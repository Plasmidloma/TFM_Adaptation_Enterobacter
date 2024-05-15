library(dplyr)
library(gridExtra)
library(ggplot2)
library(paletteer)
library(patchwork) 

paletteer_c("grDevices::Dynamic", 30)
paletteer_c("grDevices::Purples", 30) 
paletteer_c("grDevices::Blues", 30) 

#We selected the colors for each mutational event
colores_mut_event <- c("NJ" = "#8576B7FF",
                       "INDEL" = "#E494ABFF",
                       "Non-synonymous" = "#5FB6D4FF",
                       "Synonymous" = "#3269AFFF")  

merged_vcall <- read.csv("/media/paloma/TFM_Paloma/TFM_chromosome_analysis_cleaned.csv")


## Plasmid Entry in Klebsiella
datos_filtrados1 <- subset(merged_vcall, CONDITION == "Plasmid entry" & SPECIES == "K. pneumoniae")

# Filtered by mutational events 
datos_filtrados1 <- datos_filtrados1 %>%
  mutate(Type = ifelse(MUT_EVENT == "SNP",
                       ifelse(Type %in% c("Non-synonymous", "Synonymous"), Type, NA),
                       as.character(MUT_EVENT)))

# Mutational events counted by type and specie
datos_resumen <- datos_filtrados1 %>%
  group_by(STRAIN, Type) %>%
  summarise(count = n(), .groups = "drop")

# Barplot representation
grafico1 <- ggplot(datos_resumen, aes(x = STRAIN, y = count, fill = Type)) +
  geom_bar(stat = "identity") +
  labs(x = "Species",
       y = "Mutational Events") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.text.y = element_text(size = 8),
        axis.title.x = element_text(size = 8),
        axis.title.y = element_text(size = 8),
        plot.title = element_text(hjust = 0.5, size = 10)) +
  scale_fill_manual(values = colores_mut_event, na.value="#3E79BCFF",
                    labels = c("INDEL", "NJ", "Non-Synonymous", "Synonymous", "Other SNPs"))

## Plasmid entry in E.coli
datos_filtrados1 <- subset(merged_vcall, CONDITION == "Plasmid entry" & SPECIES == "E. coli")


datos_filtrados1 <- datos_filtrados1 %>%
  mutate(Type = ifelse(MUT_EVENT == "SNP",
                       ifelse(Type %in% c("Non-synonymous", "Synonymous"), Type, NA),
                       as.character(MUT_EVENT)))

datos_resumen <- datos_filtrados1 %>%
  group_by(STRAIN, Type) %>%
  summarise(count = n(), .groups = "drop")

grafico2 <- ggplot(datos_resumen, aes(x = STRAIN, y = count, fill = Type)) +
  geom_bar(stat = "identity") +
  labs(x = "Species",
       y = "Mutational Events") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.text.y = element_text(size = 8),
        axis.title.x = element_text(size = 8),
        axis.title.y = element_text(size = 8),
        plot.title = element_text(hjust = 0.5, size = 10)) +
  scale_fill_manual(values = colores_mut_event, na.value="#3E79BCFF",
                    labels = c("INDEL", "NJ", "Non-Synonymous", "Synonymous", "Other SNPs"))

## Curation & E. coli
datos_filtrados1 <- subset(merged_vcall, CONDITION == "Curation" & SPECIES == "E. coli")

# Asignar tipos a los SNPs
datos_filtrados1 <- datos_filtrados1 %>%
  mutate(Type = ifelse(MUT_EVENT == "SNP",
                       ifelse(Type %in% c("Non-synonymous", "Synonymous"), Type, NA),
                       as.character(MUT_EVENT)))

datos_resumen <- datos_filtrados1 %>%
  group_by(STRAIN, Type) %>%
  summarise(count = n(), .groups = "drop")

grafico3 <- ggplot(datos_resumen, aes(x = STRAIN, y = count, fill = Type)) +
  geom_bar(stat = "identity") +
  labs(x = "Species",
       y = "Mutational Events") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.text.y = element_text(size = 8),
        axis.title.x = element_text(size = 8),
        axis.title.y = element_text(size = 8),
        plot.title = element_text(hjust = 0.5, size = 10)) +
  scale_fill_manual(values = colores_mut_event, na.value="#3E79BCFF",
                    labels = c("INDEL", "NJ", "Non-Synonymous", "Synonymous", "Other SNPs")) +
                    coord_cartesian(ylim = c(0, 3))


## Curation + Klebsiella
grafico4 <- ggplot() +
  theme_minimal() +
  labs(x = "Species", y = "Mutational Events") +
  theme(axis.text.x = element_text(size = 8),
        axis.text.y = element_text(size = 8),
        axis.title.x = element_text(size = 10),
        axis.title.y = element_text(size = 10),
        plot.title = element_text(size = 12, hjust = 0.5)) ,
  panel.grid = element_blank() +
  geom_blank(data = NULL, aes(x = c(0, 2), y = c(0, 0))) +
  geom_blank(data = NULL, aes(x = c(0, 0), y = c(0, 2))) +
  coord_cartesian(xlim = c(0, 2), ylim = c(0, 2))




events_per_strain <- grafico1 + grafico2 + grafico3 + grafico4
# Guardar el gráfico como un archivo PNG
ggsave("~/Descargas/events_per_strain.svg", plot = events_per_strain,  width = 9.64, height = 7.45)



##Piecharts for each condition
colores_personalizados <- c("#8576B7FF", "#B0A9D3FF")
##Ex. Plasmid entry in Klebsiella
strains <- c("Mutated", "Not mutated")
cantidades <- c(57, 43)

# Created a datagrame with both data
df <- data.frame(strains, cantidades)

grafico_pie <- ggplot(df, aes(x = "", y = cantidades, fill = strains)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar(theta = "y") +
  theme_void() +
  geom_text(aes(label = cantidades), position = position_stack(vjust = 0.5)) +
  scale_fill_manual(values = colores_personalizados)

ggsave("~/Descargas/Klebsiella_entry.svg", plot = grafico_pie)
