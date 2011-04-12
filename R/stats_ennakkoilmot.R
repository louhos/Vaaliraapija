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

if (!require("plyr")) {
  install.packages("plyr")
}

setwd('/home/jlehtoma/Dropbox/Code/vaalirahoitus/R/')

# Kaikki ehdokkaat
ehdokkaat <- read.csv('../aineisto/e2011ehd.csv',
                 header=TRUE, as.is=TRUE, sep="\t")
# Vaalirahoitustiedot
data <- read.csv('../aineisto/ennakkoilmoitus_2011-04-12T08-17-32.csv',
                 header=TRUE, as.is=TRUE, sep=",")
                 
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

# Puolue- ja vaalipiirikohtaiset tilastot
ehdokkaat.count.vpiiri <- ddply(ehdokkaat.isot, c("puolue_lyh", "vaalipiiri"),
                          function(df)length(df$ehdokasnumero))                       
colnames(ehdokkaat.count.vpiiri)[3] <- "ehdokkaita_tot"

# Puoluekohtaiset tilastot
data.puolueet <- ddply(data, 
                       c('puolue_lyh'), 
                       function(df)summarise(df, 
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
                                 muu_tuki = sum(df$muu_tuki)))
data.puolueet <- merge(data.puolueet, ehdokkaat.count.isot)
colnames(data.puolueet)[length(data.puolueet)] <- "ehdokkaita_tot"
# %-ilmoituksia kaikista ehdokkaista
data.puolueet$ilmoittaneita_pros <- round(data.puolueet$ilmoittaneita / 
                                          data.puolueet$ehdokkaita, 2)
data.puolueet$suht_rahoitus  <- round(data.puolueet$rahoitus_tot / 
                                      data.puolueet$ilmoittaneita,2)




# Laske puolue- ja vaalipiirikohtaiset ennakkoilmoitusprosentit
data.puolueet.vpiiri <- merge(ehdokkaat.count.vpiiri, data.count.vpiiri)
data.puolueet.vpiiri <- as.data.frame(cbind(data.puolueet.vpiiri[1:4],
   'ilmoittaneita_pros'=round(data.puolueet.vpiiri$ilmoittaneita / 
                                       data.puolueet.vpiiri$ehdokkaita_tot, 2)))

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
    labs(x="Ilmoitettu yritysrahoitus / ilmoittanut ehdokas", 
         y="Ennakkoilmoitusprosentti")