WITH tb_pedido AS(

SELECT DISTINCT
    t1.idPedido,
    t2.idVendedor
FROM PEDIDO as t1
    
LEFT JOIN item_pedido as t2
ON t1.idPedido = t2.idPedido
    
WHERE dtPedido < DATE('{date}')
AND dtPedido >= DATE('{date}', '-7 months')
AND idVendedor IS NOT NULL
),

tb_join AS (

SELECT 
    t1.*,
    t2.vlNota
    FROM tb_pedido as t1

    LEFT JOIN avaliacao_pedido as t2
    ON t1.idPedido = t2.idPedido
),

tb_summary AS(

SELECT 
    idVendedor,
    AVG(vlNota) as avgNota,
    MIN(vlNota) as minNota,
    MAX(vlNota) as maxNota,
    count(vlNota) * 1.0 / count(idPedido) as pctAvaliacao

    FROM tb_join
    GROUP BY idVendedor
)

SELECT
    '{date}' AS dtReference,
    date('now') AS dtIngestion,
    * from tb_summary