# Dicionário de Dados — Delivery Center

Este dicionário apresenta as tabelas e colunas disponíveis na base de dados utilizada neste projeto, com breves descrições de seu conteúdo e finalidade.

------

## Tabela: `orders`

> Informações sobre as vendas processadas através da plataforma do Delivery Center.

| Coluna                               | Descrição                                         |
| ------------------------------------ | ------------------------------------------------- |
| `order_id`                           | Identificador único do pedido                     |
| `store_id`                           | ID da loja que realizou a venda                   |
| `channel_id`                         | ID do canal (marketplace) onde o pedido foi feito |
| `payment_order_id`                   | ID da transação de pagamento associada            |
| `delivery_order_id`                  | ID do pedido de entrega                           |
| `order_status`                       | Status atual do pedido (ex: FINISHED, CANCELLED)  |
| `order_amount`                       | Valor total pago pelo cliente                     |
| `order_delivery_fee`                 | Valor da taxa de entrega cobrada do cliente       |
| `order_delivery_cost`                | Custo real da entrega para o Delivery Center      |
| `order_created_hour`                 | Hora em que o pedido foi criado                   |
| `order_created_minute`               | Minuto em que o pedido foi criado                 |
| `order_created_day`                  | Dia da criação do pedido                          |
| `order_created_month`                | Mês da criação do pedido                          |
| `order_created_year`                 | Ano da criação do pedido                          |
| `order_moment_created`               | Timestamp da criação do pedido                    |
| `order_moment_accepted`              | Timestamp de aceite do pedido                     |
| `order_moment_ready`                 | Pedido pronto para coleta                         |
| `order_moment_collected`             | Pedido coletado pelo entregador                   |
| `order_moment_in_expedition`         | Pedido aguardando expedição                       |
| `order_moment_delivering`            | Pedido em rota de entrega                         |
| `order_moment_delivered`             | Entrega concluída                                 |
| `order_moment_finished`              | Pedido finalizado no sistema                      |
| `order_metric_collected_time`        | Tempo até o pedido ser coletado                   |
| `order_metric_paused_time`           | Tempo em que o pedido ficou pausado               |
| `order_metric_production_time`       | Tempo de preparação do pedido                     |
| `order_metric_walking_time`          | Tempo de deslocamento do entregador               |
| `order_metric_expedition_speed_time` | Tempo de espera na expedição                      |
| `order_metric_transit_time`          | Tempo em trânsito                                 |
| `order_metric_cycle_time`            | Tempo total do ciclo do pedido                    |

------

## Tabela: `hubs`

> Centros de distribuição dos pedidos — de onde saem as entregas.

| Coluna          | Descrição                         |
| --------------- | --------------------------------- |
| `hub_id`        | Identificador único do hub        |
| `hub_name`      | Nome do hub                       |
| `hub_city`      | Cidade onde o hub está localizado |
| `hub_state`     | Estado do hub                     |
| `hub_latitude`  | Latitude geográfica               |
| `hub_longitude` | Longitude geográfica              |

------

## Tabela: `stores`

> Informações sobre os lojistas que utilizam a plataforma.

| Coluna             | Descrição                            |
| ------------------ | ------------------------------------ |
| `store_id`         | Identificador único da loja          |
| `hub_id`           | Hub ao qual a loja está associada    |
| `store_name`       | Nome da loja                         |
| `store_segment`    | Segmento (ex: FOOD ou GOOD)          |
| `store_plan_price` | Plano comercial contratado pela loja |
| `store_latitude`   | Latitude geográfica                  |
| `store_longitude`  | Longitude geográfica                 |

------

## Tabela: `channels`

> Canais de venda (marketplaces).

| Coluna         | Descrição                            |
| -------------- | ------------------------------------ |
| `channel_id`   | ID do canal de venda                 |
| `channel_name` | Nome do canal (ex: iFood, Rappi)     |
| `channel_type` | Tipo de canal (ex: app, web, físico) |

------

## Tabela: `payments`

> Informações sobre os pagamentos realizados ao Delivery Center.

| Coluna             | Descrição                           |
| ------------------ | ----------------------------------- |
| `payment_id`       | ID do pagamento                     |
| `payment_order_id` | ID do pedido vinculado ao pagamento |
| `payment_amount`   | Valor total pago pelo cliente       |
| `payment_fee`      | Taxa de processamento cobrada       |
| `payment_method`   | Meio de pagamento utilizado         |
| `payment_status`   | Status da transação                 |

------

## Tabela: `drivers`

> Entregadores parceiros responsáveis pela logística final.

| Coluna         | Descrição                             |
| -------------- | ------------------------------------- |
| `driver_id`    | ID do entregador                      |
| `driver_modal` | Modal de transporte (ex: moto, bike)  |
| `driver_type`  | Tipo de entregador (fixo, freelancer) |

------

## Tabela: `deliveries`

> Informações sobre as entregas realizadas pelos entregadores.

| Coluna                     | Descrição                           |
| -------------------------- | ----------------------------------- |
| `delivery_id`              | ID da entrega                       |
| `delivery_order_id`        | ID do pedido relacionado            |
| `driver_id`                | ID do entregador                    |
| `delivery_distance_meters` | Distância percorrida na entrega (m) |
| `delivery_status`          | Status da entrega                   |

