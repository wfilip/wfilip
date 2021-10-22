create or replace
PACKAGE PKG_MAIN AS 
  
  FUNCTION REC_ZAMOW (pNR_KOM_ZLEC IN NUMBER)
    RETURN zamow%ROWTYPE;  
  FUNCTION REC_SPISZ (pNR_KOM_ZLEC IN NUMBER, pNR_POZ IN NUMBER, pID_POZ IN NUMBER DEFAULT 0)
    RETURN spisz%ROWTYPE;
  FUNCTION REC_SPISE (pNR_KOM_ZLEC IN NUMBER, pNR_POZ IN NUMBER, pNR_SZT IN NUMBER, pNR_KOM_SZYBY IN NUMBER)
    RETURN spise%ROWTYPE;
  FUNCTION REC_SPISD (pNR_KOM_ZLEC IN NUMBER, pNR_POZ IN NUMBER, pNR_WAR IN NUMBER, pSTRONA IN NUMBER)
    RETURN spisd%ROWTYPE;
  FUNCTION REC_KATALOG (pNr_kat IN NUMBER, pTyp_kat IN VARCHAR2 DEFAULT ' ')
    RETURN katalog%ROWTYPE;
  FUNCTION REC_STRUKTURY (pNr_str IN NUMBER, pKod_str IN VARCHAR2 DEFAULT ' ')
    RETURN struktury%ROWTYPE;
  FUNCTION REC_PARINST (pNk_inst IN NUMBER, pTyp_inst IN VARCHAR2 DEFAULT ' ', pNr_inst IN NUMBER DEFAULT 0)
    RETURN parinst%ROWTYPE;
  FUNCTION REC_SLPAROB (pNk_obr IN NUMBER)
    RETURN slparob%ROWTYPE;
  FUNCTION REC_BRAKI_B (pZLEC_BRAKI IN NUMBER, pID_POZ_BR IN NUMBER, pNR_POZ_BR IN NUMBER DEFAULT 0)
    RETURN braki_b%ROWTYPE;
  
  FUNCTION GET_PARAM_T (p_nr IN NUMBER, p_def IN VARCHAR2)
    RETURN VARCHAR2;
  FUNCTION GET_KONFIG_T (p_nr IN NUMBER, p_opis IN VARCHAR2 DEFAULT ' ') RETURN NUMBER;

END PKG_MAIN;
/


create or replace
PACKAGE BODY PKG_MAIN AS

FUNCTION REC_ZAMOW (pNR_KOM_ZLEC IN NUMBER)
    RETURN zamow%ROWTYPE
AS
  rec zamow%ROWTYPE;
BEGIN
  SELECT * INTO rec FROM zamow WHERE nr_kom_zlec=pNR_KOM_ZLEC;
  RETURN rec;
END REC_ZAMOW;

FUNCTION REC_SPISZ (pNR_KOM_ZLEC IN NUMBER, pNR_POZ IN NUMBER, pID_POZ IN NUMBER DEFAULT 0)
    RETURN spisz%ROWTYPE
AS
 rec spisz%ROWTYPE;
 CURSOR c1
  IS SELECT * INTO rec FROM spisz WHERE nr_kom_zlec=pNR_KOM_ZLEC and nr_poz=pNR_POZ;
 CURSOR c2
  IS SELECT * INTO rec FROM spisz WHERE nr_kom_zlec=pNR_KOM_ZLEC and id_poz=pID_POZ;
BEGIN
  rec := null;
  IF pNR_POZ>0 THEN
   OPEN c1;  FETCH c1 INTO rec; CLOSE c1;
  ELSIF pID_POZ>0 THEN
   OPEN c2;  FETCH c2 INTO rec; CLOSE c2;
  END IF;
  RETURN rec;
END REC_SPISZ;


FUNCTION REC_SPISE (pNR_KOM_ZLEC IN NUMBER, pNR_POZ IN NUMBER, pNR_SZT IN NUMBER, pNR_KOM_SZYBY IN NUMBER)
    RETURN spise%ROWTYPE
AS
 rec spise%ROWTYPE;
 CURSOR c1
  IS SELECT * INTO rec FROM spise WHERE nr_komp_zlec=pNR_KOM_ZLEC and nr_poz=pNR_POZ and nr_szt=pNR_SZT;
 CURSOR c2
  IS SELECT * INTO rec FROM spise WHERE nr_kom_szyby=pNR_KOM_SZYBY;
BEGIN
  rec := null;
  IF pNR_KOM_ZLEC>0 THEN
   OPEN c1;  FETCH c1 INTO rec; CLOSE c1;
  ELSIF pNR_KOM_SZYBY>0 THEN
   OPEN c2;  FETCH c2 INTO rec; CLOSE c2;
  END IF;
  RETURN rec;
END REC_SPISE;

FUNCTION REC_SPISD (pNR_KOM_ZLEC IN NUMBER, pNR_POZ IN NUMBER, pNR_WAR IN NUMBER, pSTRONA IN NUMBER)
    RETURN spisd%ROWTYPE
AS
 rec spisd%ROWTYPE;
 CURSOR c1
  IS
   SELECT * INTO rec FROM spisd WHERE nr_kom_zlec=pNR_KOM_ZLEC and nr_poz=pNR_POZ and do_war=pNR_WAR and strona=pSTRONA and rownum=1;
BEGIN
  rec := null;
  OPEN c1;  FETCH c1 INTO rec; CLOSE c1;
  RETURN rec;
END REC_SPISD;
 
FUNCTION REC_KATALOG (pNr_kat IN NUMBER, pTyp_kat IN VARCHAR2)
    RETURN katalog%ROWTYPE
AS
 rec KATALOG%ROWTYPE;
 CURSOR c1 (pNR_KAT NUMBER) IS
   SELECT * FROM katalog WHERE nr_kat=pNr_kat;
 CURSOR c2 (pTYP_KAT varchar2) IS
   SELECT * FROM katalog WHERE typ_kat=pTYP_KAT;

BEGIN
 IF pNR_kat>0 THEN
  OPEN c1 (pNr_kat);
  fetch c1 INTO rec;
  CLOSE c1;
 ELSE
  OPEN c2 (pTyp_kat);
  fetch c2 INTO rec;
  CLOSE c2;
 END IF;
  RETURN rec;
END REC_KATALOG;

FUNCTION REC_STRUKTURY (pNr_str IN NUMBER, pKod_str IN VARCHAR2)
    RETURN struktury%ROWTYPE
AS
 rec struktury%ROWTYPE;  
 CURSOR c1 (pNR_STR NUMBER)
  IS
    SELECT * FROM struktury WHERE nr_kom_str=pNR_STR;
 CURSOR c2 (pKOD_STR VARCHAR2)
  IS
    SELECT * FROM struktury WHERE kod_str=pKOD_STR;
BEGIN
  IF pNr_str>0 THEN
   OPEN c1 (pNr_str);
   FETCH c1 into rec;
   CLOSE c1;
  ELSE
   OPEN c2 (pKod_str);
   FETCH c2 into rec;
   CLOSE c2;
  END IF;
 
  RETURN rec;
END REC_STRUKTURY;

FUNCTION REC_PARINST (pNk_inst IN NUMBER, pTyp_inst IN VARCHAR2, pNr_inst IN NUMBER)
    RETURN parinst%ROWTYPE
AS
 rec parinst%ROWTYPE;
BEGIN
  rec := NULL;
  IF pNk_inst>0 THEN
   SELECT parinst.* INTO rec FROM parinst WHERE nr_komp_inst=pNK_INST;
  ELSIF pNr_inst>0 THEN
   SELECT parinst.* INTO rec FROM parinst WHERE ty_inst=pTyp_inst and nr_inst=pNr_inst;
  END IF;
  RETURN rec;
END REC_PARINST;

FUNCTION REC_SLPAROB (pNk_obr IN NUMBER)
    RETURN slparob%ROWTYPE
AS
 rec slparob%ROWTYPE;
 CURSOR c1
  IS
  SELECT * FROM slparob WHERE nr_k_p_obr=pNk_obr;
BEGIN
  rec:=NULL;
  IF pNk_obr>0 THEN
   OPEN c1;
   FETCH c1 INTO rec;
   CLOSE c1;
  END IF;
  RETURN rec;
END REC_SLPAROB;

FUNCTION REC_BRAKI_B (pZLEC_BRAKI IN NUMBER, pID_POZ_BR IN NUMBER, pNR_POZ_BR IN NUMBER DEFAULT 0)
    RETURN braki_b%ROWTYPE
AS 
 rec  BRAKI_B%ROWTYPE;
 recP SPISZ%ROWTYPE;
 vID NUMBER(10);
 CURSOR c1 (pZLEC NUMBER, pID NUMBER)
  IS
    SELECT * FROM braki_b WHERE zlec_braki=pZLEC AND id_poz_br=pID;
BEGIN
  IF pID_POZ_BR>0 THEN vID:=pID_POZ_BR;
                  ELSE recP:=REC_SPISZ(pZLEC_BRAKI,pNR_POZ_BR);
                       vID:=recP.id_poz;
  END IF;                  
  OPEN c1 (pZLEC_BRAKI, vID);
  fetch c1 INTO rec;
  CLOSE c1;
  RETURN rec;
END REC_BRAKI_B;

FUNCTION GET_PARAM_T (p_nr IN NUMBER, p_def IN VARCHAR2) RETURN VARCHAR2
AS
 v_wartosc VARCHAR2(21);
 e NUMBER(1);
BEGIN
  SELECT count(1) INTO e FROM param_t WHERE kod=p_nr;
  IF e>0 THEN
   SELECT wartosc INTO v_wartosc FROM param_t WHERE kod=p_nr;
  ELSE 
    INSERT INTO param_t (kod, wartosc, opis) VALUES (p_nr,p_def,' ');
    v_wartosc:=p_def;
    --COMMIT;
  END IF;
  RETURN v_wartosc;
END GET_PARAM_T;

FUNCTION GET_KONFIG_T 
( p_nr IN NUMBER, p_opis IN VARCHAR2 DEFAULT ' ') RETURN NUMBER
AS
  v_wartosc NUMBER(10);
  e NUMBER(1);
BEGIN
  select count(1) into e from konfig_t where nr_par=p_nr;
  if e>0 then
   select ost_nr+1 into v_wartosc from konfig_t where nr_par=p_nr;
   update konfig_t set ost_nr=ost_nr+1 where nr_par=p_nr;
  else 
    insert into konfig_t (nr_par, ost_nr, opis,opis_lang) values (p_nr,1,p_opis,' ');
    v_wartosc:=0;
    --commit;
  end if;
  RETURN v_wartosc;
END GET_KONFIG_T;

END PKG_MAIN;
/