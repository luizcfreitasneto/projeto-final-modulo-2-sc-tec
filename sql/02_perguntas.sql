
-- Projeto Final SC TEC - Modulo 2
-- Seis perguntas de negocio - PNCP 2025
-- Banco: pncp_2025_dw

-- PERGUNTA 1
-- Qual foi o volume homologado, a economia nominal
-- e o percentual de economia dos itens comparaveis?

SELECT
    ROUND(SUM(valor_total_homologado), 2)
        AS volume_homologado_total,

    COUNT(*) FILTER (WHERE comparavel = TRUE)
        AS quantidade_itens_comparaveis,

    ROUND(
        SUM(valor_total_estimado)
            FILTER (WHERE comparavel = TRUE),
        2
    ) AS valor_estimado_comparavel,

    ROUND(
        SUM(valor_total_homologado)
            FILTER (WHERE comparavel = TRUE),
        2
    ) AS valor_homologado_comparavel,

    ROUND(
        SUM(valor_total_estimado - valor_total_homologado)
            FILTER (WHERE comparavel = TRUE),
        2
    ) AS economia_nominal,

    ROUND(
        100.0 *
        SUM(valor_total_estimado - valor_total_homologado)
            FILTER (WHERE comparavel = TRUE)
        /
        NULLIF(
            SUM(valor_total_estimado)
                FILTER (WHERE comparavel = TRUE),
            0
        ),
        2
    ) AS economia_percentual

FROM fato_item_contratado;



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

    COUNT(*) AS itens_com_ciclo_valido,

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

HAVING COUNT(*) >= 5

ORDER BY ciclo_medio_dias DESC, orgao_comprador;




-- PERGUNTA 5
-- Como os gastos e a economia se distribuem
-- entre as regioes brasileiras?

SELECT
    l.regiao,

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

INNER JOIN dim_localidade AS l
    ON f.sk_localidade = l.sk_localidade

GROUP BY l.regiao

ORDER BY volume_homologado DESC;



-- PERGUNTA 6
-- Como os gastos se distribuem entre Bens, Servicos e Obras?
-- Qual a participacao de cada perfil no volume homologado?

SELECT
    f.perfil_gasto,

    COUNT(*) AS quantidade_itens,

    ROUND(
        100.0 * COUNT(*)
        / NULLIF(SUM(COUNT(*)) OVER (), 0),
        2
    ) AS percentual_itens,

    ROUND(
        SUM(f.valor_total_homologado), 2
    ) AS volume_homologado,

    ROUND(
        100.0 * SUM(f.valor_total_homologado)
        / NULLIF(
            SUM(SUM(f.valor_total_homologado)) OVER (), 0
        ),
        2
    ) AS participacao_volume_percentual

FROM fato_item_contratado AS f

GROUP BY f.perfil_gasto

ORDER BY volume_homologado DESC;
