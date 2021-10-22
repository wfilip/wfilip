create or replace FUNCTION ATRYB_PRODUCT (pIDENT1 VARCHAR2, pIDENT2 VARCHAR2) RETURN VARCHAR2
AS
 vRet VARCHAR2(100):=' ';
 vDlugosc NUMBER(3):=100;
 Nr NUMBER(3):=0;
BEGIN
 vDlugosc:=greatest(length(pIDENT1),length(pIDENT2));
 LOOP
  EXIT WHEN Nr>=vDlugosc;
  Nr:=Nr+1;
  IF substr(pIDENT1,Nr,1)='1' and substr(pIDENT2,Nr,1)='1' THEN
   vRet:=vRet||'1';
  ELSE
   vRet:=vRet||'0';
  END IF; 
 END LOOP;
 RETURN trim(vRet);
EXCEPTION WHEN OTHERS THEN
 RETURN '0';
END ATRYB_PRODUCT;
/