FROM ubuntu:22.04

# 비대화식 모드 설정
ENV DEBIAN_FRONTEND=noninteractive

# 기본 패키지 설치
RUN apt-get update && apt-get install -y \
    fontforge \
    ttfautohint \
    python3 \
    python3-pip \
    locales \
    && rm -rf /var/lib/apt/lists/*

# 로케일 설정
RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# fonttools 설치 (Python 기반)
RUN pip3 install --no-cache-dir fonttools

# 기본 작업 디렉토리 설정
WORKDIR /work
