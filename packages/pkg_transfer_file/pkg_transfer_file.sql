--------------------------------------------------------
--  DDL for Package PKG_TRANSFER_FILE
--------------------------------------------------------
CREATE OR REPLACE PACKAGE "PKG_TRANSFER_FILE" AS
    FUNCTION spacer_order_header (
        pdeviceid     NUMBER,
        pnrkompzlec   NUMBER
    ) RETURN VARCHAR2;

    FUNCTION spacer_file_header (
        pdeviceid NUMBER
    ) RETURN VARCHAR2;

    FUNCTION spacer_position (
        pdeviceid     NUMBER,
        pnrkompzlec   NUMBER,
        pnrpoz        NUMBER,
        pnrszt        NUMBER,
        pnrwar        NUMBER
    ) RETURN VARCHAR2;

    FUNCTION get_text (
        pnrkompzlec   NUMBER,
        pnrpoz        NUMBER,
        pnrszt        NUMBER,
        pnrwar        NUMBER
    ) RETURN VARCHAR2;

    FUNCTION get_cutframe_text (
        pnrkompzlec   NUMBER,
        pnrpoz        NUMBER,
        pnrszt        NUMBER,
        pnrwar        NUMBER
    ) RETURN VARCHAR2;

END pkg_transfer_file;
/
