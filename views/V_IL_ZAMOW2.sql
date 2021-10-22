CREATE OR REPLACE VIEW "V_IL_ZAMOW2" AS 
  select P.nr_kom_zlec, MAX(P.nr_zlec) nr_zlec,
         nvl(nullif(count(E.nr_kom_szyby),0),sum(ilosc)) il_szyb,
         count(E.nr_kom_szyby)-count(nullif(E.zn_wyk,9)) il_anul,-- sum(case when zn_wyk=9 then 1 else 0 end) il_anul,
       sum(case when zn_wyk in (1,2) then 1 else 0 end) il_wyk,
       min(case when zn_wyk=9 then null else data_wyk end) data_wyk_min,
       min(case when zn_wyk=9 then null else flag_real end) flag_real_min,
       min(case when zn_wyk=9 then null else nr_sped end) nr_sped_min,
       min(case when zn_wyk=9 then null else data_sped end) data_sped_min,
       count(case when P.typ_poz='I k' and E.zn_wyk between 1 and 2 then 1 else null end) il_Ik_wyk,
       count(case when P.typ_poz='II ' and E.zn_wyk between 1 and 2 then 1 else null end) il_IIk_wyk,
       count(case when P.typ_poz='I k' and E.zn_wyk not in (1,2,9) then 1 else null end) il_Ik_nwyk,
       count(case when P.typ_poz='II ' and E.zn_wyk not in (1,2,9) then 1 else null end) il_IIk_nwyk
from spisz P
left join spise E on E.nr_komp_zlec=P.nr_kom_zlec and E.nr_poz=P.nr_poz
GROUP BY P.nr_kom_zlec;