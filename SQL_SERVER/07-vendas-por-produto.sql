/*
OBJETIVO:
Calcular o valor total vendido por produto em janeiro de 2015.

ABORDAGEM:
Em vez de executar uma consulta por produto usando WHILE, esta versão agrega
os registros em conjunto com JOIN, SUM e GROUP BY.

PREMISSA:
- ITENS_NOTAS_FISCAIS contém a quantidade, o preço e o número da nota.
- NOTAS_FISCAIS contém a data da venda.
- TABELA_DE_PRODUTOS contém o nome e o código dos produtos.

RESULTADO ESPERADO:
- Versão 1: uma linha por produto com vendas no período, ordenada do maior
  para o menor TOTAL_VENDAS.
- Versão 2: uma linha por produto cadastrado; produtos sem vendas no período
  aparecem com QTD_NOTAS = 0 e TOTAL_VENDAS = 0.
*/

-- VERSÃO 1: INNER JOIN (somente produtos com vendas no período).
SELECT
    TP.CODIGO_DO_PRODUTO,
    TP.NOME_DO_PRODUTO,
    SUM(INF.QUANTIDADE * INF.PRECO) AS TOTAL_VENDAS
FROM TABELA_DE_PRODUTOS AS TP
INNER JOIN ITENS_NOTAS_FISCAIS AS INF
    ON TP.CODIGO_DO_PRODUTO = INF.CODIGO_DO_PRODUTO
INNER JOIN NOTAS_FISCAIS AS NF
    ON NF.NUMERO = INF.NUMERO
WHERE NF.DATA_VENDA >= '20150101'
  AND NF.DATA_VENDA <  '20150201'
GROUP BY
    TP.CODIGO_DO_PRODUTO,
    TP.NOME_DO_PRODUTO
ORDER BY
    TOTAL_VENDAS DESC;

/*
LEITURA DA VERSÃO 1:
1. Relaciona produto, itens de notas fiscais e notas fiscais.
2. Seleciona as vendas de janeiro de 2015 usando intervalo semiaberto.
3. Multiplica quantidade por preço e soma os valores por produto.
4. Ordena do maior para o menor total vendido.
*/

-- VERSÃO 2: LEFT JOIN + COUNT (inclui produtos sem vendas no período).
-- O filtro de período fica DENTRO da subconsulta. Se ele fosse colocado no
-- WHERE depois do LEFT JOIN, as linhas sem venda (datas NULL) seriam
-- descartadas e o LEFT JOIN passaria a se comportar como um INNER JOIN.
SELECT
    TP.CODIGO_DO_PRODUTO,
    TP.NOME_DO_PRODUTO,
    COUNT(DISTINCT V.NUMERO)                  AS QTD_NOTAS,
    COALESCE(SUM(V.QUANTIDADE * V.PRECO), 0)  AS TOTAL_VENDAS
FROM TABELA_DE_PRODUTOS AS TP
LEFT JOIN
(
    SELECT
        INF.CODIGO_DO_PRODUTO,
        INF.NUMERO,
        INF.QUANTIDADE,
        INF.PRECO
    FROM ITENS_NOTAS_FISCAIS AS INF
    INNER JOIN NOTAS_FISCAIS AS NF
        ON NF.NUMERO = INF.NUMERO
    WHERE NF.DATA_VENDA >= '20150101'
      AND NF.DATA_VENDA <  '20150201'
) AS V
    ON V.CODIGO_DO_PRODUTO = TP.CODIGO_DO_PRODUTO
GROUP BY
    TP.CODIGO_DO_PRODUTO,
    TP.NOME_DO_PRODUTO
ORDER BY
    TOTAL_VENDAS DESC;

/*
NOTA:
COUNT(DISTINCT V.NUMERO) ignora os NULL gerados pelo LEFT JOIN, por isso
produtos sem vendas retornam 0. Ajuste os nomes das tabelas e colunas caso a
estrutura da sua base seja diferente.
*/
