# prison-db-mysql

Sistema de banco de dados para gestão de presídio, desenvolvido com **MySQL 8.0** rodando via **Docker** e administrado pelo **DBeaver**.

---

##  Arquitetura

```
┌─────────────────────────────────────────┐
│              Docker Host                │
│                                         │
│   ┌─────────────────────────────────┐   │
│   │     Container: mysql-db         │   │
│   │     image: mysql:8.0            │   │
│   │                                 │   │
│   │   ┌─────────────────────────┐   │   │
│   │   │      MySQL Server       │   │   │
│   │   │    porta interna 3306   │   │   │
│   │   └────────────┬────────────┘   │   │
│   │                │                │   │
│   │   ┌────────────▼────────────┐   │   │
│   │   │   Volume: mysql-data    │   │   │
│   │   │  /var/lib/mysql (dados) │   │   │
│   │   └─────────────────────────┘   │   │
│   └──────────────┬──────────────────┘   │
│                  │                      │
│   ┌──────────────▼──────────────────┐   │
│   │  Porta: host:3306 → cont.:3306  │   │
│   └──────────────┬──────────────────┘   │
└─────────────────-│───────────────────---┘
                   │ localhost:3306
             ┌─────▼──────┐
             │   DBeaver  │
             │  (cliente) │
             └────────────┘
```

---

## Tabelas

| Tabela | Descrição |
|---|---|
| `cela` | Cadastro de celas (número, bloco, capacidade, status) |
| `detento` | Cadastro de detentos com regime e cela alocada |
| `funcionario` | Agentes, gestores e admins do presídio |
| `visita` | Visitas recebidas pelos detentos |
| `transferencia` | Histórico de transferências entre celas |

---

## Relacionamentos

```
cela ──────< detento ──────< visita
                    └──────< transferencia
funcionario ───────< visita
funcionario ───────< transferencia
```

- Uma **cela** abriga vários **detentos**
- Um **detento** recebe várias **visitas**
- Um **detento** pode sofrer várias **transferências**
- Um **funcionário** autoriza visitas e registra transferências

---

## Como rodar

### Pré-requisitos
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [DBeaver](https://dbeaver.io/)

### 1. Subir o banco com Docker

```powershell
docker run -d `
  --name mysql-db `
  -e MYSQL_ROOT_PASSWORD=root123 `
  -e MYSQL_DATABASE=meubanco `
  -e MYSQL_USER=usuario `
  -e MYSQL_PASSWORD=senha123 `
  -p 3306:3306 `
  -v mysql-data:/var/lib/mysql `
  mysql:8.0
```

### 2. Verificar se está rodando

```powershell
docker ps
```

### 3. Conectar no DBeaver

| Campo | Valor |
|---|---|
| Host | `localhost` |
| Porta | `3306` |
| Banco | `meubanco` |
| Usuário | `usuario` |
| Senha | `senha123` |

> Em **Driver Properties**, setar `allowPublicKeyRetrieval = true` e `useSSL = false`

### 4. Executar o script

Abrir o arquivo `script_presidio.sql` no DBeaver e executar com `Ctrl+Enter`.

---

## Exemplos de consultas

### INNER JOIN — detentos com suas celas
```sql
SELECT d.nome, d.regime, c.numero AS cela, c.bloco
FROM detento d
INNER JOIN cela c ON d.cela_id = c.id;
```

### LEFT JOIN — todos os detentos com total de visitas
```sql
SELECT d.nome, d.regime, COUNT(v.id) AS total_visitas
FROM detento d
LEFT JOIN visita v ON v.detento_id = d.id
GROUP BY d.id, d.nome, d.regime;
```

### CROSS JOIN — combinações detento x funcionário
```sql
SELECT d.nome AS detento, f.nome AS funcionario, f.cargo
FROM detento d
CROSS JOIN funcionario f;
```

---

## Tecnologias

- **MySQL 8.0**
- **Docker**
- **DBeaver**
