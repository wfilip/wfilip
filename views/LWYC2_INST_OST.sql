CREATE OR REPLACE FORCE VIEW LWYC2_INST_OST
AS
SELECT  L.*, I.ty_inst, I.naz_inst, I.czas_poprocesowy, to_char(PKG_CZAS.GODZ_KONC_ZM(L.nr_inst_plan,L.nr_zm_plan,0),'DD/MM/YYYY HH24:MI:SS') godz_sped,
        SPE.nr_komp_inst nk_inst_SPE, 
        (select nvl(min(nr_komp_zm),0) from zmiany Z
         where Z.nr_komp_inst=SPE.nr_komp_inst and Z.dl_zmiany>0 and Z.nr_komp_zm>L.nr_zm_plan and L.nr_zm_plan>0
           and PKG_CZAS.GODZ_POCZ_ZM(Z.nr_komp_inst,Z.nr_komp_zm)+Z.dl_zmiany/24>PKG_CZAS.GODZ_KONC_ZM(L.nr_inst_plan,L.nr_zm_plan,1)
        )   nr_zm_sped_min
FROM
(select nr_kom_zlec, nr_inst_plan, max(nr_zm_plan) nr_zm_plan, PKG_CZAS.NR_ZM_TO_DATE(max(nr_zm_plan)) data_plan, PKG_CZAS.NR_ZM_TO_ZM(max(nr_zm_plan)) zm_plan
 from l_wyc2 L
 where not exists (select 1 from l_wyc2 L2 where L2.nr_kom_zlec=L.nr_kom_zlec and L2.nr_poz_zlec=L.nr_poz_zlec and L2.nr_szt=L.nr_szt and L2.kolejn>L.kolejn)
 group by nr_kom_zlec, nr_inst_plan
) L
JOIN parinst I ON I.nr_komp_inst=L.nr_inst_plan
LEFT JOIN parinst SPE ON SPE.ty_inst='SPE';
