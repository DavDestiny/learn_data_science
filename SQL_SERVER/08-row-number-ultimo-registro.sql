/*
PROJETO DIDÁTICO: IDENTIFICAR O ÚLTIMO REGISTRO DE CADA CLIENTE

CENÁRIO FICTÍCIO:
Uma empresa fictícia de assinaturas guarda o histórico de status de cada
cliente. Queremos os clientes cujo registro mais recente seja
CANCELADO (status 2) e tenha sido registrado nos últimos sete dias.

STATUS: 1 = Ativa, 2 = Cancelada, 3 = Suspensa.

REGRA FUNDAMENTAL:
1. Numerar todos os registros de cada cliente, do mais recente ao mais antigo.
2. Selecionar a posição 1 de cada cliente.
3. Só depois filtrar o status e a data do registro mais recente.

Todos os dados abaixo são fictícios.

CONTEÚDO:
- Parte 1: ROW_NUMBER ordenado pela data.
- Parte 2: a armadilha das datas nulas e como ordenar por uma chave sequencial.
*/

------------------------------------------------------------------------
-- PARTE 1: ÚLTIMO REGISTRO POR DATA
------------------------------------------------------------------------

DECLARE @HistoricoAssinaturas TABLE
(
    CLIENTE_ID        INT NOT NULL,
    ID_REGISTRO       INT NOT NULL PRIMARY KEY,
    DATA_STATUS       DATETIME2(0) NOT NULL,
    STATUS_ASSINATURA TINYINT NOT NULL
);

-- Cliente 1001: cancelamento antigo, mas existe um registro ativo posterior.
-- Resultado esperado: NÃO retornar este cliente.
INSERT INTO @HistoricoAssinaturas
    (CLIENTE_ID, ID_REGISTRO, DATA_STATUS, STATUS_ASSINATURA)
VALUES
    (1001, 1, DATEADD(DAY, -3, SYSDATETIME()), 2),
    (1001, 2, DATEADD(DAY, -1, SYSDATETIME()), 1),

    -- Cliente 1002: registro mais recente cancelado dentro dos últimos sete dias.
    -- Resultado esperado: retornar este cliente.
    (1002, 3, DATEADD(DAY, -2, SYSDATETIME()), 2),

    -- Cliente 1003: último registro cancelado, mas fora dos últimos sete dias.
    -- Resultado esperado: NÃO retornar este cliente.
    (1003, 4, DATEADD(DAY, -10, SYSDATETIME()), 2),

    -- Cliente 1004: registro mais recente suspenso dentro do período.
    -- Resultado esperado: NÃO retornar este cliente.
    (1004, 5, DATEADD(DAY, -1, SYSDATETIME()), 3),
    (1004, 6, DATEADD(DAY, -4, SYSDATETIME()), 2);

;WITH RegistrosOrdenados AS
(
    SELECT
        CLIENTE_ID,
        ID_REGISTRO,
        DATA_STATUS,
        STATUS_ASSINATURA,
        ROW_NUMBER() OVER
        (
            PARTITION BY CLIENTE_ID
            ORDER BY DATA_STATUS DESC, ID_REGISTRO DESC
        ) AS RN
    FROM @HistoricoAssinaturas
)
SELECT
    CLIENTE_ID,
    ID_REGISTRO,
    DATA_STATUS,
    STATUS_ASSINATURA
FROM RegistrosOrdenados
WHERE RN = 1
  AND STATUS_ASSINATURA = 2
  AND DATA_STATUS >= DATEADD(DAY, -7, SYSDATETIME())
  AND DATA_STATUS <= SYSDATETIME()
ORDER BY CLIENTE_ID;

/*
RESULTADO ESPERADO DA PARTE 1:
Somente o cliente 1002 deve aparecer.

POR QUE OS FILTROS DE STATUS E DATA FICAM DEPOIS DE RN = 1?
Porque filtrar cancelados antes da numeração poderia fazer um cancelamento
antigo parecer o último, mesmo quando existe um registro posterior ativo,
suspenso ou com qualquer outro status.

CRITÉRIO DE DESEMPATE:
ID_REGISTRO é uma chave única fictícia usada para tornar a ordenação
determinística quando duas linhas têm a mesma data. Em uma base real, use uma
chave única adequada.
*/

------------------------------------------------------------------------
-- PARTE 2: A ARMADILHA DAS DATAS NULAS
------------------------------------------------------------------------
/*
No SQL Server, NULL é tratado como o menor valor possível na ordenação.
Com ORDER BY ... DESC, um registro sem data vai para o FIM da fila e nunca
recebe RN = 1 se o cliente tiver outro registro com data. Se o registro sem
data for justamente o mais novo (por exemplo, uma assinatura ativa que ainda
não teve a data de status preenchida), o cancelamento antigo passa a parecer
o último.

Solução: quando existir uma chave sequencial confiável (ID_REGISTRO cresce a
cada novo registro), use-a para definir qual é o último registro. A data fica
apenas para a condição "dentro dos últimos sete dias".
*/

DECLARE @HistoricoComDataNula TABLE
(
    CLIENTE_ID        INT NOT NULL,
    ID_REGISTRO       INT NOT NULL PRIMARY KEY,
    DATA_STATUS       DATETIME2(0) NULL,
    STATUS_ASSINATURA TINYINT NOT NULL
);

INSERT INTO @HistoricoComDataNula
    (CLIENTE_ID, ID_REGISTRO, DATA_STATUS, STATUS_ASSINATURA)
VALUES
    -- Cliente 2001: cancelou e depois contratou novamente (registro ativo sem data).
    -- Resultado esperado: NÃO retornar este cliente.
    (2001, 10, DATEADD(DAY, -3, SYSDATETIME()), 2),
    (2001, 11, NULL, 1),

    -- Cliente 2002: único registro, cancelado há dois dias.
    -- Resultado esperado: retornar este cliente.
    (2002, 12, DATEADD(DAY, -2, SYSDATETIME()), 2);

-- ERRADO: ordenar pela data coloca o registro sem data no fim da fila.
;WITH Ordenado AS
(
    SELECT
        CLIENTE_ID, ID_REGISTRO, DATA_STATUS, STATUS_ASSINATURA,
        ROW_NUMBER() OVER
        (
            PARTITION BY CLIENTE_ID
            ORDER BY DATA_STATUS DESC
        ) AS RN
    FROM @HistoricoComDataNula
)
SELECT CLIENTE_ID, ID_REGISTRO, DATA_STATUS, STATUS_ASSINATURA
FROM Ordenado
WHERE RN = 1
  AND STATUS_ASSINATURA = 2
  AND DATA_STATUS >= DATEADD(DAY, -7, SYSDATETIME())
ORDER BY CLIENTE_ID;      -- retorna 2001 e 2002 (2001 indevidamente)

-- CORRETO: a chave sequencial define o último registro.
;WITH Ordenado AS
(
    SELECT
        CLIENTE_ID, ID_REGISTRO, DATA_STATUS, STATUS_ASSINATURA,
        ROW_NUMBER() OVER
        (
            PARTITION BY CLIENTE_ID
            ORDER BY ID_REGISTRO DESC
        ) AS RN
    FROM @HistoricoComDataNula
)
SELECT CLIENTE_ID, ID_REGISTRO, DATA_STATUS, STATUS_ASSINATURA
FROM Ordenado
WHERE RN = 1
  AND STATUS_ASSINATURA = 2
  AND DATA_STATUS >= DATEADD(DAY, -7, SYSDATETIME())
ORDER BY CLIENTE_ID;      -- retorna somente 2002

/*
RESULTADO ESPERADO DA PARTE 2:
- Consulta errada: clientes 2001 e 2002.
- Consulta correta: somente o cliente 2002.

CUIDADO:
Usar uma chave sequencial como critério de recência só é correto se a regra de
negócio garantir que números maiores representam registros mais novos.
Confirme essa premissa antes de adotá-la.
*/
