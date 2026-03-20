#################################################
################# Clean Memory ##################
#################################################

rm(list = ls())
options(scipen = 999)

### REPLICATION FILE: enigh-year
### R VERSION: 4.5+
### AUTHORS: Matías Carrasco, Victor Ortega Le Hénanff
### DATE: 2026-03-03

#################################################
############## Load + Packages ##################
#################################################

if (!require(pacman)) install.packages("pacman")
p_load("dplyr", "ggplot2",
       "dineq", "viridis", "haven",
       "data.table", "stringr",
       "tidyverse", "srvyr", "bit64", "survey",
       "cowplot", "convey", "Hmisc"
)

#################################################
################## Main Loop ####################
#################################################

years <- c(2016, 2018, 2020, 2022, 2024)
cross_list <- list()

for (i in years) {
  message(format(Sys.time(), "%H:%M:%S"), " | Running year ", i)

  #################################################
  ############## Deflators from INPC ##############
  #################################################

  deflators <- fread("../../data/clean/inpc/inpc.csv") %>%
    rename(year = Año_int, month = Mes, deflator = Deflator) %>%
    select(-Fecha)

  deflators_i <- deflators %>%
    filter(year == i | (year == i - 1 & month == 12)) %>%
    arrange(desc(year))

  {
    dec_im1 <- as.numeric(deflators_i[13, 4])
    jan_i   <- as.numeric(deflators_i[12, 4])
    feb_i   <- as.numeric(deflators_i[11, 4])
    mar_i   <- as.numeric(deflators_i[10, 4])
    apr_i   <- as.numeric(deflators_i[9, 4])
    may_i   <- as.numeric(deflators_i[8, 4])
    jun_i   <- as.numeric(deflators_i[7, 4])
    jul_i   <- as.numeric(deflators_i[6, 4])
    ago_i   <- as.numeric(deflators_i[5, 4])
    sep_i   <- as.numeric(deflators_i[4, 4])
    oct_i   <- as.numeric(deflators_i[3, 4])
    nov_i   <- as.numeric(deflators_i[2, 4])
    dec_i   <- as.numeric(deflators_i[1, 4])
  }

  if (nrow(deflators_i) != 13) {
    stop(sprintf("deflators_i has %d rows (expected 13) for year %d", nrow(deflators_i), i))
  } else {
    message(" Deflators rows check passed.")
  }

  expected_months <- c(12, 1:12)
  actual_months <- as.integer(deflators_i$month)
  if (!all(expected_months %in% actual_months)) {
    warning("Months in deflators_i not as expected: ",
            paste(sort(unique(actual_months)), collapse = ", "))
  } else {
    message(" Deflators months check passed.")
  }

  #################################################
  ############# Aguinaldo correction ##############
  #################################################

  tra_path <- sprintf("../../data/source/enigh/trabajos%d.dta", i)
  tra_dt   <- as.data.table(read_dta(tra_path)) %>% rename_all(tolower)

  # aguinaldo variable code differs across years
  if (i %in% c(2016, 2018)) {
    aguinaldo_var  <- "pres_8"
    aguinaldo_code <- "08"
  } else {
    aguinaldo_var  <- "pres_2"
    aguinaldo_code <- "02"
  }

  # build aguinaldo flags per worker
  dup_check <- tra_dt[, .N, by = .(folioviv, foliohog, numren, id_trabajo)][N > 1]
  if (nrow(dup_check) > 0) {
    stop(" Duplicates by (folio, id_trabajo) in tra_dt.")
  } else {
    message(" No duplicates in tra_dt for (folio, id_trabajo).")
  }

  tra_def <- tra_dt %>%
    dplyr::select(folioviv, foliohog, numren, id_trabajo,
                  all_of(aguinaldo_var)) %>%
    rename(pres = all_of(aguinaldo_var)) %>%
    mutate(pres = as.character(pres)) %>%
    as.data.table() %>%
    dcast(folioviv + foliohog + numren ~ id_trabajo, value.var = "pres") %>%
    mutate(
      trab = 1,
      aguinaldo1 = case_when(`1` == aguinaldo_code ~ 1, TRUE ~ 0),
      aguinaldo2 = case_when(`2` == aguinaldo_code ~ 1, TRUE ~ 0)
    ) %>%
    select(folioviv, foliohog, numren, aguinaldo1, aguinaldo2, trab)

  #################################################
  ################ Ingresos dataset ###############
  #################################################

  ing_path <- sprintf("../../data/source/enigh/ingresos%d.dta", i)
  ing_dt   <- as.data.table(read_dta(ing_path)) %>% rename_all(tolower)

  # Join aguinaldo to filter invalid bonus lines
  n_before <- nrow(ing_dt)
  ing_dt2  <- left_join(ing_dt, tra_def, by = c("folioviv", "foliohog", "numren"))
  n_after  <- nrow(ing_dt2)
  if (n_after != n_before) {
    warning(sprintf(" left_join changed row count: %d -> %d (year %d)",
                    n_before, n_after, i))
  } else {
    message(" Join rows for ing-tra join check passed.")
  }

  ing_dt <- full_join(ing_dt, tra_def,
                      by = c("folioviv", "foliohog", "numren")) %>%
    mutate(index = case_when(
      clave == "P009" & aguinaldo1 != 1 ~ 1,
      clave == "P016" & aguinaldo2 != 1 ~ 1,
      TRUE ~ 0
    )) %>%
    filter(index != 1)

  # deflate monthly income columns using month-specific deflators
  ing_dt <- mutate(ing_dt,
    ing_6 = ifelse(is.na(mes_6), ing_6,
      case_when(mes_6 == "02" ~ ing_6 / feb_i,
                mes_6 == "03" ~ ing_6 / mar_i,
                mes_6 == "04" ~ ing_6 / apr_i,
                mes_6 == "05" ~ ing_6 / may_i)),
    ing_5 = ifelse(is.na(mes_5), ing_5,
      case_when(mes_5 == "03" ~ ing_5 / mar_i,
                mes_5 == "04" ~ ing_5 / apr_i,
                mes_5 == "05" ~ ing_5 / may_i,
                mes_5 == "06" ~ ing_5 / jun_i)),
    ing_4 = ifelse(is.na(mes_4), ing_4,
      case_when(mes_4 == "04" ~ ing_4 / apr_i,
                mes_4 == "05" ~ ing_4 / may_i,
                mes_4 == "06" ~ ing_4 / jun_i,
                mes_4 == "07" ~ ing_4 / jul_i)),
    ing_3 = ifelse(is.na(mes_3), ing_3,
      case_when(mes_3 == "05" ~ ing_3 / may_i,
                mes_3 == "06" ~ ing_3 / jun_i,
                mes_3 == "07" ~ ing_3 / jul_i,
                mes_3 == "08" ~ ing_3 / ago_i)),
    ing_2 = ifelse(is.na(mes_2), ing_2,
      case_when(mes_2 == "06" ~ ing_2 / jun_i,
                mes_2 == "07" ~ ing_2 / jul_i,
                mes_2 == "08" ~ ing_2 / ago_i,
                mes_2 == "09" ~ ing_2 / sep_i)),
    ing_1 = ifelse(is.na(mes_1), ing_1,
      case_when(mes_1 == "07" ~ ing_1 / jul_i,
                mes_1 == "08" ~ ing_1 / ago_i,
                mes_1 == "09" ~ ing_1 / sep_i,
                mes_1 == "10" ~ ing_1 / oct_i))
  )

  # special treatment for annual income items (profit-sharing, bonuses)
  annual_keys <- c("P008", "P009", "P015", "P016")

  ing_dt <- ing_dt %>%
    mutate(
      ing_1 = ifelse(clave == "P008" | clave == "P015", (ing_1 / may_i) / 12, ing_1),
      ing_1 = ifelse(clave == "P009" | clave == "P016", (ing_1 / dec_im1) / 12, ing_1),
      ing_2 = ifelse((clave %in% annual_keys) & ing_2 == 0, NA_real_, ing_2),
      ing_3 = ifelse((clave %in% annual_keys) & ing_3 == 0, NA_real_, ing_3),
      ing_4 = ifelse((clave %in% annual_keys) & ing_4 == 0, NA_real_, ing_4),
      ing_5 = ifelse((clave %in% annual_keys) & ing_5 == 0, NA_real_, ing_5),
      ing_6 = ifelse((clave %in% annual_keys) & ing_6 == 0, NA_real_, ing_6)
    )

  # create aggregate income variables
  ing_dt <- ing_dt %>%
    mutate(
      ing_mens = rowMeans(across(c(ing_1, ing_2, ing_3, ing_4, ing_5, ing_6)),
                          na.rm = TRUE),

      # broad categories (from repeated_cross.R)
      ing_mon = case_when(
        (clave >= "P001" & clave <= "P009") | (clave >= "P011" & clave <= "P016") |
        (clave >= "P018" & clave <= "P048") | (clave >= "P067" & clave <= "P081") |
        (clave >= "P101" & clave <= "P108") ~ ing_mens),
      ing_lab = case_when(
        (clave >= "P001" & clave <= "P009") | (clave >= "P011" & clave <= "P016") |
        (clave >= "P018" & clave <= "P022") | (clave >= "P067" & clave <= "P081") ~ ing_mens),
      ing_ren = case_when(
        (clave >= "P023" & clave <= "P031") ~ ing_mens),
      ing_tra = case_when(
        (clave >= "P032" & clave <= "P048") | (clave >= "P101" & clave <= "P108") ~ ing_mens),

      # fine categories (matching enigh_month.do classification)
      ing_wages = case_when(
        clave %in% c("P001","P002","P011","P018","P019","P067") ~ ing_mens),
      ing_non_wage_income = case_when(
        clave %in% c("P003","P004","P005","P006","P007","P008","P009",
                     "P014","P015","P016") ~ ing_mens),
      ing_gov_transfers = case_when(
        clave %in% c("P032","P033","P038","P040","P042","P043","P044","P045",
                     "P046","P047","P048","P101","P102","P103","P104","P105",
                     "P106","P107","P108") ~ ing_mens),
      ing_rentas = case_when(
        clave %in% c("P023","P024","P025") ~ ing_mens),
      ing_fin_capital = case_when(
        clave %in% c("P026","P027","P028","P029","P030","P031","P050",
                     "P052","P053","P064","P065","P066") ~ ing_mens),
      ing_negocio = case_when(
        clave %in% c("P068","P069","P070","P071","P072","P073","P074",
                     "P075","P076","P077","P078","P079","P080","P081") ~ ing_mens),
      ing_ventas = case_when(
        clave %in% c("P054","P055","P056","P059","P060","P061","P062",
                     "P063") ~ ing_mens),
      ing_other = case_when(
        clave %in% c("P012","P013","P020","P021","P022","P034","P035",
                     "P036","P037","P039","P041","P049","P051","P057",
                     "P058") ~ ing_mens)
    )

  multi <- ing_dt[, .N, by = .(folioviv, foliohog, numren, clave)][N > 1]
  if (nrow(multi) > 0) {
    warning(" Multiple rows per (folio, numren, clave). Will be summed.", nrow(multi))
  } else {
    message(" No multiple rows in ing_dt for (folio, numren, clave).")
  }

  # aggregate to person level
  inc_vars <- c("ing_mon", "ing_lab", "ing_ren", "ing_tra",
                "ing_wages", "ing_non_wage_income", "ing_gov_transfers",
                "ing_rentas", "ing_fin_capital", "ing_negocio",
                "ing_ventas", "ing_other")
  ing_dt <- data.table(ing_dt)[,
    lapply(.SD, sum, na.rm = TRUE),
    by = list(folioviv, foliohog, numren),
    .SDcols = inc_vars
  ]

  if (sum(is.na(ing_dt$ing_mon)) > 0) {
    warning(" NA's found in ing_mon after aggregation.")
  } else {
    message(" No NA's found in income after aggregation.")
  }

  #################################################
  ############### Poblacion dataset ###############
  #################################################

  pop_path <- sprintf("../../data/source/enigh/poblacion%d.dta", i)
  pop_dt   <- as.data.table(read_dta(pop_path)) %>%
    rename_all(tolower) %>%
    dplyr::select(
      folioviv, foliohog, numren,
      etnia, nivelaprob, gradoaprob,
      hablaind, lenguaind, comprenind,
      sexo_pob = sexo, edad_pob = edad,
      madre_hog, padre_hog,
      asis_esc, hor_1, trabajo_mp
    )

  # derived variables from poblacion (matching enigh_month.do)
  pop_dt <- pop_dt %>%
    mutate(
      # indigenous language speaker
      indspeaker = case_when(
        hablaind == "1" ~ 1L, hablaind == "2" ~ 0L, TRUE ~ NA_integer_),
      # understands indigenous language
      indund = case_when(
        comprenind == "1" ~ 1L, comprenind == "2" ~ 0L, TRUE ~ NA_integer_),
      # indigenous language code
      indlang = as.integer(lenguaind),
      # school attendance
      school_attendance = case_when(
        asis_esc == "1" ~ 1L, asis_esc == "2" ~ 0L, TRUE ~ NA_integer_),
      # mother/father in household
      motherhome = case_when(
        madre_hog == "1" ~ 1L, madre_hog == "2" ~ 0L, TRUE ~ NA_integer_),
      fatherhome = case_when(
        padre_hog == "1" ~ 1L, padre_hog == "2" ~ 0L, TRUE ~ NA_integer_),
      # hours worked per week (personas table)
      hoursworked = as.numeric(hor_1),
      # employed previous month
      employed = case_when(
        trabajo_mp == "1" ~ 1L, trabajo_mp == "2" ~ 0L, TRUE ~ NA_integer_),
      # years of study (from nivelaprob + gradoaprob, as in enigh_month.do)
      niv = as.integer(nivelaprob),
      grd = as.integer(gradoaprob),
      years_of_study = case_when(
        niv %in% c(0, 1) ~ 0,
        niv == 2 ~ pmin(grd, 6, na.rm = TRUE),
        niv == 3 ~ 6 + pmin(grd, 3, na.rm = TRUE),
        niv == 4 ~ 9 + pmin(grd, 3, na.rm = TRUE),
        niv %in% c(5, 6, 7) ~ 12 + pmin(grd, 5, na.rm = TRUE),
        niv == 8 ~ 17 + pmin(grd, 3, na.rm = TRUE),
        niv == 9 ~ 20 + pmin(grd, 5, na.rm = TRUE),
        TRUE ~ NA_real_
      )
    ) %>%
    dplyr::select(-hablaind, -comprenind, -lenguaind, -madre_hog,
                  -padre_hog, -asis_esc, -hor_1, -trabajo_mp, -niv, -grd)

  #################################################
  ############ Housing characteristics ############
  #################################################

  viv_path <- sprintf("../../data/source/enigh/viviendas%d.dta", i)
  viv_dt   <- as.data.table(read_dta(viv_path)) %>%
    rename_all(tolower) %>%
    dplyr::select(folioviv, tenencia, renta, estim_pago, antiguedad) %>%
    distinct(folioviv, .keep_all = TRUE)

  #################################################
  ################ Concentradohogar ###############
  #################################################

  hog_path <- sprintf("../../data/source/enigh/concentradohogar%d.dta", i)
  hog_dt   <- as.data.table(read_dta(hog_path)) %>%
    rename_all(tolower)

  # Keep only household-level identifiers and smg
  smg_cols <- intersect(c("folioviv", "smg"), names(hog_dt))
  hog_dt <- hog_dt[, ..smg_cols] %>%
    distinct(folioviv, .keep_all = TRUE)

  #################################################
  ############## Trabajos Indicators ##############
  #################################################

  tra_dt <- tra_dt %>%
    filter(id_trabajo == 1) %>%
    mutate(sector = str_sub(scian, 1, 2))

  # Select available columns flexibly
  tra_keep <- intersect(
    c("folioviv", "foliohog", "numren", "htrab",
      "scian", "sinco", "tam_emp", "clas_emp", "sector",
      "subor", "indep", "personal", "pago", "contrato", "tipocontr"),
    names(tra_dt)
  )
  tra_dt <- tra_dt %>% dplyr::select(all_of(tra_keep))

  #################################################
  ############## Poverty Indicators ###############
  #################################################

  pob_path <- sprintf("../../data/source/coneval/pobreza%d.dta", i)
  pob_dt   <- as.data.table(read_dta(pob_path)) %>% rename_all(tolower) %>%
    filter(pea == 1 | pea == 2) %>%
    mutate(
      hli      = ifelse(is.na(hli), 2, hli),
      informal = ifelse((pea == 1) & (ss_dir == 0), 1, 0),
      ictpc    = ictpc / ago_i,
      ict      = ict / ago_i,
      nomon    = nomon / ago_i,
      reg_esp  = reg_esp / ago_i,
      pago_esp = pago_esp / ago_i
    ) %>%
    dplyr::select(-ing_mon, -ing_lab, -ing_ren, -ing_tra)

  if (i %in% c(2020, 2022, 2024)) {
    if ("discap" %in% names(pob_dt)) {
      pob_dt <- pob_dt %>% dplyr::select(-discap)
    }
  }

  #################################################
  ############# Cross-section merge ###############
  #################################################

  # ZLFN municipalities (free northern border zone)
  zlfn_munis <- c(
    "02001","02002","02003","02004","02005","02006","02007",
    "05002","05012","05013","05014","05022","05023","05025","05038",
    "08005","08015","08028","08035","08037","08042","08052","08053",
    "19005",
    "26002","26004","26017","26019","26039","26043","26048","26055",
    "26059","26060","26070",
    "28007","28014","28015","28022","28024","28025","28027",
    "28032","28033","28043"
  )

  cross <- pob_dt %>%
    left_join(pop_dt, by = c("folioviv", "foliohog", "numren")) %>%
    left_join(tra_dt, by = c("folioviv", "foliohog", "numren")) %>%
    left_join(ing_dt, by = c("folioviv", "foliohog", "numren")) %>%
    left_join(viv_dt, by = "folioviv") %>%
    left_join(hog_dt, by = "folioviv") %>%
    mutate(
      year = i,
      zlfn = ifelse(ubica_geo %in% zlfn_munis, 1, 0),

      # state names
      ent_name = case_when(
        ent == 1  ~ "Aguascalientes", ent == 2  ~ "Baja California",
        ent == 3  ~ "Baja California Sur", ent == 4  ~ "Campeche",
        ent == 5  ~ "Coahuila", ent == 6  ~ "Colima",
        ent == 7  ~ "Chiapas", ent == 8  ~ "Chihuahua",
        ent == 9  ~ "Ciudad de México", ent == 10 ~ "Durango",
        ent == 11 ~ "Guanajuato", ent == 12 ~ "Guerrero",
        ent == 13 ~ "Hidalgo", ent == 14 ~ "Jalisco",
        ent == 15 ~ "México", ent == 16 ~ "Michoacán",
        ent == 17 ~ "Morelos", ent == 18 ~ "Nayarit",
        ent == 19 ~ "Nuevo León", ent == 20 ~ "Oaxaca",
        ent == 21 ~ "Puebla", ent == 22 ~ "Querétaro",
        ent == 23 ~ "Quintana Roo", ent == 24 ~ "San Luis Potosí",
        ent == 25 ~ "Sinaloa", ent == 26 ~ "Sonora",
        ent == 27 ~ "Tabasco", ent == 28 ~ "Tamaulipas",
        ent == 29 ~ "Tlaxcala", ent == 30 ~ "Veracruz",
        ent == 31 ~ "Yucatán", ent == 32 ~ "Zacatecas"),

      # Regions
      reg_num = case_when(
        ent %in% c(26, 25, 2, 3, 18)             ~ 1,
        ent %in% c(5, 8, 10, 32, 24)             ~ 2,
        ent %in% c(28, 19)                        ~ 3,
        ent %in% c(1, 14, 11, 6, 16)             ~ 4,
        ent %in% c(22, 15, 9, 13, 17, 29, 21)    ~ 5,
        ent %in% c(12, 20, 7)                     ~ 6,
        ent %in% c(27, 30)                        ~ 7,
        ent %in% c(4, 23, 31)                     ~ 8),
      reg_name = case_when(
        reg_num == 1 ~ "Northwest",  reg_num == 2 ~ "North",
        reg_num == 3 ~ "Northeast",  reg_num == 4 ~ "Center-West",
        reg_num == 5 ~ "Center-East", reg_num == 6 ~ "South",
        reg_num == 7 ~ "East",       reg_num == 8 ~ "Peninsula"),
      macro_num = case_when(
        ent %in% c(26,25,2,3,18,5,8,10,32,24,28,19) ~ 1,
        ent %in% c(1,14,11,6,16,22,15,9,13,17,29,21) ~ 2,
        ent %in% c(12, 20, 7)                         ~ 3,
        ent %in% c(27, 30, 4, 23, 31)                 ~ 4),
      macro_name = case_when(
        macro_num == 1 ~ "Northern", macro_num == 2 ~ "Central",
        macro_num == 3 ~ "South",    macro_num == 4 ~ "Eastern")
    ) %>%
    # drop rows with NA in core income variables
    filter(!if_any(all_of(c("ing_mon", "ing_lab", "ing_ren", "ing_tra")), is.na))

  # factor conversions and derived dummies
  cross <- cross %>%
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
      gov_sp       = ifelse(ing_gov_transfers > 0, 1, 0),
      public       = ifelse(clas_emp == 3, 1, 0),
      profesional  = ifelse(nivelaprob %in% c(7, 8, 9), 1, 0),
      post         = ifelse(year %in% c(2020, 2022, 2024), 1, 0),
      ent_exp      = ifelse(zlfn == 1, 33, as.numeric(as.character(ent)))
    )

  # checks
  if (sum(is.na(cross$reg_num)) > 0 || sum(is.na(cross$macro_num)) > 0) {
    warning(" Regional / Macroregional NA's detected.")
  } else {
    message(" No NA's in the construction of regions.")
  }

  n_pob   <- nrow(pob_dt)
  n_cross <- nrow(cross)
  if (n_cross > n_pob) {
    warning(sprintf(" cross has more rows than pob_dt: %d > %d", n_cross, n_pob))
  } else {
    message(" Cross-sectional left_join check passed.")
  }

  # --- National deciles and centiles ---
  cross <- cross %>%
    mutate(
      deciles_ictpc   = ntiles.wtd(x = ictpc,   n = 10,  weights = factor),
      deciles_inglab  = ntiles.wtd(x = ing_lab,  n = 10,  weights = factor),
      centiles_ictpc  = ntiles.wtd(x = ictpc,    n = 100, weights = factor),
      centiles_inglab = ntiles.wtd(x = ing_lab,  n = 100, weights = factor)
    )

  if (any(is.na(cross$deciles_ictpc), is.na(cross$deciles_inglab),
          is.na(cross$centiles_ictpc), is.na(cross$centiles_inglab))) {
    warning(" NA's found in decile/centile assignment")
  } else {
    message(" No NA's found in decile/centile assignment")
  }

  cross_list[[paste0("cross_section", i)]] <- cross
}

# ===========================================================================
# Stack all years
# ===========================================================================

remove(list = ls()[!ls() %in% c("cross_list", "years")])

cross_final <- rbindlist(
  lapply(years, function(y) {
    dt <- cross_list[[paste0("cross_section", y)]]
    # Strip haven_labelled classes so columns match across years
    for (col in names(dt)) {
      if (inherits(dt[[col]], "haven_labelled")) {
        dt[[col]] <- as.vector(dt[[col]])
      }
    }
    dt
  }),
  use.names = TRUE, fill = TRUE
)

remove(list = ls()[!ls() %in% c("cross_final", "cross_list", "years")])

# Convert factor columns to native types for Stata compatibility
cross_final_dta <- cross_final
for (col in names(cross_final_dta)) {
  if (is.factor(cross_final_dta[[col]])) {
    num_vals <- suppressWarnings(as.numeric(as.character(cross_final_dta[[col]])))
    if (all(!is.na(num_vals) | is.na(cross_final_dta[[col]]))) {
      cross_final_dta[[col]] <- num_vals
    } else {
      cross_final_dta[[col]] <- as.character(cross_final_dta[[col]])
    }
  }
}
haven::write_dta(cross_final_dta, "../../data/clean/enigh/enigh-year.dta")
message(" Saved ../../data/clean/enigh/enigh-year.dta")

save.image("../../data/clean/enigh/enigh-year.RData")
message(" Saved ../../data/clean/enigh/enigh-year.RData")

