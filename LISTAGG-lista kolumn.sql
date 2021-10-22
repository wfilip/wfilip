select listagg(lower(column_name),', ') within group (order by column_id) from user_tab_columns where table_name=:TABELA;
