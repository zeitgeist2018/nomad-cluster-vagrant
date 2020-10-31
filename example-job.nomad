job "test" {
  datacenters = ["spain"]
  type = "service"
  group "test" {
    count = 3

    task "nginx" {
      driver = "docker"
      config {
        image = "nginx:latest"

        port_map {
          db = 80
        }
      }

      resources {
        cpu    = 200 # MHz
        memory = 32 # MB

        network {
          mbits = 10
          port  "db"  {}
        }
      }
      service {
        name = "nginx"
        tags = ["frontend-/test"]
        port = "db"

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
