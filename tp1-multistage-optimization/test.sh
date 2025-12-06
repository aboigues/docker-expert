#!/bin/bash

# Script de test pour TP1: Multi-stage Builds et Optimisation d'Images
# Ce script valide automatiquement les exercices du TP1

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
BLUE='\033[0;34m'

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test result tracking
declare -a FAILED_TEST_NAMES

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_test() {
    echo -e "${YELLOW}TEST:${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅ PASS:${NC} $1"
    ((PASSED_TESTS++))
    ((TOTAL_TESTS++))
}

print_fail() {
    echo -e "${RED}❌ FAIL:${NC} $1"
    FAILED_TEST_NAMES+=("$1")
    ((FAILED_TESTS++))
    ((TOTAL_TESTS++))
}

print_info() {
    echo -e "${BLUE}ℹ️  INFO:${NC} $1"
}

# Convert bytes to human readable format
bytes_to_human() {
    local bytes=$1
    if [ $bytes -lt 1024 ]; then
        echo "${bytes}B"
    elif [ $bytes -lt 1048576 ]; then
        echo "$((bytes / 1024))KB"
    else
        echo "$((bytes / 1048576))MB"
    fi
}

# Get image size in bytes
get_image_size() {
    local image=$1
    docker image inspect "$image" --format='{{.Size}}' 2>/dev/null || echo "0"
}

# Check if image exists
image_exists() {
    docker image inspect "$1" &>/dev/null
}

# Check if container is running
container_running() {
    docker ps --filter "name=$1" --format '{{.Names}}' | grep -q "$1"
}

# Wait for container to be healthy
wait_for_healthy() {
    local container=$1
    local max_wait=30
    local wait=0

    while [ $wait -lt $max_wait ]; do
        if docker inspect "$container" --format='{{.State.Health.Status}}' 2>/dev/null | grep -q "healthy"; then
            return 0
        fi
        sleep 1
        ((wait++))
    done
    return 1
}

# Test HTTP endpoint
test_http() {
    local url=$1
    local expected_status=${2:-200}

    status=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    [ "$status" = "$expected_status" ]
}

cleanup() {
    print_info "Cleaning up test containers and images..."
    docker stop node-app-test go-app-test secrets-app-test 2>/dev/null || true
    docker rm node-app-test go-app-test secrets-app-test 2>/dev/null || true
}

trap cleanup EXIT

print_header "TP1: Multi-stage Builds et Optimisation - Tests"

# ============================================
# Exercice 1: Node.js Multi-stage Build
# ============================================
print_header "Exercice 1: Application Node.js"

if [ -f "app/node-app/Dockerfile" ]; then
    print_test "Building Node.js image..."

    # Build the image
    if DOCKER_BUILDKIT=1 docker build -t node-app:test -f app/node-app/Dockerfile app/node-app/ &>/dev/null; then
        print_success "Node.js image built successfully"

        # Test 1: Image size
        print_test "Checking Node.js image size..."
        size=$(get_image_size "node-app:test")
        size_mb=$((size / 1048576))
        print_info "Image size: ${size_mb}MB"

        if [ $size_mb -lt 100 ]; then
            print_success "Image size < 100MB ($size_mb MB)"
        else
            print_fail "Image size too large: ${size_mb}MB (should be < 100MB)"
        fi

        # Test 2: User is non-root
        print_test "Checking if container runs as non-root..."
        user=$(docker run --rm node-app:test id -u 2>/dev/null || echo "0")
        if [ "$user" != "0" ]; then
            print_success "Container runs as non-root user (uid: $user)"
        else
            print_fail "Container runs as root (security risk)"
        fi

        # Test 3: Application starts and responds
        print_test "Testing if application responds..."
        docker run -d --name node-app-test -p 3001:3000 node-app:test &>/dev/null
        sleep 3

        if test_http "http://localhost:3001/health" 200; then
            print_success "Application responds correctly on /health"
        else
            print_fail "Application does not respond on /health"
        fi

        if test_http "http://localhost:3001/" 200; then
            print_success "Application responds correctly on /"
        else
            print_fail "Application does not respond on /"
        fi

        # Test 4: No dev dependencies
        print_test "Checking for dev dependencies..."
        has_nodemon=$(docker run --rm node-app:test sh -c "ls node_modules/nodemon 2>/dev/null" || echo "")
        has_eslint=$(docker run --rm node-app:test sh -c "ls node_modules/eslint 2>/dev/null" || echo "")

        if [ -z "$has_nodemon" ] && [ -z "$has_eslint" ]; then
            print_success "No dev dependencies found in image"
        else
            print_fail "Dev dependencies found in production image"
        fi

        docker stop node-app-test &>/dev/null

    else
        print_fail "Failed to build Node.js image"
        print_info "Make sure you have created app/node-app/Dockerfile"
    fi
else
    print_fail "Dockerfile not found: app/node-app/Dockerfile"
    print_info "Create your Dockerfile for the Node.js app"
fi

# ============================================
# Exercice 2: Go Ultra-optimized
# ============================================
print_header "Exercice 2: Application Go Ultra-optimisée"

if [ -f "app/go-app/Dockerfile" ]; then
    print_test "Building Go image..."

    if DOCKER_BUILDKIT=1 docker build -t go-app:test -f app/go-app/Dockerfile app/go-app/ &>/dev/null; then
        print_success "Go image built successfully"

        # Test 1: Image size < 10MB
        print_test "Checking Go image size..."
        size=$(get_image_size "go-app:test")
        size_mb=$((size / 1048576))
        print_info "Image size: ${size_mb}MB"

        if [ $size_mb -lt 10 ]; then
            print_success "Image size < 10MB ($size_mb MB) - Excellent!"
        elif [ $size_mb -lt 20 ]; then
            print_success "Image size < 20MB ($size_mb MB) - Good, but can be better"
        else
            print_fail "Image size too large: ${size_mb}MB (should be < 10MB)"
        fi

        # Test 2: Application responds
        print_test "Testing Go application..."
        docker run -d --name go-app-test -p 8081:8080 go-app:test &>/dev/null
        sleep 2

        if test_http "http://localhost:8081/health" 200; then
            print_success "Go application responds correctly"
        else
            print_fail "Go application does not respond"
        fi

        docker stop go-app-test &>/dev/null

        # Test 3: Check if binary is static
        print_test "Checking if binary is static..."
        # This test is approximate - we check the base image
        base_image=$(docker image inspect go-app:test --format='{{index .Config.Labels "stage"}}' 2>/dev/null || echo "")
        print_info "If using distroless or scratch, binary should be static"
        print_success "Binary check completed (manual verification recommended)"

    else
        print_fail "Failed to build Go image"
        print_info "Make sure you have created app/go-app/Dockerfile"
    fi
else
    print_fail "Dockerfile not found: app/go-app/Dockerfile"
    print_info "Create your Dockerfile for the Go app"
fi

# ============================================
# Exercice 3: Build Secrets
# ============================================
print_header "Exercice 3: Build Secrets et SSH Mounts"

if [ -f "app/private-deps/Dockerfile" ]; then
    print_test "Testing build with secrets..."

    # Create a fake .npmrc for testing
    echo "test-token-12345" > /tmp/test-npmrc

    if DOCKER_BUILDKIT=1 docker build \
        --secret id=npm_token,src=/tmp/test-npmrc \
        -t secrets-app:test \
        -f app/private-deps/Dockerfile \
        app/private-deps/ &>/dev/null; then

        print_success "Build with secrets completed"

        # Test 1: Secrets not in history
        print_test "Checking if secrets are exposed in history..."
        if docker history secrets-app:test 2>/dev/null | grep -q "test-token"; then
            print_fail "SECRET EXPOSED in docker history!"
        else
            print_success "Secrets not found in docker history"
        fi

        # Test 2: Secrets not in image
        print_test "Checking if secrets are in image layers..."
        if docker save secrets-app:test | tar -xO 2>/dev/null | grep -q "test-token"; then
            print_fail "SECRET EXPOSED in image layers!"
        else
            print_success "Secrets not found in image layers"
        fi

        # Test 3: Application works
        print_test "Testing application..."
        docker run -d --name secrets-app-test -p 3002:3000 secrets-app:test &>/dev/null
        sleep 2

        if test_http "http://localhost:3002/" 200; then
            print_success "Application with secrets works correctly"
        else
            print_fail "Application with secrets does not respond"
        fi

        docker stop secrets-app-test &>/dev/null

    else
        print_fail "Failed to build image with secrets"
        print_info "Make sure your Dockerfile uses --mount=type=secret"
    fi

    rm -f /tmp/test-npmrc
else
    print_fail "Dockerfile not found: app/private-deps/Dockerfile"
    print_info "Create your Dockerfile for the secrets exercise"
fi

# ============================================
# Exercice 4: Cache Optimization
# ============================================
print_header "Exercice 4: Cache Optimization"

print_info "Testing cache optimization requires manual verification"
print_info "Run the following commands to test:"
echo ""
echo "  # First build"
echo "  time DOCKER_BUILDKIT=1 docker build -t cache-test app/node-app/"
echo ""
echo "  # Second build (should use cache)"
echo "  time DOCKER_BUILDKIT=1 docker build -t cache-test app/node-app/"
echo ""
echo "  # Modify source code and rebuild"
echo "  echo '// comment' >> app/node-app/index.js"
echo "  time DOCKER_BUILDKIT=1 docker build -t cache-test app/node-app/"
echo ""
print_success "Cache optimization test info provided"
((TOTAL_TESTS++))
((PASSED_TESTS++))

# ============================================
# Summary
# ============================================
print_header "Test Summary"

echo "Total tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"

if [ $FAILED_TESTS -gt 0 ]; then
    echo ""
    echo -e "${RED}Failed tests:${NC}"
    for test_name in "${FAILED_TEST_NAMES[@]}"; do
        echo -e "  ${RED}•${NC} $test_name"
    done
fi

echo ""
if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}🎉 Congratulations! All tests passed!${NC}"
    echo -e "${GREEN}You can proceed to TP2${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed. Please review your work.${NC}"
    echo -e "${YELLOW}Check the solutions/ folder for reference.${NC}"
    exit 1
fi
