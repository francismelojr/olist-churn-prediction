WITH tb_pedidos AS(
SELECT 
    DISTINCT
    t1.idPedido,
    t2.idVendedor

FROM pedido AS t1

LEFT JOIN item_pedido as t2
on t1.idPedido = t2.idPedido

WHERE t1.dtPedido < DATE('{date}')
AND t1.dtPedido >= DATE('{date}', '-7 months')
AND idVendedor IS NOT NULL
),

tb_join as (

SELECT t1.idVendedor,
        t2.*

FROM tb_pedidos as t1

LEFT JOIN pagamento_pedido as t2

ON t1.idPedido = t2.idPedido
),

tb_group AS (

SELECT idVendedor, descTipoPagamento,
COUNT(DISTINCT idPedido) as qtdTipoPagamento,
SUM(vlPagamento) as vlTipoPagamento

FROM tb_join
GROUP BY idVendedor, descTipoPagamento
),

tb_summary as

(SELECT idVendedor,

sum(CASE WHEN descTipoPagamento = 'credit_card' 
        THEN qtdTipoPagamento 
        ELSE 0 end) as qtde_credit_card_pedido,

sum(CASE WHEN descTipoPagamento = 'boleto' 
        THEN qtdTipoPagamento 
        ELSE 0 end) as qtde_boleto_pedido,

sum(CASE WHEN descTipoPagamento = 'debit_card' 
        THEN qtdTipoPagamento 
        ELSE 0 end) as qtde_debit_card_pedido,

sum(CASE WHEN descTipoPagamento = 'voucher' 
        THEN qtdTipoPagamento 
        ELSE 0 end) as qtde_voucher_pedido,

------------------------------------------------------------------------------------

sum(CASE WHEN descTipoPagamento = 'credit_card' 
        THEN vlTipoPagamento 
        ELSE 0 end) as valor_credit_card_pedido,

sum(CASE WHEN descTipoPagamento = 'boleto' 
        THEN vlTipoPagamento 
        ELSE 0 end) as valor_boleto_pedido,

sum(CASE WHEN descTipoPagamento = 'debit_card' 
        THEN vlTipoPagamento 
        ELSE 0 end) as valor_debit_card_pedido,

sum(CASE WHEN descTipoPagamento = 'voucher' 
        THEN vlTipoPagamento 
        ELSE 0 end) as valor_voucher_pedido,

------------------------------------------------------------------------------------

sum(CASE WHEN descTipoPagamento = 'credit_card' 
        THEN qtdTipoPagamento 
        ELSE 0 end) * 1.0 / sum(qtdTipoPagamento) as pct_qtd_credit_card_pedido,

sum(CASE WHEN descTipoPagamento = 'boleto' 
        THEN qtdTipoPagamento 
        ELSE 0 end) * 1.0 / sum(qtdTipoPagamento) as pct_qtd_boleto_pedido,

sum(CASE WHEN descTipoPagamento = 'debit_card' 
        THEN qtdTipoPagamento 
        ELSE 0 end) * 1.0 / sum(qtdTipoPagamento) as pct_qtd_debit_card_pedido,

sum(CASE WHEN descTipoPagamento = 'voucher' 
        THEN qtdTipoPagamento 
        ELSE 0 end) * 1.0 / sum(qtdTipoPagamento) as pct_qtd_voucher_pedido,

------------------------------------------------------------------------------------

sum(CASE WHEN descTipoPagamento = 'credit_card' 
        THEN vlTipoPagamento 
        ELSE 0 end) / sum(vlTipoPagamento) as pct_valor_credit_card_pedido,

sum(CASE WHEN descTipoPagamento = 'boleto' 
        THEN vlTipoPagamento 
        ELSE 0 end) / sum(vlTipoPagamento) as pct_valor_boleto_pedido,

sum(CASE WHEN descTipoPagamento = 'debit_card' 
        THEN vlTipoPagamento 
        ELSE 0 end) / sum(vlTipoPagamento) as pct_valor_debit_card_pedido,

sum(CASE WHEN descTipoPagamento = 'voucher' 
        THEN vlTipoPagamento 
        ELSE 0 end) / sum(vlTipoPagamento) as pct_valor_voucher_pedido

from tb_group

GROUP BY idVendedor),

tb_cartao AS (
SELECT
        idVendedor,
        AVG(nrParcelas) as avgQtdParcelas,
        MAX(nrParcelas) as maxQtdParcelas,
        MIN(nrParcelas) as minQtdParcelas
        FROM tb_join
        WHERE descTipoPagamento = "credit_card"
        GROUP BY idVendedor
)

SELECT 
        '{date}' AS dtReference,
        date('now') AS dtIngestion,
        t1.*,
        t2.avgQtdParcelas,
        t2.maxQtdParcelas,
        t2.minQtdParcelas

 FROM tb_summary as t1

LEFT JOIN tb_cartao as t2

ON t1.idVendedor = t2.idVendedor