# N8N Turso Node

Ce node permet d'interagir avec une base de données Turso depuis N8N.

## Installation

1. Clonez ce repository dans le dossier `~/.n8n/custom` de votre instance N8N
2. Installez les dépendances :
   ```bash
   npm install
   ```
3. Compilez le projet :
   ```bash
   npm run build
   ```
4. Redémarrez votre instance N8N

## Configuration des Credentials

Avant d'utiliser le node, vous devez configurer vos credentials Turso :

1. **Database URL** : L'URL de votre base de données Turso (ex: `libsql://your-database.turso.io`)
2. **Auth Token** : Votre token d'authentification Turso

## Fonctionnalités

### Resource: Query
- **Execute** : Exécute une requête SQL personnalisée

### Resource: Table
- **Create** : Crée une nouvelle table avec des colonnes personnalisées
- **Delete** : Supprime une table existante
- **Add Column** : Ajoute une nouvelle colonne à une table existante

### Resource: Row
- **Insert** : Insère une nouvelle ligne dans une table
- **Update** : Met à jour une ligne existante
- **Delete** : Supprime une ligne existante

## Utilisation

### Créer une table
1. Sélectionnez "Table" comme resource
2. Choisissez "Create" comme operation
3. Entrez le nom de la table
4. Ajoutez les colonnes avec leurs types et contraintes

### Insérer des données
1. Sélectionnez "Row" comme resource
2. Choisissez "Insert" comme operation
3. Entrez le nom de la table
4. Fournissez les données au format JSON

### Exécuter une requête SQL
1. Sélectionnez "Query" comme resource
2. Choisissez "Execute" comme operation
3. Entrez votre requête SQL

## Exemples

### Créer une table users
```json
{
  "columns": {
    "column": [
      {
        "name": "id",
        "type": "INTEGER",
        "primaryKey": true,
        "notNull": true
      },
      {
        "name": "name",
        "type": "TEXT",
        "notNull": true
      },
      {
        "name": "email",
        "type": "TEXT",
        "notNull": true
      }
    ]
  }
}
```

### Insérer un utilisateur
```json
{
  "name": "John Doe",
  "email": "john@example.com"
}
```

## Dépendances

- `@libsql/client` : Client officiel Turso
- `n8n-workflow` : Types N8N

## Support

Pour toute question ou problème, veuillez ouvrir une issue sur ce repository.
