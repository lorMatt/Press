# UmbriaPress
In this repository:
- scrapers for three major Umbrian newspapers (*Corriere dell'Umbria*, *PerugiaToday*, *Terninrete*) and their respective outputs (RDS files, inside 'Rawdata/');
- a data cleaning script (Dataprep.R) which outputs a complete file (Corpus.RDS) and interactive visualisations describing the corpus' composition.

Data is completely free to use under standard MIT license. The complete database is available at [this link]([url](https://drive.google.com/file/d/1FaPcCt0etc_rBmKKLJste-D-kVWaIKDl/view?usp=sharing))

## Important
I am all but a scraping expert, so the scrapers for *Corriere dell'Umbria* and *PerugiaToday* are simple while loops. Since scraping PerugiaToday took a grand total of 18 hours, I took a different route with Terninrete, and built a slightly more advanced script. The latter makes the most of the [future]([url](https://future.futureverse.org/)) and [purrr]([url](https://purrr.tidyverse.org/)) packages, working on multiple R sessions (I used 4/6), bringing the operating time down to just a couple hours. Error management and process tracking is also improved in this last script.
