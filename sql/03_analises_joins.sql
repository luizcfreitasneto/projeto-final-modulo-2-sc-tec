-- Projeto Final SC TEC - Modulo 2
-- Analises com JOIN - PNCP 2025
-- Banco: pncp_2025_dw

-- 1. Ranking dos 10 orgaos por valor homologado
SELECT
    o.nome_orgao,
    COUNT(*) AS total_itens,
    ROUND(
        SUM(f.valor_total_homologado),
        2
    ) AS valor_total_homologado
FROM fato_item_contratado AS f
INNER JOIN dim_orgao AS o
    ON f.sk_orgao = o.sk_orgao
GROUP BY
    o.sk_orgao,
    o.nome_orgao
ORDER BY valor_total_homologado DESC
LIMIT 10;


-- 2. Valor homologado por modalidade de contratacao
SELECT
    m.nome_modalidade,
    COUNT(*) AS total_itens,
    ROUND(
        SUM(f.valor_total_homologado),
        2
    ) AS valor_total_homologado,
    ROUND(
        100.0 * SUM(f.valor_total_homologado)
        / SUM(SUM(f.valor_total_homologado)) OVER (),
        2
    ) AS percentual_valor
FROM fato_item_contratado AS f
INNER JOIN dim_modalidade AS m
    ON f.sk_modalidade = m.sk_modalidade
GROUP BY
    m.sk_modalidade,
    m.nome_modalidade
ORDER BY valor_total_homologado DESC;


-- 3. Valor homologado por regiao brasileira
SELECT
    l.regiao,
    COUNT(*) AS total_itens,
    ROUND(
        SUM(f.valor_total_homologado),
        2
    ) AS valor_total_homologado,
    ROUND(
        100.0 * SUM(f.valor_total_homologado)
        / SUM(SUM(f.valor_total_homologado)) OVER (),
        2
    ) AS percentual_valor
FROM fato_item_contratado AS f
INNER JOIN dim_localidade AS l
    ON f.sk_localidade = l.sk_localidade
GROUP BY l.regiao
ORDER BY valor_total_homologado DESC;


-- 4. Ranking dos 10 fornecedores por valor homologado
SELECT
    d.nome_fornecedor,
    d.ni_fornecedor,
    d.porte,
    COUNT(*) AS total_itens,
    ROUND(
        SUM(f.valor_total_homologado),
        2
    ) AS valor_total_homologado
FROM fato_item_contratado AS f
INNER JOIN dim_fornecedor AS d
    ON f.sk_fornecedor = d.sk_fornecedor
GROUP BY
    d.sk_fornecedor,
    d.nome_fornecedor,
    d.ni_fornecedor,
    d.porte
ORDER BY valor_total_homologado DESC
LIMIT 10;


-- 5. Distribuicao dos valores por porte do fornecedor
SELECT
    COALESCE(d.porte, 'Não informado') AS porte_fornecedor,
    COUNT(*) AS total_itens,
    COUNT(DISTINCT d.sk_fornecedor) AS total_fornecedores,
    ROUND(
        SUM(f.valor_total_homologado),
        2
    ) AS valor_total_homologado,
    ROUND(
        100.0 * SUM(f.valor_total_homologado)
        / SUM(SUM(f.valor_total_homologado)) OVER (),
        2
    ) AS percentual_valor
FROM fato_item_contratado AS f
INNER JOIN dim_fornecedor AS d
    ON f.sk_fornecedor = d.sk_fornecedor
GROUP BY COALESCE(d.porte, 'Não informado')
ORDER BY valor_total_homologado DESC;


-- 6. Validacao dos relacionamentos do Star Schema
SELECT
    COUNT(*) AS total_itens,
    COUNT(*) FILTER (
        WHERE o.sk_orgao IS NULL
    ) AS sem_orgao,
    COUNT(*) FILTER (
        WHERE d.sk_fornecedor IS NULL
    ) AS sem_fornecedor,
    COUNT(*) FILTER (
        WHERE m.sk_modalidade IS NULL
    ) AS sem_modalidade,
    COUNT(*) FILTER (
        WHERE l.sk_localidade IS NULL
    ) AS sem_localidade
FROM fato_item_contratado AS f
LEFT JOIN dim_orgao AS o
    ON f.sk_orgao = o.sk_orgao
LEFT JOIN dim_fornecedor AS d
    ON f.sk_fornecedor = d.sk_fornecedor
LEFT JOIN dim_modalidade AS m
    ON f.sk_modalidade = m.sk_modalidade
LEFT JOIN dim_localidade AS l
    ON f.sk_localidade = l.sk_localidade;


-- 7. Participacao dos 10 maiores fornecedores no valor total
WITH valores_fornecedores AS (
    SELECT
        f.sk_fornecedor,
        SUM(f.valor_total_homologado) AS valor_total
    FROM fato_item_contratado AS f
    GROUP BY f.sk_fornecedor
),
top_10 AS (
    SELECT valor_total
    FROM valores_fornecedores
    ORDER BY valor_total DESC
    LIMIT 10
)
SELECT
    ROUND(SUM(valor_total), 2) AS valor_top_10,
    ROUND(
        100.0 * SUM(valor_total)
        / (
            SELECT SUM(valor_total_homologado)
            FROM fato_item_contratado
        ),
        2
    ) AS percentual_top_10
FROM top_10;


-- 8. Valores homologados por estado (UF)
SELECT
    l.uf_sigla,
    l.uf_nome,
    l.regiao,
    COUNT(*) AS total_itens,
    ROUND(
        SUM(f.valor_total_homologado),
        2
    ) AS valor_total_homologado
FROM fato_item_contratado AS f
INNER JOIN dim_localidade AS l
    ON f.sk_localidade = l.sk_localidade
GROUP BY
    l.sk_localidade,
    l.uf_sigla,
    l.uf_nome,
    l.regiao
ORDER BY valor_total_homologado DESC;


-- 9. Participacao do DNIT no valor total homologado
SELECT
    ROUND(
        SUM(f.valor_total_homologado),
        2
    ) AS valor_dnit,
    ROUND(
        100.0 * SUM(f.valor_total_homologado)
        / (
            SELECT SUM(valor_total_homologado)
            FROM fato_item_contratado
        ),
        2
    ) AS percentual_total
FROM fato_item_contratado AS f
INNER JOIN dim_orgao AS o
    ON f.sk_orgao = o.sk_orgao
WHERE o.nome_orgao ILIKE '%DNIT%';


-- 10. Consolidacao dos estabelecimentos do DNIT
-- pela raiz do CNPJ
SELECT
    LEFT(o.cnpj_orgao, 8) AS raiz_cnpj,
    COUNT(DISTINCT o.cnpj_orgao) AS total_estabelecimentos,
    COUNT(*) AS total_itens,
    ROUND(
        SUM(f.valor_total_homologado),
        2
    ) AS valor_total_homologado
FROM fato_item_contratado AS f
INNER JOIN dim_orgao AS o
    ON f.sk_orgao = o.sk_orgao
WHERE o.nome_orgao ILIKE '%DNIT%'
GROUP BY LEFT(o.cnpj_orgao, 8);


-- 11. Investigacao dos estabelecimentos do DNIT
SELECT
    sk_orgao,
    cnpj_orgao,
    nome_orgao,
    poder
FROM dim_orgao
WHERE nome_orgao ILIKE '%DNIT%'
ORDER BY sk_orgao;