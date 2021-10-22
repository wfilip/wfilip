
  CREATE OR REPLACE FORCE VIEW "V_WYK_WG_INST" ("NR_KOM_ZLEC", "NR_INST", "IL_WYK", "ILE_PLAN", "IL_BR", "ZN_WYROBU", "KOLEJN") AS 
  SELECT  L.nr_kom_zlec,L.Nr_inst,
count(case when (case when L.zn_wyrobu=1 and L.wyroznik<>'B' then E.data_wyk
when Lb.id_rek_br_ost is not null then L2.d_wyk
else L.d_wyk
end) > To_date('2001/01/01' ,'YYYY/MM/DD')
then 1 else null end) il_wyk,
count(1) ile_plan,
nvl(sum(Lb.il_br),0) il_br,  --sum(decode(L.zn_braku,1,1,0)) il_br,
L.zn_wyrobu, --L.kolejn
(select kolejn from parinst where parinst.nr_komp_inst=L.nr_inst) kolejn
FROM l_wyc L
LEFT JOIN spise E on E.nr_komp_zlec=L.nr_kom_zlec and E.nr_poz=L.nr_poz_zlec and E.nr_szt=L.nr_szt
LEFT JOIN (select count(1) il_br, max(id_rek) id_rek_br_ost, id_oryg from l_wyc where id_oryg>0 group by id_oryg) Lb
ON Lb.id_oryg=L.id_rek
LEFT JOIN l_wyc L2 ON L2.id_rek=Lb.id_rek_br_ost  --rekord ostatniego braku
WHERE (L.typ_inst not in ('MON','STR') or L.nr_warst=1)
AND (L.typ_inst in ('A C','R C','MON','STR')
OR EXISTS
(select 1 from spisd D0, katalog K, wykzal W
where D0.nr_kom_zlec=L.nr_kom_zlec and D0.nr_poz=L.nr_poz_zlec and D0.do_war=L.nr_warst and D0.strona=0
and K.nr_kat=D0.nr_kat
and W.nr_komp_zlec=D0.nr_kom_zlec and W.nr_poz=D0.nr_poz and W.nr_warst=D0.do_war and W.nr_komp_instal=L.nr_inst
--obróbka nie jest na warstiwe pólproduktu LUB nie jest obróbk¹ ze SPISD (pochodzi ze struktury a nie z drzewa)
and (K.rodz_sur<>'POL' or
not exists (select 1 from spisd D
where D.nr_kom_zlec=W.nr_komp_zlec and D.nr_poz=W.nr_poz and D.do_war=W.nr_warst and D.nr_komp_obr=W.nr_komp_obr))
)
)
GROUP BY  L.nr_kom_zlec,L.Nr_inst,L.zn_wyrobu;
 
