FROM alpine:latest

RUN apk add --no-cache wget tar openssl xxd

# تنظیم DNS ثابت (حل مشکل cannot find any ips)
RUN echo "nameserver 1.1.1.1" > /etc/resolv.conf
RUN echo "nameserver 8.8.8.8" >> /etc/resolv.conf

# دانلود mtg
RUN wget -q -O /tmp/mtg.tar.gz \
    https://github.com/9seconds/mtg/releases/download/v2.1.7/mtg-2.1.7-linux-amd64.tar.gz && \
    tar -xzf /tmp/mtg.tar.gz -C /tmp/ && \
    mv /tmp/mtg-*/mtg /usr/local/bin/mtg && \
    chmod +x /usr/local/bin/mtg && \
    rm -rf /tmp/*

# اسکریپت اجرا
RUN cat > /start.sh << 'EOF'
#!/bin/sh
set -e

PORT=${PORT:-8080}

# تولید سکرت FakeTLS
if [ -z "$SECRET" ]; then
    RANDOM_HEX=$(openssl rand -hex 16)
    DOMAIN_HEX=$(printf 'google.com' | xxd -p | tr -d '\n')  # تغییر به google.com
    SECRET="ee${RANDOM_HEX}${DOMAIN_HEX}"
fi

SERVER="switchback.proxy.rlwy.net"

echo "=========================================="
echo "   MTProto Proxy - Railway TCP"
echo "=========================================="
echo "🌐 Server: $SERVER"
echo "🔌 Port: $PORT"
echo "🔑 Secret: ${SECRET:0:15}..."
echo ""
echo "📱 لینک تلگرام:"
echo "https://t.me/proxy?server=${SERVER}&port=${PORT}&secret=${SECRET}"
echo "=========================================="

# اجرای MTProto با تنظیمات بهینه
exec /usr/local/bin/mtg simple-run \
    --domain-fronting-port=0 \           # غیرفعال کردن fronting (علت خطا)
    --prefer-ip=only-ipv4 \              # جلوگیری از خطای IPv6
    --timeout=30s \                      # افزایش timeout
    "0.0.0.0:${PORT}" \
    "${SECRET}"
EOF

RUN chmod +x /start.sh

EXPOSE ${PORT}
CMD ["/start.sh"]
