create or replace TRIGGER ZAMOW_ON_UPD_D_ZAK_PROD 
BEFORE UPDATE OF D_ZAK_PROD ON ZAMOW 
FOR EACH ROW 
DECLARE 
 DATA_MIN DATE;
 DATA_MAX DATE;
BEGIN
  SELECT nvl(min(data_wyk),'1901/01/01'), nvl(max(data_wyk),'1901/01/01')
    INTO DATA_MIN, DATA_MAX
  FROM spise
  WHERE nr_komp_zlec=:NEW.nr_kom_zlec
    AND zn_wyk<>9;
  IF DATA_MIN<'2010/01/01' THEN
   :NEW.D_ZAK_PROD:='1901/01/01';
  ELSE 
  :NEW.D_ZAK_PROD:=DATA_MAX;
  END IF;
EXCEPTION WHEN OTHERS THEN 
  NULL;
END;
/

update zamow
set D_ZAK_PROD=(select nvl(decode(min(data_wyk),'1901/01/01',min(data_wyk),max(data_wyk)),zamow.D_ZAK_PROD) from spise where nr_komp_zlec=zamow.nr_kom_zlec and zn_wyk<>9)
where typ_zlec='Pro' and D_ZAK_PROD>'2010/01/01';

select nr_komp_zlec, nvl(decode(min(data_wyk),'1901/01/01',min(data_wyk),max(data_wyk)),'1901/01/01')
from spise      
where zn_wyk<>9
group by nr_komp_zlec;