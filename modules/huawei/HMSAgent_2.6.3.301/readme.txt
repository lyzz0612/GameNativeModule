此目录下包含的几个特殊文件夹和文件作用说明如下：

HMSAgent 相关：
1、config 文件夹
		集成HMS SDK的应用可以参考AppManifestConfig.xml配置AndroidManifest.xml

2、hmsagents 文件夹
		agent 代码模块（包含所有HMS模块）

3、tool 文件夹
		同目录下批处理执行需要的工具包

4、GetHMSAgent_*.bat、GetHMSAgent_*.sh 脚本文件
		从agent 代码模块（hmsagents 文件夹）中抽取需要模块的agent代码。抽取后的代码放在了同目录下的copysrc目录下
		GetHMSAgent_cn.bat为中文脚本
		GetHMSAgent_oversea.bat为英文脚本

5、Buildcopysrc2jar.bat、Buildcopysrc2jar.sh 批处理文件
        用来将GetHMSAgent.bat 生成的代码（copysrc目录下）编译成jar包。 仅必须使用jar包的场景才使用此脚本，建议按步骤4直接拷贝代码。

