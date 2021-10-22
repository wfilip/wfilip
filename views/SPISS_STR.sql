--drop view spiss_str;
CREATE OR REPLACE FORCE VIEW SPISS_STR AS
    select zrodlo,  nr_komp_zr, nr_kol, P.nr_kom_zlec, P.nr_zlec, P.nr_poz, --D.do_war, D.kol_dod, D.zn_war,
       B.nr_kom_str,  B.typ_str, row_number() over (partition by nr_komp_zr, nr_kol, B.nr_kom_str order by B.nr_skl, B1.nr_skl, B2.nr_skl, B3.nr_skl) lp,
       nvl(B3.typ_str,nvl(B2.typ_str,nvl(B1.typ_str,S.typ_str))) typ_str_skl, --przed POLFLAM S.typ_str typ_str_skl, 
       nvl(B3.nr_kom_str,nvl(B2.nr_kom_str,nvl(B1.nr_kom_str,B.nr_kom_str))) nr_kom_str_skl,
       nvl(B3.zn_war,nvl(B2.zn_war,nvl(B1.zn_war,B.zn_war))) zn_war_skl,
       B.nr_skl, B1.nr_skl nr_skl1, B2.nr_skl nr_skl2, B3.nr_skl nr_skl3,
       case when nvl(B3.typ_str,nvl(B2.typ_str,nvl(B1.typ_str,S.typ_str)))='ZE' and K.rodz_sur not in ('LIS','TAS')--and nvl(K.rodz_sur,nvl(K1.rodz_sur,nvl(K2.rodz_sur,nvl(K3.rodz_sur,'LIS')))) not in ('LIS','TAS')
            --then 2+(max(decode(nvl(K.rodz_sur,nvl(K1.rodz_sur,K2.rodz_sur)),'FOL',1,0)) over (partition by nr_komp_zr,nr_kol,P.nr_kom_zlec,P.nr_zlec,P.nr_poz,B.nr_kom_str))
            then 3 else 1 end etap, --do poprawy jesli ZESPOLENIE na etapie laczeniowym
       /*decode(B.zn_war,'Pol',1,--sign(S.il_szk), --dla struktury PO zdarza sie IL_SZK=0
                            decode(nvl(K.rodz_sur,nvl(K1.rodz_sur,nvl(K2.rodz_sur,nvl(K3.rodz_sur,'POL')))),'TAF',1,'LIS',1,'TAS',1,'POL',1,0)) czy_war,
       sum(decode(B.zn_war,'Pol',1,decode(nvl(K.rodz_sur,nvl(K1.rodz_sur,nvl(K2.rodz_sur,nvl(K3.rodz_sur,'POL')))),'TAF',1,'LIS',1,'TAS',1,'POL',1,0)))
        over (partition by nr_komp_zr,nr_kol,P.nr_kom_zlec,P.nr_zlec,P.nr_poz,B.nr_kom_str order by B.nr_skl, B1.nr_skl, B2.nr_skl,B3.nr_skl) nr_war,
       sum(decode(nvl(K.rodz_sur,nvl(K1.rodz_sur,nvl(K2.rodz_sur,K3.rodz_sur))),'FOL',1,0))
        over (partition by nr_komp_zr,nr_kol,P.nr_kom_zlec,P.nr_zlec,P.nr_poz,B.nr_kom_str order by B.nr_skl, B1.nr_skl, B2.nr_skl) nr_fol,
       decode(B.zn_war,'Pol',(select max(nr_kat) from katalog where rodz_sur='POL'),
                             nvl(K.nr_kat,nvl(K1.nr_kat,nvl(K2.nr_kat,K3.nr_kat)))) nr_kat, 
       decode(B.zn_war,'Pol',S.kod_str,nvl(K.typ_kat,nvl(K1.typ_kat,nvl(K2.typ_kat,K3.typ_kat)))) typ_kat,
       decode(B.zn_war,'Pol','POL',nvl(K.rodz_sur,nvl(K1.rodz_sur,nvl(K2.rodz_sur,K3.rodz_sur)))) rodz_sur,
       nvl(K.nk_obr,nvl(K1.nk_obr,nvl(K2.nk_obr,K3.nk_obr))) nk_obr,
       decode(B.zn_war,'Pol','0.',nvl(K.znacz_pr,nvl(K1.znacz_pr,nvl(K2.znacz_pr,K3.znacz_pr)))) znacz_pr,
       decode(B.zn_war,'Pol',S.ind_bud,nvl(K.ident_bud,nvl(K1.ident_bud,nvl(K2.ident_bud,K3.ident_bud)))) ident_bud_skl,
       decode(nvl(B3.zn_war,nvl(B2.zn_war,nvl(B1.zn_war,B.zn_war))),'Pol',-1,--(select nr_mag from katalog where nr_kat=nvl(B2.B.nr_kom_skl,nvl(B1.nr_kat,B.nr_kat))),
              nvl(K.nr_mag,nvl(K1.nr_mag,nvl(K2.nr_mag,K3.nr_mag)))) nr_mag,
       nvl(K.typ_inst1,nvl(K1.typ_inst1,nvl(K2.typ_inst1,K3.typ_inst1))) typ_inst, nvl(K.nr_inst,nvl(K1.nr_inst,nvl(K2.nr_inst,K3.nr_inst))) nr_inst,
       decode(B.zn_war,'Pol',S.gr_pak,nvl(K.grubosc,nvl(K1.grubosc,nvl(K2.grubosc,K3.grubosc)))) grub,*/
       case when K.rodz_sur in ('TAF','LIS','TAS','POL') then 1 else 0 end czy_war,
       sum(case when K.rodz_sur in ('TAF','LIS','TAS','POL') then 1 else 0 end) over (partition by nr_komp_zr,nr_kol,P.nr_kom_zlec,P.nr_zlec,P.nr_poz,B.nr_kom_str order by B.nr_skl, B1.nr_skl, B2.nr_skl,B3.nr_skl) nr_war,
       sum(decode(K.rodz_sur,'FOL',1,0)) over (partition by nr_komp_zr,nr_kol,P.nr_kom_zlec,P.nr_zlec,P.nr_poz,B.nr_kom_str order by B.nr_skl, B1.nr_skl, B2.nr_skl) nr_fol,
       K.nr_kat, decode(K.rodz_sur,'POL',S.kod_str,K.typ_kat) typ_kat, K.rodz_sur, K.nk_obr, K.znacz_pr,
       decode(K.rodz_sur,'POL',S.ind_bud,K.ident_bud) ident_bud_skl, decode(K.rodz_sur,'POL',S.nr_mag,K.nr_mag) nr_mag,
       K.typ_inst1 typ_inst, K.nr_inst, decode(K.rodz_sur,'POL',S.gr_pak,K.grubosc) grub,
       0 zn_pp, P.ilosc, P.szer, P.wys, P.obw, P.pow, P.ind_bud ident_bud, P.id_poz id_rek, B.kod_str
   from (select 'Z' zrodlo, nr_kom_zlec nr_komp_zr, nr_poz nr_kol, nr_kom_zlec, nr_zlec, nr_poz, kod_str, ilosc, szer, wys, pow, obw, ind_bud, id_poz from spisz
         union
         select 'S', nr_kom_str, 1, 0, 0, 0, kod_str, 0, 0, 0, 0, 0, ind_bud, 0 from struktury where typ_str<>'ZE') P
--   from struktury P
   left join budstr B on B.kod_str=P.kod_str
   --left join katalog K on B.zn_war='Sur' and K.nr_kat=B.nr_kom_skl
   --left join struktury S on B.zn_war<>'Sur' and S.nr_kom_str=B.nr_kom_skl
   left join budstr B1 on B.zn_war='Str' and B1.nr_kom_str=B.nr_kom_skl
   --left join katalog K1 on B.zn_war='Str' and B1.zn_war='Sur' and K1.nr_kat=B1.nr_kom_skl
   left join budstr B2 on B1.zn_war='Str' and B2.nr_kom_str=B1.nr_kom_skl
   --left join katalog K2 on B1.zn_war='Str' and B2.zn_war='Sur' and K2.nr_kat=B2.nr_kom_skl
   left join budstr B3 on B2.zn_war='Str' and B3.nr_kom_str=B2.nr_kom_skl
   --left join katalog K3 on B2.zn_war='Str' and B3.zn_war='Sur' and K3.nr_kat=B3.nr_kom_skl
   left join budstr B4 on B3.zn_war='Str' and B4.nr_kom_str=B3.nr_kom_skl
   join katalog K on K.nr_kat=case when B.zn_war='Sur' then B.nr_kom_skl
                                              when B1.zn_war='Sur' then B1.nr_kom_skl
                                              when B2.zn_war='Sur' then B2.nr_kom_skl
                                              when B3.zn_war='Sur' then B3.nr_kom_skl
                                              when B4.zn_war='Sur' then B4.nr_kom_skl
                                              else (select max(nr_kat) from katalog where rodz_sur='POL') end
   left join struktury S on S.nr_kom_str=case when B.zn_war='Pol' then B.nr_kom_skl
                                              when B1.zn_war='Pol' then B1.nr_kom_skl
                                              when B2.zn_war='Pol' then B2.nr_kom_skl
                                              when B3.zn_war='Pol' then B3.nr_kom_skl
                                              when B4.zn_war in ('Pol','Str') then B4.nr_kom_skl
                                              else B.nr_kom_str end
  order by nr_komp_zr, nr_kol, nr_kom_zlec, nr_poz, B.nr_kom_str, B.nr_skl, B1.nr_skl, B2.nr_skl;
/