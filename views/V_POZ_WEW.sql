CREATE OR REPLACE VIEW "V_POZ_WEW" ("NR_KOM_ZLEC", "NR_POZ", "NR_KOM_ZLEC_WEW", "NR_POZ_ZLEC_WEW", "DO_WAR", "ILOSC", "SZER", "WYS", "POW", "OBW", "TYP_POZ", "KOD_STR")
AS 
  select nr_kom_zlec, nr_poz, null nr_kom_zlec_wew, null nr_poz_zlec_wew, null do_war, ilosc, szer, wys, pow, obw, typ_poz, kod_str from spisz
union
select ZP.nr_komp_zlec, P.nr_poz_pop, P.nr_kom_zlec, P.nr_poz, to_number(regexp_substr(ZT.linia,'\d+')),  ilosc, szer, wys, pow, obw, typ_poz, P.kod_str
from 
(select distinct nr_komp_zlec, nr_zlec_wew from zlec_polp) ZP
left join spisz P on typ_zlec='Pro' and nr_zlec=nr_zlec_wew
left join zlec_typ ZT on ZT.nr_komp_zlec=P.nr_kom_zlec and ZT.nr_poz=P.nr_poz and ZT.typ=202
order by 1,2,3 nulls first,4;