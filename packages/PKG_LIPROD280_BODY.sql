  CREATE OR REPLACE PACKAGE BODY "PKG_LIPROD280" AS

function BCD (pNrKompSzyby number) RETURN VARCHAR2 
as
  vResult varchar2(1000);
  vBARCODE number(24);
  vSep char;
begin
  vResult := ' ';
  vSep := ' ';

  vBARCODE := pNrKompSzyby;

  vResult := '<BCD> '||
    Rpad(vBARCODE,24);

return vResult;
end BCD;

FUNCTION BEA (pNrKompZlec number, pNrPoz number, pNrElem number) RETURN VARCHAR2 
as
  cursor c1 is  
    select * from v_zlec_mon vzm WHERE vzm.nr_kom_zlec=pNrKompZlec and vzm.nr_poz=pNrPoz and vzm.nr_el_wew=pNrElem;
  vzm v_zlec_mon%rowtype;

  vResult varchar2(1000);

  cf number;
  c number;
  i number;
  vStep number;

  vINDEX number(3):=0;
  vSHEET_INX number(1):=0;
  vFACESIDE number(1):=0;
  vDESCRIPT varchar2(40):=' ';
  vTYPE number(2):=0;
  vEDGE1 number(1):=0;
  vEDGE2 number(1):=0;
  vEDGE3 number(1):=0;
  vEDGE4 number(1):=0;
  vEDGE5 number(1):=0;
  vEDGE6 number(1):=0;
  vEDGE7 number(1):=0;
  vEDGE8 number(1):=0;
  vCORNER1 number(1):=0;
  vCORNER2 number(1):=0;
  vCORNER3 number(1):=0;
  vCORNER4 number(1):=0;
  vCORNER5 number(1):=0;
  vCORNER6 number(1):=0;
  vCORNER7 number(1):=0;
  vCORNER8 number(1):=0;
  vCORNER9 number(1):=0;
  vCORNER10 number(1):=0;
  vCORNER11 number(1):=0;
  vCORNER12 number(1):=0;
  vCORNER13 number(1):=0;
  vCORNER14 number(1):=0;
  vCORNER15 number(1):=0;
  vCORNER16 number(1):=0;
  vXCOORD number(5):=0;
  vYCOORD number(5):=0;
  vRADIUS number(5):=0;
  vWIDTH number(5):=0;
  vHEIGHT number(5):=0;

  vSep char;
  vSep2 char;
begin
  vResult := '';
  vSep := ' ';
  vSep2 := Chr(9);
  cf := 0;
  c := 0;
  i := 0;

-- Pobierz dane z widoku v_zlec_mon
  OPEN c1;
  LOOP
    FETCH c1 INTO vzm;
    EXIT WHEN c1%NOTFOUND; 

-- gdy warstwa ramki
    if pNrElem mod 2 = 0 then
      cf := floor(pNrElem/2);

      for i in 1..4 loop
        if i=1 then vStep := vzm.stepD;
        elsif i=2 then vStep := vzm.stepP;
        elsif i=3 then vStep := vzm.stepG;
        elsif i=4 then vStep := vzm.stepL;
        end if;
        if vStep>0 then
          vINDEX:=0;
          vSHEET_INX:=0;
          vFACESIDE:=0;
          vDESCRIPT:=' ';
          vTYPE:=0;
          vEDGE1:=0;
          vEDGE2:=0;
          vEDGE3:=0;
          vEDGE4:=0;
          vEDGE5:=0;
          vEDGE6:=0;
          vEDGE7:=0;
          vEDGE8:=0;
          vCORNER1:=0;
          vCORNER2:=0;
          vCORNER3:=0;
          vCORNER4:=0;
          vCORNER5:=0;
          vCORNER6:=0;
          vCORNER7:=0;
          vCORNER8:=0;
          vCORNER9:=0;
          vCORNER10:=0;
          vCORNER11:=0;
          vCORNER12:=0;
          vCORNER13:=0;
          vCORNER14:=0;
          vCORNER15:=0;
          vCORNER16:=0;
          vXCOORD:=0;
          vYCOORD:=0;
          vRADIUS:=0;
          vWIDTH:=0;
          vHEIGHT:=0;


          c := c+1;
          vINDEX := c;
          vSHEET_INX := cf;
          vTYPE := 6;
          if i=1 then 
            vEDGE1 := 1;
            vDESCRIPT := 'Pomniejszenie ramki D';
          elsif i=2 then 
            vEDGE2 := 1;
            vDESCRIPT := 'Pomniejszenie ramki P';
          elsif i=3 then 
            vEDGE3 := 1;
            vDESCRIPT := 'Pomniejszenie ramki G';
          elsif i=4 then 
            vEDGE4 := 1;
            vDESCRIPT := 'Pomniejszenie ramki L';
          end if; 
          vWIDTH := vStep+vzm.uszcz_std;

          vResult := vResult||'<BEA> '||
            LPad(vINDEX,3,'0')||vSep||
            vSHEET_INX||vSep||
            vFACESIDE||vSep||
            RPad(vDESCRIPT,40)||vSep||
            LPad(vTYPE,2,'0')||vSep||
            vEDGE1||vSep||
            vEDGE2||vSep||
            vEDGE3||vSep||
            vEDGE4||vSep||
            vEDGE5||vSep||
            vEDGE6||vSep||
            vEDGE7||vSep||
            vEDGE8||vSep||
            vCORNER1||vSep||
            vCORNER2||vSep||
            vCORNER3||vSep||
            vCORNER4||vSep||
            vCORNER5||vSep||
            vCORNER6||vSep||
            vCORNER7||vSep||
            vCORNER8||vSep||
            vCORNER9||vSep||
            vCORNER10||vSep||
            vCORNER11||vSep||
            vCORNER12||vSep||
            vCORNER13||vSep||
            vCORNER14||vSep||
            vCORNER15||vSep||
            vCORNER16||vSep||
            LPad(vXCOORD,5,'0')||vSep||
            LPad(vYCOORD,5,'0')||vSep||
            LPad(vRADIUS*10,5,'0')||vSep||
            LPad(vWIDTH*10,5,'0')||vSep||
            LPad(vHEIGHT*10,5,'0')||vSep2;
        end if;
      end loop;
    end if;
  end loop;
  close c1;

return vResult;
end bea;

FUNCTION BTH RETURN VARCHAR2 
as
  vResult varchar2(1000);

  vBTH_INFO varchar2(10);
  vBCD_START number(6);
  vBATCH_NO number(8);

  vSep char;
begin
  vResult := ' ';
  vSep := ' ';

  vBTH_INFO := ' ';
  vBCD_START := 0;
  vBATCH_NO := 0;

  vResult := '<BTH> '||
    rpad(vBTH_INFO,10)||vSep||
    lpad(vBCD_START,6,'0')||vSep||
    lpad(vBATCH_NO,8,'0');

return vResult;
end BTH;

FUNCTION ELEM (pNrKompZlec number, pNrPoz number, pNrElem number) RETURN VARCHAR2 
as
  cursor c1 is  
    select * from v_zlec_mon vzm WHERE vzm.nr_kom_zlec=pNrKompZlec and vzm.nr_poz=pNrPoz and vzm.nr_el_wew=pNrElem;
  vzm v_zlec_mon%rowtype;

--  vGrub number;
  vCzyPow number;
--  vNrKat number;
  vCzyOrn number;
  vZnaczPr varchar2(4);
  vOznRamki char;
  vResult varchar2(1000);

  cg number;
  cf number;

  vGLX_ITEM_INX number(5);
  vGLX_DESCRIPT varchar2(40);
  vGLX_SURFACE number(1);
  vGLX_THICKNESS number(5);
  vGLX_FACE_SIDE number(1);
  vGLX_IDENT varchar2(10);
  vGLX_PATT_DIR number(1);
  vGLX_PANE_BCD varchar2(10);
  vGLX_PROD_PANE number(1);
  vGLX_PROD_COMP number(2);
  vGLX_CATEGORY number(2);

  vFRX_ITEM_INX number(5);
  vFRX_DESCRIPTION varchar2(40);
  vFRX_TYPE number(2);
  vFRX_COLOR number(2);
  vFRX_WIDTH number(5);
  vFRX_HEIGHT number(5);
  vFRX_IDENT varchar2(10);

  vSep char;
begin
  vResult := ' ';
  vSep := ' ';
  cg := 0;
  cf := 0;

-- Pobierz dane z widoku v_zlec_mon
  OPEN c1;
  LOOP
    FETCH c1 INTO vzm;
    EXIT WHEN c1%NOTFOUND; 
    vCzyOrn := 0;

-- gdy warstwwa szkla
    if pNrElem mod 2 = 1 then
      cg := floor(pNrElem/2)+1;
      if vzm.nr_kat>0 then
        select NVL(substr(k.naz_kat,1,40),' '),decode(Substr(k.typ_kat,2,1),'O',1,0),k.znacz_pr into vGLX_DESCRIPT,vCzyOrn,vZnaczPr from katalog k where k.nr_kat=vzm.nr_kat;
      else 
        vGLX_DESCRIPT := vzm.typ_kat||' '||vzm.grub;
      end if;
      vGLX_ITEM_INX := 0;


      if vzm.powL>0 or vzm.powR>0 then vGLX_SURFACE := 1;
      elsif vCzyOrn=1 then vGLX_SURFACE := 2;
      else vGLX_SURFACE := 0;
      end if;

      vGLX_THICKNESS := round(vzm.grub*10);

      if vzm.powL>0 then vGLX_FACE_SIDE := 2;
      elsif vzm.powR>0 then vGLX_FACE_SIDE := 1;
      else vGLX_FACE_SIDE := 0;
      end if;

      vGLX_IDENT := ' ' ;
      vGLX_PATT_DIR := 0;
      vGLX_PANE_BCD := ' ';
      vGLX_PROD_PANE := 0;
      vGLX_PROD_COMP := 0;

      if vzm.typ_kat='LAMINAT' or vZnaczPr='9.La' then vGLX_CATEGORY := 2;
      else vGLX_CATEGORY := 1;
      END IF;

      vResult := '<GL'||cg||'> '||
        LPad(vGLX_ITEM_INX,5,'0')||vSep||
        rpad(vGLX_DESCRIPT,40)||vSep||
        vGLX_SURFACE||vSep||
        LPad(vGLX_THICKNESS,5,'0')||vSep||
        vGLX_FACE_SIDE||vSep||
        rpad(vGLX_IDENT,10)||vSep||
        vGLX_PATT_DIR||vSep||
        rpad(vGLX_PANE_BCD,10)||vSep||
        vGLX_PROD_PANE||vSep||
        LPad(vGLX_PROD_COMP,2,'0')||vSep||
        LPad(vGLX_CATEGORY,2,'0');

    end if;
-- gdy warstwa ramki
    if pNrElem mod 2 = 0 then
      vFRX_ITEM_INX := 0;

      cg := floor(pNrElem/2);
      if vzm.nr_kat>0 then
        select NVL(substr(k.naz_kat,1,40),' '),nvl(grubosc*10,0),nvl(bok_od*10,0) into vFRX_DESCRIPTION,vFRX_WIDTH,vFRX_HEIGHT from katalog k where k.nr_kat=vzm.nr_kat;
      else 
        vFRX_DESCRIPTION := ' ';
        vFRX_WIDTH := 0;
        vFRX_HEIGHT := 0;
      end if;

      vOznRamki := Substr(vzm.typ_kat,2,1);
      IF vOznRamki='A' then vFRX_TYPE := 0;
      ELSIF vOznRamki='C' then vFRX_TYPE := 0;
      ELSIF vOznRamki='E' then vFRX_TYPE := 0;
      ELSIF vOznRamki='G' then vFRX_TYPE := 3;
      ELSIF vOznRamki='H' then vFRX_TYPE := 0;
      ELSIF vOznRamki='M' then vFRX_TYPE := 0;
      ELSIF vOznRamki='N' then vFRX_TYPE := 0;
      ELSIF vOznRamki='P' then vFRX_TYPE := 0;
      ELSIF vOznRamki='S' then vFRX_TYPE := 3;
      ELSIF vOznRamki='T' then vFRX_TYPE := 0;
      ELSIF vOznRamki='W' then vFRX_TYPE := 0;
      else vFRX_TYPE :=0;
      END IF;

      vFRX_COLOR := 0;
      vFRX_IDENT := '0';

      vResult := '<FR'||cg||'> '||
        LPad(vFRX_ITEM_INX,5,'0')||vSep||
        rpad(vFRX_DESCRIPTION,40)||vSep||
        LPad(vFRX_TYPE,2,'0')||vSep||
        LPad(vFRX_COLOR,2,'0')||vSep||
        LPad(vFRX_WIDTH,5,'0')||vSep||
        LPad(vFRX_HEIGHT,5,'0')||vSep||
        rpad(vFRX_IDENT,10);
    end if;
  end loop;
  close c1;

return vResult;
end elem;


FUNCTION ORD (pNrKompZlec number) RETURN VARCHAR2 
as
  vResult varchar2(1000);

  vORD varchar2(10);
  vCUST_NUM varchar2(10);
  vCUST_NAME varchar2(40);
  vTEXT1 varchar2(40);
  vTEXT2 varchar2(40);
  vTEXT3 varchar2(40);
  vTEXT4 varchar2(40);
  vTEXT5 varchar2(40);
  vPRD_DATE varchar2(10);
  vDEL_DATE varchar2(10);
  vDEL_AREA varchar2(10);

  vSep char;
begin
  vResult := ' ';
  vSep := ' ';


  select 
    z.nr_zlec ORD,
    z.nr_kon CUST_NUM,
    k.skrot_k CUST_NAM,
    ' ' TEXT1,
    ' ' TEXT2,
    ' ' TEXT3,
    ' ' TEXT4,
    ' ' TEXT5,
    to_char(z.d_plan,'DD/MM/YYYY') PRD_DATE,
    to_char(z.d_pl_sped,'DD/MM/YYYY') DEL_DATE,
    ' ' DEL_AREA
  into  vORD, vCUST_NUM, vCUST_NAME, 
        vTEXT1, vTEXT2, vTEXT3, vTEXT4, vTEXT5,
        vPRD_DATE, vDEL_DATE, vDEL_AREA
  from zamow z
  left join klient k on k.nr_kon=z.nr_kon
  where z.nr_kom_zlec=pNrKompZlec;


  vResult := '<ORD> '||
    rpad(vORD,10)||vSep||
    rpad(vCUST_NUM,10)||vSep||
    rpad(vCUST_NAME,40)||vSep||
    rpad(vTEXT1,40)||vSep||
    rpad(vTEXT2,40)||vSep||
    rpad(vTEXT3,40)||vSep||
    rpad(vTEXT4,40)||vSep||
    rpad(vTEXT5,40)||vSep||
    rpad(vPRD_DATE,10)||vSep||
    rpad(vDEL_DATE,10)||vSep||
    rpad(vDEL_AREA,10);

return vResult;
end ORD;

FUNCTION POS (pNrKompZlec number, pNrPoz number, pNrSzt number) RETURN VARCHAR2 
as
  cursor c1 is  
    select * from v_zlec_mon vzm WHERE vzm.nr_kom_zlec=pNrKompZlec and vzm.nr_poz=pNrPoz;
  vzm v_zlec_mon%rowtype;
  vGrub number;
  vCzyPow number;
  vNrKat number;
  vCzyOrn number;
  vResult varchar2(1000);

  type glassa_t is varray(9) of varchar2(5);
  type gasa_t is varray(4) of number;
  glassa glassa_t := glassa_t(' ',' ',' ',' ',' ',' ',' ',' ',' ');
  gasa gasa_t := gasa_t(0,0,0,0);
  c number;

  vITEM_NUM number(5);
  vID_NUM varchar2(8);
  vBARCODE number(4);
  vQTY number(5);
  vWIDTH number(5);
  vHEIGHT number(5);
  vINSET number(3);
  vFRAME_TXT number(2);
  vSEAL_TYPE number(1);
  vFRAH_TYPE number(1);
  vFRAH_HOE number(5);
  vPATT_DIR number(1);
  vDGU_PANE number(1);

  vSep char;
begin
  vResult := ' ';
  vSep := ' ';
  c := 0;

-- Pobierz dane z widoku v_zlec_mon
  OPEN c1;
  LOOP
    FETCH c1 INTO vzm;
    EXIT WHEN c1%NOTFOUND; 
    c := c+1;
    vCzyOrn := 0;
    glassa(c) := to_char(round(vzm.grub,0));

-- gdy warstwwa szkla
    if c mod 2 = 1 then
      if vzm.nr_kat>0 then
        select decode(Substr(typ_kat,2,1),'O',1,0) into vCzyOrn from katalog where nr_kat=vzm.nr_kat;
      end if;

      if vzm.powL>0 or vzm.powR>0 then glassa(c) := glassa(c)||'-1';
      elsif vCzyOrn=1 then glassa(c) := glassa(c)||'-2';
      else glassa(c) := glassa(c)||'-0';
      end if;
    end if;
-- gdy warstwa ramki
    if c mod 2 = 0 then
      if vzm.gaz='A' then 
        gasa(c / 2) := 1;
      elsif vzm.gaz='K' then
        gasa(c / 2) := 2;
      else
        gasa(c / 2) := 0;
      end if;
      glassa(c) := Substr(vzm.typ_kat,2,1)||glassa(c);
      if substr(vzm.ind_bud,13,1)=1 then
        vSEAL_TYPE := 9;
      elsif vzm.silikon=1 then
        vSEAL_TYPE := 1;
      else 
        vSEAL_TYPE := 0;
      end if;
    end if;
  end loop;
  close c1;


  select 
    p.nr_poz ITEM_NUM,
    k.rack_no ID_NUM,
    0 BARCODE,
    1 QTY,
    p.szer WIDTH,
    p.wys HEIGHT,
    decode(p.GR_SIL,0,45,p.GR_SIL*10) INSET,
    0 FRAME_TXT,
    0 FRAH_TYPE,
    0 FRAH_HOE,
    0 PATT_DIR,
    0 DGU_PANE
  into  vITEM_NUM,vID_NUM,vBARCODE,vQTY,vWIDTH,vHEIGHT,
        vINSET,vFRAME_TXT,
        vFRAH_TYPE,vFRAH_HOE,vPATT_DIR,vDGU_PANE
  from spisz p
  left join struktury s on s.kod_str=p.kod_str
  left join kol_stojakow k on k.nr_komp_zlec=p.nr_kom_zlec and k.nr_poz=p.nr_poz and k.nr_sztuki=pNrSzt and k.nr_warstwy=1
  where p.nr_kom_zlec=pNrKompZlec and p.nr_poz=pNrPoz;

  vResult := '<POS> '||
    LPad(vITEM_NUM,5,'0')||vSep||
    rpad(vID_NUM,8)||vSep||
    lpad(vBARCODE,4,'0')||vSep||
    lpad(vQTY,5,'0')||vSep||
    lpad(vWIDTH*10,5,'0')||vSep||
    lpad(vHEIGHT*10,5,'0')||vSep||
    rpad(glassa(1),5)||vSep||
    rpad(glassa(2),3)||vSep||
    rpad(glassa(3),5)||vSep||
    rpad(glassa(4),3)||vSep||
    rpad(glassa(5),5)||vSep||
    rpad(glassa(6),3)||vSep||
    rpad(glassa(7),5)||vSep||
    rpad(glassa(8),3)||vSep||
    rpad(glassa(9),5)||vSep||
    lpad(vINSET,3,'0')||vSep||
    lpad(vFRAME_TXT,2,'0')||vSep||
    lpad(gasa(1),2,'0')||vSep||
    lpad(gasa(2),2,'0')||vSep||
    lpad(gasa(3),2,'0')||vSep||
    lpad(gasa(4),2,'0')||vSep||
    vSEAL_TYPE||vSep||
    vFRAH_TYPE||vSep||
    lpad(vFRAH_HOE,5,'0')||vSep||
    vPATT_DIR||vSep||
    vDGU_PANE;

return vResult;
end pos;

FUNCTION REL RETURN VARCHAR2 
as
  vResult varchar2(1000);

  vREL_NUM varchar2(5);
  vREL_INFO varchar2(40);

  vSep char;
begin
  vResult := ' ';
  vSep := ' ';

  vREL_NUM := '02.80';
  vREL_INFO := 'SIP - Transfer Cutter 2000';

  vResult := '<REL> '||
    rpad(vREL_NUM,10)||vSep||
    rpad(vREL_INFO,40);

return vResult;
end REL;

FUNCTION SHP (pNrKompZlec number, pNrPoz number, pNrElem number) RETURN VARCHAR2 
as
  cursor c1 is  
    select * from v_zlec_mon vzm WHERE vzm.nr_kom_zlec=pNrKompZlec and vzm.nr_poz=pNrPoz and vzm.nr_el_wew=pNrElem;
  vzm v_zlec_mon%rowtype;

  vResult varchar2(1000);

  cg number;

  vSHP_PANE number(1):=0;
  vSHP_DEF number(1):=0;
  vSHP_CAT number(1):=0;
  vSHP_NUM number(3):=0;
  vSHP_LEN number(5):=0;
  vSHP_LEN1 number(5):=0;
  vSHP_LEN2 number(5):=0;
  vSHP_HGT number(5):=0;
  vSHP_HGT1 number(5):=0;
  vSHP_HGT2 number(5):=0;
  vSHP_RAD number(5):=0;
  vSHP_RAD1 number(5):=0;
  vSHP_RAD2 number(5):=0;
  vSHP_RAD3 number(5):=0;
  vSHP_TRIM1 number(5):=0;
  vSHP_TRIM2 number(5):=0;
  vSHP_TRIM3 number(5):=0;
  vSHP_TRIM4 number(5):=0;
  vSHP_EDGE1 number(5):=0;
  vSHP_EDGE2 number(5):=0;
  vSHP_EDGE3 number(5):=0;
  vSHP_EDGE4 number(5):=0;
  vSHP_EDGE5 number(5):=0;
  vSHP_EDGE6 number(5):=0;
  vSHP_EDGE7 number(5):=0;
  vSHP_EDGE8 number(5):=0;
  vSHP_PATH varchar2(40):=' ';
  vSHP_FILE varchar2(40):=' ';
  vSHP_NAME varchar2(40):=' ';
  vSHP_MIRR number(1):=0;
  vSHP_BASE number(1):=0;

  vSep char;
begin
  vResult := ' ';
  vSep := ' ';
  cg := 0;

-- Pobierz dane z widoku v_zlec_mon
  OPEN c1;
  LOOP
    FETCH c1 INTO vzm;
    EXIT WHEN c1%NOTFOUND; 

-- gdy warstwwa szkla
    if pNrElem mod 2 = 1 then
      cg := floor(pNrElem/2)+1;

      vSHP_PANE :=0;
      vSHP_DEF :=0;
      vSHP_CAT :=0;
      vSHP_NUM :=0;
      vSHP_LEN :=0;
      vSHP_LEN1 :=0;
      vSHP_LEN2 :=0;
      vSHP_HGT :=0;
      vSHP_HGT1 :=0;
      vSHP_HGT2 :=0;
      vSHP_RAD :=0;
      vSHP_RAD1 :=0;
      vSHP_RAD2 :=0;
      vSHP_RAD3 :=0;
      vSHP_TRIM1 :=0;
      vSHP_TRIM2 :=0;
      vSHP_TRIM3 :=0;
      vSHP_TRIM4 :=0;
      vSHP_EDGE1 :=0;
      vSHP_EDGE2 :=0;
      vSHP_EDGE3 :=0;
      vSHP_EDGE4 :=0;
      vSHP_EDGE5 :=0;
      vSHP_EDGE6 :=0;
      vSHP_EDGE7 :=0;
      vSHP_EDGE8 :=0;
      vSHP_PATH :=' ';
      vSHP_FILE :=' ';
      vSHP_NAME :=' ';
      vSHP_MIRR :=0;
      vSHP_BASE :=0;

      vSHP_PANE := cg;
      if cg=1 then 
        vSHP_DEF := 0;
        vSHP_LEN := nvl(vzm.szer,0);
        vSHP_HGT := nvl(vzm.wys,0);
        if (to_number(strtoken(vzm.par_kszt,2,':'),'999')>0) then
          vSHP_CAT := to_number(strtoken(vzm.par_kszt,1,':'),'9');
          vSHP_NUM := to_number(strtoken(vzm.par_kszt,2,':'),'999');
          vSHP_LEN1 :=to_number(strtoken(vzm.par_kszt,4,':'),'99999');
          vSHP_LEN2 :=to_number(strtoken(vzm.par_kszt,5,':'),'99999');
          vSHP_HGT1 :=to_number(strtoken(vzm.par_kszt,7,':'),'99999');
          vSHP_HGT2 :=to_number(strtoken(vzm.par_kszt,8,':'),'99999');
          vSHP_RAD :=to_number(strtoken(vzm.par_kszt,9,':'),'99999');
          vSHP_RAD1 :=to_number(strtoken(vzm.par_kszt,10,':'),'99999');
          vSHP_RAD2 :=to_number(strtoken(vzm.par_kszt,11,':'),'99999');
          vSHP_RAD3 :=to_number(strtoken(vzm.par_kszt,12,':'),'99999');
        end if;
      else
        vSHP_DEF := 2;
        vSHP_EDGE1 := Abs(vzm.max_stepD-vzm.stepD);
        vSHP_EDGE2 := Abs(vzm.max_stepP-vzm.stepP);
        vSHP_EDGE3 := Abs(vzm.max_stepG-vzm.stepG);
        vSHP_EDGE4 := Abs(vzm.max_stepL-vzm.stepL);
--        vSHP_EDGE1 := -vzm.stepD;
--        vSHP_EDGE2 := -vzm.stepP;
--        vSHP_EDGE3 := -vzm.stepG;
--        vSHP_EDGE4 := -vzm.stepL;
      end if;

      vResult := '<SHP> '||
        vSHP_PANE||vSep||
        vSHP_DEF||vSep||
        vSHP_CAT||vSep||
        LPad(vSHP_NUM,3,'0')||vSep||
        LPad(vSHP_LEN*10,5,'0')||vSep||
        LPad(vSHP_LEN1*10,5,'0')||vSep||
        LPad(vSHP_LEN2*10,5,'0')||vSep||
        LPad(vSHP_HGT*10,5,'0')||vSep||
        LPad(vSHP_HGT1*10,5,'0')||vSep||
        LPad(vSHP_HGT2*10,5,'0')||vSep||
        LPad(vSHP_RAD*10,5,'0')||vSep||
        LPad(vSHP_RAD1*10,5,'0')||vSep||
        LPad(vSHP_RAD2*10,5,'0')||vSep||
        LPad(vSHP_RAD3*10,5,'0')||vSep||
        LPad(vSHP_TRIM1*10,5,'0')||vSep||
        LPad(vSHP_TRIM2*10,5,'0')||vSep||
        LPad(vSHP_TRIM3*10,5,'0')||vSep||
        LPad(vSHP_TRIM4*10,5,'0')||vSep||
        LPad(vSHP_EDGE1*10,5,' ')||vSep||
        LPad(vSHP_EDGE2*10,5,' ')||vSep||
        LPad(vSHP_EDGE3*10,5,' ')||vSep||
        LPad(vSHP_EDGE4*10,5,' ')||vSep||
        LPad(vSHP_EDGE5*10,5,' ')||vSep||
        LPad(vSHP_EDGE6*10,5,' ')||vSep||
        LPad(vSHP_EDGE7*10,5,' ')||vSep||
        LPad(vSHP_EDGE8*10,5,' ')||vSep||
        RPad(vSHP_PATH,40)||vSep||
        RPad(vSHP_FILE,40)||vSep||
        RPad(vSHP_NAME,40)||vSep||
        vSHP_MIRR||vSep||
        vSHP_BASE;
    end if;
  end loop;
  close c1;

return vResult;
end shp;

END PKG_LIPROD280;

/
