--------------------------------------------------------
--  DDL for Package PKG_FOREL240
--------------------------------------------------------
CREATE OR REPLACE PACKAGE "PKG_FOREL240" AS
    vsep CONSTANT CHAR(1) := '|';
    FUNCTION ord (
        vord_num     VARCHAR2,
        vcust_num    VARCHAR2,
        vcust_name   VARCHAR2,
        vtext1       VARCHAR2,
        vtext2       VARCHAR2,
        vtext3       VARCHAR2,
        vtext4       VARCHAR2,
        vtext5       VARCHAR2,
        vprod_date   VARCHAR2,
        vdel_date    VARCHAR2,
        vdel_area    VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION pan (
        pitem_num          NUMBER,
        pid_num            VARCHAR2,
        pbarcode           VARCHAR2,
        ppan_qty           NUMBER,
        pwidth             NUMBER,
        pheight            NUMBER,
        ppane1             NUMBER,
        pspacer1           NUMBER,
        ppane2             NUMBER,
        pspacer2           NUMBER,
        ppane3             NUMBER,
        pspacer3           NUMBER,
        ppane4             NUMBER,
        pseal_inset        NUMBER,
        pgas_spacer1       NUMBER,
        pgas_spacer2       NUMBER,
        pgas_spacer3       NUMBER,
        pseal_code         NUMBER,
        pspacer_type       NUMBER,
        pspacer_height     NUMBER,
        pshape             NUMBER,
        pheavy_pane        NUMBER,
        prack_info         VARCHAR2,
        pig_pane_reverse   NUMBER
    ) RETURN VARCHAR2;

    FUNCTION shp (
        pshp_path   VARCHAR2,
        pshp_file   VARCHAR2,
        pshp_name   VARCHAR2,
        pshp_cat    NUMBER,
        pshp_num    NUMBER,
        pshp_l      NUMBER,
        pshp_l1     NUMBER,
        pshp_l2     NUMBER,
        pshp_h      NUMBER,
        pshp_h1     NUMBER,
        pshp_h2     NUMBER,
        pshp_r      NUMBER,
        pshp_r1     NUMBER,
        pshp_r2     NUMBER,
        pshp_r3     NUMBER,
        pshp_mirr   NUMBER,
        pshp_base   NUMBER
    ) RETURN VARCHAR2;

    FUNCTION cm (
        ppaneno           NUMBER,
        ppane_descript    VARCHAR2,
        pid_num           VARCHAR2,
        ppane_barcode     VARCHAR2,
        ppane_type        NUMBER,
        ppane_code        VARCHAR2,
        ppane_thickness   NUMBER,
        ppane_width       NUMBER,
        ppane_height      NUMBER,
        ppane_faceside    NUMBER,
        ppane_rack_info   VARCHAR2,
        psp_descript      VARCHAR2,
        psp_type          NUMBER,
        psp_code          VARCHAR2,
        psp_width         NUMBER,
        psp_height        NUMBER,
        psp_inset         NUMBER,
        psp_rack_info     VARCHAR2,
        psp_gascode       NUMBER,
        psp_seal_type     NUMBER
    ) RETURN VARCHAR2;

    FUNCTION ver (
        punit NUMBER
    ) RETURN VARCHAR2;

    FUNCTION txt (
        ptxt VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION pro (
        ppro_id            NUMBER,
        ppane_face_side    NUMBER,
        ppro_type          NUMBER,
        pside1             NUMBER,
        pside2             NUMBER,
        pside3             NUMBER,
        pside4             NUMBER,
        pside5             NUMBER,
        pside6             NUMBER,
        pside7             NUMBER,
        pside8             NUMBER,
        pside9             NUMBER,
        pside10            NUMBER,
        ppro_description   VARCHAR2,
        ppro_text          VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION generate_pro (
        pdeviceid     NUMBER,
        pnrkompzlec   NUMBER,
        pnrpoz        NUMBER,
        pnrelem       NUMBER
    ) RETURN VARCHAR2;

END;
