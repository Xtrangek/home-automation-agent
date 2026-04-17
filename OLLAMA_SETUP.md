# Guía Rápida: Instalación de Qwen2.5-Coder:7B

**Estado actual:** Descargando `qwen2.5-coder:7b` (~5GB)

## ✅ Pasos completados

1. ✅ **Configuración Ollama agregada al repo:**
   - `docker/ollama.env` - Variables de configuración
   - `docker/ollama-entrypoint.sh` - Script para descargar modelos automáticamente
   - `docker-compose.yml` actualizado para usar estos archivos

2. ✅ **Scripts de inicialización:**
   - `scripts/start-stack.sh` - Inicia todo y descarga modelos
   - `scripts/init-ollama-models.sh` - Solo descarga modelos

3. ✅ **Servicio Systemd para Autostart:**
   - `home-automation-agent.service` - Inicia automáticamente al boot

4. ✅ **README actualizado** con:
   - Configuración de Ollama
   - Cómo cambiar modelos
   - Instrucciones de autostart
   - Estructura de carpetas

## ⏳ Esperando...

**Descarga de Qwen2.5-Coder:7B:**
```bash
# Ver progreso
docker logs -f ollama

# Ver modelos descargados
docker exec ollama ollama list
```

## 🚀 Una vez completado

### 1. Verificar que está instalado:
```bash
docker exec ollama ollama list
# Deberías ver:
# qwen2.5:7b         (anterior)
# qwen2.5-coder:7b   (nuevo - ESTE)
```

### 2. Actualizar n8n para usar el nuevo modelo

En tus workflows de n8n, cambiar:

**De:**
```json
{
  "model": "qwen2.5:7b",
  "prompt": "..."
}
```

**A:**
```json
{
  "model": "qwen2.5-coder:7b",
  "prompt": "..."
}
```

### 3. (Opcional) Eliminar modelo anterior

Si quieres ahorrar espacio:
```bash
docker exec ollama ollama rm qwen2.5:7b
```

## 📋 Próximos pasos recomendados

### 1. **Instalar servicio de autostart:** (Requiere sudo)

```bash
sudo cp home-automation-agent.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable home-automation-agent
sudo systemctl start home-automation-agent
```

### 2. **Preparar para boot automático:**

Ahora cada vez que reinicies tu PC:
- Los contenedores n8n, Ollama, Nginx se iniciarán automáticamente
- Los modelos se descargarán si no existen
- Todo estará listo cuando hagas login

### 3. **Verificar logs del servicio:**

```bash
sudo journalctl -u home-automation-agent -f
```

## 📊 Información de rendimiento esperada

Con tu **Ryzen 7 5700 + RX6600 8GB:**

- **Velocidad generación:** 25-45 tokens/seg
- **Tiempo respuesta típica:** 3-5 segundos
- **Memoria USB:** ~5GB (modelo Coder:7B)
- **VRAM usada:** ~5GB (muy cómodo en tu 8GB)

## ⚙️ Configuración de modelos

Editar: `docker/ollama.env`

```bash
# Modelos a descargar automáticamente
OLLAMA_MODELS=qwen2.5-coder:7b

# Para múltiples modelos (espacio separado)
# OLLAMA_MODELS=qwen2.5-coder:7b qwen2.5:7b
```

## 🆘 Troubleshooting

**¿El contenedor Ollama no descarga el modelo?**
```bash
# Reintentar manualmente
docker exec ollama ollama pull qwen2.5-coder:7b

# Ver logs
docker logs ollama
```

**¿Cambiar modelo después?**
- Editar `docker/ollama.env`
- Ejecutar `docker compose restart ollama`

---

**Actualizado:** Abril 16, 2026  
**Modelo:** Qwen2.5-Coder:7B  
**Estado:** En descarga (~5GB)
