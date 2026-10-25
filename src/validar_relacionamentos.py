
from pathlib import Path
import pandas as pd

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data" / "raw"

compras = pd.read_csv(
    DATA_DIR / "compras.csv",
    sep=",",
    encoding="utf-8-sig",
    dtype=str
)

itens = pd.read_csv(
    DATA_DIR / "itens.csv",
    sep=",",
    encoding="utf-8-sig",
    dtype=str
)

# Verificar a chave principal de compras
print("\n=== VALIDAÇÃO DE COMPRAS ===")

print("Total de compras:", len(compras))
print(
    "Identificadores nulos:",
    compras["numero_controle_pncp"].isna().sum()
)
print(
    "Identificadores duplicados:",
    compras["numero_controle_pncp"].duplicated().sum()
)

# Verificar a chave composta de itens
print("\n=== VALIDAÇÃO DE ITENS ===")

chave_item = ["numero_controle_pncp", "numero_item"]

print("Total de itens:", len(itens))
print(
    "Chaves com valores nulos:",
    itens[chave_item].isna().any(axis=1).sum()
)
print(
    "Chaves duplicadas:",
    itens.duplicated(subset=chave_item).sum()
)

# Verificar itens sem compra correspondente
compras_ids = set(compras["numero_controle_pncp"].dropna())

itens_sem_compra = itens[
    ~itens["numero_controle_pncp"].isin(compras_ids)
]

print(
    "Itens sem compra correspondente:",
    len(itens_sem_compra)
)



# Carregar resultados
resultados = pd.read_csv(
    DATA_DIR / "resultados.csv",
    sep=",",
    encoding="utf-8-sig",
    dtype=str
)

print("\n=== VALIDAÇÃO DE RESULTADOS ===")

chave_resultado = [
    "numero_controle_pncp",
    "numero_item",
    "sequencial_resultado"
]

print("Total de resultados:", len(resultados))

print(
    "Chaves com valores nulos:",
    resultados[chave_resultado].isna().any(axis=1).sum()
)

print(
    "Chaves duplicadas:",
    resultados.duplicated(subset=chave_resultado).sum()
)

# Verificar se cada resultado possui item correspondente
chaves_itens = pd.MultiIndex.from_frame(
    itens[["numero_controle_pncp", "numero_item"]]
)

chaves_resultados = pd.MultiIndex.from_frame(
    resultados[["numero_controle_pncp", "numero_item"]]
)

resultados_sem_item = ~chaves_resultados.isin(chaves_itens)

print(
    "Resultados sem item correspondente:",
    resultados_sem_item.sum()
)



print("\n=== CARDINALIDADE DOS RELACIONAMENTOS ===")

# Quantidade de itens por compra
itens_por_compra = itens.groupby(
    "numero_controle_pncp"
).size()

print("\nITENS POR COMPRA")
print("Compras com itens:", len(itens_por_compra))
print("Mínimo de itens:", itens_por_compra.min())
print("Máximo de itens:", itens_por_compra.max())
print("Média de itens:", round(itens_por_compra.mean(), 2))

# Quantidade de resultados por item
resultados_por_item = resultados.groupby(
    ["numero_controle_pncp", "numero_item"]
).size()

print("\nRESULTADOS POR ITEM")
print("Itens com resultados:", len(resultados_por_item))
print("Mínimo de resultados:", resultados_por_item.min())
print("Máximo de resultados:", resultados_por_item.max())
print(
    "Média de resultados:",
    round(resultados_por_item.mean(), 2)
)

# Itens que ainda não possuem resultados
chaves_com_resultados = pd.MultiIndex.from_frame(
    resultados[["numero_controle_pncp", "numero_item"]]
).unique()

chaves_todos_itens = pd.MultiIndex.from_frame(
    itens[["numero_controle_pncp", "numero_item"]]
)

itens_sem_resultado = (
    ~chaves_todos_itens.isin(chaves_com_resultados)
).sum()

print("\nItens sem resultados:", itens_sem_resultado)



print("\n=== INVESTIGAÇÃO DO ITEM COM MAIS RESULTADOS ===")

# Identificar a compra e o item com mais resultados
chave_maxima = resultados_por_item.idxmax()

numero_compra = chave_maxima[0]
numero_item = chave_maxima[1]

dados_item = resultados[
    (resultados["numero_controle_pncp"] == numero_compra)
    & (resultados["numero_item"] == numero_item)
]

print("Número de controle PNCP:", numero_compra)
print("Número do item:", numero_item)
print("Quantidade de resultados:", len(dados_item))

print(
    "Sequenciais de resultado distintos:",
    dados_item["sequencial_resultado"].nunique()
)

print(
    "Fornecedores distintos (identificador bruto):",
    dados_item["ni_fornecedor"].nunique()
)

print("\nPrimeiros 5 resultados:")
print(
    dados_item[
        [
            "sequencial_resultado",
            "ni_fornecedor",
            "nome_fornecedor",
            "valor_total_homologado"
        ]
    ].head().to_string(index=False)
)
