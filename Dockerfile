FROM alpine:latest

RUN apk update && apk add --no-cache curl tar openssl

# دانلود mtg
RUN curl -sL "https://github.com/9seconds/mtg/releases/download/v2.1.7/mtg-2.1.7-linux-amd64.tar.gz" \
    -o /tmp/mtg.tar.gz \
    && tar -xzf /tmp/mtg.tar.gz -C /tmp/ \
    && mv /tmp/mtg-2.1.7-linux-amd64/mtg /usr/local/bin/ \
    && chmod +x /usr/local/bin/mtg \
    && rm -rf /tmp/mtg*

# ایجاد اسکریپت اجرا
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'echo "========================================"' >> /start.sh && \
    echo 'echo "🚀 TELEGRAM MTPROTO PROXY"' >> /start.sh && \
    echo 'echo "========================================"' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# تولید کلید' >> /start.sh && \
    echo 'RANDOM_HEX=$(openssl rand -hex 16)' >> /start.sh && \
    echo 'SECRET="ee${RANDOM_HEX}"' >> /start.sh && \
    echo '' >> /start.sh && \
    echo 'echo "✅ Secret: $SECRET"' >> /start.sh && \
    echo 'echo "🌐 Domain: ${RAILWAY_STATIC_URL}"' >> /start.sh && \
    echo '' >> /start.sh && \
    echo 'echo "📱 TELEGRAM LINKS:"' >> /start.sh && \
    echo 'echo "1. tg://proxy?server=${RAILWAY_STATIC_URL}&port=443&secret=$SECRET"' >> /start.sh && \
    echo 'echo "2. https://t.me/proxy?server=${RAILWAY_STATIC_URL}&port=443&secret=$SECRET"' >> /start.sh && \
    echo '' >> /start.sh && \
    echo 'echo "========================================"' >> /start.sh && \
    echo 'echo "🔄 Starting proxy..."' >> /start.sh && \
    echo 'echo "========================================"' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# اجرا' >> /start.sh && \
    echo 'exec mtg simple-run "0.0.0.0:${PORT:-8080}" "$SECRET"' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 8080
CMD ["/start.sh"]
