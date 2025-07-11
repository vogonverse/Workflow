#!/usr/bin/env Rscript
# Adapted from https://github.com/babelomics/drexml-retinitis.git




# Simular argumentos para pruebas en interactivo
if (interactive()) {
  args <- c(
    "/home/clara/vogonverse/tenFEeme/data/raw/gtex_v10.gct.gz",
    "/home/clara/vogonverse/tenFEeme/data/final/test_output.feather"
  )
} else {
  args <- commandArgs(trailingOnly = TRUE)
}

# Definir rutas de entrada/salida
gtex_fname <- file.path(args[1])
output <- file.path(args[2])

# cargar librerias

library(hipathia)
library(feather)
library(edgeR)
library(data.table)
library("R.utils")
library(rlang)



#########################################
### PROCESAR datasets #####
#########################################



# funcion para guardar en formato feather
save_feather <- function(x, path) {
  df <- data.frame(index = row.names(x), x)
  feather::write_feather(df, path)
}


# Evitar que annotationHub entre en modo interactivo
AnnotationHub::setAnnotationHubOption("ASK", FALSE)

# cargar datos de expresion como DF desde el .gct etc
expreset_raw <- fread(file = gtex_fname, header = T, sep = "\t") %>% as.data.frame(.)
rownames(expreset_raw) <- expreset_raw$Name
expreset_raw[c("Name", "Description")] <- list(NULL)

# Selección de solo 100 muestras del DF para que no me pete el PC
 set.seed(42)  # para reproducibilidad
 expreset_raw <- expreset_raw[, sample(1:ncol(expreset_raw), 100)]  # aleatoria


# lognormalizar conteos
dge <- DGEList(counts = expreset_raw)
tmm <- calcNormFactors(dge, method = "TMM")
logcpm <- cpm(tmm, prior.count = 3, log = TRUE)
trans_data <- translate_data(logcpm, "hsa")


#crear carpeta de salida si no existe
dir.create(dirname(output), recursive = TRUE, showWarnings = FALSE)


# guardar archivo en .feather
save_feather(
  trans_data,
  output
)

