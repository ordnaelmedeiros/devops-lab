job "grafana" {
  datacenters = ["dc1"]
  constraint  {
    attribute = "${meta.server-type}"
    value = "metrics"
  }
  group "grafana" {
    count = 1

    network {
      port "grafana_ui" {
        static = 3000
        to = 3000
      }
    }

    volume "grafana-data" {
      type   = "host"
      source = "grafana-data"
    }

    task "grafana" {
      driver = "docker"

      config {
        image = "grafana/grafana:7.4.2"
        ports = ["grafana_ui"]

        volumes = [
          "local/datasources:/etc/grafana/provisioning/datasources",
          "local/dashboards:/etc/grafana/provisioning/dashboards",
        ]
      }

      env {
        GF_AUTH_ANONYMOUS_ENABLED  = "true"
        GF_AUTH_ANONYMOUS_ORG_ROLE = "Editor"
        GF_SERVER_HTTP_PORT        = "${NOMAD_PORT_grafana_ui}"
      }

      resources {
        cpu    = 100
        memory = 128
      }

      service {
        name = "grafana"
        port = "grafana_ui"

        check {
          type     = "http"
          path     = "/api/health"
          interval = "10s"
          timeout  = "2s"
        }
      }
      
      volume_mount {
        volume      = "grafana-data"
        destination = "/var/lib/grafana"
      }

      template {
        data = <<EOH
apiVersion: 1
datasources:
- name: Prometheus
  type: prometheus
  access: proxy
  url: http://{{ range $i, $s := service "prometheus" }}{{ if eq $i 0 }}{{.Address}}:{{.Port}}{{end}}{{end}}
  isDefault: true
  version: 1
  editable: false
EOH

        destination = "local/datasources/prometheus.yaml"
      }

      template {
        data = <<EOH
apiVersion: 1
datasources:
- name: Loki
  type: loki
  access: proxy
  url: http://{{ range $i, $s := service "loki" }}{{ if eq $i 0 }}{{.Address}}:{{.Port}}{{end}}{{end}}
  isDefault: false
  version: 1
  editable: false
EOH

        destination = "local/datasources/loki.yaml"
      }

      template {
        data = <<EOH
apiVersion: 1

providers:
- name: Nomad Autoscaler
  folder: Nomad
  folderUid: nomad
  type: file
  disableDeletion: true
  editable: false
  allowUiUpdates: false
  options:
    path: /var/lib/grafana/dashboards
EOH

        destination = "local/dashboards/nomad-autoscaler.yaml"
      }

    }
  }
}
