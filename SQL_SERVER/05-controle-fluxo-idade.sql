/*
OBJETIVO:
Comparar a idade armazenada de um cliente com a idade calculada a partir
da data de nascimento e atualizar o registro apenas se houver divergência.

IMPORTANTE:
Troque o identificador de teste por um valor fictício existente em sua base
de treinamento. Não publique CPF real nem execute sem validar o registro alvo.
*/

DECLARE @CPF VARCHAR(11);
DECLARE @DATA_NASCIMENTO DATE;
DECLARE @IDADE_TABELA INT;
DECLARE @IDADE_CALCULADA INT;

SET @CPF = 'CPF_TESTE';

SELECT
    @DATA_NASCIMENTO = DATA_DE_NASCIMENTO,
    @IDADE_TABELA = IDADE
FROM TABELA_DE_CLIENTES
WHERE CPF = @CPF;

IF @DATA_NASCIMENTO IS NULL
BEGIN
    PRINT 'Cliente não encontrado ou sem data de nascimento.';
END
ELSE
BEGIN
    -- DATEDIFF(YEAR) sozinho conta viradas de ano, não aniversários completos.
    SET @IDADE_CALCULADA =
        DATEDIFF(YEAR, @DATA_NASCIMENTO, GETDATE())
        - CASE
            WHEN DATEADD(
                    YEAR,
                    DATEDIFF(YEAR, @DATA_NASCIMENTO, GETDATE()),
                    @DATA_NASCIMENTO
                 ) > CAST(GETDATE() AS DATE)
                THEN 1
            ELSE 0
          END;

    IF @IDADE_TABELA IS NULL OR @IDADE_TABELA <> @IDADE_CALCULADA
    BEGIN
        UPDATE TABELA_DE_CLIENTES
        SET IDADE = @IDADE_CALCULADA
        WHERE CPF = @CPF;

        PRINT 'A idade armazenada foi atualizada.';
    END
    ELSE
    BEGIN
        PRINT 'A idade armazenada já está consistente.';
    END
END;
