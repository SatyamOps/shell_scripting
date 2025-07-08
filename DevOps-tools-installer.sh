#!/bin/bash

# Extended package installation script for various Linux distributions
# Usage: ./install_packages_extended.sh

echo "Supported OS types: ubuntu, fedora, centos, rhel, debian, kali, mint, suse, amazon, oracle, scientific"
read -p "Enter your Linux OS type: " os_input
OS_TYPE=$(echo "$os_input" | tr '[:upper:]' '[:lower:]')

# Determine package manager based on OS type
case $OS_TYPE in
    fedora|rhel|centos|amazon|oracle|scientific)
        PKG_MANAGER="yum"
        OS_FAMILY="redhat"
        ;;
    ubuntu|debian|kali|mint|suse)
        PKG_MANAGER="apt"
        OS_FAMILY="debian"
        ;;
    *)
        echo "Unsupported OS type: $1"
        exit 1
        ;;
esac

echo "Detected $OS_FAMILY-based system. Using $PKG_MANAGER package manager."

# Update system packages
echo "Updating system packages..."
if [ "$OS_FAMILY" = "redhat" ]; then
    sudo yum update -y
else
    sudo apt update && sudo apt upgrade -y
fi
echo "System update completed."

# Create log file
LOG_FILE="/tmp/package_install_$(date +%Y%m%d_%H%M%S).log"
echo "Installation log: $LOG_FILE"

# Extended package list
PACKAGES=("mariadb" "go" "prometheus" "grafana" "loki" "promtail" "argocd" "mongodb" "github" "git" "java" "python" "nodejs" "nginx" "terraform" "docker" "mysql" "postgresql" "kubernetes" "jenkins" "ansible" "helm" "vault" "consul" "nomad" "packer" "vagrant" "minikube" "kind" "istio" "linkerd" "fluentd" "elasticsearch" "kibana" "logstash" "redis" "rabbitmq" "kafka" "zookeeper" "etcd" "haproxy" "traefik" "caddy" "sonarqube" "nexus" "artifactory" "maven" "gradle" "sbt" "npm" "yarn" "pip" "composer" "bundler")
INSTALLED_PACKAGES=()
JENKINS_INSTALLED=false

# Function to install package
install_package() {
    local package=$1
    echo "Installing $package..." | tee -a "$LOG_FILE"
    
    # Check if package already installed
    if command -v "$package" &> /dev/null 2>&1; then
        echo "$package is already installed, skipping..." | tee -a "$LOG_FILE"
        return 0
    fi
    
    case $package in
        mariadb)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y mariadb-server mariadb
            else
                sudo apt update && sudo apt install -y mariadb-server mariadb-client
            fi
            ;;
        go)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y golang
            else
                sudo apt update && sudo apt install -y golang-go
            fi
            ;;
        prometheus)
            PROM_VERSION=$(curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
            wget https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz
            tar xvfz prometheus-${PROM_VERSION}.linux-amd64.tar.gz
            sudo mv prometheus-${PROM_VERSION}.linux-amd64/prometheus /usr/local/bin/
            sudo mv prometheus-${PROM_VERSION}.linux-amd64/promtool /usr/local/bin/
            rm -rf prometheus-${PROM_VERSION}*
            ;;
        grafana)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo tee /etc/yum.repos.d/grafana.repo <<EOF
[grafana]
name=grafana
baseurl=https://rpm.grafana.com
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://rpm.grafana.com/gpg.key
EOF
                sudo yum install -y grafana
            else
                sudo mkdir -p /etc/apt/keyrings/
                wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
                echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
                sudo apt update && sudo apt install -y grafana
            fi
            ;;
        loki)
            LOKI_VERSION=$(curl -s https://api.github.com/repos/grafana/loki/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
            wget https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/loki-linux-amd64.zip
            unzip loki-linux-amd64.zip
            sudo mv loki-linux-amd64 /usr/local/bin/loki
            rm loki-linux-amd64.zip
            ;;
        promtail)
            LOKI_VERSION=$(curl -s https://api.github.com/repos/grafana/loki/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
            wget https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/promtail-linux-amd64.zip
            unzip promtail-linux-amd64.zip
            sudo mv promtail-linux-amd64 /usr/local/bin/promtail
            rm promtail-linux-amd64.zip
            ;;
        argocd)
            curl -sSL -o /tmp/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
            sudo install -m 555 /tmp/argocd /usr/local/bin/argocd
            rm /tmp/argocd
            ;;
        mongodb)
            if [ "$OS_FAMILY" = "redhat" ]; then
                echo '[mongodb-org-7.0]' | sudo tee /etc/yum.repos.d/mongodb-org-7.0.repo
                echo 'name=MongoDB Repository' | sudo tee -a /etc/yum.repos.d/mongodb-org-7.0.repo
                echo 'baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/7.0/x86_64/' | sudo tee -a /etc/yum.repos.d/mongodb-org-7.0.repo
                echo 'gpgcheck=1' | sudo tee -a /etc/yum.repos.d/mongodb-org-7.0.repo
                echo 'enabled=1' | sudo tee -a /etc/yum.repos.d/mongodb-org-7.0.repo
                echo 'gpgkey=https://www.mongodb.org/static/pgp/server-7.0.asc' | sudo tee -a /etc/yum.repos.d/mongodb-org-7.0.repo
                sudo yum install -y mongodb-org
            else
                curl -fsSL https://pgp.mongodb.com/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
                echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
                sudo apt update && sudo apt install -y mongodb-org
            fi
            ;;
        github)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
                sudo yum install -y gh
            else
                curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
                sudo apt update && sudo apt install -y gh
            fi
            ;;
        git)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y git
            else
                sudo apt update && sudo apt install -y git
            fi
            ;;
        java)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y java-11-openjdk
            else
                sudo apt update && sudo apt install -y default-jdk
            fi
            ;;
        python)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y python3 python3-pip
            else
                sudo apt update && sudo apt install -y python3 python3-pip
            fi
            ;;
        nodejs)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y nodejs npm
            else
                sudo apt update && sudo apt install -y nodejs npm
            fi
            ;;
        nginx)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y nginx
            else
                sudo apt update && sudo apt install -y nginx
            fi
            ;;
        terraform)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y yum-utils
                sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
                sudo yum install -y terraform
            else
                wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
                echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
                sudo apt update && sudo apt install -y terraform
            fi
            ;;
        docker)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y docker
                sudo systemctl start docker
                sudo systemctl enable docker
            else
                sudo apt update && sudo apt install -y docker.io
                sudo systemctl start docker
                sudo systemctl enable docker
            fi
            ;;
        mysql)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y mysql-server
            else
                sudo apt update && sudo apt install -y mysql-server
            fi
            ;;
        postgresql)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y postgresql postgresql-server
            else
                sudo apt update && sudo apt install -y postgresql postgresql-contrib
            fi
            ;;
        kubernetes)
            if [ "$OS_FAMILY" = "redhat" ]; then
                cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
EOF
                sudo yum install -y kubectl
            else
                curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
                echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
                sudo apt update && sudo apt install -y kubectl
            fi
            ;;
        jenkins)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
                sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
                sudo yum install -y fontconfig java-17-openjdk jenkins
                sudo systemctl start jenkins
                sudo systemctl enable jenkins
            else
                curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
                echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
                sudo apt update && sudo apt install -y fontconfig openjdk-17-jre jenkins
                sudo systemctl start jenkins
                sudo systemctl enable jenkins
            fi
            JENKINS_INSTALLED=true
            ;;
        ansible)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y ansible
            else
                sudo apt update && sudo apt install -y ansible
            fi
            ;;
        helm)
            curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
            ;;
        vault)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
                sudo yum install -y vault
            else
                wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
                echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
                sudo apt update && sudo apt install -y vault
            fi
            ;;
        consul)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y consul
            else
                sudo apt update && sudo apt install -y consul
            fi
            ;;
        nomad)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y nomad
            else
                sudo apt update && sudo apt install -y nomad
            fi
            ;;
        packer)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y packer
            else
                sudo apt update && sudo apt install -y packer
            fi
            ;;
        vagrant)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y vagrant
            else
                sudo apt update && sudo apt install -y vagrant
            fi
            ;;
        minikube)
            curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
            sudo install minikube-linux-amd64 /usr/local/bin/minikube
            rm minikube-linux-amd64
            ;;
        kind)
            curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
            chmod +x ./kind
            sudo mv ./kind /usr/local/bin/kind
            ;;
        istio)
            curl -L https://istio.io/downloadIstio | sh -
            sudo mv istio-*/bin/istioctl /usr/local/bin/
            rm -rf istio-*
            ;;
        linkerd)
            curl -sL https://run.linkerd.io/install | sh
            sudo mv ~/.linkerd2/bin/linkerd /usr/local/bin/
            ;;
        fluentd)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y td-agent
            else
                curl -L https://toolbelt.treasuredata.com/sh/install-ubuntu-focal-td-agent4.sh | sh
            fi
            ;;
        elasticsearch)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
                echo '[elasticsearch]' | sudo tee /etc/yum.repos.d/elasticsearch.repo
                echo 'name=Elasticsearch repository for 8.x packages' | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
                echo 'baseurl=https://artifacts.elastic.co/packages/8.x/yum' | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
                echo 'gpgcheck=1' | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
                echo 'gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch' | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
                echo 'enabled=0' | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
                echo 'autorefresh=1' | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
                echo 'type=rpm-md' | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
                sudo yum install -y --enablerepo=elasticsearch elasticsearch
            else
                wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
                echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
                sudo apt update && sudo apt install -y elasticsearch
            fi
            ;;
        kibana)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y --enablerepo=elasticsearch kibana
            else
                sudo apt update && sudo apt install -y kibana
            fi
            ;;
        logstash)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y --enablerepo=elasticsearch logstash
            else
                sudo apt update && sudo apt install -y logstash
            fi
            ;;
        redis)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y redis
            else
                sudo apt update && sudo apt install -y redis-server
            fi
            ;;
        rabbitmq)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y rabbitmq-server
            else
                sudo apt update && sudo apt install -y rabbitmq-server
            fi
            ;;
        kafka)
            wget https://downloads.apache.org/kafka/2.13-3.5.0/kafka_2.13-3.5.0.tgz
            tar -xzf kafka_2.13-3.5.0.tgz
            sudo mv kafka_2.13-3.5.0 /opt/kafka
            rm kafka_2.13-3.5.0.tgz
            ;;
        zookeeper)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y zookeeper
            else
                sudo apt update && sudo apt install -y zookeeper
            fi
            ;;
        etcd)
            ETCD_VER=v3.5.9
            curl -L https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
            tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/
            sudo mv /tmp/etcd-${ETCD_VER}-linux-amd64/etcd* /usr/local/bin/
            rm -rf /tmp/etcd-*
            ;;
        haproxy)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y haproxy
            else
                sudo apt update && sudo apt install -y haproxy
            fi
            ;;
        traefik)
            wget https://github.com/traefik/traefik/releases/latest/download/traefik_linux_amd64.tar.gz
            tar -xzf traefik_linux_amd64.tar.gz
            sudo mv traefik /usr/local/bin/
            rm traefik_linux_amd64.tar.gz
            ;;
        caddy)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y 'dnf-command(copr)'
                sudo dnf copr enable -y @caddy/caddy
                sudo yum install -y caddy
            else
                sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
                curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
                curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
                sudo apt update && sudo apt install -y caddy
            fi
            ;;
        sonarqube)
            wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.1.69595.zip
            unzip sonarqube-9.9.1.69595.zip
            sudo mv sonarqube-9.9.1.69595 /opt/sonarqube
            rm sonarqube-9.9.1.69595.zip
            ;;
        nexus)
            wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz
            tar -xzf latest-unix.tar.gz
            sudo mv nexus-* /opt/nexus
            rm latest-unix.tar.gz
            ;;
        artifactory)
            if [ "$OS_FAMILY" = "redhat" ]; then
                wget https://releases.jfrog.io/artifactory/bintray-artifactory-rpms/artifactory-oss-7.63.14.rpm
                sudo yum install -y ./artifactory-oss-7.63.14.rpm
                rm artifactory-oss-7.63.14.rpm
            else
                wget -qO - https://releases.jfrog.io/artifactory/api/gpg/key/public | sudo apt-key add -
                echo "deb https://releases.jfrog.io/artifactory/artifactory-debs xenial main" | sudo tee /etc/apt/sources.list.d/artifactory.list
                sudo apt update && sudo apt install -y jfrog-artifactory-oss
            fi
            ;;
        maven)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y maven
            else
                sudo apt update && sudo apt install -y maven
            fi
            ;;
        gradle)
            wget https://services.gradle.org/distributions/gradle-8.3-bin.zip
            unzip gradle-8.3-bin.zip
            sudo mv gradle-8.3 /opt/gradle
            sudo ln -s /opt/gradle/bin/gradle /usr/local/bin/gradle
            rm gradle-8.3-bin.zip
            ;;
        sbt)
            if [ "$OS_FAMILY" = "redhat" ]; then
                curl -L https://www.scala-sbt.org/sbt-rpm.repo > sbt-rpm.repo
                sudo mv sbt-rpm.repo /etc/yum.repos.d/
                sudo yum install -y sbt
            else
                echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list
                curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add
                sudo apt update && sudo apt install -y sbt
            fi
            ;;
        npm)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y npm
            else
                sudo apt update && sudo apt install -y npm
            fi
            ;;
        yarn)
            curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
            echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y yarn
            else
                sudo apt update && sudo apt install -y yarn
            fi
            ;;
        pip)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y python3-pip
            else
                sudo apt update && sudo apt install -y python3-pip
            fi
            ;;
        composer)
            curl -sS https://getcomposer.org/installer | php
            sudo mv composer.phar /usr/local/bin/composer
            ;;
        bundler)
            if [ "$OS_FAMILY" = "redhat" ]; then
                sudo yum install -y ruby rubygems
                sudo gem install bundler
            else
                sudo apt update && sudo apt install -y ruby bundler
            fi
            ;;
    esac
    
    # Log installation result
    if [ $? -eq 0 ]; then
        echo "✓ $package installed successfully" | tee -a "$LOG_FILE"
    else
        echo "✗ $package installation failed" | tee -a "$LOG_FILE"
    fi
}

# Function to get package version
get_version() {
    local package=$1
    case $package in
        mariadb) mysql --version 2>/dev/null || echo "MariaDB installed" ;;
        go) go version 2>/dev/null || echo "Go installed" ;;
        prometheus) prometheus --version 2>/dev/null | head -n 1 || echo "Prometheus installed" ;;
        grafana) grafana-server --version 2>/dev/null || echo "Grafana installed" ;;
        loki) loki --version 2>/dev/null || echo "Loki installed" ;;
        promtail) promtail --version 2>/dev/null || echo "Promtail installed" ;;
        argocd) argocd version --client 2>/dev/null || echo "ArgoCD installed" ;;
        mongodb) mongod --version 2>/dev/null | head -n 1 || echo "MongoDB installed" ;;
        github) gh --version 2>/dev/null || echo "GitHub CLI installed" ;;
        git) git --version ;;
        java) java -version 2>&1 | head -n 1 ;;
        python) python3 --version ;;
        nodejs) node --version ;;
        nginx) nginx -v 2>&1 ;;
        terraform) terraform --version | head -n 1 ;;
        docker) docker --version ;;
        mysql) mysql --version ;;
        postgresql) psql --version ;;
        kubernetes) kubectl version --client --short 2>/dev/null || echo "kubectl installed" ;;
        jenkins) echo "Jenkins installed" ;;
        ansible) ansible --version | head -n 1 ;;
        helm) helm version --short 2>/dev/null || echo "Helm installed" ;;
        vault) vault --version 2>/dev/null || echo "Vault installed" ;;
        consul) consul --version 2>/dev/null || echo "Consul installed" ;;
        nomad) nomad --version 2>/dev/null || echo "Nomad installed" ;;
        packer) packer --version 2>/dev/null || echo "Packer installed" ;;
        vagrant) vagrant --version 2>/dev/null || echo "Vagrant installed" ;;
        minikube) minikube version --short 2>/dev/null || echo "Minikube installed" ;;
        kind) kind --version 2>/dev/null || echo "Kind installed" ;;
        istio) istioctl version --short 2>/dev/null || echo "Istio installed" ;;
        linkerd) linkerd version --short 2>/dev/null || echo "Linkerd installed" ;;
        fluentd) td-agent --version 2>/dev/null || echo "Fluentd installed" ;;
        elasticsearch) echo "Elasticsearch installed" ;;
        kibana) echo "Kibana installed" ;;
        logstash) echo "Logstash installed" ;;
        redis) redis-server --version 2>/dev/null || echo "Redis installed" ;;
        rabbitmq) rabbitmqctl version 2>/dev/null || echo "RabbitMQ installed" ;;
        kafka) echo "Kafka installed" ;;
        zookeeper) echo "Zookeeper installed" ;;
        etcd) etcd --version 2>/dev/null || echo "etcd installed" ;;
        haproxy) haproxy -v 2>/dev/null || echo "HAProxy installed" ;;
        traefik) traefik version 2>/dev/null || echo "Traefik installed" ;;
        caddy) caddy version 2>/dev/null || echo "Caddy installed" ;;
        sonarqube) echo "SonarQube installed" ;;
        nexus) echo "Nexus installed" ;;
        artifactory) echo "Artifactory installed" ;;
        maven) mvn --version 2>/dev/null || echo "Maven installed" ;;
        gradle) gradle --version 2>/dev/null || echo "Gradle installed" ;;
        sbt) sbt --version 2>/dev/null || echo "SBT installed" ;;
        npm) npm --version 2>/dev/null || echo "NPM installed" ;;
        yarn) yarn --version 2>/dev/null || echo "Yarn installed" ;;
        pip) pip3 --version 2>/dev/null || echo "Pip installed" ;;
        composer) composer --version 2>/dev/null || echo "Composer installed" ;;
        bundler) bundler --version 2>/dev/null || echo "Bundler installed" ;;
        *) echo "$package: version unknown" ;;
    esac
}

# Main installation loop
for package in "${PACKAGES[@]}"; do
    read -p "Do you want to install $package? (y/n): " -n 1 response
    echo
    if [[ "$response" =~ ^[Yy]$ ]]; then
        install_package "$package"
        INSTALLED_PACKAGES+=("$package")
    fi
done

# Clear screen and show versions
clear
echo "=== Installed Package Versions ==="
for package in "${INSTALLED_PACKAGES[@]}"; do
    echo "$package: $(get_version "$package")"
done

# Ask for additional packages
while true; do
    read -p "Do you want to install any additional package? (y/n): " -n 1 response
    echo
    if [[ "$response" =~ ^[Yy]$ ]]; then
        read -p "Enter the package name: " additional_package
        if [ "$OS_FAMILY" = "redhat" ]; then
            sudo yum install -y "$additional_package"
        else
            sudo apt update && sudo apt install -y "$additional_package"
        fi
        INSTALLED_PACKAGES+=("$additional_package")
        
        # Show updated versions
        clear
        echo "=== Updated Package Versions ==="
        for package in "${INSTALLED_PACKAGES[@]}"; do
            echo "$package: $(get_version "$package")"
        done
    else
        break
    fi
done

# Display Jenkins initial admin password if Jenkins was installed
if [ "$JENKINS_INSTALLED" = true ]; then
    echo
    echo "=== Jenkins Initial Admin Password ==="
    if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
        echo "Jenkins Initial Admin Password: $(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)"
        echo "Access Jenkins at: http://localhost:8080"
    else
        echo "Jenkins password file not found. Please check Jenkins installation."
    fi

# Show service status for key services
echo
echo "=== Service Status ==="
for service in docker jenkins nginx mysql postgresql mariadb mongodb grafana elasticsearch kibana logstash redis rabbitmq haproxy; do
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        echo "✓ $service: running"
    elif systemctl list-unit-files | grep -q "$service"; then
        echo "○ $service: stopped"
    fi
done

echo
echo "Installation completed! Log saved to: $LOG_FILE"
echo "Thanks for using this script!"
