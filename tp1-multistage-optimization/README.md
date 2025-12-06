# TP1: Multi-stage Builds et Optimisation d'Images

## 🎯 Objectifs

Ce TP vous apprendra à :
- Créer des multi-stage builds complexes et optimisés
- Réduire drastiquement la taille des images (objectif: -80%)
- Utiliser les cache mounts, build secrets et SSH mounts
- Créer des images reproductibles avec dependency lock files
- Maîtriser les patterns de build avancés

## 📚 Contexte

Vous allez optimiser une application Node.js et une application Go qui sont actuellement construites de manière non optimale. L'objectif est de passer d'images de plusieurs centaines de MB à des images de quelques dizaines de MB.

## 🔧 Exercices

### Exercice 1: Application Node.js avec Multi-stage Build (⭐⭐⭐)

**Fichier:** `app/node-app/`

Vous trouverez une application Express.js simple. Créez un Dockerfile multi-stage qui :

1. **Stage 1 (Dependencies):**
   - Utilise une image de base appropriée
   - Installe UNIQUEMENT les dépendances de production
   - Utilise un cache mount pour npm cache

2. **Stage 2 (Build):**
   - Copie les sources
   - Build l'application si nécessaire (TypeScript, etc.)

3. **Stage 3 (Production):**
   - Utilise une image minimale (alpine ou distroless)
   - Copie uniquement les artefacts nécessaires
   - Configure un user non-root
   - Image finale < 100MB

**Critères de validation:**
- ✅ Image finale < 100MB
- ✅ Utilisation de cache mounts
- ✅ User non-root
- ✅ L'application démarre et répond sur le port 3000
- ✅ Aucune dépendance de dev dans l'image finale

### Exercice 2: Application Go Ultra-optimisée (⭐⭐⭐⭐)

**Fichier:** `app/go-app/`

Créez un Dockerfile pour l'application Go qui :

1. **Stage Build:**
   - Compile l'application en static binary
   - Utilise les flags de compilation pour réduire la taille
   - Active les optimisations (CGO_ENABLED=0, -ldflags="-s -w")

2. **Stage Production:**
   - Utilise `scratch` ou `distroless/static`
   - Image finale < 10MB
   - Inclut les certificats SSL si nécessaire

**Critères de validation:**
- ✅ Image finale < 10MB
- ✅ Binary statique fonctionnel
- ✅ Pas de dépendances runtime
- ✅ L'application démarre correctement

### Exercice 3: Build Secrets et SSH Mounts (⭐⭐⭐⭐⭐)

**Fichier:** `app/private-deps/`

Créez un build qui utilise des dépendances privées (simulées) :

1. Utilisez `--mount=type=secret` pour gérer des tokens d'authentification
2. Utilisez `--mount=type=ssh` pour cloner des repos privés (simulés)
3. Assurez-vous qu'aucun secret ne se retrouve dans l'image finale
4. Les secrets ne doivent pas apparaître dans l'historique des layers

**Commande de build attendue:**
```bash
docker build --secret id=npm_token,src=.npmrc \
             --ssh default \
             -t app-with-secrets .
```

**Critères de validation:**
- ✅ Les secrets ne sont pas dans l'image
- ✅ Utilisation correcte de --mount=type=secret
- ✅ Build réussi avec dépendances privées
- ✅ `docker history` ne révèle aucun secret

### Exercice 4: Cache Optimization et Reproductibilité (⭐⭐⭐⭐)

**Fichier:** `app/cache-optimized/`

Optimisez les layers de cache pour :

1. **Maximiser la réutilisation du cache:**
   - Séparez l'installation des dépendances du code source
   - Utilisez `.dockerignore` efficacement
   - Ordonnez les commandes de manière optimale

2. **Reproductibilité:**
   - Utilisez des lock files (package-lock.json, go.sum)
   - Pinner les versions des images de base avec digest SHA256
   - Résultat identique à chaque build

**Critères de validation:**
- ✅ Rebuild sans changement = 100% cache hit
- ✅ Changement de code source = seuls les derniers layers rebuilt
- ✅ Images reproducibles (même digest)

### Exercice 5: Build Patterns Avancés (⭐⭐⭐⭐⭐)

**Fichier:** `app/advanced-patterns/`

Créez un Dockerfile qui démontre :

1. **Build Arguments dynamiques:**
   ```dockerfile
   ARG VERSION=latest
   ARG BUILD_DATE
   ARG VCS_REF
   ```

2. **Multi-target builds:**
   - Target `development` avec outils de dev
   - Target `test` avec dépendances de test
   - Target `production` ultra-optimisé

3. **Labels et metadata:**
   - OCI image spec labels
   - Custom labels pour versioning

**Commandes attendues:**
```bash
# Build dev
docker build --target development -t app:dev .

# Build test
docker build --target test -t app:test .

# Build production
docker build --target production \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg VCS_REF=$(git rev-parse --short HEAD) \
  -t app:prod .
```

## 📊 Métriques de succès

| Exercice | Taille Avant | Taille Après | Réduction |
|----------|-------------|--------------|-----------|
| Ex1: Node.js | ~400MB | < 100MB | > 75% |
| Ex2: Go | ~300MB | < 10MB | > 96% |
| Ex3: Secrets | - | - | 0 secrets exposés |
| Ex4: Cache | - | - | > 90% cache hit |
| Ex5: Advanced | - | - | 3 targets fonctionnels |

## 🧪 Tests

Exécutez le script de test pour valider votre travail :

```bash
chmod +x test.sh
./test.sh
```

Le script vérifie :
- ✅ Taille des images
- ✅ Fonctionnement des applications
- ✅ Absence de secrets
- ✅ Configuration de sécurité (user non-root)
- ✅ Présence des labels

## 💡 Hints

<details>
<summary>Hint 1: Réduction de taille Node.js</summary>

```dockerfile
# Utilisez alpine pour réduire la taille
FROM node:20-alpine AS deps

# Cache mount pour npm
RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production
```
</details>

<details>
<summary>Hint 2: Go static binary</summary>

```dockerfile
# Désactiver CGO et strip le binary
RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags="-s -w" \
    -o app .

# Utiliser scratch
FROM scratch
COPY --from=builder /app /app
```
</details>

<details>
<summary>Hint 3: Build secrets</summary>

```dockerfile
# Dans le Dockerfile
RUN --mount=type=secret,id=npm_token \
    echo "//registry.npmjs.org/:_authToken=$(cat /run/secrets/npm_token)" > .npmrc && \
    npm install && \
    rm .npmrc
```
</details>

## 📚 Ressources

- [Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)
- [BuildKit](https://docs.docker.com/build/buildkit/)
- [Build secrets](https://docs.docker.com/build/building/secrets/)
- [Cache mounts](https://docs.docker.com/build/guide/mounts/)
- [Distroless images](https://github.com/GoogleContainerTools/distroless)

## ✅ Checklist finale

Avant de passer au TP suivant, assurez-vous que :

- [ ] Tous les tests passent
- [ ] Les images sont < aux tailles requises
- [ ] Aucun secret n'est exposé
- [ ] Les applications démarrent correctement
- [ ] Vous comprenez chaque ligne de vos Dockerfiles
- [ ] Vous avez comparé avec les solutions

## 🎓 Points clés à retenir

1. **Séparez les stages** : build, dependencies, production
2. **Utilisez les images minimales** : alpine, distroless, scratch
3. **Optimisez l'ordre des layers** : du moins changeant au plus changeant
4. **Utilisez les cache mounts** : npm, go, apt
5. **Ne copiez que le nécessaire** : .dockerignore est votre ami
6. **Sécurité** : user non-root, pas de secrets exposés
7. **Reproductibilité** : lock files et digest SHA256

---

[← Retour au sommaire](../README.md) | [TP2: Networking Avancé →](../tp2-networking-advanced/README.md)
