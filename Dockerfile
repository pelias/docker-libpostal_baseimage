# base image
FROM pelias/baseimage

# libpostal apt dependencies
# note: this is done in one command in order to keep down the size of intermediate containers
RUN apt-get update && \
    apt-get install -y autoconf automake libtool pkg-config python && \
    rm -rf /var/lib/apt/lists/*

# clone libpostal
RUN git clone https://github.com/openvenues/libpostal /code/libpostal
WORKDIR /code/libpostal

# patch libpostal
# https://github.com/pelias/interpolation/issues/132
COPY patchfile /tmp/patchfile
RUN git apply /tmp/patchfile

# install libpostal
RUN ./bootstrap.sh && \
    ./configure --datadir=/usr/share/libpostal && \
    make && make check && make install && \
    ldconfig
