FROM alpine:latest

# نصب پیش‌نیازها
RUN apk update && apk add --no-cache \
    curl \
    bash \
    openssl \
    wget

# دانلود MTProxy
RUN wget -O /usr/local/bin/mtg \
    https://github.com/9seconds/mtg/releases/download/v2.1.8/mtg-linux-amd64 \
    && chmod +x /usr/local/bin/mtg

# کپی اسکریپت اجرا
COPY run.sh /run.sh
RUN chmod +x /run.sh

# اکسپوز پورت
EXPOSE 8080

# اجرای اصلی
CMD ["/run.sh"]