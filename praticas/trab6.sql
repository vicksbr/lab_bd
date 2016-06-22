1)

CREATE OR REPLACE VIEW empregado_departamento AS 
SELECT emp.PESSOA_ID, dep.DEPARTAMENTO_ID, dep.NOME, (pes.NOME || ' ' || pes.NOME_DO_MEIO || ' ' || pes.SOBRENOME || ' ' || pes.SUFIXO ) as Pessoa_Nome FROM EMPREGADO emp 
INNER JOIN DEPARTAMENTO dep on emp.DEPARTAMENTO_ID = dep.DEPARTAMENTO_ID
INNER JOIN PESSOA pes on emp.PESSOA_ID = pes.PESSOA_ID;

2)
CREATE OR REPLACE VIEW cliente_dados AS 
SELECT  cli.CLIENTE_ID, cli.PESSOA_ID, 
        (pes.NOME || ' ' || pes.NOME_DO_MEIO || ' ' || pes.SOBRENOME || ' ' || pes.SUFIXO ) as Pessoa_Nome, 
        tel.NUMERO, 
        ende.ENDERECO_ID 
FROM CLIENTE cli
INNER JOIN ENDERECO ende on ende.PESSOA_ID = cli.PESSOA_ID
INNER JOIN TELEFONE tel on  tel.PESSOA_ID = cli.PESSOA_ID
INNER JOIN PESSOA pes on pes.PESSOA_ID = cli.PESSOA_ID;

3)

CREATE OR REPLACE VIEW vendedor_dados AS
SELECT vend.PESSOA_ID, 
       vend.COTA_VENDAS,
       vend.BONUS,
       vend.COMISSAO,
       vend.VENDAS_ANO_ATUAL,
       vend.VENDAS_ULTIMO_ANO,
       (pes.NOME || ' ' || pes.NOME_DO_MEIO || ' ' || pes.SOBRENOME || ' ' || pes.SUFIXO) as Vendedor_Nome        
FROM VENDEDOR vend
INNER JOIN PESSOA pes on vend.PESSOA_ID = pes.PESSOA_ID;

4)

DROP TABLE temp;

CREATE TABLE temp AS 
SELECT vi.VENDA_ID, prod.PRODUTO_ID, prod.NOME, EXTRACT(YEAR FROM v.DATA_VENDA) as ANO FROM VENDA v
INNER JOIN VENDA_ITEM vi ON v.VENDA_ID = vi.VENDA_ID
INNER JOIN PRODUTO prod ON vi.PRODUTO_ID = prod.PRODUTO_ID
WHERE v.DATA_VENDA < TO_DATE('26/JAN/2012','dd/mon/yyyy');


CREATE MATERIALIZED VIEW produtos_vendidos_ano AS
SELECT PRODUTO_ID, COUNT(PRODUTO_ID) as QUANTIDADE, ANO FROM temp GROUP BY PRODUTO_ID, ANO ORDER BY ANO ASC,COUNT(PRODUTO_ID) DESC; 

DROP TABLE temp;

5)

nao consegui criar a trigger

CREATE MATERIALIZED VIEW pessoa_login 
BUILD IMMEDIATE
REFRESH COMPLETE
AS
SELECT emp.LOGIN_ID as "login" , pe.PASSWORD_HASH "password_hash" , 'funcionario' as "tipo_usuario"
FROM PESSOA pe
INNER JOIN EMPREGADO emp on pe.PESSOA_ID = emp.PESSOA_ID
UNION ALL
SELECT pe.EMAIL as "login" , pe.PASSWORD_HASH "password_hash" , 'cliente' as "tipo_usuario" 
FROM PESSOA pe
INNER JOIN CLIENTE cli on pe.PESSOA_ID = cli.PESSOA_ID;