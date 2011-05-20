
poly_coords<- function(shapefile){

if (nrow(data.frame(shapefile$ID))< 1) 

	{

	print ("No ID field in SpatialPolygon")

	}else{

	Order<-0 
	YX3<- as.numeric("XX", "XX", "XX", "XX")
	num_polys<- nrow(shapefile@data)+1
	YX3<- as.numeric("XX", "XX", "XX")
	
	curr_poly<- shapefile@data[1,]
	curr_poly_start_row <- 1
	poly_old= F
	
	for(curr_row in curr_poly_start_row:num_polys)
	{
	curr_poly_row<-shapefile@data[curr_row,]
	curr_poly_end_row = curr_row - 1	
	Poly_n= shapefile@data[curr_poly_start_row:curr_poly_end_row,]
	curr_poly_start_row = curr_row
	Poly_Name<-as.vector(Poly_n$ID)
	Poly<-shapefile[shapefile$ID==Poly_Name,]
	PolyCoords<-lapply(slot(Poly, "polygons"), function(x) lapply(slot(x,
  		 "Polygons"), function(y) slot(y, "coords")))
	PolyCoordsY<-PolyCoords[[1]][[1]][,1]
	PolyCoordsX<-PolyCoords[[1]][[1]][,2]
	Order<- 1:nrow(data.frame(PolyCoordsX)) + max(Order)
	if (poly_old != Poly_n$ID)
	{
	YX1<- data.frame(Poly_Name, Order, PolyCoordsY, PolyCoordsX)
	YX2<-rbind(YX3,YX1)
	YX3<-YX2
	}
	poly_old<-Poly_n$ID
	}
	
	join<-merge(YX3, shapefile@data, by.x="Poly_Name", by.y= "ID", all=T)
	join[order(join$Order),][1:nrow(join)-1,]
	}
}