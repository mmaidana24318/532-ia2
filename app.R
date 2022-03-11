library(dash)
library(dashHtmlComponents)
library(dashBootstrapComponents)
library(tidyverse)
library(purrr)
library(ggthemes)
library(plotly)

app <- Dash$new(external_stylesheets = dbcThemes$BOOTSTRAP)

data <- read_csv('data/processed_df.csv')

opt_dropdown_neighbourhood <- unique(data$Neighborhood) %>%
    map(function(col) list(label = col, value = col))
opt_dropdown_neighbourhood <- opt_dropdown_neighbourhood[-c(20, 24, 25)]


# filters card
card2 <- dbcCard(
    list(
        # Dropdown for neighbourhood
        htmlH5("Neighbourhood", className="text-dark"),
        dccDropdown(id = "neighbourhood_input",
                    options = opt_dropdown_neighbourhood, 
                    value = 'Kitsilano',
                    className="dropdown"),
        htmlBr(),
        htmlBr(),
        htmlBr()
    ),
    style = list("width" = "25rem", "marginLeft" = 20),
    body = TRUE,
    color = "light"
)

# filter layout
filter_panel = list(
    htmlH2("Vancouver Crime Dashboard", style = list("marginLeft" = 20)),
    htmlBr(),
    htmlBr(),
    htmlH4("Filters", style = list("marginLeft" = 20)),
    card2,
    htmlBr()
)

# plot layout
plot_body = list(
    dccGraph("bar_plot")
)

# Page layout
page_layout <- htmlDiv(
    className="page_layout",
    children=list(
        dbcRow(htmlBr()),
        dbcRow(
            list(dbcCol(filter_panel, className = "panel", width = 3),
                 dbcCol(plot_body, className = "body"))
        )
    )
)

# Overall layout
app$layout(htmlDiv(id="main", className="app", children=page_layout))


app$callback(
    output("bar_plot", 'figure'),
    list(input('neighbourhood_input', 'value')),
    function(neighbourhood, year){
        line_data <- data %>%
            filter(Neighborhood == neighbourhood) %>%
            group_by(YEAR,TIME) %>%
            summarize(n = n())
        line_chart <- line_data %>%
            ggplot(aes(x = YEAR, y = n, color = TIME)) +
            geom_line(size= 1.2) + 
            labs(title = "Crimes over Time", x = "Year", y = "Number of Crimes") +
            theme(
                plot.title = element_text(face = "bold", size = 16),
                axis.title = element_text(face = "bold", size = 12)
            ) 
        
        ggplotly(line_chart + aes(text = n), tooltip = c("TIME", "n"), width = 800, height = 500)
    }
)

app$run_server(host = '0.0.0.0')