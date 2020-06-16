library(sfnetworks)
library(tidygraph)
library(dplyr)
library(sf)
library(mapview)


# sample data
r = slopes::lisbon_road_segments
class(r)
names(r)
plot(r["Avg_Slope"])

# transform to sf network
net = as_sfnetwork(r)
st_crs(net)
p1 = net %>%
  activate(nodes) %>%
  st_as_sf() %>%
  slice(1)
p2 = net %>%
  activate(nodes) %>%
  st_as_sf() %>%
  slice(9)
# mapview does not work. Source projection error
#mapview::mapview(p1) + mapview::mapview(p2)

# this
path1 = net %>%
  activate("edges") %>%
  mutate(weight = edge_length()) %>%
  convert(to_spatial_shortest_paths, p1, p2)
plot(path1)

# Change the weight so that it is a product of edge_length and average slope.
# I am not sure how to access the edge columns to see if this worked
path2 = net %>%
  activate("edges") %>%
  mutate(weight = edge_length() * Avg_Slope) %>%
  convert(to_spatial_shortest_paths, p1, p2)
plot(path2)

# plot to see difference in routes
plot(net, col = "lightgrey")  # How do we plot this with the Avg_Slope as a variable
plot(path1, add=T)
plot(path2, add=T, col="green")
plot(p1, add=T, col="darkred")
plot(p2, add=T, col="darkred")


x <- net %>%
  activate("edges")
