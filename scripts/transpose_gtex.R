#!/usr/bin/env Rscript
# Adaptaed from https://github.com/babelomics/drexml-retinitis.git

# ===================================================================
# Script para transponer datos normalizados de GTEx
# de genes en filas a genes en columnas.
# ===================================================================

library(hipathia)
library(feather)
library(edgeR)
library(data.table)
library("R.utils")

# ===================================================================
# CONFIGURACION
# ===================================================================
# Evitar que annotationHub entre en modo interactivo
AnnotationHub::setAnnotationHubOption("ASK", FALSE)

# ===================================================================
# FUNCIÓN AUXILIAR
# ===================================================================
save_feather <- function(x, path) {
  df <- data.frame(index = row.names(x), x)
  write_feather(df, path)
}

# ===================================================================
# CONTEXTO DE SNAKEMAKE
# ===================================================================
# obtener variables desde el objeto snakemake (en lugar de argumentos por CLI)
input_path <- snakemake@input[["gex"]]
output_path <- snakemake@output[[1]]

# obtener wildcards desde objeto snakemake
gtex_version <- snakemake@wildcards[["gtex_version"]]
edger_version <- snakemake@wildcards[["edger_version"]]

cat("Transposing GTEx version:", gtex_version, "with edgeR version:", edger_version, "\n")
cat("Input file:", input_path, "\n")
cat("Output file:", output_path, "\n")

# ===================================================================
# PROCESAMIENTO DE DATOS
# ===================================================================

# lee los datos de expresion normalizados (genes == filas) 
trans_data <- as.data.frame(feather::read_feather(input_path))
rownames(trans_data) <- trans_data[["index"]]
trans_data[["index"]] <- NULL

# los transpone (genes == columnas) y guarda
save_feather(
  t(trans_data),
  output_path
)