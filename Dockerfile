From buildpack-deps:xenial-scm

LABEL maintainer="MMX <4isnothing@gmail.com>"


WORKDIR /usr/local/ss/
# netease source
#COPY sources.list /etc/apt/sources.list
VOLUME /usr/local/ss/
COPY . /usr/local/ss/
RUN apt update && apt install -y \
	wget \
	curl \
	git \
	autoconf \
	automake \
	g++-mips64-linux-gnuabi64 \
	gcc-mips64-linux-gnuabi64 \
	gettext build-essential \
	libtool \
    gettext

# mbedtls
RUN mbedtls_ver=2.12.0 \
	&&  wget --no-check-certificate https://tls.mbed.org/download/mbedtls-$mbedtls_ver-gpl.tgz \
	&& tar xvf mbedtls-$mbedtls_ver-gpl.tgz \
	&& cd mbedtls-$mbedtls_ver \
	&& sed -i "s/DESTDIR=\/usr\/local/DESTDIR=\/usr\/local\/mbedtls/g" Makefile \
	&& CC=mips64-linux-gnuabi64-gcc AR=mips64-linux-gnuabi64-ar LD=mips64-linux-gnuabi64-ld LDFLAGS=-static make \
	&& make install

# pcre
RUN pcre_ver=8.42 \
	&& wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-$pcre_ver.tar.gz \
	&& tar xvf pcre-$pcre_ver.tar.gz \
	&& cd pcre-$pcre_ver \
	&& ./configure --host=mips64-linux-gnuabi64 --prefix=/usr/local/pcre --disable-shared --enable-utf8 --enable-unicode-properties \
	&& make \
	&& make install

# libsodium
RUN git clone https://github.com/jedisct1/libsodium \
	&& cd libsodium/ \
        && git checkout stable \
	&& ./autogen.sh \
	&& ./configure --host=mips64-linux-gnuabi64 --prefix=/usr/local/libsodium --disable-ssp --disable-shared \
	&& make && make install

# libev
RUN libev_ver=4.27 \
	&& wget http://dist.schmorp.de/libev/libev-$libev_ver.tar.gz \
	&& tar xvf libev-$libev_ver.tar.gz \
	&& cd libev-$libev_ver \
	&& ./configure --host=mips64-linux-gnuabi64 --prefix=/usr/local/libev --disable-shared \
	&& make \
	&& make install

# c-ares
RUN cares_ver=1.14.0 \
	&& wget https://c-ares.haxx.se/download/c-ares-$cares_ver.tar.gz \
	&& tar xvf c-ares-$cares_ver.tar.gz \
	&& cd c-ares-$cares_ver \
	&& ./configure --host=mips64-linux-gnuabi64 --prefix=/usr/local/libcares --disable-shared --enable-utf8 --enable-unicode-properties \
	&& make \
	&& make install

# shadowsocks-libev
RUN chmod +x /usr/local/ss/entrypoint.sh 

ENTRYPOINT ["/usr/local/ss/entrypoint.sh"]
