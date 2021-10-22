CREATE OR REPLACE FUNCTION ILOSC_DODATKU (pNR_OBR NUMBER, pIL_OBR NUMBER, pWSP1 NUMBER, pWSP2 NUMBER, pWSP3 NUMBER, pWSP4 NUMBER, pWSP5 NUMBER) RETURN NUMBER
AS
 vNorma NUMBER(14,6) default 1;
 vIlSzt NUMBER(10) default 1;
 vWynik NUMBER(14,6);
BEGIN
 for l in (select S.met_oblicz, L.nr_kol_param, L.czy_korekt_wym rodz_par
           from slparob S, lista_p_obr L
           where S.nr_k_p_obr=pNR_OBR and L.nr_komp_struktury=S.nr_k_p_obr)
  loop
    if l.rodz_par=2 then
     vIlSzt := case l.nr_kol_param 
                 when 1 then pWSP1
                 when 2 then pWSP2
                 when 3 then pWSP3
                 when 4 then pWSP4
                 when 5 then pWSP5
                 else 0
               end;
    elsif l.rodz_par=9 then
     vNorma := vNorma * case l.nr_kol_param 
                         when 1 then pWSP1
                         when 2 then pWSP2
                         when 3 then pWSP3
                         when 4 then pWSP4
                         when 5 then pWSP5
                         else 0
                        end;
    end if;
    vWynik := case when l.met_oblicz in (1,2,4) then pIL_OBR*vNorma
                   when l.met_oblicz=3  then vNorma*vIlSzt
              end;
  end loop;
 RETURN vWynik;   
EXCEPTION
  WHEN OTHERS THEN
    RETURN -1;
END ILOSC_DODATKU;
/

CREATE OR REPLACE FORCE EDITIONABLE VIEW V_STR_SKL_SUR AS 
  select B.nr_kom_str, row_number() over (partition by B.nr_kom_str, B.kod_str order by B.nr_skl, B1.nr_skl, B2.nr_skl, B3.nr_skl, B4.nr_skl) lp,
       B.nr_skl, B1.nr_skl nr_skl1, B2.nr_skl nr_skl2, B3.nr_skl nr_skl3, B4.nr_skl nr_skl4,
       nvl(B4.zn_war,nvl(B3.zn_war,nvl(B2.zn_war,nvl(B1.zn_war,B.zn_war)))) zn_war, 
       nvl(B4.nr_kom_skl,nvl(B3.nr_kom_skl,nvl(B2.nr_kom_skl,nvl(B1.nr_kom_skl,B.nr_kom_skl)))) nr_kom_skl,
       nvl(B4.wsp,nvl(B3.wsp,nvl(B2.wsp,nvl(B1.wsp,B.wsp)))) wsp,
       nvl(B3.spos_obl,nvl(B3.spos_obl,nvl(B2.spos_obl,nvl(B1.spos_obl,B.spos_obl)))) spos_obl,
       B.kod_str, B1.nr_kom_str nr_kom_str1, B2.nr_kom_str nr_kom_str2, B3.nr_kom_str nr_kom_str3, B4.nr_kom_str nr_kom_str4,
       case when B4.zn_war='Sur' then 5
            when B3.zn_war='Sur' then 4
            when B2.zn_war='Sur' then 3
            when B1.zn_war='Sur' then 2
            when B.zn_war='Sur' then 1
            when B9.zn_war='Sur' then 9
       else 0 end poziom,
       case when B.zn_war='Pol' then 1
            when B1.zn_war='Pol' then 2
            when B2.zn_war='Pol' then 3
            when B3.zn_war='Pol' then 4
            when B9.zn_war='Sur' then 9
       else 0 end zn_pp
   from budstr B
   --left join katalog K on B.zn_war='Sur' and K.nr_kat=B.nr_kom_skl
   left join struktury S on B.zn_war<>'Sur' and S.nr_kom_str=B.nr_kom_skl
   left join budstr B1P on B.zn_war='Pol' and B1P.nr_kom_str=B.nr_kom_skl
   left join budstr B1 on B.zn_war<>'Sur' and B1.nr_kom_str=nvl(B1P.nr_kom_skl,B.nr_kom_skl) 
   --left join katalog K1 on K1.nr_kat=B1.nr_kom_skl
   left join budstr B2P on B1.zn_war='Pol' and B2P.nr_kom_str=B1.nr_kom_skl
   left join budstr B2 on B1.zn_war<>'Sur' and B2.nr_kom_str=nvl(B2P.nr_kom_skl,B1.nr_kom_skl)
   --left join katalog K2 on K2.nr_kat=B2.nr_kom_skl
   left join budstr B3P on B2.zn_war='Pol' and B3P.nr_kom_str=B2.nr_kom_skl
   left join budstr B3 on B2.zn_war<>'Sur' and B3.nr_kom_str=nvl(B3P.nr_kom_skl,B2.nr_kom_skl)
   --left join katalog K3 on K3.nr_kat=B3.nr_kom_skl
   left join budstr B4P on B3.zn_war='Pol' and B4P.nr_kom_str=B3.nr_kom_skl
   left join budstr B4 on B3.zn_war<>'Sur' and B4.nr_kom_str=nvl(B4P.nr_kom_skl,B3.nr_kom_skl)
   --left join katalog K4 on K4.nr_kat=B4.nr_kom_skl
   left join (select 'Sur' zn_war from dual) B9 on B4.zn_war<>'Sur' --nienull'owy B9 oznacza ¿e zaglebienie do B4 niewystarczajace
   where nvl(B9.zn_war,nvl(B4.zn_war,nvl(B3.zn_war,nvl(B2.zn_war,nvl(B1.zn_war,B.zn_war)))))='Sur'

   order by B.nr_skl, B1.nr_skl, B2.nr_skl, B3.nr_skl, B4.nr_skl;
/

CREATE OR REPLACE VIEW V_STR_SKL_SUR_GRUP AS
 Select V.*, K.nr_kat, K.typ_kat, K.rodz_sur, K.jed_pod, K.grubosc, K.waga, K.znacz_pr, K.ident_bud
 From
  (select nr_kom_str, max(kod_str) kod_str, zn_war, nr_kom_skl, max(spos_obl) spos_obl, avg(wsp) wsp, count(1) il
   from v_str_skl_sur
   group by nr_kom_str, zn_war, nr_kom_skl
  ) V
 Left join katalog K on K.nr_kat=V.nr_kom_skl;
 
CREATE OR REPLACE VIEW V_STR_SKL_SUR_WAR AS
 Select V.nr_kom_str, V.lp, V.zn_war, V.spos_obl, V.wsp, V.poziom, V.zn_pp,
            case when V.zn_pp=0 and K.rodz_sur in ('TAF','LIS','TAS') then 1
                 when V.zn_pp=1 and nr_skl1=1 then 1
                 when V.zn_pp=2 and nr_skl2=1 then 1
                 when V.zn_pp=3 and nr_skl3=1 then 1
                 when V.zn_pp=4 and nr_skl4=1 then 1
                 when V.zn_pp=9 then 1
                 else 0 end czy_war,
        sum(case when V.zn_pp=0 and K.rodz_sur in ('TAF','LIS','TAS') then 1
                 when V.zn_pp=1 and nr_skl1=1 then 1
                 when V.zn_pp=2 and nr_skl2=1 then 1
                 when V.zn_pp=3 and nr_skl3=1 then 1
                 when V.zn_pp=4 and nr_skl4=1 then 1
                 when V.zn_pp=9 then 1
                 else 0 end)
         over (partition by V.nr_kom_str, V.kod_str order by V.nr_skl, V.nr_skl1, V.nr_skl2, V.nr_skl3, V.nr_skl4) nr_war,
        K.nr_kat, K.typ_kat, K.rodz_sur, K.jed_pod, K.waga, K.grubosc,
        lag(K.grubosc,nvl(V.nr_skl4,nvl(V.nr_skl3,nvl(V.nr_skl2,nvl(V.nr_skl1,V.nr_skl))))-1)
         over (partition by V.nr_kom_str, V.kod_str order by V.nr_skl, V.nr_skl1, V.nr_skl2, V.nr_skl3, V.nr_skl4) grub_1skl,
        K.n_strat, K.znacz_pr, K.ident_bud, V.kod_str
 From v_str_skl_sur V
 Left join katalog K on K.nr_kat=V.nr_kom_skl
 ;
 
CREATE OR REPLACE VIEW V_SURZAM_POZ AS
select Z.nr_kom_zlec, Z.nr_zlec, data_zl, nr_kon, skrot_k, nr_kontraktu,
       P.nr_poz nr_poz_zlec, P.ilosc, P.szer, P.wys, P.pow, P.obw,
       D.szer_obr, D.wys_obr,
       decode(V.spos_obl,1,(D.szer_obr*0.001*D.wys_obr*0.001)*V.wsp, --pow
                         2,(D.szer_obr*0.002+D.wys_obr*0.002)*V.wsp, --obw
                         4,V.wsp, --ilosc
                         3,(D.szer_obr*0.002+D.wys_obr*0.002)-V.wsp, --obw - wsp
                         5,(D.szer_obr*0.001*D.wys_obr*0.001)-V.wsp, --pow - wsp
                         12,(D.szer_obr*0.002+D.wys_obr*0.002)*V.wsp*V.grub_1skl*nvl(nullif(P.gr_sil,0),PKG_PARAMETRY.GET_GR_SIL_DEFAULT()),
              999999) il_sur,
       V.*
from zamow Z
left join klient using (nr_kon)
left join spisz P on P.nr_kom_zlec=Z.nr_kom_zlec
left join struktury S on S.kod_str=P.kod_str
left join v_str_skl_sur_war V on V.nr_kom_str=S.nr_kom_str and V.rodz_sur<>'CZY'
left join spisd D on D.nr_kom_zlec=P.nr_kom_zlec and D.nr_poz=P.nr_poz and D.do_war=V.nr_war and D.strona=case when V.rodz_sur='TAF' then 4 else 0 end
where wyroznik in ('Z','R') and Z.status<>'A'
--order by Z.nr_kom_zlec desc, nr_poz, nr_skl, nr_skl1, nr_skl2, nr_skl3, nr_skl4
;

CREATE OR REPLACE VIEW V_SUROWCE_WAR AS
select P.nr_kom_zlec, P.nr_zlec, P.nr_poz, P.ilosc, P.szer, P.wys, P.pow, P.obw,
       D.szer_obr, D.wys_obr,
       case when to_number(trim(substr(nvl(trim(D.nr_poc),'00'),1,2)),'99')=11 --'11 Obróbka',
             then ILOSC_DODATKU(D.nr_komp_obr,D.ilosc_do_wyk,D.par1,D.par2,D.par3,D.par4,D.par5)
            when to_number(trim(substr(nvl(trim(D.nr_poc),'00'),1,2)),'99') between 2 and 10 --szpros
             then 0
            else --ilosc obrobki wg BUDSTR w odniesieniu do powierzchni/obwodu
             decode(V.spos_obl,1,(D.szer_obr*0.001*D.wys_obr*0.001)*V.wsp, --pow
                               2,(D.szer_obr*0.002+D.wys_obr*0.002)*V.wsp, --obw
                               4,V.wsp, --ilosc
                               3,greatest(0,(D.szer_obr*0.002+D.wys_obr*0.002)-V.wsp), --obw - wsp
                               5,greatest(0,(D.szer_obr*0.001*D.wys_obr*0.001)-V.wsp), --pow - wsp
                               12,(D.szer_obr*0.002+D.wys_obr*0.002)*V.wsp*V.grub_1skl*nvl(nullif(P.gr_sil,0),PKG_PARAMETRY.GET_GR_SIL_DEFAULT()),
                    999999)
       end il_sur,
       V.*,
       D.kod_dod, D.nr_mag, D.nr_kat nr_kat_dod, D.kol_dod, to_number(trim(substr(nvl(trim(D.nr_poc),'00'),1,2)),'99') nr_proc
--from zamow Z
--left join klient using (nr_kon)
--left join spisz P on P.nr_kom_zlec=Z.nr_kom_zlec
from spisz P
--left join struktury S on S.kod_str=P.kod_str
--left join v_str_skl_sur_war V on V.nr_kom_str=S.nr_kom_str and V.rodz_sur<>'CZY'
left join v_str_skl_sur_war V on V.kod_str=P.kod_str and V.rodz_sur<>'CZY'
left join spisd D on D.nr_kom_zlec=P.nr_kom_zlec and D.nr_poz=P.nr_poz and D.do_war=V.nr_war
          --dolinkowanie rek. warstw (strona 4 dla TAFLI) oraz szprosów i obróbek z dodatakami
          --AND NOT szybsze od OR
          and not (D.strona=4 and V.rodz_sur<>'TAF')
          and not (D.strona=0 and V.rodz_sur='TAF')
--          and not (D.strona=0 and V.rodz_sur not in ('LIS','TAS'))
          and not (to_number(trim(substr(nvl(trim(D.nr_poc),'00'),1,2)),'99')>1 and trim(D.kod_dod) is null)
          and not (to_number(trim(substr(nvl(trim(D.nr_poc),'00'),1,2)),'99')>1 and V.czy_war=0)
--order by Z.nr_kom_zlec desc, nr_poz, nr_skl, nr_skl1, nr_skl2, nr_skl3, nr_skl4
;

/*+ USE_NL (V)*/
CREATE OR REPLACE VIEW V_SUROWCE_POZ 
AS
select Z.nr_kom_zlec, Z.nr_zlec, Z.data_zl, nr_kon, K.skrot_k, Z.nr_kontraktu,
       V.nr_poz, min(V.ilosc) ilosc, nr_kat, V.typ_kat,
       case when max(V.nr_proc)<2 then ' ' else max(V.kod_dod) end kod_dod,
       case when max(V.nr_proc)<2 then  0  else max(V.nr_mag)  end nr_mag,
       max(case when V.nr_proc<2 then V.jed_pod
                else (select nvl(max(jed_pod),' ') from kartoteka where indeks=V.kod_dod and nr_mag=V.nr_mag)
           end) jedn,
       round(sum(V.ilosc*V.il_sur),6) il_netto,
       round(sum(V.ilosc*V.il_sur/(1-least(0.999999999,V.n_strat*0.01))),6) il_brutto_nom,
       case when max(V.rodz_sur)='TAF' and max(nr_proc)=0 then
       (select nvl(round(sum(opt_zlec.wyc_netto),6),0)
        from opt_zlec, opt_taf, opt_nr
        where opt_zlec.nr_komp_zlec=Z.nr_kom_zlec
          and opt_zlec.nr_poz=V.nr_poz and opt_zlec.nr_kat=V.nr_kat
          and opt_nr.nr_opt=opt_zlec.nr_opt and opt_taf.nr_opt=opt_zlec.nr_opt and opt_taf.nr_tafli=opt_zlec.nr_tafli
          and opt_taf.poz_w_pak>0)
       +(select nvl(round(sum(opt_zlec.wyc_netto),6),0)
         from opt_zlec, opt_taf, opt_nr,
              zamow W, spisz P
         where W.wyroznik='W' and W.nr_komp_poprz=Z.nr_kom_zlec and P.nr_kom_zlec=W.nr_kom_zlec and P.nr_poz_pop=V.nr_poz
           and opt_zlec.nr_komp_zlec=W.nr_kom_zlec and  opt_zlec.nr_poz=P.nr_poz and opt_zlec.nr_kat=V.nr_kat
           and opt_nr.nr_opt=opt_zlec.nr_opt and opt_taf.nr_opt=opt_zlec.nr_opt and opt_taf.nr_tafli=opt_zlec.nr_tafli
           and opt_taf.poz_w_pak>0)   
       else 0 end   il_netto_opt,
       case when max(V.rodz_sur)='TAF' and max(nr_proc)=0 then
        (select nvl(round(sum(opt_zlec.wyc_netto)*avg(decode(opt_nr.wyc_netto,0,0,opt_nr.wyc_brutto/opt_nr.wyc_netto)),6),0) brutto
         from opt_zlec, opt_taf, opt_nr 
         where opt_zlec.nr_komp_zlec=Z.nr_kom_zlec and opt_zlec.nr_poz=V.nr_poz and opt_zlec.nr_kat=V.nr_kat
           and opt_nr.nr_opt=opt_zlec.nr_opt and opt_taf.nr_opt=opt_zlec.nr_opt and opt_taf.nr_tafli=opt_zlec.nr_tafli
           and opt_taf.poz_w_pak>0)
         +
        (select nvl(round(sum(opt_zlec.wyc_netto)*avg(decode(opt_nr.wyc_netto,0,0,opt_nr.wyc_brutto/opt_nr.wyc_netto)),6),0) brutto
         from opt_zlec, opt_taf, opt_nr,
              zamow W, spisz P
         where W.wyroznik='W' and W.nr_komp_poprz=Z.nr_kom_zlec and P.nr_kom_zlec=W.nr_kom_zlec and P.nr_poz_pop=V.nr_poz
           and opt_zlec.nr_komp_zlec=W.nr_kom_zlec and  opt_zlec.nr_poz=P.nr_poz and opt_zlec.nr_kat=V.nr_kat
           and opt_nr.nr_opt=opt_zlec.nr_opt and opt_taf.nr_opt=opt_zlec.nr_opt and opt_taf.nr_tafli=opt_zlec.nr_tafli
           and opt_taf.poz_w_pak>0)
       else 0 end   il_brutto_opt   
from zamow Z
left join v_surowce_war V on V.nr_kom_zlec=Z.nr_kom_zlec
left join klient K using (nr_kon)
where Z.wyroznik in ('Z','R') and Z.status<>'A'
group by Z.nr_kom_zlec, Z.nr_zlec, Z.data_zl, nr_kon, K.skrot_k, Z.nr_kontraktu,
         V.nr_poz, V.nr_kat, V.typ_kat,
         case when V.nr_proc between 2 and 11 then V.kol_dod else 0 end
order by nr_kom_zlec, nr_poz, nr_kat, nr_mag
;


CREATE OR REPLACE VIEW V_SUROWCE_ZLEC AS
select V.nr_kom_zlec, V.nr_zlec, V.data_zl,  nr_kon, V.skrot_k, V.nr_kontraktu,
       V.nr_kat, V.typ_kat, V.kod_dod, V.nr_mag, max(V.jedn) jedn,
       --sum(il_netto) il_netto, sum(il_brutto_nom) il_brutto_nom,
       --tymczasowo pobieranie z SURZAM gdy w POZ il_netto=0 (KRATA)
       case when sum(il_netto)>0 then sum(il_netto) 
            else (select nvl(round(sum(il_zad),6),0) from surzam S where S.nr_komp_zlec=V.nr_kom_zlec and S.indeks=V.kod_dod)
       end il_netto,
       case when sum(il_brutto_nom)>0 then sum(il_brutto_nom) 
            else (select nvl(round(sum(il_zad/(1-S.straty*0.01)),6),0) from surzam S where S.nr_komp_zlec=V.nr_kom_zlec and S.indeks=V.kod_dod)
       end il_brutto_nom,
       sum(il_netto_opt) il_netto_opt, sum(il_brutto_opt) il_brutto_opt,
       case when sum(il_netto)>0 then
             sum(il_brutto_opt) + round((sum(il_netto)-sum(il_netto_opt))*sum(il_brutto_nom)/sum(V.il_netto),6)
            else 
             (select nvl(round(sum(il_zad/(1-S.straty*0.01)),6),0) from surzam S where S.nr_komp_zlec=V.nr_kom_zlec and S.indeks=V.kod_dod)
       end il_brutto,
       case when V.nr_mag=0 then 
         (select nvl(round(sum(rw_pob),6),0) from surzam S where S.nr_komp_zlec=V.nr_kom_zlec and S.nr_kat=V.nr_kat)
         +(select nvl(round(sum(rw_pob),6),0) from surzam S, zamow Z where Z.wyroznik='W' and Z.nr_komp_poprz=V.nr_kom_zlec and S.nr_komp_zlec=Z.nr_kom_zlec and S.nr_kat=V.nr_kat)
        else
         (select nvl(round(sum(rw_pob),6),0) from surzam S where S.nr_komp_zlec=V.nr_kom_zlec and S.nr_mag=V.nr_mag and S.indeks=V.kod_dod)
         +(select nvl(round(sum(rw_pob),6),0) from surzam S, zamow Z where Z.wyroznik='W' and Z.nr_komp_poprz=V.nr_kom_zlec and S.nr_komp_zlec=Z.nr_kom_zlec and S.nr_mag=V.nr_mag and S.indeks=V.kod_dod)
       end il_na_rw_netto,
       case when V.nr_mag=0 then 
         (select nvl(round(sum(rw_pob/(1-straty*0.01)),6),0) from surzam S where S.nr_komp_zlec=V.nr_kom_zlec and S.rw_pob>0 and S.nr_kat=V.nr_kat)
         +(select nvl(round(sum(rw_pob/(1-straty*0.01)),6),0) from surzam S, zamow Z where Z.wyroznik='W' and Z.nr_komp_poprz=V.nr_kom_zlec and S.nr_komp_zlec=Z.nr_kom_zlec and S.rw_pob>0 and S.nr_kat=V.nr_kat)
        else 
         (select nvl(round(sum(rw_pob/(1-straty*0.01)),6),0) from surzam S where S.nr_komp_zlec=V.nr_kom_zlec and S.rw_pob>0 and S.nr_mag=V.nr_mag and S.indeks=V.kod_dod)
         +(select nvl(round(sum(rw_pob/(1-straty*0.01)),6),0) from surzam S, zamow Z where Z.wyroznik='W' and Z.nr_komp_poprz=V.nr_kom_zlec and S.nr_komp_zlec=Z.nr_kom_zlec and S.rw_pob>0 and S.nr_mag=V.nr_mag and S.indeks=V.kod_dod)
       end il_na_rw
from v_surowce_poz V
group by nr_kom_zlec, nr_zlec, data_zl,  nr_kon, skrot_k, nr_kontraktu,
         nr_kat, typ_kat, kod_dod, nr_mag
order by nr_kom_zlec, nr_kat, nr_mag
;

select * from l_wyc2_plus_wew where nr_kom_zlec=:NR_ZLEC;

create or replace view V_OBROBKI_POZ
as
 select nr_kom_zlec, nr_zlec, nr_poz,  nr_obr, max(symb_obr) symb_obr, max(jedn) jedn,
        sum(il_obr) il_plan, round(sum(il_obr*wsp_p),6) il_plan_przel,
        sum(il_obr*sign(nr_zm_wyk)) il_wyk, round(sum(il_obr*sign(nr_zm_wyk)*nvl(wsp_w,1)),6) il_wyk_przel
 from l_wyc2_plus_wew
 group by nr_kom_zlec, nr_zlec, nr_poz, nr_obr
 having exists (select 1 from harmon where harmon.nr_komp_zlec=nr_kom_zlec)
 order by nr_kom_zlec, nr_zlec, nr_poz, nr_obr;
