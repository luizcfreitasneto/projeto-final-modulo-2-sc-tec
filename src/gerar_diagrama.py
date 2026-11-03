
from pathlib import Path
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

# Caminho de saída
RAIZ = Path(__file__).resolve().parent.parent
DESTINO = RAIZ / "docs" / "img" / "modelo_dimensional.png"
DESTINO.parent.mkdir(parents=True, exist_ok=True)

fig, ax = plt.subplots(figsize=(16, 10))
fig.patch.set_facecolor("#F4F7FB")
ax.set_facecolor("#F4F7FB")
ax.set_xlim(0, 16)
ax.set_ylim(0, 10)
ax.axis("off")

ax.text(
    0.8, 9.35,
    "MODELO DIMENSIONAL — STAR SCHEMA",
    fontsize=23, fontweight="bold", color="#17365D"
)
ax.text(
    0.8, 8.9,
    "Projeto PNCP 2025 | PostgreSQL",
    fontsize=13, color="#52657A"
)

def desenhar_tabela(x, y, largura, altura, titulo, campos, cor):
    caixa = FancyBboxPatch(
        (x, y), largura, altura,
        boxstyle="round,pad=0.04,rounding_size=0.12",
        facecolor="white",
        edgecolor=cor,
        linewidth=2
    )
    ax.add_patch(caixa)

    ax.text(
        x + 0.2, y + altura - 0.35,
        titulo, fontsize=13, fontweight="bold", color=cor
    )

    for i, campo in enumerate(campos):
        ax.text(
            x + 0.2, y + altura - 0.8 - i * 0.36,
            campo, fontsize=10.5, color="#34495E"
        )

# Dimensões
desenhar_tabela(
    0.7, 5.65, 5.2, 2.35,
    "dim_orgao",
    ["PK  sk_orgao", "cnpj_orgao", "nome_orgao", "poder"],
    "#2874A6"
)

desenhar_tabela(
    10.1, 5.65, 5.2, 2.35,
    "dim_fornecedor",
    ["PK  sk_fornecedor", "ni_fornecedor",
     "nome_fornecedor", "tipo_pessoa", "porte"],
    "#2874A6"
)

desenhar_tabela(
    0.7, 1.0, 5.2, 2.35,
    "dim_modalidade",
    ["PK  sk_modalidade", "modalidade_id", "nome_modalidade"],
    "#2874A6"
)

desenhar_tabela(
    10.1, 1.0, 5.2, 2.35,
    "dim_localidade",
    ["PK  sk_localidade", "uf_sigla", "uf_nome", "regiao"],
    "#2874A6"
)

# Tabela fato central
desenhar_tabela(
    6.1, 3.25, 3.8, 3.5,
    "fato_item_contratado",
    [
        "PK  numero_controle_pncp",
        "PK  numero_item",
        "FK  sk_orgao",
        "FK  sk_fornecedor",
        "FK  sk_modalidade",
        "FK  sk_localidade",
        "valor_total_homologado",
        "economia_valor",
    ],
    "#D35400"
)

# Relacionamentos 1:N
relacoes = [
    ((5.9, 6.8), (6.1, 6.3)),
    ((10.1, 6.8), (9.9, 6.3)),
    ((5.9, 2.5), (6.1, 3.6)),
    ((10.1, 2.5), (9.9, 3.6)),
]

for inicio, fim in relacoes:
    ax.annotate(
        "", xy=fim, xytext=inicio,
        arrowprops=dict(
            arrowstyle="-|>",
            color="#718096",
            linewidth=2
        )
    )

ax.text(
    8, 0.35,
    "Relacionamentos: dimensão (1) → tabela fato (N)",
    ha="center", fontsize=11, color="#52657A"
)

plt.savefig(DESTINO, dpi=180, bbox_inches="tight")
plt.close(fig)

print(f"Diagrama gerado com sucesso: {DESTINO}")
