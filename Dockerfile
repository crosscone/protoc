FROM golang:1.13

ENV PROTOC_VERSION 3.11.0
ENV PROTOC_URL https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protobuf-all-${PROTOC_VERSION}.tar.gz

ENV SWIFT_VERSION 5.1.2
ENV SWIFT_URL https://swift.org/builds/swift-${SWIFT_VERSION}-release/ubuntu1804/swift-${SWIFT_VERSION}-RELEASE/swift-${SWIFT_VERSION}-RELEASE-ubuntu18.04.tar.gz

WORKDIR /home

# Install dependencies

RUN apt-get update \
 && apt-get install -y wget autoconf automake libtool curl make g++ unzip libtinfo5 libncurses5 \
 && apt-get clean

# Install protobuf

RUN wget -O protobuf.tar.gz ${PROTOC_URL} \
 && tar xzf protobuf.tar.gz \
 && cd protobuf-${PROTOC_VERSION} \
 && ./configure \
 && make \
 && make check \
 && make install \
 && ldconfig \
 && cd .. \
 && rm -rf *

# Install protoc-gen-go

RUN go get -d -u github.com/golang/protobuf/protoc-gen-go
RUN go install github.com/golang/protobuf/protoc-gen-go

# Install protoc-gen-grpc-gateway

RUN go get -d -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway
RUN go install github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway

# Install protoc-gen-dart

RUN apt-get -y install apt-transport-https \
 && curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
 && curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list \
 && apt-get update \
 && apt-get -y install dart \
 && apt-get clean

ENV PATH="${PATH}:/usr/lib/dart/bin:/root/.pub-cache/bin"

RUN pub global activate protoc_plugin

# install protoc-gen-swift

RUN wget -O swift.tar.gz ${SWIFT_URL} \
 && tar xzf swift.tar.gz \
 && mv swift-${SWIFT_VERSION}-RELEASE-ubuntu18.04 /usr/share/swift \
 && rm -rf *

ENV PATH="${PATH}:/usr/share/swift/usr/bin"

RUN git clone https://github.com/grpc/grpc-swift.git \
 && cd /home/grpc-swift \
 && make plugin \
 && cp protoc-gen-swift /usr/bin \
 && cp protoc-gen-swiftgrpc /usr/bin \
 && cd /home \
 && rm -rf *
