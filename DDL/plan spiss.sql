--CREATE SYNONYM PINST_DODN FOR PINST_DOD;
--DROP FUNCTION WSP_12ZAKR
CREATE SYNONYM WSP_12ZAKR FOR WSP_4ZAKR;
--CREATE SYNONYM SPISS FOR SPISS_V;

create or replace FUNCTION WSP_4ZAKR (pNK_INST IN NUMBER, pPOW IN NUMBER, pIDENT_BUD IN VARCHAR2, pNR_ZEST IN NUMBER DEFAULT 0) RETURN NUMBER AS
 vWsp NUMBER(5,2) :=null;
 vWspPlus NUMBER(5,2) :=null;
 vWspMinus NUMBER(5,2) :=null;
 vWspGT NUMBER(5,2) :=null;
 vWspLT NUMBER(5,2) :=null;
BEGIN
 SELECT nvl(sum(case when znak_op='+' then wsp_przel else 0 end),0),
        nvl(sum(case when znak_op='-' then wsp_przel else 0 end),0),
        nvl(max(case when znak_op='>' then wsp_przel else 0 end),0),
        nvl(min(case when znak_op='<' then wsp_przel else 999 end),999),
        --MUL (wsp) = EXP (SUM (LN (wsp)))
        nvl(round(exp(sum(ln(case when wsp_przel<=0 then 1 when znak_op='*' then wsp_przel when znak_op='/' then 1/wsp_przel else 1 end))),2),1)
   INTO vWspPlus, vWspMinus, vWspGT, vWspLT, vWsp
 FROM 
 (select case when round(pPOW,4) between zakr_1_min and zakr_1_max then znak_op1
              when round(pPOW,4) between zakr_2_min and zakr_2_max then znak_op2
              when round(pPOW,4) between zakr_3_min and zakr_3_max then znak_op3
              when round(pPOW,4) between zakr_4_min and zakr_4_max then znak_op4
              else '*' end znak_op,
         case when round(pPOW,4) between zakr_1_min and zakr_1_max then wsp_przel1
              when round(pPOW,4) between zakr_2_min and zakr_2_max then wsp_przel2
              when round(pPOW,4) between zakr_3_min and zakr_3_max then wsp_przel3
              when round(pPOW,4) between zakr_4_min and zakr_4_max then wsp_przel4
              else 1 end wsp_przel
  from parinst I
  left join wspinst W using (nr_komp_inst)
  where nr_komp_inst=pNK_INST and znak_op1 in ('+','-','<','>','*')
    and substr('1'||pIDENT_BUD,nr_znacznika+1,1)='1'); --uwzgl. NR_ZNACZNIKA=0
 --vWsp:=1;
 vWsp:=vWsp+vWspPlus-vWspMinus;
 vWsp:=greatest(vWsp,vWspGT);
 vWsp:=least(vWsp,vWspLT);
 --IF vWsp=0 THEN vWsp:=1; END IF;
 RETURN nvl(nullif(vWsp,0),1);
END WSP_4ZAKR;
/

create or replace FUNCTION WSP_HO (pZRODLO CHAR, pNK_ZLEC NUMBER, pPOZ NUMBER, pETAP NUMBER, pWAR NUMBER) RETURN NUMBER
AS
 vSumaWspHart NUMBER;
BEGIN
 RETURN 0;
 --@P
 select sum(wsp_har) into vSumaWspHart
 from spiss S
 left join katalog K on K.nr_kat=S.nr_kat
 where S.zrodlo=pZRODLO and S.nr_komp_zr=pNK_ZLEC and S.nr_kol=pPOZ and S.etap=pETAP and S.war_od=pWAR and S.zn_war='Obr'; 
 
 RETURN nvl(vSumaWspHart,0);
END  WSP_HO;
/

create or replace FUNCTION WSP_WG_TYPU_INST (pTYP_INST VARCHAR2, pWSP_12ZAKR NUMBER, pWSP_C_M NUMBER, pWSP_HAR NUMBER, pWSP_HO NUMBER, pWSP_DOD NUMBER, pZNAK_DOD CHAR)
--/*wa¿ne dla HAR - WSP_HO*/ pNK_ZLEC NUMBER DEFAULT 0, pPOZ NUMBER DEFAULT 0, pETAP NUMBER DEFAULT 0, pWAR_OD NUMBER DEFAULT 0, pZT CHAR DEFAULT 'Z') 
RETURN NUMBER AS
 vWsp NUMBER(7,4) :=0;
BEGIN
 vWsp :=
  CASE
    WHEN trim(pTYP_INST)='A C' THEN pWSP_12ZAKR*pWSP_C_M*pWSP_DOD
    WHEN trim(pTYP_INST)='SZP' THEN pWSP_12ZAKR*pWSP_C_M
    WHEN trim(pTYP_INST)='HAR' THEN pWSP_12ZAKR*(pWSP_HAR + pWSP_HO)
    WHEN trim(pTYP_INST)='MON' THEN pWSP_12ZAKR
    ELSE CASE trim(pZNAK_DOD) WHEN '*' THEN pWSP_12ZAKR*pWSP_DOD WHEN '/' THEN pWSP_12ZAKR/pWSP_DOD WHEN '+' THEN pWSP_12ZAKR+pWSP_DOD WHEN '-' THEN pWSP_12ZAKR-pWSP_DOD ELSE pWSP_12ZAKR END
  END;
 RETURN Round(nvl(vWsp,1),4);
END WSP_WG_TYPU_INST;
/

create or replace FUNCTION "ELEMENT_LISTY" (pLISTA in varchar2, pNR in number, pSEP CHAR DEFAULT ',') return NUMBER as 
BEGIN
  RETURN case when instr(pSEP||pLISTA||pSEP,pSEP||pNR||pSEP)>0
              then 1 else 0
         end;
END ELEMENT_LISTY;
/

create or replace FUNCTION "STRTOKEN" (
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

create or replace FUNCTION "STRTOKENN" (
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
      return to_number(nvl(strtoken(trim(the_list),the_index,delim),'0'),format);
  else
      return to_number(replace(nvl(strtoken(trim(the_list),the_index,delim),'0'),sep10,'.'),format);
  end if;
end strtokenN;
/

CREATE OR REPLACE FORCE VIEW V_SPISS ("ZRODLO", "NR_KOM_ZLEC", "NR_POZ", "ETAP", "WAR_OD", "WAR_DO", "NR_PORZ", "ZN_WAR", "INDEKS", "SZER", "WYS", "POW", "GRUB", "WAGA", "NK_OBR", "KOLEJN_OBR", "NK_INST", "TYP_INST", "NR_INST_POW", "KOLEJNOSC_Z_GRUPY", "GR_AKT", "IDENT_BUD", "IL_OBR", "WSP_C_M", "WSP_HAR", "WSP_HO", "WSP_12ZAKR", "ZNAK_DOD", "WSP_DOD", "KRYT_WYM_DOD", "KRYT_GRUB_PAK", "KRYT_WAGA_PAK", "KRYT_WAGA_1MB", "KRYT_WAGA_ELEM", "KRYT_WYM_MIN", "KRYT_WYM_MAX", "KRYT_ATRYB", "KRYT_ATRYB_WYL", "KRYT_DOW", "KRYT_SUMA", "KRYT_KTORE", "KRYT_WYK", "OBSL_TECH", "INST_STD", "INST_WYBR", "INST_JAKA", "WSP_PRZEL", "WSP_ALT")
AS
  SELECT V.zrodlo,V.nr_kom_zlec,V.nr_poz,V.etap,V.war_od,V.war_do,V.nr_porz,V.zn_war,V.indeks,V.szer,V.wys,V.pow,V.grub,V.waga,V.nk_obr,V.kolejn_obr,
       V.nk_inst,V.ty_inst,V.nr_inst_pow,V.kolejnosc_z_grupy,V.gr_akt,V.ident_bud,V.il_obr,V.wsp_c_m,V.wsp_har,V.wsp_HO,V.wsp_12zakr,V.znak_dod,V.wsp_dod,
       V.kryt_wym_dod,V.kryt_grub_pak,V.kryt_waga_pak,V.kryt_waga_1mb,V.kryt_waga_elem,V.kryt_wym_min,V.kryt_wym_max,V.kryt_atryb,V.kryt_atryb_wyl,V.kryt_oper, 
       (kryt_grub_pak+kryt_waga_pak+kryt_waga_1mb+kryt_waga_elem+kryt_wym_min+kryt_wym_max+kryt_wym_dod+kryt_atryb_wyl+0+kryt_oper)*decode(gr_akt,2,-1,1) kryt_suma,
        kryt_grub_pak*0.1+kryt_waga_pak*0.01+kryt_waga_1mb*0.001+kryt_waga_elem*0.0001+kryt_wym_min*0.00001+kryt_wym_max*0.000001+kryt_wym_dod*0.000001*0.1+kryt_atryb_wyl*0.000001*0.01+0+kryt_oper*0.000001*0.0001 kryt_ktore,
       case when (max(kryt_grub_pak+kryt_waga_pak+kryt_waga_1mb+kryt_waga_elem+kryt_wym_min+kryt_wym_max+kryt_wym_dod+kryt_atryb_wyl+0+kryt_oper) over (partition by V.nr_kom_zlec, V.nr_poz, V.nr_porz))>0
            then case when (min(kryt_grub_pak+kryt_waga_pak+kryt_waga_1mb+kryt_waga_elem+kryt_wym_min+kryt_wym_max+kryt_wym_dod+kryt_atryb_wyl+0+kryt_oper) over (partition by V.nr_kom_zlec, V.nr_poz, V.nr_porz))>0
                      then 0
                      when (min(decode(nk_inst,inst_wybr,kryt_grub_pak+kryt_waga_pak+kryt_waga_1mb+kryt_waga_elem+kryt_wym_min+kryt_wym_max+kryt_wym_dod+kryt_atryb_wyl+0+kryt_oper,0)) over (partition by V.nr_kom_zlec, V.nr_poz, V.nr_porz))>0
                      then 1
                      else 2 end
            else 3 end kryt_wyk,
       V.obsl_tech, V.inst_std, V.inst_wybr, V.wsp_jaki inst_jaka,
       nvl(WSP_WG_TYPU_INST(V.ty_inst, V.wsp_12zakr, V.wsp_c_m, V.wsp_har, V.wsp_HO, V.wsp_dod, V.znak_dod),1) wsp_przel, V.wsp_alt
FROM (
SELECT S.zrodlo, S.nr_komp_zr nr_kom_zlec, S.nr_kol nr_poz, S.etap, S.war_od, S.war_do, S.nr_porz, S.zn_war, S.indeks, S.szer, S.wys, S.pow, S.grub, S.waga_jedn*S.pow waga,
       S.nk_obr, S.zn_plan kolejn_obr, S.nk_inst, I.ty_inst, I.nr_inst_pow, S.kolejnosc_z_grupy, S.gr_akt, S.ident_bud,
       S.inst_std, W.jaki wsp_jaki, W.wsp_alt,
       case when W.jaki=3 then W.nr_komp_inst else (select nvl(max(W.nr_komp_inst),0) from wsp_alter W where W.nr_kom_zlec=S.nr_komp_zr and W.nr_poz=S.nr_kol and W.nr_porz_obr=S.nr_porz and W.jaki=3) end inst_wybr,
       /*decode(S.zn_war,'Obr',S.il_obr,S.pow)*/S.il_obr il_obr, nvl(wsp_c_m,1) wsp_c_m, nvl(wsp_har,1) wsp_har,
       nvl(decode(trim(I.ty_inst),'HAR',WSP_HO(S.zrodlo,S.nr_komp_zr,S.nr_kol,S.etap,S.war_od),0),0) wsp_HO,
       nvl(wsp_12zakr(S.nk_inst,S.pow,S.ident_bud),1) wsp_12zakr,
       nvl(nvl(D1.znak,nvl(D2.znak,nvl(D3.znak,D0.znak))),'*') znak_dod, nvl(nvl(D1.wsp_przel,nvl(D2.wsp_przel,nvl(D3.wsp_przel,D0.wsp_przel))),1) wsp_dod,
       case when nvl(D1.szer_max,nvl(D2.szer_max,nvl(D3.szer_max,nvl(D0.szer_max,0))))>0 
             and least(S.szer,S.wys)>nvl(D1.szer_max,nvl(D2.szer_max,nvl(D3.szer_max,nvl(D0.szer_max,9999)))) then 1 else 0 end + 
       case when nvl(D1.wys_max,nvl(D2.wys_max,nvl(D3.wys_max,nvl(D0.wys_max,0))))>0
             and greatest(S.szer,S.wys)>nvl(D1.wys_max,nvl(D2.wys_max,nvl(D3.wys_max,nvl(D0.wys_max,9999)))) then 1 else 0 end kryt_wym_dod,
       case when I.max_grub_pak=0 or I.max_grub_pak>=S.grub then 0 else 1 end kryt_grub_pak,
       case when I.max_waga_pak=0 or I.max_waga_pak>=S.waga_jedn*S.pow then 0 else 1 end kryt_waga_pak,
       case when I.max_waga_1mb=0 or I.max_waga_1mb>=least(S.szer,S.wys)*0.001*least(1,greatest(S.szer,S.wys)*0.001)*S.waga_jedn then 0 else 1 end kryt_waga_1mb,
       case when I.max_waga_el=0 or I.max_waga_el>=S.waga_elem then 0 else 1 end kryt_waga_elem,
       case when I.szer_min+I.wys_min>0 and (S.bok_min<I.szer_min or S.bok_max<I.wys_min) then  1 else 0 end kryt_wym_min,
       case when I.szer_max+I.wys_max>0 and (S.bok_min>I.szer_max or S.bok_max>I.wys_max) then  1 else 0 end kryt_wym_max,
       decode(to_number(nvl(replace(I.ind_bud,' ','0'),'0')),0,2, atryb_match(I.ind_bud,S.ident_bud)) kryt_atryb,
       decode(to_number(nvl(replace(I.ident_bud_wyl,' ','0'),'0')),0,0, atryb_match(I.ident_bud_wyl,S.ident_bud)) kryt_atryb_wyl, 
       nvl(decode(T.obsl,0,1,0),0) kryt_oper,
       nvl(decode(TKP.obsl,0,8,TKP.obsl),0) obsl_tech
FROM
(SELECT S.zrodlo, S.nr_komp_zr, S.nr_kol, S.id_rek, S.etap, S.war_od, S.war_do, S.nr_porz, S.zn_war, S.zn_plan, S.szer, S.wys, S.szer*S.wys*0.000001 pow, S.indeks, S1.ident_bud, S.il_obr, S.inst_std,
        least(S.szer,S.wys) bok_min, greatest(S.szer,S.wys) bok_max,
        nvl(K.grubosc,Str.gr_pak) grub, K.wsp_c_m, K.wsp_har,
        nvl(K.waga,Str.waga) waga_jedn, nvl(K.waga*S.szer*S.wys*0.000001,0) waga_elem,
        decode(S.zn_war,'Obr',S.nr_kat,0) nr_czynn, S.nk_obr,
        nvl(G.nr_komp_inst,S.inst_std) nk_inst,
        nvl(G.kolejnosc,0) kolejnosc_z_grupy, nvl(G.akt,0) gr_akt
 FROM spiss S
 --link do rekordu warstwy
 LEFT JOIN spiss S1 ON S1.zrodlo=S.zrodlo and S1.nr_komp_zr=S.nr_komp_zr and S1.nr_kol=S.nr_kol and S1.etap=S.etap and S1.czy_war=1 and S.war_od between S1.war_od and S1.war_do and S1.strona=0
 --linki do pobrania wagi
 LEFT JOIN katalog K on K.typ_kat=S.indeks
 LEFT JOIN struktury Str on Str.kod_str=S.indeks
 --link do pobrania instalacji dla obróbek
 LEFT JOIN gr_inst_dla_obr G ON S.nk_obr=G.nr_komp_obr
 --wybierane s¹ wszystkie skladniki, które maj¹ byæ planowane
 WHERE S.zrodlo in ('T','Z') and S.nk_obr>0 and S.zn_plan>0 
 --zamiast poni¿szych zerowanie ZN_PLAN w proc. SPISS_MAT
   --AND NOT (S.etap=1 and S.rodz_sur='POL' and S.zn_war='Obr' and S.nr_porz>100) --obrobki ze SPISD nie planowane na pólprodukcie tylko w zlec wew.
   --AND NOT (S.nk_obr=1 and substr(S1.ident_bud,19,1)='1')  --usuniêcie ZAT w EFF, bo w strukturach SZKLO\Z\H; podobny warunek w GEN_LWYC
) S
--linki
LEFT JOIN wsp_alter W ON W.nr_kom_zlec=S.nr_komp_zr and W.nr_poz=S.nr_kol and W.nr_porz_obr=S.nr_porz and W.nr_komp_inst=S.nk_inst and W.nr_zestawu=0
--linki do wsp. dodatk. (4x, bo mo¿enie byæ rekordów odpowaidaj¹cych nr obróbki i/lub typowi katal.)
LEFT JOIN pinst_dodn D1 ON D1.nr_komp_inst=S.nk_inst and D1.typ_kat=S.indeks and D1.nr_komp_obr=S.nk_obr --and S.grub between D1.grub_od and D1.grub_do
LEFT JOIN pinst_dodn D2 ON D2.nr_komp_inst=S.nk_inst and D2.typ_kat=S.indeks and D2.nr_komp_obr=0 --and S.grub between D2.grub_od and D2.grub_do
LEFT JOIN pinst_dodn D3 ON D3.nr_komp_inst=S.nk_inst and trim(D3.typ_kat) is null and D3.nr_komp_obr=S.nk_obr and S.grub between D3.grub_od and D3.grub_do
LEFT JOIN pinst_dodn D0 ON D0.nr_komp_inst=S.nk_inst and trim(D0.typ_kat) is null and D0.nr_komp_obr=0 and S.grub between D0.grub_od and D0.grub_do
--link do spr. kryteriów z parametrów instalacji
LEFT JOIN parinst I ON I.nr_komp_inst=S.nk_inst 
--link do pobranie ostrzezenia operatora
LEFT JOIN tech_kontr_poz T ON T.nr_komp_zap=0 and T.nr_komp_zlec=S.nr_komp_zr and T.id_rek=S.id_rek and T.nr_kolejny=S.nr_porz
--link do pobrania decyzji dla kontroli poprawnoœci techn/      
LEFT JOIN (select nr_komp_zlec, max(nr_komp_zap) nr_komp_zap_ost from tech_kontr group by nr_komp_zlec) TK ON TK.nr_komp_zlec=S.nr_komp_zr
LEFT JOIN tech_kontr_poz TKP ON TKP.nr_komp_zap=TK.nr_komp_zap_ost AND TKP.nr_komp_zlec=S.nr_komp_zr AND TKP.id_rek=S.id_rek AND TKP.nr_kolejny=S.nr_porz AND TKP.nr_komp_instal=S.nk_inst
) V;
--V_SPISS
/

--drop table l_wyc2;
CREATE TABLE "L_WYC2" 
(	"NR_KOM_ZLEC" NUMBER(10,0) DEFAULT 0 NOT NULL,
	"NR_POZ_ZLEC" NUMBER(10,0) DEFAULT 0 NOT NULL,
	"NR_SZT" NUMBER(10,0) DEFAULT 0 NOT NULL,
	"NR_WARST" NUMBER(2,0) DEFAULT 0 NOT NULL,
	"WAR_DO" NUMBER(2,0) DEFAULT 0 NOT NULL,
	"NR_OBR" NUMBER(10,0) DEFAULT 0 NOT NULL,
	"NR_PORZ_OBR" NUMBER(10,0) DEFAULT 0 NOT NULL,
	"NR_INST_PLAN" NUMBER(10,0) DEFAULT 0 NOT NULL,
	"NR_INST_WYK" NUMBER(10,0) DEFAULT 0 NOT NULL,
	"NR_ZM_PLAN" NUMBER(10,0) DEFAULT 0 NOT NULL ENABLE,
	"NR_ZM_WYK" NUMBER(10,0) DEFAULT 0 NOT NULL,
	"KOLEJN" NUMBER(3,0) DEFAULT 0 NOT NULL ENABLE,
	"FLAG" NUMBER(1,0) DEFAULT 0 NOT NULL
   );
CREATE UNIQUE INDEX "WG_OBR_LWYC2" ON "L_WYC2" ("NR_KOM_ZLEC", "NR_POZ_ZLEC", "NR_SZT", "NR_PORZ_OBR");
CREATE INDEX "WG_NR_ZM_PLAN_LWYC2" ON "L_WYC2" ("NR_KOM_ZLEC", "NR_POZ_ZLEC", "NR_SZT", "NR_ZM_PLAN", "NR_WARST");
CREATE INDEX "L_WYC2_WG_ZM_WYK" ON L_WYC2 (NR_ZM_WYK, NR_INST_WYK);
CREATE INDEX "L_WYC2_WG_ZM_PLAN" ON L_WYC2 (NR_ZM_PLAN, NR_INST_PLAN);
--CREATE INDEX "WG_INST_LWYC2" ON "L_WYC2" ("NR_INST_PLAN", "NR_ZM_PLAN", "NR_OBR", "NR_KOM_ZLEC", "NR_POZ_ZLEC", "NR_WARST", "NR_SZT");
--CREATE INDEX "WG_ZM_LWYC2" ON "L_WYC2" ("NR_ZM_PLAN", "NR_OBR", "NR_INST_PLAN", "NR_KOM_ZLEC", "NR_POZ_ZLEC", "NR_WARST", "NR_SZT") ;
--CREATE INDEX "WG_NR_OBR_LWYC2" ON "L_WYC2" ("NR_OBR", "NR_ZM_PLAN", "NR_INST_PLAN", "NR_KOM_ZLEC", "NR_POZ_ZLEC", "NR_WARST", "NR_SZT");

create or replace PROCEDURE LWYC2_SAVE (pNR_KOM_ZLEC IN NUMBER, pNR_POZ IN NUMBER, pWAR IN NUMBER, pWAR_DO IN NUMBER, pIL_SZT IN NUMBER,
                       pNR_PORZ IN NUMBER, pNR_OBR IN NUMBER, pINST_PLAN IN NUMBER, pKOLEJN IN NUMBER)
AS
 vNR_SZT NUMBER :=0;
BEGIN
  --SELECT count(1) INTO n FROM l_wyc2 WHERE nr_kom_zlec=pNR_KOM_ZLEC AND nr_poz_zlec=pNR_POZ;
  LOOP
    vNR_SZT:=vNR_SZT+1;
    EXIT WHEN vNR_SZT>pIL_SZT;
    INSERT INTO l_wyc2 (nr_kom_zlec, nr_poz_zlec, nr_szt, nr_warst, war_do, nr_porz_obr, nr_obr, nr_inst_plan, kolejn)
                VALUES (pNR_KOM_ZLEC, pNR_POZ, vNR_SZT, pWAR, pWAR_DO, pNR_PORZ, pNR_OBR, pINST_PLAN, pKOLEJN);
  END LOOP;
END LWYC2_SAVE;
/

--NIEPOTRZEBNE przy SPISS jako widoku!
/*create or replace PROCEDURE WPISZ_ATRYBUTY (pZRODLO CHAR, pNK_ZLEC NUMBER, pNR_POZ NUMBER DEFAULT 0, pIDENT_BUD VARCHAR2 DEFAULT null)
AS
 CURSOR cSPISZ IS 
  SELECT nr_poz, ind_bud FROM spisz WHERE nr_kom_zlec=pNK_ZLEC;
 CURSOR cRPZLEC_POZ IS 
  SELECT nr_poz, ind_bud FROM rpzlec_poz WHERE nr_kom_zlec=pNK_ZLEC;
 CURSOR c1 IS
  SELECT nr_znacznika, kat, str, zlec, typ FROM atryb_dod WHERE nr_znacznika>0 ORDER BY 1;
  rec1 c1%ROWTYPE;
  recP cSPISZ%ROWTYPE;
  etap_max NUMBER;
  vIdent VARCHAR2(100);
  atr CHAR(1);
BEGIN
 --dla calego zlecenia rekurencyjne wywonie tej procedury z podaniem pozycji
 IF pNR_POZ=0 THEN
  IF pZRODLO='Z' THEN
   FOR recP IN cSPISZ
    LOOP WPISZ_ATRYBUTY(pZRODLO, pNK_ZLEC, recP.nr_poz, recP.ind_bud); END LOOP;
  ELSIF pZRODLO='T' THEN
   FOR recP IN cRPZLEC_POZ
    LOOP WPISZ_ATRYBUTY(pZRODLO, pNK_ZLEC, recP.nr_poz, recP.ind_bud); END LOOP; 
  END IF;
 --dla pozycji
 ELSE
  SELECT max(etap) INTO etap_max FROM spiss WHERE zrodlo=pZRODLO AND nr_komp_zr=pNK_ZLEC AND nr_kol=pNR_POZ;
  SELECT ident_bud INTO vIdent   FROM spiss WHERE zrodlo=pZRODLO AND nr_komp_zr=pNK_ZLEC AND nr_kol=pNR_POZ AND etap=etap_max AND czy_war=1 AND strona=0;
  OPEN c1;
  LOOP
    FETCH c1 INTO rec1;
    EXIT WHEN c1%NOTFOUND;
    atr:=substr(rpad(trim(pIDENT_BUD),greatest(length(trim(pIDENT_BUD)),rec1.nr_znacznika),'0'),rec1.nr_znacznika,1);
--    IF (rec1.zlec=2 or rec1.typ=1) --poprawiamy atrybuty ustawiane w zleceniu ORAZ wyliczane automatycznie
--        and (atr='1' or atr='0' and rec1.kat<2) THEN --nie cofany atrybutu z Katalogu
    IF atr='1' or rec1.kat<2 and (rec1.zlec=2 or rec1.typ=1) THEN --poprawka 29.02.2016, bo nie ustawial sie atrybut 4.Szpros
     vIdent:=Rep_Str(rpad(trim(vIdent),greatest(length(trim(vIdent)),rec1.nr_znacznika),'0'),atr,rec1.nr_znacznika);
    END IF;
  END LOOP;
  CLOSE c1;
  UPDATE spiss SET ident_bud=vIdent
  WHERE zrodlo=pZRODLO AND nr_komp_zr=pNK_ZLEC AND nr_kol=pNR_POZ AND etap=etap_max AND czy_war=1;
 END IF;
EXCEPTION WHEN OTHERS THEN
  IF c1%ISOPEN THEN CLOSE c1; END IF;
  IF cSPISZ%ISOPEN THEN CLOSE cSPISZ; END IF;
  RAISE;
END WPISZ_ATRYBUTY;
/*/

create or replace PROCEDURE ZAPISZ_WSP (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pNR_ZEST NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0)
AS
 ileZest NUMBER;
BEGIN
 IF pNR_ZEST=-1 THEN --wszystkie zestawy
  --@V WPISZ_ATRYBUTY('Z', pNK_ZLEC);
  SELECT to_number(nvl(trim(max(wartosc)),'1'),'9') INTO ileZest FROM param_t WHERE kod=154;
  IF ileZest>0 THEN
   FOR vNrZest IN 0 .. ileZest-1 LOOP
    ZAPISZ_WSP(pNK_ZLEC, pPOZ, vNrZest, pNR_OBR);
   END LOOP;
  END IF;
 ELSE --1 zestaw (pNR_ZEST)
  IF pNK_ZLEC>0 THEN 
   INSERT INTO wsp_alter (nr_zestawu, nr_komp_inst, nr_kom_zlec, nr_poz, jaki, nr_porz_obr, wsp_alt)
   SELECT pNR_ZEST, V.nk_inst, V.nr_kom_zlec, V.nr_poz, decode(V.nk_inst,V.inst_std,3,2), V.nr_porz, 
         --V_SPISS zawiera WSP_PRZEL dla zestawu=0
         --je¿eli wywolanie zapisu wsp. dla pNR_ZEST>0 to wyliczanie wsp. przy uzyciu funkcji WSP_WG_TYPU_INST i WSP_12ZAKR dla tego numeru zestawu
         case when pNR_ZEST=0 then V.wsp_przel
              else nvl(WSP_WG_TYPU_INST(V.typ_inst, nvl(wsp_12zakr(V.nk_inst,V.pow,V.ident_bud,pNR_ZEST),1), V.wsp_c_m, V.wsp_har, V.wsp_HO, V.wsp_dod, V.znak_dod),0)
         end wsp_przel
   FROM v_spiss V
   LEFT JOIN wsp_alter W ON W.nr_zestawu=pNR_ZEST and W.nr_komp_inst=V.nk_inst and W.nr_kom_zlec=V.nr_kom_zlec and W.nr_poz=V.nr_poz and W.nr_porz_obr=V.nr_porz
   WHERE V.zrodlo='Z' AND V.nr_kom_zlec=pNK_ZLEC
     AND pPOZ in (0,V.nr_poz) AND pNR_OBR in (0,V.nk_obr) 
     AND W.nr_kom_zlec is null;
  ELSE
   INSERT INTO wsp_alter (nr_zestawu, nr_komp_inst, nr_kom_zlec, nr_poz, jaki, nr_porz_obr, wsp_alt)
   SELECT pNR_ZEST, V.nk_inst, V.nr_kom_zlec, V.nr_poz, decode(V.nk_inst,V.inst_std,3,2), V.nr_porz, 
         --V_SPISS zawiera WSP_PRZEL dla zestawu=0
         --je¿eli wywolanie zapisu wsp. dla pNR_ZEST>0 to wyliczanie wsp. przy uzyciu funkcji WSP_WG_TYPU_INST i WSP_12ZAKR dla tego numeru zestawu
         case when pNR_ZEST=0 then V.wsp_przel
              else nvl(WSP_WG_TYPU_INST(V.typ_inst, nvl(wsp_12zakr(V.nk_inst,V.pow,V.ident_bud,pNR_ZEST),1), V.wsp_c_m, V.wsp_har, V.wsp_HO, V.wsp_dod, V.znak_dod),0)
         end wsp_przel
   FROM v_spiss V
   LEFT JOIN wsp_alter W ON W.nr_zestawu=pNR_ZEST and W.nr_komp_inst=V.nk_inst and W.nr_kom_zlec=V.nr_kom_zlec and W.nr_poz=V.nr_poz and W.nr_porz_obr=V.nr_porz
   WHERE V.zrodlo='Z' --AND (pNK_ZLEC>0 and V.nr_kom_zlec=pNK_ZLEC or pNK_ZLEC=0)
     AND pPOZ in (0,V.nr_poz) AND pNR_OBR in (0,V.nk_obr) 
     AND W.nr_kom_zlec is null;  
  END IF;
 END IF;   
END ZAPISZ_WSP;
/

--@V wyciêta z PKG_PLAN_SPISS
CREATE OR REPLACE FUNCTION NR_INST_NAST(pNK_ZLEC NUMBER, pPOZ NUMBER, pWAR NUMBER, pSZT NUMBER, pKOLEJN NUMBER) RETURN NUMBER IS
 vNast number(10);
BEGIN
   select max(nr_inst_plan) into vNast
   from (select nr_inst_plan
         from l_wyc2
         where nr_kom_zlec=pNK_ZLEC and nr_poz_zlec=pPOZ and nr_szt=pSZT
           and pWAR between nr_warst and war_do and kolejn>pKOLEJN
         order by kolejn)
   where rownum=1;
   return nvl(vNast,0);
END NR_INST_NAST;
/

create or replace PROCEDURE ZAPISZ_LWYC (pNK_ZLEC IN NUMBER, pINST IN NUMBER DEFAULT 0, pPOZ IN NUMBER DEFAULT 0)
AS
 vWYROZNIK zamow.wyroznik%TYPE;
BEGIN
 SELECT wyroznik INTO vWYROZNIK FROM zamow WHERE nr_kom_zlec=pNK_ZLEC;
 INSERT INTO l_wyc (nr_kom_zlec, nr_poz_zlec, nr_szt, nr_warst, typ_kat, rodz_sur,
                    nr_inst, typ_inst, kolejn,
                    zn_wyrobu, nr_inst_nast,
                    nr_listy, nr_komory, zn_wyk_tran, nr_szar, zn_w_poprz, nr_st_c,
                    kod_pask, nr_ser, id_rek,                   
                    zn_braku, op, DATA, czas, d_wyk, zm_wyk, nr_inst_wyk, nr_stoj, stoj_poz, zn_stoj, 
                    op_end, data_end, czas_end, id_oryg, wyroznik, nry_porz)
  SELECT L.nr_kom_zlec, L.nr_poz_zlec, L.nr_szt, L.nr_warst, S.indeks, decode(max(S.zn_war),'Pó³','POL','Pol','POL','Str','POL',nvl(max(K.rodz_sur),' ')),
         L.nr_inst_plan, max(I.ty_inst), max(L.kolejn),
--@V
--         decode(PKG_PLAN_SPISS.NR_INST_NAST(L.nr_kom_zlec,L.nr_poz_zlec,L.nr_warst,L.nr_szt,max(L.kolejn)),0,1,0), 
--         PKG_PLAN_SPISS.NR_INST_NAST(L.nr_kom_zlec,L.nr_poz_zlec,L.nr_warst,L.nr_szt,max(L.kolejn)),
         decode(NR_INST_NAST(L.nr_kom_zlec,L.nr_poz_zlec,L.nr_warst,L.nr_szt,max(L.kolejn)),0,1,0), 
         NR_INST_NAST(L.nr_kom_zlec,L.nr_poz_zlec,L.nr_warst,L.nr_szt,max(L.kolejn)),
         0, 0, 0, 0, 0, 0,
         to_char(nvl(max(E.nr_kom_szyby),0)*100+L.nr_warst,'0999999999'), nvl(max(E.nr_kom_szyby),0)*100+L.nr_warst, 0 /*lwyc_seq.nextval*/,
         0, ' ', to_date('190101', 'YYYYMM'), '000000', to_date('190101', 'YYYYMM'), 0, 0, 0, 0, 0,
         ' ', to_date('190101', 'YYYYMM'), '000000', 0, vWYROZNIK,
         listagg(L.nr_porz_obr,',') within group (order by L.kolejn)
  FROM l_wyc2 L
  LEFT JOIN spiss S ON S.zrodlo='Z' and S.nr_komp_zr=L.nr_kom_zlec and S.nr_kol=L.nr_poz_zlec and S.war_od=L.nr_warst
                       and S.czy_war=1 and S.strona=0 and S.etap=trunc(L.kolejn,-2)*0.01
--  --nast obr w tym samym etapie                     
--  LEFT JOIN l_wyc2 L2 ON L2.nr_kom_zlec=L.nr_kom_zlec and L2.nr_poz_zlec=L.nr_poz_zlec and L2.nr_szt=L.nr_szt
--                         and L2.nr_warst=L.nr_warst and L2.kolejn=L.kolejn+1 and trunc(L2.kolejn,-2)=trunc(L.kolejn,-2)
--  --nast etap                     
--  LEFT JOIN l_wyc2 L3 ON L3.nr_kom_zlec=L.nr_kom_zlec and L3.nr_poz_zlec=L.nr_poz_zlec and L3.nr_szt=L.nr_szt
--                         and L3.kolejn=trunc(L.kolejn,-2)+101
  LEFT JOIN katalog K ON K.nr_kat=S.nr_kat
  LEFT JOIN parinst I ON I.nr_komp_inst=L.nr_inst_plan
  LEFT join spise E ON E.nr_komp_zlec=L.nr_kom_zlec and E.nr_poz=L.nr_poz_zlec and E.nr_szt=L.nr_szt
  WHERE L.nr_kom_zlec=pNK_ZLEC AND pINST in (0,L.nr_inst_plan) AND pPOZ in (0,L.nr_poz_zlec)
  GROUP BY S.indeks, L.nr_kom_zlec, L.nr_poz_zlec, L.nr_szt, L.nr_warst, L.nr_inst_plan;
END ZAPISZ_LWYC;
/


create or replace PROCEDURE ZMIEN_GIETARKE (pNK_ZLEC NUMBER, pNR_POZ NUMBER, pNK_INST NUMBER, pNK_ZM NUMBER DEFAULT null)
AS
  vNrCiagu NUMBER(2);
  vNkInstLIS NUMBER(6);
BEGIN
   NULL;
END ZMIEN_GIETARKE;
/

create or replace procedure WPISZ_INST_LWYC2(pNK_ZLEC NUMBER, pNR_POZ NUMBER, pNR_PORZ NUMBER, pNR_SZT NUMBER, pNK_INST NUMBER, pNK_INST_POW NUMBER, pNK_ZM NUMBER default null)
AS
  rec_pow NUMBER(6):=0;
  vNrObr NUMBER(4);
  vNrCiagu NUMBER(2);
  vNkInstLIS NUMBER(6);
BEGIN
 UPDATE l_wyc2 SET nr_inst_plan=pNK_INST, nr_zm_plan=nvl(pNK_ZM,nr_zm_plan)
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
    SELECT nr_kom_zlec, nr_poz_zlec, nr_szt, nr_warst, war_do, nr_obr, nr_porz_obr+1500, pNK_INST_POW, nr_zm_plan, 0, 0, kolejn+1, 0
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
/

create or replace PROCEDURE USTAW_WSP (pNK_ZLEC NUMBER, pNK_OBR NUMBER DEFAULT 0)
AS
BEGIN
UPDATE wsp_alter A
SET jaki=(select nvl(max(case when L.nr_porz_obr=1500+A.nr_porz_obr then 4 else 3 end),2)  -- 2 bez planu  3 w planie 4 w planie jako powiazana
          --nvl(decode(nr_komp_inst,pNK_INST,3,vInstPow,4,2
          from l_wyc2 L
          left join gr_inst_dla_obr G on G.nr_komp_obr=L.nr_obr and G.nr_komp_inst=L.nr_inst_plan
          where L.nr_kom_zlec=A.nr_kom_zlec and L.nr_poz_zlec=A.nr_poz and L.nr_porz_obr in (A.nr_porz_obr,1500+A.nr_porz_obr) and L.nr_inst_plan=A.nr_komp_inst)
WHERE nr_kom_zlec=pNK_ZLEC
  AND (pNK_OBR=0 OR
       (nr_poz, nr_porz_obr) IN
       (select distinct nr_poz_zlec, nr_porz_obr from l_wyc2 where nr_kom_zlec=pNK_ZLEC and nr_obr=pNK_OBR)
      );
END USTAW_WSP;
/

create or replace PROCEDURE USTAW_INST (pNK_ZLEC NUMBER, pNR_POZ NUMBER, pNR_PORZ NUMBER, pNK_OBR NUMBER, pNK_INST NUMBER, pNK_INST_POW NUMBER DEFAULT null, pNK_ZM NUMBER DEFAULT null)
AS
 vInstPow NUMBER(10):=pNK_INST_POW;
  vNrCiagu NUMBER(2);
  vNkInstLIS NUMBER(6);
BEGIN
  IF pNK_INST_POW is null THEN
   SELECT nr_inst_pow INTO vInstPow FROM parinst WHERE nr_komp_inst=pNK_INST;
  END IF;
  IF pNK_ZLEC*pNR_POZ*pNR_PORZ>0 THEN
   --ustawienie w kolumnie JAKI informacji, ktora instalacja wybrana (ewentualnei ktora powi¹zana do wybranej)
   UPDATE wsp_alter
   SET jaki=decode(nr_komp_inst,pNK_INST,3,vInstPow,4,2)
   WHERE nr_kom_zlec=pNK_ZLEC and nr_poz=pNR_POZ and nr_porz_obr=pNR_PORZ;
   --aktualizacja inst. L_WYC2
   WPISZ_INST_LWYC2(pNK_ZLEC,pNR_POZ,pNR_PORZ,0,pNK_INST,vInstPow,pNK_ZM);
  ELSIF pNK_ZLEC*pNR_POZ*pNK_OBR>0 THEN
   FOR rec IN (select V.nr_poz, V.nr_porz, V.nr_inst_pow from v_spiss V where V.zrodlo='Z' and V.nr_kom_zlec=pNK_ZLEC and V.nr_poz=pNR_POZ and V.nk_obr=pNK_OBR and V.nk_inst=pNK_INST)
    LOOP
     USTAW_INST(pNK_ZLEC,rec.nr_poz,rec.nr_porz,0,pNK_INST,rec.nr_inst_pow,pNK_ZM);
    END LOOP;
  ELSIF pNK_ZLEC*pNK_OBR>0 THEN
   FOR rec IN (select V.nr_poz, V.nr_porz, V.nr_inst_pow from v_spiss V where V.zrodlo='Z' and V.nr_kom_zlec=pNK_ZLEC and V.nk_obr=pNK_OBR and V.nk_inst=pNK_INST)
    LOOP
     USTAW_INST(pNK_ZLEC,rec.nr_poz,rec.nr_porz,0,pNK_INST,rec.nr_inst_pow,pNK_ZM);
    END LOOP;
    
  IF pNK_OBR=99 THEN -- gdy MON to automatyczna aktualizacja giêtarek
   SELECT nvl(min(nr_komp_gr),0) INTO vNrCiagu
   FROM gr_inst_pow 
   WHERE nr_komp_inst=pNK_INST;
   SELECT nvl(min(nr_komp_inst),0) INTO vNkInstLIS
   FROM gr_inst_pow 
   LEFT JOIN parinst USING (nr_komp_inst)
   WHERE nr_komp_gr=vNrCiagu and rodz_sur='LIS';
    IF vNkInstLIS>0 THEN
    --WPISZ_INST_LWYC2(pNK_ZLEC, pNR_POZ, pNR_PORZ NUMBER, pNR_SZT, pNK_INST NUMBER, pNK_INST_POW NUMBER, pNK_ZM NUMBER default null) 
    RETURN;
    USTAW_INST(pNK_ZLEC,pNR_POZ,0,96,vNkInstLIS,0,pNK_ZM);
    --   UPDATE l_wyc2 SET nr_inst_plan=vNkInstLIS, nr_zm_plan=nvl(pNK_ZM,nr_zm_plan)
    --   WHERE nr_kom_zlec=pNK_ZLEC and nr_poz_zlec=pNR_POZ and pNR_SZT in (0,nr_szt)
    --     AND nr_obr=96 and nr_inst_plan<>49; --@TODO@ w EFF 49 to Rêczne sk¹danie ramek
    END IF;
   END IF;
  END IF;
END USTAW_INST;
/
/*
create or replace PROCEDURE ZMIEN_GIETARKE (pNK_ZLEC NUMBER, pNR_POZ NUMBER, pNK_INST NUMBER, pNK_ZM NUMBER DEFAULT null)
AS
  vNrCiagu NUMBER(2);
  vNkInstLIS NUMBER(6);
BEGIN
   SELECT nvl(min(nr_komp_gr),0) INTO vNrCiagu
   FROM gr_inst_pow 
   WHERE nr_komp_inst=pNK_INST;
   SELECT nvl(min(nr_komp_inst),0) INTO vNkInstLIS
   FROM gr_inst_pow 
   LEFT JOIN parinst USING (nr_komp_inst)
   WHERE nr_komp_gr=vNrCiagu and rodz_sur='LIS';
   IF vNkInstLIS>0 THEN
    --WPISZ_INST_LWYC2(pNK_ZLEC, pNR_POZ, pNR_PORZ NUMBER, pNR_SZT, pNK_INST NUMBER, pNK_INST_POW NUMBER, pNK_ZM NUMBER default null) 
    USTAW_INST(pNK_ZLEC,pNR_POZ,0,96,vNkInstLIS,0,pNK_ZM);
    --   UPDATE l_wyc2 SET nr_inst_plan=vNkInstLIS, nr_zm_plan=nvl(pNK_ZM,nr_zm_plan)
    --   WHERE nr_kom_zlec=pNK_ZLEC and nr_poz_zlec=pNR_POZ and pNR_SZT in (0,nr_szt)
    --     AND nr_obr=96 and nr_inst_plan<>49; --@TODO@ w EFF 49 to Rêczne sk¹danie ramek
   END IF;
END ZMIEN_GIETARKE;
*/

create or replace PROCEDURE USTAL_INST (pZRODLO CHAR, pNK_ZLEC NUMBER, pNR_POZ NUMBER DEFAULT 0, pNK_OBR NUMBER DEFAULT 0)
AS
 CURSOR c1 IS
  SELECT V.nr_poz, V.nr_porz, V.nk_inst, V.inst_std, V.nr_inst_pow, /*V.wsp_przel,*/ V.kryt_atryb, V.kryt_suma, V.obsl_tech
  FROM v_spiss V
  WHERE V.zrodlo=pZRODLO and V.nr_kom_zlec=pNK_ZLEC and pNR_POZ in (0,V.nr_poz) and pNK_OBR in (0,V.nk_obr) and V.gr_akt<2
  ORDER BY V.zrodlo, V.nr_kom_zlec, V.nr_poz, V.nr_porz, decode(V.nk_inst,V.inst_std,1,2), V.kolejnosc_z_grupy; 
  rec1 c1%ROWTYPE;
  currPoz NUMBER(4):=0;
  currObr NUMBER(4):=0;
  vObrOK BOOLEAN:=false;
  vInstOK BOOLEAN:=false;
  vNieSzukajDalej BOOLEAN;
BEGIN
  OPEN c1;
  LOOP
    FETCH c1 INTO rec1;
    EXIT WHEN c1%NOTFOUND;
    vInstOK:=rec1.kryt_suma=0 or rec1.obsl_tech=1;
    --NOWA POZYCJA LUB OBRÓBKA
    IF currPoz<>rec1.nr_poz or currObr<>rec1.nr_porz THEN      
      --je¿eli wybrana inst (INST_STD) jest OK to nie trzeba nic zmieniaæ
      vObrOK:=rec1.nk_inst=rec1.inst_std and vInstOK;
      currPoz:=rec1.nr_poz;
      currObr:=rec1.nr_porz;
      vNieSzukajDalej:=rec1.kryt_atryb=1 and vObrOK; --kryt_atryb: 1 atrybut pasuj¹cy   2 pusty atrybut kieruj¹cy na inst
      USTAW_INST(pNK_ZLEC,rec1.nr_poz,rec1.nr_porz,0,rec1.nk_inst,rec1.nr_inst_pow);
    END IF;
    --sprawdzanie pozostalych instalacji
    IF vInstOK AND (not vObrOK and rec1.kryt_atryb in (1,2) --1 atrybut pasuj¹cy   2 pusty atrybut kieruj¹cy na inst
                    or not vNieSzukajDalej and rec1.kryt_atryb=1) THEN  --wybrana tylko pierwsza instalacja z atrybutem kieruj¹cym
      vObrOK := true;
      vNieSzukajDalej:=rec1.kryt_atryb=1;
      USTAW_INST(pNK_ZLEC,rec1.nr_poz,rec1.nr_porz,0,rec1.nk_inst,rec1.nr_inst_pow);
    END IF;
  END LOOP;
  CLOSE c1;
END USTAL_INST;
/


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
  SELECT S.*
           --rezygnacja z zapisu WSP do L_WYC2 (zamist tego link do WSP_ALTER w V_WYC2
          --, nvl(W.wsp_alt,nvl(WSP_PLAN(S.zrodlo, S.nr_komp_zr, S.nr_kol, S.nr_porz, S.inst_std),0)) wsp_przel
          /*decode (trim(V.typ_inst),'A C',V.wsp_12zakr*V.wsp_c_m,'MON',V.wsp_12zakr,'SZP',V.wsp_12zakr*V.wsp_c_m, 'HAR', V.wsp_12zakr*(V.wsp_har+WSP_HO(S.nr_komp_zr,S.nr_kol,S.etap,S.war_od)),
            decode(trim(V.znak_dod),'*',V.wsp_12zakr*V.wsp_dod,'/',V.wsp_12zakr/V.wsp_dod,'+',V.wsp_12zakr+V.wsp_dod,'-',V.wsp_12zakr-V.wsp_dod,1)) wsp_przel */            
  FROM spiss S
  --LEFT JOIN wsp_alter W ON W.nr_kom_zlec=S.nr_komp_zr and W.nr_poz=S.nr_kol and W.nr_porz_obr=S.nr_porz and W.nr_komp_inst=S.inst_std
  --LEFT JOIN v_spiss V ON V.zrodlo=S.zrodlo and V.nr_kom_zlec=S.nr_komp_zr and V.nr_poz=S.nr_kol and V.nr_porz=S.nr_porz and V.nk_inst=S.inst_std
  WHERE S.zrodlo='Z' AND S.nr_komp_zr=pNR_KOM_ZLEC AND S.nr_kol=pPOZ AND pWAR between S.war_od and S.war_do AND S.etap=pETAP AND S.zn_plan>0
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
BEGIN
 SELECT count(1) INTO jestHARMON FROM dual WHERE exists (select 1 from harmon where nr_komp_zlec=pNR_KOM_ZLEC);
 IF jestHARMON=0 THEN
  DELETE FROM l_wyc WHERE nr_kom_zlec=pNR_KOM_ZLEC and pNR_POZ in (0,nr_poz_zlec) and nr_inst_wyk=0;
 END IF;
 DELETE FROM l_wyc2 WHERE nr_kom_zlec=pNR_KOM_ZLEC  and pNR_POZ in (0,nr_poz_zlec);
 DELETE FROM wsp_alter WHERE nr_kom_zlec=pNR_KOM_ZLEC and pNR_POZ in (0,nr_poz);
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
    ZAPISZ_WSP(pNR_KOM_ZLEC, recP.nr_poz, -1);  -- -1 wszystkie zestawy
    USTAL_INST('Z', pNR_KOM_ZLEC, recP.nr_poz);
    IF jestHARMON=0 THEN
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
   IF jestHARMON=0 THEN
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

create or replace TRIGGER LWYC_REJESTRACJA 
before update of d_wyk,zm_wyk,nr_inst_wyk,zn_braku on l_wyc 
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
begin
  update l_wyc2
  set nr_zm_wyk=PKG_CZAS.NR_KOMP_ZM(:NEW.d_wyk,:NEW.zm_wyk),
      nr_inst_wyk=:NEW.nr_inst_wyk
  WHERE nr_kom_zlec in (:NEW.nr_kom_zlec,-:NEW.nr_kom_zlec) and nr_poz_zlec=:NEW.nr_poz_zlec and nr_szt=:NEW.nr_szt
    and nr_warst=:NEW.nr_warst and nr_inst_plan=:NEW.nr_inst;
EXCEPTION WHEN OTHERS THEN
 NULL;
end;
/

--w porownaniu z @P roznica tylko w SPISZ.nr_rys<->nr_kom_rys
--08/2018 ominieice sprawdzania dla ZN_PLAN=0 np. obrobki nieplanowanej z powodu atrybutu wykluczajacego (SPISS.ZN_PLAN ustawiane na 0 w proc. SPISS_MAT)
CREATE OR REPLACE FORCE VIEW V_SPISS_ERRORS AS
  SELECT DANE."NR_KOM_ZLEC",DANE."NR_ZLEC",DANE."ROKP",DANE."NR_POZ",DANE."ILOSC",DANE."SZER",DANE."WYS",DANE."SZER0",DANE."WYS0",DANE."SZER4",DANE."WYS4",DANE."NR_KSZT",DANE."NR_RYS",DANE."NR_PORZ",DANE."ETAP",DANE."CZY_WAR",DANE."WAR_OD",DANE."STRONA",DANE."S04",DANE."POWLOKA",DANE."NR_KAT",DANE."INDEKS",DANE."NR_OBR",DANE."SYMB_OBR",DANE."OBR_LACZ",DANE."CZY_KOREKT_WYM",DANE."DECOAT",DANE."NR_OBR_KATALOG",DANE."PAR",DANE."BOKI",DANE."ZN_PLAN",DANE."KOLEJN_OBR",DANE."IL_OBR",DANE."INST_STD",DANE."INST_KATALOG",DANE."TYP_INST_KAT",DANE."SZER_STEP",DANE."WYS_STEP",DANE."IL_SZT_LWYC2",DANE."IL_SZT_NA_INST",DANE."PLAN_LWYC2",DANE."WSP_MIN",DANE."WSP_ALT",DANE."IL_KOL_STOJ", --nr_kom_zlec, nr_zlec, rokp, nr_poz, nr_porz, etap, war_od, indeks, nk_obr nr_obr, symb_p_obr symb_obr, il_obr, zn_plan, kolejn_obr, inst_std, il_szt_lwyc2, wsp_alt,
       decode(nvl(nr_obr,-1),-1,1,0)  spiss_err, --brak spiss
       decode(nr_kat,0,decode(obr_lacz,0,1,0),0) nr_kat_err,
       case when nr_kat>0 and nr_obr_katalog<>nr_obr and obr_lacz=0 and czy_war=1 then 1 else 0 end obr_kat_err,
       --decode(obr_lacz,0,decode(czy_war,1,decode(nr_obr_katalog,0,0,nr_obr,0,1),0),0) obr_kat_err,
       decode(nr_obr,0,decode(strona,0,0,1),0) nr_obr_err,
       decode(il_obr,0,decode(nr_obr,0,0,1),0) il_obr_err,
       decode(strona,0,decode(czy_war,0,1,0),0) strona_err, --na stronie 0 warstwy sprawdzany Step a nie strona
       decode(strona,0,czy_war,0) step_err,
       case when decoat=1 and (not (powloka=1 and strona=1 or powloka=2 and strona=3)
                               or nr_kszt>0 and nr_rys=0) then 1 else 0 end decoat_err,
       case when czy_korekt_wym=1 and (szer=szer4 and wys=wys4 or nr_kszt>0 and nr_rys=0) then 1 else 0 end nadd_err, --sprawdzanie obrysu jesli obr z nadd
       decode(nr_obr*zn_plan*nvl(kolejn_obr,0),0,0,ilosc-il_szt_lwyc2) lwyc2_err,
       decode(nr_obr*zn_plan*nvl(kolejn_obr,0),0,0,ilosc-il_szt_na_inst) lwyc2_inst_err,
       case when nr_obr=0 or zn_plan=0 or zn_plan=kolejn_obr then 0 else 1 end kolejn_err,
       case when nr_obr=0 or zn_plan=0 or kolejn_obr=0 or wsp_min is not null and wsp_min>0 then 0 else 1 end wsp_err,
       case when czy_war=1 and strona=4 and typ_inst_kat in ('A C','R C','PI?') and il_kol_stoj<>ilosc then 1 else 0 end COPT_err
FROM
(
select Z.nr_kom_zlec, Z.nr_zlec, Z.nr_komp_rokp rokp, P.nr_poz, P.ilosc, P.szer, P.wys,
       decode(S04.strona,0,S04.szer,-1) szer0, decode(S04.strona,0,S04.wys,-1) wys0,
       decode(S04.strona,4,S04.szer,-1) szer4, decode(S04.strona,4,S04.wys,-1) wys4,
       P.nr_kszt, P.nr_komp_rys nr_rys, S.nr_porz, S.etap, S.czy_war, S.war_od, S.strona, S04.strona S04,
       case when D0.il_odc_poz>0 then D0.il_odc_poz
            when D0.il_odc_pion=100000000 then 1
            when D0.il_odc_pion=1000000   then 2
            else 0 end powloka,--decode(S04.strona,0,S04.par5,-1) powloka,
       case when S.czy_war=1 then S.nr_kat else S.nr_kat_obr end nr_kat, S.indeks, S.nk_obr nr_obr, O.symb_p_obr symb_obr, O.obr_lacz, L.czy_korekt_wym, (case when O.met_oblicz=2 and O.rodzaj=2 then 1 else 0 end) decoat,
       K.nk_obr nr_obr_katalog, to_char(S.par1)||'|'||to_char(S.par2)||'|'||to_char(S.par3)||'|'||to_char(S.par4)||'|'||to_char(S.par5) par, S.boki, S.zn_plan, O.kolejn_obr, S.il_obr, 
       S.inst_std, K.nr_inst inst_katalog, K.typ_inst1 typ_inst_kat,
       case when S.etap=1 and S.czy_war=1 and S.strona=0 and D0.nr_poc='1  S' then nvl(D0.wsp1+D0.wsp3,0) else 0 end szer_step,
       case when S.etap=1 and S.czy_war=1 and S.strona=0 and D0.nr_poc='1  S' then nvl(D0.wsp2+D0.wsp4,0) else 0 end wys_step,
       (select count(1) from l_wyc2 L where L.nr_kom_zlec=Z.nr_kom_zlec and L.nr_poz_zlec=P.nr_poz and L.nr_porz_obr=S.nr_porz and L.nr_warst=S.war_od) il_szt_lwyc2,
       (select count(1) from l_wyc2 L where L.nr_kom_zlec=Z.nr_kom_zlec and L.nr_poz_zlec=P.nr_poz and L.nr_porz_obr=S.nr_porz and L.nr_warst=S.war_od
                                        and nr_inst_plan in (select nr_komp_inst from gr_inst_dla_obr where nr_komp_obr=L.nr_obr)) il_szt_na_inst,
       (select 1 from l_wyc2 L where L.nr_kom_zlec=Z.nr_kom_zlec and L.nr_poz_zlec=P.nr_poz and L.nr_porz_obr=S.nr_porz and L.nr_zm_plan>0 and rownum=1) plan_lwyc2,
       (select min(nvl(wsp_alt,-G.nr_komp_inst)) from gr_inst_dla_obr G, wsp_alter W
        where G.nr_komp_obr=S.nk_obr and W.nr_zestawu(+)=0 and W.nr_komp_inst(+)=G.nr_komp_inst and W.nr_kom_zlec(+)=Z.nr_kom_zlec and W.nr_poz(+)=P.nr_poz and W.nr_porz_obr(+)=S.nr_porz
       ) wsp_min, W.wsp_alt,
       case when S.czy_war=1 and S.strona=4 and trim(K.typ_inst1) in ('A C','R C','PI£')
            then P.ilosc--(select count(1) from kol_stojakow where nr_komp_zlec=Z.nr_kom_zlec and nr_poz=P.nr_poz and nr_warstwy=S.war_od)
            else 0 end il_kol_stoj
 from zamow Z
 left join spisz P on P.nr_kom_zlec=Z.nr_kom_zlec
 left join spiss S on S.zrodlo='Z' and S.nr_komp_zr=Z.nr_kom_zlec and S.nr_kol=P.nr_poz
 left join spisd D0 on D0.nr_kom_zlec=Z.nr_kom_zlec and D0.nr_poz=P.nr_poz and D0.do_war=S.war_od and D0.nr_poc in (' ','1  S') and D0.strona=0 --and S.etap=1 and S.czy_war=1 and S.strona=0
 left join slparob O on O.nr_k_p_obr=S.nk_obr
 left join lista_p_obr L on L.nr_komp_struktury=S.nk_obr and L.czy_korekt_wym=1
 left join spiss S04 on S04.zrodlo=S.zrodlo and S04.nr_komp_zr=Z.nr_kom_zlec and S04.nr_kol=P.nr_poz and S04.etap=S.etap and S04.czy_war=1 and S04.war_od=S.war_od and S04.strona=decode(nvl(L.czy_korekt_wym,0),1,4,0) --link do strony 4 tylko przy obróbce z naddatkiem
 --left join katalog K on K.nr_kat=S.nr_kat --poprawka 08/2018
 left join katalog K on K.nr_kat=case when S.czy_war=1 then S.nr_kat else S.nr_kat_obr end
 --left join v_spiss V on V.zrodlo=S.zrodlo and V.nr_kom_zlec=S.nr_komp_zr and V.nr_poz=S.nr_kol and V.nr_porz=S.nr_porz
 left join wsp_alter W on W.nr_zestawu=0 and W.nr_kom_zlec=S.nr_komp_zr and W.nr_poz=S.nr_kol and W.nr_porz_obr=S.nr_porz and W.nr_komp_inst=S.inst_std
 where Z.typ_zlec='Pro' and Z.nr_kom_zlec>0 --and Z.nr_kom_zlec=487073
   and K.rodz_sur not in ('USZ','ZWY')
   and (S.nk_obr is null or
        S.nr_porz>0 and not (S.nk_obr>0 and S.zn_pp>0) --nie uwzglêdniane obróbki wew. pólproduktu
        and (S.nk_obr>0 or /*S.nr_kat=0 and O.obr_lacz<2 or*/ K.rodz_sur='TAF' or K.nk_obr>0) --TAFLE lub rekordy z przypisan¹ obróbk¹ w katalogu (lub nieprzypisany katalog z wyj Zespalania obr_lacz=2)
        and not (S.czy_war=1 and S.strona=0 --not=> strona 0 (parametry stepu) nie sprawdzana dla wy¿szych etapów lub gdy jest rys., ale je¿eli nr_kszt>0 to te¿ mo¿liwy b³¹d
                 and (S.etap>1 or (P.nr_komp_rys>0 or D0.kol_dod is null or D0.nr_poc<>'1  S' or P.nr_kszt=0 and D0.wsp1+D0.wsp3=P.szer-S04.szer and D0.wsp2+D0.wsp4=P.wys-S04.wys))
                )
        )
) DANE
WHERE nr_obr is null or nr_obr=0 and etap=1
      or il_obr=0 and nr_obr>0
      or strona=0 and czy_war=0 and nr_obr>0--spr. strony obróbki
      or strona=0 and czy_war=1 and nr_obr=0 --spr. stepów
      --nr_kat=0 and obr_lacz<2 or  --nie-zespalanie musi mieæ Katalog
      or nr_kat>0 and czy_war=1 and nr_obr_katalog<>nr_obr --obr_kat_err - iina obróbka ni¿ w Katalogu
      or nr_obr>0 and zn_plan>0 and kolejn_obr>0 and (ilosc<>il_szt_lwyc2 or ilosc<>il_szt_na_inst or zn_plan<>kolejn_obr or wsp_min<=0) --spr. ilsoci rekordów w L_WYC2, WSP_ALTER, kolejn., inst.
      --or nr_obr>0 and zn_plan+kolejn_obr>0 and czy_war=1 and typ_inst_kat in ('A C','R C','PI£') and ilosc<>il_kol_stoj --spr KOL_STOJAKOW
      or decoat=1 and (not (powloka=1 and strona=1 or powloka=2 and strona=3) or nr_kszt>0 and nr_rys=0) --sprawdzanie strony powloki  przy DECOAT, b³¹d przy kszta³cie
      or czy_korekt_wym=1 and (szer=szer4 and wys=wys4 or nr_kszt>0 and nr_rys=0)                      --sprawdzanie naddatków, b³¹d przy kszta³cie
ORDER BY nr_zlec desc , nr_poz, nr_porz;
 --V_SPISS_ERRORS
/

create or replace
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
/

--drop table PLAN_BLOK;
CREATE TABLE "PLAN_BLOK" 
(	"NR_KOM_ZLEC" NUMBER(10,0) DEFAULT 0 NOT NULL, 
	"NR_POZ" NUMBER(6,0) DEFAULT 0 NOT NULL, 
	"ZAKRES_BLOKADY" NUMBER(1,0) DEFAULT 0 NOT NULL, 
	"DANE1" NUMBER(10,0) DEFAULT 0 NOT NULL, 
	"DANE2" VARCHAR2(50 BYTE), 
	"SESS_ID" NUMBER(10,0) DEFAULT 0 NOT NULL, 
	"CZAS" DATE DEFAULT sysdate NOT NULL
);
CREATE UNIQUE INDEX "JAKI_ZAKRES_PLAN_BLOK" ON "PLAN_BLOK" ("NR_KOM_ZLEC", "NR_POZ", "ZAKRES_BLOKADY", "DANE1", "DANE2");
CREATE INDEX "WG_CZASU_PLAN_BLOK" ON "PLAN_BLOK" ("CZAS", "NR_KOM_ZLEC");
  
create or replace PROCEDURE USUN_PLAN (pNK_ZLEC IN NUMBER, pINST IN NUMBER DEFAULT 0, pPOZ IN NUMBER DEFAULT 0, pPRZYWROC_LWYC2 IN NUMBER DEFAULT 0, pZAKR_INST IN NUMBER DEFAULT 0)
AS 
BEGIN
  DELETE FROM harmon WHERE nr_komp_zlec=pNK_ZLEC and typ_harm='P' and pINST in (0,nr_komp_inst) 
                       AND (pZAKR_INST=0 or pZAKR_INST=1 and trim(typ_inst) in ('MON','STR') or pZAKR_INST=2 and trim(typ_inst) not in ('MON','STR'));
  DELETE FROM wykzal WHERE nr_komp_zlec=pNK_ZLEC  and pPOZ in (0,nr_poz) and pINST in (0,nr_komp_instal) and pZAKR_INST in (0,2);
  DELETE FROM spisp WHERE numer_komputerowy_zlecenia=pNK_ZLEC  and pPOZ in (0,nr_poz) and pINST in (0,nr_kom_inst) and pZAKR_INST in (0,1);
  --DELETE FROM l_wyc WHERE nr_kom_zlec=pNK_ZLEC  and pPOZ in (0,nr_poz_zlec) and pINST in (0,nr_inst);
  
  PORZADKUJ_ZMIANY_I_KALINST (pNK_ZLEC, 0);  --dla wsz. inst. w planie
  
  /*@V
  IF pPRZYWROC_LWYC2=1 THEN
   UPDATE l_wyc2
   SET nr_inst_plan=(select inst_std from spiss S where S.zrodlo='Z' and S.nr_komp_zr=l_wyc2.nr_kom_zlec and S.nr_kol=l_wyc2.nr_poz_zlec and S.nr_porz=l_wyc2.nr_porz_obr),
       nr_zm_plan=0
   WHERE nr_kom_zlec=pNK_ZLEC and pPOZ in (0,nr_poz_zlec) and pINST in (0,nr_inst_plan)
     AND nr_inst_plan not in (select distinct nr_komp_inst from harmon where nr_kom_zlec=pNK_ZLEC and pINST in (0,nr_inst_plan));
  END IF; */
END USUN_PLAN;
/

create or replace function WYLICZ_NR_KOM(pKOM_POCZ NUMBER, pKOM_KONC NUMBER, pILOSC NUMBER, pNR_SZT NUMBER) RETURN NUMBER
AS
BEGIN
 RETURN case when pKOM_POCZ=pKOM_KONC then pKOM_POCZ
             when pKOM_KONC-pKOM_POCZ+1=pILOSC then pKOM_POCZ+pNR_SZT-1         --1 szyba w komorze
             when (pKOM_KONC-pKOM_POCZ+1)*2>=pILOSC then pKOM_POCZ+floor((pNR_SZT-1)*1/2)   --2 szyby w komorze
             when (pKOM_KONC-pKOM_POCZ+1)*3>=pILOSC then pKOM_POCZ+floor((pNR_SZT-1)*1/3) --3 szyby w komorze
             else 0 end;
END WYLICZ_NR_KOM;
/

create or replace FUNCTION CIAG_NR_INST (pNK_ZLEC NUMBER, pNR_POZ NUMBER, pNR_SZT NUMBER, pNR_WAR NUMBER) RETURN VARCHAR2 
as
  vResult varchar2(100);
begin
  vResult := '';
  SELECT nvl(LISTAGG(nr_inst_plan,',') WITHIN GROUP (ORDER BY kolejn),' ')
    INTO vResult
  FROM l_wyc2
  WHERE nr_kom_zlec=pNK_ZLEC AND nr_poz_zlec=pNR_POZ AND nr_szt=pNR_SZT
    AND pNR_WAR between nr_warst and war_do;
  return vResult;
EXCEPTION WHEN OTHERS THEN
  return 'err';
end CIAG_NR_INST;
/

CREATE OR REPLACE FORCE VIEW "V_WYC2"
         ("NR_KOM_ZLEC", "NR_ZLEC", "NR_POZ_ZLEC", "ID_POZ", "SORT", "IDENT_BUD",
          "NR_SZT", "NR_WARST", "NR_WARST_DO", "ID_SZYBY", "ID_WYC",
          "CZY_WAR", "ZN_WAR", "INDEKS", "NR_KAT", "NR_GR",
          "ETAP", "KOLEJN", "ZN_PLAN", "NR_OBR", "SYMB_OBR", "NR_KAT_OBR", "KOD_DOD", "IL_DOD",
          "NR_INST_PLAN", "NR_ZM_PLAN", "NR_INST_WYK", "NR_ZM_WYK",
          "WSP_P", "WSP_W", "CIAG_NR_INST", "CIAG_PROD",
          "ILE_WPISOW", "NRY_PORZ", "IL_OBR", "POW_SUR", "OBSL_TECH", "ZAKL_KOL_POP", "ZAKL_KOL_NAST") AS 
  SELECT /*+ use_nl (L S S0 W1 W2)*/ 
  L.nr_kom_zlec, max(P.nr_zlec), L.nr_poz_zlec, max(P.id_poz), max(decode(P.sort2,0,L.nr_poz_zlec,P.sort2)), max(S0.ident_bud),--max(P.ind_bud),
  L.nr_szt,  L.nr_warst,  L.war_do,
  max(P.id_poz)*100000000+L.nr_szt*1000 id_szyby,
  max(P.id_poz)*100000000+L.nr_szt*1000+S.etap*100+L.nr_warst id_wyc,
  max(S.czy_war), max(S0.zn_war), MAX(S0.indeks) indeks,  MAX(S0.nr_kat), max(nvl(G.nkomp_grupy,0)),
  S.etap, MIN(L.kolejn) kolejn, max(S.zn_plan+sign(L.nr_porz_obr-S.nr_porz)*0.5), --dadanie 0.5 jesli rekord dla inst. powi¹zanej czyli L.NR_PORZ_OBR=S.NR_PORZ+1500
  L.nr_obr, max(O.symb_p_obr), /*max(decode(S.zn_war,'Obr',S.nr_kat,O.nr_kat_obr))*/ max(S.nr_kat_obr) nr_kat_czynn, S.kod_dod, sum(S.il_sur) il_dod,  
  L.nr_inst_plan,  L.nr_zm_plan,  L.nr_inst_wyk,  L.nr_zm_wyk,
  --max(case when W1.wsp_alt is not null then round(W1.wsp_alt,3) else 1 /*nvl(WSP_PLAN('Z', L.nr_kom_zlec, L.nr_poz_zlec, L.nr_porz_obr, L.nr_inst_plan),1)*/ end) wsp_p,
  --max(case when L.nr_inst_wyk=0 then 0 when W2.wsp_alt is not null then round(W2.wsp_alt,3) when W1.wsp_alt is not null then round(W1.wsp_alt,3) else 1 end) wsp_w,
  --04/2018 ppoprawa wyliczania wypadkowego wspolczynnika SUM(IL_OBR*WSP)/SUM(IL_OBR)
  case when sum(S.il_obr)>0 then sum(S.il_obr*W1.wsp_alt)/sum(S.il_obr) else 1.000 end wsp_p,
  case when sum(sign(L.nr_inst_wyk)*S.il_obr)>0 then sum(sign(L.nr_inst_wyk)*S.il_obr*round(nvl(W2.wsp_alt,W1.wsp_alt),3))/sum(sign(L.nr_inst_wyk)*S.il_obr) else 1.000 end wsp_w,
  ciag_nr_inst(L.nr_kom_zlec,  L.nr_poz_zlec,  L.nr_szt,  L.nr_warst), max(S0.str_dod) ciag_prod,
  COUNT(1) ile_wpisow, listagg(L.nr_porz_obr,',') within group (order by L.kolejn) nry_porz,
  SUM(S.il_obr) il_obr,  MAX(S0.il_sur) pow_sur,  
  -- COUNT(1) ile_wpisow (ile razy ta obróbka w warstwie)
  -- MIN(L.kolejn) kolejn (jeœli obróbka wiecej ni¿ raz to  ma kolejne ró¿ne KOLEJN w l_wyc2
  -- MAX(S.zn_plan), MAX(L.wsp_p) wsp_p,  MAX(L.wsp_w) wsp_w,  MAX(VS.kryt_suma) (MAX() tylko w celu unikniêcia grupowania po tych kolumnach)
  nvl(decode(MAX(TKP.obsl),0,8,MAX(TKP.obsl)),0) obsl_tech,
  --szukanie w L_WYC2 w rekordach Pop i Nast (wg KOLEJN) zakloconych zmian
  CASE WHEN (select min(Lpop.kolejn) from l_wyc2 Lpop where  Lpop.nr_kom_zlec=L.nr_kom_zlec and Lpop.nr_poz_zlec=L.nr_poz_zlec and  Lpop.nr_warst between L.nr_warst and L.war_do and Lpop.nr_szt=L.nr_szt and Lpop.nr_zm_plan>L.nr_zm_plan)<MIN(L.kolejn) THEN 1 ELSE 0 END zakl_kolejn_pop,
  CASE WHEN (select max(Lnast.kolejn) from l_wyc2 Lnast where  Lnast.nr_kom_zlec=L.nr_kom_zlec and Lnast.nr_poz_zlec=L.nr_poz_zlec and  L.nr_warst between Lnast.nr_warst and Lnast.war_do and Lnast.nr_szt=L.nr_szt and Lnast.nr_zm_plan<L.nr_zm_plan)>MAX(L.kolejn) THEN 1 ELSE 0 END zakl_kolejn_nast
 FROM
  l_wyc2 L 
 --LEFT JOIN gr_inst_dla_obr GO ON GO.nr_komp_obr=L.nr_obr and GO.nr_komp_gr=L.nr_obr and GO.nr_komp_inst=L.nr_inst_plan --bedzie potrzebe dla upewnienia sie czy rekord dla inst powi¹zanej
 LEFT JOIN spiss S ON  S.zrodlo='Z' AND S.nr_komp_zr=L.nr_kom_zlec AND S.nr_kol=L.nr_poz_zlec AND S.nr_porz in (L.nr_porz_obr,L.nr_porz_obr-1500) --dane dla inst powiaz. przesuniete o 1500
 LEFT JOIN spiss S0 ON S0.zrodlo=S.zrodlo AND S0.nr_komp_zr=S.nr_komp_zr AND S0.nr_kol=S.nr_kol
       AND S0.etap=S.etap AND S.war_od BETWEEN S0.war_od AND S0.war_do AND S0.czy_war=1 AND S0.strona=0
 LEFT JOIN slparob O ON O.nr_k_p_obr=L.nr_obr
 LEFT JOIN kat_gr_plan G ON G.typ_kat=S.indeks AND G.nkomp_instalacji=L.nr_inst_plan
 --pobanie wsp plan. i wsp wyk.
 LEFT JOIN wsp_alter W1 ON W1.nr_zestawu=0 and W1.nr_kom_zlec=S.nr_komp_zr and W1.nr_poz=S.nr_kol and W1.nr_porz_obr=S.nr_porz and W1.nr_komp_inst=L.nr_inst_plan
 LEFT JOIN wsp_alter W2 ON W2.nr_zestawu=0 and W2.nr_kom_zlec=S.nr_komp_zr and W2.nr_poz=S.nr_kol and W2.nr_porz_obr=S.nr_porz and W2.nr_komp_inst=L.nr_inst_wyk
 --pobranie sortu
 LEFT JOIN spisz P ON P.nr_kom_zlec=L.nr_kom_zlec AND P.nr_poz=L.nr_poz_zlec
 --kontrola poprawnoœci techn/      
 LEFT JOIN (select nr_komp_zlec, max(nr_komp_zap) nr_komp_zap_ost from tech_kontr group by nr_komp_zlec) TK ON TK.nr_komp_zlec=L.nr_kom_zlec
 LEFT JOIN tech_kontr_poz TKP ON TKP.nr_komp_zap=TK.nr_komp_zap_ost AND
                                 TKP.nr_komp_zlec=L.nr_kom_zlec AND TKP.id_rek=S.id_rek AND TKP.nr_kolejny=L.nr_porz_obr AND TKP.nr_komp_instal=L.nr_inst_plan
 GROUP BY  L.nr_kom_zlec,  L.nr_poz_zlec,  L.nr_szt,  L.nr_warst, L.war_do, S.etap,  L.nr_obr,  S.kod_dod, L.nr_inst_plan,  L.nr_zm_plan,  L.nr_inst_wyk,  L.nr_zm_wyk;
/
--V_WYC1 to okrojona wersja V_WYC2 (bez kolumn dot. SO i bez spr. kolejnoœci
CREATE OR REPLACE FORCE VIEW "V_WYC1" ("NR_KOM_ZLEC", "NR_ZLEC", "NR_POZ_ZLEC", "SZT_CALK", "ID_POZ", "SORT", "IDENT_BUD",
            "NR_SZT", "NR_WARST", "NR_WARST_DO",  "ID_SZYBY", "ID_WYC",
            "ZN_WAR", "INDEKS", "NR_KAT", "NR_GR",
            "ETAP", "KOLEJN", "ZN_PLAN", "NR_OBR", "SYMB_OBR", "NR_KAT_OBR", "MET_OBLICZ", "RODZ_OBR", "OBR_LACZ",
            "KOD_DOD", "IL_DOD", "NR_INST_PLAN", "NR_ZM_PLAN", "NR_INST_WYK", "NR_ZM_WYK", "FLAG",
             "WSP_P", "WSP_W", "CIAG_NR_INST", "CIAG_PROD",
            "NR_LISTY", "NR_SZARZY", "RACK_NO", "NR_OPT", "NR_TAF", "ZN_WYK_CIE",
            "ILE_WPISOW", "NRY_PORZ",  "IL_OBR", "POW_SUR"/*, "OBSL_TECH", "ZAKL_KOL_POP", "ZAKL_KOL_NAST"*/,
            "ILE_OBR","NR_OBR_KONC","INST_POW"
            ) AS
  SELECT /*+ use_nl (L S S0 W1 W2 KS)*/ 
  L.nr_kom_zlec, max(P.nr_zlec), L.nr_poz_zlec, max(P.ilosc), max(P.id_poz), max(decode(P.sort2,0,L.nr_poz_zlec,P.sort2)), max(S0.ident_bud),--max(P.ind_bud),
  L.nr_szt,  L.nr_warst,  L.war_do,
  max(P.id_poz)*100000000+L.nr_szt*1000 id_szyby,
  max(P.id_poz)*100000000+L.nr_szt*1000+S.etap*100+L.nr_warst id_wyc,
  max(S0.zn_war), MAX(S0.indeks) indeks,  MAX(S0.nr_kat), max(nvl(G.nkomp_grupy,0)),
  S.etap, MIN(L.kolejn) kolejn, max(S.zn_plan),
  L.nr_obr, max(O.symb_p_obr), max(decode(S.zn_war,'Obr',S.nr_kat,O.nr_kat_obr)) nr_kat_czynn, max(O.met_oblicz), max(O.rodzaj), max(O.obr_lacz),
  S.kod_dod, sum(S.il_sur) il_dod,
  L.nr_inst_plan, L.nr_zm_plan, L.nr_inst_wyk, L.nr_zm_wyk, min(L.flag),
  max(case when W1.wsp_alt is not null then round(W1.wsp_alt,3) else 1 /*nvl(WSP_PLAN('Z', L.nr_kom_zlec, L.nr_poz_zlec, L.nr_porz_obr, L.nr_inst_plan),1)*/ end) wsp_p,
  max(case when L.nr_inst_wyk=0 then 0 when W2.wsp_alt is not null then round(W2.wsp_alt,3) when W1.wsp_alt is not null then round(W1.wsp_alt,3) else 1 end) wsp_w,
  ciag_nr_inst(L.nr_kom_zlec,  L.nr_poz_zlec,  L.nr_szt,  L.nr_warst), max(S0.str_dod) ciag_prod,
  max(KS.nr_listy),
  max(case when O.rodzaj=4 then decode(nvl(KS.nr_grupy,0),0,(select nr_szarzy from zamow where zamow.nr_kom_zlec=L.nr_kom_zlec), KS.nr_grupy) else 0 end) nr_szarzy,
  max(case when O.rodzaj=4 then decode(nvl(KS.rack_no,0),0,WYLICZ_NR_KOM(P.kom_pocz,P.kom_konc,P.ilosc,L.nr_szt), KS.rack_no) else 0 end) rack_no,
  max(KS.nr_optym), max(KS.nr_taf), 0,-- max(KS.zn_wyk_cie),
  COUNT(1) ile_wpisow, listagg(L.nr_porz_obr,',') within group (order by L.kolejn) nry_porz,
  SUM(S.il_obr) il_obr,  MAX(S0.il_sur) pow_sur,  
  -- COUNT(1) ile_wpisow (ile razy ta obróbka w warstwie)
  -- MIN(L.kolejn) kolejn (jeœli obróbka wiecej ni¿ raz to  ma kolejne ró¿ne KOLEJN w l_wyc2
  -- MAX(S.zn_plan), MAX(L.wsp_p) wsp_p,  MAX(L.wsp_w) wsp_w,  MAX(VS.kryt_suma) (MAX() tylko w celu unikniêcia grupowania po tych kolumnach)
  regexp_count(max(S0.str_dod),',')+1 ile_obr,--decode(regexp_count(max(S0.str_dod),','),0,L.nr_obr,strtokenn(max(S0.str_dod),regexp_count(max(S0.str_dod),',')+1,',','99')) nr_obr_konc,
  first_value(L.nr_obr) over (partition by L.nr_kom_zlec,L.nr_poz_zlec,L.nr_szt order by max(L.kolejn) desc) nr_obr_konc,
  sign(max(L.nr_porz_obr-S.nr_porz)) inst_pow
 FROM
  l_wyc2 L
 LEFT JOIN spiss S ON  S.zrodlo='Z' AND S.nr_komp_zr=L.nr_kom_zlec AND S.nr_kol=L.nr_poz_zlec AND S.nr_porz in (L.nr_porz_obr,L.nr_porz_obr-1500) --dane dla inst powiaz. przesuniete o 1500
 LEFT JOIN spiss S0 ON S0.zrodlo=S.zrodlo AND S0.nr_komp_zr=S.nr_komp_zr AND S0.nr_kol=S.nr_kol
       AND S0.etap=S.etap AND S.war_od BETWEEN S0.war_od AND S0.war_do AND S0.czy_war=1 AND S0.strona=0
 LEFT JOIN slparob O ON O.nr_k_p_obr=L.nr_obr
 LEFT JOIN kat_gr_plan G ON G.typ_kat=S.indeks AND G.nkomp_instalacji=L.nr_inst_plan
 --pobanie wsp plan. i wsp wyk.
 LEFT JOIN wsp_alter W1 ON W1.nr_zestawu=0 and W1.nr_kom_zlec=S.nr_komp_zr and W1.nr_poz=S.nr_kol and W1.nr_porz_obr=S.nr_porz and W1.nr_komp_inst=L.nr_inst_plan
 LEFT JOIN wsp_alter W2 ON W2.nr_zestawu=0 and W2.nr_kom_zlec=S.nr_komp_zr and W2.nr_poz=S.nr_kol and W2.nr_porz_obr=S.nr_porz and W2.nr_komp_inst=L.nr_inst_wyk
 --pobranie 
 LEFT JOIN spisz P ON P.nr_kom_zlec=L.nr_kom_zlec AND P.nr_poz=L.nr_poz_zlec
 LEFT JOIN kol_stojakow KS ON KS.nr_komp_zlec=L.nr_kom_zlec AND KS.nr_poz=L.nr_poz_zlec AND KS.nr_sztuki=L.nr_szt AND KS.nr_warstwy=L.nr_warst AND O.rodzaj=4
 --where L.nr_kom_zlec=487055
 GROUP BY  L.nr_kom_zlec,  L.nr_poz_zlec,  L.nr_szt,  L.nr_warst, L.war_do, S.etap,  L.nr_obr, S.zn_plan, S.kod_dod, L.nr_inst_plan,  L.nr_zm_plan,  L.nr_inst_wyk,  L.nr_zm_wyk;
 /
 
create or replace
PROCEDURE ZAPISZ_HARMON (pNK_ZLEC IN NUMBER, pINST IN NUMBER DEFAULT 0)
AS
BEGIN
  --DELETE FROM harmon WHERE nr_komp_zlec=pNK_ZLEC and pINST in (0,nr_komp_inst);
  INSERT INTO harmon (nr_komp_zlec, typ_harm, nr_oddz, rok, mies,  
                     nr_komp_inst, nr_inst, typ_inst, nr_komp_zm, dzien, zmiana,
                     ilosc, wielkosc, il_z_zam, dane_z_zam,
                     zatwierdz, spad, godz_pocz, godz_kon, kol_na_zm)--, awaria)
   SELECT V.nr_kom_zlec, 'P', (select nr_odz from firma), to_number(to_char(PKG_CZAS.NR_ZM_TO_DATE(V.nr_zm_plan),'YYYY'),'9999'), to_number(to_char(PKG_CZAS.NR_ZM_TO_DATE(V.nr_zm_plan),'MM'),'99'),
          V.nr_inst_plan, max(I.nr_inst), max(substr(I.ty_inst,1,3)), V.nr_zm_plan, PKG_CZAS.NR_ZM_TO_DATE(V.nr_zm_plan), PKG_CZAS.NR_ZM_TO_ZM(V.nr_zm_plan),
          count(decode(symb_obr,'DECOAT',null,1)), sum(V.il_obr*V.wsp_p), round(sum(V.wsp_p)), sum(V.il_obr), --IL_Z_ZAM <- Iloœc sztuk przelicz.
          0, 0, '000000', '000000', 0   --,decode(max(V.zakl_kol_pop+V.zakl_kol_nast),0,0,3)
   FROM v_wyc2 V
--   LEFT JOIN spisz P ON P.nr_kom_zlec=V.nr_kom_zlec and P.nr_poz=V.nr_poz_zlec       
--   LEFT JOIN slparob O ON O.nr_k_p_obr=V.nr_obr
   LEFT JOIN parinst I ON I.nr_komp_inst=V.nr_inst_plan
--   LEFT JOIN kat_gr_plan G ON G.typ_kat=V.indeks AND G.nkomp_instalacji=V.nr_inst_plan
   WHERE V.nr_kom_zlec=pNK_ZLEC and V.nr_zm_plan>0 and pINST in (0,V.nr_inst_plan)
   GROUP BY V.nr_kom_zlec, V.nr_inst_plan, V.nr_zm_plan;
EXCEPTION WHEN OTHERS THEN
 ZAPISZ_LOG('ZAPISZ_HARMON',pNK_ZLEC,'C',0);
 ZAPISZ_ERR(SQLERRM);
 RAISE;
END ZAPISZ_HARMON;
/

create or replace PROCEDURE ZAPISZ_SPISP (pNK_ZLEC IN NUMBER, pINST IN NUMBER DEFAULT 0, pPOZ IN NUMBER DEFAULT 0)
AS
BEGIN
  --DELETE FROM spisp WHERE numer_komputerowy_zlecenia=pNK_ZLEC and pINST in (0,nr_kom_inst) and pPOZ in (0,nr_poz);
  INSERT INTO spisp (numer_komputerowy_zlecenia, nr_poz, nr_oddz, 
                     nr_kom_inst, zm_plan, data_plan, czas_plan,
                     il_plan, --wsp_plan,
                     nr_kom_inst_wyk, zm_wyk, data_wyk, czas_wyk,
                     il_wyk, --wsp_wyk,
                     spad, oper, /*data_zatw,*/ czas)
   SELECT V.nr_kom_zlec, V.nr_poz_zlec, 0,
          V.nr_inst_plan, V.nr_zm_plan, PKG_CZAS.NR_ZM_TO_DATE(V.nr_zm_plan) d_plan, 0,
          count(1) il_plan, --max(V.wsp_p), 
          V.nr_inst_wyk, abs(V.nr_zm_wyk), decode(sign(V.nr_zm_wyk),1,PKG_CZAS.NR_ZM_TO_DATE(V.nr_zm_wyk),to_date('1901/01','YYYY/MM')), 0 czas_wyk,
          count(decode(V.nr_zm_wyk,0,0,1)), --max(V.wsp_w),
          0, ' ', 0
   FROM v_wyc2 V
--   LEFT JOIN spisz P ON P.nr_kom_zlec=V.nr_kom_zlec and P.nr_poz=V.nr_poz_zlec       
--   LEFT JOIN slparob O ON O.nr_k_p_obr=V.nr_obr
   LEFT JOIN parinst I ON I.nr_komp_inst=V.nr_inst_plan
--   LEFT JOIN kat_gr_plan G ON G.typ_kat=V.indeks AND G.nkomp_instalacji=V.nr_inst_plan
   WHERE V.nr_kom_zlec=pNK_ZLEC and V.nr_zm_plan+abs(V.nr_zm_wyk)>0 and pINST in (0,V.nr_inst_plan) and pPOZ in (0,V.nr_poz_zlec) and I.ty_inst in ('MON','STR')
   GROUP BY V.nr_kom_zlec, V.nr_poz_zlec, V.nr_inst_plan, V.nr_zm_plan, V.nr_inst_wyk, V.nr_zm_wyk;
EXCEPTION WHEN OTHERS THEN
 ZAPISZ_LOG('ZAPISZ_SPISP',pNK_ZLEC,'C',0);
 ZAPISZ_ERR(SQLERRM);
 RAISE;
END ZAPISZ_SPISP;
/

create or replace PROCEDURE ZAPISZ_WYKZAL (pNK_ZLEC IN NUMBER, pINST IN NUMBER DEFAULT 0, pPOZ IN NUMBER DEFAULT 0)
AS
BEGIN
  INSERT INTO wykzal (nr_komp_zlec, nr_poz, nr_warst, straty,--nr_warst_do,
                      indeks, nr_komp_obr,
                      il_calk, il_jedn,
                      nr_komp_instal, nr_zm_plan, d_plan, zm_plan,
                      il_plan, il_zlec_plan, wsp_przel,
                      --nr_komp_inst_wyk, 
                      nr_komp_zm, d_wyk, zm_wyk,
                      il_wyk, nr_oper, il_zlec_wyk, --wsp_wyk,
                      flag, --straty, nr_kat,
                      kod_dod, nr_komp_gr)
   SELECT V.nr_kom_zlec, V.nr_poz_zlec, V.nr_warst, decode(sign(max(V.nr_warst_do)-V.nr_warst),1,max(V.nr_warst_do),0),
          decode(K.rodz_sur,'KRA',V.kod_dod,V.indeks),
          decode(K.rodz_sur,'KRA',0,case when instr(nry_porz||',',',')>3 then V.nr_obr else V.nr_kat_obr end) nr_komp_obr, --nr_porz>100
          max(P.ilosc) il_calk, max(V.il_obr) il_jedn,
          V.nr_inst_plan, V.nr_zm_plan, PKG_CZAS.NR_ZM_TO_DATE(V.nr_zm_plan) d_plan , PKG_CZAS.NR_ZM_TO_ZM(V.nr_zm_plan) zm_plan,
          case when max(trim(I.ty_inst)) in ('A C', 'R C') then count(distinct nr_szt) else count(1) end il_plan, sum(V.il_obr) il_zlec_plan, max(V.wsp_p), 
          --V.nr_inst_wyk, 
          abs(V.nr_zm_wyk), decode(sign(V.nr_zm_wyk),1,PKG_CZAS.NR_ZM_TO_DATE(V.nr_zm_wyk),to_date('1901/01','YYYY/MM')), decode(sign(V.nr_zm_wyk),1,PKG_CZAS.NR_ZM_TO_ZM(V.nr_zm_wyk),0),
          sum(decode(V.nr_zm_wyk,0,0,1)), ' ', sum(decode(V.nr_zm_wyk,0,0,V.il_obr)), --max(V.wsp_w),
          decode(sign(V.nr_zm_wyk),0,1,1,3,2), --0, max(decode(K.rodz_sur,'KRA',V.nr_kat_obr,V.nr_kat)),
          decode(max(K.rodz_sur),'KRA',' ',V.kod_dod), decode(max(I.rodz_plan),1,nvl(max(G.nkomp_grupy),0),0)
   FROM v_wyc2 V
   LEFT JOIN spisz P ON P.nr_kom_zlec=V.nr_kom_zlec and P.nr_poz=V.nr_poz_zlec       
   --LEFT JOIN slparob O ON O.nr_k_p_obr=V.nr_obr
   LEFT JOIN katalog K ON K.nr_kat=V.nr_kat_obr
   LEFT JOIN parinst I ON I.nr_komp_inst=V.nr_inst_plan
   LEFT JOIN kat_gr_plan G ON G.typ_kat=V.indeks AND G.nkomp_instalacji=V.nr_inst_plan
   WHERE V.nr_kom_zlec=pNK_ZLEC and pINST in (0,V.nr_inst_plan) and pPOZ in (0,V.nr_poz_zlec) and I.ty_inst not in ('MON','STR') and (pINST>0 or I.ty_inst<>'A C') and V.nr_zm_plan+abs(V.nr_zm_wyk)>0
   GROUP BY V.nr_kom_zlec, V.nr_poz_zlec, V.nr_warst,
            decode(K.rodz_sur,'KRA',V.kod_dod,V.indeks),
            /*nr_komp_obr*/decode(K.rodz_sur,'KRA',0,case when instr(nry_porz||',',',')>3 then V.nr_obr else V.nr_kat_obr end),
            V.kod_dod, V.nr_inst_plan, V.nr_zm_plan, V.nr_inst_wyk, V.nr_zm_wyk;
--EXCEPTION WHEN OTHERS THEN
-- ZAPISZ_LOG('ZAPISZ_WYKZAL',pNK_ZLEC,'C',0);
-- ZAPISZ_ERR(SQLERRM);
END ZAPISZ_WYKZAL;
/

create or replace PROCEDURE "ZAPISZ_ZLEC_ZM" (pNK_ZLEC NUMBER, pTYP CHAR, pOPIS VARCHAR2, pNK_ZM IN OUT NUMBER)
AS
 vSID NUMBER:=0;
 vData DATE;
 vCzas CHAR(6);
 vOper VARCHAR2(20);
 vOperNr NUMBER(10);
 vNrZlec NUMBER(10);
 vOpisZlec VARCHAR2(10);
begin
 IF nvl(pNK_ZM,0)=0 THEN
   --SELECT zlec_zm_seq.nextval INTO pNK_ZM FROM dual;
   --UPDATE konfig_t SET ost_nr=ost_nr+1 WHERE nr_par=32
   --RETURNING ost_nr INTO pNK_ZM;
   SELECT KONFIG_T32_SEQ.nextval INTO pNK_ZM FROM dual;
 END IF;

 SELECT nr_zlec, forma_wprow||status||decode(do_produkcji,1,'Y','N')||to_char(flag_r)
   INTO vNrZlec, vOpisZlec
 FROM zamow
 WHERE nr_kom_zlec=pNK_ZLEC;

 SELECT SYS_CONTEXT('USERENV','SESSIONID'), trunc(SYSDATE), to_char(SYSDATE,'HH24MISS')
   INTO vSID, vData, vCzas
 FROM DUAL;

 SELECT nvl(max(operator_id),'brak wpisu logowania') INTO vOper
 FROM (select rownum lp, operator_id from (select operator_id from logowania where session_ID=vSID order by vData desc, vCzas desc))
 WHERE lp=1;

 SELECT nvl(max(nr_oper),0) INTO vOperNr
 FROM operatorzy
 WHERE id=vOper;

 INSERT INTO zlec_zm (nk_zm, nk_zlec, nr_zlec, data, czas, oper, typ, opis)
        VALUES (pNK_ZM, pNK_ZLEC, vNrZlec, vData, vCzas, vOperNr, pTYP, pOPIS||' /'||vOpisZlec);
END ZAPISZ_ZLEC_ZM;
/

--@V inna definicja tabeli
/*create or replace PROCEDURE ZAPISZ_ZLEC_ZMP (pNK_ZM NUMBER, pTYP CHAR, pPOZ_AKT NUMBER, pNR_POLA NUMBER, pNAZ_POLA VARCHAR2, pPOZ_PRZED NUMBER,  pPOLE_PRZED VARCHAR2, pPOZ_PO NUMBER, pPOLE_PO VARCHAR2)
AS
BEGIN
  INSERT INTO zlec_zmp (nk_zm, typ, poz_akt, nr_pola, naz_pola, poz_przed, pol_przed, poz_po, pole_po)
               VALUES  (pNK_ZM, pTYP, pPOZ_AKT, pNR_POLA, pNAZ_POLA, pPOZ_PRZED, pPOLE_PRZED, pPOZ_PO, pPOLE_PO);
END ZAPISZ_ZLEC_ZMP;
*/

create or replace PROCEDURE LWYC2_WG_PLAN_OLD (pFUN IN NUMBER, pNK_ZLEC IN NUMBER)
AS 
 CURSOR c1 IS
 SELECT DISTINCT nr_kom_zlec, nr_poz_zlec, indeks, nr_warst, nr_kat_obr, ile_rodz_obr, nr_obr, zn_plan, nr_kat,--DISTINCT dla zabezpieczenia przed "podwojeniem" rekordów np. przez link do W1
                 nr_inst_plan, nr_zm_plan, il_wpisow, il_szt, inst_plan_old, nr_zm_old, il_plan_old, src, I.ty_inst typ_inst--, I.naz_inst
 FROM
 (Select V.nr_kom_zlec, V.nr_poz_zlec, V.indeks, V.nr_warst, V.nr_kat_obr, V.ile_rodz_obr, V.nr_obr, V.zn_plan, V.nr_kat,
         V.nr_inst_plan, V.nr_zm_plan, V.il_wpisow, V.il_szt,
        --ta linia bo chcemy zaplanowac obr=15 (zatepianie) na instalacji powi¹zanej do hartowania
        --case when V.ile_rodz_obr=1 and V.nr_obr=15 and W.nr_komp_obr=4000 then I.nr_inst_pow else  W.nr_komp_instal end nr_inst_plan,
         decode(V.nr_obr,99,P.nr_kom_inst,nvl(W.nr_komp_instal,nvl(I.nr_inst_pow,nvl(W1.nr_komp_instal,nvl(H.nr_komp_inst,null))))) inst_plan_old,
         decode(V.nr_obr,99,P.zm_plan,    nvl(W.nr_zm_plan,nvl(W2.nr_zm_plan,nvl(W1.nr_zm_plan,nvl(PKG_CZAS.NR_KOMP_ZM(H.dzien,H.zmiana),0))))) nr_zm_old,
         --decode(V.nr_obr,99,P.il_plan,    nvl(W.il_plan,nvl(W2.il_plan,nvl(W1.il_plan,nvl(H.ilosc,0))))) il_plan_old,
         --obsluzenie dzielonych pozycji planu w SPISP
         decode(V.nr_obr,99,(select sum(P1.il_plan) from spisp P1 where P1.numer_komputerowy_zlecenia=V.nr_kom_zlec and P1.nr_poz=P.nr_poz and P1.nr_kom_inst=P.nr_kom_inst and P1.zm_plan=P.zm_plan),
                nvl2(W.nr_komp_instal,(select sum(A.il_plan) from wykzal A where A.nr_komp_zlec=V.nr_kom_zlec and A.nr_poz=W.nr_poz and A.nr_komp_instal=W.nr_komp_instal and A.nr_zm_plan=W.nr_zm_plan),
                 nvl2(W2.nr_komp_instal,(select sum(A.il_plan) from wykzal A where A.nr_komp_zlec=V.nr_kom_zlec and A.nr_poz=W2.nr_poz and A.nr_komp_instal=W2.nr_komp_instal and A.nr_zm_plan=W2.nr_zm_plan),
                  nvl2(W1.nr_komp_instal,(select sum(A.il_plan) from wykzal A where A.nr_komp_zlec=V.nr_kom_zlec and A.nr_poz=W1.nr_poz and A.nr_komp_instal=W1.nr_komp_instal and A.nr_zm_plan=W1.nr_zm_plan),
                   nvl(H.ilosc,0))))) il_plan_old,
         case when P.il_plan is not null then 'P'
              when W.il_plan is not null then 'W'
              when W2.il_plan is not null then 'W2'
              when W1.il_plan is not null then 'W1'
              when H.ilosc is not null then 'H' else null end src
         --decode(V.nr_obr,23,P.nr_kom_inst,W.nr_komp_instal) inst_plan_old,
         --decode(V.nr_obr,23,P.il_plan,W.il_plan) il_plan_old,
         --decode(V.nr_obr,23,P.zm_plan,W.nr_zm_plan) nr_zm_old,
         --decode(V.nr_obr,23,P.data_plan,W.d_plan) data_old,
         --decode(V.nr_obr,23,PKG_CZAS.NR_ZM_TO_ZM(P.zm_plan),W.zm_plan) zm_old
  From
  --podzapytanie zwracaj¹ce z L_WYC2 dane pogrupowane na  obrobki (wczesniej czynnosci) i zmiany (na warstwie), ewentualnie A C i R C dla obr 90,91
  (select L2.nr_kom_zlec, L2.nr_poz_zlec, max(S.indeks) indeks, L2.nr_warst, max(decode(S.zn_war,'Obr',S.nr_kat_obr,nvl(O.nr_kat_obr,0))) nr_kat_obr, max(S.nr_kat) nr_kat,
          max(O.nr_komp_inst) nk_inst_dla_obr, max(sign(L2.nr_porz_obr-S.nr_porz)) inst_pow, --jesli rozne to 1 co oznacza inst powiazan¹
          L2.nr_obr, count(distinct L2.nr_obr) ile_rodz_obr, max(S.zn_plan) zn_plan,
          L2.nr_inst_plan, L2.nr_zm_plan, L.typ_inst,
          count(1) il_wpisow, count(distinct L2.nr_kom_zlec*1000000000+L2.nr_poz_zlec*100000+L2.nr_szt*100+L2.nr_warst+decode(S.zn_war,'Obr',S.nr_kat,nvl(O.nr_kat_obr,S.nk_obr))*0.0001) il_szt
   from l_wyc2 L2
   left join l_wyc L on L.nr_kom_zlec=L2.nr_kom_zlec and L.nr_poz_zlec=L2.nr_poz_zlec and L.nr_szt=L2.nr_szt and L.nr_warst=L2.nr_warst and L2.nr_obr in (90,91) and L.typ_inst in ('A C','R C')
   left join spiss S on zrodlo='Z' and nr_komp_zr=L2.nr_kom_zlec and S.nr_kol=L2.nr_poz_zlec and S.nr_porz in (L2.nr_porz_obr,L2.nr_porz_obr-1500) --inst powiaz. przesunieta o 1500
   left join slparob O on O.nr_k_p_obr=L2.nr_obr
   where L2.nr_kom_zlec=pNK_ZLEC
     --and L2.nr_poz_zlec=2 and L2.nr_warst=3 and L2.nr_obr=90
   group by L2.nr_kom_zlec, L2.nr_poz_zlec, L2.nr_warst, L2.nr_obr, L2.nr_inst_plan, L2.nr_zm_plan, L.typ_inst
            --decode(S.zn_war,'Obr',S.nr_kat_obr,nvl(O.nr_kat_obr,0))
  ) V
  --szukanie takiej obróbki w WYKZAL
  Left join wykzal W on W.nr_komp_zlec=V.nr_kom_zlec and W.nr_poz=V.nr_poz_zlec 
                    --and (W.nr_warst=V.nr_warst or W.nr_warst=0 and W.nr_kat=V.nr_kat) --@P na inst Szprosy nie zapisany NR_WARST
                    and (W.nr_warst=V.nr_warst or V.nr_obr=94 and V.nr_warst between W.nr_warst and W.straty) --@V Szprosy maj¹ zapisany NR_WARST, dodatkowo planowanie LAM_P
                    and V.nr_obr not in (99) --Zesp
                    and (   W.nr_komp_obr>0 and W.nr_komp_obr in (V.nr_obr,V.nr_kat_obr)
                         --or W.nr_komp_obr=0 and W.nr_kat=V.nr_kat_obr and W.nr_kat>0 @P
                         --or W.nr_komp_obr=0 and W.nr_kat=V.nr_kat     and W.nr_kat>0 @P
                         or W.nr_komp_obr=0 and V.ile_rodz_obr=1 and V.nr_obr in (93,94,95) and W.nr_komp_instal=V.nk_inst_dla_obr --SZP, LAM i LAM_P (instalacja domyœlna dla obróbki)
                         or W.nr_komp_obr=0 and V.ile_rodz_obr=1 and V.nr_obr in (90,91)  --CF,CL
                            and V.typ_inst='R C'
                            and EXISTS(select 1 from parinst where nr_komp_inst=W.nr_komp_instal and ty_inst in ('R C','PIL'))
                         or W.nr_komp_obr=V.nr_kat and V.ile_rodz_obr=1 and V.nr_obr in (96,97,92)  --G,G1,PRZ (w Wykzal.nr_komp_obr zapisany NR_KAT)
                         or W.nr_komp_obr=0 and V.ile_rodz_obr=1 and V.nr_obr in (96,97)  --G,G1 na inst SZPROSY (w Wykzal.nr_komp_obr zapisane 0)
                            and (select ty_inst from parinst I where I.nr_komp_inst=W.nr_komp_instal)='SZP'
                            and (select rodz_sur from surzam S where S.nr_komp_zlec=W.nr_komp_zlec and S.indeks=W.indeks)='LIS'
                         )
                    and (inst_pow=0 and (select akt from gr_inst_dla_obr G where G.nr_komp_obr=V.nr_obr and G.nr_komp_inst=W.nr_komp_instal)<>2 or
                         inst_pow=1 and (select akt from gr_inst_dla_obr G where G.nr_komp_obr=V.nr_obr and G.nr_komp_inst=W.nr_komp_instal)=2) 
  --dla Zatepiania (jesli nie znalaz w W) szukanie inst. powi¹zanej do Hart @P
  Left join wykzal W2 on W2.nr_komp_zlec=V.nr_kom_zlec and W2.nr_poz=V.nr_poz_zlec and W2.nr_warst=V.nr_warst and V.ile_rodz_obr=1 and V.nr_obr=1000015 --Zatep @P
                    and W.nr_komp_obr is null and W2.nr_komp_obr=4000
  Left join parinst I on I.nr_komp_inst=W2.nr_komp_instal
  --szukanie w WYKZAL dla A_C
  Left join wykzal W1 on W1.nr_komp_zlec=V.nr_kom_zlec and W1.nr_poz=0 and W1.nr_warst=0 and W1.indeks=V.indeks and W1.il_plan>0 and W1.nr_zm_plan>0 and V.nr_obr in (90,91) --CF,CP
  --@P Left join wykzal W1 on W1.nr_komp_zlec=V.nr_kom_zlec and W1.nr_poz=0 and W1.nr_warst=0 and W1.nr_kat=V.nr_kat and W1.il_plan>0 and W1.nr_zm_plan>0 and V.nr_obr in (7,8) --C,CP
  Left join harmon H on H.nr_komp_zlec=V.nr_kom_zlec and H.typ_harm='P' and H.typ_inst='A C' and H.ilosc>0 and V.nr_obr in (90,91) and W1.nr_komp_zlec is null
  --szukanie zmiany dla obr 99 - zespalanie
  Left join spisp P on P.numer_komputerowy_zlecenia=V.nr_kom_zlec and P.nr_poz=V.nr_poz_zlec and V.nr_obr=99
 )
 LEFT JOIN parinst I on nr_komp_inst=inst_plan_old
 WHERE inst_plan_old in (select nr_komp_inst from gr_inst_dla_obr G where G.nr_komp_obr=nr_obr)
 ORDER BY nr_kom_zlec, zn_plan, nr_kat_obr, decode(src,'W',1,'W2',2,'W1',3,'P',4,'H',5,9), --rekordy z Harm na koncu, ¿eby nie podbierac danych z W1
          nr_poz_zlec, nr_warst, decode(nr_zm_plan,0,9999999,nr_zm_plan), nr_inst_plan; --DECODE bo jeœli pozycja podzielona w L_WYC2, to najpierw wpisane zmiany

 CURSOR c2 (pZLEC NUMBER, pPOZ NUMBER, pWAR NUMBER, pOBR NUMBER, pNR_KAT_OBR NUMBER, pINST NUMBER, pZM NUMBER, pINST_OLD NUMBER) IS
  Select L2.*
  From l_wyc2 L2
  Left join l_wyc L on L.nr_kom_zlec=L2.nr_kom_zlec and L.nr_poz_zlec=L2.nr_poz_zlec and L.nr_szt=L2.nr_szt and L.nr_warst=L2.nr_warst and L.nr_inst=pINST_OLD
  Where L2.nr_kom_zlec=pZLEC and L2.nr_poz_zlec=pPOZ and L2.nr_warst=pWAR
    and (pOBR>0 and L2.nr_obr=pOBR or 
         pNR_KAT_OBR>0 and (select S.nr_kat from spiss S where zrodlo='Z' and S.nr_komp_zr=L2.nr_kom_zlec and S.nr_kol=L2.nr_poz_zlec and S.nr_porz=L2.nr_porz_obr)=pNR_KAT_OBR)
    and L2.nr_inst_plan=pINST and L2.nr_zm_plan=pZM
  Order by L2.nr_kom_zlec, L2.nr_poz_zlec, L2.nr_warst, L.nr_szt nulls last, L2.nr_szt, L2.nr_obr
 FOR UPDATE;
 rec1 c1%ROWTYPE;
 rec2 c2%ROWTYPE;
 vNrSzt NUMBER;
 licznik NUMBER;
 ileWpisane NUMBER;
BEGIN
 OPEN c1;
 LOOP
  FETCH c1 INTO rec1;
  EXIT WHEN c1%NOTFOUND;
  IF rec1.inst_plan_old is not null AND rec1.inst_plan_old>0 THEN
   --konieczne sprawdzenie czy nie zostalo to juz wpisane (gdy dzielone pozycje (np. na kilka zmian A_C)
   SELECT count(distinct L.nr_kom_zlec*1000000000+L.nr_poz_zlec*100000+L.nr_szt*100+L.nr_warst+decode(S.zn_war,'Obr',S.nr_kat,nvl(O.nr_kat_obr,S.nk_obr))*0.0001)
     INTO ileWpisane
   FROM l_wyc2 L
   LEFT JOIN spiss S on zrodlo='Z' and S.nr_komp_zr=L.nr_kom_zlec and S.nr_kol=L.nr_poz_zlec and S.nr_porz=L.nr_porz_obr
   LEFT JOIN slparob O on O.nr_k_p_obr=L.nr_obr
   WHERE nr_kom_zlec=rec1.nr_kom_zlec
     AND (rec1.typ_inst='A C' and (rec1.src='W1' and S.nr_kat=rec1.nr_kat or rec1.src='H')
          or L.nr_poz_zlec=rec1.nr_poz_zlec and L.nr_warst=rec1.nr_warst and decode(S.zn_war,'Obr',S.nr_kat,nvl(O.nr_kat_obr,0))=rec1.nr_kat_obr)
     AND nr_inst_plan=rec1.inst_plan_old AND nr_zm_plan=rec1.nr_zm_old;
   --aktualizacja przez kursor a nie przez 1 UPDATE, zeby obsluzyc ORDER BY po NR_SZT
   OPEN c2 (rec1.nr_kom_zlec, rec1.nr_poz_zlec, rec1.nr_warst,
            case when rec1.ile_rodz_obr=1 then rec1.nr_obr else 0 end,
            rec1.nr_kat_obr, rec1.nr_inst_plan, rec1.nr_zm_plan, rec1.inst_plan_old);
   licznik:=0; vNrSzt:=0;
   LOOP
    FETCH c2 INTO rec2;
    EXIT WHEN c2%NOTFOUND OR licznik>=rec1.il_plan_old-ileWpisane and rec2.nr_szt<>vNrSzt;
    UPDATE l_wyc2
    SET nr_inst_plan=rec1.inst_plan_old, nr_zm_plan=rec1.nr_zm_old, flag=decode(pFUN,1,-1,flag)
    WHERE CURRENT OF c2;
    IF rec2.nr_szt<>vNrSzt THEN
     licznik:=licznik+1;
     vNrSzt:=rec2.nr_szt;
    END IF; 
    --EXIT WHEN licznik>=rec1.il_plan_old-ileWpisane;
   END LOOP;
   CLOSE c2;
  END IF;
 END LOOP; 
 CLOSE c1;
 ZAPISZ_LOG('LWYC2_WG_PLAN_OLD',pNK_ZLEC,'C',-pFUN);
EXCEPTION WHEN OTHERS THEN
 IF c1%ISOPEN THEN CLOSE c1; END IF;
 IF c2%ISOPEN THEN CLOSE c2; END IF;
 ZAPISZ_LOG('LWYC2_WG_PLAN_OLD',pNK_ZLEC,'E',0);
 ZAPISZ_ERR(SQLERRM);
 RAISE;
END LWYC2_WG_PLAN_OLD;
/

CREATE OR REPLACE FORCE VIEW "V_PLAN1" ("ZAKR_GR", "INST_ZAKR", "DZIEN_ZAKR", "ZM_ZAKR", "NR_ZM_ZAKR", "NR_INST_PLAN", "NR_ZM_PLAN", "DZIEN", "ZM", "NR_KOM_ZLEC", "NR_POZ_ZLEC", "NR_WARST", "NR_OBR", "NR_SZT", "ETAP_MAX", "KOLEJN_MAX", "ILE_WPISOW", "IL_SZYB", "IL_WYC", "IL_OBR", "POW_SUR", "GINST", "GZM", "GZLEC", "GPOZ_WAR_OBR", "GSZT")
AS 
 SELECT decode(L1.nr_inst_plan,L2.nr_inst_plan,3,4) ZAKR_GR,
        L1.nr_inst_plan inst_zakr,
        PKG_CZAS.NR_ZM_TO_DATE(L1.nr_zm_plan) dzien_zakr,
        PKG_CZAS.NR_ZM_TO_ZM(L1.nr_zm_plan) zm_zakr,
        L1.nr_zm_plan nr_zm_zakr, 
        L2.nr_inst_plan, /*max(I.kolejn),*/ L2.nr_zm_plan, PKG_CZAS.NR_ZM_TO_DATE(L2.nr_zm_plan) dzien, PKG_CZAS.NR_ZM_TO_ZM(L2.nr_zm_plan) zm,
        L1.nr_kom_zlec, 0 nr_poz_zlec, 0 nr_warst, 0 nr_obr, 0 nr_szt,
        max(S.etap), max(S.zn_plan) kolejn_max,
        COUNT(1) ile_wpisow,
        COUNT(DISTINCT L2.nr_kom_zlec*10000*1000+L2.nr_poz_zlec*1000+L2.nr_szt) ile_szyb,
        COUNT(DISTINCT L2.nr_kom_zlec*10000*1000+L2.nr_poz_zlec*1000+L2.nr_szt+S.etap*0.1+L2.nr_warst*0.001) ile_wycinków,
        SUM(S.il_obr) il_obr,
        sum(S0.il_sur) pow_sur,
        0 gINST, 0 gZm, 1 gZLEC, 0 , 0 gSZT
--        case when GROUPING(L2.nr_inst_plan)=0 and GROUPING(L2.nr_zm_plan)=1 then 1 else 0 end  gINST,
--        case when GROUPING(L2.nr_zm_plan)=0 and GROUPING(L1.nr_kom_zlec)=1 then 1 else 0 end  gZM,
--        case when GROUPING(L1.nr_kom_zlec)=0 and GROUPING(L1.nr_poz_zlec)=1 then 1 else 0 end  gZLEC,
--        case when GROUPING(L1.nr_poz_zlec)=0 and GROUPING(L1.nr_warst)=0 and GROUPING(L2.nr_obr)=0 and GROUPING(L1.nr_szt)=1 then 1 else 0 end  gPOZ_WAR_OBR,
--        case when GROUPING(L1.nr_szt)=0 then 1 else 0 end gSZT
  --FROM (select distinct nr_kom_zlec, nr_poz_zlec, nr_szt, nr_warst, nr_inst_plan, nr_zm_plan from l_wyc2) L1
  FROM l_wyc2 L1
  LEFT JOIN l_wyc2 L2 ON L1.nr_kom_zlec=L2.nr_kom_zlec and L1.nr_poz_zlec=L2.nr_poz_zlec and  L1.nr_szt=L2.nr_szt
                         and (case when L2.kolejn>L1.kolejn then (case when L1.nr_warst between L2.nr_warst and L2.war_do then 1 else 0 end)
                                   when L2.kolejn=L1.kolejn then (case when L1.nr_warst=L2.nr_warst and L1.war_do=L2.war_do then 1 else 0 end)
                                   when L2.kolejn<L1.kolejn then (case when L2.nr_warst between L1.nr_warst and L1.war_do then 1 else 0 end)
                              else 0 end) = 1
  LEFT JOIN spiss S ON  S.zrodlo='Z' AND S.nr_komp_zr=L2.nr_kom_zlec AND S.nr_kol=L2.nr_poz_zlec AND S.nr_porz=L2.nr_porz_obr
  LEFT JOIN spiss S0 ON S0.zrodlo=S.zrodlo AND S0.nr_komp_zr=S.nr_komp_zr AND S0.nr_kol=S.nr_kol
       AND S0.etap=S.etap AND S.war_od BETWEEN S0.war_od AND S0.war_do AND S0.czy_war=1 AND S0.strona=0
  --LEFT JOIN parinst I ON I.nr_komp_inst=L2.nr_inst_plan
  --WHERE L1.nr_kom_zlec=474580 AND L1.nr_inst_plan=12 AND L1.nr_zm_plan=23293 AND L2.nr_porz_obr is not null
  WHERE L2.nr_porz_obr is not null and L2.nr_inst_plan>0 and L2.nr_zm_plan>0 and L1.nr_kom_zlec>0 -- and L1.nr_kom_zlec=465935 
  --GROUP BY  L1.nr_inst_plan, PKG_CZAS.NR_ZM_TO_DATE(L1.nr_zm_plan), L2.nr_inst_plan,rollup(L1.nr_zm_plan, L2.nr_zm_plan, L1.nr_kom_zlec, L1.nr_poz_zlec, L1.nr_warst, L2.nr_obr, L1.nr_szt, S.etap)
  GROUP BY L1.nr_inst_plan, /*PKG_CZAS.NR_ZM_TO_DATE(L1.nr_zm_plan),*/ L1.nr_zm_plan, L2.nr_inst_plan, L2.nr_zm_plan, L1.nr_kom_zlec;
/

CREATE OR REPLACE VIEW V_ZMIANY
AS
SELECT 'P' typ_harm, nr_komp_inst, nr_komp_zm, dzien, zmiana, il_plan, ilosc, dane_z_zam, wielk_plan, wielkosc, il_szt_przel, dl_zmiany, zatwierdz,
       nvl2(nullif(il_plan,nvl(ilosc,0)),'0','1') || nvl(flag_h,'1') flag_d
FROM zmiany Z
LEFT JOIN
 (select typ_harm, nr_komp_inst, dzien, zmiana, sum(ilosc) ilosc, sum(wielkosc) wielkosc, sum(dane_z_zam) dane_z_zam, sum(il_z_zam) il_szt_przel,
         min(case when ilosc=il_z_zam and wielkosc<>dane_z_zam then 0 else 1 end) flag_h
  from harmon
  where typ_harm='P'
  group by nr_komp_inst, typ_harm, dzien, zmiana) H
USING (nr_komp_inst, dzien, zmiana);
--ON H.nr_komp_inst=Z.nr_komp_inst and H.dzien=Z.dzien and H.zmiana=Z.zmiana;
/

create or replace TRIGGER ZAMOW_ON_DELETE 
BEFORE DELETE ON ZAMOW 
FOR EACH ROW
WHEN (OLD.FLAG_R=0)
BEGIN
  delete from l_wyc2
  where nr_kom_zlec=:OLD.NR_KOM_ZLEC and nr_inst_wyk=0;
  delete from l_wyc2
  where nr_kom_zlec=-(:OLD.NR_KOM_ZLEC) and nr_inst_wyk=0;
  delete from l_wyc
  where nr_kom_zlec=:OLD.NR_KOM_ZLEC and nr_inst_wyk=0;
END;
/