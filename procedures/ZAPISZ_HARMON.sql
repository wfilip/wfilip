--DESC dodanie warunku V.il_obr>0
create or replace PROCEDURE ZAPISZ_HARMON (pNK_ZLEC IN NUMBER, pINST IN NUMBER DEFAULT 0)
AS
BEGIN
  --DELETE FROM harmon WHERE nr_komp_zlec=pNK_ZLEC and pINST in (0,nr_komp_inst);
  INSERT INTO harmon (nr_komp_zlec, typ_harm, nr_oddz, rok, mies,  
                     nr_komp_inst, nr_inst, typ_inst, nr_komp_zm, dzien, zmiana,
                     ilosc, wielkosc, il_z_zam, dane_z_zam,
                     zatwierdz, spad, godz_pocz, godz_kon, kol_na_zm)--, awaria)
   SELECT V.nr_kom_zlec, 'P', (select nr_odz from firma), to_number(to_char(PKG_CZAS.NR_ZM_TO_DATE(V.nr_zm_plan),'YYYY'),'9999'), to_number(to_char(PKG_CZAS.NR_ZM_TO_DATE(V.nr_zm_plan),'MM'),'99'),
          V.nr_inst_plan, max(I.nr_inst), max(substr(I.ty_inst,1,3)), V.nr_zm_plan, PKG_CZAS.NR_ZM_TO_DATE(V.nr_zm_plan), PKG_CZAS.NR_ZM_TO_ZM(V.nr_zm_plan),
          --count(decode(symb_obr,'DECOAT',null,1)), sum(V.il_obr*V.wsp_p), round(sum(V.wsp_p)), sum(V.il_obr),
          count(nullif(V.obr_jednocz,1)), sum(V.il_obr*V.wsp_p),
          round(sum(decode(I.jedn,'mi',decode(V.ktora_obr_na_inst,1,1,0)*V.wsp_p0 + V.ile_wpisow*V.czas_przezbr_min + V.il_obr*V.wsp_p, --czas za(roz)ladunku+czas przezbrojenia+czas wyk. obr.
                           decode(V.obr_jednocz,1,0,1)*V.il_obr*V.wsp_p/V.il_obr))),
          sum(V.il_obr), --IL_Z_ZAM <- Ilosc sztuk przelicz.
          0, 0, '000000', '000000', 0   --,decode(max(V.zakl_kol_pop+V.zakl_kol_nast),0,0,3)
   FROM v_wyc2 V
--   LEFT JOIN spisz P ON P.nr_kom_zlec=V.nr_kom_zlec and P.nr_poz=V.nr_poz_zlec       
--   LEFT JOIN slparob O ON O.nr_k_p_obr=V.nr_obr
   LEFT JOIN parinst I ON I.nr_komp_inst=V.nr_inst_plan
--   LEFT JOIN kat_gr_plan G ON G.typ_kat=V.indeks AND G.nkomp_instalacji=V.nr_inst_plan
   WHERE V.nr_kom_zlec=pNK_ZLEC and V.nr_zm_plan>0 and pINST in (0,V.nr_inst_plan)
     AND V.il_obr>0
   GROUP BY V.nr_kom_zlec, V.nr_inst_plan, V.nr_zm_plan;
EXCEPTION WHEN OTHERS THEN
 ZAPISZ_LOG('ZAPISZ_HARMON',pNK_ZLEC,'C',0);
 ZAPISZ_ERR(SQLERRM);
 RAISE;
END ZAPISZ_HARMON;
/