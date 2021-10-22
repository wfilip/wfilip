CREATE OR REPLACE FORCE EDITIONABLE VIEW V_STR_SUR3 AS 
  select B.nr_kom_str, B.nr_skl, B1.nr_skl nr_skl1, B2.nr_skl nr_skl2, B3.nr_skl nr_skl3,
       nvl(B3.zn_war,nvl(B2.zn_war,nvl(B1.zn_war,B.zn_war))) zn_war, 
       nvl(K3.nr_kat,nvl(K2.nr_kat,nvl(K1.nr_kat,K.nr_kat))) nr_kat, 
       nvl(K3.typ_kat,nvl(K2.typ_kat,nvl(K1.typ_kat,K.typ_kat))) typ_kat,
       nvl(K3.rodz_sur,nvl(K2.rodz_sur,nvl(K1.rodz_sur,K.rodz_sur))) rodz_sur,
       nvl(K3.znacz_pr,nvl(K2.znacz_pr,nvl(K1.znacz_pr,K.znacz_pr))) znacz_pr,
       nvl(K3.grubosc,nvl(K2.grubosc,nvl(K1.grubosc,K.grubosc))) grub,
       nvl(B3.wsp,nvl(B2.wsp,nvl(B1.wsp,B.wsp))) wsp,
       nvl(B3.spos_obl,nvl(B2.spos_obl,nvl(B1.spos_obl,B.spos_obl))) spos_obl,
       decode(nvl(K3.rodz_sur,nvl(K2.rodz_sur,nvl(K1.rodz_sur,K.rodz_sur))),'TAF',1,'LIS',1,0) il_war,
      B.kod_str
   from budstr B
   left join katalog K on B.zn_war='Sur' and K.nr_kat=B.nr_kom_skl
   left join struktury S on B.zn_war<>'Sur' and S.nr_kom_str=B.nr_kom_skl
--   left join budstr B1 on B.zn_war in ('Str','Pol') and B1.nr_kom_str=B.nr_kom_skl  
   left join budstr B1P on B.zn_war='Pol' and B1P.nr_kom_str=B.nr_kom_skl
   left join budstr B1 on B.zn_war<>'Sur' and B1.nr_kom_str=nvl(B1P.nr_kom_skl,B.nr_kom_skl) 
   left join katalog K1 on K1.nr_kat=B1.nr_kom_skl
--   left join budstr B2 on B1.zn_war in ('Str','Pol') and B2.nr_kom_str=B1.nr_kom_skl
   left join budstr B2P on B1.zn_war='Pol' and B2P.nr_kom_str=B1.nr_kom_skl
   left join budstr B2 on B1.zn_war<>'Sur' and B2.nr_kom_str=nvl(B2P.nr_kom_skl,B1.nr_kom_skl)
   left join katalog K2 on K2.nr_kat=B2.nr_kom_skl
--   left join budstr B3 on B2.zn_war in ('Str','Pol') and B3.nr_kom_str=B2.nr_kom_skl
   left join budstr B3P on B2.zn_war='Pol' and B3P.nr_kom_str=B2.nr_kom_skl
   left join budstr B3 on B2.zn_war<>'Sur' and B3.nr_kom_str=nvl(B3P.nr_kom_skl,B2.nr_kom_skl)
   left join katalog K3 on K3.nr_kat=B3.nr_kom_skl
   --left join budstr B4P on B3.zn_war='Pol' and B4P.nr_kom_str=B3.nr_kom_skl
   --left join budstr B4 on B3.zn_war<>'Sur' and B4.nr_kom_str=nvl(B4P.nr_kom_skl,B3.nr_kom_skl)
   --left join katalog K4 on K4.nr_kat=B4.nr_kom_skl
--   where B.nr_kom_str=:STR and
   where nvl(B3.zn_war,nvl(B2.zn_war,nvl(B1.zn_war,B.zn_war)))='Sur'
--         B.zn_war='Sur' and B1.nr_skl is null or
--         B.zn_war in ('Str','Pol') and B1.zn_war='Sur' and B2.nr_skl is null or
--         B.zn_war in ('Str','Pol') and B1.zn_war in ('Str','Pol') and B2.zn_war='Sur' and B3.nr_skl is null or
--         B.zn_war in ('Str','Pol') and B1.zn_war in ('Str','Pol') and B2.zn_war in ('Str','Pol') and B3.zn_war='Sur'
   order by B.nr_skl, B1.nr_skl, B2.nr_skl, B3.nr_skl;
