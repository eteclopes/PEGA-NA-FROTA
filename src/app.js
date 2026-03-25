const express = require('express');
const cors    = require('cors');
const path    = require('path');
require('dotenv').config();

const app = express();

// =========================
// MIDDLEWARES
// =========================
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Servir arquivos estáticos do front (HTML, CSS, JS)
app.use(express.static(path.join(__dirname, '..', 'public')));

// =========================
// ROTAS (descomentar conforme for criando)
// =========================
// app.use('/api/veiculos',    require('./routes/veiculoRoutes'));
// app.use('/api/motoristas',  require('./routes/motoristaRoutes'));
// app.use('/api/viagens',     require('./routes/viagemRoutes'));
// app.use('/api/manutencao',  require('./routes/manutencaoRoutes'));
// app.use('/api/multas',      require('./routes/multaRoutes'));
// app.use('/api/abastecimento', require('./routes/abastecimentoRoutes'));
// app.use('/api/documentos',  require('./routes/documentoRoutes'));
// app.use('/api/camera',      require('./routes/cameraRoutes'));

// =========================
// ROTA DE TESTE
// =========================
app.get('/api', (req, res) => {
    res.json({ mensagem: 'API Gestão de Frota funcionando!' });
});

// =========================
// INICIAR SERVIDOR
// =========================
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
});

module.exports = app;
