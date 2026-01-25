FROM alpine:latest

# نصب ابزارهای لازم
RUN apk update && apk add --no-cache \
    curl \
    bash \
    openssl \
    ca-certificates

# دانلود mtg v2.1.7 (پایدار)
RUN wget -O /usr/local/bin/mtg \
    https://github.com/9seconds/mtg/releases/download/v2.1.7/mtg \
    && chmod +x /usr/local/bin/mtg

# ایجاد دایرکتوری کاری
WORKDIR /app

# کپی اسکریپت
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# پورت‌ها
EXPOSE 8080

# اجرا
CMD ["/app/run.sh"]
