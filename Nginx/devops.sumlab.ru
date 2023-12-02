server {
    listen 80 default_server;
    server_name www.devops.sumlab.ru devops.sumlab.ru;
    
    proxy_connect_timeout 600;
    proxy_send_timeout 600;
    proxy_read_timeout 600;
    send_timeout 600;
    
    location / {
        proxy_pass http://158.160.134.206:29637/;
        proxy_no_cache off;
        fastcgi_cache off;
        expires epoch;
    }
    
    location /api/customer {
        proxy_pass http://158.160.134.206:29637/api/customer;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }
    
    location /api/customer/ {
        proxy_pass http://158.160.134.206:29637/api/customer/;
    }
    
    location /api/session {
        proxy_pass http://158.160.134.206:29637/api/session;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }
    
    location /api/session/ {
        proxy_pass http://158.160.134.206:29637/api/session/;
    }
    
    location /long_dummy {        
        proxy_pass http://158.160.134.206:29637/long_dummy;
        
        fastcgi_cache_bypass $cookie_cache_bypass;
        #fastcgi_cache all;
        fastcgi_cache_methods GET POST HEAD;
        fastcgi_cache_valid 404 502 503 50s;
        fastcgi_cache_valid any 50s;
        fastcgi_cache_use_stale error timeout invalid_header updating;
        
        proxy_cache_bypass $cookie_cache_bypass;
        proxy_cache all;
        proxy_cache_methods GET POST HEAD;
        proxy_cache_valid 404 502 503 50s;
        proxy_cache_valid any 50s;
        proxy_cache_use_stale error timeout invalid_header updating;
    }
}

server {
    listen 443 ssl http2;
    server_name www.devops.sumlab.ru devops.sumlab.ru;
    
    proxy_connect_timeout 600;
    proxy_send_timeout 600;
    proxy_read_timeout 600;
    send_timeout 600;
    
    ssl_certificate /etc/letsencrypt/live/devops.sumlab.ru/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/devops.sumlab.ru/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
    
    location / {
        proxy_pass http://158.160.134.206:29637/;
        proxy_no_cache off;
        fastcgi_cache off;
        expires epoch;
    }
    
    location /api/customer {
        proxy_pass http://158.160.134.206:29637/api/customer;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }
    
    location /api/customer/ {
        proxy_pass http://158.160.134.206:29637/api/customer/;
    }
    
    location /api/session {
        proxy_pass http://158.160.134.206:29637/api/session;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }
    
    location /api/session/ {
        proxy_pass http://158.160.134.206:29637/api/session/;
    }
    
    location /long_dummy {        
        proxy_pass http://158.160.134.206:29637/long_dummy;
        
        fastcgi_cache_bypass $cookie_cache_bypass;
        #fastcgi_cache all;
        fastcgi_cache_methods GET POST HEAD;
        fastcgi_cache_valid 404 502 503 50s;
        fastcgi_cache_valid any 50s;
        fastcgi_cache_use_stale error timeout invalid_header updating;
        
        proxy_cache_bypass $cookie_cache_bypass;
        proxy_cache all;
        proxy_cache_methods GET POST HEAD;
        proxy_cache_valid 404 502 503 50s;
        proxy_cache_valid any 50s;
        proxy_cache_use_stale error timeout invalid_header updating;
    }
}