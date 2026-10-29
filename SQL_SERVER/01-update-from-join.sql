/*
OBJETIVO:
Aumentar VOLUME_COMPRA em 30% para clientes cujo bairro aparece
na tabela de vendedores.

LÓGICA:
O INNER JOIN relaciona CLIENTES e TABELA_DE_VENDEDORES pelo bairro.
Somente clientes com correspondência na tabela de vendedores são afetados.

ATENÇÃO:
- Execute apenas em ambiente de teste.
- A consulta aumenta o valor atual em 30%; executá-la novamente aplica
  outro aumento sobre o valor já alterado.
- Confirme se a regra de negócio realmente deve ser baseada no bairro.
*/

-- Pré-visualização dos clientes que correspondem ao critério:
SELECT
    C.CODIGO,
    C.NOME,
    C.BAIRRO,
    C.VOLUME_COMPRA AS VOLUME_ATUAL,
    C.VOLUME_COMPRA * 1.30 AS VOLUME_APOS_AUMENTO
FROM CLIENTES AS C
INNER JOIN SUCOS_FRUTAS..TABELA_DE_VENDEDORES AS V
    ON C.BAIRRO = V.BAIRRO;

-- Atualização de exemplo: executar somente após validar o SELECT acima.
UPDATE C
SET C.VOLUME_COMPRA = C.VOLUME_COMPRA * 1.30
FROM CLIENTES AS C
INNER JOIN SUCOS_FRUTAS..TABELA_DE_VENDEDORES AS V
    ON C.BAIRRO = V.BAIRRO;
