WITH tb_join AS(

SELECT DISTINCT
    t1.idPedido,
    t1.idCliente,
    t2.idVendedor,
    t3.descUF

FROM pedido as t1

LEFT JOIN item_pedido as t2
ON t1.idPedido = t2.idPedido

LEFT JOIN cliente as t3
ON t1.idCliente = t3.idCliente

WHERE dtPedido < '2018-01-01'
AND dtPedido >= '2017-06-01'
AND idVendedor IS NOT NULL
),

tb_group as (
    SELECT
        idVendedor,
        count(distinct descUF) AS qtdUFsDistintos,
        count(DISTINCT CASE WHEN descUF = 'AC' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoAC,
        count(DISTINCT CASE WHEN descUF = 'AL' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoAL,
        count(DISTINCT CASE WHEN descUF = 'AM' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoAM,
        count(DISTINCT CASE WHEN descUF = 'AP' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoAP,
        count(DISTINCT CASE WHEN descUF = 'BA' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoBA,
        count(DISTINCT CASE WHEN descUF = 'CE' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoCE,
        count(DISTINCT CASE WHEN descUF = 'DF' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoDF,
        count(DISTINCT CASE WHEN descUF = 'ES' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoES,
        count(DISTINCT CASE WHEN descUF = 'GO' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoGO,
        count(DISTINCT CASE WHEN descUF = 'MA' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoMA,
        count(DISTINCT CASE WHEN descUF = 'MG' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoMG,
        count(DISTINCT CASE WHEN descUF = 'MS' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoMS,
        count(DISTINCT CASE WHEN descUF = 'MT' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoMT,
        count(DISTINCT CASE WHEN descUF = 'PA' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoPA,
        count(DISTINCT CASE WHEN descUF = 'PB' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoPB,
        count(DISTINCT CASE WHEN descUF = 'PE' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoPE,
        count(DISTINCT CASE WHEN descUF = 'PI' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoPI,
        count(DISTINCT CASE WHEN descUF = 'PR' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoPR,
        count(DISTINCT CASE WHEN descUF = 'RJ' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoRJ,
        count(DISTINCT CASE WHEN descUF = 'RN' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoRN,
        count(DISTINCT CASE WHEN descUF = 'RO' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoRO,
        count(DISTINCT CASE WHEN descUF = 'RR' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoRR,
        count(DISTINCT CASE WHEN descUF = 'RS' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoRS,
        count(DISTINCT CASE WHEN descUF = 'SC' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoSC,
        count(DISTINCT CASE WHEN descUF = 'SE' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoSE,
        count(DISTINCT CASE WHEN descUF = 'SP' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoSP,
        count(DISTINCT CASE WHEN descUF = 'TO' THEN idPedido end)* 1.0 / count(DISTINCT idPedido) as pctPedidoTO

    FROM tb_join

    GROUP BY idVendedor
    ORDER BY 1
)

SELECT
    '2018-01-01' AS dtReference,
    *
FROM tb_group