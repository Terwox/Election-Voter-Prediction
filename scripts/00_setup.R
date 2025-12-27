# =============================================================================
# 00_setup.R - Environment Setup
# GSS Explicit Racism & Trump Voting Analysis
# =============================================================================

# Install required packages if not already installed
required_packages <- c(
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
)

# Check and install missing packages
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    message(paste("Installing:", pkg))
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}

invisible(lapply(required_packages, install_if_missing))

# Load all packages
suppressPackageStartupMessages({
  library(haven)
  library(tidyverse)
  library(janitor)
  library(labelled)
  library(ranger)
  library(Boruta)
  library(caret)
  library(pROC)
  library(broom)
  library(gt)
  library(ggplot2)
  library(patchwork)
})

# Set seed for reproducibility
set.seed(42)

# Set working directory to project root
# Adjust this path as needed
project_root <- "c:/Users/terwo/Dropbox/Clutter/Election-Voter-Prediction"
setwd(project_root)

# Define paths
data_raw <- file.path(project_root, "data", "raw")
data_processed <- file.path(project_root, "data", "processed")
output_tables <- file.path(project_root, "output", "tables")
output_figures <- file.path(project_root, "output", "figures")
output_models <- file.path(project_root, "output", "models")

# Create directories if they don't exist
dir.create(data_processed, showWarnings = FALSE, recursive = TRUE)
dir.create(output_tables, showWarnings = FALSE, recursive = TRUE)
dir.create(output_figures, showWarnings = FALSE, recursive = TRUE)
dir.create(output_models, showWarnings = FALSE, recursive = TRUE)

message("Setup complete. Project root: ", project_root)
