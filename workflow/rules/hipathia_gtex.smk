# reglas para hipathia_gtex.smk

rule compute_hipathia: 
    input:
        gexp_norm = "data/interim/genesasrows_gexp_gtex-v{gtex_version}_edger-v{edger_version}.feather",
    output:
        pathvals = "data/final/pathvals_gtex-v{gtex_version}_edger-v{edger_version}_hipathia-v{hipathia_version}.feather",
        pathvals_norm = "data/final/pathvals_gtex-v{gtex_version}_edger-v{edger_version}_hipathia-norm-v{hipathia_version}.feather"
    conda:
        "../../envs/r.yaml"
    resources:
        runtime=600,
        mem_mb=100_000,
    log:
        "logs/compute_hipathia_{gtex_version}_{edger_version}_{hipathia_version}.log"
    benchmark:
        "benchmarks/compute_hipathia_{gtex_version}_{edger_version}_{hipathia_version}.txt"
    script:
        "../../scripts/hipathize.R"


rule build_disease:
    input:
        genes = rules.filter_drugbank.output.genes_filt,
        gex = rules.transpose_gtex.output,
        pathvals = rules.compute_hipathia.output.pathvals
    output:
        "results/drugbank-v{db_version}_gtex-v{gtex_version}_edger-v{edger_version}_mygene-v{mg_version}_v{hipathia_version}_drexml-v{drexml_version}/{disease_id}/disease.env"
    conda:
        "../../envs/r.yaml"
    log:
        "logs/build_disease_{db_version}_{gtex_version}_{edger_version}_{mg_version}_{hipathia_version}_{drexml_version}_{disease_id}.log"
    benchmark:
        "benchmarks/build_disease_{db_version}_{gtex_version}_{edger_version}_{mg_version}_{hipathia_version}_{drexml_version}_{disease_id}.txt"
    shell:
        "echo -e 'disease_id={wildcards.disease_id}\nuse_physio=false\npathvals={input.pathvals}\ngene_exp=data/interim/gexp_gtex-v{wildcards.gtex_version}_edger-v{wildcards.edger_version}.feather\ngenes={input.genes}' > {output} 2> {log}"
