#!/bin/sh

set -e

echo "========================================"
echo "🚀 TELEGRAM MTProto PROXY - ENHANCED"
echo "========================================"

# تنظیمات Railway
export DOMAIN="${RAILWAY_STATIC_URL}"
export PORT="${PORT:-8080}"
IP_ADDRESS="$(curl -s ifconfig.me || echo 'N/A')"

# تولید یا استفاده از secret
if [ -n "${SECRET_KEY}" ]; then
    export SECRET="${SECRET_KEY}"
    echo "✅ Using pre-configured secret"
else
    # تولید secret FakeTLS
    export SECRET=$(mtg generate-secret --hex "${DOMAIN:-telegram.org}")
    echo "⚠️  New secret generated (save it for reuse):"
fi

# ایجاد فایل config با مقادیر واقعی
cat > /app/config-final.toml << EOF
# تنظیمات اصلی
secret = "${SECRET}"
bind-to = "0.0.0.0:${PORT}"

# تنظیمات شبکه
[network]
timeout = { tcp = "30s", http = "30s", idle = "5m" }
prefer-ip = "prefer-ipv6"
tcp-buffer = "64KB"
concurrency = 8192

# ضد حملات تکرار
[antireplay]
max-size = "10MB"
window = "1h"

# لیست IP های مسدود شده
[ip-blocklist]
urls = [
    "https://www.spamhaus.org/drop/drop.txt",
    "https://www.spamhaus.org/drop/edrop.txt"
]
update-every = "6h"

# جلوگیری از تشخیص (FakeTLS)
[tls]
domain = "${DOMAIN}"
port = 443

# ارسال آمار
[stats]
[stats.statsd]
address = ""

[stats.prometheus]
enable = false

# ثبت رویدادها
[log]
level = "info"
json = false

# DNS امن
[dns]
type = "doh"
host = "cloudflare-dns.com"
port = 443
path = "/dns-query"

# تنظیمات SOCKS5
[proxy]
type = "none"
EOF

# نمایش اطلاعات
echo ""
echo "📊 SERVER INFORMATION:"
echo "• Domain: ${DOMAIN}"
echo "• IP Address: ${IP_ADDRESS}"
echo "• Internal Port: ${PORT}"
echo "• Public Port: 443 (HTTPS via Railway)"
echo "• Protocol: FakeTLS"
echo ""

# نمایش secret
echo "🔑 SECRET KEY:"
echo "${SECRET}"
echo ""

# نمایش لینک‌های تلگرام
echo "📱 TELEGRAM LINKS:"
echo ""
echo "1. DIRECT LINK:"
echo "tg://proxy?server=${DOMAIN}&port=443&secret=${SECRET}"
echo ""
echo "2. WEB LINK:"
echo "https://t.me/proxy?server=${DOMAIN}&port=443&secret=${SECRET}"
echo ""
echo "3. WITH IP (alternative):"
echo "tg://proxy?server=${IP_ADDRESS}&port=443&secret=${SECRET}"
echo ""
echo "========================================"
echo "⚙️  Starting enhanced MTProto proxy..."
echo "========================================"

# اجرای پروکسی با config نهایی
exec mtg run /app/config-final.toml
