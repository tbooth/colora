# This rule uses yahs to scaffold the contigs from hifiasm_p_purged.fa

import glob


# include common.smk to use get_bwa_index_inputs
include: "common.smk"


rule yahs:
    input:
        REF=get_bwa_index_inputs(),
        bam="results/arima_mapping_pipeline/REP_DIR/{sample}_rep1.bam",
    output:
        scaffolds="results/yahs/hifiasm_yahs_{sample}_scaffolds_final.fa",
    log:
        "logs/yahs_{sample}.log",
    resources:
        mem_mb=config['arima']['mem_mb'],  # access memory from config
    conda:
        "../envs/yahs.yaml"
    params:
        optional_params=" ".join(
            f"{k} {v}" for k, v in config["yahs"]["optional_params"].items() if v
        ),
    shell:
        """
        samtools faidx {input.REF} 
        mkdir -p results/yahs 
        yahs {input.REF} {input.bam} -o results/yahs/hifiasm_yahs_{wildcards.sample} {params.optional_params} >> {log} 2>&1
        """
