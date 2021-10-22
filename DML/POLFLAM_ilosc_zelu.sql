--SPRAWDZENIE WAGI
select nr_zlec, nr_poz, waga,  (select round(pow*waga,3) from spisz P, struktury S where P.nr_kom_zlec=E.nr_komp_zlec and P.nr_poz=E.nr_poz and S.kod_str=P.kod_str) waga_wyl
from spise E
where waga<>(select round(pow*waga,3) from spisz P, struktury S where P.nr_kom_zlec=E.nr_komp_zlec and P.nr_poz=E.nr_poz and S.kod_str=P.kod_str)
order by nr_zlec desc, nr_poz;

--POPRAWA WAGI w zleceniach z blêdn¹ wag¹
update spise E
set waga=(select pow*waga from spisz P, struktury S where P.nr_kom_zlec=E.nr_komp_zlec and P.nr_poz=E.nr_poz and S.kod_str=P.kod_str)
where nr_zlec in 
(select distinct nr_zlec
from spise E
where waga<>(select round(pow*waga,3) from spisz P, struktury S where P.nr_kom_zlec=E.nr_komp_zlec and P.nr_poz=E.nr_poz and S.kod_str=P.kod_str));

--SPRAWDZENIE poprawnoœci zapisanej iloœci ¿elu
select P.nr_kom_zlec, P.nr_zlec, P.nr_poz, szer, wys, pow, ZESP.wsp, pow*ZESP.wsp,
       T.linia, replace(to_char(pow*ZESP.wsp,'999.999999'),'.',','),
       to_number(replace(T.linia,',','.'),'999.999999') dm3_zap,
       ilosc, ilosc-(select count(1) from spise E where E.nr_komp_zlec=P.nr_kom_zlec and E.nr_poz=P.nr_poz and zn_wyk in (1,2,9)) il_do_wyk,
       P.pow*S.waga, (select min(waga) from spise E where E.nr_komp_zlec=P.nr_kom_zlec and E.nr_poz=P.nr_poz) E_waga,
       P.kod_str, ZESP.nr_kom_str nr_ZESP, ZESP.kod_str kod_ZESP,
       B1.nr_kom_str,B2.nr_kom_str,B3.nr_kom_str,B4.nr_kom_str
from spisz P
left join struktury S on S.kod_str=P.kod_str
left join zlec_typ T on T.nr_komp_zlec=P.nr_kom_zlec and T.nr_poz=P.nr_poz and T.typ=201
left join budstr B on B.kod_str=P.kod_str and B.zn_war='Str'
left join budstr B1 on B1.nr_kom_str=B.nr_kom_skl and B.zn_war='Str' and B1.zn_war='Str'
left join budstr B2 on B2.nr_kom_str=B1.nr_kom_skl and B1.zn_war='Str' and B2.zn_war='Str'
left join budstr B3 on B3.nr_kom_str=B2.nr_kom_skl and B2.zn_war='Str' and B3.zn_war='Str'
left join budstr B4 on B4.nr_kom_str=B3.nr_kom_skl and B3.zn_war='Str' and B4.zn_war='Str'
left join budstr ZESP on ZESP.nr_kom_str in (B1.nr_kom_skl,B2.nr_kom_skl,B3.nr_kom_skl,B4.nr_kom_str) and ZESP.typ_str='ZE' and ZESP.zn_war='Sur'
--where (P.kod_str like '%PTW22S\HZ\MRW%' or P.kod_str in '%PTW25S\HZ\MRW%' or P.kod_str like '%PTW30S\HZ\MRW%')
where ZESP.nr_kom_skl=6100 
  and pow*ZESP.wsp<>to_number(replace(T.linia,',','.'),'999.999999')
 -- and P.nr_zlec=7074 and P.nr_poz=1
order by P.nr_zlec desc, P.nr_poz;


--POPRAWA ILOSCI HYDROZELU
update zlec_typ
set linia=(select replace(to_char(pow*ZESP.wsp,'999.999999'),'.',',')
       --T.linia,
--       to_number(replace(T.linia,',','.'),'999.999999') dm3_zap,
--       ilosc, ilosc-(select count(1) from spise E where E.nr_komp_zlec=P.nr_kom_zlec and E.nr_poz=P.nr_poz and zn_wyk in (1,2,9)) il_do_wyk,
--       P.pow*S.waga, (select min(waga) from spise E where E.nr_komp_zlec=P.nr_kom_zlec and E.nr_poz=P.nr_poz) E_waga,
--       P.kod_str, ZESP.nr_kom_str nr_ZESP, ZESP.kod_str kod_ZESP
        from spisz P
        left join struktury S on S.kod_str=P.kod_str
        left join zlec_typ T on T.nr_komp_zlec=P.nr_kom_zlec and T.nr_poz=P.nr_poz and T.typ=201
        left join budstr B on B.kod_str=P.kod_str and B.zn_war='Str'
        left join budstr B1 on B1.nr_kom_str=B.nr_kom_skl and B.zn_war='Str' and B1.zn_war='Str'
        left join budstr B2 on B2.nr_kom_str=B1.nr_kom_skl and B1.zn_war='Str' and B2.zn_war='Str'
        left join budstr B3 on B3.nr_kom_str=B2.nr_kom_skl and B2.zn_war='Str' and B3.zn_war='Str'
        left join budstr B4 on B4.nr_kom_str=B3.nr_kom_skl and B3.zn_war='Str' and B4.zn_war='Str'
        left join budstr ZESP on ZESP.nr_kom_str in (B1.nr_kom_skl,B2.nr_kom_skl,B3.nr_kom_skl,B4.nr_kom_str) and ZESP.typ_str='ZE' and ZESP.zn_war='Sur'
        where P.nr_kom_zlec=zlec_typ.nr_komp_zlec and P.nr_poz=zlec_typ.nr_poz
          and ZESP.nr_kom_skl=6100)
where (nr_komp_zlec, nr_poz, typ) in 
(select distinct P.nr_kom_zlec, P.nr_poz, 201-- szer, wys, pow, ZESP.wsp, pow*ZESP.wsp,
       --T.linia,
--       to_number(replace(T.linia,',','.'),'999.999999') dm3_zap,
--       ilosc, ilosc-(select count(1) from spise E where E.nr_komp_zlec=P.nr_kom_zlec and E.nr_poz=P.nr_poz and zn_wyk in (1,2,9)) il_do_wyk,
--       P.pow*S.waga, (select min(waga) from spise E where E.nr_komp_zlec=P.nr_kom_zlec and E.nr_poz=P.nr_poz) E_waga,
--       P.kod_str, ZESP.nr_kom_str nr_ZESP, ZESP.kod_str kod_ZESP
from spisz P
left join struktury S on S.kod_str=P.kod_str
left join zlec_typ T on T.nr_komp_zlec=P.nr_kom_zlec and T.nr_poz=P.nr_poz and T.typ=201
left join budstr B on B.kod_str=P.kod_str and B.zn_war='Str'
left join budstr B1 on B1.nr_kom_str=B.nr_kom_skl and B.zn_war='Str' and B1.zn_war='Str'
left join budstr B2 on B2.nr_kom_str=B1.nr_kom_skl and B1.zn_war='Str' and B2.zn_war='Str'
left join budstr B3 on B3.nr_kom_str=B2.nr_kom_skl and B2.zn_war='Str' and B3.zn_war='Str'
left join budstr B4 on B4.nr_kom_str=B3.nr_kom_skl and B3.zn_war='Str' and B4.zn_war='Str'
left join budstr ZESP on ZESP.nr_kom_str in (B1.nr_kom_skl,B2.nr_kom_skl,B3.nr_kom_skl,B4.nr_kom_str) and ZESP.typ_str='ZE' and ZESP.zn_war='Sur'
where ZESP.nr_kom_skl=6100
  and P.pow*ZESP.wsp<>to_number(replace(T.linia,',','.'),'999.999999'));

