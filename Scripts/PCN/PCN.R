library(ggplot2)
library(paletteer)


datos <- read.csv("/media/paloma/TFM_Paloma/Projects/PCN/pcn.csv")

#Data grouped by Mutation in repA/repC present and by species
medias <- aggregate(mean_ratio ~ Specie + MUTATED, data = datos, FUN = mean)
colors <- c( "#E494ABFF","#8576B7FF")

# Boxplot
plot <- { 
  ggplot(datos, aes(x = Specie, y = mean_ratio, fill = MUTATED)) +
    geom_boxplot() +
    geom_point(position = position_dodge(width = 0.75), alpha = 0.5, size = 1, shape = 1) +  # alpha es opacidad, size tamaño
    scale_fill_manual(values = colors) + 
    labs(x = "Species",
         y = "Mean Ratio",
         fill = "Mutated") +
    theme_minimal() +
    theme(axis.text.x = element_text(face = "italic"),
          panel.grid.major = element_blank()) #delete the biggest rack
}
#Save
ggsave("~/Descargas/PNC.svg", plot, width = 6, height = 4)


#Dots with jitter to check if it's more clear
plot2 <-{ggplot(datos, aes(x = Specie, y = mean_ratio, fill = MUTATED)) +
  geom_boxplot() +
  geom_point(position = position_jitter(width = 0.3), alpha = 0.5, size = 1, shape = 1) +  
  scale_fill_manual(values = colors) +  
  labs(x = "Specie", 
       y = "Mean Ratio",
       fill = "Mutated") +
  theme_minimal() +
  theme(axis.text.x = element_text(face = "italic"))
}
ggsave("~/Descargas/PNC_jitter.png", plot2, width = 6, height = 4)

#Student's t-test:
t_test_result <- by(datos, datos$Specie, function(x) {
  t_test_mutated <- t.test(x$mean_ratio[x$MUTATED == "Y"], x$mean_ratio[x$MUTATED == "N"])
  return(t_test_mutated)
})

for (i in seq_along(t_test_result)) {
  cat("Specie:", names(t_test_result)[i], "\n")
  cat("T-test (mutated vs non-mutated):\n")
  print(t_test_result[[i]])
  cat("\n")
}
