SELECT
    descCategoria,
    count(DISTINCT idPedido)

FROM item_pedido as t2

    LEFT JOIN produto as t3
    on t2.idProduto = t3.idProduto

    AND t2.idVendedor is NOT NULL

    GROUP BY descCategoria
    ORDER BY 2 DESC
    