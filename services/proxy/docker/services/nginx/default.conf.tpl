server {
    listen 80;

    root /home;

    index index.html;
    try_files $uri /index.html;
}

server {
    server_name www.api.%HOST% api.%HOST%;

    listen 80;
    listen 443 ssl;

    location / {
        proxy_pass       http://%HOST_MACHINE_ADDR%:8001;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP $remote_addr;
    }

    add_header 'Access-Control-Allow-Origin' '*' always;
    add_header 'Access-Control-Allow-Credentials' 'true' always;

    ssl_certificate     /etc/nginx/ssl/domain.crt;
    ssl_certificate_key /etc/nginx/ssl/domain.key;
}


server {
    server_name www.%HOST% %HOST%;

    listen 80;
    listen 443 ssl;

    location / {
        proxy_pass       http://%HOST_MACHINE_ADDR%:8002;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP $remote_addr;
    }

    ssl_certificate     /etc/nginx/ssl/domain.crt;
    ssl_certificate_key /etc/nginx/ssl/domain.key;
}
