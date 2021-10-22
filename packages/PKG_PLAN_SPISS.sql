--DROP TABLE "TMP_ZMIANY";
CREATE GLOBAL TEMPORARY TABLE "TMP_ZMIANY2" 
(	"NR_KOMP_INST" NUMBER(10,0) NOT NULL, 
	"NR_KOMP_ZM" NUMBER(10,0) NOT NULL,
    "DL_ZMIANY" NUMBER(4,2) NOT NULL,
    "ZATWIERDZ" NUMBER(1) NOT NULL,
	"SZT" NUMBER(8), 
	"SZT_ZL0" NUMBER(8),
	"SZT_ZL1" NUMBER(8),
	"SZT_ZL_MAX" NUMBER(8),
	"WIELK" NUMBER(8,2), 
	"WIELK_ZL0" NUMBER(8,2),
	"WIELK_ZL1" NUMBER(8,2),
	"WIELK_ZL_MAX" NUMBER(8,2),
	"WYD_NOM" NUMBER(8), 
	"WYD_MAX" NUMBER(8)
) ON COMMIT PRESERVE ROWS ;
CREATE UNIQUE INDEX TMP_ZMIANY2_IDX ON TMP_ZMIANY2 (nr_komp_inst, nr_komp_zm);

create or replace PACKAGE PKG_PLAN_SPISS AS
 vWDR NUMBER(3) := 0;
 --PARAMETRY planowania automatycznego
 --zmiana do zaplanowania operacji, dla których nie znaleziono wolnej zmiany
 gZM_BUFOR NUMBER:=PKG_CZAS.NR_KOMP_ZM(sysdate,4);
 --minimalna zmiana do zaplanowania
 gZM_START NUMBER(10):=PKG_CZAS.NR_KOMP_ZM(sysdate,1);
 --minimalna iloœæ przeliczeniowa zo zaplanowania (jeœli konieczny podzial ze wzgledu na oblozenie instalacji)
 --gMIN_ZL NUMBER(8,2):=20;

 --zmienne globalne dla ZAPISZ_PLAN i obslugi bufora
 gNK_ZLEC NUMBER;
 gPOZ NUMBER:=0;
 gZAKR NUMBER;
 gNR_OBR NUMBER;
 gINST NUMBER;
 gDANE1 NUMBER;
 gDANE2 VARCHAR2(50);
 gLISTA_OBR VARCHAR2(500);
 --kursor dla ZAPISZ_PLAN i obslugi bufora
 --CURSOR cInst (pNK_ZLEC NUMBER, pPOZ NUMBER, pZAKR NUMBER, pNR_OBR NUMBER, pINST NUMBER, pTYP_INST VARCHAR2, pABS NUMBER DEFAULT 0)
 CURSOR cInst (pNK_ZLEC NUMBER, pPOZ NUMBER, pABS NUMBER DEFAULT 0)
 IS
   SELECT distinct L.nr_inst_plan, I.ty_inst typ_inst
   FROM l_wyc2 L
   LEFT JOIN parinst I ON L.nr_inst_plan=I.nr_komp_inst
   WHERE (pABS=1 and L.nr_kom_zlec=-pNK_ZLEC or L.nr_kom_zlec=pNK_ZLEC) and pPOZ in (0,L.nr_poz_zlec)
     --AND (gZAKR=0 OR gZAKR=1 and L.nr_obr=gNR_OBR OR gZAKR=2 and L.nr_inst_plan=gINST OR gZAKR=3 and (gTYP_INST is null or trim(I.ty_inst)=gTYP_INST or gTYP_INST='A C' and trim(I.ty_inst)='R C'))
     AND ELEMENT_LISTY(gLISTA_OBR,L.nr_obr)=1
     AND L.nr_inst_plan>0;
 
 TYPE ASSOC_TMP_TAB IS TABLE OF NUMBER INDEX BY PLS_INTEGER;  -- Associative array type
 
 FUNCTION CZAS_POPROC(pINST1 NUMBER, pINST2 NUMBER) RETURN NUMBER;
 --FUNKCJA SPRAWDZA CZY MOZNA PRZEPLANWOAC z INST_Z na INST_NA sztuki obecnie zaplanowane na pINST i zmianê pZM
 FUNCTION CZY_MOZNA_PRZENIESC (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pINST NUMBER, pZM NUMBER, pINST_Z NUMBER, pINST_NA NUMBER) RETURN NUMBER;  
 --FUNKCJA SPRAWDZAJ¥CA CZY MO¯NA WYKONAÆ W ZLECENIU (POZYCJI) OBRÓBKÊ (WSZYSTKIE OBRÓBKI)
 FUNCTION CZY_MOZNA_WYKONAC (pZT CHAR, pNK_ZLEC NUMBER, pNR_POZ NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0, pNR_PORZ NUMBER DEFAULT 0) RETURN NUMBER;

 FUNCTION LISTA_PRZEKROCZEN1(pLISTA_ZLEC VARCHAR2, pSQL_WHERE VARCHAR2 DEFAULT '1=1') RETURN VARCHAR2;
 
 --FUNKCJA ZWRACAJ¥CA LISTÊ OBRÓBEK
 FUNCTION LISTA_OBROBEK(pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pZAKR NUMBER DEFAULT 0, pOBR NUMBER, pINST NUMBER DEFAULT 0, pWPLANIE NUMBER) RETURN VARCHAR2;
 --PROCEDURY DO BUFOROWANIA PLANU
 PROCEDURE LWYC2_DO_BUFORA (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pZAKR NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0, pINST NUMBER DEFAULT 0, pDANE2 VARCHAR2 DEFAULT null);
 PROCEDURE LWYC2_Z_BUFORA (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pZAKR NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0, pINST NUMBER DEFAULT 0, pDANE2 VARCHAR2 DEFAULT null, pNO_CHECK NUMBER DEFAULT 0);
 PROCEDURE LWYC2_COMMIT (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pZAKR NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0, pINST NUMBER DEFAULT 0, pDANE2 VARCHAR2 DEFAULT null);
 PROCEDURE USUN_Z_LWYC2 (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pZAKR NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0, pINST NUMBER DEFAULT 0, pDANE2 VARCHAR2 DEFAULT null);
 PROCEDURE KOPIUJ_LWYC2_Z_MINUSEM (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pZAKR NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0, pINST NUMBER DEFAULT 0, pDANE2 VARCHAR2 DEFAULT null);
 PROCEDURE PLAN_BLOK_UPD (pFUN NUMBER, pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT gPOZ, pZAKR NUMBER DEFAULT gZAKR, pDANE1 NUMBER DEFAULT gDANE1, pDANE2 VARCHAR2 DEFAULT gDANE2);
 PROCEDURE POPRAW_INST_SPISS (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pZAKR NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0, pINST NUMBER DEFAULT 0, pDANE2 VARCHAR2 DEFAULT null);  
 PROCEDURE LWYC2_INST_POW(pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pLISTA_OBR VARCHAR2 DEFAULT null);
 PROCEDURE WPISZ_INST_WG_CIAGU (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pLISTA_OBR VARCHAR2 DEFAULT null);
 --PROCEDURE POPRAW_JEDNOCZ_LWYC2 (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pZAKR NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0, pINST NUMBER DEFAULT 0, pDANE2 VARCHAR2 DEFAULT null);
 PROCEDURE POPRAW_OBR_JEDNOCZ (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pNR_OBR NUMBER default 0, pODWROTNIE NUMBER default 0);
 --
 PROCEDURE WYPELNIJ_ZMIANY(pNK_ZLEC NUMBER, pZM_OD NUMBER, pZM_DO NUMBER, pALL_INST NUMBER DEFAULT 0);
 PROCEDURE PLANUJ_SZYBY (pNK_ZLEC NUMBER, pNR_ZM_POCZ NUMBER default 0, pNR_ZM_KONC NUMBER default 0);
 --
 FUNCTION NR_INST_NAST(pNK_ZLEC NUMBER, pPOZ NUMBER, pWAR NUMBER, pSZT NUMBER, pKOLEJN NUMBER) RETURN NUMBER;
 PROCEDURE AKTUALIZUJ_CIAG_TECHN (pNK_ZLEC NUMBER);
 --
 PROCEDURE AKTUALIZUJ_ZAMOW (pNK_ZLEC NUMBER);
 PROCEDURE AKTUALIZUJ_SPISZ (pNK_ZLEC NUMBER);
 PROCEDURE AKTUALIZUJ_ZAMINFO (pNK_ZLEC NUMBER);
 PROCEDURE AKTUALIZUJ_SURZAM (pNK_ZLEC NUMBER);
 PROCEDURE PORZADKUJ_ZMIANY_I_KALINST (pNK_ZLEC NUMBER, pNK_INST NUMBER);
 --
 PROCEDURE ZAPISZ_PLAN (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pZAKR NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0, pINST NUMBER DEFAULT 0, pDANE2 VARCHAR2 DEFAULT null, pBUFOR NUMBER DEFAULT 1);
 --PROCEDURE USUN_PLAN_WG_BACKUPU (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pZAKR NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0, pINST NUMBER DEFAULT 0, pTYP_INST VARCHAR2 DEFAULT null);
 PROCEDURE ZAPISZ_WYKZAL_DLA_AC (pNK_ZLEC IN NUMBER, pINST IN NUMBER DEFAULT 0, pPOZ IN NUMBER DEFAULT 0);
END PKG_PLAN_SPISS;
/

create or replace PACKAGE BODY PKG_PLAN_SPISS AS
 --deklaracje procedur niepublicznych
 PROCEDURE ODZYSKAJ_Z_MINUSA (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0);
 PROCEDURE USUN_PLAN_WG_BACKUPU (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0);
 FUNCTION LICZ_REKORDY(pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0) RETURN NUMBER;
 FUNCTION INFO_ZAKR RETURN VARCHAR2;
 PROCEDURE AKTUALIZUJ_LWYC (pNK_INST_NEW NUMBER, pPOZ NUMBER);
 PROCEDURE ZAPISZ_ZM_ZLEC;
 --stale
 cNR_OBR_MON CONSTANT NUMBER(3) := 99;
 -- Associative array type
 tabOBRi ASSOC_TMP_TAB;  --wybrane instalacje dla obrobki
 tabOBRz ASSOC_TMP_TAB;  --wybrane zmiany dla obrobki
 
 --definicje
 PROCEDURE LWYC2_DO_BUFORA (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pZAKR NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0, pINST NUMBER DEFAULT 0, pDANE2 VARCHAR2 DEFAULT null)
  AS
  BEGIN
   --zapis do zmiennych globalnych
   gNK_ZLEC:=pNK_ZLEC; gPOZ:=pPOZ; gZAKR:=pZAKR; gNR_OBR:=pNR_OBR; gINST:=pINST; 
   gDANE1:=case pZAKR when 1 then pNR_OBR when 2 then pINST else 0 end;
   gDANE2:=pDANE2;
   gLISTA_OBR:=LISTA_OBROBEK(pNK_ZLEC,pPOZ,pZAKR,pNR_OBR,pINST,0);
   -- WCZESNIEJ KONIECZNE SPRAWDZENIE CZY SA JU¯ REKORDY W BUFORZE
   --TO DO USUN_LWYC2()
   --ZA£O¯ENIE BLOKAD w tab PLAN_BLOK
   PLAN_BLOK_UPD (1, pNK_ZLEC, pPOZ);
   --zabezpiecznie gdyby w buforze zostaly jakieœ utracone rekordy 
   ODZYSKAJ_Z_MINUSA (pNK_ZLEC, pPOZ);
   --uzupelnienie brakuj¹cych L_WYC.NRY_PORZ
   begin
    update l_wyc L
    set nry_porz=(select listagg(L2.nr_porz_obr,',') within group (order by L2.kolejn)
                  from l_wyc2 L2
                  where L2.nr_kom_zlec=L.nr_kom_zlec and L2.nr_poz_zlec=L.nr_poz_zlec and L2.nr_warst=L.nr_warst and L2.nr_szt=L.nr_szt
                    and L2.nr_inst_plan=L.nr_inst)
    where nr_kom_zlec=pNK_ZLEC and nry_porz is null;
    update l_wyc L
    set (nry_porz, nr_inst)=
                 (select listagg(L2.nr_porz_obr,',') within group (order by L2.kolejn),  L.nr_inst--@P@ nvl(max(L2.nr_inst_plan),L.nr_inst)
                  from l_wyc2 L2
                  where L2.nr_kom_zlec=L.nr_kom_zlec and L2.nr_poz_zlec=L.nr_poz_zlec and L2.nr_warst=L.nr_warst and L2.nr_szt=L.nr_szt
                    and exists (select nr_komp_obr, count(1) from gr_inst_dla_obr where nr_komp_inst in (L.nr_inst,L2.nr_inst_plan) group by nr_komp_obr having count(1)=2)
                    and not exists (select 1 from l_wyc N where N.nr_kom_zlec=L.nr_kom_zlec and N.nr_poz_zlec=L.nr_poz_zlec and N.nr_warst=L.nr_warst and N.nr_szt=L.nr_szt and N.nr_inst=L2.nr_inst_plan))
    where nr_kom_zlec=pNK_ZLEC and nry_porz is null;
    /* @P@
    delete from l_wyc L
    where nr_kom_zlec=pNK_ZLEC and nry_porz is null
      and not exists (select 1 from l_wyc2 L2 
                      left join l_wyc N on N.nr_kom_zlec=L2.nr_kom_zlec and N.nr_poz_zlec=L2.nr_poz_zlec and N.nr_warst=L2.nr_warst and N.nr_szt=L2.nr_szt and N.nr_inst=L2.nr_inst_plan
                                           and ELEMENT_LISTY(N.nry_porz,L2.nr_porz_obr)=1
                      where L2.nr_kom_zlec=L.nr_kom_zlec and L2.nr_poz_zlec=L.nr_poz_zlec and L2.nr_szt=L.nr_szt and L2.nr_warst=L.nr_warst and N.nr_inst is null);
    */
   exception when others then
    ZAPISZ_LOG('DO_BUF upd L_WYC.NRY_PORZ',pNK_ZLEC,'E',0);
    ZAPISZ_ERR(SQLERRM);
   end;
   --zamiana procedury KOPIUJ_Z_MINUSEM na INSERT, ¿eby obsu¿yæ bl¹d kopiowania FLAG= -1 do backup'u
   INSERT INTO l_wyc2 (nr_kom_zlec, nr_poz_zlec, nr_szt, nr_warst, war_do, nr_obr, nr_porz_obr, nr_inst_plan, kolejn,  nr_zm_plan, nr_inst_wyk, nr_zm_wyk, flag)--, id_br)
    SELECT -L.nr_kom_zlec, L.nr_poz_zlec, L.nr_szt, L.nr_warst, L.war_do, L.nr_obr, L.nr_porz_obr, L.nr_inst_plan, L.kolejn,  L.nr_zm_plan, L.nr_inst_wyk, L.nr_zm_wyk, greatest(0,L.flag)--, L.id_br
    FROM l_wyc2 L
    --LEFT JOIN parinst I ON I.nr_komp_inst=L.nr_inst_plan
    WHERE nr_kom_zlec=pNK_ZLEC and pPOZ in (0,L.nr_poz_zlec)
      AND ELEMENT_LISTY(gLISTA_OBR,L.nr_obr)=1
      --AND (pZAKR=0 OR pZAKR=1 and nr_obr=pNR_OBR OR pZAKR=2 and nr_inst_plan=pINST OR pZAKR=3 and (pTYP_INST is null or trim(I.ty_inst)=pTYP_INST or pTYP_INST='A C' and trim(I.ty_inst)='R C'));
      AND NOT EXISTS (select 1 from l_wyc2 where nr_kom_zlec=-L.nr_kom_zlec and nr_poz_zlec=L.nr_poz_zlec and nr_porz_obr=L.nr_porz_obr and nr_szt=L.nr_szt);
  END LWYC2_DO_BUFORA;

 PROCEDURE LWYC2_Z_BUFORA (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pZAKR NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0, pINST NUMBER DEFAULT 0, pDANE2 VARCHAR2 DEFAULT null, pNO_CHECK NUMBER DEFAULT 0)
  AS
   ile NUMBER;
   ileBAK NUMBER;
   ex_backup EXCEPTION;
   PRAGMA EXCEPTION_INIT(ex_backup, -20000);
  BEGIN
   --zapis do zmiennych globalnych
   gNK_ZLEC:=pNK_ZLEC; gPOZ:=pPOZ; gZAKR:=pZAKR; gNR_OBR:=pNR_OBR; gINST:=pINST; 
   gDANE1:=case pZAKR when 1 then pNR_OBR when 2 then pINST else 0 end;
   gDANE2:=pDANE2;
   gLISTA_OBR:=LISTA_OBROBEK(pNK_ZLEC,pPOZ,pZAKR,pNR_OBR,pINST,0);

   --sprawdzanie czy iloœæ rekordów w buforze jest poprawna
   IF pNO_CHECK=0 THEN
    --przeniesc do odzielnej funkcji
    ile:=LICZ_REKORDY(pNK_ZLEC,pPOZ);
    ileBAK:=LICZ_REKORDY(-pNK_ZLEC,pPOZ);
    IF ile<>ileBAK THEN
     raise_application_error(-20000, 'B³êdy w buforze Planu ['||ile||'/'||ileBAK||'] '||INFO_ZAKR);
    END IF;
   END IF; 

   USUN_Z_LWYC2 (pNK_ZLEC, pPOZ, pZAKR, pNR_OBR, pINST, pDANE2);
   UPDATE l_wyc2
   SET nr_kom_zlec=-nr_kom_zlec
   WHERE nr_kom_zlec=-pNK_ZLEC and pPOZ in (0,nr_poz_zlec)
     AND ELEMENT_LISTY(gLISTA_OBR,nr_obr)=1;
--     AND (pZAKR=0 OR pZAKR=1 and nr_obr=pNR_OBR OR pZAKR=2 and nr_inst_plan=pINST OR
--          pZAKR=3 and (pTYP_INST is null or pTYP_INST in (select trim(ty_inst) from parinst where nr_komp_inst=nr_inst_plan) or pTYP_INST='A C' and (select trim(ty_inst) from parinst where nr_komp_inst=nr_inst_plan)='R C'));
   --13.07.2015 zmiana w usuwaniu blokad: usuwanie tylko wg zakresu (wczesniej usuwanie wszytkich blokad dla sesji)
   PLAN_BLOK_UPD (-1, pNK_ZLEC, pPOZ);
   --przywrócenie SPISS.INST_USTAL
   POPRAW_INST_SPISS (pNK_ZLEC, pPOZ, pZAKR, pNR_OBR, pINST, pDANE2);
   --oznaczenie WSP_ALTER.JAKI
   USTAW_WSP(pNK_ZLEC,0);
  EXCEPTION
   WHEN ex_backup THEN
    ZAPISZ_LOG('LWYC2_Z_BUFORA',pNK_ZLEC,'E',0);
    ZAPISZ_ERR(SQLERRM||': '||dbms_utility.FORMAT_ERROR_BACKTRACE);
    RAISE;
  END LWYC2_Z_BUFORA;

 PROCEDURE LWYC2_COMMIT (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pZAKR NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0, pINST NUMBER DEFAULT 0, pDANE2 VARCHAR2 DEFAULT null)
  AS
  BEGIN
   --zapis do zmiennych globalnych
   gNK_ZLEC:=pNK_ZLEC; gPOZ:=pPOZ; gZAKR:=pZAKR; gNR_OBR:=pNR_OBR; gINST:=pINST; 
   gDANE1:=case pZAKR when 1 then pNR_OBR when 2 then pINST else 0 end;
   gDANE2:=pDANE2;
   gLISTA_OBR:=LISTA_OBROBEK(pNK_ZLEC,pPOZ,pZAKR,pNR_OBR,pINST,0);

   --KOPIUJ_LWYC2_Z_MINUSEM (-pNK_ZLEC, pPOZ, pZAKR, pNR_OBR, pINST, pTYP_INST);   
--12.2018 ten update moze uzun¹c inf. o wykonaniu
--   UPDATE l_wyc2 A
--   SET (nr_inst_wyk, nr_zm_wyk, flag)
--     = (select B.nr_inst_wyk, B.nr_zm_wyk, B.flag 
--        from l_wyc2 B
--        where B.nr_kom_zlec=-A.nr_kom_zlec and B.nr_poz_zlec=A.nr_poz_zlec and B.nr_szt=A.nr_szt and B.nr_porz_obr=A.nr_porz_obr
--        union  --zabezpieczenie przed brakiem rekordu w backup'ie
--        select A.nr_inst_wyk, A.nr_zm_wyk, greatest(0,A.flag) from dual
--        where not exists 
--         (select 1 from l_wyc2 B where B.nr_kom_zlec=-A.nr_kom_zlec and B.nr_poz_zlec=A.nr_poz_zlec and B.nr_szt=A.nr_szt and B.nr_porz_obr=A.nr_porz_obr))
--   WHERE nr_kom_zlec=pNK_ZLEC and pPOZ in (0,nr_poz_zlec)
--     AND ELEMENT_LISTY(gLISTA_OBR,A.nr_obr)=1;
----     AND (pZAKR=0 OR pZAKR=1 and nr_obr=pNR_OBR OR pZAKR=2 and nr_inst_plan=pINST OR
----          pZAKR=3 and (pTYP_INST is null or pTYP_INST in (select trim(ty_inst) from parinst where nr_komp_inst=nr_inst_plan) or pTYP_INST='A C' and (select trim(ty_inst) from parinst where nr_komp_inst=nr_inst_plan)='R C'));
   UPDATE l_wyc2 A
   SET flag=0
   WHERE nr_kom_zlec=pNK_ZLEC and pPOZ in (0,nr_poz_zlec)
     AND ELEMENT_LISTY(gLISTA_OBR,A.nr_obr)=1
     AND flag=-1;
   USUN_Z_LWYC2 (-pNK_ZLEC, pPOZ, pZAKR, pNR_OBR, pINST, pDANE2);
   PLAN_BLOK_UPD (-1, pNK_ZLEC, pPOZ); --usuniecie z naglowka bufora
  END LWYC2_COMMIT;

-- PROCEDURE POPRAW_JEDNOCZ_LWYC2 (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pZAKR NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0, pINST NUMBER DEFAULT 0, pDANE2 VARCHAR2 DEFAULT null)
--  AS
--  BEGIN
--   --zapis do zmiennych globalnych
--   gNK_ZLEC:=pNK_ZLEC; gPOZ:=pPOZ; gZAKR:=pZAKR; gNR_OBR:=pNR_OBR; gINST:=pINST; 
--   gDANE1:=case pZAKR when 1 then pNR_OBR when 2 then pINST else 0 end;
--   gDANE2:=pDANE2;
--   gLISTA_OBR:=LISTA_OBROBEK(pNK_ZLEC,pPOZ,pZAKR,pNR_OBR,pINST,0);  
--
--   UPDATE l_wyc2 L
--   SET  (nr_inst_plan, nr_zm_plan, flag) =
--        (select nr_inst_plan, nr_zm_plan, flag
--         from l_wyc2
--         where nr_kom_zlec=L.nr_kom_zlec and nr_poz_zlec=L.nr_poz_zlec and nr_szt=L.nr_szt and nr_warst=L.nr_warst
--           and round(kolejn,-2)=round(L.kolejn,-2) --ten sam ETAP
--           and nr_obr in (7,8) --@V@ DO POPRAWY!
--        )
--   WHERE nr_kom_zlec=pNK_ZLEC and pPOZ in (0,nr_poz_zlec)
--     AND ELEMENT_LISTY(gLISTA_OBR,nr_obr)=1 AND nr_obr=9 AND 1=0;--@V@
--      --AND EXISTS (select 1 from l_wyc2 where nr_kom_zlec=-L.nr_kom_zlec and nr_poz_zlec=L.nr_poz_zlec and nr_porz_obr=L.nr_porz_obr and nr_szt=L.nr_szt);
--  END POPRAW_JEDNOCZ_LWYC2;

 PROCEDURE USUN_Z_LWYC2 (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pZAKR NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0, pINST NUMBER DEFAULT 0, pDANE2 VARCHAR2 DEFAULT null)
  AS
  BEGIN
    DELETE FROM l_wyc2 L
    WHERE nr_kom_zlec=pNK_ZLEC and pPOZ in (0,nr_poz_zlec)
      AND ELEMENT_LISTY(gLISTA_OBR,nr_obr)=1;
    --12.2018 wylaczenie dodatkowego zawezenia zeby nie pozostawaly smieci lub dane dla inst.powiazanyc     
    --AND EXISTS (select 1 from l_wyc2 where nr_kom_zlec=-L.nr_kom_zlec and nr_poz_zlec=L.nr_poz_zlec and nr_porz_obr=L.nr_porz_obr and nr_szt=L.nr_szt);
  END USUN_Z_LWYC2;

 --procedura do odzyskiwania utraconych rekordów 
 PROCEDURE ODZYSKAJ_Z_MINUSA (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0)
  AS
  BEGIN
  INSERT INTO l_wyc2 (nr_kom_zlec, nr_poz_zlec, nr_szt, nr_warst, war_do, nr_obr, nr_porz_obr, nr_inst_plan, kolejn, nr_zm_plan, nr_inst_wyk, nr_zm_wyk, flag)--, id_br)
    SELECT -L.nr_kom_zlec, L.nr_poz_zlec, L.nr_szt, L.nr_warst, L.war_do, L.nr_obr, L.nr_porz_obr, L.nr_inst_plan, L.kolejn,  L.nr_zm_plan, L.nr_inst_wyk, L.nr_zm_wyk, L.flag--, L.id_br
    FROM l_wyc2 L
    --LEFT JOIN parinst I ON I.nr_komp_inst=L.nr_inst_plan
    WHERE nr_kom_zlec=pNK_ZLEC and pPOZ in (0,L.nr_poz_zlec)
      AND ELEMENT_LISTY(gLISTA_OBR,L.nr_obr)=1
    --  AND (pZAKR=0 OR pZAKR=1 and nr_obr=pNR_OBR OR pZAKR=2 and nr_inst_plan=pINST OR pZAKR=3 and (pTYP_INST is null or trim(I.ty_inst)=pTYP_INST or pTYP_INST='A C' and trim(I.ty_inst)='R C'));
      AND NOT EXISTS (select 1 from l_wyc2 where nr_kom_zlec=-L.nr_kom_zlec and nr_poz_zlec=L.nr_poz_zlec and nr_porz_obr=L.nr_porz_obr and nr_szt=L.nr_szt);
  END ODZYSKAJ_Z_MINUSA;
 --NIEUZYWANA 
 PROCEDURE KOPIUJ_LWYC2_Z_MINUSEM (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pZAKR NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0, pINST NUMBER DEFAULT 0, pDANE2 VARCHAR2 DEFAULT null)
  AS
  BEGIN
  INSERT INTO l_wyc2 (nr_kom_zlec, nr_poz_zlec, nr_szt, nr_warst, war_do, nr_obr, nr_porz_obr, nr_inst_plan, kolejn, nr_zm_plan, nr_inst_wyk, nr_zm_wyk, flag)--, id_br)
    SELECT -L.nr_kom_zlec, L.nr_poz_zlec, L.nr_szt, L.nr_warst, L.war_do, L.nr_obr, L.nr_porz_obr, L.nr_inst_plan, L.kolejn,  L.nr_zm_plan, L.nr_inst_wyk, L.nr_zm_wyk, L.flag--, L.id_br
    FROM l_wyc2 L
    --LEFT JOIN parinst I ON I.nr_komp_inst=L.nr_inst_plan
    WHERE nr_kom_zlec=pNK_ZLEC and pPOZ in (0,L.nr_poz_zlec)
      AND ELEMENT_LISTY(gLISTA_OBR,L.nr_obr)=1;
    --  AND (pZAKR=0 OR pZAKR=1 and nr_obr=pNR_OBR OR pZAKR=2 and nr_inst_plan=pINST OR pZAKR=3 and (pTYP_INST is null or trim(I.ty_inst)=pTYP_INST or pTYP_INST='A C' and trim(I.ty_inst)='R C'));
  END KOPIUJ_LWYC2_Z_MINUSEM;

 PROCEDURE PLAN_BLOK_UPD (pFUN NUMBER, pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT gPOZ, pZAKR NUMBER DEFAULT gZAKR, pDANE1 NUMBER DEFAULT gDANE1, pDANE2 VARCHAR2 DEFAULT gDANE2)
  AS
    CURSOR c1 IS
     SELECT * --nr_kom_zlec, nr_poz, zakres_blokady, dane1, dane2, sess_id, czas
     FROM plan_blok
     WHERE nr_kom_zlec=pNK_ZLEC and pPOZ in (0,nr_poz) and zakres_blokady=gZAKR and dane1=gDANE1
    FOR UPDATE;
    rec1 PLAN_BLOK%ROWTYPE; 
  BEGIN
   --zapis do zmiennych globalnych
   gNK_ZLEC:=pNK_ZLEC; gPOZ:=pPOZ; gZAKR:=pZAKR;
   gDANE1:=gDANE1;  gDANE2:=pDANE2;
   gNR_OBR:=case gZAKR when 1 then gDANE1 else 0 end;
   gINST  :=case gZAKR when 2 then gDANE1 else 0 end;
   gLISTA_OBR:=LISTA_OBROBEK(pNK_ZLEC,pPOZ,pZAKR,gNR_OBR,gINST,0);

   IF pFUN=1 THEN --zapis blokady
    INSERT INTO plan_blok (nr_kom_zlec, nr_poz, zakres_blokady, dane1, dane2, sess_id) 
        VALUES (pNK_ZLEC, pPOZ, pZAKR, pDANE1, pDANE2, sys_context('userenv','sessionid'));
   ELSIF pFUN=0 THEN --zdjecie wszytkich blokad sesji
    DELETE FROM plan_blok 
    WHERE nr_kom_zlec=pNK_ZLEC and pPOZ in (0,nr_poz) 
      AND sess_id=sys_context('userenv','sessionid');
   ELSIF pFUN=-1 THEN --zdjecie blakady wg par
    OPEN c1;
    FETCH c1 INTO rec1;
    IF NOT c1%NOTFOUND THEN
     DELETE FROM plan_blok WHERE current of c1;
     DELETE FROM plan_blok
     WHERE nr_kom_zlec=rec1.nr_kom_zlec and nr_poz=rec1.nr_poz and zakres_blokady=1 and sess_id=rec1.sess_id
       AND ELEMENT_LISTY(rec1.dane2,dane1)=1;
     DELETE FROM l_wyc2 
     WHERE nr_kom_zlec=-rec1.nr_kom_zlec and rec1.nr_poz in (0,nr_poz_zlec) and ELEMENT_LISTY(rec1.dane2,nr_obr)=1;
    END IF;
    CLOSE c1;
   END IF;
  EXCEPTION WHEN OTHERS THEN
    IF c1%ISOPEN THEN CLOSE c1; END IF;
    ZAPISZ_LOG('PKG.PLAN_BLOK_UPD',pNK_ZLEC,'E',0);
    ZAPISZ_ERR(SQLERRM||': '||dbms_utility.FORMAT_ERROR_BACKTRACE);
    RAISE;
  END PLAN_BLOK_UPD; 

 PROCEDURE POPRAW_INST_SPISS (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pZAKR NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0, pINST NUMBER DEFAULT 0, pDANE2 VARCHAR2 DEFAULT null)
  AS
   CURSOR c1
   IS
    SELECT distinct L.nr_kom_zlec, L.nr_poz_zlec, L.nr_porz_obr, L.nr_inst_plan
    FROM l_wyc2 L
    WHERE L.nr_kom_zlec=pNK_ZLEC and pPOZ in (0,L.nr_poz_zlec) and L.nr_szt=1
      AND ELEMENT_LISTY(gLISTA_OBR,L.nr_obr)=1;
      --AND (pZAKR=0 OR pZAKR=1 and L.nr_obr=pNR_OBR OR pZAKR=2 and L.nr_inst_plan=pINST OR pZAKR=3 and (pTYP_INST is null or trim(I.ty_inst)=pTYP_INST or pTYP_INST='A C' and trim(I.ty_inst)='R C'));
    rec1 c1%ROWTYPE;
  BEGIN
   --zapis do zmiennych globalnych
   gNK_ZLEC:=pNK_ZLEC; gPOZ:=pPOZ; gZAKR:=pZAKR; gNR_OBR:=pNR_OBR; gINST:=pINST; 
   gDANE1:=case pZAKR when 1 then pNR_OBR when 2 then pINST else 0 end;
   gDANE2:=pDANE2;
   gLISTA_OBR:=LISTA_OBROBEK(pNK_ZLEC,pPOZ,pZAKR,pNR_OBR,pINST,0);

   OPEN c1;
   LOOP
    FETCH c1 INTO rec1;
    EXIT WHEN c1%NOTFOUND;
    UPDATE spiss
    SET inst_ustal=rec1.nr_inst_plan
    WHERE zrodlo='Z' and nr_komp_zr=rec1.nr_kom_zlec and nr_kol=rec1.nr_poz_zlec and nr_porz=rec1.nr_porz_obr;
   END LOOP;
   CLOSE c1;
  END POPRAW_INST_SPISS;
  
PROCEDURE LWYC2_INST_POW(pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pLISTA_OBR VARCHAR2)
AS
 BEGIN
  IF vWDR=0 THEN SELECT nr_wdr INTO vWDR FROM firma; END IF;
 
 
  IF trim(pLISTA_OBR) is not null THEN 
   gLISTA_OBR:=pLISTA_OBR;
  ELSE 
   gLISTA_OBR:=LISTA_OBROBEK(pNK_ZLEC,pPOZ,0,0,0,0);
  END IF;
   
  UPDATE l_wyc2 L2
  SET (nr_inst_plan,nr_zm_plan)= --wylaczona zmiana instalacji
      (select I.nr_inst_pow, L2.nr_zm_plan from l_wyc2 L
       left join parinst I on I.nr_komp_inst=L.nr_inst_plan
       where L.nr_kom_zlec=L2.nr_kom_zlec and L.nr_poz_zlec=L2.nr_poz_zlec and L.nr_szt=L2.nr_szt
         and L.nr_porz_obr=L2.nr_porz_obr-1500)
  WHERE L2.nr_kom_zlec=pNK_ZLEC and pPOZ in (0,L2.nr_poz_zlec)
      AND ELEMENT_LISTY(gLISTA_OBR,L2.nr_obr)=1
    AND L2.nr_porz_obr between 1501 and 1999
    AND EXISTS
      (select I.nr_inst_pow from l_wyc2 L
       left join parinst I on I.nr_komp_inst=L.nr_inst_plan
       where L.nr_kom_zlec=L2.nr_kom_zlec and L.nr_poz_zlec=L2.nr_poz_zlec and L.nr_szt=L2.nr_szt
         and L.nr_porz_obr=L2.nr_porz_obr-1500 and I.nr_inst_pow>0);

  DELETE FROM l_wyc2 L2
  WHERE L2.nr_kom_zlec=pNK_ZLEC and pPOZ in (0,L2.nr_poz_zlec)
    AND ELEMENT_LISTY(gLISTA_OBR,L2.nr_obr)=1
    AND L2.nr_zm_wyk=0
    AND nr_porz_obr between 1501 and 1999
    AND NOT EXISTS
      (select I.nr_inst_pow from l_wyc2 L
       left join parinst I on I.nr_komp_inst=L.nr_inst_plan
       left join gr_inst_dla_obr G on G.nr_komp_obr=L.nr_obr and G.nr_komp_inst=I.nr_inst_pow
       where L.nr_kom_zlec=L2.nr_kom_zlec and L.nr_poz_zlec=L2.nr_poz_zlec and L.nr_szt=L2.nr_szt
         and L.nr_porz_obr=L2.nr_porz_obr-1500 and I.nr_inst_pow>0 and G.nr_komp_gr is not null);
         
  INSERT INTO l_wyc2 (nr_kom_zlec, nr_poz_zlec, nr_szt, nr_warst, war_do, nr_obr, nr_porz_obr, nr_inst_plan, nr_zm_plan, nr_inst_wyk, nr_zm_wyk, kolejn, flag)
    SELECT nr_kom_zlec, nr_poz_zlec, nr_szt, nr_warst, war_do, nr_obr, nr_porz_obr+1500, I.nr_inst_pow, nr_zm_plan, 0, 0, decode(vWDR,11,floor(L.kolejn*0.01)*100+I.kolejn,L.kolejn+1), -1
    FROM l_wyc2 L
    LEFT JOIN parinst I ON I.nr_komp_inst=L.nr_inst_plan
    LEFT JOIN gr_inst_dla_obr G ON G.nr_komp_obr=L.nr_obr and G.nr_komp_inst=I.nr_inst_pow
    WHERE nr_kom_zlec=pNK_ZLEC and pPOZ in (0,L.nr_poz_zlec)
      AND ELEMENT_LISTY(gLISTA_OBR,L.nr_obr)=1
      AND I.nr_inst_pow>0 AND G.nr_komp_gr is not null
      AND NOT EXISTS
      (select 1 from l_wyc2 L2
       where L.nr_kom_zlec=L2.nr_kom_zlec and L.nr_poz_zlec=L2.nr_poz_zlec and L.nr_szt=L2.nr_szt
         and L2.nr_porz_obr=L.nr_porz_obr+1500);
         
END LWYC2_INST_POW;

PROCEDURE POPRAW_OBR_JEDNOCZ (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pNR_OBR NUMBER default 0, pODWROTNIE NUMBER default 0) --pODWROTNIE=1 oznacza poprawê NA PODSTAWIE danych obr jednoczesnej
AS
 BEGIN
  IF pODWROTNIE=0 THEN
   UPDATE l_wyc2 L
   SET  (nr_inst_plan, nr_zm_plan) =
        (select nvl(max(L2.nr_inst_plan),L.nr_inst_plan), nvl(max(L2.nr_zm_plan),L.nr_zm_plan)
         from l_wyc2 L2, v_obr_jednocz J 
         where L2.nr_kom_zlec=L.nr_kom_zlec and L2.nr_poz_zlec=L.nr_poz_zlec and L2.nr_szt=L.nr_szt
           and L2.nr_warst=L.nr_warst and L2.war_do=L.war_do
           and J.nr_obr_jednocz=L.nr_obr and J.nr_komp_obr=L2.nr_obr and J.nr_komp_inst=L2.nr_inst_plan)
   WHERE nr_kom_zlec=pNK_ZLEC and pPOZ in (0,L.nr_poz_zlec) and pNR_OBR in (0,L.nr_obr)
     AND exists (select 1 from v_obr_jednocz where nr_obr_jednocz=L.nr_obr);
   USTAW_WSP(pNK_ZLEC, pNR_OBR);
   
  ELSE 
   for o in (select distinct nr_komp_obr from v_obr_jednocz where nr_obr_jednocz=pNR_OBR) loop
    UPDATE l_wyc2 L
    SET (nr_inst_plan, nr_zm_plan) =
        (select nvl(max(L2.nr_inst_plan),L.nr_inst_plan), nvl(max(L2.nr_zm_plan),L.nr_zm_plan)
         from l_wyc2 L2, v_obr_jednocz J 
         where L2.nr_kom_zlec=L.nr_kom_zlec and L2.nr_poz_zlec=L.nr_poz_zlec and L2.nr_szt=L.nr_szt
           and L2.nr_warst=L.nr_warst and L2.war_do=L.war_do
           and J.nr_obr_jednocz=L2.nr_obr and J.nr_komp_obr=L.nr_obr and J.nr_komp_inst=L2.nr_inst_plan)
    WHERE nr_kom_zlec=pNK_ZLEC and pPOZ in (0,L.nr_poz_zlec) and L.nr_obr=o.nr_komp_obr
      AND exists (select 1 from l_wyc2 L2
                  where L2.nr_kom_zlec=L.nr_kom_zlec and L2.nr_poz_zlec=L.nr_poz_zlec and L2.nr_szt=L.nr_szt
                    and L2.nr_warst=L.nr_warst and L2.war_do=L.war_do and L2.nr_obr=pNR_OBR);
    USTAW_WSP(pNK_ZLEC, o.nr_komp_obr);    
   end loop;
  END IF;
    
  POPRAW_INST_SPISS(pNK_ZLEC); ---wylaczyc triger SPISS_INSTEADOF
  
END POPRAW_OBR_JEDNOCZ;

PROCEDURE WPISZ_INST_WG_CIAGU_EFF (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pLISTA_OBR VARCHAR2)
AS
 inst_alter NUMBER(10);
 CURSOR c1 (pPOZ NUMBER, pNR_PORZ NUMBER, pINST_ALTERNAT NUMBER)
  IS SELECT * FROM v_spiss
     WHERE zrodlo='Z' and nr_kom_zlec=pNK_ZLEC and nr_poz=pPOZ and nr_porz=pNR_PORZ and nk_inst=pINST_ALTERNAT;
 BEGIN
   IF trim(pLISTA_OBR) is not null THEN 
    gLISTA_OBR:=pLISTA_OBR;
   ELSE 
    gLISTA_OBR:=LISTA_OBROBEK(pNK_ZLEC,pPOZ,0,0,0,0);
   END IF;

   FOR v IN (select V.*  --,(select naz_inst from parinst where nr_komp_inst=nk_inst) naz_inst
             from v_spiss V
             where nr_kom_zlec=pNK_ZLEC and pPOZ in (0,V.nr_poz) and ELEMENT_LISTY(gLISTA_OBR,V.nk_obr)=1
               and etap<3 -- bez monta¿u
               and gr_akt<>2 -- bez inst. powiaz.
               and nk_inst in (select B.nr_komp_inst --instalacje z ci¹gu dla 
                               from l_wyc2 L, gr_inst_pow A, gr_inst_pow B 
                               where L.nr_kom_zlec=pNK_ZLEC and L.nr_poz_zlec=V.nr_poz and L.nr_szt=1 and L.nr_obr in (98,99)
                                 and A.nr_komp_inst=L.nr_inst_plan
                                 and B.nr_komp_gr=A.nr_komp_gr and B.nr_komp_inst not in (0,A.nr_komp_inst))
            ) LOOP   
     IF v.kryt_suma=0 THEN
       USTAW_INST (v.nr_kom_zlec, v.nr_poz, v.nr_porz, 0, v.nk_inst, v.nr_inst_pow, null);--pNK_ZLEC NUMBER, pNR_POZ NUMBER, pNR_PORZ NUMBER, pNK_OBR NUMBER, pNK_INST NUMBER, pNK_INST_POW NUMBER DEFAULT null, pNK_ZM NUMBER DEFAULT null)
--     ELSIF v.kryt_atryb_wyl>0 THEN null;  --sprawdzenie instalacji wykl. wg atrybutów
--     ELSIF v.kryt_wym_min>0 THEN null;  --sprawdzenie instalacji wykl. wg wym min.
--     ELSE null;  --sprawdzenie instalacji wykl. wg wym max.
     ELSE
      select case when v.kryt_atryb_wyl>0 then nr_inst_wyl
                  when v.kryt_wym_min>0 then nr_inst_min
                  else nr_inst_max end
        into inst_alter
      from parinst where nr_komp_inst=v.nk_inst;
      OPEN c1 (v.nr_poz, v.nr_porz, inst_alter);
      FETCH c1 INTO v;
      IF v.kryt_suma=0 THEN
       USTAW_INST (v.nr_kom_zlec, v.nr_poz, v.nr_porz, 0, v.nk_inst, v.nr_inst_pow, null);
      END IF;
      CLOSE c1;
     END IF;
   END LOOP;
END WPISZ_INST_WG_CIAGU_EFF;

PROCEDURE WPISZ_INST_WG_CIAGU (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pLISTA_OBR VARCHAR2)
AS
 BEGIN
  IF vWDR=0 THEN SELECT nr_wdr INTO vWDR FROM firma; END IF;
  IF vWDR=22 THEN
   WPISZ_INST_WG_CIAGU_EFF (pNK_ZLEC, pPOZ, pLISTA_OBR);
   RETURN;
  END IF;   
  
  --po nowemu, GP
  IF trim(pLISTA_OBR) is not null THEN 
    gLISTA_OBR:=pLISTA_OBR;
  ELSE 
    gLISTA_OBR:=LISTA_OBROBEK(pNK_ZLEC,pPOZ,0,0,0,0);
  END IF;

   FOR v IN (select v.nr_kom_zlec, v.nr_poz, v.nr_porz, v.nk_inst, v.nr_inst_pow,
                    dense_rank() OVER (PARTITION BY V.nr_kom_zlec, V.nr_poz, V.nr_porz ORDER BY G.nr_komp_gr, G.kolej, V.kolejnosc_z_grupy) Rank_grup,
                    dense_rank() OVER (PARTITION BY V.nr_kom_zlec, V.nr_poz, V.nk_obr, V.war_od ORDER BY V.nr_porz) Rank_obr,
                    G0.nr_komp_gr, G.nr_komp_inst, G.kolej
             from v_spiss V
             inner join gr_inst_pow G on V.nk_inst=G.nr_komp_inst
             inner join gr_inst_pow G0 on G0.nr_komp_gr=G.nr_komp_gr and G0.nr_komp_inst>0 and not G0.nr_komp_inst=G.nr_komp_inst and G0.flag=1 --inst. wiodaca
             where V.nr_kom_zlec=pNK_ZLEC and V.kryt_suma=0
               and exists (select 1 from l_wyc2 L2
                           where L2.nr_kom_zlec=V.nr_kom_zlec and L2.nr_poz_zlec=V.nr_poz and L2.nr_szt=1
                             and L2.nr_inst_plan=G0.nr_komp_inst
                             and (L2.nr_warst between V.war_od and V.war_do or V.war_od between L2.nr_warst and L2.war_do) --potrzebny alternatywny zakres warstw dla inst. wcz i pozn.
                           )
            )
    LOOP   
     IF V.rank_grup=1 and V.rank_obr=1 THEN
       USTAW_INST (v.nr_kom_zlec, v.nr_poz, v.nr_porz, 0, v.nk_inst, v.nr_inst_pow, null);--pNK_ZLEC NUMBER, pNR_POZ NUMBER, pNR_PORZ NUMBER, pNK_OBR NUMBER, pNK_INST NUMBER, pNK_INST_POW NUMBER DEFAULT null, pNK_ZM NUMBER DEFAULT null)
     END IF;
    END LOOP;
END WPISZ_INST_WG_CIAGU;

 FUNCTION CZY_MOZNA_PRZENIESC (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pINST NUMBER, pZM NUMBER, pINST_Z NUMBER, pINST_NA NUMBER) RETURN NUMBER
  AS
   CURSOR cL1 (pNK_ZLEC NUMBER, pPOZ NUMBER, pINST_ZAKR NUMBER, pZM_ZAKR NUMBER, pINST_PLAN NUMBER)
   IS 
    SELECT distinct L1.nr_poz_zlec, L2.nr_porz_obr, L2.nr_obr
    FROM l_wyc2 L1
    LEFT JOIN l_wyc2 L2 ON L1.nr_kom_zlec=L2.nr_kom_zlec and L1.nr_poz_zlec=L2.nr_poz_zlec and L1.nr_warst=L2.nr_warst and L1.nr_szt=L2.nr_szt and L2.nr_inst_plan=pINST_PLAN
    WHERE L1.nr_kom_zlec=pNK_ZLEC AND pPOZ in (0,L1.nr_poz_zlec) AND L1.nr_inst_plan=pINST_ZAKR AND L1.nr_zm_plan=pZM_ZAKR AND L2.nr_porz_obr is not null;
   rec cL1%ROWTYPE;
   vKrytSuma NUMBER;
   vObsl NUMBER;
   wyn NUMBER:=-99;
  BEGIN
    OPEN cL1 (pNK_ZLEC, pPOZ, pINST, pZM, pINST_Z);
    LOOP
      FETCH cL1 INTO rec;
      EXIT WHEN cL1%NOTFOUND;
      wyn:=-rec.nr_obr; --zwracany nr obróbki z minusem, jezeli nie mozna jej wykonanc na inst. docelowej
      SELECT kryt_suma, obsl_tech INTO vKrytSuma, vObsl
      FROM v_spiss
      WHERE zrodlo='Z' and nr_kom_zlec=pNK_ZLEC and nr_poz=rec.nr_poz_zlec and nr_porz=rec.nr_porz_obr and nk_inst=pINST_NA;      
      IF vKrytSuma>0 and vObsl<>1 THEN
       wyn:=rec.nr_poz_zlec;
       EXIT;
      ELSE
       wyn:=0;
      END IF; 
    END LOOP;
    CLOSE cL1;  
    RETURN wyn;
  EXCEPTION WHEN OTHERS THEN
    IF cL1%ISOPEN THEN CLOSE cL1; END IF;
    RETURN wyn;
  END CZY_MOZNA_PRZENIESC;


 FUNCTION CZY_MOZNA_WYKONAC (pZT CHAR, pNK_ZLEC NUMBER, pNR_POZ NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0, pNR_PORZ NUMBER DEFAULT 0) RETURN NUMBER
  AS
   CURSOR c1 IS 
    SELECT V.zrodlo, V.nr_kom_zlec, V.nr_poz, V.nr_porz, V.obsl_tech
    FROM v_spiss V
    WHERE V.nr_kom_zlec=pNK_ZLEC AND pNR_POZ in (0,V.nr_poz) AND pNR_OBR in (0,V.nk_obr) AND pNR_PORZ in (0,V.nr_porz)
      AND V.kryt_suma>0; --AND V.obsl_tech<>1;
   CURSOR c2 (pPOZ NUMBER, pPORZ NUMBER) IS
    SELECT decode(nk_inst,inst_wybr,2,1) jest_mozl --1-mozna ale poza Planem; 2-mozna i jest w Planie
    FROM v_spiss 
    WHERE zrodlo=pZT and nr_kom_zlec=pNK_ZLEC and nr_poz=pPOZ and nr_porz=pPORZ and (kryt_suma=0 or obsl_tech=1)
    ORDER BY decode(nk_inst,inst_wybr,2,1) desc; --najpierw INST_STD => 2
   rec1 c1%ROWTYPE;
   rec2 c2%ROWTYPE;
   wyn NUMBER:=3;
  BEGIN
    OPEN c1;
    LOOP
     FETCH c1 INTO rec1;
     EXIT WHEN c1%NOTFOUND;
     IF rec1.obsl_tech=1 THEN
      wyn:=2;
     ELSE --konflikt niezakcpetowany
      OPEN c2 (rec1.nr_poz, rec1.nr_porz);
      FETCH c2 INTO rec2;
      IF c2%NOTFOUND THEN
       wyn:=0;
       EXIT;
      ELSE 
       wyn:=least(wyn, rec2.jest_mozl);
      END IF;
     END IF; 
     CLOSE c2;
    END LOOP; 
    CLOSE c1;  
    RETURN wyn; 
  EXCEPTION WHEN OTHERS THEN
   IF c1%ISOPEN THEN CLOSE c1; END IF;
   IF c2%ISOPEN THEN CLOSE c2; END IF;
   RETURN -1;   
  END CZY_MOZNA_WYKONAC;

FUNCTION LISTA_PRZEKROCZEN(pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pZAKR NUMBER DEFAULT 0, pOBR NUMBER, pINST NUMBER DEFAULT 0)  RETURN VARCHAR2
 AS
 BEGIN
--select nk_inst, nk_obr, max(kryt_suma), listagg(nk_inst,',') within group (order by KOLEJNOSC_Z_GRUPY), listagg(kryt_suma,',') within group (order by KOLEJNOSC_Z_GRUPY)
--from v_spiss V
--where zrodlo='Z' and nr_kom_zlec=497301-- (select nr_kom_zlec from zamow where typ_zlec='Pro' and nr_zlec=14458)
--  and (nr_poz, nr_porz) in (select nr_poz_zlec, nr_porz_obr from l_wyc2 where nr_kom_zlec=V.nr_kom_zlec and nr_inst_plan=14 and nr_zm_plan>0)
--group by nk_inst, nk_obr;
   NULL;
 END LISTA_PRZEKROCZEN;


FUNCTION LISTA_PRZEKROCZEN1(pLISTA_ZLEC VARCHAR2, pSQL_WHERE VARCHAR2) RETURN VARCHAR2 AS
 vQuery VARCHAR2(5000) := 
 'Select listagg(lista,''|'') within group (order by nk_obr)
  From
  (Select V.nk_obr, V.nk_obr||'':''||'||
          --NR_OBR:FLAG:LISTA_NR_KOMP_INST-ILE_PRZEKR:LISTA_NR_INST-ILE_PRZEKR
          --FLAG 3-brak przekr   2-przekroczenia na inst. poza planen  1-przekroczenia na inst. z planu   0-przekroczenia na wszystkich  
          'case when max(ile_przekr)=0 then 3
                when min(ile_przekr)>0 then 0
                when max(ile_przekr*ile_w_planie)=0 then 2
                when max(ile_przekr*ile_w_planie)>0 then 1
                else -1 end||
          '':''||listagg(V.nk_inst||''-''||ile_przekr,'','') within group (order by V.kol)||
          '':''||listagg(i.nr_inst||''-''||ile_przekr,'','') within group (order by V.kol) lista
   From
   (select nk_inst, nk_obr, max(kolejnosc_z_grupy) kol,  COUNT(DECODE(kryt_suma,0,NULL,1)) ile_przekr,
           sum((select count(1) from l_wyc2 where nr_kom_zlec=S.nr_kom_zlec and nr_poz_zlec=S.nr_poz and nr_porz_obr=S.nr_porz and nr_inst_plan=S.nk_inst)) ile_w_planie
    from v_spiss S
    where zrodlo=''Z'' and nr_kom_zlec in ('||pLISTA_ZLEC||')
      and EXISTS
         (SELECT Z.nr_zlec FROM v_wyc1 V
          LEFT JOIN katalog K on K.nr_kat=V.nr_kat
          LEFT JOIN struktury S on S.kod_str=V.indeks
          LEFT JOIN zamow Z on Z.nr_kom_zlec=V.nr_kom_zlec
          LEFT JOIN klient on klient.nr_kon=Z.nr_kon
          WHERE S.nr_kom_zlec=V.nr_kom_zlec and S.nr_poz=V.nr_poz_zlec and ELEMENT_LISTY(V.nry_porz,S.nr_porz)=1
            AND (S.etap=V.etap and S.war_od=V.nr_warst or
                 S.etap>V.etap and V.nr_warst between S.war_od and S.war_do or
                 S.etap<V.etap and S.war_od between V.nr_warst and V.nr_warst_do)
                 --and nr_inst_plan=14 and nr_zm_plan>0 and nr_obr=23
                --AND V.nr_inst_plan=14 /*and V.nr_zm_plan=24242*/ and V.nr_obr=23 and V.nr_kom_zlec in (497301,497217)
            AND '||pSQL_WHERE||'
         )
    --and EXISTS
    --      (select nr_poz_zlec, nr_porz_obr
    --       from l_wyc2 L
    --       where nr_kom_zlec=S.nr_kom_zlec --and nr_inst_plan=14 and nr_zm_plan>0
    --         and nr_poz_zlec=S.nr_poz And nr_porz_obr=S.nr_porz
    --           AND EXISTS (SELECT 1 FROM v_wyc1 V1
    --                       WHERE L.nr_kom_zlec=V.nr_kom_zlec and L.nr_poz_zlec=V.nr_poz_zlec and L.nr_szt=V.nr_szt
    --                       AND (L.kolejn=V.kolejn and L.nr_warst=V.nr_warst or
    --                            L.kolejn>V.kolejn and V.nr_warst between L.nr_warst and L.war_do or
    --                            L.kolejn<V.kolejn and L.nr_warst between V.nr_warst and V.nr_warst_do)
    --                         and nr_inst_plan=14 and nr_zm_plan>0 and nr_obr=23
    --                       AND V.nr_inst_plan=14 /*and V.nr_zm_plan=24242*/ and V.nr_obr=23 and V.nr_kom_zlec in (497301,497217)
    --                       )
    --      )
    group by nk_inst, nk_obr
   ) V
   Left join parinst I On I.nr_komp_inst=V.nk_inst
   Group by V.nk_obr)';
  vLista VARCHAR2(5000);
 BEGIN
  EXECUTE IMMEDIATE vQuery INTO vLista;
  RETURN vLista;
 END LISTA_PRZEKROCZEN1;

 FUNCTION LISTA_OBROBEK(pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pZAKR NUMBER DEFAULT 0, pOBR NUMBER, pINST NUMBER DEFAULT 0, pWPLANIE NUMBER) RETURN VARCHAR2
  AS
   lista VARCHAR2(500):=',';
   vWPlanie NUMBER;
  BEGIN
   FOR r IN (select G.nr_komp_obr nr_obr, nr_komp_inst
             from gr_inst_dla_obr G
             left join parinst I using (nr_komp_inst)
             where case when pZAKR=0
                          or pZAKR=1 and G.nr_komp_obr=pOBR
                          or pZAKR=2 and nr_komp_inst=pINST
                          or pZAKR=3 and trim(I.ty_inst) in ('A C')   
                          or pZAKR=4 and trim(I.ty_inst) in ('MON','STR')
                          or pZAKR=5 and trim(I.ty_inst) not in ('A C','R C','MON','STR')
                          or pZAKR=6 and trim(I.ty_inst) not in ('MON','STR')
                          or pZAKR=7 and trim(I.ty_inst) not in ('A C','R C')
                        then 1 else 0 end = 1  
               and exists (select distinct nk_obr from spiss where zrodlo='Z' and nr_komp_zr=pNK_ZLEC and pPOZ in (0,nr_kol) and nk_obr=G.nr_komp_obr)
             order by I.kolejn )
   LOOP
    IF pWPLANIE=0 AND instr(lista,','||r.nr_obr||',')=0 THEN
     lista:=lista||r.nr_obr||',';
    ELSIF pWPLANIE=1 AND instr(lista,','||r.nr_obr||',')=0 THEN
     SELECT count(1) INTO vWPlanie
     FROM l_wyc2 WHERE nr_kom_zlec=pNK_ZLEC and pPOZ in (0,nr_poz_zlec) and nr_inst_plan=r.nr_komp_inst and nr_obr=r.nr_obr;
     IF vWPlanie>0 THEN
      lista:=lista||r.nr_obr||',';
     END IF;
    END IF;
   END LOOP; 
   RETURN substr(lista,2);
  END LISTA_OBROBEK;

 PROCEDURE ZAPISZ_PLAN (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pZAKR NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0, pINST NUMBER DEFAULT 0, pDANE2 VARCHAR2 DEFAULT null, pBUFOR NUMBER DEFAULT 1)
  AS
   recInst cInst%ROWTYPE; --definicja kursora w specyfikacji pakietu
  BEGIN
   --zapis do zmiennych globalnych
   gNK_ZLEC:=pNK_ZLEC; gPOZ:=pPOZ; gZAKR:=pZAKR; gNR_OBR:=pNR_OBR; gINST:=pINST; 
   gDANE1:=case pZAKR when 1 then pNR_OBR when 2 then pINST else 0 end;
   gDANE2:=pDANE2;
   gLISTA_OBR:=LISTA_OBROBEK(pNK_ZLEC,pPOZ,pZAKR,pNR_OBR,pINST,0);
   ZAPISZ_LOG('ZAPISZ_PLAN:'||INFO_ZAKR,pNK_ZLEC,'N',0);
   IF pZAKR=0 THEN
    --usuwa caly plan dla zlecenia   
    USUN_PLAN(pNK_ZLEC, 0, 0, 0);
   ELSIF pBUFOR=1 THEN
    --usuwa Plan dla zlecenia z instalacji zapisnanych w backup'ie oraz w akt. L_WYC2
    --USUN_PLAN_WG_BACKUPU(pNK_ZLEC, pPOZ, pZAKR, pNR_OBR, pINST, pTYP_INST);
    USUN_PLAN_WG_BACKUPU(pNK_ZLEC, pPOZ);
   ELSE
    --TODO usuwanie Planu bez u¿ycia bufora
     NULL;
   END IF;
   --@V POPRAW_JEDNOCZ_LWYC2(pNK_ZLEC, pPOZ, pZAKR, pNR_OBR, pINST, pDANE2);
   --logowanie zmian w ZLEC_ZM
    ZAPISZ_ZM_ZLEC;
   --OPEN cInst(pNK_ZLEC, pPOZ, pZAKR, pNR_OBR, pINST, pTYP_INST);
   OPEN cInst(pNK_ZLEC, pPOZ);
   LOOP
    FETCH cInst INTO recInst;
    EXIT WHEN cInst%NOTFOUND;
    IF recInst.typ_inst='A C' THEN
     ZAPISZ_WYKZAL_DLA_AC(pNK_ZLEC, recInst.nr_inst_plan, pPOZ);
    ELSIF recInst.typ_inst in ('MON','STR') THEN
     ZAPISZ_SPISP(pNK_ZLEC, recInst.nr_inst_plan, pPOZ);
    ELSE --pozostale inst
     ZAPISZ_WYKZAL(pNK_ZLEC, recInst.nr_inst_plan, pPOZ);
    END IF;
    ZAPISZ_HARMON(pNK_ZLEC, recInst.nr_inst_plan);
    --ZAPISZ_LWYC(pNK_ZLEC, recInst.nr_inst_plan, pPOZ);   
    --AKTUALIZUJ_LWYC(recInst.nr_inst_plan, pPOZ);
    PORZADKUJ_ZMIANY_I_KALINST (pNK_ZLEC, recInst.nr_inst_plan);
   END LOOP;
   CLOSE cInst;
   AKTUALIZUJ_LWYC(0, pPOZ);
   --aktualizacja INST_STD oraz STR_DOD z rekordzie 0-wym SPISS
   POPRAW_INST_SPISS (pNK_ZLEC, pPOZ, pZAKR, pNR_OBR, pINST, pDANE2);
   --@V AKTUALIZUJ_CIAG_TECHN(pNK_ZLEC);
   AKTUALIZUJ_ZAMOW(pNK_ZLEC);
   AKTUALIZUJ_SPISZ(pNK_ZLEC);
   AKTUALIZUJ_ZAMINFO(pNK_ZLEC);
   -- ustawinie DATA_PL, ZM_PL i NR_KOMP_INST w SURZAM
   AKTUALIZUJ_SURZAM(pNK_ZLEC);
   --@V WPISZ_DATY_ZAP_DO_SURZAM(pNK_ZLEC);
   --zatwierdzenie obecnych danych w L_WYC2, usuniecie blokady i backup'u
   LWYC2_COMMIT(pNK_ZLEC, pPOZ, pZAKR, pNR_OBR, pINST, pDANE2);
   --12.2018 przeniesienie do LWYC2_COMMIT
   --PLAN_BLOK_UPD (-1, pNK_ZLEC, pPOZ); --usuniecie z naglowka bufora
  EXCEPTION WHEN OTHERS THEN
   IF cInst%ISOPEN THEN CLOSE cInst; END IF;
   ZAPISZ_LOG('PKG.ZAPISZ_PLAN',pNK_ZLEC,'E',0);
   ZAPISZ_ERR(SQLERRM||': '||dbms_utility.FORMAT_ERROR_BACKTRACE);
   RAISE;
  END ZAPISZ_PLAN;

 --PROCEDURE USUN_PLAN_WG_BACKUPU (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pZAKR NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0, pINST NUMBER DEFAULT 0, pTYP_INST VARCHAR2 DEFAULT null)
 PROCEDURE USUN_PLAN_WG_BACKUPU (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0)
  AS
   recInst cInst%ROWTYPE; --definicja kursora w specyfikacji pakietu
  BEGIN
   --OPEN cInst(-pNK_ZLEC, pPOZ, pZAKR, pNR_OBR, pINST, pTYP_INST);
   --OPEN cInst(pNK_ZLEC, pPOZ, pZAKR, pNR_OBR, pINST, pTYP_INST,1);
   OPEN cInst(pNK_ZLEC, pPOZ, 1);
   LOOP
    FETCH cInst INTO recInst;
    EXIT WHEN cInst%NOTFOUND;
    ZAPISZ_LOG('USUN_PLAN_WG_BACKUPU',pNK_ZLEC,'D',-recInst.nr_inst_plan);
    IF recInst.typ_inst='A C' THEN
      DELETE FROM wykzal WHERE nr_komp_zlec=pNK_ZLEC  and pPOZ in (0,nr_poz) and nr_komp_instal=recInst.nr_inst_plan and nr_zm_plan>0;
    ELSIF recInst.typ_inst in ('MON','STR') THEN
      DELETE FROM spisp WHERE numer_komputerowy_zlecenia=pNK_ZLEC  and pPOZ in (0,nr_poz) and nr_kom_inst=recInst.nr_inst_plan;
    ELSE --pozostale inst
      DELETE FROM wykzal WHERE nr_komp_zlec=pNK_ZLEC  and pPOZ in (0,nr_poz) and nr_komp_instal=recInst.nr_inst_plan and nr_zm_plan>0;
    END IF;
    DELETE FROM harmon WHERE nr_komp_zlec=pNK_ZLEC and typ_harm='P' and nr_komp_inst=recInst.nr_inst_plan;
    --DELETE FROM l_wyc WHERE nr_kom_zlec=pNK_ZLEC  and pPOZ in (0,nr_poz_zlec) and nr_inst=recInst.nr_inst_plan;    
    --przeliczenie zmian i kalendarza
    PORZADKUJ_ZMIANY_I_KALINST (-pNK_ZLEC, recInst.nr_inst_plan);
   END LOOP;
   CLOSE cInst; 
  EXCEPTION WHEN OTHERS THEN
   IF cInst%ISOPEN THEN CLOSE cInst; END IF;
   ZAPISZ_LOG('PKG.USUN_PLAN',pNK_ZLEC,'E',0);
   ZAPISZ_ERR(SQLERRM||': '||dbms_utility.FORMAT_ERROR_BACKTRACE);
   RAISE;
  END USUN_PLAN_WG_BACKUPU;

 PROCEDURE ZAPISZ_WYKZAL_DLA_AC (pNK_ZLEC IN NUMBER, pINST IN NUMBER DEFAULT 0, pPOZ IN NUMBER DEFAULT 0)
 AS
  BEGIN
   INSERT INTO wykzal(nr_komp_zlec, nr_poz, nr_warst, straty, --nr_warst_do,
                      indeks, nr_komp_obr, il_calk, il_jedn,
                      nr_komp_instal, nr_zm_plan, d_plan, zm_plan, il_plan, il_zlec_plan, wsp_przel,
                      --nr_komp_inst_wyk, 
                      nr_komp_zm, d_wyk, zm_wyk,  il_wyk, nr_oper, il_zlec_wyk, --wsp_wyk,
                      flag, --straty, nr_kat,
                      kod_dod, nr_komp_gr)
   SELECT L.nr_kom_zlec, /*V.nr_poz_zlec, V.nr_warst, max(V.nr_warst_do),*/0,0,0,
          S.indeks, /*O.nr_kat_obr*/ 0 nr_komp_obr, /*max(P.ilosc)*/count(1) il_calk, avg(S.il_obr) il_jedn,
          L.nr_inst_plan, L.nr_zm_plan, PKG_CZAS.NR_ZM_TO_DATE(L.nr_zm_plan) d_plan , PKG_CZAS.NR_ZM_TO_ZM(L.nr_zm_plan) zm_plan,
          count(decode(L.flag,0,null,1)) il_plan, sum(decode(L.flag,0,0,S.il_obr)) il_zlec_plan, avg(W1.wsp_alt), 
          --L.nr_inst_wyk, 
          L.nr_zm_wyk, PKG_CZAS.NR_ZM_TO_DATE(L.nr_zm_wyk) , PKG_CZAS.NR_ZM_TO_ZM(L.nr_zm_wyk), sum(decode(L.nr_zm_wyk,0,0,1)), ' ', sum(decode(L.nr_zm_wyk,0,0,S.il_obr)), --avg(W2.wsp_alt),
          1, /*0, max(S.nr_kat),*/ ' ', 0 nr_komp_gr --decode(max(I.rodz_plan),1,nvl(max(G.nkomp_grupy),0),0)
   --FROM v_wyc2 V
   FROM l_wyc2 L
   LEFT JOIN spiss S ON  S.zrodlo='Z' AND S.nr_komp_zr=L.nr_kom_zlec AND S.nr_kol=L.nr_poz_zlec AND S.nr_porz=L.nr_porz_obr
   --pobanie wsp plan. i wsp wyk.
   LEFT JOIN wsp_alter W1 ON W1.nr_zestawu=0 and W1.nr_kom_zlec=S.nr_komp_zr and W1.nr_poz=S.nr_kol and W1.nr_porz_obr=S.nr_porz and W1.nr_komp_inst=L.nr_inst_plan
   LEFT JOIN wsp_alter W2 ON W2.nr_zestawu=0 and W2.nr_kom_zlec=S.nr_komp_zr and W2.nr_poz=S.nr_kol and W2.nr_porz_obr=S.nr_porz and W2.nr_komp_inst=L.nr_inst_wyk
   --LEFT JOIN spisz P ON P.nr_kom_zlec=L.nr_kom_zlec and P.nr_poz=L.nr_poz_zlec       
   --LEFT JOIN slparob O ON O.nr_k_p_obr=L.nr_obr
   LEFT JOIN parinst I ON I.nr_komp_inst=L.nr_inst_plan
   --LEFT JOIN kat_gr_plan G ON G.typ_kat=L.indeks AND G.nkomp_instalacji=L.nr_inst_plan
   WHERE L.nr_kom_zlec=pNK_ZLEC and pINST in (0,L.nr_inst_plan) and pPOZ in (0,L.nr_poz_zlec) and I.ty_inst='A C' and L.nr_zm_plan+L.nr_zm_wyk>0-- and L.flag>0
   GROUP BY L.nr_kom_zlec, /*L.nr_poz_zlec, L.nr_warst,*/ S.indeks, /*O.nr_kat_obr,*/ L.nr_inst_plan, L.nr_zm_plan, L.nr_inst_wyk, L.nr_zm_wyk
   HAVING count(decode(L.flag,0,null,1))>0; --przy FLAG=0 nie ma zapisu w WYKZAL
 END ZAPISZ_WYKZAL_DLA_AC;

 PROCEDURE AKTUALIZUJ_CIAG_TECHN (pNK_ZLEC NUMBER)
  AS
   --kursor dla ustawienia kodów instalacji
   CURSOR c1 IS
    SELECT distinct nr_poz_zlec, naz2, kolejn, LEAD (nr_poz_zlec,1,0) over (ORDER BY nr_poz_zlec, kolejn) AS nast_poz
    FROM (select distinct nr_poz_zlec, nr_inst_plan nr_komp_inst from l_wyc2 where nr_kom_zlec=pNK_ZLEC)
    LEFT JOIN parinst USING (nr_komp_inst)
    WHERE naz2 is not null AND naz2<>' '
    ORDER BY nr_poz_zlec, kolejn;
   rec1 c1%ROWTYPE;
   str1 VARCHAR2(100):=' ';
  BEGIN
   OPEN c1;
    LOOP
     FETCH c1 INTO rec1;
     EXIT WHEN c1%NOTFOUND;
     str1:=ltrim(str1)||trim(rec1.naz2)||' ';
     IF rec1.nr_poz_zlec<>rec1.nast_poz THEN
      UPDATE spiss SET str_dod=substr(str1,1,50) WHERE zrodlo='Z' AND nr_komp_zr=pNK_ZLEC AND nr_kol=rec1.nr_poz_zlec AND nr_porz=0;
      str1:=' ';
     END IF; 
    END LOOP;
   CLOSE c1; 
  END AKTUALIZUJ_CIAG_TECHN;

 PROCEDURE PORZADKUJ_ZMIANY_I_KALINST (pNK_ZLEC NUMBER, pNK_INST NUMBER)
  AS
  BEGIN 
   UPDATE zmiany Z
    SET (il_plan, wielk_plan)
       =(select nvl(sum(H.ilosc),0), nvl(sum(H.wielkosc),0)
         from harmon H
         where H.nr_komp_inst=Z.nr_komp_inst and H.dzien=Z.dzien and H.zmiana=Z.zmiana and H.typ_harm='P')
    WHERE (nr_komp_inst,nr_komp_zm) in (select distinct nr_inst_plan, nr_zm_plan
                                        from l_wyc2 where nr_kom_zlec=pNK_ZLEC and pNK_INST in (0,nr_inst_plan) and nr_zm_plan>0);
   UPDATE kalinst K
    SET (il_plan, wielk_plan, p_plan)
       =(select nvl(sum(H.ilosc),0), nvl(sum(H.wielkosc),0), 
         nvl(decode(min(I.wyd_nom),0,0,100*sum(H.wielkosc)/min(I.wyd_nom*/*ile_godz*/(case when K.koniec>K.poczatek then (K.koniec-K.poczatek)/3600 else 24+(K.koniec-K.poczatek)/3600 end))), 0) procent_planu
         from harmon H
         left join parinst I on I.nr_komp_inst=H.nr_komp_inst
         where H.nr_komp_inst=K.nr_komp_inst and H.dzien=K.dzien and H.typ_harm='P')
    WHERE (nr_komp_inst,dzien) in (select distinct nr_inst_plan, PKG_CZAS.NR_ZM_TO_DATE(nr_zm_plan)
                                   from l_wyc2 where nr_kom_zlec=pNK_ZLEC and pNK_INST in (0,nr_inst_plan) and nr_zm_plan>0);
  END PORZADKUJ_ZMIANY_I_KALINST;

 PROCEDURE AKTUALIZUJ_ZAMOW (pNK_ZLEC NUMBER) AS
  BEGIN
   UPDATE zamow
   SET (d_pocz_prod, d_plan)=(Select nvl(min(dzien),to_date('01/1901','MM/YYYY')), nvl(max(dzien),to_date('01/1901','MM/YYYY'))
                              From harmon
                              Where nr_komp_zlec=zamow.nr_kom_zlec and typ_harm='P'
                                And dzien>to_date('2001','YYYY'))
   WHERE nr_kom_zlec=pNK_ZLEC;
  END AKTUALIZUJ_ZAMOW;

 PROCEDURE AKTUALIZUJ_SPISZ (pNK_ZLEC NUMBER) AS
  BEGIN
   UPDATE spisz
   SET (nr_komp_inst, wsp_przel)=
       (Select nvl(max(nr_inst_plan),0), nvl(max(wsp_p),0)
        From v_wyc1
        Where nr_kom_zlec=spisz.nr_kom_zlec and nr_poz_zlec=spisz.nr_poz
          --And nr_obr=nr_obr_konc)
          And nr_obr in (select first_value(S.nk_obr) over (order by case when S.nk_obr=cNR_OBR_MON then 1 else null end nulls last, S.etap desc, S.zn_plan desc)
                         from spiss S
                         where S.zrodlo='Z' and S.nr_komp_zr=v_wyc1.nr_kom_zlec and S.nr_kol=v_wyc1.nr_poz_zlec and nk_obr>0 and zn_plan>0)
       )
   WHERE nr_kom_zlec=pNK_ZLEC;
  END AKTUALIZUJ_SPISZ;

 PROCEDURE AKTUALIZUJ_ZAMINFO (pNK_ZLEC NUMBER) AS
  BEGIN
   DELETE FROM zaminfo WHERE nr_komp_zlec=pNK_ZLEC AND nr_komp_instal>0;
   INSERT INTO zaminfo (nr_komp_zlec,numer_oddzialu,nr_komp_instal,il_pl_szyb,il_pl_wyc,dane_rzecz,dane_przel,
                        atrb_1_il,atrb_1_p,atrb_2_il,atrb_2_p,atrb_3_il,atrb_3_p,atrb_4_il,atrb_4_p,atrb_5_il,atrb_5_p,
                        atrb_6_il,atrb_6_p,atrb_7_il,atrb_7_p,atrb_8_il,atrb_8_p,atrb_9_il,atrb_9_p,atrb_10_il,atrb_10_p,
                        atrb_11_il,atrb_11_p,atrb_12_il,atrb_12_p,atrb_13_il,atrb_13_p,atrb_14_il,atrb_14_p,atrb_15_il,atrb_15_p,
                        atrb_16_il,atrb_16_p,atrb_17_il,atrb_17_p,atrb_18_il,atrb_18_p,atrb_19_il,atrb_19_p,atrb_20_il,atrb_20_p,
                        atrb_21_il,atrb_21_p,atrb_22_il,atrb_22_p,atrb_23_il,atrb_23_p,atrb_24_il,atrb_24_p,atrb_25_il,atrb_25_p,
                        atrb_26_il,atrb_26_p,atrb_27_il,atrb_27_p,atrb_28_il,atrb_28_p,atrb_29_il,atrb_29_p,atrb_30_il,atrb_30_p,
                        --szer_min,wys_min,szer_max,wys_max,
                        atrybuty_budowy,ind_bud
                        )
    SELECT V.*, Z.atrybuty_budowy, Z.ind_bud
    FROM
    (select nr_kom_zlec, (select nr_odz from firma where rownum=1),
            nr_inst_plan, count(distinct id_szyby), count(distinct id_wyc), sum(il_obr), sum(il_obr*wsp_p),
       sum(decode(substr(ident_bud,1,1),'1',1,0)), sum(decode(substr(ident_bud,1,1),'1',pow_sur,0)) atr1,
       sum(decode(substr(ident_bud,2,1),'1',1,0)), sum(decode(substr(ident_bud,2,1),'1',pow_sur,0)) atr2,
       sum(decode(substr(ident_bud,3,1),'1',1,0)), sum(decode(substr(ident_bud,3,1),'1',pow_sur,0)) atr3,
       sum(decode(substr(ident_bud,4,1),'1',1,0)), sum(decode(substr(ident_bud,4,1),'1',pow_sur,0)) atr4,
       sum(decode(substr(ident_bud,5,1),'1',1,0)), sum(decode(substr(ident_bud,5,1),'1',pow_sur,0)) atr5,
       sum(decode(substr(ident_bud,6,1),'1',1,0)), sum(decode(substr(ident_bud,6,1),'1',pow_sur,0)) atr6,
       sum(decode(substr(ident_bud,7,1),'1',1,0)), sum(decode(substr(ident_bud,7,1),'1',pow_sur,0)) atr7,
       sum(decode(substr(ident_bud,8,1),'1',1,0)), sum(decode(substr(ident_bud,8,1),'1',pow_sur,0)) atr8,
       sum(decode(substr(ident_bud,9,1),'1',1,0)), sum(decode(substr(ident_bud,9,1),'1',pow_sur,0)) atr9,
       sum(decode(substr(ident_bud,10,1),'1',1,0)), sum(decode(substr(ident_bud,10,1),'1',pow_sur,0)) atr10,
       sum(decode(substr(ident_bud,11,1),'1',1,0)), sum(decode(substr(ident_bud,11,1),'1',pow_sur,0)) atr11,
       sum(decode(substr(ident_bud,12,1),'1',1,0)), sum(decode(substr(ident_bud,12,1),'1',pow_sur,0)) atr12,
       sum(decode(substr(ident_bud,13,1),'1',1,0)), sum(decode(substr(ident_bud,13,1),'1',pow_sur,0)) atr13,
       sum(decode(substr(ident_bud,14,1),'1',1,0)), sum(decode(substr(ident_bud,14,1),'1',pow_sur,0)) atr14,
       sum(decode(substr(ident_bud,15,1),'1',1,0)), sum(decode(substr(ident_bud,15,1),'1',pow_sur,0)) atr15,
       sum(decode(substr(ident_bud,16,1),'1',1,0)), sum(decode(substr(ident_bud,16,1),'1',pow_sur,0)) atr16,
       sum(decode(substr(ident_bud,17,1),'1',1,0)), sum(decode(substr(ident_bud,17,1),'1',pow_sur,0)) atr17,
       sum(decode(substr(ident_bud,18,1),'1',1,0)), sum(decode(substr(ident_bud,18,1),'1',pow_sur,0)) atr18,
       sum(decode(substr(ident_bud,19,1),'1',1,0)), sum(decode(substr(ident_bud,19,1),'1',pow_sur,0)) atr19,
       sum(decode(substr(ident_bud,20,1),'1',1,0)), sum(decode(substr(ident_bud,20,1),'1',pow_sur,0)) atr20,
       sum(decode(substr(ident_bud,21,1),'1',1,0)), sum(decode(substr(ident_bud,21,1),'1',pow_sur,0)) atr21,
       sum(decode(substr(ident_bud,22,1),'1',1,0)), sum(decode(substr(ident_bud,22,1),'1',pow_sur,0)) atr22,
       sum(decode(substr(ident_bud,23,1),'1',1,0)), sum(decode(substr(ident_bud,23,1),'1',pow_sur,0)) atr23,
       sum(decode(substr(ident_bud,24,1),'1',1,0)), sum(decode(substr(ident_bud,24,1),'1',pow_sur,0)) atr24,
       sum(decode(substr(ident_bud,25,1),'1',1,0)), sum(decode(substr(ident_bud,25,1),'1',pow_sur,0)) atr25,
       sum(decode(substr(ident_bud,26,1),'1',1,0)), sum(decode(substr(ident_bud,26,1),'1',pow_sur,0)) atr26,
       sum(decode(substr(ident_bud,27,1),'1',1,0)), sum(decode(substr(ident_bud,27,1),'1',pow_sur,0)) atr27,
       sum(decode(substr(ident_bud,28,1),'1',1,0)), sum(decode(substr(ident_bud,28,1),'1',pow_sur,0)) atr28,
       sum(decode(substr(ident_bud,29,1),'1',1,0)), sum(decode(substr(ident_bud,29,1),'1',pow_sur,0)) atr29,
       sum(decode(substr(ident_bud,30,1),'1',1,0)), sum(decode(substr(ident_bud,30,1),'1',pow_sur,0)) atr30
     from v_wyc1
     where nr_kom_zlec=pNK_ZLEC --in (select nr_komp_zlec from paml2 where nr_listy>=1040)
     group by nr_kom_zlec, nr_inst_plan) V
    LEFT JOIN zaminfo Z ON V.nr_kom_zlec=Z.nr_komp_zlec and Z.nr_komp_instal=0;
  EXCEPTION WHEN OTHERS THEN
   ZAPISZ_LOG('AKTUALIZUJ_ZAMINFO',pNK_ZLEC,'E',0);
   ZAPISZ_ERR(SQLERRM||': '||dbms_utility.FORMAT_ERROR_BACKTRACE);
   --RAISE;
  END AKTUALIZUJ_ZAMINFO;

 PROCEDURE AKTUALIZUJ_SURZAM(pNK_ZLEC NUMBER)
 AS
   CURSOR c1 IS
    Select * From surzam Where nr_komp_zlec=pNK_ZLEC
   FOR UPDATE;
   rec1 surzam%ROWTYPE;
  BEGIN
   OPEN c1;
   LOOP
    FETCH c1 INTO rec1;
    EXIT WHEN c1%NOTFOUND;
    --nvl(min() - zabezpieczenie przed 'no data found'
    SELECT nvl(min(PKG_CZAS.NR_ZM_TO_DATE(zm_min)),rec1.data_pl),  nvl(min(PKG_CZAS.NR_ZM_TO_ZM(zm_min)),rec1.zm_pl),
           nvl(min(nr_inst_plan),rec1.nr_komp_inst), nvl(min(wsp_max),rec1.wsp_przel)
      INTO rec1.data_pl, rec1.zm_pl, rec1.nr_komp_inst, rec1.wsp_przel     
    FROM       
     (select min(nr_zm_plan) zm_min, nr_inst_plan, max(wsp_p) wsp_max
      from v_wyc2
      where nr_kom_zlec=rec1.nr_komp_zlec and (rec1.rodz_sur NOT IN ('CZY','KRA') and nr_kat=rec1.nr_kat and kolejn=101 or
                                               rec1.rodz_sur='KRA' and rec1.indeks in (indeks,kod_dod) or
                                               rec1.rodz_sur='CZY' and nr_kat_obr=rec1.nr_kat
                                                                   and (indeks=rec1.indeks or nr_kat=(select max(nr_kat) from kartoteka where nr_mag=rec1.nr_mag and indeks=rec1.indeks and nr_odz=rec1.nr_oddz and nr_kat>0)))
                                               --max(nr_kat) powoduje, ¿e zawsze bedzie 1 rekord - conajwy¿ej NULL
      group by nr_inst_plan
      order by 1
      )
    WHERE rownum=1; 
    --aktualizacja rekordu
    UPDATE surzam SET ROW=rec1 WHERE current of c1;
   END LOOP;
   CLOSE c1;
  EXCEPTION WHEN OTHERS THEN
   IF c1%ISOPEN THEN CLOSE c1; END IF;
   ZAPISZ_LOG('AKTUALIZUJ_SURZAM',pNK_ZLEC,'E',0);
   ZAPISZ_ERR(SQLERRM||': '||dbms_utility.FORMAT_ERROR_BACKTRACE);
   RAISE;
  END AKTUALIZUJ_SURZAM;


 PROCEDURE AKTUALIZUJ_LWYC_OLD (pNK_INST_NEW NUMBER, pPOZ NUMBER)
 AS
  CURSOR c1 IS
   Select distinct L.nr_kom_zlec, L.nr_poz_zlec, L.nr_warst, L.nr_szt, L.nr_inst inst_old, L2.nr_inst_plan inst_new,
       --L1.nr_obr, L1.nr_zm_plan zm_old, L2.nr_zm_plan zm_new,
       case when L3.nr_kom_zlec is null then 0 else 1 end jest_inna_obr_ma_zostac,
       case when L4.nr_kom_zlec is null then 0 else 1 end jest_juz_lwyc_na_docel
       --,L2.nr_porz_obr nr_porz_obr_przeplanowanej, L3.nr_porz_obr inny_nr_porz_na_inst_starej --po odkomentowaniu traci sens distinct
     --L l_wyc stary
   From l_wyc L
   --L1 l_wyc2 stary (backup)
   Left join l_wyc2 L1 On L1.nr_kom_zlec=-gNK_ZLEC and L1.nr_poz_zlec=L.nr_poz_zlec and L1.nr_szt=L.nr_szt and L.nr_warst=L1.nr_warst and L.nr_inst=L1.nr_inst_plan
   --L2 l_wyc2 nowy
   Left join l_wyc2 L2 On L2.nr_kom_zlec=gNK_ZLEC and L2.nr_poz_zlec=L.nr_poz_zlec and L2.nr_szt=L.nr_szt and L2.nr_porz_obr=L1.nr_porz_obr
   --L3 l_wyc2 inny na inst. starej
   Left join l_wyc2 L3 On L3.nr_kom_zlec=gNK_ZLEC and L3.nr_poz_zlec=L.nr_poz_zlec and L3.nr_szt=L.nr_szt and  L3.nr_warst=L.nr_warst and L3.nr_inst_plan=L.nr_inst
   --L4 l_wyc na inst nowej
   Left join l_wyc L4 On L4.nr_kom_zlec=gNK_ZLEC and L2.nr_poz_zlec=L4.nr_poz_zlec and L2.nr_szt=L4.nr_szt and L4.nr_warst=L2.nr_warst and L4.nr_inst=L2.nr_inst_plan
   Where L.nr_kom_zlec=gNK_ZLEC And pPOZ in (0,L.nr_poz_zlec)
     And L1.nr_inst_plan is not null And L2.nr_inst_plan is not null and L1.nr_inst_plan<>L2.nr_inst_plan
     And pNK_INST_NEW in (0,L2.nr_inst_plan) And ELEMENT_LISTY(gLISTA_OBR,L1.nr_obr)=1;
  --rekord do zmiany
  CURSOR c2 (pPOZ NUMBER, pWAR NUMBER, pSZT NUMBER, pINST NUMBER) IS
   SELECT * FROM l_wyc
   WHERE nr_kom_zlec=gNK_ZLEC and nr_poz_zlec=pPOZ and nr_warst=pWAR and nr_szt=pSZT and nr_inst=pINST
   FOR UPDATE;
  rec1 c1%ROWTYPE;
  rec2 c2%ROWTYPE;
  czy_jest_zm_inst NUMBER;
 BEGIN
  SELECT count(1) INTO czy_jest_zm_inst
  FROM l_wyc2 L1
  LEFT JOIN l_wyc2 L2 ON L2.nr_kom_zlec=-L1.nr_kom_zlec and L2.nr_poz_zlec=L1.nr_poz_zlec and L2.nr_szt=L1.nr_szt and L2.nr_porz_obr=L1.nr_porz_obr
  WHERE L1.nr_kom_zlec=gNK_ZLEC And pPOZ in (0,L1.nr_poz_zlec)
     And L1.nr_inst_plan<>L2.nr_inst_plan
     And pNK_INST_NEW in (0,L2.nr_inst_plan) And ELEMENT_LISTY(gLISTA_OBR,L1.nr_obr)=1;
  IF czy_jest_zm_inst=0 THEN
   RETURN;
  END IF;

  OPEN c1;
  LOOP
   FETCH c1 INTO rec1;
   EXIT WHEN c1%NOTFOUND;
   OPEN c2 (rec1.nr_poz_zlec, rec1.nr_warst, rec1.nr_szt, rec1.inst_old);
   FETCH c2 INTO rec2;
   --pozostaje 1 rekord, tylko zmiana instalacji
   IF rec1.jest_inna_obr_ma_zostac=0 and rec1.jest_juz_lwyc_na_docel=0 THEN
    UPDATE l_wyc SET nr_inst=rec1.inst_new WHERE current of c2;
   --potrzeba skopiowac rekord na now¹ instalacji 
   ELSIF rec1.jest_inna_obr_ma_zostac=1 and rec1.jest_juz_lwyc_na_docel=0 THEN
    rec2.nr_inst:=rec1.inst_new;
    IF rec2.zn_braku=1 THEN rec2.zn_braku:=0; END IF;
    INSERT INTO l_wyc VALUES rec2;
   --rekord do usuniêcia (Merge z docelowym?) 
   ELSIF rec1.jest_inna_obr_ma_zostac=0 and rec1.jest_juz_lwyc_na_docel=1 THEN 
    DELETE FROM l_wyc2 WHERE current of c2;
   END IF;
   CLOSE c2;
  END LOOP;
  CLOSE c1;
 EXCEPTION WHEN OTHERS THEN
   IF c1%ISOPEN THEN CLOSE c1; END IF;
   IF c2%ISOPEN THEN CLOSE c2; END IF;
   ZAPISZ_LOG('AKTUALIZUJ_LWYC',gNK_ZLEC,'E',0);
   ZAPISZ_ERR(SQLERRM||': '||dbms_utility.FORMAT_ERROR_BACKTRACE);
   --RAISE;
 END AKTUALIZUJ_LWYC_OLD;

 PROCEDURE AKTUALIZUJ_LWYC (pNK_INST_NEW NUMBER, pPOZ NUMBER)
 AS
  CURSOR c1 IS
   Select L.nr_kom_zlec, L.nr_poz_zlec, L.nr_warst, L.nr_szt, L.nr_inst inst_old, L2.nr_inst_plan inst_new
   From l_wyc L
   Left join l_wyc2 L2 on L2.nr_kom_zlec=L.nr_kom_zlec and L2.nr_poz_zlec=L.nr_poz_zlec and L2.nr_szt=L.nr_szt and ELEMENT_LISTY(L.nry_porz,L2.nr_porz_obr)=1
   Where L.nr_kom_zlec=gNK_ZLEC And pPOZ in (0,L.nr_poz_zlec)
     And L.nr_inst<>L2.nr_inst_plan
     And ELEMENT_LISTY(gLISTA_OBR,L2.nr_obr)=1;
  --rekord do zmiany
  CURSOR c2 (pPOZ NUMBER, pWAR NUMBER, pSZT NUMBER, pINST NUMBER) IS
   SELECT * FROM l_wyc
   WHERE nr_kom_zlec=gNK_ZLEC and nr_poz_zlec=pPOZ and nr_warst=pWAR and nr_szt=pSZT and nr_inst=pINST
   FOR UPDATE;
  rec1 c1%ROWTYPE;
  rec2 c2%ROWTYPE;
  jest_inna_obr_ma_zostac NUMBER(10);
  jest_juz_lwyc_na_docel NUMBER(10);
 BEGIN
--  SELECT count(1) INTO czy_jest_zm_inst
--  FROM l_wyc2 L1
--  LEFT JOIN l_wyc2 L2 ON L2.nr_kom_zlec=-L1.nr_kom_zlec and L2.nr_poz_zlec=L1.nr_poz_zlec and L2.nr_szt=L1.nr_szt and L2.nr_porz_obr=L1.nr_porz_obr
--  WHERE L1.nr_kom_zlec=gNK_ZLEC And pPOZ in (0,L1.nr_poz_zlec)
--     And L1.nr_inst_plan<>L2.nr_inst_plan
--     And pNK_INST_NEW in (0,L2.nr_inst_plan) And ELEMENT_LISTY(gLISTA_OBR,L1.nr_obr)=1;
--  IF czy_jest_zm_inst=0 THEN
--   RETURN;
--  END IF;

  OPEN c1;
  LOOP
   FETCH c1 INTO rec1;
   EXIT WHEN c1%NOTFOUND;
   OPEN c2 (rec1.nr_poz_zlec, rec1.nr_warst, rec1.nr_szt, rec1.inst_old);
   FETCH c2 INTO rec2;
   --szukanie czy jest inna obrobka na dotychczasowej L_WYC.NR_INST
   SELECT count(1) INTO jest_inna_obr_ma_zostac
   FROM l_wyc2
   WHERE nr_kom_zlec=rec2.nr_kom_zlec and nr_poz_zlec=rec2.nr_poz_zlec and nr_szt=rec2.nr_szt and  nr_warst=rec2.nr_warst and nr_inst_plan=rec2.nr_inst;
   --sprawdzenie czy na nowej instalacji nie ma juz rekordu L_WYC
   SELECT count(1) INTO jest_juz_lwyc_na_docel
   FROM l_wyc
   WHERE  nr_kom_zlec=rec2.nr_kom_zlec and  nr_poz_zlec=rec2.nr_poz_zlec and  nr_szt=rec2.nr_szt and  nr_warst=rec2.nr_warst and  nr_inst=rec1.inst_new;
   --pozostaje 1 rekord, tylko zmiana instalacji
   IF jest_inna_obr_ma_zostac=0 and jest_juz_lwyc_na_docel=0 THEN
    UPDATE l_wyc SET nr_inst=rec1.inst_new WHERE current of c2;
   --potrzeba skopiowac rekord na now¹ instalacji 
   ELSIF jest_inna_obr_ma_zostac>0 and jest_juz_lwyc_na_docel=0 THEN
    rec2.nr_inst:=rec1.inst_new;
    IF rec2.zn_braku=1 THEN rec2.zn_braku:=0; END IF;
    INSERT INTO l_wyc VALUES rec2;
   --rekord do usuniêcia (Merge z docelowym?) 
   ELSIF jest_inna_obr_ma_zostac=0 and jest_juz_lwyc_na_docel>0 THEN 
    DELETE FROM l_wyc WHERE current of c2;
   END IF;
   CLOSE c2;
  END LOOP;
  CLOSE c1;
  --aktualizacja NR_INST_NAST, NRY_PORZ, 
  UPDATE l_wyc L
  SET nr_inst_nast=NR_INST_NAST(nr_kom_zlec,nr_poz_zlec,nr_warst,nr_szt,kolejn),
      nry_porz=(select listagg(L2.nr_porz_obr,',') within group (order by L2.kolejn)
                from l_wyc2 L2
                where L2.nr_kom_zlec=L.nr_kom_zlec and L2.nr_poz_zlec=L.nr_poz_zlec and L2.nr_warst=L.nr_warst and L2.nr_szt=L.nr_szt
                  and L2.nr_inst_plan=L.nr_inst)
  WHERE nr_kom_zlec=gNK_ZLEC AND pPOZ in (0,nr_poz_zlec);
 EXCEPTION WHEN OTHERS THEN
   IF c1%ISOPEN THEN CLOSE c1; END IF;
   IF c2%ISOPEN THEN CLOSE c2; END IF;
   ZAPISZ_LOG('AKTUALIZUJ_LWYC',gNK_ZLEC,'E',0);
   ZAPISZ_ERR(SQLERRM||': '||dbms_utility.FORMAT_ERROR_BACKTRACE);
   --RAISE;
 END AKTUALIZUJ_LWYC;


 FUNCTION NR_INST_NAST(pNK_ZLEC NUMBER, pPOZ NUMBER, pWAR NUMBER, pSZT NUMBER, pKOLEJN NUMBER) RETURN NUMBER IS
    vNast number(10);
  begin
   select max(nr_inst_plan) into vNast
   from (select nr_inst_plan
         from l_wyc2
         where nr_kom_zlec=pNK_ZLEC and nr_poz_zlec=pPOZ and nr_szt=pSZT
           and pWAR between nr_warst and war_do and kolejn>pKOLEJN
         order by kolejn)
   where rownum=1;
   return nvl(vNast,0);
  end NR_INST_NAST;

 FUNCTION LICZ_REKORDY(pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0) RETURN NUMBER
 AS
   wyn NUMBER;
  BEGIN
   SELECT count(1) INTO wyn
   FROM l_wyc2 L
   --LEFT JOIN parinst I ON L.nr_inst_plan=I.nr_komp_inst
   WHERE L.nr_kom_zlec=pNK_ZLEC and pPOZ in (0,L.nr_poz_zlec)
     AND ELEMENT_LISTY(gLISTA_OBR,L.nr_obr)=1
   --AND (gZAKR=0 OR gZAKR=1 and L.nr_obr=gNR_OBR OR gZAKR=2 and L.nr_inst_plan=gINST OR gZAKR=3 and (gTYP_INST is null or trim(I.ty_inst)=gTYP_INST or gTYP_INST='A C' and trim(I.ty_inst)='R C'))
   AND L.nr_inst_plan>0
   AND L.nr_porz_obr not between 1501 and 1999; --pomijanie wpisów dla instalacji powi¹zanych, bo one mog¹ byæ dodawane/usuwane przy zmianie instalacji glównej
   RETURN wyn; 
  END;

 FUNCTION INFO_ZAKR RETURN VARCHAR2
 AS
  BEGIN
   RETURN 'NkZ:'||gNK_ZLEC
          ||case when gPOZ>0 then 'Poz:'||gPOZ||' ' else ' ' end
          ||'zakr:'||gZAKR||case gZAKR when 1 then '|'||gNR_OBR when 2 then '|'||gINST when 3 then '|'||gDANE2 else ' ' end
          ||' obr:'||gLISTA_OBR;
  END INFO_ZAKR;


 PROCEDURE ZAPISZ_ZM_ZLEC
 AS
  vObr NUMBER(4);
  vNkZm NUMBER(10);
  vSymbObr VARCHAR2(10);
  vDanePrzed VARCHAR2(128);
  vDanePo    VARCHAR2(128);
  sep CHAR(1) default ';';--chr(13);
  BEGIN
   ZAPISZ_ZLEC_ZM (gNK_ZLEC, 'HA', 'Zmiana Harm.', vNkZm /*pNK_ZM OUT NUMBER*/);
   FOR i IN 1 .. 20
    LOOP   --petla po obrobkach 
     vObr:=STRTOKENN(gLISTA_OBR,i,',');
     EXIT WHEN vObr=0;
     SELECT symb_p_obr INTO vSymbObr FROM slparob WHERE nr_k_p_obr=vObr;
     vDanePrzed:=sep; vDanePo:=sep;
     FOR r in (Select decode(L.etap,1,S.indeks,' ') indeks, L.inst0, L.inst2, L.zm0, L.zm2, sum(il_wyc) il_szt,
                      max(trim(I0.ty_inst)) typ0, max(I0.nr_inst) nr0, max(trim(I2.ty_inst)) typ2, max(I2.nr_inst) nr2
               From
               (select L2.nr_kom_zlec, L2.nr_poz_zlec, L2.nr_warst, L2.nr_inst_plan inst2, L0.nr_inst_plan inst0, L2.nr_zm_plan zm2, L0.nr_zm_plan zm0,
                      count(distinct L2.nr_szt) il_wyc, round(max(L2.kolejn)*0.01) etap, max(L2.nr_porz_obr) nr_porz
                from l_wyc2 L2
                left join l_wyc2 L0 on L0.nr_kom_zlec=-L2.nr_kom_zlec and L0.nr_poz_zlec=L2.nr_poz_zlec and L0.nr_szt=L2.nr_szt and L0.nr_porz_obr=L2.nr_porz_obr
                where L2.nr_kom_zlec=gNK_ZLEC and L2.nr_obr=vObr and not (L2.nr_inst_plan=L0.nr_inst_plan and L2.nr_zm_plan=L0.nr_zm_plan)
                group by L2.nr_kom_zlec, L2.nr_poz_zlec, L2.nr_warst, L2.war_do, L2.nr_inst_plan, L0.nr_inst_plan, L2.nr_zm_plan, L0.nr_zm_plan
               ) L
               Left join spiss S on S.zrodlo='Z' and S.nr_komp_zr=L.nr_kom_zlec and S.nr_kol=L.nr_poz_zlec and S.war_od=L.nr_warst and S.nr_porz=L.nr_porz--S.etap=L.etap and S.czy_war=1 and S.strona=0
               Left join parinst I0 on I0.nr_komp_inst=L.inst0
               Left join parinst I2 on I2.nr_komp_inst=L.inst2
               Group by decode(L.etap,1,S.indeks,' '), L.inst0, L.inst2, L.zm0, L.zm2)
      LOOP
       vDanePrzed:=vDanePrzed || r.indeks||':'||to_char(r.il_szt)||'szt:'||r.typ0||r.nr0||':'||to_char(PKG_CZAS.NR_ZM_TO_DATE(r.zm0),'DD/MM')||'z'||PKG_CZAS.NR_ZM_TO_ZM(r.zm0)||chr(13)||sep;
       vDanePo   :=vDanePo    || r.indeks||':'||to_char(r.il_szt)||'szt:'||r.typ2||r.nr2||':'||to_char(PKG_CZAS.NR_ZM_TO_DATE(r.zm2),'DD/MM')||'z'||PKG_CZAS.NR_ZM_TO_ZM(r.zm2)||chr(13)||sep;
      END LOOP;
     vDanePrzed := substr(nvl(trim(both sep from vDanePrzed),' '),1,128);
     vDanePo    := substr(nvl(trim(both sep from vDanePo   ),' '),1,128);
     IF length(vDanePrzed)>1 THEN 
      NULL; --@V ZAPISZ_ZLEC_ZMP(vNkZm, 'H', 0, vObr, vSymbObr, 0, vDanePrzed, 0, vDanePo);
     END IF;
    END LOOP;
   EXCEPTION WHEN OTHERS THEN
    ZAPISZ_LOG('ZAPISZ_ZM_ZLEC',gNK_ZLEC,'E',0);
    ZAPISZ_ERR(SQLERRM||': '||dbms_utility.FORMAT_ERROR_BACKTRACE);  
  END ZAPISZ_ZM_ZLEC;

  -- docelowo ma pobrac dane z matrycy czasów poprocesowych
  FUNCTION CZAS_POPROC(pINST1 NUMBER, pINST2 NUMBER) RETURN NUMBER
   AS
    vGodz NUMBER(10);
    vDlZm  NUMBER(10);
    vIleZm NUMBER(4);
   BEGIN
    SELECT czas_poprocesowy, dlugosc_zmiany INTO vGodz, vDlZm
    FROM parinst WHERE nr_komp_inst=pINST1;
    RETURN vGodz;
   END CZAS_POPROC;

  PROCEDURE WYPELNIJ_ZMIANY(pNK_ZLEC NUMBER, pZM_OD NUMBER, pZM_DO NUMBER, pALL_INST NUMBER DEFAULT 0) AS
   BEGIN
    DELETE tmp_zmiany2;
    INSERT INTO tmp_zmiany2 (nr_komp_inst, nr_komp_zm, dl_zmiany, zatwierdz,
                            szt, szt_zl0, szt_zl1, szt_zl_max,
                            wielk, wielk_zl0, wielk_zl1, wielk_zl_max,
                            wyd_nom, wyd_max)
     select nr_komp_inst, nr_komp_zm, max(dl_zmiany), max(Z.zatwierdz),
            nvl(sum(H.ilosc),0) szt, nvl(sum(decode(H.nr_komp_zlec,pNK_ZLEC,H.ilosc,0)),0) szt_zl0, 0 szt_zl1,
            (select count(1) from v_wyc2 where nr_kom_zlec=pNK_ZLEC and nr_inst_plan=nr_komp_inst) szt_zl_max,
            nvl(sum(H.wielkosc),0) wielk, nvl(sum(decode(H.nr_komp_zlec,pNK_ZLEC,H.wielkosc,0)),0) wielk_ZL0, 0 wielk_ZL1,
            (select nvl(sum(il_obr*wsp_p),0) from v_wyc2 where nr_kom_zlec=pNK_ZLEC and nr_inst_plan=nr_komp_inst) wielk_zl_max,
           max(Z.dl_zmiany*nvl(nullif(wyd_nom,0),999999)) wyd_nom, max(Z.dl_zmiany*nvl(nullif(wyd_max,0),999999)) wyd_max  --999999 je¿eli wydajnosæ nieustawiona(=0) tzn.¿e nie ma ograniczenia
     from zmiany Z
     left join harmon H using (nr_komp_inst, nr_komp_zm)
     left join parinst I using (nr_komp_inst)
     where I.czy_czynna='TAK'
       and nr_komp_zm between pZM_OD and pZM_DO
       and Z.zatwierdz=0 and Z.dl_zmiany>0
       --and nr_komp_inst in (select distinct nr_inst_plan from l_wyc2 where nr_kom_zlec=pNK_ZLEC)
       and not (pALL_INST=0 and not nr_komp_inst in (select distinct nr_inst_plan from l_wyc2 where nr_kom_zlec=pNK_ZLEC))
       and not (pALL_INST=1 and not nr_komp_inst in (select nr_komp_inst from gr_inst_dla_obr where nr_komp_obr in (select distinct nr_obr from l_wyc2 where nr_kom_zlec=pNK_ZLEC)))
       and nvl(H.typ_harm,'P')='P'
     group by nr_komp_inst, nr_komp_zm;
   END WYPELNIJ_ZMIANY;
/*
  FUNCTION ILE_WOLNE(pINST NUMBER, pNR_ZM NUMBER, pMAX NUMBER default 0) RETURN NUMBER
   AS
    vRET NUMBER(10,2);
   BEGIN
    SELECT nvl(max(decode(pMAX,1,wyd_max,wyd_nom)-wielk+wielk_zl0-wielk_zl1),0) INTO vRET
    FROM tmp_zmiany
    WHERE nr_komp_inst=pINST AND nr_komp_zm=pNR_ZM;
    RETURN vRET;
   END ILE_WOLNE;
*/
  FUNCTION CZY_WEJDZIE(pINST NUMBER, pNR_ZM NUMBER, pILE_PRZEL NUMBER, pILE_SZT NUMBER DEFAULT 0) RETURN boolean
   AS
    vWolneNom NUMBER(10,2);
    vWolneMax NUMBER(10,2);
    vZlecPlan NUMBER(10,2);   --ile zlecenia ju¿ wpisane
    vZlecMax  NUMBER(10,2);   --ile maks. zlecenia na inst.
    vRet boolean DEFAULT true;
   BEGIN
    IF pILE_PRZEL>0 THEN
     --wielk_zl0 -ilosc zlecenia wczesniej zaplanowana na zmianê
     --wielk_zl1 -ilosc zlecenia zaplanowana na zmianê w bie¿¹cej sesji planowania
     --wielk_zl_max -calkowita ilosc zlecenia na instalacji
     SELECT nvl(max(wyd_nom-wielk+wielk_zl0-wielk_zl1),0),
            nvl(max(wyd_max-wielk+wielk_zl0),0),
            nvl(max(wielk_zl1),0),  
            nvl(max(wielk_zl_max),0)
       INTO vWolneNom, vWolneMax, vZlecPlan, vZlecMax
     FROM tmp_zmiany
     WHERE nr_komp_inst=pINST AND nr_komp_zm=pNR_ZM;
     vRet:=vWolneNom>0/*pILE*/ or vZlecPlan>0 and vWolneMax>=vZlecMax;-- and vWolneNom-vZlecPlan>gMIN_ZL; --próba ograniczenia dzielenia - wygeneruje problem przy czêœciach>pMIN_ZL
    END IF;
    --analogicznie dla szt
    IF pILE_SZT>0 THEN
     SELECT nvl(max(wyd_nom-szt+szt_zl0-szt_zl1),0),
            nvl(max(wyd_max-szt+szt_zl0),0),
            nvl(max(szt_zl1),0),  
            nvl(max(szt_zl_max),0)
       INTO vWolneNom, vWolneMax, vZlecPlan, vZlecMax
     FROM tmp_zmiany2
     WHERE nr_komp_inst=pINST AND nr_komp_zm=pNR_ZM;
     vRet:=vWolneNom>0 or vZlecPlan>0 and vWolneMax>=vZlecMax;
    END IF;
    RETURN vRet;
   END CZY_WEJDZIE; 

  FUNCTION SZUKAJ_ZMIANY(pINST NUMBER, pZM_OD NUMBER, pZM_DO NUMBER, /*pILE_GODZ NUMBER DEFAULT 0*/ pILE NUMBER, pKIERUNEK NUMBER DEFAULT 0) RETURN NUMBER --pKIERUNEK=0 szukaj wstecz   1-wprzód
   AS
    CURSOR c1 IS
      SELECT nr_komp_inst, nr_komp_zm, zmiana, zmiany.dl_zmiany, trim(parinst.jedn) jedn
      FROM zmiany JOIN parinst USING (nr_komp_inst)
      WHERE nr_komp_inst=pINST AND nr_komp_zm between pZM_OD and pZM_DO -- - sign(pILE_GODZ)
        AND zmiany.zatwierdz=0 AND zmiany.dl_zmiany>0
      ORDER BY case when pKIERUNEK=1 then nr_komp_zm else 0 end, nr_komp_zm desc;
    rec c1%ROWTYPE;
    sumaGodz NUMBER(6):=0;
    ileZmian NUMBER(2);
    ileWolne NUMBER(10,2);
   BEGIN
     --
     OPEN c1;
     LOOP
      FETCH c1 INTO rec;
      EXIT WHEN c1%NOTFOUND;
      --nie mo¿na liczyæ czasu poprocesowego w odniesieniu do dlugoœci aktywnych zmian
      --sumaGodz:=sumaGodz+rec.dl_zmiany;
      --EXIT WHEN sumaGodz>=pILE_GODZ;
      --ileWolne:=ILE_WOLNE(rec.nr_komp_inst, rec.nr_komp_zm,0)
--      EXIT;
      EXIT WHEN CZY_WEJDZIE(rec.nr_komp_inst, rec.nr_komp_zm, case when rec.jedn='sz' then 0 else pILE end, case when rec.jedn='sz' then 1 else 0 end);
     END LOOP;
     CLOSE c1;
     RETURN nvl(rec.nr_komp_zm,gZM_BUFOR);
   END SZUKAJ_ZMIANY;
   
  FUNCTION SZUKAJ_ZMIANY_I_INST(pNK_ZLEC NUMBER, pNR_POZ NUMBER, pNR_WAR NUMBER, pNR_OBR NUMBER, pINST_AKT NUMBER, pZM_OD NUMBER, pZM_DO NUMBER, pKIERUNEK NUMBER DEFAULT 0) RETURN NUMBER --pKIERUNEK=0 szukaj wstecz   1-wprzód
   AS
    CURSOR c1 IS  --ulozenie instalacji w kiolejnosci w jakiej maja byc planowane
      SELECT I.naz_inst, trim(I.jedn) jedn, V.nk_inst nr_komp_inst, V.nr_poz, V.nr_porz, G.nr_komp_gr, G.kolej, V1.inst_std,
             V.kolejnosc_z_grupy, V.gr_akt,
             nvl2(V1.inst_std,G.kolej,V.kolejnosc_z_grupy*100) kol_wynikowa,
             --najpierw wpisy w kolejnosci z pasujacego ciagu instalacji, pozostale w kolenosci z grupy inst. dla obrobki
             --ktore wystapienie instalacji (wazny tylko ktory_wpis_dla_inst=1), moze byc w kilku ciagach, wa¿ny ten o najni¿szym numerze
             rank() OVER (PARTITION BY V.nk_inst ORDER BY decode(pINST_AKT,V.nk_inst,1,null), V1.inst_std,nvl2(V1.inst_std,G.kolej,V.kolejnosc_z_grupy),G.nr_komp_gr) ktory_wpis_dla_inst
      FROM v_spiss V
      INNER JOIN parinst I ON I.nr_komp_inst=V.nk_inst
      --sprawdzenei czy dana instalacja jest w grupie..
      LEFT JOIN gr_inst_pow G ON V.nk_inst=G.nr_komp_inst
      --..ktorej instalacja wiodaca..
      LEFT JOIN gr_inst_pow G0 ON G0.nr_komp_gr=G.nr_komp_gr and G0.nr_komp_inst>0 and not G0.nr_komp_inst=G.nr_komp_inst and G0.flag=1 --inst. wiodaca
      --..jest instalacja standardowa dla ktorejkolwie operacji w beizacej pozycji i warstwie
      LEFT JOIN v_spiss V1 ON V1.nr_kom_zlec=V.nr_kom_zlec and V1.nr_poz=V.nr_poz and V1.inst_std=G0.nr_komp_inst and
                              (V1.war_od between V.war_od and V.war_do or V.war_od between V1.war_od and V1.war_do)
      WHERE V.nr_kom_zlec=pNK_ZLEC and V.nr_poz=pNR_POZ and V.war_od=pNR_WAR
        AND not (V.nk_inst<>pINST_AKT and V.kryt_suma>0)
        AND V.nk_obr=pNR_OBR
      ORDER BY decode(pINST_AKT,V.nk_inst,1,null), kol_wynikowa; --najpierwP pINST_AKT
      
--    CURSOR cOLD IS
--      SELECT nr_komp_inst, nr_komp_zm, zmiana, zmiany.dl_zmiany, parinst.jedn
--      FROM zmiany JOIN parinst USING (nr_komp_inst)
--      WHERE nr_komp_inst=pINST AND nr_komp_zm between pZM_OD and pZM_DO -- - sign(pILE_GODZ)
--        AND zmiany.zatwierdz=0 AND zmiany.dl_zmiany>0
--      ORDER BY case when pKIERUNEK=1 then nr_komp_zm else 0 end, nr_komp_zm desc;
    inst c1%ROWTYPE;
    vWolneNom NUMBER(10,2);
    vWolneMax NUMBER(10,2);
    --vZlecPlan NUMBER(10,2);     --ile zlecenia ju¿ wpisane
    --vZlecPlanSzt NUMBER(10,2);  --ile sztuk zlecenia ju¿ wpisane
    vZlecMax  NUMBER(10,2);     --ile maks. zlecenia na inst.
    vZlecMaxSzt  NUMBER(10,2);  --ile maks. sztuk zlecenia na inst.
    nrZmTmp NUMBER(10) :=0;
    nrZmNaCalosc NUMBER(10) :=0;
    nrZmNaInnej NUMBER(10) :=0;
   BEGIN
     --resetowanie zmiennych do których zapisza sie znalezione instalacja i zmiana
     tabOBRi(pNR_OBR):=0;
     tabOBRz(pNR_OBR):=0;
     
     OPEN c1;
     LOOP
      FETCH c1 INTO inst;
      EXIT WHEN c1%NOTFOUND;
      --pobranie danych o zleceniu z inst. domyslnej (pINST)
      IF inst.nr_komp_inst=pINST_AKT THEN 
       SELECT --nvl(max(wielk_zl1),0),    --ilosc juz wpisana na instalacje
              --nvl(max(szt_zl1),0),
              nvl(max(wielk_zl_max),0), --max. ilosc przypisana do instalacji
              nvl(max(szt_zl_max),0),
              nvl(decode(pKIERUNEK,1,min(nr_komp_zm),max(nr_komp_zm)),0),
              --to samo, ale z uwzglednieniem tylko zmian, ktore pomieszcza calosc zlecenia
              nvl(decode(pKIERUNEK,1,
                  min(case when wyd_max+decode(inst.jedn,'sz',szt_zl0-szt-szt_zl_max,wielk_zl0-wielk-wielk_zl_max)>=0 then nr_komp_zm else null end),
                  max(case when wyd_max+decode(inst.jedn,'sz',szt_zl0-szt-szt_zl_max,wielk_zl0-wielk-wielk_zl_max)>=0 then nr_komp_zm else null end))
               ,0)
         INTO vZlecMax, vZlecMaxSzt, nrZmTmp, nrZmNaCalosc
       FROM tmp_zmiany2
       WHERE nr_komp_inst=pINST_AKT
         AND nr_komp_zm between pZM_OD and pZM_DO
         AND zatwierdz=0 and dl_zmiany>0
         AND (decode(inst.jedn,'sz',wyd_nom+szt_zl0-szt-szt_zl1,wyd_nom+wielk_zl0-wielk-wielk_zl1)>0 OR
              decode(inst.jedn,'sz',wyd_max+szt_zl0-szt-szt_zl_max,wyd_max+wielk_zl0-wielk-wielk_zl_max)>0);
       tabOBRz(pNR_OBR):=nrZmTmp;  --pierwsza wolna zmiana na inst. domyslnej
       IF nrZmTmp=nrZmNaCalosc THEN --zapisanie instalacji, jesli wejdzie tam calosc obrobki w zleceniu
        tabOBRi(pNR_OBR):=pINST_AKT;
       END IF;
      --wyszukanie 1. wolnej zmiany na cale zlecenie na innej inst (jesli 1. raz w c1)
      --GR_AKT=0 czyli instalacja znacozna jako Aktywna w Grupie inst. dla obróbki
      ELSIF inst.ktory_wpis_dla_inst=1 AND inst.gr_akt=0 THEN
       SELECT --nvl(decode(inst.jedn,'sz',max(wyd_nom-szt+szt_zl0-szt_zl1),max(wyd_nom-wielk+wielk_zl0-wielk_zl1)),0),
              --nvl(decode(inst.jedn,'sz',max(wyd_max-szt+szt_zl0),max(wyd_max-wielk+wielk_zl0)),0),
              nvl(decode(pKIERUNEK,1,min(nr_komp_zm),max(nr_komp_zm)),nrZmTmp) 
         INTO nrZmNaInnej
       FROM tmp_zmiany2
       WHERE nr_komp_inst=inst.nr_komp_inst
         AND nr_komp_zm between pZM_OD and pZM_DO
         AND zatwierdz=0 and dl_zmiany>0
         --wolne nominalnie
         AND decode(inst.jedn,'sz',wyd_nom+szt_zl0-szt,wyd_nom+wielk_zl0-wielk)>0
         --zmiesci sie calosc przewidziana na ta (wielk_zl_max) i domyslna (vZlecMax) instalacje
         AND decode(inst.jedn,'sz',wyd_max+szt_zl0-szt-szt_zl_max-vZlecMaxSzt,wyd_max+wielk_zl0-wielk-wielk_zl_max-vZlecMax)>0;
       --zapamietanie wynikow
       IF nrZmTmp=0 and nrZmNaInnej>0 OR pKIERUNEK=1 and nrZmNaInnej<nrZmTmp OR pKIERUNEK=0 and nrZmNaInnej>nrZmTmp THEN 
        nrZmTmp:=nrZmNaInnej;
        tabOBRi(pNR_OBR):=inst.nr_komp_inst;
        tabOBRz(pNR_OBR):=nrZmTmp;
       END IF; 
      END IF;
      --wyjscie jesli zmiana graniczna przeszukiwanego zakresu zmian
      EXIT WHEN pKIERUNEK=1 AND nrZmTmp=pZM_OD OR pKIERUNEK=0 AND nrZmTmp=pZM_DO;
     END LOOP;
     CLOSE c1;
     IF nrZmTmp=0 THEN NrZmTmp:=gZM_BUFOR; END IF;
     RETURN nrZmTmp;
   END SZUKAJ_ZMIANY_I_INST;

  --wersja przeniesiona z @P
  PROCEDURE PLANUJ_SZYBY1 (pNK_ZLEC NUMBER, pNR_ZM_LAST NUMBER default 0)
   AS
   cursor c1 IS
    SELECT V.nr_poz_zlec, V.nr_szt, V.nr_warst, V.nr_warst_do, V.kolejn, V.nr_obr, V.il_obr*V.wsp_p il_przel, V.nry_porz, V.nr_inst_plan,
           V.ident_bud 
    FROM v_wyc1 V
    WHERE V.nr_kom_zlec=pNK_ZLEC
    ORDER BY sort desc, nr_szt desc, kolejn desc, nr_warst desc;
    rec1 c1%ROWTYPE;
    NrZm NUMBER(10);
    NrZmNast NUMBER(10);
    NrZmSPED NUMBER(10);
    Zm NUMBER(1);
    recInst parinst%ROWTYPE;
    czasPopr NUMBER(5);
    lastOper NUMBER(1);
   BEGIN     
    SELECT PKG_CZAS.NR_KOMP_ZM(d_pl_sped,greatest(1,poz_cen)) INTO NrZmSPED FROM zamow WHERE nr_kom_zlec=pNK_ZLEC;
    WYPELNIJ_ZMIANY(pNK_ZLEC, gZM_START, NrZmSPED);
    UPDATE l_wyc2 SET nr_zm_plan=0 WHERE nr_kom_zlec=pNK_ZLEC;
    OPEN c1;
    LOOP
     FETCH c1 INTO rec1;
     EXIT WHEN c1%NOTFOUND;
     lastOper:=0;
     --szukanie planu pozniej
     SELECT nvl(min(nr_zm_plan),0) INTO NrZmNast
     FROM l_wyc2
     WHERE nr_kom_zlec=pNK_ZLEC and nr_poz_zlec=rec1.nr_poz_zlec and nr_szt=rec1.nr_szt and rec1.nr_warst between nr_warst and war_do
       AND kolejn>rec1.kolejn and nr_inst_plan<>rec1.nr_inst_plan and nr_zm_plan>0;
     --je¿eli nie ma planu pozniej
     IF  NrZmNast=0 THEN
      lastOper:=1;
      NrZmNast:=NrZmSPED;
     END IF;
     Zm:=PKG_CZAS.NR_ZM_TO_ZM(NrZmNast); --numer zmiany (1,2,3,4)
     recInst:=PKG_MAIN.REC_PARINST(rec1.nr_inst_plan);
     IF not recInst.czy_czynna='TAK' or ATRYB_MATCH(rec1.ident_bud,recInst.ident_bud_wyl)>0 and recInst.nr_inst_wyl=0 THEN CONTINUE; END IF;
     IF lastOper=1 and pNR_ZM_LAST>0 THEN
      NrZm:=pNR_ZM_LAST;
     ELSE 
      czasPopr:=recInst.czas_poprocesowy;--CZAS_POPROC(rec1.nr_inst_plan,0);
      NrZm:=NrZmNast-floor(czasPopr/24)*4-round(mod(czasPopr,24)/8); --zalo¿enie, ¿e 3 zmiany na dobê (3x8h)
      IF Zm<=round(mod(czasPopr,24)/8) THEN NrZm:=NrZm-1; END IF; --bo zmiana 4 nie istnieje i trzeba pomijaæ w liczeniu czasu
     END IF; 
     NrZm:=SZUKAJ_ZMIANY(rec1.nr_inst_plan, gZM_START, NrZm, rec1.il_przel);
          --SZUKAJ_ZMIANY(rec1.nr_inst_plan, gZM_START, NrZmNast-floor(czasPopr/24)*4-ceil(mod(czasPopr,24)/8));
          --SZUKAJ_ZMIANY(rec1.nr_inst_plan, gZM_START, NrZmNast, czasPopr);
     IF NrZM=0 THEN NrZM:=gZM_BUFOR; END IF;
     UPDATE l_wyc2
     SET nr_zm_plan=NrZm
     WHERE nr_kom_zlec=pNK_ZLEC and nr_poz_zlec=rec1.nr_poz_zlec and nr_szt=rec1.nr_szt and ELEMENT_LISTY(rec1.nry_porz,nr_porz_obr)=1;
     update tmp_zmiany2
     set szt_zl1=szt_zl1+1, wielk_zl1=wielk_zl1+rec1.il_przel
     where nr_komp_inst=rec1.nr_inst_plan and nr_komp_zm=NrZm;
    END LOOP;
    CLOSE c1;
   EXCEPTION WHEN OTHERS THEN
    ZAPISZ_LOG('PLANUJ_SZYBY1',pNK_ZLEC,'E',0);
    ZAPISZ_ERR(SQLERRM||': '||dbms_utility.FORMAT_ERROR_BACKTRACE);  
   END PLANUJ_SZYBY1; 

  --wersja zabezpiecznie dzielenia warstw z tej samej sztuki na ró¿ne zmiany na inst. ³¹czeniowych
 PROCEDURE PLANUJ_SZYBY2 (pNK_ZLEC NUMBER, pNR_ZM_LAST NUMBER default 0)
   AS
   cursor c1 IS
    SELECT V.nr_poz_zlec, V.nr_szt, V.nr_warst, V.nr_warst_do, V.kolejn, V.nr_obr, V.il_obr*V.wsp_p il_przel, V.nry_porz, V.nr_inst_plan,
           obr_lacz, indeks, V.ident_bud
    FROM v_wyc1 V
    WHERE V.nr_kom_zlec=pNK_ZLEC --and V.inst_pow=0 --and V.nr_inst_plan<>49
    --ORDER BY sort desc, nr_szt desc, kolejn desc, nr_warst desc;
    ORDER BY sort desc, nr_szt desc, zn_plan desc /*, case when obr_lacz in (3,4) then null else indeks end desc, nr_szt desc,*/ , case when obr_lacz in (3,4) then nr_warst else kolejn end desc, nr_warst desc;
    rec1 c1%ROWTYPE;
    NrZm NUMBER(10);
    NrZmNast NUMBER(10);
    NrZmSPED NUMBER(10);
    NrZmZak NUMBER(10);
    Zm NUMBER(1);
    recInst parinst%ROWTYPE;
    czasPopr NUMBER(5);
    lastOper NUMBER(1);
   BEGIN
    IF pNR_ZM_LAST>0 THEN 
      NrZmZak:=pNR_ZM_LAST;
    ELSE  
     SELECT PKG_CZAS.NR_KOMP_ZM(d_pl_sped,greatest(1,poz_cen)) INTO NrZmSPED FROM zamow WHERE nr_kom_zlec=pNK_ZLEC;
     NrZmZak:=NrZmSPED;
    END IF; 
    WYPELNIJ_ZMIANY(pNK_ZLEC, gZM_START, NrZmZak);
    UPDATE l_wyc2 SET nr_zm_plan=0 WHERE nr_kom_zlec=pNK_ZLEC;
    OPEN c1;
    LOOP
     FETCH c1 INTO rec1;
     ExIT WHEN c1%NOTFOUND;
     lastOper:=0;
     --szukanie planu pozniej
     SELECT nvl(min(nr_zm_plan),0) INTO NrZmNast
     FROM l_wyc2
     WHERE nr_kom_zlec=pNK_ZLEC and nr_poz_zlec=rec1.nr_poz_zlec and nr_szt=rec1.nr_szt and rec1.nr_warst between nr_warst and war_do
       AND kolejn>rec1.kolejn and nr_inst_plan<>rec1.nr_inst_plan and nr_zm_plan>0;
     --je¿eli nie ma planu pozniej
     IF  NrZmNast=0 THEN
      lastOper:=1;
      NrZmNast:=NrZmZak;
     END IF;
     Zm:=PKG_CZAS.NR_ZM_TO_ZM(NrZmNast); --numer zmiany (1,2,3,4)
     recInst:=PKG_MAIN.REC_PARINST(rec1.nr_inst_plan);
     IF not recInst.czy_czynna='TAK' or ATRYB_MATCH(rec1.ident_bud,recInst.ident_bud_wyl)>0 and recInst.nr_inst_wyl=0 THEN CONTINUE; END IF;
     czasPopr:=recInst.czas_poprocesowy;--CZAS_POPROC(rec1.nr_inst_plan,0);
     IF lastOper=1 and pNR_ZM_LAST>0 THEN
      NrZm:=pNR_ZM_LAST;
     ELSE 
      NrZm:=NrZmNast-floor(czasPopr/24)*4-round(mod(czasPopr,24)/8); --zalo¿enie, ¿e 3 zmiany na dobê (3x8h)
      IF Zm<=round(mod(czasPopr,24)/8) THEN NrZm:=NrZm-1; END IF; --bo zmiana 4 nie istnieje i trzeba pomijaæ w liczeniu czasu
     END IF; 
     NrZm:=SZUKAJ_ZMIANY(rec1.nr_inst_plan, gZM_START, NrZm, rec1.il_przel);
     IF NrZM=0 THEN NrZM:=gZM_BUFOR; END IF;
     UPDATE l_wyc2
     SET nr_zm_plan=NrZm
     WHERE nr_kom_zlec=pNK_ZLEC and nr_poz_zlec=rec1.nr_poz_zlec and nr_szt=rec1.nr_szt
       --AND (ELEMENT_LISTY(rec1.nry_porz,nr_porz_obr)=1 or ELEMENT_LISTY(rec1.nry_porz,nr_porz_obr-1500)=1); --taki sam plan inst powi¹zanej INST_POW 
       AND ELEMENT_LISTY(rec1.nry_porz,nr_porz_obr)=1;
     update tmp_zmiany2
     set szt_zl1=szt_zl1+1, wielk_zl1=wielk_zl1+rec1.il_przel
     where nr_komp_inst=rec1.nr_inst_plan and nr_komp_zm=NrZm;
     --nowe 01/2018 - zabezpieczenie przez dzieleniem warstw na zmiany na inst. kompletacji, niedokladnosc w TMP_ZMIANY
     IF rec1.obr_lacz in (3,4) THEN 
      UPDATE l_wyc2
      SET nr_zm_plan=NrZm
      WHERE nr_kom_zlec=pNK_ZLEC and nr_poz_zlec=rec1.nr_poz_zlec and nr_szt=rec1.nr_szt and nr_inst_plan=rec1.nr_inst_plan and nr_obr=rec1.nr_obr --potrzeba zawezic do tego samego laminatu
        AND nr_zm_plan>0;
     END IF;   
    END LOOP;
    CLOSE c1;
   EXCEPTION WHEN OTHERS THEN
    ZAPISZ_LOG('PLANUJ_SZYBY2',pNK_ZLEC,'E',0);
    ZAPISZ_ERR(SQLERRM||': '||dbms_utility.FORMAT_ERROR_BACKTRACE);  
   END PLANUJ_SZYBY2;

   --planowanie wprzód
  PROCEDURE PLANUJ_SZYBY3 (pNK_ZLEC NUMBER, pNR_ZM_START NUMBER default 0)
   AS
   cursor c1 IS
    SELECT V.nr_poz_zlec, V.nr_szt, V.nr_warst, V.nr_warst_do, V.kolejn, V.nr_obr, V.il_obr*V.wsp_p il_przel, V.nry_porz, V.nr_inst_plan,
           obr_lacz, indeks, V.ident_bud
    FROM v_wyc1 V
    WHERE V.nr_kom_zlec=pNK_ZLEC
    --ORDER BY sort desc, nr_szt desc, kolejn desc, nr_warst desc;
    ORDER BY sort, etap, zn_plan, case when obr_lacz in (3,4) then null else indeks end, nr_szt, case when obr_lacz in (3,4) then nr_warst else kolejn end, nr_warst;
    rec1 c1%ROWTYPE;
    NrZmFirst NUMBER(10):=pNR_ZM_START;
    NrZmLast NUMBER(10);
    NrZm NUMBER(10);
    NrZmPoprz NUMBER(10);
    NrInstPoprz NUMBER(10);
    NrZmSPED NUMBER(10);
    recInst parinst%ROWTYPE;
    czasPopr NUMBER(5);
    czasPoprIleZm8h NUMBER(2);
    firstOper NUMBER(1);
   BEGIN
    SELECT PKG_CZAS.NR_KOMP_ZM(d_pl_sped,greatest(1,poz_cen)) INTO NrZmSPED FROM zamow WHERE nr_kom_zlec=pNK_ZLEC;
    IF pNR_ZM_START=0 THEN 
     NrZmFirst:=PKG_CZAS.NR_KOMP_ZM(trunc(sysdate),1);
    END IF; 
    NrZmLast:=NrZmFirst+31*4-1;
    WYPELNIJ_ZMIANY(pNK_ZLEC, NrZmFirst, NrZmLast);
    UPDATE l_wyc2 SET nr_zm_plan=0 WHERE nr_kom_zlec=pNK_ZLEC;
    OPEN c1;
    LOOP
     FETCH c1 INTO rec1;
     EXIT WHEN c1%NOTFOUND;
     recInst:=PKG_MAIN.REC_PARINST(rec1.nr_inst_plan);
     IF not recInst.czy_czynna='TAK' or ATRYB_MATCH(rec1.ident_bud,recInst.ident_bud_wyl)>0 and recInst.nr_inst_wyl=0 THEN CONTINUE; END IF;

     firstOper:=0;
     czasPopr:=0;
     --szukanie planu wczesniej
     /*SELECT nvl(max(nr_zm_plan),0), nvl(max(inst_poprz),0)-- INTO NrZmPoprz
       INTO NrZmPoprz, NrInstPoprz
     FROM (Select nr_zm_plan, last_value(nr_inst_plan) over (order by kolejn) inst_poprz
           From l_wyc2
           Where nr_kom_zlec=pNK_ZLEC And nr_poz_zlec=rec1.nr_poz_zlec And nr_szt=rec1.nr_szt And nr_warst between rec1.nr_warst and rec1.nr_warst_do
             And kolejn<rec1.kolejn And nr_inst_plan<>rec1.nr_inst_plan And nr_zm_plan>0);*/
     SELECT nvl(max(nr_zm_plan),0), nvl(max(nr_zm_plan+floor(czas_popr/24)*4+round(mod(czas_popr,24)/8)),0) nr_zm_nast
     INTO NrZmPoprz, NrZm
     FROM
     (Select nr_zm_plan, RANK() OVER (PARTITION BY nr_warst ORDER BY kolejn desc) od_konc,
             PKG_PLAN_SPISS.CZAS_POPROC(nr_inst_plan,rec1.nr_inst_plan) czas_popr
      From l_wyc2
      Where nr_kom_zlec=pNK_ZLEC And nr_poz_zlec=rec1.nr_poz_zlec And nr_szt=rec1.nr_szt And nr_warst between rec1.nr_warst and rec1.nr_warst_do
      And kolejn<rec1.kolejn And nr_inst_plan<>rec1.nr_inst_plan And nr_zm_plan>0)
     WHERE od_konc=1;
     --je¿eli nie ma planu wczesniej
     IF  NrZmPoprz=0 THEN
      firstOper:=1;
      --NrZmPoprz:=NrZmFirst;
      NrZm:=NrZmFirst;
      czasPopr:=0;
      czasPoprIleZm8h:=0;
     ELSE
      --czasPopr:=CZAS_POPROC(NrInstPoprz,rec1.nr_inst_plan); --recInst.czas_poprocesowy;
      --czasPoprIleZm8h:=floor(czasPopr/24)*4+round(mod(czasPopr,24)/8); --gdy 3 zmiany na dobê (3x8h)
      NULL;
     END IF;
     --NrZm:=NrZmPoprz;
     IF czasPopr>0 THEN
      NrZm:=NrZmPoprz+czasPoprIleZm8h; 
      IF PKG_CZAS.NR_ZM_TO_ZM(NrZm)<PKG_CZAS.NR_ZM_TO_ZM(NrZmPoprz) THEN NrZm:=NrZm+1; END IF; --dodanie 1 bo zmiana 4 nie istnieje
     END IF; 
     IF vWDR=5 THEN
      IF true or nvl(tabOBRi(rec1.nr_obr),0)=0 THEN
       --CZY_MOZNA_PRZENIESC (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pINST NUMBER, pZM NUMBER, pINST_Z NUMBER, pINST_NA NUMBER) RETURN NUMBER
       --SZUKAJ_ZMIANY_I_INST(pNK_ZLEC NUMBER, pNR_POZ NUMBER, pNR_WAR NUMBER, pNR_OBR NUMBER, pINST_AKT NUMBER, pZM_OD NUMBER, pZM_DO NUMBER, pKIERUNEK NUMBER DEFAULT 0) RETURN NUMBER --pKIERUNEK=0 szukaj wstecz   1-wprzód
       NrZm:=SZUKAJ_ZMIANY_I_INST(pNK_ZLEC, rec1.nr_poz_zlec, rec1.nr_warst, rec1.nr_obr, rec1.nr_inst_plan, NrZm, NrZmLast, 1);
      ELSE 
       NrZm:=tabOBRz(rec1.nr_obr);
      END IF;
       UPDATE l_wyc2
       SET nr_zm_plan=NrZm, nr_inst_plan=nvl(nullif(tabOBRi(rec1.nr_obr),0),nr_inst_plan)
       WHERE nr_kom_zlec=pNK_ZLEC and nr_poz_zlec=rec1.nr_poz_zlec and nr_szt=rec1.nr_szt and ELEMENT_LISTY(rec1.nry_porz,nr_porz_obr)=1;
       update tmp_zmiany2
       set szt_zl1=szt_zl1+1, wielk_zl1=wielk_zl1+rec1.il_przel
       where nr_komp_inst=rec1.nr_inst_plan and nr_komp_zm=NrZm;
     ELSE
       NrZm:=SZUKAJ_ZMIANY(rec1.nr_inst_plan, NrZm, NrZmLast, rec1.il_przel,1);
       UPDATE l_wyc2
       SET nr_zm_plan=NrZm
       WHERE nr_kom_zlec=pNK_ZLEC and nr_poz_zlec=rec1.nr_poz_zlec and nr_szt=rec1.nr_szt and ELEMENT_LISTY(rec1.nry_porz,nr_porz_obr)=1;
       update tmp_zmiany2
       set szt_zl1=szt_zl1+1, wielk_zl1=wielk_zl1+rec1.il_przel
       where nr_komp_inst=rec1.nr_inst_plan and nr_komp_zm=NrZm;
     END IF;  

     -- zabezpieczenie przez dzieleniem warstw na zmiany na inst. kompletacji, wprowadza drobna niedokladnosc w TMP_ZMIANY
     IF rec1.obr_lacz in (3,4) THEN
      UPDATE l_wyc2
      SET nr_zm_plan=NrZm
      WHERE nr_kom_zlec=pNK_ZLEC and nr_poz_zlec=rec1.nr_poz_zlec and nr_szt=rec1.nr_szt and nr_inst_plan=rec1.nr_inst_plan and nr_obr=rec1.nr_obr; --potrzeba zawezic do tego samego laminatu LUB szyby przy zesoleniu
     END IF;
    END LOOP;
    CLOSE c1;
   EXCEPTION WHEN OTHERS THEN
    ZAPISZ_LOG('PLANUJ_SZYBY3',pNK_ZLEC,'E',0);
    ZAPISZ_ERR(SQLERRM||': '||dbms_utility.FORMAT_ERROR_BACKTRACE);  
   END PLANUJ_SZYBY3;

  PROCEDURE PLANUJ_SZYBY (pNK_ZLEC NUMBER, pNR_ZM_POCZ NUMBER default 0, pNR_ZM_KONC NUMBER default 0) AS
  BEGIN
   IF vWDR=0 THEN SELECT nr_wdr INTO vWDR FROM firma; END IF;
   --PLANUJ_SZYBY1(pNK_ZLEC, pNR_ZM_KONC);
   if pNR_ZM_POCZ>0 then
    PLANUJ_SZYBY3(pNK_ZLEC, pNR_ZM_POCZ);  --wprzód
   else 
    PLANUJ_SZYBY2(pNK_ZLEC, pNR_ZM_KONC); --wstecz
   end if;
   --22.02.2021 przeniesione z pocz. procedury
   USUN_PLAN(pNK_ZLEC);
   --22.02.2021 nowe
   PORZADKUJ_ZMIANY_I_KALINST (-pNK_ZLEC, 0); --porzadkowanie zmian dotychczasowych

  END;

END PKG_PLAN_SPISS;
/