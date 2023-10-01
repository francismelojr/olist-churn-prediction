WITH tb_pedido AS
(SELECT
    t1.idPedido,
    t2.idVendedor,
    t1.descSituacao,
    DATETIME(t1.dtPedido) as dtPedido,
    DATETIME(t1.dtAprovado) as dtAprovado,
    DATETIME(t1.dtEntregue) as dtEntregue,
    DATETIME(t1.dtEstimativaEntrega) as dtEstimativaEntrega,
    sum(vlFrete) AS totalFrete

FROM PEDIDO AS t1

LEFT JOIN item_pedido as t2
on t1.idPedido = t2.idPedido

WHERE t1.dtPedido < DATE('{date}')
AND t1.dtPedido >= DATE('{date}', '-7 months')
AND idVendedor IS NOT NULL
    
GROUP BY
    t1.idPedido,
    t2.idVendedor,
    t1.descSituacao,
    t1.dtPedido,
    t1.dtAprovado,
    t1.dtEntregue,
    t1.dtEstimativaEntrega
)

SELECT
    '{date}' AS dtReference,
    date('now') AS dtIngestion,
    idVendedor,
    COUNT(DISTINCT CASE WHEN descSituacao = 'canceled' then idPedido END)* 1.0 /
    COUNT(idPedido) AS pctPedidoCancelado,

    COUNT(DISTINCT CASE WHEN descSituacao = 'delivered' AND
    DATE(COALESCE(dtEntregue, '{date}')) >
    DATE(dtEstimativaEntrega) THEN idPedido END) * 1.0 /
    COUNT(DISTINCT CASE WHEN descSituacao = 'delivered' THEN idPedido END) AS pctPedidosAtrasados,

    AVG(totalFrete) as avgFrete,
    MAX(totalFrete) as maxFrete,
    MIN(totalFrete) as minFrete,

    AVG(JULIANDAY(DATE(COALESCE(dtEntregue, '{date}'))) -
    JULIANDAY(dtAprovado)) AS avgDifDiasEntregaAprovado,

    AVG(JULIANDAY(DATE(COALESCE(dtEntregue, '{date}'))) -
    JULIANDAY(dtEstimativaEntrega)) AS avgDifDiasEntregaEstimativa

FROM tb_pedido
GROUP BY idVendedor