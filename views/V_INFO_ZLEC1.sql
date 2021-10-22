CREATE OR REPLACE VIEW V_INFO_ZLEC1
AS
select row_number() over (order by Z.nr_zlec) lp, Z.nr_kom_zlec, Z.wyroznik, Z.nr_zlec, decode(Z.r_dan,0,'STD',1,'DXF',2,'STD HURT',3,'DXF HURT',' ') rodz, nr_kon, skrot_k,
       Z.il_ciet+Z.I_kom+Z.II_kom+Z.il_strukt il_szt, Z.pow_c+Z.pow_I+Z.pow_II+Z.pow_s pow, strtokenN(replace(T26.linia,',','.'),1,'|','9999999.99') wart,
       Z.il_ciet, Z.pow_c pow_ciet, Z.I_kom il_Ikom, Z.pow_I pow_Ikom,  Z.II_kom il_IIkom, Z.pow_II pow_IIkom, Z.il_strukt il_str, Z.pow_s pow_str,
       Z.data_zl, (select listagg(kod_str,', ') within group (order by kod_str) from (select distinct kod_str from spisz P where P.nr_kom_zlec=Z.nr_kom_zlec)) struktury,
       (select max(data) from statusy_zlec_log where nr_komp_zlec=Z.nr_kom_zlec and status=2) data_oprac,
       (select nvl(max(data),decode(Z.wyroznik,'B',Z.data_zl,null)) from zlec_zm, zlec_zmp where  nk_zlec=Z.nr_kom_zlec and nr_zmiany=nk_zm and tabela_nr=1 and pole_nr=36 and wartosc_po='TRUE') data_skier,
       (select nvl(max(data),decode(Z.wyroznik,'B',Z.data_zl,null)) from log_trans where nr_komp_nag=Z.nr_kom_zlec and tekst like '%NUMERACJA SZYB%') data_metek,
       (select listagg(nr_inst||'['||ty_inst||']'||trim(naz2)||'-'||decode(d_od,d_do,to_char(d_od,'DD/MM'),to_char(d_od,'DD/MM')||':'||to_char(d_do,'DD/MM')),', ') within group (order by kolejn)
        from
        (select nr_kom_zlec, nr_inst_wyk, min(d_wyk) d_od, max(d_wyk) d_do
         from l_wyc
         where nr_inst_wyk>0
         group by nr_kom_zlec, nr_inst_wyk) L
        left join parinst I on I.nr_komp_inst=nr_inst_wyk
        where L.nr_kom_zlec=Z.nr_kom_zlec
        group by L.nr_kom_zlec) wykonanie,       
       (select min(E.data_wyk) from spise E where E.nr_komp_zlec=Z.nr_kom_zlec and E.data_wyk>DATA_ZERO) data_prod_od,
       (select decode(min(E.data_wyk),DATA_ZERO,null,max(E.data_wyk)) from spise E where E.nr_komp_zlec=Z.nr_kom_zlec) data_prod,
       (select min(E.data_sped) from spise E where E.nr_komp_zlec=Z.nr_kom_zlec and E.flag_real=2) data_sped_od,
       (select decode(count(decode(E.flag_real,2,null,1)),0,max(E.data_sped),null) from spise E where E.nr_komp_zlec=Z.nr_kom_zlec) data_sped,
       (select min(F.data_wys) from fakpoz F where typ_doks in ('FV','FE','FDT') and F.id_zlec=Z.nr_kom_zlec) data_fak_od,
       case when Z.flag_r>=20000 then (select max(F.data_wys) from fakpoz F where typ_doks in ('FV','FE','FDT') and F.id_zlec=Z.nr_kom_zlec) else null end data_fak
from zamow Z
left join klient K using (nr_kon)
--left join spisz P on P.nr_kom_zlec=Z.nr_kom_zlec
--left join spise E on E.nr_komp_zlec=Z.nr_kom_zlec and E.nr_poz=P.nr_poz
left join (select to_date('1901/01','YYYY/MM') DATA_ZERO from dual) on 1=1
left join zlec_typ T26 on T26.nr_komp_zlec=Z.nr_kom_zlec and T26.nr_poz=0 and T26.typ=26
where exists (select 1 from spise E where E.nr_komp_zlec=Z.nr_kom_zlec);


select * from v_info_zlec1;

select distinct nr_komp_zlec, nr_komp_instal, d_wyk
from opt_taf T, opt_zlec Z
where T.nr_opt=Z.nr_opt and T.nr_tafli=Z.nr_tafli
  and T.nr_komp_zmw>0;
  
select * from l_wyc where nr_inst_wyk>0 and typ_inst='A C';