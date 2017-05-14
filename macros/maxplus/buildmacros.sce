//------------------------------------
// Allan CORNET INRIA 2005
//------------------------------------
if ~exists('SCI') ;SCI=getenv('SCI'); end;
TMPDIR=getenv('TMPDIR');
MSDOS=(getos()=='Windows');
//------------------------------------
genlib('maxpluslib','SCI/macros/maxplus');
//------------------------------------
