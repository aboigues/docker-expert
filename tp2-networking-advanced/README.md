# TP2: Networking Avancé et Service Mesh

## 🎯 Objectifs

- Maîtriser les différents types de réseaux Docker (bridge, overlay, macvlan, host)
- Créer des architectures réseau complexes multi-conteneurs
- Implémenter un reverse proxy et load balancer avec Traefik
- Configurer le DNS personnalisé et la découverte de services
- Comprendre et résoudre les problèmes de networking

## 📚 Exercices

### Exercice 1: Networks Types et Isolation (⭐⭐⭐)

Créez une architecture réseau avec isolation:
- Réseau `frontend` pour les services web
- Réseau `backend` pour les bases de données
- Réseau `admin` pour les outils d'administration
- Services qui communiquent via plusieurs réseaux

**Critères:**
- ✅ 3 réseaux personnalisés créés
- ✅ Frontend ne peut pas accéder directement à la DB
- ✅ Service API connecté aux deux réseaux
- ✅ Résolution DNS fonctionne entre conteneurs

### Exercice 2: Overlay Network et Swarm (⭐⭐⭐⭐)

Configurez un réseau overlay pour communication multi-hôtes:
```bash
docker swarm init
docker network create --driver overlay my-overlay
docker service create --network my-overlay --replicas 3 app
```

**Critères:**
- ✅ Swarm mode initialisé
- ✅ Overlay network créé
- ✅ Services communiquent entre hôtes
- ✅ Load balancing fonctionne

### Exercice 3: Traefik Reverse Proxy et Load Balancer (⭐⭐⭐⭐⭐)

Déployez Traefik comme reverse proxy avec:
- Auto-découverte des services
- Load balancing automatique
- SSL/TLS avec Let's Encrypt
- Dashboard de monitoring
- Middlewares (authentication, rate limiting)

**docker-compose.yml:**
```yaml
version: '3.8'

services:
  traefik:
    image: traefik:v2.10
    command:
      - --api.dashboard=true
      - --providers.docker=true
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik.yml:/traefik.yml
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.dashboard.rule=Host(`traefik.localhost`)"

  app1:
    image: nginx
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.app1.rule=Host(`app1.localhost`)"
    deploy:
      replicas: 3

  app2:
    image: nginx
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.app2.rule=Host(`app2.localhost`)"
```

**Critères:**
- ✅ Traefik auto-découvre les services
- ✅ Load balancing entre réplicas
- ✅ Dashboard accessible
- ✅ SSL/TLS configuré
- ✅ Rate limiting actif

### Exercice 4: Custom DNS et Service Discovery (⭐⭐⭐⭐)

Configurez un serveur DNS personnalisé:
- Utiliser CoreDNS ou dnsmasq
- Résolution personnalisée de noms
- DNS round-robin pour load balancing

**Critères:**
- ✅ DNS server déployé
- ✅ Résolution custom fonctionne
- ✅ Round-robin DNS actif

### Exercice 5: Macvlan Network (⭐⭐⭐⭐⭐)

Créez un réseau macvlan pour donner des IPs du réseau physique aux conteneurs:
```bash
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  -o parent=eth0 macvlan-net

docker run --network=macvlan-net --ip=192.168.1.100 nginx
```

**Critères:**
- ✅ Macvlan network créé
- ✅ Conteneurs ont IPs du réseau physique
- ✅ Accessibles depuis réseau externe

## 🧪 Tests

```bash
# Test isolation
docker exec app1 ping -c 1 db  # Should fail
docker exec api ping -c 1 db   # Should succeed

# Test load balancing
for i in {1..10}; do curl http://app.localhost; done

# Test DNS
docker exec app1 nslookup api
```

## 💡 Concepts Clés

**Bridge Network:**
- Default pour conteneurs standalone
- Isolation entre réseaux
- DNS automatique par nom de conteneur

**Overlay Network:**
- Multi-hôtes avec Swarm
- Encryption possible
- Service discovery intégré

**Macvlan:**
- Apparaît comme device physique
- Performance maximale
- Pas de NAT

**Host Network:**
- Performance maximale
- Pas d'isolation
- Partage stack réseau de l'hôte

## 📊 Architecture Exemple

```
                    Internet
                       |
                   Traefik
                  (Port 80/443)
                       |
        +-------------+-------------+
        |             |             |
    Frontend      API Server    Admin
   (Network:      (Networks:   (Network:
    frontend)  frontend+backend)  admin)
                       |
                   Database
                  (Network:
                   backend)
```

## 🎓 Points à Retenir

1. **Toujours isoler les services sensibles** (DB) sur réseaux privés
2. **Utiliser overlay pour multi-hôtes**
3. **Traefik pour routing automatique**
4. **DNS intégré suffit souvent**
5. **Macvlan pour performance max**
6. **Ne pas utiliser host network sauf nécessaire**

---

[← TP1: Multi-stage Builds](../tp1-multistage-optimization/README.md) | [TP3: Storage →](../tp3-storage-volumes/README.md)
