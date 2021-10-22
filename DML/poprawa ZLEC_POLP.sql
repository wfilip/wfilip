--ROKP
GRANT select ON zamow TO &&OWNER;
GRANT select ON zlec_polp TO  &&OWNER;
GRANT select ON zlec_polp1 TO  &&OWNER;

--baza aktualna
UPDATE zlec_polp P
   SET (typ, nr_zlec_wew, wsk)=
       (select typ, nr_zlec_wew, wsk
        from &&ROKP_OWNER..zlec_polp
        where nr_komp_zlec=P.NR_KOMP_ZLEC and nr_poz_zlec=P.NR_POZ_ZLEC and nr_warstwy=P.NR_WARSTWY)
   WHERE NR_ZLEC_WEW=0
     AND exists (select 1 from &&ROKP_OWNER..zlec_polp where nr_komp_zlec=P.NR_KOMP_ZLEC and nr_zlec_wew>0);

create or replace TRIGGER ZLEC_POLP_ON_INSERT 
BEFORE INSERT ON ZLEC_POLP 
FOR EACH ROW
DECLARE
 vROKP NUMBER(10);
BEGIN
  --select nr_komp_rokp into vROKP from zamow where nr_kom_zlec=:NEW.NR_KOMP_ZLEC;
  select nvl(max(nr_kom_zlec),0) into vROKP from &&ROKP_OWNER..zamow where nr_kom_zlec=:NEW.NR_KOMP_ZLEC;
  IF vROKP>0 THEN
    select typ, nr_zlec_wew, wsk
      INTO :NEW.TYP, :NEW.NR_ZLEC_WEW, :NEW.WSK
    from &&ROKP_OWNER..zlec_polp 
    where nr_komp_zlec=:NEW.NR_KOMP_ZLEC and nr_poz_zlec=:NEW.NR_POZ_ZLEC and nr_warstwy=:NEW.NR_WARSTWY;
  END IF;
  IF :NEW.NR_ZLEC_WEW>0 THEN
    insert into zlec_polp1 (NR_KOMP_ZLEC,NR_POZ_ZLEC,NR_WARSTWY,NR_SKLAD,SKLADNIK,ZN_WARSTWY,INDEKS,WSK,TYP,NR_ZLEC_WEW,OPIS,IDENT_POZ)
       select NR_KOMP_ZLEC,NR_POZ_ZLEC,NR_WARSTWY,NR_SKLAD,SKLADNIK,ZN_WARSTWY,INDEKS,WSK,TYP,NR_ZLEC_WEW,OPIS,:NEW.IDENT_POZ
       from &&ROKP_OWNER..zlec_polp1 
       where nr_komp_zlec=:NEW.NR_KOMP_ZLEC and nr_poz_zlec=:NEW.NR_POZ_ZLEC and nr_warstwy=:NEW.NR_WARSTWY
         and not exists (select 1 from zlec_polp1
                         where nr_komp_zlec=:NEW.NR_KOMP_ZLEC and nr_poz_zlec=:NEW.NR_POZ_ZLEC and nr_warstwy=:NEW.NR_WARSTWY);
  END IF;
EXCEPTION WHEN OTHERS THEN null;
END;
/
