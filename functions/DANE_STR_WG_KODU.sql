CREATE OR REPLACE FUNCTION DANE_STR_WG_KODU (pKOD_STR VARCHAR2, pINFO_TYPE VARCHAR2, pRODZ_SUR CHAR DEFAULT null) RETURN NUMBER
AS
 vILE_LIS NUMBER(2);
 sepSTR CHAR(1):='\';
 --'
 vRet NUMBER(14,4);
BEGIN
 IF instr(pKOD_STR,'/')>0 THEN sepSTR:='/'; END IF;
 IF pINFO_TYPE='GRUB_SUR' THEN
 SELECT nvl(sum(grubosc*
                ((length(sepSTR||pKOD_STR||sepSTR)-length(replace(sepSTR||pKOD_STR||sepSTR,sepSTR||typ_kat||sepSTR,sepSTR))) / (length(typ_kat)+1)) --ile razy ten typ kat. w kodzie
               ),0)
   INTO vRet
 FROM katalog 
 WHERE rodz_sur=pRODZ_SUR
   AND instr(sepSTR||pKOD_STR||sepSTR,sepSTR||typ_kat||sepSTR)>0;
 RETURN vRet;
 END IF;
END DANE_STR_WG_KODU;
/