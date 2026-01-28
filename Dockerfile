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

# تولید سکرت FakeTLS
if [ -z "$SECRET" ]; then
    RANDOM_HEX=$(openssl rand -hex 16)
    DOMAIN_HEX=$(printf 'cloudflare.com' | xxd -p | tr -d '\n')
    SECRET="ee${RANDOM_HEX}${DOMAIN_HEX}"
fi

# دریافت آدرس سرور (برای TCP service railway یه دامنه TCP میده)
if [ -n "$RAILWAY_TCP_PROXY_DOMAIN" ]; then
    SERVER="$RAILWAY_TCP_PROXY_DOMAIN"
elif [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
    SERVER="$RAILWAY_PUBLIC_DOMAIN"
else
    SERVER="0.0.0.0"
fi

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

# اجرای MTProto روی 0.0.0.0 (مهمه که رو همه اینترفیس‌ها باشه)
exec /usr/local/bin/mtg simple-run "0.0.0.0:${PORT}" "${SECRET}"
EOF

RUN chmod +x /start.sh

# Railway خودش PORT رو مپ می‌کنه
EXPOSE ${PORT}

CMD ["/start.sh"]
