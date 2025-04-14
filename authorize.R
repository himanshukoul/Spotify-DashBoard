library(dotenv)
library(spotifyr)

load_dot_env(".env")
get_spotify_authorization_code(client_id = Sys.getenv("SPOTIFY_CLIENT_ID"),
                               client_secret = Sys.getenv("SPOTIFY_CLIENT_SECRET"))
