create or replace PROCEDURE USTAL_INST (pZRODLO CHAR, pNK_ZLEC NUMBER, pNR_POZ NUMBER DEFAULT 0, pNK_OBR NUMBER DEFAULT 0)
AS
 CURSOR c1 IS
  SELECT V.nr_poz, V.nr_porz, V.nk_inst, V.inst_std, V.nr_inst_pow, --V.wsp_przel         
         kryt_wym_max, kryt_grub_pak, kryt_waga_pak, kryt_waga_1mb, kryt_waga_elem,
         kryt_wym_min, kryt_atryb_wyl, V.kryt_atryb, V.kryt_suma, V.obsl_tech
  FROM v_spiss V
  WHERE V.zrodlo=pZRODLO and V.nr_kom_zlec=pNK_ZLEC and pNR_POZ in (0,V.nr_poz) and pNK_OBR in (0,V.nk_obr) and V.gr_akt<2
  ORDER BY V.zrodlo, V.nr_kom_zlec, V.nr_poz, V.nr_porz, decode(V.nk_inst,V.inst_std,1,2), V.kolejnosc_z_grupy;   
 
 CURSOR c2 (pINST NUMBER, pPOZ NUMBER, pPORZ NUMBER, pKRYT_ATR NUMBER, pKRYT_MAX NUMBER, pKRYT_MIN NUMBER)  IS
  SELECT V.nk_inst, V.nr_inst_pow --, kryt_suma, I.nr_inst_max, I.nr_inst_min, I.nr_inst_wyl
  FROM v_spiss V
  INNER JOIN parinst I on I.nr_komp_inst=pINST
  WHERE V.zrodlo=pZRODLO and V.nr_kom_zlec=pNK_ZLEC and V.nr_poz=pPOZ and V.nr_porz=pPORZ and V.gr_akt<2
  AND (pKRYT_ATR=1 and V.nk_inst=I.nr_inst_wyl OR
       pKRYT_MAX=1 and V.nk_inst=I.nr_inst_max OR
       pKRYT_MIN=1 and V.nk_inst=I.nr_inst_min)
  AND V.kryt_suma=0
  ORDER BY decode(V.nk_inst,I.nr_inst_wyl,1,I.nr_inst_max,2,I.nr_inst_min,3,9);
  
  rec1 c1%ROWTYPE;
  currPoz NUMBER(4):=0;
  currObr NUMBER(4):=0;
  vObrOK BOOLEAN:=false;
  vInstOK BOOLEAN:=false;
  vNieSzukajDalej BOOLEAN;
  vInstAlternatywna NUMBER(10);
BEGIN
  OPEN c1;
  LOOP
    FETCH c1 INTO rec1;
    EXIT WHEN c1%NOTFOUND;
    vInstOK:=rec1.kryt_suma=0 or rec1.obsl_tech=1;
    --NOWA POZYCJA LUB OBRÓBKA
    IF currPoz<>rec1.nr_poz or currObr<>rec1.nr_porz THEN      
      --je¿eli wybrana inst (INST_STD) jest OK to nie trzeba nic zmieniaæ
      vObrOK:=rec1.nk_inst=rec1.inst_std and vInstOK;
      currPoz:=rec1.nr_poz;
      currObr:=rec1.nr_porz;
      vNieSzukajDalej:=rec1.kryt_atryb=1 and vObrOK; --kryt_atryb: 1 atrybut pasuj¹cy   2 pusty atrybut kieruj¹cy na inst
      USTAW_INST(pNK_ZLEC,rec1.nr_poz,rec1.nr_porz,0,rec1.nk_inst,rec1.nr_inst_pow);
    END IF;
    --sprawdzanie pozostalych instalacji
    IF vInstOK AND (not vObrOK and rec1.kryt_atryb in (1,2) --1 atrybut pasuj¹cy   2 pusty atrybut kieruj¹cy na inst
                    or not vNieSzukajDalej and rec1.kryt_atryb=1) THEN  --wybrana tylko pierwsza instalacja z atrybutem kieruj¹cym
      vObrOK := true;
      vNieSzukajDalej:=rec1.kryt_atryb=1;
      USTAW_INST(pNK_ZLEC,rec1.nr_poz,rec1.nr_porz,0,rec1.nk_inst,rec1.nr_inst_pow);
    --czy jest przekierowanie w PARINST
    ELSIF not vInstOK AND not vObrOK AND greatest(rec1.kryt_atryb_wyl,rec1.kryt_wym_min,rec1.kryt_wym_max,rec1.kryt_grub_pak,rec1.kryt_waga_pak,rec1.kryt_waga_1mb,rec1.kryt_waga_elem)>0 THEN
     OPEN c2 (rec1.nk_inst, rec1.nr_poz, rec1.nr_porz, rec1.kryt_atryb_wyl, sign(rec1.kryt_wym_max+rec1.kryt_grub_pak+rec1.kryt_waga_pak+rec1.kryt_waga_1mb+rec1.kryt_waga_elem), rec1.kryt_wym_min);
     LOOP
      FETCH c2 INTO vInstAlternatywna, rec1.nr_inst_pow;
      EXIT WHEN c2%NOTFOUND;
      IF vInstAlternatywna>0 THEN 
       vObrOK := true;
       vNieSzukajDalej:=true;
       USTAW_INST(pNK_ZLEC,rec1.nr_poz,rec1.nr_porz,0,vInstAlternatywna,rec1.nr_inst_pow);
       EXIT; --wa¿ny tylko 1. rekord
      END IF;
     END LOOP;
     CLOSE c2;     
    END IF;
  END LOOP;
  CLOSE c1;
  
  IF pNK_OBR=0 THEN 
   --zmieñ instalacje wg GR_INST_POW (wg inst MON)
   PKG_PLAN_SPISS.WPISZ_INST_WG_CIAGU(pNK_ZLEC,pNR_POZ);
   --popraw ilosc wpisow dla instalacji powiazanych
   PKG_PLAN_SPISS.LWYC2_INST_POW(pNK_ZLEC,pNR_POZ);
   --popraw instalacje dla obrobek jednoczesnych
   PKG_PLAN_SPISS.POPRAW_OBR_JEDNOCZ(pNK_ZLEC,pNR_POZ,0);
  ELSE
   PKG_PLAN_SPISS.WPISZ_INST_WG_CIAGU(pNK_ZLEC,pNR_POZ,trim(to_char(pNK_OBR)));
   PKG_PLAN_SPISS.LWYC2_INST_POW(pNK_ZLEC,pNR_POZ,to_char(pNK_OBR));
   FOR v IN (select distinct nr_obr_jednocz from v_obr_jednocz where nr_komp_obr=pNK_OBR) LOOP
    PKG_PLAN_SPISS.POPRAW_OBR_JEDNOCZ(pNK_ZLEC,pNR_POZ,v.nr_obr_jednocz);
    --raise invalid_number;
    --USTAW_WSP(pNK_ZLEC, v.nr_komp_obr);
   END LOOP;
  END IF;
END USTAL_INST;
/