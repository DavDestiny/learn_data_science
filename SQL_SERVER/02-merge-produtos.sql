/*
OBJETIVO:
Atualizar o preço de lista da tabela PRODUTOS com o preço correspondente
da tabela de origem SUCOS_FRUTAS..TABELA_DE_PRODUTOS.

REGRA:
Quando os códigos dos produtos coincidirem, o preço da tabela de destino
receberá o valor da tabela de origem.

CUIDADOS:
- A origem deve ter no máximo uma linha para cada código correspondente.
- Este exemplo só executa UPDATE para registros correspondentes; não insere
  produtos ausentes.
- Para uma atualização simples, compare também com UPDATE ... FROM.
- Teste em uma base controlada antes de alterar dados.
*/

MERGE INTO PRODUTOS AS P
USING SUCOS_FRUTAS..TABELA_DE_PRODUTOS AS B
    ON P.CODIGO = B.CODIGO_DO_PRODUTO
WHEN MATCHED THEN
    UPDATE SET P.PRECO_LISTA = B.PRECO_DE_LISTA;
