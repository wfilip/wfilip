create or replace PROCEDURE OPT_TO_KOL_STOJAKOW (pNK_ZLEC NUMBER, pNR_KAT NUMBER DEFAULT 0)
AS
 cursor k1 (pPOZ NUMBER, pKAT NUMBER, pOPT NUMBER, pTAF NUMBER) IS 
  SELECT * FROM kol_stojakow
  WHERE nr_komp_zlec=pNK_ZLEC and nr_poz=pPOZ and nr_katalog=pKAT and nr_optym<=0
  ORDER BY nr_sztuki, nr_warstwy,
           case when nr_optym=-pOPT and nr_taf=pTAF then 1 
                when nr_optym=0 then 2
            else 9 end
  FOR UPDATE;
 recK k1%ROWTYPE;
 i NUMBER(10);
BEGIN
 UPDATE kol_stojakow  --ustawienie minusowych NR_OPT
 SET nr_optym=-abs(nr_optym)
 WHERE nr_komp_zlec=pNK_ZLEC and pNR_KAT in (0,nr_katalog);
 FOR o IN 
  (select nr_poz, nr_opt, nr_tafli, max(nr_kat) nr_kat, sum(il_wyc) il_opt,
          (select count(1) from kol_stojakow K
           where K.nr_komp_zlec=opt_zlec.nr_komp_zlec and K.nr_poz=opt_zlec.nr_poz
                   and K.nr_katalog=opt_zlec.nr_kat and K.nr_optym=opt_zlec.nr_opt
                   and K.nr_taf=opt_zlec.nr_tafli) il_kol
   from opt_zlec
   where nr_komp_zlec=pNK_ZLEC and pNR_KAT in (0,nr_kat)
   group by nr_komp_zlec, nr_poz, nr_opt, nr_tafli, nr_kat
   order by nr_poz, il_opt-il_kol) --najpierw nadmiarowe w KOL_STAJAKOW
  LOOP
   --IF o.il_opt<o.il_kol THEN
    i:=0;
    OPEN k1(o.nr_poz,o.nr_kat,o.nr_opt,o.nr_tafli);
    LOOP    
     FETCH k1 INTO recK;
     EXIT WHEN k1%NOTFOUND;
     i:=i+1;
     IF i<=o.il_opt THEN
      UPDATE kol_stojakow SET nr_optym=o.nr_opt, nr_taf=o.nr_tafli
      WHERE CURRENT OF k1;
     ELSE
      EXIT; 
     END IF; 
    END LOOP; --koniec pêtli po KOL_STOJAKOW 
    CLOSE k1;
   --END IF;
  END LOOP;
END OPT_TO_KOL_STOJAKOW;
/