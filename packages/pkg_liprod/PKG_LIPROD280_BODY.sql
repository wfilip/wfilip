CREATE OR REPLACE PACKAGE BODY "PKG_LIPROD280" AS

    FUNCTION bcd (
        pnrkompszyby NUMBER
    ) RETURN VARCHAR2 AS
        vresult    VARCHAR2(1000);
        vbarcode   NUMBER(24);
        vsep       CHAR;
    BEGIN
        vresult := ' ';
        vsep := ' ';
        vbarcode := pnrkompszyby;
        vresult := '<BCD> ' || rpad(vbarcode, 24);
        RETURN vresult;
    END bcd;

    FUNCTION bea (
        pnrkompzlec   NUMBER,
        pnrpoz        NUMBER,
        pnrelem       NUMBER
    ) RETURN VARCHAR2 AS

        CURSOR c1 IS
        SELECT
            *
        FROM
            v_zlec_mon vzm
        WHERE
            vzm.nr_kom_zlec = pnrkompzlec
            AND vzm.nr_poz = pnrpoz
            AND vzm.nr_el_wew = pnrelem;

        vzm          v_zlec_mon%rowtype;
        vresult      VARCHAR2(1000);
        cf           NUMBER;
        c            NUMBER;
        i            NUMBER;
        vstep        NUMBER;
        vindex       NUMBER(3) := 0;
        vsheet_inx   NUMBER(1) := 0;
        vfaceside    NUMBER(1) := 0;
        vdescript    VARCHAR2(40) := ' ';
        vtype        NUMBER(2) := 0;
        vedge1       NUMBER(1) := 0;
        vedge2       NUMBER(1) := 0;
        vedge3       NUMBER(1) := 0;
        vedge4       NUMBER(1) := 0;
        vedge5       NUMBER(1) := 0;
        vedge6       NUMBER(1) := 0;
        vedge7       NUMBER(1) := 0;
        vedge8       NUMBER(1) := 0;
        vcorner1     NUMBER(1) := 0;
        vcorner2     NUMBER(1) := 0;
        vcorner3     NUMBER(1) := 0;
        vcorner4     NUMBER(1) := 0;
        vcorner5     NUMBER(1) := 0;
        vcorner6     NUMBER(1) := 0;
        vcorner7     NUMBER(1) := 0;
        vcorner8     NUMBER(1) := 0;
        vcorner9     NUMBER(1) := 0;
        vcorner10    NUMBER(1) := 0;
        vcorner11    NUMBER(1) := 0;
        vcorner12    NUMBER(1) := 0;
        vcorner13    NUMBER(1) := 0;
        vcorner14    NUMBER(1) := 0;
        vcorner15    NUMBER(1) := 0;
        vcorner16    NUMBER(1) := 0;
        vxcoord      NUMBER(5) := 0;
        vycoord      NUMBER(5) := 0;
        vradius      NUMBER(5) := 0;
        vwidth       NUMBER(5) := 0;
        vheight      NUMBER(5) := 0;
        vsep         CHAR;
        vsep2        CHAR;
    BEGIN
        vresult := '';
        vsep := ' ';
        vsep2 := chr(9);
        cf := 0;
        c := 0;
        i := 0;

-- Pobierz dane z widoku v_zlec_mon
        OPEN c1;
        LOOP
            FETCH c1 INTO vzm;
            EXIT WHEN c1%notfound; 

-- gdy warstwa ramki
            IF pnrelem MOD 2 = 0 THEN
                cf := floor(pnrelem / 2);
                FOR i IN 1..4 LOOP
                    IF i = 1 THEN
                        vstep := vzm.stepd;
                    ELSIF i = 2 THEN
                        vstep := vzm.stepp;
                    ELSIF i = 3 THEN
                        vstep := vzm.stepg;
                    ELSIF i = 4 THEN
                        vstep := vzm.stepl;
                    END IF;

                    IF vstep > 0 THEN
                        vindex := 0;
                        vsheet_inx := 0;
                        vfaceside := 0;
                        vdescript := ' ';
                        vtype := 0;
                        vedge1 := 0;
                        vedge2 := 0;
                        vedge3 := 0;
                        vedge4 := 0;
                        vedge5 := 0;
                        vedge6 := 0;
                        vedge7 := 0;
                        vedge8 := 0;
                        vcorner1 := 0;
                        vcorner2 := 0;
                        vcorner3 := 0;
                        vcorner4 := 0;
                        vcorner5 := 0;
                        vcorner6 := 0;
                        vcorner7 := 0;
                        vcorner8 := 0;
                        vcorner9 := 0;
                        vcorner10 := 0;
                        vcorner11 := 0;
                        vcorner12 := 0;
                        vcorner13 := 0;
                        vcorner14 := 0;
                        vcorner15 := 0;
                        vcorner16 := 0;
                        vxcoord := 0;
                        vycoord := 0;
                        vradius := 0;
                        vwidth := 0;
                        vheight := 0;
                        c := c + 1;
                        vindex := c;
                        vsheet_inx := cf;
                        vtype := 6;
                        IF i = 1 THEN
                            vedge1 := 1;
                            vdescript := 'Pomniejszenie ramki D';
                        ELSIF i = 2 THEN
                            vedge2 := 1;
                            vdescript := 'Pomniejszenie ramki P';
                        ELSIF i = 3 THEN
                            vedge3 := 1;
                            vdescript := 'Pomniejszenie ramki G';
                        ELSIF i = 4 THEN
                            vedge4 := 1;
                            vdescript := 'Pomniejszenie ramki L';
                        END IF;

                        vwidth := vstep + vzm.uszcz_std;
                        vresult := vresult
                                   || '<BEA> '
                                   || lpad(vindex, 3, '0')
                                   || vsep
                                   || vsheet_inx
                                   || vsep
                                   || vfaceside
                                   || vsep
                                   || rpad(vdescript, 40)
                                   || vsep
                                   || lpad(vtype, 2, '0')
                                   || vsep
                                   || vedge1
                                   || vsep
                                   || vedge2
                                   || vsep
                                   || vedge3
                                   || vsep
                                   || vedge4
                                   || vsep
                                   || vedge5
                                   || vsep
                                   || vedge6
                                   || vsep
                                   || vedge7
                                   || vsep
                                   || vedge8
                                   || vsep
                                   || vcorner1
                                   || vsep
                                   || vcorner2
                                   || vsep
                                   || vcorner3
                                   || vsep
                                   || vcorner4
                                   || vsep
                                   || vcorner5
                                   || vsep
                                   || vcorner6
                                   || vsep
                                   || vcorner7
                                   || vsep
                                   || vcorner8
                                   || vsep
                                   || vcorner9
                                   || vsep
                                   || vcorner10
                                   || vsep
                                   || vcorner11
                                   || vsep
                                   || vcorner12
                                   || vsep
                                   || vcorner13
                                   || vsep
                                   || vcorner14
                                   || vsep
                                   || vcorner15
                                   || vsep
                                   || vcorner16
                                   || vsep
                                   || lpad(vxcoord, 5, '0')
                                   || vsep
                                   || lpad(vycoord, 5, '0')
                                   || vsep
                                   || lpad(vradius * 10, 5, '0')
                                   || vsep
                                   || lpad(vwidth * 10, 5, '0')
                                   || vsep
                                   || lpad(vheight * 10, 5, '0')
                                   || vsep2;

                    END IF;

                END LOOP;

            END IF;

        END LOOP;

        CLOSE c1;
        RETURN vresult;
    END bea;

    FUNCTION bth RETURN VARCHAR2 AS

        vresult      VARCHAR2(1000);
        vbth_info    VARCHAR2(10);
        vbcd_start   NUMBER(6);
        vbatch_no    NUMBER(8);
        vsep         CHAR;
    BEGIN
        vresult := ' ';
        vsep := ' ';
        vbth_info := ' ';
        vbcd_start := 0;
        vbatch_no := 0;
        vresult := '<BTH> '
                   || rpad(vbth_info, 10)
                   || vsep
                   || lpad(vbcd_start, 6, '0')
                   || vsep
                   || lpad(vbatch_no, 8, '0');

        RETURN vresult;
    END bth;

    FUNCTION elem (
        pnrkompzlec   NUMBER,
        pnrpoz        NUMBER,
        pnrelem       NUMBER
    ) RETURN VARCHAR2 AS

        CURSOR c1 IS
        SELECT
            *
        FROM
            v_zlec_mon vzm
        WHERE
            vzm.nr_kom_zlec = pnrkompzlec
            AND vzm.nr_poz = pnrpoz
            AND vzm.nr_el_wew = pnrelem;

        vzm                v_zlec_mon%rowtype;

--  vGrub number;
        vczypow            NUMBER;
--  vNrKat number;
        vczyorn            NUMBER;
        vznaczpr           VARCHAR2(4);
        voznramki          CHAR;
        vresult            VARCHAR2(1000);
        cg                 NUMBER;
        cf                 NUMBER;
        vglx_item_inx      NUMBER(5);
        vglx_descript      VARCHAR2(40);
        vglx_surface       NUMBER(1);
        vglx_thickness     NUMBER(5);
        vglx_face_side     NUMBER(1);
        vglx_ident         VARCHAR2(10);
        vglx_patt_dir      NUMBER(1);
        vglx_pane_bcd      VARCHAR2(10);
        vglx_prod_pane     NUMBER(1);
        vglx_prod_comp     NUMBER(2);
        vglx_category      NUMBER(2);
        vfrx_item_inx      NUMBER(5);
        vfrx_description   VARCHAR2(40);
        vfrx_type          NUMBER(2);
        vfrx_color         NUMBER(2);
        vfrx_width         NUMBER(5);
        vfrx_height        NUMBER(5);
        vfrx_ident         VARCHAR2(10);
        vsep               CHAR;
    BEGIN
        vresult := ' ';
        vsep := ' ';
        cg := 0;
        cf := 0;

-- Pobierz dane z widoku v_zlec_mon
        OPEN c1;
        LOOP
            FETCH c1 INTO vzm;
            EXIT WHEN c1%notfound;
            vczyorn := 0;

-- gdy warstwwa szkla
            IF pnrelem MOD 2 = 1 THEN
                cg := floor(pnrelem / 2) + 1;
                IF vzm.nr_kat > 0 THEN
                    SELECT
                        nvl(substr(k.naz_kat, 1, 40), ' '),
                        decode(substr(k.typ_kat, 2, 1), 'O', 1, 0),
                        k.znacz_pr
                    INTO
                        vglx_descript,
                        vczyorn,
                        vznaczpr
                    FROM
                        katalog k
                    WHERE
                        k.nr_kat = vzm.nr_kat;

                ELSE
                    vglx_descript := vzm.typ_kat
                                     || ' '
                                     || vzm.grub;
                END IF;

                vglx_item_inx := 0;
                IF vzm.powl > 0 OR vzm.powr > 0 THEN
                    vglx_surface := 1;
                ELSIF vczyorn = 1 THEN
                    vglx_surface := 2;
                ELSE
                    vglx_surface := 0;
                END IF;

                vglx_thickness := round(vzm.grub * 10);
                IF vzm.powl > 0 THEN
                    vglx_face_side := 2;
                ELSIF vzm.powr > 0 THEN
                    vglx_face_side := 1;
                ELSE
                    vglx_face_side := 0;
                END IF;

                vglx_ident := ' ';
                vglx_patt_dir := 0;
                vglx_pane_bcd := ' ';
                vglx_prod_pane := 0;
                vglx_prod_comp := 0;
                IF vzm.typ_kat = 'LAMINAT' OR vznaczpr = '9.La' THEN
                    vglx_category := 2;
                ELSE
                    vglx_category := 1;
                END IF;

                vresult := '<GL'
                           || cg
                           || '> '
                           || lpad(vglx_item_inx, 5, '0')
                           || vsep
                           || rpad(vglx_descript, 40)
                           || vsep
                           || vglx_surface
                           || vsep
                           || lpad(vglx_thickness, 5, '0')
                           || vsep
                           || vglx_face_side
                           || vsep
                           || rpad(vglx_ident, 10)
                           || vsep
                           || vglx_patt_dir
                           || vsep
                           || rpad(vglx_pane_bcd, 10)
                           || vsep
                           || vglx_prod_pane
                           || vsep
                           || lpad(vglx_prod_comp, 2, '0')
                           || vsep
                           || lpad(vglx_category, 2, '0');

            END IF;
-- gdy warstwa ramki

            IF pnrelem MOD 2 = 0 THEN
                vfrx_item_inx := 0;
                cg := floor(pnrelem / 2);
                IF vzm.nr_kat > 0 THEN
                    SELECT
                        nvl(substr(k.naz_kat, 1, 40), ' '),
                        nvl(grubosc * 10, 0),
                        nvl(bok_od * 10, 0)
                    INTO
                        vfrx_description,
                        vfrx_width,
                        vfrx_height
                    FROM
                        katalog k
                    WHERE
                        k.nr_kat = vzm.nr_kat;

                ELSE
                    vfrx_description := ' ';
                    vfrx_width := 0;
                    vfrx_height := 0;
                END IF;

                voznramki := substr(vzm.typ_kat, 2, 1);
                IF voznramki = 'A' THEN
                    vfrx_type := 0;
                ELSIF voznramki = 'C' THEN
                    vfrx_type := 0;
                ELSIF voznramki = 'E' THEN
                    vfrx_type := 0;
                ELSIF voznramki = 'G' THEN
                    vfrx_type := 3;
                ELSIF voznramki = 'H' THEN
                    vfrx_type := 0;
                ELSIF voznramki = 'M' THEN
                    vfrx_type := 0;
                ELSIF voznramki = 'N' THEN
                    vfrx_type := 0;
                ELSIF voznramki = 'P' THEN
                    vfrx_type := 0;
                ELSIF voznramki = 'S' THEN
                    vfrx_type := 3;
                ELSIF voznramki = 'T' THEN
                    vfrx_type := 0;
                ELSIF voznramki = 'W' THEN
                    vfrx_type := 0;
                ELSE
                    vfrx_type := 0;
                END IF;

                vfrx_color := 0;
                vfrx_ident := '0';
                vresult := '<FR'
                           || cg
                           || '> '
                           || lpad(vfrx_item_inx, 5, '0')
                           || vsep
                           || rpad(vfrx_description, 40)
                           || vsep
                           || lpad(vfrx_type, 2, '0')
                           || vsep
                           || lpad(vfrx_color, 2, '0')
                           || vsep
                           || lpad(vfrx_width, 5, '0')
                           || vsep
                           || lpad(vfrx_height, 5, '0')
                           || vsep
                           || rpad(vfrx_ident, 10);

            END IF;

        END LOOP;

        CLOSE c1;
        RETURN vresult;
    END elem;

    FUNCTION ord (
        pnrkompzlec NUMBER
    ) RETURN VARCHAR2 AS

        vresult      VARCHAR2(1000);
        vord         VARCHAR2(10);
        vcust_num    VARCHAR2(10);
        vcust_name   VARCHAR2(40);
        vtext1       VARCHAR2(40);
        vtext2       VARCHAR2(40);
        vtext3       VARCHAR2(40);
        vtext4       VARCHAR2(40);
        vtext5       VARCHAR2(40);
        vprd_date    VARCHAR2(10);
        vdel_date    VARCHAR2(10);
        vdel_area    VARCHAR2(10);
        vsep         CHAR;
    BEGIN
        vresult := ' ';
        vsep := ' ';
        SELECT
            z.nr_zlec   ord,
            z.nr_kon    cust_num,
            k.skrot_k   cust_nam,
            ' ' text1,
            ' ' text2,
            ' ' text3,
            ' ' text4,
            ' ' text5,
            to_char(z.d_plan, 'DD/MM/YYYY') prd_date,
            to_char(z.d_pl_sped, 'DD/MM/YYYY') del_date,
            ' ' del_area
        INTO
            vord,
            vcust_num,
            vcust_name,
            vtext1,
            vtext2,
            vtext3,
            vtext4,
            vtext5,
            vprd_date,
            vdel_date,
            vdel_area
        FROM
            zamow    z
            LEFT JOIN klient   k ON k.nr_kon = z.nr_kon
        WHERE
            z.nr_kom_zlec = pnrkompzlec;

        vresult := '<ORD> '
                   || rpad(vord, 10)
                   || vsep
                   || rpad(vcust_num, 10)
                   || vsep
                   || rpad(vcust_name, 40)
                   || vsep
                   || rpad(vtext1, 40)
                   || vsep
                   || rpad(vtext2, 40)
                   || vsep
                   || rpad(vtext3, 40)
                   || vsep
                   || rpad(vtext4, 40)
                   || vsep
                   || rpad(vtext5, 40)
                   || vsep
                   || rpad(vprd_date, 10)
                   || vsep
                   || rpad(vdel_date, 10)
                   || vsep
                   || rpad(vdel_area, 10);

        RETURN vresult;
    END ord;

    FUNCTION pos (
        pnrkompzlec   NUMBER,
        pnrpoz        NUMBER,
        pnrszt        NUMBER
    ) RETURN VARCHAR2 AS

        CURSOR c1 IS
        SELECT
            *
        FROM
            v_zlec_mon vzm
        WHERE
            vzm.nr_kom_zlec = pnrkompzlec
            AND vzm.nr_poz = pnrpoz;

        vzm          v_zlec_mon%rowtype;
        vgrub        NUMBER;
        vczypow      NUMBER;
        vnrkat       NUMBER;
        vczyorn      NUMBER;
        vresult      VARCHAR2(1000);
        TYPE glassa_t IS
            VARRAY(9) OF VARCHAR2(5);
        TYPE gasa_t IS
            VARRAY(4) OF NUMBER;
        glassa       glassa_t := glassa_t(' ', ' ', ' ', ' ', ' ',
         ' ', ' ', ' ', ' ');
        gasa         gasa_t := gasa_t(0, 0, 0, 0);
        c            NUMBER;
        vitem_num    NUMBER(5);
        vid_num      VARCHAR2(8);
        vbarcode     NUMBER(4);
        vqty         NUMBER(5);
        vwidth       NUMBER(5);
        vheight      NUMBER(5);
        vinset       NUMBER(3);
        vframe_txt   NUMBER(2);
        vseal_type   NUMBER(1);
        vfrah_type   NUMBER(1);
        vfrah_hoe    NUMBER(5);
        vpatt_dir    NUMBER(1);
        vdgu_pane    NUMBER(1);
        vsep         CHAR;
    BEGIN
        vresult := ' ';
        vsep := ' ';
        c := 0;

-- Pobierz dane z widoku v_zlec_mon
        OPEN c1;
        LOOP
            FETCH c1 INTO vzm;
            EXIT WHEN c1%notfound;
            c := c + 1;
            vczyorn := 0;
            glassa(c) := to_char(round(vzm.grub, 0));

-- gdy warstwwa szkla
            IF c MOD 2 = 1 THEN
                IF vzm.nr_kat > 0 THEN
                    SELECT
                        decode(substr(typ_kat, 2, 1), 'O', 1, 0)
                    INTO vczyorn
                    FROM
                        katalog
                    WHERE
                        nr_kat = vzm.nr_kat;

                END IF;

                IF vzm.powl > 0 OR vzm.powr > 0 THEN
                    glassa(c) := glassa(c)
                                 || '-1';
                ELSIF vczyorn = 1 THEN
                    glassa(c) := glassa(c)
                                 || '-2';
                ELSE
                    glassa(c) := glassa(c)
                                 || '-0';
                END IF;

            END IF;
-- gdy warstwa ramki

            IF c MOD 2 = 0 THEN
                IF vzm.gaz = 'A' THEN
                    gasa(c / 2) := 1;
                ELSIF vzm.gaz = 'K' THEN
                    gasa(c / 2) := 2;
                ELSE
                    gasa(c / 2) := 0;
                END IF;

                glassa(c) := substr(vzm.typ_kat, 2, 1)
                             || glassa(c);

                IF substr(vzm.ind_bud, 13, 1) = 1 THEN
                    vseal_type := 9;
                ELSIF vzm.silikon = 1 THEN
                    vseal_type := 1;
                ELSE
                    vseal_type := 0;
                END IF;

            END IF;

        END LOOP;

        CLOSE c1;
        SELECT
            p.nr_poz    item_num,
            k.rack_no   id_num,
            0 barcode,
            1 qty,
            p.szer      width,
            p.wys       height,
            decode(p.gr_sil, 0, 45, p.gr_sil * 10) inset,
            0 frame_txt,
            0 frah_type,
            0 frah_hoe,
            0 patt_dir,
            0 dgu_pane
        INTO
            vitem_num,
            vid_num,
            vbarcode,
            vqty,
            vwidth,
            vheight,
            vinset,
            vframe_txt,
            vfrah_type,
            vfrah_hoe,
            vpatt_dir,
            vdgu_pane
        FROM
            spisz          p
            LEFT JOIN struktury      s ON s.kod_str = p.kod_str
            LEFT JOIN kol_stojakow   k ON k.nr_komp_zlec = p.nr_kom_zlec
                                        AND k.nr_poz = p.nr_poz
                                        AND k.nr_sztuki = pnrszt
                                        AND k.nr_warstwy = 1
        WHERE
            p.nr_kom_zlec = pnrkompzlec
            AND p.nr_poz = pnrpoz;

        vresult := '<POS> '
                   || lpad(vitem_num, 5, '0')
                   || vsep
                   || rpad(vid_num, 8)
                   || vsep
                   || lpad(vbarcode, 4, '0')
                   || vsep
                   || lpad(vqty, 5, '0')
                   || vsep
                   || lpad(vwidth * 10, 5, '0')
                   || vsep
                   || lpad(vheight * 10, 5, '0')
                   || vsep
                   || rpad(glassa(1), 5)
                   || vsep
                   || rpad(glassa(2), 3)
                   || vsep
                   || rpad(glassa(3), 5)
                   || vsep
                   || rpad(glassa(4), 3)
                   || vsep
                   || rpad(glassa(5), 5)
                   || vsep
                   || rpad(glassa(6), 3)
                   || vsep
                   || rpad(glassa(7), 5)
                   || vsep
                   || rpad(glassa(8), 3)
                   || vsep
                   || rpad(glassa(9), 5)
                   || vsep
                   || lpad(vinset, 3, '0')
                   || vsep
                   || lpad(vframe_txt, 2, '0')
                   || vsep
                   || lpad(gasa(1), 2, '0')
                   || vsep
                   || lpad(gasa(2), 2, '0')
                   || vsep
                   || lpad(gasa(3), 2, '0')
                   || vsep
                   || lpad(gasa(4), 2, '0')
                   || vsep
                   || vseal_type
                   || vsep
                   || vfrah_type
                   || vsep
                   || lpad(vfrah_hoe, 5, '0')
                   || vsep
                   || vpatt_dir
                   || vsep
                   || vdgu_pane;

        RETURN vresult;
    END pos;

    FUNCTION rel RETURN VARCHAR2 AS

        vresult     VARCHAR2(1000);
        vrel_num    VARCHAR2(5);
        vrel_info   VARCHAR2(40);
        vsep        CHAR;
    BEGIN
        vresult := ' ';
        vsep := ' ';
        vrel_num := '02.80';
        vrel_info := 'SIP - Transfer Cutter 2000';
        vresult := '<REL> '
                   || rpad(vrel_num, 10)
                   || vsep
                   || rpad(vrel_info, 40);

        RETURN vresult;
    END rel;

    FUNCTION shp (
        pnrkompzlec   NUMBER,
        pnrpoz        NUMBER,
        pnrelem       NUMBER
    ) RETURN VARCHAR2 AS

        CURSOR c1 IS
        SELECT
            *
        FROM
            v_zlec_mon vzm
        WHERE
            vzm.nr_kom_zlec = pnrkompzlec
            AND vzm.nr_poz = pnrpoz
            AND vzm.nr_el_wew = pnrelem;

        vzm          v_zlec_mon%rowtype;
        vresult      VARCHAR2(1000);
        cg           NUMBER;
        vshp_pane    NUMBER(1) := 0;
        vshp_def     NUMBER(1) := 0;
        vshp_cat     NUMBER(1) := 0;
        vshp_num     NUMBER(3) := 0;
        vshp_len     NUMBER(5) := 0;
        vshp_len1    NUMBER(5) := 0;
        vshp_len2    NUMBER(5) := 0;
        vshp_hgt     NUMBER(5) := 0;
        vshp_hgt1    NUMBER(5) := 0;
        vshp_hgt2    NUMBER(5) := 0;
        vshp_rad     NUMBER(5) := 0;
        vshp_rad1    NUMBER(5) := 0;
        vshp_rad2    NUMBER(5) := 0;
        vshp_rad3    NUMBER(5) := 0;
        vshp_trim1   NUMBER(5) := 0;
        vshp_trim2   NUMBER(5) := 0;
        vshp_trim3   NUMBER(5) := 0;
        vshp_trim4   NUMBER(5) := 0;
        vshp_edge1   NUMBER(5) := 0;
        vshp_edge2   NUMBER(5) := 0;
        vshp_edge3   NUMBER(5) := 0;
        vshp_edge4   NUMBER(5) := 0;
        vshp_edge5   NUMBER(5) := 0;
        vshp_edge6   NUMBER(5) := 0;
        vshp_edge7   NUMBER(5) := 0;
        vshp_edge8   NUMBER(5) := 0;
        vshp_path    VARCHAR2(40) := ' ';
        vshp_file    VARCHAR2(40) := ' ';
        vshp_name    VARCHAR2(40) := ' ';
        vshp_mirr    NUMBER(1) := 0;
        vshp_base    NUMBER(1) := 0;
        vsep         CHAR;
    BEGIN
        vresult := ' ';
        vsep := ' ';
        cg := 0;

-- Pobierz dane z widoku v_zlec_mon
        OPEN c1;
        LOOP
            FETCH c1 INTO vzm;
            EXIT WHEN c1%notfound; 

-- gdy warstwwa szkla
            IF pnrelem MOD 2 = 1 THEN
                cg := floor(pnrelem / 2) + 1;
                vshp_pane := 0;
                vshp_def := 0;
                vshp_cat := 0;
                vshp_num := 0;
                vshp_len := 0;
                vshp_len1 := 0;
                vshp_len2 := 0;
                vshp_hgt := 0;
                vshp_hgt1 := 0;
                vshp_hgt2 := 0;
                vshp_rad := 0;
                vshp_rad1 := 0;
                vshp_rad2 := 0;
                vshp_rad3 := 0;
                vshp_trim1 := 0;
                vshp_trim2 := 0;
                vshp_trim3 := 0;
                vshp_trim4 := 0;
                vshp_edge1 := 0;
                vshp_edge2 := 0;
                vshp_edge3 := 0;
                vshp_edge4 := 0;
                vshp_edge5 := 0;
                vshp_edge6 := 0;
                vshp_edge7 := 0;
                vshp_edge8 := 0;
                vshp_path := ' ';
                vshp_file := ' ';
                vshp_name := ' ';
                vshp_mirr := 0;
                vshp_base := 0;
                vshp_pane := cg;
                IF cg = 1 THEN
                    vshp_def := 0;
                    vshp_len := nvl(vzm.szer, 0);
                    vshp_hgt := nvl(vzm.wys, 0);
                    IF ( to_number(strtoken(vzm.par_kszt, 2, ':'), '999') > 0 ) THEN
                        vshp_cat := to_number(strtoken(vzm.par_kszt, 1, ':'), '9');

                        vshp_num := to_number(strtoken(vzm.par_kszt, 2, ':'), '999');

                        vshp_len1 := to_number(strtoken(vzm.par_kszt, 4, ':'), '99999');

                        vshp_len2 := to_number(strtoken(vzm.par_kszt, 5, ':'), '99999');

                        vshp_hgt1 := to_number(strtoken(vzm.par_kszt, 7, ':'), '99999');

                        vshp_hgt2 := to_number(strtoken(vzm.par_kszt, 8, ':'), '99999');

                        vshp_rad := to_number(strtoken(vzm.par_kszt, 9, ':'), '99999');

                        vshp_rad1 := to_number(strtoken(vzm.par_kszt, 10, ':'), '99999');

                        vshp_rad2 := to_number(strtoken(vzm.par_kszt, 11, ':'), '99999');

                        vshp_rad3 := to_number(strtoken(vzm.par_kszt, 12, ':'), '99999');

                    END IF;

                ELSE
                    vshp_def := 2;
--        vSHP_EDGE1 := Abs(vzm.max_stepD-vzm.stepD);
--        vSHP_EDGE2 := Abs(vzm.max_stepP-vzm.stepP);
--        vSHP_EDGE3 := Abs(vzm.max_stepG-vzm.stepG);
--        vSHP_EDGE4 := Abs(vzm.max_stepL-vzm.stepL);
--        vSHP_EDGE1 := -vzm.stepD;
--        vSHP_EDGE2 := -vzm.stepP;
--        vSHP_EDGE3 := -vzm.stepG;
--        vSHP_EDGE4 := -vzm.stepL;
                    vshp_edge1 := abs(-vzm.stepd);
                    vshp_edge2 := abs(-vzm.stepp);
                    vshp_edge3 := abs(-vzm.stepg);
                    vshp_edge4 := abs(-vzm.stepl);
                END IF;

                vresult := '<SHP> '
                           || vshp_pane
                           || vsep
                           || vshp_def
                           || vsep
                           || vshp_cat
                           || vsep
                           || lpad(vshp_num, 3, '0')
                           || vsep
                           || lpad(vshp_len * 10, 5, '0')
                           || vsep
                           || lpad(vshp_len1 * 10, 5, '0')
                           || vsep
                           || lpad(vshp_len2 * 10, 5, '0')
                           || vsep
                           || lpad(vshp_hgt * 10, 5, '0')
                           || vsep
                           || lpad(vshp_hgt1 * 10, 5, '0')
                           || vsep
                           || lpad(vshp_hgt2 * 10, 5, '0')
                           || vsep
                           || lpad(vshp_rad * 10, 5, '0')
                           || vsep
                           || lpad(vshp_rad1 * 10, 5, '0')
                           || vsep
                           || lpad(vshp_rad2 * 10, 5, '0')
                           || vsep
                           || lpad(vshp_rad3 * 10, 5, '0')
                           || vsep
                           || lpad(vshp_trim1 * 10, 5, '0')
                           || vsep
                           || lpad(vshp_trim2 * 10, 5, '0')
                           || vsep
                           || lpad(vshp_trim3 * 10, 5, '0')
                           || vsep
                           || lpad(vshp_trim4 * 10, 5, '0')
                           || vsep
                           || lpad(vshp_edge1 * 10, 5, ' ')
                           || vsep
                           || lpad(vshp_edge2 * 10, 5, ' ')
                           || vsep
                           || lpad(vshp_edge3 * 10, 5, ' ')
                           || vsep
                           || lpad(vshp_edge4 * 10, 5, ' ')
                           || vsep
                           || lpad(vshp_edge5 * 10, 5, ' ')
                           || vsep
                           || lpad(vshp_edge6 * 10, 5, ' ')
                           || vsep
                           || lpad(vshp_edge7 * 10, 5, ' ')
                           || vsep
                           || lpad(vshp_edge8 * 10, 5, ' ')
                           || vsep
                           || rpad(vshp_path, 40)
                           || vsep
                           || rpad(vshp_file, 40)
                           || vsep
                           || rpad(vshp_name, 40)
                           || vsep
                           || vshp_mirr
                           || vsep
                           || vshp_base;

            END IF;

        END LOOP;

        CLOSE c1;
        RETURN vresult;
    END shp;

END pkg_liprod280;
/
