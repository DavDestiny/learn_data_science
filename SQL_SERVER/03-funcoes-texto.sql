/*
OBJETIVO:
Praticar funções de texto para localizar separadores, extrair o primeiro nome,
filtrar descrições que começam com um texto específico e remover espaços
desnecessários.

FUNÇÕES PRATICADAS:
CHARINDEX (posição de um texto), SUBSTRING (trecho), LIKE (padrão de prefixo)
e TRIM (espaços no início e no fim).

REQUISITO:
TRIM está disponível a partir do SQL Server 2017. Em versões anteriores, use
LTRIM(RTRIM(texto)).

RESULTADO ESPERADO DA CONSULTA 1:
- NOME = 'Ana Souza'  -> POSIÇÃO DO ESPAÇO = 4 e PRIMEIRO NOME = 'Ana'.
- NOME = 'Madonna'    -> POSIÇÃO DO ESPAÇO = 0 e PRIMEIRO NOME = 'Madonna'.
*/

-- 1. Posição do primeiro espaço e extração do primeiro nome.
-- CASE evita um comprimento negativo quando NOME não contém espaço.
SELECT
    NOME,
    CHARINDEX(' ', NOME) AS [POSIÇÃO DO ESPAÇO],
    CASE
        WHEN CHARINDEX(' ', NOME) > 0
            THEN SUBSTRING(NOME, 1, CHARINDEX(' ', NOME) - 1)
        ELSE NOME
    END AS [PRIMEIRO NOME]
FROM TABELA_DE_CLIENTES;

-- 2. Localiza descrições cujo começo corresponde ao texto indicado.
-- 'Sabor dos Alpes' possui 15 caracteres.
SELECT *
FROM TABELA_DE_PRODUTOS
WHERE SUBSTRING(DESCRITOR, 1, 15) = 'Sabor dos Alpes';

-- Alternativa mais direta para filtrar por prefixo:
SELECT *
FROM TABELA_DE_PRODUTOS
WHERE DESCRITOR LIKE 'Sabor dos Alpes%';

/*
NOTA:
A comparação de texto pode depender da collation do banco (por exemplo,
sensibilidade a maiúsculas/minúsculas). Espaços iniciais também alteram
o resultado do filtro por prefixo.
*/

-- 3. TRIM: remove espaços do início e do fim do texto.
-- Exemplo autocontido: não depende de nenhuma tabela.
DECLARE @DESCRITOR VARCHAR(50) = '   Sabor dos Alpes  ';

SELECT
    @DESCRITOR                    AS TEXTO_ORIGINAL,
    DATALENGTH(@DESCRITOR)        AS BYTES_ORIGINAL,   -- 20 (3 + 15 + 2 espaços)
    TRIM(@DESCRITOR)              AS TEXTO_COM_TRIM,
    DATALENGTH(TRIM(@DESCRITOR))  AS BYTES_COM_TRIM;   -- 15

-- O espaço inicial impede a correspondência por prefixo sem o TRIM.
SELECT
    CASE WHEN @DESCRITOR LIKE 'Sabor dos Alpes%'
         THEN 'SIM' ELSE 'NÃO' END AS SEM_TRIM,        -- NÃO
    CASE WHEN TRIM(@DESCRITOR) LIKE 'Sabor dos Alpes%'
         THEN 'SIM' ELSE 'NÃO' END AS COM_TRIM;        -- SIM

/*
NOTA SOBRE TRIM EM FILTROS:
Aplicar TRIM (ou qualquer função) a uma coluna dentro do WHERE pode impedir o
uso eficiente de índices sobre essa coluna. Quando possível, corrija os
espaços na origem dos dados.
*/
