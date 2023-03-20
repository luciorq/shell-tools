export TRINITY_HOME=/usr/local/bin;

Trinity --seqType fq --max_memory 2G \
  --left ${TRINITY_HOME}/sample_data/test_Trinity_Assembly/reads.left.fq.gz \
  --right ${TRINITY_HOME}/sample_data/test_Trinity_Assembly/reads.right.fq.gz \
  --SS_lib_type RF \
  --CPU 1
