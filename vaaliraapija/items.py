#!/usr/bin/env python
# -*- coding: utf-8 -*-

#    VaaliRaapija - Yksinkertainen web scraper Vaalivalvontaviraston sivujen 
#                   raapimiseen
#    Tekijänoikeus (C) 2011 Joona Lehtomäki
#
# Tämä on vapaa ohjelma: tätä ohjelmaa saa levittää edelleen ja muuttaa Free 
# Software Foundationin julkaiseman GNU General Public Licensen (GPL-lisenssi) 
# version 3 tai (valinnan mukaan) myöhemmän version ehtojen mukaisesti
#
# Tätä ohjelmaa levitetään siinä toivossa, että se olisi hyödyllinen mutta 
# ILMAN MITÄÄN TAKUUTA; edes hiljaista takuuta KAUPALLISESTI HYVÄKSYTTÄVÄSTÄ 
# LAADUSTA tai SOVELTUVUUDESTA TIETTYYN TARKOITUKSEEN. Katso GPL-lisenssistä 
# lisää yksityiskohtia.
#
# Tämän ohjelman mukana pitäisi tulla kopio GPL-lisenssistä. Jos näin ei ole, 
# katso <http://www.gnu.org/licenses/>. 

from scrapy.item import Item, Field

class VaalirahoitusItem(Item):
    
    puolue = Field()
    puolue_lyh = Field()
    etunimi = Field()
    sukunimi = Field()
    ammatti = Field()
    kunta = Field()
    vaalipiiri = Field()
    
    # 1. Vaalikampanjan kulut yhteensä
    # 2. Vaalikampanjan rahoitus yhteensä
    # 2.1 Rahoitus sisältää omia varoja yhteensä
    # 2.2 Rahoitus sisältää ehdokkaan ja tukiryhmän ottamia lainoja yhteensä
    # 2.3 Rahoitus sisältää yksityishenkilöiltä saatua tukea yhteensä
    # 2.4 Rahoitus sisältää yrityksiltä saatua tukea yhteensä
    # 2.5 Rahoitus sisältää puolueelta saatua tukea yhteensä
    # 2.6 Rahoitus sisältää puolueyhdistyksiltä saatua tukea yhteensä
    # 2.7 Rahoitus sisältää muilta tahoilta saatua tukea yhteensä
    # 2.8 Rahoitus sisältää välitettyä tukea yhteensä
    
    kulut_kaikki = Field()
    rahoitus_kaikki = Field()
    omat_varat = Field()
    lainat = Field()
    yksityinen_tuki = Field()
    yritys_tuki = Field()
    puolue_tuki = Field()
    puolueyhdistys_tuki = Field()
    muu_tuki = Field()
    valitetty_tuki = Field()
    
    # C. Vaalikampanjan kulujen erittely
    # 1. Vaalikampanjan kulut yhteensä
    # Vaalimainonta
    #    - Sanoma, ilmaisjakelu- ja aikakauslehdet
    #    - Radio
    #    - Televisio
    #    - Tietoverkot
    #    - Muut viestintävälineet
    #    - Ulkomainonta
    #    - Vaalilehtien, esitteiden ja muun painetun materiaalin hankinta
    # Mainonnan suunnittelu
    # Vaalitilaisuudet
    # Vastikkeellisen tuen hankintakulut
    # Muut kulut
    
    kulut_lehdet = Field()
    kulut_radio = Field()
    kulut_televisio = Field()
    kulut_tietoverkot = Field()
    kulut_muut_viestintavalineet = Field()
    kulut_ulkomainonta = Field()
    kulut_painettu_mat = Field()
    kulut_mainonnan_suunnittelu = Field()
    kulut_vaalitilaisuudet = Field()
    kulut_tuen_hankintakulut = Field()
    kulut_muut = Field()