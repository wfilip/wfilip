CREATE OR REPLACE VIEW V_TAF_NA_ZM
AS
SELECT nr_komp_instal, nr_kat, O.typ_kat, nr_komp_zmw, d_wyk, zm_wyk, O.szer, O.wys,
       count(1) ilosc_tafli,
       sum(wyc_netto) pow_netto, sum(wyc_brutto) pow_brutto,
       sum(wyc_netto*waga) waga_netto, sum(wyc_brutto*waga) waga_brutto,
       sum((wyc_brutto-wyc_netto)*waga) waga_strat
FROM opt_taf O 
LEFT JOIN katalog using (nr_kat)
WHERE flag=3
GROUP BY nr_komp_instal, nr_kat, O.typ_kat, nr_komp_zmw, d_wyk, zm_wyk, O.szer, O.wys;
/
