CREATE TABLE abt_olist_churn AS

WITH tb_features AS (
    SELECT 
        t1.dtReference,
        t1.idVendedor,
        t1.qtdPedidos,
        t1.qtdDiasComPedidos,
        t1.qtItens,
        t1.ticketMedio,
        t1.avgValorProduto,
        t1.maxValorProduto,
        t1.minValorProduto,
        t1.avgProdutoPorPedido,
        t1.lifeTimeValue,
        t1.qtdDiasPrimeiraVenda,
        t1.qtdRecenciaVenda,
        t1.avgIntervaloVendas,

        t2.avgNota,
        t2.minNota,
        t2.maxNota,
        t2.pctAvaliacao,

        t3.qtdUFsDistintos,
        t3.pctPedidoAC,
        t3.pctPedidoAL,
        t3.pctPedidoAM,
        t3.pctPedidoAP,
        t3.pctPedidoBA,
        t3.pctPedidoCE,
        t3.pctPedidoDF,
        t3.pctPedidoES,
        t3.pctPedidoGO,
        t3.pctPedidoMA,
        t3.pctPedidoMG,
        t3.pctPedidoMS,
        t3.pctPedidoMT,
        t3.pctPedidoPA,
        t3.pctPedidoPB,
        t3.pctPedidoPE,
        t3.pctPedidoPI,
        t3.pctPedidoPR,
        t3.pctPedidoRJ,
        t3.pctPedidoRN,
        t3.pctPedidoRO,
        t3.pctPedidoRR,
        t3.pctPedidoRS,
        t3.pctPedidoSC,
        t3.pctPedidoSE,
        t3.pctPedidoSP,
        t3.pctPedidoTO,

        t4.pctPedidoCancelado,
        t4.pctPedidosAtrasados,
        t4.avgFrete,
        t4.maxFrete,
        t4.minFrete,
        t4.avgDifDiasEntregaAprovado,
        t4.avgDifDiasEntregaEstimativa,

        t5.qtde_credit_card_pedido,
        t5.qtde_boleto_pedido,
        t5.qtde_debit_card_pedido,
        t5.qtde_voucher_pedido,
        t5.valor_credit_card_pedido,
        t5.valor_boleto_pedido,
        t5.valor_debit_card_pedido,
        t5.valor_voucher_pedido,
        t5.pct_qtd_credit_card_pedido,
        t5.pct_qtd_boleto_pedido,
        t5.pct_qtd_debit_card_pedido,
        t5.pct_qtd_voucher_pedido,
        t5.pct_valor_credit_card_pedido,
        t5.pct_valor_boleto_pedido,
        t5.pct_valor_debit_card_pedido,
        t5.pct_valor_voucher_pedido,
        t5.avgQtdParcelas,
        t5.maxQtdParcelas,
        t5.minQtdParcelas,

        t6.qtdCategoriasVendedor,
        t6.avgFotosVendedor,
        t6.avgPesoGramas,
        t6.avgVolProduto,
        t6.minVolProduto,
        t6.maxVolProduto,
        t6.pctCategoria_cama_mesa_banho,
        t6.pctCategoria_beleza_saude,
        t6.pctCategoria_esporte_lazer,
        t6.pctCategoria_informatica_acessorios,
        t6.pctCategoria_moveis_decoracao,
        t6.pctCategoria_utilidades_domesticas,
        t6.pctCategoria_relogios_presentes,
        t6.pctCategoria_telefonia,
        t6.pctCategoria_automotivo,
        t6.pctCategoria_brinquedos,
        t6.pctCategoria_cool_stuff,
        t6.pctCategoria_ferramentas_jardim,
        t6.pctCategoria_perfumaria,
        t6.pctCategoria_bebes,
        t6.pctCategoria_eletronico,
        t6.pctSalesOnTop15Category

    FROM fs_vendedor_vendas AS t1

    LEFT JOIN fs_vendedor_avaliacao AS t2
    ON t1.idVendedor = t2.idVendedor
    AND t1.dtReference = t2.dtReference

    LEFT JOIN fs_vendedor_clientes AS t3
    ON t1.idVendedor = t3.idVendedor
    AND t1.dtReference = t3.dtReference

    LEFT JOIN fs_vendedor_entrega AS t4
    ON t1.idVendedor = t4.idVendedor
    AND t1.dtReference = t4.dtReference

    LEFT JOIN fs_vendedor_pagamentos AS t5
    ON t1.idVendedor = t5.idVendedor
    AND t1.dtReference = t5.dtReference

    LEFT JOIN fs_vendedor_produtos AS t6
    ON t1.idVendedor = t6.idVendedor
    AND t1.dtReference = t6.dtReference

    WHERE t1.qtdRecenciaVenda <= 45
    AND  strftime('%d', t1.dtReference) = '01'

),

tb_event AS (
  SELECT distinct idVendedor,
         date(dtPedido) as dtPedido

  FROM item_pedido AS t1

  LEFT JOIN pedido AS t2
  ON t1.idPedido = t2.idPedido

  WHERE idVendedor IS NOT NULL
),

tb_flag AS (

  SELECT t1.dtReference,
        t1.idVendedor,
        min(t2.dtPedido) as dtProxPedido

  FROM tb_features AS t1

  LEFT JOIN tb_event AS t2
  ON t1.idVendedor = t2.idVendedor
  AND t1.dtReference <= t2.dtPedido
  AND JULIANDAY(dtPedido) - JULIANDAY(dtReference) <= 45 - qtdRecenciaVenda

  GROUP BY 1,2

)

SELECT t1.*,
       CASE WHEN dtProxPedido IS NULL THEN 1 ELSE 0 END AS flChurn

FROM tb_features AS t1

LEFT JOIN tb_flag AS t2
ON t1.idVendedor = t2.idVendedor
AND t1.dtReference = t2.dtReference

ORDER BY t1.idVendedor, t1.dtReference