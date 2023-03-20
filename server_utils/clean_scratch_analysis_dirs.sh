#!/usr/bin/env bash

# Delete directories that are older than 7 days
# + in scratch and data analysis directories
__clean_scratch_analysis_dirs () {
  # find /scratch/*/* -mtime +7 -type d -exec rm -rf {} \;
  return 0;
}
