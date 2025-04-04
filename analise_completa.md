# Limitações da Amostra de Dados

É importante considerar algumas limitações que esta amostra de dados apresenta:

- **Recorte temporal restrito**: Os dados analisados compreendem apenas os quatro primeiros meses de 2021 (janeiro a abril), o que não permite observar padrões sazonais completos ou tendências de longo prazo.
- **Contexto pandêmico**: O período analisado coincide com a segunda onda da pandemia de COVID-19 no Brasil, o que pode ter influenciado significativamente os padrões de consumo, operação logística e comportamento de entrega.
- **Ausência de dados comparativos interanuais**: Sem informações de períodos passados, não foi possível fazer comparações ano a ano para avaliar crescimento ou mudanças na operação.

# Análise Exploratória de Dados

## Volume e Status de Pedidos

Comecei minha exploração inicial buscando entender o volume de pedidos que o estabelecimento recebeu no período registrado.

```sql
-- Query 1
SELECT
    order_created_year AS ano,
    order_created_month AS mes,
    order_status AS status_pedido,
    COUNT(order_id) AS numero_pedidos
FROM
    orders
GROUP BY
    ano,
    mes,
    status_pedido
ORDER BY
    ano,
    mes,
    status_pedido;

```

**Resultado:**

| **ano** | **mes** | **status_pedido** | **numero_pedidos** |
| --- | --- | --- | --- |
| 2021 | 1 | CANCELED | 3254 |
| 2021 | 1 | FINISHED | 71773 |
| 2021 | 2 | CANCELED | 3262 |
| 2021 | 2 | FINISHED | 69653 |
| 2021 | 3 | CANCELED | 4991 |
| 2021 | 3 | FINISHED | 107232 |
| 2021 | 4 | CANCELED | 5472 |
| 2021 | 4 | FINISHED | 103362 |

**Comentário:**

Aqui notei a limitação de que o banco de dados só apresenta dados de 2021 e apenas até o mês de abril desse ano. Além disso, esta foi época de pandemia, o que pode ter afetado as operações, positivamente ou negativamente. Infelizmente não possuo os dados anteriores para comparar.

## Taxa de Conclusão de Pedidos

Em seguida, explorei a taxa de conclusão do total de pedidos.

```sql
-- Query 2
SELECT
    order_created_year AS ano,
    order_created_month AS mes,
    COUNT(order_id) AS total_pedidos,
    SUM(CASE WHEN order_status IN ('DELIVERED', 'FINISHED') THEN 1 ELSE 0 END) AS pedidos_concluidos,
    (SUM(CASE WHEN order_status IN ('DELIVERED', 'FINISHED') THEN 1 ELSE 0 END) * 100.0 / COUNT(order_id)) AS taxa_conclusao_percentual
FROM
    orders
GROUP BY
    ano,
    mes
ORDER BY
    ano,
    mes;
```

**Resultado:**

| **ano** | **mes** | **total_pedidos** | **pedidos_concluidos** | **taxa_conclusao_percentual** |
| --- | --- | --- | --- | --- |
| 2021 | 1 | 75027 | 71773 | 95.66289 |
| 2021 | 2 | 72915 | 69653 | 95.52630 |
| 2021 | 3 | 112223 | 107232 | 95.55261 |
| 2021 | 4 | 108834 | 103362 | 94.97216 |

**Comentário:**

A taxa de conclusão é relativamente alta, girando em torno dos 95% de todos os pedidos, o que indica uma boa eficiência operacional do processo.

## Tempos Operacionais do Ciclo de Pedido

Procurei entender como estão divididos os tempos durante todo o processo do pedido.

```sql
-- Query 3
SELECT
    AVG(order_metric_production_time) AS tempo_medio_producao,
    AVG(order_metric_collected_time) AS tempo_medio_coleta_apos_pronto,
    AVG(order_metric_walking_time) AS tempo_medio_deslocamento_entregador,
    AVG(orders.order_metric_expediton_speed_time) AS tempo_medio_espera_hub,
    AVG(order_metric_transit_time) AS tempo_medio_transito,
    AVG(order_metric_cycle_time) AS tempo_medio_ciclo_completo
FROM
    orders
WHERE
    order_status IN ('DELIVERED', 'FINISHED');
```

**Resultado:**

| **tempo_medio_producao** | **tempo_medio_coleta_apos_pronto** | **tempo_medio_deslocamento_entregador** | **tempo_medio_espera_hub** | **tempo_medio_transito** | **tempo_medio_ciclo_completo** |
| --- | --- | --- | --- | --- | --- |
| 61.71
 | 2.75 | 4.76 | 19.09 | 46.52 | 155.84 |

**Comentário:**

- O tempo médio de deslocamento e coleta do entregador é baixo
- O tempo médio de produção e de entrega corresponde à maior parte do ciclo, o que era esperado
- O ciclo de tempo neste dataset está em minutos, considerando que o tempo médio de entrega é em torno de 46,50 e o de coleta 2,7 (não faria sentido uma coleta demorar 2,7 horas em média, nem uma entrega ser feita em 46,5 segundos)

## Análise de Gargalos por Horário

Investigando o tempo mais a fundo, busquei por indícios de gargalos observando as variações ao longo do dia.

```sql
-- Query 4
SELECT
    order_created_hour AS hora_criacao,
    AVG(order_metric_production_time) AS tempo_medio_producao,
    AVG(order_metric_collected_time) AS tempo_medio_coleta_apos_pronto,
    AVG(order_metric_transit_time) AS tempo_medio_transito,
    AVG(order_metric_cycle_time) AS tempo_medio_ciclo_completo
FROM
    orders
WHERE
    order_status IN ('DELIVERED', 'FINISHED')
GROUP BY
    hora_criacao
ORDER BY
    hora_criacao;
```

**Resultado:** (24 linhas no total. A visualização completa está disponível nos arquivos do projeto.)

| **hora_criacao** | **tempo_medio_producao** | **tempo_medio_coleta_apos_pronto** | **tempo_medio_transito** | **tempo_medio_ciclo_completo** |
| --- | --- | --- | --- | --- |
| (…) |  |  |  |  |
| 2 | 659.81 | 8.97 | 109.06 | 1168.46 |
| 3 | 522.31 | 5.79 | 73.89 | 881.6 |
| 4 | 601.32 | 17.14 | 85.69 | 1068.71 |
| 5 | 902.87 | 8.06 | 182.3 | 1968.81 |
| 6 | 1283.3 | 17.75 | 177.31 | 2389.48 |
| 7 | 629.45 | 40.26 | 308.71 | 1647.71 |
| 8 | 853.5 | 25.89 | 328.59 | 2082.57 |
| 9 | 714.99 | 30.85 | 587.44 | 1965.74 |
| 10 | 677.75 | 52.0 | 226.38 | 1519.86 |
| 11 | 970.85 | 34.93 | 228.13 | 1792.96 |
| (…) |  |  |  |  |

**Comentário:**

Às 6 da manhã é quando o tempo médio de produção mais aumenta. Isso pode ocorrer por alguns motivos:

- Os pedidos feitos durante a madrugada, horário em que não estão sendo produzidos, passam a ser produzidos todos simultaneamente a partir das 6
- A quantidade de pedidos de delivery de comidas feitos durante o período das 4 às 11 da manhã é baixíssima, o que faz com que a maior parte sejam pedidos de serviços, que naturalmente possuem um tempo de entrega maior

## Comparação de Tempos entre Segmentos

Para verificar se de fato comida (FOOD) possui um ciclo de produção-entrega menor que serviços (GOOD):

```sql
-- Query 5
SELECT
    s.store_segment AS segmento_loja,
    COUNT(o.order_id) AS numero_pedidos,
    AVG(o.order_metric_production_time) AS tempo_medio_producao,
    AVG(o.order_metric_collected_time) AS tempo_medio_coleta_apos_pronto,
    AVG(o.order_metric_transit_time) AS tempo_medio_transito,
    AVG(o.order_metric_cycle_time) AS tempo_medio_ciclo_completo
FROM
    orders o
JOIN
    stores s ON o.store_id = s.store_id
WHERE
    o.order_status IN ('DELIVERED', 'FINISHED')
GROUP BY
    s.store_segment
ORDER BY
    s.store_segment;
```

**Resultado:**

| **segmento_loja** | **numero_pedidos** | **tempo_medio_producao** | **tempo_medio_coleta_apos_pronto** | **tempo_medio_transito** | **tempo_medio_ciclo_completo** |
| --- | --- | --- | --- | --- | --- |
| FOOD | 310814 | 17.51 | 2.1 | 38.33 | 66.79 |
| GOOD | 41206 | 416.08 | 10.11 | 114.11 | 828.59 |

**Comentário:**

*BINGO!* Confirmou-se que GOOD possui um ciclo muito maior que FOOD, como esperado.

## Distribuição de Pedidos por Segmento e Horário

```sql
-- Query 6: Conta o número de pedidos por hora do dia (apenas segmento FOOD)
SELECT
    o.order_created_hour AS hora_criacao,
    COUNT(o.order_id) AS numero_pedidos
FROM
    orders o
JOIN
    stores s ON o.store_id = s.store_id
WHERE
    o.order_status IN ('DELIVERED', 'FINISHED')
    AND s.store_segment = 'FOOD'
GROUP BY
    o.order_created_hour
ORDER BY
    hora_criacao;
```

**Resultado:** (24 linhas no total. A visualização do resultado completo está disponível nos arquivos do projeto.)

| **hora_criacao** | **numero_pedidos** |
| --- | --- |
| (…) |  |
| 2 | 560 |
| 3 | 427 |
| 4 | 123 |
| 5 | 109 |
| 6 | 65 |
| 7 | 1 |
| 8 | 1 |
| 9 | 4 |
| 10 | 3 |
| 11 | 11 |
| 12 | 83 |
| 13 | 1851 |
| (…) |  |

**Comentário:**

Os dados confirmam claramente minha hipótese anterior. Os altos tempos de produção durante o horário de 4h até 11h da manhã são causados pela diminuição dos pedidos de FOOD. Como comida é produzida rapidamente e serviços levam mais tempo, a diminuição no pedido de comidas faz o *tempo_medio_producao* subir consideravelmente.

## Eficiência por Hub

Investigando agora a eficiência média por hub:

```sql
-- Query 7
SELECT
    h.hub_name,
    h.hub_city,
    h.hub_state,
    COUNT(o.order_id) AS numero_pedidos,
    AVG(CASE WHEN o.order_status IN ('DELIVERED', 'FINISHED') THEN o.order_metric_cycle_time ELSE NULL END) AS tempo_medio_ciclo_concluidos,
    AVG(CASE WHEN o.order_status IN ('DELIVERED', 'FINISHED') THEN o.order_metric_transit_time ELSE NULL END) AS tempo_medio_transito_concluidos,
    (SUM(CASE WHEN o.order_status = 'CANCELLED' THEN 1 ELSE 0 END) * 100.0 / COUNT(o.order_id)) AS taxa_cancelamento_percentual
FROM
    orders o
JOIN
    stores s ON o.store_id = s.store_id
JOIN
    hubs h ON s.hub_id = h.hub_id
GROUP BY
    h.hub_id, h.hub_name, h.hub_city, h.hub_state
ORDER BY
    numero_pedidos DESC;

```

**Resultado:** (32 linhas no total. A visualização completa do resultado pode ser feita aqui.)

| **hub_name** | **hub_city** | **hub_state** | **numero_pedidos** | **tempo_medio_ciclo_concluidos** | **tempo_medio_transito_concluidos** | **taxa_cancelamento_percentual** |
| --- | --- | --- | --- | --- | --- | --- |
| (…) |  |  |  |  |  |  |
| ELIXIR SHOPPING | S�O PAULO | SP | 10249 | 3036.46 | 292.75 | 0.00000 |
| PHP SHOPPING | CURITIBA | PR | 4610 | 43.9 | 16.63 | 0.00000 |
| (…) |  |  |  |  |  |  |

**Comentário:**

Constatei que alguns hubs apresentam tempos médios de produção significativamente maiores em comparação com outros. No entanto, esse resultado pode estar distorcido da mesma forma que na análise anterior: o número de pedidos por tipo de serviço pode estar influenciando esse tempo.

## Influência do Segmento nos Tempos por Hub

```sql
-- Query 8
SELECT
    h.hub_name,
    s.store_segment,
    COUNT(o.order_id) AS numero_pedidos
FROM
    orders o
JOIN
    stores s ON o.store_id = s.store_id
JOIN
    hubs h ON s.hub_id = h.hub_id
WHERE
    o.order_status IN ('DELIVERED', 'FINISHED')
GROUP BY
    h.hub_name, s.store_segment
ORDER BY
    h.hub_name, s.store_segment;

```

**Resultado:** (53 linhas no total. A visualização completa do resultado pode ser feita aqui.)

| **hub_name** | **store_segment** | **numero_pedidos** |
| --- | --- | --- |
| (…) |  |  |
| ELIXIR SHOPPING | GOOD | 7090 |
| PHP SHOPPING | FOOD | 4307 |
| PHP SHOPPING | GOOD | 134 |
| (…) |  |  |

**Comentário:**

De fato, há novamente uma distorção por causa do tempo de produção diferente entre os tipos GOOD e FOOD. O ELIXIR SHOPPING, por exemplo, que possui um dos maiores tempos de entregas é, justamente, o que mais processa entregas do tipo GOOD (serviço). Já o PHP Shopping, que possui o menor tempo médio de ciclo, processa majoritariamente entregas do tipo FOOD.

# Análise de Rentabilidade

## Margem Bruta Geral

Saindo da parte do ciclo de entrega, analisei a rentabilidade do negócio:

```sql
-- Query 9
SELECT
    COUNT(*) AS total_pedidos,
    AVG(o.order_amount) AS ticket_medio,
    AVG(o.order_delivery_cost) AS custo_medio_entrega,
    AVG(p.payment_fee) AS taxa_media_pagamento,
    AVG(o.order_amount - COALESCE(o.order_delivery_cost, 0) - COALESCE(p.payment_fee, 0)) AS margem_bruta_media
FROM
    orders o
LEFT JOIN
    payments p ON o.payment_order_id = p.payment_order_id
WHERE
    o.order_status IN ('DELIVERED', 'FINISHED');

```

**Resultado:**

| **total_pedidos** | **ticket_medio** | **custo_medio_entrega** | **taxa_media_pagamento** | **margem_bruta_media** |
| --- | --- | --- | --- | --- |
| 402520 | 95.6 | 509.00 | 163.02 | -566.58 |

**Comentário:**
Aqui encontrei algo preocupante:

- A soma dos **custos diretos** (logística + taxa de pagamento) está **quase 7 vezes maior** que o valor que o cliente paga no pedido
- Esse padrão se mantém **em mais de 400 mil pedidos**, ou seja, não é um caso isolado — é sistêmico

É bem provável que a estrutura de custos está completamente incompatível com o modelo atual de receita. E mesmo que existam fontes adicionais de receita (como o `store_plan_price`), **elas precisariam ser muito altas e muito frequentes** para compensar esse prejuízo por unidade.

## Margem por Segmento

```sql
-- Query 10
SELECT
    s.store_segment,
    AVG(o.order_amount - COALESCE(o.order_delivery_cost, 0) - COALESCE(p.payment_fee, 0)) AS margem_bruta_estimada_media,
    AVG(o.order_amount) AS ticket_medio,
    AVG(o.order_delivery_cost) AS custo_medio_entrega,
    AVG(p.payment_fee) AS taxa_media_pagamento
FROM
    orders o
JOIN
    stores s ON o.store_id = s.store_id
LEFT JOIN
    payments p ON o.payment_order_id = p.payment_order_id
WHERE
    o.order_status IN ('DELIVERED', 'FINISHED')
GROUP BY
    s.store_segment;

```

**Resultado:**

| **store_segment** | **margem_bruta_estimada_media** | **ticket_medio** | **custo_medio_entrega** | **taxa_media_pagamento** |
| --- | --- | --- | --- | --- |
| GOOD | -842.01 | 218.79 | 784.13 | 305.15 |
| FOOD | -533.6 | 80.85 | 476.66 | 146.03 |

**Comentário:**

A análise por segmento revelou que:

- A margem do delivery do tipo FOOD (comida) é em torno de -R$533,60, enquanto a margem do tipo GOOD (serviço) é em torno de -R$842,01
- O segmento FOOD representa um prejuízo ligeiramente menor que o segmento GOOD, porém ainda é um segmento claramente deficitário
- O segmento GOOD, mesmo possuindo um **ticket médio quase 3x maior**, tem custo logístico e taxa de pagamento proporcionalmente mais elevados
- O prejuízo por pedido é **substancialmente maior** no segmento GOOD, indicando que entregar bens tem **muito menos eficiência unitária** do que entregar alimentos

## Impacto do Tempo de Ciclo na Rentabilidade

Usando CASE para separar o order_metric_cycle_time em faixas e Common Table Expression (WITH), analisei como a rentabilidade se comporta em cada faixa de tempo:

```sql
-- Query 11
WITH PedidosComMargem AS (
    SELECT
        o.order_id,
        o.order_metric_cycle_time AS tempo_ciclo_minutos,
        (o.order_amount - COALESCE(o.order_delivery_cost, 0) - COALESCE(p.payment_fee, 0)) AS margem_bruta_estimada
    FROM
        orders o
    LEFT JOIN
        payments p ON o.payment_order_id = p.payment_order_id
    WHERE
        o.order_status IN ('DELIVERED', 'FINISHED') AND o.order_metric_cycle_time IS NOT NULL
)
SELECT
    CASE
        WHEN tempo_ciclo_minutos <= 30 THEN '0-30 min'
        WHEN tempo_ciclo_minutos <= 60 THEN '31-60 min'
        WHEN tempo_ciclo_minutos <= 90 THEN '61-90 min'
        ELSE '> 90 min'
    END AS faixa_tempo_ciclo,
    COUNT(order_id) AS numero_pedidos,
    AVG(margem_bruta_estimada) AS margem_bruta_media
FROM
    PedidosComMargem
GROUP BY
    faixa_tempo_ciclo
ORDER BY
    MIN(tempo_ciclo_minutos);

```

**Resultado:**

| **faixa_tempo_ciclo** | **numero_pedidos** | **margem_bruta_media** |
| --- | --- | --- |
| 0-30 min | 74240 | -429.09 |
| 31-60 min | 248600 | -565.61 |
| 61-90 min | 45241 | -638.52 |
| > 90 min | 34016 | -782.06 |

**Comentário:**

- Pedidos concluídos **em até 30 minutos** geram menor prejuízo (–R$429,09)
- Já os que **ultrapassam 90 minutos** geram em média **quase o dobro de prejuízo** (–R$782,06)
- Existe uma **correlação direta** entre o tempo total do pedido e a **margem bruta negativa**
- Entretanto, mesmo em pedidos com ciclos de entrega curtos, ainda há uma margem bruta média negativa

## Impacto da Distância na Rentabilidade

```sql
-- Query 12
WITH PedidosComDistanciaMargem AS (
    SELECT
        o.order_id,
        d.delivery_distance_meters,
        (o.order_amount - COALESCE(o.order_delivery_cost, 0) - COALESCE(p.payment_fee, 0)) AS margem_bruta_estimada
    FROM
        orders o
    LEFT JOIN
        payments p ON o.payment_order_id = p.payment_order_id
    JOIN
        deliveries d ON o.delivery_order_id = d.delivery_order_id
    WHERE
        o.order_status IN ('DELIVERED', 'FINISHED') AND d.delivery_distance_meters IS NOT NULL
)
SELECT
    CASE
        WHEN delivery_distance_meters <= 1000 THEN '0-1 km'
        WHEN delivery_distance_meters <= 3000 THEN '1-3 km'
        WHEN delivery_distance_meters <= 5000 THEN '3-5 km'
        WHEN delivery_distance_meters <= 8000 THEN '5-8 km'
        ELSE '> 8 km'
    END AS faixa_distancia,
    COUNT(order_id) AS numero_pedidos,
    AVG(margem_bruta_estimada) AS margem_bruta_media,
    AVG(delivery_distance_meters) AS distancia_media_metros
FROM
    PedidosComDistanciaMargem
GROUP BY
    faixa_distancia
ORDER BY
    MIN(delivery_distance_meters);

```

**Resultado:**

| **faixa_distancia** | **numero_pedidos** | **margem_bruta_media** | **distancia_media_metros** |
| --- | --- | --- | --- |
| 0-1 km | 85284 | -185.69 | 603.0619 |
| 1-3 km | 208043 | -524.8 | 1888.1054 |
| 3-5 km | 84253 | -889.51 | 3860.6962 |
| 5-8 km | 29285 | -1014.44 | 6005.1722 |
| > 8 km | 14599 | -1273.01 | 143986.0761 |

**Comentário:**

A análise mostrou que:

- Quanto maior a distância, maior o prejuízo; a margem cai drasticamente conforme a distância aumenta
- O salto mais crítico acontece acima de 3 km, onde o prejuízo ultrapassa os **R$800 por pedido**
- Entregas com mais de 8 km geram prejuízo médio acima de **R$1.270** — um valor altíssimo
- Mesmo os pedidos dentro da faixa de apenas 1-3km apresentam margem negativa severa (–R$524,80)
- A faixa de 0-1 km, mesmo sendo curtíssima, ainda possui **R$–185,69** de prejuízo médio, sendo a **única faixa com impacto "menor"** — mas ainda negativa
- Essas entregas de curta distância poderiam ser priorizadas ou otimizadas para tentar se tornarem lucrativas

## Características dos Pedidos com Margem Negativa

```sql
-- Query 13
WITH MargemNegativa AS (
    SELECT
        o.order_amount,
        o.order_delivery_cost,
        p.payment_fee,
        (o.order_amount - COALESCE(o.order_delivery_cost, 0) - COALESCE(p.payment_fee, 0)) AS margem
    FROM
        orders o
    LEFT JOIN
        payments p ON o.payment_order_id = p.payment_order_id
    WHERE
        o.order_status IN ('DELIVERED', 'FINISHED')
        AND (o.order_amount - COALESCE(o.order_delivery_cost, 0) - COALESCE(p.payment_fee, 0)) < 0
)
SELECT
    AVG(order_amount) AS ticket_medio,
    AVG(order_delivery_cost) AS media_custo_entrega,
    AVG(payment_fee) AS media_taxa_pagamento
FROM
    MargemNegativa;

```

**Resultado:**

| **ticket_medio** | **media_custo_entrega** | **media_taxa_pagamento** |
| --- | --- | --- |
| 95.58 | 558.23 | 178.94 |

**Comentário:**

Neste resultado, podemos notar que os pedidos com prejuízo têm ticket médio (R$95,58) muito abaixo à soma dos custos médios (R$737,17). Ou seja, **um custo total 7,7 vezes maior que a receita** recebida.

- O custo logístico é o principal vilão
- O modelo de entrega atual é **inviável economicamente** para esse perfil de pedido
- O **valor cobrado dos clientes (ticket)** não cobre nem de longe os custos operacionais

## Características dos Pedidos com Margem Positiva

```sql
-- Query 14
WITH MargemPositiva AS (
    SELECT
        o.order_amount,
        o.order_delivery_cost,
        p.payment_fee,
        (o.order_amount - COALESCE(o.order_delivery_cost, 0) - COALESCE(p.payment_fee, 0)) AS margem
    FROM
        orders o
    LEFT JOIN
        payments p ON o.payment_order_id = p.payment_order_id
    WHERE
        o.order_status IN ('DELIVERED', 'FINISHED')
        AND (o.order_amount - COALESCE(o.order_delivery_cost, 0) - COALESCE(p.payment_fee, 0)) > 0
)
SELECT
    AVG(order_amount) AS ticket_medio,
    AVG(order_delivery_cost) AS media_custo_entrega,
    AVG(payment_fee) AS media_taxa_pagamento
FROM
    MargemPositiva;

```

**Resultado:**

| **ticket_medio** | **media_custo_entrega** | **media_taxa_pagamento** |
| --- | --- | --- |
| 95.92 | 16.30 | 9.71 |

**Comentário:**

Analisando os pedidos com margem positiva, constatei:

- **Ticket médio praticamente igual** aos de margem negativa
    - Ou seja, **não é a receita que muda**, é o **custo que define o prejuízo ou lucro**
- Custo de entrega despenca nos pedidos com margem positiva
    - De R$558 para apenas R$16 → uma diferença de mais de **3.300%**
- Mostra que pedidos rentáveis são **casos extremamente raros e específicos**, provavelmente:
    - **entregas curtíssimas (0–1 km)**
    - **pedidos que não envolveram logística**
    - ou **transações com retirada local**
- **Taxa de pagamento também muito mais baixa**
    - De R$178 para R$9 → indica que **provavelmente foram feitos com métodos de pagamento mais baratos** (ex: PIX, dinheiro)
    - Pode também indicar **pedidos internos, testes ou exceções**

## Impacto das Taxas de Pagamento na Rentabilidade

```sql
-- Query 15
WITH Margens AS (
    SELECT
        (o.order_amount - COALESCE(o.order_delivery_cost, 0) - COALESCE(p.payment_fee, 0)) AS margem,
        CASE WHEN p.payment_fee IS NULL THEN 'Sem taxa' ELSE 'Com taxa' END AS tipo_taxa
    FROM
        orders o
    LEFT JOIN
        payments p ON o.payment_order_id = p.payment_order_id
    WHERE
        o.order_status IN ('DELIVERED', 'FINISHED')
)
SELECT
    tipo_taxa,
    COUNT(*) AS numero_pedidos,
    AVG(margem) AS media_margem
FROM
    Margens
GROUP BY
    tipo_taxa;

```

**Resultado:**

| **tipo_taxa** | **numero_pedidos** | **media_margem** |
| --- | --- | --- |
| Com taxa | 400651 | -567.71 |
| Sem taxa | 1869 | -326.06 |

**Comentário:**

- Pedidos com taxa de pagamento têm impacto financeiro significativamente pior, com média de –R$567 por pedido, contra –R$326 nos pedidos isentos de taxa
- Embora as taxas sejam um agravante importante, mesmo os pedidos sem taxa ainda operam no prejuízo, indicando que os custos logísticos são o principal gargalo de rentabilidade

# Conclusões

### O modelo atual é estruturalmente deficitário

- A **margem bruta média** é **altamente negativa** (–R$566)
- Mesmo os pedidos **entregues com sucesso** estão gerando **prejuízo unitário elevado**
- Não é uma questão de **cancelamento**, falhas ou devoluções
- Esse prejuízo é **consistente em todas as faixas** de tempo, distância, canal e segmento

### O custo logístico é o principal vilão

- Entregas com mais de 3 km resultam em **prejuízos superiores a R$800 por pedido**
- O custo médio de entrega nos pedidos com prejuízo é de **R$558**, contra apenas **R$16** nos poucos pedidos lucrativos
- Pedidos com margem positiva são exceção e ocorrem praticamente **só em entregas ultracurtas ou sem entrega**

### Taxas de pagamento agravam ainda mais o prejuízo

- Pedidos com taxas têm margem média 70% mais negativa do que os sem taxa
- A média da taxa nos pedidos com prejuízo é de **R$178**, contra apenas **R$9** nos positivos
- **Mesmo sem a taxa**, o negócio **continua deficitário**, o que confirma que o problema é maior do que apenas o meio de pagamento

### O segmento FOOD é o menos pior, mas ainda deficitário

- Embora represente a **maior parte do volume (359 mil pedidos)**, o FOOD ainda tem prejuízo médio de **–R$533**
- O segmento GOOD tem ticket mais alto, mas custos muito maiores, gerando prejuízo médio de **–R$842**

### Tempo de ciclo longo piora a margem

- Pedidos concluídos em até 30 min têm prejuízo médio de **–R$429**
- Pedidos acima de 90 min geram prejuízo de **–R$782**, confirmando que **ineficiência operacional afeta fortemente a rentabilidade**

### Pedidos de longa distância são economicamente inviáveis

- Pedidos acima de 5 km geram prejuízos médios acima de **R$1.000**
- Mesmo pedidos entre 1–3 km já são fortemente negativos (–R$524)
- Somente a faixa de **0–1 km** tem impacto mais controlado (–R$185), ainda que negativo

### Ticket médio está estagnado e insuficiente

- O ticket médio gira em torno de **R$95**, mesmo nos pedidos positivos
- Isso reforça que **não há espaço suficiente de margem** nesse modelo com os custos atuais

### Conclusão final: o modelo de negócio não se sustenta

- A operação depende de **custos fixos altos (entrega + taxas)** para pedidos com **ticket médio baixo**
- **Mesmo entregando com sucesso, o negócio perde dinheiro por pedido**
- Não há sinal de escala resolvendo isso — o problema é **estrutural**, não pontual

# Recomendações

### Imposição de limite geográfico nas entregas

Restringir o raio de operação a um máximo de 2 km pode reduzir drasticamente os custos logísticos, uma vez que entregas acima dessa faixa geram prejuízos superiores a R$800 por unidade.

### Revisão da política de frete

Considerar a cobrança total ou parcial do custo de entrega ao consumidor final, especialmente em distâncias superiores a 1 km, é essencial para equilibrar o custo unitário do pedido.

### Incentivo ao uso de meios de pagamento com menor taxa

Estimular o uso de pagamentos com menor taxa (ex: PIX ou dinheiro) pode reduzir em mais de R$150 o prejuízo médio por pedido, conforme evidenciado nos dados.

### Segmentação de atuação com base em rentabilidade

O segmento FOOD, apesar de deficitário, apresenta desempenho melhor que o segmento GOOD. Considerar a priorização ou até descontinuidade de operações com produtos GOOD pode reduzir perdas estruturais.

### Análise individual de lojistas com alto prejuízo acumulado

Lojistas com margens extremamente negativas, mesmo com alto volume de pedidos, devem ser reavaliados em termos de política de planos, subsídios ou permanência na plataforma.

### Ajustes nos planos pagos por lojistas

Caso o valor de store_plan_price esteja sendo subestimado como fonte de receita, é recomendável revisar sua aplicação proporcional ao volume de pedidos processados.

### Reestruturação do modelo de precificação

Estabelecer um valor mínimo por pedido ou por faixa de distância pode evitar a operação de pedidos cujo custo fixo inviabiliza a margem.

# Considerações Técnicas

## Escolha da linguagem

- O uso do Python traria a opção de gerar gráficos e análises estatísticas mais avançadas. Já o Power BI possibilitaria uma comunicação visual eficiente, visualização interativa e gráficos para trazer impacto visual, permitindo a criação de um dashboard para os stakeholders que não são técnicos.
- Escolhi o SQL por quatro motivos:
    1. Para aprender mais e testar meu conhecimento de modelagem de dados relacionais
    2. Explorar as potencialidades da linguagem para este tipo de análise
    3. Por julgar que o SQL seria melhor devido ao banco possuir muitas tabelas relacionadas
    4. Pela alta escalabilidade do SQL e quantidade de dados no banco
- Futuramente, posso complementar a análise trazendo visualizações gráficas utilizando Tableau ou Power BI.

## Dificuldade

- Este projeto me permitiu aprofundar meu conhecimento em SQL, especialmente no uso de técnicas como Common Table Expressions (CTE) e estruturas condicionais (CASE WHEN) para segmentação e análise de dados complexos.
- Considerei que o nível de dificuldade do projeto foi mediano, principalmente na parte de formular algumas queries mais complexas. Mas no geral foi bem proveitoso e recompensador descobrir o problema na rentabilidade e ver algumas hipóteses sendo comprovadas durante as análises.
