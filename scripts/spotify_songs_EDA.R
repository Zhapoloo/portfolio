library('tidyverse')
library('skimr')
spo_data <- read_csv('/home/zhapoloo/Documents/practice/Portfolio/dataset.csv')
#i used skimm_wituout_charts to check 2 things the first one is to make sure the data is comple 
#and the second one is to make sure that each column has the correct data type 

spo_data |>  skim()

spo_data <- spo_data |> 
  select(-...1) |>  # Destruye la columna de índice basura
  distinct(track_id, .keep_all = TRUE) # Elimina duplicados basándose SOLO en el ID y mantiene el resto de las columnas
# here i plotted all the numeric columns so that i could see the distrubution of each 

# 1. Reshape the data to long format
df_long <- spo_data %>%
  select(where(is.numeric)) %>% # Keep only numeric columns
  pivot_longer(everything(), names_to = "column", values_to = "value")

# 2. Plot using facet_wrap
ggplot(df_long, aes(x = value)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  facet_wrap(~column, scales = "free") + # Creates separate plots
  theme_minimal()



# i will use boxplots to determine the distrubution and outliers on the data 

# 1. Reshape and Plot
spo_data %>%
  select(where(is.numeric)) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
  ggplot(aes(x = variable, y = value)) +
  geom_boxplot(fill = "lightblue", outlier.color = "red") +
  facet_wrap(~variable, scales = "free") + # Give each plot its own scale
  theme_minimal() +
  theme(axis.text.x = element_blank())    # Clean up the labels

#now with the infomation displayed what i will do next is to check those values that seem off like on the popularity seems off having more on 0 thatn in any other bar


spo_data |> group_by(track_genre) |>  summarize(low_pop = sum(popularity < 1), total = n(), percentage_off_0 = (low_pop/total)* 100  ) |>  view()

# for popularity either the data is skew or was not recorder properly i have to look into the way is calculated as several genres have over 60% on 0  so based 
# on what i found seems like the more and most recent played songs have more popularity that makes sence as to why there are so much 0es but stil i will treat this 
# popularity column with care as seems skew due to more experimental users being on other platforms like tidal spotify is more mainstream 

#here i determnied what percentage of of the track seemed to be live and basically most of them were not 

spo_data |>  summarize(sum(liveness < 0.5) / n())



# here i confirmed that the temp is not skew for more on certain genres thatn in others and i found 2 things first that the amount of songs is the exact same sound made up


spo_data |> group_by(track_genre) |>  summarize(n(), mean(tempo)) |> view()

#here i checked to confirm that the info was accurate and yes music like classical tend to be on lower numbers while metal and dubstep tend to be much more higher so is accurate

spo_data |>  group_by(track_genre) |>  summarize(sum(acousticness < 0.1),n()) |>  view()

# here i made an scatter plot along with an smooth line to check how likely the cheerfull music is more dansable and seems to be a correlation
# but is lower than expected only 0.47 now even 50%

ggplot(spo_data) + geom_point(aes(x=danceability,y=valence)) + geom_smooth(aes(x=danceability,y=valence))
cor(spo_data$valence,spo_data$danceability)


### to answer the question if the most danceable songs are the more cheerfull the answer is likely a no






#### second question are the more popular songs cheerfull or not?
# at least for the correlation no it shows to be in a middle point not too sad or cheerfull 
cor(spo_data$popularity,spo_data$valence)

spo_data |>  group_by(track_genre) |>  summarize(mean(popularity), mean(valence)) |>  view()
ggplot(spo_data) + geom_point(aes(x=spo_data$popularity,y= spo_data$valence)) + geom_smooth(aes(x=spo_data$popularity,y= spo_data$valence))



###3rd question is the acustic music considered sad or happy?
#sad, seems to be sad songs the ones that usually are interpreted on acoustics
cor(spo_data$valence, spo_data$acousticness)
spo_data |>  filter(acousticness >0.7) |>  summarize(mean(valence),n())



##4th are acoustic songs popular?
#no they are not
spo_data |> 
  group_by(es_muy_acustica = acousticness > 0.8) |> 
  summarize(
    promedio_popularidad = mean(popularity, na.rm = TRUE),
    total_canciones = n()
  )



##5th is the energy realted to the danceability ?
#at least in correlation no it is not 
cor(spo_data$energy,spo_data$danceability)



##6th is the valence related to the key?
cor(spo_data$key,spo_data$valence)

## what are the most popular keys
## all has the same number about so either the data is made up or they are very likely
spo_data |>  group_by(key) |> summarize(mean(popularity))

write.csv(spo_data,'spotidy_data_clean.csv')

