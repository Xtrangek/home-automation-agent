# 🧠 Architecture Overview

This document describes the architecture of the **Home Automation Agent**, a local AI-powered automation platform that integrates Telegram, n8n, and host-level execution.

---

## 🔷 High-Level Architecture

```text
User (Telegram)
      ↓
Telegram Bot API
      ↓
n8n (Webhook Trigger)
      ↓
AI Agent (Ollama)
      ↓
Decision Engine (Switch / Logic)
      ↓
SSH Execution
      ↓
Host Machine (Scripts)
```

---

## 🌐 Networking Layer

```text
Internet
   ↓
DuckDNS (onyagents.duckdns.org)
   ↓
Router (Port Forwarding 80/443)
   ↓
Nginx Proxy Manager (Reverse Proxy)
   ↓
Docker Network (proxy_net)
   ↓
n8n
```

### Components:

* **DuckDNS**

  * Resolves domain to dynamic public IP
  * No execution logic

* **Router**

  * Forwards ports 80/443 to host machine

* **Nginx Proxy Manager**

  * Terminates HTTPS (Let's Encrypt)
  * Routes traffic to internal services (n8n)

---

## 🐳 Container Layer

All services run in Docker:

```text
docker-compose
│
├── n8n
├── ollama
└── nginx-proxy-manager (npm)
```

### Internal Network

```text
proxy_net
│
├── n8n
├── ollama
└── npm
```

* Services communicate via container names:

  * `http://n8n:5678`
  * `http://ollama:11434`

---

## 🤖 AI Layer

The AI agent is powered by **Ollama**.

### Flow:

```text
User message → AI → structured output → action
```

Example output:

```json
{
  "action": "open_studio_one"
}
```

---

## ⚙️ Execution Layer

Execution is handled via SSH from n8n to host.

### Design Principle

❌ No arbitrary command execution
✅ Only predefined scripts allowed

```text
n8n → SSH → /home/ony/bin/open-studio-one.sh
```

---

## 🔐 Security Architecture

### Network Security

* Only ports **80/443** exposed
* All internal services isolated in Docker network
* NPM admin panel restricted to `127.0.0.1`

---

### Application Security

* n8n protected with Basic Auth
* Credentials not stored in repository
* Telegram access restricted by `chat_id`

---

### Execution Security

* No dynamic shell execution
* Actions mapped via controlled `Switch` node
* Scripts audited and versioned

---

## 🧩 Workflow Architecture

```text
Telegram Trigger
   ↓
Greeting / Validation
   ↓
AI Agent (Ollama)
   ↓
JSON Parser
   ↓
Switch (Action Router)
   ↓
SSH Command Execution
```

---

## 📦 Data Flow

1. User sends message via Telegram
2. Telegram triggers webhook in n8n
3. n8n sends input to Ollama
4. AI returns structured action
5. n8n routes action via Switch
6. SSH executes corresponding script on host

---

## 🚨 Trust Boundaries

| Layer    | Trust Level   |
| -------- | ------------- |
| Internet | Untrusted     |
| Telegram | Semi-trusted  |
| n8n      | Trusted       |
| Host     | Fully trusted |

---

## 🔮 Future Improvements

* Role-based access control
* API authentication layer
* Event logging and audit trail
* VPN / Zero Trust access
* Multi-agent orchestration

---

## 🧠 Key Design Principles

* Least privilege
* No direct command injection
* Internal service isolation
* Explicit action mapping
* External exposure minimized

---

## 🧑‍💻 Summary

This system transforms a local machine into a controllable AI-driven node using:

* secure networking
* containerized services
* controlled execution pipelines
* natural language interface
