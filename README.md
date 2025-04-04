# Post-Installation Setup Script 🚀

Ce script de post-installation est destiné à automatiser la configuration d'un environnement Linux après une installation de base. Il installe des paquets nécessaires, met à jour le système, personnalise le fichier `.bashrc`, `.nanorc` et le MOTD, et configure SSH pour une authentification par clé.

## Contenu du projet 📂

- **`postinstall.sh`** : Le script principal exécuté pour configurer l'environnement.
- **Dossier `lists/`** : Contient un fichier `packages.txt` listant les paquets à installer pendant l'exécution du script.
- **Dossier `config/`** : Contient des fichiers de configuration pour personnaliser l'environnement de l'utilisateur (`bashrc.append`, `motd.txt`, `nanorc.append`).

## Prérequis ⚙️

Avant d'exécuter le script, assurez-vous que :

1. Vous utilisez un système Linux avec un gestionnaire de paquets basé sur `apt` (Debian/Ubuntu et dérivés).
2. Vous avez un accès root ou sudo pour exécuter le script.
3. Les fichiers de configuration doivent être présents dans le répertoire `config/`. Vous pouvez personnaliser ces fichiers avant de lancer le script pour qu'ils correspondent à vos préférences.

## Étapes de configuration 🛠️

### 1. **Configurer le fichier `packages.txt` 📦**
Le fichier `lists/packages.txt` contient une liste de paquets à installer sur votre machine. Vous pouvez modifier ce fichier pour ajouter ou supprimer des paquets selon vos besoins. Voici un exemple de contenu par défaut dans `packages.txt` :

    nmap
    net-tools
    htop
    curl
    htop
    sudo
    tree
    thefuck
    mtr
    clip

### 2. Personnaliser le fichier .bashrc avec bashrc.append 🎨
Le fichier config/bashrc.append permet de personnaliser le comportement de votre terminal en ajoutant des alias, des messages de bienvenue, et des informations dynamiques comme la date et l'heure. Voici un exemple de contenu par défaut dans bashrc.append :

    alias ll='ls -la --color=auto'
    alias gs='git status'
    echo "Bienvenue chacal, $(whoami)!"
    echo "Il est actuellement : $(date)"
    PS1='\u@\h:\w\$ '
Modifiez ce fichier si vous souhaitez ajouter ou supprimer des alias ou d'autres paramètres de personnalisation pour votre terminal.

### 3. Personnaliser le fichier nano avec nanorc.append ✨
Le fichier config/nanorc.append permet de configurer nano pour améliorer l'expérience utilisateur. Par exemple, il peut afficher des numéros de ligne, activer le défilement fluide, et ajouter des couleurs à la syntaxe. Voici un exemple de contenu par défaut dans nanorc.append :

    set linenumbers
    set softwrap
    set tabsize 4
    set mouse
    set smooth

    syntax "bash" "\.sh$"
    color green "\b(if|then|else|fi|for|while|do|done|return)\b"
    color cyan "\b(function|local)\b"
    color yellow "\b(\$[A-Za-z_][A-Za-z0-9_]*)\b"
    bind ^S savefile
    bind ^Q quit
N'hésitez pas à ajuster ce fichier pour activer ou désactiver certaines options ou couleurs selon vos préférences.

### 4. Personnaliser le fichier motd.txt 📝
Le fichier config/motd.txt vous permet de personnaliser le message affiché lors de la connexion. Vous pouvez y mettre un message de bienvenue, des informations système, ou toute autre information pertinente. Par exemple :

    Bienvenue sur votre serveur ! 🎉
    Il est actuellement : $(date)

Adaptez ce fichier à vos besoins avant de lancer le script.

## Exécution du script 🏃‍♂️
Une fois les fichiers personnalisés, vous êtes prêt à exécuter le script. Suivez les étapes suivantes :

### 1. Clonez ce repository sur votre machine :
    git clone https://github.com/Diokarn/tssr-linux-debian-post-install.git
    cd tssr-linux-debian-post-install

### 2. Rendez le script exécutable :
    chmod +x postinstall.sh

### 3. Exécutez le script :
    sudo ./postinstall.sh

Le script mettra à jour votre système, installera les paquets nécessaires, et personnalisera votre environnement selon les fichiers que vous avez configurés.

## Dépannage 🛠️

Si le script échoue, vérifiez les permissions des fichiers et assurez-vous que le script est exécuté en tant que root (sudo).

Consultez le fichier de logs logs/postinstall_<timestamp>.log pour plus de détails sur les erreurs éventuelles. 

