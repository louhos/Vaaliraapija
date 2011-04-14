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
import datetime

from rpy2 import robjects
from rpy2.robjects.packages import importr
from rpy2.robjects.vectors import DataFrame

from resources import DATADIR

base = importr("base")
graphics = importr("graphics")
stats = importr("stats")
utils = importr("utils")


if not base.require("plyr")[0]:
    utils.install_packages("plyr")
    
plyr = importr("plyr")

class VaaliData(object):
    
    def __init__(self, tiedosto, aika=None):
        if aika:
            self.aika = aika
        else:
            self.aika = datetime.datetime.now().isoformat()
        self._ilmoitukset = VaaliData.hae_ennakkoilmoitukset(tiedosto)
        self._ehdokkaat = VaaliData.hae_ehdokkaat()
        
    def ehdokas_tilastot(self, vaalipiiri=False):
        if vaalipiiri:
            return plyr.ddply(self._ehdokkaat, robjects.StrVector(['puolue_lyh', 
                                                                  'vaalipiiri']),
                              robjects.r('function(df)length(df$ehdokasnumero)'))
        else:
            kaava = robjects.Formula('ehdokasnumero ~ puolue_lyh')
            return stats.aggregate(kaava, self._ehdokkaat, robjects.r('length'))
        
    def gvis(self, file=None):
        googleVis = importr("googleVis")
        graafi = googleVis.gvisMotionChart(self.ilmoitus_tilastot(),
                                           idvar="puolue_lyh",
                                           timevar="vuosi")
        if not file:
            graphics.plot(graafi)
        else:
            gprint = robjects.r("print")
            gprint(graafi, file=file)
        
    def ilmoitus_tilastot(self, vaalipiiri=False):
        valinta = ["puolue_lyh",]
        if vaalipiiri:
            valinta.append("vaalipiiri")
        summat = robjects.r('''function(df)summarise(df, 
                                 ilmoittaneita = length(df$etunimi),
                                 rahoitus_tot = sum(df$rahoitus_kaikki),
                                 kulut_tot = sum(df$kulut_kaikki),
                                 omat_varat = sum(df$omat_varat),
                                 lainat = sum(df$lainat),
                                 yksityinen_tuki = sum(df$yksityinen_tuki),
                                 yritys_tuki = sum(df$yritys_tuki),
                                 puolue_tuki = sum(df$puolue_tuki),
                                 puolueyhdistys_tuki = sum(df$puolueyhdistys_tuki),
                                 valitettu_tuki = sum(df$valitetty_tuki),
                                 muu_tuki = sum(df$muu_tuki))
                                 ''')
        
        data_puolueet = plyr.ddply(self._ilmoitukset,  robjects.StrVector(valinta), summat)
        data_puolueet = base.merge(data_puolueet, 
                                   self.ehdokas_tilastot(vaalipiiri=vaalipiiri))
        data_puolueet.colnames[-1] = "ehdokkaita_tot"
        
        osuudet = robjects.r('function(a, b)return(a / b)')
        
        data_puolueet = data_puolueet.cbind(data_puolueet, 
                                    base.round(osuudet(data_puolueet.rx("ilmoittaneita"), 
                                    data_puolueet.rx("ehdokkaita_tot")), 2), 
                                    base.round(osuudet(data_puolueet.rx("rahoitus_tot"), 
                                    data_puolueet.rx("ilmoittaneita")), 2),
                                    robjects.IntVector([2011, ]))
        data_puolueet.colnames[-3] = "ilmoittaneita_pros"
        data_puolueet.colnames[-2] = "rahoitus_suht"
        data_puolueet.colnames[-1] = "vuosi"
        return data_puolueet

## Staattiset apumetodit #######################################################

    @staticmethod
    def hae_ehdokkaat():
        in_tiedosto = os.path.join(DATADIR, 'e2011ehd.csv')
        return DataFrame.from_csvfile(in_tiedosto, header=True, sep='\t', 
                                      as_is=True)
        
    @staticmethod
    def hae_ennakkoilmoitukset(tiedosto):
        if not os.path.exists(tiedosto):
            tiedosto = os.path.join(DATADIR, tiedosto)
            if not os.path.exists(tiedosto):
                raise IOError("Annettua tiedostoa %s ei löydy" % tiedosto)
        return DataFrame.from_csvfile(tiedosto, header=True, sep=',', 
                                      as_is=True)

if __name__ == '__main__':
    data = VaaliData('ennakkoilmoitus_2011-04-12T08-17-32.csv')
    #ehd = data.ehdokas_tilastot(vaalipiiri=True)
    #print(ehd)
    #print("DataFrame size is %s rows in %s cols" % (ehd.nrow, ehd.ncol))
    data.gvis("motionChart.html")