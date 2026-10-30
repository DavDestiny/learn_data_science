/*
OBJETIVO:
Atualizar o preço de lista da tabela PRODUTOS com o preço correspondente
da tabela de origem SUCOS_FRUTAS..TABELA_DE_PRODUTOS.

REGRA:
Quando os códigos dos produtos coincidirem, o preço da tabela de destino
receberá o valor da tabela de origem.

CUIDADOS:
- A origem deve ter no máximo uma linha para cada código correspondente.
  Caso contrário, o SQL Server interrompe o MERGE com erro, pois mais de uma
  linha de origem tentaria atualizar a mesma linha de destino.
- Este exemplo só executa UPDATE para registros correspondentes; não insere
  produtos ausentes (não há cláusula WHEN NOT MATCHED).
- Todas as linhas correspondentes são regravadas, mesmo quando o preço já é
  igual. Para evitar isso, use WHEN MATCHED AND <condição de diferença>.
- A instrução MERGE precisa terminar com ponto e vírgula.
- Para uma atualização simples, compare também com UPDATE ... FROM (arquivo 01).
- Teste em uma base controlada antes de alterar dados.

RESULTADO ESPERADO:
A saída do OUTPUT mostra, para cada produto atualizado, o preço antes e
depois da operação.
*/

-- 1. Verificação: a origem não pode ter códigos duplicados (deve retornar zero linhas).
SELECT
    CODIGO_DO_PRODUTO,
    COUNT(*) AS QUANTIDADE
FROM SUCOS_FRUTAS..TABELA_DE_PRODUTOS
GROUP BY CODIGO_DO_PRODUTO
HAVING COUNT(*) > 1;

-- 2. Pré-visualização: preço atual e preço que seria gravado.
SELECT
    P.CODIGO,
    P.PRECO_LISTA     AS PRECO_ATUAL,
    B.PRECO_DE_LISTA  AS PRECO_NOVO
FROM PRODUTOS AS P
INNER JOIN SUCOS_FRUTAS..TABELA_DE_PRODUTOS AS B
    ON P.CODIGO = B.CODIGO_DO_PRODUTO;

-- 3. MERGE protegido por transação.
-- O ROLLBACK desfaz a alteração; troque por COMMIT somente após validar.
BEGIN TRANSACTION;

MERGE INTO PRODUTOS AS P
USING SUCOS_FRUTAS..TABELA_DE_PRODUTOS AS B
    ON P.CODIGO = B.CODIGO_DO_PRODUTO
WHEN MATCHED THEN
    UPDATE SET P.PRECO_LISTA = B.PRECO_DE_LISTA
OUTPUT
    $action               AS ACAO,
    inserted.CODIGO       AS CODIGO,
    deleted.PRECO_LISTA   AS PRECO_ANTES,
    inserted.PRECO_LISTA  AS PRECO_DEPOIS;

ROLLBACK TRANSACTION; -- COMMIT TRANSACTION apenas após validar
