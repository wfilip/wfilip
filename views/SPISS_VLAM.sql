CREATE OR REPLACE VIEW SPISS_VLAM 
AS
SELECT  zrodlo, nr_komp_zr, nr_kol, szer, wys, S.nr_kom_str, lp,  decode(czy_war,1,1,2) etap, czy_war, nr_war,
        dense_rank() over (partition by nr_komp_zr,nr_kol order by war_do) ktory_lam,
        dense_rank() over (partition by nr_komp_zr,nr_kol,war_do order by nr_war) ktore_szklo, czy_kolejna,
        nr_war-/*ktore_szklo*/dense_rank() over (partition by nr_komp_zr,nr_kol,war_do order by nr_war)+1 war_od, war_do,
        S.nk_obr, il_fol_war, B.nr_kom_skl nr_kom_skl_nast, K.typ_kat typ_kat_skl_nast,
        S.typ_kat, S.nr_kat, S.rodz_sur, grub, S.typ_inst, S.nr_inst, S.id_rek,
        kod_laminatu(S.nr_kom_str,/*war_od*/nr_war-dense_rank() over (partition by nr_komp_zr,nr_kol,war_do order by nr_war)+1,war_do) kod_lam,
        O1.nr_k_p_obr nk_obr_WE, O1.symb_p_obr symb_obr_WE, O1.nr_kat_obr nr_kat_obr_WE, O1.kolejn_obr kolejn_WE, 
        O2.nr_k_p_obr nk_obr_WY, O2.symb_p_obr symb_obr_WY, O2.nr_kat_obr nr_kat_obr_WY, O2.kolejn_obr kolejn_WY, 
        rpad(translate(reverse(to_char(sum(reverse(rpad(S.ident_bud_skl,50,'0'))) over  (partition by S.zrodlo, S.nr_komp_zr, S.nr_kol, war_do))),'23456789','11111111'),50,'0') ident_bud,
        S.ident_bud_skl, S.ident_bud ident_spisz, S.kod_str
FROM
(select (case
          when rodz_sur='FOL' or sum(case when rodz_sur='FOL' then 1 else 0 end) over (partition by nr_komp_zr,nr_kol,nr_war)>0  --il_fol_war>0
           then (select min(min(nr_war)) from spiss_str S2
                 where S2.zrodlo='S' and S2.nr_komp_zr=S.nr_kom_str and S2.nr_kol=1 and S2.nr_war>=S.nr_war
                 group by nr_war
                 having count(decode(S2.rodz_sur,'FOL',1,null))=0)
          when nr_war>1 and
               exists (select 1 from spiss_str S2
                       where S2.zrodlo='S' and S2.nr_komp_zr=S.nr_kom_str and S2.nr_kol=1 and S2.nr_war=S.nr_war-1 and S2.rodz_sur='FOL')
           then nr_war            
          else 0 end) war_do,
        (case when nr_war>1 and rodz_sur<>'FOL' and (sum(case when rodz_sur='FOL' then 1 else 0 end) over (partition by nr_komp_zr,nr_kol,nr_war)>0  --il_fol_war>0
           or exists (select 1 from spiss_str S2
                       where S2.zrodlo='S' and S2.nr_komp_zr=S.nr_kom_str and S2.nr_kol=1 and S2.nr_war=S.nr_war-1 and S2.rodz_sur='FOL'))
         then 1 else 0 end) czy_kolejna,  --warstwa po warstwie z foli¹
        sum(case when rodz_sur='FOL' then 1 else 0 end) over (partition by nr_komp_zr,nr_kol,nr_war) il_fol_war,
        S.*
 from spiss_str S
) S
LEFT JOIN slparob O1 ON O1.obr_lacz=3 --obr LAM_P
LEFT JOIN slparob O2 ON O2.obr_lacz=1 --obr LAM
--po szukanie czynnoœci (X1..Xn) po folii (nr_skl+1)
LEFT JOIN budstr B ON B.nr_kom_str=S.nr_kom_str_skl and B.nr_skl=S.nr_skl+1
LEFT JOIN katalog K ON K.nr_kat=B.nr_kom_skl
WHERE (czy_war=1 and czy_kolejna=1 or il_fol_war>0 and (czy_war=1 or S.rodz_sur='FOL' or S.rodz_sur='CZY' and S.znacz_pr='9.La'))
--WHERE 1=1--(etap=1 and czy_war=1 or etap=2)
--  AND S.zrodlo='S' and S.nr_komp_zr=:STR_LAM
ORDER BY S.nr_komp_zr, S.nr_kol, S.LP;
/