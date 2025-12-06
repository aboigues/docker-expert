#!/bin/bash

# Script de génération de certificats TLS pour sécuriser le daemon Docker
# Basé sur: https://docs.docker.com/engine/security/protect-access/

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Configuration
HOST="${1:-localhost}"
CERT_DIR="${2:-./certs}"
DAYS=365

print_info "Generating TLS certificates for Docker daemon"
print_info "Host: $HOST"
print_info "Certificate directory: $CERT_DIR"
print_info "Validity: $DAYS days"
echo ""

# Create directory
mkdir -p "$CERT_DIR"
cd "$CERT_DIR"

# ============================================
# 1. Generate CA private key and certificate
# ============================================
print_info "Step 1/6: Generating CA private key..."
openssl genrsa -aes256 -passout pass:changeme -out ca-key.pem 4096
print_success "CA private key generated: ca-key.pem"

print_info "Step 2/6: Generating CA certificate..."
openssl req -new -x509 -days $DAYS -key ca-key.pem -passin pass:changeme \
    -sha256 -out ca.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=Docker/CN=Docker CA"
print_success "CA certificate generated: ca.pem"

# ============================================
# 2. Generate server key and certificate
# ============================================
print_info "Step 3/6: Generating server private key..."
openssl genrsa -out server-key.pem 4096
print_success "Server private key generated: server-key.pem"

print_info "Step 4/6: Generating server certificate signing request..."
openssl req -subj "/CN=$HOST" -sha256 -new -key server-key.pem -out server.csr
print_success "Server CSR generated: server.csr"

print_info "Generating server certificate..."

# Create extfile for SANs
cat > extfile.cnf <<EOF
subjectAltName = DNS:$HOST,DNS:localhost,IP:127.0.0.1,IP:0.0.0.0
extendedKeyUsage = serverAuth
EOF

openssl x509 -req -days $DAYS -sha256 \
    -in server.csr -CA ca.pem -CAkey ca-key.pem -passin pass:changeme \
    -CAcreateserial -out server-cert.pem \
    -extfile extfile.cnf

print_success "Server certificate generated: server-cert.pem"

# ============================================
# 3. Generate client key and certificate
# ============================================
print_info "Step 5/6: Generating client private key..."
openssl genrsa -out key.pem 4096
print_success "Client private key generated: key.pem"

print_info "Step 6/6: Generating client certificate..."
openssl req -subj '/CN=client' -new -key key.pem -out client.csr

# Create extfile for client
cat > extfile-client.cnf <<EOF
extendedKeyUsage = clientAuth
EOF

openssl x509 -req -days $DAYS -sha256 \
    -in client.csr -CA ca.pem -CAkey ca-key.pem -passin pass:changeme \
    -CAcreateserial -out cert.pem \
    -extfile extfile-client.cnf

print_success "Client certificate generated: cert.pem"

# ============================================
# 4. Clean up and set permissions
# ============================================
print_info "Cleaning up temporary files..."
rm -f client.csr server.csr extfile.cnf extfile-client.cnf ca.srl

print_info "Setting proper permissions..."
chmod -v 0400 ca-key.pem key.pem server-key.pem
chmod -v 0444 ca.pem server-cert.pem cert.pem

print_success "Permissions set"

# ============================================
# 5. Summary
# ============================================
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}TLS Certificates Generated Successfully${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Certificate directory: $(pwd)"
echo ""
echo "Files generated:"
echo "  CA:"
echo "    - ca.pem (CA certificate)"
echo "    - ca-key.pem (CA private key) [KEEP SECURE]"
echo ""
echo "  Server:"
echo "    - server-cert.pem (Server certificate)"
echo "    - server-key.pem (Server private key) [KEEP SECURE]"
echo ""
echo "  Client:"
echo "    - cert.pem (Client certificate)"
echo "    - key.pem (Client private key) [KEEP SECURE]"
echo ""
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Next Steps${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""
echo "1. Configure Docker daemon (/etc/docker/daemon.json):"
echo ""
cat <<'EOF'
{
  "tls": true,
  "tlscert": "/path/to/certs/server-cert.pem",
  "tlskey": "/path/to/certs/server-key.pem",
  "tlsverify": true,
  "tlscacert": "/path/to/certs/ca.pem",
  "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2376"]
}
EOF
echo ""
echo "2. Copy server certificates to Docker daemon location:"
echo "   sudo cp ca.pem server-cert.pem server-key.pem /etc/docker/"
echo ""
echo "3. Restart Docker daemon:"
echo "   sudo systemctl restart docker"
echo ""
echo "4. Use client certificates to connect:"
echo "   docker --tlsverify --tlscacert=ca.pem --tlscert=cert.pem --tlskey=key.pem -H=$HOST:2376 version"
echo ""
echo "5. Or set environment variables:"
echo "   export DOCKER_HOST=tcp://$HOST:2376"
echo "   export DOCKER_TLS_VERIFY=1"
echo "   export DOCKER_CERT_PATH=$(pwd)"
echo "   docker version"
echo ""
print_warning "Keep private keys (ca-key.pem, server-key.pem, key.pem) secure!"
print_warning "Do not commit them to version control!"
echo ""
print_success "Setup complete!"
