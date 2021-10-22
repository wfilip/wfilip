CREATE OR REPLACE FUNCTION PAR_OBR (pFUN NUMBER, pNK_OBR NUMBER, pTYP_KAT VARCHAR2) RETURN NUMBER
AS
 vRet NUMBER(14,4);
 vCzas CHAR(6);
BEGIN
 --czas przezbrojenia w MIN
 IF pFUN=1 THEN
  SELECT nvl(max(nvl(D2.czas_przezbr,D1.czas_przezbr)),' ')
  INTO vCzas
  FROM katalog K
  LEFT JOIN pinst_dodn D1 ON D1.nr_komp_inst=pNK_OBR AND K.grubosc between D1.grub_od and D1.grub_do and trim(D1.typ_kat) is null
  LEFT JOIN pinst_dodn D2 ON D1.nr_komp_inst=pNK_OBR AND D2.typ_kat=K.typ_kat
    --LEFT JOIN pinst_dodn D2 ON D2.nr_komp_inst=S.nk_inst and D2.typ_kat=S.indeks and D2.nr_komp_obr=0 --and S.grub between D2.grub_od and D2.grub_do
    --LEFT JOIN pinst_dodn D3 ON D3.nr_komp_inst=S.nk_inst and trim(D3.typ_kat) is null and D3.nr_komp_obr=S.nk_obr and S.grub between D3.grub_od and D3.grub_do
    --LEFT JOIN pinst_dodn D0 ON D0.nr_komp_inst=S.nk_inst and trim(D0.typ_kat) is null and D0.nr_komp_obr=0 and S.grub between D0.grub_od and D0.grub_do
  WHERE K.typ_kat=pTYP_KAT;  
  RETURN TIME_TO_MINUTES(vCZAS);
 ELSE 
  RETURN 0;
 END IF;
END PAR_OBR;
/