CREATE GLOBAL TEMPORARY TABLE "ZLEC_SORT_TMP" 
( NR_KOM_ZLEC NUMBER(10) DEFAULT 0 NOT NULL,
  SORT NUMBER(6) DEFAULT 0 NOT NULL
) ON COMMIT PRESERVE ROWS;
CREATE UNIQUE INDEX "ZLEC_SORT_TMP_IDX1" ON "ZLEC_SORT_TMP" ("NR_KOM_ZLEC") ;

CREATE OR REPLACE PROCEDURE USTAL_SORT_ZLEC (pMETODA NUMBER, pPARAMS VARCHAR2 default null)
AS
BEGIN
  update zlec_sort_tmp A
  set A.sort = (
    with rws as
       (select S.nr_kom_zlec,-- S.*,
               row_number() over (order by Z.nr_kom_zlec) r0,
               row_number() over (order by Z.priorytet, Z.d_pl_sped, Z.nr_kom_zlec) r1,
               row_number() over (order by Z.priorytet, Z.d_sped_kl, Z.nr_kom_zlec) r2,
               row_number() over (order by Z.priorytet, Z.d_pl_sped, inst_prior, S.nk_zlec_pocz, Z.nr_kom_zlec) r11
        from
        (select S.nr_kom_zlec,
                (select nvl(min(G1.nk_zlec),0) from grup_zlec G, grup_zlec G1 where G.typ_gr=1 and G.nk_zlec=S.nr_kom_zlec and G1.typ_gr=1 and G1.nr_gr=G.nr_gr) nk_zlec_pocz, 
                case when exists (select 1 from l_wyc2 L where L.nr_kom_zlec=S.nr_kom_zlec and L.nr_inst_plan=2)
                     then 1 else null
                  end inst_prior
         from zlec_sort_tmp S) S
        inner join zamow Z on Z.nr_kom_zlec=S.nr_kom_zlec
       ) 
    select decode(pMETODA,1,r1,2,r2,11,r11,r0) from rws where A.nr_kom_zlec = rws.nr_kom_zlec);
END USTAL_SORT_ZLEC;
/

SELECT * from zamow;
select * from vroboczy.elb_listazamp;
insert into zlec_sort_tmp
 select num_kom, 1 from vroboczy.elb_listazamp;

select S.nr_kom_zlec, S.*,
               row_number() over (order by Z.nr_kom_zlec) r0,
               row_number() over (order by Z.priorytet, Z.d_pl_sped, Z.nr_kom_zlec) r1,
               row_number() over (order by Z.priorytet, Z.d_pl_sped, inst_prior, S.nk_zlec_pocz, Z.nr_kom_zlec) r11
        from
        (select S.nr_kom_zlec,
                (select nvl(min(G1.nk_zlec),0) from grup_zlec G, grup_zlec G1 where G.typ_gr=1 and G.nk_zlec=S.nr_kom_zlec and G1.typ_gr=1 and G1.nr_gr=G.nr_gr) nk_zlec_pocz, 
                case when exists (select 1 from l_wyc2 L where L.nr_kom_zlec=S.nr_kom_zlec and L.nr_inst_plan=2)
                     then 1 else null
                  end inst_prior
         from zlec_sort_tmp S) S
        inner join zamow Z on Z.nr_kom_zlec=S.nr_kom_zlec;
        
select * from parinst where ty_inst='MON';