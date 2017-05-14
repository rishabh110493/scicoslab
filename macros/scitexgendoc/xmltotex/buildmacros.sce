SCI=getenv('SCI'); 
TMPDIR=getenv('TMPDIR');
MSDOS=(getos()=='Windows');
genlib('gendocxmllib','SCI/macros/scitexgendoc/xmltotex');

