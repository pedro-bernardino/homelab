# Portainer
[Traefik](https://github.com/traefik/traefik) is a modern HTTP reverse proxy and load balancer that makes deploying microservices easy. Traefik integrates with your existing infrastructure components (Docker, Swarm mode, Kubernetes, Consul, Etcd, Rancher v2, Amazon ECS, ...) and configures itself automatically and dynamically. Pointing Traefik at your orchestrator should be the only configuration step you need.

# Usage
> [!WARNING]
> This script uses the dynamic DNS service provider [dynu](https://www.dynu.com). If you want to use another provider or your own domain, please read the documentation of traefik and change the script accordingly.

> [!INFO]
> If you need to deploy mosquitto, traefik need to be configured differently: use the [deploy_traefik_mosquitto_dynu.sh](deploy_traefik_mosquitto_dynu.sh) instead.

+ Create a folder for the traefik files 
  + ```mkdir traefik```
+ Open traefik folder
  + ```cd traefik```
+ Copy [deploy_traefik_dynu.sh](deploy_traefik_dynu.sh) to your traefik folder
+ Edit [deploy_traefik_dynu.sh](deploy_traefik_dynu.sh) and change the values with your info
+ Make [deploy_traefik_dynu.sh](deploy_traefik_dynu.sh) executable
  + ```sudo chmod +x deploy_traefik_dynu.sh```
+ Run the script to deploy traefik
  + ```./deploy_traefik_dynu.sh```
+ Add domain to pihole local dns
  + Domain: https://traefik.YOUR-DOMAIN-COM
  + IP Address: xx.xx.xx.xx (ip of docker server)
+ Open traefik dashboard
  + https://traefik.YOUR-DOMAIN-COM

> [!WARNING]
> Only change the '***USE_LETS_ENCRYPT_STAGING***' variable to 'false' when you can confirm you got a 'staging certificate' form Let’s Encrypt first. Let’s Encrypt provides rate limits to ensure fair usage by as many people as possible - more info [here](https://letsencrypt.org/docs/rate-limits/).