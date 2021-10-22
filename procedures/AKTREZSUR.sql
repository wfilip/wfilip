create or replace PROCEDURE AKTREZSUR (ZM_INDEXSUR IN VARCHAR2 DEFAULT '', ZM_NRMAG IN NUMBER DEFAULT 0)
AS
 vPoczRoku DATE;
 vKartotekaToSynonim NUMBER(1);
 vOwner VARCHAR2(30);
 rezAKT NUMBER(14,6);
 rezROKP NUMBER(14,6) :=0;
 rezROKN NUMBER(14,6) :=0;
BEGIN
  SELECT pocz_roku_obl INTO vPoczRoku from firma;
  
  SELECT count(1), max(table_owner)  INTO vKartotekaToSynonim, vOwner
  FROM user_synonyms WHERE synonym_name='KARTOTEKA';
  
  --wyliczenie rezerwacji z bie¿acej bazy
  SELECT AKTREZSUR_FUN(ZM_INDEXSUR,ZM_NRMAG) INTO rezAKT FROM dual;
  
  --wyliczenie rezerwacji z bazy roku nastepnego (wlasciciela tabeli KARTOTEKA)
  IF vKartotekaToSynonim=1 THEN
    EXECUTE IMMEDIATE 'SELECT '||vOwner||'.AKTREZSUR_FUN(:1,:2) from dual' INTO rezROKN
                USING ZM_INDEXSUR,ZM_NRMAG;
  END IF;
  
  IF sysdate<vPoczRoku THEN
   SELECT count(1), max(owner)  INTO vKartotekaToSynonim, vOwner
   FROM all_synonyms WHERE table_owner=user and table_name='KARTOTEKA';
   --wyliczenie rezerwacji z bazy roku poprzedniego
   IF vKartotekaToSynonim=1 THEN
    EXECUTE IMMEDIATE 'SELECT '||vOwner||'.AKTREZSUR_FUN(:1,:2) from dual' INTO rezROKP
                USING ZM_INDEXSUR,ZM_NRMAG;
   END IF;  
  END IF;
  

  UPDATE KARTOTEKA
  SET REZERACJA = rezAKT + rezROKP + rezROKN  
  WHERE KARTOTEKA.NR_MAG=ZM_NRMAG
    AND KARTOTEKA.INDEKS  =ZM_INDEXSUR;
  --COMMIT;
END;