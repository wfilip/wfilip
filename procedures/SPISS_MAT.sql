create or replace PROCEDURE SPISS_MAT (pZRODLO CHAR, pZ NUMBER)
AS
 vWDR NUMBER(3);
 vLAM NUMBER(1);
 vLACZ NUMBER(1);
 vLACZ_ILE_WAR NUMBER(2);
 vZESP_ILE_WAR NUMBER(2);
 vETAP_MAX NUMBER(2);
BEGIN
 SELECT nr_wdr INTO vWDR FROM firma;
 
 DELETE FROM SPISS_TMP WHERE zrodlo=pZRODLO and nr_komp_zr=pZ; 
 INSERT INTO SPISS_TMP
  SELECT * FROM SPISS_V WHERE zrodlo=pZRODLO AND nr_komp_zr=pZ; 
 --GTE,BO ogniochronna ETAP -1, renumeroany nizej na 2 lub 3
 IF vWDR in (17,8) THEN 
  INSERT INTO SPISS_TMP
   SELECT * FROM SPISS_VLACZ WHERE zrodlo=pZRODLO AND nr_komp_zr=pZ AND poziom<2;
 END IF;
 --renumeracja ETAPów i NR_PORZ
 FOR P IN (select nr_poz from spisz where nr_kom_zlec=pZ) LOOP
  --ETAP=-1 to dodatkowy etap laczeniowy (np. szyba ogniochronna)
  SELECT max(case when etap=2 then 1 else 0 end),
         max(case when etap=-1 then 1 else 0 end),
         sum(case when etap=-1 then war_do-war_od+1 else 0 end),
         max(case when etap=3 then war_do else 0 end),
         max(etap)
    INTO vLAM, vLACZ, vLACZ_ILE_WAR, vZESP_ILE_WAR, vETAP_MAX
  FROM spiss
  WHERE zrodlo=pZRODLO and nr_komp_zr=pZ and nr_kol=P.nr_poz and czy_war=1 and strona=0 and etap<9;
  --jesli etap laczenia na tyle warst co zesp do usuniecie etapu zesp
  IF vLACZ_ILE_WAR=vZESP_ILE_WAR THEN
   DELETE FROM spiss WHERE zrodlo=pZRODLO and nr_komp_zr=pZ and nr_kol=P.nr_poz and etap=3;
  END IF;
  --jesli nie ma laminatu to szyba ogniochronna zapisana jako ETAP 2
  IF vLAM=0 and vLACZ>0 THEN 
  UPDATE spiss SET etap=2 WHERE zrodlo=pZRODLO and nr_komp_zr=pZ and nr_kol=P.nr_poz and etap=-1; 
  vETAP_MAX:=greatest(vETAP_MAX,2);
   --jesli i laminat i ogniochronna to laminowanie jako ETAP 2, ogniochronna jako 4, zespalanie jako 5
  ELSIF vLAM>0 and vLACZ>0 THEN
   UPDATE spiss SET etap=5, nr_porz=nr_porz+200 WHERE zrodlo=pZRODLO and nr_komp_zr=pZ and nr_kol=P.nr_poz and etap=3;
   UPDATE spiss SET etap=4, nr_porz=nr_porz+200 WHERE zrodlo=pZRODLO and nr_komp_zr=pZ and nr_kol=P.nr_poz and etap=-1;
   --vETAP_MAX:=greatest(vETAP_MAX,4);
   SELECT max(etap) INTO vETAP_MAX
   FROM spiss
   WHERE zrodlo=pZRODLO and nr_komp_zr=pZ and nr_kol=P.nr_poz and czy_war=1 and strona=0 and etap<9;
   UPDATE spiss S 
   SET (war_od, war_do, indeks)=
       (select nvl(max(least(S.war_od,S1.war_od)),S.war_od) war_od, nvl(max(greatest(S.war_do,S.war_do)),S.war_do) war_do,
               nvl(max(kod_laminatu(S.nr_kom_str,least(S.war_od,S1.war_od),greatest(S.war_do,S.war_do))),S.indeks)
        from spiss S1
        where S1.zrodlo=S.zrodlo and S1.nr_komp_zr=S.nr_komp_zr and S1.nr_kol=S.nr_kol and S1.etap=2 and S1.strona=4 and (S1.war_od between S.war_od and S.war_do or S1.war_do between S.war_od and S.war_do))
   WHERE zrodlo=pZRODLO and nr_komp_zr=pZ and nr_kol=P.nr_poz and etap=4;
  END IF;
  --ETAP dla obrobki pakowanie ustawiany taki jak maksymalny
  UPDATE spiss
  SET etap=vETAP_MAX, nr_porz=vETAP_MAX*100+(100-rownum)
  WHERE zrodlo=pZRODLO and nr_komp_zr=pZ and nr_kol=P.nr_poz and etap=9;
 END LOOP; 
 --nieplanowanie obrobek, ze wzglêdu na atrybut wykluczaj¹cy i brak instalacji alternatywnej
 --LUB wprowadzonych na warstwie bêd¹cej polproduktem (z wyj. tych, ktore s¹ po \P w budowie str).
 UPDATE spiss_tmp A
 SET zn_plan=0
 WHERE zrodlo=pZRODLO AND nr_komp_zr=pZ and zn_plan>0
   AND (ATRYB_MATCH((select nvl(min(ident_bud_wyl),'0') from parinst where nr_komp_inst=A.inst_std and nr_inst_wyl=0),
                   (select ident_bud from spiss_tmp S where zrodlo=pZRODLO AND nr_komp_zr=pZ and S.nr_kol=A.nr_kol and S.etap=A.etap and S.czy_war=1 and S.war_od=A.war_od and S.strona=4)
                   )=1
        OR etap=1 and rodz_sur='POL' and zn_war='Obr' and nr_porz>100 and
           not exists (select 1 from spiss_str S
                       where S.zrodlo=A.zrodlo and S.nr_komp_zr=A.nr_komp_zr and S.nr_kol=A.nr_kol and S.nr_war=A.war_od and S.rodz_sur='CZY' and (S.nr_kat=A.nr_kat_obr or S.nk_obr=A.nk_obr))
       );
 UPDATE SPISS_TMP A
 SET str_dod=(select listagg(nk_obr,',') within group (order by zn_plan)
              from spiss_tmp S
              where S.zrodlo=A.zrodlo and S.nr_komp_zr=A.nr_komp_zr and S.nr_kol=A.nr_kol
                and S.etap>=A.etap and A.war_od between S.war_od and S.war_do and S.zn_plan>0)
 WHERE zrodlo=pZRODLO AND nr_komp_zr=pZ and czy_war=1;

 INSERT INTO SPISS_TMP
  SELECT * FROM SPISS_V_WE WHERE zrodlo=pZRODLO AND nr_komp_zr=pZ;
--  SELECT * FROM spiss_v1 where nr_komp_zr=pZ
--  UNION
--  SELECT * FROM spiss_v2 where nr_komp_zr=pZ
--  UNION
--  SELECT * FROM spiss_v3 where nr_komp_zr=pZ;
END;
/