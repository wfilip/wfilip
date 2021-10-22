CREATE INDEX WG_D_WYK_L_WYC ON L_WYC (D_WYK, ZM_WYK, NR_INST_WYK, NR_KOM_ZLEC);

CREATE OR REPLACE VIEW "V_NIEZATW" AS
  SELECT L.typ, L.nr_kom_zlec, Z.nr_zlec, nk_inst, I.nr_inst, I.ty_inst typ_inst, L.d_wyk, L.zm_wyk, L.il_lwyc, L.il_zatw
FROM
(
 Select 1 typ, L.nr_kom_zlec, L.nr_inst_wyk nk_inst, L.d_wyk, L.zm_wyk, L.il_lwyc, H.ilosc il_zatw
 From
 (select L.nr_kom_zlec, L.nr_inst_wyk, L.d_wyk, L.zm_wyk, count(1) il_lwyc 
  from l_wyc L
  where L.d_wyk>'1901/01/01'
  group by L.nr_kom_zlec, L.nr_inst_wyk, L.d_wyk, L.zm_wyk) L
 Left join harmon H On H.nr_komp_inst=L.nr_inst_wyk and H.nr_komp_zlec=L.nr_kom_zlec and H.dzien=L.d_wyk and H.zmiana=L.zm_wyk and H.typ_harm='W' and H.zatwierdz=1
 Where lnnvl(L.il_lwyc<=H.ilosc)
 Union
 Select 2 typ, nr_kom_zlec, nr_inst, d_wyk, zm_wyk, il_lwyc, 0
 From
 (select L.nr_kom_zlec, L.nr_inst, L.d_wyk, 0 zm_wyk, count(1) il_lwyc,
         min(E.data_wyk) data_prod, min(greatest(E.data_wyk,E.data_sped)) data_sped
  from l_wyc L
  left join spise E on E.nr_komp_zlec=L.nr_kom_zlec and E.nr_poz=L.nr_poz_zlec and E.nr_szt=L.nr_szt
  where (L.nr_inst_wyk=0 and L.typ_inst<>'A C' or
         L.typ_inst='A C'
             and (select nvl(max(O.flag),0) from kol_stojakow K
                  left join opt_taf O on O.nr_opt=K.nr_optym and O.nr_tafli=K.nr_taf 
                  where K.nr_komp_zlec=L.nr_kom_zlec and K.nr_poz=L.nr_poz_zlec and K.nr_sztuki=L.nr_szt and K.nr_warstwy=L.nr_warst)<>3) 
    and not (L.typ_inst='MON' and L.nr_warst>1)
    and (greatest(E.data_wyk,E.data_sped)>'1901/01/01' or
         exists (select 1 from l_wyc L2 where L2.nr_kom_zlec=L.nr_kom_zlec and L2.nr_poz_zlec=L.nr_poz_zlec and L2.nr_szt=L.nr_szt and L2.nr_warst=L.nr_warst and L2.kolejn>l.kolejn and L2.d_wyk>'1901/01/01')
         or exists --dla Wew sprawdzenie SPISE zlec. glownego
            (select 1 from V_ZLECENIA_WEW_POZYCJE V, spise E0
             where V.nr_komp_zlec=E.nr_komp_zlec and V.nr_poz=E.nr_poz and V.nr_war=1
               and E0.nr_komp_zlec=V.nr_komp_zlec_org and E0.nr_poz=V.nr_poz_org and E0.nr_szt=E.nr_szt
               and not (E0.nr_stoj_sped=0 and not E0.zn_wyk in (1,2,3))
            )
        )
  group by L.nr_kom_zlec, L.nr_inst, L.d_wyk)
) L
LEFT JOIN parinst I ON I.nr_komp_inst=L.nk_inst
LEFT join zamow Z ON Z.nr_kom_zlec=L.nr_kom_zlec
WHERE I.fl_cutmon<9 and Z.r_dan<2   --nie HURT
ORDER BY L.nr_kom_zlec desc, typ;

--aktualny ni¿ej
CREATE OR REPLACE VIEW V_NIEZATW_LWYC
AS
 select L.nr_kom_zlec, L.nr_poz_zlec, L.nr_szt, L.nr_inst_wyk nk_inst, I.nr_inst, L.typ_inst, L.nr_warst, L.d_wyk, L.zm_wyk, --count(1) il_lwyc,
        E.data_wyk data_prod, E.data_sped, E.zn_wyk
 from l_wyc L
 --left join zamow Z on Z.nr_kom_zlec=E.nr_komp_zlec
 left join spise E on E.nr_komp_zlec=L.nr_kom_zlec and E.nr_poz=L.nr_poz_zlec and E.nr_szt=L.nr_szt
 left join parinst I on I.nr_komp_inst=L.nr_inst_wyk
 where L.d_wyk>'1901/01/01'
   and not exists (select 1 from harmon H where H.nr_komp_zlec=L.nr_kom_zlec and H.typ_harm='W' and H.zatwierdz=1 and H.nr_komp_inst=L.nr_inst_wyk and H.dzien=L.d_wyk and H.zmiana=L.zm_wyk)
;

CREATE OR REPLACE VIEW "V_NIEZATW_SPISE" AS 
  select E.nr_komp_zlec, E.nr_poz, E.nr_szt, L.nr_inst nk_inst, I.nr_inst, L.typ_inst, L.nr_warst, L.d_wyk, L.zm_wyk,
        case when Z.wyroznik='W' and E.data_wyk<sysdate-1000 then
                  (select data_wyk from V_ZLECENIA_WEW_POZYCJE V, spise E0
                   where V.nr_komp_zlec=E.nr_komp_zlec and V.nr_poz=E.nr_poz and V.nr_war=1
                     and E0.nr_komp_zlec=V.nr_komp_zlec_org and E0.nr_poz=V.nr_poz_org and E0.nr_szt=E.nr_szt
                     and E0.zn_wyk in (1,2,3))
             else E.data_wyk end data_prod,
        E.data_sped, E.zn_wyk
 from spise E
 left join zamow Z on Z.nr_kom_zlec=E.nr_komp_zlec
 left join l_wyc L on E.nr_komp_zlec=L.nr_kom_zlec and E.nr_poz=L.nr_poz_zlec and E.nr_szt=L.nr_szt
 left join parinst I on I.nr_komp_inst=L.nr_inst
  where Z.r_dan<2
  --where greatest(E.data_wyk,E.data_sped,L.d_wyk)>'1901/01/01'
    and not (greatest(E.data_wyk,case when nr_sped*nr_stoj_sped=0 then to_date('1901/01/01','YYYY/MM/DD') else E.data_sped end)<'1999/01/01'
             and not exists --dla Wew sprawdzenie SPISE zlec. glownego
             (select 1 from V_ZLECENIA_WEW_POZYCJE V, spise E0
              where V.nr_komp_zlec=E.nr_komp_zlec and V.nr_poz=E.nr_poz and V.nr_war=1
                and E0.nr_komp_zlec=V.nr_komp_zlec_org and E0.nr_poz=V.nr_poz_org and E0.nr_szt=E.nr_szt
                and not (E0.nr_stoj_sped=0 and not E0.zn_wyk in (1,2,3))
             ))
    and (select count(1) from zlec_typ ZT where ZT.nr_komp_zlec=E.nr_komp_zlec and ZT.nr_poz=0 and typ=172 and instr(linia,'do')>0)=0
    and I.fl_cutmon<9
    and not (L.typ_inst='MON' and L.nr_warst>1)
    and not (L.typ_inst='A C' and (select max(O.flag) from kol_stojakow K
                                   left join opt_taf O on O.nr_opt=K.nr_optym and O.nr_tafli=K.nr_taf 
                                   where K.nr_komp_zlec=L.nr_kom_zlec and K.nr_poz=L.nr_poz_zlec and K.nr_sztuki=L.nr_szt and K.nr_warstwy=L.nr_warst)=3)
    and (L.nr_inst_wyk=0 and L.typ_inst<>'A C' or
         L.zn_wyrobu=1 and E.zn_wyk not in (2,9) or
         L.d_wyk>'1901/01/01' and not exists (select 1 from harmon H where H.nr_komp_zlec=L.nr_kom_zlec and H.typ_harm='W' and H.zatwierdz=1 and H.nr_komp_inst=L.nr_inst_wyk and H.dzien=L.d_wyk and H.zmiana=L.zm_wyk)
        );

/*CREATE OR REPLACE VIEW V_NIEZATW_SPISE
AS
 select E.nr_komp_zlec, E.nr_poz, E.nr_szt, L.nr_inst nk_inst, I.nr_inst, L.typ_inst, L.nr_warst, L.d_wyk, L.zm_wyk,
        E.data_wyk data_prod, E.data_sped, E.zn_wyk
 from spise E
 left join zamow Z on Z.nr_kom_zlec=E.nr_komp_zlec
 left join l_wyc L on E.nr_komp_zlec=L.nr_kom_zlec and E.nr_poz=L.nr_poz_zlec and E.nr_szt=L.nr_szt
 left join parinst I on I.nr_komp_inst=L.nr_inst
  where greatest(E.data_wyk,E.data_sped,L.d_wyk)>'1901/01/01'
    and Z.r_dan<2
    and I.fl_cutmon<9
    and not (L.typ_inst='MON' and L.nr_warst>1)
    and not (L.typ_inst='A C' and (select O.flag from kol_stojakow K
                                   left join opt_taf O on O.nr_opt=K.nr_optym and O.nr_tafli=K.nr_taf 
                                   where K.nr_komp_zlec=L.nr_kom_zlec and K.nr_poz=L.nr_poz_zlec and K.nr_sztuki=L.nr_szt and K.nr_warstwy=L.nr_warst)=3)
    and (L.nr_inst_wyk=0 and L.typ_inst<>'A C' or
         L.zn_wyrobu=1 and E.zn_wyk not in (2,9) or
         L.d_wyk>'1901/01/01' and not exists (select 1 from harmon H where H.nr_komp_zlec=L.nr_kom_zlec and H.typ_harm='W' and H.zatwierdz=1 and H.nr_komp_inst=L.nr_inst_wyk and H.dzien=L.d_wyk and H.zmiana=L.zm_wyk)
         --L.nr_inst_wyk>0 and not exists (select 1 from v_niezatw V where V.nr_kom_zlec=E.nr_komp_zlec and V.nk_inst=L.nr_inst_wyk and V.d_wyk=L.d_wyk and V.zm_wyk=L.zm_wyk)
        );
*/
        
CREATE OR REPLACE VIEW V_NIEZATW_SZT
AS
SELECT * FROM V_NIEZATW_SPISE
UNION
SELECT * FROM V_NIEZATW_LWYC;
/

CREATE OR REPLACE VIEW V_NIEZATW_SZT1
AS
 select E.nr_komp_zlec, E.nr_poz, E.nr_szt, L.nr_inst nk_inst, I.nr_inst, L.typ_inst, L.nr_warst, L.d_wyk, 0 zm_wyk,
        E.data_wyk data_prod, E.data_sped, E.zn_wyk
        --, count(1) over (partition by L.nr_kom_zlec, L.d_wyk, L.zm_wyk, L.nr_inst_wyk) c, H.ilosc
 from spise E
 left join zamow Z on Z.nr_kom_zlec=E.nr_komp_zlec
 left join l_wyc L on E.nr_komp_zlec=L.nr_kom_zlec and E.nr_poz=L.nr_poz_zlec and E.nr_szt=L.nr_szt
 left join parinst I on I.nr_komp_inst=L.nr_inst
 --left join harmon H on H.nr_komp_zlec=E.nr_komp_zlec and H.typ_harm='W' and H.nr_komp_inst=L.nr_inst_wyk and H.dzien=L.d_wyk and H.zmiana=L.zm_wyk
  where greatest(E.data_wyk,E.data_sped)>'1901/01/01'
    and Z.r_dan<2
    and I.fl_cutmon<9
    and not (L.typ_inst='MON' and L.nr_warst>1)
    and not (L.typ_inst='A C' and (select O.flag from kol_stojakow K
                                   left join opt_taf O on O.nr_opt=K.nr_optym and O.nr_tafli=K.nr_taf 
                                   where K.nr_komp_zlec=L.nr_kom_zlec and K.nr_poz=L.nr_poz_zlec and K.nr_sztuki=L.nr_szt and K.nr_warstwy=L.nr_warst)=3)
    and (L.nr_inst_wyk=0 and L.typ_inst<>'A C' or
         L.zn_wyrobu=1 and E.zn_wyk not in (2,9) 
         --or L.nr_inst_wyk>0 and exists (select 1 from v_niezatw V where V.nr_kom_zlec=E.nr_komp_zlec and V.nk_inst=L.nr_inst_wyk and V.d_wyk=L.d_wyk and V.zm_wyk=L.zm_wyk)
        )
UNION
 select distinct L.nr_kom_zlec, L.nr_poz_zlec, L.nr_szt, L.nr_inst nk_inst, I.nr_inst, L.typ_inst, L.nr_warst, L.d_wyk, L.zm_wyk,
        L.d_wyk, to_date('1901/01','YYYY/MM'), 0
 from l_wyc L
 left join parinst I on I.nr_komp_inst=L.nr_inst
 --left join zamow Z on Z.nr_kom_zlec=E.nr_komp_zlec
 --left join spise E on E.nr_komp_zlec=L.nr_kom_zlec and E.nr_poz=L.nr_poz_zlec and E.nr_szt=L.nr_szt
 --left join parinst I on I.nr_komp_inst=L.nr_inst
 where L.d_wyk>'1901/01/01'
   and not exists (select 1 from harmon H where H.nr_komp_zlec=L.nr_kom_zlec and H.typ_harm='W' and H.zatwierdz=1 and H.nr_komp_inst=L.nr_inst_wyk and H.dzien=L.d_wyk and H.zmiana=L.zm_wyk)
;
/

--kompilowane 2020/08/24 #2020072210000041
CREATE OR REPLACE VIEW "V_NIEZATW_SZT1" ("NR_KOMP_ZLEC", "NR_POZ", "NR_SZT", "NK_INST", "NR_INST", "TYP_INST", "NR_WARST", "D_WYK", "ZM_WYK", "DATA_PROD", "DATA_SPED", "ZN_WYK") AS 
  select E.nr_komp_zlec, E.nr_poz, E.nr_szt, L.nr_inst nk_inst, I.nr_inst, L.typ_inst, L.nr_warst, L.d_wyk, 0 zm_wyk,
        E.data_wyk data_prod, E.data_sped, E.zn_wyk
        --, count(1) over (partition by L.nr_kom_zlec, L.d_wyk, L.zm_wyk, L.nr_inst_wyk) c, H.ilosc
 from spise E
 left join zamow Z on Z.nr_kom_zlec=E.nr_komp_zlec
 left join l_wyc L on E.nr_komp_zlec=L.nr_kom_zlec and E.nr_poz=L.nr_poz_zlec and E.nr_szt=L.nr_szt
 left join parinst I on I.nr_komp_inst=L.nr_inst
 --left join harmon H on H.nr_komp_zlec=E.nr_komp_zlec and H.typ_harm='W' and H.nr_komp_inst=L.nr_inst_wyk and H.dzien=L.d_wyk and H.zmiana=L.zm_wyk
  where greatest(E.data_wyk,case when nr_sped*nr_stoj_sped=0 then to_date('1901/01/01','YYYY/MM/DD') else E.data_sped end)>'1901/01/01'
    and Z.r_dan<2
    and (select count(1) from zlec_typ ZT where ZT.nr_komp_zlec=E.nr_komp_zlec and ZT.nr_poz=0 and typ=172 and instr(linia,'do')>0)=0
    and I.fl_cutmon<9
    and not (L.typ_inst='MON' and L.nr_warst>1)
    and not (L.typ_inst='A C' and (select O.flag from kol_stojakow K
                                   left join opt_taf O on O.nr_opt=K.nr_optym and O.nr_tafli=K.nr_taf 
                                   where K.nr_komp_zlec=L.nr_kom_zlec and K.nr_poz=L.nr_poz_zlec and K.nr_sztuki=L.nr_szt and K.nr_warstwy=L.nr_warst)=3)
    and (L.nr_inst_wyk=0 and L.typ_inst<>'A C' or
         L.zn_wyrobu=1 and E.zn_wyk not in (2,9) 
         --or L.nr_inst_wyk>0 and exists (select 1 from v_niezatw V where V.nr_kom_zlec=E.nr_komp_zlec and V.nk_inst=L.nr_inst_wyk and V.d_wyk=L.d_wyk and V.zm_wyk=L.zm_wyk)
        )
UNION
 select distinct L.nr_kom_zlec, L.nr_poz_zlec, L.nr_szt, L.nr_inst nk_inst, I.nr_inst, L.typ_inst, L.nr_warst, L.d_wyk, L.zm_wyk,
        L.d_wyk, to_date('1901/01','YYYY/MM'), 0
 from l_wyc L
 left join parinst I on I.nr_komp_inst=L.nr_inst
 --left join zamow Z on Z.nr_kom_zlec=E.nr_komp_zlec
 --left join spise E on E.nr_komp_zlec=L.nr_kom_zlec and E.nr_poz=L.nr_poz_zlec and E.nr_szt=L.nr_szt
 --left join parinst I on I.nr_komp_inst=L.nr_inst
 where L.d_wyk>'1901/01/01'
   and (select count(1) from zlec_typ ZT where ZT.nr_komp_zlec=L.nr_kom_zlec and ZT.nr_poz=0 and typ=172 and instr(linia,'do')>0)=0
   and not exists (select 1 from harmon H where H.nr_komp_zlec=L.nr_kom_zlec and H.typ_harm='W' and H.zatwierdz=1 and H.nr_komp_inst=L.nr_inst_wyk and H.dzien=L.d_wyk and H.zmiana=L.zm_wyk);
 
CREATE OR REPLACE VIEW "V_NIEZATW_SPISE" ("NR_KOMP_ZLEC", "NR_POZ", "NR_SZT", "NK_INST", "NR_INST", "TYP_INST", "NR_WARST", "D_WYK", "ZM_WYK", "DATA_PROD", "DATA_SPED", "ZN_WYK") AS 
  select E.nr_komp_zlec, E.nr_poz, E.nr_szt, L.nr_inst nk_inst, I.nr_inst, L.typ_inst, L.nr_warst, L.d_wyk, L.zm_wyk,
        E.data_wyk data_prod, E.data_sped, E.zn_wyk
 from spise E
 left join zamow Z on Z.nr_kom_zlec=E.nr_komp_zlec
 left join l_wyc L on E.nr_komp_zlec=L.nr_kom_zlec and E.nr_poz=L.nr_poz_zlec and E.nr_szt=L.nr_szt
 left join parinst I on I.nr_komp_inst=L.nr_inst
  where greatest(E.data_wyk,case when nr_sped*nr_stoj_sped=0 then to_date('1901/01/01','YYYY/MM/DD') else E.data_sped end)>'1901/01/01'
    and Z.r_dan<2
    and (select count(1) from zlec_typ ZT where ZT.nr_komp_zlec=E.nr_komp_zlec and ZT.nr_poz=0 and typ=172 and instr(linia,'do')>0)=0
    and I.fl_cutmon<9
    and not (L.typ_inst='MON' and L.nr_warst>1)
    and not (L.typ_inst='A C' and (select max(O.flag) from kol_stojakow K
                                   left join opt_taf O on O.nr_opt=K.nr_optym and O.nr_tafli=K.nr_taf 
                                   where K.nr_komp_zlec=L.nr_kom_zlec and K.nr_poz=L.nr_poz_zlec and K.nr_sztuki=L.nr_szt and K.nr_warstwy=L.nr_warst)=3)
    and (L.nr_inst_wyk=0 and L.typ_inst<>'A C' or
         L.zn_wyrobu=1 and E.zn_wyk not in (2,9) or
         L.d_wyk>'1901/01/01' and not exists (select 1 from harmon H where H.nr_komp_zlec=L.nr_kom_zlec and H.typ_harm='W' and H.zatwierdz=1 and H.nr_komp_inst=L.nr_inst_wyk and H.dzien=L.d_wyk and H.zmiana=L.zm_wyk)
         --L.nr_inst_wyk>0 and not exists (select 1 from v_niezatw V where V.nr_kom_zlec=E.nr_komp_zlec and V.nk_inst=L.nr_inst_wyk and V.d_wyk=L.d_wyk and V.zm_wyk=L.zm_wyk)
        );
        
--#2020080510000054 #2020111310000014
CREATE OR REPLACE VIEW "V_NIEZATW_LWYC" ("NR_KOM_ZLEC", "NR_POZ_ZLEC", "NR_SZT", "NK_INST", "NR_INST", "TYP_INST", "NR_WARST", "D_WYK", "ZM_WYK", "DATA_PROD", "DATA_SPED", "ZN_WYK") AS 
 select L.nr_kom_zlec, L.nr_poz_zlec, L.nr_szt, L.nr_inst_wyk nk_inst, I.nr_inst, L.typ_inst, L.nr_warst, L.d_wyk, L.zm_wyk, --count(1) il_lwyc,
        E.data_wyk data_prod, E.data_sped, E.zn_wyk
 from l_wyc L
 --left join zamow Z on Z.nr_kom_zlec=E.nr_komp_zlec
 left join spise E on E.nr_komp_zlec=L.nr_kom_zlec and E.nr_poz=L.nr_poz_zlec and E.nr_szt=L.nr_szt
 left join parinst I on I.nr_komp_inst=L.nr_inst_wyk
 where L.d_wyk>'1901/01/01'
   and (select count(1) from zlec_typ ZT where ZT.nr_komp_zlec=L.nr_kom_zlec and ZT.nr_poz=0 and typ=172 and instr(linia,'do')>0)=0
   and not exists (select 1 from harmon H where H.nr_komp_zlec=L.nr_kom_zlec and H.typ_harm='W' and H.zatwierdz=1 and H.nr_komp_inst=L.nr_inst_wyk and H.dzien=L.d_wyk and H.zmiana=L.zm_wyk);

    