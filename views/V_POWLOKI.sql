--sql u¿yty w prog. Zlecenie-zapamiêtaj pow³oki
CREATE OR REPLACE VIEW V_POWLOKI
AS
 Select nr_kom_zlec, nr_poz, ident,
      ListAgg(case gdzie_powloka when 1 then '#'||to_char(ktore_szklo*2-1) when 2 then '#'||to_char(ktore_szklo*2) else '' end,' ') within group (order by do_war) gdzie_powloki
 From
 (select nr_kom_zlec, nr_poz, ident, do_war, decode(IL_ODC_PION,100000000,1,1000000,2,0) gdzie_powloka, kod_dod, nr_kat, rodz_sur,
        sum(case rodz_sur when 'POL' then S.il_szk when 'TAF' then 1 else 0 end) over (partition by nr_kom_zlec, nr_poz order by do_war) ktore_szklo
  from spisd D
  left join katalog K using (nr_kat)
  left join struktury S on S.kod_str=D.kod_dod
  where D.strona=4 and K.rodz_sur in ('TAF','POL')
 )
 Group By nr_kom_zlec, nr_poz, ident
 Order By nr_kom_zlec, nr_poz;
 
--select * from v_powloki where nr_kom_zlec=:NK_ZLEC and not (:NR_POZ>0 and not nr_poz=:NR_POZ);