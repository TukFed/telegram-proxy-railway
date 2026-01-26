#!/usr/bin/env python3
import sys
import socket
import requests

def check_proxy():
    """بررسی سلامت پروکسی"""
    try:
        # بررسی اتصال داخلی
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(5)
        
        port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
        result = sock.connect_ex(('127.0.0.1', port))
        sock.close()
        
        if result == 0:
            print("✅ Proxy is running on port", port)
            return True
        else:
            print("❌ Proxy is not responding")
            return False
            
    except Exception as e:
        print(f"⚠️ Health check error: {e}")
        return False

def check_internet():
    """بررسی اتصال اینترنت"""
    try:
        response = requests.get('https://api.telegram.org', timeout=10)
        if response.status_code < 500:
            print("✅ Internet connection: OK")
            return True
    except:
        print("❌ Internet connection: FAILED")
        return False

if __name__ == "__main__":
    print("🔍 Performing health checks...")
    
    proxy_ok = check_proxy()
    internet_ok = check_internet()
    
    if proxy_ok and internet_ok:
        print("🎉 All systems operational!")
        sys.exit(0)
    else:
        print("💥 Health checks failed!")
        sys.exit(1)
