# =============================================================================
# 03b_h1_race_stratified.R - H1 Analysis with Race Controls
# Addresses concern: explicit racism effect could be confounded with race
# =============================================================================

source("scripts/00_setup.R")

message("Loading analytic data...")
analytic_data <- readRDS(file.path(data_processed, "analytic_data.rds"))

# Prepare data
h1_data <- analytic_data %>%
  select(completed_anes, age, female, white, black, educ, realinc,
         explicit_racism, symbolic_racism, trust_r, polviews, partyid) %>%
  drop_na()

message("Complete cases: ", nrow(h1_data))
message("White: ", sum(h1_data$white), " | Non-white: ", sum(h1_data$white == 0))

# =============================================================================
# 1. Correlation between race and explicit racism
# =============================================================================
cat("\n=== CORRELATION: white x explicit_racism ===\n")
r <- cor(h1_data$white, h1_data$explicit_racism)
cat("r =", round(r, 3), "\n")
cat("(Positive = whites have higher explicit racism scores)\n")

# =============================================================================
# 2. Original model (white as covariate)
# =============================================================================
cat("\n=== ORIGINAL MODEL (controlling for white) ===\n")
m_orig <- glm(completed_anes ~ age + female + white + educ + realinc +
              explicit_racism + symbolic_racism + trust_r + polviews + partyid,
              data = h1_data, family = binomial)

tidy(m_orig, conf.int = TRUE, exponentiate = TRUE) %>%
  filter(term %in% c("white", "explicit_racism", "symbolic_racism")) %>%
  mutate(across(where(is.numeric), ~round(., 3))) %>%
  print()

# =============================================================================
# 3. Stratified analysis by race
# =============================================================================
cat("\n=== STRATIFIED ANALYSIS ===\n")

# White respondents only
cat("\n--- White respondents only (N =", sum(h1_data$white), ") ---\n")
m_white <- glm(completed_anes ~ age + female + educ + realinc +
               explicit_racism + symbolic_racism + trust_r + polviews + partyid,
               data = h1_data %>% filter(white == 1), family = binomial)

white_results <- tidy(m_white, conf.int = TRUE, exponentiate = TRUE) %>%
  filter(term %in% c("explicit_racism", "symbolic_racism")) %>%
  mutate(across(where(is.numeric), ~round(., 3)))
print(white_results)

# Non-white respondents only
cat("\n--- Non-white respondents only (N =", sum(h1_data$white == 0), ") ---\n")
m_nonwhite <- glm(completed_anes ~ age + female + educ + realinc +
                  explicit_racism + symbolic_racism + trust_r + polviews + partyid,
                  data = h1_data %>% filter(white == 0), family = binomial)

nonwhite_results <- tidy(m_nonwhite, conf.int = TRUE, exponentiate = TRUE) %>%
  filter(term %in% c("explicit_racism", "symbolic_racism")) %>%
  mutate(across(where(is.numeric), ~round(., 3)))
print(nonwhite_results)

# =============================================================================
# 4. Interaction model
# =============================================================================
cat("\n=== INTERACTION MODEL ===\n")
m_int <- glm(completed_anes ~ age + female + educ + realinc +
             explicit_racism * white + symbolic_racism * white +
             trust_r + polviews + partyid,
             data = h1_data, family = binomial)

int_results <- tidy(m_int, conf.int = TRUE, exponentiate = TRUE) %>%
  filter(grepl("racism|white", term)) %>%
  mutate(across(where(is.numeric), ~round(., 3)))
print(int_results)

# =============================================================================
# 5. Summary
# =============================================================================
cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat("SUMMARY\n")
cat(paste(rep("=", 70), collapse = ""), "\n")

cat("\n1. Correlation between white and explicit_racism: r =", round(r, 3), "\n")
cat("   (", ifelse(r > 0, "Positive", "Negative"), ": whites have",
    ifelse(r > 0, "higher", "lower"), "explicit racism scores)\n")

cat("\n2. Original model (pooled, controlling for white):\n")
cat("   Explicit racism OR =", white_results$estimate[1], ", p =", white_results$p.value[1], "\n")

cat("\n3. Stratified results:\n")
cat("   White only: explicit_racism OR =", white_results$estimate[1],
    ", p =", white_results$p.value[1], "\n")
cat("   Non-white only: explicit_racism OR =", nonwhite_results$estimate[1],
    ", p =", nonwhite_results$p.value[1], "\n")

cat("\n4. Key finding:\n")
if (white_results$p.value[1] < 0.05) {
  cat("   Among WHITE respondents, explicit racism STILL predicts ANES completion\n")
  cat("   This rules out race as a confound - the effect is within-race\n")
} else {
  cat("   Among white respondents alone, effect is not significant\n")
  cat("   Race may partially confound the overall finding\n")
}

# Save results
results_summary <- bind_rows(
  white_results %>% mutate(sample = "White only"),
  nonwhite_results %>% mutate(sample = "Non-white only")
)
write_csv(results_summary, file.path(output_tables, "h1_race_stratified.csv"))

message("\n03b_h1_race_stratified.R complete!")
