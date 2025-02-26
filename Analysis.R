if (!require("pacman")) install.packages("pacman")
library(pacman)
p_load(tidyverse, tidytext)

# Data import and merge --------------------------------------------------------

CorrUmbriaTR <- readRDS('CorrUmbriaTR.RDS') |>
  mutate(city = 'TR')

CorrUmbriaPG <- readRDS('CorrUmbriaPG.RDS') |>
  mutate(city = 'PG')

CorrUmbria <- CorrUmbriaPG |> 
  bind_rows(CorrUmbriaTR)

# Text pre-process

CorrUmbria |> 
  mutate(month = floor_date(date, 'month')) |> 
  group_by(month, city) |> 
  count() |> 
  ggplot(aes(month, n)) +
  geom_col() +
  facet_wrap(~city)
