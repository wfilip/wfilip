CREATE OR  REPLACE VIEW V_ODPADY
AS
--ODPADY POWSTA£E
SELECT 'ODP_POW' typ_odp, O.nr_odp, O.nr_kat, O.data_pow, O.brak, O.nr_optym, T.nr_tafli, T.d_wyk d_wyk_opt, T.zm_wyk zm_wyk_opt,
       nvl2(nullif(T.zm_wyk,0),T.d_wyk,O.data_pow) data,
       case
        when O.zm_pow>0 then O.zm_pow
        --when O.nr_optym=0
        --then nvl((select min(zm_wyk)+10*(max(zm_wyk)-min(zm_wyk)) from l_wyc L where typ_inst in ('A C','R C') and L.d_wyk=O.data_pow and L.op=O.numer_operatora),
        --         (select nvl(min(zm_wyk),4) from spise E where E.d_wyk=O.data_pow and E.o_wyk=O.numer_operatora))
        else nvl(T.zm_wyk,0)
       end zm,
       O.nk_inst, O.szerokosc szer, O.wysokosc wys, O.szerokosc*0.001*O.wysokosc*0.001 pow, O.nr_stoj, O.numer_operatora op, O.fl_plan, O.akt,
       trunc(dt_pow) data_rej, to_char(dt_pow,'HH24MISS') czas_rej, sign(O.zm_pow) nowy_zapis
from odpady O
left join opt_taf T on T.nr_opt=O.nr_optym and T.nr_tafli=O.nrt and  O.nr_optym>0-- and T.d_wyk=O.data_pow)
where akt in (1,2,3) and O.nk_wym>=0
UNION ALL
--ODPADY POBRANE
SELECT 'ODP_POB' typ_odp, O.nr_odp, O.nr_kat, O.data_pow, O.brak, O.nr_optym, O.nrt, null, 0 zm_wyk_opt,
       case
        when zm_pob>0 then data_pob
        when t_pob between '000000' and '065959' then O.d_pob-1 else O.d_pob end data,
       case when zm_pob>0 then zm_pob
            when T_pob between '070000' and '185900' then 1
            when T_pob between '190000' and '235959' then 2
            when T_pob between '000000' and '065959' then 2
            else 0 end
       zm,
       O.nk_inst, O.szerokosc szer, O.wysokosc wys, O.szerokosc*0.001*O.wysokosc*0.001 pow, O.nr_stoj, O.o_pob op, O.fl_plan, O.akt,
       d_pob, t_pob, sign(O.zm_pob) nowy_zapis
from odpady O
where akt=2 and nk_wym>=0
UNION ALL
--ODPADY USUNIETE
SELECT 'ODP_DEL' typ_odp, O.nr_odp, O.nr_kat, O.data_pow, O.brak, O.nr_optym, O.nrt, null, 0 zm_wyk_opt,
       case
        when zm_pob>0 then data_pob
        when T_pob between '000000' and '065959' then O.d_pob-1 else O.d_pob end data,
       case when zm_pob>0 then zm_pob
            when T_pob between '070000' and '185900' then 1
            when T_pob between '190000' and '235959' then 2
            when T_pob between '000000' and '065959' then 2
            else 0 end
       zm,
       O.nk_inst, O.szerokosc szer, O.wysokosc wys, O.szerokosc*0.001*O.wysokosc*0.001 pow, O.nr_stoj, O.o_pob op, O.fl_plan, O.akt,
       d_pob, t_pob, sign(O.zm_pow) nowy_zapis
from odpady O
where akt=3 and nk_wym>=0
--ORDER BY typ_odp, nr_odp desc
;

CREATE OR REPLACE VIEW V_ZUZYCIE_SZKLA0
AS
SELECT 'OPT' src, T.nr_komp_instal nk_inst, T.d_wyk, T.zm_wyk, T.nr_kat, --max(T.typ_kat) typ_kat,
       sum(T.wyc_netto) copt_netto, sum(T.wyc_brutto) copt_brutto,
       --sum(T.wyc_brutto*(case when exists (select 1 from kartoteka K where K.nr_kat=T.nr_kat and K.szer=T.szer and K.wys=T.wys) then 1 else 0 end)) copt_brutto_pt,
       sum(T.szer*0.001*T.wys*0.001*(case when exists (select 1 from kartoteka K where K.nr_kat=T.nr_kat and K.szer=T.szer and K.wys=T.wys) then 1 else 0 end)) copt_brutto_pt,
       sum(case when O.akt in (1,2,3) then 0 else round(T.szer*0.001*T.wys*0.001-T.wyc_brutto,2) end) copt_reszta_bez_rej,
       0 CR_netto, 0 CR_brutto,
       0 il_odp_pow, 0 pow_odp_pow, 0 pow_odp_pow_br,
       0 il_odp_pob, 0 pow_odp_pob,
       0 il_odp_us, 0 pow_odp_us,
       0 il_br,0 pow_br,0 pow_br_z_odp
FROM opt_taf T
LEFT JOIN odpady O on O.nr_optym=T.nr_opt and O.nrt=T.nr_tafli and O.fl_plan=1
GROUP BY T.d_wyk, T.zm_wyk, T.nr_komp_instal, T.nr_kat
UNION
--CR
SELECT 'CR' src, W.nr_komp_instal, W.d_wyk, W.zm_wyk, D.nr_kat, 0,0,0,0 copt, sum(W.il_zlec_wyk) CR_netto, 0 CR_brutto,
       0 il_odp_pow, 0 pow_odp_pow, 0 pow_odp_pow_br, 0 il_odp_pob, 0 pow_odp_pob,0 il_odp_us, 0 pow_odp_us,
       0,0,0 br
FROM wykzal W, spisd D, parinst P
WHERE P.ty_inst='R C' and W.nr_komp_instal=P.nr_komp_inst
  and D.nr_kom_zlec=W.nr_komp_zlec and D.nr_poz=W.nr_poz and D.do_war=W.nr_warst and D.strona=4
GROUP BY W.d_wyk, W.zm_wyk, W.nr_komp_instal, D.nr_kat
UNION
--ODPADY_POW
SELECT 'ODP_POW' src, nk_inst, data, zm, nr_kat, 0,0,0,0 copt, 0,0 cr,
        count(1) il_odp_pow, sum(pow) pow_odp_pow, sum(sign(brak)*pow) pow_odp_pow_br,
        0 il_odp_pob, 0 pow_odp_pob, 0 il_odp_us, 0 pow_odp_us, 0,0,0 br
from v_odpady
where typ_odp='ODP_POW'
group by nr_kat, data, zm, nk_inst
UNION
--ODPADY_POB
SELECT 'ODP_POB' src, nk_inst, data, zm, nr_kat, 0,0,0,0 copt, 0,0 cr, 0,0,0 odp_pow, count(1) il_odp_pob, sum(pow) pow_odp_pob, 0 il_odp_us, 0 pow_odp_us, 0,0,0 br
from v_odpady
where typ_odp='ODP_POB'
group by nr_kat, data, zm, nk_inst
UNION
--ODPADY USUNIETE
SELECT 'ODP_DEL' src, nk_inst, data, zm, nr_kat, 0,0,0,0 copt, 0,0 cr, 0,0,0 odp_pow, 0,0 odp_pob, count(1) il_odp_us, sum(pow) pow_odp_us, 0,0,0 br
from v_odpady
where typ_odp='ODP_DEL'
group by nr_kat, data, zm, nk_inst
--BRAKI
UNION 
SELECT 'BRAKI' src, B.inst_pow nk_inst,
        B.data, B.zm, K.nr_kat,  0,0,0,0 copt, 0,0 cr, 0,0,0 odp_pow, 0,0 odp_pob, 0,0 odp_us, count(1) il_br, sum(C.szer*0.001*C.wys*0.001) pow_br,
       sum(case when I.ty_inst in ('A C','R C') and
            -- czy brak na wycietej tafli    
            not exists(select 1 from opt_zlec Z, opt_taf T, kol_stojakow S
                       where Z.nr_komp_zlec=C.nr_kom_zlec and Z.nr_poz=C.nr_poz and Z.nr_kat=K.nr_kat
                         and T.nr_opt=Z.nr_opt and T.nr_tafli=Z.nr_tafli
                         and T.d_wyk=B.data and T.zm_wyk=B.zm and B.inst_pow=T.nr_komp_instal
                         and S.nr_komp_zlec=C.nr_kom_zlec and S.nr_poz=C.nr_poz and S.nr_sztuki=C.nr_szt and S.nr_warstwy=C.nr_war
                         and (S.nr_optym=0 or S.nr_optym=T.nr_opt and S.nr_taf=T.nr_tafli)) and
            -- czy brak z braku cietego z optymalizacji
            not exists (select 1 from braki_b B1
                        left join spisz P on P.nr_kom_zlec=B1.zlec_braki and P.id_poz=B1.id_poz_br
                        --left join kol_stojakow K on K.nr_komp_zlec=B1.zlec_braki and K.nr_poz=P.nr_poz
                        left join opt_zlec Z on Z.nr_komp_zlec=P.nr_kom_zlec and Z.nr_poz=P.nr_poz-- and Z.nr_kat=K.nr_kat
                        left join opt_taf T on T.nr_opt=Z.nr_opt and T.nr_tafli=Z.nr_tafli 
                        where B1.nr_kom_szyby=B.nr_kom_szyby and B1.nr_kol<B.nr_kol
                          and Z.nr_kat=K.nr_kat
                          and T.d_wyk=B.data and T.zm_wyk=B.zm and T.nr_komp_instal=B.inst_pow)
           then C.szer*0.001*C.wys*0.001
           else 0 end) pow_br_z_odp
FROM braki_b B
LEFT JOIN cr_data C on C.id_br=B.nr_kol
LEFT JOIN katalog K on K.typ_kat=C.typ_kat
LEFT JOIN parinst I on I.nr_komp_inst=B.inst_pow
--LEFT JOIN kol_stojakow S on S.nr_listy=P.nr_listy and S.nr_k_zlec=C.nr_kom_zlec and S.nr_poz=C.nr_poz and S.nr_sztuki=C.nr_szt and S.nr_warstwy=C.nr_war
WHERE B.flag<9 --and B.inst_pow in (1,2,3)
GROUP BY B.inst_pow, B.data, B.zm, K.nr_kat;
--ORDER BY d_wyk desc, nr_kat, zm_wyk, nr_komp_instal;

CREATE OR REPLACE VIEW V_ZUZYCIE_SZKLA_ZM
AS
SELECT min(G.nr_gr) nr_gr, min(V0.nk_inst) nk_inst, d_wyk, zm_wyk, nr_kat, max(typ_kat) typ_kat,
       sum(copt_netto) copt_netto, sum(copt_brutto) copt_brutto, sum(copt_brutto_pt) copt_brutto_pt, sum(copt_reszta_bez_rej) copt_reszta_bez_rej,
       sum(cr_netto) cr_netto, sum(cr_brutto) cr_brutto,
       sum(il_odp_pow) il_odp_pow, sum(pow_odp_pow) pow_odp_pow, sum(pow_odp_pow_br) pow_odp_pow_br,
       sum(il_odp_pob) il_odp_pob, sum(pow_odp_pob) pow_odp_pob,
       sum(il_odp_us) il_odp_us, sum(pow_odp_us) pow_odp_us,
       sum(il_br) il_br, sum(pow_br) pow_br, sum(pow_br_z_odp) pow_br_z_odp,
       sum(copt_brutto_pt-copt_netto-cr_netto-(pow_odp_pow-pow_odp_pow_br)+pow_odp_pob+pow_odp_us+(pow_br-pow_br_z_odp)) pow_strat, min(waga) waga_jedn, 
       sum(copt_brutto_pt-copt_netto-cr_netto-(pow_odp_pow-pow_odp_pow_br)+pow_odp_pob+pow_odp_us+(pow_br-pow_br_z_odp))*min(waga) waga_strat
FROM v_zuzycie_szkla0 V0
LEFT JOIN katalog K using (nr_kat)
LEFT JOIN gr_inst G on G.typ=1 and G.nr_komp_inst=V0.nk_inst
GROUP BY d_wyk, zm_wyk, nr_kat, nvl(G.nr_gr,V0.nk_inst)
ORDER BY d_wyk desc, zm_wyk desc, nr_kat;

select * from braki_b where nr_kom_szyby=   18144562;
select * from cr_data where id_br=15173;
--where kod_str like '%040GCOSPT%';
--order by d_rejestr desc;

select * from v_zuzycie_szkla_zm;
select * from v_zuzycie_szkla_zm where typ_kat=:GLASS
order by d_wyk desc, zm_wyk desc, nk_inst;

SELECT 'BRAKI' src, B.inst_pow nk_inst,
        B.data, B.zm, K.nr_kat,  0,0,0,0 copt, 0,0 cr, 0,0,0 odp_pow, 0,0 odp_pob, 0,0 odp_us, count(1) il_br, sum(C.szer*0.001*C.wys*0.001) pow_br,
       sum(case when I.ty_inst='A C' and
            -- czy brak na wycietej tafli    
            not exists(select 1 from kol_stojakow S, opt_taf T
                       where S.nr_komp_zlec=C.nr_kom_zlec and S.nr_poz=C.nr_poz and S.nr_sztuki=C.nr_szt and S.nr_warstwy=C.nr_war
                         and S.nr_optym=T.nr_opt and S.nr_taf=T.nr_tafli
                         and T.d_wyk=B.data and T.zm_wyk=B.zm and B.inst_pow=T.nr_komp_instal)
           then C.szer*0.001*C.wys*0.001
           else 0 end) pow_br_z_odp
FROM braki_b B
LEFT JOIN cr_data C on C.id_br=B.nr_kol
LEFT JOIN katalog K on K.typ_kat=C.typ_kat
LEFT JOIN parinst I on I.nr_komp_inst=B.inst_pow
--LEFT JOIN kol_stojakow S on S.nr_listy=P.nr_listy and S.nr_k_zlec=C.nr_kom_zlec and S.nr_poz=C.nr_poz and S.nr_sztuki=C.nr_szt and S.nr_warstwy=C.nr_war
WHERE B.flag<9 and data='18/10/26'--and B.inst_pow in (1,2,3)
GROUP BY B.inst_pow, B.data, B.zm, K.nr_kat;