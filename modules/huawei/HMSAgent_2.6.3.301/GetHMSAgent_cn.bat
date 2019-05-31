@echo off
setlocal enabledelayedexpansion

echo.
echo      *************************************************************************************************************
echo      *                                                                                                           *
echo      *    �˹�������Ϊ����ȫ���� HMSAgent ���룬��������ѡ��ɾ������Ҫ�Ĵ���                                     *
echo      *    Ŀǰȫ���������  ��Ϸ��֧������Ϊ�ʺš��罻��Push                                                     *
echo      *                                                                                                           *
echo      *    1���������pc�������⵼�½ű�ִ�в��ɹ��������ı��򿪽ű������ű�ע���ֶ�ɾ����ش���                  *
echo      *                                                                                                           *
echo      *    2����ȷ�����ű�����·���������ո�                                                                      *
echo      *                                                                                                           *
echo      *    3��������Ϸʱ�������֧��                                                                              *
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

CALL :IF_EXIST java.exe || echo ���ĵ��Բ�֧��java���������java����binĿ¼��ӵ�����������PATH�У� && pause>nul && exit

set CURPATH=%~dp0
set MANIFEST_CONFIG_NAME=AppManifestConfig.xml

if exist "%CURPATH%copysrc" rd /s /q "%CURPATH%copysrc"
xcopy "%CURPATH%hmsagents\src\main\java\*.*"  "%CURPATH%copysrc\java\" /s /e  /q>nul
xcopy "%CURPATH%config\%MANIFEST_CONFIG_NAME%"  "%CURPATH%copysrc\"  /q>nul

set /p PACKAGE_NAME= ������Ӧ�õİ���:
if not [%PACKAGE_NAME%] == [] (
java -jar "%CURPATH%tool/tools.jar" -m replace  -codeformat utf-8  "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "${PACKAGE_NAME}"  "%PACKAGE_NAME%"
)
echo.
set /p APPID=������appid����Դ�ڿ��������ˣ�http://developer.huawei.com/consumer/cn��������Ӧ�÷����appid:
if not [%APPID%] == [] (
java -jar "%CURPATH%tool/tools.jar" -m replace  -codeformat utf-8  "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "${APPID}"  "%APPID%"
)
echo.
set /p CPID=������cpid����Դ�ڿ��������ˣ�http://developer.huawei.com/consumer/cn��������Ӧ�÷����cpid �� ֧��id:
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
java -jar "%CURPATH%tool/tools.jar" -m replace  -codeformat utf-8 "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "android:name=\"com.huawei.hmsagent.HuaweiPushRevicer\""  "android:name=\"${�뽫�˴�˫�����ڵ������滻����������PushReceiver��}\""

echo.
set /p NEEDGAME= ����Ӧ���Ƿ��� ����Ϸ�� ��1��ʾ�ǣ� 0��ʾ�񣩣�
@rem ����Ҫ������Ϸ��
if  %NEEDGAME% == 0 (
@rem ɾ��com/huawei/android/hms/agent/game �ļ��м�����
java -jar "%CURPATH%tool/tools.jar"  -m delFile "%CURPATH%copysrc/java/com/huawei/android/hms/agent/game"

@rem ɾ��com/huawei/android/hms/agent/common/ApiClientMgr.java�а��� .game. ����
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  ".game."

@rem ɾ��com/huawei/android/hms/agent/common/ApiClientMgr.java�а��� HuaweiGame.GAME_API ����
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  "HuaweiGame.GAME_API"

@rem ɾ��com/huawei/android/hms/agent/HMSAgent.java������Ϊ Game ����
java -jar "%CURPATH%tool/tools.jar" -m delBlock "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  "class Game"

@rem ɾ��com/huawei/android/hms/agent/HMSAgent.java�а��� .game. ����
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java" ".game."
)  else (
set NEEDPAY=1
set NEEDHWID=0
)


if [%NEEDPAY%] == [] (
set /p NEEDPAY=���Ƿ���Ҫ���� ��֧���� ��1��ʾ��Ҫ�� 0��ʾ����Ҫ�� ��
)

@rem ����Ҫ����֧����
if  %NEEDPAY% == 0 (
@rem ɾ��com/huawei/android/hms/agent/pay �ļ��м�����
java -jar "%CURPATH%tool/tools.jar"  -m delFile "%CURPATH%copysrc/java/com/huawei/android/hms/agent/pay"

@rem ɾ��com/huawei/android/hms/agent/common/ApiClientMgr.java�а��� .pay. ����
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  ".pay."

@rem ɾ��com/huawei/android/hms/agent/common/ApiClientMgr.java�а��� HuaweiPay.PAY_API ����
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  "HuaweiPay.PAY_API"

@rem ɾ��com/huawei/android/hms/agent/HMSAgent.java������Ϊ Pay ����
java -jar "%CURPATH%tool/tools.jar" -m delBlock "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  "class Pay"

@rem ɾ��com/huawei/android/hms/agent/HMSAgent.java�а��� .pay. ����
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  ".pay."

@rem  ֻ�м�����Ϸ��֧������cpid
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "cpid"
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "pay"
)

if [%NEEDHWID%] == [] (
set /p NEEDHWID=���Ƿ���Ҫ���� ����Ϊ�ʺš� ��1��ʾ��Ҫ�� 0��ʾ����Ҫ����
)

@rem ����Ҫ���ɻ�Ϊ�ʺ���
if  %NEEDHWID% == 0  (
@rem ɾ��com/huawei/android/hms/agent/hwid �ļ��м�����
java -jar "%CURPATH%tool/tools.jar"  -m delFile "%CURPATH%copysrc/java/com/huawei/android/hms/agent/hwid"

@rem ɾ��com/huawei/android/hms/agent/common/ApiClientMgr.java�а��� .hwid. ����
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  ".hwid."

@rem ɾ��com/huawei/android/hms/agent/common/ApiClientMgr.java�а��� HuaweiId ����
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  "HuaweiId"

@rem ɾ��com/huawei/android/hms/agent/HMSAgent.java������Ϊ Hwid ����
java -jar "%CURPATH%tool/tools.jar" -m delBlock "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  "class Hwid"

@rem ɾ��com/huawei/android/hms/agent/HMSAgent.java�а��� .hwid. ����
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  ".hwid."

@rem ɾ��manifest�ļ���Ϊ�ʺ�����
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "account"
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "HMSSignInAgentActivity"
)

if [%NEEDSNS%] == [] (
set /p NEEDSNS=���Ƿ���Ҫ���� ���罻�� ��1��ʾ��Ҫ�� 0��ʾ����Ҫ�� ��
)

@rem ����Ҫ�����罻��
if  %NEEDSNS% == 0 (
@rem ɾ��com/huawei/android/hms/agent/sns �ļ��м�����
java -jar "%CURPATH%tool/tools.jar"  -m delFile "%CURPATH%copysrc/java/com/huawei/android/hms/agent/sns"

@rem ɾ��com/huawei/android/hms/agent/common/ApiClientMgr.java�а��� .sns. ����
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  ".sns."

@rem ɾ��com/huawei/android/hms/agent/common/ApiClientMgr.java�а��� HuaweiSns.API ����
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  "HuaweiSns.API"

@rem ɾ��com/huawei/android/hms/agent/HMSAgent.java������Ϊ Sns ����
java -jar "%CURPATH%tool/tools.jar" -m delBlock "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  "class Sns"

@rem ɾ��com/huawei/android/hms/agent/HMSAgent.java�а��� .sns. ����
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  ".sns."
)

if [%NEEDPUSH%] == [] (
set /p NEEDPUSH=���Ƿ���Ҫ���� ��Push�� ��1��ʾ��Ҫ�� 0��ʾ����Ҫ�� ��
)

@rem ����Ҫ����Push��
if  %NEEDPUSH% == 0 (
@rem ɾ��com/huawei/android/hms/agent/push �ļ��м�����
java -jar "%CURPATH%tool/tools.jar"  -m delFile "%CURPATH%copysrc/java/com/huawei/android/hms/agent/push"

@rem ɾ��com/huawei/android/hms/agent/common/ApiClientMgr.java�а��� .push. ����
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  ".push."

@rem ɾ��com/huawei/android/hms/agent/common/ApiClientMgr.java�а��� HuaweiPush.PUSH_API ����
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  "HuaweiPush.PUSH_API"

@rem ɾ��com/huawei/android/hms/agent/HMSAgent.java������Ϊ Push ����
java -jar "%CURPATH%tool/tools.jar" -m delBlock "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  "class Push"

@rem ɾ��com/huawei/android/hms/agent/HMSAgent.java�а��� .push. ����
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  ".push."

@rem ɾ��manifest�ļ�push����
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "PUSH"
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "push"
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "Push"
)

echo.
echo.
echo �ű�ͬ��Ŀ¼�µ� copysrc ���漴Ϊ��ȡ��Ĵ��룬�ɽ�����Ĵ��뿽�������Ĺ��̴�����
echo ����������� &pause>nul

:IF_EXIST
SETLOCAL&PATH %PATH%;%~dp0;%cd%
if "%~$PATH:1"=="" exit /b 1
exit /b 0