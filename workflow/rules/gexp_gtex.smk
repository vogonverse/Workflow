# reglas para gexp_gtex.smk

rule download_gtex:
    input:
        script="scripts/downloader.py",
    output:
        "data/raw/gtex_v{gtex_version}.gct.gz",
    conda:
        "../../envs/py.yaml"
    log:
        "logs/download_gtex_{gtex_version}.log"
    shell:
        "python {input.script} download-gtex --version {wildcards.gtex_version} --output {output} 2> {log}"

rule normalize_gexp:
    input:
        gexp="data/raw/gtex_v{gtex_version}.gct.gz",
        script="scripts/normalize_gexp.R",
    output:
        "data/interim/genesasrows_gexp_gtex-v{gtex_version}_edger-v{edger_version}.feather",
    conda:
        "../../envs/r.yaml"
    log:
        "logs/normalize_gexp_{gtex_version}_{edger_version}.log"
    shell:
        "Rscript --vanilla {input.script} {input.gexp} {output} 2> {log}"

rule transpose_gtex:
    input:
        gex="data/interim/genesasrows_gexp_gtex-v{gtex_version}_edger-v{edger_version}.feather",
        script="scripts/transpose_gtex.R"
    output:
        "data/interim/gexp_gtex-v{gtex_version}_edger-v{edger_version}.feather"
    conda:
        "../../envs/r.yaml"
    log:
        "logs/transpose_gtex_{gtex_version}_{edger_version}.log"
    shell:
        "Rscript --vanilla {input.script} {input.gex} {output} 2> {log}"

rule translate_gtex:
    input:
        gex="data/interim/gexp_gtex-v{gtex_version}_edger-v{edger_version}.feather",
        script="scripts/parser.py"
    output:
        "data/final/genes_gtex-v{gtex_version}_edger-v{edger_version}_mygene-v{mg_version}.tsv.gz"
    conda:
        "../../envs/py.yaml"
    log:
        "logs/translate_gtex_{gtex_version}_{edger_version}_{mg_version}.log"
    shell:
        "python {input.script} translate --kind gtex {input.gex} {output} 2> {log}"





























































