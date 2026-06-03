# Data Sources and Redistribution Status

This file documents every external data source used in the analysis. For each source it records the producer, the citation, the access location, the license or terms of use, and whether the file ships inside this package or must be downloaded by the replicator.

The author's own contribution is the DeBERTa stance score. Every other variable derives from third-party data, so each source is credited here. Sources that permit redistribution and are of manageable size ship with this package. Four sources are not shipped. Three restrict redistribution, and the UN voting file is openly licensed but too large to host here. For all four, follow the download steps below and place the file in this folder before running the script from raw inputs. The merged dataset `analysis_data.csv` and the saved workspace `nteDeBERTa_RR.RData` reproduce every table without these raw files.

## Summary

| File | Source | License | Status |
|---|---|---|---|
| `NTE_IPR_final_v2.csv` | USTR NTE reports plus author DeBERTa scores | Public domain (17 U.S.C. 105) | Included |
| `special301.csv` | USTR Special 301 Report | Public domain (17 U.S.C. 105) | Included |
| `us_foreign_aid_country.csv` | ForeignAssistance.gov | Public domain, US federal open data | Included |
| `IFC_invest_svcs.csv` | IFC Investment Services Projects | CC-BY | Included, attribution required |
| `unga_score.csv` | UN General Assembly voting ideal points | CC0 1.0 | Download required (large file) |
| `dist_cepii.xls` | CEPII GeoDist | Etalab Open Licence 2.0 | Included, attribution required |
| `dots_us.csv` | IMF Direction of Trade Statistics | IMF Copyright and Usage | Included, attribution required |
| `TRIPSplus.xlsx` | Morin and Surbeck T+PTA dataset, via DESTA downloads | Citation requested, no explicit license | Download required |
| DESTA | DESTA database via the `desta` R package | Citation requested, no explicit license | Obtained through the R package |
| `WhoGov_crosssectional_V2.0.csv` | WhoGov | Redistribution restricted | Download required |
| `isds_cases_us_claim.csv` | UNCTAD ISDS Navigator | Redistribution restricted | Download required |

## Included sources

### NTE_IPR_final_v2.csv
- **Producer.** Office of the United States Trade Representative, National Trade Estimate Report on Foreign Trade Barriers. The `deberta_score` column is the author's own measure derived from the report text.
- **Citation.** Office of the United States Trade Representative, National Trade Estimate Report on Foreign Trade Barriers, annual volumes.
- **Access.** https://ustr.gov/about-us/policy-offices/press-office/reports-and-publications
- **License.** Public domain as a work of the US federal government under 17 U.S.C. 105.
- **Status.** Included. The author's DeBERTa scores are the author's own contribution.

### special301.csv
- **Producer.** Office of the United States Trade Representative, Special 301 Report.
- **Citation.** Office of the United States Trade Representative, Special 301 Report, annual volumes.
- **Access.** https://ustr.gov/issue-areas/intellectual-property/special-301
- **License.** Public domain under 17 U.S.C. 105.
- **Status.** Included.

### us_foreign_aid_country.csv
- **Producer.** ForeignAssistance.gov, a joint effort of the US Agency for International Development and the US Department of State.
- **Citation.** ForeignAssistance.gov, U.S. Foreign Assistance by Country.
- **Access.** https://foreignassistance.gov/data
- **License.** US federal open data, designated Public Domain U.S. Government.
- **Status.** Included.

### IFC_invest_svcs.csv
- **Producer.** International Finance Corporation, World Bank Group, IFC Investment Services Projects.
- **Citation.** International Finance Corporation, IFC Investment Services Projects, World Bank Group.
- **Access.** https://datacatalog.worldbank.org/search/dataset/0037737/ifc-investment-services-projects and https://financesone.worldbank.org/ifc-investment-services-projects/DS00499
- **License.** Creative Commons Attribution. The World Bank Data Catalog page shows CC-BY 3.0 IGO and the Finances portal shows CC-BY 4.0. Both permit redistribution with attribution.
- **Required attribution.** "The World Bank: IFC Investment Services Projects: International Finance Corporation." The script subsets and aggregates the data, so note that the file has been modified from the original.
- **Status.** Included.

### dist_cepii.xls
- **Producer.** CEPII, GeoDist database.
- **Citation.** Mayer, Thierry, and Soledad Zignago. 2011. "Notes on CEPII's distances measures: The GeoDist database." CEPII Working Paper No. 2011-25.
- **Access.** https://www.cepii.fr/cepii/en/bdd_modele/bdd_modele_item.asp?id=6
- **License.** Etalab Open Licence 2.0, which permits redistribution including modification, with attribution.
- **Required attribution.** Credit CEPII as the source of the GeoDist database and cite Mayer and Zignago (2011).
- **Status.** Included.

### dots_us.csv
- **Producer.** International Monetary Fund, Direction of Trade Statistics.
- **Citation.** International Monetary Fund, Direction of Trade Statistics (DOTS).
- **Access.** https://data.imf.org
- **License.** IMF Copyright and Usage terms, which permit downloading, copying, creating derivative works, publishing, and distributing IMF data with attribution and without altering its accuracy. https://www.imf.org/en/about/copyright-and-terms
- **Required attribution.** "Source: International Monetary Fund, Direction of Trade Statistics (DOTS), https://data.imf.org"
- **Status.** Included. The verbatim IMF clause was confirmed through multiple independent sources. A direct fetch of the live IMF page returned a server block, so confirm the live text before final upload if you want full certainty.

### DESTA
- **Producer.** Andreas Dur, Leonardo Baccini, and Manfred Elsig, Design of Trade Agreements database, World Trade Institute, University of Bern. The analysis obtains DESTA through the `desta` R package, so no DESTA file is shipped in this package.
- **Citation.** Dur, Andreas, Leonardo Baccini, and Manfred Elsig. 2014. "The design of international trade agreements: Introducing a new dataset." The Review of International Organizations 9(3), 353-375. DOI 10.1007/s11558-013-9179-8.
- **Access.** https://www.designoftradeagreements.org/downloads/ and the `desta` R package.
- **License.** The project requests citation and states no explicit redistribution license. The replicator obtains the data by installing the R package, so this package does not re-host DESTA data.
- **Status.** Obtained through the R package.

## Download-required sources

These four sources are not shipped in this package. Three restrict redistribution. The UN voting file is openly licensed under CC0 but is too large to host here. Download each from the source, save it under the exact filename below in this folder, and then the script will run from raw inputs. If you prefer not to download them, use `reproduce_from_analysis_data.R`, which rebuilds every table from the included `analysis_data.csv`, or `nteDeBERTa_RR.RData`, which already holds the fitted models.

### unga_score.csv
- **Producer.** Erik Voeten, with Anton Strezhnev and Michael Bailey, United Nations General Assembly voting data. The script uses the dyadic `IdealPointDistance` variable relative to the United States.
- **Citation.** Bailey, Michael A., Anton Strezhnev, and Erik Voeten. 2017. "Estimating Dynamic State Preferences from United Nations Voting Data." Journal of Conflict Resolution 61(2), 430-456. DOI 10.1177/0022002715595700. The manuscript cites the measure through Bailey and Voeten (2018), Public Choice 176(1), 33-55.
- **Access.** https://doi.org/10.7910/DVN/LEJUQZ (Harvard Dataverse).
- **License.** CC0 1.0 public-domain dedication. The file is openly redistributable and is excluded here only because of its size.
- **Status.** Download required. Save as `unga_score.csv`.

### TRIPSplus.xlsx
- **Producer.** Jean-Frederic Morin and Jenny Surbeck, TRIPs-plus PTA dataset. This file defines the paper's TRIPS-plus dependent variables.
- **Citation.** Morin, Jean-Frederic, and Jenny Surbeck. 2020. "Mapping the New Frontier of International IP Law: Introducing a TRIPs-plus Dataset." World Trade Review 19(1), 109-122. DOI 10.1017/S1474745618000460.
- **Access.** Downloaded from the DESTA downloads page at https://www.designoftradeagreements.org/downloads/, which distributes the TRIPS-plus add-on coding. The dataset is also available from the authors' page at https://www.chaire-epi.ulaval.ca/en/data/intellectual-property-index.
- **Terms.** The dataset carries a citation request and no explicit redistribution license, so it is not re-hosted here.
- **Status.** Download required. Save as `TRIPSplus.xlsx`.

### WhoGov_crosssectional_V2.0.csv
- **Producer.** Jacob Nyrup and Stuart Bramwell, WhoGov dataset, Nuffield Politics Research Centre, University of Oxford. Used to classify democracies and non-democracies.
- **Citation.** Nyrup, Jacob, and Stuart Bramwell. 2020. "Who Governs? A New Global Dataset on Members of Cabinets." American Political Science Review 114(4), 1366-1374. DOI 10.1017/S0003055420000490.
- **Access.** https://politicscentre.nuffield.ox.ac.uk/whogov-dataset/ (registration form). APSR replication deposit at https://doi.org/10.7910/DVN/YTRCQE.
- **Terms.** The Harvard Dataverse deposit states that the dataset is not to be distributed or posted outside the Harvard Dataverse. The website gates access behind a registration form and grants no open redistribution license.
- **Status.** Download required. Save as `WhoGov_crosssectional_V2.0.csv`.

### isds_cases_us_claim.csv
- **Producer.** UNCTAD Investment Dispute Settlement Navigator, Investment Policy Hub. Used to count investor-state disputes with US claimants.
- **Citation.** UNCTAD, Investment Dispute Settlement Navigator.
- **Access.** https://investmentpolicy.unctad.org/investment-dispute-settlement
- **Terms.** The UN terms of use grant only personal, non-commercial download "without any right to resell or redistribute them or to compile or create derivative works therefrom." https://investmentpolicy.unctad.org/pages/1048/terms-and-conditions-of-use
- **Status.** Download required. Filter to US-claimant cases and save as `isds_cases_us_claim.csv`.
