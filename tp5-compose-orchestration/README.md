# TP5: Docker Compose Avancé et Orchestration

## 🎯 Objectifs

- Maîtriser Docker Compose pour stacks complexes
- Gérer multi-environnements (dev, staging, prod)
- Implémenter health checks et dépendances
- Utiliser configs, secrets et extensions
- Patterns de déploiement avancés

## 📚 Exercices

### Exercice 1: Stack Multi-Environnements (⭐⭐⭐⭐)

Créez une stack avec surcharges par environnement:

**docker-compose.yml (base):**
```yaml
version: '3.8'

x-common-variables: &common-env
  LOG_LEVEL: info
  TZ: UTC

services:
  app:
    image: myapp:${TAG:-latest}
    environment:
      <<: *common-env
      DATABASE_URL: postgresql://db:5432/mydb
    depends_on:
      db:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 10s

  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s

secrets:
  db_password:
    external: true
```

**docker-compose.override.yml (dev):**
```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      target: development
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      NODE_ENV: development
      DEBUG: "*"
    ports:
      - "3000:3000"

  db:
    ports:
      - "5432:5432"
    environment:
      POSTGRES_PASSWORD: dev-password
```

**docker-compose.prod.yml:**
```yaml
version: '3.8'

services:
  app:
    image: myapp:${VERSION}
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
        order: start-first
      restart_policy:
        condition: on-failure
        max_attempts: 3
    environment:
      NODE_ENV: production
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  db:
    deploy:
      placement:
        constraints:
          - node.role == manager
```

**Commandes:**
```bash
# Dev
docker compose up

# Production
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Staging
docker compose -f docker-compose.yml -f docker-compose.staging.yml up -d
```

**Critères:**
- ✅ 3 environnements configurés
- ✅ Surcharges fonctionnelles
- ✅ Variables d'environnement par env
- ✅ Secrets en production seulement

### Exercice 2: Health Checks et Dependencies (⭐⭐⭐⭐⭐)

Implémentez des health checks avancés:

```yaml
services:
  frontend:
    depends_on:
      api:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:80"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 40s

  api:
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 10s
      timeout: 3s
      retries: 5
      start_period: 20s

  db:
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $$POSTGRES_USER"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 3
```

**Script wait-for-it.sh dans l'image:**
```bash
#!/bin/bash
set -e

host="$1"
shift
cmd="$@"

until curl -f "http://$host/health" &> /dev/null; do
  echo "Waiting for $host..."
  sleep 2
done

exec $cmd
```

**Critères:**
- ✅ Services démarrent dans le bon ordre
- ✅ Health checks personnalisés
- ✅ Retry logic configuré
- ✅ Start period approprié

### Exercice 3: Configs et Secrets (⭐⭐⭐⭐)

Gérez les configurations sensibles:

```yaml
version: '3.8'

services:
  app:
    configs:
      - source: app_config
        target: /etc/app/config.yaml
        mode: 0440
    secrets:
      - source: db_password
        target: /run/secrets/db_password
        mode: 0400
      - api_key

configs:
  app_config:
    file: ./configs/app.yaml
    # Ou external pour Swarm:
    # external: true

secrets:
  db_password:
    file: ./secrets/db_password.txt
    # Production: external: true
  api_key:
    environment: "API_KEY"
```

**Créer secrets:**
```bash
# Development
echo "my-secret-password" > secrets/db_password.txt

# Production (Swarm)
echo "prod-password" | docker secret create db_password -
```

**Critères:**
- ✅ Configs montés en read-only
- ✅ Secrets en mode 0400
- ✅ Pas de secrets en clair dans compose file
- ✅ Secrets external en production

### Exercice 4: Extensions et Réutilisabilité (⭐⭐⭐⭐⭐)

Utilisez les extensions YAML:

```yaml
version: '3.8'

x-logging: &default-logging
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
    labels: "service"

x-healthcheck: &default-healthcheck
  interval: 30s
  timeout: 3s
  retries: 3
  start_period: 10s

x-deploy: &default-deploy
  restart_policy:
    condition: on-failure
    delay: 5s
    max_attempts: 3
  update_config:
    parallelism: 2
    delay: 10s

x-common-env: &common-env
  TZ: UTC
  LOG_LEVEL: info

services:
  app1:
    image: app1
    logging: *default-logging
    healthcheck:
      <<: *default-healthcheck
      test: ["CMD", "curl", "-f", "http://localhost/health"]
    deploy: *default-deploy
    environment:
      <<: *common-env
      SERVICE_NAME: app1

  app2:
    image: app2
    logging: *default-logging
    healthcheck:
      <<: *default-healthcheck
      test: ["CMD", "curl", "-f", "http://localhost/health"]
    deploy: *default-deploy
    environment:
      <<: *common-env
      SERVICE_NAME: app2
```

**Critères:**
- ✅ DRY (Don't Repeat Yourself)
- ✅ Configuration centralisée
- ✅ Facile à maintenir
- ✅ Extensions bien nommées

### Exercice 5: Profiles pour Cas d'Usage (⭐⭐⭐⭐)

Utilisez profiles pour activer/désactiver services:

```yaml
services:
  app:
    image: myapp
    # Toujours actif

  db:
    image: postgres
    # Toujours actif

  pgadmin:
    image: dpage/pgadmin4
    profiles: ["debug", "admin"]
    # Activé seulement avec --profile debug

  monitoring:
    image: prom/prometheus
    profiles: ["monitoring"]

  grafana:
    image: grafana/grafana
    profiles: ["monitoring"]

  test-runner:
    image: myapp
    profiles: ["test"]
    command: npm test
```

**Commandes:**
```bash
# Production (app + db seulement)
docker compose up -d

# Dev avec admin tools
docker compose --profile debug up -d

# Avec monitoring
docker compose --profile monitoring up -d

# Tests
docker compose --profile test up --abort-on-container-exit
```

**Critères:**
- ✅ Profiles bien organisés
- ✅ Services debug séparés
- ✅ Tests isolés
- ✅ Production lean

### Exercice 6: Rolling Updates et Blue-Green (⭐⭐⭐⭐⭐)

Déploiement sans downtime:

```yaml
services:
  app:
    image: myapp:${VERSION}
    deploy:
      replicas: 6
      update_config:
        parallelism: 2      # 2 à la fois
        delay: 10s          # Attendre 10s entre chaque batch
        failure_action: rollback
        monitor: 60s        # Monitor 60s après update
        max_failure_ratio: 0.3
        order: start-first  # Start new avant de stop old
      rollback_config:
        parallelism: 0      # Rollback tout immédiatement
        order: stop-first
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 10s
```

**Blue-Green Deployment:**
```bash
# Deploy green
docker compose -p green up -d

# Test green
curl http://green-app/health

# Switch traffic (update load balancer)
# ...

# Remove blue
docker compose -p blue down
```

**Critères:**
- ✅ Zero-downtime deployment
- ✅ Rollback automatique si échec
- ✅ Health checks avant switch
- ✅ Blue-Green testé

## 🧪 Exemples Complets

### Stack E-commerce Complète

```yaml
version: '3.8'

x-app-common: &app-common
  environment: &app-env
    DATABASE_URL: postgresql://db:5432/ecommerce
    REDIS_URL: redis://redis:6379
    LOG_LEVEL: ${LOG_LEVEL:-info}
  depends_on:
    db:
      condition: service_healthy
    redis:
      condition: service_healthy

services:
  frontend:
    <<: *app-common
    image: ecommerce/frontend:${VERSION}
    ports:
      - "80:3000"
    healthcheck:
      test: ["CMD", "wget", "-q", "--spider", "http://localhost:3000/health"]

  api:
    <<: *app-common
    image: ecommerce/api:${VERSION}
    deploy:
      replicas: 3

  worker:
    <<: *app-common
    image: ecommerce/worker:${VERSION}
    command: npm run worker
    deploy:
      replicas: 2

  db:
    image: postgres:15
    volumes:
      - db-data:/var/lib/postgresql/data
    secrets:
      - db_password
    healthcheck:
      test: ["CMD", "pg_isready"]

  redis:
    image: redis:7-alpine
    volumes:
      - redis-data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]

volumes:
  db-data:
  redis-data:

secrets:
  db_password:
    external: true
```

## 🎓 Best Practices

1. **Toujours utiliser health checks** en production
2. **Depends_on avec condition** service_healthy
3. **Secrets** jamais en clair
4. **Extensions YAML** pour DRY
5. **Profiles** pour environnements
6. **Logging** avec rotation
7. **Resource limits** en production
8. **Update strategy** pour zero-downtime

---

[← TP4: Sécurité](../tp4-security-advanced/README.md) | [TP6: Monitoring →](../tp6-monitoring-debugging/README.md)
