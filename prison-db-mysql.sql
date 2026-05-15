USE meubanco;

-- CELAS
CREATE TABLE cela (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    numero      VARCHAR(10)  NOT NULL UNIQUE,
    bloco       VARCHAR(10)  NOT NULL,
    capacidade  INT          NOT NULL DEFAULT 4,
    status      ENUM('disponivel', 'lotada', 'interditada') NOT NULL DEFAULT 'disponivel',
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- FUNCIONÁRIOS
CREATE TABLE funcionario (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    nome        VARCHAR(100) NOT NULL,
    cpf         CHAR(11)     NOT NULL UNIQUE,
    cargo       ENUM('agente', 'gestor', 'admin') NOT NULL DEFAULT 'agente',
    matricula   VARCHAR(20)  NOT NULL UNIQUE,
    ativo       BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- DETENTOS
CREATE TABLE detento (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    nome             VARCHAR(100) NOT NULL,
    cpf              CHAR(11)     NOT NULL UNIQUE,
    data_nascimento  DATE         NOT NULL,
    data_entrada     DATE         NOT NULL,
    previsao_saida   DATE,
    regime           ENUM('fechado', 'semiaberto', 'aberto') NOT NULL DEFAULT 'fechado',
    cela_id          INT          REFERENCES cela(id),
    created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- VISITAS
CREATE TABLE visita (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    detento_id       INT          NOT NULL REFERENCES detento(id),
    funcionario_id   INT          NOT NULL REFERENCES funcionario(id),
    nome_visitante   VARCHAR(100) NOT NULL,
    cpf_visitante    CHAR(11)     NOT NULL,
    parentesco       VARCHAR(50),
    data_visita      DATETIME     NOT NULL,
    status           ENUM('agendada', 'realizada', 'cancelada') NOT NULL DEFAULT 'agendada',
    created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- TRANSFERÊNCIAS
CREATE TABLE transferencia (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    detento_id       INT          NOT NULL REFERENCES detento(id),
    cela_origem_id   INT          REFERENCES cela(id),
    cela_destino_id  INT          NOT NULL REFERENCES cela(id),
    data_transferencia DATE        NOT NULL,
    motivo           VARCHAR(255),
    funcionario_id   INT          NOT NULL REFERENCES funcionario(id),
    created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO cela (numero, bloco, capacidade) VALUES
('A01', 'A', 4), ('A02', 'A', 4), ('B01', 'B', 2), ('B02', 'B', 6);

INSERT INTO funcionario (nome, cpf, cargo, matricula) VALUES
('Carlos Silva',  '12345678901', 'admin',  'MAT001'),
('Ana Souza',     '23456789012', 'gestor', 'MAT002'),
('Pedro Oliveira','34567890123', 'agente', 'MAT003');

INSERT INTO detento (nome, cpf, data_nascimento, data_entrada, regime, cela_id) VALUES
('João Santos',   '45678901234', '1985-03-12', '2022-01-10', 'fechado',    1),
('Lucas Lima',    '56789012345', '1990-07-22', '2023-06-01', 'semiaberto', 2),
('Rafael Costa',  '67890123456', '1978-11-05', '2021-09-15', 'fechado',    1);

INSERT INTO visita (detento_id, funcionario_id, nome_visitante, cpf_visitante, parentesco, data_visita) VALUES
(1, 3, 'Maria Santos', '78901234567', 'esposa', '2026-05-10 14:00:00'),
(2, 3, 'Paulo Lima',   '89012345678', 'pai',    '2026-05-12 10:00:00');

INSERT INTO transferencia (detento_id, cela_origem_id, cela_destino_id, data_transferencia, motivo, funcionario_id) VALUES
(3, 1, 3, '2026-04-20', 'Superlotação da cela A01', 2);

-- Detentos com suas celas
SELECT 
    d.nome,
    d.regime,
    c.numero AS cela,
    c.bloco
FROM detento d
INNER JOIN cela c ON d.cela_id = c.id;

-- Visitas com o detento e o funcionário que autorizou
SELECT 
    v.data_visita,
    v.nome_visitante,
    v.parentesco,
    d.nome AS detento,
    f.nome AS autorizado_por
FROM visita v
INNER JOIN detento    d ON v.detento_id     = d.id
INNER JOIN funcionario f ON v.funcionario_id = f.id;

-- Todos os detentos, com ou sem visita
SELECT 
    d.nome,
    d.regime,
    COUNT(v.id) AS total_visitas
FROM detento d
LEFT JOIN visita v ON v.detento_id = d.id
GROUP BY d.id, d.nome, d.regime;

-- Todas as celas, com ou sem detento alocado
SELECT 
    c.numero,
    c.bloco,
    c.capacidade,
    COUNT(d.id) AS detentos_alocados
FROM cela c
LEFT JOIN detento d ON d.cela_id = c.id
GROUP BY c.id, c.numero, c.bloco, c.capacidade;

-- todas as combinações possíveis de detento x funcionário
SELECT 
    d.nome AS detento,
    f.nome AS funcionario,
    f.cargo
FROM detento d
CROSS JOIN funcionario f;

SHOW TABLE STATUS;