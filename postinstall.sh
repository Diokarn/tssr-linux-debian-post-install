#!/bin/bash

# === VARIABLES ===
TIMESTAMP=$(date +"%Y%m%d_%H%M%S") #Pour dire que la date sera config en Y=Année/m=Mois/d=Jour _ H=Heure/M=minutes/S=Seconde
LOG_DIR="./logs" #C'est le repertoire des logs
LOG_FILE="$LOG_DIR/postinstall_$TIMESTAMP.log" #C'est pour dire qu'à l'installation, les logs vont se mettre dans le log file en utilisant la variable de l'horodateur du dessus 
CONFIG_DIR="./config" #repertoire contenant les fichiers de conf
PACKAGE_LIST="./lists/packages.txt" #Si la variable PACKAGE_LIST est appeler il va aller chercher dans le fichier packages.txt
USERNAME=$(logname) #Cette variable est pour utiliser le nom d'utilisateur qui est actuellement connecté 
USER_HOME="/home/$USERNAME" #C'est le chemin du répértoire de l'utilisateur

# === FUNCTIONS ===
# Fonction pour loguer les messages avec un horodatage dans le fichier de log
log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE" # Enregistre dans le fichier de logs
}
# Une fonction qui vérifié si le packet ciblé est déja installé, sinon l'installer
check_and_install() {
  local pkg=$1 # ça pointe sur un paquet à installer et vérifier
  if dpkg -s "$pkg" &>/dev/null; then #Vérifie si le paquet est déja installé ou pas 
    log "$pkg is already installed."  #Si le paquet est installé, dans le fichier de log écrira "is already installed"
  else
    log "Installing $pkg..." #Pour loger que le packet est en cour d'installation
    apt install -y "$pkg" &>>"$LOG_FILE" # installation du packet et le renseigne dans le fichier de log 
    if [ $? -eq 0 ]; then #condition de si l'installation à réussi
      log "$pkg successfully installed." #Loger que l'installation est ok 
    else #Pour dire par contre enfin je crois si j'ai bien piger
      log "Failed to install $pkg." #Dit "Failed to install" en cas d'échec de l'installation
    fi
  fi
}
# Fonction pour demander une réponse oui/non à l'utilisateur
ask_yes_no() {
  read -p "$1 [y/N]: " answer
  case "$answer" in
    [Yy]* ) return 0 ;; #Si l'utilisateur tape y ou Y, valide l'installation
    * ) return 1 ;; #Sinon l'utilisateur ne valide pas 
  esac
}

# === INITIAL SETUP ===
mkdir -p "$LOG_DIR" #Créer le répertoir de log si il n'y en a pas 
touch "$LOG_FILE" #Créer le fichier de log
log "Starting post-installation script. Logged user: $USERNAME"

#Vérifie si le script est bien executé en root
if [ "$EUID" -ne 0 ]; then
  log "This script must be run as root." 
  exit 1
fi

# === 1. SYSTEM UPDATE ===
log "Updating system packages..." #Rensiegne dans les logs que le système ce met à jour les paquets
apt update && apt upgrade -y &>>"$LOG_FILE" #La classique apt update/upgrade pour mettre à jour les paquets du système

# === 2. PACKAGE INSTALLATION ===
if [ -f "$PACKAGE_LIST" ]; then #Vérifie si le fichier de liste des paquets éxiste
  log "Reading package list from $PACKAGE_LIST" 
  while IFS= read -r pkg || [[ -n "$pkg" ]]; do #Lecture de toutes les lignes du fichier des paquets
    [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue #Ignore les espaces et les lignes commencant par #
    check_and_install "$pkg" #Vérifie et installe les paquets
  done < "$PACKAGE_LIST"
else
  log "Package list file $PACKAGE_LIST not found. Skipping package installation." #Si le fichier des paquets n'existe pas, skip l'étape d'installation
fi

# === 3. UPDATE MOTD ===
if [ -f "$CONFIG_DIR/motd.txt" ]; then #Log le début de la mise à jour du MOTD
  cp "$CONFIG_DIR/motd.txt" /etc/motd #Vérifie si le fichier motd.txt existe dans le répértoire de configuration
  log "MOTD updated." #Log que la maj du MOTD à réussi avec succès
else
  log "motd.txt not found." #Si le fichier n'existe pas, log ce message pour dire que le motd n'existe pas 
fi

# === 4. CUSTOM .bashrc ===
if [ -f "$CONFIG_DIR/bashrc.append" ]; then #Vérifie si le fichier bashrc.append existe
  cat "$CONFIG_DIR/bashrc.append" >> "$USER_HOME/.bashrc" #Ajoute le contenue du fichier bashrc.append à la fin du bashrc de l'utilisateur
  chown "$USERNAME:$USERNAME" "$USER_HOME/.bashrc" #Change le propriétaire du fichier .bashrc pour que l'utilisateur puisse le modifier 
  log ".bashrc customized." #Message de log pour dire que la personalisation du bashrc est faite
else
  log "bashrc.append not found." #Si le fichier n'existe pas, log ce message pour dire que le bashrc.append est introuvable
fi

# === 5. CUSTOM .nanorc ===
if [ -f "$CONFIG_DIR/nanorc.append" ]; then #Vérifie que le fichier nanorc.apend existe dans le répertoire de configuration
  cat "$CONFIG_DIR/nanorc.append" >> "$USER_HOME/.nanorc" #Ajoute le contenue de nanorc.append à la fin de .nanorc dans le répértoire perso de l'utilisateur
  chown "$USERNAME:$USERNAME" "$USER_HOME/.nanorc" #Change le propriétaire du fichier .nanorc pour l"utilisateur
  log ".nanorc customized." #Log le fait que la personnalisation de .nanorc à été effectué
else
  log "nanorc.append not found." #Si le fichie n'existe pas, log ce message pour dire que nanorc.append est introuvable
fi

# === 6. ADD SSH PUBLIC KEY ===
if ask_yes_no "Would you like to add a public SSH key?"; then #C'est une demande à l'utilisateur pour confirmer ou non l'ajout d'une clé publique SSH
  read -p "Paste your public SSH key: " ssh_key #Demande à l'utilisateur de de coller sa clé publique SSH
  mkdir -p "$USER_HOME/.ssh" #Créer le repertoire .SSH dans le répertoire perso de l'utilisateur si il n'existe pas
  echo "$ssh_key" >> "$USER_HOME/.ssh/authorized_keys" #Ajoutee la clé publique SSH dans le fichier authorized_keys
  chown -R "$USERNAME:$USERNAME" "$USER_HOME/.ssh" #Modifie le propriétaire du répertoire .ssh et de ses fichiers pour l'utilisateur
  chmod 700 "$USER_HOME/.ssh" #Donne les droits d'accès seulement à l'utilisateur 
  chmod 600 "$USER_HOME/.ssh/authorized_keys" #Donne les droits d'écriture et de lecture seulement à l'utilisateur
  log "SSH public key added." #Log le fait que la clé publique SSH est bien ajouté
fi

# === 7. SSH CONFIGURATION: KEY AUTH ONLY ===
if [ -f /etc/ssh/sshd_config ]; then #Vérifie que le fichier de conf sshd_config existe
  sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config #Désactive l'authentification par mot de passe en SSH
  sed -i 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config #Désactivé l'authentification par challenge ???
  sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config #Active l'authentification par clé publique SSH
  systemctl restart ssh #Redémmare le service SSH pour appliquer les changements
  log "SSH configured to accept key-based authentication only." #Log que SSH est config pour accepter uniquement l'authentification par clé SSH
else
  log "sshd_config file not found." #Log un message d'erreur si le fichier sshd_config n'est pas présent
fi

log "Post-installation script completed." #Log que le script est terminé

exit 0 #Quitte le script avec un code de sortie 