FROM centos
ARG RUNC_REVISION="master"
ARG BUILDAH_REVISION="master"

RUN \
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
  git clone https://github.com/opencontainers/runc ./src/github.com/opencontainers/runc && \
  cd $GOPATH/src/github.com/opencontainers/runc && \
  git checkout "${RUNC_REVISION}" && \
  make runc && \
  mv runc /usr/bin/runc && \
  cd $GOPATH/ && \
  git clone https://github.com/containers/buildah ./src/github.com/containers/buildah && \
  cd $GOPATH/src/github.com/containers/buildah && \
  git checkout "${BUILDAH_REVISION}" && \
  make && \
  make install && \
  buildah --help

ENV BUILDAH_ISOLATION chroot
ENV STORAGE_DRIVER vfs
ENTRYPOINT ["buildah"]
