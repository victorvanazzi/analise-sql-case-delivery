![SQL](https://img.shields.io/badge/SQL-MySQL-informational)
![DBeaver](https://img.shields.io/badge/Tool-DBeaver-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Dataset](https://img.shields.io/badge/data-Kaggle-lightgrey)


# Análise de Rentabilidade e Eficiência Logística com SQL — Delivery Center

<img src="https://github.com/user-attachments/assets/669a3200-ff27-46c6-9eea-61d25de4a4d5" width="400"/>

## Visão Geral do Projeto

Este projeto consiste em uma análise aprofundada da operação logística e rentabilidade do Delivery Center, uma plataforma brasileira de entregas, durante o período de janeiro a abril de 2021. Utilizando SQL com MySQL através do DBeaver, examinei um conjunto de dados públicos disponível no Kaggle para identificar gargalos operacionais, avaliar desempenho financeiro e propor soluções para os problemas encontrados.



## Ferramentas Utilizadas

- SQL (MySQL)
- DBeaver (ambiente de execução)
- Dados públicos do [Kaggle](https://www.kaggle.com/)
- Markdown para documentação
- Git & GitHub para versionamento



## Objetivos

- Analisar o ciclo operacional dos pedidos e identificar possíveis gargalos
- Avaliar a performance dos diferentes hubs e segmentos de lojas
- Determinar os fatores que impactam a rentabilidade
- Encontrar oportunidades para melhorar a operação e as finanças



## Metodologia

A análise foi estruturada em duas partes principais:

1. **Análise Exploratória Operacional**: Investigação dos volumes de pedidos, taxas de conclusão, tempos de ciclo e eficiência por segmento e hub.
2. **Análise de Rentabilidade**: Exame detalhado das margens brutas, custos logísticos e impactos de variáveis como distância, tempo de ciclo e taxas de pagamento.



## Principais Descobertas

- O modelo de negócios apresenta um problema estrutural de rentabilidade, com margem bruta média altamente negativa (–R$566)
- O custo logístico é o principal fator de prejuízo, especialmente em entregas com mais de 3km
- Entregas de curta distância (0–1km) apresentam melhor desempenho financeiro, embora ainda deficitárias
- O segmento FOOD tem desempenho menos negativo que o GOOD, apesar de ambos serem deficitários
- Tempo de ciclo prolongado está diretamente correlacionado com piora na margem financeira
- Taxas de pagamento agravam significativamente o prejuízo operacional



## Recomendações

Com base nas análises, as principais recomendações incluem:

- Limitar a distância das entregas poderia ajudar a reduzir os custos logísticos
- Revisar a política de frete, considerando repassar total ou parcialmente o custo ao consumidor
- Incentivar meios de pagamento com menores taxas (PIX, dinheiro)
- Priorizar o segmento FOOD, com possível reavaliação da operação no segmento GOOD
- Analisar individualmente lojistas com alto prejuízo acumulado
- Reestruturar o modelo de precificação com valores mínimos por pedido ou faixa de distância



## Estrutura do Repositório

- `README.md` → Visão geral do projeto
- `dicionario_dados.md` → Dicionário de dados com descrição das tabelas e colunas
- `analise_completa.md` → Documento com todas as análises detalhadas
- `sql_queries/` → Scripts SQL utilizados nas análises
- `resultados/` → Tabelas e prints dos resultados
- `img/` → Imagens utilizadas no README
- `dados/` → Dados originais 
