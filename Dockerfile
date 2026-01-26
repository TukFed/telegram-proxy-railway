FROM alpine:latest

RUN apk update && apk add curl tar

# دانلود mtg
RUN curl -sL "https://github.com/9seconds/mtg/releases/download/v2.1.7/mtg-2.1.7-linux-amd64.tar.gz" \
    | tar -xz --strip-components=1 -C /usr/local/bin/ mtg-2.1.7-linux-amd64/mtg \
    && chmod +x /usr/local/bin/mtg

# استفاده از دستور generate-secret خود mtg
CMD ["sh", "-c", "
  echo '🚀 Starting MTProto Proxy...'
  
  # تولید کلید با mtg خودش
  SECRET=\$(mtg generate-secret --hex \${RAILWAY_STATIC_URL:-proxy.up.railway.app})
  
  echo '🔑 Secret: '\$SECRET
  echo '🌐 Domain: '\${RAILWAY_STATIC_URL}
  echo '📱 Link: https://t.me/proxy?server='\${RAILWAY_STATIC_URL}'&port=443&secret='\$SECRET
  echo ''
  
  # اجرا
  exec mtg simple-run '0.0.0.0:'\${PORT:-8080} \"\$SECRET\"
"]
