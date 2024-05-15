library(ggplot2)
library(dplyr)
library(janitor)
library(ggpubr)
library(wesanderson)
library(colorBlindness)
library(circlize)
library(BioCircos)
library(tidyverse)
library(car)

###################################################################################################33
# pOXA variants data

library(readODS)

ruta <- "/media/paloma/TFM_Paloma/Projects/TFM_pOXA_analysis.ods"
poxa_seqs <- read_ods(ruta, sheet = 2)

# Define poxa for plotting
len_chr <- 65499
chr_data <- data.frame("pOXA-48", 0, len_chr)
colnames(chr_data) <- c("Region", "Begin", "End")

# Define lines for ploting each replicate

repl_lines <- rbind(chr_data,chr_data,chr_data,chr_data,chr_data,chr_data,chr_data,chr_data,chr_data,chr_data,chr_data,chr_data,chr_data,chr_data,chr_data)
repl_lines$Rep_num <- c(1:15)
mypal <- c(rep("#009e60",2),rep("#da70d6",5),rep("#3883c2",18))

# Begin plot with circlize
circos.clear()
circos.par(start.degree = 90)
circos.genomicInitialize(chr_data, axis.labels.cex = 0.8*par("cex"), labels.cex =  1.8*par("cex"))

#unique_labels <- strain_summary_circa[!duplicated(strain_summary_circa$Gene), ]
#circos.labels(sectors = c(rep("Chromosome", length(unique_labels$Position))), x = unique_labels$Position, labels = unique_labels$Gene, side = "outside", cex = 0.6)
circos.genomicTrack(data = poxa_seqs,
                    #cell.padding = c(0.05, 1.00, 0.05, 1.00),
                    numeric.column = c("POSITION"),
                    track.height = 0.7,
                    panel.fun = function(region, value,...) {
                      #circos.genomicPoints(region, value,...)
                      #circos.genomicLines(region, value, type = "segment",...)
                    }) 



#circos.rect(track.index = 2,col = "#4cae4acc")
y <- seq(1,7, by = 1)
circos.segments(0,y,len_chr,y, track.index = 2, lwd = 4.5, col = "#6d7278")

# Draw non-synonymus SNPs as points
circos.genomicPoints(region = poxa_seqs %>%
                       filter(MUT_EVENT == "Non-synonymous") %>%
                       select(Position, end),
                     value = poxa_seqs %>%
                       filter(MUT_EVENT == "Non-synonymous") %>%
                       select(sample_num),
                     track.index = 2,
                     pch = 16, cex = 2)
# Draw intergenic SNPs as empty points
circos.genomicPoints(region = poxa_seqs %>%
                       filter(MUT_EVENT == "Intergenic") %>%
                       select(Position, end),
                     value = poxa_seqs %>%
                       filter(MUT_EVENT == "Intergenic") %>%
                       select(sample_num),
                     track.index = 2,
                     pch = 1, cex = 2)

# Draw New Junctions as squares
circos.genomicPoints(region = poxa_seqs %>%
                       filter(MUT_EVENT == "NJ") %>%
                       select(Position, end),
                     value = poxa_seqs %>%
                       filter(MUT_EVENT == "NJ") %>%
                       select(sample_num),
                     track.index = 2,
                     pch = 15, cex = 2)
circos.clear()
