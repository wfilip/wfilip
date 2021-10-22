CREATE OR REPLACE PACKAGE "PKG_LIPROD280" AS
    FUNCTION bcd (
        pnrkompszyby NUMBER
    ) RETURN VARCHAR2;

    FUNCTION bea (
        pnrkompzlec   NUMBER,
        pnrpoz        NUMBER,
        pnrelem       NUMBER
    ) RETURN VARCHAR2;

    FUNCTION bth RETURN VARCHAR2;

    FUNCTION elem (
        pnrkompzlec   NUMBER,
        pnrpoz        NUMBER,
        pnrelem       NUMBER
    ) RETURN VARCHAR2;

    FUNCTION ord (
        pnrkompzlec NUMBER
    ) RETURN VARCHAR2;

    FUNCTION pos (
        pnrkompzlec   NUMBER,
        pnrpoz        NUMBER,
        pnrszt        NUMBER
    ) RETURN VARCHAR2;

    FUNCTION rel RETURN VARCHAR2;

    FUNCTION shp (
        pnrkompzlec   NUMBER,
        pnrpoz        NUMBER,
        pnrelem       NUMBER
    ) RETURN VARCHAR2;

END pkg_liprod280;
/
