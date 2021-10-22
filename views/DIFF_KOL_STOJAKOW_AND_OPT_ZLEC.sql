CREATE OR REPLACE VIEW DIFF_KOL_STOJAKOW_AND_OPT_ZLEC AS
select nr_listy, nr_katalog, typ_katalog, max(Z.nr_zlec) nr_zlec, nr_komp_zlec, nr_poz, count(1) il_K,
      (select nvl(sum(il_wyc),0) from opt_zlec O where O.nr_kat=K.nr_katalog and O.nr_komp_zlec=K.nr_komp_zlec and O.nr_poz=K.nr_poz) il_O,
      (select nvl(min(nr_opt)||nullif('+'||greatest(0,count(distinct nr_opt)-1),'+0'),'BEZ OPT.') from opt_zlec O where O.nr_kat=K.nr_katalog and O.nr_komp_zlec=K.nr_komp_zlec and O.nr_poz=K.nr_poz) jaka_opt
from kol_stojakow K
left join zamow Z on Z.nr_kom_zlec=K.nr_komp_zlec
group by nr_listy, nr_komp_zlec, rollup(nr_poz), nr_katalog, typ_katalog
having count(1)<>
      (select nvl(sum(il_wyc),0) from opt_zlec O where O.nr_kat=K.nr_katalog and O.nr_komp_zlec=K.nr_komp_zlec and O.nr_poz=K.nr_poz)
order by 1,4,6;

--select * from DIFF_KOL_STOJAKOW_AND_OPT_ZLEC where nr_listy=62 and nr_poz is not null;
--select * from kol_stojakow;