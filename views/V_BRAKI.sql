CREATE OR REPLACE VIEW V_BRAKI AS
select bb.nr_kol lp, bb.d_rejestr, bb.c_rejestr, bb.oper, bb.data, bb.zm, zb.NR_ZLEC zlec_brak, zb.data_zl data_zlec_brak, zz.NR_KON, kl.skrot_k, zz.NR_ZLEC, zz.NR_ZLEC_KLI, bb.NR_POZ, bb.NR_SZT, bb.NR_WAR, 
bb.KOD_STR, pz.szer, pz.wys, pz.pow, bb.KOD_P, (select min(rs.NAPIS) from rekslo2 rs where bb.KOD_P=rs.KOD and rs.typ_zap=1) opis_p, pi.NR_INST, trim(pi.NAZ_INST) NAZ_INST
from braki_b bb
left join zamow zb on zb.nr_kom_zlec=bb.zlec_braki
left join zamow zz on zz.nr_kom_zlec=bb.NR_ZLEC
left join spisz pz on pz.nr_kom_zlec=bb.NR_ZLEC and pz.nr_poz=bb.nr_poz
left join parinst pi on pi.NR_KOMP_INST=bb.NR_KOM_INST
--left join rekslo2 rs on bb.KOD_P=rs.KOD and rs.typ_zap=1
join klient kl on zz.NR_KON=kl.nr_kon
order by bb.nr_kol desc;

GRANT SELECT ON V_BRAKI TO RAPORTY;

CREATE OR REPLACE VIEW V_BRAKI_TAF AS
select bb.nr_kol lp, bb.d_rejestr, bb.c_rejestr, bb.oper, bb.data, bb.zm, zb.NR_ZLEC zlec_brak, zb.data_zl data_zlec_brak, zz.NR_KON, kl.skrot_k, zz.NR_ZLEC, zz.NR_ZLEC_KLI,
cr.NR_POZ, cr.NR_SZT, bb.NR_WAR, bb.KOD_STR, cr.NR_WAR_BR,
case when exists (select 1 from l_wyc2 l2 where sz.nr_kom_zlec=l2.nr_kom_zlec and sz.nr_poz=l2.NR_POZ_ZLEC and cr.NR_SZT=l2.NR_SZT and l2.NR_INST_PLAN in (6,16)
and (cr.NR_WAR between l2.NR_WARST and l2.WAR_DO)) then 'TAK' else ' ' end as FL_OGN, cr.TYP_KAT, kg.NAZ_KAT, cr.szer, cr.wys, round(cr.szer*cr.wys*0.000001,4) POW,
1 IL_SZT, case when (sz.NR_KSZT<>0 or sz.NR_KOMP_RYS<>0) then 'TAK' else ' ' end as ksztalt, bb.KOD_P,
(select min(rs.NAPIS) from rekslo2 rs where bb.KOD_P=rs.KOD and rs.typ_zap=1) opis_p, pi.NR_INST, trim(pi.NAZ_INST) NAZ_INST
from CR_DATA cr
left join braki_b bb on cr.ID_BR=bb.NR_KOL
left join zamow zb on zb.nr_kom_zlec=bb.zlec_braki
left join zamow zz on zz.nr_kom_zlec=bb.NR_ZLEC
left join spisz sz on sz.nr_kom_zlec=bb.NR_ZLEC and bb.NR_POZ=sz.NR_POZ
left join parinst pi on pi.NR_KOMP_INST=bb.NR_KOM_INST
--left join rekslo2 rs on bb.KOD_P=rs.KOD and rs.typ_zap=1
join klient kl on zz.NR_KON=kl.nr_kon
join katalog kg on cr.TYP_KAT=kg.TYP_KAT and kg.RODZ_SUR='TAF'
order by bb.nr_kol desc, cr.NR_WAR_BR;

GRANT SELECT ON V_BRAKI_TAF TO RAPORTY;