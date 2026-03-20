### REPLICATION FILE: code/build/Makefile
### VERSION: GNU Make 3.81+
### AUTHORS: Matías Carrasco, Victor Ortega Le Hénanff
### DATE: 2026-03-03

#################################################
############### Configuration ###################
#################################################

DATADIR := ../../data

API_URL := https://en.www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/INDICATOR/910392/en/0700/false/BIE-BISE/2.0/d024134c-be50-03ee-bdf6-1cda05612673?type=json

YEARS := 2024 2022 2020 2018 2016
YEARS_CONEVAL := 2022 2020 2018 2016
YEARS_AGRO := 2024 2022 2020
YEARS_JCF := 2024 2022 2020
YEARS_TARJETAS := 2024 2022 2020 2018 2016

#################################################
############### Main Targets ####################
#################################################

all: $(DATADIR)/clean/enigh/enigh-year.RData $(DATADIR)/clean/enigh/enigh-year.dta

download: inpc enigh poverty
	rm -rf temp

inpc: $(DATADIR)/source/inpc/inpc.json

enigh: $(foreach yr,$(YEARS), \
     $(DATADIR)/source/enigh/concentradohogar$(yr).dta $(DATADIR)/source/enigh/ingresos$(yr).dta \
     $(DATADIR)/source/enigh/poblacion$(yr).dta $(DATADIR)/source/enigh/trabajos$(yr).dta \
     $(DATADIR)/source/enigh/viviendas$(yr).dta $(DATADIR)/source/enigh/hogares$(yr).dta \
     $(DATADIR)/source/enigh/erogaciones$(yr).dta $(DATADIR)/source/enigh/gastoshogar$(yr).dta \
     $(DATADIR)/source/enigh/gastospersona$(yr).dta $(DATADIR)/source/enigh/noagro$(yr).dta) \
     $(foreach yr,$(YEARS_TARJETAS),$(DATADIR)/source/enigh/gastotarjetas$(yr).dta) \
     $(foreach yr,$(YEARS_AGRO),$(DATADIR)/source/enigh/agroproductos$(yr).dta $(DATADIR)/source/enigh/agrogasto$(yr).dta $(DATADIR)/source/enigh/noagroimportes$(yr).dta) \
     $(foreach yr,$(YEARS_JCF),$(DATADIR)/source/enigh/ingresos_JCF$(yr).dta)

poverty: $(addprefix $(DATADIR)/source/coneval/, \
     pobreza2024.dta pobreza2022.dta pobreza2020.dta pobreza2018.dta pobreza2016.dta)

#################################################
############## Source Data Needed ###############
#################################################

SOURCE_DTA := $(foreach year, $(YEARS), \
  $(DATADIR)/source/enigh/ingresos$(year).dta \
  $(DATADIR)/source/enigh/poblacion$(year).dta \
  $(DATADIR)/source/enigh/concentradohogar$(year).dta \
  $(DATADIR)/source/enigh/viviendas$(year).dta \
  $(DATADIR)/source/enigh/trabajos$(year).dta) \
  $(foreach year, $(YEARS), $(DATADIR)/source/coneval/pobreza$(year).dta)

#################################################
############## Directory Creation ###############
#################################################

$(DATADIR)/source/enigh $(DATADIR)/source/coneval $(DATADIR)/source/inpc:
	mkdir -p $@

$(DATADIR)/clean/enigh $(DATADIR)/clean/inpc:
	mkdir -p $@

temp:
	mkdir -p $@

log:
	mkdir -p $@

#################################################
############# INPC (Download) ###################
#################################################

$(DATADIR)/source/inpc/inpc.json: | $(DATADIR)/source/inpc
	curl -L -o $@ $(API_URL)

#################################################
############# INPC (Clean) ######################
#################################################

$(DATADIR)/clean/inpc/inpc.csv: inpc-year.R $(DATADIR)/source/inpc/inpc.json | $(DATADIR)/clean/inpc
	Rscript inpc-year.R

#################################################
######### Yearly Cross-Section (Clean) ##########
#################################################

$(DATADIR)/clean/enigh/enigh-year.RData $(DATADIR)/clean/enigh/enigh-year.dta: enigh-year.R $(SOURCE_DTA) $(DATADIR)/clean/inpc/inpc.csv | $(DATADIR)/clean/enigh
	Rscript enigh-year.R

#################################################
############ ENIGH Download Rules ###############
#################################################

# --- concentradohogar ---
define concentradohogar_rules
temp/enigh$(1)_dta.zip: | temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_concentradohogar_dta.zip -O $$@ || { echo "Failed to download $(1) concentradohogar"; exit 1; }

$(DATADIR)/source/enigh/concentradohogar$(1).dta: temp/enigh$(1)_dta.zip | $(DATADIR)/source/enigh
	unzip -o -j $$< concentradohogar.dta -d $(DATADIR)/source/enigh
	mv $(DATADIR)/source/enigh/concentradohogar.dta $$@
endef

# --- ingresos ---
define ingresos_rules
temp/enigh$(1)_i_dta.zip: | temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_ingresos_dta.zip -O $$@ || { echo "Failed to download $(1) ingresos"; exit 1; }

$(DATADIR)/source/enigh/ingresos$(1).dta: temp/enigh$(1)_i_dta.zip | $(DATADIR)/source/enigh
	unzip -o -j $$< ingresos.dta -d $(DATADIR)/source/enigh
	mv $(DATADIR)/source/enigh/ingresos.dta $$@
endef

# --- poblacion ---
define poblacion_rules
temp/enigh$(1)_p_dta.zip: | temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_poblacion_dta.zip -O $$@ || { echo "Failed to download $(1) poblacion"; exit 1; }

$(DATADIR)/source/enigh/poblacion$(1).dta: temp/enigh$(1)_p_dta.zip | $(DATADIR)/source/enigh
	unzip -o -j $$< poblacion.dta -d $(DATADIR)/source/enigh
	mv $(DATADIR)/source/enigh/poblacion.dta $$@
endef

# --- trabajos ---
define trabajos_rules
temp/enigh$(1)_t_dta.zip: | temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_trabajos_dta.zip -O $$@ || { echo "Failed to download $(1) trabajos"; exit 1; }

$(DATADIR)/source/enigh/trabajos$(1).dta: temp/enigh$(1)_t_dta.zip | $(DATADIR)/source/enigh
	unzip -o -j $$< trabajos.dta -d $(DATADIR)/source/enigh
	mv $(DATADIR)/source/enigh/trabajos.dta $$@
endef

# --- viviendas ---
define viviendas_rules
temp/enigh$(1)_v_dta.zip: | temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_viviendas_dta.zip -O $$@ || { echo "Failed to download $(1) viviendas"; exit 1; }

$(DATADIR)/source/enigh/viviendas$(1).dta: temp/enigh$(1)_v_dta.zip | $(DATADIR)/source/enigh
	unzip -o -j $$< viviendas.dta -d $(DATADIR)/source/enigh
	mv $(DATADIR)/source/enigh/viviendas.dta $$@
endef

# --- hogares ---
define hogares_rules
temp/enigh$(1)_h_dta.zip: | temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_hogares_dta.zip -O $$@ || { echo "Failed to download $(1) hogares"; exit 1; }

$(DATADIR)/source/enigh/hogares$(1).dta: temp/enigh$(1)_h_dta.zip | $(DATADIR)/source/enigh
	unzip -o -j $$< hogares.dta -d $(DATADIR)/source/enigh
	mv $(DATADIR)/source/enigh/hogares.dta $$@
endef

# --- erogaciones ---
define erogaciones_rules
temp/enigh$(1)_er_dta.zip: | temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_erogaciones_dta.zip -O $$@ || { echo "Failed to download $(1) erogaciones"; exit 1; }

$(DATADIR)/source/enigh/erogaciones$(1).dta: temp/enigh$(1)_er_dta.zip | $(DATADIR)/source/enigh
	unzip -o -j $$< erogaciones.dta -d $(DATADIR)/source/enigh
	mv $(DATADIR)/source/enigh/erogaciones.dta $$@
endef

# --- gastoshogar ---
define gastoshogar_rules
temp/enigh$(1)_gh_dta.zip: | temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_gastoshogar_dta.zip -O $$@ || { echo "Failed to download $(1) gastoshogar"; exit 1; }

$(DATADIR)/source/enigh/gastoshogar$(1).dta: temp/enigh$(1)_gh_dta.zip | $(DATADIR)/source/enigh
	unzip -o -j $$< gastoshogar.dta -d $(DATADIR)/source/enigh
	mv $(DATADIR)/source/enigh/gastoshogar.dta $$@
endef

# --- gastotarjetas ---
define gastotarjetas_rules
temp/enigh$(1)_gt_dta.zip: | temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_gastotarjetas_dta.zip -O $$@ || { echo "Failed to download $(1) gastotarjetas"; exit 1; }

$(DATADIR)/source/enigh/gastotarjetas$(1).dta: temp/enigh$(1)_gt_dta.zip | $(DATADIR)/source/enigh
	unzip -o -j $$< gastotarjetas.dta -d $(DATADIR)/source/enigh
	mv $(DATADIR)/source/enigh/gastotarjetas.dta $$@
endef

# --- gastospersona ---
define gastospersona_rules
temp/enigh$(1)_gp_dta.zip: | temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_gastospersona_dta.zip -O $$@ || { echo "Failed to download $(1) gastospersona"; exit 1; }

$(DATADIR)/source/enigh/gastospersona$(1).dta: temp/enigh$(1)_gp_dta.zip | $(DATADIR)/source/enigh
	unzip -o -j $$< gastospersona.dta -d $(DATADIR)/source/enigh
	mv $(DATADIR)/source/enigh/gastospersona.dta $$@
endef

# --- noagro ---
define noagro_rules
temp/enigh$(1)_na_dta.zip: | temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_noagro_dta.zip -O $$@ || { echo "Failed to download $(1) noagro"; exit 1; }

$(DATADIR)/source/enigh/noagro$(1).dta: temp/enigh$(1)_na_dta.zip | $(DATADIR)/source/enigh
	unzip -o -j $$< noagro.dta -d $(DATADIR)/source/enigh
	mv $(DATADIR)/source/enigh/noagro.dta $$@
endef

# --- agroproductos ---
define agroproductos_rules
temp/enigh$(1)_ap_dta.zip: | temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_agroproductos_dta.zip -O $$@ || { echo "Failed to download $(1) agroproductos"; exit 1; }

$(DATADIR)/source/enigh/agroproductos$(1).dta: temp/enigh$(1)_ap_dta.zip | $(DATADIR)/source/enigh
	unzip -o -j $$< agroproductos.dta -d $(DATADIR)/source/enigh
	mv $(DATADIR)/source/enigh/agroproductos.dta $$@
endef

# --- agrogasto ---
define agrogasto_rules
temp/enigh$(1)_ag_dta.zip: | temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_agrogasto_dta.zip -O $$@ || { echo "Failed to download $(1) agrogasto"; exit 1; }

$(DATADIR)/source/enigh/agrogasto$(1).dta: temp/enigh$(1)_ag_dta.zip | $(DATADIR)/source/enigh
	unzip -o -j $$< agrogasto.dta -d $(DATADIR)/source/enigh
	mv $(DATADIR)/source/enigh/agrogasto.dta $$@
endef

# --- noagroimportes ---
define noagroimportes_rules
temp/enigh$(1)_ni_dta.zip: | temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_noagroimportes_dta.zip -O $$@ || { echo "Failed to download $(1) noagroimportes"; exit 1; }

$(DATADIR)/source/enigh/noagroimportes$(1).dta: temp/enigh$(1)_ni_dta.zip | $(DATADIR)/source/enigh
	unzip -o -j $$< noagroimportes.dta -d $(DATADIR)/source/enigh
	mv $(DATADIR)/source/enigh/noagroimportes.dta $$@
endef

# --- ingresos_JCF ---
define ingresos_JCF_rules
temp/enigh$(1)_jcf_dta.zip: | temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_ingresos_JCF_dta.zip -O $$@ || { echo "Failed to download $(1) ingresos_JCF"; exit 1; }

$(DATADIR)/source/enigh/ingresos_JCF$(1).dta: temp/enigh$(1)_jcf_dta.zip | $(DATADIR)/source/enigh
	unzip -o -j $$< ingresos_jcf.dta -d $(DATADIR)/source/enigh
	mv $(DATADIR)/source/enigh/ingresos_jcf.dta $$@
endef

# =============================================================================
# GENERATE RULES FOR ALL YEARS
# =============================================================================

$(foreach year,$(YEARS),$(eval $(call concentradohogar_rules,$(year))))
$(foreach year,$(YEARS),$(eval $(call ingresos_rules,$(year))))
$(foreach year,$(YEARS),$(eval $(call poblacion_rules,$(year))))
$(foreach year,$(YEARS),$(eval $(call trabajos_rules,$(year))))
$(foreach year,$(YEARS),$(eval $(call viviendas_rules,$(year))))
$(foreach year,$(YEARS),$(eval $(call hogares_rules,$(year))))
$(foreach year,$(YEARS),$(eval $(call erogaciones_rules,$(year))))
$(foreach year,$(YEARS),$(eval $(call gastoshogar_rules,$(year))))
$(foreach year,$(YEARS),$(eval $(call gastospersona_rules,$(year))))
$(foreach year,$(YEARS),$(eval $(call noagro_rules,$(year))))
$(foreach year,$(YEARS_AGRO),$(eval $(call agroproductos_rules,$(year))))
$(foreach year,$(YEARS_AGRO),$(eval $(call agrogasto_rules,$(year))))
$(foreach year,$(YEARS_AGRO),$(eval $(call noagroimportes_rules,$(year))))
$(foreach year,$(YEARS_TARJETAS),$(eval $(call gastotarjetas_rules,$(year))))
$(foreach year,$(YEARS_JCF),$(eval $(call ingresos_JCF_rules,$(year))))

#################################################
############ Poverty Download Rules #############
#################################################

# CONEVAL poverty data (2016-2022)
define poverty_coneval_rules
temp/STATA_MMP_$(1).zip: | temp
	@if [ "$(1)" = "2022" ]; then \
		wget -c -O $$@ https://www.coneval.org.mx/Medicion/MP/Documents/MMP_2022/Programas_calculo/STATA_MMP_2022.zip; \
	elif [ "$(1)" = "2020" ]; then \
		wget -c -O $$@ https://www.coneval.org.mx/Medicion/MP/Documents/Programas_calculo_pobreza_MMP_20/STATA_MMP_2020.zip; \
	elif [ "$(1)" = "2018" ]; then \
		wget -c -O $$@ https://www.coneval.org.mx/Medicion/MP/Documents/Programas_calculo_pobreza_MMP_18/STATA_MMP_2018.zip; \
	elif [ "$(1)" = "2016" ]; then \
		wget -c -O $$@ https://www.coneval.org.mx/Medicion/MP/Documents/Programas_calculo_pobreza_MMP_16/STATA_MMP_2016.zip; \
	fi

$(DATADIR)/source/coneval/pobreza$(1).dta: temp/STATA_MMP_$(1).zip | $(DATADIR)/source/coneval
	unzip -j -o temp/STATA_MMP_$(1).zip "*/pobreza_*.dta" -d $(DATADIR)/source/coneval || \
		unzip -j -o temp/STATA_MMP_$(1).zip "Base final/pobreza_*.dta" -d $(DATADIR)/source/coneval
	mv $(DATADIR)/source/coneval/pobreza_*.dta $$@
endef

$(foreach year,$(YEARS_CONEVAL),$(eval $(call poverty_coneval_rules,$(year))))

# INEGI poverty data for 2024
temp/pm_algoritmo_stata.zip: | temp
	wget -c -O $@ https://www.inegi.org.mx/contenidos/desarrollosocial/pm/doc/pm_algoritmo_stata.zip

$(DATADIR)/source/coneval/pobreza2024.dta: temp/pm_algoritmo_stata.zip | $(DATADIR)/source/coneval
	unzip -j -o $< "*/pobreza_*.dta" -d $(DATADIR)/source/coneval || \
		unzip -j -o $< "pobreza_*.dta" -d $(DATADIR)/source/coneval || \
		unzip -j -o $< "*/pobreza*.dta" -d $(DATADIR)/source/coneval
	mv $(DATADIR)/source/coneval/pobreza*.dta $@ 2>/dev/null || mv $(DATADIR)/source/coneval/pobreza_*.dta $@

#################################################
############## Phony Targets ####################
#################################################

.PHONY: all download inpc enigh poverty clean help

clean:
	rm -rf temp

help:
	@echo "Available targets:"
	@echo "  all      - Build clean data (download if needed, then clean)"
	@echo "  download - Download all source data (INPC, ENIGH, poverty)"
	@echo "  clean    - Remove temp files"
