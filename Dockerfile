FROM nginxinc/nginx-unprivileged:stable-alpine
LABEL org.opencontainers.image.source="https://github.com/GerardA8/secure-deployment"
COPY index.html /usr/share/nginx/html/index.html
COPY revision.txt /usr/share/nginx/html/revision.txt
EXPOSE 8080
