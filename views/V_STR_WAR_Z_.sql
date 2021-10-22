DEFINE ZL=2308478;

--select * from V_STR_SKL_SUR_Z
--select nr_poz, nr_kat, nr_kat_dod
select * 
from V_SUROWCE_WAR_Z
where 2=2--nr_kom_zlec=&ZL 
  and czy_war=1 and nr_kat<>nr_kat_dod;

select nr_kom_zlec, nr_zlec, nr_poz, ilosc, szer, wys, pow, obw, szer_obr, wys_obr, nr_kom_str, zn_war, czy_war, nr_war, nr_kat, typ_kat, rodz_sur, nr_kat_dod,,
       case when nr_kat<>nr_kat_dod then '1' else '0' end|| 
from V_SUROWCE_WAR_Z
where nr_kom_zlec=&ZL and czy_war=1 and nr_kat<>nr_kat_dod and zn_sur='Sur';

select * from v_str_skl_sur_z where nr_kom_str=18000;

select nr_kom_zlec, nr_zlec, nr_poz, ilosc, szer, wys, pow, obw, szer_obr, wys_obr, nr_kom_str, zn_war, czy_war, nr_war, nr_kat, typ_kat, rodz_sur, nr_kat_dod,,
       case when nr_kat<>nr_kat_dod then '1' else '0' end|| 
from V_SUROWCE_WAR_Z
where nr_kom_zlec=&ZL and czy_war=1 and nr_kat<>nr_kat_dod and zn_sur='Sur';


CREATE OR REPLACE VIEW "V_STR_WAR_Z" ("NR_KOM_ZLEC", "NR_ZLEC", "NR_KON", "DATA_ZL", "WYROZNIK", "STATUS", "R_DAN", "NR_KONTRAKTU", "NR_POZ", "ILOSC", "SZER", "WYS", "POW", "OBW", "GR_SIL", "NR_KOMP_RYS", "NR_KOM_STR", "NR_WAR", "NR_SKL", "NR_SKL1", "NR_SKL2", "NR_SKL3", "NR_SKL4", "ZN_WAR", "NR_KOM_SKL", "TYP_KAT", "KOD_POLP", "KOD_STR", "NR_KOM_STR1", "NR_KOM_STR2", "NR_KOM_STR3", "NR_KOM_STR4", "POZIOM", "ZN_PP")
AS 
select Z.nr_kom_zlec, Z.nr_zlec, Z.nr_kon, Z.data_zl, Z.wyroznik, Z.status, Z.r_dan, Z.nr_kontraktu,
       P.nr_poz, P.ilosc, P.szer, P.wys, P.pow, P.obw, P.gr_sil, P.nr_komp_rys,
       B.nr_kom_str, row_number() over (partition by Z.nr_kom_zlec, Z.nr_zlec, Z.nr_kon, Z.data_zl, P.nr_poz, B.nr_kom_str, B.kod_str order by B.nr_skl, B1.nr_skl, B2.nr_skl, B3.nr_skl, B4.nr_skl) nr_war,
       B.nr_skl, B1.nr_skl nr_skl1, B2.nr_skl nr_skl2, B3.nr_skl nr_skl3, B4.nr_skl nr_skl4,
       nvl(B4.zn_war,nvl(B3.zn_war,nvl(B2.zn_war,nvl(B1.zn_war,B.zn_war)))) zn_war, 
       nvl(B4.nr_kom_skl,nvl(B3.nr_kom_skl,nvl(B2.nr_kom_skl,nvl(B1.nr_kom_skl,B.nr_kom_skl)))) nr_kom_skl,
       K.typ_kat, S.kod_str kod_polp,
       B.kod_str, B1.nr_kom_str nr_kom_str1, B2.nr_kom_str nr_kom_str2, B3.nr_kom_str nr_kom_str3, B4.nr_kom_str nr_kom_str4,
       case when B4.zn_war='Sur' then 5
            when B3.zn_war='Sur' then 4
            when B2.zn_war='Sur' then 3
            when B1.zn_war='Sur' then 2
            when B.zn_war='Sur' then 1
            when B9.zn_war='Sur' then 9
       else 0 end poziom,
       case when B.zn_war='Pol' then 1
            when B1.zn_war='Pol' then 2
            when B2.zn_war='Pol' then 3
            when B3.zn_war='Pol' then 4
            when B9.zn_war='Sur' then 9
       else 0 end zn_pp
   from zamow Z
   left join spisz P on P.nr_kom_zlec=Z.nr_kom_zlec
   left join budstr B on B.kod_str=P.kod_str
   left join budstr B1 on B.zn_war='Str' and B1.nr_kom_str=B.nr_kom_skl 
   left join budstr B2 on B1.zn_war='Str' and B2.nr_kom_str=B1.nr_kom_skl
   left join budstr B3 on B2.zn_war='Str' and B3.nr_kom_str=B2.nr_kom_skl
   left join budstr B4 on B3.zn_war='Str' and B4.nr_kom_str=B3.nr_kom_skl
   left join (select 'Sur' zn_war from dual) B9 on B4.zn_war='Str' --nienull'owy B9 oznacza ?e zaglebienie do B4 niewystarczajace
   left join katalog K On K.nr_kat=nvl(B4.nr_kom_skl,nvl(B3.nr_kom_skl,nvl(B2.nr_kom_skl,nvl(B1.nr_kom_skl,B.nr_kom_skl))))
   left join struktury S on nvl(B4.zn_war,nvl(B3.zn_war,nvl(B2.zn_war,nvl(B1.zn_war,B.zn_war))))='Pol' and
                            S.nr_kom_str=case when B.zn_war='Pol' then B.nr_kom_skl
                                               when B1.zn_war='Pol' then B1.nr_kom_skl
                                               when B2.zn_war='Pol' then B2.nr_kom_skl
                                               when B3.zn_war='Pol' then B3.nr_kom_skl
                                               when B4.zn_war='Pol' then B4.nr_kom_skl
                                               else 0 end
   --where nvl(B9.zn_war,nvl(B4.zn_war,nvl(B3.zn_war,nvl(B2.zn_war,nvl(B1.zn_war,B.zn_war)))))='Sur'
   where not (nvl(B4.zn_war,nvl(B3.zn_war,nvl(B2.zn_war,nvl(B1.zn_war,B.zn_war))))<>'Pol' and K.rodz_sur not in ('TAF','LIS','TAS'))
   order by B.nr_skl, B1.nr_skl, B2.nr_skl, B3.nr_skl, B4.nr_skl;
