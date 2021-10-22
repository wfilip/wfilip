--select * from v_zmiany where nr_komp_inst=8 and dzien>=sysdate;


CREATE OR REPLACE FORCE VIEW "V_ZMIANY" ("TYP_HARM", "NR_KOMP_INST", "NR_KOMP_ZM", "DZIEN", "ZMIANA", "IL_PLAN", "ILOSC", "DANE_Z_ZAM", "WIELK_PLAN", "WIELKOSC", "IL_SZT_PRZEL", "DL_ZMIANY", "ZATWIERDZ", "FLAG_D") AS 
  SELECT 'P' typ_harm, nr_komp_inst, nr_komp_zm, dzien, zmiana, il_plan, nvl(ilosc,0) ilosc, nvl(dane_z_zam,0) dane_z_zam, wielk_plan, nvl(wielkosc,0) wielkosc, nvl(il_szt_przel,0) il_szt_przel, dl_zmiany, zatwierdz,
       nvl2(nullif(il_plan,nvl(ilosc,0)),'0','1') || nvl(flag_h,'1') flag_d
 FROM zmiany Z
 LEFT JOIN
 (select typ_harm, nr_komp_inst, dzien, zmiana, sum(ilosc) ilosc, sum(wielkosc) wielkosc, sum(dane_z_zam) dane_z_zam, sum(il_z_zam) il_szt_przel,
         min(case when ilosc=il_z_zam and wielkosc<>dane_z_zam then 0 else 1 end) flag_h
  from harmon
  where typ_harm='P'
  group by nr_komp_inst, typ_harm, dzien, zmiana) H
 USING (nr_komp_inst, dzien, zmiana);
 
 
