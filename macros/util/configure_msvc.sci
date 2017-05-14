//-----------------------------------------------------------------------------
// Allan CORNET
// INRIA 2005
//-----------------------------------------------------------------------------

function bOK=configure_msvc()
  bOK=%t;
  if ~ MSDOS then bOK=%f;return; end;
  [msvc,name,configured]=findmsvccompiler();
  // if findmsvccompiler succeded in setting env variables we return
  if configured then return;end
  // here we try the old methods
  select msvc,
   case 'msvc140' then   bOK=setmsvc100(name);
   case 'msvc120pro' then   bOK=setmsvc100(name);
   case 'msvc120express' then   bOK=setmsvc100(name);
   case 'msvc110pro' then   bOK=setmsvc100(name);
   case 'msvc110express' then   bOK=setmsvc100(name);
   case 'msvc100pro' then   bOK=setmsvc100(name);
   case 'msvc100express' then bOK=setmsvc100(name);
   case 'msvc90pro' then  bOK=setmsvc90(name)
   case 'msvc90std' then  bOK=setmsvc90(name)
   case 'msvc90express' then bOK=setmsvc90(name)
   case 'msvc80pro' then bOK=setmsvc80pro(name)
   case 'msvc80std' then bOK=setmsvc80std(name)
   case 'msvc80express' then bOK=setmsvc80express(name)
   case 'msvc71' then bOK=setmsvc71(name)
   case 'msvc70' then bOK=setmsvc70(name)
   case 'msvc60' then bOK=setmsvc60(name)
   case 'msvc50' then bOK=setmsvc50(name)
  else
    //disp('Warning Ms Visual C Compiler not found.');
    bOK=%F;
  end
endfunction

function bOK=setmsvc100(name)
// for version 100 and above

  if ~MSDOS then bOK=%f;return;end

  MSVSDir=winqueryreg('HKEY_LOCAL_MACHINE',name,'ProductDir');
  if (part(MSVSDir,length(MSVSDir)) == '\') then MSVSDir=part(MSVSDir,1:length(MSVSDir)-1);end;
  // remove VC is MSVSDir ends with VC
  // for version 110 and above MSVSDir ends with \VC
  n = length(MSVSDir);
  if (part(MSVSDir,n-2:n) == '\VC') then MSVSDir=part(MSVSDir,1:n-3);end
  
  err=setenv('VSINSTALLDIR',MSVSDir);
  if (err == %F) then bOK=%F,return,end

  sdk_key='Software\Microsoft\Microsoft SDKs\Windows';
  err=execstr("SDK=winqueryreg(''HKEY_LOCAL_MACHINE'',sdk_key,''CurrentInstallFolder'');","errcatch");
  if (err == 0) then
    err = setenv('WindowsSdkDir',SDK);
    if (err == %F) then bOK = %F,return,end
  else
    SDK=[];
    lasterror(%T); // The error message is cleared
  end

  MSVCDir=MSVSDir+'\VC';

  err=setenv('VCINSTALLDIR',MSVCDir);
  if (err == %F) then bOK=%F,return,end

  DevEnvDir=MSVSDir+'\Common7\IDE';
  err=setenv('DevEnvDir',DevEnvDir);
  if (err == %F) then bOK=%F,return,end

  PATH=getenv('PATH','ndef');
  if (PATH =='ndef') then  bOK=%F,return,end

  err=setenv('PATH',DevEnvDir+';'+MSVCDir+'\bin;'+MSVSDir+'\Common7\Tools;'+MSVSDir+'\VCPackages;'+..
	     '\VC\ce\dll;'+MSVCDir+'\VCPackages;'+PATH+";"+WSCI+"\bin;");
  if (err == %F) then bOK=%F,return,end

  INCLUDE=getenv('INCLUDE','');
  SDK_INCLUDE='';
  if ~isempty(SDK) then SDK_INCLUDE= SDK+'INCLUDE;';end
  INCLUDE=MSVCDir+'\INCLUDE;'+SDK_INCLUDE+INCLUDE;
  err=setenv("INCLUDE",INCLUDE);
  if (err == %F) then bOK=%F,return,end

  LIB=getenv('LIB','');
  SDK_LIB='';
  if ~isempty(SDK) then SDK_LIB= SDK+'lib;';end 
  LIB=MSVCDir+'\LIB;'+SDK_LIB+LIB;
  err=setenv("LIB",LIB);
  if (err == %F) then bOK=%F,return,end
  bOK=%T
endfunction

function bOK=setmsvc90(name)
  if ~MSDOS then bOK=%f;return;end
  MSVSDir=winqueryreg('HKEY_LOCAL_MACHINE',name,'ProductDir');
  if ( part(MSVSDir,length(MSVSDir)) == '\' ) then MSVSDir=part(MSVSDir,1:length(MSVSDir)-1);end;

  err=setenv('VSINSTALLDIR',MSVSDir);
  if (err == %F) then bOK=%F,return,end

  sdk_key='Software\Microsoft\Microsoft SDKs\Windows';
  err=execstr("SDK=winqueryreg(''HKEY_LOCAL_MACHINE'',sdk_key,''CurrentInstallFolder'');","errcatch");
  if (err == 0) then
    err = setenv('WindowsSdkDir',SDK);
    if (err == %F) then bOK = %F,return,end
  else
    SDK=[];
    lasterror(%T); // The error message is cleared
  end

  MSVCDir=MSVSDir+'\VC';
  err=setenv('VCINSTALLDIR',MSVCDir);
  if (err == %F) then bOK=%F,return,end

  DevEnvDir=MSVSDir+'\Common7\IDE';
  err=setenv('DevEnvDir',DevEnvDir);
  if (err == %F) then bOK=%F,return,end

  PATH=getenv('PATH','ndef');
  if (PATH =='ndef') then  bOK=%F,return,end

  err=setenv('PATH',DevEnvDir+';'+MSVCDir+'\bin;'+MSVSDir+'\Common7\Tools;'+MSVSDir+'\VCPackages;'+..
	     '\VC\ce\dll;'+MSVCDir+'\VCPackages;'+PATH+";"+WSCI+"\bin;");
  if (err == %F) then bOK=%F,return,end

  INCLUDE=getenv('INCLUDE','');
  INCLUDE=MSVCDir+'\INCLUDE;'+SDK+'INCLUDE;'+INCLUDE;

  err=setenv("INCLUDE",INCLUDE);
  if (err == %F) then bOK=%F,return,end

  LIB=getenv('LIB','');
  LIB=MSVCDir+'\LIB;'+SDK+'lib;'+LIB;
  err=setenv("LIB",LIB);
  if (err == %F) then bOK=%F,return,end
  bOK=%T
endfunction

function bOK=setmsvc90express_old(name)
  if ~MSDOS then bOK=%f;return;end
  MSVSDir=winqueryreg('HKEY_LOCAL_MACHINE',name,'ProductDir');
  if ( part(MSVSDir,length(MSVSDir)) == '\' ) then MSVSDir=part(MSVSDir,1:length(MSVSDir)-1);end;

  err=setenv('VSINSTALLDIR',MSVSDir);
  if (err == %F) then bOK=%F,return,end

  MSVCDir=MSVSDir+'\VC';
  err=setenv('VCINSTALLDIR',MSVCDir);
  if (err == %F) then bOK=%F,return,end

  DevEnvDir=MSVSDir+'\Common7\IDE';
  err=setenv('DevEnvDir',DevEnvDir);
  if (err == %F) then bOK=%F,return,end

  PATH=getenv('PATH','ndef');
  if (PATH =='ndef') then  bOK=%F,return,end

  err=setenv('PATH',DevEnvDir+';'+MSVCDir+'\bin;'+MSVSDir+'\Common7\Tools;'+MSVSDir+'\SDK\v2.0\bin;'+MSVCDir+'\VCPackages;'+PATH+";"+WSCI+"\bin;");
  if (err == %F) then bOK=%F,return,end

  ierr1=execstr("VISTASDK=winqueryreg(''HKEY_LOCAL_MACHINE'',''Software\Microsoft\Microsoft SDKs\Windows'',''CurrentInstallFolder'');","errcatch");
  ierr2=execstr("W2003R2SDK=winqueryreg(''HKEY_LOCAL_MACHINE'',''Software\Microsoft\MicrosoftSDK\InstalledSDKs\D2FF9F89-8AA2-4373-8A31-C838BF4DBBE1'',''Install Dir'');","errcatch");
  ierr3=execstr("W2003SDK=winqueryreg(''HKEY_LOCAL_MACHINE'',''Software\Microsoft\MicrosoftSDK\InstalledSDKs\8F9E5EF3-A9A5-491B-A889-C58EFFECE8B3'',''Install Dir'');","errcatch");

  if (ierr1 == 0) then
      WINDOWSSDK = winqueryreg('HKEY_LOCAL_MACHINE','Software\Microsoft\Microsoft SDKs\Windows','CurrentInstallFolder');
      lasterror(%T); // The error message is cleared
  else
    if (ierr2 == 0) then
      WINDOWSSDK = winqueryreg('HKEY_LOCAL_MACHINE','Software\Microsoft\MicrosoftSDK\InstalledSDKs\D2FF9F89-8AA2-4373-8A31-C838BF4DBBE1','Install Dir');
      lasterror(%T); // The error message is cleared
    else
      if (ierr3 == 0) then
	WINDOWSSDK = winqueryreg('HKEY_LOCAL_MACHINE','Software\Microsoft\MicrosoftSDK\InstalledSDKs\8F9E5EF3-A9A5-491B-A889-C58EFFECE8B3','Install Dir');
	lasterror(%T); // The error message is cleared
      end
    end
  end

  INCLUDE=getenv('INCLUDE','');
  INCLUDE=MSVCDir+'\INCLUDE;'+WINDOWSSDK+'INCLUDE;'
  err=setenv("INCLUDE",INCLUDE);
  if (err == %F) then bOK=%F,return,end

  LIB=getenv('LIB','');
  LIB=MSVCDir+'\LIB;'+MSVSDir+'\SDK\v2.0\lib;'+WINDOWSSDK+'Lib;'+LIB;
  err=setenv("LIB",LIB);
  if (err == %F) then bOK=%F,return,end

  err=setenv("USE_MT","-MT");
  if (err == %F) then bOK=%F,return,end
endfunction

function bOK=setmsvc80pro(name)
  if ~MSDOS then bOK=%f;return;end
  MSVSDir=winqueryreg('HKEY_LOCAL_MACHINE',name,'ProductDir');
  if ( part(MSVSDir,length(MSVSDir)) == '\' ) then MSVSDir=part(MSVSDir,1:length(MSVSDir)-1);end;

  err=setenv('VSINSTALLDIR',MSVSDir);
  if (err == %F) then bOK=%F,return,end

  MSVCDir=MSVSDir+'\VC';
  err=setenv('VCINSTALLDIR',MSVCDir);
  if (err == %F) then bOK=%F,return,end

  DevEnvDir=MSVSDir+'\Common7\IDE';
  err=setenv('DevEnvDir',DevEnvDir);
  if (err == %F) then bOK=%F,return,end

  PATH=getenv('PATH','ndef');
  if (PATH =='ndef') then  bOK=%F,return,end

  err=setenv('PATH',DevEnvDir+';'+MSVCDir+'\bin;'+MSVSDir+'\Common7\Tools;'+MSVSDir+'\SDK\v2.0\bin;'+MSVCDir+'\VCPackages;'+PATH+";"+WSCI+"\bin;");
  if (err == %F) then bOK=%F,return,end

  INCLUDE=getenv('INCLUDE','');
  INCLUDE=MSVCDir+'\INCLUDE;'+MSVCDir+'\PlatformSDK\include;'+MSVSDir+'\SDK\v2.0\include';

  err=setenv("INCLUDE",INCLUDE);
  if (err == %F) then bOK=%F,return,end

  LIB=getenv('LIB','');
  LIB=MSVCDir+'\LIB;'+MSVSDir+'\SDK\v2.0\lib;'+MSVSDir+'\VC\PlatformSDK\lib;'+LIB;
  err=setenv("LIB",LIB);
  if (err == %F) then bOK=%F,return,end

  err=setenv("USE_MT","-MT");
  if (err == %F) then bOK=%F,return,end
endfunction

function bOK=setmsvc80std(name)
  if ~MSDOS then bOK=%f;return;end
  MSVSDir=winqueryreg('HKEY_LOCAL_MACHINE',name,'ProductDir');
  if ( part(MSVSDir,length(MSVSDir)) == '\' ) then MSVSDir=part(MSVSDir,1:length(MSVSDir)-1);end;

  err=setenv('VSINSTALLDIR',MSVSDir);
  if (err == %F) then bOK=%F,return,end

  MSVCDir=MSVSDir+'\VC';
  err=setenv('VCINSTALLDIR',MSVCDir);
  if (err == %F) then bOK=%F,return,end

  DevEnvDir=MSVSDir+'\Common7\IDE';
  err=setenv('DevEnvDir',DevEnvDir);
  if (err == %F) then bOK=%F,return,end

  PATH=getenv('PATH','ndef');
  if (PATH =='ndef') then  bOK=%F,return,end

  err=setenv('PATH',DevEnvDir+';'+MSVCDir+'\bin;'+MSVSDir+'\Common7\Tools;'+MSVSDir+'\SDK\v2.0\bin;'+MSVCDir+'\VCPackages;'+PATH+";"+WSCI+"\bin;");
  if (err == %F) then bOK=%F,return,end

  INCLUDE=getenv('INCLUDE','');
  INCLUDE=MSVCDir+'\INCLUDE;'+MSVCDir+'\PlatformSDK\include;'+MSVSDir+'\SDK\v2.0\include';
  err=setenv("INCLUDE",INCLUDE);
  if (err == %F) then bOK=%F,return,end

  LIB=getenv('LIB','');
  LIB=MSVCDir+'\LIB;'+MSVSDir+'\SDK\v2.0\lib;'+MSVSDir+'\VC\PlatformSDK\lib;'+LIB;
  err=setenv("LIB",LIB);
  if (err == %F) then bOK=%F,return,end

  err=setenv("USE_MT","-MT");
  if (err == %F) then bOK=%F,return,end
endfunction

function bOK=setmsvc80express(name)
  if ~MSDOS then bOK=%f;return;end

  MSVSDir=winqueryreg('HKEY_LOCAL_MACHINE',name,'ProductDir');
  if ( part(MSVSDir,length(MSVSDir)) == '\' ) then MSVSDir=part(MSVSDir,1:length(MSVSDir)-1);end;
  err=setenv('VSINSTALLDIR',MSVSDir);
  if (err == %F) then bOK=%F,return,end

  MSVCDir=MSVSDir+'\VC';
  err=setenv('VCINSTALLDIR',MSVCDir);
  if (err == %F) then bOK=%F,return,end

  DevEnvDir=MSVSDir+'\Common7\IDE';
  err=setenv('DevEnvDir',DevEnvDir);
  if (err == %F) then bOK=%F,return,end

  PATH=getenv('PATH','ndef');
  if (PATH =='ndef') then  bOK=%F,return,end

  err=setenv('PATH',DevEnvDir+';'+MSVCDir+'\bin;'+MSVSDir+'\Common7\Tools;'+MSVSDir+'\SDK\v2.0\bin;'+MSVCDir+'\VCPackages;'+PATH+";"+WSCI+"\bin;");
  if (err == %F) then bOK=%F,return,end

  ierr1=execstr("VISTASDK=winqueryreg(''HKEY_LOCAL_MACHINE'',''Software\Microsoft\Microsoft SDKs\Windows'',''CurrentInstallFolder'');","errcatch");
  ierr2=execstr("W2003R2SDK=winqueryreg(''HKEY_LOCAL_MACHINE'',''Software\Microsoft\MicrosoftSDK\InstalledSDKs\D2FF9F89-8AA2-4373-8A31-C838BF4DBBE1'',''Install Dir'');","errcatch");
  ierr3=execstr("W2003SDK=winqueryreg(''HKEY_LOCAL_MACHINE'',''Software\Microsoft\MicrosoftSDK\InstalledSDKs\8F9E5EF3-A9A5-491B-A889-C58EFFECE8B3'',''Install Dir'');","errcatch");

  if (ierr1 == 0) then
    WINDOWSSDK = winqueryreg('HKEY_LOCAL_MACHINE','Software\Microsoft\Microsoft SDKs\Windows','CurrentInstallFolder');
    lasterror(%T); // The error message is cleared
  else
    if (ierr2 == 0) then
      WINDOWSSDK = winqueryreg('HKEY_LOCAL_MACHINE','Software\Microsoft\MicrosoftSDK\InstalledSDKs\D2FF9F89-8AA2-4373-8A31-C838BF4DBBE1','Install Dir');
      lasterror(%T); // The error message is cleared
    else
      if (ierr3 == 0) then
	WINDOWSSDK = winqueryreg('HKEY_LOCAL_MACHINE','Software\Microsoft\MicrosoftSDK\InstalledSDKs\8F9E5EF3-A9A5-491B-A889-C58EFFECE8B3','Install Dir');
	lasterror(%T); // The error message is cleared
      end
    end
  end

  INCLUDE=getenv('INCLUDE','');
  INCLUDE=MSVCDir+'\INCLUDE;'+WINDOWSSDK+'INCLUDE;'
  err=setenv("INCLUDE",INCLUDE);
  if (err == %F) then bOK=%F,return,end

  LIB=getenv('LIB','');
  LIB=MSVCDir+'\LIB;'+MSVSDir+'\SDK\v2.0\lib;'+WINDOWSSDK+'Lib;'+LIB;
  err=setenv("LIB",LIB);
  if (err == %F) then bOK=%F,return,end

  err=setenv("USE_MT","-MT");
  if (err == %F) then bOK=%F,return,end
endfunction

function bOK=setmsvc71(name)
  if ~MSDOS then bOK=%f;return;end
  MSVCDir=winqueryreg('HKEY_LOCAL_MACHINE',name,'ProductDir')
  if ( part(MSVCDir,length(MSVCDir)) == '\' ) then MSVCDir=part(MSVCDir,1:length(MSVCDir)-1),end;

  err=setenv('MSVCDir',MSVCDir);
  if (err == %F) then bOK=%F,return,end

  err=setenv("DevEnvDir",MSVCDir+"\..\Common7\Tools");
  if (err == %F) then bOK=%F,return,end

  PATH=getenv('PATH','ndef');
  if (PATH =='ndef') then  bOK=%F,return,end

  DevEnvDir=getenv('DevEnvDir','ndef');
  if (DevEnvDir =='ndef') then bOK=%F,return,end

  err=setenv("PATH",MSVCDir+"\BIN;"+DevEnvDir+";"+DevEnvDir+"\bin;"+MSVCDir+"\..\Common7\IDE;"+PATH+";"+WSCI+"\bin;");
  if (err == %F) then bOK=%F,return,end

  INCLUDE=getenv('INCLUDE','');

  err=setenv("INCLUDE",MSVCDir+"\ATLMFC\INCLUDE;"+MSVCDir+"\INCLUDE;"+MSVCDir+"\PlatformSDK\include;"+INCLUDE);
  if (err == %F) then bOK=%F,return,end

  LIB=getenv('LIB','ndef');

  err=setenv("LIB",MSVCDir+"\ATLMFC\LIB;"+MSVCDir+"\LIB;"+MSVCDir+"\PlatformSDK\lib;"+LIB);
  if (err == %F) then bOK=%F,return,end
endfunction

function bOK=setmsvc70(name)
  if ~MSDOS then bOK=%f;return;end
  MSVCDir=winqueryreg('HKEY_LOCAL_MACHINE',name,'ProductDir');
  if ( part(MSVCDir,length(MSVCDir)) == '\' ) then MSVCDir=part(MSVCDir,1:length(MSVCDir)-1),end;

  err=setenv('MSVCDir',MSVCDir);
  if (err == %F) then bOK=%F,return,end

  err=setenv("DevEnvDir",MSVCDir+"\..\Common7\Tools");
  if (err == %F) then bOK=%F,return,end

  DevEnvDir=getenv('DevEnvDir','ndef');
  if (DevEnvDir =='ndef') then bOK=%F,return,end

  PATH=getenv('PATH','ndef');
  if (PATH =='ndef') then  bOK=%F,return,end

  err=setenv("PATH",MSVCDir+"\BIN;"+DevEnvDir+";"+DevEnvDir+"\bin;"+MSVCDir+"\..\Common7\IDE;"+PATH+";"+SCI+"\bin;");
  if (err == %F) then bOK=%F,return,end

  INCLUDE=getenv('INCLUDE','');

  err=setenv("INCLUDE",MSVCDir+"\ATLMFC\INCLUDE;"+MSVCDir+"\INCLUDE;"+MSVCDir+"\PlatformSDK\include;"+INCLUDE);
  if (err == %F) then bOK=%F,return,end

  LIB=getenv('LIB','');

  err=setenv("LIB",MSVCDir+"\ATLMFC\LIB;"+MSVCDir+"\LIB;"+MSVCDir+"\PlatformSDK\lib;"+LIB);
  if (err == %F) then bOK=%F,return,end
endfunction


function bOK=setmsvc60(name)
  if ~MSDOS then bOK=%f;return;end
  MSVCDir=winqueryreg('HKEY_LOCAL_MACHINE',name,'ProductDir');
  if ( part(MSVCDir,length(MSVCDir)) == '\' ) then MSVCDir=part(MSVCDir,1:length(MSVCDir)-1),end;

  err=setenv('MSVCDir',MSVCDir);
  if (err == %F) then bOK=%F,return,end

  err=setenv("MSDevDir",MSVCDir+"\..\Common\msdev98");
  if (err == %F) then bOK=%F,return,end

  MSDevDir=getenv('MSDevDir','ndef');
  if (MSDevDir =='ndef') then bOK=%F,return,end

  PATH=getenv('PATH','ndef');
  if (PATH =='ndef') then  bOK=%F,return,end

  err=setenv("PATH",MSVCDir+'\BIN;'+MSDevDir+'\bin;'+';'+WSCI+'\bin;'+PATH);
  if (err == %F) then bOK=%F,return,end

  INCLUDE=getenv('INCLUDE','');

  err=setenv("INCLUDE",MSVCDir+'\INCLUDE;'+MSVCDir+'\MFC\INCLUDE;'+MSVCDir+'\ATL\INCLUDE;'+INCLUDE);
  if (err == %F) then bOK=%F,return,end

  LIB=getenv('LIB','');

  err=setenv("LIB",MSVCDir+'\LIB;'+MSVCDir+'\MFC\LIB;'+LIB);
  if (err == %F) then bOK=%F,return,end
endfunction

function bOK=setmsvc50(name)
  if ~MSDOS then bOK=%f;return;end
  MSVCDir=winqueryreg('HKEY_LOCAL_MACHINE',name,'ProductDir');
  if ( part(MSVCDir,length(MSVCDir)) == '\' ) then MSVCDir=part(MSVCDir,1:length(MSVCDir)-1),end;

  err=setenv('MSVCDir',MSVCDir);
  if (err == %F) then bOK=%F,return,end

  err=setenv("MSDevDir",MSVCDir+"\..\sharedIDE");
  if (err == %F) then bOK=%F,return,end

  MSDevDir=getenv('MSDevDir','ndef');
  if (MSDevDir =='ndef') then bOK=%F,return,end

  PATH=getenv('PATH','ndef');
  if (PATH =='ndef') then  bOK=%F,return,end

  err=setenv("PATH",MSVCDir+'\BIN;'+MSDevDir+'\bin;'+';'+WSCI+'\bin;'+PATH);
  if (err == %F) then bOK=%F,return,end

  INCLUDE=getenv('INCLUDE','');

  err=setenv("INCLUDE",MSVCDir+'\INCLUDE;'+MSVCDir+'\MFC\INCLUDE;'+MSVCDir+'\ATL\INCLUDE;'+INCLUDE);
  if (err == %F) then bOK=%F,return,end

  LIB=getenv('LIB','');

  err=setenv("LIB",MSVCDir+'\LIB;'+MSVCDir+'\MFC\LIB;'+LIB);
  if (err == %F) then bOK=%F,return,end
endfunction
