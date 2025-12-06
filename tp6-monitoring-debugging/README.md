# TP6: Monitoring, Logging et Debugging

## 🎯 Objectifs

- Mettre en place Prometheus + Grafana pour monitoring
- Centraliser les logs avec ELK ou Loki
- Maîtriser les outils de debugging avancés
- Analyser les métriques de performance
- Tracer et profiler les applications conteneurisées

## 📚 Exercices

### Exercice 1: Stack Prometheus + Grafana (⭐⭐⭐⭐⭐)

**docker-compose-monitoring.yml:**
```yaml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=30d'
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana:latest
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    volumes:
      - grafana-data:/var/lib/grafana
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./grafana/datasources:/etc/grafana/provisioning/datasources
    ports:
      - "3000:3000"
    depends_on:
      - prometheus

  node-exporter:
    image: prom/node-exporter:latest
    command:
      - '--path.rootfs=/host'
    volumes:
      - /:/host:ro,rslave
    ports:
      - "9100:9100"

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    ports:
      - "8080:8080"
    privileged: true

  alertmanager:
    image: prom/alertmanager:latest
    command:
      - '--config.file=/etc/alertmanager/config.yml'
    volumes:
      - ./alertmanager.yml:/etc/alertmanager/config.yml
    ports:
      - "9093:9093"

volumes:
  prometheus-data:
  grafana-data:
```

**prometheus.yml:**
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']

rule_files:
  - "alerts.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  - job_name: 'docker'
    static_configs:
      - targets: ['host.docker.internal:9323']
```

**Critères:**
- ✅ Prometheus collecte les métriques
- ✅ Grafana affiche dashboards
- ✅ Alertes configurées
- ✅ Métriques conteneurs via cAdvisor

### Exercice 2: Logging avec Loki + Promtail (⭐⭐⭐⭐)

**docker-compose-logging.yml:**
```yaml
services:
  loki:
    image: grafana/loki:latest
    command: -config.file=/etc/loki/local-config.yaml
    ports:
      - "3100:3100"
    volumes:
      - loki-data:/loki

  promtail:
    image: grafana/promtail:latest
    command: -config.file=/etc/promtail/config.yml
    volumes:
      - /var/log:/var/log:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - ./promtail-config.yml:/etc/promtail/config.yml
    depends_on:
      - loki

  app:
    image: myapp
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
        labels: "app,env"
        tag: "{{.Name}}/{{.ID}}"
    labels:
      logging: "promtail"
      env: "production"
```

**promtail-config.yml:**
```yaml
server:
  http_listen_port: 9080

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  - job_name: docker
    docker_sd_configs:
      - host: unix:///var/run/docker.sock
    relabel_configs:
      - source_labels: ['__meta_docker_container_name']
        target_label: 'container'
      - source_labels: ['__meta_docker_container_label_logging']
        target_label: 'job'
```

**Critères:**
- ✅ Logs centralisés dans Loki
- ✅ Recherche et filtrage fonctionnels
- ✅ Labels correctement propagés
- ✅ Rétention configurée

### Exercice 3: Debugging Avancé (⭐⭐⭐⭐⭐)

**Techniques de debugging:**

**1. Attach à un conteneur running:**
```bash
# Shell dans conteneur
docker exec -it container bash

# Avec outils de debug
docker run -it --pid=container:target --net=container:target \
  --cap-add sys_admin nicolaka/netshoot

# Debug avec nsenter
docker run -it --rm --privileged --pid=host \
  debian nsenter -t 1 -m -u -n -i sh
```

**2. Inspect et logs:**
```bash
# Logs en temps réel
docker logs -f --tail=100 container

# Inspect détaillé
docker inspect container | jq '.[0].State'

# Stats en temps réel
docker stats --no-stream

# Top des processus
docker top container
```

**3. Debug network:**
```bash
# Capture packets
docker run --rm --net=container:target \
  nicolaka/netshoot tcpdump -i any -w /tmp/capture.pcap

# Test connectivité
docker run --rm --net=container:target \
  nicolaka/netshoot curl -v http://api:8080
```

**4. Debug filesystem:**
```bash
# Diff des fichiers modifiés
docker diff container

# Export filesystem
docker export container > container.tar

# Commit pour analyse
docker commit container debug-image
docker run -it debug-image bash
```

**5. Profiling et tracing:**
```bash
# strace dans conteneur
docker run --cap-add=SYS_PTRACE --pid=container:target \
  alpine strace -p 1

# Performance profiling
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

**Critères:**
- ✅ Maîtrise de docker exec et attach
- ✅ Utilisation de nicolaka/netshoot
- ✅ Capture réseau fonctionnelle
- ✅ Profiling actif

### Exercice 4: Distributed Tracing avec Jaeger (⭐⭐⭐⭐⭐)

```yaml
services:
  jaeger:
    image: jaegertracing/all-in-one:latest
    environment:
      - COLLECTOR_ZIPKIN_HOST_PORT=:9411
    ports:
      - "5775:5775/udp"
      - "6831:6831/udp"
      - "6832:6832/udp"
      - "5778:5778"
      - "16686:16686"
      - "14268:14268"
      - "14250:14250"
      - "9411:9411"

  app:
    image: myapp
    environment:
      - JAEGER_AGENT_HOST=jaeger
      - JAEGER_AGENT_PORT=6831
```

**Dans l'application (Node.js):**
```javascript
const { initTracer } = require('jaeger-client');

const config = {
  serviceName: 'my-app',
  sampler: { type: 'const', param: 1 },
  reporter: {
    agentHost: process.env.JAEGER_AGENT_HOST,
    agentPort: process.env.JAEGER_AGENT_PORT
  }
};

const tracer = initTracer(config);

// Trace une opération
const span = tracer.startSpan('database_query');
span.setTag('query', 'SELECT * FROM users');
// ... exécuter query ...
span.finish();
```

**Critères:**
- ✅ Traces collectées
- ✅ Timeline des requêtes visible
- ✅ Latency identifiée
- ✅ Dépendances services mappées

### Exercice 5: Alerting avec Alertmanager (⭐⭐⭐⭐)

**alerts.yml:**
```yaml
groups:
  - name: containers
    interval: 10s
    rules:
      - alert: ContainerDown
        expr: absent(container_last_seen{name=~".+"})
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Container {{ $labels.name }} is down"

      - alert: HighMemoryUsage
        expr: |
          (container_memory_usage_bytes / container_spec_memory_limit_bytes) > 0.9
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage on {{ $labels.name }}"
          description: "Memory usage is {{ $value | humanizePercentage }}"

      - alert: HighCPUUsage
        expr: |
          rate(container_cpu_usage_seconds_total[5m]) > 0.8
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU on {{ $labels.name }}"
```

**alertmanager.yml:**
```yaml
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname', 'cluster']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  receiver: 'slack'

receivers:
  - name: 'slack'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/XXX'
        channel: '#alerts'
        title: 'Alert: {{ .GroupLabels.alertname }}'
        text: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'
```

**Critères:**
- ✅ Alertes déclenchées correctement
- ✅ Notifications envoyées (Slack/Email)
- ✅ Groupement et throttling actifs
- ✅ Alertes résolues automatiquement

### Exercice 6: Health Checks et Readiness (⭐⭐⭐⭐)

**Dockerfile avec health check:**
```dockerfile
FROM node:20-alpine

WORKDIR /app
COPY . .

RUN npm ci --only=production

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js

CMD ["node", "index.js"]
```

**healthcheck.js:**
```javascript
const http = require('http');

const options = {
  host: 'localhost',
  port: 3000,
  path: '/health',
  timeout: 2000
};

const req = http.request(options, (res) => {
  console.log(`STATUS: ${res.statusCode}`);
  process.exit(res.statusCode === 200 ? 0 : 1);
});

req.on('error', (err) => {
  console.error('ERROR:', err);
  process.exit(1);
});

req.end();
```

**Endpoint /health:**
```javascript
app.get('/health', async (req, res) => {
  const checks = {
    uptime: process.uptime(),
    message: 'OK',
    timestamp: Date.now()
  };

  try {
    // Check database
    await db.ping();
    checks.database = 'OK';

    // Check redis
    await redis.ping();
    checks.redis = 'OK';

    res.status(200).json(checks);
  } catch (error) {
    checks.message = error.message;
    res.status(503).json(checks);
  }
});
```

**Critères:**
- ✅ Health check comprehensive
- ✅ Dépendances externes testées
- ✅ Timeout approprié
- ✅ Logs des failures

## 🧪 Dashboards Grafana Recommandés

1. **Docker Container Metrics** (ID: 193)
2. **Node Exporter Full** (ID: 1860)
3. **Loki Dashboard** (ID: 13639)
4. **Traefik** (ID: 11462)

## 🎓 Best Practices

1. **Metrics:** Collecter au moins CPU, Memory, Disk, Network
2. **Logs:** Structured logging (JSON)
3. **Traces:** Distributed tracing pour microservices
4. **Alerts:** Actionables seulement
5. **Dashboards:** Un par service
6. **Retention:** 30 jours minimum
7. **Health Checks:** Tester dépendances critiques

---

[← TP5: Compose](../tp5-compose-orchestration/README.md) | [TP7: BuildKit →](../tp7-buildkit-advanced/README.md)
