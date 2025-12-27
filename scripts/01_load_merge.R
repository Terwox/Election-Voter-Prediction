# =============================================================================
# 01_load_merge.R - Data Loading and Merging
# GSS Explicit Racism & Trump Voting Analysis
# =============================================================================

source("scripts/00_setup.R")

# =============================================================================
# 1a. Load GSS 2016-2020 Panel
# =============================================================================
message("Loading GSS 2016-2020 Panel data...")

gss_panel <- read_dta(file.path(data_raw, "gss2020panel_r1a.dta")) %>%
  clean_names()

message("GSS Panel dimensions: ", nrow(gss_panel), " rows x ", ncol(gss_panel), " cols")

# =============================================================================
# 1b. Load ANES-GSS 2020 Joint Study
# =============================================================================
message("Loading ANES-GSS 2020 Joint Study data...")

anes_gss <- read_csv(file.path(data_raw, "anes_timeseries_2020_gss_csv_20220408.csv"),
                     show_col_types = FALSE) %>%
  clean_names()

message("ANES-GSS dimensions: ", nrow(anes_gss), " rows x ", ncol(anes_gss), " cols")

# =============================================================================
# 1c. Create completer flag in GSS Panel
# =============================================================================
message("Creating ANES completer flag...")

# anesid in GSS panel links to v200001 in ANES
gss_panel <- gss_panel %>%
  mutate(
    completed_anes = if_else(!is.na(anesid), 1, 0)
  )

message("ANES completers: ", sum(gss_panel$completed_anes), " / ", nrow(gss_panel))

# =============================================================================
# 1d. Merge GSS Panel with ANES-GSS Joint Study
# =============================================================================
message("Merging datasets...")

# Prepare ANES data for merge - rename v200001 to match anesid
anes_gss_merge <- anes_gss %>%
  rename(anesid = v200001)

# Left join - keep all GSS panel, add ANES data where available
joint_data <- gss_panel %>%
  left_join(anes_gss_merge, by = "anesid", suffix = c("", "_anes"))

message("Joint data dimensions: ", nrow(joint_data), " rows x ", ncol(joint_data), " cols")

# Verify merge
n_matched <- sum(!is.na(joint_data$v202073))
message("Cases with ANES 2020 vote (v202073): ", n_matched)

# =============================================================================
# 1e. Save merged data
# =============================================================================
message("Saving merged data...")

saveRDS(joint_data, file.path(data_processed, "joint_data.rds"))

# Also save a summary of the merge
merge_summary <- tibble(
  dataset = c("GSS Panel", "ANES-GSS Joint", "Merged (joint_data)", "With ANES vote"),
  n_rows = c(nrow(gss_panel), nrow(anes_gss), nrow(joint_data), n_matched),
  n_cols = c(ncol(gss_panel), ncol(anes_gss), ncol(joint_data), NA)
)

write_csv(merge_summary, file.path(output_tables, "01_merge_summary.csv"))
print(merge_summary)

message("\n01_load_merge.R complete!")
