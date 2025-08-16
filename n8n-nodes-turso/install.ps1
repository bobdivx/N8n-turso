# Script d'installation PowerShell pour le node Turso N8N
# À exécuter sur Windows

Write-Host "🚀 Installation du node Turso pour N8N..." -ForegroundColor Green

# Vérifier que nous sommes dans le bon répertoire
if (-not (Test-Path "package.json")) {
    Write-Host "❌ Erreur: Ce script doit être exécuté depuis le répertoire du projet" -ForegroundColor Red
    exit 1
}

# Installer les dépendances
Write-Host "📦 Installation des dépendances..." -ForegroundColor Yellow
npm install

# Compiler le projet
Write-Host "🔨 Compilation du projet..." -ForegroundColor Yellow
npm run build

# Vérifier que la compilation a réussi
if (-not (Test-Path "dist/nodes/Turso.node.js")) {
    Write-Host "❌ Erreur: La compilation a échoué" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Compilation réussie !" -ForegroundColor Green

# Créer le répertoire de destination
$N8N_CUSTOM_DIR = "$env:USERPROFILE\.n8n\custom"
Write-Host "📁 Création du répertoire de destination: $N8N_CUSTOM_DIR" -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $N8N_CUSTOM_DIR | Out-Null

# Copier les fichiers compilés
Write-Host "📋 Copie des fichiers..." -ForegroundColor Yellow
Copy-Item -Path "dist\*" -Destination $N8N_CUSTOM_DIR -Recurse -Force

Write-Host "✅ Installation terminée !" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Prochaines étapes:" -ForegroundColor Cyan
Write-Host "1. Redémarrez votre instance N8N" -ForegroundColor White
Write-Host "2. Le node 'Turso' devrait apparaître dans la liste des nodes" -ForegroundColor White
Write-Host "3. Configurez vos credentials Turso dans N8N" -ForegroundColor White
Write-Host ""
Write-Host "🔧 Pour configurer N8N avec ce node personnalisé, ajoutez cette variable d'environnement:" -ForegroundColor Cyan
Write-Host "   N8N_CUSTOM_EXTENSIONS_PATH=$N8N_CUSTOM_DIR" -ForegroundColor White
Write-Host ""
Write-Host "💡 Si vous utilisez Docker, utilisez le docker-compose.yml fourni" -ForegroundColor Yellow
