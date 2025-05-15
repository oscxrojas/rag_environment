#!/bin/bash

set -e

# COLORS
RESET="\033[0m"
BOLD="\033[1m"
BLUE="\033[1;34m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
CYAN="\033[1;36m"
GRAY="\033[0;37m"

# LOG FUNCTIONS
log_info()    { echo -e "${BLUE}ℹ️  [INFO] $1${RESET}"; }
log_success() { echo -e "${GREEN}✅ [OK]   $1${RESET}"; }
log_warn()    { echo -e "${YELLOW}⚠️  [WARN] $1${RESET}"; }
log_error()   { echo -e "${RED}❌ [ERROR] $1${RESET}"; }

start_service() {
  local service="$1"

  if ! docker compose config --services | grep -q "^$service$"; then
    log_warn "Service '$service' not found in docker-compose.yml. Skipping..."
    return
  fi

  log_info "Starting service: ${BOLD}$service${RESET}"
  docker compose up -d "$service"

  if [ "$service" = "ollama" ]; then
    log_info "Downloading models for Ollama..."
    if docker exec ollama bash -c "sh /mnt/model-downloader.sh"; then
      log_success "Model download completed"
    else
      log_error "Failed to download model in Ollama"
      exit 1
    fi
  fi
}

# PREPARE
log_info "Removing orphan containers..."
docker compose down --remove-orphans

log_info "Building Docker images..."
docker compose build

# START CONTAINERS
services=("ollama" "qdrant" "postgres" "clickhouse" "minio" "redis" "langfuse-worker" "langfuse-web" "jupyter")
for item in "${services[@]}"; do
  start_service "$item"
done

log_success "All services started successfully 🎉"
