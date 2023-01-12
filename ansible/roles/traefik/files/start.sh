sudo docker rm -f traefik
docker run -d \
    --name traefik \
    --restart always \
    --network host \
    -p 8081:8081 \
    -p 80:80 \
    -v /opt/traefik/traefik.toml:/etc/traefik/traefik.toml \
    traefik:v2.5.1