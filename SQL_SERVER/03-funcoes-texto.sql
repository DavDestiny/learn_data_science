/*
OBJETIVO:
Praticar funções de texto para localizar separadores, extrair o primeiro nome
e filtrar descrições que começam com um texto específico.
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
