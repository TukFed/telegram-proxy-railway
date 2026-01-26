FROM alpine:latest

# نصب curl و tar
RUN apk update && apk add --no-cache curl tar

# دانلود mtg نسخه 2.1.7
RUN curl -sL "https://github.com/9seconds/mtg/releases/download/v2.1.7/mtg-2.1.7-linux-amd64.tar.gz" \
    | tar -xz --strip-components=1 -C /usr/local/bin/ mtg-2.1.7-linux-amd64/mtg \
    && chmod +x /usr/local/bin/mtg

# اسکریپت اجرا
CMD ["sh", "-c", "
  echo '========================================'
  echo '🚀 TELEGRAM MTPROTO PROXY'
  echo '========================================'
  
  # تولید کلید HEX صحیح (با ee شروع شود)
  RANDOM_HEX=\$(openssl rand -hex 16)
  SECRET=\"ee\${RANDOM_HEX}\"
  
  echo '✅ Secret: '\$SECRET
  echo '🌐 Domain: '\${RAILWAY_STATIC_URL}
  echo ''
  echo '📱 TELEGRAM LINKS:'
  echo '1. For app: tg://proxy?server='\${RAILWAY_STATIC_URL}'&port=443&secret='\$SECRET
  echo '2. For web: https://t.me/proxy?server='\${RAILWAY_STATIC_URL}'&port=443&secret='\$SECRET
  echo ''
  echo '========================================'
  echo '🔄 Starting proxy...'
  echo '========================================'
  
  # اجرای پروکسی
  exec mtg simple-run '0.0.0.0:'\${PORT:-8080} \"\$SECRET\"
"]
