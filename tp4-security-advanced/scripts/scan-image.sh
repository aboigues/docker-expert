#!/bin/bash

# Script de scan de sécurité pour images Docker
# Utilise plusieurs outils pour une analyse complète

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
IMAGE_NAME="${1}"
SEVERITY_THRESHOLD="${2:-CRITICAL,HIGH}"
FAIL_ON_CRITICAL="${3:-true}"

if [ -z "$IMAGE_NAME" ]; then
    echo -e "${RED}Usage: $0 <image-name> [severity-threshold] [fail-on-critical]${NC}"
    echo "Example: $0 myapp:latest CRITICAL,HIGH true"
    exit 1
fi

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if image exists
if ! docker image inspect "$IMAGE_NAME" &>/dev/null; then
    print_error "Image $IMAGE_NAME not found"
    exit 1
fi

print_header "Security Scan for: $IMAGE_NAME"

# Variables pour tracking
HAS_CRITICAL=0
HAS_HIGH=0
SCAN_FAILED=0

# ============================================
# 1. Trivy Scan
# ============================================
print_header "1. Trivy Vulnerability Scan"

if command -v trivy &>/dev/null; then
    print_info "Scanning with Trivy..."

    # Scan for vulnerabilities
    if trivy image --severity "$SEVERITY_THRESHOLD" --exit-code 0 "$IMAGE_NAME"; then
        print_success "Trivy scan completed"
    else
        print_warning "Trivy found vulnerabilities"
    fi

    # Check for CRITICAL
    if trivy image --severity CRITICAL --exit-code 1 "$IMAGE_NAME" &>/dev/null; then
        print_success "No CRITICAL vulnerabilities found"
    else
        print_error "CRITICAL vulnerabilities found!"
        HAS_CRITICAL=1
    fi

    # Generate JSON report
    print_info "Generating JSON report..."
    trivy image --format json --output trivy-report.json "$IMAGE_NAME"
    print_success "Report saved to: trivy-report.json"

    # Generate SBOM
    print_info "Generating SBOM..."
    trivy image --format cyclonedx --output sbom.json "$IMAGE_NAME"
    print_success "SBOM saved to: sbom.json"

else
    print_warning "Trivy not installed. Install with: curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin"
    SCAN_FAILED=1
fi

# ============================================
# 2. Grype Scan
# ============================================
print_header "2. Grype Vulnerability Scan"

if command -v grype &>/dev/null; then
    print_info "Scanning with Grype..."

    if grype "$IMAGE_NAME" -o json > grype-report.json 2>&1; then
        print_success "Grype scan completed"

        # Count vulnerabilities
        CRITICAL_COUNT=$(jq '[.matches[] | select(.vulnerability.severity=="Critical")] | length' grype-report.json 2>/dev/null || echo "0")
        HIGH_COUNT=$(jq '[.matches[] | select(.vulnerability.severity=="High")] | length' grype-report.json 2>/dev/null || echo "0")

        print_info "CRITICAL: $CRITICAL_COUNT, HIGH: $HIGH_COUNT"

        if [ "$CRITICAL_COUNT" -gt 0 ]; then
            HAS_CRITICAL=1
        fi
        if [ "$HIGH_COUNT" -gt 0 ]; then
            HAS_HIGH=1
        fi
    else
        print_warning "Grype scan failed"
    fi
else
    print_warning "Grype not installed. Install with: curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin"
fi

# ============================================
# 3. Docker Scout (if available)
# ============================================
print_header "3. Docker Scout Scan"

if docker scout version &>/dev/null; then
    print_info "Scanning with Docker Scout..."

    if docker scout cves "$IMAGE_NAME" 2>&1 | tee scout-report.txt; then
        print_success "Docker Scout scan completed"
    else
        print_warning "Docker Scout scan had issues"
    fi
else
    print_info "Docker Scout not available (requires Docker Desktop or Scout CLI)"
fi

# ============================================
# 4. Image Configuration Analysis
# ============================================
print_header "4. Image Security Configuration"

print_info "Analyzing image configuration..."

# Check if running as root
USER=$(docker image inspect "$IMAGE_NAME" --format='{{.Config.User}}' 2>/dev/null || echo "")
if [ -z "$USER" ] || [ "$USER" = "0" ] || [ "$USER" = "root" ]; then
    print_error "Image runs as ROOT (security risk)"
else
    print_success "Image runs as non-root user: $USER"
fi

# Check for health check
HEALTHCHECK=$(docker image inspect "$IMAGE_NAME" --format='{{.Config.Healthcheck}}' 2>/dev/null || echo "")
if [ "$HEALTHCHECK" = "<nil>" ] || [ -z "$HEALTHCHECK" ]; then
    print_warning "No HEALTHCHECK defined"
else
    print_success "HEALTHCHECK defined"
fi

# Check image size
SIZE=$(docker image inspect "$IMAGE_NAME" --format='{{.Size}}' 2>/dev/null || echo "0")
SIZE_MB=$((SIZE / 1048576))
if [ $SIZE_MB -gt 500 ]; then
    print_warning "Large image size: ${SIZE_MB}MB (consider optimization)"
elif [ $SIZE_MB -gt 200 ]; then
    print_info "Image size: ${SIZE_MB}MB"
else
    print_success "Optimized image size: ${SIZE_MB}MB"
fi

# Check number of layers
LAYERS=$(docker image inspect "$IMAGE_NAME" --format='{{len .RootFS.Layers}}' 2>/dev/null || echo "0")
if [ "$LAYERS" -gt 50 ]; then
    print_warning "Many layers: $LAYERS (consider squashing)"
else
    print_success "Layer count: $LAYERS"
fi

# ============================================
# 5. Secret Detection
# ============================================
print_header "5. Secret Detection"

print_info "Scanning for exposed secrets..."

# Common secret patterns
PATTERNS=(
    "password"
    "secret"
    "token"
    "api[_-]?key"
    "private[_-]?key"
    "aws[_-]?access"
    "-----BEGIN RSA PRIVATE KEY-----"
    "-----BEGIN PRIVATE KEY-----"
)

SECRETS_FOUND=0

# Export image and search
TEMP_DIR=$(mktemp -d)
docker save "$IMAGE_NAME" | tar -xC "$TEMP_DIR" 2>/dev/null

for pattern in "${PATTERNS[@]}"; do
    if grep -r -i -E "$pattern" "$TEMP_DIR" 2>/dev/null | grep -v "Binary" | head -5; then
        print_error "Potential secret found: $pattern"
        SECRETS_FOUND=1
    fi
done

rm -rf "$TEMP_DIR"

if [ $SECRETS_FOUND -eq 0 ]; then
    print_success "No obvious secrets detected in image"
fi

# ============================================
# 6. Dockerfile Best Practices (if Dockerfile available)
# ============================================
print_header "6. Dockerfile Best Practices"

if [ -f "Dockerfile" ]; then
    print_info "Analyzing Dockerfile..."

    # Check for COPY --chown
    if grep -q "COPY --chown" Dockerfile; then
        print_success "Uses COPY --chown for proper ownership"
    else
        print_warning "Consider using COPY --chown"
    fi

    # Check for .dockerignore
    if [ -f ".dockerignore" ]; then
        print_success ".dockerignore present"
    else
        print_warning ".dockerignore missing"
    fi

    # Check for specific base image version
    if grep -E "^FROM.*:latest" Dockerfile; then
        print_error "Using :latest tag (not reproducible)"
    else
        print_success "Using pinned base image version"
    fi

else
    print_info "Dockerfile not found in current directory"
fi

# ============================================
# Summary
# ============================================
print_header "Scan Summary"

echo "Image: $IMAGE_NAME"
echo "Size: ${SIZE_MB}MB"
echo "Layers: $LAYERS"
echo "User: ${USER:-root}"
echo ""

if [ $HAS_CRITICAL -eq 1 ]; then
    print_error "CRITICAL vulnerabilities found!"
    if [ "$FAIL_ON_CRITICAL" = "true" ]; then
        echo ""
        print_error "Build FAILED due to critical vulnerabilities"
        echo ""
        echo "Remediation steps:"
        echo "1. Review vulnerability reports: trivy-report.json, grype-report.json"
        echo "2. Update base image and dependencies"
        echo "3. Rebuild and rescan"
        exit 1
    fi
fi

if [ $HAS_HIGH -eq 1 ]; then
    print_warning "HIGH severity vulnerabilities found"
fi

if [ $HAS_CRITICAL -eq 0 ] && [ $HAS_HIGH -eq 0 ]; then
    print_success "No critical or high vulnerabilities found!"
fi

print_success "Scan completed successfully!"

echo ""
echo "Generated files:"
echo "  - trivy-report.json"
echo "  - sbom.json"
if [ -f "grype-report.json" ]; then
    echo "  - grype-report.json"
fi
if [ -f "scout-report.txt" ]; then
    echo "  - scout-report.txt"
fi

exit 0
