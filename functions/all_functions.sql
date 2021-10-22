--------------------------------------------------------
--  File created - poniedzia³ek-paŸdziernika-23-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function CZY_WYKONANY_BRAK
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CZY_WYKONANY_BRAK" (pID_REK NUMBER, pKOLEJN NUMBER) RETURN NUMBER
AS
vNr_ser_br NUMBER(12);
vD_wyk DATE;
BEGIN
--pobranie nowego NR_SER z najnowszego zlecenia braku
SELECT nvl(max(nr_ser),0) INTO vNr_ser_br
FROM l_wyc
WHERE id_oryg=pID_REK and wyroznik='B'; --id_oryg wype³niany przy parT_103>0
IF vNr_ser_br=0 THEN
RETURN 0;
END IF;
--spr. D_WYK na inst bie¿¹cej lub póŸniejszej w kolejnosci
SELECT max(d_wyk) INTO vD_wyk
FROM l_wyc
WHERE nr_ser=vNr_ser_br AND kolejn>=pKOLEJN;
RETURN case when vD_wyk>'2001/01/01' THEN 1 else 0 end;
EXCEPTION WHEN OTHERS THEN
RETURN 0;
END CZY_WYKONANY_BRAK;

/
--------------------------------------------------------
--  DDL for Function ELEMENT_LISTY
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "ELEMENT_LISTY" (pLISTA in varchar2, pNR in number, pSEP CHAR DEFAULT ',') return NUMBER
as 
 BEGIN
  RETURN case when instr(pSEP||pLISTA||pSEP,pSEP||pNR||pSEP)>0
              then 1 else 0
         end;
 END ELEMENT_LISTY;

/
--------------------------------------------------------
--  DDL for Function ETYKIETA_PROD
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "ETYKIETA_PROD" (p_NrKompZlec in NUMBER, p_NrPoz in NUMBER, p_NrSzt in NUMBER, p_NrWar in NUMBER)
   return varchar2
is
   vResult    varchar2(1000);
   v_col_name varchar2(100);
   v_col_type varchar2(30);
   v_col     varchar2(1000);
   cursor c_col is select column_name,data_type from ALL_TAB_COLS where TABLE_NAME='V_ETYKIETY_PROD2' and owner in (select sys_context( 'userenv', 'current_schema' ) from dual);
   rec_col c_col%ROWTYPE;
   TYPE cur_typ IS REF CURSOR;
   c cur_typ;
   query_str VARCHAR2(1000);
   pierwszy boolean := True;
begin
  vResult := '';  

  OPEN c_col;
  LOOP
    FETCH c_col INTO rec_col;
    EXIT WHEN c_col%NOTFOUND;
    if instr(rec_col.column_name,'F_')>0 then
      query_str := 'select '||rec_col.column_name||' from v_etykiety_prod2 where nr_komp_zlec=:zlec and nr_poz=:poz and nr_szt=:szt and nr_war=:war';
      OPEN c FOR query_str USING p_NrKompZlec,p_NrPoz,p_NrSzt,p_NrWar;
      LOOP
          FETCH c INTO v_col;
          EXIT WHEN c%NOTFOUND;
          if not pierwszy then 
            vResult := vResult || Chr(13) || Chr(10); 
          end if;
          vResult := vResult || '[' || replace(rec_col.column_name,'F_','') || ']'||v_col;  
          pierwszy := False;
      END LOOP;
      CLOSE c;
    end if; 
    
  END LOOP;
  CLOSE c_col;
  return vResult;
  EXCEPTION WHEN OTHERS THEN
    IF c_col%ISOPEN THEN CLOSE c_col; END IF;
end ETYKIETA_PROD;

/
--------------------------------------------------------
--  DDL for Function ETYKIETA_PROD2
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "ETYKIETA_PROD2" (p_NrKompZlec in NUMBER, p_NrPoz in NUMBER, p_NrSzt in NUMBER, p_NrWar in NUMBER)
   return varchar2
is
   vResult    varchar2(10000);
   TYPE cur_typ IS REF CURSOR;
   c cur_typ;
   query_str VARCHAR2(1000);
   pierwszy boolean := True;
   v_cols varchar2(1000);
   v_values varchar2(10000);
   v_col varchar2(100);
   v_val varchar2(1000);
   i integer;
begin
  vResult := '';  
  
-- zebranie nazw column
  select listagg(column_name,Chr(8)) within group (order by column_id) into v_cols 
    from all_tab_cols where table_name='V_ETYKIETY_PROD' and COLUMN_name like 'F_%' and owner in (select sys_context( 'userenv', 'current_schema' ) from dual);

-- przygotowanie sql zwracaj¹cego wartoœci
  query_str := 'select '||replace(v_cols,Chr(8),'||'''||chr(8)||'''||')||' from V_ETYKIETY_PROD where nr_komp_zlec=:zlec and nr_poz=:poz and nr_szt=:szt and nr_war=:war' ;
  OPEN c FOR query_str USING p_NrKompZlec,p_NrPoz,p_NrSzt,p_nrWar;
  LOOP
    FETCH c INTO v_values;
    EXIT WHEN c%NOTFOUND;
  END LOOP;
  i := 1;
  
-- przygotowanie zwracanego stringu 
  loop
    v_col := strtoken(v_cols,i,Chr(8));
    exit when v_col is null;
    v_val := strtoken(v_values,i,Chr(8));
    
    if not pierwszy then 
      vResult := vResult || Chr(13) || Chr(10); 
    end if;
    vResult := vResult || '[' || replace(v_col,'F_','') || ']'||v_val;  
    pierwszy := False;
    i := i+1;
  end loop;
  CLOSE c;
  return vResult;
end ETYKIETA_PROD2;

/
--------------------------------------------------------
--  DDL for Function ETYKIETA_PROD_CUTMON
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "ETYKIETA_PROD_CUTMON" (p_NrKompZlec in NUMBER, p_NrPoz in NUMBER, p_NrSzt in NUMBER, p_NrWar in NUMBER)
   return varchar2
is
  vNrKompZlec numeric(10);
  vResult    varchar2(1000);
begin
  select ETYKIETA_PROD(p_NrKompZlec,p_nrPoz,p_nrSzt,p_nrWar) into vResult from dual;
  return vResult;
end ETYKIETA_PROD_CUTMON;

/
--------------------------------------------------------
--  DDL for Function ILE_KOMOR
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "ILE_KOMOR" (pNrKompZlec number, pNrPoz number) return number 
as
  r number;
begin
  select count(*) into r from spisd d
  left join katalog k on k.NR_KAT=d.NR_KAT
  left join spisd d_pop on d_pop.IDENT=d.IDENT and d_pop.STRONA=d.STRONA and d_pop.DO_WAR=d.DO_WAR-1
  left join katalog k_pop on k_pop.NR_KAT=d_pop.nr_kat
  where d.NR_KOM_ZLEC=pNrKompZlec and d.nr_poz=pNrPoz and d.STRONA=0 and k.RODZ_SUR='LIS' and k_pop.RODZ_SUR in ('TAF','POL');
  return r;
end;

/
--------------------------------------------------------
--  DDL for Function INSTR_SIP
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "INSTR_SIP" (pTEKST VARCHAR2, pFRAZY VARCHAR2, pAND NUMBER) return number
is
 tmp varchar2(1000);
 nr number(2):=0;
 poz number(4):=0;
begin
 if trim(pfrazy) is null then return 1; end if; 
 tmp:=replace(replace(upper(trim(pFRAZY)),'  ',';'),' ',';')||';';
 loop
  exit when tmp is null;-- or instr(tmp,';')=0;
  nr:=nr+1;
  poz:=instr(upper(pTEKST),substr(tmp,1,instr(tmp,';')-1));
  exit when poz=0 AND pAND=1 or poz>0 and pAND=0;
  tmp:=substr(tmp,instr(tmp,';')+1);
 end loop;
 return nr*sign(poz);
end instr_sip;

/
--------------------------------------------------------
--  DDL for Function LIPROD280_BCD
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function LISTA_ZLEC_POWIAZ
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "LISTA_ZLEC_POWIAZ" (pNK_ZLEC NUMBER, pFUN NUMBER DEFAULT 0, pPOLP NUMBER DEFAULT 1, pBRAKI NUMBER DEFAULT 1)
 RETURN VARCHAR2 AS
 vWew VARCHAR2(100);
 vBraki VARCHAR2(100);
 vNk NUMBER(10);
 vWyr CHAR(1);
 vLista VARCHAR2(100);
BEGIN
 --czy zlecenie jest Wewnêtrzne albo Braki 
 SELECT max(P.nr_komp_zlec), max(Z.wyroznik) INTO vNk, vWyr
 FROM zamow Z
 LEFT JOIN zlec_polp P ON Z.typ_zlec='Pro' and Z.nr_zlec=P.nr_zlec_wew
 WHERE Z.nr_kom_zlec=pNK_ZLEC;

 IF pPOLP>0 THEN
  vLista:=case when vNk is not null
               then vNk||','||pNK_ZLEC
               else to_char(pNK_ZLEC) end;
  --czy do zlecenia wygenerowano zlecenia Wewnêtrzne
  --SELECT listagg(nr_kom_zlec,',') within group (order by nr_kom_zlec) INTO vWew FROM ();
  FOR r in (SELECT DISTINCT Z.nr_kom_zlec
            FROM zlec_polp P
            LEFT JOIN zamow Z ON Z.typ_zlec='Pro' and Z.nr_zlec=P.nr_zlec_wew
            WHERE P.nr_komp_zlec=pNK_ZLEC AND P.nr_zlec_wew>0)
  LOOP
   vWew:=vWew||','||to_char(r.nr_kom_zlec);
  END LOOP;
  vLista:=vLista||vWew;
 END IF;
 --jeœli zlecenie Braki to szukanie Ÿródlowego
 IF pBRAKI>0 AND vWyr='B' THEN
  --SELECT Listagg(nr_zlec,',') Within Group (Order by nr_zlec) INTO vBraki
  FOR r IN
       (Select distinct nr_zlec From braki_b
        Where zlec_braki=pNK_ZLEC)
  LOOP
   vBraki:=vBraki||','||to_char(r.nr_zlec);
  END LOOP;
  IF vBraki is not null THEN
   vLista:=ltrim(vBraki,',')||','||vLista;
  END IF;
  --szukanie czy do zlecenia powstaly zlecenia braków
 ELSIF pBRAKI>0 THEN
  --  EXECUTE IMMEDIATE
  --  'SELECT Listagg(zlec_braki,'','') Within Group (Order by zlec_braki)
  --   FROM (Select distinct zlec_braki From braki_b
  --         Where braki_b.nr_zlec in ('||vLista||') And zlec_braki>0'||
  --  '     )' 
  --  INTO vBraki;
  vBraki:=QUERY2LIST('Select distinct zlec_braki From braki_b
                      Where nr_zlec in ('||vLista||') And zlec_braki>0');
  IF vBraki is not null THEN
   vLista:=vLista||','||vBraki;
  END IF;
 END IF;
 --vLista zawiera numery komp. - zamiana na numery zwykle(poprzedzone wyroznikiem) i wyrzucenie z listy zlecenia wejœciowego
 IF pFUN>0 THEN
  vLista:=QUERY2LIST('SELECT wyroznik||nr_zlec
                      FROM (select wyroznik, nr_zlec, instr('',''||'''||vLista||'''||'','',to_char(nr_kom_zlec)) lp
                            from zamow
                            where typ_zlec=''Pro'' and nr_kom_zlec in ('||vLista||')
                              and nr_kom_zlec<>'||pNK_ZLEC||
                     '     ) '||
                     'ORDER BY lp');
 END IF;
 RETURN vLista;
EXCEPTION WHEN OTHERS THEN
 RETURN 'ERR'||pNK_ZLEC||' '||SQLERRM;
END LISTA_ZLEC_POWIAZ;

/
--------------------------------------------------------
--  DDL for Function NR_KOMP_ZM
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "NR_KOMP_ZM" 
( DZIEN IN DATE,  
  ZMIANA IN NUMBER  
) RETURN NUMBER AS 
BEGIN
  IF DZIEN<to_date('1999/01/01','YYYY/MM/DD') THEN
   RETURN 0;
  ELSE
   RETURN (trunc(DZIEN)-trunc(to_date('1999/01/01','YYYY/MM/DD'))-1)*4 + ZMIANA;
  END IF;
END NR_KOMP_ZM;

/
--------------------------------------------------------
--  DDL for Function NR_ZLECTYP
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "NR_ZLECTYP" (p_nr_war IN NUMBER)
RETURN NUMBER AS 
BEGIN
  --zwraca nr zlec_typ w celu wyciagniecia parametrów podanej wartswy
  if p_nr_war>0 and p_nr_war<=5 then
    return p_nr_war+14;
  elsif p_nr_war>5 and p_nr_war<=20 then
    return p_nr_war+29;
  else
    return 0;
  end if;
END NR_ZLECTYP;

/
--------------------------------------------------------
--  DDL for Function PAR_KSZ_DC
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "PAR_KSZ_DC" (p_nrKompZlec in number, p_nrPoz in NUMBER, p_nrWar IN NUMBER)
RETURN VARCHAR2 AS 
  vlinia ZLEC_TYP.LINIA%TYPE;  
  vtyp integer;
  s char := ':';
  r spisz%ROWTYPE;
BEGIN
  -- czy pozycja z rysunkiem DXF
  select * into r from spisz where nr_kom_zlec=p_nrKompZlec and nr_poz=p_nrPoz;
  if r.nr_komp_rys>0 then
    --zwraca parametry ksztatltu dla zadanej warstwy ze zlectyp
    select nr_zlectyp(p_nrwar) into vtyp from dual;
    select linia into vlinia from zlec_typ where NR_KOMP_ZLEC=p_nrKompZlec and NR_POZ=p_nrPoz and typ=vtyp;
    -- drugi |
    vlinia := STRTOKEN(vlinia,2,'|');
    -- drugi ;
    vlinia := STRTOKEN(vlinia,2,';'); 
  elsif r.nr_kszt>0 then
    --zwraca parametry ksztaltu ze spisz
    vlinia :=   r.nrkatk||s||r.nr_kszt||s||r.L||s||r.W1_L1||s||r.W2_L2||s||r.H||s||r.H1||s||r.H2||s||r.R||s||r.R1||s||r.R2||s||r.R3||s||r.T1_b1||s||r.T2_B2||s||r.T3_B3||s||r.T4||s;
  end if;
  return vlinia;
END PAR_KSZ_DC;

/
--------------------------------------------------------
--  DDL for Function PAR_KSZ_DOCEL
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "PAR_KSZ_DOCEL" (p_nrKompZlec in number, p_nrPoz in NUMBER, p_nrWar IN NUMBER)
RETURN VARCHAR2 AS 
  vlinia ZLEC_TYP.LINIA%TYPE;  
  vtyp integer;
  s char := ':';
  r spisz%ROWTYPE;
BEGIN
  -- czy pozycja z rysunkiem DXF
  select * into r from spisz where nr_kom_zlec=p_nrKompZlec and nr_poz=p_nrPoz;
  if r.nr_komp_rys>0 then
    --zwraca parametry ksztatltu dla zadanej warstwy ze zlectyp
    select nr_zlectyp(p_nrwar) into vtyp from dual;
    select linia into vlinia from zlec_typ where NR_KOMP_ZLEC=p_nrKompZlec and NR_POZ=p_nrPoz and typ=vtyp;
    -- drugi |
    vlinia := STRTOKEN(vlinia,1,'|');
    -- drugi ;
    vlinia := STRTOKEN(vlinia,2,';'); 
  elsif r.nr_kszt>0 then
    --zwraca parametry ksztaltu ze spisz
    vlinia :=   r.nrkatk||s||r.nr_kszt||s||r.L||s||r.W1_L1||s||r.W2_L2||s||r.H||s||r.H1||s||r.H2||s||r.R||s||r.R1||s||r.R2||s||r.R3||s||r.T1_b1||s||r.T2_B2||s||r.T3_B3||s||r.T4||s;
  end if;
  return vlinia;
END PAR_KSZ_DOCEL;

/
--------------------------------------------------------
--  DDL for Function PAR_KSZ_POZ
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "PAR_KSZ_POZ" (p_nrKompZlec in number, p_nrPoz in NUMBER)
RETURN VARCHAR2 AS 
  vlinia varchar(1000);
  s char := ':';
  r spisz%ROWTYPE;
BEGIN
  select * into r from spisz where nr_kom_zlec=p_nrKompZlec and nr_poz=p_nrPoz;
--zwraca parametry ksztaltu ze spisz
  vlinia := r.nrkatk||s||r.nr_kszt||s||r.L||s||r.W1_L1||s||r.W2_L2||s||r.H||s||r.H1||s||r.H2||s||r.R||s||r.R1||s||r.R2||s||r.R3||s||r.T1_b1||s||r.T2_B2||s||r.T3_B3||s||r.T4||s;
  return vlinia;
END PAR_KSZ_POZ;

/
--------------------------------------------------------
--  DDL for Function POLICZ_PUNKTY_KON2
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "POLICZ_PUNKTY_KON2" (
 p_nr_kon zamow.nr_kon%TYPE,
 p_gr_tow numeric,
 p_mnozyc NUMERIC
)
return numeric
as
 gr numeric;
 suma numeric;
 ile numeric;
 v_gr_tow numeric;
 v_mnoznik float;
 v_zakresod varchar(10);
 v_zakresdo varchar(10);
 v_dataod date;
 v_datado date;
 CURSOR GrupyTowCursor is
  select nr_komp,mnoznik,zakresod,zakresdo,dataod,datado
  from ecutter_grupytow;
begin
  suma := 0;
  
  open GrupyTowCursor;
  loop
    fetch GrupyTowCursor into
    v_gr_tow,v_mnoznik,v_zakresod,v_zakresdo,v_dataod,v_datado;
    exit when GrupyTowCursor%NOTFOUND;

		if v_gr_tow=p_gr_tow or p_gr_tow=0 then
     select sum(p.pow_jed_fak) into gr from spise s
      left join zamow z on z.nr_kom_zlec=s.nr_komp_zlec
      left join spisz p on p.nr_kom_zlec=s.nr_komp_zlec and p.nr_poz=s.nr_poz
      left join struktury st on st.kod_str=p.kod_str
      where z.nr_kon=p_nr_kon and z.status in ('P','Z','K') and wyroznik='Z' and
       s.data_wyk>=v_dataod and s.data_wyk<=v_datado and
       st.gr_tow>=v_zakresod and st.gr_tow<=v_zakresdo and 
       st.gr_tow<>'H19' and st.gr_tow<>'Z48' and st.gr_tow<>'F19' and
       s.zn_wyk in (1,2);
    if gr is null then
      gr := 0;
    end if;
    if p_mnozyc=1 then
      gr := gr*v_mnoznik;
    end if;
    suma := suma+gr;
  end if;

  end loop;
  close GrupyTowCursor;

  return suma;
end;

/
--------------------------------------------------------
--  DDL for Function POWLOKAAKTYWNA_WAR
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "POWLOKAAKTYWNA_WAR" (pNrKompZlec number, pNrPoz number, pNrWar number) return number 
as
  vPow varchar2(10);
  vNrKompZlec number;
  vNrPoz number;
  vNrWar number;
  vIdPoz number;
  c number;
begin
-- sprawdz czy zlecenie nie zawiera polproduktow
  select count(*) into c from v_zlecenia_wew_pozycje where NR_KOMP_ZLEC_ORG=pNrKompZlec and NR_POZ_ORG=pNrPoz and NR_WAR_ORG=pNrWar;
  if c>0 then
-- warstwa jest polproduktem
    select NR_KOMP_ZLEC,NR_POZ,NR_WAR into vNrKompZlec,vNrPoz,vNrWar from v_zlecenia_wew_pozycje where NR_KOMP_ZLEC_ORG=pNrKompZlec and NR_POZ_ORG=pNrPoz and NR_WAR_ORG=pNrWar;
  else
-- warstwa nie jest polproduktem
    vNrKompZlec := pNrKompZlec;
    vNrPoz := pNrPoz; 
    vNrWar := pNrWar;
  end if;
  select nvl(lpad(il_odc_pion,10,'0'),'0000000000') into vPow from spisd where nr_kom_zlec=vNrKompZlec and nr_poz=vNrPoz and strona=0 and zn_War='Sur' and do_war=vNrWar;
  if (substr(vPow,4,1)='1') and (substr(vPow,2,1)='1') then
    return 3;
  elsif substr(vPow,4,1)='1' then
    return 2;
  elsif substr(vPow,2,1)='1' then
    return 1;
  else
    return 0;
  end if;
end;

/
--------------------------------------------------------
--  DDL for Function QUERY2LIST
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "QUERY2LIST" (pQUERY IN VARCHAR2, pSEP IN CHAR DEFAULT ',') RETURN VARCHAR2
AS 
  TYPE tN is table of number(10,2);
  TYPE tC is table of varchar2(500);
  vListaNum tN;
  vListaStr tC;
  vLista VARCHAR2(4000);
 BEGIN
  EXECUTE IMMEDIATE pQUERY
  --BULK COLLECT INTO vListaNum;
  BULK COLLECT INTO vListaStr;
  vLista:=pSEP;
  FOR n in 1 .. vListaStr.count() LOOP
    vLista:=trim(vLista)||pSEP||trim(vListaStr(n));
  END LOOP;
  RETURN ltrim(vLista,pSEP);
 EXCEPTION when OTHERS then
  RETURN SQLERRM;
 END QUERY2LIST;

/
--------------------------------------------------------
--  DDL for Function REP_STR
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "REP_STR" (STR1 IN VARCHAR2, STR_NEW IN VARCHAR2, POS_FROM IN NUMBER) 
RETURN VARCHAR2 AS 
BEGIN
  --zastepuje w STR1 fragment od znaku nr POS_FROM ci¹giem STR_NEW
  RETURN substr(STR1,1,POS_FROM-1)||STR_NEW||substr(STR1,POS_FROM+length(STR_NEW),length(STR1)-(POS_FROM-1)-length(STR_NEW));
END REP_STR;

/
--------------------------------------------------------
--  DDL for Function SPISE_VS_WZ_ERR
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "SPISE_VS_WZ_ERR" (pNR_KOMP_ZLEC IN NUMBER, pNR_POZ IN NUMBER DEFAULT 0)
RETURN NUMBER
AS
ile_poz NUMBER(10);
BEGIN
Select count(distinct e.nr_poz) Into ile_poz
From
(
select nr_komp_zlec, nr_poz, nr_sped, max(data_sped) data_sped, count(1) il,
nr_k_WZ, nr_poz_WZ,
(select count(1) from pozdok where typ_dok='WZ' and nr_komp_baz=nr_komp_zlec and nr_poz_zlec=spise.nr_poz and storno=0) il_poz_WZ
from spise
where nr_komp_zlec=pNR_KOMP_ZLEC  and (pNR_POZ=0 or nr_poz=pNR_POZ)
group by nr_komp_zlec, nr_poz, nr_sped, nr_k_WZ, nr_poz_WZ
order by 1,2,3
) e
Left join pozdok on typ_dok='WZ' and nr_komp_dok=nr_k_WZ and pozdok.nr_poz=nr_poz_WZ and nr_komp_baz=nr_komp_zlec and nr_poz_zlec=e.nr_poz and storno=0
Where
--blad gdy szyby s¹ w spedycjach i nie maja przypisanego WZ a WZ istniej¹
nr_sped>0 and nvl(ilosc_jr,0)<>il and il_poz_WZ>1
--szyby bez spedycji moga miec WZ, ale pod warunkiem ¿e cala pozycja ma nr_k_WZ>0
or nr_sped=0 and nvl(ilosc_jr,0)>0 and (select count(1) from spise where nr_komp_zlec=e.nr_komp_zlec and nr_poz=e.nr_poz and nr_k_WZ=0)>0;
RETURN ile_poz;
END SPISE_VS_WZ_ERR;

/
--------------------------------------------------------
--  DDL for Function STRONA_POWLOKI_OBROT
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "STRONA_POWLOKI_OBROT" (pFUN NUMBER, pPOWLOKA NUMBER, pFORMATKA NUMBER, pKTORA_WAR NUMBER) RETURN NUMBER AS
vStrPowl  NUMBER(1):=0;
vCzyObrot NUMBER(1):=0;
BEGIN
FOR p IN (select * from slow_powlok where nr_powloki=pPOWLOKA)
LOOP
IF pFORMATKA=1 THEN
IF p.CZY_ZEWN in (1)   THEN vStrPowl:=1; END IF;
IF p.CZY_ZEWN in (0,2) THEN vStrPowl:=3; END IF;
ELSE
IF p.CZY_WEWN=1 AND pKTORA_WAR=1 OR p.CZY_WEWN=2 AND pKTORA_WAR>1 THEN
vStrPowl:=3;
ELSIF p.CZY_WEWN=2 AND pKTORA_WAR=1 OR p.CZY_WEWN=1 AND pKTORA_WAR>1 THEN
vStrPowl:=1;
ELSIF p.CZY_ZEWN=1 AND pKTORA_WAR=1 OR p.CZY_ZEWN=2 AND pKTORA_WAR>1 THEN
vStrPowl:=3;
ELSIF p.CZY_ZEWN=2 AND pKTORA_WAR=1 OR p.CZY_ZEWN=1 AND pKTORA_WAR>1 THEN
vStrPowl:=1;
END IF;
END IF;
vCzyObrot:=1; --nie
IF p.CZY_ODWRACANIE=1 AND vStrPowl=3 OR p.CZY_ODWRACANIE=0 AND vStrPowl=1 OR p.CZY_ODWRACANIE=2 AND pKTORA_WAR>1 THEN
vCzyObrot:=2;
END IF;
END LOOP;
--zwracanie strony powloki 1-lewa 3-prawa
IF pFUN=1 THEN
RETURN vStrPowl;
--zwracanie czy obrot 1-nie 2-tak
ELSIF pFUN=2 THEN
RETURN vCzyObrot;
ELSE
RETURN -1;
END IF;
END STRONA_POWLOKI_OBROT;

/
--------------------------------------------------------
--  DDL for Function STRTOKEN
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "STRTOKEN" (
   the_list  varchar2,
   the_index number,
   delim     varchar2 := '|'
)
   return    varchar2
is
   start_pos number;
   end_pos   number;
begin
   if the_index = 1 then
       start_pos := 1;
   else
       start_pos := instr(the_list, delim, 1, the_index - 1);
       if start_pos = 0 then
           return null;
       else
           start_pos := start_pos + length(delim);
       end if;
   end if;

   end_pos := instr(the_list, delim, start_pos, 1);

   if end_pos = 0 then
       return substr(the_list, start_pos);
   else
       return substr(the_list, start_pos, end_pos - start_pos);
   end if;

end strtoken;

/
--------------------------------------------------------
--  DDL for Function STRTOKENN
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "STRTOKENN" (
   the_list  varchar2,
   the_index number,
   delim     varchar2 := '|',
   format    varchar2 := '99999999.99',
   sep10     varchar2 := '.'
)
   return    number
is
begin
  if sep10='.' then
      return to_number(strtoken(the_list,the_index,delim),format);
  else
      return to_number(replace(strtoken(the_list,the_index,delim),sep10,'.'),format);
  end if;
end strtokenN;

/
--------------------------------------------------------
--  DDL for Function WSP_4ZAKR
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "WSP_4ZAKR" (pNK_INST IN NUMBER, pPOW IN NUMBER, pIDENT_BUD IN VARCHAR2, pNR_KAT IN NUMBER DEFAULT 0) RETURN NUMBER AS
CURSOR c1 IS
SELECT nr_komp_inst, case when round(pPOW,4) between zakr_1_min and zakr_1_max then znak_op1
when round(pPOW,4) between zakr_2_min and zakr_2_max then znak_op2
when round(pPOW,4) between zakr_3_min and zakr_3_max then znak_op3
when round(pPOW,4) between zakr_4_min and zakr_4_max then znak_op4
else '*' end znak_op,
case when round(pPOW,4) between zakr_1_min and zakr_1_max then wsp_przel1
when round(pPOW,4) between zakr_2_min and zakr_2_max then wsp_przel2
when round(pPOW,4) between zakr_3_min and zakr_3_max then wsp_przel3
when round(pPOW,4) between zakr_4_min and zakr_4_max then wsp_przel4
else 1 end wsp_przel
FROM parinst I
LEFT JOIN wspinst W USING (nr_komp_inst)
WHERE nr_komp_inst=pNK_INST
AND (nr_znacznika=0 OR substr(pIDENT_BUD,nr_znacznika,1)='1' AND
(pNR_KAT=0 OR nr_znacznika not in (1,2,9) OR I.ty_inst not in ('A C','R C')
OR nr_znacznika=(select to_number(substr(znacz_pr,1,greatest(1,instr(znacz_pr,'.')-1)))
from katalog
where nr_kat=pNR_KAT)
)
)
--AND round(pPOW,4) between zakres_od and zakres_do
ORDER BY decode(case when round(pPOW,4) between zakr_1_min and zakr_1_max then znak_op1
when round(pPOW,4) between zakr_2_min and zakr_2_max then znak_op2
when round(pPOW,4) between zakr_3_min and zakr_3_max then znak_op3
when round(pPOW,4) between zakr_4_min and zakr_4_max then znak_op4
else '*' end,
'+',1,'-',2,'*',3,'/',4,'<',5,'>',6,9);
rec c1%ROWTYPE;
vWsp NUMBER :=null;
BEGIN
OPEN c1;
LOOP
FETCH c1 INTO rec;
EXIT WHEN c1%NOTFOUND;
IF vWsp is null THEN
vWsp:=case when rec.znak_op in('+','-','>') then 0
when rec.znak_op in('*','/') then 1
when rec.znak_op in('<') then 99
else 1 end;
END IF;
vWsp:=case rec.znak_op when '+' then vWsp+rec.wsp_przel
when '-' then vWsp-rec.wsp_przel
when '*' then vWsp*rec.wsp_przel
when '/' then vWsp/rec.wsp_przel
when '>' then greatest(vWsp,rec.wsp_przel)
when '<' then least(vWsp,rec.wsp_przel)
else vWsp end;
END LOOP;
IF vWsp=0 THEN vWsp:=1; END IF;
RETURN nvl(vWsp,1);
END WSP_4ZAKR;

/
