# Guide d'Installation - Node Turso pour N8N

## 🎯 Objectif
Ce guide vous explique comment installer le node Turso personnalisé sur votre instance N8N existante.

## 📋 Prérequis
- Une instance N8N en cours d'exécution
- Accès SSH à votre serveur N8N
- Node.js et npm installés sur le serveur

## 🚀 Installation

### Option 1: Installation manuelle (recommandée)

1. **Connectez-vous à votre serveur N8N via SSH**
   ```bash
   ssh root@votre-serveur
   # Mot de passe: 8tc6vr89
   ```

2. **Créez le répertoire pour les nodes personnalisés**
   ```bash
   mkdir -p ~/.n8n/custom
   cd ~/.n8n/custom
   ```

3. **Clonez le repository**
   ```bash
   git clone https://github.com/votre-username/n8n-nodes-turso.git
   cd n8n-nodes-turso
   ```

4. **Installez les dépendances et compilez**
   ```bash
   npm install
   npm run build
   ```

5. **Copiez les fichiers compilés**
   ```bash
   cp -r dist/* ~/.n8n/custom/
   ```

6. **Configurez N8N pour charger les nodes personnalisés**
   
   **Si vous utilisez systemd:**
   ```bash
   # Éditez le fichier de service
   nano /etc/systemd/system/n8n.service
   
   # Ajoutez cette ligne dans la section [Service]:
   Environment="N8N_CUSTOM_EXTENSIONS_PATH=/root/.n8n/custom"
   
   # Rechargez et redémarrez
   systemctl daemon-reload
   systemctl restart n8n
   ```

   **Si vous démarrez N8N manuellement:**
   ```bash
   export N8N_CUSTOM_EXTENSIONS_PATH=/root/.n8n/custom
   n8n start
   ```

### Option 2: Installation via Docker

1. **Arrêtez votre instance N8N actuelle**
2. **Utilisez le docker-compose.yml fourni**
   ```bash
   docker-compose up -d
   ```

## ✅ Vérification

1. **Redémarrez N8N**
2. **Accédez à l'interface web N8N**
3. **Dans un workflow, ajoutez un nouveau node**
4. **Recherchez "Turso" dans la liste des nodes**

## 🔐 Configuration des Credentials

1. **Dans N8N, allez dans "Credentials"**
2. **Cliquez sur "Add Credential"**
3. **Recherchez "Turso API"**
4. **Configurez:**
   - **Database URL**: `libsql://your-database.turso.io`
   - **Auth Token**: Votre token Turso

## 🧪 Test du Node

1. **Créez un nouveau workflow**
2. **Ajoutez le node Turso**
3. **Sélectionnez vos credentials**
4. **Testez avec une requête simple:**
   - Resource: Query
   - Operation: Execute
   - SQL Query: `SELECT 1 as test;`

## 🐛 Dépannage

### Le node n'apparaît pas
- Vérifiez que `N8N_CUSTOM_EXTENSIONS_PATH` est correctement configuré
- Vérifiez les logs N8N: `journalctl -u n8n -f`
- Redémarrez N8N après modification de la configuration

### Erreur de compilation
- Vérifiez que Node.js et npm sont installés
- Vérifiez que toutes les dépendances sont installées

### Erreur de connexion à Turso
- Vérifiez que l'URL et le token sont corrects
- Vérifiez que votre base de données Turso est accessible

## 📞 Support

En cas de problème, vérifiez:
1. Les logs N8N
2. La configuration des variables d'environnement
3. Les permissions des fichiers

## 🔄 Mise à jour

Pour mettre à jour le node:
```bash
cd ~/.n8n/custom/n8n-nodes-turso
git pull
npm install
npm run build
cp -r dist/* ~/.n8n/custom/
systemctl restart n8n
```
