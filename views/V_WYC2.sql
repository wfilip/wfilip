CREATE OR REPLACE VIEW "V_WYC2"
 ("NR_KOM_ZLEC", "NR_ZLEC", "NR_POZ_ZLEC", "ID_POZ", "SORT", "IDENT_BUD", "NR_SZT", "NR_WARST", "NR_WARST_DO",
  "ID_SZYBY", "ID_WYC", "CZY_WAR", "ZN_WAR", "INDEKS", "NR_KAT", "NR_GR", "ETAP", "KOLEJN", "ZN_PLAN", "NR_OBR", "SYMB_OBR", "NR_KAT_OBR", "OBR_JEDNOCZ", "OBR_LACZ",
  "KOD_DOD", "IL_DOD", "NR_INST_PLAN", "NR_ZM_PLAN", "NR_INST_WYK", "NR_ZM_WYK", "WSP_P", "WSP_W", "WSP_P0", "CZAS_PRZEZBR_MIN", "KTORA_OBR_NA_INST",
  "CIAG_NR_INST", "CIAG_PROD", "ILE_WPISOW", "NRY_PORZ",
  "IL_OBR", "POW_SUR", "OBSL_TECH", "ZAKL_KOL_POP", "ZAKL_KOL_NAST")
 AS 
   SELECT /*+ use_nl (L S S0 W1 W2)*/ 
  L.nr_kom_zlec, max(P.nr_zlec), L.nr_poz_zlec, max(P.id_poz), max(decode(P.sort2,0,L.nr_poz_zlec,P.sort2)), max(S0.ident_bud),--max(P.ind_bud),
  L.nr_szt,  L.nr_warst,  L.war_do,
  max(P.id_poz)*100000000+L.nr_szt*1000 id_szyby,
  max(P.id_poz)*100000000+L.nr_szt*1000+S.etap*100+L.nr_warst id_wyc,
  max(S.czy_war), max(S0.zn_war), MAX(S0.indeks) indeks,  MAX(S0.nr_kat), max(nvl(G.nkomp_grupy,0)),
  S.etap, MIN(L.kolejn) kolejn, max(S.zn_plan+sign(L.nr_porz_obr-S.nr_porz)*0.5), --dadanie 0.5 jesli rekord dla inst. powi¹zanej czyli L.NR_PORZ_OBR=S.NR_PORZ+1500
  L.nr_obr, max(O.symb_p_obr), /*max(decode(S.zn_war,'Obr',S.nr_kat,O.nr_kat_obr))*/ max(S.nr_kat_obr) nr_kat_czynn, max(O.obr_jednocz), max(O.obr_lacz), S.kod_dod, sum(S.il_sur) il_dod,  
  L.nr_inst_plan,  L.nr_zm_plan,  L.nr_inst_wyk,  L.nr_zm_wyk,
  --max(case when W1.wsp_alt is not null then round(W1.wsp_alt,3) else 1 /*nvl(WSP_PLAN('Z', L.nr_kom_zlec, L.nr_poz_zlec, L.nr_porz_obr, L.nr_inst_plan),1)*/ end) wsp_p,
  --max(case when L.nr_inst_wyk=0 then 0 when W2.wsp_alt is not null then round(W2.wsp_alt,3) when W1.wsp_alt is not null then round(W1.wsp_alt,3) else 1 end) wsp_w,
  --04/2018 ppoprawa wyliczania wypadkowego wspolczynnika SUM(IL_OBR*WSP)/SUM(IL_OBR)
  case when sum(S.il_obr)>0 then sum(S.il_obr*W1.wsp_alt)/sum(S.il_obr) else 1.000 end wsp_p,
  case when sum(sign(L.nr_inst_wyk)*S.il_obr)>0 then sum(sign(L.nr_inst_wyk)*S.il_obr*round(nvl(W2.wsp_alt,W1.wsp_alt),3))/sum(sign(L.nr_inst_wyk)*S.il_obr) else 1.000 end wsp_w,
  nvl(max(W0.wsp_alt),0) wsp_p0, sum(decode(I.jedn,'mi',PAR_OBR(1,L.nr_obr,S0.indeks),0)) czas_przezbr_min,
  rank() over (partition by L.nr_kom_zlec,L.nr_poz_zlec,L.nr_szt,L.nr_warst,L.nr_inst_plan order by L.nr_obr) ktora_obr_na_inst,
  ciag_nr_inst(L.nr_kom_zlec,  L.nr_poz_zlec,  L.nr_szt,  L.nr_warst), max(S0.str_dod) ciag_prod,
  COUNT(1) ile_wpisow, listagg(L.nr_porz_obr,',') within group (order by L.kolejn) nry_porz,
  SUM(S.il_obr) il_obr,  MAX(S0.il_sur) pow_sur,  
  -- COUNT(1) ile_wpisow (ile razy ta obróbka w warstwie)
  -- MIN(L.kolejn) kolejn (jeœli obróbka wiecej ni¿ raz to  ma kolejne ró¿ne KOLEJN w l_wyc2
  -- MAX(S.zn_plan), MAX(L.wsp_p) wsp_p,  MAX(L.wsp_w) wsp_w,  MAX(VS.kryt_suma) (MAX() tylko w celu unikniêcia grupowania po tych kolumnach)
  --  nvl(decode(MAX(TKP.obsl),0,8,MAX(TKP.obsl)),0) obsl_tech,
  0 obsl_tech,
  --szukanie w L_WYC2 w rekordach Pop i Nast (wg KOLEJN) zakloconych zmian
  CASE WHEN (select min(Lpop.kolejn) from l_wyc2 Lpop where  Lpop.nr_kom_zlec=L.nr_kom_zlec and Lpop.nr_poz_zlec=L.nr_poz_zlec and  Lpop.nr_warst between L.nr_warst and L.war_do and Lpop.nr_szt=L.nr_szt and Lpop.nr_zm_plan>L.nr_zm_plan)<MIN(L.kolejn) THEN 1 ELSE 0 END zakl_kolejn_pop,
  CASE WHEN (select max(Lnast.kolejn) from l_wyc2 Lnast where  Lnast.nr_kom_zlec=L.nr_kom_zlec and Lnast.nr_poz_zlec=L.nr_poz_zlec and  L.nr_warst between Lnast.nr_warst and Lnast.war_do and Lnast.nr_szt=L.nr_szt and Lnast.nr_zm_plan<L.nr_zm_plan)>MAX(L.kolejn) THEN 1 ELSE 0 END zakl_kolejn_nast
 FROM
  l_wyc2 L 
 --LEFT JOIN gr_inst_dla_obr GO ON GO.nr_komp_obr=L.nr_obr and GO.nr_komp_gr=L.nr_obr and GO.nr_komp_inst=L.nr_inst_plan --bedzie potrzebe dla upewnienia sie czy rekord dla inst powi¹zanej
 LEFT JOIN parinst I ON I.nr_komp_inst=L.nr_inst_plan
 LEFT JOIN spiss S ON  S.zrodlo='Z' AND S.nr_komp_zr=L.nr_kom_zlec AND S.nr_kol=L.nr_poz_zlec AND S.nr_porz in (L.nr_porz_obr,L.nr_porz_obr-1500) --dane dla inst powiaz. przesuniete o 1500
 LEFT JOIN spiss S0 ON S0.zrodlo=S.zrodlo AND S0.nr_komp_zr=S.nr_komp_zr AND S0.nr_kol=S.nr_kol
       AND S0.etap=S.etap AND S.war_od BETWEEN S0.war_od AND S0.war_do AND S0.czy_war=1 AND S0.strona=0
 --LEFT JOIN v_spiss VS on VS.zrodlo=S.zrodlo and VS.nr_kom_zlec=S.nr_komp_zr and VS.nr_poz=S.nr_kol and VS.nr_porz=S.nr_porz and VS.nk_inst=L.nr_inst_plan
 LEFT JOIN slparob O ON O.nr_k_p_obr=L.nr_obr
 LEFT JOIN kat_gr_plan G ON G.typ_kat=S.indeks AND G.nkomp_instalacji=L.nr_inst_plan
 --pobanie wsp plan. i wsp wyk.
 LEFT JOIN wsp_alter W1 ON W1.nr_zestawu=0 and W1.nr_kom_zlec=S.nr_komp_zr and W1.nr_poz=S.nr_kol and W1.nr_porz_obr=S.nr_porz and W1.nr_komp_inst=L.nr_inst_plan
 LEFT JOIN wsp_alter W2 ON W2.nr_zestawu=0 and W2.nr_kom_zlec=S.nr_komp_zr and W2.nr_poz=S.nr_kol and W2.nr_porz_obr=S.nr_porz and W2.nr_komp_inst=L.nr_inst_wyk
 --pobranie wsp. dla warstwy (np. czas polozenia formatki)
 LEFT JOIN wsp_alter W0 ON W0.nr_zestawu=0 and W1.nr_kom_zlec=S0.nr_komp_zr and W0.nr_poz=S0.nr_kol and W0.nr_porz_obr=S0.nr_porz and W0.nr_komp_inst=L.nr_inst_plan
 --pobranie sortu
 LEFT JOIN spisz P ON P.nr_kom_zlec=L.nr_kom_zlec AND P.nr_poz=L.nr_poz_zlec
 --kontrola poprawnoœci techn/      
-- LEFT JOIN (select nr_komp_zlec, max(nr_komp_zap) nr_komp_zap_ost from tech_kontr group by nr_komp_zlec) TK ON TK.nr_komp_zlec=L.nr_kom_zlec
-- LEFT JOIN tech_kontr_poz TKP ON TKP.nr_komp_zap=TK.nr_komp_zap_ost AND
--                                 TKP.nr_komp_zlec=L.nr_kom_zlec AND TKP.id_rek=S.id_rek AND TKP.nr_kolejny=L.nr_porz_obr AND TKP.nr_komp_instal=L.nr_inst_plan
 GROUP BY  L.nr_kom_zlec,  L.nr_poz_zlec,  L.nr_szt,  L.nr_warst, L.war_do, S.etap,  L.nr_obr,  S.kod_dod, L.nr_inst_plan,  L.nr_zm_plan,  L.nr_inst_wyk,  L.nr_zm_wyk;
/ 
