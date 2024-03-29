CREATE OR REPLACE VIEW SPISS_VLACZ
AS
 select S.zrodlo, S.nr_komp_zr, S.nr_kol, -1 etap, case when O.obr_lacz=5 then 1 else 0 end czy_war,
        S.nr_war-1 war_od, S.nr_war+1 war_do,
        'Pol' rodz_sur, case when O.obr_lacz=5 then X.strona else 2 end strona, 
        case when X.strona=0 then 1200+S.lp else 200+S.lp end nr_porz,
        case when O.obr_lacz=5 then 'Pol' else 'Obr' end zn_war, S.szer, S.wys,
        case when X.strona=0 then 0 else S.nk_obr end nk_obr,
        case when X.strona=0 then ' ' else O.symb_p_obr end symb_obr,
        case when X.strona=0 then 0 else O.nr_kat_obr end  nr_kat_obr,
        O.par_1 par1, O.par_2 par2, O.par_3 par3, O.par_4 par4, O.par5, ' ' boki,
       /*pow*/S.szer*0.001*S.wys*0.001 il_obr, 0 il_sur,
       case when X.strona=0 then 0 else O.kolejn_obr end zn_plan,
       case when X.strona=0 then 0 else O.nr_komp_inst end inst_std,
       (select nvl(min(nr_komp_inst),0) 
        from wsp_alter where nr_kom_zlec=S.nr_komp_zr and nr_poz=S.nr_kol and jaki=3
                         and nr_porz_obr=200+S.lp/*nr_porz*/) inst_ustal,
       S.nr_kat, ' ' kod_dod, 0 zn_pp,
       case when X.strona=0 then ' ' else S.typ_kat end typ_kat,
       kod_laminatu(S.nr_kom_str,S.nr_war-1,S.nr_war+1) indeks, 
       --ATRYB_SUM(IDENT_ETAP(1,S.ident_spisz), IDENT_ETAP_POP(2,nr_komp_zr,nr_kol,war_od,war_do),
       --          case when S.rodz_sur='FOL' then S.ident_bud_skl
       --               when kod_lam=kod_str then S.ident_spisz
       --               else S.ident_bud end) ident_bud,
       S.ident_bud,
       0 nr_mag, S.nr_kom_str, S.kod_str, S.id_rek, 0 poziom, 0 ident_dod, ' ' str_dod, 0 cena
from spiss_str S
left join slparob O on O.nr_k_p_obr=S.nk_obr
left join (select 0 strona from firma union select 4 from firma) X on O.obr_lacz=5
where --S.nr_komp_zr=:ZL and S.nr_kol=1 and
      O.obr_lacz in (5,6);

--CREATE OR REPLACE VIEW SPISS_V_E1
/

create or replace FUNCTION IDENT_ETAP_POP (pETAP NUMBER, pNR_KOM_ZLEC NUMBER, pNR_POZ NUMBER, pWAR_OD NUMBER DEFAULT 0, pWAR_DO NUMBER DEFAULT 99) RETURN VARCHAR2
AS
 vRet VARCHAR2(100):='0';
BEGIN
 IF pETAP=2 THEN
  --sumowanie atrybut�w z rekord�w czy_war=1
  FOR e1 IN (select ident_bud
             from spiss_v_e1
             where zrodlo='Z' and nr_komp_zr=pNR_KOM_ZLEC and nr_kol=pNR_POZ 
              and war_od between pWAR_OD and pWAR_DO
              and etap=1 and czy_war=1 and strona=0)
   LOOP
    vRet:=ATRYB_SUM(vRet,e1.ident_bud);
   END LOOP;
 END IF;
 RETURN vRet;
EXCEPTION WHEN OTHERS THEN
 RETURN '0';
END IDENT_ETAP_POP;
/

CREATE OR REPLACE VIEW SPISS_V
AS
--ETAP 0 rekord zerowy
 select zrodlo, S.nr_komp_zr, S.nr_kol, 0 etap, 0 czy_war, 0 war_od, 0 war_do, ' ' rodz_sur, 0 strona, 0 nr_porz,
               'Str' zn_war, szer, wys,0 nk_obr, ' ' symb_obr, 0 nr_kat_obr, 0 par1, 0 par2, 0 par3, 0 par4, 0 par5, ' ' boki, 0 il_obr, pow il_sur,
               0 zn_plan, 0 inst_std, 0 inst_ustal, 0 nr_kat, ' ' kod_dod, S.zn_pp, ' ' typ_kat, S.kod_str indeks, S.ident_bud, nr_mag, nr_kom_str, kod_str, id_rek,
               0 poziom, nr_kom_str ident_dod, rpad(' ',50) str_dod, 0 cena
 from spiss_str S where lp=1
UNION -- ETAP 1
 select * from spiss_v_e1
--UNION select * from spiss_vlacz -- przeniesione do SPISS_MAT
UNION --laminowanie NEW
Select zrodlo, nr_komp_zr, nr_kol, 2 etap, case when czy_war=1 or S.rodz_sur='CZY' and nr_war=war_od then 1 else 0 end czy_war, war_od, war_do,
       S.rodz_sur, decode(S.czy_war,0,0,decode(S.czy_kolejna,0,0,4)) strona, 200+S.lp nr_porz,
       decode(S.rodz_sur,'FOL','Sur','Pol') zn_war, S.szer, S.wys,
       case when S.czy_war=1 and S.czy_kolejna=1 then S.nk_obr_WY else 0 end nk_obr,
       case when S.czy_war=1 and S.czy_kolejna=1 then O.symb_p_obr
            when S.rodz_sur='FOL' then S.typ_kat_skl_nast else ' ' end symb_obr,
       case when S.rodz_sur='FOL' then S.nr_kom_skl_nast else O.nr_kat_obr end nr_kat_obr,
       O.par_1 par1, O.par_2 par2, O.par_3 par3, O.par_4 par4, O.par5, ' ' boki,
       /*pow*/S.szer*0.001*S.wys*0.001 il_obr, /*pow*/S.szer*0.001*S.wys*0.001 il_sur,
       case when S.czy_war=1 and S.czy_kolejna=1 then O.kolejn_obr else 0 end zn_plan,
       case when S.czy_war=1 and S.czy_kolejna=1 then O.nr_komp_inst else 0 end inst_std,
       (select nvl(min(nr_komp_inst),0) 
        from wsp_alter where nr_kom_zlec=S.nr_komp_zr and nr_poz=S.nr_kol and jaki=3
                         and nr_porz_obr=200+S.lp/*nr_porz*/) inst_ustal,
       0 nr_kat, decode(S.rodz_sur,'FOL',typ_kat,kod_lam) kod_dod, 0 zn_pp, typ_kat, decode(S.rodz_sur,'FOL',typ_kat,kod_lam) indeks, 
       ATRYB_SUM(IDENT_ETAP(1,S.ident_spisz), IDENT_ETAP_POP(2,nr_komp_zr,nr_kol,war_od,war_do),
                 case when S.rodz_sur='FOL' then S.ident_bud_skl
                      when kod_lam=kod_str then S.ident_spisz
                      else S.ident_bud end) ident_bud,
       0 nr_mag, S.nr_kom_str, S.kod_str, S.id_rek, 0 poziom, ktory_lam ident_dod, ' ' str_dod, 0 cena
From spiss_vlam S
LEFT JOIN slparob O ON O.nr_k_p_obr=S.nk_obr_WY  --obr LAM
--LEFT JOIN parinst I on S.rodz_sur='CZY' and I.ty_inst=S.typ_inst and I.nr_inst=S.nr_inst
--Where (czy_war=1 and ktore_szklo in (1,2) or S.rodz_sur='FOL')
Where Not (not (czy_war=1 and ktore_szklo in (1,2)) and S.rodz_sur<>'FOL')  --A or B => NOT (not A and not B)

UNION --ETAP 3 (lub 5 przy ogniochronnych) zespalanie i obrobki pomontazowe (ze SPISD lub ze struktury)
Select 'Z' zrodlo, Z.nr_kom_zlec nr_komp_zr, Z.nr_poz nr_kol,
       3 etap, --zmiana �e MON nie jest etapem 2, nawet gdy nie ma LAM
       case when X.strona in (0,4) then 1 else 0 end czy_war, 1 war_od, (select max(do_war) from spisd  D where D.nr_kom_zlec=Z.nr_kom_zlec and D.nr_poz=Z.nr_poz) war_do,
       ' ' rodz_sur, decode(X.strona,5,O.strona,X.strona) strona, 300+nvl(D.kol_dod,nvl(10+S.lp,X.strona)) nr_porz,
       'Str' zn_war, Z.szer, Z.wys,
       --decode(X.strona,4,O.nr_k_p_obr,0) nk_obr, decode(X.strona,4,O.symb_p_obr,' ') symb_obr, decode(X.strona,4,O.nr_kat_obr,0) nr_kat_obr,
       --decode(X.strona,4,O.par_1,0) par1, decode(X.strona,4,O.par_2,0) par2, decode(X.strona,4,O.par_3,0) par3, decode(X.strona,4,O.par_4,0) par4, decode(X.strona,4,O.par5,0) par5, 
       decode(X.strona,0,0,nvl(O.nr_k_p_obr,0)) nk_obr, decode(X.strona,0,' ',nvl(O.symb_p_obr,' ')) symb_obr, decode(X.strona,0,0,nvl(O.nr_kat_obr,0)) nr_kat_obr,
       nvl(D.par1,nvl(O.par_1,0)) par1, nvl(D.par2,nvl(O.par_2,0)) par2, nvl(D.par3,nvl(O.par_3,0)) par3, nvl(D.par4,nvl(O.par_4,0)) par4, nvl(D.par5,nvl(O.par5,0)) par5, decode(X.strona,0,' ','000') boki,
       nvl(D.ilosc_do_wyk,decode(X.strona,0,0,Z.pow)) il_obr, decode(X.strona,0,0,Z.pow) il_sur,
       decode(X.strona,0,0,nvl(O.kolejn_obr,0)) zn_plan, decode(X.strona,0,0,nvl(I.nr_komp_inst,0)) inst_std,
       decode(X.strona,0,0,
       (select nvl(min(nr_komp_inst),0)
        from wsp_alter where nr_kom_zlec=Z.nr_kom_zlec and nr_poz=Z.nr_poz and jaki=3
                         and nr_porz_obr=300+nvl(D.kol_dod,nvl(10+S.lp,X.strona))/*nr_porz*/)) inst_ustal,
       0 nr_kat, nvl(D.kod_dod,' ') kod_dod, 0 zn_pp, ' ' typ_kat, Z.kod_str indeks, Z.ind_bud ident_bud, Z.nr_mag,
       0 nr_kom_str, Z.kod_str, id_poz id_rek, 0 poziom, 0 ident_dod, ' ' str_dod, 0 cena
From spisz Z
LEFT JOIN (select 0 strona from firma union
           select 1 strona from firma union
           select 2 strona from firma union
           select 3 strona from firma union  --1,2,3 dla obrobek pomontazowych ze spisd
           select 4 strona from firma union  --4 obrobka MON
           select 5 strona from firma) X     --5-pomontazowe ze struktury
       ON 1=1
LEFT JOIN (select nr_k_p_obr, nr_komp_inst from slparob where obr_lacz=2 and rownum=1) MON ON 1=1 --obr MON podzapytanie celem zabezpiecznia przed >1 rekordem
LEFT JOIN spisd D on D.nr_kom_zlec=Z.nr_kom_zlec and D.nr_poz=Z.nr_poz and D.strona=X.strona and D.nr_komp_obr>0
LEFT JOIN spiss_str S on S.zrodlo='Z' and S.nr_komp_zr=Z.nr_kom_zlec and S.nr_kol=Z.nr_poz and S.nk_obr>0 and X.strona=5
LEFT JOIN slparob O on O.nr_k_p_obr=decode(X.strona,0,MON.nr_k_p_obr,
                                                    4,MON.nr_k_p_obr,
                                                    5,S.nk_obr,
                                                    D.nr_komp_obr)
--and not (X.strona not in (0,4) and O.obr_lacz<>8) --zespalanie X.strona=0    pomontazowe ze SPSID X.strona in (1,2,3)   pomontazowe ze strukt X.strona=4
LEFT JOIN parinst I on I.nr_komp_inst=O.nr_komp_inst-- or X.strona=0 and I.nr_komp_inst=MON.nr_komp_inst
Where Z.typ_zlec='Pro' and Z.typ_poz in ('I k','II ')
      --and (X.strona in (0,4) and (instr(I.ind_bud,'1')=0 or ATRYB_MATCH(I.ind_bud,Z.ind_bud)=1) or O.obr_lacz=8) --obr_lacz=8 obr�bka pomonta�owa
      and not (instr(I.ind_bud,'1')>0 and  ATRYB_MATCH(I.ind_bud,Z.ind_bud)=0)
      and not (X.strona not in (0,4) and O.obr_lacz<>8)
      --sprawdzenie czy na szybie EI jest LISTWA bez obrobki polaczeniowej
--      and not (Z.kod_str like '%EI%'
--       and not exists 
--        (select 1 from spiss_str LIS
--         where LIS.zrodlo='S' and LIS.nr_kom_str=S.nr_kom_str and LIS.rodz_sur='LIS' 
--         and not exists (select 1 from spiss_str ZEL
--                         left join slparob O1 on O1.nr_k_p_obr=ZEL.nk_obr
--                         where ZEL.zrodlo=LIS.zrodlo and ZEL.nr_kom_str=LIS.nr_kom_str and ZEL.nr_war=LIS.nr_war
--                           and ZEL.nk_obr>0 and O1.obr_lacz=6)
--        )
--       )

UNION --OBROBKA STA�A
Select 'Z' zrodlo, P.nr_kom_zlec nr_komp_zr, P.nr_poz nr_kol, decode(I.rodz_plan,5,9,1) etap,
       0 czy_war, S.war_od, case when I.rodz_plan=5 then (select max(do_war) from spisd  D where D.nr_kom_zlec=P.nr_kom_zlec and D.nr_poz=P.nr_poz) else S.war_od end war_do,
       S.rodz_sur, O.strona, 800+10*nvl(S.war_od,10)+O.nr_k_p_obr nr_porz, 'Obr' zn_war, nvl(S.szer,P.szer) szer, nvl(S.wys,P.wys) wys,
       O.nr_k_p_obr nk_obr, O.symb_p_obr symb_obr, O.nr_kat_obr,
       nvl(O.par_1,0) par1, nvl(O.par_2,0) par2, nvl(O.par_3,0) par3, nvl(O.par_4,0) par4, nvl(O.par5,0) par5, ' ' boki,
       case O.met_oblicz when 1 then nvl(S.szer,P.szer)*0.002+nvl(S.wys,P.wys)*0.002
                         when 2 then nvl(S.szer,P.szer)*0.001*nvl(S.wys,P.wys)*0.001 
                         else 1 end il_obr, P.pow il_sur,
       O.kolejn_obr zn_plan, I.nr_komp_inst inst_std,
       (select nvl(min(nr_komp_inst),0) 
        from wsp_alter where nr_kom_zlec=P.nr_kom_zlec and nr_poz=P.nr_poz and jaki=3
                         and nr_porz_obr=800+10*nvl(S.war_od,10)+O.nr_k_p_obr/*nr_porz*/) inst_ustal,
       nvl(S.nr_kat,0) nr_kat, ' ' kod_dod, 0 zn_pp, nvl(S.indeks,' ') typ_kat, nvl(S.indeks,P.kod_str) indeks, decode(I.rodz_plan,5,P.ind_bud,S.ident_bud) ident_bud, P.nr_mag,
       0 nr_kom_str, P.kod_str, P.id_poz id_rek, 0 poziom, 0 ident_dod, ' ' str_dod, 0 cena
From spisz P 
LEFT JOIN parinst I on I.czy_obr_stala>0
LEFT JOIN slparob O on O.nr_komp_inst=I.nr_komp_inst and O.kolejn_obr>0
--szybciej dziaa po zamianie SPISS_V_E1 na SPISS_STR oraz usunieciu OR
LEFT JOIN spiss_v_e1 S on S.zrodlo='Z' and S.nr_komp_zr=P.nr_kom_zlec and S.nr_kol=P.nr_poz and S.etap=1 and S.czy_war=1 and S.strona=4 and I.rodz_plan<3
Where P.typ_zlec='Pro' and I.nr_komp_inst is not null and I.czy_czynna='TAK' and O.nr_komp_inst is not null
  And (I.rodz_plan=5 or O.nr_kat_obr>0 and not exists (select 1 from spisd D, slparob OB1
                                                       where D.nr_kom_zlec=P.nr_kom_zlec and D.nr_poz=P.nr_poz and D.do_war=S.war_od and D.nr_komp_obr=OB1.nr_k_p_obr and OB1.nr_kat_obr=O.nr_kat_obr) )
  And (instr(I.ind_bud,'1')=0 or ATRYB_MATCH(I.ind_bud,decode(I.rodz_plan,5,P.ind_bud,S.ident_bud))=1)
  And (instr(I.ident_bud_wyl,'1')=0 or ATRYB_MATCH(I.ident_bud_wyl,decode(I.rodz_plan,5,P.ind_bud,S.ident_bud))=0)
  And I.rodz_sur in (' ',S.rodz_sur)

UNION --OBROBKA pakowania, etap ustawiany 9 ale  w SPISS_MAT zmieniany na ostatni (SLPAROB.OBR_LACZ=9 i czynna instalacja przypisana do obrobki)
Select 'Z' zrodlo, Z.nr_kom_zlec nr_komp_zr, P.nr_poz nr_kol, 9 etap, 0 czy_war, 1 war_od, (select max(do_war) from spisd  D where D.nr_kom_zlec=P.nr_kom_zlec and D.nr_poz=P.nr_poz) war_do,
       ' ' rodz_sur, 2 strona, 99 nr_porz, 'Str' zn_war, P.szer, P.wys,
       nvl(O.nr_k_p_obr,0) nk_obr, nvl(O.symb_p_obr,' ') symb_obr, nvl(O.nr_kat_obr,0) nr_kat_obr,
       nvl(O.par_1,0) par1, nvl(O.par_2,0) par2, nvl(O.par_3,0) par3, nvl(O.par_4,0) par4, nvl(O.par5,0) par5, ' ' boki,
       P.pow il_obr, P.pow il_sur,
       nvl(O.kolejn_obr,0) zn_plan, nvl(I.nr_komp_inst,0) inst_std,
       (select nvl(min(nr_komp_inst),0) 
        from wsp_alter where nr_kom_zlec=P.nr_kom_zlec and nr_poz=P.nr_poz and jaki=3
                         and nr_porz_obr=999/*nr_porz*/) inst_ustal,
       0 nr_kat, ' ' kod_dod, 0 zn_pp, ' ' typ_kat, P.kod_str indeks, P.ind_bud ident_bud, P.nr_mag,
       0 nr_kom_str, P.kod_str, P.id_poz id_rek, 0 poziom, 0 ident_dod, ' ' str_dod, 0 cena
From zamow Z
LEFT JOIN spisz P ON P.nr_kom_zlec=Z.nr_kom_zlec
LEFT JOIN slparob O on O.obr_lacz=9 and O.kolejn_obr>0
LEFT JOIN parinst I on I.nr_komp_inst=O.nr_komp_inst
Where Z.typ_zlec='Pro' and Z.wyroznik in ('Z','R') And O.kolejn_obr is not null
  And I.czy_czynna='TAK'
  And Not (instr(I.ind_bud,'1')>0 and ATRYB_MATCH(I.ind_bud,P.ind_bud)=0) --A or B => NOT (not A and not B)
ORDER BY zrodlo, nr_komp_zr, nr_kol, etap, war_od, czy_war desc, zn_plan, strona;
/

--DROP TRIGGER SPISS_INSTEADOF;
create or replace TRIGGER SPISS_INSTEADOF
INSTEAD OF UPDATE OR DELETE OR INSERT ON SPISS_V
BEGIN  NULL; END;
/

DROP TABLE SPISS_TMP;
CREATE GLOBAL TEMPORARY TABLE SPISS_TMP ON COMMIT PRESERVE ROWS
AS SELECT * FROM SPISS_V WHERE NR_KOMP_ZR=0;
/
CREATE UNIQUE INDEX SPISS_TMP_IDX ON SPISS_TMP (NR_KOMP_ZR, NR_KOL, NR_PORZ);
/

DROP SYNONYM SPISS;
--CREATE SYNONYM SPISS FOR SPISS_V;
CREATE SYNONYM SPISS FOR SPISS_TMP;

CREATE OR REPLACE VIEW SPISS_V_WE
AS
SELECT S.zrodlo, S.nr_komp_zr, S.nr_kol, S.etap, 0 czy_war, S.war_od, S.war_do,
       'CZY' rodz_sur, 2 strona, 1000*nvl(S2.etap,S3.etap)+S.nr_porz nr_porz, 'Obr' zn_war,
       S.szer, S.wys, O.nr_k_p_obr nk_obr, O.symb_p_obr symb_obr, O.nr_kat_obr,
       O.par_1 par1, O.par_2 par2, O.par_3 par3, O.par_4 par4, O.par5, ' ' boki,
       S.szer*0.001*S.wys*0.001 il_obr, S.szer*0.001*S.wys*0.001 il_sur,
       O.kolejn_obr zn_plan, O.nr_komp_inst inst_std,
       (select nvl(min(nr_komp_inst),0) 
        from wsp_alter where nr_kom_zlec=S.nr_komp_zr and nr_poz=S.nr_kol and jaki=3
                         and nr_porz_obr=1000*nvl(S2.etap,S3.etap)+S.nr_porz) inst_ustal,
       S.nr_kat, ' ' kod_dod, 0 zn_pp, S.typ_kat, S.indeks indeks, '0' ident_bud, S.nr_mag,
       S.nr_kom_str, S.kod_str, S.id_rek, 0 poziom, 0 ident_dod, ' ' str_dod, 0 cena       
FROM SPISS S
LEFT JOIN spiss S2 ON S2.nr_komp_zr=S.nr_komp_zr and S2.nr_kol=S.nr_kol and S2.etap=S.etap+1 and S.war_od between S2.war_od and S2.war_do and S2.czy_war=1 and S2.nk_obr>0--S2.strona=4
LEFT JOIN spiss S3 ON S3.nr_komp_zr=S.nr_komp_zr and S3.nr_kol=S.nr_kol and S3.etap=S.etap+2 and S.war_od between S3.war_od and S3.war_do and S3.czy_war=1 and S3.nk_obr>0 and S2.nk_obr is null--S3.strona=4
LEFT JOIN slparob O2 ON O2.nr_k_p_obr=nvl(S2.nk_obr,S3.nk_obr) and O2.obr_lacz in (1,2,5)
LEFT JOIN slparob O ON O.obr_lacz=decode(O2.obr_lacz,1,3,2,4,5,4,-1)--O.obr_lacz in (3,4) and O.obr_lacz=O2.obr_lacz+2
WHERE S.etap in (1,2) and S.czy_war=1 and S.strona=0 and O.obr_lacz is not null
ORDER BY S.zrodlo, S.nr_komp_zr, S.nr_kol, S.etap, S.war_od;
/

