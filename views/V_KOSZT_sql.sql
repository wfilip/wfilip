CREATE OR REPLACE VIEW V_SZYBY_SPRZED AS
select --dok.nr_komp_dok, dok.typ_dok, dok.nr_dok, dok.data_tr data_d,
       dok.nr_komp_dok, dok.typ_dok, dok.nr_dok, nvl(pozdokSZP.nr_poz,pozdok.nr_poz) nr_poz_wz, dok.data_tr data_d,
       nvl(F.nr_komp_doks,0) nk_doks, nvl(F.typ_doks,0) typ_doks, nvl(F.nr_doks,0) nr_doks, nvl(F.nr_poz,0) nr_poz_doks, nvl(pozdokSZP.id_poz_fak,nvl(F.id_poz,0)) id_poz_doks,
       Z.nr_kon, E.nr_komp_zlec, Z.wyroznik, E.nr_zlec, E.nr_poz, E.nr_szt, E.nr_kom_szyby, E.data_wyk data_prod, E.data_sped, Z.flag_r,
       --ZM.nr_komp_inst, ZM.nr_komp_zm, L2.nr_porz_obr, ZM.dzien data_wyk
       nvl(ZM.nr_komp_inst,L2.nr_inst_plan) nr_komp_inst, nvl(ZM.nr_komp_zm,L2.nr_zm_plan) nr_zm, L2.nr_porz_obr, L2.nr_obr, O.symb_p_obr symb_obr, O.met_oblicz,
       nvl(ZM.dzien,nvl(nullif(E.data_wyk,to_date('1901/01','YYYY/MM')),E.data_sped)) data_wyk,
       case when L2.kolejn>300 then P.pow
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
       nvl(Wp.wsp_alt,1) wsp_przel
from dok
left join pozdok on pozdok.nr_komp_dok=dok.nr_komp_dok
left join spise E on E.nr_k_wz=dok.nr_komp_dok and E.nr_poz_wz=pozdok.nr_poz
left join l_wyc2 L2 on L2.nr_kom_zlec=E.nr_komp_zlec and L2.nr_poz_zlec=E.nr_poz and L2.nr_szt=E.nr_szt
left join zmiany ZM on L2.nr_inst_wyk>0 and ZM.nr_komp_inst=L2.nr_inst_wyk and ZM.nr_komp_zm=L2.nr_zm_wyk
left join zamow Z on Z.nr_kom_zlec=dok.nr_komp_baz--E.nr_komp_zlec
left join spisz P on P.nr_kom_zlec=Z.nr_kom_zlec and P.nr_poz=pozdok.nr_poz_zlec --E.nr_poz
left join spisd D on D.nr_kom_zlec=Z.nr_kom_zlec and D.nr_poz=P.nr_poz and D.kol_dod=L2.nr_porz_obr-100
left join spisd D0 on D0.nr_kom_zlec=Z.nr_kom_zlec and D0.nr_poz=P.nr_poz and D0.do_war=L2.nr_warst and D0.strona=0 and substr(D0.nr_poc,1,1) in (' ','0','1')
left join slparob O on O.nr_k_p_obr=L2.nr_obr
left join wsp_alter Wp ON Wp.nr_kom_zlec=E.nr_komp_zlec and Wp.nr_poz=E.nr_poz and Wp.nr_komp_inst=nvl(ZM.nr_komp_inst,L2.nr_inst_plan) and Wp.nr_porz_obr in (L2.nr_porz_obr,L2.nr_porz_obr-1500)
left join fakpoz F on F.typ_doks in ('FV','FE','FDT') and F.id_zlec=E.nr_komp_zlec and F.id_zlec_poz=E.nr_poz and F.id_poz=pozdok.id_poz_fak and F.lp_dod=0
left join pozdok pozdokSZP on L2.nr_obr=93 and pozdokSZP.nr_komp_dok=dok.nr_komp_dok and pozdokSZP.nr_poz between pozdok.nr_poz+1 and pozdok.nr_poz+2 and pozdokSZP.kol_dod=L2.nr_porz_obr-100
--left join fakpoz F2 on F2.id_zlec=E.nr_komp_zlec and F2.id_zlec_poz=E.nr_poz and F2.id_poz=pozdokSZP.id_poz_fak and F2.lp_dod>0
where dok.typ_dok in ('WZ','WP') and dok.storno=0 and E.nr_k_wz>0 and Z.r_dan<2;
/


CREATE OR REPLACE VIEW V_SZYBY_WEW_SPRZED AS              
select distinct dok.nr_komp_dok, dok.typ_dok, dok.nr_dok, pozdok.nr_poz nr_poz_wz, dok.data_tr data_d,
       nvl(F.nr_komp_doks,0) nk_doks, nvl(F.typ_doks,0) typ_doks, nvl(F.nr_doks,0) nr_doks, nvl(F.nr_poz,0) nr_poz_doks, nvl(F.id_poz,0) id_poz_doks,
       Z0.nr_kon, E.nr_komp_zlec, Z.wyroznik, E.nr_zlec, E.nr_poz, E.nr_szt, E.nr_kom_szyby, E0.data_wyk data_prod, E0.data_sped, Z0.flag_r,
       nvl(ZM.nr_komp_inst,L2.nr_inst_plan) nr_komp_inst, nvl(ZM.nr_komp_zm,L2.nr_zm_plan) nr_zm, L2.nr_porz_obr, L2.nr_obr, O.symb_p_obr symb_obr, O.met_oblicz,
       nvl(ZM.dzien,nvl(nullif(E.data_wyk,to_date('1901/01','YYYY/MM')),E.data_sped)) data_wyk,
       case when L2.kolejn>300 then P.pow
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
       nvl(Wp.wsp_alt,1) wsp_przel
from dok 
left join pozdok on pozdok.nr_komp_dok=dok.nr_komp_dok
left join spise E0 on E0.nr_k_wz=pozdok.nr_komp_dok and E0.nr_poz_wz=pozdok.nr_poz
left join fakpoz F on F.typ_doks in ('FV','FE','FDT') and F.id_zlec=E0.nr_komp_zlec and F.id_zlec_poz=E0.nr_poz and F.id_poz=pozdok.id_poz_fak and F.lp_dod=0
left join zamow Z0 on Z0.nr_kom_zlec=dok.nr_komp_baz
left join spisz P0 on P0.nr_kom_zlec=Z0.nr_kom_zlec and P0.nr_poz=pozdok.nr_poz_zlec--E0.nr_poz
left join zlec_polp ZP on ZP.nr_komp_zlec=E0.nr_komp_zlec and ZP.nr_poz_zlec=E0.nr_poz
--left join (select distinct nr_komp_zlec, nr_poz_zlec, nr_zlec_wew from zlec_polp where nr_zlec_wew>0) ZP on ZP.nr_komp_zlec=dok.nr_komp_baz and ZP.nr_poz_zlec=pozdok.nr_poz_zlec
left join zamow Z on Z.typ_zlec='Pro' and Z.nr_zlec=ZP.nr_zlec_wew-- in (select distinct ZP.nr_zlec_wew from zlec_polp ZP where ZP.nr_komp_zlec=dok.nr_komp_baz and ZP.nr_poz_zlec=pozdok.nr_poz_zlec)
left join spisz P on P.nr_kom_zlec=Z.nr_kom_zlec and P.nr_poz_pop=P0.nr_poz
left join spise E on E.nr_komp_zlec=P.nr_kom_zlec and E.nr_poz=P.nr_poz and E.nr_szt=E0.nr_szt
left join l_wyc2 L2 on L2.nr_kom_zlec=E.nr_komp_zlec and L2.nr_poz_zlec=E.nr_poz and L2.nr_szt=E.nr_szt
left join spisd D on D.nr_kom_zlec=L2.nr_kom_zlec and D.nr_poz=L2.nr_poz_zlec and D.kol_dod=L2.nr_porz_obr-100
left join spisd D0 on D0.nr_kom_zlec=L2.nr_kom_zlec and D0.nr_poz=L2.nr_poz_zlec and D0.do_war=L2.nr_warst and D0.strona=0 and substr(D0.nr_poc,1,1) in (' ','0','1')
left join slparob O on O.nr_k_p_obr=L2.nr_obr
left join zmiany ZM on L2.nr_inst_wyk>0 and ZM.nr_komp_inst=L2.nr_inst_wyk and ZM.nr_komp_zm=L2.nr_zm_wyk
left join wsp_alter Wp ON Wp.nr_kom_zlec=E.nr_komp_zlec and Wp.nr_poz=E.nr_poz and Wp.nr_komp_inst=nvl(ZM.nr_komp_inst,L2.nr_inst_plan) and Wp.nr_porz_obr in (L2.nr_porz_obr,L2.nr_porz_obr-1500)
where dok.typ_dok in ('WZ','WP') and dok.storno=0 and E0.nr_k_wz>0 and Z0.r_dan<2
  and E0.nr_komp_zlec in (select distinct nr_komp_zlec from zlec_polp)
;
/

CREATE OR REPLACE VIEW V_SZYBY_SPRZED_PAK AS
select dok.nr_komp_dok, dok.typ_dok, dok.nr_dok, pozdok.nr_poz nr_poz_wz, dok.data_tr data_d,
       nvl(F.nr_komp_doks,0) nk_doks, nvl(F.typ_doks,0) typ_doks, nvl(F.nr_doks,0) nr_doks, nvl(F.nr_poz,0) nr_poz_doks, nvl(F.id_poz,0) id_poz_doks,
       Z.nr_kon, E.nr_komp_zlec, Z.wyroznik, E.nr_zlec, E.nr_poz, E.nr_szt, E.nr_kom_szyby, E.data_wyk data_prod, E.data_sped, Z.flag_r,
       O.nr_komp_inst, PKG_CZAS.NR_KOMP_ZM(E.data_sped,greatest(E.zm_sped,1)) nr_zm,
       900 nr_porz_obr, O.nr_k_p_obr nr_obr, O.symb_p_obr symb_obr, O.met_oblicz,
       E.d_odcz data_wyk,
       decode(O.met_oblicz,1,P.obw,2,P.pow,3,1,P.pow) il_obr,
       WSP_4ZAKR(O.nr_komp_inst,P.pow,P.ind_bud,0) wsp_przel
from dok
left join pozdok on pozdok.nr_komp_dok=dok.nr_komp_dok
left join spise E on E.nr_k_wz=pozdok.nr_komp_dok and E.nr_poz_wz=pozdok.nr_poz
left join fakpoz F on F.typ_doks in ('FV','FE','FDT') and F.id_zlec=E.nr_komp_zlec and F.id_zlec_poz=E.nr_poz and F.id_poz=pozdok.id_poz_fak and F.lp_dod=0
left join zamow Z on Z.nr_kom_zlec=dok.nr_komp_baz--E.nr_komp_zlec
LEFT JOIN spisz P ON P.nr_kom_zlec=Z.nr_kom_zlec and P.nr_poz=pozdok.nr_poz_zlec--E.nr_poz
LEFT JOIN slparob O ON O.nr_k_p_obr=case P.typ_poz when 'I k' then 112 when 'II ' then 113 else 111 end
WHERE dok.typ_dok in ('WZ','WP') and dok.storno=0 and E.nr_stoj_sped>0 and Z.r_dan<2;
/

CREATE OR REPLACE VIEW V_KOSZT_PROD_SPRZED
AS
SELECT V.*, V.il_obr*V.wsp_przel il_przel,
       decode(met_oblicz,1,'mb',2,'m2',3,'sz',(select jedn from parinst where parinst.nr_komp_inst=v.nr_komp_inst)) jedn,
       V.il_obr*V.wsp_przel*nvl(K.koszt1,0) koszt1,
       V.il_obr*V.wsp_przel*nvl(K.koszt2,0) koszt2,
       V.il_obr*V.wsp_przel*nvl(K.narzut1,0) narzut1,
       V.il_obr*V.wsp_przel*nvl(K.narzut2,0) narzut2,     
       K.obszar, lokalizacje.naz naz_obsz
FROM (select * from v_szyby_sprzed union all select * from v_szyby_sprzed_pak union all select * from v_szyby_wew_sprzed) V
LEFT JOIN koszt_obr_std K ON K.nk_obr=V.nr_obr and K.nk_inst=V.nr_komp_inst and V.data_wyk between K.d_od and K.d_do
LEFT JOIN lokalizacje ON lokalizacje.nr=K.obszar;
/


CREATE OR REPLACE VIEW V_SZYBY_WYPROD AS
select E.nr_komp_zlec, Z.wyroznik, E.nr_zlec, E.nr_poz, E.nr_szt, E.nr_kom_szyby,
       nvl(E0.data_wyk,E.data_wyk) data_prod, nvl(E0.data_sped,E.data_sped) data_sped, nvl(Z0.nr_kon,Z.nr_kon) nr_kon, nvl(Z0.flag_r,Z.flag_r) flag_r,
       nvl(E0.flag_real,E.flag_real) flag_real, nvl(E0.nr_k_wz,E.nr_k_wz) nr_k_wz,
       nvl(ZM.nr_komp_inst,L2.nr_inst_plan) nr_komp_inst, nvl(ZM.nr_komp_zm,L2.nr_zm_plan) nr_zm, L2.nr_porz_obr, L2.nr_obr, O.symb_p_obr symb_obr, O.met_oblicz,
       nvl(ZM.dzien,nvl(nullif(E.data_wyk,to_date('1901/01','YYYY/MM')),E.data_sped)) data_wyk,       
       --L2.nr_inst_wyk nr_komp_inst, L2.nr_zm_wyk nr_zm, L2.nr_porz_obr, L2.nr_obr, O.symb_p_obr symb_obr, ZM.dzien data_wyk,
       case when L2.kolejn>300 then P.pow
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
       nvl(Wp.wsp_alt,1) wsp_przel
from spise E 
left join zamow Z on Z.nr_kom_zlec=E.nr_komp_zlec
left join l_wyc2 L2 on L2.nr_kom_zlec=E.nr_komp_zlec and L2.nr_poz_zlec=E.nr_poz and L2.nr_szt=E.nr_szt
left join zmiany ZM on L2.nr_inst_wyk>0 and ZM.nr_komp_inst=L2.nr_inst_wyk and ZM.nr_komp_zm=L2.nr_zm_wyk
left join spisz P on P.nr_kom_zlec=L2.nr_kom_zlec and P.nr_poz=L2.nr_poz_zlec
left join spisd D on D.nr_kom_zlec=L2.nr_kom_zlec and D.nr_poz=L2.nr_poz_zlec and D.kol_dod=L2.nr_porz_obr-100
left join spisd D0 on D0.nr_kom_zlec=L2.nr_kom_zlec and D0.nr_poz=L2.nr_poz_zlec and D0.do_war=L2.nr_warst and D0.strona=0 and substr(D0.nr_poc,1,1) in (' ','0','1')
left join slparob O on O.nr_k_p_obr=L2.nr_obr
left join wsp_alter Wp ON Wp.nr_kom_zlec=E.nr_komp_zlec and Wp.nr_poz=E.nr_poz and Wp.nr_komp_inst=nvl(ZM.nr_komp_inst,L2.nr_inst_plan) and Wp.nr_porz_obr in (L2.nr_porz_obr,L2.nr_porz_obr-1500)
left join spise E0 on E0.nr_komp_zlec=Z.nr_komp_poprz and E0.nr_poz=P.nr_poz_pop and E0.nr_szt=E.nr_szt
left join zamow Z0 on Z0.nr_kom_zlec=Z.nr_komp_poprz
where E.nr_k_wz=0 and (Z.wyroznik='W' and E0.nr_k_wz=0 and greatest(E0.data_wyk,E0.data_sped)>'1901/01/01' or
                       Z.wyroznik<>'W' and greatest(E.data_wyk,E.data_sped)>'1901/01/01')
  and Z.r_dan<2;
/

CREATE OR REPLACE VIEW V_SZYBY_WYPROD_ALL AS
select E.nr_komp_zlec, Z.wyroznik, E.nr_zlec, E.nr_poz, E.nr_szt, E.nr_kom_szyby,
       nvl(E0.data_wyk,E.data_wyk) data_prod, nvl(E0.data_sped,E.data_sped) data_sped, nvl(Z0.nr_kon,Z.nr_kon) nr_kon, nvl(Z0.flag_r,Z.flag_r) flag_r,
       nvl(E0.flag_real,E.flag_real) flag_real, nvl(E0.nr_k_wz,E.nr_k_wz) nr_k_wz,
       nvl(ZM.nr_komp_inst,L2.nr_inst_plan) nr_komp_inst, nvl(ZM.nr_komp_zm,L2.nr_zm_plan) nr_zm, L2.nr_porz_obr, L2.nr_obr, O.symb_p_obr symb_obr, O.met_oblicz,
       nvl(ZM.dzien,nvl(nullif(E.data_wyk,to_date('1901/01','YYYY/MM')),E.data_sped)) data_wyk,       
       --L2.nr_inst_wyk nr_komp_inst, L2.nr_zm_wyk nr_zm, L2.nr_porz_obr, L2.nr_obr, O.symb_p_obr symb_obr, ZM.dzien data_wyk,
       case when L2.kolejn>300 then P.pow
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
       nvl(Wp.wsp_alt,1) wsp_przel
from spise E 
left join zamow Z on Z.nr_kom_zlec=E.nr_komp_zlec
left join l_wyc2 L2 on L2.nr_kom_zlec=E.nr_komp_zlec and L2.nr_poz_zlec=E.nr_poz and L2.nr_szt=E.nr_szt
left join zmiany ZM on L2.nr_inst_wyk>0 and ZM.nr_komp_inst=L2.nr_inst_wyk and ZM.nr_komp_zm=L2.nr_zm_wyk
left join spisz P on P.nr_kom_zlec=L2.nr_kom_zlec and P.nr_poz=L2.nr_poz_zlec
left join spisd D on D.nr_kom_zlec=L2.nr_kom_zlec and D.nr_poz=L2.nr_poz_zlec and D.kol_dod=L2.nr_porz_obr-100
left join spisd D0 on D0.nr_kom_zlec=L2.nr_kom_zlec and D0.nr_poz=L2.nr_poz_zlec and D0.do_war=L2.nr_warst and D0.strona=0 and substr(D0.nr_poc,1,1) in (' ','0','1')
left join slparob O on O.nr_k_p_obr=L2.nr_obr
left join wsp_alter Wp ON Wp.nr_kom_zlec=E.nr_komp_zlec and Wp.nr_poz=E.nr_poz and Wp.nr_komp_inst=nvl(ZM.nr_komp_inst,L2.nr_inst_plan) and Wp.nr_porz_obr in (L2.nr_porz_obr,L2.nr_porz_obr-1500)
left join spise E0 on E0.nr_komp_zlec=Z.nr_komp_poprz and E0.nr_poz=P.nr_poz_pop and E0.nr_szt=E.nr_szt
left join zamow Z0 on Z0.nr_kom_zlec=Z.nr_komp_poprz
where (Z.wyroznik='W'  and greatest(E0.data_wyk,E0.data_sped)>'1901/01/01' or
       Z.wyroznik<>'W' and greatest(E.data_wyk,E.data_sped)>'1901/01/01')
--where E.nr_k_wz=0 and (Z.wyroznik='W' and E0.nr_k_wz=0 and greatest(E0.data_wyk,E0.data_sped)>'1901/01/01' or
--                       Z.wyroznik<>'W' and greatest(E.data_wyk,E.data_sped)>'1901/01/01')
  and Z.r_dan<2;
/

CREATE OR REPLACE VIEW V_SZYBY_WYPROD_PAK_ALL AS
select E.nr_komp_zlec, Z.wyroznik, E.nr_zlec, E.nr_poz, E.nr_szt, E.nr_kom_szyby,
       E.data_wyk data_prod, E.data_sped, Z.nr_kon, Z.flag_r,
       E.flag_real, E.nr_k_wz,
       O.nr_komp_inst, PKG_CZAS.NR_KOMP_ZM(E.data_sped,greatest(E.zm_sped,1)) nr_zm,
       900 nr_porz_obr, O.nr_k_p_obr nr_obr, O.symb_p_obr symb_obr, O.met_oblicz,
       E.d_odcz data_wyk,
       decode(O.met_oblicz,1,P.obw,2,P.pow,3,1,P.pow) il_obr,
       WSP_4ZAKR(O.nr_komp_inst,P.pow,P.ind_bud,0) wsp_przel
from spise E
left join zamow Z on Z.nr_kom_zlec=E.nr_komp_zlec
LEFT JOIN spisz P ON P.nr_kom_zlec=Z.nr_kom_zlec and P.nr_poz=E.nr_poz
LEFT JOIN slparob O ON O.nr_k_p_obr=case P.typ_poz when 'I k' then 112 when 'II ' then 113 else 111 end
WHERE E.nr_stoj_sped>0 and greatest(E.data_wyk,E.data_sped)>'1901/01/01' and Z.r_dan<2;
/ 

CREATE OR REPLACE VIEW V_KOSZT_PROD_ZAK
AS
SELECT V.*, V.il_obr*V.wsp_przel il_przel,
       decode(met_oblicz,1,'mb',2,'m2',3,'sz',(select jedn from parinst where parinst.nr_komp_inst=v.nr_komp_inst)) jedn,
       V.il_obr*V.wsp_przel*nvl(K.koszt1,0) koszt1,
       V.il_obr*V.wsp_przel*nvl(K.koszt2,0) koszt2,
       V.il_obr*V.wsp_przel*nvl(K.narzut1,0) narzut1,
       V.il_obr*V.wsp_przel*nvl(K.narzut2,0) narzut2,     
       K.obszar, lokalizacje.naz naz_obsz
FROM (select * from v_szyby_wyprod union all select * from v_szyby_wyprod_pak_all where nr_k_wz=0) V
LEFT JOIN koszt_obr_std K ON K.nk_obr=V.nr_obr and K.nk_inst=V.nr_komp_inst and V.data_wyk between K.d_od and K.d_do
LEFT JOIN lokalizacje ON lokalizacje.nr=K.obszar;
/

CREATE OR REPLACE VIEW V_KOSZT_PROD_ZAK_ALL
AS
SELECT V.*, V.il_obr*V.wsp_przel il_przel,
       decode(met_oblicz,1,'mb',2,'m2',3,'sz',(select jedn from parinst where parinst.nr_komp_inst=v.nr_komp_inst)) jedn,
       V.il_obr*V.wsp_przel*nvl(K.koszt1,0) koszt1,
       V.il_obr*V.wsp_przel*nvl(K.koszt2,0) koszt2,
       V.il_obr*V.wsp_przel*nvl(K.narzut1,0) narzut1,
       V.il_obr*V.wsp_przel*nvl(K.narzut2,0) narzut2,     
       K.obszar, lokalizacje.naz naz_obsz
FROM (select * from v_szyby_wyprod_all union all select * from v_szyby_wyprod_pak_all) V
LEFT JOIN koszt_obr_std K ON K.nk_obr=V.nr_obr and K.nk_inst=V.nr_komp_inst and V.data_wyk between K.d_od and K.d_do
LEFT JOIN lokalizacje ON lokalizacje.nr=K.obszar;
/


CREATE OR REPLACE VIEW V_SZYBY_WTOKU AS
select E.nr_komp_zlec, Z.wyroznik, E.nr_zlec, E.nr_poz, E.nr_szt, E.nr_kom_szyby,
       E.data_wyk data_prod, nvl(E0.data_sped,E.data_sped) data_sped, nvl(Z0.nr_kon,Z.nr_kon) nr_kon, nvl(Z0.flag_r,Z.flag_r) flag_r,
       L2.nr_inst_wyk nr_komp_inst, L2.nr_zm_wyk nr_zm, L2.nr_porz_obr, L2.nr_obr, O.symb_p_obr symb_obr, O.met_oblicz,
       ZM.dzien data_wyk,
       case when L2.kolejn>300 then P.pow
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
       nvl(Wp.wsp_alt,1) wsp_przel
from spise E 
left join zamow Z on Z.nr_kom_zlec=E.nr_komp_zlec
left join l_wyc2 L2 on L2.nr_kom_zlec=E.nr_komp_zlec and L2.nr_poz_zlec=E.nr_poz and L2.nr_szt=E.nr_szt
left join zmiany ZM on ZM.nr_komp_inst=L2.nr_inst_wyk and ZM.nr_komp_zm=L2.nr_zm_wyk
left join spisz P on P.nr_kom_zlec=L2.nr_kom_zlec and P.nr_poz=L2.nr_poz_zlec
left join spisd D on D.nr_kom_zlec=L2.nr_kom_zlec and D.nr_poz=L2.nr_poz_zlec and D.kol_dod=L2.nr_porz_obr-100
left join spisd D0 on D0.nr_kom_zlec=L2.nr_kom_zlec and D0.nr_poz=L2.nr_poz_zlec and D0.do_war=L2.nr_warst and D0.strona=0 and substr(D0.nr_poc,1,1) in (' ','0','1')
left join slparob O on O.nr_k_p_obr=L2.nr_obr
left join wsp_alter Wp ON Wp.nr_kom_zlec=E.nr_komp_zlec and Wp.nr_poz=E.nr_poz and Wp.nr_komp_inst=nvl(ZM.nr_komp_inst,L2.nr_inst_plan) and Wp.nr_porz_obr in (L2.nr_porz_obr,L2.nr_porz_obr-1500)
left join spise E0 on Z.wyroznik='W' and E0.nr_komp_zlec=Z.nr_komp_poprz and E0.nr_poz=P.nr_poz_pop and E0.nr_szt=E.nr_szt
left join zamow Z0 on Z0.nr_kom_zlec=Z.nr_komp_poprz
where E.nr_k_wz=0 and L2.nr_inst_wyk>0 and
      (Z.wyroznik='W' and E0.nr_k_wz=0 and greatest(E0.data_wyk,E0.data_sped)='1901/01/01' or
       Z.wyroznik<>'W' and greatest(E.data_wyk,E.data_sped)='1901/01/01')
  and Z.r_dan<2;
--E.data_wyk='1901/01/01' and E.flag_real<2 and L2.nr_inst_wyk>0;
/

CREATE OR REPLACE VIEW V_KOSZT_PROD_WTOKU
AS
SELECT V.*, V.il_obr*V.wsp_przel il_przel,
       decode(V.met_oblicz,1,'mb',2,'m2',3,'sz',(select jedn from parinst where parinst.nr_komp_inst=V.nr_komp_inst)) jedn,
       il_obr*wsp_przel*nvl(K.koszt1,0) koszt1,
       il_obr*wsp_przel*nvl(K.koszt2,0) koszt2,
       il_obr*wsp_przel*nvl(K.narzut1,0) narzut1,
       il_obr*wsp_przel*nvl(K.narzut2,0) narzut2,      
       K.obszar, lokalizacje.naz naz_obsz
FROM v_szyby_wtoku V
LEFT JOIN koszt_obr_std K ON K.nk_obr=V.nr_obr and K.nk_inst=V.nr_komp_inst and V.data_wyk between K.d_od and K.d_do
LEFT JOIN lokalizacje ON lokalizacje.nr=K.obszar;


select count(distinct nr_kom_szyby) ile_szyb, count(1) il_oper, sum(il_obr*wsp_alt) il_przel, sum(koszt1) koszt1, sum(koszt2) koszt2, count(1)-count(koszt1) il_null
from v_koszt_prod_sprzed V
where data_d between :D1 and :D2 and data_wyk between :D1 and :D2;

select count(distinct nr_kom_szyby) ile_szyb, count(1) il_oper, sum(il_obr*wsp_alt) il_przel, sum(koszt1) koszt1, sum(koszt2) koszt2, count(1)-count(koszt1) il_null
from v_koszt_prod_wtoku V
where data_wyk between :D1 and :D2;

select * from v_szyby_wtoku;

select * from v_koszt_std;

select case when data_wyk<'18/07/01' then 0 when data_wyk between '18/07/01' and '18/07/31' then 1 else -1 end prod_w_okresie,
       count(distinct nr_kom_szyby) ile_szyb, count(1) il_oper, sum(il_obr*wsp_alt) il_przel, sum(koszt1) koszt1, sum(koszt2) koszt2, count(1)-count(koszt1) il_null
from v_koszt_prod_sprzed V
where data_d between '18/07/01' and '18/07/31'
group by case when data_wyk<'18/07/01' then 0 when data_wyk between '18/07/01' and '18/07/31' then 1 else -1 end;

select * 
from v_koszt_prod_sprzed V
where data_d between '18/07/01' and '18/07/31' and data_wyk>'18/07/31';

select count(distinct nr_kom_szyby) ile_szyb, count(1) il_oper, sum(il_obr) il_obr
--from (select * from v_szyby_sprzed union select * from v_szyby_WEW_sprzed) V
from v_szyby_wew_sprzed
where data_d between :D1 and :D2 and data_wyk between :D1 and :D2
union
select count(distinct nr_kom_szyby) ile_szyb, count(1) il_oper, sum(il_obr) il_obr
from v_szyby_sprzed
where data_d between :D1 and :D2 and data_wyk between :D1 and :D2;

select count(distinct nr_kom_szyby) ile_szyb, count(1) il_oper, sum(il_obr) il_obr
from (select * from v_szyby_sprzed union all select * from v_szyby_WEW_sprzed) V
where data_d between :D1 and :D2 and data_wyk between :D1 and :D2;

select count(distinct nr_kom_szyby)
from v_szyby_sprzed_pak
where data_d between :D1 and :D2 and data_wyk<:D1;

select *
from v_szyby_sprzed_pak
where data_d between :D1 and :D2 and data_wyk<:D1
  and nr_kom_szyby not in 
  (select distinct nr_kom_szyby
   from v_szyby_sprzed
   where data_d between :D1 and :D2) and data_wyk<:D1;
   
select count(distinct nr_kom_szyby) ile_szyb, count(1) il_oper, sum(il_obr) il_obr, sum(il_obr*wsp_przel) il_przel, sum(koszt1) koszt1
from v_koszt_prod_zak
where data_wyk='18/07/02';data_wyk between :D1 and :D2;

select * from v_szyby_wyprod where data_wyk='18/07/02';