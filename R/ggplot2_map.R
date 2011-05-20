library(maptools)
library(ggplot2)
library(RColorBrewer)

# set the working directory.

setwd("/home/jlehtoma/Dropbox/Code/vaalirahoitus/R/")

# Load the function we require later.

source("poly_coords_function.R")

# Load the shapefile

sport <- readShapePoly("London_Sport/london_sport.shp")

# Have a look at the attribute table headings

names(sport)

# SpatialPolygons are complex objects in R. Accessing their geometry isn't 
# straightforward but needs to be done in order for ggplot2 to be able to 
# handle  them. ggplot2 contains the "fortify" function that does this for you 
# but I have been having problems with it on 64bit installations and macs so I 
# have written my own function for this tutorial. It is simple enough to use 
# the fortify command (remember to sort the table by the order field, and check 
# the field headings) and go to the mapping step. It requires an ID field in 
# the SpatialPolygonsdataframe, we will rename the "ons_label" field for this.

names(sport) <- c("ID", "name", "Partic_Per", "Pop_2001")

sport_geom <- poly_coords(sport)

# Have a look at the sport_geom object to see its contents

head(sport_geom)

# Make the map of % sports participation in London boroughs. We will use the 
# plot function.

map <- qplot(PolyCoordsY, PolyCoordsX, data=sport_geom, group=Poly_Name , 
             fill=Partic_Per, geom="polygon")

map

# The default colours are really nice but we may wish to produce the map in 
# black and white:

map + scale_fill_gradient(low="white", high="black")

# Or use another colour scheme such as one recommended by Color Brewer or 
# introduce more breaks in the data:

new_fill <- function(pal, lowerlim, upperlim){
  scale_fill_gradientn(colours= pal, limits=c(lowerlim, upperlim))
}

# The function above requires the name of the colour palette and any parameters 
# required for it as well as the upper and lower limits of the data you wish to 
# plot. 

map + new_fill(brewer.pal(7, "Blues"), 0, 30)

# See rspatialtips.org.uk for more info.

#
# Disclaimer: The methods provided here may not be the best solutions, just the 
# ones I happen to know about! No support is provided with these worksheets. I 
# have tried to make them as self-explanatory as possible and will not be able to
# respond to specific requests for help. I do however welcome feedback on the 
# tutorials. License: cc-by-nc-sa. Contact: james@spatialanalysis.co.uk
