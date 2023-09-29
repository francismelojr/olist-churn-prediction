WITH tb_join AS 
(SELECT DISTINCT
    t2.idVendedor,
    t3.*

    FROM PEDIDO AS t1

    LEFT JOIN item_pedido as t2
    on t1.idPedido = t2.idPedido

    LEFT JOIN produto as t3
    on t2.idProduto = t3.idProduto

    WHERE t1.dtPedido < '2018-01-01'
    AND t1.dtPedido >= '2017-06-01'
    AND t2.idVendedor is NOT NULL
),

tb_summary as 
(
SELECT 
    idVendedor,
    COUNT(DISTINCT descCategoria) as qtdCategoriasVendedor,
    AVG(coalesce(nrFotos,0)) as avgFotosVendedor,
    AVG(coalesce(vlPesoGramas,0)) as avgPesoGramas,
    AVG(vlComprimentoCm * vlAlturaCm * vlLarguraCm) as avgVolProduto,
    MIN(vlComprimentoCm * vlAlturaCm * vlLarguraCm) as minVolProduto,
    MAX(vlComprimentoCm * vlAlturaCm * vlLarguraCm) as maxVolProduto,

    COUNT(DISTINCT CASE WHEN descCategoria = 'cama_mesa_banho' THEN idProduto END) * 1.0 / COUNT(DISTINCT idProduto) AS pctCategoria_cama_mesa_banho,
    COUNT(DISTINCT CASE WHEN descCategoria = 'beleza_saude' THEN idProduto END) * 1.0 / COUNT(DISTINCT idProduto) AS pctCategoria_beleza_saude,
    COUNT(DISTINCT CASE WHEN descCategoria = 'esporte_lazer' THEN idProduto END) * 1.0 / COUNT(DISTINCT idProduto) AS pctCategoria_esporte_lazer,
    COUNT(DISTINCT CASE WHEN descCategoria = 'informatica_acessorios' THEN idProduto END) * 1.0 / COUNT(DISTINCT idProduto) AS pctCategoria_informatica_acessorios,
    COUNT(DISTINCT CASE WHEN descCategoria = 'moveis_decoracao' THEN idProduto END) * 1.0 / COUNT(DISTINCT idProduto) AS pctCategoria_moveis_decoracao,
    COUNT(DISTINCT CASE WHEN descCategoria = 'utilidades_domesticas' THEN idProduto END) * 1.0 / COUNT(DISTINCT idProduto) AS pctCategoria_utilidades_domesticas,
    COUNT(DISTINCT CASE WHEN descCategoria = 'relogios_presentes' THEN idProduto END) * 1.0 / COUNT(DISTINCT idProduto) AS pctCategoria_relogios_presentes,
    COUNT(DISTINCT CASE WHEN descCategoria = 'telefonia' THEN idProduto END) * 1.0 / COUNT(DISTINCT idProduto) AS pctCategoria_telefonia,
    COUNT(DISTINCT CASE WHEN descCategoria = 'automotivo' THEN idProduto END) * 1.0 / COUNT(DISTINCT idProduto) AS pctCategoria_automotivo,
    COUNT(DISTINCT CASE WHEN descCategoria = 'brinquedos' THEN idProduto END) * 1.0 / COUNT(DISTINCT idProduto) AS pctCategoria_brinquedos,
    COUNT(DISTINCT CASE WHEN descCategoria = 'cool_stuff' THEN idProduto END) * 1.0 / COUNT(DISTINCT idProduto) AS pctCategoria_cool_stuff,
    COUNT(DISTINCT CASE WHEN descCategoria = 'ferramentas_jardim' THEN idProduto END) * 1.0 / COUNT(DISTINCT idProduto) AS pctCategoria_ferramentas_jardim,
    COUNT(DISTINCT CASE WHEN descCategoria = 'perfumaria' THEN idProduto END) * 1.0 / COUNT(DISTINCT idProduto) AS pctCategoria_perfumaria,
    COUNT(DISTINCT CASE WHEN descCategoria = 'bebes' THEN idProduto END) * 1.0 / COUNT(DISTINCT idProduto) AS pctCategoria_bebes,
    COUNT(DISTINCT CASE WHEN descCategoria = 'eletronico' THEN idProduto END) * 1.0 / COUNT(DISTINCT idProduto) AS pctCategoria_eletronico

    FROM tb_join

    GROUP BY idVendedor
    
),

tb_topcategories as 

(

SELECT 
    idVendedor,

    COUNT(DISTINCT CASE WHEN descCategoria IN ('cama_mesa_banho', 'beleza_saude', 
    'esporte_lazer', 'informatica_acessorios', 'moveis_decoracao', 'utilidades_domesticas',
    'relogios_presentes', 'telefonia', 'automotivo', 'brinquedos', 'cool_stuff',
    'ferramentas_jardim', 'perfumaria', 'bebes',
    'eletronico') THEN idProduto END) * 1.0 /
    COUNT(DISTINCT idProduto) AS pctSalesOnTop15Category

    FROM tb_join

    GROUP BY idVendedor


)

SELECT 
    '2018-01-01' AS dtReference,
    t1.*,
    t2.pctSalesOnTop15Category 
    FROM tb_summary as t1
    LEFT JOIN tb_topcategories as t2
    on t1.idVendedor = t2.idVendedor