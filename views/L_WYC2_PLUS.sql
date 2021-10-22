CREATE OR REPLACE VIEW V_POZ_WEW
AS
select nr_kom_zlec, nr_poz, null nr_kom_zlec_wew, null nr_poz_zlec_wew, null do_war, ilosc, szer, wys, pow, obw, typ_poz, kod_str from spisz
union
select ZP.nr_komp_zlec, P.nr_poz_pop, P.nr_kom_zlec, P.nr_poz, to_number(regexp_substr(ZT.linia,'\d+')),  ilosc, szer, wys, pow, obw, typ_poz, P.kod_str
from 
(select distinct nr_komp_zlec, nr_zlec_wew from zlec_polp) ZP
left join spisz P on typ_zlec='Pro' and nr_zlec=nr_zlec_wew
left join zlec_typ ZT on ZT.nr_komp_zlec=P.nr_kom_zlec and ZT.nr_poz=P.nr_poz and ZT.typ=202
order by 1,2,3 nulls first,4;
/

CREATE OR REPLACE VIEW L_WYC2_PLUS
AS
select Z.wyroznik, Z.nr_zlec, L.nr_kom_zlec, L.nr_poz_zlec, L.nr_szt, L.nr_warst, L.war_do, P.ilosc il_szt_calk,
       L.kolejn,  L.nr_obr, O.symb_p_obr symb_obr, O.kolejn_obr,
       Z.nr_komp_poprz nk_zlec_pop, P.nr_poz_pop,
       (select to_number(regexp_substr(linia,'\d+')) --pierwsza liczba z col. LINIA
        from zlec_typ ZT where ZT.nr_komp_zlec=L.nr_kom_zlec and ZT.nr_poz=L.nr_poz_zlec and ZT.typ=1202) nr_war_pop,
       case when L.kolejn>300 then P.pow
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
       nvl2(nullif(D.nr_komp_obr,0),D.kod_dod,' ') kod_dod,
       decode(O.met_oblicz,1,'mb',2,'m2',3,'sz',Ip.jedn) jedn,
       Wp.wsp_alt wsp_p, Ww.wsp_alt wsp_w,
       L.nr_inst_plan nk_inst_plan, L.nr_zm_plan,
       PKG_CZAS.NR_ZM_TO_DATE(L.nr_zm_plan) data_plan, PKG_CZAS.NR_ZM_TO_ZM(L.nr_zm_plan) zm_plan,
       L.nr_inst_wyk nk_inst_wyk, L.nr_zm_wyk,
       PKG_CZAS.NR_ZM_TO_DATE(L.nr_zm_wyk) data_wyk, PKG_CZAS.NR_ZM_TO_ZM(L.nr_zm_wyk) zm_wyk,
       Ip.nr_inst nr_inst_plan, Ip.naz_inst naz_inst_plan, Ip.fl_cutmon, Ip.kolejn kolejn_inst,
       Iw.nr_inst nr_inst_wyk, Iw.naz_inst naz_inst_wyk,
       case when L.nr_inst_wyk>0 then L.nr_zm_wyk
            else (select min(nr_zm_wyk)
                  from l_wyc2 L2
                  where L.nr_kom_zlec=L2.nr_kom_zlec and L.nr_poz_zlec=L2.nr_poz_zlec and L2.nr_szt=L.nr_szt
                    and L.nr_warst between L2.nr_warst and L2.war_do and L2.kolejn>=L.kolejn and nr_zm_wyk>0)
            end nr_zm_wyk2
from l_wyc2 L
left join zamow Z on Z.nr_kom_zlec=L.nr_kom_zlec
left join spisz P on P.nr_kom_zlec=L.nr_kom_zlec and P.nr_poz=L.nr_poz_zlec
left join spisd D on D.nr_kom_zlec=L.nr_kom_zlec and D.nr_poz=L.nr_poz_zlec and D.kol_dod=L.nr_porz_obr-100
left join spisd D0 on D0.nr_kom_zlec=L.nr_kom_zlec and D0.nr_poz=L.nr_poz_zlec and D0.do_war=L.nr_warst and D0.strona=0 and substr(D0.nr_poc,1,1) in (' ','0','1')
left join wsp_alter Wp on Wp.nr_kom_zlec=L.nr_kom_zlec and Wp.nr_poz=L.nr_poz_zlec and Wp.nr_porz_obr=L.nr_porz_obr and Wp.nr_komp_inst=L.nr_inst_plan
left join wsp_alter Ww on Ww.nr_kom_zlec=L.nr_kom_zlec and Ww.nr_poz=L.nr_poz_zlec and Ww.nr_porz_obr=L.nr_porz_obr and Ww.nr_komp_inst=L.nr_inst_wyk
left join parinst Ip on Ip.nr_komp_inst=L.nr_inst_plan
left join parinst Iw on Iw.nr_komp_inst=L.nr_inst_wyk
left join slparob O on O.nr_k_p_obr=L.nr_obr
where L.nr_kom_zlec>0
order by L.nr_kom_zlec, L.nr_poz_zlec, L.nr_szt, L.nr_warst, L.kolejn;
/

CREATE OR REPLACE VIEW L_WYC2_W_TOKU
AS
select L.nk_inst_wyk, L.nr_inst_wyk, L.naz_inst_wyk, L.kolejn_inst,
       L.nr_zm_wyk, L.data_wyk, L.zm_wyk, 
       L.nr_kom_zlec, L.nr_zlec, L.nr_poz_zlec, L.nr_obr, kod_dod,
       L.il_obr, L.il_obr*nvl(L.wsp_w,L.wsp_p) il_przel,
       decode(O.met_oblicz,1,'mb',2,'m2',3,'sz',(select jedn from parinst where parinst.nr_komp_inst=L.nr_inst_wyk)) jedn,
       case when L.nr_zm_wyk>0 then L.data_wyk
            when L.nr_zm_wyk2>0 then PKG_CZAS.NR_ZM_TO_DATE(L.nr_zm_wyk2)
--            when E.zm_wyk>0 then E.data_wyk
--            when E.nr_sped>0 then E.data_sped
            else to_date('190101','YYYYMM') end data_kosztu1,
            1 wyk,
            PKG_CZAS.NR_ZM_TO_DATE(L.nr_zm_wyk2) data_kosztu
--       L.il_obr*nvl(L.wsp_w,L.wsp_p)*KW.koszt1 koszt1,
--       L.il_obr*nvl(L.wsp_w,L.wsp_p)*KW.koszt2 koszt2,
--       L.il_obr*nvl(L.wsp_w,L.wsp_p)*KW.narzut1 narzut1,
--       L.il_obr*nvl(L.wsp_w,L.wsp_p)*KW.narzut2 narzut2,      
--       KW.obszar, lokalizacje.naz naz_obsz
--FROM SPISE E
--LEFT JOIN L_WYC2_PLUS L ON E.nr_komp_zlec=L.nr_kom_zlec and E.nr_poz=L.nr_poz_zlec and E.nr_szt=L.nr_szt
FROM L_WYC2_PLUS L, spise E, slparob O
--LEFT JOIN spise E ON E.nr_komp_zlec=L.nr_kom_zlec and E.nr_poz=L.nr_poz_zlec and E.nr_szt=L.nr_szt
--left join slparob O on O.nr_k_p_obr=L.nr_obr
--LEFT JOIN koszt_obr_std KW ON KW.nk_obr=L.nr_obr and KW.nk_inst=nvl(nullif(L.nr_inst_wyk,0),L.nk_inst_plan) and PKG_CZAS.NR_ZM_TO_DATE(L.nr_zm_wyk2) between KW.d_od and KW.d_do
--LEFT JOIN lokalizacje ON lokalizacje.nr=KW.obszar
WHERE --(L.nr_kom_zlec,L.nr_poz_zlec,L.nr_szt) in (select nr_komp_zlec,nr_poz,nr_szt from spise where data_wyk='1901/01/01' and nr_sped=0)
      E.nr_komp_zlec=L.nr_kom_zlec and E.nr_poz=L.nr_poz_zlec and E.nr_szt=L.nr_szt
  and O.nr_k_p_obr=L.nr_obr
  and E.data_wyk='1901/01/01' and E.nr_sped=0 
  and L.nr_zm_wyk2>0
  --AND NR_ZM_WYK2 Between PKG_CZAS.NR_KOMP_ZM('2018/08/01',1) And PKG_CZAS.NR_KOMP_ZM('2018/08/01',4)
--ORDER BY kolejn_inst, nk_inst_wyk, data_wyk, zm_wyk;
/
--select sum(il_przel) from l_wyc2_w_toku where DATA_KOSZTU Between :DATA_OD and :DATA_DO;

CREATE OR REPLACE VIEW L_WYC2_VS_HARMON_OLD
AS
select 'W' typ_harm, L.nk_inst_wyk, L.nr_inst_wyk, L.naz_inst, L.kolejn_inst,
       L.nr_zm_wyk, L.data_wyk, L.zm_wyk, 
       L.nr_kom_zlec, L.nr_zlec,
       L.szt, L.il_obr, L.il_przel,
       H.ilosc, H.dane_z_zam, H.wielkosc
from
(SELECT NK_INST_WYK, max(nr_inst_wyk) nr_inst_wyk, max(naz_inst_wyk) naz_inst, max(kolejn_inst) kolejn_inst,
        NR_ZM_WYK, PKG_CZAS.NR_ZM_TO_DATE(nr_zm_wyk) data_wyk, PKG_CZAS.NR_ZM_TO_ZM(nr_zm_wyk) zm_wyk,
        nr_kom_zlec, max(nr_zlec) nr_zlec, count(distinct nr_poz_zlec*1000+nr_obr+nr_szt*0.00001+nr_warst*0.0000001) szt,
        Sum(IL_OBR) IL_OBR, Sum(IL_OBR*WSP_W) il_przel
 FROM L_WYC2_PLUS
 --WHERE (((NR_ZM_WYK) Between PKG_CZAS.NR_KOMP_ZM('2018/06/01',1) And PKG_CZAS.NR_KOMP_ZM('2018/06/30',4)))
 WHERE nk_inst_wyk>0 and nr_kom_zlec>0 and symb_obr<>'DECOAT'
 GROUP BY NK_INST_WYK, NR_ZM_WYK, nr_kom_zlec
) L
left join harmon H on H.nr_komp_zlec=L.nr_kom_zlec and H.typ_harm='W' and H.zatwierdz=1 and H.nr_komp_inst=L.nk_inst_wyk and H.dzien=L.data_wyk and H.zmiana=L.zm_wyk
--WHERE H.typ_harm is null or not (szt=ilosc)-- and abs(il_obr-dane_z_zam)<1)
ORDER BY kolejn_inst, nk_inst_wyk, data_wyk, zm_wyk;
/

CREATE OR REPLACE VIEW L_WYC2_POZ
AS
select 'W' typ_harm, L.nk_inst_wyk, L.nr_inst_wyk, L.naz_inst_wyk, L.kolejn_inst,
       L.nr_zm_wyk, L.data_wyk, L.zm_wyk, 
       L.nr_kom_zlec, L.nr_zlec, L.nr_poz_zlec, L.nr_obr, kod_dod,
       L.szt, L.il_obr, L.il_przel,
       decode(O.met_oblicz,1,'mb',2,'m2',3,'sz',(select jedn from parinst where parinst.nr_komp_inst=L.nr_inst_wyk)) jedn,
       --H.ilosc, H.dane_z_zam, H.wielkosc
       il_przel*KW.koszt1 koszt1,
       il_przel*KW.koszt2 koszt2,
       il_przel*KW.narzut1 narzut1,
       il_przel*KW.narzut2 narzut2,      
       KW.obszar, lokalizacje.naz naz_obsz, PKG_CZAS.NR_ZM_TO_DATE(L.nr_zm_wyk) d
from
(SELECT NK_INST_WYK, max(nr_inst_wyk) nr_inst_wyk, max(naz_inst_wyk) naz_inst_wyk, max(kolejn_inst) kolejn_inst,
        NR_ZM_WYK, PKG_CZAS.NR_ZM_TO_DATE(nr_zm_wyk) data_wyk, PKG_CZAS.NR_ZM_TO_ZM(nr_zm_wyk) zm_wyk,
        nr_kom_zlec, max(nr_zlec) nr_zlec, nr_poz_zlec, nr_obr, kod_dod,
        count(distinct nr_szt*1000+nr_obr+nr_warst*0.01) szt,
        round(Sum(IL_OBR),2) IL_OBR, round(Sum(IL_OBR*WSP_W),2) il_przel
 FROM L_WYC2_PLUS
 --WHERE (((NR_ZM_WYK) Between PKG_CZAS.NR_KOMP_ZM('2018/06/01',1) And PKG_CZAS.NR_KOMP_ZM('2018/06/30',4)))
 WHERE nk_inst_wyk>0 and nr_kom_zlec>0 and symb_obr<>'DECOAT'
 GROUP BY NK_INST_WYK, NR_ZM_WYK, nr_kom_zlec, nr_poz_zlec, nr_obr, kod_dod
) L
left join slparob O on O.nr_k_p_obr=L.nr_obr
LEFT JOIN koszt_obr_std KW ON KW.nk_obr=L.nr_obr and KW.nk_inst=L.nk_inst_wyk and PKG_CZAS.NR_ZM_TO_DATE(L.nr_zm_wyk) between KW.d_od and KW.d_do
LEFT JOIN lokalizacje ON lokalizacje.nr=KW.obszar
--left join harmon H on H.nr_komp_zlec=L.nr_kom_zlec and H.typ_harm='W' and H.zatwierdz=1 and H.nr_komp_inst=L.nk_inst_wyk and H.dzien=L.data_wyk and H.zmiana=L.zm_wyk
--WHERE H.typ_harm is null or not (szt=ilosc)-- and abs(il_obr-dane_z_zam)<1)
ORDER BY kolejn_inst, nk_inst_wyk, data_wyk, zm_wyk;
/

CREATE OR REPLACE VIEW L_WYC2_VS_HARMON
AS
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
/

CREATE OR REPLACE VIEW L_WYC2_PLUS_WEW
AS
select Z.wyroznik wyr, Z.nr_zlec, V.nr_kom_zlec, V.nr_poz, V.nr_kom_zlec_wew, V.nr_poz_zlec_wew, V.do_war, 
       L.nr_szt, V.ilosc il_szt_calk, L.nr_warst, L.war_do, 
       L.kolejn,  L.nr_obr, O.symb_p_obr symb_obr, O.kolejn_obr,
       case when D.nr_komp_obr is null then case when O.met_oblicz=1 then D0.szer_obr*0.002+D0.wys_obr*0.002
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
from v_poz_wew V    --pozycje zlecenia glownego + pozycje zlec. wew
left join zamow Z on Z.nr_kom_zlec=V.nr_kom_zlec
left join l_wyc2 L on L.nr_kom_zlec=nvl(V.nr_kom_zlec_wew,V.nr_kom_zlec) and L.nr_poz_zlec=nvl(V.nr_poz_zlec_wew,V.nr_poz)
left join spisd D on D.nr_kom_zlec=L.nr_kom_zlec and D.nr_poz=L.nr_poz_zlec and D.kol_dod=L.nr_porz_obr-100
left join spisd D0 on D0.nr_kom_zlec=L.nr_kom_zlec and D0.nr_poz=L.nr_poz_zlec and D0.do_war=L.nr_warst and D0.strona=0 and substr(D0.nr_poc,1,1) in (' ','0','1')
left join wsp_alter Wp on Wp.nr_kom_zlec=L.nr_kom_zlec and Wp.nr_poz=L.nr_poz_zlec and Wp.nr_porz_obr=L.nr_porz_obr and Wp.nr_komp_inst=L.nr_inst_plan
left join wsp_alter Ww on Ww.nr_kom_zlec=L.nr_kom_zlec and Ww.nr_poz=L.nr_poz_zlec and Ww.nr_porz_obr=L.nr_porz_obr and Ww.nr_komp_inst=L.nr_inst_wyk
left join slparob O on O.nr_k_p_obr=L.nr_obr
--order by V.nr_kom_zlec, V.nr_poz, V.nk_zlec_wew nulls first, V.nr_poz_wew, L.nr_szt, L.nr_warst, L.kolejn;
order by V.nr_kom_zlec, V.nr_poz, L.nr_szt, O.kolejn_obr, V.nr_kom_zlec_wew nulls first, V.nr_poz_zlec_wew, L.nr_warst;
/
CREATE OR REPLACE VIEW L_WYC2_PLUS_WEW_PLUS_PAK
AS
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
/

CREATE OR REPLACE VIEW V_KOSZT_OBR_LWYC2
AS
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
/

CREATE OR REPLACE VIEW V_KOSZT_OBR_SZT
AS
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
/

CREATE OR REPLACE VIEW V_KOSZT_OBR_POZ
AS
SELECT max(wyr) wyr, max(nr_zlec) nr_zlec, nr_kom_zlec, nr_poz, nr_obr, max(symb_obr) symb_obr, min(kolejn_obr) kolejn_obr, nk_inst,
       count(distinct nr_szt) ile_szt, max(il_szt_calk) il_szt_calk, sum(ile_war) ile_war,
       sum(il_obr) il_obr, sum(il_przel) il_przel,
       min(data_od) data_od, max(data_do) data_do,
       sum(koszt1) koszt1, sum(koszt2) koszt2, sum(narzut1) narzut1, sum(narzut2) narzut2,
       sum(koszt1+koszt2+narzut1+narzut2) koszt_std
from v_koszt_obr_szt
group by nr_kom_zlec, nr_poz, nr_obr, nk_inst
order by nr_kom_zlec, nr_poz, kolejn_obr, nk_inst;


CREATE OR REPLACE VIEW V_KOSZT_STD_VS_FAKPOZ
AS
select F.typ_doks, F.nr_doks, F.nr_komp_doks, F.nr_poz, min(id_zlec) id_zlec, min(id_zlec_poz) id_zlec_poz, min(id_wz) id_wz, min(id_wz_poz) id_wz_poz, min(il_szt) il_szt_fakpoz,
       count(distinct nr_kom_szyby) il_spise, sum(ile_war) sum_szt_obr, sum(il_przel) sum_il_przel, sum(koszt_std) koszt_std,
       min(data_od) data_od, max(data_do) data_do
from fakpoz F
left join spise E on E.nr_komp_zlec=F.id_zlec and E.nr_poz=F.id_zlec_poz and E.nr_k_wz=F.id_wz and E.nr_poz_wz=F.id_wz_poz
left join v_koszt_obr_szt V on V.nr_kom_zlec=F.id_zlec and V.nr_poz=F.id_zlec_poz and V.nr_szt=E.nr_szt
where lp_dod=0 and storno=0
group by nr_komp_doks, F.nr_poz, typ_doks, nr_doks
ORDER BY typ_doks, nr_doks, F.nr_poz;

CREATE OR REPLACE VIEW V_KOSZT_STD_PROD
AS
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

CREATE OR REPLACE VIEW V_KOSZT_STD0
AS
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
  and Z.wyroznik in ('Z','R')
;

CREATE OR REPLACE VIEW V_KOSZT_STD
AS
SELECT V.*,
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
*/                                 

;
