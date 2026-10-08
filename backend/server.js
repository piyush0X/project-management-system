const app = require('./src/app');
const pool = require('./src/config/db');
const initializeDatabase = require('./init-db');

const PORT = process.env.PORT || 5000;

async function startServer() {
  try {
    await pool.query('SELECT NOW()');

    console.log('Database connected successfully');

    await initializeDatabase();

    app.listen(PORT, '0.0.0.0', () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (error) {
    console.error('Server startup failed:', error);
    process.exit(1);
  }
}

startServer();