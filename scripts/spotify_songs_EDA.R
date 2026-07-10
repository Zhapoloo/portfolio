library('tidyverse')
library('skimr')


### IMPORTANDO EL DATASET ###


spo_data <- read_csv('/home/zhapoloo/Documents/practice/Portfolio/dataset.csv')


### LIMPIEZA DE DATOS  ###


#use skim para verificar que no hubiera data faltante o valores nulos y para ver los tipos de datos de cada columna

spo_data |>  skim()
# Aqui use select para eliminar la columna de índice basura y distinct para eliminar duplicados basándose SOLO en el ID y mantener el resto de las columnas
spo_data <- spo_data |> 
  select(-...1) |>  # Destruye la columna de índice basura
  distinct(track_id, .keep_all = TRUE) # Elimina duplicados basándose SOLO en el ID y mantiene el resto de las columnas


### VISUALIZACION DE DATOS ###

#Aqui use pivot_longer para transformar los datos de ancho a largo y luego use facet_wrap para crear histogramas separados para cada columna numérica. Esto me permite ver la distribución de cada variable numérica en el conjunto de datos.
df_long <- spo_data %>%
  select(where(is.numeric)) %>% # mantiene solo las columnas numéricas
  pivot_longer(everything(), names_to = "column", values_to = "value")

# 2. Plot usando ggplot para crear histogramas de cada columna numérica en el conjunto de datos. Cada histograma se muestra en un panel separado gracias a facet_wrap, lo que facilita la comparación de distribuciones entre diferentes variables.
ggplot(df_long, aes(x = value)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  facet_wrap(~column, scales = "free") + # Crea paneles separados para cada columna numérica
  theme_minimal()



# use pivot_longer para transformar los datos de ancho a largo y luego use facet_wrap para crear boxplots separados para cada columna numérica.
# Esto me permite ver la distribución de cada variable numérica en el conjunto de datos y detectar posibles valores atípicos.

# reformatee la columna de datos para que cada variable numérica tenga su propio panel en el gráfico, lo que facilita la comparación de distribuciones entre diferentes variables y la identificación de posibles valores atípicos.
spo_data %>%
  select(where(is.numeric)) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
  ggplot(aes(x = variable, y = value)) +
  geom_boxplot(fill = "lightblue", outlier.color = "red") +
  facet_wrap(~variable, scales = "free") + 
  theme_minimal() +
  theme(axis.text.x = element_blank())   


  ### EDA ###

# Ahora voy a ver la cantidad de canciones que tienen 0 de popularidad y el porcentaje que representan del total de canciones por género,
# esto me ayudará a entender si hay algún sesgo en los datos de popularidad y si ciertos géneros tienen más canciones con baja popularidad que otros.

spo_data |> group_by(track_genre) |>  summarize(low_pop = sum(popularity < 1), total = n(), percentage_off_0 = (low_pop/total)* 100  ) |>  view()


# viendo la forma en la que se recabaron los datos y la cantidad de canciones que tienen 0 de popularidad, me di cuenta que la mayoría de las canciones no son 
populares y que hay un sesgo en los datos de popularidad, ya que ciertos géneros tienen más canciones con baja popularidad que otros. Esto puede afectar el análisis y las conclusiones que se puedan sacar de los datos, pero al saber la forma en la que 
se calcula la popularida basandose en la cantidad de reproducciones y que la mayoría de las canciones no son populares, puedo tener en cuenta este sesgo al analizar los datos y sacar conclusiones más precisas.

#Aqui use summarize para calcular el porcentaje de canciones con liveness menor a 0.5 en el conjunto de datos, lo que me ayudará a entender
# la proporción de canciones que tienen un nivel bajo de "liveness" y cómo esto puede afectar el análisis de los datos.

spo_data |>  summarize(sum(liveness < 0.5) / n())



# Aqui depues de ver como se recaudo la informacion pude ver que la razon por la que las canciones tienen la misma cantidad en cada genero es porque se seleccionaron 1000 por cada genero,
# por lo que no hay un sesgo en la cantidad de canciones por genero, pero si hay un sesgo en la popularidad de las canciones, ya que la mayoría de las canciones no son populares y ciertos generos tienen 
#mas canciones con baja popularidad que otros.


spo_data |> group_by(track_genre) |>  summarize(n(), mean(tempo)) |> view()

# Aqui hice un analisis de correlacion entre la valencia y la danceabilidad para ver si las canciones mas bailables son tambien las mas alegres,
# y si tiene una correlacion positiva por lo que si son mas alegres 

ggplot(spo_data) + geom_point(aes(x=danceability,y=valence)) + geom_smooth(aes(x=danceability,y=valence))
cor(spo_data$valence,spo_data$danceability)


### 1 son las canciones mas populares tambien las mas alegres?
# parece que no hay una correlacion entre la popularidad y la valencia, por lo que no necesariamente las canciones mas populares son las mas alegres.

cor(spo_data$popularity,spo_data$valence)

spo_data |>  group_by(track_genre) |>  summarize(mean(popularity), mean(valence)) |>  view()
ggplot(spo_data) + geom_point(aes(x=spo_data$popularity,y= spo_data$valence)) + geom_smooth(aes(x=spo_data$popularity,y= spo_data$valence))



###Es la musica mas acustica la que tiene menos valencia? 
#si, parece que hay una correlacion negativa entre la valencia y la acusticidad, por lo que las canciones mas acusticas tienden a tener menos valencia.
cor(spo_data$valence, spo_data$acousticness)
spo_data |>  filter(acousticness >0.7) |>  summarize(mean(valence),n())



##son las canciones mas acusticas tambien las menos populares?
#parece que no 
spo_data |> 
  group_by(es_muy_acustica = acousticness > 0.8) |> 
  summarize(
    promedio_popularidad = mean(popularity, na.rm = TRUE),
    total_canciones = n()
  )



##esta la energia relacionada con la danceabilidad?
# no tiene una correlacion muy fuerte, pero si hay una correlacion positiva entre la energia y la danceabilidad, por lo que las canciones mas energicas tienden a ser mas bailables.
cor(spo_data$energy,spo_data$danceability)



##ersta la clave musical relacionada con la valencia?
# no 
cor(spo_data$key,spo_data$valence)

#cuales son las claves musicales mas populares?
# todas las claves musicales tienen la misma popularidad promedio, por lo que no hay una clave musical que sea mas popular que otra.
spo_data |>  group_by(key) |> summarize(mean(popularity)) |>  view()



### EXPORTANDO EL DATASET LIMPIO ###

write.csv(spo_data,'spotidy_data_clean.csv')

