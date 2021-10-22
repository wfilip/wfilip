--select utl_raw.cast_to_varchar2(ostat_nr),
--    sip_raw_to_number(ostat_nr),
--    sip_number_to_raw(sip_raw_to_number(ostat_nr),10) sip_raw, ostat_nr,
--    K.*
--from konfdok K
--where gr_dok='Dok' and typ_dok IN ('ZZ','ZW','ZO','ZD','WW');

--alter table konfdok add ost_nr number(10) default 0 not null;

create or replace function SIP_RAW_TO_NUMBER(pRAW RAW) RETURN NUMBER
AS
 c CHAR(1);
 str VARCHAR2(100);
 retN NUMBER(10):=0;
 n NUMBER(2);
BEGIN
 str:=utl_raw.cast_to_varchar2(pRAW);
 FOR I IN 1..length(str) LOOP
   c:=substr(str,i,1);
   IF i<length(str) THEN
    N:=to_number(c);
    retN:=retN+N*power(10,10-i);
   ELSIF c<>'{' THEN
    N:=ascii(c)-65+1;
    retN:=retN+N;
   END IF; 
 END LOOP;
 RETURN retN;
END SIP_RAW_TO_NUMBER;
/

create or replace function SIP_NUMBER_TO_RAW(pNUM NUMBER, pLEN NUMBER) RETURN RAW
AS
 ret VARCHAR2(100);
 str VARCHAR2(100);
BEGIN
 str:=trim(to_char(pNUM,rpad('0',pLEN,'9')));
 FOR i IN 1..pLEN LOOP
   IF i<pLEN THEN
    --ret:=ret||'3'||substr(str,i,1);
    ret:=ret||substr(str,i,1);
   ELSIF substr(str,pLEN,1)='0' THEN
    ret:=ret||'{';
   ELSE
    ret:=ret||chr(65+to_number(substr(str,pLEN,1))-1); -- 1->A, 2->B, ...
   END IF; 
 END LOOP;
 RETURN UTL_RAW.CAST_TO_RAW(ret);
 --RETURN ret;
END SIP_NUMBER_TO_RAW;
/
