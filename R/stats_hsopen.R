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

## DATAN SISÄÄNLUKU ############################################################

setwd('/home/jlehtoma/Dropbox/Code/vaalirahoitus/R/')

# Kaikki ehdokkaat
ehdokkaat <- read.csv('../aineisto/e2011ehd.csv',
		header=TRUE, as.is=TRUE, sep="\t")

# Vaalirahoitustiedot (versio: Jens Finnäs)
data <- read.csv('../aineisto/raavitut/finnas/menot2011.csv',
		header=TRUE, as.is=TRUE, sep=";")

# Tulokset puoluettain
tulokset.puolue <- read.csv('../aineisto/tulokset_edvaalit2011.csv',
		header=TRUE, as.is=TRUE, sep=",")
                            
# Valitut kansanedustajat (n = 199)
edustajat  <- read.csv('../aineisto/valitut_edustajat.csv',
  	header=TRUE, as.is=TRUE, sep=";")

################################################################################

## MUOKKAUS ####################################################################

# Lisää dataan tieto siitä, valittiinko ehdokas. HUOM kaikki ehdokkaat eivät ole
# vielä tehneet vaalirahoitusilmoitusta

# Täsmätään edustajat "sukunimi etunimi" yhdistelmän perusteella
edustajat$kokonimi  <- paste(edustajat$sukunimi, edustajat$etunimi)

for (i in 1:length(data$etunimi)) {
    data$etunimi[i]  <- strsplit(data$etunimi[i], " ")[[1]]
}
data$kokonimi  <- paste(data$sukunimi, data$etunimi)
data$valittu  <- ifelse(data$kokonimi %in% edustajat$kokonimi, TRUE, FALSE)

for (i in 1:length(ehdokkaat$etunimi)) {
    ehdokkaat$etunimi[i]  <- strsplit(ehdokkaat$etunimi[i], " ")[[1]]
}
ehdokkaat$kokonimi  <- paste(ehdokkaat$sukunimi, ehdokkaat$etunimi)
ehdokkaat$valittu  <- ifelse(ehdokkaat$kokonimi %in% edustajat$kokonimi, TRUE, 
                             FALSE)