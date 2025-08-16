# Guide de Vérification - Node Turso N8N

## ✅ Vérifications Pré-Installation

### 1. Structure du Projet
Vérifiez que votre projet contient tous les fichiers nécessaires :
```
n8n-nodes-turso/
├── dist/
│   ├── nodes/
│   │   └── Turso.node.js
│   ├── credentials/
│   │   └── TursoApi.credentials.js
│   └── index.js
├── nodes/
│   └── Turso.node.ts
├── credentials/
│   └── TursoApi.credentials.ts
├── package.json
├── tsconfig.json
└── README.md
```

### 2. Compilation
Exécutez le test de compilation :
```bash
node test-node.js
```
Vous devriez voir : "✅ Compilation réussie !"

## 🚀 Installation sur le Serveur N8N

### 1. Connexion SSH
```bash
ssh root@votre-serveur
# Mot de passe: 8tc6vr89
```

### 2. Préparation de l'environnement
```bash
# Vérifier que Node.js est installé
node --version
npm --version

# Créer le répertoire des nodes personnalisés
mkdir -p ~/.n8n/custom
```

### 3. Déploiement du Node
```bash
# Cloner ou copier votre projet
cd ~/.n8n/custom
git clone https://github.com/votre-username/n8n-nodes-turso.git
cd n8n-nodes-turso

# Installer et compiler
npm install
npm run build

# Copier les fichiers compilés
cp -r dist/* ~/.n8n/custom/
```

## ⚙️ Configuration de N8N

### 1. Variable d'Environnement
Ajoutez cette ligne à votre configuration N8N :

**Si vous utilisez systemd :**
```bash
# Éditer le fichier de service
nano /etc/systemd/system/n8n.service

# Ajouter dans la section [Service] :
Environment="N8N_CUSTOM_EXTENSIONS_PATH=/root/.n8n/custom"

# Recharger et redémarrer
systemctl daemon-reload
systemctl restart n8n
```

**Si vous démarrez N8N manuellement :**
```bash
export N8N_CUSTOM_EXTENSIONS_PATH=/root/.n8n/custom
n8n start
```

### 2. Redémarrage
```bash
# Redémarrer N8N
systemctl restart n8n

# Vérifier le statut
systemctl status n8n

# Vérifier les logs
journalctl -u n8n -f
```

## 🔍 Vérification Post-Installation

### 1. Interface Web N8N
1. Accédez à l'interface web N8N
2. Créez un nouveau workflow
3. Ajoutez un nouveau node
4. Recherchez "Turso" dans la liste

### 2. Test du Node
1. **Ajoutez le node Turso** à votre workflow
2. **Configurez les credentials :**
   - Database URL: `libsql://your-database.turso.io`
   - Auth Token: Votre token Turso
3. **Testez avec une requête simple :**
   - Resource: Query
   - Operation: Execute
   - SQL Query: `SELECT 1 as test;`

### 3. Vérification des Logs
```bash
# Vérifier les logs N8N
journalctl -u n8n -f

# Rechercher les erreurs liées au node Turso
journalctl -u n8n | grep -i turso
```

## 🐛 Dépannage

### Le node n'apparaît pas
- ✅ Vérifiez `N8N_CUSTOM_EXTENSIONS_PATH`
- ✅ Vérifiez que les fichiers sont dans le bon répertoire
- ✅ Redémarrez N8N après modification
- ✅ Vérifiez les permissions des fichiers

### Erreur de compilation
- ✅ Vérifiez que Node.js et npm sont installés
- ✅ Vérifiez que toutes les dépendances sont installées
- ✅ Vérifiez la syntaxe TypeScript

### Erreur de connexion à Turso
- ✅ Vérifiez l'URL de la base de données
- ✅ Vérifiez le token d'authentification
- ✅ Vérifiez la connectivité réseau

## 📋 Checklist de Vérification

- [ ] Projet compilé sans erreur
- [ ] Fichiers copiés dans `~/.n8n/custom/`
- [ ] Variable `N8N_CUSTOM_EXTENSIONS_PATH` configurée
- [ ] N8N redémarré
- [ ] Node "Turso" visible dans l'interface
- [ ] Credentials configurés
- [ ] Test de requête réussi
- [ ] Logs sans erreur

## 🎯 Test Final

Créez un workflow de test complet :
1. **Déclencheur** : Manuel
2. **Node Turso** : Créer une table de test
3. **Node Turso** : Insérer des données
4. **Node Turso** : Exécuter une requête SELECT
5. **Vérification** : Les données sont correctement retournées

Si tout fonctionne, votre node Turso est correctement installé et configuré ! 🎉
