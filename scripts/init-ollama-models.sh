#!/bin/bash
# scripts/init-ollama-models.sh
# Script para descargar e inicializar modelos de Ollama
# Se ejecuta automáticamente al iniciar los contenedores

set -e

OLLAMA_CONTAINER="ollama"
OLLAMA_HOST="${OLLAMA_HOST:-http://localhost:11434}"
MODELS="${OLLAMA_MODELS:-qwen2.5-coder:7b}"

echo "🤖 Inicializando modelos de Ollama..."
echo "Host: $OLLAMA_HOST"
echo "Modelos a descargar: $MODELS"

# Esperar a que Ollama esté listo
echo "⏳ Esperando a que Ollama esté disponible..."
for i in {1..60}; do
    if curl -s "$OLLAMA_HOST/api/tags" > /dev/null 2>&1; then
        echo "✅ Ollama está listo"
        break
    fi
    if [ $i -eq 60 ]; then
        echo "❌ Error: Ollama no respondió después de 60 segundos"
        exit 1
    fi
    echo "   Intento $i/60..."
    sleep 1
done

# Descargar modelos
for MODEL in $MODELS; do
    echo ""
    echo "📥 Descargando modelo: $MODEL"
    
    # Verificar si ya existe
    if docker exec "$OLLAMA_CONTAINER" ollama list | grep -q "^$MODEL"; then
        echo "✅ Modelo $MODEL ya está instalado"
        continue
    fi
    
    # Descargar
    if docker exec "$OLLAMA_CONTAINER" ollama pull "$MODEL"; then
        echo "✅ Modelo $MODEL descargado exitosamente"
    else
        echo "❌ Error descargando $MODEL"
        exit 1
    fi
done

echo ""
echo "🎉 Modelos inicializados correctamente"
echo ""
echo "Modelos disponibles:"
docker exec "$OLLAMA_CONTAINER" ollama list
