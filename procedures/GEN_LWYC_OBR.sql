create or replace PROCEDURE             "GEN_LWYC_OBR" (pFUN IN NUMBER, pNR_KOM_ZLEC IN NUMBER, pNR_POZ NUMBER DEFAULT 0, pSKIP_ERR NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0)
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
  SELECT S.*
           --rezygnacja z zapisu WSP do L_WYC2 (zamist tego link do WSP_ALTER w V_WYC2
          --, nvl(W.wsp_alt,nvl(WSP_PLAN(S.zrodlo, S.nr_komp_zr, S.nr_kol, S.nr_porz, S.inst_std),0)) wsp_przel
          /*decode (trim(V.typ_inst),'A C',V.wsp_12zakr*V.wsp_c_m,'MON',V.wsp_12zakr,'SZP',V.wsp_12zakr*V.wsp_c_m, 'HAR', V.wsp_12zakr*(V.wsp_har+WSP_HO(S.nr_komp_zr,S.nr_kol,S.etap,S.war_od)),
            decode(trim(V.znak_dod),'*',V.wsp_12zakr*V.wsp_dod,'/',V.wsp_12zakr/V.wsp_dod,'+',V.wsp_12zakr+V.wsp_dod,'-',V.wsp_12zakr-V.wsp_dod,1)) wsp_przel */            
  FROM spiss S
  --LEFT JOIN wsp_alter W ON W.nr_kom_zlec=S.nr_komp_zr and W.nr_poz=S.nr_kol and W.nr_porz_obr=S.nr_porz and W.nr_komp_inst=S.inst_std
  --LEFT JOIN v_spiss V ON V.zrodlo=S.zrodlo and V.nr_kom_zlec=S.nr_komp_zr and V.nr_poz=S.nr_kol and V.nr_porz=S.nr_porz and V.nk_inst=S.inst_std
  WHERE S.zrodlo='Z' AND S.nr_komp_zr=pNR_KOM_ZLEC AND S.nr_kol=pPOZ AND pWAR between S.war_od and S.war_do AND S.etap=pETAP AND S.zn_plan>0
    AND S.nk_obr=pNR_OBR
  ORDER BY S.etap, S.zn_plan, S.nk_obr;
-- CURSOR c3 (pPOZ NUMBER) IS
--  SELECT S.indeks, L.nr_kom_zlec, L.nr_poz_zlec, L.nr_szt, L.nr_warst, L.nr_inst_plan, max(L.kolejn) kolejn, decode(max(S.zn_war),'Pó³','Pó³','Str','Pó³',max(K.rodz_sur)) rodz_sur,
--         nvl(max(L2.nr_inst_plan),nvl(max(L3.nr_inst_plan),0)) nr_inst_nast 
--  FROM l_wyc2 L
--  LEFT JOIN spiss S ON S.zrodlo='Z' and S.nr_komp_zr=L.nr_kom_zlec and S.nr_kol=L.nr_poz_zlec and S.war_od=L.nr_warst
--                       and S.czy_war=1 and S.strona=0 and S.etap=trunc(L.kolejn,-2)*0.01
--  --nast obr w tym samym etapie                     
--  LEFT JOIN l_wyc2 L2 ON L2.nr_kom_zlec=L.nr_kom_zlec and L2.nr_poz_zlec=L.nr_poz_zlec and L2.nr_szt=L.nr_szt
--                         and L2.nr_warst=L.nr_warst and L2.kolejn=L.kolejn+1 and trunc(L2.kolejn,-2)=trunc(L.kolejn,-2)
--  --nast etap                     
--  LEFT JOIN l_wyc2 L3 ON L3.nr_kom_zlec=L.nr_kom_zlec and L3.nr_poz_zlec=L.nr_poz_zlec and L3.nr_szt=L.nr_szt
--                         and L3.kolejn=trunc(L.kolejn,-2)+101
--  LEFT JOIN katalog K ON K.nr_kat=S.nr_kat                     
--  WHERE L.nr_kom_zlec=pNR_KOM_ZLEC AND L.nr_poz_zlec=pPOZ AND L.nr_szt=1
--  GROUP BY S.indeks, L.nr_kom_zlec, L.nr_poz_zlec, L.nr_szt, L.nr_warst, L.nr_inst_plan;
 --ci¹g prod. (dla calej Poz.)
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
  vINST NUMBER;
BEGIN
 SELECT count(1) INTO jestHARMON FROM dual WHERE exists (select 1 from harmon where nr_komp_zlec=pNR_KOM_ZLEC);
/*
 IF jestHARMON=0 THEN
  DELETE FROM l_wyc WHERE nr_kom_zlec=pNR_KOM_ZLEC and pNR_POZ in (0,nr_poz_zlec) and nr_inst_wyk=0;
 END IF;
 DELETE FROM l_wyc2 WHERE nr_kom_zlec=pNR_KOM_ZLEC  and pNR_POZ in (0,nr_poz_zlec);
 DELETE FROM wsp_alter WHERE nr_kom_zlec=pNR_KOM_ZLEC and pNR_POZ in (0,nr_poz);
*/
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
    FETCH c2 INTO recO; --rekord obróbki
    EXIT WHEN c2%NOTFOUND;
    --pominiecie ZAT gdy atrybut 19.Szlif (EFF)
    IF recO.nk_obr=1 and recO.nr_porz<100 and substr(recW.ident_bud,19,1)='1' THEN
     CONTINUE;
    --pominiecie obrobek ze SPISD jesli wprowadozne na póproducie (bêd¹ sie planowaæ w zlec. wew.)
    ELSIF recW.etap=1 and recW.rodz_sur='POL' and recO.zn_war='Obr' and recO.nr_porz>100 THEN
     CONTINUE;
    END IF; 
    IF recO.etap>etap_pam then vKolejn:=0; END IF;
    --zapamietanie obrobki w str1 tylko gdy nie jest powtórzona
    IF instr(','||str1,','||trim(to_char(recO.nk_obr,'999'))||',')=0 THEN 
      str1:=trim(str1)||trim(to_char(recO.nk_obr,'999'))||',';
    END IF;
    --str2:=trim(str2)||trim(to_char(recO.inst_std,'999'))||',';
    vKolejn:=vKolejn+1;
    etap_pam:=recO.etap;
    vINST:=recO.inst_std;
    LWYC2_SAVE(pNR_KOM_ZLEC, recO.nr_kol, recO.war_od, recW.war_do, recP.ilosc, recO.nr_porz, recO.nk_obr, recO.inst_std, recO.etap*100+vKolejn);
   END LOOP;
   CLOSE c2;
   --zapis ci¹gu prod. (numery obróbek) na rekordzie warstwy etapu 1.
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
   --kopiowanie atrybutów z Poz do Warstwy
   recW.ident_bud:=rep_str(recW.ident_bud,substr(recP.ind_bud,5,4),5); --atryb 5,6,7,8
   --recW.ident_bud:=rep_str(recW.ident_bud,decode(recW.par1*recW.par2*recW.par3*recW.par4,0,0,1),21);
   --@V UPDATE spiss SET ident_bud=recW.ident_bud WHERE CURRENT OF c1;
  END LOOP;
  CLOSE c1;
  --@V WPISZ_ATRYBUTY('Z', pNR_KOM_ZLEC, recP.nr_poz, recP.ind_bud);
  IF pNR_POZ>0 THEN 
    ZAPISZ_WSP(pNR_KOM_ZLEC, recP.nr_poz, -1, pNR_OBR);  -- -1 wszystkie zestawy
    /*
    USTAL_INST('Z', pNR_KOM_ZLEC, recP.nr_poz);
    IF jestHARMON=0 THEN
     ZAPISZ_LWYC(pNR_KOM_ZLEC, 0, recP.nr_poz);
    END IF;
    */
    ZAPISZ_LWYC(pNR_KOM_ZLEC, vINST, recP.nr_poz);
  END IF;  
 END LOOP;
 CLOSE cP;
 IF pNR_POZ=0 THEN 
   ZAPISZ_WSP(pNR_KOM_ZLEC, 0, -1, pNR_OBR);
   USTAL_INST('Z', pNR_KOM_ZLEC, 0, pNR_OBR);
   /*
   IF jestHARMON=0 THEN
    ZAPISZ_LWYC(pNR_KOM_ZLEC, 0, 0);
   END IF; 
   */
   DELETE FROM l_WYC WHERE nr_kom_zlec=pNR_KOM_ZLEC and nr_inst=vINST and nr_inst_wyk=0;
   ZAPISZ_LWYC(pNR_KOM_ZLEC, vINST, 0);
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
 ZAPISZ_LOG('GEN_LWYC_OBR',pNR_KOM_ZLEC,'C',0);

EXCEPTION WHEN OTHERS THEN
 IF cP%ISOPEN THEN CLOSE cP; END IF;
 IF c1%ISOPEN THEN CLOSE c1; END IF;
 IF c2%ISOPEN THEN CLOSE c2; END IF;
 --IF c3%ISOPEN THEN CLOSE c3; END IF;
 IF c4%ISOPEN THEN CLOSE c4; END IF;
 dbms_output.put_line(dbms_utility.FORMAT_ERROR_BACKTRACE);
 dbms_output.put_line(SQLERRM);
 ZAPISZ_LOG('GEN_LWYC_OBR',pNR_KOM_ZLEC,'E',0);
 ZAPISZ_ERR(SQLERRM);
 IF pSKIP_ERR=0 THEN
  ROLLBACK;
  RAISE;
 END IF;
END GEN_LWYC_OBR;