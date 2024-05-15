library(dplyr)
library(gridExtra)
library(ggplot2)
library(paletteer)

paletteer_c("grDevices::Dynamic", 30)
paletteer_c("grDevices::Purples", 30) 
paletteer_c("grDevices::Blues", 30) 

merged_vcall <- read.csv("/media/paloma/TFM_Paloma/TFM_chromosome_analysis_cleaned.csv")

# Filter by the types of mutations

merged_vcall <- merged_vcall %>%
  mutate(Type = ifelse(MUT_EVENT == "SNP",
                       ifelse(Type %in% c("Non-synonymous", "Synonymous"), Type, NA),
                       as.character(MUT_EVENT)))

#Define colors for each mutation
colores_mut_event <- c("NJ" = "#8576B7FF",
                       "INDEL" = "#E494ABFF",
                       "Non-synonymous" = "#5FB6D4FF",
                       "Synonymous" = "#3269AFFF")  
#Count each event and gruped
datos_resumen <- merged_vcall %>%
  group_by(SPECIES, Type) %>%
  summarise(count = n(), .groups = "drop")

# Represented in a barplot
grafico <- ggplot(datos_resumen, aes(x = SPECIES, y = count, fill = Type)) +
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


# Save as svg
ggsave("~/Descargas/counts_grafico.svg", plot = grafico)
