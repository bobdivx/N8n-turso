// Test simple du node Turso
// Ce fichier permet de vérifier que la compilation a réussi

const TursoNode = require('./dist/nodes/Turso.node.js');
const TursoCredentials = require('./dist/credentials/TursoApi.credentials.js');

console.log('✅ Test de compilation du node Turso');
console.log('📦 Node Turso:', typeof TursoNode);
console.log('🔐 Credentials Turso:', typeof TursoCredentials);

// Vérifier que les classes sont bien exportées
if (TursoNode && TursoCredentials) {
    console.log('✅ Compilation réussie !');
    console.log('🚀 Le node est prêt à être utilisé dans N8N');
} else {
    console.log('❌ Erreur dans la compilation');
    process.exit(1);
}

console.log('\n📋 Prochaines étapes:');
console.log('1. Copiez le dossier dist/ vers ~/.n8n/custom/ sur votre serveur N8N');
console.log('2. Configurez N8N_CUSTOM_EXTENSIONS_PATH');
console.log('3. Redémarrez N8N');
console.log('4. Le node "Turso" devrait apparaître dans la liste des nodes');
