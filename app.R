library(shiny)
library(shinydashboard)
library(spotifyr)
library(tidyverse) #inc dplyr tidyr purrr...
library(plotly)
library(waiter)

ui <- dashboardPage(
  skin = "green",
  dashboardHeader(title = "Spotify User Analytics"),
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard"))
    ),
    selectInput("time_range", "Time Range:",
                choices = c("Last 4 Weeks" = "short_term",
                            "Last 6 Months" = "medium_term",
                            "All Time" = "long_term"),
                selected = "short_term"),
    div(style = "padding: 10px;",
        actionButton("refresh_btn", "Refresh Data", icon = icon("sync"),
                     style = "color: #fff; background-color: #1DB954; width: 90%;"))
  ),
  dashboardBody(
    use_waiter(),
    waiterShowOnLoad(html = spin_3circles(), color = "#1DB954"),
    tabItems(
      tabItem(tabName = "dashboard",
              fluidRow(
                infoBox("Top Artist", textOutput("top_artist"), icon = icon("star"), 
                        color = "green", width = 3),
                infoBox("Top Track", textOutput("top_track"), icon = icon("music"), 
                        color = "green", width = 3),
                infoBox("Unique Artists", textOutput("unique_artists"), icon = icon("users"), 
                        color = "green", width = 3),
                infoBox("Avg Track Length", textOutput("avg_track_length"), icon = icon("clock"), 
                        color = "green", width = 3)
              ),
              fluidRow(
                box(title = "Top Tracks by Popularity", status = "success", solidHeader = TRUE, width = 6,
                    plotlyOutput("tracks_plot", height = "400px")),
                box(title = "Top Artists by Popularity", status = "success", solidHeader = TRUE, width = 6,
                    plotlyOutput("artists_plot", height = "400px"))
              ),
              fluidRow(
                box(title = "Artist Diversity (Top Tracks)", status = "success", solidHeader = TRUE, width = 6,
                    plotlyOutput("artist_diversity_plot", height = "400px")),
                box(title = "Genre Distribution (Top Artists)", status = "success", solidHeader = TRUE, width = 6,
                    plotlyOutput("genre_plot", height = "400px"))
              ),
              fluidRow(
                box(title = "Track Duration Distribution", status = "success", solidHeader = TRUE, width = 6,
                    plotlyOutput("duration_plot", height = "400px")),
                box(title = "Artist Popularity Spread", status = "success", solidHeader = TRUE, width = 6,
                    plotlyOutput("artist_spread_plot", height = "400px"))
              ),
              fluidRow(
                box(title = "Time of Day Listening", status = "success", solidHeader = TRUE, width = 6,
                    plotlyOutput("time_of_day_plot", height = "400px")),
                box(title = "Recent vs Top Artist Overlap", status = "success", solidHeader = TRUE, width = 6,
                    plotlyOutput("overlap_plot", height = "400px"))
              ),
              fluidRow(
                box(title = "Recent Listening History", status = "success", solidHeader = TRUE, width = 12,
                    plotlyOutput("recent_tracks_plot", height = "400px"))
              )
    
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  #Rcontainer
  rv <- reactiveValues(top_tracks = NULL, top_artists = NULL, recent_tracks = NULL)
  
  fetch_spotify_data <- function() {
    waiter_show()
    access_token <- get_spotify_access_token()
    message("Access token: ", substr(access_token, 1, 10), "...")
    
    rv$top_tracks <- get_my_top_artists_or_tracks(type = "tracks", time_range = input$time_range, limit = 10)
    
    
    rv$top_artists <- get_my_top_artists_or_tracks(type = "artists", time_range = input$time_range, limit = 10)
    
    rv$recent_tracks <- get_my_recently_played(limit = 20)
   
    waiter_hide()
  }
  
  observe({ fetch_spotify_data() }) #on normal open
  observeEvent(input$refresh_btn, { fetch_spotify_data() }) #on btn click
  
  output$top_artist <- renderText({
    if (!is.null(rv$top_artists) && nrow(rv$top_artists) > 0) rv$top_artists$name[1] else "Unknown"
  })
  
  output$top_track <- renderText({
    if (!is.null(rv$top_tracks) && nrow(rv$top_tracks) > 0) rv$top_tracks$name[1] else "Unknown"
  })
  
  output$unique_artists <- renderText({
    if (!is.null(rv$top_tracks) && nrow(rv$top_tracks) > 0) {
      unique_artists <- rv$top_tracks %>% 
        unnest(artists, names_sep = "_") %>% 
        distinct(artists_name) %>% 
        nrow()
      as.character(unique_artists)
    } else {
      "N/A"
    }
  })
  
  output$avg_track_length <- renderText({
    if (!is.null(rv$top_tracks) && nrow(rv$top_tracks) > 0) {
      avg_length <- mean(rv$top_tracks$duration_ms, na.rm = TRUE) / 60000
      paste(round(avg_length, 1), "min")
    } else {
      "N/A"
    }
  })
  
  # Top Tracks Plot
  output$tracks_plot <- renderPlotly({
    if (!is.null(rv$top_tracks) && nrow(rv$top_tracks) > 0) {
      # purrr - mapchar func elementwise in list
      tracks_data <- rv$top_tracks %>%
        mutate(artist_name = map_chr(artists, ~paste(.x$name, collapse = ", ")),
               display_name = paste(name, "-", artist_name))
      plot_ly(tracks_data, y = ~reorder(display_name, popularity), x = ~popularity,
              type = "bar", orientation = "h", marker = list(color = "#1DB954")) %>%
        layout(title = "Top 10 Tracks by Popularity",
               xaxis = list(title = "Popularity", titlefont = list(size = 12), range = c(0, 100)),
               yaxis = list(title = ""),
               margin = list(l = 250, r = 50))  
    } else {
      plot_ly() %>% layout(title = "No track data available")
    }
  })
  
  # Top Artists Plot
  output$artists_plot <- renderPlotly({
    if (!is.null(rv$top_artists) && nrow(rv$top_artists) > 0) {
      plot_ly(rv$top_artists, x = ~reorder(name, popularity), y = ~popularity,
              type = "bar", marker = list(color = "#1DB954")) %>%
        layout(title = "Top 10 Artists by Popularity",
               xaxis = list(title = "", tickangle = 45),
               yaxis = list(title = "Popularity (0-100)", range = c(0, 100)))
    } else {
      plot_ly() %>% layout(title = "No artist data available")
    }
  })
  
  # Artist Diversity Plot
  output$artist_diversity_plot <- renderPlotly({
    if (!is.null(rv$top_tracks) && nrow(rv$top_tracks) > 0) {
      artist_counts <- rv$top_tracks %>%
        unnest(artists, names_sep = "_") %>%
        count(artists_name, name = "count") %>%
        arrange(desc(count))
      plot_ly(artist_counts, labels = ~artists_name, values = ~count, type = "pie",
              marker = list(colors = rev(colorRampPalette(c("#1DB954", "#0A3D2E"))(nrow(artist_counts))))) %>%
        layout(title = "Artist Distribution in Top Tracks")
    } else {
      plot_ly() %>% layout(title = "No artist diversity data available")
    }
  })
  
  
  
  # Genre Distribution Plot
  output$genre_plot <- renderPlotly({
    if (!is.null(rv$top_artists) && nrow(rv$top_artists) > 0) {
      genre_counts <- rv$top_artists %>%
        unnest(genres, names_sep = "_") %>%
        count(genres, name = "count") %>%
        arrange(desc(count)) %>%
        head(10)
      plot_ly(genre_counts, labels = ~genres, values = ~count, type = "pie",
              marker = list(colors = rev(colorRampPalette(c("#1DB954", "#0A3D2E"))(nrow(genre_counts))))) %>%
        layout(title = "Top 10 Genres from Top Artists")
    } else {
      plot_ly() %>% layout(title = "No genre data available")
    }
  })
  
  # Track Duration Distribution Plot
  output$duration_plot <- renderPlotly({
    if (!is.null(rv$top_tracks) && nrow(rv$top_tracks) > 0) {
      duration_data <- rv$top_tracks %>%
        mutate(duration_min = duration_ms / 60000)
      plot_ly(duration_data, x = ~duration_min, type = "histogram",
              marker = list(color = "#1DB954", line = list(color = "white", width = 1))) %>%
        layout(title = "Track Duration Distribution",
               xaxis = list(title = "Duration (minutes)"),
               yaxis = list(title = "Count"))
    } else {
      plot_ly() %>% layout(title = "No duration data available")
    }
  })
  
  # Artist Popularity Spread Plot
  output$artist_spread_plot <- renderPlotly({
    if (!is.null(rv$top_artists) && nrow(rv$top_artists) > 0) {
      plot_ly(rv$top_artists, y = ~popularity, type = "box",
              marker = list(color = "#1DB954"), line = list(color = "#1DB954")) %>%
        layout(title = "Popularity Spread of Top Artists",
               yaxis = list(title = "Popularity (0-100)", range = c(0, 100)))
    } else {
      plot_ly() %>% layout(title = "No artist spread data available")
    }
  })
  
  # Recent Time Listening Plot
  output$time_of_day_plot <- renderPlotly({
    if (!is.null(rv$recent_tracks) && nrow(rv$recent_tracks) > 0) {
      cat("Sample played_at value:", rv$recent_tracks$played_at[1], "\n") #debugging time format
      
      time_data <- rv$recent_tracks %>%
        mutate(timestamp = as.POSIXct(played_at, format = "%Y-%m-%dT%H:%M:%S.%OSZ", tz = "UTC"),
               local_time = format(timestamp, tz = Sys.timezone()),
               hour = as.integer(format(as.POSIXct(local_time), "%H"))) %>%
        count(hour, name = "count")
      
      plot_ly(time_data, x = ~hour, y = ~count, type = "bar",
              marker = list(color = "#1DB954")) %>%
        layout(title = "Time of Day Listening (Recent)",
               xaxis = list(title = "Hour of Day (0-23)", dtick = 2, 
                            tickvals = seq(0, 23, 2)),  #tick marks every 2hrs
               yaxis = list(title = "Number of Plays"))
    } else {
      plot_ly() %>% layout(title = "No time of day data available")
    }
  })
  
  # Recent vs Top Artist
  output$overlap_plot <- renderPlotly({
    if (!is.null(rv$top_tracks) && !is.null(rv$recent_tracks) && 
        nrow(rv$top_tracks) > 0 && nrow(rv$recent_tracks) > 0) {
      top_artists <- rv$top_tracks %>%
        unnest(artists, names_sep = "_") %>%
        count(artists_name, name = "top_count") %>%
        mutate(source = "Top Tracks")
      recent_artists <- rv$recent_tracks %>%
        unnest(track.artists, names_sep = "_") %>%
        count(track.artists_name, name = "recent_count") %>%
        mutate(source = "Recent Tracks")
      overlap_data <- full_join(top_artists, recent_artists, 
                                by = c("artists_name" = "track.artists_name")) %>%
        mutate(top_count = replace_na(top_count, 0),
               recent_count = replace_na(recent_count, 0)) %>%
        pivot_longer(cols = c(top_count, recent_count), names_to = "source", values_to = "count") %>%
        mutate(source = recode(source, "top_count" = "Top Tracks", "recent_count" = "Recent Tracks")) #recode = casewhen
      plot_ly(overlap_data, x = ~artists_name, y = ~count, color = ~source,
              type = "bar", colors = c("#1DB954", "#191414")) %>%
        layout(title = "Artist Overlap: Recent vs Top Tracks",
               xaxis = list(title = "", tickangle = 45),
               yaxis = list(title = "Count"),
               barmode = "group")
    } else {
      plot_ly() %>% layout(title = "No overlap data available")
    }
  })
  
  # Recent Tracks Plot
  output$recent_tracks_plot <- renderPlotly({
    if (!is.null(rv$recent_tracks) && nrow(rv$recent_tracks) > 0) {
      recent_data <- rv$recent_tracks %>%
        mutate(played_at = as.POSIXct(played_at),
               track_name = map_chr(track.artists, ~paste(.x$name, collapse = ", ")) %>%
                 paste(track.name, "-", .))
      plot_ly(recent_data, x = ~played_at, y = ~track_name, type = "scatter", mode = "markers",
              marker = list(color = "#1DB954", size = 10)) %>%
        layout(title = "Recent Listening History",
               xaxis = list(title = "Time Played"),
               yaxis = list(title = ""), margin = list(l = 250))
    } else {
      plot_ly() %>% layout(title = "No recent tracks data available")
    }
  })
}

shinyApp(ui = ui, server = server)