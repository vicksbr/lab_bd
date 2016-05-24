1)

SELECT met.NOME, round(AVG(ven.FRETE),2) AS MEDIA_MENSAL, EXTRACT(MONTH FROM ven.DATA_VENDA) as MES, EXTRACT(YEAR FROM ven.DATA_VENDA) as ANO FROM VENDA ven
INNER JOIN METODO_ENTREGA met ON ven.METODO_ENTREGA_ID = met.METODO_ENTREGA_ID
GROUP BY CUBE(met.NOME,EXTRACT(YEAR FROM ven.DATA_VENDA),EXTRACT(MONTH FROM ven.DATA_VENDA))
ORDER BY 1,4,3
;


2)

SELECT cli.CLIENTE_ID, count(cli.CLIENTE_ID) as Qtd, EXTRACT(YEAR FROM ven.DATA_VENDA) as ANO, ROUND(SUM(ven.TOTAL_DEVIDO),2) as TOTAL
FROM VENDA ven
INNER JOIN CLIENTE cli ON ven.CLIENTE_ID = cli.CLIENTE_ID
GROUP BY ROLLUP(cli.CLIENTE_ID,EXTRACT(YEAR FROM ven.DATA_VENDA))
ORDER BY cli.CLIENTE_ID
;


3)

SELECT cli.CLIENTE_ID, count(cli.CLIENTE_ID) as Qtd, EXTRACT(YEAR FROM ven.DATA_VENDA) as ANO, ROUND(SUM(ven.TOTAL_DEVIDO),2) as TOTAL
FROM VENDA ven
INNER JOIN CLIENTE cli ON ven.CLIENTE_ID = cli.CLIENTE_ID
GROUP BY CUBE(cli.CLIENTE_ID,EXTRACT(YEAR FROM ven.DATA_VENDA))
ORDER BY cli.CLIENTE_ID
;


4)

SELECT prod.PRODUTO_ID, EXTRACT(MONTH FROM ven.DATA_VENDA) as MES, EXTRACT(YEAR from ven.DATA_VENDA) as ANO, count(prod.PRODUTO_ID) as QTD
FROM VENDA ven 
INNER JOIN VENDA_ITEM vid ON ven.VENDA_ID = vid.VENDA_ID
INNER JOIN PRODUTO prod ON vid.PRODUTO_ID = prod.PRODUTO_ID
GROUP BY ROLLUP(prod.PRODUTO_ID, EXTRACT(YEAR from ven.DATA_VENDA),EXTRACT(MONTH FROM ven.DATA_VENDA))
HAVING EXTRACT(YEAR FROM ven.DATA_VENDA) = 2013
ORDER BY 1,3,2
;

5)

SELECT est.NOME, EXTRACT(YEAR FROM ven.DATA_VENDA) as ANO, EXTRACT(MONTH FROM ven.DATA_VENDA) as MES, ROUND(SUM(ven.IMPOSTOS),2) as SOMA FROM VENDA ven
INNER JOIN ENDERECO ende ON ven.ENDERECO_COBRANCA = ende.ENDERECO_ID
INNER JOIN ESTADO est ON ende.ESTADO_ID = est.ESTADO_ID
GROUP BY CUBE(est.NOME,EXTRACT(YEAR FROM ven.DATA_VENDA),EXTRACT(MONTH FROM ven.DATA_VENDA))
HAVING EXTRACT(YEAR FROM ven.DATA_VENDA) = 2013
ORDER BY 1,2,3
;

6)

SELECT sub.NOME, sub.CATEGORIA, EXTRACT(YEAR FROM ven.DATA_VENDA) as ANO, EXTRACT(MONTH FROM ven.DATA_VENDA) as MES, count(sub.SUBCATEGORIA_ID) as QTD
FROM VENDA ven
INNER JOIN VENDA_ITEM vid ON ven.VENDA_ID = vid.VENDA_ID
INNER JOIN PRODUTO prod ON vid.PRODUTO_ID = prod.PRODUTO_ID
INNER JOIN SUBCATEGORIA sub ON prod.SUBCATEGORIA = sub.SUBCATEGORIA_ID
GROUP BY CUBE(sub.NOME,sub.CATEGORIA,EXTRACT(YEAR FROM ven.DATA_VENDA),EXTRACT(MONTH FROM ven.DATA_VENDA))
HAVING EXTRACT(YEAR FROM ven.DATA_VENDA) = 2013
ORDER BY 1,2,3
;

7)

SELECT sub.CATEGORIA as CATEGORIA,sub.NOME as SUBCATEGORIA, EXTRACT(YEAR FROM ven.DATA_VENDA) as ANO, EXTRACT(MONTH FROM ven.DATA_VENDA) as MES, count(sub.SUBCATEGORIA_ID) as QTD
FROM VENDA ven
INNER JOIN VENDA_ITEM vid ON ven.VENDA_ID = vid.VENDA_ID
INNER JOIN PRODUTO prod ON vid.PRODUTO_ID = prod.PRODUTO_ID
INNER JOIN SUBCATEGORIA sub ON prod.SUBCATEGORIA = sub.SUBCATEGORIA_ID
GROUP BY CUBE(sub.CATEGORIA,sub.NOME,EXTRACT(YEAR FROM ven.DATA_VENDA),EXTRACT(MONTH FROM ven.DATA_VENDA))
HAVING EXTRACT(YEAR FROM ven.DATA_VENDA) = 2013
ORDER BY 1,2,3,4
;




