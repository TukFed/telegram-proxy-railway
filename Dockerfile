FROM alpine:latest

RUN apk update && apk add --no-cache curl tar openssl

# دانلود mtg
RUN curl -sL "https://github.com/9seconds/mtg/releases/download/v2.1.7/mtg-2.1.7-linux-amd64.tar.gz" \
    -o /tmp/mtg.tar.gz \
    && tar -xzf /tmp/mtg.tar.gz -C /tmp/ \
    && mv /tmp/mtg-2.1.7-linux-amd64/mtg /usr/local/bin/ \
    && chmod +x /usr/local/bin/mtg \
    && rm -rf /tmp/mtg*

# اسکریپت اجرا
RUN echo '#!/bin/sh' > /start.sh && cat >> /start.sh << 'EOF'
echo "========================================"
echo "🚀 TELEGRAM MTPROTO PROXY"
echo "========================================"

# تنظیم دامنه
DOMAIN="${RAILWAY_STATIC_URL}"
if [ -z "$DOMAIN" ]; then
    DOMAIN="proxy.up.railway.app"
fi

# تولید کلید صحیح
RANDOM_HEX=$(openssl rand -hex 16)
DOMAIN_HEX=$(echo -n "$DOMAIN" | xxd -p)
SECRET="ee${RANDOM_HEX}${DOMAIN_HEX}"

echo "✅ Secret: $SECRET"
echo "🌐 Domain: $DOMAIN"
echo ""
echo "📱 TELEGRAM LINKS:"
echo "1. tg://proxy?server=$DOMAIN&port=443&secret=$SECRET"
echo "2. https://t.me/proxy?server=$DOMAIN&port=443&secret=$SECRET"
echo ""
echo "========================================"
echo "🔄 Starting proxy..."
echo "========================================"

# اجرای پروکسی
exec mtg simple-run "0.0.0.0:${PORT:-8080}" "$SECRET"
EOF

RUN chmod +x /start.sh

EXPOSE 8080
CMD ["/start.sh"]
