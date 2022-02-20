job "prometheus" {

  datacenters = ["dc1"]
  constraint  {
    attribute = "${meta.server-type}"
    value = "metrics"
  }
  group "prometheus" {


    count = 1

    network {
      port "prometheus_ui" {
        static = 9090
        to = 9090
      }
    }

    task "prometheus" {
      driver = "docker"

      config {
        image = "prom/prometheus:v2.25.0"
        ports = ["prometheus_ui"]

        # Use `host` network so we can communicate with the Nomad and Consul
        # agents running in the host and scrape their metrics.
        network_mode = "host"

        args = [
          "--config.file=/etc/prometheus/config/prometheus.yml",
          "--storage.tsdb.path=/prometheus",
          "--web.listen-address=0.0.0.0:${NOMAD_PORT_prometheus_ui}",
          "--web.console.libraries=/usr/share/prometheus/console_libraries",
          "--web.console.templates=/usr/share/prometheus/consoles",
        ]

        volumes = [
          "local/config:/etc/prometheus/config",
        ]
      }

      template {
        data = <<EOH
---
global:
  scrape_interval:     1s
  evaluation_interval: 1s

scrape_configs:
#  - job_name: haproxy_exporter
#    static_configs:
#      - targets: [{{ range service "haproxy-exporter" }}'{{ .Address }}:{{ .Port }}',{{ end }}]

  - job_name: traefik
    metrics_path: /metrics
    static_configs:
      - targets: [{{ range service "traefik" }}'{{ .Address }}:8081',{{ end }}]

  - job_name: nomad_autoscaler
    metrics_path: /v1/metrics
    params:
      format: ['prometheus']
    static_configs:
      - targets: [{{ range service "autoscaler" }}'{{ .Address }}:{{ .Port }}',{{ end }}]

  - job_name: consul
    metrics_path: /v1/agent/metrics
    params:
      format: ['prometheus']
    static_configs:
    - targets: [{{ range service "consul" }}'{{ .Address }}:8500',{{ end }}{{ range service "nomad-client" }}'{{ .Address }}:8500',{{ end }}]
#    - targets: ['{{ env "attr.unique.network.ip-address" }}:8500']

  - job_name: nomad
    metrics_path: /v1/metrics
    params:
      format: ['prometheus']
    static_configs:
    - targets: [{{ range service "nomad-server" }}'{{ .Address }}:4646',{{ end }}{{ range service "nomad-client" }}'{{ .Address }}:4646',{{ end }}]
#    - targets: ['{{ env "attr.unique.network.ip-address" }}:4646']

  - job_name: consul-connect-envoy
    consul_sd_configs:
    - server: 'http://192.168.100.151:8500'
    relabel_configs:
    - source_labels: [__meta_consul_service]
      regex: (.+)-sidecar-proxy
      action: drop
    - source_labels: [__meta_consul_service_metadata_metrics_port_envoy]
      regex: (.+)
      action: keep
    - source_labels: [__address__,__meta_consul_service_metadata_metrics_port_envoy]
      regex: ([^:]+)(?::\d+)?;(\d+)
      replacement: $1:$2
      target_label: __address__

EOH
        change_mode   = "signal"
        change_signal = "SIGHUP"
        destination   = "local/config/prometheus.yml"
      }

      resources {
        cpu    = 100
        memory = 256
      }

      service {
        name = "prometheus"
        port = "prometheus_ui"

        check {
          type     = "http"
          path     = "/-/healthy"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
