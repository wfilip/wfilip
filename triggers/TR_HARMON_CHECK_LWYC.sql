CREATE OR REPLACE TRIGGER TR_HARMON_CHECK_LWYC 
BEFORE INSERT ON HARMON 
FOR EACH ROW 
WHEN (NEW.TYP_HARM='P') 
DECLARE 
 jestLWYC NUMBER(1);
 jestSPISS NUMBER(1);
BEGIN
 SELECT count(1) INTO jestLWYC   FROM dual WHERE exists (select 1 from l_wyc where nr_kom_zlec=:NEW.NR_KOMP_ZLEC);
 IF jestLWYC=0 THEN
  SELECT count(1) INTO jestSPISS  FROM dual WHERE exists (select 1 from spiss where zrodlo='Z' and nr_komp_zr=:NEW.NR_KOMP_ZLEC);
  IF jestSPISS=0 THEN
   SPISS_MAT('Z',:NEW.NR_KOMP_ZLEC);
  END IF;
  ZAPISZ_LWYC(:NEW.NR_KOMP_ZLEC,0,0);
 END IF;  
END;