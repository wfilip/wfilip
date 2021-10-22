create or replace FUNCTION  SIP_index_exp_to_varchar2 (pOwner VARCHAR2, pIndName varchar2, pColumnPos NUMBER)
RETURN VARCHAR2
IS
varcharVal VARCHAR2(4000);
varcharLength NUMBER;
cur PLS_INTEGER := DBMS_SQL.OPEN_CURSOR;
fetchIt PLS_INTEGER;
BEGIN
 DBMS_SQL.PARSE (cur, 'SELECT column_expression FROM all_ind_expressions WHERE table_owner=:1 and index_name=:2 and column_position=:3', DBMS_SQL.NATIVE);
 DBMS_SQL.BIND_VARIABLE(cur, ':1', pOwner);
 DBMS_SQL.BIND_VARIABLE(cur, ':2', pIndName);
 DBMS_SQL.BIND_VARIABLE(cur, ':3', pColumnPos);
 --DBMS_SQL.PARSE (cur, 'SELECT column_expression FROM all_ind_expressions WHERE table_owner='''||pOwner||''' and index_name='''||pIndName||''' and column_position='||pColumnPos, DBMS_SQL.NATIVE);
 DBMS_SQL.DEFINE_COLUMN_LONG(cur,1);
 fetchIt := DBMS_SQL.EXECUTE_AND_FETCH(cur);
 DBMS_SQL.COLUMN_VALUE_LONG(cur,1,4000,0,varcharVal,varcharLength);
 DBMS_SQL.CLOSE_CURSOR(cur);
 RETURN varcharVal;
EXCEPTION WHEN OTHERS THEN
 DBMS_SQL.CLOSE_CURSOR(cur);
 RAISE;
END;
/

grant execute on SIP_index_exp_to_varchar2 to cutter with grant option;
grant execute on SIP_index_exp_to_varchar2 to cutter_ddl;