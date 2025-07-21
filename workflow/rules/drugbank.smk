# reglas para drugbank.smk

rule download_drugbank: #
    input:
        setup="data/.setup_done"
    output:
        "data/raw/drugbank_{db_version}.zip"
    conda:
        "../../envs/py.yaml"
    log:
        "logs/download_drugbank_{db_version}.log"
    script:
        "../../scripts/snakemake_download_drugbank.py"


rule parse_drugbank: #
    input:
        xml="data/raw/drugbank_{db_version}.zip",
        check="data/interim/drugbank_{db_version}.checked"
    output:
        "data/interim/drugbank_{db_version}.tsv.gz"
    conda:
        "../../envs/py.yaml"
    log:
        "logs/parse_drugbank_{db_version}.log"
    script:
        "../../scripts/snakemake_parse_drugbank.py"



rule translate_drugbank: #
    input:
        parsed="data/interim/drugbank_{db_version}.tsv.gz"
    output:
        "data/final/genes_drugbank-v{db_version}_mygene-v{mg_version}.tsv.gz"
    conda:
        "../../envs/py.yaml"
    log:
        "logs/translate_drugbank_{db_version}_{mg_version}.log"
    script:
        "../../scripts/snakemake_translate_drugbank.py"





rule filter_drugbank: #
    input:
        dbank = "data/interim/drugbank_{db_version}.tsv.gz",
        dbank_genes = "data/final/genes_drugbank-v{db_version}_mygene-v{mg_version}.tsv.gz",
        gtex_genes = "data/final/genes_gtex-v{gtex_version}_edger-v{edger_version}_mygene-v{mg_version}.tsv.gz",
    output:
        genes_filt = "data/final/genes-drugbank-v{db_version}_gtex-v{gtex_version}_edger-v{edger_version}_mygene-v{mg_version}.tsv.gz",
        db_filt = "data/final/drugbank-v{db_version}_gtex-v{gtex_version}_edger-v{edger_version}_mygene-v{mg_version}.tsv.gz",
    conda:
        "../../envs/py.yaml"
    log:
        "logs/filter_drugbank_{db_version}_{gtex_version}_{edger_version}_{mg_version}.log"
    script:
        "../../scripts/snakemake_filter_drugbank.py"




rule check_drugbank_integrity:
    input:
        zipfile = "data/raw/drugbank_{db_version}.zip",
        checksum = "versions/drugbank_v{db_version}.zip.sha256"
    output:
        "data/interim/drugbank_{db_version}.checked"
    conda:
        "../../envs/py.yaml"
    log:
        "logs/check_drugbank_integrity_{db_version}.log"
    shell:
        """
        sha256sum -c <(awk '{{print $1 "  {input.zipfile}"}}' {input.checksum}) > {log} 2>&1

        # si todo ok crear archivo de verificacion
        if [ $? -eq 0 ]; then
            touch {output}
        else
            echo "checksum de verificacion caca" >&2
            exit 1
        fi
        """