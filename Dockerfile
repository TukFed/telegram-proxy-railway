FROM alpine:latest

# نصب ابزارها
RUN apk update && apk add --no-cache \
    curl \
    bash \
    tar \
    gzip \
    openssl \
    ca-certificates

# دانلود mtg
RUN curl -L "https://github.com/9seconds/mtg/releases/download/v2.1.7/mtg-2.1.7-linux-amd64.tar.gz" -o mtg.tar.gz \
    && tar -xzf mtg.tar.gz \
    && mv mtg-2.1.7-linux-amd64/mtg /usr/local/bin/mtg \
    && chmod +x /usr/local/bin/mtg \
    && rm -rf mtg.tar.gz mtg-2.1.7-linux-amd64

# کپی اسکریپت به مسیر درست
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 8080

# اجرای اسکریپت
CMD ["/run.sh"]
