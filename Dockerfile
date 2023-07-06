# builder image
FROM pelias/baseimage as builder

# libpostal apt dependencies
# note: this is done in one command in order to keep down the size of intermediate containers
RUN apt-get update && \
    apt-get install -y build-essential autoconf automake libtool pkg-config python3

# clone libpostal
RUN git clone https://github.com/openvenues/libpostal /code/libpostal
WORKDIR /code/libpostal

# install libpostal
RUN ./bootstrap.sh && \
    ./configure --datadir=/usr/share/libpostal && \
    make && make check && DESTDIR=/libpostal make install && \
    ldconfig

# main image
FROM pelias/baseimage

COPY --from=builder /usr/share/libpostal /usr/share/libpostal
COPY --from=builder /libpostal /
