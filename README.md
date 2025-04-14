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

## Screenshots
![image](https://github.com/user-attachments/assets/cbd13f9b-92f1-451d-be2f-8a871e2fa95c)
![image](https://github.com/user-attachments/assets/e1eba904-fb22-450b-8f0e-691ad33ef258)
![image](https://github.com/user-attachments/assets/01b5e9e5-0b86-47de-b9b1-e9ac98c6079a)
![image](https://github.com/user-attachments/assets/ed221026-aee3-4406-89b5-f9d04ce0b6e6)
![image](https://github.com/user-attachments/assets/c4fa5dfc-6afb-4f34-91ff-e6927b9cda68)




