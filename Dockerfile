FROM continuumio/miniconda3

LABEL maintainer="Dabin Jeong <dnj01208@gmail.com>"

RUN conda init bash

RUN conda create -n tcga_env python=3.9 
RUN conda env activate tcga_env 

RUN conda install -y conda-forge::r-base
RUN conda install -y bioconda::bioconductor-genomicdatacommons
RUN conda install -y anaconda::pandas 
RUN conda install -y anaconda::numpy 
RUN conda install -y conda-forge::argparse 

COPY modules/* /tools/

ENTRYPOINT [ ""usr/bin/env"" ]
CMD [ "/bin/bash" ]
