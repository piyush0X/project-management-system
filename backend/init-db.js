const fs = require('fs');
const path = require('path');

const pool = require('./src/config/db');

async function initializeDatabase() {
  try {
    const schemaPath = path.join(
      __dirname,
      'database',
      'schema.sql'
    );

    const schema = fs.readFileSync(schemaPath, 'utf8');

    await pool.query(schema);

    console.log('Database schema initialized successfully');
  } catch (error) {
    console.error('Database schema initialization failed:', error);
    throw error;
  }
}

module.exports = initializeDatabase;