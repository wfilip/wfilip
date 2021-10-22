create or replace function POZ_INFO (pNK_ZLEC NUMBER, pNR_POZ NUMBER, pNR_WAR NUMBER, pINFO_TYP VARCHAR2) RETURN NUMBER
AS
 vNum NUMBER(14,4):=0;
 vLinia VARCHAR(500);
BEGIN
 IF pINFO_TYP in ('POW_RZECZ','WAGA_RZECZ','OBW_RZECZ') THEN 
  IF pNR_WAR>0 THEN 
   select max(linia) into vLinia
   from zlec_typ
   where nr_komp_zlec=pNK_ZLEC and nr_poz=pNR_POZ and typ=NR_ZLECTYP(pNR_WAR);
   if vLinia is not null then
    vLinia:=case when instr(vLinia,'|',1,2)>0                      --dane jako 3. strtoken (nowy zapis)
                 then trim(strtoken(vLinia,3,'|'))                 --0:0;0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:;|0:0;0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:;|    0,9271;     0,0399;     0,0000;
                 when instr(vLinia,' ',INSTR(vLinia, ';' , 1, 3))>0 --0:0;0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:;|0:0;0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:;     0,9271;     0,0399;     0,0000;
                 then trim(substr(vLinia,instr(vLinia,' ',INSTR(vLinia, ';' , 1, 3))))
                 else null
            end;
    vNum:=case pINFO_TYP 
               when 'POW_RZECZ' then strtokenN(trim(vLinia),1,';','9999.9999',',')
               when 'WAGA_RZECZ' then strtokenN(trim(vLinia),2,';','9999.9999',',')
               when 'OBW_RZECZ' then strtokenN(trim(vLinia),3,';','9999.9999',',')
               else 0 end;
   end if;
  END IF; --pNR_WAR>0
  if vNum=0 then
    select max(linia) into vLinia --0|0:0|196658|1;3,284;81,279;8,164;|
    from zlec_typ
    where nr_komp_zlec=pNK_ZLEC and nr_poz=pNR_POZ and typ=13;
    if vLinia is not null and (to_number(substr(vLinia,1,1))>0 or pNR_WAR=0) then
     vLinia:=trim(strtoken(vLinia,4,'|'));
     vNum:=case pINFO_TYP 
           when 'POW_RZECZ' then strtokenN(trim(vLinia),2,';','9999.9999',',')
           when 'WAGA_RZECZ' then strtokenN(trim(vLinia),3,';','9999.9999',',')
           when 'OBW_RZECZ' then strtokenN(trim(vLinia),4,';','9999.9999',',')
           else 0 end;
    elsif pNR_WAR>0 then
     for d in (select szer_obr*0.001*wys_obr*0.001 pow, 2*szer_obr*0.001+2*wys_obr*0.001 obw, katalog.waga
               from spisd left join katalog using (nr_kat)
               where nr_kom_zlec=pNK_ZLEC and nr_poz=pNR_POZ and do_war=pNR_WAR and strona=0
                 and katalog.rodz_sur in ('TAF','LIS','POL') )
      loop
       vNum:=case pINFO_TYP 
             when 'POW_RZECZ' then d.pow
             when 'WAGA_RZECZ' then d.waga*d.pow
             when 'OBW_RZECZ' then d.obw
             else 0 end;
      end loop;
    end if;
  end if;
  if vNum=0 then
   for p in (select pow, obw, pow*waga waga
             from spisz left join struktury using (kod_str)
             where nr_kom_zlec=pNK_ZLEC and nr_poz=pNR_POZ)
    loop
     vNum:=case pINFO_TYP 
                when 'POW_RZECZ' then p.pow
                when 'WAGA_RZECZ' then p.waga
                when 'OBW_RZECZ' then p.obw
                else 0 end;
    end loop;
  end if;
 END IF;
 ---
 IF pINFO_TYP='NR_WAR_ORYG' THEN 
  select to_number(regexp_substr(ZT.linia,'\d+')) 
    into vNum
  from zlec_typ ZT 
  where ZT.typ=202 and ZT.nr_komp_zlec=pNK_ZLEC and ZT.nr_poz=pNR_POZ;
 END IF; 
 RETURN vNum;
EXCEPTION WHEN OTHERS THEN
 RETURN 0;
END POZ_INFO;