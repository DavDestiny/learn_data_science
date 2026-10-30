/*
OBJETIVO:
Comparar a idade armazenada de um cliente com a idade calculada a partir
da data de nascimento e atualizar o registro apenas se houver divergência.

REGRA DE NEGÓCIO:
A idade é medida em aniversários completos. DATEDIFF(YEAR, ...) sozinho conta
viradas de ano, então o cálculo subtrai 1 quando o aniversário deste ano
ainda não ocorreu.

EXEMPLOS DO CÁLCULO (referência: 29/10/2026):
- Nascimento em 10/05/2000 -> 26 anos (aniversário já ocorreu).
- Nascimento em 31/12/2000 -> 25 anos (aniversário ainda não ocorreu).

CUIDADOS:
- Troque o identificador de teste por um valor fictício existente em sua base
  de treinamento. Não publique CPF real nem execute sem validar o registro alvo.
- O código pressupõe que o CPF identifica um único cliente. Se houver
  duplicidade, as variáveis recebem os valores da última linha lida e o UPDATE
  altera todas as linhas com esse CPF.
- Para quem nasceu em 29/02, o aniversário em anos não bissextos é tratado
  como 28/02 (comportamento do DATEADD).
- A idade armazenada é um dado derivado que fica desatualizado com o tempo;
  em um projeto real, considere calculá-la na consulta em vez de armazená-la.
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

    -- Pré-visualização: confira os valores antes de qualquer alteração.
    SELECT
        @CPF              AS CPF,
        @DATA_NASCIMENTO  AS DATA_NASCIMENTO,
        @IDADE_TABELA     AS IDADE_ARMAZENADA,
        @IDADE_CALCULADA  AS IDADE_CALCULADA;

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
