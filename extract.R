#.libPaths("H:/myCitrixFiles/Documents/R/win-library/3.2")

library(dplyr)
library(ggplot2)
library(jsonlite)

matches <- readRDS('matchdata/matches_json.rda')

#Generate empty dataframes
player_perf <- data.frame()
match_data <- data.frame()

#Parse json match data
for(i in 1:length(matches))
{
  match_id <- matches[i]$data$match_id
  radiant_win <- matches[i]$data$radiant_victory
  radiant_team <- matches[i]$data$radiant$team$name
  dire_team <- matches[i]$data$dire$team$name
  
  radiant_pp <- cbind(matches[i]$data$radiant$player_performances$player,
                      matches[i]$data$radiant$player_performances$performance$hero,
                      matches[i]$data$radiant$player_performances$performance[-c(1)]) %>%
    select(-items, -abilities) %>%
    mutate(MatchId = match_id, 
           Team = radiant_team, 
           Win = radiant_win)
  
  dire_pp <- cbind(matches[i]$data$dire$player_performances$player, 
                   matches[i]$data$dire$player_performances$performance$hero,
                   matches[i]$data$dire$player_performances$performance[-c(1)]) %>%
    select(-items, -abilities) %>%
    mutate(MatchId = match_id, 
           Team = dire_team, 
           Win = !radiant_win)
  
  match <- data.frame(MatchId = match_id,
                         duration = matches[i]$data$duration,
                         radiant_victory = radiant_win,
                         league_id = matches[i]$data$league$league_id,
                         league_name = matches[i]$data$league$name,
                         patch = matches[i]$data$patch)
  
  player_perf <- rbind(player_perf, radiant_pp) %>%
    rbind(dire_pp)
  
  match_data <- rbind(match_data, match)
  
}

#Exploratory
heal <- player_perf %>%
  
  group_by(MatchId, Win, patch) %>%
  summarise(Team_Heal = sum(hero_healing),
            Team_Damage = sum(hero_damage))

ggplot(heal, aes(x=Team_Heal, y=Team_Damage)) +
  geom_point(aes(colour=Win))

