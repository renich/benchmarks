FROM docker.io/library/alpine:latest

LABEL maintainer="Renich Bon Ćirić <renich@woralelandia.com>"
LABEL description="Multi-language benchmark test environment"

RUN apk update && apk add --no-cache \
    bash \
    clang \
    crystal \
    g++ \
    ghc \
    go \
    libffi-dev \
    make \
    nim \
    nodejs-current \
    openjdk21 \
    perl \
    php \
    python3 \
    R \
    R-dev \
    rakudo \
    ruby \
    rust \
    time

RUN ln -sf /usr/lib/jvm/default-jvm/bin/javac /usr/local/bin/javac

WORKDIR /benchmarks
CMD ["make", "all"]
