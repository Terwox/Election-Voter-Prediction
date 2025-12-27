# =============================================================================
# run_all.R - Master script to run entire analysis pipeline
# GSS Explicit Racism & Trump Voting Analysis
# =============================================================================

message("\n", paste(rep("=", 70), collapse = ""))
message("GSS EXPLICIT RACISM & TRUMP VOTING ANALYSIS")
message("Running full analysis pipeline")
message(paste(rep("=", 70), collapse = ""))
message("\nStarted: ", Sys.time())

# Track timing
start_time <- Sys.time()

# Step 0: Setup (package installation if needed)
message("\n--- Running 00_setup.R ---")
source("scripts/00_setup.R")

# Step 1: Load and merge data
message("\n--- Running 01_load_merge.R ---")
source("scripts/01_load_merge.R")

# Step 2: Derive variables
message("\n--- Running 02_derive_variables.R ---")
source("scripts/02_derive_variables.R")

# Step 3: H1 - Attrition analysis
message("\n--- Running 03_h1_attrition.R ---")
source("scripts/03_h1_attrition.R")

# Step 4: H2 - Explicit vs Symbolic racism
message("\n--- Running 04_h2_racism_comparison.R ---")
source("scripts/04_h2_racism_comparison.R")

# Step 5: RQ1 - Variable importance
message("\n--- Running 05_rq1_variable_importance.R ---")
source("scripts/05_rq1_variable_importance.R")

# Summary
end_time <- Sys.time()
duration <- difftime(end_time, start_time, units = "mins")

message("\n", paste(rep("=", 70), collapse = ""))
message("ANALYSIS COMPLETE")
message(paste(rep("=", 70), collapse = ""))
message("Total runtime: ", round(duration, 1), " minutes")
message("Finished: ", Sys.time())

# List output files
message("\nOutput files created:")
message("\nTables:")
list.files("output/tables", full.names = TRUE) %>% cat(sep = "\n")
message("\nFigures:")
list.files("output/figures", full.names = TRUE) %>% cat(sep = "\n")
message("\nModels:")
list.files("output/models", full.names = TRUE) %>% cat(sep = "\n")
