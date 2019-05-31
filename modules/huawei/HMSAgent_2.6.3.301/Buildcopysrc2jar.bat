
@echo off
setlocal enabledelayedexpansion

set HMSSDKVER=2.6.3.300
set MAVENURL=http://developer.huawei.com/repo

echo.
echo      **********************************************************************************************************************
echo      *                                                                                                                    *
echo      *    此工具作用为：将同目录下copysrc/java 文件夹下的代码编译生成jar包。                                              *
echo      *    This tool works by compiling code under the Copysrc/java folder in the same directory to generate JAR packages. *
echo      *        生成的jar包路径为 copysrc/HMSAgent_%HMSSDKVER%.jar                                                            *
echo      *        The generated jar package path is Copysrc/hmsagent_%hmssdkver%.jar                                            *
echo      *                                                                                                                    *
echo      *    编译过程需要 jdk 和 android.jar 请准备                                                                          *
echo      *    The compilation process requires JDK and Android.jar, please prepare                                            *
echo      *                                                                                                                    *
echo      **********************************************************************************************************************
echo.



@rem 确保java 和 javac 命令能够执行
if defined JAVA_HOME (
 set JAVA_HOME=!JAVA_HOME:"=!
 set JAVA_PATH=!JAVA_HOME!/bin
 set JAVA_PATH=!JAVA_PATH:\/=/!
 set JAVA_PATH=!JAVA_PATH://=/!
 set PATH=!PATH!;!JAVA_PATH!
)

CALL :IF_EXIST java.exe || echo 您的电脑不支持java命令，请下载jdk并将bin目录添加到环境变量的PATH中！&& echo Your computer does not support Java commands, please download the JDK and add the bin directory to the path of the environment variable!  && pause>nul && exit
CALL :IF_EXIST javac.exe || echo 您的电脑不支持javac命令，请下载jdk并将bin目录添加到环境变量的PATH中！&& echo Your computer does not support the Javac command, please download the JDK and add the bin directory to the path of the environment variable! && pause>nul && exit


@rem 输入android.jar 路径
:INPUTANDROIDJAR
echo 请输入android.jar 文件的全路径（例如：C:\android-sdk\platforms\android-23\android.jar ）
set /p ANDROIDJAR=Please enter a full path to the Android.jar file (for example: C:\android-sdk\platforms\android-23\android.jar)：
if not exist %ANDROIDJAR% goto :INPUTANDROIDJAR


@rem 取得当前路径  |  Get current path
set CURPATH=%~dp0


@rem 创建临时文件夹 | Create a temporary folder
mkdir "%CURPATH%bin"
mkdir "%CURPATH%libs"
mkdir "%CURPATH%aars"

@rem 下载HMS-SDK  | Download HMS-SDK 
echo 将要下载HMS SDK 包
echo The HMS SDK package will be downloaded

echo  %MAVENURL%/com/huawei/android/hms/base/%HMSSDKVER%/base-%HMSSDKVER%.aar
echo  %MAVENURL%/com/huawei/android/hms/sns/%HMSSDKVER%/sns-%HMSSDKVER%.aar
echo  %MAVENURL%/com/huawei/android/hms/push/%HMSSDKVER%/push-%HMSSDKVER%.aar 
echo  %MAVENURL%/com/huawei/android/hms/iap/%HMSSDKVER%/iap-%HMSSDKVER%.aar
echo  %MAVENURL%/com/huawei/android/hms/hwid/%HMSSDKVER%/hwid-%HMSSDKVER%.aar
echo  %MAVENURL%/com/huawei/android/hms/game/%HMSSDKVER%/game-%HMSSDKVER%.aar
echo.
echo 如果你的电脑网络有问题下载不了，请手动从别处下载，放到 %CURPATH%aars 下面
echo If your computer network has trouble downloading, please download it manually from elsewhere, put it under %curpath%aars

java -jar "%CURPATH%tool/tools.jar" -m download %MAVENURL%/com/huawei/android/hms/base/%HMSSDKVER%/base-%HMSSDKVER%.aar  "%CURPATH%aars"
java -jar "%CURPATH%tool/tools.jar" -m download %MAVENURL%/com/huawei/android/hms/sns/%HMSSDKVER%/sns-%HMSSDKVER%.aar  "%CURPATH%aars"
java -jar "%CURPATH%tool/tools.jar" -m download %MAVENURL%/com/huawei/android/hms/push/%HMSSDKVER%/push-%HMSSDKVER%.aar  "%CURPATH%aars"
java -jar "%CURPATH%tool/tools.jar" -m download %MAVENURL%/com/huawei/android/hms/iap/%HMSSDKVER%/iap-%HMSSDKVER%.aar  "%CURPATH%aars"
java -jar "%CURPATH%tool/tools.jar" -m download %MAVENURL%/com/huawei/android/hms/hwid/%HMSSDKVER%/hwid-%HMSSDKVER%.aar  "%CURPATH%aars"
java -jar "%CURPATH%tool/tools.jar" -m download %MAVENURL%/com/huawei/android/hms/game/%HMSSDKVER%/game-%HMSSDKVER%.aar  "%CURPATH%aars"


@rem 抽取里面的jar包放到libs下面供编译依赖 | Extract the jar package inside and place it under libs for compilation dependencies
for /r "%CURPATH%aars"  %%i in ("*.aar")  do (
java -jar "%CURPATH%tool/tools.jar" -m zipOut "%%i"  classes.jar  "%CURPATH%libs/%%~ni.jar"
)

@rem 拼接要编译的java文件 | Stitching Java files to compile
set AGENT_JAVAS=
pushd "%CURPATH%copysrc\java"
for /R %%i in (*.java) do set AGENT_JAVAS=!AGENT_JAVAS!  "%%i"
popd

@rem 拼接依赖的HMSSDKjar包 | Mosaic Dependent Hmssdkjar Package
set AGENT_LIBS=
pushd "%CURPATH%libs"
for /R %%i in (*.jar) do set AGENT_LIBS=!AGENT_LIBS!;"%%i"
popd

@rem 使用javac命令编译 | Compiling with the Javac command
javac -encoding utf-8 -bootclasspath %ANDROIDJAR% -classpath %AGENT_LIBS%  -d bin %AGENT_JAVAS%

@rem 将中间文件压缩成jar包 | Compress intermediate files into jar packages
java -jar "%CURPATH%tool/tools.jar" -m zipIn "%CURPATH%copysrc/HMSAgent_%HMSSDKVER%.jar"  com  "%CURPATH%bin/com"

@rem 删除缓存文件夹 | Delete cache folder
if exist "%CURPATH%bin" rd /s /q "%CURPATH%bin"
if exist "%CURPATH%aars" rd /s /q "%CURPATH%aars"
if exist "%CURPATH%libs" rd /s /q "%CURPATH%libs"

echo.
echo.
echo 本次脚本执行生成的文件有
echo The files generated by this script execution are:
echo copysrc/HMSAgent_%HMSSDKVER%.jar    
echo 按任意键结束&echo Press any key to exit &pause>nul

:IF_EXIST
SETLOCAL&PATH %PATH%;%~dp0;%cd%
if "%~$PATH:1"=="" exit /b 1
exit /b 0
