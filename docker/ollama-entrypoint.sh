#!/bin/bash
# docker/ollama-entrypoint.sh
# Script de entrada para Ollama que descarga modelos automáticamente

set -e

echo "🤖 Iniciando Ollama..."

# Función para descargar modelos
download_models() {
    echo "📥 Descargando modelos configurados..."
    
    # Esperar a que Ollama esté listo
    for i in {1..30}; do
        if /usr/bin/ollama list >/dev/null 2>&1; then
            echo "✅ Ollama está listo"
            break
        fi
        if [ $i -eq 30 ]; then
            echo "⚠️ Ollama tardó mucho en iniciar"
            return 1
        fi
        sleep 1
    done
    
    # Descargar modelo configurado
    if [ -n "$OLLAMA_MODELS" ]; then
        for MODEL in $OLLAMA_MODELS; do
            echo "📥 Verificando modelo: $MODEL"
            if /usr/bin/ollama list | grep -q "^$MODEL"; then
                echo "✅ Modelo $MODEL ya está instalado"
            else
                echo "📥 Descargando $MODEL..."
                /usr/bin/ollama pull "$MODEL" || echo "⚠️ Error descargando $MODEL"
            fi
        done
    else
        echo "ℹ️ No hay modelos configurados en OLLAMA_MODELS"
    fi
    
    echo "✅ Inicialización de modelos completada"
}

# Iniciar Ollama en background
/ollama/bin/ollama serve &
OLLAMA_PID=$!

# Descargar modelos
download_models

# Mantener el proceso activo
wait $OLLAMA_PID
