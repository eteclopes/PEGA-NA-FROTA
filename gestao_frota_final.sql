-- =====================================================
-- BANCO DE DADOS: GESTÃO DE FROTA DE CAMINHÕES
-- TCC - Script Final
-- =====================================================

CREATE DATABASE IF NOT EXISTS gestao_frota;
USE gestao_frota;

-- =========================
-- TABELA DE USUÁRIOS
-- (gestores do sistema)
-- =========================
CREATE TABLE user (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    nome            VARCHAR(100) NOT NULL,
    login           VARCHAR(50)  NOT NULL UNIQUE,
    senha           VARCHAR(255) NOT NULL,
    nivel_acesso    VARCHAR(50)  NOT NULL,
    ativo           TINYINT(1)   DEFAULT 1   -- 0 = desativado (exclusão lógica)
);

-- =========================
-- TABELA DE VEÍCULOS
-- =========================
CREATE TABLE controle_veiculo (
    id_veiculo          INT AUTO_INCREMENT PRIMARY KEY,
    placa               VARCHAR(10)  NOT NULL UNIQUE,
    modelo              VARCHAR(100) NOT NULL,
    marca               VARCHAR(100) NOT NULL,
    ano                 YEAR         NOT NULL,
    tipo_veiculo        VARCHAR(50)  NOT NULL,           -- ex: 'Caminhão Toco', 'Bitruck', 'Carreta'
    tipo_combustivel    VARCHAR(30)  NOT NULL,           -- ex: 'Diesel S-10', 'Diesel S-500'
    quilometragem       INT          NOT NULL,
    capacidade_carga_kg DECIMAL(10,2),                  -- capacidade máxima de carga em kg
    status_veiculo      VARCHAR(50)  NOT NULL,           -- 'Disponível', 'Em viagem', 'Em manutenção'
    ativo               TINYINT(1)   DEFAULT 1           -- 0 = veículo removido da frota ativa
);

-- =========================
-- TABELA DE MOTORISTAS
-- =========================
CREATE TABLE motorista (
    id_motorista        INT AUTO_INCREMENT PRIMARY KEY,
    nome                VARCHAR(100) NOT NULL,
    cnh                 VARCHAR(20)  NOT NULL UNIQUE,
    categoria_cnh       VARCHAR(5)   NOT NULL,           -- C, D ou E (obrigatório para caminhão)
    vencimento_cnh      DATE         NOT NULL,
    data_nascimento     DATE,
    telefone            VARCHAR(20),
    status_motorista    VARCHAR(50),                     -- 'Ativo', 'De férias', 'Afastado'
    ativo               TINYINT(1)   DEFAULT 1           -- 0 = motorista desligado
);

-- =========================
-- TABELA DE MANUTENÇÃO
-- (manutenções já realizadas)
-- =========================
CREATE TABLE controle_manutencao (
    id_manutencao               INT AUTO_INCREMENT PRIMARY KEY,
    id_veiculo                  INT          NOT NULL,
    tipo_manutencao             VARCHAR(50)  NOT NULL,   -- 'Corretiva', 'Preventiva'
    data_manutencao             DATE         NOT NULL,
    descricao_servico           VARCHAR(255) NOT NULL,
    custo                       DECIMAL(10,2) NOT NULL,
    quilometragem_manutencao    INT          NOT NULL,
    oficina                     VARCHAR(100),
    FOREIGN KEY (id_veiculo) REFERENCES controle_veiculo(id_veiculo)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- =========================
-- TABELA DE MANUTENÇÃO PREVENTIVA
-- (agendamentos e alertas futuros)
-- =========================
CREATE TABLE manutencao_preventiva (
    id_preventiva           INT AUTO_INCREMENT PRIMARY KEY,
    id_veiculo              INT          NOT NULL,
    tipo_servico            VARCHAR(100) NOT NULL,       -- ex: 'Troca de óleo', 'Revisão freios'
    data_prevista           DATE,
    quilometragem_prevista  INT,                         -- ex: avisar quando chegar em X km
    status                  VARCHAR(50)  DEFAULT 'Pendente', -- 'Pendente', 'Concluída', 'Atrasada'
    observacoes             TEXT,
    FOREIGN KEY (id_veiculo) REFERENCES controle_veiculo(id_veiculo)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- =========================
-- TABELA DE MULTAS
-- =========================
CREATE TABLE controle_multas (
    id_multa        INT AUTO_INCREMENT PRIMARY KEY,
    id_veiculo      INT,                                 -- NULL se veículo for removido
    id_motorista    INT,                                 -- NULL se motorista for removido
    data_infracao   DATE          NOT NULL,
    tipo_multa      VARCHAR(100)  NOT NULL,
    valor_multa     DECIMAL(10,2) NOT NULL,
    situacao_multa  VARCHAR(50)   NOT NULL,              -- 'Pendente', 'Paga', 'Recurso'
    FOREIGN KEY (id_veiculo) REFERENCES controle_veiculo(id_veiculo)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (id_motorista) REFERENCES motorista(id_motorista)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- =========================
-- TABELA DE VIAGENS
-- =========================
CREATE TABLE controle_viagem (
    id_viagem               INT AUTO_INCREMENT PRIMARY KEY,
    id_veiculo              INT,
    id_motorista            INT,
    data_saida              DATETIME     NOT NULL,
    data_retorno            DATETIME,
    origem                  VARCHAR(100) NOT NULL,
    destino                 VARCHAR(100) NOT NULL,
    finalidade              VARCHAR(255),
    quilometragem_inicial   INT          NOT NULL,
    quilometragem_final     INT,
    carga_transportada      VARCHAR(255),               -- descrição da carga
    peso_carga_kg           DECIMAL(10,2),              -- peso da carga em kg
    FOREIGN KEY (id_veiculo) REFERENCES controle_veiculo(id_veiculo)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (id_motorista) REFERENCES motorista(id_motorista)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- =========================
-- TABELA DE ABASTECIMENTO
-- =========================
CREATE TABLE abastecimento (
    id_abastecimento            INT AUTO_INCREMENT PRIMARY KEY,
    id_veiculo                  INT,
    id_motorista                INT,
    data_abastecimento          DATE          NOT NULL,
    tipo_combustivel            VARCHAR(30)   NOT NULL,
    quantidade_litros           DECIMAL(10,2) NOT NULL,
    valor_litro                 DECIMAL(10,2) NOT NULL,
    valor_total                 DECIMAL(10,2) NOT NULL,
    quilometragem_abastecimento INT           NOT NULL,
    posto_combustivel           VARCHAR(100),
    FOREIGN KEY (id_veiculo) REFERENCES controle_veiculo(id_veiculo)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (id_motorista) REFERENCES motorista(id_motorista)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- =========================
-- TABELA DE DOCUMENTOS DO VEÍCULO
-- (CRLV, Seguro, IPVA, Vistoria)
-- =========================
CREATE TABLE documentos_veiculo (
    id_documento        INT AUTO_INCREMENT PRIMARY KEY,
    id_veiculo          INT          NOT NULL,
    tipo_documento      VARCHAR(50)  NOT NULL,           -- 'CRLV', 'Seguro', 'IPVA', 'Vistoria'
    data_emissao        DATE,
    data_vencimento     DATE         NOT NULL,
    numero_documento    VARCHAR(100),
    arquivo_path        VARCHAR(255),                    -- caminho do PDF/imagem do documento
    status              VARCHAR(30)  DEFAULT 'Válido',   -- 'Válido', 'Vencido', 'A vencer'
    FOREIGN KEY (id_veiculo) REFERENCES controle_veiculo(id_veiculo)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- =========================
-- TABELA DE RELATÓRIOS
-- =========================
CREATE TABLE relatorios (
    id_relatorio    INT AUTO_INCREMENT PRIMARY KEY,
    tipo_relatorio  VARCHAR(100) NOT NULL,
    data_geracao    DATETIME     DEFAULT CURRENT_TIMESTAMP,
    id_usuario      INT,
    FOREIGN KEY (id_usuario) REFERENCES user(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- =========================
-- TABELA DE REGISTRO DA CÂMERA
-- (reservada para integração futura com ESP32-CAM)
-- =========================
CREATE TABLE registro_camera (
    id_registro         INT AUTO_INCREMENT PRIMARY KEY,
    id_veiculo          INT,
    id_viagem           INT,
    data_hora           DATETIME     NOT NULL,
    tipo_evento         VARCHAR(50),                     -- 'Saída da frota', 'Retorno', 'Alerta'
    imagem_path         VARCHAR(255),                    -- caminho da foto salva
    placa_detectada     VARCHAR(10),                     -- placa lida pelo ESP32-CAM (OCR futuro)
    observacao          TEXT,
    FOREIGN KEY (id_veiculo) REFERENCES controle_veiculo(id_veiculo)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (id_viagem) REFERENCES controle_viagem(id_viagem)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
