FROM alpine:latest

# نصب ابزارها
RUN apk update && apk add --no-cache \
    curl \
    bash \
    tar \
    gzip \
    openssl \
    ca-certificates

# دانلود mtg v2.1.7 از لینک صحیح
RUN curl -L "https://github.com/9seconds/mtg/releases/download/v2.1.7/mtg-2.1.7-linux-amd64.tar.gz" -o mtg.tar.gz \
    && tar -xzf mtg.tar.gz \
    && mv mtg-2.1.7-linux-amd64/mtg /usr/local/bin/mtg \
    && chmod +x /usr/local/bin/mtg \
    && rm -rf mtg.tar.gz mtg-2.1.7-linux-amd64

# یا روش ساده‌تر:
# RUN curl -L "https://github.com/9seconds/mtg/releases/download/v2.1.7/mtg-2.1.7-linux-amd64.tar.gz" | \
#     tar -xz --strip-components=1 -C /usr/local/bin/ mtg-2.1.7-linux-amd64/mtg \
#     && chmod +x /usr/local/bin/mtg

WORKDIR /app

# کپی اسکریپت
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

EXPOSE 8080

CMD ["/app/run.sh"]
