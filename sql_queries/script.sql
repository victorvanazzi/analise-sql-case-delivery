USE delivery_center

-- Query 1: Volume de Pedidos por Mês/Ano e Status
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

-- Query 2: Taxa de Conclusão de Pedidos por Mês/Ano
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

-- Query 3: Tempo Médio por Etapa Operacional (Geral)
SELECT
    ROUND(AVG(order_metric_production_time), 2) AS tempo_medio_producao,
    ROUND(AVG(order_metric_collected_time), 2) AS tempo_medio_coleta_apos_pronto,
    ROUND(AVG(order_metric_walking_time), 2) AS tempo_medio_deslocamento_entregador,
    ROUND(AVG(order_metric_expediton_speed_time), 2) AS tempo_medio_espera_hub,
    ROUND(AVG(order_metric_transit_time), 2) AS tempo_medio_transito,
    ROUND(AVG(order_metric_cycle_time), 2) AS tempo_medio_ciclo_completo
FROM
    orders
WHERE
    order_status IN ('DELIVERED', 'FINISHED');

-- Query 4: Tempo Médio por Etapa Operacional (Por Hora do Dia)
SELECT
    order_created_hour AS hora_criacao,
    ROUND(AVG(order_metric_production_time), 2) AS tempo_medio_producao,
    ROUND(AVG(order_metric_collected_time), 2) AS tempo_medio_coleta_apos_pronto,
    ROUND(AVG(order_metric_transit_time), 2) AS tempo_medio_transito,
    ROUND(AVG(order_metric_cycle_time), 2) AS tempo_medio_ciclo_completo
FROM
    orders
WHERE
    order_status IN ('DELIVERED', 'FINISHED')
GROUP BY
    order_created_hour
ORDER BY
    order_created_hour;

-- Query 5: Eficiência Média por Segmento da Loja
SELECT
    s.store_segment AS segmento_loja,
    COUNT(o.order_id) AS numero_pedidos,
    ROUND(AVG(o.order_metric_production_time), 2) AS tempo_medio_producao,
    ROUND(AVG(o.order_metric_collected_time), 2) AS tempo_medio_coleta_apos_pronto,
    ROUND(AVG(o.order_metric_transit_time), 2) AS tempo_medio_transito,
    ROUND(AVG(o.order_metric_cycle_time), 2) AS tempo_medio_ciclo_completo
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

-- Query 7: Eficiência Média por Hub
SELECT
    h.hub_name,
    h.hub_city,
    h.hub_state,
    COUNT(o.order_id) AS numero_pedidos,
    ROUND(AVG(CASE WHEN o.order_status IN ('DELIVERED', 'FINISHED') THEN o.order_metric_cycle_time ELSE NULL END), 2) AS tempo_medio_ciclo_concluidos,
    ROUND(AVG(CASE WHEN o.order_status IN ('DELIVERED', 'FINISHED') THEN o.order_metric_transit_time ELSE NULL END), 2) AS tempo_medio_transito_concluidos,
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

-- Query 8: Conta a quantidade de pedidos por hub e segmento da loja
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

-- Query 9: Média, Mediana e Distribuição de Margem
SELECT
    COUNT(*) AS total_pedidos,
    ROUND(AVG(o.order_amount), 2) AS ticket_medio,
    ROUND(AVG(o.order_delivery_cost), 2) AS custo_medio_entrega,
    ROUND(AVG(p.payment_fee), 2) AS taxa_media_pagamento,
    ROUND(AVG(o.order_amount - COALESCE(o.order_delivery_cost, 0) - COALESCE(p.payment_fee, 0)), 2) AS margem_bruta_media
FROM
    orders o
LEFT JOIN
    payments p ON o.payment_order_id = p.payment_order_id
WHERE
    o.order_status IN ('DELIVERED', 'FINISHED');

-- Query 10: Margem Bruta Média por Segmento da Loja
SELECT
    s.store_segment,
    ROUND(AVG(o.order_amount - COALESCE(o.order_delivery_cost, 0) - COALESCE(p.payment_fee, 0)), 2) AS margem_bruta_estimada_media,
    ROUND(AVG(o.order_amount), 2) AS ticket_medio,
    ROUND(AVG(o.order_delivery_cost), 2) AS custo_medio_entrega,
    ROUND(AVG(p.payment_fee), 2) AS taxa_media_pagamento
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

-- Query 11: Margem Bruta Média por Faixa de Tempo de Ciclo (sem conversão)
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
    ROUND(AVG(margem_bruta_estimada), 2) AS margem_bruta_media
FROM
    PedidosComMargem
GROUP BY
    faixa_tempo_ciclo
ORDER BY
    MIN(tempo_ciclo_minutos);

-- Query 12: Margem Bruta Média por Faixa de Distância de Entrega
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
    ROUND(AVG(margem_bruta_estimada), 2) AS margem_bruta_media,
    AVG(delivery_distance_meters) AS distancia_media_metros
FROM
    PedidosComDistanciaMargem
GROUP BY
    faixa_distancia
ORDER BY
    MIN(delivery_distance_meters);

-- Query 13: Calcula ticket médio, custo médio de entrega e taxa média dos pedidos com margem bruta negativa
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
    ROUND(AVG(order_amount), 2) AS ticket_medio,
    ROUND(AVG(order_delivery_cost), 2) AS media_custo_entrega,
    ROUND(AVG(payment_fee), 2) AS media_taxa_pagamento
FROM
    MargemNegativa;

-- Query 14: Métricas dos pedidos com margem bruta positiva
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
    ROUND(AVG(order_amount), 2) AS ticket_medio,
    ROUND(AVG(order_delivery_cost), 2) AS media_custo_entrega,
    ROUND(AVG(payment_fee), 2) AS media_taxa_pagamento
FROM
    MargemPositiva;

-- Query 15: Compara a margem média dos pedidos com e sem taxa de pagamento
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
    ROUND(AVG(margem), 2) AS media_margem
FROM
    Margens
GROUP BY
    tipo_taxa;


