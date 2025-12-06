# TP8: CI/CD et Registry Privé

## 🎯 Objectifs

- Déployer et sécuriser un registry Docker privé
- Créer des pipelines CI/CD complets avec GitHub Actions
- Implémenter le versioning et tagging automatique
- Mettre en place un workflow GitOps
- Signer et scanner les images automatiquement

## 📚 Exercices

### Exercice 1: Registry Privé avec Authentification (⭐⭐⭐⭐)

**docker-compose-registry.yml:**
```yaml
version: '3.8'

services:
  registry:
    image: registry:2
    restart: always
    environment:
      REGISTRY_AUTH: htpasswd
      REGISTRY_AUTH_HTPASSWD_PATH: /auth/htpasswd
      REGISTRY_AUTH_HTPASSWD_REALM: Registry Realm
      REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY: /data
      REGISTRY_HTTP_SECRET: changeme-secret-key
      REGISTRY_HTTP_HEADERS_Access-Control-Allow-Origin: ['*']
      REGISTRY_HTTP_HEADERS_Access-Control-Allow-Methods: ['HEAD', 'GET', 'OPTIONS', 'DELETE']
      REGISTRY_HTTP_HEADERS_Access-Control-Allow-Headers: ['Authorization', 'Accept']
      REGISTRY_HTTP_HEADERS_Access-Control-Expose-Headers: ['Docker-Content-Digest']
    volumes:
      - registry-data:/data
      - ./auth:/auth:ro
      - ./certs:/certs:ro
    ports:
      - "5000:5000"
    networks:
      - registry

  registry-ui:
    image: joxit/docker-registry-ui:latest
    restart: always
    environment:
      REGISTRY_TITLE: My Private Registry
      REGISTRY_URL: https://registry:5000
      DELETE_IMAGES: "true"
      SHOW_CONTENT_DIGEST: "true"
      SINGLE_REGISTRY: "true"
    ports:
      - "8080:80"
    depends_on:
      - registry
    networks:
      - registry

volumes:
  registry-data:

networks:
  registry:
```

**Setup authentification:**
```bash
# Créer htpasswd
mkdir auth
docker run --rm --entrypoint htpasswd httpd:2 \
  -Bbn username password > auth/htpasswd

# Générer certificats SSL
mkdir certs
openssl req -newkey rsa:4096 -nodes -sha256 \
  -keyout certs/domain.key -x509 -days 365 \
  -out certs/domain.crt \
  -subj "/CN=registry.local"

# Démarrer registry
docker compose -f docker-compose-registry.yml up -d

# Login
docker login localhost:5000 -u username -p password

# Push image
docker tag myapp localhost:5000/myapp:latest
docker push localhost:5000/myapp:latest
```

**Critères:**
- ✅ Registry accessible avec auth
- ✅ HTTPS configuré
- ✅ UI fonctionnelle
- ✅ Push/Pull fonctionnent

### Exercice 2: GitHub Actions CI/CD Pipeline (⭐⭐⭐⭐⭐)

**.github/workflows/ci.yml:**
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
    tags: [ 'v*' ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run tests
        run: |
          docker compose -f docker-compose.test.yml up \
            --abort-on-container-exit \
            --exit-code-from test

      - name: Lint Dockerfile
        uses: hadolint/hadolint-action@v3.1.0
        with:
          dockerfile: Dockerfile

  build:
    needs: test
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
      id-token: write
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha,prefix={{branch}}-
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          platforms: linux/amd64,linux/arm64
          provenance: true
          sbom: true

      - name: Scan image
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ steps.meta.outputs.version }}
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH'

      - name: Upload scan results
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: 'trivy-results.sarif'

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Deploy to production
        run: |
          # SSH to server and pull new image
          # kubectl set image deployment/app app=$IMAGE:$TAG
          # docker stack deploy -c docker-compose.yml myapp
          echo "Deployment logic here"
```

**Critères:**
- ✅ Tests automatiques
- ✅ Build multi-platform
- ✅ Scan de vulnérabilités
- ✅ Tag automatique selon git
- ✅ Deploy automatique sur main

### Exercice 3: Semantic Versioning Automatique (⭐⭐⭐⭐)

**.github/workflows/release.yml:**
```yaml
name: Release

on:
  push:
    branches: [ main ]

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Semantic Release
        uses: cycjimmy/semantic-release-action@v4
        with:
          extra_plugins: |
            @semantic-release/changelog
            @semantic-release/git
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Get version
        id: version
        run: echo "version=$(cat package.json | jq -r .version)" >> $GITHUB_OUTPUT

      - name: Build and push with version
        uses: docker/build-push-action@v5
        with:
          push: true
          tags: |
            myregistry/app:${{ steps.version.outputs.version }}
            myregistry/app:latest
```

**Conventional Commits:**
```bash
# Feature (minor bump)
git commit -m "feat: add user authentication"

# Fix (patch bump)
git commit -m "fix: resolve login issue"

# Breaking change (major bump)
git commit -m "feat!: redesign API structure"
git commit -m "feat: new feature

BREAKING CHANGE: API endpoint changed"
```

**Critères:**
- ✅ Versioning automatique
- ✅ CHANGELOG généré
- ✅ Git tags créés
- ✅ Images tagées avec versions

### Exercice 4: Multi-Environment Deployment (⭐⭐⭐⭐⭐)

**.github/workflows/deploy.yml:**
```yaml
name: Deploy

on:
  workflow_run:
    workflows: ["CI/CD Pipeline"]
    types: [completed]
    branches: [main, staging, develop]

jobs:
  deploy-dev:
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    environment: development
    steps:
      - name: Deploy to dev
        run: |
          kubectl config use-context dev-cluster
          kubectl set image deployment/app app=$IMAGE:dev-$GITHUB_SHA

  deploy-staging:
    if: github.ref == 'refs/heads/staging'
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - name: Deploy to staging
        run: |
          kubectl config use-context staging-cluster
          kubectl set image deployment/app app=$IMAGE:staging-$GITHUB_SHA

  deploy-prod:
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Deploy to production
        run: |
          kubectl config use-context prod-cluster
          kubectl set image deployment/app app=$IMAGE:$VERSION

      - name: Run smoke tests
        run: |
          curl -f https://api.prod.example.com/health || exit 1

      - name: Notify Slack
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: 'Production deployment completed'
```

**Critères:**
- ✅ Deploy automatique par environnement
- ✅ Approval requis pour prod
- ✅ Rollback automatique si échec
- ✅ Notifications

### Exercice 5: Image Signing avec Cosign (⭐⭐⭐⭐⭐)

**Installation Cosign:**
```bash
# Install cosign
curl -O -L https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64
sudo mv cosign-linux-amd64 /usr/local/bin/cosign
sudo chmod +x /usr/local/bin/cosign

# Generate keys
cosign generate-key-pair
```

**.github/workflows/sign.yml:**
```yaml
name: Sign Images

on:
  workflow_run:
    workflows: ["CI/CD Pipeline"]
    types: [completed]

jobs:
  sign:
    runs-on: ubuntu-latest
    permissions:
      packages: write
      id-token: write
    steps:
      - name: Install Cosign
        uses: sigstore/cosign-installer@v3

      - name: Sign image
        env:
          COSIGN_PASSWORD: ${{ secrets.COSIGN_PASSWORD }}
        run: |
          cosign sign --key cosign.key \
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}

      - name: Verify signature
        run: |
          cosign verify --key cosign.pub \
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
```

**Verify locally:**
```bash
# Verify image signature
cosign verify --key cosign.pub myregistry/app:latest

# Verify with policy
cosign verify --certificate-identity user@example.com \
  --certificate-oidc-issuer https://github.com/login/oauth \
  myregistry/app:latest
```

**Critères:**
- ✅ Images signées automatiquement
- ✅ Vérification fonctionne
- ✅ Keyless signing (OIDC)
- ✅ Attestations attachées

### Exercice 6: Registry Garbage Collection (⭐⭐⭐⭐)

**Script de cleanup:**
```bash
#!/bin/bash
# registry-gc.sh

# Dry run
docker exec registry bin/registry garbage-collect \
  --dry-run /etc/docker/registry/config.yml

# Réel cleanup
docker exec registry bin/registry garbage-collect \
  /etc/docker/registry/config.yml

# Restart registry
docker restart registry
```

**Cron job:**
```bash
# Crontab: Tous les dimanches à 2h
0 2 * * 0 /usr/local/bin/registry-gc.sh >> /var/log/registry-gc.log 2>&1
```

**Configuration retention:**
```yaml
# config.yml
version: 0.1
storage:
  delete:
    enabled: true
  maintenance:
    uploadpurging:
      enabled: true
      age: 168h  # 7 days
      interval: 24h
      dryrun: false
```

**Critères:**
- ✅ Cleanup automatique
- ✅ Old tags supprimés
- ✅ Espace disque récupéré
- ✅ Logs de cleanup

### Exercice 7: Mirror et Pull-Through Cache (⭐⭐⭐⭐)

**Registry pull-through cache:**
```yaml
# config.yml
version: 0.1
proxy:
  remoteurl: https://registry-1.docker.io
  username: dockerhub-username
  password: dockerhub-password

storage:
  filesystem:
    rootdirectory: /var/lib/registry
```

**Utilisation:**
```bash
# Configurer mirror
docker pull localhost:5000/library/nginx:latest
# Cache le pull pour prochaines fois
```

**Docker daemon config:**
```json
{
  "registry-mirrors": ["http://localhost:5000"],
  "insecure-registries": ["localhost:5000"]
}
```

**Critères:**
- ✅ Mirror cache les images
- ✅ Pulls plus rapides
- ✅ Bandwidth réduit
- ✅ Fallback si mirror down

### Exercice 8: Registry Replication (⭐⭐⭐⭐⭐)

**Harbor pour replication:**
```yaml
version: '3.8'

services:
  harbor-core:
    image: goharbor/harbor-core:v2.9.0
    # ... config

  harbor-jobservice:
    image: goharbor/harbor-jobservice:v2.9.0
    # ... config
```

**Configure replication:**
```bash
# Via Harbor UI ou API
curl -X POST "https://harbor.example.com/api/v2.0/replication/policies" \
  -H "Authorization: Basic $(echo -n admin:password | base64)" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "replicate-to-dr",
    "src_registry": {
      "id": 1
    },
    "dest_registry": {
      "id": 2
    },
    "filters": [{
      "type": "name",
      "value": "prod/**"
    }],
    "trigger": {
      "type": "event_based"
    }
  }'
```

**Critères:**
- ✅ Replication automatique
- ✅ Multi-region sync
- ✅ Disaster recovery ready
- ✅ Filters configurés

## 🧪 Pipeline Complete Example

```yaml
# .github/workflows/complete.yml
name: Complete CI/CD

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]

jobs:
  # 1. Lint et Tests
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: docker compose -f docker-compose.test.yml up --exit-code-from test
      - uses: hadolint/hadolint-action@v3.1.0

  # 2. Build Multi-platform
  build:
    needs: quality
    runs-on: ubuntu-latest
    steps:
      - uses: docker/setup-buildx-action@v3
      - uses: docker/build-push-action@v5
        with:
          platforms: linux/amd64,linux/arm64
          cache-from: type=gha
          cache-to: type=gha,mode=max

  # 3. Scan Security
  scan:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: aquasecurity/trivy-action@master
        with:
          severity: CRITICAL,HIGH
          exit-code: 1

  # 4. Sign Image
  sign:
    needs: scan
    runs-on: ubuntu-latest
    steps:
      - uses: sigstore/cosign-installer@v3
      - run: cosign sign --key cosign.key $IMAGE

  # 5. Deploy
  deploy:
    needs: sign
    runs-on: ubuntu-latest
    environment: production
    steps:
      - run: kubectl set image deployment/app app=$IMAGE
      - run: kubectl rollout status deployment/app

  # 6. Notify
  notify:
    needs: deploy
    runs-on: ubuntu-latest
    if: always()
    steps:
      - uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
```

## 🎓 Best Practices CI/CD

1. **Toujours tester avant de build**
2. **Scanner les images** pour vulnérabilités
3. **Signer les images** en production
4. **Multi-stage déploiement** dev → staging → prod
5. **Approval** manuel pour production
6. **Rollback automatique** si health check fail
7. **Monitoring et alerting** post-deployment
8. **Immutable tags** (jamais écraser :latest en prod)

---

[← TP7: BuildKit](../tp7-buildkit-advanced/README.md) | [🏠 Retour au sommaire](../README.md)
