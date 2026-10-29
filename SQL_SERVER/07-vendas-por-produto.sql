/*
OBJETIVO:
Calcular o valor total vendido por produto em janeiro de 2015.

ABORDAGEM:
Em vez de executar uma consulta por produto usando WHILE, esta versão agrega os registros em conjunto com JOIN, SUM e GROUP BY.

PREMISSA:
ITENS_NOTAS_FISCAIS contém a quantidade, o preço e o número da nota; NOTAS_FISCAIS contém a data da venda; TABELA_DE_PRODUTOS contém o nome e o código dos produtos.
*/

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
LEITURA:
1. Relaciona produto, itens de notas fiscais e notas fiscais.
2. Seleciona as vendas de janeiro de 2015 usando intervalo semiaberto.
3. Multiplica quantidade por preço e soma os valores por produto.
4. Ordena do maior para o menor total vendido.

NOTA:
O INNER JOIN retorna apenas produtos com vendas no período. Para incluir produtos sem vendas, avalie LEFT JOIN e o tratamento de valores NULL.
Ajuste os nomes das tabelas e colunas caso a estrutura da sua base seja diferente.
*/