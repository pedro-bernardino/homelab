# watchtower
With [watchtower](https://github.com/containrrr/watchtower) you can update the running version of your containerized app simply by pushing a new image to the Docker Hub or your own image registry.

Watchtower will pull down your new image, gracefully shut down your existing container and restart it with the same options that were used when it was deployed initially.

# Usage
+ Copy the [compose.yaml](/DockerCompose/watchtower/compose.yaml) to your docker server (change port if needed)
  + run the command (inside the **compose.yaml** folder):
    + ***sudo docker compose up -d***