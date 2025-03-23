#!/usr/bin/env bash


# Experiment with pyinfra

# conda create -n pyinfra-env pyinfra;
conda activate pyinfra-env


pyinfra mendel,kiko,chaves exec -- cat /etc/os-release


conda run -n pyinfra-env python -m pyinfra ./server_utils/inventory.py ./server_utils/update_rstats_system.py

sudo su - -c "R -e \"install.packages('any_package', repos='https://cran.rstudio.com/')\""


# - Experiments with installing R and System-level R packages from the CLI with root
sudo su
RIG_VERSION=0.7.0
R_VERSION=4.3.3

R -q -e "pak::pkg_install(pkg = c( \
  'tidyverse', 'BiocManager', 'pak', 'reticulate', \
  'styler', 'lintr', 'rstudioapi', 'quarto', 'rmarkdown', 'knitr', \
  'bioc::DESeq2', 'bioc::SingleCellExperiment', \
  ),lib = '/opt/R/${R_VERSION}/lib/R/library')"

"""
pak::pkg_install(
  pkg = c(
    "remotes", "pak", "BiocManager", "devtools",
    "stringr", "cli", "condathis",
    "tidyverse",
    "patchwork",
    "bioc::SummarizedExperiment",
    "bioc::ExploreModelMatrix",
    "bioc::AnnotationDbi",
    "bioc::org.Hs.eg.db",
    "bioc::org.Mm.eg.db",
    "bioc::hgu95av2.db",
    "github::csoneson/ConfoundingExplorer",
    "bioc::DESeq2",
    "bioc::vsn",
    "ComplexHeatmap",
    "RColorBrewer",
    "hexbin",
    "cowplot",
    "bioc::iSEE",
    "clusterProfiler",
    "enrichplot",
    "kableExtra",
    "msigdbr",
    "gplots",
    "ggplot2",
    "simplifyEnrichment",
    "apeglm",
    "microbenchmark",
    "bioc::Biostrings",
    "bioc::SingleCellExperiment",
    "bioc::fgsea"
  ),
  lib = '/opt/R/4.4.3/lib/R/library'
)



install.packages(c("BiocManager", "remotes"))
BiocManager::install(c("tidyverse", "SummarizedExperiment",
                       "ExploreModelMatrix", "AnnotationDbi", "org.Hs.eg.db",
                       "org.Mm.eg.db", "csoneson/ConfoundingExplorer",
                       "DESeq2", "vsn", "ComplexHeatmap", "hgu95av2.db",
                       "RColorBrewer", "hexbin", "cowplot", "iSEE",
                       "clusterProfiler", "enrichplot", "kableExtra",
                       "msigdbr", "gplots", "ggplot2", "simplifyEnrichment",
                       "apeglm", "microbenchmark", "Biostrings",
                       "SingleCellExperiment", "fgsea"))
"""

curl -f -s -S -L --create-dirs --insecure --silent -o /opt/install_apps/rstudio/rstudio-server.deb -C - https://rstudio.org/download/latest/stable/server/jammy/rstudio-server-latest-amd64.deb
gdebi -n /opt/install_apps/rstudio/rstudio-server.deb