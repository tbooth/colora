# This rule includes the "Step 3A: Pair reads & mapping quality filter" from the Arima Genomics mapping pipeline
# This pipeline is currently built for processing a single sample with one read1 and read2 FASTQ file.
# For more info: https://github.com/ArimaGenomics/mapping_pipeline
# colora doesn't contain the codes to handle technical and biological replicates of hic reads, refer to the original pipeline for that


# include common.smk to use get_bwa_index_inputs
include: "common.smk"


rule two_read_bam_combiner:
    input:
        bam1_filt="results/arima_mapping_pipeline/FILT_DIR/{sample}_1.bam",
        bam2_filt="results/arima_mapping_pipeline/FILT_DIR/{sample}_2.bam",
        REF=get_bwa_index_inputs(),
    output:
        tmp_bam="results/arima_mapping_pipeline/TMP_DIR/{sample}.bam",
    threads: config["arima"]["CPU"]
    params:
        MAPQ_FILTER=config["arima"]["MAPQ_FILTER"],
    log:
        "logs/{sample}_two_read_bam_combiner.log",
    resources:
        mem_mb=config['arima']['mem_mb'],  # access memory from config
    conda:
        "../envs/arima_mapping_pipeline.yaml"
    shell:
        """
        mkdir -p results/arima_mapping_pipeline/TMP_DIR
        samtools faidx {input.REF}
        perl scripts/two_read_bam_combiner.pl {input.bam1_filt} {input.bam2_filt} samtools {params.MAPQ_FILTER} | samtools view -bS -t {input.REF}.fai - | samtools sort -@ {threads} -o {output.tmp_bam} - 
        """
