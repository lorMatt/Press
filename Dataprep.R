if (!require("pacman")) install.packages("pacman")
library(pacman)
p_load(tidyverse, tidytext)

# Data import ------------------------------------------------------------------

## Corriere dell'Umbria
CorrUmbriaTR <- readRDS('Rawdata/CorrUmbriaTR.RDS') |>
  mutate(city = 'TR',
         newspaper = 'Corriere dell\'Umbria')

CorrUmbriaPG <- readRDS('Rawdata/CorrUmbriaPG.RDS') |>
  mutate(city = 'PG',
         newspaper = 'Corriere dell\'Umbria')

CorrUmbria <- CorrUmbriaPG |> 
  bind_rows(CorrUmbriaTR)

## Perugia Today

unzip('Rawdata/PGToday.RDS.zip')
PGToday <- readRDS('Rawdata/PGToday.RDS') |> 
  mutate(city = 'PG',
         newspaper = 'Perugia Today')

## Terninrete

TRinrete <- readRDS('Rawdata/TRinrete.RDS') |> 
  mutate(city = 'TR',
         newspaper = 'Terninrete') |> 
  select(!errore)

# Merge ------------------------------------------------------------------------
Corpus <- CorrUmbria |> 
  bind_rows(PGToday, TRinrete)

## Write corpus as RDS
write_rds(Corpus, 'Corpus.RDS')

