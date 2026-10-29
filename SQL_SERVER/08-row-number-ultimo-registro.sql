/*
PROJETO DIDÁTICO: IDENTIFICAR O ÚLTIMO REGISTRO POR DATA

OBJETIVO:
Demonstrar como retornar somente entidades cujo registro mais recente esteja
com status 2 (Cancelado) e tenha sido registrado nos últimos sete dias.

REGRA FUNDAMENTAL:
1. Numerar todos os registros de cada NDG pela data, do mais recente ao mais antigo.
2. Selecionar a posição 1 de cada NDG.
3. Só depois filtrar a data e o status do registro mais recente.

Os dados abaixo são fictícios e não representam dados corporativos.
*/

DECLARE @HistoricoAcordos TABLE
(
    NDG INT NOT NULL,
    ID_REGISTRO INT NOT NULL PRIMARY KEY,
    DATA_STATUS_CUMPRIMENTO DATETIME2(0) NOT NULL,
    STATUS_CUMPRIMENTO TINYINT NOT NULL
);

-- NDG 1001: cancelado antigo, mas existe um registro vigente posterior.
-- Resultado esperado: NÃO retornar este NDG.
INSERT INTO @HistoricoAcordos
    (NDG, ID_REGISTRO, DATA_STATUS_CUMPRIMENTO, STATUS_CUMPRIMENTO)
VALUES
    (1001, 1, DATEADD(DAY, -3, SYSDATETIME()), 2),
    (1001, 2, DATEADD(DAY, -1, SYSDATETIME()), 0),

    -- NDG 1002: registro mais recente cancelado dentro dos últimos sete dias.
    -- Resultado esperado: retornar este NDG.
    (1002, 3, DATEADD(DAY, -2, SYSDATETIME()), 2),

    -- NDG 1003: último registro cancelado, mas fora dos últimos sete dias.
    -- Resultado esperado: NÃO retornar este NDG.
    (1003, 4, DATEADD(DAY, -10, SYSDATETIME()), 2),

    -- NDG 1004: registro mais recente rejeitado dentro do período.
    -- Resultado esperado: NÃO retornar este NDG.
    (1004, 5, DATEADD(DAY, -1, SYSDATETIME()), 3),
    (1004, 6, DATEADD(DAY, -4, SYSDATETIME()), 2);

;WITH RegistrosOrdenados AS
(
    SELECT
        NDG,
        ID_REGISTRO,
        DATA_STATUS_CUMPRIMENTO,
        STATUS_CUMPRIMENTO,
        ROW_NUMBER() OVER
        (
            PARTITION BY NDG
            ORDER BY DATA_STATUS_CUMPRIMENTO DESC, ID_REGISTRO DESC
        ) AS RN
    FROM @HistoricoAcordos
)
SELECT
    NDG,
    ID_REGISTRO,
    DATA_STATUS_CUMPRIMENTO,
    STATUS_CUMPRIMENTO
FROM RegistrosOrdenados
WHERE RN = 1
  AND STATUS_CUMPRIMENTO = 2
  AND DATA_STATUS_CUMPRIMENTO >= DATEADD(DAY, -7, SYSDATETIME())
  AND DATA_STATUS_CUMPRIMENTO <= SYSDATETIME()
ORDER BY NDG;

/*
RESULTADO ESPERADO:
Somente o NDG 1002 deve aparecer.

POR QUE OS FILTROS DE STATUS E DATA FICAM DEPOIS DE RN = 1?
Porque filtrar cancelados antes da numeração poderia fazer um cancelamento antigo
parecer o último, mesmo quando existe um registro posterior vigente, rejeitado,
cumprido ou com qualquer outro status.

CRITÉRIO DE DESEMPATE:
ID_REGISTRO é uma chave única fictícia usada para tornar a ordenação determinística
quando duas linhas têm a mesma data. Em uma base real, use uma chave única adequada.
*/