# OwnCloud Docker

## Étape 1 : Installation d'OwnCloud avec Docker

1. **Installation de Docker**  
   Pour commencer, vous devez installer Docker. Pour cela, récupérez le script depuis mon GitHub dans le dossier `bilanprojet` en utilisant la commande suivante :  
   `git clone https://github.com/UgoBozion/bilanprojet`

2. **Exécution du script d'installation**  
   Ensuite, exécutez le script d'installation de Docker avec la commande :  
   `./install_docker.sh`

3. **Téléchargement de l'image OwnCloud**  
   Téléchargez l'image d'OwnCloud avec la commande Docker suivante :  
   `docker pull owncloud`

4. **Lancement du conteneur OwnCloud**  
   Lancez le conteneur avec la commande Docker suivante :  
   `docker run -d -p 8080:80 --name owncloud --restart=always -v owncloud_data:/var/www/html owncloud`  
   L'option `--restart=always` permet de redémarrer le conteneur automatiquement après chaque redémarrage de la machine afin de conserver les fichiers d'OwnCloud.

## Étape 2 : Installation et configuration du client OwnCloud sur Windows pour la synchronisation des fichiers

1. **Accéder à l'interface Web d'OwnCloud**  
   Vous pouvez accéder à l'interface web d'OwnCloud en vous rendant à l'adresse suivante :  
   `http://<IP_du_serveur>:8080`  
   Créez un compte administrateur avec un mot de passe.

2. **Installation du client OwnCloud sur Windows**  
   Téléchargez le client OwnCloud pour Windows via le lien suivant :  
   `https://owncloud.com/desktop-app/`

3. **Configuration du client OwnCloud**  
   Lors de la première utilisation du client, renseignez l'adresse du serveur sous le format suivant :  
   `http://<IP_du_serveur>:8080`  
   Connectez-vous et vous pourrez synchroniser les fichiers entre votre machine Windows et OwnCloud.

OwnCloud offre diverses fonctionnalités comme l'intégration LDAP, les communications sécurisées via SSL, la possibilité d'utiliser OwnCloud comme serveur FTP, l'authentification à plusieurs facteurs (MFA), ainsi que de nombreuses autres extensions.

## Mise en œuvre d'un espace de stockage Cloud

Dans notre cas, un serveur de stockage Cloud est installé dans une annexe de la clinique, où il enregistre les logs téléphoniques sous format CSV. Le DSI souhaite centraliser les logs de cinq annexes sur un serveur FTP.

1. **Création d'un répertoire sur OwnCloud**  
   Pour ce faire, rendez-vous sur l'interface web d'OwnCloud, cliquez sur le bouton "+" dans la section des fichiers, puis choisissez "Dossier". Créez un dossier nommé `toip` et placez-y un fichier au format `.csv`.

2. **Création d'un répertoire d'archivage local**  
   Sur la machine où OwnCloud est stocké, créez un répertoire pour les archives, par exemple :  
   `/root/sauvegardezip`  
   Ce répertoire servira à stocker les fichiers avant leur compression.

3. **Vérification des permissions**  
   Assurez-vous que l'utilisateur possède les permissions nécessaires pour effectuer un transfert vers le serveur FTP. De mon côté, l'utilisateur utilisé est `ftpuser`.

4. **Installation de `zip`**  
   Dans mon script, il est nécessaire d'installer l'outil `zip` pour pouvoir compresser les fichiers avant leur transfert. Pour ce faire, utilisez la commande :  
   `apt install zip`

5. **Exécution du script de sauvegarde**  
   Vous pouvez récupérer et exécuter le script de sauvegarde depuis mon GitHub avec les commandes suivantes :  
   `git clone https://github.com/UgoBozion/stockage-et-archivage-auto`  
   `cd stockage-et-archivage-auto`  
   `./backup.sh`  
   Si vous n'avez pas les permissions pour exécuter le script, il suffit de changer les permissions avec la commande :  
   `chmod +x backup.sh`

## Automatisation de la sauvegarde avec Cron

1. **Configuration de Cron**  
   Pour automatiser l'exécution du script, utilisez la commande suivante :  
   `crontab -e`  
   Choisissez l'option 1, puis ajoutez la ligne suivante pour exécuter le script chaque jour à 23h45 :  
   `45 23 * * * /root/sauvegardezip/backup.sh`  
   Enregistrez en appuyant sur `Ctrl + X`, puis `O` et `Entrée`.

La syntaxe du cron est la suivante :  
- `45` : minute (45 minutes)  
- `23` : heure (23h)  
- `*` : chaque jour  
- `*` : chaque mois  
- `*` : chaque jour de la semaine  
- `/root/sauvegardezip/backup.sh` : chemin du script à exécuter

Ainsi, le script sera exécuté tous les jours à 23h45 pour effectuer la sauvegarde et l'archivage automatique.
