#!/bin/bash

# 🚀 Script de déploiement automatique du node Turso pour N8N
# 📍 Version corrigée avec gestion Git et déploiement robuste

set -e  # Arrêter en cas d'erreur

echo "🚀 Déploiement automatique du node Turso pour N8N"
echo "📍 Serveur: $(hostname -I | awk '{print $1}'):5678"
echo "⏰ $(date)"
echo ""

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction de log coloré
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# Fonction de nettoyage en cas d'erreur
cleanup() {
    log_error "Erreur détectée, nettoyage en cours..."
    if [ -d "/tmp/turso-deploy" ]; then
        rm -rf /tmp/turso-deploy
    fi
    exit 1
}

trap cleanup ERR

# 1. Vérification de la connectivité réseau
log_info "Vérification de la connectivité réseau..."
if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    log_success "Connectivité Internet OK"
else
    log_error "Pas de connectivité Internet"
    exit 1
fi

# 2. Vérification de Node.js
log_info "Vérification de Node.js..."
if command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node --version)
    log_success "Node.js déjà installé: $NODE_VERSION"
else
    log_info "Installation de Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
    log_success "Node.js installé: $(node --version)"
fi

# 3. Vérification de npm
if command -v npm >/dev/null 2>&1; then
    log_success "npm disponible: $(npm --version)"
else
    log_error "npm non disponible"
    exit 1
fi

# 4. Création du répertoire des nodes personnalisés
log_info "Création du répertoire: /root/.n8n/custom"
mkdir -p /root/.n8n/custom

# 5. Gestion du repository Git
log_info "Gestion du repository Git..."
cd /root/N8n-turso

# Vérifier si le repository existe et est à jour
if [ -d ".git" ]; then
    log_info "Repository Git détecté, mise à jour..."
    git fetch origin
    git reset --hard origin/main 2>/dev/null || git reset --hard origin/master 2>/dev/null || git reset --hard HEAD
    log_success "Repository mis à jour"
else
    log_error "Repository Git non trouvé dans /root/N8n-turso"
    exit 1
fi

# 6. Aller dans le dossier du projet
cd n8n-nodes-turso
if [ ! -f "package.json" ]; then
    log_error "package.json non trouvé dans n8n-nodes-turso"
    exit 1
fi

# 7. Nettoyage et installation des dépendances
log_info "Nettoyage et installation des dépendances..."
rm -rf node_modules package-lock.json
npm cache clean --force
npm install

# 8. Compilation du projet
log_info "Compilation du projet..."
npm run build

# 9. Vérification de la compilation
if [ ! -d "dist" ] || [ ! -f "dist/nodes/Turso.node.js" ]; then
    log_error "Compilation échouée - fichiers manquants"
    ls -la dist/ 2>/dev/null || echo "Dossier dist/ non trouvé"
    exit 1
fi

log_success "Compilation réussie !"

# 10. Copie des fichiers compilés
log_info "Copie des fichiers compilés..."
cp -r dist/* /root/.n8n/custom/

# 11. Vérification de la copie
log_info "Vérification de la copie..."
if [ -f "/root/.n8n/custom/nodes/Turso.node.js" ] && [ -f "/root/.n8n/custom/credentials/TursoApi.credentials.js" ]; then
    log_success "Fichiers copiés avec succès"
else
    log_error "Échec de la copie des fichiers"
    ls -la /root/.n8n/custom/
    exit 1
fi

# 12. Configuration de N8N
log_info "Configuration de N8N pour les nodes personnalisés..."

# Vérifier si la variable est déjà configurée
if ! grep -q "N8N_CUSTOM_EXTENSIONS_PATH" /etc/systemd/system/n8n.service; then
    log_info "Ajout de la variable d'environnement..."
    sed -i '/\[Service\]/a Environment="N8N_CUSTOM_EXTENSIONS_PATH=/root/.n8n/custom"' /etc/systemd/system/n8n.service
    systemctl daemon-reload
    log_success "Variable d'environnement ajoutée"
else
    log_success "La variable d'environnement est déjà configurée"
fi

# 13. Redémarrage de N8N
log_info "Redémarrage de N8N pour charger le nouveau node..."
systemctl restart n8n

# 14. Attendre que N8N redémarre
log_info "Attente du redémarrage de N8N..."
sleep 15

# 15. Vérification finale
log_info "Vérification finale..."
if systemctl is-active --quiet n8n; then
    log_success "N8N est actif"
    
    # Vérifier que les fichiers sont toujours présents
    if [ -f "/root/.n8n/custom/nodes/Turso.node.js" ]; then
        log_success "Node Turso déployé avec succès !"
        echo ""
        echo "🎉 Déploiement terminé avec succès !"
        echo "📋 Prochaines étapes:"
        echo "1. Accédez à http://$(hostname -I | awk '{print $1}'):5678/"
        echo "2. Créez un nouveau workflow"
        echo "3. Ajoutez un nouveau node"
        echo "4. Recherchez 'Turso' dans la liste"
        echo ""
        echo "📁 Fichiers déployés:"
        ls -la /root/.n8n/custom/
    else
        log_error "Fichiers du node manquants après redémarrage"
        exit 1
    fi
else
    log_error "N8N n'est pas actif après redémarrage"
    systemctl status n8n
    exit 1
fi

log_success "Déploiement terminé avec succès ! 🚀"
