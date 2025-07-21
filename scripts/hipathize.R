#!/usr/bin/env Rscript
# Adaptaed from https://github.com/babelomics/drexml-retinitis.git

# ===================================================================
# Script para análisis de pathways con Hipathia.
# Procesa datos normalizados de GTEx y calcula señales de pathway
# ===================================================================

library(hipathia)
library(feather)
library(edgeR)
library(data.table)
library("R.utils")
library(rlang)
library(purrr)

# ===================================================================
# CONFIGURACION
# ===================================================================
# Evitar que annotationHub entre en modo interactivo
AnnotationHub::setAnnotationHubOption("ASK", FALSE)

# ===================================================================
# FUNCION AUXILIAR
# ===================================================================
save_feather <- function(x, path) {
  df <- data.frame(index = row.names(x), x)
  write_feather(df, path)
}

# ===================================================================
# CONTEXTO DE SNAKEMAKE
# ===================================================================
# obtener variables desde el objeto snakemake (en lugar de argumentos por CLI)
input_path <- snakemake@input[["gexp_norm"]]
output_path <- snakemake@output[["pathvals"]]
output_norm_path <- snakemake@output[["pathvals_norm"]]

# obtener wildcards desde objeto snakemake
gtex_version <- snakemake@wildcards[["gtex_version"]]
edger_version <- snakemake@wildcards[["edger_version"]]
hipathia_version <- snakemake@wildcards[["hipathia_version"]]

cat("Processing Hipathia analysis:\n")
cat("  GTEx version:", gtex_version, "\n")
cat("  EdgeR version:", edger_version, "\n") 
cat("  Hipathia version:", hipathia_version, "\n")
cat("  Input file:", input_path, "\n")
cat("  Output pathvals:", output_path, "\n")
cat("  Output pathvals norm:", output_norm_path, "\n")

# ===================================================================
# PROCESAMIENTO DE DATOS
# ===================================================================

# lee los datos de expresion normalizados (genes == filas)
trans_data <- as.data.frame(feather::read_feather(input_path))
rownames(trans_data) <- trans_data[["index"]]
trans_data[["index"]] <- NULL

# escala los datos
exp_data <- normalize_data(as.matrix(trans_data))

# carga pathways humanos
pathways <- load_pathways("hsa")

# calcula las señales de pathway
results <- hipathia(exp_data, pathways, decompose = FALSE, verbose = FALSE)
path_vals <- get_paths_data(results, matrix = TRUE)
path_vals_norm <- normalize_paths(path_vals, pathways)

# crear carpetas de salida si no existen
dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)
dir.create(dirname(output_norm_path), recursive = TRUE, showWarnings = FALSE)

save_feather(
  t(path_vals),
  output_path
)

save_feather(
  t(path_vals_norm),
  output_norm_path
)