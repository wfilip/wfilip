create or replace PACKAGE PKG_REJESTRACJA IS 
/*deklaracje*/
/*nowy typ kursora, do podstawiana ró¿nych kewrend - test NIEUZYWANE*/
TYPE ref_kursor IS REF CURSOR;

cOP_AUTOMAT CONSTANT CHAR(7) := 'AUTOMAT';
vOP_SESJA VARCHAR(30):=null;
FUNCTION OPERATOR_SESJI RETURN VARCHAR2;
/*kursor wybieraj¹cy rekordy z tabeli L_WYC wg parametrów wejœciowych*/
CURSOR kursor_lwyc (pNR_KOM_ZLEC NUMBER, pNR_POZ_ZLEC NUMBER, pNR_SZT NUMBER, pNR_WARST NUMBER,
                    pZAKRES_INST NUMBER, pNR_INST NUMBER, pNADPISZ NUMBER, pZAPIS NUMBER, pMAX_KOLEJN NUMBER, pOPER VARCHAR2)
 IS SELECT L_WYC.* FROM l_wyc
    LEFT JOIN parinst ON parinst.nr_komp_inst=l_wyc.nr_inst
    WHERE l_wyc.nr_kom_zlec=pNR_KOM_ZLEC AND l_wyc.nr_poz_zlec=pNR_POZ_ZLEC AND l_wyc.nr_szt=pNR_SZT
      AND (pNR_WARST=0 or l_wyc.nr_warst=pNR_WARST)
      AND l_wyc.typ_inst not in ('A C','R C')
      AND (l_wyc.typ_inst not in ('MON','STR') or l_wyc.nr_warst=1) --A C wcale a MON tylko 1. warstwa
      AND (case when pZAKRES_INST=3 and l_wyc.zn_wyrobu=1 OR pZAKRES_INST in (4,5,6) and l_wyc.kolejn<pMAX_KOLEJN OR pZAKRES_INST=1 and l_wyc.nr_inst=pNR_INST OR pZAKRES_INST=2 then 1 else 0 end)=1
      AND (case when pZAPIS=0 and l_wyc.op=pOPER OR pNADPISZ=1 or l_wyc.d_wyk<to_date('2001/01/01','YYYY/MM/DD') then 1 else 0 end)=1
      AND (pZAPIS=1 or l_wyc.nr_stoj=0)
      AND zn_braku in (0,8)
      AND parinst.fl_cutmon=2
 FOR UPDATE;
 
CURSOR kursor_lwycMON (pNR_KOM_ZLEC NUMBER, pNR_POZ_ZLEC NUMBER, pNR_SZT NUMBER)
 IS SELECT * from l_wyc
    WHERE nr_kom_zlec=pNR_KOM_ZLEC AND nr_poz_zlec=pNR_POZ_ZLEC AND nr_szt=pNR_SZT
      AND nr_warst=(select min(nr_warst) from l_wyc where nr_kom_zlec=pNR_KOM_ZLEC AND nr_poz_zlec=pNR_POZ_ZLEC AND nr_szt=pNR_SZT AND typ_inst in ('MON','STR') AND rodz_sur<>'LIS')
      AND typ_inst in ('MON','STR')
      AND zn_wyrobu=1
 FOR UPDATE;
/* procedura poprawiajaca l_wyc na podstawie spise (triger na spise)*/
PROCEDURE POPRAW_MON_W_L_WYC(pNR_KOM_ZLEC NUMBER, pNR_POZ_ZLEC NUMBER, pNR_SZT NUMBER,
                             pNR_INST_WYK NUMBER, pDATA_WYK DATE, pZM_WYK NUMBER, pNR_STOJ NUMBER, pPOZ_STOJ NUMBER,
                             pOPER VARCHAR2);

/*procedura uzupeniaj¹ca L_WYC dla rekordów z 1. kursora*/ 
PROCEDURE Uzupelnij_l_wyc(
  pNR_KOM_SZYBY IN NUMBER
, pNR_KOM_ZLEC IN NUMBER
, pNR_POZ_ZLEC IN NUMBER
, pNR_SZT IN NUMBER
, pNR_WARST IN NUMBER
, pNR_INST IN NUMBER
, pZAKRES_INST IN NUMBER /*0-ostatnia; 1-bie¿¹ca; 2-wszystkie*/
, pNADPISZ IN NUMBER
, pUWZGL_BRAKI IN NUMBER
, pDATA_WYK IN DATE
, pZM_WYK IN NUMBER
, pNR_STOJ IN NUMBER
, pPOZ_STOJ IN NUMBER
, pZAPIS IN NUMBER
, pMAX_KOLEJN IN NUMBER DEFAULT 0
, pOPER IN VARCHAR2 DEFAULT null
);

PROCEDURE REJ_ZMIANE_WG_TAFLI (pINST NUMBER, pNK_ZM_WYK NUMBER, pZN_WYK NUMBER);
PROCEDURE REJ_WG_TAFLI (pNR_OPT NUMBER, pNR_TAF NUMBER, pZN_WYK NUMBER, pDATA DATE, pZM NUMBER, pINST NUMBER);

END PKG_REJESTRACJA;
/

create or replace PACKAGE BODY PKG_REJESTRACJA AS

FUNCTION OPERATOR_SESJI RETURN VARCHAR2 AS
begin
 IF vOP_SESJA is null THEN
  select distinct first_value(operator_id) over (order by data desc, czas desc)
    into vOP_SESJA
  from logowania
  where session_id=sys_context('USERENV', 'SESSIONID');
 END IF;
 RETURN vOP_SESJA;
exception when others then
 vOP_SESJA:=' ';
 RETURN vOP_SESJA;
end OPERATOR_SESJI;

PROCEDURE POPRAW_MON_W_L_WYC(pNR_KOM_ZLEC NUMBER, pNR_POZ_ZLEC NUMBER, pNR_SZT NUMBER,
                             pNR_INST_WYK NUMBER, pDATA_WYK DATE, pZM_WYK NUMBER, pNR_STOJ NUMBER, pPOZ_STOJ NUMBER,
                             pOPER VARCHAR2)
AS
 rec kursor_lwycMON%ROWTYPE;
BEGIN
 OPEN kursor_lwycMON(pNR_KOM_ZLEC, pNR_POZ_ZLEC, pNR_SZT);
 FETCH kursor_lwycMON INTO rec;
 IF rec.zn_wyrobu is not null THEN
    UPDATE l_wyc
    SET nr_inst_wyk=pNR_INST_WYK, d_wyk=pDATA_WYK, zm_wyk=pZM_WYK, nr_stoj=pNR_STOJ, stoj_poz=pPOZ_STOJ, op=pOPER,
        data=case pNR_STOJ when 0 then to_date('01/1901','MM/YYYY') else data end,
        czas=case pNR_STOJ when 0 then '000000' else czas end
    WHERE CURRENT OF kursor_lwycMON;
 END IF;
 CLOSE kursor_lwycMON;
END;

PROCEDURE Uzupelnij_l_wyc(
  pNR_KOM_SZYBY IN NUMBER
, pNR_KOM_ZLEC IN NUMBER
, pNR_POZ_ZLEC IN NUMBER
, pNR_SZT IN NUMBER
, pNR_WARST IN NUMBER
, pNR_INST IN NUMBER
, pZAKRES_INST IN NUMBER /* 1-wybrana; 2-wszystkie; 3-ostatnia; 4-wsz. wczeœniejsze do pMAX_KOLEJN*/
, pNADPISZ IN NUMBER
, pUWZGL_BRAKI IN NUMBER
, pDATA_WYK IN DATE
, pZM_WYK IN NUMBER
, pNR_STOJ IN NUMBER
, pPOZ_STOJ IN NUMBER
, pZAPIS IN NUMBER
, pMAX_KOLEJN IN NUMBER DEFAULT 0
, pOPER IN VARCHAR2 DEFAULT null
) AS
  vlw l_wyc%ROWTYPE;
  BEGIN  
  
  OPEN kursor_lwyc(pNR_KOM_ZLEC, pNR_POZ_ZLEC, pNR_SZT, pNR_WARST,
                   pZAKRES_INST, pNR_INST, pNADPISZ, pZAPIS, pMAX_KOLEJN, nvl(pOPER,cOP_AUTOMAT));
  /*FOR l_wyc_record IN kursor_lwyc(pNR_KOM_ZLEC, pNR_POZ_ZLEC, pNR_SZT, pNR_WARST,
                   pZAKRES_INST, pNR_INST, pNADPISZ, pZAPIS)*/
  LOOP
  FETCH kursor_lwyc INTO vlw;
  EXIT WHEN kursor_lwyc %NOTFOUND;
  IF pZAPIS=1 THEN 
   UPDATE l_wyc
   SET d_wyk=pDATA_WYK, zm_wyk=pZM_WYK,
       nr_inst_wyk=nr_inst, op=nvl(pOPER,cOP_AUTOMAT),
       nr_stoj=pNR_STOJ, stoj_poz=pPOZ_STOJ,
       --data=case nr_inst when pNR_INST then trunc(sysdate) else data end,
       --czas=case nr_inst when pNR_INST then to_char(sysdate,'HH24MISS') else czas end
       data=trunc(sysdate), czas=to_char(sysdate,'HH24MISS')
   WHERE CURRENT OF kursor_lwyc;
  ELSE
   UPDATE l_wyc
   SET d_wyk=pDATA_WYK, zm_wyk=pZM_WYK,
       nr_inst_wyk=0, op=nvl(pOPER,cOP_AUTOMAT),
       --data=case nr_inst when pNR_INST then trunc(sysdate) else data end,
       --czas=case nr_inst when pNR_INST then to_char(sysdate,'HH24MISS') else czas end
       data=trunc(sysdate), czas=to_char(sysdate,'HH24MISS')
   WHERE CURRENT OF kursor_lwyc;
   END IF;
  END LOOP;
  CLOSE kursor_lwyc; 
 --uzup. zlec. wew. 
 IF pZAKRES_INST in (5,6) THEN
  FOR p IN (select * from v_poz_wew where nr_kom_zlec=pNR_KOM_ZLEC and nr_poz=pNR_POZ_ZLEC)
   LOOP
    IF p.nr_kom_zlec_wew is not null THEN --AND pNR_WARST in (0,p.do_war) THEN
     Uzupelnij_l_wyc(0, p.nr_kom_zlec_wew, p.nr_poz_zlec_wew, pNR_SZT, 0, pNR_INST, pZAKRES_INST, pNADPISZ, pUWZGL_BRAKI, pDATA_WYK, pZM_WYK, pNR_STOJ, pPOZ_STOJ, pZAPIS, pMAX_KOLEJN, pOPER);
     UPDATE SPISE E
     SET (DATA_WYK, ZM_WYK, NR_KOMP_INST, ZN_WYK, D_WYK, T_WYK, O_WYK, NR_STOJ_PROD)=
         (select d_wyk, zm_wyk, nr_inst_wyk, decode(pZAPIS,1,1,0), data, czas, op, nr_stoj
          from l_wyc L 
          where L.nr_kom_zlec=E.nr_komp_zlec and L.nr_poz_zlec=E.nr_poz and L.nr_szt=E.nr_szt and L.zn_wyrobu=1)
     WHERE nr_komp_zlec=p.nr_kom_zlec_wew and nr_poz=p.nr_poz_zlec_wew and nr_szt=pNR_SZT and zn_wyk<2;
    END IF;
   END LOOP;
 END IF;    
 END Uzupelnij_l_wyc;
  
 
 PROCEDURE REJ_ZMIANE_WG_TAFLI (pINST NUMBER, pNK_ZM_WYK NUMBER, pZN_WYK NUMBER)
 AS
  cursor c1 IS 
   SELECT nr_opt, nr_tafli, d_wyk, zm_wyk, nr_komp_instal
   FROM opt_taf
   WHERE nr_komp_instal=pINST and nr_komp_zmw=pNK_ZM_WYK; --d_wyk=pDATA and zm_wyk=pZM;
  rec1 c1%ROWTYPE;
 BEGIN
  --wyjscie przy wywolaniu z apl. PLANOWANIE
  IF pZN_WYK=2 THEN RETURN; END IF;
  
  OPEN c1;
  LOOP
   FETCH c1 INTO rec1;
   EXIT WHEN c1%NOTFOUND;
   REJ_WG_TAFLI(rec1.nr_opt, rec1.nr_tafli, pZN_WYK, rec1.d_wyk, rec1.zm_wyk, rec1.nr_komp_instal); 
  END LOOP;
  CLOSE c1;
 EXCEPTION WHEN OTHERS THEN
  IF c1%ISOPEN THEN CLOSE c1; END IF;
 END REJ_ZMIANE_WG_TAFLI;
 
 PROCEDURE REJ_WG_TAFLI (pNR_OPT NUMBER, pNR_TAF NUMBER, pZN_WYK NUMBER, pDATA DATE, pZM NUMBER, pINST NUMBER)
 AS
  cursor cK IS 
   SELECT nr_komp_zlec, nr_poz, nr_sztuki, nr_warstwy
   FROM kol_stojakow
   WHERE nr_optym=pNR_OPT and nr_taf=pNR_TAF;
  recK cK%ROWTYPE;
  vOper VARCHAR2(30);
  vZnWyrobu NUMBER(1);
 BEGIN
  vOper:=OPERATOR_SESJI();
  OPEN cK;
  LOOP
   FETCH cK INTO recK;
   EXIT WHEN cK%NOTFOUND;
   vZnWyrobu:=-1;
   UPDATE l_wyc
   SET d_wyk=pDATA, zm_wyk=pZM, nr_inst_wyk=pINST, op=vOper
   WHERE nr_kom_zlec=recK.nr_komp_zlec AND nr_poz_zlec=recK.nr_poz AND nr_szt=recK.nr_sztuki AND nr_warst=recK.nr_warstwy
     AND typ_inst='A C' --and d_wyk<to_date('2001','YYYY')
   RETURNING max(zn_wyrobu) INTO vZnWyrobu;
   IF pZN_WYK>=0 AND vZnWyrobu=1 THEN
    UPDATE spise
    SET data_wyk=pDATA, zm_wyk=pZM, nr_komp_inst=pINST, o_wyk=vOper, zn_wyk=pZN_WYK
    WHERE nr_komp_zlec=recK.nr_komp_zlec AND nr_poz=recK.nr_poz AND nr_szt=recK.nr_sztuki
      AND (data_wyk<to_date('2001','YYYY') OR zn_wyk<2);
   END IF;
  END LOOP;
  CLOSE cK;
 EXCEPTION WHEN OTHERS THEN
  IF ck%ISOPEN THEN CLOSE cK; END IF;
 END REJ_WG_TAFLI;
 
END PKG_REJESTRACJA;