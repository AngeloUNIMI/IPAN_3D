function Gb_free = getFreeSpaceHd_in_GB()


[c,d] = dos('dir');
[c,e] = size(d);
f = strrep(d((e-28):(e-11)),'.','');
f = strrep(d((e-28):(e-11)),',','');
f2 = strrep(f,')','');
Gb_free = str2num(f2)/(1024*1024*1024);