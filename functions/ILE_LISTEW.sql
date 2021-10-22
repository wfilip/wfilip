CREATE OR REPLACE FUNCTION ILE_LISTEW (pKOD_STR VARCHAR2) RETURN NUMBER
AS
 vILE_LIS NUMBER(1);
 sepSTR CHAR(1):='\';
 --'
BEGIN
 IF instr(pKOD_STR,'/')>0 THEN sepSTR:='/'; END IF;
 
 SELECT nvl(sum(
                (length(sepSTR||pKOD_STR||sepSTR)-length(replace(sepSTR||pKOD_STR||sepSTR,sepSTR||typ_kat||sepSTR,sepSTR))) / (length(typ_kat)+1)
               ),0)
   INTO vILE_LIS
 FROM katalog 
 WHERE rodz_sur='LIS'
   AND instr(sepSTR||pKOD_STR||sepSTR,sepSTR||typ_kat||sepSTR)>0;
 RETURN vILE_LIS;
END ILE_LISTEW;
/