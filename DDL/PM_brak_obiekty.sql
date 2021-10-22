 CREATE OR REPLACE FORCE VIEW "V_STR_SUR1" ("NR_KOM_STR", "NR_SKL", "NR_SKL1", "NR_SKL2", "NR_SKL3", "NR_SKL4", "NR_KAT", "TYP_KAT", "RODZ_SUR", "ZNACZ_PR", "GRUB", "WSP", "IL_WAR", "NR_WAR", "ZN_PP", "KOD_STR") AS 
  select B.nr_kom_str, B.nr_skl, B1.nr_skl nr_skl1, B2.nr_skl nr_skl2, B3.nr_skl nr_skl3, B4.nr_skl nr_skl4,
       nvl(K4.nr_kat,nvl(K3.nr_kat,nvl(K2.nr_kat,nvl(K1.nr_kat,K.nr_kat)))) nr_kat, 
       nvl(K4.typ_kat,nvl(K3.typ_kat,nvl(K2.typ_kat,nvl(K1.typ_kat,K.typ_kat)))) typ_kat,
       nvl(K4.rodz_sur,nvl(K3.rodz_sur,nvl(K2.rodz_sur,nvl(K1.rodz_sur,K.rodz_sur)))) rodz_sur,
       nvl(K4.znacz_pr,nvl(K3.znacz_pr,nvl(K2.znacz_pr,nvl(K1.znacz_pr,K.znacz_pr)))) znacz_pr,
       nvl(K4.grubosc,nvl(K3.grubosc,nvl(K2.grubosc,nvl(K1.grubosc,K.grubosc)))) grub,
       nvl(B4.wsp,nvl(B3.wsp,nvl(B2.wsp,nvl(B1.wsp,B.wsp)))) wsp,
       decode(nvl(K4.rodz_sur,nvl(K3.rodz_sur,nvl(K2.rodz_sur,nvl(K1.rodz_sur,K.rodz_sur)))),'TAF',1,'LIS',1,'TAS',1,0) il_war,
--       decode(B.zn_war,'Pol',(select max(nr_kat) from katalog where rodz_sur='POL'),
--                             nvl(K.nr_kat,nvl(K1.nr_kat,K2.nr_kat))) nr_kat, 
--       decode(B.zn_war,'Pol',S.kod_str,nvl(K.typ_kat,nvl(K1.typ_kat,K2.typ_kat))) typ_kat,
--       decode(B.zn_war,'Pol','POL',nvl(K.rodz_sur,nvl(K1.rodz_sur,K2.rodz_sur))) rodz_sur,
--       decode(B.zn_war,'Pol','0.',nvl(K.znacz_pr,nvl(K1.znacz_pr,K2.znacz_pr))) znacz_pr,
--       decode(B.zn_war,'Pol',S.gr_pak,nvl(K.grubosc,nvl(K1.grubosc,K2.grubosc))) grub,
--       decode(B.zn_war,'Pol',S.il_szk,
--                            decode(nvl(K.rodz_sur,nvl(K1.rodz_sur,K2.rodz_sur)),'TAF',1,'LIS',1,0)) il_war,
       sum(case when B.zn_war='Pol' or K.rodz_sur in ('TAF','LIS','TAS') then 1
                when B1.zn_war='Pol' or K1.rodz_sur in ('TAF','LIS','TAS') then 1
                when B2.zn_war='Pol' or K2.rodz_sur in ('TAF','LIS','TAS') then 1
                when B3.zn_war='Pol' or K3.rodz_sur in ('TAF','LIS','TAS') then 1
                when B4.zn_war='Pol' or K4.rodz_sur in ('TAF','LIS','TAS') then 1
                else 0 end)
        over (partition by B.nr_kom_str order by B.nr_skl, B1.nr_skl, B2.nr_skl, B3.nr_skl, B4.nr_skl) nr_war,

        case when B.zn_war='Pol' then 1
             when B1.zn_war='Pol' then 2
             when B2.zn_war='Pol' then 3
             when B3.zn_war='Pol' then 4
             when B4.zn_war='Pol' then 5
        else 0 end zn_pp,
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
--   left join budstr B4 on B3.zn_war in ('Str','Pol') and B4.nr_kom_str=B3.nr_kom_skl
   left join budstr B4P on B3.zn_war='Pol' and B4P.nr_kom_str=B3.nr_kom_skl
   left join budstr B4 on B3.zn_war<>'Sur' and B4.nr_kom_str=nvl(B4P.nr_kom_skl,B3.nr_kom_skl)
   left join katalog K4 on K4.nr_kat=B4.nr_kom_skl
--   where B.nr_kom_str=:STR and
   where
         (B.zn_war='Sur' and B1.nr_skl is null or
          B.zn_war in ('Str','Pol') and B1.zn_war='Sur' and B2.nr_skl is null or
          B.zn_war in ('Str','Pol') and B1.zn_war in ('Str','Pol') and B2.zn_war='Sur' and B3.nr_skl is null or
          B.zn_war in ('Str','Pol') and B1.zn_war in ('Str','Pol') and B2.zn_war in ('Str','Pol') and B3.zn_war='Sur' and B4.nr_skl is null or
          B.zn_war in ('Str','Pol') and B1.zn_war in ('Str','Pol') and B2.zn_war in ('Str','Pol') and B3.zn_war in ('Str','Pol') and B4.zn_war='Sur')
   order by B.nr_skl, B1.nr_skl, B2.nr_skl, B3.nr_skl, B4.nr_skl;



  CREATE TABLE "BRAK_STR" 
   (	"KOD_STR" VARCHAR2(128 BYTE) DEFAULT ' ' NOT NULL ENABLE, 
	"DATA" DATE DEFAULT to_date('01/1901','MM/YYYY') NOT NULL ENABLE, 
	"CZAS" CHAR(6 BYTE) DEFAULT 000000 NOT NULL ENABLE, 
	"WSK" NUMBER(1,0) DEFAULT 0 NOT NULL ENABLE
   );
  CREATE UNIQUE INDEX "WG_KOD_BRAKI_STR" ON "GTE2021"."BRAK_STR" ("KOD_STR");
  
  insert into param_t values (132,1,'Rodzaj DXFa',' ');
  commit;