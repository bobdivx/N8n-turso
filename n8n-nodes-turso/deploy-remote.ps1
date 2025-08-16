# Script PowerShell de déploiement distant pour le node Turso N8N
# Ce script transfère et exécute automatiquement le déploiement sur le serveur N8N

param(
    [string]$ServerIP = "10.1.2.59",
    [string]$ServerUser = "root",
    [string]$ServerPassword = "8tc6vr89"
)

# Configuration
$N8N_URL = "http://$ServerIP:5678/"

# Couleurs pour l'affichage
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Info {
    param([string]$Message)
    Write-ColorOutput "ℹ️  $Message" "Blue"
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "✅ $Message" "Green"
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "⚠️  $Message" "Yellow"
}

function Write-Error {
    param([string]$Message)
    Write-ColorOutput "❌ $Message" "Red"
}

# Début du script
Write-ColorOutput "🚀 Déploiement automatique du node Turso sur N8N" "Cyan"
Write-ColorOutput "📍 Serveur: $ServerIP" "White"
Write-ColorOutput "👤 Utilisateur: $ServerUser" "White"
Write-ColorOutput "🌐 N8N URL: $N8N_URL" "White"
Write-Host ""

# Vérifier la connectivité au serveur
Write-Info "Vérification de la connectivité au serveur..."
try {
    $ping = Test-Connection -ComputerName $ServerIP -Count 1 -Quiet
    if ($ping) {
        Write-Success "Serveur accessible"
    } else {
        Write-Error "Impossible de joindre le serveur $ServerIP"
        exit 1
    }
} catch {
    Write-Error "Erreur lors de la vérification de connectivité: $_"
    exit 1
}

# Vérifier si OpenSSH est disponible
Write-Info "Vérification d'OpenSSH..."
if (-not (Get-Command ssh -ErrorAction SilentlyContinue)) {
    Write-Warning "OpenSSH n'est pas installé. Installation en cours..."
    
    # Installer OpenSSH via Windows Features
    try {
        Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
        Write-Success "OpenSSH installé"
    } catch {
        Write-Error "Impossible d'installer OpenSSH. Veuillez l'installer manuellement via 'Ajouter des fonctionnalités Windows'"
        exit 1
    }
}

# Créer le script de déploiement sur le serveur
Write-Info "Création du script de déploiement sur le serveur..."

# Créer le contenu du script de déploiement
$deployScript = @'
#!/bin/bash

set -e

echo "🚀 Déploiement automatique du node Turso pour N8N"
echo "📍 Serveur: 10.1.2.59:5678"
echo "⏰ $(date)"
echo ""

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

# Vérifier que nous sommes root
if [ "$EUID" -ne 0 ]; then
    log_error "Ce script doit être exécuté en tant que root"
    exit 1
fi

# Vérifier la connectivité réseau
log_info "Vérification de la connectivité réseau..."
if ! ping -c 1 8.8.8.8 &> /dev/null; then
    log_error "Pas de connectivité Internet"
    exit 1
fi
log_success "Connectivité Internet OK"

# Vérifier et installer Node.js si nécessaire
log_info "Vérification de Node.js..."
if ! command -v node &> /dev/null; then
    log_warning "Node.js n'est pas installé. Installation en cours..."
    
    # Ajouter le repository NodeSource
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    
    # Installer Node.js
    apt-get update
    apt-get install -y nodejs
    
    log_success "Node.js installé"
else
    NODE_VERSION=$(node --version)
    log_success "Node.js déjà installé: $NODE_VERSION"
fi

# Vérifier npm
if ! command -v npm &> /dev/null; then
    log_error "npm n'est pas installé"
    exit 1
fi

# Créer le répertoire des nodes personnalisés
N8N_CUSTOM_DIR="/root/.n8n/custom"
log_info "Création du répertoire: $N8N_CUSTOM_DIR"
mkdir -p "$N8N_CUSTOM_DIR"

# Créer le projet Turso directement sur le serveur
cd "$N8N_CUSTOM_DIR"

# Créer la structure du projet
log_info "Création de la structure du projet Turso..."
mkdir -p nodes credentials

# Créer package.json
cat > package.json << 'EOF'
{
  "name": "n8n-nodes-turso",
  "version": "1.0.0",
  "description": "N8N node for Turso database operations",
  "main": "index.js",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch"
  },
  "keywords": ["n8n", "turso", "database", "sqlite"],
  "author": "Jules",
  "n8n": {
    "n8nVersion": "1.0.0",
    "nodes": [
      "dist/nodes/Turso.node.js"
    ],
    "credentials": [
      "dist/credentials/TursoApi.credentials.js"
    ]
  },
  "license": "MIT",
  "type": "commonjs",
  "dependencies": {
    "@libsql/client": "^0.15.11",
    "n8n-workflow": "^1.82.0"
  },
  "devDependencies": {
    "@types/node": "^24.3.0",
    "n8n-core": "^1.14.1",
    "ts-node": "^10.9.2",
    "typescript": "^5.9.2"
  }
}
EOF

# Créer tsconfig.json
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "es6",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  }
}
EOF

# Créer le node Turso
cat > nodes/Turso.node.ts << 'EOF'
import {
	IExecuteFunctions,
	INodeExecutionData,
	INodeType,
	INodeTypeDescription,
	NodeApiError,
	NodeOperationError,
} from "n8n-workflow";
import { createClient, Client } from "@libsql/client";

export class Turso implements INodeType {
	description: INodeTypeDescription = {
		displayName: "Turso",
		name: "turso",
		icon: "file:turso.svg",
		group: ["input"],
		version: 1,
		subtitle: "={{$parameter[\"operation\"] + \": \" + $parameter[\"resource\"]}}",
		description: "Interact with a Turso database",
		defaults: {
			name: "Turso",
		},
		inputs: ["main"] as any,
		outputs: ["main"] as any,
		credentials: [
			{
				name: "tursoApi",
				required: true,
			},
		],
		properties: [
			{
				displayName: "Resource",
				name: "resource",
				type: "options",
				noDataExpression: true,
				options: [
					{
						name: "Query",
						value: "query",
					},
					{
						name: "Table",
						value: "table",
					},
					{
						name: "Row",
						value: "row",
					},
				],
				default: "query",
			},
			{
				displayName: "Operation",
				name: "operation",
				type: "options",
				noDataExpression: true,
				displayOptions: {
					show: {
						resource: ["query"],
					},
				},
				options: [
					{
						name: "Execute",
						value: "execute",
						description: "Execute a SQL query",
						action: "Execute a SQL query",
					},
				],
				default: "execute",
			},
			{
				displayName: "Operation",
				name: "operation",
				type: "options",
				noDataExpression: true,
				displayOptions: {
					show: {
						resource: ["table"],
					},
				},
				options: [
					{
						name: "Create",
						value: "create",
						description: "Create a new table",
						action: "Create a table",
					},
					{
						name: "Delete",
						value: "delete",
						description: "Delete a table",
						action: "Delete a table",
					},
					{
						name: "Add Column",
						value: "addColumn",
						description: "Add a column to a table",
						action: "Add a column to a table",
					}
				],
				default: "create",
			},
			{
				displayName: "Operation",
				name: "operation",
				type: "options",
				noDataExpression: true,
				displayOptions: {
					show: {
						resource: ["row"],
					},
				},
				options: [
					{
						name: "Insert",
						value: "insert",
						description: "Insert a new row into a table",
						action: "Insert a row",
					},
					{
						name: "Update",
						value: "update",
						description: "Update a row in a table",
						action: "Update a row",
					},
					{
						name: "Delete",
						value: "delete",
						description: "Delete a row from a table",
						action: "Delete a row",
					},
				],
				default: "insert",
			},
			{
				displayName: "SQL Query",
				name: "query",
				type: "string",
				displayOptions: {
					show: {
						resource: ["query"],
						operation: ["execute"],
					},
				},
				default: "",
				placeholder: "SELECT * FROM my_table;",
				description: "The SQL query to execute",
				required: true,
				typeOptions: {
					rows: 5,
				},
			},
			{
				displayName: "Table Name",
				name: "tableName",
				type: "string",
				displayOptions: {
					show: {
						resource: ["table", "row"],
					},
				},
				default: "",
				placeholder: "my_table",
				description: "The name of the table",
				required: true,
			},
			{
				displayName: "Columns",
				name: "columns",
				type: "fixedCollection",
				displayOptions: {
					show: {
						resource: ["table"],
						operation: ["create"],
					},
				},
				default: {},
				placeholder: "Add Column",
				typeOptions: {
					multipleValues: true,
					properties: [
						{
							name: "name",
							displayName: "Name",
							type: "string",
							default: "",
						},
						{
							name: "type",
							displayName: "Type",
							type: "options",
							options: [
								{ name: "TEXT", value: "TEXT" },
								{ name: "INTEGER", value: "INTEGER" },
								{ name: "REAL", value: "REAL" },
								{ name: "BLOB", value: "BLOB" },
								{ name: "NUMERIC", value: "NUMERIC" },
							],
							default: "TEXT",
						},
						{
							name: "primaryKey",
							displayName: "Primary Key",
							type: "boolean",
							default: false,
						},
						{
							name: "notNull",
							displayName: "Not Null",
							type: "boolean",
							default: false,
						},
					],
				},
				description: "The columns of the table",
			},
            {
                displayName: "Column Name",
                name: "columnName",
                type: "string",
                displayOptions: {
                    show: {
                        resource: ["table"],
                        operation: ["addColumn"],
                    },
                },
                default: "",
                placeholder: "my_column",
                description: "The name of the new column",
                required: true,
            },
            {
                displayName: "Column Type",
                name: "columnType",
                type: "options",
                displayOptions: {
                    show: {
                        resource: ["table"],
                        operation: ["addColumn"],
                    },
                },
                options: [
                    { name: "TEXT", value: "TEXT" },
                    { name: "INTEGER", value: "INTEGER" },
                    { name: "REAL", value: "REAL" },
                    { name: "BLOB", value: "BLOB" },
                    { name: "NUMERIC", value: "NUMERIC" },
                ],
                default: "TEXT",
                description: "The type of the new column",
                required: true,
            },
			{
				displayName: "Data",
				name: "data",
				type: "json",
				displayOptions: {
					show: {
						resource: ["row"],
						operation: ["insert", "update"],
					},
				},
				default: "{}",
				description: "The data to insert or update in JSON format",
				required: true,
			},
			{
				displayName: "Where Clause",
				name: "whereClause",
				type: "string",
				displayOptions: {
					show: {
						resource: ["row"],
						operation: ["update", "delete"],
					},
				},
				default: "",
				placeholder: "id = 1",
				description: "The WHERE clause to identify the row(s) to update or delete",
				required: true,
			},
		],
	};

	async execute(this: IExecuteFunctions): Promise<INodeExecutionData[][]> {
		const items = this.getInputData();
		let returnData: INodeExecutionData[] = [];
		const resource = this.getNodeParameter("resource", 0, "") as string;
		const operation = this.getNodeParameter("operation", 0, "") as string;
		const credentials = await this.getCredentials("tursoApi");
		
		if (!credentials.url || !credentials.authToken) {
			throw new NodeOperationError(this.getNode(), 'Database URL and Auth Token are required');
		}

		const client: Client = createClient({
			url: credentials.url as string,
			authToken: credentials.authToken as string,
		});

		for (let i = 0; i < items.length; i++) {
			try {
				if (resource === "query") {
					if (operation === "execute") {
						const query = this.getNodeParameter("query", i, "") as string;
						if (!query.trim()) {
							throw new NodeOperationError(this.getNode(), 'SQL query cannot be empty');
						}
						const result = await client.execute(query);
						returnData = this.helpers.returnJsonArray(result.rows as any[]);
					}
				} else if (resource === "table") {
					const tableName = this.getNodeParameter("tableName", i, "") as string;
					if (!tableName.trim()) {
						throw new NodeOperationError(this.getNode(), 'Table name cannot be empty');
					}

					if (operation === "create") {
						const columnsParam = this.getNodeParameter("columns", i, {}) as any;
						if (!columnsParam || !columnsParam.column || !Array.isArray(columnsParam.column) || columnsParam.column.length === 0) {
							throw new NodeOperationError(this.getNode(), 'At least one column is required to create a table');
						}

						const columnDefinitions = columnsParam.column
							.map((col: any) => {
								let definition = `${col.name} ${col.type}`;
								if (col.primaryKey) definition += " PRIMARY KEY";
								if (col.notNull) definition += " NOT NULL";
								return definition;
							})
							.join(", ");
						
						const query = `CREATE TABLE IF NOT EXISTS ${tableName} (${columnDefinitions});`;
						await client.execute(query);
						returnData.push({ 
							json: { 
								success: true, 
								message: `Table ${tableName} created successfully`,
								tableName,
								columns: columnsParam.column
							} 
						});
					} else if (operation === "delete") {
						const query = `DROP TABLE IF EXISTS ${tableName};`;
						await client.execute(query);
						returnData.push({ 
							json: { 
								success: true, 
								message: `Table ${tableName} deleted successfully`,
								tableName
							} 
						});
					} else if (operation === "addColumn") {
                        const columnName = this.getNodeParameter("columnName", i, "") as string;
                        const columnType = this.getNodeParameter("columnType", i, "") as string;
                        
                        if (!columnName.trim()) {
							throw new NodeOperationError(this.getNode(), 'Column name cannot be empty');
						}

                        const query = `ALTER TABLE ${tableName} ADD COLUMN ${columnName} ${columnType};`;
                        await client.execute(query);
                        returnData.push({ 
							json: { 
								success: true, 
								message: `Column ${columnName} added to table ${tableName} successfully`,
								tableName,
								columnName,
								columnType
							} 
						});
                    }
				} else if (resource === "row") {
					const tableName = this.getNodeParameter("tableName", i, "") as string;
					if (!tableName.trim()) {
						throw new NodeOperationError(this.getNode(), 'Table name cannot be empty');
					}

					if (operation === "insert") {
						const data = this.getNodeParameter("data", i, "{}") as string;
						let parsedData;
						try {
							parsedData = JSON.parse(data);
						} catch (e) {
							throw new NodeOperationError(this.getNode(), 'Invalid JSON data format');
						}

						if (Object.keys(parsedData).length === 0) {
							throw new NodeOperationError(this.getNode(), 'Data cannot be empty');
						}

						const columns = Object.keys(parsedData).join(", ");
						const values = Object.values(parsedData);
						const placeholders = values.map(() => "?").join(", ");
						const query = `INSERT INTO ${tableName} (${columns}) VALUES (${placeholders});`;
						const result = await client.execute({ sql: query, args: values as any[] });
						returnData.push({ 
							json: { 
								success: true, 
								rowsAffected: result.rowsAffected,
								tableName,
								insertedData: parsedData
							} 
						});
					} else if (operation === "update") {
						const data = this.getNodeParameter("data", i, "{}") as string;
						const whereClause = this.getNodeParameter("whereClause", i, "") as string;
						
						if (!whereClause.trim()) {
							throw new NodeOperationError(this.getNode(), 'Where clause cannot be empty for update operation');
						}

						let parsedData;
						try {
							parsedData = JSON.parse(data);
						} catch (e) {
							throw new NodeOperationError(this.getNode(), 'Invalid JSON data format');
						}

						if (Object.keys(parsedData).length === 0) {
							throw new NodeOperationError(this.getNode(), 'Data cannot be empty');
						}

						const setClause = Object.keys(parsedData)
							.map((key) => `${key} = ?`)
							.join(", ");
						const values = Object.values(parsedData);
						const query = `UPDATE ${tableName} SET ${setClause} WHERE ${whereClause};`;
						const result = await client.execute({ sql: query, args: values as any[] });
						returnData.push({ 
							json: { 
								success: true, 
								rowsAffected: result.rowsAffected,
								tableName,
								updatedData: parsedData,
								whereClause
							} 
						});
					} else if (operation === "delete") {
						const whereClause = this.getNodeParameter("whereClause", i, "") as string;
						
						if (!whereClause.trim()) {
							throw new NodeOperationError(this.getNode(), 'Where clause cannot be empty for delete operation');
						}

						const query = `DELETE FROM ${tableName} WHERE ${whereClause};`;
						const result = await client.execute(query);
						returnData.push({ 
							json: { 
								success: true, 
								rowsAffected: result.rowsAffected,
								tableName,
								whereClause
							} 
						});
					}
				}
			} catch (error) {
				if (this.continueOnFail()) {
					returnData.push({ 
						json: { 
							error: (error as Error).message,
							resource,
							operation
						} 
					});
					continue;
				}
				throw new NodeApiError(this.getNode(), error as any);
			}
		}
		return [this.helpers.returnJsonArray(returnData)];
	}
}
EOF

# Créer les credentials Turso
cat > credentials/TursoApi.credentials.ts << 'EOF'
import {
	ICredentialType,
	INodeProperties,
} from "n8n-workflow";

export class TursoApi implements ICredentialType {
	name = "tursoApi";
	displayName = "Turso API";
	documentationUrl = "https://docs.turso.tech/sdk/ts/reference";
	properties: INodeProperties[] = [
		{
			displayName: "Database URL",
			name: "url",
			type: "string",
			default: "",
			placeholder: "libsql://your-database.turso.io",
			description: "The URL of your Turso database",
			required: true,
		},
		{
			name: "authToken",
			displayName: "Auth Token",
			type: "string",
			typeOptions: {
				password: true,
			},
			default: "",
			description: "The authentication token for your Turso database",
			required: true,
		},
	];
}
EOF

# Créer le fichier d'index
cat > index.ts << 'EOF'
import { Turso } from './nodes/Turso.node';
import { TursoApi } from './credentials/TursoApi.credentials';

export const nodes = [Turso];
export const credentials = [TursoApi];
EOF

# Installer les dépendances
log_info "Installation des dépendances..."
npm install

# Compiler le projet
log_info "Compilation du projet..."
npm run build

# Vérifier que la compilation a réussi
if [ ! -f "dist/nodes/Turso.node.js" ]; then
    log_error "La compilation a échoué"
    exit 1
fi

log_success "Compilation réussie !"

# Copier les fichiers compilés
log_info "Copie des fichiers compilés..."
cp -r dist/* ./

# Nettoyer les fichiers temporaires
rm -rf dist/ node_modules/ package*.json tsconfig.json index.ts nodes/ credentials/

# Vérifier que N8N est en cours d'exécution
log_info "Vérification du statut de N8N..."
if systemctl is-active --quiet n8n; then
    log_success "N8N est en cours d'exécution"
    
    # Configurer N8N pour charger les nodes personnalisés
    log_info "Configuration de N8N pour les nodes personnalisés..."
    
    # Vérifier si la variable d'environnement est déjà configurée
    if ! grep -q "N8N_CUSTOM_EXTENSIONS_PATH" /etc/systemd/system/n8n.service; then
        log_info "Ajout de la variable d'environnement N8N_CUSTOM_EXTENSIONS_PATH..."
        
        # Sauvegarder le fichier original
        cp /etc/systemd/system/n8n.service /etc/systemd/system/n8n.service.backup
        
        # Ajouter la variable d'environnement
        sed -i '/\[Service\]/a Environment="N8N_CUSTOM_EXTENSIONS_PATH=/root/.n8n/custom"' /etc/systemd/system/n8n.service
        
        # Recharger la configuration systemd
        systemctl daemon-reload
        
        # Redémarrer N8N
        log_info "Redémarrage de N8N..."
        systemctl restart n8n
        
        # Attendre que N8N redémarre
        sleep 10
        
        # Vérifier le statut
        if systemctl is-active --quiet n8n; then
            log_success "N8N redémarré avec succès"
        else
            log_error "Erreur lors du redémarrage de N8N"
            systemctl status n8n
        fi
    else
        log_success "La variable d'environnement est déjà configurée"
        
        # Redémarrer N8N pour charger le nouveau node
        log_info "Redémarrage de N8N pour charger le nouveau node..."
        systemctl restart n8n
        sleep 10
    fi
else
    log_warning "N8N n'est pas en cours d'exécution"
    log_info "Démarrage de N8N..."
    systemctl start n8n
    sleep 10
fi

# Vérification finale
log_info "Vérification finale..."
if [ -f "Turso.node.js" ] && [ -f "TursoApi.credentials.js" ]; then
    log_success "✅ Déploiement réussi !"
    echo ""
    echo "🎉 Votre node Turso est maintenant disponible dans N8N !"
    echo ""
    echo "📋 Prochaines étapes:"
    echo "1. Accédez à l'interface N8N: http://10.1.2.59:5678/"
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
else
    log_error "❌ Déploiement échoué"
    exit 1
fi
'@

# Créer un fichier temporaire avec le script
$tempScript = [System.IO.Path]::GetTempFileName()
$deployScript | Out-File -FilePath $tempScript -Encoding UTF8

# Transférer le script sur le serveur
Write-Info "Transfert du script de déploiement sur le serveur..."
try {
    # Utiliser scp pour transférer le fichier
    $scpCommand = "scp -o StrictHostKeyChecking=no '$tempScript' ${ServerUser}@${ServerIP}:/tmp/deploy-auto.sh"
    Invoke-Expression $scpCommand
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Script transféré avec succès"
    } else {
        throw "Échec du transfert"
    }
} catch {
    Write-Error "Échec du transfert du script: $_"
    Remove-Item $tempScript -ErrorAction SilentlyContinue
    exit 1
}

# Exécuter le script sur le serveur
Write-Info "Exécution du script de déploiement sur le serveur..."
try {
    $sshCommand = "ssh -o StrictHostKeyChecking=no ${ServerUser}@${ServerIP} 'chmod +x /tmp/deploy-auto.sh && cd /tmp && ./deploy-auto.sh'"
    Invoke-Expression $sshCommand
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Script exécuté avec succès"
    } else {
        throw "Échec de l'exécution"
    }
} catch {
    Write-Error "Échec de l'exécution du script: $_"
    Remove-Item $tempScript -ErrorAction SilentlyContinue
    exit 1
}

# Vérifier le statut du déploiement
Write-Info "Vérification du statut du déploiement..."
try {
    $checkCommand = "ssh -o StrictHostKeyChecking=no ${ServerUser}@${ServerIP} 'test -f /root/.n8n/custom/Turso.node.js'"
    Invoke-Expression $checkCommand
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✅ Déploiement réussi !"
        Write-Host ""
        Write-ColorOutput "🎉 Votre node Turso est maintenant disponible dans N8N !" "Green"
        Write-Host ""
        Write-ColorOutput "📋 Prochaines étapes:" "Cyan"
        Write-ColorOutput "1. Accédez à l'interface N8N: $N8N_URL" "White"
        Write-ColorOutput "2. Créez un nouveau workflow" "White"
        Write-ColorOutput "3. Ajoutez un nouveau node et recherchez 'Turso'" "White"
        Write-ColorOutput "4. Configurez vos credentials Turso" "White"
        Write-ColorOutput "5. Testez avec une requête simple: SELECT 1 as test;" "White"
        Write-Host ""
        Write-ColorOutput "🔧 Configuration des credentials:" "Cyan"
        Write-ColorOutput "   - Database URL: libsql://your-database.turso.io" "White"
        Write-ColorOutput "   - Auth Token: Votre token Turso" "White"
        Write-Host ""
        Write-ColorOutput "📊 Fonctionnalités disponibles:" "Cyan"
        Write-ColorOutput "   - Requêtes SQL personnalisées" "White"
        Write-ColorOutput "   - Création/suppression de tables" "White"
        Write-ColorOutput "   - Insertion/modification/suppression de données" "White"
        Write-Host ""
        Write-ColorOutput "🚀 Bon développement avec votre node Turso !" "Green"
        
        # Nettoyer le script temporaire sur le serveur
        Write-Info "Nettoyage des fichiers temporaires..."
        $cleanupCommand = "ssh -o StrictHostKeyChecking=no ${ServerUser}@${ServerIP} 'rm -f /tmp/deploy-auto.sh'"
        Invoke-Expression $cleanupCommand
        
    } else {
        Write-Error "❌ Déploiement échoué"
        Write-Host ""
        Write-ColorOutput "🔍 Vérifiez les logs sur le serveur:" "Yellow"
        Write-ColorOutput "   ssh ${ServerUser}@${ServerIP}" "White"
        Write-ColorOutput "   journalctl -u n8n -f" "White"
        exit 1
    }
} catch {
    Write-Error "Erreur lors de la vérification: $_"
    exit 1
} finally {
    # Nettoyer le fichier temporaire local
    Remove-Item $tempScript -ErrorAction SilentlyContinue
}
