create or replace FUNCTION NR_ZLECTYP (p_nr_war IN NUMBER)
RETURN NUMBER AS 
BEGIN
  --zwraca nr zlec_typ w celu wyciagniecia parametrów podanej wartswy
  if p_nr_war>0 and p_nr_war<=5 then
    return p_nr_war+14;
  elsif p_nr_war>5 and p_nr_war<=20 then
    return p_nr_war+29;
  else
    return 0;
  end if;
END NR_ZLECTYP;
/