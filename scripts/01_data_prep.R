# scripts/01_data_prep.R
library(tidyverse)
library(here)

setwd("~/R_Working_Directory/grad_fall_work/BIOST_2168/Final_Project/criteo-causal-uplift")

# Define script location for the 'here' package
here::i_am("scripts/01_data_prep.R")

# Load Raw Data
data <- read.csv(here("data", "raw", "criteo_uplift-v2_1.csv"))

# Sample Data for Computation Speed
set.seed(42)
df <- data[sample(nrow(data), 500000), ]

# Format Variables
df$treatment <- as.factor(df$treatment)
df$treatment_num <- as.numeric(as.character(df$treatment))
df$visit <- as.numeric(as.character(df$visit))

# Save the processed dataset
out_dir <- here("data", "processed")
if(!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

saveRDS(df, here("data", "processed", "criteo_sampled_500k.rds"))