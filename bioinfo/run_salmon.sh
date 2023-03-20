#!/usr/bin/env bash


#
SINGULARITY_REPO=/data/singularity_images
SALMON_VERSION=1.3.0

# Mudar essas variaveis
INPUT_DIR="data-raw/fastq"
TRANSCRIPTOME_REFERENCE="gencode_v34_transcripts.fasta"
REFERENCE_NAME="gencode_v34"

# for variables not declared check, build_salmon_container.sh
NUM_THREADS=8

mkdir -p data/index/
# build index
singularity \
  exec -e \
  ${SINGULARITY_REPO}/salmon_${SALMON_VERSION}.sif \
  salmon index \
    -t ${TRANSCRIPTOME_REFERENCE} \
    -i data/index/${REFERENCE_NAME}_salmon_index \
    --gencode \
    -p ${NUM_THREADS} \
    -k 31

# Para as bibliotecas Single End
# criar um arquivo: accession_single_end.txt
for ACCESSION in `cat accession_single_end.txt`;
do
  echo "Processing library ${ACCESSION}";
  mkdir -p ${INPUT_DIR}/${ACCESSION}_quant;
  singularity \
    exec ${SINGULARITY_REPO}/salmon_${SALMON_VERSION}.sif \
    salmon quant \
      -i data/index/${REFERENCE_NAME}_salmon_index \
      -l A \
      -r ${INPUT_DIR}/${ACCESSION}.fastq \
      -o data/salmon/${ACCESSION}_quant \
      --threads ${THREAD_NUM} \
      --validateMappings \
      --gcBias \
      --seqBias \
      --posBias \
      --numBootstraps 30
done

# Para as bibliotecas Single End
# criar um arquivo: accession_paired_end.txt
for ACCESSION in `cat accession_paired_end.txt`;
do
  echo "Processing library ${ACCESSION}";
  mkdir -p ${INPUT_DIR}/${ACCESSION}_quant;
  singularity \
    exec ${SINGULARITY_REPO}/salmon_${SALMON_VERSION}.sif \
    salmon quant \
      -i ${PROJECT_PATH}/data-raw/gencode/gencode_v${GENCODE_VERSION}_index \
      -l A \
      -1 ${INPUT_DIR}/${ACCESSION}_1.fastq \
      -2 ${INPUT_DIR}/${ACCESSION}_2.fastq \
      -o data/salmon/${ACCESSION}_quant \
      --threads ${THREAD_NUM} \
      --validateMappings \
      --gcBias \
      --seqBias \
      --posBias \
      --numBootstraps 30
done
