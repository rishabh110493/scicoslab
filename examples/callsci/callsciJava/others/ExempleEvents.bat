echo off
rem A modifier selon votre r�pertoire d'installation de Java(TM) 2 SDK, Standard Edition Version 1.4.2
PATH=%PATH%;c:\Wintools\JBuilder9\jdk1.4\bin;

rem execution des exemples
cd ..\..\..\..\bin
echo ------------------------------------------------------------------------
echo Exemple Events 1
echo ------------------------------------------------------------------------
java ExempleEvent
pause
cd ..\examples\callsci\callsciJava\others
echo on
