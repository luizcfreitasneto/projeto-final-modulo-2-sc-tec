
from pathlib import Path
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

# Localizar a pasta principal do projeto
RAIZ = Path(__file__).resolve().parent.parent
DESTINO = RAIZ / "docs" / "img" / "sprints.png"
DESTINO.parent.mkdir(parents=True, exist_ok=True)

sprints = [
    ("Sprint 1", "Preparação e exploração",
     "Ambiente Python, GitHub e inspeção dos CSVs", "Concluída"),
    ("Sprint 2", "Qualidade e tratamento",
     "Auditoria, limpeza e validação dos dados", "Concluída"),
    ("Sprint 3", "Modelagem dimensional",
     "Star Schema, dimensões e tabela fato", "Concluída"),
    ("Sprint 4", "PostgreSQL e análises SQL",
     "Banco de dados, carregamento e consultas", "Concluída"),
    ("Sprint 5", "Dashboards Power BI",
     "Medidas DAX, seis páginas e testes", "Concluída"),
    ("Sprint 6", "Documentação e entrega",
     "README, GitHub, revisão, vídeo e AVA", "Em andamento"),
]

fig, ax = plt.subplots(figsize=(15, 10))
fig.patch.set_facecolor("#F4F7FB")
ax.set_facecolor("#F4F7FB")
ax.set_xlim(0, 15)
ax.set_ylim(0, 10)
ax.axis("off")

ax.text(
    0.8, 9.4, "PLANEJAMENTO EM SPRINTS",
    fontsize=24, fontweight="bold", color="#142D4E"
)
ax.text(
    0.8, 8.95, "Projeto Final SC TEC | PNCP 2025",
    fontsize=13, color="#52657A"
)

for i, (numero, titulo, atividades, status) in enumerate(sprints):
    y = 7.75 - i * 1.18

    caixa = FancyBboxPatch(
        (0.8, y), 13.4, 0.95,
        boxstyle="round,pad=0.03,rounding_size=0.15",
        facecolor="white",
        edgecolor="#D9E2EC",
        linewidth=1.2
    )
    ax.add_patch(caixa)

    ax.text(
        1.1, y + 0.62, f"{numero} — {titulo}",
        fontsize=14, fontweight="bold", color="#17365D"
    )
    ax.text(
        1.1, y + 0.23, atividades,
        fontsize=11, color="#52657A"
    )

    cor = "#16804A" if status == "Concluída" else "#B36B00"
    ax.text(
        13.8, y + 0.49, status,
        fontsize=10, fontweight="bold",
        color=cor, ha="right", va="center"
    )

ax.text(
    0.8, 0.4,
    "Organização retrospectiva das atividades, sem datas históricas atribuídas.",
    fontsize=10, color="#52657A"
)

plt.savefig(DESTINO, dpi=180, bbox_inches="tight")
plt.close(fig)

print(f"Imagem gerada com sucesso: {DESTINO}")
