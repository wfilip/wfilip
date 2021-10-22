create or replace procedure WPISZ_INST_LWYC2(pNK_ZLEC NUMBER, pNR_POZ NUMBER, pNR_PORZ NUMBER, pNR_SZT NUMBER, pNK_INST NUMBER, pNK_INST_POW NUMBER, pNK_ZM NUMBER default null)
AS
  rec_pow NUMBER(6):=0;
  vNrObr NUMBER(4);
  vNrCiagu NUMBER(2);
  vNkInstLIS NUMBER(6);
  vKolejnInst NUMBER(3);
  vKolejnInstPow NUMBER(3);
  vWDR NUMBER(3):=0;
BEGIN
 IF PKG_PLAN_SPISS.vWDR=0 THEN SELECT nr_wdr INTO PKG_PLAN_SPISS.vWDR FROM firma; END IF;
 IF PKG_PLAN_SPISS.vWDR=11 THEN
  SELECT nvl(max(kolejn),0) INTO vKolejnInst FROM parinst WHERE nr_komp_inst=pNK_INST;
  SELECT nvl(max(kolejn),0) INTO vKolejnInstPow FROM parinst WHERE nr_komp_inst=pNK_INST_POW;
  vWDR:=PKG_PLAN_SPISS.vWDR;
 END IF;

 UPDATE l_wyc2
    SET nr_inst_plan=pNK_INST, nr_zm_plan=nvl(pNK_ZM,nr_zm_plan), kolejn=case when vWDR=11 then floor(kolejn*0.01)*100+vKolejnInst else kolejn end
 WHERE nr_kom_zlec=pNK_ZLEC and nr_poz_zlec=pNR_POZ and nr_porz_obr=pNR_PORZ and pNR_SZT in (0,nr_szt)
 RETURNING min(nr_obr) INTO vNrObr;

 IF pNK_INST_POW>0 THEN
  Select count(1) Into rec_pow
  From gr_inst_dla_obr
  Where nr_komp_obr=vNrObr and nr_komp_inst=pNK_INST_POW;
 END IF;
 IF rec_pow>0 THEN
  rec_pow:=0;
  UPDATE l_wyc2 SET nr_inst_plan=pNK_INST_POW, nr_zm_plan=nvl(pNK_ZM,nr_zm_plan)
  WHERE nr_kom_zlec=pNK_ZLEC and nr_poz_zlec=pNR_POZ and nr_porz_obr=1500+pNR_PORZ and pNR_SZT in (0,nr_szt)
  RETURNING count(1) INTO rec_pow;
  IF rec_pow=0 THEN
   INSERT INTO l_wyc2 (nr_kom_zlec, nr_poz_zlec, nr_szt, nr_warst, war_do, nr_obr, nr_porz_obr, nr_inst_plan, nr_zm_plan, nr_inst_wyk, nr_zm_wyk, kolejn, flag)
    SELECT nr_kom_zlec, nr_poz_zlec, nr_szt, nr_warst, war_do, nr_obr, nr_porz_obr+1500, pNK_INST_POW, nr_zm_plan, 0, 0, decode(vWDR,11,floor(kolejn*0.01)*100+vKolejnInstPow,kolejn+1), 0
    FROM l_wyc2
    WHERE nr_kom_zlec=pNK_ZLEC and nr_poz_zlec=pNR_POZ and nr_porz_obr=pNR_PORZ and pNR_SZT in (0,nr_szt);
  END IF;
 ELSE
  DELETE FROM l_wyc2
  WHERE nr_kom_zlec=pNK_ZLEC and nr_poz_zlec=pNR_POZ and nr_porz_obr=1500+pNR_PORZ and pNR_SZT in (0,nr_szt);
 END IF;

 IF vNrObr=99 THEN -- gdy MON to automatyczna aktualizacja giêtarek
  NULL;--ZMIEN_GIETARKE (pNK_ZLEC, pNR_POZ, pNK_INST, pNK_ZM);
 END IF;
END WPISZ_INST_LWYC2;
