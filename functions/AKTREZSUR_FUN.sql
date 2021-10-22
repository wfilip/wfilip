create or replace FUNCTION AKTREZSUR_FUN (ZM_INDEXSUR IN VARCHAR2 DEFAULT ' ', ZM_NRMAG    IN NUMBER DEFAULT 0) RETURN NUMBER
AS
 zm_rezerwacja number(14,6);
BEGIN
    SELECT nvl(SUM( (IL_ZAD-rw_POB)/(1-0.01*DECODE(STRATY,100,50,STRATY))),0)
       INTO zm_rezerwacja
    FROM SURZAM
    WHERE (IL_ZAD-rw_POB)>0.05
    AND RODZ_SUR        <>'CZY'
    AND indeks           =ZM_INDEXSUR
    AND NR_MAG           =ZM_NRMAG
    AND NR_KOMP_ZLEC    IN
      (SELECT NR_KOM_ZLEC
      FROM ZAMOW
      WHERE TYP_ZLEC ='Pro'
      AND wyroznik  <>'O'
      AND forma_wprow='P'
      AND status     ='P'
      AND NOT substr(trim(to_char(flag_r,'09999')),2,1) in ('5','6')
      AND NOT substr(trim(to_char(flag_r,'09999')),3,1)='3'
      );
  RETURN zm_rezerwacja;    
END;
/
