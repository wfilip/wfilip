CREATE OR REPLACE VIEW L_WYC2_OBR AS
select Z.nr_kom_zlec, Z.nr_zlec, Z.d_pl_sped, P.nr_poz, P.ilosc il_calk, L.nr_warst, L.war_do nr_warst_do, L.nr_szt, L.nr_obr, L.nr_porz_obr, D.kol_dod,
        case when L.nr_obr=93 then (select sum(il_pol_szp) from spisd D
                                    where D.nr_kom_zlec=L.nr_kom_zlec and D.nr_poz=L.nr_poz_zlec and D.do_war=L.nr_warst
                                      and to_number(trim(substr(nvl(trim(D.nr_poc),'00'),1,2)),'99') between 2 and 10)
             when L.nr_obr=nvl(D.nr_komp_obr,0) then D.ilosc_do_wyk
             when O.obr_lacz>0 then P.pow
             when O.met_oblicz=1 then D04.szer_obr*0.002+D04.wys_obr*0.002
             when O.met_oblicz=2 then D04.szer_obr*0.001*D04.wys_obr*0.001
             else 1
        end il_obr,
        O.symb_p_obr, O.nazwa_p_obr, O.met_oblicz, O.kolejn_obr,
        L.nr_inst_plan, L.nr_zm_plan, L.nr_inst_wyk, L.nr_zm_wyk,
        W.wsp_alt wsp_p,
        case when O.obr_lacz>0 then P.kod_str 
             when L.nr_warst=L.war_do and K.rodz_sur in ('TAF','LIS','TAS') then K.typ_kat
             else D04.kod_dod end indeks, 
        nvl(D.kod_dod,' ') kod_dod
 from zamow Z
 left join spisz P on P.nr_kom_zlec=Z.nr_kom_zlec
 left join l_wyc2 L on L.nr_kom_zlec=Z.nr_kom_zlec and P.nr_poz=L.nr_poz_zlec
 left join slparob O on O.nr_k_p_obr=L.nr_obr
 left join gr_inst_dla_obr G on G.nr_komp_obr=L.nr_obr and G.nr_komp_inst=L.nr_inst_plan
 left join spisd D on D.nr_kom_zlec=Z.nr_kom_zlec and D.nr_poz=L.nr_poz_zlec and D.do_war=L.nr_warst and D.kol_dod=L.nr_porz_obr-100-decode(G.akt,2,1500,0) --instalacja powiazana przesunieta o 1500
 left join spisd D04 on D04.nr_kom_zlec=Z.nr_kom_zlec and D04.nr_poz=L.nr_poz_zlec and D04.do_war=L.nr_warst and D04.strona=case when L.nr_obr in (90,91,92) then 4 else 0 end
 left join katalog K on K.nr_kat=D.nr_kat
 left join wsp_alter W on W.nr_zestawu=0 and W.nr_kom_zlec=L.nr_kom_zlec and W.nr_poz=L.nr_poz_zlec and W.nr_komp_inst=L.nr_inst_plan and W.nr_porz_obr in (L.nr_porz_obr,L.nr_porz_obr-1500)
order by Z.nr_kom_zlec, P.nr_poz, kolejn_obr, L.nr_warst;
