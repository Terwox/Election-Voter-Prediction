# =============================================================================
# 05_rq1_variable_importance.R - RQ1: Variable Importance
# GSS Explicit Racism & Trump Voting Analysis
#
# RQ1: Which GSS variables best predict Trump voting (PRES16, PRES20)?
# Exploratory analysis with explicit acknowledgment of data fishing.
# =============================================================================

source("scripts/00_setup.R")

# Load analytic data
message("Loading analytic data...")
analytic_data <- readRDS(file.path(data_processed, "analytic_data.rds"))

# =============================================================================
# 5a. Prepare wide predictor set
# =============================================================================
message("Preparing RQ1 analysis data...")

rq1_data <- analytic_data %>%
  filter(!is.na(trump20)) %>%
  select(
    trump20,
    # Demographics
    age, female, white, educ, realinc, region,
    # Racism measures
    explicit_racism, symbolic_racism, intl_gap, work_gap,
    wrkwayup, racdif1, racdif2, racdif3, racdif4,
    # Trust
    trust_r, fair_r, helpful_r,
    # Authoritarianism
    obey, thnkself, auth_index,
    # Institutional confidence
    consci_r, conpress_r, confed_r, coneduc_r,
    # Religion
    attend, fund,
    # Economic
    eqwlth, finrela, satfin,
    # Political
    polviews, partyid
  ) %>%
  drop_na()

message("RQ1 complete cases: ", nrow(rq1_data))
message("Number of predictors: ", ncol(rq1_data) - 1)
message("Trump voters: ", sum(rq1_data$trump20), " (",
        round(100 * mean(rq1_data$trump20), 1), "%)")

# =============================================================================
# 5b. Boruta feature selection
# =============================================================================
message("\nRunning Boruta feature selection...")
message("(This may take several minutes)")

# Use fewer runs for speed; increase if needed
rq1_boruta <- Boruta(
  trump20 ~ .,
  data = rq1_data %>% mutate(trump20 = factor(trump20)),
  doTrace = 1,
  maxRuns = 100,  # Reduced for stability
  seed = 42
)

# Get results
boruta_results <- attStats(rq1_boruta) %>%
  rownames_to_column("variable") %>%
  as_tibble() %>%
  arrange(desc(meanImp))

message("\nBoruta results:")
print(boruta_results)
write_csv(boruta_results, file.path(output_tables, "rq1_boruta_results.csv"))

# Save Boruta model
saveRDS(rq1_boruta, file.path(output_models, "rq1_boruta_model.rds"))

# =============================================================================
# 5c. Stability selection (bootstrap)
# =============================================================================
message("\nRunning stability selection (50 bootstrap samples)...")

n_boot <- 50  # Reduced for stability
stability_results <- map_dfr(1:n_boot, function(i) {
  if (i %% 10 == 0) message("  Bootstrap ", i, "/", n_boot)

  boot_idx <- sample(nrow(rq1_data), replace = TRUE)
  boot_data <- rq1_data[boot_idx, ]

  rf <- ranger(
    trump20 ~ .,
    data = boot_data %>% mutate(trump20 = factor(trump20)),
    importance = "permutation",
    num.trees = 500,
    seed = i
  )

  tibble(
    boot = i,
    variable = names(rf$variable.importance),
    importance = rf$variable.importance
  )
})

stability_summary <- stability_results %>%
  group_by(variable) %>%
  summarise(
    mean_importance = mean(importance),
    sd_importance = sd(importance),
    pct_positive = mean(importance > 0),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_importance))

message("\nStability selection results:")
print(stability_summary)
write_csv(stability_summary, file.path(output_tables, "rq1_stability_selection.csv"))

# =============================================================================
# 5d. Split-sample validation
# =============================================================================
message("\nRunning split-sample validation...")

set.seed(42)
train_idx <- sample(nrow(rq1_data), 0.7 * nrow(rq1_data))
train_data <- rq1_data[train_idx, ]
test_data <- rq1_data[-train_idx, ]

message("Training set: ", nrow(train_data), " cases")
message("Test set: ", nrow(test_data), " cases")

rf_train <- ranger(
  trump20 ~ .,
  data = train_data %>% mutate(trump20 = factor(trump20)),
  importance = "permutation",
  num.trees = 1000,
  probability = TRUE,
  seed = 42
)

# Training importance
train_importance <- tibble(
  variable = names(rf_train$variable.importance),
  train_importance = rf_train$variable.importance
) %>%
  arrange(desc(train_importance))

message("\nTraining set importance (top 10):")
print(head(train_importance, 10))
write_csv(train_importance, file.path(output_tables, "rq1_train_importance.csv"))

# Test set performance
test_preds <- predict(rf_train, test_data)$predictions[, "1"]
test_roc <- roc(test_data$trump20, test_preds, quiet = TRUE)
test_auc <- auc(test_roc)

message("\nTest set AUC: ", round(test_auc, 3))
writeLines(paste("Test AUC:", round(test_auc, 3)),
           file.path(output_tables, "rq1_test_auc.txt"))

# Save trained model
saveRDS(rf_train, file.path(output_models, "rq1_rf_train.rds"))

# =============================================================================
# 5e. Visualizations
# =============================================================================
message("\nCreating visualizations...")

# Boruta plot
p_boruta <- boruta_results %>%
  mutate(
    variable = fct_reorder(variable, meanImp),
    decision = factor(decision, levels = c("Confirmed", "Tentative", "Rejected"))
  ) %>%
  ggplot(aes(x = meanImp, y = variable, fill = decision)) +
  geom_col() +
  scale_fill_manual(values = c("Confirmed" = "darkgreen",
                               "Tentative" = "gold",
                               "Rejected" = "red")) +
  labs(
    title = "RQ1: Boruta Feature Selection",
    subtitle = "Predicting Trump 2020 Vote",
    x = "Mean Importance",
    y = "Variable",
    fill = "Decision"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave(file.path(output_figures, "rq1_boruta_plot.png"),
       p_boruta, width = 10, height = 12, dpi = 300)

# Stability plot with bootstrap CIs
p_stability <- stability_summary %>%
  mutate(variable = fct_reorder(variable, mean_importance)) %>%
  ggplot(aes(x = mean_importance, y = variable)) +
  geom_point() +
  geom_errorbarh(aes(xmin = mean_importance - 1.96 * sd_importance,
                     xmax = mean_importance + 1.96 * sd_importance),
                 height = 0.2) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red") +
  labs(
    title = "RQ1: Variable Importance with Bootstrap 95% CIs",
    subtitle = paste0("Based on ", n_boot, " bootstrap samples"),
    x = "Mean Permutation Importance",
    y = "Variable"
  ) +
  theme_minimal()

ggsave(file.path(output_figures, "rq1_stability_plot.png"),
       p_stability, width = 10, height = 12, dpi = 300)

# =============================================================================
# 5f. Summary and interpretation
# =============================================================================
message("\n", paste(rep("=", 70), collapse = ""))
message("RQ1 SUMMARY")
message(paste(rep("=", 70), collapse = ""))

# Top predictors from each method
message("\nTop 10 predictors by method:")

message("\nBoruta (confirmed variables):")
confirmed <- boruta_results %>% filter(decision == "Confirmed")
print(confirmed %>% select(variable, meanImp, decision))

message("\nStability selection (mean importance):")
print(head(stability_summary %>% select(variable, mean_importance, pct_positive), 10))

message("\nTraining set RF importance:")
print(head(train_importance, 10))

# Consensus top predictors
consensus <- stability_summary %>%
  filter(pct_positive >= 0.95) %>%  # Positive in 95% of bootstrap samples
  inner_join(
    boruta_results %>% filter(decision == "Confirmed") %>% select(variable),
    by = "variable"
  ) %>%
  arrange(desc(mean_importance))

message("\nCONSENSUS TOP PREDICTORS (Boruta confirmed + 95% bootstrap stability):")
print(consensus)

write_csv(consensus, file.path(output_tables, "rq1_consensus_predictors.csv"))

message("\nCAVEAT: This is exploratory analysis. Results require replication.")
message("\n05_rq1_variable_importance.R complete!")
