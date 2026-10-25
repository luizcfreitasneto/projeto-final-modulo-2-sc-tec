
from pathlib import Path
import pandas as pd

# Localiza a pasta principal do projeto
BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data" / "raw"

arquivos = ["compras.csv", "itens.csv", "resultados.csv"]

for arquivo in arquivos:
    caminho = DATA_DIR / arquivo

    print(f"\n{'=' * 50}")
    print(f"ARQUIVO: {arquivo}")
    print("=" * 50)

    try:
        df = pd.read_csv(
            caminho,
            sep=None,
            engine="python",
            encoding="utf-8-sig",
            nrows=5
        )

        print(f"Colunas identificadas: {len(df.columns)}")
        print(f"Nomes das colunas: {df.columns.tolist()}")
        print("\nPrimeiras 5 linhas:")
        print(df.head().to_string(index=False))

    except Exception as erro:
        print(f"Erro ao ler {arquivo}: {erro}")



# Contagem de registros dos arquivos CSV
print("\n" + "=" * 50)
print("CONTAGEM DE REGISTROS")
print("=" * 50)

for arquivo in arquivos:
    caminho = DATA_DIR / arquivo

    with open(caminho, "r", encoding="utf-8-sig", newline="") as f:
        total_linhas = sum(1 for _ in f) - 1

    print(f"{arquivo}: {total_linhas:,} registros")



# Auditoria inicial de valores ausentes
print("\n" + "=" * 50)
print("VALORES AUSENTES POR ARQUIVO")
print("=" * 50)

for arquivo in arquivos:
    caminho = DATA_DIR / arquivo

    print(f"\nARQUIVO: {arquivo}")

    df = pd.read_csv(
        caminho,
        sep=None,
        engine="python",
        encoding="utf-8-sig",
        dtype=str
    )

    nulos = df.isna().sum()
    nulos = nulos[nulos > 0].sort_values(ascending=False)

    if nulos.empty:
        print("Nenhum valor ausente identificado.")
    else:
        print(nulos.to_string())



# Verificação de registros duplicados
print("\n" + "=" * 50)
print("REGISTROS DUPLICADOS")
print("=" * 50)

for arquivo in arquivos:
    caminho = DATA_DIR / arquivo

    df = pd.read_csv(
        caminho,
        sep=None,
        engine="python",
        encoding="utf-8-sig",
        dtype=str
    )

    duplicados = df.duplicated().sum()

    print(f"\nARQUIVO: {arquivo}")
    print(f"Total de registros: {len(df)}")
    print(f"Linhas inteiramente duplicadas: {duplicados}")
    print(f"Percentual: {duplicados / len(df) * 100:.2f}%")



import csv

print("\n" + "=" * 50)
print("VALIDAÇÃO DA CONTAGEM DE REGISTROS")
print("=" * 50)

for arquivo in arquivos:
    caminho = DATA_DIR / arquivo

    with open(
        caminho,
        "r",
        encoding="utf-8-sig",
        newline=""
    ) as f:
        amostra = f.read(65536)
        f.seek(0)

        dialeto = csv.Sniffer().sniff(amostra)
        leitor = csv.reader(f, dialect=dialeto)

        cabecalho = next(leitor)
        total_registros = sum(1 for linha in leitor if linha)

    print(f"\n{arquivo}")
    print(f"Registros identificados pelo CSV: {total_registros}")
    print(f"Colunas no cabeçalho: {len(cabecalho)}")



print("\n" + "=" * 50)
print("VERIFICAÇÃO DOS SEPARADORES")
print("=" * 50)

for arquivo in arquivos:
    caminho = DATA_DIR / arquivo

    with open(caminho, "r", encoding="utf-8-sig") as f:
        primeira_linha = f.readline().strip()

    print(f"\nARQUIVO: {arquivo}")
    print(f"Vírgulas: {primeira_linha.count(',')}")
    print(f"Pontos e vírgulas: {primeira_linha.count(';')}")
    print(f"Tabs: {primeira_linha.count(chr(9))}")
    print(f"Cabeçalho: {primeira_linha[:200]}")



print("\n" + "=" * 50)
print("VALIDAÇÃO FINAL DOS REGISTROS")
print("=" * 50)

for arquivo in arquivos:
    caminho = DATA_DIR / arquivo

    # Leitura pelo pandas
    df = pd.read_csv(
        caminho,
        sep=",",
        encoding="utf-8-sig",
        dtype=str
    )

    # Leitura pelo módulo csv
    with open(caminho, "r", encoding="utf-8-sig", newline="") as f:
        leitor = csv.reader(f, delimiter=",")
        cabecalho = next(leitor)
        linhas = list(leitor)

    linhas_validas = sum(
        1 for linha in linhas
        if len(linha) == len(cabecalho)
    )

    linhas_invalidas = len(linhas) - linhas_validas

    print(f"\nARQUIVO: {arquivo}")
    print(f"Registros pandas: {len(df)}")
    print(f"Registros csv.reader: {len(linhas)}")
    print(f"Registros com {len(cabecalho)} campos: {linhas_validas}")
    print(f"Registros com quantidade incorreta de campos: {linhas_invalidas}")


