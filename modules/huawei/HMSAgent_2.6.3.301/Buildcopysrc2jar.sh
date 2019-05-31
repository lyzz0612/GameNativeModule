#!/bin/sh

HMSSDKVER="2.6.3.300"
MAVENURL="http://developer.huawei.com/repo"

echo 
echo      "*********************************************************************************************************************"
echo      "*                                                                                                                   *"
echo      "*    此工具作用为：将同目录下copysrc/java 文件夹下的代码编译生成jar包。                                             *"
echo      "*    This tool works by compiling code under the Copysrc/java folder in the same directory to generate JAR packages.*"
echo      "*        生成的jar包路径为 copysrc/HMSAgent_${HMSSDKVER}.jar                                                           *"
echo      "*        The generated jar package path is copysrc/HMSAgent_${HMSSDKVER}.jar                                           *"
echo      "*                                                                                                                   *"
echo      "*    编译过程需要 jdk 和 android.jar 请准备                                                                         *"
echo      "*    The compilation process requires JDK and Android.jar, please prepare                                           *"
echo      "*                                                                                                                   *"
echo      "*********************************************************************************************************************"
echo 

# Determine the Java command to use to start the JVM.
if [ -n "$JAVA_HOME" ] ; then
    if [ -x "$JAVA_HOME/jre/sh/java" ] ; then
        # IBM's JDK on AIX uses strange locations for the executables
        JAVACMD="$JAVA_HOME/jre/sh/java"
    else
        JAVACMD="$JAVA_HOME/bin/java"
    fi
    if [ ! -x "$JAVACMD" ] ; then
        die "ERROR: JAVA_HOME is set to an invalid directory: $JAVA_HOME

Please set the JAVA_HOME variable in your environment to match the
location of your Java installation."
    fi
else
    JAVACMD="java"
    which java >/dev/null 2>&1 || die "ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
Please set the JAVA_HOME variable in your environment to match the
location of your Java installation."
fi

echo ${JAVACMD} 


# Determine the Java command to use to start the JVM.
if [ -n "$JAVA_HOME" ] ; then
    if [ -x "$JAVA_HOME/jre/sh/javac" ] ; then
        # IBM's JDK on AIX uses strange locations for the executables
        JAVACCMD="$JAVA_HOME/jre/sh/javac"
    else
        JAVACCMD="$JAVA_HOME/bin/javac"
    fi
    if [ ! -x "$JAVACCMD" ] ; then
        die "ERROR: JAVA_HOME is set to an invalid directory: $JAVA_HOME

Please set the JAVA_HOME variable in your environment to match the
location of your Java installation."
    fi
else
    JAVACCMD="javac"
    which java >/dev/null 2>&1 || die "ERROR: JAVA_HOME is not set and no 'javac' command could be found in your PATH.
Please set the JAVA_HOME variable in your environment to match the
location of your Java installation."
fi
echo ${JAVACCMD} 

# 输入android.jar 路径 | Enter Android.jar path
echo "请输入android.jar 文件的全路径（例如：/usr/testuser/software/android-sdk/android.jar ）"
echo "Please enter a full path to the Android.jar file (for example:/usr/testuser/software/android-sdk/android.jar):"
read ANDROIDJAR


# 取得当前路径 | Get current path
CURPATH="$( cd "$( dirname "$0"  )" && pwd)/"


# 创建临时文件夹 | Create a temporary folder
mkdir "${CURPATH}bin"
mkdir "${CURPATH}libs"
mkdir "${CURPATH}aars"

# 下载HMS-SDK  |  Download HMS-SDK
echo "将要下载HMS SDK 包"
echo "The HMS SDK package will be downloaded"

echo  "${MAVENURL}/com/huawei/android/hms/base/${HMSSDKVER}/base-${HMSSDKVER}.aar"
echo  "${MAVENURL}/com/huawei/android/hms/sns/${HMSSDKVER}/sns-${HMSSDKVER}.aar"
echo  "${MAVENURL}/com/huawei/android/hms/push/${HMSSDKVER}/push-${HMSSDKVER}.aar "
echo  "${MAVENURL}/com/huawei/android/hms/iap/${HMSSDKVER}/iap-${HMSSDKVER}.aar"
echo  "${MAVENURL}/com/huawei/android/hms/hwid/${HMSSDKVER}/hwid-${HMSSDKVER}.aar"
echo  "${MAVENURL}/com/huawei/android/hms/game/${HMSSDKVER}/game-${HMSSDKVER}.aar"
echo ""
echo "如果你的电脑网络有问题下载不了，请手动从别处下载，放到 ${CURPATH}aars 下面"
echo "If your computer network has trouble downloading, please download it manually from elsewhere, put it under  ${curpath}aars"

${JAVACMD} -jar "${CURPATH}tool/tools.jar" -m download "${MAVENURL}/com/huawei/android/hms/base/${HMSSDKVER}/base-${HMSSDKVER}.aar"  "${CURPATH}aars"
${JAVACMD} -jar "${CURPATH}tool/tools.jar" -m download "${MAVENURL}/com/huawei/android/hms/sns/${HMSSDKVER}/sns-${HMSSDKVER}.aar"  "${CURPATH}aars"
${JAVACMD} -jar "${CURPATH}tool/tools.jar" -m download "${MAVENURL}/com/huawei/android/hms/push/${HMSSDKVER}/push-${HMSSDKVER}.aar"  "${CURPATH}aars"
${JAVACMD} -jar "${CURPATH}tool/tools.jar" -m download "${MAVENURL}/com/huawei/android/hms/iap/${HMSSDKVER}/iap-${HMSSDKVER}.aar"  "${CURPATH}aars"
${JAVACMD} -jar "${CURPATH}tool/tools.jar" -m download "${MAVENURL}/com/huawei/android/hms/hwid/${HMSSDKVER}/hwid-${HMSSDKVER}.aar"  "${CURPATH}aars"
${JAVACMD} -jar "${CURPATH}tool/tools.jar" -m download "${MAVENURL}/com/huawei/android/hms/game/${HMSSDKVER}/game-${HMSSDKVER}.aar"  "${CURPATH}aars"

# 抽取里面的jar包放到libs下面供编译依赖 | Extract the jar package inside and place it under Libs for compilation dependencies
for file in `ls "${CURPATH}aars/"`
do
    if test -f "${CURPATH}aars/$file"  && [[ ${file##*.} == "aar" ]]
    then
        ${JAVACMD} -jar "${CURPATH}tool/tools.jar" -m zipOut "${CURPATH}aars/$file"  classes.jar  "${CURPATH}libs/$(basename ${file} .aar).jar"
    fi
done

# # 拼接要编译的java文件 | Stitching Java files to compile
AGENT_JAVAS=""
cd "${CURPATH}copysrc/java"
function getdir(){
    for file in  `ls "$1"`
    do
        if test -f "${1}/$file"
        then
			if [ ${file##*.} == "java" ]
			then
			    AGENT_JAVAS="${AGENT_JAVAS}  ${1}/$file"
			fi
        else
            getdir "${1}/$file"
        fi
    done
}
getdir "${CURPATH}copysrc/java"
cd ../../
echo $AGENT_JAVAS

# 拼接依赖的HMSSDKjar包 | Mosaic Dependent Hmssdkjar Package
AGENT_LIBS=

for file in `ls "${CURPATH}libs/"`
do
    if test -f "${CURPATH}libs/$file"  && [[ ${file##*.} == "jar" ]]
    then
		if [ -n "${AGENT_LIBS}" ] ;then
		    AGENT_LIBS="${AGENT_LIBS}:${CURPATH}libs/$file"
		else 
			AGENT_LIBS="${CURPATH}libs/$file"
		fi
    fi
done

echo $AGENT_LIBS

# 使用javac命令编译 | Compiling with the Javac command
echo "${JAVACCMD} -encoding utf-8 -bootclasspath ${ANDROIDJAR} -classpath ${AGENT_LIBS}  -d ${CURPATH}bin ${AGENT_JAVAS}"
${JAVACCMD} -encoding utf-8 -bootclasspath ${ANDROIDJAR} -classpath ${AGENT_LIBS}  -d  "${CURPATH}bin" ${AGENT_JAVAS}

if [ $? == 0 ] ; then
	rm -rf  "${CURPATH}aars"
fi

# 将中间文件压缩成jar包 | Compress intermediate files into jar packages
${JAVACMD} -jar "${CURPATH}tool/tools.jar" -m zipIn "${CURPATH}copysrc/HMSAgent_${HMSSDKVER}.jar"  com  "${CURPATH}bin/com"

# 删除缓存文件夹 | Delete cache folder
rm -rf  "${CURPATH}bin"
rm -rf  "${CURPATH}libs"

echo ""
echo ""
echo "本次脚本执行生成的文件有:"
echo "The files generated by this script execution are:"
echo "copysrc/HMSAgent_${HMSSDKVER}.jar "
echo ""
echo "按回车键结束"
echo "Press ENTER to end"
read
