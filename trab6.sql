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

