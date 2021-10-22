CREATE OR REPLACE VIEW V_ZLEC_WYC
AS
SELECT D.nr_kom_zlec, max(D.nr_zlec) nr_zlec, D.nr_poz, D.do_war nr_war, max(D.nr_kat) nr_kat, max(katalog.typ_kat) indeks, max(P.ilosc) il_calk, count(1) il_rek,
       max(D.szer_obr) szer, max(D.wys_obr) wys, max(D4.szer_obr) szer_c, max(D4.wys_obr) wys_c,
       decode(max(P.nr_komp_rys),0,max(P.nr_kszt),max(to_number(strtoken(strtoken(T15.linia,2,';'),2,':')))) nr_kszt, max(P.nr_komp_rys) nr_rys,
       max(K.nr_grupy) nr_gr, count(distinct K.rack_no) ile_kom, min(K.rack_no) rack_od, max(K.rack_no) rack_do,-- round((max(K.rack_no)-min(K.rack_no))/(count(1)),2) przeskok_kom
       min(K.nr_optym) nr_opt, decode(max(K.nr_optym),0,0,count(distinct K.nr_optym*1000+K.nr_taf)) ile_taf,
       opis_ksztaltu(nvl2(max(T15.typ),strtoken(max(T15.linia),4,';'),strtoken(max(T13.linia),2,'|'))) par_kszt,
       ' ' typ_linia, max(T13.linia) typ13_linia, max(T15.linia) typ15_linia
FROM spisd D
LEFT JOIN spisd D4 on D4.nr_kom_zlec=D.nr_kom_zlec and D4.nr_poz=D.nr_poz and D4.do_war=D.do_war and D4.strona=4
LEFT JOIN spisz P on P.nr_kom_zlec=D.nr_kom_zlec and P.nr_poz=D.nr_poz
LEFT JOIN zlec_typ T13 on T13.nr_komp_zlec=D.nr_kom_zlec and T13.nr_poz=D.nr_poz and T13.typ=13
LEFT JOIN zlec_typ T15 on T15.nr_komp_zlec=D.nr_kom_zlec and T15.nr_poz=D.nr_poz and T15.typ=15+D.do_war-1
LEFT JOIN katalog on katalog.nr_kat=D.nr_kat
LEFT JOIN kol_stojakow K on K.nr_komp_zlec=D.nr_kom_zlec and K.nr_poz=D.nr_poz and K.nr_warstwy=D.do_war
WHERE --D.nr_kom_zlec in (      10243) and 
      D.strona=0 and katalog.rodz_sur='TAF'
GROUP BY D.nr_kom_zlec, D.nr_poz, D.do_war--, K.nr_grupy
ORDER BY D.nr_kom_zlec, max(D.nr_kat), D.nr_poz, D.do_war;
/