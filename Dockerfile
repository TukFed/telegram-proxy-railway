FROM alpine:latest

# نصب ابزارهای لازم
RUN apk update && apk add --no-cache curl tar

# دانلود mtg نسخه 2.1.7
RUN curl -sL "https://github.com/9seconds/mtg/releases/download/v2.1.7/mtg-2.1.7-linux-amd64.tar.gz" \
    -o /tmp/mtg.tar.gz \
    && tar -xzf /tmp/mtg.tar.gz -C /tmp/ \
    && mv /tmp/mtg-2.1.7-linux-amd64/mtg /usr/local/bin/mtg \
    && chmod +x /usr/local/bin/mtg \
    && rm -rf /tmp/mtg*

# تست نصب
RUN mtg --version

# اسکریپت اجرا
CMD ["sh", "-c", "\
# تولید کلید
SECRET=\$(mtg generate-secret --hex telegram.org)\
DOMAIN=\${RAILWAY_STATIC_URL:-'proxy.up.railway.app'}\
PORT=\${PORT:-8080}\
\
echo '========================================'\
echo '🚀 TELEGRAM MTPROTO PROXY'\
echo '========================================'\
echo '✅ Secret: '\$SECRET\
echo '🌐 Domain: '\$DOMAIN\
echo '🔌 Port: '\$PORT\
echo ''\
echo '📱 TELEGRAM LINKS:'\
echo '1. tg://proxy?server='\$DOMAIN'&port=443&secret='\$SECRET\
echo '2. https://t.me/proxy?server='\$DOMAIN'&port=443&secret='\$SECRET\
echo ''\
echo '========================================'\
echo '🔄 Starting proxy...'\
echo '========================================'\
\
# اجرای پروکسی\
exec mtg simple-run \"0.0.0.0:\$PORT\" \"\$SECRET\"\
"]
