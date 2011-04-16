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

import os

DATADIR = os.path.abspath(os.path.join('../', 'aineisto'))

vaalipiirit = {'01': 'Helsingin vaalipiiri', 
               '02': 'Uudenmaan vaalipiiri', 
               '03': 'Varsinais-Suomen vaalipiiri', 
               '04': 'Satakunnan vaalipiiri', 
               '05': 'Ahvenanmaan maakunnan vaalipiiri',
               '06': 'Hämeen vaalipiiri',
               '07': 'Pirkanmaan vaalipiiri',
               '08': 'Kymen vaalipiiri', 
               '09': 'Etelä-Savon vaalipiiri', 
               '10': 'Pohjois-Savon vaalipiiri', 
               '11': 'Pohjois-Karjalan vaalipiiri', 
               '12': 'Vaasan vaalipiiri', 
               '13': 'Keski-Suomen vaalipiiri', 
               '14': 'Oulun vaalipiiri', 
               '15': 'Lapin vaalipiiri'} 

puolueet ={u'Suomen Sosialidemokraattinen Puolue': 'SDP',
           u'Suomen Keskusta r.p.': 'KESK',
           u'Kansallinen Kokoomus r.p.': 'KOK',
           u'Suomen ruotsalainen kansanpuolue r.p.': 'RKP',
           u'Suomen Kristillisdemokraatit (KD)': 'KD',
           u'Vihreä liitto r.p.': 'VIHR',
           u'Vasemmistoliitto r.p.': 'VAS',
           u'Perussuomalaiset r.p.': 'PS',
           u'Suomen Kommunistinen Puolue': 'SKP',
           u'Suomen Senioripuolue r.p.': 'SSP',
           u'Kommunistinen Työväenpuolue': 'KTP',
           u'Suomen Työväenpuolue STP r.p.': 'STP',
           u'Itsenäisyyspuolue r.p.': 'ITSP', 
           u'Köyhien Asialla r.p.': 'KOY',
           u'Piraattipuolue r.p.': 'PIR',
           u'Muutos 2011 r.p.': 'M11',
           u'Vapauspuolue (VP) - Suomen tulevaisuus r.p.': 'VP',
           u'Yhteislista sitoutumattomat': 'SIT'}