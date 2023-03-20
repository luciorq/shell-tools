for ACCESSION in `cat lista_refseq.txt`;
do
  echo "Searching for ${ACCESSION}";
  GENE_NAME=$(esearch -db nuccore -query "${ACCESSION}" | efetch -format xml | xtract -pattern Bioseq_annot -block Seq-feat -element Gene-ref_locus);
  echo "${ACCESSION},${GENE_NAME}" >> refseq_to_genename.csv;
done

