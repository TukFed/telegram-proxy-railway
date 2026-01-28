FROM alpine:latest

RUN apk add --no-cache wget tar openssl

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

# تولید سکرت ساده (32 کاراکتر hex - بدون ee و بدون دامنه)
if [ -z "$SECRET" ]; then
    SECRET=$(openssl rand -hex 16)
    echo "🆕 سکرت ساده تولید شد: $SECRET"
else
    echo "🔑 استفاده از سکرت موجود: $SECRET"
fi

# دامنه Railway TCP
if [ -n "$RAILWAY_TCP_PROXY_DOMAIN" ]; then
    SERVER="$RAILWAY_TCP_PROXY_DOMAIN"
elif [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
    SERVER="$RAILWAY_PUBLIC_DOMAIN"
else
    SERVER="localhost"
fi

echo "=========================================="
echo "   MTProto Proxy - Railway TCP"
echo "=========================================="
echo "🌐 Server: $SERVER"
echo "🔌 Internal Port: $PORT"
echo "🔌 External Port: 17782"
echo "🔑 Secret: $SECRET"
echo ""
echo "📱 لینک تلگرام:"
echo "https://t.me/proxy?server=${SERVER}&port=17782&secret=${SECRET}"
echo ""
echo "⚠️  توجه: این پروکسی بدون FakeTLS است و ممکن است سریعتر فیلتر شود."
echo "=========================================="

exec /usr/local/bin/mtg simple-run "0.0.0.0:${PORT}" "${SECRET}"
EOF

RUN chmod +x /start.sh

EXPOSE ${PORT}
CMD ["/start.sh"]
