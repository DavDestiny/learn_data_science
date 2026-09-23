"""
Script para mover arquivos de ex-funcionários automaticamente.

Cenário (Ativos):
- Pasta CTPS: já corrigida, é a referência. Arquivos tipo "Ana Beatriz - CTPS.pdf".
- Pasta RG: tem arquivos de todo mundo, tipo "Ana Beatriz - RG.pdf".
- Dentro da pasta RG existe a subpasta "ex funcionario", que é o destino.

Lógica:
1. Lê os nomes de arquivos da pasta CTPS (referência = quem é ativo).
2. Lê os arquivos da pasta RG (mistura de ativos e ex-funcionários).
3. Qualquer arquivo da RG cuja PESSOA não apareça na pasta CTPS é considerado
   ex-funcionário e é movido para a subpasta "ex funcionario".

Por que normalizar os nomes:
    Arquivos podem ter pequenas diferenças (maiúsculas/minúsculas, acentos,
    espaços, hífens, extensão .pdf/.jpg/.png) e também sufixos diferentes de
    tipo de documento ("- CTPS" numa pasta, "- RG" na outra). Para comparar
    pela PESSOA e não pelo nome do arquivo inteiro, removemos esse sufixo e
    normalizamos os dois lados antes de comparar (veja SUFIXOS_DOCUMENTO).
"""

import difflib
import os
import re
import shutil
import unicodedata
from pathlib import Path

# Sufixos de tipo de documento que aparecem no final do nome do arquivo
# (ex: "Ana Beatriz - CTPS.pdf", "Ana Beatriz - RG.pdf").
# Adicione aqui outros tipos que aparecerem (CNH, COMPROVANTE, etc.) —
# sem isso, o script compararia "ana beatriz ctps" com "ana beatriz rg"
# e nunca acharia que são a mesma pessoa.
SUFIXOS_DOCUMENTO = ["CTPS", "CTPS 2", "CTPS 3", "TERMO 2", "RG", "RG 2", "TERMO", "CNH", "RG E CPF", "CPF E RG", "RG E TERMO", "CONTRATO ESTAGIO", "DOCUMENTO", "E-SOCIAL"]

# Se um arquivo "não bater" com nenhum ativo, mas existir um nome nos ativos
# com semelhança igual ou maior que este valor (0 a 1), o script avisa —
# geralmente indica erro de digitação/formatação, não um ex-funcionário de verdade.
LIMIAR_AVISO_SIMILARIDADE = 0.75


def _construir_padrao_sufixos() -> str:
    """
    Monta o trecho de regex com todos os SUFIXOS_DOCUMENTO como alternativas,
    permitindo espaçamento irregular entre palavras (ex: "RG E CPF" também
    bate com "RG  E   CPF") e escapando qualquer caractere especial de regex.
    """
    alternativas = []
    for sufixo in SUFIXOS_DOCUMENTO:
        palavras = sufixo.split()
        alternativas.append(r"\s+".join(re.escape(palavra) for palavra in palavras))
    return "|".join(alternativas)


def remover_marcador_duplicata(nome: str) -> str:
    """
    Remove o marcador de arquivo duplicado que o Windows adiciona sozinho
    quando você copia um arquivo pra mesma pasta, ex:
    "Ana Beatriz - TERMO (2)" -> "Ana Beatriz - TERMO"

    Precisa rodar ANTES de remover o sufixo de documento, porque o "(2)"
    fica depois do sufixo (mais perto da extensão).
    """
    return re.sub(r"\s*\(\d+\)\s*$", "", nome)


def remover_sufixo_documento(nome_sem_extensao: str) -> str:
    """
    Remove o sufixo de tipo de documento do final do nome, ex:
    "Ana Beatriz - CTPS" -> "Ana Beatriz"
    "Ana Beatriz – RG"   -> "Ana Beatriz"
    Isso é o que permite comparar um arquivo da pasta CTPS com um da pasta RG
    e reconhecer que são da mesma pessoa.

    Aceita como separador: hífen comum "-", travessão "–"/"—" (o Windows/Word
    às vezes substitui o hífen digitado por um travessão automaticamente —
    visualmente quase idêntico, mas é outro caractere) e underline "_".
    """
    separador = r"[\s\-\u2010-\u2015_]+"  # espaço, hífen, travessão (vários tipos) ou underline
    padrao = separador + r"(" + _construir_padrao_sufixos() + r")\s*$"
    return re.sub(padrao, "", nome_sem_extensao, flags=re.IGNORECASE)


def normalizar_nome(nome_arquivo: str) -> str:
    """
    Remove extensão, sufixo de documento (CTPS/RG/...), acentos e caracteres
    especiais do nome do arquivo, e deixa tudo em minúsculo — assim
    "Ana Beatriz - CTPS.pdf" e "ana_beatriz_-_rg.PDF" são considerados o
    mesmo nome na comparação.
    """
    nome_sem_extensao = Path(nome_arquivo).stem
    nome_sem_duplicata = remover_marcador_duplicata(nome_sem_extensao)
    nome_sem_sufixo = remover_sufixo_documento(nome_sem_duplicata)
    # remove acentos (á, ã, ç, etc.), já que eles costumam ser a maior fonte
    # de "diferença falsa" entre nomes que na real são a mesma pessoa
    nome_sem_acento = unicodedata.normalize("NFKD", nome_sem_sufixo)
    nome_sem_acento = nome_sem_acento.encode("ASCII", "ignore").decode("ASCII")
    # mantém só letras e números, removendo espaços, hífens, underlines etc.
    nome_limpo = re.sub(r"[^a-zA-Z0-9]", "", nome_sem_acento)
    return nome_limpo.lower().strip()


def listar_nomes_normalizados(pasta: str) -> set[str]:
    """Retorna o conjunto de nomes normalizados de todos os arquivos de uma pasta."""
    if not os.path.isdir(pasta):
        raise FileNotFoundError(f"Pasta não encontrada: {pasta}")

    return {
        normalizar_nome(arquivo)
        for arquivo in os.listdir(pasta)
        if os.path.isfile(os.path.join(pasta, arquivo))
    }


def encontrar_nome_mais_proximo(nome_normalizado: str, nomes_ativos: set[str]) -> tuple[str, float]:
    """
    Procura, dentro de `nomes_ativos`, o nome mais parecido com `nome_normalizado`
    e retorna (nome_encontrado, grau_de_semelhança de 0 a 1).

    Serve para diagnosticar falso positivo: se um arquivo "não bateu" com
    nenhum ativo, mas existe um nome muito parecido (ex: 90% de semelhança),
    é bem provável que seja a MESMA pessoa com o nome digitado de forma
    levemente diferente — não um ex-funcionário de verdade.
    """
    candidatos = difflib.get_close_matches(nome_normalizado, nomes_ativos, n=1, cutoff=0.0)
    if not candidatos:
        return "", 0.0
    mais_proximo = candidatos[0]
    semelhanca = difflib.SequenceMatcher(None, nome_normalizado, mais_proximo).ratio()
    return mais_proximo, semelhanca


def mover_ex_funcionarios(
    pasta_ativos: str,
    pasta_origem: str,
    pasta_destino: str,
    simular: bool = True,
) -> list[str]:
    """
    Move para `pasta_destino` todo arquivo de `pasta_origem` cujo nome
    normalizado NÃO existir em `pasta_ativos`.

    simular=True  -> só mostra o que SERIA movido, sem mexer em nada (padrão,
                      pra você conferir a lista antes de rodar de verdade)
    simular=False -> move os arquivos de fato
    """
    nomes_ativos = listar_nomes_normalizados(pasta_ativos)
    os.makedirs(pasta_destino, exist_ok=True)

    movidos: list[str] = []

    for arquivo in os.listdir(pasta_origem):
        caminho_origem = os.path.join(pasta_origem, arquivo)
        if not os.path.isfile(caminho_origem):
            continue  # ignora subpastas

        nome_norm = normalizar_nome(arquivo)
        if nome_norm not in nomes_ativos:
            movidos.append(arquivo)

            # Verifica se existe um nome muito parecido nos ativos — se sim,
            # provavelmente é a mesma pessoa com o nome escrito de forma diferente
            mais_proximo, semelhanca = encontrar_nome_mais_proximo(nome_norm, nomes_ativos)
            aviso = ""
            if semelhanca >= LIMIAR_AVISO_SIMILARIDADE:
                aviso = (
                    f"  ⚠️ ATENÇÃO: parecido com um ativo cadastrado como "
                    f"'{mais_proximo}' ({semelhanca:.0%} de semelhança) — "
                    f"confira se não é a mesma pessoa antes de mover!"
                )

            if simular:
                print(f"[SIMULAÇÃO] moveria: {arquivo}{aviso}")
            else:
                caminho_destino = os.path.join(pasta_destino, arquivo)
                shutil.move(caminho_origem, caminho_destino)
                print(f"movido: {arquivo}{aviso}")

    acao = "seriam movidos" if simular else "foram movidos"
    print(f"\nTotal de arquivos que {acao}: {len(movidos)}")
    return movidos


def processar_todas_movimentacoes(
    pasta_ativos: str,
    movimentacoes: list[dict[str, str]],
    simular: bool = True,
) -> None:
    """
    Roda `mover_ex_funcionarios` para uma lista de pastas de uma vez só,
    sempre usando a mesma `pasta_ativos` como referência.

    `movimentacoes` é uma lista de dicionários no formato:
        {"origem": "caminho da pasta a organizar", "destino": "caminho da pasta ex funcionario"}

    Assim você adiciona quantas pastas quiser na lista (RG, TERMO, CNH...)
    sem precisar editar código ou rodar o script várias vezes.
    """
    for movimentacao in movimentacoes:
        origem = movimentacao["origem"]
        destino = movimentacao["destino"]
        print(f"\n=== Processando: {origem} ===")
        mover_ex_funcionarios(
            pasta_ativos=pasta_ativos,
            pasta_origem=origem,
            pasta_destino=destino,
            simular=simular,
        )


if __name__ == "__main__":
    # ---------- AJUSTE AQUI ----------
    PASTA_ATIVOS = r"K:"  # referência (já corrigida) — usada em todas as movimentações

    # Adicione aqui uma linha pra cada pasta que precisa organizar.
    # Não precisa mexer em mais nada — só ir acrescentando itens nesta lista.
    MOVIMENTACOES = [
        {
            "origem": r"K:",
            "destino": r"K:",
        },
        {
            "origem": r"K:",
            "destino": r"K:",
        },
        # {
        #     "origem": r"C:\caminho\para\OUTRA_PASTA",
        #     "destino": r"C:\caminho\para\OUTRA_PASTA\ex funcionario",
        # },
    ]

    # IMPORTANTE: rode primeiro com SIMULAR = True pra conferir a lista
    # de todas as pastas antes de mover os arquivos de verdade
    SIMULAR = True

    processar_todas_movimentacoes(
        pasta_ativos=PASTA_ATIVOS,
        movimentacoes=MOVIMENTACOES,
        simular=SIMULAR,
    )