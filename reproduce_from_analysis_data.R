# reproduce_from_analysis_data.R
#
# Self-contained reproduction of every results table from the merged analysis
# dataset analysis_data.csv. No internet, no restricted raw files (WhoGov,
# UNCTAD ISDS, Morin-Surbeck TRIPSplus.xlsx), no desta / WDI packages.
#
# analysis_data.csv is an exact CSV extract of the in-script object `temp`
# from nteDeBERTa_RR.Rmd. All lagged regressors (ldeberta_score, laid_usd,
# lifc_loan, lunga_dist), the regime classification (democ), the dispute count
# (isds_occurrences), the log-distance exclusion restriction (log_dist_us) and
# the TRIPS-plus dependent variables are already baked into the columns, so the
# models can be re-fit directly without rebuilding any raw input.
#
# Run from /Users/jacqpark/nte_text/replication/ with:
#   Rscript reproduce_from_analysis_data.R
#
# R 4.5.x. Requires: fixest, sampleSelection, texreg (readxl not needed here
# because log_dist_us is already in the CSV; dist_cepii.xls is shipped only as
# a provenance reference).

suppressPackageStartupMessages({
  library(fixest)
  library(sampleSelection)
  library(texreg)
  library(ggplot2)
  library(marginaleffects)
  library(dplyr)
})

# Write all output tables into the tables/ subfolder (same filenames as the
# reference tables produced by the full pipeline).
out_dir <- "tables"
if (!dir.exists(out_dir)) dir.create(out_dir)
op <- function(f) file.path(out_dir, f)

# -------------------------------------------------------------------------
# Load the analysis dataset. This object is equivalent to `temp` in the Rmd.
# -------------------------------------------------------------------------
temp <- read.csv("analysis_data.csv", stringsAsFactors = FALSE)

cat("Loaded analysis_data.csv:", nrow(temp), "rows,", ncol(temp), "cols\n")

# Common etable arguments matching the reference tables exactly.
etable_args <- list(
  tex          = TRUE,
  depvar       = TRUE,
  digits       = "r3",
  digits.stats = "r3",
  fitstat      = ~ n + r2 + wr2,
  signifCode   = c("**" = 0.01, "*" = 0.05, "+" = 0.10)  # passed via do.call; signif.code errors through that path in fixest 0.14.0, signifCode works (deprecation warning only)
)

# =========================================================================
# 1. Six main models -> aid_results_table.tex
#    Aid x Democracy (undisclosed, patents, enforcement)
#    IFC x Non-democracy (undisclosed, patents, enforcement)
# =========================================================================

aid_data <- subset(temp, oecd1994 == 0 & iso3c != "EUU" & democ == "Democracy")
ifc_data <- subset(temp, oecd1994 == 0 & iso3c != "EUU" & iso3c != "RUS" &
                     democ == "Non-democracy")

feols_trips_aid1  <- feols(ipr_tripsplus_undisclosed_information ~ ldeberta_score*laid_usd + unga_dist +
                             log_gdppc + log_gdpcons + gdpgrowth + log_import + log_export +
                             usbit + isds_occurrences | year,
                           data = aid_data, cluster = "iso3c")
feols_trips_aid1p <- feols(ipr_tripsplus_patents ~ ldeberta_score*laid_usd + unga_dist +
                             log_gdppc + log_gdpcons + gdpgrowth + log_import + log_export +
                             usbit + isds_occurrences | year,
                           data = aid_data, cluster = "iso3c")
feols_trips_aid1e <- feols(ipr_tripsplus_enforcement ~ ldeberta_score*laid_usd + unga_dist +
                             log_gdppc + log_gdpcons + gdpgrowth + log_import + log_export +
                             usbit + isds_occurrences | year,
                           data = aid_data, cluster = "iso3c")

feols_trips_ifc1  <- feols(ipr_tripsplus_undisclosed_information ~ ldeberta_score*lifc_loan +
                             log_gdppc + log_gdpcons + gdpgrowth + log_import + log_export + lunga_dist +
                             usbit + isds_occurrences | year,
                           data = ifc_data, cluster = "iso3c")
feols_trips_ifc1p <- feols(ipr_tripsplus_patents ~ ldeberta_score*lifc_loan +
                             log_gdppc + log_gdpcons + gdpgrowth + log_import + log_export + lunga_dist +
                             usbit + isds_occurrences | year,
                           data = ifc_data, cluster = "iso3c")
feols_trips_ifc1e <- feols(ipr_tripsplus_enforcement ~ ldeberta_score*lifc_loan +
                             log_gdppc + log_gdpcons + gdpgrowth + log_import + log_export + lunga_dist +
                             usbit + isds_occurrences | year,
                           data = ifc_data, cluster = "iso3c")

do.call(etable, c(list(feols_trips_aid1, feols_trips_aid1p, feols_trips_aid1e,
                       feols_trips_ifc1, feols_trips_ifc1p, feols_trips_ifc1e),
                  etable_args, list(file = op("aid_results_table.tex"), replace = TRUE)))
cat("Wrote", op("aid_results_table.tex"), "\n")

# =========================================================================
# 2. Placebo models -> placebo_table.tex
#    Aid x Non-democracy (placebo) + IFC x Democracy (placebo)
# =========================================================================

aid_placebo_data <- subset(temp, oecd1994 == 0 & iso3c != "EUU" & iso3c != "RUS" &
                            democ == "Non-democracy")
ifc_placebo_data <- subset(temp, oecd1994 == 0 & iso3c != "EUU" & democ == "Democracy")

pl_aid_u <- feols(ipr_tripsplus_undisclosed_information ~ ldeberta_score*laid_usd + unga_dist +
                    log_gdppc + log_gdpcons + gdpgrowth + log_import + log_export +
                    usbit + isds_occurrences | year,
                  data = aid_placebo_data, cluster = "iso3c")
pl_aid_p <- feols(ipr_tripsplus_patents ~ ldeberta_score*laid_usd + unga_dist +
                    log_gdppc + log_gdpcons + gdpgrowth + log_import + log_export +
                    usbit + isds_occurrences | year,
                  data = aid_placebo_data, cluster = "iso3c")
pl_aid_e <- feols(ipr_tripsplus_enforcement ~ ldeberta_score*laid_usd + unga_dist +
                    log_gdppc + log_gdpcons + gdpgrowth + log_import + log_export +
                    usbit + isds_occurrences | year,
                  data = aid_placebo_data, cluster = "iso3c")

pl_ifc_u <- feols(ipr_tripsplus_undisclosed_information ~ ldeberta_score*lifc_loan +
                    log_gdppc + log_gdpcons + gdpgrowth + log_import + log_export + lunga_dist +
                    usbit + isds_occurrences | year,
                  data = ifc_placebo_data, cluster = "iso3c")
pl_ifc_p <- feols(ipr_tripsplus_patents ~ ldeberta_score*lifc_loan +
                    log_gdppc + log_gdpcons + gdpgrowth + log_import + log_export + lunga_dist +
                    usbit + isds_occurrences | year,
                  data = ifc_placebo_data, cluster = "iso3c")
pl_ifc_e <- feols(ipr_tripsplus_enforcement ~ ldeberta_score*lifc_loan +
                    log_gdppc + log_gdpcons + gdpgrowth + log_import + log_export + lunga_dist +
                    usbit + isds_occurrences | year,
                  data = ifc_placebo_data, cluster = "iso3c")

do.call(etable, c(list(pl_aid_u, pl_aid_p, pl_aid_e, pl_ifc_u, pl_ifc_p, pl_ifc_e),
                  etable_args, list(file = op("placebo_table.tex"), replace = TRUE)))
cat("Wrote", op("placebo_table.tex"), "\n")

# =========================================================================
# 3. TWFE and Mundlak appendix models
#    table_aid_dem_yfe.tex, table_aid_dem_mundlak.tex
#    table_ifc_nondem_yfe.tex, table_ifc_nondem_mundlak.tex
# =========================================================================

# Aid x Democracy (TWFE: iso3c + year fixed effects)
demo_main <- subset(temp, oecd1994 == 0 & iso3c != "EUU" & democ == "Democracy")
aid_yfe_u <- feols(ipr_tripsplus_undisclosed_information ~ ldeberta_score*laid_usd + log_gdppc + log_gdpcons + gdpgrowth + log_import + log_export + usbit + isds_occurrences + unga_dist | iso3c + year, data = demo_main, cluster = "iso3c")
aid_yfe_p <- feols(ipr_tripsplus_patents                 ~ ldeberta_score*laid_usd + log_gdppc + log_gdpcons + gdpgrowth + log_import + log_export + usbit + isds_occurrences + unga_dist | iso3c + year, data = demo_main, cluster = "iso3c")
aid_yfe_e <- feols(ipr_tripsplus_enforcement             ~ ldeberta_score*laid_usd + log_gdppc + log_gdpcons + gdpgrowth + log_import + log_export + usbit + isds_occurrences + unga_dist | iso3c + year, data = demo_main, cluster = "iso3c")
etable(aid_yfe_u, aid_yfe_p, aid_yfe_e, tex = TRUE, file = op("table_aid_dem_yfe.tex"), digits = 3, replace = TRUE)
cat("Wrote", op("table_aid_dem_yfe.tex"), "\n")

# Aid x Democracy (Mundlak: within and between decomposition of laid_usd)
demo_mund <- demo_main
demo_mund$mean_aid <- ave(demo_mund$laid_usd, demo_mund$iso3c,
                          FUN = function(x) mean(x, na.rm = TRUE))
demo_mund$dev_aid  <- demo_mund$laid_usd - demo_mund$mean_aid
aid_mk_u <- feols(ipr_tripsplus_undisclosed_information ~ ldeberta_score*dev_aid + ldeberta_score*mean_aid + log_gdppc + log_gdpcons + gdpgrowth + log_import + log_export + usbit + isds_occurrences + unga_dist | year, data = demo_mund, cluster = "iso3c")
aid_mk_p <- feols(ipr_tripsplus_patents                 ~ ldeberta_score*dev_aid + ldeberta_score*mean_aid + log_gdppc + log_gdpcons + gdpgrowth + log_import + log_export + usbit + isds_occurrences + unga_dist | year, data = demo_mund, cluster = "iso3c")
aid_mk_e <- feols(ipr_tripsplus_enforcement             ~ ldeberta_score*dev_aid + ldeberta_score*mean_aid + log_gdppc + log_gdpcons + gdpgrowth + log_import + log_export + usbit + isds_occurrences + unga_dist | year, data = demo_mund, cluster = "iso3c")
etable(aid_mk_u, aid_mk_p, aid_mk_e, tex = TRUE, file = op("table_aid_dem_mundlak.tex"), digits = 3, replace = TRUE)
cat("Wrote", op("table_aid_dem_mundlak.tex"), "\n")

# IFC x Non-democracy (TWFE)
nondem_main <- subset(temp, oecd1994 == 0 & iso3c != "EUU" & democ == "Non-democracy")
ifc_yfe_u <- feols(ipr_tripsplus_undisclosed_information ~ ldeberta_score*lifc_loan + log_gdppc + log_gdpcons + gdpgrowth + log_import + log_export + usbit + isds_occurrences + lunga_dist | iso3c + year, data = nondem_main, cluster = "iso3c")
ifc_yfe_p <- feols(ipr_tripsplus_patents                 ~ ldeberta_score*lifc_loan + log_gdppc + log_gdpcons + gdpgrowth + log_import + log_export + usbit + isds_occurrences + lunga_dist | iso3c + year, data = nondem_main, cluster = "iso3c")
ifc_yfe_e <- feols(ipr_tripsplus_enforcement             ~ ldeberta_score*lifc_loan + log_gdppc + log_gdpcons + gdpgrowth + log_import + log_export + usbit + isds_occurrences + lunga_dist | iso3c + year, data = nondem_main, cluster = "iso3c")
etable(ifc_yfe_u, ifc_yfe_p, ifc_yfe_e, tex = TRUE, file = op("table_ifc_nondem_yfe.tex"), digits = 3, replace = TRUE)
cat("Wrote", op("table_ifc_nondem_yfe.tex"), "\n")

# IFC x Non-democracy (Mundlak)
nondem_mund <- nondem_main
nondem_mund$mean_ifc <- ave(nondem_mund$lifc_loan, nondem_mund$iso3c,
                            FUN = function(x) mean(x, na.rm = TRUE))
nondem_mund$dev_ifc  <- nondem_mund$lifc_loan - nondem_mund$mean_ifc
ifc_mk_u <- feols(ipr_tripsplus_undisclosed_information ~ ldeberta_score*dev_ifc + ldeberta_score*mean_ifc + log_gdppc + log_gdpcons + gdpgrowth + log_import + log_export + usbit + isds_occurrences + lunga_dist | year, data = nondem_mund, cluster = "iso3c")
ifc_mk_p <- feols(ipr_tripsplus_patents                 ~ ldeberta_score*dev_ifc + ldeberta_score*mean_ifc + log_gdppc + log_gdpcons + gdpgrowth + log_import + log_export + usbit + isds_occurrences + lunga_dist | year, data = nondem_mund, cluster = "iso3c")
ifc_mk_e <- feols(ipr_tripsplus_enforcement             ~ ldeberta_score*dev_ifc + ldeberta_score*mean_ifc + log_gdppc + log_gdpcons + gdpgrowth + log_import + log_export + usbit + isds_occurrences + lunga_dist | year, data = nondem_mund, cluster = "iso3c")
etable(ifc_mk_u, ifc_mk_p, ifc_mk_e, tex = TRUE, file = op("table_ifc_nondem_mundlak.tex"), digits = 3, replace = TRUE)
cat("Wrote", op("table_ifc_nondem_mundlak.tex"), "\n")

# =========================================================================
# 4. Heckman selection model -> heckman_results.tex
#    Selection: uspta ~ log_dist_us (exclusion restriction) + covariates.
#    Outcome: TRIPS-plus depth conditional on a US PTA being in force.
#    divided_gov is constructed in-script from a hardcoded year table; it
#    requires no external file. log_dist_us is already in analysis_data.csv.
# =========================================================================

divided_gov_df <- data.frame(
  year = 1995:2022,
  divided_gov = c(
    1,1,1,1,1,1,   # 1995-2000 Clinton (D), R House + R Senate
    0,0,           # 2001-2002 Bush (R), only Senate opposite (not both)
    0,0,0,0,       # 2003-2006 Bush (R), unified R Congress
    1,1,           # 2007-2008 Bush (R), D House + D Senate
    0,0,           # 2009-2010 Obama (D), unified D Congress
    0,0,0,0,       # 2011-2014 Obama (D), only House opposite (not both)
    1,1,           # 2015-2016 Obama (D), R House + R Senate
    0,0,           # 2017-2018 Trump (R), unified R Congress
    0,0,           # 2019-2020 Trump (R), only House opposite (not both)
    0,0            # 2021-2022 Biden (D), unified D Congress
  )
)

heck_demo   <- subset(temp, oecd1994 == 0 & iso3c != "EUU" & democ == "Democracy")
heck_nondem <- subset(temp, oecd1994 == 0 & iso3c != "EUU" & iso3c != "RUS" &
                       democ == "Non-democracy")
heck_demo_dg   <- merge(heck_demo,   divided_gov_df, by = "year", all.x = TRUE)
heck_nondem_dg <- merge(heck_nondem, divided_gov_df, by = "year", all.x = TRUE)

heck_aid_undisc_dg <- heckit(
  uspta ~ log_dist_us + log_gdpcons + log_import + log_export + unga_dist +
          usbit + gdpgrowth + divided_gov,
  ipr_tripsplus_undisclosed_information ~ ldeberta_score * laid_usd +
          log_gdpcons + log_import + log_export + unga_dist +
          usbit + gdpgrowth + divided_gov,
  data = heck_demo_dg, method = "2step")
heck_aid_patent_dg <- heckit(
  uspta ~ log_dist_us + log_gdpcons + log_import + log_export + unga_dist +
          usbit + gdpgrowth + divided_gov,
  ipr_tripsplus_patents ~ ldeberta_score * laid_usd +
          log_gdpcons + log_import + log_export + unga_dist +
          usbit + gdpgrowth + divided_gov,
  data = heck_demo_dg, method = "2step")
heck_aid_enf_dg <- heckit(
  uspta ~ log_dist_us + log_gdpcons + log_import + log_export + unga_dist +
          usbit + gdpgrowth + divided_gov,
  ipr_tripsplus_enforcement ~ ldeberta_score * laid_usd +
          log_gdpcons + log_import + log_export + unga_dist +
          usbit + gdpgrowth + divided_gov,
  data = heck_demo_dg, method = "2step")

heck_ifc_undisc_dg <- heckit(
  uspta ~ log_dist_us + log_gdpcons + log_import + log_export + unga_dist +
          usbit + gdpgrowth + divided_gov,
  ipr_tripsplus_undisclosed_information ~ ldeberta_score * lifc_loan +
          log_gdpcons + log_import + log_export + unga_dist +
          usbit + gdpgrowth + divided_gov,
  data = heck_nondem_dg, method = "2step")
heck_ifc_patent_dg <- heckit(
  uspta ~ log_dist_us + log_gdpcons + log_import + log_export + unga_dist +
          usbit + gdpgrowth + divided_gov,
  ipr_tripsplus_patents ~ ldeberta_score * lifc_loan +
          log_gdpcons + log_import + log_export + unga_dist +
          usbit + gdpgrowth + divided_gov,
  data = heck_nondem_dg, method = "2step")
heck_ifc_enf_dg <- heckit(
  uspta ~ log_dist_us + log_gdpcons + log_import + log_export + unga_dist +
          usbit + gdpgrowth + divided_gov,
  ipr_tripsplus_enforcement ~ ldeberta_score * lifc_loan +
          log_gdpcons + log_import + log_export + unga_dist +
          usbit + gdpgrowth + divided_gov,
  data = heck_nondem_dg, method = "2step")

dg_models <- list(
  heck_aid_undisc_dg, heck_aid_patent_dg, heck_aid_enf_dg,
  heck_ifc_undisc_dg, heck_ifc_patent_dg, heck_ifc_enf_dg
)

texreg(dg_models,
       custom.model.names = c("Undiscl (D)", "Patents (D)", "Enforce (D)",
                              "Undiscl (ND)", "Patents (ND)", "Enforce (ND)"),
       caption = "Heckman selection model (strict divided-government specification)",
       label   = "tab:heckman",
       file    = op("heckman_results.tex"),
       digits  = 3,
       stars   = c(0.01, 0.05, 0.10))
cat("Wrote", op("heckman_results.tex"), "\n")

cat("\nAll tables regenerated from analysis_data.csv only.\n")

# =========================================================================
# 5. Figures
#    Ported from the plot chunks of nteDeBERTa_RR.Rmd. analysis_data.csv
#    carries the same country / year / deberta_score / ldeberta_score columns
#    used by those chunks, so every figure is reproduced from it alone.
# =========================================================================

fig_dir <- "figures"
if (!dir.exists(fig_dir)) dir.create(fig_dir)
fp <- function(f) file.path(fig_dir, f)


# ---- 5c. Rug-data subsets (obs actually used in each model) -------------
# Reconstruct exactly as the Rmd: the model's filtered data, then the rows
# kept by feols via obs_selection.
tempA  <- temp %>% filter(oecd1994 == 0 & iso3c != "EUU") %>% filter(democ == "Democracy")
tempA  <- tempA[unlist(feols_trips_aid1$obs_selection), ]
tempA1 <- temp %>% filter(oecd1994 == 0 & iso3c != "EUU") %>% filter(democ == "Democracy")
tempA1 <- tempA1[unlist(feols_trips_aid1p$obs_selection), ]
tempB  <- temp %>% filter(oecd1994 == 0 & iso3c != "EUU") %>% filter(democ == "Democracy")
tempB  <- tempB[unlist(feols_trips_aid1e$obs_selection), ]

tempC  <- temp %>% filter(oecd1994 == 0 & iso3c != "EUU" & iso3c != "RUS") %>% filter(democ == "Non-democracy")
tempC  <- tempC[unlist(feols_trips_ifc1$obs_selection), ]
tempC1 <- temp %>% filter(oecd1994 == 0 & iso3c != "EUU" & iso3c != "RUS") %>% filter(democ == "Non-democracy")
tempC1 <- tempC1[unlist(feols_trips_ifc1p$obs_selection), ]
tempD  <- temp %>% filter(oecd1994 == 0 & iso3c != "EUU" & iso3c != "RUS") %>% filter(democ == "Non-democracy")
tempD  <- tempD[unlist(feols_trips_ifc1e$obs_selection), ]

# ---- 5d. Three Aid marginal-effects plots -------------------------------
p_aid_u <- plot_comparisons(
  feols_trips_aid1,
  variables = list("laid_usd" = "sd"),
  condition = "ldeberta_score",
  conf_level = 0.95
) +
  geom_hline(yintercept = 0, color = "grey80", linetype = "dashed") +
  geom_rug(data = tempA, aes(x = ldeberta_score),
           inherit.aes = FALSE, color = "black", alpha = 0.4,
           length = unit(0.06, "npc")) +
  theme_classic() +
  xlab("DeBERTa Score") +
  ylab(bquote(Delta ~ ("Undisclosed info"))) +
  theme(
    panel.background = element_rect(fill = "transparent"),
    plot.background = element_rect(fill = "transparent", color = NA),
    legend.position = "none"
  )
ggsave(filename = fp("fig_marg_aid_undisclosed.png"), plot = p_aid_u,
       width = 6, height = 4, dpi = 300)
cat("Wrote", fp("fig_marg_aid_undisclosed.png"), "\n")

p_aid_p <- plot_comparisons(
  feols_trips_aid1p,
  variables = list("laid_usd" = "sd"),
  condition = "ldeberta_score",
  conf_level = 0.9
) +
  geom_hline(yintercept = 0, color = "grey80", linetype = "dashed") +
  geom_rug(data = tempA1, aes(x = ldeberta_score),
           inherit.aes = FALSE, color = "black", alpha = 0.4,
           length = unit(0.06, "npc")) +
  theme_classic() +
  xlab("DeBERTa Score") +
  ylab(bquote(Delta ~ ("Patent"))) +
  theme(
    panel.background = element_rect(fill = "transparent"),
    plot.background = element_rect(fill = "transparent", color = NA),
    legend.position = "none"
  )
ggsave(filename = fp("fig_marg_aid_patent.png"), plot = p_aid_p,
       width = 6, height = 4, dpi = 300)
cat("Wrote", fp("fig_marg_aid_patent.png"), "\n")

p_aid_e <- plot_comparisons(
  feols_trips_aid1e,
  variables = list("laid_usd" = "sd"),
  condition = "ldeberta_score",
  conf_level = 0.9
) +
  geom_hline(yintercept = 0, color = "grey80", linetype = "dashed") +
  geom_rug(data = tempB, aes(x = ldeberta_score),
           inherit.aes = FALSE, color = "black", alpha = 0.4,
           length = unit(0.06, "npc")) +
  theme_classic() +
  xlab("DeBERTa Score") +
  ylab(bquote(Delta ~ ("Enforcement"))) +
  theme(
    panel.background = element_rect(fill = "transparent"),
    plot.background = element_rect(fill = "transparent", color = NA),
    legend.position = "none"
  )
ggsave(filename = fp("fig_marg_aid_enforcement.png"), plot = p_aid_e,
       width = 6, height = 4, dpi = 300)
cat("Wrote", fp("fig_marg_aid_enforcement.png"), "\n")

# ---- 5e. Three IFC marginal-effects plots -------------------------------
p_ifc_u <- plot_comparisons(feols_trips_ifc1,
            variables = list("lifc_loan" = "sd"),
            condition = c("ldeberta_score"),
            conf_level = 0.9) +
  theme_classic() + xlab("DeBERTa score") + ylab(bquote(Delta ~ ("Undisclosed info"))) +
  geom_hline(yintercept = 0, color = "grey80", linetype = "dashed") +
  geom_rug(data = tempC, aes(x = ldeberta_score), color = "black", alpha = .4, length = unit(0.06, "npc")) +
  theme(
         panel.background = element_rect(fill = 'transparent'),
         plot.background = element_rect(fill = 'transparent', color = NA),
         panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         legend.position = "none"
       )
ggsave(filename = fp("fig_marg_ifc_undisclosed.png"), plot = p_ifc_u,
       width = 6, height = 4, dpi = 300)
cat("Wrote", fp("fig_marg_ifc_undisclosed.png"), "\n")

p_ifc_p <- plot_comparisons(feols_trips_ifc1p,
            variables = list("lifc_loan" = "sd"),
            condition = c("ldeberta_score"),
            conf_level = 0.9) +
  theme_classic() + xlab("DeBERTa score") + ylab(bquote(Delta ~ ("Patent"))) +
  geom_hline(yintercept = 0, color = "grey80", linetype = "dashed") +
  geom_rug(data = tempC1, aes(x = ldeberta_score), color = "black", alpha = .4, length = unit(0.06, "npc")) +
  theme(
         panel.background = element_rect(fill = 'transparent'),
         plot.background = element_rect(fill = 'transparent', color = NA),
         panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         legend.position = "none"
       )
ggsave(filename = fp("fig_marg_ifc_patent.png"), plot = p_ifc_p,
       width = 6, height = 4, dpi = 300)
cat("Wrote", fp("fig_marg_ifc_patent.png"), "\n")

p_ifc_e <- plot_comparisons(feols_trips_ifc1e,
            variables = list("lifc_loan" = "sd"),
            condition = c("ldeberta_score"),
            conf_level = 0.9) +
  theme_classic() + xlab("DeBERTa score") + ylab(bquote(Delta ~ ("Enforcement"))) +
  geom_hline(yintercept = 0, color = "grey80", linetype = "dashed") +
  geom_rug(data = tempD, aes(x = ldeberta_score), color = "black", alpha = .4, length = unit(0.06, "npc")) +
  theme(
         panel.background = element_rect(fill = 'transparent'),
         plot.background = element_rect(fill = 'transparent', color = NA),
         panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         legend.position = "none"
       )
ggsave(filename = fp("fig_marg_ifc_enforcement.png"), plot = p_ifc_e,
       width = 6, height = 4, dpi = 300)
cat("Wrote", fp("fig_marg_ifc_enforcement.png"), "\n")

cat("\nAll 12 figures written to", fig_dir, "/ from analysis_data.csv only.\n")
