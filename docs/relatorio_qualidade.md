
# Relatório de Qualidade dos Dados

## Projeto Final — Módulo 2 | SC TEC / SENAI-SC

### 1. Objetivo

Este relatório apresenta os resultados da auditoria inicial dos dados
de compras públicas do PNCP, antes das etapas de limpeza,
transformação e carregamento no banco de dados.

O objetivo é identificar problemas de qualidade, verificar
relacionamentos e documentar as decisões necessárias para o ETL.

### 2. Fontes de dados

Foram analisados três arquivos CSV:

| Arquivo | Registros | Colunas |
|---|---:|---:|
| compras.csv | 2.042 | 25 |
| itens.csv | 7.077 | 14 |
| resultados.csv | 15.896 | 13 |
| **Total** | **25.015** | — |

Os arquivos foram lidos utilizando:

- Codificação: UTF-8 com BOM (`utf-8-sig`)
- Delimitador: vírgula (`,`)
- Biblioteca: pandas

### 3. Integridade estrutural

As verificações realizadas identificaram:

- 0 registros com quantidade incorreta de campos.
- 0 linhas integralmente duplicadas.
- 0 chaves primárias nulas ou duplicadas.
- 0 itens sem compra correspondente.
- 0 resultados sem item correspondente.

As chaves utilizadas foram:

**Compras:** `numero_controle_pncp`

**Itens:** `numero_controle_pncp` + `numero_item`

**Resultados:** `numero_controle_pncp` + `numero_item` +
`sequencial_resultado`

### 4. Relacionamentos

Foram confirmados os seguintes relacionamentos:

- Uma compra pode possuir vários itens.
- Um item pode possuir vários resultados.
- Todas as 2.042 compras possuem pelo menos um item.
- 6.225 itens possuem resultados associados.
- 852 itens não possuem resultados associados.

A ausência de resultados para determinados itens será
investigada antes de ser classificada como erro.

Foi identificado um item com 1.773 resultados distintos.
A situação será preservada para análise posterior, pois
não foi identificada duplicação da chave composta.



### 5. Valores ausentes

A auditoria identificou valores ausentes nas três bases.

#### 5.1. Compras

| Coluna | Valores ausentes |
|---|---:|
| data_abertura_proposta | 617 |
| data_encerramento_proposta | 617 |
| processo | 28 |
| modo_disputa | 26 |

As datas ausentes serão avaliadas considerando o tipo
e a situação da contratação.

Não será realizada exclusão automática dos registros.

#### 5.2. Itens

| Coluna | Valores ausentes |
|---|---:|
| catalogo_codigo_item | 7.068 |
| situacao_item | 92 |
| unidade_medida | 9 |

A coluna catalogo_codigo_item apresenta ausência de
preenchimento na maior parte dos registros.

Será avaliado se esse campo é necessário para o modelo
dimensional e para as análises solicitadas.

#### 5.3. Resultados

| Coluna | Valores ausentes |
|---|---:|
| data_cancelamento | 15.834 |
| ordem_classificacao_srp | 11.976 |
| porte | 196 |

A ausência de data_cancelamento pode ser esperada
quando não houve cancelamento.

A coluna ordem_classificacao_srp também será analisada
considerando sua aplicabilidade aos registros.

#### 5.4. Tratamento planejado

Durante a etapa de limpeza:

- Preservar os dados originais.
- Investigar o significado dos valores ausentes.
- Não substituir valores sem justificativa.
- Não excluir linhas automaticamente.
- Documentar as decisões de tratamento.



### 6. Formatos monetários

Foram identificados diferentes padrões de representação
de valores monetários nas três bases.

Exemplos encontrados:

| Valor original | Formato identificado |
|---|---|
| 20307804.45 | Decimal com ponto |
| 20.307.804,45 | Padrão brasileiro |
| 420,562.14 | Padrão internacional |
| R$ 419.848,81 | Padrão brasileiro com símbolo monetário |

As seguintes colunas foram analisadas:

**Compras**
- valor_total_estimado
- valor_total_homologado

**Itens**
- valor_unitario_estimado
- valor_total_estimado

**Resultados**
- valor_unitario_homologado
- valor_total_homologado

A auditoria confirmou a existência de formatos diferentes
dentro de uma mesma coluna.

#### 6.1. Tratamento planejado

Durante a limpeza dos dados:

- Identificar os separadores decimais e de milhar.
- Remover símbolos monetários quando necessário.
- Converter os valores para representação numérica padronizada.
- Verificar possíveis formatos ambíguos.
- Preservar os arquivos originais.
- Validar os resultados após a conversão.

### 7. Formatos de datas

A auditoria identificou os seguintes padrões:

| Exemplo | Formato |
|---|---|
| 2025-01-06T11:51:06 | ISO com horário |
| 2025-10-31 | ISO simples |
| 02/01/2025 | DD/MM/AAAA |
| 06.03.2025 | DD.MM.AAAA |
| 20250114 | AAAAMMDD |
| 02-01-2025 | DD-MM-AAAA |
| 2025/01/08 | AAAA/MM/DD |

Foram classificados 20.850 valores de datas preenchidos.

Resultado da auditoria:

- Valores preenchidos: 20.850
- Formatos reconhecidos: 20.850
- Formatos não classificados: 0
- Cobertura da classificação: 100%

O reconhecimento dos formatos não garante que todas
as datas sejam válidas no calendário.

#### 7.1. Tratamento planejado

Durante a limpeza:

- Converter datas para tipos apropriados.
- Validar dias, meses e anos.
- Identificar datas fora do intervalo esperado.
- Investigar valores atípicos, como 19-01-2035.
- Preservar valores ausentes quando justificados.
- Não alterar os arquivos originais.



### 8. Riscos identificados

A auditoria inicial identificou pontos que exigem
atenção durante a limpeza e transformação dos dados.

#### 8.1. Conversão incorreta de valores monetários

Os arquivos apresentam diferentes padrões de
separadores decimais e de milhar.

Uma conversão inadequada pode alterar os valores
financeiros e comprometer os indicadores do projeto.

**Recomendação:** criar regras de conversão,
identificar formatos ambíguos e validar os resultados.

#### 8.2. Datas fora do intervalo esperado

Foram identificados registros com datas que
merecem investigação, como 19-01-2035.

**Recomendação:** verificar a validade das datas
e analisar valores atípicos antes de decidir
qualquer tratamento.

#### 8.3. Valores ausentes

Algumas colunas apresentam grande quantidade
de valores não preenchidos.

**Recomendação:** avaliar o significado de cada
campo antes de preencher ou excluir informações.

#### 8.4. Multiplicidade de resultados

Foi identificado um item com 1.773 resultados
distintos, sem duplicação da chave composta.

**Recomendação:** preservar os registros e
investigar seu significado antes de realizar
agregações financeiras.

#### 8.5. Itens sem resultados

Foram identificados 852 itens sem resultados
associados.

**Recomendação:** não excluir automaticamente
esses itens. Avaliar sua situação e seu impacto
nas análises.

### 9. Recomendações para o ETL

A etapa de transformação deverá seguir
as seguintes diretrizes:

1. Preservar os arquivos CSV originais.
2. Padronizar os valores monetários.
3. Converter e validar os campos de datas.
4. Tratar valores ausentes conforme seu significado.
5. Preservar as chaves e os relacionamentos.
6. Investigar valores atípicos.
7. Evitar duplicações causadas por junções de tabelas.
8. Validar os resultados após cada transformação.
9. Registrar as decisões de tratamento.

### 10. Conclusão da auditoria

A análise inicial identificou 25.015 registros
distribuídos em três arquivos CSV.

As verificações confirmaram a integridade
das chaves e dos relacionamentos analisados,
sem registros órfãos ou duplicações das chaves.

Foram identificadas inconsistências de
representação monetária e diversidade de
formatos de datas, além de valores ausentes
e situações que exigem investigação.

Os dados apresentam condições para avançar
à etapa de limpeza e transformação, desde
que sejam aplicadas regras de tratamento
e validações apropriadas.

Este relatório documenta o estado inicial
das bases e orientará as próximas etapas
do processo ETL.
