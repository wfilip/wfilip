CREATE OR REPLACE FUNCTION IDENT_ETAP (pETAP NUMBER, pIDENT_SPISZ VARCHAR2) RETURN VARCHAR2
AS
BEGIN
 --pozostawienie atrybutów 5,6,7,8,22,27
 RETURN '0000'||substr(pIDENT_SPISZ,5,4)||rpad('0',13,'0')||substr(pIDENT_SPISZ,22,1)||rpad('0',4,'0')||substr(pIDENT_SPISZ,27,1);
EXCEPTION WHEN OTHERS THEN
 RETURN '0';
END IDENT_ETAP;
/

CREATE OR REPLACE FUNCTION IDENT_ETAP_POP (pETAP NUMBER, pNR_KOM_ZLEC NUMBER, pNR_POZ NUMBER, pWAR_OD NUMBER DEFAULT 0, pWAR_DO NUMBER DEFAULT 99) RETURN VARCHAR2
AS
 vRet VARCHAR2(100):='0';
BEGIN
 IF pETAP=2 THEN
  --sumowanie atrybutów z rekordów czy_war=1
  FOR e1 IN (select ident_bud
             from spiss_v_e1
             where zrodlo='Z' and nr_komp_zr=pNR_KOM_ZLEC and nr_kol=pNR_POZ 
              and war_od between pWAR_OD and pWAR_DO
              and etap=1 and czy_war=1 and strona=0)
   LOOP
    vRet:=ATRYB_SUM(vRet,e1.ident_bud);
   END LOOP;
 END IF;
 RETURN vRet;
EXCEPTION WHEN OTHERS THEN
 RETURN '0';
END IDENT_ETAP_POP;
/