create or replace FUNCTION WSP_4ZAKR (pNK_INST IN NUMBER, pPOW IN NUMBER, pIDENT_BUD IN VARCHAR2, pNR_KAT IN NUMBER DEFAULT 0, pCZAS IN NUMBER DEFAULT 0, pNOT_ZERO IN NUMBER DEFAULT 1) RETURN NUMBER AS
 vWsp NUMBER(5,2) :=null;
 vWspPlus NUMBER(5,2) :=null;
 vWspMinus NUMBER(5,2) :=null;
 vWspGT NUMBER(5,2) :=null;
 vWspLT NUMBER(5,2) :=null;
 vSumSek NUMBER(10) :=0;
BEGIN
 SELECT nvl(sum(case when znak_op='+' then wsp_przel else 0 end),0),
        nvl(sum(case when znak_op='-' then wsp_przel else 0 end),0),
        nvl(max(case when znak_op='>' then wsp_przel else 0 end),0),
        nvl(min(case when znak_op='<' then wsp_przel else 999 end),999),
        --MUL (wsp) = EXP (SUM (LN (wsp)))
        nvl(round(exp(sum(ln(case when wsp_przel<0 then 1 when znak_op='*' then wsp_przel when znak_op='/' then 1/wsp_przel else null end))),2),pNOT_ZERO),
        --nowe pole SEKUNDY
        nvl(sum(czas_w_sek),0)
   INTO vWspPlus, vWspMinus, vWspGT, vWspLT, vWsp, vSumSek
 FROM 
 (select case when round(pPOW,4) between zakr_1_min and zakr_1_max then znak_op1
              when round(pPOW,4) between zakr_2_min and zakr_2_max then znak_op2
              when round(pPOW,4) between zakr_3_min and zakr_3_max then znak_op3
              when round(pPOW,4) between zakr_4_min and zakr_4_max then znak_op4
              else '*' end znak_op,
         case when round(pPOW,4) between zakr_1_min and zakr_1_max then wsp_przel1
              when round(pPOW,4) between zakr_2_min and zakr_2_max then wsp_przel2
              when round(pPOW,4) between zakr_3_min and zakr_3_max then wsp_przel3
              when round(pPOW,4) between zakr_4_min and zakr_4_max then wsp_przel4
              else 1 end wsp_przel,
         case when round(pPOW,4) between zakr_1_min and zakr_1_max then secs1
              when round(pPOW,4) between zakr_2_min and zakr_2_max then secs2
              when round(pPOW,4) between zakr_3_min and zakr_3_max then secs3
              when round(pPOW,4) between zakr_4_min and zakr_4_max then secs4
              else 1 end czas_w_sek
  from parinst I
  left join wspinst W using (nr_komp_inst)
  where nr_komp_inst=pNK_INST --and znak_op1 in ('+','-','<','>','*')
    and substr('1'||pIDENT_BUD,nr_znacznika+1,1)='1' --uwzgl. NR_ZNACZNIKA=0\
    --dla inst ciecia sprawdzenie czy Surowiec ma atrybuty 1,2 lub 9
    and (pNR_KAT=0 OR nr_znacznika not in (1,2,9) OR I.ty_inst not in ('A C','R C') OR
         EXISTS (select 1
                 from katalog
                 where nr_kat=pNR_KAT
                   and (to_number(substr(znacz_pr,1,greatest(1,instr(znacz_pr,'.')-1)))=nr_znacznika
                        or substr(katalog.ident_bud,nr_znacznika,1)='1')
                )
         )       
 );        
 --vWsp:=1;
 vWsp:=vWsp+vWspPlus-vWspMinus;
 vWsp:=greatest(vWsp,vWspGT);
 vWsp:=least(vWsp,vWspLT);
 --IF vWsp=0 THEN vWsp:=1; END IF;
 RETURN case when pCZAS=1 then vSumSek
             else nvl(nullif(vWsp,0),pNOT_ZERO) 
        end;
END WSP_4ZAKR;
/