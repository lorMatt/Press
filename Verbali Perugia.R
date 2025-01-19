if (!require("pacman")) install.packages("pacman")
library(pacman)
p_load(pdftools, tidyverse)


# Import .pdf ------------------------------------------------------------------

## define file list ----
files <- 
  'Perugia/Verbali/' |> 
  paste(list.files(path = 'Perugia/Verbali'), sep = '')
  
## import and tidy ----

### empty tibble
verbali <- tibble(text = '', speaker = '', date = '')[0,]

### for loop
for (i in files) {
  doc <-
  
  # import file
    pdf_text(i) |>
    as_tibble() |> 
    rename('text' = 'value') |> 

  # add date
    cbind(i) |>
    mutate(date = gsub('Perugia/Verbali/Verbale_', '', i)) |> 
    mutate(date = gsub('.pdf', '', date)) |> 
    select(!`i`) |> 
  
  # delete first and last page
    filter(row_number()!=1 & row_number() != n()) |>
  
  # delete tabulation, assign page num
    mutate(pag = row_number(date), text = str_split(text,'\n')) |>
    unnest(cols = text) |>
  
  # delete header, footer
    group_by(pag) |>
    slice(-c(1, n())) |>
    ungroup() |> 
  
  # delete unnecessary space, empty strings
    filter(substr(text, 1, 1) != ' ' & text != '') |>
  
  # define speakers
    mutate(speaker = ifelse(grepl(regex("^[A-Z]{2,} [A-Z]{2,}"), text),
                            text, NA)) |> 
    fill(speaker) |> 
    filter(speaker != text) |> 
    
  # summarise by speaker
    group_by(speaker) |> 
    mutate(text = str_c(text, collapse = '')) |> 
    distinct(text, .keep_all = T) |> 
    mutate(text = gsub('- ', '', text)) |> 
    ungroup() |> 
    
  # delete unnecessary column, move speakers to front
    select(!pag) |> 
    relocate(speaker, .before = text)
    

  # append to global tibble
  verbali <- bind_rows(doc, verbali)
}

verbali <- verbali |> 
  
  # filter out roll calls
  filter(grepl('appello', speaker) == F) |> 
  
  # tidy speaker titles and names
  mutate(desc = str_replace(speaker, regex("^[A-Z]{2,} [A-Z]{2,}"), ''),
         speaker = str_extract(speaker, regex("^[A-Z]{2,} [A-Z]{2,}"))) |>
  relocate(desc, .after = speaker)

# Write RDS file ---------------------------------------------------------------
write_rds(verbali, 'Perugia/VerbPG.RDS')


