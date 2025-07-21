# ====================================================================
# Adaptador para filtrado de datos de DrugBank.
#
# Extrae variables del contexto del workflow a parámetros de función
# para evitar el conflicto entre la directiva script: y la click CLI
# con el proposito de llamar a la funcion de filtrado.
# ====================================================================

import sys
from pathlib import Path

# añadir el directorio de scripts al path
sys.path.append(str(Path(__file__).parent))

from parser import filter_db

# extraccion de variables a partir del objeto snakemake
drugbank_path = snakemake.input.dbank
drugbank_genes_path = snakemake.input.dbank_genes
gtex_genes_path = snakemake.input.gtex_genes
drugbank_output = snakemake.output.db_filt
genes_output = snakemake.output.genes_filt


print(f"Snakemake filter_drugbank:")
print(f"  drugbank_path: {drugbank_path}")
print(f"  drugbank_genes_path: {drugbank_genes_path}")
print(f"  gtex_genes_path: {gtex_genes_path}")
print(f"  drugbank_output: {drugbank_output}")
print(f"  genes_output: {genes_output}")

# llamada a funcion pura directamente
filter_db(
    drugbank_output=drugbank_output,
    genes_output=genes_output,
    drugbank_path=drugbank_path,
    drugbank_genes_path=drugbank_genes_path,
    gtex_genes_path=gtex_genes_path
)