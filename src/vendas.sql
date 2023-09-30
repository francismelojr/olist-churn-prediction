WITH tb_join AS(

    SELECT t1.dtPedido, t2.*
        FROM pedido as t1
        LEFT JOIN item_pedido as t2
        ON t1.idPedido = t2.idPedido

        WHERE t1.dtPedido < '2018-01-01'
        AND t1.dtPedido >= '2017-06-01'
        AND t2.idVendedor IS NOT NULL

),

tb_summary AS (

    SELECT
        idVendedor,
        COUNT(DISTINCT idPedido) AS qtdPedidos,
        COUNT(DISTINCT date(dtPedido)) AS qtdDiasComPedidos,
        COUNT(DISTINCT idProduto) AS qtItens,
        SUM(vlPreco) / COUNT(DISTINCT idPedido) AS ticketMedio,
        AVG(vlPreco) AS avgValorProduto,
        MAX(vlPreco) AS maxValorProduto,
        MIN(vlPreco) AS minValorProduto,
        COUNT(idProduto) / count(DISTINCT idPedido) as avgProdutoPorPedido
    FROM tb_join
    GROUP BY idVendedor
),

tb_pedidos AS(
SELECT
    idVendedor,
    idPedido,
    sum(vlPreco) as vlPedido

FROM tb_join
GROUP BY idVendedor, idPedido
),

tb_lifecycle AS(

SELECT
    t2.idVendedor,
    sum(vlPreco) AS lifeTimeValue,
    JULIANDAY(DATE('2018-01-01')) - JULIANDAY(MIN(DATE(t1.dtPedido))) AS qtdDiasPrimeiraVenda,
    JULIANDAY(DATE('2018-01-01')) - JULIANDAY(MAX(DATE(dtPedido))) AS qtdRecenciaVenda

FROM pedido as t1
LEFT JOIN item_pedido as t2
ON t1.idPedido = t2.idPedido

WHERE t1.dtPedido < '2018-01-01'
AND t2.idVendedor IS NOT NULL

GROUP BY t2.idVendedor
),

tb_dtpedido AS(

SELECT DISTINCT
    idVendedor,
    DATE(dtPedido) as dtPedido

FROM tb_join
ORDER BY idVendedor, dtPedido
),

tb_lag as(
SELECT *,
    LAG(dtPedido) OVER (PARTITION BY idVendedor ORDER BY dtPedido) as lagDtPedido
FROM tb_dtpedido

),

tb_interavals AS(

SELECT
    idVendedor,
    avg(JULIANDAY(dtPedido) - JULIANDAY(lagDtPedido)) as avgIntervaloVendas
FROM tb_lag
GROUP BY idVendedor
)

SELECT
    '2018-01-01' AS dtReference,
    t1.*,
    t2.lifeTimeValue,
    t2.qtdDiasPrimeiraVenda,
    t2.qtdRecenciaVenda,
    t3.avgIntervaloVendas

    FROM tb_summary as t1
    LEFT JOIN tb_lifecycle as t2
    ON t1.idVendedor = t2.idVendedor

    LEFT JOIN tb_interavals as t3
    ON t1.idVendedor = t3.idVendedor