# aim: get road network data (and slopes) for any city

remotes::install_github("itsleeds/geofabrik")
remotes::install_github("itsleeds/slopes")
library(geofabrik)
library(sf)

city_name = "sheffield"
buffer_size = 2000

city_sf = tmaptools::geocode_OSM(city_name, as.sf = TRUE)
city_buffer = stplanr::geo_buffer(city_sf, dist = buffer_size)
mapview::mapview(city_buffer)

osm_data_city = get_geofabrik(name = city_sf)
pryr::object_size(osm_data_city)

osm_data_in_buffer = st_intersection(osm_data_city, city_buffer)
pryr::object_size(osm_data_in_buffer)

mapview::mapview(osm_data_in_buffer)
osm_data_no_na = osm_data_in_buffer[!is.na(osm_data_in_buffer$highway), ]
pryr::object_size(osm_data_no_na)

summary(geo_type <- sf::st_geometry_type(osm_data_no_na))
osm_data_linestring = osm_data_no_na[geo_type == "LINESTRING", ]

library(slopes)
# lisbon_route_3d_auto = slope_3d(r = lisbon_route)
st_geometry(osm_data_linestring)
osm_data_z = slope_3d(osm_data_linestring) # must be linestrings
st_geometry(osm_data_z)
m = st_coordinates(osm_data_z)
head(m)
osm_data_z$slope = slope_matrix_weighted(m)
# note to self: not intuitive at all!
plot(osm_data_z["slope"])
summary(osm_data_z$slope)

net_3d = sfnetworks::as_sfnetwork(osm_data_z) # fails
net_3d = sfnetworks::as_sfnetwork(sf::st_zm(osm_data_z)) # fails
osm_data_z2 = sf::st_as_sf(
  data.frame(stringsAsFactors = FALSE,
    osm_id = osm_data_z$osm_id,
    highway = osm_data_z$highway,
    slope = osm_data_z$slope
  ),
  geometry = sf::st_geometry(osm_data_z)
)
net_3d = sfnetworks::as_sfnetwork(sf::st_zm(osm_data_z2)) # fails
net_3d = sfnetworks::as_sfnetwork(sf::st_zm(osm_data_z2)[1:9, ]) # fails



osm_data_z$slope = slopes::slope_matrix_weighted()



# try with lisbon data ----------------------------------------------------
library(sfnetworks)
lisbon_road_segment$geom
net = as_sfnetwork(lisbon_road_segment_3d)
sf::st_z_range(net)
sf::st_geometry(net)
