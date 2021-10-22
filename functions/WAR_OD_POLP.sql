CREATE OR REPLACE FUNCTION WAR_OD_POLP(pFUN NUMBER, pNR_KOM_STR NUMBER, pNR_WAR NUMBER) RETURN NUMBER
AS
 vResult NUMBER(2):=0;
BEGIN
 IF pFUN=5 THEN
  select nvl(max(S0.nr_war),0)+1
    into vResult
  from spiss_str S0
  where S0.zrodlo='S' and S0.nr_komp_zr=pNR_KOM_STR
    and S0.nr_war<=pNR_WAR
    and S0.rodz_sur='LIS'
    and not exists (select 1 from spiss_str S1, slparob O
                    where S1.zrodlo=S0.zrodlo and S1.nr_komp_zr=S0.nr_komp_zr and S1.nr_war=S0.nr_war and O.nr_k_p_obr=S1.nk_obr and O.obr_lacz=6);
  END IF;                  
 RETURN vResult;
END WAR_OD_POLP;
/

CREATE OR REPLACE FUNCTION WAR_DO_POLP(pFUN NUMBER, pNR_KOM_STR NUMBER, pNR_WAR NUMBER) RETURN NUMBER
AS
 vResult NUMBER(2):=0;
BEGIN
 IF pFUN=5 THEN
   select nvl(least(min(decode(S0.rodz_sur,'LIS',S0.nr_war,99)),max(S0.nr_war)),pNR_WAR)
     into vResult
   from spiss_str S0
   where S0.zrodlo='S' and S0.nr_komp_zr=pNR_KOM_STR
     and S0.czy_war=1 and S0.nr_war>pNR_WAR 
     --nie LISTWA lub Listwa bez obrobki polaczeniowej (obr_lacz=6)
     and not (S0.rodz_sur='LIS' and
              exists (select 1 from spiss_str S1, slparob O
                      where S1.zrodlo=S0.zrodlo and S1.nr_komp_zr=S0.nr_komp_zr and S1.nr_war=S0.nr_war and O.nr_k_p_obr=S1.nk_obr and O.obr_lacz=6));
 END IF;                  
 RETURN vResult;
END WAR_DO_POLP;
/
