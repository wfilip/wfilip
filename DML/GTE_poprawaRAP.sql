begin
  for r in (select * from st_rap_0601 B
            where not exists (select 1 from st_rap A where A.nk_rap=B.nk_rap)
               OR
                EXISTS (select 1 from st_rap_poz_0601 X
                        where X.nk_rap=B.nk_rap 
                          and not exists (select 1 from st_rap_poz P  where P.nk_rap=X.nk_rap and P.nk_st=X.nk_st)
                       )   
           )
   loop
    --delete from st_rap where nk_rap=r.nk_rap;
    --insert into st_rap values r;
    insert into st_rap
     select * from st_rap_0601 B
     where nk_rap=r.nk_rap
       and not exists (select 1 from st_rap A where A.nk_rap=B.nk_rap);
    insert into st_rap_poz 
     select * from st_rap_poz_0601 B
     where nk_rap=r.nk_rap
       and not exists (select 1 from st_rap_poz A where A.nk_rap=B.nk_rap and A.nk_st=B.nk_st);
   end loop;
end;
/