create or replace PROCEDURE ZAPISZ_WSP (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pNR_ZEST NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0)
AS
 ileZest NUMBER;
BEGIN
 IF pNR_ZEST=-1 THEN --wszystkie zestawy
  --@V WPISZ_ATRYBUTY('Z', pNK_ZLEC);
  SELECT to_number(nvl(trim(max(wartosc)),'1'),'9') INTO ileZest FROM param_t WHERE kod=154;
  IF ileZest>0 THEN
   FOR vNrZest IN 0 .. ileZest-1 LOOP
    ZAPISZ_WSP(pNK_ZLEC, pPOZ, vNrZest, pNR_OBR);
   END LOOP;
  END IF;
 ELSE --1 zestaw (pNR_ZEST)
  IF pNK_ZLEC>0 THEN 
   INSERT INTO wsp_alter (nr_zestawu, nr_komp_inst, nr_kom_zlec, nr_poz, jaki, nr_porz_obr, wsp_alt)
   SELECT pNR_ZEST, V.nk_inst, V.nr_kom_zlec, V.nr_poz, decode(V.nk_inst,V.inst_std,3,2), V.nr_porz, 
         --V_SPISS zawiera WSP_PRZEL dla zestawu=0
         --je¿eli wywolanie zapisu wsp. dla pNR_ZEST>0 to wyliczanie wsp. przy uzyciu funkcji WSP_WG_TYPU_INST i WSP_12ZAKR dla tego numeru zestawu
         case when pNR_ZEST=0 then V.wsp_przel
              else nvl(WSP_WG_TYPU_INST(V.typ_inst, nvl(wsp_12zakr(V.nk_inst,V.pow,V.ident_bud,pNR_ZEST),1), V.wsp_c_m, V.wsp_har, V.wsp_HO, V.wsp_dod, V.znak_dod),0)
         end wsp_przel
   FROM v_spiss V
   LEFT JOIN wsp_alter W ON W.nr_zestawu=pNR_ZEST and W.nr_komp_inst=V.nk_inst and W.nr_kom_zlec=V.nr_kom_zlec and W.nr_poz=V.nr_poz and W.nr_porz_obr=V.nr_porz
   WHERE V.zrodlo='Z' AND V.nr_kom_zlec=pNK_ZLEC
     AND pPOZ in (0,V.nr_poz) AND pNR_OBR in (0,V.nk_obr) 
     AND W.nr_kom_zlec is null;
   --zapisanie oddzielnie WSP_4ZAKR dla inst. z jedn. CZAS dla NR_PORZ ze strony 0 ka¿dej warstwy
   INSERT INTO wsp_alter (nr_zestawu, nr_komp_inst, nr_kom_zlec, nr_poz, jaki, nr_porz_obr, wsp_alt)
   SELECT DISTINCT W.nr_zestawu, W.nr_komp_inst, W.nr_kom_zlec, W.nr_poz, 0, S0.nr_porz,
          --ilosc MINUT lub GODZIN (w zaleznosci od jedn. inst.)
          wsp_4zakr(W.nr_komp_inst,S0.szer*0.001*S0.wys*0.001,S0.ident_bud, S0.nr_kat,1,0)--czas z 4 zakr. pow w sek.
          /decode(trim(I.jedn),'mi',60,'ho',60*60,1)
   FROM wsp_alter W
   JOIN parinst I on I.nr_komp_inst=W.nr_komp_inst and I.jedn in ('ho','mi')
   JOIN spiss S on S.zrodlo='Z' and S.nr_komp_zr=W.nr_kom_zlec and S.nr_kol=W.nr_poz and S.nr_porz=W.nr_porz_obr
   JOIN spiss S0 on S0.zrodlo='Z' and S0.nr_komp_zr=S.nr_komp_zr and S0.nr_kol=S.nr_kol and S0.etap=S.etap and S0.czy_war=1 and S0.strona=0
                               and S.war_od BETWEEN S0.war_od AND S0.war_do
   LEFT JOIN wsp_alter W1 ON W1.nr_zestawu=pNR_ZEST and W1.nr_komp_inst=W.nr_komp_inst and W1.nr_kom_zlec=W.nr_kom_zlec and W1.nr_poz=W.nr_poz and W1.nr_porz_obr=S0.nr_porz
   WHERE W.nr_zestawu=pNR_ZEST AND W.nr_kom_zlec=pNK_ZLEC AND pPOZ in (0,W.nr_poz)
     AND W1.nr_kom_zlec is null;
   
  ELSE
   INSERT INTO wsp_alter (nr_zestawu, nr_komp_inst, nr_kom_zlec, nr_poz, jaki, nr_porz_obr, wsp_alt)
   SELECT pNR_ZEST, V.nk_inst, V.nr_kom_zlec, V.nr_poz, decode(V.nk_inst,V.inst_std,3,2), V.nr_porz, 
         --V_SPISS zawiera WSP_PRZEL dla zestawu=0
         --je¿eli wywolanie zapisu wsp. dla pNR_ZEST>0 to wyliczanie wsp. przy uzyciu funkcji WSP_WG_TYPU_INST i WSP_12ZAKR dla tego numeru zestawu
         case when pNR_ZEST=0 then V.wsp_przel
              else nvl(WSP_WG_TYPU_INST(V.typ_inst, nvl(wsp_12zakr(V.nk_inst,V.pow,V.ident_bud,pNR_ZEST),1), V.wsp_c_m, V.wsp_har, V.wsp_HO, V.wsp_dod, V.znak_dod),0)
         end wsp_przel
   FROM v_spiss V
   LEFT JOIN wsp_alter W ON W.nr_zestawu=pNR_ZEST and W.nr_komp_inst=V.nk_inst and W.nr_kom_zlec=V.nr_kom_zlec and W.nr_poz=V.nr_poz and W.nr_porz_obr=V.nr_porz
   WHERE V.zrodlo='Z' --AND (pNK_ZLEC>0 and V.nr_kom_zlec=pNK_ZLEC or pNK_ZLEC=0)
     AND pPOZ in (0,V.nr_poz) AND pNR_OBR in (0,V.nk_obr) 
     AND W.nr_kom_zlec is null;  
  END IF;
 END IF;   

END ZAPISZ_WSP;
/
