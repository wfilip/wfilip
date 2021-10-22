DROP TABLE TMP_LISTA_POZ;
CREATE GLOBAL TEMPORARY TABLE "TMP_LISTA_POZ" 
(	NK_ZLEC NUMBER(10,0),
    DATA DATE,
 	NR_POZ NUMBER(9,0),
    TYP_POZ CHAR(3),
    KSZT NUMBER(1),
    IDENT_BUD VARCHAR2(100),
    NR_OBR NUMBER(6)
) ON COMMIT PRESERVE ROWS ;
--CREATE UNIQUE INDEX "TMP_LISTA_POZ_PK" ON "TMP_LISTA_ZLEC" ("NK_ZLEC");
CREATE UNIQUE INDEX "TMP_LISTA_POZ_WG_DATY" ON "TMP_LISTA_POZ" (DATA,NK_ZLEC,NR_POZ) ;

--po skompilowaniu widoku 1. raz konieczne ustawienie synonimu na widok o numerze taki jak nr wdrozenia 
--CREATE OR REPLACE SYNONYM SYN_V_OBR_WG_DPS FOR V_OBR_WG_DPS;  --domyslny
--CREATE OR REPLACE SYNONYM SYN_V_OBR_WG_DPS FOR V_OBR_WG_DPS5; --dedykowany dla wdr 5
--CREATE OR REPLACE SYNONYM SYN_V_OBR_WG_DPS_WG_WYR FOR V_OBR_WG_DPS_WG_WYR5;
--desc spisz;

DELETE FROM tmp_lista_zlec;
INSERT INTO tmp_lista_zlec 
 SELECT nr_kom_zlec, d_pl_sped from zamow Z WHERE d_pl_sped=:D;-- between '2021/01/01' and '2021/01/15' and Z.status<>'A' and Z.do_produkcji=1 and Z.d_pl_sped>'2020/06/01';--sysdate-15 --trunc(sysdate,'YY')

DELETE FROM tmp_lista_poz;
insert into TMP_LISTA_POZ
SELECT Z.nr_kom_zlec, d_pl_sped, nr_poz, typ_poz,
       case when P.nr_komp_rys=0 and substr(P.ind_bud,5,4)='0000' then 0 else 1 end kszt,
       atryb_product(ind_bud,nvl(wybr_atr,P.ind_bud)), 0 nr_obr
FROM zamow Z
JOIN spisz P on P.nr_kom_zlec=Z.nr_kom_zlec
LEFT JOIN (select nr_par, str1 wybr_atr from params_tmp where nr_zest=5) PAR on PAR.nr_par=1
WHERE d_pl_sped=:D
;


CREATE OR REPLACE FORCE VIEW V_OBR_W_ZLEC AS
 select TMP.nk_zlec nr_kom_zlec, TMP.data d_pl_sped,--Z.nr_kom_zlec, Z.d_pl_sped,
        P.nr_poz, P.typ_poz,
        '000100001' wybr_atr,
        case when P.nr_komp_rys=0 and substr(P.ind_bud,5,4)='0000' then 0 else 1 end kszt, to_number(substr(P.ind_bud,4,1),'9') szpr,
        rpad(P.ind_bud,50,'0') ind_bud, nvl(K4.ident_bud,nvl(S4.ind_bud,P.ind_bud)) ident_bud_war,
        L.nr_obr, W.wsp_alt * case when O.obr_lacz=2 and nvl(S.wsp_cen,0)>0 then S.wsp_cen else 1 end wsp_p, --dla MON uwzgl. WSP_CEN
        case when L.nr_obr=93 then (select sum(il_pol_szp) from spisd D
                                    where D.nr_kom_zlec=L.nr_kom_zlec and D.nr_poz=L.nr_poz_zlec and D.do_war=L.nr_warst
                                      and to_number(trim(substr(nvl(trim(D.nr_poc),'00'),1,2)),'99') between 2 and 10)
             when L.nr_obr=99 then P.pow
             when L.nr_obr in (96,97) then 1
             else D4.szer_obr*0.001*D4.wys_obr*0.001
        end il_obr,
        O.symb_p_obr, O.nazwa_p_obr, O.met_oblicz, O.kolejn_obr, O.nr_komp_inst nk_inst_obr, O.wyd_h,
        decode(L.kolejn,max(L.kolejn) over (partition by L.nr_kom_zlec, L. nr_poz_zlec, L.nr_szt),1,0) zn_wyrobu,
        E.nr_kom_szyby, E.nr_stoj_sped, E.zn_wyk, case when E.nr_stoj_sped>0 or E.zn_wyk in (1,2) then 1 else 0 end wyk
 from tmp_lista_poz TMP
 join zamow Z on Z.nr_kom_zlec=TMP.nk_zlec
 join spisz P on P.nr_kom_zlec=TMP.nk_zlec
 join struktury S on S.kod_str=P.kod_str 
 join l_wyc2 L on L.nr_kom_zlec=TMP.nk_zlec and L.nr_poz_zlec=P.nr_poz
 join slparob O on O.nr_k_p_obr=L.nr_obr
 join spisd D4 on D4.nr_kom_zlec=Z.nr_kom_zlec and D4.nr_poz=L.nr_poz_zlec and D4.do_war=L.nr_warst and D4.strona=4
 left join spise E on E.nr_komp_zlec=L.nr_kom_zlec and E.nr_poz=L.nr_poz_zlec and E.nr_szt=L.nr_szt
 left join katalog K4 on K4.nr_kat=D4.nr_kat and D4.zn_war='Sur' and L.nr_warst=L.war_do
 left join struktury S4 on S4.kod_str=D4.kod_dod and D4.zn_war<>'Sur'
 left join wsp_alter W on W.nr_zestawu=0 and W.nr_kom_zlec=L.nr_kom_zlec and W.nr_poz=L.nr_poz_zlec and W.nr_porz_obr=L.nr_porz_obr and W.nr_komp_inst=L.nr_inst_plan
 where Z.status<>'A' and Z.do_produkcji=1 and Z.d_pl_sped>'2021/06/01'--sysdate-15 --trunc(sysdate,'YY')
 where nvl(E.zn_wyk,0)<>9
;

CREATE OR REPLACE FORCE VIEW V_OBR_W_ZLEC AS
 select Z.nr_kom_zlec, Z.d_pl_sped, P.nr_poz, P.typ_poz,
        case when P.nr_komp_rys=0 and substr(P.ind_bud,5,4)='0000' then 0 else 1 end kszt, to_number(substr(P.ind_bud,4,1),'9') szpr,
        rpad(P.ind_bud,50,'0') ind_bud, nvl(K4.ident_bud,nvl(S4.ind_bud,P.ind_bud)) ident_bud_war,
        L.nr_obr, W.wsp_alt * case when O.obr_lacz=2 and nvl(S.wsp_cen,0)>0 then S.wsp_cen else 1 end wsp_p, --dla MON uwzgl. WSP_CEN
        case when L.nr_obr=93 then (select sum(il_pol_szp) from spisd D
                                    where D.nr_kom_zlec=L.nr_kom_zlec and D.nr_poz=L.nr_poz_zlec and D.do_war=L.nr_warst
                                      and to_number(trim(substr(nvl(trim(D.nr_poc),'00'),1,2)),'99') between 2 and 10)
             when L.nr_obr=99 then P.pow
             when L.nr_obr in (96,97) then 1
             else D4.szer_obr*0.001*D4.wys_obr*0.001
        end il_obr,
        O.symb_p_obr, O.nazwa_p_obr, O.met_oblicz, O.kolejn_obr, O.nr_komp_inst nk_inst_obr, O.wyd_h,
        decode(L.kolejn,max(L.kolejn) over (partition by Z.nr_kom_zlec, P.nr_poz, L.nr_szt),1,0) zn_wyrobu,
        E.nr_kom_szyby, E.nr_stoj_sped, E.zn_wyk, case when E.nr_stoj_sped>0 or E.zn_wyk in (1,2) then 1 else 0 end wyk
 from zamow Z
 left join spisz P on P.nr_kom_zlec=Z.nr_kom_zlec
 left join l_wyc2 L on L.nr_kom_zlec=Z.nr_kom_zlec and L.nr_poz_zlec=P.nr_poz
 left join spise E on E.nr_komp_zlec=L.nr_kom_zlec and E.nr_poz=L.nr_poz_zlec and E.nr_szt=L.nr_szt
 left join struktury S on S.kod_str=P.kod_str 
 left join spisd D4 on D4.nr_kom_zlec=Z.nr_kom_zlec and D4.nr_poz=L.nr_poz_zlec and D4.do_war=L.nr_warst and D4.strona=4
 left join katalog K4 on K4.nr_kat=D4.nr_kat and D4.zn_war='Sur' and L.nr_warst=L.war_do
 left join struktury S4 on S4.kod_str=D4.kod_dod and D4.zn_war<>'Sur'
 left join wsp_alter W on W.nr_zestawu=0 and W.nr_kom_zlec=L.nr_kom_zlec and W.nr_poz=L.nr_poz_zlec and W.nr_porz_obr=L.nr_porz_obr and W.nr_komp_inst=L.nr_inst_plan
 left join slparob O on O.nr_k_p_obr=L.nr_obr
 where Z.status<>'A' and Z.do_produkcji=1
   --and Z.d_pl_sped>sysdate-15 --trunc(sysdate,'YY')
   --and Z.d_pl_sped='2021/01/08'
   and nvl(E.zn_wyk,0)<>9
   --and Z.nr_kom_zlec in (select nk_zlec from tmp_lista_zlec)
;

--INSERT INTO params_tmp (nr_zest, nr_par, str1) VALUES (5,1,'000000001');
UPDATE params_tmp set str1='000100001';
select * from params_tmp;
select * from zamow where nr_kom_zlec in (select nk_zlec from tmp_lista_zlec);
select * from V_OBR_WG_DPS_WG_WYR5 where d_pl_sped=:D and grup=:GRUP;
select d_pl_sped, max(nr_zlec), max(nr_kom_zlec), count(1) from zamow group by d_pl_sped order by 1 desc;

CREATE OR REPLACE FORCE VIEW V_OBR_WG_DPS_WG_WYR5 AS
  SELECT nvl2(d_pl_sped,'D','T') grup, nvl(d_pl_sped,trunc(d_pl_sped,'D')) d_pl_sped,
       --rank() over (partition by d_pl_sped order by typ_poz, kszt nulls first, szpr nulls first) sort,
       rank() over (partition by nvl2(d_pl_sped,'D','T'), d_pl_sped
                    order by typ_poz, nr_obr, atryb_product(ind_bud,nvl(wybr_atr,ind_bud)) nulls first,
                             --length(replace(atryb_product(ind_bud,nvl(wybr_atr,ind_bud)),'0','')) desc nulls first,
                             kszt nulls first) sort,
       typ_poz, nr_obr, kszt, sum(nvl(kszt,0)) il_szt_kszt,
       nvl2(kszt,lag(count(1))over (partition by nvl2(d_pl_sped,'D','T'), d_pl_sped, typ_poz, nr_obr, atryb_product(ind_bud,nvl(wybr_atr,ind_bud))
                          order by kszt nulls first)
                ,0) il_szt_atr, --length(replace(atryb_product(ind_bud,nvl(wybr_atr,ind_bud)),'0','')) len_atr0,        
       max(wybr_atr) ident_bud_szukany, atryb_product(ind_bud,nvl(wybr_atr,ind_bud)) ident_bud_istn,
       sign(instr(atryb_product(ind_bud,nvl(wybr_atr,ind_bud)),'1')) atr,
       case when grouping_id(atryb_product(ind_bud,nvl(wybr_atr,ind_bud)))=0
            then nvl((select listagg(do_wydruku,'+') within group (order by nr_znacznika)
                      from atryb_dod
                      where nr_znacznika>0 and substr(atryb_product(ind_bud,nvl(wybr_atr,ind_bud)),nr_znacznika,1)='1')
                     ,'-')
            else 'RAZEM' end  atr_desc,
       nvl2(d_pl_sped,(count(1) over (partition by nvl2(d_pl_sped,'D','T'), d_pl_sped, typ_poz, nr_obr, kszt)),
                      (count(1) over (partition by nvl2(d_pl_sped,'D','T'), trunc(d_pl_sped,'D'),typ_poz, nr_obr, kszt))
           )-1 il_rec_atr,
       nvl2(d_pl_sped,(row_number() over (partition by nvl2(d_pl_sped,'D','T'), d_pl_sped, typ_poz, nr_obr order by atryb_product(ind_bud,nvl(wybr_atr,ind_bud)) nulls first, kszt nulls first)),
                      (row_number() over (partition by nvl2(d_pl_sped,'D','T'), trunc(d_pl_sped,'D'),typ_poz,nr_obr  order by atryb_product(ind_bud,nvl(wybr_atr,ind_bud)) nulls first, kszt nulls first))
           ) ktory_rec_obr,    
       max(kolejn_obr) kolejn_obr, max(symb_p_obr) symb_obr, max(nazwa_p_obr) naz_obr,
       count(1) il_szt, sum(il_obr) il_rzecz, sum(il_obr*wsp_p) il_przel, count(distinct nr_kom_zlec) il_zl,
       count(nr_kom_szyby) il_szt_w_prod, sum(nvl2(nr_kom_szyby,1,0)*il_obr) il_rzecz_w_prod, sum(nvl2(nr_kom_szyby,1,0)*il_obr*wsp_p) il_przel_w_prod, count(distinct nvl2(nr_kom_szyby,nr_kom_zlec,null)) il_zl_w_prod,
       count(nullif(wyk,0)) il_szt_wyk, sum(wyk*il_obr) il_rzecz_wyk, sum(wyk*il_obr*wsp_p) il_przel_wyk, count(distinct nr_kom_zlec)-count(distinct case when wyk=1 then null else nr_kom_zlec end) il_zl_wyk,
       max(nr_kom_zlec) max_zl, nvl2(d_pl_sped,d_pl_sped-trunc(sysdate),(trunc(d_pl_sped,'D')-trunc(sysdate,'D'))/7) pozostalo
FROM V_OBR_W_ZLEC
LEFT JOIN (select nr_par, str1 wybr_atr from params_tmp where nr_zest=5) PAR on PAR.nr_par=1
WHERE zn_wyrobu=1 and nr_obr>0 --and d_pl_sped=:D
GROUP BY trunc(d_pl_sped,'D'), rollup(d_pl_sped), nr_obr, typ_poz, cube(kszt, atryb_product(ind_bud,nvl(wybr_atr,ind_bud)))
--HAVING NOT (grouping_id(kszt)=0 and grouping_id(atryb_product(ind_bud,nvl(wybr_atr,ind_bud)))=1) AND nvl(kszt,1)=1
HAVING nvl(kszt,1)=1
ORDER BY d_pl_sped, sort;

CREATE OR REPLACE FORCE VIEW V_OBR_WG_DPS_WG_WYR AS
SELECT nvl2(d_pl_sped,'D','T') grup, nvl(d_pl_sped,trunc(d_pl_sped,'D')) d_pl_sped,
       typ_poz, kszt, szpr, nr_obr,
       max(kolejn_obr) kolejn_obr, max(symb_p_obr) symb_obr, max(nazwa_p_obr) naz_obr,
       max(wyd_h) wyd_h, 
       sum((select sum(dl_zmiany) from zmiany where nr_komp_inst=nk_inst_obr and dzien=d_pl_sped)) il_godz,
       count(1) il_szt, sum(il_obr) il_rzecz, sum(il_obr*wsp_p) il_przel, count(distinct nr_kom_zlec) il_zl,
       count(nr_kom_szyby) il_szt_w_prod, sum(nvl2(nr_kom_szyby,1,0)*il_obr) il_rzecz_w_prod, sum(nvl2(nr_kom_szyby,1,0)*il_obr*wsp_p) il_przel_w_prod, count(distinct nvl2(nr_kom_szyby,nr_kom_zlec,null)) il_zl_w_prod,
       count(nullif(wyk,0)) il_szt_wyk, sum(wyk*il_obr) il_rzecz_wyk, sum(wyk*il_obr*wsp_p) il_przel_wyk, count(distinct nr_kom_zlec)-count(distinct case when wyk=1 then null else nr_kom_zlec end) il_zl_wyk,
       max(nr_kom_zlec) max_zl, nvl2(d_pl_sped,d_pl_sped-trunc(sysdate),(trunc(d_pl_sped,'D')-trunc(sysdate,'D'))/7) pozostalo
FROM V_OBR_W_ZLEC
WHERE zn_wyrobu=1 and nr_obr>0
GROUP BY trunc(d_pl_sped,'D'), rollup(d_pl_sped), nr_obr, typ_poz, cube(kszt, szpr)
--HAVING NOT (kszt is not null and szpr is null)
HAVING  grouping_id(kszt,szpr)=3 or grouping_id(kszt,szpr)=2 and szpr=1 and kszt is null or grouping_id(kszt,szpr)=1 and kszt=1 and szpr is null or grouping_id(kszt,szpr)=0 and szpr*kszt=1  --bez rekordu "ile bez ksztat?w" oraz "ile ksztat?w" bez szprosu
ORDER BY d_pl_sped desc, kolejn_obr, nr_obr;

select * from atryb_dod;
select * from parinst;
select * from v_obr_wg_dps_wg_wyr where d_pl_sped=:DPS;
select * from v_obr_wg_dps24;-- where d_pl_sped>=:DPS;
select * FROM V_OBR_W_ZLEC where d_pl_sped>=:DPS;
delete from l_wyc2 where nr_obr=98;

select * from zmiany where dzien>='2021/10/25';

select sum(dl_zmiany) from zmiany where nr_komp_inst=:nk_inst_obr and dzien=nvl(null,dzien) and trunc(dzien,'D')=trunc(null,'D');
select * from zamow where do_produkcji=1;

--CREATE OR REPLACE SYNONYM SYN_V_OBR_WG_DPS FOR V_OBR_WG_DPS24;
CREATE OR REPLACE FORCE VIEW "V_OBR_WG_DPS24" --("GRUP", "D_PL_SPED", "NR_OBR", "KOLEJN_OBR", "SYMB_OBR", "NAZ_OBR", "IL_SZT", "IL_RZECZ", "IL_PRZEL", "IL_ZL", "IL_SZT_W_PROD", "IL_RZECZ_W_PROD", "IL_PRZEL_W_PROD", "IL_ZL_W_PROD", "IL_SZT_WYK", "IL_RZECZ_WYK", "IL_PRZEL_WYK", "IL_ZL_WYK", "MAX_ZL", "POZOSTALO") AS 
AS
SELECT nvl2(d_pl_sped,'D','T') grup, nvl(d_pl_sped,trunc(d_pl_sped,'D')) d_pl_sped, nr_obr, max(kolejn_obr) kolejn_obr, max(symb_p_obr) symb_obr, max(nazwa_p_obr) naz_obr,
       max(nk_inst_obr) nk_inst_obr, max(decode(wyd_h,0,(select wyd_nom from parinst where nr_komp_inst=nk_inst_obr),wyd_h)) wyd_obr, 
       nvl2(d_pl_sped,max((select sum(dl_zmiany) from zmiany where nr_komp_inst=nk_inst_obr and dzien=d_pl_sped)),
                      max((select sum(dl_zmiany) from zmiany where nr_komp_inst=nk_inst_obr and trunc(dzien,'D')=trunc(d_pl_sped,'D')))) il_godz,
       count(1) il_szt, sum(il_obr) il_rzecz, sum(il_obr*wsp_p) il_przel, count(distinct nr_kom_zlec) il_zl,
       count(nr_kom_szyby) il_szt_w_prod, sum(nvl2(nr_kom_szyby,1,0)*il_obr) il_rzecz_w_prod, sum(nvl2(nr_kom_szyby,1,0)*il_obr*wsp_p) il_przel_w_prod, count(distinct nvl2(nr_kom_szyby,nr_kom_zlec,null)) il_zl_w_prod,
       count(nullif(wyk,0)) il_szt_wyk, sum(wyk*il_obr) il_rzecz_wyk, sum(wyk*il_obr*wsp_p) il_przel_wyk, count(distinct nr_kom_zlec)-count(distinct case when wyk=1 then null else nr_kom_zlec end) il_zl_wyk,
       max(nr_kom_zlec) max_zl, nvl2(d_pl_sped,d_pl_sped-trunc(sysdate),(trunc(d_pl_sped,'D')-trunc(sysdate,'D'))/7) pozostalo
FROM V_OBR_W_ZLEC
GROUP BY trunc(d_pl_sped,'D'), rollup(d_pl_sped), nr_obr
ORDER BY d_pl_sped desc, kolejn_obr, nr_obr;

CREATE OR REPLACE FORCE VIEW V_OBR_WG_DPS5 ("GRUP", "D_PL_SPED", "NR_OBR", "KOLEJN_OBR", "SYMB_OBR", "NAZ_OBR", "IL_SZT", "IL_RZECZ", "IL_PRZEL", "IL_ZL", "IL_SZT_W_PROD", "IL_RZECZ_W_PROD", "IL_PRZEL_W_PROD", "IL_ZL_W_PROD", "IL_SZT_WYK", "IL_RZECZ_WYK", "IL_PRZEL_WYK", "IL_ZL_WYK", "MAX_ZL", "POZOSTALO") AS 
  SELECT nvl2(d_pl_sped,'D','T') grup, nvl(d_pl_sped,trunc(d_pl_sped,'D')) d_pl_sped, nr_obr, max(kolejn_obr) kolejn_obr, max(symb_p_obr) symb_obr, max(nazwa_p_obr) naz_obr,
       count(1) il_szt, sum(il_obr) il_rzecz, sum(il_obr*wsp_p) il_przel, count(distinct nr_kom_zlec) il_zl,
       count(nr_kom_szyby) il_szt_w_prod, sum(nvl2(nr_kom_szyby,1,0)*il_obr) il_rzecz_w_prod, sum(nvl2(nr_kom_szyby,1,0)*il_obr*wsp_p) il_przel_w_prod, count(distinct nvl2(nr_kom_szyby,nr_kom_zlec,null)) il_zl_w_prod,
       count(nullif(wyk,0)) il_szt_wyk, sum(wyk*il_obr) il_rzecz_wyk, sum(wyk*il_obr*wsp_p) il_przel_wyk, count(distinct nr_kom_zlec)-count(distinct case when wyk=1 then null else nr_kom_zlec end) il_zl_wyk,
       max(nr_kom_zlec) max_zl, nvl2(d_pl_sped,d_pl_sped-trunc(sysdate),(trunc(d_pl_sped,'D')-trunc(sysdate,'D'))/7) pozostalo
FROM
(select Z.nr_kom_zlec, Z.d_pl_sped, L.nr_obr,
        W.wsp_alt * case when O.obr_lacz=2 and nvl(S.wsp_cen,0)>0 then S.wsp_cen else 1 end wsp_p, --dla MON uwzgl. WSP_CEN
        case when L.nr_obr=93 then (select sum(il_pol_szp) from spisd D
                                    where D.nr_kom_zlec=L.nr_kom_zlec and D.nr_poz=L.nr_poz_zlec and D.do_war=L.nr_warst
                                      and to_number(trim(substr(nvl(trim(D.nr_poc),'00'),1,2)),'99') between 2 and 10)
             when L.nr_obr=99 then P.pow
             when L.nr_obr in (96,97) then 1
             else D4.szer_obr*0.001*D4.wys_obr*0.001
        end il_obr,
        symb_p_obr, nazwa_p_obr, met_oblicz, kolejn_obr
        ,E.nr_kom_szyby, E.nr_stoj_sped, E.zn_wyk, case when E.nr_stoj_sped>0 or E.zn_wyk in (1,2) then 1 else 0 end wyk
 from zamow Z
 left join l_wyc2 L on L.nr_kom_zlec=Z.nr_kom_zlec
 left join spise E on E.nr_komp_zlec=L.nr_kom_zlec and E.nr_poz=L.nr_poz_zlec and E.nr_szt=L.nr_szt
 left join spisz P on P.nr_kom_zlec=Z.nr_kom_zlec and P.nr_poz=L.nr_poz_zlec
 left join spisd D4 on D4.nr_kom_zlec=Z.nr_kom_zlec and D4.nr_poz=L.nr_poz_zlec and D4.do_war=L.nr_warst and D4.strona=4
 left join struktury S on S.kod_str=P.kod_str 
 left join wsp_alter W on W.nr_zestawu=0 and W.nr_kom_zlec=L.nr_kom_zlec and W.nr_poz=L.nr_poz_zlec and W.nr_porz_obr=L.nr_porz_obr and W.nr_komp_inst=L.nr_inst_plan
 left join slparob O on O.nr_k_p_obr=L.nr_obr
 where Z.status<>'A' and Z.do_produkcji=1 and Z.d_pl_sped>sysdate-5 --trunc(sysdate,'YY')
   and nvl(E.zn_wyk,0)<>9
)
GROUP BY trunc(d_pl_sped,'D'), rollup(d_pl_sped), nr_obr
ORDER BY d_pl_sped desc, kolejn_obr, nr_obr;

--stara wersja
CREATE OR REPLACE VIEW V_OBR_WG_DPS
AS
SELECT nvl2(d_pl_sped,'D','T') grup, nvl(d_pl_sped,trunc(d_pl_sped,'D')) d_pl_sped, nr_obr, max(kolejn_obr) kolejn_obr, max(symb_p_obr) symb_obr, max(nazwa_p_obr) naz_obr,
       count(1) il_szt, sum(il_obr) il_rzecz, sum(il_obr*wsp_p) il_przel, count(distinct nr_kom_zlec) il_zl, max(nr_kom_zlec) max_zl,
       count(nr_kom_szyby) il_szt_w_prod, sum(nvl2(nr_kom_szyby,1,0)*il_obr) il_rzecz_w_prod, sum(nvl2(nr_kom_szyby,1,0)*il_obr*wsp_p) il_przel_w_prod, count(distinct nvl2(nr_kom_szyby,nr_kom_zlec,null)) il_zl_w_prod,
       count(nullif(wyk,0)) il_szt_wyk, sum(wyk*il_obr) il_rzecz_wyk, sum(wyk*il_obr*wsp_p) il_przel_wyk, count(distinct nr_kom_zlec)-count(distinct case when wyk=1 then null else nr_kom_zlec end) il_zl_wyk,
       nvl2(d_pl_sped,d_pl_sped-trunc(sysdate),(trunc(d_pl_sped,'D')-trunc(sysdate,'D'))/7) pozostalo
FROM
(select Z.nr_kom_zlec, Z.d_pl_sped, L.nr_obr, W.wsp_alt wsp_p,
        case when L.nr_obr=93 then (select sum(il_pol_szp) from spisd D
                                    where D.nr_kom_zlec=L.nr_kom_zlec and D.nr_poz=L.nr_poz_zlec and D.do_war=L.nr_warst
                                      and to_number(trim(substr(nvl(trim(D.nr_poc),'00'),1,2)),'99') between 2 and 10)
             when L.nr_obr=99 then P.pow
             when L.nr_obr in (96,97) then 1
             else D4.szer_obr*0.001*D4.wys_obr*0.001
        end il_obr,
        symb_p_obr, nazwa_p_obr, met_oblicz, kolejn_obr
        ,E.nr_kom_szyby, E.nr_stoj_sped, E.zn_wyk, case when E.nr_stoj_sped>0 or E.zn_wyk in (1,2) then 1 else 0 end wyk
 from zamow Z
 left join l_wyc2 L on L.nr_kom_zlec=Z.nr_kom_zlec
 left join spise E on E.nr_komp_zlec=L.nr_kom_zlec and E.nr_poz=L.nr_poz_zlec and E.nr_szt=L.nr_szt
 left join spisz P on P.nr_kom_zlec=Z.nr_kom_zlec and P.nr_poz=L.nr_poz_zlec
 left join spisd D4 on D4.nr_kom_zlec=Z.nr_kom_zlec and D4.nr_poz=L.nr_poz_zlec and D4.do_war=L.nr_warst and D4.strona=4
 left join wsp_alter W on W.nr_zestawu=0 and W.nr_kom_zlec=L.nr_kom_zlec and W.nr_poz=L.nr_poz_zlec and W.nr_porz_obr=L.nr_porz_obr and W.nr_komp_inst=L.nr_inst_plan
 left join slparob O on O.nr_k_p_obr=L.nr_obr
 where do_produkcji=1 and d_pl_sped>sysdate-14 --trunc(sysdate,'YY')
)
WHERE nvl(nr_stoj_sped,0)=0 AND  nvl(zn_wyk,0) not in (1,2,9)
GROUP BY trunc(d_pl_sped,'D'), rollup(d_pl_sped), nr_obr
ORDER BY d_pl_sped desc, kolejn_obr, nr_obr;
