# ✅ SOLUTION ULTRA-OPTIMISÉE - Dockerfile pour Go
# Objectif: Passer de ~800MB à < 10MB (reduction de 98%+)

# ============================================
# Stage 1: Build
# ============================================
FROM golang:1.21-alpine AS builder

# Metadata
LABEL stage=builder

# Install des outils nécessaires
RUN apk add --no-cache git ca-certificates tzdata

WORKDIR /build

# Copie les fichiers de dépendances pour cache optimization
COPY go.mod go.sum* ./

# Download des dépendances (si go.sum existe)
# Cette layer sera cachée tant que go.mod ne change pas
RUN go mod download
RUN go mod verify

# Copie le code source
COPY . .

# Build du binary statique avec optimisations maximales
# CGO_ENABLED=0 : Désactive CGO pour créer un binary statique
# GOOS=linux : Spécifie le système cible
# -ldflags="-s -w" :
#   -s : Supprime la table des symboles
#   -w : Supprime les informations de debug DWARF
#   Réduction de taille: ~30-40%
# -a : Force la recompilation de tous les packages
# -installsuffix cgo : Différencie les builds avec/sans CGO
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -a \
    -installsuffix cgo \
    -ldflags="-s -w -X main.version=1.0.0 -X main.buildTime=$(date -u '+%Y-%m-%d_%H:%M:%S')" \
    -o app \
    .

# Vérifie que le binary est bien statique
RUN ldd app 2>&1 | grep -q "not a dynamic executable" || (echo "Binary is not static!" && exit 1)

# ============================================
# Stage 2: Production - Image minimale
# Option 1: scratch (plus petit, 0MB de base)
# Option 2: distroless/static (recommandé, ~2MB, includes ca-certs et tzdata)
# ============================================
FROM gcr.io/distroless/static:nonroot AS production

# Labels OCI
LABEL org.opencontainers.image.title="Go Demo App" \
      org.opencontainers.image.description="Ultra-optimized Go application" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.vendor="Docker Expert Training" \
      org.opencontainers.image.source="https://github.com/docker-expert/demo"

# Copie les certificats SSL (nécessaires pour HTTPS)
# COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
# Note: pas nécessaire avec distroless, déjà inclus

# Copie les timezone data (si nécessaire)
# COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
# Note: pas nécessaire avec distroless, déjà inclus

# Copie le binary statique
COPY --from=builder /build/app /app

# distroless/static:nonroot utilise déjà un user non-root (uid: 65532)
# Pas besoin de spécifier USER

# Variables d'environnement
ENV PORT=8080

# Expose le port
EXPOSE 8080

# Health check (nécessite un outil externe ou le binary doit l'implémenter)
# Note: healthcheck ne fonctionne pas bien avec scratch/distroless
# Utilisez k8s liveness/readiness probes à la place

# Entrypoint
ENTRYPOINT ["/app"]

# ============================================
# Alternative avec scratch (encore plus petit)
# ============================================
FROM scratch AS scratch-production

# Copie les certificats SSL
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copie timezone data
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo

# Copie le binary
COPY --from=builder /build/app /app

ENV PORT=8080

EXPOSE 8080

ENTRYPOINT ["/app"]

# ============================================
# Résultats:
# - Image de base golang: ~800MB
# - Image finale distroless: ~8MB (99% reduction!)
# - Image finale scratch: ~6MB (99.2% reduction!)
# - Binary statique: ✅
# - User non-root: ✅ (distroless)
# - Optimisations build: ✅
# - Aucune dépendance runtime: ✅
# ============================================

# Pour build avec target distroless (recommandé):
# DOCKER_BUILDKIT=1 docker build --target production -t go-app:optimized -f solutions/Dockerfile.go app/go-app/

# Pour build avec scratch (maximum optimization):
# DOCKER_BUILDKIT=1 docker build --target scratch-production -t go-app:scratch -f solutions/Dockerfile.go app/go-app/

# Pour vérifier la taille:
# docker images go-app

# Pour run:
# docker run -p 8080:8080 go-app:optimized

# Pour inspecter le binary:
# docker run --rm --entrypoint /bin/sh golang:1.21-alpine -c "file /path/to/app"
