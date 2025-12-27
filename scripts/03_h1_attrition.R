# =============================================================================
# 03_h1_attrition.R - H1: Systematic Attrition Analysis
# GSS Explicit Racism & Trump Voting Analysis
#
# H1: The ANES-GSS 2020 joint study subsample (n ~ 1,164) differs from
# GSS 2016-2020 panel non-completers (n ~ 4,051) on racial attitudes,
# social trust, and other theoretically relevant dimensions.
# =============================================================================

source("scripts/00_setup.R")

# Load analytic data
message("Loading analytic data...")
analytic_data <- readRDS(file.path(data_processed, "analytic_data.rds"))

# =============================================================================
# 3a. Prepare H1 analysis data
# =============================================================================
message("Preparing H1 analysis data...")

h1_data <- analytic_data %>%
  select(
    completed_anes,
    # Demographics
    age, female, white, educ, realinc, region,
    # Racism measures
    explicit_racism, symbolic_racism, intl_gap, work_gap,
    # Trust
    trust_r, fair_r, helpful_r,
    # Other theoretically relevant
    attend, polviews, partyid, auth_index
  ) %>%
  drop_na(completed_anes)

message("H1 data: ", nrow(h1_data), " cases")
message("Completers: ", sum(h1_data$completed_anes),
        " | Non-completers: ", sum(h1_data$completed_anes == 0))

# =============================================================================
# 3b. Descriptive comparison
# =============================================================================
message("\nDescriptive comparison by ANES completion status...")

desc_comparison <- h1_data %>%
  group_by(completed_anes) %>%
  summarise(across(everything(), list(
    n = ~sum(!is.na(.)),
    mean = ~mean(., na.rm = TRUE),
    sd = ~sd(., na.rm = TRUE)
  ), .names = "{.col}_{.fn}")) %>%
  pivot_longer(-completed_anes, names_to = "stat", values_to = "value") %>%
  separate(stat, into = c("variable", "statistic"), sep = "_(?=[^_]+$)") %>%
  pivot_wider(names_from = c(completed_anes, statistic),
              values_from = value,
              names_glue = "{statistic}_{completed_anes}")

print(desc_comparison)
write_csv(desc_comparison, file.path(output_tables, "h1_descriptive_comparison.csv"))

# =============================================================================
# 3c. Logistic regression: predictors of ANES completion
# =============================================================================
message("\nFitting logistic regression...")

# Prepare data for regression (complete cases only for key variables)
h1_reg_data <- h1_data %>%
  select(completed_anes, age, female, white, educ, realinc,
         explicit_racism, symbolic_racism,
         trust_r, polviews, partyid) %>%
  drop_na()

message("Complete cases for regression: ", nrow(h1_reg_data))

h1_logit <- glm(completed_anes ~ .,
                data = h1_reg_data,
                family = binomial)

h1_logit_tidy <- tidy(h1_logit, conf.int = TRUE, exponentiate = TRUE) %>%
  mutate(across(where(is.numeric), ~round(., 3)))

print(h1_logit_tidy)
write_csv(h1_logit_tidy, file.path(output_tables, "h1_logit_results.csv"))

# Model summary
message("\nLogistic regression summary:")
print(summary(h1_logit))

# =============================================================================
# 3d. Random forest for variable importance
# =============================================================================
message("\nFitting random forest...")

h1_rf <- ranger(
  completed_anes ~ .,
  data = h1_reg_data %>% mutate(completed_anes = factor(completed_anes)),
  importance = "permutation",
  num.trees = 1000,
  seed = 42
)

h1_importance <- tibble(
  variable = names(h1_rf$variable.importance),
  importance = h1_rf$variable.importance
) %>%
  arrange(desc(importance))

print(h1_importance)
write_csv(h1_importance, file.path(output_tables, "h1_rf_importance.csv"))

# Save RF model
saveRDS(h1_rf, file.path(output_models, "h1_rf_model.rds"))

# =============================================================================
# 3e. Variable importance plot
# =============================================================================
message("\nCreating importance plot...")

p_importance <- h1_importance %>%
  mutate(variable = fct_reorder(variable, importance)) %>%
  ggplot(aes(x = importance, y = variable)) +
  geom_col(fill = "steelblue") +
  labs(
    title = "H1: Predictors of ANES-GSS Joint Study Completion",
    subtitle = "Permutation importance from Random Forest",
    x = "Permutation Importance",
    y = "Variable"
  ) +
  theme_minimal()

ggsave(file.path(output_figures, "h1_importance_plot.png"),
       p_importance, width = 8, height = 6, dpi = 300)

# =============================================================================
# 3f. Interpretation
# =============================================================================
message("\n" , paste(rep("=", 70), collapse = ""))
message("H1 INTERPRETATION")
message(paste(rep("=", 70), collapse = ""))

# Check if racism measures predict completion
racism_coefs <- h1_logit_tidy %>%
  filter(term %in% c("explicit_racism", "symbolic_racism"))

message("\nRacism measures as predictors of ANES completion:")
print(racism_coefs)

if (any(racism_coefs$p.value < 0.05)) {
  message("\nWARNING: Racism measures significantly predict ANES completion.")
  message("This suggests potential selection bias in joint study estimates.")
} else {
  message("\nNo significant selection on racism measures detected.")
}

message("\n03_h1_attrition.R complete!")
