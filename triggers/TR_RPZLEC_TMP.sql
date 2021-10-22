--drop trigger TR_RPZLEC_TMP;
create TRIGGER TR_RPZLEC_TMP
BEFORE UPDATE ON RPZLEC
FOR EACH ROW 
WHEN (NEW.DATA_ZLEC<'2021/01/01' AND OLD.NK_KONTR>0 AND NEW.NK_KONTR=0)
DECLARE
 jestZAMOW NUMBER(1) :=0;
 kontraktOK NUMBER(1); 
BEGIN
 --anulowanie zerowanie tylko przy 1. zapisie
 SELECT count(1) INTO jestZAMOW FROM dual WHERE exists (select 1 from zamow where nr_kom_zlec=:NEW.NKOMP);
 --RAISE invalid_number;
 IF jestZAMOW=0 THEN
   SELECT count(1) INTO kontraktOK FROM kontrakt WHERE nr_komp_kontr=:OLD.NK_KONTR AND :NEW.data_zlec between data_pocz and data_zak AND status=0;
   IF kontraktOK=1 THEN 
    :NEW.NK_KONTR:=:OLD.NK_KONTR;
   END IF; 
 END IF;
END;