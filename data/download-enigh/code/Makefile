# =============================================================================
# REPLICATION FILE: data/raw/code/Makefile
# VERSION: zsh
# AUTHOR: Victor Alfonso Ortega Le Hénanff
# EMAIL: vincictor33@gmail.com
# DATE: 2026-02-11
# =============================================================================

# Combined Makefile for downloading all raw data sources
# INPC deflators, ENIGH surveys, and CONEVAL/INEGI poverty data

# Configuration
API_URL := https://en.www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/INDICATOR/910392/en/0700/false/BIE-BISE/2.0/d024134c-be50-03ee-bdf6-1cda05612673?type=json

YEARS := 2024 2022 2020 2018 2016
YEARS_CONEVAL := 2022 2020 2018 2016

# agroproductos, agrogasto, noagroimportes, ingresos_JCF only available 2020+
YEARS_AGRO := 2024 2022 2020
YEARS_JCF := 2024 2022 2020

# gastotarjetas available for all years
YEARS_TARJETAS := 2024 2022 2020 2018 2016

# All targets
all: inpc enigh poverty
	rm -rf ../temp

# INPC deflator data
inpc: ../output/inpc.json

# ENIGH survey data (original 5 + new tables)
enigh: $(foreach yr,$(YEARS), \
     ../output/concentradohogar$(yr).dta ../output/ingresos$(yr).dta \
     ../output/poblacion$(yr).dta ../output/trabajos$(yr).dta \
     ../output/viviendas$(yr).dta ../output/hogares$(yr).dta \
     ../output/erogaciones$(yr).dta ../output/gastoshogar$(yr).dta \
     ../output/gastospersona$(yr).dta ../output/noagro$(yr).dta) \
     $(foreach yr,$(YEARS_TARJETAS),../output/gastotarjetas$(yr).dta) \
     $(foreach yr,$(YEARS_AGRO),../output/agroproductos$(yr).dta ../output/agrogasto$(yr).dta ../output/noagroimportes$(yr).dta) \
     $(foreach yr,$(YEARS_JCF),../output/ingresos_JCF$(yr).dta)

# Poverty data (CONEVAL 2016–2022 + INEGI 2024)
poverty: $(addprefix ../output/, \
     pobreza2024.dta pobreza2022.dta pobreza2020.dta pobreza2018.dta pobreza2016.dta)

# Directory creation
../temp:
	mkdir -p ../temp

../input:
	mkdir -p ../input

../output:
	mkdir -p ../output

# =============================================================================
# INPC DEFLATOR RULES
# =============================================================================

../output/inpc.json: | ../output
	curl -L -o ../output/inpc.json $(API_URL)

# =============================================================================
# ENIGH SURVEY RULES — PER-TABLE TEMPLATES
# =============================================================================
# Each ENIGH table gets its own define block to match the exact wget/unzip
# pattern that INEGI expects. The server is sensitive to request format.

# --- concentradohogar ---
define concentradohogar_rules
../temp/enigh$(1)_dta.zip: | ../temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_concentradohogar_dta.zip -O $$@ || { echo "Failed to download $(1) concentradohogar"; exit 1; }

../output/concentradohogar$(1).dta: ../temp/enigh$(1)_dta.zip | ../output
	unzip -o -j $$< concentradohogar.dta -d ../output
	mv ../output/concentradohogar.dta $$@
endef

# --- ingresos ---
define ingresos_rules
../temp/enigh$(1)_i_dta.zip: | ../temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_ingresos_dta.zip -O $$@ || { echo "Failed to download $(1) ingresos"; exit 1; }

../output/ingresos$(1).dta: ../temp/enigh$(1)_i_dta.zip | ../output
	unzip -o -j $$< ingresos.dta -d ../output
	mv ../output/ingresos.dta $$@
endef

# --- poblacion ---
define poblacion_rules
../temp/enigh$(1)_p_dta.zip: | ../temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_poblacion_dta.zip -O $$@ || { echo "Failed to download $(1) poblacion"; exit 1; }

../output/poblacion$(1).dta: ../temp/enigh$(1)_p_dta.zip | ../output
	unzip -o -j $$< poblacion.dta -d ../output
	mv ../output/poblacion.dta $$@
endef

# --- trabajos ---
define trabajos_rules
../temp/enigh$(1)_t_dta.zip: | ../temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_trabajos_dta.zip -O $$@ || { echo "Failed to download $(1) trabajos"; exit 1; }

../output/trabajos$(1).dta: ../temp/enigh$(1)_t_dta.zip | ../output
	unzip -o -j $$< trabajos.dta -d ../output
	mv ../output/trabajos.dta $$@
endef

# --- viviendas ---
define viviendas_rules
../temp/enigh$(1)_v_dta.zip: | ../temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_viviendas_dta.zip -O $$@ || { echo "Failed to download $(1) viviendas"; exit 1; }

../output/viviendas$(1).dta: ../temp/enigh$(1)_v_dta.zip | ../output
	unzip -o -j $$< viviendas.dta -d ../output
	mv ../output/viviendas.dta $$@
endef

# --- hogares ---
define hogares_rules
../temp/enigh$(1)_h_dta.zip: | ../temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_hogares_dta.zip -O $$@ || { echo "Failed to download $(1) hogares"; exit 1; }

../output/hogares$(1).dta: ../temp/enigh$(1)_h_dta.zip | ../output
	unzip -o -j $$< hogares.dta -d ../output
	mv ../output/hogares.dta $$@
endef

# --- erogaciones ---
define erogaciones_rules
../temp/enigh$(1)_er_dta.zip: | ../temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_erogaciones_dta.zip -O $$@ || { echo "Failed to download $(1) erogaciones"; exit 1; }

../output/erogaciones$(1).dta: ../temp/enigh$(1)_er_dta.zip | ../output
	unzip -o -j $$< erogaciones.dta -d ../output
	mv ../output/erogaciones.dta $$@
endef

# --- gastoshogar ---
define gastoshogar_rules
../temp/enigh$(1)_gh_dta.zip: | ../temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_gastoshogar_dta.zip -O $$@ || { echo "Failed to download $(1) gastoshogar"; exit 1; }

../output/gastoshogar$(1).dta: ../temp/enigh$(1)_gh_dta.zip | ../output
	unzip -o -j $$< gastoshogar.dta -d ../output
	mv ../output/gastoshogar.dta $$@
endef

# --- gastotarjetas ---
define gastotarjetas_rules
../temp/enigh$(1)_gt_dta.zip: | ../temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_gastotarjetas_dta.zip -O $$@ || { echo "Failed to download $(1) gastotarjetas"; exit 1; }

../output/gastotarjetas$(1).dta: ../temp/enigh$(1)_gt_dta.zip | ../output
	unzip -o -j $$< gastotarjetas.dta -d ../output
	mv ../output/gastotarjetas.dta $$@
endef

# --- gastospersona ---
define gastospersona_rules
../temp/enigh$(1)_gp_dta.zip: | ../temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_gastospersona_dta.zip -O $$@ || { echo "Failed to download $(1) gastospersona"; exit 1; }

../output/gastospersona$(1).dta: ../temp/enigh$(1)_gp_dta.zip | ../output
	unzip -o -j $$< gastospersona.dta -d ../output
	mv ../output/gastospersona.dta $$@
endef

# --- noagro ---
define noagro_rules
../temp/enigh$(1)_na_dta.zip: | ../temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_noagro_dta.zip -O $$@ || { echo "Failed to download $(1) noagro"; exit 1; }

../output/noagro$(1).dta: ../temp/enigh$(1)_na_dta.zip | ../output
	unzip -o -j $$< noagro.dta -d ../output
	mv ../output/noagro.dta $$@
endef

# --- agroproductos ---
define agroproductos_rules
../temp/enigh$(1)_ap_dta.zip: | ../temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_agroproductos_dta.zip -O $$@ || { echo "Failed to download $(1) agroproductos"; exit 1; }

../output/agroproductos$(1).dta: ../temp/enigh$(1)_ap_dta.zip | ../output
	unzip -o -j $$< agroproductos.dta -d ../output
	mv ../output/agroproductos.dta $$@
endef

# --- agrogasto ---
define agrogasto_rules
../temp/enigh$(1)_ag_dta.zip: | ../temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_agrogasto_dta.zip -O $$@ || { echo "Failed to download $(1) agrogasto"; exit 1; }

../output/agrogasto$(1).dta: ../temp/enigh$(1)_ag_dta.zip | ../output
	unzip -o -j $$< agrogasto.dta -d ../output
	mv ../output/agrogasto.dta $$@
endef

# --- noagroimportes ---
define noagroimportes_rules
../temp/enigh$(1)_ni_dta.zip: | ../temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_noagroimportes_dta.zip -O $$@ || { echo "Failed to download $(1) noagroimportes"; exit 1; }

../output/noagroimportes$(1).dta: ../temp/enigh$(1)_ni_dta.zip | ../output
	unzip -o -j $$< noagroimportes.dta -d ../output
	mv ../output/noagroimportes.dta $$@
endef

# --- ingresos_JCF ---
define ingresos_JCF_rules
../temp/enigh$(1)_jcf_dta.zip: | ../temp
	wget https://www.inegi.org.mx/contenidos/programas/enigh/nc/$(1)/microdatos/enigh$(1)_ns_ingresos_JCF_dta.zip -O $$@ || { echo "Failed to download $(1) ingresos_JCF"; exit 1; }

../output/ingresos_JCF$(1).dta: ../temp/enigh$(1)_jcf_dta.zip | ../output
	unzip -o -j $$< ingresos_jcf.dta -d ../output
	mv ../output/ingresos_jcf.dta $$@
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

# =============================================================================
# POVERTY RULES
# =============================================================================

# CONEVAL poverty data (2016–2022)
define poverty_coneval_rules
../temp/STATA_MMP_$(1).zip: | ../temp
	@if [ "$(1)" = "2022" ]; then \
		wget -c -O $$@ https://www.coneval.org.mx/Medicion/MP/Documents/MMP_2022/Programas_calculo/STATA_MMP_2022.zip; \
	elif [ "$(1)" = "2020" ]; then \
		wget -c -O $$@ https://www.coneval.org.mx/Medicion/MP/Documents/Programas_calculo_pobreza_MMP_20/STATA_MMP_2020.zip; \
	elif [ "$(1)" = "2018" ]; then \
		wget -c -O $$@ https://www.coneval.org.mx/Medicion/MP/Documents/Programas_calculo_pobreza_MMP_18/STATA_MMP_2018.zip; \
	elif [ "$(1)" = "2016" ]; then \
		wget -c -O $$@ https://www.coneval.org.mx/Medicion/MP/Documents/Programas_calculo_pobreza_MMP_16/STATA_MMP_2016.zip; \
	fi

../output/pobreza$(1).dta: ../temp/STATA_MMP_$(1).zip | ../output
	unzip -j -o ../temp/STATA_MMP_$(1).zip "*/pobreza_*.dta" -d ../output || \
		unzip -j -o ../temp/STATA_MMP_$(1).zip "Base final/pobreza_*.dta" -d ../output
	mv ../output/pobreza_*.dta $$@
endef

$(foreach year,$(YEARS_CONEVAL),$(eval $(call poverty_coneval_rules,$(year))))

# INEGI poverty data for 2024 (same folder structure, different source)
../temp/pm_algoritmo_stata.zip: | ../temp
	wget -c -O $@ https://www.inegi.org.mx/contenidos/desarrollosocial/pm/doc/pm_algoritmo_stata.zip

../output/pobreza2024.dta: ../temp/pm_algoritmo_stata.zip | ../output
	unzip -j -o $< "*/pobreza_*.dta" -d ../output || \
		unzip -j -o $< "pobreza_*.dta" -d ../output || \
		unzip -j -o $< "*/pobreza*.dta" -d ../output
	mv ../output/pobreza*.dta $@ 2>/dev/null || mv ../output/pobreza_*.dta $@

# =============================================================================
# PHONY TARGETS
# =============================================================================

.PHONY: all inpc enigh poverty clean

clean:
	rm -rf ../temp

# Help target
help:
	@echo "Available targets:"
	@echo "  all     - Download all data (INPC, ENIGH, and poverty)"
	@echo "  inpc    - Download only INPC deflator data"
	@echo "  enigh   - Download only ENIGH survey data"
	@echo "  poverty - Download only poverty data (CONEVAL 2016-2022, INEGI 2024)"
	@echo "  clean   - Remove temp files"
	@echo ""
	@echo "ENIGH tables: concentradohogar ingresos poblacion trabajos viviendas"
	@echo "              hogares erogaciones gastoshogar gastospersona noagro"
	@echo "              agroproductos agrogasto noagroimportes gastotarjetas ingresos_JCF"
	@echo "Years: $(YEARS)"
	@echo "Years JCF: $(YEARS_JCF)"
	@echo "Years tarjetas: $(YEARS_TARJETAS)"