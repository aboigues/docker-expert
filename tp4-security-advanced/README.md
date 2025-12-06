# TP4: Sécurité Docker Avancée

## 🎯 Objectifs

Ce TP vous apprendra à :
- Configurer et utiliser Docker en mode rootless
- Maîtriser les Linux Security Modules (AppArmor, SELinux, Seccomp)
- Implémenter le scanning de vulnérabilités dans vos images
- Gérer finement les capabilities Linux
- Appliquer le principe du moindre privilège
- Sécuriser le daemon Docker et les communications
- Utiliser les User Namespaces pour l'isolation

## 📚 Contexte

La sécurité est critique en production. Ce TP couvre les aspects avancés de la sécurité Docker, de la configuration du daemon jusqu'aux profils de sécurité personnalisés. Vous apprendrez à défendre vos conteneurs contre les attaques courantes et à implémenter une défense en profondeur.

## 🔧 Exercices

### Exercice 1: Docker Rootless (⭐⭐⭐⭐)

**Objectif:** Configurer et utiliser Docker en mode rootless pour éliminer les risques liés au daemon root.

**Tâches:**

1. **Installation Docker Rootless:**
   ```bash
   # Désinstaller le daemon Docker rootful si nécessaire
   # Installer Docker Rootless
   curl -fsSL https://get.docker.com/rootless | sh
   ```

2. **Configuration:**
   - Configurer les variables d'environnement
   - Gérer les limitations (ports < 1024, etc.)
   - Configurer le port forwarding si nécessaire

3. **Tests:**
   - Vérifier que le daemon tourne sans root
   - Lancer des conteneurs
   - Tester les limitations de privilèges

**Critères de validation:**
- ✅ Daemon Docker ne tourne PAS en tant que root
- ✅ Conteneurs fonctionnent normalement
- ✅ Pas de sudo nécessaire pour docker commands
- ✅ Documentation des limitations connues

**Questions à répondre:**
- Quelles sont les limitations du mode rootless ?
- Comment gérer les ports < 1024 ?
- Quels sont les avantages de sécurité ?

### Exercice 2: Capabilities Linux et Least Privilege (⭐⭐⭐⭐⭐)

**Objectif:** Comprendre et gérer finement les capabilities Linux au lieu d'utiliser --privileged.

**Tâches:**

1. **Analyse des capabilities:**
   - Lister les capabilities par défaut d'un conteneur
   - Comprendre chaque capability

2. **Créer des profils personnalisés:**
   - Application web (HTTP server) - capabilities minimales
   - Application nécessitant ping (CAP_NET_RAW)
   - Application nécessitant bind sur port 80 (CAP_NET_BIND_SERVICE)

3. **Anti-pattern à éviter:**
   ```bash
   # ❌ NE JAMAIS FAIRE ÇA EN PRODUCTION
   docker run --privileged app
   ```

4. **Bonne pratique:**
   ```bash
   # ✅ Ajouter uniquement les capabilities nécessaires
   docker run --cap-drop=ALL --cap-add=NET_BIND_SERVICE app
   ```

**Fichiers à créer:**
- `configs/minimal-caps.json` - Profil de capabilities minimal
- `configs/web-server-caps.json` - Profil pour serveur web
- `app/capability-test/` - Application de test

**Critères de validation:**
- ✅ Compréhension de toutes les capabilities par défaut
- ✅ Application fonctionne avec capabilities minimales
- ✅ Documentation de chaque capability utilisée
- ✅ Aucun usage de --privileged

**Capabilities importantes à connaître:**
```
CAP_NET_BIND_SERVICE - Bind sur ports < 1024
CAP_NET_RAW          - Utiliser RAW et PACKET sockets (ping)
CAP_SYS_ADMIN        - Administration système (DANGEREUX)
CAP_SYS_TIME         - Modifier l'horloge système
CAP_CHOWN            - Changer ownership des fichiers
CAP_DAC_OVERRIDE     - Bypass des permissions fichiers
CAP_KILL             - Envoyer des signaux
CAP_SETUID/SETGID    - Changer UID/GID
```

### Exercice 3: Seccomp Profiles (⭐⭐⭐⭐⭐)

**Objectif:** Créer des profils Seccomp personnalisés pour restreindre les syscalls disponibles.

**Tâches:**

1. **Analyser le profil par défaut:**
   - Examiner le profil Seccomp par défaut de Docker
   - Comprendre les syscalls bloqués

2. **Créer un profil personnalisé strict:**
   ```json
   {
     "defaultAction": "SCMP_ACT_ERRNO",
     "architectures": ["SCMP_ARCH_X86_64"],
     "syscalls": [
       {
         "names": ["read", "write", "open", "close", "stat", ...],
         "action": "SCMP_ACT_ALLOW"
       }
     ]
   }
   ```

3. **Profils pour différents use cases:**
   - Profil ultra-strict pour application read-only
   - Profil pour application web standard
   - Profil bloquant les syscalls dangereux (ptrace, etc.)

4. **Test et debugging:**
   - Identifier les syscalls manquants
   - Logger les violations avec SCMP_ACT_LOG
   - Affiner le profil

**Fichiers à créer:**
- `configs/seccomp-strict.json` - Profil minimal
- `configs/seccomp-web.json` - Profil web app
- `configs/seccomp-readonly.json` - Profil read-only

**Critères de validation:**
- ✅ Profil Seccomp personnalisé fonctionne
- ✅ Application démarre avec profil strict
- ✅ Syscalls dangereux bloqués (ptrace, reboot, etc.)
- ✅ Profils documentés et commentés

**Syscalls à considérer bloquer:**
```
ptrace    - Debugging d'autres processus
reboot    - Reboot du système
mount     - Monter des filesystems
swapon    - Gérer la swap
kexec     - Changer de kernel
```

### Exercice 4: AppArmor / SELinux Profiles (⭐⭐⭐⭐)

**Objectif:** Créer des profils AppArmor ou SELinux pour MAC (Mandatory Access Control).

**Tâches:**

1. **Profil AppArmor pour application web:**
   ```
   # /etc/apparmor.d/docker-webapp
   #include <tunables/global>

   profile docker-webapp flags=(attach_disconnected,mediate_deleted) {
     #include <abstractions/base>

     # Autorise réseau
     network inet tcp,
     network inet udp,

     # Autorise lecture fichiers app
     /app/** r,

     # Interdit write sur /
     deny / w,

     # Logs uniquement
     /var/log/app/** rw,
   }
   ```

2. **Tester les profils:**
   - Charger le profil AppArmor
   - Lancer conteneur avec profil
   - Tester les restrictions

3. **Profils pour différents scénarios:**
   - Application read-only
   - Application avec logs
   - Application avec accès DB limité

**Fichiers à créer:**
- `configs/apparmor-webapp` - Profil web app
- `configs/apparmor-readonly` - Profil read-only strict
- Documentation des tests

**Critères de validation:**
- ✅ Profil AppArmor/SELinux chargé
- ✅ Conteneur utilise le profil
- ✅ Restrictions testées et validées
- ✅ Profil ne casse pas l'application

### Exercice 5: Image Scanning et Vulnerability Management (⭐⭐⭐⭐)

**Objectif:** Intégrer le scanning de vulnérabilités dans votre workflow.

**Tâches:**

1. **Configuration des outils:**
   - Trivy
   - Grype
   - Clair (optionnel)
   - Docker Scout

2. **Scan d'images:**
   ```bash
   # Scan avec Trivy
   trivy image --severity HIGH,CRITICAL myapp:latest

   # Scan avec Grype
   grype myapp:latest

   # Docker Scout
   docker scout cves myapp:latest
   ```

3. **Automatisation:**
   - Script de scan pre-commit
   - Intégration CI/CD
   - Politique de seuil (fail si CRITICAL)

4. **Remediation:**
   - Identifier les vulnérabilités
   - Mettre à jour les dépendances
   - Rebuild et re-scan

**Fichiers à créer:**
- `scripts/scan-image.sh` - Script de scan automatique
- `scripts/generate-sbom.sh` - Génération SBOM
- `.github/workflows/security-scan.yml` - CI workflow

**Critères de validation:**
- ✅ Scanning automatique des images
- ✅ Détection des vulnérabilités HIGH/CRITICAL
- ✅ SBOM (Software Bill of Materials) généré
- ✅ Pipeline CI échoue si vulnérabilités critiques

### Exercice 6: User Namespaces (⭐⭐⭐⭐)

**Objectif:** Configurer les User Namespaces pour remapper les UIDs.

**Tâches:**

1. **Configuration daemon:**
   ```json
   {
     "userns-remap": "default"
   }
   ```

2. **Comprendre le remapping:**
   - UID 0 dans le conteneur → UID 100000 sur l'hôte
   - Isolation des UIDs entre conteneurs

3. **Tests:**
   - Lancer conteneur avec user namespace
   - Vérifier les UIDs sur l'hôte
   - Tester l'isolation

**Critères de validation:**
- ✅ User namespaces activés
- ✅ UID root conteneur != UID root hôte
- ✅ Isolation vérifiée

### Exercice 7: Sécurisation du Daemon Docker (⭐⭐⭐⭐⭐)

**Objectif:** Sécuriser le daemon Docker et les communications.

**Tâches:**

1. **TLS pour API Docker:**
   ```bash
   # Générer certificats
   openssl genrsa -aes256 -out ca-key.pem 4096
   openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem
   # ... générer server cert et client cert
   ```

2. **Configuration daemon.json:**
   ```json
   {
     "tls": true,
     "tlscert": "/etc/docker/server-cert.pem",
     "tlskey": "/etc/docker/server-key.pem",
     "tlsverify": true,
     "tlscacert": "/etc/docker/ca.pem",
     "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2376"]
   }
   ```

3. **Autres configurations de sécurité:**
   ```json
   {
     "icc": false,
     "live-restore": true,
     "no-new-privileges": true,
     "userns-remap": "default"
   }
   ```

**Fichiers à créer:**
- `scripts/generate-certs.sh` - Génération certificats TLS
- `configs/daemon-secure.json` - Configuration sécurisée

**Critères de validation:**
- ✅ TLS activé et fonctionnel
- ✅ Connexion refuse sans certificat client
- ✅ Audit logging activé
- ✅ Configuration durcie

### Exercice 8: Read-only Containers et Immutability (⭐⭐⭐)

**Objectif:** Créer des conteneurs immuables et read-only.

**Tâches:**

1. **Conteneur read-only:**
   ```bash
   docker run --read-only \
     --tmpfs /tmp:rw,noexec,nosuid \
     --tmpfs /var/run:rw,noexec,nosuid \
     myapp
   ```

2. **Gérer les besoins d'écriture:**
   - tmpfs pour /tmp
   - volumes pour données persistantes
   - Application design pour immutability

**Critères de validation:**
- ✅ Filesystem root en read-only
- ✅ Application fonctionne normalement
- ✅ tmpfs correctement configurés

## 🧪 Tests

Script de validation automatique:

```bash
chmod +x test.sh
sudo ./test.sh  # Sudo nécessaire pour certains tests
```

Le script vérifie:
- Configuration rootless
- Capabilities correctement restreintes
- Profils Seccomp fonctionnels
- AppArmor/SELinux activés
- Scanning de vulnérabilités
- User namespaces
- TLS daemon
- Read-only containers

## 📊 Checklist de Sécurité Production

Avant de déployer en production, vérifiez:

**Images:**
- [ ] Images scannées pour vulnérabilités
- [ ] Pas de secrets dans les images
- [ ] Images signées (Docker Content Trust)
- [ ] Images basées sur minimal base (alpine/distroless)
- [ ] User non-root
- [ ] SBOM généré

**Runtime:**
- [ ] Daemon en mode rootless OU user namespaces activés
- [ ] Capabilities drop ALL + whitelist
- [ ] Profil Seccomp personnalisé
- [ ] AppArmor/SELinux enforced
- [ ] Read-only filesystem quand possible
- [ ] No new privileges
- [ ] Resource limits (CPU, memory)
- [ ] PIDs limit

**Network:**
- [ ] Network isolation
- [ ] TLS pour communications
- [ ] Pas d'exposition inutile de ports
- [ ] Firewall rules

**Daemon:**
- [ ] TLS avec vérification client
- [ ] Audit logging activé
- [ ] No inter-container communication par défaut
- [ ] Live restore activé
- [ ] Authorization plugins si nécessaire

**Monitoring:**
- [ ] Logs centralisés
- [ ] Alertes sur comportements anormaux
- [ ] Scan régulier des images en cours d'exécution
- [ ] Audit des accès

## 💡 Points Clés de Sécurité

### Defense in Depth (Défense en profondeur)

Appliquez plusieurs couches de sécurité:
1. **Image Layer:** Scan, minimal base, no secrets
2. **Runtime Layer:** Capabilities, seccomp, AppArmor
3. **Isolation Layer:** User namespaces, network isolation
4. **Host Layer:** Rootless, TLS, hardened kernel
5. **Monitoring Layer:** Logs, alerts, audit

### Principe du Moindre Privilège

```bash
# ❌ MAUVAIS - Trop de privilèges
docker run --privileged --cap-add=ALL app

# ✅ BON - Privilèges minimaux
docker run \
  --read-only \
  --cap-drop=ALL \
  --cap-add=NET_BIND_SERVICE \
  --security-opt=no-new-privileges \
  --security-opt=seccomp=seccomp-profile.json \
  --user 1000:1000 \
  app
```

### Matrice de Risques

| Menace | Mitigation | Priorité |
|--------|-----------|----------|
| Container escape | Seccomp, AppArmor, User NS | CRITIQUE |
| Privilege escalation | Drop capabilities, no-new-privileges | CRITIQUE |
| Malicious images | Image scanning, Content Trust | HAUTE |
| Daemon compromise | Rootless, TLS, Audit | HAUTE |
| Resource exhaustion | Limits, quotas | MOYENNE |
| Network attacks | Network policies, isolation | MOYENNE |

## 📖 Ressources

- [Docker Security](https://docs.docker.com/engine/security/)
- [Seccomp](https://docs.docker.com/engine/security/seccomp/)
- [AppArmor](https://docs.docker.com/engine/security/apparmor/)
- [Capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)
- [NIST Application Container Security Guide](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-190.pdf)

## 🎓 Pour aller plus loin

- Implémenter Falco pour runtime security
- Configurer un registry avec Notary (Content Trust)
- Mettre en place des admission controllers (OPA)
- Audit complet avec docker-bench-security
- Implémenter un WAF devant vos conteneurs

---

[← TP3: Storage](../tp3-storage-volumes/README.md) | [TP5: Docker Compose Avancé →](../tp5-compose-orchestration/README.md)
