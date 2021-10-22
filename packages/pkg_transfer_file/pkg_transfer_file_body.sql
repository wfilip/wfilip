--------------------------------------------------------
--  DDL for Package Body PKG_TRANSFER_FILE
--------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY "PKG_TRANSFER_FILE" AS

    FUNCTION get_text (
        pnrkompzlec   NUMBER,
        pnrpoz        NUMBER,
        pnrszt        NUMBER,
        pnrwar        NUMBER
    ) RETURN VARCHAR2 AS
        vtxt      VARCHAR2(1000);
        vnrzlec   NUMBER;
    BEGIN
        SELECT
            napis
        INTO vtxt
        FROM
            napisy_szyb_warstwy
        WHERE
            nr_kom_zlec = pnrkompzlec
            AND nr_poz = pnrpoz
            AND nr_szt = pnrszt
            AND nr_war = pnrwar;

        vtxt := replace(vtxt, '%DATE%', to_char(sysdate(), 'DD-MM-YYYY'));

        vtxt := replace(vtxt, '\', '/');
--  select nr_zlec into vNrZlec from zamow where nr_kom_zlec=pNrKompZlec;
--  vTXT := to_char(vNrZlec,'99999999')||' '||to_char(pNrPoz,'999')||' ###';
        RETURN vtxt;
    END;

    FUNCTION get_cutframe_text (
        pnrkompzlec   NUMBER,
        pnrpoz        NUMBER,
        pnrszt        NUMBER,
        pnrwar        NUMBER
    ) RETURN VARCHAR2 AS
        vtxt      VARCHAR2(1000);
        vnrzlec   NUMBER;
    BEGIN
        SELECT
            nr_zlec
        INTO vnrzlec
        FROM
            zamow
        WHERE
            nr_kom_zlec = pnrkompzlec;

        vtxt := 'Z:'
                || trim(to_char(vnrzlec, '99999999'))
                || ' P:'
                || trim(to_char(pnrpoz, '999'))
                || ' S:'
                || trim(to_char(pnrszt, '999'))
                || ' W:'
                || trim(to_char(pnrwar, '999'))
                || ' @@@';

        RETURN vtxt;
    END;

    FUNCTION spacer_forel_position (
        pdeviceid     NUMBER,
        pnrkompzlec   NUMBER,
        pnrpoz        NUMBER,
        pnrszt        NUMBER,
        pnrwar        NUMBER
    ) RETURN VARCHAR2 AS

        vresult   VARCHAR2(20000);
        vlinia    VARCHAR2(20000);
        vnrzlec   NUMBER;
        vsep      CHAR;
        vsep2     VARCHAR2(2);
        vnrwar    NUMBER;
        CURSOR c1 IS
        SELECT
            d.do_war
        FROM
            spisd     d
            LEFT JOIN katalog   k ON k.nr_kat = d.nr_kat
        WHERE
            d.nr_kom_zlec = pnrkompzlec
            AND d.nr_poz = pnrpoz
            AND d.strona = 0
            AND k.rodz_sur IN (
                'TAF',
                'POL'
            )
        ORDER BY
            d.do_war;

    BEGIN
        vresult := ' ';
        vsep := ';';
        vsep2 := chr(13)
                 || chr(10);
        SELECT
            forel240_pan(pdeviceid, pnrkompzlec, pnrpoz, pnrszt)
        INTO vlinia
        FROM
            dual;

        IF length(trim(vlinia)) > 0 THEN
            vresult := vlinia;
        END IF;

        IF pnrwar = 0 THEN
            SELECT
                forel240_shp3(pdeviceid, pnrkompzlec, pnrpoz, 1)
            INTO vlinia
            FROM
                dual;

            IF length(trim(vlinia)) > 0 THEN
                vresult := vresult
                           || vsep2
                           || vlinia;
            END IF;

            OPEN c1;
            LOOP
                FETCH c1 INTO vnrwar;
                EXIT WHEN c1%notfound;
                SELECT
                    forel240_elem(pdeviceid, pnrkompzlec, pnrpoz, vnrwar)
                INTO vlinia
                FROM
                    dual;

                IF length(trim(vlinia)) > 0 THEN
                    vresult := vresult
                               || vsep2
                               || vlinia;
                END IF;

                SELECT
                    forel240_pro(pdeviceid, pnrkompzlec, pnrpoz, vnrwar)
                INTO vlinia
                FROM
                    dual;

                IF length(trim(vlinia)) > 0 THEN
                    vresult := vresult
                               || vsep2
                               || vlinia;
                END IF;

                IF vnrwar > 1 THEN
                    SELECT
                        forel240_txt(pdeviceid, pnrkompzlec, pnrpoz, pnrszt, vnrwar)
                    INTO vlinia
                    FROM
                        dual;

                END IF;

                IF length(trim(vlinia)) > 0 THEN
                    vresult := vresult
                               || vsep2
                               || vlinia;
                END IF;

            END LOOP;

            CLOSE c1;
        END IF;

        RETURN vresult;
    END;

    FUNCTION spacer_forel_layer (
        pdeviceid     NUMBER,
        pnrkompzlec   NUMBER,
        pnrpoz        NUMBER,
        pnrszt        NUMBER,
        pnrwar        NUMBER
    ) RETURN VARCHAR2 AS

        vresult                VARCHAR2(20000);
        vlinia                 VARCHAR2(20000);
        vzm                    v_zlec_mon%rowtype;
        CURSOR c1 IS
        SELECT
            *
        FROM
            v_zlec_mon
        WHERE
            nr_kom_zlec = pnrkompzlec
            AND nr_poz = pnrpoz
            AND nr_el_wew = pnrwar;

        vnrzlec                NUMBER;
        vsep2                  VARCHAR2(2);
        vrozneuszcz            NUMBER;
        vnrksztaltu            NUMBER;
-- declare PAN variables
        vpan_item_num          NUMBER(5);
        vpan_id_num            VARCHAR2(10);
        vpan_barcode           VARCHAR2(10);
        vpan_qty               NUMBER(5);
        vpan_width             NUMBER(5);
        vpan_height            NUMBER(5);
        vpan_pane1             NUMBER(5);
        vpan_spacer1           NUMBER(5);
        vpan_pane2             NUMBER(5);
        vpan_spacer2           NUMBER(5);
        vpan_pane3             NUMBER(5);
        vpan_spacer3           NUMBER(5);
        vpan_pane4             NUMBER(5);
        vpan_seal_inset        NUMBER(3);
        vpan_gas_spacer1       NUMBER(1);
        vpan_gas_spacer2       NUMBER(1);
        vpan_gas_spacer3       NUMBER(1);
        vpan_seal_code         NUMBER(1);
        vpan_spacer_type       NUMBER(1);
        vpan_spacer_height     NUMBER(5);
        vpan_shape             NUMBER(5);
        vpan_heavy_pane        NUMBER(1);
        vpan_rack_info         VARCHAR2(10);
        vpan_ig_pane_reverse   NUMBER(1);
-- declare SHP variables
        vparamkszt             VARCHAR2(200);
        vshp_path              VARCHAR2(40) := ' ';
        vshp_file              VARCHAR2(40) := ' ';
        vshp_name              VARCHAR2(40) := ' ';
        vshp_cat               NUMBER(1) := 0;
        vshp_num               NUMBER(3) := 0;
        vshp_l                 NUMBER(5) := 0;
        vshp_l1                NUMBER(5) := 0;
        vshp_l2                NUMBER(5) := 0;
        vshp_h                 NUMBER(5) := 0;
        vshp_h1                NUMBER(5) := 0;
        vshp_h2                NUMBER(5) := 0;
        vshp_r                 NUMBER(5) := 0;
        vshp_r1                NUMBER(5) := 0;
        vshp_r2                NUMBER(5) := 0;
        vshp_r3                NUMBER(5) := 0;
        vshp_mirr              NUMBER(1) := 0;
        vshp_base              NUMBER(1) := 0;
-- declare CMx variables
        vcm_pane_descript      VARCHAR2(100);
        vcm_id_num             VARCHAR(10);
        vcm_pane_barcode       VARCHAR2(20);
        vcm_pane_type          NUMBER(1);
        vcm_pane_code          VARCHAR2(20);
        vcm_pane_thickness     NUMBER(5);
        vcm_pane_width         NUMBER(5);
        vcm_pane_height        NUMBER(5);
        vcm_pane_faceside      NUMBER(1);
        vcm_pane_rack_info     VARCHAR2(10);
        vcm_sp_descript        VARCHAR2(100);
        vcm_sp_type            NUMBER(1);
        vcm_sp_code            VARCHAR2(20);
        vcm_sp_width           NUMBER(5);
        vcm_sp_height          NUMBER(5);
        vcm_sp_inset           NUMBER(5);
        vcm_sp_rack_info       VARCHAR2(10);
        vcm_sp_gascode         NUMBER(1);
        vcm_sp_seal_type       NUMBER(1);
        vl                     NUMBER(10, 4);
        vl1                    NUMBER(10, 4);
        vl2                    NUMBER(10, 4);
        vh                     NUMBER(10, 4);
        vh1                    NUMBER(10, 4);
        vh2                    NUMBER(10, 4);
        vr                     NUMBER(10, 4);
        vr1                    NUMBER(10, 4);
        vr2                    NUMBER(10, 4);
        vr3                    NUMBER(10, 4);
    BEGIN
        vresult := ' ';
        vsep2 := chr(13)
                 || chr(10);

-- initializing PAN variables
        vpan_item_num := 0;
        vpan_id_num := '';
        vpan_barcode := '';
        vpan_qty := 0;
        vpan_width := 0;
        vpan_height := 0;
        vpan_pane1 := 0;
        vpan_spacer1 := 0;
        vpan_pane2 := 0;
        vpan_spacer2 := 0;
        vpan_pane3 := 0;
        vpan_spacer3 := 0;
        vpan_pane4 := 0;
        vpan_seal_inset := 0;
        vpan_gas_spacer1 := 0;
        vpan_gas_spacer2 := 0;
        vpan_gas_spacer3 := 0;
        vpan_seal_code := 0;
        vpan_spacer_type := 0;
        vpan_spacer_height := 0;
        vpan_shape := 0;
        vpan_heavy_pane := 0;
        vpan_rack_info := '';
        vpan_ig_pane_reverse := 0;
-- initializing SHP variables  
        vshp_path := '';
        vshp_file := '';
        vshp_name := '';
        vshp_mirr := 0;
        vshp_base := 0;
-- initializing CMx variables
        vcm_pane_code := '';
        vcm_id_num := '';
        vcm_sp_gascode := 1;
        vcm_sp_seal_type := 1;
        vcm_pane_faceside := 0;
        vcm_pane_rack_info := ' ';
        vrozneuszcz := 0;
-- open cursor
        OPEN c1;
        FETCH c1 INTO vzm;
--PAN    
        vpan_pane1 := 4;
        vpan_spacer1 := round(vzm.grub, 0);
        vpan_pane2 := 4;
        IF vzm.gaz = 'A' THEN
            vpan_gas_spacer1 := 1;
        ELSIF vzm.gaz = 'K' THEN
            vpan_gas_spacer1 := 2;
        ELSE
            vpan_gas_spacer1 := 0;
        END IF;

        IF substr(vzm.ind_bud, 13, 1) = 1 THEN
            vpan_seal_code := 3;
        ELSIF vzm.silikon = 1 THEN
            vpan_seal_code := 2;
        ELSE
            vpan_seal_code := 1;
        END IF;

        IF vzm.uszcz_rozne > 0 THEN
            vrozneuszcz := 1;
        END IF;

        IF vzm.nr_kat > 0 THEN
            SELECT
                nvl(substr(k.naz_kat, 1, 40), ' '),
                nvl(floor(grubosc) * 10, 0),
                nvl(bok_od * 10, 0)
            INTO
                vcm_sp_descript,
                vcm_sp_width,
                vcm_sp_height
            FROM
                katalog k
            WHERE
                k.nr_kat = vzm.nr_kat;

        ELSE
            vcm_sp_descript := ' ';
            vcm_sp_width := 0;
            vcm_sp_height := 0;
        END IF;

        vcm_sp_code := vzm.typ_kat;
        IF vzm.szpros > 0 THEN
            vcm_sp_code := vcm_sp_code || '(SZ)';
        END IF;
        CLOSE c1;
        SELECT
            p.nr_poz item_num,
            (
                SELECT
                    MAX(k.rack_no)
                FROM
                    kol_stojakow k
                WHERE
                    k.nr_komp_zlec = p.nr_kom_zlec
                    AND k.nr_poz = p.nr_poz
                    AND k.nr_sztuki = pnrszt
                    AND k.nr_warstwy = pnrwar - 1
            ) id_num,
            0 barcode,
            1 qty,
            decode(p.gr_sil, 0, 4.5, p.gr_sil) inset,
            decode(p.nr_kszt, 0, 0, 1),
            szer,
            wys
        INTO
            vpan_item_num,
            vpan_id_num,
            vpan_barcode,
            vpan_qty,
            vpan_seal_inset,
            vnrksztaltu,
            vpan_width,
            vpan_height
        FROM
            spisz       p
            LEFT JOIN struktury   s ON s.kod_str = p.kod_str
        WHERE
            p.nr_kom_zlec = pnrkompzlec
            AND p.nr_poz = pnrpoz;


        vcm_pane_width := vpan_width;
        vcm_pane_height := vpan_height;

        vpan_shape := 0;
        IF vrozneuszcz > 0 OR vnrksztaltu > 0 THEN
            vpan_shape := 1;
        END IF;
        
        vCM_SP_INSET := vPAN_SEAL_INSET;
        
        SELECT
            pkg_forel240.pan(vpan_item_num, vpan_id_num, vpan_barcode, vpan_qty, vpan_width,
                             vpan_height, vpan_pane1, vpan_spacer1, vpan_pane2, vpan_spacer2,
                             vpan_pane3, vpan_spacer3, vpan_pane4, vpan_seal_inset, vpan_gas_spacer1,
                             vpan_gas_spacer2, vpan_gas_spacer3, vpan_seal_code, vpan_spacer_type, vpan_spacer_height,
                             vpan_shape, vpan_heavy_pane, vpan_rack_info, vpan_ig_pane_reverse)
        INTO vlinia
        FROM
            dual;

        IF length(trim(vlinia)) > 0 THEN
            vresult := vlinia;
        END IF;

        SELECT
            strtoken(MAX(param_kszt), 1, ';')
        INTO vparamkszt
        FROM
            napisy_szyb_warstwy
        WHERE
            nr_kom_zlec = pnrkompzlec
            AND nr_poz = pnrpoz
            AND nr_szt = 1
            AND nr_war = pnrwar - 1;

        IF to_number(strtoken(vparamkszt, 2, ':')) > 0 THEN
            vshp_cat := 0;
            IF pdeviceid = 0 THEN
                vshp_cat := 1;
            END IF;
            vshp_num := to_number(strtoken(vparamkszt, 2, ':'), '999');
            vshp_l := to_number(strtoken(vparamkszt, 3, ':'), '99999');
            vshp_l1 := to_number(strtoken(vparamkszt, 4, ':'), '99999');
            vshp_l2 := to_number(strtoken(vparamkszt, 5, ':'), '99999');
            vshp_h := to_number(strtoken(vparamkszt, 6, ':'), '99999');
            vshp_h1 := to_number(strtoken(vparamkszt, 7, ':'), '99999');
            vshp_h2 := to_number(strtoken(vparamkszt, 8, ':'), '99999');
            vshp_r := to_number(strtoken(vparamkszt, 9, ':'), '99999');
            vshp_r1 := to_number(strtoken(vparamkszt, 10, ':'), '99999');
            vshp_r2 := to_number(strtoken(vparamkszt, 11, ':'), '99999');
            vshp_r3 := to_number(strtoken(vparamkszt, 12, ':'), '99999');
            IF ( vshp_num IN (
                64,
                66,
                67,
                68,
                70,
                71
            ) ) THEN
                vshp_r1 := vshp_r;
                vshp_r := 0;
            END IF;

            IF ( vshp_num = 51 ) THEN
                vshp_num := 25;
                vl := vshp_l;
                vl1 := vshp_l1;
                vl2 := vshp_l2;
                vl1 := ( power(vl1, 2) - power(vl2, 2) + power(vl, 2) ) / ( 2 * vl );

                vh := power(power(vl2, 2) - power(vl - vl1, 2), 0.5);

                vshp_l1 := round(vl1);
                vshp_l2 := 0;
                vshp_h := round(vh);
                vshp_h1 := 0;
                vshp_h2 := 0;
                vshp_r := 0;
                vshp_r1 := 0;
                vshp_r2 := 0;
                vshp_r3 := 0;
            END IF;

            SELECT
                pkg_forel240.shp(vshp_path, vshp_file, vshp_name, vshp_cat, vshp_num,
                                 vshp_l, vshp_l1, vshp_l2, vshp_h, vshp_h1,
                                 vshp_h2, vshp_r, vshp_r1, vshp_r2, vshp_r3,
                                 vshp_mirr, vshp_base)
            INTO vlinia
            FROM
                dual;

            IF length(trim(vlinia)) > 0 THEN
                vresult := vresult
                           || vsep2
                           || vlinia;
            END IF;

        END IF;

        SELECT
            pkg_forel240.cm(1, '', '', '', 0,
                            '', '', vcm_pane_width, vcm_pane_height, 0,
                            '', '', 0, '', 0,
                            0, 0, '', 0, 0)
        INTO vlinia
        FROM
            dual;

        IF length(trim(vlinia)) > 0 THEN
            vresult := vresult
                       || vsep2
                       || vlinia;
        END IF;

        SELECT
            pkg_forel240.cm(2, vcm_pane_descript, vcm_id_num, vcm_pane_barcode, 0,
                            vcm_pane_code, vcm_pane_thickness, vcm_pane_width, vcm_pane_height, vcm_pane_faceside,
                            vcm_pane_rack_info, vcm_sp_descript, vcm_sp_type, vcm_sp_code, vcm_sp_width,
                            vcm_sp_height, vcm_sp_inset, vcm_sp_rack_info, vcm_sp_gascode, vcm_sp_seal_type)
        INTO vlinia
        FROM
            dual;

        IF length(trim(vlinia)) > 0 THEN
            vresult := vresult
                       || vsep2
                       || vlinia;
        END IF;

        select pkg_forel240.generate_pro(pDeviceId,pNrKompZlec,pNrPoz,pNrWar) into vLinia from dual;
        if length(trim(vLinia))>0 then
            vResult := vResult||vSep2||vlinia;
        end if;

--  select pkg_forel240.txt(get_text(pNrKompZlec,pNrPoz,pNrSzt,pNrWar-1)) into vLinia from dual;

        SELECT
            pkg_forel240.txt(get_cutframe_text(pnrkompzlec, pnrpoz, pnrszt, pnrwar - 1))
        INTO vlinia
        FROM
            dual;

        IF length(trim(vlinia)) > 0 THEN
            vresult := vresult
                       || vsep2
                       || vlinia;
        END IF;

        RETURN vresult;
    END;

    FUNCTION spacer_order_header (
        pdeviceid     NUMBER,
        pnrkompzlec   NUMBER
    ) RETURN VARCHAR2 AS

        vresult      VARCHAR2(20000);
        vord_num     VARCHAR2(100);
        vcust_num    VARCHAR2(100);
        vcust_name   VARCHAR2(100);
        vprod_date   VARCHAR2(100);
        vdel_date    VARCHAR2(100);
    BEGIN
        SELECT
            z.nr_zlec   ord,
            z.nr_kon    cust_num,
            k.skrot_k   cust_nam,
            to_char(z.d_plan, 'DD/MM/YYYY') prd_date,
            to_char(z.d_pl_sped, 'DD/MM/YYYY') del_date
        INTO
            vord_num,
            vcust_num,
            vcust_name,
            vprod_date,
            vdel_date
        FROM
            zamow    z
            LEFT JOIN klient   k ON k.nr_kon = z.nr_kon
        WHERE
            z.nr_kom_zlec = pnrkompzlec;

        vresult := ' ';
        CASE pdeviceid
            WHEN 0 THEN
                SELECT
                    pkg_forel240.ord(vord_num, vcust_num, vcust_name, '', '',
                                     '', '', '', vprod_date, vdel_date,
                                     '')
                INTO vresult
                FROM
                    dual;

            WHEN 1 THEN
                SELECT
                    pkg_forel240.ord(vord_num, vcust_num, vcust_name, '', '',
                                     '', '', '', vprod_date, vdel_date,
                                     '')
                INTO vresult
                FROM
                    dual;

            WHEN 2 THEN
                SELECT
                    pkg_forel240.ord(vord_num, vcust_num, vcust_name, '', '',
                                     '', '', '', vprod_date, vdel_date,
                                     '')
                INTO vresult
                FROM
                    dual;

        END CASE;

        RETURN vresult;
    END spacer_order_header;

    FUNCTION spacer_file_header (
        pdeviceid NUMBER
    ) RETURN VARCHAR2 AS
        vresult VARCHAR2(2000);
    BEGIN
        vresult := ' ';
        CASE pdeviceid
            WHEN 0 THEN
                SELECT
                    pkg_forel240.ver(0)
                INTO vresult
                FROM
                    dual;

            WHEN 1 THEN
                SELECT
                    pkg_forel240.ver(0)
                INTO vresult
                FROM
                    dual;

            WHEN 2 THEN
                SELECT
                    pkg_forel240.ver(0)
                INTO vresult
                FROM
                    dual;

        END CASE;

        RETURN vresult;
    END spacer_file_header;

    FUNCTION spacer_position (
        pdeviceid     NUMBER,
        pnrkompzlec   NUMBER,
        pnrpoz        NUMBER,
        pnrszt        NUMBER,
        pnrwar        NUMBER
    ) RETURN VARCHAR2 AS
        vresult VARCHAR2(20000);
    BEGIN
        vresult := ' ';
        CASE pdeviceid
            WHEN 0 THEN
                vresult := spacer_forel_position(pdeviceid, pnrkompzlec, pnrpoz, pnrszt, pnrwar);
            WHEN 1 THEN
                vresult := spacer_forel_position(pdeviceid, pnrkompzlec, pnrpoz, pnrszt, pnrwar);
            WHEN 2 THEN
                vresult := spacer_forel_layer(pdeviceid, pnrkompzlec, pnrpoz, pnrszt, pnrwar);
        END CASE;

        RETURN vresult;
    END spacer_position;

END pkg_transfer_file;
/
