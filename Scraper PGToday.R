if (!require("pacman")) install.packages("pacman")
library(pacman)
p_load(tidyverse, rvest)

# Get article links ------------------------------------------------------------

## Define page n link ----
link <- 'https://www.perugiatoday.it/notizie/tutte/pag/'

## setup up loop to iterate 2556 times (one for each page) ----

### setup vectors
article_urls <- tibble()
i <- 1

### start loop
while (i <= 2556) {
  print(paste('retrieving URLs from page', i, 'out of 2556'))
  
  ilink <- paste0(link, i, '/') # generate page i link
  
  html <- read_html(ilink) # Parse html
  
  article_url <- html |> 
    html_elements('.c-story--stack') |> # Get article link 
    html_nodes('a') |> 
    html_attr('href')
  article_urls <- article_urls |> 
    bind_rows(as_tibble(article_url)) # append to url list
  
  i <- i + 1 # add 1 to i
}
rm(i)

## restore corrupt urls
article_urls_ <- ifelse(!startsWith(article_urls$value, 'https://www.perugiatoday.it'),
                       paste0('https://www.perugiatoday.it', article_urls$value),
                       article_urls$value)

# Scrape article data ----------------------------------------------------------

## define empty df ----
PGToday <- tibble(title = character(),
                       date = character(),
                       text = character(),
                       tag = character())

## set language to italian
Sys.setlocale(locale="it_IT.UTF-8")
## initialise loop ----
i <- 2597
while (i <= NROW(article_urls)) {
  print(paste('scraping article number', i, 'of', NROW(article_urls)))
  
  article <- read_html(article_urls_[i]) # parse html
  
  title <- article |> 
    html_element('.l-entry__title') |> # extract title
    html_text()
  
  text <- article |> 
    html_element('.c-entry') |> # extract text
    html_nodes('p') |>
    html_text() |> 
    paste(collapse = '') |> 
    str_remove_all('\\n') |> 
    str_remove_all('\\r')
  
  date <- article |> 
    html_elements('.u-label-08') |> # extract date
    html_text2() |> 
    paste(collapse = '') |> 
    str_extract('\\d{2}\\s[A-Za-z]+\\s\\d{4}')
  
  tag <- article |> 
    html_element('.u-label-02') |> #extract tag
    html_text()
  
  n_row <- tibble(
    title = title,
    date = date,
    text = text,
    tag = tag # defining new df row
  )
  
  PGToday <- n_row |> 
    bind_rows(PGToday) # append to original df
  
  i <- i + 1
}

## convert date column to date format
PGToday <- PGToday |> 
  mutate(date = date |> as_date(format = "%d %B %Y"))

# Export corpus as RDS

write_rds(PGToday, 'Rawdata/PGToday.RDS')
zip('Rawdata/PGToday.RDS.zip', 'Rawdata/PGToday.RDS')
