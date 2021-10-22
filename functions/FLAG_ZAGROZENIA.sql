create or replace function FLAG_ZAGROZENIA (pNK_ZLEC NUMBER, pFORMA_WPR CHAR, pSTATUS CHAR, pWYR CHAR, pFLAG_R NUMBER, pD_PLAN_PROD DATE, pD_ZAK_PROD DATE, pDPS DATE, pDSK DATE) RETURN NUMBER
AS
 vRet NUMBER(1);
 DataZero DATE;
BEGIN
  DataZero:=to_date('2001/01','YYYY/MM'); 
  SELECT 
  CASE WHEN pFORMA_WPR='W' OR pSTATUS in ('Z','A')THEN 0 --wstepne, zakonczone i anulowane
       WHEN pWYR NOT IN ('Z','R','W')  THEN 0
       WHEN pDSK<=DataZero  THEN 0
       WHEN mod(pFLAG_R,1000)>=880 THEN 0
       WHEN pD_ZAK_PROD>DataZero AND pD_ZAK_PROD<=pDSK THEN 0
       WHEN mod(pFLAG_R,1000)<200
            OR (select nvl(count(1),1) from spise where nr_komp_zlec=pNK_ZLEC and zn_wyk in (0,3) and nr_stoj_sped=0)>0 THEN
            CASE WHEN pDSK<=sysdate THEN 1
                 WHEN pDPS>pDSK THEN 2
                 WHEN pD_PLAN_PROD<=DataZero AND pDSK<=sysdate+1 THEN 3
                 WHEN pD_PLAN_PROD>pDSK THEN 4
                 --WHEN (select PKG_CZAS.NR_ZM_TO_DATE(nvl(max(nr_zm_sped_min),0)) from lwyc2_inst_ost where nr_kom_zlec=pNK_ZLEC)>pDSK THEN 5
                 ELSE 0
             END 
       ELSE 0
   END
  INTO vRet
  FROM dual;
  RETURN vRet;
END FLAG_ZAGROZENIA;
/