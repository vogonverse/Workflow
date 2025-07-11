# reglas para drugbank.smk

rule download_drugbank:
    input:
        setup="data/.setup_done"
    output:
        "data/raw/drugbank_{db_version}.zip"
    params:
        script="scripts/parser.py"
    conda:
        "../../envs/py.yaml"
    log:
        "logs/download_drugbank_{db_version}.log"
    shell:
        "python {params.script} download-drugbank --version {wildcards.db_version} --filename {output} > {log} 2>&1"



rule parse_drugbank:
    input:
        xml="data/raw/drugbank_{db_version}.zip",
        check="data/interim/drugbank_{db_version}.checked"
    output:
        "data/interim/drugbank_{db_version}.tsv.gz"
    params:
        script="scripts/parser.py"
    conda:
        "../../envs/py.yaml"
    log:
        "logs/parse_drugbank_{db_version}.log"
    shell:
        "python {params.script} parse {input.xml} {output} > {log} 2>&1"



rule translate_drugbank:
    input:
        parsed="data/interim/drugbank_{db_version}.tsv.gz"
    output:
        "data/final/genes_drugbank-v{db_version}_mygene-v{mg_version}.tsv.gz"
    params:
        script="scripts/parser.py"
    conda:
        "../../envs/py.yaml"
    log:
        "logs/translate_drugbank_{db_version}_{mg_version}.log"
    shell:
        "python {params.script} translate --kind drugbank {input.parsed} {output} > {log} 2>&1"

    
  

rule filter_drugbank:
    input:
        #dbank = rules.parse_drugbank.output,
        dbank = rules.parse_drugbank.output,
        dbank_genes = rules.translate_drugbank.output,
        gtex_genes = rules.translate_gtex.output,
        script = "scripts/parser.py",
       # integrity_check = "data/interim/drugbank_{db_version}.checked"  # tiene que existir!
    output:
        genes_filt = "data/final/genes-drugbank-v{db_version}_gtex-v{gtex_version}_edger-v{edger_version}_mygene-v{mg_version}.tsv.gz",
        db_filt = "data/final/drugbank-v{db_version}_gtex-v{gtex_version}_edger-v{edger_version}_mygene-v{mg_version}.tsv.gz",
    conda:
        "../../envs/py.yaml",
    log:
        "logs/filter_drugbank_{db_version}_{gtex_version}_{edger_version}_{mg_version}.log",
    shell:
        """
        python {input.script} filter-db \
            --drugbank-path {input.dbank} \
            --drugbank-genes-path {input.dbank_genes} \
            --gtex-genes-path {input.gtex_genes} \
            {output.db_filt} {output.genes_filt} > {log} 2>&1
        """
             
        


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
