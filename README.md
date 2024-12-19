Ansible Project

Ce projet vise à automatiser le déploiement et la configuration d'une solution de monitoring basée sur Prometheus, Grafana, et Alertmanager, le tout orchestré avec Ansible. Cette solution permet de surveiller l'état des systèmes et des services via des tableaux de bord visuels et des alertes configurables, le tout dans un environnement de conteneurs géré par Docker.
________________________________________
Objectifs du projet
1.	Automatiser le déploiement des services de monitoring pour réduire les erreurs manuelles.
2.	Simplifier la gestion des configurations grâce à Ansible.
3.	Fournir une solution clé en main pour surveiller l'infrastructure et recevoir des alertes 
en temps réel.
4.	Utiliser des conteneurs Docker pour assurer la portabilité et l'isolement des services.
________________________________________
Prérequis
Avant de commencer, assurez-vous que les éléments suivants sont installés sur votre machine :
•	Git : pour cloner le dépôt.
•	Docker: pour gérer les conteneurs.
•	Accessibilité réseau : une adresse IP ou un nom de domaine local pour accéder aux services déployés.
________________________________________
Installation et déploiement
Étape 1 : Récupérer le dépôt
Clonez le dépôt sur votre machine locale :

git clone https://github.com/mouadh15/Ansible-project-main.git

Étape 2 : Lancer le script d'installation
Dans le dossier 
Le script deploy_and_start.sh est conçu pour automatiser tout le processus. 
Exécutez-le avec la commande suivante :
./deploy_and_start.sh

Ce script effectue les tâches suivantes :
•	Installation des dépendances nécessaires (Docker, Ansible, etc.).
•	Création du réseau Docker nommé sae502 avec le sous-réseau 172.20.0.0/24.
Déploiement des services Prometheus, Grafana, et Alertmanager dans des conteneurs Docker.

Configuration
Configuration du réseau Docker
Le réseau Docker est défini avec les paramètres suivants :
•	Nom : sae502
•	Sous-réseau : 172.20.0.0/24
Ces paramètres peuvent être modifiés dans le fichier de configuration du réseau Ansible.

-  name: Créer un réseau Docker 
   community.docker.docker_network: 
        name: sae502 
        driver: bridge 
        ipam_config:
              - subnet: 172.20.0.0/24 
       state: present
   
IP des services
Les adresses IP statiques des conteneurs sont configurées comme suit :
•	Grafana : 172.20.0.2
•	Prometheus : 172.20.0.3
•	Alertmanager : 172.20.0.4

Assurez-vous que ces adresses ne sont pas en conflit avec votre réseau existant.
Dans le fichier inventaire.ini, vous trouverez les adresses IP des services Grafana, Prometheus et Alertmanager.
[hote] 
192.168.1.27
[grafana] 
172.20.0.2 
[prometheus] 
172.20.0.3 
[alertmanager] 
172.20.0.4 

Accès aux services
Une fois le déploiement terminé, vous pouvez accéder aux services via les adresses suivantes dans votre navigateur :
•	Grafana : http://172.20.0.2:3000
•	Prometheus : http://172.20.0.3:9090
•	Alertmanager : http://172.20.0.4:9093
Par défaut, les identifiants pour Grafana sont configurés comme suit :
•	Utilisateur : administrateur
•	Mot de passe : R00tR00t
Changez-les dès votre première connexion pour sécuriser l'accès.
________________________________________
Cible de Prometheus

Le fichier prometheus.yml contient les cibles des services surveillés :
scrape_interval: 30s
evaluation_interval: 30s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'docker_services'
    static_configs:
      - targets:
          - "172.20.0.2:3000"  # Grafana
          - "172.20.0.4:9093"  # AlertManager

  - job_name: 'machines'
    static_configs:
      - targets:
          - "192.168.1.27:9100" #hote

rule_files:
  - "alert_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - "172.20.0.4:9093"


