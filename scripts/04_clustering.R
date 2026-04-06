# scripts/04_clustering.R

library(tidyverse)
library(survey)
library(here)

here::i_am("scripts/04_clustering.R")

# Load Weighted Data
df <- readRDS(here("data", "processed", "criteo_sampled_500k_weighted.rds"))
confounder_names <- paste0("f", 0:11)
features_for_clustering <- df[, confounder_names]

# K-Means Clustering
set.seed(42)
k <- 4 
clusters <- kmeans(features_for_clustering, centers = k, nstart = 25)
df$cluster <- as.factor(clusters$cluster)

# Cluster-Specific CATT
results_list <- list()

for(c in sort(unique(df$cluster))) {
  sub_df <- df %>% filter(cluster == c)
  
  cluster_design <- svydesign(ids = ~ 1, weights = ~ att_weights, data = sub_df)
  fit_cluster <- svyglm(visit ~ treatment, design = cluster_design, family = gaussian())
  
  est <- coef(fit_cluster)["treatment1"]
  se  <- summary(fit_cluster)$coefficients["treatment1", "Std. Error"]
  ci  <- confint(fit_cluster)["treatment1", ]
  
  results_list[[c]] <- data.frame(
    Cluster = c,
    N_Users = nrow(sub_df),
    Percent_Users = nrow(sub_df) / nrow(df),
    ATT_Estimate = est,
    Standard_Error = se,
    CI_Lower = ci[1],
    CI_Upper = ci[2]
  )
}

final_cluster_table <- bind_rows(results_list)

# Save Final Output
write.csv(final_cluster_table, here("outputs", "cluster_att_results.csv"), row.names = FALSE)
print("Clustering complete. Results saved to outputs/cluster_att_results.csv")