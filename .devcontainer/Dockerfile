FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
      perl make python3 ca-certificates git wget \
      texlive-full latexmk biber ghostscript \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
