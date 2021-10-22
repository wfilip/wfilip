select nr_kom_zlec, max(Z.nr_zlec) nr_zlec, max(Z.d_pl_sped) dps, max(nullif(S.data_sped,to_date('190101','YYYYMM'))) data_sped,
       max(nullif(S.data_sped,to_date('190101','YYYYMM')))-max(Z.d_pl_sped) opozn
from zamow Z
left join spise E on E.nr_komp_zlec=Z.nr_kom_zlec
left join spedc S on S.nr_sped=E.nr_sped
where E.zn_wyk<>9
group by nr_kom_zlec;