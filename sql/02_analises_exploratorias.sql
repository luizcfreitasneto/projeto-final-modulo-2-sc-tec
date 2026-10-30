-- Projeto Final SC TEC - Modulo 2
-- Analises exploratorias dos dados PNCP 2025
-- Banco: pncp_2025_dw

-- 1. Quantidade de itens e contratacoes distintas
SELECT
    COUNT(*) AS total_itens,
    COUNT(DISTINCT numero_controle_pncp) AS total_contratacoes
FROM fato_item_contratado;

-- 2. Quantidade de orgaos e fornecedores distintos
SELECT
    COUNT(DISTINCT sk_orgao) AS total_orgaos,
    COUNT(DISTINCT sk_fornecedor) AS total_fornecedores
FROM fato_item_contratado;

-- 3. Indicadores financeiros
SELECT
    ROUND(SUM(valor_total_homologado), 2) AS valor_total_homologado,
    ROUND(AVG(valor_total_homologado), 2) AS media_valor_homologado,
    MIN(valor_total_homologado) AS menor_valor,
    MAX(valor_total_homologado) AS maior_valor
FROM fato_item_contratado;


-- 4. Mediana dos valores homologados
SELECT
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY valor_total_homologado
        )::NUMERIC,
        2
    ) AS mediana_valor_homologado
FROM fato_item_contratado;

-- 5. Verificacao de valores zerados, ausentes e positivos
SELECT
    COUNT(*) FILTER (
        WHERE valor_total_homologado = 0
    ) AS itens_valor_zero,

    COUNT(*) FILTER (
        WHERE valor_total_homologado IS NULL
    ) AS itens_valor_ausente,

    COUNT(*) FILTER (
        WHERE valor_total_homologado > 0
    ) AS itens_valor_positivo
FROM fato_item_contratado;


-- 6. Distribuicao dos itens por perfil de gasto
SELECT
    perfil_gasto,
    COUNT(*) AS total_itens,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentual_itens
FROM fato_item_contratado
GROUP BY perfil_gasto
ORDER BY total_itens DESC;

-- 7. Valor homologado por perfil de gasto
SELECT
    perfil_gasto,
    COUNT(*) AS total_itens,
    ROUND(SUM(valor_total_homologado), 2) AS valor_total,
    ROUND(
        100.0 * SUM(valor_total_homologado)
        / SUM(SUM(valor_total_homologado)) OVER (),
        2
    ) AS percentual_valor
FROM fato_item_contratado
GROUP BY perfil_gasto
ORDER BY valor_total DESC;


-- 8. Indicadores do ciclo de contratacao
SELECT
    ROUND(AVG(dias_ciclo), 2) AS media_dias_ciclo,
    MIN(dias_ciclo) AS menor_ciclo,
    MAX(dias_ciclo) AS maior_ciclo,
    COUNT(dias_ciclo) AS ciclos_preenchidos,
    COUNT(*) FILTER (
        WHERE dias_ciclo IS NULL
    ) AS ciclos_ausentes
FROM fato_item_contratado;


-- 9. Quantidade de itens comparaveis e nao comparaveis
SELECT
    comparavel,
    COUNT(*) AS total_itens,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentual
FROM fato_item_contratado
GROUP BY comparavel
ORDER BY comparavel DESC;