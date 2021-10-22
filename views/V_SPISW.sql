CREATE OR REPLACE FORCE VIEW V_SPISD_DECOAT
AS
  select distinct nr_kom_zlec, nr_poz, do_war, decoat, decode(decoat,1,nr_komp_obr,0) nr_komp_obr, decode(decoat,1,ILOSC_DO_WYK,0) ILOSC_DO_WYK
  from spisd D1 
  left join (select 0 decoat from dual union select 1 from dual) on 1=1
  where D1.nr_komp_obr=(select min(nr_k_p_obr) from slparob where symb_p_obr='DECOAT'); --53

CREATE OR REPLACE FORCE VIEW L_WYC_BR 
AS
SELECT L.nr_kom_zlec, L.nr_poz_zlec, L.nr_szt, L.nr_warst, 
       decode(brak,1,Lb.nr_kom_zlec,0) zlec_braki,
       Lb.nr_poz_zlec nr_poz_br, Lb.nr_warst nr_warst_br, Lb.nr_inst, Lb.kolejn, Lb.d_wyk, Lb.zm_wyk, Lb.op,
       --decode(Lb.zm_wyk,0,DATA_WYK_NAST(Lb.nr_ser,Lb.kolejn+1),to_date('190101','YYYYMM')) data_nast, --DATA_WYK_NAST(Lb.nr_ser,Lb.kolejn+1),
       case when Lb.zm_wyk=0 and Lb.zn_braku not in (1,8,9) then DATA_WYK_NAST(Lb.nr_ser,Lb.kolejn+1) else to_date('190101','YYYYMM') end data_nast,
       Lb.zn_braku, Lb.nr_ser, Lb.id_oryg
FROM l_wyc Lb 
left join l_wyc L on L.id_rek=Lb.id_oryg
--sztuczne utworzenie danych z rek. oryginalnego
left join (select 0 brak from dual union select 1 from dual) on 1=1
WHERE Lb.id_oryg>0 and Lb.wyroznik='B' and Lb.zn_braku in (0,7)
ORDER BY 1,2,3,4,Lb.kolejn;
/

CREATE OR REPLACE FORCE VIEW V_WYKZAL_OBR
AS
 SELECT W.nr_komp_zlec, W.nr_poz, W.nr_warst, W.nr_komp_instal, W.nr_komp_obr, max(W.il_jedn) IL_JEDN, sum(il_plan) IL_PLAN, sum(il_wyk) IL_WYK, max(il_calk) IL_CALK
 FROM wykzal W
 GROUP BY W.nr_komp_zlec, W.nr_poz, W.nr_warst, W.nr_komp_instal, W.nr_komp_obr
 ORDER BY W.nr_komp_zlec, W.nr_poz, W.nr_warst, W.nr_komp_instal, W.nr_komp_obr;
/

CREATE OR REPLACE FUNCTION DATA_WYK_NAST (pNR_SER NUMBER, pKOLEJN_MIN NUMBER) RETURN DATE
IS
 vZmWyk NUMBER(10);
BEGIN
  --SELECT count(1) INTO vZmWyk from l_wyc;
  SELECT nvl(min(PKG_CZAS.NR_KOMP_ZM(d_wyk,zm_wyk)),0) INTO vZmWyk
  from l_wyc
  where nr_ser=pNR_SER AND kolejn>=pKOLEJN_MIN and d_wyk>to_date('1901','YYYY');
  RETURN case when vZmWyk>0
              then PKG_CZAS.NR_ZM_TO_DATE(vZmWyk)
              else to_date('190101','YYYYMM') end;
EXCEPTION WHEN OTHERS THEN
 RETURN to_date('190101','YYYYMM'); 
END DATA_WYK_NAST;
/

CREATE OR REPLACE FORCE VIEW V_SPISW
AS
SELECT DISTINCT E.nr_komp_zlec nr_kom_zlec, E.nr_poz, E.nr_szt, E.nr_kom_szyby, D.do_war nr_war, D.nr_kat,
       case when I.ty_inst in ('MON','STR') or I.rodz_plan=5 then Z.kod_str 
            when K.rodz_sur='POL' then D.kod_dod
            else K.typ_kat end        indeks,
       L.typ_inst, L.kolejn, L.zn_wyrobu,
       nvl(D1.nr_komp_obr,nvl(W.nr_komp_obr,0)) nr_obr,
       round(decode(nvl(D1.decoat,0),1,D1.ilosc_do_wyk,nvl(W.il_jedn,case when I.ty_inst in ('A C','R C') then D.szer_obr*0.001*D.wys_obr*0.001 else Z.pow end)),4) il_jedn,
       L.zn_braku, nvl(Lb.zlec_braki,0) zlec_braki,
      decode(nvl(Lb.zlec_braki,0),0,L.nr_inst,Lb.nr_inst) nr_inst,
--      case when I.ty_inst in ('MON','STR') or I.rodz_plan=5 then decode(E.data_wyk,to_date('190101','YYYYMM'),E.data_sped,E.data_wyk)
--           else   decode(nvl(Lb.zlec_braki,0),0,L.d_wyk,Lb.d_wyk) end d_wyk,
      decode(nvl(Lb.zlec_braki,0),0,decode(L.d_wyk,to_date('190101','YYYYMM'),DATA_WYK_NAST(L.nr_ser,L.kolejn+1),L.d_wyk),
                                     decode(Lb.d_wyk,to_date('190101','YYYYMM'),DATA_WYK_NAST(Lb.nr_ser,Lb.kolejn+1),Lb.d_wyk))
        data_wyk,
      decode(nvl(Lb.zlec_braki,0),0,L.zm_wyk,Lb.zm_wyk) zm_wyk,
      decode(nvl(Lb.zlec_braki,0),0,L.op,Lb.op) oper_wyk,
      E.data_wyk data_prod, E.zm_wyk zm_prod, E.d_odcz data_pak, E.data_sped data_sped, E.zm_sped,
      decode(E.data_wyk,to_date('190101','YYYYMM'),decode(E.d_odcz,to_date('190101','YYYYMM'),E.data_sped,E.d_odcz),E.data_wyk) data_konc, 
      E.o_wyk oper_prod, E.o_odcz oper_pak
FROM spise E
LEFT JOIN spisz Z ON Z.nr_kom_zlec=E.nr_komp_zlec and Z.nr_poz=E.nr_poz
LEFT JOIN spisd D ON D.nr_kom_zlec=E.nr_komp_zlec and D.nr_poz=E.nr_poz and D.strona=4
LEFT JOIN katalog K ON K.nr_kat=D.nr_kat
LEFT JOIN l_wyc L ON L.nr_kom_zlec=D.nr_kom_zlec and L.nr_poz_zlec=D.nr_poz and L.nr_szt=E.nr_szt and L.nr_warst=D.do_war
--LEFT JOIN (select 0 nr_kom_zlec,0 nr_poz_zlec,0 nr_szt,0 nr_warst,0 nr_inst,0 kolejn, 0 zlec_braki, to_date('190101','YYYYMM') d_wyk,0 zm_wyk,' ' op, 0 nr_ser, -1 id_oryg from dual) Lb ON 1=1
LEFT JOIN l_wyc_br Lb ON Lb.id_oryg=L.id_rek--L.nr_kom_zlec=D.nr_kom_zlec and L.nr_poz_zlec=D.nr_poz and L.nr_szt=E.nr_szt and L.nr_warst=D.do_war
LEFT JOIN parinst I ON I.nr_komp_inst=L.nr_inst
--szukanie obrobek na warstwie - WYKZAL bo s¹ obróbki ze Struktur
LEFT JOIN v_wykzal_obr W ON W.nr_komp_zlec=D.nr_kom_zlec and W.nr_poz=D.nr_poz and W.nr_warst=D.do_war and W.nr_komp_instal=L.nr_inst and W.nr_komp_obr>0
--zdublowanie rekordów na ciêciu gdy jest DECOAT
LEFT JOIN v_spisd_decoat D1 ON I.ty_inst in ('A C','R C') and D1.nr_kom_zlec=D.nr_kom_zlec and D1.nr_poz=D.nr_poz and D1.do_war=D.do_war
WHERE not exists (select 1 from braki_b where zlec_braki=E.nr_komp_zlec) AND E.zn_wyk<>9
  --AND E.nr_komp_zlec=:1 --AND E.nr_poz=:2 AND E.nr_szt=1 AND L.nr_inst=:3
  AND (greatest(E.data_wyk,E.d_odcz,E.data_sped)>to_date('1901/01','YYYY/MM') or (select count(1) from l_wyc where nr_kom_zlec=E.nr_komp_zlec and nr_poz_zlec=E.nr_poz and d_wyk>to_date('1901/01','YYYY/MM'))>0)
  AND nvl(K.rodz_sur,' ')<>'LIS'
  AND L.nr_kom_zlec is not null
  AND (I.ty_inst not in ('MON','STR') or L.nr_warst=1)
ORDER BY E.nr_komp_zlec, E.nr_poz, E.nr_szt, D.do_war, L.kolejn,  nvl(Lb.zlec_braki,0);
/

CREATE OR REPLACE FORCE VIEW V_SPISW_SUMPOZ
AS
select nr_kom_zlec, nr_poz, nr_inst, zlec_braki, nr_obr, 
       decode(data_wyk,to_date('190101','YYYYMM'),data_konc,data_wyk) data_wyk,
       decode(data_wyk,to_date('190101','YYYYMM'),oper_prod,oper_wyk) id_prac,
       count(1) il_szt, sum(il_jedn) il_obr,
       indeks, max(kolejn) kolejn
from v_spisw
where (data_wyk>to_date('190101','YYYYMM') or 
       data_konc>to_date('190101','YYYYMM') and (typ_inst in ('MON','STR') or zn_wyrobu=1 and zn_braku=0) or
       zlec_braki>0 OR not exists (select 1 from braki_b where nr_kom_szyby=v_spisw.nr_kom_szyby and inst_pow=nr_inst))
  --and nr_kom_zlec=:10
group by nr_inst, nr_kom_zlec, nr_poz, zlec_braki, nr_obr, indeks, 
       decode(data_wyk,to_date('190101','YYYYMM'),data_konc,data_wyk), --data_wyk
       decode(data_wyk,to_date('190101','YYYYMM'),oper_prod,oper_wyk)  --id_prac
order by nr_kom_zlec, nr_poz, kolejn, data_wyk, nr_obr;
/