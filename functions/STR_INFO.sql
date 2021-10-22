create or replace function STR_INFO (pNR_STR NUMBER, pINFO_TYP VARCHAR2) RETURN NUMBER
AS
 vNum NUMBER(14,4);
BEGIN
 
 IF PINFO_TYP='GRUB' THEN
   SELECT sum(grub*decode(rodz_sur,'FOL',wsp,1)) INTO vNum
   FROM v_str_sur1
   WHERE nr_kom_str=pNR_STR;
 ELSIF PINFO_TYP LIKE 'GRUB-%' THEN
   SELECT sum(grub*decode(rodz_sur,'FOL',wsp,1)) INTO vNum
   FROM v_str_sur1
   WHERE nr_kom_str=pNR_STR AND rodz_sur=substr(pINFO_TYP,6);
 ELSIF pINFO_TYP='WSP-GRUB-TAF' THEN
   Select nvl(max(to_number(replace(wartosc,',','.'),'9.99')),0.25)
   Into vNum
   From param_t Where kod=109;
   SELECT sum(1+(grub-4)*vNum) INTO vNum
   FROM v_str_sur1
   WHERE nr_kom_str=pNR_STR AND rodz_sur='TAF';
 END IF;

 RETURN vNum; 
END;
/

--   select str_info(:STR,'GRUB') from dual;
--   select str_info(:STR,'GRUB-TAF') from dual;
--   select str_info(:STR,'WSP-GRUB-TAF') from dual;