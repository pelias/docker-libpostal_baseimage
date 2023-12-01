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
RUN ./bootstrap.sh

# https://github.com/openvenues/libpostal/pull/632#issuecomment-1648303654
ARG TARGETARCH
RUN if [ "$TARGETARCH" = "arm64" ]; then \
      ./configure --datadir='/usr/share/libpostal' --disable-sse2; \
    else \
      ./configure --datadir='/usr/share/libpostal'; \
    fi

RUN make -j4
RUN DESTDIR=/libpostal make install
RUN ldconfig

# main image
FROM pelias/baseimage

COPY --from=builder /usr/share/libpostal /usr/share/libpostal
COPY --from=builder /libpostal /
