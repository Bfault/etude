FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    perl make git wget ca-certificates python3 ghostscript \
    texlive-latex-base \
    texlive-luatex \
    latexmk biber \
    texlive-latex-recommended \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-lang-french \
    texlive-science \
    && apt-get clean && rm -rf /var/lib/apt/lists/*