# Prison-DB-MySQL

Sistema de gerenciamento de banco de dados prisional desenvolvido para otimizar a administração de detentos, celas e pavilhões. O projeto utiliza **MySQL 8.0** em ambiente **Docker** para garantir portabilidade e isolamento.

## Funcionalidades Principais

*   **Gestão de Detentos:** Controle de prontuário, regime, periculosidade e situação processual.
*   **Controle de Infraestrutura:** Gerenciamento de pavilhões e celas com monitoramento de capacidade e status.
*   **Segurança e Vigilância:** Registro de ocorrências disciplinares e histórico de transferências.
*   **Administração de Acessos:** Cadastro de funcionários (agentes/gestores), advogados e controle de visitas.
*   **Automação de Dados:** Cálculo de pena e remoção automática após cumprimento integral.

## Regras de Negócio

Para garantir a integridade e a segurança do sistema prisional, as seguintes regras foram implementadas:

1.  **Alocação por Periculosidade:** Detentos com alto grau de periculosidade devem ser preferencialmente alocados em pavilhões de segurança máxima.
2.  **Capacidade das Celas:** O sistema impede a alocação de novos detentos em celas com status 'lotada' ou 'interditada'.
3.  **Controle de Visitas:** Apenas funcionários ativos podem registrar e autorizar visitas.
4.  **Histórico de Transferência:** Toda mudança de cela deve obrigatoriamente registrar a cela de origem, destino, motivo e o funcionário responsável.
5.  **Gestão Processual:** Cada detento deve estar vinculado a um processo judicial e, opcionalmente, a um advogado cadastrado.

## Estrutura do Banco de Dados (Dicionário de Dados)

O banco de dados `meubanco` é composto por tabelas normalizadas para evitar redundância.

### 1. Infraestrutura (`pavilhao` e `cela`)
| Tabela | Campo | Tipo | Descrição |
| :--- | :--- | :--- | :--- |
| `pavilhao` | `nome` | VARCHAR(50) | Nome identificador do pavilhão. |
| `pavilhao` | `nivel_seguranca` | ENUM | Níveis: baixo, medio, alto. |
| `cela` | `numero` | VARCHAR(10) | Identificador único da cela. |
| `cela` | `capacidade` | INT | Limite máximo de detentos (Default: 4). |
| `cela` | `status` | ENUM | Estados: disponivel, lotada, interditada. |

### 2. Gestão de Pessoas (`detento`, `funcionario`, `advogado`)
| Tabela | Campo | Tipo | Descrição |
| :--- | :--- | :--- | :--- |
| `detento` | `nome` | VARCHAR(100) | Nome completo do apenado. |
| `detento` | `cpf` | CHAR(11) | CPF único para evitar homônimos. |
| `detento` | `regime` | ENUM | fechado, semiaberto, aberto. |
| `funcionario` | `matricula` | VARCHAR(20) | Identificador funcional único. |
| `advogado` | `oab` | VARCHAR(20) | Registro profissional na ordem. |

## Implementação Técnica (SQL)

### Definição de Estrutura (DDL)

```sql
-- Criação da Tabela de Detentos com Relacionamentos
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
```

## Guia de Instalação e Configuração

### 1. Ambiente Docker
Para subir o banco de dados rapidamente, utilize o comando abaixo:

```powershell
docker run -d \
  --name mysql-db \
  -e MYSQL_ROOT_PASSWORD=root123 \
  -e MYSQL_DATABASE=meubanco \
  -e MYSQL_USER=usuario \
  -e MYSQL_PASSWORD=senha123 \
  -p 3306:3306 \
  -v mysql-data:/var/lib/mysql \
  mysql:8.0
```

### 2. Conexão via DBeaver
Conecte-se ao banco utilizando as credenciais definidas no Docker:
*   **Host:** `localhost`
*   **Porta:** `3306`
*   **Database:** `meubanco`
*   **User:** `usuario`
*   **Password:** `senha123`

## Consultas e Resultados Esperados

Abaixo estão os principais relatórios do sistema com seus respectivos resultados baseados nos dados de exemplo.

### 1. Relatório de Localização e Regime (INNER JOIN)
Cruza os dados do detento com sua respectiva cela e bloco.

```sql
SELECT d.nome, d.regime, c.numero AS cela, c.bloco
FROM detento d
INNER JOIN cela c ON d.cela_id = c.id;
```

**Resultado:**
| nome | regime | cela | bloco |
| :--- | :--- | :--- | :--- |
| Joao Santos | fechado | A01 | A |
| Lucas Lima | semiaberto | A02 | A |
| Rafael Costa | fechado | B01 | B |
| Felipe Alves | fechado | A01 | A |

---

### 2. Controle de Visitas por Detento (LEFT JOIN)
Lista todos os detentos e a quantidade de visitas que cada um recebeu.

```sql
SELECT d.nome, d.regime, COUNT(v.id) AS total_visitas
FROM detento d
LEFT JOIN visita v ON v.detento_id = d.id
GROUP BY d.id, d.nome, d.regime;
```

**Resultado:**
| nome | regime | total_visitas |
| :--- | :--- | :--- |
| Joao Santos | fechado | 1 |
| Lucas Lima | semiaberto | 1 |
| Rafael Costa | fechado | 1 |
| Andre Souza | aberto | 0 |
| Felipe Alves | fechado | 0 |

---

### 3. Estatísticas Gerais (Agregações)
Resumo quantitativo do sistema.

```sql
SELECT 
    (SELECT COUNT(*) FROM detento) AS total_detentos,
    (SELECT COUNT(*) FROM funcionario) AS total_funcionarios,
    (SELECT AVG(capacidade) FROM cela) AS media_capacidade_celas;
```

**Resultado:**
| total_detentos | total_funcionarios | media_capacidade_celas |
| :--- | :--- | :--- |
| 5 | 5 | 3.4000 |

---

### 4. Histórico de Transferências
Rastreabilidade de movimentação interna.

```sql
SELECT 
    t.data_transferencia,
    d.nome AS detento,
    c1.numero AS origem,
    c2.numero AS destino,
    t.motivo
FROM transferencia t
JOIN detento d ON t.detento_id = d.id
JOIN cela c1 ON t.cela_origem_id = c1.id
JOIN cela c2 ON t.cela_destino_id = c2.id;
```

**Resultado:**
| data_transferencia | detento | origem | destino | motivo |
| :--- | :--- | :--- | :--- | :--- |
| 2026-04-20 | Rafael Costa | B01 | B02 | Superlotacao |
| 2026-04-25 | Lucas Lima | A02 | A01 | Seguranca |

## Manutenção de Dados (DML)

### Atualização de Status de Cela
```sql
UPDATE cela SET status = 'lotada' WHERE id = 1;
-- Resultado: Query OK, 1 row affected
```

### Remoção de Registro
```sql
DELETE FROM visita WHERE id = 3;
-- Resultado: Query OK, 1 row affected
```

## Tecnologias Utilizadas
*   **MySQL 8.0**
*   **Docker**
*   **DBeaver**
*   **Markdown**
