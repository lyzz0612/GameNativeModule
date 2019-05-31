@echo off
setlocal enabledelayedexpansion

echo.
echo      *************************************************************************************************************
echo      *                                                                                                           *
echo      *    This tool is: from the full amount of hmsagent code, according to your choice to delete unwanted code  *
echo      *    Current full code includes pay, Huawei ID, Push                                                        *
echo      *                                                                                                           *
echo      *    1. If script execution is unsuccessful due to PC environment problems, open the script with text,      *
echo      *       and manually delete the related code by script comment                                              *
echo      *                                                                                                           *
echo      *    2. Make sure the path to this script does not contain spaces                                           *
echo      *                                                                                                           *
echo      *************************************************************************************************************
echo.

if defined JAVA_HOME (
 set JAVA_HOME=!JAVA_HOME:"=!
 set JAVA_PATH=!JAVA_HOME!/bin
 set JAVA_PATH=!JAVA_PATH:\/=/!
 set JAVA_PATH=!JAVA_PATH://=/!
 set PATH=!PATH!;!JAVA_PATH!
)

CALL :IF_EXIST java.exe || echo Your computer does not support Java commands, please download Java and add the bin directory to the path of the environment variable!  && pause>nul && exit

set CURPATH=%~dp0
set MANIFEST_CONFIG_NAME=AppManifestConfig.xml

if exist "%CURPATH%copysrc" rd /s /q "%CURPATH%copysrc"
xcopy "%CURPATH%hmsagents\src\main\java\*.*"  "%CURPATH%copysrc\java\" /s /e  /q>nul
xcopy "%CURPATH%config\%MANIFEST_CONFIG_NAME%"  "%CURPATH%copysrc\"  /q>nul

set /p PACKAGE_NAME= Please enter the package name of the application:
if not [%PACKAGE_NAME%] == [] (
java -jar "%CURPATH%tool/tools.jar" -m replace  -codeformat utf-8  "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "${PACKAGE_NAME}"  "%PACKAGE_NAME%"
)
echo.
set /p APPID=Please input AppID from the Developer Consortium (http://developer.huawei.com/consumer/cn) for application assignment AppID:
if not [%APPID%] == [] (
java -jar "%CURPATH%tool/tools.jar" -m replace  -codeformat utf-8  "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "${APPID}"  "%APPID%"
)
echo.
set /p CPID=Please enter cpid, from the cpid or payid for application assignment from the Developer Federation (http://developer.huawei.com/consumer/cn):
if not [%CPID%] == [] (
java -jar "%CURPATH%tool/tools.jar" -m replace  -codeformat utf-8 "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "${CPID}"  "%CPID%"
)


java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "MyApplication"
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "drawable/ic_launcher"
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "GameActivity"
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "PayActivity"
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "HwIDActivity"
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "SnsActivity"
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "PushActivity"
java -jar "%CURPATH%tool/tools.jar" -m replace  -codeformat utf-8 "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "package=\"com.huawei.hmsagent\""  ""
java -jar "%CURPATH%tool/tools.jar" -m replace  -codeformat utf-8 "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "android:name=\"com.huawei.hmsagent.HuaweiPushRevicer\""  "android:name=\"${Replace the contents of the double quotes here with the PushReceiver class you created}\""

echo.
set  /p NEEDGAME= Whether your application is a game £¨1 means yes, 0 indicates no £©£º
set  NEEDSNS=0

if [%NEEDGAME%] == [] (
set /p NEEDGAME= Your application is "game" £¨1 means yes, 0 indicates no £©£º
)
@rem No integration games are required£º
if  %NEEDGAME% == 0 (
@rem Delete com/huawei/android/hms/agent/game folder and content
java -jar "%CURPATH%tool/tools.jar"  -m delFile "%CURPATH%copysrc/java/com/huawei/android/hms/agent/game"

@rem Delete a line in com/huawei/android/hms/agent/common/apiclientmgr.java that contains ". Game."
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  ".game."

@rem Delete rows containing "Huaweigame.game_api" in Com/huawei/android/hms/agent/common/apiclientmgr.java
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  "HuaweiGame.GAME_API"

@rem Delete class with Name "Game" in Com/huawei/android/hms/agent/hmsagent.java
java -jar "%CURPATH%tool/tools.jar" -m delBlock "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  "class Game"

@rem Delete a line in Com/huawei/android/hms/agent/hmsagent.java that contains ". Game."
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java" ".game."
)  else (
set NEEDPAY=1
set NEEDHWID=0
)

if [%NEEDPAY%] == [] (
set /p NEEDPAY=Do you need to integrate "pay" £¨1 for required, 0 for No £©  £º
)

@rem No integration payments are required£º
if  %NEEDPAY% == 0 (
@rem Delete "Com/huawei/android/hms/agent/pay" folder and content
java -jar "%CURPATH%tool/tools.jar"  -m delFile "%CURPATH%copysrc/java/com/huawei/android/hms/agent/pay"

@rem Delete a line in Com/huawei/android/hms/agent/common/apiclientmgr.java that contains ". Pay."
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  ".pay."

@rem Delete rows containing Huaweipay.pay_api in Com/huawei/android/hms/agent/common/apiclientmgr.java
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  "HuaweiPay.PAY_API"

@rem Delete class with name Pay in Com/huawei/android/hms/agent/hmsagent.java
java -jar "%CURPATH%tool/tools.jar" -m delBlock "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  "class Pay"

@rem  Delete a line in Com/huawei/android/hms/agent/hmsagent.java that contains ". Pay."
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  ".pay."

@rem  Only integrated games or payments have cpid
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "cpid"
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "pay"
)

if [%NEEDHWID%] == [] (
set /p NEEDHWID=Do you need to integrate "Huawei ID" £¨1 for required, 0 means not required £©£º
)

@rem No need to integrate Huawei ID£º
if  %NEEDHWID% == 0  (
@rem Delete com/huawei/android/hms/agent/hwid folder and content
java -jar "%CURPATH%tool/tools.jar"  -m delFile "%CURPATH%copysrc/java/com/huawei/android/hms/agent/hwid"

@rem Delete a line in Com/huawei/android/hms/agent/common/apiclientmgr.java that contains ". Hwid."
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  ".hwid."

@rem Delete rows containing huaweiid in Com/huawei/android/hms/agent/common/apiclientmgr.java
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  "HuaweiId"

@rem Delete class with name Hwid in Com/huawei/android/hms/agent/hmsagent.java
java -jar "%CURPATH%tool/tools.jar" -m delBlock "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  "class Hwid"

@rem Delete a line in Com/huawei/android/hms/agent/hmsagent.java that contains ". Hwid."
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  ".hwid."

@rem Delete manifest file hwid configuration
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "account"
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "HMSSignInAgentActivity"
)

if [%NEEDSNS%] == [] (
set /p NEEDSNS=Do you need to integrate "SNS" £¨1 for need, 0 for No £© £º
)

@rem No need to integrate sns£º
if  %NEEDSNS% == 0 (
@rem Delete com/huawei/android/hms/agent/sns folder and content
java -jar "%CURPATH%tool/tools.jar"  -m delFile "%CURPATH%copysrc/java/com/huawei/android/hms/agent/sns"

@rem Delete the line in the com/huawei/android/hms/agent/common/apiclientmgr.java that contains ". Sns."
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  ".sns."

@rem  Delete rows containing Huaweisns.api in com/huawei/android/hms/agent/common/apiclientmgr.java
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  "HuaweiSns.API"

@rem Delete a class named Sns in Com/huawei/android/hms/agent/hmsagent.java
java -jar "%CURPATH%tool/tools.jar" -m delBlock "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  "class Sns"

@rem Delete the line in the Com/huawei/android/hms/agent/hmsagent.java that contains ". Sns."
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  ".sns."
)

if [%NEEDPUSH%] == [] (
set /p NEEDPUSH=Do you need to integrate "Push" £¨1 for required, 0 for No £© £º
)

@rem No integration push is required£º
if  %NEEDPUSH% == 0 (
@rem Delete Com/huawei/android/hms/agent/push folder and content
java -jar "%CURPATH%tool/tools.jar"  -m delFile "%CURPATH%copysrc/java/com/huawei/android/hms/agent/push"

@rem Delete the line in the Com/huawei/android/hms/agent/common/apiclientmgr.java that contains ". Push."
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  ".push."

@rem Delete rows containing Huaweipush.push_api in Com/huawei/android/hms/agent/common/apiclientmgr.java
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  "HuaweiPush.PUSH_API"

@rem Delete class with name Push in Com/huawei/android/hms/agent/hmsagent.java
java -jar "%CURPATH%tool/tools.jar" -m delBlock "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  "class Push"

@rem Delete the line in the Com/huawei/android/hms/agent/hmsagent.java that contains ". Push."
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  ".push."

@rem Delete manifest file push configuration
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "PUSH"
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "push"
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "Push"
)

echo.
echo.
echo The "copysrc" folder in the script sibling directory is the extracted code, which copies the code in your engineering code
echo Press any key to end &pause>nul

:IF_EXIST
SETLOCAL&PATH %PATH%;%~dp0;%cd%
if "%~$PATH:1"=="" exit /b 1
exit /b 0