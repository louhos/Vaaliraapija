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

#data$puolue_lyh <- as.factor(data$puolue_lyh)
#data$vaalipiiri <- as.factor(data$vaalipiiri)

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
                                          data.puolueet$ehdokkaita_tot, 2)
data.puolueet$suht_rahoitus  <- round(data.puolueet$rahoitus_tot / 
                                      data.puolueet$ilmoittaneita,2)
data.puolueet$suht_yritys_rahoitus  <- round(data.puolueet$yritys_tuki / 
                                      data.puolueet$ilmoittaneita,2)


# Laske puolue- ja vaalipiirikohtaiset ennakkoilmoitusprosentit
data.puolueet.vpiiri <- ddply(data, 
                       c('puolue_lyh', 'vaalipiiri'), 
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

data.puolueet.vpiiri <- merge(data.puolueet.vpiiri, ehdokkaat.count.vpiiri)  
colnames(data.puolueet.vpiiri)[length(data.puolueet.vpiiri)] <- "ehdokkaita_tot"
# %-ilmoituksia kaikista ehdokkaista
data.puolueet.vpiiri$ilmoittaneita_pros <- round(data.puolueet.vpiiri$ilmoittaneita / 
                                          data.puolueet.vpiiri$ehdokkaita_tot, 2)
data.puolueet.vpiiri$suht_rahoitus  <- round(data.puolueet.vpiiri$rahoitus_tot / 
                                      data.puolueet.vpiiri$ilmoittaneita,2)
data.puolueet.vpiiri$suht_yritys_rahoitus  <- round(data.puolueet.vpiiri$yritys_tuki / 
                                      data.puolueet.vpiiri$ilmoittaneita,2)
# Puoluekohtaiset värit
# KD, KESK, KOK, KOY, M11, PIR, PS, RKP, SDP, SIT, SKP, VAS, VIHR, VP
colours <- c("KD" = "#5C7EB8", "KESK" = "#008700", "KOY" = "#36496B", 
             "M11" = "#1DB4E3", "PIR" = "#000000", "PS" = "#AD5700", 
             "RKP" = "#FBF000", "SDP" = "#AD0000", "SIT" = "#FFFFFF", 
             "SKP" = "#FF5500", "VAS" = "#FF0000", "VIHR" = "#00FF00", 
             "VP" = "#B3B000", "KOK" = "#0003A6")


# Ehdokkaita / puolue / vaalipiiri
ggplot(ehdokkaat.isot, aes(puolue_lyh, fill=vaalipiiri)) + geom_bar() + labs(x=NULL, y="Ehdokkaiden lkm")
ggplot(ehdokkaat.isot, aes(puolue_lyh)) + geom_bar() + facet_wrap(~ vaalipiiri)  

# Ennakkoilmoituksia / puolue / vaalipiiri
ggplot(data, aes(data$puolue_lyh, fill=data$vaalipiiri)) + geom_bar()
# Ilmoitetut summat puolueittain ja vaalipiireittäin
qplot(data$puolue_lyh, data$rahoitus_kaikki, geom='bar', stat='identity',
      fill=data$vaalipiiri)

# Ennakkoilmoitusprosentti / vaalipiiri
p <- ggplot(data.puolueet.vpiiri, aes(x=puolue_lyh, y=ilmoittaneita_pros, fill=puolue_lyh)) + 
       geom_bar(stat='identity') + facet_wrap(~ vaalipiiri) +
       opts(axis.text.x=theme_text(colour="white"), 
            axis.ticks=theme_segment(size=0)) + 
       labs(x="", y="Ennakkoilmoitusprosentti")
p + scale_fill_manual(values = colours)

# Isoimmat budjetit
rahakkaat  <- subset(data, rahoitus_kaikki >= 30000)
rahakkaat$kokonimi  <- paste(rahakkaat$etunimi, rahakkaat$sukunimi)
ggplot(rahakkaat) + geom_bar(aes(x=reorder(kokonimi, rahoitus_kaikki), 
                        y=rahoitus_kaikki, fill=puolue_lyh), stat='identity') + 
      opts(axis.text.x=theme_text(angle=90, hjust=1.0)) + 
      scale_fill_manual(values = colours) +
      labs(x="", y="Ilmoitettu rahoitus (€)") + coord_flip()
      
# Eniten yritystukea saaneet
yritys.rahakkaat  <- subset(data, yritys_tuki >= 3000)
yritys.rahakkaat$kokonimi  <- paste(yritys.rahakkaat$etunimi, 
                                    yritys.rahakkaat$sukunimi)
ggplot(yritys.rahakkaat) + geom_bar(aes(x=reorder(kokonimi, yritys_tuki), 
                        y=yritys_tuki, fill=puolue_lyh), stat='identity') + 
      opts(axis.text.x=theme_text(angle=90, hjust=1.0)) + 
      scale_fill_manual(values = colours) +
      labs(x="", y="Ilmoitettu yrityksiltä saatu tuki (€)") + coord_flip()

# Suhteellinen rahoitus ~ ennakkoilmoitusprosentti + kaikkien ehdokkaiden lkm
p <- ggplot(data.puolueet, aes(x=suht_rahoitus, y=ilmoittaneita_pros, 
            label=puolue_lyh)) 
p + geom_text(aes(size=ehdokkaita_tot)) + scale_size(to=c(4,8)) + 
    labs(x="Ilmoitettu rahoitus (€) / ilmoittanut ehdokas", 
         y="Ennakkoilmoitusprosentti") + 
         scale_y_continuous(breaks=c(seq(0.1, 1, 0.1)), 
                            labels=c('10%','20%','30%','40%','50%','60%','70%',
                                     '80%','90%','100%')) +
         scale_x_continuous(limits=c(0,30000))
                                     
ggsave("kuvaajat/suhteellinen_rahoitus.png", scale=0.75)

# Suhteellinen yritysrahoitus ~ ennakkoilmoitusprosentti + kaikkien ehdokkaiden lkm
p <- ggplot(data.puolueet, aes(x=suht_yritys_rahoitus, y=ilmoittaneita_pros, 
            label=puolue_lyh)) 
p + geom_text(aes(size=ehdokkaita_tot)) + scale_size(to=c(4,8)) + 
    labs(x="Ilmoitettu yritysrahoitus / ilmoittanut ehdokas", 
         y="Ennakkoilmoitusprosentti") + 
         scale_y_continuous(breaks=c(seq(0.1, 1, 0.1)), 
                            labels=c('10%','20%','30%','40%','50%','60%','70%',
                                     '80%','90%','100%')) +
         scale_x_continuous(limits=c(0,4000))