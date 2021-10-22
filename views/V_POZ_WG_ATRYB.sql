select (select count(1) from l_wyc L where L.nr_kom_zlec=Z.nr_kom_zlec) ilLW, Z.*
from zamow Z
order by nr_kom_zlec desc;

desc zamow;
create or replace view V_POZ_WG_BUD AS
select nr_kom_zlec, max(nr_zlec) nr_zlec, typ_poz, count(distinct nr_poz) il_poz, sum(ilosc) il_szyb, max(wybr_atr) ind_bud_szukany, atryb_product(ind_bud,nvl(wybr_atr,ind_bud)) ind_bud_istn,
       nvl((select listagg(do_wydruku,'+') within group (order by nr_znacznika)
        from atryb_dod
        where nr_znacznika>0 and substr(atryb_product(ind_bud,nvl(wybr_atr,ind_bud)),nr_znacznika,1)='1'
       ),'-') atr
from spisz
left join (select nr_par, str1 wybr_atr from params_tmp where nr_zest=5) PAR on PAR.nr_par=1
group by nr_kom_zlec, typ_poz, atryb_product(ind_bud,nvl(wybr_atr,ind_bud))--ind_bud;
;

select * from v_poz_wg_BUD;

select nr_poz, ind_bud, atryb_sum(ind_bud,'00010') match
from spisz where nr_zlec=1044;

select translate(sum(ident),'12','01')
from (select '1010100' ident from dual union select '0010101' from dual);
select atryb_product('101010011111111','001010111') from dual;

create or replace FUNCTION ATRYB_PRODUCT (pIDENT1 VARCHAR2, pIDENT2 VARCHAR2) RETURN VARCHAR2
AS
 vRet VARCHAR2(100):=' ';
 vDlugosc NUMBER(3):=100;
 Nr NUMBER(3):=0;
BEGIN
 vDlugosc:=greatest(length(pIDENT1),length(pIDENT2));
 LOOP
  EXIT WHEN Nr>=vDlugosc;
  Nr:=Nr+1;
  IF substr(pIDENT1,Nr,1)='1' and substr(pIDENT2,Nr,1)='1' THEN
   vRet:=vRet||'1';
  ELSE
   vRet:=vRet||'0';
  END IF; 
 END LOOP;
 RETURN trim(vRet);
EXCEPTION WHEN OTHERS THEN
 RETURN '0';
END ATRYB_PRODUCT;
/
--truncate table params_tmp;
--drop table params_tmp;
CREATE GLOBAL TEMPORARY TABLE PARAMS_TMP
  (	"NR_ZEST" NUMBER(6,0), 
	"NR_PAR" NUMBER(4,0), 
	"DATA1" DATE, 
	"DATA2" DATE, 
	"NUM1" NUMBER(10,0), 
	"NUM2" NUMBER(10,0), 
	"NUM3" NUMBER(10,0), 
	"NUM4" NUMBER(10,0), 
	"STR1" VARCHAR2(100)
   ) ON COMMIT PRESERVE ROWS ;
CREATE UNIQUE INDEX PARAMS_TMP_PK ON PARAMS_TMP ("NR_ZEST", "NR_PAR") ;

