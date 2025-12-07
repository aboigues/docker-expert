# Programme de Préparation à la Certification Docker DCA
## Docker Certified Associate (DCA)

![DCA Badge](https://training.mirantis.com/wp-content/uploads/2019/05/Docker-Certification-Badge.png)

> **🆕 Mise à jour 2025** : Ce programme a été actualisé pour refléter les derniers changements de la certification DCA gérée par Mirantis. Les références aux produits renommés (UCP → MKE, DTR → MSR) et les technologies dépréciées (AUFS, DeviceMapper) ont été mises à jour.

---

## 📋 Table des matières

1. [Présentation de la certification DCA](#présentation-de-la-certification-dca)
2. [Domaines d'examen et pondération](#domaines-dexamen-et-pondération)
3. [Programme de formation (12 semaines)](#programme-de-formation-12-semaines)
4. [Mapping avec les TPs existants](#mapping-avec-les-tps-existants)
5. [Ressources complémentaires](#ressources-complémentaires)
6. [Examens blancs et révisions](#examens-blancs-et-révisions)
7. [Conseils pour l'examen](#conseils-pour-lexamen)

---

## 🎯 Présentation de la certification DCA

### Qu'est-ce que la certification DCA ?

La **Docker Certified Associate (DCA)** est la certification officielle de Docker Inc. qui valide vos compétences en matière de conteneurisation avec Docker. Elle est reconnue mondialement et démontre votre expertise dans l'utilisation de Docker en environnement de production.

### Informations sur l'examen

- **Durée :** 90 minutes
- **Nombre de questions :** 55 questions (QCM et questions pratiques)
- **Score minimum :** 65% (36/55 questions correctes)
- **Format :** En ligne, surveillé par webcam
- **Langue :** Anglais
- **Validité :** 2 ans
- **Prix :** $199 USD
- **Type :** Questions à choix multiples, vrai/faux, et scénarios pratiques

### À qui s'adresse cette certification ?

- Ingénieurs DevOps
- Administrateurs système
- Développeurs travaillant avec Docker
- Architectes cloud
- Toute personne souhaitant valider ses compétences Docker

---

## 📊 Domaines d'examen et pondération

L'examen DCA couvre **6 domaines principaux** avec des pondérations différentes :

### 1. Orchestration (25%)

**Compétences requises :**
- ✅ Compléter la configuration d'un cluster Swarm
- ✅ Déclarer et gérer les services dans un swarm
- ✅ Comprendre les états des nœuds et des tâches
- ✅ Gérer les nœuds dans un swarm
- ✅ Interpréter la sortie des commandes "docker inspect"
- ✅ Convertir une application en stack deployable
- ✅ Manipuler un conteneur en cours d'exécution
- ✅ Comprendre les types de verrouillage Swarm
- ✅ Étendre les instructions dans un Compose file pour déployer un stack
- ✅ Augmenter et réduire le nombre de réplicas
- ✅ Exécuter des services de réplication vs globaux
- ✅ Démontrer les étapes pour verrouiller/déverrouiller un cluster
- ✅ Appliquer les stratégies de mise à jour de nœuds
- ✅ Illustrer l'exécution d'une application stack dans un swarm

**Commandes clés à maîtriser :**
```bash
docker swarm init/join/leave/update
docker node ls/inspect/update/promote/demote
docker service create/ls/inspect/update/scale/rm
docker stack deploy/ls/ps/rm/services
docker config create/ls/inspect/rm
docker secret create/ls/inspect/rm
```

### 2. Création, gestion et registre d'images (20%)

**Compétences requises :**
- ✅ Décrire les composants d'un Dockerfile
- ✅ Afficher les couches d'une image Docker
- ✅ Modifier une image pour créer une nouvelle image
- ✅ Déployer un registry
- ✅ Configurer un registry
- ✅ Logger dans un registry
- ✅ Utiliser un registry privé
- ✅ Pousser/tirer des images vers/depuis un registry
- ✅ Supprimer des images d'un registry
- ✅ Taguer des images
- ✅ Comprendre et utiliser les multi-stage builds
- ✅ Appliquer les bonnes pratiques de création d'images

**Commandes clés à maîtriser :**
```bash
docker build --tag --file --target
docker image ls/inspect/history/prune/rm
docker tag
docker push/pull
docker login/logout
docker commit
docker save/load
docker export/import
```

### 3. Installation et configuration (15%)

**Compétences requises :**
- ✅ Démontrer la capacité à mettre à niveau le Docker Engine
- ✅ Configurer les logs (drivers, niveaux)
- ✅ Configurer le démarrage automatique des conteneurs
- ✅ Décrire et démontrer la configuration du daemon Docker
- ✅ Comprendre les namespaces, cgroups et certificate
- ✅ Utiliser les label et filtres pour la gestion
- ✅ Décrire et interpréter les erreurs pour dépanner les problèmes d'installation
- ✅ Déployer Docker sur plusieurs plateformes (Linux, Windows)
- ✅ Participer au programme Docker Community Edition (CE)
- ✅ Identifier et sélectionner le meilleur storage driver pour un scénario

**Fichiers de configuration importants :**
```bash
/etc/docker/daemon.json
/lib/systemd/system/docker.service
~/.docker/config.json
```

### 4. Networking (15%)

**Compétences requises :**
- ✅ Créer un réseau Docker
- ✅ Déployer un service sur un réseau Docker
- ✅ Identifier les drivers de réseau par défaut et leurs cas d'usage
- ✅ Comprendre l'impact de "--link" et son utilisation
- ✅ Comprendre les types de trafic entrant dans et sortant du moteur Docker
- ✅ Déployer un service qui publie des ports
- ✅ Identifier les ports exposés par un conteneur
- ✅ Comprendre les différences entre bridge, overlay, macvlan, host et none
- ✅ Décrire le traffic flow dans Swarm mode
- ✅ Dépanner les problèmes de résolution de conteneur et de service

**Commandes clés à maîtriser :**
```bash
docker network create/ls/inspect/rm/connect/disconnect
docker network prune
docker port
```

**Types de réseaux :**
- **bridge** : réseau par défaut pour conteneurs standalone
- **overlay** : pour la communication inter-hôtes dans Swarm
- **host** : supprime l'isolation réseau
- **macvlan** : assigne une adresse MAC au conteneur
- **none** : désactive le networking

### 5. Sécurité (15%)

**Compétences requises :**
- ✅ Décrire les meilleures pratiques de sécurité pour Docker daemon et conteneurs
- ✅ Démontrer la création d'un utilisateur MKE (Mirantis Kubernetes Engine)
- ✅ Configurer RBAC (Role-Based Access Control)
- ✅ Intégrer MKE avec LDAP/AD
- ✅ Démontrer la création d'une équipe MKE
- ✅ Utiliser MSR (Mirantis Secure Registry)
- ✅ Décrire les meilleures pratiques d'utilisation de MSR
- ✅ Décrire le processus de signature d'image
- ✅ Démontrer qu'une image passe un scan de sécurité
- ✅ Activer Docker Content Trust
- ✅ Configurer RBAC dans MKE
- ✅ Comprendre et configurer les certificats TLS
- ✅ Utiliser les secrets et configs dans Swarm

**Commandes clés à maîtriser :**
```bash
docker secret create/ls/inspect/rm
docker config create/ls/inspect/rm
docker run --cap-add --cap-drop
docker run --security-opt
docker trust sign/revoke/inspect
```

**Variables d'environnement importantes :**
```bash
DOCKER_CONTENT_TRUST=1
DOCKER_CONTENT_TRUST_SERVER
```

### 6. Storage et volumes (10%)

**Compétences requises :**
- ✅ Identifier les cas d'usage des volumes vs bind mounts
- ✅ Démontrer comment créer des volumes d'hôte
- ✅ Créer et gérer des volumes via la ligne de commande
- ✅ Monter des volumes dans des conteneurs
- ✅ Utiliser tmpfs pour le stockage temporaire
- ✅ Appliquer les permissions filesystem sur les volumes
- ✅ Comprendre les storage drivers et leur impact
- ✅ Configurer overlay2 et ses options avancées
- ✅ Comparer et distinguer object vs block storage

**Commandes clés à maîtriser :**
```bash
docker volume create/ls/inspect/rm/prune
docker run -v / --volume
docker run --mount
docker run --tmpfs
```

**Storage drivers :**
- **overlay2** : recommandé pour la plupart des cas (Linux moderne)
- **btrfs/zfs** : pour systèmes de fichiers spécifiques
- **vfs** : pas de copy-on-write, lent (tests uniquement)

**⚠️ Dépréciés (ne plus utiliser) :**
- **aufs** : complètement déprécié depuis Docker 20.10
- **devicemapper** : déprécié, utiliser overlay2 à la place

---

## 📅 Programme de formation (12 semaines)

### 🗓️ Semaine 1-2 : Installation, configuration et fondamentaux

**Objectifs :**
- Installer Docker sur différentes plateformes
- Configurer le Docker daemon
- Comprendre l'architecture Docker
- Maîtriser les commandes de base

**Thèmes à étudier :**
- [ ] Installation de Docker CE/EE sur Ubuntu, CentOS, Windows
- [ ] Configuration de `/etc/docker/daemon.json`
- [ ] Gestion du service Docker avec systemd
- [ ] Logging drivers : json-file, syslog, journald, fluentd
- [ ] Comprendre namespaces et cgroups
- [ ] Labels et filtres

**Exercices pratiques :**
```bash
# Configuration du daemon
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "live-restore": true
}
EOF

sudo systemctl restart docker
docker info

# Tester les labels
docker run -d --label env=prod --label tier=frontend nginx
docker ps --filter "label=env=prod"
```

**Ressources :**
- [Docker Installation Guide](https://docs.docker.com/engine/install/)
- [Daemon configuration](https://docs.docker.com/config/daemon/)
- [Post-installation steps](https://docs.docker.com/engine/install/linux-postinstall/)

---

### 🗓️ Semaine 3-4 : Images et Dockerfile

**Objectifs :**
- Maîtriser l'écriture de Dockerfiles optimisés
- Comprendre le système de couches
- Utiliser les multi-stage builds
- Gérer les images efficacement

**Thèmes à étudier :**
- [ ] Instructions Dockerfile : FROM, RUN, CMD, ENTRYPOINT, COPY, ADD, ENV, ARG, WORKDIR, EXPOSE, USER, VOLUME
- [ ] Multi-stage builds
- [ ] Build cache et optimisation
- [ ] .dockerignore
- [ ] Image layers et Union File System
- [ ] Build arguments et variables d'environnement

**TP associé :**
➡️ **[TP1: Multi-stage Builds et Optimisation d'Images](./tp1-multistage-optimization/README.md)**

**Exercices pratiques :**
```dockerfile
# Exemple de multi-stage build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

```bash
# Commandes à pratiquer
docker build -t myapp:v1 .
docker build --target builder -t myapp:builder .
docker build --no-cache -t myapp:v2 .
docker image history myapp:v1
docker image inspect myapp:v1
docker save myapp:v1 -o myapp.tar
docker load -i myapp.tar
```

**Quiz de validation :**
1. Quelle est la différence entre CMD et ENTRYPOINT ?
2. Pourquoi utiliser multi-stage builds ?
3. Comment réduire le nombre de layers dans une image ?
4. Différence entre COPY et ADD ?

---

### 🗓️ Semaine 5 : Registries et gestion d'images

**Objectifs :**
- Déployer et configurer un registry privé
- Gérer les images (push, pull, tag)
- Implémenter Docker Content Trust
- Comprendre l'authentification

**Thèmes à étudier :**
- [ ] Docker Hub vs registries privés
- [ ] Déployer Docker Registry v2
- [ ] Configuration TLS pour registry
- [ ] Authentification basique et token-based
- [ ] Docker Content Trust (DCT)
- [ ] Image signing et verification
- [ ] Garbage collection dans registry

**TP associé :**
➡️ **[TP8: CI/CD et Registry Privé](./tp8-cicd-registry/README.md)**

**Exercices pratiques :**
```bash
# Déployer un registry privé
docker run -d -p 5000:5000 \
  --restart=always \
  --name registry \
  -v registry-data:/var/lib/registry \
  registry:2

# Tagger et pousser une image
docker tag nginx:alpine localhost:5000/nginx:v1
docker push localhost:5000/nginx:v1

# Activer Docker Content Trust
export DOCKER_CONTENT_TRUST=1
docker pull nginx:alpine
docker trust inspect nginx:alpine

# Lister les images d'un registry
curl -X GET http://localhost:5000/v2/_catalog
curl -X GET http://localhost:5000/v2/nginx/tags/list
```

**Challenge :**
Déployer un registry privé avec :
- Authentification HTTP Basic
- Certificat TLS auto-signé
- Configuration de garbage collection
- UI web pour explorer les images

---

### 🗓️ Semaine 6 : Networking

**Objectifs :**
- Maîtriser tous les drivers réseau Docker
- Configurer des réseaux custom
- Comprendre le port mapping
- Déboguer les problèmes réseau

**Thèmes à étudier :**
- [ ] Bridge networks (default et custom)
- [ ] Host network mode
- [ ] Overlay networks pour Swarm
- [ ] Macvlan networks
- [ ] None network
- [ ] Port publishing (-p vs -P)
- [ ] DNS et service discovery
- [ ] Network troubleshooting

**TP associé :**
➡️ **[TP2: Networking Avancé et Service Mesh](./tp2-networking-advanced/README.md)**

**Exercices pratiques :**
```bash
# Créer différents types de réseaux
docker network create --driver bridge my-bridge
docker network create --driver overlay --attachable my-overlay
docker network create --driver macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  -o parent=eth0 my-macvlan

# Tester la connectivité
docker run -dit --name container1 --network my-bridge alpine
docker run -dit --name container2 --network my-bridge alpine
docker exec container1 ping container2

# Port mapping
docker run -d -p 8080:80 nginx  # map host 8080 -> container 80
docker run -d -P nginx           # map random port -> EXPOSE
docker port <container_id>

# Inspecter le réseau
docker network inspect bridge
docker inspect <container> | jq '.[0].NetworkSettings'
```

**Scénarios de troubleshooting :**
1. Container ne peut pas résoudre les noms DNS
2. Services ne peuvent pas communiquer entre réseaux
3. Port déjà utilisé sur l'hôte
4. Performance réseau dégradée

---

### 🗓️ Semaine 7 : Storage et volumes

**Objectifs :**
- Comprendre volumes vs bind mounts vs tmpfs
- Gérer la persistance des données
- Configurer les storage drivers
- Optimiser les performances I/O

**Thèmes à étudier :**
- [ ] Volumes Docker (named volumes)
- [ ] Bind mounts
- [ ] tmpfs mounts
- [ ] Volume drivers
- [ ] Storage drivers (overlay2, btrfs, zfs)
- [ ] Backup et restore de volumes
- [ ] Performance considerations

**TP associé :**
➡️ **[TP3: Volumes, Bind Mounts et Storage Drivers](./tp3-storage-volumes/README.md)**

**Exercices pratiques :**
```bash
# Créer et utiliser des volumes
docker volume create mydata
docker run -d -v mydata:/data nginx
docker run -d --mount type=volume,source=mydata,target=/data nginx

# Bind mounts
docker run -d -v /host/path:/container/path nginx
docker run -d --mount type=bind,source=/host/path,target=/container/path nginx

# tmpfs (données en RAM)
docker run -d --tmpfs /app/temp:rw,size=100m nginx
docker run -d --mount type=tmpfs,target=/app/temp,tmpfs-size=100m nginx

# Backup d'un volume
docker run --rm -v mydata:/data -v $(pwd):/backup alpine \
  tar czf /backup/mydata-backup.tar.gz -C /data .

# Restore
docker run --rm -v mydata:/data -v $(pwd):/backup alpine \
  tar xzf /backup/mydata-backup.tar.gz -C /data

# Inspecter le storage driver
docker info | grep "Storage Driver"
```

**Quiz :**
1. Quand utiliser un volume vs un bind mount ?
2. Avantages de tmpfs pour les données sensibles ?
3. Comment migrer des données entre volumes ?

---

### 🗓️ Semaine 8-9 : Orchestration avec Docker Swarm

**Objectifs :**
- Initialiser et gérer un cluster Swarm
- Déployer et scaler des services
- Gérer les secrets et configs
- Comprendre le routing mesh

**Thèmes à étudier :**
- [ ] Swarm architecture (managers vs workers)
- [ ] Initialisation d'un swarm
- [ ] Gestion des nœuds
- [ ] Services : replicated vs global
- [ ] Service discovery interne
- [ ] Routing mesh et load balancing
- [ ] Stacks et Compose files v3
- [ ] Secrets et configs
- [ ] Rolling updates et rollback
- [ ] Health checks
- [ ] Placement constraints

**TP associé :**
➡️ **[TP5: Docker Compose Avancé et Orchestration](./tp5-compose-orchestration/README.md)**

**Exercices pratiques :**
```bash
# Initialiser un swarm
docker swarm init --advertise-addr <MANAGER-IP>

# Ajouter des workers
docker swarm join-token worker
docker swarm join --token <TOKEN> <MANAGER-IP>:2377

# Promouvoir un worker en manager
docker node promote <NODE-ID>

# Créer un service
docker service create --name web \
  --replicas 3 \
  --publish 8080:80 \
  nginx:alpine

# Scaler un service
docker service scale web=5

# Update d'un service
docker service update --image nginx:latest web
docker service update --rollback web

# Créer et utiliser des secrets
echo "mysecretpassword" | docker secret create db_password -
docker service create --name db \
  --secret db_password \
  postgres:alpine

# Déployer un stack
cat > docker-stack.yml <<EOF
version: '3.8'
services:
  web:
    image: nginx:alpine
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
    ports:
      - "80:80"
    networks:
      - frontend

networks:
  frontend:
    driver: overlay
EOF

docker stack deploy -c docker-stack.yml myapp

# Lister les services du stack
docker stack services myapp
docker stack ps myapp

# Inspecter un service
docker service inspect web --pretty
docker service logs web
```

**Scénarios à maîtriser :**
1. Drain d'un nœud pour maintenance
2. Rollback d'une mise à jour défaillante
3. Configuration de constraints pour placer des services
4. Mise en place d'un stack multi-tier (frontend, backend, database)

---

### 🗓️ Semaine 10 : Sécurité Docker

**Objectifs :**
- Implémenter les meilleures pratiques de sécurité
- Configurer les capabilities Linux
- Utiliser les secrets Docker
- Scanner les vulnérabilités
- Comprendre Docker Content Trust

**Thèmes à étudier :**
- [ ] Principe du moindre privilège
- [ ] User namespaces
- [ ] Capabilities Linux
- [ ] AppArmor et SELinux
- [ ] Seccomp profiles
- [ ] Docker rootless mode
- [ ] Image scanning (Trivy, Clair, Docker Scout)
- [ ] Docker Content Trust
- [ ] Secrets management
- [ ] TLS pour Docker daemon
- [ ] RBAC dans Swarm

**TP associé :**
➡️ **[TP4: Sécurité Docker Avancée](./tp4-security-advanced/README.md)**

**Exercices pratiques :**
```bash
# Scanner une image avec Trivy
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image nginx:alpine

# Capabilities
docker run --rm --cap-drop ALL --cap-add NET_BIND_SERVICE nginx
docker run --rm --cap-add=SYS_ADMIN alpine

# User namespaces
docker run --user 1000:1000 alpine id

# Read-only filesystem
docker run --read-only --tmpfs /tmp nginx

# Seccomp profile
docker run --security-opt seccomp=/path/to/profile.json alpine

# AppArmor
docker run --security-opt apparmor=docker-default nginx

# No new privileges
docker run --security-opt no-new-privileges alpine

# Activer Content Trust
export DOCKER_CONTENT_TRUST=1
docker pull nginx:alpine  # vérifie la signature

# Configurer TLS pour Docker daemon
dockerd --tlsverify \
  --tlscacert=ca.pem \
  --tlscert=server-cert.pem \
  --tlskey=server-key.pem \
  -H=0.0.0.0:2376
```

**Checklist de sécurité :**
- [ ] N'exécuter aucun conteneur en tant que root
- [ ] Scanner toutes les images pour les vulnérabilités
- [ ] Utiliser des images officielles et vérifiées
- [ ] Limiter les ressources (CPU, mémoire)
- [ ] Activer Docker Content Trust en production
- [ ] Utiliser secrets pour les données sensibles
- [ ] Appliquer le principe du moindre privilège
- [ ] Maintenir Docker à jour

---

### 🗓️ Semaine 11 : Monitoring, Logging et Debugging

**Objectifs :**
- Mettre en place un monitoring des conteneurs
- Centraliser les logs
- Déboguer les conteneurs en production
- Analyser les performances

**Thèmes à étudier :**
- [ ] docker stats et docker top
- [ ] Prometheus + cAdvisor + Grafana
- [ ] Logging drivers
- [ ] ELK Stack (Elasticsearch, Logstash, Kibana)
- [ ] Loki + Promtail + Grafana
- [ ] Health checks
- [ ] docker events
- [ ] Performance troubleshooting

**TP associé :**
➡️ **[TP6: Monitoring, Logging et Debugging](./tp6-monitoring-debugging/README.md)**

**Exercices pratiques :**
```bash
# Monitoring basique
docker stats
docker top <container>
docker events

# Health checks dans Dockerfile
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost/ || exit 1

# Health checks dans docker-compose
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost"]
  interval: 30s
  timeout: 10s
  retries: 3

# Logs
docker logs -f --tail 100 <container>
docker service logs -f <service>

# Inspecter les ressources
docker inspect <container> | jq '.[0].State'
docker inspect <container> | jq '.[0].HostConfig.Memory'

# Limiter les ressources
docker run -d --memory="512m" --cpus="1.5" nginx

# Stack de monitoring avec Prometheus
cat > monitoring-stack.yml <<EOF
version: '3.8'
services:
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    ports:
      - "9090:9090"

  cadvisor:
    image: gcr.io/cadvisor/cadvisor
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    ports:
      - "8080:8080"

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana-data:/var/lib/grafana

volumes:
  prometheus-data:
  grafana-data:
EOF
```

---

### 🗓️ Semaine 12 : BuildKit et CI/CD

**Objectifs :**
- Maîtriser BuildKit et ses features avancées
- Créer des pipelines CI/CD
- Automatiser les builds et déploiements

**Thèmes à étudier :**
- [ ] BuildKit features
- [ ] Cache mounts et build secrets
- [ ] Multi-platform builds
- [ ] GitHub Actions pour Docker
- [ ] GitLab CI avec Docker
- [ ] Automated testing

**TPs associés :**
➡️ **[TP7: BuildKit et Build Avancé](./tp7-buildkit-advanced/README.md)**
➡️ **[TP8: CI/CD et Registry Privé](./tp8-cicd-registry/README.md)**

**Exercices pratiques :**
```dockerfile
# syntax=docker/dockerfile:1.4

FROM node:20-alpine AS builder
WORKDIR /app

# Cache mount pour npm
RUN --mount=type=cache,target=/root/.npm \
    npm install

# Build secrets
RUN --mount=type=secret,id=npm_token \
    echo "//registry.npmjs.org/:_authToken=$(cat /run/secrets/npm_token)" > ~/.npmrc

COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
```

```bash
# Build avec BuildKit
DOCKER_BUILDKIT=1 docker build \
  --secret id=npm_token,src=./npm_token \
  --build-arg VERSION=1.0.0 \
  -t myapp:latest .

# Multi-platform build
docker buildx create --use
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t myapp:multiarch \
  --push .
```

---

## 🔗 Mapping avec les TPs existants

| Domaine DCA | TP correspondant | Couverture |
|-------------|------------------|------------|
| **Orchestration (25%)** | TP5: Docker Compose et Orchestration | ⭐⭐⭐⭐⭐ |
| **Images et Registry (20%)** | TP1: Multi-stage Builds<br/>TP7: BuildKit<br/>TP8: CI/CD et Registry | ⭐⭐⭐⭐⭐ |
| **Installation et Config (15%)** | Tous les TPs (prérequis) | ⭐⭐⭐ |
| **Networking (15%)** | TP2: Networking Avancé | ⭐⭐⭐⭐⭐ |
| **Sécurité (15%)** | TP4: Sécurité Avancée | ⭐⭐⭐⭐⭐ |
| **Storage (10%)** | TP3: Storage et Volumes | ⭐⭐⭐⭐⭐ |
| **Monitoring/Debugging** | TP6: Monitoring et Debugging | ⭐⭐⭐⭐ |

### Parcours d'apprentissage recommandé

```
Semaine 1-2: Fondamentaux
    ↓
Semaine 3-4: TP1 (Images)
    ↓
Semaine 5: TP8 (Registry)
    ↓
Semaine 6: TP2 (Networking)
    ↓
Semaine 7: TP3 (Storage)
    ↓
Semaine 8-9: TP5 (Orchestration)
    ↓
Semaine 10: TP4 (Sécurité)
    ↓
Semaine 11: TP6 (Monitoring)
    ↓
Semaine 12: TP7 (BuildKit) + Révisions
    ↓
EXAMEN DCA 🎯
```

---

## 📚 Ressources complémentaires

### Documentation officielle

- 📘 [Docker Documentation](https://docs.docker.com/)
- 📘 [Docker Engine API](https://docs.docker.com/engine/api/)
- 📘 [Dockerfile Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- 📘 [Docker Security](https://docs.docker.com/engine/security/)
- 📘 [Swarm Mode](https://docs.docker.com/engine/swarm/)

### Guides d'étude DCA

- 📖 [Docker Certified Associate Study Guide (officiel)](https://training.mirantis.com/dca-certification-exam/)
- 📖 [DCA Exam Prep Guide](https://github.com/DevOps-Academy-Org/dca-prep-guide)
- 📖 [Docker Deep Dive - Nigel Poulton](https://www.amazon.com/Docker-Deep-Dive-Nigel-Poulton/dp/1521822808)

### Plateformes d'entraînement

- 💻 [Play with Docker](https://labs.play-with-docker.com/) - Lab gratuit en ligne
- 💻 [KodeKloud Docker Labs](https://kodekloud.com/courses/docker-certified-associate-exam-course/)
- 💻 [Linux Academy / ACG Docker Courses](https://acloudguru.com/)

### Vidéos et cours

- 🎥 [Docker Mastery - Bret Fisher (Udemy)](https://www.udemy.com/course/docker-mastery/)
- 🎥 [Docker Certified Associate Prep - KodeKloud](https://kodekloud.com/courses/docker-certified-associate-exam-course/)
- 🎥 [Docker Deep Dive - Pluralsight](https://www.pluralsight.com/courses/docker-deep-dive-update)

### Communauté

- 💬 [Docker Community Forums](https://forums.docker.com/)
- 💬 [Docker Subreddit](https://www.reddit.com/r/docker/)
- 💬 [Docker Community Slack](https://www.docker.com/docker-community)
- 💬 Stack Overflow tag: [docker]

---

## 📝 Examens blancs et révisions

### Examens blancs recommandés

1. **KodeKloud Practice Tests**
   - 3 examens complets (55 questions chacun)
   - Explication détaillée pour chaque réponse
   - [Lien](https://kodekloud.com/courses/docker-certified-associate-exam-course/)

2. **Study4Exam DCA Practice Tests**
   - Plusieurs ensembles de questions
   - Format similaire à l'examen réel

3. **Examens blancs GitHub**
   - [DCA Practice Questions](https://github.com/DevOps-Academy-Org/dca-prep-guide)
   - Questions de la communauté

### Questions types par domaine

#### Orchestration (25%)

**Question 1:**
Vous devez déployer un service Redis qui doit s'exécuter sur tous les nœuds du swarm. Quelle commande utilisez-vous ?

A) `docker service create --replicas 5 redis`
B) `docker service create --mode global redis`
C) `docker service create --constraint node.role==worker redis`
D) `docker service create --placement-pref spread=node.id redis`

**Réponse : B**

---

**Question 2:**
Comment verrouiller un cluster Swarm pour empêcher les managers redémarrés de rejoindre automatiquement ?

A) `docker swarm lock`
B) `docker swarm update --autolock=true`
C) `docker node update --availability drain`
D) `docker swarm init --autolock`

**Réponse : B**

---

**Question 3:**
Vous voulez mettre à jour un service avec zéro downtime. Quelle stratégie utilisez-vous ?

```bash
docker service update \
  --update-parallelism 1 \
  --update-delay 10s \
  --image myapp:v2 \
  myapp
```

A) Met à jour tous les conteneurs en parallèle
B) Met à jour 1 conteneur à la fois avec 10s de délai
C) Met à jour avec un délai de 10s entre chaque batch
D) Rollback automatique après 10s

**Réponse : B**

---

#### Images et Registry (20%)

**Question 4:**
Quelle instruction Dockerfile utiliser pour copier des fichiers d'un stage de build à un autre ?

A) `COPY --from=builder /app /app`
B) `ADD --from=builder /app /app`
C) `RUN cp --from=builder /app /app`
D) `IMPORT --from=builder /app`

**Réponse : A**

---

**Question 5:**
Comment supprimer toutes les images non utilisées ?

A) `docker image rm $(docker images -q)`
B) `docker image prune -a`
C) `docker rmi --all`
D) `docker system prune`

**Réponse : B** (avec `-a` pour inclure les images non taguées)

---

**Question 6:**
Quelle est la différence entre `docker save` et `docker export` ?

A) Aucune différence
B) `save` préserve les layers et metadata, `export` crée un flat filesystem
C) `export` inclut l'historique, `save` non
D) `save` est pour les conteneurs, `export` pour les images

**Réponse : B**

---

#### Networking (15%)

**Question 7:**
Quel driver réseau permet aux conteneurs d'obtenir une IP du réseau physique ?

A) bridge
B) overlay
C) macvlan
D) host

**Réponse : C**

---

**Question 8:**
Comment publier le port 80 d'un conteneur sur un port aléatoire de l'hôte ?

A) `docker run -p 80 nginx`
B) `docker run -P nginx`
C) `docker run --publish 80 nginx`
D) `docker run --expose 80 nginx`

**Réponse : B** (nécessite EXPOSE dans le Dockerfile)

---

**Question 9:**
Dans un Swarm, quel réseau est créé automatiquement pour la communication inter-services ?

A) bridge
B) ingress
C) docker_gwbridge
D) host

**Réponse : B** (ingress pour le routing mesh)

---

#### Sécurité (15%)

**Question 10:**
Comment passer un secret à un service Swarm ?

```bash
echo "mypassword" | docker secret create db_pass -
docker service create --secret db_pass postgres
```

Où le secret est-il accessible dans le conteneur ?

A) Variable d'environnement `$db_pass`
B) Fichier `/run/secrets/db_pass`
C) Fichier `/var/secrets/db_pass`
D) Fichier `/etc/secrets/db_pass`

**Réponse : B**

---

**Question 11:**
Quelle commande retire toutes les capabilities sauf NET_BIND_SERVICE ?

A) `docker run --cap-drop ALL --cap-add NET_BIND_SERVICE nginx`
B) `docker run --privileged=false --cap NET_BIND_SERVICE nginx`
C) `docker run --security-opt cap=NET_BIND_SERVICE nginx`
D) `docker run --cap=NET_BIND_SERVICE nginx`

**Réponse : A**

---

**Question 12:**
Comment activer Docker Content Trust pour toutes les opérations pull/push ?

A) `docker config set content-trust true`
B) `export DOCKER_CONTENT_TRUST=1`
C) `docker trust enable`
D) Dans `/etc/docker/daemon.json`: `{"content-trust": true}`

**Réponse : B**

---

#### Storage (10%)

**Question 13:**
Quelle est la principale différence entre un volume et un bind mount ?

A) Les volumes sont plus rapides
B) Les volumes sont gérés par Docker, les bind mounts pointent vers le filesystem hôte
C) Les bind mounts sont deprecated
D) Aucune différence réelle

**Réponse : B**

---

**Question 14:**
Comment créer un volume tmpfs de 100MB ?

A) `docker run --tmpfs /app:size=100m nginx`
B) `docker run --mount type=tmpfs,target=/app,tmpfs-size=100m nginx`
C) Les deux A et B
D) `docker volume create --driver tmpfs --opt size=100m`

**Réponse : C**

---

**Question 15:**
Quel storage driver est recommandé pour la production sur Linux moderne ?

A) ~~aufs~~ (déprécié)
B) ~~devicemapper~~ (déprécié)
C) overlay2
D) vfs

**Réponse : C** - overlay2 est le storage driver recommandé pour tous les systèmes Linux modernes

---

### Plan de révision (dernière semaine)

#### Jour 1-2 : Révision Orchestration
- [ ] Créer un swarm à 3 managers et 2 workers
- [ ] Déployer un stack complet (web, api, db, cache)
- [ ] Pratiquer les rolling updates et rollbacks
- [ ] Tester le drain/active de nœuds
- [ ] Utiliser secrets et configs

#### Jour 3 : Révision Images et Registry
- [ ] Écrire 5 Dockerfiles avec multi-stage
- [ ] Optimiser une image de 1GB à < 100MB
- [ ] Déployer un registry privé avec TLS
- [ ] Pratiquer tagging et pushing

#### Jour 4 : Révision Networking et Storage
- [ ] Créer tous les types de réseaux
- [ ] Tester la communication inter-conteneurs
- [ ] Créer et gérer des volumes
- [ ] Pratiquer backup/restore

#### Jour 5 : Révision Sécurité
- [ ] Scanner des images avec Trivy
- [ ] Configurer capabilities
- [ ] Utiliser Docker Content Trust
- [ ] Créer des secrets Swarm

#### Jour 6 : Examen blanc complet
- [ ] Faire un examen blanc de 55 questions en 90 minutes
- [ ] Analyser les erreurs
- [ ] Réviser les points faibles

#### Jour 7 : Révision finale
- [ ] Relire les notes
- [ ] Pratiquer les commandes difficiles
- [ ] Se reposer avant l'examen

---

## 💡 Conseils pour l'examen

### Avant l'examen

1. **Configuration technique**
   - ✅ Testez votre webcam et micro 24h avant
   - ✅ Vérifiez votre connexion internet (min 1 Mbps)
   - ✅ Fermez toutes les applications sauf le navigateur
   - ✅ Préparez une pièce d'identité valide
   - ✅ Bureau propre (rien d'écrit visible)

2. **Préparation mentale**
   - ✅ Bonne nuit de sommeil
   - ✅ Pas de caféine excessive
   - ✅ Prévoyez une pause si nécessaire (le timer continue)

### Pendant l'examen

1. **Gestion du temps**
   - 90 minutes pour 55 questions = ~1min30 par question
   - Ne restez pas bloqué sur une question
   - Marquez les questions difficiles pour y revenir
   - Gardez 10-15 minutes pour réviser

2. **Stratégie de réponse**
   - Lisez attentivement chaque question
   - Éliminez les réponses évidemment fausses
   - Méfiez-vous des questions à double négation
   - Attention aux mots-clés : "toujours", "jamais", "tous", "aucun"
   - Les scénarios pratiques valent souvent plus de points

3. **Points d'attention**
   - Les commandes exactes comptent (flags, options)
   - L'ordre des arguments peut être important
   - Distinction entre Docker Swarm et Kubernetes (ne pas confondre)
   - Comprendre la question : que demande-t-on exactement ?

### Types de questions

1. **Questions de commandes**
   - Connaître la syntaxe exacte
   - Savoir quels flags utiliser
   - Exemple : `docker service create --replicas 3 --publish 8080:80 nginx`

2. **Questions de scénarios**
   - Analyser le besoin
   - Choisir la meilleure solution
   - Exemple : "Vous devez déployer une application sur tous les nœuds..."

3. **Questions de troubleshooting**
   - Identifier la cause du problème
   - Proposer une solution
   - Exemple : "Un conteneur ne peut pas résoudre les noms DNS..."

4. **Questions de concepts**
   - Comprendre l'architecture Docker
   - Connaître les différences entre options
   - Exemple : "Différence entre CMD et ENTRYPOINT ?"

### Erreurs communes à éviter

❌ Confondre `docker compose` et `docker stack`
❌ Oublier que Swarm mode utilise des services, pas des conteneurs
❌ Confondre les drivers réseau et leurs cas d'usage
❌ Ne pas connaître l'emplacement des secrets (`/run/secrets/`)
❌ Confondre `docker save/load` avec `docker export/import`
❌ Oublier les flags importants comme `--mount` vs `-v`

---

## 🎯 Checklist finale avant l'examen

### Commandes à maîtriser absolument

```bash
# CONTAINER
docker run/start/stop/restart/rm/exec/logs/inspect/stats/top

# IMAGE
docker build/pull/push/tag/save/load/history/inspect/prune

# NETWORK
docker network create/ls/inspect/rm/connect/disconnect

# VOLUME
docker volume create/ls/inspect/rm/prune

# SWARM
docker swarm init/join/leave/update/unlock
docker node ls/inspect/update/promote/demote/rm
docker service create/ls/inspect/update/scale/rollback/rm
docker stack deploy/ls/ps/rm/services

# SECRET & CONFIG
docker secret create/ls/inspect/rm
docker config create/ls/inspect/rm

# SYSTEM
docker info/version/events/system df/system prune
```

### Concepts clés

- [ ] Architecture Docker (daemon, client, registry)
- [ ] Namespaces et cgroups
- [ ] Union File System et layers
- [ ] Copy-on-Write (CoW)
- [ ] Différence entre image et conteneur
- [ ] Cycle de vie d'un conteneur
- [ ] Swarm architecture (managers, workers, raft consensus)
- [ ] Routing mesh et ingress network
- [ ] Service discovery dans Swarm
- [ ] Différents types de volumes
- [ ] Tous les drivers réseau
- [ ] Storage drivers et leurs différences
- [ ] Logging drivers
- [ ] Capabilities Linux
- [ ] Docker Content Trust
- [ ] Multi-stage builds

### Fichiers de configuration importants

```bash
/etc/docker/daemon.json              # Configuration du daemon
/lib/systemd/system/docker.service   # Service systemd
~/.docker/config.json                # Config client (registries, etc.)
/run/secrets/                        # Secrets dans conteneurs Swarm
```

---

## 📊 Auto-évaluation

Avant de passer l'examen, assurez-vous de pouvoir faire les tâches suivantes **sans documentation** :

### Orchestration ⭐⭐⭐⭐⭐ (25%)
- [ ] Initialiser un swarm à 3 managers
- [ ] Ajouter/retirer des workers
- [ ] Créer un service avec 5 réplicas
- [ ] Scaler un service de 5 à 10 réplicas
- [ ] Faire un rolling update d'un service
- [ ] Faire un rollback après update raté
- [ ] Déployer un stack avec docker-compose.yml
- [ ] Créer et utiliser des secrets
- [ ] Créer et utiliser des configs
- [ ] Drainer un nœud et le réactiver
- [ ] Promouvoir/rétrograder un nœud
- [ ] Verrouiller/déverrouiller un swarm

### Images ⭐⭐⭐⭐⭐ (20%)
- [ ] Écrire un Dockerfile avec multi-stage build
- [ ] Builder une image avec tag
- [ ] Lister les layers d'une image
- [ ] Pousser une image vers un registry
- [ ] Tirer une image depuis un registry privé
- [ ] Créer une image à partir d'un conteneur (commit)
- [ ] Sauvegarder/charger une image (save/load)
- [ ] Exporter/importer un conteneur (export/import)
- [ ] Taguer une image
- [ ] Supprimer les images non utilisées

### Installation & Config ⭐⭐⭐⭐ (15%)
- [ ] Installer Docker sur Ubuntu/CentOS
- [ ] Configurer le daemon via daemon.json
- [ ] Changer le logging driver
- [ ] Configurer le storage driver
- [ ] Activer live-restore
- [ ] Configurer le démarrage auto des conteneurs
- [ ] Utiliser labels pour organiser les ressources
- [ ] Comprendre et modifier systemd service

### Networking ⭐⭐⭐⭐⭐ (15%)
- [ ] Créer un réseau bridge custom
- [ ] Créer un réseau overlay
- [ ] Créer un réseau macvlan
- [ ] Connecter/déconnecter un conteneur d'un réseau
- [ ] Publier des ports (-p)
- [ ] Exposer des ports (EXPOSE + -P)
- [ ] Comprendre le DNS dans Docker
- [ ] Déboguer des problèmes réseau

### Sécurité ⭐⭐⭐⭐⭐ (15%)
- [ ] Créer et utiliser des secrets Swarm
- [ ] Utiliser des configs Swarm
- [ ] Dropper toutes les capabilities et en ajouter une
- [ ] Exécuter un conteneur en read-only
- [ ] Activer Docker Content Trust
- [ ] Scanner une image pour les vulnérabilités
- [ ] Utiliser un utilisateur non-root dans Dockerfile
- [ ] Configurer AppArmor/SELinux

### Storage ⭐⭐⭐⭐ (10%)
- [ ] Créer un volume nommé
- [ ] Utiliser un bind mount
- [ ] Utiliser tmpfs
- [ ] Monter un volume dans un conteneur
- [ ] Backup/restore un volume
- [ ] Comprendre les différents storage drivers
- [ ] Lister et supprimer les volumes non utilisés

---

## 🏆 Certification obtenue - Et après ?

### Maintenir vos compétences

1. **Continuer la pratique**
   - Utilisez Docker quotidiennement
   - Expérimentez avec de nouveaux use cases
   - Contribuez à des projets open source

2. **Rester à jour**
   - Suivez le [Docker Blog](https://www.docker.com/blog/)
   - Regardez les Docker releases notes
   - Participez aux Docker Community events

3. **Progresser**
   - Apprendre Kubernetes (CKA, CKAD, CKS)
   - Explorer les plateformes cloud (AWS ECS, GCP Cloud Run, Azure Container Instances)
   - Se spécialiser (sécurité, performance, architecture)

### Valoriser votre certification

- ✅ Ajoutez le badge à votre profil LinkedIn
- ✅ Mentionnez-la sur votre CV
- ✅ Partagez votre réussite sur les réseaux sociaux
- ✅ Envisagez des certifications complémentaires (Kubernetes, Cloud)

### Renouvellement

- La certification DCA est valide **2 ans**
- Vous devrez repasser l'examen pour renouveler
- Les technologies évoluent : restez à jour !

---

## 📞 Support et Questions

### Besoin d'aide ?

- 💬 **GitHub Issues** : [Ouvrir une issue](../../issues)
- 💬 **Docker Forums** : [forums.docker.com](https://forums.docker.com/)
- 💬 **Stack Overflow** : Tag `docker`
- 💬 **Reddit** : [r/docker](https://www.reddit.com/r/docker/)

### Contact pour l'examen

- 📧 Support Mirantis Training : [training@mirantis.com](mailto:training@mirantis.com)
- 🌐 Page officielle : [training.mirantis.com/dca-certification-exam](https://training.mirantis.com/dca-certification-exam/)

---

## 🎓 Conclusion

La certification Docker DCA est un excellent moyen de valider vos compétences Docker et de progresser dans votre carrière DevOps/Cloud. Ce programme de 12 semaines, combiné aux TPs pratiques de ce repository, vous donnera toutes les connaissances nécessaires pour réussir l'examen.

**Clés du succès :**
1. ✅ Pratiquer, pratiquer, pratiquer (80% pratique, 20% théorie)
2. ✅ Faire tous les TPs de ce repository
3. ✅ Comprendre les concepts, pas juste mémoriser
4. ✅ Faire plusieurs examens blancs
5. ✅ Gérer votre temps pendant l'examen
6. ✅ Rester calme et confiant

**Bonne préparation et bon courage pour votre certification DCA ! 🐳🎯**

---

*Dernière mise à jour : Décembre 2025*
*Version du programme : 2.0*

**Changements majeurs en 2025 :**
- ✅ UCP renommé en MKE (Mirantis Kubernetes Engine)
- ✅ DTR renommé en MSR (Mirantis Secure Registry)
- ✅ AUFS et DeviceMapper complètement dépréciés
- ✅ Overlay2 comme storage driver standard
- ✅ Support Swarm garanti jusqu'en 2030 par Mirantis
