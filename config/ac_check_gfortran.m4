# detect a gfortran bug 

AC_DEFUN([AC_CHECK_GFORTRAN_FORMAT_PB], [
dnl INPUTS :
dnl OUTPUTS
dnl  1 if no format pb 0 otherwise
dnl  Check pointer size 

AC_MSG_CHECKING([if gfortran format is ok ])

cat > conftest.f <<EOF
      program testf 
      write(06,'(f3.0)') 0.9999
      end 
EOF

$FC -o conftest conftest.f
if test -s conftest.f && (./conftest > conftest_out$$; exit) 2>/dev/null; then
  SIZEOF_INTP=`grep 1 conftest_out$$ | wc -l`
else
  SIZEOF_INTP="cannot_happen"
fi
rm -f conftest_out$$ 

if test $SIZEOF_INTP = 1; then 
	AC_MSG_RESULT([yes (we will use formatok.f)])
	FORMATFILE=formatok.o 
else 
	AC_MSG_RESULT([no, (we will use formatbug.c)])
	FORMATFILE=formatbug.o 
fi

]) dnl End of AC_CHECK_POINTER_SIZE 

