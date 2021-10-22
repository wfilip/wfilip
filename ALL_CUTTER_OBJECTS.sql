--------------------------------------------------------
--  File created - poniedzia³ek-paŸdziernika-23-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View ECUTTER_DEALERS
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "ECUTTER_DEALERS" ("LOGIN", "HASLO", "NKOMP_KLIENT", "NAZ_KON", "MAIL", "ECU3") AS SELECT DISTINCT operatorzy.id AS LOGIN,
    oper_srob.napis             AS HASLO,
    operatorzy.nr_oper          AS NKOMP_KLIENT,
    operatorzy.im_nazw          AS NAZ_KON,
    operatorzy.mail,
    oper_kl.wsk+oper_kl.wskg ecu3
  FROM operatorzy
  LEFT JOIN oper_srob ON oper_srob.nk_oper=operatorzy.nr_oper
  LEFT JOIN oper_kl ON oper_kl.nr_oper=operatorzy.nr_oper AND oper_kl.numer_klucza=290
  WHERE (SELECT oper_kl.wsk
    FROM oper_kl
    WHERE oper_kl.numer_klucza=242
    AND oper_kl.nr_oper       =operatorzy.nr_oper)=1
  OR (SELECT oper_kl.wskg
    FROM oper_kl
    WHERE oper_kl.numer_klucza=242
    AND oper_kl.nr_oper       =operatorzy.nr_oper)=1
;
--------------------------------------------------------
--  DDL for View ECUTTER_DEALERS_USERS
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "ECUTTER_DEALERS_USERS" ("LOGIN", "NKOMP_KLIENT") AS SELECT DISTINCT operatorzy.id AS LOGIN,
    ktrkredyt.numer_komputerowy AS NKOMP_KLIENT
  FROM operatorzy,
    ktrkredyt
  WHERE OPERATORZY.NR_OPER=KTRKREDYT.OBSL_NR
  OR OPERATORZY.NR_OPER   =KTRKREDYT.NADZ_NR
  OR operatorzy.nr_oper  IN
    (SELECT nr_oper
    FROM oper_kl
    WHERE oper_kl.numer_klucza=290
    AND (wsk                  =1
    or WSKG                   =1)
    )
;
--------------------------------------------------------
--  DDL for View GRUP_PLAN
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "GRUP_PLAN" ("INSTAL", "DZIEN", "ZMIANA", "GRUPA", "NR_OBR", "DODATEK", "ILOSC", "WIELKOSC") AS select distinct wykzal.nr_komp_instal as instal,
wykzal.d_plan as dzien, wykzal.zm_plan as zmiana, wykzal.nr_komp_gr as grupa, wykzal.nr_komp_obr as nr_obr,
wykzal.kod_dod as dodatek, sum(wykzal.il_plan) as ilosc ,sum(wykzal.il_zlec_plan*wykzal.wsp_przel) as wielkosc
from wykzal where wykzal.flag=1
group by wykzal.nr_komp_instal,wykzal.d_plan, wykzal.zm_plan, wykzal.nr_komp_gr, wykzal.nr_komp_obr, wykzal.kod_dod
;
--------------------------------------------------------
--  DDL for View INFOFAKT
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "INFOFAKT" ("NR_KOMP", "PREFIX", "NR_DOKS", "SUFIX", "TYP_DOKS", "MIEJSCOWOSC", "DATA_WYST", "DATA_SPRZED", "NR_O", "NAZ_O", "SKROT_O", "PANSTWO_O", "KOD_POCZ_O", "MIASTO_O", "ADRES_O", "NIP_O", "NR_P", "NAZ_P", "SKROT_P", "PANSTWO_P", "KOD_POCZ_P", "MIASTO_P", "ADRES_P", "NIP_P", "GOT_KRED", "WAR_PLAT", "KREDYT_DNI", "WALUTA", "WARTOSC_NETTO", "WARTOSC_BRUTTO", "WARTOSC_VAT", "WYSTAWIL", "ODEBRAL", "POW", "SZT") AS select distinct
faknagl.NR_KOMP,
faknagl.PREFIX,faknagl.NR_DOKS,faknagl.SUFIX,faknagl.typ_doks,
faknagl.MIEJSCOWOSC,faknagl.DATA_WYST,faknagl.DATA_SPRZED,
faknagl.nr_odb as NR_O,faknagl.naz_odb as NAZ_O,faknagl.skrot_odb as SKROT_O,faknagl.PANSTWO_O,faknagl.KOD_POCZ_O,faknagl.MIASTO_O,faknagl.ADRES_O,faknagl.NIP_O,
faknagl.nr_plat as NR_P,faknagl.naz_plat as NAZ_P,faknagl.skrot_plat as SKROT_P,faknagl.panstwo_plat as PANSTWO_P,
faknagl.kod_pocz_plat as KOD_POCZ_P,faknagl.miasto_plat as MIASTO_P,faknagl.adres_plat as ADRES_P,NIP_P,
faknagl.GOT_KRED,faknagl.war_plat,faknagl.KREDYT_DNI,
faknagl.WALUTA,faknagl.netto_wal as WARTOSC_NETTO,faknagl.brutto_wal as WARTOSC_BRUTTO,faknagl.vat_wal as WARTOSC_VAT,
faknagl.im_naz_wyd as WYSTAWIL,faknagl.ODEBRAL,
sum(fakpoz.ilosc) as POW, sum(fakpoz.il_szt) as SZT
from FAKNAGL,fakpoz where
faknagl.nr_komp=fakpoz.nr_komp_doks and
faknagl.typ_doks not in ('FW')
group by
faknagl.NR_KOMP,
faknagl.PREFIX,faknagl.NR_DOKS,faknagl.SUFIX,faknagl.typ_doks,
faknagl.MIEJSCOWOSC,faknagl.DATA_WYST,faknagl.DATA_SPRZED,
faknagl.nr_odb,faknagl.naz_odb,faknagl.skrot_odb,faknagl.PANSTWO_O,faknagl.KOD_POCZ_O,faknagl.MIASTO_O,faknagl.ADRES_O,faknagl.NIP_O,
faknagl.nr_plat,faknagl.naz_plat,faknagl.skrot_plat,faknagl.panstwo_plat,faknagl.kod_pocz_plat,faknagl.miasto_plat,faknagl.adres_plat,faknagl.NIP_P,
faknagl.GOT_KRED,faknagl.war_plat,faknagl.KREDYT_DNI,
faknagl.WALUTA,faknagl.netto_wal,faknagl.brutto_wal,faknagl.vat_wal,
faknagl.im_naz_wyd,faknagl.ODEBRAL
;
--------------------------------------------------------
--  DDL for View INFOFAKTPODSUM
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "INFOFAKTPODSUM" ("ID_FAKT", "ID_PODS", "PEL_NAZ", "ILOSC_SZT", "ILOSC_JP", "CENA_NETTO", "WART_NETTO", "ST_VAT", "WART_VAT") AS select distinct
ID_FAKT,ID_PODS,PEL_NAZ,ILOSC_SZT,ILOSC_JP,CENA_NETTO,
WART_NETTO,ST_VAT,WART_VAT
from fakpodsum
;
--------------------------------------------------------
--  DDL for View INFOFAKTPOZ
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "INFOFAKTPOZ" ("NR_KOMP", "NR_POZ", "INDEKS", "PREFIX", "NAZ_TOW", "PKWIU", "ILOSC", "CENA_NETTO", "JEDN", "CENA_NETTO_SZT", "RODZAJ_CENY", "WART_NETTO", "VAT", "WART_VAT", "WART_BRUTTO", "SZT", "CZY_DOD", "LP_DOD", "SZER", "WYS", "NR_KOMP_ZLEC") AS select distinct
fakpoz.nr_komp_doks as NR_KOMP, fakpoz.NR_POZ,
fakpoz.INDEKS,fakpoz.prefix_nazwy_towaru as PREFIX,fakpoz.NAZ_TOW,
fakpoz.PKWIU,fakpoz.ILOSC,
fakpoz.CENA_NETTO,JEDN,CENA_NETTO_SZT,RODZAJ_CENY,fakpoz.NETTO_WAL as WART_NETTO,
fakpoz.naz_vat as VAT,fakpoz.vat_wal as WART_VAT,fakpoz.brutto_wal as WART_BRUTTO,
fakpoz.il_szt as SZT,fakpoz.czy_dod,fakpoz.lp_dod,
infopoz.szer,infopoz.wys,infopoz.nr_kom_zlec
from fakpoz left join infopoz
on
(infopoz.nr_kom_zlec=fakpoz.id_zlec) and
(infopoz.nr_poz=fakpoz.id_zlec_poz)
;
--------------------------------------------------------
--  DDL for View INFOHISTORIA
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "INFOHISTORIA" ("NK_KONTR", "NR_STOJ", "ST_STATUS", "TYP_STOJ", "NK_ZAP", "NK_SPED", "DATA_SPED", "ODD_WYJ", "DATA_WYJ", "ODD_PRZYJ", "DATA_PRZYJ", "NK_RAP", "ILOSAC_DNI", "STATUS", "ZNACZNIK", "FL_AKT", "DATA_NOTY", "Nr_NOTY", "ODD_NOTY") AS SELECT DISTINCT sk.nk_kontr,
    st.nr_stoj,
    ST.status AS st_status,
    st.typ_stoj,
    sk.nk_zap,
    sk.nk_sped,
    sk.data_sped,
    sk.odd_wyj,
    sk.data_wyj,
    sk.odd_przyj,
    sk.data_przyj,
    sk.nk_rap,
    sk.ilosc_dni,
    sk.status,
    sk.znacznik,
    sk.fl_akt,
    sk.data_noty,
    sk.nr_noty,
    sk.odd_noty
  FROM st_kontr_stoj sk
  left join STOJSPED ST
  on ST.NR_KOMP_STOJ=SK.NK_STOJ
where st.nr_oddz=1
;
--------------------------------------------------------
--  DDL for View INFOKLIENT
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "INFOKLIENT" ("NR_KON", "NAZ_KON", "SKROT_K", "KOD_POCZ", "MIASTO", "ADRES", "PANSTWO", "POWIAT", "WOJEW", "TEL", "FAX", "MAIL", "REGON", "NIP", "LIMIT_K", "IL_D_KRED", "NAZ_BANKU", "NR_RACH", "STATUS", "DLUG_C", "DLUG_P", "DLUG_Z", "ZAL", "DLUG1", "DLUG2", "DLUG3", "DLUG4", "ILE_STOJ", "ILE_STOJ_WDRODZE") AS select distinct
klient.nr_kon,klient.naz_kon,klient.skrot_k,klient.kod_pocz,
klient.miasto,klient.adres,klient.panstwo,klient.powiat,
klient.wojew,klient.tel,klient.fax,klient.mail,klient.regon,
klient.nip,klient.limit_k,klient.il_d_kred,banki.naz_banku,nr_rach,
klient.status,
ktrkredyt.dlug_c as DLUG_C,ktrkredyt.dlug_przet as DLUG_P,
ktrkredyt.wzlec_cetral as DLUG_Z,ktrkredyt.zal,
ktrkredyt.kwota_30 as DLUG1,
ktrkredyt.kwota_31_60 as DLUG2,
ktrkredyt.kwota_61_90 as DLUG3,
ktrkredyt.kwota_91 as DLUG4,
sk.ile_stoj,
sk.ile_stoj_wdrodze
from klient 
left join banki on banki.nr_banku=klient.nr_banku
left join ktrkredyt on ktrkredyt.numer_komputerowy=klient.nr_kon
left join 
( select 
    nk_kontr,
    sum(decode(status,0,1,0)) ile_stoj,
    sum(decode(status,2,1,0)) ile_stoj_wdrodze
  from st_kontr_stoj 
  group by nk_kontr
  ) sk on sk.nk_kontr=klient.nr_kon
;
--------------------------------------------------------
--  DDL for View INFOKLIENT2
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "INFOKLIENT2" ("NR_KON", "NAZ_KON", "SKROT_K", "KOD_POCZ", "MIASTO", "ADRES", "PANSTWO", "POWIAT", "WOJEW", "TEL", "FAX", "MAIL", "REGON", "NIP", "LIMIT_K", "IL_D_KRED", "NAZ_BANKU", "NR_RACH", "STATUS", "DLUG_C", "DLUG_P", "DLUG_Z", "ZAL", "DLUG1", "DLUG2", "DLUG3", "DLUG4") AS select distinct
klient.nr_kon,klient.naz_kon,klient.skrot_k,klient.kod_pocz,
klient.miasto,klient.adres,klient.panstwo,klient.powiat,
klient.wojew,klient.tel,klient.fax,klient.mail,klient.regon,
klient.nip,klient.limit_k,klient.il_d_kred,banki.naz_banku,nr_rach,
klient.status,
ktrkredyt.dlug_c as DLUG_C,ktrkredyt.dlug_przet as DLUG_P,
ktrkredyt.wzlec_cetral as DLUG_Z,ktrkredyt.zal,
ktrkredyt.kwota_30 as DLUG1,
ktrkredyt.kwota_31_60 as DLUG2,
ktrkredyt.kwota_61_90 as DLUG3,
ktrkredyt.kwota_91 as DLUG4
from klient 
left join banki on banki.nr_banku=klient.nr_banku
left join ktrkredyt on ktrkredyt.numer_komputerowy=klient.nr_kon
;
--------------------------------------------------------
--  DDL for View INFOPOZ
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "INFOPOZ" ("NR_KOM_ZLEC", "NR_POZ", "ILOSC", "SZER", "WYS", "KOD_STR", "OPIS_KLI", "WSP_K", "CENA", "RODZ_CEN", "NR_KSZT", "H", "H1", "H2", "L1", "L2", "R", "R1", "R2", "R3", "T1", "T2", "T3", "T4", "POW", "IL_NA_WZ", "IL_NA_PW") AS select distinct
spisz.NR_KOM_ZLEC,spisz.NR_POZ,spisz.ILOSC,spisz.SZER,spisz.WYS,spisz.KOD_STR,
spisz.OPIS_KLI,spisz.WSP_K,spisz.CENA,spisz.RODZ_CEN,
spisz.NR_KSZT,
spisz.H,spisz.H1,spisz.H2,spisz.W1_L1 AS L1,spisz.W2_L2 AS L2,
spisz.R,spisz.R1,spisz.R2,spisz.R3,
spisz.T1_B1 AS T1,spisz.T2_B2 AS T2,spisz.T3_B3 AS T3,spisz.T4,
spisz.POW,spisz.IL_NA_WZ,spisz.IL_NA_PW
FROM SPISZ
;
--------------------------------------------------------
--  DDL for View INFOSPECSTOJ
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "INFOSPECSTOJ" ("NR_ZLEC", "NR_POZ", "NR_SPED", "NR_STOJ", "NR_KON", "MIN", "MAX") AS select distinct spise.nr_zlec,spise.nr_poz,spise.nr_sped,
stojsped.nr_stoj,zamow.nr_kon,
min(spise.poz_st_sped) min,max(spise.poz_st_sped) max from spise
left join stojsped on stojsped.nr_komp_stoj=spise.nr_stoj_sped
left join spisz on spisz.nr_kom_zlec=spise.nr_komp_zlec and spisz.nr_poz=spise.nr_poz
left join zamow on zamow.nr_kom_zlec=spise.nr_komp_zlec
group by (spise.nr_zlec,spise.nr_poz,spise.nr_sped,
zamow.nr_kon,stojsped.nr_stoj)
;
--------------------------------------------------------
--  DDL for View INFOSPED
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "INFOSPED" ("NR_SPED", "DATA_SPED", "NR_REJ", "NAZWA_TRASY", "IL_SZYB", "POW", "IL_STOJ") AS select nr_sped,DATA_SPED,NR_REJ,
 trasy.NAZ_TRASY,
 spedc.IL_SZYB,spedc.POW,spedc.IL_STOJ
from spedc
left join trasy on trasy.nr_trasy=spedc.nr_trasy
;
--------------------------------------------------------
--  DDL for View INFOSPEDZLEC
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "INFOSPEDZLEC" ("NR_SPED", "NR_KOMP_ZLEC", "NR_KON") AS select kom_zle.nr_sped,kom_zle.nr_komp_zlec,zamow.nr_kon
from kom_zle
join zamow on zamow.nr_kom_zlec=kom_zle.nr_komp_zlec

;
--------------------------------------------------------
--  DDL for View INFOTRASY
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "INFOTRASY" ("NR_SPED", "NAZ_TRASY") AS select distinct spedc.nr_sped,trasy.naz_trasy
    from spedc
left join trasy on trasy.nr_trasy=spedc.nr_trasy
;
--------------------------------------------------------
--  DDL for View INFOZLEC
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "INFOZLEC" ("NR_KOM_ZLEC", "NR_KON", "DATA_ZL", "NR_ZLEC", "NR_ZLEC_KLIENTA", "D_WYS", "D_PL_SPED", "D_SPED_KL", "NR_ZLEC_WEWN", "NR_KON_D", "IL_POZ", "IL_SZT", "IL_PW", "IL_WZ", "IL_FAK", "IL_N_WYS", "STATUS", "FORMA_WPROW", "WYROZNIK", "NR_ADR_DOST") AS select distinct (zamow.nr_kom_zlec), zamow.nr_kon,
    zamow.data_zl,
zamow.nr_zlec, zamow.nr_zlec_kli, zamow.d_wys, zamow.d_pl_sped,
zamow.d_sped_kl, zamow.nr_zlec_wewn,
dostawy.nr_kon as nr_kon_d,
count(spisz.nr_poz) as il_poz, sum(spisz.ilosc) as il_szt,
sum(spisz.il_na_PW) as il_pw, sum(spisz.il_na_wz) as il_wz,
sum(spisz.il_fak) as il_fak, sum(spisz.il_do_wys) as il_n_wys,
zamow.status,zamow.forma_wprow,zamow.wyroznik,
zamow.nr_adr_dost
from zamow,spisz,dostawy
where
zamow.nr_kom_zlec=spisz.nr_kom_zlec and
zamow.nr_adr_dost=dostawy.nr_dost and
zamow.wyroznik in ('Z','R')
 group by zamow.nr_kom_zlec,zamow.nr_kon,zamow.data_zl,zamow.nr_zlec,
 zamow.nr_zlec_kli, zamow.d_wys, zamow.d_pl_sped,zamow.d_sped_kl,
 zamow.nr_zlec_wewn,dostawy.nr_kon,zamow.status,zamow.forma_wprow,zamow.wyroznik,
 zamow.nr_adr_dost
;
--------------------------------------------------------
--  DDL for View KONTR_PLAN
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "KONTR_PLAN" ("INSTAL", "DZIEN", "ZMIANA", "GRUPA", "ILOSC", "WIELKOSC") AS select distinct harmon.nr_komp_inst as instal, 
harmon.dzien as dzien,
harmon.zmiana as zmiana, klient.status_plan as grupa,
sum(harmon.ilosc) as ilosc ,sum(harmon.wielkosc) as wielkosc  
from harmon, klient where harmon.typ_harm='P' 
and  klient.nr_kon=(select klient.nr_kon from klient 
where klient.nr_kon=(select zamow.nr_kon from zamow where 
zamow.nr_kom_zlec=harmon.nr_komp_zlec))
group by harmon.nr_komp_inst, harmon.dzien , harmon.zmiana, klient.status_plan
;
--------------------------------------------------------
--  DDL for View KONTR_ZAMOW
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "KONTR_ZAMOW" ("NR_KOM_ZLEC", "NR_ZLEC", "NR_ZLEC_KLI", "NR_KON", "NR_ZLEC_WEWN", "WYROZNIK", "TYP_ZLEC", "FLAG_R", "DATA_ZL", "D_POCZ_PROD", "D_ZAK_PROD", "D_PLAN", "D_WYS", "D_PL_SPED", "FORMA_WPROW", "DO_PRODUKCJI", "STATUS", "NR_ADR_DOST", "NR_KONTRAKTU", "IL_POZ", "ILE_SZYB", "ILE_M2", "WALUTA", "NR_KOMP_ROKP", "SKROT_K", "NR_LISTY") AS SELECT Z.NR_KOM_ZLEC,
Z.NR_ZLEC,
trim(Z.NR_ZLEC_KLI),
Z.NR_KON,
Z.NR_ZLEC_WEWN,
Z.WYROZNIK,
Z.TYP_ZLEC,
Z.FLAG_R,
Z.DATA_ZL,
Z.D_POCZ_PROD,
Z.D_ZAK_PROD,
Z.D_PLAN,
Z.D_WYS,
Z.D_PL_SPED,
Z.FORMA_WPROW,
Z.DO_PRODUKCJI,
Z.STATUS,
Z.NR_ADR_DOST,
Z.NR_KONTRAKTU,
Z.IL_POZ,
(Z.IL_CIET+Z.I_KOM+Z.II_KOM+Z.IL_STRUKT+IL_SCH) ILE_SZYB,
(Z.POW_C  +Z.POW_I+Z.POW_II+Z.POW_S+Z.POW_SCH) ILE_M2,
Z.WALUTA,
Z.NR_KOMP_ROKP,
KLIENT.SKROT_K,
nvl(PAMLIST.NR_LISTY,0) NR_LISTY
FROM ZAMOW Z
LEFT JOIN KLIENT
ON Z.NR_KON=KLIENT.NR_KON
LEFT JOIN PAMLIST
ON Z.NR_KOM_ZLEC=PAMLIST.NR_K_ZLEC
WITH READ ONLY
;
--------------------------------------------------------
--  DDL for View OBR_WG_DNI
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "OBR_WG_DNI" ("NKINS", "NKZP", "NKOBR", "IL_PLAN", "WPNETTO", "WPBRUTTO", "IL_WYK", "WWNETTO", "WWBRUTTO") AS select distinct nr_komp_INSTAL as NKINS, nr_zm_plan as NKZP, nr_komp_obr as NKOBR,
sum(il_plan) as il_plan, sum(il_plan*il_jedn) as WPNETTO, sum(il_plan*il_jedn*wsp_przel) as WPBRUTTO,
sum(il_wyk) as il_wyk, sum(il_wyk*il_jedn) as WWNETTO, sum(il_wyk*il_jedn*wsp_przel) as WWBRUTTO
from wykzal group by nr_komp_INSTAL, nr_zm_plan, nr_komp_obr
;
--------------------------------------------------------
--  DDL for View OBR_WG_DNI_WYK
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "OBR_WG_DNI_WYK" ("NKINS", "NKZW", "NKOBR", "FLAG", "IL_WYK", "WWNETTO", "WWBRUTTO") AS select distinct nr_komp_INSTAL as NKINS, nr_komp_zm as NKZW, nr_komp_obr as NKOBR,flag as flag,
sum(il_wyk) as il_wyk, sum(il_wyk*il_jedn) as WWNETTO, sum(il_wyk*il_jedn*wsp_przel) as WWBRUTTO
from wykzal where  flag>1
group by nr_komp_INSTAL, nr_komp_zm, nr_komp_obr, flag
;
--------------------------------------------------------
--  DDL for View OBR_WG_INDEKS
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "OBR_WG_INDEKS" ("NKINS", "NKZP", "NKZLEC", "INDEKS", "NKOBR", "IL_PLAN", "WPNETTO", "WPBRUTTO", "IL_WYK", "WWNETTO", "WWBRUTTO") AS select distinct nr_komp_INSTAL as NKINS,nr_zm_plan as NKZP, nr_komp_zlec as NKZLEC, indeks as INDEKS, nr_komp_obr as NKOBR,
sum(il_plan) as il_plan, sum(il_plan*il_jedn) as WPNETTO, sum(il_plan*il_jedn*wsp_przel) as WPBRUTTO,
sum(il_wyk) as il_wyk, sum(il_wyk*il_jedn) as WWNETTO, sum(il_wyk*il_jedn*wsp_przel) as WWBRUTTO
from wykzal group by nr_komp_INSTAL,nr_zm_plan, nr_komp_zlec , indeks , nr_komp_obr
;
--------------------------------------------------------
--  DDL for View OBR_WG_INDEKS_WYK
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "OBR_WG_INDEKS_WYK" ("NKINS", "NKZW", "NKZLEC", "INDEKS", "NKOBR", "FLAG", "IL_WYK", "WWNETTO", "WWBRUTTO") AS select distinct nr_komp_INSTAL as NKINS,nr_komp_zm as NKZW, nr_komp_zlec as NKZLEC, indeks as INDEKS, nr_komp_obr as NKOBR,
flag as flag,
sum(il_wyk) as il_wyk, sum(il_wyk*il_jedn) as WWNETTO, sum(il_wyk*il_jedn*wsp_przel) as WWBRUTTO
from wykzal where flag>1
group by nr_komp_INSTAL,nr_komp_zm, nr_komp_zlec , indeks , nr_komp_obr, flag
;
--------------------------------------------------------
--  DDL for View SZKLO_WG_GR
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "SZKLO_WG_GR" ("NR_KOMP_ZLEC", "NR_PODGR", "NR_KAT", "IL_SZT", "IL_WARST", "SUMA_POW") AS select distinct spisz.nr_kom_zlec as nr_komp_zlec, spisz.nr_podgr as nr_podgr,
spisd.nr_kat as nr_kat,
sum(ilosc) as il_szt, count(*)as il_warst, sum(spisz.ilosc*0.000001*szer_obr*wys_obr)as suma_pow from
spisz, spisd where spisd.nr_kom_zlec=spisz.nr_kom_zlec and spisd.nr_poz=spisz.nr_poz and spisd.strona=0
and spisd.nr_kat in (select nr_kat from katalog where rodz_sur='TAF')
group by spisz.nr_kom_zlec, spisz.nr_podgr, spisd.nr_kat
;
--------------------------------------------------------
--  DDL for View V_CUTMON_LABELS
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_CUTMON_LABELS" ("NR_KOM_ZLEC", "NR_ZLEC", "NR_POZ", "NR_SZT", "NR_WARST", "NR_KON", "KOD_STR", "NAZ_STR", "ZN_ZESP", "NAZ_DLA_KLI", "GR_TOW", "NR_ANAL", "P027_NAZPUBL", "K027_NAZ_STR", "P024_UWSP", "K024_UWSP") AS SELECT distinct L.nr_kom_zlec, Z.nr_zlec, L.nr_poz_zlec nr_poz, L.nr_szt, L.nr_warst,
        Z.nr_kon, kod_str, S.naz_str, S.zn_zesp, S.naz_dla_kli, S.gr_tow, S.nr_anal,
        replace(S.naz_str,'\','\\') P027_nazpubl, replace(S.naz_str,'\','\\') K027_naz_str,
        S.wsp_k P024_Uwsp, S.wsp_k K024_Uwsp
 FROM l_wyc L
 LEFT JOIN zamow Z ON Z.nr_kom_zlec=L.nr_kom_zlec
 LEFT JOIN spisz P ON P.nr_kom_zlec=L.nr_kom_zlec and P.nr_poz=L.nr_poz_zlec
 LEFT JOIN struktury S USING (kod_str)
;
--------------------------------------------------------
--  DDL for View V_ETYKIETY_PROD2
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_ETYKIETY_PROD2" ("NR_KOMP_ZLEC", "NR_ZLEC", "NR_POZ", "NR_SZT", "NR_WAR", "F_ZLEC_ORG", "F_ORG_POS", "F_ORG_LAYER", "F_ORG_CUSTOMER", "F_DATA_PLAN_SPED", "F_GLEB_USZCZ", "F_TYPE_ORDER", "F_WEIGHT", "F_PROCESSING_ORDER") AS select distinct
L.nr_kom_zlec nr_komp_zlec,
Z.nr_zlec,
L.nr_poz_zlec nr_poz,
L.nr_szt,
L.nr_warst nr_war,
case(z.wyroznik)
when 'W' then nvl(z1.nr_zlec,'')
when 'B' then nvl(z2.nr_zlec,'')
else nvl(z.nr_zlec,'')
end f_zlec_org,
case(z.wyroznik)
when 'W' then nvl(p.nr_poz_pop,0)
when 'B' then nvl(l2.NR_POZ_ZLEC,0)
else nvl(L.nr_poz_zlec,'')
end f_org_pos,
case(z.wyroznik)
when 'W' then wew.nr_war_org
else l.nr_warst
end f_org_layer,
case(z.wyroznik)
when 'W' then nvl(kon1.skrot_k,'')
else nvl(kon.skrot_k,'')
end f_org_customer,
case(z.wyroznik)
when 'B' then to_char(z2.d_pl_sped,'DD/MM/YYYY')
when 'W' then to_char(z1.d_pl_sped,'DD/MM/YYYY')
else to_char(z.d_pl_sped,'DD/MM/YYYY')
end f_data_plan_sped,
p.gr_sil f_gleb_uszcz,
z.wyroznik f_type_order,
round(str.waga*p.szer*p.wys/1000000,1) f_WEIGHT,
ks.symbol f_processing_order
from l_wyc l
left join spisz p on p.NR_KOM_ZLEC=l.nr_kom_zlec and p.NR_POZ=l.nr_poz_zlec
left join zamow z on z.nr_kom_zlec=l.NR_KOM_ZLEC
left join zamow z1 on z1.nr_kom_zlec=z.nr_komp_poprz
left join l_wyc l2 on l2.ID_REK=l.ID_ORYG
left join zamow z2 on z2.nr_kom_zlec=l2.NR_KOM_ZLEC
left join v_zlecenia_wew_pozycje wew on wew.nr_komp_zlec=l.nr_kom_zlec and wew.nr_poz=l.nr_poz_zlec and wew.nr_war=L.nr_warst
left join klient kon on kon.nr_kon=z.nr_kon
left join klient kon1 on kon1.nr_kon=z1.nr_kon
left join struktury str on str.kod_str=p.kod_str
left join kol_stojakow ks on ks.nr_komp_zlec=l.nr_kom_zlec and ks.nr_poz=l.nr_poz_zlec and ks.nr_sztuki=L.NR_SZT and ks.nr_warstwy=L.NR_WARST
;
--------------------------------------------------------
--  DDL for View V_IL_ZAMOW
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_IL_ZAMOW" ("NR_KOM_ZLEC", "IL_POZ", "IL_SZYB", "IL_M2", "IL_KSZT", "IL_SZABL", "IL_SZPR", "IL_POL_SZPR", "IL_METEK", "IL_WYPROD", "IL_ZATW", "IL_NA_STOJ", "IL_W_SPED", "IL_WYSL", "IL_ANUL", "IL_BR", "DNI_OPOZN") AS SELECT nr_kom_zlec, sum(il_poz), sum(il_szyb), sum(il_m2),
        sum(il_kszt), sum(il_szabl), sum(il_szpr), sum(il_pol_szpr),
        nvl(sum(il_metek),0) il_metek, nvl(sum(il_wyprod),0) il_wyprod, nvl(sum(il_zatw),0) il_zatw,
        nvl(sum(il_na_stoj),0) il_na_stoj, nvl(sum(il_w_sped),0) il_w_sped, nvl(sum(il_wysl),0) il_wysl,
        nvl(sum(il_anul),0) il_anul, nvl(sum(il_br),0) il_br,
        nvl(case when sum(il_szyb)-sum(il_anul)>sum(il_wyprod) and sum(il_szyb)-sum(il_anul)>sum(il_wysl) then sum(dni_po_plan_sped) else -99 end, 0) dni_opozn --nie wsz. wyprod LUB nie wsz. wyslane
FROM (
 SELECT nr_kom_zlec, il_poz,
       il_ciet+i_kom+ii_kom+il_strukt+il_sch il_szyb,
       pow_c+pow_i+pow_ii+pow_s+pow_sch il_m2,
       0 il_kszt, 0 il_szabl, 0 il_szpr, 0 il_pol_szpr,
       0 il_metek, 0 il_wyprod, 0 il_zatw, 0 il_na_stoj, 0 il_w_sped, 0 il_wysl, 0 il_anul, 0 il_br,
       case when status='P' and forma_wprow='P' and d_pl_sped>to_date('0101','YYMM')
            then greatest(-99,trunc(sysdate)-d_pl_sped)
            else -99 end dni_po_plan_sped
 FROM zamow
 UNION
 SELECT nr_kom_zlec, 0, 0, 0,
       sum(decode(nr_kszt,0,0,ilosc)) il_kszt,
       sum(decode(substr(ind_bud,8,1),'1',ilosc,0)) il_szabl,
       sum(decode(substr(ind_bud,4,1),'1',ilosc,0)) il_szpr, 0,
       0, 0, 0, 0, 0, 0, 0, 0, 0
 FROM spisz GROUP BY nr_kom_zlec
 UNION
 SELECT D.nr_kom_zlec, 0, 0, 0, 
       0, 0, 0,
       sum(D.il_pol_szp*P.ilosc),
      0, 0, 0, 0, 0, 0, 0, 0, 0
 FROM spisd D
 LEFT JOIN spisz P ON P.nr_kom_zlec=D.nr_kom_zlec and D.nr_poz=P.nr_poz
 WHERE to_number(trim(substr(D.nr_poc,1,2)),'99') BETWEEN 2 AND 10
 GROUP BY D.nr_kom_zlec
 UNION
 SELECT nr_komp_zlec, 0, 0, 0, 
       0, 0, 0, 0,
       count(1) il_metek,
       sum(decode(zn_wyk,1,1,2,1,0)) il_wyprod,
       sum(decode(zn_wyk,2,1,0,decode(zm_wyk,0,0,1),0)) il_zatw, --przy zn_wyk sprawdzana zmiana_wyk (zatw.bez CUTMONa nie ustawa zn_wyk)
       sum(decode(nr_stoj_sped,0,0,1)) il_na_stoj,
       sum(decode(flag_real,1,0)) il_w_sped,
       sum(decode(flag_real,2,1,0)) il_wysl, 
       sum(decode(zn_wyk,9,1,0)) il_anul,
       0 il_br, 0
 FROM spise 
 GROUP BY nr_komp_zlec
 UNION
 SELECT nr_zlec, 0, 0, 0,
      0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0,
      count(1) il_br, 0
 FROM braki_b
 GROUP BY nr_zlec
 UNION
 --dla zlecên braków sprawdzenie wyprodukowania zlecen Ÿród³owych
 SELECT braki_b.zlec_braki, 0, 0, 0,
      0, 0, 0, 0,
      0 il_metek,
      sum(decode(spise.zn_wyk,1,1,2,1,0)) il_wyprod,
      sum(decode(spise.zn_wyk,2,1,0,decode(spise.zm_wyk,0,0,1),0)) il_zatw, --przy zn_wyk sprawdzana zmiana_wyk (zatw.bez CUTMONa nie ustawa zn_wyk)
      0, 0, 0, 
      sum(decode(spise.zn_wyk,9,1,0)) il_anul,
      0 il_br, 0
 FROM braki_b
 LEFT JOIN spise USING (nr_kom_szyby)
 GROUP BY braki_b.zlec_braki
 )
GROUP BY nr_kom_zlec
WITH READ ONLY
;
--------------------------------------------------------
--  DDL for View V_KOL_STOJAKOW
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_KOL_STOJAKOW" ("NR_LISTY", "TYP_KATALOG", "NR_KATALOG", "NR_KOMP_ZLEC", "NR_POZ", "NR_SZTUKI", "NR_WARSTWY", "NR_STOJ_CIECIA", "POZ_STOJAKA_CIECIA", "POZ_STOJAKA_DOCEL", "SERIALNO", "RACK_NO", "NR_PODGRUPY", "NR_INSTALACJI", "NR_OPTYM", "NR_TAF", "NR_GRUPY", "LISTA_INST", "SYMBOL") AS SELECT "NR_LISTY","TYP_KATALOG","NR_KATALOG","NR_KOMP_ZLEC","NR_POZ","NR_SZTUKI","NR_WARSTWY","NR_STOJ_CIECIA","POZ_STOJAKA_CIECIA","POZ_STOJAKA_DOCEL","SERIALNO","RACK_NO","NR_PODGRUPY","NR_INSTALACJI","NR_OPTYM","NR_TAF","NR_GRUPY","LISTA_INST","SYMBOL" FROM KOL_STOJAKOW
;
--------------------------------------------------------
--  DDL for View V_LIPRODZ_BCD
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_LIPRODZ_BCD" ("NR_KOM_ZLEC", "NR_POZ", "NR_SZT", "LIPROD_BCD") AS select
  e.nr_komp_zlec NR_KOM_ZLEC,
  e.nr_poz,
  e.nr_szt,
  liprod280_BCD(e.nr_kom_szyby) liprod_bcd
  from spise e
;
--------------------------------------------------------
--  DDL for View V_LIPRODZ_BEA
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_LIPRODZ_BEA" ("NR_KOM_ZLEC", "NR_POZ", "NR_EL_WEW", "LIPROD_BEA") AS select 
  vzm.nr_kom_zlec,
  vzm.nr_poz,
  vzm.nr_el_wew,
  liprod280_bea(vzm.nr_kom_zlec,vzm.nr_poz,vzm.nr_el_wew) liprod_bea
from v_zlec_mon vzm order by nr_el_wew
;
--------------------------------------------------------
--  DDL for View V_LIPRODZ_BTH
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_LIPRODZ_BTH" ("LIPROD280_BTH") AS select 
  liprod280_bth from dual
;
--------------------------------------------------------
--  DDL for View V_LIPRODZ_ELEM
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_LIPRODZ_ELEM" ("NR_KOM_ZLEC", "NR_POZ", "NR_EL_WEW", "LIPROD_ELEM") AS select 
  vzm.nr_kom_zlec,
  vzm.nr_poz,
  vzm.nr_el_wew,
  liprod280_elem(vzm.nr_kom_zlec,vzm.nr_poz,vzm.nr_el_wew) liprod_elem
from v_zlec_mon vzm order by nr_el_wew
;
--------------------------------------------------------
--  DDL for View V_LIPRODZ_ORD
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_LIPRODZ_ORD" ("NR_KOM_ZLEC", "ORD") AS select 
  z.nr_kom_zlec, liprod280_ord(z.nr_kom_zlec) ord
from zamow z
;
--------------------------------------------------------
--  DDL for View V_LIPRODZ_POS
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_LIPRODZ_POS" ("NR_KOM_ZLEC", "NR_ZLEC", "NR_POZ", "NR_SZT", "LIPROD_POS") AS select 
  e.nr_komp_zlec nr_kom_zlec,
  e.nr_zlec,
  e.nr_poz,e.nr_szt,
  liprod280_pos(e.nr_komp_zlec,e.nr_poz,e.nr_szt) liprod_pos
from spise e
;
--------------------------------------------------------
--  DDL for View V_LIPRODZ_REL
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_LIPRODZ_REL" ("LIPROD280_REL") AS select 
  liprod280_rel from dual
;
--------------------------------------------------------
--  DDL for View V_LIPRODZ_SHP
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_LIPRODZ_SHP" ("NR_KOM_ZLEC", "NR_POZ", "NR_EL_WEW", "LIPROD_SHP") AS select 
  vzm.nr_kom_zlec,
  vzm.nr_poz,
  vzm.nr_el_wew,
  liprod280_shp(vzm.nr_kom_zlec,vzm.nr_poz,vzm.nr_el_wew) liprod_shp
from v_zlec_mon vzm order by nr_el_wew
;
--------------------------------------------------------
--  DDL for View V_MON_STR
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_MON_STR" ("NR_KOM_STR", "NR_EL", "WAR_OD", "WAR_DO", "GRUB", "GAZ", "MIEKKA_POW", "MIN_NR_SKL", "MAX_NR_SKL") AS SELECT nr_kom_str, to_number(substr(nr_el_nr_war,1,1)) nr_el,
       min(to_number(substr(nr_el_nr_war,2))) war_od,
       max(to_number(substr(nr_el_nr_war,2))) war_do,
    sum(grub) grub,
    max(decode(znacz_pr,'3.Ga',typ_kat,null)) gaz,
    max(decode(znacz_pr,'1.Mi',1,null)) miekka_pow,
    min(nr_skl) min_nr_skl,
    max(nr_skl) max_nr_skl
FROM
(
SELECT V.*,
     --podzapytania wylicza NR_ELEM i NR_WAR (skleja w string typu '56')
    (select nvl(sum(decode(rodz_sur,'LIS',1,0)),0)*2/*il_LIS_przed*/
                   +case when V.rodz_sur='LIS' then 1/*+1 je¿eli obecny rekord LIS*/
                         when nvl(max(decode(W.rodz_sur,'LIS',W.nr_skl,0)),0)=V.nr_skl then -1 /*-1 jezlei skladniki zespolenia bo bylo x2 przy LIS*/
                         else 0 end
                   +1     /*NR_ELEM*/
             ||nvl(sum(il_war),0)+V.il_war/*NR_WAR*/
              from v_sur_str W
              where W.nr_kom_str=V.nr_kom_str and il_war>0 and (W.nr_skl<V.nr_skl or W.nr_skl=V.nr_skl and W.nr_skl1<V.nr_skl1)
            ) nr_el_nr_war
 FROM v_sur_str V
 --WHERE V.nr_kom_str=:pNR_STR
)
GROUP BY nr_kom_str, substr(nr_el_nr_war,1,1)
ORDER BY nr_kom_str, nr_el
;
--------------------------------------------------------
--  DDL for View V_SPISD
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_SPISD" ("NR_ZLEC", "TYP_ZLEC", "NR_POZ", "KOL_DOD", "KOD_DOD", "ZN_WAR", "NR_POC", "WSP1", "WSP2", "WSP3", "WSP4", "CENA", "IL_POL_SZP", "NR_KOM_ZLEC", "NR_ODDZ", "ROK", "MIES", "DO_WAR", "NR_MAG", "IDENT_SZP", "IL_ODC_PION", "IL_ODC_POZ", "NR_KOMP_RYS", "ILOSC_DO_WYK", "NR_KOMP_OBR", "NR_KAT", "STRONA", "PAR1", "PAR2", "PAR3", "PAR4", "PAR5", "SZER_OBR", "WYS_OBR", "IL_BOK", "IL_WYK", "IDENT", "MARZA") AS select "NR_ZLEC","TYP_ZLEC","NR_POZ","KOL_DOD","KOD_DOD","ZN_WAR","NR_POC","WSP1","WSP2","WSP3","WSP4","CENA","IL_POL_SZP","NR_KOM_ZLEC","NR_ODDZ","ROK","MIES","DO_WAR","NR_MAG","IDENT_SZP","IL_ODC_PION","IL_ODC_POZ","NR_KOMP_RYS","ILOSC_DO_WYK","NR_KOMP_OBR","NR_KAT","STRONA","PAR1","PAR2","PAR3","PAR4","PAR5","SZER_OBR","WYS_OBR","IL_BOK","IL_WYK","IDENT","MARZA" from spisd
;
--------------------------------------------------------
--  DDL for View V_SPISW_SUMPOZ
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_SPISW_SUMPOZ" ("NR_KOM_ZLEC", "NR_POZ", "NR_INST", "ZLEC_BRAKI", "NR_OBR", "DATA_WYK", "ID_PRAC", "IL_SZT", "IL_OBR", "INDEKS", "KOLEJN") AS select distinct a.nr_kom_zlec, a.nr_poz, a.nr_inst, nvl(b.nr_kom_zlec,a.brak) zlec_braki, a.nr_obr, a.data_wyk, a.id_prac,
count(1) il_szt,
sum(case when i.ty_inst in ('MON','STR') or i.rodz_plan in (3,5) then Z.pow else a.il_obr/a.il_wyc end) il_obr,
case when i.ty_inst in ('MON','STR') then min(z.kod_str) else l.typ_kat end indeks, i.kolejn
from spisw a
left join parinst i on i.nr_komp_inst=a.nr_inst
left join spisz Z on Z.nr_kom_zlec=a.nr_kom_zlec and Z.nr_poz=a.nr_poz
left join l_wyc b on a.brak=1 and b.nr_inst=a.nr_inst and b.d_wyk=a.data_wyk and b.zm_wyk=a.zm_wyk and b.wyroznik='B' and b.id_oryg>0
left join l_wyc l on l.nr_kom_zlec=a.nr_kom_zlec and l.nr_poz_zlec=a.nr_poz and l.nr_szt=a.nr_szt and
(a.brak=0 and l.nr_inst=a.nr_inst and a.data_wyk=l.d_wyk and a.zm_wyk=l.zm_wyk or
a.brak=1 and l.id_rek=b.id_oryg)
where  a.nr_komp_zm>0
and (a.brak=0 or a.brak=1 and  l.id_rek is not null)
--and a.nr_kom_zlec=:1
group by a.nr_kom_zlec,a.nr_inst,i.ty_inst,i.kolejn,a.id_prac,a.nr_poz,l.typ_kat,b.nr_kom_zlec,a.brak,a.nr_obr,a.data_wyk
order by a.nr_kom_zlec, a.nr_poz, i.kolejn
;
--------------------------------------------------------
--  DDL for View V_STR_MON
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_STR_MON" ("NR_KOM_STR", "NR_EL", "NR_EL_WEW", "WAR_OD", "WAR_DO", "GRUB", "GAZ", "SILIKON", "MIEKKA_POW", "MIN_NR_SKL", "MAX_NR_SKL", "TYP_KAT", "NR_KAT") AS SELECT nr_kom_str, 
    to_number(substr(nr_el_nr_war,1,1),'9') nr_el, 
    rank() over (partition by nr_kom_str order by to_number(substr(nr_el_nr_war,1,1),'9') desc) nr_el_wew,
       min(to_number(substr(nr_el_nr_war,2))) war_od,
       max(to_number(substr(nr_el_nr_war,2))) war_do,
    sum(grub) grub,
    max(decode(znacz_pr,'3.Ga',typ_kat,null)) gaz,
    max(decode(znacz_pr,'17.',1,null)) silikon,
    max(decode(znacz_pr,'1.Mi',1,null)) miekka_pow,
    min(nr_skl) min_nr_skl,
    max(nr_skl) max_nr_skl,
    decode(
        min(to_number(substr(nr_el_nr_war,2)))-max(to_number(substr(nr_el_nr_war,2))),
        0,
        min(decode(rodz_sur,'TAF',typ_kat,'LIS',typ_kat,null)),
        'LAMINAT') typ_kat,
    decode(
        min(to_number(substr(nr_el_nr_war,2)))-max(to_number(substr(nr_el_nr_war,2))),
        0,
        min(decode(rodz_sur,'TAF',nr_kat,'LIS',nr_kat,null)),
        -1) nr_kat
    
FROM
(
SELECT V.*,
     --podzapytania wylicza NR_ELEM i NR_WAR (skleja w string typu '56')
    (select nvl(sum(decode(rodz_sur,'LIS',1,0)),0)*2/*il_LIS_przed*/
                   +case when V.rodz_sur='LIS' then 1/*+1 jezeli obecny rekord LIS*/
                         when nvl(max(decode(W.rodz_sur,'LIS',W.nr_skl,0)),0)=V.nr_skl then -1 /*-1 jezeli skladniki zespolenia bo bylo x2 przy LIS*/
                         else 0 end
                   +1     /*NR_ELEM*/
             ||nvl(sum(il_war),0)+V.il_war/*NR_WAR*/ 
              from v_str_sur W
              where W.nr_kom_str=V.nr_kom_str and il_war>0 and (W.nr_skl<V.nr_skl or W.nr_skl=V.nr_skl and W.nr_skl1<V.nr_skl1)
            ) nr_el_nr_war
 FROM v_str_sur V
 --WHERE V.nr_kom_str=:pNR_STR
)
GROUP BY nr_kom_str, substr(nr_el_nr_war,1,1)
ORDER BY nr_kom_str, nr_el,nr_el_wew
;
--------------------------------------------------------
--  DDL for View V_STR_MON_ZLEC
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_STR_MON_ZLEC" ("NR_KOM_ZLEC", "NR_POZ", "NR_KOM_STR", "KOD_STR", "NR_EL", "NR_EL_WEW", "WAR_OD", "WAR_DO", "GRUB", "GAZ", "SILIKON", "MIEKKA_POW", "MIN_NR_SKL", "MAX_NR_SKL", "TYP_KAT", "NR_KAT") AS SELECT nr_kom_zlec, nr_poz, nr_kom_str, V.kod_str,
    to_number(substr(nr_el_nr_war,1,1),'9') nr_el, 
    rank() over (partition by nr_kom_zlec, nr_poz, nr_kom_str order by to_number(substr(nr_el_nr_war,1,1),'9') desc) nr_el_wew,
       min(to_number(substr(nr_el_nr_war,2))) war_od,
       max(to_number(substr(nr_el_nr_war,2))) war_do,
    sum(grubosc) grub,
    max(decode(znacz_pr,'3.Ga',typ_kat,null)) gaz,
    max(decode(znacz_pr,'17.',1,null)) silikon,
    max(decode(znacz_pr,'1.Mi',1,null)) miekka_pow,
    min(nr_skl) min_nr_skl,
    max(nr_skl) max_nr_skl,
    decode(
        min(to_number(substr(nr_el_nr_war,2)))-max(to_number(substr(nr_el_nr_war,2))),
        0,
        min(decode(rodz_sur,'TAF',typ_kat,'LIS',typ_kat,null)),
        'LAMINAT') typ_kat,
    decode(
        min(to_number(substr(nr_el_nr_war,2)))-max(to_number(substr(nr_el_nr_war,2))),
        0,
        min(decode(rodz_sur,'TAF',nr_kat,'LIS',nr_kat,null)),
        -1) nr_kat
    
FROM
(
SELECT V.*,
     --podzapytania wylicza NR_ELEM i NR_WAR (skleja w string typu '56')
    (select nvl(sum(decode(rodz_sur,'LIS',1,0)),0)*2/*il_LIS_przed*/
                   +case when V.rodz_sur='LIS' then 1/*+1 jeÃ„Å¹Ä¹Ä½Ã‹Å¥eli obecny rekord LIS*/
                         when nvl(max(decode(W.rodz_sur,'LIS',W.nr_skl,0)),0)=V.nr_skl then -1 /*-1 jezlei skladniki zespolenia bo bylo x2 przy LIS*/
                         else 0 end
                   +1     /*NR_ELEM*/
             ||nvl(sum(il_war),0)+V.il_war/*NR_WAR*/ 
              from v_str_sur_union W
              where W.nr_kom_str=V.nr_kom_str and il_war>0 and (W.nr_skl<V.nr_skl or W.nr_skl=V.nr_skl and W.nr_skl1<V.nr_skl1)
            ) nr_el_nr_war
 FROM v_str_sur_zlec_union V
) V
GROUP BY nr_kom_zlec, nr_poz, nr_kom_str, V.kod_Str,substr(nr_el_nr_war,1,1)
ORDER BY nr_kom_zlec, nr_poz, nr_kom_str, nr_el,nr_el_wew
;
--------------------------------------------------------
--  DDL for View V_STR_SUR
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_STR_SUR" ("NR_KOM_STR", "NR_SKL", "NR_SKL1", "NR_SKL2", "NR_KAT", "TYP_KAT", "RODZ_SUR", "ZNACZ_PR", "GRUB", "IL_WAR", "KOD_STR") AS select B.nr_kom_str, B.nr_skl, B1.nr_skl nr_skl1, B2.nr_skl nr_skl2,
       decode(B.zn_war,'Pol',(select max(nr_kat) from katalog where rodz_sur='POL'),
                             nvl(K.nr_kat,nvl(K1.nr_kat,K2.nr_kat))) nr_kat, 
       decode(B.zn_war,'Pol',S.kod_str,nvl(K.typ_kat,nvl(K1.typ_kat,K2.typ_kat))) typ_kat,
       decode(B.zn_war,'Pol','POL',nvl(K.rodz_sur,nvl(K1.rodz_sur,K2.rodz_sur))) rodz_sur,
       decode(B.zn_war,'Pol','0.',nvl(K.znacz_pr,nvl(K1.znacz_pr,K2.znacz_pr))) znacz_pr,
       decode(B.zn_war,'Pol',S.gr_pak,nvl(K.grubosc,nvl(K1.grubosc,K2.grubosc))) grub,
       decode(B.zn_war,'Pol',S.il_szk,
                            decode(nvl(K.rodz_sur,nvl(K1.rodz_sur,K2.rodz_sur)),'TAF',1,'LIS',1,0)) il_war,
--       decode(B.zn_war,'Sur',K.nr_kat,K1.nr_kat) nr_kat,
--       decode(B.zn_war,'Sur',K.typ_kat,K1.typ_kat) typ_kat,
--       decode(B.zn_war,'Sur',K.rodz_sur,K1.rodz_sur) rodz_sur,
--       decode(B.zn_war,'Sur',K.znacz_pr,K1.znacz_pr) znacz_pr,
      B.kod_str
   from budstr B
   left join katalog K on B.zn_war='Sur' and K.nr_kat=B.nr_kom_skl
   left join struktury S on B.zn_war<>'Sur' and S.nr_kom_str=B.nr_kom_skl
   left join budstr B1 on B.zn_war='Str' and B1.nr_kom_str=B.nr_kom_skl
   left join katalog K1 on B.zn_war='Str' and B1.zn_war='Sur' and K1.nr_kat=B1.nr_kom_skl
   left join budstr B2 on B1.zn_war='Str' and B2.nr_kom_str=B1.nr_kom_skl
   left join katalog K2 on B1.zn_war='Str' and B2.zn_war='Sur' and K2.nr_kat=B2.nr_kom_skl
--   where B.nr_kom_str=:pNR_STR
   order by B.nr_skl, B1.nr_skl, B2.nr_skl
;
--------------------------------------------------------
--  DDL for View V_STR_SUR_UNION
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_STR_SUR_UNION" ("NR_KOM_STR", "NR_SKL", "NR_SKL1", "NR_SKL2", "NR_KAT", "TYP_KAT", "RODZ_SUR", "ZNACZ_PR", "GRUBOSC", "IL_WAR", "KOD_STR") AS SELECT B.nr_kom_str, B.nr_skl,  0 nr_skl1, 0 nr_skl2, K.nr_kat, K.typ_kat, K.rodz_sur, K.znacz_pr, K.grubosc,
         case when K.rodz_sur in ('TAF','LIS') then 1 else 0 end il_war, B.kod_str
  FROM budstr B
  LEFT JOIN katalog K ON K.nr_kat=B.nr_kom_skl
  WHERE zn_war='Sur'
  -- 2 POZIOM 'Sur'
  UNION
  SELECT B.nr_kom_str, B.nr_skl,  B1.nr_skl, 0, K1.nr_kat, K1.typ_kat, K1.rodz_sur, K1.znacz_pr, K1.grubosc,
         case when K1.rodz_sur in ('TAF','LIS') then 1 else 0 end il_war, B.kod_str
  FROM budstr B
  LEFT JOIN budstr B1 ON B1.nr_kom_str=B.nr_kom_skl 
  LEFT JOIN katalog K1  ON K1.nr_kat=B1.nr_kom_skl
  WHERE B.zn_war='Str' and B1.zn_war='Sur'
  -- 3 POZIOM 'Sur'
  UNION
  SELECT B.nr_kom_str, B.nr_skl,  B1.nr_skl, B2.nr_skl, K2.nr_kat, K2.typ_kat, K2.rodz_sur, K2.znacz_pr, K2.grubosc,
         case when K2.rodz_sur in ('TAF','LIS') then 1 else 0 end il_war, B.kod_str
  FROM budstr B
  LEFT JOIN budstr B1 ON B1.nr_kom_str=B.nr_kom_skl 
  LEFT JOIN budstr B2 ON B2.nr_kom_str=B1.nr_kom_skl 
  LEFT JOIN katalog K2 ON K2.nr_kat=B2.nr_kom_skl
  WHERE B.zn_war='Str' and B1.zn_war='Str' and B2.zn_war='Sur'
  -- 1 POZIOM 'Pol'
  UNION
  SELECT B.nr_kom_str, B.nr_skl,  0, 0, (select max(nr_kat) from katalog where rodz_sur='POL'),
         S.kod_str, 'POL', '0. ', S.gr_pak, S.il_szk il_war, B.kod_str
  FROM budstr B
  LEFT JOIN struktury S  ON S.nr_kom_str=B.nr_kom_skl
  WHERE B.zn_war='Pol'
;
--------------------------------------------------------
--  DDL for View V_STR_SUR_ZLEC
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_STR_SUR_ZLEC" ("NR_KOM_ZLEC", "NR_POZ", "NR_KOM_STR", "NR_SKL", "NR_SKL1", "NR_SKL2", "NR_KAT", "TYP_KAT", "RODZ_SUR", "ZNACZ_PR", "GRUB", "IL_WAR", "KOD_STR") AS select P.nr_kom_zlec, P.nr_poz, B.nr_kom_str, B.nr_skl, B1.nr_skl nr_skl1, B2.nr_skl nr_skl2,
       decode(B.zn_war,'Pol',(select max(nr_kat) from katalog where rodz_sur='POL'),
                             nvl(K.nr_kat,nvl(K1.nr_kat,K2.nr_kat))) nr_kat, 
       decode(B.zn_war,'Pol',S.kod_str,nvl(K.typ_kat,nvl(K1.typ_kat,K2.typ_kat))) typ_kat,
       decode(B.zn_war,'Pol','POL',nvl(K.rodz_sur,nvl(K1.rodz_sur,K2.rodz_sur))) rodz_sur,
       decode(B.zn_war,'Pol','0.',nvl(K.znacz_pr,nvl(K1.znacz_pr,K2.znacz_pr))) znacz_pr,
       decode(B.zn_war,'Pol',S.gr_pak,nvl(K.grubosc,nvl(K1.grubosc,K2.grubosc))) grub,
       decode(B.zn_war,'Pol',S.il_szk,
                            decode(nvl(K.rodz_sur,nvl(K1.rodz_sur,K2.rodz_sur)),'TAF',1,'LIS',1,0)) il_war,
      B.kod_str
   from spisz P
   left join budstr B on B.kod_str=P.kod_str
   left join katalog K on B.zn_war='Sur' and K.nr_kat=B.nr_kom_skl
   left join struktury S on B.zn_war<>'Sur' and S.nr_kom_str=B.nr_kom_skl
   left join budstr B1 on B.zn_war='Str' and B1.nr_kom_str=B.nr_kom_skl
   left join katalog K1 on B.zn_war='Str' and B1.zn_war='Sur' and K1.nr_kat=B1.nr_kom_skl
   left join budstr B2 on B1.zn_war='Str' and B2.nr_kom_str=B1.nr_kom_skl
   left join katalog K2 on B1.zn_war='Str' and B2.zn_war='Sur' and K2.nr_kat=B2.nr_kom_skl
   order by B.nr_skl, B1.nr_skl, B2.nr_skl
;
--------------------------------------------------------
--  DDL for View V_STR_SUR_ZLEC_UNION
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_STR_SUR_ZLEC_UNION" ("NR_KOM_ZLEC", "NR_POZ", "NR_KOM_STR", "NR_SKL", "NR_SKL1", "NR_SKL2", "NR_KAT", "TYP_KAT", "RODZ_SUR", "ZNACZ_PR", "GRUBOSC", "IL_WAR", "KOD_STR") AS SELECT P.nr_kom_zlec, P.nr_poz, B.nr_kom_str, B.nr_skl,  0 nr_skl1, 0 nr_skl2, K.nr_kat, K.typ_kat, K.rodz_sur, K.znacz_pr, K.grubosc,
         case when K.rodz_sur in ('TAF','LIS') then 1 else 0 end il_war, B.kod_str
  FROM spisz P
  LEFT JOIN budstr B ON B.kod_str=P.kod_str
  LEFT JOIN katalog K ON K.nr_kat=B.nr_kom_skl
  WHERE zn_war='Sur'
  -- 2 POZIOM 'Sur'
  UNION
  SELECT P.nr_kom_zlec, P.nr_poz, B.nr_kom_str, B.nr_skl,  B1.nr_skl, 0, K1.nr_kat, K1.typ_kat, K1.rodz_sur, K1.znacz_pr, K1.grubosc,
         case when K1.rodz_sur in ('TAF','LIS') then 1 else 0 end il_war, B.kod_str
  FROM spisz P
  LEFT JOIN budstr B ON B.kod_str=P.kod_str
  LEFT JOIN budstr B1 ON B1.nr_kom_str=B.nr_kom_skl 
  LEFT JOIN katalog K1  ON K1.nr_kat=B1.nr_kom_skl
  WHERE B.zn_war='Str' and B1.zn_war='Sur'
  -- 3 POZIOM 'Sur'
  UNION
  SELECT P.nr_kom_zlec, P.nr_poz, B.nr_kom_str, B.nr_skl,  B1.nr_skl, B2.nr_skl, K2.nr_kat, K2.typ_kat, K2.rodz_sur, K2.znacz_pr, K2.grubosc,
         case when K2.rodz_sur in ('TAF','LIS') then 1 else 0 end il_war, B.kod_str
  FROM spisz P
  LEFT JOIN budstr B ON B.kod_str=P.kod_str
  LEFT JOIN budstr B1 ON B1.nr_kom_str=B.nr_kom_skl 
  LEFT JOIN budstr B2 ON B2.nr_kom_str=B1.nr_kom_skl 
  LEFT JOIN katalog K2 ON K2.nr_kat=B2.nr_kom_skl
  WHERE B.zn_war='Str' and B1.zn_war='Str' and B2.zn_war='Sur'
  -- 1 POZIOM 'Pol'
  UNION
  SELECT P.nr_kom_zlec, P.nr_poz, B.nr_kom_str, B.nr_skl,  0, 0, (select max(nr_kat) from katalog where rodz_sur='POL'),
         S.kod_str, 'POL', '0. ', S.gr_pak, S.il_szk il_war, B.kod_str
  FROM spisz P
  LEFT JOIN budstr B ON B.kod_str=P.kod_str
  LEFT JOIN struktury S  ON S.nr_kom_str=B.nr_kom_skl
  WHERE B.zn_war='Pol'
;
--------------------------------------------------------
--  DDL for View V_STR_WAR
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_STR_WAR" ("NR_KOM_STR", "NR_SKL", "NR_SKL1", "NR_SKL2", "NR_WAR", "NR_KAT", "TYP_KAT", "RODZ_SUR", "ZNACZ_PR", "GRUB", "IL_WAR", "KOD_STR") AS SELECT nr_kom_str, nr_skl, nr_skl1, nr_skl2,
    rank() over (partition by nr_kom_str order by nr_skl, nr_skl1, nr_skl2) nr_war,
    nr_kat, typ_kat, rodz_sur, znacz_pr, grub, il_war, kod_str
FROM V_STR_SUR
WHERE il_war>0
ORDER BY nr_kom_str, nr_skl, nr_skl1, nr_skl2
;
--------------------------------------------------------
--  DDL for View V_SUR_STR
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_SUR_STR" ("NR_KOM_STR", "NR_SKL", "NR_SKL1", "NR_SKL2", "NR_KAT", "TYP_KAT", "RODZ_SUR", "ZNACZ_PR", "GRUB", "IL_WAR", "KOD_STR") AS select B.nr_kom_str, B.nr_skl, B1.nr_skl nr_skl1, B2.nr_skl nr_skl2,
       decode(B.zn_war,'Pol',(select max(nr_kat) from katalog where rodz_sur='POL'),
                             nvl(K.nr_kat,nvl(K1.nr_kat,K2.nr_kat))) nr_kat,
       decode(B.zn_war,'Pol',S.kod_str,nvl(K.typ_kat,nvl(K1.typ_kat,K2.typ_kat))) typ_kat,
       decode(B.zn_war,'Pol','POL',nvl(K.rodz_sur,nvl(K1.rodz_sur,K2.rodz_sur))) rodz_sur,
       decode(B.zn_war,'Pol','0.',nvl(K.znacz_pr,nvl(K1.znacz_pr,K2.znacz_pr))) znacz_pr,
       decode(B.zn_war,'Pol',S.gr_pak,nvl(K.grubosc,nvl(K1.grubosc,K2.grubosc))) grub,
       decode(B.zn_war,'Pol',S.il_szk,
                            decode(nvl(K.rodz_sur,nvl(K1.rodz_sur,K2.rodz_sur)),'TAF',1,'LIS',1,0)) il_war,
--       decode(B.zn_war,'Sur',K.nr_kat,K1.nr_kat) nr_kat,
--       decode(B.zn_war,'Sur',K.typ_kat,K1.typ_kat) typ_kat,
--       decode(B.zn_war,'Sur',K.rodz_sur,K1.rodz_sur) rodz_sur,
--       decode(B.zn_war,'Sur',K.znacz_pr,K1.znacz_pr) znacz_pr,
      B.kod_str
   from budstr B
   left join katalog K on B.zn_war='Sur' and K.nr_kat=B.nr_kom_skl
   left join struktury S on B.zn_war<>'Sur' and S.nr_kom_str=B.nr_kom_skl
   left join budstr B1 on B.zn_war='Str' and B1.nr_kom_str=B.nr_kom_skl
   left join katalog K1 on B.zn_war='Str' and B1.zn_war='Sur' and K1.nr_kat=B1.nr_kom_skl
   left join budstr B2 on B1.zn_war='Str' and B2.nr_kom_str=B1.nr_kom_skl
   left join katalog K2 on B1.zn_war='Str' and B2.zn_war='Sur' and K2.nr_kat=B2.nr_kom_skl
--   where B.nr_kom_str=:pNR_STR
   order by B.nr_skl, B1.nr_skl, B2.nr_skl
;
--------------------------------------------------------
--  DDL for View V_WYK_WG_INST
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_WYK_WG_INST" ("NR_KOM_ZLEC", "NR_INST", "IL_WYK", "ILE_PLAN", "IL_BR", "ZN_WYROBU", "KOLEJN") AS SELECT  L.nr_kom_zlec,L.Nr_inst, 
         count(case when (case when L.zn_wyrobu=1 then E.data_wyk
                             when Lb.id_rek_br_ost is not null then L2.d_wyk
                             else L.d_wyk 
                        end) > To_date('2001/01/01' ,'YYYY/MM/DD')
                    then 1 else null end) il_wyk,
         count(1) ile_plan,
         nvl(sum(Lb.il_br),0) il_br,  --sum(decode(L.zn_braku,1,1,0)) il_br,
         L.zn_wyrobu, L.kolejn
 FROM l_wyc L
 LEFT JOIN spise E on E.nr_komp_zlec=L.nr_kom_zlec and E.nr_poz=L.nr_poz_zlec and E.nr_szt=L.nr_szt
 LEFT JOIN (select count(1) il_br, max(id_rek) id_rek_br_ost, id_oryg from l_wyc where id_oryg>0 group by id_oryg) Lb
        ON Lb.id_oryg=L.id_rek
 LEFT JOIN l_wyc L2 ON L2.id_rek=Lb.id_rek_br_ost  --rekord ostatniego braku
 WHERE (L.typ_inst not in ('MON','STR') or L.nr_warst=1)
   AND (L.typ_inst in ('A C','R C','MON','STR')
        OR EXISTS
        (select 1 from spisd D0, katalog K, wykzal W
              where D0.nr_kom_zlec=L.nr_kom_zlec and D0.nr_poz=L.nr_poz_zlec and D0.do_war=L.nr_warst and D0.strona=0
                and K.nr_kat=D0.nr_kat
                and W.nr_komp_zlec=D0.nr_kom_zlec and W.nr_poz=D0.nr_poz and W.nr_warst=D0.do_war and W.nr_komp_instal=L.nr_inst
                --obróbka nie jest na warstiwe pólproduktu LUB nie jest obróbk¹ ze SPISD (pochodzi ze struktury a nie z drzewa)
                and (K.rodz_sur<>'POL' or 
                     not exists (select 1 from spisd D
                                 where D.nr_kom_zlec=W.nr_komp_zlec and D.nr_poz=W.nr_poz and D.do_war=W.nr_warst and D.nr_komp_obr=W.nr_komp_obr))
        )
       )     
 GROUP BY  L.nr_kom_zlec,L.Nr_inst,L.zn_wyrobu,L.kolejn
;
--------------------------------------------------------
--  DDL for View V_ZLECENIA_WEW_POZYCJE
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_ZLECENIA_WEW_POZYCJE" ("NR_KOMP_ZLEC", "NR_POZ", "NR_WAR", "NR_KOMP_ZLEC_ORG", "NR_POZ_ORG", "NR_WAR_ORG") AS select 
  zt.nr_komp_zlec,
  zt.nr_poz,
  1 nr_war, 
  zw.NR_KOMP_POPRZ nr_komp_zlec_org,
  pw.NR_POZ_POP nr_poz_org,
  to_number(LINIA,'99') nr_war_org 
from zlec_typ zt
  left join zamow zw on zw.nr_kom_zlec=zt.nr_komp_zlec
  left join spisz pw on pw.nr_kom_zlec=zt.nr_komp_zlec and pw.nr_poz=zt.nr_poz
where typ=202 and zw.status<>'A' and zw.wyroznik<>'B'
;
--------------------------------------------------------
--  DDL for View V_ZLEC_MON
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_ZLEC_MON" ("NR_KOM_ZLEC", "NR_POZ", "NR_EL", "NR_EL_WEW", "GRUB", "GAZ", "SILIKON", "IND_BUD", "STEPL", "STEPD", "STEPP", "STEPG", "USZCZ_ROZNE", "USZCZ_STD", "SZER", "WYS", "ILE_WARSTW", "POWL", "POWR", "NR_KAT", "TYP_KAT", "PAR_KSZT", "SZER_POZ", "WYS_POZ") AS select p.nr_kom_zlec,p.nr_poz
        ,vsm.NR_EL
        ,vsm.NR_EL_wew
        ,vsm.GRUB 
        ,vsm.GAZ
        ,vsm.silikon
        ,p.ind_bud
        ,(select min(wsp1) from spisd d where D.NR_KOM_ZLEC=p.nr_kom_zlec and d.nr_poz=p.nr_poz and d.do_war between vsm.WAR_OD and vsm.war_do and d.strona=0) stepL
        ,(select min(wsp2) from spisd d where D.NR_KOM_ZLEC=p.nr_kom_zlec and d.nr_poz=p.nr_poz and d.do_war between vsm.WAR_OD and vsm.war_do and d.strona=0) stepD
        ,(select min(wsp3) from spisd d where D.NR_KOM_ZLEC=p.nr_kom_zlec and d.nr_poz=p.nr_poz and d.do_war between vsm.WAR_OD and vsm.war_do and d.strona=0) stepP
        ,(select min(wsp4) from spisd d where D.NR_KOM_ZLEC=p.nr_kom_zlec and d.nr_poz=p.nr_poz and d.do_war between vsm.WAR_OD and vsm.war_do and d.strona=0) stepG
--        ,(select max(wsp1) from spisd d left join katalog k on k.nr_kat=d.nr_kat where D.NR_KOM_ZLEC=p.nr_kom_zlec and d.nr_poz=p.nr_poz and d.strona=0 and k.rodz_sur='TAF') max_stepL
--        ,(select max(wsp2) from spisd d left join katalog k on k.nr_kat=d.nr_kat where D.NR_KOM_ZLEC=p.nr_kom_zlec and d.nr_poz=p.nr_poz and d.strona=0 and k.rodz_sur='TAF') max_stepD
--        ,(select max(wsp3) from spisd d left join katalog k on k.nr_kat=d.nr_kat where D.NR_KOM_ZLEC=p.nr_kom_zlec and d.nr_poz=p.nr_poz and d.strona=0 and k.rodz_sur='TAF') max_stepP
--        ,(select max(wsp4) from spisd d left join katalog k on k.nr_kat=d.nr_kat where D.NR_KOM_ZLEC=p.nr_kom_zlec and d.nr_poz=p.nr_poz and d.strona=0 and k.rodz_sur='TAF') max_stepG
        ,(select nvl(count(*),0) from spisd d left join katalog k on k.nr_kat=d.nr_kat where D.NR_KOM_ZLEC=p.nr_kom_zlec and d.nr_poz=p.nr_poz and d.do_war between vsm.WAR_OD and vsm.war_do 
            and d.strona=0 and k.rodz_sur='LIS' and (d.wsp1>0 or  d.wsp2>0 or d.wsp3>0 or d.wsp4>0)) uszcz_rozne
        ,P.GR_SIL uszcz_std
        ,(select max(szer_obr) from spisd d where D.NR_KOM_ZLEC=p.nr_kom_zlec and d.nr_poz=p.nr_poz and d.do_war between vsm.WAR_OD and vsm.war_do and d.strona=0) szer
        ,(select max(wys_obr) from spisd d where D.NR_KOM_ZLEC=p.nr_kom_zlec and d.nr_poz=p.nr_poz and d.do_war between vsm.WAR_OD and vsm.war_do and d.strona=0) wys
        ,vsm.war_do-vsm.war_od+1 ile_warstw
        ,(select nvl(decode(il_odc_pion,'100000000',1),0) from spisd d where D.NR_KOM_ZLEC=p.nr_kom_zlec and d.nr_poz=p.nr_poz and d.do_war= vsm.WAR_OD and d.strona=0) powL
        ,(select nvl(decode(il_odc_pion,'1000000',1),0) from spisd d where D.NR_KOM_ZLEC=p.nr_kom_zlec and d.nr_poz=p.nr_poz and d.do_war= vsm.WAR_do and d.strona=0) powR
        ,vsm.nr_kat
        ,vsm.typ_kat
--        ,p.nrkatk||';'||p.nr_kszt||';'||p.l||';'||p.w1_l1||';'||p.w2_l2||';'||p.h||';'||p.h1||';'||p.h2||';'||p.r||';'||p.r1||';'||p.r2||';'||p.r3 par_kszt
        ,par_ksz_docel(vsm.nr_kom_zlec,vsm.nr_poz,vsm.NR_EL) par_kszt
        ,p.szer szer_poz
        ,p.wys wys_poz
    from v_str_mon_zlec vsm
    left join spisz p on p.nr_kom_zlec=vsm.nr_kom_zlec and p.nr_poz=vsm.nr_poz
    --where p.nr_zlec=:pnrKomStr
    order by p.nr_kom_zlec,p.nr_poz,vsm.nr_el_wew
;
--------------------------------------------------------
--  DDL for View ZLECENIA_VIEW
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "ZLECENIA_VIEW" ("Kontrahent", "Nr zlecenia", "Lista prod", "Nr zlec klienta", "Data zlecenia", "Data plan. spedycji", "Il sztuk", "Il wyk", "Il wys", "Il anul", "IL_POZ", "IL_SZPR", "WYROZNIK", "STATUS", "FORMA_WPROW", "ILE_FAKT", "IL_POTW") AS SELECT DISTINCT ik.skrot_k,
    z.nr_zlec,
    case 
      when pamlist.nr_listy is null
      then 0
      else pamlist.nr_listy
    end,
    z.nr_zlec_kli Nr_zlec_klienta,
    z.data_zl Data_zlecenia,
    z.d_pl_sped DATA_PLAN_SPEDYcji,
    z.il_ciet+z.I_kom+z.II_kom+z.il_strukt il_SZTUK ,
    CASE
      WHEN es.WYK IS NULL
      THEN 0
      ELSE es.WYK 
    END IL_WYK,
    CASE
      WHEN es.WYS IS NULL
      THEN 0
      ELSE es.WYS 
    END IL_WYS,
    CASE
      WHEN es.IL_A IS NULL
      THEN 0
      ELSE es.IL_A 
    END IL_ANUL,
    z.il_poz,
    CASE
      WHEN es.IL_S IS NULL
      THEN 0
      ELSE es.IL_S 
    END IL_S,
    z.wyroznik,
    z.status,
    z.forma_wprow,
    case 
      when es.ILE_FAKT is NULL
      then 0
      else es.ile_FAKT
    end ILE_FAKT,
    CASE
      WHEN A.il IS NULL
      THEN 0
      ELSE A.il
    END il_potw
  FROM zamow z
  LEFT JOIN ecutter_spise es
  ON es.nr_komp_zlec=z.nr_kom_zlec
  JOIN infoklient ik
  ON z.nr_kon=ik.nr_kon
  LEFT JOIN
    (SELECT nr_komp_zlec,
      COUNT(1) il
    FROM zlec_typ
    WHERE nr_poz=0
    AND typ    IN (204,205,206)
    GROUP BY nr_komp_zlec
    ) A
  ON z.nr_kom_zlec=A.nr_komp_zlec
  LEFT JOIN pamlist
  ON pamlist.nr_k_zlec=z.nr_kom_zlec
  WHERE z.wyroznik   IN ('Z','R')
  AND z.status       IN ('P','K')
  ORDER BY z.nr_zlec DESC
;
--------------------------------------------------------
--  DDL for View ZLEC_POZ_VIEW
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "ZLEC_POZ_VIEW" ("NR_KOMP_ZLEC", "NR_ZLEC", "NR_POZ", "ILOSC", "SZER", "WYS", "KOD_STR", "OPIS_KLI", "NAZ_STR", "NR_KLI", "NR_ZLEC_KLI", "NAZ_SKR_KLI") AS select a.nr_kom_zlec nr_komp_zlec, a.nr_zlec nr_zlec, a.nr_poz nr_poz, a.ilosc ilosc,
a.szer szer, a.wys wys, a.kod_str kod_str,a.opis_kli opis_kli,
b.naz_str naz_str, c.nr_kon nr_kli, c.nr_zlec_kli, d.skrot_k naz_skr_kli
from spisz a, struktury b, zamow c, klient d
where b.kod_str=a.kod_str and c.nr_kom_zlec=a.nr_kom_zlec
and d.nr_kon=c.nr_kon and c.typ_zlec='Pro'   WITH READ ONLY
;
--------------------------------------------------------
--  DDL for Table A_BUFOR
--------------------------------------------------------

  CREATE TABLE "A_BUFOR" ("NR_KOL" NUMBER(10,0), "NR_POZ" NUMBER(3,0), "LICZNIK" NUMBER(10,0), "BUFOR" VARCHAR2(1000 BYTE)) ;
--------------------------------------------------------
--  DDL for Table A_C1
--------------------------------------------------------

  CREATE TABLE "A_C1" ("NR_KOLEJNY" NUMBER(10,0), "NR_POZ" NUMBER(3,0), "P1" VARCHAR2(2 BYTE), "P2" VARCHAR2(10 BYTE), "P3" VARCHAR2(4 BYTE), "P4" VARCHAR2(6 BYTE), "P5" VARCHAR2(6 BYTE), "P6" VARCHAR2(6 BYTE), "P7" VARCHAR2(6 BYTE), "P8" VARCHAR2(6 BYTE), "P9" VARCHAR2(6 BYTE), "P10" VARCHAR2(6 BYTE), "P11" VARCHAR2(6 BYTE), "P12" VARCHAR2(6 BYTE), "P13" VARCHAR2(6 BYTE), "P14" VARCHAR2(6 BYTE), "P15" VARCHAR2(6 BYTE), "P16" VARCHAR2(3 BYTE), "P17" VARCHAR2(4 BYTE), "P18" VARCHAR2(15 BYTE)) ;
--------------------------------------------------------
--  DDL for Table A_C2
--------------------------------------------------------

  CREATE TABLE "A_C2" ("NR_KOLEJNY" NUMBER(10,0), "NR_POZ" NUMBER(3,0), "P1" VARCHAR2(2 BYTE), "P2" VARCHAR2(10 BYTE), "P3" VARCHAR2(4 BYTE), "P4" VARCHAR2(6 BYTE), "P5" VARCHAR2(6 BYTE), "P6" VARCHAR2(6 BYTE), "P7" VARCHAR2(6 BYTE), "P8" VARCHAR2(6 BYTE), "P9" VARCHAR2(6 BYTE), "P10" VARCHAR2(6 BYTE), "P11" VARCHAR2(6 BYTE), "P12" VARCHAR2(6 BYTE), "P13" VARCHAR2(6 BYTE), "P14" VARCHAR2(6 BYTE), "P15" VARCHAR2(6 BYTE), "P16" VARCHAR2(15 BYTE)) ;
--------------------------------------------------------
--  DDL for Table A_C3
--------------------------------------------------------

  CREATE TABLE "A_C3" ("NR_KOLEJNY" NUMBER(10,0), "NR_POZ" NUMBER(3,0), "P1" VARCHAR2(2 BYTE), "P2" VARCHAR2(4 BYTE), "P3" VARCHAR2(4 BYTE), "P4" VARCHAR2(4 BYTE), "P5" VARCHAR2(4 BYTE), "P6" VARCHAR2(4 BYTE), "P7" VARCHAR2(4 BYTE), "P8" VARCHAR2(4 BYTE), "P9" VARCHAR2(4 BYTE), "P10" VARCHAR2(4 BYTE), "P11" VARCHAR2(4 BYTE), "P12" VARCHAR2(4 BYTE), "P13" VARCHAR2(4 BYTE), "P14" VARCHAR2(4 BYTE), "P15" VARCHAR2(4 BYTE), "P16" VARCHAR2(4 BYTE), "P17" VARCHAR2(4 BYTE), "P18" VARCHAR2(4 BYTE), "P19" VARCHAR2(4 BYTE), "P20" VARCHAR2(4 BYTE), "P21" VARCHAR2(4 BYTE), "P22" VARCHAR2(4 BYTE), "P23" VARCHAR2(4 BYTE), "P24" VARCHAR2(4 BYTE), "P25" VARCHAR2(4 BYTE)) ;
--------------------------------------------------------
--  DDL for Table A_DANES
--------------------------------------------------------

  CREATE TABLE "A_DANES" ("KOD_KLIENTA" RAW(101), "NR_KOMP" NUMBER(10,0), "NR_KONTR" NUMBER(10,0), "AKCEPT" NUMBER(1,0), "ODD_WPIS" NUMBER(2,0), "DATA_WPIS" DATE, "OP_WPIS" NUMBER(10,0), "ODD_MOD" NUMBER(2,0), "DATA_MOD" DATE, "OP_MOD" NUMBER(10,0), "ODD_AKCEPT" NUMBER(2,0), "DATA_AKCEPT" DATE, "OP_AKCEPT" NUMBER(10,0), "KOD" VARCHAR2(10 BYTE), "AKT" NUMBER(1,0), "OPIS_DOD" VARCHAR2(20 BYTE), "RODZAJ" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table A_GLAS
--------------------------------------------------------

  CREATE TABLE "A_GLAS" ("TYP" NUMBER(1,0), "KOD_ZNAKU" NUMBER(3,0), "O_VINDUER" VARCHAR2(30 BYTE), "O_PILKINGTON" VARCHAR2(30 BYTE), "ZNAK" RAW(1)) ;
--------------------------------------------------------
--  DDL for Table AITROBPODSWG
--------------------------------------------------------

  CREATE TABLE "AITROBPODSWG" ("NR_MAGAZ" NUMBER(3,0), "NR_OKRESU" NUMBER(10,0), "NR_KOMP_STOJ" NUMBER(10,0), "NR_KOL_STOJAKA" NUMBER(8,0), "NR_KOMP_ZLEC" NUMBER(10,0), "INDEKS" VARCHAR2(128 BYTE), "ILE_SZT_REJESTR" NUMBER(10,0), "ILE_SZT_POTW" NUMBER(10,0), "ILE_SZT_W_PK" NUMBER(10,0), "ILE_POZ_REJESTR" NUMBER(8,0), "ILE_POZ_POTW" NUMBER(8,0), "ILE_POZ_PK" NUMBER(8,0), "ILE_M2_REJESTR" NUMBER(12,6), "ILE_M2_POTW" NUMBER(12,6), "ILE_M2_PK" NUMBER(12,6)) ;
--------------------------------------------------------
--  DDL for Table AITROBSTOJWG
--------------------------------------------------------

  CREATE TABLE "AITROBSTOJWG" ("NR_MAG" NUMBER(3,0), "NR_OKR" NUMBER(10,0), "NR_KOL_ST" NUMBER(10,0), "NR_KOMP_STOJ" NUMBER(10,0), "NR_STOJAKA" VARCHAR2(7 BYTE), "ILE_SZYB" NUMBER(6,0), "ILE_M2" NUMBER(6,0), "ILE_KG" NUMBER(7,2), "ILE_ZLEC" NUMBER(3,0), "NR_1_ZLEC" NUMBER(10,0), "DATA_REJESTR" DATE, "GODZ_REJESTR" CHAR(6 BYTE), "ILE_SZYB_POTW" NUMBER(10,0), "AKCEPTUJ_STOJAK" NUMBER(1,0), "DATA_POTW_INWENT" DATE, "CZAS_POTW_INWENT" CHAR(6 BYTE)) ;
--------------------------------------------------------
--  DDL for Table AITROBWGOT
--------------------------------------------------------

  CREATE TABLE "AITROBWGOT" ("NR_MAG" NUMBER(3,0), "NR_OKRESU" NUMBER(10,0), "NR_K_POZ_INW" NUMBER(10,0), "NR_K_ZAMOW" NUMBER(10,0), "NR_ZAMOW" NUMBER(8,0), "NR_KLIENTA" NUMBER(10,0), "POZ_ZAMOW" NUMBER(5,0), "SZT" NUMBER(6,0), "NR_K_STOJAKA" NUMBER(10,0), "NR_STOJAKA" VARCHAR2(7 BYTE), "POZ_STOJAKA" NUMBER(6,0), "STRONA_STOJ" NUMBER(2,0), "NR_K_SZYBY" NUMBER(10,0), "INDEKS" VARCHAR2(128 BYTE), "POW_JEDN" NUMBER(12,6), "WAGA_JEDN" NUMBER(12,6), "F_POZKART" NUMBER(1,0), "F_ODCZYT" NUMBER(1,0), "DATA_REJ" DATE, "GODZ_REJ" CHAR(6 BYTE), "DATA_ODCZ" DATE, "CZAS_ODCZ" CHAR(6 BYTE)) ;
--------------------------------------------------------
--  DDL for Table ALFAK_KONTRAHENT
--------------------------------------------------------

  CREATE TABLE "ALFAK_KONTRAHENT" ("NR_ALFAK" NUMBER(8,0), "NK_KON" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table ALFAK_STOJ
--------------------------------------------------------

  CREATE TABLE "ALFAK_STOJ" ("TYP" VARCHAR2(3 BYTE), "OPIS" VARCHAR2(16 BYTE), "SZEROKOSC" NUMBER(5,0), "NK_DEF" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table ANALITYKI
--------------------------------------------------------

  CREATE TABLE "ANALITYKI" ("NR_MAG" NUMBER(3,0), "NR_ANAL" NUMBER(3,0), "OPIS" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table APLIKACJE
--------------------------------------------------------

  CREATE TABLE "APLIKACJE" ("NR" NUMBER(4,0), "NAZ_APL" VARCHAR2(50 BYTE), "SCI" VARCHAR2(200 BYTE), "PAR" VARCHAR2(500 BYTE), "WSK" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table ARK_INW_POZ
--------------------------------------------------------

  CREATE TABLE "ARK_INW_POZ" ("NR_MAG" NUMBER(3,0), "OKRES" NUMBER(2,0), "INDEKS" VARCHAR2(128 BYTE), "NR_KOMP" NUMBER(10,0), "TYP_KAT" VARCHAR2(9 BYTE), "SZER" NUMBER(4,0), "WYS" NUMBER(4,0), "NK_WYM" NUMBER(10,0), "NK_STOJ" NUMBER(10,0), "POZ_STOJ" NUMBER(5,0), "FLAG" NUMBER(1,0), "OPER" VARCHAR2(10 BYTE), "D_MOD" DATE, "T_MOD" CHAR(6 BYTE)) ;
--------------------------------------------------------
--  DDL for Table ARK_KOSZT_ODDZ
--------------------------------------------------------

  CREATE TABLE "ARK_KOSZT_ODDZ" ("NR_TABELI" NUMBER(10,0), "NR_OKRESU" NUMBER(4,0), "DATA_POCZ" DATE, "DATA_KONC" DATE, "NR_GR_KOSZT_WYR" NUMBER(10,0), "KOSZT_ST" NUMBER(16,2), "KOSZT_ZM" NUMBER(16,2), "KOSZT_ADM_ODD" NUMBER(16,2), "KOSZT_ADM_CENTR" NUMBER(16,2), "KOSZTY_DODATK_1" NUMBER(16,2), "KOSZTY_DODATK_2" NUMBER(16,2)) ;
--------------------------------------------------------
--  DDL for Table A_SLOWO
--------------------------------------------------------

  CREATE TABLE "A_SLOWO" ("KOD" VARCHAR2(10 BYTE), "KOD_A" VARCHAR2(20 BYTE), "OPIS" VARCHAR2(50 BYTE)) ;
--------------------------------------------------------
--  DDL for Table A_STORKE
--------------------------------------------------------

  CREATE TABLE "A_STORKE" ("TYP" NUMBER(1,0), "KOD" RAW(2), "KOD4" VARCHAR2(10 BYTE), "KOD6" VARCHAR2(10 BYTE), "KOD8" VARCHAR2(10 BYTE), "PELNY" VARCHAR2(6 BYTE)) ;
--------------------------------------------------------
--  DDL for Table A_TRANP
--------------------------------------------------------

  CREATE TABLE "A_TRANP" ("NR_KOL" NUMBER(10,0), "NR_POZ" NUMBER(3,0), "SZYBA1" VARCHAR2(6 BYTE), "RAMKA1" NUMBER(4,0), "SZYBA2" VARCHAR2(6 BYTE), "RAMKA2" NUMBER(4,0), "SZYBA3" VARCHAR2(6 BYTE), "ARTYKUL" VARCHAR2(16 BYTE), "TYP_RAMKI" VARCHAR2(20 BYTE), "TYP_GAZU" VARCHAR2(20 BYTE), "SZER" NUMBER(4,0), "WYS" NUMBER(4,0), "ILOSC" NUMBER(4,0), "NR_KSZT" NUMBER(3,0), "OPIS" RAW(70), "INDEKS" VARCHAR2(128 BYTE), "UWAGI" VARCHAR2(100 BYTE), "NR_STRUK" NUMBER(10,0), "WSK" NUMBER(1,0), "L" NUMBER(4,0), "H" NUMBER(4,0), "W1" NUMBER(4,0), "W2" NUMBER(4,0), "H1" NUMBER(4,0), "H2" NUMBER(4,0), "R" NUMBER(4,0), "R1" NUMBER(4,0), "R2" NUMBER(4,0), "KOD_SZPROSU" VARCHAR2(50 BYTE), "TYP_SZPROSU" VARCHAR2(10 BYTE), "WSP1" NUMBER(4,0), "WSP2" NUMBER(4,0), "SZPROS_IND" VARCHAR2(50 BYTE), "SZPROS_MAG" NUMBER(3,0), "STR_KLIENTA" RAW(100), "ZN_WIEL" NUMBER(1,0), "CZY_KONTR" NUMBER(1,0), "POW" NUMBER(14,4), "GRUPA" NUMBER(2,0), "ZLEC_KLIENTA" VARCHAR2(20 BYTE), "SORT_DOD" VARCHAR2(50 BYTE)) ;
--------------------------------------------------------
--  DDL for Table A_TRANS
--------------------------------------------------------

  CREATE TABLE "A_TRANS" ("NAZ_SZPR" VARCHAR2(50 BYTE), "INDEKS" VARCHAR2(128 BYTE), "NR_MAG" NUMBER(3,0)) ;
--------------------------------------------------------
--  DDL for Table A_TRANZ
--------------------------------------------------------

  CREATE TABLE "A_TRANZ" ("NR_KOL" NUMBER(10,0), "DATA_WCZYT" DATE, "CZAS_WCZYT" CHAR(6 BYTE), "NAZ_KONTR" VARCHAR2(50 BYTE), "ULICA" VARCHAR2(30 BYTE), "MIASTO" VARCHAR2(30 BYTE), "KRAJ" VARCHAR2(30 BYTE), "DATA_ZLEC" DATE, "DATA_DOST" DATE, "NR_ZLEC_KLIENTA" VARCHAR2(18 BYTE), "ADRES_DOST" VARCHAR2(31 BYTE), "ILOSC" NUMBER(4,0), "NR_KONTR" NUMBER(10,0), "I_WCZYT" NUMBER(4,0), "I_AKCEPT" NUMBER(4,0), "NR_ADR_DOST" NUMBER(10,0), "WSK_SZPROS" NUMBER(1,0), "NAZ_ZBIORU" VARCHAR2(20 BYTE), "NR_OP" VARCHAR2(10 BYTE), "NR_KONTRAKT" NUMBER(10,0), "ILOSC_Z_KONTR" NUMBER(4,0), "IL_DOL" NUMBER(6,0), "IL_GOR" NUMBER(6,0), "PODZ" NUMBER(1,0), "WSK" NUMBER(1,0), "SZPR_DO" NUMBER(7,0), "IL_SZYB" NUMBER(7,0), "POW" NUMBER(14,4), "TYP_ZLEC" NUMBER(2,0), "CZY_KSZT" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table ATRYB_DOD
--------------------------------------------------------

  CREATE TABLE "ATRYB_DOD" ("NR_ZNACZNIKA" NUMBER(3,0) DEFAULT 0, "OPIS" VARCHAR2(20 BYTE) DEFAULT ' ', "DO_WYDRUKU" VARCHAR2(20 BYTE) DEFAULT ' ', "TYP" NUMBER(1,0) DEFAULT 0, "PRZEPIS" VARCHAR2(100 BYTE) DEFAULT ' ', "OPIS_POZ" NUMBER(1,0) DEFAULT 0, "KAT" NUMBER(1,0) DEFAULT 0, "STR" NUMBER(1,0) DEFAULT 0, "ZLEC" NUMBER(1,0) DEFAULT 0, "INST" NUMBER(1,0) DEFAULT 0, "ZNACZ_PROD" VARCHAR2(4 BYTE) DEFAULT ' ', "F_POTW" NUMBER(2,0) DEFAULT 0, "F_WTECH" NUMBER(2,0) DEFAULT 0, "F_HARM" NUMBER(2,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table AUDYT
--------------------------------------------------------

  CREATE TABLE "AUDYT" ("NUM_KOL" NUMBER(10,0), "DATA" DATE, "CZAS" CHAR(6 BYTE), "N_TABELI" VARCHAR2(33 BYTE), "N_POLA" VARCHAR2(33 BYTE), "W_PRZED" VARCHAR2(100 BYTE), "W_PO" VARCHAR2(100 BYTE), "ID_UZYT" VARCHAR2(33 BYTE), "UZYTK" VARCHAR2(33 BYTE), "T_ZMIANY" VARCHAR2(12 BYTE)) ;
--------------------------------------------------------
--  DDL for Table BANKI
--------------------------------------------------------

  CREATE TABLE "BANKI" ("NR_BANKU" NUMBER(8,0), "NAZ_BANKU" VARCHAR2(30 BYTE), "KOD_POCZ" VARCHAR2(10 BYTE), "MIASTO" VARCHAR2(30 BYTE), "ADRES" VARCHAR2(31 BYTE), "PANSTWO" VARCHAR2(20 BYTE), "SWIFT" VARCHAR2(20 BYTE), "WOJEW" VARCHAR2(20 BYTE), "TEL" VARCHAR2(19 BYTE), "FAX" VARCHAR2(19 BYTE), "INFO1" VARCHAR2(60 BYTE) DEFAULT '', "INFO2" VARCHAR2(60 BYTE) DEFAULT '', "INFO3" VARCHAR2(60 BYTE) DEFAULT '') ;
--------------------------------------------------------
--  DDL for Table BAZA_CEN
--------------------------------------------------------

  CREATE TABLE "BAZA_CEN" ("INDEKS" VARCHAR2(50 BYTE), "NAZWA" VARCHAR2(100 BYTE), "ZNACZ_KART" VARCHAR2(3 BYTE), "INDEKS_DOST" VARCHAR2(50 BYTE), "NAZWA_DOST" VARCHAR2(100 BYTE), "NR_DOST" NUMBER(10,0), "NAZ_DOST" VARCHAR2(50 BYTE), "NAZ_SKR_DOST" VARCHAR2(15 BYTE), "JEDN" VARCHAR2(5 BYTE), "D_WPROW" DATE, "CENA_PLN" NUMBER(10,2), "CENA_WALUT" NUMBER(10,2), "WALUTA" VARCHAR2(4 BYTE), "NR_ODDZ" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table BILANSPK
--------------------------------------------------------

  CREATE TABLE "BILANSPK" ("NR_ODDZ" NUMBER(2,0), "NR_MAG" NUMBER(3,0), "INDEKS" VARCHAR2(128 BYTE), "CENA_ZAKUPU" NUMBER(14,4), "DATA_WPROW" DATE, "ILOSC" NUMBER(18,6), "ZN_KARTOTEKI" VARCHAR2(3 BYTE), "NR" NUMBER(10,0), "NR_POZ_DOK" NUMBER(5,0), "STATUS" NUMBER(1,0), "NR_KOMP_ZLEC" NUMBER(10,0), "NR_POZ_ZLEC" NUMBER(3,0), "DODATEK" VARCHAR2(1 BYTE), "DATA_ZAPASU" DATE, "SERIA" NUMBER(4,0) DEFAULT 0, "CENA_SPRZED" NUMBER(14,4) DEFAULT 0, "NR_DOK_ZROD" NUMBER(10,0) DEFAULT 0, "NR_DOST" VARCHAR2(20 BYTE) DEFAULT '', "NR_POZ_ZROD" NUMBER(5,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table BILTPOZ
--------------------------------------------------------

  CREATE TABLE "BILTPOZ" ("TYP_DOK" VARCHAR2(3 BYTE), "DATA_D" DATE, "NR_DOK" NUMBER(8,0), "NR_POZ" NUMBER(5,0), "INDEKS" VARCHAR2(128 BYTE), "ILOSC_JR" NUMBER(10,0), "ILOSC_JP" NUMBER(18,6), "STAN1" NUMBER(18,6), "STAN2" NUMBER(18,6), "CENA_PRZYJ" NUMBER(14,4), "CEN_WYD" NUMBER(14,4), "STORNO" NUMBER(1,0), "NR_POZ_ZLEC" NUMBER(3,0), "CZY_DOD" VARCHAR2(1 BYTE), "ROK" NUMBER(4,0), "MIES" NUMBER(2,0), "NR_ODDZ" NUMBER(2,0), "NR_MAG" NUMBER(3,0), "NR_KOMP_DOK" NUMBER(10,0), "NR_KOMP_BAZ" NUMBER(10,0), "ZNACZNIK_KARTOTEKI" VARCHAR2(3 BYTE), "STATUS_DOKUMENTU" NUMBER(1,0), "KOLEJNOSC_DODATKU" NUMBER(3,0), "SERIA" NUMBER(10,0) DEFAULT 0, "CENA_SPRZED" NUMBER(14,4) DEFAULT 0, "NR_DOK_ZROD" NUMBER(10,0) DEFAULT 0, "NR_DOST" VARCHAR2(20 BYTE) DEFAULT '', "NR_POZ_ZROD" NUMBER(5,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table BLOKADY
--------------------------------------------------------

  CREATE TABLE "BLOKADY" ("TYP" NUMBER(4,0), "CO_BLOK" NUMBER(10,0), "KTO_BLOK" NUMBER(10,0), "DATA_BLOK" DATE, "CZAS_BLOK" CHAR(6 BYTE), "TIME_OUT" NUMBER(6,0)) ;
--------------------------------------------------------
--  DDL for Table BRAKI_A
--------------------------------------------------------

  CREATE TABLE "BRAKI_A" ("NR_ZAP" NUMBER(10,0), "NR_ZLEC" NUMBER(10,0), "NR_POZ" NUMBER(3,0), "NR_OPT" NUMBER(10,0), "NR_TAF" NUMBER(3,0), "NR_STOJ" VARCHAR2(7 BYTE), "SZER" NUMBER(4,0), "WYS" NUMBER(4,0), "ZN_ZESP" VARCHAR2(18 BYTE), "D_REJESTR" DATE, "C_REJESTR" CHAR(6 BYTE), "NAZ_ZB" VARCHAR2(20 BYTE), "ZLEC_BRAK" NUMBER(6,0), "WSK_ZLEC" NUMBER(1,0), "WSK" NUMBER(1,0), "NR_WYC" NUMBER(6,0)) ;
--------------------------------------------------------
--  DDL for Table BRAKI_B
--------------------------------------------------------

  CREATE TABLE "BRAKI_B" ("NR_KOM_SZYBY" NUMBER(10,0), "NR_ZLEC" NUMBER(10,0), "NR_POZ" NUMBER(3,0), "NR_SZT" NUMBER(4,0), "KOD_STR" VARCHAR2(50 BYTE), "ZLEC_BRAKI" NUMBER(10,0), "WSK_ZLEC" NUMBER(1,0), "D_REJESTR" DATE, "C_REJESTR" CHAR(6 BYTE), "WSK" NUMBER(1,0), "TYP_POZ" NUMBER(1,0), "NR_WAR" NUMBER(2,0), "KOD_P" VARCHAR2(3 BYTE), "NR_KOM_PRZ" NUMBER(10,0) DEFAULT 0, "NR_KOM_INST" NUMBER(10,0) DEFAULT 0, "OPER" VARCHAR2(10 BYTE) DEFAULT '', "DATA" DATE DEFAULT '1901/01/01', "ZM" NUMBER(1,0) DEFAULT 0, "SP_REAL" NUMBER(10,0) DEFAULT 0, "FLAG" NUMBER(1,0) DEFAULT 0, "ID_POZ_BR" NUMBER(10,0) DEFAULT 0, "NR_SER_BR" NUMBER(10,0) DEFAULT 0, "INST_POW" NUMBER(10,0) DEFAULT 0, "LAMINAT" NUMBER(1,0) DEFAULT 0, "NR_KOL" NUMBER(10,0) DEFAULT 1) ;
--------------------------------------------------------
--  DDL for Table BRAK_STR
--------------------------------------------------------

  CREATE TABLE "BRAK_STR" ("KOD_STR" VARCHAR2(128 BYTE), "DATA" DATE, "CZAS" CHAR(6 BYTE), "WSK" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table BRYG_POZ
--------------------------------------------------------

  CREATE TABLE "BRYG_POZ" ("NR_KOMP_B" NUMBER(10,0), "NR_PRAC" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table BUDSTR
--------------------------------------------------------

  CREATE TABLE "BUDSTR" ("NR_KOM_STR" NUMBER(10,0), "KOD_STR" VARCHAR2(128 BYTE), "NR_SKL" NUMBER(2,0), "NR_KOM_SKL" NUMBER(10,0), "ZN_WAR" CHAR(3 BYTE), "TYP_STR" CHAR(2 BYTE), "SPOS_OBL" CHAR(3 BYTE), "WSP" NUMBER(14,5), "NR_KOMP_RYS" NUMBER(10,0) DEFAULT 0, "OBROT" NUMBER(1,0) DEFAULT -1) ;
--------------------------------------------------------
--  DDL for Table BUDZET
--------------------------------------------------------

  CREATE TABLE "BUDZET" ("ROK_OBRACH" NUMBER(4,0), "MIES_OBR" NUMBER(2,0), "GR_TOW" VARCHAR2(3 BYTE), "IL_PLAN" NUMBER(18,6), "WART_PLAN" NUMBER(16,2), "IL_ZAK" NUMBER(18,6), "WART_ZAK" NUMBER(16,2), "JEDN" VARCHAR2(5 BYTE), "NR_ODDZ" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table BUF_ITYP
--------------------------------------------------------

  CREATE TABLE "BUF_ITYP" ("NR_KOMP_ZLEC" NUMBER(10,0), "NR_POZ" NUMBER(3,0), "TYP" NUMBER(3,0), "LINIA" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table BUF_SPED
--------------------------------------------------------

  CREATE TABLE "BUF_SPED" ("NK_ZAP" NUMBER(10,0), "TYP_DAN" NUMBER(2,0), "NK_STOJ" NUMBER(10,0), "FLAGA" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table CCEN00
--------------------------------------------------------

  CREATE TABLE "CCEN00" ("NK_CENNIKA" NUMBER(10,0), "DATA_OD" DATE, "DATA_DO" DATE, "OPIS_CEN" VARCHAR2(100 BYTE), "DATA_MOD" DATE, "CZAS_MOD" CHAR(6 BYTE), "OPERATOR" NUMBER(10,0), "ODDZIAL" NUMBER(2,0), "DOP_TROJKAT" NUMBER(5,2), "DOP_LINIOWY" NUMBER(5,2), "DOP_ZDEF" NUMBER(5,2), "DOP_SZABLON" NUMBER(5,2), "DOP_WAGA" NUMBER(5,2), "WAGA_GR" NUMBER(7,0), "DOP_ZA_WYMIAR" NUMBER(5,2), "BOK_KR" NUMBER(4,0), "BOK_DL" NUMBER(4,0), "NR_CEN" NUMBER(10,0), "NK_KONTR" NUMBER(10,0), "DOP_ZA_WYM_POW" NUMBER(6,4), "POW_MIN" NUMBER(6,4)) ;
--------------------------------------------------------
--  DDL for Table C_DOST_UWAGI
--------------------------------------------------------

  CREATE TABLE "C_DOST_UWAGI" ("NR_KONTR" NUMBER(10,0), "UWAGI" VARCHAR2(300 BYTE)) ;
--------------------------------------------------------
--  DDL for Table CECHY_LISTA
--------------------------------------------------------

  CREATE TABLE "CECHY_LISTA" ("NUMER_CECHY" NUMBER(10,0), "OPIS_CECHY" VARCHAR2(200 BYTE)) ;
--------------------------------------------------------
--  DDL for Table CECHY_MONIT
--------------------------------------------------------

  CREATE TABLE "CECHY_MONIT" ("NK_KONTR" NUMBER(10,0), "NR_CECHY" NUMBER(10,0), "NAZ_PAR" VARCHAR2(30 BYTE), "OPERATOR" NUMBER(10,0), "ODDZIAL" NUMBER(2,0), "DATA" DATE, "CZAS" CHAR(6 BYTE), "WSK" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table CECHY_PAR2
--------------------------------------------------------

  CREATE TABLE "CECHY_PAR2" ("NKOMP_CECHY" NUMBER(10,0), "NR_PAR" NUMBER(3,0), "NAZ_PAR" VARCHAR2(30 BYTE), "KLUCZ_UPR" VARCHAR2(31 BYTE), "CZY_MONIT" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table CECHY_USER
--------------------------------------------------------

  CREATE TABLE "CECHY_USER" ("NR_CECHY" NUMBER(4,0), "NR_KONTRAH" NUMBER(10,0), "PARAM" VARCHAR2(1000 BYTE)) ;
--------------------------------------------------------
--  DDL for Table CEN00
--------------------------------------------------------

  CREATE TABLE "CEN00" ("NK_CENNIKA" NUMBER(10,0), "DATA_OD" DATE, "DATA_DO" DATE, "OPIS_CEN" VARCHAR2(100 BYTE), "DATA_MOD" DATE, "CZAS_MOD" CHAR(6 BYTE), "OPERATOR" NUMBER(10,0), "ODDZIAL" NUMBER(2,0), "DOP_TROJKAT" NUMBER(5,2), "DOP_LINIOWY" NUMBER(5,2), "DOP_ZDEF" NUMBER(5,2), "DOP_SZABLON" NUMBER(5,2), "DOP_WAGA" NUMBER(5,2), "WAGA_GR" NUMBER(7,0), "DOPL_WYMIAR" NUMBER(5,2), "BOK_KR" NUMBER(4,0), "BOK_DL" NUMBER(4,0), "NR_CEN" NUMBER(10,0), "NR_KONTR" NUMBER(10,0), "DOP_ZA_WYM_POW" NUMBER(6,4) DEFAULT 0, "POW_MIN" NUMBER(6,4) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table CEN00_FGT
--------------------------------------------------------

  CREATE TABLE "CEN00_FGT" ("NKOMP_CEN" NUMBER(10,0), "DATA_OD" DATE, "DATA_DO" DATE, "OPIS_CEN" VARCHAR2(100 BYTE), "DATA_MOD" DATE, "CZAS_MOD" CHAR(6 BYTE), "OPERATOR" NUMBER(10,0), "ODDZ" NUMBER(2,0), "NR_CEN" NUMBER(10,0), "NKOMP_KONTR" NUMBER(10,0), "POW_MIN" NUMBER(7,4) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table CEN00_T7
--------------------------------------------------------

  CREATE TABLE "CEN00_T7" ("NKOMP_CEN" NUMBER(10,0), "DATA_OD" DATE, "DATA_DO" DATE, "OPIS_CEN" VARCHAR2(100 BYTE), "DATA_MOD" DATE, "CZAS_MOD" CHAR(6 BYTE), "OPERATOR" NUMBER(10,0), "ODDZ" NUMBER(2,0), "NR_CEN" NUMBER(10,0), "NKOMP_KONTR" NUMBER(10,0), "POW_MIN" NUMBER(7,4)) ;
--------------------------------------------------------
--  DDL for Table CEN01
--------------------------------------------------------

  CREATE TABLE "CEN01" ("NK_CENNIKA" NUMBER(10,0), "NKAT_SZYBA1" NUMBER(10,0), "NKAT_RAMKA" NUMBER(10,0), "NKAT_GAZ" NUMBER(10,0), "NKAT_SZYBA2" NUMBER(10,0), "CENA" NUMBER(14,4), "WZORZEC" VARCHAR2(50 BYTE), "NK_WZORCA" NUMBER(10,0), "DATA_MOD" DATE, "CZAS_MOD" CHAR(6 BYTE) DEFAULT '', "OPERATOR" NUMBER(10,0) DEFAULT 0, "ODD" NUMBER(2,0) DEFAULT 0, "NKAT_RAMKA2" NUMBER(10,0) DEFAULT 0, "NKAT_GAZ2" NUMBER(10,0) DEFAULT 0, "NKAT_SZYBA3" NUMBER(10,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table CEN01_FGT
--------------------------------------------------------

  CREATE TABLE "CEN01_FGT" ("NKOMP_CEN" NUMBER(10,0), "NR_KAT" NUMBER(4,0), "NAZ_KAT" VARCHAR2(50 BYTE), "JEDN" VARCHAR2(5 BYTE), "CENA" NUMBER(14,4), "NORMA_STRAT" NUMBER(5,2), "DATA_MOD" DATE, "CZAS_MOD" CHAR(6 BYTE), "OPERATOR" NUMBER(10,0), "ODDZ" NUMBER(2,0), "MARZA" NUMBER(7,3), "CEN_ZAK" NUMBER(14,4), "WSK_ZERA" NUMBER(1,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table CEN02
--------------------------------------------------------

  CREATE TABLE "CEN02" ("NK_CENNIKA" NUMBER(10,0), "TYP" NUMBER(2,0), "NR_KAT" NUMBER(10,0), "DOPLATA" NUMBER(14,4), "NR_SZYBY" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table CEN02_FGT
--------------------------------------------------------

  CREATE TABLE "CEN02_FGT" ("NKOMP_CEN" NUMBER(10,0), "NKOMP_OBR" NUMBER(10,0), "NAZ_OBR" VARCHAR2(50 BYTE), "GRUB" NUMBER(6,3), "CENA" NUMBER(14,4), "DATA_MOD" DATE, "CZAS_MOD" CHAR(6 BYTE), "OPERATOR" NUMBER(10,0), "ODDZ" NUMBER(2,0), "MARZA" NUMBER(8,3) DEFAULT 0, "CENA_ZAK" NUMBER(14,4) DEFAULT 0, "WSK_ZERA" NUMBER(1,0) DEFAULT 0, "STRATY_S" NUMBER(5,2) DEFAULT 0, "RODZAJ" NUMBER(2,0) DEFAULT 0, "OD" NUMBER(5,4) DEFAULT 0, "DO" NUMBER(5,4)) ;
--------------------------------------------------------
--  DDL for Table CEN02_T7
--------------------------------------------------------

  CREATE TABLE "CEN02_T7" ("NKOMP_CEN" NUMBER(10,0), "NKOMP_OBR" NUMBER(10,0), "NAZ_OBR" VARCHAR2(50 BYTE), "GRUB" NUMBER(6,3), "CENA" NUMBER(10,2), "DATA_MOD" DATE, "CZAS_MOD" CHAR(6 BYTE), "OPERATOR" NUMBER(10,0), "ODDZ" NUMBER(2,0), "MARZA" NUMBER(7,3), "CENA_ZAK" NUMBER(10,2), "WSK_ZERA" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table CEN03
--------------------------------------------------------

  CREATE TABLE "CEN03" ("NK_CENNIKA" NUMBER(10,0), "INDEKS_SZP" VARCHAR2(50 BYTE), "NAZWA_SZP" VARCHAR2(100 BYTE), "SZER_SZP" NUMBER(3,0), "CENA_POD" NUMBER(14,4)) ;
--------------------------------------------------------
--  DDL for Table CEN03_FGT
--------------------------------------------------------

  CREATE TABLE "CEN03_FGT" ("NKOMP_CEN" NUMBER(10,0), "TYP_DOPL" NUMBER(3,0), "NR_KOL" NUMBER(1,0), "OD" NUMBER(9,4), "DO" NUMBER(9,4), "DOPLATA" NUMBER(5,2), "OPIS" VARCHAR2(50 BYTE), "DATA_MOD" DATE, "CZAS_MOD" CHAR(6 BYTE), "OPERATOR" NUMBER(10,0), "ODDZ" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table CEN03_T7
--------------------------------------------------------

  CREATE TABLE "CEN03_T7" ("NKOMP_CEN" NUMBER(10,0), "TYP_DOPL" NUMBER(3,0), "NR_KOL" NUMBER(1,0), "OD" NUMBER(9,4), "DO" NUMBER(9,4), "DOPLATA" NUMBER(5,2), "OPIS" VARCHAR2(50 BYTE), "DATA_MOD" DATE, "CZAS_MOD" CHAR(6 BYTE), "OPERATOR" NUMBER(10,0), "ODDZ" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table CEN04
--------------------------------------------------------

  CREATE TABLE "CEN04" ("NK_CENNIKA" NUMBER(10,0), "TYP" NUMBER(2,0), "NKOMP" NUMBER(10,0), "KOD" VARCHAR2(50 BYTE), "NK_WZORCA" NUMBER(10,0), "CANA_BAZ" NUMBER(14,4), "DOPLATA_1" NUMBER(14,4), "DOPLATA_2" NUMBER(14,4)) ;
--------------------------------------------------------
--  DDL for Table CEN04_FGT
--------------------------------------------------------

  CREATE TABLE "CEN04_FGT" ("NKOMP_CEN" NUMBER(10,0), "TYP" NUMBER(2,0), "NKOMP" NUMBER(10,0), "KOD" VARCHAR2(128 BYTE), "CANA_BAZ" NUMBER(14,4), "GRUB_TAFLI" NUMBER(3,0)) ;
--------------------------------------------------------
--  DDL for Table CEN04_T7
--------------------------------------------------------

  CREATE TABLE "CEN04_T7" ("NKOMP_CEN" NUMBER(10,0), "TYP" NUMBER(2,0), "NKOMP" NUMBER(10,0), "KOD" VARCHAR2(128 BYTE), "CANA_BAZ" NUMBER(10,2), "GRUB_TAFLI" NUMBER(3,0)) ;
--------------------------------------------------------
--  DDL for Table CEN05
--------------------------------------------------------

  CREATE TABLE "CEN05" ("NKOMP_CEN" NUMBER(10,0), "NKOMP_OBR" NUMBER(10,0), "NAZ_OBR" VARCHAR2(50 BYTE), "GRUB" NUMBER(6,3), "CENA" NUMBER(14,4), "DATA_MOD" DATE, "CZAS_MOD" CHAR(6 BYTE), "OPERATOR" NUMBER(10,0), "ODDZ" NUMBER(2,0), "MARZA" NUMBER(7,3), "CENA_ZAK" NUMBER(14,4), "WSK_ZERA" NUMBER(1,0), "STRATY" NUMBER(5,2) DEFAULT 0, "RODZAJ" NUMBER(2,0) DEFAULT 0, "OD" NUMBER(8,4) DEFAULT 0, "DO" NUMBER(8,4) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table CEN06
--------------------------------------------------------

  CREATE TABLE "CEN06" ("NKOMP_CEN" NUMBER(10,0), "TYP_DOPLATY" NUMBER(3,0), "NR_KOLEJNY" NUMBER(1,0), "OD" NUMBER(9,4), "DO" NUMBER(9,4), "DOPLATA" NUMBER(5,2), "OPIS" VARCHAR2(50 BYTE), "DATA_MOD" DATE, "CZAS_MOD" CHAR(6 BYTE), "OPERATOR" NUMBER(10,0), "ODDZ" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table CEN06_T7
--------------------------------------------------------

  CREATE TABLE "CEN06_T7" ("NK_CEN" NUMBER(10,0), "INDEKS" VARCHAR2(128 BYTE), "NAZWA" VARCHAR2(255 BYTE), "CENA" NUMBER(10,2), "RODZ_CENY" VARCHAR2(4 BYTE), "DATA_MOD" DATE, "CZAS_MOD" CHAR(6 BYTE), "OPER_MOD" NUMBER(10,0), "ODD_MOD" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table CEN_LIM_KRED
--------------------------------------------------------

  CREATE TABLE "CEN_LIM_KRED" ("NR_KOMP" NUMBER(10,0), "NAZWA" VARCHAR2(31 BYTE), "LIMIT" NUMBER(10,0), "DO_LIM" NUMBER(2,0), "POW_LIM" NUMBER(2,0), "ZAD_LIM" NUMBER(1,0), "CAL_LIM" NUMBER(1,0), "ZADLUZ" NUMBER(2,0), "OPIS" VARCHAR2(50 BYTE), "IL_KLUCZY" NUMBER(1,0), "NR_KOL" NUMBER(10,0), "POZIOM" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table CEN_STR
--------------------------------------------------------

  CREATE TABLE "CEN_STR" ("NR_CEN" NUMBER(10,0), "KOD_STR" VARCHAR2(50 BYTE), "NR_PROF" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table CENT_KLIENT
--------------------------------------------------------

  CREATE TABLE "CENT_KLIENT" ("NR_KON" NUMBER(10,0), "GR_DOK" CHAR(3 BYTE), "RODZ_KON" CHAR(3 BYTE), "NAZ_KON" VARCHAR2(50 BYTE), "SKROT_K" VARCHAR2(15 BYTE), "KOD_POCZ" VARCHAR2(5 BYTE), "MIASTO" VARCHAR2(30 BYTE), "ADRES" VARCHAR2(31 BYTE), "PANSTWO" VARCHAR2(20 BYTE), "POWIAT" VARCHAR2(20 BYTE), "WOJEW" VARCHAR2(20 BYTE), "TEL" VARCHAR2(19 BYTE), "FAX" VARCHAR2(19 BYTE), "MAIL" VARCHAR2(128 BYTE), "REGON" VARCHAR2(20 BYTE), "NIP" VARCHAR2(20 BYTE), "NR_RACH" VARCHAR2(40 BYTE), "NR_BANKU" NUMBER(8,0), "LIMIT_K" NUMBER(16,2), "IL_D_KRED" NUMBER(3,0), "DLUG" NUMBER(16,2), "TERMIN_P" NUMBER(3,0), "ODB_FAKT" CHAR(2 BYTE), "NR_OS_VAT" VARCHAR2(15 BYTE), "RODZ_OS" CHAR(2 BYTE), "D_OSW" DATE, "D_WAZ_VAT" DATE, "POZ_CEN" CHAR(3 BYTE), "WAR_KOR" NUMBER(3,0), "WYS_KOR" NUMBER(5,2), "GOT_KRED" CHAR(2 BYTE), "WAR_PLAT" CHAR(2 BYTE), "NR_PLAT" NUMBER(10,0), "PLAT_VAT" CHAR(1 BYTE), "RABAT" NUMBER(5,2), "NR_ODDZ" NUMBER(2,0), "TYP_IFS" VARCHAR2(10 BYTE), "STATUS" NUMBER(1,0), "STAT_ZAK" NUMBER(1,0), "STOPA_CL" NUMBER(8,2), "NIP_UE" VARCHAR2(15 BYTE), "CZY_UE" NUMBER(2,0), "NIP_MASKA" VARCHAR2(15 BYTE), "STATUS_PLAN" NUMBER(2,0), "TEL_KOM1" VARCHAR2(19 BYTE), "OS_KONTAK1" VARCHAR2(128 BYTE), "TEL_KOM2" VARCHAR2(19 BYTE), "OS_KONTAK2" VARCHAR2(128 BYTE), "UWAGI" VARCHAR2(255 BYTE), "NAZ_RAM" VARCHAR2(40 BYTE)) ;
--------------------------------------------------------
--  DDL for Table CENT_POPER
--------------------------------------------------------

  CREATE TABLE "CENT_POPER" ("NR_OPER" NUMBER(10,0), "NR_ODDZ" NUMBER(2,0), "NAZWISKO" VARCHAR2(50 BYTE), "KOD" NUMBER(10,0), "ID" VARCHAR2(10 BYTE), "NAZWA" VARCHAR2(30 BYTE)) ;
--------------------------------------------------------
--  DDL for Table CP_CEN
--------------------------------------------------------

  CREATE TABLE "CP_CEN" ("NK_PRZEC" NUMBER(10,0), "NK_CEN" NUMBER(10,0), "WSKK" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table CP_DOP
--------------------------------------------------------

  CREATE TABLE "CP_DOP" ("NK_PRZEC" NUMBER(10,0), "TYP" NUMBER(1,0), "NR_KAT" NUMBER(4,0), "PRZEC" VARCHAR2(1 BYTE), "WART" NUMBER(7,2), "WSK" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table CP_KONT
--------------------------------------------------------

  CREATE TABLE "CP_KONT" ("NK_PRZEC" NUMBER(10,0), "NK_KONTR" NUMBER(10,0), "WSK" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table CP_NARZ
--------------------------------------------------------

  CREATE TABLE "CP_NARZ" ("NK_PRZEC" NUMBER(10,0), "NK_NARZ" NUMBER(3,0), "TYP" NUMBER(1,0), "PRZEC" VARCHAR2(1 BYTE), "WART" NUMBER(7,2), "WSK" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table CP_PRZEC
--------------------------------------------------------

  CREATE TABLE "CP_PRZEC" ("NK_PRZEC" NUMBER(10,0), "OPIS_PRZEC" VARCHAR2(100 BYTE), "DATA_MOD" DATE, "CZAS_MOD" CHAR(6 BYTE), "OPER_MOD" NUMBER(10,0), "ODD_MOD" NUMBER(2,0), "CEN_WSK" NUMBER(1,0), "CEN_OD" NUMBER(10,0), "CEN_DO" NUMBER(10,0), "KONTR_WSK" NUMBER(1,0), "KONTR_D" NUMBER(10,0), "KONTR_DO" NUMBER(10,0), "DATY_WSK" NUMBER(1,0), "DATY_OD" DATE, "DATY_DO" DATE, "ST_WYDR" NUMBER(1,0), "DOKL" NUMBER(1,0), "DOP_PRZEC" NUMBER(1,0), "DOP_ZAKRES" NUMBER(1,0), "DOP_WART" NUMBER(7,2), "FOR_PRZEC" NUMBER(1,0), "FOR_ZAKRES" NUMBER(1,0), "FOR_WART" NUMBER(7,2), "SZP_PRZEC" NUMBER(1,0), "SZP_ZAKRES" NUMBER(1,0), "SZP_WART" NUMBER(7,2), "OBR_PRZEC" NUMBER(1,0), "OBR_ZAKRES" NUMBER(1,0), "OBR_WART" NUMBER(7,2), "WZR_PRZEC" NUMBER(1,0), "WZR_ZAKRES" NUMBER(1,0), "WZR_WART" NUMBER(7,2), "WSK_KOP" NUMBER(1,0), "NARZ_PRZEC" NUMBER(1,0), "NARZ_ZAKRES" NUMBER(1,0), "NARZ_WART" NUMBER(7,2)) ;
--------------------------------------------------------
--  DDL for Table CP_ROB
--------------------------------------------------------

  CREATE TABLE "CP_ROB" ("NK_PRZEC" NUMBER(10,0), "NK_CEN" NUMBER(10,0), "WSKK" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table CP_SZP
--------------------------------------------------------

  CREATE TABLE "CP_SZP" ("NK_PRZEC" NUMBER(10,0), "INDEKS_SZPR" VARCHAR2(128 BYTE), "SZER" NUMBER(3,0), "PRZEC" VARCHAR2(1 BYTE), "WART" NUMBER(7,2), "WSK" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table CP_WZR
--------------------------------------------------------

  CREATE TABLE "CP_WZR" ("NK_PRZEC" NUMBER(10,0), "NKAT_SZYBA1" NUMBER(10,0), "NKAT_RAMKA" NUMBER(10,0), "NKAT_GAZ" NUMBER(10,0), "NKAT_SZYBA2" NUMBER(10,0), "PRZEC" VARCHAR2(1 BYTE), "WART" NUMBER(7,2), "WSK" NUMBER(1,0), "TYP_SZYBA1" VARCHAR2(9 BYTE), "TYP_RAMKA" VARCHAR2(9 BYTE), "TYP_GAZ" VARCHAR2(9 BYTE), "TYP_SZYBA2" VARCHAR2(9 BYTE)) ;
--------------------------------------------------------
--  DDL for Table CRM_ADRES
--------------------------------------------------------

  CREATE TABLE "CRM_ADRES" ("NKOMP_KONTR" NUMBER(10,0), "NR_KOLEJNY" NUMBER(3,0), "RODZAJ" NUMBER(3,0), "TRESC" VARCHAR2(50 BYTE), "OPIS" VARCHAR2(50 BYTE)) ;
--------------------------------------------------------
--  DDL for Table CRM_BLOB
--------------------------------------------------------

  CREATE TABLE "CRM_BLOB" ("NKOMP_WIAD" NUMBER(10,0), "TRESC" LONG RAW, "NR_ODD" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table CRM_LISTA
--------------------------------------------------------

  CREATE TABLE "CRM_LISTA" ("TYP" NUMBER(3,0), "RODZAJ" NUMBER(3,0), "NAZWA" VARCHAR2(20 BYTE)) ;
--------------------------------------------------------
--  DDL for Table CRM_OSOBA
--------------------------------------------------------

  CREATE TABLE "CRM_OSOBA" ("NKOMP_KONTR" NUMBER(10,0), "NR_KOLEJNY" NUMBER(3,0), "OSOBA" VARCHAR2(50 BYTE), "OPIS" VARCHAR2(50 BYTE)) ;
--------------------------------------------------------
--  DDL for Table CRM_PAR
--------------------------------------------------------

  CREATE TABLE "CRM_PAR" ("NKOMP_KONTR" NUMBER(10,0), "NKOMP_WIAD" NUMBER(10,0), "TYP_ZAPISU" NUMBER(3,0), "TRESC" VARCHAR2(100 BYTE), "NR_ODD" NUMBER(2,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table CRM_STOJ
--------------------------------------------------------

  CREATE TABLE "CRM_STOJ" ("NKOMP_KONTR" NUMBER(10,0), "NKOMP_WIAD" NUMBER(10,0), "NUMER_ZAPISU" NUMBER(2,0), "NKOMP_STOJAKA" NUMBER(10,0), "NUMER_STOJAKA" VARCHAR2(7 BYTE), "DATA_OD" DATE, "DATA_DO" DATE, "ILOSC_DNI" NUMBER(5,0), "WARTOSC" NUMBER(14,2), "WSKAZNIK" NUMBER(1,0), "NR_ODD" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table CRM_WIA
--------------------------------------------------------

  CREATE TABLE "CRM_WIA" ("NKOMP_KONTR" NUMBER(10,0), "DATA" DATE, "CZAS" CHAR(6 BYTE), "OSOBA" VARCHAR2(50 BYTE), "ADRES" VARCHAR2(50 BYTE), "SKROT" VARCHAR2(100 BYTE), "RODZAJ_WIAD" NUMBER(3,0), "NKOMP_WIAD" NUMBER(10,0), "NKOMP_OPER" NUMBER(10,0), "TYP_DANYCH" NUMBER(2,0), "IDENT_RODZAJU" NUMBER(10,0), "NR_ODD" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table CRM_ZDARZENIE
--------------------------------------------------------

  CREATE TABLE "CRM_ZDARZENIE" ("NK_KONTR" NUMBER(10,0) DEFAULT 0, "NK_ZD" NUMBER(10,0) DEFAULT 0, "NK_ZAP" NUMBER(10,0) DEFAULT 0, "A_EMAIL" VARCHAR2(50 BYTE) DEFAULT ' ', "NAZ" VARCHAR2(50 BYTE) DEFAULT ' ', "STAN" NUMBER(2,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table CRS_DANE
--------------------------------------------------------

  CREATE TABLE "CRS_DANE" ("NK_KONTR" NUMBER(10,0), "STOJAKI_W" NUMBER(10,0), "STOJAKI_D" NUMBER(10,0), "ILOSC_SZYB" NUMBER(10,0), "DATA_SPED" DATE, "WSP" NUMBER(5,2), "HANDL" VARCHAR2(30 BYTE), "KONTAKT" VARCHAR2(100 BYTE), "DATA_UPO" DATE, "DATA_ODP" DATE, "DATA_ODB" DATE, "IL_UPO" NUMBER(4,0), "IDENT_UPO" NUMBER(10,0), "DATA_LIKW" DATE, "IL_STOJ" NUMBER(4,0), "LISTA_STOJ" VARCHAR2(100 BYTE), "POWOD_LIKW" VARCHAR2(200 BYTE), "IDENT_LIKW" NUMBER(10,0), "DATA_POTW" DATE, "ILOSC_NA_PROT" NUMBER(4,0), "ILOSC_BRAKOW" NUMBER(4,0), "UZG" VARCHAR2(1 BYTE), "UWAGI" VARCHAR2(200 BYTE), "ZGL" VARCHAR2(200 BYTE), "IDENT_POT" NUMBER(10,0), "DATA_ZGL" DATE, "UWAGI1" VARCHAR2(200 BYTE), "OKRES" NUMBER(5,0), "POCZTA" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table CUBCK777
--------------------------------------------------------

  CREATE TABLE "CUBCK777" ("NR_KOMP_STRUKTURY" NUMBER(10,0), "NR_KOL_PARAM" NUMBER(6,0), "NR_KOMP_SL_PAR" NUMBER(10,0), "SYMB_PARAM" VARCHAR2(10 BYTE), "OPIS_PARAM" VARCHAR2(50 BYTE), "WART_PAR" NUMBER(14,4), "TYP_PAR" NUMBER(2,0), "CZY_OBOW" NUMBER(2,0), "CZY_KOREKT_WYM" NUMBER(1,0), "JEDN" VARCHAR2(5 BYTE), "FORMAT" VARCHAR2(10 BYTE), "NR_KOMP_GR" NUMBER(10,0) DEFAULT 0, "CZY_NA_WYDR" NUMBER(1,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table DANE_ADR
--------------------------------------------------------

  CREATE TABLE "DANE_ADR" ("OPERATOR" VARCHAR2(50 BYTE), "NAZWISKO" VARCHAR2(50 BYTE), "TELEFON" VARCHAR2(20 BYTE), "FAX" VARCHAR2(20 BYTE), "ADRES" VARCHAR2(100 BYTE), "EMAIL" VARCHAR2(100 BYTE), "UWAGI" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table DANE_WYK
--------------------------------------------------------

  CREATE TABLE "DANE_WYK" ("NR_KOMP_INST" NUMBER(10,0), "NR_KOMP_ZM" NUMBER(10,0), "NR_BRYGADY" NUMBER(10,0), "DZIEN" DATE, "ZMIANA" NUMBER(1,0), "GODZ_NOM" NUMBER(4,2), "GODZ_PRZEPR" NUMBER(4,2), "POW_PRZEL_WYK" NUMBER(18,2), "SRED_POW" NUMBER(9,4), "WSP_RBG" NUMBER(7,2), "RBG_WYL" NUMBER(18,2), "PREMIA_WYL" NUMBER(18,2), "PREMIA_ZATWIER" NUMBER(18,2), "FM" NUMBER(18,2), "POTR" NUMBER(18,2), "ODLICZ_PREM" NUMBER(18,2), "FLAG_ZATW" NUMBER(1,0), "NUMER_ODDZ" NUMBER(2,0), "MIESIAC" NUMBER(2,0), "ROK" NUMBER(4,0), "PREMIA_DOD" NUMBER(18,2)) ;
--------------------------------------------------------
--  DDL for Table DAN_FK5
--------------------------------------------------------

  CREATE TABLE "DAN_FK5" ("NKOMP_KONTRAHENTA" NUMBER(10,0), "SALDO" NUMBER(15,2), "KW_PRZET" NUMBER(15,2), "KW_NIE_PRZET" NUMBER(15,2), "ZALICZKI" NUMBER(15,2), "P_30" NUMBER(15,2), "P_31_60" NUMBER(15,2), "P_61_90" NUMBER(15,2), "P_91" NUMBER(15,2), "DATA" DATE, "WSKAZNIK" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table DOK
--------------------------------------------------------

  CREATE TABLE "DOK" ("NR_KOMP_DOK" NUMBER(10,0), "NR_DOK" NUMBER(8,0), "DATA_D" DATE, "DATA_TR" DATE, "NR_DOK_BAZ" CHAR(19 BYTE), "DATA_D_BAZ" DATE, "TYP_DOK" VARCHAR2(3 BYTE), "OPIS" CHAR(50 BYTE), "NR_MAG" NUMBER(3,0), "NR_MAG_DOC" NUMBER(3,0), "NR_KON" NUMBER(10,0), "STATUS" NUMBER(1,0), "STORNO" NUMBER(1,0), "GR_DOK" CHAR(3 BYTE), "NR_KOM_FAKT" NUMBER(10,0), "TYP_ZLEC" CHAR(3 BYTE), "ROK" NUMBER(4,0), "MIES" NUMBER(2,0), "NR_ODDZ" NUMBER(2,0), "NR_KOMP_BAZ" NUMBER(10,0), "WARTOSC" NUMBER(14,2), "NR_OP_WPR" VARCHAR2(10 BYTE), "WARTNOM" NUMBER(14,2) DEFAULT 0, "NR_DOK_STORNO" NUMBER(10,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table DOSTAWY
--------------------------------------------------------

  CREATE TABLE "DOSTAWY" ("NR_DOST" NUMBER(10,0), "GR_DOK" CHAR(3 BYTE), "NR_TRASY" NUMBER(10,0), "NR_KON" NUMBER(10,0), "NAZ_ODB" VARCHAR2(30 BYTE), "KOD_POCZ" VARCHAR2(10 BYTE), "MIASTO" VARCHAR2(30 BYTE), "ADRES" VARCHAR2(31 BYTE), "PANSTWO" VARCHAR2(20 BYTE), "POWIAT" VARCHAR2(20 BYTE), "WOJEW" VARCHAR2(20 BYTE), "TEL" VARCHAR2(19 BYTE), "FAX" VARCHAR2(19 BYTE), "MAIL" VARCHAR2(128 BYTE), "DL_TRASY" NUMBER(5,0), "ODL_OD" NUMBER(3,0) DEFAULT 0, "GDZIE_STOJAKI" NUMBER(10,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table DRMETPOZ
--------------------------------------------------------

  CREATE TABLE "DRMETPOZ" ("NR_KOM_ZLEC" NUMBER(10,0), "LP_LIS" NUMBER(6,0), "TYP_ZLEC" VARCHAR2(3 BYTE), "POZ_SORT" NUMBER(10,0), "NAGL0" VARCHAR2(100 BYTE), "NAGL1" VARCHAR2(100 BYTE), "NAGL2" VARCHAR2(100 BYTE), "NAGL3" VARCHAR2(100 BYTE), "NAGL4" VARCHAR2(50 BYTE), "DATA1" DATE, "DATA2" DATE, "NUMERZ" NUMBER(6,0), "ZLECODD" VARCHAR2(20 BYTE), "ZLECK" VARCHAR2(18 BYTE), "ZLECW" VARCHAR2(18 BYTE), "SYMBOL" VARCHAR2(100 BYTE), "STRUKT" VARCHAR2(500 BYTE), "BUDOWA" VARCHAR2(50 BYTE), "LPS" NUMBER(3,0), "POZ" NUMBER(3,0), "DLUG" NUMBER(4,0), "SZER" NUMBER(4,0), "SZT" NUMBER(8,0), "SZCAL" NUMBER(4,0), "KLIENT" VARCHAR2(15 BYTE), "INDKLI" NUMBER(10,0), "ADRDOST" VARCHAR2(200 BYTE), "KWSP" NUMBER(4,2), "ZLTYP" VARCHAR2(20 BYTE), "ID" VARCHAR2(20 BYTE), "RACKNO" NUMBER(6,0), "NAZPUBL" VARCHAR2(128 BYTE), "NAZSTKLI" VARCHAR2(150 BYTE), "NAZSLKLI" VARCHAR2(150 BYTE), "SERIALNO" NUMBER(10,0), "LPC" NUMBER(3,0), "LPM" NUMBER(3,0), "ATTRIB" VARCHAR2(30 BYTE), "CODEBAR" VARCHAR2(21 BYTE), "WAGA" NUMBER(9,3), "SZP1" NUMBER(4,0), "SZP2" NUMBER(4,0), "SZPN" VARCHAR2(128 BYTE), "SZPP" VARCHAR2(128 BYTE), "ENER" VARCHAR2(100 BYTE), "NAPISD" VARCHAR2(100 BYTE), "TRASA" NUMBER(8,0), "ILPOZ" NUMBER(6,0), "DATAP" DATE, "WNG" NUMBER(4,0), "WNB" NUMBER(4,0), "JNG" NUMBER(4,0), "JNB" NUMBER(4,0), "RGAZ" VARCHAR2(50 BYTE), "SZPB1" NUMBER(5,0), "SZPB2" NUMBER(5,0), "RWYR" VARCHAR2(100 BYTE), "OPISD" VARCHAR2(100 BYTE), "MODEL" NUMBER(5,0), "NAZKLI" VARCHAR2(50 BYTE), "DPRDK" DATE, "DSPEDK" DATE, "KDPOL" VARCHAR2(100 BYTE), "KDLINE" VARCHAR2(100 BYTE), "KDREF" VARCHAR2(100 BYTE), "NCEMARK" VARCHAR2(100 BYTE), "PNORMA" VARCHAR2(100 BYTE), "NCEWWW" VARCHAR2(150 BYTE), "NATEST" VARCHAR2(100 BYTE), "NZNAKB" VARCHAR2(20 BYTE), "NZNBUD" VARCHAR2(20 BYTE), "EUNAME1" VARCHAR2(100 BYTE), "EUNAME2" VARCHAR2(100 BYTE), "EUADDR" VARCHAR2(100 BYTE), "EUKRAJ" VARCHAR2(100 BYTE), "SALEPOS" VARCHAR2(100 BYTE), "SALEORD" VARCHAR2(100 BYTE), "NAZ_DLA_KLI" VARCHAR2(255 BYTE), "CE_ID" VARCHAR2(100 BYTE), "CE_CERT" VARCHAR2(100 BYTE), "GR_PAK" NUMBER(7,1), "GR_RMA1" NUMBER(5,1), "GR_RAM2" NUMBER(5,1), "SORTTYPE" VARCHAR2(50 BYTE), "LISTA" NUMBER(8,0), "STC" NUMBER(8,0), "PSTC" NUMBER(8,0), "GRPNR" VARCHAR2(50 BYTE), "KEYNR" VARCHAR2(50 BYTE), "PRDCODE" VARCHAR2(50 BYTE), "SYMTECH" VARCHAR2(50 BYTE), "RAMK" VARCHAR2(60 BYTE), "FNAME" VARCHAR2(128 BYTE), "ZLECP" VARCHAR2(50 BYTE), "ZZESP" VARCHAR2(128 BYTE), "NRSZYBY" NUMBER(8,0), "MARKER" VARCHAR2(25 BYTE), "WARSTWA" NUMBER(2,0), "CENA" NUMBER(14,4), "RCEN" VARCHAR2(4 BYTE), "MPARAM" VARCHAR2(100 BYTE), "KODNAL" VARCHAR2(40 BYTE), "OPTNR" NUMBER(10,0), "TAFNR" NUMBER(10,0), "TAFPOZ" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table DRUKARKA
--------------------------------------------------------

  CREATE TABLE "DRUKARKA" ("NR_WZORU" NUMBER(3,0), "TEKST" VARCHAR2(200 BYTE)) ;
--------------------------------------------------------
--  DDL for Table EC_BUF
--------------------------------------------------------

  CREATE TABLE "EC_BUF" ("EC_NK" NUMBER(10,0), "BF_NK" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table ECUTTER_GRUPYTOW
--------------------------------------------------------

  CREATE TABLE "ECUTTER_GRUPYTOW" ("NR_KOMP" NUMBER(10,0), "NAZWA_GRUPY" VARCHAR2(50 BYTE), "ZAKRESOD" VARCHAR2(10 BYTE), "ZAKRESDO" VARCHAR2(10 BYTE), "MNOZNIK" NUMBER(6,2), "DATAOD" DATE, "DATADO" DATE) ;
--------------------------------------------------------
--  DDL for Table ECUTTER_MESSAGEUSERS
--------------------------------------------------------

  CREATE TABLE "ECUTTER_MESSAGEUSERS" ("NR_KOMP_WIAD" NUMBER(10,0), "NR_KOMP_KL" NUMBER(10,0), "STATUS" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table ECUTTER_NAGRODY
--------------------------------------------------------

  CREATE TABLE "ECUTTER_NAGRODY" ("NR_KOMP" NUMBER(10,0), "NAZWA" VARCHAR2(100 BYTE), "OPIS" VARCHAR2(500 BYTE), "ROZMIAR" VARCHAR2(50 BYTE), "KOD" VARCHAR2(10 BYTE), "WARTOSC" NUMBER(6,0)) ;
--------------------------------------------------------
--  DDL for Table ECUTTER_NAGRODYUSERS
--------------------------------------------------------

  CREATE TABLE "ECUTTER_NAGRODYUSERS" ("NR_NAGRODY" NUMBER(10,0), "NR_KON" NUMBER(10,0), "DATA" DATE) ;
--------------------------------------------------------
--  DDL for Table ECUTTER_ORDERS
--------------------------------------------------------

  CREATE TABLE "ECUTTER_ORDERS" ("NR_KOMP_ZLEC" NUMBER(10,0), "NR_KLIENTA" NUMBER(10,0), "NR_ZLEC_KLIENTA" VARCHAR2(50 BYTE), "OPIS_KLIENTA" VARCHAR2(100 BYTE), "STATUS" NUMBER(2,0), "NR_ZLEC_CUTTER" NUMBER(10,0), "DATA_WPROW" DATE, "DATA_PRZYJ" DATE, "DATA_PLAN_WYS" DATE, "FLAGA_WYS" NUMBER(2,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table ECUTTER_POSITIONS
--------------------------------------------------------

  CREATE TABLE "ECUTTER_POSITIONS" ("NR_KOMP_ZLEC" NUMBER(10,0), "NR_POZ" NUMBER(10,0), "STRUKTURA" VARCHAR2(100 BYTE), "SZER" NUMBER(4,0), "WYS" NUMBER(4,0), "ILOSC" NUMBER(4,0), "OPIS" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table ECUTTER_PUNKTY
--------------------------------------------------------

  CREATE TABLE "ECUTTER_PUNKTY" ("NR_KON" NUMBER, "ROK" NUMBER, "PUNKTY" NUMBER) ;
--------------------------------------------------------
--  DDL for Table ECUTTER_SPISE
--------------------------------------------------------

  CREATE TABLE "ECUTTER_SPISE" ("NR_KOMP_ZLEC" NUMBER(10,0), "WYK" NUMBER(6,0), "WYS" NUMBER(6,0), "ILE_FAKT" NUMBER(6,0), "IL_A" NUMBER(6,0), "IL_S" NUMBER(6,0)) ;
--------------------------------------------------------
--  DDL for Table ECUTTER_SPISE_POZ
--------------------------------------------------------

  CREATE TABLE "ECUTTER_SPISE_POZ" ("NR_KOMP_ZLEC" NUMBER(10,0), "NR_POZ" NUMBER(3,0), "WYK" NUMBER(6,0) DEFAULT 0, "WYS" NUMBER(6,0) DEFAULT 0, "IL_A" NUMBER(6,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table ECUTTER_STRUCTURES
--------------------------------------------------------

  CREATE TABLE "ECUTTER_STRUCTURES" ("NR_KON" NUMBER(10,0), "STRUKTURA" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table ECUTTER_USERS
--------------------------------------------------------

  CREATE TABLE "ECUTTER_USERS" ("LOGIN" VARCHAR2(50 BYTE), "HASLO" VARCHAR2(40 BYTE), "TYP" VARCHAR2(1 BYTE), "NKOMP_KLIENT" NUMBER(10,0), "ID" NUMBER(10,0), "AKTYW" NUMBER(10,0), "HASLO2" VARCHAR2(40 BYTE) DEFAULT ' ') ;
--------------------------------------------------------
--  DDL for Table EDI_MAT
--------------------------------------------------------

  CREATE TABLE "EDI_MAT" ("MAT_KLIENTA" VARCHAR2(128 BYTE), "INDEKS" VARCHAR2(128 BYTE)) ;
--------------------------------------------------------
--  DDL for Table EDI_SLOW
--------------------------------------------------------

  CREATE TABLE "EDI_SLOW" ("NAZ_EDI" VARCHAR2(20 BYTE), "RODZAJ" VARCHAR2(1 BYTE), "TYP_POLA" NUMBER(3,0)) ;
--------------------------------------------------------
--  DDL for Table EFF_SLOW
--------------------------------------------------------

  CREATE TABLE "EFF_SLOW" ("KOD" RAW(7), "NIP" VARCHAR2(13 BYTE), "DEALER" VARCHAR2(3 BYTE)) ;
--------------------------------------------------------
--  DDL for Table EFF_ZASADY
--------------------------------------------------------

  CREATE TABLE "EFF_ZASADY" ("GR_KOSZ" NUMBER(10,0), "NAZ_VAT" VARCHAR2(5 BYTE), "NETTO" VARCHAR2(10 BYTE), "VAT" VARCHAR2(10 BYTE), "NETTO_FK" VARCHAR2(10 BYTE), "VAT_FK" VARCHAR2(10 BYTE), "KOLUMNA" NUMBER(1,0), "KOMENTARZ" VARCHAR2(100 BYTE), "MVAT_FK" NUMBER(10,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table EKOLOR
--------------------------------------------------------

  CREATE TABLE "EKOLOR" ("NAZ" VARCHAR2(20 BYTE), "WAR" VARCHAR2(8 BYTE)) ;
--------------------------------------------------------
--  DDL for Table FACIMILE
--------------------------------------------------------

  CREATE TABLE "FACIMILE" ("NR_OP" NUMBER(10,0), "PODPIS" LONG RAW) ;
--------------------------------------------------------
--  DDL for Table FAKNAGL
--------------------------------------------------------

  CREATE TABLE "FAKNAGL" ("NR_KOMP" NUMBER(10,0), "TYP_DOKS" CHAR(3 BYTE), "PREFIX" VARCHAR2(13 BYTE), "NR_DOKS" NUMBER(8,0), "SUFIX" VARCHAR2(13 BYTE), "MIEJSCOWOSC" CHAR(15 BYTE), "DATA_WYST" DATE, "DATA_SPRZED" DATE, "DATA_DUPLIK" DATE, "NR_PARAG" CHAR(15 BYTE), "NR_ODB" NUMBER(10,0), "NAZ_ODB" CHAR(50 BYTE), "SKROT_ODB" CHAR(15 BYTE), "PANSTWO_O" VARCHAR2(20 BYTE), "KOD_POCZ_O" VARCHAR2(10 BYTE), "MIASTO_O" VARCHAR2(30 BYTE), "ADRES_O" VARCHAR2(31 BYTE), "NR_PLAT" NUMBER(10,0), "NAZ_PLAT" CHAR(50 BYTE), "SKROT_PLAT" CHAR(15 BYTE), "PANSTWO_PLAT" VARCHAR2(20 BYTE), "KOD_POCZ_PLAT" VARCHAR2(10 BYTE), "MIASTO_PLAT" VARCHAR2(30 BYTE), "ADRES_PLAT" VARCHAR2(31 BYTE), "NR_DOST" NUMBER(10,0), "ADRES_DOST" VARCHAR2(60 BYTE), "GOT_KRED" CHAR(2 BYTE), "WAR_PLAT" CHAR(2 BYTE), "POZ_CEN" CHAR(3 BYTE), "DOK_DOST" CHAR(3 BYTE), "NR_WZ" NUMBER(8,0), "IM_NAZ_WYD" VARCHAR2(35 BYTE), "ODEBRAL" VARCHAR2(35 BYTE), "NR_KOMP_POPRZE" NUMBER(10,0), "NR_KOMP_NAST" NUMBER(10,0), "TYP_DOK_KOR" CHAR(3 BYTE), "PREFIX_KOR" CHAR(7 BYTE), "NR_DOK_KOR" NUMBER(8,0), "SUFIX_KOR" CHAR(7 BYTE), "DATA_KOR" DATE, "INF_PRZED_KOR" VARCHAR2(60 BYTE), "INF_PO_KOR" VARCHAR2(60 BYTE), "WART_NETTO" NUMBER(14,2), "WART_VAT" NUMBER(14,2), "WART_BRUTTO" NUMBER(14,2), "GR_DOK" CHAR(3 BYTE), "POLE_OK" NUMBER(2,0), "NR_OP_MOD" VARCHAR2(10 BYTE), "DATA_MOD" DATE, "NR_KOMP_ZLEC" NUMBER(10,0), "KREDYT_DNI" NUMBER(3,0), "STAN" NUMBER(3,0), "NR_ODDZ" NUMBER(2,0), "ROK" NUMBER(4,0), "MIES" NUMBER(2,0), "W_NETTO_B" NUMBER(14,2), "WART_VAT_B" NUMBER(14,2), "WART_BRUTTO_B" NUMBER(14,2), "STORNO" NUMBER(1,0), "OST_NR_B" NUMBER(10,0), "OST_NR_P" NUMBER(10,0), "UWAGI" VARCHAR2(100 BYTE), "WALUTA" VARCHAR2(4 BYTE), "KURS" NUMBER(12,4), "NR_TABELI" VARCHAR2(10 BYTE), "DATA_TABELI" DATE, "NIP_O" VARCHAR2(20 BYTE), "NIP_P" VARCHAR2(20 BYTE), "SALDO_Z" NUMBER(12,4), "NETTO_WAL" NUMBER(14,2), "VAT_WAL" NUMBER(14,2), "BRUTTO_WAL" NUMBER(14,2), "NETTO_B_WAL" NUMBER(14,2), "VAT_B_WAL" NUMBER(14,2), "BRUTTO_B_WAL" NUMBER(14,2), "ZAL_NETTO" NUMBER(14,2) DEFAULT 0, "ZAL_VAT" NUMBER(14,2) DEFAULT 0, "ZAL_BRUTTO" NUMBER(14,2) DEFAULT 0, "FL_INTRASTAT" NUMBER(2,0) DEFAULT 0, "WART_NETTO_PB_SKONTO" NUMBER(10,2) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table FAKNAGL_B
--------------------------------------------------------

  CREATE TABLE "FAKNAGL_B" ("ID_FAKT" NUMBER(10,0), "BONIFIKATA" NUMBER(11,5), "OPIS" CHAR(40 BYTE), "CZY_Z_FAKT" NUMBER(1,0), "ID_BON" NUMBER(10,0), "RODZAJ_B" NUMBER(6,0) DEFAULT 0, "TYP_B" VARCHAR2(3 BYTE) DEFAULT 'B', "WART_B_NETTO" NUMBER(10,2) DEFAULT 0, "WART_B_BRUTTO" NUMBER(10,2) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table FAKPODSUM
--------------------------------------------------------

  CREATE TABLE "FAKPODSUM" ("ID_FAKT" NUMBER(10,0), "ID_PODS" NUMBER(10,0), "NR_ART" NUMBER(10,0), "POZ_PODS" NUMBER(10,0), "NR_KONTRAH" NUMBER(10,0), "PEL_NAZ" VARCHAR2(255 BYTE), "ILOSC_JP" NUMBER(14,4), "ILOSC_SZT" NUMBER(10,0), "ILE_DOD" NUMBER(14,4), "WART_DOD" NUMBER(12,2), "JEDN" VARCHAR2(5 BYTE), "CENA_NETTO" NUMBER(16,4), "ST_VAT" VARCHAR2(5 BYTE), "WART_NETTO" NUMBER(14,2), "RODZ_CENY" VARCHAR2(4 BYTE), "SWW" VARCHAR2(18 BYTE), "GR_KOSZT" NUMBER(10,0), "GR_TOW" VARCHAR2(3 BYTE), "WART_VAT" NUMBER(14,2), "WART_BRUTTO" NUMBER(10,2) DEFAULT 0, "SUMA_BON" NUMBER(6,5) DEFAULT 0, "WART_NETTO_PB" NUMBER(10,2) DEFAULT 0, "WART_BRUTTO_PB" NUMBER(10,2) DEFAULT 0, "CENA_NETTO_SZT" NUMBER(10,4) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table FAKPOZ
--------------------------------------------------------

  CREATE TABLE "FAKPOZ" ("TYP_DOKS" CHAR(3 BYTE), "NR_DOKS" NUMBER(8,0), "DATA_WYS" DATE, "NR_POZ" NUMBER(3,0), "INDEKS" VARCHAR2(128 BYTE), "NAZ_TOW" VARCHAR2(255 BYTE), "PKWIU" CHAR(18 BYTE), "ILOSC" NUMBER(14,4), "CENA_NETTO" NUMBER(16,4), "JEDN" CHAR(5 BYTE), "WART_NETTO" NUMBER(14,2), "NAZ_VAT" CHAR(5 BYTE), "WART_VAT" NUMBER(14,2), "WART_BRUTTO" NUMBER(14,2), "STORNO" NUMBER(1,0), "NR_DOK_KOR" NUMBER(8,0), "NR_POZ_KOR" NUMBER(3,0), "NR_MAG" NUMBER(3,0), "NR_KOMP_DOKS" NUMBER(10,0), "NR_ODDZ" NUMBER(2,0), "ROK" NUMBER(4,0), "MIES" NUMBER(2,0), "PREFIX_INDEKSU_TOWARU" VARCHAR2(20 BYTE), "PREFIX_NAZWY_TOWARU" VARCHAR2(50 BYTE), "CENA_NETTO_B" NUMBER(16,4), "WART_NETTO_B" NUMBER(14,2), "WART_VAT_B" NUMBER(14,2), "WART_BRUTTO_B" NUMBER(14,2), "OST_NR_B" NUMBER(10,0), "ID_POZ" NUMBER(10,0), "BON_SUMA_P" NUMBER(11,5), "ID_WZ" NUMBER(10,0), "ID_WZ_POZ" NUMBER(3,0), "ID_ZLEC" NUMBER(10,0), "ID_ZLEC_POZ" NUMBER(3,0), "CZY_DOD" VARCHAR2(1 BYTE), "C_N_POZ_W" NUMBER(16,4), "LP_DOD" NUMBER(3,0), "IL_SZT" NUMBER(4,0), "CENA_NETTO_SZT" NUMBER(16,4), "RODZAJ_CENY" VARCHAR2(4 BYTE), "NETTO_WAL" NUMBER(14,2), "VAT_WAL" NUMBER(14,2), "BRUTTO_WAL" NUMBER(14,2), "NETTO_B_WAL" NUMBER(14,2), "VAT_B_WAL" NUMBER(14,2), "BRUTTO_B_WAL" NUMBER(14,2), "KOD_TOW_UE" VARCHAR2(9 BYTE) DEFAULT '', "KOD_KRAJ_PRZEZ" VARCHAR2(2 BYTE) DEFAULT '', "FL_INTRASTAT" NUMBER(2,0) DEFAULT 0, "WAGA" NUMBER(10,3) DEFAULT 0, "SUMA_RAB_FAKT" NUMBER(6,5) DEFAULT 0, "WART_Z_RAB_POZ" NUMBER(10,2) DEFAULT 0, "WART_POZ_NARAST" NUMBER(10,2) DEFAULT 0, "SUMA_IL_NARAST" NUMBER(10,4) DEFAULT 0, "SUMA_SZT_NARAST" NUMBER(8,0) DEFAULT 0, "CENA_SZT_WYPADK" NUMBER(10,4) DEFAULT 0, "CENA_SZT_WYP_PB" NUMBER(10,4) DEFAULT 0, "CENA_JM_WYP_PB" NUMBER(10,4) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table FAKPOZ_B
--------------------------------------------------------

  CREATE TABLE "FAKPOZ_B" ("ID_FAKT" NUMBER(10,0), "NR_POZ" NUMBER(3,0), "BONIFIKATA" NUMBER(11,5), "OPIS" CHAR(40 BYTE), "CZY_Z_FAKT" NUMBER(1,0), "ID_BON" NUMBER(10,0), "ID_POZ" NUMBER(10,0), "RODZAJ_B" NUMBER(6,0) DEFAULT 0, "TYP_B" VARCHAR2(3 BYTE) DEFAULT 'B', "KOREKTA_CENY" NUMBER(10,4) DEFAULT 0, "KOREKTA_W_NETTO" NUMBER(10,2) DEFAULT 0, "KOREKTA_W_BRUTTO" NUMBER(10,2) DEFAULT 0, "KOREKTA_CALK_NETTO" NUMBER(10,2) DEFAULT 0, "KOREKTA_CALK_BRUTTO" NUMBER(10,2) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table FAKT_BUF
--------------------------------------------------------

  CREATE TABLE "FAKT_BUF" ("NR_KOMP" NUMBER(10,0), "TYP_DOKS" VARCHAR2(3 BYTE), "NR_DOKS" NUMBER(8,0), "SYMB" VARCHAR2(50 BYTE), "NR_KONTR" NUMBER(10,0), "NR_ODDZ" NUMBER(2,0), "WART_BRUTTO" NUMBER(18,2), "WSK_OBC" NUMBER(1,0), "WSK_ZAP" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table FAKTEXT
--------------------------------------------------------

  CREATE TABLE "FAKTEXT" ("NR_FAKT" NUMBER(10,0), "WAR_TRAN" VARCHAR2(100 BYTE), "TEKST_D" VARCHAR2(1000 BYTE) DEFAULT '', "KOD_KRAJ_SPRZ" CHAR(2 BYTE) DEFAULT '', "KOD_KRAJ_ODB" CHAR(2 BYTE) DEFAULT '', "KOD_WAR_DOST" CHAR(3 BYTE) DEFAULT '', "KOD_RODZ_TRANSAK" CHAR(2 BYTE) DEFAULT '', "KOD_RODZ_TRANSP" CHAR(2 BYTE) DEFAULT '', "NIP_UE_SP" CHAR(15 BYTE) DEFAULT '', "NIP_UE_ODB" CHAR(15 BYTE) DEFAULT '', "LOCO" CHAR(31 BYTE), "NIP_UE_PLAT" CHAR(15 BYTE) DEFAULT '', "KOD_KRAJ_PLAT" CHAR(2 BYTE), "WAGA_DOLICZ" NUMBER(9,3)) ;
--------------------------------------------------------
--  DDL for Table FAKT_LISTA_SPED
--------------------------------------------------------

  CREATE TABLE "FAKT_LISTA_SPED" ("ID_FAKTURY" NUMBER(10,0), "ID_DOSTAWY" NUMBER(10,0), "DATA_DOSTAWY" DATE, "WAGA_SUM_DOSTAWY" NUMBER(8,2), "NR_SAMOCH_DOSTAWY" VARCHAR2(21 BYTE)) ;
--------------------------------------------------------
--  DDL for Table FAKT_LISTA_WZ
--------------------------------------------------------

  CREATE TABLE "FAKT_LISTA_WZ" ("ID_FAKTURY" NUMBER(10,0), "NR_K_WZ" NUMBER(10,0), "NUMER_DOK_WZ" NUMBER(8,0), "NR_MAG_WZ" NUMBER(4,0), "DATA_WZ" DATE, "WART_NETTO_WZ" NUMBER(10,2)) ;
--------------------------------------------------------
--  DDL for Table FAKT_LISTA_ZLEC
--------------------------------------------------------

  CREATE TABLE "FAKT_LISTA_ZLEC" ("ID_FAKTURY" NUMBER(10,0), "ID_ZLEC" NUMBER(10,0), "NR_ZLEC_KLIENTA" VARCHAR2(51 BYTE), "TYP_ZLEC" VARCHAR2(4 BYTE), "DATA_ZLEC" DATE, "SUMA_JM_W_FAKT" NUMBER(10,4), "SUMA_SZT_W_FAKT" NUMBER(6,0), "SUMA_NETTO_W_FAKT" NUMBER(10,2), "SUMA_NETTO_W_FAKT_WAL" NUMBER(10,2)) ;
--------------------------------------------------------
--  DDL for Table FAKT_PODS_VAT
--------------------------------------------------------

  CREATE TABLE "FAKT_PODS_VAT" ("ID_FAKT" NUMBER(10,0), "KOD_ST_VAT" VARCHAR2(7 BYTE), "STAWKAVAT" NUMBER(3,3), "SUMA_NETTO" NUMBER(10,2), "SUMA_VAT" NUMBER(10,2), "SUMA_BRUTTO" NUMBER(10,2), "SUMA_NETTO_PB" NUMBER(10,2), "SUMA_VAT_PB" NUMBER(10,2), "SUMA_BRUTTO_PB" NUMBER(10,2), "SUMA_NETTO_WAL" NUMBER(10,2), "SUMA_VAT_WAL" NUMBER(10,2), "SUMA_BRUTTO_WAL" NUMBER(10,2), "SUMA_NETTO_WAL_PB" NUMBER(10,2), "SUMA_VAT_WAL_PB" NUMBER(10,2), "SUMA_BRUTTO_WAL_PB" NUMBER(10,2)) ;
--------------------------------------------------------
--  DDL for Table FGT_DEKRETY
--------------------------------------------------------

  CREATE TABLE "FGT_DEKRETY" ("IDENT" NUMBER(10,0), "LP" NUMBER(10,0), "RODZAJ_KWOTY" VARCHAR2(1 BYTE), "WINIEN" VARCHAR2(20 BYTE), "MA" VARCHAR2(20 BYTE), "GRUPA_KOSZTOWA" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table FGT_FAK
--------------------------------------------------------

  CREATE TABLE "FGT_FAK" ("NK_DOK" NUMBER(10,0), "ZNK_DOK" NUMBER(2,0), "DATA_WYS" DATE, "ZN" NUMBER(1,0), "SYMBOL" VARCHAR2(50 BYTE) DEFAULT '', "DATA_WYST" DATE DEFAULT '1901/01/01', "WALUTA" VARCHAR2(5 BYTE) DEFAULT '', "KURS" NUMBER(10,6) DEFAULT 0, "KURS_NOW" NUMBER(10,6) DEFAULT 0, "BLOKADA" NUMBER(1,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table FGT_GRK
--------------------------------------------------------

  CREATE TABLE "FGT_GRK" ("INDEKS" VARCHAR2(128 BYTE), "NAZWA" VARCHAR2(255 BYTE), "NKOMP" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table FIRMA
--------------------------------------------------------

  CREATE TABLE "FIRMA" ("NAZ_FIRMY" VARCHAR2(199 BYTE), "SKROT_FIRMY" VARCHAR2(20 BYTE), "PANSTWO" VARCHAR2(20 BYTE), "KOD_POCZ" VARCHAR2(10 BYTE), "MIASTO" VARCHAR2(30 BYTE), "POWIAT" VARCHAR2(20 BYTE), "WOJEW" VARCHAR2(20 BYTE), "ADRES" VARCHAR2(31 BYTE), "REGON" VARCHAR2(20 BYTE), "NIP" CHAR(20 BYTE), "NR_RACH" VARCHAR2(40 BYTE), "NR_BANKU" NUMBER(8,0), "ROK_OBL" DATE, "POCZ_ROKU_OBL" DATE, "NR_ODZ" NUMBER(2,0), "LICENCJA" NUMBER(10,0), "MIEJ_WYS" VARCHAR2(30 BYTE), "NAZWA_1" VARCHAR2(100 BYTE), "NAZWA_2" VARCHAR2(100 BYTE), "NR_WDR" NUMBER(5,0), "LICZBA_ODDZ" NUMBER(5,0), "TEL_1" VARCHAR2(16 BYTE), "TEL_2" VARCHAR2(16 BYTE), "FAX_1" VARCHAR2(16 BYTE), "FAX_2" VARCHAR2(16 BYTE), "PREFIX_KRAJU" VARCHAR2(4 BYTE), "PREFIX_MIASTA" VARCHAR2(4 BYTE), "BANK2" NUMBER(8,0), "NR_RACH_2" VARCHAR2(40 BYTE), "BANK3" NUMBER(8,0), "NR_RACH_3" VARCHAR2(40 BYTE), "NIP_UE" VARCHAR2(15 BYTE), "KOD_IC" VARCHAR2(6 BYTE), "F_NAZWA" VARCHAR2(199 BYTE), "F_MIASTO" VARCHAR2(30 BYTE), "F_ULICA" VARCHAR2(31 BYTE), "F_KODPOCZT" VARCHAR2(10 BYTE), "F_HTTP" VARCHAR2(100 BYTE), "F_EMAIL" VARCHAR2(100 BYTE), "F_NRKOM" VARCHAR2(20 BYTE), "F_WWW_ZAM" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table FK2_FAK
--------------------------------------------------------

  CREATE TABLE "FK2_FAK" ("NK_DOK" NUMBER(10,0), "ZNK_DOK" NUMBER(2,0), "DATA_WYS" DATE, "ZN" NUMBER(1,0), "SYMBOL" VARCHAR2(50 BYTE), "DATA_WYST" DATE, "WALUTA" VARCHAR2(5 BYTE), "KURS" NUMBER(16,6), "KURS_NOW" NUMBER(16,6), "BLOKADA" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table FK2_SLOW
--------------------------------------------------------

  CREATE TABLE "FK2_SLOW" ("RODZAJ" NUMBER(2,0), "NUMER" NUMBER(3,0), "NAZWA" VARCHAR2(50 BYTE), "SZER" NUMBER(3,0), "OD" NUMBER(3,0), "DO" NUMBER(3,0)) ;
--------------------------------------------------------
--  DDL for Table FK6_DANE2
--------------------------------------------------------

  CREATE TABLE "FK6_DANE2" ("NK_KONTR" NUMBER(10,0) DEFAULT 0, "ROK" NUMBER(4,0) DEFAULT 0, "OKRES" NUMBER(2,0) DEFAULT 0, "NK_ZAP" NUMBER(10,0) DEFAULT 0, "DATA" DATE DEFAULT to_date(1901,'YYYY'), "KWOTA" NUMBER(14,4) DEFAULT 0, "BLOK" NUMBER(2,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table FK6_DANE7
--------------------------------------------------------

  CREATE TABLE "FK6_DANE7" ("NK_ZLEC" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table FKS_FAKTURY
--------------------------------------------------------

  CREATE TABLE "FKS_FAKTURY" ("NKOMP_DOKUMENTU" NUMBER(10,0), "ZNACZNIK_DOKUMENTU" NUMBER(2,0), "DATA_WYSLANIA" DATE, "ZNACZNIK" NUMBER(1,0), "SYMBOL" VARCHAR2(50 BYTE), "DATA_WYSTAWIENIA" DATE, "WALUTA" VARCHAR2(5 BYTE), "KURS" NUMBER(16,6), "KURS_NOW" NUMBER(16,6), "BLOKADA" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table GR_INST
--------------------------------------------------------

  CREATE TABLE "GR_INST" ("NR_GR" NUMBER(5,0) DEFAULT 0, "NAZ_GR" VARCHAR2(50 BYTE) DEFAULT '') ;
--------------------------------------------------------
--  DDL for Table GR_INST_DLA_OBR
--------------------------------------------------------

  CREATE TABLE "GR_INST_DLA_OBR" ("NR_KOMP_GR" NUMBER(10,0), "NR_KOMP_OBR" NUMBER(10,0), "NR_KOMP_INST" NUMBER(10,0), "KOLEJNOSC" NUMBER(5,0), "AKT" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table GR_INST_POW
--------------------------------------------------------

  CREATE TABLE "GR_INST_POW" ("NR_KOMP_GR" NUMBER(10,0), "OPIS_GRUPY" VARCHAR2(100 BYTE), "NR_KOMP_INST" NUMBER(10,0), "KOLEJ" NUMBER(2,0), "ROZN_CZAS" NUMBER(2,0), "FLAG" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table GR_KOSZT
--------------------------------------------------------

  CREATE TABLE "GR_KOSZT" ("NR_KOMP_GR" NUMBER(10,0), "NAZ_GR" VARCHAR2(20 BYTE), "NAZ_PODGR" VARCHAR2(100 BYTE), "NR_MAG" NUMBER(3,0), "NR_ANAL" NUMBER(3,0), "KONTO_M" VARCHAR2(10 BYTE), "KONTO_MWD" VARCHAR2(10 BYTE), "KONTO_MNF" VARCHAR2(10 BYTE), "KONTO_MODCH" VARCHAR2(10 BYTE), "KONTO_KOSZT" VARCHAR2(10 BYTE), "ZN_KART" VARCHAR2(3 BYTE), "NR_GRUPY" NUMBER(5,0), "KOD_J" VARCHAR2(10 BYTE), "KOD_H" VARCHAR2(10 BYTE)) ;
--------------------------------------------------------
--  DDL for Table GR_PLAN
--------------------------------------------------------

  CREATE TABLE "GR_PLAN" ("NKOMP_GRUPY" NUMBER(10,0), "NKOMP_INSTALACJI" NUMBER(10,0), "NR_GR" NUMBER(5,0), "NAZWA_GRUPY" VARCHAR2(50 BYTE), "NR_KOMP_OBR" NUMBER(10,0), "GRUB_P" NUMBER(6,3), "GRUB_K" NUMBER(6,3), "NADDATEK" NUMBER(6,3)) ;
--------------------------------------------------------
--  DDL for Table GR_STRUKT
--------------------------------------------------------

  CREATE TABLE "GR_STRUKT" ("NR_GRUPY_STR" NUMBER(10,0), "NAZWA_GRUPY" VARCHAR2(60 BYTE), "INDEKS" NUMBER(4,0)) ;
--------------------------------------------------------
--  DDL for Table GRUPTOW
--------------------------------------------------------

  CREATE TABLE "GRUPTOW" ("GR_TOW" CHAR(3 BYTE), "OPIS" VARCHAR2(100 BYTE), "NAZWA_STAWKI_VAT" VARCHAR2(5 BYTE), "PREFIX_TOW" VARCHAR2(20 BYTE), "PREFIX_NAZW" VARCHAR2(50 BYTE), "GR_TOW_SUR" CHAR(3 BYTE), "GR_TOW_FORM" CHAR(3 BYTE), "GR_TOW_SZYB" CHAR(3 BYTE), "PKWIU" CHAR(18 BYTE), "MARZA" NUMBER(6,3), "POZ_Z" NUMBER(2,0), "POZ_W" NUMBER(2,0), "NR_ANAL" NUMBER(3,0), "ZN_KART" VARCHAR2(3 BYTE), "NR_KOMP_GR_KOSZT" NUMBER(10,0), "PROCEN" NUMBER(10,0), "P_REALOK" NUMBER(10,0), "PROFIL_MARZ" NUMBER(10,0), "KOD_UE" CHAR(8 BYTE) DEFAULT '', "NR_KAT" NUMBER(4,0) DEFAULT 0, "GR_TOW_SKL" VARCHAR2(200 BYTE) DEFAULT '') ;
--------------------------------------------------------
--  DDL for Table GRUPY
--------------------------------------------------------

  CREATE TABLE "GRUPY" ("NAZWA_GRUPY" VARCHAR2(31 BYTE), "NUMER_GRUPY" NUMBER(10,0), "OPIS" VARCHAR2(200 BYTE)) ;
--------------------------------------------------------
--  DDL for Table GRUPYKL
--------------------------------------------------------

  CREATE TABLE "GRUPYKL" ("NUMER_GRUPY" NUMBER(10,0), "NUMER_KLUCZA" NUMBER(10,0), "WSK" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table GT_OBR1
--------------------------------------------------------

  CREATE TABLE "GT_OBR1" ("GR_TOW" VARCHAR2(3 BYTE), "NK_ZAP" NUMBER(10,0), "TYP" VARCHAR2(1 BYTE)) ;
--------------------------------------------------------
--  DDL for Table GT_OBR2
--------------------------------------------------------

  CREATE TABLE "GT_OBR2" ("NK_ZAP" NUMBER(10,0), "NK_OBR" NUMBER(4,0), "TYP_A" NUMBER(1,0), "GR_A" NUMBER(3,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table HARMON
--------------------------------------------------------

  CREATE TABLE "HARMON" ("NR_INST" NUMBER(3,0), "DZIEN" DATE, "ZMIANA" NUMBER(1,0), "NR_KOMP_ZLEC" NUMBER(10,0), "TYP_HARM" CHAR(1 BYTE), "ILOSC" NUMBER(14,0), "WIELKOSC" NUMBER(14,2), "NR_KOMP_INST" NUMBER(10,0), "TYP_INST" CHAR(3 BYTE), "NR_ODDZ" NUMBER(2,0), "ROK" NUMBER(4,0), "MIES" NUMBER(2,0), "IL_Z_ZAM" NUMBER(14,0), "DANE_Z_ZAM" NUMBER(14,2), "ZATWIERDZ" NUMBER(1,0), "GODZ_POCZ" CHAR(6 BYTE) DEFAULT '', "GODZ_KON" CHAR(6 BYTE) DEFAULT '', "KOL_NA_ZM" NUMBER(5,0) DEFAULT 0, "NR_KOMP_ZM" NUMBER(10,0) DEFAULT 0, "SPAD" NUMBER(1,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table HISTOJ
--------------------------------------------------------

  CREATE TABLE "HISTOJ" ("NR_KOMP_STOJ" NUMBER(10,0), "DATA" DATE, "CZAS" CHAR(6 BYTE), "NR_KONTR" NUMBER(10,0), "ADRES" VARCHAR2(100 BYTE), "NR_ODDZ" NUMBER(2,0), "WYJ_PRZYJ" VARCHAR2(1 BYTE), "NR_SPED" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table IFS_ANAL
--------------------------------------------------------

  CREATE TABLE "IFS_ANAL" ("NR_ANAL" NUMBER(3,0), "KONTO_SYNT" VARCHAR2(10 BYTE), "KONTO_ANAL" VARCHAR2(10 BYTE), "OPIS" VARCHAR2(30 BYTE), "KOMENTARZ" VARCHAR2(40 BYTE), "NR_MAG" NUMBER(3,0)) ;
--------------------------------------------------------
--  DDL for Table IFS_ODB
--------------------------------------------------------

  CREATE TABLE "IFS_ODB" ("CT_DT" VARCHAR2(2 BYTE), "TYP_IFS" VARCHAR2(10 BYTE), "KONTO" VARCHAR2(10 BYTE), "OPIS" VARCHAR2(60 BYTE)) ;
--------------------------------------------------------
--  DDL for Table IFS_ODBIORCY
--------------------------------------------------------

  CREATE TABLE "IFS_ODBIORCY" ("TYP_ODB" VARCHAR2(10 BYTE), "KONTO_SYNT" VARCHAR2(10 BYTE), "KONTO_ANAL" VARCHAR2(10 BYTE), "OPIS" VARCHAR2(40 BYTE)) ;
--------------------------------------------------------
--  DDL for Table IFS_VAT
--------------------------------------------------------

  CREATE TABLE "IFS_VAT" ("KONTO_SYNT" VARCHAR2(10 BYTE), "KONTO_ANAL" VARCHAR2(10 BYTE), "OPIS" VARCHAR2(30 BYTE), "KOMENTARZ" VARCHAR2(40 BYTE)) ;
--------------------------------------------------------
--  DDL for Table IFS_VAT_K
--------------------------------------------------------

  CREATE TABLE "IFS_VAT_K" ("CT_DT" VARCHAR2(2 BYTE), "KONTO" VARCHAR2(10 BYTE), "OPIS" VARCHAR2(60 BYTE)) ;
--------------------------------------------------------
--  DDL for Table IFS_WZ
--------------------------------------------------------

  CREATE TABLE "IFS_WZ" ("TYP_KONTA" VARCHAR2(2 BYTE), "KONTO_SYNT" VARCHAR2(10 BYTE), "KONTO_ANAL" VARCHAR2(10 BYTE), "OPIS" VARCHAR2(30 BYTE), "KOMENTARZ" VARCHAR2(40 BYTE), "NR_MAG" NUMBER(3,0), "NR_ANAL" NUMBER(3,0)) ;
--------------------------------------------------------
--  DDL for Table IFS_ZASADY
--------------------------------------------------------

  CREATE TABLE "IFS_ZASADY" ("TYP" VARCHAR2(2 BYTE), "KOD" VARCHAR2(8 BYTE), "TYP_IFS" VARCHAR2(10 BYTE), "BRUTTO" VARCHAR2(10 BYTE), "NETTO" VARCHAR2(10 BYTE), "VAT" VARCHAR2(10 BYTE), "OPIS" VARCHAR2(60 BYTE)) ;
--------------------------------------------------------
--  DDL for Table INFO_ESPED
--------------------------------------------------------

  CREATE TABLE "INFO_ESPED" ("NK_KONTR" NUMBER(10,0), "NR_OD" NUMBER(2,0), "NR_SPED" NUMBER(10,0), "DATA_SPED" DATE, "ILOSC_SZYB" NUMBER(10,0), "ILOSC_STOJ" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table INFO_ESTOJ
--------------------------------------------------------

  CREATE TABLE "INFO_ESTOJ" ("NK_KONTR" NUMBER(10,0), "NR_OD" NUMBER(2,0), "NK_SPED" NUMBER(10,0), "NK_ZLEC" NUMBER(10,0), "NK_STOJ" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table ISO_PRNTNR
--------------------------------------------------------

  CREATE TABLE "ISO_PRNTNR" ("NR_WYDRUKU" NUMBER(10,0), "NR_APLIKACJI" NUMBER(4,0), "NAZWA_WYDRUKU" VARCHAR2(100 BYTE), "ISO_NUMBER" VARCHAR2(50 BYTE), "UWAGI" VARCHAR2(100 BYTE), "DRUKOWAC" NUMBER(1,0), "NR_WZORU" NUMBER(4,0)) ;
--------------------------------------------------------
--  DDL for Table JEDN
--------------------------------------------------------

  CREATE TABLE "JEDN" ("SYMB" CHAR(6 BYTE), "NAZ_JED" VARCHAR2(20 BYTE), "DOKL" NUMBER(7,5)) ;
--------------------------------------------------------
--  DDL for Table JEDNROW
--------------------------------------------------------

  CREATE TABLE "JEDNROW" ("NAZ_JED" CHAR(18 BYTE), "RODZ_OP" CHAR(15 BYTE), "IL_W_OP" NUMBER(10,0), "JED_POD" CHAR(5 BYTE), "WSP_PRZEL" NUMBER(18,8), "NR_KOMP_JEDN" NUMBER(4,0), "JEDNOSTKA_PODSTAWOWA" VARCHAR2(5 BYTE)) ;
--------------------------------------------------------
--  DDL for Table JEZ_LISTA
--------------------------------------------------------

  CREATE TABLE "JEZ_LISTA" ("NUMER_JEZYKA" NUMBER(3,0), "NAZWA_JEZYKA" VARCHAR2(50 BYTE), "KOL_DEF_C" NUMBER(3,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table JEZ_OPIS_POZ
--------------------------------------------------------

  CREATE TABLE "JEZ_OPIS_POZ" ("NK_ZLEC" NUMBER(10,0), "NR_POZ" NUMBER(3,0), "NR_JEZ" NUMBER(2,0), "OPIS" VARCHAR2(1000 BYTE)) ;
--------------------------------------------------------
--  DDL for Table JEZYKI_WYDR_KONF
--------------------------------------------------------

  CREATE TABLE "JEZYKI_WYDR_KONF" ("FONT_OFFSET" NUMBER(3,0), "LICZBA_CZCIONEK" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table KALINST
--------------------------------------------------------

  CREATE TABLE "KALINST" ("NR_KOMP_INST" NUMBER(10,0), "DZIEN" DATE, "POCZATEK" NUMBER(10,0), "KONIEC" NUMBER(10,0), "WIELK_PLAN" NUMBER(18,2), "IL_PLAN" NUMBER(16,0), "WIEL_WYK" NUMBER(18,2), "IL_WYK" NUMBER(16,0), "P_PLAN" NUMBER(12,2), "P_WYK" NUMBER(12,2)) ;
--------------------------------------------------------
--  DDL for Table KARTOTEKA
--------------------------------------------------------

  CREATE TABLE "KARTOTEKA" ("INDEKS" VARCHAR2(128 BYTE), "NAZWA" VARCHAR2(255 BYTE), "NR_KAT" NUMBER(4,0), "RODZ_SUR" VARCHAR2(3 BYTE), "PKWIU" VARCHAR2(18 BYTE), "SZER" NUMBER(4,0), "WYS" NUMBER(4,0), "GRUB" NUMBER(6,3), "POW" NUMBER(8,3), "JED_POD" VARCHAR2(5 BYTE), "ST_BIEZ" NUMBER(14,6), "ILOSC" NUMBER(14,6), "ZAPAS" NUMBER(14,6), "REZERACJA" NUMBER(14,6), "CENA_ZAK" NUMBER(14,4), "CENA_SR" NUMBER(14,4), "CENA_HURT" NUMBER(14,4), "CENA_POLH" NUMBER(14,4), "CENA_DET" NUMBER(14,4), "NR_MAG" NUMBER(3,0), "NR_ANAL" NUMBER(3,0), "GR_TOW" VARCHAR2(3 BYTE), "R_DOL" NUMBER(4,0), "R_TYL" NUMBER(4,0), "R_GORA" NUMBER(4,0), "R_PRZOD" NUMBER(4,0), "F_ZLICZ" NUMBER(2,0), "NAZ_VAT" VARCHAR2(5 BYTE), "MARZA" NUMBER(6,3), "ZN_KART" VARCHAR2(3 BYTE), "NR_ODZ" NUMBER(2,0), "SUMA_DOSTAW" NUMBER(14,6), "CENA_ZA_SZT" NUMBER(14,4), "CENA_MIN" NUMBER(14,4), "NR_KOMP_GR" NUMBER(10,0), "WSP_X" VARCHAR2(10 BYTE), "WSP_Y" VARCHAR2(10 BYTE), "WSP_Z" VARCHAR2(10 BYTE), "KOD_UE" VARCHAR2(9 BYTE), "KOLOR" VARCHAR2(10 BYTE), "FLAG_REZ" NUMBER(2,0) DEFAULT 0, "FLAG_AKT" NUMBER(1,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table KASA
--------------------------------------------------------

  CREATE TABLE "KASA" ("NR_ZAPISU" NUMBER(10,0), "TYP_ZAP" NUMBER(1,0), "DATA" DATE, "GODZ" CHAR(6 BYTE), "OPERATOR" VARCHAR2(30 BYTE), "TYP_DOK" VARCHAR2(3 BYTE), "NR_DOK" NUMBER(10,0), "KWOTA" NUMBER(17,2), "NR_DOK_KAS" NUMBER(10,0), "TYP_DOK_KAS" VARCHAR2(2 BYTE), "NR_KONTR" NUMBER(10,0), "NAZWA_SKROCONA_KONTRAHENTA" VARCHAR2(15 BYTE)) ;
--------------------------------------------------------
--  DDL for Table KASA_DOK
--------------------------------------------------------

  CREATE TABLE "KASA_DOK" ("TYP_DOK" VARCHAR2(2 BYTE), "NR_DOK" NUMBER(10,0), "DATA_DOK" DATE, "OSOBA" VARCHAR2(50 BYTE), "ADRES" VARCHAR2(100 BYTE), "TYTUL" VARCHAR2(100 BYTE), "KWOTA" NUMBER(17,2), "OPERATOR" VARCHAR2(30 BYTE), "NAZ_OP" VARCHAR2(50 BYTE), "CZAS_DOK" CHAR(6 BYTE) DEFAULT '') ;
--------------------------------------------------------
--  DDL for Table KATALOG
--------------------------------------------------------

  CREATE TABLE "KATALOG" ("NR_KAT" NUMBER(4,0), "TYP_KAT" VARCHAR2(9 BYTE), "RODZ_SUR" VARCHAR2(3 BYTE), "NAZ_KAT" VARCHAR2(50 BYTE), "JED_POD" VARCHAR2(5 BYTE), "WAGA" NUMBER(10,3), "ZN_ZESP" VARCHAR2(6 BYTE), "WSP_C_M" NUMBER(6,3), "N_STRAT" NUMBER(5,2), "M_LAM_GR" NUMBER(6,3), "BOK_OD" NUMBER(7,3), "POW_ODZ" NUMBER(7,3), "STOS_B" NUMBER(5,2), "TYP_INST1" VARCHAR2(3 BYTE), "WSP_HAR" NUMBER(5,2), "ZNACZ_PR" VARCHAR2(4 BYTE), "KART_ODZ" VARCHAR2(255 BYTE), "KART_DOM" VARCHAR2(128 BYTE), "GR_TOW" VARCHAR2(3 BYTE), "NR_MAG" NUMBER(3,0), "CENA" NUMBER(14,4), "GRUBOSC" NUMBER(6,3), "NR_MAG_ODZ" NUMBER(3,0), "NR_KOM_KAT" NUMBER(10,0), "NAZ_HAND" VARCHAR2(20 BYTE), "NR_INST" NUMBER(3,0), "NR_KOMP_GR" NUMBER(10,0), "GR_KOSZT_TOW" NUMBER(10,0), "STRAT_CEN" NUMBER(5,2), "G_SZER" NUMBER(4,0), "G_WYS" NUMBER(4,0), "POWLOKA" NUMBER(2,0), "NR_TLUM" NUMBER(10,0) DEFAULT 0, "NK_OBR" NUMBER(10,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table KATEG_INFO
--------------------------------------------------------

  CREATE TABLE "KATEG_INFO" ("NR_KOMP_ZLEC" NUMBER(10,0), "NR_KATEG" NUMBER(10,0), "ILOSC_SZT_P" NUMBER(10,0), "ILE_M2_PL" NUMBER(14,4), "ILOSC_SZT_WYK" NUMBER(10,0), "ILE_M2_WYK" NUMBER(14,4)) ;
--------------------------------------------------------
--  DDL for Table KATEGORIE
--------------------------------------------------------

  CREATE TABLE "KATEGORIE" ("NR_K_KAT" NUMBER(10,0), "SKROT" VARCHAR2(15 BYTE), "OPIS_NA_WYDR" VARCHAR2(50 BYTE), "ILE_CECH" NUMBER(3,0), "FLAGA_PP_1" NUMBER(1,0), "FLAGA_PP_2" NUMBER(1,0), "FLAGA_PP_3" NUMBER(1,0), "WYZN_1" VARCHAR2(1 BYTE), "WYZN_2" VARCHAR2(1 BYTE), "WYZN_3" VARCHAR2(1 BYTE), "PARAM_1" NUMBER(6,0), "PARAM_2" NUMBER(6,0), "PARAM_3" NUMBER(6,0), "NR_K_1" NUMBER(10,0), "NR_K_2" NUMBER(10,0), "NR_K_3" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table KATEG_PAR
--------------------------------------------------------

  CREATE TABLE "KATEG_PAR" ("NR_K_KAT" NUMBER(10,0), "NR_PARAM" NUMBER(4,0), "CZY_ATRYBUT" NUMBER(1,0), "MASKA_ATRYBUTOW" VARCHAR2(50 BYTE), "WAR_ATRYB_LOG" NUMBER(2,0), "CZY_WYMIA" NUMBER(1,0), "WYMIAR_MIN" NUMBER(10,4), "WYMIAR_MAX" NUMBER(10,4), "CZY_SLOWNIK" NUMBER(1,0), "NR_ZB_SLOWNIKOWEGO" NUMBER(5,0), "CZY_OBROBKA" NUMBER(1,0), "NR_KOMP_OBROBKI" NUMBER(10,0), "CZY_TYP_KATALOG" NUMBER(1,0), "NR_TYPU_KATALOG" NUMBER(8,0), "CZY_MASKA_KALOG" NUMBER(1,0), "MASKA_TYPU_KATALOG" VARCHAR2(9 BYTE), "CZY_INSTAL" NUMBER(1,0), "NR_INSTAL" NUMBER(10,0), "CZY_RODZAJ" NUMBER(1,0), "RODZAJ_WYROBU" VARCHAR2(4 BYTE), "CZY_ILOSC_POZ" NUMBER(1,0), "ILOSC_GRANICZNA_POZ" NUMBER(6,0), "CZY_ILOSC_ZLEC" NUMBER(1,0), "ILOSC_GRANICZNA_ZLEC" NUMBER(6,0), "CZY_GR_TOWAR" NUMBER(1,0), "GRUPA_TOWAR" VARCHAR2(3 BYTE), "WARUNEK_CD" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table KATEG_WYM_O
--------------------------------------------------------

  CREATE TABLE "KATEG_WYM_O" ("KOD_KAT" VARCHAR2(20 BYTE), "PRI" NUMBER(6,0), "SZER" NUMBER(6,0), "WYS" NUMBER(6,0), "KOD_ST" VARCHAR2(20 BYTE), "NK_WYM" NUMBER(10,0), "FLAG" NUMBER(1,0), "AKT" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table KAT_GR_PLAN
--------------------------------------------------------

  CREATE TABLE "KAT_GR_PLAN" ("TYP_KAT" VARCHAR2(9 BYTE), "NKOMP_GRUPY" NUMBER(10,0), "NKOMP_INSTALACJI" NUMBER(10,0), "NR_KOMP_OBR" NUMBER(10,0), "NR_KAT" NUMBER(4,0)) ;
--------------------------------------------------------
--  DDL for Table KLIENT
--------------------------------------------------------

  CREATE TABLE "KLIENT" ("NR_KON" NUMBER(10,0), "GR_DOK" CHAR(3 BYTE), "RODZ_KON" CHAR(3 BYTE), "NAZ_KON" VARCHAR2(50 BYTE), "SKROT_K" VARCHAR2(15 BYTE), "KOD_POCZ" VARCHAR2(10 BYTE), "MIASTO" VARCHAR2(30 BYTE), "ADRES" VARCHAR2(31 BYTE), "PANSTWO" VARCHAR2(20 BYTE), "POWIAT" VARCHAR2(20 BYTE), "WOJEW" VARCHAR2(20 BYTE), "TEL" VARCHAR2(19 BYTE), "FAX" VARCHAR2(19 BYTE), "MAIL" VARCHAR2(128 BYTE), "REGON" VARCHAR2(20 BYTE), "NIP" VARCHAR2(20 BYTE), "NR_RACH" VARCHAR2(40 BYTE), "NR_BANKU" NUMBER(8,0), "LIMIT_K" NUMBER(16,2), "IL_D_KRED" NUMBER(3,0), "DLUG" NUMBER(16,2), "TERMIN_P" NUMBER(3,0), "ODB_FAKT" CHAR(2 BYTE), "NR_OS_VAT" VARCHAR2(15 BYTE), "RODZ_OS" CHAR(2 BYTE), "D_OSW" DATE, "D_WAZ_VAT" DATE, "POZ_CEN" CHAR(3 BYTE), "WAR_KOR" NUMBER(3,0), "WYS_KOR" NUMBER(5,2), "GOT_KRED" CHAR(2 BYTE), "WAR_PLAT" CHAR(2 BYTE), "NR_PLAT" NUMBER(10,0), "PLAT_VAT" CHAR(1 BYTE), "RABAT" NUMBER(5,2), "NR_ODDZ" NUMBER(2,0), "TYP_IFS" VARCHAR2(10 BYTE) DEFAULT 'KRI', "STATUS" NUMBER(1,0), "STAT_ZAK" NUMBER(1,0), "STOPA_CL" NUMBER(8,2), "NIP_UE" VARCHAR2(15 BYTE), "CZY_UE" NUMBER(2,0), "NIP_MASKA" VARCHAR2(15 BYTE), "STATUS_PLAN" NUMBER(2,0), "TEL_KOM1" VARCHAR2(19 BYTE), "OS_KONTAK1" VARCHAR2(128 BYTE), "TEL_KOM2" VARCHAR2(19 BYTE), "OS_KONTAK2" VARCHAR2(128 BYTE), "UWAGI" VARCHAR2(255 BYTE), "NAZ_RAM" VARCHAR2(40 BYTE) DEFAULT '') ;
--------------------------------------------------------
--  DDL for Table KLUCZE
--------------------------------------------------------

  CREATE TABLE "KLUCZE" ("NAZWA" VARCHAR2(31 BYTE), "KLUCZ" VARCHAR2(10 BYTE), "APLIKACJA" VARCHAR2(20 BYTE), "OPIS" VARCHAR2(200 BYTE), "NUMER_KLUCZA" NUMBER(10,0), "OPIS_LANG" VARCHAR2(200 BYTE) DEFAULT '') ;
--------------------------------------------------------
--  DDL for Table KOD_JH
--------------------------------------------------------

  CREATE TABLE "KOD_JH" ("TYP" VARCHAR2(1 BYTE), "KOD" VARCHAR2(8 BYTE), "OPIS" VARCHAR2(50 BYTE), "KOMENTARZ" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table KODSTER
--------------------------------------------------------

  CREATE TABLE "KODSTER" ("NR_KODU" NUMBER(4,0), "ZNAK_KODU" VARCHAR2(12 BYTE), "OPIS_KODU" VARCHAR2(80 BYTE)) ;
--------------------------------------------------------
--  DDL for Table KODY_GRUB
--------------------------------------------------------

  CREATE TABLE "KODY_GRUB" ("KOD" VARCHAR2(2 BYTE), "DLUGOSC" VARCHAR2(4 BYTE), "SZEROKOSC" VARCHAR2(4 BYTE)) ;
--------------------------------------------------------
--  DDL for Table KODY_NAL
--------------------------------------------------------

  CREATE TABLE "KODY_NAL" ("KOD_WZORU" VARCHAR2(40 BYTE), "NR_WZORU" NUMBER(4,0), "NR_KLIENTA" NUMBER(10,0), "JEZYK" NUMBER(4,0), "TYP" NUMBER(4,0), "KOLOR" NUMBER(4,0), "NR_WZORUB" NUMBER(4,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table KODY_NAZW
--------------------------------------------------------

  CREATE TABLE "KODY_NAZW" ("NUMER" NUMBER(3,0), "NR_PODT" NUMBER(2,0), "NR_POZ_W_KOD" NUMBER(1,0), "OPIS" VARCHAR2(80 BYTE), "KOD" VARCHAR2(1 BYTE), "KOD_NUMEROWY" VARCHAR2(2 BYTE), "NAZWA" VARCHAR2(20 BYTE)) ;
--------------------------------------------------------
--  DDL for Table KODYPOL
--------------------------------------------------------

  CREATE TABLE "KODYPOL" ("NR_KODU" NUMBER(4,0), "SYMBOL_KODU" VARCHAR2(12 BYTE), "OPIS_POLA" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table KOL_STOJAKOW
--------------------------------------------------------

  CREATE TABLE "KOL_STOJAKOW" ("NR_LISTY" NUMBER(10,0), "TYP_KATALOG" VARCHAR2(128 BYTE), "NR_KATALOG" NUMBER(6,0), "NR_KOMP_ZLEC" NUMBER(10,0), "NR_POZ" NUMBER(6,0), "NR_SZTUKI" NUMBER(6,0), "NR_WARSTWY" NUMBER(4,0), "NR_STOJ_CIECIA" NUMBER(10,0) DEFAULT 0, "POZ_STOJAKA_CIECIA" NUMBER(4,0), "POZ_STOJAKA_DOCEL" NUMBER(4,0), "SERIALNO" NUMBER(12,0), "RACK_NO" NUMBER(8,0), "NR_PODGRUPY" NUMBER(6,0), "NR_INSTALACJI" NUMBER(8,0), "NR_OPTYM" NUMBER(8,0), "NR_TAF" NUMBER(8,0), "NR_GRUPY" NUMBER(8,0), "LISTA_INST" VARCHAR2(50 BYTE), "SYMBOL" VARCHAR2(32 BYTE)) ;
--------------------------------------------------------
--  DDL for Table KOM
--------------------------------------------------------

  CREATE TABLE "KOM" ("NR_ZAP" NUMBER(10,0), "RODZ" NUMBER(4,0), "OPER" VARCHAR2(50 BYTE), "NKOMP" NUMBER(10,0), "KOM" VARCHAR2(300 BYTE), "PAR" VARCHAR2(300 BYTE), "DATA" DATE, "CZAS" CHAR(6 BYTE), "OP" VARCHAR2(20 BYTE), "ODD" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table KOM_ADRES
--------------------------------------------------------

  CREATE TABLE "KOM_ADRES" ("NR_SPED" NUMBER(10,0), "NR_ADR" NUMBER(10,0), "NR_KONTR" NUMBER(10,0), "KOD_POCZTOWY" VARCHAR2(10 BYTE), "MIASTO" VARCHAR2(30 BYTE), "ADRES" VARCHAR2(31 BYTE), "PANSTWO" VARCHAR2(20 BYTE), "DL_TRASY" NUMBER(5,0), "ODL_OD_TRASY" NUMBER(5,0), "DATA" DATE, "CZAS" CHAR(6 BYTE)) ;
--------------------------------------------------------
--  DDL for Table KOM_OPIS
--------------------------------------------------------

  CREATE TABLE "KOM_OPIS" ("NR_SPED" NUMBER(10,0), "OPIS" VARCHAR2(200 BYTE)) ;
--------------------------------------------------------
--  DDL for Table KOM_STOJ
--------------------------------------------------------

  CREATE TABLE "KOM_STOJ" ("NR_SPED" NUMBER(10,0), "NR_STOJ" NUMBER(10,0), "ILOSC_SZT" NUMBER(10,0), "WAGA" NUMBER(17,3), "NR_OBCY" CHAR(20 BYTE) DEFAULT '', "KONTRAHENT" NUMBER(10,0) DEFAULT 0, "SUMA_POW" NUMBER(14,4) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table KOM_ZLE
--------------------------------------------------------

  CREATE TABLE "KOM_ZLE" ("NR_SPED" NUMBER(10,0), "NR_ZLEC" NUMBER(6,0), "NR_KOMP_ZLEC" NUMBER(10,0), "NR_KONTR" NUMBER(10,0), "ILOSC_SZT" NUMBER(10,0), "WAGA" NUMBER(17,3)) ;
--------------------------------------------------------
--  DDL for Table KONFDOK
--------------------------------------------------------

  CREATE TABLE "KONFDOK" ("GR_DOK" CHAR(3 BYTE), "TYP_DOK" CHAR(3 BYTE), "TYTUL" CHAR(30 BYTE), "GDZIE_ROK" VARCHAR2(4 BYTE), "ZNAK_ROK" CHAR(2 BYTE), "GDZIE_MIES" VARCHAR2(4 BYTE), "ZNAK_MIES" VARCHAR2(1 BYTE), "GDZIE_INNE" VARCHAR2(4 BYTE), "INNE" VARCHAR2(8 BYTE), "POLA_FORMY" VARCHAR2(100 BYTE), "POLA_WYDR" VARCHAR2(100 BYTE), "CZY_SKROT" VARCHAR2(100 BYTE), "POLA_POZ" VARCHAR2(100 BYTE), "NR_NAGL" NUMBER(3,0), "OSTAT_NR" RAW(10), "SPOSOB_NUM" VARCHAR2(2 BYTE), "CZY_W_BIL" NUMBER(2,0), "NR_W_BIL_ZB" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table KONF_DOK_ZAK
--------------------------------------------------------

  CREATE TABLE "KONF_DOK_ZAK" ("GR_DOK" VARCHAR2(3 BYTE), "TYP_DOK" VARCHAR2(3 BYTE), "TYTUL" VARCHAR2(30 BYTE), "GDZIE_ROK" VARCHAR2(4 BYTE), "ZNAK_ROK" VARCHAR2(1 BYTE), "GDZIE_MIES" VARCHAR2(4 BYTE), "ZNAK_MIES" VARCHAR2(1 BYTE), "GDZIE_INNE" VARCHAR2(4 BYTE), "INNE" VARCHAR2(5 BYTE), "POLA_FORMY" VARCHAR2(100 BYTE), "POLA_WYDR" VARCHAR2(100 BYTE), "CZY_SKROT" VARCHAR2(100 BYTE), "POLA_POZ" VARCHAR2(100 BYTE), "NR_NAGL" NUMBER(3,0), "OSTAT_NR" NUMBER(10,0), "SPOSOB_NUM" VARCHAR2(2 BYTE), "CZY_W_BIL" NUMBER(2,0), "NR_W_BIL_ZB" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table KONF_DRUK_PL
--------------------------------------------------------

  CREATE TABLE "KONF_DRUK_PL" ("NE_INST" NUMBER(10,0), "NAZWA_INST" VARCHAR2(60 BYTE), "CZY_DRUK" NUMBER(1,0), "ILE_KOPII" NUMBER(3,0), "NR_KONFIG" NUMBER(2,0) DEFAULT 0, "NAZWA_KONFIG" VARCHAR2(60 BYTE) DEFAULT '', "NR_WZ1" NUMBER(4,0) DEFAULT 1, "NR_WZ2" NUMBER(4,0) DEFAULT 1, "NR_WZ3" NUMBER(4,0) DEFAULT 1) ;
--------------------------------------------------------
--  DDL for Table KONFIG_SEKWENCJI
--------------------------------------------------------

  CREATE TABLE "KONFIG_SEKWENCJI" ("NR_SEKWENCJI" NUMBER(6,0), "NAZWA_SEKWENCJI" VARCHAR2(100 BYTE), "NR_W_KOLEJNOSCI" NUMBER(4,0), "KOD_OPERACJI" VARCHAR2(12 BYTE), "TYP_OPERACJI" VARCHAR2(4 BYTE), "NAZWA_APLIKACJI" VARCHAR2(50 BYTE), "NAZWA_PROGRAMU" VARCHAR2(50 BYTE), "NR_ZADANIA_PROGRAMY" NUMBER(6,0), "WYKONUJ_BEZ_EKRANU" NUMBER(1,0), "SEK_AKTYWNA" NUMBER(1,0), "OPER_AKTYWNA" NUMBER(1,0), "SCIEZKA" VARCHAR2(200 BYTE), "ILE_PARAM" NUMBER(4,0)) ;
--------------------------------------------------------
--  DDL for Table KONFIG_T
--------------------------------------------------------

  CREATE TABLE "KONFIG_T" ("NR_PAR" NUMBER(4,0), "OST_NR" NUMBER(10,0), "OPIS" VARCHAR2(100 BYTE), "OPIS_LANG" VARCHAR2(100 BYTE) DEFAULT '') ;
--------------------------------------------------------
--  DDL for Table KONFIGWYDR
--------------------------------------------------------

  CREATE TABLE "KONFIGWYDR" ("NR_KONFW" NUMBER(6,0), "NAZ_KONFW" VARCHAR2(64 BYTE), "PAR_KONFW" VARCHAR2(60 BYTE)) ;
--------------------------------------------------------
--  DDL for Table KON_FK
--------------------------------------------------------

  CREATE TABLE "KON_FK" ("NIP" VARCHAR2(13 BYTE), "SALDO" NUMBER(17,2), "PRZETER" NUMBER(17,2), "NIEPRZETER" NUMBER(17,2), "P30" NUMBER(17,2), "P31_60" NUMBER(17,2), "P61_90" NUMBER(17,2), "P91" NUMBER(17,2)) ;
--------------------------------------------------------
--  DDL for Table KONTA_FK
--------------------------------------------------------

  CREATE TABLE "KONTA_FK" ("TYP_ZAPISU" NUMBER(2,0), "KONTO" VARCHAR2(20 BYTE), "OPIS" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table KONTOSOB
--------------------------------------------------------

  CREATE TABLE "KONTOSOB" ("TYPKONT" NUMBER(4,0), "NRKOMKON" NUMBER(10,0), "NRKONTR" NUMBER(10,0), "NRKOLKONTR" NUMBER(4,0), "NAZ" VARCHAR2(30 BYTE), "IMIE" VARCHAR2(30 BYTE), "STANOW" VARCHAR2(30 BYTE), "TEL_SL" VARCHAR2(20 BYTE), "TEL_OS" VARCHAR2(20 BYTE), "TEL_KOM" VARCHAR2(20 BYTE), "EMAIL" VARCHAR2(100 BYTE), "NICK" VARCHAR2(30 BYTE), "UWAGI" VARCHAR2(150 BYTE)) ;
--------------------------------------------------------
--  DDL for Table KONTRAKT
--------------------------------------------------------

  CREATE TABLE "KONTRAKT" ("NR_KOMP_KONTR" NUMBER(10,0), "GR_DOK" CHAR(3 BYTE), "NR_KONTR" VARCHAR2(19 BYTE) DEFAULT '', "NR_KON" NUMBER(10,0), "DATA_POCZ" DATE, "DATA_ZAK" DATE, "RABAT" NUMBER(5,2), "NR_DOST" NUMBER(10,0), "NR_OP_WPR" VARCHAR2(10 BYTE), "DATA_WPR" DATE, "NR_OP_MOD" VARCHAR2(10 BYTE), "DATA_MOD" DATE, "OS_ODPOW" VARCHAR2(35 BYTE), "PRZEDSTA_KON" VARCHAR2(35 BYTE), "GOT_KRED" CHAR(2 BYTE), "WAR_PLAT" CHAR(2 BYTE), "IL_D_KRED" NUMBER(3,0), "LIMIT_K" NUMBER(16,2), "LIMIT_WYK" NUMBER(16,2), "SUMA_ZAPL" NUMBER(16,2), "WART_PLAN" NUMBER(16,2), "WART_ZREAL" NUMBER(16,2), "CZAS_REAL" NUMBER(3,0), "RODZ_KARY" CHAR(3 BYTE), "KARA_UM" NUMBER(14,4), "RODZ_ODSET" CHAR(3 BYTE), "WYS_ODSET" NUMBER(12,6), "TERM_1_DOST" DATE, "NAST_DOST_CO" NUMBER(3,0), "NAZ_OBIEKTU" CHAR(30 BYTE), "RODZ_OBIEKTU" CHAR(30 BYTE), "NAZ_INWEST" CHAR(30 BYTE), "GENER_WYK" CHAR(30 BYTE), "ARCHITEKT" CHAR(30 BYTE), "ZATWIERDZ" VARCHAR2(2 BYTE), "STATUS" NUMBER(2,0), "WALUTA" VARCHAR2(4 BYTE), "DATA_ZATW" DATE, "NR_OP_ZATW" VARCHAR2(10 BYTE), "OS_ZATW" VARCHAR2(35 BYTE), "NR_ODDZ" NUMBER(2,0), "TERM_GWAR" NUMBER(4,0), "KURS" NUMBER(14,4), "DATA_KURSU" DATE, "KATEGORIA" VARCHAR2(30 BYTE), "PRZESZKLENIE" VARCHAR2(30 BYTE), "WARUNKI" VARCHAR2(40 BYTE), "IL_ZATW" NUMBER(10,0), "WSP_KURSU1" NUMBER(5,2) DEFAULT 0, "WSP_KURSU2" NUMBER(5,2) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table KONTR_OBR
--------------------------------------------------------

  CREATE TABLE "KONTR_OBR" ("NK_KNTR" NUMBER(10,0), "NK_OBR_OBR" NUMBER(10,0), "GRUB" NUMBER(6,3), "CENA" NUMBER(14,4), "RODZ_CENY" VARCHAR2(4 BYTE), "POPRAWKI" NUMBER(1,0), "DATA_ZATW" DATE, "OP_ZATW" VARCHAR2(10 BYTE), "POZ_ZATW" NUMBER(2,0), "KOL_WYDR" NUMBER(4,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table KONTR_PAM
--------------------------------------------------------

  CREATE TABLE "KONTR_PAM" ("NK_KONTR" NUMBER(10,0), "FUN" NUMBER(2,0), "NK_OP" NUMBER(10,0), "DATA" DATE, "CZAS" CHAR(6 BYTE)) ;
--------------------------------------------------------
--  DDL for Table KON_UPR
--------------------------------------------------------

  CREATE TABLE "KON_UPR" ("NR_KLUCZA" NUMBER(10,0), "NAZ_KLUCZA" VARCHAR2(40 BYTE), "DO_KWOTY" NUMBER(12,0), "OPIS" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table KON_UWAGI_CENT
--------------------------------------------------------

  CREATE TABLE "KON_UWAGI_CENT" ("NR_KONTR" NUMBER(10,0), "UWAGI" VARCHAR2(300 BYTE)) ;
--------------------------------------------------------
--  DDL for Table KON_UWAGI_ODD
--------------------------------------------------------

  CREATE TABLE "KON_UWAGI_ODD" ("NR_KONTR" NUMBER(10,0), "UWAGI" VARCHAR2(300 BYTE)) ;
--------------------------------------------------------
--  DDL for Table KOPHARMON
--------------------------------------------------------

  CREATE TABLE "KOPHARMON" ("NR_INST" NUMBER(3,0), "DZIEN" DATE, "ZMIANA" NUMBER(1,0), "NR_KOMP_ZLEC" NUMBER(10,0), "TYP_HARM" CHAR(1 BYTE), "ILOSC" NUMBER(14,0), "WIELKOSC" NUMBER(14,2), "NR_KOMP_INST" NUMBER(10,0), "TYP_INST" CHAR(3 BYTE), "NR_ODDZ" NUMBER(2,0), "ROK" NUMBER(4,0), "MIES" NUMBER(2,0), "IL_Z_ZAM" NUMBER(14,0), "DANE_Z_ZAM" NUMBER(14,2), "ZATWIERDZ" NUMBER(1,0), "GODZ_POCZ" CHAR(6 BYTE), "GODZ_KON" CHAR(6 BYTE), "KOL_NA_ZM" NUMBER(5,0), "NR_KOMP_ZM" NUMBER(10,0), "DATA_KOPII" DATE, "CZAS_KOPII" CHAR(6 BYTE)) ;
--------------------------------------------------------
--  DDL for Table KOPSPISP
--------------------------------------------------------

  CREATE TABLE "KOPSPISP" ("NUMER_KOMPUTEROWY_ZLECENIA" NUMBER(10,0), "NR_POZ" NUMBER(3,0), "IL_PLAN" NUMBER(4,0), "DATA_PLAN" DATE, "ZM_PLAN" NUMBER(10,0), "CZAS_PLAN" NUMBER(10,0), "IL_WYK" NUMBER(4,0), "DATA_WYK" DATE, "ZM_WYK" NUMBER(10,0), "CZAS_WYK" NUMBER(10,0), "NR_KOM_INST" NUMBER(10,0), "NR_ODDZ" NUMBER(2,0), "DATA_KOPII" DATE, "CZAS_KOPII" CHAR(6 BYTE)) ;
--------------------------------------------------------
--  DDL for Table KOPWYKZAL
--------------------------------------------------------

  CREATE TABLE "KOPWYKZAL" ("NR_KOMP_ZLEC" NUMBER(10,0), "NR_KOMP_INSTAL" NUMBER(10,0), "NR_KOMP_ZM" NUMBER(10,0), "NR_POZ" NUMBER(3,0), "IL_WYK" NUMBER(14,0), "NR_OPER" VARCHAR2(10 BYTE), "INDEKS" VARCHAR2(50 BYTE), "IL_ZLEC_WYK" NUMBER(14,6), "D_WYK" DATE, "ZM_WYK" NUMBER(1,0), "FLAG" NUMBER(1,0), "D_PLAN" DATE, "ZM_PLAN" NUMBER(1,0), "NR_ZM_PLAN" NUMBER(10,0), "WSP_PRZEL" NUMBER(7,4), "IL_PLAN" NUMBER(14,0), "IL_ZLEC_PLAN" NUMBER(14,6), "IL_CALK" NUMBER(14,0), "IL_JEDN" NUMBER(14,6), "STRATY" NUMBER(13,3), "DATA_KOPII" DATE, "CZAS_KOPII" CHAR(6 BYTE)) ;
--------------------------------------------------------
--  DDL for Table KOSZT_ST
--------------------------------------------------------

  CREATE TABLE "KOSZT_ST" ("NR_GR" NUMBER(10,0), "NR_OKRESU" NUMBER(4,0), "DATA_P" DATE, "DATA_K" DATE, "KOSZT_ST" NUMBER(14,4), "ODCHYLKA" NUMBER(14,4), "DATA_W" DATE, "OP_WPR" VARCHAR2(10 BYTE), "DATA_MK" DATE, "OP_MOD" VARCHAR2(10 BYTE), "CENA_OF" NUMBER(14,4), "PRZYCH_ST" NUMBER(14,4)) ;
--------------------------------------------------------
--  DDL for Table KP_KON
--------------------------------------------------------

  CREATE TABLE "KP_KON" ("NK_PRZEC" NUMBER(10,0), "NK_KONTR" NUMBER(10,0), "WSK" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table KP_OBR
--------------------------------------------------------

  CREATE TABLE "KP_OBR" ("NK_PRZEC" NUMBER(10,0), "NK_OBR" NUMBER(10,0), "GR" NUMBER(6,3), "WSK" NUMBER(1,0), "PRZEC" VARCHAR2(1 BYTE), "WART" NUMBER(7,2)) ;
--------------------------------------------------------
--  DDL for Table KP_PRZEC
--------------------------------------------------------

  CREATE TABLE "KP_PRZEC" ("NK_PRZEC" NUMBER(10,0), "OPIS_PRZEC" VARCHAR2(100 BYTE), "WSK_KONTR" NUMBER(1,0), "KONTR_OD" NUMBER(10,0), "KONTR_DO" NUMBER(10,0), "WSK_KONTR1" NUMBER(1,0), "KONTRAHENT_OD" NUMBER(10,0), "KONTRAHENT_DO" NUMBER(10,0), "WSK_WALUTA" NUMBER(1,0), "WALUTA_SYMBOL" VARCHAR2(4 BYTE), "WSK_DATA" NUMBER(1,0), "DATA_OD" DATE, "DATA_DO" DATE, "STR_PRZEC" NUMBER(1,0), "STR_PRZEC_TYP" VARCHAR2(1 BYTE), "STR_PRZEC_WART" NUMBER(7,2), "WSK_STR" NUMBER(1,0), "OBR_PRZEC" NUMBER(1,0), "OBR_PRZEC_TYP" VARCHAR2(1 BYTE), "OBR_PRZEC_WART" NUMBER(14,4), "WSK_OBR" NUMBER(1,0), "DATA_MOD" DATE, "CZAS_MOD" CHAR(6 BYTE), "ODD_MOD" NUMBER(2,0), "OP_MOD" NUMBER(10,0), "ST_WYDR" NUMBER(2,0), "DOKL" NUMBER(1,0), "PRZES" NUMBER(3,0)) ;
--------------------------------------------------------
--  DDL for Table KP_ROB
--------------------------------------------------------

  CREATE TABLE "KP_ROB" ("NK_PRZEC" NUMBER(10,0), "NK_KONTR" NUMBER(10,0), "WSK" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table KP_STR
--------------------------------------------------------

  CREATE TABLE "KP_STR" ("NK_PRZEC" NUMBER(10,0), "TYP_W" VARCHAR2(2 BYTE), "INDEKS" VARCHAR2(128 BYTE), "WSK" NUMBER(1,0), "PRZEC" VARCHAR2(1 BYTE), "WARTOSC" NUMBER(7,2)) ;
--------------------------------------------------------
--  DDL for Table KP_WYB
--------------------------------------------------------

  CREATE TABLE "KP_WYB" ("NK_PRZEC" NUMBER(10,0), "NK_KONTR" NUMBER(10,0), "WSK" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table KRAJ
--------------------------------------------------------

  CREATE TABLE "KRAJ" ("SKROT_K" VARCHAR2(3 BYTE), "PANSTWO" VARCHAR2(20 BYTE), "NAZWA" VARCHAR2(30 BYTE), "WALUTA" VARCHAR2(5 BYTE), "WSP_PRZEL" NUMBER(5,0), "KOD_UE" CHAR(2 BYTE) DEFAULT '', "CZY_UE" NUMBER(1,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table KRAJ_TRANS
--------------------------------------------------------

  CREATE TABLE "KRAJ_TRANS" ("NAZWA_KRAJU_1" VARCHAR2(50 BYTE), "NAZWA_KRAJU_2" VARCHAR2(50 BYTE), "NAZWA_KRAJU_3" VARCHAR2(50 BYTE), "NAZWA_KRAJU_4" VARCHAR2(50 BYTE), "NAZWA_KRAJU_5" VARCHAR2(50 BYTE), "NAZWA_KRAJU_6" VARCHAR2(50 BYTE), "NAZWA_KRAJU_7" VARCHAR2(50 BYTE), "NAZWA_KRAJU_8" VARCHAR2(50 BYTE), "NAZWA_KRAJU_9" VARCHAR2(50 BYTE), "NAZWA_KRAJU_10" VARCHAR2(50 BYTE)) ;
--------------------------------------------------------
--  DDL for Table KSZT_DOP
--------------------------------------------------------

  CREATE TABLE "KSZT_DOP" ("NUMER_KOMPUTEROWY" NUMBER(10,0), "NR_KSZT" NUMBER(3,0), "ZNACZNIK_PRODUKTU" VARCHAR2(4 BYTE), "NR_NAP" NUMBER(10,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table KSZT_DOP1
--------------------------------------------------------

  CREATE TABLE "KSZT_DOP1" ("NR_KAT_KSZTALTOW" NUMBER(10,0), "NR_KSZTALTU" NUMBER(3,0), "NR_DOPLATY" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table KTH_N
--------------------------------------------------------

  CREATE TABLE "KTH_N" ("AXS_TPS" VARCHAR2(1 BYTE), "KH_KOD" VARCHAR2(6 BYTE), "KH_NAZWA" VARCHAR2(30 BYTE), "KH_ADRES_1" VARCHAR2(30 BYTE), "KH_ADRES_2" VARCHAR2(30 BYTE), "KH_ADRES_3" VARCHAR2(30 BYTE), "KH_ADRES_4" VARCHAR2(30 BYTE), "KH_ADRES_5" VARCHAR2(30 BYTE), "KH_MIASTO" VARCHAR2(10 BYTE), "KH_PANSTWO" VARCHAR2(12 BYTE), "KH_NIP" VARCHAR2(13 BYTE), "KH_REGON" VARCHAR2(9 BYTE), "KH_VAT" NUMBER(1,0), "KH_BANK_1" VARCHAR2(70 BYTE), "KH_BANK_2" VARCHAR2(70 BYTE), "KH_BANK_3" VARCHAR2(70 BYTE), "KH_BANK_4" VARCHAR2(70 BYTE), "KH_UPUST" NUMBER(4,1), "KH_TERMIN" NUMBER(4,1), "KH_OPIS_1" VARCHAR2(30 BYTE), "KH_OPIS_2" VARCHAR2(30 BYTE), "KH_OPIS_3" VARCHAR2(90 BYTE), "KH_PLATNIK" VARCHAR2(6 BYTE), "KH_DO" VARCHAR2(1 BYTE), "KH_FK" NUMBER(1,0), "KH_KP" NUMBER(1,0), "KH_HURT" NUMBER(1,0), "KH_INNE" NUMBER(1,0), "KH_DATA" DATE, "KH_ZAZNACZ" VARCHAR2(1 BYTE), "KH_DEALER" VARCHAR2(3 BYTE), "KH_EMAIL" VARCHAR2(30 BYTE), "KH_ESTAT" NUMBER(1,0), "KH_HASLO" VARCHAR2(8 BYTE), "KH_MWART" NUMBER(12,2), "KH_MDNI" NUMBER(4,1), "KH_CENA" VARCHAR2(1 BYTE), "KH_MDOST1" VARCHAR2(30 BYTE), "KH_MDOST2" VARCHAR2(30 BYTE), "KH_NR" VARCHAR2(30 BYTE), "KH_OSOBA" VARCHAR2(20 BYTE), "KH_BANK" VARCHAR2(30 BYTE), "KH_KONTO" VARCHAR2(30 BYTE), "KH_KONTO_2" VARCHAR2(30 BYTE)) ;
--------------------------------------------------------
--  DDL for Table KTH_ROZRACH
--------------------------------------------------------

  CREATE TABLE "KTH_ROZRACH" ("NR_KONTRAH" NUMBER(10,0), "NR_KONTA_FK" VARCHAR2(30 BYTE), "NR_FAKTURY" NUMBER(10,0), "NR_KOMP_FAKT" NUMBER(10,0), "DATA_KSIEG" DATE, "TERMIN_ZAPL" DATE, "DATA_ZAPL" DATE, "KWOTA_FAKT" NUMBER(14,2), "NR_DOWODU_KS" VARCHAR2(20 BYTE), "POZ_DOW_KS" VARCHAR2(10 BYTE), "KWOTA_ZAPL" NUMBER(14,2), "NIP_KTH" VARCHAR2(20 BYTE), "TYP_ZAPISU" NUMBER(4,0), "IDENT_ROZR" NUMBER(10,0), "WALUTA" VARCHAR2(4 BYTE), "KURS" NUMBER(10,5), "KW_BR_WAL" NUMBER(14,4), "ZAPL_BR_WAL" NUMBER(14,4), "ST_ODSETEK" NUMBER(9,5), "ODS_NALICZ" NUMBER(12,4), "ODS_ZAPLAC" NUMBER(12,4)) ;
--------------------------------------------------------
--  DDL for Table KTRGRUPY
--------------------------------------------------------

  CREATE TABLE "KTRGRUPY" ("NR_KOMP_GR" NUMBER(10,0), "NAZ_GR" VARCHAR2(50 BYTE), "OPIS_GRUPY" VARCHAR2(100 BYTE), "WSKAZNIK" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table KTRKREDYT
--------------------------------------------------------

  CREATE TABLE "KTRKREDYT" ("NUMER_KOMPUTEROWY" NUMBER(10,0), "TYMCZASOWY_LIMIT" NUMBER(16,2), "DSO" NUMBER(4,0), "DLUG_C" NUMBER(18,2), "DLUG_PRZET" NUMBER(18,2), "WZLEC_CETRAL" NUMBER(18,2), "WZLEC_LOK" NUMBER(18,2), "KREDYT_WYK" NUMBER(5,2), "WART_WST" NUMBER(18,2), "NR_OP_OBSL" VARCHAR2(10 BYTE), "NR_OP_NADZ" VARCHAR2(10 BYTE), "KWOTA_30" NUMBER(18,2), "KWOTA_31_60" NUMBER(18,2), "KWOTA_61_90" NUMBER(18,2), "KWOTA_91" NUMBER(18,2), "ZAL" NUMBER(18,2), "OBSL_NR" NUMBER(10,0) DEFAULT 0, "NADZ_NR" NUMBER(10,0) DEFAULT 0, "AUTOR_NR" NUMBER(10,0) DEFAULT 0, "KWOTA_P5" NUMBER(18,2) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table KTRWARUNKI_KREDYT
--------------------------------------------------------

  CREATE TABLE "KTRWARUNKI_KREDYT" ("NUMER_KLUCZA" NUMBER(10,0), "NAZWA_KLUCZA" VARCHAR2(31 BYTE), "LIMIT_NOWY" NUMBER(16,2), "LIMIT_ZMIANA" NUMBER(16,2), "TERMIN_PLATNOSCI" NUMBER(3,0), "OPIS" VARCHAR2(50 BYTE), "IL_KLUCZY" NUMBER(1,0), "NR_KOL" NUMBER(10,0), "POZIOM" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table KTRWGR
--------------------------------------------------------

  CREATE TABLE "KTRWGR" ("NR_KOMP_GR" NUMBER(10,0), "NR_KONTR" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table KTRWNIOSKI_ODD
--------------------------------------------------------

  CREATE TABLE "KTRWNIOSKI_ODD" ("NR_WNIOSKU" NUMBER(10,0), "NR_KONTR" NUMBER(10,0), "DATA_WN" DATE, "CZAS_WN" CHAR(6 BYTE), "STARY_LIMIT" NUMBER(16,2), "NOWY_LIMIT" NUMBER(16,2), "PRZYZN_LIMIT" NUMBER(16,2), "S_TERMIN_PL" NUMBER(3,0), "N_TERMIN_PL" NUMBER(3,0), "PRZYZ_TERMIN_PL" NUMBER(3,0), "OPIS_K" RAW(1002), "DATA_ROZP" DATE, "DYREKTOR" VARCHAR2(50 BYTE), "FIRMY" RAW(1002), "UWAGI" RAW(1002), "DSO" NUMBER(4,0), "OBR_AKTUAL" NUMBER(18,2), "OBROTY_POP" NUMBER(18,2), "DATA_ZATW" DATE, "CZAS_ZATW" CHAR(6 BYTE), "STATUS" NUMBER(1,0), "OP_WNIOSK" NUMBER(10,0), "ODDZ_WNIOSK" NUMBER(2,0), "NAZ_WNIOSK" VARCHAR2(50 BYTE), "OP_ZATW" NUMBER(10,0), "ODDZ_ZATW" NUMBER(2,0), "NAZW_ZATW" VARCHAR2(50 BYTE), "S_LIMIT_D" NUMBER(16,2), "N_LIMIT_D" NUMBER(16,2), "P_LIMIT_D" NUMBER(16,2), "CALK" NUMBER(18,2) DEFAULT 0, "WYM" NUMBER(18,2) DEFAULT 0, "SPOR" NUMBER(18,2) DEFAULT 0, "PROD" NUMBER(18,2) DEFAULT 0, "OP_ZATW2" NUMBER(10,0) DEFAULT 0, "ODD_ZATW2" NUMBER(2,0) DEFAULT 0, "NAZ_ZATW2" VARCHAR2(50 BYTE), "OP_ZATW3" NUMBER(10,0) DEFAULT 0, "ODD_ZATW3" NUMBER(2,0) DEFAULT 0, "NAZ_ZATW3" VARCHAR2(50 BYTE), "POZ_WYM" NUMBER(1,0) DEFAULT 0, "POZ_AKT" NUMBER(1,0) DEFAULT 0, "POZ_WYS" NUMBER(1,0) DEFAULT 0, "ZALICZKA" NUMBER(18,2) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table KURS_SAD
--------------------------------------------------------

  CREATE TABLE "KURS_SAD" ("WALUTA" VARCHAR2(4 BYTE), "KURS" NUMBER(14,4), "NR_TABELI" VARCHAR2(10 BYTE), "DATA" DATE) ;
--------------------------------------------------------
--  DDL for Table LCENN_O
--------------------------------------------------------

  CREATE TABLE "LCENN_O" ("NR_KOMP" NUMBER(10,0), "NR_CENN" NUMBER(10,0), "DATA_OD" DATE, "DATA_DO" DATE, "OPIS" VARCHAR2(100 BYTE), "NR_OPER" VARCHAR2(10 BYTE), "DATA_PRZEL" DATE) ;
--------------------------------------------------------
--  DDL for Table LDRUKLOK
--------------------------------------------------------

  CREATE TABLE "LDRUKLOK" ("NR_KONFIG" NUMBER(10,0), "NR_STACJI" NUMBER(10,0), "NAZWA_STACJI" VARCHAR2(50 BYTE), "NAZWA_OPERAT" VARCHAR2(50 BYTE), "NR_WYDR" NUMBER(10,0), "SCIEZKA_WZORU" VARCHAR2(100 BYTE), "TYP_WYDRUKU" VARCHAR2(5 BYTE), "TYP_STEROWNIKA" VARCHAR2(15 BYTE), "NAZWA_DRUKARKI" VARCHAR2(50 BYTE), "DRUKARKA_DOMYSLNA" VARCHAR2(100 BYTE), "SCIEZKA_DO_PLIKU_TEKSTOWEGO" VARCHAR2(120 BYTE), "CZY_PODGLAD" NUMBER(1,0), "PAR1" NUMBER(1,0), "PAR2" NUMBER(1,0), "NPAR1" NUMBER(3,0), "NPAR2" NUMBER(3,0), "NPAR3" NUMBER(3,0), "PAR3" NUMBER(1,0), "PAR4" NUMBER(1,0), "PAR_5" NUMBER(1,0), "NPAR_4" NUMBER(4,0), "NPAR_5" NUMBER(4,0), "SPAR_1" VARCHAR2(60 BYTE), "SPAR_2" VARCHAR2(60 BYTE), "SPAR_3" VARCHAR2(60 BYTE), "PAGE" NUMBER(6,0) DEFAULT 2500) ;
--------------------------------------------------------
--  DDL for Table LIMITY_WYM
--------------------------------------------------------

  CREATE TABLE "LIMITY_WYM" ("GR_SZKL" NUMBER(3,0), "SZER_RAMKI" NUMBER(3,0), "DLUG" NUMBER(4,0), "SZER" NUMBER(4,0), "POW" NUMBER(7,3), "BOK" NUMBER(4,0), "STOS_BOK" NUMBER(7,4) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table LISTA_DZIAL
--------------------------------------------------------

  CREATE TABLE "LISTA_DZIAL" ("NR_KOMP" NUMBER(10,0), "NAZ_DZ" VARCHAR2(30 BYTE), "KOD_DZ" VARCHAR2(5 BYTE), "WSK" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table LISTA_MPK
--------------------------------------------------------

  CREATE TABLE "LISTA_MPK" ("NR_KOMP" NUMBER(10,0), "NAZ_MPK" VARCHAR2(30 BYTE), "NR_REGIONU" NUMBER(3,0), "NR_ODDZ" NUMBER(2,0), "SKROT" VARCHAR2(5 BYTE)) ;
--------------------------------------------------------
--  DDL for Table LISTA_P_OBR
--------------------------------------------------------

  CREATE TABLE "LISTA_P_OBR" ("NR_KOMP_STRUKTURY" NUMBER(10,0), "NR_KOL_PARAM" NUMBER(6,0), "NR_KOMP_SL_PAR" NUMBER(10,0), "SYMB_PARAM" VARCHAR2(10 BYTE), "OPIS_PARAM" VARCHAR2(50 BYTE), "WART_PAR" NUMBER(14,4), "TYP_PAR" NUMBER(2,0), "CZY_OBOW" NUMBER(2,0), "CZY_KOREKT_WYM" NUMBER(2,0), "JEDN" VARCHAR2(5 BYTE), "FORMAT" VARCHAR2(10 BYTE), "NR_KOMP_GR" NUMBER(10,0) DEFAULT 0, "CZY_NA_WYDR" NUMBER(1,0) DEFAULT 0, "CZY_LISTA" NUMBER(1,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table LISTA_PRACOW
--------------------------------------------------------

  CREATE TABLE "LISTA_PRACOW" ("NR_PRAC" NUMBER(10,0), "PRACOWNIK" VARCHAR2(35 BYTE), "NR_EWID" NUMBER(10,0), "NIP" VARCHAR2(20 BYTE), "NR_ODDZ" NUMBER(2,0), "LOGIN" VARCHAR2(10 BYTE) DEFAULT ' ') ;
--------------------------------------------------------
--  DDL for Table LISTNAZ
--------------------------------------------------------

  CREATE TABLE "LISTNAZ" ("NR_SCHEM" NUMBER(10,0), "NAZ_SCHEM" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table LISTSZAB
--------------------------------------------------------

  CREATE TABLE "LISTSZAB" ("NR_SCHEM" NUMBER(3,0), "TYP_POZ" VARCHAR2(1 BYTE), "POLE" VARCHAR2(10 BYTE), "TYP" NUMBER(3,0)) ;
--------------------------------------------------------
--  DDL for Table LISTTYP
--------------------------------------------------------

  CREATE TABLE "LISTTYP" ("RODZAJ" VARCHAR2(1 BYTE), "TYP" NUMBER(3,0), "OPIS_TYPU" VARCHAR2(100 BYTE), "FORMAT" VARCHAR2(20 BYTE)) ;
--------------------------------------------------------
--  DDL for Table LKONW
--------------------------------------------------------

  CREATE TABLE "LKONW" ("ZNAK_WEJ" NUMBER(3,0), "ZNAK_WYJ" NUMBER(3,0), "TYP" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table LOG_CZYTNIK
--------------------------------------------------------

  CREATE TABLE "LOG_CZYTNIK" ("DATA" DATE, "CZAS" CHAR(6 BYTE), "OPERATOR" VARCHAR2(10 BYTE), "STOJAK" VARCHAR2(7 BYTE), "POZ" NUMBER(10,0), "NR_SZYBY" VARCHAR2(32 BYTE), "NR_ZLEC" NUMBER(6,0), "POZ_ZLEC" NUMBER(3,0), "NR_SZT" NUMBER(10,0), "TRYB" VARCHAR2(1 BYTE), "NR_ZAPISU" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table LOGDAN
--------------------------------------------------------

  CREATE TABLE "LOGDAN" ("NR_KONTR" NUMBER(9,0), "RODZ_DAN" VARCHAR2(1 BYTE), "DANE" LONG RAW, "DATA_AKT" VARCHAR2(10 BYTE), "CZAS_AKT" VARCHAR2(8 BYTE), "NR_ODDZ" NUMBER(9,0), "TYP" NUMBER(1,0), "FL_COMPR" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table LOGHREF
--------------------------------------------------------

  CREATE TABLE "LOGHREF" ("NK_KONTR" NUMBER(10,0), "NR_OD" NUMBER(2,0), "TYP" VARCHAR2(1 BYTE), "NKOMP1" NUMBER(10,0), "NKOMP2" NUMBER(10,0), "ZN" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table LOG_KAL
--------------------------------------------------------

  CREATE TABLE "LOG_KAL" ("NK_ZAP" NUMBER(10,0), "NK_ZLEC" NUMBER(10,0), "DATA" DATE, "CZAS" CHAR(6 BYTE), "OP" VARCHAR2(30 BYTE), "FUN" VARCHAR2(100 BYTE), "NR_POZ" NUMBER(4,0)) ;
--------------------------------------------------------
--  DDL for Table LOGKRED
--------------------------------------------------------

  CREATE TABLE "LOGKRED" ("NR_KONTR" NUMBER(10,0), "DATA_Z" DATE, "GODZ_Z" CHAR(6 BYTE), "ZNACZNIK" NUMBER(1,0), "TYP" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table LOGKSZTALT
--------------------------------------------------------

  CREATE TABLE "LOGKSZTALT" ("NR_KONTRAHENTA" NUMBER(10,0), "NR_ODDZIALU" NUMBER(2,0), "NR_ZLECENIA" NUMBER(6,0), "POZYCJA" NUMBER(4,0), "RYSUNEK" LONG RAW) ;
--------------------------------------------------------
--  DDL for Table LOG_ODCZYTOW
--------------------------------------------------------

  CREATE TABLE "LOG_ODCZYTOW" ("LOG_TYP" VARCHAR2(2 BYTE) DEFAULT ' ', "OPER" VARCHAR2(10 BYTE) DEFAULT ' ', "STACJA" VARCHAR2(30 BYTE) DEFAULT ' ', "NR_KOL" NUMBER(10,0) DEFAULT 0, "NR_KOMP_ZLEC" NUMBER(10,0) DEFAULT 0, "IDENT2" NUMBER(10,0) DEFAULT 0, "IDENT3" NUMBER(10,0) DEFAULT 0, "IDENT4" NUMBER(10,0) DEFAULT 0, "DATA" DATE DEFAULT TO_DATE('01/01/1901','DD/MM/YYYY'), "CZAS" CHAR(6 BYTE) DEFAULT '000000', "NR_KOMP_INST" NUMBER(10,0) DEFAULT 0, "NR_KOMP_ZM" NUMBER(10,0) DEFAULT 0, "FLAG" NUMBER(1,0) DEFAULT 0, "TEKST" VARCHAR2(100 BYTE) DEFAULT ' ', "SESSION_ID" NUMBER(10,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table LOGOWANIA
--------------------------------------------------------

  CREATE TABLE "LOGOWANIA" ("SESSION_ID" NUMBER(10,0) DEFAULT 0, "HOST" VARCHAR2(50 BYTE) DEFAULT ' ', "OS_USER" VARCHAR2(50 BYTE) DEFAULT ' ', "OPERATOR_ID" VARCHAR2(10 BYTE) DEFAULT ' ', "DATA" DATE DEFAULT to_date('1901/01/01','YYYY/MM/DD'), "CZAS" CHAR(6 BYTE) DEFAULT '000000', "PROG_NAME" VARCHAR2(50 BYTE) DEFAULT ' ', "PROG_VER" VARCHAR2(50 BYTE) DEFAULT ' ') ;
--------------------------------------------------------
--  DDL for Table LOG_POL
--------------------------------------------------------

  CREATE TABLE "LOG_POL" ("TAB" VARCHAR2(30 BYTE), "KOL" VARCHAR2(30 BYTE), "TYP" VARCHAR2(10 BYTE), "WSK" NUMBER(1,0), "WSK2" NUMBER(1,0), "N_TRIG" VARCHAR2(20 BYTE)) ;
--------------------------------------------------------
--  DDL for Table LOGS
--------------------------------------------------------

  CREATE TABLE "LOGS" ("SESJA" NUMBER(10,0), "OP" VARCHAR2(30 BYTE), "OP_ID" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table LOGT
--------------------------------------------------------

  CREATE TABLE "LOGT" ("DATA" DATE, "UZYTK" VARCHAR2(50 BYTE), "NK_ZAP" NUMBER(10,0), "CZAS" CHAR(6 BYTE), "WAR" VARCHAR2(100 BYTE), "TAB" VARCHAR2(30 BYTE), "POLE" VARCHAR2(30 BYTE), "ID_GL" NUMBER(10,0), "ID_POZ" NUMBER(10,0), "OP_ID" NUMBER(10,0), "OPIS" VARCHAR2(10 BYTE)) ;
--------------------------------------------------------
--  DDL for Table LOG_TAB
--------------------------------------------------------

  CREATE TABLE "LOG_TAB" ("TABELA" VARCHAR2(30 BYTE), "ILOSC" NUMBER(5,0), "WSK" NUMBER(1,0), "IDENT_GLOWY" VARCHAR2(30 BYTE), "IDENT_POZYCJI" VARCHAR2(30 BYTE)) ;
--------------------------------------------------------
--  DDL for Table LOGTRANP
--------------------------------------------------------

  CREATE TABLE "LOGTRANP" ("K1" NUMBER(10,0), "K2" NUMBER(2,0), "K3" NUMBER(10,0), "KOL4" LONG RAW, "K5" VARCHAR2(1 BYTE), "OPERACJA" NUMBER(1,0), "FL_COMPR" VARCHAR2(1 BYTE) DEFAULT '0') ;
--------------------------------------------------------
--  DDL for Table LOG_TRANS
--------------------------------------------------------

  CREATE TABLE "LOG_TRANS" ("DATA" DATE, "CZAS" CHAR(6 BYTE), "NR_OP" VARCHAR2(10 BYTE), "NR_ZBIORU" NUMBER(6,0), "TEKST" VARCHAR2(40 BYTE), "NR_KOMP_NAG" NUMBER(10,0), "NR_POZ" NUMBER(5,0), "ZNAK_OP" VARCHAR2(1 BYTE), "WART_STARA" NUMBER(14,4), "NR_ODDZ" NUMBER(2,0), "NKOMP" NUMBER(10,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table LOG_ZMCEN
--------------------------------------------------------

  CREATE TABLE "LOG_ZMCEN" ("NR_KOL" NUMBER(10,0), "NR_KONTRAH" NUMBER(10,0), "TYP_ZAPISU" NUMBER(2,0), "NR_KOMP_ZK" NUMBER(10,0), "INDEKS" VARCHAR2(128 BYTE), "CENA_POP" NUMBER(14,4), "CENA_AKT" NUMBER(14,4), "NR_OP" VARCHAR2(10 BYTE), "D_AUTOR" DATE, "TYP_AUTOR" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table LOK_DOK
--------------------------------------------------------

  CREATE TABLE "LOK_DOK" ("NR_KOMP_DOK" NUMBER(10,0), "NR_DOK" NUMBER(8,0), "DATA_D" DATE, "DATA_TR" DATE, "NR_DOK_BAZ" VARCHAR2(18 BYTE), "DATA_D_BAZ" DATE, "TYP_DOK" VARCHAR2(3 BYTE), "OPIS" VARCHAR2(50 BYTE), "NR_MAG" NUMBER(3,0), "NR_MAG_DOC" NUMBER(3,0), "NR_KON" NUMBER(10,0), "STATUS" NUMBER(1,0), "STORNO" NUMBER(1,0), "GR_DOK" VARCHAR2(3 BYTE), "NR_KOM_FAKT" NUMBER(10,0), "TYP_ZLEC" VARCHAR2(3 BYTE), "ROK" NUMBER(4,0), "MIES" NUMBER(2,0), "NR_ODDZ" NUMBER(2,0), "NR_KOMP_BAZ" NUMBER(10,0), "WARTOSC" NUMBER(16,2), "NR_OP_WPR" VARCHAR2(10 BYTE)) ;
--------------------------------------------------------
--  DDL for Table LOK_POZDOK
--------------------------------------------------------

  CREATE TABLE "LOK_POZDOK" ("TYP_DOK" VARCHAR2(3 BYTE), "DATA_D" DATE, "NR_DOK" NUMBER(8,0), "NR_POZ" NUMBER(5,0), "INDEKS" VARCHAR2(128 BYTE), "INDEKS_ORG" VARCHAR2(128 BYTE), "NAZWA" VARCHAR2(255 BYTE), "ILOSC_JR" NUMBER(10,0), "ILOSC_JP" NUMBER(18,6), "STAN1" NUMBER(18,6), "STAN2" NUMBER(18,6), "CENA_PRZYJ" NUMBER(14,4), "CEN_WYD" NUMBER(14,4), "STORNO" NUMBER(1,0), "NR_POZ_ZLEC" NUMBER(3,0), "CZY_DOD" VARCHAR2(1 BYTE), "ROK" NUMBER(4,0), "MIES" NUMBER(2,0), "NR_ODDZ" NUMBER(2,0), "NR_MAG" NUMBER(3,0), "NR_KOMP_DOK" NUMBER(10,0), "NR_KOMP_BAZ" NUMBER(10,0), "ZNACZ_KART" VARCHAR2(3 BYTE), "STATUS_DOK" NUMBER(1,0), "KOL_DOD" NUMBER(3,0), "CENA_DODATKOWA" NUMBER(14,4)) ;
--------------------------------------------------------
--  DDL for Table L_PAMLIST
--------------------------------------------------------

  CREATE TABLE "L_PAMLIST" ("NR_LISTY" NUMBER(10,0), "DATA" DATE, "ILE_ZLEC" NUMBER(8,0), "ILE_STOJ" NUMBER(8,0), "ILE_GRUP" NUMBER(8,0), "ILE_SZKIEL" NUMBER(8,0), "GR_POCZ" NUMBER(8,0), "GR_KONC" NUMBER(8,0), "ILE_SZYB" NUMBER(6,0), "ILE_M2" NUMBER(6,0), "ILE_WYSLANYCH" NUMBER(6,0)) ;
--------------------------------------------------------
--  DDL for Table L_WYC
--------------------------------------------------------

  CREATE TABLE "L_WYC" ("NR_KOM_ZLEC" NUMBER(10,0), "NR_POZ_ZLEC" NUMBER(3,0), "NR_SZT" NUMBER(10,0), "NR_WARST" NUMBER(2,0), "TYP_KAT" VARCHAR2(128 BYTE), "RODZ_SUR" VARCHAR2(3 BYTE), "NR_LISTY" NUMBER(10,0), "NR_KOMORY" NUMBER(10,0), "NR_INST" NUMBER(10,0), "TYP_INST" VARCHAR2(3 BYTE), "KOLEJN" NUMBER(3,0), "ZN_WYK_TRAN" NUMBER(2,0), "NR_STOJ" NUMBER(10,0), "KOD_PASK" VARCHAR2(20 BYTE), "ZN_BRAKU" NUMBER(2,0), "OP" VARCHAR2(10 BYTE), "DATA" DATE, "CZAS" CHAR(6 BYTE), "ZN_WYROBU" NUMBER(2,0), "NR_SZAR" NUMBER(6,0) DEFAULT 0, "NR_INST_NAST" NUMBER(10,0) DEFAULT 0, "D_WYK" DATE DEFAULT '1901/01/01', "ZM_WYK" NUMBER(1,0) DEFAULT 0, "NR_INST_WYK" NUMBER(10,0) DEFAULT 0, "STOJ_POZ" NUMBER(5,0) DEFAULT 0, "ZN_STOJ" NUMBER(10,0) DEFAULT 0, "OP_END" VARCHAR2(10 BYTE) DEFAULT 0, "DATA_END" DATE DEFAULT '1901/01/01', "CZAS_END" CHAR(6 BYTE) DEFAULT '', "ZN_W_POPRZ" NUMBER(2,0) DEFAULT 0, "NR_ST_C" NUMBER(10,0) DEFAULT 0, "ID_REK" NUMBER(10,0) DEFAULT 0, "NR_SER" NUMBER(12,0) DEFAULT 0, "ID_ORYG" NUMBER(10,0) DEFAULT 0, "WYROZNIK" CHAR(1 BYTE) DEFAULT '') ;
--------------------------------------------------------
--  DDL for Table L_WYC_TMP
--------------------------------------------------------

  CREATE TABLE "L_WYC_TMP" ("NR_KOMP_ZLEC" NUMBER(10,0), "NR_POZ" NUMBER(6,0), "NR_SZT" NUMBER(10,0), "NR_WARST" NUMBER(2,0), "INDEKS" VARCHAR2(128 BYTE), "RODZ_SUR" VARCHAR2(3 BYTE), "NR_LISTY" NUMBER(10,0), "NR_KOMORY" NUMBER(10,0), "NR_KOMP_INST" NUMBER(10,0), "TYP_INST" VARCHAR2(3 BYTE), "KOLEJN" NUMBER(3,0), "ZN_WYK_TRAN" NUMBER(2,0), "NR_STOJ" NUMBER(10,0), "KOD_PASK" VARCHAR2(20 BYTE), "ZN_BRAKU" NUMBER(2,0), "OP" VARCHAR2(10 BYTE), "DATA" DATE, "CZAS" CHAR(6 BYTE), "ZN_WYROBU" NUMBER(2,0), "NR_SZAR" NUMBER(6,0), "NR_KOMP_NAST" NUMBER(10,0), "D_WYK" DATE, "ZM_WYK" NUMBER(1,0), "NR_INST_WYK" NUMBER(10,0), "CZY_ZOST" NUMBER(1,0), "STOJ_POZ" NUMBER(5,0) DEFAULT 0, "ZN_STOJ" NUMBER(10,0) DEFAULT 0, "OP_END" VARCHAR2(10 BYTE) DEFAULT 0, "DATA_END" DATE DEFAULT '1901/01/01', "CZAS_END" CHAR(6 BYTE) DEFAULT '', "ZN_W_POPRZ" NUMBER(2,0) DEFAULT 0, "NR_ST_C" NUMBER(10,0) DEFAULT 0, "ID_REK" NUMBER(10,0) DEFAULT 0, "NR_SER" NUMBER(12,0) DEFAULT 0, "ID_ORYG" NUMBER(10,0) DEFAULT 0, "WYROZNIK" CHAR(1 BYTE) DEFAULT '') ;
--------------------------------------------------------
--  DDL for Table MAGAZYN
--------------------------------------------------------

  CREATE TABLE "MAGAZYN" ("NR_ODDZ" NUMBER(2,0), "NR_MAG" NUMBER(3,0), "PRZEZN" VARCHAR2(4 BYTE), "NAZ_MAG" VARCHAR2(30 BYTE), "PANSTWO" VARCHAR2(20 BYTE), "MIASTO" VARCHAR2(30 BYTE), "POWIAT" VARCHAR2(20 BYTE), "WOJEW" VARCHAR2(20 BYTE), "KOD_POCZ" VARCHAR2(10 BYTE), "ADRES" VARCHAR2(31 BYTE), "TEL" VARCHAR2(19 BYTE), "FAX" VARCHAR2(19 BYTE), "IM_NAZ_ODP" VARCHAR2(40 BYTE), "DAT_ZAK_OKRESU" DATE, "TRYB_PRACY" VARCHAR2(7 BYTE), "DATA_POCZ_OKRESU" DATE, "STRT" NUMBER(1,0), "ZNACZNIK" VARCHAR2(3 BYTE), "NUMER_OKRESU" NUMBER(4,0), "CZY_STD" NUMBER(1,0), "FLAG_REZ" NUMBER(2,0) DEFAULT 0, "F_ZAKUPY" NUMBER(1,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table MEMOSPED
--------------------------------------------------------

  CREATE TABLE "MEMOSPED" ("NR_K_ZLEC" NUMBER(10,0), "MEMO_SPED" RAW(514)) ;
--------------------------------------------------------
--  DDL for Table MK_NR_DOK
--------------------------------------------------------

  CREATE TABLE "MK_NR_DOK" ("GR_DOK" CHAR(3 BYTE), "KARTOTEKA" CHAR(4 BYTE), "TYP_DOK" CHAR(3 BYTE), "ROK" NUMBER(4,0), "MIES" NUMBER(2,0), "NUMER" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table MK_NR_KOMPUT
--------------------------------------------------------

  CREATE TABLE "MK_NR_KOMPUT" ("NR_KOMP" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table MLOG$_ZAMOW
--------------------------------------------------------

  CREATE TABLE "MLOG$_ZAMOW" ("M_ROW$$" VARCHAR2(255 BYTE), "SNAPTIME$$" DATE, "DMLTYPE$$" VARCHAR2(1 BYTE), "OLD_NEW$$" VARCHAR2(1 BYTE), "CHANGE_VECTOR$$" RAW(255)) ;
 

   COMMENT ON TABLE "MLOG$_ZAMOW"  IS 'snapshot log for master table VITR2011.ZAMOW';
--------------------------------------------------------
--  DDL for Table MON_STRATY
--------------------------------------------------------

  CREATE TABLE "MON_STRATY" ("INDEKS" VARCHAR2(50 BYTE), "NR_KOMP_POBR" NUMBER(10,0), "TYP_KATALOG" VARCHAR2(9 BYTE), "NR_KATALOG" NUMBER(4,0), "NR_KOMP_ODP" NUMBER(10,0), "ILE_TAF" NUMBER(4,0), "SZER" NUMBER(5,0), "WYS" NUMBER(5,0), "ILE_POBRANO" RAW(14), "ILE_ODP" NUMBER(5,0), "DLUGP" NUMBER(5,0), "WYSP" NUMBER(5,0), "ILE_POZOSTALO" RAW(14), "STRATY_WZGL" NUMBER(8,3), "NR_KOMP_ZMIANY" NUMBER(10,0), "ZMIANA" NUMBER(2,0), "DATA" DATE, "FLAGA_CZY_ODPAD" NUMBER(1,0), "FLAGA_CZY_BRAK" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table NALBIL
--------------------------------------------------------

  CREATE TABLE "NALBIL" ("NR_KOMPB" NUMBER(10,0), "NR_KOMP_KART" NUMBER(10,0), "NR_MAG" NUMBER(3,0), "NR_ANAL" NUMBER(3,0), "INDEKS" VARCHAR2(128 BYTE), "D_POCZ" DATE, "D_KON" DATE, "STAN_POCZ" NUMBER(14,6), "WART_POCZ" NUMBER(14,2), "STAN_KON" NUMBER(14,6), "WART_KON" NUMBER(14,2), "NR_ODDZ" NUMBER(2,0), "RODZ_BIL" VARCHAR2(1 BYTE)) ;
--------------------------------------------------------
--  DDL for Table NALEZN
--------------------------------------------------------

  CREATE TABLE "NALEZN" ("NR_KOMP_NAL" NUMBER(10,0), "DATA_WPL" DATE, "KWOTA_WPL" NUMBER(18,2), "NAZ_OP" CHAR(35 BYTE), "ID_DOK_WPLATY" VARCHAR2(10 BYTE), "TYP_WPL" VARCHAR2(1 BYTE), "DATA_ZAPISU" DATE, "CZAS_ZAPISU" CHAR(6 BYTE), "NR_KOMP_WPLATY" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table NAL_FK
--------------------------------------------------------

  CREATE TABLE "NAL_FK" ("SYM_FAKT" RAW(15), "DATA_FAKT" DATE, "DATA_PLAT" DATE, "NALEZNOSC" NUMBER(12,2), "ZAPLACONO" NUMBER(12,2), "DO_ZAPLATY" NUMBER(12,2), "KOD_KONTR" RAW(7), "ILOSC_DNI" NUMBER(5,0), "NIP" VARCHAR2(13 BYTE)) ;
--------------------------------------------------------
--  DDL for Table NAL_RAP_ZYSK
--------------------------------------------------------

  CREATE TABLE "NAL_RAP_ZYSK" ("NR_NALICZ" NUMBER(10,0), "DATA_NAL" DATE, "LP_DOD" VARCHAR2(10 BYTE), "DATA_OD" DATE, "DATA_DO" DATE, "DLA_KTR_GRP" VARCHAR2(100 BYTE), "MASKA_TOW" VARCHAR2(150 BYTE), "KOSZTY_SPR" NUMBER(18,2), "NETTO_SPR" NUMBER(18,2), "MM_SPR" NUMBER(14,2), "ZYSK_STD_SPR" NUMBER(18,2), "KOSZTY_PROD" NUMBER(18,2), "NETTO_PROD" NUMBER(18,2), "MM_PROD" NUMBER(14,2), "ZYSK_STD_PROD" NUMBER(18,2), "KOSZTY_INNE" NUMBER(18,2), "NETTO_INNE" NUMBER(18,2), "MM_INNE" NUMBER(14,2), "ZYSK_STD_INNE" NUMBER(18,2)) ;
--------------------------------------------------------
--  DDL for Table NAPISY_SZYB
--------------------------------------------------------

  CREATE TABLE "NAPISY_SZYB" ("NR_KOM_SZYBY" NUMBER(10,0), "NAPIS" VARCHAR2(1000 BYTE)) ;
--------------------------------------------------------
--  DDL for Table NAP_KLUCZE
--------------------------------------------------------

  CREATE TABLE "NAP_KLUCZE" ("KLUCZ" VARCHAR2(11 BYTE), "OPIS" VARCHAR2(100 BYTE), "TYP" NUMBER(4,0), "WARTOSC" VARCHAR2(20 BYTE)) ;
--------------------------------------------------------
--  DDL for Table NAP_NAPISY
--------------------------------------------------------

  CREATE TABLE "NAP_NAPISY" ("NR_SLO" NUMBER(10,0), "NR_NAP" NUMBER(10,0), "NR_WZ" NUMBER(10,0), "T_STALY" VARCHAR2(50 BYTE), "OPIS" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table NAP_SLOW
--------------------------------------------------------

  CREATE TABLE "NAP_SLOW" ("NR_SLO" NUMBER(10,0), "NAZA_SLO" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table NAP_WZR
--------------------------------------------------------

  CREATE TABLE "NAP_WZR" ("NR_WZORCA" NUMBER(10,0), "WZR" VARCHAR2(200 BYTE)) ;
--------------------------------------------------------
--  DDL for Table NB_KONFIG
--------------------------------------------------------

  CREATE TABLE "NB_KONFIG" ("KONF_KEY" VARCHAR2(10 BYTE), "KONF_VALUE" VARCHAR2(200 BYTE)) ;
--------------------------------------------------------
--  DDL for Table NB_OST_NR
--------------------------------------------------------

  CREATE TABLE "NB_OST_NR" ("TYP" VARCHAR2(30 BYTE), "NR" NUMBER(10,0), "GR_DOK" VARCHAR2(3 BYTE), "TYP_DOK" VARCHAR2(30 BYTE), "TAB" VARCHAR2(30 BYTE), "KOL_DATA" VARCHAR2(30 BYTE), "OPIS" VARCHAR2(100 BYTE), "OST_NR" NUMBER(10,0) DEFAULT 0, "FIRST_NR" NUMBER(10,0) DEFAULT 0, "NR_NEW" NUMBER(10,0) DEFAULT 0, "NR_NEW_OPER" NUMBER(10,0), "CZY_EDT" NUMBER(1,0) DEFAULT 0, "FLAG_WIDOCZNOSCI" NUMBER(1,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table NB_PLIKI_IMPORT
--------------------------------------------------------

  CREATE TABLE "NB_PLIKI_IMPORT" ("PDI_TAB_ID" NUMBER(9,0), "PDI_NAZWA" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table NB_POLECENIA
--------------------------------------------------------

  CREATE TABLE "NB_POLECENIA" ("POL_ID" NUMBER(9,0), "POL_ETAP" VARCHAR2(1 BYTE), "POL_KOLEJNOSC" NUMBER(4,0), "POL_POLECENIE" VARCHAR2(1000 BYTE)) ;
--------------------------------------------------------
--  DDL for Table NB_TABELE
--------------------------------------------------------

  CREATE TABLE "NB_TABELE" ("TAB_ID" NUMBER(9,0), "TAB_NAZWA" VARCHAR2(50 BYTE), "TAB_ETAP_PRZEN" VARCHAR2(1 BYTE), "TAB_AKTYWNA" NUMBER(1,0), "TAB_WLASNA" NUMBER(1,0), "TAB_ZAZNACZONA" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table NIEOBEC
--------------------------------------------------------

  CREATE TABLE "NIEOBEC" ("NR_PRAC" NUMBER(10,0), "OD_DATY" DATE, "DO_DATY" DATE, "UWAGI" VARCHAR2(20 BYTE), "KOD" NUMBER(2,0), "NR_ODDZ" NUMBER(2,0), "NR_KOMP_NIEOB" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table NOTA
--------------------------------------------------------

  CREATE TABLE "NOTA" ("AXS_TPS" VARCHAR2(1 BYTE), "SYMB_DOK" VARCHAR2(8 BYTE), "LP_DOK" NUMBER(5,1), "DATA_DOKF" DATE, "KONTO" VARCHAR2(16 BYTE), "WALUTA" VARCHAR2(1 BYTE), "KWOTA_WN" NUMBER(12,2), "KWOTA_MA" NUMBER(12,2), "IDENT_FAK" VARCHAR2(14 BYTE), "DATA_PLAT" DATE, "KTO" VARCHAR2(3 BYTE), "KOMENT" VARCHAR2(30 BYTE), "BL_SALDA" NUMBER(1,0), "WART_DOK" NUMBER(1,0), "K_R" VARCHAR2(1 BYTE), "ARCHIW" NUMBER(1,0), "DATA_DZIEN" DATE, "NR_DZIEN" NUMBER(6,1), "KURS" NUMBER(10,6), "EXPORTED" VARCHAR2(1 BYTE), "RK_NWZ" VARCHAR2(7 BYTE), "RK_LP" NUMBER(5,1), "DEALER" VARCHAR2(3 BYTE), "MAGAZYN" VARCHAR2(8 BYTE), "ZNACZNIK" VARCHAR2(4 BYTE), "TYP_DOK" VARCHAR2(3 BYTE), "NKOMP_DOK" NUMBER(10,0), "WYSLANA" NUMBER(1,0), "WSKAZNIK" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table NR_OZNAK
--------------------------------------------------------

  CREATE TABLE "NR_OZNAK" ("NR_KOL" NUMBER(2,0), "NR_TAB" NUMBER(4,0), "NR_POLA" NUMBER(2,0), "NAZWA_SQL" VARCHAR2(25 BYTE), "NR_KOMP" NUMBER(10,0), "NR" VARCHAR2(10 BYTE), "WARTA" NUMBER(8,0), "WARTB" NUMBER(4,0), "WARTC" NUMBER(13,3), "FLAG" NUMBER(1,0), "WSK" NUMBER(1,0), "DATA" DATE, "CZAS" CHAR(6 BYTE)) ;
--------------------------------------------------------
--  DDL for Table OBR_CZAS
--------------------------------------------------------

  CREATE TABLE "OBR_CZAS" ("NR_KOMP_ZM" NUMBER(10,0), "DL_ZM" NUMBER(2,0), "DATA" DATE, "ZM" NUMBER(1,0), "NR_KOMP_INST" NUMBER(10,0), "NR_OBR" NUMBER(4,0), "ILOSC" NUMBER(10,0), "IL_WYC" NUMBER(10,0), "POW" NUMBER(13,3), "IL_WYK" NUMBER(10,0), "IL_OBR" NUMBER(13,3), "IL_PRZEL" NUMBER(13,3), "IL_PRACOW" NUMBER(2,0), "GODZ" NUMBER(5,2)) ;
--------------------------------------------------------
--  DDL for Table ODDTRAN
--------------------------------------------------------

  CREATE TABLE "ODDTRAN" ("K1" NUMBER(10,0), "K2" NUMBER(2,0), "K3" NUMBER(2,0), "K4" VARCHAR2(50 BYTE), "K5" DATE, "K6" CHAR(6 BYTE), "K7" LONG RAW, "K8" VARCHAR2(50 BYTE), "K9" VARCHAR2(50 BYTE)) ;
--------------------------------------------------------
--  DDL for Table ODDZ_BLOK
--------------------------------------------------------

  CREATE TABLE "ODDZ_BLOK" ("NR_KOMP" NUMBER(10,0), "D_WSTRZYM" DATE, "C_WSTRZYM" CHAR(6 BYTE), "STAN" NUMBER(1,0), "NR_KOM_ZLEC" NUMBER(10,0), "NR_ZLEC" NUMBER(6,0), "DATA_ZLEC" DATE, "WART_ZLEC" NUMBER(12,2), "NR_KONTR" NUMBER(10,0), "PEL_NAZ_KONTR" VARCHAR2(50 BYTE), "NIP" VARCHAR2(20 BYTE), "STATUS" NUMBER(1,0), "CALK_ZADL" NUMBER(16,2), "WYM_ZADL" NUMBER(16,2), "LIM_KRED" NUMBER(16,2), "PRZEKR" NUMBER(5,2), "D_ODBL" DATE, "C_ODBL" CHAR(6 BYTE), "NR_ODDZ" NUMBER(2,0), "NR_OP_WYST" NUMBER(10,0), "NAZ_OP_WYST" VARCHAR2(50 BYTE), "ODDZ_OP_WYST" NUMBER(2,0), "NR_OP_ODBL" NUMBER(10,0), "NAZ_OP_ODBL" VARCHAR2(50 BYTE), "ODDZ_OP_ODBL" NUMBER(2,0), "STATUS_O" NUMBER(1,0), "CALK_ZADL_O" NUMBER(16,2), "WYM_ZADL_O" NUMBER(16,2), "LIMIT_KRED_O" NUMBER(16,2), "OPIS" VARCHAR2(200 BYTE), "OP_ODBL2" NUMBER(10,0), "NAZ_ODBL2" VARCHAR2(50 BYTE), "ODDZ_ODBL2" NUMBER(2,0), "OP_ODBL3" NUMBER(10,0), "NAZ_ODBL3" VARCHAR2(50 BYTE), "ODDZ_ODBL3" NUMBER(2,0), "POZ_WYM" NUMBER(1,0), "POZ_AKT" NUMBER(1,0), "POZ_WYS" NUMBER(1,0), "ZALICZKA" NUMBER(18,2), "ZALICZKA_O" NUMBER(18,2), "PRZYCZ" NUMBER(1,0), "PROD" NUMBER(14,2) DEFAULT 0, "PROD_O" NUMBER(14,2) DEFAULT 0, "ZAPLATY" NUMBER(14,2) DEFAULT 0, "ZAPLATY_O" NUMBER(14,2) DEFAULT 0, "WST" NUMBER(14,2) DEFAULT 0, "WST_O" NUMBER(14,2) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table ODDZIALY
--------------------------------------------------------

  CREATE TABLE "ODDZIALY" ("NR_ODDZ" NUMBER(2,0), "PREFIX" VARCHAR2(10 BYTE), "OPIS" VARCHAR2(60 BYTE), "NR_KONTR_ODB" NUMBER(10,0), "NR_KONT_DOST" NUMBER(10,0), "NR_INT" NUMBER(2,0) DEFAULT 0, "CZY_PRZE" NUMBER(1,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table ODPADY
--------------------------------------------------------

  CREATE TABLE "ODPADY" ("NR_ODP" NUMBER(10,0), "NR_KAT" NUMBER(4,0), "DATA_POW" DATE, "SZEROKOSC" NUMBER(4,0), "WYSOKOSC" NUMBER(4,0), "CENA" NUMBER(14,4), "NR_OPTYM" NUMBER(10,0), "CZY_METKA" NUMBER(1,0), "NRT" NUMBER(4,0), "NR_STOJ" NUMBER(10,0), "POZ_ST" NUMBER(3,0), "FL_PLAN" NUMBER(1,0), "FL_WYB" NUMBER(1,0), "NUMER_OPERATORA" VARCHAR2(10 BYTE), "NK_WYM" NUMBER(10,0), "NK_INST" NUMBER(10,0), "O_POB" VARCHAR2(10 BYTE), "D_POB" DATE, "T_POB" CHAR(6 BYTE), "AKT" NUMBER(1,0), "NR_DOK_PLUS" NUMBER(10,0) DEFAULT 0, "NR_DOK_MINUS" NUMBER(10,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table OFERTY_NAG
--------------------------------------------------------

  CREATE TABLE "OFERTY_NAG" ("NR_KOM_ZLEC" NUMBER(10,0), "GR_DOK" VARCHAR2(3 BYTE), "NR_ZLEC" NUMBER(6,0), "NR_KON" NUMBER(10,0), "DATA_ZL" DATE, "D_WYS" DATE, "IL_POZ" NUMBER(3,0), "NR_ODDZ" NUMBER(2,0), "ROK" NUMBER(4,0), "MIES" NUMBER(2,0), "FORMA_WPROW" VARCHAR2(1 BYTE), "DO_PRODUKCJI" NUMBER(1,0), "INCOTERMS" VARCHAR2(3 BYTE), "WAR_PLAT" VARCHAR2(2 BYTE), "RABAT" NUMBER(5,2), "DATA_DOST" DATE, "ADRES_DOST" NUMBER(10,0), "D_ODP" DATE, "BAZA_DOST" VARCHAR2(40 BYTE), "TERMIN_ODP" DATE, "NAZ_IM" VARCHAR2(25 BYTE), "NR_KOMP_ZAM" NUMBER(10,0), "NR_ZAM" NUMBER(6,0), "RODZ_PLAT" VARCHAR2(2 BYTE), "IL_DNI" NUMBER(3,0), "WALUTA" VARCHAR2(4 BYTE), "NAZ_DOST" VARCHAR2(50 BYTE), "MIASTO" VARCHAR2(30 BYTE), "ADRES" VARCHAR2(31 BYTE), "NIP" VARCHAR2(20 BYTE), "PANSTWO" VARCHAR2(20 BYTE)) ;
--------------------------------------------------------
--  DDL for Table OFERTY_NAGK
--------------------------------------------------------

  CREATE TABLE "OFERTY_NAGK" ("NR_KOM_ZLEC" NUMBER(10,0), "GR_DOK" VARCHAR2(3 BYTE), "NR_ZLEC" NUMBER(6,0), "NR_KON" NUMBER(10,0), "DATA_ZL" DATE, "D_WYS" DATE, "IL_POZ" NUMBER(3,0), "NR_ODDZ" NUMBER(2,0), "ROK" NUMBER(4,0), "MIES" NUMBER(2,0), "FORMA_WPROW" VARCHAR2(1 BYTE), "DO_PRODUKCJI" NUMBER(1,0), "INCOTERMS" VARCHAR2(3 BYTE), "WAR_PLAT" VARCHAR2(2 BYTE), "RABAT" NUMBER(5,2), "DATA_DOST" DATE, "ADRES_DOST" NUMBER(10,0), "D_ODP" DATE, "BAZA_DOST" VARCHAR2(40 BYTE), "TERMIN_ODP" DATE, "NAZ_IM" VARCHAR2(25 BYTE), "NR_KOMP_ZAM" NUMBER(10,0), "NR_ZAM" NUMBER(6,0), "RODZ_PLAT" VARCHAR2(2 BYTE), "IL_DNI" NUMBER(3,0), "WALUTA" VARCHAR2(4 BYTE), "NAZ_DOST" VARCHAR2(50 BYTE), "MIASTO" VARCHAR2(30 BYTE), "ADRES" VARCHAR2(31 BYTE), "NIP" VARCHAR2(20 BYTE), "PANSTWO" VARCHAR2(20 BYTE)) ;
--------------------------------------------------------
--  DDL for Table OFERTY_POZ
--------------------------------------------------------

  CREATE TABLE "OFERTY_POZ" ("NR_KOMP_OF" NUMBER(10,0), "NR_OFERTY" NUMBER(6,0), "NR_POZ" NUMBER(3,0), "KOD_STR" VARCHAR2(50 BYTE), "KOD_DOST" VARCHAR2(50 BYTE), "NAZWA_DOST" VARCHAR2(100 BYTE), "IL_SPRZED" NUMBER(18,6), "JEDNOSTKA" VARCHAR2(10 BYTE), "DATA_DOST" DATE, "CENA" NUMBER(7,2), "NR_ODDZ" NUMBER(2,0), "ROK" NUMBER(4,0), "MIES" NUMBER(2,0), "STATUS_POZ" NUMBER(2,0), "STORNO" NUMBER(1,0), "WYS_RABATU" NUMBER(5,2), "WALUTA" VARCHAR2(4 BYTE)) ;
--------------------------------------------------------
--  DDL for Table OFERTY_POZK
--------------------------------------------------------

  CREATE TABLE "OFERTY_POZK" ("NR_KOMP_OF" NUMBER(10,0), "NR_OFERTY" NUMBER(6,0), "NR_POZ" NUMBER(3,0), "KOD_STR" VARCHAR2(50 BYTE), "KOD_DOST" VARCHAR2(50 BYTE), "NAZWA_DOST" VARCHAR2(100 BYTE), "IL_SPRZED" NUMBER(18,6), "JEDNOSTKA" VARCHAR2(10 BYTE), "DATA_DOST" DATE, "CENA" NUMBER(7,2), "NR_ODDZ" NUMBER(2,0), "ROK" NUMBER(4,0), "MIES" NUMBER(2,0), "STATUS_POZ" NUMBER(2,0), "STORNO" NUMBER(1,0), "WYS_RABATU" NUMBER(5,2), "WALUTA" VARCHAR2(4 BYTE)) ;
--------------------------------------------------------
--  DDL for Table OKNA_DEK
--------------------------------------------------------

  CREATE TABLE "OKNA_DEK" ("IDENT" NUMBER(10,0), "LP" NUMBER(10,0), "RODZAJ" VARCHAR2(1 BYTE), "WINIEN" VARCHAR2(10 BYTE), "MA" VARCHAR2(10 BYTE)) ;
--------------------------------------------------------
--  DDL for Table OKNA_KONTA
--------------------------------------------------------

  CREATE TABLE "OKNA_KONTA" ("NR_ODD" NUMBER(2,0), "KONTO_WN" VARCHAR2(10 BYTE), "KONTO_MA" VARCHAR2(10 BYTE), "BRUTTO" VARCHAR2(10 BYTE)) ;
--------------------------------------------------------
--  DDL for Table OKNA_KONTA_N
--------------------------------------------------------

  CREATE TABLE "OKNA_KONTA_N" ("NUMER_ODDZIALU" NUMBER(2,0), "TYP_DOKUMENTU_SPRZEDAZY" CHAR(3 BYTE), "TYP_KONTRAHENTA" VARCHAR2(10 BYTE), "IDENT" NUMBER(10,0), "IDENT_FK" VARCHAR2(10 BYTE)) ;
--------------------------------------------------------
--  DDL for Table OKNA_ZAS1
--------------------------------------------------------

  CREATE TABLE "OKNA_ZAS1" ("TYP_DOK" VARCHAR2(5 BYTE), "TYP_KONTR" VARCHAR2(10 BYTE), "TYP_SPR" VARCHAR2(3 BYTE), "NR_ODD" NUMBER(2,0), "OPIS" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table OPADRESY
--------------------------------------------------------

  CREATE TABLE "OPADRESY" ("ODB_KOD" NUMBER(10,0), "ODB_DATA" DATE, "ODB_CZAS" CHAR(6 BYTE), "ODB_NAZW" VARCHAR2(50 BYTE), "NAD_KOD" NUMBER(10,0), "NAD_DATA" DATE, "NAD_CZAS" CHAR(6 BYTE), "NAD_NAZW" VARCHAR2(50 BYTE), "NR_INF" NUMBER(10,0), "ODB_USUN" NUMBER(1,0), "NAD_USUN" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table OPAKOUT_G
--------------------------------------------------------

  CREATE TABLE "OPAKOUT_G" ("NR_K_GRP" NUMBER(10,0), "ILE_OPAK" NUMBER(6,0), "DATA_P" DATE, "NR_TRASY" NUMBER(10,0), "NR_1_KLIENTA" NUMBER(10,0), "ILE_ZLECEN" NUMBER(6,0), "ILE_WAGA" NUMBER(7,1), "ILE_SAMOCH" NUMBER(2,0), "WAGA_Z_SAMOCH" NUMBER(7,1), "WAGA_N_SAMOCH" NUMBER(7,1), "NR_SAMOCH" VARCHAR2(12 BYTE), "KIEROWCA" VARCHAR2(50 BYTE), "NR_KLIENTA_TRANSP" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table OPAKOUT_H
--------------------------------------------------------

  CREATE TABLE "OPAKOUT_H" ("NR_K_PAKOW" NUMBER(10,0), "NR_KOL_OPAK" NUMBER(8,0), "NR_KOL_TYP_OPAK" NUMBER(8,0), "KOD_OPAK" VARCHAR2(18 BYTE), "TYP_OPAK" VARCHAR2(18 BYTE), "DATA_PRZYGOTOW" DATE, "DATA_PAKOW" DATE, "DATA_WYSYLKI" DATE, "WAGA_OPAK" NUMBER(8,2), "WAGA_SZYB" NUMBER(8,2), "NR_SPEDYCJI" NUMBER(10,0), "NR_KLIENTA" NUMBER(10,0), "NR_KOMP_ZLEC" NUMBER(10,0), "ILOSC_SZYB" NUMBER(5,0), "ILOSC_RZEDOW" NUMBER(3,0), "ILOSC_PIETER" NUMBER(3,0), "ROZMIARX" NUMBER(6,0), "ROZMIARY" NUMBER(6,0), "ROZMIARZ" NUMBER(6,0), "NR_GRUPY_PAK" NUMBER(10,0), "NR_K_STOJAKA_SPED" NUMBER(10,0), "NR_OZNACZ_OPAK" VARCHAR2(20 BYTE)) ;
--------------------------------------------------------
--  DDL for Table OPAKOUT_P
--------------------------------------------------------

  CREATE TABLE "OPAKOUT_P" ("NR_K_PAKOW" NUMBER(10,0), "NR_KOL" NUMBER(6,0), "NR_POZ_OPAK" NUMBER(6,0), "NR_RZEDU" NUMBER(6,0), "NR_KOLUMNY" NUMBER(6,0), "NR_PIETRA" NUMBER(6,0), "NR_ZAMOW" NUMBER(10,0), "NR_POZ_ZAM" NUMBER(5,0), "NUMER_SZT" NUMBER(5,0), "ID_OPAK" NUMBER(10,0), "NR_PDGR" NUMBER(8,0)) ;
--------------------------------------------------------
--  DDL for Table OPAKOUT_PG
--------------------------------------------------------

  CREATE TABLE "OPAKOUT_PG" ("NR_K_GRP" NUMBER(10,0), "NR_PODGR" NUMBER(10,0), "SUMA_WAGI" NUMBER(9,3), "SUMA_GRUB" NUMBER(7,1), "SUMA_POW" NUMBER(8,2), "SUMA_SZYB" NUMBER(8,0), "MAX_SZER" NUMBER(5,0), "MIN_SZER" NUMBER(5,0), "MAX_WYS" NUMBER(5,0), "MIN_WYS" NUMBER(5,0), "SRED_SZER" NUMBER(5,0), "OPIS_OZNACZ_GR" VARCHAR2(30 BYTE)) ;
--------------------------------------------------------
--  DDL for Table OPAKOUT_PK
--------------------------------------------------------

  CREATE TABLE "OPAKOUT_PK" ("NR_K_OPAK" NUMBER(10,0), "NR_PIETRA" NUMBER(3,0), "NR_RZEDU" NUMBER(4,0), "ZLEC1" NUMBER(8,0), "POZ1" NUMBER(5,0), "SZT1" NUMBER(6,0), "SZER1" NUMBER(5,0), "WYS1" NUMBER(5,0), "GR_PAK1" NUMBER(5,1), "WAGA1" NUMBER(5,1), "OPIS1" VARCHAR2(30 BYTE), "ZLEC2" NUMBER(8,0), "POZ2" NUMBER(5,0), "SZT2" NUMBER(5,0), "SZER2" NUMBER(5,0), "WYS2" NUMBER(5,0), "GR_PAK2" NUMBER(5,1), "WAGA2" NUMBER(5,1), "OPIS2" VARCHAR2(30 BYTE), "ZLEC3" NUMBER(8,0), "POZ3" NUMBER(5,0), "SZT3" NUMBER(5,0), "SZER3" NUMBER(5,0), "WYS3" NUMBER(5,0), "GR_PAK3" NUMBER(5,1), "WAGA3" NUMBER(5,1), "OPIS3" VARCHAR2(30 BYTE), "ZLEC4" NUMBER(8,0), "POZ4" NUMBER(6,0), "SZT4" NUMBER(5,0), "SZER4" NUMBER(5,0), "WYS4" NUMBER(5,0), "GR_PAK4" NUMBER(5,1), "WAGA4" NUMBER(5,1), "OPIS4" VARCHAR2(30 BYTE), "ZLEC5" NUMBER(8,0), "POZ5" NUMBER(6,0), "SZT5" NUMBER(5,0), "SZER5" NUMBER(5,0), "WYS5" NUMBER(5,0), "GR_PAK5" NUMBER(5,1), "WAGA5" NUMBER(5,1), "OPIS5" VARCHAR2(30 BYTE), "SZER_RZ" NUMBER(5,0), "WYS_RZ" NUMBER(5,0), "GRUB_RZ" NUMBER(5,1), "WAGA_RZ" NUMBER(5,1)) ;
--------------------------------------------------------
--  DDL for Table OPAKOUT_SZ
--------------------------------------------------------

  CREATE TABLE "OPAKOUT_SZ" ("ZLEC" NUMBER(8,0), "POZ" NUMBER(6,0), "SZT" NUMBER(6,0), "SZER" NUMBER(6,0), "WYS" NUMBER(6,0), "GRUB" NUMBER(5,1), "WAGA" NUMBER(6,2), "OPIS" VARCHAR2(30 BYTE), "NR_KOMP_STOJ" NUMBER(6,0), "NR_RZEDU" NUMBER(4,0), "NR_KOL" NUMBER(4,0), "NR_PIETRA" NUMBER(3,0), "GR_PAK" NUMBER(8,0), "ZAZNACZ" NUMBER(1,0), "NR_PDGR" NUMBER(8,0)) ;
--------------------------------------------------------
--  DDL for Table OPAKOUT_Z
--------------------------------------------------------

  CREATE TABLE "OPAKOUT_Z" ("NR" NUMBER(10,0), "NR_K_GR" NUMBER(10,0), "ILE_POZ" NUMBER(5,0), "ILE_SZT" NUMBER(6,0), "ILE_M2" NUMBER(7,1), "ILE_KG" NUMBER(7,1), "NR_KLI" NUMBER(8,0), "NR_ZLEC" NUMBER(8,0), "GRUB_PAK" NUMBER(7,1), "SZT_DO_WYS" NUMBER(6,0), "POW_ZALAD" NUMBER(7,1)) ;
--------------------------------------------------------
--  DDL for Table OPAKOWANIA
--------------------------------------------------------

  CREATE TABLE "OPAKOWANIA" ("NUMER" NUMBER(4,0), "NAZWA" VARCHAR2(10 BYTE)) ;
--------------------------------------------------------
--  DDL for Table OPBCK006
--------------------------------------------------------

  CREATE TABLE "OPBCK006" ("NR_KAT" NUMBER(4,0), "NAZ_KAT" VARCHAR2(50 BYTE), "NAZ_SKROC" VARCHAR2(6 BYTE), "KOL_SORT" NUMBER(2,0), "IL_ZE_ZLEC" NUMBER(18,6), "STRATY" NUMBER(5,2), "IL_SZT" NUMBER(14,0), "WYBRANE" NUMBER(1,0), "TYP_KATALOG" VARCHAR2(18 BYTE), "ILE_ZALEG" NUMBER(14,0), "M2_ZALEG" NUMBER(18,6), "ILE_Z_WYPRZEDZ" NUMBER(14,0), "M2_Z_WYPRZEDZ" NUMBER(18,6), "M2_JUZ_WYC" NUMBER(18,6), "SZT_JUZ_WYC" NUMBER(14,0), "TRYB_C" VARCHAR2(1 BYTE), "NR_INST_C" NUMBER(10,0), "NR_ZM_POCZ" NUMBER(10,0), "NR_INST_PRZEZN" NUMBER(10,0), "TRYB_WYBORU" VARCHAR2(1 BYTE), "INDEKS" VARCHAR2(128 BYTE), "NR_KOMP_LISTY" NUMBER(10,0), "ILE_STOJAKÓW" NUMBER(5,0), "NR_OST_STOJAKA" NUMBER(5,0), "NR_POZ_NA_OST_STOJAKU" NUMBER(5,0)) ;
--------------------------------------------------------
--  DDL for Table OPERATORZY
--------------------------------------------------------

  CREATE TABLE "OPERATORZY" ("ID" VARCHAR2(10 BYTE), "NAZWA" VARCHAR2(30 BYTE), "IM_NAZW" VARCHAR2(50 BYTE), "NR_ODDZ" NUMBER(2,0), "NR_OPER" NUMBER(10,0), "TEL" VARCHAR2(20 BYTE) DEFAULT '', "TEL_KOM" VARCHAR2(20 BYTE) DEFAULT '', "MAIL" VARCHAR2(32 BYTE) DEFAULT '', "NR_KOMUNIKAT" VARCHAR2(32 BYTE) DEFAULT '', "OPIS_KOMUNIKAT" VARCHAR2(32 BYTE) DEFAULT '', "NR_KADROWY" NUMBER(10,0) DEFAULT 0, "NR_FAC" NUMBER(10,0) DEFAULT 0, "NR_DZIAL" NUMBER(4,0) DEFAULT 0, "AKT" NUMBER(1,0) DEFAULT 1) ;
--------------------------------------------------------
--  DDL for Table OPER_GR
--------------------------------------------------------

  CREATE TABLE "OPER_GR" ("NR_OPER" NUMBER(10,0), "NUMER_GRUPY" NUMBER(10,0), "WSK" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table OPER_KL
--------------------------------------------------------

  CREATE TABLE "OPER_KL" ("NR_OPER" NUMBER(10,0), "NUMER_KLUCZA" NUMBER(10,0), "WSK" NUMBER(1,0), "WSKG" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table OPER_SROB
--------------------------------------------------------

  CREATE TABLE "OPER_SROB" ("NK_OPER" NUMBER(30,15), "NAPIS" VARCHAR2(20 BYTE)) ;
--------------------------------------------------------
--  DDL for Table OPGRUPY
--------------------------------------------------------

  CREATE TABLE "OPGRUPY" ("NR_KOMP_GR" NUMBER(10,0), "NR_OPER" NUMBER(10,0), "NR_ODDZ" NUMBER(2,0), "NAZ_GR" VARCHAR2(50 BYTE), "OPIS_GRUPY" VARCHAR2(100 BYTE), "WSKAZNIK" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table OPINFO
--------------------------------------------------------

  CREATE TABLE "OPINFO" ("NR_INFORM" NUMBER(10,0), "TEMAT" VARCHAR2(50 BYTE), "INFO" VARCHAR2(250 BYTE)) ;
--------------------------------------------------------
--  DDL for Table OPISY_ET
--------------------------------------------------------

  CREATE TABLE "OPISY_ET" ("NUMER" NUMBER(10,0), "OPIS" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table OPISYT
--------------------------------------------------------

  CREATE TABLE "OPISYT" ("RODZAJ" NUMBER(10,0), "NUMER" NUMBER(10,0), "OPIS" VARCHAR2(100 BYTE), "OPIS_LANG" VARCHAR2(100 BYTE) DEFAULT '') ;
--------------------------------------------------------
--  DDL for Table OPT_NR
--------------------------------------------------------

  CREATE TABLE "OPT_NR" ("NR_OPT" NUMBER(10,0), "TYP_KAT" VARCHAR2(9 BYTE), "SZKLO_W_OPT" VARCHAR2(15 BYTE), "IL_TAF" NUMBER(4,0), "WYC_NETTO" NUMBER(14,4), "WYC_BRUTTO" NUMBER(14,4), "NR_KAT" NUMBER(4,0), "FLAG_REAL" NUMBER(2,0), "POW_ODP" NUMBER(10,4) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table OPT_TAF
--------------------------------------------------------

  CREATE TABLE "OPT_TAF" ("NR_OPT" NUMBER(10,0), "NR_TAFLI" NUMBER(4,0), "TYP_KAT" VARCHAR2(9 BYTE), "SZER" NUMBER(4,0), "WYS" NUMBER(4,0), "WYC_NETTO" NUMBER(14,4), "WYC_BRUTTO" NUMBER(14,4), "NR_KAT" NUMBER(4,0), "NR_KOMP_ZMW" NUMBER(10,0), "NR_KOMP_BRYG" NUMBER(10,0), "D_WYK" DATE, "ZM_WYK" NUMBER(1,0), "NR_KOMP_INSTAL" NUMBER(10,0), "NR_OPER" VARCHAR2(10 BYTE), "D_MODYF" DATE, "NR_KOMP_ZMP" NUMBER(10,0), "D_PLAN" DATE, "ZM_PLAN" NUMBER(1,0), "NR_PAK" NUMBER(10,0), "POZ_W_PAK" NUMBER(4,0), "FLAG" NUMBER(1,0), "INDEKS" VARCHAR2(128 BYTE) DEFAULT '', "ZN_MM" NUMBER(2,0) DEFAULT 0, "NR_DOST" VARCHAR2(20 BYTE) DEFAULT '', "NK_WYM" NUMBER(10,0) DEFAULT 0, "POW_ODP" NUMBER(10,4) DEFAULT 0, "NR_INST_PLAN" NUMBER(10,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table OPT_ZLEC
--------------------------------------------------------

  CREATE TABLE "OPT_ZLEC" ("NR_OPT" NUMBER(10,0), "NR_TAFLI" NUMBER(4,0), "NR_ZLEC" NUMBER(6,0), "NR_KOMP_ZLEC" NUMBER(10,0), "NR_POZ" NUMBER(3,0), "IL_WYC" NUMBER(14,0), "WYC_NETTO" NUMBER(14,4), "WYC_BRUTTO" NUMBER(14,4), "NR_KAT" NUMBER(4,0), "SZER" NUMBER(4,0) DEFAULT 0, "WYS" NUMBER(4,0) DEFAULT 0, "STRATY" NUMBER(3,2) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table OPWIEZY
--------------------------------------------------------

  CREATE TABLE "OPWIEZY" ("NR_KOMP_GR" NUMBER(10,0), "NR_OPER" NUMBER(10,0), "NR_ODDZ" NUMBER(2,0), "NAZWISKO" VARCHAR2(50 BYTE), "KOD" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table OSTATNIE_ZAMKN
--------------------------------------------------------

  CREATE TABLE "OSTATNIE_ZAMKN" ("NR_MAG" NUMBER(3,0), "NR_OKRESU" NUMBER(4,0), "DATA_POCZ" DATE, "DATA_KONC" DATE, "PRZENIESIENIE" NUMBER(1,0), "NR_AI" NUMBER(10,0), "NR_KN" NUMBER(10,0), "NR_LN" NUMBER(10,0), "NR_SP" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table PAM_C
--------------------------------------------------------

  CREATE TABLE "PAM_C" ("NR_ZEST" NUMBER(10,0) DEFAULT 0, "NR_PAR" NUMBER(10,0) DEFAULT 0, "NR_KONF" NUMBER(10,0) DEFAULT 0, "DANE" VARCHAR2(500 BYTE) DEFAULT ' ', "LAST_MOD" VARCHAR2(30 BYTE) DEFAULT ' ') ;
--------------------------------------------------------
--  DDL for Table PAM_E
--------------------------------------------------------

  CREATE TABLE "PAM_E" ("RODZ_KONF" VARCHAR2(5 BYTE) DEFAULT ' ', "NR_KONF" NUMBER(10,0) DEFAULT 0, "NR_POZ" NUMBER(10,0) DEFAULT 0, "TEKST" VARCHAR2(500 BYTE) DEFAULT ' ', "OPIS" VARCHAR2(100 BYTE) DEFAULT ' ') ;
--------------------------------------------------------
--  DDL for Table PAM_E_NAGL
--------------------------------------------------------

  CREATE TABLE "PAM_E_NAGL" ("RODZ_KONF" VARCHAR2(5 BYTE) DEFAULT ' ', "NR_KONF" NUMBER(10,0) DEFAULT 0, "OPIS" VARCHAR2(30 BYTE) DEFAULT ' ', "OPERATOR" VARCHAR2(10 BYTE) DEFAULT ' ', "STACJA" VARCHAR2(30 BYTE) DEFAULT ' ', "UZYTK" VARCHAR2(30 BYTE), "DATA_MOD" DATE DEFAULT '1901/01/01', "CZAS_MOD" CHAR(6 BYTE) DEFAULT '000000') ;
--------------------------------------------------------
--  DDL for Table PAM_ET
--------------------------------------------------------

  CREATE TABLE "PAM_ET" ("NUMER_KOMPUTEROWY" NUMBER(10,0), "TEKST" VARCHAR2(200 BYTE), "OPIS" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table PAML1
--------------------------------------------------------

  CREATE TABLE "PAML1" ("NR_LISTY" NUMBER(10,0), "D_UTWORZ" DATE, "D_ZAP" DATE, "GODZ_ZAP" CHAR(6 BYTE), "D_WYK" DATE, "ZM_WYK" NUMBER(1,0), "TYP_NUM" NUMBER(1,0), "IL_W_PRZEGR" NUMBER(6,0), "PRZEGR_W_ST" NUMBER(6,0), "IL_W_SERII" NUMBER(6,0), "SKOK_ZLEC_W_NUM" NUMBER(6,0), "SKOK_GR_W_NUMC" NUMBER(6,0), "SKOK_GR_W_NUMS" NUMBER(6,0), "ILE_POZ_W_GRC" NUMBER(6,0), "ILE_POZ_W_NUMS" NUMBER(6,0), "PAR_REZ1" NUMBER(6,0), "PAR_REZ2" NUMBER(6,0), "PAR_REZ3" NUMBER(6,0), "NR_GR1" NUMBER(6,0), "NR_GRO" NUMBER(6,0), "NR_KOMP_INSTW" NUMBER(10,0), "ATR_WYBR" VARCHAR2(30 BYTE), "STORNO" NUMBER(1,0), "FLAG_ZATW" NUMBER(1,0), "ODCZ_WYN" NUMBER(1,0), "WPIS_PLAN" NUMBER(1,0), "LISTA_WYK" NUMBER(1,0), "OPIS" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table PAMLIST
--------------------------------------------------------

  CREATE TABLE "PAMLIST" ("NR_LISTY" NUMBER(10,0), "DATA" DATE, "NR_KOL" NUMBER(10,0), "NR_K_ZLEC" NUMBER(10,0), "NR_SZARZY" NUMBER(6,0), "LISTA_TRANSF" NUMBER(1,0), "DATA_TRANS" DATE, "LISTA_SORT" NUMBER(1,0), "DATA_SORT" DATE, "LISTA_ODCZ" NUMBER(1,0), "DAOA_ODCZ" DATE, "LISTA_DRUKOWANA" NUMBER(1,0), "LISTA_PLAN" NUMBER(1,0), "DATA_PLAN" DATE) ;
--------------------------------------------------------
--  DDL for Table PAMLIST_OZNACZ
--------------------------------------------------------

  CREATE TABLE "PAMLIST_OZNACZ" ("NR_LISTY" NUMBER(10,0) DEFAULT 0, "NR_KOL_STOJ" NUMBER(6,0) DEFAULT 0, "NR_KOMP_STOJ" NUMBER(10,0) DEFAULT 0, "NR_STOJ" VARCHAR2(7 BYTE) DEFAULT ' ', "TYP_STOJ" VARCHAR2(2 BYTE) DEFAULT ' ', "STRONA_STOJ" NUMBER(2,0) DEFAULT 0, "PIETRO_STOJ" NUMBER(2,0) DEFAULT 0, "OZN_MIEJSCA" VARCHAR2(10 BYTE) DEFAULT ' ', "NR_INSTAL" NUMBER(10,0) DEFAULT 0, "NR_NASTEPN" NUMBER(10,0) DEFAULT 0, "NR_MARSZRUTY" NUMBER(6,0) DEFAULT 0, "ILE_INSTAL" NUMBER(4,0) DEFAULT 0, "SYMBOL_TRASY" VARCHAR2(200 BYTE) DEFAULT ' ', "SORT_STOJ" NUMBER(2,0) DEFAULT 0, "KOLOR_FLAGI" VARCHAR2(4 BYTE) DEFAULT ' ', "MARKER" VARCHAR2(2 BYTE) DEFAULT ' ') ;
--------------------------------------------------------
--  DDL for Table PAMLIST_STOJ
--------------------------------------------------------

  CREATE TABLE "PAMLIST_STOJ" ("NR_LISTY" NUMBER(10,0), "DATA" DATE, "NR_KOL" NUMBER(10,0), "SZKLO_NR_KAT" NUMBER(6,0), "SZKLO_TYP_KAT" VARCHAR2(9 BYTE), "NR_K_ZLEC" NUMBER(10,0), "NR_SZARZY" NUMBER(8,0), "NR_PODGRUPY" NUMBER(8,0), "NR_INSTALACJI" NUMBER(6,0), "ILE_SZYB" NUMBER(6,0), "ILE_M2" NUMBER(6,0), "ILE_WYSLANYCH" NUMBER(10,0) DEFAULT 0, "SEIA" NUMBER(8,0), "OPIS_STOJ" VARCHAR2(50 BYTE), "UWAGI" VARCHAR2(201 BYTE) DEFAULT '') ;
--------------------------------------------------------
--  DDL for Table PAPIERY
--------------------------------------------------------

  CREATE TABLE "PAPIERY" ("NK_ZAP" NUMBER(10,0), "DATA_ZAP" DATE, "CZAS_ZAP" CHAR(6 BYTE), "ODD_ZAP" NUMBER(2,0), "OP_ZAP" VARCHAR2(50 BYTE), "NK_KL" NUMBER(10,0), "ZLEC_KL" VARCHAR2(50 BYTE), "DATA_ZLEC" DATE, "UWAGI" VARCHAR2(500 BYTE), "NAZ_ZB" VARCHAR2(30 BYTE), "NK_ZLEC" NUMBER(10,0), "DANE" LONG RAW) ;
--------------------------------------------------------
--  DDL for Table PAPIERYN
--------------------------------------------------------

  CREATE TABLE "PAPIERYN" ("NK_ZAP" NUMBER(10,0), "DATA_ZAP" DATE, "CZAS_ZAP" CHAR(6 BYTE), "ODD_ZAP" NUMBER(2,0), "OP_ZAP" VARCHAR2(50 BYTE), "NK_KL" NUMBER(10,0), "ZLEC_KL" VARCHAR2(50 BYTE), "DATA_ZLEC" DATE, "UWAGI" VARCHAR2(500 BYTE), "NAZ_ZB" VARCHAR2(100 BYTE), "NK_ZLEC" NUMBER(10,0), "IDENT_POZYCJI" NUMBER(10,0), "NR_WARTSWY" NUMBER(3,0), "DANE" LONG RAW, "RODZAJ" VARCHAR2(1 BYTE), "TYP" VARCHAR2(10 BYTE)) ;
--------------------------------------------------------
--  DDL for Table PAPIERYN1
--------------------------------------------------------

  CREATE TABLE "PAPIERYN1" ("NK_ZLEC" NUMBER(10,0), "ID_POZ" NUMBER(10,0), "NR_W" NUMBER(3,0), "RODZAJ" VARCHAR2(1 BYTE), "ILOSC" NUMBER(5,0)) ;
--------------------------------------------------------
--  DDL for Table PARAM_T
--------------------------------------------------------

  CREATE TABLE "PARAM_T" ("KOD" NUMBER(3,0), "WARTOSC" VARCHAR2(20 BYTE), "OPIS" VARCHAR2(100 BYTE), "OPIS_LANG" VARCHAR2(100 BYTE) DEFAULT '') ;
--------------------------------------------------------
--  DDL for Table PARAM_TS
--------------------------------------------------------

  CREATE TABLE "PARAM_TS" ("KOD" NUMBER(3,0), "WARTOSC" VARCHAR2(20 BYTE), "OPIS" VARCHAR2(100 BYTE), "OPIS_LANG" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table PARAM_WG_GR
--------------------------------------------------------

  CREATE TABLE "PARAM_WG_GR" ("NR_KOMP_GR" NUMBER(10,0), "NR_KOMP_OBR" NUMBER(10,0), "NR_KOL_PARAM" NUMBER(6,0), "GRUB" NUMBER(6,3), "WSP" NUMBER(8,3), "WSP_PRZEL" NUMBER(6,3)) ;
--------------------------------------------------------
--  DDL for Table PARCEN
--------------------------------------------------------

  CREATE TABLE "PARCEN" ("MARZA_G" NUMBER(7,2), "KOSZT_ST" NUMBER(14,4), "MNOZ_SUR" NUMBER(7,2), "ZAK_OD1" NUMBER(6,4), "ZAK_DO1" NUMBER(6,4), "RODZ_CEN1" VARCHAR2(4 BYTE), "WSP1" NUMBER(6,4), "ZAK_OD2" NUMBER(6,4), "ZAK_DO2" NUMBER(6,4), "RODZ_CEN2" VARCHAR2(4 BYTE), "WSP2" NUMBER(6,4), "ZAK_OD3" NUMBER(6,4), "ZAK_DO3" NUMBER(6,4), "RODZ_CEN3" VARCHAR2(4 BYTE), "WSP3" NUMBER(6,4), "ZAK_OD4" NUMBER(6,4), "ZAK_DO4" NUMBER(6,4), "RODZ_CEN4" VARCHAR2(4 BYTE), "WSP4" NUMBER(6,4), "DOP_KSZT" NUMBER(5,2), "DOP_SZAB" NUMBER(5,2), "DOP_WAGA" NUMBER(14,4), "DOP_ZA_WAGI" NUMBER(14,4), "DOMYSLNY_RABAT_ZA_HURT" NUMBER(5,2), "DOMYSLNY_RABAT_ZA_POLHURT" NUMBER(5,2), "M_MIN_DLA_WYR" NUMBER(6,3), "M_MIN_DLA_FORM" NUMBER(6,3), "M_MIN_DLA_TOW" NUMBER(6,3), "D_KSZT_1" NUMBER(5,2), "D_SZABL_1" NUMBER(5,2), "D_LIN_1" NUMBER(5,2), "D_TROJK_1" NUMBER(5,2), "D_KSZT_2" NUMBER(5,2), "D_SZABL_2" NUMBER(5,2), "D_LIN_2" NUMBER(5,2), "D_TROJK_2" NUMBER(5,2), "D_KSZT_3" NUMBER(5,2), "D_SZABL_3" NUMBER(5,2), "D_LIN_3" NUMBER(5,2), "D_TROJK_3" NUMBER(5,2), "D_KSZT_4" NUMBER(5,2), "D_SZABL_4" NUMBER(5,2), "D_LIN_4" NUMBER(5,2), "D_TROJK_4" NUMBER(5,2)) ;
--------------------------------------------------------
--  DDL for Table PARINST
--------------------------------------------------------

  CREATE TABLE "PARINST" ("NR_INST" NUMBER(3,0), "KOLEJN" NUMBER(2,0), "NAZ_INST" CHAR(61 BYTE), "NR_CZYN" NUMBER(4,0), "WYD_NOM" NUMBER(14,2), "WYD_MAX" NUMBER(14,2), "JEDN" CHAR(3 BYTE), "NR_KOMP_INST" NUMBER(10,0), "ZAKR_1_MIN" NUMBER(14,4), "ZAKR_1_MAX" NUMBER(14,4), "ZAKR_2_MIN" NUMBER(14,4), "ZAKR_2_MAX" NUMBER(14,4), "ZAKR_3_MIN" NUMBER(14,4), "ZAKR_3_MAX" NUMBER(14,4), "ZAKR_4_MIN" NUMBER(14,4), "ZAKR_4_MAX" NUMBER(14,4), "PON_POCZ" CHAR(6 BYTE), "PON_KON" CHAR(6 BYTE), "WT_POCZ" CHAR(6 BYTE), "WT_KON" CHAR(6 BYTE), "SR_POCZ" CHAR(6 BYTE), "SR_KON" CHAR(6 BYTE), "CZW_POCZ" CHAR(6 BYTE), "CZW_KON" CHAR(6 BYTE), "PI_POCZ" CHAR(6 BYTE), "PI_KON" CHAR(6 BYTE), "SOB_POCZ" CHAR(6 BYTE), "SOB_KON" CHAR(6 BYTE), "NIE_POCZ" CHAR(6 BYTE), "NIE_KON" CHAR(6 BYTE), "DLUGOSC_ZMIANY" NUMBER(2,0), "CZY_CZYNNA" VARCHAR2(3 BYTE), "CZAS_POPROCESOWY" NUMBER(2,0), "IND_BUD" VARCHAR2(30 BYTE), "CZAS_MIN" NUMBER(2,0), "CZY_GIET" NUMBER(1,0), "NAZ2" VARCHAR2(60 BYTE), "CZY_OBR_STALA" NUMBER(1,0) DEFAULT 0, "RODZ_SUR" CHAR(3 BYTE) DEFAULT '', "SZER_MAX" NUMBER(4,0) DEFAULT 0, "WYS_MAX" NUMBER(4,0) DEFAULT 0, "NR_WYDR" NUMBER(5,0) DEFAULT 0, "IDENT_BUD_WYL" VARCHAR2(30 BYTE), "SORT" NUMBER(2,0), "CZY_GR_PLAN" NUMBER(1,0) DEFAULT 0, "RODZ_PLAN" NUMBER(1,0) DEFAULT 0, "NR_INST_MIN" NUMBER(10,0) DEFAULT 0, "NR_INST_MAX" NUMBER(10,0) DEFAULT 0, "FL_CUTMON" NUMBER(1,0) DEFAULT 0, "SZER_MIN" NUMBER(4,0) DEFAULT 0, "WYS_MIN" NUMBER(4,0) DEFAULT 0, "NR_INST_WYL" NUMBER(10,0) DEFAULT 0, "CZY_NA_PLO" NUMBER(1,0) DEFAULT 1, "NR_INST_POW" NUMBER(10,0) DEFAULT 0, "TY_INST" VARCHAR2(3 BYTE) DEFAULT ' ', "NR_MAG" NUMBER(3,0) DEFAULT 0, "GR_INST" NUMBER(5,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table PAR_STRUKT
--------------------------------------------------------

  CREATE TABLE "PAR_STRUKT" ("NR_KOL_PARAM" NUMBER(4,0), "NAZWA_PARAM" VARCHAR2(200 BYTE), "SYMBOL_PARAM" VARCHAR2(30 BYTE), "NR_NORMY_PARAM" VARCHAR2(30 BYTE), "TYP_DEKLAR" NUMBER(4,0), "JEDNOSTKA_MIARY" VARCHAR2(30 BYTE), "FORMAT_ZAPISU" VARCHAR2(30 BYTE), "PAR_POMOCN_1" VARCHAR2(30 BYTE), "PAR_POMOCN_2" NUMBER(9,4), "FLAG_WPROW" NUMBER(1,0), "TRYB_WYDR" NUMBER(3,0), "NR_CZCIONKI" NUMBER(4,0), "ILE_WIERSZY" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table PELKONTR
--------------------------------------------------------

  CREATE TABLE "PELKONTR" ("NR_KON" NUMBER(10,0), "PEL_NAZ" VARCHAR2(200 BYTE)) ;
--------------------------------------------------------
--  DDL for Table PELPLAT
--------------------------------------------------------

  CREATE TABLE "PELPLAT" ("NR_FAKT" NUMBER(10,0), "PEL_NAZ" VARCHAR2(200 BYTE)) ;
--------------------------------------------------------
--  DDL for Table PINST_DOD
--------------------------------------------------------

  CREATE TABLE "PINST_DOD" ("NR_KOMP_INST" NUMBER(10,0), "TYP_KAT" VARCHAR2(9 BYTE), "GRUB_OD" NUMBER(6,3), "GRUB_DO" NUMBER(6,3), "WSP_PRZEL" NUMBER(6,3), "CZAS_JEDN_OBR" CHAR(6 BYTE) DEFAULT '000000') ;
--------------------------------------------------------
--  DDL for Table PLAN_TABLE
--------------------------------------------------------

  CREATE TABLE "PLAN_TABLE" ("STATEMENT_ID" VARCHAR2(30 BYTE), "TIMESTAMP" DATE, "REMARKS" VARCHAR2(80 BYTE), "OPERATION" VARCHAR2(30 BYTE), "OPTIONS" VARCHAR2(255 BYTE), "OBJECT_NODE" VARCHAR2(128 BYTE), "OBJECT_OWNER" VARCHAR2(30 BYTE), "OBJECT_NAME" VARCHAR2(30 BYTE), "OBJECT_INSTANCE" NUMBER(*,0), "OBJECT_TYPE" VARCHAR2(30 BYTE), "OPTIMIZER" VARCHAR2(255 BYTE), "SEARCH_COLUMNS" NUMBER, "ID" NUMBER(*,0), "PARENT_ID" NUMBER(*,0), "POSITION" NUMBER(*,0), "COST" NUMBER(*,0), "CARDINALITY" NUMBER(*,0), "BYTES" NUMBER(*,0), "OTHER_TAG" VARCHAR2(255 BYTE), "PARTITION_START" VARCHAR2(255 BYTE), "PARTITION_STOP" VARCHAR2(255 BYTE), "PARTITION_ID" NUMBER(*,0), "OTHER" LONG, "DISTRIBUTION" VARCHAR2(30 BYTE), "CPU_COST" NUMBER(*,0), "IO_COST" NUMBER(*,0), "TEMP_SPACE" NUMBER(*,0)) ;
--------------------------------------------------------
--  DDL for Table POLWMAG
--------------------------------------------------------

  CREATE TABLE "POLWMAG" ("NR_WSP" NUMBER(2,0), "KOD" VARCHAR2(10 BYTE), "OPIS" VARCHAR2(160 BYTE)) ;
--------------------------------------------------------
--  DDL for Table POSTOJE
--------------------------------------------------------

  CREATE TABLE "POSTOJE" ("NR_KOMP_INST" NUMBER(10,0), "DATA" DATE, "ZMIANA" NUMBER(1,0), "CZAS" CHAR(6 BYTE), "DLUG_P" NUMBER(4,0), "NR_POST" NUMBER(10,0), "NR_KOMP_BRYG" NUMBER(10,0), "NR_KOMP_POST" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table POZBIL
--------------------------------------------------------

  CREATE TABLE "POZBIL" ("NR_KOMP" NUMBER(10,0), "NR_KOM_KART" NUMBER(10,0), "TYP_DOKUMENTU" VARCHAR2(3 BYTE), "ILOSC" NUMBER(14,6), "WARTOSC" NUMBER(14,2), "PLUS_MINUS" NUMBER(2,0), "GR_KOSZT" NUMBER(10,0), "NR_W_BILANSIE" NUMBER(5,0)) ;
--------------------------------------------------------
--  DDL for Table POZDOK
--------------------------------------------------------

  CREATE TABLE "POZDOK" ("TYP_DOK" VARCHAR2(3 BYTE), "DATA_D" DATE, "NR_DOK" NUMBER(8,0), "NR_POZ" NUMBER(5,0), "INDEKS" VARCHAR2(128 BYTE), "ILOSC_JR" NUMBER(14,0), "ILOSC_JP" NUMBER(14,6), "STAN1" NUMBER(14,6), "STAN2" NUMBER(14,6), "CENA_PRZYJ" NUMBER(14,4), "CEN_WYD" NUMBER(14,4), "STORNO" NUMBER(1,0), "NR_POZ_ZLEC" NUMBER(3,0), "CZY_DOD" VARCHAR2(1 BYTE), "ROK" NUMBER(4,0), "MIES" NUMBER(2,0), "NR_ODDZ" NUMBER(2,0), "NR_MAG" NUMBER(3,0), "NR_KOMP_DOK" NUMBER(10,0), "NR_KOMP_BAZ" NUMBER(10,0), "ZNACZNIK_KARTOTEKI" CHAR(3 BYTE), "STATUS_DOKUMENTU" NUMBER(1,0), "KOL_DOD" NUMBER(3,0), "ID_POZ_FAK" NUMBER(10,0), "CENA_NETTO" NUMBER(16,4), "C_NOMP" NUMBER(14,4) DEFAULT 0, "C_NOMW" NUMBER(14,4) DEFAULT 0, "SERIA" NUMBER(10,0) DEFAULT 0, "NR_DOK_ZROD" NUMBER(10,0) DEFAULT 0, "IL_SZT_STORNO" NUMBER(14,0) DEFAULT 0, "IL_JP_STORNO" NUMBER(14,6) DEFAULT 0, "NR_POZ_ZROD" NUMBER(5,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table POZ_GR_STR
--------------------------------------------------------

  CREATE TABLE "POZ_GR_STR" ("NR_GR_STR" NUMBER(10,0), "INDEKS" VARCHAR2(128 BYTE)) ;
--------------------------------------------------------
--  DDL for Table POZIOM_O
--------------------------------------------------------

  CREATE TABLE "POZIOM_O" ("POZIOM" NUMBER(10,0), "KLUCZ" VARCHAR2(31 BYTE), "OPIS" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table POZKARTOT
--------------------------------------------------------

  CREATE TABLE "POZKARTOT" ("NR_ODDZ" NUMBER(2,0), "NR_MAG" NUMBER(3,0), "INDEKS" VARCHAR2(128 BYTE), "CENA_ZAKUPU" NUMBER(14,4), "DATA_WPROW" DATE, "ILOSC" NUMBER(14,6), "ZN_KARTOTEKI" RAW(3), "NR" NUMBER(10,0), "NR_POZ_DOK" NUMBER(5,0), "STATUS" NUMBER(1,0), "NR_KOMP_ZLEC" NUMBER(10,0), "NR_POZ_ZLEC" NUMBER(3,0), "DODATEK" VARCHAR2(1 BYTE), "DATA_ZAPASU" DATE, "SERIA" NUMBER(10,0) DEFAULT 0, "CENA_SPRZED" NUMBER(14,4) DEFAULT 0, "NR_DOK_ZROD" NUMBER(10,0) DEFAULT 0, "NR_DOST" VARCHAR2(20 BYTE) DEFAULT '', "NR_POZ_ZROD" NUMBER(5,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table POZKARTPOP
--------------------------------------------------------

  CREATE TABLE "POZKARTPOP" ("NR_ODDZ" NUMBER(2,0), "NR_MAG" NUMBER(3,0), "INDEKS" VARCHAR2(128 BYTE), "CENA_ZAKUPU" NUMBER(14,4), "DATA_WPROW" DATE, "ILOSC" NUMBER(18,6), "ZN_KARTOTEKI" RAW(3), "NR" NUMBER(10,0), "NR_POZ_DOK" NUMBER(5,0), "STATUS" NUMBER(1,0), "NR_KOMP_ZLEC" NUMBER(10,0), "NR_POZ_ZLEC" NUMBER(3,0), "DODATEK" VARCHAR2(1 BYTE), "DATA_ZAPASU" DATE, "SERIA" NUMBER(10,0) DEFAULT 0, "CENA_SPRZED" NUMBER(14,4) DEFAULT 0, "NR_DOK_ZROD" NUMBER(10,0) DEFAULT 0, "NR_DOST" VARCHAR2(20 BYTE) DEFAULT '', "NR_POZ_ZROD" NUMBER(5,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table POZKONTR
--------------------------------------------------------

  CREATE TABLE "POZKONTR" ("NR_KOMP_KONTR" NUMBER(10,0), "POZ_KONTR" NUMBER(4,0), "INDEKS" VARCHAR2(128 BYTE), "TYP_WYROBU" VARCHAR2(2 BYTE), "NAZ_DLA_KLI" VARCHAR2(65 BYTE), "RABAT" NUMBER(5,2), "CENA_UM" NUMBER(14,4), "ILOSC_MIN" NUMBER(17,2), "ILOSC_MAX" NUMBER(17,2), "POW_MIN" NUMBER(7,4), "POW_MAX" NUMBER(7,4), "WAGA_DOST" NUMBER(12,2), "DOPL_ZA_WAGE" NUMBER(12,2), "DOPL_ZA_KSZT" NUMBER(12,2), "DOPL_ZA_SZABLON" NUMBER(12,2), "ILOSC_PLAN" NUMBER(16,2), "ILOSC_ZREAL" NUMBER(16,2), "GWARANCJA" NUMBER(4,0), "RODZ_CENY" VARCHAR2(4 BYTE) DEFAULT 'z³/m', "CZAS_REALIZACJI" NUMBER(4,0), "POPRAWKI" NUMBER(1,0), "D_ZATW" DATE, "OP_ZATW" VARCHAR2(10 BYTE), "POZ_OK" NUMBER(2,0), "DOP_TROJ" NUMBER(12,2), "DOP_LIN" NUMBER(12,2), "NR_KOMP_RYS" NUMBER(10,0) DEFAULT 0, "KOL_WYDR" NUMBER(4,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table PRAC_WYK
--------------------------------------------------------

  CREATE TABLE "PRAC_WYK" ("NR_KOMP_INST" NUMBER(10,0), "NR_KOMP_ZM" NUMBER(10,0), "NR_BRYGADY" NUMBER(10,0), "NR_PRAC" NUMBER(10,0), "GODZ_PRZEPR" NUMBER(4,2), "ZALICZ_PREM" VARCHAR2(3 BYTE), "ZALICZ_PROC" NUMBER(6,2), "PREMIA" NUMBER(18,2), "POTR_PROC" NUMBER(6,2), "POTR_WART" NUMBER(18,2), "FM" NUMBER(18,2), "FLAG_ZATW" NUMBER(1,0), "NUMER_ODDZ" NUMBER(2,0), "MIESIAC" NUMBER(2,0), "ROK" NUMBER(4,0), "PREMIA_DOD" NUMBER(18,2), "UZAS_MNIEJ" VARCHAR2(100 BYTE), "GDZIE_RESZTA" NUMBER(1,0), "DZIEN" DATE, "ZM_WYK" NUMBER(1,0), "CZAS_WEJ" CHAR(6 BYTE) DEFAULT '000000', "D_REJ" DATE DEFAULT '1901/01/01', "CZAS_WYJ" CHAR(6 BYTE) DEFAULT '000000', "D_REJ_WYJ" DATE DEFAULT '1901/01/01', "NK_ZAP" NUMBER(10,0) DEFAULT 0, "G_PRZEPR_ORG" NUMBER(2,2) DEFAULT 0, "FL_POPR" NUMBER(1,0) DEFAULT 0, "OPER_MOD" VARCHAR2(10 BYTE) DEFAULT 0, "DATA_MOD" DATE DEFAULT '1901/01/01') ;
--------------------------------------------------------
--  DDL for Table PREMM
--------------------------------------------------------

  CREATE TABLE "PREMM" ("ROK" NUMBER(4,0), "MIES" NUMBER(2,0), "NR_PRAC" NUMBER(10,0), "SUMA" NUMBER(16,2), "DO_FM" NUMBER(16,2), "POTR" NUMBER(7,2), "K_POTR" NUMBER(16,2), "POTR_R" NUMBER(16,2), "SUMA_BFM" NUMBER(16,2), "Z_FM" NUMBER(16,2), "RAZEM" NUMBER(16,2), "ZATW" NUMBER(1,0), "NR_OP1" VARCHAR2(10 BYTE), "NR_OPER2" VARCHAR2(10 BYTE), "D_ZATW1" DATE, "D_ZATW2" DATE, "D_ANUL" DATE, "KTO_AN" VARCHAR2(10 BYTE), "NR_ODDZ" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table PROTPOZ
--------------------------------------------------------

  CREATE TABLE "PROTPOZ" ("TYP_DOK" VARCHAR2(3 BYTE), "NR_KOMP" NUMBER(10,0), "NR_PROT" NUMBER(6,0), "NR_POZ" NUMBER(3,0), "PRZEDM_OFERTY" VARCHAR2(50 BYTE), "CEN_OFER_1" NUMBER(7,2), "DDP_PLN_1" NUMBER(7,2), "CEN_OFER_2" NUMBER(7,2), "DDP_PLN_2" NUMBER(7,2), "CEN_OFER_3" NUMBER(7,2), "DDP_PLN_3" NUMBER(7,2), "CEN_OFER_4" NUMBER(7,2), "DDP_PLN_4" NUMBER(7,2), "STORNO" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table PROTWYB
--------------------------------------------------------

  CREATE TABLE "PROTWYB" ("TYP_DOK" VARCHAR2(3 BYTE), "NR_KOMP" NUMBER(10,0), "NR_PROT" NUMBER(6,0), "DATA_PROT" DATE, "OPIS" VARCHAR2(60 BYTE), "NR_OFER_1" NUMBER(6,0), "NR_KOMP_1" NUMBER(10,0), "NR_OFER_2" NUMBER(6,0), "NR_KOMP_2" NUMBER(10,0), "NR_OFER_3" NUMBER(6,0), "NR_KOMP_3" NUMBER(10,0), "NR_OFER_4" NUMBER(6,0), "NR_KOMP_4" NUMBER(10,0), "WALUTA_1" VARCHAR2(4 BYTE), "KURS_1" NUMBER(14,4), "WALUTA_2" VARCHAR2(4 BYTE), "KURS_2" NUMBER(14,4), "WALUTA_3" VARCHAR2(4 BYTE), "KURS_3" NUMBER(14,4), "WALUTA_4" VARCHAR2(4 BYTE), "KURS_4" NUMBER(14,4), "DOSTAWCA_1" NUMBER(10,0), "TERM_DOST_1" DATE, "TERM_PLAT_1" DATE, "INNE_WAR_1" VARCHAR2(60 BYTE), "DOSTAWCA_2" NUMBER(10,0), "TERM_DOST_2" DATE, "TERM_PLAT_2" DATE, "INNE_WAR_2" VARCHAR2(60 BYTE), "DOSTAWCA_3" NUMBER(10,0), "TERM_DOST_3" DATE, "TERM_PLAT_3" DATE, "INNE_WAR_3" VARCHAR2(60 BYTE), "DOSTAWCA_4" NUMBER(10,0), "TERM_DOST_4" DATE, "TERM_PLAT_4" DATE, "INNE_WAR_4" VARCHAR2(60 BYTE), "UZAS_JAKOS" VARCHAR2(160 BYTE), "UZAS_CEN" VARCHAR2(160 BYTE), "UZAS_T_DOST" VARCHAR2(160 BYTE), "UZAS_W_PLAT" VARCHAR2(160 BYTE), "UZAS_OPAK" VARCHAR2(160 BYTE), "UZAS_WYL_PODW" VARCHAR2(160 BYTE), "UZAS_INNE" VARCHAR2(160 BYTE), "STATUS" NUMBER(1,0), "DOST_WYBR" NUMBER(1,0), "STORNO" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table PZLECROB
--------------------------------------------------------

  CREATE TABLE "PZLECROB" ("NR_KOMP_ZLEC" NUMBER(10,0), "NR_POZ_ZLEC" NUMBER(6,0), "NR_SZTUKI" NUMBER(6,0), "NR_KOMP_SZYBY" NUMBER(10,0), "SORT_C" NUMBER(6,0), "SORT_M" NUMBER(6,0), "SORT_S" NUMBER(6,0), "STOJ_SP" NUMBER(6,0), "NR_ST_SP" NUMBER(6,0), "RZAD_SP" NUMBER(2,0), "BOK_POZ" NUMBER(5,0), "BOK_PION" NUMBER(5,0), "NR_K_INST" NUMBER(10,0), "DATA" DATE, "NR_K_ZM" NUMBER(10,0), "GRUB_PAK" NUMBER(4,0), "WAGA_PAK" NUMBER(9,3), "POLOZ" VARCHAR2(8 BYTE) DEFAULT '') ;
--------------------------------------------------------
--  DDL for Table RAP_MIES_GR_KONTRAH
--------------------------------------------------------

  CREATE TABLE "RAP_MIES_GR_KONTRAH" ("NR_KONTRAH" NUMBER(10,0), "NR_MIES" NUMBER(2,0), "ROK" NUMBER(4,0), "NR_KOMP_OST_FAKT" NUMBER(10,0), "SPRZEDAZ_CALK" NUMBER(14,2), "SPRZEDAZ_HURT_NETTO" NUMBER(14,2), "SPRZEDAZ_PROD_NETTO" NUMBER(14,2), "SPRZEDAZ_SZYB_ZESP" NUMBER(14,2), "ILOSC_SZYB_ZESP" NUMBER(14,4), "ILOSC_FORMATEK" NUMBER(14,4), "ILOSC_PRZETWORZ" NUMBER(14,4), "ILOSC_SUROWCA" NUMBER(14,4)) ;
--------------------------------------------------------
--  DDL for Table RAP_SP_DZ
--------------------------------------------------------

  CREATE TABLE "RAP_SP_DZ" ("NR_KONTR" NUMBER(10,0), "DATA_WYST" DATE, "MIES" NUMBER(2,0), "ROK" NUMBER(4,0), "GR_TOWAR" VARCHAR2(3 BYTE), "SPRZEDAZ" NUMBER(14,2), "ZESP_WART" NUMBER(14,2), "ZESP_IL" NUMBER(14,6), "ZESP_SRED" NUMBER(14,4), "HURT_WART" NUMBER(14,2), "HURT_IL" NUMBER(14,6), "HURT_SRED" NUMBER(14,4), "PRZET_WART" NUMBER(14,2), "PRZET_IL" NUMBER(14,6), "PRZET_SRED" NUMBER(14,4), "HART_WART" NUMBER(14,2), "HART_IL" NUMBER(14,6), "HART_SRED" NUMBER(14,4), "SIL_WART" NUMBER(14,2), "SIL_ILOSC" NUMBER(14,6), "SIL_SRED" NUMBER(14,4), "USLUGI" NUMBER(14,2), "PROD_MET" NUMBER(14,2), "CIE_ILOSC" NUMBER(10,0), "CIE_POW" NUMBER(14,6), "CIE_WAGA" NUMBER(14,6), "CIE_NETTO" NUMBER(14,2), "K1_ILOSC" NUMBER(10,0), "K1_POW" NUMBER(14,6), "K1_WAGA" NUMBER(14,6), "K1_NETTO" NUMBER(14,2), "K2_ILOSC" NUMBER(10,0), "K2_POW" NUMBER(14,6), "K2_WAGA" NUMBER(14,6), "K2_NETTO" NUMBER(14,2), "LAM_ILOSC" NUMBER(10,0), "LAM_POW" NUMBER(14,6), "LAM_NETTO" NUMBER(14,2), "SZPR_ILOSC" NUMBER(10,0), "SZPR_POW" NUMBER(14,6), "SZPR_NETTO" NUMBER(14,2), "M1_ILOSC" NUMBER(10,0), "M1_POW" NUMBER(14,6), "M1_NETTO" NUMBER(14,2), "M2_ILOSC" NUMBER(10,0), "M2_POW" NUMBER(14,6), "M2_NETTO" NUMBER(14,2), "M3_ILOSC" NUMBER(10,0), "M3_POW" NUMBER(14,6), "M3_NETTO" NUMBER(14,2), "SZAB_ILOSC" NUMBER(10,0), "SZAB_POW" NUMBER(14,6), "SZAB_NETTO" NUMBER(14,2), "SK11_ILOSC" NUMBER(10,0), "SK11_POW" NUMBER(14,6), "SK11_NETTO" NUMBER(14,2), "SG01_ILOSC" NUMBER(10,0), "SG01_POW" NUMBER(14,6), "SG01_NETTO" NUMBER(14,2), "SG02_ILOSC" NUMBER(10,0), "SG02_POW" NUMBER(14,6), "SG02_NETTO" NUMBER(14,2), "NRODDZ" NUMBER(6,0), "NROPIEK" NUMBER(6,0), "SG01_POWB" NUMBER(14,6), "SG02_POWB" NUMBER(14,6), "SK11_POWB" NUMBER(14,6)) ;
--------------------------------------------------------
--  DDL for Table RAP_ZYSK
--------------------------------------------------------

  CREATE TABLE "RAP_ZYSK" ("LP_114" NUMBER(10,0), "INDEKS_WYR" VARCHAR2(128 BYTE), "NR_KON" NUMBER(10,0), "SKROT_KON" VARCHAR2(15 BYTE), "NR_SPRZED" NUMBER(10,0), "POZ_SPRZED" NUMBER(10,0), "ILOSC" NUMBER(14,4), "KOSZT_JEDN" NUMBER(14,4), "KOSZT_PROD_RZ" NUMBER(17,2), "CENA_NETSPRZED" NUMBER(14,4), "WARTOSC_NETSPRZED" NUMBER(14,2), "ZYSK" NUMBER(10,2), "TYP_ZLECENIA" VARCHAR2(3 BYTE), "MM" NUMBER(12,2), "NR_KOMP_ZLEC" NUMBER(10,0), "NR_FAKTURY" NUMBER(10,0), "WART_FAKT_NETTO" NUMBER(14,2), "DATA" DATE, "TYP_FAKTURY" VARCHAR2(3 BYTE), "ZNACZNIK" VARCHAR2(3 BYTE), "MAGAZYN" NUMBER(3,0), "CENA_WYK_STD" NUMBER(14,4), "KOSZT_WYKON_STD" NUMBER(14,2), "ZYSK_STAND" NUMBER(14,2), "NR_GR_KOSZT_WYR" NUMBER(10,0), "SKR_TYP_FAKT" VARCHAR2(2 BYTE), "CZY_TO_PZ" NUMBER(1,0), "NR_NALICZ" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table RBG_MIN
--------------------------------------------------------

  CREATE TABLE "RBG_MIN" ("NR_KOMP_INSTAL" NUMBER(10,0), "POW_SRED" NUMBER(6,2), "RBG" NUMBER(14,4)) ;
--------------------------------------------------------
--  DDL for Table RDANET
--------------------------------------------------------

  CREATE TABLE "RDANET" ("NK_ZLEC" NUMBER(10,0), "NR_POZ" NUMBER(3,0), "TYP" NUMBER(3,0), "LINIA" VARCHAR2(500 BYTE)) ;
--------------------------------------------------------
--  DDL for Table RDANKODSZP
--------------------------------------------------------

  CREATE TABLE "RDANKODSZP" ("NR_K_ZLEC" NUMBER(10,0), "NR_POZ_ZLEC" NUMBER(5,0), "TYP" NUMBER(2,0), "KOLEJN" NUMBER(4,0), "RZAD" NUMBER(4,0), "POLOZ" NUMBER(6,1), "NR_MATERIALU" NUMBER(4,0)) ;
--------------------------------------------------------
--  DDL for Table RDANMATSZPR
--------------------------------------------------------

  CREATE TABLE "RDANMATSZPR" ("NR_K_ZLEC" NUMBER(10,0), "NR_P_ZLEC" NUMBER(5,0), "NR_MATER" NUMBER(5,0), "KOD_MATER" VARCHAR2(60 BYTE), "INDEKS_SZPR" VARCHAR2(128 BYTE), "RODZAJ" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table REJ_POB_SUR
--------------------------------------------------------

  CREATE TABLE "REJ_POB_SUR" ("NK" NUMBER(10,0), "INDEKS" VARCHAR2(128 BYTE), "NR_MAG" NUMBER(3,0), "NR_OPER" VARCHAR2(10 BYTE), "D_REJ" DATE, "T_REJ" CHAR(6 BYTE), "FLAG" NUMBER(2,0), "NR_KOMP_INST" NUMBER(10,0), "NR_KOMP_MM" NUMBER(10,0), "NR_KOMP_ZM" NUMBER(10,0), "ILOSC" NUMBER(14,0), "IL_NA_MM" NUMBER(14,0), "NR_OPT" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table REJ_POZ_REKL
--------------------------------------------------------

  CREATE TABLE "REJ_POZ_REKL" ("NR_KOMP_REKL" NUMBER(10,0), "NR_ODDZ" NUMBER(2,0), "NR_KOMP_ZLEC" NUMBER(10,0), "NR_ZLEC" NUMBER(6,0), "NR_POZ" NUMBER(3,0), "NR_SZTUKI" NUMBER(4,0), "NR_KOMP_SZYBY" NUMBER(10,0), "ILE_SZTUK" NUMBER(4,0), "NR_KOMP_INST" NUMBER(10,0), "NR_INSTAL" NUMBER(3,0), "NR_KOMP_ZM" NUMBER(10,0), "NR_BRYGADY" NUMBER(3,0), "NR_PRAC" NUMBER(5,0), "KOD_PRZYCZ" NUMBER(10,0), "NR_KOMP_ZLEC_REKL" NUMBER(10,0), "NR_POZ_REKL" NUMBER(3,0), "NR_KOMP_SZ_REK" NUMBER(10,0), "DATA_ZGLOSZ" DATE, "DATA_PROD" DATE, "DATA_WYS" DATE, "UWAGI" VARCHAR2(80 BYTE)) ;
--------------------------------------------------------
--  DDL for Table REJVAT
--------------------------------------------------------

  CREATE TABLE "REJVAT" ("NR_KOMP_REJ" NUMBER(10,0), "TYP_DOKS" CHAR(3 BYTE), "PREFIX" CHAR(7 BYTE), "NR_DOKS" NUMBER(8,0), "SUFIX" CHAR(7 BYTE), "DATA_WYS" DATE, "NR_KON" NUMBER(10,0), "NAZ_KON" CHAR(50 BYTE), "SKROT_KON" CHAR(15 BYTE), "PANSTWO" CHAR(20 BYTE), "MIASTO" CHAR(30 BYTE), "KOD_POCZ" VARCHAR2(10 BYTE), "ADRES" CHAR(20 BYTE), "NIP" CHAR(20 BYTE), "VAT" NUMBER(6,3), "WART_BRUTTO" NUMBER(18,2), "WART_VAT" NUMBER(17,2), "NUMER_KOMPUTEROWY" NUMBER(10,0), "NR_ODDZ" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table REJ_W_FAKT
--------------------------------------------------------

  CREATE TABLE "REJ_W_FAKT" ("NR_KOMP" NUMBER(10,0), "TYP_DOKUM" CHAR(3 BYTE), "NUMER_DOKUM" NUMBER(8,0), "KLIENT" NUMBER(10,0), "ROK" NUMBER(4,0), "MC" NUMBER(2,0), "DATA" DATE, "ILOSC_POZYCJI" NUMBER(6,0), "WART_NETTO" NUMBER(18,2), "WART_VAT" NUMBER(17,2), "WART_BRUTTO" NUMBER(18,2), "ILOSC_KOPII" NUMBER(6,0), "ILOSC_WYDRUKOW" NUMBER(6,0), "OPERATOR_DRUKUJACY" VARCHAR2(32 BYTE), "DATA_WYDR" DATE, "DATA_OST_WYDR" DATE) ;
--------------------------------------------------------
--  DDL for Table REKBRAK
--------------------------------------------------------

  CREATE TABLE "REKBRAK" ("NR_KOMP_RB" NUMBER(10,0), "WYR_RB" VARCHAR2(1 BYTE), "NR_POZ_RB" NUMBER(3,0), "NR_KOM_ZLEC" NUMBER(10,0), "NR_POZ_ZLEC" NUMBER(3,0), "ILOSC" NUMBER(4,0), "FLAG_UZN" NUMBER(2,0), "NR_WARST" NUMBER(2,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table REKSLO2
--------------------------------------------------------

  CREATE TABLE "REKSLO2" ("NK_ZAP" NUMBER(10,0), "TYP_ZAP" NUMBER(1,0), "NAPIS" VARCHAR2(80 BYTE), "DATA_WPR" DATE, "CZAS_WPR" CHAR(6 BYTE), "NR_OP" NUMBER(10,0), "NR_OD" NUMBER(2,0), "KOD" VARCHAR2(3 BYTE) DEFAULT '000') ;
--------------------------------------------------------
--  DDL for Table REKZLEC2
--------------------------------------------------------

  CREATE TABLE "REKZLEC2" ("NK_ZLEC" NUMBER(10,0), "NR_ZLEC" NUMBER(10,0), "NK_PRZY" NUMBER(10,0), "NK_ROZL" NUMBER(10,0), "TER_REAL" DATE, "OS_ZGL" VARCHAR2(50 BYTE), "NK_ODP" NUMBER(10,0), "NR_POZ" NUMBER(3,0), "MIEJSCE" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table RKONTRAKT
--------------------------------------------------------

  CREATE TABLE "RKONTRAKT" ("NK_KOMP_KONTR" NUMBER(10,0), "GR_DOK" VARCHAR2(3 BYTE), "NR_KONTR" CHAR(19 BYTE), "NR_KON" NUMBER(10,0), "DATA_POCZ" DATE, "DATA_ZAK" DATE, "RABAT" NUMBER(5,2), "NR_DOST" NUMBER(10,0), "NR_OP_WPR" VARCHAR2(10 BYTE), "DATA_WPR" DATE, "NR_OP_MOD" VARCHAR2(10 BYTE), "DATA_MOD" DATE, "OS_ODPOW" VARCHAR2(35 BYTE), "PRZEDSTA_KON" VARCHAR2(35 BYTE), "GOT_KRED" VARCHAR2(2 BYTE), "WAR_PLAT" VARCHAR2(2 BYTE), "IL_D_KRED" NUMBER(3,0), "LIMIT_K" NUMBER(16,2), "LIMIT_WYK" NUMBER(16,2), "SUMA_ZAPL" NUMBER(16,2), "WART_PLAN" NUMBER(16,2), "WART_ZREAL" NUMBER(16,2), "CZAS_REAL" NUMBER(3,0), "RODZ_KARY" VARCHAR2(3 BYTE), "KARA_UM" NUMBER(17,4), "RODZ_ODSET" VARCHAR2(3 BYTE), "WYS_ODSET" NUMBER(12,6), "TERM_1_DOST" DATE, "NAST_DOST_CO" NUMBER(3,0), "NAZ_OBIEKTU" VARCHAR2(30 BYTE), "RODZ_OBIEKTU" VARCHAR2(30 BYTE), "NAZ_INWEST" VARCHAR2(30 BYTE), "GENER_WYK" VARCHAR2(30 BYTE), "ARCHITEKT" VARCHAR2(30 BYTE), "ZATWIERDZ" VARCHAR2(2 BYTE), "STATUS" NUMBER(2,0), "WALUTA" VARCHAR2(4 BYTE), "DATA_ZATW" DATE, "NR_OP_ZATW" VARCHAR2(10 BYTE), "OS_ZATW" VARCHAR2(35 BYTE), "NR_ODDZ" NUMBER(2,0), "TERM_GWAR" NUMBER(4,0), "KURS" NUMBER(14,4), "DATA_KURSU" DATE, "KATEGORIA" VARCHAR2(30 BYTE), "PRZESZKLENIE" VARCHAR2(30 BYTE), "WARUNKI" VARCHAR2(40 BYTE), "IL_ZATW" NUMBER(10,0), "WSP_KURSU1" NUMBER(3,2) DEFAULT 0, "WSP_KURSU2" NUMBER(3,2) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table RKONTR_POZYCJE
--------------------------------------------------------

  CREATE TABLE "RKONTR_POZYCJE" ("NK_KONTRAKTU" NUMBER(10,0), "POZA_KONTRAKTU" NUMBER(4,0), "INDEKS" VARCHAR2(128 BYTE), "TYP_WYR" VARCHAR2(2 BYTE), "KOD_STR" VARCHAR2(65 BYTE), "RABAT" NUMBER(5,2), "CENA_UM" NUMBER(14,4), "IL_MIN" NUMBER(17,2), "IL_MAK" NUMBER(17,2), "PO_MIN" NUMBER(7,4), "POW_MAK" NUMBER(7,4), "DOP_WAGA_DOST" NUMBER(12,2), "DOP_ZA_PRZEKR" NUMBER(12,2), "DOPA_ZA_KSZT" NUMBER(12,2), "DOP_ZA_SZAB" NUMBER(12,2), "PLAN_IL_DOST" NUMBER(16,2), "ZREAL_IL_DOST" NUMBER(16,2), "GWAR" NUMBER(4,0), "R_CENY" VARCHAR2(4 BYTE), "CZAS_REAL" NUMBER(4,0), "POPRAWKI" NUMBER(1,0), "D_ZATW" DATE, "OP_ZATW" VARCHAR2(10 BYTE), "POZ_ZATW" NUMBER(2,0), "DOP_ZA_TROJ" NUMBER(12,2), "DOP_ZA_LIN" NUMBER(12,2), "NK_RYS" NUMBER(10,0), "KOL_WYDR" NUMBER(4,0)) ;
--------------------------------------------------------
--  DDL for Table RKONTR_STR
--------------------------------------------------------

  CREATE TABLE "RKONTR_STR" ("NKOMP" NUMBER(10,0), "INDEKS" VARCHAR2(128 BYTE), "TYP_WYR" VARCHAR2(2 BYTE), "NR_STR" NUMBER(10,0), "KOD_STR_KL" VARCHAR2(64 BYTE), "CENA" NUMBER(14,4), "DOP_WYM" NUMBER(5,2), "BOK_KROTSZY" NUMBER(4,0), "BOK_DLUZSZY" NUMBER(4,0), "DOP_WAGI" NUMBER(5,2), "WAGA_GR" NUMBER(7,0), "DOP_KSZT" NUMBER(5,2), "DOP_SZABL" NUMBER(5,2), "TERMIN_GWAR" NUMBER(4,0), "CZAS_REAL" NUMBER(4,0), "POPRAWKI" NUMBER(1,0), "DATA_ZATW" DATE, "NR_OP" VARCHAR2(10 BYTE), "POZ_ZATW" NUMBER(2,0), "DOP_TROJ" NUMBER(12,2), "DOP_LIN" NUMBER(12,2), "NK_RYS" NUMBER(10,0), "WDR_NR" NUMBER(4,0), "ID_REK" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table RKONTR_WYM
--------------------------------------------------------

  CREATE TABLE "RKONTR_WYM" ("NK_KONTR" NUMBER(10,0), "INDEKS" VARCHAR2(128 BYTE), "TYP_WYR" VARCHAR2(2 BYTE), "NR_STR" NUMBER(10,0), "POW_MIN" NUMBER(7,4), "POW_MAK" NUMBER(7,4), "DOP_WYM" NUMBER(5,2), "CENA" NUMBER(14,4), "R_CENY" VARCHAR2(4 BYTE)) ;
--------------------------------------------------------
--  DDL for Table ROBR_KONTR
--------------------------------------------------------

  CREATE TABLE "ROBR_KONTR" ("NK_KONTRAKTU" NUMBER(10,0), "NK_OBROBKI" NUMBER(10,0), "GRUBOSC" NUMBER(6,3), "CENA" NUMBER(14,4), "RODZAJ_CENY" VARCHAR2(4 BYTE), "POPRAWKI" NUMBER(1,0), "DATA_ZATW" DATE, "OP_ZATW" VARCHAR2(10 BYTE), "POZ_ZATW" NUMBER(2,0), "KOL_WYDR" NUMBER(4,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table RODSZKL
--------------------------------------------------------

  CREATE TABLE "RODSZKL" ("POZIOM" NUMBER(2,0), "NAZWA" VARCHAR2(50 BYTE), "GRUPA_TOWAROWA" VARCHAR2(3 BYTE)) ;
--------------------------------------------------------
--  DDL for Table ROZLICZ_ZAL
--------------------------------------------------------

  CREATE TABLE "ROZLICZ_ZAL" ("NR_KLI" NUMBER(10,0), "N_K_ZAL" NUMBER(10,0), "N_K_FAKT" NUMBER(10,0), "NETTO" NUMBER(14,2), "VAT" NUMBER(14,2), "BRUTTO" NUMBER(14,2), "DATA_P" DATE, "OPERATOR" VARCHAR2(50 BYTE), "NR_OPER" VARCHAR2(10 BYTE), "STAN" NUMBER(2,0), "PELNY_NR_FAKT" VARCHAR2(20 BYTE)) ;
--------------------------------------------------------
--  DDL for Table RPZLEC
--------------------------------------------------------

  CREATE TABLE "RPZLEC" ("NKOMP" NUMBER(10,0), "GR_DOK" VARCHAR2(3 BYTE), "NR_ZLEC" NUMBER(10,0), "NR_ZLEC_KL" VARCHAR2(18 BYTE), "NR_KONTR" NUMBER(10,0), "DATA_ZLEC" DATE, "POZ_CEN" NUMBER(2,0), "DATA_POCZU_PROD" DATE, "DATA_ZAK_PROD" DATE, "DATA_PLAN_PROD" DATE, "DATA_WYS" DATE, "NR_ADR_DOST" NUMBER(10,0), "NK_KONTR" NUMBER(10,0), "W_ZLEC" NUMBER(12,2), "W_SUR" NUMBER(12,2), "W_DO_UBEZP" NUMBER(12,2), "W_USL" NUMBER(12,2), "W_PW" NUMBER(12,2), "IL_POZ" NUMBER(3,0), "KOM_POCZ" NUMBER(10,0), "KOM_KON" NUMBER(10,0), "NR_OP_WPR" VARCHAR2(10 BYTE), "NR_OP_MOD" VARCHAR2(10 BYTE), "TYP_ZLE" VARCHAR2(3 BYTE), "PRIORYTET" NUMBER(2,0), "WYR_ZLEC" VARCHAR2(1 BYTE), "STOP_REAL_ZLEC" NUMBER(10,0), "NR_ODD" NUMBER(2,0), "ROK" NUMBER(4,0), "MC" NUMBER(2,0), "DATA_PLAN_SPED" DATE, "DATA_SPED_KLIENTA" DATE, "NR_ZLEC_WEWN" VARCHAR2(18 BYTE), "FORMA_WPR" VARCHAR2(1 BYTE), "STATUS" VARCHAR2(1 BYTE), "SKIER_DO_PROD" NUMBER(1,0), "OP_ZATW" VARCHAR2(10 BYTE), "IL_CIETYCH" NUMBER(14,0), "IL_I_KOM" NUMBER(14,0), "IL_II_KOM" NUMBER(14,0), "ILO_STRUKT" NUMBER(14,0), "POW_CIETYCH" NUMBER(18,6), "POW_I_KOM" NUMBER(18,6), "POW_II_KOM" NUMBER(18,6), "POW_STRUKT" NUMBER(18,6), "POWOD" VARCHAR2(30 BYTE), "WALUTA" VARCHAR2(4 BYTE), "KURS" NUMBER(14,4), "IL_STR" NUMBER(14,0), "POW_STR" NUMBER(18,6), "ZN_ZLEC" NUMBER(4,0), "NR_KOMP_ZLEC_POP" NUMBER(10,0), "WSK_POL" NUMBER(5,0), "IL_ZATW" NUMBER(10,0), "NR_SZARZY" NUMBER(6,0), "NR_PAKIETU" NUMBER(6,0), "TRYB_WPR" NUMBER(2,0), "SORT" VARCHAR2(9 BYTE), "RODZAJ" NUMBER(1,0), "RODZAJ_DANYCH" NUMBER(2,0), "NR_KOMP_ROKP" NUMBER(10,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table RPZLEC_POZ
--------------------------------------------------------

  CREATE TABLE "RPZLEC_POZ" ("NR_ZLEC" NUMBER(10,0), "TYP_ZLEC" VARCHAR2(3 BYTE), "NR_POZ_ZLEC" NUMBER(3,0), "ILOSC" NUMBER(4,0), "SZER" NUMBER(4,0), "WYS" NUMBER(4,0), "KOD_STR" VARCHAR2(128 BYTE), "OPIS_KL" VARCHAR2(20 BYTE), "WSP_K" NUMBER(4,2), "CENA" NUMBER(14,4), "RODZ_CEN" VARCHAR2(4 BYTE), "NR_NAP" NUMBER(3,0), "IL_OTW" NUMBER(5,2), "KOD_PASK" VARCHAR2(21 BYTE), "NR_KSZT" NUMBER(3,0), "H" NUMBER(4,0), "L" NUMBER(4,0), "W1" NUMBER(4,0), "W2" NUMBER(4,0), "H1" NUMBER(4,0), "H2" NUMBER(4,0), "T1" NUMBER(4,0), "T2" NUMBER(4,0), "T3" NUMBER(4,0), "R" NUMBER(4,0), "R1" NUMBER(4,0), "R2" NUMBER(4,0), "KOSZT_SUR" NUMBER(7,2), "TYP_POZ" VARCHAR2(3 BYTE), "SORT1" NUMBER(3,0), "SORT2" NUMBER(3,0), "SORT3" NUMBER(3,0), "IL_SPRZED" NUMBER(14,4), "DAN_DOD" NUMBER(3,0), "WSP_PRZEL" NUMBER(6,3), "IND_BUD" VARCHAR2(30 BYTE), "ATR_BUD" NUMBER(18,0), "IL_SZK" NUMBER(1,0), "IL_DO_WYS" NUMBER(4,0), "NR_DOST" NUMBER(10,0), "NR_KOM_ZLEC" NUMBER(10,0), "NR_ODDZ" NUMBER(2,0), "ROK" NUMBER(4,0), "MIES" NUMBER(2,0), "POW" NUMBER(14,4), "OBW" NUMBER(14,4), "IL_NA_WZ" NUMBER(4,0), "NR_MAG" NUMBER(3,0), "IL_NA_OST_PROT" NUMBER(4,0), "IL_NA_PW" NUMBER(4,0), "STATUS_POZYCJI" NUMBER(2,0), "SPR" NUMBER(1,0), "NR_KONTR" NUMBER(10,0), "NR_KAT_KSZT" NUMBER(9,0), "DO_KTOREJ_POZ_POP" NUMBER(6,0), "GL_SILIKONU" NUMBER(6,3), "DATA_ZATW" DATE, "OP_ZATW" VARCHAR2(10 BYTE), "POZ_ZATW" NUMBER(2,0), "KOM_POCZ" NUMBER(6,0), "KOM_KONC" NUMBER(6,0), "NR_KOMP_INST" NUMBER(10,0), "POW_JED_FAK" NUMBER(14,4), "POW_CAL_FAK" NUMBER(14,4), "IL_FAK" NUMBER(4,0), "R3" NUMBER(4,0), "T4" NUMBER(4,0), "D" NUMBER(4,0), "SERIA" NUMBER(10,0), "CENA_BAZ" NUMBER(14,4), "IDENT_POZ" NUMBER(10,0), "OPIS_DOD" VARCHAR2(20 BYTE), "NR_KOMP_RYS" NUMBER(10,0), "IDENT_REKORDU" NUMBER(10,0), "NR_POZ_ROKP" NUMBER(3,0) DEFAULT 0, "NR_PODGR" NUMBER(10,0) DEFAULT 0, "NR_SZAR" NUMBER(6,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table RREK_ZLEC
--------------------------------------------------------

  CREATE TABLE "RREK_ZLEC" ("NK_ZLEC" NUMBER(10,0), "NR_ZLEX" NUMBER(10,0), "NK_PRZYCZ" NUMBER(10,0), "NK_ROZLI" NUMBER(10,0), "TERMIN_REAL" DATE, "OS_ZGL" VARCHAR2(50 BYTE), "NK_ODP" NUMBER(10,0), "POZ_ZLEC" NUMBER(3,0), "MIEJ_POWS" NUMBER(10,0), "IDENT_REK" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table RRYSUNKI
--------------------------------------------------------

  CREATE TABLE "RRYSUNKI" ("NK_RYS" NUMBER(10,0), "TYP_RYS" NUMBER(1,0), "NK_ZLEC" NUMBER(10,0), "NR_POZ" NUMBER(3,0), "NR_WARST" NUMBER(5,0), "RYS" LONG RAW, "SCIEZKA_DO_PLIKU" VARCHAR2(200 BYTE), "IDENT_REK" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table RYSUNKI
--------------------------------------------------------

  CREATE TABLE "RYSUNKI" ("NK_RYS" NUMBER(10,0), "TYP_RYS" NUMBER(2,0), "NK_ZLEC" NUMBER(10,0), "NR_POZ" NUMBER(3,0), "NR_WARST" NUMBER(5,0), "RYSUNEK" LONG RAW, "SCIEZKA" VARCHAR2(200 BYTE), "IDENT_POZ" NUMBER(10,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table RZLEC_DODATKI
--------------------------------------------------------

  CREATE TABLE "RZLEC_DODATKI" ("NR_ZLEC" NUMBER(10,0), "TYP_ZLEC" VARCHAR2(3 BYTE), "POZ_ZLEC" NUMBER(3,0), "KOL_DOD" NUMBER(3,0), "KOD_DOD" VARCHAR2(128 BYTE), "ZN_WAR" VARCHAR2(3 BYTE), "NR_PROC" VARCHAR2(4 BYTE), "WSP1" NUMBER(4,0), "WSP2" NUMBER(4,0), "WSP3" NUMBER(4,0), "WSP4" NUMBER(4,0), "CENA" NUMBER(14,4), "IL_POL_SZPR" NUMBER(4,0), "NKOMP_ZLEC" NUMBER(10,0), "NR_ODDZ" NUMBER(2,0), "ROK" NUMBER(4,0), "MC" NUMBER(2,0), "DO_KTOREJ_WAR" NUMBER(3,0), "NR_MAG" NUMBER(3,0), "IDEN_SZP" NUMBER(4,0), "IL_ODC_SZPR_PION" NUMBER(10,0), "IL_ODC_SZPR_POZ" NUMBER(10,0), "NKOMP_RYS" NUMBER(10,0), "DL_BOK" NUMBER(18,6), "NKOMP_STR_OBR" NUMBER(10,0), "NR_KAT" NUMBER(4,0), "STRONA" NUMBER(2,0), "PAR1" NUMBER(12,4), "PAR2" NUMBER(12,4), "PAR3" NUMBER(12,4), "PAR4" NUMBER(12,4), "PAR5" NUMBER(12,4), "SZER_OBRYSU" NUMBER(4,0), "WYS_OBRYSU" NUMBER(4,0), "IL_BOK_OBR" NUMBER(4,0), "IL_WYK" NUMBER(4,0), "IDENT_REK" NUMBER(10,0), "MARZA" NUMBER(7,3)) ;
--------------------------------------------------------
--  DDL for Table RZLEC_DOPLATY
--------------------------------------------------------

  CREATE TABLE "RZLEC_DOPLATY" ("NK_ZLEC" NUMBER(10,0), "ID_POZ" NUMBER(10,0), "RODZAJ" NUMBER(2,0), "WART" NUMBER(5,2)) ;
--------------------------------------------------------
--  DDL for Table RZLEC_SZP
--------------------------------------------------------

  CREATE TABLE "RZLEC_SZP" ("NR_ZLEC" NUMBER(10,0), "NK_ZLEC" NUMBER(10,0), "NR_POZ_ZLEC" NUMBER(3,0), "NR_WAR" NUMBER(3,0), "PAR_SZPR" VARCHAR2(2000 BYTE), "R3" NUMBER(4,0), "T4" NUMBER(4,0), "MATSZP1" VARCHAR2(128 BYTE), "MATSZP2" VARCHAR2(128 BYTE), "NR_WZR_SZPR" NUMBER(4,0), "IL_PAR" NUMBER(4,0), "MARG_KSZT" NUMBER(4,0), "IDENT_SZP" NUMBER(3,0), "PODZIAL" NUMBER(1,0), "IDENT_REK" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table RZLEC_TYP
--------------------------------------------------------

  CREATE TABLE "RZLEC_TYP" ("NK_ZLEC" NUMBER(10,0), "POZ_ZLEC" NUMBER(3,0), "TYP" NUMBER(3,0), "LINIA" VARCHAR2(500 BYTE), "IDENT_REKORDU" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table RZMIANY
--------------------------------------------------------

  CREATE TABLE "RZMIANY" ("ID_REK" NUMBER(10,0), "STAN" NUMBER(1,0), "FLAG_ZM" NUMBER(1,0), "INDEKS" VARCHAR2(128 BYTE), "CENA_POP" NUMBER(10,2), "CENA_AKT" NUMBER(10,2), "NR_OP" VARCHAR2(10 BYTE), "DATA_ZATW" DATE, "ZATWIER" NUMBER(2,0), "NKOMP_ZLEC" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table SAMOCH
--------------------------------------------------------

  CREATE TABLE "SAMOCH" ("NR_REJ" VARCHAR2(25 BYTE), "MARKA_S" CHAR(15 BYTE), "NOSNOSC" NUMBER(12,2), "RODZ_SAM" CHAR(4 BYTE), "KIEROW_1" CHAR(30 BYTE), "KIEROW_2" CHAR(30 BYTE), "KIEROW_3" CHAR(30 BYTE), "KIEROW_4" CHAR(30 BYTE), "CZAS_ZAL" NUMBER(3,0) DEFAULT 0, "MAX_ILOSC" NUMBER(2,0) DEFAULT 0, "SRED_PRED" NUMBER(3,0) DEFAULT 0, "NR_KONTR_SPED" NUMBER(10,0) DEFAULT 0, "TEL" VARCHAR2(30 BYTE) DEFAULT ' ') ;
--------------------------------------------------------
--  DDL for Table SL1_ROKP
--------------------------------------------------------

  CREATE TABLE "SL1_ROKP" ("NK_ROKP" NUMBER(10,0), "NAZ_ROKP" VARCHAR2(50 BYTE), "SKR_ROKP" VARCHAR2(15 BYTE), "NK_KONTR" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table SL_OBR_STAND
--------------------------------------------------------

  CREATE TABLE "SL_OBR_STAND" ("NR_KOMP_EL" NUMBER(10,0), "TYP" VARCHAR2(10 BYTE), "NR_TYPU" NUMBER(5,0), "OPIS" VARCHAR2(30 BYTE), "SZER" NUMBER(4,0), "WYS" NUMBER(4,0), "IL_OTW_D1" NUMBER(4,0), "D1" NUMBER(6,3), "IL_OTW_D2" NUMBER(4,0), "D2" NUMBER(6,3), "ILOSC_OBR" NUMBER(13,3), "RYS" LONG RAW, "NR_KOMP" NUMBER(10,0), "NR_KOMP_D1" NUMBER(10,0), "NR_KOMP_D2" NUMBER(10,0), "NR_KOMP_SZL" NUMBER(10,0), "NK_PLAN_D1" NUMBER(10,0) DEFAULT 0, "NK_PLAN_D2" NUMBER(10,0) DEFAULT 0, "NK_PLAN_SZL" NUMBER(10,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table SLOW_ATEST
--------------------------------------------------------

  CREATE TABLE "SLOW_ATEST" ("NR_ATESTU" NUMBER(10,0), "GR_TOWAR" VARCHAR2(3 BYTE), "ANALITYKA_WYROBU" NUMBER(3,0), "TYP_WYROBU" VARCHAR2(40 BYTE), "TYP_DOK_ODN" VARCHAR2(40 BYTE), "SWW_PKWIU" VARCHAR2(18 BYTE), "DATA_WYDANIA" DATE, "ODDZ" NUMBER(3,0), "OPIS_ATESTU" VARCHAR2(512 BYTE), "DATA_WAZN" DATE, "FILE_NAME" VARCHAR2(50 BYTE) DEFAULT '') ;
--------------------------------------------------------
--  DDL for Table SLOW_BRYG
--------------------------------------------------------

  CREATE TABLE "SLOW_BRYG" ("NR_KOMP_B" NUMBER(10,0), "NR_BRYG" NUMBER(1,0), "NR_KOMP_INST" NUMBER(10,0), "MISTRZ" NUMBER(10,0), "ILOSOB" NUMBER(5,0)) ;
--------------------------------------------------------
--  DDL for Table SLOW_DLA_CZYNN
--------------------------------------------------------

  CREATE TABLE "SLOW_DLA_CZYNN" ("NUMER" NUMBER(5,0), "NAZWA" VARCHAR2(50 BYTE), "KOD" VARCHAR2(1 BYTE), "CZYN_1" NUMBER(4,0), "CZYN_2" NUMBER(4,0), "CZYN_3" NUMBER(4,0), "CZYN_4" NUMBER(4,0), "K_LITERA_KODU" NUMBER(2,0), "POMOC" VARCHAR2(20 BYTE)) ;
--------------------------------------------------------
--  DDL for Table SLOWDLAOO
--------------------------------------------------------

  CREATE TABLE "SLOWDLAOO" ("INDEKS" VARCHAR2(128 BYTE), "NR_ODDZ" NUMBER(2,0), "INDEKS_PRZYCH" VARCHAR2(128 BYTE), "NAZWA_PRZYCH" VARCHAR2(255 BYTE), "NR_ODDZ_PRZYCH" NUMBER(2,0), "NR_MAG_DOC" NUMBER(3,0)) ;
--------------------------------------------------------
--  DDL for Table SLOW_FK
--------------------------------------------------------

  CREATE TABLE "SLOW_FK" ("SYMBOL" VARCHAR2(3 BYTE), "WSKAZNIK" NUMBER(1,0), "OPIS" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table SLOWGIEN
--------------------------------------------------------

  CREATE TABLE "SLOWGIEN" ("NR_GIETARKI" NUMBER(4,0), "NAZWA_GIETARKI" VARCHAR2(50 BYTE), "NR_KOMPUTER" NUMBER(4,0), "TYP_STEROWNIKA" VARCHAR2(10 BYTE), "NAPISY" NUMBER(2,0), "CUTFRAME" NUMBER(2,0), "NR_WZORU" NUMBER(4,0), "FRAMEPATH" VARCHAR2(200 BYTE), "CFRPATH" VARCHAR2(200 BYTE)) ;
--------------------------------------------------------
--  DDL for Table SLOWGRUP
--------------------------------------------------------

  CREATE TABLE "SLOWGRUP" ("TYP_WYROBU" VARCHAR2(3 BYTE), "NR_JEZYKA" NUMBER(2,0), "NAZWA_GRUPY_WYR" VARCHAR2(100 BYTE), "NAPISNAL" VARCHAR2(30 BYTE), "NAPISRAM" VARCHAR2(30 BYTE), "NAPISPOTW" VARCHAR2(50 BYTE), "NAPISFAKT" VARCHAR2(50 BYTE), "CE_MARK" VARCHAR2(50 BYTE), "NR_NORMY" VARCHAR2(50 BYTE), "ANAL" NUMBER(3,0), "CE_ADR_WWW" VARCHAR2(120 BYTE), "OZNACZ_ATESTU" VARCHAR2(120 BYTE), "ZNAK_B" NUMBER(1,0), "ZNAK_B_2" NUMBER(1,0), "ZNAK_CE" NUMBER(1,0), "NORMA_PN" NUMBER(1,0), "ATEST" NUMBER(1,0), "DEKLAR" NUMBER(1,0), "DEKLAR_PLIK" VARCHAR2(150 BYTE), "KOD_ID" VARCHAR2(20 BYTE), "CERTYFIKAT" VARCHAR2(50 BYTE), "CZY_KOD_ID" NUMBER(1,0), "CZY_CERTYFIKAT" NUMBER(1,0), "CZY_WWW" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table SLOW_NIEOB
--------------------------------------------------------

  CREATE TABLE "SLOW_NIEOB" ("KOD" NUMBER(2,0), "OPIS" VARCHAR2(20 BYTE), "DNI_MIN" NUMBER(5,0)) ;
--------------------------------------------------------
--  DDL for Table SLOWNIK
--------------------------------------------------------

  CREATE TABLE "SLOWNIK" ("TYP" NUMBER(10,0), "ROZ" NUMBER(2,0), "ZNAK" VARCHAR2(1 BYTE), "OPIS" VARCHAR2(30 BYTE), "KOMENTARZ" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table SLOW_PAR
--------------------------------------------------------

  CREATE TABLE "SLOW_PAR" ("TYPY_P" VARCHAR2(1 BYTE), "NUMER" NUMBER(3,0), "NAZ_PAR" VARCHAR2(40 BYTE), "WART_DOM" VARCHAR2(80 BYTE), "GRUPA_W_INI" VARCHAR2(10 BYTE)) ;
--------------------------------------------------------
--  DDL for Table SLOW_POST
--------------------------------------------------------

  CREATE TABLE "SLOW_POST" ("NR_POST" NUMBER(10,0), "OPIS" VARCHAR2(20 BYTE)) ;
--------------------------------------------------------
--  DDL for Table SLOW_POWLOK
--------------------------------------------------------

  CREATE TABLE "SLOW_POWLOK" ("NR_POWLOKI" NUMBER(4,0), "NAZWA_POW" VARCHAR2(60 BYTE), "CZY_SZLIFOWANIE" NUMBER(1,0), "CZY_ODWRACANIE" NUMBER(1,0), "CZY" NUMBER(1,0), "CZY_NALEPKI" NUMBER(1,0), "CZY_ZEWN" NUMBER(1,0), "CZY_WEWN" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table SLOW_TAB
--------------------------------------------------------

  CREATE TABLE "SLOW_TAB" ("NR" NUMBER(4,0), "NAZWA" VARCHAR2(30 BYTE), "NAZ_W_BAZIE" VARCHAR2(30 BYTE), "GDZIE_BAZA" VARCHAR2(30 BYTE), "WYBOR" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table SLOWTYPR
--------------------------------------------------------

  CREATE TABLE "SLOWTYPR" ("TYPKAT" VARCHAR2(9 BYTE), "NRKAT" NUMBER(4,0), "GRUB" NUMBER(4,0), "NRKOL" NUMBER(10,0), "KODLISEC" VARCHAR2(6 BYTE), "KODBAYER" VARCHAR2(6 BYTE), "KODRYUKAN" VARCHAR2(6 BYTE), "KODSANAC" VARCHAR2(6 BYTE), "KODINNE" VARCHAR2(6 BYTE)) ;
--------------------------------------------------------
--  DDL for Table SLPAROB
--------------------------------------------------------

  CREATE TABLE "SLPAROB" ("NR_K_P_OBR" NUMBER(10,0), "SYMB_P_OBR" VARCHAR2(6 BYTE), "NAZWA_P_OBR" VARCHAR2(50 BYTE), "MET_OBLICZ" NUMBER(4,0), "OPIS_METODY" VARCHAR2(20 BYTE), "PAR_1" NUMBER(14,4), "PAR_2" NUMBER(14,4), "PAR_3" NUMBER(14,4), "PAR_4" NUMBER(14,4), "PAR5" NUMBER(14,4), "IL_PARAM" NUMBER(10,0), "CENA" NUMBER(14,4), "MARZA" NUMBER(6,3), "NR_KAT_OBR" NUMBER(4,0), "NR_KOMP_INST" NUMBER(10,0), "RODZAJ" NUMBER(2,0) DEFAULT 0, "OBR_JEDNOCZ" NUMBER(1,0) DEFAULT 0, "NR_TLUM" NUMBER(10,0) DEFAULT 0, "NR_KOMP_EL" NUMBER(10,0) DEFAULT 0, "NR_KOMP_GR_INST" NUMBER(10,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table SL_ROKP
--------------------------------------------------------

  CREATE TABLE "SL_ROKP" ("KOD_ROKP" VARCHAR2(128 BYTE), "KOD" VARCHAR2(128 BYTE)) ;
--------------------------------------------------------
--  DDL for Table SL_STORKE
--------------------------------------------------------

  CREATE TABLE "SL_STORKE" ("KOD" VARCHAR2(10 BYTE), "OPIS" VARCHAR2(30 BYTE)) ;
--------------------------------------------------------
--  DDL for Table SL_TOW_PROD
--------------------------------------------------------

  CREATE TABLE "SL_TOW_PROD" ("TYP_WYROBU_DLA_KONTRAKTU" VARCHAR2(2 BYTE), "KOD_STRUK" VARCHAR2(128 BYTE), "NAZWA" VARCHAR2(255 BYTE)) ;
--------------------------------------------------------
--  DDL for Table SL_TRANS
--------------------------------------------------------

  CREATE TABLE "SL_TRANS" ("KOD_USL" VARCHAR2(50 BYTE), "OPIS" VARCHAR2(100 BYTE), "NR_DOST" NUMBER(10,0), "NR_DOST_TRAN" NUMBER(10,0), "NR_ODDZ" NUMBER(2,0), "ST_VAT" VARCHAR2(5 BYTE), "KOSZT_WAL" NUMBER(10,2), "WALUTA" VARCHAR2(4 BYTE), "NR_KOMP_GR" NUMBER(10,0), "GR_TOW" VARCHAR2(3 BYTE), "KOSZT_W_PLN" NUMBER(10,2), "KURS" NUMBER(14,4)) ;
--------------------------------------------------------
--  DDL for Table SL_TYP
--------------------------------------------------------

  CREATE TABLE "SL_TYP" ("TYP" NUMBER(4,0), "RODZAJ" NUMBER(4,0), "NUMER" NUMBER(4,0), "OPIS" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table SLTYP_TRANS
--------------------------------------------------------

  CREATE TABLE "SLTYP_TRANS" ("OZN_TYPU" VARCHAR2(10 BYTE), "OPIS_TYPU" VARCHAR2(50 BYTE), "PARAM_DEF" VARCHAR2(10 BYTE), "PAR_OGRANICZ" NUMBER(6,0), "RODZAJ_SUR" VARCHAR2(3 BYTE), "OPIS_PAR_TRANS" VARCHAR2(512 BYTE)) ;
--------------------------------------------------------
--  DDL for Table SL_UZUP
--------------------------------------------------------

  CREATE TABLE "SL_UZUP" ("SKROT" VARCHAR2(128 BYTE), "OPIS" VARCHAR2(255 BYTE), "ST_VAT" VARCHAR2(5 BYTE), "JEDN" VARCHAR2(5 BYTE), "CENA" NUMBER(14,4), "NR_KOMP_GR" NUMBER(10,0), "GR_TOW" VARCHAR2(3 BYTE)) ;
--------------------------------------------------------
--  DDL for Table SPEDC
--------------------------------------------------------

  CREATE TABLE "SPEDC" ("NR_SPED" NUMBER(14,0), "DATA_SPED" DATE, "NR_REJ" VARCHAR2(17 BYTE), "NR_TRASY" NUMBER(10,0), "FLAG_REAL" NUMBER(1,0), "IL_SZYB" NUMBER(10,0), "POW" NUMBER(14,4), "MAX_BOK" NUMBER(5,0), "WAGA" NUMBER(12,3), "AUTO" NUMBER(1,0), "DATA_PODST" DATE, "CZAS_PODST" CHAR(6 BYTE), "DATA_WYJ" DATE, "CZAS_WYJ" CHAR(6 BYTE), "IL_STOJ" NUMBER(3,0), "DL_TRASY" NUMBER(5,0), "DATA_PRZYJ" DATE, "CZAS_PRZYJ" CHAR(6 BYTE), "KIEROWCA" VARCHAR2(36 BYTE) DEFAULT '') ;
--------------------------------------------------------
--  DDL for Table SPISD
--------------------------------------------------------

  CREATE TABLE "SPISD" ("NR_ZLEC" NUMBER(6,0), "TYP_ZLEC" CHAR(3 BYTE), "NR_POZ" NUMBER(3,0), "KOL_DOD" NUMBER(3,0), "KOD_DOD" VARCHAR2(128 BYTE), "ZN_WAR" CHAR(3 BYTE), "NR_POC" CHAR(4 BYTE), "WSP1" NUMBER(4,0), "WSP2" NUMBER(4,0), "WSP3" NUMBER(4,0), "WSP4" NUMBER(4,0), "CENA" NUMBER(14,4), "IL_POL_SZP" NUMBER(4,0), "NR_KOM_ZLEC" NUMBER(10,0), "NR_ODDZ" NUMBER(2,0), "ROK" NUMBER(4,0), "MIES" NUMBER(2,0), "DO_WAR" NUMBER(3,0), "NR_MAG" NUMBER(3,0), "IDENT_SZP" NUMBER(3,0), "IL_ODC_PION" NUMBER(10,0) DEFAULT 0, "IL_ODC_POZ" NUMBER(10,0) DEFAULT 0, "NR_KOMP_RYS" NUMBER(10,0) DEFAULT 0, "ILOSC_DO_WYK" NUMBER(18,6) DEFAULT 0, "NR_KOMP_OBR" NUMBER(10,0) DEFAULT 0, "NR_KAT" NUMBER(4,0) DEFAULT 0, "STRONA" NUMBER(2,0) DEFAULT 0, "PAR1" NUMBER(12,4) DEFAULT 0, "PAR2" NUMBER(12,4) DEFAULT 0, "PAR3" NUMBER(12,4) DEFAULT 0, "PAR4" NUMBER(12,4) DEFAULT 0, "PAR5" NUMBER(12,4) DEFAULT 0, "SZER_OBR" NUMBER(4,0) DEFAULT 0, "WYS_OBR" NUMBER(4,0) DEFAULT 0, "IL_BOK" NUMBER(4,0) DEFAULT 0, "IL_WYK" NUMBER(4,0), "IDENT" NUMBER(10,0) DEFAULT 0, "MARZA" NUMBER(7,3) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table SPISE
--------------------------------------------------------

  CREATE TABLE "SPISE" ("NR_KOM_SZYBY" NUMBER(10,0), "NR_ZLEC" NUMBER(6,0), "TYP_ZLEC" CHAR(3 BYTE), "NR_POZ" NUMBER(3,0), "NR_SZT" NUMBER(4,0), "NR_STOJ_PROD" NUMBER(10,0), "POZ_ST_PR" NUMBER(4,0), "DATA_WYK" DATE, "ZM_WYK" NUMBER(1,0), "NR_SPED" NUMBER(14,0), "NR_STOJ_SPED" NUMBER(10,0), "POZ_ST_SPED" NUMBER(4,0), "DATA_SPED" DATE, "ZM_SPED" NUMBER(1,0), "NR_KOMP_STOJAKA" NUMBER(10,0), "NR_ODDZ" NUMBER(2,0), "ROK" NUMBER(4,0), "MIESIAC" NUMBER(2,0), "NR_KOMP_ZLEC" NUMBER(10,0), "NR_KOMP_INST" NUMBER(10,0), "WAGA" NUMBER(10,3), "FLAG_REAL" NUMBER(1,0), "O_ODCZ" VARCHAR2(10 BYTE) DEFAULT '', "D_ODCZ" DATE DEFAULT '1901/01/01', "T_ODCZYT" CHAR(6 BYTE) DEFAULT '', "O_WYK" VARCHAR2(10 BYTE) DEFAULT '', "D_WYK" DATE DEFAULT '1901/01/01', "T_WYK" VARCHAR2(6 BYTE) DEFAULT '000000', "ZN_WYK" NUMBER(2,0) DEFAULT 0, "STR_ST" VARCHAR2(2 BYTE) DEFAULT '', "NR_K_WZ" NUMBER(10,0) DEFAULT 0, "NR_POZ_WZ" NUMBER(6,0) DEFAULT 0, "NSZ_W_ZLEC" NUMBER(6,0) DEFAULT 0, "NR_KOMP_INST_PAK" NUMBER(10,0) DEFAULT 0, "NR_KOMP_ZM_PAK" NUMBER(10,0) DEFAULT 0, "FLAG_WYK" NUMBER(1,0) DEFAULT 0, "DATA_PW" DATE DEFAULT to_date('01/01/1901','DD/MM/YYYY')) ;
--------------------------------------------------------
--  DDL for Table SPISP
--------------------------------------------------------

  CREATE TABLE "SPISP" ("NUMER_KOMPUTEROWY_ZLECENIA" NUMBER(10,0), "NR_POZ" NUMBER(3,0), "IL_PLAN" NUMBER(4,0), "DATA_PLAN" DATE, "ZM_PLAN" NUMBER(10,0), "CZAS_PLAN" NUMBER(10,0), "IL_WYK" NUMBER(4,0), "DATA_WYK" DATE, "ZM_WYK" NUMBER(10,0), "CZAS_WYK" NUMBER(10,0), "NR_KOM_INST" NUMBER(10,0), "NR_ODDZ" NUMBER(2,0), "NR_KOM_INST_WYK" NUMBER(10,0) DEFAULT 0, "OPER" VARCHAR2(10 BYTE) DEFAULT ' ', "CZAS" CHAR(6 BYTE) DEFAULT '000000', "SPAD" NUMBER(1,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table SPISW
--------------------------------------------------------

  CREATE TABLE "SPISW" ("NR_KOM_ZLEC" NUMBER(10,0), "NR_POZ" NUMBER(3,0), "NR_SZT" NUMBER(10,0), "NR_INST" NUMBER(10,0), "NR_KOMP_ZM" NUMBER(10,0), "DATA_WYK" DATE, "ZM_WYK" NUMBER(1,0), "NR_OBR" NUMBER(4,0), "IND_OBR" VARCHAR2(128 BYTE), "IL_OBR" NUMBER(13,3), "IL_PRZEL" NUMBER(13,3), "JDN_OBR" VARCHAR2(5 BYTE), "BRAK" NUMBER(1,0), "IL_SZT_BR" NUMBER(1,0), "ID_PRAC" VARCHAR2(10 BYTE) DEFAULT '', "GODZ_WYK" CHAR(6 BYTE) DEFAULT '000000', "IL_WYC" NUMBER(5,0) DEFAULT 0, "DATA_PW" DATE DEFAULT to_date('01/01/1901','DD/MM/YYYY'), "INST_N" NUMBER(10,0) DEFAULT -1, "ZM_N" NUMBER(10,0) DEFAULT -1, "NR_KOMP_DOK_PW" NUMBER(10,0) DEFAULT 0, "KOLEJN" NUMBER(2,0) DEFAULT 0, "KOSZT_JP" NUMBER(14,4) DEFAULT 0, "KOSZT_OBR" NUMBER(14,4) DEFAULT 0, "FLAG" NUMBER(2,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table SPISZ
--------------------------------------------------------

  CREATE TABLE "SPISZ" ("NR_ZLEC" NUMBER(6,0), "TYP_ZLEC" CHAR(3 BYTE), "NR_POZ" NUMBER(3,0), "ILOSC" NUMBER(4,0), "SZER" NUMBER(4,0), "WYS" NUMBER(4,0), "KOD_STR" VARCHAR2(128 BYTE), "OPIS_KLI" CHAR(20 BYTE), "WSP_K" NUMBER(4,2), "CENA" NUMBER(14,4), "RODZ_CEN" CHAR(4 BYTE), "NR_NAP" NUMBER(3,0), "IL_OTW" NUMBER(5,2), "KOD_PASK" CHAR(21 BYTE), "NR_KSZT" NUMBER(3,0), "H" NUMBER(4,0), "L" NUMBER(4,0), "W1_L1" NUMBER(4,0), "W2_L2" NUMBER(4,0), "H1" NUMBER(4,0), "H2" NUMBER(4,0), "T1_B1" NUMBER(4,0), "T2_B2" NUMBER(4,0), "T3_B3" NUMBER(4,0), "R" NUMBER(4,0), "R1" NUMBER(4,0), "R2" NUMBER(4,0), "KOSZT_SUR" NUMBER(7,2), "TYP_POZ" CHAR(3 BYTE), "SORT1" NUMBER(3,0), "SORT2" NUMBER(3,0), "SORT3" NUMBER(3,0), "IL_SPRZED" NUMBER(14,4), "DAN_DOD" NUMBER(3,0), "WSP_PRZEL" NUMBER(6,3), "IND_BUD" VARCHAR2(30 BYTE), "ATR_BUD" NUMBER(18,0), "IL_SZK" NUMBER(1,0), "IL_DO_WYS" NUMBER(4,0), "NR_DOST" NUMBER(10,0), "NR_KOM_ZLEC" NUMBER(10,0), "NR_ODDZ" NUMBER(2,0), "ROK" NUMBER(4,0), "MIES" NUMBER(2,0), "POW" NUMBER(14,4), "OBW" NUMBER(14,4), "IL_NA_WZ" NUMBER(4,0), "NR_MAG" NUMBER(3,0), "IL_O_P" NUMBER(4,0), "IL_NA_PW" NUMBER(4,0), "STATUS_POZYCJI" NUMBER(2,0), "SPRAW" NUMBER(1,0), "NRKONTR" NUMBER(10,0), "NRKATK" NUMBER(2,0), "NR_POZ_POP" NUMBER(6,0), "GR_SIL" NUMBER(6,3), "D_ZATW" DATE, "OP_ZATW" VARCHAR2(10 BYTE), "POZ_OK" NUMBER(2,0), "KOM_POCZ" NUMBER(6,0), "KOM_KONC" NUMBER(6,0), "NR_KOMP_INST" NUMBER(10,0), "POW_JED_FAK" NUMBER(14,4), "POW_CAL_FAK" NUMBER(14,4), "IL_FAK" NUMBER(4,0), "R3" NUMBER(4,0), "T4" NUMBER(4,0), "D" NUMBER(4,0), "SERIA" NUMBER(10,0), "C_BAZ" NUMBER(14,4), "ID_POZ" NUMBER(10,0), "OPIS_DOD" VARCHAR2(20 BYTE) DEFAULT '', "NR_KOMP_RYS" NUMBER(10,0) DEFAULT 0, "NR_POZ_ROKP" NUMBER(3,0) DEFAULT 0, "NR_PODGR" NUMBER(10,0) DEFAULT 0, "NR_SZAR" NUMBER(6,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table SQL_ARG
--------------------------------------------------------

  CREATE TABLE "SQL_ARG" ("SQL_ID" NUMBER(10,0) DEFAULT 0, "ARG_ID" NUMBER(10,0) DEFAULT 0, "NAZWA" VARCHAR2(30 BYTE) DEFAULT ' ', "ARG_DEFAULT" VARCHAR2(128 BYTE) DEFAULT ' ', "TYP" CHAR(1 BYTE) DEFAULT ' ', "OPIS" VARCHAR2(100 BYTE) DEFAULT ' ') ;
--------------------------------------------------------
--  DDL for Table SQL_FILE
--------------------------------------------------------

  CREATE TABLE "SQL_FILE" ("SQL_ID" NUMBER(10,0), "NAZWA" VARCHAR2(100 BYTE), "SCIEZKA" VARCHAR2(1000 BYTE), "ID_OPER" VARCHAR2(10 BYTE), "DO_WYKON" NUMBER(1,0) DEFAULT 0, "DATA_BASE" VARCHAR2(30 BYTE) DEFAULT ' ', "TYP" NUMBER(1,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table SQL_FILE_HIS
--------------------------------------------------------

  CREATE TABLE "SQL_FILE_HIS" ("HIS_ID" NUMBER(10,0), "SQL_ID" NUMBER(10,0), "TYP" NUMBER(1,0), "NAZWA_SQL" VARCHAR2(100 BYTE), "DATA_TIME" DATE DEFAULT sysdate, "ID_OPER" VARCHAR2(10 BYTE), "DB_USER" VARCHAR2(30 BYTE), "DB_CONN" VARCHAR2(10 BYTE), "SQL_FILE" LONG RAW, "BLEDY" VARCHAR2(1000 BYTE)) ;
--------------------------------------------------------
--  DDL for Table SQL_HISTORIA
--------------------------------------------------------

  CREATE TABLE "SQL_HISTORIA" ("HIS_ID" NUMBER(10,0), "SQL_ID" NUMBER(10,0), "HIS_DATA" DATE DEFAULT sysdate, "ID_OPER" VARCHAR2(10 BYTE)) ;
--------------------------------------------------------
--  DDL for Table SQL_LISTA
--------------------------------------------------------

  CREATE TABLE "SQL_LISTA" ("SQL_ID" NUMBER(10,0), "NAZWA" VARCHAR2(50 BYTE), "KOMENTARZ" VARCHAR2(100 BYTE), "KOD" VARCHAR2(1000 BYTE), "ID_OPER" VARCHAR2(10 BYTE), "CZY_HIST" NUMBER(1,0) DEFAULT 0, "DATA_BASE" VARCHAR2(30 BYTE) DEFAULT ' ', "TYP_INS" VARCHAR2(1 BYTE) DEFAULT ' ') ;
--------------------------------------------------------
--  DDL for Table SQLSIP
--------------------------------------------------------

  CREATE TABLE "SQLSIP" ("LAST_SQL_NO" NUMBER(5,0), "LAST_SQL_DATE" DATE, "JAKA_BAZA" VARCHAR2(1 BYTE)) ;
--------------------------------------------------------
--  DDL for Table SQL_UPRAWNIENIA
--------------------------------------------------------

  CREATE TABLE "SQL_UPRAWNIENIA" ("SQL_ID" NUMBER(10,0), "KLUCZ" VARCHAR2(10 BYTE)) ;
--------------------------------------------------------
--  DDL for Table SQL_UPRAWNIENIA2
--------------------------------------------------------

  CREATE TABLE "SQL_UPRAWNIENIA2" ("SQL_ID" NUMBER(10,0), "OPERATOR_ID" VARCHAR2(10 BYTE)) ;
--------------------------------------------------------
--  DDL for Table STAN_MAG_O
--------------------------------------------------------

  CREATE TABLE "STAN_MAG_O" ("TYP_KAT" VARCHAR2(9 BYTE), "KAT_WYM" VARCHAR2(4 BYTE), "SZER" NUMBER(6,0), "WYS" NUMBER(6,0), "ILOSC_AKT" NUMBER(6,0), "ILOSC_REZ" NUMBER(6,0), "ILOSC_MIN" NUMBER(3,0), "ILOSC_ALARM" NUMBER(6,0), "KOD_POLOZ" VARCHAR2(20 BYTE), "KOD_PRIOR" NUMBER(3,0), "NK_WYM" NUMBER(10,0), "IL_DO_WYK" NUMBER(6,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table STANY_MIN
--------------------------------------------------------

  CREATE TABLE "STANY_MIN" ("INDEKS" VARCHAR2(128 BYTE), "NAZWA" VARCHAR2(255 BYTE), "NR_KAT" NUMBER(4,0), "JEDN" VARCHAR2(5 BYTE), "IL_BIEZ" NUMBER(18,6), "IL_ZAREZ" NUMBER(18,6), "ZUZ_ZA_OKRES" NUMBER(18,6), "ZUZ_WG_KAT" NUMBER(18,6), "STAN_MIN" NUMBER(18,6), "STAN_MAKS" NUMBER(18,6), "NR_MAG" NUMBER(3,0), "ZNACZ_KART" VARCHAR2(3 BYTE), "NR_ODDZ" NUMBER(2,0), "DATA_OD" DATE, "DATA_DO" DATE) ;
--------------------------------------------------------
--  DDL for Table STATUSY
--------------------------------------------------------

  CREATE TABLE "STATUSY" ("ID" NUMBER(2,0), "NAZWA" VARCHAR2(200 BYTE), "SKROT" VARCHAR2(50 BYTE), "NAZWA_KLAWISZ" VARCHAR2(30 BYTE), "KLUCZ" VARCHAR2(10 BYTE), "NAST_STATUSY" VARCHAR2(200 BYTE)) ;
--------------------------------------------------------
--  DDL for Table STATUSY_ZLEC
--------------------------------------------------------

  CREATE TABLE "STATUSY_ZLEC" ("NR_KOMP_ZLEC" NUMBER(10,0), "STATUS" NUMBER(10,0), "OPERATOR" VARCHAR2(10 BYTE) DEFAULT ' ', "KOMPUTER" VARCHAR2(100 BYTE) DEFAULT ' ') ;
--------------------------------------------------------
--  DDL for Table STATUSY_ZLEC_LOG
--------------------------------------------------------

  CREATE TABLE "STATUSY_ZLEC_LOG" ("NR_KOMP_ZLEC" NUMBER(10,0), "STATUS" NUMBER(2,0), "STATUS_LAST" NUMBER(2,0), "DATA" DATE, "CZAS" CHAR(6 BYTE), "OPERATOR" VARCHAR2(100 BYTE), "KOMPUTER" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table ST_BUF_STOJ
--------------------------------------------------------

  CREATE TABLE "ST_BUF_STOJ" ("NK_ZAP" NUMBER(10,0), "TYP_ZAP" NUMBER(1,0), "NK_KONTR" NUMBER(10,0), "NK_ODD" NUMBER(2,0), "NK_STOJ" NUMBER(10,0), "DATA" DATE, "NKOMP" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table ST_KONR
--------------------------------------------------------

  CREATE TABLE "ST_KONR" ("NK_KONTR" NUMBER(10,0), "TYP_ROZ" NUMBER(1,0), "ILOSC_DOP" NUMBER(4,0), "CZAS_DOP" NUMBER(4,0), "DATA_AKT" DATE, "ST_W" NUMBER(4,0), "ST_O" NUMBER(4,0), "DATA_MOD" DATE, "CZAS_MOD" CHAR(6 BYTE), "OPER_MOD" NUMBER(10,0), "ODD_MOD" NUMBER(2,0), "ST_W_DRODZE" NUMBER(4,0), "ST_O_DRODZE" NUMBER(4,0), "FL_AKT" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table ST_KONTR_STOJ
--------------------------------------------------------

  CREATE TABLE "ST_KONTR_STOJ" ("NK_KONTR" NUMBER(10,0), "NK_STOJ" NUMBER(10,0), "NK_ZAP" NUMBER(10,0), "ODD_WYJ" NUMBER(2,0), "DATA_WYJ" DATE, "NK_SPED" NUMBER(10,0), "ODD_PRZYJ" NUMBER(2,0), "DATA_PRZYJ" DATE, "NK_RAP" NUMBER(10,0), "ILOSC_DNI" NUMBER(4,0), "STATUS" NUMBER(1,0), "ZNACZNIK" NUMBER(1,0), "DATA_SPED" DATE, "FL_AKT" NUMBER(1,0), "DATA_NOTY" DATE DEFAULT '1901/01/01', "NR_NOTY" NUMBER(10,0) DEFAULT 0, "ODD_NOTY" NUMBER(2,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table STOJAKI_ALFAK
--------------------------------------------------------

  CREATE TABLE "STOJAKI_ALFAK" ("NR_STOJAKA" NUMBER(8,0), "TYP" VARCHAR2(3 BYTE), "TYP_OPIS" VARCHAR2(16 BYTE), "SZEROKOSC" NUMBER(5,0), "WARTOSC_OPIS" VARCHAR2(60 BYTE), "KLIENT" NUMBER(8,0), "DATA_WYJAZDU" DATE, "DATA_POWROTU" DATE, "NK_STOJ" NUMBER(10,0), "NK_RAP" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table STOJAKI_DEF
--------------------------------------------------------

  CREATE TABLE "STOJAKI_DEF" ("NR_DEF" NUMBER(10,0), "SYMBOL" VARCHAR2(41 BYTE), "TYP" VARCHAR2(1 BYTE), "GLEB" NUMBER(4,0), "ILOSC_SZYB" NUMBER(4,0), "OD_RAMION" NUMBER(4,0), "MIN_SZYBA" NUMBER(4,0), "L_RAMION" NUMBER(2,0), "SZER" NUMBER(4,0), "WYS" NUMBER(4,0), "WSK" NUMBER(1,0), "UDZWIG" NUMBER(10,2), "TOL_SX" NUMBER(5,0), "TOL_SY" NUMBER(5,0), "TOL_ZX" NUMBER(5,0), "TOL_ZY" NUMBER(5,0), "LACZ_MIN" NUMBER(5,0), "LACZ_MAX" NUMBER(5,0), "CO_LACZ" NUMBER(2,0), "MAX_ROWS" NUMBER(5,0) DEFAULT 0, "MAX_COLS" NUMBER(5,0) DEFAULT 0, "MINX" NUMBER(5,0) DEFAULT 0, "MINY" NUMBER(5,0) DEFAULT 0, "WAGA_STOJ" NUMBER(6,1) DEFAULT 0, "CENA_STOJ" NUMBER(14,4) DEFAULT 0, "MIN_DEPTH" NUMBER(6,0) DEFAULT 0, "MAX_DEPTH" NUMBER(6,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table STOJAKI_DEF_O
--------------------------------------------------------

  CREATE TABLE "STOJAKI_DEF_O" ("NR_DEF" NUMBER(10,0), "SYMBOL" VARCHAR2(41 BYTE), "TYP" VARCHAR2(1 BYTE), "GLEB" NUMBER(4,0), "ILOSC_SZYB" NUMBER(4,0), "OD_RAMION" NUMBER(4,0), "MIN_SZYBA" NUMBER(4,0), "L_RAMION" NUMBER(2,0), "SZER" NUMBER(4,0), "WYS" NUMBER(4,0), "WSK" NUMBER(1,0), "UDZWIG" NUMBER(10,2), "WAGA_ST" NUMBER(10,3) DEFAULT 0, "STATUS" NUMBER(1,0) DEFAULT 0, "CZY_WAGA_ZDEF" NUMBER(1,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table STOJ_LACZ
--------------------------------------------------------

  CREATE TABLE "STOJ_LACZ" ("NR_LISTY" NUMBER(10,0), "NR_STOJAKA" NUMBER(4,0), "NR_KLIENTA" NUMBER(10,0), "NR_KIERUNKU" NUMBER(10,0), "NR_ZLECENIA" NUMBER(10,0), "NR_STOJ_W_ZLEC" NUMBER(4,0), "STOJAK_LACZ" NUMBER(1,0), "ILE_ZLECEN" NUMBER(4,0), "POZ_NA_STOJ_ZB" NUMBER(4,0), "STR_STOJAKA_LACZ" NUMBER(2,0), "RZAD_STOJAKA_LACZ" NUMBER(4,0), "ILE_SZYB_NA_STOJAKU" NUMBER(4,0), "SZER_MAX_STOJAKA" NUMBER(4,0), "WYS_MAX_STOJAKA" NUMBER(4,0), "WAGA_SZYB" NUMBER(9,3), "NR_K_OPAK" NUMBER(10,0) DEFAULT 0, "TYP_OPAK" NUMBER(6,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table STOJSPED
--------------------------------------------------------

  CREATE TABLE "STOJSPED" ("NR_STOJ" VARCHAR2(10 BYTE), "TYP_STOJ" CHAR(1 BYTE), "ILOSC_MAX" NUMBER(3,0), "UDZWIG_MAX" NUMBER(10,2), "NR_ODDZ" NUMBER(2,0), "NR_KOMP_STOJ" NUMBER(10,0), "RODZ_STOJ" CHAR(1 BYTE), "GDZIE_JEST" NUMBER(2,0), "NR_ODB" NUMBER(10,0), "NR_SPED" NUMBER(10,0), "ODDZ_SPED" NUMBER(2,0), "DATA_SPED" DATE, "NR_DEF" NUMBER(10,0), "DATA_MOD" DATE, "CZAS_MOD" CHAR(6 BYTE), "AKTYW" NUMBER(5,0), "STATUS" NUMBER(2,0), "ST_DROGA" NUMBER(2,0), "DATA_AKT" DATE, "CZAS_AKT" CHAR(6 BYTE), "WAGA" NUMBER(6,2) DEFAULT 0, "NR_KONTR_SPED" NUMBER(10,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table STORKE_PZLEC
--------------------------------------------------------

  CREATE TABLE "STORKE_PZLEC" ("NR_ZLEC_KLI" VARCHAR2(18 BYTE), "IDENT_ZLEC" NUMBER(10,0), "POZ" NUMBER(4,0), "LINIA" NUMBER(2,0), "POL" NUMBER(3,0), "IL_ZAM" NUMBER(4,0), "IL_WYS" NUMBER(4,0), "IL_POM" NUMBER(4,0), "ROZNICA" NUMBER(4,0), "SZER" NUMBER(4,0), "WYS" NUMBER(4,0), "KOD_KLI" VARCHAR2(7 BYTE), "STOJAK1" NUMBER(10,0), "STOJAK2" NUMBER(10,0), "STOJAK3" NUMBER(10,0), "IDENT_LINII" NUMBER(10,0), "NR_KOMP_ZLEC" NUMBER(10,0), "NR_POZ_ZLEC" NUMBER(3,0)) ;
--------------------------------------------------------
--  DDL for Table STORKE_ZLEC
--------------------------------------------------------

  CREATE TABLE "STORKE_ZLEC" ("NR_ZLEC_KLI" VARCHAR2(18 BYTE), "D_WCZYT" DATE, "C_WCZYT" CHAR(6 BYTE), "IL_ZAM" NUMBER(4,0), "IL_WYS" NUMBER(4,0), "IL_POMIN" NUMBER(4,0), "ROZNICA" NUMBER(4,0), "IL_POZ" NUMBER(3,0), "IDENT_ZLEC" NUMBER(10,0), "FLAG_R" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table ST_PREM
--------------------------------------------------------

  CREATE TABLE "ST_PREM" ("NR_KOMP_INSTAL" NUMBER(10,0), "ST_WART" NUMBER(14,4), "OPIS" VARCHAR2(20 BYTE), "NORMA_W_JEDN" NUMBER(13,3), "NORMA_W_SZT" NUMBER(10,0), "ILOSC_PRAC" NUMBER(3,0), "NR_OPER" VARCHAR2(10 BYTE), "DATA_MODYF" DATE, "OD_DNIA" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table ST_RAP
--------------------------------------------------------

  CREATE TABLE "ST_RAP" ("NK_RAP" NUMBER(10,0), "DATA_RAP" DATE, "CZAS_RAP" CHAR(6 BYTE), "NK_KONTR" NUMBER(10,0), "NK_ODD" NUMBER(2,0), "NR_REJ" VARCHAR2(17 BYTE), "KIER" VARCHAR2(30 BYTE), "ST_KW" NUMBER(4,0), "ST_KO" NUMBER(4,0), "DATA_WPR" DATE, "CZAS_WPR" CHAR(6 BYTE), "OP_WPR" NUMBER(10,0), "OD_WPR" NUMBER(2,0), "ST_W" NUMBER(4,0), "ST_O" NUMBER(4,0), "DATA_MOD" DATE, "CZAS_MOD" CHAR(6 BYTE), "OP_MOD" NUMBER(10,0), "ODD_MOD" NUMBER(2,0), "UWAGI" VARCHAR2(100 BYTE), "STATUS" NUMBER(1,0), "TYP_ZAP" NUMBER(1,0), "ST_W_KLIENT" NUMBER(4,0), "ST_O_KLIENT" NUMBER(4,0), "NR_SPED" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table ST_RAP_POZ
--------------------------------------------------------

  CREATE TABLE "ST_RAP_POZ" ("NK_RAP" NUMBER(10,0), "NR_POZ" NUMBER(4,0), "NK_ST" NUMBER(10,0), "DATA" DATE, "CZAS" CHAR(6 BYTE), "STATUS" NUMBER(2,0), "CO_ZE_STOJ" NUMBER(2,0), "ILE_K_NA_ST" NUMBER(5,0), "NR_SPED" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table STR_PARAM
--------------------------------------------------------

  CREATE TABLE "STR_PARAM" ("KOD_STR" VARCHAR2(128 BYTE), "NR_PARAM" NUMBER(4,0), "NAZWA_PARAM" NUMBER(11,5), "SYMBOL_PARAM" VARCHAR2(200 BYTE), "FLAGA_WYSTEPOWANIA" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table STRUKTURY
--------------------------------------------------------

  CREATE TABLE "STRUKTURY" ("NR_KOM_STR" NUMBER(10,0), "KOD_STR" VARCHAR2(128 BYTE), "TYP_STR" CHAR(2 BYTE), "PKWIU" CHAR(18 BYTE), "ZN_ZESP" VARCHAR2(18 BYTE), "WAGA" NUMBER(10,3), "NR_MAG" NUMBER(3,0), "NR_ANAL" NUMBER(3,0), "GR_TOW" VARCHAR2(3 BYTE), "NAZ_STR" VARCHAR2(255 BYTE), "IND_BUD" VARCHAR2(30 BYTE), "ATR_BUD" NUMBER(18,0), "NAZ_DLA_KLI" VARCHAR2(64 BYTE), "CENA" NUMBER(14,4), "WSP_CEN" NUMBER(7,3), "MARZA" NUMBER(7,3), "NAZ_VAT" VARCHAR2(5 BYTE), "IL_WARSTW" NUMBER(2,0), "POZ_ZAGL" NUMBER(1,0), "JEDNOSTKA" VARCHAR2(5 BYTE), "CENA_MIN" NUMBER(14,4), "TYP_POZYCJI" VARCHAR2(3 BYTE), "IL_SZK" NUMBER(1,0), "KOSZTN" NUMBER(14,4), "NR_KOMP_GR" NUMBER(10,0), "WSP_K" NUMBER(4,2), "NR_NAPISU" NUMBER(3,0), "ENERGIE" VARCHAR2(2 BYTE), "KSWIATL" NUMBER(8,3), "G_SZER" NUMBER(4,0) DEFAULT 0, "G_WYS" NUMBER(4,0) DEFAULT 0, "NR_KOMP_RYS" NUMBER(10,0) DEFAULT 0, "AKT" NUMBER(2,0) DEFAULT 0, "GR_PAK" NUMBER(4,1) DEFAULT 0, "N_RAM" VARCHAR2(100 BYTE) DEFAULT ' ') ;
--------------------------------------------------------
--  DDL for Table STR_W_ZLEC
--------------------------------------------------------

  CREATE TABLE "STR_W_ZLEC" ("NR_KOM_ZLEC" NUMBER(10,0), "NR_KOL_STRUKT" NUMBER(6,0), "NR_KOM_STR" VARCHAR2(128 BYTE), "NR_KAT_DOD" VARCHAR2(128 BYTE), "GR_KOSZT_WYR" NUMBER(6,0), "ILE_W_ZL" NUMBER(16,4), "ILE_DOD" NUMBER(6,0), "ILE_SZTUK" NUMBER(6,0), "SUMA_OBW" NUMBER(16,4), "SUMA_OBJ" NUMBER(16,4)) ;
--------------------------------------------------------
--  DDL for Table STVAT
--------------------------------------------------------

  CREATE TABLE "STVAT" ("NAZ_VAT" CHAR(5 BYTE), "WYSOKOSC" NUMBER(7,4), "P_NA_NETTO" NUMBER(7,4), "OBOW_OD" DATE, "OBOW_DO" DATE, "PTU" VARCHAR2(1 BYTE)) ;
--------------------------------------------------------
--  DDL for Table SUR_KONFIG
--------------------------------------------------------

  CREATE TABLE "SUR_KONFIG" ("NR_KATALOG" NUMBER(6,0), "TYP_KATALOG" VARCHAR2(9 BYTE), "TYP_TRANS" VARCHAR2(10 BYTE), "PARAM1" NUMBER(6,0), "PARAM2" NUMBER(6,0), "PARAM3" NUMBER(6,0), "PARAM4" NUMBER(6,0), "PARAM5" NUMBER(6,0), "SPAR1" VARCHAR2(12 BYTE), "SPAR2" VARCHAR2(12 BYTE), "SPAR3" VARCHAR2(12 BYTE), "RODZAJ_SUR" VARCHAR2(3 BYTE)) ;
--------------------------------------------------------
--  DDL for Table SURZAM
--------------------------------------------------------

  CREATE TABLE "SURZAM" ("NR_ZLEC" NUMBER(6,0), "TYP_ZLEC" CHAR(3 BYTE), "NR_KAT" NUMBER(4,0), "RODZ_SUR" CHAR(3 BYTE), "INDEKS" VARCHAR2(128 BYTE), "IL_ZAM" NUMBER(14,6), "IL_ZAD" NUMBER(14,6), "IL_RW" NUMBER(14,6), "STRATY" NUMBER(5,2), "STATUS" CHAR(2 BYTE), "NR_RW" NUMBER(10,0), "DATA_RW" DATE, "NR_ZW" NUMBER(10,0), "DATA_ZW" DATE, "IL_SZT" NUMBER(14,0), "DATA_PL" DATE, "ZM_PL" NUMBER(1,0), "CZAS_PLAN" NUMBER(10,0), "DATA_PROD" DATE, "ZM_PROD" NUMBER(1,0), "NR_KOMP_INST" NUMBER(10,0), "NR_KOMP_ZLEC" NUMBER(10,0), "NR_ODDZ" NUMBER(2,0), "ROK" NUMBER(4,0), "MIES" NUMBER(2,0), "NR_MAG" NUMBER(3,0), "IL_C" NUMBER(14,0), "POW_C" NUMBER(14,6), "IL_I_KOM" NUMBER(14,0), "POW_I_KOM" NUMBER(14,6), "IL_II_KOM" NUMBER(14,0), "POW_II_KOM" NUMBER(14,6), "IL_STR" NUMBER(14,0), "POW_STR" NUMBER(14,6), "RW_POB" NUMBER(14,6), "IL_DO_WYD_RW" NUMBER(14,6), "WSP_PRZEL" NUMBER(7,4), "FLAGWYC" NUMBER(1,0), "NROPT" NUMBER(6,0), "IL_WYC_SUR" NUMBER(10,4) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table SZABLON
--------------------------------------------------------

  CREATE TABLE "SZABLON" ("POLE" VARCHAR2(10 BYTE), "P" NUMBER(3,0), "K" NUMBER(3,0), "NR" NUMBER(3,0), "TYP" NUMBER(3,0)) ;
--------------------------------------------------------
--  DDL for Table TDOK
--------------------------------------------------------

  CREATE TABLE "TDOK" ("NR_KOMP_DOK" NUMBER(10,0), "NR_DOK" NUMBER(8,0), "DATA_D" DATE, "DATA_TR" DATE, "NR_DOK_BAZ" VARCHAR2(18 BYTE), "DATA_D_BAZ" DATE, "TYP_DOK" VARCHAR2(3 BYTE), "OPIS" VARCHAR2(50 BYTE), "NR_MAG" NUMBER(3,0), "NR_MAG_DOC" NUMBER(3,0), "NR_KON" NUMBER(10,0), "STATUS" NUMBER(1,0), "STORNO" NUMBER(1,0), "GR_DOK" VARCHAR2(3 BYTE), "NR_KOM_FAKT" NUMBER(10,0), "TYP_ZLEC" VARCHAR2(3 BYTE), "ROK" NUMBER(4,0), "MIES" NUMBER(2,0), "NR_ODDZ" NUMBER(2,0), "NR_KOMP_BAZ" NUMBER(10,0), "NR_DOK_POSRED" NUMBER(10,0), "NR_DOK_ZWRAC" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table TEMP_0042142
--------------------------------------------------------

  CREATE TABLE "TEMP_0042142" ("FLD1" NUMBER(10,0), "FLD2" NUMBER(14,0), "FLD3" DATE, "FLD4" NUMBER) ;
--------------------------------------------------------
--  DDL for Table TEMP_1197050
--------------------------------------------------------

  CREATE TABLE "TEMP_1197050" ("FLD1" NUMBER(10,0), "FLD2" NUMBER(14,0), "FLD3" DATE, "FLD4" NUMBER) ;
--------------------------------------------------------
--  DDL for Table TEMP_1487760
--------------------------------------------------------

  CREATE TABLE "TEMP_1487760" ("FLD1" NUMBER(10,0), "FLD2" NUMBER(14,0), "FLD3" DATE, "FLD4" NUMBER) ;
--------------------------------------------------------
--  DDL for Table TEMP_1603112
--------------------------------------------------------

  CREATE TABLE "TEMP_1603112" ("FLD1" NUMBER(10,0), "FLD2" NUMBER(14,0), "FLD3" DATE, "FLD4" NUMBER) ;
--------------------------------------------------------
--  DDL for Table TEMP_1659796
--------------------------------------------------------

  CREATE TABLE "TEMP_1659796" ("FLD1" NUMBER(10,0), "FLD2" NUMBER(14,0), "FLD3" DATE, "FLD4" NUMBER) ;
--------------------------------------------------------
--  DDL for Table TEMP_2141896
--------------------------------------------------------

  CREATE TABLE "TEMP_2141896" ("FLD1" NUMBER(10,0), "FLD2" NUMBER(14,0), "FLD3" DATE, "FLD4" NUMBER) ;
--------------------------------------------------------
--  DDL for Table TEMP_2913376
--------------------------------------------------------

  CREATE TABLE "TEMP_2913376" ("FLD1" NUMBER(10,0), "FLD2" NUMBER(14,0), "FLD3" DATE, "FLD4" NUMBER) ;
--------------------------------------------------------
--  DDL for Table TEMP_3514942
--------------------------------------------------------

  CREATE TABLE "TEMP_3514942" ("FLD1" NUMBER(10,0), "FLD2" NUMBER(14,0), "FLD3" DATE, "FLD4" NUMBER) ;
--------------------------------------------------------
--  DDL for Table TEMP_5097240
--------------------------------------------------------

  CREATE TABLE "TEMP_5097240" ("FLD1" NUMBER(10,0), "FLD2" NUMBER(14,0), "FLD3" DATE, "FLD4" NUMBER) ;
--------------------------------------------------------
--  DDL for Table TEMP_5389712
--------------------------------------------------------

  CREATE TABLE "TEMP_5389712" ("FLD1" NUMBER(10,0), "FLD2" NUMBER(14,0), "FLD3" DATE, "FLD4" NUMBER) ;
--------------------------------------------------------
--  DDL for Table TEMP_5670094
--------------------------------------------------------

  CREATE TABLE "TEMP_5670094" ("FLD1" NUMBER(10,0), "FLD2" NUMBER(14,0), "FLD3" DATE, "FLD4" NUMBER) ;
--------------------------------------------------------
--  DDL for Table TEMP_5684181
--------------------------------------------------------

  CREATE TABLE "TEMP_5684181" ("FLD1" NUMBER(10,0), "FLD2" NUMBER(14,0), "FLD3" DATE, "FLD4" NUMBER) ;
--------------------------------------------------------
--  DDL for Table TEMP_6392326
--------------------------------------------------------

  CREATE TABLE "TEMP_6392326" ("FLD1" NUMBER(10,0), "FLD2" NUMBER(14,0), "FLD3" DATE, "FLD4" NUMBER) ;
--------------------------------------------------------
--  DDL for Table TEMP_7361000
--------------------------------------------------------

  CREATE TABLE "TEMP_7361000" ("FLD1" NUMBER(10,0), "FLD2" NUMBER(14,0), "FLD3" DATE, "FLD4" NUMBER) ;
--------------------------------------------------------
--  DDL for Table TEMP_8601681
--------------------------------------------------------

  CREATE TABLE "TEMP_8601681" ("FLD1" NUMBER(10,0), "FLD2" NUMBER(14,0), "FLD3" DATE, "FLD4" NUMBER) ;
--------------------------------------------------------
--  DDL for Table TEMP_8693340
--------------------------------------------------------

  CREATE TABLE "TEMP_8693340" ("FLD1" NUMBER(10,0), "FLD2" NUMBER(14,0), "FLD3" DATE, "FLD4" NUMBER) ;
--------------------------------------------------------
--  DDL for Table TLUM_NAPIS
--------------------------------------------------------

  CREATE TABLE "TLUM_NAPIS" ("NR_JEZYKA" NUMBER(4,0), "NR_WYRAZENIA" NUMBER(6,0), "GR_WYRAZEN" NUMBER(2,0), "TEKST_PELNY" VARCHAR2(100 BYTE), "TEKST_SKROCONY" VARCHAR2(20 BYTE)) ;
--------------------------------------------------------
--  DDL for Table TLUM_NAPIS_BAC
--------------------------------------------------------

  CREATE TABLE "TLUM_NAPIS_BAC" ("NR_JEZYKA" NUMBER(4,0), "NR_WYRAZENIA" NUMBER(6,0), "GR_WYRAZEN" NUMBER(2,0), "TEKST_PELNY" VARCHAR2(100 BYTE), "TEKST_SKROCONY" VARCHAR2(20 BYTE)) ;
--------------------------------------------------------
--  DDL for Table TLUM_NAPIS_UNICODE
--------------------------------------------------------

  CREATE TABLE "TLUM_NAPIS_UNICODE" ("NR_JEZYKA" NUMBER(4,0), "NR_WYRAZENIA" NUMBER(6,0), "GR_WYRAZEN" NUMBER(2,0), "TEKST_PELNY" NVARCHAR2(1000), "TEKST_SKROCONY" NVARCHAR2(200)) ;
--------------------------------------------------------
--  DDL for Table TMPDOK
--------------------------------------------------------

  CREATE TABLE "TMPDOK" ("NR_KOMP_DOK" NUMBER(10,0), "NR_DOK" NUMBER(8,0), "DATA_D" DATE, "DATA_TR" DATE, "NR_DOK_BAZ" CHAR(19 BYTE), "DATA_D_BAZ" DATE, "TYP_DOK" VARCHAR2(3 BYTE), "OPIS" CHAR(50 BYTE), "NR_MAG" NUMBER(3,0), "NR_MAG_DOC" NUMBER(3,0), "NR_KON" NUMBER(10,0), "STATUS" NUMBER(1,0), "STORNO" NUMBER(1,0), "GR_DOK" CHAR(3 BYTE), "NR_KOM_FAKT" NUMBER(10,0), "TYP_ZLEC" CHAR(3 BYTE), "ROK" NUMBER(4,0), "MIES" NUMBER(2,0), "NR_ODDZ" NUMBER(2,0), "NR_KOMP_BAZ" NUMBER(10,0), "NR_DOK_STORNO" NUMBER(10,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table TMP_LLTRSZKLA
--------------------------------------------------------

  CREATE TABLE "TMP_LLTRSZKLA" ("NR_KOMP_LISTY" NUMBER(10,0), "NR_KOMP_ZLEC" NUMBER(10,0), "NR_PODGR" NUMBER(10,0), "NR_KAT" NUMBER(4,0), "NR_INSTAL" NUMBER(10,0), "IL_SZT" NUMBER(10,0), "IL_WARST" NUMBER(10,0), "SUMA_POW" NUMBER(14,4), "WYBOR_ZLECENIA" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table TMPPOZDOK
--------------------------------------------------------

  CREATE TABLE "TMPPOZDOK" ("TYP_DOK" VARCHAR2(3 BYTE), "DATA_D" DATE, "NR_DOK" NUMBER(8,0), "NR_POZ" NUMBER(5,0), "INDEKS" VARCHAR2(128 BYTE), "ILOSC_JR" NUMBER(14,0), "ILOSC_JP" NUMBER(14,6), "STAN1" NUMBER(14,6), "STAN2" NUMBER(14,6), "CENA_PRZYJ" NUMBER(14,4), "CEN_WYD" NUMBER(14,4), "STORNO" NUMBER(1,0), "NR_POZ_ZLEC" NUMBER(3,0), "CZY_DOD" VARCHAR2(1 BYTE), "ROK" NUMBER(4,0) DEFAULT 0, "MIES" NUMBER(2,0) DEFAULT 0, "NR_ODDZ" NUMBER(2,0), "NR_MAG" NUMBER(3,0), "NR_KOMP_DOK" NUMBER(10,0), "NR_KOMP_BAZ" NUMBER(10,0), "ZNACZNIK_KARTOTEKI" CHAR(3 BYTE), "STATUS_DOKUMENTU" NUMBER(1,0) DEFAULT 0, "KOL_DOD" NUMBER(3,0) DEFAULT 0, "C_DODATK" NUMBER(14,4) DEFAULT 0, "SERIA" NUMBER(10,0) DEFAULT 0, "NR_DOK_ZROD" NUMBER(14,0) DEFAULT 0, "IL_SZT_STORNO" NUMBER(10,0) DEFAULT 0, "IL_JP_STORNO" NUMBER(8,6) DEFAULT 0, "NR_POZ_ZROD" NUMBER(5,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table TMP_SUROPT
--------------------------------------------------------

  CREATE TABLE "TMP_SUROPT" ("NR_KAT" NUMBER(4,0), "NAZ_KAT" VARCHAR2(50 BYTE), "NAZ_SKROC" VARCHAR2(6 BYTE), "KOL_SORT" NUMBER(2,0), "IL_ZE_ZLEC" NUMBER(18,6), "STRATY" NUMBER(5,2), "IL_SZT" NUMBER(14,0), "WYBRANE" NUMBER(1,0), "TYP_KATALOG" VARCHAR2(18 BYTE), "ILE_ZALEG" NUMBER(14,0), "M2_ZALEG" NUMBER(18,6), "ILE_Z_WYPRZEDZ" NUMBER(14,0), "M2_Z_WYPRZEDZ" NUMBER(18,6), "M2_JUZ_WYC" NUMBER(18,6), "SZT_JUZ_WYC" NUMBER(14,0), "TRYB_C" VARCHAR2(1 BYTE), "NR_INST_C" NUMBER(10,0), "NR_ZM_POCZ" NUMBER(10,0), "NR_INST_PRZEZN" NUMBER(10,0), "TRYB_WYBORU" VARCHAR2(1 BYTE), "INDEKS" VARCHAR2(128 BYTE), "NR_KOMP_LISTY" NUMBER(10,0), "ILE_STOJ" NUMBER(5,0), "NR_OST_STOJ" NUMBER(5,0), "NR_POZ_ST" NUMBER(5,0)) ;
--------------------------------------------------------
--  DDL for Table TN_FUN
--------------------------------------------------------

  CREATE TABLE "TN_FUN" ("NR_FUN" NUMBER(3,0), "OPIS" VARCHAR2(100 BYTE), "A_POLA" VARCHAR2(20 BYTE)) ;
--------------------------------------------------------
--  DDL for Table TN_POLA
--------------------------------------------------------

  CREATE TABLE "TN_POLA" ("TYP_POLA" VARCHAR2(1 BYTE), "NAZ_POLA" VARCHAR2(30 BYTE), "ROD_POLA" VARCHAR2(2 BYTE), "FORMAT" VARCHAR2(20 BYTE), "WSK" NUMBER(1,0), "WSK1" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table TOWARY_O
--------------------------------------------------------

  CREATE TABLE "TOWARY_O" ("NR_KOMP" NUMBER(10,0), "TYP_KAT" VARCHAR2(9 BYTE), "WALUTA" VARCHAR2(4 BYTE), "C_SPEC" NUMBER(14,4), "C_KNT" NUMBER(14,4), "C_SKR" NUMBER(14,4), "C_REG" NUMBER(14,4), "WSKAZ" NUMBER(1,0), "NR_PROF" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table TPOZ
--------------------------------------------------------

  CREATE TABLE "TPOZ" ("TYP_DOK" VARCHAR2(3 BYTE), "DATA_D" DATE, "NR_DOK" NUMBER(8,0), "NR_POZ" NUMBER(5,0), "INDEKS" VARCHAR2(128 BYTE), "ILOSC_JR" NUMBER(10,0), "ILOSC_JP" NUMBER(14,6), "STAN1" NUMBER(14,6), "STAN2" NUMBER(14,6), "CENA_PRZYJ" NUMBER(14,4), "CEN_WYD" NUMBER(14,4), "STORNO" NUMBER(1,0), "NR_POZ_ZLEC" NUMBER(3,0), "CZY_DOD" VARCHAR2(1 BYTE), "ROK" NUMBER(4,0), "MIES" NUMBER(2,0), "NR_ODDZ" NUMBER(2,0), "NR_MAG" NUMBER(3,0), "NR_KOMP_DOK" NUMBER(10,0), "NR_KOMP_BAZ" NUMBER(10,0), "ZN_KART" VARCHAR2(3 BYTE), "STATUS_DOK" NUMBER(1,0), "KOL_DOD" NUMBER(3,0), "CENA_DOD" NUMBER(14,4), "NR_KAT_CZYN" NUMBER(4,0), "NR_KAT_SUR" NUMBER(4,0), "IL_NETTO_SUR" NUMBER(14,4), "INDEKS_SUR" VARCHAR2(128 BYTE), "NR_MAG_SUR" NUMBER(3,0), "INDEKS_CZYN" VARCHAR2(128 BYTE), "IL_ROZLICZ_CZYN" NUMBER(14,4), "IL_POZOST_DO_WYD" NUMBER(14,4), "IL_WYD_W_DOK" NUMBER(14,4)) ;
--------------------------------------------------------
--  DDL for Table TR1_BUFOR
--------------------------------------------------------

  CREATE TABLE "TR1_BUFOR" ("NUMER" NUMBER(10,0), "LINIA" VARCHAR2(1000 BYTE)) ;
--------------------------------------------------------
--  DDL for Table TR2_BUFOR
--------------------------------------------------------

  CREATE TABLE "TR2_BUFOR" ("NUMER" NUMBER(10,0), "LINIA" VARCHAR2(1000 BYTE)) ;
--------------------------------------------------------
--  DDL for Table TR3_TABELA1
--------------------------------------------------------

  CREATE TABLE "TR3_TABELA1" ("M_DESC" VARCHAR2(20 BYTE), "M_NAME" VARCHAR2(20 BYTE), "M_PUBLIC" VARCHAR2(20 BYTE), "M_DBNAME" VARCHAR2(20 BYTE), "ZNACZNIK" VARCHAR2(10 BYTE), "ID" NUMBER(6,0), "M_ITEM_ISN" NUMBER(6,0), "M_ISN" NUMBER(6,0)) ;
--------------------------------------------------------
--  DDL for Table TR5_TABELA2
--------------------------------------------------------

  CREATE TABLE "TR5_TABELA2" ("NUMER" NUMBER(4,0), "A_NAME" VARCHAR2(20 BYTE), "A_DESC" VARCHAR2(20 BYTE), "A_DBNAME" VARCHAR2(20 BYTE), "ID" NUMBER(6,0), "ZNACZNIK" NUMBER(6,0)) ;
--------------------------------------------------------
--  DDL for Table TRAN_IND
--------------------------------------------------------

  CREATE TABLE "TRAN_IND" ("NK_KONTR" NUMBER(10,0), "ZN" NUMBER(1,0), "TYP_POLA" NUMBER(4,0), "NR_SKL" NUMBER(4,0), "POCZ" NUMBER(4,0), "KON" NUMBER(4,0), "KOL" NUMBER(4,0), "NR_SZBL" NUMBER(4,0), "OPIS" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table TRAN_IND0
--------------------------------------------------------

  CREATE TABLE "TRAN_IND0" ("NK_KONTR" NUMBER(10,0), "NR_SZABL" NUMBER(4,0), "OPIS_SZABL" VARCHAR2(100 BYTE), "POL_KONW" VARCHAR2(250 BYTE), "PLIK_WYN" VARCHAR2(250 BYTE), "KON_PARAM" VARCHAR2(200 BYTE), "ZNAK_SEPAR_1" VARCHAR2(4 BYTE) DEFAULT '', "ZNAK_SEPAR_2" VARCHAR2(4 BYTE) DEFAULT '', "PAR_DOD_1" NUMBER(4,0) DEFAULT 0, "PAR_DOD_2" NUMBER(4,0) DEFAULT 0, "PAR_DOD_3" NUMBER(4,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table TRAN_IND1
--------------------------------------------------------

  CREATE TABLE "TRAN_IND1" ("NK_KONTR" NUMBER(10,0), "NR_SZABL" NUMBER(4,0), "SKLADOWA" NUMBER(4,0), "TYP_POLA" NUMBER(4,0), "POCZATEK" NUMBER(4,0), "KONIEC" NUMBER(4,0), "KOLUMNA" NUMBER(4,0), "ZNAK" VARCHAR2(1 BYTE)) ;
--------------------------------------------------------
--  DDL for Table TRAN_KONTR
--------------------------------------------------------

  CREATE TABLE "TRAN_KONTR" ("KLIENT_C7_4" VARCHAR2(20 BYTE), "NR_KLIENTA" NUMBER(10,0), "AKCEPTACJA" NUMBER(1,0), "ODD_WPIS" NUMBER(2,0), "DATA_WPIS" DATE, "OP_WPIS" NUMBER(10,0), "ODD_MOD" NUMBER(2,0), "DATA_MOD" DATE, "OP_MOD" NUMBER(10,0), "ODD_AKCEPT" NUMBER(2,0), "DATA_AKCEPT" DATE, "OP_AKCEPT" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table TRAN_POZ
--------------------------------------------------------

  CREATE TABLE "TRAN_POZ" ("NR_KOL" NUMBER(10,0), "NR_POZ_ZLEC" NUMBER(3,0), "SZER" NUMBER(4,0), "WYS" NUMBER(4,0), "ILOSC" NUMBER(4,0), "NR_KSZT" NUMBER(3,0), "WSP_K" NUMBER(4,2), "OPIS" VARCHAR2(100 BYTE) DEFAULT '', "INDEKS" VARCHAR2(500 BYTE) DEFAULT ' ', "UWAGI" VARCHAR2(100 BYTE), "NR_STRUK" NUMBER(10,0), "CENA" NUMBER(14,4), "RODZAJ_CENY" VARCHAR2(4 BYTE), "WSK" NUMBER(1,0), "L" NUMBER(4,0), "H" NUMBER(4,0), "W1" NUMBER(4,0), "W2" NUMBER(4,0), "H1" NUMBER(4,0), "H2" NUMBER(4,0), "R" NUMBER(4,0), "R1" NUMBER(4,0), "R2" NUMBER(4,0), "KOD_SZPROSU" VARCHAR2(50 BYTE), "WSP1" NUMBER(4,0), "WSP2" NUMBER(4,0), "SZPROS_IND" VARCHAR2(128 BYTE), "SZPROS_MAG" NUMBER(3,0), "ZN_WIEL" NUMBER(1,0), "CZY_KONTR" NUMBER(1,0), "POW_POZ" NUMBER(14,4), "KAT_KSZT" NUMBER(3,0) DEFAULT 0, "CZY_SZABLON" NUMBER(1,0) DEFAULT 0, "NR_SZPROSU" NUMBER(3,0) DEFAULT 0, "IL_PAR_SZPROSU" NUMBER(3,0) DEFAULT 0, "SZP_INDEKS2" VARCHAR2(128 BYTE), "PAR_SZP" VARCHAR2(2000 BYTE), "TYP_SZPROSU" NUMBER(1,0) DEFAULT 0, "STR_DO_UST" NUMBER(1,0) DEFAULT 0, "STR_DO_AKC" NUMBER(1,0) DEFAULT 0, "SZPRS_DO_UST" NUMBER(1,0) DEFAULT 0, "SZPR_DO_AKC" NUMBER(1,0) DEFAULT 0, "AKCEPTACJA" NUMBER(1,0) DEFAULT 0, "KS_OK" NUMBER(1,0) DEFAULT 0, "R3" NUMBER(4,0) DEFAULT 0, "T1" NUMBER(4,0) DEFAULT 0, "T2" NUMBER(4,0) DEFAULT 0, "T3" NUMBER(4,0) DEFAULT 0, "T4" NUMBER(4,0) DEFAULT 0, "D" NUMBER(4,0) DEFAULT 0, "POL" VARCHAR2(20 BYTE), "ZN_POW" NUMBER(2,0) DEFAULT 0, "OPIS_DOD" VARCHAR2(100 BYTE) DEFAULT '', "OPIS_DOD1" VARCHAR2(100 BYTE) DEFAULT '', "N_SZPR2" VARCHAR2(50 BYTE) DEFAULT '', "SZP_DO_UST1" NUMBER(1,0) DEFAULT 0, "SZP_DO_UST2" NUMBER(1,0) DEFAULT 0, "SZP_DO_AKC1" NUMBER(1,0) DEFAULT 0, "SZP_DO_AKC2" NUMBER(1,0) DEFAULT 0, "NALEPKA" VARCHAR2(50 BYTE) DEFAULT ' ', "NAPIS_RAM" VARCHAR2(50 BYTE) DEFAULT ' ', "INFO_POZ_1" VARCHAR2(255 BYTE) DEFAULT '', "INFO_POZ_2" VARCHAR2(255 BYTE) DEFAULT '', "PAR_KSZT" VARCHAR2(100 BYTE) DEFAULT ' ', "KLUCZ" VARCHAR2(100 BYTE) DEFAULT ' ', "OPIS_DOD2" VARCHAR2(100 BYTE) DEFAULT ' ', "KOM_SZP" VARCHAR2(5 BYTE) DEFAULT ' ') ;
--------------------------------------------------------
--  DDL for Table TRANS_KONFIG
--------------------------------------------------------

  CREATE TABLE "TRANS_KONFIG" ("NR_KOMP_KONF" NUMBER(10,0), "SYMBOL_TRANS" VARCHAR2(20 BYTE), "NAZWA_TRANS" VARCHAR2(100 BYTE), "TYP_TRANS" VARCHAR2(10 BYTE), "NR_INSTAL" NUMBER(10,0), "SCIEZKA_PLIKOW" VARCHAR2(100 BYTE), "SCIEZKA_PRG" VARCHAR2(100 BYTE), "PRG_WYKON" VARCHAR2(100 BYTE), "PARAM_WYWOL" VARCHAR2(100 BYTE), "PARAM1" NUMBER(6,0), "PARAM2" NUMBER(6,0), "PARAM3" NUMBER(6,0), "PARAM4" NUMBER(6,0), "PARAM_5" NUMBER(5,0), "SPAR1" VARCHAR2(12 BYTE), "SPAR2" VARCHAR2(12 BYTE), "SPAR3" VARCHAR2(12 BYTE), "AKTYWNY" NUMBER(1,0), "LPAR_1" NUMBER(1,0), "LPAR2" NUMBER(1,0), "LPAR3" NUMBER(1,0), "GRP__PLANSZA" NUMBER(2,0), "GRP_TRANSFERY" NUMBER(2,0), "FILE_PREFIX" VARCHAR2(12 BYTE), "FILE_SUFFIX" VARCHAR2(12 BYTE), "LPAR4" NUMBER(1,0) DEFAULT 0, "LPAR5" NUMBER(1,0) DEFAULT 0, "LPAR6" NUMBER(1,0) DEFAULT 0, "LPAR7" NUMBER(1,0) DEFAULT 0, "LPAR8" NUMBER(1,0) DEFAULT 0, "PARAM_6" NUMBER(6,0) DEFAULT 0, "PARAM_7" NUMBER(6,0) DEFAULT 0, "PARAM_8" NUMBER(6,0) DEFAULT 0, "LISTA_INSTALACJI" VARCHAR2(100 BYTE) DEFAULT '', "LISTA_OBROBEK" VARCHAR2(100 BYTE) DEFAULT '') ;
--------------------------------------------------------
--  DDL for Table TRANS_POL
--------------------------------------------------------

  CREATE TABLE "TRANS_POL" ("TYP" NUMBER(3,0), "LINIA" VARCHAR2(500 BYTE)) ;
--------------------------------------------------------
--  DDL for Table TRAN_STR
--------------------------------------------------------

  CREATE TABLE "TRAN_STR" ("KOD_DLA_KLI" VARCHAR2(500 BYTE) DEFAULT ' ', "NR_KOMP_STR" NUMBER(10,0), "NUMER_KONTRAHENTA" NUMBER(10,0), "AKCEPTACJA" NUMBER(1,0), "ODD_WPIS" NUMBER(2,0), "DATA_WPIS" DATE, "OP_WPIS" NUMBER(10,0), "ODD_MOD" NUMBER(2,0), "DATA_MOD" DATE, "OP_MOD" NUMBER(10,0), "ODD_AKCEPT" NUMBER(2,0), "DATA_AKCEPT" DATE, "OP_AKCEPT" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table TRAN_SZPR
--------------------------------------------------------

  CREATE TABLE "TRAN_SZPR" ("NAZWA_SZPROSU" VARCHAR2(50 BYTE), "INDEKS" VARCHAR2(50 BYTE), "NR_MAG" NUMBER(3,0), "NUMER_KONTRAHENTA" NUMBER(10,0), "AKCEPTACHJA" NUMBER(1,0), "ODD_WPIS" NUMBER(2,0), "DATA_WPIS" DATE, "OP_WPIS" NUMBER(10,0), "ODD_MOD" NUMBER(2,0), "DATA_MOD" DATE, "OP_MOD" NUMBER(10,0), "ODD_AKCEPT" NUMBER(2,0), "DATA_AKCEPT" DATE, "OP_AKCEPT" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table TRAN_ZAM
--------------------------------------------------------

  CREATE TABLE "TRAN_ZAM" ("NR_KOL" NUMBER(10,0), "NAZ_KONTR" VARCHAR2(50 BYTE), "DATA_ZLEC" DATE, "NR_ZLEC_KLIENTA" VARCHAR2(18 BYTE), "ADRES" VARCHAR2(31 BYTE), "ILOSC" NUMBER(4,0), "NR_WEW" VARCHAR2(10 BYTE), "UWAGI" VARCHAR2(200 BYTE), "NR_KONTR" NUMBER(10,0), "I_WCZYT" NUMBER(4,0), "I_AKCEPT" NUMBER(4,0), "NUMER_ADRESU_DOSTAWY" NUMBER(10,0), "WSK_SZPROS" NUMBER(1,0), "NAZ_ZB" VARCHAR2(20 BYTE), "NR_OPER" VARCHAR2(10 BYTE), "NR_KONTRAK" NUMBER(10,0), "IL_KONTR" NUMBER(4,0), "IL_DOL" NUMBER(6,0), "IL_GOR" NUMBER(6,0), "PODZ" NUMBER(1,0), "WSK" NUMBER(1,0), "DATA_WCZ" DATE, "CZAS_WCZ" CHAR(6 BYTE), "SZPR_DO" NUMBER(7,0), "IL_SZYB" NUMBER(7,0), "POW" NUMBER(14,4), "CZY_KSZT" NUMBER(1,0), "CZY_WSP" NUMBER(1,0), "DATA_SPED" DATE, "TYP_DOK" VARCHAR2(1 BYTE), "NR_CUTTER" NUMBER(10,0), "BLAD" NUMBER(2,0), "DATA_KLIENTA" DATE, "STR_DO_UST" NUMBER(4,0), "KONTR_DO_AKC" NUMBER(4,0), "STR_DO_AKC" NUMBER(4,0), "SZPR_DO_AKC" NUMBER(4,0), "KS_OK" NUMBER(4,0), "KONTR_DO_UST" NUMBER(4,0), "ZRODLO" NUMBER(1,0), "ILOSC_C" NUMBER(6,0), "TYP_PLIKU" NUMBER(2,0) DEFAULT 0, "PODZIAL_P" NUMBER(2,0) DEFAULT 0, "CZY_DEF_KSZT" NUMBER(1,0) DEFAULT 0, "FORMAT" NUMBER(2,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table TRA_SCHEMATAY
--------------------------------------------------------

  CREATE TABLE "TRA_SCHEMATAY" ("NUMER" NUMBER(10,0), "OPIS" VARCHAR2(100 BYTE), "FOARMAT" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table TRASY
--------------------------------------------------------

  CREATE TABLE "TRASY" ("NR_TRASY" NUMBER(10,0), "NAZ_TRASY" VARCHAR2(201 BYTE), "NIE" NUMBER(1,0), "PON" NUMBER(1,0), "WTO" NUMBER(1,0), "SRO" NUMBER(1,0), "CZW" NUMBER(1,0), "PIA" NUMBER(1,0), "SOB" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table TYP_NAZWY
--------------------------------------------------------

  CREATE TABLE "TYP_NAZWY" ("NR_TYPU" NUMBER(5,0) DEFAULT 0, "NAZWA_TYPU" VARCHAR2(50 BYTE) DEFAULT ' ', "SKLAD_OPISU" VARCHAR2(50 BYTE) DEFAULT ' ') ;
--------------------------------------------------------
--  DDL for Table TYP_OPISU
--------------------------------------------------------

  CREATE TABLE "TYP_OPISU" ("NR_TYPU" NUMBER(5,0), "NAZWA_TYPU" VARCHAR2(50 BYTE), "SKLAD_OPISU" VARCHAR2(50 BYTE)) ;
--------------------------------------------------------
--  DDL for Table TYPY_DOPLAT
--------------------------------------------------------

  CREATE TABLE "TYPY_DOPLAT" ("ID_TYPU_DOPL" NUMBER(8,0), "PRZEZNACZ" NUMBER(2,0), "OPIS_RODZ_DOPL" VARCHAR2(51 BYTE), "RODZ_OBL" NUMBER(4,0), "RODZ_PREZ" NUMBER(4,0), "WSP1" NUMBER(6,5), "WSP2" NUMBER(6,5), "RODZ_OKR" NUMBER(4,0), "ILE_JEDN_ROZL" NUMBER(4,0), "POCZ" DATE, "KONIEC" DATE, "LICZBA_GRAN" NUMBER(8,2), "ID_DOPL_FK" VARCHAR2(7 BYTE)) ;
--------------------------------------------------------
--  DDL for Table TYPY_FAKT_R
--------------------------------------------------------

  CREATE TABLE "TYPY_FAKT_R" ("KOD_TYPU" VARCHAR2(7 BYTE), "SUMA_L_E" VARCHAR2(2 BYTE), "CENY_N_B" VARCHAR2(2 BYTE), "DOKL_N" NUMBER(2,0), "IDENT_FK" VARCHAR2(7 BYTE)) ;
--------------------------------------------------------
--  DDL for Table TYPY_PLATN
--------------------------------------------------------

  CREATE TABLE "TYPY_PLATN" ("ID_TYPU_PLAT" NUMBER(6,0), "KOD_TYPU_PLAT" VARCHAR2(7 BYTE), "OPIS_TYPU_PLAT" VARCHAR2(101 BYTE), "ID_PLATN_W_FK" VARCHAR2(17 BYTE), "ILE_DNI" NUMBER(6,0)) ;
--------------------------------------------------------
--  DDL for Table TYPY_RABATOW
--------------------------------------------------------

  CREATE TABLE "TYPY_RABATOW" ("ID_TYPU_RABATU" NUMBER(8,0), "PRZEZNACZ" NUMBER(2,0), "OPIS_RODZ_RAB" VARCHAR2(51 BYTE), "RODZ_OBL" NUMBER(4,0), "RODZ_PREZ" NUMBER(4,0), "WSP1" NUMBER(6,5), "WSP2" NUMBER(6,5), "RODZ_OKR" NUMBER(4,0), "ILE_JEDN_ROZL" NUMBER(4,0), "POCZ_KONIEC" NUMBER(2,0), "NR_IDENT_RABATU_FK" VARCHAR2(7 BYTE)) ;
--------------------------------------------------------
--  DDL for Table UE_NIP
--------------------------------------------------------

  CREATE TABLE "UE_NIP" ("KRAJ" VARCHAR2(20 BYTE), "WERSJA" NUMBER(2,0), "WZORZEC" VARCHAR2(20 BYTE), "UWAGI" VARCHAR2(100 BYTE), "UNIA" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table UE_ZNAK
--------------------------------------------------------

  CREATE TABLE "UE_ZNAK" ("ZNAK" VARCHAR2(1 BYTE), "OPCJE" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table UPR_CENO
--------------------------------------------------------

  CREATE TABLE "UPR_CENO" ("NR_KOMP" NUMBER(10,0), "POZIOM_1" NUMBER(5,2), "POZIOM_2" NUMBER(5,2), "POZIOM_3" NUMBER(5,2), "POZIOM_4" NUMBER(5,2), "POZIOM_5" NUMBER(5,2), "POZIOM_6" NUMBER(5,2), "POZIOM_7" NUMBER(5,2), "POZIOM_8" NUMBER(5,2), "POZIOM_9" NUMBER(5,2), "POZIOM_10" NUMBER(5,2), "OPIS" VARCHAR2(100 BYTE), "DATA_MOD" DATE, "NR_OPER" VARCHAR2(10 BYTE)) ;
--------------------------------------------------------
--  DDL for Table VAT
--------------------------------------------------------

  CREATE TABLE "VAT" ("AXS_TPS" VARCHAR2(1 BYTE), "NR_R" VARCHAR2(1 BYTE), "LP_R" NUMBER(5,1), "BRUTTO_R" NUMBER(12,2), "NP_R" NUMBER(12,2), "ZW_R" NUMBER(12,2), "NETTO_0WR1" NUMBER(12,2), "NETTO_0R1" NUMBER(12,2), "NETTO_1R1" NUMBER(12,2), "NETTO_2R1" NUMBER(12,2), "NETTO_3R1" NUMBER(12,2), "NETTO_4R1" NUMBER(12,2), "NETTO_5R1" NUMBER(12,2), "VAT_1R1" NUMBER(12,2), "VAT_2R1" NUMBER(12,2), "VAT_3R1" NUMBER(12,2), "VAT_4R1" NUMBER(12,2), "VAT_5R1" NUMBER(12,2), "NETTO_0WR2" NUMBER(12,2), "NETTO_0R2" NUMBER(12,2), "NETTO_1R2" NUMBER(12,2), "NETTO_2R2" NUMBER(12,2), "NETTO_3R2" NUMBER(12,2), "NETTO_4R2" NUMBER(12,2), "NETTO_5R2" NUMBER(12,2), "VAT_1R2" NUMBER(12,2), "VAT_2R2" NUMBER(12,2), "VAT_3R2" NUMBER(12,2), "VAT_4R2" NUMBER(12,2), "VAT_5R2" NUMBER(12,2), "SYMB_DOK" VARCHAR2(8 BYTE), "ODN" NUMBER(5,1), "DON" NUMBER(5,1), "DATA_S" DATE, "DATA_F" DATE, "DATA_PLAT" DATE, "NR_FAK_R" VARCHAR2(14 BYTE), "KONTO_U" VARCHAR2(3 BYTE), "NR_KTH_R" VARCHAR2(13 BYTE), "KOMENT" VARCHAR2(30 BYTE), "DATA_OB" VARCHAR2(2 BYTE), "MIES_DOK" VARCHAR2(2 BYTE), "SYMB_PKS" VARCHAR2(8 BYTE), "PRZEKS_OB" VARCHAR2(7 BYTE), "IN_MASTER" NUMBER(1,0), "PLATNOSC" VARCHAR2(3 BYTE), "KH_NIP" VARCHAR2(13 BYTE), "KH_ADRES_1" VARCHAR2(30 BYTE), "KH_ADRES_2" VARCHAR2(30 BYTE), "KH_ADRES_3" VARCHAR2(30 BYTE), "KH_ADRES_4" VARCHAR2(30 BYTE), "KH_ADRES_5" VARCHAR2(30 BYTE), "BL_SALDA" NUMBER(1,0), "PAR_FISK" NUMBER(1,0), "KWOTA_WAL" NUMBER(12,2), "WALUTA" VARCHAR2(1 BYTE), "PLATNIK" VARCHAR2(6 BYTE), "EDYTOWANY" NUMBER(1,0), "ZOBOWIAZ" NUMBER(10,2), "TRANSPORT" NUMBER(10,2), "CLO" NUMBER(10,2), "PODATEK" NUMBER(10,2), "AKCYZA" NUMBER(10,2), "KOSZTY" NUMBER(10,2), "MAGAZYN" VARCHAR2(8 BYTE), "ZNACZNIK" VARCHAR2(4 BYTE)) ;
--------------------------------------------------------
--  DDL for Table WALUTA
--------------------------------------------------------

  CREATE TABLE "WALUTA" ("WALUTA" CHAR(4 BYTE), "KURS_NBP" NUMBER(15,5), "KURS_SREDNI" NUMBER(15,5), "INNY" NUMBER(15,5), "NR_TABELI" VARCHAR2(20 BYTE), "DATA_TABELI" DATE, "PRZELICZNIK" NUMBER(5,1) DEFAULT 1) ;
--------------------------------------------------------
--  DDL for Table WARUNKI
--------------------------------------------------------

  CREATE TABLE "WARUNKI" ("TYP" NUMBER(3,0), "TABELA" VARCHAR2(30 BYTE), "NR_POLA" NUMBER(3,0), "NAZ_POLA" VARCHAR2(30 BYTE), "WSK" NUMBER(1,0), "WSK_OB" NUMBER(1,0), "NAZ_POL_DB" VARCHAR2(30 BYTE), "TAB_DB" VARCHAR2(30 BYTE), "NAZ_POLA1_DB" VARCHAR2(30 BYTE), "TAB11_DB" VARCHAR2(30 BYTE)) ;
--------------------------------------------------------
--  DDL for Table WIEK_DLUG
--------------------------------------------------------

  CREATE TABLE "WIEK_DLUG" ("NAZWA" VARCHAR2(10 BYTE), "CZY" NUMBER(1,0), "KWOTA" NUMBER(16,0), "OPIS" VARCHAR2(50 BYTE), "POZ_WYM" NUMBER(1,0), "NUMER" NUMBER(1,0), "OD" NUMBER(4,0) DEFAULT 0, "DO" NUMBER(4,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table WNIOSKI_OBS
--------------------------------------------------------

  CREATE TABLE "WNIOSKI_OBS" ("NR_WNIOSKU" NUMBER(10,0), "NR_ODDZ" NUMBER(2,0), "D_WNIOSKU" DATE, "D_AKCEPT" DATE, "STAN" NUMBER(1,0), "NR_KONTRAH" NUMBER(10,0), "NR_OS_WN" NUMBER(10,0), "NAZ_OS_WN" VARCHAR2(50 BYTE), "NR_OS_POP" NUMBER(10,0), "NAZ_OS_POP" VARCHAR2(50 BYTE), "NR_OS_AKT" NUMBER(10,0), "NAZ_OS_AKT" VARCHAR2(50 BYTE), "NR_OS_AUT" NUMBER(10,0), "NAZ_OS_AUT" VARCHAR2(50 BYTE), "UZASAD" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table WOJEWODZTWA
--------------------------------------------------------

  CREATE TABLE "WOJEWODZTWA" ("NUMER" NUMBER(2,0), "WOJ" VARCHAR2(20 BYTE)) ;
--------------------------------------------------------
--  DDL for Table WSPINST
--------------------------------------------------------

  CREATE TABLE "WSPINST" ("NR_KOMP_INST" NUMBER(10,0), "NR_ZNACZNIKA" NUMBER(3,0), "ZN_PROD" CHAR(4 BYTE), "ZNAK_OP1" CHAR(1 BYTE), "WSP_PRZEL1" NUMBER(7,4), "ZNAK_OP2" CHAR(1 BYTE), "WSP_PRZEL2" NUMBER(7,4), "ZNAK_OP3" CHAR(1 BYTE), "WSP_PRZEL3" NUMBER(7,4), "ZNAK_OP4" CHAR(1 BYTE), "WSP_PRZEL4" NUMBER(7,4)) ;
--------------------------------------------------------
--  DDL for Table WSP_OBR
--------------------------------------------------------

  CREATE TABLE "WSP_OBR" ("TYP_WSP" NUMBER(1,0), "NR_KOMP_OBR" NUMBER(10,0), "SYMB" VARCHAR2(40 BYTE), "TYP_KAT_SZKLA" VARCHAR2(9 BYTE), "NR_KOMP_INST" NUMBER(10,0), "WSP" NUMBER(6,3), "AKT" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table WSP_ROB
--------------------------------------------------------

  CREATE TABLE "WSP_ROB" ("NR_INST" NUMBER(10,0), "ZN_PROD" VARCHAR2(4 BYTE), "ZNAK_OP1" VARCHAR2(1 BYTE), "WSP_PRZEL1" NUMBER(7,4), "ZNAK_OP2" VARCHAR2(1 BYTE), "WSP_PRZEL2" NUMBER(7,4), "ZNAK_OP3" VARCHAR2(1 BYTE), "WSP_PRZEL3" NUMBER(7,4), "ZNAK_OP4" VARCHAR2(1 BYTE), "WSP_PRZEL4" NUMBER(7,4), "DO_WYDRUKU" VARCHAR2(20 BYTE), "MODY" NUMBER(1,0) DEFAULT 0, "WIDOCZNY" NUMBER(1,0) DEFAULT 1) ;
--------------------------------------------------------
--  DDL for Table WSPSTAND
--------------------------------------------------------

  CREATE TABLE "WSPSTAND" ("NR_INST" NUMBER(10,0), "ZN_PROD" VARCHAR2(4 BYTE), "ZNAK_OP1" VARCHAR2(1 BYTE), "WSP_PRZEL1" NUMBER(7,4), "ZNAK_OP2" VARCHAR2(1 BYTE), "WSP_PRZEL2" NUMBER(7,4), "ZNAK_OP3" VARCHAR2(1 BYTE), "WSP_PRZEL3" NUMBER(7,4), "ZNAK_OP4" VARCHAR2(1 BYTE), "WSP_PRZEL4" NUMBER(7,4), "DO_WYDRUKU" VARCHAR2(20 BYTE), "MODY" NUMBER(1,0) DEFAULT 0, "WIDOCZNY" NUMBER(1,0) DEFAULT 1) ;
--------------------------------------------------------
--  DDL for Table WYCINKI
--------------------------------------------------------

  CREATE TABLE "WYCINKI" ("NR_KOMP_ZLEC" NUMBER(10,0) DEFAULT 0, "NR_POZ" NUMBER(10,0) DEFAULT 0, "NR_SZT" NUMBER(10,0) DEFAULT 0, "NR_WAR" NUMBER(2,0) DEFAULT 0, "KARTOTEKA" VARCHAR2(128 BYTE) DEFAULT ' ', "ID_TAF" NUMBER(10,0) DEFAULT 0, "D_WYK" DATE DEFAULT to_date('01/1901','MM/YYYY'), "ZM_WYK" NUMBER(1,0) DEFAULT 0, "NR_ZM_WYK" NUMBER(10,0) DEFAULT 0, "CREATED" DATE DEFAULT to_date('01/1901','MM/YYYY'), "MODIFIED" DATE DEFAULT to_date('01/1901','MM/YYYY'), "CZY_ODPAD" NUMBER(1,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table WYKZAL
--------------------------------------------------------

  CREATE TABLE "WYKZAL" ("NR_KOMP_ZLEC" NUMBER(10,0), "NR_KOMP_INSTAL" NUMBER(10,0), "NR_KOMP_ZM" NUMBER(10,0), "NR_POZ" NUMBER(3,0), "IL_WYK" NUMBER(14,0), "NR_OPER" VARCHAR2(10 BYTE), "INDEKS" VARCHAR2(128 BYTE), "IL_ZLEC_WYK" NUMBER(14,6), "D_WYK" DATE, "ZM_WYK" NUMBER(1,0), "FLAG" NUMBER(1,0), "D_PLAN" DATE, "ZM_PLAN" NUMBER(1,0), "NR_ZM_PLAN" NUMBER(10,0), "WSP_PRZEL" NUMBER(7,4), "IL_PLAN" NUMBER(14,0), "IL_ZLEC_PLAN" NUMBER(14,6), "IL_CALK" NUMBER(14,0), "IL_JEDN" NUMBER(14,6), "STRATY" NUMBER(13,3) DEFAULT 0, "NR_KOMP_OBR" NUMBER(10,0) DEFAULT 0, "KOD_DOD" VARCHAR2(128 BYTE) DEFAULT '', "NR_WARST" NUMBER(3,0) DEFAULT 0, "NR_KOMP_GR" NUMBER(10,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table WYM_SER
--------------------------------------------------------

  CREATE TABLE "WYM_SER" ("NR_KOMP" NUMBER(10,0), "NR_GLOWNY" NUMBER(4,0), "NR_WYM" NUMBER(4,0), "SZER" NUMBER(4,0), "WYS" NUMBER(4,0), "INDEKS" VARCHAR2(128 BYTE), "NR_IND" NUMBER(10,0), "POW" NUMBER(14,4) DEFAULT 0, "IND_FK" VARCHAR2(12 BYTE) DEFAULT '', "IND_FABR" VARCHAR2(5 BYTE) DEFAULT '', "IND_UE" VARCHAR2(5 BYTE) DEFAULT '', "OPIS" VARCHAR2(100 BYTE) DEFAULT '', "FOLIA" VARCHAR2(3 BYTE) DEFAULT '', "CZY_KSZT" NUMBER(1,0) DEFAULT 0, "CZY_SIT" NUMBER(1,0) DEFAULT 0, "NR_RYS" NUMBER(10,0) DEFAULT 0, "NR_SITA" NUMBER(10,0) DEFAULT 0, "NR_FORMY" NUMBER(10,0) DEFAULT 0, "SZER_FOL" NUMBER(4,0) DEFAULT 0, "SZER_C" NUMBER(4,0) DEFAULT 0, "WYS_C" NUMBER(4,0) DEFAULT 0, "LATA_PROD" VARCHAR2(15 BYTE) DEFAULT '', "IND_SCAN" VARCHAR2(5 BYTE) DEFAULT '', "OPIS_SZK" VARCHAR2(30 BYTE) DEFAULT '', "SZKLO1" VARCHAR2(128 BYTE) DEFAULT '', "SZKLO2" VARCHAR2(128 BYTE) DEFAULT '', "KART_FOL" VARCHAR2(128 BYTE) DEFAULT '', "IND_NAGS" VARCHAR2(10 BYTE) DEFAULT '', "ETYK" VARCHAR2(20 BYTE) DEFAULT '', "IND_DOD" VARCHAR2(20 BYTE) DEFAULT '') ;
--------------------------------------------------------
--  DDL for Table WYROBY_O
--------------------------------------------------------

  CREATE TABLE "WYROBY_O" ("NR_KOMP" NUMBER(10,0), "INDEKS" VARCHAR2(50 BYTE), "C_REALOK" NUMBER(14,4), "C_SPRZED" NUMBER(14,4), "C_ZA_SZT" NUMBER(14,4), "C_BAZ" NUMBER(14,4), "WSKAZ" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Table WZORCE_R
--------------------------------------------------------

  CREATE TABLE "WZORCE_R" ("RODZAJ" NUMBER(2,0), "WERSJA" NUMBER(2,0), "WZORZEC" VARCHAR2(30 BYTE), "UWAGI" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table WZORCE_Z
--------------------------------------------------------

  CREATE TABLE "WZORCE_Z" ("RODZAJ" NUMBER(2,0), "TYP" NUMBER(1,0), "ZNAK" VARCHAR2(1 BYTE), "OPERACJA" VARCHAR2(2 BYTE), "OPCJE" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table WZORDRUK
--------------------------------------------------------

  CREATE TABLE "WZORDRUK" ("NR_NAP" NUMBER(3,0), "NR_WZOR" NUMBER(3,0), "NAPIS" VARCHAR2(200 BYTE)) ;
--------------------------------------------------------
--  DDL for Table WZORNAL
--------------------------------------------------------

  CREATE TABLE "WZORNAL" ("NR_WZORU" NUMBER(10,0), "NR_LINII" NUMBER(4,0), "LINIA" VARCHAR2(255 BYTE)) ;
--------------------------------------------------------
--  DDL for Table ZAK_UPR
--------------------------------------------------------

  CREATE TABLE "ZAK_UPR" ("RODZAJ" NUMBER(2,0), "NAZ_SPEC" VARCHAR2(40 BYTE), "KWOTA" NUMBER(16,0), "ZAP1" VARCHAR2(31 BYTE), "ZAP2" VARCHAR2(31 BYTE), "ZAP3" VARCHAR2(31 BYTE), "AUT1" VARCHAR2(31 BYTE), "AUT2" VARCHAR2(31 BYTE), "AUT3" VARCHAR2(31 BYTE), "OPIS" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table ZAMINFO
--------------------------------------------------------

  CREATE TABLE "ZAMINFO" ("NR_KOMP_ZLEC" NUMBER(10,0), "NUMER_ODDZIALU" NUMBER(2,0), "NR_KOMP_INSTAL" NUMBER(10,0), "IL_PL_SZYB" NUMBER(10,0), "IL_PL_WYC" NUMBER(10,0), "DANE_RZECZ" NUMBER(13,3), "DANE_PRZEL" NUMBER(13,3), "ATRB_1_IL" NUMBER(10,0), "ATRB_1_P" NUMBER(13,3), "ATRB_2_IL" NUMBER(10,0), "ATRB_2_P" NUMBER(13,3), "ATRB_3_IL" NUMBER(10,0), "ATRB_3_P" NUMBER(13,3), "ATRB_4_IL" NUMBER(10,0), "ATRB_4_P" NUMBER(13,3), "ATRB_5_IL" NUMBER(10,0), "ATRB_5_P" NUMBER(13,3), "ATRB_6_IL" NUMBER(10,0), "ATRB_6_P" NUMBER(13,3), "ATRB_7_IL" NUMBER(10,0), "ATRB_7_P" NUMBER(13,3), "ATRB_8_IL" NUMBER(10,0), "ATRB_8_P" NUMBER(13,3), "ATRB_9_IL" NUMBER(10,0), "ATRB_9_P" NUMBER(13,3), "ATRB_10_IL" NUMBER(10,0), "ATRB_10_P" NUMBER(13,3), "ATRB_11_IL" NUMBER(10,0), "ATRB_11_P" NUMBER(13,3), "ATRB_12_IL" NUMBER(10,0), "ATRB_12_P" NUMBER(13,3), "ATRB_13_IL" NUMBER(10,0), "ATRB_13_P" NUMBER(13,3), "ATRB_14_IL" NUMBER(10,0), "ATRB_14_P" NUMBER(13,3), "ATRB_15_IL" NUMBER(10,0), "ATRB_15_P" NUMBER(13,3), "ATRB_16_IL" NUMBER(10,0), "ATRB_16_P" NUMBER(13,3), "ATRB_17_IL" NUMBER(10,0), "ATRB_17_P" NUMBER(13,3), "ATRB_18_IL" NUMBER(10,0), "ATRB_18_P" NUMBER(13,3), "ATRB_19_IL" NUMBER(10,0), "ATRB_19_P" NUMBER(13,3), "ATRB_20_IL" NUMBER(10,0), "ATRB_20_P" NUMBER(13,3), "ATRYBUTY_BUDOWY" NUMBER(18,0), "ATRB_21_IL" NUMBER(10,0) DEFAULT 0, "ATRB_21_P" NUMBER(10,3) DEFAULT 0, "ATRB_22_IL" NUMBER(10,0) DEFAULT 0, "ATRB_22_P" NUMBER(10,3) DEFAULT 0, "ATRB_23_IL" NUMBER(10,0) DEFAULT 0, "ATRB_23_P" NUMBER(10,3) DEFAULT 0, "ATRB_24_IL" NUMBER(10,0) DEFAULT 0, "ATRB_24_P" NUMBER(10,3) DEFAULT 0, "ATRB_25_IL" NUMBER(10,0) DEFAULT 0, "ATRB_25_P" NUMBER(10,3) DEFAULT 0, "ATRB_26_IL" NUMBER(10,0) DEFAULT 0, "ATRB_26_P" NUMBER(10,3) DEFAULT 0, "ATRB_27_IL" NUMBER(10,0) DEFAULT 0, "ATRB_27_P" NUMBER(10,3) DEFAULT 0, "ATRB_28_IL" NUMBER(10,0) DEFAULT 0, "ATRB_28_P" NUMBER(10,3) DEFAULT 0, "ATRB_29_IL" NUMBER(10,0) DEFAULT 0, "ATRB_29_P" NUMBER(10,3) DEFAULT 0, "ATRB_30_IL" NUMBER(10,0) DEFAULT 0, "ATRB_30_P" NUMBER(10,3) DEFAULT 0, "SZER_MIN" NUMBER(4,0) DEFAULT 0, "WYS_MIN" NUMBER(4,0) DEFAULT 0, "SZER_MAX" NUMBER(4,0) DEFAULT 0, "WYS_MAX" NUMBER(4,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table ZAMKZLEC
--------------------------------------------------------

  CREATE TABLE "ZAMKZLEC" ("NR_KOMP_ZLEC" NUMBER(10,0), "PFLAG_R" NUMBER(10,0), "D_ZAMK" DATE, "C_ZAMK" CHAR(6 BYTE), "NR_OPT" VARCHAR2(10 BYTE), "KOMENTARZ" VARCHAR2(200 BYTE)) ;
--------------------------------------------------------
--  DDL for Table ZAMOW
--------------------------------------------------------

  CREATE TABLE "ZAMOW" ("NR_KOM_ZLEC" NUMBER(10,0), "GR_DOK" CHAR(3 BYTE), "NR_ZLEC" NUMBER(6,0), "NR_ZLEC_KLI" CHAR(18 BYTE), "NR_KON" NUMBER(10,0), "DATA_ZL" DATE, "POZ_CEN" NUMBER(2,0), "D_POCZ_PROD" DATE, "D_ZAK_PROD" DATE, "D_PLAN" DATE, "D_WYS" DATE, "NR_ADR_DOST" NUMBER(10,0), "NR_KONTRAKTU" NUMBER(10,0), "WART_ZLEC" NUMBER(12,2), "WART_SUR" NUMBER(12,2), "WART_DO_UB" NUMBER(12,2), "WART_USL" NUMBER(12,2), "WART_PW" NUMBER(12,2), "IL_POZ" NUMBER(3,0), "KOM_POCZ" NUMBER(10,0), "KOM_KON" NUMBER(10,0), "NR_OP_WPR" VARCHAR2(10 BYTE), "NR_OP_MOD" VARCHAR2(10 BYTE), "TYP_ZLEC" CHAR(3 BYTE), "PRIORYTET" NUMBER(2,0), "WYROZNIK" CHAR(1 BYTE), "FLAG_R" NUMBER(10,0), "NR_ODDZ" NUMBER(2,0), "ROK" NUMBER(4,0), "MIES" NUMBER(2,0), "D_PL_SPED" DATE, "D_SPED_KL" DATE, "NR_ZLEC_WEWN" VARCHAR2(18 BYTE), "FORMA_WPROW" VARCHAR2(1 BYTE), "STATUS" VARCHAR2(1 BYTE), "DO_PRODUKCJI" NUMBER(1,0), "OP_ZATW" VARCHAR2(10 BYTE), "IL_CIET" NUMBER(14,0), "I_KOM" NUMBER(14,0), "II_KOM" NUMBER(14,0), "IL_STRUKT" NUMBER(14,0), "POW_C" NUMBER(18,6), "POW_I" NUMBER(18,6), "POW_II" NUMBER(18,6), "POW_S" NUMBER(18,6), "POWOD" VARCHAR2(30 BYTE), "WALUTA" VARCHAR2(4 BYTE), "KURS" NUMBER(14,4), "IL_SCH" NUMBER(14,0), "POW_SCH" NUMBER(18,6), "ZN" NUMBER(4,0), "NR_KOMP_POPRZ" NUMBER(10,0), "WSK_POLP" NUMBER(5,0), "IL_ZATW" NUMBER(10,0), "NR_SZARZY" NUMBER(6,0), "NR_PAKIETU" NUMBER(6,0), "TRYB_WPR" NUMBER(2,0), "SORT" VARCHAR2(9 BYTE), "RODZAJ" NUMBER(1,0), "R_DAN" NUMBER(2,0) DEFAULT 0, "NR_KOMP_ROKP" NUMBER(10,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table ZAM_UWAGI
--------------------------------------------------------

  CREATE TABLE "ZAM_UWAGI" ("NUMER_KOMPUTEROWY" NUMBER(10,0), "PEL_NAZ" VARCHAR2(200 BYTE)) ;
--------------------------------------------------------
--  DDL for Table ZLEC_DOPLATY
--------------------------------------------------------

  CREATE TABLE "ZLEC_DOPLATY" ("NK_ZLEC" NUMBER(10,0), "IDENT_POZ" NUMBER(10,0), "RODZAJ" NUMBER(2,0), "WARTOSC" NUMBER(5,2)) ;
--------------------------------------------------------
--  DDL for Table ZLECENIA_ANAL_KOSZT
--------------------------------------------------------

  CREATE TABLE "ZLECENIA_ANAL_KOSZT" ("NR_ZLEC" NUMBER(10,0), "NR_STRUKT" NUMBER(10,0), "GR_KOSZT_WYR" NUMBER(10,0), "NR_KATAL_SUR" NUMBER(10,0), "GR_KOSZT_SUR" NUMBER(10,0), "ILOSC_SZTUK" NUMBER(8,0), "SZTUK_W_OKR" NUMBER(8,0), "ILOSC_WYROBU" NUMBER(18,6), "ILOSC_SUROWCA" NUMBER(18,6), "WYDANE_W_OKR" NUMBER(18,6), "UDZIAL_W__SUR" NUMBER(18,6), "UDZIAL_W_PROD" NUMBER(18,6), "NA_RW_W_OK" NUMBER(18,6), "POMOCN" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table ZLEC_ODBL
--------------------------------------------------------

  CREATE TABLE "ZLEC_ODBL" ("NKP_ZLEC" NUMBER(10,0), "NR_ZLEC" NUMBER(10,0), "NK_KONTR" NUMBER(10,0), "DATA" DATE, "NK_OP" NUMBER(10,0), "ODD" NUMBER(2,0)) ;
--------------------------------------------------------
--  DDL for Table ZLEC_PAM
--------------------------------------------------------

  CREATE TABLE "ZLEC_PAM" ("NK_ZLEC" NUMBER(10,0), "NR_ZLEC" NUMBER(10,0), "FUN" NUMBER(2,0), "NK_OPER" NUMBER(10,0), "DATA" DATE, "CZAS" CHAR(6 BYTE)) ;
--------------------------------------------------------
--  DDL for Table ZLEC_POLP
--------------------------------------------------------

  CREATE TABLE "ZLEC_POLP" ("NR_KOMP_ZLEC" NUMBER(10,0), "NR_POZ_ZLEC" NUMBER(3,0), "NR_WARSTWY" NUMBER(2,0), "NR_STRUKT" NUMBER(10,0), "NR_KATAL" NUMBER(4,0), "WSK" NUMBER(1,0), "TYP" VARCHAR2(1 BYTE), "NR_ZLEC_WEW" NUMBER(10,0), "IDENT_POZ" NUMBER(10,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table ZLEC_POLP1
--------------------------------------------------------

  CREATE TABLE "ZLEC_POLP1" ("NR_KOMP_ZLEC" NUMBER(10,0), "NR_POZ_ZLEC" NUMBER(3,0), "NR_WARSTWY" NUMBER(2,0), "NR_SKLAD" NUMBER(2,0), "SKLADNIK" NUMBER(10,0), "ZN_WARSTWY" VARCHAR2(3 BYTE), "INDEKS" VARCHAR2(50 BYTE), "WSK" NUMBER(1,0), "TYP" VARCHAR2(1 BYTE), "NR_ZLEC_WEW" NUMBER(10,0), "OPIS" VARCHAR2(100 BYTE), "IDENT_POZ" NUMBER(10,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table ZLEC_SZP
--------------------------------------------------------

  CREATE TABLE "ZLEC_SZP" ("NR_ZLEC" NUMBER(6,0), "NKOMP_ZLEC" NUMBER(10,0), "POZ_ZLEC" NUMBER(3,0), "NR_WAR" NUMBER(3,0), "DANE" VARCHAR2(2000 BYTE), "R3" NUMBER(4,0), "T4" NUMBER(4,0), "MATSZP1" VARCHAR2(128 BYTE), "MATSZP2" VARCHAR2(128 BYTE), "NR_WZS" NUMBER(4,0), "IL_PAR" NUMBER(4,0), "MARG" NUMBER(4,0), "IDENT_SZP" NUMBER(3,0), "PODZIAL" NUMBER(1,0) DEFAULT 0, "IDENT_POZ" NUMBER(10,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table ZLEC_TYP
--------------------------------------------------------

  CREATE TABLE "ZLEC_TYP" ("NR_KOMP_ZLEC" NUMBER(10,0), "NR_POZ" NUMBER(3,0), "TYP" NUMBER(3,0), "LINIA" VARCHAR2(500 BYTE), "IDENT_POZ" NUMBER(10,0) DEFAULT 0) ;
--------------------------------------------------------
--  DDL for Table ZLEC_UWAGI
--------------------------------------------------------

  CREATE TABLE "ZLEC_UWAGI" ("NUMER_KOMPUTEROWY" NUMBER(10,0), "PEL_NAZ" VARCHAR2(500 BYTE) DEFAULT '', "UW_SPED" VARCHAR2(200 BYTE) DEFAULT '', "UW_HANDL" VARCHAR2(200 BYTE) DEFAULT '', "UW_Z_PROD" VARCHAR2(200 BYTE) DEFAULT '', "UWAGI_PP" VARCHAR2(200 BYTE) DEFAULT '', "UWAGI_DLA_DPP" VARCHAR2(500 BYTE) DEFAULT '') ;
--------------------------------------------------------
--  DDL for Table ZLEC_ZM
--------------------------------------------------------

  CREATE TABLE "ZLEC_ZM" ("NK_ZM" NUMBER(10,0), "NK_ZLEC" NUMBER(10,0), "NR_ZLEC" NUMBER(10,0), "DATA" DATE, "CZAS" CHAR(6 BYTE), "OPER" NUMBER(10,0), "TYP" VARCHAR2(2 BYTE), "OPIS" VARCHAR2(50 BYTE)) ;
--------------------------------------------------------
--  DDL for Table ZLEC_ZMP
--------------------------------------------------------

  CREATE TABLE "ZLEC_ZMP" ("NR_ZAPISU" NUMBER(10,0), "NR_ZMIANY" NUMBER(10,0), "TABELA_NR" NUMBER(4,0), "POLE_NR" NUMBER(4,0), "WARTOSC_PRZED" VARCHAR2(100 BYTE), "WARTOSC_PO" VARCHAR2(100 BYTE), "TRYB_ZMIANY" VARCHAR2(2 BYTE), "IDENT1" NUMBER(10,0), "IDENT2" NUMBER(10,0), "IDENT3" NUMBER(10,0), "IDENT4" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table ZLEC_ZMS
--------------------------------------------------------

  CREATE TABLE "ZLEC_ZMS" ("TABELA" VARCHAR2(32 BYTE), "POLE" VARCHAR2(32 BYTE), "WSK" NUMBER(1,0), "NR_POLA" NUMBER(4,0), "NR_TAB" NUMBER(4,0), "POLE_NAZ" VARCHAR2(32 BYTE), "RODZAJ" NUMBER(2,0), "WSK_ZOBACZ" NUMBER(1,0), "DYMEK" VARCHAR2(100 BYTE)) ;
--------------------------------------------------------
--  DDL for Table ZMCNV111
--------------------------------------------------------

  CREATE TABLE "ZMCNV111" ("LP_114" NUMBER(10,0), "INDEKS_WYR" VARCHAR2(128 BYTE), "NR_KON" NUMBER(10,0), "SKROT_KON" VARCHAR2(15 BYTE), "NR_SPRZED" NUMBER(10,0), "POZ_SPRZED" NUMBER(10,0), "ILOSC" NUMBER(14,4), "KOSZT_JEDN" NUMBER(14,4), "KOSZT_PROD_RZ" NUMBER(16,2), "CENA_NETSPRZED" NUMBER(14,4), "WARTOSC_NETSPRZED" NUMBER(14,2), "ZYSK" NUMBER(10,2), "TYP_ZLECENIA" VARCHAR2(3 BYTE), "MM" NUMBER(12,2), "NR_KOMP_ZLEC" NUMBER(10,0), "NR_FAKTURY" NUMBER(10,0), "WART_FAKT_NETTO" NUMBER(14,2), "DATA" DATE, "TYP_FAKTURY" CHAR(3 BYTE), "ZNACZNIK" VARCHAR2(3 BYTE), "MAGAZYN" NUMBER(3,0), "CENA_WYK_STD" NUMBER(14,4), "KOSZT_WYKON_STD" NUMBER(14,2), "ZYSK_STAND" NUMBER(14,2), "NR_GR_KOSZT_WYR" NUMBER(10,0), "SKR_TYP_FAKT" VARCHAR2(2 BYTE), "CZY_TO_PZ" NUMBER(1,0), "NR_NALICZ" NUMBER(10,0)) ;
--------------------------------------------------------
--  DDL for Table ZMIANY
--------------------------------------------------------

  CREATE TABLE "ZMIANY" ("NR_KOMP_INST" NUMBER(10,0), "DZIEN" DATE, "ZMIANA" NUMBER(1,0), "WIELK_PLAN" NUMBER(14,2), "IL_PLAN" NUMBER(14,0), "WIELK_WYK" NUMBER(14,2), "IL_WYK" NUMBER(14,0), "DL_ZMIANY" NUMBER(2,0), "BRYGADA" VARCHAR2(10 BYTE), "NR_KOMP_ZM" NUMBER(10,0), "ZATWIERDZ" NUMBER(1,0) DEFAULT 0, "NR_KOMP_BRYG" NUMBER(10,0) DEFAULT 0, "ILOSOB" NUMBER(5,0) DEFAULT 0, "GODZ_WOLNA" CHAR(6 BYTE), "KOL_WOLNA" NUMBER(5,0) DEFAULT 0, "AKT_W_WIZ" NUMBER(1,0) DEFAULT 1) ;
--------------------------------------------------------
--  DDL for Table ZNAKI
--------------------------------------------------------

  CREATE TABLE "ZNAKI" ("ZNAK" VARCHAR2(1 BYTE)) ;
--------------------------------------------------------
--  DDL for Table ZZSLOW
--------------------------------------------------------

  CREATE TABLE "ZZSLOW" ("NR_KOMP" NUMBER(10,0), "GRUPA" NUMBER(3,0), "NR_W_GRUPIE" NUMBER(5,0), "TEKST" VARCHAR2(160 BYTE), "DOMYSLNA" NUMBER(1,0)) ;
--------------------------------------------------------
--  DDL for Sequence BRAKI_B_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  "BRAKI_B_SEQ"  MINVALUE 1 MAXVALUE 9999999999 INCREMENT BY 1 START WITH 6233 NOCACHE  NOORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Sequence BUF_SEQ_ID
--------------------------------------------------------

   CREATE SEQUENCE  "BUF_SEQ_ID"  MINVALUE 99 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 3701 CACHE 20 NOORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Sequence LWYC_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  "LWYC_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 26611860 CACHE 20 NOORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Sequence MK_SEQ_ID
--------------------------------------------------------

   CREATE SEQUENCE  "MK_SEQ_ID"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1573100 CACHE 20 NOORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Sequence NK_LOGT
--------------------------------------------------------

   CREATE SEQUENCE  "NK_LOGT"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 7000 CACHE 20 NOORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Sequence SEQ_ID_ODP
--------------------------------------------------------

   CREATE SEQUENCE  "SEQ_ID_ODP"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 2086000 CACHE 20 NOORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Sequence SQL_HIST_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  "SQL_HIST_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 140 CACHE 20 NOORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Sequence TAFLA_ID_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  "TAFLA_ID_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 100 CACHE 20 NOORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Index DLA_PROD
--------------------------------------------------------

  CREATE INDEX "DLA_PROD" ON "SURZAM" ("TYP_ZLEC", "NR_ZLEC", "NR_KOMP_INST") ;
--------------------------------------------------------
--  DDL for Index DOKUMENT529
--------------------------------------------------------

  CREATE INDEX "DOKUMENT529" ON "NOTA" ("ZNACZNIK", "TYP_DOK", "NKOMP_DOK") ;
--------------------------------------------------------
--  DDL for Index ECUTTER_MESSAGEUSERS
--------------------------------------------------------

  CREATE UNIQUE INDEX "ECUTTER_MESSAGEUSERS" ON "ECUTTER_MESSAGEUSERS" ("NR_KOMP_WIAD", "NR_KOMP_KL") ;
--------------------------------------------------------
--  DDL for Index ECUTTER_NAGRODYUSERS
--------------------------------------------------------

  CREATE INDEX "ECUTTER_NAGRODYUSERS" ON "ECUTTER_NAGRODYUSERS" ("NR_KON", "NR_NAGRODY") ;
--------------------------------------------------------
--  DDL for Index ECUTTER_NAGRODY_WGNRKOMP
--------------------------------------------------------

  CREATE UNIQUE INDEX "ECUTTER_NAGRODY_WGNRKOMP" ON "ECUTTER_NAGRODY" ("NR_KOMP") ;
--------------------------------------------------------
--  DDL for Index ECUTTER_ORDERS_WGNRKOMP
--------------------------------------------------------

  CREATE UNIQUE INDEX "ECUTTER_ORDERS_WGNRKOMP" ON "ECUTTER_ORDERS" ("NR_KOMP_ZLEC") ;
--------------------------------------------------------
--  DDL for Index ECUTTER_POSITIONS_WGNRKOMP
--------------------------------------------------------

  CREATE UNIQUE INDEX "ECUTTER_POSITIONS_WGNRKOMP" ON "ECUTTER_POSITIONS" ("NR_KOMP_ZLEC", "NR_POZ") ;
--------------------------------------------------------
--  DDL for Index ECUTTER_PUNKTY_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "ECUTTER_PUNKTY_PK" ON "ECUTTER_PUNKTY" ("NR_KON", "ROK") ;
--------------------------------------------------------
--  DDL for Index ECUTTER_STRUCTURES_UNIQUE
--------------------------------------------------------

  CREATE UNIQUE INDEX "ECUTTER_STRUCTURES_UNIQUE" ON "ECUTTER_STRUCTURES" ("NR_KON", "STRUKTURA") ;
--------------------------------------------------------
--  DDL for Index EG_ZLECZ587
--------------------------------------------------------

  CREATE UNIQUE INDEX "EG_ZLECZ587" ON "RYSUNKI" ("NK_ZLEC", "NR_WARST", "NK_RYS") ;
--------------------------------------------------------
--  DDL for Index EG_ZLECZ587R
--------------------------------------------------------

  CREATE INDEX "EG_ZLECZ587R" ON "RRYSUNKI" ("NK_ZLEC", "NR_WARST", "NK_RYS") ;
--------------------------------------------------------
--  DDL for Index GW_KATALOGU729A_37
--------------------------------------------------------

  CREATE UNIQUE INDEX "GW_KATALOGU729A_37" ON "CEN05" ("NKOMP_CEN", "NKOMP_OBR", "GRUB") ;
--------------------------------------------------------
--  DDL for Index GW_KATALOGU729O
--------------------------------------------------------

  CREATE UNIQUE INDEX "GW_KATALOGU729O" ON "CEN02_FGT" ("NKOMP_CEN", "NKOMP_OBR", "GRUB") ;
--------------------------------------------------------
--  DDL for Index GW_KATALOGU733
--------------------------------------------------------

  CREATE UNIQUE INDEX "GW_KATALOGU733" ON "CEN02" ("NK_CENNIKA", "TYP", "NR_KAT", "NR_SZYBY") ;
--------------------------------------------------------
--  DDL for Index GW_KATALOGU_CEN02_T7
--------------------------------------------------------

  CREATE UNIQUE INDEX "GW_KATALOGU_CEN02_T7" ON "CEN02_T7" ("NKOMP_CEN", "NKOMP_OBR", "GRUB") ;
--------------------------------------------------------
--  DDL for Index ID_FAKT_POZ60
--------------------------------------------------------

  CREATE INDEX "ID_FAKT_POZ60" ON "FAKPOZ_B" ("ID_FAKT", "NR_POZ") ;
--------------------------------------------------------
--  DDL for Index ID_JAA_POZ60
--------------------------------------------------------

  CREATE INDEX "ID_JAA_POZ60" ON "FAKPOZ_B" ("ID_FAKT", "ID_POZ") ;
--------------------------------------------------------
--  DDL for Index ID_POZ60
--------------------------------------------------------

  CREATE UNIQUE INDEX "ID_POZ60" ON "FAKPOZ_B" ("ID_FAKT", "ID_POZ", "ID_BON") ;
--------------------------------------------------------
--  DDL for Index IND573
--------------------------------------------------------

  CREATE UNIQUE INDEX "IND573" ON "LOGTRANP" ("K2", "K1", "K5", "K3") ;
--------------------------------------------------------
--  DDL for Index IND820
--------------------------------------------------------

  CREATE UNIQUE INDEX "IND820" ON "SL_OBR_STAND" ("NR_KOMP_EL", "TYP", "NR_TYPU", "NR_KOMP") ;
--------------------------------------------------------
--  DDL for Index INDEKS655
--------------------------------------------------------

  CREATE UNIQUE INDEX "INDEKS655" ON "KSZT_DOP" ("NUMER_KOMPUTEROWY", "NR_KSZT") ;
--------------------------------------------------------
--  DDL for Index IND_KONF
--------------------------------------------------------

  CREATE UNIQUE INDEX "IND_KONF" ON "KONFDOK" ("GR_DOK", "TYP_DOK") ;
--------------------------------------------------------
--  DDL for Index IND_KONF271
--------------------------------------------------------

  CREATE UNIQUE INDEX "IND_KONF271" ON "KONF_DOK_ZAK" ("GR_DOK", "TYP_DOK") ;
--------------------------------------------------------
--  DDL for Index IND_KONFD_NB_OST_NR
--------------------------------------------------------

  CREATE UNIQUE INDEX "IND_KONFD_NB_OST_NR" ON "NB_OST_NR" ("GR_DOK", "TYP", "TYP_DOK") ;
--------------------------------------------------------
--  DDL for Index JEZ_WYDR_KONF
--------------------------------------------------------

  CREATE UNIQUE INDEX "JEZ_WYDR_KONF" ON "JEZYKI_WYDR_KONF" ("FONT_OFFSET") ;
--------------------------------------------------------
--  DDL for Index KEY001CUBCK777
--------------------------------------------------------

  CREATE UNIQUE INDEX "KEY001CUBCK777" ON "CUBCK777" ("NR_KOMP_STRUKTURY", "NR_KOL_PARAM") ;
--------------------------------------------------------
--  DDL for Index KEY001ZMCNV111
--------------------------------------------------------

  CREATE UNIQUE INDEX "KEY001ZMCNV111" ON "ZMCNV111" ("NR_NALICZ", "ZNACZNIK", "INDEKS_WYR", "NR_SPRZED", "POZ_SPRZED", "LP_114") ;
--------------------------------------------------------
--  DDL for Index KEY002CUBCK777
--------------------------------------------------------

  CREATE UNIQUE INDEX "KEY002CUBCK777" ON "CUBCK777" ("NR_KOMP_SL_PAR", "NR_KOMP_STRUKTURY", "NR_KOL_PARAM") ;
--------------------------------------------------------
--  DDL for Index KEY002ZMCNV111
--------------------------------------------------------

  CREATE UNIQUE INDEX "KEY002ZMCNV111" ON "ZMCNV111" ("NR_NALICZ", "SKROT_KON", "NR_KON", "NR_SPRZED", "POZ_SPRZED", "LP_114") ;
--------------------------------------------------------
--  DDL for Index KEY003ZMCNV111
--------------------------------------------------------

  CREATE UNIQUE INDEX "KEY003ZMCNV111" ON "ZMCNV111" ("NR_NALICZ", "SKR_TYP_FAKT", "ZNACZNIK", "NR_FAKTURY", "POZ_SPRZED", "LP_114") ;
--------------------------------------------------------
--  DDL for Index KEY004ZMCNV111
--------------------------------------------------------

  CREATE UNIQUE INDEX "KEY004ZMCNV111" ON "ZMCNV111" ("NR_NALICZ", "NR_GR_KOSZT_WYR", "INDEKS_WYR", "NR_SPRZED", "POZ_SPRZED", "LP_114") ;
--------------------------------------------------------
--  DDL for Index KONF_KEY
--------------------------------------------------------

  CREATE UNIQUE INDEX "KONF_KEY" ON "NB_KONFIG" ("KONF_KEY") ;
--------------------------------------------------------
--  DDL for Index KSLTYP1
--------------------------------------------------------

  CREATE UNIQUE INDEX "KSLTYP1" ON "SLTYP_TRANS" ("OZN_TYPU") ;
--------------------------------------------------------
--  DDL for Index KSURKON1
--------------------------------------------------------

  CREATE UNIQUE INDEX "KSURKON1" ON "SUR_KONFIG" ("RODZAJ_SUR", "NR_KATALOG", "TYP_TRANS") ;
--------------------------------------------------------
--  DDL for Index KSURKON2
--------------------------------------------------------

  CREATE UNIQUE INDEX "KSURKON2" ON "SUR_KONFIG" ("RODZAJ_SUR", "TYP_KATALOG", "TYP_TRANS") ;
--------------------------------------------------------
--  DDL for Index KSURKON3
--------------------------------------------------------

  CREATE UNIQUE INDEX "KSURKON3" ON "SUR_KONFIG" ("TYP_TRANS", "RODZAJ_SUR", "NR_KATALOG") ;
--------------------------------------------------------
--  DDL for Index KTH_
--------------------------------------------------------

  CREATE UNIQUE INDEX "KTH_" ON "KTH_N" ("KH_KOD") ;
--------------------------------------------------------
--  DDL for Index KTHM
--------------------------------------------------------

  CREATE INDEX "KTHM" ON "KTH_N" ("KH_MIASTO", "KH_NAZWA") ;
--------------------------------------------------------
--  DDL for Index KTHN
--------------------------------------------------------

  CREATE INDEX "KTHN" ON "KTH_N" ("KH_NAZWA") ;
--------------------------------------------------------
--  DDL for Index KTHV
--------------------------------------------------------

  CREATE INDEX "KTHV" ON "KTH_N" ("KH_NIP") ;
--------------------------------------------------------
--  DDL for Index KTRAN1
--------------------------------------------------------

  CREATE UNIQUE INDEX "KTRAN1" ON "TRANS_KONFIG" ("NR_KOMP_KONF") ;
--------------------------------------------------------
--  DDL for Index KTRAN2
--------------------------------------------------------

  CREATE UNIQUE INDEX "KTRAN2" ON "TRANS_KONFIG" ("TYP_TRANS", "NR_KOMP_KONF") ;
--------------------------------------------------------
--  DDL for Index KTRAN3
--------------------------------------------------------

  CREATE UNIQUE INDEX "KTRAN3" ON "TRANS_KONFIG" ("NR_INSTAL", "NR_KOMP_KONF") ;
--------------------------------------------------------
--  DDL for Index LP
--------------------------------------------------------

  CREATE UNIQUE INDEX "LP" ON "ZNAKI" ("ZNAK") ;
--------------------------------------------------------
--  DDL for Index LSUROPT_1
--------------------------------------------------------

  CREATE INDEX "LSUROPT_1" ON "TMP_SUROPT" ("NR_KOMP_LISTY", "NR_ZM_POCZ", "NR_KAT", "NR_INST_PRZEZN", "INDEKS") ;
--------------------------------------------------------
--  DDL for Index LTR_WG_SZKGR
--------------------------------------------------------

  CREATE UNIQUE INDEX "LTR_WG_SZKGR" ON "TMP_LLTRSZKLA" ("NR_KOMP_LISTY", "NR_KOMP_ZLEC", "NR_PODGR", "NR_KAT") ;
--------------------------------------------------------
--  DDL for Index M_ID_FAKT
--------------------------------------------------------

  CREATE INDEX "M_ID_FAKT" ON "FAKNAGL_B" ("ID_FAKT", "OPIS") ;
--------------------------------------------------------
--  DDL for Index M_ID_POZ
--------------------------------------------------------

  CREATE UNIQUE INDEX "M_ID_POZ" ON "FAKNAGL_B" ("ID_FAKT", "ID_BON") ;
--------------------------------------------------------
--  DDL for Index MK_NUMER_KOMP
--------------------------------------------------------

  CREATE UNIQUE INDEX "MK_NUMER_KOMP" ON "MK_NR_KOMPUT" ("NR_KOMP") ;
--------------------------------------------------------
--  DDL for Index NAZ_KAT1
--------------------------------------------------------

  CREATE INDEX "NAZ_KAT1" ON "KATALOG" ("NAZ_KAT") ;
--------------------------------------------------------
--  DDL for Index NO__
--------------------------------------------------------

  CREATE UNIQUE INDEX "NO__" ON "NOTA" ("ZNACZNIK", "KONTO", "WALUTA", "SYMB_DOK", "LP_DOK", "IDENT_FAK") ;
--------------------------------------------------------
--  DDL for Index NOTA
--------------------------------------------------------

  CREATE INDEX "NOTA" ON "NOTA" ("ZNACZNIK", "SYMB_DOK", "LP_DOK") ;
--------------------------------------------------------
--  DDL for Index NR_ODDZ244
--------------------------------------------------------

  CREATE UNIQUE INDEX "NR_ODDZ244" ON "LISTA_MPK" ("NR_ODDZ", "NR_KOMP") ;
--------------------------------------------------------
--  DDL for Index NUM_KAT1
--------------------------------------------------------

  CREATE UNIQUE INDEX "NUM_KAT1" ON "KATALOG" ("NR_KAT") ;
--------------------------------------------------------
--  DDL for Index PDI_TAB_ID
--------------------------------------------------------

  CREATE UNIQUE INDEX "PDI_TAB_ID" ON "NB_PLIKI_IMPORT" ("PDI_TAB_ID") ;
--------------------------------------------------------
--  DDL for Index POL_ETAP
--------------------------------------------------------

  CREATE INDEX "POL_ETAP" ON "NB_POLECENIA" ("POL_ETAP", "POL_KOLEJNOSC") ;
--------------------------------------------------------
--  DDL for Index POL_ID
--------------------------------------------------------

  CREATE UNIQUE INDEX "POL_ID" ON "NB_POLECENIA" ("POL_ID") ;
--------------------------------------------------------
--  DDL for Index RODZ_SUR1
--------------------------------------------------------

  CREATE INDEX "RODZ_SUR1" ON "KATALOG" ("RODZ_SUR") ;
--------------------------------------------------------
--  DDL for Index SIP_WG_NR_APL_APLIKACJE
--------------------------------------------------------

  CREATE UNIQUE INDEX "SIP_WG_NR_APL_APLIKACJE" ON "APLIKACJE" ("NR") ;
--------------------------------------------------------
--  DDL for Index SQL_ARG_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "SQL_ARG_PK" ON "SQL_ARG" ("SQL_ID", "ARG_ID") ;
--------------------------------------------------------
--  DDL for Index SQL_FILE_HIS_KEY
--------------------------------------------------------

  CREATE UNIQUE INDEX "SQL_FILE_HIS_KEY" ON "SQL_FILE_HIS" ("HIS_ID") ;
--------------------------------------------------------
--  DDL for Index SQL_FILE_HIS_UNIQUE
--------------------------------------------------------

  CREATE UNIQUE INDEX "SQL_FILE_HIS_UNIQUE" ON "SQL_FILE_HIS" ("SQL_ID", "TYP", "DATA_TIME") ;
--------------------------------------------------------
--  DDL for Index SQL_HIS_ID
--------------------------------------------------------

  CREATE UNIQUE INDEX "SQL_HIS_ID" ON "SQL_HISTORIA" ("HIS_ID") ;
--------------------------------------------------------
--  DDL for Index SQL_ID
--------------------------------------------------------

  CREATE UNIQUE INDEX "SQL_ID" ON "SQL_LISTA" ("SQL_ID") ;
--------------------------------------------------------
--  DDL for Index SQL_ID_FILE
--------------------------------------------------------

  CREATE UNIQUE INDEX "SQL_ID_FILE" ON "SQL_FILE" ("SQL_ID", "TYP") ;
--------------------------------------------------------
--  DDL for Index SQL_UPR2_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "SQL_UPR2_PK" ON "SQL_UPRAWNIENIA2" ("SQL_ID", "OPERATOR_ID") ;
--------------------------------------------------------
--  DDL for Index SQL_UPR_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "SQL_UPR_PK" ON "SQL_UPRAWNIENIA" ("SQL_ID", "KLUCZ") ;
--------------------------------------------------------
--  DDL for Index SYS_C001040530
--------------------------------------------------------

  CREATE UNIQUE INDEX "SYS_C001040530" ON "ECUTTER_USERS" ("LOGIN") ;
--------------------------------------------------------
--  DDL for Index TAB_ID
--------------------------------------------------------

  CREATE UNIQUE INDEX "TAB_ID" ON "NB_TABELE" ("TAB_ID") ;
--------------------------------------------------------
--  DDL for Index TAB_LISTA
--------------------------------------------------------

  CREATE INDEX "TAB_LISTA" ON "NB_TABELE" ("TAB_WLASNA" DESC, "TAB_NAZWA") ;
--------------------------------------------------------
--  DDL for Index TAB_NAZWA
--------------------------------------------------------

  CREATE INDEX "TAB_NAZWA" ON "NB_TABELE" ("TAB_NAZWA") ;
--------------------------------------------------------
--  DDL for Index TYP_KAT1
--------------------------------------------------------

  CREATE UNIQUE INDEX "TYP_KAT1" ON "KATALOG" ("TYP_KAT") ;
--------------------------------------------------------
--  DDL for Index VAT_
--------------------------------------------------------

  CREATE UNIQUE INDEX "VAT_" ON "VAT" ("ZNACZNIK", "NR_R", "LP_R") ;
--------------------------------------------------------
--  DDL for Index VATD
--------------------------------------------------------

  CREATE INDEX "VATD" ON "VAT" ("ZNACZNIK", "MIES_DOK", "SYMB_DOK", "MAGAZYN") ;
--------------------------------------------------------
--  DDL for Index WCENC53
--------------------------------------------------------

  CREATE INDEX "WCENC53" ON "DRMETPOZ" ("LP_LIS", "LPC") ;
--------------------------------------------------------
--  DDL for Index WCENM53
--------------------------------------------------------

  CREATE INDEX "WCENM53" ON "DRMETPOZ" ("LP_LIS" DESC, "LPC" DESC) ;
--------------------------------------------------------
--  DDL for Index WG_133
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_133" ON "BILANSPK" ("NR_ODDZ", "NR_MAG", "INDEKS", "SERIA", "DATA_ZAPASU", "CENA_ZAKUPU", "ZN_KARTOTEKI", "NR_KOMP_ZLEC", "NR_POZ_ZLEC", "NR", "NR_POZ_DOK") ;
--------------------------------------------------------
--  DDL for Index WG_AKT_ODM70
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_AKT_ODM70" ON "ODPADY" ("AKT", "NR_ODP") ;
--------------------------------------------------------
--  DDL for Index WG_ALL43
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ALL43" ON "MK_NR_DOK" ("NUMER", "MIES", "ROK", "KARTOTEKA", "TYP_DOK") ;
--------------------------------------------------------
--  DDL for Index WG_APLIKACJI
--------------------------------------------------------

  CREATE INDEX "WG_APLIKACJI" ON "KLUCZE" ("APLIKACJA", "NAZWA") ;
--------------------------------------------------------
--  DDL for Index WG_BRAKI438
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_BRAKI438" ON "REKBRAK" ("NR_KOMP_RB", "NR_KOM_ZLEC", "NR_POZ_ZLEC", "NR_WARST") ;
--------------------------------------------------------
--  DDL for Index WG_BRYG241
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_BRYG241" ON "DANE_WYK" ("NR_KOMP_INST", "NR_BRYGADY", "NR_KOMP_ZM") ;
--------------------------------------------------------
--  DDL for Index WG_BRYG362
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_BRYG362" ON "PRAC_WYK" ("NR_KOMP_INST", "NR_BRYGADY", "NR_KOMP_ZM", "NR_PRAC", "NK_ZAP") ;
--------------------------------------------------------
--  DDL for Index WG_BUD8
--------------------------------------------------------

  CREATE INDEX "WG_BUD8" ON "STRUKTURY" ("IL_WARSTW", "ATR_BUD", "IND_BUD") ;
--------------------------------------------------------
--  DDL for Index WG_BUDOWY
--------------------------------------------------------

  CREATE INDEX "WG_BUDOWY" ON "SPISZ" ("IND_BUD") ;
--------------------------------------------------------
--  DDL for Index WG_BUDOWY10_2
--------------------------------------------------------

  CREATE INDEX "WG_BUDOWY10_2" ON "RPZLEC_POZ" ("IND_BUD") ;
--------------------------------------------------------
--  DDL for Index WG_CECHY460
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_CECHY460" ON "CECHY_USER" ("NR_CECHY", "NR_KONTRAH") ;
--------------------------------------------------------
--  DDL for Index WGCECHY461
--------------------------------------------------------

  CREATE UNIQUE INDEX "WGCECHY461" ON "CECHY_LISTA" ("NUMER_CECHY") ;
--------------------------------------------------------
--  DDL for Index WG_CENNIKA421
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_CENNIKA421" ON "CEN_STR" ("NR_CEN", "KOD_STR") ;
--------------------------------------------------------
--  DDL for Index WG_CENNIKA735
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_CENNIKA735" ON "CEN04" ("NK_CENNIKA", "TYP", "NKOMP", "KOD") ;
--------------------------------------------------------
--  DDL for Index WG_CENNIKA735O
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_CENNIKA735O" ON "CEN04_FGT" ("NKOMP_CEN", "TYP", "NKOMP") ;
--------------------------------------------------------
--  DDL for Index WG_CENNIKA_CEN04_T7
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_CENNIKA_CEN04_T7" ON "CEN04_T7" ("NKOMP_CEN", "TYP", "NKOMP") ;
--------------------------------------------------------
--  DDL for Index WG_CP_CEN_I47
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_CP_CEN_I47" ON "CP_CEN" ("NK_PRZEC", "NK_CEN") ;
--------------------------------------------------------
--  DDL for Index WG_CP_PRZEC_I50
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_CP_PRZEC_I50" ON "CP_DOP" ("NK_PRZEC", "TYP", "NR_KAT") ;
--------------------------------------------------------
--  DDL for Index WG_CZYN
--------------------------------------------------------

  CREATE INDEX "WG_CZYN" ON "PARINST" ("NR_CZYN") ;
--------------------------------------------------------
--  DDL for Index WG_DATY
--------------------------------------------------------

  CREATE INDEX "WG_DATY" ON "LOG_TRANS" ("DATA", "CZAS") ;
--------------------------------------------------------
--  DDL for Index WG_DATY_112
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_DATY_112" ON "NAL_RAP_ZYSK" ("DATA_OD", "NR_NALICZ") ;
--------------------------------------------------------
--  DDL for Index WG_DATY_116
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_DATY_116" ON "OPAKOUT_G" ("DATA_P", "NR_K_GRP") ;
--------------------------------------------------------
--  DDL for Index WG_DATY128
--------------------------------------------------------

  CREATE INDEX "WG_DATY128" ON "TRAN_STR" ("NUMER_KONTRAHENTA", "NR_KOMP_STR", "DATA_MOD" DESC) ;
--------------------------------------------------------
--  DDL for Index WG_DATY15
--------------------------------------------------------

  CREATE INDEX "WG_DATY15" ON "DOK" ("DATA_TR") ;
--------------------------------------------------------
--  DDL for Index WG_DATY16
--------------------------------------------------------

  CREATE INDEX "WG_DATY16" ON "POZDOK" ("TYP_DOK", "DATA_D") ;
--------------------------------------------------------
--  DDL for Index WG_DATY21
--------------------------------------------------------

  CREATE INDEX "WG_DATY21" ON "FAKNAGL" ("DATA_WYST") ;
--------------------------------------------------------
--  DDL for Index WG_DATY237
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_DATY237" ON "NIEOBEC" ("OD_DATY", "NR_PRAC", "NR_ODDZ") ;
--------------------------------------------------------
--  DDL for Index WG_DATY_259
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_DATY_259" ON "REJ_POZ_REKL" ("DATA_ZGLOSZ", "NR_KOMP_REKL") ;
--------------------------------------------------------
--  DDL for Index WG_DATY260
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_DATY260" ON "KURS_SAD" ("DATA", "WALUTA") ;
--------------------------------------------------------
--  DDL for Index WG_DATY261
--------------------------------------------------------

  CREATE INDEX "WG_DATY261" ON "LOK_DOK" ("DATA_TR") ;
--------------------------------------------------------
--  DDL for Index WG_DATY262
--------------------------------------------------------

  CREATE INDEX "WG_DATY262" ON "LOK_POZDOK" ("TYP_DOK", "DATA_D") ;
--------------------------------------------------------
--  DDL for Index WG_DATY272
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_DATY272" ON "BUDZET" ("NR_ODDZ", "ROK_OBRACH", "MIES_OBR", "GR_TOW") ;
--------------------------------------------------------
--  DDL for Index WG_DATY277
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_DATY277" ON "ODDZ_BLOK" ("D_WSTRZYM", "C_WSTRZYM", "NR_KOM_ZLEC", "NR_ODDZ") ;
--------------------------------------------------------
--  DDL for Index WG_DATY29
--------------------------------------------------------

  CREATE INDEX "WG_DATY29" ON "REJVAT" ("DATA_WYS") ;
--------------------------------------------------------
--  DDL for Index WG_DATY30
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_DATY30" ON "KONTRAKT" ("DATA_POCZ", "NR_KOMP_KONTR") ;
--------------------------------------------------------
--  DDL for Index WG_DATY30_18
--------------------------------------------------------

  CREATE INDEX "WG_DATY30_18" ON "RKONTRAKT" ("DATA_POCZ") ;
--------------------------------------------------------
--  DDL for Index WG_DATY388
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_DATY388" ON "PREMM" ("NR_ODDZ", "ROK", "MIES", "NR_PRAC") ;
--------------------------------------------------------
--  DDL for Index WG_DATY_495
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_DATY_495" ON "PAML1" ("D_UTWORZ", "NR_LISTY") ;
--------------------------------------------------------
--  DDL for Index WG_DATY540
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_DATY540" ON "RAP_SP_DZ" ("DATA_WYST", "NR_KONTR", "GR_TOWAR") ;
--------------------------------------------------------
--  DDL for Index WG_DATY60_40
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_DATY60_40" ON "FK2_FAK" ("DATA_WYS", "NK_DOK", "ZNK_DOK") ;
--------------------------------------------------------
--  DDL for Index WG_DATY605
--------------------------------------------------------

  CREATE INDEX "WG_DATY605" ON "ST_KONTR_STOJ" ("NK_KONTR", "DATA_WYJ", "NK_STOJ") ;
--------------------------------------------------------
--  DDL for Index WG_DATY726
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_DATY726" ON "CECHY_MONIT" ("DATA", "CZAS", "NAZ_PAR") ;
--------------------------------------------------------
--  DDL for Index WG_DATY_FK6_DANE2
--------------------------------------------------------

  CREATE INDEX "WG_DATY_FK6_DANE2" ON "FK6_DANE2" ("NK_KONTR", "DATA") ;
--------------------------------------------------------
--  DDL for Index WG_DATY_FKS_FAKTURY
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_DATY_FKS_FAKTURY" ON "FKS_FAKTURY" ("DATA_WYSLANIA", "NKOMP_DOKUMENTU", "ZNACZNIK_DOKUMENTU") ;
--------------------------------------------------------
--  DDL for Index WG_DATY_KONC
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_DATY_KONC" ON "ARK_KOSZT_ODDZ" ("DATA_KONC", "NR_GR_KOSZT_WYR", "NR_TABELI") ;
--------------------------------------------------------
--  DDL for Index WG_DATY_LOGT
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_DATY_LOGT" ON "LOGT" ("NK_ZAP") ;
--------------------------------------------------------
--  DDL for Index WG_DATY_PAK12
--------------------------------------------------------

  CREATE INDEX "WG_DATY_PAK12" ON "SPISE" ("NR_KOMP_ZM_PAK", "NR_KOMP_INST_PAK") ;
--------------------------------------------------------
--  DDL for Index WG_DATY_PL
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_DATY_PL" ON "HARMON" ("NR_KOMP_INST", "DZIEN", "ZMIANA", "TYP_HARM", "NR_KOMP_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_DATY_PL550
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_DATY_PL550" ON "KOPHARMON" ("NR_KOMP_INST", "DZIEN", "ZMIANA", "TYP_HARM", "NR_KOMP_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_DATY_PROD12
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_DATY_PROD12" ON "SPISE" ("DATA_WYK", "ZM_WYK", "NR_KOMP_ZLEC", "NR_POZ", "NR_KOM_SZYBY") ;
--------------------------------------------------------
--  DDL for Index WG_DATY_REJ12
--------------------------------------------------------

  CREATE INDEX "WG_DATY_REJ12" ON "SPISE" ("D_WYK", "T_WYK", "O_WYK") ;
--------------------------------------------------------
--  DDL for Index WG_DOK19
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_DOK19" ON "REJVAT" ("TYP_DOKS", "PREFIX", "NR_DOKS", "SUFIX") ;
--------------------------------------------------------
--  DDL for Index WG_DOK23
--------------------------------------------------------

  CREATE INDEX "WG_DOK23" ON "NALEZN" ("NR_KOMP_NAL") ;
--------------------------------------------------------
--  DDL for Index WG_DOK507
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_DOK507" ON "KASA_DOK" ("TYP_DOK", "NR_DOK") ;
--------------------------------------------------------
--  DDL for Index WG_DOK_FKS_FAKTURY
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_DOK_FKS_FAKTURY" ON "FKS_FAKTURY" ("NKOMP_DOKUMENTU") ;
--------------------------------------------------------
--  DDL for Index WG_DOKUMENTU665
--------------------------------------------------------

  CREATE INDEX "WG_DOKUMENTU665" ON "OKNA_ZAS1" ("TYP_DOK") ;
--------------------------------------------------------
--  DDL for Index WG_DOM_BAZ15
--------------------------------------------------------

  CREATE INDEX "WG_DOM_BAZ15" ON "DOK" ("NR_KOMP_BAZ") ;
--------------------------------------------------------
--  DDL for Index WG_DOM_BAZ261
--------------------------------------------------------

  CREATE INDEX "WG_DOM_BAZ261" ON "LOK_DOK" ("NR_KOMP_BAZ") ;
--------------------------------------------------------
--  DDL for Index WG_D_PL13
--------------------------------------------------------

  CREATE INDEX "WG_D_PL13" ON "SPISP" ("DATA_PLAN", "ZM_PLAN") ;
--------------------------------------------------------
--  DDL for Index WG_D_PL549
--------------------------------------------------------

  CREATE INDEX "WG_D_PL549" ON "KOPSPISP" ("DATA_PLAN", "ZM_PLAN") ;
--------------------------------------------------------
--  DDL for Index WG_D_PL9
--------------------------------------------------------

  CREATE INDEX "WG_D_PL9" ON "ZAMOW" ("D_PLAN" DESC) ;
--------------------------------------------------------
--  DDL for Index WG_D_PL9_1
--------------------------------------------------------

  CREATE INDEX "WG_D_PL9_1" ON "RPZLEC" ("DATA_PLAN_PROD" DESC) ;
--------------------------------------------------------
--  DDL for Index WG_D_WYK13
--------------------------------------------------------

  CREATE INDEX "WG_D_WYK13" ON "SPISP" ("DATA_WYK", "ZM_WYK") ;
--------------------------------------------------------
--  DDL for Index WG_D_WYK549
--------------------------------------------------------

  CREATE INDEX "WG_D_WYK549" ON "KOPSPISP" ("DATA_WYK", "ZM_WYK") ;
--------------------------------------------------------
--  DDL for Index WG_DWYK62
--------------------------------------------------------

  CREATE INDEX "WG_DWYK62" ON "L_WYC" ("D_WYK", "ZM_WYK", "NR_INST_WYK") ;
--------------------------------------------------------
--  DDL for Index WG_D_ZL228
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_D_ZL228" ON "OFERTY_NAG" ("DATA_ZL", "NR_KOM_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_D_ZL441
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_D_ZL441" ON "OFERTY_NAGK" ("DATA_ZL", "NR_KOM_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_D_ZL9
--------------------------------------------------------

  CREATE INDEX "WG_D_ZL9" ON "ZAMOW" ("DATA_ZL" DESC) ;
--------------------------------------------------------
--  DDL for Index WG_D_ZL9_1
--------------------------------------------------------

  CREATE INDEX "WG_D_ZL9_1" ON "RPZLEC" ("DATA_ZLEC" DESC) ;
--------------------------------------------------------
--  DDL for Index WG_EC_NKOMP_EC_BUF
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_EC_NKOMP_EC_BUF" ON "EC_BUF" ("EC_NK") ;
--------------------------------------------------------
--  DDL for Index WG_FAK_POZ
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_FAK_POZ" ON "FAKPODSUM" ("ID_FAKT", "ID_PODS") ;
--------------------------------------------------------
--  DDL for Index WG_FAKT_111
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_FAKT_111" ON "RAP_ZYSK" ("NR_NALICZ", "SKR_TYP_FAKT", "ZNACZNIK", "NR_FAKTURY", "POZ_SPRZED", "LP_114") ;
--------------------------------------------------------
--  DDL for Index WG_FAKT509
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_FAKT509" ON "NAL_FK" ("SYM_FAKT", "KOD_KONTR") ;
--------------------------------------------------------
--  DDL for Index WG_FAKT_DOST_508
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_FAKT_DOST_508" ON "FAKT_LISTA_SPED" ("ID_FAKTURY", "ID_DOSTAWY") ;
--------------------------------------------------------
--  DDL for Index WG_FAKTURY_22
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_FAKTURY_22" ON "KTH_ROZRACH" ("NR_KOMP_FAKT", "DATA_ZAPL", "NR_DOWODU_KS", "POZ_DOW_KS", "IDENT_ROZR") ;
--------------------------------------------------------
--  DDL for Index WG_FAKT_WZ_506
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_FAKT_WZ_506" ON "FAKT_LISTA_WZ" ("ID_FAKTURY", "NR_K_WZ") ;
--------------------------------------------------------
--  DDL for Index WG_FAKT_ZLEC_507
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_FAKT_ZLEC_507" ON "FAKT_LISTA_ZLEC" ("ID_FAKTURY", "ID_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_FAT_ST_505
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_FAT_ST_505" ON "FAKT_PODS_VAT" ("ID_FAKT", "KOD_ST_VAT") ;
--------------------------------------------------------
--  DDL for Index WG_FLAG460
--------------------------------------------------------

  CREATE INDEX "WG_FLAG460" ON "NR_OZNAK" ("NR_KOL", "FLAG", "NR") ;
--------------------------------------------------------
--  DDL for Index WG_FL_REAL
--------------------------------------------------------

  CREATE INDEX "WG_FL_REAL" ON "SPISE" ("FLAG_REAL") ;
--------------------------------------------------------
--  DDL for Index WG_FV577
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_FV577" ON "ROZLICZ_ZAL" ("N_K_FAKT", "N_K_ZAL") ;
--------------------------------------------------------
--  DDL for Index WG_G294
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_G294" ON "ZZSLOW" ("GRUPA", "NR_W_GRUPIE") ;
--------------------------------------------------------
--  DDL for Index WG_GLOW537
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_GLOW537" ON "WYM_SER" ("NR_GLOWNY", "NR_WYM") ;
--------------------------------------------------------
--  DDL for Index WG_GR_111
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_GR_111" ON "RAP_ZYSK" ("NR_NALICZ", "NR_GR_KOSZT_WYR", "INDEKS_WYR", "NR_SPRZED", "POZ_SPRZED", "LP_114") ;
--------------------------------------------------------
--  DDL for Index WG_GR_250
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_GR_250" ON "SLOW_ATEST" ("GR_TOWAR", "NR_ATESTU") ;
--------------------------------------------------------
--  DDL for Index WG_GR_452
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_GR_452" ON "STR_W_ZLEC" ("GR_KOSZT_WYR", "NR_KOM_STR", "NR_KAT_DOD", "NR_KOM_ZLEC", "NR_KOL_STRUKT") ;
--------------------------------------------------------
--  DDL for Index WG_GR464
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_GR464" ON "LIMITY_WYM" ("GR_SZKL", "SZER_RAMKI") ;
--------------------------------------------------------
--  DDL for Index WG_GR_INST_M489
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_GR_INST_M489" ON "GR_INST_POW" ("NR_KOMP_GR", "NR_KOMP_INST") ;
--------------------------------------------------------
--  DDL for Index WG_GR_K258
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_GR_K258" ON "FAKPODSUM" ("ID_FAKT", "GR_KOSZT", "ST_VAT", "ID_PODS") ;
--------------------------------------------------------
--  DDL for Index WG_GR_KOSZT_311
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_GR_KOSZT_311" ON "ARK_KOSZT_ODDZ" ("NR_GR_KOSZT_WYR", "DATA_POCZ", "DATA_KONC") ;
--------------------------------------------------------
--  DDL for Index WG_GRP_120
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_GRP_120" ON "OPAKOUT_PG" ("NR_K_GRP", "NR_PODGR") ;
--------------------------------------------------------
--  DDL for Index WG_GR_SUR_312
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_GR_SUR_312" ON "ZLECENIA_ANAL_KOSZT" ("GR_KOSZT_SUR", "GR_KOSZT_WYR", "NR_ZLEC", "NR_STRUKT") ;
--------------------------------------------------------
--  DDL for Index WG_GR_T258
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_GR_T258" ON "FAKPODSUM" ("GR_TOW", "ID_FAKT", "ID_PODS", "GR_KOSZT") ;
--------------------------------------------------------
--  DDL for Index WG_GR_TOW_540
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_GR_TOW_540" ON "RAP_SP_DZ" ("GR_TOWAR", "DATA_WYST", "NR_KONTR") ;
--------------------------------------------------------
--  DDL for Index WG_GRUP272
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_GRUP272" ON "BUDZET" ("NR_ODDZ", "GR_TOW", "ROK_OBRACH", "MIES_OBR") ;
--------------------------------------------------------
--  DDL for Index WG_GRUP_T
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_GRUP_T" ON "GRUPTOW" ("GR_TOW") ;
--------------------------------------------------------
--  DDL for Index WG_GRUPY188
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_GRUPY188" ON "GRUPYKL" ("NUMER_GRUPY", "NUMER_KLUCZA") ;
--------------------------------------------------------
--  DDL for Index WG_GRUPY191
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_GRUPY191" ON "OPER_GR" ("NUMER_GRUPY", "NR_OPER") ;
--------------------------------------------------------
--  DDL for Index WG_GRUPY527
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_GRUPY527" ON "EFF_ZASADY" ("GR_KOSZ", "NAZ_VAT") ;
--------------------------------------------------------
--  DDL for Index WG_GRUPY_555
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_GRUPY_555" ON "GR_STRUKT" ("NR_GRUPY_STR") ;
--------------------------------------------------------
--  DDL for Index WG_GRUPY655
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_GRUPY655" ON "SLOWGRUP" ("TYP_WYROBU", "ANAL", "NR_JEZYKA") ;
--------------------------------------------------------
--  DDL for Index WG_GR_WYR_312
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_GR_WYR_312" ON "ZLECENIA_ANAL_KOSZT" ("GR_KOSZT_WYR", "GR_KOSZT_SUR", "NR_STRUKT", "NR_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_ID
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ID" ON "FAKPOZ" ("NR_KOMP_DOKS", "ID_POZ", "LP_DOD") ;
--------------------------------------------------------
--  DDL for Index WG_ID189
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ID189" ON "OPERATORZY" ("ID") ;
--------------------------------------------------------
--  DDL for Index WG_ID212
--------------------------------------------------------

  CREATE INDEX "WG_ID212" ON "CENT_POPER" ("NR_ODDZ", "ID") ;
--------------------------------------------------------
--  DDL for Index WG_ID3
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ID3" ON "TR3_TABELA1" ("ZNACZNIK", "ID") ;
--------------------------------------------------------
--  DDL for Index WG_ID_826
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ID_826" ON "KATEG_WYM_O" ("KOD_KAT") ;
--------------------------------------------------------
--  DDL for Index WG_ID_DOPL503
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ID_DOPL503" ON "TYPY_DOPLAT" ("ID_TYPU_DOPL") ;
--------------------------------------------------------
--  DDL for Index WG_IDENT
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IDENT" ON "FGT_DEKRETY" ("IDENT", "LP") ;
--------------------------------------------------------
--  DDL for Index WG_IDENT10_2
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IDENT10_2" ON "RPZLEC_POZ" ("IDENT_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_IDENT_3
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IDENT_3" ON "RZLEC_DODATKI" ("IDENT_REK", "KOL_DOD") ;
--------------------------------------------------------
--  DDL for Index WG_IDENT438R
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IDENT438R" ON "RZMIANY" ("ID_REK") ;
--------------------------------------------------------
--  DDL for Index WG_IDENT476R
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IDENT476R" ON "RZLEC_SZP" ("NK_ZLEC", "IDENT_SZP") ;
--------------------------------------------------------
--  DDL for Index WG_IDENT535
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IDENT535" ON "STORKE_ZLEC" ("IDENT_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_IDENT536
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IDENT536" ON "STORKE_PZLEC" ("IDENT_LINII") ;
--------------------------------------------------------
--  DDL for Index WG_IDENT587R
--------------------------------------------------------

  CREATE INDEX "WG_IDENT587R" ON "RRYSUNKI" ("IDENT_REK") ;
--------------------------------------------------------
--  DDL for Index WG_IDENT_666
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IDENT_666" ON "OKNA_KONTA_N" ("IDENT") ;
--------------------------------------------------------
--  DDL for Index WG_IDENT667R
--------------------------------------------------------

  CREATE INDEX "WG_IDENT667R" ON "RREK_ZLEC" ("IDENT_REK") ;
--------------------------------------------------------
--  DDL for Index WG_IDENT673
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IDENT673" ON "ZLEC_DOPLATY" ("IDENT_POZ", "RODZAJ") ;
--------------------------------------------------------
--  DDL for Index WG_IDENT674R
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IDENT674R" ON "RZLEC_DOPLATY" ("ID_POZ", "RODZAJ") ;
--------------------------------------------------------
--  DDL for Index WG_IDENT748R
--------------------------------------------------------

  CREATE INDEX "WG_IDENT748R" ON "RZLEC_TYP" ("IDENT_REKORDU", "TYP") ;
--------------------------------------------------------
--  DDL for Index WG_IDN103
--------------------------------------------------------

  CREATE INDEX "WG_IDN103" ON "LOG_TRANS" ("NR_ODDZ", "DATA", "CZAS", "NR_ZBIORU", "NKOMP", "NR_KOMP_NAG") ;
--------------------------------------------------------
--  DDL for Index WG_ID_ORYG62
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ID_ORYG62" ON "L_WYC" ("ID_ORYG", "ID_REK") ;
--------------------------------------------------------
--  DDL for Index WG_ID_RAB501
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ID_RAB501" ON "TYPY_RABATOW" ("ID_TYPU_RABATU") ;
--------------------------------------------------------
--  DDL for Index WG_ID_REK62
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ID_REK62" ON "L_WYC" ("ID_REK") ;
--------------------------------------------------------
--  DDL for Index WG_ID_STATUSY
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ID_STATUSY" ON "STATUSY" ("ID") ;
--------------------------------------------------------
--  DDL for Index WG_IDX_120
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IDX_120" ON "OPAKOUT_PG" ("OPIS_OZNACZ_GR", "NR_K_GRP", "NR_PODGR") ;
--------------------------------------------------------
--  DDL for Index WG_ID_ZLEC22
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ID_ZLEC22" ON "FAKPOZ" ("ID_ZLEC", "ID_ZLEC_POZ", "LP_DOD", "ID_POZ", "NR_KOMP_DOKS") ;
--------------------------------------------------------
--  DDL for Index WG_IFS109
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IFS109" ON "IFS_VAT" ("KONTO_SYNT", "KONTO_ANAL") ;
--------------------------------------------------------
--  DDL for Index WG_IGR_556
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IGR_556" ON "POZ_GR_STR" ("NR_GR_STR", "INDEKS") ;
--------------------------------------------------------
--  DDL for Index WG_IND_111
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IND_111" ON "RAP_ZYSK" ("NR_NALICZ", "ZNACZNIK", "INDEKS_WYR", "NR_SPRZED", "POZ_SPRZED", "LP_114") ;
--------------------------------------------------------
--  DDL for Index WG_IND126
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IND126" ON "TRAN_ZAM" ("NR_KOL", "NR_KONTR", "NR_ZLEC_KLIENTA") ;
--------------------------------------------------------
--  DDL for Index WG_IND151
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IND151" ON "KODY_GRUB" ("KOD") ;
--------------------------------------------------------
--  DDL for Index WG_IND224
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IND224" ON "SLOWDLAOO" ("INDEKS", "NR_ODDZ", "NR_MAG_DOC") ;
--------------------------------------------------------
--  DDL for Index WG_IND273
--------------------------------------------------------

  CREATE INDEX "WG_IND273" ON "BAZA_CEN" ("INDEKS", "NR_DOST") ;
--------------------------------------------------------
--  DDL for Index WG_IND275
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IND275" ON "STANY_MIN" ("INDEKS", "NR_MAG", "NR_ODDZ") ;
--------------------------------------------------------
--  DDL for Index WG_IND_335
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IND_335" ON "ZAK_UPR" ("RODZAJ", "KWOTA", "ZAP1", "AUT1") ;
--------------------------------------------------------
--  DDL for Index WG_IND376
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IND376" ON "A_TRANZ" ("NR_KOL", "NAZ_KONTR", "DATA_WCZYT", "NR_ZLEC_KLIENTA") ;
--------------------------------------------------------
--  DDL for Index WG_IND377
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IND377" ON "A_TRANP" ("NR_KOL", "NR_POZ", "ZLEC_KLIENTA", "SZYBA1") ;
--------------------------------------------------------
--  DDL for Index WG_IND378
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IND378" ON "A_TRANS" ("NAZ_SZPR", "INDEKS", "NR_MAG") ;
--------------------------------------------------------
--  DDL for Index WG_IND403
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IND403" ON "WYROBY_O" ("INDEKS", "NR_KOMP") ;
--------------------------------------------------------
--  DDL for Index WG_IND_472
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IND_472" ON "MON_STRATY" ("INDEKS", "NR_KOMP_POBR", "NR_KOMP_ZMIANY") ;
--------------------------------------------------------
--  DDL for Index WG_IND537
--------------------------------------------------------

  CREATE INDEX "WG_IND537" ON "WYM_SER" ("IND_FK") ;
--------------------------------------------------------
--  DDL for Index WG_IND_676
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IND_676" ON "MEMOSPED" ("NR_K_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_IND839
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_IND839" ON "JEZ_OPIS_POZ" ("NK_ZLEC", "NR_POZ", "NR_JEZ") ;
--------------------------------------------------------
--  DDL for Index WG_IND_DOST273
--------------------------------------------------------

  CREATE INDEX "WG_IND_DOST273" ON "BAZA_CEN" ("INDEKS_DOST", "NR_DOST") ;
--------------------------------------------------------
--  DDL for Index WG_INDEKS51
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_INDEKS51" ON "FGT_GRK" ("INDEKS") ;
--------------------------------------------------------
--  DDL for Index WG_INDEKS730A_38
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_INDEKS730A_38" ON "CEN06" ("NKOMP_CEN", "TYP_DOPLATY", "NR_KOLEJNY") ;
--------------------------------------------------------
--  DDL for Index WG_INDEKS730O
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_INDEKS730O" ON "CEN03_FGT" ("NKOMP_CEN", "TYP_DOPL", "NR_KOL") ;
--------------------------------------------------------
--  DDL for Index WG_INDEKS734
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_INDEKS734" ON "CEN03" ("NK_CENNIKA", "INDEKS_SZP", "SZER_SZP") ;
--------------------------------------------------------
--  DDL for Index WG_INDEKS_CEN03_T7
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_INDEKS_CEN03_T7" ON "CEN03_T7" ("NKOMP_CEN", "TYP_DOPL", "NR_KOL") ;
--------------------------------------------------------
--  DDL for Index WG_INDEKS_CEN06_ODD_T7
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_INDEKS_CEN06_ODD_T7" ON "CEN06_T7" ("NK_CEN", "INDEKS") ;
--------------------------------------------------------
--  DDL for Index WG_INDEKS_I51
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_INDEKS_I51" ON "CP_SZP" ("NK_PRZEC", "INDEKS_SZPR", "SZER") ;
--------------------------------------------------------
--  DDL for Index WG_INDEKSU2
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_INDEKSU2" ON "KARTOTEKA" ("INDEKS", "ZN_KART", "NR_ODZ", "NR_MAG") ;
--------------------------------------------------------
--  DDL for Index WG_INDEKSU_34
--------------------------------------------------------

  CREATE INDEX "WG_INDEKSU_34" ON "AITROBWGOT" ("NR_OKRESU", "NR_MAG", "INDEKS") ;
--------------------------------------------------------
--  DDL for Index WG_INDEKSU_36
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_INDEKSU_36" ON "AITROBPODSWG" ("NR_MAGAZ", "NR_OKRESU", "INDEKS", "NR_KOL_STOJAKA", "NR_KOMP_STOJ", "NR_KOMP_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_INDUNIQ273
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_INDUNIQ273" ON "BAZA_CEN" ("INDEKS", "NR_DOST", "CENA_WALUT", "NAZ_SKR_DOST") ;
--------------------------------------------------------
--  DDL for Index WG_INST240
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_INST240" ON "POSTOJE" ("NR_KOMP_INST", "DATA", "ZMIANA", "NR_KOMP_POST") ;
--------------------------------------------------------
--  DDL for Index WG_INST385
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_INST385" ON "WYKZAL" ("NR_KOMP_INSTAL", "NR_KOMP_ZLEC", "NR_KOMP_ZM", "NR_POZ", "INDEKS", "NR_ZM_PLAN", "NR_KOMP_OBR", "KOD_DOD", "NR_WARST") ;
--------------------------------------------------------
--  DDL for Index WG_INST462
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_INST462" ON "SPISW" ("NR_KOM_ZLEC", "NR_POZ", "NR_SZT", "NR_INST", "NR_OBR", "NR_KOMP_ZM", "BRAK") ;
--------------------------------------------------------
--  DDL for Index WG_INST548
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_INST548" ON "KOPWYKZAL" ("NR_KOMP_INSTAL", "NR_KOMP_ZLEC", "NR_KOMP_ZM", "NR_POZ", "INDEKS", "NR_ZM_PLAN") ;
--------------------------------------------------------
--  DDL for Index WG_INST62
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_INST62" ON "L_WYC" ("NR_INST", "NR_KOM_ZLEC", "NR_POZ_ZLEC", "NR_SZT", "NR_WARST") ;
--------------------------------------------------------
--  DDL for Index WG_INST62_P
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_INST62_P" ON "L_WYC_TMP" ("NR_KOMP_INST", "NR_KOMP_ZLEC", "NR_POZ", "NR_SZT", "NR_WARST") ;
--------------------------------------------------------
--  DDL for Index WG_INST800
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_INST800" ON "GR_PLAN" ("NKOMP_INSTALACJI", "NR_KOMP_OBR", "NR_GR") ;
--------------------------------------------------------
--  DDL for Index WG_INST801
--------------------------------------------------------

  CREATE INDEX "WG_INST801" ON "KAT_GR_PLAN" ("TYP_KAT", "NKOMP_INSTALACJI", "NR_KOMP_OBR") ;
--------------------------------------------------------
--  DDL for Index WG_INSTAL360
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_INSTAL360" ON "ST_PREM" ("NR_KOMP_INSTAL") ;
--------------------------------------------------------
--  DDL for Index WG_INSTAL361
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_INSTAL361" ON "RBG_MIN" ("NR_KOMP_INSTAL", "POW_SRED") ;
--------------------------------------------------------
--  DDL for Index WG_INSTAL_PL
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_INSTAL_PL" ON "KONF_DRUK_PL" ("NR_KONFIG", "NE_INST") ;
--------------------------------------------------------
--  DDL for Index WG_INST_GR_M489
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_INST_GR_M489" ON "GR_INST_POW" ("NR_KOMP_INST", "NR_KOMP_GR") ;
--------------------------------------------------------
--  DDL for Index WG_JEDN25
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_JEDN25" ON "JEDN" ("NAZ_JED") ;
--------------------------------------------------------
--  DDL for Index WG_JEDP_17
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_JEDP_17" ON "JEDNROW" ("JEDNOSTKA_PODSTAWOWA", "JED_POD", "NR_KOMP_JEDN") ;
--------------------------------------------------------
--  DDL for Index WG_JEDR17
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_JEDR17" ON "JEDNROW" ("JED_POD", "JEDNOSTKA_PODSTAWOWA", "NR_KOMP_JEDN") ;
--------------------------------------------------------
--  DDL for Index WG_JEZ_787
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_JEZ_787" ON "TLUM_NAPIS" ("NR_JEZYKA", "NR_WYRAZENIA") ;
--------------------------------------------------------
--  DDL for Index WG_K
--------------------------------------------------------

  CREATE INDEX "WG_K" ON "SZABLON" ("K") ;
--------------------------------------------------------
--  DDL for Index WG_K294
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_K294" ON "ZZSLOW" ("NR_KOMP") ;
--------------------------------------------------------
--  DDL for Index WG_KATEG825
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KATEG825" ON "STAN_MAG_O" ("KAT_WYM", "TYP_KAT", "KOD_POLOZ") ;
--------------------------------------------------------
--  DDL for Index WG_KAT_NR_PAR
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KAT_NR_PAR" ON "KATEG_PAR" ("NR_K_KAT", "NR_PARAM") ;
--------------------------------------------------------
--  DDL for Index WG_K_GRT540
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_K_GRT540" ON "RAP_SP_DZ" ("GR_TOWAR", "NR_KONTR", "DATA_WYST") ;
--------------------------------------------------------
--  DDL for Index WGKLI456
--------------------------------------------------------

  CREATE UNIQUE INDEX "WGKLI456" ON "KONTOSOB" ("NRKONTR", "NRKOLKONTR", "NRKOMKON") ;
--------------------------------------------------------
--  DDL for Index WG_KLI577
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KLI577" ON "ROZLICZ_ZAL" ("NR_KLI", "N_K_FAKT", "N_K_ZAL") ;
--------------------------------------------------------
--  DDL for Index WG_KLIENTA_382
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KLIENTA_382" ON "A_DANES" ("NR_KONTR", "KOD_KLIENTA", "KOD", "AKT") ;
--------------------------------------------------------
--  DDL for Index WG_KLIENTA_PAPIERY
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KLIENTA_PAPIERY" ON "PAPIERY" ("NK_KL", "DATA_ZAP", "CZAS_ZAP", "NK_ZAP") ;
--------------------------------------------------------
--  DDL for Index WG_KLIENTA_PAPIERYN
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KLIENTA_PAPIERYN" ON "PAPIERYN" ("NK_KL", "DATA_ZAP", "CZAS_ZAP", "NK_ZAP") ;
--------------------------------------------------------
--  DDL for Index WG_KLUCZA
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KLUCZA" ON "TRAN_ZAM" ("NR_KOL") ;
--------------------------------------------------------
--  DDL for Index WG_KLUCZA186
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KLUCZA186" ON "KLUCZE" ("KLUCZ") ;
--------------------------------------------------------
--  DDL for Index WG_KLUCZA188
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KLUCZA188" ON "GRUPYKL" ("NUMER_KLUCZA", "NUMER_GRUPY") ;
--------------------------------------------------------
--  DDL for Index WG_KLUCZA190
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KLUCZA190" ON "OPER_KL" ("NUMER_KLUCZA", "NR_OPER") ;
--------------------------------------------------------
--  DDL for Index WG_KLUCZA279
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KLUCZA279" ON "KON_UPR" ("NR_KLUCZA") ;
--------------------------------------------------------
--  DDL for Index WG_KLUCZA376
--------------------------------------------------------

  CREATE INDEX "WG_KLUCZA376" ON "A_TRANZ" ("NR_KOL") ;
--------------------------------------------------------
--  DDL for Index WG_KLUCZA647
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KLUCZA647" ON "NAP_KLUCZE" ("KLUCZ") ;
--------------------------------------------------------
--  DDL for Index WG_KOD128
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KOD128" ON "SL_ROKP" ("KOD_ROKP") ;
--------------------------------------------------------
--  DDL for Index WG_KOD_BRAKI_STR
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KOD_BRAKI_STR" ON "BRAK_STR" ("KOD_STR") ;
--------------------------------------------------------
--  DDL for Index WG_KOD_PASK62
--------------------------------------------------------

  CREATE INDEX "WG_KOD_PASK62" ON "L_WYC" ("NR_SER", "KOLEJN") ;
--------------------------------------------------------
--  DDL for Index WG_KODU
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KODU" ON "SL_TOW_PROD" ("TYP_WYROBU_DLA_KONTRAKTU", "KOD_STRUK") ;
--------------------------------------------------------
--  DDL for Index WG_KODU128
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KODU128" ON "TRAN_STR" ("KOD_DLA_KLI", "NUMER_KONTRAHENTA") ;
--------------------------------------------------------
--  DDL for Index WG_KODU214
--------------------------------------------------------

  CREATE INDEX "WG_KODU214" ON "OPWIEZY" ("KOD", "NAZWISKO", "NR_ODDZ") ;
--------------------------------------------------------
--  DDL for Index WG_KODU373
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KODU373" ON "A_SLOWO" ("KOD") ;
--------------------------------------------------------
--  DDL for Index WG_KODU375
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KODU375" ON "A_STORKE" ("TYP", "KOD") ;
--------------------------------------------------------
--  DDL for Index WG_KODU_423
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KODU_423" ON "KODY_NAL" ("NR_KLIENTA", "KOD_WZORU") ;
--------------------------------------------------------
--  DDL for Index WG_KODU443
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KODU443" ON "SL_STORKE" ("KOD") ;
--------------------------------------------------------
--  DDL for Index WG_KODU478
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KODU478" ON "KOD_JH" ("TYP", "KOD") ;
--------------------------------------------------------
--  DDL for Index WG_KODU502
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KODU502" ON "TYPY_FAKT_R" ("KOD_TYPU") ;
--------------------------------------------------------
--  DDL for Index WG_KODU526
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KODU526" ON "EFF_SLOW" ("KOD") ;
--------------------------------------------------------
--  DDL for Index WG_KODU565
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KODU565" ON "OPISY_ET" ("NUMER") ;
--------------------------------------------------------
--  DDL for Index WG_KODU567
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KODU567" ON "EKOLOR" ("WAR") ;
--------------------------------------------------------
--  DDL for Index WG_KODU7
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KODU7" ON "BUDSTR" ("KOD_STR", "NR_SKL") ;
--------------------------------------------------------
--  DDL for Index WG_KODU8
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KODU8" ON "STRUKTURY" ("KOD_STR") ;
--------------------------------------------------------
--  DDL for Index WG_KODU_MATER_688
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KODU_MATER_688" ON "RDANMATSZPR" ("NR_K_ZLEC", "NR_P_ZLEC", "KOD_MATER") ;
--------------------------------------------------------
--  DDL for Index WG_KODU_PAR80
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KODU_PAR80" ON "PARAM_T" ("KOD") ;
--------------------------------------------------------
--  DDL for Index WG_KODU_PARAM_TS
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KODU_PARAM_TS" ON "PARAM_TS" ("KOD") ;
--------------------------------------------------------
--  DDL for Index WG_KOL76
--------------------------------------------------------

  CREATE INDEX "WG_KOL76" ON "PARINST" ("KOLEJN") ;
--------------------------------------------------------
--  DDL for Index WG_KOLEJ462
--------------------------------------------------------

  CREATE INDEX "WG_KOLEJ462" ON "SPISW" ("NR_KOM_ZLEC", "NR_POZ", "NR_SZT", "KOLEJN") ;
--------------------------------------------------------
--  DDL for Index WG_KOLEJ62
--------------------------------------------------------

  CREATE INDEX "WG_KOLEJ62" ON "L_WYC" ("NR_KOM_ZLEC", "NR_POZ_ZLEC", "NR_SZT", "NR_WARST", "KOLEJN") ;
--------------------------------------------------------
--  DDL for Index WGKOLEJ82_P
--------------------------------------------------------

  CREATE INDEX "WGKOLEJ82_P" ON "L_WYC_TMP" ("NR_KOMP_ZLEC", "NR_POZ", "NR_SZT", "NR_WARST", "KOLEJN") ;
--------------------------------------------------------
--  DDL for Index WG_KOLEJN_PAR
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KOLEJN_PAR" ON "PAR_STRUKT" ("NR_KOL_PARAM") ;
--------------------------------------------------------
--  DDL for Index WG_KOL_GRP_114
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KOL_GRP_114" ON "OPAKOUT_H" ("NR_GRUPY_PAK", "NR_KOL_OPAK", "NR_K_PAKOW") ;
--------------------------------------------------------
--  DDL for Index WG_KOL_LOG_POZ
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KOL_LOG_POZ" ON "LOG_POL" ("TAB", "KOL") ;
--------------------------------------------------------
--  DDL for Index WG_KOL_LOG_TAB
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KOL_LOG_TAB" ON "LOG_TAB" ("TABELA") ;
--------------------------------------------------------
--  DDL for Index WG_KOLN11
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KOLN11" ON "SPISD" ("TYP_ZLEC", "NR_ZLEC", "NR_POZ", "KOL_DOD") ;
--------------------------------------------------------
--  DDL for Index WG_KOLN11_3
--------------------------------------------------------

  CREATE INDEX "WG_KOLN11_3" ON "RZLEC_DODATKI" ("TYP_ZLEC", "NR_ZLEC", "POZ_ZLEC", "KOL_DOD") ;
--------------------------------------------------------
--  DDL for Index WG_KOMBINACJI
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KOMBINACJI" ON "SL_TRANS" ("NR_ODDZ", "NR_DOST", "NR_DOST_TRAN") ;
--------------------------------------------------------
--  DDL for Index WG_KOMP391
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KOMP391" ON "PROTWYB" ("NR_KOMP") ;
--------------------------------------------------------
--  DDL for Index WG_KOMP392
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KOMP392" ON "PROTPOZ" ("NR_KOMP", "NR_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_KOMP402
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KOMP402" ON "LCENN_O" ("NR_KOMP") ;
--------------------------------------------------------
--  DDL for Index WG_KOMP537
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KOMP537" ON "WYM_SER" ("NR_KOMP") ;
--------------------------------------------------------
--  DDL for Index WG_KOMP820
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KOMP820" ON "SL_OBR_STAND" ("NR_KOMP") ;
--------------------------------------------------------
--  DDL for Index WG_KOMP_POZ16
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KOMP_POZ16" ON "POZDOK" ("ID_POZ_FAK", "NR_KOMP_DOK", "NR_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_KOM_ZLEC
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KOM_ZLEC" ON "SURZAM" ("NR_KOMP_ZLEC", "NR_KAT", "INDEKS", "NR_MAG") ;
--------------------------------------------------------
--  DDL for Index WG_KON_111
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KON_111" ON "RAP_ZYSK" ("NR_NALICZ", "SKROT_KON", "NR_KON", "NR_SPRZED", "POZ_SPRZED", "LP_114") ;
--------------------------------------------------------
--  DDL for Index WG_KON29
--------------------------------------------------------

  CREATE INDEX "WG_KON29" ON "REJVAT" ("NR_KON") ;
--------------------------------------------------------
--  DDL for Index WG_KON5
--------------------------------------------------------

  CREATE INDEX "WG_KON5" ON "DOSTAWY" ("NR_KON") ;
--------------------------------------------------------
--  DDL for Index WG_KON9
--------------------------------------------------------

  CREATE INDEX "WG_KON9" ON "ZAMOW" ("NR_KON") ;
--------------------------------------------------------
--  DDL for Index WG_KONFIG
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KONFIG" ON "LDRUKLOK" ("NR_KONFIG", "NR_STACJI", "NAZWA_STACJI", "NAZWA_OPERAT", "NR_WYDR") ;
--------------------------------------------------------
--  DDL for Index WG_KONFW
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KONFW" ON "KONFIGWYDR" ("NR_KONFW") ;
--------------------------------------------------------
--  DDL for Index WG_KONTR198
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KONTR198" ON "KTRWGR" ("NR_KONTR", "NR_KOMP_GR") ;
--------------------------------------------------------
--  DDL for Index WG_KONTR214
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KONTR214" ON "OPWIEZY" ("NR_OPER", "NR_KOMP_GR", "NR_ODDZ") ;
--------------------------------------------------------
--  DDL for Index WG_KONTR278
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KONTR278" ON "KTRWNIOSKI_ODD" ("NR_KONTR", "DATA_WN", "CZAS_WN", "NR_WNIOSKU") ;
--------------------------------------------------------
--  DDL for Index WG_KONTR30
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KONTR30" ON "KONTRAKT" ("NR_KON", "NR_KOMP_KONTR") ;
--------------------------------------------------------
--  DDL for Index WG_KONTR30_18
--------------------------------------------------------

  CREATE INDEX "WG_KONTR30_18" ON "RKONTRAKT" ("NR_KON") ;
--------------------------------------------------------
--  DDL for Index WG_KONTR_42
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KONTR_42" ON "KP_KON" ("NK_PRZEC", "NK_KONTR") ;
--------------------------------------------------------
--  DDL for Index WG_KONTR570
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KONTR570" ON "LOGDAN" ("NR_KONTR", "RODZ_DAN", "NR_ODDZ") ;
--------------------------------------------------------
--  DDL for Index WG_KONTR604
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KONTR604" ON "ST_KONR" ("NK_KONTR") ;
--------------------------------------------------------
--  DDL for Index WG_KONTR727
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KONTR727" ON "CCEN00" ("NK_KONTR", "NK_CENNIKA") ;
--------------------------------------------------------
--  DDL for Index WG_KONTR727O
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KONTR727O" ON "CEN00_FGT" ("NKOMP_KONTR", "NKOMP_CEN") ;
--------------------------------------------------------
--  DDL for Index WG_KONTR731
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KONTR731" ON "CEN00" ("NR_KONTR", "NK_CENNIKA") ;
--------------------------------------------------------
--  DDL for Index WG_KONTR_8
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KONTR_8" ON "TRAN_IND" ("NK_KONTR", "NR_SZBL", "NR_SKL") ;
--------------------------------------------------------
--  DDL for Index WG_KONTRAH_22
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KONTRAH_22" ON "KTH_ROZRACH" ("NR_KONTRAH", "NR_KOMP_FAKT", "DATA_ZAPL", "NR_DOWODU_KS", "POZ_DOW_KS", "IDENT_ROZR") ;
--------------------------------------------------------
--  DDL for Index WG_KONTRAH_310
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KONTRAH_310" ON "RAP_MIES_GR_KONTRAH" ("NR_KONTRAH", "ROK", "NR_MIES") ;
--------------------------------------------------------
--  DDL for Index WG_KONTRAH460
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KONTRAH460" ON "CECHY_USER" ("NR_KONTRAH", "NR_CECHY") ;
--------------------------------------------------------
--  DDL for Index WG_KONTRAHENTA605
--------------------------------------------------------

  CREATE INDEX "WG_KONTRAHENTA605" ON "ST_KONTR_STOJ" ("NK_KONTR", "NK_STOJ", "STATUS", "DATA_WYJ") ;
--------------------------------------------------------
--  DDL for Index WG_KONTRAKTU_41
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KONTRAKTU_41" ON "KP_WYB" ("NK_PRZEC", "NK_KONTR") ;
--------------------------------------------------------
--  DDL for Index WG_KONTR_CEN00_T7
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KONTR_CEN00_T7" ON "CEN00_T7" ("NKOMP_KONTR", "NKOMP_CEN") ;
--------------------------------------------------------
--  DDL for Index WG_KONTR_FK6_DANE2
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KONTR_FK6_DANE2" ON "FK6_DANE2" ("NK_KONTR", "ROK", "OKRES", "NK_ZAP") ;
--------------------------------------------------------
--  DDL for Index WG_KONTR_I48
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KONTR_I48" ON "CP_KONT" ("NK_PRZEC", "NK_KONTR") ;
--------------------------------------------------------
--  DDL for Index WG_KONTR_TRAN_IND
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KONTR_TRAN_IND" ON "TRAN_IND0" ("NK_KONTR", "NR_SZABL") ;
--------------------------------------------------------
--  DDL for Index WG_KONTR_WYB_46
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KONTR_WYB_46" ON "KP_ROB" ("NK_PRZEC", "NK_KONTR") ;
--------------------------------------------------------
--  DDL for Index WG_KRAJU_1
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KRAJU_1" ON "KRAJ_TRANS" ("NAZWA_KRAJU_1") ;
--------------------------------------------------------
--  DDL for Index WG_KRAJU631
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_KRAJU631" ON "UE_NIP" ("KRAJ", "WERSJA") ;
--------------------------------------------------------
--  DDL for Index WG_KWOTY279
--------------------------------------------------------

  CREATE INDEX "WG_KWOTY279" ON "KON_UPR" ("DO_KWOTY") ;
--------------------------------------------------------
--  DDL for Index WG_LIMITU205
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_LIMITU205" ON "CEN_LIM_KRED" ("LIMIT", "DO_LIM", "POW_LIM", "NR_KOL") ;
--------------------------------------------------------
--  DDL for Index WG_LIMITU216
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_LIMITU216" ON "KTRWARUNKI_KREDYT" ("NAZWA_KLUCZA", "LIMIT_ZMIANA", "TERMIN_PLATNOSCI", "NR_KOL") ;
--------------------------------------------------------
--  DDL for Index WG_LISTY_561
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_LISTY_561" ON "STOJ_LACZ" ("NR_LISTY", "NR_STOJAKA", "NR_ZLECENIA", "NR_STOJ_W_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_LISTY_62
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_LISTY_62" ON "L_WYC" ("NR_LISTY", "NR_KOM_ZLEC", "NR_POZ_ZLEC", "NR_SZT", "NR_WARST", "NR_INST") ;
--------------------------------------------------------
--  DDL for Index WG_LISTY_63
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_LISTY_63" ON "PAMLIST_OZNACZ" ("NR_LISTY", "NR_KOL_STOJ") ;
--------------------------------------------------------
--  DDL for Index WG__LISTY_KL
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG__LISTY_KL" ON "STOJ_LACZ" ("NR_LISTY", "NR_KLIENTA", "NR_STOJAKA", "NR_ZLECENIA", "NR_STOJ_W_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_LOG_ODCZ1
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_LOG_ODCZ1" ON "LOG_CZYTNIK" ("DATA", "CZAS", "NR_SZYBY", "NR_ZAPISU") ;
--------------------------------------------------------
--  DDL for Index WG_LP
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_LP" ON "TRAN_POZ" ("NR_KOL", "NR_POZ_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_LP377
--------------------------------------------------------

  CREATE INDEX "WG_LP377" ON "A_TRANP" ("NR_KOL", "NR_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_LP_672
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_LP_672" ON "OKNA_DEK" ("IDENT", "LP") ;
--------------------------------------------------------
--  DDL for Index WG_M477
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_M477" ON "ATRYB_DOD" ("NR_ZNACZNIKA") ;
--------------------------------------------------------
--  DDL for Index WG_MAG
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_MAG" ON "IFS_ANAL" ("NR_MAG", "NR_ANAL") ;
--------------------------------------------------------
--  DDL for Index WG_MAG_297
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_MAG_297" ON "OSTATNIE_ZAMKN" ("NR_MAG", "NR_OKRESU") ;
--------------------------------------------------------
--  DDL for Index WG_MAG_35
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_MAG_35" ON "AITROBSTOJWG" ("NR_MAG", "NR_OKR", "NR_KOL_ST", "NR_KOMP_STOJ") ;
--------------------------------------------------------
--  DDL for Index WG_MAT685
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_MAT685" ON "EDI_MAT" ("MAT_KLIENTA") ;
--------------------------------------------------------
--  DDL for Index WG_MATER_687
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_MATER_687" ON "RDANMATSZPR" ("NR_K_ZLEC", "NR_P_ZLEC", "NR_MATER", "KOD_MATER") ;
--------------------------------------------------------
--  DDL for Index WG_NAD202
--------------------------------------------------------

  CREATE INDEX "WG_NAD202" ON "OPADRESY" ("NAD_KOD", "NAD_DATA", "NAD_CZAS") ;
--------------------------------------------------------
--  DDL for Index WG_NARZUTU_I53
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NARZUTU_I53" ON "CP_NARZ" ("NK_PRZEC", "NK_NARZ", "TYP") ;
--------------------------------------------------------
--  DDL for Index WG_NAZ116
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NAZ116" ON "WOJEWODZTWA" ("WOJ") ;
--------------------------------------------------------
--  DDL for Index WG_NAZ18
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NAZ18" ON "STVAT" ("NAZ_VAT") ;
--------------------------------------------------------
--  DDL for Index WG_NAZ19
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NAZ19" ON "WALUTA" ("WALUTA", "NR_TABELI") ;
--------------------------------------------------------
--  DDL for Index WG_NAZ196
--------------------------------------------------------

  CREATE INDEX "WG_NAZ196" ON "KTRGRUPY" ("NAZ_GR") ;
--------------------------------------------------------
--  DDL for Index WG_NAZ212
--------------------------------------------------------

  CREATE INDEX "WG_NAZ212" ON "CENT_POPER" ("NAZWISKO", "KOD") ;
--------------------------------------------------------
--  DDL for Index WG_NAZ213
--------------------------------------------------------

  CREATE INDEX "WG_NAZ213" ON "OPGRUPY" ("NR_OPER", "NR_ODDZ", "NAZ_GR") ;
--------------------------------------------------------
--  DDL for Index WG_NAZ245
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NAZ245" ON "LISTA_DZIAL" ("NAZ_DZ", "NR_KOMP") ;
--------------------------------------------------------
--  DDL for Index WG_NAZ4
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NAZ4" ON "BANKI" ("NAZ_BANKU") ;
--------------------------------------------------------
--  DDL for Index WG_NAZ6
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NAZ6" ON "TRASY" ("NAZ_TRASY") ;
--------------------------------------------------------
--  DDL for Index WG_NAZ_KLI8
--------------------------------------------------------

  CREATE INDEX "WG_NAZ_KLI8" ON "STRUKTURY" ("NAZ_DLA_KLI") ;
--------------------------------------------------------
--  DDL for Index WG_NAZ_SKR156
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NAZ_SKR156" ON "CENT_KLIENT" ("SKROT_K", "NR_KON") ;
--------------------------------------------------------
--  DDL for Index WG_NAZ_SKR3
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NAZ_SKR3" ON "KLIENT" ("SKROT_K", "NR_KON") ;
--------------------------------------------------------
--  DDL for Index WGNAZW456
--------------------------------------------------------

  CREATE INDEX "WGNAZW456" ON "KONTOSOB" ("NAZ", "IMIE") ;
--------------------------------------------------------
--  DDL for Index WG_NAZW666
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NAZW666" ON "DANE_ADR" ("NAZWISKO", "OPERATOR") ;
--------------------------------------------------------
--  DDL for Index WG_NAZWISK214
--------------------------------------------------------

  CREATE INDEX "WG_NAZWISK214" ON "OPWIEZY" ("NAZWISKO", "NR_ODDZ", "KOD") ;
--------------------------------------------------------
--  DDL for Index WG_NAZWY
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NAZWY" ON "SZABLON" ("POLE") ;
--------------------------------------------------------
--  DDL for Index WG_NAZWY129
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NAZWY129" ON "TRAN_KONTR" ("KLIENT_C7_4") ;
--------------------------------------------------------
--  DDL for Index WG_NAZWY186
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NAZWY186" ON "KLUCZE" ("NAZWA") ;
--------------------------------------------------------
--  DDL for Index WG_NAZWY187
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NAZWY187" ON "GRUPY" ("NAZWA_GRUPY") ;
--------------------------------------------------------
--  DDL for Index WG_NAZWY24
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NAZWY24" ON "FIRMA" ("NAZ_FIRMY") ;
--------------------------------------------------------
--  DDL for Index WG_NAZWY454
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NAZWY454" ON "WIEK_DLUG" ("NUMER") ;
--------------------------------------------------------
--  DDL for Index WG_NAZWY516
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NAZWY516" ON "FAKT_BUF" ("SYMB") ;
--------------------------------------------------------
--  DDL for Index WG_NAZWY567
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NAZWY567" ON "EKOLOR" ("NAZ") ;
--------------------------------------------------------
--  DDL for Index WG_NAZWY658
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NAZWY658" ON "KODYPOL" ("SYMBOL_KODU") ;
--------------------------------------------------------
--  DDL for Index WG_NAZWY683
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NAZWY683" ON "EDI_SLOW" ("NAZ_EDI") ;
--------------------------------------------------------
--  DDL for Index WG_NAZWY763
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NAZWY763" ON "CRM_LISTA" ("TYP", "RODZAJ", "NAZWA") ;
--------------------------------------------------------
--  DDL for Index WG_NIP156
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NIP156" ON "CENT_KLIENT" ("NIP", "NR_KON") ;
--------------------------------------------------------
--  DDL for Index WG_NIP207
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NIP207" ON "KTRKREDYT" ("NUMER_KOMPUTEROWY") ;
--------------------------------------------------------
--  DDL for Index WG_NIP3
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NIP3" ON "KLIENT" ("NIP", "NR_KON") ;
--------------------------------------------------------
--  DDL for Index WG_NIP509
--------------------------------------------------------

  CREATE INDEX "WG_NIP509" ON "NAL_FK" ("NIP", "SYM_FAKT", "KOD_KONTR") ;
--------------------------------------------------------
--  DDL for Index WG_NIP510
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NIP510" ON "KON_FK" ("NIP") ;
--------------------------------------------------------
--  DDL for Index WG_NIP526
--------------------------------------------------------

  CREATE INDEX "WG_NIP526" ON "EFF_SLOW" ("NIP") ;
--------------------------------------------------------
--  DDL for Index WG_NK438R
--------------------------------------------------------

  CREATE INDEX "WG_NK438R" ON "RZMIANY" ("NKOMP_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_NK844
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NK844" ON "ARK_INW_POZ" ("NR_MAG", "OKRES", "INDEKS", "NR_KOMP") ;
--------------------------------------------------------
--  DDL for Index WG_NKAT728O
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKAT728O" ON "CEN01_FGT" ("NKOMP_CEN", "NR_KAT") ;
--------------------------------------------------------
--  DDL for Index WG_NKAT732
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKAT732" ON "CEN01" ("NK_CENNIKA", "NKAT_RAMKA", "NKAT_GAZ", "NKAT_RAMKA2", "NKAT_GAZ2") ;
--------------------------------------------------------
--  DDL for Index WG_NKDOK60
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKDOK60" ON "FGT_FAK" ("NK_DOK") ;
--------------------------------------------------------
--  DDL for Index WG_NKDOK60_40
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKDOK60_40" ON "FK2_FAK" ("NK_DOK") ;
--------------------------------------------------------
--  DDL for Index WG_NK_M82
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NK_M82" ON "KATEG_WYM_O" ("NK_WYM") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP101
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP101" ON "ZLEC_PAM" ("NK_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP_135
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP_135" ON "ZLEC_PAM" ("NK_OPER", "NK_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP_15
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP_15" ON "KONTR_PAM" ("NK_OP", "NK_KONTR") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP470
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP470" ON "A_BUFOR" ("LICZNIK") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP581
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP581" ON "REKSLO2" ("NK_ZAP", "TYP_ZAP") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP584
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP584" ON "ZLEC_ZM" ("NK_ZM") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP602
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP602" ON "ST_RAP" ("NK_RAP") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP680
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP680" ON "DAN_FK5" ("NKOMP_KONTRAHENTA") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP725
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP725" ON "CECHY_PAR2" ("NKOMP_CECHY", "NR_PAR") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP727
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP727" ON "CCEN00" ("NK_CENNIKA") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP727O
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP727O" ON "CEN00_FGT" ("NKOMP_CEN") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP731
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP731" ON "CEN00" ("NK_CENNIKA") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP732
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP732" ON "CEN01" ("NK_WZORCA") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP762
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP762" ON "CRM_WIA" ("NKOMP_KONTR", "DATA", "CZAS", "NKOMP_WIAD", "NR_ODD") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP764
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP764" ON "CRM_BLOB" ("NKOMP_WIAD", "NR_ODD") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP768
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP768" ON "CRM_PAR" ("NKOMP_KONTR", "NKOMP_WIAD", "NR_ODD", "TYP_ZAPISU") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP770
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP770" ON "CRM_STOJ" ("NKOMP_KONTR", "NKOMP_WIAD", "NR_ODD", "NUMER_ZAPISU", "NKOMP_STOJAKA") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP800
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP800" ON "GR_PLAN" ("NKOMP_GRUPY") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP_CEN00_T7
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP_CEN00_T7" ON "CEN00_T7" ("NKOMP_CEN") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP_CRM_ZDARZENIE
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP_CRM_ZDARZENIE" ON "CRM_ZDARZENIE" ("NK_KONTR", "NK_ZD", "NK_ZAP") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP_CRS_DANE
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP_CRS_DANE" ON "CRS_DANE" ("NK_KONTR") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP_FK6_DANE6
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP_FK6_DANE6" ON "FK6_DANE7" ("NK_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP_PAPIERY_N1
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP_PAPIERY_N1" ON "PAPIERYN1" ("NK_ZLEC", "ID_POZ", "NR_W") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP_RZLEC_TYPP
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP_RZLEC_TYPP" ON "RDANET" ("NK_ZLEC", "NR_POZ", "TYP") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP_SL1_ROKP
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP_SL1_ROKP" ON "SL1_ROKP" ("NK_ROKP") ;
--------------------------------------------------------
--  DDL for Index WG_NKOMP_TRAN_IND1
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKOMP_TRAN_IND1" ON "TRAN_IND1" ("NK_KONTR", "NR_SZABL", "SKLADOWA") ;
--------------------------------------------------------
--  DDL for Index WG_NKWYMM70
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NKWYMM70" ON "ODPADY" ("NK_WYM", "NR_ODP") ;
--------------------------------------------------------
--  DDL for Index WG_NPOLA460
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NPOLA460" ON "NR_OZNAK" ("NR_KOL", "NR_KOMP") ;
--------------------------------------------------------
--  DDL for Index WG_NR
--------------------------------------------------------

  CREATE INDEX "WG_NR" ON "SZABLON" ("NR") ;
--------------------------------------------------------
--  DDL for Index WG_NR11
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR11" ON "SPISD" ("NR_KOM_ZLEC", "NR_POZ", "KOL_DOD") ;
--------------------------------------------------------
--  DDL for Index WG_NR_112
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_112" ON "NAL_RAP_ZYSK" ("NR_NALICZ") ;
--------------------------------------------------------
--  DDL for Index WG_NR_147
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_147" ON "PELKONTR" ("NR_KON") ;
--------------------------------------------------------
--  DDL for Index WG_NR150
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR150" ON "KODY_NAZW" ("NR_POZ_W_KOD", "NUMER") ;
--------------------------------------------------------
--  DDL for Index WG_NR154
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR154" ON "SLOW_TAB" ("NR") ;
--------------------------------------------------------
--  DDL for Index WG_NR156
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR156" ON "CENT_KLIENT" ("RODZ_KON", "NR_KON") ;
--------------------------------------------------------
--  DDL for Index WG_NR196
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR196" ON "KTRGRUPY" ("NR_KOMP_GR") ;
--------------------------------------------------------
--  DDL for Index WG_NR198
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR198" ON "KTRWGR" ("NR_KOMP_GR", "NR_KONTR") ;
--------------------------------------------------------
--  DDL for Index WG_NR_199
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_199" ON "ZLEC_UWAGI" ("NUMER_KOMPUTEROWY") ;
--------------------------------------------------------
--  DDL for Index WG_NR_205
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_205" ON "CEN_LIM_KRED" ("POZIOM", "LIMIT", "NR_KOL") ;
--------------------------------------------------------
--  DDL for Index WG_NR213
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR213" ON "OPGRUPY" ("NR_KOMP_GR", "NR_OPER", "NR_ODDZ") ;
--------------------------------------------------------
--  DDL for Index WG_NR214
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR214" ON "OPWIEZY" ("NR_KOMP_GR", "NR_OPER", "NR_ODDZ") ;
--------------------------------------------------------
--  DDL for Index WG_NR235
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR235" ON "C_DOST_UWAGI" ("NR_KONTR") ;
--------------------------------------------------------
--  DDL for Index WG_NR237
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR237" ON "NIEOBEC" ("NR_ODDZ", "NR_PRAC", "NR_KOMP_NIEOB") ;
--------------------------------------------------------
--  DDL for Index WG_NR239
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR239" ON "SLOW_POST" ("NR_POST") ;
--------------------------------------------------------
--  DDL for Index WG_NR241
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR241" ON "DANE_WYK" ("NR_KOMP_INST", "NR_KOMP_ZM", "NR_BRYGADY") ;
--------------------------------------------------------
--  DDL for Index WG_NR244
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR244" ON "LISTA_MPK" ("NR_KOMP") ;
--------------------------------------------------------
--  DDL for Index WG_NR245
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR245" ON "LISTA_DZIAL" ("NR_KOMP") ;
--------------------------------------------------------
--  DDL for Index WG_NR246
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR246" ON "GR_KOSZT" ("NR_KOMP_GR") ;
--------------------------------------------------------
--  DDL for Index WG_NR247
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR247" ON "KOSZT_ST" ("NR_GR", "NR_OKRESU") ;
--------------------------------------------------------
--  DDL for Index WG_NR_250
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_250" ON "SLOW_ATEST" ("NR_ATESTU") ;
--------------------------------------------------------
--  DDL for Index WG_NR_259
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_259" ON "REJ_POZ_REKL" ("NR_ODDZ", "NR_KOMP_REKL") ;
--------------------------------------------------------
--  DDL for Index WG_NR264
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR264" ON "ANALITYKI" ("NR_MAG", "NR_ANAL") ;
--------------------------------------------------------
--  DDL for Index WG_NR276
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR276" ON "LOGKRED" ("NR_KONTR", "TYP") ;
--------------------------------------------------------
--  DDL for Index WG_NR280
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR280" ON "KON_UWAGI_ODD" ("NR_KONTR") ;
--------------------------------------------------------
--  DDL for Index WG_NR281
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR281" ON "KON_UWAGI_CENT" ("NR_KONTR") ;
--------------------------------------------------------
--  DDL for Index WG_NR3
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR3" ON "KLIENT" ("RODZ_KON", "NR_KON") ;
--------------------------------------------------------
--  DDL for Index WG_NR30
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR30" ON "KONTRAKT" ("NR_KOMP_KONTR") ;
--------------------------------------------------------
--  DDL for Index WG_NR30_18
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR30_18" ON "RKONTRAKT" ("NK_KOMP_KONTR") ;
--------------------------------------------------------
--  DDL for Index WG_NR_308
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_308" ON "ZAM_UWAGI" ("NUMER_KOMPUTEROWY") ;
--------------------------------------------------------
--  DDL for Index WG_NR362
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR362" ON "PRAC_WYK" ("NR_KOMP_INST", "NR_KOMP_ZM", "NR_BRYGADY", "NR_PRAC", "NK_ZAP") ;
--------------------------------------------------------
--  DDL for Index WG_NR370
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR370" ON "SLOW_BRYG" ("NR_KOMP_INST", "NR_KOMP_B") ;
--------------------------------------------------------
--  DDL for Index WG_NR_391
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_391" ON "PROTWYB" ("NR_PROT") ;
--------------------------------------------------------
--  DDL for Index WG_NR392
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR392" ON "PROTPOZ" ("NR_PROT", "NR_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_NR4
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR4" ON "BANKI" ("NR_BANKU") ;
--------------------------------------------------------
--  DDL for Index WG_NR_426
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_426" ON "AUDYT" ("NUM_KOL", "DATA", "CZAS") ;
--------------------------------------------------------
--  DDL for Index WG_NR459
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR459" ON "WNIOSKI_OBS" ("NR_WNIOSKU") ;
--------------------------------------------------------
--  DDL for Index WG_NR_472
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_472" ON "MON_STRATY" ("NR_KOMP_POBR") ;
--------------------------------------------------------
--  DDL for Index WG_NR_495
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_495" ON "PAML1" ("NR_LISTY") ;
--------------------------------------------------------
--  DDL for Index WG_NR5
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR5" ON "DOSTAWY" ("NR_DOST") ;
--------------------------------------------------------
--  DDL for Index WG_NR_603
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_603" ON "SLPAROB" ("NR_K_P_OBR") ;
--------------------------------------------------------
--  DDL for Index WG_NR_657
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_657" ON "KODSTER" ("NR_KODU") ;
--------------------------------------------------------
--  DDL for Index WG_NR_660
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_660" ON "PAMLIST" ("NR_LISTY", "NR_K_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_NR747
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR747" ON "ZLEC_TYP" ("NR_KOMP_ZLEC", "NR_POZ", "TYP") ;
--------------------------------------------------------
--  DDL for Index WG_NR748R
--------------------------------------------------------

  CREATE INDEX "WG_NR748R" ON "RZLEC_TYP" ("NK_ZLEC", "POZ_ZLEC", "TYP") ;
--------------------------------------------------------
--  DDL for Index WG_NR76
--------------------------------------------------------

  CREATE INDEX "WG_NR76" ON "PARINST" ("NR_INST") ;
--------------------------------------------------------
--  DDL for Index WG_NR_787
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_787" ON "TLUM_NAPIS" ("NR_WYRAZENIA", "NR_JEZYKA") ;
--------------------------------------------------------
--  DDL for Index WG_NR_ALFAK
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_ALFAK" ON "ALFAK_KONTRAHENT" ("NR_ALFAK") ;
--------------------------------------------------------
--  DDL for Index WG_NRB371
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NRB371" ON "BRYG_POZ" ("NR_KOMP_B", "NR_PRAC") ;
--------------------------------------------------------
--  DDL for Index WG_NR_DOK22
--------------------------------------------------------

  CREATE INDEX "WG_NR_DOK22" ON "FAKPOZ" ("TYP_DOKS", "NR_DOKS", "NR_POZ", "LP_DOD") ;
--------------------------------------------------------
--  DDL for Index WG_NR_DOSTAWCY
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_DOSTAWCY" ON "SL_TRANS" ("NR_DOST", "KOD_USL", "NR_DOST_TRAN", "NR_ODDZ") ;
--------------------------------------------------------
--  DDL for Index WG_NR_FAKT148
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_FAKT148" ON "PELPLAT" ("NR_FAKT") ;
--------------------------------------------------------
--  DDL for Index WG_NR_FAKT248
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_FAKT248" ON "FAKTEXT" ("NR_FAKT") ;
--------------------------------------------------------
--  DDL for Index WG_NR_FAKT_44
--------------------------------------------------------

  CREATE INDEX "WG_NR_FAKT_44" ON "REJ_W_FAKT" ("TYP_DOKUM", "NUMER_DOKUM", "ROK", "MC") ;
--------------------------------------------------------
--  DDL for Index WG_NR_GR_116
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_GR_116" ON "OPAKOUT_G" ("NR_K_GRP") ;
--------------------------------------------------------
--  DDL for Index WG_NR_GR_117
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_GR_117" ON "OPAKOUT_Z" ("NR_K_GR", "NR") ;
--------------------------------------------------------
--  DDL for Index WG_NRGR890
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NRGR890" ON "GR_INST_DLA_OBR" ("NR_KOMP_GR", "NR_KOMP_OBR", "NR_KOMP_INST") ;
--------------------------------------------------------
--  DDL for Index WG_NRIND537
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NRIND537" ON "WYM_SER" ("NR_IND", "NR_KOMP") ;
--------------------------------------------------------
--  DDL for Index WG_NR_INST76
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_INST76" ON "PARINST" ("NR_KOMP_INST") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KAT
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KAT" ON "KATEGORIE" ("NR_K_KAT") ;
--------------------------------------------------------
--  DDL for Index WG_NRKATM70
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NRKATM70" ON "ODPADY" ("NR_KAT", "AKT", "NR_ODP") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KLI_116
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KLI_116" ON "OPAKOUT_G" ("NR_1_KLIENTA", "NR_K_GRP") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KLI_117
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KLI_117" ON "OPAKOUT_Z" ("NR_KLI", "NR", "NR_K_GR") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KLI9
--------------------------------------------------------

  CREATE INDEX "WG_NR_KLI9" ON "ZAMOW" ("NR_ZLEC_KLI") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KLI9_1
--------------------------------------------------------

  CREATE INDEX "WG_NR_KLI9_1" ON "RPZLEC" ("NR_ZLEC_KL") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KODU658
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KODU658" ON "KODYPOL" ("NR_KODU") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KOL48
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KOL48" ON "ZMIANY" ("NR_KOMP_INST", "NR_KOMP_ZM") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KOM156
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KOM156" ON "CENT_KLIENT" ("NR_KON") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KOM228
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KOM228" ON "OFERTY_NAG" ("NR_KOM_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KOM441
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KOM441" ON "OFERTY_NAGK" ("NR_KOM_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KOM62
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KOM62" ON "L_WYC" ("NR_KOM_ZLEC", "NR_POZ_ZLEC", "NR_SZT", "NR_WARST", "NR_INST") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KOM62_P
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KOM62_P" ON "L_WYC_TMP" ("NR_KOMP_ZLEC", "NR_POZ", "NR_SZT", "NR_WARST", "NR_KOMP_INST") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KOM7
--------------------------------------------------------

  CREATE INDEX "WG_NR_KOM7" ON "BUDSTR" ("NR_KOM_STR") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KOM9
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KOM9" ON "ZAMOW" ("NR_KOM_ZLEC" DESC) ;
--------------------------------------------------------
--  DDL for Index WG_NR_KOM9_1
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KOM9_1" ON "RPZLEC" ("NKOMP" DESC) ;
--------------------------------------------------------
--  DDL for Index WG_NR_KOM_B
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KOM_B" ON "NALBIL" ("NR_KOMPB", "NR_KOMP_KART") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KOM_INST
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KOM_INST" ON "KALINST" ("NR_KOMP_INST", "DZIEN") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KOMP10
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KOMP10" ON "SPISZ" ("NR_KOM_ZLEC", "NR_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KOMP10_2
--------------------------------------------------------

  CREATE INDEX "WG_NR_KOMP10_2" ON "RPZLEC_POZ" ("NR_KOM_ZLEC", "NR_POZ_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KOMP16
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KOMP16" ON "POZDOK" ("NR_KOMP_DOK", "NR_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KOMP21
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KOMP21" ON "FAKNAGL" ("NR_KOMP") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KOMP236
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KOMP236" ON "LISTA_PRACOW" ("NR_ODDZ", "NR_PRAC") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KOMP289
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KOMP289" ON "OFERTY_POZ" ("NR_KOMP_OF", "NR_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KOMP29
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KOMP29" ON "REJVAT" ("NR_KOMP_REJ") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KOMP_44
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KOMP_44" ON "REJ_W_FAKT" ("NR_KOMP") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KOMP442
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KOMP442" ON "OFERTY_POZK" ("NR_KOMP_OF", "NR_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KOMP550
--------------------------------------------------------

  CREATE INDEX "WG_NR_KOMP550" ON "KOPHARMON" ("NR_KOMP_INST", "TYP_HARM", "NR_KOMP_ZM", "KOL_NA_ZM") ;
--------------------------------------------------------
--  DDL for Index WG_NRKOMP573
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NRKOMP573" ON "ZAMKZLEC" ("NR_KOMP_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KOMP73
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KOMP73" ON "STOJSPED" ("NR_KOMP_STOJ") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KOMP79
--------------------------------------------------------

  CREATE INDEX "WG_NR_KOMP79" ON "HARMON" ("NR_KOMP_INST", "TYP_HARM", "NR_KOMP_ZM", "KOL_NA_ZM") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KOMP_EGRUPYTOW
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KOMP_EGRUPYTOW" ON "ECUTTER_GRUPYTOW" ("NR_KOMP") ;
--------------------------------------------------------
--  DDL for Index WG__NR_KOMPZ585
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG__NR_KOMPZ585" ON "RYSUNKI" ("NK_RYS") ;
--------------------------------------------------------
--  DDL for Index WG__NR_KOMPZ585R
--------------------------------------------------------

  CREATE INDEX "WG__NR_KOMPZ585R" ON "RRYSUNKI" ("NK_RYS") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KOMP_ZL_STATUSY_ZLEC_LOG
--------------------------------------------------------

  CREATE INDEX "WG_NR_KOMP_ZL_STATUSY_ZLEC_LOG" ON "STATUSY_ZLEC_LOG" ("NR_KOMP_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KONF_PAM_E
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KONF_PAM_E" ON "PAM_E_NAGL" ("RODZ_KONF", "NR_KONF") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KONTR30
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KONTR30" ON "KONTRAKT" ("NR_KON", "NR_KONTR", "NR_KOMP_KONTR") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KONTR30_18
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KONTR30_18" ON "RKONTRAKT" ("NR_KON", "NR_KONTR", "NK_KOMP_KONTR") ;
--------------------------------------------------------
--  DDL for Index WG_NR_K_PAK115
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_K_PAK115" ON "OPAKOUT_P" ("NR_K_PAKOW", "NR_POZ_OPAK") ;
--------------------------------------------------------
--  DDL for Index WG_NR_KSZT_DOP1
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_KSZT_DOP1" ON "KSZT_DOP1" ("NR_KAT_KSZTALTOW", "NR_KSZTALTU", "NR_DOPLATY") ;
--------------------------------------------------------
--  DDL for Index WG_NR_LLST
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_LLST" ON "L_PAMLIST" ("NR_LISTY") ;
--------------------------------------------------------
--  DDL for Index WG_NR_LT2
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_LT2" ON "ODDTRAN" ("K1", "K2", "K5", "K6") ;
--------------------------------------------------------
--  DDL for Index WG_NR_M455
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_M455" ON "GR_INST" ("NR_GR") ;
--------------------------------------------------------
--  DDL for Index WG_NR_MAG_ZM906
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_MAG_ZM906" ON "REJ_POB_SUR" ("NR_KOMP_ZM", "NR_MAG", "INDEKS", "FLAG", "NK") ;
--------------------------------------------------------
--  DDL for Index WG_NROBR890
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NROBR890" ON "GR_INST_DLA_OBR" ("NR_KOMP_OBR", "NR_KOMP_INST", "NR_KOMP_GR") ;
--------------------------------------------------------
--  DDL for Index WG_NR_OBR_WSP_OBR
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_OBR_WSP_OBR" ON "WSP_OBR" ("NR_KOMP_OBR", "TYP_KAT_SZKLA", "NR_KOMP_INST") ;
--------------------------------------------------------
--  DDL for Index WG_NR_OP805
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_OP805" ON "FACIMILE" ("NR_OP") ;
--------------------------------------------------------
--  DDL for Index WG_NR_OPAK114
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_OPAK114" ON "OPAKOUT_H" ("NR_K_PAKOW") ;
--------------------------------------------------------
--  DDL for Index WG_NR_OPAK_119
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_OPAK_119" ON "OPAKOUT_PK" ("NR_K_OPAK", "NR_PIETRA", "NR_RZEDU") ;
--------------------------------------------------------
--  DDL for Index WG_NROPT410
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NROPT410" ON "OPT_NR" ("NR_OPT") ;
--------------------------------------------------------
--  DDL for Index WG_NROPT411
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NROPT411" ON "OPT_TAF" ("NR_OPT", "NR_TAFLI") ;
--------------------------------------------------------
--  DDL for Index WG_NR_OZNACZ114
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_OZNACZ114" ON "OPAKOUT_H" ("TYP_OPAK", "NR_KOL_TYP_OPAK", "NR_K_PAKOW", "NR_KOL_OPAK") ;
--------------------------------------------------------
--  DDL for Index WG_NR_PAM_C
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_PAM_C" ON "PAM_C" ("NR_ZEST", "NR_KONF", "NR_PAR") ;
--------------------------------------------------------
--  DDL for Index WG_NR_PARAM_NB_STR_NR
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_PARAM_NB_STR_NR" ON "NB_OST_NR" ("TYP", "NR") ;
--------------------------------------------------------
--  DDL for Index WG_NR_PLST
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_PLST" ON "PAMLIST_STOJ" ("NR_LISTY", "NR_K_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_NR_POPRZ
--------------------------------------------------------

  CREATE INDEX "WG_NR_POPRZ" ON "FAKNAGL" ("NR_KOMP_POPRZE") ;
--------------------------------------------------------
--  DDL for Index WG_NR_POW
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_POW" ON "SLOW_POWLOK" ("NR_POWLOKI") ;
--------------------------------------------------------
--  DDL for Index WG_NR_POZ10
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_POZ10" ON "SPISZ" ("TYP_ZLEC", "NR_ZLEC", "NR_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_NR_POZ10_2
--------------------------------------------------------

  CREATE INDEX "WG_NR_POZ10_2" ON "RPZLEC_POZ" ("TYP_ZLEC", "NR_ZLEC", "NR_POZ_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_NR_POZ22
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_POZ22" ON "FAKPOZ" ("NR_KOMP_DOKS", "NR_POZ", "LP_DOD") ;
--------------------------------------------------------
--  DDL for Index WG_NR_POZ289
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_POZ289" ON "OFERTY_POZ" ("NR_OFERTY", "NR_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_NR_POZ442
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_POZ442" ON "OFERTY_POZK" ("NR_OFERTY", "NR_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_NR_REJ
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_REJ" ON "SAMOCH" ("NR_REJ") ;
--------------------------------------------------------
--  DDL for Index WG_NR_SEKW
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_SEKW" ON "KONFIG_SEKWENCJI" ("NR_SEKWENCJI", "NR_W_KOLEJNOSCI") ;
--------------------------------------------------------
--  DDL for Index WG_NR_SLOWN
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_SLOWN" ON "SLOWGIEN" ("NR_KOMPUTER", "NAZWA_GIETARKI") ;
--------------------------------------------------------
--  DDL for Index WG_NR_SPED
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_SPED" ON "SPEDC" ("NR_SPED") ;
--------------------------------------------------------
--  DDL for Index WG_NR_STR8
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_STR8" ON "STRUKTURY" ("NR_KOM_STR") ;
--------------------------------------------------------
--  DDL for Index WG_NR_SZ_456
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_SZ_456" ON "NAPISY_SZYB" ("NR_KOM_SZYBY") ;
--------------------------------------------------------
--  DDL for Index WG_NR_SZYBY
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_SZYBY" ON "SPISE" ("NR_KOM_SZYBY") ;
--------------------------------------------------------
--  DDL for Index WG_NR_TAB_311
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_TAB_311" ON "ARK_KOSZT_ODDZ" ("NR_TABELI") ;
--------------------------------------------------------
--  DDL for Index WG_NR_TR5
--------------------------------------------------------

  CREATE INDEX "WG_NR_TR5" ON "DOSTAWY" ("NR_TRASY") ;
--------------------------------------------------------
--  DDL for Index WG_NR_TRA_SCHEMATY
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_TRA_SCHEMATY" ON "TRA_SCHEMATAY" ("NUMER") ;
--------------------------------------------------------
--  DDL for Index WG_NR_TYPB
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_TYPB" ON "POZBIL" ("NR_KOMP", "NR_KOM_KART", "TYP_DOKUMENTU") ;
--------------------------------------------------------
--  DDL for Index WG_NRW762
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NRW762" ON "CRM_WIA" ("NKOMP_WIAD", "NR_ODD", "IDENT_RODZAJU") ;
--------------------------------------------------------
--  DDL for Index WG_NR_WP23
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_WP23" ON "NALEZN" ("NR_KOMP_WPLATY", "NR_KOMP_NAL") ;
--------------------------------------------------------
--  DDL for Index WG_NR_WYDRUKU
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_WYDRUKU" ON "ISO_PRNTNR" ("NR_WYDRUKU") ;
--------------------------------------------------------
--  DDL for Index WG_NR_WZORU_656
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_WZORU_656" ON "WZORNAL" ("NR_WZORU", "NR_LINII") ;
--------------------------------------------------------
--  DDL for Index WG_NR_ZAM
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_ZAM" ON "HARMON" ("NR_KOMP_ZLEC", "TYP_HARM", "NR_KOMP_INST", "DZIEN", "ZMIANA") ;
--------------------------------------------------------
--  DDL for Index WG_NR_ZAM550
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_ZAM550" ON "KOPHARMON" ("NR_KOMP_ZLEC", "TYP_HARM", "NR_KOMP_INST", "DZIEN", "ZMIANA") ;
--------------------------------------------------------
--  DDL for Index WG_NR_ZL9
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_ZL9" ON "ZAMOW" ("TYP_ZLEC", "NR_ZLEC" DESC) ;
--------------------------------------------------------
--  DDL for Index WG_NR_ZL9_1
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_ZL9_1" ON "RPZLEC" ("TYP_ZLE", "WYR_ZLEC", "NR_ZLEC" DESC) ;
--------------------------------------------------------
--  DDL for Index WG_NR_ZLEC_117
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NR_ZLEC_117" ON "OPAKOUT_Z" ("NR", "NR_K_GR") ;
--------------------------------------------------------
--  DDL for Index WG_NR_ZLEC536
--------------------------------------------------------

  CREATE INDEX "WG_NR_ZLEC536" ON "STORKE_PZLEC" ("NR_KOMP_ZLEC", "NR_POZ_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_NRZ_NRI
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NRZ_NRI" ON "ZAMINFO" ("NR_KOMP_ZLEC", "NR_KOMP_INSTAL") ;
--------------------------------------------------------
--  DDL for Index WG_NTK76
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NTK76" ON "PARINST" ("TY_INST", "KOLEJN", "NR_INST") ;
--------------------------------------------------------
--  DDL for Index WG_NUM116
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM116" ON "WOJEWODZTWA" ("NUMER") ;
--------------------------------------------------------
--  DDL for Index WG_NUM117
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM117" ON "OPAKOWANIA" ("NUMER") ;
--------------------------------------------------------
--  DDL for Index WG_NUM134
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM134" ON "BILTPOZ" ("TYP_DOK", "NR_KOMP_DOK", "NR_ODDZ", "NR_POZ", "NR_POZ_ZLEC", "NR_MAG", "INDEKS", "SERIA", "ZNACZNIK_KARTOTEKI", "CENA_PRZYJ", "CEN_WYD") ;
--------------------------------------------------------
--  DDL for Index WG_NUM15
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM15" ON "DOK" ("NR_KOMP_DOK") ;
--------------------------------------------------------
--  DDL for Index WG_NUM153
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM153" ON "SLOW_DLA_CZYNN" ("NUMER") ;
--------------------------------------------------------
--  DDL for Index WG_NUM16
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM16" ON "POZDOK" ("TYP_DOK", "NR_DOK", "NR_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_NUM202
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM202" ON "OPADRESY" ("ODB_KOD", "NR_INF") ;
--------------------------------------------------------
--  DDL for Index WG_NUM203
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM203" ON "OPINFO" ("NR_INFORM") ;
--------------------------------------------------------
--  DDL for Index WG_NUM21
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM21" ON "FAKNAGL" ("TYP_DOKS", "STAN", "PREFIX", "NR_DOKS", "SUFIX") ;
--------------------------------------------------------
--  DDL for Index WG_NUM212
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM212" ON "CENT_POPER" ("NR_OPER", "NR_ODDZ") ;
--------------------------------------------------------
--  DDL for Index WG_NUM260
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM260" ON "LOK_DOK" ("NR_KOMP_DOK") ;
--------------------------------------------------------
--  DDL for Index WG_NUM262
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM262" ON "LOK_POZDOK" ("TYP_DOK", "NR_DOK", "NR_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_NUM32
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM32" ON "TMPPOZDOK" ("TYP_DOK", "NR_KOMP_DOK", "NR_ODDZ", "NR_POZ", "NR_POZ_ZLEC", "NR_MAG", "INDEKS", "SERIA", "ZNACZNIK_KARTOTEKI", "CENA_PRZYJ", "CEN_WYD") ;
--------------------------------------------------------
--  DDL for Index WG_NUM32_TPOZ
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM32_TPOZ" ON "TPOZ" ("TYP_DOK", "NR_KOMP_DOK", "NR_ODDZ", "NR_POZ", "NR_POZ_ZLEC", "NR_MAG", "INDEKS", "ZN_KART", "CENA_PRZYJ", "CEN_WYD") ;
--------------------------------------------------------
--  DDL for Index WG_NUM34
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM34" ON "TMPDOK" ("TYP_DOK", "NR_KOMP_DOK", "NR_ODDZ", "NR_MAG") ;
--------------------------------------------------------
--  DDL for Index WG_NUM34_TDOK
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM34_TDOK" ON "TDOK" ("TYP_DOK", "NR_KOMP_DOK", "NR_ODDZ", "NR_MAG") ;
--------------------------------------------------------
--  DDL for Index WG_NUM379
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM379" ON "A_C1" ("NR_KOLEJNY", "NR_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_NUM380
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM380" ON "A_C2" ("NR_KOLEJNY", "NR_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_NUM381
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM381" ON "A_C3" ("NR_KOLEJNY", "NR_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_NUM4
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM4" ON "TR5_TABELA2" ("NUMER") ;
--------------------------------------------------------
--  DDL for Index WG_NUM404
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM404" ON "TOWARY_O" ("NR_KOMP", "TYP_KAT") ;
--------------------------------------------------------
--  DDL for Index WG_NUM405
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM405" ON "UPR_CENO" ("NR_KOMP") ;
--------------------------------------------------------
--  DDL for Index WGNUM456
--------------------------------------------------------

  CREATE UNIQUE INDEX "WGNUM456" ON "KONTOSOB" ("NRKOMKON") ;
--------------------------------------------------------
--  DDL for Index WG_NUMER_TN_FUN
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUMER_TN_FUN" ON "TN_FUN" ("NR_FUN") ;
--------------------------------------------------------
--  DDL for Index WG_NUMERU
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUMERU" ON "RAP_SP_DZ" ("NR_KONTR", "GR_TOWAR", "DATA_WYST") ;
--------------------------------------------------------
--  DDL for Index WG_NUMERU128
--------------------------------------------------------

  CREATE INDEX "WG_NUMERU128" ON "TRAN_STR" ("NR_KOMP_STR", "KOD_DLA_KLI", "NUMER_KONTRAHENTA") ;
--------------------------------------------------------
--  DDL for Index WG_NUMERU174
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUMERU174" ON "DRUKARKA" ("NR_WZORU") ;
--------------------------------------------------------
--  DDL for Index WG_NUMERU182
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUMERU182" ON "WZORDRUK" ("NR_NAP") ;
--------------------------------------------------------
--  DDL for Index WG_NUMERU186
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUMERU186" ON "KLUCZE" ("NUMER_KLUCZA") ;
--------------------------------------------------------
--  DDL for Index WG_NUMERU187
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUMERU187" ON "GRUPY" ("NUMER_GRUPY") ;
--------------------------------------------------------
--  DDL for Index WG_NUMERU189
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUMERU189" ON "OPERATORZY" ("NR_OPER") ;
--------------------------------------------------------
--  DDL for Index WG_NUMERU265_30
--------------------------------------------------------

  CREATE INDEX "WG_NUMERU265_30" ON "RKONTR_STR" ("NKOMP", "INDEKS", "TYP_WYR") ;
--------------------------------------------------------
--  DDL for Index WG_NUMERU277
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUMERU277" ON "ODDZ_BLOK" ("NR_KOMP", "STAN", "POZ_WYS") ;
--------------------------------------------------------
--  DDL for Index WG_NUMERU358
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUMERU358" ON "ZLEC_POLP1" ("NR_KOMP_ZLEC", "NR_POZ_ZLEC", "NR_WARSTWY", "NR_SKLAD", "IDENT_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_NUMERU_382
--------------------------------------------------------

  CREATE INDEX "WG_NUMERU_382" ON "A_DANES" ("NR_KOMP", "NR_KONTR", "KOD_KLIENTA", "KOD") ;
--------------------------------------------------------
--  DDL for Index WG_NUMERU434
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUMERU434" ON "LOG_ZMCEN" ("NR_KOL") ;
--------------------------------------------------------
--  DDL for Index WG_NUMERU475
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUMERU475" ON "ZLEC_SZP" ("NKOMP_ZLEC", "POZ_ZLEC", "NR_WAR") ;
--------------------------------------------------------
--  DDL for Index WG_NUMERU476R
--------------------------------------------------------

  CREATE INDEX "WG_NUMERU476R" ON "RZLEC_SZP" ("NK_ZLEC", "NR_POZ_ZLEC", "NR_WAR") ;
--------------------------------------------------------
--  DDL for Index WG_NUMERU564
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUMERU564" ON "LOGHREF" ("NK_KONTR", "NR_OD", "TYP", "NKOMP1", "NKOMP2") ;
--------------------------------------------------------
--  DDL for Index WG_NUMERU583
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUMERU583" ON "KONFIG_T" ("NR_PAR") ;
--------------------------------------------------------
--  DDL for Index WG_NUMERU649
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUMERU649" ON "NAP_SLOW" ("NR_SLO") ;
--------------------------------------------------------
--  DDL for Index WG_NUMERU760
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUMERU760" ON "CRM_ADRES" ("NKOMP_KONTR", "NR_KOLEJNY") ;
--------------------------------------------------------
--  DDL for Index WG_NUMERU761
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUMERU761" ON "CRM_OSOBA" ("NKOMP_KONTR", "NR_KOLEJNY") ;
--------------------------------------------------------
--  DDL for Index WG_NUMERU790
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUMERU790" ON "JEZ_LISTA" ("NUMER_JEZYKA") ;
--------------------------------------------------------
--  DDL for Index WG_NUMERU_KLUCZA216
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUMERU_KLUCZA216" ON "KTRWARUNKI_KREDYT" ("POZIOM", "LIMIT_NOWY", "NR_KOL") ;
--------------------------------------------------------
--  DDL for Index WG_NUMERU_TR2
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUMERU_TR2" ON "TR2_BUFOR" ("NUMER") ;
--------------------------------------------------------
--  DDL for Index WG_NUM_KAT14
--------------------------------------------------------

  CREATE INDEX "WG_NUM_KAT14" ON "SURZAM" ("TYP_ZLEC", "NR_ZLEC", "NR_KAT") ;
--------------------------------------------------------
--  DDL for Index WG_NUM_KOMP48
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM_KOMP48" ON "ZMIANY" ("NR_KOMP_INST", "DZIEN", "ZMIANA") ;
--------------------------------------------------------
--  DDL for Index WG_NUM_KONTR228
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM_KONTR228" ON "OFERTY_NAG" ("NR_KON", "NR_KOM_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_NUM_KONTR441
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM_KONTR441" ON "OFERTY_NAGK" ("NR_KON", "NR_KOM_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_NUM_MAG27
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM_MAG27" ON "MAGAZYN" ("NR_ODDZ", "NR_MAG") ;
--------------------------------------------------------
--  DDL for Index WG_NUM_ODP
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM_ODP" ON "ODPADY" ("NR_ODP") ;
--------------------------------------------------------
--  DDL for Index WG_NUM_SKL7
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM_SKL7" ON "BUDSTR" ("NR_KOM_STR", "NR_SKL") ;
--------------------------------------------------------
--  DDL for Index WG_NUM_ZN78
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM_ZN78" ON "WSPINST" ("NR_KOMP_INST", "NR_ZNACZNIKA") ;
--------------------------------------------------------
--  DDL for Index WG_NUM_ZNACZ
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM_ZNACZ" ON "WSPSTAND" ("NR_INST", "ZN_PROD") ;
--------------------------------------------------------
--  DDL for Index WG_NUM_ZN_WSP_ROB
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_NUM_ZN_WSP_ROB" ON "WSP_ROB" ("NR_INST", "ZN_PROD") ;
--------------------------------------------------------
--  DDL for Index WG_OBR116_22
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_OBR116_22" ON "ROBR_KONTR" ("NK_KONTRAKTU", "NK_OBROBKI", "GRUBOSC") ;
--------------------------------------------------------
--  DDL for Index WG_OBR384
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_OBR384" ON "KONTR_OBR" ("NK_KNTR", "NK_OBR_OBR", "GRUB") ;
--------------------------------------------------------
--  DDL for Index WG_OBR_44
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_OBR_44" ON "KP_OBR" ("NK_PRZEC", "NK_OBR", "GR") ;
--------------------------------------------------------
--  DDL for Index WG_OBR786
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_OBR786" ON "PARAM_WG_GR" ("NR_KOMP_GR", "NR_KOMP_OBR", "NR_KOL_PARAM") ;
--------------------------------------------------------
--  DDL for Index WG_ODB202
--------------------------------------------------------

  CREATE INDEX "WG_ODB202" ON "OPADRESY" ("ODB_KOD", "ODB_DATA", "ODB_CZAS") ;
--------------------------------------------------------
--  DDL for Index WG_ODD214
--------------------------------------------------------

  CREATE INDEX "WG_ODD214" ON "OPWIEZY" ("NR_ODDZ", "NAZWISKO", "KOD") ;
--------------------------------------------------------
--  DDL for Index WG_ODDZ212
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ODDZ212" ON "CENT_POPER" ("NR_ODDZ", "NR_OPER") ;
--------------------------------------------------------
--  DDL for Index WG_ODDZ73
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ODDZ73" ON "STOJSPED" ("NR_ODDZ", "NR_STOJ", "NR_KOMP_STOJ") ;
--------------------------------------------------------
--  DDL for Index WG_ODDZIALU_666
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ODDZIALU_666" ON "OKNA_KONTA_N" ("NUMER_ODDZIALU", "TYP_DOKUMENTU_SPRZEDAZY", "TYP_KONTRAHENTA") ;
--------------------------------------------------------
--  DDL for Index WG_ODDZIALU666
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ODDZIALU666" ON "OKNA_KONTA" ("NR_ODD") ;
--------------------------------------------------------
--  DDL for Index WG_ODP_472
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ODP_472" ON "MON_STRATY" ("NR_KOMP_ODP", "NR_KOMP_POBR", "TYP_KATALOG") ;
--------------------------------------------------------
--  DDL for Index WG_OKR247
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_OKR247" ON "KOSZT_ST" ("NR_OKRESU", "NR_GR") ;
--------------------------------------------------------
--  DDL for Index WG_OKR_35
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_OKR_35" ON "AITROBSTOJWG" ("NR_OKR", "NR_MAG", "NR_KOL_ST", "NR_KOMP_STOJ") ;
--------------------------------------------------------
--  DDL for Index WG_OP
--------------------------------------------------------

  CREATE INDEX "WG_OP" ON "LOG_TRANS" ("NR_OP") ;
--------------------------------------------------------
--  DDL for Index WG_OPER666
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_OPER666" ON "DANE_ADR" ("OPERATOR") ;
--------------------------------------------------------
--  DDL for Index WG_OPER852
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_OPER852" ON "OPER_SROB" ("NK_OPER") ;
--------------------------------------------------------
--  DDL for Index WG_OPERATORA190
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_OPERATORA190" ON "OPER_KL" ("NR_OPER", "NUMER_KLUCZA") ;
--------------------------------------------------------
--  DDL for Index WG_OPERATORA191
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_OPERATORA191" ON "OPER_GR" ("NR_OPER", "NUMER_GRUPY") ;
--------------------------------------------------------
--  DDL for Index WG_OPIS2
--------------------------------------------------------

  CREATE INDEX "WG_OPIS2" ON "KARTOTEKA" ("NAZWA", "ZN_KART", "NR_ODZ", "NR_MAG") ;
--------------------------------------------------------
--  DDL for Index WG_OPISU_119
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_OPISU_119" ON "OPAKOUT_SZ" ("OPIS", "ZLEC", "POZ", "SZT") ;
--------------------------------------------------------
--  DDL for Index WG_OPT
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_OPT" ON "KOL_STOJAKOW" ("NR_OPTYM", "NR_TAF", "NR_LISTY", "NR_KOMP_ZLEC", "NR_POZ", "NR_SZTUKI", "NR_WARSTWY") ;
--------------------------------------------------------
--  DDL for Index WG_OPT412
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_OPT412" ON "OPT_ZLEC" ("NR_OPT", "NR_TAFLI", "NR_KOMP_ZLEC", "NR_POZ", "SZER", "WYS") ;
--------------------------------------------------------
--  DDL for Index WG_OPTTAF_ODPADY
--------------------------------------------------------

  CREATE INDEX "WG_OPTTAF_ODPADY" ON "ODPADY" ("NR_OPTYM", "NRT") ;
--------------------------------------------------------
--  DDL for Index WG_P
--------------------------------------------------------

  CREATE INDEX "WG_P" ON "SZABLON" ("P") ;
--------------------------------------------------------
--  DDL for Index WG_PAR71
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_PAR71" ON "PARCEN" ("MARZA_G") ;
--------------------------------------------------------
--  DDL for Index WG_PARAM_296
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_PARAM_296" ON "POZKARTPOP" ("NR_ODDZ", "NR_MAG", "INDEKS", "SERIA", "ZN_KARTOTEKI", "DATA_ZAPASU", "NR", "NR_POZ_DOK") ;
--------------------------------------------------------
--  DDL for Index WG_POLOZ
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_POLOZ" ON "RDANKODSZP" ("NR_K_ZLEC", "NR_POZ_ZLEC", "TYP", "KOLEJN", "POLOZ", "RZAD") ;
--------------------------------------------------------
--  DDL for Index WG_POLOZ825
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_POLOZ825" ON "STAN_MAG_O" ("KOD_POLOZ", "TYP_KAT", "KAT_WYM") ;
--------------------------------------------------------
--  DDL for Index WG_POZ
--------------------------------------------------------

  CREATE INDEX "WG_POZ" ON "SPISE" ("NR_SPED", "NR_STOJ_SPED", "POZ_ST_SPED") ;
--------------------------------------------------------
--  DDL for Index WG_POZ10_2
--------------------------------------------------------

  CREATE INDEX "WG_POZ10_2" ON "RPZLEC_POZ" ("NR_POZ_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_POZ_3
--------------------------------------------------------

  CREATE INDEX "WG_POZ_3" ON "RZLEC_DODATKI" ("POZ_ZLEC", "KOL_DOD") ;
--------------------------------------------------------
--  DDL for Index WG_POZ31
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_POZ31" ON "POZKONTR" ("NR_KOMP_KONTR", "POZ_KONTR") ;
--------------------------------------------------------
--  DDL for Index WG_POZ31_17
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_POZ31_17" ON "RKONTR_POZYCJE" ("NK_KONTRAKTU", "POZA_KONTRAKTU") ;
--------------------------------------------------------
--  DDL for Index WG_POZ31_21
--------------------------------------------------------

  CREATE INDEX "WG_POZ31_21" ON "RKONTR_WYM" ("NK_KONTR", "INDEKS", "TYP_WYR", "POW_MIN") ;
--------------------------------------------------------
--  DDL for Index WG_POZ667R
--------------------------------------------------------

  CREATE INDEX "WG_POZ667R" ON "RREK_ZLEC" ("NK_ZLEC", "POZ_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_POZIOMU
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_POZIOMU" ON "RODSZKL" ("POZIOM") ;
--------------------------------------------------------
--  DDL for Index WG_POZYCJI509
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_POZYCJI509" ON "KOM_ZLE" ("NR_SPED", "NR_KOMP_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_POZYCJI511
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_POZYCJI511" ON "KOM_STOJ" ("NR_SPED", "NR_STOJ") ;
--------------------------------------------------------
--  DDL for Index WG_POZYCJI603
--------------------------------------------------------

  CREATE INDEX "WG_POZYCJI603" ON "ST_RAP_POZ" ("NK_RAP", "NR_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_PR388
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_PR388" ON "PREMM" ("NR_ODDZ", "NR_PRAC", "ROK", "MIES") ;
--------------------------------------------------------
--  DDL for Index WG_PRAC236
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_PRAC236" ON "LISTA_PRACOW" ("PRACOWNIK", "NR_ODDZ", "NR_PRAC") ;
--------------------------------------------------------
--  DDL for Index WG_PRZEC_45
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_PRZEC_45" ON "KP_PRZEC" ("NK_PRZEC") ;
--------------------------------------------------------
--  DDL for Index WG_PRZEC_I49
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_PRZEC_I49" ON "CP_ROB" ("NK_PRZEC", "NK_CEN") ;
--------------------------------------------------------
--  DDL for Index WG_PRZYCH224
--------------------------------------------------------

  CREATE INDEX "WG_PRZYCH224" ON "SLOWDLAOO" ("INDEKS_PRZYCH", "NR_ODDZ_PRZYCH", "NR_MAG_DOC") ;
--------------------------------------------------------
--  DDL for Index WG_PUBLIC3
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_PUBLIC3" ON "TR3_TABELA1" ("M_PUBLIC") ;
--------------------------------------------------------
--  DDL for Index WG_PWB_GK142
--------------------------------------------------------

  CREATE INDEX "WG_PWB_GK142" ON "POZBIL" ("NR_KOMP", "NR_W_BILANSIE", "GR_KOSZT") ;
--------------------------------------------------------
--  DDL for Index WG_RODZ335
--------------------------------------------------------

  CREATE INDEX "WG_RODZ335" ON "ZAK_UPR" ("RODZAJ", "KWOTA") ;
--------------------------------------------------------
--  DDL for Index WG_RODZ653
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_RODZ653" ON "WZORCE_R" ("RODZAJ", "WERSJA") ;
--------------------------------------------------------
--  DDL for Index WG_RODZ654
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_RODZ654" ON "WZORCE_Z" ("RODZAJ", "TYP", "ZNAK", "OPERACJA") ;
--------------------------------------------------------
--  DDL for Index WG_RODZ73
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_RODZ73" ON "STOJSPED" ("RODZ_STOJ", "NR_STOJ", "NR_ODDZ") ;
--------------------------------------------------------
--  DDL for Index WG_RODZAJ
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_RODZAJ" ON "FK2_SLOW" ("RODZAJ", "NUMER") ;
--------------------------------------------------------
--  DDL for Index WG_RODZAJU434
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_RODZAJU434" ON "LOG_ZMCEN" ("TYP_ZAPISU", "NR_KOL") ;
--------------------------------------------------------
--  DDL for Index WG_RODZAJU762
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_RODZAJU762" ON "CRM_WIA" ("NKOMP_KONTR", "RODZAJ_WIAD", "NKOMP_WIAD", "NR_ODD") ;
--------------------------------------------------------
--  DDL for Index WG_RODZ_POZ_PAM_E
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_RODZ_POZ_PAM_E" ON "PAM_E" ("RODZ_KONF", "NR_KONF", "NR_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_RODZ_SUR14
--------------------------------------------------------

  CREATE INDEX "WG_RODZ_SUR14" ON "SURZAM" ("TYP_ZLEC", "NR_ZLEC", "RODZ_SUR") ;
--------------------------------------------------------
--  DDL for Index WG_RZEDU
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_RZEDU" ON "RDANKODSZP" ("NR_K_ZLEC", "NR_POZ_ZLEC", "RZAD", "TYP", "KOLEJN", "POLOZ") ;
--------------------------------------------------------
--  DDL for Index WG_SES_LOGS
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_SES_LOGS" ON "LOGS" ("SESJA") ;
--------------------------------------------------------
--  DDL for Index WG_SESSID_LOGOWANIA
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_SESSID_LOGOWANIA" ON "LOGOWANIA" ("SESSION_ID", "DATA", "OPERATOR_ID") ;
--------------------------------------------------------
--  DDL for Index WG_SKROTU_299
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_SKROTU_299" ON "SL_TRANS" ("KOD_USL", "NR_DOST", "NR_ODDZ") ;
--------------------------------------------------------
--  DDL for Index WG_SKRZYNKI212
--------------------------------------------------------

  CREATE INDEX "WG_SKRZYNKI212" ON "CENT_POPER" ("KOD", "NAZWISKO") ;
--------------------------------------------------------
--  DDL for Index WG_SLOWNIKA648
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_SLOWNIKA648" ON "NAP_NAPISY" ("NR_SLO", "NR_NAP") ;
--------------------------------------------------------
--  DDL for Index WG_SLOW_PAR_603
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_SLOW_PAR_603" ON "LISTA_P_OBR" ("NR_KOMP_SL_PAR", "NR_KOMP_STRUKTURY", "NR_KOL_PARAM") ;
--------------------------------------------------------
--  DDL for Index WG_SP510
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_SP510" ON "PZLECROB" ("NR_KOMP_ZLEC", "NR_ST_SP", "STOJ_SP", "NR_POZ_ZLEC", "NR_SZTUKI") ;
--------------------------------------------------------
--  DDL for Index WG__SP510M
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG__SP510M" ON "PZLECROB" ("NR_KOMP_ZLEC" DESC, "NR_ST_SP" DESC, "STOJ_SP" DESC, "NR_POZ_ZLEC" DESC, "NR_SZTUKI" DESC) ;
--------------------------------------------------------
--  DDL for Index WG_SPED513
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_SPED513" ON "KOM_ADRES" ("NR_SPED", "NR_ADR", "NR_KONTR") ;
--------------------------------------------------------
--  DDL for Index WG_SPED524
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_SPED524" ON "KOM_OPIS" ("NR_SPED") ;
--------------------------------------------------------
--  DDL for Index WG_SPED568
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_SPED568" ON "INFO_ESPED" ("NK_KONTR", "NR_OD", "NR_SPED") ;
--------------------------------------------------------
--  DDL for Index WG_SPED569
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_SPED569" ON "INFO_ESTOJ" ("NK_KONTR", "NR_OD", "NK_SPED", "NK_ZLEC", "NK_STOJ") ;
--------------------------------------------------------
--  DDL for Index WG_SPED602
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_SPED602" ON "ST_RAP" ("NR_SPED", "NK_KONTR", "NK_RAP") ;
--------------------------------------------------------
--  DDL for Index WG_SPEDYCJI605
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_SPEDYCJI605" ON "ST_KONTR_STOJ" ("NK_SPED", "NK_STOJ", "ODD_WYJ", "NK_ZAP") ;
--------------------------------------------------------
--  DDL for Index WG_SPRZED_540
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_SPRZED_540" ON "RAP_SP_DZ" ("SPRZEDAZ" DESC, "DATA_WYST", "NR_KONTR", "GR_TOWAR") ;
--------------------------------------------------------
--  DDL for Index WG_STACJI_PAM_E
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_STACJI_PAM_E" ON "PAM_E_NAGL" ("RODZ_KONF", "STACJA", "UZYTK") ;
--------------------------------------------------------
--  DDL for Index WG_STANU_CRM_ZDARZENIE
--------------------------------------------------------

  CREATE INDEX "WG_STANU_CRM_ZDARZENIE" ON "CRM_ZDARZENIE" ("NK_KONTR", "NK_ZD", "STAN") ;
--------------------------------------------------------
--  DDL for Index WG_STAT238
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_STAT238" ON "SLOW_NIEOB" ("KOD") ;
--------------------------------------------------------
--  DDL for Index WG_STOJ_119
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_STOJ_119" ON "OPAKOUT_SZ" ("NR_KOMP_STOJ", "NR_PIETRA", "NR_RZEDU", "NR_KOL", "ZLEC", "POZ", "SZT") ;
--------------------------------------------------------
--  DDL for Index WG_STOJ_34
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_STOJ_34" ON "AITROBWGOT" ("NR_MAG", "NR_OKRESU", "NR_K_STOJAKA", "POZ_STOJAKA", "NR_K_ZAMOW", "POZ_ZAMOW", "SZT") ;
--------------------------------------------------------
--  DDL for Index WG_STOJ_36
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_STOJ_36" ON "AITROBPODSWG" ("NR_MAGAZ", "NR_OKRESU", "NR_KOMP_STOJ", "NR_KOL_STOJAKA", "NR_KOMP_ZLEC", "INDEKS") ;
--------------------------------------------------------
--  DDL for Index WG_STOJ62
--------------------------------------------------------

  CREATE INDEX "WG_STOJ62" ON "L_WYC" ("NR_INST", "NR_STOJ", "STOJ_POZ", "ZN_STOJ") ;
--------------------------------------------------------
--  DDL for Index WG_STOJ_63
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_STOJ_63" ON "PAMLIST_OZNACZ" ("NR_LISTY", "NR_KOMP_STOJ", "STRONA_STOJ", "PIETRO_STOJ", "NR_KOL_STOJ") ;
--------------------------------------------------------
--  DDL for Index WG_STOJ75
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_STOJ75" ON "HISTOJ" ("NR_KOMP_STOJ", "DATA", "CZAS") ;
--------------------------------------------------------
--  DDL for Index WG_STOJ844
--------------------------------------------------------

  CREATE INDEX "WG_STOJ844" ON "ARK_INW_POZ" ("NR_MAG", "OKRES", "NK_STOJ", "POZ_STOJ") ;
--------------------------------------------------------
--  DDL for Index WG_STOJAKA603
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_STOJAKA603" ON "ST_RAP_POZ" ("NK_RAP", "NK_ST") ;
--------------------------------------------------------
--  DDL for Index WG_STOJAKA605
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_STOJAKA605" ON "ST_KONTR_STOJ" ("NK_STOJ", "DATA_WYJ", "NK_ZAP", "ODD_WYJ") ;
--------------------------------------------------------
--  DDL for Index WG_STOJAKOW_35
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_STOJAKOW_35" ON "AITROBSTOJWG" ("NR_OKR", "NR_MAG", "NR_KOMP_STOJ", "NR_KOL_ST", "NR_1_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_STOJ_ALFAK
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_STOJ_ALFAK" ON "STOJAKI_ALFAK" ("NR_STOJAKA") ;
--------------------------------------------------------
--  DDL for Index WG_STOJ_PLST
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_STOJ_PLST" ON "PAMLIST_STOJ" ("NR_K_ZLEC", "NR_LISTY") ;
--------------------------------------------------------
--  DDL for Index WG_STOJ_POZ
--------------------------------------------------------

  CREATE INDEX "WG_STOJ_POZ" ON "SPISE" ("NR_STOJ_SPED", "POZ_ST_SPED", "FLAG_REAL") ;
--------------------------------------------------------
--  DDL for Index WG_STOJ_PROD12
--------------------------------------------------------

  CREATE INDEX "WG_STOJ_PROD12" ON "SPISE" ("NR_STOJ_PROD") ;
--------------------------------------------------------
--  DDL for Index WG_STOJ_SPED
--------------------------------------------------------

  CREATE INDEX "WG_STOJ_SPED" ON "SPISE" ("NR_SPED", "NR_STOJ_SPED", "NR_KOMP_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_STR_10
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_STR_10" ON "SPISZ" ("KOD_STR", "NR_KOM_ZLEC", "NR_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_STR_43
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_STR_43" ON "KP_STR" ("NK_PRZEC", "TYP_W", "INDEKS") ;
--------------------------------------------------------
--  DDL for Index WG_STR_452
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_STR_452" ON "STR_W_ZLEC" ("NR_KOM_STR", "NR_KAT_DOD", "NR_KOM_ZLEC", "NR_KOL_STRUKT") ;
--------------------------------------------------------
--  DDL for Index WG_STR_PARAM
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_STR_PARAM" ON "STR_PARAM" ("KOD_STR", "NR_PARAM") ;
--------------------------------------------------------
--  DDL for Index WG_STRUKT603
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_STRUKT603" ON "LISTA_P_OBR" ("NR_KOMP_STRUKTURY", "NR_KOL_PARAM") ;
--------------------------------------------------------
--  DDL for Index WG_STRUKTU127
--------------------------------------------------------

  CREATE INDEX "WG_STRUKTU127" ON "TRAN_POZ" ("NR_KOL", "INDEKS") ;
--------------------------------------------------------
--  DDL for Index WG_STRUKTUR377
--------------------------------------------------------

  CREATE INDEX "WG_STRUKTUR377" ON "A_TRANP" ("NR_KOL", "STR_KLIENTA") ;
--------------------------------------------------------
--  DDL for Index WG_STRUKTURY265_30
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_STRUKTURY265_30" ON "RKONTR_STR" ("NKOMP", "NR_STR") ;
--------------------------------------------------------
--  DDL for Index WG_STRUKTURY266_21
--------------------------------------------------------

  CREATE INDEX "WG_STRUKTURY266_21" ON "RKONTR_WYM" ("NK_KONTR", "NR_STR", "POW_MIN", "POW_MAK") ;
--------------------------------------------------------
--  DDL for Index WG_SUR16
--------------------------------------------------------

  CREATE INDEX "WG_SUR16" ON "POZDOK" ("TYP_DOK", "NR_MAG", "INDEKS", "SERIA") ;
--------------------------------------------------------
--  DDL for Index WG_SUR262
--------------------------------------------------------

  CREATE INDEX "WG_SUR262" ON "LOK_POZDOK" ("TYP_DOK", "NR_MAG", "INDEKS") ;
--------------------------------------------------------
--  DDL for Index WG_SYMB_602
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_SYMB_602" ON "SLPAROB" ("SYMB_P_OBR", "NR_K_P_OBR") ;
--------------------------------------------------------
--  DDL for Index WG_SYMBOLU505
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_SYMBOLU505" ON "STOJAKI_DEF" ("SYMBOL", "NR_DEF") ;
--------------------------------------------------------
--  DDL for Index WG_SYMBOLU508
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_SYMBOLU508" ON "SLOW_FK" ("SYMBOL") ;
--------------------------------------------------------
--  DDL for Index WG_SYMBOLU615
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_SYMBOLU615" ON "STOJAKI_DEF_O" ("SYMBOL", "NR_DEF") ;
--------------------------------------------------------
--  DDL for Index WG_SYMB_WSP_OBR
--------------------------------------------------------

  CREATE INDEX "WG_SYMB_WSP_OBR" ON "WSP_OBR" ("SYMB", "TYP_KAT_SZKLA", "NR_KOMP_INST") ;
--------------------------------------------------------
--  DDL for Index WG_SZABLONU_TRAN_IND
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_SZABLONU_TRAN_IND" ON "TRAN_IND0" ("NR_SZABL", "NK_KONTR") ;
--------------------------------------------------------
--  DDL for Index WG_SZER_119
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_SZER_119" ON "OPAKOUT_SZ" ("SZER" DESC, "WYS" DESC, "ZLEC", "POZ", "SZT") ;
--------------------------------------------------------
--  DDL for Index WG_SZPROS91_3
--------------------------------------------------------

  CREATE INDEX "WG_SZPROS91_3" ON "RZLEC_DODATKI" ("IDEN_SZP") ;
--------------------------------------------------------
--  DDL for Index WG_SZPROSU
--------------------------------------------------------

  CREATE INDEX "WG_SZPROSU" ON "TRAN_SZPR" ("NAZWA_SZPROSU") ;
--------------------------------------------------------
--  DDL for Index WG_SZPROSU127
--------------------------------------------------------

  CREATE INDEX "WG_SZPROSU127" ON "TRAN_POZ" ("NR_KOL", "KOD_SZPROSU") ;
--------------------------------------------------------
--  DDL for Index WG_SZPROSU377
--------------------------------------------------------

  CREATE INDEX "WG_SZPROSU377" ON "A_TRANP" ("NR_KOL", "KOD_SZPROSU") ;
--------------------------------------------------------
--  DDL for Index WG_SZPROSU378
--------------------------------------------------------

  CREATE INDEX "WG_SZPROSU378" ON "A_TRANS" ("NAZ_SZPR") ;
--------------------------------------------------------
--  DDL for Index WG_SZYBY467
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_SZYBY467" ON "BRAKI_B" ("NR_KOM_SZYBY", "ZLEC_BRAKI", "NR_KOL", "NR_WAR") ;
--------------------------------------------------------
--  DDL for Index WG_TAB19
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TAB19" ON "WALUTA" ("NR_TABELI", "WALUTA") ;
--------------------------------------------------------
--  DDL for Index WG_TABELI130
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TABELI130" ON "ZLEC_ZMS" ("RODZAJ", "NR_TAB", "NR_POLA") ;
--------------------------------------------------------
--  DDL for Index WG_TOW22
--------------------------------------------------------

  CREATE INDEX "WG_TOW22" ON "FAKPOZ" ("DATA_WYS", "NR_MAG", "INDEKS") ;
--------------------------------------------------------
--  DDL for Index WG_TRASY6
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TRASY6" ON "TRASY" ("NR_TRASY") ;
--------------------------------------------------------
--  DDL for Index WG_TYP
--------------------------------------------------------

  CREATE INDEX "WG_TYP" ON "SZABLON" ("TYP") ;
--------------------------------------------------------
--  DDL for Index WG_TYP129
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYP129" ON "SL_TYP" ("TYP", "RODZAJ", "NUMER") ;
--------------------------------------------------------
--  DDL for Index WG_TYP_32
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYP_32" ON "ALFAK_STOJ" ("TYP", "OPIS", "SZEROKOSC") ;
--------------------------------------------------------
--  DDL for Index WG_TYP63
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYP63" ON "SLOW_PAR" ("TYPY_P", "NUMER") ;
--------------------------------------------------------
--  DDL for Index WG_TYP738
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYP738" ON "SLOWNIK" ("TYP", "ROZ") ;
--------------------------------------------------------
--  DDL for Index WG_TYP8
--------------------------------------------------------

  CREATE INDEX "WG_TYP8" ON "STRUKTURY" ("TYP_STR") ;
--------------------------------------------------------
--  DDL for Index WG_TYP801
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYP801" ON "KAT_GR_PLAN" ("TYP_KAT", "NKOMP_GRUPY") ;
--------------------------------------------------------
--  DDL for Index WG_TYPDOK_ZLEC16
--------------------------------------------------------

  CREATE INDEX "WG_TYPDOK_ZLEC16" ON "POZDOK" ("TYP_DOK", "NR_KOMP_BAZ") ;
--------------------------------------------------------
--  DDL for Index WG__TYP_INST
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG__TYP_INST" ON "PINST_DOD" ("NR_KOMP_INST", "TYP_KAT", "GRUB_OD") ;
--------------------------------------------------------
--  DDL for Index WG_TYP_POZ
--------------------------------------------------------

  CREATE INDEX "WG_TYP_POZ" ON "SPISZ" ("TYP_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_TYP_POZ10_2
--------------------------------------------------------

  CREATE INDEX "WG_TYP_POZ10_2" ON "RPZLEC_POZ" ("TYP_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_TYP_TN_POLA
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYP_TN_POLA" ON "TN_POLA" ("TYP_POLA", "NAZ_POLA") ;
--------------------------------------------------------
--  DDL for Index WG_TYP_TRANS_POL_172
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYP_TRANS_POL_172" ON "TRANS_POL" ("TYP") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYPU" ON "IFS_ODBIORCY" ("TYP_ODB") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU110
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYPU110" ON "IFS_WZ" ("TYP_KONTA", "NR_MAG", "NR_ANAL") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU15
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYPU15" ON "DOK" ("TYP_DOK", "NR_DOK") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU16
--------------------------------------------------------

  CREATE INDEX "WG_TYPU16" ON "POZDOK" ("TYP_DOK", "NR_DOK") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU261
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYPU261" ON "LOK_DOK" ("TYP_DOK", "NR_DOK") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU262
--------------------------------------------------------

  CREATE INDEX "WG_TYPU262" ON "LOK_POZDOK" ("TYP_DOK", "NR_DOK") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU330
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYPU330" ON "IFS_ODB" ("CT_DT", "TYP_IFS") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU331
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYPU331" ON "IFS_VAT_K" ("CT_DT", "KONTO") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU343
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYPU343" ON "IFS_ZASADY" ("TYP", "KOD", "TYP_IFS") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU374
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYPU374" ON "A_GLAS" ("TYP", "KOD_ZNAKU") ;
--------------------------------------------------------
--  DDL for Index WGTYPU456
--------------------------------------------------------

  CREATE UNIQUE INDEX "WGTYPU456" ON "KONTOSOB" ("TYPKONT", "NRKOMKON") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU487
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYPU487" ON "LISTSZAB" ("NR_SCHEM", "TYP_POZ", "TYP") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU488
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYPU488" ON "LISTTYP" ("RODZAJ", "TYP") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU_504
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYPU_504" ON "TYPY_PLATN" ("ID_TYPU_PLAT") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU505
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYPU505" ON "STOJAKI_DEF" ("WSK" DESC, "NR_DEF") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU525
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYPU525" ON "KONTA_FK" ("TYP_ZAPISU") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU581
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYPU581" ON "REKSLO2" ("TYP_ZAP", "NK_ZAP") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU615
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYPU615" ON "STOJAKI_DEF_O" ("NR_DEF") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU647
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYPU647" ON "NAP_KLUCZE" ("TYP", "KLUCZ") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU665
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYPU665" ON "OKNA_ZAS1" ("TYP_KONTR", "TYP_SPR", "NR_ODD") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU738
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYPU738" ON "BLOKADY" ("TYP", "CO_BLOK") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU825
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYPU825" ON "STAN_MAG_O" ("TYP_KAT", "KAT_WYM", "KOD_POLOZ") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU_KAT_KOL
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYPU_KAT_KOL" ON "SLOWTYPR" ("TYPKAT") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU_ODCZ850
--------------------------------------------------------

  CREATE INDEX "WG_TYPU_ODCZ850" ON "LOG_ODCZYTOW" ("LOG_TYP", "DATA", "CZAS") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU_ODCZ_NR850
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYPU_ODCZ_NR850" ON "LOG_ODCZYTOW" ("LOG_TYP", "NR_KOL") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU_OPISU_850
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYPU_OPISU_850" ON "TYP_OPISU" ("NR_TYPU") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU_OPISU_866
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYPU_OPISU_866" ON "TYP_NAZWY" ("NR_TYPU") ;
--------------------------------------------------------
--  DDL for Index WG_TYPU_WSP_OBR
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYPU_WSP_OBR" ON "WSP_OBR" ("TYP_WSP", "NR_KOMP_OBR", "NR_KOMP_INST", "TYP_KAT_SZKLA") ;
--------------------------------------------------------
--  DDL for Index WG_TYP_WARUNKI
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYP_WARUNKI" ON "WARUNKI" ("TYP", "NR_POLA") ;
--------------------------------------------------------
--  DDL for Index WG_TYPY410
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_TYPY410" ON "OPT_NR" ("TYP_KAT", "NR_OPT") ;
--------------------------------------------------------
--  DDL for Index WG_WALUTY260
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_WALUTY260" ON "KURS_SAD" ("WALUTA", "DATA") ;
--------------------------------------------------------
--  DDL for Index WG_WN278
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_WN278" ON "KTRWNIOSKI_ODD" ("NR_WNIOSKU", "STATUS", "POZ_WYS") ;
--------------------------------------------------------
--  DDL for Index WG_WSK128
--------------------------------------------------------

  CREATE INDEX "WG_WSK128" ON "ZLEC_ZMS" ("WSK", "NR_TAB", "NR_POLA") ;
--------------------------------------------------------
--  DDL for Index WG_WSK460
--------------------------------------------------------

  CREATE INDEX "WG_WSK460" ON "NR_OZNAK" ("NR_KOL", "WSK", "NR") ;
--------------------------------------------------------
--  DDL for Index WG_WSK466
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_WSK466" ON "BRAKI_A" ("WSK", "NR_ZAP") ;
--------------------------------------------------------
--  DDL for Index WG_WSK467
--------------------------------------------------------

  CREATE INDEX "WG_WSK467" ON "BRAKI_B" ("WSK", "NR_KOM_SZYBY") ;
--------------------------------------------------------
--  DDL for Index WG_WSKAZNIKA
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_WSKAZNIKA" ON "TRAN_KONTR" ("KLIENT_C7_4", "AKCEPTACJA") ;
--------------------------------------------------------
--  DDL for Index WG_WSZYSTKICH_PARAMETROW
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_WSZYSTKICH_PARAMETROW" ON "POZKARTOT" ("NR_ODDZ", "NR_MAG", "INDEKS", "SERIA", "ZN_KARTOTEKI", "DATA_ZAPASU", "NR", "NR_POZ_DOK") ;
--------------------------------------------------------
--  DDL for Index WG_WYDR_555
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_WYDR_555" ON "GR_STRUKT" ("INDEKS") ;
--------------------------------------------------------
--  DDL for Index WG_WYSOK_119
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_WYSOK_119" ON "OPAKOUT_SZ" ("WYS" DESC, "SZER" DESC, "ZLEC", "POZ", "SZT") ;
--------------------------------------------------------
--  DDL for Index WG_WZ22
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_WZ22" ON "FAKPOZ" ("TYP_DOKS", "ID_WZ", "ID_WZ_POZ", "NR_KOMP_DOKS", "ID_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_WZORCA650
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_WZORCA650" ON "NAP_WZR" ("NR_WZORCA") ;
--------------------------------------------------------
--  DDL for Index WG_WZR_I52
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_WZR_I52" ON "CP_WZR" ("NK_PRZEC", "NKAT_SZYBA1", "NKAT_RAMKA", "NKAT_GAZ", "NKAT_SZYBA2") ;
--------------------------------------------------------
--  DDL for Index WG_WZ_SPISE
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_WZ_SPISE" ON "SPISE" ("NR_KOMP_ZLEC", "NR_K_WZ", "NR_POZ_WZ", "NR_POZ", "NR_SZT") ;
--------------------------------------------------------
--  DDL for Index WG_ZAL577
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZAL577" ON "ROZLICZ_ZAL" ("N_K_ZAL", "N_K_FAKT") ;
--------------------------------------------------------
--  DDL for Index WG_ZAP362
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZAP362" ON "PRAC_WYK" ("NK_ZAP") ;
--------------------------------------------------------
--  DDL for Index WG_ZAP466
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZAP466" ON "BRAKI_A" ("NR_ZAP") ;
--------------------------------------------------------
--  DDL for Index WG_ZAPIS605
--------------------------------------------------------

  CREATE INDEX "WG_ZAPIS605" ON "ST_KONTR_STOJ" ("ODD_WYJ", "NK_ZAP") ;
--------------------------------------------------------
--  DDL for Index WG_ZAPISU506
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZAPISU506" ON "KASA" ("NR_ZAPISU") ;
--------------------------------------------------------
--  DDL for Index WG_ZAPISU606
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZAPISU606" ON "ST_BUF_STOJ" ("NK_ZAP") ;
--------------------------------------------------------
--  DDL for Index WG_ZAPISU618
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZAPISU618" ON "BUF_SPED" ("NK_ZAP") ;
--------------------------------------------------------
--  DDL for Index WG_ZAPISU795
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZAPISU795" ON "ZLEC_ZMP" ("NR_ZAPISU") ;
--------------------------------------------------------
--  DDL for Index WG_ZAPISU_CRM_ZDARZENIE
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZAPISU_CRM_ZDARZENIE" ON "CRM_ZDARZENIE" ("NK_ZAP", "NK_ZD", "NK_KONTR") ;
--------------------------------------------------------
--  DDL for Index WG_ZAPISU_KOM
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZAPISU_KOM" ON "KOM" ("NR_ZAP") ;
--------------------------------------------------------
--  DDL for Index WG_ZAPISU_LOG_KAL
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZAPISU_LOG_KAL" ON "LOG_KAL" ("NK_ZAP") ;
--------------------------------------------------------
--  DDL for Index WG_ZAPISU_PAPIERY
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZAPISU_PAPIERY" ON "PAPIERY" ("NK_ZAP") ;
--------------------------------------------------------
--  DDL for Index WG_ZAPISU_PAPIERYN
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZAPISU_PAPIERYN" ON "PAPIERYN" ("NK_ZAP") ;
--------------------------------------------------------
--  DDL for Index WG_ZBIORU466
--------------------------------------------------------

  CREATE INDEX "WG_ZBIORU466" ON "BRAKI_A" ("NAZ_ZB") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLEC" ON "SPISE" ("NR_KOMP_ZLEC", "NR_POZ", "NR_SZT") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC_119
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLEC_119" ON "OPAKOUT_SZ" ("ZLEC", "POZ", "SZT") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC13
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLEC13" ON "SPISP" ("NUMER_KOMPUTEROWY_ZLECENIA", "NR_POZ", "ZM_PLAN", "ZM_WYK", "NR_KOM_INST", "NR_KOM_INST_WYK") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC14
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLEC14" ON "SURZAM" ("TYP_ZLEC", "NR_ZLEC", "NR_KAT", "INDEKS", "NR_MAG") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC16
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLEC16" ON "POZDOK" ("NR_KOMP_BAZ", "NR_POZ_ZLEC", "KOL_DOD", "NR_KOMP_DOK", "NR_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC_259
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLEC_259" ON "REJ_POZ_REKL" ("NR_KOMP_ZLEC", "NR_POZ", "NR_SZTUKI", "NR_KOMP_REKL") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC_312
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLEC_312" ON "ZLECENIA_ANAL_KOSZT" ("NR_ZLEC", "NR_STRUKT", "GR_KOSZT_WYR", "GR_KOSZT_SUR") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC_34
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLEC_34" ON "AITROBWGOT" ("NR_MAG", "NR_OKRESU", "NR_K_ZAMOW", "POZ_ZAMOW", "SZT") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC_36
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLEC_36" ON "AITROBPODSWG" ("NR_MAGAZ", "NR_OKRESU", "NR_KOMP_ZLEC", "NR_KOMP_STOJ", "NR_KOL_STOJAKA", "INDEKS") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC385
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLEC385" ON "WYKZAL" ("NR_KOMP_ZLEC", "NR_KOMP_INSTAL", "NR_KOMP_ZM", "NR_POZ", "INDEKS", "NR_ZM_PLAN", "NR_KOMP_OBR", "KOD_DOD", "NR_WARST") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC412
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLEC412" ON "OPT_ZLEC" ("NR_KOMP_ZLEC", "NR_OPT", "NR_TAFLI", "NR_POZ", "SZER", "WYS") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC_452
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLEC_452" ON "STR_W_ZLEC" ("NR_KOM_ZLEC", "NR_KOL_STRUKT", "NR_KOM_STR", "NR_KAT_DOD") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC462
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLEC462" ON "SPISW" ("NR_INST", "NR_KOMP_ZM", "NR_OBR", "NR_KOM_ZLEC", "NR_POZ", "NR_SZT", "BRAK") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC466
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLEC466" ON "BRAKI_A" ("NR_ZLEC", "NR_POZ", "NAZ_ZB", "NR_ZAP") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC467
--------------------------------------------------------

  CREATE INDEX "WG_ZLEC467" ON "BRAKI_B" ("NR_ZLEC", "NR_KOM_SZYBY") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC510
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLEC510" ON "PZLECROB" ("NR_KOMP_ZLEC", "NR_POZ_ZLEC", "NR_SZTUKI") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC548
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLEC548" ON "KOPWYKZAL" ("NR_KOMP_ZLEC", "NR_KOMP_INSTAL", "NR_KOMP_ZM", "NR_POZ", "INDEKS", "NR_ZM_PLAN") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC549
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLEC549" ON "KOPSPISP" ("NUMER_KOMPUTEROWY_ZLECENIA", "NR_POZ", "ZM_PLAN", "ZM_WYK", "NR_KOM_INST") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC582
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLEC582" ON "REKZLEC2" ("NK_ZLEC", "NR_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC_660
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLEC_660" ON "PAMLIST" ("NR_K_ZLEC", "NR_LISTY") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC722
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLEC722" ON "LOGKSZTALT" ("NR_ZLECENIA", "POZYCJA") ;
--------------------------------------------------------
--  DDL for Index WG_ZLECEN357
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLECEN357" ON "ZLEC_POLP" ("NR_KOMP_ZLEC", "NR_POZ_ZLEC", "NR_WARSTWY", "IDENT_POZ") ;
--------------------------------------------------------
--  DDL for Index WG_ZLECEN470
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLECEN470" ON "A_BUFOR" ("NR_KOL", "NR_POZ", "LICZNIK") ;
--------------------------------------------------------
--  DDL for Index WG_ZLECENIA475
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLECENIA475" ON "ZLEC_SZP" ("NR_ZLEC", "POZ_ZLEC", "NR_WAR") ;
--------------------------------------------------------
--  DDL for Index WG_ZLECENIA476R
--------------------------------------------------------

  CREATE INDEX "WG_ZLECENIA476R" ON "RZLEC_SZP" ("NR_ZLEC", "NR_POZ_ZLEC", "NR_WAR") ;
--------------------------------------------------------
--  DDL for Index WG_ZLECENIA535
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLECENIA535" ON "STORKE_ZLEC" ("NR_ZLEC_KLI", "D_WCZYT", "C_WCZYT") ;
--------------------------------------------------------
--  DDL for Index WG_ZLECENIA536
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLECENIA536" ON "STORKE_PZLEC" ("IDENT_ZLEC", "POZ") ;
--------------------------------------------------------
--  DDL for Index WG_ZLECENIA584
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLECENIA584" ON "ZLEC_ZM" ("NK_ZLEC", "NK_ZM") ;
--------------------------------------------------------
--  DDL for Index WG_ZLECENIA673
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLECENIA673" ON "ZLEC_DOPLATY" ("NK_ZLEC", "IDENT_POZ", "RODZAJ") ;
--------------------------------------------------------
--  DDL for Index WG_ZLECENIA674R
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLECENIA674R" ON "RZLEC_DOPLATY" ("NK_ZLEC", "ID_POZ", "RODZAJ") ;
--------------------------------------------------------
--  DDL for Index WG_ZLECENIA736
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLECENIA736" ON "ZLEC_ODBL" ("NKP_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC_I_KAT
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLEC_I_KAT" ON "KATEG_INFO" ("NR_KOMP_ZLEC", "NR_KATEG") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC_ODCZ850
--------------------------------------------------------

  CREATE INDEX "WG_ZLEC_ODCZ850" ON "LOG_ODCZYTOW" ("NR_KOMP_ZLEC", "IDENT2", "IDENT3", "IDENT4") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC_OPAK114
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLEC_OPAK114" ON "OPAKOUT_H" ("NR_KOMP_ZLEC", "NR_K_PAKOW") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC_OTWARTYCH
--------------------------------------------------------

  CREATE INDEX "WG_ZLEC_OTWARTYCH" ON "SPISE" ("NR_KOMP_ZLEC", "FLAG_REAL") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC_PAK115
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLEC_PAK115" ON "OPAKOUT_P" ("NR_ZAMOW", "NR_POZ_ZAM", "NUMER_SZT") ;
--------------------------------------------------------
--  DDL for Index WG_ZLEC_STATUSY_ZLEC
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZLEC_STATUSY_ZLEC" ON "STATUSY_ZLEC" ("NR_KOMP_ZLEC") ;
--------------------------------------------------------
--  DDL for Index WG_ZM385
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZM385" ON "WYKZAL" ("NR_KOMP_ZM", "NR_KOMP_INSTAL", "NR_KOMP_ZLEC", "NR_POZ", "INDEKS", "NR_ZM_PLAN", "NR_KOMP_OBR", "KOD_DOD", "NR_WARST") ;
--------------------------------------------------------
--  DDL for Index WG_ZM411
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZM411" ON "OPT_TAF" ("NR_KOMP_ZMW", "NR_OPT", "NR_TAFLI") ;
--------------------------------------------------------
--  DDL for Index WG_ZM463
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZM463" ON "OBR_CZAS" ("NR_KOMP_INST", "NR_KOMP_ZM", "NR_OBR") ;
--------------------------------------------------------
--  DDL for Index WG_ZM548
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZM548" ON "KOPWYKZAL" ("NR_KOMP_ZM", "NR_KOMP_INSTAL", "NR_KOMP_ZLEC", "NR_POZ", "INDEKS", "NR_ZM_PLAN") ;
--------------------------------------------------------
--  DDL for Index WG_ZMI_472
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZMI_472" ON "MON_STRATY" ("NR_KOMP_ZMIANY", "NR_KOMP_POBR", "NR_KOMP_ODP") ;
--------------------------------------------------------
--  DDL for Index WG_ZMIANY795
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZMIANY795" ON "ZLEC_ZMP" ("NR_ZMIANY", "NR_ZAPISU") ;
--------------------------------------------------------
--  DDL for Index WG_ZMIANY_ODCZ850
--------------------------------------------------------

  CREATE INDEX "WG_ZMIANY_ODCZ850" ON "LOG_ODCZYTOW" ("NR_KOMP_INST", "NR_KOL", "OPER") ;
--------------------------------------------------------
--  DDL for Index WG_ZMP411
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZMP411" ON "OPT_TAF" ("NR_KOMP_ZMP", "NR_PAK", "POZ_W_PAK", "NR_OPT", "NR_TAFLI") ;
--------------------------------------------------------
--  DDL for Index WG_ZNACZNIKA564
--------------------------------------------------------

  CREATE INDEX "WG_ZNACZNIKA564" ON "LOGHREF" ("ZN") ;
--------------------------------------------------------
--  DDL for Index WG_ZNACZNIKA60_40
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZNACZNIKA60_40" ON "FK2_FAK" ("ZNK_DOK", "NK_DOK") ;
--------------------------------------------------------
--  DDL for Index WG_ZNAKI632
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZNAKI632" ON "UE_ZNAK" ("ZNAK") ;
--------------------------------------------------------
--  DDL for Index WG_ZNAK_WEJ_LKONW
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZNAK_WEJ_LKONW" ON "LKONW" ("TYP", "ZNAK_WEJ") ;
--------------------------------------------------------
--  DDL for Index WG_ZN_FKS_FAKTURY
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZN_FKS_FAKTURY" ON "FKS_FAKTURY" ("ZNACZNIK_DOKUMENTU", "NKOMP_DOKUMENTU") ;
--------------------------------------------------------
--  DDL for Index WG_ZN_KART246
--------------------------------------------------------

  CREATE UNIQUE INDEX "WG_ZN_KART246" ON "GR_KOSZT" ("ZN_KART", "NR_KOMP_GR") ;
--------------------------------------------------------
--  DDL for Index WG_ZNSTOJ62
--------------------------------------------------------

  CREATE INDEX "WG_ZNSTOJ62" ON "L_WYC" ("ZN_STOJ", "NR_STOJ", "NR_INST_NAST") ;
--------------------------------------------------------
--  DDL for Index WH_FL_REAL74
--------------------------------------------------------

  CREATE INDEX "WH_FL_REAL74" ON "SPEDC" ("FLAG_REAL") ;
--------------------------------------------------------
--  DDL for Index WID53
--------------------------------------------------------

  CREATE INDEX "WID53" ON "DRMETPOZ" ("SERIALNO") ;
--------------------------------------------------------
--  DDL for Index WIDM53
--------------------------------------------------------

  CREATE INDEX "WIDM53" ON "DRMETPOZ" ("SERIALNO" DESC) ;
--------------------------------------------------------
--  DDL for Index WMONM53
--------------------------------------------------------

  CREATE INDEX "WMONM53" ON "DRMETPOZ" ("LP_LIS" DESC, "LPM" DESC) ;
--------------------------------------------------------
--  DDL for Index WMONT53
--------------------------------------------------------

  CREATE INDEX "WMONT53" ON "DRMETPOZ" ("LP_LIS", "LPM") ;
--------------------------------------------------------
--  DDL for Index WOPT53
--------------------------------------------------------

  CREATE INDEX "WOPT53" ON "DRMETPOZ" ("OPTNR", "TAFNR", "TAFPOZ", "NR_KOM_ZLEC", "POZ_SORT", "WARSTWA") ;
--------------------------------------------------------
--  DDL for Index WPOZ53
--------------------------------------------------------

  CREATE INDEX "WPOZ53" ON "DRMETPOZ" ("LP_LIS", "POZ", "SZT") ;
--------------------------------------------------------
--  DDL for Index WPOZM53
--------------------------------------------------------

  CREATE INDEX "WPOZM53" ON "DRMETPOZ" ("LP_LIS" DESC, "POZ" DESC, "SZT" DESC) ;
--------------------------------------------------------
--  DDL for Index WPOZSORT53
--------------------------------------------------------

  CREATE UNIQUE INDEX "WPOZSORT53" ON "DRMETPOZ" ("POZ_SORT", "WARSTWA", "NR_KOM_ZLEC", "LPM", "SZT") ;
--------------------------------------------------------
--  DDL for Index WPOZSZT53
--------------------------------------------------------

  CREATE UNIQUE INDEX "WPOZSZT53" ON "DRMETPOZ" ("NR_KOM_ZLEC", "POZ", "SZT", "WARSTWA") ;
--------------------------------------------------------
--  DDL for Index WRACK53
--------------------------------------------------------

  CREATE INDEX "WRACK53" ON "DRMETPOZ" ("RACKNO") ;
--------------------------------------------------------
--  DDL for Index WRACKM53
--------------------------------------------------------

  CREATE INDEX "WRACKM53" ON "DRMETPOZ" ("RACKNO" DESC) ;
--------------------------------------------------------
--  DDL for Index WSPED53
--------------------------------------------------------

  CREATE INDEX "WSPED53" ON "DRMETPOZ" ("LP_LIS", "LPS") ;
--------------------------------------------------------
--  DDL for Index WSPEDM53
--------------------------------------------------------

  CREATE INDEX "WSPEDM53" ON "DRMETPOZ" ("LP_LIS" DESC, "LPS" DESC) ;
--------------------------------------------------------
--  DDL for Index WYCINKI_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "WYCINKI_PK" ON "WYCINKI" ("NR_KOMP_ZLEC", "NR_POZ", "NR_SZT", "NR_WAR") ;
--------------------------------------------------------
--  DDL for Index WYCOPT_01
--------------------------------------------------------

  CREATE UNIQUE INDEX "WYCOPT_01" ON "KOL_STOJAKOW" ("NR_LISTY", "NR_KOMP_ZLEC", "NR_POZ", "NR_SZTUKI", "NR_WARSTWY") ;
--------------------------------------------------------
--  DDL for Index WYCOPT_02
--------------------------------------------------------

  CREATE INDEX "WYCOPT_02" ON "KOL_STOJAKOW" ("NR_OPTYM", "NR_TAF", "RACK_NO") ;
--------------------------------------------------------
--  DDL for Index WYCOPT_03
--------------------------------------------------------

  CREATE UNIQUE INDEX "WYCOPT_03" ON "KOL_STOJAKOW" ("NR_KOMP_ZLEC", "NR_POZ", "NR_SZTUKI", "NR_WARSTWY", "NR_KATALOG", "NR_LISTY") ;
--------------------------------------------------------
--  DDL for Trigger BRAKIB_ON_CREATE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "BRAKIB_ON_CREATE" 
BEFORE INSERT ON BRAKI_B 
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
BEGIN
 SELECT braki_b_seq.nextval INTO :NEW.NR_KOL FROM dual;
END;
/
ALTER TRIGGER "BRAKIB_ON_CREATE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger CALC_KARTOTEKA_ILOSC
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "CALC_KARTOTEKA_ILOSC" 
BEFORE DELETE ON TMPPOZDOK
REFERENCING OLD AS OLD
FOR EACH ROW
--WHEN (OLD.NR_MAG in (0,0))
 WHEN (OLD.ZNACZNIK_KARTOTEKI not in ('Wyr','Czy')) DECLARE
vIlosc kartoteka.ilosc%TYPE;
BEGIN
SELECT sum(ilosc) INTO vIlosc
FROM pozkartot
WHERE nr_oddz=:OLD.nr_oddz AND nr_mag=:OLD.nr_mag AND indeks=:OLD.indeks;-- AND zn_kartoteki=:OLD.znacznik_kartoteki;
UPDATE kartoteka
SET ilosc=nvl(vIlosc,0)
WHERE nr_odz=:OLD.nr_oddz AND nr_mag=:OLD.nr_mag AND indeks=:OLD.indeks;-- AND zn_kart=:OLD.znacznik_kartoteki;
END;
/
ALTER TRIGGER "CALC_KARTOTEKA_ILOSC" ENABLE;
--------------------------------------------------------
--  DDL for Trigger LOG_ODCZYTOW_ONINSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "LOG_ODCZYTOW_ONINSERT" 
BEFORE INSERT ON LOG_ODCZYTOW 
REFERENCING NEW AS NEW 
FOR EACH ROW
DECLARE
 CURSOR cLog (pSID NUMBER) IS
   SELECT operator_ID FROM logowania WHERE session_ID=pSID
   ORDER BY data DESC, czas DESC;
 vOper VARCHAR2(10);  
BEGIN
  -- aktualizacja NR_KOL (unikalny w ramach typu)
  SELECT case when MAX(nr_kol) is null then 1 else MAX(nr_kol)+1 end INTO :NEW.NR_KOL
  FROM LOG_ODCZYTOW
  WHERE LOG_TYP=:NEW.LOG_TYP;
  -- nazwa komputera
  SELECT SYS_CONTEXT('USERENV','SESSIONID'),
         substr(SYS_CONTEXT('USERENV','HOST'),1,30)
    INTO :NEW.SESSION_ID, :NEW.STACJA
  FROM DUAL;
  -- data, czas zapisu
  SELECT trunc(SYSDATE), to_char(SYSDATE,'HH24MISS') INTO :NEW.DATA, :NEW.CZAS
  FROM DUAL;
  -- operator (spr. w tabeli LOGOWANIA)
  IF :NEW.OPER is not null AND :NEW.OPER<>' ' THEN RETURN; END IF;
  OPEN cLog (:NEW.SESSION_ID);
  FETCH cLog INTO vOper;
  IF cLog%NOTFOUND THEN vOper:=' '; END IF;
  CLOSE cLog;
  :NEW.OPER:=vOper;
END LOG_ODCZYTOW_ONINSERT;
/
ALTER TRIGGER "LOG_ODCZYTOW_ONINSERT" ENABLE;
--------------------------------------------------------
--  DDL for Trigger LWYC_WYCINKI
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "LWYC_WYCINKI" AFTER INSERT OR DELETE ON l_wyc
FOR EACH ROW
begin
  if :new.TYP_INST in ('A C','R C') then
    if inserting then
  		INSERT into wycinki(NR_KOMP_ZLEC,NR_POZ,NR_SZT,NR_WAR,CREATED) 
        VALUES(:new.nr_kom_zlec,:new.nr_poz_zlec,:new.nr_szt,:new.nr_warst,sysdate());
    end if;
    if deleting then 
      DELETE from wycinki where NR_KOMP_ZLEC=:old.nr_kom_zlec and NR_POZ=:old.nr_poz_zlec and
        NR_SZT=:old.nr_szt and NR_WAR=:old.nr_warst;
    end if;
  end if;
end;
/
ALTER TRIGGER "LWYC_WYCINKI" DISABLE;
--------------------------------------------------------
--  DDL for Trigger OPT_TAF_INST_PLAN
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "OPT_TAF_INST_PLAN" 
BEFORE INSERT OR UPDATE OF NR_KOMP_INSTAL ON OPT_TAF
REFERENCING NEW AS NEW
FOR EACH ROW
 WHEN (NEW.NR_INST_PLAN=0 or NEW.FLAG=1) BEGIN
:NEW.NR_INST_PLAN:=:NEW.NR_KOMP_INSTAL;
END;
/
ALTER TRIGGER "OPT_TAF_INST_PLAN" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SPISE_ECUTTER
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SPISE_ECUTTER" AFTER INSERT OR UPDATE OR DELETE ON "SPISE"
FOR EACH ROW
DECLARE
  v_wys number(6);
  v_WYK NUMBER(6);
  v_ILE_FAKT NUMBER(6);
  v_IL_A NUMBER(6);
  v_IL_S NUMBER(6);
  v_wys_poz number(6);
  v_wyk_poz number(6);
  v_ila_poz number(6);

  v_nr_komp_zlec NUMBER;
  v_nr_poz NUMBER;
  c number(6);
  c_poz number(6);
  inc_wys number(1);
  inc_wyk number(1);
  inc_ile_fakt number(1);
  inc_il_a number(1);
  inc_il_s number(1);
begin
  v_wys:=0;
  v_wyk:=0;
  v_ile_fakt:=0;
  v_il_a:=0;
  v_il_s:=0;
  v_wyk_poz := 0;
  v_wys_poz := 0;
  v_ila_poz := 0;
  inc_wyk:=0;
  inc_wys:=0;
  inc_ile_fakt:=0;
  inc_il_a:=0;
  inc_il_s:=0;
  v_nr_komp_zlec := 0;
  if inserting then
    v_nr_komp_zlec := :new.nr_komp_zlec;
    v_nr_poz := :new.nr_poz;
  end if;
  if deleting or updating then
    v_nr_komp_zlec := :old.nr_komp_zlec;
    v_nr_poz := :old.nr_poz;
  end if;
	select count(1) into c from ecutter_spise where nr_komp_zlec=v_nr_komp_zlec;
	select count(1) into c_poz from ecutter_spise_poz where nr_komp_zlec=v_nr_komp_zlec and nr_poz=v_nr_poz;
	if c is not null and c=1 then
  	select wys,wyk,ile_fakt,il_a,il_s into v_wys,v_wyk,v_ile_fakt,v_il_a,v_il_s from ecutter_spise where nr_komp_zlec=v_nr_komp_zlec;
  end if;
	if c_poz is not null and c_poz>=1 then
  	select wys,wyk,il_a into v_wys_poz,v_wyk_poz,v_ila_poz from ecutter_spise_poz where nr_komp_zlec=v_nr_komp_zlec and nr_poz=v_nr_poz;
  end if;

  if updating then
    if :old.zn_wyk!=:new.zn_wyk then
      if :old.zn_wyk in (1,2) and not :new.zn_wyk in (1,2) then
        inc_wyk:=-1;
      end if;
      if (:old.zn_wyk!=1 and :old.zn_wyk!=2) and (:new.zn_wyk=1 or :new.zn_wyk=2) then
        inc_wyk:=1;
      end if;
      if :old.zn_wyk=9 then inc_il_a := -1; end if;
      if :old.zn_wyk=9 and :new.flag_real>1 then inc_wys := 1; end if;
      if :new.zn_wyk=9 then
        INC_IL_A := 1;
--        inc_wys := -1;
      end if;
      if :new.ZN_WYK=9 and :old.FLAG_REAL>1 then INC_WYS := -1; end if;
    end if;
    if :old.flag_real!=:new.flag_real then
      if :old.flag_real<=1 and :new.flag_real>1 and :new.zn_wyk in (1,2) then
        inc_wys := 1;
      end if;
      if :old.flag_real>1 and :new.flag_real<=1 then inc_wys := -1; end if;
    end if;

  end if;
  if deleting then
    inc_wyk:=-1;
    inc_wys:=-1;
    inc_il_a:=-1;
  end if;
  if inserting then
    if :new.zn_wyk in (1,2) then inc_wyk := 1; end if;
    if :new.zn_wyk=9 then inc_il_a := 1; end if;
    if :new.flag_real>1 and :new.nr_sped>0 and :new.zn_wyk in (1,2) then inc_wys := 1; end if;
  end if;

  v_wyk := v_wyk+inc_wyk;
  v_wys := v_wys+inc_wys;
  v_ile_fakt := v_ile_fakt+inc_ile_fakt;
  v_il_a := v_il_a+inc_il_a;
  v_il_s := v_il_s+inc_il_s;
  v_wyk_poz := v_wyk_poz+inc_wyk;
  v_wys_poz := v_wys_poz+inc_wys;
  v_ila_poz := v_ila_poz+inc_il_a;

  if v_wyk<0 then v_wyk:=0; end if;
  if v_wys<0 then v_wys:=0; end if;
  if v_ile_fakt<0 then v_ile_fakt:=0; end if;
  if v_il_a<0 then v_il_a:=0; end if;
  if v_il_s<0 then v_il_s:=0; end if;
  if v_wyk_poz<0 then v_wyk_poz:=0; end if;
  if v_wys_poz<0 then v_wys_poz:=0; end if;
  if v_ila_poz<0 then v_ila_poz:=0; end if;

	if c is not null and c>0 then
		UPDATE ecutter_spise SET WYS=v_wys,WYK=v_wyk,ILE_FAKT=V_ile_fakt,IL_A=v_il_a,IL_S=v_il_s where nr_komp_zlec=v_nr_komp_zlec;
		UPDATE ecutter_spise_poz SET WYS=v_wys,WYK=v_wyk,IL_A=v_ila_poz where nr_komp_zlec=v_nr_komp_zlec and nr_poz=v_nr_poz;
	else
		INSERT into ecutter_spise(nr_komp_zlec,wys,wyk,ile_fakt,il_a,il_s) VALUES(v_nr_komp_zlec,v_wys,v_wyk,v_ile_fakt,v_il_a,v_il_s);
		INSERT into ecutter_spise_poz(nr_komp_zlec,nr_poz,wys,wyk,il_a) VALUES(v_nr_komp_zlec,v_nr_poz,v_wys,v_wyk,v_ila_poz);
	end if;
end;
/
ALTER TRIGGER "SPISE_ECUTTER" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SPISE_ON_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SPISE_ON_UPDATE" 
BEFORE UPDATE OF NR_KOM_SZYBY, NR_SZT, NR_STOJ_PROD, POZ_ST_PR, DATA_WYK, ZM_WYK, NR_KOMP_INST, O_WYK, ZN_WYK ON SPISE 
REFERENCING OLD AS OLD NEW AS NEW 
FOR EACH ROW
declare
 opis VARCHAR2(200);
 tmp NUMBER;
BEGIN
  --aktualizacja l_wyc dla MON
  IF :OLD.NR_KOMP_INST<>:NEW.NR_KOMP_INST OR
     :OLD.NR_STOJ_PROD<>:NEW.NR_STOJ_PROD OR
     --:OLD.POZ_ST_PR<>:NEW.POZ_ST_PR OR
     :OLD.DATA_WYK<>:NEW.DATA_WYK OR
     :OLD.ZM_WYK<>:NEW.ZM_WYK OR
     :OLD.O_WYK<>:NEW.O_WYK THEN
   SELECT count(1) INTO tmp FROM parinst
   WHERE nr_komp_inst=case when :OLD.NR_KOMP_INST>0 then :OLD.NR_KOMP_INST else :NEW.NR_KOMP_INST end
     AND ty_inst in ('MON','STR');--5286085
   IF tmp=1 THEN --gdy instalacja MONtazowa
    SELECT count(1) INTO tmp FROM l_wyc
    WHERE nr_kom_zlec=:OLD.NR_KOMP_ZLEC AND nr_poz_zlec=:OLD.NR_POZ AND nr_szt=:OLD.NR_SZT AND typ_inst='MON'
      AND nr_inst_wyk=:NEW.NR_KOMP_INST AND d_wyk=:NEW.DATA_WYK AND zm_wyk=:NEW.ZM_WYK AND nr_stoj=:NEW.NR_STOJ_PROD AND op=:NEW.O_WYK;
    IF tmp is null or tmp=0 THEN --gdy nie ma podobnego rekordu w l_wyc 
     PKG_REJESTRACJA.POPRAW_MON_W_L_WYC(:OLD.NR_KOMP_ZLEC, :OLD.NR_POZ, :OLD.NR_SZT,
                                        :NEW.NR_KOMP_INST, :NEW.DATA_WYK, :NEW.ZM_WYK, :NEW.NR_STOJ_PROD, :NEW.POZ_ST_PR, :NEW.O_WYK);
     END IF;
   END IF;
  END IF;   
  --logowanie zmian
  opis:='SPISE';
  IF :OLD.NR_KOM_SZYBY<>:NEW.NR_KOM_SZYBY THEN
   opis:=opis||'.NR_KOM_SZYBY:'||to_char(:OLD.NR_KOM_SZYBY)||'->'||to_char(:NEW.NR_KOM_SZYBY);
  ELSIF :OLD.NR_SZT<>:NEW.NR_SZT THEN
   opis:=opis||'.NR_SZT:'||to_char(:OLD.NR_SZT)||'->'||to_char(:NEW.NR_SZT);
  ELSIF NOT (:OLD.ZN_WYK>1 OR :NEW.ZN_WYK=9 OR :OLD.NR_KOMP_INST>0 AND NOT :OLD.NR_KOMP_INST=:NEW.NR_KOMP_INST) THEN
    RETURN;
  END IF;
  
  IF :OLD.NR_STOJ_PROD<>:NEW.NR_STOJ_PROD THEN
   opis:=opis||'.NR_STOJ_PROD:'||to_char(:OLD.NR_STOJ_PROD)||'->'||to_char(:NEW.NR_STOJ_PROD);
  END IF;
  IF :OLD.DATA_WYK<>:NEW.DATA_WYK THEN
   opis:=opis||'.DATA_WYK:'||to_char(:OLD.DATA_WYK,'YYYYMMDD')||'->'||to_char(:NEW.DATA_WYK,'YYYYMMDD');
  END IF;
  IF :OLD.NR_KOMP_INST<>:NEW.NR_KOMP_INST THEN
   opis:=opis||'.NR_KOMP_INST:'||to_char(:OLD.NR_KOMP_INST)||'->'||to_char(:NEW.NR_KOMP_INST);
  END IF;
  IF :OLD.ZN_WYK<>:NEW.ZN_WYK THEN
   opis:=opis||'.ZN_WYK:'||to_char(:OLD.ZN_WYK)||'->'||to_char(:NEW.ZN_WYK);
  END IF;
  
  INSERT INTO log_odczytow (log_typ,nr_komp_inst,nr_komp_zlec,ident2,ident3,ident4,nr_komp_zm,flag,tekst)
  VALUES ('TR',0,:OLD.NR_KOMP_ZLEC,:NEW.NR_KOM_SZYBY,:NEW.NR_POZ,:NEW.NR_SZT,
          PKG_CZAS.NR_KOMP_ZM(:OLD.DATA_WYK,:OLD.ZM_WYK),:NEW.ZN_WYK,SUBSTR(OPIS,1,100));

END SPISE_ON_UPDATE;
/
ALTER TRIGGER "SPISE_ON_UPDATE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SPISE_ON_WYK
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SPISE_ON_WYK" 
BEFORE UPDATE OF DATA_WYK, ZN_WYK ON SPISE 
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
BEGIN
  PKG_REJESTRACJA.UZUPELNIJ_L_WYC(:NEW.NR_KOM_SZYBY, :NEW.NR_KOMP_ZLEC, :NEW.NR_POZ, :NEW.NR_SZT, 0,
                                0, 2, 0, 0, :NEW.DATA_WYK, :NEW.ZM_WYK, 0, 0,
                                case when :NEW.DATA_WYK>to_date('2001','YYYY') then 1 else 0 end);
END;
/
ALTER TRIGGER "SPISE_ON_WYK" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SQL_HIST_ID_TR
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SQL_HIST_ID_TR" 
   before insert on "SQL_HISTORIA" 
   for each row 
begin  
   if inserting then 
      if :NEW."HIS_ID" is null OR :NEW.HIS_ID=0 then 
         select SQL_hist_seq.nextval into :NEW."HIS_ID" from dual; 
      end if; 
   end if; 
end;
/
ALTER TRIGGER "SQL_HIST_ID_TR" ENABLE;
--------------------------------------------------------
--  DDL for Trigger STATUS_ZLEC_ON_CHANGE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "STATUS_ZLEC_ON_CHANGE" 
AFTER INSERT OR UPDATE OF STATUS ON STATUSY_ZLEC 
REFERENCING OLD AS OLD NEW AS NEW 
for each row
--declare
--  czy_metki zamow.nr_kom_zlec%type;
BEGIN
  Insert into statusy_zlec_log(nr_komp_zlec,status,status_last,"DATA",czas,operator,komputer) 
    values(:new.nr_komp_zlec,:new.status,:old.status,sysdate,to_char(sysdate(),'HH24MISS'),:new.operator,:new.komputer);
--gdy 3->4 blokada zlecenia
--  if :old.status=3  and :new.status=4 then
--    select max(nr_komp_zlec) into czy_metki from spise where nr_komp_zlec=:new.nr_komp_zlec and nr_poz=1 and nr_szt=1;
--    if czy_metki is null then 
--      update zamow set flag_r=to_number(rep_str(lpad(flag_r,6,'0'),1,4)) where nr_kom_zlec=:new.nr_komp_zlec and substr(lpad(flag_r,6,'0'),4,1)='0';
--      
      -- zapêtlanie "w kolko" z drugim triggerem
--    end if;
--  end if;
--gdy 4->3 odblokowanie zlecenia
--  if :old.status=4  and :new.status=3 then
--    select max(nr_komp_zlec) into czy_metki from spise where nr_komp_zlec=:new.nr_komp_zlec and nr_poz=1 and nr_szt=1;
--    if czy_metki is null then 
--      update zamow set flag_r=to_number(rep_str(lpad(flag_r,6,'0'),0,4)) where nr_kom_zlec=:new.nr_komp_zlec and substr(lpad(flag_r,6,'0'),4,1)='1';
--    end if;
--  end if;
END;
/
ALTER TRIGGER "STATUS_ZLEC_ON_CHANGE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger UPDATEKODPASKONINSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "UPDATEKODPASKONINSERT" 
AFTER INSERT ON "SPISE"
FOR EACH ROW
BEGIN
UPDATE l_wyc
SET kod_pask=ltrim(to_char(:new.Nr_kom_szyby*100+nr_warst,'990000000000')),
nr_ser=:new.Nr_kom_szyby*100+nr_warst
	WHERE nr_kom_zlec=:new.Nr_komp_zlec and nr_poz_zlec=:new.Nr_poz
	and nr_szt=:new.Nr_szt;

UPDATE l_wyc
SET id_rek=lwyc_seq.nextval
WHERE nr_kom_zlec=:new.Nr_komp_zlec and nr_poz_zlec=:new.Nr_poz
	     and nr_szt=:new.Nr_szt and id_rek=0;
END UpdatekodpaskOnInsert;
/
ALTER TRIGGER "UPDATEKODPASKONINSERT" ENABLE;
--------------------------------------------------------
--  DDL for Trigger ZAMOW_ON_CHANGE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "ZAMOW_ON_CHANGE" 
AFTER INSERT OR UPDATE or delete ON ZAMOW 
REFERENCING OLD AS OLD NEW AS NEW 
for each row
declare
  s statusy_zlec.status%type;
  r rpzlec%rowtype;
  c integer;
  vSID NUMBER:=0;
  vOper logowania.operator_id%type;
  vHost logowania.host%type;
BEGIN
 SELECT SYS_CONTEXT('USERENV','SESSIONID') INTO vSID FROM DUAL;
 
 SELECT nvl(max(operator_id),'-----') INTO vOper
 FROM (select rownum lp, operator_id from (select operator_id from logowania where session_ID=vSID order by "DATA" desc, CZAS desc))
 WHERE lp=1;

 SELECT nvl(max(host),' ') INTO vHost
 FROM (select rownum lp, host from (select host from logowania where session_ID=vSID order by "DATA" desc, CZAS desc))
 WHERE lp=1;

-- pobranie aktualnego statusu zlecenia
    select max(status) into s from statusy_zlec where nr_komp_zlec=:new.nr_kom_zlec;
  if inserting then
-- dla nowego zlecenia wpisujemy status Zarejestrowane 0
    if s is null then
      insert into STATUSY_ZLEC(nr_komp_zlec,status,operator,komputer) values(:new.nr_kom_zlec,0,vOper,vHost);
    end if;
  end if;
  if updating then
-- je¿eli zlecenie kierujemy do produkcji zmieniamy status na Opracowane 2 (wersja zmien Dane)
    if :new.forma_wprow='P' and :old.do_produkcji=0 and :new.do_produkcji=1 and s<2 then
      update statusy_zlec set status=2,operator=vOper,komputer=vHost where nr_komp_zlec=:new.nr_kom_zlec;
    end if;
-- zablokuj
    if :old.flag_r=0 and :new.flag_r=100 and s=3 then
      update statusy_zlec set status=4,operator=vOper,komputer=vHost where nr_komp_zlec=:new.nr_kom_zlec;
    end if;
-- zablokuj
    if :old.flag_r=100 and :new.flag_r=0 and s=4 then
      update statusy_zlec set status=3,operator=vOper,komputer=vHost where nr_komp_zlec=:new.nr_kom_zlec;
    end if;
  end if;
  
  
  if deleting then
-- pobranie aktualnego statusu zlecenia
    select max(status) into s from statusy_zlec where nr_komp_zlec=:old.nr_kom_zlec;
-- je¿eli zlecenie kierujemy do produkcji zmieniamy status na Opracowane 2 (wersja zmien Zlecenie, wykorzystuje RPZLEC)
    select count(*) into c from rpzlec where nkomp=:old.nr_kom_zlec;
    if c>0 then
      select * into r from rpzlec where nkomp=:old.nr_kom_zlec;
      if s>=0 and s<2 and r.skier_do_prod=1 and r.forma_wpr='P' and :old.do_produkcji=0 then
        update statusy_zlec set status=2,operator=vOper,komputer=vHost where nr_komp_zlec=:old.nr_kom_zlec;
      end if;
    end if;
  end if;
END;
/
ALTER TRIGGER "ZAMOW_ON_CHANGE" ENABLE;
--------------------------------------------------------
--  DDL for Procedure AKTREZSUR
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "AKTREZSUR" ( 
ZM_INDEXSUR IN VARCHAR2 DEFAULT '',
ZM_NRMAG IN NUMBER DEFAULT 0
)
AS
BEGIN
declare
CURSOR C1  IS
SELECT SUM( (IL_ZAD-rw_POB)/(1-0.01*STRATY))  FROM SURZAM
WHERE (IL_ZAD-rw_POB)>0.05 AND RODZ_SUR<>'CZY' AND indeks=ZM_INDEXSUR and NR_MAG=ZM_NRMAG AND
NR_KOMP_ZLEC IN (SELECT NR_KOM_ZLEC FROM ZAMOW 
WHERE TYP_ZLEC='Pro' and wyroznik<>'O' and forma_wprow='P' and status='P');
-------------
zm_rezerwacja kartoteka.rezeracja%TYPE;
------------
begin
OPEN   C1;

FETCH  C1 INTO zm_rezerwacja;
close c1;
if zm_rezerwacja>0 then
UPDATE KARTOTEKA SET REZERACJA=zm_rezerwacja
WHERE KARTOTEKA.NR_MAG=ZM_NRMAG AND KARTOTEKA.INDEKS=ZM_INDEXSUR; 
else
UPDATE KARTOTEKA SET REZERACJA=0
WHERE KARTOTEKA.NR_MAG=ZM_NRMAG AND KARTOTEKA.INDEKS=ZM_INDEXSUR;
end if;
commit;
END;
end;

/
--------------------------------------------------------
--  DDL for Procedure AKTREZZLEC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "AKTREZZLEC" (
ZM_NR_KOMP_ZLEC IN NUMBER DEFAULT(0)
)
AS
BEGIN
DECLARE
   CURSOR CSURZ  IS
   SELECT SURZAM.INDEKS, SURZAM.NR_MAG FROM SURZAM 
   WHERE SURZAM.NR_KOMP_ZLEC= ZM_NR_KOMP_ZLEC AND RODZ_SUR<>'CZY';

ZM_INDEXSUR SURZAM.INDEKS%TYPE;
ZM_NRMAG SURZAM.NR_MAG%TYPE;
   
BEGIN
OPEN CSURZ;
  LOOP
    FETCH CSURZ INTO ZM_INDEXSUR,ZM_NRMAG;
    exit when CSURZ%NOTFOUND;
    AKTREZSUR(ZM_INDEXSUR,ZM_NRMAG);
  END LOOP;
CLOSE CSURZ;
END;
END;

/
--------------------------------------------------------
--  DDL for Procedure CREATE_KOL_STOJAKOW
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CREATE_KOL_STOJAKOW" (pNK_ZLEC NUMBER) AS
vLista NUMBER(10);
BEGIN
SELECT nvl(max(nr_listy),0) INTO vLista FROM pamlist WHERE nr_k_zlec=pNK_ZLEC;
INSERT INTO kol_stojakow (nr_listy, nr_komp_zlec, nr_poz, nr_sztuki, nr_warstwy,
typ_katalog, nr_katalog,
nr_stoj_ciecia, poz_stojaka_ciecia, poz_stojaka_docel,
serialno, rack_no, nr_grupy, nr_podgrupy,
nr_optym, nr_taf, nr_instalacji,lista_inst, symbol)
SELECT vLista, L.nr_kom_zlec, L.nr_poz_zlec, L.nr_szt, L.nr_warst,
K.typ_kat, K.nr_kat, 0, 0, 0,
0, 0, Z.nr_szar, Z.nr_podgr,
0, 0, L.nr_inst_nast, ' ', ' '
FROM l_wyc L
LEFT JOIN spisz Z ON Z.nr_kom_zlec=L.nr_kom_zlec and Z.nr_poz=L.nr_poz_zlec
LEFT JOIN katalog K ON K.typ_kat=L.typ_kat
WHERE L.nr_kom_zlec=pNK_ZLEC AND L.typ_inst in ('A C','R C')
AND K.nr_kat is not null
AND NOT EXISTS (select 1 from kol_stojakow
where nr_komp_zlec=L.nr_kom_zlec and nr_poz=L.nr_poz_zlec
and nr_sztuki=L.nr_szt and nr_warstwy=L.nr_warst);
END CREATE_KOL_STOJAKOW;

/
--------------------------------------------------------
--  DDL for Procedure NEXTSERIALNUMBER
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "NEXTSERIALNUMBER" (pIle IN NUMBER, pOstPrzedRez OUT NUMBER, pSukces OUT NUMBER)
AS
  cNUMER_PARAMETRU CONSTANT NUMBER := 42;
  cNAZWA_PARAMETRU CONSTANT VARCHAR2(100) := 'Ostatni numer seryjny';
  CURSOR c1 IS
  SELECT ost_nr FROM konfig_t
  WHERE nr_par=cNUMER_PARAMETRU
  FOR UPDATE;
  
  vOstNr KONFIG_T.OST_NR%type;
  vMaxSpise NUMBER;
begin
  pOstPrzedRez := null;
  pSukces := 0;
  SELECT max(nr_kom_szyby) INTO vMaxSpise FROM spise;
  IF vMaxSpise is null THEN
   vMaxSpise:=0;
  END IF;
  
  OPEN C1;
  FETCH C1 INTO vOstNr;
  IF vOstNr is not null THEN
   UPDATE konfig_t SET ost_nr=greatest(vMaxSpise,ost_nr)+pIle WHERE CURRENT OF C1;
   pOstPrzedRez := greatest(vOstNr,vMaxSpise);
   pSukces := 1;
  ELSE
   INSERT INTO konfig_t (nr_par, ost_nr, opis, opis_lang)
               VALUES (cNUMER_PARAMETRU, vMaxSpise+pIle, cNAZWA_PARAMETRU, cNAZWA_PARAMETRU);
   pOstPrzedRez := vMaxSpise;
   pSukces := 1;
  END IF;
  CLOSE C1;
  COMMIT;
  
END NEXTSERIALNUMBER;

/
--------------------------------------------------------
--  DDL for Procedure OPT_TO_KOL_STOJAKOW
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "OPT_TO_KOL_STOJAKOW" (pNK_ZLEC NUMBER, pNR_KAT NUMBER DEFAULT 0)
AS
cursor k1 (pPOZ NUMBER, pKAT NUMBER, pOPT NUMBER, pTAF NUMBER) IS
SELECT * FROM kol_stojakow
WHERE nr_komp_zlec=pNK_ZLEC and nr_poz=pPOZ and nr_katalog=pKAT and nr_optym<-0
ORDER BY nr_sztuki, nr_warstwy,
case when nr_optym=-pOPT and nr_taf=pTAF then 1
when nr_optym=0 then 2
else 9 end
FOR UPDATE;
recK k1%ROWTYPE;
i NUMBER(10);
BEGIN
UPDATE kol_stojakow  --ustawienie minusowych NR_OPT
SET nr_optym=-abs(nr_optym)
WHERE nr_komp_zlec=pNK_ZLEC and pNR_KAT in (0,nr_katalog);
FOR o IN
(select nr_poz, nr_opt, nr_tafli, max(nr_kat) nr_kat, sum(il_wyc) il_opt,
count((select 1 from kol_stojakow
where nr_komp_zlec=opt_zlec.nr_komp_zlec and nr_poz=opt_zlec.nr_poz
and nr_katalog=opt_zlec.nr_kat and nr_optym=opt_zlec.nr_opt
and nr_taf=opt_zlec.nr_tafli)) il_kol
from opt_zlec
where nr_komp_zlec=pNK_ZLEC  and pNR_KAT in (0,nr_kat)
group by nr_opt, nr_tafli, nr_poz
--   having sum(il_wyc)<>count((select 1 from kol_stojakow
--                              where nr_komp_zlec=opt_zlec.nr_komp_zlec and nr_poz=opt_zlec.nr_poz
--                                and nr_katalog=opt_zlec.nr_kat and nr_optym=opt_zlec.nr_opt
--                                and nr_taf=opt_zlec.nr_tafli))
order by nr_poz, il_opt-il_kol) --najpierw nadmiarowe w KOL_STAJAKOW
LOOP
--IF o.il_opt<o.il_kol THEN
i:=0;
OPEN k1(o.nr_poz,o.nr_kat,o.nr_opt,o.nr_tafli);
LOOP
FETCH k1 INTO recK;
EXIT WHEN k1%NOTFOUND;
i:=i+1;
IF i<=o.il_opt THEN
UPDATE kol_stojakow SET nr_optym=o.nr_opt, nr_taf=o.nr_tafli
WHERE CURRENT OF k1;
ELSE
EXIT;
END IF;
END LOOP; --koniec pêtli po KOL_STOJAKOW
CLOSE k1;
--END IF;
END LOOP;
END OPT_TO_KOL_STOJAKOW;

/
--------------------------------------------------------
--  DDL for Procedure PRZYPISZ_WZ_W_SPISE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "PRZYPISZ_WZ_W_SPISE" (pNR_KOMP_ZLEC IN NUMBER, pNR_POZ IN NUMBER DEFAULT 0)
AS
CURSOR cWZ (pZLEC NUMBER, pPOZ NUMBER)
IS SELECT * FROM pozdok
WHERE typ_dok='WZ' and nr_komp_baz=pZLEC and nr_poz_zlec=pPOZ and storno=0
AND NOT EXISTS (select 1 from spise where nr_komp_zlec=pZLEC and nr_poz=pPOZ and nr_k_WZ=pozdok.nr_komp_dok and nr_poz_WZ=pozdok.nr_poz)
ORDER BY nr_dok_zrod, nr_komp_dok, nr_poz;
CURSOR cE (pZLEC NUMBER, pPOZ NUMBER, pDATA_WZ DATE DEFAULT '01/01/01')
--IS select nr_komp_zlec, nr_poz, nr_sped, max(data_sped) data_sped, max(sign(nr_k_WZ*nr_poz_WZ)) wpisWZ, count(1) il
IS SELECT * FROM spise
WHERE nr_komp_zlec=pZLEC and nr_poz=pPOZ and nr_k_WZ=0
and (pDATA_WZ='01/01/01' or nr_sped>0 and data_sped=pDATA_WZ)
--ORDER BY data_wyk, zm_wyk, nr_sped
ORDER BY sign(nr_sped) desc, data_wyk, zm_wyk, data_sped, nr_sped
--najpierw niezerowe spedycje, potem wg daty wyprodukowania i daty sped
FOR UPDATE;
recWZ cWZ%ROWTYPE;
recE  cE%ROWTYPE;
vIl  NUMBER(4);
vIlSped NUMBER(2);
vNrSped NUMBER(10);
BEGIN
FOR poz IN (select nr_kom_zlec, nr_poz from spisz
where nr_kom_zlec=pNR_KOMP_ZLEC and (pNR_POZ=0 or nr_poz=pNR_POZ)
and spise_vs_wz_err(nr_kom_zlec, nr_poz)>0)
LOOP
UPDATE spise SET nr_k_WZ=0, nr_poz_WZ=0 WHERE nr_komp_zlec=poz.nr_kom_zlec and nr_poz=poz.nr_poz;
--KROK 1: szukanie spedycji z identyczn¹ dat¹ ni¿ data WZ i t¹ sam¹ iloœci¹
OPEN cWZ (poz.nr_kom_zlec, poz.nr_poz);
LOOP
FETCH cWZ INTO recWZ;
EXIT WHEN cWZ%NOTFOUND;
select count(1), count(distinct nr_sped) into vIl, vIlSped
from spise
where nr_komp_zlec=poz.nr_kom_zlec and nr_poz=poz.nr_poz and data_sped=recWZ.data_d
and nr_sped>0 and nr_k_WZ=0;
IF vIl=recWZ.ilosc_jr and vIlSped=1 THEN
UPDATE spise
SET nr_k_WZ=recWZ.nr_komp_dok, nr_poz_WZ=recWZ.nr_poz
WHERE nr_komp_zlec=poz.nr_kom_zlec and nr_poz=poz.nr_poz and data_sped=recWZ.data_d
and nr_sped>0 and nr_k_WZ=0;
dbms_output.put_line(recWZ.nr_dok||'/'||recWZ.nr_poz||' UPDATE1');
CONTINUE;
END IF;
END LOOP;
CLOSE cWZ;
--KROK 2 : szukanie spedycji z odpowiedni¹ ilosci¹ sztuk
OPEN cWZ (poz.nr_kom_zlec, poz.nr_poz);
LOOP
FETCH cWZ INTO recWZ;
EXIT WHEN cWZ%NOTFOUND;
vNrSped:=0;
select nvl(min(nr_sped),0) into vNrSped from
(select nr_sped, count(1) il
from spise
where nr_komp_zlec=poz.nr_kom_zlec and nr_poz=poz.nr_poz and data_sped<=recWZ.data_d
and nr_sped>0 and nr_k_WZ=0
group by nr_sped
)
where il=recWZ.ilosc_jr;
IF vNrSped>0 THEN
UPDATE spise
SET nr_k_WZ=recWZ.nr_komp_dok, nr_poz_WZ=recWZ.nr_poz
WHERE nr_komp_zlec=poz.nr_kom_zlec and nr_poz=poz.nr_poz and nr_sped=vNrSped and data_sped<=recWZ.data_d and nr_k_WZ=0;
dbms_output.put_line(recWZ.nr_dok||'/'||recWZ.nr_poz||' UPDATE2');
CONTINUE;
END IF;
END LOOP;
CLOSE cWZ;
--KROK 3: zapis po kolei jesli data_sped=data_WZ
OPEN cWZ (poz.nr_kom_zlec, poz.nr_poz);
LOOP
FETCH cWZ INTO recWZ;
EXIT WHEN cWZ%NOTFOUND;
vIl:=0;
OPEN cE (poz.nr_kom_zlec, poz.nr_poz, recWZ.data_d);
LOOP
FETCH cE INTO recE;
EXIT WHEN cE%NOTFOUND;
UPDATE spise
SET nr_k_WZ=recWZ.nr_komp_dok, nr_poz_WZ=recWZ.nr_poz
WHERE current of cE;
vIl:=vIl+1;
EXIT WHEN vIl=recWZ.ilosc_jr;
END LOOP;
CLOSE cE;
--cofniecie przypisaniea je¿eli nie znaleziono tylu szyb ile jest w WZ
IF vIl<>recWZ.ilosc_jr THEN
UPDATE spise
SET nr_k_WZ=0, nr_poz_WZ=0
WHERE nr_k_WZ=recWZ.nr_komp_dok and nr_poz_WZ=recWZ.nr_poz;
ELSE
dbms_output.put_line(recWZ.nr_dok||'/'||recWZ.nr_poz||' UPDATE3');
END IF;
END LOOP;
CLOSE cWZ;
--KROK 4: zapis po kolei wg wyprod.
OPEN cWZ (poz.nr_kom_zlec, poz.nr_poz);
LOOP
FETCH cWZ INTO recWZ;
EXIT WHEN cWZ%NOTFOUND;
vIl:=0;
OPEN cE (poz.nr_kom_zlec, poz.nr_poz);
LOOP
FETCH cE INTO recE;
EXIT WHEN cE%NOTFOUND;
UPDATE spise
SET nr_k_WZ=recWZ.nr_komp_dok, nr_poz_WZ=recWZ.nr_poz
WHERE current of cE;
vIl:=vIl+1;
EXIT WHEN vIl=recWZ.ilosc_jr;
END LOOP;
CLOSE cE;
IF vIl=recWZ.ilosc_jr THEN
dbms_output.put_line(recWZ.nr_dok||'/'||recWZ.nr_poz||' UPDATE4');
ELSE
dbms_output.put_line('Nie przypisana pozycja WZ: '||recWZ.nr_dok||'/'||recWZ.nr_poz);
END IF;
END LOOP;
CLOSE cWZ;
END LOOP;
END PRZYPISZ_WZ_W_SPISE;

/
--------------------------------------------------------
--  DDL for Procedure UPDATE_ECUTTER_SPISE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "UPDATE_ECUTTER_SPISE" as
  v_nr_kon klient.nr_kon%TYPE;
  CURSOR KlientCursor is
    select nr_kon from klient;
begin
  open KlientCursor;
  loop
    fetch KlientCursor into v_nr_kon;
    exit when KlientCursor%NOTFOUND;
    update_ecutter_spise_kon(v_nr_kon);
    update_ecutter_spise_poz(v_nr_kon);
  end loop;
  close KlientCursor;
end;

/
--------------------------------------------------------
--  DDL for Procedure UPDATE_ECUTTER_SPISE_KON
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "UPDATE_ECUTTER_SPISE_KON" (p_nr_kon in number) as
  v_nr_komp_zlec zamow.nr_kom_zlec%TYPE;
  v_wys number;
  v_wyk number;
  v_ile_fakt number;
  v_il_a number;
  v_il_s number;
  c number;
  CURSOR ZamowCursor is
    select nr_kom_zlec from zamow where nr_kon=p_nr_kon;
begin
  open ZamowCursor;
  loop
    fetch ZamowCursor into v_nr_komp_zlec;
    exit when ZamowCursor%NOTFOUND;
    select count(1) into v_WYS from spise where flag_real>1 and nr_sped>0 and (zn_wyk=1 or zn_wyk=2) and nr_komp_zlec=v_nr_komp_zlec;
    select count(1) into v_WYK from spise where (zn_wyk=1 or zn_wyk=2) and nr_komp_zlec=v_nr_komp_zlec;
    select count(1) into v_ILE_FAKT from fakpoz where id_zlec=v_nr_komp_zlec;
    select count(1) into v_IL_A from spise where zn_wyk=9 and nr_komp_zlec=v_nr_komp_zlec;
    select count(1) into v_IL_S from spisd where IDENT_SZP>0 and nr_kom_zlec=v_nr_komp_zlec;

    select count(1) into c from ecutter_spise where nr_komp_zlec=v_nr_komp_zlec;
    if c is not null and c>0 then
      UPDATE ecutter_spise SET WYS=v_wys,WYK=v_wyk,ILE_FAKT=V_ile_fakt,IL_A=v_il_a,IL_S=v_il_s where nr_komp_zlec=v_nr_komp_zlec;
    else
      insert into ecutter_spise(nr_komp_zlec,wyk,wys,ile_fakt,il_a,il_s) values(v_nr_komp_zlec,v_wyk,v_wys,v_ile_fakt,v_il_a,v_il_s);
    end if;
    update_ecutter_spise_poz(v_nr_komp_zlec);
  end loop;
	dbms_output.put_line('Wykonano update tablei ecutter_spise dla klienta: '||to_Char(p_nr_kon));
  close ZamowCursor;
end;

/
--------------------------------------------------------
--  DDL for Procedure UPDATE_ECUTTER_SPISE_POZ
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "UPDATE_ECUTTER_SPISE_POZ" (p_nr_kom_zlec in number) as
  v_nr_poz spisz.nr_poz%TYPE;
  v_wys number;
  v_wyk number;
  v_il_a number;
  c number;
  CURSOR PozycjeCursor is
    select nr_poz from spisz where nr_kom_zlec=p_nr_kom_zlec;
begin
  open PozycjeCursor;
  loop
    fetch PozycjeCursor into v_nr_poz;
    exit when PozycjeCursor%NOTFOUND;
    select count(1) into v_WYS from spise where flag_real>1 and nr_sped>0 and (zn_wyk=1 or zn_wyk=2) and nr_komp_zlec=p_nr_kom_zlec and nr_poz=v_nr_poz;
    select count(1) into v_WYK from spise where (zn_wyk=1 or zn_wyk=2) and nr_komp_zlec=p_nr_kom_zlec and nr_poz=v_nr_poz;
    select count(1) into v_IL_A from spise where zn_wyk=9 and nr_komp_zlec=p_nr_kom_zlec and nr_poz=v_nr_poz;
    select count(1) into c from ecutter_spise_poz where nr_komp_zlec=p_nr_kom_zlec and nr_poz=v_nr_poz;
    if c is not null and c>0 then
      UPDATE ecutter_spise_poz SET WYS=v_wys,WYK=v_wyk,il_a=v_il_a where nr_komp_zlec=p_nr_kom_zlec and nr_poz=v_nr_poz;
    else
      insert into ecutter_spise_poz(nr_komp_zlec,nr_poz,wyk,wys,il_a) values(p_nr_kom_zlec,v_nr_poz,v_wyk,v_wys,v_il_a);
    end if;
  end loop;
	dbms_output.put_line('Wykonano update tablei ecutter_spise_poz dla zlecenia: '||to_Char(p_nr_kom_zlec));
  close PozycjeCursor;
end;

/
--------------------------------------------------------
--  DDL for Procedure UPDATE_WYCINKI_FROM_LWYC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "UPDATE_WYCINKI_FROM_LWYC" as
  c number;
  CURSOR lwycCursor is
    select nr_kom_zlec,nr_poz_zlec,nr_szt,nr_warst from l_wyc where typ_inst in ('A C','R C');
  reclwyc lwycCursor%ROWTYPE;
begin
  open lwycCursor;
  loop
    fetch lwycCursor into reclwyc;
    exit when lwycCursor%NOTFOUND;

    select count(1) into c from wycinki where nr_komp_zlec=reclwyc.nr_kom_zlec and nr_poz=reclwyc.nr_poz_zlec 
      and nr_szt=reclwyc.nr_szt and nr_war=reclwyc.nr_warst;
    if c=0 then
  		INSERT into wycinki(NR_KOMP_ZLEC,NR_POZ,NR_SZT,NR_WAR,CREATED) 
        VALUES(reclwyc.nr_kom_zlec,reclwyc.nr_poz_zlec,reclwyc.nr_szt,reclwyc.nr_warst,sysdate());
    end if;
  end loop;
  close lwycCursor;
end;

/
--------------------------------------------------------
--  DDL for Procedure ZAMKNIJ_STOJAK
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ZAMKNIJ_STOJAK" 
( pNR_STOJ IN NUMBER
) AS
  paczka number;
BEGIN
  paczka := PKG_MAIN.GET_KONFIG_T(24,'Nr paczki w l_wyc');
  UPDATE l_wyc
  SET zn_stoj=paczka
  WHERE nr_stoj=pNR_STOJ and zn_stoj=0;
END ZAMKNIJ_STOJAK;

/
--------------------------------------------------------
--  DDL for Procedure ZAMKNIJ_STOJAKI
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ZAMKNIJ_STOJAKI" 
( pNR_INST IN NUMBER, pNR_KOMP_ZM IN NUMBER
) AS 
  CURSOR c1 IS
            SELECT DISTINCT nr_stoj
            FROM l_wyc
            WHERE zn_stoj=0 AND nr_stoj>0
              AND (pNR_INST=0 or nr_inst=pNR_INST)
              AND (pNR_KOMP_ZM=0 or PKG_CZAS.NR_KOMP_ZM(d_wyk,zm_wyk)=pNR_KOMP_ZM);
              --AND (pNR_KOMP_ZM=0 or NR_KOMP_ZM(d_wyk,zm_wyk)=pNR_KOMP_ZM);
 vStoj NUMBER(10);                           
BEGIN
  OPEN c1;
  LOOP
   FETCH c1 INTO vStoj;
   EXIT WHEN c1%NOTFOUND;
   ZAMKNIJ_STOJAK(vStoj);
  END LOOP;
  CLOSE c1;
END ZAMKNIJ_STOJAKI;

/
--------------------------------------------------------
--  DDL for Procedure ZAPISZ_LOGOWANIE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ZAPISZ_LOGOWANIE" (pOper IN VARCHAR2, pProgName IN VARCHAR2 DEFAULT ' ', pProgVer IN VARCHAR2 DEFAULT ' ')
AS
 vOper VARCHAR2(10);
 vProgName VARCHAR2(50);
 vSID NUMBER:=0;
 vData DATE;
 vCZAS CHAR(6);
 vJest NUMBER(1);
begin
 IF pOper is null THEN vOper:=' '; ELSE vOper:=substr(pOper,1,10); END IF;
 
 SELECT SYS_CONTEXT('USERENV','SESSIONID'), SYS_CONTEXT('USERENV','MODULE'),
        trunc(SYSDATE), to_char(SYSDATE,'HH24MISS')
   INTO vSID, vProgName, vData, vCzas
   FROM DUAL;
 SELECT count(1) INTO vJest FROM logowania
   WHERE session_ID=vSID and operator_ID=vOper and data=vData;
 IF vJest<>0 THEN RETURN; END IF;
 IF vProgName is null THEN vProgName:=' '; END IF;
 IF pProgName is null OR pProgName=' ' THEN vProgName:=substr(vProgName,1,50);
                                       ELSE vProgName:=substr(pProgName,1,50);
 END IF;
 
 INSERT INTO logowania (session_ID, host, os_user, prog_name, prog_ver, operator_id, data, czas)
        VALUES (vSID,
                substr(SYS_CONTEXT('USERENV','HOST'),1,50),
                substr(SYS_CONTEXT('USERENV','OS_USER'),1,50),
                vProgName, pProgVer, vOper, vData, vCzas);

END ZAPISZ_LOGOWANIE;

/
--------------------------------------------------------
--  DDL for Procedure ZLEC_NADRZEDNE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ZLEC_NADRZEDNE" 
(
pNR_KOM_SZYBY IN NUMBER DEFAULT 0,
pNR_KOM_ZLEC_WEW IN NUMBER DEFAULT 0,
pNR_POZ_WEW IN NUMBER DEFAULT 0,
pNR_SZT_WEW IN NUMBER DEFAULT 0,
pNR_WAR_WEW IN NUMBER DEFAULT 0,
pNK_ZLEC OUT NUMBER,
pNR_POZ OUT NUMBER,
pNR_SZT OUT NUMBER,
pNR_WAR OUT NUMBER,
pLISTA OUT NUMBER,
pRACK OUT NUMBER
) AS
vNR_ZLEC_WEW NUMBER:=0;
vNK_ZLEC_WEW NUMBER:=0;
vNR_POZ_WEW NUMBER:=0;
vNR_SZT_WEW NUMBER:=0;
vNr NUMBER;
vWyr CHAR(1);
EX_BRAK_POLP EXCEPTION;
BEGIN
pNK_ZLEC:=0;
-- jeœli podany NR_KOM_SZYBY sprawdzenie danych w SPISE
IF pNR_KOM_SZYBY>0 THEN
SELECT nr_komp_zlec,nr_zlec,nr_poz,nr_szt INTO vNK_ZLEC_WEW,vNR_ZLEC_WEW,vNR_POZ_WEW,vNR_SZT_WEW
FROM spise E  WHERE E.nr_kom_szyby=pNR_KOM_SZYBY;
SELECT wyroznik INTO vWyr FROM zamow WHERE nr_kom_zlec=vNK_ZLEC_WEW;
ELSE
vNK_ZLEC_WEW:=pNR_KOM_ZLEC_WEW;
vNR_POZ_WEW:=pNR_POZ_WEW;
vNR_SZT_WEW:=pNR_SZT_WEW;
SELECT nr_zlec, wyroznik INTO vNR_ZLEC_WEW,vWyr FROM zamow WHERE nr_kom_zlec=pNR_KOM_ZLEC_WEW;
END IF;
--wyjœcie gdy zlecnie nieWEWNETRZNE
IF vWyr<>'W' THEN RETURN; END IF;
--ZLEC_POLP - sprawdzenie numeru komp. zlecenia nadrzednego
SELECT count(1) into vNr FROM zlec_polp WHERE nr_zlec_wew=vNR_ZLEC_WEW;
IF vNr is null or vNr=0 THEN
RAISE EX_BRAK_POLP;
END IF;
SELECT DISTINCT zlec_polp.nr_komp_zlec INTO pNK_ZLEC
FROM zlec_polp WHERE nr_zlec_wew=vNR_ZLEC_WEW;
-- wyjœcie gdy brak dod. informacji
IF vNR_POZ_WEW=0 THEN
RETURN;
END IF;
--KOL_STOJAKOW - sprawdzenie listy, ID
SELECT max(nr_listy), min(rack_no) INTO pLista,pRACK
FROM kol_stojakow
WHERE nr_komp_zlec=vNK_ZLEC_WEW AND nr_poz=vNR_POZ_WEW AND nr_sztuki=greatest(1,vNR_SZT_WEW)
AND (pNR_WAR_WEW is null or pNR_WAR_WEW=0 OR nr_warstwy=pNR_WAR_WEW);
-- sprawdzenie który z kolei wycinek w zleceniu wewnetrznym
SELECT nr INTO vNr
FROM (SELECT ROWNUM AS nr, nr_poz, nr_sztuki, nr_warstwy FROM kol_stojakow
WHERE nr_listy=pLISTA AND nr_komp_zlec=vNK_ZLEC_WEW AND rack_no=pRACK AND nr_sztuki=greatest(1,vNR_SZT_WEW)
ORDER BY nr_komp_zlec, nr_poz, nr_warstwy)
WHERE nr_poz=vNR_POZ_WEW AND nr_warstwy=greatest(1,pNR_WAR_WEW);
-- odszukanie tego kolejnego wycinka w zleceniu nadrzednym
SELECT nr_poz, nr_warstwy INTO pNR_POZ, pNR_WAR
FROM (SELECT ROWNUM AS nr, nr_poz, nr_warstwy FROM kol_stojakow
WHERE nr_listy=pLISTA AND nr_komp_zlec=pNK_ZLEC AND rack_no=pRACK AND nr_sztuki=greatest(1,vNR_SZT_WEW)
ORDER BY nr_komp_zlec, nr_poz, nr_warstwy)
WHERE nr=vNr;
--zalo¿enie ¿e NR_SZT taki sam
pNR_SZT:=Greatest(pNR_SZT_WEW,vNR_SZT_WEW);
EXCEPTION
WHEN EX_BRAK_POLP THEN RAISE_APPLICATION_ERROR(-20001,'ZLECENIE '||vNR_ZLEC_WEW||'- NIE MA POWIAZANIA ZE ZLECENIEM NADRZEDNYM');
WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20002,'ZLECENIE '||vNR_ZLEC_WEW||'- BRAKI NA LIŒCIE WYCINKÓW DLA LISTY '||pLISTA);
WHEN OTHERS THEN RAISE_APPLICATION_ERROR(-20099,'NIEKREŒLONY B£¥D');
END ZLEC_NADRZEDNE;

/
--------------------------------------------------------
--  DDL for Package PKG_CZAS
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "PKG_CZAS" AS 

  FUNCTION NR_KOMP_ZM (DZIEN IN DATE,  ZMIANA IN NUMBER) RETURN NUMBER;
  FUNCTION NR_ZM_TO_DATE (pNR_KOMP_ZM IN NUMBER) RETURN DATE;
  FUNCTION NR_ZM_TO_ZM (pNR_KOMP_ZM IN NUMBER) RETURN NUMBER;

  FUNCTION CZAS_TO_ZM (pNR_KOMP_INST IN NUMBER, pDATA IN DATE, pPRZED_PO IN NUMBER DEFAULT 0, pRAISE_EX IN NUMBER DEFAULT 1) RETURN NUMBER;
  PROCEDURE POBIERZ_GODZ_PRACY(pNR_KOMP_INST IN NUMBER, pDayOfWeek IN NUMBER, pPocz OUT DATE, pKon OUT DATE, pDlugZm OUT NUMBER);
  
END PKG_CZAS;

/
--------------------------------------------------------
--  DDL for Package PKG_MAIN
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "PKG_MAIN" AS 
  
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
--------------------------------------------------------
--  DDL for Package PKG_REJESTRACJA
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "PKG_REJESTRACJA" IS 
/*deklaracje*/
/*nowy typ kursora, do podstawiana ró¿nych kewrend - test NIEUZYWANE*/
TYPE ref_kursor IS REF CURSOR;

cOP_AUTOMAT CONSTANT CHAR(7) := 'AUTOMAT';

/*kursor wybieraj¹cy rekordy z tabeli L_WYC wg parametrów wejœciowych*/
CURSOR kursor_lwyc (pNR_KOM_ZLEC NUMBER, pNR_POZ_ZLEC NUMBER, pNR_SZT NUMBER, pNR_WARST NUMBER,
                    pZAKRES_INST NUMBER, pNR_INST NUMBER, pNADPISZ NUMBER, pZAPIS NUMBER, pMAX_KOLEJN NUMBER, pOPER VARCHAR2)
 IS SELECT L_WYC.* FROM l_wyc
    LEFT JOIN parinst ON parinst.nr_komp_inst=l_wyc.nr_inst
    WHERE l_wyc.nr_kom_zlec=pNR_KOM_ZLEC AND l_wyc.nr_poz_zlec=pNR_POZ_ZLEC AND l_wyc.nr_szt=pNR_SZT
      AND (pNR_WARST=0 or l_wyc.nr_warst=pNR_WARST)
      AND (l_wyc.typ_inst not in ('MON','STR') or l_wyc.nr_warst=1) --A C wcale a MON tylko 1. warstwa
      AND (case when pZAKRES_INST=3 and l_wyc.zn_wyrobu=1 OR pZAKRES_INST=4 and l_wyc.kolejn<pMAX_KOLEJN OR pZAKRES_INST=1 and l_wyc.nr_inst=pNR_INST OR pZAKRES_INST=2 then 1 else 0 end)=1
      AND (case when pZAPIS=0 and l_wyc.op=pOPER OR pNADPISZ=1 or l_wyc.d_wyk<to_date('2001/01/01','YYYY/MM/DD') then 1 else 0 end)=1
      AND (pZAPIS=1 or l_wyc.nr_stoj=0)
      AND zn_braku in (0,8)
     -- AND parinst.fl_cutmon=2 --zakomentowac w VITROTERMIE
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
END PKG_REJESTRACJA;

/
--------------------------------------------------------
--  DDL for Package Body PKG_CZAS
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PKG_CZAS" AS

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
   RETURN trunc(to_date('1999/01/01','YYYY/MM/DD')) + (pNR_KOMP_ZM-((pNR_KOMP_ZM-1) mod 4))*0.25 +1;   
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

END PKG_CZAS;

/
--------------------------------------------------------
--  DDL for Package Body PKG_MAIN
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PKG_MAIN" AS

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
--------------------------------------------------------
--  DDL for Package Body PKG_REJESTRACJA
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PKG_REJESTRACJA" AS

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
  vZakres NUMBER;
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
       data=case nr_inst when pNR_INST then trunc(sysdate) else data end,
       czas=case nr_inst when pNR_INST then to_char(sysdate,'HH24MISS') else czas end
   WHERE CURRENT OF kursor_lwyc;
  ELSE
   UPDATE l_wyc
   SET d_wyk=pDATA_WYK, zm_wyk=pZM_WYK,
       nr_inst_wyk=0, op=nvl(pOPER,cOP_AUTOMAT),
       data=case nr_inst when pNR_INST then trunc(sysdate) else data end,
       czas=case nr_inst when pNR_INST then to_char(sysdate,'HH24MISS') else czas end
   WHERE CURRENT OF kursor_lwyc;
   END IF;
  END LOOP;
  CLOSE kursor_lwyc;  
  --COMMIT; 
  END Uzupelnij_l_wyc;
  
END PKG_REJESTRACJA;

/
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

  CREATE OR REPLACE FUNCTION "LIPROD280_BCD" (pNrKompSzyby number) RETURN VARCHAR2 
as
  vResult varchar2(1000);

  vBARCODE number(24);

  vSep char;
begin
  vResult := ' ';
  vSep := ' ';

  vBARCODE := pNrKompSzyby;

  vResult := '<BCD> '||
    Rpad(vBARCODE,24);

return vResult;
end liprod280_BCD;

/
--------------------------------------------------------
--  DDL for Function LIPROD280_BEA
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "LIPROD280_BEA" (pNrKompZlec number, pNrPoz number, pNrElem number) RETURN VARCHAR2 
as
  cursor c1 is  
    select * from v_zlec_mon vzm WHERE vzm.nr_kom_zlec=pNrKompZlec and vzm.nr_poz=pNrPoz and vzm.nr_el_wew=pNrElem;
  vzm v_zlec_mon%rowtype;

  vResult varchar2(1000);

  cf number;
  c number;
  i number;
  vStep number;

  vINDEX number(3):=0;
  vSHEET_INX number(1):=0;
  vFACESIDE number(1):=0;
  vDESCRIPT varchar2(40):=' ';
  vTYPE number(2):=0;
  vEDGE1 number(1):=0;
  vEDGE2 number(1):=0;
  vEDGE3 number(1):=0;
  vEDGE4 number(1):=0;
  vEDGE5 number(1):=0;
  vEDGE6 number(1):=0;
  vEDGE7 number(1):=0;
  vEDGE8 number(1):=0;
  vCORNER1 number(1):=0;
  vCORNER2 number(1):=0;
  vCORNER3 number(1):=0;
  vCORNER4 number(1):=0;
  vCORNER5 number(1):=0;
  vCORNER6 number(1):=0;
  vCORNER7 number(1):=0;
  vCORNER8 number(1):=0;
  vCORNER9 number(1):=0;
  vCORNER10 number(1):=0;
  vCORNER11 number(1):=0;
  vCORNER12 number(1):=0;
  vCORNER13 number(1):=0;
  vCORNER14 number(1):=0;
  vCORNER15 number(1):=0;
  vCORNER16 number(1):=0;
  vXCOORD number(5):=0;
  vYCOORD number(5):=0;
  vRADIUS number(5):=0;
  vWIDTH number(5):=0;
  vHEIGHT number(5):=0;

  vSep char;
  vSep2 char;
begin
  vResult := '';
  vSep := ' ';
  vSep2 := Chr(9);
  cf := 0;
  c := 0;
  i := 0;

-- Pobierz dane z widoku v_zlec_mon
  OPEN c1;
  LOOP
    FETCH c1 INTO vzm;
    EXIT WHEN c1%NOTFOUND; 

-- gdy warstwa ramki
    if pNrElem mod 2 = 0 then
      cf := floor(pNrElem/2);

      for i in 1..4 loop
        if i=1 then vStep := vzm.stepD;
        elsif i=2 then vStep := vzm.stepP;
        elsif i=3 then vStep := vzm.stepG;
        elsif i=4 then vStep := vzm.stepL;
        end if;
        if vStep>0 then
          vINDEX:=0;
          vSHEET_INX:=0;
          vFACESIDE:=0;
          vDESCRIPT:=' ';
          vTYPE:=0;
          vEDGE1:=0;
          vEDGE2:=0;
          vEDGE3:=0;
          vEDGE4:=0;
          vEDGE5:=0;
          vEDGE6:=0;
          vEDGE7:=0;
          vEDGE8:=0;
          vCORNER1:=0;
          vCORNER2:=0;
          vCORNER3:=0;
          vCORNER4:=0;
          vCORNER5:=0;
          vCORNER6:=0;
          vCORNER7:=0;
          vCORNER8:=0;
          vCORNER9:=0;
          vCORNER10:=0;
          vCORNER11:=0;
          vCORNER12:=0;
          vCORNER13:=0;
          vCORNER14:=0;
          vCORNER15:=0;
          vCORNER16:=0;
          vXCOORD:=0;
          vYCOORD:=0;
          vRADIUS:=0;
          vWIDTH:=0;
          vHEIGHT:=0;


          c := c+1;
          vINDEX := c;
          vSHEET_INX := cf;
          vTYPE := 6;
          if i=1 then 
            vEDGE1 := 1;
            vDESCRIPT := 'Pomniejszenie ramki D';
          elsif i=2 then 
            vEDGE2 := 1;
            vDESCRIPT := 'Pomniejszenie ramki P';
          elsif i=3 then 
            vEDGE3 := 1;
            vDESCRIPT := 'Pomniejszenie ramki G';
          elsif i=4 then 
            vEDGE4 := 1;
            vDESCRIPT := 'Pomniejszenie ramki L';
          end if; 
          vWIDTH := vStep+vzm.uszcz_std;

          vResult := vResult||'<BEA> '||
            LPad(vINDEX,3,'0')||vSep||
            vSHEET_INX||vSep||
            vFACESIDE||vSep||
            RPad(vDESCRIPT,40)||vSep||
            LPad(vTYPE,2,'0')||vSep||
            vEDGE1||vSep||
            vEDGE2||vSep||
            vEDGE3||vSep||
            vEDGE4||vSep||
            vEDGE5||vSep||
            vEDGE6||vSep||
            vEDGE7||vSep||
            vEDGE8||vSep||
            vCORNER1||vSep||
            vCORNER2||vSep||
            vCORNER3||vSep||
            vCORNER4||vSep||
            vCORNER5||vSep||
            vCORNER6||vSep||
            vCORNER7||vSep||
            vCORNER8||vSep||
            vCORNER9||vSep||
            vCORNER10||vSep||
            vCORNER11||vSep||
            vCORNER12||vSep||
            vCORNER13||vSep||
            vCORNER14||vSep||
            vCORNER15||vSep||
            vCORNER16||vSep||
            LPad(vXCOORD,5,'0')||vSep||
            LPad(vYCOORD,5,'0')||vSep||
            LPad(vRADIUS*10,5,'0')||vSep||
            LPad(vWIDTH*10,5,'0')||vSep||
            LPad(vHEIGHT*10,5,'0')||vSep2;
        end if;
      end loop;
    end if;
  end loop;
  close c1;

return vResult;
end liprod280_bea;

/
--------------------------------------------------------
--  DDL for Function LIPROD280_BTH
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "LIPROD280_BTH" RETURN VARCHAR2 
as
  vResult varchar2(1000);

  vBTH_INFO varchar2(10);
  vBCD_START number(6);
  vBATCH_NO number(8);

  vSep char;
begin
  vResult := ' ';
  vSep := ' ';

  vBTH_INFO := ' ';
  vBCD_START := 0;
  vBATCH_NO := 0;

  vResult := '<BTH> '||
    rpad(vBTH_INFO,10)||vSep||
    lpad(vBCD_START,6,'0')||vSep||
    lpad(vBATCH_NO,8,'0');

return vResult;
end liprod280_BTH;

/
--------------------------------------------------------
--  DDL for Function LIPROD280_ELEM
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "LIPROD280_ELEM" (pNrKompZlec number, pNrPoz number, pNrElem number) RETURN VARCHAR2 
as
  cursor c1 is  
    select * from v_zlec_mon vzm WHERE vzm.nr_kom_zlec=pNrKompZlec and vzm.nr_poz=pNrPoz and vzm.nr_el_wew=pNrElem;
  vzm v_zlec_mon%rowtype;

--  vGrub number;
  vCzyPow number;
--  vNrKat number;
  vCzyOrn number;
  vZnaczPr varchar2(4);
  vOznRamki char;
  vResult varchar2(1000);

  cg number;
  cf number;

  vGLX_ITEM_INX number(5);
  vGLX_DESCRIPT varchar2(40);
  vGLX_SURFACE number(1);
  vGLX_THICKNESS number(5);
  vGLX_FACE_SIDE number(1);
  vGLX_IDENT varchar2(10);
  vGLX_PATT_DIR number(1);
  vGLX_PANE_BCD varchar2(10);
  vGLX_PROD_PANE number(1);
  vGLX_PROD_COMP number(2);
  vGLX_CATEGORY number(2);

  vFRX_ITEM_INX number(5);
  vFRX_DESCRIPTION varchar2(40);
  vFRX_TYPE number(2);
  vFRX_COLOR number(2);
  vFRX_WIDTH number(5);
  vFRX_HEIGHT number(5);
  vFRX_IDENT varchar2(10);

  vSep char;
begin
  vResult := ' ';
  vSep := ' ';
  cg := 0;
  cf := 0;

-- Pobierz dane z widoku v_zlec_mon
  OPEN c1;
  LOOP
    FETCH c1 INTO vzm;
    EXIT WHEN c1%NOTFOUND; 
    vCzyOrn := 0;

-- gdy warstwwa szkla
    if pNrElem mod 2 = 1 then
      cg := floor(pNrElem/2)+1;
      if vzm.nr_kat>0 then
        select NVL(substr(k.naz_kat,1,40),' '),decode(Substr(k.typ_kat,2,1),'O',1,0),k.znacz_pr into vGLX_DESCRIPT,vCzyOrn,vZnaczPr from katalog k where k.nr_kat=vzm.nr_kat;
      else 
        vGLX_DESCRIPT := vzm.typ_kat||' '||vzm.grub;
      end if;
      vGLX_ITEM_INX := 0;


      if vzm.powL>0 or vzm.powR>0 then vGLX_SURFACE := 1;
      elsif vCzyOrn=1 then vGLX_SURFACE := 2;
      else vGLX_SURFACE := 0;
      end if;

      vGLX_THICKNESS := round(vzm.grub*10);

      if vzm.powL>0 then vGLX_FACE_SIDE := 2;
      elsif vzm.powR>0 then vGLX_FACE_SIDE := 1;
      else vGLX_FACE_SIDE := 0;
      end if;

      vGLX_IDENT := ' ' ;
      vGLX_PATT_DIR := 0;
      vGLX_PANE_BCD := ' ';
      vGLX_PROD_PANE := 0;
      vGLX_PROD_COMP := 0;

      if vzm.typ_kat='LAMINAT' or vZnaczPr='9.La' then vGLX_CATEGORY := 2;
      else vGLX_CATEGORY := 1;
      END IF;

      vResult := '<GL'||cg||'> '||
        LPad(vGLX_ITEM_INX,5,'0')||vSep||
        rpad(vGLX_DESCRIPT,40)||vSep||
        vGLX_SURFACE||vSep||
        LPad(vGLX_THICKNESS,5,'0')||vSep||
        vGLX_FACE_SIDE||vSep||
        rpad(vGLX_IDENT,10)||vSep||
        vGLX_PATT_DIR||vSep||
        rpad(vGLX_PANE_BCD,10)||vSep||
        vGLX_PROD_PANE||vSep||
        LPad(vGLX_PROD_COMP,2,'0')||vSep||
        LPad(vGLX_CATEGORY,2,'0');

    end if;
-- gdy warstwa ramki
    if pNrElem mod 2 = 0 then
      vFRX_ITEM_INX := 0;

      cg := floor(pNrElem/2);
      if vzm.nr_kat>0 then
        select NVL(substr(k.naz_kat,1,40),' '),nvl(grubosc*10,0),nvl(bok_od*10,0) into vFRX_DESCRIPTION,vFRX_WIDTH,vFRX_HEIGHT from katalog k where k.nr_kat=vzm.nr_kat;
      else 
        vFRX_DESCRIPTION := ' ';
        vFRX_WIDTH := 0;
        vFRX_HEIGHT := 0;
      end if;

      vOznRamki := Substr(vzm.typ_kat,2,1);
      IF vOznRamki='A' then vFRX_TYPE := 0;
      ELSIF vOznRamki='C' then vFRX_TYPE := 0;
      ELSIF vOznRamki='E' then vFRX_TYPE := 0;
      ELSIF vOznRamki='G' then vFRX_TYPE := 3;
      ELSIF vOznRamki='H' then vFRX_TYPE := 0;
      ELSIF vOznRamki='M' then vFRX_TYPE := 0;
      ELSIF vOznRamki='N' then vFRX_TYPE := 0;
      ELSIF vOznRamki='P' then vFRX_TYPE := 0;
      ELSIF vOznRamki='S' then vFRX_TYPE := 3;
      ELSIF vOznRamki='T' then vFRX_TYPE := 0;
      ELSIF vOznRamki='W' then vFRX_TYPE := 0;
      else vFRX_TYPE :=0;
      END IF;

      vFRX_COLOR := 0;
      vFRX_IDENT := '0';

      vResult := '<FR'||cg||'> '||
        LPad(vFRX_ITEM_INX,5,'0')||vSep||
        rpad(vFRX_DESCRIPTION,40)||vSep||
        LPad(vFRX_TYPE,2,'0')||vSep||
        LPad(vFRX_COLOR,2,'0')||vSep||
        LPad(vFRX_WIDTH,5,'0')||vSep||
        LPad(vFRX_HEIGHT,5,'0')||vSep||
        rpad(vFRX_IDENT,10);
    end if;
  end loop;
  close c1;

return vResult;
end liprod280_elem;

/
--------------------------------------------------------
--  DDL for Function LIPROD280_ORD
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "LIPROD280_ORD" (pNrKompZlec number) RETURN VARCHAR2 
as
  vResult varchar2(1000);

  vORD varchar2(10);
  vCUST_NUM varchar2(10);
  vCUST_NAME varchar2(40);
  vTEXT1 varchar2(40);
  vTEXT2 varchar2(40);
  vTEXT3 varchar2(40);
  vTEXT4 varchar2(40);
  vTEXT5 varchar2(40);
  vPRD_DATE varchar2(10);
  vDEL_DATE varchar2(10);
  vDEL_AREA varchar2(10);

  vSep char;
begin
  vResult := ' ';
  vSep := ' ';


  select 
    z.nr_zlec ORD,
    z.nr_kon CUST_NUM,
    k.skrot_k CUST_NAM,
    ' ' TEXT1,
    ' ' TEXT2,
    ' ' TEXT3,
    ' ' TEXT4,
    ' ' TEXT5,
    to_char(z.d_plan,'DD/MM/YYYY') PRD_DATE,
    to_char(z.d_pl_sped,'DD/MM/YYYY') DEL_DATE,
    ' ' DEL_AREA
  into  vORD, vCUST_NUM, vCUST_NAME, 
        vTEXT1, vTEXT2, vTEXT3, vTEXT4, vTEXT5,
        vPRD_DATE, vDEL_DATE, vDEL_AREA
  from zamow z
  left join klient k on k.nr_kon=z.nr_kon
  where z.nr_kom_zlec=pNrKompZlec;


  vResult := '<ORD> '||
    rpad(vORD,10)||vSep||
    rpad(vCUST_NUM,10)||vSep||
    rpad(vCUST_NAME,40)||vSep||
    rpad(vTEXT1,40)||vSep||
    rpad(vTEXT2,40)||vSep||
    rpad(vTEXT3,40)||vSep||
    rpad(vTEXT4,40)||vSep||
    rpad(vTEXT5,40)||vSep||
    rpad(vPRD_DATE,10)||vSep||
    rpad(vDEL_DATE,10)||vSep||
    rpad(vDEL_AREA,10);

return vResult;
end liprod280_ORD;

/
--------------------------------------------------------
--  DDL for Function LIPROD280_POS
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "LIPROD280_POS" (pNrKompZlec number, pNrPoz number, pNrSzt number) RETURN VARCHAR2 
as
  cursor c1 is  
    select * from v_zlec_mon vzm WHERE vzm.nr_kom_zlec=pNrKompZlec and vzm.nr_poz=pNrPoz;
  vzm v_zlec_mon%rowtype;
  vGrub number;
  vCzyPow number;
  vNrKat number;
  vCzyOrn number;
  vResult varchar2(1000);

  type glassa_t is varray(9) of varchar2(5);
  type gasa_t is varray(4) of number;
  glassa glassa_t := glassa_t(' ',' ',' ',' ',' ',' ',' ',' ',' ');
  gasa gasa_t := gasa_t(0,0,0,0);
  c number;

  vITEM_NUM number(5);
  vID_NUM varchar2(8);
  vBARCODE number(4);
  vQTY number(5);
  vWIDTH number(5);
  vHEIGHT number(5);
  vINSET number(3);
  vFRAME_TXT number(2);
  vSEAL_TYPE number(1);
  vFRAH_TYPE number(1);
  vFRAH_HOE number(5);
  vPATT_DIR number(1);
  vDGU_PANE number(1);

  vSep char;
begin
  vResult := ' ';
  vSep := ' ';
  c := 0;

-- Pobierz dane z widoku v_zlec_mon
  OPEN c1;
  LOOP
    FETCH c1 INTO vzm;
    EXIT WHEN c1%NOTFOUND; 
    c := c+1;
    vCzyOrn := 0;
    glassa(c) := to_char(round(vzm.grub,0));

-- gdy warstwwa szkla
    if c mod 2 = 1 then
      if vzm.nr_kat>0 then
        select decode(Substr(typ_kat,2,1),'O',1,0) into vCzyOrn from katalog where nr_kat=vzm.nr_kat;
      end if;

      if vzm.powL>0 or vzm.powR>0 then glassa(c) := glassa(c)||'-1';
      elsif vCzyOrn=1 then glassa(c) := glassa(c)||'-2';
      else glassa(c) := glassa(c)||'-0';
      end if;
    end if;
-- gdy warstwa ramki
    if c mod 2 = 0 then
      if vzm.gaz='A' then 
        gasa(c / 2) := 1;
      elsif vzm.gaz='K' then
        gasa(c / 2) := 2;
      else
        gasa(c / 2) := 0;
      end if;
      glassa(c) := Substr(vzm.typ_kat,2,1)||glassa(c);
      if substr(vzm.ind_bud,13,1)=1 then
        vSEAL_TYPE := 9;
      elsif vzm.silikon=1 then
        vSEAL_TYPE := 1;
      else 
        vSEAL_TYPE := 0;
      end if;
    end if;
  end loop;
  close c1;


  select 
    p.nr_poz ITEM_NUM,
    k.rack_no ID_NUM,
    0 BARCODE,
    1 QTY,
    p.szer WIDTH,
    p.wys HEIGHT,
    decode(p.GR_SIL,0,45,p.GR_SIL*10) INSET,
    0 FRAME_TXT,
    0 FRAH_TYPE,
    0 FRAH_HOE,
    0 PATT_DIR,
    0 DGU_PANE
  into  vITEM_NUM,vID_NUM,vBARCODE,vQTY,vWIDTH,vHEIGHT,
        vINSET,vFRAME_TXT,
        vFRAH_TYPE,vFRAH_HOE,vPATT_DIR,vDGU_PANE
  from spisz p
  left join struktury s on s.kod_str=p.kod_str
  left join kol_stojakow k on k.nr_komp_zlec=p.nr_kom_zlec and k.nr_poz=p.nr_poz and k.nr_sztuki=pNrSzt and k.nr_warstwy=1
  where p.nr_kom_zlec=pNrKompZlec and p.nr_poz=pNrPoz;

  vResult := '<POS> '||
    LPad(vITEM_NUM,5,'0')||vSep||
    rpad(vID_NUM,8)||vSep||
    lpad(vBARCODE,4,'0')||vSep||
    lpad(vQTY,5,'0')||vSep||
    lpad(vWIDTH*10,5,'0')||vSep||
    lpad(vHEIGHT*10,5,'0')||vSep||
    rpad(glassa(1),5)||vSep||
    rpad(glassa(2),3)||vSep||
    rpad(glassa(3),5)||vSep||
    rpad(glassa(4),3)||vSep||
    rpad(glassa(5),5)||vSep||
    rpad(glassa(6),3)||vSep||
    rpad(glassa(7),5)||vSep||
    rpad(glassa(8),3)||vSep||
    rpad(glassa(9),5)||vSep||
    lpad(vINSET,3,'0')||vSep||
    lpad(vFRAME_TXT,2,'0')||vSep||
    lpad(gasa(1),2,'0')||vSep||
    lpad(gasa(2),2,'0')||vSep||
    lpad(gasa(3),2,'0')||vSep||
    lpad(gasa(4),2,'0')||vSep||
    vSEAL_TYPE||vSep||
    vFRAH_TYPE||vSep||
    lpad(vFRAH_HOE,5,'0')||vSep||
    vPATT_DIR||vSep||
    vDGU_PANE;

return vResult;
end liprod280_pos;

/
--------------------------------------------------------
--  DDL for Function LIPROD280_REL
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "LIPROD280_REL" RETURN VARCHAR2 
as
  vResult varchar2(1000);

  vREL_NUM varchar2(5);
  vREL_INFO varchar2(40);

  vSep char;
begin
  vResult := ' ';
  vSep := ' ';

  vREL_NUM := '02.80';
  vREL_INFO := 'SIP - Transfer Cutter 2000';

  vResult := '<REL> '||
    rpad(vREL_NUM,10)||vSep||
    rpad(vREL_INFO,40);

return vResult;
end liprod280_REL;

/
--------------------------------------------------------
--  DDL for Function LIPROD280_SHP
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "LIPROD280_SHP" (pNrKompZlec number, pNrPoz number, pNrElem number) RETURN VARCHAR2 
as
  cursor c1 is  
    select * from v_zlec_mon vzm WHERE vzm.nr_kom_zlec=pNrKompZlec and vzm.nr_poz=pNrPoz and vzm.nr_el_wew=pNrElem;
  vzm v_zlec_mon%rowtype;

  vResult varchar2(1000);

  cg number;

  vSHP_PANE number(1):=0;
  vSHP_DEF number(1):=0;
  vSHP_CAT number(1):=0;
  vSHP_NUM number(3):=0;
  vSHP_LEN number(5):=0;
  vSHP_LEN1 number(5):=0;
  vSHP_LEN2 number(5):=0;
  vSHP_HGT number(5):=0;
  vSHP_HGT1 number(5):=0;
  vSHP_HGT2 number(5):=0;
  vSHP_RAD number(5):=0;
  vSHP_RAD1 number(5):=0;
  vSHP_RAD2 number(5):=0;
  vSHP_RAD3 number(5):=0;
  vSHP_TRIM1 number(5):=0;
  vSHP_TRIM2 number(5):=0;
  vSHP_TRIM3 number(5):=0;
  vSHP_TRIM4 number(5):=0;
  vSHP_EDGE1 number(5):=0;
  vSHP_EDGE2 number(5):=0;
  vSHP_EDGE3 number(5):=0;
  vSHP_EDGE4 number(5):=0;
  vSHP_EDGE5 number(5):=0;
  vSHP_EDGE6 number(5):=0;
  vSHP_EDGE7 number(5):=0;
  vSHP_EDGE8 number(5):=0;
  vSHP_PATH varchar2(40):=' ';
  vSHP_FILE varchar2(40):=' ';
  vSHP_NAME varchar2(40):=' ';
  vSHP_MIRR number(1):=0;
  vSHP_BASE number(1):=0;

  vSep char;
begin
  vResult := ' ';
  vSep := ' ';
  cg := 0;

-- Pobierz dane z widoku v_zlec_mon
  OPEN c1;
  LOOP
    FETCH c1 INTO vzm;
    EXIT WHEN c1%NOTFOUND; 

-- gdy warstwwa szkla
    if pNrElem mod 2 = 1 then
      cg := floor(pNrElem/2)+1;

      vSHP_PANE :=0;
      vSHP_DEF :=0;
      vSHP_CAT :=0;
      vSHP_NUM :=0;
      vSHP_LEN :=0;
      vSHP_LEN1 :=0;
      vSHP_LEN2 :=0;
      vSHP_HGT :=0;
      vSHP_HGT1 :=0;
      vSHP_HGT2 :=0;
      vSHP_RAD :=0;
      vSHP_RAD1 :=0;
      vSHP_RAD2 :=0;
      vSHP_RAD3 :=0;
      vSHP_TRIM1 :=0;
      vSHP_TRIM2 :=0;
      vSHP_TRIM3 :=0;
      vSHP_TRIM4 :=0;
      vSHP_EDGE1 :=0;
      vSHP_EDGE2 :=0;
      vSHP_EDGE3 :=0;
      vSHP_EDGE4 :=0;
      vSHP_EDGE5 :=0;
      vSHP_EDGE6 :=0;
      vSHP_EDGE7 :=0;
      vSHP_EDGE8 :=0;
      vSHP_PATH :=' ';
      vSHP_FILE :=' ';
      vSHP_NAME :=' ';
      vSHP_MIRR :=0;
      vSHP_BASE :=0;

      vSHP_PANE := cg;
      if cg=1 then 
        vSHP_DEF := 0;
        vSHP_LEN := nvl(vzm.szer,0);
        vSHP_HGT := nvl(vzm.wys,0);
        if (to_number(strtoken(vzm.par_kszt,2,':'),'999')>0) then
          vSHP_CAT := to_number(strtoken(vzm.par_kszt,1,':'),'9');
          vSHP_NUM := to_number(strtoken(vzm.par_kszt,2,':'),'999');
          vSHP_LEN1 :=to_number(strtoken(vzm.par_kszt,4,':'),'99999');
          vSHP_LEN2 :=to_number(strtoken(vzm.par_kszt,5,':'),'99999');
          vSHP_HGT1 :=to_number(strtoken(vzm.par_kszt,7,':'),'99999');
          vSHP_HGT2 :=to_number(strtoken(vzm.par_kszt,8,':'),'99999');
          vSHP_RAD :=to_number(strtoken(vzm.par_kszt,9,':'),'99999');
          vSHP_RAD1 :=to_number(strtoken(vzm.par_kszt,10,':'),'99999');
          vSHP_RAD2 :=to_number(strtoken(vzm.par_kszt,11,':'),'99999');
          vSHP_RAD3 :=to_number(strtoken(vzm.par_kszt,12,':'),'99999');
        end if;
      else
        vSHP_DEF := 2;
        vSHP_EDGE1 := Abs(vzm.max_stepD-vzm.stepD);
        vSHP_EDGE2 := Abs(vzm.max_stepP-vzm.stepP);
        vSHP_EDGE3 := Abs(vzm.max_stepG-vzm.stepG);
        vSHP_EDGE4 := Abs(vzm.max_stepL-vzm.stepL);
--        vSHP_EDGE1 := -vzm.stepD;
--        vSHP_EDGE2 := -vzm.stepP;
--        vSHP_EDGE3 := -vzm.stepG;
--        vSHP_EDGE4 := -vzm.stepL;
      end if;

      vResult := '<SHP> '||
        vSHP_PANE||vSep||
        vSHP_DEF||vSep||
        vSHP_CAT||vSep||
        LPad(vSHP_NUM,3,'0')||vSep||
        LPad(vSHP_LEN*10,5,'0')||vSep||
        LPad(vSHP_LEN1*10,5,'0')||vSep||
        LPad(vSHP_LEN2*10,5,'0')||vSep||
        LPad(vSHP_HGT*10,5,'0')||vSep||
        LPad(vSHP_HGT1*10,5,'0')||vSep||
        LPad(vSHP_HGT2*10,5,'0')||vSep||
        LPad(vSHP_RAD*10,5,'0')||vSep||
        LPad(vSHP_RAD1*10,5,'0')||vSep||
        LPad(vSHP_RAD2*10,5,'0')||vSep||
        LPad(vSHP_RAD3*10,5,'0')||vSep||
        LPad(vSHP_TRIM1*10,5,'0')||vSep||
        LPad(vSHP_TRIM2*10,5,'0')||vSep||
        LPad(vSHP_TRIM3*10,5,'0')||vSep||
        LPad(vSHP_TRIM4*10,5,'0')||vSep||
        LPad(vSHP_EDGE1*10,5,' ')||vSep||
        LPad(vSHP_EDGE2*10,5,' ')||vSep||
        LPad(vSHP_EDGE3*10,5,' ')||vSep||
        LPad(vSHP_EDGE4*10,5,' ')||vSep||
        LPad(vSHP_EDGE5*10,5,' ')||vSep||
        LPad(vSHP_EDGE6*10,5,' ')||vSep||
        LPad(vSHP_EDGE7*10,5,' ')||vSep||
        LPad(vSHP_EDGE8*10,5,' ')||vSep||
        RPad(vSHP_PATH,40)||vSep||
        RPad(vSHP_FILE,40)||vSep||
        RPad(vSHP_NAME,40)||vSep||
        vSHP_MIRR||vSep||
        vSHP_BASE;
    end if;
  end loop;
  close c1;

return vResult;
end liprod280_shp;

/
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
