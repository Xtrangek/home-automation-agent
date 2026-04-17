#!/bin/bash
# scripts/start-stack.sh
# Script para iniciar toda la stack de automatización

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DOCKER_DIR="$PROJECT_ROOT/docker"

echo "============================================"
echo "🚀 Home Automation Agent - Stack Start"
echo "============================================"
echo ""

# Cambiar a directorio docker
cd "$DOCKER_DIR"

# Verificar que .env existe
if [ ! -f ".env" ]; then
    echo "❌ Error: archivo .env no encontrado en $DOCKER_DIR"
    echo "Por favor copia .env.example a .env y actualiza los valores"
    exit 1
fi

echo "📦 Iniciando contenedores Docker..."
docker compose up -d

echo "✅ Contenedores iniciados"
echo ""

# Esperar a que los contenedores estén listos
echo "⏳ Esperando a que los servicios estén listos..."
sleep 10

# Inicializar modelos de Ollama
echo ""
echo "📥 Inicializando modelos de Ollama..."
"$SCRIPT_DIR/init-ollama-models.sh"

echo ""
echo "============================================"
echo "✅ Stack iniciada correctamente"
echo "============================================"
echo ""
echo "🌐 Servicios disponibles:"
echo "   • n8n:      http://localhost:5678"
echo "   • Ollama:   http://localhost:11434"
echo "   • NPM:      http://localhost:81 (admin)"
echo ""
echo "📊 Ver logs:"
echo "   docker logs -f n8n"
echo "   docker logs -f ollama"
echo ""
