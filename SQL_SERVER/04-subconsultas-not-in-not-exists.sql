/*
OBJETIVO:
Encontrar produtos da tabela PRODUTOS que não possuem correspondência
na tabela SUCOS_FRUTAS..TABELA_DE_PRODUTOS.
*/

-- Forma estudada: NOT IN.
-- ATENÇÃO: se a subconsulta retornar NULL, NOT IN pode não produzir
-- o resultado esperado.
SELECT P.*
FROM PRODUTOS AS P
WHERE P.CODIGO NOT IN
(
    SELECT B.CODIGO_DO_PRODUTO
    FROM SUCOS_FRUTAS..TABELA_DE_PRODUTOS AS B
);

-- Alternativa: NOT EXISTS.
-- Verifica se não existe linha de origem com o mesmo código.
SELECT P.*
FROM PRODUTOS AS P
WHERE NOT EXISTS
(
    SELECT 1
    FROM SUCOS_FRUTAS..TABELA_DE_PRODUTOS AS B
    WHERE B.CODIGO_DO_PRODUTO = P.CODIGO
);

/*
LEITURA:
Ambas buscam produtos sem correspondência na tabela de origem.
NOT EXISTS evita a armadilha típica de NULL no conjunto retornado pelo
NOT IN. O desempenho deve ser validado com dados, índices e plano de execução.
*/
