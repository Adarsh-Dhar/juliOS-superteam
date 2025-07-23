# 🧠 JuliaOS + A2A Agent Example

This guide walks you through setting up and running a JuliaOS-powered agent using the A2A protocol.

---

## 📦 Setup Instructions

### 1. Create and Activate a Virtual Environment

```bash
python3 -m venv venv
source venv/bin/activate
```

### 2. Install Dependencies

Install the core libraries and the current package:

```bash
pip install -e ../python
pip install -e .
```

---

## 🚀 Run the JuliaOS Agent Server

Start the Julia backend server:

```bash
cd ../backend/
julia run_server.jl
```

---

## ⚙️ Create the `add2` Agent

Register and configure the agent:

```bash
cd src/a2a/example/
python create_add2_agent.py
```

---

## 🛰️ Launch the A2A Server

Start the server that will host your agents:

```bash
cd src/a2a/
python server.py
```

---

## 🧪 Test the Agent with a Client

Send a test message to the agent:

```bash
cd src/a2a/example/
python client.py
```

---

## ✅ Result

You should see output from the server indicating that the agent received the message, processed it, and responded accordingly.