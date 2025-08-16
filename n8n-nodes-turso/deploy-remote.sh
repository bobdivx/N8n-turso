#!/bin/bash

# Script de déploiement distant pour le node Turso N8N
# Ce script transfère et exécute automatiquement le déploiement sur le serveur N8N

set -e

# Configuration du serveur
SERVER_IP="10.1.2.59"
SERVER_USER="root"
SERVER_PASSWORD="8tc6vr89"
N8N_URL="http://10.1.2.59:5678/"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

echo "🚀 Déploiement automatique du node Turso sur N8N"
echo "📍 Serveur: $SERVER_IP"
echo "👤 Utilisateur: $SERVER_USER"
echo "🌐 N8N URL: $N8N_URL"
echo ""

# Vérifier que sshpass est installé
if ! command -v sshpass &> /dev/null; then
    log_error "sshpass n'est pas installé. Installation en cours..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install -y sshpass
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install hudochenkov/sshpass/sshpass
    else
        log_error "Impossible d'installer sshpass automatiquement. Veuillez l'installer manuellement."
        exit 1
    fi
fi

# Vérifier la connectivité au serveur
log_info "Vérification de la connectivité au serveur..."
if ! ping -c 1 $SERVER_IP &> /dev/null; then
    log_error "Impossible de joindre le serveur $SERVER_IP"
    exit 1
fi
log_success "Serveur accessible"

# Transférer le script de déploiement
log_info "Transfert du script de déploiement..."
if sshpass -p "$SERVER_PASSWORD" scp -o StrictHostKeyChecking=no deploy-auto.sh $SERVER_USER@$SERVER_IP:/tmp/; then
    log_success "Script transféré avec succès"
else
    log_error "Échec du transfert du script"
    exit 1
fi

# Rendre le script exécutable et l'exécuter
log_info "Exécution du script de déploiement sur le serveur..."
sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP << 'EOF'
chmod +x /tmp/deploy-auto.sh
cd /tmp
./deploy-auto.sh
EOF

# Vérifier le statut du déploiement
log_info "Vérification du statut du déploiement..."
if sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP "test -f /root/.n8n/custom/Turso.node.js"; then
    log_success "✅ Déploiement réussi !"
    echo ""
    echo "🎉 Votre node Turso est maintenant disponible dans N8N !"
    echo ""
    echo "📋 Prochaines étapes:"
    echo "1. Accédez à l'interface N8N: $N8N_URL"
    echo "2. Créez un nouveau workflow"
    echo "3. Ajoutez un nouveau node et recherchez 'Turso'"
    echo "4. Configurez vos credentials Turso"
    echo "5. Testez avec une requête simple: SELECT 1 as test;"
    echo ""
    echo "🔧 Configuration des credentials:"
    echo "   - Database URL: libsql://your-database.turso.io"
    echo "   - Auth Token: Votre token Turso"
    echo ""
    echo "📊 Fonctionnalités disponibles:"
    echo "   - Requêtes SQL personnalisées"
    echo "   - Création/suppression de tables"
    echo "   - Insertion/modification/suppression de données"
    echo ""
    echo "🚀 Bon développement avec votre node Turso !"
    
    # Nettoyer le script temporaire
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP "rm -f /tmp/deploy-auto.sh"
    
else
    log_error "❌ Déploiement échoué"
    echo ""
    echo "🔍 Vérifiez les logs sur le serveur:"
    echo "   ssh $SERVER_USER@$SERVER_IP"
    echo "   journalctl -u n8n -f"
    exit 1
fi
