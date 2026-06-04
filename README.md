[![DOI](https://zenodo.org/badge/1257996976.svg)](https://doi.org/10.5281/zenodo.20534622)

# Replication Package

## Aid, Lending, and TRIPS

This package replicates the empirical analysis for the paper on how US foreign aid and IFC lending shape developing-country TRIPS-plus intellectual property commitments. The analysis measures US trade pressure with DeBERTa stance scores drawn from National Trade Estimate reports. It then estimates how aid (in democracies) and IFC investment (in non-democracies) moderate the effect of that pressure on undisclosed information, patent, and enforcement provisions.

This folder holds the cleaned analysis script, the raw input files, a fully merged analysis extract, a saved R workspace, and the regenerated LaTeX tables.

## Software requirements

- R 4.5.3 or later.
- R packages. `readr`, `readxl`, `ggplot2`, `dplyr`, `tidyverse`, `countrycode`, `WDI`, `fixest`, `marginaleffects`, `desta`, `sampleSelection`, `texreg`.

Install any missing packages with `install.packages()` before running. The `desta` package may need to be installed from its own source if it is not on CRAN for your platform.

## How to run

### Fastest path. Offline fallback with no external sources

Run `reproduce_from_analysis_data.R` from inside this folder. This single script rebuilds every table and figure in the paper from the included `analysis_data.csv` alone. It needs no internet connection, no World Bank API call, no `desta` or `WDI` package, and none of the download-required files listed below. It only needs the `fixest`, `sampleSelection`, `texreg`, `ggplot2`, and `marginaleffects` packages.

The script reads `analysis_data.csv` by bare filename and writes outputs to `tables/` and `figures/` by relative path. The working directory must be whatever folder you downloaded or extracted this package into. The paths below are examples. Replace `/path/to/package` with your own location. Pick one of the two forms below.

From a terminal, run the script directly with `Rscript`. The `cd` sets the working directory to the folder holding the package files.

```bash
cd /path/to/package
Rscript reproduce_from_analysis_data.R
```

From an interactive R or RStudio session, set the working directory first, then source the script.

```r
setwd("/path/to/package")
source("reproduce_from_analysis_data.R")
```

It writes all seven LaTeX tables to `tables/` and all six figures to `figures/`. See the output mappings near the end of this file for which output corresponds to which manuscript exhibit.

### Full pipeline from raw inputs

To rebuild the merged dataset from the raw sources, run the main script instead. Open `nteDeBERTa_RR.Rmd` in RStudio and knit it, or purl it to plain R and source it from this folder.

```r
knitr::purl("nteDeBERTa_RR.Rmd", output = "pkg.R", documentation = 0)
source("pkg.R")
```

Run from inside this folder so the relative file reads resolve. The script reads its raw inputs by bare filename. This path pulls some macro indicators from the World Bank through `WDI`, so it needs an internet connection, and it expects the four download-required sources to be present.

## Internet access and the World Bank API

The script pulls some macro indicators from the World Bank through the `WDI` package. That step needs an internet connection. If you cannot reach the World Bank API, use the provided merged data instead. `analysis_data.csv` and `nteDeBERTa_RR.RData` both contain the fully merged analysis dataset, so you can reproduce every table from them without an outside connection.

## DeBERTa stance scores

The DeBERTa stance scores are precomputed and shipped with this package. They live in the `deberta_score` column of `NTE_IPR_final_v2.csv`. You do not need to rerun the language model to reproduce the results.

## Data manifest

Each included input file sits in the top level of this folder. Four further sources are not shipped here. Three restrict redistribution, and the UN voting file is openly licensed but too large to host. See the Sources not shipped section below. Full provenance, citations, and license terms for every source are in `DATA_SOURCES.md`.

- `NTE_IPR_final_v2.csv`. NTE intellectual property text scores, including the precomputed DeBERTa stance score. USTR National Trade Estimate reports, public domain.
- `special301.csv`. USTR Special 301 watch-list listings, public domain.
- `dots_us.csv`. US bilateral trade flows from IMF Direction of Trade Statistics. Attribution to the IMF is required.
- `us_foreign_aid_country.csv`. US foreign aid disbursements by recipient country. ForeignAssistance.gov, public domain.
- `IFC_invest_svcs.csv`. International Finance Corporation investment service commitments. Released under CC-BY, attribution to the World Bank required.
- `dist_cepii.xls`. CEPII bilateral distance and geography measures. Released under the Etalab Open Licence 2.0, attribution to CEPII required.

The TRIPS-plus dependent variables come from the Morin and Surbeck (2020) coding in the `TRIPSplus.xlsx` workbook, merged onto treaty and dyad structure from DESTA (loaded via the `desta` package). DESTA is obtained by installing the `desta` R package, so no DESTA file is shipped here.

## Sources not shipped (download required)

Four data sources are not shipped in this package. Three restrict redistribution. The UN voting file is openly licensed under CC0 but is too large to host here. To run the script from raw inputs, download each from its source, save it under the filename shown, and place it in this folder. If you prefer not to download them, run `reproduce_from_analysis_data.R`, which rebuilds every table from the included `analysis_data.csv`, or load the saved workspace `nteDeBERTa_RR.RData`, which already holds the fitted models. Full terms are in `DATA_SOURCES.md`.

- `unga_score.csv`. UN General Assembly voting ideal-point data, the dyadic `IdealPointDistance` relative to the US, from Erik Voeten's United Nations General Assembly Voting Data on Harvard Dataverse (CC0). Download from https://doi.org/10.7910/DVN/LEJUQZ and cite Bailey, Strezhnev, and Voeten (2017).
- `TRIPSplus.xlsx`. The TRIPS-plus provision coding that defines the dependent variables, from Morin and Surbeck (2020). Download from the DESTA downloads page at https://www.designoftradeagreements.org/downloads/ and cite Morin and Surbeck (2020).
- `WhoGov_crosssectional_V2.0.csv`. WhoGov cabinet and regime data, used to classify democracies and non-democracies. Download from https://politicscentre.nuffield.ox.ac.uk/whogov-dataset/ and cite Nyrup and Bramwell (2020).
- `isds_cases_us_claim.csv`. Investor-state dispute cases with US claimants. Download from the UNCTAD Investment Dispute Settlement Navigator at https://investmentpolicy.unctad.org/investment-dispute-settlement, filter to US-claimant cases, and cite UNCTAD.

## Generated files

- `analysis_data.csv`. The fully merged analysis dataset written by the script as an open CSV extract.
- `nteDeBERTa_RR.RData`. A saved R workspace holding every fitted object and intermediate frame from a clean run.
- `tables/`. The regenerated LaTeX tables.
- `figures/`. The regenerated figures.

## Output to manuscript table mapping

The script writes its LaTeX tables into the `tables/` subfolder. They map to the manuscript as follows.

- `aid_results_table.tex`. The main results table, the appendix year-fixed-effects-only specification. Columns 1 to 3 are Aid x Democracy for undisclosed information, patents, and enforcement. Columns 4 to 6 are IFC x Non-democracy for the same three outcomes.
- `placebo_table.tex`. The placebo table. Columns 1 to 3 are Aid x Non-democracy. Columns 4 to 6 are IFC x Democracy.
- `heckman_results.tex`. The Heckman selection table.
- `table_aid_dem_yfe.tex`. The appendix identification-robustness table for the Aid x Democracy two-way fixed-effects specification.
- `table_ifc_nondem_yfe.tex`. The appendix identification-robustness table for the IFC x Non-democracy two-way fixed-effects specification.
- `table_aid_dem_mundlak.tex`. The appendix identification-robustness table for the Aid x Democracy Mundlak specification.
- `table_ifc_nondem_mundlak.tex`. The appendix identification-robustness table for the IFC x Non-democracy Mundlak specification.

The two-way fixed-effects and Mundlak tables together form the appendix identification-robustness tables.

## Output to manuscript figure mapping

The reproduction script writes figures into the `figures/` subfolder.

- `fig_marg_aid_undisclosed.png`, `fig_marg_aid_patent.png`, `fig_marg_aid_enforcement.png`. The marginal-effects plots for Aid x Democracy across the three outcomes.
- `fig_marg_ifc_undisclosed.png`, `fig_marg_ifc_patent.png`, `fig_marg_ifc_enforcement.png`. The marginal-effects plots for IFC x Non-democracy across the three outcomes.

The Korea and Japan NTE report images and the cross-validation figures in the manuscript are produced outside this R package and are not regenerated here.
