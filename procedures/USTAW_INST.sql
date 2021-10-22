create or replace PROCEDURE USTAW_INST (pNK_ZLEC NUMBER, pNR_POZ NUMBER, pNR_PORZ NUMBER, pNK_OBR NUMBER, pNK_INST NUMBER, pNK_INST_POW NUMBER DEFAULT null, pNK_ZM NUMBER DEFAULT null)
AS
 vInstPow NUMBER(10):=pNK_INST_POW;
  vNrCiagu NUMBER(2);
  vNkInstLIS NUMBER(6);
BEGIN
  IF pNK_INST_POW is null THEN
   SELECT nr_inst_pow INTO vInstPow FROM parinst WHERE nr_komp_inst=pNK_INST;
  END IF;
  IF pNK_ZLEC*pNR_POZ*pNR_PORZ>0 THEN
   --ustawienie w kolumnie JAKI informacji, ktora instalacja wybrana (ewentualnei ktora powi¹zana do wybranej)
   UPDATE wsp_alter
   SET jaki=decode(nr_komp_inst,pNK_INST,3,vInstPow,4,2)
   WHERE nr_kom_zlec=pNK_ZLEC and nr_poz=pNR_POZ and nr_porz_obr=pNR_PORZ;
   --aktualizacja inst. L_WYC2
   WPISZ_INST_LWYC2(pNK_ZLEC,pNR_POZ,pNR_PORZ,0,pNK_INST,vInstPow,pNK_ZM);
  ELSIF pNK_ZLEC*pNR_POZ*pNK_OBR>0 THEN
   FOR rec IN (select V.nr_poz, V.nr_porz, V.nr_inst_pow from v_spiss V where V.zrodlo='Z' and V.nr_kom_zlec=pNK_ZLEC and V.nr_poz=pNR_POZ and V.nk_obr=pNK_OBR and V.nk_inst=pNK_INST)
    LOOP
     USTAW_INST(pNK_ZLEC,rec.nr_poz,rec.nr_porz,0,pNK_INST,rec.nr_inst_pow,pNK_ZM);
    END LOOP;
  ELSIF pNK_ZLEC*pNK_OBR>0 THEN
   FOR rec IN (select V.nr_poz, V.nr_porz, V.nr_inst_pow from v_spiss V where V.zrodlo='Z' and V.nr_kom_zlec=pNK_ZLEC and V.nk_obr=pNK_OBR and V.nk_inst=pNK_INST)
    LOOP
     USTAW_INST(pNK_ZLEC,rec.nr_poz,rec.nr_porz,0,pNK_INST,rec.nr_inst_pow,pNK_ZM);
    END LOOP;
  END IF;
END USTAW_INST;
/