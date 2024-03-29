--mozliwe �e konieczna kompilacja GET_PARAM_T

create or replace PROCEDURE GEN_LWYC (pFUN IN NUMBER, pNR_KOM_ZLEC IN NUMBER, pNR_POZ NUMBER DEFAULT 0, pSKIP_ERR NUMBER DEFAULT 0)
AS 
 --pozycje
 CURSOR cP IS
  SELECT nr_poz, ilosc, typ_poz, ind_bud FROM spisz WHERE nr_kom_zlec=pNR_KOM_ZLEC and pNR_POZ in (0,nr_poz);
 --warstwy
 CURSOR c1 (pPOZ NUMBER) IS
  SELECT S.* FROM spiss S
  WHERE S.zrodlo='Z' AND S.nr_komp_zr=pNR_KOM_ZLEC and S.nr_kol=pPOZ
    and S.czy_war=1 and strona=0 --and etap=1
  ORDER BY S.nr_kol, S.etap, S.war_od
  ; --@V FOR UPDATE;
 --operacje na warstwie
 CURSOR c2 (pPOZ NUMBER, pWAR NUMBER, pETAP NUMBER) IS
  SELECT S.*, I.kolejn kolejn_inst         
  FROM spiss S
  LEFT JOIN parinst I on I.nr_komp_inst=S.inst_std
  WHERE S.zrodlo='Z' AND S.nr_komp_zr=pNR_KOM_ZLEC AND S.nr_kol=pPOZ AND pWAR between S.war_od and S.war_do AND S.etap=pETAP AND S.zn_plan>0
  ORDER BY S.etap, S.zn_plan, S.nk_obr;
 --ci�g prod. (dla calej Poz.)
 CURSOR c4 (pPOZ NUMBER) IS
  SELECT distinct naz2, kolejn
  FROM (select distinct nr_poz_zlec, nr_inst_plan nr_komp_inst from l_wyc2 where nr_kom_zlec=pNR_KOM_ZLEC)
  LEFT JOIN parinst USING (nr_komp_inst)
  WHERE pPOZ in (0,nr_poz_zlec) AND trim(naz2) is not null
  ORDER BY kolejn;
  recP cP%ROWTYPE;
  recW c1%ROWTYPE;
  recO c2%ROWTYPE;
  --recL c3%ROWTYPE;
  rec4 c4%ROWTYPE;
  str1 VARCHAR2(100);
  str2 VARCHAR2(100);
  etap_pam NUMBER:=0;
  vKolejn NUMBER;
  jestHARMON NUMBER(1);
  jestLWYC NUMBER(1);
  par152 NUMBER(1);
  vWDR NUMBER(3);
BEGIN
 par152:=GET_PARAM_T(152,0);
 SELECT nr_wdr INTO vWDR FROM firma;
 
 SELECT count(1) INTO jestHARMON FROM dual WHERE exists (select 1 from harmon where nr_komp_zlec=pNR_KOM_ZLEC);
 IF par152>1 AND jestHARMON=0 THEN
  DELETE FROM l_wyc WHERE nr_kom_zlec=pNR_KOM_ZLEC and pNR_POZ in (0,nr_poz_zlec) and nr_inst_wyk=0;
 END IF;
 SELECT count(1) INTO jestLWYC   FROM dual WHERE exists (select 1 from l_wyc where nr_kom_zlec=pNR_KOM_ZLEC);
 
 DELETE FROM l_wyc2 WHERE nr_kom_zlec=pNR_KOM_ZLEC  and pNR_POZ in (0,nr_poz_zlec);
 DELETE FROM wsp_alter WHERE nr_kom_zlec=pNR_KOM_ZLEC and pNR_POZ in (0,nr_poz) and nr_porz_obr>0;
 -- po poz.
 OPEN cP;
 LOOP
  FETCH cP INTO recP;
  EXIT WHEN cP%NOTFOUND;
  --aktualizacja STR_DOD w rekordach warstw oraz zapis L_WYC2;
  --UPDATE spiss set str_dod=' ' WHERE zrodlo='Z' and nr_komp_zr=pNR_KOM_ZLEC and nr_kol=recP.nr_poz and str_dod not in ('KRA','PROC12');
  OPEN c1 (recP.nr_poz);
  LOOP
   FETCH c1 INTO recW; --rekord warstwy
   EXIT WHEN c1%NOTFOUND;
   OPEN c2 (recP.nr_poz, recW.war_od, recW.etap);
   str1:=' ';
   str2:=' ';
   vKolejn:=0;
   etap_pam:=0;
   LOOP
    FETCH c2 INTO recO; --rekord obr�bki
    EXIT WHEN c2%NOTFOUND;
    --WY��CZONE (przeniesione do SPISS_MAT) pominiecie ZAT gdy atrybut 19.Szlif (EFF)
    IF FALSE and recO.nk_obr=1 and recO.nr_porz<100 and substr(recW.ident_bud,19,1)='1' THEN
     CONTINUE;
    --WY��CZONE (przeniesione do SPISS_MAT) pominiecie obrobek ze SPISD jesli wprowadozne na p�producie (b�d� sie planowa� w zlec. wew.)
    ELSIF FALSE and recW.etap=1 and recW.rodz_sur='POL' and recO.zn_war='Obr' and recO.nr_porz>100 THEN
     CONTINUE;
    END IF; 
    IF recO.etap>etap_pam then vKolejn:=0; END IF;
    --zapamietanie obrobki w str1 tylko gdy nie jest powt�rzona
    IF instr(','||str1,','||trim(to_char(recO.nk_obr,'999'))||',')=0 THEN 
      str1:=trim(str1)||trim(to_char(recO.nk_obr,'999'))||',';
    END IF;
    --str2:=trim(str2)||trim(to_char(recO.inst_std,'999'))||',';
    vKolejn:=vKolejn+1;
    IF vWDR=11 THEN vKolejn:=recO.kolejn_inst; END IF;
    etap_pam:=recO.etap;
    LWYC2_SAVE(pNR_KOM_ZLEC, recO.nr_kol, recO.war_od, recW.war_do, recP.ilosc, recO.nr_porz, recO.nk_obr, recO.inst_std, recO.etap*100+vKolejn);
   END LOOP;
   CLOSE c2;
   --zapis ci�gu prod. (numery obr�bek) na rekordzie warstwy etapu 1.
   IF recW.etap=1 AND trim(str1) is not null THEN
    NULL;--@V UPDATE spiss SET str_dod=nvl(trim(str1),' ') WHERE CURRENT OF c1;
   --dopisanie obrobki z etapow>1 do warstw w etapie 1
   ELSIF recW.etap>1 THEN
    NULL;
    --@V UPDATE spiss SET str_dod=nvl(trim(str1),' ') WHERE CURRENT OF c1;
    --@V UPDATE spiss SET str_dod=trim(str_dod)||nvl(trim(str1), ' ')
    --@V WHERE zrodlo=recW.zrodlo and nr_komp_zr=recW.nr_komp_zr and nr_kol=recW.nr_kol and etap=1 and czy_war=1 and strona=0 and war_od between recW.war_od and recW.war_do;
   END IF; 
   recW.ident_bud:=rpad(nvl(recW.ident_bud,'0'),greatest(length(recW.ident_bud),length(recP.ind_bud)),'0');
   --kopiowanie atrybut�w z Poz do Warstwy
   recW.ident_bud:=rep_str(recW.ident_bud,substr(recP.ind_bud,5,4),5); --atryb 5,6,7,8
   --recW.ident_bud:=rep_str(recW.ident_bud,decode(recW.par1*recW.par2*recW.par3*recW.par4,0,0,1),21);
   --@V UPDATE spiss SET ident_bud=recW.ident_bud WHERE CURRENT OF c1;
  END LOOP;
  CLOSE c1;
  --@V WPISZ_ATRYBUTY('Z', pNR_KOM_ZLEC, recP.nr_poz, recP.ind_bud);
  IF pNR_POZ>0 THEN 
    ZAPISZ_WSP(pNR_KOM_ZLEC, recP.nr_poz, -1);  -- -1 wszystkie zestawy
    USTAL_INST('Z', pNR_KOM_ZLEC, recP.nr_poz);
    IF par152>1 AND jestLWYC=0 THEN
     ZAPISZ_LWYC(pNR_KOM_ZLEC, 0, recP.nr_poz);
    END IF; 
  END IF;  
 END LOOP;
 CLOSE cP;
 IF pNR_POZ=0 THEN 
   ZAPISZ_WSP(pNR_KOM_ZLEC, 0, -1);
   IF pFUN=2 THEN
    USTAL_INST('Z', pNR_KOM_ZLEC, 0, 96);
    USTAL_INST('Z', pNR_KOM_ZLEC, 0, 97);
   ELSE
    USTAL_INST('Z', pNR_KOM_ZLEC, 0, 0);
   END IF; 
   IF par152>1 AND jestLWYC=0 THEN
    ZAPISZ_LWYC(pNR_KOM_ZLEC, 0, 0);
   END IF; 
 END IF;
 --zapis nazw inst. w calej pozycji (do rek. SPISS.NR_PORZ=0)
 /*--@P
 OPEN cP;
 LOOP
  FETCH cP INTO recP;
  EXIT WHEN cP%NOTFOUND;
  str1:=' ';
  OPEN c4 (recP.nr_poz);
   LOOP
    FETCH c4 INTO rec4;
    EXIT WHEN c4%NOTFOUND;
    str1:=str1||rec4.naz2||' ';
    UPDATE spiss SET str_dod=substr(str1,1,50) WHERE zrodlo='Z' AND nr_komp_zr=pNR_KOM_ZLEC AND nr_kol=recP.nr_poz AND nr_porz=0;
   END LOOP;
  CLOSE c4;
 END LOOP; 
 CLOSE cP; 
 */
 ZAPISZ_LOG('GEN_LWYC',pNR_KOM_ZLEC,'C',0);

EXCEPTION WHEN OTHERS THEN
 IF cP%ISOPEN THEN CLOSE cP; END IF;
 IF c1%ISOPEN THEN CLOSE c1; END IF;
 IF c2%ISOPEN THEN CLOSE c2; END IF;
 --IF c3%ISOPEN THEN CLOSE c3; END IF;
 IF c4%ISOPEN THEN CLOSE c4; END IF;
 dbms_output.put_line(dbms_utility.FORMAT_ERROR_BACKTRACE);
 dbms_output.put_line(SQLERRM);
 ZAPISZ_LOG('GEN_LWYC',pNR_KOM_ZLEC,'E',0);
 ZAPISZ_ERR(SQLERRM);
 IF pSKIP_ERR=0 THEN
  ROLLBACK;
  RAISE;
 END IF;
END GEN_LWYC;
/