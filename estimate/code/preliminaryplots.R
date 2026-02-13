#*** Minimum Wages (preliminary plots) **
#***
#*** Reads: ../input/repeated_cross.RData, ../input/decile_centile.RData
#*** Writes: ../output/figs/*.jpeg

# Preamble --------------------------------------------------------------------

rm(list = ls())
options(scipen = 999)

if (!require(pacman)) install.packages("pacman")
p_load("dplyr", "ggplot2",
       "dineq", "viridis", "haven",
       "data.table", "stringr",
       "tidyverse", "srvyr", "bit64", "survey",
       "cowplot", "convey", "mxmaps", "fixest", "Hmisc"
)

load("../input/enigh_year.RData")

if (!dir.exists("../output/figs")) dir.create("../output/figs", recursive = TRUE)

# Density Plots ---------------------------------------------------------------

## By Groups ------------------------------------------------------------------

{
  plots_list <- list()

  for (i in years) {

    # Minimum wage zone comparison
    min_comp_i <- ggplot(cross_list[[paste0("cross_section", i)]] %>% filter(ing_lab > 0)) +
      geom_density(aes(x = log(ing_lab), linetype = as.factor(zlfn))) +
      scale_linetype_manual(values = c("solid", "dashed"),
                            labels = c("Rest of The Country", "ZLFN")) +
      labs(y = "Density", x = "Labor Income (log)", title = paste("Year:", i)) +
      theme_minimal() +
      theme(legend.position = "bottom", legend.title = element_blank())
    plots_list[[paste0("min_comp_", i)]] <- min_comp_i

    # Ethnicity comparison
    et_comp_i <- ggplot(cross_list[[paste0("cross_section", i)]] %>% filter(ing_lab > 0)) +
      geom_density(aes(x = log(ing_lab), linetype = as.factor(etnia))) +
      scale_linetype_manual(values = c("solid", "dashed"),
                            labels = c("Indigenous", "Non-Indigenous")) +
      labs(y = "Density", x = "Labor Income (log)", title = paste("Year:", i)) +
      theme_minimal() +
      theme(legend.position = "bottom", legend.title = element_blank())
    plots_list[[paste0("et_comp_", i)]] <- et_comp_i

    # Informality comparison
    inf_comp_i <- ggplot(cross_list[[paste0("cross_section", i)]] %>% filter(ing_lab > 0)) +
      geom_density(aes(x = log(ing_lab), linetype = as.factor(informal))) +
      scale_linetype_manual(values = c("solid", "dashed"),
                            labels = c("Formal", "Informal")) +
      labs(y = "Density", x = "Labor Income (log)", title = paste("Year:", i)) +
      theme_minimal() +
      theme(legend.position = "bottom", legend.title = element_blank())
    plots_list[[paste0("inf_comp_", i)]] <- inf_comp_i

    # Gender comparison
    sex_comp_i <- ggplot(cross_list[[paste0("cross_section", i)]] %>% filter(ing_lab > 0)) +
      geom_density(aes(x = log(ing_lab), linetype = as.factor(sexo))) +
      scale_linetype_manual(values = c("solid", "dashed"),
                            labels = c("Men", "Women")) +
      labs(y = "Density", x = "Labor Income (log)", title = paste("Year:", i)) +
      theme_minimal() +
      theme(legend.position = "bottom", legend.title = element_blank())
    plots_list[[paste0("sex_comp_", i)]] <- sex_comp_i

    # Rural-urban comparison
    rur_comp_i <- ggplot(cross_list[[paste0("cross_section", i)]] %>% filter(ing_lab > 0)) +
      geom_density(aes(x = log(ing_lab), linetype = as.factor(rururb))) +
      scale_linetype_manual(values = c("solid", "dashed"),
                            labels = c("Urban", "Rural")) +
      labs(y = "Density", x = "Labor Income (log)", title = paste("Year:", i)) +
      theme_minimal() +
      theme(legend.position = "bottom", legend.title = element_blank())
    plots_list[[paste0("rur_comp_", i)]] <- rur_comp_i
  }

  grid1 <- plot_grid(plots_list$min_comp_2016, plots_list$min_comp_2018,
                     plots_list$min_comp_2020, plots_list$min_comp_2022,
                     plots_list$min_comp_2024, ncol = 3)

  grid2 <- plot_grid(plots_list$et_comp_2016, plots_list$et_comp_2018,
                     plots_list$et_comp_2020, plots_list$et_comp_2022,
                     plots_list$et_comp_2024, ncol = 3)

  grid3 <- plot_grid(plots_list$inf_comp_2016, plots_list$inf_comp_2018,
                     plots_list$inf_comp_2020, plots_list$inf_comp_2022,
                     plots_list$inf_comp_2024, ncol = 3)

  grid4 <- plot_grid(plots_list$sex_comp_2016, plots_list$sex_comp_2018,
                     plots_list$sex_comp_2020, plots_list$sex_comp_2022,
                     plots_list$sex_comp_2024, ncol = 3)

  grid5 <- plot_grid(plots_list$rur_comp_2016, plots_list$rur_comp_2018,
                     plots_list$rur_comp_2020, plots_list$rur_comp_2022,
                     plots_list$rur_comp_2024, ncol = 3)

  save_plot("../output/figs/min_wageZone_comp.jpeg", grid1, base_width = 12, base_height = 8)
  save_plot("../output/figs/ethnic_wage_comp.jpeg", grid2, base_width = 12, base_height = 8)
  save_plot("../output/figs/informality_wage_comp.jpeg", grid3, base_width = 12, base_height = 8)
  save_plot("../output/figs/gender_wage_comp.jpeg", grid4, base_width = 12, base_height = 8)
  save_plot("../output/figs/rural_urban_wage_comp.jpeg", grid5, base_width = 12, base_height = 8)
}

## By Year ------------------------------------------------------------------

ggplot(cross_final) +
  geom_density(aes(x = log(ictpc), color = as.factor(year))) +
  labs(y = "Density", x = "Per Capita Household Income (log)") +
  scale_color_viridis(discrete = TRUE, option = "H") +
  theme_minimal() +
  theme(legend.position = "bottom", legend.title = element_blank()) +
  scale_x_continuous(limits = c(4, 12))
ggsave("../output/figs/income_density.jpeg", width = 10, height = 6)

