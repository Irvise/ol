@echo off
set PATH=%PATH%;C:\MinGW\bin;C:\MinGW\msys\1.0\bin

if exist a.exe     erase a.exe
if exist boot.fasl erase boot.fasl
if exist repl.exe  erase repl.exe
if exist tests.exe erase tests.exe

:: ������� ������������� (� ��������������� �������)
gcc src/olvm.c src/boot.c src/repl.c -IC:\MinGW\include\ -LC:\MinGW\lib\ -lws2_32 -Ofast

:: � ������ �������� ������������ ������ ������
a.exe src/ol.scm

:: ������������� ��� � C
echo Preparing new boot.c...
a.exe src/to-c.scm >boot.c

:recompile
echo Making new repl.exe...
gcc src/olvm.c boot.c src/repl.c -IC:\MinGW\include\ -LC:\MinGW\lib\ -lws2_32 -Ofast -o repl.exe
repl.exe -e "(print \"Ok\")"

:: ������������ ����������� ������
gcc src/olvm.c boot.c src/testing.c -IC:\MinGW\include\ -LC:\MinGW\lib\ -lws2_32 -Ofast -o tests.exe
tests.exe

:: ������ ����� �� ������ �����������
repl.exe src/ol.scm
echo Preparing new boot.c...
repl.exe src/to-c.scm >boot2.c
echo Comparing old and new boot files
fc boot.c boot2.c /B >NUL
if errorlevel 1 (
	echo Different
	copy boot2.c boot.c
	goto recompile
) ELSE (
	echo ok
)

echo Making new repl2.exe...
gcc src/olvm.c boot2.c src/repl.c -IC:\MinGW\include\ -LC:\MinGW\lib\ -lws2_32 -Ofast -o repl2.exe
repl2.exe -e "(print \"Ok\")"
