--------------------------------------------------------
--  File created - poniedzia³ek-paŸdziernika-11-2021   
--------------------------------------------------------
---------------------------
--New VIEW
--V_ZLEC_MON
---------------------------
CREATE OR REPLACE FORCE VIEW "V_ZLEC_MON" 
 ( "NR_KOM_ZLEC", "NR_POZ", "NR_EL", "NR_EL_WEW", "GRUB", "GAZ", "SILIKON", "HARTOWANA", "IND_BUD", "STEPL", "STEPD", "STEPP", "STEPG", "MAX_STEPL", "MAX_STEPD", "MAX_STEPP", "MAX_STEPG", "USZCZ_ROZNE", "USZCZ_STD", "SZER", "WYS", "ILE_WARSTW", "POWL", "POWR", "NR_KAT", "TYP_KAT", "PAR_KSZT", "SZPROS"
  )  AS 
  select p.nr_kom_zlec,p.nr_poz
        ,vsm.NR_EL
        ,vsm.NR_EL_wew
        ,vsm.GRUB 
        ,vsm.GAZ
        ,vsm.silikon
        ,vsm.hartowana
        ,p.ind_bud
        ,(select min(wsp1) from spisd d where D.NR_KOM_ZLEC=p.nr_kom_zlec and d.nr_poz=p.nr_poz and d.do_war between vsm.WAR_OD and vsm.war_do and d.strona=0) stepL
        ,(select min(wsp2) from spisd d where D.NR_KOM_ZLEC=p.nr_kom_zlec and d.nr_poz=p.nr_poz and d.do_war between vsm.WAR_OD and vsm.war_do and d.strona=0) stepD
        ,(select min(wsp3) from spisd d where D.NR_KOM_ZLEC=p.nr_kom_zlec and d.nr_poz=p.nr_poz and d.do_war between vsm.WAR_OD and vsm.war_do and d.strona=0) stepP
        ,(select min(wsp4) from spisd d where D.NR_KOM_ZLEC=p.nr_kom_zlec and d.nr_poz=p.nr_poz and d.do_war between vsm.WAR_OD and vsm.war_do and d.strona=0) stepG
        ,(select max(wsp1) from spisd d left join katalog k on k.nr_kat=d.nr_kat where D.NR_KOM_ZLEC=p.nr_kom_zlec and d.nr_poz=p.nr_poz and d.strona=0 and k.rodz_sur in ('TAF','POL')) max_stepL
        ,(select max(wsp2) from spisd d left join katalog k on k.nr_kat=d.nr_kat where D.NR_KOM_ZLEC=p.nr_kom_zlec and d.nr_poz=p.nr_poz and d.strona=0 and k.rodz_sur in ('TAF','POL')) max_stepD
        ,(select max(wsp3) from spisd d left join katalog k on k.nr_kat=d.nr_kat where D.NR_KOM_ZLEC=p.nr_kom_zlec and d.nr_poz=p.nr_poz and d.strona=0 and k.rodz_sur in ('TAF','POL')) max_stepP
        ,(select max(wsp4) from spisd d left join katalog k on k.nr_kat=d.nr_kat where D.NR_KOM_ZLEC=p.nr_kom_zlec and d.nr_poz=p.nr_poz and d.strona=0 and k.rodz_sur in ('TAF','POL')) max_stepG
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
        ,(select nvl(count(*),0) from spisd d left join katalog k on k.nr_kat=d.nr_kat where D.NR_KOM_ZLEC=p.nr_kom_zlec and d.nr_poz=p.nr_poz and d.do_war between vsm.WAR_OD and vsm.war_do 
            and k.rodz_sur='KRA') SZPROS
    from v_str_mon_zlec vsm
    left join spisz p on p.nr_kom_zlec=vsm.nr_kom_zlec and p.nr_poz=vsm.nr_poz
    --where p.nr_zlec=:pnrKomStr
    order by p.nr_kom_zlec,p.nr_poz,vsm.nr_el_wew;
---------------------------
--New VIEW
--V_SUROWCE_ZLEC
---------------------------
CREATE OR REPLACE FORCE VIEW "V_SUROWCE_ZLEC" 
 ( "NR_KOM_ZLEC", "NR_ZLEC", "DATA_ZL", "NR_KON", "SKROT_K", "NR_KONTRAKTU", "NR_KAT", "TYP_KAT", "KOD_DOD", "NR_MAG", "JEDN", "IL_NETTO", "IL_BRUTTO_NOM", "IL_NETTO_OPT", "IL_BRUTTO_OPT", "IL_BRUTTO", "IL_NA_RW_NETTO", "IL_NA_RW"
  )  AS 
  select V.nr_kom_zlec, V.nr_zlec, V.data_zl,  nr_kon, V.skrot_k, V.nr_kontraktu,
       V.nr_kat, V.typ_kat, V.kod_dod, V.nr_mag, max(V.jedn) jedn,
       --sum(il_netto) il_netto, sum(il_brutto_nom) il_brutto_nom,
       --tymczasowo pobieranie z SURZAM gdy w POZ il_netto=0 (KRATA)
       case when sum(il_netto)>0 then sum(il_netto) 
            else (select nvl(round(sum(il_zad),6),0) from surzam S where S.nr_komp_zlec=V.nr_kom_zlec and S.indeks=V.kod_dod)
       end il_netto,
       case when sum(il_brutto_nom)>0 then sum(il_brutto_nom) 
            else (select nvl(round(sum(il_zad/(1-S.straty*0.01)),6),0) from surzam S where S.nr_komp_zlec=V.nr_kom_zlec and S.indeks=V.kod_dod)
       end il_brutto_nom,
       sum(il_netto_opt) il_netto_opt, sum(il_brutto_opt) il_brutto_opt,
       case when sum(il_netto)>0 then
             sum(il_brutto_opt) + round((sum(il_netto)-sum(il_netto_opt))*sum(il_brutto_nom)/sum(V.il_netto),6)
            else 
             (select nvl(round(sum(il_zad/(1-S.straty*0.01)),6),0) from surzam S where S.nr_komp_zlec=V.nr_kom_zlec and S.indeks=V.kod_dod)
       end il_brutto,
       case when V.nr_mag=0 then 
         (select nvl(round(sum(rw_pob),6),0) from surzam S where S.nr_komp_zlec=V.nr_kom_zlec and S.nr_kat=V.nr_kat)
         +(select nvl(round(sum(rw_pob),6),0) from surzam S, zamow Z where Z.wyroznik='W' and Z.nr_komp_poprz=V.nr_kom_zlec and S.nr_komp_zlec=Z.nr_kom_zlec and S.nr_kat=V.nr_kat)
        else
         (select nvl(round(sum(rw_pob),6),0) from surzam S where S.nr_komp_zlec=V.nr_kom_zlec and S.nr_mag=V.nr_mag and S.indeks=V.kod_dod)
         +(select nvl(round(sum(rw_pob),6),0) from surzam S, zamow Z where Z.wyroznik='W' and Z.nr_komp_poprz=V.nr_kom_zlec and S.nr_komp_zlec=Z.nr_kom_zlec and S.nr_mag=V.nr_mag and S.indeks=V.kod_dod)
       end il_na_rw_netto,
       case when V.nr_mag=0 then 
         (select nvl(round(sum(rw_pob/(1-straty*0.01)),6),0) from surzam S where S.nr_komp_zlec=V.nr_kom_zlec and S.rw_pob>0 and S.nr_kat=V.nr_kat)
         +(select nvl(round(sum(rw_pob/(1-straty*0.01)),6),0) from surzam S, zamow Z where Z.wyroznik='W' and Z.nr_komp_poprz=V.nr_kom_zlec and S.nr_komp_zlec=Z.nr_kom_zlec and S.rw_pob>0 and S.nr_kat=V.nr_kat)
        else 
         (select nvl(round(sum(rw_pob/(1-straty*0.01)),6),0) from surzam S where S.nr_komp_zlec=V.nr_kom_zlec and S.rw_pob>0 and S.nr_mag=V.nr_mag and S.indeks=V.kod_dod)
         +(select nvl(round(sum(rw_pob/(1-straty*0.01)),6),0) from surzam S, zamow Z where Z.wyroznik='W' and Z.nr_komp_poprz=V.nr_kom_zlec and S.nr_komp_zlec=Z.nr_kom_zlec and S.rw_pob>0 and S.nr_mag=V.nr_mag and S.indeks=V.kod_dod)
       end il_na_rw
from v_surowce_poz V
group by nr_kom_zlec, nr_zlec, data_zl,  nr_kon, skrot_k, nr_kontraktu,
         nr_kat, typ_kat, kod_dod, nr_mag
order by nr_kom_zlec, nr_kat, nr_mag;
---------------------------
--New VIEW
--V_SUROWCE_WAR
---------------------------
CREATE OR REPLACE FORCE VIEW "V_SUROWCE_WAR" 
 ( "NR_KOM_ZLEC", "NR_ZLEC", "NR_POZ", "ILOSC", "SZER", "WYS", "POW", "OBW", "SZER_OBR", "WYS_OBR", "IL_SUR", "NR_KOM_STR", "LP", "ZN_WAR", "SPOS_OBL", "WSP", "POZIOM", "ZN_PP", "CZY_WAR", "NR_WAR", "NR_KAT", "TYP_KAT", "RODZ_SUR", "JED_POD", "WAGA", "GRUBOSC", "GRUB_1SKL", "N_STRAT", "ZNACZ_PR", "IDENT_BUD", "KOD_STR", "KOD_DOD", "NR_MAG", "NR_KAT_DOD", "KOL_DOD", "NR_PROC"
  )  AS 
  select P.nr_kom_zlec, P.nr_zlec, P.nr_poz, P.ilosc, P.szer, P.wys, P.pow, P.obw,
       D.szer_obr, D.wys_obr,
       case when to_number(trim(substr(nvl(trim(D.nr_poc),'00'),1,2)),'99')=11 --'11 Obróbka',
             then ILOSC_DODATKU(D.nr_komp_obr,D.ilosc_do_wyk,D.par1,D.par2,D.par3,D.par4,D.par5)
            when to_number(trim(substr(nvl(trim(D.nr_poc),'00'),1,2)),'99') between 2 and 10 --szpros
             then -2
            else --ilosc obrobki wg BUDSTR w odniesieniu do powierzchni/obwodu
             decode(V.spos_obl,1,(D.szer_obr*0.001*D.wys_obr*0.001)*V.wsp, --pow
                               2,(D.szer_obr*0.002+D.wys_obr*0.002)*V.wsp, --obw
                               4,V.wsp, --ilosc
                               3,greatest(0,(D.szer_obr*0.002+D.wys_obr*0.002)-V.wsp), --obw - wsp
                               5,greatest(0,(D.szer_obr*0.001*D.wys_obr*0.001)-V.wsp), --pow - wsp
                               12,(D.szer_obr*0.002+D.wys_obr*0.002)*V.wsp*V.grub_1skl*nvl(nullif(P.gr_sil,0),PKG_PARAMETRY.GET_GR_SIL_DEFAULT()),
                    999999)
       end il_sur,
       V."NR_KOM_STR",V."LP",V."ZN_WAR",V."SPOS_OBL",V."WSP",V."POZIOM",V."ZN_PP",V."CZY_WAR",V."NR_WAR",V."NR_KAT",V."TYP_KAT",V."RODZ_SUR",V."JED_POD",V."WAGA",V."GRUBOSC",V."GRUB_1SKL",V."N_STRAT",V."ZNACZ_PR",V."IDENT_BUD",V."KOD_STR",
       D.kod_dod, D.nr_mag, D.nr_kat nr_kat_dod, D.kol_dod, to_number(trim(substr(nvl(trim(D.nr_poc),'00'),1,2)),'99') nr_proc
from spisz P
left join v_str_skl_sur_war V on V.kod_str=P.kod_str and V.rodz_sur<>'CZY'
left join spisd D on D.nr_kom_zlec=P.nr_kom_zlec and D.nr_poz=P.nr_poz and D.do_war=V.nr_war
          --dolinkowanie rek. warstw (strona 4 dla TAFLI) oraz szprosów i obróbek z dodatakami
          --AND NOT szybsze od OR
          and not (D.strona=4 and V.rodz_sur<>'TAF')
          and not (D.strona=0 and V.rodz_sur='TAF')
          and not (to_number(trim(substr(nvl(trim(D.nr_poc),'00'),1,2)),'99')>1 and trim(D.kod_dod) is null)
          and not (to_number(trim(substr(nvl(trim(D.nr_poc),'00'),1,2)),'99')>1 and V.czy_war=0)
--order by Z.nr_kom_zlec desc, nr_poz, nr_skl, nr_skl1, nr_skl2, nr_skl3, nr_skl4;
---------------------------
--New VIEW
--V_SUROWCE_POZ
---------------------------
CREATE OR REPLACE FORCE VIEW "V_SUROWCE_POZ" 
 ( "NR_KOM_ZLEC", "NR_ZLEC", "DATA_ZL", "NR_KON", "SKROT_K", "NR_KONTRAKTU", "NR_POZ", "ILOSC", "NR_KAT", "TYP_KAT", "KOD_DOD", "NR_MAG", "JEDN", "IL_NETTO", "IL_BRUTTO_NOM", "IL_NETTO_OPT", "IL_BRUTTO_OPT"
  )  AS 
  select Z.nr_kom_zlec, Z.nr_zlec, Z.data_zl, nr_kon, K.skrot_k, Z.nr_kontraktu,
       V.nr_poz, min(V.ilosc) ilosc, nr_kat, V.typ_kat,
       case when max(V.nr_proc)<2 then ' ' else max(V.kod_dod) end kod_dod,
       case when max(V.nr_proc)<2 then  0  else max(V.nr_mag)  end nr_mag,
       max(case when V.nr_proc<2 then V.jed_pod
                else (select nvl(max(jed_pod),' ') from kartoteka where indeks=V.kod_dod and nr_mag=V.nr_mag)
           end) jedn,
       round(sum(V.ilosc*V.il_sur),6) il_netto,
       round(sum(V.ilosc*V.il_sur/(1-least(0.999999999,V.n_strat*0.01))),6) il_brutto_nom,
       case when max(V.rodz_sur)='TAF' and max(nr_proc)=0 then
       (select nvl(round(sum(opt_zlec.wyc_netto),6),0)
        from opt_zlec, opt_taf, opt_nr
        where opt_zlec.nr_komp_zlec=Z.nr_kom_zlec
          and opt_zlec.nr_poz=V.nr_poz and opt_zlec.nr_kat=V.nr_kat
          and opt_nr.nr_opt=opt_zlec.nr_opt and opt_taf.nr_opt=opt_zlec.nr_opt and opt_taf.nr_tafli=opt_zlec.nr_tafli
          and opt_taf.poz_w_pak>0)
       +(select nvl(round(sum(opt_zlec.wyc_netto),6),0)
         from opt_zlec, opt_taf, opt_nr,
              zamow W, spisz P
         where W.wyroznik='W' and W.nr_komp_poprz=Z.nr_kom_zlec and P.nr_kom_zlec=W.nr_kom_zlec and P.nr_poz_pop=V.nr_poz
           and opt_zlec.nr_komp_zlec=W.nr_kom_zlec and  opt_zlec.nr_poz=P.nr_poz and opt_zlec.nr_kat=V.nr_kat
           and opt_nr.nr_opt=opt_zlec.nr_opt and opt_taf.nr_opt=opt_zlec.nr_opt and opt_taf.nr_tafli=opt_zlec.nr_tafli
           and opt_taf.poz_w_pak>0)   
       else 0 end   il_netto_opt,
       case when max(V.rodz_sur)='TAF' and max(nr_proc)=0 then
        (select nvl(round(sum(opt_zlec.wyc_netto)*avg(decode(opt_nr.wyc_netto,0,0,opt_nr.wyc_brutto/opt_nr.wyc_netto)),6),0) brutto
         from opt_zlec, opt_taf, opt_nr 
         where opt_zlec.nr_komp_zlec=Z.nr_kom_zlec and opt_zlec.nr_poz=V.nr_poz and opt_zlec.nr_kat=V.nr_kat
           and opt_nr.nr_opt=opt_zlec.nr_opt and opt_taf.nr_opt=opt_zlec.nr_opt and opt_taf.nr_tafli=opt_zlec.nr_tafli
           and opt_taf.poz_w_pak>0)
         +
        (select nvl(round(sum(opt_zlec.wyc_netto)*avg(decode(opt_nr.wyc_netto,0,0,opt_nr.wyc_brutto/opt_nr.wyc_netto)),6),0) brutto
         from opt_zlec, opt_taf, opt_nr,
              zamow W, spisz P
         where W.wyroznik='W' and W.nr_komp_poprz=Z.nr_kom_zlec and P.nr_kom_zlec=W.nr_kom_zlec and P.nr_poz_pop=V.nr_poz
           and opt_zlec.nr_komp_zlec=W.nr_kom_zlec and  opt_zlec.nr_poz=P.nr_poz and opt_zlec.nr_kat=V.nr_kat
           and opt_nr.nr_opt=opt_zlec.nr_opt and opt_taf.nr_opt=opt_zlec.nr_opt and opt_taf.nr_tafli=opt_zlec.nr_tafli
           and opt_taf.poz_w_pak>0)
       else 0 end   il_brutto_opt   
from zamow Z
left join v_surowce_war V on V.nr_kom_zlec=Z.nr_kom_zlec
left join klient K using (nr_kon)
where Z.wyroznik in ('Z','R') and Z.status<>'A'
group by Z.nr_kom_zlec, Z.nr_zlec, Z.data_zl, nr_kon, K.skrot_k, Z.nr_kontraktu,
         V.nr_poz, V.nr_kat, V.typ_kat,
         case when V.nr_proc between 2 and 11 then V.kol_dod else 0 end
order by nr_kom_zlec, nr_poz, nr_kat, nr_mag;
---------------------------
--New VIEW
--V_STR_MON_ZLEC
---------------------------
CREATE OR REPLACE FORCE VIEW "V_STR_MON_ZLEC" 
 ( "NR_KOM_ZLEC", "NR_POZ", "NR_KOM_STR", "KOD_STR", "NR_EL", "NR_EL_WEW", "WAR_OD", "WAR_DO", "GRUB", "GAZ", "SILIKON", "MIEKKA_POW", "HARTOWANA", "MIN_NR_SKL", "MAX_NR_SKL", "TYP_KAT", "NR_KAT", "ATRYBUTY"
  )  AS 
  SELECT nr_kom_zlec, nr_poz, nr_kom_str, V.kod_str,
    to_number(substr(nr_el_nr_war,1,1),'9') nr_el, 
    rank() over (partition by nr_kom_zlec, nr_poz, nr_kom_str order by to_number(substr(nr_el_nr_war,1,1),'9') desc) nr_el_wew,
       min(to_number(substr(nr_el_nr_war,2))) war_od,
       max(to_number(substr(nr_el_nr_war,2))) war_do,
    sum(grubosc) grub,
    max(decode(znacz_pr,'3.Ga',typ_kat,null)) gaz,
    max(decode(znacz_pr,'17.',1,null)) silikon,
    max(decode(znacz_pr,'1.Mi',1,null)) miekka_pow,
    max(decode(znacz_pr,'10.H',1,null)) hartowana,
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
        -1) nr_kat,
    0 atrybuty
    
FROM
(
SELECT V.*,
     --podzapytania wylicza NR_ELEM i NR_WAR (skleja w string typu '56')
    (select nvl(sum(decode(rodz_sur,'LIS',1,0)),0)*2/*il_LIS_przed*/
                   +case when V.rodz_sur='LIS' then 1/*+1 jeAdz?Ladz?adz??Adz?LAeli obecny rekord LIS*/
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
ORDER BY nr_kom_zlec, nr_poz, nr_kom_str, nr_el,nr_el_wew;
---------------------------
--New VIEW
--V_SPISW_SZT
---------------------------
CREATE OR REPLACE FORCE VIEW "V_SPISW_SZT" 
 ( "NR_KOM_ZLEC", "NR_POZ", "NR_SZT", "NR_KOM_SZYBY", "NR_INST", "ZLEC_BRAKI", "NR_OBR", "DATA_WYK", "ID_PRAC", "IL_SZT", "IL_OBR", "SZER_OBR", "WYS_OBR", "NR_RYS", "NR_KSZT", "POW_RZECZ", "OBW_RZECZ", "INDEKS", "KOLEJN", "TYP_POZ", "ATRYB"
  )  AS 
  select nr_kom_zlec, nr_poz, nr_szt, nr_kom_szyby, nr_inst, zlec_braki, nr_obr0 nr_obr, 
       decode(data_wyk,to_date('190101','YYYYMM'),data_konc,data_wyk) data_wyk,
       decode(data_wyk,to_date('190101','YYYYMM'),oper_prod,oper_wyk) id_prac,
       count(1) il_szt, sum(il_jedn) il_obr,
       max(szer_obr) szer_obr, max(wys_obr) wys_obr, min(nr_komp_rys) nr_rys, min(nr_kszt) nr_kszt,
       sum(pow_rzecz) pow_rzecz, sum(obw_rzecz) obw_rzecz,
       indeks, max(kolejn) kolejn, 
--       case when max(typ_inst) in ('MON','STR') then WSP_4ZAKR(nr_inst,max(pow),max(ind_bud)) else 0 end wsp_atryb, 
       max(typ_poz) typ_poz, max(ind_bud) atryb
from v_spisw
where (data_wyk>to_date('190101','YYYYMM') or 
       data_konc>to_date('190101','YYYYMM') and (typ_inst in ('MON','STR') or zn_wyrobu=1 and zn_braku=0) or
       zlec_braki>0 OR not exists (select 1 from braki_b where nr_kom_szyby=v_spisw.nr_kom_szyby and inst_pow=nr_inst))
  --and nr_kom_zlec=:10
group by nr_inst, nr_kom_zlec, nr_poz, nr_szt, nr_kom_szyby, zlec_braki, nr_obr0, indeks, 
       decode(data_wyk,to_date('190101','YYYYMM'),data_konc,data_wyk), --data_wyk
       decode(data_wyk,to_date('190101','YYYYMM'),oper_prod,oper_wyk)  --id_prac
order by nr_kom_zlec, nr_poz, nr_szt, kolejn, data_wyk, nr_obr;
---------------------------
--New VIEW
--V_SPISW_SUMPOZ
---------------------------
CREATE OR REPLACE FORCE VIEW "V_SPISW_SUMPOZ" 
 ( "NR_KOM_ZLEC", "NR_POZ", "NR_INST", "ZLEC_BRAKI", "NR_OBR", "DATA_WYK", "ID_PRAC", "IL_SZT", "IL_OBR", "SZER_OBR", "WYS_OBR", "NR_RYS", "NR_KSZT", "POW_RZECZ", "OBW_RZECZ", "INDEKS", "KOLEJN", "TYP_POZ", "ATRYB"
  )  AS 
  select nr_kom_zlec, nr_poz, nr_inst, zlec_braki, nr_obr0 nr_obr, 
       decode(data_wyk,to_date('190101','YYYYMM'),data_konc,data_wyk) data_wyk,
       decode(data_wyk,to_date('190101','YYYYMM'),oper_prod,oper_wyk) id_prac,
       count(1) il_szt, sum(il_jedn) il_obr,
       max(szer_obr) szer_obr, max(wys_obr) wys_obr, min(nr_komp_rys) nr_rys, min(nr_kszt) nr_kszt,
       sum(pow_rzecz) pow_rzecz, sum(obw_rzecz) obw_rzecz,
       indeks, max(kolejn) kolejn, 
       --case when max(typ_inst) in ('MON','STR') then WSP_4ZAKR(nr_inst,max(pow),max(ind_bud)) else 0 end wsp_atryb,
       max(typ_poz) typ_poz, max(ind_bud) atryb
from v_spisw
where (data_wyk>to_date('190101','YYYYMM') or 
       data_konc>to_date('190101','YYYYMM') and (typ_inst in ('MON','STR') or zn_wyrobu=1 and zn_braku=0) or
       zlec_braki>0 OR not exists (select 1 from braki_b where nr_kom_szyby=v_spisw.nr_kom_szyby and inst_pow=nr_inst))
  --and nr_kom_zlec=:10
group by nr_inst, nr_kom_zlec, nr_poz, zlec_braki, nr_obr0, indeks, 
       decode(data_wyk,to_date('190101','YYYYMM'),data_konc,data_wyk), --data_wyk
       decode(data_wyk,to_date('190101','YYYYMM'),oper_prod,oper_wyk)  --id_prac
order by nr_kom_zlec, nr_poz, kolejn, data_wyk, nr_obr;
---------------------------
--New VIEW
--V_SPISS
---------------------------
CREATE OR REPLACE FORCE VIEW "V_SPISS" 
 ( "ZRODLO", "NR_KOM_ZLEC", "NR_POZ", "ETAP", "WAR_OD", "WAR_DO", "NR_PORZ", "ZN_WAR", "INDEKS", "SZER", "WYS", "POW", "GRUB", "WAGA", "NK_OBR", "KOLEJN_OBR", "NK_INST", "TYP_INST", "NR_INST_POW", "KOLEJNOSC_Z_GRUPY", "GR_AKT", "IDENT_BUD", "IL_OBR", "WSP_C_M", "WSP_HAR", "WSP_HO", "WSP_12ZAKR", "ZNAK_DOD", "WSP_DOD", "KRYT_WYM_DOD", "KRYT_GRUB_PAK", "KRYT_WAGA_PAK", "KRYT_WAGA_1MB", "KRYT_WAGA_ELEM", "KRYT_WYM_MIN", "KRYT_WYM_MAX", "KRYT_ATRYB", "KRYT_ATRYB_WYL", "KRYT_DOW", "KRYT_OBR_JEDNOCZ", "KRYT_SUMA", "KRYT_KTORE", "KRYT_WYK", "OBSL_TECH", "INST_STD", "INST_WYBR", "INST_JAKA", "WSP_PRZEL", "WSP_ALT", "LISTA_OBR_JEDNOCZ"
  )  AS 
  SELECT V.zrodlo,V.nr_kom_zlec,V.nr_poz,V.etap,V.war_od,V.war_do,V.nr_porz,V.zn_war,V.indeks,V.szer,V.wys,V.pow,V.grub,V.waga,V.nk_obr,V.kolejn_obr,
       V.nk_inst,V.ty_inst,V.nr_inst_pow,V.kolejnosc_z_grupy,V.gr_akt,V.ident_bud,V.il_obr,V.wsp_c_m,V.wsp_har,V.wsp_HO,V.wsp_12zakr,V.znak_dod,V.wsp_dod,
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
       nvl(WSP_WG_TYPU_INST(V.ty_inst, V.wsp_12zakr, V.wsp_c_m, V.wsp_har, V.wsp_HO, V.wsp_dod, V.znak_dod, V.wsp_ceny),1) wsp_przel, V.wsp_alt, V.lista_obr_jednocz
FROM (
SELECT S.zrodlo, S.nr_komp_zr nr_kom_zlec, S.nr_kol nr_poz, S.etap, S.war_od, S.war_do, S.nr_porz, S.zn_war, S.indeks, S.szer, S.wys, S.pow, S.grub, S.waga_jedn*S.pow waga,
       S.nk_obr, S.zn_plan kolejn_obr, S.nk_inst, I.ty_inst, I.nr_inst_pow, S.kolejnosc_z_grupy, S.gr_akt, S.ident_bud,
       S.inst_std, W.jaki wsp_jaki, W.wsp_alt,
       case when W.jaki=3 then W.nr_komp_inst else (select nvl(max(W.nr_komp_inst),0) from wsp_alter W where W.nr_kom_zlec=S.nr_komp_zr and W.nr_poz=S.nr_kol and W.nr_porz_obr=S.nr_porz and W.jaki=3) end inst_wybr,
       /*decode(S.zn_war,'Obr',S.il_obr,S.pow)*/S.il_obr il_obr, nvl(wsp_c_m,1) wsp_c_m, nvl(wsp_har,1) wsp_har,
       nvl(decode(trim(I.ty_inst),'HAR',WSP_HO(S.zrodlo,S.nr_komp_zr,S.nr_kol,S.etap,S.war_od),0),0) wsp_HO,
       nvl(wsp_12zakr(S.nk_inst,S.pow,S.ident_bud),1) wsp_12zakr,
       nvl(nvl(D1.znak,nvl(D2.znak,nvl(D3.znak,D0.znak))),'*') znak_dod, nvl(nvl(D1.wsp_przel,nvl(D2.wsp_przel,nvl(D3.wsp_przel,D0.wsp_przel))),1) wsp_dod,
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
(SELECT S.zrodlo, S.nr_komp_zr, S.nr_kol, S.id_rek, S.etap, S.war_od, S.war_do, S.nr_porz, S.zn_war, S.zn_plan, S.szer, S.wys, S.szer*S.wys*0.000001 pow, S.indeks, S1.ident_bud, S.il_obr, S.inst_std,
        least(S.szer,S.wys) bok_min, greatest(S.szer,S.wys) bok_max,
        nvl(K.grubosc,Str.gr_pak) grub, K.wsp_c_m, K.wsp_har,
        nvl(K.waga,Str.waga) waga_jedn, nvl(K.waga*S.szer*S.wys*0.000001,0) waga_elem, Str.wsp_cen,
        decode(S.zn_war,'Obr',S.nr_kat,0) nr_czynn, S.nk_obr,
        nvl(G.nr_komp_inst,S.inst_std) nk_inst,
        nvl(G.kolejnosc,0) kolejnosc_z_grupy, nvl(G.akt,0) gr_akt,
        (select listagg('O'||SJ.nk_obr||';N'||SJ.nr_porz||';I'||VJ.nr_komp_inst||';','|') within group (order by SJ.nk_obr)
         from spiss SJ, v_obr_jednocz VJ
         where SJ.zrodlo=S.zrodlo and SJ.nr_komp_zr=S.nr_komp_zr and SJ.nr_kol=S.nr_kol and SJ.etap=S.etap and SJ.war_od=S.war_od
           and (SJ.nk_obr=VJ.nr_obr_jednocz and SJ.nk_obr<>S.nk_obr and VJ.nr_komp_obr=S.nk_obr or
                S.nk_obr=VJ.nr_obr_jednocz and SJ.nk_obr<>S.nk_obr and VJ.nr_komp_obr=SJ.nk_obr)
           and SJ.zn_plan>0 --and VJ.nr_komp_inst=G.nr_komp_inst
           ) lista_obr_jednocz
 FROM spiss S
 --link do rekordu warstwy
 LEFT JOIN spiss S1 ON S1.zrodlo=S.zrodlo and S1.nr_komp_zr=S.nr_komp_zr and S1.nr_kol=S.nr_kol and S1.etap=S.etap and S1.czy_war=1 and S.war_od between S1.war_od and S1.war_do and S1.strona=0
 --linki do pobrania wagi
 LEFT JOIN katalog K on K.typ_kat=S.indeks
 LEFT JOIN struktury Str on Str.kod_str=S.indeks
 --link do pobrania instalacji dla obróbek
 LEFT JOIN gr_inst_dla_obr G ON S.nk_obr=G.nr_komp_obr
 --wybierane sa wszystkie skladniki, które maja byc planowane
 WHERE S.zrodlo in ('T','Z') and S.nk_obr>0 and S.zn_plan>0
 --zamiast ponizszych zerowanie ZN_PLAN w proc. SPISS_MAT
   --AND NOT (S.etap=1 and S.rodz_sur='POL' and S.zn_war='Obr' and S.nr_porz>100) --obrobki ze SPISD nie planowane na pólprodukcie tylko w zlec wew.
   --AND NOT (S.nk_obr=1 and substr(S1.ident_bud,19,1)='1')  --usuniecie ZAT w EFF, bo w strukturach SZKLO\Z\H; podobny warunek w GEN_LWYC
) S
--link do sprawdzenia wyliczonych wspolczynnikow
LEFT JOIN wsp_alter W ON W.nr_kom_zlec=S.nr_komp_zr and W.nr_poz=S.nr_kol and W.nr_porz_obr=S.nr_porz and W.nr_komp_inst=S.nk_inst and W.nr_zestawu=0
--link do pobrania wspolczynnika ceny (dla GP)
--LEFT JOIN struktury Str ON Str.kod_str=S.indeks and S.etap>=3
--linki do wsp. dodatk. (4x, bo mozenie byc rekordów odpowaidajacych nr obróbki i/lub typowi katal.)
LEFT JOIN pinst_dodn D1 ON D1.nr_komp_inst=S.nk_inst and D1.typ_kat=S.indeks and D1.nr_komp_obr=S.nk_obr --and S.grub between D1.grub_od and D1.grub_do
LEFT JOIN pinst_dodn D2 ON D2.nr_komp_inst=S.nk_inst and D2.typ_kat=S.indeks and D2.nr_komp_obr=0 --and S.grub between D2.grub_od and D2.grub_do
LEFT JOIN pinst_dodn D3 ON D3.nr_komp_inst=S.nk_inst and trim(D3.typ_kat) is null and D3.nr_komp_obr=S.nk_obr and S.grub between D3.grub_od and D3.grub_do
LEFT JOIN pinst_dodn D0 ON D0.nr_komp_inst=S.nk_inst and trim(D0.typ_kat) is null and D0.nr_komp_obr=0 and S.grub between D0.grub_od and D0.grub_do
--link do spr. kryteriów z parametrów instalacji
LEFT JOIN parinst I ON I.nr_komp_inst=S.nk_inst
--link do pobranie ostrzezenia operatora
--LEFT JOIN tech_kontr_poz T ON T.nr_komp_zap=0 and T.nr_komp_zlec=S.nr_komp_zr and T.id_rek=S.id_rek and T.nr_kolejny=S.nr_porz
--link do pobrania decyzji dla kontroli poprawnosci techn/      
--LEFT JOIN (select nr_komp_zlec, max(nr_komp_zap) nr_komp_zap_ost from tech_kontr group by nr_komp_zlec) TK ON TK.nr_komp_zlec=S.nr_komp_zr
--LEFT JOIN tech_kontr_poz TKP ON TKP.nr_komp_zap=TK.nr_komp_zap_ost AND TKP.nr_komp_zlec=S.nr_komp_zr AND TKP.id_rek=S.id_rek AND TKP.nr_kolejny=S.nr_porz AND TKP.nr_komp_instal=S.nk_inst
) V;
---------------------------
--New VIEW
--V_ORDER_DATA18
---------------------------
CREATE OR REPLACE FORCE VIEW "V_ORDER_DATA18" 
 ( "NR_KOM_ZLEC", "NR_ZLEC", "NR_KON", "STATUS", "R_DAN", "DATA_ZL", "NR_POZ", "TYP_POZ", "SZER", "WYS", "NR_KOMP_RYS", "NR_KOM_STR", "ZN_WAR", "NR_WAR", "NR_KOM_SKL", "TYP_KAT_CZY", "KOD_POLP", "ATRYB_SKL", "SZER_OBR", "WYS_OBR", "STRONA", "NR_KAT", "TYP_KAT", "KOD_DOD", "NR_POC", "WSP1", "WSP2", "WSP3", "WSP4", "NR_KOMP_OBR", "SYMB_P_OBR", "ILOSC_DO_WYK", "ATR10_WAR", "OBR_Z_NADD", "OBR_OBWODOWA", "KOD_STR"
  )  AS 
  Select V.nr_kom_zlec, V.nr_zlec, V.nr_kon, V.status, V.r_dan, V.data_zl, V.nr_poz, V.typ_poz, V.szer, V.wys, V.nr_komp_rys,
       V.nr_kom_str, V.zn_war, V.nr_war, V.nr_kom_skl, V.typ_kat typ_kat_czy, V.kod_polp, V.ident_bud atryb_skl,
       D.szer_obr, D.wys_obr, D.strona, D.nr_kat, K.typ_kat, D.kod_dod,
       D.nr_poc, D.wsp1, D.wsp2, D.wsp3, D.wsp4,
       D.nr_komp_obr, O.symb_p_obr, D.ilosc_do_wyk,
       decode(D.strona,0,max(to_number(nvl(substr(V.ident_bud,10,1),0))*10
                                +case when V.zn_war='Pol' and 
                                           exists (select 1 from v_str_sur1 V1
                                                   where V1.kod_str=V.kod_polp and V1.rodz_sur='CZY' and V1.znacz_pr='10.H')
                                           then 2
                                      when V.rodz_sur='CZY' then 1 
                                      else 0 end)
                         over (partition by V.nr_kom_zlec, V.nr_poz, V.nr_war)) atr10_war,
       max((select count(1) from lista_p_obr L where L.nr_komp_struktury=D.nr_komp_obr and L.czy_korekt_wym=1)) over (partition by V.nr_kom_zlec, V.nr_poz, V.nr_war) obr_z_nadd,
       decode(D.strona,0,max((case O.met_oblicz when 1 then 1 else 0 end))  over (partition by V.nr_kom_zlec, V.nr_poz, V.nr_war),null) obr_obwodowa,
       V.kod_str
from V_STR_SKL_Z V
left join spisd D on D.nr_kom_zlec=V.nr_kom_zlec and D.nr_poz=V.nr_poz and D.do_war=V.nr_war and V.czy_war=1
left join katalog K on K.nr_kat=D.nr_kat
left join slparob O on O.nr_k_p_obr=D.nr_komp_obr
--z widoku V_STR_SKL_Z pobierane tylko warstwy i czynnosci
where not (V.czy_war=0 and V.rodz_sur<>'CZY');
---------------------------
--New VIEW
--V_ORDER_DATA1
---------------------------
CREATE OR REPLACE FORCE VIEW "V_ORDER_DATA1" 
 ( "NR_KOM_ZLEC", "NR_ZLEC", "NR_KON", "STATUS", "WYROZNIK", "R_DAN", "DATA_ZL", "NR_POZ", "SZER", "WYS", "NR_KOMP_RYS", "NR_KOM_STR", "ZN_WAR", "NR_WAR", "NR_KOM_SKL", "KOD_POLP", "SZER_OBR", "WYS_OBR", "STRONA", "NR_KAT", "TYP_KAT", "KOD_DOD", "NR_POC", "WSP1", "WSP2", "WSP3", "WSP4", "NR_KOMP_OBR", "SYMB_P_OBR", "ILOSC_DO_WYK", "OBR_Z_NADD", "KOD_STR"
  )  AS 
  Select V.nr_kom_zlec, V.nr_zlec, V.nr_kon, V.status, V.wyroznik, V.r_dan, V.data_zl, V.nr_poz, V.szer, V.wys, V.nr_komp_rys,
       V.nr_kom_str, V.zn_war, V.nr_war, V.nr_kom_skl, V.kod_polp,
       D.szer_obr, D.wys_obr, D.strona, D.nr_kat, K.typ_kat, D.kod_dod,
       D.nr_poc, D.wsp1, D.wsp2, D.wsp3, D.wsp4,
       D.nr_komp_obr, O.symb_p_obr, D.ilosc_do_wyk,
       max((select count(1) from lista_p_obr L where L.nr_komp_struktury=D.nr_komp_obr and czy_korekt_wym=1)) over (partition by V.nr_kom_zlec, V.nr_poz, V.nr_war) obr_z_nadd,
       V.kod_str
from V_STR_WAR_Z V
left join spisd D on D.nr_kom_zlec=V.nr_kom_zlec and D.nr_poz=V.nr_poz and D.do_war=V.nr_war
left join katalog K on K.nr_kat=D.nr_kat
left join slparob O on O.nr_k_p_obr=D.nr_komp_obr;
---------------------------
--New VIEW
--V_OBR_WG_DPS_WG_WYR
---------------------------
CREATE OR REPLACE FORCE VIEW "V_OBR_WG_DPS_WG_WYR" 
 ( "GRUP", "D_PL_SPED", "SORT", "TYP_POZ", "KSZT", "SZPR", "NR_OBR", "KOLEJN_OBR", "SYMB_OBR", "NAZ_OBR", "IL_SZT", "IL_RZECZ", "IL_PRZEL", "IL_ZL", "IL_SZT_W_PROD", "IL_RZECZ_W_PROD", "IL_PRZEL_W_PROD", "IL_ZL_W_PROD", "IL_SZT_WYK", "IL_RZECZ_WYK", "IL_PRZEL_WYK", "IL_ZL_WYK", "MAX_ZL", "POZOSTALO"
  )  AS 
  SELECT nvl2(d_pl_sped,'D','T') grup, nvl(d_pl_sped,trunc(d_pl_sped,'D')) d_pl_sped,
       rank() over (partition by d_pl_sped order by typ_poz, kszt nulls first, szpr nulls first) sort,
       typ_poz, kszt, szpr, nr_obr,
       max(kolejn_obr) kolejn_obr, max(symb_p_obr) symb_obr, max(nazwa_p_obr) naz_obr,
       count(1) il_szt, sum(il_obr) il_rzecz, sum(il_obr*wsp_p) il_przel, count(distinct nr_kom_zlec) il_zl,
       count(nr_kom_szyby) il_szt_w_prod, sum(nvl2(nr_kom_szyby,1,0)*il_obr) il_rzecz_w_prod, sum(nvl2(nr_kom_szyby,1,0)*il_obr*wsp_p) il_przel_w_prod, count(distinct nvl2(nr_kom_szyby,nr_kom_zlec,null)) il_zl_w_prod,
       count(nullif(wyk,0)) il_szt_wyk, sum(wyk*il_obr) il_rzecz_wyk, sum(wyk*il_obr*wsp_p) il_przel_wyk, count(distinct nr_kom_zlec)-count(distinct case when wyk=1 then null else nr_kom_zlec end) il_zl_wyk,
       max(nr_kom_zlec) max_zl, nvl2(d_pl_sped,d_pl_sped-trunc(sysdate),(trunc(d_pl_sped,'D')-trunc(sysdate,'D'))/7) pozostalo
FROM V_OBR_W_ZLEC
WHERE zn_wyrobu=1 and nr_obr>0
GROUP BY trunc(d_pl_sped,'D'), rollup(d_pl_sped), nr_obr, typ_poz, cube(kszt, szpr)
--HAVING NOT (kszt is not null and szpr is null)
HAVING  grouping_id(kszt,szpr)=3 or grouping_id(kszt,szpr)=2 and szpr=1 and kszt is null or grouping_id(kszt,szpr)=1 and kszt=1 and szpr is null or grouping_id(kszt,szpr)=0 and szpr*kszt=1  --bez rekordu "ile bez ksztatów" oraz "ile ksztatów" bez szprosu
ORDER BY sort;
---------------------------
--New VIEW
--V_OBR_WG_DPS24
---------------------------
CREATE OR REPLACE FORCE VIEW "V_OBR_WG_DPS24" 
 ( "GRUP", "D_PL_SPED", "NR_OBR", "KOLEJN_OBR", "SYMB_OBR", "NAZ_OBR", "IL_SZT", "IL_RZECZ", "IL_PRZEL", "IL_ZL", "IL_SZT_W_PROD", "IL_RZECZ_W_PROD", "IL_PRZEL_W_PROD", "IL_ZL_W_PROD", "IL_SZT_WYK", "IL_RZECZ_WYK", "IL_PRZEL_WYK", "IL_ZL_WYK", "MAX_ZL", "POZOSTALO"
  )  AS 
  SELECT nvl2(d_pl_sped,'D','T') grup, nvl(d_pl_sped,trunc(d_pl_sped,'D')) d_pl_sped, nr_obr, max(kolejn_obr) kolejn_obr, max(symb_p_obr) symb_obr, max(nazwa_p_obr) naz_obr,
       count(1) il_szt, sum(il_obr) il_rzecz, sum(il_obr*wsp_p) il_przel, count(distinct nr_kom_zlec) il_zl,
       count(nr_kom_szyby) il_szt_w_prod, sum(nvl2(nr_kom_szyby,1,0)*il_obr) il_rzecz_w_prod, sum(nvl2(nr_kom_szyby,1,0)*il_obr*wsp_p) il_przel_w_prod, count(distinct nvl2(nr_kom_szyby,nr_kom_zlec,null)) il_zl_w_prod,
       count(nullif(wyk,0)) il_szt_wyk, sum(wyk*il_obr) il_rzecz_wyk, sum(wyk*il_obr*wsp_p) il_przel_wyk, count(distinct nr_kom_zlec)-count(distinct case when wyk=1 then null else nr_kom_zlec end) il_zl_wyk,
       max(nr_kom_zlec) max_zl, nvl2(d_pl_sped,d_pl_sped-trunc(sysdate),(trunc(d_pl_sped,'D')-trunc(sysdate,'D'))/7) pozostalo
FROM V_OBR_W_ZLEC
GROUP BY trunc(d_pl_sped,'D'), rollup(d_pl_sped), nr_obr
ORDER BY d_pl_sped desc, kolejn_obr, nr_obr;
---------------------------
--New VIEW
--V_FAK_WG_STOJ
---------------------------
CREATE OR REPLACE FORCE VIEW "V_FAK_WG_STOJ" 
 ( "TYP_DOKS", "NR_KOMP_DOKS", "DATA_WYS", "NR_DOKS", "NR_POZ_DOKS", "NR_STOJ_SPED", "NR_STOJ", "ILE_SZYB_NA_STOJ", "ILE_SZT_W_POZ"
  )  AS 
  select V.typ_doks, V.nr_komp_doks, V.data_wys, V.nr_doks, V.nr_poz_doks,
       V.nr_stoj_sped, max(S.nr_stoj) nr_stoj,
       count(distinct V.nr_kom_szyby) ile_szyb_na_stoj, max(il_szt) ile_szt_w_poz
from V_FAK_WZ_SPISE V
left join stojsped S on S.nr_komp_stoj=V.nr_stoj_sped
group by V.typ_doks, V.nr_komp_doks, V.data_wys, V.nr_doks, V.nr_poz_doks, V.nr_stoj_sped
order by V.nr_komp_doks desc, V.nr_poz_doks, V.nr_stoj_sped;
---------------------------
--New VIEW
--V_CHECK_ORDER18
---------------------------
CREATE OR REPLACE FORCE VIEW "V_CHECK_ORDER18" 
 ( "NR_KOM_ZLEC", "NR_ZLEC", "NR_KON", "STATUS", "R_DAN", "DATA_ZL", "NR_POZ", "TYP_POZ", "SZER", "WYS", "NR_KOMP_RYS", "NR_KOM_STR", "ZN_WAR", "NR_WAR", "NR_KOM_SKL", "TYP_KAT_CZY", "KOD_POLP", "ATRYB_SKL", "SZER_OBR", "WYS_OBR", "STRONA", "NR_KAT", "TYP_KAT", "KOD_DOD", "NR_POC", "WSP1", "WSP2", "WSP3", "WSP4", "NR_KOMP_OBR", "SYMB_P_OBR", "ILOSC_DO_WYK", "ATR10_WAR", "OBR_Z_NADD", "OBR_OBWODOWA", "KOD_STR", "ERR_INFO"
  )  AS 
  SELECT "NR_KOM_ZLEC","NR_ZLEC","NR_KON","STATUS","R_DAN","DATA_ZL","NR_POZ","TYP_POZ","SZER","WYS","NR_KOMP_RYS","NR_KOM_STR","ZN_WAR","NR_WAR","NR_KOM_SKL","TYP_KAT_CZY","KOD_POLP","ATRYB_SKL","SZER_OBR","WYS_OBR","STRONA","NR_KAT","TYP_KAT","KOD_DOD","NR_POC","WSP1","WSP2","WSP3","WSP4","NR_KOMP_OBR","SYMB_P_OBR","ILOSC_DO_WYK","ATR10_WAR","OBR_Z_NADD","OBR_OBWODOWA","KOD_STR","ERR_INFO" FROM
 (Select V.*,
       --sprawdzenie spojnosci miedzy budowA struktury a SPISD
       case when zn_war='Sur' and not V.nr_kom_skl=V.nr_kat and V.strona in (0,4)
            then 1 else 0 end ||
       case when zn_war='Pol' and not V.kod_polp=V.kod_dod and V.strona in (0,4)
            then 1 else 0 end ||
       --sprawdzenie czy jest rekord w ZLEC_POLP
       case when zn_war='Pol' and V.strona in (0,4) and
                 not exists (select 1 from zlec_polp P
                             where P.nr_komp_zlec=V.nr_kom_zlec and P.nr_poz_zlec=V.nr_poz
                               and P.nr_strukt=V.nr_kom_skl)
            then 1 else 0 end ||
            '00'|| --do wykorzystania do sprawdzenia danych warstwy
       --sprawdzenie czy wyliczona ilosc obróbki
       case when V.nr_komp_obr>0 and V.ilosc_do_wyk=0
            then 1 else 0 end ||
       --sprawdzenie czy jest obróbka obwodowa do obróbki Hartowanie (11-H na warstwie, 12-H w polprodukcie)
       case when V.atr10_war in(11,12) and V.obr_obwodowa=0
            then 1 else 0 
       end ||
       --sprawdzenie czy jest obrobka obwodowa na warstwie z atryb 10.Hart
       case when V.r_dan=1 and V.atr10_war=10 and V.obr_obwodowa=0
            then 1 else 0 
       end ||
       --sprawdzenie czy jest obróbka obwodowa dla formatek
       case when V.r_dan=1 and V.typ_poz in ('cie','str') and V.obr_obwodowa=0
            then 1 else 0 
       end err_info
  From V_ORDER_DATA18 V )
 WHERE trim(replace(err_info,'0','')) is not null;
---------------------------
--New VIEW
--V_CHECK_ORDER1
---------------------------
CREATE OR REPLACE FORCE VIEW "V_CHECK_ORDER1" 
 ( "NR_KOM_ZLEC", "NR_ZLEC", "NR_KON", "STATUS", "WYROZNIK", "R_DAN", "DATA_ZL", "NR_POZ", "SZER", "WYS", "NR_KOMP_RYS", "NR_KOM_STR", "ZN_WAR", "NR_WAR", "NR_KOM_SKL", "KOD_POLP", "SZER_OBR", "WYS_OBR", "STRONA", "NR_KAT", "TYP_KAT", "KOD_DOD", "NR_POC", "WSP1", "WSP2", "WSP3", "WSP4", "NR_KOMP_OBR", "SYMB_P_OBR", "ILOSC_DO_WYK", "OBR_Z_NADD", "KOD_STR", "ERR_INFO"
  )  AS 
  Select V."NR_KOM_ZLEC",V."NR_ZLEC",V."NR_KON",V."STATUS",V."WYROZNIK",V."R_DAN",V."DATA_ZL",V."NR_POZ",V."SZER",V."WYS",V."NR_KOMP_RYS",V."NR_KOM_STR",V."ZN_WAR",V."NR_WAR",V."NR_KOM_SKL",V."KOD_POLP",V."SZER_OBR",V."WYS_OBR",V."STRONA",V."NR_KAT",V."TYP_KAT",V."KOD_DOD",V."NR_POC",V."WSP1",V."WSP2",V."WSP3",V."WSP4",V."NR_KOMP_OBR",V."SYMB_P_OBR",V."ILOSC_DO_WYK",V."OBR_Z_NADD",V."KOD_STR",
       case when zn_war='Sur' and not V.nr_kom_skl=V.nr_kat and V.strona in (0,4)
            then 1 else 0 end ||
       case when zn_war='Pol' and not V.kod_polp=V.kod_dod and V.strona in (0,4)
            then 1 else 0 end ||
       case when zn_war='Pol' and strona in (0,4) and wyroznik<>'O' and
                 not exists (select 1 from zlec_polp P
                             where P.nr_komp_zlec=V.nr_kom_zlec and P.nr_poz_zlec=V.nr_poz
                               and P.nr_strukt=V.nr_kom_skl)
            then 1 else 0 end ||
            '00'|| --do wykorzystania
       case when V.nr_komp_obr>0 and V.ilosc_do_wyk=0
            then 1 else 0 
       end err_info
 From V_ORDER_DATA1 V
 Where V.strona in (0,4) and 
       (V.zn_war='Sur' and not V.nr_kom_skl=V.nr_kat or
        V.zn_war='Pol' and (not V.kod_polp=V.kod_dod or 
                            V.r_dan in (0,1) and wyroznik<>'O' and V.strona=0 and
                            not exists (select 1 from zlec_polp P
                                        where P.nr_komp_zlec=V.nr_kom_zlec and P.nr_poz_zlec=V.nr_poz
                                          and P.nr_strukt=V.nr_kom_skl))
       )
       Or V.nr_komp_obr>0 and V.ilosc_do_wyk=0
  --and nr_kom_zlec=&ZL;
---------------------------
--New VIEW
--SPISS_VLAM
---------------------------
CREATE OR REPLACE FORCE VIEW "SPISS_VLAM" 
 ( "ZRODLO", "NR_KOMP_ZR", "NR_KOL", "SZER", "WYS", "NR_KOM_STR", "LP", "ETAP", "CZY_WAR", "NR_WAR", "KTORY_LAM", "KTORE_SZKLO", "CZY_KOLEJNA", "WAR_OD", "WAR_DO", "NK_OBR", "IL_FOL_WAR", "NR_KOM_SKL_NAST", "TYP_KAT_SKL_NAST", "TYP_KAT", "NR_KAT", "RODZ_SUR", "GRUB", "TYP_INST", "NR_INST", "ID_REK", "KOD_LAM", "NK_OBR_WE", "SYMB_OBR_WE", "NR_KAT_OBR_WE", "KOLEJN_WE", "NK_OBR_WY", "SYMB_OBR_WY", "NR_KAT_OBR_WY", "KOLEJN_WY", "IDENT_BUD", "IDENT_BUD_SKL", "IDENT_SPISZ", "KOD_STR"
  )  AS 
  SELECT  zrodlo, nr_komp_zr, nr_kol, szer, wys, S.nr_kom_str, lp,  decode(czy_war,1,1,2) etap, czy_war, nr_war,
        dense_rank() over (partition by nr_komp_zr,nr_kol order by war_do) ktory_lam,
        dense_rank() over (partition by nr_komp_zr,nr_kol,war_do order by nr_war) ktore_szklo, czy_kolejna,
        nr_war-/*ktore_szklo*/dense_rank() over (partition by nr_komp_zr,nr_kol,war_do order by nr_war)+1 war_od, war_do,
        S.nk_obr, il_fol_war, B.nr_kom_skl nr_kom_skl_nast, K.typ_kat typ_kat_skl_nast,
        S.typ_kat, S.nr_kat, S.rodz_sur, grub, S.typ_inst, S.nr_inst, S.id_rek,
        kod_laminatu(S.nr_kom_str,/*war_od*/nr_war-dense_rank() over (partition by nr_komp_zr,nr_kol,war_do order by nr_war)+1,war_do) kod_lam,
        O1.nr_k_p_obr nk_obr_WE, O1.symb_p_obr symb_obr_WE, O1.nr_kat_obr nr_kat_obr_WE, O1.kolejn_obr kolejn_WE, 
        O2.nr_k_p_obr nk_obr_WY, O2.symb_p_obr symb_obr_WY, O2.nr_kat_obr nr_kat_obr_WY, O2.kolejn_obr kolejn_WY, 
        rpad(translate(reverse(to_char(sum(reverse(rpad(S.ident_bud_skl,50,'0'))) over  (partition by S.zrodlo, S.nr_komp_zr, S.nr_kol, war_do))),'23456789','11111111'),50,'0') ident_bud,
        S.ident_bud_skl, S.ident_bud ident_spisz, S.kod_str
FROM
(select (case
          when rodz_sur='FOL' or sum(case when rodz_sur='FOL' then 1 else 0 end) over (partition by nr_komp_zr,nr_kol,nr_war)>0  --il_fol_war>0
           then (select min(min(nr_war)) from spiss_str S2
                 where S2.zrodlo='S' and S2.nr_komp_zr=S.nr_kom_str and S2.nr_kol=1 and S2.nr_war>=S.nr_war
                 group by nr_war
                 having count(decode(S2.rodz_sur,'FOL',1,null))=0)
          when nr_war>1 and
               exists (select 1 from spiss_str S2
                       where S2.zrodlo='S' and S2.nr_komp_zr=S.nr_kom_str and S2.nr_kol=1 and S2.nr_war=S.nr_war-1 and S2.rodz_sur='FOL')
           then nr_war            
          else 0 end) war_do,
        (case when nr_war>1 and rodz_sur<>'FOL' --and sum(case when rodz_sur='FOL' then 1 else 0 end) over (partition by nr_komp_zr,nr_kol,nr_war)>0  --il_fol_war>0
           and exists (select 1 from spiss_str S2
                       where S2.zrodlo='S' and S2.nr_komp_zr=S.nr_kom_str and S2.nr_kol=1 and S2.nr_war=S.nr_war-1 and S2.rodz_sur='FOL')
         then 1 else 0 end) czy_kolejna,  --warstwa po warstwie z folia
--       (select max(S.nr_war-S2.nr_war) from spiss_str S2
--        where S2.zrodlo='S' and S2.nr_komp_zr=S.nr_kom_str and S2.nr_kol=1 and S2.nr_war=S.nr_war-1 and S2.rodz_sur='FOL') czy_konc,
--        (select min(min(nr_war)) from v_str_sur1 S2
--         where S2.nr_kom_str=S.nr_komp_zr and S2.nr_war>=S.nr_war
--         group by S2.nr_war
--         having count(decode(S2.rodz_sur,'FOL',1,null))=0
--        ) war_do,
--        (select max(S.nr_war-S2.nr_war) from v_str_sur1 S2
--         where S2.nr_kom_str=S.nr_komp_zr and S2.nr_war=S.nr_war-1 and S2.rodz_sur='FOL'
--        ) war_konc, 
        sum(case when rodz_sur='FOL' then 1 else 0 end) over (partition by nr_komp_zr,nr_kol,nr_war) il_fol_war,
        --f.LEAD dziala zbyt dugo, pewnie przez S.lp w Order BY
        --case when rodz_sur='FOL' then LEAD(S.typ_kat,1) OVER (ORDER BY nr_komp_zr, S.nr_kol, S.lp) else null end symb_czynn,
        --case when rodz_sur='FOL' then LEAD(S.nr_kat,1) OVER (ORDER BY nr_komp_zr, S.nr_kol, S.lp) else 0 end nr_czynn, 
        --max(nr_fol) over (partition by nr_komp_zr,nr_kol,nr_war) nr_fol_war_max,
        S.*
 from spiss_str S
) S
LEFT JOIN slparob O1 ON O1.obr_lacz=3 --obr LAM_P
LEFT JOIN slparob O2 ON O2.obr_lacz=1 --obr LAM
--po szukanie czynnosci (X1..Xn) po folii (nr_skl+1)
LEFT JOIN budstr B ON B.nr_kom_str=S.nr_kom_str_skl and B.nr_skl=S.nr_skl+1
LEFT JOIN katalog K ON K.nr_kat=B.nr_kom_skl
WHERE (czy_war=1 and czy_kolejna=1 or il_fol_war>0 and (czy_war=1 or S.rodz_sur='FOL' or S.rodz_sur='CZY' and S.znacz_pr='9.La'))
--WHERE il_fol_war2>0
--WHERE 1=1--(etap=1 and czy_war=1 or etap=2)
--  AND S.zrodlo='S' and S.nr_komp_zr=:STR_LAM
ORDER BY S.nr_komp_zr, S.nr_kol, S.LP;
---------------------------
--New VIEW
--SPISS_VLACZ
---------------------------
CREATE OR REPLACE FORCE VIEW "SPISS_VLACZ" 
 ( "ZRODLO", "NR_KOMP_ZR", "NR_KOL", "ETAP", "CZY_WAR", "WAR_OD", "WAR_DO", "RODZ_SUR", "STRONA", "NR_PORZ", "ZN_WAR", "SZER", "WYS", "NK_OBR", "SYMB_OBR", "NR_KAT_OBR", "PAR1", "PAR2", "PAR3", "PAR4", "PAR5", "BOKI", "IL_OBR", "IL_SUR", "ZN_PLAN", "INST_STD", "INST_USTAL", "NR_KAT", "KOD_DOD", "ZN_PP", "TYP_KAT", "INDEKS", "IDENT_BUD", "NR_MAG", "NR_KOM_STR", "KOD_STR", "ID_REK", "POZIOM", "IDENT_DOD", "STR_DOD", "CENA"
  )  AS 
  select S.zrodlo, S.nr_komp_zr, S.nr_kol, -1 etap, case when O.obr_lacz=5 then 1 else 0 end czy_war,
        --S.nr_war-1 war_od, S.nr_war+1 war_do,
        (select nvl(max(war_od),S.nr_war-1) from spiss_vlam S1 where S1.zrodlo=S.zrodlo and S1.nr_komp_zr=S.nr_komp_zr and S1.nr_kol=S.nr_kol and S1.nr_war=S.nr_war-1) war_od,
        (select nvl(max(war_do),S.nr_war+1) from spiss_vlam S1 where S1.zrodlo=S.zrodlo and S1.nr_komp_zr=S.nr_komp_zr and S1.nr_kol=S.nr_kol and S1.nr_war=S.nr_war+1) war_do,
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
       --kod_laminatu(S.nr_kom_str,S.nr_war-1,S.nr_war+1) indeks, 
       kod_laminatu(S.nr_kom_str,
                    (select nvl(max(war_od),S.nr_war-1) from spiss_vlam S1 where S1.zrodlo=S.zrodlo and S1.nr_komp_zr=S.nr_komp_zr and S1.nr_kol=S.nr_kol and S1.nr_war=S.nr_war-1),
                    (select nvl(max(war_do),S.nr_war+1) from spiss_vlam S1 where S1.zrodlo=S.zrodlo and S1.nr_komp_zr=S.nr_komp_zr and S1.nr_kol=S.nr_kol and S1.nr_war=S.nr_war+1)
                   ) indeks, 
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
---------------------------
--New VIEW
--SPISS_V_E1
---------------------------
CREATE OR REPLACE FORCE VIEW "SPISS_V_E1" 
 ( "ZRODLO", "NR_KOMP_ZR", "NR_KOL", "ETAP", "CZY_WAR", "WAR_OD", "WAR_DO", "RODZ_SUR", "STRONA", "NR_PORZ", "ZN_WAR", "SZER", "WYS", "NK_OBR", "SYMB_OBR", "NR_KAT_OBR", "PAR1", "PAR2", "PAR3", "PAR4", "PAR5", "BOKI", "IL_OBR", "IL_SUR", "ZN_PLAN", "INST_STD", "INST_USTAL", "NR_KAT", "KOD_DOD", "ZN_PP", "TYP_KAT", "INDEKS", "IDENT_BUD", "NR_MAG", "NR_KOM_STR", "KOD_STR", "ID_REK", "POZIOM", "IDENT_DOD", "STR_DOD", "CENA"
  )  AS 
  select zrodlo, S.nr_komp_zr, S.nr_kol, S.etap, case when S.czy_war=1 and D.strona in (0,4) then 1 else 0 end czy_war,
--       nvl(rec_zero,decode(war_lam,1,2,nvl(L.etap,S.etap))) etap, war_lam, L.lp lp_lam,
--               --sum(decode(S.rodz_sur,'FOL',1,0)) over (partition by S.nr_komp_zr,S.nr_kol) ile_fol,
               S.nr_war war_od, S.nr_war war_do, 
               nvl(KRA.rodz_sur,S.rodz_sur) rodz_sur, nvl(D.strona,decode(S.rodz_sur,'CZY',2,0)) strona, --S.lp,
               case when S.czy_war=1 and D.strona=0 then S.lp else nvl(S.etap*100+D.kol_dod,S.lp) end nr_porz,
               /*D.zn_war Dzn_war,*/ case when S.rodz_sur='CZY' or D.nr_poc='11 O' then 'Obr' else nvl(D.zn_war,'Sur') end zn_war,
               nvl(decode(D.strona,4,D.szer_obr,D0.szer_obr),S.szer) szer, nvl(decode(D.strona,4,D.wys_obr,D0.wys_obr),S.wys) wys,
               --decode(sign(S.nk_obr),1,S.nk_obr,nvl(D.nr_komp_obr,decode(S.rodz_sur,'CZY',S.nr_kat,0))) nk_obr,
               nvl(O1.nr_k_p_obr,nvl(KRA.nk_obr,case when S.nk_obr>0 and (D.strona<>0 or S.rodz_sur='CZY') then S.nk_obr when S.rodz_sur='CZY' then S.nr_kat when D.strona=4 then nvl(O0.nr_k_p_obr,0) else 0 end)) nk_obr,
               nvl(O1.symb_p_obr,nvl(OKRA.symb_p_obr,case when S.nk_obr>0 and (D.strona<>0 or S.rodz_sur='CZY') then O.symb_p_obr when S.rodz_sur='CZY' then S.typ_kat when D.strona=4 then nvl(O0.symb_p_obr,0) else ' ' end)) symb_obr,
               nvl(O1.nr_kat_obr,nvl(KRA.nr_kat,case when S.nk_obr>0 and (D.strona<>0 or S.rodz_sur='CZY') then O.nr_kat_obr when S.rodz_sur='CZY' then S.nr_kat when D.strona=4 then nvl(O0.nr_kat_obr,0) else 0 end)) nr_kat_obr,
               nvl2(O1.nr_k_p_obr,D.par1,O.par_1) par1,  nvl2(O1.nr_k_p_obr,D.par2,O.par_2) par2, nvl2(O1.nr_k_p_obr,D.par3,O.par_3) par3,  nvl2(O1.nr_k_p_obr,D.par4,O.par_4) par4, nvl2(O1.nr_k_p_obr,D.par5,O.par5) par5,
               RPAD(lpad(to_char(D.IL_ODC_PION),9,'0')||'0'||lpad(to_char(D.IL_ODC_Poz),5,'0'), 20, '0') boki, --D.IL_ODC_PION, D.IL_ODC_Poz,
               nvl2(O1.nr_k_p_obr,D.ilosc_do_wyk,
                nvl2(KRA.nr_kat,D.il_pol_szp,
                     case when O.met_oblicz=1 then /*obw*/D0.szer_obr*0.002+D0.wys_obr*0.002
                          when nvl(O0.met_oblicz,O.met_oblicz)=2 then /*pow*/decode(D.strona,4,D.szer_obr,D0.szer_obr)*0.001*decode(D.strona,4,D.wys_obr,D0.wys_obr)*0.001
                     else 1 end)) il_obr,
               /*pow*/decode(D.strona,4,D.szer_obr,D0.szer_obr)*0.001*decode(D.strona,4,D.wys_obr,D0.wys_obr)*0.001 il_sur,
               nvl(O1.kolejn_obr,nvl(OKRA.kolejn_obr,case when S.nk_obr>0 and (D.strona<>0 or S.rodz_sur='CZY') then O.kolejn_obr when S.rodz_sur='CZY' then I.kolejn when D.strona=4 then nvl(O0.kolejn_obr,0) else 0 end)) zn_plan,
               nvl(I1.nr_komp_inst,nvl(IKRA.nr_komp_inst,case when S.rodz_sur='CZY' and I2.nr_komp_inst is not null then I2.nr_komp_inst when S.nr_inst>0 and not (S.czy_war=1 and D.strona=0) then I.nr_komp_inst when D.strona=4 then nvl(O0.nr_komp_inst,0) else 0 end)) inst_std,
               (select nvl(min(nr_komp_inst),0) 
                from wsp_alter where nr_kom_zlec=S.nr_komp_zr and nr_poz=S.nr_kol and jaki=3
                                 and nr_porz_obr=/*nr_porz*/(case when S.czy_war=1 and D.strona=0 then S.lp else nvl(S.etap*100+D.kol_dod,S.lp) end)) inst_ustal,
               --decode(nvl(D.nr_kat,0),0,K0.nr_kat,D.nr_kat) nr_kat, 28/03
               --nvl(D0.nr_kat,S.nr_kat) nr_kat, --zakomentowane 28/01/2019 przed wdrozeniem do Eff ze wzgledu na bleny w V_SPISS_ERR
               nvl(nullif(S.nr_kat,0),D0.nr_kat) nr_kat, 
               case when KRA.nr_kat is not null or O1.nr_k_p_obr is not null then D.kod_dod else ' ' end kod_dod, S.zn_pp, 
               nvl(KRA.typ_kat,S.typ_kat) typ_kat,
               nvl2(KRA.nr_kat,D.kod_dod,decode(S.rodz_sur,'CZY',K0.typ_kat,S.typ_kat)) indeks,
               case when /*czy_war*/S.czy_war=1 and D.strona in (0,4) 
                    then ATRYB_SUM(IDENT_ETAP(1,S.ident_bud),   --S.ident_bud=SPISZ.IND_BUD
                                   rpad(translate(reverse(to_char(sum(reverse(rpad(case when D.strona=4 then '0' when D.nr_komp_obr>0 then K1.ident_bud else nvl(KRA.ident_bud,S.ident_bud_skl) end,100,'0'))) over  (partition by S.zrodlo, S.nr_komp_zr, S.nr_kol, S.etap, S.nr_war))),'23456789','11111111'),50,'0'))
                    when /*obr ze SPISD*/D.nr_komp_obr>0 then K1.ident_bud
                    when KRA.nr_kat is not null then KRA.ident_bud
                    else S.ident_bud_skl end ident_bud,
               nvl(D.nr_mag,S.nr_mag) nr_mag,
               S.nr_kom_str, S.kod_str, S.id_rek, 0 poziom, S.nr_skl ident_dod, ' ' str_dod, 0 cena
from spiss_str S
--link do rekordu warstwy
left join spisd D0 on D0.nr_kom_zlec=S.nr_komp_zr and D0.nr_poz=S.nr_kol and D0.do_war=S.nr_war and D0.strona=0
--dane szkla (strona=0)
left join katalog K0 on K0.nr_kat=D0.nr_kat
left join slparob O0 on O0.nr_k_p_obr=K0.nk_obr and K0.rodz_sur='POL'
--link do wszystkich rekordów na warstwie
left join spisd D on D.nr_kom_zlec=S.nr_kom_zlec and D.nr_poz=S.nr_poz and S.czy_war=1 and D.do_war=S.nr_war
--obrobka ze SPISD
left join slparob O1 on O1.nr_k_p_obr=D.nr_komp_obr and D.nr_komp_obr>0
left join katalog K1 on K1.nr_kat=O1.nr_kat_obr
left join parinst I1 on I1.nr_komp_inst=O1.nr_komp_inst
--KRATA
left join katalog KRA on KRA.nr_kat=D.nr_kat and KRA.rodz_sur='KRA'
left join slparob OKRA on OKRA.nr_k_p_obr=KRA.nk_obr
left join parinst IKRA on IKRA.ty_inst=KRA.typ_inst1 and IKRA.nr_inst=KRA.nr_inst
--instalacja, obrobka z Katalogu
left join slparob O on O.nr_k_p_obr=S.nk_obr and KRA.nr_kat is null
left join parinst I on I.ty_inst=S.typ_inst and I.nr_inst=S.nr_inst
left join parinst I2 on I2.nr_komp_inst=O.nr_komp_inst
--instalacja ze Slownika Obróbek
where 1=1 --and S.nr_komp_zr=:NK_ZLEC --and nr_kol=:POZ
  and not (S.rodz_sur='FOL' or S.rodz_sur='CZY' and S.znacz_pr='9.La' or nvl(O1.obr_lacz,0)>0)
  --and not (S.rodz_sur='CZY' and S.nr_kat=(select nvl(max(O.nr_kat_obr),-1) from spisd D, slparob O where D.nr_kom_zlec=S.nr_kom_zlec and D.nr_poz=S.nr_poz and D.do_war=S.nr_war and O.nr_k_p_obr=D.nr_komp_obr));
---------------------------
--New VIEW
--SPISS_V
---------------------------
CREATE OR REPLACE FORCE VIEW "SPISS_V" 
 ( "ZRODLO", "NR_KOMP_ZR", "NR_KOL", "ETAP", "CZY_WAR", "WAR_OD", "WAR_DO", "RODZ_SUR", "STRONA", "NR_PORZ", "ZN_WAR", "SZER", "WYS", "NK_OBR", "SYMB_OBR", "NR_KAT_OBR", "PAR1", "PAR2", "PAR3", "PAR4", "PAR5", "BOKI", "IL_OBR", "IL_SUR", "ZN_PLAN", "INST_STD", "INST_USTAL", "NR_KAT", "KOD_DOD", "ZN_PP", "TYP_KAT", "INDEKS", "IDENT_BUD", "NR_MAG", "NR_KOM_STR", "KOD_STR", "ID_REK", "POZIOM", "IDENT_DOD", "STR_DOD", "CENA"
  )  AS 
  select zrodlo, S.nr_komp_zr, S.nr_kol, 0 etap, 0 czy_war, 0 war_od, 0 war_do, ' ' rodz_sur, 0 strona, 0 nr_porz,
               'Str' zn_war, szer, wys,0 nk_obr, ' ' symb_obr, 0 nr_kat_obr, 0 par1, 0 par2, 0 par3, 0 par4, 0 par5, ' ' boki, 0 il_obr, pow il_sur,
               0 zn_plan, 0 inst_std, 0 inst_ustal, 0 nr_kat, ' ' kod_dod, S.zn_pp, ' ' typ_kat, S.kod_str indeks, S.ident_bud, nr_mag, nr_kom_str, kod_str, id_rek,
               0 poziom, nr_kom_str ident_dod, rpad(' ',50) str_dod, 0 cena
 from spiss_str S where lp=1
UNION -- ETAP 1
 select "ZRODLO","NR_KOMP_ZR","NR_KOL","ETAP","CZY_WAR","WAR_OD","WAR_DO","RODZ_SUR","STRONA","NR_PORZ","ZN_WAR","SZER","WYS","NK_OBR","SYMB_OBR","NR_KAT_OBR","PAR1","PAR2","PAR3","PAR4","PAR5","BOKI","IL_OBR","IL_SUR","ZN_PLAN","INST_STD","INST_USTAL","NR_KAT","KOD_DOD","ZN_PP","TYP_KAT","INDEKS","IDENT_BUD","NR_MAG","NR_KOM_STR","KOD_STR","ID_REK","POZIOM","IDENT_DOD","STR_DOD","CENA" from spiss_v_e1
UNION -- ETAP -1, renumeroany na 2 lub 3 w SPISS_MAT (GTE szyba ogniochronna)
 select "ZRODLO","NR_KOMP_ZR","NR_KOL","ETAP","CZY_WAR","WAR_OD","WAR_DO","RODZ_SUR","STRONA","NR_PORZ","ZN_WAR","SZER","WYS","NK_OBR","SYMB_OBR","NR_KAT_OBR","PAR1","PAR2","PAR3","PAR4","PAR5","BOKI","IL_OBR","IL_SUR","ZN_PLAN","INST_STD","INST_USTAL","NR_KAT","KOD_DOD","ZN_PP","TYP_KAT","INDEKS","IDENT_BUD","NR_MAG","NR_KOM_STR","KOD_STR","ID_REK","POZIOM","IDENT_DOD","STR_DOD","CENA" from spiss_vlacz
/* dane obróbek przygotowujace do laczenia przygotowywane w oddzielnej procedurze
UNION -- laminowanie WE
SELECT zrodlo, nr_komp_zr, nr_kol, etap, 0 czy_war, nr_war war_od, nr_war war_do,
       'CZY' rodz_sur, 2 strona, 2000+S.lp nr_porz, 'Obr' zn_war,
       szer, wys, nk_obr_WE nk_obr, O.symb_p_obr symb_obr, nr_kat_obr,
       O.par_1 par1, O.par_2 par2, O.par_3 par3, O.par_4 par4, O.par5, ' ' boki,
       S.szer*0.001*S.wys*0.001 il_obr, S.szer*0.001*S.wys*0.001 il_sur,
       O.kolejn_obr zn_plan, O.nr_komp_inst inst_std,
       (select nvl(min(nr_komp_inst),0) 
        from wsp_alter where nr_kom_zlec=S.nr_komp_zr and nr_poz=S.nr_kol and jaki=3
                         and nr_porz_obr=2000+S.lp) inst_ustal,
       0 nr_kat, ' ' kod_dod, 0 zn_pp, typ_kat, typ_kat indeks, S.ident_bud, 0 nr_mag,
       0 nr_kom_str, kod_str, S.id_rek, 0 poziom, 0 ident_dod, ' ' str_dod, 0 cena
From spiss_vlam S
LEFT JOIN slparob O ON O.nr_k_p_obr=S.nk_obr_WE --obr LAM_P
WHERE czy_war=1 and etap=1 */
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
Where (czy_war=1 and ktore_szklo in (1,2) or S.rodz_sur='FOL')
/*UNION --laminowanie OLD
Select zrodlo, nr_komp_zr, nr_kol, 22 etap, case when czy_war=1 or S.rodz_sur='CZY' and nr_war=war_od then 1 else 0 end czy_war, war_od, war_do,
       S.rodz_sur, decode(czy_war,1,0,decode(S.rodz_sur,'CZY',4,2)) strona, 200+S.lp nr_porz,
       decode(S.rodz_sur,'FOL','Sur','Pol') zn_war, S.szer, S.wys,
       decode(S.rodz_sur,'CZY',nk_obr,0) nk_obr, decode(S.rodz_sur,'CZY',O.symb_p_obr,'') symb_obr, decode(S.rodz_sur,'CZY',nvl(O.nr_kat_obr,nr_kat),0) nr_kat_obr,
       O.par_1 par1, O.par_2 par2, O.par_3 par3, O.par_4 par4, O.par5, '000' boki,
       S.szer*0.001*S.wys*0.001 il_obr, S.szer*0.001*S.wys*0.001 il_sur, --pow
       nvl(O.kolejn_obr,I.kolejn) zn_plan, nvl(O.nr_komp_inst,I.nr_komp_inst) inst_std,
       (select nvl(min(nr_komp_inst),0) 
        from wsp_alter where nr_kom_zlec=S.nr_komp_zr and nr_poz=S.nr_kol and jaki=3
                         and nr_porz_obr=200+S.lp) inst_ustal,
       0 nr_kat, decode(S.rodz_sur,'FOL',typ_kat,kod_lam) kod_dod, 0 zn_pp, typ_kat, kod_lam, '00e' ident_bud, 0 nr_mag,
       S.nr_kom_str, S.kod_str, S.id_rek, 0 poziom, ktory_lam ident_dod, ' ' str_dod, 0 cena
From spiss_vlam S
LEFT JOIN slparob O ON S.rodz_sur='CZY' and O.nr_k_p_obr=S.nk_obr and S.nk_obr>0          --obr LAM
Left join parinst I on S.rodz_sur='CZY' and I.ty_inst=S.typ_inst and I.nr_inst=S.nr_inst
Where 0=1 and (nr_war=war_od or S.rodz_sur='FOL')
--  and  S.nr_komp_zr=:NK_ZLEC and nr_kol=:POZ
*/
UNION --ETAP 3 zespalanie i obrobki pomontazowe (ze SPISD)
Select 'Z' zrodlo, Z.nr_kom_zlec nr_komp_zr, Z.nr_poz nr_kol,
       --decode((select max(do_war)-sum(decode(K.rodz_sur,'LIS',2,0)) from spisd D,katalog K where D.nr_kom_zlec=Z.nr_kom_zlec and D.nr_poz=Z.nr_poz and K.nr_kat=D.nr_kat and D.strona=4),1,2,3) etap, --jest etap LAM jesli WAR_MAX>(IL_LISTEW)*2+1
       3 etap, --zmiana ze MON zawsze etap 3 niewazny czy jest LAM
       case when X.strona in (0,4) then 1 else 0 end czy_war, 1 war_od, (select max(do_war) from spisd  D where D.nr_kom_zlec=Z.nr_kom_zlec and D.nr_poz=Z.nr_poz) war_do,
       ' ' rodz_sur, X.strona, 300+nvl(D.kol_dod,X.strona) nr_porz,
       'Str' zn_war, Z.szer, Z.wys,
       --decode(X.strona,4,O.nr_k_p_obr,0) nk_obr, decode(X.strona,4,O.symb_p_obr,' ') symb_obr, decode(X.strona,4,O.nr_kat_obr,0) nr_kat_obr,
       --decode(X.strona,4,O.par_1,0) par1, decode(X.strona,4,O.par_2,0) par2, decode(X.strona,4,O.par_3,0) par3, decode(X.strona,4,O.par_4,0) par4, decode(X.strona,4,O.par5,0) par5, 
       nvl(O.nr_k_p_obr,0) nk_obr, nvl(O.symb_p_obr,' ') symb_obr, nvl(O.nr_kat_obr,0) nr_kat_obr,
       nvl(D.par1,nvl(O.par_1,0)) par1, nvl(D.par2,nvl(O.par_2,0)) par2, nvl(D.par3,nvl(O.par_3,0)) par3, nvl(D.par4,nvl(O.par_4,0)) par4, nvl(D.par5,nvl(O.par5,0)) par5, '000' boki,
       nvl(D.ilosc_do_wyk,decode(X.strona,4,pow,0)) il_obr, pow il_sur,
       nvl(O.kolejn_obr,0) zn_plan, nvl(I.nr_komp_inst,0) inst_std,
       (select nvl(min(nr_komp_inst),0) 
        from wsp_alter where nr_kom_zlec=Z.nr_kom_zlec and nr_poz=Z.nr_poz and jaki=3
                         and nr_porz_obr=300+nvl(D.kol_dod,X.strona)/*nr_porz*/) inst_ustal,
       0 nr_kat, ' ' kod_dod, 0 zn_pp, ' ' typ_kat, kod_str indeks, Z.ind_bud ident_bud, Z.nr_mag,
       0 nr_kom_str, kod_str, id_poz id_rek, 0 poziom, 0 ident_dod, ' ' str_dod, 0 cena
From spisz Z
LEFT JOIN (select 0 strona from firma union
           select 1 strona from firma union
           select 2 strona from firma union
           select 3 strona from firma union
           select 4 strona from firma) X
       ON 1=1
LEFT JOIN (select nr_k_p_obr, nr_komp_inst from slparob where obr_lacz=2 and rownum=1) MON ON 1=1 --obr MON podzapytanie celem zabezpiecznia przed >1 rekordem
LEFT JOIN spisd D on D.nr_kom_zlec=Z.nr_kom_zlec and D.nr_poz=Z.nr_poz and D.strona=X.strona and D.nr_komp_obr>0
LEFT JOIN slparob O on O.nr_k_p_obr=MON.nr_k_p_obr and X.strona=4 or O.nr_k_p_obr=D.nr_komp_obr and O.obr_lacz=8 and X.strona in (1,2,3)
LEFT JOIN parinst I on I.nr_komp_inst=O.nr_komp_inst or X.strona=0 and I.nr_komp_inst=MON.nr_komp_inst
Where Z.typ_zlec='Pro' and Z.typ_poz in ('I k','II ') and (X.strona in (0,4) and (instr(I.ind_bud,'1')=0 or ATRYB_MATCH(I.ind_bud,Z.ind_bud)=1)
                                                           or O.obr_lacz=8) --obr_lacz=8 obróbka pomontazowa
  --and  nr_kom_zlec=:NK_ZLEC and nr_poz=:POZ
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
  And I.czy_czynna='TAK' and (instr(I.ind_bud,'1')=0 or ATRYB_MATCH(I.ind_bud,P.ind_bud)=1)
  --and  nr_kom_zlec=:NK_ZLEC and nr_poz=:POZ
ORDER BY zrodlo, nr_komp_zr, nr_kol, etap, war_od, czy_war desc, zn_plan, strona;
---------------------------
--New TRIGGER
--ZAMOW_ON_UPD_D_ZAK_PROD
---------------------------
  CREATE OR REPLACE TRIGGER "ZAMOW_ON_UPD_D_ZAK_PROD"
  BEFORE UPDATE OF D_ZAK_PROD ON "ZAMOW"
  REFERENCING FOR EACH ROW
  BEGIN
  :NEW.D_ZAK_PROD:=DATA_ZAK_PROD_WG_SPISE(:NEW.NR_KOM_ZLEC);
EXCEPTION WHEN OTHERS THEN 
  NULL;
END;
/
---------------------------
--New TRIGGER
--ZAMOW_ON_DELETE
---------------------------
  CREATE OR REPLACE TRIGGER "ZAMOW_ON_DELETE"
  BEFORE DELETE ON "ZAMOW"
  REFERENCING FOR EACH ROW
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
---------------------------
--New TRIGGER
--ZAMOW_ON_CHANGE
---------------------------
  CREATE OR REPLACE TRIGGER "ZAMOW_ON_CHANGE"
  AFTER INSERT OR DELETE OR UPDATE ON "ZAMOW"
  REFERENCING FOR EACH ROW
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
-- jezeli zlecenie kierujemy do produkcji zmieniamy status na Opracowane 2 (wersja zmien Dane)
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
-- jezeli zlecenie kierujemy do produkcji zmieniamy status na Opracowane 2 (wersja zmien Zlecenie, wykorzystuje RPZLEC)
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
  ALTER TRIGGER "ZAMOW_ON_CHANGE" DISABLE;
/
---------------------------
--New TRIGGER
--UPDATEKODPASKONINSERT
---------------------------
  CREATE OR REPLACE TRIGGER "UPDATEKODPASKONINSERT"
  AFTER INSERT ON "SPISE"
  REFERENCING FOR EACH ROW
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
---------------------------
--New TRIGGER
--TR_ZAMINFO_IND_BUD
---------------------------
  CREATE OR REPLACE TRIGGER "TR_ZAMINFO_IND_BUD"
  BEFORE INSERT ON "ZAMINFO"
  REFERENCING FOR EACH ROW
  BEGIN
  :NEW.IND_BUD:=SIGN(:NEW.atrb_1_il)||SIGN(:NEW.atrb_2_il)||SIGN(:NEW.atrb_3_il)||SIGN(:NEW.atrb_4_il)||SIGN(:NEW.atrb_5_il)||
                SIGN(:NEW.atrb_6_il)||SIGN(:NEW.atrb_7_il)||SIGN(:NEW.atrb_8_il)||SIGN(:NEW.atrb_9_il)||SIGN(:NEW.atrb_10_il)||
                SIGN(:NEW.atrb_11_il)||SIGN(:NEW.atrb_12_il)||SIGN(:NEW.atrb_13_il)||SIGN(:NEW.atrb_14_il)||SIGN(:NEW.atrb_15_il)||
                SIGN(:NEW.atrb_16_il)||SIGN(:NEW.atrb_17_il)||SIGN(:NEW.atrb_18_il)||SIGN(:NEW.atrb_19_il)||SIGN(:NEW.atrb_20_il)||
                SIGN(:NEW.atrb_21_il)||SIGN(:NEW.atrb_22_il)||SIGN(:NEW.atrb_23_il)||SIGN(:NEW.atrb_24_il)||SIGN(:NEW.atrb_25_il)||
                SIGN(:NEW.atrb_26_il)||SIGN(:NEW.atrb_27_il)||SIGN(:NEW.atrb_28_il)||SIGN(:NEW.atrb_29_il)||SIGN(:NEW.atrb_30_il);
EXCEPTION WHEN OTHERS THEN
 NULL;
END;
/
---------------------------
--New TRIGGER
--TR_HARMON_CHECK_LWYC
---------------------------
  CREATE OR REPLACE TRIGGER "TR_HARMON_CHECK_LWYC"
  BEFORE INSERT ON "HARMON"
  REFERENCING FOR EACH ROW
 WHEN (NEW.TYP_HARM='P')
  DECLARE 
 jestLWYC NUMBER(1);
 jestSPISS NUMBER(1);
BEGIN
 SELECT count(1) INTO jestLWYC   FROM dual WHERE exists (select 1 from l_wyc where nr_kom_zlec=:NEW.NR_KOMP_ZLEC);
 IF jestLWYC=0 THEN
  SELECT count(1) INTO jestSPISS  FROM dual WHERE exists (select 1 from spiss where zrodlo='Z' and nr_komp_zr=:NEW.NR_KOMP_ZLEC);
  IF jestSPISS=0 THEN
   SPISS_MAT('Z',:NEW.NR_KOMP_ZLEC);
  END IF;
  ZAPISZ_LWYC(:NEW.NR_KOMP_ZLEC,0,0);
 END IF;  
END;
/
---------------------------
--New TRIGGER
--TRG_POZKARTPOP1
---------------------------
  CREATE OR REPLACE TRIGGER "TRG_POZKARTPOP1"
  BEFORE INSERT ON "POZKARTPOP"
  REFERENCING FOR EACH ROW
  BEGIN
  SELECT znacznik INTO :NEW.ZN_KART
  FROM magazyn WHERE nr_mag=:NEW.NR_MAG;
  :NEW.ZN_KARTOTEKI:=UTL_RAW.CAST_TO_RAW(:NEW.ZN_KART);
EXCEPTION WHEN OTHERS THEN
  NULL;
END;
/
---------------------------
--New TRIGGER
--TRG_POZKARTOT1
---------------------------
  CREATE OR REPLACE TRIGGER "TRG_POZKARTOT1"
  BEFORE INSERT ON "POZKARTOT"
  REFERENCING FOR EACH ROW
  BEGIN
  SELECT znacznik INTO :NEW.ZN_KART
  FROM magazyn WHERE nr_mag=:NEW.NR_MAG;
  :NEW.ZN_KARTOTEKI:=UTL_RAW.CAST_TO_RAW(:NEW.ZN_KART);
EXCEPTION WHEN OTHERS THEN
  NULL;
END;
/
---------------------------
--New TRIGGER
--STATUS_ZLEC_ON_CHANGE
---------------------------
  CREATE OR REPLACE TRIGGER "STATUS_ZLEC_ON_CHANGE"
  AFTER INSERT OR UPDATE OF STATUS ON "STATUSY_ZLEC"
  REFERENCING FOR EACH ROW
  BEGIN
  Insert into statusy_zlec_log(nr_komp_zlec,status,status_last,"DATA",czas,operator,komputer) 
    values(:new.nr_komp_zlec,:new.status,:old.status,sysdate,to_char(sysdate(),'HH24MISS'),:new.operator,:new.komputer);
--gdy 3->4 blokada zlecenia
--  if :old.status=3  and :new.status=4 then
--    select max(nr_komp_zlec) into czy_metki from spise where nr_komp_zlec=:new.nr_komp_zlec and nr_poz=1 and nr_szt=1;
--    if czy_metki is null then 
--      update zamow set flag_r=to_number(rep_str(lpad(flag_r,6,'0'),1,4)) where nr_kom_zlec=:new.nr_komp_zlec and substr(lpad(flag_r,6,'0'),4,1)='0';
--      
      -- zapetlanie "w kolko" z drugim triggerem
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
---------------------------
--New TRIGGER
--SQL_HIST_ID_TR
---------------------------
  CREATE OR REPLACE TRIGGER "SQL_HIST_ID_TR"
  BEFORE INSERT ON "SQL_HISTORIA"
  REFERENCING FOR EACH ROW
  begin  
   if inserting then 
      if :NEW."HIS_ID" is null OR :NEW.HIS_ID=0 then 
         select SQL_hist_seq.nextval into :NEW."HIS_ID" from dual; 
      end if; 
   end if; 
end;
/
---------------------------
--New TRIGGER
--SPISE_WYK_BY_SPED
---------------------------
  CREATE OR REPLACE TRIGGER "SPISE_WYK_BY_SPED"
  BEFORE UPDATE OF DATA_WYK, ZM_WYK, NR_KOMP_INST ON "SPISE"
  REFERENCING FOR EACH ROW
 WHEN (OLD.NR_KOMP_INST*NEW.NR_KOMP_INST=0 OR OLD.NR_STOJ_SPED=0 AND NEW.NR_STOJ_SPED>0 AND NEW.O_ODCZ=NEW.O_WYK)
  BEGIN
  :NEW.POZ_ST_PR:=0;
  UPDATE l_wyc
  SET nr_inst_wyk=:NEW.NR_KOMP_INST,
      d_wyk=:NEW.DATA_WYK, zm_wyk=:NEW.ZM_WYK,
      data=trunc(sysdate), czas=to_char(sysdate,'HH24MISS')
  WHERE nr_kom_zlec=:NEW.NR_KOMP_ZLEC AND nr_poz_zlec=:NEW.NR_POZ AND nr_szt=:NEW.NR_SZT    
    AND nr_warst=1 and zn_wyrobu=1;

  --trigger SPISE_ON_WYK
  PKG_REJESTRACJA.UZUPELNIJ_L_WYC(:NEW.NR_KOM_SZYBY, :NEW.NR_KOMP_ZLEC, :NEW.NR_POZ, :NEW.NR_SZT, 0,
                                0, 2, 0, 0, :NEW.DATA_WYK, :NEW.ZM_WYK, 0, 0,
                                case when :NEW.DATA_WYK>to_date('2001','YYYY') then 1 else 0 end);  
EXCEPTION WHEN OTHERS THEN
 ZAPISZ_LOG('SPISE_WYK_BY_SPED',:NEW.NR_KOMP_ZLEC,'E',0);
 ZAPISZ_ERR(SQLERRM);
END;
/
---------------------------
--New TRIGGER
--SPISE_POZ_ST_ZERO
---------------------------
  CREATE OR REPLACE TRIGGER "SPISE_POZ_ST_ZERO"
  BEFORE UPDATE OF POZ_ST_SPED ON "SPISE"
  REFERENCING FOR EACH ROW
 WHEN (NEW.POZ_ST_SPED>998)
  BEGIN
  :NEW.POZ_ST_SPED:=0;
END;
/
---------------------------
--New TRIGGER
--SPISE_ECUTTER
---------------------------
  CREATE OR REPLACE TRIGGER "SPISE_ECUTTER"
  AFTER INSERT OR DELETE OR UPDATE ON "SPISE"
  REFERENCING FOR EACH ROW
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
  ALTER TRIGGER "SPISE_ECUTTER" DISABLE;
/
---------------------------
--New TRIGGER
--OPT_TAF_ON_ZATW
---------------------------
  CREATE OR REPLACE TRIGGER "OPT_TAF_ON_ZATW"
  BEFORE UPDATE OF D_WYK, ZM_WYK, NR_KOMP_INSTAL, FLAG ON "OPT_TAF"
  REFERENCING FOR EACH ROW
  BEGIN
  PKG_REJESTRACJA.REJ_WG_TAFLI(:NEW.nr_opt, :NEW.nr_tafli, 1, :NEW.d_wyk, :NEW.zm_wyk, case when :NEW.ZM_WYK>0 then :NEW.nr_komp_instal else 0 end);
EXCEPTION WHEN OTHERS THEN
 ZAPISZ_LOG('OPT_TAF_ON_ZATW',:NEW.nr_opt,'U',0);
 ZAPISZ_ERR(SQLERRM);
END;
/
---------------------------
--New TRIGGER
--OPT_TAF_INST_PLAN
---------------------------
  CREATE OR REPLACE TRIGGER "OPT_TAF_INST_PLAN"
  BEFORE INSERT OR UPDATE OF NR_KOMP_INSTAL ON "OPT_TAF"
  REFERENCING FOR EACH ROW
 WHEN (NEW.NR_KOMP_ZMW=0)
  BEGIN
  :NEW.NR_INST_PLAN:=:NEW.NR_KOMP_INSTAL;
END;
/
---------------------------
--New TRIGGER
--LWYC_WYCINKI
---------------------------
  CREATE OR REPLACE TRIGGER "LWYC_WYCINKI"
  AFTER INSERT OR DELETE ON "L_WYC"
  REFERENCING FOR EACH ROW
  begin
    if inserting and :new.TYP_INST in ('A C','R C') then
  		INSERT into wycinki(NR_KOMP_ZLEC,NR_POZ,NR_SZT,NR_WAR,CREATED) 
        VALUES(:new.nr_kom_zlec,:new.nr_poz_zlec,:new.nr_szt,:new.nr_warst,sysdate());
    end if;
    if deleting and :old.TYP_INST in ('A C','R C') then 
      DELETE from wycinki where NR_KOMP_ZLEC=:old.nr_kom_zlec and NR_POZ=:old.nr_poz_zlec and
        NR_SZT=:old.nr_szt and NR_WAR=:old.nr_warst;
    end if;
exception when others then
 null;
end;
/
---------------------------
--New TRIGGER
--LWYC_REJESTRACJA
---------------------------
  CREATE OR REPLACE TRIGGER "LWYC_REJESTRACJA"
  BEFORE UPDATE OF ZN_BRAKU, D_WYK, ZM_WYK, NR_INST_WYK ON "L_WYC"
  REFERENCING FOR EACH ROW
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
---------------------------
--New TRIGGER
--LWYC_IDREK
---------------------------
  CREATE OR REPLACE TRIGGER "LWYC_IDREK"
  BEFORE INSERT ON "L_WYC"
  REFERENCING FOR EACH ROW
 WHEN (NEW.ID_REK=0)
  BEGIN
 :NEW.ID_REK:=lwyc_seq.nextval;
END;
/
---------------------------
--New TRIGGER
--LOG_ZM_INS
---------------------------
  CREATE OR REPLACE TRIGGER "LOG_ZM_INS"
  BEFORE INSERT ON "LOG_ZM"
  REFERENCING FOR EACH ROW
  BEGIN
 :NEW.DATA:=trunc(sysdate);
 :NEW.CZAS:=to_char(sysdate,'HH24MISS');
 :NEW.OS_USER:=sys_context('USERENV','OS_USER');
 :NEW.SID:=sys_context('USERENV','SESSIONID');
END;
/
---------------------------
--New TRIGGER
--HARMON_ON_ZATW
---------------------------
  CREATE OR REPLACE TRIGGER "HARMON_ON_ZATW"
  BEFORE INSERT ON "HARMON"
  REFERENCING FOR EACH ROW
 WHEN (NEW.TYP_HARM='W')
  BEGIN
  UPDATE zamow
  SET D_ZAK_PROD=DATA_ZAK_PROD_WG_SPISE(nr_kom_zlec)
  WHERE nr_kom_zlec=:NEW.NR_KOMP_ZLEC;
EXCEPTION WHEN OTHERS THEN 
  NULL;
END;
/
---------------------------
--New TRIGGER
--GRUP_ZLEC_TR
---------------------------
  CREATE OR REPLACE TRIGGER "GRUP_ZLEC_TR"
  BEFORE INSERT ON "GRUP_ZLEC"
  REFERENCING FOR EACH ROW
 WHEN (NEW.NR_GR=0 AND NEW.NK_ZLEC>0)
  BEGIN
 :NEW.NR_GR := GRUP_ZLEC_SEQ.nextval;
END;
/
---------------------------
--New TRIGGER
--CR_DATA_TR
---------------------------
  CREATE OR REPLACE TRIGGER "CR_DATA_TR"
  BEFORE INSERT ON "CR_DATA"
  REFERENCING FOR EACH ROW
  BEGIN
	 IF :NEW.LP is null or :NEW.LP=0 THEN
	   SELECT cr_data_seq.nextval INTO :NEW.LP FROM dual;
	 END IF;
	END;
/
---------------------------
--New TRIGGER
--CALC_KARTOTEKA_ILOSC
---------------------------
  CREATE OR REPLACE TRIGGER "CALC_KARTOTEKA_ILOSC"
  BEFORE DELETE ON "TMPPOZDOK"
  REFERENCING FOR EACH ROW
 WHEN (OLD.ZNACZNIK_KARTOTEKI not in ('Wyr','Czy'))
  DECLARE
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
---------------------------
--New TRIGGER
--BRAKIB_ON_CREATE
---------------------------
  CREATE OR REPLACE TRIGGER "BRAKIB_ON_CREATE"
  BEFORE INSERT ON "BRAKI_B"
  REFERENCING FOR EACH ROW
  BEGIN
 SELECT braki_b_seq.nextval INTO :NEW.NR_KOL FROM dual;

 INSERT INTO cr_data (nr_kom_zlec,nr_poz,nr_szt,nr_war,szer,wys,
                      id_br,nr_war_br,typ_kat,flag)
 SELECT D.nr_kom_zlec, D.nr_poz, :NEW.nr_szt, D.do_war, D.szer_obr, D.wys_obr,
        :NEW.nr_kol, row_number() over (order by D.do_war), K.typ_kat, 0
 FROM spisd D LEFT JOIN katalog K USING (nr_kat)
 WHERE D.nr_kom_zlec=:NEW.nr_zlec and D.nr_poz=:NEW.nr_poz and D.strona=4
   AND (:NEW.nr_war in (0,D.do_war) OR
        :NEW.laminat=1 and D.do_war between :NEW.nr_war
        and (select max(W.straty) war_do from wykzal W
             where W.nr_komp_zlec=D.nr_kom_zlec and W.nr_poz=D.nr_poz
               and W.nr_warst=:NEW.nr_war and W.straty>W.nr_warst)
       );
EXCEPTION WHEN OTHERS THEN
 NULL;
END;
/
---------------------------
--New PROCEDURE
--ZMIEN_GIETARKE
---------------------------
CREATE OR REPLACE PROCEDURE "ZMIEN_GIETARKE" (pNK_ZLEC NUMBER, pNR_POZ NUMBER, pNK_INST NUMBER, pNK_ZM NUMBER DEFAULT null)
AS
  vNrCiagu NUMBER(2);
  vNkInstLIS NUMBER(6);
BEGIN
   NULL;
END ZMIEN_GIETARKE;
/
---------------------------
--New PROCEDURE
--ZLEC_NADRZEDNE
---------------------------
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
 -- jesli podany NR_KOM_SZYBY sprawdzenie danych w SPISE
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
 
 --wyjscie gdy zlecnie nieWEWNETRZNE
 IF vWyr<>'W' THEN RETURN; END IF;
 
 --ZLEC_POLP - sprawdzenie numeru komp. zlecenia nadrzednego
 SELECT count(1) into vNr FROM zlec_polp WHERE nr_zlec_wew=vNR_ZLEC_WEW;
 IF vNr is null or vNr=0 THEN
  RAISE EX_BRAK_POLP;
 END IF; 
 SELECT DISTINCT zlec_polp.nr_komp_zlec INTO pNK_ZLEC
 FROM zlec_polp WHERE nr_zlec_wew=vNR_ZLEC_WEW;

-- wyjscie gdy brak dod. informacji 
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
 --zalozenie ze NR_SZT taki sam
 pNR_SZT:=Greatest(pNR_SZT_WEW,vNR_SZT_WEW);

EXCEPTION
 WHEN EX_BRAK_POLP THEN RAISE_APPLICATION_ERROR(-20001,'ZLECENIE '||vNR_ZLEC_WEW||'- NIE MA POWIAZANIA ZE ZLECENIEM NADRZEDNYM');
 WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20002,'ZLECENIE '||vNR_ZLEC_WEW||'- BRAKI NA LISCIE WYCINKÓW DLA LISTY '||pLISTA);
 WHEN OTHERS THEN RAISE_APPLICATION_ERROR(-20099,'NIEKRESLONY BLAD');
END ZLEC_NADRZEDNE;
/
---------------------------
--New PROCEDURE
--ZAPISZ_ZLEC_ZM
---------------------------
CREATE OR REPLACE PROCEDURE "ZAPISZ_ZLEC_ZM" (pNK_ZLEC NUMBER, pTYP CHAR, pOPIS VARCHAR2, pNK_ZM IN OUT NUMBER)
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
---------------------------
--New PROCEDURE
--ZAPISZ_WYKZAL
---------------------------
CREATE OR REPLACE PROCEDURE "ZAPISZ_WYKZAL" (pNK_ZLEC IN NUMBER, pINST IN NUMBER DEFAULT 0, pPOZ IN NUMBER DEFAULT 0)
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
---------------------------
--New PROCEDURE
--ZAPISZ_WSP
---------------------------
CREATE OR REPLACE PROCEDURE "ZAPISZ_WSP" (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pNR_ZEST NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0)
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
         --jezeli wywolanie zapisu wsp. dla pNR_ZEST>0 to wyliczanie wsp. przy uzyciu funkcji WSP_WG_TYPU_INST i WSP_12ZAKR dla tego numeru zestawu
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
         --jezeli wywolanie zapisu wsp. dla pNR_ZEST>0 to wyliczanie wsp. przy uzyciu funkcji WSP_WG_TYPU_INST i WSP_12ZAKR dla tego numeru zestawu
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
---------------------------
--New PROCEDURE
--ZAPISZ_SPISP
---------------------------
CREATE OR REPLACE PROCEDURE "ZAPISZ_SPISP" (pNK_ZLEC IN NUMBER, pINST IN NUMBER DEFAULT 0, pPOZ IN NUMBER DEFAULT 0)
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
---------------------------
--New PROCEDURE
--ZAPISZ_LWYC
---------------------------
CREATE OR REPLACE PROCEDURE "ZAPISZ_LWYC" (pNK_ZLEC IN NUMBER, pINST IN NUMBER DEFAULT 0, pPOZ IN NUMBER DEFAULT 0)
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
  SELECT L.nr_kom_zlec, L.nr_poz_zlec, L.nr_szt, L.nr_warst, S.indeks, decode(max(S.zn_war),'Pól','POL','Pol','POL','Str','POL',nvl(max(K.rodz_sur),' ')),
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
---------------------------
--New PROCEDURE
--ZAPISZ_LOGOWANIE
---------------------------
CREATE OR REPLACE PROCEDURE "ZAPISZ_LOGOWANIE" (pOper IN VARCHAR2, pProgName IN VARCHAR2 DEFAULT ' ', pProgVer IN VARCHAR2 DEFAULT ' ')
AS
 vOper VARCHAR2(10);
 vProgName VARCHAR2(50);
 vProgVer VARCHAR2(50);
 vSID NUMBER:=0;
 vData DATE;
 vCZAS CHAR(6);
 vJest NUMBER(1);
begin
 IF pOper is null THEN vOper:=' '; ELSE vOper:=substr(pOper,1,10); END IF;
 
 SELECT nvl(SYS_CONTEXT('USERENV','SESSIONID'),' '), nvl(SYS_CONTEXT('USERENV','MODULE'),' '),
        trunc(SYSDATE), to_char(SYSDATE,'HH24MISS')
   INTO vSID, vProgName, vData, vCzas
   FROM DUAL;
 SELECT count(1) INTO vJest FROM logowania
   WHERE session_ID=vSID and operator_ID=vOper and data=vData;
 IF vJest<>0 THEN RETURN; END IF;
 IF pProgVer is null THEN vProgVer:=' '; ELSE vProgVer:=pProgVer; END IF;
 IF vProgName is null THEN vProgName:=' '; END IF;
 IF pProgName is null OR pProgName=' ' THEN vProgName:=substr(vProgName,1,50);
                                       ELSE vProgName:=substr(pProgName,1,50);
 END IF;
 
 INSERT INTO logowania (session_ID, host, os_user, prog_name, prog_ver, operator_id, data, czas)
        VALUES (vSID,
                substr(nvl(SYS_CONTEXT('USERENV','HOST'),' '),1,50),
                substr(nvl(SYS_CONTEXT('USERENV','OS_USER'),' '),1,50),
                vProgName, vProgVer, vOper, vData, vCzas);

END ZAPISZ_LOGOWANIE;
/
---------------------------
--New PROCEDURE
--ZAPISZ_LOG
---------------------------
CREATE OR REPLACE PROCEDURE "ZAPISZ_LOG" (pTab VARCHAR2, pNr_komp_dok NUMBER, pFl_op CHAR, pDO_SYNCH NUMBER DEFAULT 0) AS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  INSERT INTO log_zm (tab, nr_komp, fl_op, do_synch)
               VALUES (substr(pTab,1,30), pNr_komp_dok, pFl_op, pDO_SYNCH);
  COMMIT;
END ZAPISZ_LOG;
/
---------------------------
--New PROCEDURE
--ZAPISZ_HARMON
---------------------------
CREATE OR REPLACE PROCEDURE "ZAPISZ_HARMON" (pNK_ZLEC IN NUMBER, pINST IN NUMBER DEFAULT 0)
AS
BEGIN
  --DELETE FROM harmon WHERE nr_komp_zlec=pNK_ZLEC and pINST in (0,nr_komp_inst);
  INSERT INTO harmon (nr_komp_zlec, typ_harm, nr_oddz, rok, mies,  
                     nr_komp_inst, nr_inst, typ_inst, nr_komp_zm, dzien, zmiana,
                     ilosc, wielkosc, il_z_zam, dane_z_zam,
                     zatwierdz, spad, godz_pocz, godz_kon, kol_na_zm)--, awaria)
   SELECT V.nr_kom_zlec, 'P', (select nr_odz from firma), to_number(to_char(PKG_CZAS.NR_ZM_TO_DATE(V.nr_zm_plan),'YYYY'),'9999'), to_number(to_char(PKG_CZAS.NR_ZM_TO_DATE(V.nr_zm_plan),'MM'),'99'),
          V.nr_inst_plan, max(I.nr_inst), max(substr(I.ty_inst,1,3)), V.nr_zm_plan, PKG_CZAS.NR_ZM_TO_DATE(V.nr_zm_plan), PKG_CZAS.NR_ZM_TO_ZM(V.nr_zm_plan),
          --count(decode(symb_obr,'DECOAT',null,1)), sum(V.il_obr*V.wsp_p), round(sum(V.wsp_p)), sum(V.il_obr),
          count(nullif(V.obr_jednocz,1)), sum(V.il_obr*V.wsp_p), round(sum(decode(V.obr_jednocz,1,0,1)*V.il_obr*V.wsp_p/V.il_obr)), sum(V.il_obr), --IL_Z_ZAM <- Ilosc sztuk przelicz.
          0, 0, '000000', '000000', 0   --,decode(max(V.zakl_kol_pop+V.zakl_kol_nast),0,0,3)
   FROM v_wyc2 V
--   LEFT JOIN spisz P ON P.nr_kom_zlec=V.nr_kom_zlec and P.nr_poz=V.nr_poz_zlec       
--   LEFT JOIN slparob O ON O.nr_k_p_obr=V.nr_obr
   LEFT JOIN parinst I ON I.nr_komp_inst=V.nr_inst_plan
--   LEFT JOIN kat_gr_plan G ON G.typ_kat=V.indeks AND G.nkomp_instalacji=V.nr_inst_plan
   WHERE V.nr_kom_zlec=pNK_ZLEC and V.nr_zm_plan>0 and pINST in (0,V.nr_inst_plan)
     AND V.il_obr>0
   GROUP BY V.nr_kom_zlec, V.nr_inst_plan, V.nr_zm_plan;
EXCEPTION WHEN OTHERS THEN
 ZAPISZ_LOG('ZAPISZ_HARMON',pNK_ZLEC,'C',0);
 ZAPISZ_ERR(SQLERRM);
 RAISE;
END ZAPISZ_HARMON;
/
---------------------------
--New PROCEDURE
--ZAPISZ_ERR
---------------------------
CREATE OR REPLACE PROCEDURE "ZAPISZ_ERR" (pMESSAGE VARCHAR2) as
  PRAGMA AUTONOMOUS_TRANSACTION;
begin
  insert into errors (message) values (substr(pMESSAGE,1,500));
  commit;
end;
/
---------------------------
--New PROCEDURE
--ZAMKNIJ_STOJAKI
---------------------------
CREATE OR REPLACE PROCEDURE "ZAMKNIJ_STOJAKI" 
( pNR_INST IN NUMBER, pNR_KOMP_ZM IN NUMBER
) AS 
  CURSOR c1 IS
            SELECT DISTINCT nr_stoj
            FROM l_wyc
            WHERE zn_stoj=0 AND nr_stoj>0
              AND (pNR_INST=0 or nr_inst=pNR_INST)
              AND (pNR_KOMP_ZM=0 or PKG_CZAS.NR_KOMP_ZM(d_wyk,zm_wyk)=pNR_KOMP_ZM);
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
---------------------------
--New PROCEDURE
--ZAMKNIJ_STOJAK
---------------------------
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
---------------------------
--New PROCEDURE
--WPISZ_INST_LWYC2
---------------------------
CREATE OR REPLACE PROCEDURE "WPISZ_INST_LWYC2" (pNK_ZLEC NUMBER, pNR_POZ NUMBER, pNR_PORZ NUMBER, pNR_SZT NUMBER, pNK_INST NUMBER, pNK_INST_POW NUMBER, pNK_ZM NUMBER default null)
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

 IF vNrObr=99 THEN -- gdy MON to automatyczna aktualizacja gietarek
  NULL;--ZMIEN_GIETARKE (pNK_ZLEC, pNR_POZ, pNK_INST, pNK_ZM);
 END IF;
END WPISZ_INST_LWYC2;
/
---------------------------
--New PROCEDURE
--USUN_PLAN
---------------------------
CREATE OR REPLACE PROCEDURE "USUN_PLAN" (pNK_ZLEC IN NUMBER, pINST IN NUMBER DEFAULT 0, pPOZ IN NUMBER DEFAULT 0, pPRZYWROC_LWYC2 IN NUMBER DEFAULT 0, pZAKR_INST IN NUMBER DEFAULT 0)
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
---------------------------
--New PROCEDURE
--USTAW_WSP
---------------------------
CREATE OR REPLACE PROCEDURE "USTAW_WSP" (pNK_ZLEC NUMBER, pNK_OBR NUMBER DEFAULT 0)
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
---------------------------
--New PROCEDURE
--USTAW_INST
---------------------------
CREATE OR REPLACE PROCEDURE "USTAW_INST" (pNK_ZLEC NUMBER, pNR_POZ NUMBER, pNR_PORZ NUMBER, pNK_OBR NUMBER, pNK_INST NUMBER, pNK_INST_POW NUMBER DEFAULT null, pNK_ZM NUMBER DEFAULT null)
AS
 vInstPow NUMBER(10):=pNK_INST_POW;
  vNrCiagu NUMBER(2);
  vNkInstLIS NUMBER(6);
BEGIN
  IF pNK_INST_POW is null THEN
   SELECT nr_inst_pow INTO vInstPow FROM parinst WHERE nr_komp_inst=pNK_INST;
  END IF;
  IF pNK_ZLEC*pNR_POZ*pNR_PORZ>0 THEN
   --ustawienie w kolumnie JAKI informacji, ktora instalacja wybrana (ewentualnei ktora powiazana do wybranej)
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
  END IF;
END USTAW_INST;
/
---------------------------
--New PROCEDURE
--USTAL_INST
---------------------------
CREATE OR REPLACE PROCEDURE "USTAL_INST" (pZRODLO CHAR, pNK_ZLEC NUMBER, pNR_POZ NUMBER DEFAULT 0, pNK_OBR NUMBER DEFAULT 0)
AS
 CURSOR c1 IS
  SELECT V.nr_poz, V.nr_porz, V.nk_inst, V.inst_std, V.nr_inst_pow, --V.wsp_przel         
         kryt_wym_max, kryt_grub_pak, kryt_waga_pak, kryt_waga_1mb, kryt_waga_elem,
         kryt_wym_min, kryt_atryb_wyl, V.kryt_atryb, V.kryt_suma, V.obsl_tech
  FROM v_spiss V
  WHERE V.zrodlo=pZRODLO and V.nr_kom_zlec=pNK_ZLEC and pNR_POZ in (0,V.nr_poz) and pNK_OBR in (0,V.nk_obr) and V.gr_akt<2
  ORDER BY V.zrodlo, V.nr_kom_zlec, V.nr_poz, V.nr_porz, decode(V.nk_inst,V.inst_std,1,2), V.kolejnosc_z_grupy;   

 CURSOR c2 (pINST NUMBER, pPOZ NUMBER, pPORZ NUMBER, pKRYT_ATR NUMBER, pKRYT_MAX NUMBER, pKRYT_MIN NUMBER)  IS
  SELECT V.nk_inst, V.nr_inst_pow --, kryt_suma, I.nr_inst_max, I.nr_inst_min, I.nr_inst_wyl
  FROM v_spiss V
  INNER JOIN parinst I on I.nr_komp_inst=pINST
  WHERE V.zrodlo=pZRODLO and V.nr_kom_zlec=pNK_ZLEC and V.nr_poz=pPOZ and V.nr_porz=pPORZ and V.gr_akt<2
  AND (pKRYT_ATR=1 and V.nk_inst=I.nr_inst_wyl OR
       pKRYT_MAX=1 and V.nk_inst=I.nr_inst_max OR
       pKRYT_MIN=1 and V.nk_inst=I.nr_inst_min)
  AND V.kryt_suma=0
  ORDER BY decode(V.nk_inst,I.nr_inst_wyl,1,I.nr_inst_max,2,I.nr_inst_min,3,9);

  rec1 c1%ROWTYPE;
  currPoz NUMBER(4):=0;
  currObr NUMBER(4):=0;
  vObrOK BOOLEAN:=false;
  vInstOK BOOLEAN:=false;
  vNieSzukajDalej BOOLEAN;
  vInstAlternatywna NUMBER(10);
BEGIN
  OPEN c1;
  LOOP
    FETCH c1 INTO rec1;
    EXIT WHEN c1%NOTFOUND;
    vInstOK:=rec1.kryt_suma=0 or rec1.obsl_tech=1;
    --NOWA POZYCJA LUB OBRÓBKA
    IF currPoz<>rec1.nr_poz or currObr<>rec1.nr_porz THEN      
      --jezeli wybrana inst (INST_STD) jest OK to nie trzeba nic zmieniac
      vObrOK:=rec1.nk_inst=rec1.inst_std and vInstOK;
      currPoz:=rec1.nr_poz;
      currObr:=rec1.nr_porz;
      vNieSzukajDalej:=rec1.kryt_atryb=1 and vObrOK; --kryt_atryb: 1 atrybut pasujacy   2 pusty atrybut kierujacy na inst
      USTAW_INST(pNK_ZLEC,rec1.nr_poz,rec1.nr_porz,0,rec1.nk_inst,rec1.nr_inst_pow);
    END IF;
    --sprawdzanie pozostalych instalacji
    IF vInstOK AND (not vObrOK and rec1.kryt_atryb in (1,2) --1 atrybut pasujacy   2 pusty atrybut kierujacy na inst
                    or not vNieSzukajDalej and rec1.kryt_atryb=1) THEN  --wybrana tylko pierwsza instalacja z atrybutem kierujacym
      vObrOK := true;
      vNieSzukajDalej:=rec1.kryt_atryb=1;
      USTAW_INST(pNK_ZLEC,rec1.nr_poz,rec1.nr_porz,0,rec1.nk_inst,rec1.nr_inst_pow);
    --czy jest przekierowanie w PARINST
    ELSIF not vInstOK AND not vObrOK AND greatest(rec1.kryt_atryb_wyl,rec1.kryt_wym_min,rec1.kryt_wym_max,rec1.kryt_grub_pak,rec1.kryt_waga_pak,rec1.kryt_waga_1mb,rec1.kryt_waga_elem)>0 THEN
     OPEN c2 (rec1.nk_inst, rec1.nr_poz, rec1.nr_porz, rec1.kryt_atryb_wyl, sign(rec1.kryt_wym_max+rec1.kryt_grub_pak+rec1.kryt_waga_pak+rec1.kryt_waga_1mb+rec1.kryt_waga_elem), rec1.kryt_wym_min);
     LOOP
      FETCH c2 INTO vInstAlternatywna, rec1.nr_inst_pow;
      EXIT WHEN c2%NOTFOUND;
      IF vInstAlternatywna>0 THEN 
       vObrOK := true;
       vNieSzukajDalej:=true;
       USTAW_INST(pNK_ZLEC,rec1.nr_poz,rec1.nr_porz,0,vInstAlternatywna,rec1.nr_inst_pow);
       EXIT; --wazny tylko 1. rekord
      END IF;
     END LOOP;
     CLOSE c2;     
    END IF;
  END LOOP;
  CLOSE c1;

  IF pNK_OBR=0 THEN 
   --zmien instalacje wg GR_INST_POW (wg inst MON)
   PKG_PLAN_SPISS.WPISZ_INST_WG_CIAGU(pNK_ZLEC,pNR_POZ);
   --popraw ilosc wpisow dla instalacji powiazanych
   PKG_PLAN_SPISS.LWYC2_INST_POW(pNK_ZLEC,pNR_POZ);
   --popraw instalacje dla obrobek jednoczesnych
   PKG_PLAN_SPISS.POPRAW_OBR_JEDNOCZ(pNK_ZLEC,pNR_POZ,0);
  ELSE
   PKG_PLAN_SPISS.WPISZ_INST_WG_CIAGU(pNK_ZLEC,pNR_POZ,trim(to_char(pNK_OBR)));
   PKG_PLAN_SPISS.LWYC2_INST_POW(pNK_ZLEC,pNR_POZ,to_char(pNK_OBR));
   FOR v IN (select distinct nr_obr_jednocz from v_obr_jednocz where nr_komp_obr=pNK_OBR) LOOP
    PKG_PLAN_SPISS.POPRAW_OBR_JEDNOCZ(pNK_ZLEC,pNR_POZ,v.nr_obr_jednocz);
    --raise invalid_number;
    --USTAW_WSP(pNK_ZLEC, v.nr_komp_obr);
   END LOOP;
  END IF;
END USTAL_INST;
/
---------------------------
--New PROCEDURE
--UPDATE_WYCINKI_FROM_LWYC
---------------------------
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
---------------------------
--New PROCEDURE
--UPDATE_ECUTTER_SPISE_POZ
---------------------------
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
---------------------------
--New PROCEDURE
--UPDATE_ECUTTER_SPISE_KON
---------------------------
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
---------------------------
--New PROCEDURE
--SPISS_MAT
---------------------------
CREATE OR REPLACE PROCEDURE "SPISS_MAT" (pZRODLO CHAR, pZ NUMBER)
AS
 vLAM NUMBER(1);
 vLACZ NUMBER(1);
 vETAP_MAX NUMBER(2);
BEGIN
 --DELETE FROM SPISS_STR_TMP WHERE nr_kom_zlec=pZ;
 --INSERT INTO SPISS_STR_TMP
  --SELECT * FROM spiss_str where nr_kom_zlec=pZ;

 DELETE FROM SPISS_TMP WHERE zrodlo=pZRODLO and nr_komp_zr=pZ; 
 INSERT INTO SPISS_TMP
  SELECT * FROM SPISS_V WHERE zrodlo=pZRODLO AND nr_komp_zr=pZ;
 --renumeracja ETAPów i NR_PORZ
 FOR P IN (select nr_poz from spisz where nr_kom_zlec=pZ) LOOP
  --ETAP=-1 to dodatkowy etap laczeniowy (np. GTE szyba ogniochronna)
  SELECT max(case when etap=2 then 1 else 0 end),
         max(case when etap=-1 then 1 else 0 end),
         max(etap)
    INTO vLAM, vLACZ, vETAP_MAX
  FROM spiss
  WHERE zrodlo=pZRODLO and nr_komp_zr=pZ and nr_kol=P.nr_poz and czy_war=1 and strona=0 and etap<9;
  --jesli nie ma laminatu to szyba ogniochronna zapisana jako ETAP 2
  IF vLAM=0 and vLACZ>0 THEN 
  UPDATE spiss SET etap=2 WHERE zrodlo=pZRODLO and nr_komp_zr=pZ and nr_kol=P.nr_poz and etap=-1;
  vETAP_MAX:=greatest(vETAP_MAX,2);
   --jesli i laminat i ogniochronna to laminowanie jako ETAP 2, ogniochronna jako 4, zespalanie jako 5
  ELSIF vLAM>0 and vLACZ>0 THEN
   UPDATE spiss SET etap=5, nr_porz=nr_porz+200 WHERE zrodlo=pZRODLO and nr_komp_zr=pZ and nr_kol=P.nr_poz and etap=3;
   UPDATE spiss SET etap=4, nr_porz=nr_porz+200 WHERE zrodlo=pZRODLO and nr_komp_zr=pZ and nr_kol=P.nr_poz and etap=-1;
   --vETAP_MAX:=greatest(vETAP_MAX,4);
   SELECT max(etap) INTO vETAP_MAX
   FROM spiss
   WHERE zrodlo=pZRODLO and nr_komp_zr=pZ and nr_kol=P.nr_poz and czy_war=1 and strona=0 and etap<9;
   --ponizszy UPDATE niepotzrebny bo wartosci poprawne wyliczane w SPISS_VLACZ
   --UPDATE spiss S 
   --SET (war_od, war_do, indeks)=
   --    (select nvl(max(least(S.war_od,S1.war_od)),S.war_od) war_od, nvl(max(greatest(S.war_do,S1.war_do)),S.war_do) war_do,
   --            nvl(max(kod_laminatu(S.nr_kom_str,least(S.war_od,S1.war_od),greatest(S.war_do,S1.war_do))),S.indeks)
   --     from spiss S1
   --     where S1.zrodlo=S.zrodlo and S1.nr_komp_zr=S.nr_komp_zr and S1.nr_kol=S.nr_kol and S1.etap=2 and S1.strona=4 and (S1.war_od between S.war_od and S.war_do or S1.war_do between S.war_od and S.war_do))
   --WHERE zrodlo=pZRODLO and nr_komp_zr=pZ and nr_kol=P.nr_poz and etap=4;
  END IF;
  UPDATE spiss
  SET etap=vETAP_MAX, nr_porz=vETAP_MAX*100+(100-rownum)
  WHERE zrodlo=pZRODLO and nr_komp_zr=pZ and nr_kol=P.nr_poz and etap=9;
 END LOOP; 
 --nieplanowanie obrobek, ze wzgledu na atrybut wykluczajacy i brak instalacji alternatywnej
 --LUB wprowadzonych na warstwie bedacej polproduktem
 UPDATE spiss_tmp A
 SET zn_plan=0
 WHERE zrodlo=pZRODLO AND nr_komp_zr=pZ and zn_plan>0
   AND (ATRYB_MATCH((select nvl(min(ident_bud_wyl),'0') from parinst where nr_komp_inst=A.inst_std and nr_inst_wyl=0),
                   (select ident_bud from spiss_tmp S where zrodlo=pZRODLO AND nr_komp_zr=pZ and S.nr_kol=A.nr_kol and S.etap=A.etap and S.czy_war=1 and S.war_od=A.war_od and S.strona=4)
                   )=1
        OR etap=1 and rodz_sur='POL' and zn_war='Obr' and nr_porz>100);
 UPDATE SPISS_TMP A
 SET str_dod=(select listagg(nk_obr,',') within group (order by zn_plan)
              from spiss_tmp S
              where S.zrodlo=A.zrodlo and S.nr_komp_zr=A.nr_komp_zr and S.nr_kol=A.nr_kol
                and S.etap>=A.etap and A.war_od between S.war_od and S.war_do and S.zn_plan>0)
 WHERE zrodlo=pZRODLO AND nr_komp_zr=pZ and czy_war=1;

 INSERT INTO SPISS_TMP
  SELECT * FROM SPISS_V_WE WHERE zrodlo=pZRODLO AND nr_komp_zr=pZ;
--  SELECT * FROM spiss_v1 where nr_komp_zr=pZ
--  UNION
--  SELECT * FROM spiss_v2 where nr_komp_zr=pZ
--  UNION
--  SELECT * FROM spiss_v3 where nr_komp_zr=pZ;
END;
/
---------------------------
--New PROCEDURE
--PRZYPISZ_WZ_W_SPISE
---------------------------
CREATE OR REPLACE PROCEDURE "PRZYPISZ_WZ_W_SPISE" (pNR_KOMP_ZLEC IN NUMBER, pNR_POZ IN NUMBER DEFAULT 0)
AS
  CURSOR cWZ (pZLEC NUMBER, pPOZ NUMBER)
   IS SELECT * FROM pozdok
      WHERE typ_dok in ('WP','WZ') and nr_komp_baz=pZLEC and nr_poz_zlec=pPOZ and storno=0 and kol_dod=0
        AND NOT EXISTS (select 1 from spise where nr_komp_zlec=pZLEC and nr_poz=pPOZ and nr_k_WZ=pozdok.nr_komp_dok and nr_poz_WZ=pozdok.nr_poz)
      ORDER BY nr_dok_zrod, nr_komp_dok, nr_poz;

  CURSOR cE (pZLEC NUMBER, pPOZ NUMBER, pDATA_WZ DATE DEFAULT '01/01/01')
   --IS select nr_komp_zlec, nr_poz, nr_sped, max(data_sped) data_sped, max(sign(nr_k_WZ*nr_poz_WZ)) wpisWZ, count(1) il
   IS SELECT * FROM spise
      WHERE nr_komp_zlec=pZLEC and nr_poz=pPOZ and nr_k_WZ=0
        and (pDATA_WZ='01/01/01' or nr_sped>0 and data_sped=pDATA_WZ)
      --ORDER BY data_wyk, zm_wyk, nr_sped
      ORDER BY sign(nr_sped) desc, data_wyk, zm_wyk, data_sped, nr_sped, d_wyk, t_wyk, nr_szt
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
    --KROK 1: szukanie spedycji z identyczna data niz data WZ i ta sama iloscia
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
    --KROK 2 : szukanie spedycji z odpowiednia iloscia sztuk
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
     --cofniecie przypisaniea jezeli nie znaleziono tylu szyb ile jest w WZ
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
---------------------------
--New PROCEDURE
--PORZADKUJ_ZMIANY_I_KALINST
---------------------------
CREATE OR REPLACE PROCEDURE "PORZADKUJ_ZMIANY_I_KALINST" (pNK_ZLEC NUMBER, pNK_INST NUMBER)
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
---------------------------
--New PROCEDURE
--OPT_TO_KOL_STOJAKOW
---------------------------
CREATE OR REPLACE PROCEDURE "OPT_TO_KOL_STOJAKOW" (pNK_ZLEC NUMBER, pNR_KAT NUMBER DEFAULT 0)
AS
 cursor k1 (pPOZ NUMBER, pKAT NUMBER, pOPT NUMBER, pTAF NUMBER) IS 
  SELECT * FROM kol_stojakow
  WHERE nr_komp_zlec=pNK_ZLEC and nr_poz=pPOZ and nr_katalog=pKAT and nr_optym<=0
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
    END LOOP; --koniec petli po KOL_STOJAKOW 
    CLOSE k1;
   --END IF;
  END LOOP;
END OPT_TO_KOL_STOJAKOW;
/
---------------------------
--New PROCEDURE
--NEXTSERIALNUMBER
---------------------------
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
   INSERT INTO konfig_t (nr_par, ost_nr, opis)
               VALUES (cNUMER_PARAMETRU, vMaxSpise+pIle, cNAZWA_PARAMETRU);
   pOstPrzedRez := vMaxSpise;
   pSukces := 1;
  END IF;
  CLOSE C1;
  COMMIT;

END NEXTSERIALNUMBER;
/
---------------------------
--New PROCEDURE
--LWYC2_WG_PLAN_OLD
---------------------------
CREATE OR REPLACE PROCEDURE "LWYC2_WG_PLAN_OLD" (pFUN IN NUMBER, pNK_ZLEC IN NUMBER)
AS 
 CURSOR c1 IS
 SELECT DISTINCT nr_kom_zlec, nr_poz_zlec, indeks, nr_warst, nr_kat_obr, ile_rodz_obr, nr_obr, zn_plan, nr_kat,--DISTINCT dla zabezpieczenia przed "podwojeniem" rekordów np. przez link do W1
                 nr_inst_plan, nr_zm_plan, il_wpisow, il_szt, inst_plan_old, nr_zm_old, il_plan_old, src, I.ty_inst typ_inst--, I.naz_inst
 FROM
 (Select V.nr_kom_zlec, V.nr_poz_zlec, V.indeks, V.nr_warst, V.nr_kat_obr, V.ile_rodz_obr, V.nr_obr, V.zn_plan, V.nr_kat,
         V.nr_inst_plan, V.nr_zm_plan, V.il_wpisow, V.il_szt,
        --ta linia bo chcemy zaplanowac obr=15 (zatepianie) na instalacji powiazanej do hartowania
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
  --podzapytanie zwracajace z L_WYC2 dane pogrupowane na  obrobki (wczesniej czynnosci) i zmiany (na warstwie), ewentualnie A C i R C dla obr 90,91
  (select L2.nr_kom_zlec, L2.nr_poz_zlec, max(S.indeks) indeks, L2.nr_warst, max(decode(S.zn_war,'Obr',S.nr_kat_obr,nvl(O.nr_kat_obr,0))) nr_kat_obr, max(S.nr_kat) nr_kat,
          max(O.nr_komp_inst) nk_inst_dla_obr, max(sign(L2.nr_porz_obr-S.nr_porz)) inst_pow, --jesli rozne to 1 co oznacza inst powiazana
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
                    and (W.nr_warst=V.nr_warst or V.nr_obr=94 and V.nr_warst between W.nr_warst and W.straty) --@V Szprosy maja zapisany NR_WARST, dodatkowo planowanie LAM_P
                    and V.nr_obr not in (99) --Zesp
                    and (   W.nr_komp_obr>0 and W.nr_komp_obr in (V.nr_obr,V.nr_kat_obr)
                         --or W.nr_komp_obr=0 and W.nr_kat=V.nr_kat_obr and W.nr_kat>0 @P
                         --or W.nr_komp_obr=0 and W.nr_kat=V.nr_kat     and W.nr_kat>0 @P
                         or W.nr_komp_obr=0 and V.ile_rodz_obr=1 and V.nr_obr in (93,94,95) and W.nr_komp_instal=V.nk_inst_dla_obr --SZP, LAM i LAM_P (instalacja domyslna dla obróbki)
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
  --dla Zatepiania (jesli nie znalaz w W) szukanie inst. powiazanej do Hart @P
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
 ORDER BY nr_kom_zlec, zn_plan, nr_kat_obr, decode(src,'W',1,'W2',2,'W1',3,'P',4,'H',5,9), --rekordy z Harm na koncu, zeby nie podbierac danych z W1
          nr_poz_zlec, nr_warst, decode(nr_zm_plan,0,9999999,nr_zm_plan), nr_inst_plan; --DECODE bo jesli pozycja podzielona w L_WYC2, to najpierw wpisane zmiany

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
---------------------------
--New PROCEDURE
--LWYC2_SAVE
---------------------------
CREATE OR REPLACE PROCEDURE "LWYC2_SAVE" (pNR_KOM_ZLEC IN NUMBER, pNR_POZ IN NUMBER, pWAR IN NUMBER, pWAR_DO IN NUMBER, pIL_SZT IN NUMBER,
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
---------------------------
--New PROCEDURE
--GEN_LWYC_OBR
---------------------------
CREATE OR REPLACE PROCEDURE "GEN_LWYC_OBR" (pFUN IN NUMBER, pNR_KOM_ZLEC IN NUMBER, pNR_POZ NUMBER DEFAULT 0, pSKIP_ERR NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0)
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
    AND S.nk_obr=pNR_OBR
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
  vINST NUMBER;
BEGIN
 SELECT count(1) INTO jestHARMON FROM dual WHERE exists (select 1 from harmon where nr_komp_zlec=pNR_KOM_ZLEC);
/*
 IF jestHARMON=0 THEN
  DELETE FROM l_wyc WHERE nr_kom_zlec=pNR_KOM_ZLEC and pNR_POZ in (0,nr_poz_zlec) and nr_inst_wyk=0;
 END IF;
 DELETE FROM l_wyc2 WHERE nr_kom_zlec=pNR_KOM_ZLEC  and pNR_POZ in (0,nr_poz_zlec);
 DELETE FROM wsp_alter WHERE nr_kom_zlec=pNR_KOM_ZLEC and pNR_POZ in (0,nr_poz);
*/
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
    vINST:=recO.inst_std;
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
    ZAPISZ_WSP(pNR_KOM_ZLEC, recP.nr_poz, -1, pNR_OBR);  -- -1 wszystkie zestawy
    /*
    USTAL_INST('Z', pNR_KOM_ZLEC, recP.nr_poz);
    IF jestHARMON=0 THEN
     ZAPISZ_LWYC(pNR_KOM_ZLEC, 0, recP.nr_poz);
    END IF;
    */
    ZAPISZ_LWYC(pNR_KOM_ZLEC, vINST, recP.nr_poz);
  END IF;  
 END LOOP;
 CLOSE cP;
 IF pNR_POZ=0 THEN 
   ZAPISZ_WSP(pNR_KOM_ZLEC, 0, -1, pNR_OBR);
   USTAL_INST('Z', pNR_KOM_ZLEC, 0, pNR_OBR);
   /*
   IF jestHARMON=0 THEN
    ZAPISZ_LWYC(pNR_KOM_ZLEC, 0, 0);
   END IF; 
   */
   DELETE FROM l_WYC WHERE nr_kom_zlec=pNR_KOM_ZLEC and nr_inst=vINST and nr_inst_wyk=0;
   ZAPISZ_LWYC(pNR_KOM_ZLEC, vINST, 0);
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
 ZAPISZ_LOG('GEN_LWYC_OBR',pNR_KOM_ZLEC,'C',0);

EXCEPTION WHEN OTHERS THEN
 IF cP%ISOPEN THEN CLOSE cP; END IF;
 IF c1%ISOPEN THEN CLOSE c1; END IF;
 IF c2%ISOPEN THEN CLOSE c2; END IF;
 --IF c3%ISOPEN THEN CLOSE c3; END IF;
 IF c4%ISOPEN THEN CLOSE c4; END IF;
 dbms_output.put_line(dbms_utility.FORMAT_ERROR_BACKTRACE);
 dbms_output.put_line(SQLERRM);
 ZAPISZ_LOG('GEN_LWYC_OBR',pNR_KOM_ZLEC,'E',0);
 ZAPISZ_ERR(SQLERRM);
 IF pSKIP_ERR=0 THEN
  ROLLBACK;
  RAISE;
 END IF;
END GEN_LWYC_OBR;
/
---------------------------
--New PROCEDURE
--GEN_LWYC
---------------------------
CREATE OR REPLACE PROCEDURE "GEN_LWYC" (pFUN IN NUMBER, pNR_KOM_ZLEC IN NUMBER, pNR_POZ NUMBER DEFAULT 0, pSKIP_ERR NUMBER DEFAULT 0)
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
--  SELECT S.indeks, L.nr_kom_zlec, L.nr_poz_zlec, L.nr_szt, L.nr_warst, L.nr_inst_plan, max(L.kolejn) kolejn, decode(max(S.zn_war),'Pól','Pól','Str','Pól',max(K.rodz_sur)) rodz_sur,
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
 --ciag prod. (dla calej Poz.)
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
  par152 NUMBER(1);
BEGIN
 par152:=GET_PARAM_T(152,0);
 SELECT count(1) INTO jestHARMON FROM dual WHERE exists (select 1 from harmon where nr_komp_zlec=pNR_KOM_ZLEC);
 IF par152>1 AND jestHARMON=0 THEN
  DELETE FROM l_wyc WHERE nr_kom_zlec=pNR_KOM_ZLEC and pNR_POZ in (0,nr_poz_zlec) and nr_inst_wyk=0;
 END IF;
 DELETE FROM l_wyc2 WHERE nr_kom_zlec=pNR_KOM_ZLEC  and pNR_POZ in (0,nr_poz_zlec);
 DELETE FROM wsp_alter WHERE nr_kom_zlec=pNR_KOM_ZLEC and pNR_POZ in (0,nr_poz) and nr_porz_obr>0;
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
    --WYLACZONE (przeniesione do SPISS_MAT) pominiecie ZAT gdy atrybut 19.Szlif (EFF)
    IF FALSE and recO.nk_obr=1 and recO.nr_porz<100 and substr(recW.ident_bud,19,1)='1' THEN
     CONTINUE;
    --WYLACZONE (przeniesione do SPISS_MAT) pominiecie obrobek ze SPISD jesli wprowadozne na póproducie (beda sie planowac w zlec. wew.)
    ELSIF FALSE and recW.etap=1 and recW.rodz_sur='POL' and recO.zn_war='Obr' and recO.nr_porz>100 THEN
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
   --zapis ciagu prod. (numery obróbek) na rekordzie warstwy etapu 1.
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
    IF par152>1 AND jestHARMON=0 THEN
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
   IF par152>1 AND jestHARMON=0 THEN
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
---------------------------
--New PROCEDURE
--CREATE_KOL_STOJAKOW
---------------------------
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
---------------------------
--New PROCEDURE
--AKTREZZLEC
---------------------------
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
---------------------------
--New PROCEDURE
--AKTREZSUR
---------------------------
CREATE OR REPLACE PROCEDURE "AKTREZSUR" (
    ZM_INDEXSUR IN VARCHAR2 DEFAULT '',
    ZM_NRMAG    IN NUMBER DEFAULT 0 )
AS
  CURSOR C1
  IS
    SELECT SUM( (IL_ZAD-rw_POB)/(1-0.01*DECODE(STRATY,100,50,STRATY)))
    FROM SURZAM
    WHERE (IL_ZAD-rw_POB)>0.05
    AND RODZ_SUR        <>'CZY'
    AND indeks           =ZM_INDEXSUR
    AND NR_MAG           =ZM_NRMAG
    AND NR_KOMP_ZLEC    IN
      (SELECT NR_KOM_ZLEC
      FROM ZAMOW
      WHERE TYP_ZLEC ='Pro'
      AND wyroznik  <>'O'
      AND forma_wprow='P'
      AND status     ='P'
      );
  -------------
  zm_rezerwacja kartoteka.rezeracja%TYPE;
  ------------
BEGIN
  OPEN C1;
  FETCH C1 INTO zm_rezerwacja;
  CLOSE c1;
  IF zm_rezerwacja>0 THEN
    UPDATE KARTOTEKA
    SET REZERACJA         =zm_rezerwacja
    WHERE KARTOTEKA.NR_MAG=ZM_NRMAG
    AND KARTOTEKA.INDEKS  =ZM_INDEXSUR;
  ELSE
    UPDATE KARTOTEKA
    SET REZERACJA         =0
    WHERE KARTOTEKA.NR_MAG=ZM_NRMAG
    AND KARTOTEKA.INDEKS  =ZM_INDEXSUR;
  END IF;
  COMMIT;
END;
/
---------------------------
--New PACKAGE
--PKG_TRANSFER_FILE
---------------------------
CREATE OR REPLACE PACKAGE "PKG_TRANSFER_FILE" AS 
function spacer_order_header(pDeviceId number, pNrKompZlec number) return varchar2;
function spacer_file_header(pDeviceId number) return varchar2;
function spacer_position(pDeviceId number, pNrKompZlec number, pNrPoz number, pNrSzt number, pNrWar number) return varchar2;
function get_text(pNrKompZlec number, pNrPoz number, pNrSzt number, pNrWar number) return varchar2;
END PKG_TRANSFER_FILE;
/
---------------------------
--New PACKAGE
--PKG_SPISW
---------------------------
CREATE OR REPLACE PACKAGE "PKG_SPISW" AS
 vSEP_STR CONSTANT CHAR(1) := '\';  --separator elementow w strukturze
 recPARINST parinst%ROWTYPE;
 recKAT   katalog%ROWTYPE;
 recSTR struktury%ROWTYPE;
 recZAMOW zamow%ROWTYPE;
 recSPISZ spisz%ROWTYPE;
 recSPISE spise%ROWTYPE;
 recSPISD spisd%ROWTYPE;
 recSPISW spisw%ROWTYPE;
 --recL_WYC l_wyc%ROWTYPE;
 recWYKZAL wykzal%ROWTYPE;
 recBRAKI_B braki_b%ROWTYPE;

 TYPE WSP_OBR_TYP  IS RECORD (nr_obr NUMBER(10), il_jedn NUMBER (8,4), wsp NUMBER (8,4));
 TYPE TAB_OBR IS TABLE OF WSP_OBR_TYP;

 --kursor po SPISZ
 CURSOR curSPISZ (pNR_KOM_ZLEC NUMBER, pNR_POZ NUMBER)
  IS SELECT * FROM spisz
  WHERE nr_kom_zlec=pNR_KOM_ZLEC AND (pNR_POZ=0 OR nr_poz=pNR_POZ);
 --kursor po SPISE
 CURSOR curSPISE (pNR_KOMP_ZLEC NUMBER, pNR_POZ NUMBER, pNR_SZT NUMBER)
  IS SELECT nr_kom_szyby FROM spise
  WHERE nr_komp_zlec=pNR_KOMP_ZLEC AND (pNR_POZ=0 or nr_poz=pNR_POZ) AND (pNR_SZT=0 or nr_szt=pNR_SZT);
 --kursory L_WYC
 CURSOR curL_WYC_1 (pNR_KOM_ZLEC NUMBER, pNR_POZ NUMBER, pNR_SZT NUMBER, pNR_WAR NUMBER, pNR_INST NUMBER)
  IS SELECT * FROM l_wyc
  WHERE nr_kom_zlec=pNR_KOM_ZLEC AND (pNR_POZ=0 or nr_poz_zlec=pNR_POZ) AND (pNR_SZT=0 or nr_szt=pNR_SZT)
    AND (pNR_WAR=0 or nr_warst=pNR_WAR) and (pNR_INST=0 or nr_inst=pNR_INST)
  ORDER BY nr_kom_zlec, nr_poz_zlec, nr_szt, nr_warst, kolejn DESC;
 --kursor WYKZAL
 CURSOR curWYKZAL_1 (pNR_KOMP_ZLEC NUMBER, pNR_POZ NUMBER, pNR_WAR NUMBER, pNR_KOMP_INST NUMBER)
  IS SELECT * FROM wykzal
  WHERE nr_komp_zlec=pNR_KOMP_ZLEC AND (pNR_POZ=0 or nr_poz=pNR_POZ)
    AND (pNR_WAR=0 or nr_warst=pNR_WAR or straty>nr_warst and pNR_WAR between nr_warst and straty) 
    AND (pNR_KOMP_INST=0 or nr_komp_instal=pNR_KOMP_INST)
  ORDER BY nr_komp_zlec, nr_komp_instal, nr_poz, nr_warst, nr_komp_obr;
 --kursor BRAKI_B 
 CURSOR curBRAKI_B_1 (pNR_KOM_SZYBY NUMBER)
  IS SELECT * FROM braki_b
  WHERE nr_kom_szyby=pNR_KOM_SZYBY AND ZLEC_BRAKI>0 AND ID_POZ_BR>0
  ORDER BY zlec_braki, id_poz_br;  
  
 --kursor przeliczanych szyb (uzyty w proc. UZUPELNIJ_SPISW)
 CURSOR curSzyby (pDataOd DATE, pDataDo DATE)
   IS SELECT nr_kom_szyby FROM spise
      WHERE d_wyk BETWEEN pDataOd AND pDataDo
         OR d_odcz BETWEEN pDataOd AND pDataDo
         OR data_sped BETWEEN pDataOd AND pDataDo
      UNION
      SELECT case L.wyroznik when 'B' then  B.nr_kom_szyby else E.nr_kom_szyby end
      FROM (select distinct nr_kom_zlec, nr_poz_zlec, nr_szt, wyroznik from l_wyc
            where d_wyk between pDataOd AND pDataDo) L
      LEFT JOIN spise E ON E.nr_komp_zlec=L.nr_kom_zlec AND E.nr_poz=L.nr_poz_zlec AND E.nr_szt=L.nr_szt
      LEFT JOIN spisz P ON P.nr_kom_zlec=L.nr_kom_zlec AND P.nr_poz=L.nr_poz_zlec
      LEFT JOIN braki_b B ON B.zlec_braki=L.nr_kom_zlec AND B.id_poz_br=P.id_poz;

 PROCEDURE UZUPELNIJ_SPISW(pDATA_OD IN DATE, pDATA_DO IN DATE,
                           pNR_KOM_ZLEC IN NUMBER DEFAULT 0, pNR_POZ IN NUMBER DEFAULT 0, pNR_SZT IN NUMBER DEFAULT 0 );
 PROCEDURE WYLICZ_SPISW(pNR_KOM_ZLEC IN NUMBER, pNR_POZ IN NUMBER, pNR_SZT IN NUMBER, pNR_KOM_SZYBY IN NUMBER,
                        pDATA_OD IN DATE, pDATA_DO IN DATE);
 PROCEDURE NALICZ_PO_LWYC(pNR_KOM_ZLEC IN NUMBER, pNR_POZ IN NUMBER, pNR_SZT IN NUMBER, pNR_ZM IN NUMBER,
           pZM_OD IN NUMBER, pZM_DO IN NUMBER, pNR_KOM_SZYBY_ORYG IN NUMBER);
 FUNCTION REC_SPISW (pNR_KOM_ZLEC IN NUMBER, pNR_POZ IN NUMBER, pNR_SZT IN NUMBER,pNR_INST IN NUMBER, pNR_OBR IN NUMBER, pNR_ZM IN NUMBER, pBRAK IN NUMBER)
   RETURN spisw%ROWTYPE;
 PROCEDURE ZAPISZ_SPISW(pNR_KOM_ZLEC IN NUMBER, pNR_POZ IN NUMBER, pNR_SZT IN NUMBER, pNR_INST IN NUMBER, pKOLEJN IN NUMBER,
                      pNR_ZM IN NUMBER, pDATA IN DATE, pNR_OBR IN NUMBER, pIND_OBR IN VARCHAR2, pIL_WYC IN NUMBER, pIL IN NUMBER, pIL_PRZEL IN NUMBER,
                      pBRAK IN NUMBER, pIL_BR IN NUMBER, pOPER IN VARCHAR2, pCZAS IN CHAR);
 FUNCTION OBR_WG_WYKZAL(pNR_KOMP_ZLEC IN NUMBER, pNR_POZ IN NUMBER, pNR_WAR IN NUMBER, pTYP_KAT IN VARCHAR2, pNR_KOMP_INST IN NUMBER)
  RETURN TAB_OBR;
 FUNCTION CZY_ZLEC_BRAKU (pNR_KOM_ZLEC IN NUMBER) RETURN BOOLEAN;
 FUNCTION SZUKAJ_INSTALACJI_BRAKU(pNR_KOM_ZLEC IN NUMBER, pNR_POZ IN NUMBER, pNR_SZT IN NUMBER, pNR_WAR IN NUMBER, pID_BR IN NUMBER) RETURN NUMBER;
 FUNCTION SZUKAJ_POZNIEJSZEJ(pNR_KOM_ZLEC IN NUMBER, pNR_POZ IN NUMBER, pNR_SZT IN NUMBER, pNR_WAR IN NUMBER, pMIN_KOL IN NUMBER, pNR_SER IN NUMBER) RETURN NUMBER;
 FUNCTION DAJ_WSP (pNR_OBR IN NUMBER, pNK_INST IN NUMBER, pTYP_SZKLA IN VARCHAR2) RETURN NUMBER;
 FUNCTION WSP_WG_GRUB (pNR_KOM_ZLEC IN NUMBER, pNR_POZ IN NUMBER, pWAR_OD IN NUMBER, pWAR_DO IN NUMBER) RETURN NUMBER;

END PKG_SPISW;
/
---------------------------
--New PACKAGE
--PKG_REJESTRACJA1
---------------------------
CREATE OR REPLACE PACKAGE "PKG_REJESTRACJA1" IS 
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
      --AND l_wyc.typ_inst not in ('A C','R C')
      AND (l_wyc.typ_inst not in ('MON','STR') or l_wyc.nr_warst=1) --A C wcale a MON tylko 1. warstwa
      AND (case when pZAKRES_INST=3 and l_wyc.zn_wyrobu=1 OR pZAKRES_INST in (4,5,6) and l_wyc.kolejn<pMAX_KOLEJN OR pZAKRES_INST=1 and l_wyc.nr_inst=pNR_INST OR pZAKRES_INST=2 then 1 else 0 end)=1
      AND (case when pZAPIS=0 and l_wyc.op=pOPER OR pNADPISZ=1 or l_wyc.d_wyk<to_date('2001/01/01','YYYY/MM/DD') then 1 else 0 end)=1
      AND (pZAPIS=1 or l_wyc.nr_stoj=0)
      AND (zn_braku in (0,7) OR zn_braku=8 and wyroznik<>'B')
      AND (parinst.fl_cutmon=2 OR (select nr_wdr from firma)=11) --VTM
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

END PKG_REJESTRACJA1;
/
---------------------------
--New PACKAGE
--PKG_REJESTRACJA0
---------------------------
CREATE OR REPLACE PACKAGE "PKG_REJESTRACJA0" IS 
/*deklaracje*/
/*nowy typ kursora, do podstawiana róznych kewrend - test NIEUZYWANE*/
TYPE ref_kursor IS REF CURSOR;

cOP_AUTOMAT CONSTANT CHAR(7) := 'AUTOMAT';

/*kursor wybierajacy rekordy z tabeli L_WYC wg parametrów wejsciowych*/
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

/*procedura uzupeniajaca L_WYC dla rekordów z 1. kursora*/ 
PROCEDURE Uzupelnij_l_wyc(
  pNR_KOM_SZYBY IN NUMBER
, pNR_KOM_ZLEC IN NUMBER
, pNR_POZ_ZLEC IN NUMBER
, pNR_SZT IN NUMBER
, pNR_WARST IN NUMBER
, pNR_INST IN NUMBER
, pZAKRES_INST IN NUMBER /*0-ostatnia; 1-biezaca; 2-wszystkie*/
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
END PKG_REJESTRACJA0;
/
---------------------------
--New PACKAGE
--PKG_PLAN_SPISS
---------------------------
CREATE OR REPLACE PACKAGE "PKG_PLAN_SPISS" AS
 vWDR NUMBER(3) := 0;
 --PARAMETRY planowania automatycznego
 --zmiana do zaplanowania operacji, dla których nie znaleziono wolnej zmiany
 gZM_BUFOR NUMBER:=PKG_CZAS.NR_KOMP_ZM(sysdate,4);
 --minimalna zmiana do zaplanowania
 gZM_START NUMBER(10):=PKG_CZAS.NR_KOMP_ZM(sysdate,1);
 --minimalna ilosc przeliczeniowa zo zaplanowania (jesli konieczny podzial ze wzgledu na oblozenie instalacji)
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

 FUNCTION CZAS_POPROC(pINST1 NUMBER, pINST2 NUMBER) RETURN NUMBER;
 --FUNKCJA SPRAWDZA CZY MOZNA PRZEPLANWOAC z INST_Z na INST_NA sztuki obecnie zaplanowane na pINST i zmiane pZM
 FUNCTION CZY_MOZNA_PRZENIESC (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pINST NUMBER, pZM NUMBER, pINST_Z NUMBER, pINST_NA NUMBER) RETURN NUMBER;  
 --FUNKCJA SPRAWDZAJACA CZY MOZNA WYKONAC W ZLECENIU (POZYCJI) OBRÓBKE (WSZYSTKIE OBRÓBKI)
 FUNCTION CZY_MOZNA_WYKONAC (pZT CHAR, pNK_ZLEC NUMBER, pNR_POZ NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0, pNR_PORZ NUMBER DEFAULT 0) RETURN NUMBER;

 FUNCTION LISTA_PRZEKROCZEN1(pLISTA_ZLEC VARCHAR2, pSQL_WHERE VARCHAR2 DEFAULT '1=1') RETURN VARCHAR2;

 --FUNKCJA ZWRACAJACA LISTE OBRÓBEK
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
---------------------------
--New PACKAGE
--PKG_PARAMETRY
---------------------------
CREATE OR REPLACE PACKAGE "PKG_PARAMETRY" IS
 cGR_SIL_DEFAULT CONSTANT NUMBER(2) := 4;
 cGR_SIL4 CONSTANT NUMBER(2) := 5;
 vNR_ODDZ NUMBER(2) := 0;
 FUNCTION GET_GR_SIL_DEFAULT RETURN NUMBER;
END PKG_PARAMETRY;
/
---------------------------
--New PACKAGE
--PKG_MAIN
---------------------------
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
---------------------------
--New PACKAGE
--PKG_FOREL240
---------------------------
CREATE OR REPLACE PACKAGE "PKG_FOREL240" AS 
  vSEP CONSTANT CHAR(1) := '|';
  function ORD(vORD_NUM varchar2, vCUST_NUM varchar2, vCUST_NAME varchar2, vTEXT1 varchar2, vTEXT2 varchar2, vTEXT3 varchar2, 
    vTEXT4 varchar2, vTEXT5 varchar2, vPROD_DATE varchar2, vDEL_DATE varchar2, vDEL_AREA varchar2) RETURN VARCHAR2;
  function pan(pITEM_NUM number, pID_NUM varchar2, pBARCODE varchar2, pPAN_QTY number, pWIDTH number, pHEIGHT number, 
    pPANE1 NUMBER, pSPACER1 NUMBER, pPANE2 NUMBER, pSPACER2 NUMBER, pPANE3 NUMBER, pSPACER3 NUMBER, pPANE4 NUMBER,
    pSEAL_INSET number, pGAS_SPACER1 number, pGAS_SPACER2 number, pGAS_SPACER3 number,
    pSEAL_CODE number, pSPACER_TYPE number, pSPACER_HEIGHT number, pSHAPE number, pHEAVY_PANE number, pRACK_INFO varchar2,
    pIG_PANE_REVERSE number) return varchar2;
  function shp(pSHP_PATH varchar2, pSHP_FILE varchar2, pSHP_NAME varchar2, pSHP_CAT number, pSHP_NUM number,
    pSHP_L number, pSHP_L1 number, pSHP_L2 number, pSHP_H number, pSHP_H1 number, pSHP_H2 number, 
    pSHP_R number, pSHP_R1 number, pSHP_R2 number, pSHP_R3 number, pSHP_MIRR number, pSHP_BASE number) RETURN VARCHAR2;
  function cm(pPaneNo number, pPANE_DESCRIPT varchar2, pID_NUM varchar2, pPANE_BARCODE varchar2, pPANE_TYPE number, pPANE_CODE varchar2,
    pPANE_THICKNESS number, pPANE_WIDTH number, pPANE_HEIGHT number, pPANE_FACESIDE number, pPANE_RACK_INFO varchar2,
    pSP_DESCRIPT varchar2, pSP_TYPE number, pSP_CODE varchar2, pSP_WIDTH number, pSP_HEIGHT number, pSP_INSET number,
    pSP_RACK_INFO varchar2, pSP_GASCODE number, pSP_SEAL_TYPE number) RETURN VARCHAR2;
  function ver(pUNIT number) RETURN VARCHAR2;
  function txt(pTXT varchar2) RETURN VARCHAR2;
end;
/
---------------------------
--New PACKAGE
--PKG_CZAS
---------------------------
CREATE OR REPLACE PACKAGE "PKG_CZAS" AS 

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
---------------------------
--New PACKAGE BODY
--PKG_TRANSFER_FILE
---------------------------
CREATE OR REPLACE PACKAGE BODY "PKG_TRANSFER_FILE" AS

function get_text(pNrKompZlec number, pNrPoz number, pNrSzt number, pNrWar number) return varchar2
as
  vTXT varchar2(1000);
begin
  select napis into vTXT from napisy_szyb_warstwy where nr_kom_zlec=pNrKompZlec and nr_poz=pNrPoz and nr_szt=pNrSzt and nr_war=pNrWar;
  vTXT := replace(vTXT,'%DATE%',to_char(sysdate(),'DD-MM-YYYY'));
  vTXT := replace(vTXT,'\','/');
  return vTXT;
end;

function spacer_forel_position(pDeviceId number, pNrKompZlec number, pNrPoz number, pNrSzt number, pNrWar number) return varchar2
as
  vResult varchar2(20000);
  vLinia varchar2(20000);
  vNrZlec number;
  vSep char;
  vSep2 varchar2(2);
  vNrWar number;
  cursor c1 is
    select d.do_war from spisd d
    left join katalog k on k.nr_kat=d.nr_kat
    where d.nr_kom_zlec=pNrKompZlec and d.nr_poz=pNrPoz and d.strona=0 and k.rodz_sur in ('TAF','POL')
    order by d.do_war;
begin
  vResult := ' ';
  vSep := ';';
  vSep2 := Chr(13)||Chr(10);
  select forel240_pan(pDeviceId,pNrKompZlec,pNrPoz,pNrSzt) into vLinia from dual;
  if length(trim(vLinia))>0 then
    vResult := vLinia;
  end if;
  if pNrWar=0 then
    select forel240_shp3(pDeviceId,pNrKompZlec,pNrPoz,1) into vLinia from dual;
    if length(trim(vLinia))>0 then
      vResult := vResult||vSep2||vLinia;
    end if;

    OPEN c1;
    LOOP
      FETCH c1 INTO vNrWar;
      EXIT WHEN c1%NOTFOUND;
      select forel240_elem(pDeviceId,pNrKompZlec,pNrPoz,vNrWar) into vLinia from dual;
      if length(trim(vLinia))>0 then
          vResult := vResult||vSep2||vlinia;
      end if;
      select forel240_pro(pDeviceId,pNrKompZlec,pNrPoz,vNrWar) into vLinia from dual;
      if length(trim(vLinia))>0 then
          vResult := vResult||vSep2||vlinia;
      end if;
      if vNrWar>1 then
        select forel240_txt(pDeviceId,pNrKompZlec,pNrPoz,pNrSzt,vNrWar) into vLinia from dual;
      end if;
      if length(trim(vLinia))>0 then
        vResult := vResult||vSep2||vLinia;
      end if;
    END LOOP;
    CLOSE c1;

  end if;
return vResult;
end;

function spacer_forel_layer(pDeviceId number, pNrKompZlec number, pNrPoz number, pNrSzt number, pNrWar number) return varchar2
as
  vResult varchar2(20000);
  vLinia varchar2(20000);
  vzm v_zlec_mon%rowtype;
  cursor c1 is  
    select * from v_zlec_mon where nr_kom_zlec=pNrKompZlec and nr_poz=pNrPoz and nr_el_wew=pNrWar;

  vNrZlec number;
  vSep2 varchar2(2);
  vRozneUszcz number;
  vNrKsztaltu number;
--PAN
  vPAN_ITEM_NUM number(5);
  vPAN_ID_NUM varchar2(10);
  vPAN_BARCODE varchar2(10);
  vPAN_QTY number(5);
  vPAN_WIDTH number(5);
  vPAN_HEIGHT number(5);
  vPAN_PANE1 NUMBER(5);
  vPAN_SPACER1 NUMBER(5);
  vPAN_PANE2 NUMBER(5);
  vPAN_SPACER2 NUMBER(5);
  vPAN_PANE3 NUMBER(5);
  vPAN_SPACER3 NUMBER(5);
  vPAN_PANE4 NUMBER(5);
  vPAN_SEAL_INSET number(3);
  vPAN_GAS_SPACER1 number(1);
  vPAN_GAS_SPACER2 number(1);
  vPAN_GAS_SPACER3 number(1);
  vPAN_SEAL_CODE number(1);
  vPAN_SPACER_TYPE number(1);
  vPAN_SPACER_HEIGHT number(5);
  vPAN_SHAPE number(5);
  vPAN_HEAVY_PANE number(1);
  vPAN_RACK_INFO varchar2(10);
  vPAN_IG_PANE_REVERSE number(1);
-- SHP
  vParamKszt varchar2(200);
  vSHP_PATH varchar2(40):=' ';
  vSHP_FILE varchar2(40):=' ';
  vSHP_NAME varchar2(40):=' ';
  vSHP_CAT number(1):=0;
  vSHP_NUM number(3):=0;
  vSHP_L number(5):=0;
  vSHP_L1 number(5):=0;
  vSHP_L2 number(5):=0;
  vSHP_H number(5):=0;
  vSHP_H1 number(5):=0;
  vSHP_H2 number(5):=0;
  vSHP_R number(5):=0;
  vSHP_R1 number(5):=0;
  vSHP_R2 number(5):=0;
  vSHP_R3 number(5):=0;
  vSHP_MIRR number(1):=0;
  vSHP_BASE number(1):=0;
--CMx
  vCM_PANE_DESCRIPT varchar2(100);
  vCM_ID_NUM varchar(10);
  vCM_PANE_BARCODE varchar2(20);
  vCM_PANE_TYPE number(1);
  vCM_PANE_CODE varchar2(20);
  vCM_PANE_THICKNESS number(5);
  vCM_PANE_WIDTH number(5);
  vCM_PANE_HEIGHT number(5);
  vCM_PANE_FACESIDE number(1);
  vCM_PANE_RACK_INFO varchar2(10);
  vCM_SP_DESCRIPT varchar2(100);
  vCM_SP_TYPE number(1);
  vCM_SP_CODE varchar2(20);
  vCM_SP_WIDTH number(5);
  vCM_SP_HEIGHT number(5);
  vCM_SP_INSET number(5);
  vCM_SP_RACK_INFO varchar2(10);
  vCM_SP_GASCODE number(1);
  vCM_SP_SEAL_TYPE number(1);

begin
  vResult := ' ';
  vSep2 := Chr(13)||Chr(10);

--PAN
  vPAN_ITEM_NUM := 0;
  vPAN_ID_NUM := '';
  vPAN_BARCODE := '';
  vPAN_QTY := 0;
  vPAN_WIDTH := 0;
  vPAN_HEIGHT := 0;
  vPAN_PANE1 := 0;
  vPAN_SPACER1 := 0;
  vPAN_PANE2 := 0;
  vPAN_SPACER2 := 0;
  vPAN_PANE3 := 0;
  vPAN_SPACER3 := 0;
  vPAN_PANE4 := 0;
  vPAN_SEAL_INSET := 0;
  vPAN_GAS_SPACER1 := 0;
  vPAN_GAS_SPACER2 := 0;
  vPAN_GAS_SPACER3 := 0;
  vPAN_SEAL_CODE := 0;
  vPAN_SPACER_TYPE := 0;
  vPAN_SPACER_HEIGHT := 0;
  vPAN_SHAPE := 0;
  vPAN_HEAVY_PANE := 0;
  vPAN_RACK_INFO := '';
  vPAN_IG_PANE_REVERSE := 0;
--SHP  
  vSHP_PATH :='';
  vSHP_FILE :='';
  vSHP_NAME :='';
  vSHP_MIRR :=0;
  vSHP_BASE :=0;
--CMx
  vCM_PANE_CODE := '';
  vCM_ID_NUM := '';
  vCM_SP_GASCODE := 1;
  vCM_SP_SEAL_TYPE := 1;
  vCM_PANE_FACESIDE := 0;
  vCM_PANE_RACK_INFO := ' ' ;

  vRozneUszcz := 0;

  OPEN c1;
  FETCH c1 INTO vzm;
--PAN    
  vPAN_PANE1 := 4;
  vPAN_SPACER1 := round(vzm.grub,0);
  vPAN_PANE2 := 4;

  if vzm.gaz='A' then 
    vPAN_GAS_SPACER1 := 1;
  elsif vzm.gaz='K' then
    vPAN_GAS_SPACER1 := 2;
  else
    vPAN_GAS_SPACER1 := 0;
  end if;

  if substr(vzm.ind_bud,13,1)=1 then
    vPAN_SEAL_CODE := 3;
  elsif vzm.silikon=1 then
    vPAN_SEAL_CODE := 2;
  else 
    vPAN_SEAL_CODE := 1;
  end if;
  if vzm.uszcz_rozne>0 then vRozneUszcz := 1; end if;

--  vPAN_WIDTH := (vzm.szer-vzm.max_stepL-vzm.max_stepP+vzm.stepL+vzm.stepP);
--  vPAN_HEIGHT := (vzm.wys-vzm.max_stepG-vzm.max_stepD+vzm.stepG+vzm.stepD);
  vPAN_WIDTH := vzm.szer;
  vPAN_HEIGHT := vzm.wys;

--CMx
--  vCM_PANE_WIDTH := (vzm.szer-vzm.max_stepL-vzm.max_stepP+vzm.stepL+vzm.stepP);
--  vCM_PANE_HEIGHT := (vzm.wys-vzm.max_stepG-vzm.max_stepD+vzm.stepG+vzm.stepD);
  vCM_PANE_WIDTH := vzm.szer;
  vCM_PANE_HEIGHT := vzm.wys;
  if vzm.nr_kat>0 then
    select NVL(substr(k.naz_kat,1,40),' '),nvl(floor(grubosc)*10,0),nvl(bok_od*10,0) into vCM_SP_DESCRIPT,vCM_SP_WIDTH,vCM_SP_HEIGHT from katalog k where k.nr_kat=vzm.nr_kat;        
  else 
    vCM_SP_DESCRIPT := ' ';
    vCM_SP_WIDTH := 0;
    vCM_SP_HEIGHT := 0;
  end if;
  vCM_SP_CODE := vzm.typ_kat;
  if vzm.szpros>0 then
    vCM_SP_CODE := vCM_SP_CODE || '(SZ)';
  end if;

  close c1;

  select 
    p.nr_poz ITEM_NUM,
    (select max(k.rack_no) from kol_stojakow k  where k.nr_komp_zlec=p.nr_kom_zlec and k.nr_poz=p.nr_poz and k.nr_sztuki=pNrSzt and k.nr_warstwy=pNrWar-1) ID_NUM,
    0 BARCODE,
    1 QTY,
    decode(p.GR_SIL,0,4.5,p.GR_SIL) INSET,
    decode(p.nr_kszt,0,0,1) 
  into  vPAN_ITEM_NUM,vPAN_ID_NUM,vPAN_BARCODE,vPAN_QTY,
        vPAN_SEAL_INSET,vNrKsztaltu
  from spisz p
  left join struktury s on s.kod_str=p.kod_str
  where p.nr_kom_zlec=pNrKompZlec and p.nr_poz=pNrPoz;

  vPAN_SHAPE := 0;
  if vRozneUszcz>0 or vNrKsztaltu>0 then vPAN_SHAPE := 1; end if;
  vPAN_WIDTH := vPAN_WIDTH - 2.0*vPAN_SEAL_INSET + 10; -- dodanie 10mm bo FOREL domyslnie odejmuje 5mm z kazdego boku
  vPAN_HEIGHT := vPAN_HEIGHT - 2.0*vPAN_SEAL_INSET + 10;
  vCM_PANE_WIDTH := vCM_PANE_WIDTH - 2.0*vPAN_SEAL_INSET + 10;
  vCM_PANE_HEIGHT := vCM_PANE_HEIGHT - 2.0*vPAN_SEAL_INSET + 10;
  vPAN_SEAL_INSET := 0;

  select pkg_forel240.pan(vPAN_ITEM_NUM, vPAN_ID_NUM, vPAN_BARCODE, vPAN_QTY, vPAN_WIDTH, vPAN_HEIGHT, 
    vPAN_PANE1, vPAN_SPACER1, vPAN_PANE2, vPAN_SPACER2, vPAN_PANE3, vPAN_SPACER3, vPAN_PANE4,
    vPAN_SEAL_INSET, vPAN_GAS_SPACER1, vPAN_GAS_SPACER2, vPAN_GAS_SPACER3, vPAN_SEAL_CODE, vPAN_SPACER_TYPE, 
    vPAN_SPACER_HEIGHT, vPAN_SHAPE, vPAN_HEAVY_PANE, vPAN_RACK_INFO, vPAN_IG_PANE_REVERSE) into vLinia from dual;

  if length(trim(vLinia))>0 then
    vResult := vLinia;
  end if;

  select strtoken(max(param_kszt),1,';') into vParamKszt from napisy_szyb_warstwy where nr_kom_zlec=pNrKompZlec and nr_poz=pNrPoz and nr_szt=1 and nr_war=pNrWar-1;
  if to_number(strtoken(vParamKszt,2,':'))>0 then
    vSHP_CAT := 0;
    if pDeviceId=0 then
      vSHP_CAT := 1;
    end if;
    vSHP_NUM := to_number(strtoken(vParamKszt,2,':'),'999');
    vSHP_L :=to_number(strtoken(vParamKszt,3,':'),'99999');
    vSHP_L1 :=to_number(strtoken(vParamKszt,4,':'),'99999');
    vSHP_L2 :=to_number(strtoken(vParamKszt,5,':'),'99999');
    vSHP_H :=to_number(strtoken(vParamKszt,6,':'),'99999');
    vSHP_H1 :=to_number(strtoken(vParamKszt,7,':'),'99999');
    vSHP_H2 :=to_number(strtoken(vParamKszt,8,':'),'99999');
    vSHP_R :=to_number(strtoken(vParamKszt,9,':'),'99999');
    vSHP_R1 :=to_number(strtoken(vParamKszt,10,':'),'99999');
    vSHP_R2 :=to_number(strtoken(vParamKszt,11,':'),'99999');
    vSHP_R3 :=to_number(strtoken(vParamKszt,12,':'),'99999');
    select pkg_forel240.shp(vSHP_PATH, vSHP_FILE, vSHP_NAME, vSHP_CAT, vSHP_NUM, vSHP_L, vSHP_L1, vSHP_L2, vSHP_H, vSHP_H1, vSHP_H2, 
      vSHP_R, vSHP_R1, vSHP_R2, vSHP_R3, vSHP_MIRR, vSHP_BASE) into vLinia from dual;
    if length(trim(vLinia))>0 then
      vResult := vResult||vSep2||vLinia;
    end if;
  end if;

  select pkg_forel240.cm(1,'','','',0,'','',vCM_PANE_WIDTH, vCM_PANE_HEIGHT, 0, '', '', 0, '', 0, 0, 0,'',0, 0) into vLinia from dual;
  if length(trim(vLinia))>0 then
    vResult := vResult||vSep2||vlinia;
  end if;
--  select forel240_elem2(pDeviceId,pNrKompZlec,pNrPoz,pNrWar) into vLinia from dual;
  select pkg_forel240.cm(2, vCM_PANE_DESCRIPT, vCM_ID_NUM, vCM_PANE_BARCODE, 0, vCM_PANE_CODE,
    vCM_PANE_THICKNESS, vCM_PANE_WIDTH, vCM_PANE_HEIGHT, vCM_PANE_FACESIDE, vCM_PANE_RACK_INFO,
    vCM_SP_DESCRIPT, vCM_SP_TYPE, vCM_SP_CODE, vCM_SP_WIDTH, vCM_SP_HEIGHT, vCM_SP_INSET,
    vCM_SP_RACK_INFO, vCM_SP_GASCODE, vCM_SP_SEAL_TYPE) into vLinia from dual;
  if length(trim(vLinia))>0 then
    vResult := vResult||vSep2||vlinia;
  end if;

--  select forel240_pro(pDeviceId,pNrKompZlec,pNrPoz,pNrWar) into vLinia from dual;
--  if length(trim(vLinia))>0 then
--    vResult := vResult||vSep2||vlinia;
--  end if;
  select pkg_forel240.txt(get_text(pNrKompZlec,pNrPoz,pNrSzt,pNrWar-1)) into vLinia from dual;
  if length(trim(vLinia))>0 then
    vResult := vResult||vSep2||vLinia;
  end if;
return vResult;
end;

function spacer_order_header(pDeviceId number, pNrKompZlec number) return varchar2
as
  vResult varchar2(20000);
  vORD_NUM varchar2(100);
  vCUST_NUM varchar2(100);
  vCUST_NAME varchar2(100);
  vPROD_DATE varchar2(100);
  vDEL_DATE varchar2(100);
begin
  select 
    z.nr_zlec ORD,
    z.nr_kon CUST_NUM,
    k.skrot_k CUST_NAM,
    to_char(z.d_plan,'DD/MM/YYYY') PRD_DATE,
    to_char(z.d_pl_sped,'DD/MM/YYYY') DEL_DATE
  into  vORD_NUM, vCUST_NUM, vCUST_NAME,
        vPROD_DATE, vDEL_DATE
  from zamow z
  left join klient k on k.nr_kon=z.nr_kon
  where z.nr_kom_zlec=pNrKompZlec;

  vResult := ' ';
  case pdeviceid
    when 0 then select pkg_forel240.ord(vORD_NUM, vCUST_NUM, vCUST_NAME, '', '', '', '', '', vPROD_DATE, vDEL_DATE, '') into vResult from dual;
    when 1 then select pkg_forel240.ord(vORD_NUM, vCUST_NUM, vCUST_NAME, '', '', '', '', '', vPROD_DATE, vDEL_DATE, '') into vResult from dual;
    when 2 then select pkg_forel240.ord(vORD_NUM, vCUST_NUM, vCUST_NAME, '', '', '', '', '', vPROD_DATE, vDEL_DATE, '') into vResult from dual;
  end case;
  return vResult;
end spacer_order_header;

function spacer_file_header(pDeviceId number) return varchar2
as
  vResult varchar2(2000);
begin
  vResult := ' ';
  case pdeviceid
    when 0 then select pkg_forel240.ver(0) into vResult from dual;
    when 1 then select pkg_forel240.ver(0) into vResult from dual;
    when 2 then select pkg_forel240.ver(0) into vResult from dual;
  end case;
  return vResult;
end spacer_file_header;

function spacer_position(pDeviceId number, pNrKompZlec number, pNrPoz number, pNrSzt number, pNrWar number) return varchar2
as
  vResult varchar2(20000);
begin
  vResult := ' ';
  case pdeviceid
    when 0 then vResult := spacer_forel_position(pDeviceId,pNrKompZlec,pNrPoz,pNrSzt,0);
    when 1 then vResult := spacer_forel_position(pDeviceId,pNrKompZlec,pNrPoz,pNrSzt,0);
    when 2 then vResult := spacer_forel_layer(pDeviceId,pNrKompZlec,pNrPoz,pNrSzt,pNrWar);
  end case;
  return vResult;
end spacer_position;

END PKG_TRANSFER_FILE;
/
---------------------------
--New PACKAGE BODY
--PKG_SPISW
---------------------------
CREATE OR REPLACE PACKAGE BODY "PKG_SPISW" AS

PROCEDURE UZUPELNIJ_SPISW(pDATA_OD IN DATE, pDATA_DO IN DATE, pNR_KOM_ZLEC IN NUMBER, pNR_POZ IN NUMBER, pNR_SZT IN NUMBER)
AS
 vNrSzyby NUMBER(10);
BEGIN 
  DELETE FROM spisw
  WHERE data_wyk BETWEEN pDATA_OD AND pDATA_DO AND flag=0
    AND (pNR_KOM_ZLEC=0 OR nr_kom_zlec=pNR_KOM_ZLEC) AND (pNR_POZ=0 OR nr_poz=pNR_POZ) AND (pNR_SZT=0 OR nr_szt=pNR_SZT);
  
  --wywolanie przeliczania tylko dla wybranego zlecenia/pozycji
  IF pNR_KOM_ZLEC>0 THEN
   OPEN curSPISE(pNR_KOM_ZLEC, pNR_POZ, pNR_SZT);
   LOOP FETCH curSPISE INTO vNrSzyby;
    EXIT WHEN curSPISE%NOTFOUND;
    PKG_SPISW.WYLICZ_SPISW(0, 0, 0, vNrSzyby, pDATA_OD, pDATA_DO );
   END LOOP;
   CLOSE curSPISE;    
  --wywolanie przeliczania dla wszystkich zlecen z zakresu dat
  ELSIF pNR_KOM_ZLEC=0 THEN  
   OPEN curSzyby(pDATA_OD,pDATA_DO);
   LOOP FETCH curSzyby INTO vNrSzyby;
    EXIT WHEN curSzyby%NOTFOUND;
    PKG_SPISW.WYLICZ_SPISW(0, 0, 0, vNrSzyby, pDATA_OD, pDATA_DO );
   END LOOP;
   CLOSE curSzyby;
  END IF; 
  
--EXCEPTION
--  WHEN OTHERS THEN 
--   BEGIN
--    IF curSzyby%ISOPEN THEN CLOSE curSzyby; END IF;
--    IF curSPISE%ISOPEN THEN CLOSE curSPISE; END IF;
--    RAISE;
--   END; 
   
END UZUPELNIJ_SPISW;


PROCEDURE WYLICZ_SPISW(pNR_KOM_ZLEC IN NUMBER, pNR_POZ IN NUMBER, pNR_SZT IN NUMBER, pNR_KOM_SZYBY IN NUMBER,
                       pDATA_OD IN DATE, pDATA_DO IN DATE)
AS
  vDataGran DATE DEFAULT to_date('2001/01/01','YYYY/MM/DD');
  vNr_zm NUMBER(10); --zm komp. do wpisania dla niewykonanaych
  vCzyWyprod BOOLEAN;
  vCzyZakon BOOLEAN;
  vZm_od NUMBER(10);
  vZm_do NUMBER(10);
BEGIN
 IF pNR_KOM_SZYBY=0 AND pNR_KOM_ZLEC=0 THEN RETURN; END IF; 
 IF pNR_KOM_SZYBY>0 THEN
  recSPISE := PKG_MAIN.REC_SPISE(0,0,0,pNR_KOM_SZYBY);
 ELSE 
  recSPISE := PKG_MAIN.REC_SPISE(pNR_KOM_ZLEC,pNR_POZ,pNR_SZT,0);
 END IF;
 
 vZm_od := PKG_CZAS.NR_KOMP_ZM(pDATA_OD,1);
 vZm_do := PKG_CZAS.NR_KOMP_ZM(pDATA_DO,4);

 DELETE FROM spisw WHERE nr_kom_zlec=recSPISE.nr_komp_zlec AND nr_poz=recSPISE.nr_poz AND nr_szt=recSPISE.nr_szt
                     AND flag=0 AND data_pw<vDataGran;
  
  --raise invalid_cursor;

 --wyjscie gdy pozycja anulowana lub zlecenie zakonczone
 vCzyZakon := recSPISE.zn_wyk=9;
 IF vCzyZakon THEN RETURN; END IF;
 recZAMOW := PKG_MAIN.REC_ZAMOW(recSPISE.nr_komp_zlec);
 vCzyZakon := substr(to_char(recZAMOW.flag_r,'99999999'),1,1)='3';
 IF vCzyZakon THEN RETURN; END IF;
 

 recSPISZ := PKG_MAIN.REC_SPISZ(recSPISE.nr_komp_zlec,recSPISE.nr_poz);
 IF recSPISE.data_wyk>vDataGran THEN vNr_zm:=PKG_CZAS.NR_KOMP_ZM(recSPISE.data_wyk,recSPISE.zm_wyk);
 ELSIF recSPISE.d_odcz>vDataGran THEN vNr_zm:=PKG_CZAS.NR_KOMP_ZM(recSPISE.d_odcz,1);
 ELSIF recSPISE.data_sped>vDataGran THEN vNr_zm:=PKG_CZAS.NR_KOMP_ZM(recSPISE.data_sped,recSPISE.zm_sped);
 ELSE vNr_zm:=0; END IF;
 vCzyWyprod := vNr_zm>0;
 IF vCzyWyprod AND vNr_zm between vZm_od and vZm_do THEN
  IF recSPISE.nr_komp_inst>0 THEN
   recPARINST := PKG_MAIN.REC_PARINST(recSPISE.nr_komp_inst);
   --co w sytuacji gdy wyprod na instalacji "rejestracja formatek" lub np. "pakowanie" (inst. bez wspolczynnikow)
   --IF recPARINST.rodz_plan=4 THEN  recPARINST := PKG_MAIN.REC_PARINST(recSPISZ.nr_komp_inst); END IF;
  ELSE
   recPARINST := PKG_MAIN.REC_PARINST(recSPISZ.nr_komp_inst);
  END IF;
  --jezeli montaz po SPISE to tutaj zapis SPISW
  IF recPARINST.ty_inst in ('MON','STR') OR recPARINST.rodz_plan=4 THEN
    ZAPISZ_SPISW(recSPISE.nr_komp_zlec, recSPISE.nr_poz, recSPISE.nr_szt, recPARINST.nr_komp_inst, recPARINST.kolejn,
                 PKG_CZAS.NR_KOMP_ZM(recSPISE.data_wyk,recSPISE.zm_wyk), PKG_CZAS.NR_ZM_TO_DATE(vNr_zm), 0 ,' ',
                 recSPISZ.il_szk, recSPISZ.szer*0.001*recSPISZ.wys*0.001, --recSPISZ.szer*0.001*recSPISZ.wys*0.001*recSPISZ.wsp_przel,
                 wsp_4zakr(recPARINST.nr_komp_inst, recSPISZ.szer*0.001*recSPISZ.wys*0.001, recSPISZ.ind_bud),
                 0, 0, recSPISE.o_wyk, recSPISE.t_wyk);
  END IF;
 END IF;
 
 --WPISYWANIE wczesniejszych instalacji ze zlec oryg.
 NALICZ_PO_LWYC(recSPISE.nr_komp_zlec, recSPISE.nr_poz, recSPISE.nr_szt, vNr_zm, vZm_od, vZm_do, 0);

 --BRAKI
 OPEN curBRAKI_B_1(recSPISE.nr_kom_szyby);
 LOOP FETCH curBRAKI_B_1 INTO recBRAKI_B;
  EXIT WHEN curBRAKI_B_1%NOTFOUND;
  recSPISZ:=PKG_MAIN.REC_SPISZ(recBRAKI_B.zlec_braki,0,recBRAKI_B.id_poz_br);
  NALICZ_PO_LWYC(recSPISZ.nr_kom_zlec, recSPISZ.nr_poz, 1, vNr_zm, vZm_od, vZm_do, recSPISE.nr_kom_szyby);
 END LOOP;
 CLOSE curBRAKI_B_1;
--
--EXCEPTION
--  WHEN OTHERS THEN
--   BEGIN
--    IF curSzyby%ISOPEN THEN CLOSE curSzyby; END IF;
--    RAISE;
--   END;
 
END WYLICZ_SPISW;

PROCEDURE NALICZ_PO_LWYC(pNR_KOM_ZLEC IN NUMBER, pNR_POZ IN NUMBER, pNR_SZT IN NUMBER, pNR_ZM IN NUMBER,
          pZM_OD IN NUMBER, pZM_DO IN NUMBER, pNR_KOM_SZYBY_ORYG IN NUMBER)
AS
 vNrZm NUMBER(10);
 vNrZmPam NUMBER(10); --numer komp. zmiany do wpisania, gdy brak wyk.
 vWarTmp NUMBER(2);
 vNowaWar BOOLEAN;
 vCzyBrak BOOLEAN;
 vIdPozBr NUMBER(10);
 vNkInstBr NUMBER(10);
 vInstBr parinst%ROWTYPE;
 vObrobki TAB_OBR;
 vNrObr NUMBER(10);
 vIlObr NUMBER(10,4);
 vWsp NUMBER(7,4);
 recSPISZ spisz%ROWTYPE;
 recSPISE spise%ROWTYPE;
 recL_WYC l_wyc%ROWTYPE;
 --kursor dla obrobki DECOAT (nie planuje sie)
 CURSOR cD (pZLEC NUMBER, pPOZ NUMBER, pWAR NUMBER)
  IS SELECT max(D.nr_komp_obr), sum(D.ilosc_do_wyk) FROM spisd D
     LEFT JOIN slparob S ON S.nr_k_p_obr=D.nr_komp_obr
     WHERE S.symb_p_obr='DECOAT'
       AND D.nr_kom_zlec=pZLEC and D.nr_poz=pPOZ and D.do_war=pWAR;

BEGIN
 vNrZmPam:=0;
 --recZAMOW := REC_ZAMOW(pNR_KOM_ZLEC);
 --vCzyBrak:=CZY_ZLEC_BRAKU(pNR_KOM_ZLEC);
 vCzyBrak := pNR_KOM_SZYBY_ORYG>0;
 vIdPozBr:=0;
 IF vCzyBrak THEN
  recSPISE := PKG_MAIN.REC_SPISE(0,0,0,pNR_KOM_SZYBY_ORYG);
  recSPISZ:=PKG_MAIN.REC_SPISZ(pNR_KOM_ZLEC,pNR_POZ);
  vIdPozBr:=recSPISZ.id_poz;
 ELSE
  recSPISE := PKG_MAIN.REC_SPISE(pNR_KOM_ZLEC,pNR_POZ,pNR_SZT,0);
 END IF;
 
 vWarTmp:=0;
 --malejaco wg l_wyc.kolejn
 OPEN curL_WYC_1(pNR_KOM_ZLEC, pNR_POZ, pNR_SZT,0,0);
  LOOP FETCH curL_WYC_1 INTO recL_WYC;
   EXIT WHEN curL_WYC_1%NOTFOUND;
   vNowaWar:=recL_WYC.nr_warst<>vWarTmp;
   vWarTmp:=recL_WYC.nr_warst;
   IF vCzyBrak THEN
    --TODO:
    --lepiej zwrocic caly rekord "pierwszego,nastepnego" braku
    --bo potrzebne odzielnie sprawdzania gdy ten brak na kilu warstwach, bo kolejny moze byc na pojedynczej warstwie
    IF vNowaWar THEN
     vNkInstBr:=SZUKAJ_INSTALACJI_BRAKU(recL_WYC.nr_kom_zlec, recL_WYC.nr_poz_zlec, recL_WYC.nr_szt, recL_WYC.nr_warst,vIdPozBr);
    END IF; 
    IF vNkInstBr>0 THEN
     recPARINST := PKG_MAIN.REC_PARINST(vNkInstBr);
     --wyjscie gdy byl brak na braku wczesniej
     IF recPARINST.kolejn>0 and recL_WYC.kolejn>=recPARINST.kolejn THEN
       --CONTINUE;
       GOTO FOO; 
     END IF;
    END IF; 
   END IF;

   vNrZm:=PKG_CZAS.NR_KOMP_ZM(recL_WYC.d_wyk,recL_WYC.zm_wyk);
   --szukanie zmiany do wpisania gdy niewykonane
   IF vNrZm=0 THEN
    IF vNowaWar THEN
     vNrZm:=SZUKAJ_POZNIEJSZEJ(recL_WYC.nr_kom_zlec, recL_WYC.nr_poz_zlec, recL_WYC.nr_szt, recL_WYC.nr_warst, recL_WYC.kolejn, recL_WYC.nr_ser);
    END IF;
    IF vNrZm=0 THEN 
     IF vNrZmPam>0 THEN vNrZM:=vNrZmPam;
                   ELSE vNrZm:=pNR_ZM;
     END IF;
    END IF;
   END IF;
   vNrZmPam:=vNrZm;

   --pominiecie wpisywania gdy nie znaleziono daty (zmiany) na ktora wpisac LUB data jest spoza wejsciowego zakresu dat
   IF vNrZm=0 OR NOT vNrZm BETWEEN pZM_OD AND pZM_DO THEN
       --CONTINUE; nie dziala w Oracle10
       GOTO FOO;
   END IF;
   --pomijanie instalacji Montazu
   IF recL_WYC.typ_inst IN ('MON','STR') THEN
       --CONTINUE;
       GOTO FOO;
   --jezeli instalacja ciecia to ilosc obrobki wg Dodatkow (powierzchnia do ciecia)
   ELSIF recL_WYC.typ_inst IN ('A C','R C') THEN
    recSPISD:=PKG_MAIN.REC_SPISD(recL_WYC.nr_kom_zlec, recL_WYC.nr_poz_zlec, recL_WYC.nr_warst,4);
    vNrObr:=0;
    vIlObr:=recSPISD.szer_obr*0.001*recSPISD.wys_obr*0.001;
    vWsp := DAJ_WSP(0, recL_WYC.nr_inst, recL_WYC.typ_kat);
    ZAPISZ_SPISW(recSPISE.nr_komp_zlec, recSPISE.nr_poz, recSPISE.nr_szt, recL_WYC.nr_inst, recL_WYC.kolejn,
                 PKG_CZAS.NR_KOMP_ZM(recL_WYC.d_wyk,recL_WYC.zm_wyk), PKG_CZAS.NR_ZM_TO_DATE(vNrZm), vNrObr ,' ',
                 1, vIlObr, vIlObr*vWsp, case when vCzyBrak then 1 else 0 end, case when vCzyBrak then 1 else 0 end,
                 recL_WYC.op, recL_WYC.czas);
    --zapis DECOAT
    OPEN cD(recL_WYC.nr_kom_zlec, recL_WYC.nr_poz_zlec, recL_WYC.nr_warst);
    FETCH cD INTO vNrObr,vIlObr;
    CLOSE cD;
    IF vIlObr is not null THEN
     vWsp:=DAJ_WSP(vNrObr, 1, ' ');
     ZAPISZ_SPISW(recSPISE.nr_komp_zlec, recSPISE.nr_poz, recSPISE.nr_szt, recL_WYC.nr_inst, recL_WYC.kolejn,
                 PKG_CZAS.NR_KOMP_ZM(recL_WYC.d_wyk,recL_WYC.zm_wyk), PKG_CZAS.NR_ZM_TO_DATE(vNrZm), vNrObr ,' ',
                 1, vIlObr, vIlObr*vWsp, case when vCzyBrak then 1 else 0 end, case when vCzyBrak then 1 else 0 end,
                 recL_WYC.op, recL_WYC.czas);
    END IF;
   --jezeli pozostale obrobki, to pobranie ilosci i numerow obrobek z WYKZAL
   ELSE
    vObrobki := OBR_WG_WYKZAL(recL_WYC.nr_kom_zlec, recL_WYC.nr_poz_zlec, recL_WYC.nr_warst, recL_WYC.typ_kat, recL_WYC.nr_inst);
    FOR i IN 1 ..  greatest(1,vObrobki.count) LOOP
     IF vObrobki.count<1 THEN
      vNrObr:=0; --DO POPRAWY!
      vIlObr:=0; --0 gdy jest rekord w L_WYC a brak w WYKZAL
      vWsp :=0;
     ELSE
      vNrObr:=vObrobki(i).nr_obr;
      vIlObr:=vObrobki(i).il_jedn;
      vWsp:=vObrobki(i).wsp;
     END IF;
     ZAPISZ_SPISW(recSPISE.nr_komp_zlec, recSPISE.nr_poz, recSPISE.nr_szt, recL_WYC.nr_inst, recL_WYC.kolejn,
                 PKG_CZAS.NR_KOMP_ZM(recL_WYC.d_wyk,recL_WYC.zm_wyk), PKG_CZAS.NR_ZM_TO_DATE(vNrZm), vNrObr ,' ',
                 1, vIlObr, vIlObr*vWsp, case when vCzyBrak then 1 else 0 end, case when vCzyBrak then 1 else 0 end,
                 recL_WYC.op, recL_WYC.czas);
    END LOOP; --koniec petli po kolekcji obrobek
   END IF;
   <<FOO>> NULL; 
  END LOOP; --koniec petli po instalacjach/warstwach (malejaco)
 CLOSE curL_WYC_1;
END;

FUNCTION OBR_WG_WYKZAL(pNR_KOMP_ZLEC IN NUMBER, pNR_POZ IN NUMBER, pNR_WAR IN NUMBER, pTYP_KAT IN VARCHAR2, pNR_KOMP_INST IN NUMBER)
  RETURN TAB_OBR
AS
 vPopWar NUMBER(2);
 vPopObr NUMBER(10);
 vWspObr NUMBER(7,3):=0;
 vWspSzkiel NUMBER(7,3):=0;
 vPara WSP_OBR_TYP;
 vWynik TAB_OBR;
BEGIN
  vPopWar:=-1;
  vPopObr:=-1;
  vWynik:=TAB_OBR();
  OPEN curWYKZAL_1(pNR_KOMP_ZLEC, pNR_POZ, pNR_WAR, pNR_KOMP_INST);
  LOOP FETCH curWYKZAL_1 INTO recWYKZAL;
   EXIT WHEN curWYKZAL_1%NOTFOUND;
   IF vPopObr<>recWYKZAL.nr_komp_obr OR vPopWar<>recWYKZAL.nr_warst THEN
    recPARINST:=PKG_MAIN.REC_PARINST(recWYKZAL.nr_komp_instal);
    --gdy laminowanie (ale nie WEjscie)
    IF recPARINST.rodz_plan=3 AND recPARINST.sort<>1 THEN
      vWspSzkiel:=WSP_WG_GRUB(pNR_KOMP_ZLEC, pNR_POZ, recWYKZAL.nr_warst, greatest(1,recWYKZAL.nr_warst,recWYKZAL.straty));
      IF vWspSzkiel is null THEN vWspSzkiel:=0; END IF;
    ELSIF recPARINST.sort=1 THEN
      vWspSzkiel:=0;
    ELSE
      vWspSzkiel:=1;
    END IF;
    IF vWspSzkiel>0 THEN
      vWspObr:=DAJ_WSP(recWYKZAL.nr_komp_obr,pNR_KOMP_INST,case when recPARINST.rodz_plan=3 then recWYKZAL.indeks else pTYP_KAT end);
    END IF;  

    vPara.nr_obr:=recWYKZAL.nr_komp_obr;
    vPara.il_jedn:=recWYKZAL.il_jedn;
    vPara.wsp   :=vWspObr*vWspSzkiel;
    vWynik.extend;
    vWynik(vWynik.last):=vPara;
   END IF;
   vPopWar:=recWYKZAL.nr_warst;
   vPopObr:=recWYKZAL.nr_komp_obr;
  END LOOP;
 CLOSE curWYKZAL_1;
 RETURN vWynik;
END OBR_WG_WYKZAL;

FUNCTION REC_SPISW (pNR_KOM_ZLEC IN NUMBER, pNR_POZ IN NUMBER, pNR_SZT IN NUMBER,
                    pNR_INST IN NUMBER, pNR_OBR IN NUMBER, pNR_ZM IN NUMBER, pBRAK IN NUMBER)
   RETURN spisw%ROWTYPE
AS
 rec spisw%ROWTYPE;
 CURSOR c1
  IS SELECT * FROM spisw
     WHERE nr_kom_zlec=pNR_KOM_ZLEC AND nr_poz=pNR_POZ AND nr_szt=pNR_SZT
       AND nr_inst=pNR_INST AND nr_obr=pNR_OBR AND nr_komp_zm=pNR_ZM AND brak=pBRAK;
BEGIN
  rec := null;
  OPEN c1;  FETCH c1 INTO rec; CLOSE c1;
  RETURN rec;
END REC_SPISW; 

PROCEDURE ZAPISZ_SPISW(pNR_KOM_ZLEC IN NUMBER, pNR_POZ IN NUMBER, pNR_SZT IN NUMBER, pNR_INST IN NUMBER, pKOLEJN IN NUMBER,
                      pNR_ZM IN NUMBER, pDATA IN DATE, pNR_OBR IN NUMBER, pIND_OBR IN VARCHAR2, pIL_WYC IN NUMBER, pIL IN NUMBER, pIL_PRZEL IN NUMBER,
                      pBRAK IN NUMBER, pIL_BR IN NUMBER, pOPER IN VARCHAR2, pCZAS IN CHAR)
AS
  vData DATE;
  vZm  NUMBER(1) DEFAULT 0;
  vIlPrzel NUMBER DEFAULT 0;
  --vPlik  utl_file.file_type;
BEGIN
  IF pIL_PRZEl is not null THEN vIlPrzel:=pIL_PRZEL; END IF;
  --vPlik := UTL_FILE.FOPEN('EXP_DIR','spisw.log', 'A', 32000 );
  --UTL_FILE.PUT_LINE(vPlik,pNR_KOM_ZLEC||';'||pNR_POZ||';'||pNR_SZT||';'||pNR_INST||';'||pKOLEJN||';'||pNR_ZM||';'||pDATA||';'||pNR_OBR||';'||pBRAK||';'||pIL_BR);
  recSPISW := PKG_SPISW.REC_SPISW(pNR_KOM_ZLEC, pNR_POZ, pNR_SZT, pNR_INST, pNR_OBR, pNR_ZM, pBRAK);
  --gdy nie ma takiego rekordu rekordu
  IF recSPISW.nr_kom_zlec is null THEN
   IF pNR_ZM>0 THEN
    vData:=PKG_CZAS.NR_ZM_TO_DATE(pNR_ZM);
    vZm  :=PKG_CZAS.NR_ZM_TO_ZM(pNR_ZM);
   ELSE
    vData:=pDATA;
   END IF;
   INSERT INTO spisw (nr_kom_zlec, nr_poz, nr_szt, nr_inst, kolejn, nr_komp_zm, data_wyk, zm_wyk, nr_obr, ind_obr, jdn_obr,
                      il_wyc, il_obr, il_przel, brak, il_szt_br, id_prac, godz_wyk)
        VALUES (pNR_KOM_ZLEC, pNR_POZ, pNR_SZT, pNR_INST, pKOLEJN, pNR_ZM, vData, vZm, pNR_OBR, pIND_OBR, ' ',
                pIL_WYC, pIL, pIL_PRZEL, pBRAK, pIL_BR, pOPER, pCZAS);                
 --gdy jest rekord to UPDATE mozliwy tylko dla FLAG=0 
  ELSIF recSPISW.flag=0 THEN
    UPDATE spisw
    SET il_wyc=il_wyc+pIL_WYC,  il_obr=il_obr+pIL, il_przel=il_przel+pIL_PRZEL,
        il_szt_br=il_szt_br+pIL_BR, ind_obr=pIND_OBR, kolejn=pKOLEJN,
        id_prac=case when pCZAS>godz_wyk then pOPER else id_prac end, godz_wyk=greatest(pCZAS,godz_wyk)
    WHERE nr_kom_zlec=pNR_KOM_ZLEC AND nr_poz=pNR_POZ AND nr_szt=pNR_SZT AND nr_inst=pNR_INST AND nr_obr=pNR_OBR AND nr_komp_zm=pNR_ZM
      AND brak=pBRAK AND flag=0; --!!!!!!
  END IF;
 --utl_file.fclose(vPlik);
EXCEPTION
  WHEN OTHERS THEN
   BEGIN
    --UTL_FILE.PUT_LINE(vPlik,SQLERRM);
    --utl_file.fclose(vPlik);
    IF curSPISZ%ISOPEN   THEN CLOSE curSPISZ; END IF;
    IF curL_WYC_1%ISOPEN THEN CLOSE curL_WYC_1; END IF;
    IF curWYKZAL_1%ISOPEN THEN CLOSE curWYKZAL_1; END IF;
    IF curBRAKI_B_1%ISOPEN THEN CLOSE curBRAKI_B_1; END IF;
    IF curSzyby%ISOPEN THEN CLOSE curSzyby; END IF;
    RAISE;
    RAISE_APPLICATION_ERROR(-20099,'ZLEC:'||pNR_KOM_ZLEC||' POZ:'||pNR_POZ||' SZT:'||pNR_SZT);
   END;
END ZAPISZ_SPISW;

FUNCTION CZY_ZLEC_BRAKU (pNR_KOM_ZLEC IN NUMBER) RETURN BOOLEAN
AS
 vTmp NUMBER(4);
BEGIN
  SELECT count(1) INTO vTmp FROM braki_b WHERE zlec_braki=pNR_KOM_ZLEC;
  IF vTmp>0 THEN RETURN true; ELSE RETURN false; END IF;
END CZY_ZLEC_BRAKU;

FUNCTION SZUKAJ_INSTALACJI_BRAKU(pNR_KOM_ZLEC IN NUMBER, pNR_POZ IN NUMBER, pNR_SZT IN NUMBER, pNR_WAR IN NUMBER, pID_BR IN NUMBER)
  RETURN NUMBER
AS
 vInst NUMBER(10):=0;
 vZlec NUMBER(10);
 vPoz NUMBER(10);
 vSzt NUMBER(10);
 vWar NUMBER(2);
 --kursor zwraca nr komp. inst. na ktorej powstal brak o ID_POZ poznijeszym niz wejsciowy pID_BR
 --podzapytanie zwraca  najwczensiejszej pozycji zlecenia braku dla warstwy wejsciowej (z uwzglednieniem brakow na calosci i laminatach)
 CURSOR cB IS
  SELECT braki_b.inst_pow
  FROM (Select min(B.zlec_braki) zlec_braki, min(B.id_poz_br) id_poz_br
       From braki_b B
       Left Join spisz P On P.nr_kom_zlec=B.zlec_braki and P.id_poz=B.id_poz_br
       Where B.nr_zlec=vZlec and B.nr_poz=vPoz and B.nr_szt=vSzt and B.id_poz_br>pID_BR
         and (B.nr_war=vWar or B.nr_war=0
              or B.laminat=1 and vWar between B.nr_war and B.nr_war+P.il_szk-1))
  LEFT JOIN braki_b USING (zlec_braki,id_poz_br);
 recBRAKI braki_b%ROWTYPE; 
BEGIN
 IF pID_BR>0 THEN
  recBRAKI:=PKG_MAIN.REC_BRAKI_B(pNR_KOM_ZLEC,pID_BR);
  vZlec:=recBRAKI.nr_zlec;
  vPoz:=recBRAKI.nr_poz;
  vSzt:=recBRAKI.nr_szt;
  vWar:=greatest(1,recBRAKI.nr_war)+pNR_WAR-1;
 ELSE
  vZlec:=pNR_KOM_ZLEC;
  vPoz:=pNR_POZ;
  vSzt:=pNR_SZT;
  vWar:=pNR_WAR;
 END IF;
 OPEN cB;
 FETCH cB INTO vInst;
 CLOSE cB;
 IF vInst IS NULL THEN RETURN 0; ELSE RETURN vInst; END IF;
EXCEPTION
 WHEN OTHERS THEN
  IF cB%ISOPEN THEN CLOSE cB; END IF;
END SZUKAJ_INSTALACJI_BRAKU;

FUNCTION SZUKAJ_POZNIEJSZEJ(pNR_KOM_ZLEC IN NUMBER, pNR_POZ IN NUMBER, pNR_SZT IN NUMBER, pNR_WAR IN NUMBER, pMIN_KOL IN NUMBER, pNR_SER IN NUMBER)
  RETURN NUMBER
AS
 vWynik NUMBER(10);
 CURSOR cL IS
  SELECT * FROM 
    (SELECT * from l_wyc
     WHERE nr_kom_zlec=pNR_KOM_ZLEC and nr_poz_zlec=pNR_POZ and nr_szt=pNR_SZT and kolejn>=pMIN_KOL and nr_warst<=pNR_WAR
     UNION 
     SELECT * from l_wyc WHERE nr_ser=pNR_SER AND kolejn>=pMIN_KOL)
  ORDER BY case when nr_ser=pNR_SER then 'a' else 'b' end, kolejn ;
--  IS SELECT L.* from l_wyc L
--     LEFT JOIN parinst I ON I.nr_komp_inst=L.nr_inst
--     WHERE L.nr_kom_zlec=pNR_KOM_ZLEC and L.nr_poz_zlec=pNR_POZ and L.nr_szt=pNR_SZT and L.kolejn>=pMIN_KOL and nr_warst<=pNR_WAR
--     ORDER BY case when L.nr_warst=pNR_WAR then 1 else 2 end, kolejn ;
 recLW l_wyc%ROWTYPE;
BEGIN
 vWynik:=0;
 OPEN cL;
 LOOP FETCH cL INTO recLW;
  EXIT WHEN cl%NOTFOUND OR vWynik>0;
  vWynik:=PKG_CZAS.NR_KOMP_ZM(recLW.d_wyk, recLW.zm_wyk);
 END LOOP;
 CLOSE cL;
 RETURN vWynik;
END SZUKAJ_POZNIEJSZEJ;

FUNCTION DAJ_WSP (pNR_OBR IN NUMBER, pNK_INST IN NUMBER, pTYP_SZKLA IN VARCHAR2)
  RETURN NUMBER
AS 
 vWynik NUMBER(7,3);
 vTmp  NUMBER(6,3);
 vNr_obr NUMBER(10); --zmienna wykorzystywana gdy pNR_OBR=0 (pierwsze otwarcie kursora)
 vNU  NUMBER(10); --zmienna potrzeba jedynie do FETCH kursora
 czyLaminat BOOLEAN;
 recObr slparob%ROWTYPE;
 --kursor po czynnosciach przypisanych do inst. laczeniowych
 CURSOR cCzyn
  IS select K.*
     from katalog K
     left join parinst I on I.ty_inst=K.typ_inst1 and I.nr_inst=K.nr_inst
     where K.rodz_sur='CZY' and rodz_plan=3;
 --kursor do wspolczynnikow    
 CURSOR cWsp (pTYP NUMBER, pINST NUMBER, pOBR NUMBER, pSZKLO VARCHAR2 DEFAULT '')
  IS SELECT nr_komp_obr, wsp FROM wsp_obr 
     WHERE typ_wsp=pTYP 
       AND (pTYP<>1 OR (pINST=0 or nr_komp_inst=pINST) AND (pOBR=0 or nr_komp_obr=pOBR))
       AND (pTYP<>2 OR typ_kat_szkla=pSZKLO AND nr_komp_obr=pOBR)
     ORDER BY nr_komp_obr DESC; --bo dla A C szukalo obrobki ze slownika (DECOAT) zamiast z katalogu (R)
 
BEGIN
  recPARINST:=PKG_MAIN.REC_PARINST(pNK_INST);
  czyLaminat := recPARINST.rodz_plan=3;
  vWynik:=1;
  IF NOT czyLaminat THEN
    recObr:=PKG_MAIN.REC_SLPAROB(pNR_OBR); 
    /*wsp. dla instalacji */
    OPEN cWsp(1,pNK_INST,pNR_OBR);
    FETCH cWsp INTO vNr_obr,vTmp;
    CLOSE cWsp;
    IF vTmp is not null AND vTmp>0 THEN 
     vWynik:=vTmp; 
    --gdy nieznaleziono wsp. dla inst i obr, szukanie wsp. dla obrobki na instalacji wg slownika lub zerowej
    ELSE
     IF pNR_OBR>0 THEN
      OPEN cWsp(1,case when recObr.nr_komp_inst is null then 0 else recObr.nr_komp_inst end, pNR_OBR);
      FETCH cWsp INTO vNU,vTmp;
      CLOSE cWsp; 
      IF vTmp is not null AND vTmp>0 THEN 
        vWynik:=vTmp;
      END IF;  
     END IF; 
    END IF;
    /*wsp. dla szkla */
    IF pTYP_SZKLA is not null AND pTYP_SZKLA<>' ' THEN
     OPEN cWsp(2,0,case when recObr.nr_kat_obr is not null then recObr.nr_kat_obr else greatest(pNR_OBR,vNr_obr) end,
               pTYP_SZKLA);
     FETCH cWsp INTO vNU,vTmp;
     CLOSE cWsp;
     --wynikowy wspolczynnik jako iloczyn wspolczynnika z instalacji i dla szkla
     IF vTmp is not null AND vTmp>0 THEN 
      vWynik:=vWynik*vTmp; 
     END IF; 
    END IF;
    RETURN vWynik;
  --instalacje laczeniowe
  ELSIF czyLaminat THEN
    OPEN cCzyn;
    LOOP
      FETCH cCzyn INTO recKat;
      EXIT WHEN cCzyn%NOTFOUND;
      --pominiecie tej czynnosci jezeli nie wystepuje w kodzie struktury
      IF NOT (instr(pTYP_SZKLA,vSEP_STR||recKat.typ_kat||vSEP_STR)>0 OR 
              instr(pTYP_SZKLA,vSEP_STR||recKat.typ_kat||vSEP_STR)=length(pTYP_SZKLA)-length(recKat.typ_kat))
       THEN        
        GOTO FOO; --CONTINUE; 
      END IF;
      --szukanie wszpolczynnikow dla czynnosci/obrobki
      OPEN cWsp(1,pNK_INST,recKat.nr_kat);
      FETCH cWsp INTO vNU,vTmp;
      CLOSE cWsp;
      IF vTmp is not null AND vTmp>0 THEN 
       vWynik:=vWynik*vTmp;
      --gdy brak wspolczynnika na wejsciowej instalacji to szukanie na tej z katalogu
      ELSE
       recPARINST:=PKG_MAIN.REC_PARINST(0,recKat.typ_inst1,recKat.nr_inst);
       IF recPARINST.nr_komp_inst<>pNK_INST THEN
        OPEN cWsp(1,pNK_INST,recKat.nr_kat);
        FETCH cWsp INTO vNU,vTmp;
        CLOSE cWsp;
        IF vTmp is not null AND vTmp>0  THEN 
         vWynik:=vWynik*vTmp;
        END IF; 
       END IF;
      END IF;
     <<FOO>> NULL;       
    END LOOP;  
    CLOSE cCzyn;
  END IF;  
    RETURN vWynik;
END DAJ_WSP;

FUNCTION WSP_WG_GRUB (pNR_KOM_ZLEC IN NUMBER, pNR_POZ IN NUMBER, pWAR_OD IN NUMBER, pWAR_DO IN NUMBER)
  RETURN NUMBER
AS
 vWspMM NUMBER(5,3);
 CURSOR cD
  IS SELECT * FROM spisd
     WHERE nr_kom_zlec=pNR_KOM_ZLEC AND nr_poz=pNR_POZ AND do_war between pWAR_OD and pWAR_DO AND strona=0;
 vWynik NUMBER(5,3) DEFAULT 0;    
BEGIN
  vWspMM:=PKG_MAIN.GET_PARAM_T(109,'0.25');
  OPEN cD;
  LOOP
   FETCH cD INTO recSPISD;
   EXIT WHEN cD%NOTFOUND;
   --pobranie grubosc szkla z Katalogu
   IF recSPISD.zn_war='Sur' THEN
    recKat:=PKG_MAIN.REC_KATALOG(recSPISD.nr_kat);
    IF recKAT.rodz_sur='TAF' THEN
      vWynik:=vWynik+(recKAT.grubosc-4)*vWspMM+1;
    END IF;
  --pobranie grubosci Polproduktu ze Struktur  
   ELSIF recSPISD.zn_war='Pol' THEN
    recStr:=PKG_MAIN.REC_STRUKTURY(0,recSPISD.kod_dod);
    vWynik:=vWynik+(recStr.gr_pak-4)*vWspMM+1;
   END IF;
  END LOOP;
  CLOSE cD;
  RETURN vWynik;
END WSP_WG_GRUB;

END PKG_SPISW;
/
---------------------------
--New PACKAGE BODY
--PKG_REJESTRACJA1
---------------------------
CREATE OR REPLACE PACKAGE BODY "PKG_REJESTRACJA1" AS

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
  --uzup. zlec. braków 
 IF pUWZGL_BRAKI=1 THEN
  FOR b IN (select B.zlec_braki, P.nr_poz nr_poz_br
            from braki_b B
            left join spisz P ON P.id_poz =B.id_poz_br
            where B.nr_kom_szyby=pNR_KOM_SZYBY)
   LOOP
    IF b.nr_poz_br is not null AND b.zlec_braki>0 THEN
     Uzupelnij_l_wyc(0, b.zlec_braki, b.nr_poz_br, 1, 0, pNR_INST, pZAKRES_INST, pNADPISZ, 0, pDATA_WYK, pZM_WYK, pNR_STOJ, pPOZ_STOJ, pZAPIS, pMAX_KOLEJN, pOPER);
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
     --AND typ_inst='A C' --and d_wyk<to_date('2001','YYYY')
     AND (select ty_inst from parinst where nr_komp_inst=l_wyc.nr_inst) in ('A C','R C')
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

END PKG_REJESTRACJA1;
/
---------------------------
--New PACKAGE BODY
--PKG_REJESTRACJA0
---------------------------
CREATE OR REPLACE PACKAGE BODY "PKG_REJESTRACJA0" AS

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
, pZAKRES_INST IN NUMBER /* 1-wybrana; 2-wszystkie; 3-ostatnia; 4-wsz. wczesniejsze do pMAX_KOLEJN*/
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

END PKG_REJESTRACJA0;
/
---------------------------
--New PACKAGE BODY
--PKG_PLAN_SPISS
---------------------------
CREATE OR REPLACE PACKAGE BODY "PKG_PLAN_SPISS" AS
 --deklaracje procedur niepublicznych
 PROCEDURE ODZYSKAJ_Z_MINUSA (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0);
 PROCEDURE USUN_PLAN_WG_BACKUPU (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0);
 FUNCTION LICZ_REKORDY(pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0) RETURN NUMBER;
 FUNCTION INFO_ZAKR RETURN VARCHAR2;
 PROCEDURE AKTUALIZUJ_LWYC (pNK_INST_NEW NUMBER, pPOZ NUMBER);
 PROCEDURE ZAPISZ_ZM_ZLEC;
 --stale
 cNR_OBR_MON CONSTANT NUMBER(3) := 99;

 --definicje
 PROCEDURE LWYC2_DO_BUFORA (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pZAKR NUMBER DEFAULT 0, pNR_OBR NUMBER DEFAULT 0, pINST NUMBER DEFAULT 0, pDANE2 VARCHAR2 DEFAULT null)
  AS
  BEGIN
   --zapis do zmiennych globalnych
   gNK_ZLEC:=pNK_ZLEC; gPOZ:=pPOZ; gZAKR:=pZAKR; gNR_OBR:=pNR_OBR; gINST:=pINST; 
   gDANE1:=case pZAKR when 1 then pNR_OBR when 2 then pINST else 0 end;
   gDANE2:=pDANE2;
   gLISTA_OBR:=LISTA_OBROBEK(pNK_ZLEC,pPOZ,pZAKR,pNR_OBR,pINST,0);
   -- WCZESNIEJ KONIECZNE SPRAWDZENIE CZY SA JUZ REKORDY W BUFORZE
   --TO DO USUN_LWYC2()
   --ZALOZENIE BLOKAD w tab PLAN_BLOK
   PLAN_BLOK_UPD (1, pNK_ZLEC, pPOZ);
   --zabezpiecznie gdyby w buforze zostaly jakies utracone rekordy 
   ODZYSKAJ_Z_MINUSA (pNK_ZLEC, pPOZ);
   --uzupelnienie brakujacych L_WYC.NRY_PORZ
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
   --zamiana procedury KOPIUJ_Z_MINUSEM na INSERT, zeby obsuzyc blad kopiowania FLAG= -1 do backup'u
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

   --sprawdzanie czy ilosc rekordów w buforze jest poprawna
   IF pNO_CHECK=0 THEN
    --przeniesc do odzielnej funkcji
    ile:=LICZ_REKORDY(pNK_ZLEC,pPOZ);
    ileBAK:=LICZ_REKORDY(-pNK_ZLEC,pPOZ);
    IF ile<>ileBAK THEN
     raise_application_error(-20000, 'Bledy w buforze Planu ['||ile||'/'||ileBAK||'] '||INFO_ZAKR);
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
--12.2018 ten update moze uzunac inf. o wykonaniu
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

PROCEDURE POPRAW_OBR_JEDNOCZ (pNK_ZLEC NUMBER, pPOZ NUMBER DEFAULT 0, pNR_OBR NUMBER default 0, pODWROTNIE NUMBER default 0) --pODWROTNIE=1 oznacza poprawe NA PODSTAWIE danych obr jednoczesnej
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
               and etap<3 -- bez montazu
               and gr_akt<>2 -- bez inst. powiaz.
               and nk_inst in (select B.nr_komp_inst --instalacje z ciagu dla 
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
    --TODO usuwanie Planu bez uzycia bufora
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
                                               --max(nr_kat) powoduje, ze zawsze bedzie 1 rekord - conajwyzej NULL
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
   --potrzeba skopiowac rekord na nowa instalacji 
   ELSIF rec1.jest_inna_obr_ma_zostac=1 and rec1.jest_juz_lwyc_na_docel=0 THEN
    rec2.nr_inst:=rec1.inst_new;
    IF rec2.zn_braku=1 THEN rec2.zn_braku:=0; END IF;
    INSERT INTO l_wyc VALUES rec2;
   --rekord do usuniecia (Merge z docelowym?) 
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
   --potrzeba skopiowac rekord na nowa instalacji 
   ELSIF jest_inna_obr_ma_zostac>0 and jest_juz_lwyc_na_docel=0 THEN
    rec2.nr_inst:=rec1.inst_new;
    IF rec2.zn_braku=1 THEN rec2.zn_braku:=0; END IF;
    INSERT INTO l_wyc VALUES rec2;
   --rekord do usuniecia (Merge z docelowym?) 
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
   AND L.nr_porz_obr not between 1501 and 1999; --pomijanie wpisów dla instalacji powiazanych, bo one moga byc dodawane/usuwane przy zmianie instalacji glównej
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

  PROCEDURE WYPELNIJ_ZMIANY(pNK_ZLEC NUMBER, pZM_OD NUMBER, pZM_DO NUMBER) AS
   BEGIN
    DELETE tmp_zmiany1;
    INSERT INTO tmp_zmiany1 (nr_komp_inst, nr_komp_zm,
                            szt, szt_zl0, szt_zl1, szt_zl_max,
                            wielk, wielk_zl0, wielk_zl1, wielk_zl_max,
                            wyd_nom, wyd_max)
     select nr_komp_inst, nr_komp_zm,
            nvl(sum(H.ilosc),0) szt, nvl(sum(decode(H.nr_komp_zlec,pNK_ZLEC,H.ilosc,0)),0) szt_zl0, 0 szt_zl1,
            (select count(1) from v_wyc2 where nr_kom_zlec=pNK_ZLEC and nr_inst_plan=nr_komp_inst) szt_zl_max,
            nvl(sum(H.wielkosc),0) wielk, nvl(sum(decode(H.nr_komp_zlec,pNK_ZLEC,H.wielkosc,0)),0) wielk_ZL0, 0 wielk_ZL1,
            (select nvl(sum(il_obr*wsp_p),0) from v_wyc2 where nr_kom_zlec=pNK_ZLEC and nr_inst_plan=nr_komp_inst) wielk_zl_max,
           max(Z.dl_zmiany*nvl(nullif(wyd_nom,0),999999)) wyd_nom, max(Z.dl_zmiany*nvl(nullif(wyd_max,0),999999)) wyd_max  --999999 jezeli wydajnosc nieustawiona(=0) tzn.ze nie ma ograniczenia
     from zmiany Z
     left join harmon H using (nr_komp_inst, nr_komp_zm)
     left join parinst I using (nr_komp_inst)
     where I.czy_czynna='TAK'
       and nr_komp_zm between pZM_OD and pZM_DO
       and Z.zatwierdz=0 and Z.dl_zmiany>0
       and nr_komp_inst in (select distinct nr_inst_plan from l_wyc2 where nr_kom_zlec=pNK_ZLEC)
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
    vZlecPlan NUMBER(10,2);   --ile zlecenia juz wpisane
    vZlecMax  NUMBER(10,2);   --ile maks. zlecenia na inst.
    vRet boolean DEFAULT true;
   BEGIN
    IF pILE_PRZEL>0 THEN
     --wielk_zl0 -ilosc zlecenia wczesniej zaplanowana na zmiane
     --wielk_zl1 -ilosc zlecenia zaplanowana na zmiane w biezacej sesji planowania
     --wielk_zl_max -calkowita ilosc zlecenia na instalacji
     SELECT nvl(max(wyd_nom-wielk+wielk_zl0-wielk_zl1),0),
            nvl(max(wyd_max-wielk+wielk_zl0),0),
            nvl(max(wielk_zl1),0),  
            nvl(max(wielk_zl_max),0)
       INTO vWolneNom, vWolneMax, vZlecPlan, vZlecMax
     FROM tmp_zmiany1
     WHERE nr_komp_inst=pINST AND nr_komp_zm=pNR_ZM;
     vRet:=vWolneNom>0/*pILE*/ or vZlecPlan>0 and vWolneMax>=vZlecMax;-- and vWolneNom-vZlecPlan>gMIN_ZL; --próba ograniczenia dzielenia - wygeneruje problem przy czesciach>pMIN_ZL
    END IF;
    --analogicznie dla szt
    IF pILE_SZT>0 THEN
     SELECT nvl(max(wyd_nom-szt+szt_zl0-szt_zl1),0),
            nvl(max(wyd_max-szt+szt_zl0),0),
            nvl(max(szt_zl1),0),  
            nvl(max(szt_zl_max),0)
       INTO vWolneNom, vWolneMax, vZlecPlan, vZlecMax
     FROM tmp_zmiany1
     WHERE nr_komp_inst=pINST AND nr_komp_zm=pNR_ZM;
     vRet:=vWolneNom>0 or vZlecPlan>0 and vWolneMax>=vZlecMax;
    END IF;
    RETURN vRet;
   END CZY_WEJDZIE; 

  FUNCTION SZUKAJ_ZMIANY(pINST NUMBER, pZM_OD NUMBER, pZM_DO NUMBER, /*pILE_GODZ NUMBER DEFAULT 0*/ pILE NUMBER, pKIERUNEK NUMBER DEFAULT 0) RETURN NUMBER --pKIERUNEK=0 szukaj wstecz   1-wprzód
   AS
    CURSOR c1 IS
      SELECT nr_komp_inst, nr_komp_zm, zmiana, zmiany.dl_zmiany, parinst.jedn
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
      --nie mozna liczyc czasu poprocesowego w odniesieniu do dlugosci aktywnych zmian
      --sumaGodz:=sumaGodz+rec.dl_zmiany;
      --EXIT WHEN sumaGodz>=pILE_GODZ;
      --ileWolne:=ILE_WOLNE(rec.nr_komp_inst, rec.nr_komp_zm,0)
--      EXIT;
      EXIT WHEN CZY_WEJDZIE(rec.nr_komp_inst, rec.nr_komp_zm, case when rec.jedn='sz' then 0 else pILE end, case when rec.jedn='sz' then 1 else 0 end);
     END LOOP;
     CLOSE c1;
     RETURN nvl(rec.nr_komp_zm,0);
   END SZUKAJ_ZMIANY;

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
     --jezeli nie ma planu pozniej
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
      NrZm:=NrZmNast-floor(czasPopr/24)*4-round(mod(czasPopr,24)/8); --zalozenie, ze 3 zmiany na dobe (3x8h)
      IF Zm<=round(mod(czasPopr,24)/8) THEN NrZm:=NrZm-1; END IF; --bo zmiana 4 nie istnieje i trzeba pomijac w liczeniu czasu
     END IF; 
     NrZm:=SZUKAJ_ZMIANY(rec1.nr_inst_plan, gZM_START, NrZm, rec1.il_przel);
          --SZUKAJ_ZMIANY(rec1.nr_inst_plan, gZM_START, NrZmNast-floor(czasPopr/24)*4-ceil(mod(czasPopr,24)/8));
          --SZUKAJ_ZMIANY(rec1.nr_inst_plan, gZM_START, NrZmNast, czasPopr);
     IF NrZM=0 THEN NrZM:=gZM_BUFOR; END IF;
     UPDATE l_wyc2
     SET nr_zm_plan=NrZm
     WHERE nr_kom_zlec=pNK_ZLEC and nr_poz_zlec=rec1.nr_poz_zlec and nr_szt=rec1.nr_szt and ELEMENT_LISTY(rec1.nry_porz,nr_porz_obr)=1;
     update tmp_zmiany1
     set szt_zl1=szt_zl1+1, wielk_zl1=wielk_zl1+rec1.il_przel
     where nr_komp_inst=rec1.nr_inst_plan and nr_komp_zm=NrZm;
    END LOOP;
    CLOSE c1;
   EXCEPTION WHEN OTHERS THEN
    ZAPISZ_LOG('PLANUJ_SZYBY1',pNK_ZLEC,'E',0);
    ZAPISZ_ERR(SQLERRM||': '||dbms_utility.FORMAT_ERROR_BACKTRACE);  
   END PLANUJ_SZYBY1; 

  --wersja zabezpiecznie dzielenia warstw z tej samej sztuki na rózne zmiany na inst. laczeniowych
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
     --jezeli nie ma planu pozniej
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
      NrZm:=NrZmNast-floor(czasPopr/24)*4-round(mod(czasPopr,24)/8); --zalozenie, ze 3 zmiany na dobe (3x8h)
      IF Zm<=round(mod(czasPopr,24)/8) THEN NrZm:=NrZm-1; END IF; --bo zmiana 4 nie istnieje i trzeba pomijac w liczeniu czasu
     END IF; 
     NrZm:=SZUKAJ_ZMIANY(rec1.nr_inst_plan, gZM_START, NrZm, rec1.il_przel);
     IF NrZM=0 THEN NrZM:=gZM_BUFOR; END IF;
     UPDATE l_wyc2
     SET nr_zm_plan=NrZm
     WHERE nr_kom_zlec=pNK_ZLEC and nr_poz_zlec=rec1.nr_poz_zlec and nr_szt=rec1.nr_szt
       --AND (ELEMENT_LISTY(rec1.nry_porz,nr_porz_obr)=1 or ELEMENT_LISTY(rec1.nry_porz,nr_porz_obr-1500)=1); --taki sam plan inst powiazanej INST_POW 
       AND ELEMENT_LISTY(rec1.nry_porz,nr_porz_obr)=1;
     update tmp_zmiany1
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
     --jezeli nie ma planu wczesniej
     IF  NrZmPoprz=0 THEN
      firstOper:=1;
      --NrZmPoprz:=NrZmFirst;
      NrZm:=NrZmFirst;
      czasPopr:=0;
      czasPoprIleZm8h:=0;
     ELSE
      --czasPopr:=CZAS_POPROC(NrInstPoprz,rec1.nr_inst_plan); --recInst.czas_poprocesowy;
      --czasPoprIleZm8h:=floor(czasPopr/24)*4+round(mod(czasPopr,24)/8); --gdy 3 zmiany na dobe (3x8h)
      NULL;
     END IF;
     --NrZm:=NrZmPoprz;
     IF czasPopr>0 THEN
      NrZm:=NrZmPoprz+czasPoprIleZm8h; 
      IF PKG_CZAS.NR_ZM_TO_ZM(NrZm)<PKG_CZAS.NR_ZM_TO_ZM(NrZmPoprz) THEN NrZm:=NrZm+1; END IF; --dodanie 1 bo zmiana 4 nie istnieje
     END IF; 
     NrZm:=SZUKAJ_ZMIANY(rec1.nr_inst_plan, NrZm, NrZmLast, rec1.il_przel,1);
     IF NrZM=0 THEN NrZM:=gZM_BUFOR; END IF;
     UPDATE l_wyc2
     SET nr_zm_plan=NrZm
     WHERE nr_kom_zlec=pNK_ZLEC and nr_poz_zlec=rec1.nr_poz_zlec and nr_szt=rec1.nr_szt and ELEMENT_LISTY(rec1.nry_porz,nr_porz_obr)=1;
     update tmp_zmiany1 
     set szt_zl1=szt_zl1+1, wielk_zl1=wielk_zl1+rec1.il_przel
     where nr_komp_inst=rec1.nr_inst_plan and nr_komp_zm=NrZm;
     -- zabezpieczenie przez dzieleniem warstw na zmiany na inst. kompletacji, niedokladnosc w TMP_ZMIANY
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
   USUN_PLAN(pNK_ZLEC);
   --PLANUJ_SZYBY1(pNK_ZLEC, pNR_ZM_KONC);
   if pNR_ZM_POCZ>0 then
    PLANUJ_SZYBY3(pNK_ZLEC, pNR_ZM_POCZ);  --wprzód
   else 
    PLANUJ_SZYBY2(pNK_ZLEC, pNR_ZM_KONC); --wstecz
   end if;

  END;

END PKG_PLAN_SPISS;
/
---------------------------
--New PACKAGE BODY
--PKG_PARAMETRY
---------------------------
CREATE OR REPLACE PACKAGE BODY "PKG_PARAMETRY" AS
 FUNCTION GET_GR_SIL_DEFAULT RETURN NUMBER AS
  BEGIN
   IF vNR_ODDZ=0 THEN 
    SELECT nr_odz INTO vNR_ODDZ FROM firma;
   END IF;
   RETURN case when vNR_ODDZ=4 THEN cGR_SIL4 else cGR_SIL_DEFAULT end;
  EXCEPTION WHEN OTHERS THEN
   RETURN -1;
  END GET_GR_SIL_DEFAULT;
END PKG_PARAMETRY;
/
---------------------------
--New PACKAGE BODY
--PKG_MAIN
---------------------------
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
---------------------------
--New PACKAGE BODY
--PKG_FOREL240
---------------------------
CREATE OR REPLACE PACKAGE BODY "PKG_FOREL240" AS
function ORD(vORD_NUM varchar2, vCUST_NUM varchar2, vCUST_NAME varchar2, vTEXT1 varchar2, vTEXT2 varchar2, vTEXT3 varchar2, 
    vTEXT4 varchar2, vTEXT5 varchar2, vPROD_DATE varchar2, vDEL_DATE varchar2, vDEL_AREA varchar2) RETURN VARCHAR2 
as
  vResult varchar2(1000);
begin
  vResult := ' ';
  vResult := 'ORD'||vSep||
    vORD_NUM||vSep||
    vCUST_NUM||vSep||
    vCUST_NAME||vSep||
    vTEXT1||vSep||
    vTEXT2||vSep||
    vTEXT3||vSep||
    vTEXT4||vSep||
    vTEXT5||vSep||
    vPROD_DATE||vSep||
    vDEL_DATE||vSep||
    vDEL_AREA;
return vResult;
end;

function pan(pITEM_NUM number, pID_NUM varchar2, pBARCODE varchar2, pPAN_QTY number, pWIDTH number, pHEIGHT number, 
    pPANE1 NUMBER, pSPACER1 NUMBER, pPANE2 NUMBER, pSPACER2 NUMBER, pPANE3 NUMBER, pSPACER3 NUMBER, pPANE4 NUMBER,
    pSEAL_INSET number, pGAS_SPACER1 number, pGAS_SPACER2 number, pGAS_SPACER3 number,
    pSEAL_CODE number, pSPACER_TYPE number, pSPACER_HEIGHT number, pSHAPE number, pHEAVY_PANE number, pRACK_INFO varchar2,
    pIG_PANE_REVERSE number) return varchar2
as
  vResult varchar2(1000);
begin
  vResult := ' ';

  vResult := 'PAN'||vSep||
    pITEM_NUM||vSep||
    pID_NUM||vSep||
    pBARCODE||vSep||
    pPAN_QTY||vSep||
    pWIDTH*10||vSep||
    pHEIGHT*10||vSep||
    pPANE1||vSep||
    pSPACER1||vSep||
    pPANE2||vSep||
    pSPACER2||vSep||
    pPANE3||vSep||
    pSPACER3||vSep||
    pPANE4||vSep||
    pSEAL_INSET||vSep||
    pGAS_SPACER1||vSep||
    pGAS_SPACER2||vSep||
    pGAS_SPACER3||vSep||
    pSEAL_CODE||vSep||
    pSPACER_TYPE||vSep||
    pSPACER_HEIGHT||vSep||
    pSHAPE||vSep||
    pHEAVY_PANE||vSep||
    pRACK_INFO||vSep||
    pIG_PANE_REVERSE||vSep;
  return vResult;
end;

function ver(pUNIT number) RETURN VARCHAR2 
as
  vResult varchar2(1000);
  vVER_NUM varchar2(6);
  vSep char;
begin
  vResult := ' ';
  vSep := '|';

  vVER_NUM := '02.40';

  vResult := 'VER'||vSep||
    vVER_NUM||vSep||
    pUNIT;
return vResult;
end;

function shp(pSHP_PATH varchar2, pSHP_FILE varchar2, pSHP_NAME varchar2, pSHP_CAT number, pSHP_NUM number,
  pSHP_L number, pSHP_L1 number, pSHP_L2 number, pSHP_H number, pSHP_H1 number, pSHP_H2 number, 
  pSHP_R number, pSHP_R1 number, pSHP_R2 number, pSHP_R3 number, pSHP_MIRR number, pSHP_BASE number) RETURN VARCHAR2 
as
  vResult varchar2(1000);
begin
  vResult := ' ';

  vResult := 'SHP'||vSep||
    pSHP_PATH||vSep||
    pSHP_FILE||vSep||
    pSHP_NAME||vSep||
    pSHP_CAT||vSep||
    pSHP_NUM||vSep||
    pSHP_L*10||vSep||
    pSHP_L1*10||vSep||
    pSHP_L2*10||vSep||
    pSHP_H*10||vSep||
    pSHP_H1*10||vSep||
    pSHP_H2*10||vSep||
    pSHP_R*10||vSep||
    pSHP_R1*10||vSep||
    pSHP_R2*10||vSep||
    pSHP_R3*10||vSep||
    pSHP_MIRR||vSep||
    pSHP_BASE;
return vResult;
end;

function cm(pPaneNo number, pPANE_DESCRIPT varchar2, pID_NUM varchar2, pPANE_BARCODE varchar2, pPANE_TYPE number, pPANE_CODE varchar2,
    pPANE_THICKNESS number, pPANE_WIDTH number, pPANE_HEIGHT number, pPANE_FACESIDE number, pPANE_RACK_INFO varchar2,
    pSP_DESCRIPT varchar2, pSP_TYPE number, pSP_CODE varchar2, pSP_WIDTH number, pSP_HEIGHT number, pSP_INSET number,
    pSP_RACK_INFO varchar2, pSP_GASCODE number, pSP_SEAL_TYPE number) RETURN VARCHAR2 
as
  vResult varchar2(1000);
begin
  vResult := 'CM'||pPaneNo||vSep||
    pPANE_DESCRIPT||vSep||
    pID_NUM||vSep||
    pPANE_BARCODE||vSep||
    pPANE_TYPE||vSep||
    pPANE_CODE||vSep||
    pPANE_THICKNESS||vSep||
    pPANE_WIDTH*10||vSep||
    pPANE_HEIGHT*10||vSep||
    pPANE_FACESIDE||vSep||
    pPANE_RACK_INFO||vSep||
    pSP_DESCRIPT||vSep||
    pSP_TYPE||vSep||
    pSP_CODE||vSep||
    pSP_WIDTH||vSep||
    pSP_HEIGHT||vSep||
    pSP_INSET||vSep||
    pSP_RACK_INFO||vSep||
    pSP_GASCODE||vSep||
    pSP_SEAL_TYPE||vSep;
return vResult;
end;

function txt(pTXT varchar2) RETURN VARCHAR2 
as
  vResult varchar2(1000);
begin
  vResult := 'PRO'||vSep||vSep||vSep||'1'||vSep||vSep||vSep||vSep||vSep||vSep||vSep||vSep||vSep||vSep||vSep||'Printing Text'||vSep||pTxt||vSep;
  return vResult;
end;


end;
/
---------------------------
--New PACKAGE BODY
--PKG_CZAS
---------------------------
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
 WHEN OTHERS THEN RAISE_APPLICATION_ERROR(-20099,'NIEKRESLONY BLAD'); 
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
 WHEN OTHERS THEN RAISE_APPLICATION_ERROR(-20099,'NIEKRESLONY BLAD'); 
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
 RETURN GPocz; --zwracana wartosc DATE = 1.dzien biezacego miesiaca + godzina wg PARINST
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
 RETURN GPocz; --zwracana wartosc DATE = 1.dzien biezacego miesiaca + godzina wg PARINST
END GODZ_KONC_ZM;

END PKG_CZAS;
/
---------------------------
--New FUNCTION
--ZNAJDZ_PODOBNE_ZLEC
---------------------------
CREATE OR REPLACE FUNCTION "ZNAJDZ_PODOBNE_ZLEC" (pFUN NUMBER, pSTR1 VARCHAR2, pSTR2 VARCHAR2) RETURN NUMBER
AS
BEGIN
  IF pFUN<3 THEN RETURN 0;
  ELSE
   RETURN case when upper(USUN_ZNAKI_SPEC(pSTR1,1,1,1))=upper(USUN_ZNAKI_SPEC(pSTR2,1,1,1)) then 1 else 0 end;
  END IF;
EXCEPTION WHEN OTHERS THEN 
 RETURN 0;
END ZNAJDZ_PODOBNE_ZLEC;
/
---------------------------
--New FUNCTION
--WYLICZ_NR_KOM
---------------------------
CREATE OR REPLACE FUNCTION "WYLICZ_NR_KOM" (pKOM_POCZ NUMBER, pKOM_KONC NUMBER, pILOSC NUMBER, pNR_SZT NUMBER) RETURN NUMBER
AS
BEGIN
 RETURN case when pKOM_POCZ=pKOM_KONC then pKOM_POCZ
             when pKOM_KONC-pKOM_POCZ+1=pILOSC then pKOM_POCZ+pNR_SZT-1         --1 szyba w komorze
             when (pKOM_KONC-pKOM_POCZ+1)*2>=pILOSC then pKOM_POCZ+floor((pNR_SZT-1)*1/2)   --2 szyby w komorze
             when (pKOM_KONC-pKOM_POCZ+1)*3>=pILOSC then pKOM_POCZ+floor((pNR_SZT-1)*1/3) --3 szyby w komorze
             else 0 end;
END WYLICZ_NR_KOM;
/
---------------------------
--New FUNCTION
--WSP_WG_TYPU_INST
---------------------------
CREATE OR REPLACE FUNCTION "WSP_WG_TYPU_INST" (pTYP_INST VARCHAR2, pWSP_12ZAKR NUMBER, pWSP_C_M NUMBER, pWSP_HAR NUMBER, pWSP_HO NUMBER, pWSP_DOD NUMBER, pZNAK_DOD CHAR, pWSP_CENY NUMBER DEFAULT 1)
--/*wazne dla HAR - WSP_HO*/ pNK_ZLEC NUMBER DEFAULT 0, pPOZ NUMBER DEFAULT 0, pETAP NUMBER DEFAULT 0, pWAR_OD NUMBER DEFAULT 0, pZT CHAR DEFAULT 'Z') 
RETURN NUMBER AS
 vWsp NUMBER(7,4) :=0;
 vWsp_dla_MON NUMBER(7,4) DEFAULT 1;
BEGIN
 IF pTYP_INST='MON' and false THEN  --wylaczanie 4.01.2021
  SELECT case when nr_wdr=5 then pWSP_CENY else 1 end
    INTO vWsp_dla_MON
  FROM firma;  
 END IF;
 vWsp :=
  CASE
    WHEN trim(pTYP_INST)='A C' THEN pWSP_12ZAKR*pWSP_C_M*pWSP_DOD
    WHEN trim(pTYP_INST)='SZP' THEN pWSP_12ZAKR*pWSP_C_M
    WHEN trim(pTYP_INST)='HAR' THEN pWSP_12ZAKR*(pWSP_HAR + pWSP_HO)
    WHEN trim(pTYP_INST)='MON' THEN pWSP_12ZAKR*vWsp_dla_MON
    ELSE CASE trim(pZNAK_DOD) WHEN '*' THEN pWSP_12ZAKR*pWSP_DOD WHEN '/' THEN pWSP_12ZAKR/pWSP_DOD WHEN '+' THEN pWSP_12ZAKR+pWSP_DOD WHEN '-' THEN pWSP_12ZAKR-pWSP_DOD ELSE pWSP_12ZAKR END
  END;
 RETURN Round(nvl(vWsp,1),4);
END WSP_WG_TYPU_INST;
/
---------------------------
--New FUNCTION
--WSP_HO
---------------------------
CREATE OR REPLACE FUNCTION "WSP_HO" (pZRODLO CHAR, pNK_ZLEC NUMBER, pPOZ NUMBER, pETAP NUMBER, pWAR NUMBER) RETURN NUMBER
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
---------------------------
--New FUNCTION
--WSP_4ZAKR
---------------------------
CREATE OR REPLACE FUNCTION "WSP_4ZAKR" (pNK_INST IN NUMBER, pPOW IN NUMBER, pIDENT_BUD IN VARCHAR2, pNR_ZEST IN NUMBER DEFAULT 0) RETURN NUMBER AS
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
---------------------------
--New FUNCTION
--USUN_ZNAKI_SPEC
---------------------------
CREATE OR REPLACE FUNCTION "USUN_ZNAKI_SPEC" (pSTR VARCHAR2, czyLIT NUMBER, czyCYF NUMBER, czyKONW NUMBER, listaZNAKOW VARCHAR2 DEFAULT null)
 RETURN VARCHAR2
AS
 c CHAR(1);
 we VARCHAR2(4000);
 ret VARCHAR2(4000):='';
BEGIN
  we:=pSTR;
  IF czyKONW>0 THEN 
     we:=translate(we,'ACELNÓSZZacelnószz','ACELNOSZZacelnoszz');
  END IF;   
  FOR i IN 1..length(we) 
  LOOP
    c:=substr(we,i,1);
    IF czyCYF>0 AND ASCII(c) between 48 and 57 OR
       czyLIT>0 AND ASCII(c) between 65 and 90 OR
       czyLIT>0 AND ASCII(c) between 97 and 122 OR
       czyLIT>0 AND UPPER(c) in ('A','C','E','L','N','Ó','S','Z','Z') OR
       instr(listaZNAKOW,c)>0
     THEN
       ret := ret||c;
    END IF;
   END LOOP;
  RETURN ret;
EXCEPTION WHEN OTHERS THEN 
 RETURN 0;
END USUN_ZNAKI_SPEC;
/
---------------------------
--New FUNCTION
--STRTOKENN
---------------------------
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
      return to_number(nvl(strtoken(trim(the_list),the_index,delim),'0'),format);
  else
      return to_number(replace(nvl(strtoken(trim(the_list),the_index,delim),'0'),sep10,'.'),format);
  end if;
end strtokenN;
/
---------------------------
--New FUNCTION
--STRTOKEN
---------------------------
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
---------------------------
--New FUNCTION
--STRONA_POWLOKI_OBROT
---------------------------
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
---------------------------
--New FUNCTION
--STR_INFO
---------------------------
CREATE OR REPLACE FUNCTION "STR_INFO" (pNR_STR NUMBER, pINFO_TYP VARCHAR2) RETURN NUMBER
AS
 vNum NUMBER(14,4);
BEGIN


 IF PINFO_TYP='GRUB' THEN
   SELECT sum(grub*decode(rodz_sur,'FOL',wsp,1)) INTO vNum
   FROM v_str_sur1
   WHERE nr_kom_str=pNR_STR;
 ELSIF PINFO_TYP LIKE 'GRUB-%' THEN
   SELECT sum(grub*decode(rodz_sur,'FOL',wsp,1)) INTO vNum
   FROM v_str_sur1
   WHERE nr_kom_str=pNR_STR AND rodz_sur=substr(pINFO_TYP,6);
 ELSIF pINFO_TYP='WSP-GRUB-TAF' THEN
   Select nvl(max(to_number(replace(wartosc,',','.'),'9.99')),0.25)
   Into vNum
   From param_t Where kod=109;
   SELECT sum(1+(grub-4)*vNum) INTO vNum
   FROM v_str_sur1
   WHERE nr_kom_str=pNR_STR AND rodz_sur='TAF';
 END IF;

 RETURN vNum; 
END;
/
---------------------------
--New FUNCTION
--SPRAWDZ_REJESTR
---------------------------
CREATE OR REPLACE FUNCTION "SPRAWDZ_REJESTR" 
(pNR_SER IN NUMBER,
 pUWZGL_BRAKI IN NUMBER
) RETURN NUMBER AS
 vNR_KOM_ZLEC l_wyc.nr_kom_zlec%TYPE;
 vNR_POZ_ZLEC l_wyc.nr_poz_zlec%TYPE;
 vNR_SZT      l_wyc.nr_szt%TYPE;
 vBEZ_REJESTR NUMBER;
BEGIN
 Select nr_komp_zlec,nr_poz,nr_szt into vNR_KOM_ZLEC,vNR_POZ_ZLEC,vNR_SZT from spise where nr_kom_szyby=pNR_SER;
 /*sprawdzanie tylko bie??cego zlecenia*/
 IF (pUWZGL_BRAKI=0) then
  SELECT SPRAWDZ_LWYC(vNR_KOM_ZLEC,vNR_POZ_ZLEC,vNR_SZT,0,0,0) into  vBEZ_REJESTR FROM DUAL;
 /*sprawdzanie wg najwy?szego kodu - nie dziaa poprawnie, gdy brak na ost. instalacji*/
 ELSIF (pUWZGL_BRAKI=1) then
  SELECT count(1) into vBEZ_REJESTR
  FROM (
   SELECT Z.nr_zlec,nr_poz_zlec,LW.nr_szt,LW.nr_warst,LW.nr_inst nrk_inst,LW.kolejn kolej,LW.zn_braku,LW.zn_stoj, LW.nr_ser,LW.typ_kat, LW.rodz_sur,
         (case when I.ty_inst<>'MON' then LW.d_wyk
                                     else (select data_wyk from spise where nr_kom_szyby=pNR_SER)
          end) data_wyk,
         I.nr_inst,I.naz_inst
   FROM (
    select nr_kom_zlec, nr_poz_zlec, nr_szt, nr_warst, nr_inst, kolejn, zn_braku, zn_stoj, nr_ser, d_wyk, typ_kat, rodz_sur
    from l_wyc where nr_ser in (select max(nr_ser) from l_wyc
                                where nr_kom_zlec=vNR_KOM_ZLEC and nr_poz_zlec=vNR_POZ_ZLEC and nr_szt=vNR_SZT
                                group by nr_warst)) LW,
    zamow Z, parinst I
   WHERE LW.nr_kom_zlec=Z.nr_kom_zlec and LW.nr_inst=I.nr_komp_inst)
  WHERE data_wyk<to_date('2001/01/01','YYYY/MM/DD');
 /*sprawdzanie wszystkich rekord?w braku i wyj?ciowego*/
 ELSIF (pUWZGL_BRAKI=2) then
  /*Select nr_kom_szyby, nr_war, sprawdz_lwyc(nr_komp_zlec,nr_poz,nr_szt,war,inst_pow,czy_brak) niewyk*/
  Select sum(sprawdz_lwyc(nr_komp_zlec,nr_poz,nr_szt,
                          case when war=0 and czy_brak=0 and typ_poz in ('cie','str') then 1 else war end,
                          nk_inst,czy_brak)) into vBEZ_REJESTR
  From
  (select E.nr_kom_szyby, E.nr_komp_zlec,E.nr_poz,E.nr_szt, B1.nr_war,
       case when inst_pow is null then 0 else inst_pow end nk_inst,
       case when B1.nr_war is null
              or lag(B1.nr_war,rownum-1,B1.nr_war) over (order by 1,5)=0
             and lag(id_poz_br,rownum-1,id_poz_br) over (order by 1,5)<id_poz_br
            then 0 else B1.nr_war end war, P.typ_poz,
       0 czy_brak
   from spise E
   left join
    (select nr_kom_szyby, nr_war, min(id_poz_br) id_poz_br from braki_b group by nr_kom_szyby, nr_war) B1
    on B1.nr_kom_szyby=E.nr_kom_szyby
   left join braki_b B2 using(id_poz_br)
   left join spisz P on P.nr_kom_zlec=E.nr_komp_zlec and P.nr_poz=E.nr_poz
   where E.nr_kom_szyby=pNR_SER
  union
   select B.nr_ser_br,E.nr_komp_zlec,E.nr_poz,E.nr_szt,0,0,0,'',1 czy_brak from braki_b B
   left join spise E on E.nr_kom_szyby=nr_ser_br
   where B.nr_kom_szyby=pNR_SER
  order by 1,5);
 END IF;

 if vBEZ_REJESTR>0 then RETURN 0;
                   else RETURN 1;
 end if;

END SPRAWDZ_REJESTR;
/
---------------------------
--New FUNCTION
--SPRAWDZ_LWYC
---------------------------
CREATE OR REPLACE FUNCTION "SPRAWDZ_LWYC" 
(pNR_KOM_ZLEC IN NUMBER,
 pNR_POZ_ZLEC IN NUMBER,
 pNR_SZT IN NUMBER,
 pNR_WAR IN NUMBER,
 pNR_INST IN NUMBER,
 pDO_BRAKU IN NUMBER
) RETURN NUMBER AS
 vKOLEJN parinst.kolejn%TYPE;
 vIL_BEZ_REJESTR NUMBER;
BEGIN
 if (pNR_WAR>0) and (pNR_INST>0) then
  select kolejn into vKOLEJN from parinst where nr_komp_inst=pNR_INST;
 end if;

 SELECT count(1) into vIL_BEZ_REJESTR
 FROM l_wyc
 WHERE nr_kom_zlec=pNR_KOM_ZLEC AND nr_poz_zlec=pNR_POZ_ZLEC AND nr_szt=pNR_SZT
   AND typ_inst not in ('MON','STR')
   /*sprawdzanie wg nr_inst i nr_warst (gdy powstal w tym miejscu brak, ta i dalsze instalacje nie wliczaj? sie)*/
   AND (pDO_BRAKU>0 or (pNR_WAR=0 or nr_warst=pNR_WAR) and (pNR_WAR=0 or pNR_INST=0 or kolejn<vKOLEJN or zn_braku=8))
   /*sprawdzanie wg zn_braku*/
   AND (pDO_BRAKU=0 or zn_braku in (0,7))
   AND D_WYK<to_date('2001/01/01','YYYY/MM/DD');

 RETURN vIL_BEZ_REJESTR;
END SPRAWDZ_LWYC;
/
---------------------------
--New FUNCTION
--SPISE_VS_WZ_ERR
---------------------------
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
         (select count(1) from pozdok where typ_dok in ('WP','WZ') and nr_komp_baz=nr_komp_zlec and nr_poz_zlec=spise.nr_poz and storno=0 and kol_dod=0) il_poz_WZ
  from spise
  where nr_komp_zlec=pNR_KOMP_ZLEC  and (pNR_POZ=0 or nr_poz=pNR_POZ)
  group by nr_komp_zlec, nr_poz, nr_sped, nr_k_WZ, nr_poz_WZ
  order by 1,2,3
 ) e
 Left join pozdok on typ_dok in ('WP','WZ') and nr_komp_dok=nr_k_WZ and pozdok.nr_poz=nr_poz_WZ and nr_komp_baz=nr_komp_zlec and nr_poz_zlec=e.nr_poz and storno=0 and kol_dod=0
 Where 
    --blad gdy szyby sa w spedycjach i nie maja przypisanego WZ a WZ istnieja
    nr_sped>0 and nvl(ilosc_jr,0)<>il and (il_poz_WZ>1 or il_poz_WZ=1 and ilosc_jr is null)
    --szyby bez spedycji moga miec WZ, ale pod warunkiem ze cala pozycja ma nr_k_WZ>0
    or nr_sped=0 and nvl(ilosc_jr,0)>0 and (select count(1) from spise where nr_komp_zlec=e.nr_komp_zlec and nr_poz=e.nr_poz and nr_k_WZ=0)>0;

 RETURN ile_poz;
END SPISE_VS_WZ_ERR;
/
---------------------------
--New FUNCTION
--REP_STR
---------------------------
CREATE OR REPLACE FUNCTION "REP_STR" (STR1 IN VARCHAR2, STR_NEW IN VARCHAR2, POS_FROM IN NUMBER) 
RETURN VARCHAR2 AS 
BEGIN
  --zastepuje w STR1 fragment od znaku nr POS_FROM ciagiem STR_NEW
  RETURN substr(STR1,1,POS_FROM-1)||STR_NEW||substr(STR1,POS_FROM+length(STR_NEW),length(STR1)-(POS_FROM-1)-length(STR_NEW));
END REP_STR;
/
---------------------------
--New FUNCTION
--RAMKA_NAPIS_KLUCZE
---------------------------
CREATE OR REPLACE FUNCTION "RAMKA_NAPIS_KLUCZE" (p_NrKompZlec in NUMBER, p_NrPoz in NUMBER, p_NrSzt in NUMBER, p_NrWar in NUMBER)
   return varchar2
is
   vResult    varchar2(1000);
   v_col_name varchar2(100);
   v_col_type varchar2(30);
   v_col     varchar2(1000);
   cursor c_col is select column_name,data_type from ALL_TAB_COLS where TABLE_NAME='V_RAMKA_NAPIS_KLUCZE' and owner in (select sys_context( 'userenv', 'current_schema' ) from dual);
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
      query_str := 'select '||rec_col.column_name||' from V_RAMKA_NAPIS_KLUCZE where nr_komp_zlec=:zlec and nr_poz=:poz and nr_szt=:szt and nr_war=:war';
      OPEN c FOR query_str USING p_NrKompZlec,p_NrPoz,p_NrSzt,p_NrWar;
      LOOP
          FETCH c INTO v_col;
          EXIT WHEN c%NOTFOUND;
          if not pierwszy then 
            vResult := vResult || Chr(9); 
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
end RAMKA_NAPIS_KLUCZE;
/
---------------------------
--New FUNCTION
--RAMKA_NAPIS
---------------------------
CREATE OR REPLACE FUNCTION "RAMKA_NAPIS" (p_NrZlec in NUMBER, p_NrPoz in NUMBER, p_NrSzt in NUMBER, p_NrWar in NUMBER, p_Pattern in VARCHAR2)
   return varchar2
is
   vResult    varchar2(1000);
   vFixText varchar2(1000);
   vWidth number;
   vHeight number;
begin
  vResult := '';  

  select napis into vFixText from napisy_szyb_warstwy where nr_kom_zlec=(select nr_kom_zlec from zamow 
    where nr_zlec=p_NrZlec and typ_zlec='Pro') and nr_poz=p_NrPoz
    and nr_szt=p_NrSzt
    and nr_war=p_nrWar;
  select szer,wys into vWidth,vHeight from spisz 
    where nr_kom_zlec=(select nr_kom_zlec from zamow where nr_zlec=p_NrZlec and typ_zlec='Pro') 
    and nr_poz=p_NrPoz;

  vResult := p_Pattern;
  vResult := REPLACE(vResult,'%FIXTEXT%',vFixText);
  vResult := REPLACE(vResult,'%WIDTH%',vWidth);
  vResult := REPLACE(vResult,'%HEIGHT%',vHeight);
  vResult := REPLACE(vResult,'%DATE%',to_char(sysdate,'DD-MM-YYYY'));

  return vResult;
--  EXCEPTION WHEN OTHERS THEN
--    IF c_col%ISOPEN THEN CLOSE c_col; END IF;
end RAMKA_NAPIS;
/
---------------------------
--New FUNCTION
--QUERY2LIST
---------------------------
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
---------------------------
--New FUNCTION
--POZ_INFO
---------------------------
CREATE OR REPLACE FUNCTION "POZ_INFO" (pNK_ZLEC NUMBER, pNR_POZ NUMBER, pNR_WAR NUMBER, pINFO_TYP VARCHAR2) RETURN NUMBER
AS
 vNum NUMBER(14,4):=0;
 vLinia VARCHAR(500);
BEGIN
 IF pINFO_TYP in ('POW_RZECZ','WAGA_RZECZ','OBW_RZECZ') THEN 
  IF pNR_WAR>0 THEN 
   select max(linia) into vLinia
   from zlec_typ
   where nr_komp_zlec=pNK_ZLEC and nr_poz=pNR_POZ and typ=NR_ZLECTYP(pNR_WAR);
   if vLinia is not null then
    vLinia:=case when instr(vLinia,'|',1,2)>0                      --dane jako 3. strtoken (nowy zapis)
                 then trim(strtoken(vLinia,3,'|'))                 --0:0;0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:;|0:0;0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:;|    0,9271;     0,0399;     0,0000;
                 when instr(vLinia,' ',INSTR(vLinia, ';' , 1, 3))>0 --0:0;0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:;|0:0;0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:;     0,9271;     0,0399;     0,0000;
                 then trim(substr(vLinia,instr(vLinia,' ',INSTR(vLinia, ';' , 1, 3))))
                 else null
            end;
    vNum:=case pINFO_TYP 
               when 'POW_RZECZ' then strtokenN(trim(vLinia),1,';','9999.9999',',')
               when 'WAGA_RZECZ' then strtokenN(trim(vLinia),2,';','9999.9999',',')
               when 'OBW_RZECZ' then strtokenN(trim(vLinia),3,';','9999.9999',',')
               else 0 end;
   end if;
  END IF; --pNR_WAR>0
  IF vNum=0 AND pNR_WAR=0 THEN
    select max(linia) into vLinia --0|0:0|196658|1;3,284;81,279;8,164;|
    from zlec_typ
    where nr_komp_zlec=pNK_ZLEC and nr_poz=pNR_POZ and typ=13;
    --if vLinia is not null and (to_number(substr(vLinia,1,1))>0 or pNR_WAR=0) then
    if vLinia is not null and to_number(substr(vLinia,1,1))>0 then
     vLinia:=trim(strtoken(vLinia,4,'|'));
     vNum:=case pINFO_TYP 
           when 'POW_RZECZ' then strtokenN(trim(vLinia),2,';','9999.9999',',')
           when 'WAGA_RZECZ' then strtokenN(trim(vLinia),3,';','9999.9999',',')
           when 'OBW_RZECZ' then strtokenN(trim(vLinia),4,';','9999.9999',',')
           else 0 end;
    end if;
  ELSIF vNum=0 AND pNR_WAR>0 THEN
     for d in (select szer_obr*0.001*wys_obr*0.001 pow, 2*szer_obr*0.001+2*wys_obr*0.001 obw, katalog.waga
               from spisd left join katalog using (nr_kat)
               where nr_kom_zlec=pNK_ZLEC and nr_poz=pNR_POZ and do_war=pNR_WAR and strona=0
                 and katalog.rodz_sur in ('TAF','LIS','POL') )
      loop
       vNum:=case pINFO_TYP 
             when 'POW_RZECZ' then d.pow
             when 'WAGA_RZECZ' then d.waga*d.pow
             when 'OBW_RZECZ' then d.obw
             else 0 end;
      end loop;
  END IF;
  IF vNum=0 then
   for p in (select pow, obw, pow*waga waga
             from spisz left join struktury using (kod_str)
             where nr_kom_zlec=pNK_ZLEC and nr_poz=pNR_POZ)
    loop
     vNum:=case pINFO_TYP 
                when 'POW_RZECZ' then p.pow
                when 'WAGA_RZECZ' then p.waga
                when 'OBW_RZECZ' then p.obw
                else 0 end;
    end loop;
  END IF;
 END IF;
 RETURN vNum;
EXCEPTION WHEN OTHERS THEN
 RETURN 0;
END POZ_INFO;
/
---------------------------
--New FUNCTION
--POWLOKAAKTYWNA_WAR
---------------------------
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
---------------------------
--New FUNCTION
--PAR_KSZ_DOCEL
---------------------------
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
---------------------------
--New FUNCTION
--PAR_KSZ_DC
---------------------------
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
---------------------------
--New FUNCTION
--OPIS_KSZTALTU
---------------------------
CREATE OR REPLACE FUNCTION "OPIS_KSZTALTU" (pTYP13 VARCHAR2, pTYP15 VARCHAR2 default null)
RETURN VARCHAR2
 AS
 TYPE tab IS TABLE OF VARCHAR2(8);
  opisy tab;
 par NUMBER(6,1); 
 wynik VARCHAR2(1000); 
BEGIN
 opisy := tab ('Nr kat','Nr kszt','L','L1','L2','H','H1','H2','R','R1','R2','R3','T1','T2','T3','T4');
 --return to_char(strtokenN(pTYP13,2,':','999'));
 IF strtokenN(pTYP13,2,':','9999')=0 THEN 
  return ' ';
 END IF;
 wynik:=opisy(2)||':'||strtokenN(pTYP13,2,':','9999')||'/'||strtokenN(pTYP13,1,':','9');
 FOR i IN 3..16
  LOOP
   par:=strtokenN(pTYP13,i,':','9999');
   IF par>0 THEN
    wynik:=wynik||' '||opisy(i)||':'||trim(to_char(par));
   END IF; 
  END LOOP;
  return wynik;
END OPIS_KSZTALTU;
/
---------------------------
--New FUNCTION
--OBR0
---------------------------
CREATE OR REPLACE FUNCTION "OBR0" (pNK_INST NUMBER default 0, pTYP_INST CHAR default null, pNK_ZLEC NUMBER default null, pNR_POZ NUMBER default null, pNR_WAR NUMBER default null, pKOD_LAMINATU VARCHAR2 default null) RETURN NUMBER
AS
 vStr VARCHAR2(128);
 vRet NUMBER(6):=0;
BEGIN
 IF pTYP_INST='MON' THEN
   Select nvl(min(nr_kat),0) Into vRet From katalog Where typ_kat='MON';
 ELSIF pTYP_INST IN ('A C','R C') THEN
   Select nvl(min(nr_kat),0) Into vRet From katalog Where typ_kat='R';
 ELSIF pKOD_LAMINATU is not null THEN
   FOR i IN 1..100
    LOOP
     vStr:=strtoken(pKOD_LAMINATU,i,'\');
     IF REGEXP_LIKE(vStr,'X\d{1,2}') THEN
      vRet:=vRet+to_number(substr(vStr,2));
     END IF; 
     EXIT WHEN trim(vStr) is null;
    END LOOP;
   Select nvl(min(nr_kat),-vRet) Into vRet From katalog Where typ_kat='X'||vRet; 
 ELSE 
   Select nvl(min(nr_komp_obr),0) Into vRet
   From spisd
   Where nr_kom_zlec=pNK_ZLEC And nr_poz=pNR_POZ And do_war=pNR_WAR And strona>0 And nr_komp_obr>0
     And exists (select 1 from wykzal where nr_komp_instal=pNK_INST and wykzal.nr_komp_obr=spisd.nr_komp_obr);
 END IF;
 RETURN vRet;
EXCEPTION WHEN OTHERS THEN
 RETURN 0;
END OBR0;
/
---------------------------
--New FUNCTION
--NR_ZLECTYP
---------------------------
CREATE OR REPLACE FUNCTION "NR_ZLECTYP" (p_nr_war IN NUMBER)
RETURN NUMBER AS 
BEGIN
  --zwraca nr zlec_typ w celu wyciagniecia parametrAlw podanej wartswy
  RETURN case when p_nr_war between 1 and 5 then 15+p_nr_war-1
               when p_nr_war between 6 and 20 then 35+p_nr_war-6
               else 0 end;
END NR_ZLECTYP;
/
---------------------------
--New FUNCTION
--NR_INST_NAST
---------------------------
CREATE OR REPLACE FUNCTION "NR_INST_NAST" (pNK_ZLEC NUMBER, pPOZ NUMBER, pWAR NUMBER, pSZT NUMBER, pKOLEJN NUMBER) RETURN NUMBER IS
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
---------------------------
--New FUNCTION
--LISTA_ZLEC_POWIAZ
---------------------------
CREATE OR REPLACE FUNCTION "LISTA_ZLEC_POWIAZ" (pNK_ZLEC NUMBER, pFUN NUMBER DEFAULT 0, pPOLP NUMBER DEFAULT 1, pBRAKI NUMBER DEFAULT 1)
 RETURN VARCHAR2 AS
 vWew VARCHAR2(10000);
 vBraki VARCHAR2(10000);
 vNk NUMBER(10);
 vWyr CHAR(1);
 vLista VARCHAR2(10000);
BEGIN
 --czy zlecenie jest Wewnetrzne albo Braki 
 SELECT max(P.nr_komp_zlec), max(Z.wyroznik) INTO vNk, vWyr
 FROM zamow Z
 LEFT JOIN zlec_polp P ON Z.typ_zlec='Pro' and Z.nr_zlec=P.nr_zlec_wew
 WHERE Z.nr_kom_zlec=pNK_ZLEC;

 IF pPOLP>0 THEN
  vLista:=case when vNk is not null
               then vNk||','||pNK_ZLEC
               else to_char(pNK_ZLEC) end;
  --czy do zlecenia wygenerowano zlecenia Wewnetrzne
  SELECT listagg(nr_kom_zlec,',') within group (order by nr_kom_zlec) INTO vWew
  FROM (SELECT DISTINCT Z.nr_kom_zlec
        FROM zlec_polp P
        LEFT JOIN zamow Z ON Z.typ_zlec='Pro' and Z.nr_zlec=P.nr_zlec_wew
        WHERE P.nr_komp_zlec=pNK_ZLEC AND P.nr_zlec_wew>0);
  vLista:=vLista||
          case when vWew is not null
               then ','||vWew
               else '' end;
 END IF;
 --jesli zlecenie Braki to szukanie zródlowego
 IF pBRAKI>0 AND vWyr='B' THEN
  SELECT Listagg(nr_zlec,',') Within Group (Order by nr_zlec) INTO vBraki
  FROM (Select distinct nr_zlec From braki_b
        Where zlec_braki=pNK_ZLEC
       ); 
  IF vBraki is not null THEN
   vLista:=vBraki||','||vLista;
  END IF;
  --szukanie czy do zlecenia powstay zlecenia braków
 ELSIF pBRAKI>0 THEN             
  EXECUTE IMMEDIATE
  'SELECT Listagg(zlec_braki,'','') Within Group (Order by zlec_braki)
   FROM (Select distinct zlec_braki From braki_b
         Where braki_b.nr_zlec in ('||vLista||') And zlec_braki>0'||
  '     )' 
  INTO vBraki; 
  IF vBraki is not null THEN
   vLista:=vLista||','||vBraki;
  END IF;
 END IF;
 --vLista zawiera numery komp. - zamiana na numery zwykle i wyrzucenie z listy zlecenia wejsciowego
 IF pFUN>0 THEN
  EXECUTE IMMEDIATE
  'SELECT ListAgg(wyroznik||nr_zlec,'','') Within Group (order by lp)
   FROM (select wyroznik, nr_zlec, instr('',''||'''||vLista||'''||'','',to_char(nr_kom_zlec)) lp
         from zamow where typ_zlec=''Pro'' and nr_kom_zlec<>:1 and nr_kom_zlec in ('||vLista||')
        )'
  INTO vLista
  USING pNK_ZLEC;
 END IF;
 RETURN vLista;
EXCEPTION WHEN OTHERS THEN
 RETURN 'ERR'||pNK_ZLEC||' '||SQLERRM;
END LISTA_ZLEC_POWIAZ;
/
---------------------------
--New FUNCTION
--KOD_LAMINATU2
---------------------------
CREATE OR REPLACE FUNCTION "KOD_LAMINATU2" (pNR_KOM_STR NUMBER, pNR_WAR NUMBER) RETURN VARCHAR2
AS
 CURSOR c1
  IS select listagg(typ_kat,'\') within group (order by lp)
     from spiss_vlam
     where nr_kom_str=pNR_KOM_STR
       and pNR_WAR between war_od and war_do;
 vKod VARCHAR2(128);
BEGIN
 OPEN c1;
 FETCH c1 INTO vKod;
 CLOSE c1;
 RETURN vKod;
END;
/
---------------------------
--New FUNCTION
--KOD_LAMINATU
---------------------------
CREATE OR REPLACE FUNCTION "KOD_LAMINATU" (pNR_KOM_STR NUMBER, pNR_WAR_OD NUMBER, pNR_WAR_DO NUMBER) RETURN VARCHAR2
AS
 CURSOR c1
-- ORACLE 10 or higher
  IS select listagg(typ_kat,'\') within group (order by lp)
--  IS select typ_kat
     from spiss_str
     where zrodlo='S' and nr_komp_zr=pNR_KOM_STR and nr_kol=1
       and nr_war between pNR_WAR_OD and pNR_WAR_DO
       and rodz_sur<>'ZWY';
-- vTyp VARCHAR2(50);
 vKod VARCHAR2(128):='\';
BEGIN
 OPEN c1;
 --od ORACLE10
 FETCH c1 INTO vKod; --od ORACLE10
 --ORACLE9
-- LOOP
--  FETCH c1 INTO vTyp;
--  EXIT WHEN c1%NOTFOUND;
--  vKod:=vKod||vTyp||'\';
-- END LOOP;
 CLOSE c1;
 --RETURN trim(BOTH '\' FROM vKod);
 RETURN vKod; --Oracle10
END;
/
---------------------------
--New FUNCTION
--INSTR_SIP
---------------------------
CREATE OR REPLACE FUNCTION "INSTR_SIP" (pTEKST VARCHAR2, pFRAZY VARCHAR2, pAND NUMBER) return number
is
 tmp varchar2(1000);
 nr number(2):=0;
 poz number(4):=0;
begin
 if trim(pFRAZY) is null then return 1; end if; 
 tmp:=replace(upper(trim(pFRAZY)),' ',';')||';';
 loop
  exit when tmp is null;-- or instr(tmp,';')=0;
  nr:=nr+1;
  poz:=instr(upper(pTEKST),substr(tmp,1,instr(tmp,';')-1));
  exit when poz=0 AND pAND=1 or poz>0 and pAND=0;
  tmp:=substr(tmp,instr(tmp,';')+1);
 end loop;
 return nr*sign(poz);
end INSTR_SIP;
/
---------------------------
--New FUNCTION
--ILOSC_DODATKU
---------------------------
CREATE OR REPLACE FUNCTION "ILOSC_DODATKU" (pNR_OBR NUMBER, pIL_OBR NUMBER, pWSP1 NUMBER, pWSP2 NUMBER, pWSP3 NUMBER, pWSP4 NUMBER, pWSP5 NUMBER) RETURN NUMBER
AS
 vNorma NUMBER(14,6) default 1;
 vIlSzt NUMBER(10) default 1;
 vWynik NUMBER(14,6);
BEGIN
 for l in (select S.met_oblicz, L.nr_kol_param, L.czy_korekt_wym rodz_par
           from slparob S, lista_p_obr L
           where S.nr_k_p_obr=pNR_OBR and L.nr_komp_struktury=S.nr_k_p_obr)
  loop
    if l.rodz_par=2 then
     vIlSzt := case l.nr_kol_param 
                 when 1 then pWSP1
                 when 2 then pWSP2
                 when 3 then pWSP3
                 when 4 then pWSP4
                 when 5 then pWSP5
                 else 0
               end;
    elsif l.rodz_par=9 then
     vNorma := vNorma * case l.nr_kol_param 
                         when 1 then pWSP1
                         when 2 then pWSP2
                         when 3 then pWSP3
                         when 4 then pWSP4
                         when 5 then pWSP5
                         else 0
                        end;
    end if;
    vWynik := case when l.met_oblicz in (1,2,4) then pIL_OBR*vNorma
                   when l.met_oblicz=3  then vNorma*vIlSzt
              end;
  end loop;
 RETURN vWynik;   
EXCEPTION
  WHEN OTHERS THEN
    RETURN -1;
END ILOSC_DODATKU;
/
---------------------------
--New FUNCTION
--ILE_LISTEW
---------------------------
CREATE OR REPLACE FUNCTION "ILE_LISTEW" (pKOD_STR VARCHAR2) RETURN NUMBER
AS
 vILE_LIS NUMBER(1);
 sepSTR CHAR(1):='\';
 --'
BEGIN
 IF instr(pKOD_STR,'/')>0 THEN sepSTR:='/'; END IF;

 SELECT nvl(sum(
                (length(sepSTR||pKOD_STR||sepSTR)-length(replace(sepSTR||pKOD_STR||sepSTR,sepSTR||typ_kat||sepSTR,sepSTR))) / (length(typ_kat)+1)
               ),0)
   INTO vILE_LIS
 FROM katalog 
 WHERE rodz_sur='LIS'
   AND instr(sepSTR||pKOD_STR||sepSTR,sepSTR||typ_kat||sepSTR)>0;
 RETURN vILE_LIS;
END ILE_LISTEW;
/
---------------------------
--New FUNCTION
--ILE_KOMOR
---------------------------
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
---------------------------
--New FUNCTION
--IDENT_ETAP_POP
---------------------------
CREATE OR REPLACE FUNCTION "IDENT_ETAP_POP" (pETAP NUMBER, pNR_KOM_ZLEC NUMBER, pNR_POZ NUMBER, pWAR_OD NUMBER DEFAULT 0, pWAR_DO NUMBER DEFAULT 99) RETURN VARCHAR2
AS
 vRet VARCHAR2(100):='0';
BEGIN
 IF pETAP=2 THEN
  --sumowanie atrybutów z rekordów czy_war=1
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
---------------------------
--New FUNCTION
--IDENT_ETAP
---------------------------
CREATE OR REPLACE FUNCTION "IDENT_ETAP" (pETAP NUMBER, pIDENT_SPISZ VARCHAR2) RETURN VARCHAR2
AS
BEGIN
 --pozostawienie atrybutów 4,5,6,7,8,22,27
 RETURN '000'||substr(pIDENT_SPISZ,4,5)||rpad('0',13,'0')||substr(pIDENT_SPISZ,22,1)||rpad('0',4,'0')||substr(pIDENT_SPISZ,27,1);
EXCEPTION WHEN OTHERS THEN
 RETURN '0';
END IDENT_ETAP;
/
---------------------------
--New FUNCTION
--GRUBOSC_WAR
---------------------------
CREATE OR REPLACE FUNCTION "GRUBOSC_WAR" (pNrKompZlec number, pNrPoz number, pNrWar number) return number 
as
  VnrKat spisd.nr_kat%type;
  VznWar spisd.zn_War%type;
  VkodDod spisd.kod_dod%type;
  r number;
begin
  select nvl(nr_kat,0),zn_War,kod_dod into vNrKAt,VznWar,VkodDod from spisd d where d.nr_kom_zlec=pNrKompZlec and nr_poz=pNrPoz and strona=0 and do_war=pNrWar;
  if VNrKat=0 then
    return 0;
  else
    if (VznWar='Pol') or (VnrKat=9999) then
-- grubosc pólproduktu szukamy w strukturach
      select gr_pak into r from struktury where kod_str=VkodDod;
    else
-- grubosc surowca szukamy w katalogu
      select grubosc into r from katalog where nr_kat=VNrKat;
    end if;
    return r;  
  end if;
  if VNrKat=0 then
    select nvl(nr_kat,0) into vNrKAt from spisd d where d.nr_kom_zlec=pNrKompZlec and nr_poz=pNrPoz and strona=0 and zn_War='Pol' and do_war=pNrWar;
  
  end if;
end;
/
---------------------------
--New FUNCTION
--GET_PARAM_T
---------------------------
CREATE OR REPLACE FUNCTION "GET_PARAM_T" 
( p_nr IN NUMBER, p_def IN VARCHAR2) RETURN VARCHAR2
AS
v_wartosc VARCHAR2(21);
e NUMBER(1);
BEGIN
  select count(1) into e from param_t where kod=p_nr;
  if e>0 then
   select wartosc into v_wartosc from param_t where kod=p_nr;
  else
    insert into param_t (kod, wartosc, opis) values (p_nr,p_def,' ');
    v_wartosc:=p_def;
    commit;
  end if;
  RETURN v_wartosc;
END GET_PARAM_T;
/
---------------------------
--New FUNCTION
--FUN_OPISY
---------------------------
CREATE OR REPLACE FUNCTION "FUN_OPISY" (pGRUPA NUMBER, pKTORE VARCHAR2, pSEP CHAR) RETURN VARCHAR2 IS
vRet VARCHAR2(4000);
BEGIN
 IF pGRUPA=101 THEN
  NULL; 
 END IF;
 SELECT listagg(fraza,pSEP) within group (order by lp)
   INTO vRet
 FROM (select 0 grupa, 0 lp, NULL fraza from dual union
       select 101, 1, 'Bledny surowiec' from dual union
       select 101, 2, 'Bledny kod pólproduktu' from dual union
       select 101, 3, 'Blad zapisu danych pólproduktów [ZLEC_POLP]' from dual union
       select 101, 4, ' ' from dual union
       select 101, 5, ' ' from dual union
       select 101, 6, 'Zerowa ilosc obróbki' from dual union
       select 101, 7, 'Brak obróbki krawedzi na warstwie z obróbka HART' from dual union
       select 101, 8, 'Brak obróbki krawedzi na warstwie hartowanej' from dual union
       select 101, 9, 'Formatka bez obróbki krawedzi' from dual
      )
 WHERE grupa=pGRUPA AND substr(pKTORE,lp,1)='1';
 RETURN vRet;
END FUN_OPISY;
/
---------------------------
--New FUNCTION
--FOREL240_VER
---------------------------
CREATE OR REPLACE FUNCTION "FOREL240_VER" (pDeviceId number) RETURN VARCHAR2 
as
  vResult varchar2(1000);

  vVER_NUM varchar2(6);
  vUNIT number;

  vSep char;
begin
  vResult := ' ';
  vSep := '|';

  vVER_NUM := '02.40';
  vUNIT := 0;

  vResult := 'VER'||vSep||
    vVER_NUM||vSep||
    vUNIT;

return vResult;
end forel240_ver;
/
---------------------------
--New FUNCTION
--FOREL240_TXT
---------------------------
CREATE OR REPLACE FUNCTION "FOREL240_TXT" (pDeviceId number, pNrKompZlec number, pNrPoz number, pNrSzt number, pNrElem number) RETURN VARCHAR2 
as
  vTxt varchar2(1000);
  vResult varchar2(1000);
  vSep char;
begin
  vResult := ' ';
  vSep := '|';
-- Pobierz dane z widoku v_zlec_mon
  select napis into vTXT from napisy_szyb_warstwy where nr_kom_zlec=pNrKompZlec and nr_poz=pNrPoz and nr_szt=pNrSzt and nr_war=pNrElem;
  vTXT := replace(vTXT,'%DATE%',to_char(sysdate(),'DD-MM-YYYY'));
  vTXT := replace(vTXT,'\','/');
  if (pDeviceId=0 or pDeviceId=1) and pNrElem>1 then
    vResult := 'PRO'||vSep||vSep||vSep||'1'||vSep||vSep||vSep||vSep||vSep||vSep||vSep||vSep||vSep||vSep||vSep||'Printing Text'||vSep||vTxt||vSep;
  end if;
  return vResult;
end forel240_txt;
/
---------------------------
--New FUNCTION
--FOREL240_SHP3
---------------------------
CREATE OR REPLACE FUNCTION "FOREL240_SHP3" (pDeviceId number, pNrKompZlec number, pNrPoz number, pNrWar number) RETURN VARCHAR2 
as
  vResult varchar2(1000);
  vSHP_PATH varchar2(40):=' ';
  vSHP_FILE varchar2(40):=' ';
  vSHP_NAME varchar2(40):=' ';
  vSHP_CAT number(1):=0;
  vSHP_NUM number(3):=0;
  vSHP_L number(5):=0;
  vSHP_L1 number(5):=0;
  vSHP_L2 number(5):=0;
  vSHP_H number(5):=0;
  vSHP_H1 number(5):=0;
  vSHP_H2 number(5):=0;
  vSHP_R number(5):=0;
  vSHP_R1 number(5):=0;
  vSHP_R2 number(5):=0;
  vSHP_R3 number(5):=0;
  vSHP_MIRR number(1):=0;
  vSHP_BASE number(1):=0;

  vParamKszt varchar2(200);
  vSep char;
begin
  vResult := ' ';
  vSep := '|';
  vSHP_PATH :='';
  vSHP_FILE :='';
  vSHP_NAME :='';
  vSHP_CAT :=0;
  vSHP_NUM :=0;
  vSHP_L :=0;
  vSHP_L1 :=0;
  vSHP_L2 :=0;
  vSHP_H :=0;
  vSHP_H1 :=0;
  vSHP_H2 :=0;
  vSHP_R :=0;
  vSHP_R1 :=0;
  vSHP_R2 :=0;
  vSHP_R3 :=0;
  vSHP_MIRR :=0;
  vSHP_BASE :=0;

  select strtoken(param_kszt,1,';') into vParamKszt from napisy_szyb_warstwy where nr_kom_zlec=pNrKompZlec and nr_poz=pNrPoz and nr_szt=1 and nr_war=pNrWar;
  if to_number(strtoken(vParamKszt,2,':'))>0 then
    vSHP_CAT := 0;
    if pDeviceId=0 then
      vSHP_CAT := 1;
    end if;
    vSHP_NUM := to_number(strtoken(vParamKszt,2,':'),'999');
    vSHP_L :=to_number(strtoken(vParamKszt,3,':'),'99999');
    vSHP_L1 :=to_number(strtoken(vParamKszt,4,':'),'99999');
    vSHP_L2 :=to_number(strtoken(vParamKszt,5,':'),'99999');
    vSHP_H :=to_number(strtoken(vParamKszt,6,':'),'99999');
    vSHP_H1 :=to_number(strtoken(vParamKszt,7,':'),'99999');
    vSHP_H2 :=to_number(strtoken(vParamKszt,8,':'),'99999');
    vSHP_R :=to_number(strtoken(vParamKszt,9,':'),'99999');
    vSHP_R1 :=to_number(strtoken(vParamKszt,10,':'),'99999');
    vSHP_R2 :=to_number(strtoken(vParamKszt,11,':'),'99999');
    vSHP_R3 :=to_number(strtoken(vParamKszt,12,':'),'99999');
    vResult := 'SHP'||vSep||
      vSHP_PATH||vSep||
      vSHP_FILE||vSep||
      vSHP_NAME||vSep||
      vSHP_CAT||vSep||
      vSHP_NUM||vSep||
      vSHP_L*10||vSep||
      vSHP_L1*10||vSep||
      vSHP_L2*10||vSep||
      vSHP_H*10||vSep||
      vSHP_H1*10||vSep||
      vSHP_H2*10||vSep||
      vSHP_R*10||vSep||
      vSHP_R1*10||vSep||
      vSHP_R2*10||vSep||
      vSHP_R3*10||vSep||
      vSHP_MIRR||vSep||
      vSHP_BASE;
  end if;
return vResult;
end forel240_shp3;
/
---------------------------
--New FUNCTION
--FOREL240_PRO
---------------------------
CREATE OR REPLACE FUNCTION "FOREL240_PRO" (pDeviceId number, pNrKompZlec number, pNrPoz number, pNrElem number) RETURN VARCHAR2 
as
  cursor c1 is  
    select * from v_zlec_mon vzm WHERE vzm.nr_kom_zlec=pNrKompZlec and vzm.nr_poz=pNrPoz and vzm.nr_el_wew=pNrElem;
  vzm v_zlec_mon%rowtype;

  vResult varchar2(1000);

  cf number;
  c number;
  i number;
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
--    if pNrElem mod 2 = 0 then
--    end if;
--    if (pDeviceId=1) and (vzm.szpros>0) then
--      vResult := 'PRO|||5|300|300|||||||||VERTICAL GEORGIAN BAR|';
--    end if;
  end loop;
  close c1;

return vResult;
end forel240_pro;
/
---------------------------
--New FUNCTION
--FOREL240_PAN
---------------------------
CREATE OR REPLACE FUNCTION "FOREL240_PAN" (pDeviceId number, pNrKompZlec number, pNrPoz number, pNrSzt number) RETURN VARCHAR2 
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
  vID_NUM varchar2(10);
  vBARCODE varchar2(10);
  vPAN_QTY number(5);
  vWIDTH number(5);
  vHEIGHT number(5);
  vSEAL_INSET number(3);
  vSEAL_CODE number(1);
  vSPACER_TYPE number(1);
  vSPACER_HEIGHT number(5);
  vSHAPE number(5);
  vHEAVY_PANE number(1);
  vRACK_INFO varchar2(10);
  vIG_PANE_REVERSE number(1);

  vSep char;
begin
  vResult := ' ';
  vSep := '|';
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

--      if vzm.powL>0 or vzm.powR>0 then glassa(c) := glassa(c)||'-1';
--      elsif vCzyOrn=1 then glassa(c) := glassa(c)||'-2';
--      else glassa(c) := glassa(c)||'-0';
--      end if;
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
--      glassa(c) := Substr(vzm.typ_kat,2,1)||glassa(c);
      if substr(vzm.ind_bud,13,1)=1 then
        vSEAL_CODE := 3;
      elsif vzm.silikon=1 then
        vSEAL_CODE := 2;
      else 
        vSEAL_CODE := 1;
      end if;
    end if;
  end loop;
  close c1;


  select 
    p.nr_poz ITEM_NUM,
    (select max(k.rack_no) from kol_stojakow k  where k.nr_komp_zlec=p.nr_kom_zlec and k.nr_poz=p.nr_poz and k.nr_sztuki=pNrSzt and k.nr_warstwy=1) ID_NUM,
    0 BARCODE,
    1 QTY,
    p.szer WIDTH,
    p.wys HEIGHT,
    decode(p.GR_SIL,0,45,p.GR_SIL*10) INSET,
    decode(p.nr_kszt,0,0,1) 
  into  vITEM_NUM,vID_NUM,vBARCODE,vPAN_QTY,vWIDTH,vHEIGHT,
        vSEAL_INSET,vSHAPE
  from spisz p
  left join struktury s on s.kod_str=p.kod_str
  where p.nr_kom_zlec=pNrKompZlec and p.nr_poz=pNrPoz;

  vResult := 'PAN'||vSep||
    vITEM_NUM||vSep||
    vID_NUM||vSep||
    vBARCODE||vSep||
    vPAN_QTY||vSep||
    vWIDTH*10||vSep||
    vHEIGHT*10||vSep||
    glassa(1)||vSep||
    glassa(2)||vSep||
    glassa(3)||vSep||
    glassa(4)||vSep||
    glassa(5)||vSep||
    glassa(6)||vSep||
    glassa(7)||vSep||
    vSEAL_INSET||vSep||
    gasa(1)||vSep||
    gasa(2)||vSep||
    gasa(3)||vSep||
    vSEAL_CODE||vSep||
    vSep||
    vSep||
    vSHAPE||vSep||
    vSep||
    vRACK_INFO||vSep||
    ''||vSep;


return vResult;
end forel240_pan;
/
---------------------------
--New FUNCTION
--FOREL240_ORD
---------------------------
CREATE OR REPLACE FUNCTION "FOREL240_ORD" (pDeviceId number, pNrKompZlec number) RETURN VARCHAR2 
as
  vResult varchar2(1000);

  vORD_NUM varchar2(100);
  vCUST_NUM varchar2(100);
  vCUST_NAME varchar2(100);
  vTEXT1 varchar2(100);
  vTEXT2 varchar2(100);
  vTEXT3 varchar2(100);
  vTEXT4 varchar2(100);
  vTEXT5 varchar2(100);
  vPROD_DATE varchar2(100);
  vDEL_DATE varchar2(100);
  vDEL_AREA varchar2(100);

  vSep char;
begin
  vResult := ' ';
  vSep := '|';

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
  into  vORD_NUM, vCUST_NUM, vCUST_NAME, 
        vTEXT1, vTEXT2, vTEXT3, vTEXT4, vTEXT5,
        vPROD_DATE, vDEL_DATE, vDEL_AREA
  from zamow z
  left join klient k on k.nr_kon=z.nr_kon
  where z.nr_kom_zlec=pNrKompZlec;


  vResult := 'ORD'||vSep||
    vORD_NUM||vSep||
    vCUST_NUM||vSep||
    vCUST_NAME||vSep||
    vTEXT1||vSep||
    vTEXT2||vSep||
    vTEXT3||vSep||
    vTEXT4||vSep||
    vTEXT5||vSep||
    vPROD_DATE||vSep||
    vDEL_DATE||vSep||
    vDEL_AREA;

return vResult;
end forel240_ORD;
/
---------------------------
--New FUNCTION
--FOREL240_ELEM2
---------------------------
CREATE OR REPLACE FUNCTION "FOREL240_ELEM2" (pDeviceId number, pNrKompZlec number, pNrPoz number, pNrElem number) RETURN VARCHAR2 
as
  cursor c2 is  
    select * from v_zlec_mon vzm WHERE vzm.nr_kom_zlec=pNrKompZlec and vzm.nr_poz=pNrPoz and vzm.nr_el=pNrElem;
  vzm v_zlec_mon%rowtype;

  vOznRamki char;
  vResult varchar2(1000);

  vPANE_DESCRIPT varchar2(100);
  vPANE_BARCODE varchar2(20);
  vPANE_TYPE number(1);
  vPANE_CODE varchar2(20);
  vPANE_THICKNESS number(5);
  vPANE_WIDTH number(5);
  vPANE_HEIGHT number(5);
  vPANE_FACESIDE number(1);
  vPANE_RACK_INFO varchar2(10);

  vSP_DESCRIPT varchar2(100);
  vSP_TYPE number(1);
  vSP_CODE varchar2(20);
  vSP_WIDTH number(5);
  vSP_HEIGHT number(5);
  vSP_INSET number(5);
  vSP_RACK_INFO varchar2(10);
  vSP_GASCODE number(1);
  vSP_SEAL_TYPE number(1);

  vSep char;
  vSep2 char;
begin
  vResult := ' ';
  vSep := '|';
  vSep2 := Chr(13);

  vPANE_CODE := '';
  vSP_GASCODE := 1;
  vSP_SEAL_TYPE := 1;

  vPANE_FACESIDE := 0;
  vPANE_RACK_INFO := ' ' ;

  OPEN c2;
  FETCH c2 INTO vzm;

  vPANE_WIDTH := (vzm.szer-vzm.max_stepL-vzm.max_stepP+vzm.stepL+vzm.stepP)*10;
  vPANE_HEIGHT := (vzm.wys-vzm.max_stepG-vzm.max_stepD+vzm.stepG+vzm.stepD)*10;
  vResult := 'CM1'||''||vSep||
    vPANE_DESCRIPT||vSep||
    vSep|| --ID_NUM
    vSep|| --PANE_BARCODE
    vPANE_TYPE||vSep||
    vPANE_CODE||vSep||
    vPANE_THICKNESS||vSep||
    vPANE_WIDTH||vSep||
    vPANE_HEIGHT||vSep||
    vPANE_FACESIDE||vSep||
    vPANE_RACK_INFO||vSep||
    vSP_DESCRIPT||vSep||
    vSP_TYPE||vSep||
    vSP_CODE||vSep||
    vSP_WIDTH||vSep||
    vSP_HEIGHT||vSep||
    vSP_INSET||vSep||
    vSP_RACK_INFO||vSep||
    vSP_GASCODE||vSep||
    vSP_SEAL_TYPE||vSep||
    vSep;

  if vzm.nr_kat>0 then
    select NVL(substr(k.naz_kat,1,40),' '),nvl(floor(grubosc)*10,0),nvl(bok_od*10,0) into vSP_DESCRIPT,vSP_WIDTH,vSP_HEIGHT from katalog k where k.nr_kat=vzm.nr_kat;        
  else 
    vSP_DESCRIPT := ' ';
    vSP_WIDTH := 0;
    vSP_HEIGHT := 0;
  end if;
  vSP_CODE := vzm.typ_kat;
  if vzm.szpros>0 then
    vSP_CODE := vSP_CODE || '(SZ)';
  end if;
  if vzm.uszcz_std=0 then
    vSP_INSET := 50;
  else
    vSP_INSET := vzm.uszcz_std*10;
  end if;
  close c2;

  vResult := vResult||vSep2||
        'CM2'||vSep||
        vPANE_DESCRIPT||vSep||
        vSep|| --ID_NUM
        vSep|| --PANE_BARCODE
        vPANE_TYPE||vSep||
        vPANE_CODE||vSep||
        vPANE_THICKNESS||vSep||
        vPANE_WIDTH||vSep||
        vPANE_HEIGHT||vSep||
        vPANE_FACESIDE||vSep||
        vPANE_RACK_INFO||vSep||
        vSP_DESCRIPT||vSep||
        vSP_TYPE||vSep||
        vSP_CODE||vSep||
        vSP_WIDTH||vSep||
        vSP_HEIGHT||vSep||
        vSP_INSET||vSep||
        vSP_RACK_INFO||vSep||
        vSP_GASCODE||vSep||
        vSP_SEAL_TYPE||vSep||
        vSep;
return vResult;
end forel240_elem2;
/
---------------------------
--New FUNCTION
--FOREL240_ELEM
---------------------------
CREATE OR REPLACE FUNCTION "FOREL240_ELEM" (pDeviceId number, pNrKompZlec number, pNrPoz number, pNrElem number) RETURN VARCHAR2 
as
  cursor c1 is  
    select * from v_zlec_mon vzm WHERE vzm.nr_kom_zlec=pNrKompZlec and vzm.nr_poz=pNrPoz and vzm.nr_el=pNrElem;
  cursor c2 is  
    select * from v_zlec_mon vzm WHERE vzm.nr_kom_zlec=pNrKompZlec and vzm.nr_poz=pNrPoz and vzm.nr_el=pNrElem-1;
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

  vPANE_DESCRIPT varchar2(100);
  vPANE_BARCODE varchar2(20);
  vPANE_TYPE number(1);
  vPANE_CODE varchar2(20);
  vPANE_THICKNESS number(5);
  vPANE_WIDTH number(5);
  vPANE_HEIGHT number(5);
  vPANE_FACESIDE number(1);
  vPANE_RACK_INFO varchar2(10);

  vSP_DESCRIPT varchar2(100);
  vSP_TYPE number(1);
  vSP_CODE varchar2(20);
  vSP_WIDTH number(5);
  vSP_HEIGHT number(5);
  vSP_INSET number(5);
  vSP_RACK_INFO varchar2(10);
  vSP_GASCODE number(1);
  vSP_SEAL_TYPE number(1);

  vSep char;
begin
  vResult := ' ';
  vSep := '|';
  cg := 0;
  cf := 0;
  vPANE_CODE := vzm.typ_kat;
  vSP_GASCODE := 1;
  vSP_SEAL_TYPE := 1;

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
        select NVL(substr(k.naz_kat,1,40),' '),decode(Substr(k.typ_kat,1,1),'O',1,0),k.znacz_pr into vPANE_DESCRIPT,vCzyOrn,vZnaczPr from katalog k where k.nr_kat=vzm.nr_kat;
      else 
        vPANE_DESCRIPT := vzm.typ_kat||' '||vzm.grub;
      end if;
      vPANE_CODE := vzm.typ_kat;


      if vCzyOrn=1 then vPANE_TYPE := 2;
      elsif vzm.powL>0 or vzm.powR>0 then vPANE_TYPE := 1;
      else vPANE_TYPE := 0;
      end if;

      vPANE_THICKNESS := round(vzm.grub*10);
      if pDeviceId=1 then
        vPANE_WIDTH := vzm.szer*10;
        vPANE_HEIGHT := vzm.wys*10;
      end if;

      if vzm.powL>0 then vPANE_FACESIDE := 1;
      elsif vzm.powR>0 then vPANE_FACESIDE := 2;
      else vPANE_FACESIDE := 0;
      end if;

      vPANE_RACK_INFO := ' ' ;

--      if vzm.typ_kat='LAMINAT' or vZnaczPr='9.La' or vZnaczPr='29.' then vGLX_CATEGORY := 2;
--      elsif vzm.hartowana=1 then vGLX_CATEGORY := 4;
--      else vGLX_CATEGORY := 1;
--      END IF;
      if cg>1 then
        OPEN c2;
        FETCH c2 INTO vzm;
        EXIT WHEN c1%NOTFOUND; 

        if vzm.nr_kat>0 then
          select NVL(substr(k.naz_kat,1,40),' '),nvl(floor(grubosc)*10,0),nvl(bok_od*10,0) into vSP_DESCRIPT,vSP_WIDTH,vSP_HEIGHT from katalog k where k.nr_kat=vzm.nr_kat;

        else 
          vSP_DESCRIPT := ' ';
          vSP_WIDTH := 0;
          vSP_HEIGHT := 0;
        end if;
        select nvl(max(trim(NAZWA_RAMKI)),vzm.typ_kat) into vSP_CODE from v_typy_ramek 
          where typkat=vzm.typ_kat and NR_KOMP_KONF=(select nr_konf_trans from v_forel_devices where device_id=pDeviceId);
--        if vSP_CODE = ' ' then vSP_CODE := vzm.typ_kat; end if;
        if pDeviceId=1 and vzm.szpros>0 then
          vSP_CODE := vSP_CODE || '(SZ)';
        end if;
        if vzm.uszcz_std=0 then
          vSP_INSET := 50;
        else
          vSP_INSET := vzm.uszcz_std*10;
        end if;
      end if;

      vResult := 'CM'||cg||''||vSep||
        vPANE_DESCRIPT||vSep||
        vSep|| --ID_NUM
        vSep|| --PANE_BARCODE
        vPANE_TYPE||vSep||
        vPANE_CODE||vSep||
        vPANE_THICKNESS||vSep||
        vPANE_WIDTH||vSep||
        vPANE_HEIGHT||vSep||
        vPANE_FACESIDE||vSep||
        vPANE_RACK_INFO||vSep||
        vSP_DESCRIPT||vSep||
        vSP_TYPE||vSep||
        vSP_CODE||vSep||
        vSP_WIDTH||vSep||
        vSP_HEIGHT||vSep||
        vSP_INSET||vSep||
        vSP_RACK_INFO||vSep||
        vSP_GASCODE||vSep||
        vSP_SEAL_TYPE||vSep||
        vSep;
    end if;
-- gdy warstwa ramki
--    if pNrElem mod 2 = 0 then
--    end if;
  end loop;
  close c1;

return vResult;
end forel240_elem;
/
---------------------------
--New FUNCTION
--FLAG_ZAGROZENIA
---------------------------
CREATE OR REPLACE FUNCTION "FLAG_ZAGROZENIA" (pNK_ZLEC NUMBER, pFORMA_WPR CHAR, pSTATUS CHAR, pWYR CHAR, pFLAG_R NUMBER, pD_PLAN_PROD DATE, pD_ZAK_PROD DATE, pDPS DATE, pDSK DATE) RETURN NUMBER
AS
 vRet NUMBER(1);
 DataZero DATE;
BEGIN
  DataZero:=to_date('2001/01','YYYY/MM'); 
  SELECT 
  CASE WHEN pFORMA_WPR='W' OR pSTATUS in ('Z','A')THEN 0 --wstepne, zakonczone i anulowane
       WHEN pWYR NOT IN ('Z','R','W')  THEN 0
       WHEN pDSK<=DataZero  THEN 0
       WHEN mod(pFLAG_R,1000)>=880 THEN 0
       WHEN pD_ZAK_PROD>DataZero AND pD_ZAK_PROD<=pDSK THEN 0
       WHEN mod(pFLAG_R,1000)<200
            OR (select nvl(count(1),1) from spise where nr_komp_zlec=pNK_ZLEC and zn_wyk in (0,3) and nr_stoj_sped=0)>0 THEN
            CASE WHEN pDSK<=sysdate THEN 1
                 WHEN pDPS>pDSK THEN 2
                 WHEN pD_PLAN_PROD<=DataZero AND pDSK<=sysdate+1 THEN 3
                 WHEN pD_PLAN_PROD>pDSK THEN 4
                 --GP
                 --WHEN (select PKG_CZAS.NR_ZM_TO_DATE(nvl(max(nr_zm_sped_min),0)) from lwyc2_inst_ost where nr_kom_zlec=pNK_ZLEC)>pDSK THEN 5
                 ELSE 0
             END 
       ELSE 0
   END
  INTO vRet
  FROM dual;
  RETURN vRet;
END FLAG_ZAGROZENIA;
/
---------------------------
--New FUNCTION
--ETYKIETA_PROD_CUTMON
---------------------------
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
---------------------------
--New FUNCTION
--ETYKIETA_PROD_CTV
---------------------------
CREATE OR REPLACE FUNCTION "ETYKIETA_PROD_CTV" (p_NrZlec in NUMBER, p_NrPoz in NUMBER, p_NrSzt in NUMBER, p_NrWar in NUMBER)
   return varchar2
is
  vNrKompZlec numeric(10);
  vResult    varchar2(1000);
begin
  select max(nr_kom_zlec) into vNrKompZlec from zamow where nr_zlec=p_NrZlec and typ_zlec='Pro';
--  select ETYKIETA_PROD(vNrKompZlec,p_nrPoz,p_nrSzt,p_nrWar) into vResult from dual;
--  return vResult;
  return Replace(ETYKIETA_PROD(vNrKompZlec,p_nrPoz,p_nrSzt,p_nrWar),Chr(13) || Chr(10),'||');
  EXCEPTION WHEN OTHERS THEN
    ZAPISZ_ERR('ETYKIETA_PROD_CTV():'||SQLERRM);
    return '';
end ETYKIETA_PROD_CTV;
/
---------------------------
--New FUNCTION
--ETYKIETA_PROD2
---------------------------
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

-- przygotowanie sql zwracajacego wartosci
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
---------------------------
--New FUNCTION
--ETYKIETA_PROD
---------------------------
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
---------------------------
--New FUNCTION
--ETYKIETA2
---------------------------
CREATE OR REPLACE FUNCTION "ETYKIETA2" (p_NrKompSzyby in NUMBER, p_NrKompZlec in NUMBER, p_NrPoz in NUMBER, p_NrSzt in NUMBER)
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
  vResult := ' ';  

-- zebranie nazw column
  select listagg(column_name,Chr(8)) within group (order by column_id) into v_cols 
    from all_tab_cols where table_name='V_ETYKIETY' and COLUMN_name like 'F_%' and owner in (select sys_context( 'userenv', 'current_schema' ) from dual);

  if v_cols is null then return vResult; end if;

-- przygotowanie sql zwracajacego wartosci
  if p_NrKompSzyby=0 then
    query_str := 'select '||replace(v_cols,Chr(8),'||'''||chr(8)||'''||')||' from V_ETYKIETY where nr_komp_zlec=:zlec and nr_poz=:poz and nr_szt=:szt';
    OPEN c FOR query_str USING p_NrKompZlec,p_NrPoz,p_NrSzt;
  else
    query_str := 'select '||replace(v_cols,Chr(8),'||'''||Chr(8)||'''||')||' from V_ETYKIETY where nr_kom_szyby=:nrszyby';
    OPEN c FOR query_str USING p_NrKompSzyby;
  end if;
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
end ETYKIETA2;
/
---------------------------
--New FUNCTION
--ELEMENT_LISTY
---------------------------
CREATE OR REPLACE FUNCTION "ELEMENT_LISTY" (pLISTA in varchar2, pNR in number, pSEP CHAR DEFAULT ',') return NUMBER as 
BEGIN
  RETURN case when instr(pSEP||pLISTA||pSEP,pSEP||pNR||pSEP)>0
              then 1 else 0
         end;
END ELEMENT_LISTY;
/
---------------------------
--New FUNCTION
--DATA_ZAK_PROD_WG_SPISE
---------------------------
CREATE OR REPLACE FUNCTION "DATA_ZAK_PROD_WG_SPISE" (pNK_ZLEC NUMBER) RETURN DATE
AS
 vDataMax DATE;
 vIl_szyb NUMBER(10);
 vIl_zatw NUMBER(10);
BEGIN
 select max(data_wyk), sum(case when zn_wyk in (2,3) then 1 else 0 end) il_zatw, count(1)
   into vDataMax, vIl_zatw, vIl_szyb
 from spise
 where nr_komp_zlec=pNK_ZLEC and zn_wyk<>9;
 RETURN case when vIl_zatw>0 and vIl_zatw=vIl_szyb then vDataMax else to_date('1901/01','YYYY/MM') end;
EXCEPTION WHEN OTHERS THEN 
  RETURN to_date('1901/01','YYYY/MM');
END DATA_ZAK_PROD_WG_SPISE;
/
---------------------------
--New FUNCTION
--DATA_WYK_NAST
---------------------------
CREATE OR REPLACE FUNCTION "DATA_WYK_NAST" (pNR_SER NUMBER, pKOLEJN_MIN NUMBER) RETURN DATE
IS
 vZmWyk NUMBER(10);
BEGIN
  --SELECT count(1) INTO vZmWyk from l_wyc;
  SELECT nvl(min(PKG_CZAS.NR_KOMP_ZM(d_wyk,zm_wyk)),0) INTO vZmWyk
  from l_wyc
  where nr_ser=pNR_SER AND kolejn>=pKOLEJN_MIN and d_wyk>to_date('1901','YYYY');
  RETURN case when vZmWyk>0
              then PKG_CZAS.NR_ZM_TO_DATE(vZmWyk)
              else to_date('190101','YYYYMM') end;
EXCEPTION WHEN OTHERS THEN
 RETURN to_date('190101','YYYYMM'); 
END DATA_WYK_NAST;
/
---------------------------
--New FUNCTION
--DANE_LAMINATU
---------------------------
CREATE OR REPLACE FUNCTION "DANE_LAMINATU" (pNR_KOM_STR NUMBER, pNR_WAR NUMBER) RETURN VARCHAR2
AS
 CURSOR c1
  IS select listagg(typ_kat,'\') within group (order by lp)
     from spiss_vlam
     where nr_kom_str=pNR_KOM_STR
       and pNR_WAR between war_od and war_do;
 vKod VARCHAR2(128);
BEGIN
 OPEN c1;
 FETCH c1 INTO vKod;
 CLOSE c1;
 RETURN vKod;
END;
/
---------------------------
--New FUNCTION
--CZY_WYKONANY_BRAK
---------------------------
CREATE OR REPLACE FUNCTION "CZY_WYKONANY_BRAK" (pID_REK NUMBER, pKOLEJN NUMBER) RETURN NUMBER
AS
 vNr_ser_br NUMBER(12);
 vD_wyk DATE;
BEGIN
 --pobranie nowego NR_SER z najnowszego zlecenia braku
 SELECT nvl(max(nr_ser),0) INTO vNr_ser_br
 FROM l_wyc
 WHERE id_oryg=pID_REK and wyroznik='B'; --id_oryg wypelniany przy parT_103>0
 IF vNr_ser_br=0 THEN 
  RETURN 0;
 END IF;
 
 --spr. D_WYK na inst biezacej lub pózniejszej w kolejnosci
 SELECT max(d_wyk) INTO vD_wyk
 FROM l_wyc
 WHERE nr_ser=vNr_ser_br AND kolejn>=pKOLEJN;
 
 RETURN case when vD_wyk>'2001/01/01' THEN 1 else 0 end;
 
EXCEPTION WHEN OTHERS THEN
 RETURN 0;
END CZY_WYKONANY_BRAK;
/
---------------------------
--New FUNCTION
--CZY_KSZTALT
---------------------------
CREATE OR REPLACE FUNCTION "CZY_KSZTALT" (p_nrKompZlec in number, p_nrPoz in NUMBER, p_nrWar IN NUMBER)
RETURN integer AS 
  vNrKat integer;
  vNrKszt integer;
  vNrKompRys integer;
  vRet integer;
BEGIN
  vRet := 0;
-- pobranie nrKatalogowego
  select nvl(strtoken(par_ksz_dc(p_nrKompZlec,p_nrPoz,p_nrWar),1,':'),'0') into vNrKat from dual;
-- pobranie nrKsztaltu
  select nvl(strtoken(par_ksz_dc(p_nrKompZlec,p_nrPoz,p_nrWar),2,':'),'0') into vNrKszt from dual;
-- pobranie numeru rysunku DXF
  select nr_komp_rys into vNrKompRys from spisz where nr_kom_zlec=p_nrKompZlec and nr_poz=p_nrPoz;
  
  if vNrKompRys>0 then
    if (vNrKat>0 and vNrKszt>0) or (vNrKat=0 and vNrKszt=0) then
      vRet := 1;
    else
      vRet := 0;
    end if;
  else 
    if (vNrKat>0 and vNrKszt>0) then
      vRet := 1;
    else
      vRet := 0;
    end if;
  end if;
  return vRet;
  EXCEPTION WHEN OTHERS THEN
    ZAPISZ_ERR('CZY_KSZTALT('||p_nrKompZlec||'):'||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||SQLERRM);
    return 0;
END CZY_KSZTALT;
/
---------------------------
--New FUNCTION
--CTV_CAPTION
---------------------------
CREATE OR REPLACE FUNCTION "CTV_CAPTION" (p_TypKat varchar2, p_Szer number, p_wys number, p_NrZlec number, p_NrPoz number, p_NrSzt number, p_NrWar number) return Varchar2  
as
  vSep char := Chr(9);  
  vRet VARCHAR2(100);
  vStojak number;
  vKomora number;
begin
  vret:='0';

  if p_NrZlec=0 then
    --vret:='Odp. '||vSep||p_TypKat;
    vret:='';
  else
    select 
        decode(mod(rank,60),0,floor(rank/60),floor(rank/60)+1) stojak,
        decode(mod(rank,60),0,60,mod(rank,60)) komora
        into vStojak,vKomora
    from V_CTV_KOLEJNOSC_SZKIEL_CR
    where nr_zlec=p_NrZlec and nr_poz=p_NrPoz and nr_sztuki=p_NrSzt and nr_warstwy=p_NrWar;

    vret:=trim(to_char(vStojak,'9999999999'))||'.'||trim(to_char(vKomora,'9999999999'));
  end if;


  return vRet;

end;
/
---------------------------
--New FUNCTION
--CIAG_PROD
---------------------------
CREATE OR REPLACE FUNCTION "CIAG_PROD" (
   p_nrKomZlec number,
   p_nrPoz number,
   p_nrSzt number,
   p_nrWar number,
   p_Sep char default '',
   p_AC integer default 0
)
   return    varchar2
is
  cursor c1 is select * from l_wyc l 
    where NR_KOM_ZLEC=p_nrKomZlec and nr_poz_zlec=p_nrPoz and nr_szt=p_nrSzt and p_nrWar=nr_warst
      and nr_inst>0
    order by nr_kom_zlec,nr_poz_zlec,nr_szt,kolejn,nr_warst;
  rec l_wyc%ROWTYPE;
  vNazInst parinst.naz2%TYPE;
  vNkInst number:=0;
  vResult varchar2(100);
begin
  vResult := '';
  OPEN c1;
  LOOP
    FETCH c1 INTO rec;
    EXIT WHEN c1%NOTFOUND;
    if rec.typ_inst='A C' and p_AC=0 then continue; end if;
    IF rec.nr_inst<>vNkInst THEN
      select naz2 into vNazInst from parinst where NR_KOMP_INST=rec.NR_INST;
      vResult := vResult || vNazInst || p_Sep;
      vNkInst:=rec.nr_inst;
    END IF;
  END LOOP;
  CLOSE c1;
  return vResult;
EXCEPTION WHEN OTHERS THEN
  IF c1%ISOPEN THEN CLOSE c1; END IF;
  return vResult;
end ciag_prod;
/
---------------------------
--New FUNCTION
--CIAG_OBR
---------------------------
CREATE OR REPLACE FUNCTION "CIAG_OBR" (
   p_nrKomZlec number,
   p_nrPoz number,
   p_nrSzt number,
   p_rodzajNazwy number
)
   return    varchar2
is
  cursor c1 is 
    select o.symb_p_obr,tn.tekst_skrocony from 
    (
        select distinct d.nr_komp_obr
        from spisd d
        where d.nr_kom_zlec=p_nrKomZlec and d.nr_poz=p_nrPoz and d.nr_komp_obr>0
    )a
    left join slparob o  on o.nr_k_p_obr=a.nr_komp_obr
    left join tlum_napis tn on tn.nr_jezyka=1 and tn.nr_wyrazenia=o.nr_tlum
    order by o.kolejn_obr;
  vNazwaObr varchar2(100);
  vSkrotObr varchar2(50);
  vResult varchar2(100);
begin
  vResult := '';
  OPEN c1;
  LOOP
    FETCH c1 INTO vNazwaObr,vSkrotObr;
    EXIT WHEN c1%NOTFOUND;
    if p_rodzajNazwy=1 then
        vResult := vResult || vSkrotObr || ' ';
    else
        vResult := vResult || vNazwaObr || ' ';
    end if;
  END LOOP;
  CLOSE c1;
  return vResult;
EXCEPTION WHEN OTHERS THEN
  IF c1%ISOPEN THEN CLOSE c1; END IF;
  return vResult;
end ciag_obr;
/
---------------------------
--New FUNCTION
--CIAG_NR_INST
---------------------------
CREATE OR REPLACE FUNCTION "CIAG_NR_INST" (pNK_ZLEC NUMBER, pNR_POZ NUMBER, pNR_SZT NUMBER, pNR_WAR NUMBER) RETURN VARCHAR2 
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
---------------------------
--New FUNCTION
--ATRYB_SUM
---------------------------
CREATE OR REPLACE FUNCTION "ATRYB_SUM" (pIDENT1 VARCHAR2, pIDENT2 VARCHAR2, pIDENT3 VARCHAR2 DEFAULT '0', pIDENT4 VARCHAR2 DEFAULT '0') RETURN VARCHAR2
AS
 vRet VARCHAR2(100):=' ';
 vDlugosc NUMBER(3):=100;
 Nr NUMBER(3):=0;
BEGIN
 vDlugosc:=greatest(length(pIDENT1),length(pIDENT2),length(pIDENT3),length(pIDENT4));
 --dobrze dziala przy '1' maks na 40ej pozycji
 IF vDlugosc<=40 THEN 
  SELECT rpad(translate(reverse(to_char(sum(reverse(rpad(ident_bud,100,'0'))))),'23456789','11111111'),vDlugosc,'0')
  --SELECT translate(reverse(to_char(sum(reverse(rpad(ident_bud,100,'0'))),rpad('0',least(63,vDlugosc),'9'))),'23456789','11111111')
    INTO vRet
  FROM 
  (select pIDENT1 ident_bud from dual union 
   select pIDENT2 from dual union
   select pIDENT3 from dual union
   select pIDENT4 from dual);
  RETURN vRet; 
 ELSE
   LOOP
    EXIT WHEN Nr>=vDlugosc;
    Nr:=Nr+1;
    IF substr(pIDENT1,Nr,1)='1' or substr(pIDENT2,Nr,1)='1' or substr(pIDENT3,Nr,1)='1' or substr(pIDENT4,Nr,1)='1' THEN
     vRet:=vRet||'1';
    ELSE
     vRet:=vRet||'0';
    END IF; 
   END LOOP;
  RETURN trim(vRet);
 END IF; 
EXCEPTION WHEN OTHERS THEN
 RETURN '0';
END ATRYB_SUM;
/
---------------------------
--New FUNCTION
--ATRYB_PRODUCT
---------------------------
CREATE OR REPLACE FUNCTION "ATRYB_PRODUCT" (pIDENT1 VARCHAR2, pIDENT2 VARCHAR2) RETURN VARCHAR2
AS
 vRet VARCHAR2(100):=' ';
 vDlugosc NUMBER(3):=100;
 Nr NUMBER(3):=0;
BEGIN
 vDlugosc:=greatest(length(pIDENT1),length(pIDENT2));
 LOOP
  EXIT WHEN Nr>=vDlugosc;
  Nr:=Nr+1;
  IF substr(pIDENT1,Nr,1)='1' and substr(pIDENT2,Nr,1)='1' THEN
   vRet:=vRet||'1';
  ELSE
   vRet:=vRet||'0';
  END IF; 
 END LOOP;
 RETURN trim(vRet);
EXCEPTION WHEN OTHERS THEN
 RETURN '0';
END ATRYB_PRODUCT;
/
---------------------------
--New FUNCTION
--ATRYB_MATCH
---------------------------
CREATE OR REPLACE FUNCTION "ATRYB_MATCH" 
(
  pIDENT1 IN VARCHAR2 
, pIDENT2 IN VARCHAR2 
) RETURN NUMBER AS 
 Nr NUMBER:=0;
BEGIN
  IF least(instr(pIDENT1,'1'),instr(pIDENT2,'1'))=0 THEN
   RETURN 0;
  END IF; 
  LOOP
    EXIT WHEN Nr>=nvl(greatest(length(pIDENT1),length(pIDENT1)),0);
    Nr:=Nr+1;
    IF substr(pIDENT1,Nr,1)='1' and substr(pIDENT2,Nr,1)='1' THEN 
     RETURN 1;
    END IF; 
  END LOOP;
  RETURN 0;
END ATRYB_MATCH;
/
