FROM alpine:latest

RUN apk update && apk add --no-cache curl tar

# دانلود mtg
RUN wget -q -O /tmp/mtg.tar.gz https://github.com/9seconds/mtg/releases/download/v2.1.7/mtg-2.1.7-linux-amd64.tar.gz \
    && tar -xzf /tmp/mtg.tar.gz -C /tmp/ \
    && mv /tmp/mtg-2.1.7-linux-amd64/mtg /usr/local/bin/ \
    && chmod +x /usr/local/bin/mtg \
    && rm -rf /tmp/mtg*

# تست mtg
RUN mtg --version

# اجرا
CMD sh -c "
echo '========================================'
echo '🚀 TELEGRAM MTPROTO PROXY'
echo '========================================'

# تولید کلید با خود mtg
SECRET=\$(mtg generate-secret --hex telegram.org)

REAL_DOMAIN=\${RAILWAY_STATIC_URL}
if [ -z \"\$REAL_DOMAIN\" ]; then
    REAL_DOMAIN=proxy.up.railway.app
fi

echo '✅ Secret: '\$SECRET
echo '🌐 Domain: '\$REAL_DOMAIN
echo ''
echo '📱 TELEGRAM LINKS:'
echo '1. tg://proxy?server='\$REAL_DOMAIN'&port=443&secret='\$SECRET
echo '2. https://t.me/proxy?server='\$REAL_DOMAIN'&port=443&secret='\$SECRET
echo ''
echo '========================================'
echo '🔄 Starting proxy...'
echo '========================================'

# اجرای پروکسی
exec mtg simple-run '0.0.0.0:'\${PORT:-8080} \"\$SECRET\"
"
