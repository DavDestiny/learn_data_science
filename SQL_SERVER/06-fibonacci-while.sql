/*
OBJETIVO:
Gerar as primeiras 44 posições da sequência de Fibonacci.

REGRA:
A posição seguinte é calculada pela soma dos dois valores anteriores.

OBSERVAÇÃO:
BIGINT permite armazenar valores maiores que INT, mas também possui limite.
Este exemplo termina na posição 44 para manter o escopo didático.
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
