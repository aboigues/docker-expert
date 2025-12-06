# Docker Expert - Série de Travaux Pratiques

Cette série de TPs vous permettra de maîtriser Docker au niveau expert. Chaque TP est conçu pour être progressif, testable et couvre des aspects avancés de Docker en production.

## 📋 Prérequis

- Docker Engine 24.0+ installé
- Docker Compose v2+
- Connaissances solides de Docker (niveau intermédiaire)
- Linux/Unix shell
- Git

## 🎯 Objectifs pédagogiques

À l'issue de cette formation, vous serez capable de :
- Optimiser drastiquement la taille et les performances des images Docker
- Maîtriser le networking avancé et créer des architectures complexes
- Implémenter des stratégies de sécurité Docker en production
- Débugger et monitorer des conteneurs en profondeur
- Mettre en place des pipelines CI/CD avec Docker
- Utiliser BuildKit pour des builds avancés

## 📚 Liste des TPs

### [TP1: Multi-stage Builds et Optimisation d'Images](./tp1-multistage-optimization/README.md)
**Durée estimée:** 3-4h
**Niveau:** Expert
**Objectifs:**
- Maîtriser les multi-stage builds complexes
- Réduire la taille des images de 80%+
- Utiliser les cache mounts et build secrets
- Créer des images reproductibles avec lock files

### [TP2: Networking Avancé et Service Mesh](./tp2-networking-advanced/README.md)
**Durée estimée:** 4-5h
**Niveau:** Expert
**Objectifs:**
- Créer et gérer des réseaux overlay et macvlan
- Implémenter un service mesh avec Traefik
- Configurer un load balancer personnalisé
- Résoudre des problèmes de DNS et routing

### [TP3: Volumes, Bind Mounts et Storage Drivers](./tp3-storage-volumes/README.md)
**Durée estimée:** 3-4h
**Niveau:** Expert
**Objectifs:**
- Comprendre les storage drivers (overlay2, btrfs, zfs)
- Optimiser les performances I/O
- Gérer la persistance de données complexe
- Implémenter des backups automatisés

### [TP4: Sécurité Docker Avancée](./tp4-security-advanced/README.md)
**Durée estimée:** 4-5h
**Niveau:** Expert
**Objectifs:**
- Configurer Docker rootless
- Maîtriser AppArmor, SELinux et Seccomp
- Implémenter le scanning de vulnérabilités
- Utiliser les capabilities Linux finement

### [TP5: Docker Compose Avancé et Orchestration](./tp5-compose-orchestration/README.md)
**Durée estimée:** 4h
**Niveau:** Expert
**Objectifs:**
- Créer des stacks complexes multi-environnements
- Gérer les dépendances et health checks
- Implémenter des patterns de déploiement
- Utiliser les configs et secrets

### [TP6: Monitoring, Logging et Debugging](./tp6-monitoring-debugging/README.md)
**Durée estimée:** 4-5h
**Niveau:** Expert
**Objectifs:**
- Mettre en place une stack Prometheus + Grafana
- Centraliser les logs avec ELK/Loki
- Debugger des conteneurs en production
- Analyser les métriques de performance

### [TP7: BuildKit et Build Avancé](./tp7-buildkit-advanced/README.md)
**Durée estimée:** 3-4h
**Niveau:** Expert
**Objectifs:**
- Maîtriser BuildKit et ses features avancées
- Utiliser les build contexts multiples
- Créer des builds cross-platform
- Optimiser le cache et les builds parallèles

### [TP8: CI/CD et Registry Privé](./tp8-cicd-registry/README.md)
**Durée estimée:** 4-5h
**Niveau:** Expert
**Objectifs:**
- Déployer et sécuriser un registry privé
- Créer des pipelines CI/CD avec GitHub Actions
- Implémenter le versioning et tagging
- Mettre en place un workflow GitOps

## 🧪 Tests et Validation

Chaque TP contient :
- Un script `test.sh` pour valider automatiquement votre travail
- Des critères de validation précis
- Des solutions commentées dans le dossier `solutions/`

Pour exécuter les tests d'un TP :
```bash
cd tpX-nom-du-tp
chmod +x test.sh
./test.sh
```

## 🚀 Comment utiliser ce repository

1. **Suivre l'ordre des TPs** : Ils sont progressifs
2. **Lire le README de chaque TP** avant de commencer
3. **Essayer sans regarder les solutions** d'abord
4. **Exécuter les tests** pour valider votre travail
5. **Comparer avec les solutions** pour optimiser

## 📖 Ressources complémentaires

- [Documentation officielle Docker](https://docs.docker.com/)
- [Best practices Docker](https://docs.docker.com/develop/dev-best-practices/)
- [Docker Security](https://docs.docker.com/engine/security/)
- [BuildKit Documentation](https://github.com/moby/buildkit)

## 🤝 Contribution

Les contributions sont bienvenues ! N'hésitez pas à :
- Signaler des bugs
- Proposer des améliorations
- Ajouter de nouveaux TPs

## 📝 Licence

MIT License - Libre d'utilisation pour l'apprentissage

---

**Bonne formation ! 🐳**
