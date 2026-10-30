# Indicadores SQL — PNCP 2025

## 1. Objetivo

Este documento apresenta os principais indicadores
obtidos por meio das consultas SQL realizadas no
PostgreSQL, utilizando o modelo dimensional
Star Schema do projeto.

Os resultados servirão de referência para a
construção do dashboard no Power BI.

## 2. Estrutura dos dados

O banco de dados utilizado é `pncp_2025_dw`.

### Tabela fato

- fato_item_contratado: 6.126 registros.

### Tabelas dimensão

| Tabela | Registros |
|---|---:|
| dim_orgao | 363 |
| dim_fornecedor | 2.652 |
| dim_modalidade | 7 |
| dim_localidade | 27 |

## 3. Validação dos relacionamentos

A análise com LEFT JOIN apresentou:

| Indicador | Resultado |
|---|---:|
| Total de itens | 6.126 |
| Itens sem órgão correspondente | 0 |
| Itens sem fornecedor correspondente | 0 |
| Itens sem modalidade correspondente | 0 |
| Itens sem localidade correspondente | 0 |

Todos os 6.126 registros da tabela fato possuem
correspondência nas quatro dimensões analisadas.


## 4. Indicadores por modalidade de contratação

A análise SQL relacionou a tabela fato com a
dimensão de modalidades, utilizando INNER JOIN.

Os resultados foram:

| Modalidade | Itens | Valor homologado | Participação |
|---|---:|---:|---:|
| Concorrência Eletrônica | 521 | R$ 4.700.493.122,98 | 58,43% |
| Credenciamento | 601 | R$ 2.141.301.557,16 | 26,62% |
| Pregão Eletrônico | 3.046 | R$ 502.223.491,28 | 6,24% |
| Concorrência Presencial | 63 | R$ 444.752.757,18 | 5,53% |
| Inexigibilidade | 503 | R$ 213.365.238,19 | 2,65% |
| Dispensa | 1.387 | R$ 39.887.350,44 | 0,50% |
| Pregão Presencial | 5 | R$ 247.528,51 | 0,03% |

### Principais observações

1. A Concorrência Eletrônica concentra a maior
   parcela do valor homologado: 58,43%.

2. O Credenciamento ocupa a segunda posição,
   representando 26,62% do valor.

3. O Pregão Eletrônico possui a maior quantidade
   de itens: 3.046.

4. A modalidade com maior quantidade de itens
   não é necessariamente aquela com maior
   valor financeiro.

Esses resultados representam os registros
tratados e carregados no banco de dados
do projeto, não a totalidade das contratações
públicas brasileiras de 2025.


## 5. Indicadores por região brasileira

A análise utilizou INNER JOIN entre a tabela
fato_item_contratado e a dimensão dim_localidade.

Os resultados foram:

| Região | Itens | Valor homologado | Participação |
|---|---:|---:|---:|
| Centro-Oeste | 940 | R$ 3.559.879.991,73 | 44,25% |
| Nordeste | 1.155 | R$ 1.850.420.285,02 | 23,00% |
| Sudeste | 2.072 | R$ 1.083.309.811,49 | 13,47% |
| Sul | 1.325 | R$ 1.021.624.955,41 | 12,70% |
| Norte | 634 | R$ 529.263.762,09 | 6,58% |

### Principais observações

1. O Centro-Oeste concentra 44,25% do valor
   homologado na base analisada.

2. O Nordeste ocupa a segunda posição em
   participação financeira, com 23,00%.

3. O Sudeste apresenta a maior quantidade
   de itens, totalizando 2.072 registros.

4. A região com maior quantidade de itens
   não é necessariamente aquela com o
   maior valor homologado.

### Interpretação

Os resultados demonstram diferenças entre
a distribuição financeira e a quantidade
de itens contratados por região.

Esses indicadores poderão ser utilizados
em gráficos de barras e mapas no Power BI.

Os valores representam exclusivamente os
dados tratados neste projeto.


## 6. Indicadores por unidade federativa (UF)

A análise relacionou a tabela fato_item_contratado
com a dimensão dim_localidade por meio de INNER JOIN.

Foram identificadas 27 unidades federativas.

### Cinco maiores valores homologados

| UF | Itens | Valor homologado |
|---|---:|---:|
| DF | 585 | R$ 3.135.638.456,35 |
| RS | 845 | R$ 820.584.056,64 |
| RJ | 933 | R$ 461.925.602,27 |
| PI | 70 | R$ 408.389.525,89 |
| SP | 517 | R$ 393.783.392,48 |

### Principais observações

1. O Distrito Federal apresenta o maior
   valor homologado entre as UFs analisadas.

2. O Rio Grande do Sul ocupa a segunda
   posição em valor financeiro.

3. O Rio de Janeiro possui a maior
   quantidade de itens entre essas cinco UFs.

4. O Piauí apresenta apenas 70 itens,
   mas ocupa a quarta posição em valor
   homologado.

### Interpretação

A quantidade de itens não determina,
isoladamente, o valor financeiro total.

A concentração de valores no Distrito
Federal deve ser interpretada considerando
as características dos órgãos contratantes
e a composição da base analisada.

Esses resultados poderão ser apresentados
em um gráfico de barras no Power BI.


## 7. Concentração financeira dos fornecedores

A análise SQL utilizou CTEs (WITH) para
identificar os dez fornecedores com maiores
valores homologados.

### Indicadores

| Indicador | Resultado |
|---|---:|
| Fornecedores cadastrados na dimensão | 2.652 |
| Valor dos 10 maiores fornecedores | R$ 3.332.484.029,86 |
| Participação dos 10 maiores | 41,43% |

### Principais observações

1. Os dez maiores fornecedores concentram
   41,43% do valor homologado na base.

2. Essa concentração indica que uma parcela
   significativa do valor financeiro está
   associada a um grupo reduzido de fornecedores.

3. A NOW SEGUROS SA ocupa a primeira posição
   do ranking, com R$ 1.060.000.000,00
   em valor homologado.

### Interpretação

A concentração financeira não significa,
isoladamente, irregularidade nas contratações.

Para uma avaliação mais aprofundada, seria
necessário considerar os objetos contratados,
os órgãos responsáveis e as características
dos processos licitatórios.

No Power BI, esses indicadores poderão ser
representados por um ranking de fornecedores
e um cartão com o percentual de concentração.



## 8. Indicadores por porte dos fornecedores

A análise utilizou INNER JOIN entre
fato_item_contratado e dim_fornecedor.

### Resultados

| Porte | Itens | Fornecedores | Valor homologado | Participação |
|---|---:|---:|---:|---:|
| Demais | 1.926 | 908 | R$ 6.265.616.432,62 | 77,89% |
| ME | 3.811 | 1.489 | R$ 1.597.328.211,35 | 19,86% |
| Não informado | 380 | 250 | R$ 180.539.924,67 | 2,24% |
| EPP | 9 | 5 | R$ 101.423,10 | 0,01% |

### Principais observações

1. A categoria Demais concentra 77,89%
   do valor homologado.

2. As microempresas (ME) apresentam a
   maior quantidade de itens: 3.811.

3. As microempresas representam 19,86%
   do valor financeiro analisado.

4. Existem 380 itens associados a
   fornecedores com porte não informado.

### Interpretação

A distribuição demonstra que a quantidade
de itens e o valor financeiro contratado
não estão distribuídos de maneira uniforme
entre as categorias de porte.

A categoria Demais deve ser interpretada
conforme a classificação presente nos
dados de origem.

Os resultados poderão ser utilizados
em gráficos de barras e cartões no Power BI.


## 9. Indicadores por órgão público

A análise utilizou INNER JOIN entre a tabela
fato_item_contratado e a dimensão dim_orgao.

### Principais órgãos por valor homologado

| Órgão | Itens | Valor homologado |
|---|---:|---:|
| Ministério da Agricultura, Pecuária e Abastecimento | 25 | R$ 1.476.244.088,22 |
| DNIT - Estabelecimento 1 | 38 | R$ 1.352.010.451,41 |
| DNIT - Estabelecimento 2 | 4 | R$ 703.221.428,15 |
| Comando da Aeronáutica | 371 | R$ 358.804.777,08 |
| Comando do Exército | 1.276 | R$ 304.489.158,43 |

Os estabelecimentos do DNIT foram identificados
separadamente na dimensão de órgãos.

### Análise consolidada do DNIT

| Indicador | Resultado |
|---|---:|
| Raiz do CNPJ | 04892707 |
| Estabelecimentos identificados | 12 |
| Total de itens | 62 |
| Valor homologado | R$ 2.610.387.744,91 |
| Participação no valor total | 32,45% |

### Principais observações

1. O DNIT apresenta uma concentração
   significativa do valor homologado na base.

2. Os 12 estabelecimentos identificados
   compartilham a mesma raiz de CNPJ.

3. A consolidação pela raiz do CNPJ permite
   analisar conjuntamente esses estabelecimentos.

4. A quantidade de itens não determina
   isoladamente o valor financeiro total.

### Limitações da análise

A identificação dos estabelecimentos do DNIT
utilizou o filtro de nome ILIKE '%DNIT%'.

Os resultados representam os registros
encontrados por esse critério na base analisada.

A concentração financeira observada não
representa, por si só, qualquer irregularidade.


## 10. Conclusões das análises SQL

As consultas realizadas no PostgreSQL permitiram
identificar padrões relevantes na base PNCP 2025.

### Principais conclusões

1. A Concorrência Eletrônica concentra 58,43%
   do valor homologado, enquanto o Pregão
   Eletrônico apresenta a maior quantidade
   de itens.

2. O Centro-Oeste representa 44,25% do valor
   homologado, mas o Sudeste possui a maior
   quantidade de itens entre as regiões.

3. O Distrito Federal lidera o ranking de
   valores homologados por unidade federativa.

4. Os dez maiores fornecedores concentram
   41,43% do valor homologado na base.

5. As microempresas possuem a maior quantidade
   de itens, mas a categoria Demais concentra
   a maior participação financeira.

6. Os estabelecimentos identificados como DNIT
   representam 32,45% do valor homologado.

### Cuidados na interpretação

Os resultados representam exclusivamente
os registros tratados e carregados no banco
de dados deste projeto.

As concentrações financeiras identificadas
não demonstram, isoladamente, irregularidades.

Diferenças entre quantidade de itens e valores
homologados devem ser consideradas na
interpretação dos indicadores.

### Aplicação no Power BI

Os indicadores documentados poderão orientar:

- Cartões com valores e quantidades.
- Gráficos por modalidade de contratação.
- Comparações entre regiões e UFs.
- Ranking dos principais fornecedores.
- Análises por porte dos fornecedores.
- Ranking dos órgãos públicos.