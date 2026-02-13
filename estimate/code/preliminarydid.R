#*** Minimum Wages (preliminary DiD estimations) **
#***
#*** Reads: ../input/repeated_cross.RData
#*** Writes: estimation output to console (tables can be exported with fixest)

# Preamble --------------------------------------------------------------------

rm(list = ls())
options(scipen = 999)

if (!require(pacman)) install.packages("pacman")
p_load("dplyr", "ggplot2",
       "dineq", "viridis", "haven",
       "data.table", "stringr",
       "tidyverse", "srvyr", "bit64", "survey",
       "cowplot", "convey", "fixest"
)

load("../input/enigh_year.RData")

cross_final <- cross_final %>%
  filter(ing_lab > 0) %>%
  mutate(
    ubica_geo    = as.factor(ubica_geo),
    ent          = as.factor(ent),
    year         = as.factor(year),
    zlfn         = as.integer(zlfn),
    sector       = as.factor(sector),
    sexo         = ifelse(sexo == 1, 1, 0),
    etnia        = ifelse(etnia == 1, 1, 0),
    subor        = ifelse(subor == 1, 1, 0),
    indep        = ifelse(indep == 1, 1, 0),
    public       = ifelse(clas_emp == 3, 1, 0),
    profesional  = ifelse((nivelaprob == 7 | nivelaprob == 8 | nivelaprob == 9), 1, 0),
    post         = ifelse((year == 2020 | year == 2022 | year == 2024), 1, 0),
    ent_exp      = ifelse(zlfn == 1, 33, ent)
  )

# Baseline DiD regressions ----------------------------------------------------

m_lab <- feols(
  log(ing_lab) ~ rururb + edad + I(edad^2) + sexo + ic_rezedu +
    ic_asalud + ic_segsoc + ic_cv + ic_sbv + ic_ali + etnia + subor +
    htrab + subor + public + profesional + zlfn:post
  | ubica_geo + ent + year + sector,
  data = cross_final,
  weights = ~factor,
  cluster = ~ubica_geo
)
summary(m_lab)

m_event <- feols(
  log(ing_lab) ~ rururb + edad + I(edad^2) + sexo + ic_rezedu +
    ic_asalud + ic_segsoc + ic_cv + ic_sbv + ic_ali + subor +
    htrab + subor + public + profesional +
    i(year, zlfn, ref = 2018)
  | ubica_geo + ent + sector,
  data = cross_final,
  weights = ~factor,
  cluster = ~ubica_geo
)
summary(m_event)

iplot(m_event,
      xlab = "Year",
      main = "Event Study: ZLFN vs Rest of The country",
      ci_level = 0.95) +
  geom_vline(xintercept = 2016, linetype = "dashed")


m_lab_e <- feols(
  log(ing_lab) ~ rururb + edad + I(edad^2) + sexo + ic_rezedu +
    ic_asalud + ic_segsoc + ic_cv + ic_sbv + ic_ali + etnia + subor +
    htrab + subor + public + profesional + zlfn:post
  | ubica_geo + ent + year,
  data = cross_final %>% filter(deciles_ictpc == 5),
  weights = ~factor,
  cluster = ~ubica_geo
)
summary(m_lab_e)
