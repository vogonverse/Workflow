# ===================================================================
# Adaptador para parseo de XML DrugBank.
#
# Extrae variables del contexto del workflow a parametros de funcion
# para evitar el conflicto entre la directiva script: y la click CLI
# con el proposito de llamar a la funcion de parseo.
# ===================================================================

import sys
from pathlib import Path

# añadir el directorio de scripts al path
sys.path.append(str(Path(__file__).parent))

from parser import parse

# extraccion de variables a partir del objeto snakemake
xml_path = snakemake.input.xml
output_path = snakemake.output[0]

print(f"Snakemake parse_drugbank: xml={xml_path}, output={output_path}")

# llamada a funcion pura directamente (use_groups=False por defecto)
parse(xml_path, output_path, use_groups=False)