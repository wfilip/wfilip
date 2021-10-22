--------------------------------------------------------
--  File created - pi¹tek-marca-27-2020   
--------------------------------------------------------
---------------------------
--New VIEW
--V_ZUZYCIE_SZKLA_ZM
---------------------------
CREATE OR REPLACE FORCE VIEW "V_ZUZYCIE_SZKLA_ZM" 
 ( "NR_GR", "NK_INST", "D_WYK", "ZM_WYK", "NR_KAT", "TYP_KAT", "COPT_NETTO", "COPT_BRUTTO", "COPT_BRUTTO_PT", "COPT_RESZTA_BEZ_REJ", "CR_NETTO", "CR_BRUTTO", "IL_ODP_POW", "POW_ODP_POW", "IL_ODP_POB", "POW_ODP_POB", "IL_ODP_US", "POW_ODP_US", "IL_BR", "POW_BR", "POW_STRAT", "WAGA_JEDN", "WAGA_STRAT"
  )  AS 
  SELECT min(G.nr_gr) nr_gr, min(V0.nk_inst) nk_inst, d_wyk, zm_wyk, nr_kat, max(typ_kat) typ_kat,
       sum(copt_netto) copt_netto, sum(copt_brutto) copt_brutto, sum(copt_brutto_pt) copt_brutto_pt, sum(copt_reszta_bez_rej) copt_reszta_bez_rej,
       sum(cr_netto) cr_netto, sum(cr_brutto) cr_brutto,
       sum(il_odp_pow) il_odp_pow, sum(pow_odp_pow) pow_odp_pow,
       sum(il_odp_pob) il_odp_pob, sum(pow_odp_pob) pow_odp_pob,
       sum(il_odp_us) il_odp_us, sum(pow_odp_us) pow_odp_us,
       sum(il_br) il_br, sum(pow_br) pow_br,
       sum(copt_brutto_pt-copt_netto-cr_netto-pow_odp_pow+pow_odp_pob+pow_odp_us+pow_br) pow_strat, min(waga) waga_jedn, 
       sum(copt_brutto_pt-copt_netto-cr_netto-pow_odp_pow+pow_odp_pob+pow_odp_us+pow_br)*min(waga) waga_strat
FROM v_zuzycie_szkla0 V0
LEFT JOIN katalog K using (nr_kat)
LEFT JOIN gr_inst G on G.typ=1 and G.nr_komp_inst=V0.nk_inst
GROUP BY d_wyk, zm_wyk, nr_kat, nvl(G.nr_gr,V0.nk_inst)
ORDER BY d_wyk desc, zm_wyk desc, nr_kat;
---------------------------
--New VIEW
--V_ZUZYCIE_SZKLA0
---------------------------
CREATE OR REPLACE FORCE VIEW "V_ZUZYCIE_SZKLA0" 
 ( "SRC", "NK_INST", "D_WYK", "ZM_WYK", "NR_KAT", "COPT_NETTO", "COPT_BRUTTO", "COPT_BRUTTO_PT", "COPT_RESZTA_BEZ_REJ", "CR_NETTO", "CR_BRUTTO", "IL_ODP_POW", "POW_ODP_POW", "IL_ODP_POB", "POW_ODP_POB", "IL_ODP_US", "POW_ODP_US", "IL_BR", "POW_BR"
  )  AS 
  SELECT 'OPT' src, T.nr_komp_instal nk_inst, T.d_wyk, T.zm_wyk, T.nr_kat, --max(T.typ_kat) typ_kat,
       sum(T.wyc_netto) copt_netto, sum(T.wyc_brutto) copt_brutto,
       --sum(T.wyc_brutto*(case when exists (select 1 from kartoteka K where K.nr_kat=T.nr_kat and K.szer=T.szer and K.wys=T.wys) then 1 else 0 end)) copt_brutto_pt,
       sum(T.szer*0.001*T.wys*0.001*(case when exists (select 1 from kartoteka K where K.nr_kat=T.nr_kat and K.szer=T.szer and K.wys=T.wys) then 1 else 0 end)) copt_brutto_pt,
       sum(case when O.akt in (1,2,3) then 0 else round(T.szer*0.001*T.wys*0.001-T.wyc_brutto,2) end) copt_reszta_bez_rej,
       0 CR_netto, 0 CR_brutto,
       0 il_odp_pow, 0 pow_odp_pow,
       0 il_odp_pob, 0 pow_odp_pob,
       0 il_odp_us, 0 pow_odp_us,
       0 il_br,0 pow_br
FROM opt_taf T
LEFT JOIN odpady O on O.nr_optym=T.nr_opt and O.nrt=T.nr_tafli and O.fl_plan=1
GROUP BY T.d_wyk, T.zm_wyk, T.nr_komp_instal, T.nr_kat
UNION
--CR
SELECT 'CR' src, W.nr_komp_instal, W.d_wyk, W.zm_wyk, D.nr_kat, 0,0,0,0 copt, sum(W.il_zlec_wyk) CR_netto, 0 CR_brutto,
       0 il_odp_pow, 0 pow_odp_pow, 0 il_odp_pob, 0 pow_odp_pob,0 il_odp_us, 0 pow_odp_us,
       0,0 br
FROM wykzal W, spisd D, parinst P
WHERE P.ty_inst='R C' and W.nr_komp_instal=P.nr_komp_inst
  and D.nr_kom_zlec=W.nr_komp_zlec and D.nr_poz=W.nr_poz and D.do_war=W.nr_warst and D.strona=4
GROUP BY W.d_wyk, W.zm_wyk, W.nr_komp_instal, D.nr_kat
UNION
--ODPADY_POW
SELECT 'ODP_POW' src, nk_inst, data, zm, nr_kat, 0,0,0,0 copt, 0,0 cr, count(1) il_odp_pow, sum(pow) pow_odp_pow, 0 il_odp_pob, 0 pow_odp_pob, 0 il_odp_us, 0 pow_odp_us, 0,0 br
from v_odpady
where typ_odp='ODP_POW'
group by nr_kat, data, zm, nk_inst
UNION
--ODPADY_POB
SELECT 'ODP_POB' src, nk_inst, data, zm, nr_kat, 0,0,0,0 copt, 0,0 cr, 0,0 odp_pow, count(1) il_odp_pob, sum(pow) pow_odp_pob, 0 il_odp_us, 0 pow_odp_us, 0,0 br
from v_odpady
where typ_odp='ODP_POB'
group by nr_kat, data, zm, nk_inst
UNION
--ODPADY USUNIETE
SELECT 'ODP_DEL' src, nk_inst, data, zm, nr_kat, 0,0,0,0 copt, 0,0 cr, 0,0 odp_pow, 0,0 odp_pob, count(1) il_odp_us, sum(pow) pow_odp_us, 0,0 br
from v_odpady
where typ_odp='ODP_DEL'
group by nr_kat, data, zm, nk_inst
--BRAKI;
---------------------------
--New VIEW
--V_SUROWCE_ZLEC
---------------------------
CREATE OR REPLACE FORCE VIEW "V_SUROWCE_ZLEC" 
 ( "NR_KOM_ZLEC", "NR_ZLEC", "DATA_ZL", "NR_KON", "SKROT_K", "NR_KONTRAKTU", "NR_KAT", "TYP_KAT", "KOD_DOD", "NR_MAG", "JEDN", "IL_NETTO", "IL_BRUTTO_NOM", "IL_NETTO_OPT", "IL_BRUTTO_OPT", "IL_BRUTTO", "IL_NA_RW_NETTO", "IL_NA_RW"
  )  AS 
  select V.nr_kom_zlec, V.nr_zlec, V.data_zl, V.nr_kon, V.skrot_k, V.nr_kontraktu,
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
--V_SUROWCE_WAR_Z
---------------------------
CREATE OR REPLACE FORCE VIEW "V_SUROWCE_WAR_Z" 
 ( "NR_KOM_ZLEC", "NR_ZLEC", "NR_KON", "DATA_ZL", "WYROZNIK", "STATUS", "NR_KONTRAKTU", "NR_POZ", "ILOSC", "SZER", "WYS", "POW", "OBW", "SZER_OBR", "WYS_OBR", "NR_KOM_STR", "LP", "ZN_WAR", "SPOS_OBL", "WSP", "POZIOM", "ZN_PP", "CZY_WAR", "NR_WAR", "NR_KAT", "TYP_KAT", "RODZ_SUR", "JED_POD", "WAGA", "GRUBOSC", "GRUB_1SKL", "N_STRAT", "IL_SUR", "KOD_DOD", "NR_MAG", "NR_KAT_DOD", "KOL_DOD", "NR_PROC", "ZNACZ_PR", "IDENT_BUD", "KOD_STR"
  )  AS 
  select V.nr_kom_zlec, V.nr_zlec, V.nr_kon, V.data_zl, V.wyroznik, V.status, V.nr_kontraktu,
       V.nr_poz, V.ilosc, V.szer, V.wys, V.pow, V.obw,
       D.szer_obr, D.wys_obr,
       V.nr_kom_str, V.lp, V.zn_war, V.spos_obl, V.wsp, V.poziom, V.zn_pp, V.czy_war, V.nr_war,
       V.nr_kat, V.typ_kat, V.rodz_sur, V.jed_pod, V.waga, V.grubosc, V.grub_1skl, V.n_strat,
       case when to_number(trim(substr(nvl(trim(D.nr_poc),'00'),1,2)),'99')=11 --'11 Obróbka',
             then ILOSC_DODATKU(D.nr_komp_obr,D.ilosc_do_wyk,D.par1,D.par2,D.par3,D.par4,D.par5)
            when to_number(trim(substr(nvl(trim(D.nr_poc),'00'),1,2)),'99') between 2 and 10 --szpros
             then 0
            else --ilosc obrobki wg BUDSTR w odniesieniu do powierzchni/obwodu
             decode(V.spos_obl,1,(D.szer_obr*0.001*D.wys_obr*0.001)*V.wsp, --pow
                               2,(D.szer_obr*0.002+D.wys_obr*0.002)*V.wsp, --obw
                               4,V.wsp, --ilosc
                               3,greatest(0,(D.szer_obr*0.002+D.wys_obr*0.002)-V.wsp), --obw - wsp
                               5,greatest(0,(D.szer_obr*0.001*D.wys_obr*0.001)-V.wsp), --pow - wsp
                               12,(D.szer_obr*0.002+D.wys_obr*0.002)*V.wsp*V.grub_1skl*nvl(nullif(V.gr_sil,0),PKG_PARAMETRY.GET_GR_SIL_DEFAULT()),
                    999999)
       end il_sur,
       D.kod_dod, D.nr_mag, D.nr_kat nr_kat_dod, D.kol_dod, to_number(trim(substr(nvl(trim(D.nr_poc),'00'),1,2)),'99') nr_proc,
       V.znacz_pr, V.ident_bud, V.kod_str
--from zamow Z
--left join klient using (nr_kon)
--left join spisz P on P.nr_kom_zlec=Z.nr_kom_zlec
--left join struktury S on S.kod_str=P.kod_str
--left join v_str_skl_sur_war V on V.nr_kom_str=S.nr_kom_str and V.rodz_sur<>'CZY'
--from spisz P
--left join v_str_skl_sur_war V on V.kod_str=P.kod_str and V.rodz_sur<>'CZY'
from v_str_skl_sur_war_z V
left join spisd D on D.nr_kom_zlec=V.nr_kom_zlec and D.nr_poz=V.nr_poz and D.do_war=V.nr_war
          --dolinkowanie rek. warstw (strona 4 dla TAFLI) oraz szprosów i obróbek z dodatakami
          --AND NOT szybsze od OR
          and not (D.strona=4 and V.rodz_sur<>'TAF')
          and not (D.strona=0 and V.rodz_sur='TAF')
--          and not (D.strona=0 and V.rodz_sur not in ('LIS','TAS'))
          and not (to_number(trim(substr(nvl(trim(D.nr_poc),'00'),1,2)),'99')>1 and trim(D.kod_dod) is null)
          and not (to_number(trim(substr(nvl(trim(D.nr_poc),'00'),1,2)),'99')>1 and V.czy_war=0)
where V.rodz_sur<>'CZY'
--order by Z.nr_kom_zlec desc, nr_poz, nr_skl, nr_skl1, nr_skl2, nr_skl3, nr_skl4;
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
             then 0
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
  select V.nr_kom_zlec, V.nr_zlec, V.data_zl, V.nr_kon, K.skrot_k, V.nr_kontraktu,
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
        where opt_zlec.nr_komp_zlec=V.nr_kom_zlec
          and opt_zlec.nr_poz=V.nr_poz and opt_zlec.nr_kat=V.nr_kat
          and opt_nr.nr_opt=opt_zlec.nr_opt and opt_taf.nr_opt=opt_zlec.nr_opt and opt_taf.nr_tafli=opt_zlec.nr_tafli
          and opt_taf.poz_w_pak>0)
       +(select nvl(round(sum(opt_zlec.wyc_netto),6),0)
         from opt_zlec, opt_taf, opt_nr,
              zamow W, spisz P
         where W.wyroznik='W' and W.nr_komp_poprz=V.nr_kom_zlec and P.nr_kom_zlec=W.nr_kom_zlec and P.nr_poz_pop=V.nr_poz
           and opt_zlec.nr_komp_zlec=W.nr_kom_zlec and  opt_zlec.nr_poz=P.nr_poz and opt_zlec.nr_kat=V.nr_kat
           and opt_nr.nr_opt=opt_zlec.nr_opt and opt_taf.nr_opt=opt_zlec.nr_opt and opt_taf.nr_tafli=opt_zlec.nr_tafli
           and opt_taf.poz_w_pak>0)   
       else 0 end   il_netto_opt,
       case when max(V.rodz_sur)='TAF' and max(nr_proc)=0 then
        (select nvl(round(sum(opt_zlec.wyc_netto)*avg(decode(opt_nr.wyc_netto,0,0,opt_nr.wyc_brutto/opt_nr.wyc_netto)),6),0) brutto
         from opt_zlec, opt_taf, opt_nr 
         where opt_zlec.nr_komp_zlec=V.nr_kom_zlec and opt_zlec.nr_poz=V.nr_poz and opt_zlec.nr_kat=V.nr_kat
           and opt_nr.nr_opt=opt_zlec.nr_opt and opt_taf.nr_opt=opt_zlec.nr_opt and opt_taf.nr_tafli=opt_zlec.nr_tafli
           and opt_taf.poz_w_pak>0)
         +
        (select nvl(round(sum(opt_zlec.wyc_netto)*avg(decode(opt_nr.wyc_netto,0,0,opt_nr.wyc_brutto/opt_nr.wyc_netto)),6),0) brutto
         from opt_zlec, opt_taf, opt_nr,
              zamow W, spisz P
         where W.wyroznik='W' and W.nr_komp_poprz=V.nr_kom_zlec and P.nr_kom_zlec=W.nr_kom_zlec and P.nr_poz_pop=V.nr_poz
           and opt_zlec.nr_komp_zlec=W.nr_kom_zlec and  opt_zlec.nr_poz=P.nr_poz and opt_zlec.nr_kat=V.nr_kat
           and opt_nr.nr_opt=opt_zlec.nr_opt and opt_taf.nr_opt=opt_zlec.nr_opt and opt_taf.nr_tafli=opt_zlec.nr_tafli
           and opt_taf.poz_w_pak>0)
       else 0 end   il_brutto_opt   
from v_surowce_war_z V 
--left join zamow Z on V.nr_kom_zlec=Z.nr_kom_zlec
left join klient K on K.nr_kon=V.nr_kon
where V.wyroznik in ('Z','R') and V.status<>'A'
group by V.nr_kom_zlec, V.nr_zlec, V.data_zl, V.nr_kon, K.skrot_k, V.nr_kontraktu,
         V.nr_poz, V.nr_kat, V.typ_kat,
         case when V.nr_proc between 2 and 11 then V.kol_dod else 0 end
order by nr_kom_zlec, nr_poz, nr_kat, nr_mag;
---------------------------
--Changed VIEW
--V_STR_SKL_SUR_Z
---------------------------
CREATE OR REPLACE FORCE VIEW "V_STR_SKL_SUR_Z" 
 ( "NR_KOM_ZLEC", "NR_ZLEC", "NR_KON", "DATA_ZL", "WYROZNIK", "STATUS", "NR_KONTRAKTU", "NR_POZ", "ILOSC", "SZER", "WYS", "POW", "OBW", "GR_SIL", "NR_KOM_STR", "LP", "NR_SKL", "NR_SKL1", "NR_SKL2", "NR_SKL3", "NR_SKL4", "ZN_WAR", "NR_KOM_SKL", "WSP", "SPOS_OBL", "KOD_STR", "NR_KOM_STR1", "NR_KOM_STR2", "NR_KOM_STR3", "NR_KOM_STR4", "POZIOM", "ZN_PP"
  )  AS 
  select Z.nr_kom_zlec, Z.nr_zlec, Z.nr_kon, Z.data_zl, Z.wyroznik, Z.status, Z.nr_kontraktu,
        P.nr_poz, P.ilosc, P.szer, P.wys, P.pow, P.obw, P.gr_sil,
        B.nr_kom_str, row_number() over (partition by Z.nr_kom_zlec, Z.nr_zlec, Z.nr_kon, Z.data_zl, P.nr_poz, B.nr_kom_str, B.kod_str order by B.nr_skl, B1.nr_skl, B2.nr_skl, B3.nr_skl, B4.nr_skl) lp,
       B.nr_skl, B1.nr_skl nr_skl1, B2.nr_skl nr_skl2, B3.nr_skl nr_skl3, B4.nr_skl nr_skl4,
       nvl(B4.zn_war,nvl(B3.zn_war,nvl(B2.zn_war,nvl(B1.zn_war,B.zn_war)))) zn_war, 
       nvl(B4.nr_kom_skl,nvl(B3.nr_kom_skl,nvl(B2.nr_kom_skl,nvl(B1.nr_kom_skl,B.nr_kom_skl)))) nr_kom_skl,
       nvl(B4.wsp,nvl(B3.wsp,nvl(B2.wsp,nvl(B1.wsp,B.wsp)))) wsp,
       nvl(B3.spos_obl,nvl(B3.spos_obl,nvl(B2.spos_obl,nvl(B1.spos_obl,B.spos_obl)))) spos_obl,
       B.kod_str, B1.nr_kom_str nr_kom_str1, B2.nr_kom_str nr_kom_str2, B3.nr_kom_str nr_kom_str3, B4.nr_kom_str nr_kom_str4,
       case when B4.zn_war='Sur' then 5
            when B3.zn_war='Sur' then 4
            when B2.zn_war='Sur' then 3
            when B1.zn_war='Sur' then 2
            when B.zn_war='Sur' then 1
            when B9.zn_war='Sur' then 9
       else 0 end poziom,
       case when B.zn_war='Pol' then 1
            when B1.zn_war='Pol' then 2
            when B2.zn_war='Pol' then 3
            when B3.zn_war='Pol' then 4
            when B9.zn_war='Sur' then 9
       else 0 end zn_pp
   from zamow Z
   left join spisz P on P.nr_kom_zlec=Z.nr_kom_zlec
   left join budstr B on B.kod_str=P.kod_str
   --left join katalog K on B.zn_war='Sur' and K.nr_kat=B.nr_kom_skl
   left join struktury S on B.zn_war<>'Sur' and S.nr_kom_str=B.nr_kom_skl
   left join budstr B1P on B.zn_war='Pol' and B1P.nr_kom_str=B.nr_kom_skl
   left join budstr B1 on B.zn_war<>'Sur' and B1.nr_kom_str=nvl(B1P.nr_kom_skl,B.nr_kom_skl) 
   --left join katalog K1 on K1.nr_kat=B1.nr_kom_skl
   left join budstr B2P on B1.zn_war='Pol' and B2P.nr_kom_str=B1.nr_kom_skl
   left join budstr B2 on B1.zn_war<>'Sur' and B2.nr_kom_str=nvl(B2P.nr_kom_skl,B1.nr_kom_skl)
   --left join katalog K2 on K2.nr_kat=B2.nr_kom_skl
   left join budstr B3P on B2.zn_war='Pol' and B3P.nr_kom_str=B2.nr_kom_skl
   left join budstr B3 on B2.zn_war<>'Sur' and B3.nr_kom_str=nvl(B3P.nr_kom_skl,B2.nr_kom_skl)
   --left join katalog K3 on K3.nr_kat=B3.nr_kom_skl
   left join budstr B4P on B3.zn_war='Pol' and B4P.nr_kom_str=B3.nr_kom_skl
   left join budstr B4 on B3.zn_war<>'Sur' and B4.nr_kom_str=nvl(B4P.nr_kom_skl,B3.nr_kom_skl)
   --left join katalog K4 on K4.nr_kat=B4.nr_kom_skl
   left join (select 'Sur' zn_war from dual) B9 on B4.zn_war<>'Sur' --nienull'owy B9 oznacza ?e zaglebienie do B4 niewystarczajace
   where nvl(B9.zn_war,nvl(B4.zn_war,nvl(B3.zn_war,nvl(B2.zn_war,nvl(B1.zn_war,B.zn_war)))))='Sur'

   order by B.nr_skl, B1.nr_skl, B2.nr_skl, B3.nr_skl, B4.nr_skl;
---------------------------
--New VIEW
--V_STR_SKL_SUR_WAR_Z
---------------------------
CREATE OR REPLACE FORCE VIEW "V_STR_SKL_SUR_WAR_Z" 
 ( "NR_KOM_ZLEC", "NR_ZLEC", "NR_KON", "DATA_ZL", "WYROZNIK", "STATUS", "NR_KONTRAKTU", "NR_POZ", "ILOSC", "SZER", "WYS", "POW", "OBW", "GR_SIL", "NR_KOM_STR", "LP", "ZN_WAR", "SPOS_OBL", "WSP", "POZIOM", "ZN_PP", "CZY_WAR", "NR_WAR", "NR_KAT", "TYP_KAT", "RODZ_SUR", "JED_POD", "WAGA", "GRUBOSC", "GRUB_1SKL", "N_STRAT", "ZNACZ_PR", "IDENT_BUD", "KOD_STR"
  )  AS 
  Select V.nr_kom_zlec, V.nr_zlec, V.nr_kon, V.data_zl, V.wyroznik, V.status, V.nr_kontraktu,
        V.nr_poz, V.ilosc, V.szer, V.wys, V.pow, V.obw, V.gr_sil,
        V.nr_kom_str, V.lp, V.zn_war, V.spos_obl, V.wsp, V.poziom, V.zn_pp,
            case when V.zn_pp=0 and K.rodz_sur in ('TAF','LIS','TAS') then 1
                 when V.zn_pp=1 and nr_skl1=1 then 1
                 when V.zn_pp=2 and nr_skl2=1 then 1
                 when V.zn_pp=3 and nr_skl3=1 then 1
                 when V.zn_pp=4 and nr_skl4=1 then 1
                 when V.zn_pp=9 then 1
                 else 0 end czy_war,
        sum(case when V.zn_pp=0 and K.rodz_sur in ('TAF','LIS','TAS') then 1
                 when V.zn_pp=1 and nr_skl1=1 then 1
                 when V.zn_pp=2 and nr_skl2=1 then 1
                 when V.zn_pp=3 and nr_skl3=1 then 1
                 when V.zn_pp=4 and nr_skl4=1 then 1
                 when V.zn_pp=9 then 1
                 else 0 end)
         over (partition by V.nr_kom_zlec, V.nr_zlec, V.nr_kon, V.data_zl, V.nr_poz, V.nr_kom_str, V.kod_str order by V.nr_skl, V.nr_skl1, V.nr_skl2, V.nr_skl3, V.nr_skl4) nr_war,
        K.nr_kat, K.typ_kat, K.rodz_sur, K.jed_pod, K.waga, K.grubosc,
        lag(K.grubosc,nvl(V.nr_skl4,nvl(V.nr_skl3,nvl(V.nr_skl2,nvl(V.nr_skl1,V.nr_skl))))-1)
         over (partition by V.nr_kom_zlec, V.nr_zlec, V.nr_kon, V.data_zl, V.nr_poz, V.nr_kom_str, V.kod_str order by V.nr_skl, V.nr_skl1, V.nr_skl2, V.nr_skl3, V.nr_skl4) grub_1skl,
        K.n_strat, K.znacz_pr, K.ident_bud, V.kod_str
 From v_str_skl_sur_z V
 Left join katalog K on K.nr_kat=V.nr_kom_skl;
---------------------------
--New VIEW
--V_STR_SKL_SUR_WAR
---------------------------
CREATE OR REPLACE FORCE VIEW "V_STR_SKL_SUR_WAR" 
 ( "NR_KOM_STR", "LP", "ZN_WAR", "SPOS_OBL", "WSP", "POZIOM", "ZN_PP", "CZY_WAR", "NR_WAR", "NR_KAT", "TYP_KAT", "RODZ_SUR", "JED_POD", "WAGA", "GRUBOSC", "GRUB_1SKL", "N_STRAT", "ZNACZ_PR", "IDENT_BUD", "KOD_STR"
  )  AS 
  Select V.nr_kom_str, V.lp, V.zn_war, V.spos_obl, V.wsp, V.poziom, V.zn_pp,
            case when V.zn_pp=0 and K.rodz_sur in ('TAF','LIS','TAS') then 1
                 when V.zn_pp=1 and nr_skl1=1 then 1
                 when V.zn_pp=2 and nr_skl2=1 then 1
                 when V.zn_pp=3 and nr_skl3=1 then 1
                 when V.zn_pp=4 and nr_skl4=1 then 1
                 when V.zn_pp=9 then 1
                 else 0 end czy_war,
        sum(case when V.zn_pp=0 and K.rodz_sur in ('TAF','LIS','TAS') then 1
                 when V.zn_pp=1 and nr_skl1=1 then 1
                 when V.zn_pp=2 and nr_skl2=1 then 1
                 when V.zn_pp=3 and nr_skl3=1 then 1
                 when V.zn_pp=4 and nr_skl4=1 then 1
                 when V.zn_pp=9 then 1
                 else 0 end)
         over (partition by V.nr_kom_str, V.kod_str order by V.nr_skl, V.nr_skl1, V.nr_skl2, V.nr_skl3, V.nr_skl4) nr_war,
        K.nr_kat, K.typ_kat, K.rodz_sur, K.jed_pod, K.waga, K.grubosc,
        lag(K.grubosc,nvl(V.nr_skl4,nvl(V.nr_skl3,nvl(V.nr_skl2,nvl(V.nr_skl1,V.nr_skl))))-1)
         over (partition by V.nr_kom_str, V.kod_str order by V.nr_skl, V.nr_skl1, V.nr_skl2, V.nr_skl3, V.nr_skl4) grub_1skl,
        K.n_strat, K.znacz_pr, K.ident_bud, V.kod_str
 From v_str_skl_sur V
 Left join katalog K on K.nr_kat=V.nr_kom_skl;
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
        kryt_grub_pak*0.1+kryt_waga_pak*0.01+kryt_waga_1mb*0.001+kryt_waga_elem*0.0001+kryt_wym_min*0.00001+kryt_wym_max*0.000001+kryt_wym_dod*0.000001*0.1+kryt_atryb_wyl*0.000001*0.01+V.kryt_obr_jednocz*0.000001*0.001+kryt_oper*0.000001*0.0001 kryt_ktore,
       case when (max(kryt_grub_pak+kryt_waga_pak+kryt_waga_1mb+kryt_waga_elem+kryt_wym_min+kryt_wym_max+kryt_wym_dod+kryt_atryb_wyl+0+kryt_oper+V.kryt_obr_jednocz) over (partition by V.nr_kom_zlec, V.nr_poz, V.nr_porz))>0
            then case when (min(kryt_grub_pak+kryt_waga_pak+kryt_waga_1mb+kryt_waga_elem+kryt_wym_min+kryt_wym_max+kryt_wym_dod+kryt_atryb_wyl+0+kryt_oper+V.kryt_obr_jednocz) over (partition by V.nr_kom_zlec, V.nr_poz, V.nr_porz))>0
                      then 0
                      when max(decode(nk_inst,inst_wybr,kryt_grub_pak+kryt_waga_pak+kryt_waga_1mb+kryt_waga_elem+kryt_wym_min+kryt_wym_max+kryt_wym_dod+kryt_atryb_wyl+0+kryt_oper+V.kryt_obr_jednocz,null)) over (partition by V.nr_kom_zlec, V.nr_poz, V.nr_porz)>0
                      then 1
                      else 2 end
            else 3 end kryt_wyk,
       V.obsl_tech, V.inst_std, V.inst_wybr, V.wsp_jaki inst_jaka,
       nvl(WSP_WG_TYPU_INST(V.ty_inst, V.wsp_12zakr, V.wsp_c_m, V.wsp_har, V.wsp_HO, V.wsp_dod, V.znak_dod),1) wsp_przel, V.wsp_alt, V.lista_obr_jednocz
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
       decode(instr(lista_obr_jednocz,'I'||S.nk_inst||';'),0,1,0) kryt_obr_jednocz, lista_obr_jednocz,
       0 kryt_oper,--nvl(decode(T.obsl,0,1,0),0) kryt_oper,
       -1 obsl_tech--nvl(decode(TKP.obsl,0,8,TKP.obsl),0) obsl_tech
FROM
(SELECT S.zrodlo, S.nr_komp_zr, S.nr_kol, S.id_rek, S.etap, S.war_od, S.war_do, S.nr_porz, S.zn_war, S.zn_plan, S.szer, S.wys, S.szer*S.wys*0.000001 pow, S.indeks, S1.ident_bud, S.il_obr, S.inst_std,
        least(S.szer,S.wys) bok_min, greatest(S.szer,S.wys) bok_max,
        nvl(K.grubosc,Str.gr_pak) grub, K.wsp_c_m, K.wsp_har,
        nvl(K.waga,Str.waga) waga_jedn, nvl(K.waga*S.szer*S.wys*0.000001,0) waga_elem,
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
--LEFT JOIN tech_kontr_poz T ON T.nr_komp_zap=0 and T.nr_komp_zlec=S.nr_komp_zr and T.id_rek=S.id_rek and T.nr_kolejny=S.nr_porz
--link do pobrania decyzji dla kontroli poprawnoœci techn/      
--LEFT JOIN (select nr_komp_zlec, max(nr_komp_zap) nr_komp_zap_ost from tech_kontr group by nr_komp_zlec) TK ON TK.nr_komp_zlec=S.nr_komp_zr
--LEFT JOIN tech_kontr_poz TKP ON TKP.nr_komp_zap=TK.nr_komp_zap_ost AND TKP.nr_komp_zlec=S.nr_komp_zr AND TKP.id_rek=S.id_rek AND TKP.nr_kolejny=S.nr_porz AND TKP.nr_komp_instal=S.nk_inst
) V;
---------------------------
--New VIEW
--V_POWLOKI
---------------------------
CREATE OR REPLACE FORCE VIEW "V_POWLOKI" 
 ( "NR_KOM_ZLEC", "NR_POZ", "IDENT", "GDZIE_POWLOKI"
  )  AS 
  Select nr_kom_zlec, nr_poz, ident,
      ListAgg(case gdzie_powloka when 1 then '#'||to_char(ktore_szklo*2-1) when 2 then '#'||to_char(ktore_szklo*2) else '' end,' ') within group (order by do_war) gdzie_powloki
 From
 (select nr_kom_zlec, nr_poz, ident, do_war, decode(IL_ODC_PION,100000000,1,1000000,2,0) gdzie_powloka, kod_dod, nr_kat, rodz_sur,
        sum(case rodz_sur when 'POL' then S.il_szk when 'TAF' then 1 else 0 end) over (partition by nr_kom_zlec, nr_poz order by do_war) ktore_szklo
  from spisd D
  left join katalog K using (nr_kat)
  left join struktury S on S.kod_str=D.kod_dod
  where D.strona=4 and K.rodz_sur in ('TAF','POL')
 )
 Group By nr_kom_zlec, nr_poz, ident
 Order By nr_kom_zlec, nr_poz;
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
--V_OBROBKI_POZ
---------------------------
CREATE OR REPLACE FORCE VIEW "V_OBROBKI_POZ" 
 ( "NR_KOM_ZLEC", "NR_ZLEC", "DATA_ZL", "NR_POZ", "NR_OBR", "SYMB_OBR", "JEDN", "IL_PLAN", "IL_PLAN_PRZEL", "IL_WYK", "IL_WYK_PRZEL"
  )  AS 
  select nr_kom_zlec, nr_zlec, data_zl, nr_poz,  nr_obr, max(symb_obr) symb_obr, max(jedn) jedn,
        sum(il_obr) il_plan, round(sum(il_obr*wsp_p),6) il_plan_przel,
        sum(il_obr*sign(nr_zm_wyk)) il_wyk, round(sum(il_obr*sign(nr_zm_wyk)*nvl(wsp_w,1)),6) il_wyk_przel
 from l_wyc2_plus_wew
 group by nr_kom_zlec, nr_zlec, data_zl, nr_poz, nr_obr
 having exists (select 1 from harmon where harmon.nr_komp_zlec=nr_kom_zlec)
 order by nr_kom_zlec, nr_zlec, nr_poz, nr_obr;
---------------------------
--New VIEW
--V_NIEZATW_SZT
---------------------------
CREATE OR REPLACE FORCE VIEW "V_NIEZATW_SZT" 
 ( "NR_KOMP_ZLEC", "NR_POZ", "NR_SZT", "NK_INST", "NR_INST", "TYP_INST", "NR_WARST", "D_WYK", "ZM_WYK", "DATA_PROD", "DATA_SPED", "ZN_WYK"
  )  AS 
  SELECT "NR_KOMP_ZLEC","NR_POZ","NR_SZT","NK_INST","NR_INST","TYP_INST","NR_WARST","D_WYK","ZM_WYK","DATA_PROD","DATA_SPED","ZN_WYK" FROM V_NIEZATW_SPISE
UNION
SELECT "NR_KOM_ZLEC","NR_POZ_ZLEC","NR_SZT","NK_INST","NR_INST","TYP_INST","NR_WARST","D_WYK","ZM_WYK","DATA_PROD","DATA_SPED","ZN_WYK" FROM V_NIEZATW_LWYC;
---------------------------
--New VIEW
--V_KOSZT_STD_VS_FAKPOZ
---------------------------
CREATE OR REPLACE FORCE VIEW "V_KOSZT_STD_VS_FAKPOZ" 
 ( "TYP_DOKS", "NR_DOKS", "NR_KOMP_DOKS", "NR_POZ", "ID_ZLEC", "ID_ZLEC_POZ", "ID_WZ", "ID_WZ_POZ", "IL_SZT_FAKPOZ", "IL_SPISE", "SUM_SZT_OBR", "SUM_IL_PRZEL", "KOSZT_STD", "DATA_OD", "DATA_DO"
  )  AS 
  select F.typ_doks, F.nr_doks, F.nr_komp_doks, F.nr_poz, min(id_zlec) id_zlec, min(id_zlec_poz) id_zlec_poz, min(id_wz) id_wz, min(id_wz_poz) id_wz_poz, min(il_szt) il_szt_fakpoz,
       count(distinct nr_kom_szyby) il_spise, sum(ile_war) sum_szt_obr, sum(il_przel) sum_il_przel, sum(koszt_std) koszt_std,
       min(data_od) data_od, max(data_do) data_do
from fakpoz F
left join spise E on E.nr_komp_zlec=F.id_zlec and E.nr_poz=F.id_zlec_poz and E.nr_k_wz=F.id_wz and E.nr_poz_wz=F.id_wz_poz
left join v_koszt_obr_szt V on V.nr_kom_zlec=F.id_zlec and V.nr_poz=F.id_zlec_poz and V.nr_szt=E.nr_szt
where lp_dod=0 and storno=0
group by nr_komp_doks, F.nr_poz, typ_doks, nr_doks
ORDER BY typ_doks, nr_doks, F.nr_poz;
---------------------------
--New VIEW
--V_KOSZT_STD_PROD
---------------------------
CREATE OR REPLACE FORCE VIEW "V_KOSZT_STD_PROD" 
 ( "TYP_DOK", "NR_DOK", "DATA_D", "NR_KOMP_DOK", "NR_POZ_DOK", "WYROZNIK", "NR_KON", "NR_KOMP_ZLEC", "NR_ZLEC", "NR_POZ", "NR_SZT", "NR_KOM_SZYBY", "KOLEJN", "ZN_WYK", "NR_OBR", "SYMB_OBR", "NR_WAR", "KOLEJN_OBR", "IL_OBR", "IL_PRZEL", "KOSZT1", "KOSZT2", "NARZUT1", "NARZUT2", "KOSZT_STD", "NK_INST_KOSZTU", "DATA_KOSZTU", "DATA_PLAN", "DATA_WYK", "NR_ZM_PLAN", "NR_ZM_WYK", "WYK"
  )  AS 
  select dok.typ_dok, dok.nr_dok, dok.data_d, E.nr_k_wz nr_komp_dok, E.nr_poz_wz nr_poz_dok,
 --      F.typ_doks, F.nr_doks, F.nr_komp_doks, F.nr_poz nr_poz_doks, 
       Z.wyroznik, Z.nr_kon, E.nr_komp_zlec, E.nr_zlec, E.nr_poz, E.nr_szt,
--       E.nr_kom_szyby, row_number() over (partition by nr_kom_szyby order by V.kolejn) lp, E.zn_wyk,
       E.nr_kom_szyby, V.kolejn, E.zn_wyk, 
       V.nr_obr, V.symb_obr, nvl(V.do_war,V.nr_warst) nr_war, V.kolejn_obr, V.il_obr, V.il_przel,
       V.koszt1, V.koszt2, V.narzut1, V.narzut2, V.koszt_std, V.nk_inst_kosztu, V.data_kosztu,
       V.data_plan, V.data_wyk, V.nr_zm_plan, V.nr_zm_wyk, 
       case when E.zn_wyk in (1,2) or V.nr_zm_wyk>0 or
                 (select max(nr_zm_wyk) from l_wyc2 L
                  where L.nr_kom_zlec=V.nr_kom_zlec and L.nr_poz_zlec=V.nr_poz and L.nr_szt=V.nr_szt
                    and V.nr_warst between L.nr_warst and L.war_do and L.kolejn>=V.kolejn)>0
            then 1 else 0 end wyk
from spise E
left join zamow Z on Z.nr_kom_zlec=E.nr_komp_zlec
--left join v_koszt_obr_szt V on V.nr_kom_zlec=E.nr_komp_zlec and V.nr_poz=E.nr_poz and V.nr_szt=E.nr_szt
left join v_koszt_obr_lwyc2 V on V.nr_kom_zlec=E.nr_komp_zlec and V.nr_poz=E.nr_poz and V.nr_szt=E.nr_szt
left join dok on dok.nr_komp_dok=E.nr_k_wz
--left join fakpoz F on E.nr_komp_zlec=F.id_zlec and E.nr_poz=F.id_zlec_poz and E.nr_k_wz=F.id_wz and E.nr_poz_wz=F.id_wz_poz
where Z.wyroznik in ('Z','R','B') and (E.nr_k_wz>0 or E.nr_sped>0 or E.zn_wyk<9)
ORDER BY nr_komp_zlec desc, nr_poz, nr_szt, kolejn_obr;
---------------------------
--New VIEW
--V_KOSZT_STD1
---------------------------
CREATE OR REPLACE FORCE VIEW "V_KOSZT_STD1" 
 ( "TYP_DOK", "NR_DOK", "DATA_D", "NR_KOMP_DOK", "NR_POZ_DOK", "WYR", "NR_ZLEC", "NR_KOMP_ZLEC", "NR_POZ", "NR_KOM_ZLEC_WEW", "NR_POZ_ZLEC_WEW", "DO_WAR", "NR_SZT", "IL_SZT_CALK", "NR_KOM_SZYBY", "ZN_WYK", "DATA_PROD", "DATA_SPED", "NR_WARST", "WAR_DO", "KOLEJN", "NR_OBR", "SYMB_OBR", "KOLEJN_OBR", "IL_OBR", "NR_INST_PLAN", "NR_ZM_PLAN", "IL_PRZEL_P", "NR_INST_WYK", "NR_ZM_WYK", "IL_PRZEL_W", "DATA_PLAN", "ZM_PLAN", "DATA_WYK", "ZM_WYK", "WYK", "KOD_STR", "KOSZT1", "KOSZT2", "NARZUT1", "NARZUT2", "KOSZT_STD", "DATA_KOSZTU"
  )  AS 
  SELECT  TYP_DOK, NR_DOK, DATA_D, NR_KOMP_DOK, NR_POZ_DOK, WYR, NR_ZLEC, NR_KOMP_ZLEC, NR_POZ, NR_KOM_ZLEC_WEW, NR_POZ_ZLEC_WEW, DO_WAR, NR_SZT, IL_SZT_CALK, NR_KOM_SZYBY, ZN_WYK, DATA_PROD, DATA_SPED, NR_WARST, WAR_DO, MAX(KOLEJN) KOLEJN, NR_OBR, SYMB_OBR, KOLEJN_OBR, SUM(IL_OBR) IL_OBR, NR_INST_PLAN, NR_ZM_PLAN, sum(IL_OBR*WSP_P) IL_PRZEL_P, NR_INST_WYK, NR_ZM_WYK, sum(IL_OBR*WSP_W) IL_PRZEL_W, DATA_PLAN, ZM_PLAN, DATA_WYK, ZM_WYK, WYK, max(kod_str) KOD_STR, sum(KOSZT1) KOSZT1, sum(KOSZT2) KOSZT2, sum(NARZUT1) NARZUT1, sum(NARZUT2) NARZUT2, sum(KOSZT_STD) KOSZT_STD, max(DATA_KOSZTU) DATA_KOSZTU
FROM v_koszt_std
GROUP BY TYP_DOK, NR_DOK, DATA_D, NR_KOMP_DOK, NR_POZ_DOK, WYR, NR_ZLEC, NR_KOMP_ZLEC, NR_POZ, NR_KOM_ZLEC_WEW, NR_POZ_ZLEC_WEW, DO_WAR, NR_SZT, IL_SZT_CALK, NR_KOM_SZYBY, ZN_WYK, DATA_PROD, DATA_SPED, NR_WARST, WAR_DO, NR_OBR, SYMB_OBR, KOLEJN_OBR, NR_INST_PLAN, NR_ZM_PLAN, NR_INST_WYK, NR_ZM_WYK, DATA_PLAN, ZM_PLAN, DATA_WYK, ZM_WYK, WYK;
---------------------------
--New VIEW
--V_KOSZT_STD0
---------------------------
CREATE OR REPLACE FORCE VIEW "V_KOSZT_STD0" 
 ( "TYP_DOK", "NR_DOK", "DATA_D", "NR_KOMP_DOK", "NR_POZ_DOK", "WYR", "NR_ZLEC", "NR_KOMP_ZLEC", "NR_POZ", "NR_KOM_ZLEC_WEW", "NR_POZ_ZLEC_WEW", "DO_WAR", "NR_SZT", "IL_SZT_CALK", "NR_WARST", "WAR_DO", "KOLEJN", "NR_OBR", "SYMB_OBR", "KOLEJN_OBR", "IL_OBR", "NR_INST_PLAN", "NR_ZM_PLAN", "WSP_P", "NR_INST_WYK", "NR_ZM_WYK", "WSP_W", "DATA_PLAN", "ZM_PLAN", "DATA_WYK", "ZM_WYK", "KOD_STR"
  )  AS 
  select dok.typ_dok, dok.nr_dok, dok.data_d, E.nr_k_wz nr_komp_dok, E.nr_poz_wz nr_poz_dok,
       Z.wyroznik wyr, Z.nr_zlec, E.nr_komp_zlec, E.nr_poz, V.nr_kom_zlec_wew, V.nr_poz_zlec_wew, V.do_war, 
       E.nr_szt, V.ilosc il_szt_calk, L.nr_warst, L.war_do, 
       L.kolejn,  O.nr_k_p_obr nr_obr, O.symb_p_obr symb_obr, O.kolejn_obr,
       case when L.kolejn>300 then V.pow
            when D.nr_komp_obr is null then case when O.met_oblicz=1 then D0.szer_obr*0.002+D0.wys_obr*0.002
                                                 when O.met_oblicz=2 then D0.szer_obr*0.001*D0.wys_obr*0.001
                                                 else 1 end
            when D.strona=4 then            case when O.met_oblicz=1 then D.szer_obr*0.002+D.wys_obr*0.002
                                                 when O.met_oblicz=2 then D.szer_obr*0.001*D.wys_obr*0.001
                                                 else 1 end
            when D.il_pol_szp>0 then D.il_pol_szp
            when D.ilosc_do_wyk>0 then D.ilosc_do_wyk
            else 0
       end il_obr,
       L.nr_inst_plan, L.nr_zm_plan, Wp.wsp_alt wsp_p, L.nr_inst_wyk, L.nr_zm_wyk, Ww.wsp_alt wsp_w,
       PKG_CZAS.NR_ZM_TO_DATE(L.nr_zm_plan) data_plan, PKG_CZAS.NR_ZM_TO_ZM(L.nr_zm_plan) zm_plan,
       PKG_CZAS.NR_ZM_TO_DATE(L.nr_zm_wyk) data_wyk, PKG_CZAS.NR_ZM_TO_ZM(L.nr_zm_wyk) zm_wyk,
       V.kod_str
--from v_poz_wew V    --pozycje zlecenia glownego + pozycje zlec. wew
--left join spise E on E.nr_komp_zlec=Z.nr_kom_zlec and E.nr_poz=V.nr_poz
from spise E
left join (select to_date('1901/01','YYYY/MM') DATA_ZERO from dual) on 1=1
left join v_poz_wew V on E.nr_komp_zlec=V.nr_kom_zlec and E.nr_poz=V.nr_poz
left join zamow Z on Z.nr_kom_zlec=V.nr_kom_zlec
left join dok on dok.nr_komp_dok=E.nr_k_wz
left join l_wyc2 L on L.nr_kom_zlec=nvl(V.nr_kom_zlec_wew,V.nr_kom_zlec) and L.nr_poz_zlec=nvl(V.nr_poz_zlec_wew,V.nr_poz) and L.nr_szt=E.nr_szt
left join spisd D on D.nr_kom_zlec=L.nr_kom_zlec and D.nr_poz=L.nr_poz_zlec and D.kol_dod=L.nr_porz_obr-100
left join spisd D0 on D0.nr_kom_zlec=L.nr_kom_zlec and D0.nr_poz=L.nr_poz_zlec and D0.do_war=L.nr_warst and D0.strona=0 and substr(D0.nr_poc,1,1) in (' ','0','1')
left join wsp_alter Wp on Wp.nr_kom_zlec=L.nr_kom_zlec and Wp.nr_poz=L.nr_poz_zlec and Wp.nr_porz_obr=L.nr_porz_obr and Wp.nr_komp_inst=L.nr_inst_plan
left join wsp_alter Ww on Ww.nr_kom_zlec=L.nr_kom_zlec and Ww.nr_poz=L.nr_poz_zlec and Ww.nr_porz_obr=L.nr_porz_obr and Ww.nr_komp_inst=L.nr_inst_wyk
--left join (select 1 pak from dual union select 0 from dual) on pak=zn_wyrobu and not (pak=1 and V.nr_kom_zlec_wew>0)
--left join slparob O on O.nr_k_p_obr=case when pak=0 then L.nr_obr when V.typ_poz='I k' then 112 when V.typ_poz='II ' then 113 else 111 end
left join slparob O on O.nr_k_p_obr=L.nr_obr
left join koszt_obr_std K on K.nk_obr=L.nr_obr and K.nk_inst=nvl(nullif(L.nr_inst_wyk,0),L.nr_inst_plan) --nk_inst
                             --and nvl2(nullif(L.nr_inst_wyk,0),L.data_wyk,nvl(nullif(L.data_plan,DATA_ZERO),nvl(nullif(E.data_wyk,DATA_ZERO),nvl(nullif(E.data_sped,DATA_ZERO),trunc(sysdate)))))
                             and nvl2(nullif(L.nr_inst_wyk,0),PKG_CZAS.NR_ZM_TO_DATE(L.nr_zm_wyk),nvl2(nullif(L.nr_zm_plan,0),PKG_CZAS.NR_ZM_TO_DATE(L.nr_zm_plan),nvl(nullif(E.data_wyk,DATA_ZERO),nvl(nullif(E.data_sped,DATA_ZERO),trunc(sysdate)))))
                                 between K.d_od and K.d_do
where not (E.zn_wyk=9 and E.nr_sped=0 and E.nr_k_wz=0)
  and Z.wyroznik in ('Z','R','B')
UNION
 --pakowanie
SELECT dok.typ_dok, dok.nr_dok, dok.data_d, E.nr_k_wz nr_komp_dok, E.nr_poz_wz nr_poz_dok,
       Z.wyroznik, Z.nr_zlec, Z.nr_kom_zlec, P.nr_poz, 0, 0, 0,
       E.nr_szt, P.ilosc, 0, 0,
       900, O.nr_k_p_obr, O.symb_p_obr, O.kolejn_obr, P.pow,
       O.nr_komp_inst, PKG_CZAS.NR_KOMP_ZM(Z.d_pl_sped,1), -1,--WSP_4ZAKR(O.nr_komp_inst,P.pow,P.ind_bud,0),
       O.nr_komp_inst, PKG_CZAS.NR_KOMP_ZM(E.data_sped,greatest(E.zm_sped,1)), -1,--WSP_4ZAKR(O.nr_komp_inst,P.pow,P.ind_bud,0),
       Z.d_pl_sped, 1, E.data_sped, greatest(E.zm_sped,1),
        P.kod_str
FROM spise E
LEFT JOIN zamow Z ON Z.nr_kom_zlec=E.nr_komp_zlec
LEFT JOIN spisz P ON P.nr_kom_zlec=Z.nr_kom_zlec and P.nr_poz=E.nr_poz
LEFT JOIN dok on dok.nr_komp_dok=E.nr_k_wz
LEFT JOIN slparob O ON O.nr_k_p_obr=case P.typ_poz when 'I k' then 112 when 'II ' then 113 else 111 end
--WHERE Z.wyroznik in ('Z','R') and (E.nr_k_wz>0 or E.nr_sped>0 or E.zn_wyk<9)
WHERE not (E.zn_wyk=9 and E.nr_sped=0 and E.nr_k_wz=0)
  and Z.wyroznik in ('Z','R');
---------------------------
--New VIEW
--V_KOSZT_STD
---------------------------
CREATE OR REPLACE FORCE VIEW "V_KOSZT_STD" 
 ( "TYP_DOK", "NR_DOK", "DATA_D", "NR_KOMP_DOK", "NR_POZ_DOK", "WYR", "NR_ZLEC", "NR_KOMP_ZLEC", "NR_POZ", "NR_KOM_ZLEC_WEW", "NR_POZ_ZLEC_WEW", "DO_WAR", "NR_SZT", "IL_SZT_CALK", "NR_KOM_SZYBY", "ZN_WYK", "DATA_PROD", "DATA_SPED", "NR_WARST", "WAR_DO", "KOLEJN", "NR_OBR", "SYMB_OBR", "KOLEJN_OBR", "IL_OBR", "JEDN", "NR_INST_PLAN", "NR_ZM_PLAN", "WSP_P", "NR_INST_WYK", "NR_ZM_WYK", "WSP_W", "DATA_PLAN", "ZM_PLAN", "DATA_WYK", "ZM_WYK", "WYK", "COUNT_PARTITION", "KOD_STR", "KOSZT1P", "KOSZT2P", "NARZUT1P", "NARZUT2P", "KOSZT1W", "KOSZT2W", "NARZUT1W", "NARZUT2W", "KOSZT1", "KOSZT2", "NARZUT1", "NARZUT2", "KOSZT_STD", "DATA_KOSZTU", "OBSZAR", "NAZ_OBSZ"
  )  AS 
  SELECT V."TYP_DOK",V."NR_DOK",V."DATA_D",V."NR_KOMP_DOK",V."NR_POZ_DOK",V."WYR",V."NR_ZLEC",V."NR_KOMP_ZLEC",V."NR_POZ",V."NR_KOM_ZLEC_WEW",V."NR_POZ_ZLEC_WEW",V."DO_WAR",V."NR_SZT",V."IL_SZT_CALK",V."NR_KOM_SZYBY",V."ZN_WYK",V."DATA_PROD",V."DATA_SPED",V."NR_WARST",V."WAR_DO",V."KOLEJN",V."NR_OBR",V."SYMB_OBR",V."KOLEJN_OBR",V."IL_OBR",V."JEDN",V."NR_INST_PLAN",V."NR_ZM_PLAN",V."WSP_P",V."NR_INST_WYK",V."NR_ZM_WYK",V."WSP_W",V."DATA_PLAN",V."ZM_PLAN",V."DATA_WYK",V."ZM_WYK",V."WYK",V."COUNT_PARTITION",V."KOD_STR",
       il_obr*wsp_p*KP.koszt1 koszt1P,
       il_obr*wsp_p*KP.koszt2 koszt2P,
       il_obr*wsp_p*KP.narzut1 narzut1P,
       il_obr*wsp_p*KP.narzut2 narzut2P,
       il_obr*nvl(wsp_w,wsp_p)*nvl(KW.koszt1,nvl(K.koszt1,0)) koszt1W,
       il_obr*nvl(wsp_w,wsp_p)*nvl(KW.koszt2,nvl(K.koszt2,0)) koszt2W,
       il_obr*nvl(wsp_w,wsp_p)*nvl(KW.narzut1,nvl(K.narzut1,0)) narzut1W,
       il_obr*nvl(wsp_w,wsp_p)*nvl(KW.narzut2,nvl(K.narzut2,0)) narzut2W,
       il_obr*nvl(wsp_w,wsp_p)*nvl(KW.koszt1,nvl(K.koszt1,KP.koszt1)) koszt1,
       il_obr*nvl(wsp_w,wsp_p)*nvl(KW.koszt2,nvl(K.koszt2,KP.koszt2)) koszt2,
       il_obr*nvl(wsp_w,wsp_p)*nvl(KW.narzut1,nvl(K.narzut1,KP.narzut1)) narzut1,
       il_obr*nvl(wsp_w,wsp_p)*nvl(KW.narzut2,nvl(K.narzut2,KP.narzut2)) narzut2,
       il_obr*nvl(wsp_w,wsp_p)*(nvl(KW.koszt1,nvl(K.koszt1,KP.koszt1))+nvl(KW.koszt2,nvl(K.koszt2,KP.koszt2))+nvl(KW.narzut1,nvl(K.narzut1,KP.narzut1))+nvl(KW.narzut2,nvl(K.narzut2,KP.narzut2))) koszt_std,
/*       il_obr*nvl(wsp_w,wsp_p)*K.koszt2 koszt2,
       il_obr*nvl(wsp_w,wsp_p)*K.koszt2 koszt2,
       il_obr*nvl(wsp_w,wsp_p)*K.narzut1 narzut1,
       il_obr*nvl(wsp_w,wsp_p)*K.narzut2 narzut2, */
       --nvl2(nullif(V.nr_inst_wyk,0),PKG_CZAS.NR_ZM_TO_DATE(V.nr_zm_wyk),nvl2(nullif(V.nr_zm_plan,0),PKG_CZAS.NR_ZM_TO_DATE(V.nr_zm_plan),nvl(nullif(V.data_prod,DATA_ZERO),nvl(nullif(V.data_sped,DATA_ZERO),trunc(sysdate))))) data_kosztu,
       nvl2(nullif(V.nr_inst_wyk,0),PKG_CZAS.NR_ZM_TO_DATE(V.nr_zm_wyk),
            nvl2(K.koszt1,nvl(nullif(V.data_prod,DATA_ZERO),V.data_sped),
                 PKG_CZAS.NR_ZM_TO_DATE(V.nr_zm_plan))) data_kosztu,
       KP.obszar, lokalizacje.naz naz_obsz
FROM
(
select dok.typ_dok, dok.nr_dok, dok.data_d, E.nr_k_wz nr_komp_dok, E.nr_poz_wz nr_poz_dok,
       Z.wyroznik wyr, Z.nr_zlec, E.nr_komp_zlec, E.nr_poz, V.nr_kom_zlec_wew, V.nr_poz_zlec_wew, V.do_war, 
       E.nr_szt, V.ilosc il_szt_calk, E.nr_kom_szyby, E.zn_wyk, E.data_wyk data_prod, E.data_sped,
       L.nr_warst, L.war_do, L.kolejn,  O.nr_k_p_obr nr_obr, O.symb_p_obr symb_obr, O.kolejn_obr,
       case when L.kolejn>300 then V.pow
            when D.nr_komp_obr is null then case when O.met_oblicz=1 then D0.szer_obr*0.002+D0.wys_obr*0.002
                                                 when O.met_oblicz=2 then D0.szer_obr*0.001*D0.wys_obr*0.001
                                                 else 1 end
            when D.strona=4 then            case when O.met_oblicz=1 then D.szer_obr*0.002+D.wys_obr*0.002
                                                 when O.met_oblicz=2 then D.szer_obr*0.001*D.wys_obr*0.001
                                                 else 1 end
            when D.il_pol_szp>0 then D.il_pol_szp
            when D.ilosc_do_wyk>0 then D.ilosc_do_wyk
            else 0
       end il_obr,
       decode(O.met_oblicz,1,'mb',2,'m2',3,'sz',(select jedn from parinst where parinst.nr_komp_inst=L.nr_inst_plan)) jedn,
       L.nr_inst_plan, L.nr_zm_plan, Wp.wsp_alt wsp_p, L.nr_inst_wyk, L.nr_zm_wyk, Ww.wsp_alt wsp_w,
       PKG_CZAS.NR_ZM_TO_DATE(L.nr_zm_plan) data_plan, PKG_CZAS.NR_ZM_TO_ZM(L.nr_zm_plan) zm_plan,
       PKG_CZAS.NR_ZM_TO_DATE(L.nr_zm_wyk) data_wyk, PKG_CZAS.NR_ZM_TO_ZM(L.nr_zm_wyk) zm_wyk,
       case when E.zn_wyk in (1,2) or L.nr_zm_wyk>0 or
                 (select max(nr_zm_wyk) from l_wyc2 L2
                  where L2.nr_kom_zlec=L.nr_kom_zlec and L2.nr_poz_zlec=L.nr_poz_zlec and L2.nr_szt=L.nr_szt
                    and L.nr_warst between L2.nr_warst and L2.war_do and L2.kolejn>=L.kolejn)>0
            then 1 else 0 end wyk,
       count(1) over (partition by E.nr_komp_zlec, E.nr_poz, E.nr_szt, L.nr_warst, L.nr_obr, V.nr_kom_zlec_wew, V.nr_poz_zlec_wew, V.do_war, L.nr_inst_plan, L.nr_zm_plan, L.nr_inst_wyk, L.nr_zm_wyk) count_partition,     
       V.kod_str
--from v_poz_wew V    --pozycje zlecenia glownego + pozycje zlec. wew
--left join spise E on E.nr_komp_zlec=Z.nr_kom_zlec and E.nr_poz=V.nr_poz
from spise E
--left join (select to_date('1901/01','YYYY/MM') DATA_ZERO from dual) on 1=1
left join v_poz_wew V on E.nr_komp_zlec=V.nr_kom_zlec and E.nr_poz=V.nr_poz
left join zamow Z on Z.nr_kom_zlec=V.nr_kom_zlec
left join dok on dok.nr_komp_dok=E.nr_k_wz
left join l_wyc2 L on L.nr_kom_zlec=nvl(V.nr_kom_zlec_wew,V.nr_kom_zlec) and L.nr_poz_zlec=nvl(V.nr_poz_zlec_wew,V.nr_poz) and L.nr_szt=E.nr_szt
left join spisd D on D.nr_kom_zlec=L.nr_kom_zlec and D.nr_poz=L.nr_poz_zlec and D.kol_dod=L.nr_porz_obr-100
left join spisd D0 on D0.nr_kom_zlec=L.nr_kom_zlec and D0.nr_poz=L.nr_poz_zlec and D0.do_war=L.nr_warst and D0.strona=0 and substr(D0.nr_poc,1,1) in (' ','0','1')
left join wsp_alter Wp on Wp.nr_kom_zlec=L.nr_kom_zlec and Wp.nr_poz=L.nr_poz_zlec and Wp.nr_porz_obr=L.nr_porz_obr and Wp.nr_komp_inst=L.nr_inst_plan
left join wsp_alter Ww on Ww.nr_kom_zlec=L.nr_kom_zlec and Ww.nr_poz=L.nr_poz_zlec and Ww.nr_porz_obr=L.nr_porz_obr and Ww.nr_komp_inst=L.nr_inst_wyk
--left join (select 1 pak from dual union select 0 from dual) on pak=zn_wyrobu and not (pak=1 and V.nr_kom_zlec_wew>0)
--left join slparob O on O.nr_k_p_obr=case when pak=0 then L.nr_obr when V.typ_poz='I k' then 112 when V.typ_poz='II ' then 113 else 111 end
left join slparob O on O.nr_k_p_obr=L.nr_obr
where not (E.zn_wyk=9 and E.nr_sped=0 and E.nr_k_wz=0)
  and Z.wyroznik in ('Z','R','B')
UNION
 --pakowanie
SELECT dok.typ_dok, dok.nr_dok, dok.data_d, E.nr_k_wz nr_komp_dok, E.nr_poz_wz nr_poz_dok,
       Z.wyroznik, Z.nr_zlec, Z.nr_kom_zlec, P.nr_poz, 0, 0, 0,
       E.nr_szt, P.ilosc, E.nr_kom_szyby, E.zn_wyk, E.data_wyk data_prod, E.data_sped,
       0, 0, 900, O.nr_k_p_obr, O.symb_p_obr, O.kolejn_obr, P.pow, 'm2' jedn,
       O.nr_komp_inst, PKG_CZAS.NR_KOMP_ZM(Z.d_pl_sped,1), WSP_4ZAKR(O.nr_komp_inst,P.pow,P.ind_bud,0),
       O.nr_komp_inst, PKG_CZAS.NR_KOMP_ZM(E.data_sped,greatest(E.zm_sped,1)), WSP_4ZAKR(O.nr_komp_inst,P.pow,P.ind_bud,0),
       Z.d_pl_sped data_plan, 1 zm_plan, E.data_sped data_wyk, greatest(E.zm_sped,1) zm_wyk, sign(nr_sped) wyk, 1,
       P.kod_str
FROM spise E
LEFT JOIN zamow Z ON Z.nr_kom_zlec=E.nr_komp_zlec
LEFT JOIN spisz P ON P.nr_kom_zlec=Z.nr_kom_zlec and P.nr_poz=E.nr_poz
LEFT JOIN dok on dok.nr_komp_dok=E.nr_k_wz
LEFT JOIN slparob O ON O.nr_k_p_obr=case P.typ_poz when 'I k' then 112 when 'II ' then 113 else 111 end
WHERE Z.wyroznik in ('Z','R') and E.nr_k_wz>0
--WHERE Z.wyroznik in ('Z','R') and (E.nr_k_wz>0 or E.nr_sped>0 or E.zn_wyk<9)
--WHERE not (E.zn_wyk=9 and E.nr_sped=0 and E.nr_k_wz=0)
--  and Z.wyroznik in ('Z','R')
) V
LEFT JOIN (select to_date('1901/01','YYYY/MM') DATA_ZERO from dual) on 1=1
LEFT JOIN koszt_obr_std KP ON KP.nk_obr=V.nr_obr and KP.nk_inst=V.nr_inst_plan and PKG_CZAS.NR_ZM_TO_DATE(V.nr_zm_plan) between KP.d_od and KP.d_do
LEFT JOIN koszt_obr_std KW ON KW.nk_obr=V.nr_obr and KW.nk_inst=V.nr_inst_wyk and PKG_CZAS.NR_ZM_TO_DATE(V.nr_zm_wyk) between KW.d_od and KW.d_do
LEFT JOIN koszt_obr_std K ON K.nk_obr=V.nr_obr and K.nk_inst=V.nr_inst_plan and nvl(nullif(V.data_prod,DATA_ZERO),V.data_sped) between K.d_od and K.d_do
LEFT JOIN lokalizacje ON lokalizacje.nr=KP.obszar
/* do 06/07/2018
LEFT JOIN koszt_obr_std K ON K.nk_obr=V.nr_obr and K.nk_inst=nvl(nullif(V.nr_inst_wyk,0),V.nr_inst_plan) --nk_inst
                             --and nvl2(nullif(L.nr_inst_wyk,0),L.data_wyk,nvl(nullif(L.data_plan,DATA_ZERO),nvl(nullif(E.data_wyk,DATA_ZERO),nvl(nullif(E.data_sped,DATA_ZERO),trunc(sysdate)))))
                             and nvl2(nullif(V.nr_inst_wyk,0),PKG_CZAS.NR_ZM_TO_DATE(V.nr_zm_wyk),nvl2(nullif(V.nr_zm_plan,0),PKG_CZAS.NR_ZM_TO_DATE(V.nr_zm_plan),nvl(nullif(V.data_prod,DATA_ZERO),nvl(nullif(V.data_sped,DATA_ZERO),trunc(sysdate)))))
                                 between K.d_od and K.d_do
*/;
---------------------------
--New VIEW
--V_KOSZT_PROD_ZAK_ALL
---------------------------
CREATE OR REPLACE FORCE VIEW "V_KOSZT_PROD_ZAK_ALL" 
 ( "NR_KOMP_ZLEC", "WYROZNIK", "NR_ZLEC", "NR_POZ", "NR_SZT", "NR_KOM_SZYBY", "DATA_PROD", "DATA_SPED", "NR_KON", "FLAG_R", "FLAG_REAL", "NR_K_WZ", "NR_KOMP_INST", "NR_ZM", "NR_PORZ_OBR", "NR_OBR", "SYMB_OBR", "MET_OBLICZ", "DATA_WYK", "IL_OBR", "WSP_PRZEL", "IL_PRZEL", "JEDN", "KOSZT1", "KOSZT2", "NARZUT1", "NARZUT2", "OBSZAR", "NAZ_OBSZ"
  )  AS 
  SELECT V."NR_KOMP_ZLEC",V."WYROZNIK",V."NR_ZLEC",V."NR_POZ",V."NR_SZT",V."NR_KOM_SZYBY",V."DATA_PROD",V."DATA_SPED",V."NR_KON",V."FLAG_R",V."FLAG_REAL",V."NR_K_WZ",V."NR_KOMP_INST",V."NR_ZM",V."NR_PORZ_OBR",V."NR_OBR",V."SYMB_OBR",V."MET_OBLICZ",V."DATA_WYK",V."IL_OBR",V."WSP_PRZEL", V.il_obr*V.wsp_przel il_przel,
       decode(met_oblicz,1,'mb',2,'m2',3,'sz',(select jedn from parinst where parinst.nr_komp_inst=v.nr_komp_inst)) jedn,
       V.il_obr*V.wsp_przel*nvl(K.koszt1,0) koszt1,
       V.il_obr*V.wsp_przel*nvl(K.koszt2,0) koszt2,
       V.il_obr*V.wsp_przel*nvl(K.narzut1,0) narzut1,
       V.il_obr*V.wsp_przel*nvl(K.narzut2,0) narzut2,     
       K.obszar, lokalizacje.naz naz_obsz
FROM (select * from v_szyby_wyprod_all union all select * from v_szyby_wyprod_pak_all) V
LEFT JOIN koszt_obr_std K ON K.nk_obr=V.nr_obr and K.nk_inst=V.nr_komp_inst and V.data_wyk between K.d_od and K.d_do
LEFT JOIN lokalizacje ON lokalizacje.nr=K.obszar;
---------------------------
--New VIEW
--V_KOSZT_PROD_ZAK
---------------------------
CREATE OR REPLACE FORCE VIEW "V_KOSZT_PROD_ZAK" 
 ( "NR_KOMP_ZLEC", "WYROZNIK", "NR_ZLEC", "NR_POZ", "NR_SZT", "NR_KOM_SZYBY", "DATA_PROD", "DATA_SPED", "NR_KON", "FLAG_R", "FLAG_REAL", "NR_K_WZ", "NR_KOMP_INST", "NR_ZM", "NR_PORZ_OBR", "NR_OBR", "SYMB_OBR", "MET_OBLICZ", "DATA_WYK", "IL_OBR", "WSP_PRZEL", "IL_PRZEL", "JEDN", "KOSZT1", "KOSZT2", "NARZUT1", "NARZUT2", "OBSZAR", "NAZ_OBSZ"
  )  AS 
  SELECT V."NR_KOMP_ZLEC",V."WYROZNIK",V."NR_ZLEC",V."NR_POZ",V."NR_SZT",V."NR_KOM_SZYBY",V."DATA_PROD",V."DATA_SPED",V."NR_KON",V."FLAG_R",V."FLAG_REAL",V."NR_K_WZ",V."NR_KOMP_INST",V."NR_ZM",V."NR_PORZ_OBR",V."NR_OBR",V."SYMB_OBR",V."MET_OBLICZ",V."DATA_WYK",V."IL_OBR",V."WSP_PRZEL", V.il_obr*V.wsp_przel il_przel,
       decode(met_oblicz,1,'mb',2,'m2',3,'sz',(select jedn from parinst where parinst.nr_komp_inst=v.nr_komp_inst)) jedn,
       V.il_obr*V.wsp_przel*nvl(K.koszt1,0) koszt1,
       V.il_obr*V.wsp_przel*nvl(K.koszt2,0) koszt2,
       V.il_obr*V.wsp_przel*nvl(K.narzut1,0) narzut1,
       V.il_obr*V.wsp_przel*nvl(K.narzut2,0) narzut2,     
       K.obszar, lokalizacje.naz naz_obsz
FROM (select * from v_szyby_wyprod union all select * from v_szyby_wyprod_pak_all where nr_k_wz=0) V
LEFT JOIN koszt_obr_std K ON K.nk_obr=V.nr_obr and K.nk_inst=V.nr_komp_inst and V.data_wyk between K.d_od and K.d_do
LEFT JOIN lokalizacje ON lokalizacje.nr=K.obszar;
---------------------------
--New VIEW
--V_KOSZT_PROD_WTOKU
---------------------------
CREATE OR REPLACE FORCE VIEW "V_KOSZT_PROD_WTOKU" 
 ( "NR_KOMP_ZLEC", "WYROZNIK", "NR_ZLEC", "NR_POZ", "NR_SZT", "NR_KOM_SZYBY", "DATA_PROD", "DATA_SPED", "NR_KON", "FLAG_R", "NR_KOMP_INST", "NR_ZM", "NR_PORZ_OBR", "NR_OBR", "SYMB_OBR", "MET_OBLICZ", "DATA_WYK", "IL_OBR", "WSP_PRZEL", "IL_PRZEL", "JEDN", "KOSZT1", "KOSZT2", "NARZUT1", "NARZUT2", "OBSZAR", "NAZ_OBSZ"
  )  AS 
  SELECT V."NR_KOMP_ZLEC",V."WYROZNIK",V."NR_ZLEC",V."NR_POZ",V."NR_SZT",V."NR_KOM_SZYBY",V."DATA_PROD",V."DATA_SPED",V."NR_KON",V."FLAG_R",V."NR_KOMP_INST",V."NR_ZM",V."NR_PORZ_OBR",V."NR_OBR",V."SYMB_OBR",V."MET_OBLICZ",V."DATA_WYK",V."IL_OBR",V."WSP_PRZEL", V.il_obr*V.wsp_przel il_przel,
       decode(V.met_oblicz,1,'mb',2,'m2',3,'sz',(select jedn from parinst where parinst.nr_komp_inst=V.nr_komp_inst)) jedn,
       il_obr*wsp_przel*nvl(K.koszt1,0) koszt1,
       il_obr*wsp_przel*nvl(K.koszt2,0) koszt2,
       il_obr*wsp_przel*nvl(K.narzut1,0) narzut1,
       il_obr*wsp_przel*nvl(K.narzut2,0) narzut2,      
       K.obszar, lokalizacje.naz naz_obsz
FROM v_szyby_wtoku V
LEFT JOIN koszt_obr_std K ON K.nk_obr=V.nr_obr and K.nk_inst=V.nr_komp_inst and V.data_wyk between K.d_od and K.d_do
LEFT JOIN lokalizacje ON lokalizacje.nr=K.obszar;
---------------------------
--New VIEW
--V_KOSZT_PROD_SPRZED
---------------------------
CREATE OR REPLACE FORCE VIEW "V_KOSZT_PROD_SPRZED" 
 ( "NR_KOMP_DOK", "TYP_DOK", "NR_DOK", "NR_POZ_WZ", "DATA_D", "NK_DOKS", "TYP_DOKS", "NR_DOKS", "NR_POZ_DOKS", "ID_POZ_DOKS", "NR_KON", "NR_KOMP_ZLEC", "WYROZNIK", "NR_ZLEC", "NR_POZ", "NR_SZT", "NR_KOM_SZYBY", "DATA_PROD", "DATA_SPED", "FLAG_R", "NR_KOMP_INST", "NR_ZM", "NR_PORZ_OBR", "NR_OBR", "SYMB_OBR", "MET_OBLICZ", "DATA_WYK", "IL_OBR", "WSP_PRZEL", "IL_PRZEL", "JEDN", "KOSZT1", "KOSZT2", "NARZUT1", "NARZUT2", "OBSZAR", "NAZ_OBSZ"
  )  AS 
  SELECT V."NR_KOMP_DOK",V."TYP_DOK",V."NR_DOK",V."NR_POZ_WZ",V."DATA_D",V."NK_DOKS",V."TYP_DOKS",V."NR_DOKS",V."NR_POZ_DOKS",V."ID_POZ_DOKS",V."NR_KON",V."NR_KOMP_ZLEC",V."WYROZNIK",V."NR_ZLEC",V."NR_POZ",V."NR_SZT",V."NR_KOM_SZYBY",V."DATA_PROD",V."DATA_SPED",V."FLAG_R",V."NR_KOMP_INST",V."NR_ZM",V."NR_PORZ_OBR",V."NR_OBR",V."SYMB_OBR",V."MET_OBLICZ",V."DATA_WYK",V."IL_OBR",V."WSP_PRZEL", V.il_obr*V.wsp_przel il_przel,
       decode(met_oblicz,1,'mb',2,'m2',3,'sz',(select jedn from parinst where parinst.nr_komp_inst=v.nr_komp_inst)) jedn,
       V.il_obr*V.wsp_przel*nvl(K.koszt1,0) koszt1,
       V.il_obr*V.wsp_przel*nvl(K.koszt2,0) koszt2,
       V.il_obr*V.wsp_przel*nvl(K.narzut1,0) narzut1,
       V.il_obr*V.wsp_przel*nvl(K.narzut2,0) narzut2,     
       K.obszar, lokalizacje.naz naz_obsz
FROM (select * from v_szyby_sprzed union all select * from v_szyby_sprzed_pak union all select * from v_szyby_wew_sprzed) V
LEFT JOIN koszt_obr_std K ON K.nk_obr=V.nr_obr and K.nk_inst=V.nr_komp_inst and V.data_wyk between K.d_od and K.d_do
LEFT JOIN lokalizacje ON lokalizacje.nr=K.obszar;
---------------------------
--New VIEW
--V_KOSZT_OBR_SZT
---------------------------
CREATE OR REPLACE FORCE VIEW "V_KOSZT_OBR_SZT" 
 ( "WYR", "NR_ZLEC", "NR_KOM_ZLEC", "NR_POZ", "NR_SZT", "IL_SZT_CALK", "ILE_WAR", "NR_OBR", "SYMB_OBR", "KOLEJN_OBR", "SORT_WG_KOLEJN", "NK_INST", "IL_OBR", "IL_PRZEL", "NR_SZYBY", "NR_K_WZ", "NR_POZ_WZ", "DATA_OD", "DATA_DO", "KTORA_DATA", "KOSZT1", "KOSZT2", "NARZUT1", "NARZUT2", "KOSZT_STD"
  )  AS 
  SELECT max(L.wyr) wyr, max(L.nr_zlec) nr_zlec, L.nr_kom_zlec, L.nr_poz, L.nr_szt, 
       max(il_szt_calk) il_szt_calk, count(distinct nvl(L.nr_kom_zlec_wew*10000+L.nr_poz_zlec_wew,0)+L.nr_warst*0.01) ile_war,
       L.nr_obr, max(L.symb_obr) symb_obr, max(L.kolejn_obr) kolejn_obr, max(L.kolejn_obr) sort_wg_kolejn, --zdublowanie KOLEJN_OBR przez b¹d w Oracle11
       --case when L.nr_inst_wyk>0 then L.nr_inst_wyk else L.nr_inst_plan end nk_inst,
       nvl(nullif(L.nr_inst_wyk,0),L.nr_inst_plan) nk_inst,
       sum(il_obr) il_obr, sum(il_obr*nvl(wsp_w,wsp_p)) il_przel,
       max(E.nr_kom_szyby) nr_szyby, max(E.nr_k_wz) nr_k_wz, max(E.nr_poz_wz) nr_poz_wz,
       min(nvl2(nullif(L.nr_inst_wyk,0),L.data_wyk,nvl(nullif(L.data_plan,DATA_ZERO),nvl(nullif(E.data_wyk,DATA_ZERO),nvl(nullif(E.data_sped,DATA_ZERO),DATA_ZERO))))) data_od,
       max(nvl2(nullif(L.nr_inst_wyk,0),L.data_wyk,nvl(nullif(L.data_plan,DATA_ZERO),nvl(nullif(E.data_wyk,DATA_ZERO),nvl(nullif(E.data_sped,DATA_ZERO),DATA_ZERO))))) data_do,
       max(nvl2(nullif(L.nr_inst_wyk,0),2,nvl2(nullif(L.data_plan,DATA_ZERO),1,nvl2(nullif(E.data_wyk,DATA_ZERO),3,nvl2(nullif(E.data_sped,DATA_ZERO),4,0))))) ktora_data,
       sum(il_obr*nvl(wsp_w,wsp_p)*K.koszt1) koszt1,
       sum(il_obr*nvl(wsp_w,wsp_p)*K.koszt2) koszt2,
       sum(il_obr*nvl(wsp_w,wsp_p)*K.narzut1) narzut1,
       sum(il_obr*nvl(wsp_w,wsp_p)*K.narzut2) narzut2,
       sum(il_obr*nvl(wsp_w,wsp_p)*(koszt1+koszt2+narzut1+narzut2)) koszt_std
       --max(L.szer) szer, max(L.wys) wys, max(L.pow) pow, max(L.obw) obw,
       --listagg(kod_str,',') within group (order by do_war) kody_str
from l_wyc2_plus_wew_plus_pak L
left join (select to_date('1901/01','YYYY/MM') DATA_ZERO from dual) on 1=1
left join spise E on E.nr_komp_zlec=L.nr_kom_zlec and E.nr_poz=L.nr_poz and E.nr_szt=L.nr_szt
left join koszt_obr_std K on K.nk_obr=L.nr_obr and K.nk_inst=nvl(nullif(L.nr_inst_wyk,0),L.nr_inst_plan)
                             and nvl2(nullif(L.nr_inst_wyk,0),L.data_wyk,nvl(nullif(L.data_plan,DATA_ZERO),nvl(nullif(E.data_wyk,DATA_ZERO),nvl(nullif(E.data_sped,DATA_ZERO),trunc(sysdate)))))
                                 between K.d_od and K.d_do
                             --and nvl2(nullif(L.nr_inst_wyk,0),L.data_wyk,L.data_plan) between K.d_od and K.d_do    
--left join koszt_obr_std K1 on K1.nk_obr=L.nr_obr and K1.nk_inst=nvl(nullif(L.nr_inst_wyk,0),L.nr_inst_plan)
--                              and nvl(nullif(E.data_wyk,DATA_ZERO),nvl(nullif(E.data_sped,DATA_ZERO),trunc(sysdate))) between K1.d_od and K1.d_do
group by L.nr_kom_zlec, L.nr_poz, L.nr_szt, L.nr_obr,
         --case when L.nr_inst_wyk>0 then L.nr_inst_wyk else L.nr_inst_plan end, --nk_inst
         nvl(nullif(L.nr_inst_wyk,0),L.nr_inst_plan)
order by nr_kom_zlec, nr_poz, nr_szt, sort_wg_kolejn, nk_inst;
---------------------------
--New VIEW
--V_KOSZT_OBR_POZ
---------------------------
CREATE OR REPLACE FORCE VIEW "V_KOSZT_OBR_POZ" 
 ( "WYR", "NR_ZLEC", "NR_KOM_ZLEC", "NR_POZ", "NR_OBR", "SYMB_OBR", "KOLEJN_OBR", "NK_INST", "ILE_SZT", "IL_SZT_CALK", "ILE_WAR", "IL_OBR", "IL_PRZEL", "DATA_OD", "DATA_DO", "KOSZT1", "KOSZT2", "NARZUT1", "NARZUT2", "KOSZT_STD"
  )  AS 
  SELECT max(wyr) wyr, max(nr_zlec) nr_zlec, nr_kom_zlec, nr_poz, nr_obr, max(symb_obr) symb_obr, min(kolejn_obr) kolejn_obr, nk_inst,
       count(distinct nr_szt) ile_szt, max(il_szt_calk) il_szt_calk, sum(ile_war) ile_war,
       sum(il_obr) il_obr, sum(il_przel) il_przel,
       min(data_od) data_od, max(data_do) data_do,
       sum(koszt1) koszt1, sum(koszt2) koszt2, sum(narzut1) narzut1, sum(narzut2) narzut2,
       sum(koszt1+koszt2+narzut1+narzut2) koszt_std
from v_koszt_obr_szt
group by nr_kom_zlec, nr_poz, nr_obr, nk_inst
order by nr_kom_zlec, nr_poz, kolejn_obr, nk_inst;
---------------------------
--New VIEW
--V_KOSZT_OBR_LWYC2
---------------------------
CREATE OR REPLACE FORCE VIEW "V_KOSZT_OBR_LWYC2" 
 ( "WYR", "NR_ZLEC", "NR_KOM_ZLEC", "NR_POZ", "NR_SZT", "IL_SZT_CALK", "NR_KOM_ZLEC_WEW", "NR_POZ_ZLEC_WEW", "DO_WAR", "NR_WARST", "WAR_DO", "NR_OBR", "KOLEJN", "SYMB_OBR", "KOLEJN_OBR", "IL_OBR", "WSP_P", "WSP_W", "IL_PRZEL", "NR_INST_PLAN", "NR_ZM_PLAN", "DATA_PLAN", "ZM_PLAN", "NR_INST_WYK", "NR_ZM_WYK", "DATA_WYK", "ZM_WYK", "NK_INST_KOSZTU", "DATA_KOSZTU", "KOSZT1", "KOSZT2", "NARZUT1", "NARZUT2", "KOSZT_STD"
  )  AS 
  SELECT L.wyr, L.nr_zlec, L.nr_kom_zlec, L.nr_poz, L.nr_szt, L.il_szt_calk, 
       L.nr_kom_zlec_wew, L.nr_poz_zlec_wew, L.do_war , L.nr_warst, L.war_do,
       L.nr_obr, L.kolejn, L.symb_obr, L.kolejn_obr, L.il_obr, wsp_p, wsp_w, il_obr*nvl(wsp_w,wsp_p) il_przel,
       L.nr_inst_plan, L.nr_zm_plan, L.data_plan, L.zm_plan,
       L.nr_inst_wyk, L.nr_zm_wyk, L.data_wyk, L.zm_wyk,
--       case when L.nr_zm_wyk>0 or E.zn_wyk in (1,2) or
--                 (select max(nr_zm_wyk) from l_wyc2 L2
--                  where L2.nr_kom_zlec=L.nr_kom_zlec and L2.nr_poz_zlec=L.nr_poz and L2.nr_szt=L.nr_szt
--                    and L.nr_warst between L2.nr_warst and L2.war_do and L2.kolejn>=L.kolejn)>0
--            then 1 else 0 end wyk,
       nvl(nullif(L.nr_inst_wyk,0),L.nr_inst_plan) nk_inst_kosztu,
       nvl2(nullif(L.nr_inst_wyk,0),L.data_wyk,nvl(nullif(L.data_plan,DATA_ZERO),trunc(sysdate))) data_kosztu,
       --max(E.nr_kom_szyby) nr_szyby, max(E.nr_k_wz) nr_k_wz, max(E.nr_poz_wz) nr_poz_wz,
       --min(nvl2(nullif(L.nr_inst_wyk,0),L.data_wyk,nvl(nullif(L.data_plan,DATA_ZERO),nvl(nullif(E.data_wyk,DATA_ZERO),nvl(nullif(E.data_sped,DATA_ZERO),DATA_ZERO))))) data_od,
       --max(nvl2(nullif(L.nr_inst_wyk,0),L.data_wyk,nvl(nullif(L.data_plan,DATA_ZERO),nvl(nullif(E.data_wyk,DATA_ZERO),nvl(nullif(E.data_sped,DATA_ZERO),DATA_ZERO))))) data_do,
       --max(nvl2(nullif(L.nr_inst_wyk,0),2,nvl2(nullif(L.data_plan,DATA_ZERO),1,nvl2(nullif(E.data_wyk,DATA_ZERO),3,nvl2(nullif(E.data_sped,DATA_ZERO),4,0))))) ktora_data,
       il_obr*nvl(wsp_w,wsp_p)*K.koszt1 koszt1,
       il_obr*nvl(wsp_w,wsp_p)*K.koszt2 koszt2,
       il_obr*nvl(wsp_w,wsp_p)*K.narzut1 narzut1,
       il_obr*nvl(wsp_w,wsp_p)*K.narzut2 narzut2,
       il_obr*nvl(wsp_w,wsp_p)*(koszt1+koszt2+narzut1+narzut2) koszt_std
--from l_wyc2_plus_wew_plus_pak L
from l_wyc2_plus_wew L
left join (select to_date('1901/01','YYYY/MM') DATA_ZERO from dual) on 1=1
--left join spise E on E.nr_komp_zlec=L.nr_kom_zlec and E.nr_poz=L.nr_poz and E.nr_szt=L.nr_szt
--left join dok on dok.nr_komp_dok=E.nr_k_wz
left join koszt_obr_std K on K.nk_obr=L.nr_obr and K.nk_inst=nvl(nullif(L.nr_inst_wyk,0),L.nr_inst_plan) --nk_inst
                             --and nvl2(nullif(L.nr_inst_wyk,0),L.data_wyk,nvl(nullif(L.data_plan,DATA_ZERO),nvl(nullif(E.data_wyk,DATA_ZERO),nvl(nullif(E.data_sped,DATA_ZERO),trunc(sysdate)))))
                             and nvl2(nullif(L.nr_inst_wyk,0),L.data_wyk,nvl(nullif(L.data_plan,DATA_ZERO),trunc(sysdate)))
                                 between K.d_od and K.d_do
order by L.nr_kom_zlec desc, L.nr_poz, L.nr_szt, L.kolejn_obr, nvl(L.do_war,L.nr_warst), L.nr_warst;
---------------------------
--New VIEW
--V_ETYKIETY_PROD2
---------------------------
CREATE OR REPLACE FORCE VIEW "V_ETYKIETY_PROD2" 
 ( "NR_KOMP_ZLEC", "NR_ZLEC", "NR_POZ", "NR_SZT", "NR_WAR", "F_4SERIALNO", "F__4SERIALNO", "F_ZLEC_ORG", "F_ORG_POS", "F_ORG_LAYER", "F_ORG_CUSTOMER", "F_DATA_PLAN_SPED", "F_GLEB_USZCZ", "F_TYPE_ORDER", "F_WEIGHT", "F_PROCESSING_ORDER", "F_ORG_PROCESSING_ORDER"
  )  AS 
  select distinct 
    L.nr_kom_zlec nr_komp_zlec, 
    Z.nr_zlec, 
    L.nr_poz_zlec nr_poz, 
    L.nr_szt, 
    L.nr_warst nr_war,
    L.nr_ser,
    L.nr_ser,
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
    CIAG_PROD(L.nr_kom_zlec,L.nr_poz_zlec,L.nr_szt,L.nr_warst) f_processing_order,
    case(Z.wyroznik)
      when 'W' then CIAG_PROD(z1.nr_kom_zlec,p.nr_poz_pop,1,wew.nr_war_org) 
      when 'B' then CIAG_PROD(z2.nr_kom_zlec,l2.NR_POZ_ZLEC,1,l.nr_warst) 
    end f_org_processing_order
  from l_wyc l    
  left join spisz p on p.NR_KOM_ZLEC=l.nr_kom_zlec and p.NR_POZ=l.nr_poz_zlec
  left join zamow z on z.nr_kom_zlec=l.NR_KOM_ZLEC
  left join zamow z1 on z1.nr_kom_zlec=z.nr_komp_poprz
  left join l_wyc l2 on l2.ID_REK=l.ID_ORYG
  left join zamow z2 on z2.nr_kom_zlec=l2.NR_KOM_ZLEC
  left join v_zlecenia_wew_pozycje wew on wew.nr_komp_zlec=l.nr_kom_zlec and wew.nr_poz=l.nr_poz_zlec and wew.nr_war=L.nr_warst
  left join klient kon on kon.nr_kon=z.nr_kon
  left join klient kon1 on kon1.nr_kon=z1.nr_kon
  left join struktury str on str.kod_str=p.kod_str;
---------------------------
--New VIEW
--VEG_STAT_OP
---------------------------
CREATE OR REPLACE FORCE VIEW "VEG_STAT_OP" 
 ( "ROK", "MIES", "DATA", "CZAS", "GODZ", "IM_NAZW", "NR_ZLEC", "IL_POZ", "IL_SZT", "WART_ZLEC", "WYROZNIK", "TRYB_WPR"
  )  AS 
  SELECT 
  z.ROK,
  z.MIES,
  lt.DATA,
  lt.CZAS,
  SUBSTR(lt.CZAS, 1, 2) GODZ,
  op.IM_NAZW,
  z.NR_ZLEC,
  zi.IL_POZ,
  zi.IL_SZT,
  z.WART_ZLEC,
  z.WYROZNIK,
  z.TRYB_WPR
FROM log_trans lt
INNER JOIN
  (SELECT LOG_TRANS.NR_KOMP_NAG,
    MIN(LOG_TRANS.NKOMP) NKOMP
  FROM LOG_TRANS
  GROUP BY LOG_TRANS.NR_KOMP_NAG
  ) ltf
ON lt.NKOMP        = ltf.NKOMP
AND lt.NR_KOMP_NAG = ltf.NR_KOMP_NAG
INNER JOIN
  (SELECT * FROM ZAMOW
  ) z
ON lt.NR_KOMP_NAG = z.NR_KOM_ZLEC
INNER JOIN
  (SELECT * FROM INFOZLEC
  ) zi
ON z.NR_KOM_ZLEC = zi.NR_KOM_ZLEC
INNER JOIN
  (SELECT * FROM OPERATORZY
  ) op
ON op.ID          = lt.NR_OP
WHERE (z.WYROZNIK = 'Z')
OR (z.WYROZNIK    = 'R');
---------------------------
--Changed VIEW
--VEG_ANALIZA_TRNSPORTU_DATA
---------------------------
CREATE OR REPLACE FORCE VIEW "VEG_ANALIZA_TRNSPORTU_DATA" 
 ( "SKROT_K", "NR_KON", "NR_ZLEC", "DATA_ZL", "WYROZNIK", "STATUS", "FLAG_R", "NR_POZ", "TYP_POZ", "SZT", "POW", "OBW", "WAGA", "GR_PAK", "W_NETTO", "W_BRUTTO", "KOD_STR", "NR_SPED", "NR_REJ", "KIEROWCA", "MARKA_S", "NAZ_TRASY", "NAZWAPH", "FLAG_REAL", "NR_STOJ_SPED", "DATA_SPED", "NR_STOJ", "TYP_STOJ", "STOJ_A", "STOJ_L", "STOJ_P", "NR_KOM_SZYBY", "SZYBA_C", "SZYBA_IK", "SZYBA_IIK", "SZYBA_STR"
  )  AS 
  WITH wart_poz as (
    SELECT
        zt.nr_komp_zlec,
        zt.nr_poz,
        to_number(regexp_substr(zt.linia,'[^|]+',1,1) ) w_netto,
        to_number(regexp_substr(zt.linia,'[^|]+',1,2) ) w_vat,
        to_number(regexp_substr(zt.linia,'[^|]+',1,3) ) w_brutto
    FROM
        zlec_typ zt
    WHERE
        zt.typ = 65
),
sam_sped AS (
    SELECT
        sp.nr_sped,
        sp.data_sped,
        sp.nr_rej,
        sp.kierowca,
        sm.marka_s,
        tr.naz_trasy
    FROM
        spedc sp
        LEFT JOIN trasy tr ON sp.nr_trasy = tr.nr_trasy
        INNER JOIN samoch sm ON TRIM(sp.nr_rej) = TRIM(sm.nr_rej)
) 
SELECT    
    k.skrot_k,
    z.nr_kon,
    z.nr_zlec,
    z.data_zl,
    z.wyroznik,
    z.status,
    z.flag_r,
    sz.nr_poz,
    sz.typ_poz,
    1 AS szt,
    sz.pow,
    sz.obw,
    se.waga,
    s.gr_pak,
    wp.w_netto,
    wp.w_brutto,
    sz.kod_str,
    se.nr_sped,
    sm.nr_rej,
    sm.kierowca,
    sm.marka_s,
    sm.naz_trasy,
    ph.nazwaph,
    se.flag_real,
    se.nr_stoj_sped,
    se.data_sped,
    sts.nr_stoj,
    sts.typ_stoj,
    DECODE(sts.typ_stoj,'A',1,0) stoj_a,
    DECODE(sts.typ_stoj,'L',1,0) stoj_l,
    DECODE(sts.typ_stoj,'C',1,0) stoj_p,
    se.nr_kom_szyby,
    DECODE(sz.typ_poz,'cie',1,0) szyba_c,
    DECODE(sz.typ_poz,'I k',1,0) szyba_ik,
    DECODE(sz.typ_poz,'II ',1,0) szyba_iik,
    DECODE(sz.typ_poz,'str',1,0) szyba_str
  FROM
    zamow z
    INNER JOIN klient k ON z.nr_kon = k.nr_kon
    INNER JOIN cutter.cutter_ph ph ON k.nr_kon = ph.cutter
    INNER JOIN spisz sz ON z.nr_kom_zlec = sz.nr_kom_zlec
    INNER JOIN wart_poz wp ON sz.nr_kom_zlec = wp.nr_komp_zlec
                              AND sz.nr_poz = wp.nr_poz
    INNER JOIN struktury s ON sz.kod_str = s.kod_str
    INNER JOIN spise se ON sz.nr_kom_zlec = se.nr_komp_zlec
                           AND sz.nr_poz = se.nr_poz
    INNER JOIN sam_sped sm ON se.nr_sped = sm.nr_sped
    INNER JOIN stojsped sts ON se.nr_stoj_sped = sts.nr_komp_stoj;
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
--Changed VIEW
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
        (case when nr_war>1 and rodz_sur<>'FOL' and (sum(case when rodz_sur='FOL' then 1 else 0 end) over (partition by nr_komp_zr,nr_kol,nr_war)>0  --il_fol_war>0
           or exists (select 1 from spiss_str S2
                       where S2.zrodlo='S' and S2.nr_komp_zr=S.nr_kom_str and S2.nr_kol=1 and S2.nr_war=S.nr_war-1 and S2.rodz_sur='FOL'))
         then 1 else 0 end) czy_kolejna,  --warstwa po warstwie z foli¹
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
--po szukanie czynnoœci (X1..Xn) po folii (nr_skl+1)
LEFT JOIN budstr B ON B.nr_kom_str=S.nr_kom_str_skl and B.nr_skl=S.nr_skl+1
LEFT JOIN katalog K ON K.nr_kat=B.nr_kom_skl
WHERE (czy_war=1 and czy_kolejna=1 or il_fol_war>0 and (czy_war=1 or S.rodz_sur='FOL' or S.rodz_sur='CZY' and S.znacz_pr='9.La'))
--WHERE il_fol_war2>0
--WHERE 1=1--(etap=1 and czy_war=1 or etap=2)
--  AND S.zrodlo='S' and S.nr_komp_zr=:STR_LAM
ORDER BY S.nr_komp_zr, S.nr_kol, S.LP;
---------------------------
--Changed VIEW
--SPISS_VLACZ
---------------------------
CREATE OR REPLACE FORCE VIEW "SPISS_VLACZ" 
 ( "ZRODLO", "NR_KOMP_ZR", "NR_KOL", "ETAP", "CZY_WAR", "WAR_OD", "WAR_DO", "RODZ_SUR", "STRONA", "NR_PORZ", "ZN_WAR", "SZER", "WYS", "NK_OBR", "SYMB_OBR", "NR_KAT_OBR", "PAR1", "PAR2", "PAR3", "PAR4", "PAR5", "BOKI", "IL_OBR", "IL_SUR", "ZN_PLAN", "INST_STD", "INST_USTAL", "NR_KAT", "KOD_DOD", "ZN_PP", "TYP_KAT", "INDEKS", "IDENT_BUD", "NR_MAG", "NR_KOM_STR", "KOD_STR", "ID_REK", "POZIOM", "IDENT_DOD", "STR_DOD", "CENA"
  )  AS 
  select S.zrodlo, S.nr_komp_zr, S.nr_kol, -1 etap, case when O.obr_lacz=5 then 1 else 0 end czy_war,
        S.nr_war-1 war_od, S.nr_war+1 war_do,
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
       kod_laminatu(S.nr_kom_str,S.nr_war-1,S.nr_war+1) indeks, 
       --ATRYB_SUM(IDENT_ETAP(1,S.ident_spisz), IDENT_ETAP_POP(2,nr_komp_zr,nr_kol,war_od,war_do),
       --          case when S.rodz_sur='FOL' then S.ident_bud_skl
       --               when kod_lam=kod_str then S.ident_spisz
       --               else S.ident_bud end) ident_bud,
       S.ident_bud,
       0 nr_mag, S.nr_kom_str, S.kod_str, S.id_rek, 0 poziom, 0 ident_dod, ' ' str_dod, 0 cena
from spiss_str S
left join slparob O on O.nr_k_p_obr=S.nk_obr
left join (select 0 strona from firma union select 4 from firma) X on O.obr_lacz=5
where O.obr_lacz in (5,6);
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
/* dane obróbek przygotowuj¹ce do l¹czenia przygotowywane w oddzielnej procedurze
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
       3 etap, --zmiana ¿e MON zawsze etap 3 niewazny czy jest LAM
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
                                                           or O.obr_lacz=8) --obr_lacz=8 obróbka pomonta¿owa
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
--New VIEW
--SPED_SYT_VIEW_TR
---------------------------
CREATE OR REPLACE FORCE VIEW "SPED_SYT_VIEW_TR" 
 ( "FILTR", "FLAG", "NR_TRASY", "DATA", "ILOSC", "WAGA", "POW", "IL_STOJ"
  )  AS 
  SELECT filtr, flag_real, nr_trasy, data_sped, sum(ilosc), sum(waga), sum(pow), sum(il_stoj)
  FROM sped_syt_view
  WHERE data_sped is not null AND flag_real>0
  GROUP BY filtr, nr_trasy, flag_real, data_sped
    UNION ALL
  SELECT filtr, 10, nr_trasy, dps, sum(ilosc), sum(waga), sum(pow), sum(il_stoj)
  FROM sped_syt_view
  GROUP BY filtr, nr_trasy, dps
    UNION ALL
  SELECT filtr, 11, nr_trasy, data_kli, sum(ilosc), sum(waga), sum(pow), sum(il_stoj)
  FROM sped_syt_view
  GROUP BY filtr, nr_trasy, data_kli;
---------------------------
--New VIEW
--PROD_SYT_VIEW_ZM
---------------------------
CREATE OR REPLACE FORCE VIEW "PROD_SYT_VIEW_ZM" 
 ( "FILTR", "NR_KOMP_INST", "TYP_INST", "POLOZ", "NR_KOMP_ZM", "DZIEN", "ZMIANA", "SZT_PLAN", "IL_PLAN", "IL_PLAN_PRZEL", "SZT_ZAL", "IL_ZAL", "IL_ZAL_PRZEL", "SZT_ZATW", "IL_ZATW", "IL_ZATW_PRZEL", "SZT_REJ", "IL_REJ", "IL_REJ_PRZEL"
  )  AS 
  SELECT V.filtr, V.nr_komp_inst, max(V.typ_inst) typ_inst, max(V.poloz) poloz, V.nr_komp_zm, max(V.dzien), max(V.zmiana),
        sum(V.szt_plan), sum(V.il_plan), sum(V.il_plan*V.wsp),
        sum(V.szt_zal),  sum(V.il_zal), sum(V.il_zal*V.wsp),
        sum(V.szt_zatw), sum(V.il_zatw), sum(V.il_zatw*V.wsp),
        sum(V.szt_rej),  sum(V.il_rej), sum(V.il_rej*V.wsp)
 FROM PROD_SYT_VIEW V
 GROUP BY V.nr_komp_inst, V.nr_komp_zm, V.filtr;
---------------------------
--New VIEW
--PROD_SYT_VIEW_DZIEN
---------------------------
CREATE OR REPLACE FORCE VIEW "PROD_SYT_VIEW_DZIEN" 
 ( "FILTR", "NR_KOMP_INST", "TYP_INST", "POLOZ", "DZIEN", "SZT_PLAN", "IL_PLAN", "IL_PLAN_PRZEL", "SZT_ZAL", "IL_ZAL", "IL_ZAL_PRZEL", "SZT_ZATW", "IL_ZATW", "IL_ZATW_PRZEL", "SZT_REJ", "IL_REJ", "IL_REJ_PRZEL"
  )  AS 
  SELECT V.filtr, V.nr_komp_inst, max(V.typ_inst) typ_inst, max(V.poloz) poloz, V.dzien,
        sum(V.szt_plan), sum(V.il_plan), sum(V.il_plan*V.wsp),
        sum(V.szt_zal),  sum(V.il_zal), sum(V.il_zal*V.wsp),
        sum(V.szt_zatw), sum(V.il_zatw), sum(V.il_zatw*V.wsp),
        sum(V.szt_rej),  sum(V.il_rej), sum(V.il_rej*V.wsp)
 FROM PROD_SYT_VIEW V
 GROUP BY V.nr_komp_inst, V.dzien, V.filtr;
---------------------------
--New VIEW
--L_WYC2_VS_HARMON1
---------------------------
CREATE OR REPLACE FORCE VIEW "L_WYC2_VS_HARMON1" 
 ( "TYP_HARM", "NK_INST_WYK", "NR_INST_WYK", "NAZ_INST", "KOLEJN_INST", "NR_ZM_WYK", "DATA_WYK", "ZM_WYK", "NR_KOM_ZLEC", "NR_ZLEC", "SZT", "IL_OBR", "IL_PRZEL", "ILOSC", "DANE_Z_ZAM", "WIELKOSC", "KOSZT1", "KOSZT2", "NARZUT1", "NARZUT2", "OBSZAR", "NAZ_OBSZ"
  )  AS 
  select 'W' typ_harm, L.nk_inst_wyk, L.nr_inst_wyk, L.naz_inst, L.kolejn_inst,
       L.nr_zm_wyk, L.data_wyk, L.zm_wyk, 
       L.nr_kom_zlec, L.nr_zlec,
       L.szt, L.il_obr, L.il_przel,
       nvl(H.ilosc,0) ilosc, H.dane_z_zam, H.wielkosc,
       koszt1, koszt2, narzut1, narzut2, obszar, naz_obsz
from
(SELECT NK_INST_WYK, max(nr_inst_wyk) nr_inst_wyk, max(naz_inst_wyk) naz_inst, max(kolejn_inst) kolejn_inst,
        NR_ZM_WYK, PKG_CZAS.NR_ZM_TO_DATE(nr_zm_wyk) data_wyk, PKG_CZAS.NR_ZM_TO_ZM(nr_zm_wyk) zm_wyk,
        nr_kom_zlec, max(nr_zlec) nr_zlec,
        case when max(jedn)=min(jedn) then min(jedn) else null end jedn,
        Sum(szt) szt, Sum(IL_OBR) IL_OBR, Sum(IL_PRZEL) il_przel,
        sum(koszt1) koszt1, sum(koszt2) koszt2, sum(narzut1) narzut1, sum(narzut2) narzut2,
        max(obszar) obszar, max(naz_obsz) naz_obsz
 FROM L_WYC2_POZ
 GROUP BY NK_INST_WYK, NR_ZM_WYK, nr_kom_zlec
) L
left join harmon H on H.nr_komp_zlec=L.nr_kom_zlec and H.typ_harm='W' and H.zatwierdz=1 and H.nr_komp_inst=L.nk_inst_wyk and H.dzien=L.data_wyk and H.zmiana=L.zm_wyk
--WHERE H.typ_harm is null or not (szt=ilosc)-- and abs(il_obr-dane_z_zam)<1)
UNION
select H.typ_harm,  H.nr_komp_inst, H.nr_inst, ' ', 1 kolejn_inst,
       H.nr_komp_zm, H.dzien, H.zmiana, 
       H.nr_komp_zlec, Z.nr_zlec,
       0 szt, 0 il_obr, 0 il_przel,
       H.ilosc, H.dane_z_zam, H.wielkosc,
       0, 0, 0, 0, 0, ' '
       --koszt1, koszt2, narzut1, narzut2, obszar, naz_obsz
from harmon H
left join zamow Z on Z.nr_kom_zlec=H.nr_komp_zlec
where typ_harm='W' and zatwierdz=1
  and not exists (select 1 from l_wyc2 L where L.nr_inst_wyk=H.nr_komp_inst and L.nr_kom_zlec=H.nr_komp_zlec and L.nr_zm_wyk=PKG_CZAS.NR_KOMP_ZM(H.dzien,H.zmiana))
  and dzien='18/08/02'
ORDER BY kolejn_inst, nk_inst_wyk, data_wyk, zm_wyk;
---------------------------
--New VIEW
--L_WYC2_VS_HARMON
---------------------------
CREATE OR REPLACE FORCE VIEW "L_WYC2_VS_HARMON" 
 ( "TYP_HARM", "NK_INST_WYK", "NR_INST_WYK", "NAZ_INST", "KOLEJN_INST", "NR_ZM_WYK", "DATA_WYK", "ZM_WYK", "NR_KOM_ZLEC", "NR_ZLEC", "SZT", "IL_OBR", "IL_PRZEL", "ILOSC", "DANE_Z_ZAM", "WIELKOSC", "KOSZT1", "KOSZT2", "NARZUT1", "NARZUT2", "OBSZAR", "NAZ_OBSZ"
  )  AS 
  select 'W' typ_harm, L.nk_inst_wyk, L.nr_inst_wyk, L.naz_inst, L.kolejn_inst,
       L.nr_zm_wyk, L.data_wyk, L.zm_wyk, 
       L.nr_kom_zlec, L.nr_zlec,
       L.szt, L.il_obr, L.il_przel,
       nvl(H.ilosc,0) ilosc, H.dane_z_zam, H.wielkosc,
       koszt1, koszt2, narzut1, narzut2, obszar, naz_obsz
from
(SELECT NK_INST_WYK, max(nr_inst_wyk) nr_inst_wyk, max(naz_inst_wyk) naz_inst, max(kolejn_inst) kolejn_inst,
        NR_ZM_WYK, PKG_CZAS.NR_ZM_TO_DATE(nr_zm_wyk) data_wyk, PKG_CZAS.NR_ZM_TO_ZM(nr_zm_wyk) zm_wyk,
        nr_kom_zlec, max(nr_zlec) nr_zlec,
        case when max(jedn)=min(jedn) then min(jedn) else null end jedn,
        Sum(szt) szt, Sum(IL_OBR) IL_OBR, Sum(IL_PRZEL) il_przel,
        sum(koszt1) koszt1, sum(koszt2) koszt2, sum(narzut1) narzut1, sum(narzut2) narzut2,
        max(obszar) obszar, max(naz_obsz) naz_obsz
 FROM L_WYC2_POZ
 GROUP BY NK_INST_WYK, NR_ZM_WYK, nr_kom_zlec
) L
left join harmon H on H.nr_komp_zlec=L.nr_kom_zlec and H.typ_harm='W' and H.zatwierdz=1 and H.nr_komp_inst=L.nk_inst_wyk and H.dzien=L.data_wyk and H.zmiana=L.zm_wyk
--WHERE H.typ_harm is null or not (szt=ilosc)-- and abs(il_obr-dane_z_zam)<1)
ORDER BY kolejn_inst, nk_inst_wyk, data_wyk, zm_wyk;
---------------------------
--New VIEW
--L_WYC2_PLUS_WEW_PLUS_PAK
---------------------------
CREATE OR REPLACE FORCE VIEW "L_WYC2_PLUS_WEW_PLUS_PAK" 
 ( "WYR", "NR_ZLEC", "NR_KOM_ZLEC", "NR_POZ", "NR_KOM_ZLEC_WEW", "NR_POZ_ZLEC_WEW", "DO_WAR", "NR_SZT", "IL_SZT_CALK", "NR_WARST", "WAR_DO", "KOLEJN", "NR_OBR", "SYMB_OBR", "KOLEJN_OBR", "IL_OBR", "NR_INST_PLAN", "NR_ZM_PLAN", "WSP_P", "NR_INST_WYK", "NR_ZM_WYK", "WSP_W", "DATA_PLAN", "ZM_PLAN", "DATA_WYK", "ZM_WYK", "KOD_STR"
  )  AS 
  SELECT wyr, nr_zlec, nr_kom_zlec, nr_poz, nr_kom_zlec_wew, nr_poz_zlec_wew, do_war, nr_szt, il_szt_calk, nr_warst, war_do,
        kolejn, nr_obr, symb_obr, kolejn_obr, il_obr,
        nr_inst_plan, nr_zm_plan, wsp_p,
        nr_inst_wyk, nr_zm_wyk, wsp_w,
        data_plan, zm_plan, data_wyk, zm_wyk,
        kod_str
 FROM L_WYC2_PLUS_WEW
 UNION
 --pakowanie
 SELECT Z.wyroznik, Z.nr_zlec, Z.nr_kom_zlec, P.nr_poz, 0, 0, 0, E.nr_szt, P.ilosc, 0, 0,
        900, O.nr_k_p_obr, O.symb_p_obr, O.kolejn_obr, P.pow,
        O.nr_komp_inst, PKG_CZAS.NR_KOMP_ZM(Z.d_pl_sped,1), WSP_4ZAKR(O.nr_komp_inst,P.pow,P.ind_bud,0),
        O.nr_komp_inst, PKG_CZAS.NR_KOMP_ZM(E.data_sped,greatest(E.zm_sped,1)), WSP_4ZAKR(O.nr_komp_inst,P.pow,P.ind_bud,0),
        Z.d_pl_sped, 1, E.data_sped, greatest(E.zm_sped,1),
        P.kod_str
 FROM zamow Z
 LEFT JOIN spisz P ON P.nr_kom_zlec=Z.nr_kom_zlec
 LEFT JOIN spise E ON E.nr_komp_zlec=P.nr_kom_zlec and E.nr_poz=P.nr_poz
 LEFT JOIN slparob O ON O.nr_k_p_obr=case P.typ_poz when 'I k' then 112 when 'II ' then 113 else 111 end
 WHERE Z.do_produkcji=1;
---------------------------
--Changed VIEW
--INFOZLEC
---------------------------
CREATE OR REPLACE FORCE VIEW "INFOZLEC" 
 ( "NR_KOM_ZLEC", "NR_KON", "DATA_ZL", "NR_ZLEC", "NR_ZLEC_KLIENTA", "D_WYS", "D_PL_SPED", "D_SPED_KL", "NR_ZLEC_WEWN", "NR_KON_D", "IL_POZ", "IL_SZT", "IL_PW", "IL_WZ", "IL_FAK", "IL_N_WYS", "STATUS", "FORMA_WPROW", "WYROZNIK", "NR_ADR_DOST"
  )  AS 
  select distinct (zamow.nr_kom_zlec), zamow.nr_kon,
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
 zamow.nr_adr_dost;
