select  sql_id, sql_text, count(*) as "OPEN CURSORS", user_name
   from v$open_cursor
  where user_name <>'SYS' 
group by sql_id, sql_text, user_name 
order by count(*) desc;