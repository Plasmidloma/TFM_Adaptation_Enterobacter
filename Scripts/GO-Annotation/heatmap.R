# Instala e importa las librerías necesarias
#install.packages("tidyverse", "reshape2")
#install.packages("readODS")
#install.packages("tidyr")

#library("readcsv")
library(tidyverse)
library(reshape2)
library(readODS)
library(tidyr)
library(ggplot2)
library(paletteer)
library(dplyr)
#colores
#install.packages("devtools") 
#devtools::install_github("jbgb13/peRReo") 
#library(peRReo)

paletteer_c("grDevices::Dynamic", 30)
paletteer_c("grDevices::Purples", 30) 

# Define color palette
palette <- c("1" = "#D3CFE9FF", "2" = "#B0A9D3FF", "3" = "#8C7FBBFF", "4" = "#442280FF")


data <- read_ods("/media/paloma/TFM_Paloma/TFM_chromosome_analysis_cleaned.ods", sheet = 3)
data$nombre <- data$SPECIES

# separate the molecular functions by comma since there may be several in the same row
data_sep <- data %>%
  separate_rows(Molecular_Function, sep = ",")

# Filter rows with NA or '-'
data_filter <- data_sep %>%
  filter(!is.na(Molecular_Function) & Molecular_Function != '-')

# The coincidences were counted
count <- data_filter %>%
  count(nombre, Molecular_Function) %>%
  filter(n > 0)

# Heatmap was plotted and save
heatmap_plot <- ggplot(count, aes(x = nombre, y = Molecular_Function, fill = n)) +
  geom_tile(color = "white") +
  scale_fill_gradientn(colours = palette) +
  theme_gray() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
                                    axis.text.y = element_text(size = 7)) +
  labs(x = "Especie", y = "Molecular Function", fill = "counts")

ggsave("~/Descargas/Molecular_function.png", plot = heatmap_plot, width = 10, height = 8, units = "in", dpi = 300)



### BIOLOGICAL PROCESS
data <- read_ods("/media/paloma/TFM_Paloma/TFM_chromosome_analysis_cleaned.ods", sheet = 3)


data$nombre <- data$SPECIES
#Separate the BPs by ','
data_sep <- data %>%
  separate_rows(Biological_Procces, sep = ",")

# Filter those files with '-' as NA
data_filter <- data_sep %>%
  filter(!is.na(Biological_Procces) & Biological_Procces != '-')

# The coincidences were counted
count <- data_filter %>%
  count(nombre, Biological_Procces) %>%
  filter(n > 0)

# Heatmap was plotted and save
heatmap_plot <- ggplot(count, aes(x = nombre, y = Biological_Procces, fill = n)) +
  geom_tile(color = "white") +
  scale_fill_gradientn(colours = palette) +
  theme_gray() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
        axis.text.y = element_text(size = 7)) +
  labs(x = "Especie", y = "Molecular Function", fill = "counts")

ggsave("~/Descargas/Biological_Process.png", plot = heatmap_plot, width = 8, height = 6, units = "in", dpi = 300)
