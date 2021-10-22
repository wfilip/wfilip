CREATE TABLE GRUP_ZLEC
 (TYP_GR NUMBER(2) DEFAULT 0 NOT NULL,
  NR_GR  NUMBER(10) DEFAULT 0 NOT NULL,
  NK_ZLEC  NUMBER(10) DEFAULT 0 NOT NULL, 
  NR_KOL  NUMBER(5) DEFAULT 0 NOT NULL,
  DANE_DOD VARCHAR2(50) NULL);
--ALTER TABLE grup_zlec RENAME COLUMN opis to dane_dod;
--ALTER TABLE grup_zlec MODIFY dane_dod VARCHAR2(50);  
CREATE UNIQUE INDEX GRUP_ZLEC_IDX1 ON GRUP_ZLEC (typ_gr, nr_gr, nr_kol, nk_zlec);
CREATE UNIQUE INDEX GRUP_ZLEC_IDX2 ON GRUP_ZLEC (nk_zlec, typ_gr, nr_gr);
COMMENT ON TABLE GRUP_ZLEC IS 'Tabela grupowania zleceñ. Ró¿ne typy grupowania wg kol. TYP_GR';
COMMENT ON COLUMN GRUP_ZLEC.TYP_GR IS '1-grupowanie zleceñ utworzonych przez Podzia³   2-zestawy zleceñ';

CREATE SEQUENCE GRUP_ZLEC_SEQ INCREMENT BY 1 START WITH 1 MAXVALUE 9999999999 MINVALUE 1 CYCLE NOCACHE;

CREATE OR REPLACE TRIGGER GRUP_ZLEC_TR 
BEFORE INSERT ON GRUP_ZLEC 
FOR EACH ROW 
WHEN (NEW.NR_GR=0 AND NEW.NK_ZLEC>0) 
BEGIN
 :NEW.NR_GR := GRUP_ZLEC_SEQ.nextval;
END;
/

CREATE OR REPLACE VIEW GRUP_ZLEC_VIEW 
 AS
  select typ_gr, nr_gr, nr_kol, nk_zlec, dane_dod,
         rank() over (partition by typ_gr, nr_gr order by nr_kol, nk_zlec) cz,
         count(1) over (partition by typ_gr, nr_gr) max_cz,
         to_char(rank() over (partition by typ_gr, nr_gr order by nr_kol, nk_zlec))||'/'||to_char(count(1) over (partition by typ_gr, nr_gr)) il_cz,
         --case when instr(trim(dane_dod),'|') between 1 and 4 then strtokenn(trim(dane_dod),1,'|','99999') else 1 end kolor,
         max(case when instr(trim(dane_dod),'|') between 1 and 4 then strtokenn(trim(dane_dod),1,'|','99999') else 1 end) over (partition by typ_gr, nr_gr) kolor,
         to_char(nr_gr)||':'
         ||to_char(nr_kol)||':'
         ||to_char(rank() over (partition by typ_gr, nr_gr order by nr_kol, nk_zlec))||'/'
         ||to_char(count(1) over (partition by typ_gr, nr_gr))
         ||':'||trim(dane_dod) dane
  from grup_zlec G;
  
  
 select * from grup_zlec_view; 
