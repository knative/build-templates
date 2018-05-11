FROM centos

RUN \
  # Install runc first, fail fast if something is wrong.
  yum -y install wget && \
  wget -O /bin/runc https://github.com/opencontainers/runc/releases/download/v1.0.0-rc5/runc.amd64 && \
  chmod +x /bin/runc && \
  runc --help && \
  # Install buildah dependencies.
  yum -y install \
    make \
    golang \
    bats \
    btrfs-progs-devel \
    device-mapper-devel \
    glib2-devel \
    gpgme-devel \
    libassuan-devel \
    libseccomp-devel \
    ostree-devel \
    git \
    bzip2 \
    go-md2man \
    runc \
    skopeo-containers && \
  # Install buildah.
  mkdir ~/buildah && \
  cd ~/buildah && \
  export GOPATH=`pwd` && \
  git clone https://github.com/projectatomic/buildah ./src/github.com/projectatomic/buildah && \
  cd ./src/github.com/projectatomic/buildah && \
  make && \
  make install && \
  buildah --help

ENTRYPOINT ["buildah"]
