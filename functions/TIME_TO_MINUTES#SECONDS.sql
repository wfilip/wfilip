create or replace function TIME_TO_SECONDS(pCZAS CHAR) RETURN NUMBER
AS
 czas char(6);
BEGIN
 IF trim(pCZAS) is null OR trim(translate(pCZAS,'0',' ')) is null THEN
  RETURN 0;
 ELSE
  czas:=RPAD(replace(pCZAS,':',''),6,'0'); --uzup. 0 do 121500, usuniecie dwukropków
  RETURN to_char(TO_DATE(czas,'HH24MISS'),'sssss');
 END IF;
END TIME_TO_SECONDS;
/

create or replace function TIME_TO_MINUTES(pCZAS CHAR) RETURN NUMBER
AS
 czas char(6);
BEGIN
 IF trim(pCZAS) is null OR trim(translate(pCZAS,'0',' ')) is null THEN
  RETURN 0;
 ELSE
  czas:=RPAD(replace(pCZAS,':',''),6,'0'); --uzup. 0 do 121500, usuniecie dwukropków
  RETURN to_number(substr(czas,1,2),'99')*60+to_number(substr(czas,3,2),'99')+to_number(substr(czas,5,2),'99')/60;
 END IF;
END TIME_TO_MINUTES;
/

--select time_to_seconds('01:10:02'), to_char(TO_DATE('23:59:59','HH24:MI:SS'),'sssss')/60 minutes, 60*24 min_per_day FROM DUAL;
