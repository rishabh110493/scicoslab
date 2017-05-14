//-----------------------------------------------------------------------------
// Allan CORNET
// INRIA 2005
//-----------------------------------------------------------------------------

function [MSCompiler,name,configured]=findmsvccompiler()
// MSCompiler: a nickname for the compiler
// name: the key for product dir
// configured:  %t if succeded in setting env variables

  [lhs,rhs]=argn(0);
  MSCompiler='unknown'; // default value
  name = 'unknown';
  if ~MSDOS then return;end

  table = ['Software\Microsoft\VisualStudio\14.0\Setup\VS', 'msvc140'
	   'Software\Microsoft\VCExpress\12.0\Setup\VS', 'msvc120express';
	   'Software\Microsoft\VisualStudio\12.0\Setup\VS',  'msvc120pro';
	   'Software\Microsoft\VCExpress\11.0\Setup\VS',  'msvc110express';
	   'Software\Microsoft\VisualStudio\11.0\Setup\VS',  'msvc110pro';
  // Microsoft Visual 2010
	   'Software\Microsoft\VCExpress\10.0\Setup\VS',  'msvc100express';
	   'Software\Microsoft\VisualStudio\10.0\Setup\VS',  'msvc100pro';
  // Microsoft Visual 2008
	   'Software\Microsoft\VCExpress\9.0\Setup\VS',  'msvc90express';
	   'Software\Microsoft\VisualStudio\9.0\Setup\VS\Pro',  'msvc90pro';
	   'Software\Microsoft\VisualStudio\9.0\Setup\VS\Std',  'msvc90std';
  // Microsoft Visual 2005
	   'Software\Microsoft\VCExpress\8.0\Setup\VS',  'msvc80express';
	   'Software\Microsoft\VisualStudio\8.0\Setup\VS\Pro',  'msvc80pro';
	   'Software\Microsoft\VisualStudio\8.0\Setup\VS\Std',  'msvc80std';
  // Microsoft Visual Studio .NET 2003
	   'SOFTWARE\Microsoft\VisualStudio\7.1\Setup\VC',  'msvc71';
  // Microsoft Visual Studio .NET 2002
	   'SOFTWARE\Microsoft\VisualStudio\7.0\Setup\VC',  'msvc70';
  // Microsoft Visual Studio 6
	   'SOFTWARE\Microsoft\DevStudio\6.0\Products\Microsoft Visual C++','msvc60';
  // Microsoft Visual Studio 5
	   'SOFTWARE\Microsoft\DevStudio\5.0\Directories',  'msvc50'];

  for i=1:size(table,1)
    name = table(i,1); // returned value
    [MSCompiler,configured]=check_msvc_product(table(i,2),table(i,1));
    if ~isempty(MSCompiler); break ;end
  end

  if MSCompiler == 'msvc90express' then
    // Microsoft Visual C++ Express 9.0: search sdk
    name1 = 'Software\Microsoft\MicrosoftSDK\InstalledSDKs\D2FF9F89-8AA2-4373-8A31-C838BF4DBBE1';
    ierr1=execstr("rep=winqueryreg(''HKEY_LOCAL_MACHINE'',name1,''Install Dir'');","errcatch");
    name1 = 'Software\Microsoft\MicrosoftSDK\InstalledSDKs\8F9E5EF3-A9A5-491B-A889-C58EFFECE8B3'
    ierr2=execstr("rep=winqueryreg(''HKEY_LOCAL_MACHINE'',name1,''Install Dir'');","errcatch");
    name1 = 'Software\Microsoft\Microsoft SDKs\Windows';
    ierr3=execstr("rep=winqueryreg(''HKEY_LOCAL_MACHINE'',name1,''CurrentInstallFolder'');","errcatch");
    if ( (ierr1 == 0) | (ierr2 == 0) | (ierr3 == 0) ) then
      return;
    else
      printf('\nWarning : Microsoft Visual C++ 2008 Express Edition has been detected,\n");
      printf('but not Microsoft Platform SDK for Windows Server 2003 R2 or more.\n");
      printf('Please install this SDK if you want to use dynamic link with scilab.\n');
      lasterror(%T); // The error message is cleared
    end
  else
    lasterror(%T); // The error message is cleared
  end

  if MSCompiler == 'msvc80express' then
    // Microsoft Visual C++ Express 8.0: search SDK
    name1 = 'Software\Microsoft\MicrosoftSDK\InstalledSDKs\D2FF9F89-8AA2-4373-8A31-C838BF4DBBE1';
    ierr1=execstr("rep=winqueryreg(''HKEY_LOCAL_MACHINE'',name,''Install Dir'');","errcatch");
    name1 = 'Software\Microsoft\MicrosoftSDK\InstalledSDKs\8F9E5EF3-A9A5-491B-A889-C58EFFECE8B3';
    ierr2=execstr("rep=winqueryreg(''HKEY_LOCAL_MACHINE'',name,''Install Dir'');","errcatch");
    name1 = 'Software\Microsoft\Microsoft SDKs\Windows';
    ierr3=execstr("rep=winqueryreg(''HKEY_LOCAL_MACHINE'',name,''CurrentInstallFolder'');","errcatch");
    if ( (ierr1 == 0) | (ierr2 == 0) | (ierr3 == 0) ) then
      return;
    else
      printf('\nWarning: Microsoft Visual C++ 2005 Express Edition has been detected,\n");
      printf('but not Microsoft Platform SDK for Windows Server 2003 R2 or more.\n");
      printf('Please install this SDK if you want to use dynamic link with scilab.\n');
      lasterror(%T); // The error message is cleared
    end
  else
    lasterror(%T); // The error message is cleared
  end

  if isempty(MSCompiler) then
    // no compiler found
    MSCompiler='unknown';
    name = 'unknown';
    configured=%f;
  end
endfunction

function [msvc_compiler,configured]=check_msvc_product(rep,name)
// check if a version of visual exists and set env variables accordingly
// msvc_compiler is set to '' if the visual version corresponding to name
// is not found.
// configure is set to %t if setting env variables succeeded.

  configured = %f;
  ierr=execstr("vsdir=winqueryreg(''HKEY_LOCAL_MACHINE'',name,''ProductDir'');","errcatch");
  if (ierr == 0) then
    msvc_compiler=rep;
  else
    lasterror(%T);
    msvc_compiler='';
    return;
  end
  // printf('C compiler found at:%s\n",vsdir);
  // execute vcvarsall to set env variables 

  VC= sprintf("%sVC",vsdir);
  cmd = SCI+'/bin/vc.bat ""'+VC+'""';
  S=unix_g(cmd)

  vars= ['DevEnvDir';
	 'INCLUDE';
	 'LIB';
	 'LIBPATH';
	 'PATH';
	 'VCINSTALLDIR';
	 'VS100COMNTOOLS';
	 'VSINSTALLDIR';
	 'WindowsSdkDir'];

  for i=1:size(vars,'*')
    tag = vars(i)+'=';
    ntag= length(tag);
    for (j=1:size(S,1))
      if part(S(j,:),1:ntag) == tag then
	val = part(S(j,:),(ntag+1):length(S(j,:)));
	setenv(vars(i),val);
	// printf("set %s\n",vars(i));
	continue
      end
    end
  end
  if getenv('VCINSTALLDIR','')<>'' then
    configured = %t
  else
    configured = %f
  end

endfunction
