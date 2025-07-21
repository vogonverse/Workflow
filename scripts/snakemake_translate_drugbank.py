# ===================================================================
# Adaptador para traducción de genes de DrugBank.
#
# Extrae variables del contexto del workflow a parámetros de función
# para evitar el conflicto entre la directiva script: y la click CLI
# con el proposito de llamar a la funcion de traduccion.
# ===================================================================

import sys
from pathlib import Path

# añadir el directorio de scripts al path
sys.path.append(str(Path(__file__).parent))

from parser import translate

# extraccion de variables a partir del objeto snakemake
input_file = snakemake.input.parsed
output_file = snakemake.output[0]

print(f"Snakemake translate_drugbank: input={input_file}, output={output_file}")

# llamada a funcion pura directamente con tipo de datos
translate(input_file, output_file, "drugbank")