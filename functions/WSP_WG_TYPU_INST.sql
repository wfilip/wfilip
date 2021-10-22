create or replace FUNCTION WSP_WG_TYPU_INST (pTYP_INST VARCHAR2, pWSP_12ZAKR NUMBER, pWSP_C_M NUMBER, pWSP_HAR NUMBER, pWSP_HO NUMBER, pWSP_DOD NUMBER, pZNAK_DOD CHAR, pWSP_CENY NUMBER DEFAULT 1)
--/*wa�ne dla HAR - WSP_HO*/ pNK_ZLEC NUMBER DEFAULT 0, pPOZ NUMBER DEFAULT 0, pETAP NUMBER DEFAULT 0, pWAR_OD NUMBER DEFAULT 0, pZT CHAR DEFAULT 'Z') 
RETURN NUMBER AS
 vWsp NUMBER(7,4) :=0;
 vWsp_dla_MON NUMBER(7,4) DEFAULT 1;
BEGIN
 IF pTYP_INST='MON' THEN
  SELECT case when nr_wdr=5 then pWSP_CENY else 1 end
    INTO vWsp_dla_MON
  FROM firma;  
 END IF;
 vWsp :=
  CASE
    WHEN trim(pTYP_INST)='A C' THEN pWSP_12ZAKR*pWSP_C_M*pWSP_DOD
    WHEN trim(pTYP_INST)='SZP' THEN pWSP_12ZAKR*pWSP_C_M
    WHEN trim(pTYP_INST)='HAR' THEN pWSP_12ZAKR*(pWSP_HAR + pWSP_HO)
    WHEN trim(pTYP_INST)='MON' THEN pWSP_12ZAKR*vWsp_dla_MON
    ELSE CASE trim(pZNAK_DOD) WHEN '*' THEN pWSP_12ZAKR*pWSP_DOD WHEN '/' THEN pWSP_12ZAKR/pWSP_DOD WHEN '+' THEN pWSP_12ZAKR+pWSP_DOD WHEN '-' THEN pWSP_12ZAKR-pWSP_DOD ELSE pWSP_12ZAKR END
  END;
 RETURN Round(nvl(vWsp,1),4);
END WSP_WG_TYPU_INST;
/

desc parinst;

create or replace FUNCTION WSP_WG_TYPU_INST2 (pTYP_INST VARCHAR2, pJEDN CHAR, pWSP_12ZAKR NUMBER, pWSP_C_M NUMBER, pWSP_HAR NUMBER, pWSP_HO NUMBER, pWSP_DOD NUMBER, pZNAK_DOD CHAR, pCZAS_DOD CHAR, pWSP_CENY NUMBER DEFAULT 1)
--/*wa�ne dla HAR - WSP_HO*/ pNK_ZLEC NUMBER DEFAULT 0, pPOZ NUMBER DEFAULT 0, pETAP NUMBER DEFAULT 0, pWAR_OD NUMBER DEFAULT 0, pZT CHAR DEFAULT 'Z') 
RETURN NUMBER AS
 vWsp NUMBER(7,4) :=0;
 vWsp_dla_MON NUMBER(7,4) DEFAULT 1;
BEGIN
 IF pTYP_INST='MON' THEN
  SELECT case when nr_wdr=5 then pWSP_CENY else 1 end
    INTO vWsp_dla_MON
  FROM firma;  
 END IF;
 vWsp :=
  CASE
    WHEN trim(pJEDN) in ('h','mi') and trim(translate(pCZAS_DOD,'0',' ')) is not null THEN TIME_TO_MINUTES(pCZAS_DOD)*case when pJEDN='ho' then 60 else 1 end
    WHEN trim(pTYP_INST)='A C' THEN pWSP_12ZAKR*pWSP_C_M*pWSP_DOD
    WHEN trim(pTYP_INST)='SZP' THEN pWSP_12ZAKR*pWSP_C_M
    WHEN trim(pTYP_INST)='HAR' THEN pWSP_12ZAKR*(pWSP_HAR + pWSP_HO)
    WHEN trim(pTYP_INST)='MON' THEN pWSP_12ZAKR*vWsp_dla_MON
    ELSE CASE trim(pZNAK_DOD) WHEN '*' THEN pWSP_12ZAKR*pWSP_DOD WHEN '/' THEN pWSP_12ZAKR/pWSP_DOD WHEN '+' THEN pWSP_12ZAKR+pWSP_DOD WHEN '-' THEN pWSP_12ZAKR-pWSP_DOD ELSE pWSP_12ZAKR END
  END;
 RETURN Round(nvl(vWsp,1),4);
END WSP_WG_TYPU_INST2;
/