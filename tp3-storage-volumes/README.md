# TP3: Volumes, Storage et Persistence

## 🎯 Objectifs

- Maîtriser les volumes, bind mounts et tmpfs
- Comprendre les storage drivers (overlay2, btrfs, zfs)
- Optimiser les performances I/O
- Implémenter des stratégies de backup
- Gérer la persistance de données en production

## 📚 Exercices

### Exercice 1: Volumes vs Bind Mounts vs Tmpfs (⭐⭐⭐)

Comparez les trois types de montage:

**1. Volume (Recommandé):**
```bash
docker volume create mydata
docker run -v mydata:/data app
```

**2. Bind Mount:**
```bash
docker run -v $(pwd)/data:/data app
```

**3. Tmpfs (RAM, non persistant):**
```bash
docker run --tmpfs /tmp:rw,noexec,nosuid,size=100m app
```

**Tâches:**
- Créer un volume et tester la persistance
- Utiliser bind mount pour développement
- Configurer tmpfs pour données temporaires
- Benchmarker les performances I/O

**Critères:**
- ✅ Données persistent après suppression conteneur (volume)
- ✅ Modifications locales visibles dans conteneur (bind mount)
- ✅ Tmpfs plus rapide que volume
- ✅ Tmpfs limité en taille

### Exercice 2: Volume Drivers et Plugins (⭐⭐⭐⭐)

Explorez les drivers de volume:

**Local driver avec options:**
```bash
docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.1.1,rw \
  --opt device=:/path/to/share \
  nfs-volume
```

**Driver NFS:**
```yaml
volumes:
  nfs-data:
    driver: local
    driver_opts:
      type: nfs
      o: addr=nfs-server,rw
      device: ":/export/data"
```

**Critères:**
- ✅ NFS volume configuré
- ✅ Données accessibles depuis plusieurs hôtes
- ✅ Performance acceptable

### Exercice 3: Storage Drivers - Overlay2, Btrfs, ZFS (⭐⭐⭐⭐⭐)

Comparez les storage drivers:

**Overlay2 (Default, Recommandé):**
- Performant
- Copy-on-write efficace
- Support le plus large

**Btrfs:**
- Snapshots natifs
- Compression
- Copy-on-write avancé

**ZFS:**
- Intégrité données maximale
- Snapshots et clones
- Déduplication

**Tâches:**
```bash
# Vérifier driver actuel
docker info | grep "Storage Driver"

# Benchmarker
docker run --rm -v mydata:/data alpine \
  dd if=/dev/zero of=/data/test bs=1M count=1000
```

**Critères:**
- ✅ Comprendre les différences
- ✅ Benchmark de chaque driver
- ✅ Choisir le bon driver selon use case

### Exercice 4: Optimisation Performances I/O (⭐⭐⭐⭐⭐)

Optimisez les performances:

**1. Volume options:**
```yaml
volumes:
  db-data:
    driver: local
    driver_opts:
      type: none
      device: /mnt/ssd/db
      o: bind
```

**2. Mount options pour performance:**
```bash
docker run -v data:/data:rw,Z \
  --mount type=tmpfs,destination=/tmp,tmpfs-size=1g,tmpfs-mode=1777 \
  --storage-opt size=50G \
  app
```

**3. Benchmark avec fio:**
```bash
docker run --rm -v data:/data \
  ubuntu fio --name=random-read --ioengine=libaio \
  --rw=randread --bs=4k --size=1G \
  --filename=/data/test
```

**Critères:**
- ✅ IOPS > 10k pour random read
- ✅ Latency < 1ms
- ✅ SSD utilisé pour DB volumes

### Exercice 5: Backup et Restore Automatisés (⭐⭐⭐⭐)

Implémentez une stratégie de backup:

**Script de backup:**
```bash
#!/bin/bash
# backup-volume.sh

VOLUME=$1
BACKUP_DIR=/backups
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

docker run --rm \
  -v $VOLUME:/source:ro \
  -v $BACKUP_DIR:/backup \
  alpine tar czf /backup/${VOLUME}-${TIMESTAMP}.tar.gz -C /source .

echo "Backup created: ${VOLUME}-${TIMESTAMP}.tar.gz"
```

**Restore:**
```bash
#!/bin/bash
# restore-volume.sh

VOLUME=$1
BACKUP_FILE=$2

docker run --rm \
  -v $VOLUME:/target \
  -v $(dirname $BACKUP_FILE):/backup \
  alpine tar xzf /backup/$(basename $BACKUP_FILE) -C /target

echo "Restored $BACKUP_FILE to $VOLUME"
```

**Critères:**
- ✅ Backup automatique quotidien
- ✅ Rotation (garder 7 jours)
- ✅ Restore testé et fonctionnel
- ✅ Backup versionnés

### Exercice 6: Volume Snapshots avec Btrfs/ZFS (⭐⭐⭐⭐⭐)

Utilisez les snapshots:

**Avec Btrfs:**
```bash
# Créer snapshot
btrfs subvolume snapshot /var/lib/docker/volumes/mydata/_data \
  /var/lib/docker/volumes/mydata-snapshot

# Restaurer
btrfs subvolume delete /var/lib/docker/volumes/mydata/_data
btrfs subvolume snapshot /var/lib/docker/volumes/mydata-snapshot \
  /var/lib/docker/volumes/mydata/_data
```

**Critères:**
- ✅ Snapshots créés instantanément
- ✅ Restore rapide
- ✅ Point-in-time recovery

### Exercice 7: Volume Cleanup et Maintenance (⭐⭐⭐)

Nettoyez les volumes orphelins:

```bash
# Lister volumes orphelins
docker volume ls -f dangling=true

# Supprimer volumes non utilisés
docker volume prune

# Trouver gros volumes
docker volume ls --format '{{.Name}}' | while read vol; do
  size=$(docker system df -v | grep $vol | awk '{print $3}')
  echo "$vol: $size"
done | sort -k2 -hr
```

**Critères:**
- ✅ Pas de volumes orphelins
- ✅ Script de cleanup automatique
- ✅ Alertes si volume > 80% plein

### Exercice 8: Database Volumes Best Practices (⭐⭐⭐⭐⭐)

Configuration optimale pour PostgreSQL:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15
    volumes:
      # Data sur SSD avec options optimisées
      - type: volume
        source: pg-data
        target: /var/lib/postgresql/data
        volume:
          nocopy: true
      # WAL sur volume séparé pour performance
      - type: volume
        source: pg-wal
        target: /var/lib/postgresql/wal
      # Tmpfs pour temp files
      - type: tmpfs
        target: /tmp
        tmpfs:
          size: 1073741824  # 1GB
    environment:
      POSTGRES_PASSWORD: secret
      PGDATA: /var/lib/postgresql/data/pgdata

volumes:
  pg-data:
    driver: local
    driver_opts:
      type: none
      device: /mnt/ssd/pgdata
      o: bind
  pg-wal:
    driver: local
    driver_opts:
      type: none
      device: /mnt/ssd/pgwal
      o: bind
```

**Critères:**
- ✅ Data et WAL séparés
- ✅ Tmpfs pour /tmp
- ✅ Backup automatique
- ✅ Performance optimale

## 🧪 Tests de Performance

```bash
# Test write performance
docker run --rm -v test:/data alpine \
  dd if=/dev/zero of=/data/test bs=1M count=1000 oflag=direct

# Test read performance
docker run --rm -v test:/data alpine \
  dd if=/data/test of=/dev/null bs=1M iflag=direct

# Fio benchmark complet
docker run --rm -v test:/data \
  --name=fio ubuntu \
  bash -c "apt-get update && apt-get install -y fio && \
  fio --name=randread --ioengine=libaio --rw=randread --bs=4k --size=1G --filename=/data/test"
```

## 📊 Comparaison des Options

| Type | Performance | Persistance | Partage | Use Case |
|------|-------------|-------------|---------|----------|
| Volume | ⭐⭐⭐⭐ | ✅ | Multi-container | Production DB |
| Bind Mount | ⭐⭐⭐ | ✅ | Host-container | Development |
| Tmpfs | ⭐⭐⭐⭐⭐ | ❌ | Non | Temp files |
| NFS | ⭐⭐ | ✅ | Multi-host | Shared data |

## 🎓 Best Practices

1. **Utilisez volumes** pour données de production
2. **Bind mounts** uniquement pour dev
3. **Tmpfs** pour temp files et secrets éphémères
4. **Séparez data et logs** sur volumes différents
5. **SSD pour DB**, HDD pour logs/backups
6. **Backup réguliers** avec tests de restore
7. **Monitoring** de l'espace disque
8. **Labels** pour organiser les volumes

---

[← TP2: Networking](../tp2-networking-advanced/README.md) | [TP4: Sécurité →](../tp4-security-advanced/README.md)
