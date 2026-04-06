# scripts/03_psm_ipw.R

library(tidyverse)
library(MatchIt)
library(cobalt)
library(survey)
library(here)

here::i_am("scripts/03_psm_ipw.R")

# Load Data
df <- readRDS(here("data", "processed", "criteo_sampled_500k.rds"))
confounder_formula <- as.formula(paste("treatment ~", paste(paste0("f", 0:11), collapse = " + ")))

# Propensity Score Matching (PSM)
set.seed(42)
match_obj <- matchit(confounder_formula, data = df, method = "nearest", distance = "glm", ratio = 1)
matched_data <- match.data(match_obj)

# Fit PSM Model
psm_fit <- lm(visit ~ treatment, data = matched_data, weights = weights)
psm_att <- coef(psm_fit)["treatment1"]

# Save Love Plot
png(here("outputs", "figures", "psm_love_plot.png"), width = 800, height = 600)
love.plot(match_obj, stat = "mean.diffs", threshold = 0.1, abs = TRUE, 
          colors = c("red", "blue"), main = "Covariate Balance: PSM")
dev.off()

# Inverse Probability Weighting (IPW)
ps_model <- glm(confounder_formula, data = df, family = binomial(link = "logit"))
df$ps <- predict(ps_model, type = "response")

# Calculate ATT Weights
df$att_weights <- ifelse(df$treatment == 1, 1, df$ps / (1 - df$ps))

# Fit IPW Model using Survey package
design_ipw <- svydesign(ids = ~1, weights = ~att_weights, data = df)
ipw_fit <- svyglm(visit ~ treatment, design = design_ipw, family = gaussian())
ipw_att <- coef(ipw_fit)["treatment1"]

# Save weights back to processed data for Clustering
saveRDS(df, here("data", "processed", "criteo_sampled_500k_weighted.rds"))
print(paste("PSM ATT:", round(psm_att, 4), "| IPW ATT:", round(ipw_att, 4)))