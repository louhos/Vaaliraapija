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

BOT_NAME = 'vaaliraapija'
BOT_VERSION = '1.0'

SPIDER_MODULES = ['vaaliraapija.spiders']
NEWSPIDER_MODULE = 'vaaliraapija.spiders'
DEFAULT_ITEM_CLASS = 'vaaliraapija.items.VaalirahoitusItem'
USER_AGENT = '%s/%s' % (BOT_NAME, BOT_VERSION)

