#!/usr/bin/env Rscript
# Adapted from https://github.com/babelomics/drexml-retinitis.git

# ===================================================================
# Script para normalizar datos de expresion génica de GTEx
# y guardarlos en .feather para su uso posterior en hipathia.
# ===================================================================


library(hipathia)
library(feather)
library(edgeR)
library(data.table)
library("R.utils")
library(rlang)

# ===================================================================
# CONFIGURACION
# ===================================================================
# Evitar que annotationHub entre en modo interactivo 
AnnotationHub::setAnnotationHubOption("ASK", FALSE)

# ===================================================================
# FUNCION AUXILIAR
# ===================================================================
# funcion para guardar en formato feather
save_feather <- function(x, path) {
  df <- data.frame(index = row.names(x), x)
  feather::write_feather(df, path)
}

# ===================================================================
# CONTEXTO DE SNAKEMAKE
# ===================================================================
# obtener variables desde el objeto snakemake (en lugar de argumentos por CLI)
gtex_fname <- snakemake@input[["gexp"]]
output <- snakemake@output[[1]]

# obtener wildcards desde objeto snakemake
gtex_version <- snakemake@wildcards[["gtex_version"]]
edger_version <- snakemake@wildcards[["edger_version"]]

cat("Processing GTEx version:", gtex_version, "with edgeR version:", edger_version, "\n")
cat("Input file:", gtex_fname, "\n")
cat("Output file:", output, "\n")

# ===================================================================
# PROCESAMIENTO DE DATOS
# ===================================================================

# cargar datos de expresion como DF desde el .gct etc
expreset_raw <- fread(file = gtex_fname, header = T, sep = "\t") %>% as.data.frame(.)
rownames(expreset_raw) <- expreset_raw$Name
expreset_raw[c("Name", "Description")] <- list(NULL)

# selección de solo 100 muestras del DF para no saturar la RAM
#set.seed(42)  # para reproducibilidad
#expreset_raw <- expreset_raw[, sample(1:ncol(expreset_raw), 100)]  # aleatoria

# lognormalizar conteos 
dge <- DGEList(counts = expreset_raw)
tmm <- calcNormFactors(dge, method = "TMM")
logcpm <- cpm(tmm, prior.count = 3, log = TRUE)
trans_data <- translate_data(logcpm, "hsa")

# crear carpeta de salida si no existe
dir.create(dirname(output), recursive = TRUE, showWarnings = FALSE)

# guardar archivo en .feather 
save_feather(
  trans_data,
  output
)
