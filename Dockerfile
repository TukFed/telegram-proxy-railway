FROM alpine:latest

# نصب ابزارها
RUN apk update && apk add --no-cache \
    curl \
    bash \
    tar \
    gzip \
    openssl

# دانلود mtg
RUN curl -sL "https://github.com/9seconds/mtg/releases/download/v2.1.7/mtg-2.1.7-linux-amd64.tar.gz" \
    | tar -xz -C /usr/local/bin/ --strip-components=1 mtg-2.1.7-linux-amd64/mtg \
    && chmod +x /usr/local/bin/mtg

# تست دستور simple-run
RUN echo "=== Testing mtg ===" && \
    mtg --help | head -5 && \
    echo "=== Testing simple-run ===" && \
    mtg simple-run --help 2>&1 | head -10 || echo "simple-run test completed"

# ایجاد اسکریپت اجرا با simple-run
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'echo "🚀 Starting MTProto Proxy..."' >> /start.sh && \
    echo 'PORT=${PORT:-8080}' >> /start.sh && \
    echo 'SECRET=$(openssl rand -hex 16 | xxd -r -p | base64 | tr -d "\\n=")' >> /start.sh && \
    echo 'echo "🔑 Secret: $SECRET"' >> /start.sh && \
    echo 'echo "🌐 Domain: ${RAILWAY_STATIC_URL}"' >> /start.sh && \
    echo 'echo "📱 Link: https://t.me/proxy?server=${RAILWAY_STATIC_URL}&port=443&secret=$SECRET"' >> /start.sh && \
    # استفاده از simple-run به جای run
    echo 'exec mtg simple-run "0.0.0.0:$PORT" "$SECRET"' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 8080
CMD ["/start.sh"]
