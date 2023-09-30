WITH tb_activeSellers AS(

    SELECT
        idVendedor,
        min(DATE(dtPedido)) as minDtPedido  

    FROM pedido AS t1

    LEFT JOIN item_pedido AS t2
    ON t1.idPedido = t2.idPedido

    WHERE t1.dtPedido >= '2018-01-01'
    AND t1.dtPedido < '2018-03-01'
    AND idVendedor IS NOT NULL

    GROUP BY 1
)

