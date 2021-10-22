create or replace package PKG_CZAS AS 

  FUNCTION NR_KOMP_ZM (DZIEN IN DATE,  ZMIANA IN NUMBER) RETURN NUMBER;
  FUNCTION NR_ZM_TO_DATE (pNR_KOMP_ZM IN NUMBER) RETURN DATE;
  FUNCTION NR_ZM_TO_ZM (pNR_KOMP_ZM IN NUMBER) RETURN NUMBER;

  FUNCTION CZAS_TO_ZM (pNR_KOMP_INST IN NUMBER, pDATA IN DATE, pPRZED_PO IN NUMBER DEFAULT 0, pRAISE_EX IN NUMBER DEFAULT 1) RETURN NUMBER;
  FUNCTION CZAS_TO_ZM2 (pNR_KOMP_INST IN NUMBER, pDATA IN DATE, pPRZED_PO IN NUMBER DEFAULT 0, pRAISE_EX IN NUMBER DEFAULT 1) RETURN NUMBER;
  PROCEDURE POBIERZ_GODZ_PRACY(pNR_KOMP_INST IN NUMBER, pDayOfWeek IN NUMBER, pPocz OUT DATE, pKon OUT DATE, pDlugZm OUT NUMBER);
  PROCEDURE NUMER_TYGODNIA (pDATA IN DATE, pNR_TYG IN OUT NUMBER, pROK IN OUT NUMBER, pDATA_PON OUT DATE);
  --03.2021
  FUNCTION GODZ_POCZ_ZM(pNR_KOMP_INST NUMBER, pNR_ZM NUMBER) RETURN DATE;
  FUNCTION GODZ_KONC_ZM(pNR_KOMP_INST NUMBER, pNR_ZM NUMBER, pUWZGL_CZAS_POPROC NUMBER default 0) RETURN DATE;
  
END PKG_CZAS;
/


create or replace package body PKG_CZAS AS

FUNCTION NR_KOMP_ZM (DZIEN IN DATE,  ZMIANA IN NUMBER)
 RETURN NUMBER AS
BEGIN
  IF DZIEN<to_date('1999/01/01','YYYY/MM/DD') THEN RETURN 0;
  ELSE
   RETURN (trunc(DZIEN)-trunc(to_date('1999/01/01','YYYY/MM/DD'))-1)*4 + ZMIANA;
  END IF;
END NR_KOMP_ZM;

FUNCTION NR_ZM_TO_DATE (pNR_KOMP_ZM IN NUMBER) 
 RETURN DATE AS
BEGIN
  IF pNR_KOMP_ZM>0 THEN
   --RETURN trunc(to_date('1999/01/01','YYYY/MM/DD')) + (pNR_KOMP_ZM-((pNR_KOMP_ZM-1) mod 4))*0.25 +1;
   RETURN trunc(to_date('1999/01/01','YYYY/MM/DD')) + (pNR_KOMP_ZM-(mod(pNR_KOMP_ZM-1,4)+1))*0.25 +1;    
  ELSE
   RETURN to_date('1901/01/01','YYYY/MM/DD');
  END IF;
END NR_ZM_TO_DATE;

FUNCTION  NR_ZM_TO_ZM (pNR_KOMP_ZM IN NUMBER)
 RETURN NUMBER AS
BEGIN
  IF pNR_KOMP_ZM>0 THEN
   RETURN ((pNR_KOMP_ZM-1) mod 4) +1;   
  ELSE
   RETURN 0;
  END IF;
END NR_ZM_TO_ZM;

FUNCTION CZAS_TO_ZM (pNR_KOMP_INST IN NUMBER, pDATA IN DATE, pPRZED_PO IN NUMBER DEFAULT 0, pRAISE_EX IN NUMBER DEFAULT 1)
 RETURN NUMBER
AS
 vDOW NUMBER;
 vGodzPocz DATE;
 vGodzKon DATE;
 vDlugZm  NUMBER;   --ilosc godz zmiany
 vDlugDnia NUMBER;  --ilosc godzin pracy
 vCzasPracy NUMBER; --ilosc godzin od pocz. dnia do chwili pDate
 vTmp NUMBER;
 EX_ZERO EXCEPTION;
BEGIN
 SELECT to_number(to_char(pDATA,'D'),'9') INTO vDOW FROM dual;
 --sprawdzenie poprzedniego dnia
 POBIERZ_GODZ_PRACY(pNR_KOMP_INST, case vDOW when 1 then 7 else vDOW-1 end,
                    vGodzPocz,vGodzKon,vDlugZm);
 --jezeli czas spoza godzin pracy poprzedniego dnia
 IF vGodzKon>vGodzPocz OR
    to_date(to_char(pData,'HH24MISS'),'HH24MISS')>=to_date(to_char(vGodzKon,'HH24MISS'),'HH24MISS') THEN
  --pobranie dnia wg pDATA
  POBIERZ_GODZ_PRACY(pNR_KOMP_INST, vDOW, vGodzPocz, vGodzKon, vDlugZm);
 END IF;
 

 IF vGodzKon=vGodzPocz THEN
    IF to_char(vGodzPocz,'HH24MISS')='000000' THEN RETURN 0; 
    ELSE vDlugDnia:=24; END IF;
 ELSIF vGodzKon>vGodzPocz THEN vDlugDnia:=(vGodzKon-vGodzPocz)*24;
                          ELSE vDlugDnia:=(vGodzKon-vGodzPocz+1)*24; 
 END IF;
                       
 IF to_date(to_char(pData,'HH24MISS'),'HH24MISS')>=to_date(to_char(vGodzPocz,'HH24MISS'),'HH24MISS') THEN
      vCzasPracy:=(to_date(to_char(pData,'HH24MISS'),'HH24MISS')-to_date(to_char(vGodzPocz,'HH24MISS'),'HH24MISS'))*24;
 ELSE vCzasPracy:=(to_date(to_char(pData,'HH24MISS'),'HH24MISS')-to_date(to_char(vGodzPocz,'HH24MISS'),'HH24MISS')+1)*24;
 END IF;
 
 vTmp:=0;
 FOR Lcntr IN 1..4
  LOOP
    IF vCzasPracy<=vDlugDnia AND vCzasPracy between vDlugZm*(Lcntr-1) and vDlugZm*Lcntr THEN
      vTmp:=Lcntr;
    END IF;  
    EXIT WHEN vTmp>0;
  END LOOP;
  IF vTmp>0 THEN RETURN vTmp; END IF;
 
 --sprawdzanie czy czas nieznacznie (o ilosc minut pPRZED_PO) przed/po godzinach pracy
 IF pPRZED_PO>0 THEN
  vTmp:=to_date(to_char(pData,'HH24MISS'),'HH24MISS')-to_date(to_char(vGodzPocz,'HH24MISS'),'HH24MISS'); --roznica w dn.
  IF vTmp<0 AND round(vTmp*60*24,6)+pPRZED_PO>=0 THEN RETURN 1; END IF;
  vTmp:=vDlugDnia-vCzasPracy; --roznica (ilosc nadgodz) w godz.
  IF vTmp<0 AND round(vTmp*60,4)+pPRZED_PO>=0 THEN RETURN round(vCzasPracy/vDlugZm); END IF;
 END IF;
 --gdy nieznaleziono wczesniej to rzucany wyjatek albo zwracane 0
 IF pRAISE_EX=1 THEN RAISE EX_ZERO;
 ELSE RETURN 0;
 END IF;
EXCEPTION
 WHEN EX_ZERO THEN RAISE_APPLICATION_ERROR(-20003,'NIEOKRESLONA ZMIANA '||to_char(pData,'DD/MM/YYYY HH24:MI:SS'));
 WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20004,'PKG_CZAS.CZAS_TO_ZM');
 WHEN OTHERS THEN RAISE_APPLICATION_ERROR(-20099,'NIEKREŒLONY B£¥D'); 
END CZAS_TO_ZM;

--druga wersja, z bazy Eff
FUNCTION CZAS_TO_ZM2 (pNR_KOMP_INST IN NUMBER, pDATA IN DATE, pPRZED_PO IN NUMBER DEFAULT 0, pRAISE_EX IN NUMBER DEFAULT 1)
 RETURN NUMBER
AS
 vRecInst parinst%ROWTYPE;
 vDOW CHAR(1);
 vGodzPocz DATE;
 vGodzKon DATE;
 vDlugDnia NUMBER;  --ilosc godzin pracy
 vCzasPracy NUMBER; --ilosc godzin od pocz. dnia do chwili pDate
 vTmp NUMBER;
 EX_ZERO EXCEPTION;
BEGIN
 SELECT * INTO vRecInst FROM parinst WHERE nr_komp_inst=pNR_KOMP_INST;
 SELECT to_char(sysdate,'D') INTO vDOW FROM dual;
 CASE vDOW
  WHEN '1' THEN BEGIN vGodzPocz:=to_date(vRecInst.pon_pocz,'HH24MISS');
                      vGodzKon:=to_date(vRecInst.pon_kon,'HH24MISS'); END;
  WHEN '2' THEN BEGIN vGodzPocz:=to_date(vRecInst.wt_pocz,'HH24MISS');
                      vGodzKon:=to_date(vRecInst.wt_kon,'HH24MISS'); END;
  WHEN '3' THEN BEGIN vGodzPocz:=to_date(vRecInst.sr_pocz,'HH24MISS');
                      vGodzKon:=to_date(vRecInst.sr_kon,'HH24MISS'); END;
  WHEN '4' THEN BEGIN vGodzPocz:=to_date(vRecInst.czw_pocz,'HH24MISS');
                      vGodzKon:=to_date(vRecInst.czw_kon,'HH24MISS'); END;
  WHEN '5' THEN BEGIN vGodzPocz:=to_date(vRecInst.pi_pocz,'HH24MISS');
                      vGodzKon:=to_date(vRecInst.pi_kon,'HH24MISS'); END;
  WHEN '6' THEN BEGIN vGodzPocz:=to_date(vRecInst.sob_pocz,'HH24MISS');
                      vGodzKon:=to_date(vRecInst.sob_kon,'HH24MISS'); END;
  WHEN '7' THEN BEGIN vGodzPocz:=to_date(vRecInst.nie_pocz,'HH24MISS');
                      vGodzKon:=to_date(vRecInst.nie_kon,'HH24MISS'); END;
 END CASE;
 IF vGodzKon=vGodzPocz AND to_char(vGodzPocz,'HH24MISS')='000000' THEN RETURN 0; END IF;
 
 IF vGodzKon>vGodzPocz THEN vDlugDnia:=(vGodzKon-vGodzPocz)*24;
                       ELSE vDlugDnia:=(vGodzKon-vGodzPocz+24)*24; 
 END IF;
                       
 IF to_date(to_char(pData,'HH24MISS'),'HH24MISS')>=to_date(to_char(vGodzPocz,'HH24MISS'),'HH24MISS') THEN
      vCzasPracy:=(to_date(to_char(pData,'HH24MISS'),'HH24MISS')-to_date(to_char(vGodzPocz,'HH24MISS'),'HH24MISS'))*24;
 ELSE vCzasPracy:=(to_date(to_char(pData,'HH24MISS'),'HH24MISS')-to_date(to_char(vGodzPocz,'HH24MISS'),'HH24MISS')+24)*24;
 END IF;
 
 vTmp:=0;
 FOR Lcntr IN 1..4
  LOOP
    IF vCzasPracy<=vDlugDnia AND vCzasPracy between vRecInst.dlugosc_zmiany*(Lcntr-1) and vRecInst.dlugosc_zmiany*Lcntr THEN
      vTmp:=Lcntr;
    END IF;  
    EXIT WHEN vTmp>0;
  END LOOP;
  IF vTmp>0 THEN RETURN vTmp; END IF;
 
 --sprawdzanie czy czas nieznacznie (o ilosc minut pPRZED_PO) przed/po godzinach pracy
 IF pPRZED_PO>0 THEN
  vTmp:=to_date(to_char(pData,'HH24MISS'),'HH24MISS')-to_date(to_char(vGodzPocz,'HH24MISS'),'HH24MISS'); --roznica w dn.
  IF vTmp<0 AND round(vTmp*60*24,6)+pPRZED_PO>=0 THEN RETURN 1; END IF;
  vTmp:=vDlugDnia-vCzasPracy; --roznica (ilosc nadgodz) w godz.
  IF vTmp<0 AND round(vTmp*60,4)+pPRZED_PO>=0 THEN RETURN round(vCzasPracy/vRecInst.dlugosc_zmiany); END IF;
 END IF;
 --gdy nieznaleziono wczesniej to rzucany wyjatek albo zwracane 0
 IF pRAISE_EX=1 THEN RAISE EX_ZERO;
 ELSE RETURN 0;
 END IF;
EXCEPTION
 WHEN EX_ZERO THEN RAISE_APPLICATION_ERROR(-20003,'NIEOKRESLONA ZMIANA '||to_char(pData,'DD/MM/YYYY HH24:MI:SS'));
 WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20004,'PKG_CZAS.CZAS_TO_ZM');
 WHEN OTHERS THEN RAISE_APPLICATION_ERROR(-20099,'NIEKREŒLONY B£¥D'); 
END CZAS_TO_ZM2;


PROCEDURE POBIERZ_GODZ_PRACY(pNR_KOMP_INST IN NUMBER, pDayOfWeek IN NUMBER, pPocz OUT DATE, pKon OUT DATE, pDlugZm OUT NUMBER)
AS
  vRecInst parinst%ROWTYPE;
BEGIN 
 SELECT * INTO vRecInst FROM parinst WHERE nr_komp_inst=pNR_KOMP_INST;
 pDlugZm:=vRecInst.dlugosc_zmiany;
 
 CASE pDayOfWeek
  WHEN 1 THEN BEGIN pPocz:=to_date(vRecInst.pon_pocz,'HH24MISS');
                    pKon:=to_date(vRecInst.pon_kon,'HH24MISS'); END;
  WHEN 2 THEN BEGIN pPocz:=to_date(vRecInst.wt_pocz,'HH24MISS');
                    pKon:=to_date(vRecInst.wt_kon,'HH24MISS'); END;
  WHEN 3 THEN BEGIN pPocz:=to_date(vRecInst.sr_pocz,'HH24MISS');
                    pKon:=to_date(vRecInst.sr_kon,'HH24MISS'); END;
  WHEN 4 THEN BEGIN pPocz:=to_date(vRecInst.czw_pocz,'HH24MISS');
                    pKon:=to_date(vRecInst.czw_kon,'HH24MISS'); END;
  WHEN 5 THEN BEGIN pPocz:=to_date(vRecInst.pi_pocz,'HH24MISS');
                    pKon:=to_date(vRecInst.pi_kon,'HH24MISS'); END;
  WHEN 6 THEN BEGIN pPocz:=to_date(vRecInst.sob_pocz,'HH24MISS');
                    pKon:=to_date(vRecInst.sob_kon,'HH24MISS'); END;
  WHEN 7 THEN BEGIN pPocz:=to_date(vRecInst.nie_pocz,'HH24MISS');
                    pKon:=to_date(vRecInst.nie_kon,'HH24MISS'); END;
 END CASE;
END POBIERZ_GODZ_PRACY;


PROCEDURE NUMER_TYGODNIA (pDATA IN DATE, pNR_TYG IN OUT NUMBER, pROK IN OUT NUMBER, pDATA_PON OUT DATE)
AS
 ustaw_NR_TYG boolean;  --procedura moze ustawiac tylko pDATA_PON gdy nie podana pDATA a podane pNR_TYG i pROK
 data_rob date;
 boy date;   --1. styczen
 dow01 number; --dzien tygodnia Nowego roku 
 day1 date;  --poniedziaek 1. tygodnia
BEGIN
 ustaw_NR_TYG := pDATA is not null AND pDATA>to_date('01/01/1901','DD/MM/YYYY');
 IF ustaw_NR_TYG THEN
  data_rob := pDATA;
 ELSE 
  data_rob :=to_date(to_char(pROK,'9999'),'YYYY');
 END IF; 
 boy :=trunc(data_rob)-to_char(trunc(data_rob),'DDD')+1; --1. stycznia godz. 0:00 
 dow01 := to_char(boy,'D'); --numer dnia tyg. Nowego roku
 IF dow01>4 THEN  --gdy Nowy Rok pozniej niz czwartek to jest to ostatni tydzien poprzedniego roku
  day1 := boy + (7-dow01) + 1;
 ELSE
  day1 := boy - dow01 + 1;
 END IF;
 IF ustaw_NR_TYG THEN 
  pNR_TYG := floor((data_rob-day1)/7)+1;
  IF pNR_TYG>0 THEN
   pDATA_PON := day1 + (pNR_TYG-1)*7;
   pROK := to_char(trunc(pDATA_PON),'YYYY');
   --gdy poniedzialek jest ktoryms z ostatnich 3 dni roku to jest to juz 1. tyg. nowego roku
   IF to_char(pDATA_PON,'MM')=12 AND to_char(pDATA_PON,'DD')>28 THEN
      pROK := pROK+1;
      pNR_TYG := 1;
   END IF;
  ELSE
   NUMER_TYGODNIA(day1-7, pNR_TYG, pROK, pDATA_PON);
  END IF; 
  
 ELSE
   pDATA_PON := day1 + (pNR_TYG-1)*7;
 END IF;
 
END NUMER_TYGODNIA;

FUNCTION GODZ_POCZ_ZM(pNR_KOMP_INST NUMBER, pNR_ZM NUMBER) RETURN DATE
AS
 GPocz DATE;
 WeekDay NUMBER(1);
 Dzien DATE;
 Zm NUMBER(1);
BEGIN
 WeekDay:=to_char(NR_ZM_TO_DATE(pNR_ZM),'D');
 Dzien:=NR_ZM_TO_DATE(pNR_ZM);
 Zm:=NR_ZM_TO_ZM(pNR_ZM);
 SELECT to_date(to_char(Dzien,'DDMMYYYY')||' '||decode(WeekDay,1,pon_pocz,2,wt_pocz,3,sr_pocz,4,czw_pocz,5,pi_pocz,6,sob_pocz,7,nie_pocz,'060000'),'DDMMYYYY HH24MISS')
        +(Zm-1)*dlugosc_zmiany/24
   INTO GPocz
 FROM parinst
 WHERE nr_komp_inst=pNR_KOMP_INST;
 RETURN GPocz; --zwracana wartoœæ DATE = 1.dzieñ bie¿acego miesiaca + godzina wg PARINST
END GODZ_POCZ_ZM;

FUNCTION GODZ_KONC_ZM(pNR_KOMP_INST NUMBER, pNR_ZM NUMBER, pUWZGL_CZAS_POPROC NUMBER) RETURN DATE
AS
 GPocz DATE;
 WeekDay NUMBER(1);
 Dzien DATE;
 Zm NUMBER(1);
BEGIN
 WeekDay:=to_char(NR_ZM_TO_DATE(pNR_ZM),'D');
 Dzien:=NR_ZM_TO_DATE(pNR_ZM);
 Zm:=NR_ZM_TO_ZM(pNR_ZM);
 SELECT to_date(to_char(Dzien,'DDMMYYYY')||' '||decode(WeekDay,1,pon_pocz,2,wt_pocz,3,sr_pocz,4,czw_pocz,5,pi_pocz,6,sob_pocz,7,nie_pocz,'060000'),'DDMMYYYY HH24MISS')
        +Zm*dlugosc_zmiany/24
        +sign(pUWZGL_CZAS_POPROC)*czas_poprocesowy/24
   INTO GPocz
 FROM parinst
 WHERE nr_komp_inst=pNR_KOMP_INST;
 RETURN GPocz; --zwracana wartoœæ DATE = 1.dzieñ bie¿acego miesiaca + godzina wg PARINST
END GODZ_KONC_ZM;

END PKG_CZAS;
/