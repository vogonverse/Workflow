# =================================================================
# Adaptador para descarga de datos de GTEx.
#
# Extrae variables del contexto del workflow a parametros de funcion 
# para evitar el conflicto entre la directiva script: y la click CLI
# con el proposito de llamar a la funcion de descarga.
# =================================================================

import sys
from pathlib import Path

# añadir el directorio de scripts al path
sys.path.append(str(Path(__file__).parent))

from downloader import download_gtex_data

# variables a partir del objeto snakemake 
version = snakemake.wildcards.gtex_version
output_file = snakemake.output[0]

print(f"Snakemake download_gtex: version={version}, output={output_file}")

# llamada a función pura directamente
download_gtex_data(version, output_file)