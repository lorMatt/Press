if (!require("pacman")) install.packages("pacman")
library(pacman)
p_load(rvest, future, tidyverse, progressr, furrr)

# Get article links ------------------------------------------------------------

## Define page links list 2984 ----
links <- 'https://terninrete.it/tutti-gli-articoli/page/'
links <- paste0(links, c(1:2984), '/')

## define scraping function ----
url_scrape <- function(link) {
  tryCatch({
    html <- read_html(link) # Carica l'HTML della pagina corretta
    url <- html |> 
      html_elements('.jeg_post_title a') |> 
      html_attr('href')
    return(tibble(url = url))
  }, error = function(e) {
    return(tibble(url = NA_character_, errore = as.character(e)))
  })
}

# configure future for parallel run
plan(multisession, workers = 6)

## progressr config, call function ----
with_progress({
  p <- progressor(steps = length(links)) # initialise prog bar
  
  # Parallel scraping
  article_links <- future_map(links, function(link) {
    p() # Progress bar increment
    url_scrape(link)
  })
})

# convert results in vector
article_links <- bind_rows(article_links) |>
  unique() |> 
  filter(is.na(errore)) |> 
  select(url)
article_links <- article_links$url |>
  as.character()
# Get article data ------------------------------------------------------------

## define scraping function ----
art_scrape <- function(link) {
  tryCatch({
    html <- read_html(link)
    
    title <- html |> 
      html_elements('.jeg_post_subtitle , .entry-header .jeg_post_title') |> 
      html_text() |> 
      paste(collapse = '. ')
    
    date <- html |> 
      html_element('.meta_left .jeg_meta_date a') |> 
      html_text() |> 
      str_extract('\\d{2}\\s[A-Za-z]+\\s\\d{4}')
    
    text <- html |> 
      html_elements('.content-inner p') |> 
      html_text() |> 
      paste(collapse = ' ')
    
    return(tibble(title = title,
                  date = date,
                  text = text))
  }, error = function(e) {
    return(tibble(title = NA,
                  date = NA,
                  text = NA,
                  errore = as.character(e)))
  })
}

# configure future for parallel run
plan(multisession, workers = 8)
art_links <- article_links
## progressr config, call function ----
with_progress({
  p <- progressor(steps = length(art_links)) # Inizializza la barra di progresso
  
  # Parallel scraping
  article_data <- future_map(art_links, function(link) { # Usa future_map qui
    p() # Progress bar increment
    art_scrape(link)
  })
})

# convert results in tibble, parse dates
## set language to italian
Sys.setlocale(locale="it_IT.UTF-8")
TRinrete <- tibble(title = character(),
                   date = Date(),
                   text = character(),
                   errore = character())
TRinrete_ <- bind_rows(article_data) |> 
  mutate(date = date |> as_date(format = "%d %B %Y")) |> 
  filter(is.na(errore)) |> 
  bind_rows(TRinrete) |> 
  unique()
TRinrete <- TRinrete_ |> rbind(TRinrete)

# Ripristina l'esecuzione sequenziale
plan(sequential)

# Export corpus as RDS

write_rds(TRinrete, 'Rawdata/TRinrete.RDS')
