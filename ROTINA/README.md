# Rotinas em Python

Scripts de automação desenvolvidos durante os estudos. Os exemplos usam cenários e nomes fictícios.

## Mover arquivos de colaboradores desligados — `MOVER MULTIPLAS PASTAS.py`

Organiza arquivos de colaboradores desligados: compara os nomes de uma pasta de **referência** (somente pessoas ativas) com os de uma ou mais pastas de **origem** e move para uma subpasta de destino os arquivos cuja pessoa **não** aparece na referência.

### Como a comparação funciona

1. Remove extensão, marcador de duplicata do Windows (`(2)`) e sufixo do tipo de documento (`- CTPS`, `- RG`, ...).
2. Remove acentos, espaços e pontuação e converte para minúsculas.
3. Compara os nomes resultantes. Quando um arquivo não bate, o script procura o nome ativo mais parecido e emite um aviso se a semelhança for alta (provável erro de digitação).

### Como usar

1. Requer **Python 3.9 ou superior** e apenas a biblioteca padrão.
2. Edite a seção `AJUSTE AQUI` no final do arquivo: pasta de referência e lista de movimentações (`origem` e `destino`).
3. Execute com `SIMULAR = True` (padrão) e confira a lista exibida. Nesse modo nada é movido e nenhuma pasta é criada.
4. Altere para `SIMULAR = False` somente depois de validar a lista.

### Cuidados

- Se o arquivo já existir no destino, ele **não** é sobrescrito: aparece como `[IGNORADO]` no resultado.
- Nomes de pessoas diferentes que fiquem iguais após a normalização serão tratados como a mesma pessoa.
- Acrescente novos tipos de documento à lista `SUFIXOS_DOCUMENTO` quando aparecerem.
- Não publique caminhos reais, nomes reais de pessoas ou documentos pessoais neste repositório.
