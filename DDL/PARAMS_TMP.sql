  CREATE GLOBAL TEMPORARY TABLE "PARAMS_TMP" 
   (	"NR_ZEST" NUMBER(6,0), 
	"NR_PAR" NUMBER(4,0), 
	"DATA1" DATE, 
	"DATA2" DATE, 
	"NUM1" NUMBER(10,0), 
	"NUM2" NUMBER(10,0), 
	"NUM3" NUMBER(10,0), 
	"NUM4" NUMBER(10,0), 
	"STR1" VARCHAR2(50 BYTE)
   ) ON COMMIT PRESERVE ROWS ;

   COMMENT ON TABLE "PARAMS_TMP"  IS 'U�ywane zestawy parametr�w: 1-V_PLAN_OPT_SZT (przyg. ci�cia wg planu); 5-V_OBR_WG_DPS_WG_WYR; 10-PIV_DANE(Monitor-MES); 11-MESn 101-RAP_WYK_NA_INST_WG_ZM; 102-V_WYK_POZ_GRUPTOW_';

  CREATE UNIQUE INDEX "PARAMS_TMP_PK" ON "PARAMS_TMP" ("NR_ZEST", "NR_PAR");