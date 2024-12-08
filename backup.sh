#!/bin/bash

# Variables
SOURCE_DIR="/var/lib/docker/volumes/owncloud_data/_data/data/admin/files"  # Répertoire des données OwnCloud
ARCHIVE_DIR="/root/sauvegardezip"                                          # Répertoire temporaire pour la sauvegarde et la compression
FTP_HOST="192.168.20.120"                                                  # Adresse IP du serveur FTP
FTP_USER="ftpuser"                                                         # Nom d'utilisateur FTP
FTP_PASS="sio2024"                                                         # Mot de passe FTP
FTP_REMOTE_DIR="/home/ftpuser/sauvegardeftp"                               # Répertoire distant sur FTP pour les archives

# Créer un répertoire local pour les sauvegardes s'il n'existe pas
mkdir -p "$ARCHIVE_DIR"

# Étape 1 : Trouver le dernier fichier CSV dans le répertoire Toip
CSV_FILE=$(ls -t $SOURCE_DIR/toip/*.csv | head -n 1)  # Lister les fichiers CSV par ordre de date et prendre le plus récent
TIMESTAMP=$(date +"%d-%m-%Y_%H:%M:%S")
BACKUP_CSV="$ARCHIVE_DIR/sio2-${TIMESTAMP}.csv"

# Vérifier si un fichier CSV existe
if [ -f "$CSV_FILE" ]; then
    cp "$CSV_FILE" "$BACKUP_CSV"
    echo "Sauvegarde locale réussie du fichier CSV : $BACKUP_CSV"
else
    echo "Aucun fichier CSV trouvé dans $SOURCE_DIR/toip/" >&2
    exit 1
fi

# Étape 2 : Compression du dossier Toip sans le chemin absolu
ZIP_FILE="$ARCHIVE_DIR/sio2-${TIMESTAMP}.zip"
echo "Compression du dossier Toip en $ZIP_FILE..."
cd $SOURCE_DIR && zip -r "$ZIP_FILE" "toip"  # Zip uniquement le dossier 'toip' sans le chemin complet

# Vérifier la réussite de la compression
if [ $? -eq 0 ]; then
    echo "Compression réussie : $ZIP_FILE"
else
    echo "Erreur lors de la compression du dossier Toip" >&2
    exit 1
fi

# Étape 3 : Transfert du fichier ZIP vers le serveur FTP
echo "Transfert du fichier compressé vers le serveur FTP ($FTP_HOST)..."

ftp -inv $FTP_HOST <<EOF
user $FTP_USER $FTP_PASS
# Aller dans le bon répertoire distant
cd $FTP_REMOTE_DIR
# Transférer le fichier avec un chemin relatif
put "$ZIP_FILE" "$(basename "$ZIP_FILE")"
bye
EOF

# Vérification du transfert FTP
if [ $? -eq 0 ]; then
    echo "Transfert FTP réussi : $(basename "$ZIP_FILE")"
else
    echo "Erreur lors du transfert FTP." >&2
    exit 1
fi

# Nettoyage des fichiers temporaires
rm -f "$ZIP_FILE"
#echo "Fichiers temporaires supprimés : $ZIP_FILE"

# Fin du script
echo "Script terminé avec succès."
