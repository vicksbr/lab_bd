CONTADOR DE TIMES PARA CAMPEONATO COM ID TAL

SELECT COUNT(*) FROM (
SELECT DISTINCT * FROM ( 
SELECT TTIME1 FROM F11_PARTIDA WHERE IDCAMPEONATOP = 17
UNION
SELECT TTIME2 FROM F11_PARTIDA WHERE IDCAMPEONATOP = 17
));

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

create or replace TRIGGER VERIFICA_ESTADIO_PARTIDA
BEFORE INSERT OR DELETE OR UPDATE
ON F11_PARTIDA
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW

DECLARE cidade_time F04_TIME.CIDADE%type; 
        cidade_estadio F09_ESTADIO.CIDADE%type;
        cidadesDiferentes EXCEPTION;
BEGIN
    SELECT CIDADE INTO cidade_time FROM F04_TIME where F04_TIME.TTIME = :NEW.TTIME1;
    SELECT CIDADE into cidade_estadio FROM F09_ESTADIO where F09_ESTADIO.IDESTADIO = :NEW.IDESTADIOP;

    IF (cidade_time != cidade_estadio) THEN
          RAISE_APPLICATION_ERROR (-20500
        , 'O time da casa só pode jogar em casa'); 
    END IF;    
END;

Exemplo que leventa exceção idestadio=60

INSERT INTO "L7656512"."F11_PARTIDA" (IDPARTIDA, TTIME1, TTIME2, DATAHORA, IDCAMPEONATOP, IDESTADIOP, GOLS_TIME1, GOLS_TIME2) VALUES ('651', 'Brasil', 'Itália', TO_DATE('2016-07-30 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), '63', '60', '15', '9')

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


create or replace TRIGGER VERIFICA_QTD_JOGADORES
BEFORE INSERT OR UPDATE
ON F05_JOGADOR
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW

DECLARE cidade_time F04_TIME.CIDADE%type; 
        jogadores NUMBER;        
BEGIN
    SELECT * INTO jogadores FROM(
        SELECT COUNT(*) as contador 
        FROM F04_TIME team
        INNER JOIN F05_JOGADOR jogador ON team.TTIME = jogador.TTIMEJ
        WHERE team.TTIME = :NEW.TTIMEJ
        GROUP BY team.TTIME
    ); 

    IF (jogadores > 5) THEN
          RAISE_APPLICATION_ERROR (-20500
        , 'Só podemos ter 5 inscritos por time'); 
    END IF;    
END;
