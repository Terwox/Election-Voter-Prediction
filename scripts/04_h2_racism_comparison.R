# =============================================================================
# 04_h2_racism_comparison.R - H2: Explicit vs. Symbolic Racism
# GSS Explicit Racism & Trump Voting Analysis
#
# H2: Explicit racial stereotype measures (INTLBLKS, WORKBLKS) predict
# Trump vote choice differently than symbolic racism measures (WRKWAYUP,
# RACDIF1-4) - in magnitude, direction, or incremental validity.
# =============================================================================

source("scripts/00_setup.R")

# Load analytic data
message("Loading analytic data...")
analytic_data <- readRDS(file.path(data_processed, "analytic_data.rds"))

# =============================================================================
# 4a. Prepare H2 analysis data
# =============================================================================
message("Preparing H2 analysis data...")

# Restrict to cases with both racism measures and vote choice
h2_data <- analytic_data %>%
  filter(!is.na(trump20) & !is.na(explicit_racism) & !is.na(symbolic_racism)) %>%
  select(
    trump20, trump20_gss, trump20_anes,
    explicit_racism, symbolic_racism,
    intl_gap, work_gap,
    age, female, white, educ, realinc, attend, polviews
  ) %>%
  drop_na(trump20, explicit_racism, symbolic_racism,
          age, female, white, educ, attend, polviews)

message("H2 analysis N: ", nrow(h2_data))
message("Trump 2020 voters: ", sum(h2_data$trump20), " (",
        round(100 * mean(h2_data$trump20), 1), "%)")

# Check racism measure distributions
message("\nRacism measure summaries:")
message("Explicit racism - Mean: ", round(mean(h2_data$explicit_racism), 3),
        ", SD: ", round(sd(h2_data$explicit_racism), 3))
message("Symbolic racism - Mean: ", round(mean(h2_data$symbolic_racism), 3),
        ", SD: ", round(sd(h2_data$symbolic_racism), 3))

# =============================================================================
# 4b. Nested models
# =============================================================================
message("\nFitting nested models...")

# Model 1: Demographics only
m1_demog <- glm(trump20 ~ age + female + white + educ + realinc + attend,
                data = h2_data, family = binomial)

# Model 2: Demographics + Symbolic racism
m2_symbolic <- glm(trump20 ~ age + female + white + educ + realinc + attend +
                     symbolic_racism,
                   data = h2_data, family = binomial)

# Model 3: Demographics + Explicit racism
m3_explicit <- glm(trump20 ~ age + female + white + educ + realinc + attend +
                     explicit_racism,
                   data = h2_data, family = binomial)

# Model 4: Demographics + Both
m4_both <- glm(trump20 ~ age + female + white + educ + realinc + attend +
                 symbolic_racism + explicit_racism,
               data = h2_data, family = binomial)

# =============================================================================
# 4c. Model comparison table
# =============================================================================
message("\nComparing model fit...")

models <- list(m1_demog, m2_symbolic, m3_explicit, m4_both)
model_names <- c("Demographics", "+ Symbolic", "+ Explicit", "Both")

model_comparison <- tibble(
  model = model_names,
  AIC = map_dbl(models, AIC),
  BIC = map_dbl(models, BIC),
  deviance = map_dbl(models, deviance),
  df_residual = map_dbl(models, ~.$df.residual),
  n_params = map_dbl(models, ~length(coef(.)))
) %>%
  mutate(
    delta_AIC = AIC - min(AIC),
    delta_BIC = BIC - min(BIC)
  )

print(model_comparison)
write_csv(model_comparison, file.path(output_tables, "h2_model_comparison.csv"))

# =============================================================================
# 4d. Likelihood ratio tests
# =============================================================================
message("\nLikelihood ratio tests...")

# Does explicit add to symbolic?
lrt_explicit_over_symbolic <- anova(m2_symbolic, m4_both, test = "Chisq")
message("\nDoes explicit add to symbolic?")
print(lrt_explicit_over_symbolic)

# Does symbolic add to explicit?
lrt_symbolic_over_explicit <- anova(m3_explicit, m4_both, test = "Chisq")
message("\nDoes symbolic add to explicit?")
print(lrt_symbolic_over_explicit)

# =============================================================================
# 4e. Coefficient comparison
# =============================================================================
message("\nExtracting coefficients...")

coef_table <- bind_rows(
  tidy(m1_demog, conf.int = TRUE, exponentiate = TRUE) %>%
    mutate(model = "Demographics"),
  tidy(m2_symbolic, conf.int = TRUE, exponentiate = TRUE) %>%
    mutate(model = "+ Symbolic"),
  tidy(m3_explicit, conf.int = TRUE, exponentiate = TRUE) %>%
    mutate(model = "+ Explicit"),
  tidy(m4_both, conf.int = TRUE, exponentiate = TRUE) %>%
    mutate(model = "Both")
) %>%
  mutate(across(where(is.numeric), ~round(., 3)))

write_csv(coef_table, file.path(output_tables, "h2_coefficient_table.csv"))

# Focus on racism coefficients
racism_coefs <- coef_table %>%
  filter(term %in% c("symbolic_racism", "explicit_racism"))
print(racism_coefs)

# =============================================================================
# 4f. AUC comparison
# =============================================================================
message("\nROC/AUC analysis...")

# Use fitted values to ensure matching length (handles any dropped NA cases)
roc_demog <- roc(m1_demog$y, fitted(m1_demog), quiet = TRUE)
roc_symbolic <- roc(m2_symbolic$y, fitted(m2_symbolic), quiet = TRUE)
roc_explicit <- roc(m3_explicit$y, fitted(m3_explicit), quiet = TRUE)
roc_both <- roc(m4_both$y, fitted(m4_both), quiet = TRUE)

auc_table <- tibble(
  model = model_names,
  AUC = c(auc(roc_demog), auc(roc_symbolic), auc(roc_explicit), auc(roc_both))
) %>%
  mutate(AUC = round(AUC, 3))

print(auc_table)
write_csv(auc_table, file.path(output_tables, "h2_auc_comparison.csv"))

# ROC curve comparison tests
message("\nROC curve comparison:")
message("Symbolic vs Demog: ")
print(roc.test(roc_demog, roc_symbolic))

message("\nExplicit vs Demog: ")
print(roc.test(roc_demog, roc_explicit))

message("\nBoth vs Symbolic: ")
print(roc.test(roc_symbolic, roc_both))

message("\nBoth vs Explicit: ")
print(roc.test(roc_explicit, roc_both))

# =============================================================================
# 4g. Visualization
# =============================================================================
message("\nCreating visualizations...")

# ROC curves plot
png(file.path(output_figures, "h2_roc_curves.png"), width = 8, height = 6,
    units = "in", res = 300)
plot(roc_demog, col = "gray50", main = "ROC Curves: Predicting Trump 2020 Vote")
plot(roc_symbolic, add = TRUE, col = "blue")
plot(roc_explicit, add = TRUE, col = "red")
plot(roc_both, add = TRUE, col = "purple")
legend("bottomright",
       legend = paste(model_names, "- AUC:", round(auc_table$AUC, 3)),
       col = c("gray50", "blue", "red", "purple"),
       lwd = 2)
dev.off()

# Coefficient forest plot
p_coef <- racism_coefs %>%
  ggplot(aes(x = estimate, y = model, color = term)) +
  geom_point(size = 3, position = position_dodge(0.3)) +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high),
                 height = 0.2, position = position_dodge(0.3)) +
  geom_vline(xintercept = 1, linetype = "dashed") +
  scale_x_log10() +
  labs(
    title = "H2: Racism Measures as Predictors of Trump 2020 Vote",
    subtitle = "Odds ratios with 95% CIs (controlling for demographics)",
    x = "Odds Ratio",
    y = "Model",
    color = "Predictor"
  ) +
  theme_minimal()

ggsave(file.path(output_figures, "h2_coefficient_plot.png"),
       p_coef, width = 10, height = 5, dpi = 300)

# =============================================================================
# 4h. Save models
# =============================================================================
h2_models <- list(
  demographics = m1_demog,
  symbolic = m2_symbolic,
  explicit = m3_explicit,
  both = m4_both
)
saveRDS(h2_models, file.path(output_models, "h2_models.rds"))

# =============================================================================
# 4i. Interpretation
# =============================================================================
message("\n", paste(rep("=", 70), collapse = ""))
message("H2 INTERPRETATION")
message(paste(rep("=", 70), collapse = ""))

message("\nBest fitting model (lowest AIC): ",
        model_comparison$model[which.min(model_comparison$AIC)])
message("Best fitting model (lowest BIC): ",
        model_comparison$model[which.min(model_comparison$BIC)])

# Check incremental validity
explicit_p <- lrt_explicit_over_symbolic$`Pr(>Chi)`[2]
symbolic_p <- lrt_symbolic_over_explicit$`Pr(>Chi)`[2]

message("\nIncremental validity:")
message("  Explicit adds to symbolic: p = ", round(explicit_p, 4))
message("  Symbolic adds to explicit: p = ", round(symbolic_p, 4))

if (explicit_p < 0.05 & symbolic_p < 0.05) {
  message("\nCONCLUSION: Both measures provide unique predictive information.")
} else if (explicit_p < 0.05) {
  message("\nCONCLUSION: Explicit racism adds beyond symbolic, but not vice versa.")
} else if (symbolic_p < 0.05) {
  message("\nCONCLUSION: Symbolic racism adds beyond explicit, but not vice versa.")
} else {
  message("\nCONCLUSION: Neither measure adds significantly beyond the other.")
}

message("\n04_h2_racism_comparison.R complete!")
