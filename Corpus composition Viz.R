if (!require("pacman")) install.packages("pacman")
library(pacman)
p_load(tidyverse, patchwork, ggiraph)

# Data import ------------------------------------------------------------------
Corpus <- read_rds('Corpus.RDS')

# Descriptives -----------------------------------------------------------------
## graphics ----
### palette ----
pal <- c(
  "#FDA638",
  "#459395",
  "#EB7C69"
)
na_col <- "#866f85"

### theming ----
theme_set(theme(panel.background = element_blank(),
                axis.ticks = element_blank(),
                legend.title = element_blank(),
                panel.grid.major = element_line(linetype = 'solid', colour = 'gray97', linewidth = .3),
                panel.grid.minor = element_blank(),
                axis.line.x = element_line(colour = 'gray25'),
                axis.line.y = element_line(colour = 'gray25')))
## Distribution of articles over time ----
time_art <- Corpus |>
  group_by(newspaper, city) |> 
  mutate(month = floor_date(date, unit = 'quarter')) |>
  count(month) |> 
  ggplot(aes(month, n, fill = newspaper, data_id = month,tooltip = n)) +
  geom_col_interactive(position = 'stack', width = 70) +
  theme(axis.line.y = element_blank()) +
  scale_x_date(limits = c(as_date(as_date('1 January 2011', format = "%d %B %Y")), NA))

## Regional composition ----
reg_art <-
  Corpus |> 
  group_by(city, newspaper) |> 
  count() |> 
  ggplot(aes(city, n, fill = newspaper, data_id = city, tooltip = n)) +
  coord_flip() +
  theme(axis.line.x = element_blank()) +
  geom_col_interactive()

## Patchwork ----
p <- time_art / reg_art +
  plot_layout(guides = 'collect', heights  = c(8,1)) &
  plot_annotation(title = 'Article distribution over time',
                  subtitle = 'By newspaper and city') &
  scale_y_continuous(expand = c(0,0)) &
  scale_fill_manual(values = pal, na.value = na_col) &
  theme(legend.position = 'bottom',
        axis.title = element_blank())

### interactive 
girafe(ggobj = p, width_svg = 8,
       options = list(
         opts_hover(css = ''), ## CSS code of line we're hovering over
         opts_hover_inv(css = "opacity:0.3;"), ## CSS code of all other lines
         opts_tooltip(css = "background-color:white;
                      color:black;
                      font-family:Helvetica;
                      font-style:empty;
                      padding:8px;
                      border-radius:10px;",
                      use_cursor_pos = T),
         opts_toolbar(position = 'bottomright')))