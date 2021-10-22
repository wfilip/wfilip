create or replace PROCEDURE "ZAPISZ_ZLEC_ZM" (pNK_ZLEC NUMBER, pTYP CHAR, pOPIS VARCHAR2, pNK_ZM IN OUT NUMBER)
AS
 vSID NUMBER:=0;
 vData DATE;
 vCzas CHAR(6);
 vOper VARCHAR2(20);
 vOperNr NUMBER(10);
 vNrZlec NUMBER(10);
 vOpisZlec VARCHAR2(10);
begin
 IF nvl(pNK_ZM,0)=0 THEN
   --SELECT zlec_zm_seq.nextval INTO pNK_ZM FROM dual;
   --UPDATE konfig_t SET ost_nr=ost_nr+1 WHERE nr_par=32
   --RETURNING ost_nr INTO pNK_ZM;
   SELECT KONFIG_T32_SEQ.nextval INTO pNK_ZM FROM dual;
 END IF;

 SELECT nr_zlec, forma_wprow||status||decode(do_produkcji,1,'Y','N')||to_char(flag_r)
   INTO vNrZlec, vOpisZlec
 FROM zamow
 WHERE nr_kom_zlec=pNK_ZLEC;

 SELECT SYS_CONTEXT('USERENV','SESSIONID'), trunc(SYSDATE), to_char(SYSDATE,'HH24MISS')
   INTO vSID, vData, vCzas
 FROM DUAL;

 SELECT nvl(max(operator_id),'brak wpisu logowania') INTO vOper
 FROM (select rownum lp, operator_id from (select operator_id from logowania where session_ID=vSID order by vData desc, vCzas desc))
 WHERE lp=1;

 SELECT nvl(max(nr_oper),0) INTO vOperNr
 FROM operatorzy
 WHERE id=vOper;

 INSERT INTO zlec_zm (nk_zm, nk_zlec, nr_zlec, data, czas, oper, typ, opis)
        VALUES (pNK_ZM, pNK_ZLEC, vNrZlec, vData, vCzas, vOperNr, pTYP, pOPIS||' /'||vOpisZlec);
END ZAPISZ_ZLEC_ZM;
/