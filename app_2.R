library(dash)
library(readr)
library(plotly)
library(ggplot2)
library(broom)
#library(geojsonio)
library(rgdal)
library(dplyr)
library(dashCoreComponents)
library(dashHtmlComponents)
library(dashBootstrapComponents)
library(maptools)

gpclibPermit()

app <- Dash$new(external_stylesheets = dbcThemes$BOOTSTRAP)

#msleep2 <- readr::read_csv(here::here('data', 'msleep.csv'))
#df <- read.csv(here::here('data', 'map_df.csv')) %>% 
df <- read_csv("data/map_df.csv") %>%
    filter(YEAR==2021)
url_geojson <- "https://raw.githubusercontent.com/UBC-MDS/vancouver_crime_dashboard/main/data/vancouver.geojson"
geojson <- rgdal::readOGR(url_geojson)
geojson2 <- broom::tidy(geojson, region = "name")
geojson2 <- geojson2 %>%
    left_join(df, by = c("id" = "Neighborhood"))
fig <- ggplot() +
    geom_polygon(data = geojson2, 
                 aes(x = long, y = lat, group = group, fill = Count)) +
    scale_fill_gradient(low = "yellow2", high = "red3", na.value = NA)


app$layout(
  dbcContainer(
    list(
      htmlH1('Vancouver Crime Map - 2021',
             style=list(
                 'margin-top'= 20,
                 'margin-bottom'= 20,
                 'text-align'= 'center',
                 'font-size'= '25px')),
      dccGraph(id='plot-area', figure=ggplotly(fig))
    )
  )
)


#app$run_server(debug = T)
app$run_server(host = '0.0.0.0')