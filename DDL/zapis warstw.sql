--224,225.sql 
ALTER TABLE SLPAROB ADD
 ("OBR_LACZ" NUMBER(1) DEFAULT 0 NOT NULL,
	"KOLEJN_OBR" NUMBER(2) DEFAULT 0 NOT NULL,
	"STRONA" NUMBER(1) DEFAULT 2 NOT NULL,
	"OBR_TECH" NUMBER(1) DEFAULT 0 NOT NULL,
	"AKT" NUMBER(1) DEFAULT 0 NOT NULL
 );
 
CREATE TABLE "GR_INST_DLA_OBR" 
   ("NR_KOMP_GR" NUMBER(10,0) NOT NULL ENABLE, 
	"NR_KOMP_OBR" NUMBER(10,0) NOT NULL ENABLE, 
	"NR_KOMP_INST" NUMBER(10,0) NOT NULL ENABLE, 
	"KOLEJNOSC" NUMBER(5,0) NOT NULL ENABLE, 
	"AKT" NUMBER(1,0) NOT NULL ENABLE
   );
CREATE UNIQUE INDEX "WG_NRGR890" ON "GR_INST_DLA_OBR" ("NR_KOMP_GR", "NR_KOMP_OBR", "NR_KOMP_INST");
CREATE UNIQUE INDEX "WG_NROBR890" ON "GR_INST_DLA_OBR" ("NR_KOMP_OBR", "NR_KOMP_INST", "NR_KOMP_GR");

ALTER TABLE parinst ADD (MAX_GRUB_PAK NUMBER(6,3),
                         MAX_WAGA_PAK NUMBER(10,3),
                         MAX_WAGA_1MB NUMBER(10,3),
                         MAX_WAGA_EL NUMBER(10,3));

UPDATE parinst SET MAX_GRUB_PAK=nvl(MAX_GRUB_PAK,0), MAX_WAGA_PAK=nvl(MAX_WAGA_PAK,0), MAX_WAGA_1MB=nvl(MAX_WAGA_1MB,0), MAX_WAGA_EL=nvl(MAX_WAGA_EL,0);
ALTER TABLE parinst MODIFY (MAX_GRUB_PAK NUMBER(6,3) DEFAULT 0 NOT NULL,
                            MAX_WAGA_PAK NUMBER(10,3) DEFAULT 0 NOT NULL,
                            MAX_WAGA_1MB NUMBER(10,3) DEFAULT 0 NOT NULL,
                            MAX_WAGA_EL NUMBER(10,3) DEFAULT 0 NOT NULL);
/*
ALTER TABLE pinst_dod ADD(znak VARCHAR2(1) DEFAULT '*' NOT NULL,
                          szer_max NUMBER(4) DEFAULT 0 NOT NULL,
                          wys_max  NUMBER(4) DEFAULT 0 NOT NULL,
                          waga_max NUMBER(8,1) DEFAULT 0 NOT NULL,
                          nr_komp_obr NUMBER(4) DEFAULT 0 NOT NULL);
*/
CREATE TABLE "PINST_DODN" 
   (	"NR_KOMP_INST" NUMBER(10,0) NOT NULL ENABLE, 
	"TYP_KAT" VARCHAR2(9 BYTE) NOT NULL ENABLE, 
	"GRUB_OD" NUMBER(6,3) NOT NULL ENABLE, 
	"GRUB_DO" NUMBER(6,3) NOT NULL ENABLE, 
	"WSP_PRZEL" NUMBER(7,4) NOT NULL ENABLE, 
	"CZAS_JEDN_OBR" CHAR(6 BYTE) NOT NULL ENABLE, 
	"ZNAK" VARCHAR2(1 BYTE) NOT NULL ENABLE, 
	"SZER_MAX" NUMBER(4,0) NOT NULL ENABLE, 
	"WYS_MAX" NUMBER(4,0) NOT NULL ENABLE, 
	"WAGA_MAX" NUMBER(10,3) NOT NULL ENABLE, 
	"NR_KOMP_OBR" NUMBER(10,0) DEFAULT 0
   );
CREATE UNIQUE INDEX "WG_INST_PL100" ON "PINST_DODN" ("NR_KOMP_INST", "TYP_KAT", "GRUB_OD", "NR_KOMP_OBR");
INSERT INTO PINST_DODN (nr_komp_inst, typ_kat, grub_od, grub_do, wsp_przel, czas_jedn_obr)  select nr_komp_inst, typ_kat, grub_od, grub_do, wsp_przel, czas_jedn_obr from pinst_dod;


create or replace view wspinst2 (nr_komp_inst, nr_znacznika, zn_prod, nr_zakr, zakres_od, zakres_do, znak_op, wsp_przel, nr_zest)
as 
 select nr_komp_inst, nr_znacznika, zn_prod, nr_zakr,
        decode(nr_zakr,1,zakr_1_min,2,zakr_2_min,3,zakr_3_min,4,zakr_4_min,0) zakres_od,
        decode(nr_zakr,1,zakr_1_max,2,zakr_2_max,3,zakr_3_max,4,zakr_4_max,0) zakres_do,
        decode(nr_zakr,1,znak_op1,2,znak_op2,3,znak_op3,4,znak_op4,'*') znak,
        decode(nr_zakr,1,wsp_przel1,2,wsp_przel2,3,wsp_przel3,4,wsp_przel4,'*') wsp, 0
 from parinst
 left join wspinst using (nr_komp_inst)
 left join (select 1 nr_zakr from dual union select 2 from dual union select 3 from dual union  select 4 from dual) on 1=1
 where nr_komp_inst>0;
/

CREATE TABLE "TECH_KONTR" 
("NR_KOMP_ZAP" NUMBER(10,0)  DEFAULT 0 NOT NULL, 
	"NR_KOMP_ZLEC" NUMBER(10,0)  DEFAULT 0 NOT NULL, 
	"RODZ" NUMBER(2,0)  DEFAULT 0 NOT NULL, 
	"D_ZAP" DATE  DEFAULT to_date('011901','MMYYYY') NOT NULL, 
	"T_ZAP" CHAR(6 BYTE)  DEFAULT '000000' NOT NULL, 
	"NR_OP_ZAP" VARCHAR2(10 BYTE)  DEFAULT ' ' NOT NULL, 
	"OBSL" NUMBER(2,0)  DEFAULT 0 NOT NULL, 
	"D_DEC" DATE  DEFAULT to_date('011901','MMYYYY') NOT NULL, 
	"T_DEC" CHAR(6 BYTE)  DEFAULT '000000' NOT NULL, 
	"NR_OPER" VARCHAR2(10 BYTE)  DEFAULT ' ' NOT NULL
   );

CREATE UNIQUE INDEX "WG_NRZL_M483" ON "TECH_KONTR" ("NR_KOMP_ZLEC", "NR_KOMP_ZAP") ;
  
  
 CREATE TABLE "TECH_KONTR_POZ" 
 ("NR_KOMP_ZAP" NUMBER(10,0) DEFAULT 0 NOT NULL,
	"NR_KOMP_ZLEC" NUMBER(10,0) DEFAULT 0 NOT NULL,
	"ID_REK" NUMBER(10,0) DEFAULT 0 NOT NULL,
	"NR_KOLEJNY" NUMBER(10,0) DEFAULT 0 NOT NULL ENABLE,
	"NR_POZ" NUMBER(3,0) DEFAULT 0 NOT NULL ENABLE,
	"KTORE_PRZEKR" VARCHAR2(20) DEFAULT ' ' NOT NULL ENABLE,
	"TEKST" VARCHAR2(500 BYTE) DEFAULT ' ' NOT NULL,
	"NR_KOMP_INSTAL" NUMBER(10,0) DEFAULT 0 NOT NULL ENABLE,
	"NR_OBR" NUMBER(3,0) DEFAULT 0 NOT NULL,
	"OBSL" NUMBER(2,0) DEFAULT 0 NOT NULL,
	"D_DEC" DATE DEFAULT to_date('011901','MMYYYY') NOT NULL ENABLE,
	"T_DEC" CHAR(6 BYTE) DEFAULT '000000' NOT NULL,
	"NR_OPER" VARCHAR2(10 BYTE) DEFAULT ' ' NOT NULL ENABLE
   ) ;

  CREATE UNIQUE INDEX "WG_NR_ZLEC_M484" ON "TECH_KONTR_POZ" ("NR_KOMP_ZAP","NR_KOMP_ZLEC", "ID_REK", "NR_KOLEJNY", "NR_KOMP_INSTAL");
  
CREATE OR REPLACE FUNCTION ATRYB_MATCH 
(
  pIDENT1 IN VARCHAR2 
, pIDENT2 IN VARCHAR2 
) RETURN NUMBER AS 
 Nr NUMBER:=0;
BEGIN
  IF least(instr(pIDENT1,'1'),instr(pIDENT2,'1'))=0 THEN
   RETURN 0;
  END IF; 
  LOOP
    EXIT WHEN Nr>=nvl(greatest(length(pIDENT1),length(pIDENT1)),0);
    Nr:=Nr+1;
    IF substr(pIDENT1,Nr,1)='1' and substr(pIDENT2,Nr,1)='1' THEN 
     RETURN 1;
    END IF; 
  END LOOP;
  RETURN 0;
END ATRYB_MATCH;
/

create or replace FUNCTION ATRYB_SUM (pIDENT1 VARCHAR2, pIDENT2 VARCHAR2, pIDENT3 VARCHAR2 DEFAULT '0', pIDENT4 VARCHAR2 DEFAULT '0') RETURN VARCHAR2
AS
 vRet VARCHAR2(100):=' ';
 vDlugosc NUMBER(3):=100;
 Nr NUMBER(3):=0;
BEGIN
 vDlugosc:=greatest(length(pIDENT1),length(pIDENT2),length(pIDENT3),length(pIDENT4));
 --dobrze dziala przy '1' maks na 40ej pozycji
 IF vDlugosc<=40 THEN 
  SELECT rpad(translate(reverse(to_char(sum(reverse(rpad(ident_bud,100,'0'))))),'23456789','11111111'),vDlugosc,'0')
  --SELECT translate(reverse(to_char(sum(reverse(rpad(ident_bud,100,'0'))),rpad('0',least(63,vDlugosc),'9'))),'23456789','11111111')
    INTO vRet
  FROM 
  (select pIDENT1 ident_bud from dual union 
   select pIDENT2 from dual union
   select pIDENT3 from dual union
   select pIDENT4 from dual);
  RETURN vRet; 
 ELSE
   LOOP
    EXIT WHEN Nr>=vDlugosc;
    Nr:=Nr+1;
    IF substr(pIDENT1,Nr,1)='1' or substr(pIDENT2,Nr,1)='1' or substr(pIDENT3,Nr,1)='1' or substr(pIDENT4,Nr,1)='1' THEN
     vRet:=vRet||'1';
    ELSE
     vRet:=vRet||'0';
    END IF; 
   END LOOP;
  RETURN trim(vRet);
 END IF; 
EXCEPTION WHEN OTHERS THEN
 RETURN '0';
END ATRYB_SUM;
/

CREATE TABLE "WSP_ALTER" 
(	"NR_KOMP_INST" NUMBER(10,0) DEFAULT 0 NOT NULL,
	"NR_KOM_ZLEC" NUMBER(10,0) DEFAULT 0 NOT NULL,
	"NR_POZ" NUMBER(3,0) DEFAULT 0 NOT NULL,
	"WSP_ALT" NUMBER(7,4) DEFAULT 0 NOT NULL,
	"JAKI" NUMBER(1,0) DEFAULT 0, 
	"NR_PORZ_OBR" NUMBER(4,0) DEFAULT 0 NOT NULL,
	"NR_ZESTAWU" NUMBER(1,0) DEFAULT 0 NOT NULL ENABLE
);
CREATE UNIQUE INDEX "WG_M476" ON "WSP_ALTER" ("NR_KOM_ZLEC", "NR_KOMP_INST", "NR_POZ", "NR_PORZ_OBR", "NR_ZESTAWU");
CREATE UNIQUE INDEX "WG_NR_ZEST_WSPALTER" ON "WSP_ALTER" ("NR_ZESTAWU", "NR_KOM_ZLEC", "NR_POZ", "NR_PORZ_OBR", "NR_KOMP_INST");

ALTER TABLE l_wyc ADD ("NRY_PORZ" VARCHAR2(30 BYTE) DEFAULT null);

CREATE OR REPLACE TRIGGER LWYC_IDREK
BEFORE INSERT ON L_WYC
REFERENCING NEW AS NEW
FOR EACH ROW
WHEN (NEW.ID_REK=0)
BEGIN
 :NEW.ID_REK:=lwyc_seq.nextval;
END;
/

alter table  log_zm RENAME to log_zm_old;
CREATE TABLE "LOG_ZM" 
(	"TAB" VARCHAR2(50 BYTE) DEFAULT ' ' NOT NULL ENABLE, 
	"NR_KOMP" NUMBER(10,0) DEFAULT 0 NOT NULL ENABLE, 
	"FL_OP" CHAR(1 BYTE) DEFAULT ' ' NOT NULL ENABLE, 
	"DATA" DATE DEFAULT to_date('01-1901','MM-YYYY') NOT NULL ENABLE, 
	"CZAS" CHAR(6 BYTE) DEFAULT '000000' NOT NULL ENABLE, 
	"DO_SYNCH" NUMBER(10,0) DEFAULT 1 NOT NULL ENABLE, 
	"OS_USER" VARCHAR2(30),
	"SID" NUMBER(10,0)
   );
CREATE INDEX "WG_SYNCH_LOG_ZM" ON "LOG_ZM" ("DO_SYNCH", "TAB", "DATA", "CZAS");
CREATE OR REPLACE  TRIGGER LOG_ZM_INS
BEFORE INSERT ON LOG_ZM
REFERENCING NEW AS NEW
FOR EACH ROW
BEGIN
 :NEW.DATA:=trunc(sysdate);
 :NEW.CZAS:=to_char(sysdate,'HH24MISS');
 :NEW.OS_USER:=sys_context('USERENV','OS_USER');
 :NEW.SID:=sys_context('USERENV','SESSIONID');
END;
/

create or replace PROCEDURE ZAPISZ_LOG(pTab VARCHAR2, pNr_komp_dok NUMBER, pFl_op CHAR, pDO_SYNCH NUMBER DEFAULT 0) AS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  INSERT INTO log_zm (tab, nr_komp, fl_op, do_synch)
               VALUES (substr(pTab,1,30), pNr_komp_dok, pFl_op, pDO_SYNCH);
  COMMIT;
END ZAPISZ_LOG;
/


CREATE TABLE "ERRORS" 
(	"SID" NUMBER(10,0) DEFAULT userenv('SESSIONID'), 
	"MESSAGE" VARCHAR2(500 BYTE) DEFAULT ' ', 
	"DATA" DATE DEFAULT sysdate, 
	"CZAS" CHAR(6 BYTE) DEFAULT to_char(sysdate,'HH24MISS')
);
CREATE INDEX "WG_DATETIME_ERRORS" ON "ERRORS" ("DATA" DESC, "CZAS" DESC, "SID");
create or replace procedure ZAPISZ_ERR(pMESSAGE VARCHAR2) as
  PRAGMA AUTONOMOUS_TRANSACTION;
begin
  insert into errors (message) values (substr(pMESSAGE,1,500));
  commit;
end;
/

create or replace FUNCTION "REP_STR" (STR1 IN VARCHAR2, STR_NEW IN VARCHAR2, POS_FROM IN NUMBER) 
RETURN VARCHAR2 AS 
BEGIN
  --zastepuje w STR1 fragment od znaku nr POS_FROM ci�giem STR_NEW
  RETURN substr(STR1,1,POS_FROM-1)||STR_NEW||substr(STR1,POS_FROM+length(STR_NEW),length(STR1)-(POS_FROM-1)-length(STR_NEW));
END REP_STR;
/