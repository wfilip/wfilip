SELECT OBJECT_NAME, OBJECT_TYPE FROM user_objects WHERE status = 'INVALID' ORDER BY 2;

--kompilacja niepoprawnych obiektów
declare
 n char(1);
begin
FOR cur IN (SELECT OBJECT_NAME, OBJECT_TYPE FROM user_objects WHERE status = 'INVALID' ORDER BY 2) LOOP 
 BEGIN
  if cur.OBJECT_TYPE = 'PACKAGE BODY' then 
    EXECUTE IMMEDIATE 'alter PACKAGE "' || cur.OBJECT_NAME || '" compile body';
  else 
    EXECUTE IMMEDIATE 'alter ' || cur.OBJECT_TYPE || ' "' || cur.OBJECT_NAME || '" compile'; 
  end if; 
  dbms_output.put_line(cur.OBJECT_TYPE || ' ' || cur.OBJECT_NAME || ' compiled');
 EXCEPTION
  WHEN OTHERS THEN 
  dbms_output.put_line(cur.OBJECT_TYPE || ' ' || cur.OBJECT_NAME || ' not compiled ' || SQLERRM);
 END;
END LOOP;
end;
/
QUIT;