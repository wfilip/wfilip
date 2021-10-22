--widok dla metek z CTV w GLASS
CREATE OR REPLACE VIEW "GZ2020"."V_ETYKIETY_PROD" ("NR_KOMP_ZLEC", "NR_POZ", "NR_SZT", "NR_WAR", "F_ZLEC_ORG", "F_POZ_ORG", "F_DATA_SPED", "F_CZYKSZTALT", "F_ATTR28", "F_WYROZNIK") AS 
  select 
    k.nr_komp_zlec,
    k.nr_poz,
    k.NR_SZTUKI nr_szt,
    k.nr_warstwy nr_war,
    case(z.wyroznik) 
      when 'W' then nvl(z1.nr_zlec,'')
      else nvl(z.nr_zlec,'') 
    end f_zlec_org,
    nvl(p.nr_poz_pop,0) f_poz_org,
    to_char(z.d_plan,'DD/MM/YYYY') f_data_sped,
    decode(czy_ksztalt(k.nr_komp_zlec,k.nr_poz,k.nr_sztuki),1,'K',' ') f_czyksztalt  
    ,decode(substr(p.ind_bud,28,1),'1','BEZ ZNAKU',' ') F_ATTR28
    ,decode(z.wyroznik,'B','B',' ') f_wyroznik
from kol_stojakow k
left join spisz p on p.NR_KOM_ZLEC=k.nr_komp_zlec and p.NR_POZ=k.nr_poz
left join zamow z on z.nr_kom_zlec=k.NR_KOMP_ZLEC
left join zamow z1 on z1.nr_kom_zlec=z.nr_komp_poprz
union
  select 
    l.nr_kom_zlec,
    l.nr_poz_zlec,
    l.NR_SZT nr_szt,
    l.nr_warst nr_war,
    nvl(z2.nr_zlec,'') f_zlec_org,
    nvl(l2.NR_POZ_ZLEC,0) f_poz_org,
    to_char(z2.d_plan,'DD/MM/YYYY') f_data_sped,
    decode(czy_ksztalt(l.nr_kom_zlec,l.nr_poz_zlec,l.nr_szt),1,'K',' ') f_czyksztalt
    ,decode(substr(p2.ind_bud,28,1),'1','BEZ ZNAKU',' ') F_ATTR28
    ,decode(z.wyroznik,'B','B',' ') f_wyroznik
from l_wyc l
left join spisz p on p.NR_KOM_ZLEC=l.nr_kom_zlec and p.NR_POZ=l.nr_poz_zlec
left join zamow z on z.nr_kom_zlec=l.NR_KOM_ZLEC
left join l_wyc l2 on l2.ID_REK=l.ID_ORYG
left join zamow z2 on z2.nr_kom_zlec=l2.NR_KOM_ZLEC
left join spisz p2 on p2.NR_KOM_ZLEC=l2.nr_kom_zlec and p2.NR_POZ=l2.nr_poz_zlec
where l.typ_inst in ('A C','R C') and l.WYROZNIK='B' and l.ID_ORYG>0;
