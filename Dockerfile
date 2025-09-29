# builder image
FROM pelias/baseimage AS builder

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
RUN case "$TARGETARCH" in \
      arm*|aarch*) \
        ./configure --datadir='/usr/share/libpostal' --disable-sse2 ;; \
      *) \
        ./configure --datadir='/usr/share/libpostal' ;; \
    esac

# compile
RUN make -j4
RUN DESTDIR=/libpostal make install
RUN ldconfig

# copy address_parser executable
RUN cp /code/libpostal/src/.libs/address_parser /libpostal/usr/local/bin/

# -------------------------------------------------------------

# main image
FROM pelias/baseimage

# copy data
COPY --from=builder /usr/share/libpostal /usr/share/libpostal

# copy build
COPY --from=builder /libpostal /

# ensure /usr/local/lib is on LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"

# test model / executable load correctly
RUN echo '12 example lane, example' | address_parser
