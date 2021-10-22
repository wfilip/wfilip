create or replace PACKAGE PKG_SQL AS 

PROCEDURE EXECUTE_SQLFILE (pfilename in varchar2, RET out number);

FUNCTION RAW_TO_NUMBER (pRAW IN RAW, pLength IN NUMBER) RETURN NUMBER;
FUNCTION RAW_TO_VARCHAR2 (pRAW IN RAW, pLength IN NUMBER) RETURN VARCHAR2;

END PKG_SQL;
/


create or replace PACKAGE BODY PKG_SQL AS

PROCEDURE EXECUTE_SQLFILE (pfilename in varchar2, RET out number)
as
 vInHandle utl_file.file_type;
 VNEWLINE  varchar2(250);
 VSTR varchar2(2000);
 vSQL varchar2(2000);
 POS integer;
begin
  ret := -1;
  VSQL := '';
  VSTR := '';
  VINHANDLE := UTL_FILE.FOPEN('SQLDIR', PFILENAME, 'R');
  if UTL_FILE.IS_OPEN(VINHANDLE) then
    LOOP
      begin
        RET:=0;
        UTL_FILE.GET_LINE(VINHANDLE, VNEWLINE);
        
        POS := INSTR(VNEWLINE, '--', 1, 1); 
        if POS=0 then
          VSTR := VSTR || VNEWLINE;
        end if;
        
        POS := INSTR(VSTR, ';', 1, 1); 
        if POS>0 then
          VSQL := SUBSTR(VSTR, 1 ,POS-1);
          DBMS_OUTPUT.PUT_LINE('-----------------');
          DBMS_OUTPUT.PUT_LINE(VSQL);
          dbms_output.put_line('-----------------');
          execute immediate VSQL;
          commit;
          VSTR := SUBSTR(VSTR,POS+1,length(VSTR)-POS);
--        dbms_output.put_line(vstr);
        end if;
      END;
    end LOOP;
  UTL_FILE.FCLOSE(VINHANDLE);
--  else
--    exit;
  end if;
EXCEPTION
  when OTHERS then
    null;
end EXECUTE_SQLFILE;

FUNCTION RAW_TO_NUMBER (pRAW IN RAW, pLength IN NUMBER) RETURN NUMBER
AS
 vHex CHAR(2);
 vDec CHAR(1);
 vWynS VARCHAR2(30);
BEGIN
  vWynS:=null;
  FOR i IN 1..pLength LOOP
   vHex := substr(pRAW,(i-1)*2+1, 2);
   IF true or i<pLength THEN --wyzsze bajty
    vDec := chr(to_number(vHex,'XX'));
   ELSE --pierwsze 2 bajty z prawej (0 to 7B; 1..9 to 41..49)
    IF vHex='7B' THEN
     vDec:='0';
    ELSIF vHex between '41' and '49' THEN
     vDec := chr(to_number(vHex,'XX')-16);
    END IF;
   END IF;
   vWynS := vWynS || vDec;
  END LOOP;
  RETURN to_number(vWynS,'999999999999999');
END RAW_TO_NUMBER;

FUNCTION RAW_TO_VARCHAR2 (pRAW IN RAW, pLength IN NUMBER) RETURN VARCHAR2
AS
 vHex CHAR(2);
 vChr CHAR(1);
 vWynS VARCHAR2(30);
BEGIN
  vWynS:=null;
  FOR i IN 1..pLength LOOP
   vHex := substr(pRAW,(i-1)*2+1, 2);
   vChr := chr(to_number(vHex,'XX'));
   vWynS := vWynS || vChr;
  END LOOP;
  RETURN vWynS;
END RAW_TO_VARCHAR2;

END PKG_SQL;
/