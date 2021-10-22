--nowa wersja SPISS_VLACZ dla Bojar, wymaga f. WAR_OD_POLP, WAR_DO_POLP

--DEFINE ZL=249738;
--DEFINE STR=
--
--select nvl(max(S0.nr_war),0)+1
--from spiss_str S0
--where S0.zrodlo='S' and S0.nr_komp_zr=17971
-- and S0.nr_war<7
-- and S0.rodz_sur='LIS'
-- and not exists (select 1 from spiss_str S1, slparob O where S1.zrodlo=S0.zrodlo and S1.nr_komp_zr=S0.nr_komp_zr and S1.nr_war=S0.nr_war and O.nr_k_p_obr=S1.nk_obr and O.obr_lacz=6);

CREATE OR REPLACE FORCE VIEW SPISS_VLACZ AS
  select S.zrodlo, S.nr_komp_zr, S.nr_kol, -1 etap, case when O.obr_lacz=5 then 1 else 0 end czy_war,
        --S.nr_war-1 war_od, S.nr_war+1 war_do,
        WAR_OD_POLP(5, S.nr_kom_str, S.nr_war) war_od,
        WAR_DO_POLP(5, S.nr_kom_str, S.nr_war) war_do,
        --(select nvl(max(war_od),S.nr_war-1) from spiss_vlam S1 where S1.zrodlo=S.zrodlo and S1.nr_komp_zr=S.nr_komp_zr and S1.nr_kol=S.nr_kol and S1.nr_war=S.nr_war-1) war_od,
        --(select nvl(max(war_do),S.nr_war+1) from spiss_vlam S1 where S1.zrodlo=S.zrodlo and S1.nr_komp_zr=S.nr_komp_zr and S1.nr_kol=S.nr_kol and S1.nr_war=S.nr_war+1) war_do,
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
       kod_laminatu(S.nr_kom_str, WAR_OD_POLP(5, S.nr_kom_str, S.nr_war), WAR_DO_POLP(5, S.nr_kom_str, S.nr_war)) indeks,
       --ATRYB_SUM(IDENT_ETAP(1,S.ident_spisz), IDENT_ETAP_POP(2,nr_komp_zr,nr_kol,war_od,war_do),
       --          case when S.rodz_sur='FOL' then S.ident_bud_skl
       --               when kod_lam=kod_str then S.ident_spisz
       --               else S.ident_bud end) ident_bud,
       S.ident_bud,
       0 nr_mag, S.nr_kom_str, S.kod_str, S.id_rek,
       --w proc. SPISS_MAT pole POZIOM wykorzystanr do pominiecia kolejnego wystapienia tej samej obrobki np.ZEL
       row_number() over (partition by zrodlo,nr_komp_zr,nr_kol,etap,nk_obr,WAR_OD_POLP(5,S.nr_kom_str,S.nr_war),X.strona order by lp) poziom,
       0 ident_dod, ' ' str_dod, 0 cena
from spiss_str S
left join slparob O on O.nr_k_p_obr=S.nk_obr
left join (select 0 strona from firma union select 4 from firma) X on O.obr_lacz=5
where --S.nr_komp_zr=&ZL and S.nr_kol=1 and
      O.obr_lacz in (5,6);