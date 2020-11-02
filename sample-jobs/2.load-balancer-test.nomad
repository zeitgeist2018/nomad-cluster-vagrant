job "lb-test-job" {
  datacenters = ["spain"]
  type = "service"
  group "test-group" {
    count = 3

    task "lb-test-task" {
      driver = "docker"
      config {
        image = "nginxdemos/hello"

        port_map {
          http = 80
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
        name = "lb-test-service"
        port = "http"
        meta {
          frontend = "lb-test"
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
