create or replace function ETYKIETA_PROD_WF(p_NrKompZlec in NUMBER, p_NrPoz in NUMBER, p_NrSzt in NUMBER, p_NrWar in NUMBER)
   return varchar2
is
   vResult    varchar2(32000);
   v_col_name varchar2(100);
   v_col_type varchar2(30);
   v_col     varchar2(1000);
   cursor c_col is select column_name,data_type from ALL_TAB_COLS where TABLE_NAME='V_ETYKIETY_PROD3' and owner in (select sys_context( 'userenv', 'current_schema' ) from dual);
   rec_col c_col%ROWTYPE;
   TYPE cur_typ IS REF CURSOR;
   c cur_typ;
   query_str VARCHAR2(4000);
   pierwszy boolean := True;
begin
  vResult := '';  

  OPEN c_col;
  LOOP
    FETCH c_col INTO rec_col;
    EXIT WHEN c_col%NOTFOUND;
    if instr(rec_col.column_name,'F_')>0 then
      query_str := query_str || '''[' || replace(rec_col.column_name,'F_','') || ']''||' || rec_col.column_name ||' ||''#13''|| ';
    end if;
  END LOOP;
  CLOSE c_col;
  query_str := 'select '||query_str||''' '' from v_etykiety_prod3 where nr_komp_zlec=:zlec and nr_poz=:poz and nr_szt=:szt and nr_war=:war';
  EXECUTE IMMEDIATE query_str
          INTO vResult
          USING p_NrKompZlec,p_NrPoz,p_NrSzt,p_NrWar;
  return replace(vResult,'#13',Chr(13)||Chr(10));
  EXCEPTION WHEN OTHERS THEN
    IF c_col%ISOPEN THEN CLOSE c_col; END IF;
    --raise;
    return ' ';
end ETYKIETA_PROD_WF;