#!/bin/bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Vérification de l'installation de Docker
echo "Vérification de l'installation de Docker"
sudo systemctl enable docker
sudo systemctl start docker

# Installation de Ansible
echo "Installation de Ansible"
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible


# Télécharger la dernière version de Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.4.0/node_exporter-1.4.0.linux-amd64.tar.gz

# Extraire l'archive téléchargée
tar xvfz node_exporter-1.4.0.linux-amd64.tar.gz

# Déplacer les fichiers extraits vers le répertoire /usr/local/bin
sudo mv node_exporter-1.4.0.linux-amd64/node_exporter /usr/local/bin/

# Supprimer les fichiers d'archive et les fichiers temporaires
rm -rf node_exporter-1.4.0.linux-amd64.tar.gz node_exporter-1.4.0.linux-amd64

# Créer un fichier de service systemd pour Node Exporter
echo "[Unit]
Description=Node Exporter
After=network.target

[Service]
User=root
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target" | sudo tee /etc/systemd/system/node_exporter.service

# Recharger systemd pour prendre en compte le nouveau service
sudo systemctl daemon-reload

# Activer et démarrer le service Node Exporter
echo "Démarrage de Node Exporter"
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

ansible-playbook playbooks/network_config.yml
ansible-playbook -i inventaire.ini playbooks/conteneur_config.yml
ansible-playbook -i inventaire.ini playbooks/prometheus_config.yml
ansible-playbook -i inventaire.ini playbooks/grafana_config.yml
ansible-playbook -i inventaire.ini playbooks/alertmanager_config.yml
