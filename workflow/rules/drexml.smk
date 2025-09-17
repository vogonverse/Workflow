# reglas para drexml.smk



rule repurpose:
    input:
        disease="results/drugbank-v{db_version}_gtex-v{gtex_version}_edger-v{edger_version}_mygene-v{mg_version}_v{hipathia_version}_drexml-v{drexml_version}/{disease_id}/disease.env",
    output:
        rel="results/drugbank-v{db_version}_gtex-v{gtex_version}_edger-v{edger_version}_mygene-v{mg_version}_v{hipathia_version}_drexml-v{drexml_version}/{disease_id}/results/shap_summary_symbol.tsv",
        sel="results/drugbank-v{db_version}_gtex-v{gtex_version}_edger-v{edger_version}_mygene-v{mg_version}_v{hipathia_version}_drexml-v{drexml_version}/{disease_id}/results/shap_selection_symbol.tsv",
        res="results/drugbank-v{db_version}_gtex-v{gtex_version}_edger-v{edger_version}_mygene-v{mg_version}_v{hipathia_version}_drexml-v{drexml_version}/{disease_id}/results/stability_results_symbol.tsv",
        tmp=directory(
                "results/drugbank-v{db_version}_gtex-v{gtex_version}_edger-v{edger_version}_mygene-v{mg_version}_v{hipathia_version}_drexml-v{drexml_version}/{disease_id}/results/tmp"
            )
        ,
    conda:
        "../../envs/py.yaml" 
    resources:
        mem_gb=200         #cluster
    threads: 20            
    log:
        "logs/repurpose_{db_version}_{gtex_version}_{edger_version}_{mg_version}_{hipathia_version}_{drexml_version}_{disease_id}.log",
    benchmark:
        "benchmarks/repurpose_{db_version}_{gtex_version}_{edger_version}_{mg_version}_{hipathia_version}_{drexml_version}_{disease_id}.txt"
    shell:
        """
        drexml run {input.disease} > {log} 2>&1
        """

rule plot_drexml:
    input:
        rel="results/drugbank-v{db_version}_gtex-v{gtex_version}_edger-v{edger_version}_mygene-v{mg_version}_v{hipathia_version}_drexml-v{drexml_version}/{disease_id}/results/shap_summary_symbol.tsv",
        sel="results/drugbank-v{db_version}_gtex-v{gtex_version}_edger-v{edger_version}_mygene-v{mg_version}_v{hipathia_version}_drexml-v{drexml_version}/{disease_id}/results/shap_selection_symbol.tsv",
        res="results/drugbank-v{db_version}_gtex-v{gtex_version}_edger-v{edger_version}_mygene-v{mg_version}_v{hipathia_version}_drexml-v{drexml_version}/{disease_id}/results/stability_results_symbol.tsv",
    params:
        out="results/drugbank-v{db_version}_gtex-v{gtex_version}_edger-v{edger_version}_mygene-v{mg_version}_v{hipathia_version}_drexml-v{drexml_version}/{disease_id}",
    output:
        "results/drugbank-v{db_version}_gtex-v{gtex_version}_edger-v{edger_version}_mygene-v{mg_version}_v{hipathia_version}_drexml-v{drexml_version}/{disease_id}/metrics.pdf",
        "results/drugbank-v{db_version}_gtex-v{gtex_version}_edger-v{edger_version}_mygene-v{mg_version}_v{hipathia_version}_drexml-v{drexml_version}/{disease_id}/relevance_heatmap.pdf",
    conda:
        "../../envs/py.yaml"  
    log:
        "logs/plot_drexml_{db_version}_{gtex_version}_{edger_version}_{mg_version}_{hipathia_version}_{drexml_version}_{disease_id}.log",
    benchmark:
        "benchmarks/plot_drexml_{db_version}_{gtex_version}_{edger_version}_{mg_version}_{hipathia_version}_{drexml_version}_{disease_id}.txt"
    shell:
        """
        drexml plot {input.sel} {input.rel} {input.res} {params.out} > {log} 2>&1
        """