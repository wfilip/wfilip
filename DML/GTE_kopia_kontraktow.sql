select max(nr_komp_kontr) from cent_kontrakt;
DEFINE OSTAT_NR=;

delete from cent_kontrakt where nr_komp_kontr>=&OSTAT_NR;
delete from cent_pozkontr where nr_komp_kontr>=&OSTAT_NR;
delete from gte2019.kontrakt where nr_komp_kontr>=&OSTAT_NR;
delete from gte2019.pozkontr where nr_komp_kontr>=&OSTAT_NR;

DECLARE
 nrN NUMBER(10) :=&OSTAT_NR;
BEGIN
 FOR K in (select * from cent_kontrakt
           where trunc(data_zak,'YYYY')='18/01/01' and data_pocz<data_zak and trunc(data_pocz,'YYYY')='18/01/01'
             and not exists (select 1 from cent_kontrakt C2 where cent_kontrakt.nr_kon=C2.nr_kon and trunc(greatest(data_pocz,data_zak),'YYYY')='19/01/01')
          )  
 LOOP
  INSERT INTO cent_pozkontr
    SELECT nrN,poz_kontr,indeks,typ_wyrobu,naz_dla_kli,rabat,
           decode(rodz_ceny,'zl/s',(select nvl(max(cena_um),0) from cent_pozkontr C2 where C2.nr_komp_kontr=C1.nr_komp_kontr and C2.indeks=C1.indeks and C2.rodz_ceny='zl/m'),cena_um),
          ilosc_minimalna,ilosc_maksymalna,decode(pow_min,0.2001,0.3001,pow_min),decode(pow_max,0.2,0.3,pow_max),waga_dost,dopl_za_wage,dopl_za_kszt,dopl_za_szablon,ilosc_plan,ilosc_zreal,gwarancja,decode(rodz_ceny,'zl/s','zl/m',rodz_ceny),czas_realizacji,poprawki,d_zatw,op_zatw,poz_ok,dop_troj,dop_lin,nr_komp_rys,kol_wydr 
    FROM cent_pozkontr C1 where nr_komp_kontr=K.nr_komp_kontr;
  K.nr_komp_kontr:=nrN;
  K.data_pocz:=trunc(sysdate);
  K.data_zak:='2019/12/31';
  INSERT INTO cent_kontrakt VALUES K;
  nrN:=nrN+1;
 END LOOP;
END;
/

insert into gte2019.kontrakt
select * from cent_kontrakt where nr_komp_kontr>=&OSTAT_NR;
insert into gte2019.pozkontr
select * from cent_pozkontr where nr_komp_kontr>=&OSTAT_NR;

UPDATE cent_pozkontr C1
SET (pow_min, pow_max, cena_um, rodz_ceny)=
    (SELECT decode(C1.pow_min,0.2001,0.3001,C1.pow_min),decode(C1.pow_max,0.2,0.3,C1.pow_max),
            decode(C1.rodz_ceny,'zl/s',nvl(max(C2.cena_um),0),C1.cena_um),
            decode(C1.rodz_ceny,'zl/s','zl/m',C1.rodz_ceny)
    FROM cent_pozkontr C2
    WHERE C2.nr_komp_kontr=C1.nr_komp_kontr and C2.indeks=C1.indeks and C2.rodz_ceny='zl/m')
WHERE C1.nr_komp_kontr<&OSTAT_NR and (select greatest(data_pocz,data_zak) from cent_kontrakt K where K.nr_komp_kontr=C1.nr_komp_kontr)>=trunc(sysdate);
--ODDZIA£
UPDATE pozkontr C1
SET (pow_min, pow_max, cena_um, rodz_ceny)=
    (SELECT decode(C1.pow_min,0.2001,0.3001,C1.pow_min),decode(C1.pow_max,0.2,0.3,C1.pow_max),
            decode(C1.rodz_ceny,'zl/s',nvl(max(C2.cena_um),0),C1.cena_um),
            decode(C1.rodz_ceny,'zl/s','zl/m',C1.rodz_ceny)
    FROM pozkontr C2
    WHERE C2.nr_komp_kontr=C1.nr_komp_kontr and C2.indeks=C1.indeks and C2.rodz_ceny='zl/m')
WHERE C1.nr_komp_kontr<3325 and (select greatest(data_pocz,data_zak) from kontrakt K where K.nr_komp_kontr=C1.nr_komp_kontr)>=trunc(sysdate);

--przywrócenie zl/szt
update cent_pozkontr P
set rodz_ceny='zl/s', cena_um=cena_um*pow_max
where rodz_ceny='zl/m' and pow_max=0.3
  and exists (select 1 from cent_kontrakt K where K.nr_komp_kontr=P.nr_komp_kontr and sysdate between data_pocz and data_zak);