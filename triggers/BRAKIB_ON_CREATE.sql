create or replace TRIGGER BRAKIB_ON_CREATE 
BEFORE INSERT ON BRAKI_B 
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
BEGIN
 SELECT braki_b_seq.nextval INTO :NEW.NR_KOL FROM dual;
 
 INSERT INTO cr_data (nr_kom_zlec,nr_poz,nr_szt,nr_war,szer,wys,
                      id_br,nr_war_br,typ_kat,flag)
 SELECT D.nr_kom_zlec, D.nr_poz, :NEW.nr_szt, D.do_war, D.szer_obr, D.wys_obr,
        :NEW.nr_kol, row_number() over (order by D.do_war), K.typ_kat, 0
 FROM spisd D LEFT JOIN katalog K USING (nr_kat)
 WHERE D.nr_kom_zlec=:NEW.nr_zlec and D.nr_poz=:NEW.nr_poz and D.strona=4
   AND (:NEW.nr_war in (0,D.do_war) OR
        :NEW.laminat=1 and D.do_war between :NEW.nr_war
        and (select max(W.straty) war_do from wykzal W
             where W.nr_komp_zlec=D.nr_kom_zlec and W.nr_poz=D.nr_poz
               and W.nr_warst=:NEW.nr_war and W.straty>W.nr_warst)
       );
 --przy rejestracji z trybu PRODUKCJA
 IF :NEW.NR_WAR=0 THEN 
  UPDATE l_wyc 
  SET zn_braku=1 
  WHERE nr_kom_zlec=:NEW.nr_zlec AND nr_poz_zlec=:NEW.nr_poz AND nr_szt=:NEW.nr_szt
    AND zn_wyrobu=1 AND zn_braku<>1;
 END IF;   
EXCEPTION WHEN OTHERS THEN
 NULL;
END;
/