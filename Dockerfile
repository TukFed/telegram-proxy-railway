FROM alpine:latest

# نصب ابزارها
RUN apk update && apk add --no-cache \
    curl \
    bash \
    openssl \
    tar \
    gzip \
    ca-certificates

# دانلود آخرین نسخه mtg از ریلیزها
RUN LATEST_VERSION=$(curl -s https://api.github.com/repos/9seconds/mtg/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/') \
    && echo "Downloading mtg version: $LATEST_VERSION" \
    && curl -L "https://github.com/9seconds/mtg/releases/download/v${LATEST_VERSION}/mtg_${LATEST_VERSION}_linux_amd64.tar.gz" -o mtg.tar.gz \
    && tar -xzf mtg.tar.gz \
    && mv mtg /usr/local/bin/mtg \
    && chmod +x /usr/local/bin/mtg \
    && rm mtg.tar.gz

# یا مستقیم از نسخه مشخص (اگر بالا کار نکرد):
# RUN curl -L https://github.com/9seconds/mtg/releases/download/v2.1.7/mtg_2.1.7_linux_amd64.tar.gz -o mtg.tar.gz \
#     && tar -xzf mtg.tar.gz \
#     && mv mtg /usr/local/bin/mtg \
#     && chmod +x /usr/local/bin/mtg \
#     && rm mtg.tar.gz

# دایرکتوری کاری
WORKDIR /app

# کپی اسکریپت
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# پورت
EXPOSE 8080

# اجرا
CMD ["/app/run.sh"]
