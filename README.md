# Home Automation Agent 🚀

AI-powered local automation system using **n8n + Ollama + Telegram + Docker**.

This project allows you to control your local machine (e.g. launch applications like Studio One) via a secure Telegram bot powered by an AI agent.

---

💰 Cost-Efficient Design

This system is designed to run at zero or near-zero cost.

All components used are:

🆓 Open-source or free-tier tools
🏠 Self-hosted on local infrastructure
🚫 No paid APIs required
🚫 No cloud dependencies
What this means
No monthly subscriptions
No API usage fees (no OpenAI, no paid LLMs)
No infrastructure costs (runs on your own machine)

👉 You get a fully functional AI-powered automation system without spending money

---

## 🧠 Features

* 🤖 AI Agent powered by Ollama (local LLM)
* 💬 Telegram bot interface
* 🖥️ Execute controlled actions on host machine
* 🔐 Secure SSH-based command execution
* 🌐 Reverse proxy with Nginx Proxy Manager
* 🧱 Docker-based deployment
* 🔒 Hardened network exposure
* 🏠 **NEW:** Home automation via Alexa Remote API
* 🎛️ **NEW:** Smart device control (lights, routines, voice commands)

---

## 🧠 Agent Execution Model

This system no longer relies on predefined actions.

### How it works:

1. User sends a message via Telegram
2. n8n receives the message
3. The AI agent (Ollama) interprets the request
4. The agent generates a **Bash command dynamically**
5. The command is executed via SSH on the host machine
6. The result is returned to the user
7. Memory is updated for future context

---

## 🏗️ Architecture

```text
Telegram → n8n → AI Agent (Ollama)
                 ↓
              Dynamic command
                 ↓
            SSH → Host → Execution
```

---

## 🌐 Networking & Exposure

```text
Internet → DuckDNS → Router → Nginx Proxy Manager → Docker Network → n8n
```

### Components

* **DuckDNS**

  * Dynamic DNS pointing to your public IP
  * No execution logic

* **Router**

  * Port forwarding (80 / 443)

* **Nginx Proxy Manager**

  * HTTPS termination (Let's Encrypt)
  * Routes traffic to internal services

---

## 💾 Memory System

The agent maintains persistent state in:

n8n/memory/agent-memory.json
Example:
{
  "last_app": "studio_one",
  "last_action": "open",
  "status": "open",
  "mode": "normal"
}
Purpose:
Avoid redundant actions
Maintain context between interactions
Enable smarter decision-making

---

## 🔐 Security Model

### Network Security

* ✅ Only ports **80/443** exposed
* ❌ n8n port (5678) NOT public
* ❌ Ollama port NOT public
* ❌ NPM admin panel restricted to localhost
* ✅ Internal Docker network isolation

---

### Application Security

* n8n protected with Basic Auth
* Credentials NOT stored in repository
* Telegram access restricted by `chat_id`

---

### Execution Security

* ❌ No arbitrary command execution
* ✅ Only predefined scripts allowed
* ✅ Controlled via Switch node in n8n
* ✅ SSH key-based authentication only

---

## 🐳 Stack

* n8n (workflow automation)
* Ollama (local LLM)
* Alexa Remote API (smart home integration)
* Nginx Proxy Manager (reverse proxy)
* Docker / Docker Compose
* Telegram Bot API

---

## 🚀 Setup

### 1. Clone repository

```bash
git clone https://github.com/YOUR_USER/ony-agents.git
cd ony-agents/docker
```

---

### 2. Configure environment

```bash
cp .env.example .env
# Edit with your actual values
nano .env
```

**IMPORTANT - Security Update:**

All sensitive credentials are now externalized to `.env` files:

- **Root .env** (`/root/.env`): Master environment configuration
- **Docker .env** (`docker/.env`): Synced copy for docker-compose
- **Both files are gitignored** - never committed to repository

**Critical fields:**

```env
# Encryption Key - CHANGE THIS FOR SECURITY
# Generate new key with: node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
N8N_ENCRYPTION_KEY=<your-32-byte-base64-key>

# Authentication
N8N_BASIC_AUTH_USER=your_user
N8N_BASIC_AUTH_PASSWORD=your_secure_password

# REQUIRED: Fill in your values
WEBHOOK_URL=https://your-domain.duckdns.org
N8N_PORT=5678
N8N_HOST=0.0.0.0
```

Fill required variables:

```env
# N8N
N8N_BASIC_AUTH_USER=your_user
N8N_BASIC_AUTH_PASSWORD=your_password
N8N_ENCRYPTION_KEY=your_encryption_key

# TELEGRAM
TELEGRAM_BOT_TOKEN=your_bot_token
TELEGRAM_CHAT_ID=your_chat_id

# DOMAIN
WEBHOOK_URL=https://your-domain.duckdns.org
```

---

### 3. Run services

```bash
# Opción 1: Usar script de facilidad (recomendado)
./scripts/start-stack.sh

# Opción 2: Manual con docker compose
cd docker
docker compose up -d
```

**El script `start-stack.sh` automáticamente:**
- ✅ Inicia los contenedores n8n, Ollama, Nginx
- ✅ Descarga los modelos de Ollama configurados
- ✅ Valida que todos los servicios estén listos

---

## 🤖 Configuración de Ollama

### Modelos Soportados

El proyecto está configurado para usar **Qwen2.5-Coder:7B** (optimizado para código y arquitectura).

| Modelo | Tamaño | VRAM Requerido | Recomendado |
|--------|--------|---|---|
| `qwen2.5-coder:7b` | 7B | ~5GB | ✅ SÍ (ACTUAL) |
| `qwen2.5:7b` | 7B | ~5GB | ❌ General |
| `qwen2.5:14b` | 14B | ~8-9GB | ⚠️ Si tienes mucha VRAM |

### Cambiar de Modelo

**1. Editar configuración:**

```bash
# Editar docker/ollama.env
# Cambiar OLLAMA_MODELS=qwen2.5-coder:7b
# A: OLLAMA_MODELS=qwen2.5:14b (o el modelo que prefieras)
```

**2. Reiniciar servicios:**

```bash
cd docker
docker compose down
docker compose up -d

# El nuevo modelo se descargará automáticamente
```

**3. Verificar modelo activo:**

```bash
docker exec ollama ollama list
```

### Descargar Modelo Manualmente

```bash
# Dentro del contenedor
docker exec ollama ollama pull qwen2.5-coder:7b

# O desde el host (si ollama está instalado)
ollama pull qwen2.5-coder:7b
```

---

## 🔄 Autostart en Boot (Linux)

Para que la stack inicie automáticamente cuando enciendas la PC:

### Instalación del Servicio Systemd

```bash
# 1. Copiar el archivo del servicio
sudo cp home-automation-agent.service /etc/systemd/system/

# 2. Recargar systemd
sudo systemctl daemon-reload

# 3. Habilitar el servicio
sudo systemctl enable home-automation-agent

# 4. Iniciar ahora (opcional)
sudo systemctl start home-automation-agent

# 5. Verificar estado
sudo systemctl status home-automation-agent
```

### Verificar Logs del Servicio

```bash
# Ver logs en tiempo real
sudo journalctl -u home-automation-agent -f

# Ver últimos 50 logs
sudo journalctl -u home-automation-agent -n 50
```

### Detener/Reiniciar el Servicio

```bash
# Detener
sudo systemctl stop home-automation-agent

# Reiniciar
sudo systemctl restart home-automation-agent

# Deshabilitar autostart
sudo systemctl disable home-automation-agent
```

---

## 📁 Estructura de Configuración

```
docker/
├── docker-compose.yml      # Orquestación de contenedores
├── ollama.env              # Configuración de modelos
├── ollama-entrypoint.sh    # Script para descargar modelos
├── Dockerfile.n8n          # Imagen personalizada de n8n
└── .env                    # Credenciales locales (gitignored)

scripts/
├── start-stack.sh          # Script para iniciar la stack
└── init-ollama-models.sh   # Script para descargar modelos

home-automation-agent.service  # Servicio systemd para autostart
```

---

## 🏠 Home Automation Setup (NEW)

### Alexa Remote Integration

The system now supports controlling Amazon Alexa devices and smart home devices.

#### Installation

1. **Dockerfile Extension**: The n8n container automatically includes the Alexa Remote node:

```dockerfile
# docker/Dockerfile.n8n
FROM docker.n8n.io/n8nio/n8n:latest
RUN npm install -g @ac-codeprod/n8n-nodes-alexa-remote
```

2. **Environment Configuration**: All sensitive credentials are now managed via `.env` files:

```bash
# Root .env file (NOT committed to repo)
# Managed in docker/.env and synced from root
N8N_ENCRYPTION_KEY=<your-secure-key>
N8N_BASIC_AUTH_PASSWORD=<your-secure-password>
```

#### Alexa Authentication

**Step-by-step authentication:**

1. En n8n UI, abre la credencial **"Alexa Remote account"**
2. Asegúrate que el Proxy IP sea `192.168.1.70` y Proxy Port `3456`
3. Haz click en **"Retry"** / guardar — esto inicia el proxy interno
4. Abre tu navegador y ve a **`http://192.168.1.70:3456`**
5. Te redirigirá a Amazon — inicia sesión con tu cuenta de Amazon
6. Las cookies se guardan automáticamente en:
   ```
   /home/node/.n8n/.alexa-cookie.json
   ```
7. La credencial aparecerá como conectada

**Requisito:** El puerto `3456` debe estar expuesto en `docker-compose.yml`:
```yaml
ports:
  - "127.0.0.1:5678:5678"
  - "192.168.1.70:3456:3456"
```

**Troubleshooting:**
- Si el proxy no responde: reinicia el container n8n y reintenta
- Si falla la conexión: verifica que Amazon no tenga 2FA activo o desactívalo temporalmente
- Cookie path en el container: `/home/node/.n8n/.alexa-cookie.json`

#### Available Actions

The Alexa Remote node supports:

- **Text Command**: Send voice commands to Alexa devices
  - Examples: "Enciende las luces de la sala", "Pon música jazz"
- **Device Control**: Target specific devices or device groups
- **Interactions**: Text commands, Device control, Routines

### Workflow Changes

The **agent-core workflow** now includes:

1. **Telegram Trigger** → Receives user message
2. **Ollama Agent** → Processes request with LLM
   - Returns JSON with action type: `control_alexa`, `execute_command`, or `answer`
3. **Switch Node** → Routes based on action type:
   - `control_alexa` → Alexa Remote node
   - `execute_command` → Command execution
   - `answer` → Text response
4. **Alexa Remote Node** → Sends commands to smart devices
   - Supports groups (sends to multiple devices)
   - Returns success status for each device
5. **Consolidation Node** → Combines multiple device responses
   - Formats multiple device confirmations into single Telegram message
6. **Telegram Response** → Sends result back to user

**Example Flow:**
```
User: "Apaga las luces de la sala"
  ↓
Ollama: {"action": "control_alexa", "command": "Apaga las luces de la sala", "message": "..."}
  ↓
Alexa Remote: Sends to all Alexa devices
  ↓
Response: 2 items (multiple devices executed successfully)
  ↓
Consolidation: Combines into single message
  ↓
Telegram: "✅ Comando ejecutado en 2 dispositivos"
```

---

## 🧩 Workflows

Located in:

```text
n8n/workflows/
```

### Import into n8n

1. Open n8n UI
2. Import workflow JSON
3. Reconnect credentials manually

---

## 🔐 Credentials Setup

Credentials are NOT included in this repository.

You must create them manually in n8n:

### Required Credentials

* Telegram API
* SSH (host access)
* Ollama HTTP endpoint

Example reference:

```text
n8n/credentials-example.json
```

---

## 🖥️ Host Scripts

Located in:

```text
scripts/
```

Examples:

* open-studio-one.sh
* close-studio-one.sh

---

## ⚠️ Important

Do NOT:

* expose n8n directly to internet
* expose Ollama port
* allow arbitrary command execution
* commit secrets to repository

---

## 📁 Project Structure

```text
ony-agents/
│
├── docker/
│   └── docker-compose.yml
│
├── scripts/
│
├── n8n/
│   ├── workflows/
│   └── credentials-example.json
│
├── docs/
│   └── architecture.md
│
├── .env.example
├── .gitignore
└── README.md
```

---

## 🧠 Design Principles

* Least privilege
* Explicit action mapping
* No command injection
* Internal service isolation
* Minimal external exposure

---

## � Troubleshooting

### Encryption Key Issues

**Problem:** "Mismatching encryption keys" error on n8n startup

**Solution:**
1. The encryption key was rotated for security (credentials were exposed)
2. Delete the old n8n config: `rm -rf /home/ony/.n8n/config`
3. Restart containers: `docker compose restart n8n`
4. Reconfigure all credentials in n8n UI (old encrypted data cannot be recovered)

**To generate a new safe encryption key:**
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

### Alexa Authentication Issues

**Problem:** "No cookie file found" when connecting to Alexa Remote

**Solution:**
1. Ensure you clicked the **"Authenticate"** button in the Alexa Remote credential window
2. Complete the full Amazon login flow
3. Wait for cookies file to be created at `/home/ony/.n8n/alexa-cookie.json`
4. Click **"Retry"** if connection still fails

**Problem:** Multiple device responses in workflow

**Solution:**
- This is normal when targeting device groups
- Use a **Code node** to consolidate responses before sending to Telegram
- See "Workflow Changes" section for consolidation example

### Container Startup Issues

**Problem:** n8n container fails to start

1. Check logs: `docker logs n8n`
2. Verify `.env` files exist in both root and `docker/` folders
3. Ensure `docker-compose.yml` has correct `env_file` path
4. Rebuild: `docker compose up --build -d`

**Problem:** Ollama not accessible from n8n

- Ollama runs in the same Docker network, use: `http://ollama:11434`
- Not `http://localhost:11434`

---

## �🔮 Future Improvements

* Role-based access control
* Audit logging
* Multi-agent orchestration
* Cloudflare / Zero Trust access
* Enhanced Alexa integration (routines automation, device discovery)
* Additional smart home platforms (Google Home, Home Assistant)
* Workflow versioning and rollback
* Performance metrics and monitoring

---

## 🧑‍💻 Author

Xtrangek

---

## 📄 License

MIT
