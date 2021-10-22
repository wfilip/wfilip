--CUTTER wywoluje V_CHECK_ORDER, w bazie ten obiekt to synonim wskazujacy konkretny widok z numerem w nazwie
--V_CHECK_ORDER1 wdrozony w Eff
--V_CHECK_ORDER18 wdrozony w Matpol
CREATE OR REPLACE VIEW "V_ORDER_DATA1"
AS 
Select V.nr_kom_zlec, V.nr_zlec, V.nr_kon, V.status, V.wyroznik, V.r_dan, V.data_zl, V.nr_poz, V.szer, V.wys, V.nr_komp_rys,
       V.nr_kom_str, V.zn_war, V.nr_war, V.nr_kom_skl, V.kod_polp,
       D.szer_obr, D.wys_obr, D.strona, D.nr_kat, K.typ_kat, D.kod_dod,
       D.nr_poc, D.wsp1, D.wsp2, D.wsp3, D.wsp4,
       D.nr_komp_obr, O.symb_p_obr, D.ilosc_do_wyk,
       max((select count(1) from lista_p_obr L where L.nr_komp_struktury=D.nr_komp_obr and czy_korekt_wym=1)) over (partition by V.nr_kom_zlec, V.nr_poz, V.nr_war) obr_z_nadd,
       V.kod_str
from V_STR_WAR_Z V
left join spisd D on D.nr_kom_zlec=V.nr_kom_zlec and D.nr_poz=V.nr_poz and D.do_war=V.nr_war
left join katalog K on K.nr_kat=D.nr_kat
left join slparob O on O.nr_k_p_obr=D.nr_komp_obr;

CREATE OR REPLACE VIEW V_CHECK_ORDER1
AS 
 Select V.*,
       case when zn_war='Sur' and not V.nr_kom_skl=V.nr_kat and V.strona in (0,4)
            then 1 else 0 end ||
       case when zn_war='Pol' and not V.kod_polp=V.kod_dod and V.strona in (0,4)
            then 1 else 0 end ||
       case when zn_war='Pol' and strona in (0,4) and wyroznik<>'O' and
                 not exists (select 1 from zlec_polp P
                             where P.nr_komp_zlec=V.nr_kom_zlec and P.nr_poz_zlec=V.nr_poz
                               and P.nr_strukt=V.nr_kom_skl)
            then 1 else 0 end ||
            '00'|| --do wykorzystania
       case when V.nr_komp_obr>0 and V.ilosc_do_wyk=0
            then 1 else 0 
       end err_info
 From V_ORDER_DATA1 V
 Where V.strona in (0,4) and 
       (V.zn_war='Sur' and not V.nr_kom_skl=V.nr_kat or
        V.zn_war='Pol' and (not V.kod_polp=V.kod_dod or 
                            V.r_dan in (0,1) and wyroznik<>'O' and V.strona=0 and
                            not exists (select 1 from zlec_polp P
                                        where P.nr_komp_zlec=V.nr_kom_zlec and P.nr_poz_zlec=V.nr_poz
                                          and P.nr_strukt=V.nr_kom_skl))
       )
       Or V.nr_komp_obr>0 and V.ilosc_do_wyk=0
  --and nr_kom_zlec=&ZL
;

--06.2020 nowa wersja dla Matpol, m.in sygnalizowanie braku obróbek obwodowych
@V_STR_SKL_Z.sql;

CREATE OR REPLACE VIEW "V_ORDER_DATA18"
AS
Select V.nr_kom_zlec, V.nr_zlec, V.nr_kon, V.status, V.r_dan, V.data_zl, V.nr_poz, V.typ_poz, V.szer, V.wys, V.nr_komp_rys,
       V.nr_kom_str, V.zn_war, V.nr_war, V.nr_kom_skl, V.typ_kat typ_kat_czy, V.kod_polp, V.ident_bud atryb_skl,
       D.szer_obr, D.wys_obr, D.strona, D.nr_kat, K.typ_kat, D.kod_dod,
       D.nr_poc, D.wsp1, D.wsp2, D.wsp3, D.wsp4,
       D.nr_komp_obr, O.symb_p_obr, D.ilosc_do_wyk,
       decode(D.strona,0,max(to_number(nvl(substr(V.ident_bud,10,1),0))*10
                                +case when V.zn_war='Pol' and 
                                           exists (select 1 from v_str_sur1 V1
                                                   where V1.kod_str=V.kod_polp and V1.rodz_sur='CZY' and V1.znacz_pr='10.H')
                                           then 2
                                      when V.rodz_sur='CZY' then 1 
                                      else 0 end)
                         over (partition by V.nr_kom_zlec, V.nr_poz, V.nr_war)) atr10_war,
       max((select count(1) from lista_p_obr L where L.nr_komp_struktury=D.nr_komp_obr and L.czy_korekt_wym=1)) over (partition by V.nr_kom_zlec, V.nr_poz, V.nr_war) obr_z_nadd,
       decode(D.strona,0,max((case O.met_oblicz when 1 then 1 else 0 end))  over (partition by V.nr_kom_zlec, V.nr_poz, V.nr_war),null) obr_obwodowa,
       V.kod_str
from V_STR_SKL_Z V
left join spisd D on D.nr_kom_zlec=V.nr_kom_zlec and D.nr_poz=V.nr_poz and D.do_war=V.nr_war and V.czy_war=1
left join katalog K on K.nr_kat=D.nr_kat
left join slparob O on O.nr_k_p_obr=D.nr_komp_obr
--z widoku V_STR_SKL_Z pobierane tylko warstwy i czynnoœci
where not (V.czy_war=0 and V.rodz_sur<>'CZY');

CREATE OR REPLACE VIEW V_CHECK_ORDER18
AS 
 SELECT * FROM
 (Select V.*,
       --sprawdzenie spojnoœci miedzy budow¥ struktury a SPISD
       case when zn_war='Sur' and not V.nr_kom_skl=V.nr_kat and V.strona in (0,4)
            then 1 else 0 end ||
       case when zn_war='Pol' and not V.kod_polp=V.kod_dod and V.strona in (0,4)
            then 1 else 0 end ||
       --sprawdzenie czy jest rekord w ZLEC_POLP
       case when zn_war='Pol' and V.strona in (0,4) and
                 not exists (select 1 from zlec_polp P
                             where P.nr_komp_zlec=V.nr_kom_zlec and P.nr_poz_zlec=V.nr_poz
                               and P.nr_strukt=V.nr_kom_skl)
            then 1 else 0 end ||
            '00'|| --do wykorzystania do sprawdzenia danych warstwy
       --sprawdzenie czy wyliczona iloœæ obróbki
       case when V.nr_komp_obr>0 and V.ilosc_do_wyk=0
            then 1 else 0 end ||
       --sprawdzenie czy jest obróbka obwodowa do obróbki Hartowanie (11-H na warstwie, 12-H w polprodukcie)
       case when V.atr10_war in(11,12) and V.obr_obwodowa=0
            then 1 else 0 
       end ||
       --sprawdzenie czy jest obrobka obwodowa na warstwie z atryb 10.Hart
       case when V.r_dan=1 and V.atr10_war=10 and V.obr_obwodowa=0
            then 1 else 0 
       end ||
       --sprawdzenie czy jest obróbka obwodowa dla formatek
       case when V.r_dan=1 and V.typ_poz in ('cie','str') and V.obr_obwodowa=0
            then 1 else 0 
       end err_info
  From V_ORDER_DATA18 V )
 WHERE trim(replace(err_info,'0','')) is not null
;

create or replace FUNCTION FUN_OPISY(pGRUPA NUMBER, pKTORE VARCHAR2, pSEP CHAR) RETURN VARCHAR2 IS
vRet VARCHAR2(4000);
BEGIN
 IF pGRUPA=101 THEN
  NULL; 
 END IF;
 SELECT listagg(fraza,pSEP) within group (order by lp)
   INTO vRet
 FROM (select 0 grupa, 0 lp, NULL fraza from dual union
       select 101, 1, 'B³êdny surowiec' from dual union
       select 101, 2, 'B³êdny kod pó³produktu' from dual union
       select 101, 3, 'B³¹d zapisu danych pó³produktów [ZLEC_POLP]' from dual union
       select 101, 4, ' ' from dual union
       select 101, 5, ' ' from dual union
       select 101, 6, 'Zerowa iloœæ obróbki' from dual union
       select 101, 7, 'Brak obróbki krawêdzi na warstwie z obróbk¹ HART' from dual union
       select 101, 8, 'Brak obróbki krawêdzi na warstwie hartowanej' from dual union
       select 101, 9, 'Formatka bez obróbki krawêdzi' from dual
      )
 WHERE grupa=pGRUPA AND substr(pKTORE,lp,1)='1';
 RETURN vRet;
END FUN_OPISY;
/

--DROP SYNONYM V_CHECK_ORDER;
--CREATE SYNONYM V_CHECK_ORDER FOR V_CHECK_ORDER18;