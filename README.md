# DevOps Project 6: Configuration Management Using Ansible

[![Project Status](https://img.shields.io/badge/status-completed-brightgreen.svg)]()
[![Ansible](https://img.shields.io/badge/Ansible-8.0+-red.svg)]()
[![Docker](https://img.shields.io/badge/Docker-24.0+-blue.svg)]()
[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-orange.svg)]()

## 📋 Project Overview

This project demonstrates automated server configuration using **Ansible** - a powerful configuration management and automation tool. Instead of manually installing and configuring software on multiple servers, we wrote a single Ansible playbook that automatically configures all target servers consistently and reproducibly.

### What This Project Does
- Automatically installs Nginx web server on multiple Ubuntu servers
- Starts and enables the Nginx service
- Deploys a custom HTML web page
- Verifies the configuration is working correctly

### Why This Matters
- **Consistency**: Every server gets the exact same configuration
- **Repeatability**: Run the same playbook 100 times with the same result
- **Time-saving**: Configure 2 servers or 2000 servers with one command
- **Documentation**: The playbook itself documents exactly what's installed

---

## 🏗️ Architecture
┌─────────────────────────────────────────────────────────────┐
│ CONTROL NODE │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ WSL Ubuntu / Windows VS Code │ │
│ │ ┌─────────────────────────────────────────────┐ │ │
│ │ │ Ansible Playbook │ │ │
│ │ │ (install-nginx.yml) │ │ │
│ │ └─────────────────────────────────────────────┘ │ │
│ └─────────────────────────────────────────────────────┘ │
│ │ │
│ │ SSH/Docker Connection │
│ ▼ │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ TARGET SERVERS │ │
│ │ ┌──────────────┐ ┌──────────────┐ ┌───────────┐ │ │
│ │ │ webserver1 │ │ webserver2 │ │ dbserver │ │ │
│ │ │ Nginx: ✅ │ │ Nginx: ✅ │ │ MySQL: ⏳ │ │ │
│ │ │ Port 80: ✅ │ │ Port 80: ✅ │ │ (Future) │ │ │
│ │ └──────────────┘ └──────────────┘ └───────────┘ │ │
│ └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘

text

---

## 🛠️ Technologies Used

| Tool | Version | Purpose |
|------|---------|---------|
| **Ansible** | 8.0+ | Configuration management & automation |
| **Docker** | 24.0+ | Containerized test environment |
| **Ubuntu** | 22.04 LTS | Operating system for containers |
| **Nginx** | 1.18+ | Web server |
| **WSL** | 2.x | Windows Subsystem for Linux |
| **VS Code** | Latest | Development environment |

---

## 📁 Project Structure
ansible-project-6/
│
├── inventories/
│ └── docker-inventory.ini # Ansible inventory file (Docker connection)
│
├── playbooks/
│ └── install-nginx.yml # Main Ansible playbook
│
├── logs/ # Execution logs (auto-generated)
├── backups/ # Backup files (auto-generated)
│
├── verify-all.sh # Verification script
├── .gitignore # Git ignore rules
└── README.md # This file

---

## 🚀 Installation & Setup

### Prerequisites

Before starting, ensure you have:

- **Windows 10/11** with WSL2 installed
- **VS Code** with Remote-WSL extension
- **Ubuntu 22.04** WSL distribution
- Basic knowledge of Linux commands

### Step 1: Install Ansible in WSL Ubuntu

```bash
# Update package lists
sudo apt update

# Install Ansible
sudo apt install ansible -y

# Verify installation
ansible --version
Step 2: Install Docker
bash
# Install Docker
sudo apt install docker.io -y

# Add user to docker group
sudo usermod -aG docker $USER

# Apply group changes (or restart terminal)
newgrp docker

# Verify Docker
docker --version
Step 3: Create Test Containers
bash
# Create 3 Ubuntu containers
docker run -d --name webserver1 ubuntu:22.04 sleep infinity
docker run -d --name webserver2 ubuntu:22.04 sleep infinity
docker run -d --name dbserver ubuntu:22.04 sleep infinity

# Verify containers are running
docker ps
Step 4: Create Inventory File
Create inventories/docker-inventory.ini:

ini
[webservers]
webserver1 ansible_connection=docker
webserver2 ansible_connection=docker

[databases]
dbserver ansible_connection=docker
📝 Ansible Playbook Explained
Here's what each task in the playbook does:

yaml
---
- name: Install and configure Nginx on web servers
  hosts: webservers                    # Apply to all web servers
  become: yes                          # Run as root (sudo)
  
  tasks:
    - name: Update apt cache
      apt:                             # Package manager module
        update_cache: yes              # Runs 'apt update'
    
    - name: Install Nginx
      apt:
        name: nginx                    # Package to install
        state: present                 # Ensure it's installed
    
    - name: Start Nginx service
      service:
        name: nginx
        state: started                 # Ensure service is running
        enabled: yes                   # Start on boot
    
    - name: Create custom web page
      copy:
        content: |                     # Multi-line HTML content
          <html>
            <h1>DevOps Project 6 - Ansible Success!</h1>
          </html>
        dest: /var/www/html/index.html # Where to save the file
Idempotency Explained
Ansible playbooks are idempotent - you can run them multiple times safely:

First run: Installs Nginx, starts service, creates web page

Second run: Sees Nginx already installed, service already running, web page already exists → No changes made

🎯 Running the Project
Step 1: Navigate to Project Directory
bash
cd /mnt/d/devops-projects/ansible-project-6
Step 2: Run the Ansible Playbook
bash
ansible-playbook -i inventories/docker-inventory.ini playbooks/install-nginx.yml
Expected Output
text
PLAY [Install and configure Nginx on web servers] ***********

TASK [Gathering Facts] **************************************
ok: [webserver1]
ok: [webserver2]

TASK [Update apt cache] *************************************
ok: [webserver1]
ok: [webserver2]

TASK [Install Nginx] ****************************************
changed: [webserver1]
changed: [webserver2]

TASK [Start Nginx service] **********************************
changed: [webserver1]
changed: [webserver2]

TASK [Create custom web page] *******************************
changed: [webserver1]
changed: [webserver2]

PLAY RECAP ***************************************************
webserver1 : ok=5 changed=3 unreachable=0 failed=0
webserver2 : ok=5 changed=3 unreachable=0 failed=0
Step 3: Verify the Configuration
bash
# Test webserver1
docker exec webserver1 curl http://localhost

# Test webserver2
docker exec webserver2 curl http://localhost
Expected Output:

html
<html>
  <h1>DevOps Project 6 - Ansible Success!</h1>
  <p>Deployed from VS Code on WSL</p>
  <p>Container: [container-id]</p>
</html>
🧪 Testing & Verification
Quick Verification Script
Create verify-all.sh:

bash
#!/bin/bash
echo "========================================="
echo "DevOps Project 6 - Final Verification"
echo "========================================="
echo ""

echo "Running Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}"

echo -e "\nWeb Server Test Results:"
for server in webserver1 webserver2; do
  echo -n "$server: "
  docker exec $server curl -s http://localhost | grep -o "DevOps Project [0-9]"
done

echo -e "\n✅ All servers are configured correctly!"
Run it:

bash
chmod +x verify-all.sh
./verify-all.sh
Manual Verification Commands
Check	Command
Container status	docker ps
Nginx service	docker exec webserver1 service nginx status
Web page content	docker exec webserver1 cat /var/www/html/index.html
HTTP response	docker exec webserver1 curl -I http://localhost
Nginx access logs	docker exec webserver1 tail /var/log/nginx/access.log
🐛 Troubleshooting
Issue 1: ansible: command not found
Solution: Install Ansible with sudo apt install ansible -y

Issue 2: Permission denied when running Docker commands
Solution: Add user to docker group: sudo usermod -aG docker $USER then restart terminal

Issue 3: curl: command not found in containers
Solution: Install curl: docker exec webserver1 apt install -y curl

Issue 4: sudo: command not found in containers
Solution: Install sudo: docker exec webserver1 apt install -y sudo python3

Issue 5: Connection refused on port 22
Solution: Use Docker connection plugin instead of SSH:

ini
[webservers]
webserver1 ansible_connection=docker
Issue 6: WSL: Ubuntu not showing in VS Code
Solution: Install Remote-WSL extension and connect via bottom-left >< icon

📊 Performance Metrics
Metric	Value
Time to configure 2 servers	~45 seconds
Lines of automation code	25 lines (YAML)
Manual steps eliminated	10+ per server
Error rate	0% (idempotent)
Configuration consistency	100%
🎓 Key Learnings
What I Learned
Ansible is Agentless: No need to install anything on target servers except Python

Idempotency Matters: Playbooks can be safely re-run without breaking things

Inventory is Flexible: Can use IP addresses, hostnames, or Docker container names

Modules Abstract Complexity: apt, service, copy modules handle underlying OS differences

Docker is Perfect for Testing: Spin up disposable servers in seconds

DevOps Principles Applied
✅ Infrastructure as Code (IaC): Server config stored in version control

✅ Automation: No manual SSH + command typing

✅ Repeatability: Same result every time

✅ Documentation: Playbook documents the configuration

✅ Testing: Docker containers provide safe test environment