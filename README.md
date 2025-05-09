# 🚀 AWX Tower Setup, Configuration, and Integration with GitHub

*Author: Satyam Maheshwari*

In the fast-paced world of DevOps, automation is the backbone of efficiency and reliability. **AWX Tower** serves as the open-source version of Ansible Tower, providing a powerful web-based interface to manage, schedule, and monitor Ansible playbooks. Mastering AWX Tower means gaining complete control over infrastructure automation with visibility and centralized execution.

Manually running Ansible playbooks can be manageable at first, but as environments grow more complex, automation becomes a necessity. Setting up AWX Tower on AWS provides seamless orchestration of playbooks across environments. With two EC2 instances — a Master Node for AWX Tower and a Worker Node for executing tasks — this guide walks through the setup of a scalable and automated Ansible management system.

---

## ✅ **Prerequisites**

- 2 EC2 instances: One as Master and the other as Worker.
- **Instance Type:** t2.medium or higher.
- **OS:** Ubuntu 20.04 or 22.04 recommended.
- **SSH Access:** Ensure you can SSH into both instances.
- **GitHub Account & Repository.**

---

## 🏗️ **Architecture Overview**

```plaintext
[Master Node (AWX Tower)]
    └── AWX Tower Application
    └── Docker, Ansible, Node.js, Python

[Worker Node]
    └── Target for Playbook Execution
```

The Master Node will host the AWX Tower, while the Worker Node will be the target for Ansible playbooks executed via AWX.

---

## 🔧 **Step 1: Execute the AWX Tower Setup Script**

Run the following command on your Master Node:

```bash
<Complete script you provided>
```

This script performs the following:

- ✅ Installs Docker, Docker Compose, Ansible, Node.js, and dependencies.
- ✅ Downloads AWX Tower version 17.1.0 and sets up the environment.
- ✅ Configures admin credentials and secret key in the inventory file.
- ✅ Executes the Ansible playbook to install AWX Tower.

---

## 🛠️ **Step 2: Configure AWX Tower**

### 1️⃣ **Create Credentials**

Navigate to **AWX Tower → Credentials → Add**

- Name: `GitHub-Credentials`
- Credential Type: `Source Control`
- Username: `<your_github_username>`
- Password: `<your_github_personal_access_token>`
- Organization: `Default` or your preferred organization

### 2️⃣ **Create Project**

Navigate to **Projects → Add**

- Name: `My-AWX-Project`
- Source Control Type: `Git`
- Repository URL: `<your_github_repo_url>`
- Credential Type: `GitHub-Credentials`
- Organization: `Default`

---

## 🔑 **Step 3: Exchange SSH Keys**

On the **Master Node**:

```bash
ssh-keygen -t rsa -b 4096 -C "id_rsa"
```

Copy the public key to the **Worker Node**:

```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub user@worker-node-ip
```

Or manually:

```bash
cat ~/.ssh/id_rsa.pub | ssh user@worker-node-ip 'cat >> ~/.ssh/authorized_keys'
```

---

## 📋 **Step 4: Create Inventory and Job Template**

### **Create Inventory:**

Navigate to **Inventories → Add**

- Name: `My-Inventory`
- Description: `AWX Worker Nodes`
- Organization: `Default`

**Add Hosts:**

- Hostname: `<worker-node-ip>`
- Variables: Leave empty or customize if needed

### **Create Job Template:**

Navigate to **Templates → Add → Job Template**

- Name: `Deploy Playbook`
- Job Type: `Run`
- Inventory: `My-Inventory`
- Project: `My-AWX-Project`
- Playbook: `<your_playbook.yml>`
- Credentials: `GitHub-Credentials`

---

## ✅ **Step 5: Test Your Setup**

To test the setup, launch the Job Template from **AWX Tower → Templates → Deploy Playbook → Launch**. Verify execution and output logs.

---

## 🐛 **Troubleshooting**

1️⃣ **If Docker services fail to start, check logs:**

```bash
sudo journalctl -u docker.service
```

2️⃣ **AWX Tower UI not accessible:**

- Verify ports are open: `8080` for AWX UI.

3️⃣ **Permission issues during key exchange:**

Ensure correct permissions:

```bash
chmod 600 ~/.ssh/authorized_keys
```

---

🎉 **Congratulations!** You have successfully set up and configured AWX Tower with a Master and Worker Node architecture.
