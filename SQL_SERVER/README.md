# SQL Server — Fundamentos e práticas

Coleção de consultas T-SQL desenvolvidas e revisadas durante meus estudos. O foco é praticar leitura de código, manipulação de dados, regras condicionais e consultas orientadas a problemas.

> **Nota:** os exemplos são educacionais. Parte deles pressupõe uma base de testes com as tabelas mencionadas (coluna **Autocontido**). Ajuste nomes de bancos e tabelas conforme seu ambiente. Não execute operações de alteração em bases de produção sem revisão e autorização.

## Conteúdo

| Arquivo | Tema | O que demonstra | Autocontido |
|---|---|---|---|
| [01 — UPDATE com JOIN](01-update-from-join.sql) | Atualização baseada em outra tabela | Relacionar clientes e vendedores, pré-visualizar, contar e atualizar dentro de uma transação | Não |
| [02 — MERGE](02-merge-produtos.sql) | Sincronização de valores | Verificar duplicidades na origem e atualizar produtos com `OUTPUT` | Não |
| [03 — Funções de texto](03-funcoes-texto.sql) | SUBSTRING, CHARINDEX e TRIM | Extrair partes de textos, filtrar prefixos e remover espaços | Parcial |
| [04 — NOT IN e NOT EXISTS](04-subconsultas-not-in-not-exists.sql) | Subconsultas | Encontrar produtos sem correspondência e entender o efeito do `NULL` | Parcial |
| [05 — IF e variáveis](05-controle-fluxo-idade.sql) | Controle de fluxo | Comparar um valor calculado com o armazenado | Não |
| [06 — Fibonacci com WHILE](06-fibonacci-while.sql) | Laços e estado | Gerar uma sequência com variáveis e conhecer os limites de `INT` e `BIGINT` | Sim |
| [07 — Vendas por produto](07-vendas-por-produto.sql) | JOIN, SUM e COUNT | Calcular vendas por produto com `INNER JOIN` e incluir produtos sem vendas com `LEFT JOIN` | Não |
| [08 — Último registro por cliente](08-row-number-ultimo-registro.sql) | ROW_NUMBER e datas | Identificar o registro mais recente por cliente e evitar a armadilha das datas nulas | Sim |

## Padrão de documentação

As consultas incluem comentários com o objetivo, a lógica, as regras de negócio, os cuidados relevantes e, quando aplicável, o resultado esperado. Quando uma solução tem limitações conhecidas, elas são registradas para tornar o código mais fácil de revisar no futuro.

## Conceitos praticados

- `SELECT`, `WHERE` e filtros;
- `INNER JOIN` e `LEFT JOIN`;
- `UPDATE ... FROM` e `MERGE`;
- `SUBSTRING`, `CHARINDEX`, `TRIM`, `CASE` e `CONCAT`;
- `NOT IN` e `NOT EXISTS`, incluindo o comportamento de `NULL`;
- variáveis, `IF`, `WHILE` e `DATEDIFF`;
- `SUM`, `COUNT`, `GROUP BY`, `ROW_NUMBER()` e análise temporal;
- transações com `ROLLBACK` para testar alterações.

## Como executar

- Use o SQL Server Management Studio ou o Azure Data Studio em uma instância de testes (a edição Developer ou Express é suficiente).
- `TRIM` exige SQL Server 2017 ou superior.
- Scripts que alteram dados (01, 02 e 05) terminam em `ROLLBACK` quando há transação: troque por `COMMIT` somente após conferir as pré-visualizações.
- Os arquivos usam codificação UTF-8. Se os acentos aparecerem incorretos, abra o arquivo escolhendo essa codificação.

## Próximas melhorias

- Adicionar um conjunto de dados de teste fictício para tornar os exemplos 01, 02, 05 e 07 executáveis sem a base do curso;
- documentar os resultados esperados com tabelas de saída;
- comparar planos de execução quando houver alternativas;
- criar projetos analíticos com perguntas de negócio e conclusões.

## Segurança e integridade dos dados

Os exemplos não devem conter CPF real, identificadores reais de clientes, credenciais ou detalhes internos de sistemas corporativos. Consultas de escrita (`UPDATE`, `MERGE`, `DELETE`) devem ser testadas em ambiente isolado e revisadas antes da execução.

---

*Material de estudo: evolui conforme novas consultas são praticadas e validadas.*
