library(tibble)
library(ggplot2)
library(dplyr)
library(reshape2)
library(tidyr)
library(paletteer)
library(readODS)
library(gdata)

paletteer_c("grDevices::Purples", 30)
paletteer_c("grDevices::Dynamic", 30)


ptable <- read_ods("/home/paloma/Escritorio/Máster/TFM/Abricate/ARGs_strains.ods")

ptable <- as.data.frame(subset(ptable, select = -c(2)))

ptable <- ptable %>%
  column_to_rownames(var = "#FILE")

straincol <- rep(rownames(ptable), each = 71)

colnames(ptable) <- as.character(colnames(ptable))

# Convert the dataframe to long format
ptable4heatmap <- ptable %>%
  pivot_longer(cols = everything(),
               names_to = "ARGs",
               values_to = "Presence")

ptable4heatmap$Strain <- straincol
ptable4heatmap$Presence <- as.numeric(ptable4heatmap$Presence)
ptable4heatmap <- as.data.frame(ptable4heatmap)


ptable4heatmap %>%
  ggplot(aes(x = Strain, y = ARGs, fill = Presence)) +
  geom_tile() +
  scale_fill_gradient(low = "#B0A9D3FF", high = "#442280FF") +
  theme_bw() +
  ylab("Plasmid") +
  xlab("Strain") +
  theme(axis.text.x=element_text(angle = 90, hjust = 1, vjust = 0.5)) +
  theme(axis.text.y=element_text(angle = 0, hjust = 1, vjust = 0.5, size = 7, face = "italic")) +
  theme(strip.background = element_blank())

ggsave("ARGs.svg", plot = last_plot(), width = 10, height = 8)

##For the plasmids
ptable <- read_ods("/home/paloma/Escritorio/Máster/TFM/Abricate/Plasmids_strains.ods")

ptable <- as.data.frame(subset(ptable, select = -c(2)))

ptable <- ptable %>%
  column_to_rownames(var = "#FILE")

straincol <- rep(rownames(ptable), each = 41)

colnames(ptable) <- as.character(colnames(ptable))

# Convert the dataframe to long format
ptable4heatmap <- ptable %>%
  pivot_longer(cols = everything(),
               names_to = "ARGs",
               values_to = "Presence")

ptable4heatmap$Strain <- straincol
ptable4heatmap$Presence <- as.numeric(ptable4heatmap$Presence)
ptable4heatmap <- as.data.frame(ptable4heatmap)


ptable4heatmap %>%
  ggplot(aes(x = Strain, y = ARGs, fill = Presence)) +
  geom_tile() +
  scale_fill_gradient(low = "#B0A9D3FF", high = "#442280FF") +
  theme_bw() +
  ylab("Plasmid") +
  xlab("Strain") +
  theme(axis.text.x=element_text(angle = 90, hjust = 1, vjust = 0.5)) +
  theme(axis.text.y=element_text(angle = 0, hjust = 1, vjust = 0.5, size = 7)) +
  theme(strip.background = element_blank())

# Guardar la figura como un archivo PDF
ggsave("Plasmids.svg", plot = last_plot(), width = 10, height = 8)
