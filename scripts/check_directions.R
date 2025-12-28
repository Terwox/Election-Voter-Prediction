# Quick check of variable directions
library(tidyverse)
analytic_data <- readRDS("data/processed/analytic_data.rds")

# Key variables to check direction
vars_to_check <- c("suicide1", "letdie1", "spanking", "hunt", "granborn",
                   "born", "tvhours", "owngun", "courts", "natsci")

cat("=== DIRECTION CHECK: Correlations with Trump 2020 vote ===\n\n")

for (v in vars_to_check) {
  if (v %in% names(analytic_data)) {
    r <- cor(analytic_data[[v]], analytic_data$trump20, use = "complete.obs")
    cat(sprintf("%-12s: r = %+.3f\n", v, r))
  }
}

cat("\n=== Cross-tabs for key oddballs ===\n\n")

# suicide1
cat("SUICIDE1 (right to suicide if incurable): 1=yes, 2=no\n")
analytic_data %>%
  filter(!is.na(trump20), !is.na(suicide1)) %>%
  group_by(suicide1) %>%
  summarise(n = n(), pct_trump = round(mean(trump20) * 100, 1)) %>%
  print()

cat("\nLETDIE1 (allow incurable to die): 1=yes, 2=no\n")
analytic_data %>%
  filter(!is.na(trump20), !is.na(letdie1)) %>%
  group_by(letdie1) %>%
  summarise(n = n(), pct_trump = round(mean(trump20) * 100, 1)) %>%
  print()

cat("\nSPANKING (approve spanking): 1=strongly agree ... 4=strongly disagree\n")
analytic_data %>%
  filter(!is.na(trump20), !is.na(spanking)) %>%
  group_by(spanking) %>%
  summarise(n = n(), pct_trump = round(mean(trump20) * 100, 1)) %>%
  print()

cat("\nHUNT (does R hunt): 1=yes, 2=no\n")
analytic_data %>%
  filter(!is.na(trump20), !is.na(hunt)) %>%
  group_by(hunt) %>%
  summarise(n = n(), pct_trump = round(mean(trump20) * 100, 1)) %>%
  print()

cat("\nGRANBORN (grandparents born in US): 1=all 4, 2=3, 3=2, 4=1, 5=none\n")
analytic_data %>%
  filter(!is.na(trump20), !is.na(granborn)) %>%
  group_by(granborn) %>%
  summarise(n = n(), pct_trump = round(mean(trump20) * 100, 1)) %>%
  print()

cat("\nTVHOURS (hours of TV per day)\n")
analytic_data %>%
  filter(!is.na(trump20), !is.na(tvhours)) %>%
  mutate(tv_cat = cut(tvhours, breaks = c(-1, 1, 3, 5, 24), labels = c("0-1", "2-3", "4-5", "6+"))) %>%
  group_by(tv_cat) %>%
  summarise(n = n(), pct_trump = round(mean(trump20) * 100, 1)) %>%
  print()
