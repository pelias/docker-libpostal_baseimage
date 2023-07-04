# builder image
FROM pelias/baseimage as builder

# libpostal apt dependencies
# note: this is done in one command in order to keep down the size of intermediate containers
RUN apt-get update && \
    apt-get install -y autoconf automake libtool pkg-config python

# clone libpostal
RUN git clone https://github.com/openvenues/libpostal /code/libpostal && \
# pin to libpostal version not affected by https://github.com/openvenues/libpostal/issues/592
  cd /code/libpostal && git checkout a97717f2b9f8fba03d25442f2bd88c15e86ec81b

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
