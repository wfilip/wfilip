select listagg(lower(column_name),', ') within group (order by column_id) from user_tab_columns where table_name=:TABELA;

select listagg('sum('||lower(column_name)||') '||lower(column_name),', ') within group (order by column_id) from user_tab_columns where table_name=:TABELA and column_id>=7;

select listagg('nvl(Z1.'||lower(column_name)||',0)+nvl(Z2.'||lower(column_name)||',0)+nvl(Z3.'||lower(column_name)||',0)+nvl(Z4.'||lower(column_name)||',0) '||lower(column_name),', ')
        within group (order by column_id)
from user_tab_columns where table_name=:TABELA and column_id>=5;
