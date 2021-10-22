create or replace view V_OBR_JEDNOCZ
AS 
 select O.nr_k_p_obr nr_obr_jednocz, O.symb_p_obr symb_obr_jednocz,
         G2.nr_komp_obr, O2.symb_p_obr symb_obr, G2.nr_komp_inst
 from slparob O 
 left join gr_inst_dla_obr G1 on G1.nr_komp_obr=O.nr_k_p_obr
 left join gr_inst_dla_obr G2 on G2.nr_komp_inst=G1.nr_komp_inst and G2.nr_komp_obr<>G1.nr_komp_obr
 left join slparob O2 on O2.nr_k_p_obr=G2.nr_komp_obr
 where O.obr_jednocz=1;
/