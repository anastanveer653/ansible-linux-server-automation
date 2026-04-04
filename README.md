# ⚙️ Ansible Linux Server Automation

![Ansible](https://img.shields.io/badge/Ansible-2.14+-EE0000?logo=ansible&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%20|%2022.04%20|%2024.04-E95420?logo=ubuntu)
![Debian](https://img.shields.io/badge/Debian-11%20|%2012-A81D33?logo=debian)
![RHEL](https://img.shields.io/badge/RHEL%20%2F%20CentOS-8%20|%209-EE0000?logo=redhat)
![License](https://img.shields.io/badge/License-MIT-green)
![Stars](https://img.shields.io/github/stars/anastanveer653/ansible-linux-server-automation?style=social)

> **One command to go from a blank Linux server to a hardened, production-ready machine.**

A complete, modular Ansible playbook collection for automating Linux server setup, security hardening, and software deployment. Built for sysadmins, DevOps engineers, and anyone who manages VPS or bare-metal servers.

---

## ⚡ Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/anastanveer653/ansible-linux-server-automation.git
cd ansible-linux-server-automation

# 2. Install Ansible collections
ansible-galaxy collection install -r requirements.yml

# 3. Edit your inventory
cp inventory/hosts.yml inventory/hosts.yml.bak
nano inventory/inventory/hosts.yml   # Add your server IPs

# 4. Edit variables
nano inventory/group_vars/all.yml    # Set your admin user, SSH port, etc.

# 5. Run the full playbook
ansible-playbook site.yml

# Or just run security hardening
ansible-playbook playbooks/security-hardening.yml
```

---

## 🧱 What Gets Configured

### 🖥️ Baseline (`roles/baseline`)
- Sets **timezone** and **locale**
- Installs **essential tools**: curl, git, htop, vim, jq, rsync, net-tools, and more
- **Removes insecure legacy packages**: telnet, rsh, nis, talk
- Applies **kernel hardening** via sysctl (IP spoofing, SYN floods, ICMP, ASLR)
- Configures **automatic security updates** (unattended-upgrades)
- Enables **auditd** for system call auditing
- Disables **core dumps**
- Drops `/etc/ansible-managed/info` marker on every managed host

### 👤 Users (`roles/users`)
- Creates a **non-root sudo admin user**
- Adds your **SSH public key** to authorized_keys
- Locks the **root account password**
- Sets **umask 027** for tighter file permissions
- Grants **passwordless sudo** to admin user

### 🔐 SSH Hardening (`roles/ssh_hardening`) — CIS Aligned
- Changes **SSH port** (optional)
- Disables **root login** and **password authentication**
- Enforces **key-based auth only**
- Allows only **strong ciphers and algorithms** (ED25519, AES-GCM, ChaCha20)
- Removes **weak DSA host keys**
- Sets **MaxAuthTries**, **ClientAliveInterval**, **LoginGraceTime**
- Disables X11, TCP, and agent forwarding
- Adds **login banner** (legal warning)
- Validates config before applying (`sshd -t`)

### 🔥 Firewall (`roles/firewall`)
- **UFW** on Debian/Ubuntu — deny all inbound, allow configured ports
- **firewalld** on RHEL/CentOS
- Only opens ports you specify in `group_vars/all.yml`
- Enables **UFW logging**

### 🚫 Fail2Ban (`roles/fail2ban`)
- Bans IPs after **5 failed SSH attempts** (configurable)
- **Double-ban** rule: 24-hour ban for repeat offenders
- Stubs for **Nginx** HTTP auth protection (commented, easy to enable)

### 🐳 Docker (`roles/docker`) *(optional)*
- Installs **Docker Engine** + **Docker Compose plugin** from official repo
- Adds users to `docker` group
- Configures **secure daemon defaults**: log rotation, no userland proxy, no new privileges

### 📊 Monitoring (`roles/monitoring`) *(optional)*
- Installs **Prometheus Node Exporter** as a systemd service
- Runs as a dedicated **non-root** `node_exporter` user
- Opens the metrics port in the firewall
- Verifies endpoint is responding after install

---

## 🗂️ Project Structure

```
ansible-linux-server-automation/
│
├── site.yml                          # Master playbook — runs everything
├── ansible.cfg                       # Ansible configuration
├── requirements.yml                  # Galaxy collections to install
│
├── inventory/
│   ├── hosts.yml                     # Your server inventory
│   └── group_vars/
│       └── all.yml                   # All variables in one place
│
├── playbooks/
│   ├── security-hardening.yml        # SSH + Firewall + Fail2Ban only
│   ├── setup-docker.yml              # Docker only
│   ├── setup-monitoring.yml          # Node Exporter only
│   └── new-vps-setup.yml             # One-shot fresh VPS bootstrap
│
└── roles/
    ├── baseline/                     # System essentials + kernel hardening
    ├── users/                        # Admin user creation
    ├── ssh_hardening/                # CIS-aligned SSH config
    ├── firewall/                     # UFW / firewalld
    ├── fail2ban/                     # Brute-force protection
    ├── docker/                       # Docker Engine + Compose
    └── monitoring/                   # Prometheus Node Exporter
```

---

## 🎯 Common Usage Examples

```bash
# Full setup on all servers
ansible-playbook site.yml

# Fresh VPS bootstrap (run as root on new server)
ansible-playbook playbooks/new-vps-setup.yml -i "192.168.1.100," -u root

# Security hardening only
ansible-playbook playbooks/security-hardening.yml

# Install Docker on docker_hosts group only
ansible-playbook playbooks/setup-docker.yml -l docker_hosts

# Run specific tags only
ansible-playbook site.yml --tags "ssh,firewall"

# Dry run (check mode — no changes made)
ansible-playbook site.yml --check

# Run on a single host
ansible-playbook site.yml -l web01

# Verbose output for debugging
ansible-playbook site.yml -vvv
```

---

## ⚙️ Configuration

All settings live in `inventory/group_vars/all.yml`. Key options:

```yaml
# SSH
ssh_port: 22                          # Change to 2222 for obscurity
ssh_password_authentication: "no"    # Key-based only

# Admin user
admin_user: "sysadmin"
admin_ssh_public_key: "ssh-ed25519 AAAA..."  # Your public key

# Firewall — only these ports open
firewall_allowed_tcp_ports:
  - 22    # SSH
  - 80    # HTTP
  - 443   # HTTPS

# Fail2Ban
fail2ban_maxretry: 5
fail2ban_bantime: 3600               # 1 hour

# Optional features
install_docker: false
install_monitoring: false
```

---

## ✅ Supported Operating Systems

| OS | Version | Tested |
|---|---|---|
| Ubuntu | 20.04, 22.04, 24.04 | ✅ |
| Debian | 11, 12 | ✅ |
| RHEL / AlmaLinux / Rocky | 8, 9 | ✅ |
| CentOS Stream | 8, 9 | ✅ |

---

## 🔒 Security Controls Applied

| Control | Details |
|---|---|
| SSH hardening | CIS Level 1 aligned, strong ciphers only |
| Kernel parameters | IP spoofing, SYN floods, ICMP, ASLR via sysctl |
| Automatic updates | Security patches applied automatically |
| Brute-force protection | Fail2Ban watching SSH with repeat offender rules |
| Firewall | Default-deny inbound, explicit allowlist only |
| Audit logging | auditd enabled for system call tracking |
| Core dumps disabled | Prevents credential leakage from crashes |
| Legacy packages removed | telnet, rsh, nis and others removed |

---

## 📋 Prerequisites

- **Ansible** 2.14+ on your local machine
- **Python** 3.8+ on target servers
- **SSH access** to target servers (key-based recommended)
- **sudo** or **root** access on target servers

```bash
# Install Ansible (Ubuntu/Debian)
sudo apt install ansible -y

# Or via pip
pip install ansible

# Install required collections
ansible-galaxy collection install -r requirements.yml
```

---

## 📄 License

MIT © [Anas Tanveer](https://github.com/anastanveer653)
