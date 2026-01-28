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

PORT=${PORT:-8080}

# تولید سکرت با دامنه لوکال (نیازی به DNS نداره)
if [ -z "$SECRET" ]; then
    RANDOM_HEX=$(openssl rand -hex 16)
    # به جای cloudflare.com از localhost یا 127.0.0.1 استفاده می‌کنیم
    DOMAIN_HEX=$(printf 'localhost' | xxd -p | tr -d '\n')
    SECRET="ee${RANDOM_HEX}${DOMAIN_HEX}"
fi

# یا استفاده از سکرت ساده (بدون FakeTLS)
# SECRET="${RANDOM_HEX}"

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
echo "🌐 Server: $SERVER"
echo "🔌 Port: $PORT"
echo "🔑 Secret: ${SECRET:0:20}..."
echo ""
echo "📱 لینک تلگرام:"
echo "https://t.me/proxy?server=${SERVER}&port=17782&secret=${SECRET}"
echo "=========================================="

# اجرای MTProto
exec /usr/local/bin/mtg simple-run "0.0.0.0:${PORT}" "${SECRET}"
EOF

RUN chmod +x /start.sh

EXPOSE ${PORT}

CMD ["/start.sh"]
