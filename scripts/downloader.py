# ========================================================================
# Script modificado sin click para compatibilidad con la directiva script:
#
# Funciones puras para descarga de datos de GTeX desde scripts adaptadores
# ========================================================================

#!/usr/bin/env python
# -*- coding: utf-8 -*-

import requests
THIS_VERSION = 1.0


def build_gtex_url(version, qcv="RNASeQCv2.4.2"):
    """Build gtex url from versions."""
    url_parts = [
        "https://storage.googleapis.com",
        "adult-gtex",
        "bulk-gex",
        f"v{version}",
        "rna-seq",
        f"GTEx_Analysis_v{version}_{qcv}_gene_reads.gct.gz",
    ]
    return "/".join(url_parts)



def download_gtex_data(version, output_file):
    """Downloads the GTeX rnaseq database.

    Args:
        version: GTeX version 
        output_file: Output filename
    """
    url = build_gtex_url(version=version)
    
    print(f"Downloading GTEx v{version} from: {url}")

    try:
        response = requests.get(url, stream=True, timeout=100)
        response.raise_for_status() 

        with open(output_file, "wb") as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)

        
        print(f"GTeX rnaseq database downloaded successfully to {output_file}")

    except requests.exceptions.RequestException as e:
        
        print(f"Error downloading GTeX rnaseq database: {e}")
        raise
