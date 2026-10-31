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