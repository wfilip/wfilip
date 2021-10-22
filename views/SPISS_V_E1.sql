CREATE OR REPLACE VIEW SPISS_V_E1
AS
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
 and not (S.rodz_sur='CZY' and exists (select 1 from spisd D, slparob O where D.nr_kom_zlec=S.nr_kom_zlec and D.nr_poz=S.nr_poz and D.do_war=S.nr_war and D.nr_komp_obr>0 and O.nr_k_p_obr=D.nr_komp_obr and (D.nr_komp_obr=S.nk_obr or O.nr_kat_obr=S.nr_kat))); 
/
