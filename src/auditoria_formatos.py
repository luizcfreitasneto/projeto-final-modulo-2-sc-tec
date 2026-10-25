
from pathlib import Path
import pandas as pd
import re

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data" / "raw"

arquivos = ["compras.csv", "itens.csv", "resultados.csv"]

for arquivo in arquivos:
    caminho = DATA_DIR / arquivo

    df = pd.read_csv(
        caminho,
        sep=",",
        encoding="utf-8-sig",
        dtype=str
    )

    colunas_monetarias = [
        coluna for coluna in df.columns
        if "valor_" in coluna
    ]

    print(f"\n{'=' * 50}")
    print(f"ARQUIVO: {arquivo}")
    print("=" * 50)

    for coluna in colunas_monetarias:
        print(f"\nCOLUNA: {coluna}")

        valores = df[coluna].dropna().astype(str).str.strip()

        contagem = {
            "Com R$": 0,
            "Com ponto e vírgula decimal": 0,
            "Com vírgula e ponto": 0,
            "Apenas ponto": 0,
            "Apenas vírgula": 0,
            "Sem separador": 0
        }

        for valor in valores:
            if "R$" in valor:
                contagem["Com R$"] += 1

            if "." in valor and "," in valor:
                contagem["Com vírgula e ponto"] += 1
            elif "." in valor:
                contagem["Apenas ponto"] += 1
            elif "," in valor:
                contagem["Apenas vírgula"] += 1
            else:
                contagem["Sem separador"] += 1

        for categoria, quantidade in contagem.items():
            print(f"{categoria}: {quantidade}")



print("\n" + "=" * 50)
print("AUDITORIA DOS FORMATOS DE DATAS")
print("=" * 50)

padroes_data = {
    "ISO com horário": r"^\d{4}-\d{2}-\d{2}T",
    "ISO simples": r"^\d{4}-\d{2}-\d{2}$",
    "Brasileiro com barras": r"^\d{2}/\d{2}/\d{4}",
    "Brasileiro com pontos": r"^\d{2}\.\d{2}\.\d{4}",
    "Compacto AAAAMMDD": r"^\d{8}$"
}

for arquivo in arquivos:
    caminho = DATA_DIR / arquivo

    df = pd.read_csv(
        caminho,
        sep=",",
        encoding="utf-8-sig",
        dtype=str
    )

    colunas_data = [
        coluna for coluna in df.columns
        if coluna.startswith("data_")
    ]

    for coluna in colunas_data:
        print(f"\n{arquivo} — {coluna}")

        valores = df[coluna].dropna().astype(str).str.strip()

        classificados = pd.Series(False, index=valores.index)

        for nome, padrao in padroes_data.items():
            mascara = valores.str.match(padrao)
            print(f"{nome}: {mascara.sum()}")
            classificados = classificados | mascara

        print("Não classificados:", (~classificados).sum())
        print("Ausentes:", df[coluna].isna().sum())



print("\n" + "=" * 50)
print("INVESTIGAÇÃO DE DATAS NÃO CLASSIFICADAS")
print("=" * 50)

for arquivo in arquivos:
    caminho = DATA_DIR / arquivo

    df = pd.read_csv(
        caminho,
        sep=",",
        encoding="utf-8-sig",
        dtype=str
    )

    colunas_data = [
        coluna for coluna in df.columns
        if coluna.startswith("data_")
    ]

    for coluna in colunas_data:
        valores = df[coluna].dropna().astype(str).str.strip()

        classificados = pd.Series(False, index=valores.index)

        for padrao in padroes_data.values():
            classificados = classificados | valores.str.match(padrao)

        nao_classificados = valores[~classificados]

        if not nao_classificados.empty:
            print(f"\n{arquivo} — {coluna}")
            print("Total:", len(nao_classificados))
            print("Exemplos:")
            print(nao_classificados.drop_duplicates().head(10).to_string(index=False))



print("\n" + "=" * 50)
print("VALIDAÇÃO FINAL DOS FORMATOS DE DATAS")
print("=" * 50)

padroes_data_completos = {
    "ISO com horário": r"^\d{4}-\d{2}-\d{2}T.*$",
    "ISO simples": r"^\d{4}-\d{2}-\d{2}$",
    "Brasileiro com barras": r"^\d{2}/\d{2}/\d{4}(?:\s+.*)?$",
    "Brasileiro com pontos": r"^\d{2}\.\d{2}\.\d{4}(?:\s+.*)?$",
    "Compacto AAAAMMDD": r"^\d{8}$",
    "Brasileiro com hífens": r"^\d{2}-\d{2}-\d{4}$",
    "Ano primeiro com barras": r"^\d{4}/\d{2}/\d{2}$",
    "ISO com espaço e horário": r"^\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}.*$"
}

for arquivo in arquivos:
    df = pd.read_csv(
        DATA_DIR / arquivo,
        sep=",",
        encoding="utf-8-sig",
        dtype=str
    )

    for coluna in df.columns:
        if not coluna.startswith("data_"):
            continue

        valores = df[coluna].dropna().astype(str).str.strip()
        classificados = pd.Series(False, index=valores.index)

        for padrao in padroes_data_completos.values():
            classificados |= valores.str.match(padrao)

        restantes = valores[~classificados]

        print(f"\n{arquivo} — {coluna}")
        print("Valores preenchidos:", len(valores))
        print("Formatos reconhecidos:", int(classificados.sum()))
        print("Não classificados:", len(restantes))

        if not restantes.empty:
            print("Exemplos restantes:")
            print(restantes.drop_duplicates().head(5).to_string(index=False))
