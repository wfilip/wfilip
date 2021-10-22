CREATE OR REPLACE FUNCTION ATRYB_SUM (pIDENT1 VARCHAR2, pIDENT2 VARCHAR2, pIDENT3 VARCHAR2 DEFAULT '0', pIDENT4 VARCHAR2 DEFAULT '0') RETURN VARCHAR2
AS
 vRet VARCHAR2(100):=' ';
 vDlugosc NUMBER(3):=100;
 Nr NUMBER(3):=0;
BEGIN
 vDlugosc:=greatest(length(pIDENT1),length(pIDENT2),length(pIDENT3),length(pIDENT4));
 --dobrze dziala przy '1' maks na 40ej pozycji
 IF vDlugosc<=40 THEN 
  SELECT rpad(translate(reverse(to_char(sum(reverse(rpad(ident_bud,100,'0'))))),'23456789','11111111'),vDlugosc,'0')
  --SELECT translate(reverse(to_char(sum(reverse(rpad(ident_bud,100,'0'))),rpad('0',least(63,vDlugosc),'9'))),'23456789','11111111')
    INTO vRet
  FROM 
  (select pIDENT1 ident_bud from dual union 
   select pIDENT2 from dual union
   select pIDENT3 from dual union
   select pIDENT4 from dual);
  RETURN vRet; 
 ELSE
   LOOP
    EXIT WHEN Nr>=vDlugosc;
    Nr:=Nr+1;
    IF substr(pIDENT1,Nr,1)='1' or substr(pIDENT2,Nr,1)='1' or substr(pIDENT3,Nr,1)='1' or substr(pIDENT4,Nr,1)='1' THEN
     vRet:=vRet||'1';
    ELSE
     vRet:=vRet||'0';
    END IF; 
   END LOOP;
  RETURN trim(vRet);
 END IF; 
EXCEPTION WHEN OTHERS THEN
 RETURN '0';
END ATRYB_SUM;
/