CREATE DATABASE IF NOT EXISTS meubanco;
USE meubanco;

CREATE TABLE pavilhao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    nivel_seguranca ENUM('baixo', 'medio', 'alto') NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cela (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(10) NOT NULL UNIQUE,
    bloco VARCHAR(10) NOT NULL,
    capacidade INT NOT NULL DEFAULT 4,
    status ENUM('disponivel', 'lotada', 'interditada') DEFAULT 'disponivel',
    pavilhao_id INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (pavilhao_id) REFERENCES pavilhao(id)
);

CREATE TABLE funcionario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    cargo ENUM('agente', 'gestor', 'admin') DEFAULT 'agente',
    matricula VARCHAR(20) NOT NULL UNIQUE,
    ativo BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE advogado (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    oab VARCHAR(20) NOT NULL UNIQUE,
    telefone VARCHAR(20),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE crime (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    artigo_penal VARCHAR(50),
    pena_anos INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE processo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero_processo VARCHAR(50) NOT NULL UNIQUE,
    status ENUM('andamento', 'concluido', 'arquivado') DEFAULT 'andamento',
    advogado_id INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (advogado_id) REFERENCES advogado(id)
);

CREATE TABLE detento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    data_nascimento DATE NOT NULL,
    data_entrada DATE NOT NULL,
    previsao_saida DATE,
    regime ENUM('fechado', 'semiaberto', 'aberto') DEFAULT 'fechado',
    grau_periculosidade ENUM('baixo', 'medio', 'alto') DEFAULT 'medio',
    cela_id INT,
    crime_id INT,
    processo_id INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (cela_id) REFERENCES cela(id),
    FOREIGN KEY (crime_id) REFERENCES crime(id),
    FOREIGN KEY (processo_id) REFERENCES processo(id)
);

CREATE TABLE visita (
    id INT AUTO_INCREMENT PRIMARY KEY,
    detento_id INT NOT NULL,
    funcionario_id INT NOT NULL,
    nome_visitante VARCHAR(100) NOT NULL,
    cpf_visitante CHAR(11) NOT NULL,
    parentesco VARCHAR(50),
    data_visita DATETIME NOT NULL,
    status ENUM('agendada', 'realizada', 'cancelada') DEFAULT 'agendada',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (detento_id) REFERENCES detento(id),
    FOREIGN KEY (funcionario_id) REFERENCES funcionario(id)
);

CREATE TABLE transferencia (
    id INT AUTO_INCREMENT PRIMARY KEY,
    detento_id INT NOT NULL,
    cela_origem_id INT,
    cela_destino_id INT NOT NULL,
    data_transferencia DATE NOT NULL,
    motivo VARCHAR(255),
    funcionario_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (detento_id) REFERENCES detento(id),
    FOREIGN KEY (cela_origem_id) REFERENCES cela(id),
    FOREIGN KEY (cela_destino_id) REFERENCES cela(id),
    FOREIGN KEY (funcionario_id) REFERENCES funcionario(id)
);

CREATE TABLE ocorrencia (
    id INT AUTO_INCREMENT PRIMARY KEY,
    detento_id INT NOT NULL,
    funcionario_id INT NOT NULL,
    descricao TEXT NOT NULL,
    gravidade ENUM('leve', 'media', 'grave') DEFAULT 'leve',
    data_ocorrencia DATETIME NOT NULL,

    FOREIGN KEY (detento_id) REFERENCES detento(id),
    FOREIGN KEY (funcionario_id) REFERENCES funcionario(id)
);


INSERT INTO pavilhao (nome, nivel_seguranca) VALUES
('Pavilhao A', 'baixo'),
('Pavilhao B', 'medio'),
('Pavilhao C', 'alto');

INSERT INTO cela (numero, bloco, capacidade, status, pavilhao_id) VALUES
('A01', 'A', 4, 'disponivel', 1),
('A02', 'A', 4, 'disponivel', 1),
('B01', 'B', 2, 'lotada', 2),
('B02', 'B', 6, 'disponivel', 2),
('C01', 'C', 1, 'interditada', 3);

INSERT INTO funcionario (nome, cpf, cargo, matricula) VALUES
('Carlos Silva', '12345678901', 'admin', 'MAT001'),
('Ana Souza', '23456789012', 'gestor', 'MAT002'),
('Pedro Oliveira', '34567890123', 'agente', 'MAT003'),
('Ricardo Alves', '45678901234', 'agente', 'MAT004'),
('Juliana Costa', '56789012345', 'gestor', 'MAT005');

INSERT INTO advogado (nome, cpf, oab, telefone) VALUES
('Marcos Lima', '67890123456', 'OAB12345', '81999999999'),
('Fernanda Rocha', '78901234567', 'OAB54321', '81988888888');

INSERT INTO crime (nome, artigo_penal, pena_anos) VALUES
('Roubo', '157', 10),
('Homicidio', '121', 20),
('Furto', '155', 4),
('Trafico', '33', 15);

INSERT INTO processo (numero_processo, status, advogado_id) VALUES
('PROC001', 'andamento', 1),
('PROC002', 'andamento', 2),
('PROC003', 'concluido', 1),
('PROC004', 'arquivado', 2);

INSERT INTO detento (
nome,
cpf,
data_nascimento,
data_entrada,
previsao_saida,
regime,
grau_periculosidade,
cela_id,
crime_id,
processo_id
) VALUES
('Joao Santos', '89012345678', '1985-03-12', '2022-01-10', '2030-01-10', 'fechado', 'alto', 1, 2, 1),
('Lucas Lima', '90123456789', '1990-07-22', '2023-06-01', '2028-06-01', 'semiaberto', 'medio', 2, 1, 2),
('Rafael Costa', '01234567890', '1978-11-05', '2021-09-15', '2035-09-15', 'fechado', 'alto', 3, 4, 3),
('Andre Souza', '11111111111', '1992-08-10', '2024-01-01', '2027-01-01', 'aberto', 'baixo', 4, 3, 4),
('Felipe Alves', '22222222222', '1980-04-18', '2020-05-05', '2032-05-05', 'fechado', 'medio', 1, 2, 1);

INSERT INTO visita (
 detento_id,
 funcionario_id,
 nome_visitante,
 cpf_visitante,
 parentesco,
 data_visita,
 status
) VALUES
(1, 3, 'Maria Santos', '33333333333', 'esposa', '2026-05-10 14:00:00', 'realizada'),
(2, 3, 'Paulo Lima', '44444444444', 'pai', '2026-05-12 10:00:00', 'agendada'),
(3, 4, 'Ana Costa', '55555555555', 'irma', '2026-05-13 09:00:00', 'cancelada');

INSERT INTO transferencia (
 detento_id,
 cela_origem_id,
 cela_destino_id,
 data_transferencia,
 motivo,
 funcionario_id
) VALUES
(3, 3, 4, '2026-04-20', 'Superlotacao', 2),
(2, 2, 1, '2026-04-25', 'Seguranca', 5);

INSERT INTO ocorrencia (
 detento_id,
 funcionario_id,
 descricao,
 gravidade,
 data_ocorrencia
) VALUES
(1, 3, 'Tentativa de briga', 'media', '2026-05-01 10:00:00'),
(3, 4, 'Desobediencia', 'leve', '2026-05-03 11:00:00'),
(5, 2, 'Tentativa de fuga', 'grave', '2026-05-05 20:00:00');


SELECT * FROM detento;
SELECT * FROM cela;
SELECT * FROM funcionario;
SELECT * FROM visita;
SELECT * FROM transferencia;
SELECT * FROM ocorrencia;
SELECT * FROM advogado;
SELECT * FROM crime;
SELECT * FROM processo;
SELECT * FROM pavilhao;

SELECT * FROM detento WHERE regime = 'fechado';
SELECT * FROM detento WHERE grau_periculosidade = 'alto';
SELECT * FROM cela WHERE status = 'lotada';
SELECT * FROM funcionario WHERE ativo = TRUE;
SELECT * FROM visita WHERE status = 'agendada';
SELECT * FROM ocorrencia WHERE gravidade = 'grave';
SELECT * FROM processo WHERE status = 'andamento';
SELECT * FROM crime WHERE pena_anos > 10;
SELECT * FROM detento WHERE previsao_saida > '2030-01-01';
SELECT * FROM cela WHERE capacidade >= 4;

-- Detento e cela
SELECT 
    d.nome,
    c.numero AS cela,
    c.bloco
FROM detento d
INNER JOIN cela c ON d.cela_id = c.id;

-- Detento e crime
SELECT 
    d.nome,
    cr.nome AS crime
FROM detento d
INNER JOIN crime cr ON d.crime_id = cr.id;

-- Detento e processo
SELECT 
    d.nome,
    p.numero_processo
FROM detento d
INNER JOIN processo p ON d.processo_id = p.id;

-- Cela e pavilhao
SELECT 
    p.nome,
    c.numero
FROM cela c
INNER JOIN pavilhao p ON c.pavilhao_id = p.id;

-- Visita e detento
SELECT 
    v.nome_visitante,
    d.nome AS detento
FROM visita v
INNER JOIN detento d ON v.detento_id = d.id;

-- Visita e funcionario
SELECT 
    v.nome_visitante,
    f.nome AS funcionario
FROM visita v
INNER JOIN funcionario f ON v.funcionario_id = f.id;

-- Transferencia e detento
SELECT 
    t.data_transferencia,
    d.nome
FROM transferencia t
INNER JOIN detento d ON t.detento_id = d.id;

-- Ocorrencia e detento
SELECT 
    o.descricao,
    d.nome
FROM ocorrencia o
INNER JOIN detento d ON o.detento_id = d.id;

-- Ocorrencia e funcionario
SELECT 
    o.descricao,
    f.nome
FROM ocorrencia o
INNER JOIN funcionario f ON o.funcionario_id = f.id;

-- Processo e advogado
SELECT 
    p.numero_processo,
    a.nome AS advogado
FROM processo p
INNER JOIN advogado a ON p.advogado_id = a.id;

SELECT COUNT(*) AS total_detentos FROM detento;
SELECT COUNT(*) AS total_funcionarios FROM funcionario;
SELECT COUNT(*) AS total_visitas FROM visita;

SELECT AVG(capacidade) AS media_capacidade FROM cela;
SELECT AVG(pena_anos) AS media_pena FROM crime;
SELECT AVG(id) AS media_ids FROM funcionario;

SELECT MAX(capacidade) AS maior_capacidade FROM cela;
SELECT MIN(capacidade) AS menor_capacidade FROM cela;
SELECT SUM(capacidade) AS capacidade_total FROM cela;


UPDATE cela SET status = 'lotada' WHERE id = 1;
UPDATE cela SET status = 'interditada' WHERE id = 2;
UPDATE funcionario SET ativo = FALSE WHERE id = 3;
UPDATE detento SET regime = 'semiaberto' WHERE id = 1;
UPDATE detento SET cela_id = 2 WHERE id = 5;
UPDATE visita SET status = 'realizada' WHERE id = 2;
UPDATE ocorrencia SET gravidade = 'grave' WHERE id = 2;
UPDATE crime SET pena_anos = 12 WHERE id = 1;
UPDATE processo SET status = 'concluido' WHERE id = 1;
UPDATE advogado SET telefone = '81977777777' WHERE id = 2;

DELETE FROM visita WHERE id = 3;
DELETE FROM ocorrencia WHERE id = 2;
DELETE FROM transferencia WHERE id = 2;
DELETE FROM advogado WHERE id = 2;
DELETE FROM crime WHERE id = 3;
DELETE FROM processo WHERE id = 4;
DELETE FROM funcionario WHERE id = 5;
DELETE FROM cela WHERE id = 5;
DELETE FROM detento WHERE id = 4;
DELETE FROM pavilhao WHERE id = 3;

USE meubanco;

SHOW TABLES;
DESCRIBE detento;
SHOW TABLE STATUS;''
