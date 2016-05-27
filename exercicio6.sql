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