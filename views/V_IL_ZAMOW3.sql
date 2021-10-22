CREATE OR REPLACE VIEW "V_IL_ZAMOW3" AS 
  select P.nr_kom_zlec, MAX(P.nr_zlec) nr_zlec, sum(ilosc) il_szyb, sum(pow) pow,
       sum(case when P.typ_poz='I k' then ilosc else 0 end) il_Ik,
       sum(case when P.typ_poz='II ' then ilosc else 0 end) il_IIk,
       sum(case when P.typ_poz='I k' then ilosc*pow else 0 end) pow_Ik,
       sum(case when P.typ_poz='II ' then ilosc*pow else 0 end) pow_IIk,
       sum(case when ILE_LISTEW(P.kod_str)=1 then ilosc else 0 end) il_1LIS,
       sum(case when ILE_LISTEW(P.kod_str)>1 then ilosc else 0 end) il_2LIS,
       sum(case when ILE_LISTEW(P.kod_str)=1 then ilosc*pow else 0 end) pow_1LIS,
       sum(case when ILE_LISTEW(P.kod_str)>1 then ilosc*pow else 0 end) pow_2LIS
from spisz P
GROUP BY P.nr_kom_zlec;