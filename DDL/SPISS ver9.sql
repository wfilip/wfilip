CREATE OR REPLACE FORCE VIEW SPISS_STR AS
--   select 'Z' zrodlo, P.nr_kom_zlec nr_komp_zr, P.nr_poz nr_kol,
--          0, V.typ_kat, V.nr_kat, V.nr_kat,
    select 'Z' zrodlo, P.nr_kom_zlec nr_komp_zr, P.nr_poz nr_kol, P.nr_kom_zlec, P.nr_zlec, P.nr_poz, --D.do_war, D.kol_dod, D.zn_war,
       B.nr_kom_str,  B.typ_str, row_number() over (partition by P.nr_kom_zlec, P.nr_poz order by B.nr_skl, B1.nr_skl, B2.nr_skl) lp,
       S.typ_str typ_str_skl,  B.nr_skl, B1.nr_skl nr_skl1, B2.nr_skl nr_skl2,
       case when S.typ_str='ZE' and nvl(K.rodz_sur,nvl(K1.rodz_sur,K2.rodz_sur))<>'LIS' then 2+(max(decode(nvl(K.rodz_sur,nvl(K1.rodz_sur,K2.rodz_sur)),'FOL',1,0)) over (partition by P.nr_kom_zlec,P.nr_zlec,P.nr_poz,B.nr_kom_str))
            else 1 end etap,
       decode(B.zn_war,'Pol',S.il_szk,
                            decode(nvl(K.rodz_sur,nvl(K1.rodz_sur,K2.rodz_sur)),'TAF',1,'LIS',1,0)) czy_war,
       sum(decode(B.zn_war,'Pol',1/*S.il_szk*/,decode(nvl(K.rodz_sur,nvl(K1.rodz_sur,K2.rodz_sur)),'TAF',1,'LIS',1,0)))
        over (partition by P.nr_kom_zlec,P.nr_zlec,P.nr_poz,B.nr_kom_str order by B.nr_skl, B1.nr_skl, B2.nr_skl) nr_war,
       sum(decode(nvl(K.rodz_sur,nvl(K1.rodz_sur,K2.rodz_sur)),'FOL',1,0))
        over (partition by P.nr_kom_zlec,P.nr_zlec,P.nr_poz,B.nr_kom_str order by B.nr_skl, B1.nr_skl, B2.nr_skl) nr_fol,
       decode(B.zn_war,'Pol',(select max(nr_kat) from katalog where rodz_sur='POL'),
                             nvl(K.nr_kat,nvl(K1.nr_kat,K2.nr_kat))) nr_kat, 
       decode(B.zn_war,'Pol',S.kod_str,nvl(K.typ_kat,nvl(K1.typ_kat,K2.typ_kat))) typ_kat,
       decode(B.zn_war,'Pol','POL',nvl(K.rodz_sur,nvl(K1.rodz_sur,K2.rodz_sur))) rodz_sur,
       decode(nvl(K.rodz_sur,nvl(K1.rodz_sur,K2.rodz_sur)),'CZY',nvl(K.nk_obr,nvl(K1.nk_obr,K2.nk_obr)),0) nk_obr,
       decode(B.zn_war,'Pol','0.',nvl(K.znacz_pr,nvl(K1.znacz_pr,K2.znacz_pr))) znacz_pr,
       decode(B.zn_war,'Pol',S.ind_bud,nvl(K.ident_bud,nvl(K1.ident_bud,K2.ident_bud))) ident_bud_skl,
       decode(nvl(B2.zn_war,nvl(B1.zn_war,B.zn_war)),'Pol',-1,--(select nr_mag from katalog where nr_kat=nvl(B2.B.nr_kom_skl,nvl(B1.nr_kat,B.nr_kat))),
              nvl(K.nr_mag,nvl(K1.nr_mag,K2.nr_mag))) nr_mag,
       nvl(K.typ_inst1,nvl(K1.typ_inst1,K2.typ_inst1)) typ_inst, nvl(K.nr_inst,nvl(K1.nr_inst,K2.nr_inst)) nr_inst,
       decode(B.zn_war,'Pol',S.gr_pak,nvl(K.grubosc,nvl(K1.grubosc,K2.grubosc))) grub, 0 zn_pp,
       P.ilosc, P.szer, P.wys, P.ind_bud ident_bud, P.id_poz id_rek, B.kod_str
--   from (select 'Z' zrodlo, nr_kom_zlec nr_komp_zr, nr_poz nr_kol, nr_kom_zlec, nr_zlec, nr_poz, kod_str, ilosc, szer, wys, ind_bud, id_poz from spisz
--         union
--         select 'S', nr_kom_str, 1, 0, 0, 0, kod_str, 0, 0, 0, ind_bud, 0 from struktury where typ_str<>'ZE') P
   from spisz P
   left join budstr B on B.kod_str=P.kod_str
   left join katalog K on B.zn_war='Sur' and K.nr_kat=B.nr_kom_skl
   left join struktury S on B.zn_war<>'Sur' and S.nr_kom_str=B.nr_kom_skl
   left join budstr B1 on B.zn_war='Str' and B1.nr_kom_str=B.nr_kom_skl
   left join katalog K1 on B.zn_war='Str' and B1.zn_war='Sur' and K1.nr_kat=B1.nr_kom_skl
   left join budstr B2 on B1.zn_war='Str' and B2.nr_kom_str=B1.nr_kom_skl
   left join katalog K2 on B1.zn_war='Str' and B2.zn_war='Sur' and K2.nr_kat=B2.nr_kom_skl
--   left join spisd D on D.nr_kom_zlec=P.nr_kom_zlec and D.nr_poz=P.nr_poz
--                      and (nvl(K.rodz_sur,nvl(K1.rodz_sur,K2.rodz_sur)) in ('TAF','LIS') or nvl(B.zn_war,nvl(B1.zn_war,B2.zn_war))='Pol')
--  where nr_komp_zr=:pNR_STR
   where P.typ_zlec='Pro'-- and P.nr_kom_zlec=:ZLEC and P.nr_poz=:POZ
--   where P.kod_str='FEC006\EMAL\H\PC18M9004\SIL\A\NEM006T\H\PC18M9004\SIL\A\NEM006T\H'
--   order by P.nr_kom_zlec, P.nr_poz, B.nr_kom_str, B.nr_skl, B1.nr_skl, B2.nr_skl;
  order by nr_kom_zlec, nr_poz, B.nr_kom_str, B.nr_skl, B1.nr_skl, B2.nr_skl;
/
CREATE OR REPLACE FORCE VIEW SPISS_LAM AS
SELECT  zrodlo, nr_komp_zr, nr_kol, szer, wys, nr_kom_str, lp, nr_war, czy_war, decode(czy_war,1,1,2) etap,
        dense_rank() over (partition by nr_komp_zr,nr_kol order by war_do) ktory_lam,
        dense_rank() over (partition by nr_komp_zr,nr_kol,war_do order by nr_war) ktore_szklo,
        nr_war-/*ktore_szklo*/dense_rank() over (partition by nr_komp_zr,nr_kol,war_do order by nr_war)+1 war_od,
        war_do, typ_kat, nr_kat, rodz_sur, grub, typ_inst, nr_inst, S.nk_obr,
        kod_laminatu(nr_kom_str,/*war_od*/nr_war-dense_rank() over (partition by nr_komp_zr,nr_kol,war_do order by nr_war)+1,war_do) kod_lam,
        id_rek, ident_bud, kod_str
FROM
(select (select min(min(nr_war)) from spiss_str S2
         where S2.zrodlo='S' and S2.nr_komp_zr=S.nr_kom_str and S2.nr_kol=1 and S2.nr_war>=S.nr_war
         group by nr_war
         having count(decode(S2.rodz_sur,'FOL',1,null))=0
        ) war_do,
        (select max(S.nr_war-S2.nr_war) from spiss_str S2
         where S2.zrodlo='S' and S2.nr_komp_zr=S.nr_kom_str and S2.nr_kol=1 and S2.nr_war=S.nr_war-1 and S2.rodz_sur='FOL'
        ) war_konc,
        sum(decode(rodz_sur,'FOL',1,0)) over (partition by nr_komp_zr,nr_kol,nr_war) il_fol_war,
        max(nr_fol) over (partition by nr_komp_zr,nr_kol,nr_war) nr_fol_war_max,
        S.*
 from spiss_str S
) S
--WHERE il_fol_war>0
WHERE (il_fol_war>0 and (czy_war=1 or rodz_sur='FOL' or rodz_sur='CZY' and znacz_pr='9.La') or czy_war=1 and war_konc=1)
  --AND S.zrodlo='S' and S.nr_komp_zr=:STR_LAM
ORDER BY S.LP;
/

CREATE OR REPLACE VIEW SPISS_V1
AS
 select zrodlo, S.nr_komp_zr, S.nr_kol, nvl2(rec_zero,0,S.etap) etap, nvl2(rec_zero,0,case when S.czy_war=1 and D.strona in (0,4) then 1 else 0 end) czy_war,
--       nvl(rec_zero,decode(war_lam,1,2,nvl(L.etap,S.etap))) etap, war_lam, L.lp lp_lam,
--               --sum(decode(S.rodz_sur,'FOL',1,0)) over (partition by S.nr_komp_zr,S.nr_kol) ile_fol,
               nvl(rec_zero,S.nr_war) war_od, nvl(rec_zero,S.nr_war) war_do, /*D.nr_kat Dnr_kat, S.nr_kat Snr_kat,*/ nvl(rec_zero,nvl(O.nr_kat_obr,decode(nvl(D.nr_kat,0),0,S.nr_kat,D.nr_kat))) nr_kat,
               D.kod_dod, nvl2(rec_zero,' ',S.rodz_sur) rodz_sur, /*D.strona Dstrona,*/ nvl(D.strona,decode(S.rodz_sur,'CZY',2,0)) strona,
               nvl2(rec_zero,0,case when D.kol_dod is null or S.czy_war=1 and D.strona=0 then S.lp else S.etap*100+D.kol_dod end) nr_porz,
               /*D.zn_war Dzn_war,*/ nvl2(rec_zero,'Str',case when S.rodz_sur='CZY' or D.nr_poc='11 O' then 'Obr' else nvl(D.zn_war,'Sur') end) zn_war,
               nvl(decode(D.strona,4,D.szer_obr,D0.szer_obr),S.szer) szer, nvl(decode(D.strona,4,D.wys_obr,D0.wys_obr),S.wys) wys,
               decode(sign(S.nk_obr),1,S.nk_obr,nvl(D.nr_komp_obr,decode(S.rodz_sur,'CZY',S.nr_kat,0))) nk_obr,
               nvl(O.symb_p_obr,nvl(O1.symb_p_obr,decode(S.rodz_sur,'CZY',S.typ_kat,' '))) symb_obr, nvl(O.nr_kat_obr,nvl(O1.nr_kat_obr,decode(S.rodz_sur,'CZY',S.nr_kat,0))) nr_kat_obr,
               nvl(D.par1,O.par_1) par1, nvl(D.par2,O.par_2) par2, nvl(D.par3,O.par_3) par3,  nvl(D.par4,O.par_4) par4, nvl(D.par5,O.par5) par5,
               RPAD(lpad(to_char(D.IL_ODC_PION),9,'0')||'0'||lpad(to_char(D.IL_ODC_Poz),5,'0'), 20, '0') boki, --D.IL_ODC_PION, D.IL_ODC_Poz,
               decode(sign(nvl(D.nr_komp_obr,0)),1,D.ilosc_do_wyk,/*pow*/decode(D.strona,4,D.szer_obr,D0.szer_obr)*0.001*decode(D.strona,4,D.wys_obr,D0.wys_obr)*0.001) il_obr,
               /*pow*/decode(D.strona,4,D.szer_obr,D0.szer_obr)*0.001*decode(D.strona,4,D.wys_obr,D0.wys_obr)*0.001 il_sur,
               nvl(I1.nr_komp_inst,I.nr_komp_inst) inst_std, nvl(I1.kolejn,I.kolejn) zn_plan, S.zn_pp,
               S.typ_kat, decode(nvl(rec_zero,-1),0,S.kod_str,decode(S.rodz_sur,'CZY',K0.typ_kat,S.typ_kat)) indeks,
               case when rec_zero is not null then S.ident_bud
                    when /*czy_war*/S.czy_war=1 and D.strona in (0,4) then rpad(translate(reverse(to_char(sum(reverse(rpad(decode(D.strona,4,'0',S.ident_bud_skl),100,'0'))) over  (partition by S.zrodlo, S.nr_komp_zr, S.nr_kol, S.etap, S.nr_war))),'23456789','11111111'),50,'0')
                    else S.ident_bud_skl end ident_bud,
               --nvl2(rec_zero,S.ident_bud,'0e') ident_bud, 
               nvl(D.nr_mag,S.nr_mag) nr_mag,
               S.nr_kom_str, S.kod_str, S.id_rek, 0 poziom, decode(rec_zero,0,S.nr_kom_str,S.nr_skl) ident_dod, ' ' str_dod, 0 cena
from spiss_str S
--dodanie rekordu zerowego
left join (select 0 rec_zero from firma union select null from firma) on S.lp=1 --firma zamiast dual bo nie dalo siê skompilowaæ procedur z 'UPDATE spiss'
--link do rekordu warstwy
left join spisd D0 on D0.nr_kom_zlec=S.nr_kom_zlec and D0.nr_poz=S.nr_poz and D0.do_war=S.nr_war and D0.strona=0 and rec_zero is null
--dane szkla (strona=0)
left join katalog K0 on K0.nr_kat=D0.nr_kat
--link do wszystkich rekordów na warstwie
left join spisd D on D.nr_kom_zlec=S.nr_kom_zlec and D.nr_poz=S.nr_poz and S.czy_war=1 and D.do_war=S.nr_war and rec_zero is null
left join slparob O on O.nr_k_p_obr=D.nr_komp_obr
left join slparob O1 on O1.nr_k_p_obr=S.nk_obr
--instalacja z Katalogu
left join parinst I on (S.rodz_sur='CZY' or D.strona=4) and I.ty_inst=decode(S.rodz_sur,'CZY',S.typ_inst,K0.typ_inst1) and I.nr_inst=decode(S.rodz_sur,'CZY',S.nr_inst,K0.nr_inst)
--instalacja ze Slownika Obróbek
left join parinst I1 on O.nr_komp_inst is not null and I1.nr_komp_inst=O.nr_komp_inst
where 1=1--S.nr_komp_zr=:NK_ZLEC and nr_kol=:POZ
  and not (S.rodz_sur='FOL' or S.rodz_sur='CZY' and S.znacz_pr='9.La')
  and not (S.rodz_sur='CZY' and S.nr_kat=(select nvl(max(O.nr_kat_obr),-1) from spisd D, slparob O where D.nr_kom_zlec=S.nr_kom_zlec and D.nr_poz=S.nr_poz and D.do_war=S.nr_war and O.nr_k_p_obr=D.nr_komp_obr))
ORDER BY zrodlo, nr_komp_zr, nr_kol, etap, war_od, czy_war desc, strona;
--laminowanie
CREATE OR REPLACE VIEW SPISS_V2
AS
Select zrodlo, nr_komp_zr, nr_kol, 2 etap, case when czy_war=1 or S.rodz_sur='CZY' and nr_war=war_od then 1 else 0 end czy_war, war_od, war_do,
       0 nr_kat, decode(S.rodz_sur,'FOL',typ_kat,kod_lam) kod_dod, S.rodz_sur, decode(czy_war,1,0,decode(S.rodz_sur,'CZY',4,2)) strona, 200+S.lp nr_porz,
       decode(S.rodz_sur,'FOL','Sur','Pol') zn_war, S.szer, S.wys,
       decode(S.rodz_sur,'CZY',nk_obr,0) nk_obr, decode(S.rodz_sur,'CZY',O.symb_p_obr,'') symb_obr, decode(S.rodz_sur,'CZY',nvl(O.nr_kat_obr,nr_kat),0) nr_kat_obr,
       O.par_1 par1, O.par_2 par2, O.par_3 par3, O.par_4 par4, O.par5, '000' boki,
       /*pow*/S.szer*0.001*S.wys*0.001 il_obr, /*pow*/S.szer*0.001*S.wys*0.001 il_sur,
       nvl(O.nr_komp_inst,I.nr_komp_inst) inst_std, nvl(O.kolejn_obr,I.kolejn) zn_plan, 0 zn_pp, typ_kat, kod_lam, '00e' ident_bud, 0 nr_mag,
       S.nr_kom_str, S.kod_str, S.id_rek, 0 poziom, ktory_lam ident_dod, ' ' str_dod, 0 cena
From spiss_lam S
LEFT JOIN slparob O ON S.rodz_sur='CZY' and O.nr_k_p_obr=S.nk_obr and S.nk_obr>0          --obr LAM
Left join parinst I on S.rodz_sur='CZY' and I.ty_inst=S.typ_inst and I.nr_inst=S.nr_inst
Where (nr_war=war_od or S.rodz_sur='FOL')
--  and  S.nr_komp_zr=:NK_ZLEC and nr_kol=:POZ
ORDER BY zrodlo, nr_komp_zr, nr_kol, etap, war_od, czy_war desc, strona;
--zespalanie
CREATE OR REPLACE VIEW SPISS_V3
AS
Select 'Z' zrodlo, nr_kom_zlec nr_komp_zr, nr_poz nr_kol,
       decode((select max(do_war)-sum(decode(K.rodz_sur,'LIS',2,0)) from spisd D,katalog K where D.nr_kom_zlec=Z.nr_kom_zlec and D.nr_poz=Z.nr_poz and K.nr_kat=D.nr_kat and D.strona=4),1,2,3) etap, --jest etap LAM jesli WAR_MAX>(IL_LISTEW)*2+1
       1 czy_war, 1 war_od, (select max(do_war) from spisd  D where D.nr_kom_zlec=Z.nr_kom_zlec and D.nr_poz=Z.nr_poz) war_do,
       0 nr_kat, ' ' kod_dod, ' ' rodz_sur, strona, 300+strona nr_porz,
       'Str' zn_war,
       szer, wys, decode(strona,4,O.nr_k_p_obr,0) nk_obr, decode(strona,4,O.symb_p_obr,' ') symb, decode(strona,4,O.nr_kat_obr,0) nr_kat_obr,
       decode(strona,4,O.par_1) par1, decode(strona,4,O.par_2) par2, decode(strona,4,O.par_3) par3, decode(strona,4,O.par_4) par4, decode(strona,4,O.par5) par5, '000' boki,
       decode(strona,4,pow) il_obr, pow il_sur,
       decode(strona,4,I.nr_komp_inst) inst_std, decode(strona,4,O.kolejn_obr) zn_plan, 0 zn_pp, ' ' typ_kat, kod_str indeks, Z.ind_bud ident_bud, Z.nr_mag,
       0 nr_kom_str, kod_str, id_poz id_rek, 0 poziom, 0 ident_dod, ' ' str_dod, 0 cena
From spisz Z
LEFT JOIN (select 0 strona from firma union select 4 strona from firma) ON 1=1
LEFT JOIN (select nr_k_p_obr, symb_p_obr, nr_kat_obr, nr_komp_inst, kolejn_obr, par_1, par_2, par_3, par_4, par5 from slparob where obr_lacz=0 and rownum=1) O ON 1=1 --obr MON podzapytanie celem zabezpiecznia przed >1 rekordem
Left join parinst I on I.nr_komp_inst=O.nr_komp_inst
Where typ_zlec='Pro' and typ_poz in ('I k','II ')
--  and  nr_kom_zlec=:ZLEC and nr_poz=:POZ
ORDER BY zrodlo, nr_komp_zr, nr_kol, etap, war_od, czy_war desc, strona;
/
CREATE OR REPLACE VIEW SPISS_V
AS
  SELECT * FROM spiss_v1
  UNION
  SELECT * FROM spiss_v2
  UNION
  SELECT * FROM spiss_v3;
/
