select V.*
from v_warstwy V
--left join struktury T on T.kod_str=P.kod_str
--left join spisz P on V.nr_kom_zlec=P.nr_kom_zlec and V.nr_poz=P.nr_poz
where V.rodz_sur='TAF' and exists (select 1 from spiss_str S where S.zrodlo='Z' and S.nr_komp_zr=V.nr_kom_zlec and S.nr_kol=V.nr_poz and S.nr_kat=6100 and V.do_war in (S.nr_war-1,S.nr_war+1))
  and V.NR_KOM_ZLEC=:ZL;

CREATE OR REPLACE VIEW V_SUR_OGNIOCH
AS
select nr_kom_zlec, nr_poz, nr_kat, max(typ_kat) typ_kat,
       sum(pow_rzecz) pow_rzecz, sum(szer_obr_c*0.001*wys_obr_c*0.001) pow_obr_netto,
       sum(szer_obr_c*0.001*wys_obr_c*0.001)*
        nvl((select max(O.wyc_brutto/O.wyc_netto) from opt_nr O, opt_zlec Z where O.nr_opt=Z.nr_opt and Z.nr_komp_zlec=V.nr_kom_zlec and Z.nr_poz=V.nr_poz and O.nr_kat=V.nr_kat),
            1/(1-(select n_strat*0.01 from katalog K where K.nr_kat=V.nr_kat))) pow_obr_brutto --B=N/(1-S)           
from v_warstwy V
--left join struktury T on T.kod_str=P.kod_str
--left join spisz P on V.nr_kom_zlec=P.nr_kom_zlec and V.nr_poz=P.nr_poz
where V.rodz_sur='TAF' and exists (select 1 from spiss_str S where S.zrodlo='Z' and S.nr_komp_zr=V.nr_kom_zlec and S.nr_kol=V.nr_poz and S.nr_kat=6100 and V.do_war in (S.nr_war-1,S.nr_war+1))
--  and V.NR_KOM_ZLEC=:ZL
group by nr_kom_zlec, nr_poz, nr_kat;

SELECT nr_kat, typ_kat, pow_obr_netto, pow_obr_brutto
FROM v_sur_ognioch V
WHERE V.NR_KOM_ZLEC=:ZL and V.nr_poz=:POZ;

DROP VIEW v_sur_ognioch;

select * from zlec_typ where typ=13 and nr_komp_zlec=:ZL;
  
select * from gte2018.opt_nr;
select * from spise where zn_wyk=9 order by nr_kom_szyby desc;

select * from gz2018.katalog where rodz_sur='TAF';