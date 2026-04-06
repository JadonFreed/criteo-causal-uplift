# scripts/02_eda.R
library(tidyverse)
library(corrplot)
library(overlapping)
library(here)

here::i_am("scripts/02_eda.R")

# Load Processed Data
df <- readRDS(here("data", "processed", "criteo_sampled_500k.rds"))
confounder_names <- c("f0", "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10", "f11")

# Correlation Matrix & Plot
cor_matrix <- cor(df[, confounder_names])

fig_dir <- here("outputs", "figures")
if(!dir.exists(fig_dir)) dir.create(fig_dir, recursive = TRUE)

png(here("outputs", "figures", "correlation_plot.png"), width = 800, height = 800)
corrplot(cor_matrix, method = "color", type = "upper", 
         tl.col = "black", tl.srt = 45, addCoef.col = "black")
dev.off()

# Feature Overlap Analysis
treatment_1 <- df %>% filter(treatment == 1)
treatment_0 <- df %>% filter(treatment == 0)

overlap_scores <- list()
for (feature in confounder_names) {
  list_data <- list(Treatment_0 = treatment_0[[feature]], Treatment_1 = treatment_1[[feature]])
  overlap_result <- overlap(list_data, plot = FALSE)
  overlap_scores[[feature]] <- overlap_result$OV
}

overlap_df <- data.frame(
  Feature = names(overlap_scores),
  Overlap_Percentage = unlist(overlap_scores) * 100
) %>% arrange(Overlap_Percentage)
