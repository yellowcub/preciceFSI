# syntax=docker/dockerfile:1
FROM ubuntu:22.04

ARG precice_version=2.5.0
ARG TIMEZONE=US/Michigan

RUN <<EOT bash # Install necessary base packages
    export TZ=$TIMEZONE
    echo $TZ > /etc/timezone
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
    apt-get -y update
       apt-get install -y git nano tree pkg-config make cmake tzdata lsb-release
    apt update -y
       apt upgrade -y
       apt install -y curl wget
EOT

RUN <<EOT bash # Install preCICE
    # export ver_release=`echo ${precice_version} | sed 's/\([0-9]\+\)\.\([0-9]\+\.[0-9]\+\)/\1_\1.\2/'`_$(lsb_release -sc)
    # wget -O libprecice.deb https://github.com/precice/precice/releases/download/v${precice_version}/libprecice${ver_release}.deb
    wget -q -O libprecice.deb https://github.com/precice/precice/releases/download/v2.5.0/libprecice2_2.5.0_jammy.deb
    apt-get update -y
    apt -y install ./libprecice.deb && rm ./libprecice.deb
EOT
# RUN ["/bin/bash", "-c", "precice-tools xml > /dev/null"] # Make sure the installation is functional

RUN <<EOT bash # Install OpenFOAM v2306
    curl -s https://dl.openfoam.com/add-debian-repo.sh | bash
    apt-get install -y openfoam2306-dev
EOT

# Install CalculiX-preCICE
WORKDIR /
RUN <<EOT bash # Install CalculiX-PreCICE
    set -ue
    wget -q -O calculix.deb https://github.com/precice/calculix-adapter/releases/download/v2.20.0/calculix-precice2_2.20.0-1_amd64_jammy.deb
    apt update && apt install -y ./calculix.deb && rm -f ./calculix.deb
EOT

RUN apt-get autoremove -y
RUN apt autoremove -y

# Create a new user called foam
RUN useradd --user-group --create-home --shell /bin/bash foam ;\
        echo "foam ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN echo "source /usr/lib/openfoam/openfoam2306/etc/bashrc" >> /home/foam/.bashrc

USER foam
WORKDIR /home/foam

# Install openfoam-adapter
RUN wget -q -O openfoam_adapter.tar.gz https://github.com/precice/openfoam-adapter/releases/download/v1.2.3/openefoam-adapter-v1.2.3-OpenFOAMv1812-v2306-newer.tar.gz
RUN tar -xf ./openfoam_adapter.tar.gz && rm ./openfoam_adapter.tar.gz
WORKDIR openefoam-adapter-v1.2.3-master
RUN mkdir cases
RUN ["/bin/bash", "-c", "export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig/libprecice.pc; source /usr/lib/openfoam/openfoam2306/etc/bashrc; ./Allwmake"]
WORKDIR /home/foam

ADD test ./test

################
