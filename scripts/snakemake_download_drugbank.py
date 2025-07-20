# ===================================================================
# Adaptador para descarga de datos de DrugBank.
#
# Extrae variables del contexto del workflow a parametros de funcion
# para evitar el conflicto entre la directiva script: y la click CLI
# con el proposito de llamar a la funcion de descarga.
# ===================================================================

import sys
from pathlib import Path

# añadir el directorio de scripts al path
sys.path.append(str(Path(__file__).parent))

from parser import download_drugbank

# extraccion de variables a partir del objeto snakemake
version = snakemake.wildcards.db_version
filename = snakemake.output[0]

print(f"Snakemake download_drugbank: version={version}, filename={filename}")

# llamada a funcion pura directamente
download_drugbank(version=version, filename=filename)