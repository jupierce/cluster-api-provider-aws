FROM registry.svc.ci.openshift.org/openshift/release:golang-1.10 AS builder
WORKDIR /go/src/sigs.k8s.io/cluster-api-provider-aws
COPY . .
RUN go build -o ./machine-controller-manager ./cmd/manager
RUN go build -o ./manager ./vendor/github.com/openshift/cluster-api/cmd/manager

FROM registry.svc.ci.openshift.org/openshift/origin-v4.0:base
RUN INSTALL_PKGS=" \
      openssh \
      " && \
    yum install -y $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all
COPY --from=builder /go/src/sigs.k8s.io/cluster-api-provider-aws/manager /
COPY --from=builder /go/src/sigs.k8s.io/cluster-api-provider-aws/machine-controller-manager /
