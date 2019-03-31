library(jsonlite)
library(dplyr)
library(lubridate)


premium <- read.csv('datdota/matches_p1.csv', header=T) %>%
  rename(MatchId = ï..Match.ID)

datdota_url <- 'https://www.datdota.com/api/matches/'
options(HTTPUserAgent="R (3.5.1) - Friendly Bot. Contact vishalin.pillay@outlook.com if usage is problematic")

matches <- list()

for(i in 1:nrow(premium))
{
  start <- Sys.time()
  
  match_url <- paste0(datdota_url, premium$MatchId[i])
  match_json <- fromJSON(match_url)
  
  matches <- c(matches, match_json)
  
  Sys.sleep(ifelse(1.2 - as.numeric(Sys.time() - start, 'secs') > 0, 1.2 - as.numeric(Sys.time() - start, 'secs'), 0))
  
  print(paste0(i, ' - ', as.numeric(Sys.time() - start, 'secs')))
}

saveRDS(matches, 'matchdata/matches_json.rda')

