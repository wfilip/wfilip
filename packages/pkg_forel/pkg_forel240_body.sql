--------------------------------------------------------
--  DDL for Package Body PKG_FOREL240
--------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY "PKG_FOREL240" AS

    FUNCTION ord (
        vord_num    VARCHAR2,
        vcust_num   VARCHAR2,
        vcust_name  VARCHAR2,
        vtext1      VARCHAR2,
        vtext2      VARCHAR2,
        vtext3      VARCHAR2,
        vtext4      VARCHAR2,
        vtext5      VARCHAR2,
        vprod_date  VARCHAR2,
        vdel_date   VARCHAR2,
        vdel_area   VARCHAR2
    ) RETURN VARCHAR2 AS
    BEGIN
        RETURN 'ORD'
               || vsep
               || vord_num
               || vsep
               || vcust_num
               || vsep
               || vcust_name
               || vsep
               || vtext1
               || vsep
               || vtext2
               || vsep
               || vtext3
               || vsep
               || vtext4
               || vsep
               || vtext5
               || vsep
               || vprod_date
               || vsep
               || vdel_date
               || vsep
               || vdel_area;
    END;

    FUNCTION pan (
        pitem_num         NUMBER,
        pid_num           VARCHAR2,
        pbarcode          VARCHAR2,
        ppan_qty          NUMBER,
        pwidth            NUMBER,
        pheight           NUMBER,
        ppane1            NUMBER,
        pspacer1          NUMBER,
        ppane2            NUMBER,
        pspacer2          NUMBER,
        ppane3            NUMBER,
        pspacer3          NUMBER,
        ppane4            NUMBER,
        pseal_inset       NUMBER,
        pgas_spacer1      NUMBER,
        pgas_spacer2      NUMBER,
        pgas_spacer3      NUMBER,
        pseal_code        NUMBER,
        pspacer_type      NUMBER,
        pspacer_height    NUMBER,
        pshape            NUMBER,
        pheavy_pane       NUMBER,
        prack_info        VARCHAR2,
        pig_pane_reverse  NUMBER
    ) RETURN VARCHAR2 AS
    BEGIN
        RETURN 'PAN'
               || vsep
               || pitem_num
               || vsep
               || pid_num
               || vsep
               || pbarcode
               || vsep
               || ppan_qty
               || vsep
               || pwidth * 10
               || vsep
               || pheight * 10
               || vsep
               || ppane1
               || vsep
               || pspacer1
               || vsep
               || ppane2
               || vsep
               || pspacer2
               || vsep
               || ppane3
               || vsep
               || pspacer3
               || vsep
               || ppane4
               || vsep
               || pseal_inset * 10
               || vsep
               || pgas_spacer1
               || vsep
               || pgas_spacer2
               || vsep
               || pgas_spacer3
               || vsep
               || pseal_code
               || vsep
               || pspacer_type
               || vsep
               || pspacer_height
               || vsep
               || pshape
               || vsep
               || pheavy_pane
               || vsep
               || prack_info
               || vsep
               || pig_pane_reverse
               || vsep;
    END;

    FUNCTION ver (
        punit NUMBER
    ) RETURN VARCHAR2 AS
        vver_num VARCHAR2(6);
    BEGIN
        vver_num := '02.40';
        RETURN 'VER'
               || vsep
               || vver_num
               || vsep
               || punit;
    END;

    FUNCTION shp (
        pshp_path  VARCHAR2,
        pshp_file  VARCHAR2,
        pshp_name  VARCHAR2,
        pshp_cat   NUMBER,
        pshp_num   NUMBER,
        pshp_l     NUMBER,
        pshp_l1    NUMBER,
        pshp_l2    NUMBER,
        pshp_h     NUMBER,
        pshp_h1    NUMBER,
        pshp_h2    NUMBER,
        pshp_r     NUMBER,
        pshp_r1    NUMBER,
        pshp_r2    NUMBER,
        pshp_r3    NUMBER,
        pshp_mirr  NUMBER,
        pshp_base  NUMBER
    ) RETURN VARCHAR2 AS
        vresult VARCHAR2(1000);
    BEGIN
        RETURN 'SHP'
               || vsep
               || pshp_path
               || vsep
               || pshp_file
               || vsep
               || pshp_name
               || vsep
               || pshp_cat
               || vsep
               || pshp_num
               || vsep
               || pshp_l * 10
               || vsep
               || pshp_l1 * 10
               || vsep
               || pshp_l2 * 10
               || vsep
               || pshp_h * 10
               || vsep
               || pshp_h1 * 10
               || vsep
               || pshp_h2 * 10
               || vsep
               || pshp_r * 10
               || vsep
               || pshp_r1 * 10
               || vsep
               || pshp_r2 * 10
               || vsep
               || pshp_r3 * 10
               || vsep
               || pshp_mirr
               || vsep
               || pshp_base;
    END;

    FUNCTION cm (
        ppaneno          NUMBER,
        ppane_descript   VARCHAR2,
        pid_num          VARCHAR2,
        ppane_barcode    VARCHAR2,
        ppane_type       NUMBER,
        ppane_code       VARCHAR2,
        ppane_thickness  NUMBER,
        ppane_width      NUMBER,
        ppane_height     NUMBER,
        ppane_faceside   NUMBER,
        ppane_rack_info  VARCHAR2,
        psp_descript     VARCHAR2,
        psp_type         NUMBER,
        psp_code         VARCHAR2,
        psp_width        NUMBER,
        psp_height       NUMBER,
        psp_inset        NUMBER,
        psp_rack_info    VARCHAR2,
        psp_gascode      NUMBER,
        psp_seal_type    NUMBER
    ) RETURN VARCHAR2 AS
    BEGIN
        RETURN 'CM'
               || ppaneno
               || vsep
               || ppane_descript
               || vsep
               || pid_num
               || vsep
               || ppane_barcode
               || vsep
               || ppane_type
               || vsep
               || ppane_code
               || vsep
               || ppane_thickness
               || vsep
               || ppane_width * 10
               || vsep
               || ppane_height * 10
               || vsep
               || ppane_faceside
               || vsep
               || ppane_rack_info
               || vsep
               || psp_descript
               || vsep
               || psp_type
               || vsep
               || psp_code
               || vsep
               || psp_width
               || vsep
               || psp_height
               || vsep
               || psp_inset * 10
               || vsep
               || psp_rack_info
               || vsep
               || psp_gascode
               || vsep
               || psp_seal_type
               || vsep;
    END;

    FUNCTION txt (
        ptxt VARCHAR2
    ) RETURN VARCHAR2 AS
    BEGIN
        RETURN 'PRO'
               || vsep
               || vsep
               || vsep
               || '1'
               || vsep
               || vsep
               || vsep
               || vsep
               || vsep
               || vsep
               || vsep
               || vsep
               || vsep
               || vsep
               || vsep
               || 'Printing Text'
               || vsep
               || ptxt
               || vsep;
    END;

    FUNCTION pro (
        ppro_id           NUMBER,
        ppane_face_side   NUMBER,
        ppro_type         NUMBER,
        pside1            NUMBER,
        pside2            NUMBER,
        pside3            NUMBER,
        pside4            NUMBER,
        pside5            NUMBER,
        pside6            NUMBER,
        pside7            NUMBER,
        pside8            NUMBER,
        pside9            NUMBER,
        pside10           NUMBER,
        ppro_description  VARCHAR2,
        ppro_text         VARCHAR2
    ) RETURN VARCHAR2 AS
    BEGIN
        RETURN 'PRO'
               || vsep
               || ppro_id
               || vsep
               || ppane_face_side
               || vsep
               || ppro_type
               || vsep
               || pside1 * 10
               || vsep
               || pside2 * 10
               || vsep
               || pside3 * 10
               || vsep
               || pside4 * 10
               || vsep
               || pside5 * 10
               || vsep
               || pside6 * 10
               || vsep
               || pside7 * 10
               || vsep
               || pside8 * 10
               || vsep
               || pside9 * 10
               || vsep
               || pside10 * 10
               || vsep
               || ppro_description
               || vsep
               || ppro_text
               || vsep;
    END;

    FUNCTION generate_pro (
        pdeviceid    NUMBER,
        pnrkompzlec  NUMBER,
        pnrpoz       NUMBER,
        pnrelem      NUMBER
    ) RETURN VARCHAR2 AS

        CURSOR c1 IS
        SELECT
            *
        FROM
            v_zlec_mon vzm
        WHERE
                vzm.nr_kom_zlec = pnrkompzlec
            AND vzm.nr_poz = pnrpoz
            AND vzm.nr_el = pnrelem;

        vzm        v_zlec_mon%rowtype;
        vresult    VARCHAR2(1000);
        vside1     NUMBER(5);
        vside2     NUMBER(5);
        vside3     NUMBER(5);
        vside4     NUMBER(5);
        vside5     NUMBER(5);
        vside6     NUMBER(5);
        vside7     NUMBER(5);
        vside8     NUMBER(5);
        vside9     NUMBER(5);
        vside10    NUMBER(5);
        max_stepl  NUMBER(5);
        max_stepg  NUMBER(5);
        max_stepp  NUMBER(5);
        max_stepd  NUMBER(5);
        vsep2      VARCHAR2(2);
    BEGIN
        vsep2 := chr(13)
                 || chr(10);
        vresult := '';
        OPEN c1;
        FETCH c1 INTO vzm;

-- pobranie maksymalnego stepu na sasiadujacych warstwach
        SELECT
            MAX(stepl),
            MAX(stepg),
            MAX(stepp),
            MAX(stepd)
        INTO
            max_stepl,
            max_stepg,
            max_stepp,
            max_stepd
        FROM
            v_zlec_mon vzm
        WHERE
                vzm.nr_kom_zlec = pnrkompzlec
            AND vzm.nr_poz = pnrpoz
            AND vzm.nr_el IN (
                pnrelem - 1,
                pnrelem + 1
            );

-- informacja o stepie na ramce - pogębione uszczelnienie

        vside1 := 0;
        vside2 := 0;
        vside3 := 0;
        vside4 := 0;
        vside5 := 0;
        vside6 := 0;
        vside7 := 0;
        vside8 := 0;
        vside9 := 0;
        vside10 := 0;

-- SPECIAL inset
-- roznica wartosci stepu na ramce i max stepu na sasiadujacych warstwach to jest poglebienie uszczelnienia
        IF ( vzm.stepl - max_stepl > 0 ) OR ( vzm.stepp - max_stepp > 0 ) OR ( vzm.stepd - max_stepd > 0 ) OR ( vzm.stepg - max_stepg >
        0 ) THEN
            vside1 := vzm.stepd - max_stepd + vzm.uszcz_std;
            vside2 := vzm.stepp - max_stepp + vzm.uszcz_std;
            vside3 := vzm.stepg - max_stepg + vzm.uszcz_std;
            vside4 := vzm.stepl - max_stepl + vzm.uszcz_std;
            vresult := vresult
                       || pro(0, 0, 14, vside1, vside2,
    vside3, vside4, vside5, vside6, vside7,
    vside8, vside9, vside10, 'SPECIAL INSET (14)', '')
                       || vsep2;

        END IF;

-- informacja o stepie na warstwie szkla

        vside1 := 0;
        vside2 := 0;
        vside3 := 0;
        vside4 := 0;
        vside5 := 0;
        vside6 := 0;
        vside7 := 0;
        vside8 := 0;
        vside9 := 0;
        vside10 := 0;

-- step na ramcie okresla maksymalna wartosc stepu na sasiadujacych warstwach
        IF ( max_stepl > 0 ) OR ( max_stepp > 0 ) OR ( max_stepd > 0 ) OR ( max_stepg > 0 ) THEN
            vside1 := max_stepd;
            vside2 := max_stepp;
            vside3 := max_stepg;
            vside4 := max_stepl;
            vresult := vresult
                       || pro(0, 0, 4, vside1, vside2,
    vside3, vside4, vside5, vside6, vside7,
    vside8, vside9, vside10, 'OFFSET', '');

        END IF;

        RETURN vresult;
    END;

END;
/