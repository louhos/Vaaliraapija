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

if (!require("ggplot2")) {
  install.packages("ggplot2")
}

if (!require("Deducer")) {
  install.packages("Deducer")
}

setwd('/home/jlehtoma/Dropbox/Code/vaalirahoitus/R/')

# Kaikki ehdokkaat
ehdokkaat <- read.csv('../aineisto/e2011ehd.csv',
                 header=TRUE, as.is=TRUE, sep="\t")
# Vaalirahoitustiedot
data <- read.csv('../aineisto/ennakkoilmoitus_2011-04-10T13-03-54.csv',
                 header=TRUE, as.is=TRUE, sep="\t")
                 
# Muunna puoluelyhenne ja vaalipiiri faktoreiksi
ehdokkaat$puolueen_lyhenne <- as.factor(ehdokkaat$puolue_lyh)
ehdokkaat$vaalipiiri <- as.factor(ehdokkaat$vaalipiiri)

data$puolue_lyh <- as.factor(data$puolue_lyh)
data$vaalipiiri <- as.factor(data$vaalipiiri)

# Laske puoluekohtaisia tilastoja
data.sum <- aggregate(rahoitus_kaikki~puolue_lyh, data, sum)
data.sum.yritys <- aggregate(yritys_tuki~puolue_lyh, data, sum)
data.count <- aggregate(etunimi~puolue_lyh, data, length)
ehdokkaat.count <- aggregate(ehdokasnumero~puolue_lyh, ehdokkaat, length)

# Ota mukaan vain yli 10 ehdokkaan puolueet
ehdokkaat.count.isot <- subset(ehdokkaat.count, ehdokasnumero >= 10)
ehdokkaat.isot <- subset(ehdokkaat, puolue_lyh %in% ehdokkaat.count.isot$puolue_lyh)
ehdokkaat.isot$puolueen_lyh <- as.factor(ehdokkaat.isot$puolue_lyh)
ehdokkaat.isot$vaalipiiri <- as.factor(ehdokkaat.isot$vaalipiiri)

# %-ilmoituksia kaikista ehdokkaista
data.puolueet <- merge(ehdokkaat.count.isot, data.count)
data.puolueet <- merge(data.puolueet, data.sum)
data.puolueet <- merge(data.puolueet, data.sum.yritys)
colnames(data.puolueet) <- c("puolue_lyh", "ehdokkaita", "ilmoittaneita",  
                              "tot_rahoitus", 'yritys_rahoitus')
data.puolueet <- as.data.frame(cbind(data.puolueet[1:3],
'ilmoittaneita_pros'=round(data.puolueet$ilmoittaneita / data.puolueet$ehdokkaita, 2),
                    data.puolueet[4],
'suht_rahoitus'=round(data.puolueet$tot_rahoitus / data.puolueet$ilmoittaneita,2),
                    data.puolueet[5],
'suht_yritys_rahoitus'=round(data.puolueet$yritys_rahoitus / data.puolueet$ilmoittaneita,2)))

# Ehdokkaita / puolue / vaalipiiri
ggplot(ehdokkaat.isot, aes(puolue_lyh, fill=vaalipiiri)) + geom_bar() + labs(x=NULL, y="Ehdokkaiden lkm")
ggplot(ehdokkaat.isot, aes(puolue_lyh)) + geom_bar() + facet_wrap(~ vaalipiiri) 

# Yritystuki
qplot(data.sum.yritys$puolue_lyh, data.sum.yritys$yritys_tuki, 
      geom="bar", stat="identity") 

# Ennakkoilmoituksia / puolue / vaalipiiri
ggplot(data, aes(data$puolue_lyh, fill=data$vaalipiiri)) + geom_bar()
# Ilmoitetut summat puolueittain ja vaalipiireittäin
qplot(data$puolue_lyh, data$rahoitus_kaikki, geom='bar', stat='identity',
      fill=data$vaalipiiri)
ggplot(ehdokkaat.isot, aes(puolue_lyh)) + geom_bar() + facet_wrap(~ vaalipiiri)

# Suhteellinen rahoitus ~ ennakkoilmoitusprosentti + kaikkien ehdokkaiden lkm
p <- ggplot(data.puolueet, aes(x=suht_rahoitus, y=ilmoittaneita_pros, 
            label=puolue_lyh)) 
p + geom_text(aes(size=ehdokkaita)) + scale_size(to=c(3,10)) + 
    labs(x="Ilmoitettu rahoitus / ilmoittanut ehdokas", 
         y="Ennakkoilmoitusprosentti")
         
# Suhteellinen yritysrahoitus ~ ennakkoilmoitusprosentti + kaikkien ehdokkaiden lkm
p <- ggplot(data.puolueet, aes(x=suht_yritys_rahoitus, y=ilmoittaneita_pros, 
            label=puolue_lyh)) 
p + geom_text(aes(size=ehdokkaita)) + scale_size(to=c(3,10)) + 
    labs(x="Ilmoitettu yritys rahoitus / ilmoittanut ehdokas", 
         y="Ennakkoilmoitusprosentti")