select * from parinst;
select * from harmon where typ_harm='W' and nr_komp_inst=16;
select * from struktury;

select * from v_wyk_poz_GRUPTOW_sum1 where nk_inst_wyk in (16,5);
select * from v_wyk_poz_GRUPTOW where nk_inst_wyk in (16,5);

CREATE OR REPLACE VIEW V_WYK_POZ AS
select nr_komp_zlec, nr_poz, nr_komp_instal nk_inst_wyk, indeks kod_str, d_wyk data_wyk, zm_wyk, il_wyk, il_wyk*il_zlec_wyk pow
from wykzal
where flag=3
union
select numer_komputerowy_zlecenia, spisp.nr_poz, spisp.nr_kom_inst_wyk, kod_str, spisp.data_wyk, PKG_CZAS.NR_ZM_TO_ZM(spisp.zm_wyk), spisp.il_wyk, spisp.il_wyk*spisz.pow
from spisp left join spisz on spisz.nr_kom_zlec=numer_komputerowy_zlecenia and spisz.nr_poz=spisp.nr_poz
where nr_kom_inst_wyk>0;

CREATE OR REPLACE VIEW V_WYK_POZ_GRUPTOW AS
select Z.wyroznik, Z.nr_zlec, V.nr_komp_zlec, V.nr_poz, V.data_wyk, V.zm_wyk, V.nk_inst_wyk, V.il_wyk, V.pow,
       S.gr_tow, G.opis, V.kod_str, I.nr_inst, I.naz_inst, I.ty_inst typ_inst
from v_wyk_poz V
left join zamow Z on Z.nr_kom_zlec=V.nr_komp_zlec
left join struktury S on S.kod_str=V.kod_str
left join gruptow G on S.gr_tow=G.gr_tow
left join parinst I on I.nr_komp_inst=V.nk_inst_wyk
order by data_wyk desc, zm_wyk desc, nk_inst_wyk, nr_komp_zlec;

CREATE OR REPLACE VIEW V_WYK_POZ_GRUPTOW_SUM1 AS
select nr_inst, data_wyk, zm_wyk, decode(grouping_id(gr_tow),1,'SUMA',gr_tow) gr_tow, grouping_id(gr_tow) gid,
       sum(decode(wyroznik,'Z',il_wyk,0)) il_wyk_Z, sum(decode(wyroznik,'Z',pow,0)) il_m2_Z,
       sum(decode(wyroznik,'R',il_wyk,0)) il_wyk_R, sum(decode(wyroznik,'R',pow,0)) il_m2_R,
       sum(decode(wyroznik,'W',il_wyk,0)) il_wyk_W, sum(decode(wyroznik,'W',pow,0)) il_m2_W,
       sum(il_wyk) sum_szt, sum(pow) sum_m2,
       decode(grouping_id(gr_tow),1,'GRUPY TOW. RAZEM',max(opis)) opis_grtow,
       nk_inst_wyk, max(naz_inst) naz_inst, max(typ_inst) typ_inst
from v_wyk_poz_gruptow
where gr_tow is not null
group by nr_inst, nk_inst_wyk, data_wyk, zm_wyk, rollup(gr_tow)
order by data_wyk desc, zm_wyk desc, nr_inst;