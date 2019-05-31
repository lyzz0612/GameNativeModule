
@echo off
setlocal enabledelayedexpansion

set HMSSDKVER=2.6.3.300
set MAVENURL=http://developer.huawei.com/repo

echo.
echo      **********************************************************************************************************************
echo      *                                                                                                                    *
echo      *    �˹�������Ϊ����ͬĿ¼��copysrc/java �ļ����µĴ����������jar����                                              *
echo      *    This tool works by compiling code under the Copysrc/java folder in the same directory to generate JAR packages. *
echo      *        ���ɵ�jar��·��Ϊ copysrc/HMSAgent_%HMSSDKVER%.jar                                                            *
echo      *        The generated jar package path is Copysrc/hmsagent_%hmssdkver%.jar                                            *
echo      *                                                                                                                    *
echo      *    ���������Ҫ jdk �� android.jar ��׼��                                                                          *
echo      *    The compilation process requires JDK and Android.jar, please prepare                                            *
echo      *                                                                                                                    *
echo      **********************************************************************************************************************
echo.



@rem ȷ��java �� javac �����ܹ�ִ��
if defined JAVA_HOME (
 set JAVA_HOME=!JAVA_HOME:"=!
 set JAVA_PATH=!JAVA_HOME!/bin
 set JAVA_PATH=!JAVA_PATH:\/=/!
 set JAVA_PATH=!JAVA_PATH://=/!
 set PATH=!PATH!;!JAVA_PATH!
)

CALL :IF_EXIST java.exe || echo ���ĵ��Բ�֧��java���������jdk����binĿ¼��ӵ�����������PATH�У�&& echo Your computer does not support Java commands, please download the JDK and add the bin directory to the path of the environment variable!  && pause>nul && exit
CALL :IF_EXIST javac.exe || echo ���ĵ��Բ�֧��javac���������jdk����binĿ¼��ӵ�����������PATH�У�&& echo Your computer does not support the Javac command, please download the JDK and add the bin directory to the path of the environment variable! && pause>nul && exit


@rem ����android.jar ·��
:INPUTANDROIDJAR
echo ������android.jar �ļ���ȫ·�������磺C:\android-sdk\platforms\android-23\android.jar ��
set /p ANDROIDJAR=Please enter a full path to the Android.jar file (for example: C:\android-sdk\platforms\android-23\android.jar)��
if not exist %ANDROIDJAR% goto :INPUTANDROIDJAR


@rem ȡ�õ�ǰ·��  |  Get current path
set CURPATH=%~dp0


@rem ������ʱ�ļ��� | Create a temporary folder
mkdir "%CURPATH%bin"
mkdir "%CURPATH%libs"
mkdir "%CURPATH%aars"

@rem ����HMS-SDK  | Download HMS-SDK 
echo ��Ҫ����HMS SDK ��
echo The HMS SDK package will be downloaded

echo  %MAVENURL%/com/huawei/android/hms/base/%HMSSDKVER%/base-%HMSSDKVER%.aar
echo  %MAVENURL%/com/huawei/android/hms/sns/%HMSSDKVER%/sns-%HMSSDKVER%.aar
echo  %MAVENURL%/com/huawei/android/hms/push/%HMSSDKVER%/push-%HMSSDKVER%.aar 
echo  %MAVENURL%/com/huawei/android/hms/iap/%HMSSDKVER%/iap-%HMSSDKVER%.aar
echo  %MAVENURL%/com/huawei/android/hms/hwid/%HMSSDKVER%/hwid-%HMSSDKVER%.aar
echo  %MAVENURL%/com/huawei/android/hms/game/%HMSSDKVER%/game-%HMSSDKVER%.aar
echo.
echo �����ĵ����������������ز��ˣ����ֶ��ӱ����أ��ŵ� %CURPATH%aars ����
echo If your computer network has trouble downloading, please download it manually from elsewhere, put it under %curpath%aars

java -jar "%CURPATH%tool/tools.jar" -m download %MAVENURL%/com/huawei/android/hms/base/%HMSSDKVER%/base-%HMSSDKVER%.aar  "%CURPATH%aars"
java -jar "%CURPATH%tool/tools.jar" -m download %MAVENURL%/com/huawei/android/hms/sns/%HMSSDKVER%/sns-%HMSSDKVER%.aar  "%CURPATH%aars"
java -jar "%CURPATH%tool/tools.jar" -m download %MAVENURL%/com/huawei/android/hms/push/%HMSSDKVER%/push-%HMSSDKVER%.aar  "%CURPATH%aars"
java -jar "%CURPATH%tool/tools.jar" -m download %MAVENURL%/com/huawei/android/hms/iap/%HMSSDKVER%/iap-%HMSSDKVER%.aar  "%CURPATH%aars"
java -jar "%CURPATH%tool/tools.jar" -m download %MAVENURL%/com/huawei/android/hms/hwid/%HMSSDKVER%/hwid-%HMSSDKVER%.aar  "%CURPATH%aars"
java -jar "%CURPATH%tool/tools.jar" -m download %MAVENURL%/com/huawei/android/hms/game/%HMSSDKVER%/game-%HMSSDKVER%.aar  "%CURPATH%aars"


@rem ��ȡ�����jar���ŵ�libs���湩�������� | Extract the jar package inside and place it under libs for compilation dependencies
for /r "%CURPATH%aars"  %%i in ("*.aar")  do (
java -jar "%CURPATH%tool/tools.jar" -m zipOut "%%i"  classes.jar  "%CURPATH%libs/%%~ni.jar"
)

@rem ƴ��Ҫ�����java�ļ� | Stitching Java files to compile
set AGENT_JAVAS=
pushd "%CURPATH%copysrc\java"
for /R %%i in (*.java) do set AGENT_JAVAS=!AGENT_JAVAS!  "%%i"
popd

@rem ƴ��������HMSSDKjar�� | Mosaic Dependent Hmssdkjar Package
set AGENT_LIBS=
pushd "%CURPATH%libs"
for /R %%i in (*.jar) do set AGENT_LIBS=!AGENT_LIBS!;"%%i"
popd

@rem ʹ��javac������� | Compiling with the Javac command
javac -encoding utf-8 -bootclasspath %ANDROIDJAR% -classpath %AGENT_LIBS%  -d bin %AGENT_JAVAS%

@rem ���м��ļ�ѹ����jar�� | Compress intermediate files into jar packages
java -jar "%CURPATH%tool/tools.jar" -m zipIn "%CURPATH%copysrc/HMSAgent_%HMSSDKVER%.jar"  com  "%CURPATH%bin/com"

@rem ɾ�������ļ��� | Delete cache folder
if exist "%CURPATH%bin" rd /s /q "%CURPATH%bin"
if exist "%CURPATH%aars" rd /s /q "%CURPATH%aars"
if exist "%CURPATH%libs" rd /s /q "%CURPATH%libs"

echo.
echo.
echo ���νű�ִ�����ɵ��ļ���
echo The files generated by this script execution are:
echo copysrc/HMSAgent_%HMSSDKVER%.jar    
echo �����������&echo Press any key to exit &pause>nul

:IF_EXIST
SETLOCAL&PATH %PATH%;%~dp0;%cd%
if "%~$PATH:1"=="" exit /b 1
exit /b 0
