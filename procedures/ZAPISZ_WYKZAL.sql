create or replace PROCEDURE ZAPISZ_WYKZAL (pNK_ZLEC IN NUMBER, pINST IN NUMBER DEFAULT 0, pPOZ IN NUMBER DEFAULT 0)
AS
BEGIN
  INSERT INTO wykzal (nr_komp_zlec, nr_poz, nr_warst, straty,--nr_warst_do,
                      indeks, nr_komp_obr,
                      il_calk, il_jedn,
                      nr_komp_instal, nr_zm_plan, d_plan, zm_plan,
                      il_plan, il_zlec_plan, wsp_przel,
                      --nr_komp_inst_wyk, 
                      nr_komp_zm, d_wyk, zm_wyk,
                      il_wyk, nr_oper, il_zlec_wyk,
                      flag, --straty, nr_kat,
                      kod_dod, nr_komp_gr)
   SELECT V.nr_kom_zlec, V.nr_poz_zlec, V.nr_warst, decode(sign(max(V.nr_warst_do)-V.nr_warst),1,max(V.nr_warst_do),0),
          decode(K.rodz_sur,'KRA',V.kod_dod,V.indeks),
          decode(K.rodz_sur,'KRA',0,case when instr(nry_porz||',',',')>3 then V.nr_obr else V.nr_kat_obr end) nr_komp_obr, --nr_porz>100
          max(P.ilosc) il_calk, max(V.il_obr) il_jedn,
          V.nr_inst_plan, V.nr_zm_plan, PKG_CZAS.NR_ZM_TO_DATE(V.nr_zm_plan) d_plan , PKG_CZAS.NR_ZM_TO_ZM(V.nr_zm_plan) zm_plan,
          case when max(trim(I.ty_inst)) in ('A C', 'R C') then count(distinct nr_szt) else count(1) end il_plan, sum(V.il_obr) il_zlec_plan, max(V.wsp_p), 
          --V.nr_inst_wyk, 
          decode(V.nr_inst_wyk,V.nr_inst_plan,V.nr_zm_wyk,0) nr_zm_wyk,
          max(case when V.nr_inst_plan=V.nr_inst_wyk and V.nr_zm_wyk>0 then PKG_CZAS.NR_ZM_TO_DATE(V.nr_zm_wyk) else to_date('1901/01','YYYY/MM') end) data_wyk,
          max(case when V.nr_inst_plan=V.nr_inst_wyk and V.nr_zm_wyk>0 then PKG_CZAS.NR_ZM_TO_ZM(V.nr_zm_wyk) else 0 end) zm_wyk,
          sum(case when V.nr_inst_plan=V.nr_inst_wyk and V.nr_zm_wyk>0 then 1 else 0 end) il_wyk, ' ' oper,
          sum(case when V.nr_inst_plan=V.nr_inst_wyk and V.nr_zm_wyk>0 then 1 else 0 end) il_zlec_wyk,
          decode(sign(decode(V.nr_inst_wyk,V.nr_inst_plan,V.nr_zm_wyk,0)),0,1,1,3,2) flag, --0, max(decode(K.rodz_sur,'KRA',V.nr_kat_obr,V.nr_kat)),
          decode(max(K.rodz_sur),'KRA',' ',V.kod_dod), decode(max(I.rodz_plan),1,nvl(max(G.nkomp_grupy),0),0)
   FROM v_wyc2 V
   LEFT JOIN spisz P ON P.nr_kom_zlec=V.nr_kom_zlec and P.nr_poz=V.nr_poz_zlec       
   --LEFT JOIN slparob O ON O.nr_k_p_obr=V.nr_obr
   LEFT JOIN katalog K ON K.nr_kat=V.nr_kat_obr
   LEFT JOIN parinst I ON I.nr_komp_inst=V.nr_inst_plan
   LEFT JOIN kat_gr_plan G ON G.typ_kat=V.indeks AND G.nkomp_instalacji=V.nr_inst_plan
   WHERE V.nr_kom_zlec=pNK_ZLEC and pINST in (0,V.nr_inst_plan) and pPOZ in (0,V.nr_poz_zlec) and I.ty_inst not in ('MON','STR') and (pINST>0 or I.ty_inst<>'A C') and V.nr_zm_plan>0
   GROUP BY V.nr_kom_zlec, V.nr_poz_zlec, V.nr_warst,
            decode(K.rodz_sur,'KRA',V.kod_dod,V.indeks),
            /*nr_komp_obr*/decode(K.rodz_sur,'KRA',0,case when instr(nry_porz||',',',')>3 then V.nr_obr else V.nr_kat_obr end),
            V.kod_dod, V.nr_zm_plan,
            decode(V.nr_inst_wyk,V.nr_inst_plan,V.nr_zm_wyk,0),--V.nr_zm_wyk,
            V.nr_inst_plan;--, V.nr_inst_wyk
            --zapisywane tylko rekordy z planem
            --zapis danych wykonanania na innej instlacji w Cutter:Zatwierdzanie na podstawie V_TSURCZYN
END ZAPISZ_WYKZAL;
/
