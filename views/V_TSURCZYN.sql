CREATE OR REPLACE VIEW V_TSURCZYN AS
select nr_inst_plan nr_komp_inst, nr_kom_zlec, nr_poz, nr_warst, max(nr_warst_do) nr_warst_do, nr_obr, indeks, kod_dod,
       PKG_CZAS.NR_ZM_TO_DATE(nr_zm_plan) data_plan, PKG_CZAS.NR_ZM_TO_ZM(nr_zm_plan) zm_plan, nr_zm_plan,
       count(1) il_szt_plan, sum(il_obr) il_ze_zlec_plan, sum(il_obr*wsp_p) dane_przel, 'P' typ_harm, min(il_obr) il_jedn,
       PKG_CZAS.NR_ZM_TO_DATE(0) data_wyk, 0 zm_wyk, 0 nr_zm_wyk,
       0 il_szt_wyk, 0 il_ze_zlec_wyk,
       0 nr_kat, max(wsp_p) wsp, 0 nr_czynn, 1 flag, min(il_calk) il_calk
from l_wyc2_obr
where nr_inst_plan<>nr_inst_wyk
group by nr_inst_plan, nr_kom_zlec, nr_poz, nr_warst, nr_obr, indeks, kod_dod, nr_zm_plan
UNION
select nr_inst_wyk, nr_kom_zlec, nr_poz, nr_warst, max(nr_warst_do) nr_warst_do, nr_obr, indeks, kod_dod,
       PKG_CZAS.NR_ZM_TO_DATE(0) data_plan, 0 zm_plan, 0 nr_zm_plan,
       0 il_szt_plan, 0 il_ze_zlec_plan, sum(il_obr*wsp_p) dane_przel, 'W' typ_harm, min(il_obr) il_jedn,
       PKG_CZAS.NR_ZM_TO_DATE(nr_zm_wyk) data_wyk, PKG_CZAS.NR_ZM_TO_ZM(nr_zm_wyk) zm_wyk, nr_zm_wyk,
       count(1) il_szt_wyk, sum(il_obr) il_ze_zlec_wyk,
       0 nr_kat, max(wsp_p), 0 nr_czynn, 3 flag, min(il_calk) il_calk
from l_wyc2_obr
where nr_inst_wyk>0 and nr_inst_plan<>nr_inst_wyk
group by nr_inst_wyk, nr_kom_zlec, nr_poz, nr_warst, nr_obr, indeks, kod_dod, nr_zm_wyk
UNION
select nr_inst_wyk, nr_kom_zlec, nr_poz, nr_warst, max(nr_warst_do) nr_warst_do, nr_obr, indeks, kod_dod,
       PKG_CZAS.NR_ZM_TO_DATE(nr_zm_plan) data_plan, PKG_CZAS.NR_ZM_TO_ZM(nr_zm_plan) zm_plan, nr_zm_plan,
       count(1) il_szt_plan, sum(il_obr) il_ze_zlec_plan, sum(il_obr*wsp_p) dane_przel, 'W' typ_harm,  min(il_obr) il_jedn,
       PKG_CZAS.NR_ZM_TO_DATE(nr_zm_wyk) data_wyk, PKG_CZAS.NR_ZM_TO_ZM(nr_zm_wyk) zm_wyk, nr_zm_wyk,
       count(1) il_szt_wyk, sum(il_obr*wsp_p) il_ze_zlec_wyk,
       0 nr_kat, max(wsp_p), 0 nr_czynn, 3 flag, min(il_calk) il_calk
from l_wyc2_obr
where nr_inst_wyk>0 and nr_inst_plan=nr_inst_wyk
group by nr_inst_wyk, nr_kom_zlec, nr_poz, nr_warst, nr_obr, indeks, kod_dod, nr_zm_plan, nr_zm_wyk
;