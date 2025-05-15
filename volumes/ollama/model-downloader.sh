#!/bin/bash

MODEL_DIR="/root/.ollama/models/manifests/registry.ollama.ai/library"
MODEL_NAME="${OLLAMA_MODEL}"

if [ -d "${MODEL_DIR}/${MODEL_NAME}" ]; then
  echo "boostrap  | Model '${MODEL_NAME}' already exists, skipping download."
else
  echo "boostrap  | Model '${MODEL_NAME}' not found, downloading..."
  ollama pull "${MODEL_NAME}"
fi