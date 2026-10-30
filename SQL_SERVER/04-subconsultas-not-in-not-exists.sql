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

/*
DEMONSTRAÇÃO COM DADOS FICTÍCIOS: POR QUE O NULL IMPORTA
Exemplo autocontido: usa variáveis de tabela e não depende de nenhuma base.

RESULTADO ESPERADO:
- Cenário 1 (origem sem NULL): NOT IN e NOT EXISTS retornam 'C3'.
- Cenário 2 (origem com NULL): NOT IN não retorna nenhuma linha;
  NOT EXISTS continua retornando 'C3'.

EXPLICAÇÃO:
'C3' NOT IN ('A1', 'B2', NULL) equivale a: <> 'A1' AND <> 'B2' AND <> NULL.
A comparação com NULL resulta em desconhecido, então a condição inteira não
é verdadeira e a linha é descartada.
*/

DECLARE @PRODUTOS TABLE (CODIGO VARCHAR(5) NOT NULL);
DECLARE @ORIGEM   TABLE (CODIGO_DO_PRODUTO VARCHAR(5) NULL);

INSERT INTO @PRODUTOS (CODIGO) VALUES ('A1'), ('B2'), ('C3');
INSERT INTO @ORIGEM (CODIGO_DO_PRODUTO) VALUES ('A1'), ('B2');

-- Cenário 1: origem sem NULL.
SELECT P.CODIGO AS NOT_IN_CENARIO_1
FROM @PRODUTOS AS P
WHERE P.CODIGO NOT IN (SELECT O.CODIGO_DO_PRODUTO FROM @ORIGEM AS O);

SELECT P.CODIGO AS NOT_EXISTS_CENARIO_1
FROM @PRODUTOS AS P
WHERE NOT EXISTS (SELECT 1 FROM @ORIGEM AS O WHERE O.CODIGO_DO_PRODUTO = P.CODIGO);

-- Cenário 2: a origem passa a conter um NULL.
INSERT INTO @ORIGEM (CODIGO_DO_PRODUTO) VALUES (NULL);

SELECT P.CODIGO AS NOT_IN_CENARIO_2          -- nenhuma linha
FROM @PRODUTOS AS P
WHERE P.CODIGO NOT IN (SELECT O.CODIGO_DO_PRODUTO FROM @ORIGEM AS O);

SELECT P.CODIGO AS NOT_EXISTS_CENARIO_2      -- 'C3'
FROM @PRODUTOS AS P
WHERE NOT EXISTS (SELECT 1 FROM @ORIGEM AS O WHERE O.CODIGO_DO_PRODUTO = P.CODIGO);
