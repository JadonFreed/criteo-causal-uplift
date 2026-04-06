# Estimating the Causal Effect of Digital Advertising on User Visit Probability

### A Causal Inference and Heterogeneous Treatment Effect (HTE) Pipeline
**Author:** Jadon Freed | **Date:** November 2025 | **Institution:** University of Pittsburgh

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue)](https://www.linkedin.com/in/jadonfreed/)
[![R](https://img.shields.io/badge/R-276DC3?style=flat&logo=R&logoColor=white)](https://www.r-project.org/)
[![Kaggle](https://img.shields.io/badge/Data-Kaggle-20BEFF.svg?style=flat&logo=kaggle&logoColor=white)](https://www.kaggle.com/datasets/arashnic/uplift-modeling)

## Overview
This repository contains a complete reproducible data science pipeline designed to measure the true Return on Investment (ROI) of digital advertising. In 2024, digital advertising spend reached $740 billion, yet measuring the true causal impact of an ad campaign is notoriously difficult due to **selection bias** (i.e., advertisers intentionally targeting users who are already highly likely to purchase). 

This project analyzes the **Criteo Uplift Dataset** (comprising millions of user interactions) to move beyond naive correlation. By utilizing advanced causal inference techniques, the pipeline isolates the global Average Treatment Effect on the Treated (ATT) and utilizes unsupervised machine learning to identify high-value user subpopulations, optimizing future marketing budget allocation.

---

## Repository Structure

The codebase is organized into a modular `01` through `04` execution pipeline, isolating data preparation from causal mathematical operations and final reporting.

### The Core Analytical Pipeline
* **`01_data_prep.R`**: Ingests the raw 13M-row Criteo dataset, applies systematic downsampling for local computation, formats treatment/control variables, and stages the processed data.
* **`02_eda.R`**: Conducts baseline confounder evaluation. Generates correlation matrices and calculates strict feature overlap percentages between treated and control groups to ensure the positivity assumption is met.
* **`03_psm_ipw.R`**: The core causal engine. Implements **Propensity Score Matching (PSM)** using the `MatchIt` package (Nearest Neighbor, GLM distance) and **Inverse Probability Weighting (IPW)** using the `survey` package to estimate the global ATT. Outputs covariate balance diagnostics (Love Plots).
* **`04_clustering.R`**: Evaluates Heterogeneous Treatment Effects (HTE). Applies **K-Means Clustering** to baseline user covariates, then fits cluster-specific weighted regression models to calculate the Conditional Average Treatment Effect on the Treated (CATT).

### Reporting and Visuals
* **`Causal_Analysis_Report.Rmd`**: The executive whitepaper. It weaves together the methodology, the generated figures, and the final cluster tables into a cohesive, interactive HTML report tailored for business stakeholders.
* **`Causal Inference Final Project Presentation.pptx`**: The conceptual graphics and final slide deck summarizing the business recommendations.

---

## Methodological Highlight: Heterogeneity & Budget Optimization

While the global causal estimators (PSM and IPW) proved that advertising has a statistically significant effect on website visits, the magnitude was globally small (<1%). This pipeline utilizes unsupervised learning to prove that **ad spend is highly inefficient**. The clustering algorithm reveals that **~52% of users are entirely unresponsive** to ad targeting (zero causal effect), while a concentrated **~5% subpopulation exhibits a causal response 5x greater** than the global average. 

---

## How to Run

1.  **Environment Setup**: Ensure R is installed along with the `tidyverse`, `MatchIt`, `cobalt`, and `survey` packages. The `here` package is required for path resolution.
2.  **Data Provisioning**: Due to GitHub's 100MB file limit, the raw dataset is ignored via `.gitignore`. Download the *Criteo Uplift Dataset* from Kaggle and place `criteo_uplift-v2_1.csv` in the `data/raw/` directory.
3.  **Execution Pipeline**: Run the `.R` scripts sequentially from `01` to `04` located in the `scripts/` folder.
4.  **Note on Sampling**: `01_data_prep.R` downsamples the dataset to 500k rows. Due to the high class imbalance (85% Treated / 15% Control), 1:1 PSM will naturally drop unmatched treated units. For full-population replication, bypass the sampling step on a high-RAM machine.

---

## Pipeline Architecture

The pipeline is modularized into 5 sequential phases, moving from raw observational data to validated business insights.

```mermaid
%%{init: {'theme': 'base'}}%%
flowchart TB
    subgraph Phase1 ["Phase 1: Data Provisioning"]
        direction LR
        A["Raw Criteo Observational Data (13M)"] --> B["Systematic Downsampling"]
        B --> C("<b>Processed Feature Matrix</b>")
    end
    
    subgraph Phase2 ["Phase 2: Confounder Evaluation (EDA)"]
        direction TB
        D["Feature Correlation Analysis"] --> E["Distribution Overlap Scoring"]
        E --> F{"Positivity Assumption Met?"}
    end
    
    subgraph Phase3 ["Phase 3: Global Causal Estimation"]
        direction LR
        subgraph Phase3A ["Propensity Score Matching"]
            direction TB
            G["1:1 Nearest Neighbor Match"] --> H("<b>PSM ATT Estimate</b>")
        end
        subgraph Phase3B ["Inverse Probability Weighting"]
            direction TB
            I["Propensity Score Calculation"] --> J["Survey-Weighted Regression"]
            J --> K("<b>IPW ATT Estimate</b>")
        end
    end
    
    subgraph Phase4 ["Phase 4: Heterogeneity Analysis"]
        direction TB
        L["K-Means Covariate Clustering"] --> M["Cluster-Specific IPW Regression"]
        M --> N("<b>CATT Estimates (by Segment)</b>")
    end
    
    subgraph Phase5 ["Phase 5: Strategic Optimization"]
        direction LR
        O["Identify High-Value Responders"] --> P["Reallocate Inefficient Ad Spend"]
        P --> Q("<b>Optimized Marketing ROI</b>")
    end
    
    C ===> Phase2
    F -- "Yes" --> Phase3
    Phase3 ===> Phase4
    Phase4 ===> Phase5
    
    style Phase1 fill:#f8f9fa,stroke:#343a40,stroke-width:2px,color:#212529
    style Phase2 fill:#e9ecef,stroke:#495057,stroke-width:2px,color:#212529
    style Phase3 fill:#d1e7dd,stroke:#0f5132,stroke-width:2px,color:#0f5132
    style Phase4 fill:#fff3cd,stroke:#856404,stroke-width:2px,color:#856404
    style Phase3A fill:none,stroke:none
    style Phase3B fill:none,stroke:none
    style Phase5 fill:#cfe2ff,stroke:#084298,stroke-width:2px,color:#084298
