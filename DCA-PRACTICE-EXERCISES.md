# Exercices Pratiques pour la Certification DCA

Ce document contient des exercices pratiques organisés par domaine pour vous préparer à l'examen Docker Certified Associate (DCA).

---

## 📋 Table des matières

1. [Orchestration - Exercices](#orchestration---exercices)
2. [Images et Registry - Exercices](#images-et-registry---exercices)
3. [Networking - Exercices](#networking---exercices)
4. [Storage - Exercices](#storage---exercices)
5. [Sécurité - Exercices](#sécurité---exercices)
6. [Installation et Configuration - Exercices](#installation-et-configuration---exercices)
7. [Scénarios de troubleshooting](#scénarios-de-troubleshooting)
8. [Mini-projets intégrés](#mini-projets-intégrés)

---

## 🎯 Orchestration - Exercices

### Exercice 1 : Créer un cluster Swarm complet

**Objectif :** Initialiser un cluster Swarm avec 3 managers et 2 workers

**Instructions :**

```bash
# Sur le premier manager
docker swarm init --advertise-addr <IP_MANAGER_1>

# Récupérer les tokens
docker swarm join-token manager
docker swarm join-token worker

# Sur les autres managers (2 autres machines)
docker swarm join --token <MANAGER_TOKEN> <IP_MANAGER_1>:2377

# Sur les workers (2 machines)
docker swarm join --token <WORKER_TOKEN> <IP_MANAGER_1>:2377

# Vérifier le cluster
docker node ls
```

**Critères de validation :**
- [ ] 3 nœuds avec le rôle "Manager"
- [ ] 2 nœuds avec le rôle "Worker"
- [ ] 1 nœud avec le statut "Leader"
- [ ] Tous les nœuds sont "Ready" et "Active"

---

### Exercice 2 : Déployer un service web avec scaling

**Objectif :** Déployer un service nginx et le scaler

**Instructions :**

```bash
# Créer le service avec 3 réplicas
docker service create \
  --name web \
  --replicas 3 \
  --publish published=8080,target=80 \
  --constraint 'node.role==worker' \
  nginx:alpine

# Vérifier le service
docker service ls
docker service ps web

# Scaler à 5 réplicas
docker service scale web=5

# Vérifier la distribution
docker service ps web

# Obtenir les logs
docker service logs web
```

**Critères de validation :**
- [ ] Service "web" existe avec 5 réplicas
- [ ] Réplicas distribués sur les workers uniquement
- [ ] Port 8080 accessible depuis n'importe quel nœud
- [ ] `curl localhost:8080` retourne la page nginx

**Questions :**
1. Que se passe-t-il si vous accédez au port 8080 sur un manager ?
2. Comment le routing mesh fonctionne-t-il ?

---

### Exercice 3 : Rolling update avec rollback

**Objectif :** Mettre à jour un service avec stratégie et effectuer un rollback

**Instructions :**

```bash
# Créer un service avec version initiale
docker service create \
  --name myapp \
  --replicas 6 \
  --update-delay 10s \
  --update-parallelism 2 \
  --update-failure-action rollback \
  nginx:1.20-alpine

# Mettre à jour vers une nouvelle version
docker service update \
  --image nginx:1.21-alpine \
  myapp

# Observer le rolling update
watch docker service ps myapp

# En cas de problème, rollback manuel
docker service update --rollback myapp

# Ou automatique si échec détecté
docker service update \
  --update-failure-action rollback \
  --image nginx:broken \
  myapp
```

**Critères de validation :**
- [ ] Update se fait 2 conteneurs à la fois
- [ ] Délai de 10s entre chaque batch
- [ ] Rollback automatique en cas d'échec
- [ ] Service reste disponible pendant l'update

**Challenge :**
Configurez une update qui :
- Met à jour 1 conteneur à la fois
- Attend 5 secondes entre chaque
- Rollback automatiquement après 2 échecs
- Effectue un health check avant de continuer

<details>
<summary>Solution du challenge</summary>

```bash
docker service update \
  --update-parallelism 1 \
  --update-delay 5s \
  --update-failure-action rollback \
  --update-max-failure-ratio 0.33 \
  --health-cmd "curl -f http://localhost/ || exit 1" \
  --health-interval 10s \
  --health-retries 3 \
  --image nginx:1.22-alpine \
  myapp
```
</details>

---

### Exercice 4 : Secrets et Configs

**Objectif :** Utiliser secrets et configs dans un service

**Instructions :**

```bash
# Créer un secret
echo "SuperSecretPassword123" | docker secret create db_password -

# Créer un config
cat > nginx.conf <<EOF
server {
    listen 80;
    server_name example.com;
    location / {
        return 200 "Hello from config!";
    }
}
EOF
docker config create nginx_config nginx.conf

# Créer un service utilisant le secret
docker service create \
  --name db \
  --secret db_password \
  --env POSTGRES_PASSWORD_FILE=/run/secrets/db_password \
  postgres:alpine

# Créer un service utilisant le config
docker service create \
  --name web \
  --config source=nginx_config,target=/etc/nginx/conf.d/default.conf \
  --publish 80:80 \
  nginx:alpine

# Vérifier
docker exec $(docker ps -q -f name=db) cat /run/secrets/db_password
curl localhost:80
```

**Critères de validation :**
- [ ] Secret "db_password" existe
- [ ] Config "nginx_config" existe
- [ ] Secret accessible dans `/run/secrets/` du conteneur db
- [ ] Config injecté dans le conteneur web
- [ ] `curl localhost:80` retourne "Hello from config!"

**Challenge :**
Créez un stack complet (compose file) avec :
- Un service web utilisant un config pour nginx
- Un service API utilisant un secret pour une API key
- Un service database utilisant un secret pour le mot de passe

---

### Exercice 5 : Déployer un stack complet

**Objectif :** Déployer une application multi-tier avec Docker Stack

**Instructions :**

Créez un fichier `voting-stack.yml` :

```yaml
version: '3.8'

services:
  vote:
    image: dockersamples/examplevotingapp_vote:before
    ports:
      - "5000:80"
    networks:
      - frontend
    deploy:
      replicas: 2
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure

  redis:
    image: redis:alpine
    networks:
      - frontend
    deploy:
      placement:
        constraints:
          - node.role==manager

  worker:
    image: dockersamples/examplevotingapp_worker
    networks:
      - frontend
      - backend
    deploy:
      mode: replicated
      replicas: 1
      restart_policy:
        condition: on-failure
        delay: 10s
        max_attempts: 3

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - backend
    deploy:
      placement:
        constraints:
          - node.role==manager

  result:
    image: dockersamples/examplevotingapp_result:before
    ports:
      - "5001:80"
    networks:
      - backend
    deploy:
      replicas: 1
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure

networks:
  frontend:
    driver: overlay
  backend:
    driver: overlay

volumes:
  db-data:
```

Déployez le stack :

```bash
# Déployer le stack
docker stack deploy -c voting-stack.yml voting

# Vérifier le déploiement
docker stack ls
docker stack services voting
docker stack ps voting

# Accéder à l'application
# Vote interface: http://<any-node>:5000
# Results interface: http://<any-node>:5001

# Scaler le service vote
docker service scale voting_vote=5

# Voir les logs d'un service
docker service logs voting_vote

# Supprimer le stack
docker stack rm voting
```

**Critères de validation :**
- [ ] Tous les services sont démarrés (5/5)
- [ ] Vote accessible sur le port 5000
- [ ] Result accessible sur le port 5001
- [ ] Votes sont enregistrés et visibles dans Results
- [ ] Database et Redis sur les managers uniquement

---

### Exercice 6 : Maintenance d'un nœud

**Objectif :** Mettre un nœud en maintenance sans downtime

**Instructions :**

```bash
# Vérifier l'état actuel
docker node ls
docker service ps web

# Drainer un nœud (déplace les tâches)
docker node update --availability drain worker1

# Vérifier que les tâches ont migré
docker service ps web

# Faire la maintenance (ex: upgrade du système)
# ...

# Réactiver le nœud
docker node update --availability active worker1

# Le nœud peut maintenant recevoir de nouvelles tâches
# Pour forcer la redistribution:
docker service update --force web
```

**Critères de validation :**
- [ ] Aucune tâche ne s'exécute sur le nœud drainé
- [ ] Service reste disponible pendant le drain
- [ ] Tâches redémarrées sur d'autres nœuds
- [ ] Nœud réactivé peut recevoir de nouvelles tâches

---

### Exercice 7 : Lock et Unlock du Swarm

**Objectif :** Sécuriser le cluster avec autolock

**Instructions :**

```bash
# Activer l'autolock
docker swarm update --autolock=true

# Sauvegarder la clé de déverrouillage affichée !
# SWMKEY-1-xxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Simuler un redémarrage du daemon
sudo systemctl restart docker

# Vérifier l'état
docker node ls
# Erreur: Swarm is encrypted and needs to be unlocked

# Déverrouiller
docker swarm unlock
# Entrer la clé

# Récupérer la clé (si perdue, depuis un autre manager)
docker swarm unlock-key

# Désactiver l'autolock
docker swarm update --autolock=false
```

**Critères de validation :**
- [ ] Autolock activé avec succès
- [ ] Clé de déverrouillage sauvegardée
- [ ] Après restart, swarm est verrouillé
- [ ] Déverrouillage réussi avec la clé

---

## 🖼️ Images et Registry - Exercices

### Exercice 1 : Multi-stage build optimisé

**Objectif :** Créer une image optimisée pour une application Node.js

**Instructions :**

Créez une application Node.js simple :

```bash
mkdir myapp && cd myapp

# package.json
cat > package.json <<EOF
{
  "name": "myapp",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

# app.js
cat > app.js <<EOF
const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('Hello from optimized Docker image!');
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
EOF
```

Créez un Dockerfile multi-stage optimisé :

```dockerfile
# Dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:20-alpine
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001
WORKDIR /app
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs . .
USER nodejs
EXPOSE 3000
CMD ["node", "app.js"]
```

```bash
# Builder l'image
docker build -t myapp:optimized .

# Comparer avec une version non-optimisée
docker build -t myapp:unoptimized -f - . <<EOF
FROM node:20
WORKDIR /app
COPY . .
RUN npm install
EXPOSE 3000
CMD ["node", "app.js"]
EOF

# Comparer les tailles
docker images | grep myapp

# Analyser les layers
docker history myapp:optimized
docker history myapp:unoptimized

# Tester
docker run -d -p 3000:3000 myapp:optimized
curl localhost:3000
```

**Critères de validation :**
- [ ] Image optimisée < 150MB
- [ ] Image non-optimisée > 900MB
- [ ] Application fonctionne correctement
- [ ] Utilise un utilisateur non-root
- [ ] Moins de layers dans la version optimisée

**Challenge :**
Optimisez encore plus en :
- Utilisant `node:20-alpine` comme base
- Supprimant les fichiers inutiles (.git, tests, etc.)
- Utilisant `.dockerignore`

---

### Exercice 2 : Registry privé avec authentification

**Objectif :** Déployer un registry privé sécurisé

**Instructions :**

```bash
# Créer un répertoire pour le registry
mkdir -p ~/registry/{auth,certs,data}

# Générer un certificat auto-signé
openssl req -newkey rsa:4096 -nodes -sha256 \
  -keyout ~/registry/certs/domain.key \
  -x509 -days 365 \
  -out ~/registry/certs/domain.crt \
  -subj "/CN=myregistry.local"

# Créer un fichier htpasswd pour l'authentification
docker run --rm --entrypoint htpasswd httpd:2 \
  -Bbn admin admin123 > ~/registry/auth/htpasswd

# Déployer le registry
docker run -d \
  --name registry \
  --restart=always \
  -v ~/registry/data:/var/lib/registry \
  -v ~/registry/auth:/auth \
  -v ~/registry/certs:/certs \
  -e REGISTRY_AUTH=htpasswd \
  -e REGISTRY_AUTH_HTPASSWD_REALM="Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  -p 5000:5000 \
  registry:2

# Ajouter le certificat aux certificats de confiance
sudo mkdir -p /etc/docker/certs.d/myregistry.local:5000
sudo cp ~/registry/certs/domain.crt \
  /etc/docker/certs.d/myregistry.local:5000/ca.crt

# Ajouter myregistry.local au /etc/hosts
echo "127.0.0.1 myregistry.local" | sudo tee -a /etc/hosts

# Se connecter au registry
docker login myregistry.local:5000
# Username: admin
# Password: admin123

# Pousser une image
docker tag nginx:alpine myregistry.local:5000/nginx:v1
docker push myregistry.local:5000/nginx:v1

# Lister les images
curl -u admin:admin123 https://myregistry.local:5000/v2/_catalog
curl -u admin:admin123 https://myregistry.local:5000/v2/nginx/tags/list

# Tirer l'image
docker pull myregistry.local:5000/nginx:v1
```

**Critères de validation :**
- [ ] Registry accessible uniquement avec authentification
- [ ] TLS configuré correctement
- [ ] Push d'image réussie
- [ ] Pull d'image réussie
- [ ] Catalogue listable via API

---

### Exercice 3 : Docker Content Trust

**Objectif :** Signer et vérifier des images

**Instructions :**

```bash
# Activer Docker Content Trust
export DOCKER_CONTENT_TRUST=1

# Créer une image de test
cat > Dockerfile <<EOF
FROM alpine:latest
CMD ["echo", "Signed image!"]
EOF

docker build -t myregistry.local:5000/signed-app:v1 .

# Pousser l'image (signature automatique)
docker push myregistry.local:5000/signed-app:v1
# Vous devrez créer une passphrase pour root et repository keys

# Lister les signatures
docker trust inspect myregistry.local:5000/signed-app:v1

# Tenter de pull une image non signée (échouera)
export DOCKER_CONTENT_TRUST=1
docker pull some-unsigned-image

# Désactiver temporairement pour tester
export DOCKER_CONTENT_TRUST=0
docker pull some-unsigned-image  # Réussit

# Réactiver
export DOCKER_CONTENT_TRUST=1

# Révoquer une signature
docker trust revoke myregistry.local:5000/signed-app:v1
```

**Critères de validation :**
- [ ] Image signée avec succès
- [ ] Pull d'image non signée échoue avec DCT=1
- [ ] Pull d'image signée réussit avec DCT=1
- [ ] Signature visible via `docker trust inspect`

---

## 🌐 Networking - Exercices

### Exercice 1 : Tous les types de réseaux

**Objectif :** Créer et tester tous les drivers réseau

**Instructions :**

```bash
# 1. Bridge network (custom)
docker network create --driver bridge my-bridge

docker run -dit --name box1 --network my-bridge alpine
docker run -dit --name box2 --network my-bridge alpine

# Tester la connectivité
docker exec box1 ping box2  # Fonctionne (DNS)
docker exec box1 ping -c 3 box2

# 2. Host network
docker run -dit --name host-box --network host alpine
docker exec host-box ip addr  # Même IPs que l'hôte

# 3. None network
docker run -dit --name isolated-box --network none alpine
docker exec isolated-box ip addr  # Seulement loopback

# 4. Overlay network (nécessite Swarm)
docker network create --driver overlay --attachable my-overlay

docker service create --name svc1 \
  --network my-overlay \
  alpine sleep 3600

docker run -dit --name overlay-box \
  --network my-overlay \
  alpine

# 5. Macvlan network
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  -o parent=eth0 \
  my-macvlan

docker run -dit --name macvlan-box \
  --network my-macvlan \
  --ip 192.168.1.100 \
  alpine

# Inspecter tous les réseaux
docker network ls
docker network inspect my-bridge
```

**Critères de validation :**
- [ ] Bridge custom : conteneurs peuvent se ping par nom
- [ ] Host : conteneur a les mêmes IPs que l'hôte
- [ ] None : conteneur n'a que loopback
- [ ] Overlay : service discovery fonctionne
- [ ] Macvlan : conteneur a une IP du réseau physique

---

### Exercice 2 : Service multi-réseau

**Objectif :** Créer une architecture 3-tier avec isolation réseau

**Instructions :**

```bash
# Créer 3 réseaux
docker network create frontend
docker network create backend
docker network create database

# Nginx (frontend only)
docker run -d --name nginx \
  --network frontend \
  -p 80:80 \
  nginx:alpine

# API (frontend + backend)
docker run -d --name api \
  --network frontend \
  alpine sleep 3600

docker network connect backend api

# Database (backend only)
docker run -d --name db \
  --network backend \
  -e POSTGRES_PASSWORD=secret \
  postgres:alpine

# Worker (backend + database)
docker run -d --name worker \
  --network backend \
  alpine sleep 3600

docker network connect database worker

# Tests de connectivité
docker exec nginx ping api     # ✓ Fonctionne
docker exec nginx ping db      # ✗ Échoue (pas de route)
docker exec api ping db        # ✓ Fonctionne
docker exec worker ping db     # ✓ Fonctionne
docker exec db ping nginx      # ✗ Échoue

# Visualiser les connexions
docker inspect nginx | jq '.[0].NetworkSettings.Networks'
docker inspect api | jq '.[0].NetworkSettings.Networks'
```

**Critères de validation :**
- [ ] nginx ne peut communiquer qu'avec api
- [ ] api peut communiquer avec nginx et db
- [ ] db n'est accessible que depuis backend
- [ ] Isolation réseau effective

**Architecture :**
```
[Users] ─── HTTP ──→ [Nginx:80] ────┐
                     (frontend)      │
                                     ▼
                                  [API]
                                (frontend + backend)
                                     │
                                     ▼
                                   [DB]
                                 (backend)
                                     ▲
                                     │
                                 [Worker]
                              (backend + database)
```

---

### Exercice 3 : Load balancing et service discovery

**Objectif :** Comprendre le routing mesh de Swarm

**Instructions :**

```bash
# Créer un service avec 3 réplicas
docker service create --name web \
  --replicas 3 \
  --publish published=8080,target=80 \
  nginx:alpine

# Vérifier la distribution
docker service ps web

# Tester le load balancing
for i in {1..10}; do
  curl -s localhost:8080 | grep "hostname"
done

# Personnaliser nginx pour voir le hostname
docker service update \
  --env-add HOSTNAME='{{.Task.Name}}' \
  web

# Chaque requête peut aller vers un conteneur différent

# Tester depuis tous les nœuds
# Le port 8080 fonctionne sur TOUS les nœuds (routing mesh)

# Créer un réseau overlay pour service discovery
docker network create --driver overlay my-app

docker service create --name backend \
  --network my-app \
  --replicas 2 \
  alpine sleep 3600

docker service create --name frontend \
  --network my-app \
  alpine sleep 3600

# Tester le DNS
docker exec $(docker ps -q -f name=frontend) nslookup backend
docker exec $(docker ps -q -f name=frontend) ping backend
```

**Critères de validation :**
- [ ] Port 8080 accessible depuis n'importe quel nœud
- [ ] Requêtes distribuées entre les réplicas
- [ ] Service discovery fonctionne (ping par nom)
- [ ] DNS round-robin pour les réplicas

---

## 💾 Storage - Exercices

### Exercice 1 : Volumes vs Bind Mounts vs tmpfs

**Objectif :** Comprendre les différences et cas d'usage

**Instructions :**

```bash
# 1. Volume Docker
docker volume create mydata

docker run -d --name vol-test \
  -v mydata:/data \
  alpine sh -c "echo 'Hello from volume' > /data/test.txt && sleep 3600"

# Vérifier
docker exec vol-test cat /data/test.txt

# Localiser le volume sur l'hôte
docker volume inspect mydata | jq '.[0].Mountpoint'
sudo cat /var/lib/docker/volumes/mydata/_data/test.txt

# 2. Bind Mount
mkdir ~/mydata
echo "Hello from bind mount" > ~/mydata/test.txt

docker run -d --name bind-test \
  -v ~/mydata:/data \
  alpine sleep 3600

# Modifications visibles immédiatement
echo "Updated!" >> ~/mydata/test.txt
docker exec bind-test cat /data/test.txt

# 3. tmpfs (données en RAM)
docker run -d --name tmpfs-test \
  --tmpfs /cache:rw,size=100m \
  alpine sh -c "echo 'Temporary data' > /cache/temp.txt && sleep 3600"

docker exec tmpfs-test cat /cache/temp.txt

# Les données tmpfs disparaissent à l'arrêt du conteneur
docker stop tmpfs-test
docker start tmpfs-test
docker exec tmpfs-test ls /cache  # Vide !

# Comparer les performances
docker run --rm \
  -v mydata:/data \
  alpine sh -c "dd if=/dev/zero of=/data/test bs=1M count=100"

docker run --rm \
  --tmpfs /data:rw,size=200m \
  alpine sh -c "dd if=/dev/zero of=/data/test bs=1M count=100"
```

**Critères de validation :**
- [ ] Volume persist après suppression du conteneur
- [ ] Bind mount reflète les changements de l'hôte
- [ ] tmpfs perd les données après restart
- [ ] tmpfs plus rapide que volume

**Cas d'usage :**
- **Volume** : Données de production, databases, uploads
- **Bind mount** : Code source en dev, config files
- **tmpfs** : Sessions, cache temporaire, données sensibles

---

### Exercice 2 : Backup et restore de volumes

**Objectif :** Sauvegarder et restaurer des données

**Instructions :**

```bash
# Créer un volume avec des données
docker volume create important-data

docker run --rm -v important-data:/data alpine \
  sh -c "echo 'Critical data' > /data/file1.txt && \
         echo 'Important info' > /data/file2.txt && \
         mkdir /data/subdir && \
         echo 'Nested data' > /data/subdir/file3.txt"

# Backup du volume
docker run --rm \
  -v important-data:/source:ro \
  -v $(pwd):/backup \
  alpine \
  tar czf /backup/important-data-backup.tar.gz -C /source .

# Vérifier le backup
tar tzf important-data-backup.tar.gz

# Supprimer le volume original
docker volume rm important-data

# Créer un nouveau volume
docker volume create important-data-restored

# Restore
docker run --rm \
  -v important-data-restored:/target \
  -v $(pwd):/backup \
  alpine \
  tar xzf /backup/important-data-backup.tar.gz -C /target

# Vérifier la restoration
docker run --rm \
  -v important-data-restored:/data \
  alpine \
  ls -la /data
```

**Critères de validation :**
- [ ] Backup créé avec succès
- [ ] Archive contient tous les fichiers
- [ ] Restore récupère toutes les données
- [ ] Permissions préservées

**Challenge :**
Créez un script `backup-volume.sh` qui :
- Accepte un nom de volume en argument
- Crée un backup horodaté
- Compresse avec gzip
- Stocke dans un répertoire de backup

---

### Exercice 3 : Partage de volumes entre conteneurs

**Objectif :** Partager des données entre plusieurs conteneurs

**Instructions :**

```bash
# Créer un volume partagé
docker volume create shared-data

# Conteneur 1 : Writer
docker run -d --name writer \
  -v shared-data:/data \
  alpine \
  sh -c "while true; do date >> /data/log.txt; sleep 5; done"

# Conteneur 2 : Reader
docker run -d --name reader \
  -v shared-data:/data:ro \
  alpine \
  sh -c "while true; do tail -n 1 /data/log.txt; sleep 2; done"

# Conteneur 3 : Processor
docker run -d --name processor \
  -v shared-data:/data \
  alpine \
  sh -c "while true; do wc -l /data/log.txt; sleep 10; done"

# Observer les logs
docker logs -f writer &
docker logs -f reader &
docker logs -f processor &

# Vérifier que les données sont partagées
docker exec reader cat /data/log.txt
docker exec processor wc -l /data/log.txt

# Test du read-only
docker exec reader sh -c "echo 'test' > /data/readonly-test.txt"
# Erreur: Read-only file system
```

**Critères de validation :**
- [ ] Tous les conteneurs accèdent au même volume
- [ ] Writer écrit des données
- [ ] Reader peut lire mais pas écrire (ro)
- [ ] Processor peut traiter les données

---

## 🔒 Sécurité - Exercices

### Exercice 1 : Capabilities Linux

**Objectif :** Maîtriser les capabilities

**Instructions :**

```bash
# Par défaut, Docker donne certaines capabilities
docker run --rm alpine sh -c "apk add -q libcap && capsh --print"

# Retirer TOUTES les capabilities
docker run --rm --cap-drop ALL alpine sh -c "apk add -q libcap && capsh --print"

# Essayer de ping (nécessite CAP_NET_RAW)
docker run --rm --cap-drop ALL alpine ping -c 1 8.8.8.8
# Échoue !

# Ajouter seulement NET_RAW
docker run --rm --cap-drop ALL --cap-add NET_RAW alpine ping -c 1 8.8.8.8
# Fonctionne !

# Tester NET_BIND_SERVICE (bind sur port < 1024)
docker run --rm --cap-drop ALL alpine \
  sh -c "nc -l -p 80"
# Échoue

docker run --rm --cap-drop ALL --cap-add NET_BIND_SERVICE alpine \
  sh -c "timeout 5 nc -l -p 80 || true"
# Fonctionne

# Mode privileged (TOUTES les capabilities - DANGEREUX)
docker run --rm --privileged alpine sh -c "apk add -q libcap && capsh --print"
```

**Critères de validation :**
- [ ] Comprendre quelles capabilities sont nécessaires
- [ ] Appliquer le principe du moindre privilège
- [ ] Savoir retirer toutes les caps et n'ajouter que nécessaires

**Capabilities communes :**
- `NET_BIND_SERVICE` : Bind ports < 1024
- `NET_RAW` : Utiliser RAW et PACKET sockets (ping)
- `SYS_ADMIN` : Admin diverses opérations système
- `CHOWN` : Changer ownership de fichiers

---

### Exercice 2 : User namespaces et non-root

**Objectif :** Exécuter des conteneurs en tant qu'utilisateur non-root

**Instructions :**

```bash
# Par défaut, beaucoup d'images run en root
docker run --rm alpine id
# uid=0(root) gid=0(root)

# Spécifier un user:group
docker run --rm --user 1000:1000 alpine id
# uid=1000 gid=1000

# Créer un Dockerfile avec utilisateur non-root
cat > Dockerfile <<EOF
FROM alpine:latest
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup
USER appuser
CMD ["id"]
EOF

docker build -t nonroot-app .
docker run --rm nonroot-app
# uid=1001(appuser) gid=1001(appgroup)

# Tester les permissions
docker run --rm --user 1000:1000 \
  -v $(pwd):/data \
  alpine sh -c "touch /data/testfile"

ls -la testfile
# Le fichier appartient à l'user 1000

# Read-only filesystem
docker run --rm --read-only alpine \
  sh -c "echo 'test' > /tmp/file"
# Erreur: Read-only file system

# Avec tmpfs pour /tmp
docker run --rm --read-only --tmpfs /tmp alpine \
  sh -c "echo 'test' > /tmp/file && cat /tmp/file"
# Fonctionne !
```

**Critères de validation :**
- [ ] Savoir créer un user dans Dockerfile
- [ ] Comprendre l'impact sur les permissions de fichiers
- [ ] Combiner user non-root avec read-only filesystem

**Best practices :**
1. Toujours créer un user dédié dans Dockerfile
2. Ne jamais run en root en production
3. Utiliser `--read-only` quand possible
4. Monter `/tmp` en tmpfs si nécessaire

---

### Exercice 3 : Scanning de vulnérabilités

**Objectif :** Scanner des images avec Trivy

**Instructions :**

```bash
# Installer Trivy (ou utiliser via Docker)
docker pull aquasec/trivy

# Scanner une image
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image nginx:latest

# Scanner avec filtre de sévérité
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image --severity HIGH,CRITICAL nginx:latest

# Scanner une image locale
docker build -t myapp:test .

docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image myapp:test

# Format JSON pour automatisation
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image --format json -o results.json nginx:latest

# Scanner avec exit code (pour CI/CD)
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image --exit-code 1 --severity CRITICAL nginx:latest
# Exit code 1 si des vulnérabilités CRITICAL trouvées

# Comparer différentes versions
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image node:18

docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image node:20
```

**Critères de validation :**
- [ ] Scanner réussit
- [ ] Comprendre le rapport de vulnerabilités
- [ ] Savoir filtrer par sévérité
- [ ] Utiliser en CI/CD avec exit codes

---

## ⚙️ Installation et Configuration - Exercices

### Exercice 1 : Configuration du daemon Docker

**Objectif :** Configurer le daemon avec daemon.json

**Instructions :**

```bash
# Créer/éditer /etc/docker/daemon.json
sudo tee /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3",
    "labels": "production"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ],
  "live-restore": true,
  "userland-proxy": false,
  "default-address-pools": [
    {
      "base": "172.17.0.0/16",
      "size": 24
    }
  ],
  "dns": ["8.8.8.8", "8.8.4.4"],
  "labels": ["environment=production", "region=us-west"]
}
EOF

# Valider la configuration
cat /etc/docker/daemon.json | jq .

# Recharger la configuration
sudo systemctl daemon-reload
sudo systemctl restart docker

# Vérifier la configuration
docker info

# Vérifier les labels
docker info | grep -A 5 Labels

# Vérifier le storage driver
docker info | grep "Storage Driver"

# Vérifier les logs
docker run -d --name test-logs alpine \
  sh -c "while true; do echo 'Log message'; sleep 1; done"

# Logs rotate automatiquement
docker inspect test-logs | jq '.[0].HostConfig.LogConfig'
```

**Critères de validation :**
- [ ] daemon.json valide (JSON correct)
- [ ] Docker redémarre sans erreur
- [ ] Configuration appliquée (`docker info`)
- [ ] Logs configurés correctement

**Paramètres importants :**
- `log-driver` : Type de logging (json-file, syslog, journald, etc.)
- `storage-driver` : Driver de storage (overlay2 recommandé)
- `live-restore` : Garder conteneurs running pendant restart du daemon
- `userland-proxy` : Désactiver pour meilleures performances
- `dns` : Serveurs DNS custom pour conteneurs

---

### Exercice 2 : Restart policies

**Objectif :** Maîtriser les politiques de redémarrage

**Instructions :**

```bash
# no (défaut) - Jamais redémarrer
docker run -d --name no-restart \
  --restart no \
  alpine sh -c "sleep 10 && exit 1"

# Attendre 15s
sleep 15
docker ps -a --filter name=no-restart
# Status: Exited

# on-failure - Redémarrer seulement si exit code != 0
docker run -d --name on-failure \
  --restart on-failure:3 \
  alpine sh -c "sleep 5 && exit 1"

# Observer les restarts
docker ps -a --filter name=on-failure
# Sera restarté 3 fois maximum

# always - Toujours redémarrer
docker run -d --name always-restart \
  --restart always \
  alpine sh -c "sleep 5 && exit 1"

# Même après stop manuel, restart au redémarrage du daemon
docker stop always-restart
sudo systemctl restart docker
docker ps  # always-restart est running !

# unless-stopped - Comme always sauf si stopped manuellement
docker run -d --name unless-stopped \
  --restart unless-stopped \
  alpine sh -c "sleep 5 && exit 1"

docker stop unless-stopped
sudo systemctl restart docker
docker ps -a --filter name=unless-stopped
# Reste stopped

# Vérifier la politique
docker inspect always-restart | jq '.[0].HostConfig.RestartPolicy'
```

**Critères de validation :**
- [ ] Comprendre les 4 politiques
- [ ] Savoir quand utiliser chacune
- [ ] `always` vs `unless-stopped`

**Usage recommandé :**
- `no` : Jobs one-time
- `on-failure` : Applications qui peuvent échouer temporairement
- `always` : Services critiques qui doivent toujours tourner
- `unless-stopped` : Services qu'on veut contrôler manuellement

---

## 🔧 Scénarios de troubleshooting

### Scénario 1 : Conteneur ne démarre pas

**Problème :**
```bash
docker run -d --name broken-app myapp:latest
# Conteneur s'arrête immédiatement
```

**Investigation :**

```bash
# 1. Vérifier le statut
docker ps -a --filter name=broken-app

# 2. Voir les logs
docker logs broken-app

# 3. Inspecter le conteneur
docker inspect broken-app | jq '.[0].State'

# 4. Vérifier l'exit code
docker inspect broken-app | jq '.[0].State.ExitCode'

# 5. Tester interactivement
docker run -it --rm myapp:latest sh

# 6. Override ENTRYPOINT pour débug
docker run -it --rm --entrypoint sh myapp:latest

# 7. Vérifier les dépendances
docker run -it --rm myapp:latest ldd /app/binary
```

**Solutions possibles :**
- CMD/ENTRYPOINT incorrect
- Dépendances manquantes
- Permissions insuffisantes
- Variables d'environnement manquantes

---

### Scénario 2 : Problème de résolution DNS

**Problème :**
```bash
docker exec myapp ping google.com
# ping: bad address 'google.com'
```

**Investigation :**

```bash
# 1. Vérifier les DNS du conteneur
docker exec myapp cat /etc/resolv.conf

# 2. Vérifier la config du daemon
docker info | grep DNS

# 3. Tester avec un DNS public
docker run --rm --dns 8.8.8.8 alpine ping -c 1 google.com

# 4. Vérifier le réseau
docker inspect myapp | jq '.[0].NetworkSettings'

# 5. Créer un réseau avec DNS custom
docker network create --dns 8.8.8.8 my-net
docker run --rm --network my-net alpine ping -c 1 google.com
```

**Solutions :**
- Configurer DNS dans daemon.json
- Utiliser `--dns` au runtime
- Vérifier les règles firewall

---

### Scénario 3 : Volume permissions

**Problème :**
```bash
docker run --rm -v /host/data:/data alpine sh -c "touch /data/file"
# touch: /data/file: Permission denied
```

**Investigation :**

```bash
# 1. Vérifier les permissions sur l'hôte
ls -la /host/data

# 2. Vérifier l'user du conteneur
docker run --rm alpine id

# 3. Vérifier l'ownership du volume
docker run --rm -v /host/data:/data alpine ls -la /data

# Solutions:
# A. Changer ownership sur l'hôte
sudo chown -R 1000:1000 /host/data

# B. Run en root (temporaire pour debug)
docker run --rm --user root -v /host/data:/data alpine touch /data/file

# C. Utiliser un volume Docker au lieu de bind mount
docker volume create mydata
docker run --rm -v mydata:/data alpine touch /data/file
```

---

## 🚀 Mini-projets intégrés

### Projet 1 : Application web complète avec monitoring

**Description :** Déployer une stack complète avec:
- Frontend (React)
- Backend API (Node.js)
- Database (PostgreSQL)
- Cache (Redis)
- Monitoring (Prometheus + Grafana)

**docker-compose.yml :**

```yaml
version: '3.8'

services:
  frontend:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./frontend/dist:/usr/share/nginx/html:ro
    networks:
      - frontend
    deploy:
      replicas: 2
      restart_policy:
        condition: on-failure

  api:
    build: ./backend
    environment:
      DATABASE_URL: postgresql://postgres:secret@db:5432/myapp
      REDIS_URL: redis://cache:6379
    networks:
      - frontend
      - backend
    deploy:
      replicas: 3
      restart_policy:
        condition: on-failure
    depends_on:
      - db
      - cache

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_PASSWORD: secret
      POSTGRES_DB: myapp
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - backend
    deploy:
      placement:
        constraints:
          - node.role==manager

  cache:
    image: redis:alpine
    networks:
      - backend

  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
    ports:
      - "9090:9090"
    networks:
      - monitoring

  grafana:
    image: grafana/grafana
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin
    ports:
      - "3000:3000"
    volumes:
      - grafana-data:/var/lib/grafana
    networks:
      - monitoring

networks:
  frontend:
    driver: overlay
  backend:
    driver: overlay
  monitoring:
    driver: overlay

volumes:
  postgres-data:
  prometheus-data:
  grafana-data:
```

**Tâches :**
1. Déployer le stack
2. Vérifier que tous les services communiquent
3. Scaler l'API à 5 réplicas
4. Faire un rolling update de l'API
5. Simuler une panne et vérifier le restart automatique
6. Configurer des alertes dans Prometheus
7. Créer un dashboard Grafana

---

### Projet 2 : CI/CD Pipeline complet

**Description :** Créer un pipeline qui :
1. Build l'image
2. Scan pour vulnérabilités
3. Run les tests
4. Push vers registry privé
5. Deploy vers Swarm

**GitHub Actions workflow :**

```yaml
name: Docker CI/CD

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Build image
        run: docker build -t myapp:${{ github.sha }} .

      - name: Scan for vulnerabilities
        run: |
          docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
            aquasec/trivy image --exit-code 1 --severity CRITICAL myapp:${{ github.sha }}

      - name: Run tests
        run: docker run --rm myapp:${{ github.sha }} npm test

      - name: Login to registry
        run: echo "${{ secrets.REGISTRY_PASSWORD }}" | docker login myregistry.com -u ${{ secrets.REGISTRY_USER }} --password-stdin

      - name: Tag and push
        run: |
          docker tag myapp:${{ github.sha }} myregistry.com/myapp:latest
          docker tag myapp:${{ github.sha }} myregistry.com/myapp:${{ github.sha }}
          docker push myregistry.com/myapp:latest
          docker push myregistry.com/myapp:${{ github.sha }}

  deploy:
    needs: build-and-test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Deploy to Swarm
        run: |
          docker stack deploy -c docker-stack.yml myapp
```

---

## ✅ Checklist complète de préparation

Avant de passer l'examen DCA, vérifiez que vous pouvez faire toutes ces tâches **sans documentation** :

### Orchestration
- [ ] Init un swarm et ajouter des nœuds
- [ ] Créer un service avec constraints
- [ ] Scaler un service
- [ ] Faire un rolling update
- [ ] Faire un rollback
- [ ] Déployer un stack
- [ ] Créer et utiliser secrets/configs
- [ ] Drainer et activer un nœud
- [ ] Lock/unlock un swarm

### Images
- [ ] Écrire un Dockerfile multi-stage
- [ ] Builder et taguer une image
- [ ] Push/pull vers registry
- [ ] Lister les layers
- [ ] Save/load une image
- [ ] Export/import un conteneur

### Networking
- [ ] Créer tous types de réseaux
- [ ] Connecter conteneurs à multiple networks
- [ ] Publier des ports
- [ ] Debug problèmes réseau

### Storage
- [ ] Créer et utiliser volumes
- [ ] Utiliser bind mounts
- [ ] Utiliser tmpfs
- [ ] Backup/restore volumes

### Sécurité
- [ ] Utiliser capabilities
- [ ] Run en non-root
- [ ] Créer et utiliser secrets
- [ ] Scanner images
- [ ] Activer Content Trust

### Installation
- [ ] Configurer daemon.json
- [ ] Configurer logging
- [ ] Configurer restart policies
- [ ] Utiliser labels

---

**Bonne pratique et bon courage pour la certification DCA ! 🐳🎯**
