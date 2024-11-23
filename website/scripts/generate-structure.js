const fs = require('fs');
const path = require('path');

function generateStructure(startPath) {
  const items = [];
  const files = fs.readdirSync(startPath);

  for (const file of files) {
    const filePath = path.join(startPath, file);
    const stats = fs.statSync(filePath);
    const relativePath = filePath.replace('public', '');

    if (stats.isDirectory()) {
      const children = generateStructure(filePath);
      if (children.length > 0) {
        items.push({
          type: 'directory',
          name: file,
          children: children
        });
      }
    } else if (path.extname(file).toLowerCase() === '.pdf') {
      items.push({
        type: 'pdf',
        name: path.basename(file, '.pdf'),
        path: relativePath
      });
    }
  }

  return items;
}

try {
  const structure = generateStructure('public/static/cours');

  if (!fs.existsSync('public/static')) {
    fs.mkdirSync('public/static', { recursive: true });
  }

  fs.writeFileSync(
    'public/static/structure.json',
    JSON.stringify(structure, null, 2)
  );

  console.log('Structure générée avec succès !');
} catch (error) {
  console.error('Erreur lors de la génération de la structure:', error);
  process.exit(1);
}