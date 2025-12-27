# Research Spec: GSS Explicit Racism & Trump Voting

## Overview

Exploratory analysis examining (1) whether ANES-GSS joint study participants differ systematically from non-participants, and (2) whether explicit racial stereotype measures predict Trump voting differently than symbolic racism measures. Secondary goal: identify which GSS variables most strongly predict Trump vote choice.

---

## Hypotheses & Research Questions

### H1: Systematic Attrition
The ANES-GSS 2020 joint study subsample (n ≈ 1,164) differs from GSS 2016-2020 panel non-completers (n ≈ 4,051) on racial attitudes, social trust, and other theoretically relevant dimensions.
- *Null*: No systematic differences beyond demographics already captured by weights.

### H2: Explicit vs. Symbolic Racism
Explicit racial stereotype measures (INTLBLKS, WORKBLKS) predict Trump vote choice differently than symbolic racism measures (WRKWAYUP, RACDIF1-4)—in magnitude, direction, or incremental validity.
- *Null*: Both measure sets perform equivalently as predictors.

### RQ1: Variable Importance
Which GSS variables best predict Trump voting (PRES16, PRES20)? Exploratory analysis with explicit acknowledgment of fishing.

---

## Data Sources

### Files to Download

| Source | URL | Format | Notes |
|--------|-----|--------|-------|
| GSS 2016-2020 Panel | https://gss.norc.org/get-the-data → "2016-2020 GSS Panel" | Stata (.dta) | 5,215 cases |
| ANES-GSS 2020 Joint Study | https://electionstudies.org/data-center/anes-gss-2020-joint-study/ | Stata (.dta) | 1,164 cases |
| GSS 1972-2024 Cumulative | https://gss.norc.org/get-the-data → "GSS 1972-2024 Cross-Sectional Cumulative Data" | Stata (.dta) | ~75,000 cases (for robustness/trends) |

### Merge Keys
- GSS Panel ↔ ANES-GSS Joint Study: Use `SAMPCODE` and `YEARID` or the Case ID variable specified in Joint Study codebook (check: `V200001` maps to GSS case ID)
- The Joint Study codebook specifies exact merge procedure—follow it

---

## Key Variables

### Explicit Racism (GSS stereotype items)
7-point scales: 1 = negative trait, 7 = positive trait

| Variable | Description | Ballots |
|----------|-------------|---------|
| INTLWHTS | Whites: unintelligent (1) to intelligent (7) | A, B |
| INTLBLKS | Blacks: unintelligent (1) to intelligent (7) | A, B |
| WORKWHTS | Whites: lazy (1) to hardworking (7) | A, B |
| WORKBLKS | Blacks: lazy (1) to hardworking (7) | A, B |

**Derived variables:**
```r
# Gap scores (positive = more negative view of Blacks relative to Whites)
intl_gap <- INTLWHTS - INTLBLKS
work_gap <- WORKWHTS - WORKBLKS

# Combined explicit racism index (average of gap scores)
explicit_racism <- (intl_gap + work_gap) / 2
```

### Symbolic Racism (GSS items)

| Variable | Description | Scale |
|----------|-------------|-------|
| WRKWAYUP | "Blacks should work their way up without special favors" | 1-5 (agree-disagree) |
| RACDIF1 | Discrimination causes inequality | 1=yes, 2=no |
| RACDIF2 | Inborn ability causes inequality | 1=yes, 2=no |
| RACDIF3 | Lack of motivation causes inequality | 1=yes, 2=no |
| RACDIF4 | Lack of education causes inequality | 1=yes, 2=no |

**Derived variables:**
```r
# Symbolic racism index
# WRKWAYUP: recode so higher = more symbolic racism
# RACDIF2, RACDIF3: "yes" = more symbolic racism
# RACDIF1, RACDIF4: "no" = more symbolic racism (denial of structural causes)

wrkwayup_r <- 6 - WRKWAYUP  # reverse so higher = more racism
racdif1_r <- ifelse(RACDIF1 == 2, 1, 0)  # 1 if denies discrimination
racdif2_r <- ifelse(RACDIF2 == 1, 1, 0)  # 1 if endorses ability
racdif3_r <- ifelse(RACDIF3 == 1, 1, 0)  # 1 if endorses motivation
racdif4_r <- ifelse(RACDIF4 == 2, 1, 0)  # 1 if denies education

# Standardize and average (or use factor analysis)
symbolic_racism <- rowMeans(scale(cbind(wrkwayup_r, racdif1_r, racdif2_r, racdif3_r, racdif4_r)), na.rm = TRUE)
```

### Outcome Variables

| Variable | Source | Description | Recoding |
|----------|--------|-------------|----------|
| PRES16 | GSS Panel | 2016 presidential vote (self-report) | 1=Trump, 0=Clinton, NA=other/didn't vote |
| PRES20 | GSS Panel | 2020 presidential vote (self-report) | 1=Trump, 0=Biden, NA=other/didn't vote |
| V202073 | ANES Joint Study | 2020 presidential vote (validated) | Check codebook for exact values; recode to 1=Trump, 0=Biden |
| completed_anes | Derived | Completed joint study | 1=in joint study, 0=panel only |

### Covariates / Candidate Predictors

**Demographics:**
- AGE (continuous)
- SEX (1=male, 2=female → recode to 0/1)
- RACE (1=white, 2=black, 3=other)
- EDUC (years of education, 0-20)
- DEGREE (highest degree: 0=<HS, 1=HS, 2=JC, 3=BA, 4=grad)
- INCOME16 or REALINC (household income)
- REGION (9 census regions)

**Social Trust:**
- TRUST ("Can people be trusted?" 1=yes, 2=no)
- FAIR ("Do people try to be fair?" 1=yes, 2=no)
- HELPFUL ("Are people helpful?" 1=yes, 2=no)

**Authoritarianism Proxies (child-rearing values):**
- OBEY (obedience important in child)
- THNKSELF (thinking for self important in child)
- Derived: auth_index = OBEY ranking - THNKSELF ranking (higher = more authoritarian)

**Institutional Confidence (1=great deal, 2=some, 3=hardly any):**
- CONSCI (science)
- CONPRESS (press)
- CONFED (federal government)
- CONEDUC (education)

**Religious:**
- ATTEND (religious attendance, 0-8)
- RELIG (religious affiliation)
- FUND (fundamentalism: 1=fund, 2=moderate, 3=liberal)

**Economic Attitudes:**
- EQWLTH (government reduce income differences, 1-7)
- FINRELA (financial situation relative to others)
- SATFIN (satisfaction with finances)

---

## Handling Missing Data

### Ballot-Based Missingness
Stereotype items (INTLBLKS, WORKBLKS, etc.) only appear on Ballots A and B, not C. Expect ~1/3 structural missingness.

**Approach:**
1. For H2 and stereotype-specific analyses: listwise deletion (only include cases with stereotype data)
2. For RQ1 variable importance: use random forest's native handling of missingness OR multiple imputation
3. Report N for each analysis explicitly

### Item Nonresponse
- Code refused/don't know as NA
- Report missingness rates per variable
- For RQ1: Boruta/RF can handle some missingness; document threshold used

---

## Analytical Pipeline

### Step 0: Environment Setup
```r
# Required packages
install.packages(c(
  "haven",        # read Stata files
  "tidyverse",    # data manipulation
  "janitor",      # clean names
  "labelled",     # handle labeled data
  "ranger",       # fast random forest
  "Boruta",       # feature selection
  "caret",        # model training utilities
  "pROC",         # ROC/AUC
  "broom",        # tidy model output
  "gt",           # tables
  "ggplot2",      # figures
  "patchwork"     # combine figures
))

set.seed(42)  # reproducibility
```

### Step 1: Data Acquisition & Merge
```r
# 1a. Load GSS 2016-2020 Panel
gss_panel <- haven::read_dta("path/to/gss_panel_2016_2020.dta") %>%
  janitor::clean_names() %>%
  labelled::unlabelled()

# 1b. Load ANES-GSS Joint Study
anes_gss <- haven::read_dta("path/to/anes_gss_2020_joint.dta") %>%
  janitor::clean_names() %>%
  labelled::unlabelled()

# 1c. Create completer flag
gss_panel <- gss_panel %>%
  mutate(completed_anes = if_else(case_id %in% anes_gss$case_id, 1, 0))

# 1d. Merge for joint analyses
# Follow codebook instructions for exact merge keys
joint_data <- gss_panel %>%
  left_join(anes_gss, by = "case_id")  # adjust key as needed
```

### Step 2: Derive Variables
```r
# 2a. Explicit racism measures
analytic_data <- joint_data %>%
  mutate(
    intl_gap = intlwhts - intlblks,
    work_gap = workwhts - workblks,
    explicit_racism = (intl_gap + work_gap) / 2
  )

# 2b. Symbolic racism measures
analytic_data <- analytic_data %>%
  mutate(
    wrkwayup_r = 6 - wrkwayup,
    racdif1_r = if_else(racdif1 == 2, 1, 0),
    racdif2_r = if_else(racdif2 == 1, 1, 0),
    racdif3_r = if_else(racdif3 == 1, 1, 0),
    racdif4_r = if_else(racdif4 == 2, 1, 0)
  ) %>%
  rowwise() %>%
  mutate(
    symbolic_racism = mean(c_across(c(wrkwayup_r, racdif1_r, racdif2_r, racdif3_r, racdif4_r)), na.rm = TRUE)
  ) %>%
  ungroup()

# 2c. Outcome recoding
analytic_data <- analytic_data %>%
  mutate(
    trump16 = case_when(
      pres16 == 1 ~ 1,  # check actual coding in codebook
      pres16 == 2 ~ 0,
      TRUE ~ NA_real_
    ),
    trump20 = case_when(
      pres20 == 1 ~ 1,
      pres20 == 2 ~ 0,
      TRUE ~ NA_real_
    )
  )

# 2d. Covariates
analytic_data <- analytic_data %>%
  mutate(
    female = if_else(sex == 2, 1, 0),
    white = if_else(race == 1, 1, 0),
    # ... etc
  )
```

### Step 3: H1 — Attrition Analysis
```r
# 3a. Outcome: completed_anes (1/0)
# Predictors: All GSS variables measured before ANES follow-up

h1_data <- analytic_data %>%
  select(completed_anes, 
         # Demographics
         age, female, white, educ, realinc, region,
         # Racism measures
         explicit_racism, symbolic_racism, intl_gap, work_gap,
         # Trust
         trust, fair, helpful,
         # Other theoretically relevant
         attend, polviews, partyid) %>%
  drop_na(completed_anes)

# 3b. Logistic regression
h1_logit <- glm(completed_anes ~ ., data = h1_data, family = binomial)
summary(h1_logit)
broom::tidy(h1_logit, conf.int = TRUE) %>%
  write_csv("output/h1_logit_results.csv")

# 3c. Random forest for variable importance
h1_rf <- ranger::ranger(
  completed_anes ~ .,
  data = h1_data %>% mutate(completed_anes = factor(completed_anes)),
  importance = "permutation",
  num.trees = 1000
)

h1_importance <- tibble(
  variable = names(h1_rf$variable.importance),
  importance = h1_rf$variable.importance
) %>%
  arrange(desc(importance))

write_csv(h1_importance, "output/h1_rf_importance.csv")

# 3d. Interpretation
# If explicit_racism or symbolic_racism predict completion, note selection bias concern
```

### Step 4: H2 — Explicit vs. Symbolic Comparison
```r
# 4a. Restrict to cases with both racism measures and vote choice
h2_data <- analytic_data %>%
  filter(!is.na(trump20) & !is.na(explicit_racism) & !is.na(symbolic_racism)) %>%
  select(trump20, explicit_racism, symbolic_racism,
         age, female, white, educ, realinc, attend, polviews)

# 4b. Nested models
m1_demog <- glm(trump20 ~ age + female + white + educ + realinc + attend, 
                data = h2_data, family = binomial)
m2_symbolic <- glm(trump20 ~ age + female + white + educ + realinc + attend + symbolic_racism, 
                   data = h2_data, family = binomial)
m3_explicit <- glm(trump20 ~ age + female + white + educ + realinc + attend + explicit_racism, 
                   data = h2_data, family = binomial)
m4_both <- glm(trump20 ~ age + female + white + educ + realinc + attend + symbolic_racism + explicit_racism, 
               data = h2_data, family = binomial)

# 4c. Compare model fit
models <- list(m1_demog, m2_symbolic, m3_explicit, m4_both)
model_comparison <- tibble(
  model = c("Demographics", "+ Symbolic", "+ Explicit", "Both"),
  AIC = map_dbl(models, AIC),
  BIC = map_dbl(models, BIC),
  deviance = map_dbl(models, deviance),
  df = map_dbl(models, ~ .$df.residual)
)

# 4d. Likelihood ratio tests
anova(m2_symbolic, m4_both, test = "Chisq")  # Does explicit add to symbolic?
anova(m3_explicit, m4_both, test = "Chisq")  # Does symbolic add to explicit?

# 4e. AUC comparison
library(pROC)
roc_symbolic <- roc(h2_data$trump20, predict(m2_symbolic, type = "response"))
roc_explicit <- roc(h2_data$trump20, predict(m3_explicit, type = "response"))
roc_both <- roc(h2_data$trump20, predict(m4_both, type = "response"))

roc.test(roc_symbolic, roc_both)
roc.test(roc_explicit, roc_both)

# 4f. Save results
write_csv(model_comparison, "output/h2_model_comparison.csv")
```

### Step 5: RQ1 — Variable Importance
```r
# 5a. Prepare wide predictor set
rq1_data <- analytic_data %>%
  filter(!is.na(trump20)) %>%
  select(trump20,
         # All candidate predictors
         age, female, white, educ, realinc, region,
         explicit_racism, symbolic_racism, intl_gap, work_gap,
         wrkwayup, racdif1, racdif2, racdif3, racdif4,
         trust, fair, helpful,
         obey, thnkself,
         consci, conpress, confed, coneduc,
         attend, fund,
         eqwlth, finrela, satfin,
         polviews, partyid) %>%
  drop_na()  # or use imputation

# 5b. Boruta feature selection
library(Boruta)
rq1_boruta <- Boruta(
  trump20 ~ .,
  data = rq1_data %>% mutate(trump20 = factor(trump20)),
  doTrace = 2,
  maxRuns = 300
)

boruta_results <- attStats(rq1_boruta) %>%
  rownames_to_column("variable") %>%
  arrange(desc(meanImp))

write_csv(boruta_results, "output/rq1_boruta_results.csv")

# 5c. Stability selection (bootstrap)
n_boot <- 100
stability_results <- map_dfr(1:n_boot, function(i) {
  boot_idx <- sample(nrow(rq1_data), replace = TRUE)
  boot_data <- rq1_data[boot_idx, ]
  
  rf <- ranger::ranger(
    trump20 ~ .,
    data = boot_data %>% mutate(trump20 = factor(trump20)),
    importance = "permutation",
    num.trees = 500
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

write_csv(stability_summary, "output/rq1_stability_selection.csv")

# 5d. Split-sample validation
set.seed(42)
train_idx <- sample(nrow(rq1_data), 0.7 * nrow(rq1_data))
train_data <- rq1_data[train_idx, ]
test_data <- rq1_data[-train_idx, ]

rf_train <- ranger::ranger(
  trump20 ~ .,
  data = train_data %>% mutate(trump20 = factor(trump20)),
  importance = "permutation",
  num.trees = 1000,
  probability = TRUE
)

# Check if importance rankings replicate
train_importance <- tibble(
  variable = names(rf_train$variable.importance),
  train_importance = rf_train$variable.importance
)

# Test set performance
test_preds <- predict(rf_train, test_data)$predictions[, 2]
test_auc <- pROC::auc(test_data$trump20, test_preds)

write_csv(train_importance, "output/rq1_train_importance.csv")
cat("Test AUC:", test_auc, "\n", file = "output/rq1_test_auc.txt")
```

---

## Output Specifications

### Directory Structure
```
project/
├── data/
│   ├── raw/              # Downloaded files (do not modify)
│   ├── processed/        # Cleaned/merged analytic files
├── output/
│   ├── tables/           # CSV tables
│   ├── figures/          # PNG figures
│   ├── models/           # Saved model objects (.rds)
├── scripts/
│   ├── 01_load_merge.R
│   ├── 02_derive_variables.R
│   ├── 03_h1_attrition.R
│   ├── 04_h2_racism_comparison.R
│   ├── 05_rq1_variable_importance.R
├── gss_trump_research_spec.md
├── README.md
```

### Output Files

**Tables (CSV):**
- `h1_logit_results.csv` — Logistic regression coefficients for attrition
- `h1_rf_importance.csv` — RF variable importance for attrition
- `h2_model_comparison.csv` — Nested model fit statistics
- `h2_coefficient_table.csv` — Coefficients from all H2 models
- `rq1_boruta_results.csv` — Boruta feature selection results
- `rq1_stability_selection.csv` — Bootstrap stability results

**Figures (PNG, 300 dpi):**
- `h1_importance_plot.png` — Bar chart of attrition predictors
- `h2_roc_curves.png` — ROC curves comparing symbolic vs explicit
- `h2_coefficient_plot.png` — Forest plot of racism coefficients
- `rq1_boruta_plot.png` — Boruta importance with confirmed/rejected
- `rq1_stability_plot.png` — Variable importance with bootstrap CIs

**Model Objects (RDS):**
- `h1_rf_model.rds`
- `h2_models.rds` (list of all 4 models)
- `rq1_boruta_model.rds`
- `rq1_rf_train.rds`

---

## Limitations (State in Any Writeup)

1. **Attrition bias**: If H1 confirms systematic differences, H2/RQ1 findings may not generalize to full population. Will quantify direction and magnitude.

2. **Small N for joint study**: 1,164 cases limits power for detecting small effects and model complexity. Will report power analysis for H2.

3. **Ballot design**: Stereotype items only on Ballots A+B; ~33% structural missingness. Will report effective N.

4. **Self-reported vote**: PRES16/PRES20 in GSS not validated. Social desirability may bias Trump vote reporting. Joint study has validated 2020 only.

5. **Exploratory framing**: RQ1 is explicitly fishing. Findings require replication. Will use stability selection and split-sample validation to reduce false discoveries.

6. **Temporal confounds**: GSS attitudes measured at varying times relative to elections. Cannot establish causal direction.

7. **Weighting**: Will run sensitivity analyses with and without weights. Report both.

---

## Notes for Claude Code

- All file paths are placeholders—will need actual downloaded files
- Check variable names against codebooks (may differ in case or exact spelling)
- The PRES16/PRES20 coding needs verification against GSS codebook
- Joint study merge procedure should follow their exact documentation
- Random seed set to 42 for reproducibility; document any deviations
- If packages fail to install, may need to specify CRAN mirror or use `pak`
