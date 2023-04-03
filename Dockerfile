ARG LANG=C.UTF-8 LC_ALL=C.UTF-8
ARG ARCH=aarch64  


FROM ubuntu:lunar AS builder
USER root

ARG ARCH
ARG LANG
ARG LC_ALL
ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /root/


# SYSTEM PACKAGES
RUN apt update
RUN apt install -y sudo
RUN apt install -y --no-install-recommends apt-utils
RUN apt install -y --no-install-recommends tzdata software-properties-common \
    zstd git openssh-client

RUN apt install -y --no-install-recommends jq exa fish htop graphviz

# MICROMAMBA
RUN curl -Ls https://micro.mamba.pm/api/micromamba/linux-$ARCH/latest | \
    tar -xvj bin/micromamba && mv bin/micromamba /bin/ && rm -rf bin

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN apt clean && rm -rf /var/lib/apt/lists/* /home


FROM scratch AS final
COPY --from=builder / /

ARG LANG
ENV LANG=$LANG
ARG LC_ALL
ENV LC_ALL=$LC_ALL

RUN useradd --create-home --home-dir=/home --shell /bin/fish -g sudo deviant
USER deviant
WORKDIR /home

ENTRYPOINT /bin/fish
RUN sudo chmod -R a+rwx /opt /var
ENV MAMBA_ROOT_PREFIX=/opt/mamba
ENV MAMBA_ROOT_ENVIRONMENT=/var/opt/mamba
RUN mkdir -p $MAMBA_ROOT_PREFIX $MAMBA_ROOT_ENVIRONMENT
RUN micromamba shell init -s fish
RUN micromamba activate

EXPOSE 8080
CMD fish
#CMD ["jupyter", "lab", "--allow-root", "--no-browser", "-y", "--ip=0.0.0.0", "--port=8080"]
