
  CREATE OR REPLACE VIEW "V_IL_ZAMOW" ("NR_KOM_ZLEC", "IL_POZ", "IL_SZYB", "IL_M2", "IL_KSZT", "IL_SZABL", "IL_SZPR", "IL_POL_SZPR", "IL_METEK", "IL_WYPROD", "IL_ZATW", "IL_NA_STOJ", "IL_W_SPED", "IL_WYSL", "IL_ANUL", "IL_BR", "DNI_OPOZN", "IL_POLP", "IL_POZ_POLP", "IL_POLP_WYGEN") AS 
  SELECT nr_kom_zlec, sum(il_poz), sum(il_szyb), sum(il_m2),
        sum(il_kszt), sum(il_szabl), sum(il_szpr), sum(il_pol_szpr),
        nvl(sum(il_metek),0) il_metek, nvl(sum(il_wyprod),0) il_wyprod, nvl(sum(il_zatw),0) il_zatw,
        nvl(sum(il_na_stoj),0) il_na_stoj, nvl(sum(il_w_sped),0) il_w_sped, nvl(sum(il_wysl),0) il_wysl,
        nvl(sum(il_anul),0) il_anul, nvl(sum(il_br),0) il_br,
        nvl(case when sum(il_szyb)-sum(il_anul)>sum(il_wyprod) and sum(il_szyb)-sum(il_anul)>sum(il_wysl) then sum(dni_po_plan_sped) else -99 end, 0) dni_opozn, --nie wsz. wyprod LUB nie wsz. wyslane
        sum(il_polp) il_polp, sum(il_poz_polp) il_poz_polp, sum(il_polp_wygen) il_polp_wygen
FROM (
 SELECT nr_kom_zlec, il_poz,
       il_ciet+i_kom+ii_kom+il_strukt+il_sch il_szyb,
       pow_c+pow_i+pow_ii+pow_s+pow_sch il_m2,
       0 il_kszt, 0 il_szabl, 0 il_szpr, 0 il_pol_szpr,
       0 il_metek, 0 il_wyprod, 0 il_zatw, 0 il_na_stoj, 0 il_w_sped, 0 il_wysl, 0 il_anul, 0 il_br,
       case when status='P' and forma_wprow='P' and d_pl_sped>to_date('0101','YYMM')
            then greatest(-99,trunc(sysdate)-d_pl_sped)
            else -99 end dni_po_plan_sped,
       0 il_polp, 0 il_poz_polp, 0 il_polp_wygen
 FROM zamow
 UNION
 SELECT nr_kom_zlec, 0, 0, 0,
       sum(decode(nr_kszt,0,0,ilosc)) il_kszt,
       sum(decode(substr(ind_bud,8,1),'1',ilosc,0)) il_szabl,
       sum(decode(substr(ind_bud,4,1),'1',ilosc,0)) il_szpr, 0,
       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
 FROM spisz GROUP BY nr_kom_zlec
 UNION
 SELECT D.nr_kom_zlec, 0, 0, 0, 
       0, 0, 0,
       sum(D.il_pol_szp*P.ilosc),
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
 FROM spisd D
 LEFT JOIN spisz P ON P.nr_kom_zlec=D.nr_kom_zlec and D.nr_poz=P.nr_poz
 WHERE to_number(trim(substr(D.nr_poc,1,2)),'99') BETWEEN 2 AND 10
 GROUP BY D.nr_kom_zlec
 UNION
 SELECT nr_komp_zlec, 0, 0, 0, 
       0, 0, 0, 0,
       count(1) il_metek,
       sum(decode(zn_wyk,1,1,2,1,0)) il_wyprod,
       sum(decode(zn_wyk,2,1,0,decode(zm_wyk,0,0,1),0)) il_zatw, --przy zn_wyk sprawdzana zmiana_wyk (zatw.bez CUTMONa nie ustawa zn_wyk)
       sum(decode(nr_stoj_sped,0,0,1)) il_na_stoj,
       sum(decode(flag_real,1,0)) il_w_sped,
       sum(decode(flag_real,2,1,0)) il_wysl, 
       sum(decode(zn_wyk,9,1,0)) il_anul,
       0 il_br, 0 dni_opozn,
       0, 0, 0
 FROM spise 
 GROUP BY nr_komp_zlec
 UNION
 SELECT nr_zlec, 0, 0, 0,
      0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0,
      count(1) il_br, 0,
      0, 0, 0
 FROM braki_b
 GROUP BY nr_zlec
 UNION
 --dla zlecên braków sprawdzenie wyprodukowania zlecen Ÿród³owych
 SELECT braki_b.zlec_braki, 0, 0, 0,
      0, 0, 0, 0,
      0 il_metek,
      sum(decode(spise.zn_wyk,1,1,2,1,0)) il_wyprod,
      sum(decode(spise.zn_wyk,2,1,0,decode(spise.zm_wyk,0,0,1),0)) il_zatw, --przy zn_wyk sprawdzana zmiana_wyk (zatw.bez CUTMONa nie ustawa zn_wyk)
      0, 0, 0, 
      sum(decode(spise.zn_wyk,9,1,0)) il_anul,
      0 il_br, 0,
      0, 0, 0
 FROM braki_b
 LEFT JOIN spise USING (nr_kom_szyby)
 GROUP BY braki_b.zlec_braki
 UNION
 --ilosci wg ZLEC_POLP
 SELECT nr_komp_zlec, 0, 0, 0,
      0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0,
      0, 0, 
      count(1) il_polp, count(distinct nr_poz_zlec) il_poz_polp, count(nullif(sign(nr_zlec_wew),0)) il_polp_wygen
 FROM zlec_polp
 GROUP BY nr_komp_zlec
 )
GROUP BY nr_kom_zlec;
