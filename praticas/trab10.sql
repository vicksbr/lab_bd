1)

SELECT DISTINCT
  ven.DATA_VENDA,  
  SUM(ven.TOTAL_DEVIDO) OVER (PARTITION BY ven.DATA_VENDA ORDER BY ven.DATA_VENDA) as SOMA,
  AVG(ven.TOTAL_DEVIDO) OVER (ORDER BY ven.DATA_VENDA RANGE BETWEEN INTERVAL '1' DAY PRECEDING AND INTERVAL '1' DAY FOLLOWING) AS MEDIA_CALC
FROM 
  VENDA ven
 	
ORDER BY 1
;

2)

SELECT MES, COUNTER, ROUND(((COUNTER-LAG(COUNTER,1) OVER (ORDER BY MES))*100)/COUNTER,2) AS PROX_MES_PERC 
       
       FROM (
          SELECT DISTINCT
              EXTRACT(MONTH FROM DATA_VENDA) as MES,  
              SUM(ven.TOTAL_DEVIDO) OVER (PARTITION BY EXTRACT(MONTH FROM DATA_VENDA) ORDER BY EXTRACT(MONTH FROM DATA_VENDA)) as COUNTER
          FROM 
                VENDA ven
          WHERE EXTRACT(YEAR FROM ven.DATA_VENDA) = 2012 
          ORDER BY 1
		) 
;



3)

SELECT 
  SUBID, ANO, MES, SOMA_MES, SUM(SOMA_MES) OVER (PARTITION BY SUBID ORDER BY ANO) AS SOMA_ANO
    FROM(
        SELECT 
            sub.SUBCATEGORIA_ID AS SUBID,
            EXTRACT(MONTH FROM ven.DATA_VENDA) AS MES,
            EXTRACT(YEAR FROM ven.DATA_VENDA) AS ANO,
            COUNT(1) AS SOMA_MES
        FROM 
        VENDA ven
            INNER JOIN VENDA_ITEM vi ON ven.VENDA_ID = vi.VENDA_ID
            INNER JOIN PRODUTO pro ON vi.PRODUTO_ID = pro.PRODUTO_ID
            INNER JOIN SUBCATEGORIA sub ON pro.SUBCATEGORIA = sub.SUBCATEGORIA_ID
        GROUP BY sub.SUBCATEGORIA_ID,EXTRACT(YEAR FROM ven.DATA_VENDA),EXTRACT(MONTH FROM ven.DATA_VENDA)
        ORDER BY 1,3
    ) 
    ORDER BY SUBID,ANO,MES
;


SELECT DISTINCT
    sub.SUBCATEGORIA_ID AS SUBID,
    EXTRACT(YEAR FROM ven.DATA_VENDA) AS ANO,
    COUNT(1) OVER (PARTITION BY sub.SUBCATEGORIA_ID ORDER BY EXTRACT(YEAR FROM ven.DATA_VENDA)) as CALC
FROM 
    VENDA ven
    INNER JOIN VENDA_ITEM vi ON ven.VENDA_ID = vi.VENDA_ID
    INNER JOIN PRODUTO pro ON vi.PRODUTO_ID = pro.PRODUTO_ID
    INNER JOIN SUBCATEGORIA sub ON pro.SUBCATEGORIA = sub.SUBCATEGORIA_ID
ORDER BY 1,2
;

4)

SELECT 
      NOME,
      QTD_VEND,
      SUBCAT,
      CATEGO,
      DENSE_RANK() OVER (PARTITION BY SUBCAT ORDER BY QTD_VEND DESC) as RANKSUB,
      DENSE_RANK() OVER (PARTITION BY CATEGO ORDER BY QTD_VEND DESC,SUBCAT) as RANKCAT,
      DENSE_RANK() OVER (ORDER BY QTD_VEND DESC) RANK_GERAL
  FROM (
        SELECT DISTINCT
          vi.PRODUTO_ID,  
          pro.NOME as NOME,
          sub.SUBCATEGORIA_ID as SUBCAT,
          sub.CATEGORIA CATEGO,
          COUNT(1) OVER (PARTITION BY vi.PRODUTO_ID ORDER BY vi.PRODUTO_ID) AS QTD_VEND,
          COUNT(1) OVER () AS QTD_TOTAL
        FROM 
          VENDA ven 
          INNER JOIN VENDA_ITEM vi ON ven.VENDA_ID = vi.VENDA_ID
          INNER JOIN PRODUTO pro ON vi.PRODUTO_ID = pro.PRODUTO_ID
          INNER JOIN SUBCATEGORIA sub ON pro.SUBCATEGORIA = sub.SUBCATEGORIA_ID
        ORDER BY QTD_VEND DESC
        )
ORDER BY QTD_VEND DESC
;


5)

SELECT NOME,QTD 
  FROM (
	SELECT 
	    R1 as NOME,
    	R2 as QTD,
	    ROUND(R3,2) as PORCENTAGEM 
		FROM (	
			SELECT 
		      NOME as R1,
		      QTD_VEND AS R2,
		      PERCENT_RANK() OVER (ORDER BY QTD_VEND) AS R3
  			FROM (
        		SELECT DISTINCT
		          vi.PRODUTO_ID,  
		          pro.NOME as NOME,
		          sub.SUBCATEGORIA_ID as SUBCAT,
		          sub.CATEGORIA CATEGO,
		          COUNT(1) OVER (PARTITION BY vi.PRODUTO_ID ORDER BY vi.PRODUTO_ID) AS QTD_VEND,
		          COUNT(1) OVER () AS QTD_TOTAL
        		FROM 
		          VENDA ven 
		          INNER JOIN VENDA_ITEM vi ON ven.VENDA_ID = vi.VENDA_ID
		          INNER JOIN PRODUTO pro ON vi.PRODUTO_ID = pro.PRODUTO_ID
		          INNER JOIN SUBCATEGORIA sub ON pro.SUBCATEGORIA = sub.SUBCATEGORIA_ID
		        ORDER BY QTD_VEND DESC
        		)
		ORDER BY QTD_VEND DESC
		)
	WHERE R3 > 0.9 OR R3 < 0.1
	ORDER BY QTD DESC
	)
;


6)

/*demo*/
SELECT DISTINCT
    	*
     	FROM(
			SELECT 
	      		PAIS,
	            ESTADO,
	            CIDADE,
	            total_cid,
	            total_est,    
	            total_pais,
	            CATEGORIA,
	            CAT_CIDADE,
	            CAT_CIDADE-LAG(CAT_CIDADE,1,0) OVER (PARTITION BY CIDADE ORDER BY PAIS,ESTADO,CIDADE,CATEGORIA) AS cat_por_cidade,
	            CAT_ESTADO,
	            CAT_ESTADO-LAG(CAT_ESTADO,1,0) OVER (PARTITION BY PAIS,ESTADO,CIDADE ORDER BY PAIS,ESTADO,CIDADE,CATEGORIA) AS cat_por_estado,
	            CAT_PAIS,
	            CAT_PAIS-LAG(CAT_PAIS,1,0) OVER (PARTITION BY PAIS,ESTADO,CIDADE ORDER BY PAIS,ESTADO,CIDADE,CATEGORIA) AS cat_por_pais
	            FROM(
	            		SELECT DISTINCT
	            			est.PAIS    AS PAIS,
	              			est.NOME    AS ESTADO,
	              			ende.CIDADE AS CIDADE,
	              			COUNT(1) OVER (PARTITION BY est.PAIS) total_pais, 
			                COUNT(1) OVER (PARTITION BY est.ESTADO_ID) total_est,
	              			COUNT(1) OVER (PARTITION BY ende.CIDADE) total_cid, 
	              			sub.CATEGORIA as CATEGORIA,
	              			COUNT(1) OVER (PARTITION BY ende.CIDADE ORDER BY sub.CATEGORIA) as CAT_CIDADE,
	              			COUNT(1) OVER (PARTITION BY est.ESTADO_ID ORDER BY sub.CATEGORIA) as CAT_ESTADO,
	              			COUNT(1) OVER (PARTITION BY est.PAIS ORDER BY sub.CATEGORIA) as CAT_PAIS          
			            FROM 
	              			VENDA ven 
	              			INNER JOIN VENDA_ITEM vi ON ven.VENDA_ID = vi.VENDA_ID
	              			INNER JOIN PRODUTO pro ON vi.PRODUTO_ID = pro.PRODUTO_ID
	              			INNER JOIN SUBCATEGORIA sub ON pro.SUBCATEGORIA = sub.SUBCATEGORIA_ID
	              			INNER JOIN ENDERECO ende ON ven.ENDERECO_ENTREGA = ende.ENDERECO_ID
	              			INNER JOIN ESTADO est ON ende.ESTADO_ID = est.ESTADO_ID
	            		ORDER BY PAIS,ESTADO,CIDADE
	            )
	            ORDER BY PAIS,ESTADO,CIDADE
    	)
ORDER BY PAIS,ESTADO,CIDADE,CATEGORIA
;


/*com o total calculado*/

SELECT 
  * 
  FROM(
      SELECT DISTINCT
        PAIS,
        ESTADO,
        CIDADE,
        total_cid,
        total_est,    
        total_pais,
        total_mundo,
        CATEGORIA,
        cat_por_cidade,
        cat_por_estado,      
        cat_por_mundo,
        round(cat_por_cidade/cat_por_estado*100,4) AS PCID_RELACAO_ESTADO,
        round(cat_por_cidade/cat_por_pais*100,4) AS PCID_RELACAO_PAIS,
        round(cat_por_cidade/cat_por_mundo*100,4) AS PCID_RELACAO_MUNDO      
        FROM(
            SELECT 
                PAIS,
                ESTADO,
                CIDADE,
                total_cid,
                total_est,    
                total_pais,
                total_mundo,
                CATEGORIA,
                CAT_CIDADE,
                CAT_CIDADE-LAG(CAT_CIDADE,1,0) OVER (PARTITION BY CIDADE ORDER BY PAIS,ESTADO,CIDADE,CATEGORIA) AS cat_por_cidade,
                CAT_ESTADO,
                CAT_ESTADO-LAG(CAT_ESTADO,1,0) OVER (PARTITION BY PAIS,ESTADO,CIDADE ORDER BY PAIS,ESTADO,CIDADE,CATEGORIA) AS cat_por_estado,
                CAT_PAIS,
                CAT_PAIS-LAG(CAT_PAIS,1,0) OVER (PARTITION BY PAIS,ESTADO,CIDADE ORDER BY PAIS,ESTADO,CIDADE,CATEGORIA) AS cat_por_pais,              
                CAT_MUNDO,
                CAT_MUNDO-LAG(CAT_MUNDO,1,0) OVER (PARTITION BY PAIS,ESTADO,CIDADE ORDER BY PAIS,ESTADO,CIDADE,CATEGORIA) AS cat_por_mundo              
                FROM(
                      SELECT DISTINCT
                        est.PAIS    AS PAIS,
                        est.NOME    AS ESTADO,
                        ende.CIDADE AS CIDADE,
                        SUM(vi.TOTAL_UNITARIO) OVER (PARTITION BY est.PAIS) total_pais, 
                        SUM(vi.TOTAL_UNITARIO) OVER (PARTITION BY est.ESTADO_ID) total_est,
                        SUM(vi.TOTAL_UNITARIO) OVER (PARTITION BY ende.CIDADE) total_cid, 
                        SUM(vi.TOTAL_UNITARIO) OVER () total_mundo, 
                        sub.CATEGORIA as CATEGORIA,
                        SUM(ven.TOTAL_DEVIDO) OVER (PARTITION BY ende.CIDADE ORDER BY sub.CATEGORIA) as CAT_CIDADE,
                        SUM(ven.TOTAL_DEVIDO) OVER (PARTITION BY est.ESTADO_ID ORDER BY sub.CATEGORIA) as CAT_ESTADO,
                        SUM(ven.TOTAL_DEVIDO) OVER (PARTITION BY est.PAIS ORDER BY sub.CATEGORIA) as CAT_PAIS,          
                        SUM(ven.TOTAL_DEVIDO) OVER (ORDER BY sub.CATEGORIA) as CAT_MUNDO
                      FROM 
                        VENDA ven 
                        INNER JOIN VENDA_ITEM vi ON ven.VENDA_ID = vi.VENDA_ID
                        INNER JOIN PRODUTO pro ON vi.PRODUTO_ID = pro.PRODUTO_ID
                        INNER JOIN SUBCATEGORIA sub ON pro.SUBCATEGORIA = sub.SUBCATEGORIA_ID
                        INNER JOIN ENDERECO ende ON ven.ENDERECO_ENTREGA = ende.ENDERECO_ID
                        INNER JOIN ESTADO est ON ende.ESTADO_ID = est.ESTADO_ID
                      ORDER BY PAIS,ESTADO,CIDADE
                  )
            ORDER BY PAIS,ESTADO,CIDADE
         )
  ORDER BY PAIS,ESTADO,CIDADE
  )
ORDER BY PAIS,ESTADO,CIDADE
;