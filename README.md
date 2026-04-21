# Predictors of Antibiotic Prescribing: An Analysis of Deprivation and Ethnicity Across Integrated Care Boards in England
 
**MSc Epidemiology Summer Project**  
London School of Hygiene & Tropical Medicine (LSHTM)  
LSHTM Ethics Approval: Pending  
Study period: 2016–2023 | Analysis period: June–August 2026
 
---
 
## Overview
 
This repository contains all analysis code for a retrospective ecological study examining whether area-level deprivation and ethnic composition are independently associated with antibiotic prescribing rates across Integrated Care Boards (ICBs) in England from 2016 to 2023, and whether ethnicity modifies the association between deprivation and prescribing.
 
The primary exposure is ICB-level deprivation, measured by Index of Multiple Deprivation (IMD) quintile. Ethnicity is operationalised as two continuous proxies: proportion non-white and proportion Asian or Asian British (2021 ONS Census). The primary outcome is the count of antibiotic prescription items per 1,000 population, modelled using Poisson or negative binomial regression with a log-population offset. Secondary analyses examine class-specific prescribing for penicillins, tetracyclines, quinolones, and cephalosporins.
 
All analysis is conducted in R (≥ 4.3.0) and is fully reproducible from the raw data files via the scripts in this repository.
 
---
 
## Repository Structure
 
```
├── data/
│   ├── raw/                  # Raw downloads — not committed (see Data Access)
│   ├── processed/            # Cleaned and linked analytical datasets
│
├── scripts/
│
├── outputs/
│
└── README.md
```
 
---
 
## Data Sources
 
All data are publicly available secondary data. Raw data files are **not committed to this repository** due to file size. Download instructions are provided below.
 
| Dataset | Source | Access |
|---|---|---|
| Antibiotic prescribing counts (primary care, by ICB, year, month, BNF chemical substance, sex, 5-year age band) | NHSBSA Open Data Portal — [FOI-01671](https://opendata.nhsbsa.net/dataset/foi-01671) and [FOI-01975](https://opendata.nhsbsa.net/dataset/foi-01975) | Open Government Licence v3.0 — free public download |
| Population denominators | ONS Mid-Year Population Estimates (2016–2023) | [ONS website](https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates) — free public download |
| Area-level deprivation | English Indices of Multiple Deprivation (IMD) — LSOA-level scores aggregated to ICB using population-weighted averages | [MHCLG / DLUHC](https://www.gov.uk/government/statistics/english-indices-of-deprivation-2019) — free public download |
| Ethnicity | 2021 ONS Census — proportion non-white and proportion Asian or Asian British at ICB-level | [ONS Census 2021](https://www.ons.gov.uk/census) — free public download |
 
Place downloaded raw files into `data/raw/` before running any scripts. The `01_data_cleaning.R` script assumes file names as downloaded from the respective portals; see inline comments for any required renaming.
 
---
 
## Study Design
 
| Parameter | Detail |
|---|---|
| Study design | Retrospective ecological study |
| Unit of analysis | ICB (n = 42 ICBs in England) |
| Study period | January 2016 – December 2023 |
| Temporal aggregation | Annual (monthly data explored descriptively) |
| Primary outcome | Count of antibiotic prescription items (Poisson/NB offset model → rate ratio per 1,000 population) |
| Secondary outcomes | Class-specific counts: penicillins, tetracyclines, quinolones, cephalosporins |
| Primary exposure | IMD quintile (ICB-level, quintiles derived by ranking ICBs) |
| Effect modifier / covariate | Proportion non-white; proportion Asian or Asian British (2021 Census) |
| Covariates | Age (5-year bands), sex (male/female), calendar year |
| Regression model | Poisson with log-population offset; negative binomial if overdispersion confirmed |
| Software | R ≥ 4.3.0, RStudio, renv for package management |
 
---
 
## Analysis Plan
 
### 1. Data Management
 
- Restrict prescribing data to January 2016 – December 2023 (complete calendar years only)
- Aggregate monthly counts to annual totals for regression; retain monthly data for descriptive time series
- Harmonise age bands: ONS population data (single years) grouped to 5-year bands to match prescribing data; ages 86+ collapsed into a single stratum (86–89 from single-year estimates + 90+ aggregate category from ONS)
- Exclude sex categories 'Not Known' and 'Indeterminate' from regression due to low counts (discussed as a limitation)
- Censored small counts (1–4) set to 2 for main analysis; sensitivity analysis evaluates alternative imputation values
- Validate linkage by cross-referencing 2021 Census population totals against 2021 ONS mid-year estimates at national level
### 2. Descriptive Analysis
 
- Crude prescribing rates per 1,000 population: national trends 2016–2023, stratified by age band, sex, ICB
- Choropleth maps of ICB-level prescribing rates and IMD quintile
- Boxplots of prescribing rate by IMD quintile and by year
- Descriptive summary of ethnic composition across ICBs
- Spearman rank correlation between ICB-level IMD score and ethnicity proxies (to characterise collinearity prior to regression)
- Exploratory spatial autocorrelation (global Moran's I) if choropleth maps suggest non-random spatial clustering
### 3. Regression Models
 
Sequential Poisson regression models (negative binomial if overdispersion confirmed via likelihood ratio test comparing Poisson and NB models):
 
| Model | Specification |
|---|---|
| M1 | `count ~ IMD_quintile + year + offset(log(population))` |
| M2 | `count ~ IMD_quintile + age_band + sex + year + offset(log(population))` |
| M3 | `count ~ IMD_quintile + age_band + sex + prop_nonwhite + year + offset(log(population))` |
| M3b | `count ~ IMD_quintile + age_band + sex + prop_asian + year + offset(log(population))` |
| M4 | `count ~ IMD_quintile * prop_nonwhite + age_band + sex + year + offset(log(population))` |
| M4b | `count ~ IMD_quintile * prop_asian + age_band + sex + year + offset(log(population))` |
 
Results reported as rate ratios (RR) with 95% confidence intervals. Model comparison via likelihood ratio tests.
 
### 4. Secondary Analyses
 
Models M1–M4 repeated separately for:
- Penicillins
- Tetracyclines
- Quinolones
- Cephalosporins
### 5. Sensitivity Analysis
 
Repeat main analyses substituting alternative values (1, 3, 4) for censored small counts to assess robustness of findings to the imputation value chosen for main analysis (2).
 
---
 
## Ethical Approval
 
This project uses exclusively anonymised, aggregated secondary data from publicly available sources. No individual-level data are used. Ethics being reviewed by the LSHTM Ethics Committee. Data are stored securely on LSHTM OneDrive and will be deleted upon project completion.
 
Ecological inference is limited to the ICB-level. No individual-level causal inferences are drawn. Results pertaining to ethnic composition are interpreted as area-level associations only.
 
---
 
## Limitations
 
- Ecological study design: associations are estimated at the ICB level and are subject to the ecological fallacy; individual-level confounding cannot be excluded
- Ethnicity is measured from the 2021 Census only and is assumed static across the 2016–2023 study period
- IMD quintiles derived from the 2019 IMD; deprivation trajectories within ICBs over the study period are not captured
- Sex is restricted to male and female; non-binary and unknown categories excluded due to low and potentially unreliable counts
- Small count censoring (1–4) introduces imprecision in class-specific analyses with low prescribing volume
- ICBs were formally established in July 2022; historical data mapped retrospectively to current ICB boundaries
---
 
## Licence
 
Code in this repository is released under the [MIT Licence](LICENSE). Data are not redistributed; see individual source licences (Open Government Licence v3.0 for NHSBSA and ONS data).