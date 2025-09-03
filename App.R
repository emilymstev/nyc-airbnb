# Load libraries
library(shiny)
library(dplyr)
library(ggplot2)

# Load the data from data aggregation
source("Data.r")

# Component #1: UI
ui <- fluidPage(
  titlePanel("NYC Airbnb Map"),
  tabsetPanel(
    # A ReadMe tab explaining the storytelling components of the application
    tabPanel("ReadMe",
             fluidPage(
               h3("Welcome to the NYC Airbnb Visualization App!"),
               p("This app is intended to help you find the perfect AirBnb for your next New York City stay!"),
               p("Navigate through different tabs to compare neighborhoods, hosts, and view a map. Reference below for more information about filters"),
               h4("Tab Information"),
               p("Neighborhood: Wondering which neighborhood may be the best and safest place to book your stay? Check out this tab to compare New York City's 5 Neighborhoods. You will have the opportunity to gauge a neighborhood's crowd levels by comparing Populations, view the differences in the percentage of people under the poverty level, and determine how to get around by contrasting the percentage of people who frequently walk to work and the percentage of people who take transit and other options amongst different areas."),
               p("Host Summary: Have a few hosts in mind? Compare several hosts at a time and view their places based on average price per night, days in the year of availability, and the number of reviews available. You will easily be able to see if a host has many or few places as well."),
               p("Map: After knowing various stats on the areas and hosts, select a price per night range, room type, and neighborhood to view AirBnB options on a New York City map. The map only includes AirBnbs less than $1000 per night, but more expensive options can be found in the Host Summary tab.")
             )
    ),
    
    # A tab to display neighborhood information
    tabPanel("Neighborhood",
             sidebarLayout(
               # Allow the user to select 2 neighborhoods and a comparison variable
               sidebarPanel(
                 selectInput(
                   inputId = "neighborhood1", 
                   label = "Select Neighborhood 1:", 
                   choices = unique(census_detail$Borough)),
                 selectInput(
                   inputId = "neighborhood2", 
                   label = "Select Neighborhood 2:", 
                   choices = unique(census_detail$Borough)),
                 selectInput(inputId = "comparison_variable", 
                             label = "Select Variable to Compare:",
                             choices = c("Total Population", "Percentage Below Poverty", "Transit Percentage", "Walking Percentage"),
                             selected = "Total Population")
               ),
               mainPanel(
                 plotOutput("neighborhood_plot")
               )
             )
    ),
    # A tab to display data about particular host and their listings
    tabPanel("Host Summary",
             sidebarLayout(
               sidebarPanel(
                 selectInput(inputId = "selected_hosts_table", 
                             label = "Select Hosts:", 
                             choices = unique(census_full$Host), 
                             multiple = TRUE),
                 checkboxGroupInput(inputId = "selected_variables_table", 
                                    label = "Select Variables:", 
                                    choices = c("Price", "Availability (365 days)", "Number of Reviews"),
                                    selected = c("Price", "Availability (365 days)", "Number of Reviews"))
               ),
               mainPanel(
                 tableOutput("host_summary_table")
               )
             )
    ),
    #A tab to display a leaflet map with markers filtered by price, 
    tabPanel("Map",
             sidebarLayout(
               sidebarPanel(
                 conditionalPanel(
                   condition = "input.room_type.length > 0 || input.price_range[1] > 0 || input.price_range[2] > 0 || input.neighborhood.length > 0",
                   checkboxGroupInput(inputId = "room_type", 
                                      label = "Room Type:", 
                                      choices = unique(census_full$room_type), 
                                      selected = unique(census_full$room_type)),
                   sliderInput(
                     inputId = "price_range",
                     label = "Price Range:", 
                     min = 0, max = 1000, value = c(0, 100), step = 5
                   ),
                   
                   selectInput(
                     inputId = "neighborhood", 
                     label = "Neighborhood", 
                     choices = unique(census_full$neighbourhood_group), selected = unique(census_full$neighbourhood_group)
                   )
                 )
               ),
               
               mainPanel(
                 leafletOutput("map")
               )
             )
    )
  )
)

# Component #2: Server
server <- function(input, output, session) {
  # Get the aggregated data and separate by dataset
  census_data_list <- list(census_full = census_full, census_detail = census_detail)
  
  # NEIGHBORHOOD TAB
  
  # Note: I was having trouple using DynamicUI, but I researched reactive functions and learned how to use them in my application. I was able to connect one reactive to multiple outputs to make dynamic rendering easier.
  #Filter through both of the datasets (by binding them together) and only keep the rows where the neighborhood matches either input statement
  neighborhood_comparison_data <- reactive({
    filtered_data <- bind_rows(census_data_list$census_full, census_data_list$census_detail) %>%
      filter(Borough %in% c(input$neighborhood1, input$neighborhood2))
    return(filtered_data)
  })
  
  output$neighborhood_plot <- renderPlot({
    # Ensure that both neighborhoods are unique (Note: This was another workaround due to my failed attempt to implement the DynamicUI)
    req(length(unique(neighborhood_comparison_data()$Borough)) >= 2)
    
    # Render ggplot bar chart for neighborhood comparison
    # Note: .data was used on the Y variable so that ggplot would recognize that the variable was being rendered dynamically
    ggplot(neighborhood_comparison_data(), aes(x = Borough, y = .data[[input$comparison_variable]], fill = Borough)) +
      geom_bar(stat = "identity", position = "dodge", alpha = 0.7) +
      labs(title = paste("Comparison of", input$comparison_variable, "in Selected Neighborhoods"),
           x = "Neighborhood",
           y = input$comparison_variable) +
      theme_classic()
  })
  
  #HOST TAB
  
  # Dynamically filter out only the selected hosts for dynamic table display
  selected_hosts_table_data <- reactive({
    filter(census_full, Host %in% input$selected_hosts_table)
  })
  
  # Render table for selected hosts
  output$host_summary_table <- renderTable({
    req(length(input$selected_hosts_table) > 0)
    
    # Create a data variable to call the reactive function
    data <- selected_hosts_table_data()
    
    # Drop all unnecessary variables for table display and only include variables checked by the user along with host and name
    selected_variables <- input$selected_variables_table
    data <- data[, c("Host", "Name", selected_variables), drop = FALSE]
    
    # Sort alphabetically by Host
    data <- arrange(data, Host)
    
    # Return the data to display a table based on all filters and arrangements applied
    return(data)
  })
  
  #MAP TAB
  
  # Filter so that the data only includes Airbnbs that are in the user selected range, particular room types, and a selected neighborhood
  filtered_data <- reactive({
    if (length(input$room_type) > 0 || input$price_range[1] > 0 || input$price_range[2] > 0 || length(input$neighborhood) > 0) {
      filter(census_data_list$census_full,
             room_type %in% input$room_type,
             Price >= input$price_range[1] & Price <= input$price_range[2],
             neighbourhood_group == input$neighborhood
      )
    } else {
      # Return an empty data frame if no filters are selected
      data.frame()
    }
  })
  
  # Render Leaflet map
  output$map <- renderLeaflet({
    leaflet(data = filtered_data()) %>%
      addTiles() %>%
      addMarkers(~longitude, ~latitude,
                 popup = ~paste("<b>Name:</b>", Name, "<br>Host:</b>", Host, "<br><b>Room Type:</b>", room_type, "<br><b>Price: $</b>", Price, "<br><b>365 Day Availability</b>", `Availability (365 days)`),
                 clusterOptions = markerClusterOptions()) %>%
      setView(lng = -74, lat = 40.7, zoom = 12)
  })
}

# Component #3: Server
shinyApp(ui, server)
