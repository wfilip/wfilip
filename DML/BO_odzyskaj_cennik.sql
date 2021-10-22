--kopiowanie cennika z bazy oddziaowej do centralnej (nadpisywanie)
define NK_CENNIKA=1177;
define OPER_MOD=25;
define NR_ODDZ=1;
delete from cbo2018.ccen00_t6 where nk_cennika=&NK_CENNIKA;
insert into cbo2018.ccen00_t6 select * from cen00_t6 where nk_cennika=&NK_CENNIKA;
delete from cbo2018.ccen01_t6 where nk_cennika=&NK_CENNIKA;
insert into cbo2018.ccen01_t6 select * from cen01_t6 where nk_cennika=&NK_CENNIKA;
delete from cbo2018.ccen02_t6 where nk_cennika=&NK_CENNIKA;
insert into cbo2018.ccen02_t6 (nk_cennika, typ, nr_kat, doplata, nr_szyby, data_mod, czas_mod, operator, odd, wsk_zera) 
  select nk_cennika, typ, nr_kat, doplata, nr_szyby, trunc(sysdate), '000000', &OPER_MOD, &NR_ODDZ, wsk_zera from cen02_t6 where nk_cennika=&NK_CENNIKA;
delete from cbo2018.ccen03_t6 where nk_cennika=&NK_CENNIKA;
insert into cbo2018.ccen03_t6 (nk_cennika,indeks_szprosu,naz_szprosu,szer_szp,cena_podst,data_mod,czas_mod,operator,odd) 
  select nk_cennika,indeks_szp,nazwa_szp,szer_szp,cena_pod,trunc(sysdate), '000000', &OPER_MOD, &NR_ODDZ from cen03_t6 where nk_cennika=&NK_CENNIKA;
delete from cbo2018.ccen05_t6 where nkomp_cen=&NK_CENNIKA;
insert into cbo2018.ccen05_t6 select * from cen05_t6 where nkomp_cen=&NK_CENNIKA;
delete from cbo2018.ccen06_t6 where nkomp_cen=&NK_CENNIKA;
insert into cbo2018.ccen06_t6 select * from cen06_t6 where nkomp_cen=&NK_CENNIKA;

--select * from cbo2018.ccen06_t6 where nk_cennika=&NK_CENNIKA;
--select * from bo2018.cen06_t6 where nkomp_cen=&NK_CENNIKA;

--select listagg(column_name,',') within group (order by column_id) from all_tab_columns where owner='CBO2018' and table_name='CCEN03_T6';
