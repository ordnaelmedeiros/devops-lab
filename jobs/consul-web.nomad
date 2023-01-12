job consul-web {
  datacenters = ["dc1"]
  type = "service"
  group "grupo" {
    count = 1
    network {
      port "http" {
        to = 80
      }
    }
    service {
      name = "consul-web"
      port = "http"
      tags = [
        "traefik.enable=true"
      ]
    }
    task "task" {
      driver = "docker"
      config {
        image = "nginx:1.21"
        ports = ["http"]
        volumes = [
          "local/default.conf:/etc/nginx/conf.d/default.conf",
        ]
      }
      resources {
        cpu = 10
        memory = 16
      }
      template {
        destination = "local/default.conf"
        data = <<EOF
server {
  listen 80;
  location / {
    proxy_pass http://192.168.56.101:8500;
  }
  access_log off;
  error_log  /var/log/nginx/error.log error;
}
EOF
      }
    }
  }
}