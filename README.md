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

---

## 🏗️ Architecture

```text
Telegram → n8n → AI Agent (Ollama)
                 ↓
              Decision
                 ↓
            SSH → Host → Scripts
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
cp ../.env.example .env
nano .env
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
docker compose up -d
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

## 🔮 Future Improvements

* Role-based access control
* Audit logging
* Multi-agent orchestration
* Cloudflare / Zero Trust access
* Alexa secure integration via webhook

---

## 🧑‍💻 Author

Xtrangek

---

## 📄 License

MIT
