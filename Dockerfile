FROM ubuntu:bionic
USER root
WORKDIR /root/

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

# SYSTEM PACKAGES
RUN apt update && apt install -y --no-install-recommends apt-utils && \
    apt install -y tzdata software-properties-common python3-software-properties \
    wget curl bzip2 git gcc openssh-client build-essential jq entr \
    tree htop vim parallel openjdk-8-jre

# ANACONDA SETUP
ENV PATH /opt/conda/bin:$PATH
ADD https://repo.anaconda.com/archive/Anaconda3-5.2.0-Linux-x86_64.sh anaconda.sh
RUN echo '. /opt/conda/bin/activate' >> $HOME/.bashrc && \
    echo '. /opt/conda/bin/activate' >> $HOME/.bash_profile && \
    echo '. /opt/conda/bin/activate' >> $HOME/.profile && \
    echo 'export PATH=/opt/conda/bin:$PATH' >> /etc/profile.d/conda.sh && \
    bash anaconda.sh -b -p /opt/conda && \
    rm anaconda.sh

# PYTHON PACKAGES
RUN conda config --add channels conda-forge
RUN conda install -y graphviz python-graphviz s3transfer s3fs boto3 fastparquet pyspark \
    python-snappy dill bokeh ujson spacy gensim holoviews pymysql && conda clean -tipsy
RUN pip install retry uvloop pygsheets asyncpg records unidecode gtin_validator yurl \
    oauth2client httpie bpython s4cmd

EXPOSE 80
CMD ["jupyter", "lab", "--allow-root", "--no-browser", "-y", "--ip=0.0.0.0", "--port=80"]

