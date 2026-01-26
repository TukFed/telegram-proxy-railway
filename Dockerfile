FROM alpine:3.18

# نصب بسته‌های ضروری
RUN apk update && apk add --no-cache \
    curl \
    python3 \
    py3-pip \
    openssl \
    tzdata \
    && pip3 install --no-cache-dir requests

# دانلود آخرین نسخه mtg
ENV MTG_VERSION="2.1.7"
RUN curl -L https://github.com/9seconds/mtg/releases/download/v${MTG_VERSION}/mtg-${MTG_VERSION}-linux-amd64.tar.gz \
    -o /tmp/mtg.tar.gz \
    && tar -xzf /tmp/mtg.tar.gz -C /tmp/ \
    && mv /tmp/mtg-${MTG_VERSION}-linux-amd64/mtg /usr/local/bin/mtg \
    && chmod +x /usr/local/bin/mtg \
    && rm -rf /tmp/mtg* \
    && mtg --version

# کپی فایل‌ها
COPY start.sh /app/start.sh
COPY healthcheck.py /app/healthcheck.py
COPY config.toml /app/config.toml

# دسترسی‌های لازم
RUN chmod +x /app/start.sh /app/healthcheck.py

# پورت اکسپوز
EXPOSE 8080

# اجرا
CMD ["/app/start.sh"]
