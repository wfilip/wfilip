create or replace PROCEDURE             "ZAMKNIJ_STOJAK" 
( pNR_STOJ IN NUMBER
) AS
  paczka number;
BEGIN
  paczka := PKG_MAIN.GET_KONFIG_T(24,'Nr paczki w l_wyc');
  UPDATE l_wyc
  SET zn_stoj=paczka
  WHERE nr_stoj=pNR_STOJ and zn_stoj=0;
END ZAMKNIJ_STOJAK;
/

create or replace PROCEDURE             "ZAMKNIJ_STOJAKI" 
( pNR_INST IN NUMBER, pNR_KOMP_ZM IN NUMBER
) AS 
  CURSOR c1 IS
            SELECT DISTINCT nr_stoj
            FROM l_wyc
            WHERE zn_stoj=0 AND nr_stoj>0
              AND (pNR_INST=0 or nr_inst=pNR_INST)
              AND (pNR_KOMP_ZM=0 or PKG_CZAS.NR_KOMP_ZM(d_wyk,zm_wyk)=pNR_KOMP_ZM);
 vStoj NUMBER(10);                           
BEGIN
  OPEN c1;
  LOOP
   FETCH c1 INTO vStoj;
   EXIT WHEN c1%NOTFOUND;
   ZAMKNIJ_STOJAK(vStoj);
  END LOOP;
  CLOSE c1;
END ZAMKNIJ_STOJAKI;
/