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
data <- read.csv('../aineisto/ennakkoilmoitus_2011-04-16T22-54-54.csv',
		header=TRUE, as.is=TRUE, sep=",")

# Tulokset
tulokset <- read.csv('../aineisto/tulokset_edvaalit2011.csv',
		header=TRUE, as.is=TRUE, sep=",")

# Datan korjaus
# 1. Astrid Thorsille on ilmoitettu 44,00 € vaalikampanjan kuluiksi, ositus
# summautuu 44 000 €
data[which(data$sukunimi == 'Thors'),]$rahoitus_kaikki  <- 44000
data[which(data$sukunimi == 'Thors'),]$kulut_kaikki  <- 44000

# 2. Eero Akaan-Penttilä on ilmoittanut 250 000, todellisuudessa 25 000
data[which(data$sukunimi == 'Akaan-Penttilä'),]$rahoitus_kaikki  <- 25000
data[which(data$sukunimi == 'Akaan-Penttilä'),]$kulut_kaikki  <- 25000
data[which(data$sukunimi == 'Akaan-Penttilä'),]$omat_varat  <- 20000

# Pyyntö A. Poikonen 16.4.2011:
# "Datan jatkokäsittelyä ja yhdistelyä muihin datoihin helpottaisi, jos 
# vaalirahoitusilmoitukset ehdokkaittain ja puolueittain ilmoitettaisiin 
# Oikeusministeriön julkaisemien täydellisten ehdokas- ja puoluelistausten 
# mukaisesti. Ne, jotka eivät ole ilmoittaneet näkyisivät datassa tyhjinä 
# riveinä.
# Ehdokkaita 2315 kpl
# Puolueita (valitsijayhdistyksen mukana) 32 kpl"

data.yhdistelma  <- data
colnames(data.yhdistelma)[7]  <- "nimietu"
colnames(data.yhdistelma)[26]  <- "mammatti"
# Otetaan mukaan vain 1. etunimi, jotta ulkoliitos ei tuota duplikaattirivejä
#f <- function(s) strsplit(s, " ")[[1]][1]
#data.yhdistelma$etunimi  <- sapply(data.yhdistelma$etunimi, f)
# FIXME: ei toimi täysin, koska ehdokkaat saattavat käyttää toista nimeään 
# kutsumanimenä -> syntyy duplikaattirivejä. Pitäisi perata käsin.
data.yhdistelma  <- merge(ehdokkaat, data.yhdistelma, all=TRUE)
write.csv(data.yhdistelma, '../aineisto/data_yhdistelmä.csv')

data = data[which(data$puolue_lyh != ""),]

# Kaikki ehdokkaat eivät ole ilmoittaneet vaalikampanjan rahoituksen summaa
# jat/tai kuluja vaan ainoastaan erittelyt -> lasketaan erittelyt yhteen
# HUOM välitettyä tukea ei lasketa mukaan
data$rahoitus_kaikki_johdettu <- data$omat_varat + data$lainat + 
		data$yksityinen_tuki + data$yritys_tuki +
		data$puolue_tuki + data$puolueyhdistys_tuki +
		data$muu_tuki

data$kulut_kaikki_johdettu <- data$kulut_muut + data$kulut_muut_viestintavalineet +
		data$kulut_vaalitilaisuudet + data$kulut_radio +
		data$kulut_tietoverkot + data$kulut_televisio +
		data$kulut_painettu_mat + data$kulut_tuen_hankintakulut +
		data$kulut_mainonnan_suunnittelu + 
		data$kulut_ulkomainonta + data$kulut_lehdet

# Korjaa kokonaisrahoitus jos johdettu tieto on olemassa ja summailmoitus puuttuu
data$rahoitus_kaikki  <- ifelse(data$rahoitus_kaikki == 0, 
		data$rahoitus_kaikki_johdettu,
		data$rahoitus_kaikki)

data$kulut_kaikki  <- ifelse(data$kulut_kaikki == 0, 
		data$kulut_kaikki_johdettu,
		data$kulut_kaikki)

data$rahoitus_tase  <-  data$rahoitus_kaikki - data$kulut_kaikki

# Kulujen erittelyn erotus ilmoitetusta kokonaiskuluista -> mikä selittää? 
# A) taulukkoon sopimattomat rahoituslähteet, B) virhe, C) alle 1500 euron
# yksityislahjoitukset

data$rahoitus_selittamaton <- data$rahoitus_kaikki - data$rahoitus_kaikki_johdettu
data$kulut_selittamaton <- data$kulut_kaikki - data$kulut_kaikki_johdettu

# Vaalimainonnan summa
data$kulut_vaalimainonta  <- data$kulut_lehdet + data$kulut_radio + 
		data$kulut_televisio + data$kulut_tietoverkot +
		data$kulut_muut_viestintavalineet +
		data$kulut_ulkomainonta + data$kulut_painettu_mat

# Omavaraisuusaste
data$omav_aste <- data$omat_varat / data$rahoitus_kaikki

# Laske puoluekohtaisia tilastoja
data.sum <- aggregate(rahoitus_kaikki~puolue_lyh, data, sum)
data.sum.yritys <- aggregate(yritys_tuki~puolue_lyh, data, sum)
data.count <- aggregate(etunimi~puolue_lyh, data, length)
ehdokkaat.count <- aggregate(ehdokasnumero~puolue_lyh, ehdokkaat, length)

# Ota mukaan vain yli 10 ehdokkaan puolueet
#ehdokkaat.count.isot <- subset(ehdokkaat.count, ehdokasnumero >= 10)
#ehdokkaat.isot <- subset(ehdokkaat, puolue_lyh %in% ehdokkaat.count.isot$puolue_lyh)
#ehdokkaat.isot$puolueen_lyh <- as.factor(ehdokkaat.isot$puolue_lyh)
#ehdokkaat.isot$vaalipiiri <- as.factor(ehdokkaat.isot$vaalipiiri)

# Puolue- ja vaalipiirikohtaiset tilastot
ehdokkaat.count.vpiiri <- ddply(ehdokkaat, c("puolue_lyh", "vaalipiiri"),
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
					muu_tuki = sum(df$muu_tuki),
					vaalimainonta = sum(df$kulut_vaalimainonta),
					vaalimainonta_suunnittelu = sum(df$kulut_mainonnan_suunnittelu),
					omav_aste = mean(df$omav_aste)))

data.puolueet <- merge(data.puolueet, ehdokkaat.count)	
colnames(data.puolueet)[length(data.puolueet)] <- "ehdokkaita_tot"
# %-ilmoituksia kaikista ehdokkaista
data.puolueet$ilmoittaneita_pros <- round(data.puolueet$ilmoittaneita / 
				data.puolueet$ehdokkaita_tot, 2)
data.puolueet$suht_rahoitus  <- round(data.puolueet$rahoitus_tot / 
				data.puolueet$ilmoittaneita,2)
data.puolueet$suht_yritys_rahoitus  <- round(data.puolueet$yritys_tuki / 
				data.puolueet$ilmoittaneita,2)
# Suhteellinen vaalimainonta
data.puolueet$suht_vaalimainonta <- round(data.puolueet$vaalimainonta / 
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

# Tulokset
isot  <- c("KOK", "SDP", "PS", "KESK", "VAS", "VIHR")
tulokset.data <- merge(tulokset, data.puolueet)
tulokset.data <- subset(tulokset.data, puolue_lyh %in% isot)
#tulokset.data$ilmoittaneita_pros  <- tulokset.data$ilmoittaneita_pros * 100
aanet  <- data.frame(puolue_lyh=tulokset.data$puolue_lyh, z=tulokset.data$aani_pros, 
		panel="Kannatusprosentti")
aanet  <- arrange(aanet, desc(z))
ilmot  <- data.frame(puolue_lyh=tulokset.data$puolue_lyh, z=tulokset.data$ilmoittaneita_pros, 
		panel="Ennakkoilmoitusprosentti")
ilmot  <- arrange(ilmot, z)
d <- rbind(aanet, ilmot)
ggplot(d, aes(x=reorder(puolue_lyh, z), y=z, fill=puolue_lyh)) + 
		geom_bar(stat='identity') + facet_wrap(~ panel, scale="free", nrow=2, 
				ncol=1) +
		scale_fill_manual(values = colours) +
		labs(x="", y="%")
ggsave("kuvaajat/tulokset_prossat.png", width=10.417, height=8.333, dpi=72)

# Puoluekohtaiset värit
# KD, KESK, KOK, KOY, M11, PIR, PS, RKP, SDP, SIT, SKP, VAS, VIHR, VP
colours <- c("KD" = "#5C7EB8", "KESK" = "#008700", "KOY" = "#36496B", 
		"M11" = "#1DB4E3", "PIR" = "#000000", "PS" = "#AD5700", 
		"RKP" = "#FBF000", "SDP" = "#AD0000", "SIT" = "#FFFFFF", 
		"SKP" = "#FF5500", "VAS" = "#FF0000", "VIHR" = "#00FF00", 
		"VP" = "#B3B000", "KOK" = "#0003A6", "STP" = "#333333",
		"ITSP" = "#FF6699", "SSP" = "#330033")


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

## PERUSTILASTOT ###############################################################

data$kokonimi  <- paste(data$etunimi, data$sukunimi)

# Funktio, jolla voi plotata DataFrame (data) tilastoja EI TOIMI
plottaa.tilastot  <- function(x, sarake, raja, y.otsake) {
	
	rajaus  <- subset(x, sarake >= raja)
	browser()
	ggplot(rajaus) + geom_bar(aes(x=reorder(kokonimi, sarake), 
							y=sarake, fill=puolue_lyh), stat='identity') + 
			opts(axis.text.x=theme_text(angle=90, hjust=1.0)) + 
			scale_fill_manual(values = colours) +
			labs(x="", y=y.otsake) + coord_flip()
}

plottaa.tilastot(data, sarake=data$rahoitus_kaikki, 30000, "Ilmoitettu rahoitus (€)")

# Isoimmat budjetit
rahakkaat  <- subset(data, rahoitus_kaikki >= 40000)
rahakkaat$kokonimi  <- paste(rahakkaat$etunimi, rahakkaat$sukunimi)
ggplot(rahakkaat) + geom_bar(aes(x=reorder(kokonimi, rahoitus_kaikki), 
						y=rahoitus_kaikki, fill=puolue_lyh), stat='identity') + 
		opts(axis.text.x=theme_text(angle=90, hjust=1.0, size=10),
				axis.text.y=theme_text(hjust=1.0, size=12, colour="#7F7F7F"),
				axis.title.x = theme_text(family = "sans", size=16),
				legend.title = theme_text(family = "sans", size=12, hjust=0)) + 
		scale_fill_manual(values = colours) +
		labs(x="", y="Ilmoitettu rahoitus (€)") + coord_flip()
ggsave("kuvaajat/isoimmat_budjetit.png", width=10.417, height=8.333, dpi=72)

# Isoimmat omat varat
rahakkaat.omat  <- subset(data, omat_varat >= 23000)
rahakkaat.omat$kokonimi  <- paste(rahakkaat.omat$etunimi, rahakkaat.omat$sukunimi)
ggplot(rahakkaat.omat) + geom_bar(aes(x=reorder(kokonimi, omat_varat), 
						y=omat_varat, fill=puolue_lyh), stat='identity') + 
		opts(axis.text.x=theme_text(angle=90, hjust=1.0, size=10),
				axis.text.y=theme_text(hjust=1.0, size=12, colour="#7F7F7F"),
				axis.title.x = theme_text(family = "sans", size=16),
				legend.title = theme_text(family = "sans", size=12, hjust=0)) + 
		scale_fill_manual(values = colours) +
		labs(x="", y="Ilmoitetut omat varat (€)") + coord_flip()
ggsave("kuvaajat/isoimmat_omat_varat.png", width=10.417, height=8.333, dpi=72)

# Eniten yksityistukea saaneet
yksityis.rahakkaat  <- subset(data, yksityinen_tuki >= 9000)
yksityis.rahakkaat$kokonimi  <- paste(yksityis.rahakkaat$etunimi, 
		yksityis.rahakkaat$sukunimi)
ggplot(yksityis.rahakkaat) + geom_bar(aes(x=reorder(kokonimi, yksityinen_tuki), 
						y=yksityinen_tuki, fill=puolue_lyh), stat='identity') + 
		opts(axis.text.x=theme_text(angle=90, hjust=1.0, size=10),
				axis.text.y=theme_text(hjust=1.0, size=12, colour="#7F7F7F"),
				axis.title.x = theme_text(family = "sans", size=16),
				legend.title = theme_text(family = "sans", size=12, hjust=0)) + 
		scale_fill_manual(values = colours) +
		labs(x="", y="Ilmoitettu yksiyishenkilöiltä saatu tuki (€)") + coord_flip()
ggsave("kuvaajat/isoimmat_yksityis_tuet.png", width=10.417, height=8.333, dpi=72)

# Eniten yritystukea saaneet
yritys.rahakkaat  <- subset(data, yritys_tuki >= 10000)
yritys.rahakkaat$kokonimi  <- paste(yritys.rahakkaat$etunimi, 
		yritys.rahakkaat$sukunimi)
ggplot(yritys.rahakkaat) + geom_bar(aes(x=reorder(kokonimi, yritys_tuki), 
						y=yritys_tuki, fill=puolue_lyh), stat='identity') + 
		opts(axis.text.x=theme_text(angle=90, hjust=1.0, size=10),
				axis.text.y=theme_text(hjust=1.0, size=12, colour="#7F7F7F"),
				axis.title.x = theme_text(family = "sans", size=16),
				legend.title = theme_text(family = "sans", size=12, hjust=0)) + 
		scale_fill_manual(values = colours) +
		labs(x="", y="Ilmoitettu yrityksiltä saatu tuki (€)") + coord_flip()
ggsave("kuvaajat/isoimmat_yritys_tuet.png", width=10.417, height=8.333, dpi=72)

# Muu tuki
muu.rahakkaat  <- subset(data, muu_tuki >= 7000)
muu.rahakkaat$kokonimi  <- paste(muu.rahakkaat$etunimi, 
		muu.rahakkaat$sukunimi)
ggplot(muu.rahakkaat) + geom_bar(aes(x=reorder(kokonimi, muu_tuki), 
						y=muu_tuki, fill=puolue_lyh), stat='identity') + 
		opts(axis.text.x=theme_text(angle=90, hjust=1.0, size=10),
				axis.text.y=theme_text(hjust=1.0, size=12, colour="#7F7F7F"),
				axis.title.x = theme_text(family = "sans", size=16),
				legend.title = theme_text(family = "sans", size=12, hjust=0)) + 
		scale_fill_manual(values = colours) +
		labs(x="", y="Ilmoitettu muu tuki (€)") + coord_flip()
ggsave("kuvaajat/isoimmat_muut_tuet.png", width=10.417, height=8.333, dpi=72)

# Lainat
laina.rahakkaat  <- subset(data, lainat >= 9000)
laina.rahakkaat$kokonimi  <- paste(laina.rahakkaat$etunimi, 
		laina.rahakkaat$sukunimi)
ggplot(laina.rahakkaat) + geom_bar(aes(x=reorder(kokonimi, lainat), 
						y=lainat, fill=puolue_lyh), stat='identity') + 
		opts(axis.text.x=theme_text(angle=90, hjust=1.0, size=10),
				axis.text.y=theme_text(hjust=1.0, size=12, colour="#7F7F7F"),
				axis.title.x = theme_text(family = "sans", size=16),
				legend.title = theme_text(family = "sans", size=12, hjust=0)) + 
		scale_fill_manual(values = colours) +
		labs(x="", y="Ehdokkaan ja tukiryhmien lainat (€)") + coord_flip()
ggsave("kuvaajat/isoimmat_lainat.png", width=10.417, height=8.333, dpi=72)

# Puoluetuki
puoluetuki.rahakkaat  <- subset(data, puolue_tuki >= 1500)
puoluetuki.rahakkaat$kokonimi  <- paste(puoluetuki.rahakkaat$etunimi, 
		puoluetuki.rahakkaat$sukunimi)
ggplot(puoluetuki.rahakkaat) + geom_bar(aes(x=reorder(kokonimi, puolue_tuki), 
						y=puolue_tuki, fill=puolue_lyh), stat='identity') + 
		opts(axis.text.x=theme_text(angle=90, hjust=1.0, size=10),
				axis.text.y=theme_text(hjust=1.0, size=12, colour="#7F7F7F"),
				axis.title.x = theme_text(family = "sans", size=16),
				legend.title = theme_text(family = "sans", size=12, hjust=0)) +
		scale_fill_manual(values = colours) +
		labs(x="", y="Ehdokkaan puolueelta saatu tuki  (€)") + coord_flip()
ggsave("kuvaajat/isoimmat_puoluetuet.png", width=10.417, height=8.333, dpi=72)

# Vaalimainonta
vaalimainonta.rahakkaat  <- subset(data, kulut_vaalimainonta >= 33000)
vaalimainonta.rahakkaat$kokonimi  <- paste(vaalimainonta.rahakkaat$etunimi, 
		vaalimainonta.rahakkaat$sukunimi)
ggplot(vaalimainonta.rahakkaat) + geom_bar(aes(x=reorder(kokonimi, kulut_vaalimainonta), 
						y=kulut_vaalimainonta, fill=puolue_lyh), stat='identity') + 
		opts(axis.text.x=theme_text(angle=90, hjust=1.0, size=10),
				axis.text.y=theme_text(hjust=1.0, size=12, colour="#7F7F7F"),
				axis.title.x = theme_text(family = "sans", size=16),
				legend.title = theme_text(family = "sans", size=12, hjust=0)) + 
		scale_fill_manual(values = colours) +
		labs(x="", y="Ehdokkaan vaalimainontaan käyttämä raha (€)") + coord_flip()
ggsave("kuvaajat/isoimmat_vaalimainonta.png", width=10.417, height=8.333, dpi=72)

# Rahoitustaseet

alijaam  <- subset(data, rahoitus_tase < -200)
alijaam$kokonimi  <- paste(alijaam$etunimi, alijaam$sukunimi)
ggplot(alijaam) + geom_bar(aes(x=reorder(kokonimi, desc(rahoitus_tase)), 
						y=rahoitus_tase, fill=puolue_lyh), stat='identity') + 
		opts(axis.text.x=theme_text(angle=90, hjust=1.0, size=10),
				axis.text.y=theme_text(hjust=1.0, size=12, colour="#7F7F7F"),
				axis.title.x = theme_text(family = "sans", size=16),
				legend.title = theme_text(family = "sans", size=12, hjust=0)) + 
		scale_fill_manual(values = colours) +
		labs(x="", y="Ehdokkaan rahoituksen alijäämä (€)") + coord_flip()
ggsave("kuvaajat/isoimmat_alijäämät.png", width=10.417, height=8.333, dpi=72)

# HUOM ylijäämää voi johtua myös siitä, ettei kuluja ole ilmoitettu

ylijaam  <- subset(data, rahoitus_tase > 900)
ylijaam$kokonimi  <- paste(ylijaam$etunimi, ylijaam$sukunimi)
ggplot(ylijaam) + geom_bar(aes(x=reorder(kokonimi, rahoitus_tase), 
						y=rahoitus_tase, fill=puolue_lyh), stat='identity') + 
		opts(axis.text.x=theme_text(angle=90, hjust=1.0, size=10),
				axis.text.y=theme_text(hjust=1.0, size=12, colour="#7F7F7F"),
				axis.title.x = theme_text(family = "sans", size=16),
				legend.title = theme_text(family = "sans", size=12, hjust=0)) + 
		scale_fill_manual(values = colours) +
		labs(x="", y="Ehdokkaan rahoituksen ylijäämä (€)") + coord_flip()
ggsave("kuvaajat/isoimmat_ylijäämät.png", width=10.417, height=8.333, dpi=72)

# Erittelemätön rahoitus

erittelematon_rahoitus  <- subset(data, rahoitus_selittamaton > 4000)
erittelematon_rahoitus$kokonimi  <- paste(erittelematon_rahoitus$etunimi, 
		erittelematon_rahoitus$sukunimi)
ggplot(erittelematon_rahoitus) + geom_bar(aes(x=reorder(kokonimi, rahoitus_selittamaton), 
						y=rahoitus_selittamaton, fill=puolue_lyh), stat='identity') + 
		opts(axis.text.x=theme_text(angle=90, hjust=1.0, size=10),
				axis.text.y=theme_text(hjust=1.0, size=12, colour="#7F7F7F"),
				axis.title.x = theme_text(family = "sans", size=16),
				legend.title = theme_text(family = "sans", size=12, hjust=0)) + 
		scale_fill_manual(values = colours) +
		labs(x="", y="Ehdokkaan erittelemätön rahoitus (€)") + coord_flip()
ggsave("kuvaajat/isoimmat_erittelematon_rahoitus.png", width=10.417, height=8.333, dpi=72)

# Erittelemättömät kulut

erittelematon_kulut  <- subset(data, kulut_selittamaton > 4500)
erittelematon_kulut$kokonimi  <- paste(erittelematon_kulut$etunimi, 
		erittelematon_kulut$sukunimi)
ggplot(erittelematon_kulut) + geom_bar(aes(x=reorder(kokonimi, kulut_selittamaton), 
						y=kulut_selittamaton, fill=puolue_lyh), stat='identity') + 
		opts(axis.text.x=theme_text(angle=90, hjust=1.0, size=10),
				axis.text.y=theme_text(hjust=1.0, size=12, colour="#7F7F7F"),
				axis.title.x = theme_text(family = "sans", size=16),
				legend.title = theme_text(family = "sans", size=12, hjust=0)) + 
		scale_fill_manual(values = colours) +
		labs(x="", y="Ehdokkaan erittelemättömät kulut (€)") + coord_flip()
ggsave("kuvaajat/isoimmat_erittelematon_kulut.png", width=10.417, height=8.333, dpi=72)

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
		scale_x_continuous(limits=c(0,5000))
ggsave("kuvaajat/suhteellinen_yritys_rahoitus.png", scale=0.75)

# Vaalimainonta
p <- ggplot(data.puolueet, aes(x=vaalimainonta, y=ilmoittaneita_pros, 
				label=puolue_lyh)) 
p + geom_text(aes(size=ehdokkaita_tot)) + scale_size(to=c(4,8)) + 
		labs(x="Vaalimainontaan käytetty raha (€)", 
				y="Ennakkoilmoitusprosentti") + 
		scale_y_continuous(breaks=c(seq(0.1, 1, 0.1)), 
				labels=c('10%','20%','30%','40%','50%','60%','70%',
						'80%','90%','100%')) +
		scale_x_continuous(limits=c(0,2000000))
ggsave("kuvaajat/absoluuttinen_vaalimainonta.png", scale=0.75)

p <- ggplot(data.puolueet, aes(x=suht_vaalimainonta, y=ilmoittaneita_pros, 
				label=puolue_lyh)) 
p + geom_text(aes(size=ehdokkaita_tot)) + scale_size(to=c(4,8)) + 
		labs(x="Vaalimainontaan käytetty raha (€) / ilmoittanut ehdokas", 
				y="Ennakkoilmoitusprosentti") + 
		scale_y_continuous(breaks=c(seq(0.1, 1, 0.1)), 
				labels=c('10%','20%','30%','40%','50%','60%','70%',
						'80%','90%','100%')) +
		scale_x_continuous(limits=c(0,20000))
ggsave("kuvaajat/suhteellinen_vaalimainonta.png", scale=0.75)

# Omavaraisuus

data.omav  <- subset(data, !is.na(omav_aste) & is.finite(omav_aste))
p <- ggplot(data.omav, aes(rahoitus_kaikki, omav_aste, colour=factor(puolue_lyh))) + 
		scale_colour_manual(values = colours) + 
		scale_y_continuous(breaks=c(seq(0.1, 1, 0.1)), 
				labels=c('10%','20%','30%','40%','50%','60%','70%',
						'80%','90%','100%'),
				limits=c(0, 1))
p + geom_point()

budjetti.nolla  <- data[which(data$rahoitus_kaikki < 1000),]
budjetti.nolla.puolueet <- ddply(budjetti.nolla, c('puolue_lyh'), 
		function(df)summarise(df, 
					matala_budjetti = length(df$etunimi)))
budjetti.nolla.puolueet <- merge(data.puolueet, budjetti.nolla.puolueet)
budjetti.nolla.puolueet$matala_budjetti_suht  <- round(budjetti.nolla.puolueet$matala_budjetti / 
				budjetti.nolla.puolueet$ilmoittaneita, 2)


ggplot(budjetti.nolla.puolueet) + geom_bar(aes(x=reorder(puolue_lyh, desc(matala_budjetti)), 
						y=matala_budjetti, fill=puolue_lyh), stat='identity') + 
		opts(axis.text.x=theme_text(angle=90, hjust=1.0, size=10),
				axis.text.y=theme_text(hjust=0.5, size=12, colour="#7F7F7F"),
				axis.title.x = theme_text(family = "sans", size=16),
				legend.title = theme_text(family = "sans", size=12, hjust=0)) + 
		scale_fill_manual(values = colours) +
		labs(x="", y="Pienen budjetin (< 1000 €) kampanjoiden lukumäärä")
ggsave("kuvaajat/pienet_budjetit.png", width=10.417, height=8.333, dpi=72)

p <- ggplot(budjetti.nolla.puolueet, aes(x=matala_budjetti_suht, y=ilmoittaneita_pros, 
				label=puolue_lyh)) 
p + geom_text(aes(size=ehdokkaita_tot)) + scale_size(to=c(4,8)) + 
		labs(x="Pienen budjetin (< 1000 €) kampanjoiden osuus", 
				y="Ennakkoilmoitusprosentti") + 
		scale_y_continuous(breaks=c(seq(0.1, 1, 0.1)), 
				labels=c('10%','20%','30%','40%','50%','60%','70%',
						'80%','90%','100%')) +
		scale_x_continuous(breaks=c(seq(0, 1, 0.1)), 
				labels=c('0%','10%','20%','30%','40%','50%','60%','70%',
						'80%','90%','100%'), limits=c(-.05, 1))
ggsave("kuvaajat/pienet_budjetit_suhteessa.png", scale=0.75)

# GoogleVis
library(googleVis)
data.puolueet$vuosi  <- 2011
m  <- gvisMotionChart(data.puolueet, idvar="puolue_lyh", timevar="vuosi",
		options=list(width=1000, height=800))
plot(m)
print(m, file="motionChart.html")