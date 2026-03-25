const mysql = require('mysql2');
require('dotenv').config();

const connection = mysql.createPool({
    host:     process.env.DB_HOST,
    user:     process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port:     process.env.DB_PORT || 3306,
    waitForConnections: true,
    connectionLimit:    10,
    queueLimit:         0
});

// Testa a conexão ao iniciar
connection.getConnection((err, conn) => {
    if (err) {
        console.error('Erro ao conectar no banco de dados:', err.message);
        return;
    }
    console.log('Banco de dados conectado com sucesso!');
    conn.release();
});

module.exports = connection.promise();
