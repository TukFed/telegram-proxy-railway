FROM alpine:latest

# نصب ابزارها + netcat برای healthcheck
RUN apk update && apk add --no-cache \
    curl \
    bash \
    tar \
    gzip \
    openssl \
    ca-certificates \
    busybox \
    busybox-extras

# دانلود mtg
RUN curl -L "https://github.com/9seconds/mtg/releases/download/v2.1.7/mtg-2.1.7-linux-amd64.tar.gz" -o mtg.tar.gz \
    && tar -xzf mtg.tar.gz \
    && mv mtg-2.1.7-linux-amd64/mtg /usr/local/bin/mtg \
    && chmod +x /usr/local/bin/mtg \
    && rm -rf mtg.tar.gz mtg-2.1.7-linux-amd64

# تست mtg
RUN echo "Testing mtg installation..." \
    && /usr/local/bin/mtg version || echo "Version check failed but continuing..."

# کپی اسکریپت
COPY run.sh /run.sh
RUN chmod +x /run.sh

# پورت‌ها
EXPOSE 8080 8081

# اجرا
CMD ["/run.sh"]
