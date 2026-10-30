/*
OBJETIVO:
Gerar as primeiras 44 posições da sequência de Fibonacci.

REGRA:
A posição seguinte é calculada pela soma dos dois valores anteriores.
A posição 1 vale 0 e a posição 2 vale 1.

LIMITES DOS TIPOS NUMÉRICOS:
- INT (máximo 2.147.483.647) comporta a sequência até a posição 47.
- BIGINT (máximo 9.223.372.036.854.775.807) comporta até a posição 93;
  a posição 94 provocaria erro de estouro aritmético.
Este exemplo termina na posição 44 para manter o escopo didático.

RESULTADO ESPERADO:
As duas primeiras linhas são "POSIÇÃO 1 --> 0" e "POSIÇÃO 2 --> 1".
A última linha é "POSIÇÃO 44 --> 433494437".
*/

DECLARE @NUMERO_ANTERIOR2 BIGINT = 0;
DECLARE @NUMERO_ANTERIOR1 BIGINT = 1;
DECLARE @NUMERO_ATUAL BIGINT;
DECLARE @POSICAO INT = 3;
DECLARE @LIMITE INT = 44;

PRINT 'POSIÇÃO 1 --> 0';
PRINT 'POSIÇÃO 2 --> 1';

WHILE @POSICAO <= @LIMITE
BEGIN
    SET @NUMERO_ATUAL = @NUMERO_ANTERIOR2 + @NUMERO_ANTERIOR1;

    PRINT CONCAT(
        'POSIÇÃO ',
        @POSICAO,
        ' --> ',
        @NUMERO_ATUAL
    );

    SET @NUMERO_ANTERIOR2 = @NUMERO_ANTERIOR1;
    SET @NUMERO_ANTERIOR1 = @NUMERO_ATUAL;
    SET @POSICAO = @POSICAO + 1;
END;
