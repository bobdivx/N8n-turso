# 🚀 Guide d'Automatisation - Déploiement du Node Turso

## 🎯 Déploiement Automatique

Votre node Turso peut maintenant être déployé **automatiquement** sur votre serveur N8N ! Plus besoin de faire les étapes manuellement.

## 📋 Options de Déploiement

### Option 1: Déploiement Automatique (Recommandé) 🎯

#### Pour Windows (PowerShell)
```powershell
# Exécuter le script PowerShell d'automatisation
.\deploy-remote.ps1
```

#### Pour Linux/macOS (Bash)
```bash
# Rendre le script exécutable
chmod +x deploy-remote.sh

# Exécuter le script d'automatisation
./deploy-remote.sh
```

### Option 2: Déploiement Manuel sur le Serveur

Si vous préférez faire le déploiement manuellement :

1. **Connectez-vous à votre serveur :**
   ```bash
   ssh root@10.1.2.59
   # Mot de passe: 8tc6vr89
   ```

2. **Exécutez le script d'automatisation :**
   ```bash
   chmod +x deploy-auto.sh
   ./deploy-auto.sh
   ```

## 🔧 Ce que fait l'Automatisation

Le script d'automatisation effectue **automatiquement** :

✅ **Vérification de l'environnement**
- Connectivité réseau
- Installation de Node.js si nécessaire
- Vérification des prérequis

✅ **Création du projet**
- Structure complète du node Turso
- Configuration TypeScript
- Installation des dépendances

✅ **Compilation**
- Compilation TypeScript automatique
- Vérification des erreurs
- Génération des fichiers JavaScript

✅ **Configuration N8N**
- Ajout de la variable d'environnement
- Configuration du service systemd
- Redémarrage automatique de N8N

✅ **Vérification finale**
- Test de la présence des fichiers
- Confirmation du déploiement
- Instructions d'utilisation

## 🎮 Utilisation Après Déploiement

### 1. Accéder à N8N
- **URL :** http://10.1.2.59:5678/
- Le node "Turso" apparaîtra dans la liste des nodes

### 2. Configurer les Credentials
1. Allez dans "Credentials"
2. Cliquez sur "Add Credential"
3. Recherchez "Turso API"
4. Configurez :
   - **Database URL :** `libsql://your-database.turso.io`
   - **Auth Token :** Votre token Turso

### 3. Tester le Node
1. Créez un nouveau workflow
2. Ajoutez le node "Turso"
3. Testez avec : `SELECT 1 as test;`

## 🐛 Dépannage Automatique

### En cas d'échec du déploiement

#### Vérifier les logs sur le serveur
```bash
ssh root@10.1.2.59
journalctl -u n8n -f
```

#### Vérifier la configuration
```bash
# Vérifier que la variable d'environnement est configurée
grep "N8N_CUSTOM_EXTENSIONS_PATH" /etc/systemd/system/n8n.service

# Vérifier que les fichiers sont présents
ls -la /root/.n8n/custom/
```

#### Redémarrer manuellement si nécessaire
```bash
systemctl restart n8n
systemctl status n8n
```

## 📊 Fonctionnalités Disponibles

Une fois déployé, votre node Turso offre :

### 🔍 **Resource: Query**
- **Execute** : Requêtes SQL personnalisées

### 📋 **Resource: Table**
- **Create** : Création de tables avec colonnes
- **Delete** : Suppression de tables
- **Add Column** : Ajout de colonnes

### 📝 **Resource: Row**
- **Insert** : Insertion de données
- **Update** : Modification de données
- **Delete** : Suppression de données

## 🎉 Avantages de l'Automatisation

- **⏱️ Gain de temps** : Déploiement en quelques minutes
- **🔒 Fiabilité** : Moins d'erreurs humaines
- **🔄 Reproductibilité** : Déploiement identique à chaque fois
- **📋 Documentation** : Instructions automatiques
- **🛠️ Maintenance** : Mise à jour facile

## 🚀 Prochaines Étapes

1. **Exécutez le script d'automatisation** de votre choix
2. **Attendez la confirmation** du déploiement
3. **Accédez à N8N** et testez le node
4. **Configurez vos credentials** Turso
5. **Créez vos premiers workflows** avec Turso !

## 💡 Conseils

- **Sauvegardez** votre serveur avant le déploiement
- **Vérifiez** que N8N est accessible avant de commencer
- **Testez** avec une requête simple avant de passer en production
- **Consultez** les logs en cas de problème

---

**🎯 Votre node Turso sera opérationnel en quelques minutes grâce à l'automatisation !**
