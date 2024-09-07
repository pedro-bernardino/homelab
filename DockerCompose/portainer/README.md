# Portainer
[Portainer](https://github.com/portainer/portainer) Community Edition is a lightweight service delivery platform for containerized applications that can be used to manage Docker, Swarm, Kubernetes and ACI environments. It is designed to be as simple to deploy as it is to use. The application allows you to manage all your orchestrator resources (containers, images, volumes, networks and more) through a ‘smart’ GUI and/or an extensive API.

# Usage
+ Copy the [compose.yaml](/DockerCompose/portainer/compose.yaml) to your docker server (change port if needed)
  + run the command (inside the **compose.yaml** folder):
    + ***sudo docker compose up -d***