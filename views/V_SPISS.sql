CREATE OR REPLACE VIEW "V_SPISS" ("ZRODLO", "NR_KOM_ZLEC", "NR_POZ", "ETAP", "WAR_OD", "WAR_DO", "NR_PORZ", "ZN_WAR", "INDEKS", "SZER", "WYS", "POW", "GRUB", "GRUB_SUR", "WAGA", "NK_OBR", "KOLEJN_OBR", "NK_INST", "TYP_INST", "JEDN", "NR_INST_POW", "KOLEJNOSC_Z_GRUPY", "GR_AKT", "IDENT_BUD", "IL_OBR", "WSP_C_M", "WSP_HAR", "WSP_HO", "WSP_12ZAKR", "ZNAK_DOD", "WSP_DOD", "WSP_CENY", "KRYT_WYM_DOD", "KRYT_GRUB_PAK", "KRYT_WAGA_PAK", "KRYT_WAGA_1MB", "KRYT_WAGA_ELEM", "KRYT_WYM_MIN", "KRYT_WYM_MAX", "KRYT_ATRYB", "KRYT_ATRYB_WYL", "KRYT_DOW", "KRYT_OBR_JEDNOCZ", "KRYT_SUMA", "KRYT_KTORE", "KRYT_WYK", "OBSL_TECH", "INST_STD", "INST_WYBR", "INST_JAKA", "WSP_PRZEL", "WSP_ALT", "WSP0", "CZAS0_MIN", "CZAS_PRZEZBR_MIN", "CZAS_PRZEZBR", "CZAS_JEDN_OBR", "KTORY_WPIS_OBR", "WPIS1_OBR", "KTORY_WPIS_INST", "KTORY_WPIS_INST_WYBR", "WPIS1_INST", "LISTA_OBR_JEDNOCZ") AS 
  SELECT V.zrodlo,V.nr_kom_zlec,V.nr_poz,V.etap,V.war_od,V.war_do,V.nr_porz,V.zn_war,V.indeks,V.szer,V.wys,V.pow,V.grub,V.grub_sur,V.waga,V.nk_obr,V.kolejn_obr,
       V.nk_inst, V.ty_inst typ_inst, V.jedn, V.nr_inst_pow, V.kolejnosc_z_grupy, V.gr_akt, V.ident_bud, V.il_obr, V.wsp_c_m, V.wsp_har, V.wsp_HO, V.wsp_12zakr, V.znak_dod, V.wsp_dod, V.wsp_ceny,
       V.kryt_wym_dod,V.kryt_grub_pak,V.kryt_waga_pak,V.kryt_waga_1mb,V.kryt_waga_elem,V.kryt_wym_min,V.kryt_wym_max,V.kryt_atryb,V.kryt_atryb_wyl,V.kryt_oper,
       nvl2(V.lista_obr_jednocz,max(greatest(V.kryt_obr_jednocz,V.kryt_wym_dod,V.kryt_oper)) over (partition by V.nr_kom_zlec, V.nr_poz, V.etap, V.war_od, V.nk_inst),0) kryt_obr_jednocz,
       (nvl2(V.lista_obr_jednocz,max(greatest(V.kryt_obr_jednocz,V.kryt_wym_dod,V.kryt_oper)) over (partition by V.nr_kom_zlec, V.nr_poz, V.etap, V.war_od, V.nk_inst),0)--kryt_obr_jednocz
       +kryt_grub_pak+kryt_waga_pak+kryt_waga_1mb+kryt_waga_elem+kryt_wym_min+kryt_wym_max+kryt_wym_dod+kryt_atryb_wyl+0+kryt_oper)*decode(gr_akt,2,-1,1) kryt_suma,
        kryt_grub_pak*0.1+kryt_waga_pak*0.01+kryt_waga_1mb*0.001+kryt_waga_elem*0.0001+kryt_wym_min*0.00001+kryt_wym_max*0.000001+kryt_wym_dod*0.000001*0.1+kryt_atryb_wyl*0.000001*0.01+0+kryt_oper*0.000001*0.0001+V.kryt_obr_jednocz*0.000001*0.00001 kryt_ktore,
       case when (max(kryt_grub_pak+kryt_waga_pak+kryt_waga_1mb+kryt_waga_elem+kryt_wym_min+kryt_wym_max+kryt_wym_dod+kryt_atryb_wyl+0+kryt_oper+V.kryt_obr_jednocz) over (partition by V.nr_kom_zlec, V.nr_poz, V.nr_porz))>0
            then case when (min(kryt_grub_pak+kryt_waga_pak+kryt_waga_1mb+kryt_waga_elem+kryt_wym_min+kryt_wym_max+kryt_wym_dod+kryt_atryb_wyl+0+kryt_oper+V.kryt_obr_jednocz) over (partition by V.nr_kom_zlec, V.nr_poz, V.nr_porz))>0
                      then 0
                      when max(decode(nk_inst,inst_wybr,kryt_grub_pak+kryt_waga_pak+kryt_waga_1mb+kryt_waga_elem+kryt_wym_min+kryt_wym_max+kryt_wym_dod+kryt_atryb_wyl+0+kryt_oper+V.kryt_obr_jednocz,null)) over (partition by V.nr_kom_zlec, V.nr_poz, V.nr_porz)>0
                      then 1
                      else 2 end
            else 3 end kryt_wyk,
       V.obsl_tech, V.inst_std, V.inst_wybr, V.wsp_jaki inst_jaka,
       --nvl(WSP_WG_TYPU_INST(V.ty_inst, V.wsp_12zakr, V.wsp_c_m, V.wsp_har, V.wsp_HO, V.wsp_dod, V.znak_dod, V.wsp_ceny),1) wsp_przel, 
       nvl(WSP_WG_TYPU_INST2(V.ty_inst, V.jedn, V.wsp_12zakr, V.wsp_c_m, V.wsp_har, V.wsp_HO, V.wsp_dod, V.znak_dod, V.czas_jedn_obr, V.wsp_ceny),1) wsp_przel,
       V.wsp_alt, V.wsp0, V.wsp0 czas0_min, TIME_TO_MINUTES(V.czas_przezbr) czas_przezbr_min,
       V.czas_przezbr, V.czas_jedn_obr,
       V.ktory_wpis_obr, decode(V.ktory_wpis_obr,1,1,0) wpis1_obr,
       V.ktory_wpis_inst,
       decode(V.inst_wybr,V.nk_inst,
               dense_rank() over (partition by V.zrodlo, V.nr_kom_zlec, V.nr_poz, V.etap, V.war_od, V.inst_wybr order by V.nr_porz),
               0) ktory_wpis_inst_wybr,
        decode(V.ktory_wpis_inst,1,1,0) wpis1_inst,
       V.lista_obr_jednocz
FROM (
SELECT S.zrodlo, S.nr_komp_zr nr_kom_zlec, S.nr_kol nr_poz, S.etap, S.war_od, S.war_do, S.nr_porz, S.zn_war, S.indeks, S.szer, S.wys, S.pow, S.grub, S.grub_sur, S.waga_jedn*S.pow waga,
       S.nk_obr, S.zn_plan kolejn_obr, S.nk_inst, I.ty_inst, I.jedn, I.nr_inst_pow, 
       S.kolejnosc_z_grupy, S.gr_akt, S.ident_bud, S.inst_std, 
       wsp_jaki, wsp_alt, wsp0, inst_wybr,
       --W.jaki wsp_jaki, W.wsp_alt, nvl(W0.wsp_alt,0) wsp0,
       --case when W.jaki=3 then W.nr_komp_inst else (select nvl(max(W.nr_komp_inst),0) from wsp_alter W where W.nr_kom_zlec=S.nr_komp_zr and W.nr_poz=S.nr_kol and W.nr_porz_obr=S.nr_porz and W.jaki=3) end inst_wybr,
       /*decode(S.zn_war,'Obr',S.il_obr,S.pow)*/S.il_obr il_obr, nvl(wsp_c_m,1) wsp_c_m, nvl(wsp_har,1) wsp_har,
       nvl(decode(trim(I.ty_inst),'HAR',WSP_HO(S.zrodlo,S.nr_komp_zr,S.nr_kol,S.etap,S.war_od),0),0) wsp_HO,
       nvl(wsp_12zakr(S.nk_inst,S.pow,S.ident_bud),1) wsp_12zakr,
       nvl(nvl(D1.znak,nvl(D2.znak,nvl(D3.znak,D0.znak))),'*') znak_dod,
       nvl(nvl(D1.wsp_przel,nvl(D2.wsp_przel,nvl(D3.wsp_przel,D0.wsp_przel))),1) wsp_dod,
       nvl(nvl(D1.czas_jedn_obr,nvl(D2.czas_jedn_obr,nvl(D3.czas_jedn_obr,D0.czas_jedn_obr))),1) czas_jedn_obr,
       nvl(nvl(D1.czas_przezbr,nvl(D2.czas_przezbr,nvl(D3.czas_przezbr,D0.czas_przezbr))),1) czas_przezbr,
       S.ktory_wpis_obr, --S.ktory_wpis_inst, 
       dense_rank() over (partition by S.zrodlo, S.nr_komp_zr, S.nr_kol, S.etap, S.war_od, S.nk_inst order by S.zn_plan, S.nr_porz) ktory_wpis_inst,
       --S.ktory_wpis_inst_std,
       nvl(wsp_cen,0) wsp_ceny,
       case when nvl(D1.szer_max,nvl(D2.szer_max,nvl(D3.szer_max,nvl(D0.szer_max,0))))>0 
             and least(S.szer,S.wys)>nvl(D1.szer_max,nvl(D2.szer_max,nvl(D3.szer_max,nvl(D0.szer_max,9999)))) then 1 else 0 end + 
       case when nvl(D1.wys_max,nvl(D2.wys_max,nvl(D3.wys_max,nvl(D0.wys_max,0))))>0
             and greatest(S.szer,S.wys)>nvl(D1.wys_max,nvl(D2.wys_max,nvl(D3.wys_max,nvl(D0.wys_max,9999)))) then 1 else 0 end kryt_wym_dod,
       case when I.max_grub_pak=0 or I.max_grub_pak>=S.grub then 0 else 1 end kryt_grub_pak,
       case when I.max_waga_pak=0 or I.max_waga_pak>=S.waga_jedn*S.pow then 0 else 1 end kryt_waga_pak,
       case when I.max_waga_1mb=0 or I.max_waga_1mb>=least(S.szer,S.wys)*0.001*least(1,greatest(S.szer,S.wys)*0.001)*S.waga_jedn then 0 else 1 end kryt_waga_1mb,
       --od 14.01.2021 sprawdzana pow. max zamiast waga 1 formatki
       case when I.max_waga_el=0 or I.max_waga_el>=S.pow then 0 else 1 end kryt_waga_elem,
       --case when I.max_waga_el=0 or I.max_waga_el>=S.waga_elem then 0 else 1 end kryt_waga_elem,
       case when I.szer_min+I.wys_min>0 and (S.bok_min<I.szer_min or S.bok_max<I.wys_min) then  1 else 0 end kryt_wym_min,
       case when I.szer_max+I.wys_max>0 and (S.bok_min>I.szer_max or S.bok_max>I.wys_max) then  1 else 0 end kryt_wym_max,
       decode(to_number(nvl(replace(I.ind_bud,' ','0'),'0')),0,2, atryb_match(I.ind_bud,S.ident_bud)) kryt_atryb,
       decode(to_number(nvl(replace(I.ident_bud_wyl,' ','0'),'0')),0,0, atryb_match(I.ident_bud_wyl,S.ident_bud)) kryt_atryb_wyl, 
       decode(instr(lista_obr_jednocz,'I'||S.nk_inst||';'),0,1,0) kryt_obr_jednocz, lista_obr_jednocz,
       0 kryt_oper,--nvl(decode(T.obsl,0,1,0),0) kryt_oper,
       -1 obsl_tech--nvl(decode(TKP.obsl,0,8,TKP.obsl),0) obsl_tech
FROM
(SELECT S.zrodlo, S.nr_komp_zr, S.nr_kol, S.id_rek, S.etap, S.war_od, S.war_do, S.nr_porz, S.zn_war, S.zn_plan, S.szer, S.wys, S.szer*S.wys*0.000001 pow,
        S.indeks, S0.nr_porz nr_porz_war, S0.ident_bud, S.il_obr, S.inst_std,
        least(S.szer,S.wys) bok_min, greatest(S.szer,S.wys) bok_max,
        nvl(K.grubosc,Str.gr_pak) grub, nvl2(trim(I.rodz_sur),DANE_STR_WG_KODU(S.indeks,'GRUB_SUR',I.rodz_sur),null) grub_sur,
        K.wsp_c_m, K.wsp_har,
        nvl(K.waga,Str.waga) waga_jedn, nvl(K.waga*S.szer*S.wys*0.000001,0) waga_elem, Str.wsp_cen,
        decode(S.zn_war,'Obr',S.nr_kat,0) nr_czynn, S.nk_obr,
        dense_rank() over (partition by S.zrodlo, S.nr_komp_zr, S.nr_kol, S.etap, S.war_od, S.nk_obr order by S.nr_porz) ktory_wpis_obr,
        dense_rank() over (partition by S.zrodlo, S.nr_komp_zr, S.nr_kol, S.etap, S.war_od, G.nr_komp_inst order by S.zn_plan, S.nr_porz) ktory_wpis_inst,
        dense_rank() over (partition by S.zrodlo, S.nr_komp_zr, S.nr_kol, S.etap, S.war_od, S.inst_std order by S.zn_plan, S.nr_porz) ktory_wpis_inst_std,
        nvl(G.nr_komp_inst,S.inst_std) nk_inst,
        nvl(G.kolejnosc,0) kolejnosc_z_grupy, nvl(G.akt,0) gr_akt,
        W.jaki wsp_jaki, W.wsp_alt, nvl(W0.wsp_alt,0) wsp0,
        case when W.jaki=3 then W.nr_komp_inst else (select nvl(max(W.nr_komp_inst),0) from wsp_alter W where W.nr_kom_zlec=S.nr_komp_zr and W.nr_poz=S.nr_kol and W.nr_porz_obr=S.nr_porz and W.jaki=3) end inst_wybr,
        (select listagg('O'||SJ.nk_obr||';N'||SJ.nr_porz||';I'||VJ.nr_komp_inst||';','|') within group (order by SJ.nk_obr)
         from spiss SJ, v_obr_jednocz VJ
         where SJ.zrodlo=S.zrodlo and SJ.nr_komp_zr=S.nr_komp_zr and SJ.nr_kol=S.nr_kol and SJ.etap=S.etap and SJ.war_od=S.war_od
           and (SJ.nk_obr=VJ.nr_obr_jednocz and SJ.nk_obr<>S.nk_obr and VJ.nr_komp_obr=S.nk_obr or
                S.nk_obr=VJ.nr_obr_jednocz and SJ.nk_obr<>S.nk_obr and VJ.nr_komp_obr=SJ.nk_obr)
           and SJ.zn_plan>0 --and VJ.nr_komp_inst=G.nr_komp_inst
           ) lista_obr_jednocz
 FROM spiss S
 --link do rekordu warstwy
 LEFT JOIN spiss S0 ON S0.zrodlo=S.zrodlo and S0.nr_komp_zr=S.nr_komp_zr and S0.nr_kol=S.nr_kol and S0.etap=S.etap and S0.czy_war=1 and S.war_od between S0.war_od and S0.war_do and S0.strona=0
 --linki do pobrania wagi
 LEFT JOIN katalog K on K.typ_kat=S.indeks
 LEFT JOIN struktury Str on Str.kod_str=S.indeks
 --link do pobrania instalacji dla obróbek
 LEFT JOIN gr_inst_dla_obr G ON S.nk_obr=G.nr_komp_obr
 --link do spr. kryteriów z parametrów instalacji
 LEFT JOIN parinst I ON I.nr_komp_inst=nvl(G.nr_komp_inst,S.inst_std)
 --link do sprawdzenia wyliczonych wspolczynnikow
 LEFT JOIN wsp_alter W ON W.nr_kom_zlec=S.nr_komp_zr and W.nr_poz=S.nr_kol and W.nr_porz_obr=S.nr_porz and W.nr_komp_inst=nvl(G.nr_komp_inst,S.inst_std) and W.nr_zestawu=0
 --link do sprawdzenia wsp. warstwy (czas obr)
 LEFT JOIN wsp_alter W0 ON W0.nr_kom_zlec=S0.nr_komp_zr and W0.nr_poz=S0.nr_kol and W0.nr_porz_obr=S0.nr_porz and W0.nr_komp_inst=G.nr_komp_inst and W0.nr_zestawu=0
  --link do pobrania wspolczynnika ceny (dla GP)
  --LEFT JOIN struktury Str ON Str.kod_str=S.indeks and S.etap>=3
 --wybierane s¹ wszystkie skladniki, które maj¹ byæ planowane
 WHERE S.zrodlo in ('T','Z') and S.nk_obr>0 and S.zn_plan>0
 --zamiast poni¿szych zerowanie ZN_PLAN w proc. SPISS_MAT
   --AND NOT (S.etap=1 and S.rodz_sur='POL' and S.zn_war='Obr' and S.nr_porz>100) --obrobki ze SPISD nie planowane na pólprodukcie tylko w zlec wew.
   --AND NOT (S.nk_obr=1 and substr(S0.ident_bud,19,1)='1')  --usuniêcie ZAT w EFF, bo w strukturach SZKLO\Z\H; podobny warunek w GEN_LWYC
) S
--linki do wsp. dodatk. (4x, bo mo¿enie byæ rekordów odpowaidaj¹cych nr obróbki i/lub typowi katal.)
LEFT JOIN pinst_dodn D1 ON D1.nr_komp_inst=S.nk_inst and D1.typ_kat=S.indeks and D1.nr_komp_obr=S.nk_obr --and S.grub between D1.grub_od and D1.grub_do
LEFT JOIN pinst_dodn D2 ON D2.nr_komp_inst=S.nk_inst and D2.typ_kat=S.indeks and D2.nr_komp_obr=0 --and S.grub between D2.grub_od and D2.grub_do
LEFT JOIN pinst_dodn D3 ON D3.nr_komp_inst=S.nk_inst and trim(D3.typ_kat) is null and D3.nr_komp_obr=S.nk_obr and nvl(S.grub_sur,S.grub) between D3.grub_od and D3.grub_do
LEFT JOIN pinst_dodn D0 ON D0.nr_komp_inst=S.nk_inst and trim(D0.typ_kat) is null and D0.nr_komp_obr=0 and nvl(S.grub_sur,S.grub) between D0.grub_od and D0.grub_do
--link do spr. kryteriów z parametrów instalacji
LEFT JOIN parinst I ON I.nr_komp_inst=S.nk_inst
--link do pobranie ostrzezenia operatora
--LEFT JOIN tech_kontr_poz T ON T.nr_komp_zap=0 and T.nr_komp_zlec=S.nr_komp_zr and T.id_rek=S.id_rek and T.nr_kolejny=S.nr_porz
--link do pobrania decyzji dla kontroli poprawnoœci techn/      
--LEFT JOIN (select nr_komp_zlec, max(nr_komp_zap) nr_komp_zap_ost from tech_kontr group by nr_komp_zlec) TK ON TK.nr_komp_zlec=S.nr_komp_zr
--LEFT JOIN tech_kontr_poz TKP ON TKP.nr_komp_zap=TK.nr_komp_zap_ost AND TKP.nr_komp_zlec=S.nr_komp_zr AND TKP.id_rek=S.id_rek AND TKP.nr_kolejny=S.nr_porz AND TKP.nr_komp_instal=S.nk_inst
) V;
