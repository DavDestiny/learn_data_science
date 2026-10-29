# SQL Server — Fundamentos e práticas

Coleção de consultas T-SQL desenvolvidas e revisadas durante meus estudos. O foco é praticar leitura de código, manipulação de dados, regras condicionais e consultas orientadas a problemas.

> **Nota:** os exemplos são educacionais e pressupõem uma base de testes com as tabelas mencionadas. Ajuste nomes de bancos e tabelas conforme seu ambiente. Não execute operações de alteração em bases de produção sem revisão e autorização.

## Conteúdo

| Arquivo | Tema | O que demonstra |
|---|---|---|
| [01 — UPDATE com JOIN](01-update-from-join.sql) | Atualização baseada em outra tabela | Relacionar clientes e vendedores e atualizar um valor |
| [02 — MERGE](02-merge-produtos.sql) | Sincronização de valores | Atualizar produtos quando há correspondência |
| [03 — Funções de texto](03-funcoes-texto.sql) | SUBSTRING e CHARINDEX | Extrair partes de textos e filtrar descrições |
| [04 — NOT IN e NOT EXISTS](04-subconsultas-not-in-not-exists.sql) | Subconsultas | Encontrar produtos sem correspondência |
| [05 — IF e variáveis](05-controle-fluxo-idade.sql) | Controle de fluxo | Comparar um valor calculado com o armazenado |
| [06 — Fibonacci com WHILE](06-fibonacci-while.sql) | Laços e estado | Gerar uma sequência com variáveis |
| [07 — Vendas por produto](07-vendas-por-produto.sql) | JOIN e agregação | Calcular vendas por produto sem percorrer produto a produto |

## Padrão de documentação

As consultas incluem comentários com o objetivo, a interpretação da lógica e os cuidados relevantes. Quando uma solução tem limitações conhecidas, elas são registradas para tornar o código mais fácil de revisar no futuro.

## Conceitos praticados

- `SELECT`, `WHERE` e filtros;
- `INNER JOIN`;
- `UPDATE ... FROM` e `MERGE`;
- `SUBSTRING`, `CHARINDEX`, `CASE` e `CONCAT`;
- `NOT IN` e `NOT EXISTS`;
- variáveis, `IF`, `WHILE` e `DATEDIFF`;
- `SUM`, `GROUP BY` e agregações.

## Próximas melhorias

- Adicionar conjuntos de dados de teste fictícios;
- documentar resultados esperados para cada exemplo;
- comparar planos de execução quando houver alternativas;
- criar projetos analíticos com perguntas de negócio e conclusões.

## Segurança e integridade dos dados

Os exemplos não devem conter CPF real, NDG real, credenciais ou detalhes internos de sistemas corporativos. Consultas de escrita (`UPDATE`, `MERGE`, `DELETE`) devem ser testadas em ambiente isolado e revisadas antes da execução.

---

*Material de estudo: evolui conforme novas consultas são praticadas e validadas.*
