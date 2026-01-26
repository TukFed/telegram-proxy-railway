FROM alpine:latest

# نصب ابزارها
RUN apk update && apk add --no-cache \
    curl \
    bash \
    tar \
    gzip \
    openssl \
    ca-certificates

# دانلود mtg مستقیماً از source خود پروژه
RUN curl -sL "https://github.com/9seconds/mtg/releases/download/v2.1.7/mtg-2.1.7-linux-amd64.tar.gz" \
    | tar -xz -C /usr/local/bin/ --strip-components=1 mtg-2.1.7-linux-amd64/mtg \
    && chmod +x /usr/local/bin/mtg

# ایجاد اسکریپت اجرا درست داخل Dockerfile
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'echo "🚀 Starting MTProto Proxy..."' >> /start.sh && \
    echo 'PORT=${PORT:-8080}' >> /start.sh && \
    echo 'SECRET=$(openssl rand -hex 16 | xxd -r -p | base64 | tr -d "\\n=")' >> /start.sh && \
    echo 'echo "🔑 Secret: $SECRET"' >> /start.sh && \
    echo 'echo "🌐 Domain: ${RAILWAY_STATIC_URL}"' >> /start.sh && \
    echo 'echo "📱 Link: https://t.me/proxy?server=${RAILWAY_STATIC_URL}&port=443&secret=$SECRET"' >> /start.sh && \
    echo 'exec mtg run --bind "0.0.0.0:$PORT" --secret "$SECRET" --cloak-port 443' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 8080
CMD ["/start.sh"]
