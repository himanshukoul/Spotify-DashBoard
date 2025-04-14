# Spotify User Analytics Dashboard

A Shiny dashboard that visualizes a user's Spotify listening habits using the Spotify API, built with R, `shinydashboard`, `spotifyr`, `plotly`, and other packages.

## Files

- `app.R`: Main Shiny app for the dashboard, displaying top tracks, artists, genres, and more.
- `authorize.R`: Script to authenticate with the Spotify API.
- `.env`: Configuration file for Spotify credentials (not included in repository).

## Features

- Displays top tracks and artists by popularity.
- Visualizes genre distribution, track duration, and listening time of day.
- Compares recent listening history with top tracks/artists.
- Interactive plots with `plotly` and a responsive UI with `shinydashboard`.

## Setup

1. Install R and required packages:
   ```R
   install.packages(c("shiny", "shinydashboard", "spotifyr", "tidyverse", "plotly", "waiter", "dotenv"))
   ```
2. since not using spotify extended version, you need to create a new app in the developer dashboard and get the client id and client secret. Also need to add spotify id in User Management (Spotify Developers) for people who will be using the app.
3. Create a `.env` file with your Spotify credentials (client ID and client secret).