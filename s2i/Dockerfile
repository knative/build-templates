FROM centos:7 as build
RUN yum -y install \
    make \
    golang \
    git \
    bzip2
ARG S2I_REVISION="v1.1.12"
RUN mkdir ~/s2i && \
  go version && \
  cd ~/s2i && \
  export GOPATH=`pwd` && \
  cd $GOPATH/ && \
  git clone https://github.com/openshift/source-to-image ./src/github.com/openshift/source-to-image && \
  cd $GOPATH/src/github.com/openshift/source-to-image && \
  git checkout "${S2I_REVISION}" && \
  go build -o /usr/local/bin/s2i ./cmd/s2i

FROM centos:7
COPY --from=build /usr/local/bin/s2i /usr/bin/s2i
ENTRYPOINT [ "s2i", "build", "--as-dockerfile=Dockerfile" ]
