-- Projeto Final SC TEC - Modulo 2
-- Modelo dimensional: PNCP 2025
-- Dimensao de orgaos

CREATE TABLE dim_orgao (
    sk_orgao INTEGER PRIMARY KEY,
    cnpj_orgao VARCHAR(14) NOT NULL,
    nome_orgao TEXT,
    poder TEXT
);


-- Dimensao de fornecedores

CREATE TABLE dim_fornecedor (
    sk_fornecedor INTEGER PRIMARY KEY,
    ni_fornecedor TEXT NOT NULL,
    nome_fornecedor TEXT,
    tipo_pessoa TEXT,
    porte TEXT
);


-- Dimensao de modalidades de contratacao

CREATE TABLE dim_modalidade (
    sk_modalidade INTEGER PRIMARY KEY,
    modalidade_id INTEGER NOT NULL,
    nome_modalidade TEXT
);


-- Dimensao de localidades

CREATE TABLE dim_localidade (
    sk_localidade INTEGER PRIMARY KEY,
    uf_sigla VARCHAR(2) NOT NULL,
    uf_nome TEXT,
    regiao TEXT
);


-- Tabela fato: itens contratados do PNCP 2025

CREATE TABLE fato_item_contratado (
    numero_controle_pncp TEXT NOT NULL,
    numero_item INTEGER NOT NULL,

    sk_orgao INTEGER NOT NULL,
    sk_fornecedor INTEGER NOT NULL,
    sk_modalidade INTEGER NOT NULL,
    sk_localidade INTEGER NOT NULL,

    data_publicacao DATE NOT NULL,
    data_homologacao DATE,

    descricao_item TEXT,
    perfil_gasto TEXT,

    quantidade NUMERIC,
    valor_unitario_estimado NUMERIC,
    valor_total_estimado NUMERIC,
    valor_unitario_homologado NUMERIC,
    valor_total_homologado NUMERIC,

    comparavel BOOLEAN NOT NULL,
    economia_valor NUMERIC,
    dias_ciclo INTEGER,

    CONSTRAINT pk_fato_item_contratado
        PRIMARY KEY (numero_controle_pncp, numero_item),

    CONSTRAINT fk_fato_orgao
        FOREIGN KEY (sk_orgao)
        REFERENCES dim_orgao(sk_orgao),

    CONSTRAINT fk_fato_fornecedor
        FOREIGN KEY (sk_fornecedor)
        REFERENCES dim_fornecedor(sk_fornecedor),

    CONSTRAINT fk_fato_modalidade
        FOREIGN KEY (sk_modalidade)
        REFERENCES dim_modalidade(sk_modalidade),

    CONSTRAINT fk_fato_localidade
        FOREIGN KEY (sk_localidade)
        REFERENCES dim_localidade(sk_localidade)
);



-- PERGUNTA 2
-- Quais fornecedores concentram o maior volume homologado?
-- Qual a participacao dos 10 maiores no volume total?

WITH gastos_fornecedores AS (
    SELECT
        d.sk_fornecedor,
        d.ni_fornecedor,
        d.nome_fornecedor,
        COUNT(*) AS quantidade_itens,
        SUM(f.valor_total_homologado) AS valor_homologado
    FROM fato_item_contratado AS f
    INNER JOIN dim_fornecedor AS d
        ON f.sk_fornecedor = d.sk_fornecedor
    GROUP BY
        d.sk_fornecedor,
        d.ni_fornecedor,
        d.nome_fornecedor
),
ranking AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            ORDER BY valor_homologado DESC, sk_fornecedor
        ) AS posicao
    FROM gastos_fornecedores
),
total_geral AS (
    SELECT SUM(valor_total_homologado) AS total
    FROM fato_item_contratado
)
SELECT
    r.posicao,
    r.ni_fornecedor,
    r.nome_fornecedor,
    r.quantidade_itens,
    ROUND(r.valor_homologado, 2) AS valor_homologado,
    ROUND(
        100.0 * r.valor_homologado / NULLIF(t.total, 0),
        2
    ) AS participacao_percentual,
    ROUND(
        100.0 * SUM(r.valor_homologado) OVER ()
        / NULLIF(t.total, 0),
        2
    ) AS concentracao_top_10_percentual
FROM ranking AS r
CROSS JOIN total_geral AS t
WHERE r.posicao <= 10
ORDER BY r.posicao;



-- PERGUNTA 3
-- Qual o volume homologado e a economia por modalidade?
-- A economia considera somente itens comparaveis.

SELECT
    m.nome_modalidade,

    COUNT(*) AS quantidade_itens,

    ROUND(
        SUM(f.valor_total_homologado), 2
    ) AS volume_homologado,

    ROUND(
        100.0 * SUM(f.valor_total_homologado)
        / NULLIF(
            SUM(SUM(f.valor_total_homologado)) OVER (), 0
        ), 2
    ) AS participacao_volume_percentual,

    COUNT(*) FILTER (
        WHERE f.comparavel = TRUE
    ) AS itens_comparaveis,

    ROUND(
        SUM(f.valor_total_estimado) FILTER (
            WHERE f.comparavel = TRUE
        ), 2
    ) AS estimado_comparavel,

    ROUND(
        SUM(f.valor_total_estimado - f.valor_total_homologado)
        FILTER (
            WHERE f.comparavel = TRUE
        ), 2
    ) AS economia_nominal,

    ROUND(
        100.0 *
        SUM(f.valor_total_estimado - f.valor_total_homologado)
        FILTER (
            WHERE f.comparavel = TRUE
        )
        / NULLIF(
            SUM(f.valor_total_estimado) FILTER (
                WHERE f.comparavel = TRUE
            ), 0
        ), 2
    ) AS economia_percentual

FROM fato_item_contratado AS f
INNER JOIN dim_modalidade AS m
    ON f.sk_modalidade = m.sk_modalidade

GROUP BY
    m.sk_modalidade,
    m.nome_modalidade

ORDER BY volume_homologado DESC;



-- PERGUNTA 4
-- Quais orgaos apresentam os maiores ciclos medios?
-- Considerar apenas orgaos com pelo menos 5 itens
-- com ciclo valido.

SELECT
    o.nome_orgao AS orgao_comprador,

    COUNT(f.dias_ciclo) AS itens_com_ciclo_valido,

    ROUND(
        AVG(f.dias_ciclo), 2
    ) AS ciclo_medio_dias,

    MAX(f.dias_ciclo) AS ciclo_maximo_dias,

    MIN(f.dias_ciclo) AS ciclo_minimo_dias

FROM fato_item_contratado AS f

INNER JOIN dim_orgao AS o
    ON f.sk_orgao = o.sk_orgao

WHERE f.dias_ciclo IS NOT NULL
  AND f.dias_ciclo >= 0

GROUP BY o.nome_orgao

HAVING COUNT(f.dias_ciclo) >= 5

ORDER BY ciclo_medio_dias DESC, orgao_comprador;
