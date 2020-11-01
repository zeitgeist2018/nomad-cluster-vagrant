job "test-job" {
  datacenters = ["spain"]
  type = "service"
  group "test-group" {
    count = 6

    task "test-task" {
      driver = "docker"
      config {
        image = "nginx:latest"

        port_map {
          db = 80
        }
      }

      resources {
        cpu    = 100 # MHz
        memory = 32 # MB

        network {
          mbits = 10
          port  "http"  {}
        }
      }
      service {
        name = "test-service"
        port = "http"
        meta {
          frontend = "nginx"
        }

        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
