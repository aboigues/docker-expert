# TP7: BuildKit et Build Avancé

## 🎯 Objectifs

- Maîtriser BuildKit et ses fonctionnalités avancées
- Utiliser les builds cross-platform
- Optimiser le cache et les builds parallèles
- Implémenter des build contexts multiples
- Utiliser les frontends alternatifs (buildpacks, etc.)

## 📚 Exercices

### Exercice 1: BuildKit Features Avancées (⭐⭐⭐⭐)

**Activer BuildKit:**
```bash
export DOCKER_BUILDKIT=1
# Ou dans daemon.json
{
  "features": {
    "buildkit": true
  }
}
```

**Dockerfile avec features BuildKit:**
```dockerfile
# syntax=docker/dockerfile:1.4

FROM alpine AS base

# Cache mount pour packages
RUN --mount=type=cache,target=/var/cache/apk \
    apk add --update nodejs npm

# Secret mount (token jamais dans l'image)
RUN --mount=type=secret,id=npmrc,target=/root/.npmrc \
    npm install -g some-private-package

# SSH mount pour repos privés
RUN --mount=type=ssh \
    git clone git@github.com:private/repo.git

# Bind mount pour context externe
RUN --mount=type=bind,source=vendor,target=/vendor \
    cp /vendor/lib.so /usr/local/lib/

# Tmpfs mount
RUN --mount=type=tmpfs,target=/tmp \
    make build
```

**Build avec BuildKit:**
```bash
docker buildx build \
  --secret id=npmrc,src=$HOME/.npmrc \
  --ssh default \
  --cache-from type=registry,ref=myapp:cache \
  --cache-to type=registry,ref=myapp:cache,mode=max \
  -t myapp:latest \
  .
```

**Critères:**
- ✅ Cache mounts fonctionnels
- ✅ Secrets ne sont pas dans l'image
- ✅ SSH mount fonctionne
- ✅ Build plus rapide avec cache

### Exercice 2: Multi-Platform Builds (⭐⭐⭐⭐⭐)

**Setup buildx:**
```bash
# Créer builder multi-platform
docker buildx create --name multiplatform --use
docker buildx inspect --bootstrap

# Vérifier platforms supportées
docker buildx ls
```

**Dockerfile cross-platform:**
```dockerfile
# syntax=docker/dockerfile:1.4

FROM --platform=$BUILDPLATFORM golang:1.21-alpine AS builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH

RUN echo "Building on $BUILDPLATFORM for $TARGETPLATFORM"

WORKDIR /build

COPY go.mod go.sum ./
RUN go mod download

COPY . .

# Cross-compile pour la target platform
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -ldflags="-s -w" -o app .

# Image finale multi-platform
FROM alpine:latest

COPY --from=builder /build/app /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/app"]
```

**Build et push multi-platform:**
```bash
docker buildx build \
  --platform linux/amd64,linux/arm64,linux/arm/v7 \
  --tag myregistry/app:latest \
  --push \
  .

# Ou build local pour tester
docker buildx build \
  --platform linux/arm64 \
  --load \
  -t app:arm64 \
  .
```

**Critères:**
- ✅ Images pour amd64, arm64, armv7
- ✅ Manifests multi-platform
- ✅ Pull fonctionne sur toutes platforms
- ✅ Taille optimisée pour chaque platform

### Exercice 3: Build Contexts Multiples (⭐⭐⭐⭐⭐)

**Utiliser plusieurs contextes:**
```dockerfile
# syntax=docker/dockerfile:1.4

FROM alpine AS base

# Context additionnel depuis un repo Git
FROM --context=deps git://github.com/user/dependencies.git AS deps

# Context depuis une image
FROM --context=prebuilt myregistry/prebuilt:latest AS prebuilt

# Copier depuis différents contexts
COPY --from=deps /app/lib /usr/local/lib
COPY --from=prebuilt /app/binary /usr/local/bin/

# Context local mais path différent
COPY --from=configs ./configs /etc/app/
```

**Build avec contexts nommés:**
```bash
docker buildx build \
  --build-context deps=../shared-dependencies \
  --build-context configs=./environments/production \
  -t app:latest \
  .
```

**Critères:**
- ✅ Multiples sources de contexte
- ✅ Git contexts fonctionnels
- ✅ Image contexts utilisables
- ✅ Build reproductible

### Exercice 4: Cache Optimization Avancée (⭐⭐⭐⭐⭐)

**Cache inline:**
```bash
# Build avec cache inline
docker buildx build \
  --cache-to type=inline \
  --tag myapp:latest \
  --push \
  .

# Build suivant utilise le cache
docker buildx build \
  --cache-from myapp:latest \
  --tag myapp:v2 \
  .
```

**Cache registry:**
```bash
# Export cache vers registry
docker buildx build \
  --cache-to type=registry,ref=myregistry/myapp:cache,mode=max \
  --tag myapp:latest \
  .

# Import cache depuis registry
docker buildx build \
  --cache-from type=registry,ref=myregistry/myapp:cache \
  --tag myapp:latest \
  .
```

**Cache local:**
```bash
# Export vers filesystem
docker buildx build \
  --cache-to type=local,dest=/tmp/cache \
  --tag myapp:latest \
  .

# Import depuis filesystem
docker buildx build \
  --cache-from type=local,src=/tmp/cache \
  --tag myapp:latest \
  .
```

**GitHub Actions cache:**
```bash
docker buildx build \
  --cache-from type=gha \
  --cache-to type=gha,mode=max \
  --tag myapp:latest \
  .
```

**Critères:**
- ✅ Cache partagé entre builds
- ✅ Mode=max pour cache complet
- ✅ Cache size raisonnable
- ✅ Speedup > 50%

### Exercice 5: Builds Parallèles et Dépendances (⭐⭐⭐⭐)

**Dockerfile avec builds parallèles:**
```dockerfile
# syntax=docker/dockerfile:1.4

# Ces stages buildent en parallèle
FROM golang:1.21 AS backend-builder
WORKDIR /backend
COPY backend/ .
RUN go build -o api

FROM node:20 AS frontend-builder
WORKDIR /frontend
COPY frontend/ .
RUN npm ci && npm run build

FROM python:3.11 AS ml-builder
WORKDIR /ml
COPY ml/ .
RUN pip install -r requirements.txt

# Stage final combine tout
FROM alpine:latest

COPY --from=backend-builder /backend/api /usr/local/bin/
COPY --from=frontend-builder /frontend/dist /var/www/
COPY --from=ml-builder /ml /opt/ml/

CMD ["/usr/local/bin/api"]
```

**Build graph:**
```bash
# Visualiser le build graph
docker buildx bake --print

# Forcer parallélisme max
docker buildx build --builder multiplatform .
```

**Critères:**
- ✅ Stages indépendants buildent en parallèle
- ✅ Utilisation CPU optimale
- ✅ Build time réduit de 40%+

### Exercice 6: Buildx Bake (⭐⭐⭐⭐⭐)

**docker-bake.hcl:**
```hcl
variable "TAG" {
  default = "latest"
}

variable "REGISTRY" {
  default = "myregistry"
}

group "default" {
  targets = ["app", "worker", "admin"]
}

target "app" {
  dockerfile = "Dockerfile"
  tags = ["${REGISTRY}/app:${TAG}"]
  cache-from = ["type=registry,ref=${REGISTRY}/app:cache"]
  cache-to = ["type=registry,ref=${REGISTRY}/app:cache,mode=max"]
  platforms = ["linux/amd64", "linux/arm64"]
  args = {
    BUILD_DATE = timestamp()
    VERSION = TAG
  }
}

target "worker" {
  inherits = ["app"]
  tags = ["${REGISTRY}/worker:${TAG}"]
  target = "worker"
}

target "admin" {
  inherits = ["app"]
  tags = ["${REGISTRY}/admin:${TAG}"]
  target = "admin"
  contexts = {
    assets = "./admin-assets"
  }
}
```

**Build avec bake:**
```bash
# Build tout
docker buildx bake

# Build un target spécifique
docker buildx bake app

# Override variables
docker buildx bake --set *.platform=linux/amd64 --set TAG=v1.2.3

# Push
docker buildx bake --push
```

**Critères:**
- ✅ Tous targets buildent correctement
- ✅ Variables propagées
- ✅ Cache réutilisé
- ✅ Multi-platform fonctionne

### Exercice 7: Frontends Alternatifs (⭐⭐⭐⭐⭐)

**BuildPacks:**
```dockerfile
# syntax=docker/dockerfile:1.4
FROM buildpacksio/pack:latest

# Pack build directement
RUN pack build myapp --builder heroku/buildpacks:20
```

**Ou via CLI:**
```bash
pack build myapp \
  --builder paketobuildpacks/builder:base \
  --buildpack paketo-buildpacks/nodejs \
  --env BP_NODE_VERSION=20
```

**DockerSlim:**
```bash
# Minifier image existante
docker-slim build --http-probe myapp:latest

# Résultat: myapp.slim (90% plus petit)
```

**Custom Frontend:**
```dockerfile
# syntax=myorg/custom-frontend:latest

# Votre syntaxe custom
FROM alpine
```

**Critères:**
- ✅ Buildpacks fonctionnel
- ✅ Image optimisée automatiquement
- ✅ Pas de Dockerfile nécessaire

### Exercice 8: Metadata et Attestations (⭐⭐⭐⭐)

**Build avec metadata:**
```bash
docker buildx build \
  --provenance=true \
  --sbom=true \
  --attest type=provenance,mode=max \
  --attest type=sbom \
  --tag myapp:latest \
  --push \
  .
```

**Labels OCI:**
```dockerfile
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.source="https://github.com/user/repo"
```

**Inspecter attestations:**
```bash
docker buildx imagetools inspect myapp:latest \
  --format "{{json .Provenance}}"

docker buildx imagetools inspect myapp:latest \
  --format "{{json .SBOM}}"
```

**Critères:**
- ✅ Provenance générée
- ✅ SBOM complet
- ✅ Metadata OCI présente
- ✅ Signable avec Cosign

## 🧪 Benchmarks

**Test performance du cache:**
```bash
# First build (cold cache)
time docker buildx build --no-cache -t app:test .

# Second build (warm cache)
time docker buildx build -t app:test .

# Avec cache registry
time docker buildx build \
  --cache-from type=registry,ref=app:cache \
  -t app:test .
```

## 🎓 Best Practices BuildKit

1. **Toujours utiliser DOCKER_BUILDKIT=1**
2. **Cache mounts** pour package managers
3. **Secrets** avec --mount=type=secret
4. **Multi-platform** dès le début
5. **Cache registry** pour CI/CD
6. **Bake** pour projets complexes
7. **SBOM et Provenance** en production
8. **syntax directive** pour features récentes

---

[← TP6: Monitoring](../tp6-monitoring-debugging/README.md) | [TP8: CI/CD →](../tp8-cicd-registry/README.md)
