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

import re

from scrapy.contrib.spiders import CrawlSpider, Rule
from scrapy.contrib.linkextractors.sgml import SgmlLinkExtractor
from scrapy.selector import HtmlXPathSelector
from vaaliraapija.items import VaalirahoitusItem
from vaaliraapija.resources import vaalipiirit, puolueet

class VaaliraapijaSpider(CrawlSpider):
    name = "vaalirahoitusvalvonta.fi"
    allowed_domains = ["vaalirahoitusvalvonta.fi"]
    start_urls = [
        "http://www.vaalirahoitusvalvonta.fi/fi/index/vaalirahailmoituksia/ilmoituslistaus/EV2011.html"
    ]
    
    rules = (
        # Sallitaan ehdokaslinkit, mukana vain suomenkieliset sivut
        Rule(SgmlLinkExtractor(allow='^(http://www\.vaalirahoitusvalvonta\.fi/fi)\S+(/EV2011/[0-9]{2})\.html'), 
             follow=True),
        # Ehdokaslinkit parsitaan metodilla parse_ehdokas
        Rule(SgmlLinkExtractor(allow='^(http://)\S+(E_EI_EV2011\.html)'), 
             callback='parse_ehdokas', follow=False),
        )

    def parse_ehdokas(self, response):
        self.log('Prosessoidaan ehdokasta: %s' % response.url)
        
        # Ehdokkaan ennakkoilmoitussivulta parsitaan 2 ensimmäistä kohtaa. 
        # HTML:ssä kohdat erottuvat DIV-määreen "ann_form_table_basic" 
        # perusteella. response-oliosta tehdyn valintalistan (1. valinta) 
        # alkiot ovat seuraavat:
        # [0] A = Ilmoittajan tiedot
        # [1] B = Vaalikamppanjan kulujen ja rahoituksen yhteenveto
        # TODO: parsi loputkin alkiot -> mukana tarkempaa tietoa rahoituksen
        # yksityiskohdista
        
        hxs = HtmlXPathSelector(response)
        # 1. valinta
        data = hxs.select('//div[@class="ann_form_table_basic"]')
        item = VaalirahoitusItem()
        
        ## KOHTA A: Ilmoittajan tiedot #########################################
        
        # Ilmoittajan tiedot, valinnassa parsittavat tiedot löytyvät seuraavista
        # listan alkioista:
        # [0] = Sukunimi, etunimi
        # [1] = Ammatti
        # [2] = Puolue
        # [3] = Kotipaikka
        info = data[0].select('.//tr//td/text()').extract()
        # Sukunimi ja etunimi on erotettu pilkulla, erottele nimet
        names = info[0].split(',')
        # Poistetaan välilyönnit nimistä
        names = [name.strip() for name in names]
        
        item['sukunimi'] = names[0]
        item['etunimi'] = names[1]
        item['ammatti'] = info[1].strip()
        puolue = info[2].strip()
        item['puolue'] = puolue
        try:
            item['puolue_lyh'] = puolueet[puolue]
        except KeyError:
            item['puolue_lyh'] = u''
        item['kunta'] = info[3].strip()
        
        # Vaalipiiriä ei ole ilmoitettu sellaisenaan sivulla, joten irroitetaan
        # vaalipiirin numero sivun urlista ja haetaan vastaavaa vaalipiirin nimi
        district_id = response.url.split('/')[-3]
        item['vaalipiiri'] = vaalipiirit[district_id]
        
        ## KOHTA B: Vaalikampanjan kulujen ja rahoituksen yhteenveto ###########
        
        # Ehdokkaan ilmoitussivulla olevat euromäärät ovat kahdessa 
        # DIV-luokassa:
        # kulut yhteensä & rahoitus yhteensä ->  div="cell_light_blue number"
        #    [0] = Vaalikampanjan kulut yhteensä
        #    [1] = Vaalikampanjan rahoitus yhteensä
        # loput erittelyt 8 kpl -> div="number"
        #    [0] = Rahoitus sisältää omia varoja yhteensä
        #    [1] = Rahoitus sisältää ehdokkaan ja tukiryhmän ottamia lainoja yhteensä
        #    [2] = Rahoitus sisältää yksityishenkilöiltä saatua tukea yhteensä
        #    [3] = Rahoitus sisältää yrityksiltä saatua tukea yhteensä
        #    [4] = Rahoitus sisältää puolueelta saatua tukea yhteensä
        #    [5] = Rahoitus sisältää puolueyhdistyksiltä saatua tukea yhteensä
        #    [6] = Rahoitus sisältää muilta tahoilta saatua tukea yhteensä
        #    [7] = Rahoitus sisältää välitettyä tukea yhteensä
        
        yhteensa_euroja = data[1].select('.//td[@class="cell_light_blue number"]').extract()
        erittely_euroja = data[1].select('.//td[@class="number"]').extract()
         
        ## KOHTA C: Vaalikampanjan kulujen erittely ############################
        # Euromäärien irroittaminen samalla tavalla kuin kohdassa B
        # kulut yhteensä ->  div="cell_light_blue number"
        #    [0] = Vaalikampanjan kulut yhteensä
        #    HUOM: tätä ei tarvita, koska pitäisi olla sama kuin edellisestä
        #          saatava "vaalikampanjan kulut yhteensä"
        # loput erittelyt 8 kpl -> div="number"
        #    [0] = Sanoma, ilmaisjakelu- ja aikakauslehdet
        #    [1] = Radio
        #    [2] = Televisio
        #    [3] = Tietoverkot
        #    [4] = Muut viestintävälineet
        #    [5] = Ulkomainonta
        #    [6] = Vaalilehtien, esitteiden ja muun painetun materiaalin hankinta
        #    Vaalimainonta = [0:6]
        #    [7] = Mainonnan suunnittelu
        #    [8] = Vaalitilaisuudet
        #    [9] = Vastikkeellisen tuen hankintakulut
        #    [10] = Muut kulut
        
        # Ei tarvita
        #kulut_yhteensa_euroja = data[2].select('.//td[@class="cell_light_blue number"]').extract()
        kulut_erittely_euroja = data[2].select('.//td[@class="number"]').extract()
        
        def set_item(item, attr, luku):
            ''' Apufunktio, jolla asetetaan VaalirahoituItemin attribuutit 
            oikein.
            '''
            
            # Ehdokkaan ilmoitussivulla olevia euromääriä ei ole tallennettu 
            # taulukossa td-arvoina, vaan numerot liitetään sivudokumenttiin
            # JavaScript-funktiolla document.write(addSpaces(XXX)). XXX täytyy 
            # siis parsia irti funktiokutsusta -> käytetään regexiä 
            
            p = re.compile('(?<=addSpaces\()[0-9]+')
            # Etsitään kaikki regex-osumat
            # FIXME: onko findall tässä hyvä? Match ei palauttanut yhtään 
            # osumaa
            luku = p.findall(luku)
            if luku:
                # findall palautta lis	tan osumia, joita pitäisi olla vain 1
                # -> valitaan listan 1. alkio
                item[attr] = luku[0]
            else:
                # jos osumia ei ole, astetaan euromääräksi 0
                item[attr] = 0
        
        # Aseta VaalirahoitusItemin attribuutit
        set_item(item, 'kulut_kaikki', yhteensa_euroja[0])
        set_item(item, 'rahoitus_kaikki', yhteensa_euroja[1])
        set_item(item, 'omat_varat', erittely_euroja[0])
        set_item(item, 'lainat', erittely_euroja[1])
        set_item(item, 'yksityinen_tuki', erittely_euroja[2])
        set_item(item, 'yritys_tuki', erittely_euroja[3])
        set_item(item, 'puolue_tuki', erittely_euroja[4])
        set_item(item, 'puolueyhdistys_tuki', erittely_euroja[5])
        set_item(item, 'muu_tuki', erittely_euroja[6])
        set_item(item, 'valitetty_tuki', erittely_euroja[7])
        set_item(item, 'kulut_lehdet', kulut_erittely_euroja[0])
        set_item(item, 'kulut_radio', kulut_erittely_euroja[1])
        set_item(item, 'kulut_televisio', kulut_erittely_euroja[2])
        set_item(item, 'kulut_tietoverkot', kulut_erittely_euroja[3])
        set_item(item, 'kulut_muut_viestintavalineet', kulut_erittely_euroja[4])
        set_item(item, 'kulut_ulkomainonta', kulut_erittely_euroja[5])
        set_item(item, 'kulut_painettu_mat', kulut_erittely_euroja[6])
        set_item(item, 'kulut_mainonnan_suunnittelu', kulut_erittely_euroja[7])
        set_item(item, 'kulut_vaalitilaisuudet', kulut_erittely_euroja[8])
        set_item(item, 'kulut_tuen_hankintakulut', kulut_erittely_euroja[9])
        set_item(item, 'kulut_muut', kulut_erittely_euroja[10])
        
        return item