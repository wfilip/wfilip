CREATE OR REPLACE FORCE VIEW "V_ZLECENIA_WEW_POZYCJE" ("NR_KOMP_ZLEC", "NR_POZ", "NR_WAR", "NR_KOMP_ZLEC_ORG", "NR_POZ_ORG", "NR_WAR_ORG") AS 
  select 
  zt.nr_komp_zlec,
  zt.nr_poz,
  1 nr_war, 
  zw.NR_KOMP_POPRZ nr_komp_zlec_org,
  pw.NR_POZ_POP nr_poz_org,
  to_number(LINIA,'99') nr_war_org 
from zamow zw
  left join zlec_typ zt on zw.nr_kom_zlec=zt.nr_komp_zlec
  left join spisz pw on pw.nr_kom_zlec=zt.nr_komp_zlec and pw.nr_poz=zt.nr_poz
where zw.wyroznik='W' and zw.status<>'A' and typ=202; 