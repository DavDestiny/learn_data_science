/*
OBJETIVO:
Aumentar VOLUME_COMPRA em 30% para clientes cujo bairro aparece
na tabela de vendedores.

LÓGICA:
O INNER JOIN relaciona CLIENTES e TABELA_DE_VENDEDORES pelo bairro.
Somente clientes com correspondência na tabela de vendedores são afetados.

REGRA DE NEGÓCIO:
O aumento vale para todo cliente que está em um bairro atendido por pelo
menos um vendedor.

CUIDADOS:
- Execute apenas em ambiente de teste.
- A consulta aumenta o valor atual em 30%; executá-la novamente aplica
  outro aumento sobre o valor já alterado (a operação não é idempotente).
- Se houver mais de um vendedor no mesmo bairro, o cliente aparece mais de
  uma vez no SELECT de pré-visualização, mas o UPDATE altera a linha do
  cliente uma única vez. Por isso o SELECT pode retornar mais linhas do que
  o número de clientes realmente atualizados (use a contagem com EXISTS).
- Confirme se a regra de negócio realmente deve ser baseada no bairro.

RESULTADO ESPERADO DA PRÉ-VISUALIZAÇÃO:
Uma linha por combinação cliente-vendedor, em que VOLUME_APOS_AUMENTO é
igual a VOLUME_ATUAL multiplicado por 1,30.
*/

-- 1. Pré-visualização dos clientes que correspondem ao critério:
SELECT
    C.CODIGO,
    C.NOME,
    C.BAIRRO,
    C.VOLUME_COMPRA AS VOLUME_ATUAL,
    C.VOLUME_COMPRA * 1.30 AS VOLUME_APOS_AUMENTO
FROM CLIENTES AS C
INNER JOIN SUCOS_FRUTAS..TABELA_DE_VENDEDORES AS V
    ON C.BAIRRO = V.BAIRRO;

-- 2. Quantidade de clientes distintos que seriam atualizados.
SELECT COUNT(*) AS CLIENTES_AFETADOS
FROM CLIENTES AS C
WHERE EXISTS
(
    SELECT 1
    FROM SUCOS_FRUTAS..TABELA_DE_VENDEDORES AS V
    WHERE V.BAIRRO = C.BAIRRO
);

-- 3. Atualização de exemplo, protegida por transação.
-- O ROLLBACK desfaz a alteração; troque por COMMIT somente depois de
-- conferir as contagens acima em um ambiente de teste.
BEGIN TRANSACTION;

UPDATE C
SET C.VOLUME_COMPRA = C.VOLUME_COMPRA * 1.30
FROM CLIENTES AS C
INNER JOIN SUCOS_FRUTAS..TABELA_DE_VENDEDORES AS V
    ON C.BAIRRO = V.BAIRRO;

SELECT @@ROWCOUNT AS LINHAS_ATUALIZADAS; -- deve coincidir com CLIENTES_AFETADOS

ROLLBACK TRANSACTION; -- COMMIT TRANSACTION apenas após validar
