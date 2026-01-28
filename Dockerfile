FROM alpine:latest

RUN apk add --no-cache wget tar openssl xxd

# دانلود mtg
RUN wget -q -O /tmp/mtg.tar.gz \
    https://github.com/9seconds/mtg/releases/download/v2.1.7/mtg-2.1.7-linux-amd64.tar.gz && \
    tar -xzf /tmp/mtg.tar.gz -C /tmp/ && \
    mv /tmp/mtg-*/mtg /usr/local/bin/mtg && \
    chmod +x /usr/local/bin/mtg && \
    rm -rf /tmp/*

RUN cat > /start.sh << 'EOF'
#!/bin/sh
set -e

# تنظیم DNS در runtime (نه build)
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf

PORT=${PORT:-8080}

# تولید سکرت با cloudflare.com
if [ -z "$SECRET" ]; then
    RANDOM_HEX=$(openssl rand -hex 16)
    DOMAIN_HEX=$(printf 'cloudflare.com' | xxd -p | tr -d '\n')
    SECRET="ee${RANDOM_HEX}${DOMAIN_HEX}"
fi

if [ -n "$RAILWAY_TCP_PROXY_DOMAIN" ]; then
    SERVER="$RAILWAY_TCP_PROXY_DOMAIN"
elif [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
    SERVER="$RAILWAY_PUBLIC_DOMAIN"
else
    SERVER="0.0.0.0"
fi

echo "=========================================="
echo "   MTProto Proxy - Railway"
echo "=========================================="
echo "🌐 Server: ${SERVER}"
echo "🔌 Port: 8080 (internal) -> 17782 (external)"
echo "🔑 Secret: ${SECRET:0:20}..."
echo ""
echo "📱 لینک تلگرام (با پورت خارجی 17782):"
echo "https://t.me/proxy?server=${SERVER}&port=17782&secret=${SECRET}"
echo "=========================================="

exec /usr/local/bin/mtg simple-run "0.0.0.0:${PORT}" "${SECRET}"
EOF

RUN chmod +x /start.sh

EXPOSE ${PORT}
CMD ["/start.sh"]
