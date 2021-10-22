create or replace FUNCTION cutter.SIP_index_exp_to_varchar2 (pOwner VARCHAR2, pIndName varchar2, pColumnPos NUMBER)
RETURN VARCHAR2
IS
varcharVal VARCHAR2(4000);
varcharLength NUMBER;
cur PLS_INTEGER := DBMS_SQL.OPEN_CURSOR;
fetchIt PLS_INTEGER;
BEGIN
-- DBMS_SQL.PARSE (cur, 'SELECT column_expression FROM all_ind_expressions WHERE table_owner=:1 and index_name=:2 and column_position=:3', DBMS_SQL.NATIVE);
-- DBMS_SQL.BIND_VARIABLE(cur, ':1', pOwner);
-- DBMS_SQL.BIND_VARIABLE(cur, ':2', pIndName);
-- DBMS_SQL.BIND_VARIABLE(cur, ':3', pColumnPos);
 DBMS_SQL.PARSE (cur, 'SELECT column_expression FROM all_ind_expressions WHERE table_owner='''||pOwner||''' and index_name='''||pIndName||''' and column_position='||pColumnPos, DBMS_SQL.NATIVE);
 --DBMS_SQL.PARSE (cur, 'SELECT column_expression FROM user_ind_expressions WHERE index_name='''||pIndName||''' and column_position='||pColumnPos, DBMS_SQL.NATIVE);
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

DEFINE OWNER=MA2020;
DEFINE TAB=ZAMOW
KRAJ;

CREATE OR REPLACE VIEW CUTTER.V_INDEKSY
AS
select owner, table_name, index_name, uniqueness,
       nvl2(index_name,'DROP INDEX '||index_name||';',null) drop_sql,
       nvl2(index_name,'CREATE '||case when uniqueness not like 'NO%' then uniqueness else ' ' end||' INDEX '||index_name||' ON "'||table_name||'" ('||listagg(case when column_expression is not null then SYS.SIP_INDEX_EXP_TO_VARCHAR2(owner,index_name,column_position) else '"'||column_name||'"' end,', ') within group (order by column_position)||');',null) create_sql,
       (select count(1) from all_indexes I where I.owner='CUTTER_DDL' and I.table_name=A.table_name and I.index_name=nvl(A.index_name,I.index_name)) cutter_ddl_count,
       nvl2(index_name,null,(select max(owner) from all_indexes I where I.table_name=A.table_name)) other_owner
from (
select T.owner, T.table_name, I.table_type, C.index_name, I.uniqueness, I.index_type, C.column_position, C.column_name, E.column_expression column_expression, C.descend
from all_all_tables T
left join all_indexes I ON I.table_owner=T.owner and I.table_name=T.table_name
left join all_ind_columns C ON C.table_owner=T.owner and C.table_name=T.table_name AND C.index_name=I.index_name
left join all_ind_expressions E ON E.table_owner=T.owner AND E.index_name=C.index_name AND E.column_position=C.column_position
) A
--where owner in ('BO2020','CBO2020','CGK2020','CGP2020','CMA2020','CPV2020','CVITR2020','CWG2020','CWW2020','GK2020','GKG2020')--,'GP2020','GTE2020','GZ2020','MA2020','PV2020','VITR2020','WG2020','WW2020')
--where owner='GP2020' and index_name='WG_D_ZL9' and column_position=1
group by owner, table_name, index_name, uniqueness
order by owner, table_name, index_name;

CREATE OR REPLACE VIEW CUTTER.V_INDEKSY_SQL
AS
select V.owner, V.table_name, V.index_name, V.uniqueness, 
        V.cutter_ddl_count, V.other_owner,
        V.drop_sql, V.create_sql,
       (select listagg(V1.create_sql,chr(10)) within group (order by index_name)
        from cutter.v_indeksy V1
        where V1.owner=case when V.cutter_ddl_count>0 then 'CUTTER_DDL' else V.other_owner end
          and V1.table_name=V.table_name and V1.index_name=nvl(V.index_name,V1.index_name)) create_sql_other
from cutter.v_indeksy V
--where V.owner='MA2020' and V.index_name is null
order by owner,table_name,index_name;

select listagg(''''||owner||'''',',') within group (order by owner) from all_objects where object_name='ZAMOW' and owner like '%2020';

select * from all_ind_expressions where table_owner='GTE2020' and table_name='ZAMOW';

grant select on v_indeksy to CUTTER_DDL;

declare
 vTab VARCHAR2(30):='SL_UWAGI';
 ilRek NUMBER(10);
begin
 for t in (select rownum lp, owner, table_name from all_all_tables where table_name=vTab) loop
  execute immediate 'select count(1) from '||t.owner||'.'||t.table_name into ilRek;
  if ilRek>0 then 
   dbms_output.put_line(t.owner||'.'||t.table_name||' '||ilRek||' recs');
  end if;
 end loop;
end;
/
select * from v_indeksy;

select * from v_indeksy_sql V
where V.owner='WW2020' and V.index_name is null
order by owner,table_name,index_name;

select * from v_indeksy_sql V
where V.owner='MA2020' and V.table_name='SPISS_TMP';

grant execute on dbms_lock to EFF2020NK;