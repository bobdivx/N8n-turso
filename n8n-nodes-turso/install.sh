#!/bin/bash

# Script d'installation pour le node Turso N8N
# À exécuter sur votre instance N8N

echo "🚀 Installation du node Turso pour N8N..."

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "package.json" ]; then
    echo "❌ Erreur: Ce script doit être exécuté depuis le répertoire du projet"
    exit 1
fi

# Installer les dépendances
echo "📦 Installation des dépendances..."
npm install

# Compiler le projet
echo "🔨 Compilation du projet..."
npm run build

# Vérifier que la compilation a réussi
if [ ! -f "dist/nodes/Turso.node.js" ]; then
    echo "❌ Erreur: La compilation a échoué"
    exit 1
fi

echo "✅ Compilation réussie !"

# Créer le répertoire de destination
N8N_CUSTOM_DIR="$HOME/.n8n/custom"
echo "📁 Création du répertoire de destination: $N8N_CUSTOM_DIR"
mkdir -p "$N8N_CUSTOM_DIR"

# Copier les fichiers compilés
echo "📋 Copie des fichiers..."
cp -r dist/* "$N8N_CUSTOM_DIR/"

echo "✅ Installation terminée !"
echo ""
echo "📝 Prochaines étapes:"
echo "1. Redémarrez votre instance N8N"
echo "2. Le node 'Turso' devrait apparaître dans la liste des nodes"
echo "3. Configurez vos credentials Turso dans N8N"
echo ""
echo "🔧 Pour configurer N8N avec ce node personnalisé, ajoutez cette variable d'environnement:"
echo "   N8N_CUSTOM_EXTENSIONS_PATH=$N8N_CUSTOM_DIR"
