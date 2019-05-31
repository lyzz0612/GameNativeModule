@echo off
setlocal enabledelayedexpansion

echo.
echo      *************************************************************************************************************
echo      *                                                                                                           *
echo      *    此工具作用为：从全量的 HMSAgent 代码，根据您的选择删除不需要的代码                                     *
echo      *    目前全量代码包括  游戏、支付、华为帐号、社交、Push                                                     *
echo      *                                                                                                           *
echo      *    1、如果由于pc环境问题导致脚本执行不成功，请用文本打开脚本，按脚本注释手动删除相关代码                  *
echo      *                                                                                                           *
echo      *    2、请确保本脚本所在路径不包含空格                                                                      *
echo      *                                                                                                           *
echo      *    3、接入游戏时必须接入支付                                                                              *
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

CALL :IF_EXIST java.exe || echo 您的电脑不支持java命令，请下载java并将bin目录添加到环境变量的PATH中！ && pause>nul && exit

set CURPATH=%~dp0
set MANIFEST_CONFIG_NAME=AppManifestConfig.xml

if exist "%CURPATH%copysrc" rd /s /q "%CURPATH%copysrc"
xcopy "%CURPATH%hmsagents\src\main\java\*.*"  "%CURPATH%copysrc\java\" /s /e  /q>nul
xcopy "%CURPATH%config\%MANIFEST_CONFIG_NAME%"  "%CURPATH%copysrc\"  /q>nul

set /p PACKAGE_NAME= 请输入应用的包名:
if not [%PACKAGE_NAME%] == [] (
java -jar "%CURPATH%tool/tools.jar" -m replace  -codeformat utf-8  "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "${PACKAGE_NAME}"  "%PACKAGE_NAME%"
)
echo.
set /p APPID=请输入appid，来源于开发者联盟（http://developer.huawei.com/consumer/cn）上申请应用分配的appid:
if not [%APPID%] == [] (
java -jar "%CURPATH%tool/tools.jar" -m replace  -codeformat utf-8  "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "${APPID}"  "%APPID%"
)
echo.
set /p CPID=请输入cpid，来源于开发者联盟（http://developer.huawei.com/consumer/cn）上申请应用分配的cpid 或 支付id:
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
java -jar "%CURPATH%tool/tools.jar" -m replace  -codeformat utf-8 "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "android:name=\"com.huawei.hmsagent.HuaweiPushRevicer\""  "android:name=\"${请将此处双引号内的内容替换成您创建的PushReceiver类}\""

echo.
set /p NEEDGAME= 您的应用是否是 “游戏” （1表示是， 0表示否）：
@rem 不需要集成游戏则
if  %NEEDGAME% == 0 (
@rem 删除com/huawei/android/hms/agent/game 文件夹及内容
java -jar "%CURPATH%tool/tools.jar"  -m delFile "%CURPATH%copysrc/java/com/huawei/android/hms/agent/game"

@rem 删除com/huawei/android/hms/agent/common/ApiClientMgr.java中包含 .game. 的行
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  ".game."

@rem 删除com/huawei/android/hms/agent/common/ApiClientMgr.java中包含 HuaweiGame.GAME_API 的行
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  "HuaweiGame.GAME_API"

@rem 删除com/huawei/android/hms/agent/HMSAgent.java中名称为 Game 的类
java -jar "%CURPATH%tool/tools.jar" -m delBlock "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  "class Game"

@rem 删除com/huawei/android/hms/agent/HMSAgent.java中包含 .game. 的行
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java" ".game."
)  else (
set NEEDPAY=1
set NEEDHWID=0
)


if [%NEEDPAY%] == [] (
set /p NEEDPAY=您是否需要集成 “支付” （1表示需要， 0表示不需要） ：
)

@rem 不需要集成支付则
if  %NEEDPAY% == 0 (
@rem 删除com/huawei/android/hms/agent/pay 文件夹及内容
java -jar "%CURPATH%tool/tools.jar"  -m delFile "%CURPATH%copysrc/java/com/huawei/android/hms/agent/pay"

@rem 删除com/huawei/android/hms/agent/common/ApiClientMgr.java中包含 .pay. 的行
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  ".pay."

@rem 删除com/huawei/android/hms/agent/common/ApiClientMgr.java中包含 HuaweiPay.PAY_API 的行
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  "HuaweiPay.PAY_API"

@rem 删除com/huawei/android/hms/agent/HMSAgent.java中名称为 Pay 的类
java -jar "%CURPATH%tool/tools.jar" -m delBlock "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  "class Pay"

@rem 删除com/huawei/android/hms/agent/HMSAgent.java中包含 .pay. 的行
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  ".pay."

@rem  只有集成游戏或支付才有cpid
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "cpid"
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "pay"
)

if [%NEEDHWID%] == [] (
set /p NEEDHWID=您是否需要集成 “华为帐号” （1表示需要， 0表示不需要）：
)

@rem 不需要集成华为帐号则
if  %NEEDHWID% == 0  (
@rem 删除com/huawei/android/hms/agent/hwid 文件夹及内容
java -jar "%CURPATH%tool/tools.jar"  -m delFile "%CURPATH%copysrc/java/com/huawei/android/hms/agent/hwid"

@rem 删除com/huawei/android/hms/agent/common/ApiClientMgr.java中包含 .hwid. 的行
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  ".hwid."

@rem 删除com/huawei/android/hms/agent/common/ApiClientMgr.java中包含 HuaweiId 的行
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  "HuaweiId"

@rem 删除com/huawei/android/hms/agent/HMSAgent.java中名称为 Hwid 的类
java -jar "%CURPATH%tool/tools.jar" -m delBlock "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  "class Hwid"

@rem 删除com/huawei/android/hms/agent/HMSAgent.java中包含 .hwid. 的行
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  ".hwid."

@rem 删除manifest文件华为帐号配置
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "account"
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "HMSSignInAgentActivity"
)

if [%NEEDSNS%] == [] (
set /p NEEDSNS=您是否需要集成 “社交” （1表示需要， 0表示不需要） ：
)

@rem 不需要集成社交则
if  %NEEDSNS% == 0 (
@rem 删除com/huawei/android/hms/agent/sns 文件夹及内容
java -jar "%CURPATH%tool/tools.jar"  -m delFile "%CURPATH%copysrc/java/com/huawei/android/hms/agent/sns"

@rem 删除com/huawei/android/hms/agent/common/ApiClientMgr.java中包含 .sns. 的行
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  ".sns."

@rem 删除com/huawei/android/hms/agent/common/ApiClientMgr.java中包含 HuaweiSns.API 的行
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  "HuaweiSns.API"

@rem 删除com/huawei/android/hms/agent/HMSAgent.java中名称为 Sns 的类
java -jar "%CURPATH%tool/tools.jar" -m delBlock "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  "class Sns"

@rem 删除com/huawei/android/hms/agent/HMSAgent.java中包含 .sns. 的行
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  ".sns."
)

if [%NEEDPUSH%] == [] (
set /p NEEDPUSH=您是否需要集成 “Push” （1表示需要， 0表示不需要） ：
)

@rem 不需要集成Push则
if  %NEEDPUSH% == 0 (
@rem 删除com/huawei/android/hms/agent/push 文件夹及内容
java -jar "%CURPATH%tool/tools.jar"  -m delFile "%CURPATH%copysrc/java/com/huawei/android/hms/agent/push"

@rem 删除com/huawei/android/hms/agent/common/ApiClientMgr.java中包含 .push. 的行
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  ".push."

@rem 删除com/huawei/android/hms/agent/common/ApiClientMgr.java中包含 HuaweiPush.PUSH_API 的行
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  "HuaweiPush.PUSH_API"

@rem 删除com/huawei/android/hms/agent/HMSAgent.java中名称为 Push 的类
java -jar "%CURPATH%tool/tools.jar" -m delBlock "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  "class Push"

@rem 删除com/huawei/android/hms/agent/HMSAgent.java中包含 .push. 的行
java -jar "%CURPATH%tool/tools.jar" -m delLine "%CURPATH%copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  ".push."

@rem 删除manifest文件push配置
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "PUSH"
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "push"
java -jar "%CURPATH%tool/tools.jar" -m delXmlBlock "%CURPATH%copysrc\%MANIFEST_CONFIG_NAME%"  "Push"
)

echo.
echo.
echo 脚本同级目录下的 copysrc 里面即为抽取后的代码，可将里面的代码拷贝的您的工程代码中
echo 按任意键结束 &pause>nul

:IF_EXIST
SETLOCAL&PATH %PATH%;%~dp0;%cd%
if "%~$PATH:1"=="" exit /b 1
exit /b 0