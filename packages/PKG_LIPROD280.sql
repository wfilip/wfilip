  CREATE OR REPLACE PACKAGE "PKG_LIPROD280" AS 
function BCD (pNrKompSzyby number) RETURN VARCHAR2;
FUNCTION BEA (pNrKompZlec number, pNrPoz number, pNrElem number) RETURN VARCHAR2;
FUNCTION BTH RETURN VARCHAR2;
FUNCTION ELEM (pNrKompZlec number, pNrPoz number, pNrElem number) RETURN VARCHAR2;
FUNCTION ORD (pNrKompZlec number) RETURN VARCHAR2;
FUNCTION POS (pNrKompZlec number, pNrPoz number, pNrSzt number) RETURN VARCHAR2;
FUNCTION REL RETURN VARCHAR2;
FUNCTION SHP (pNrKompZlec number, pNrPoz number, pNrElem number) RETURN VARCHAR2;
END PKG_LIPROD280;

/
