create or replace function OPIS_KSZTALTU (pTYP13 VARCHAR2, pTYP15 VARCHAR2 default null)
RETURN VARCHAR2
 AS
 TYPE tab IS TABLE OF VARCHAR2(8);
  opisy tab;
 par NUMBER(6,1); 
 wynik VARCHAR2(1000); 
BEGIN
 opisy := tab ('Nr kat','Nr kszt','L','L1','L2','H','H1','H2','R','R1','R2','R3','T1','T2','T3','T4');
 --return to_char(strtokenN(pTYP13,2,':','999'));
 IF strtokenN(pTYP13,2,':','9999')=0 THEN 
  return ' ';
 END IF;
 wynik:=opisy(2)||':'||strtokenN(pTYP13,2,':','9999')||'/'||strtokenN(pTYP13,1,':','9');
 FOR i IN 3..16
  LOOP
   par:=strtokenN(pTYP13,i,':','9999');
   IF par>0 THEN
    wynik:=wynik||' '||opisy(i)||':'||trim(to_char(par));
   END IF; 
  END LOOP;
  return wynik;
END OPIS_KSZTALTU;
/