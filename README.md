# GameNativeModule
游戏常用原生功能模块化，如浏览器、剪切板，微信登录，友盟分享



## 模块管理

`module_manager.py`

```
Usage: python module_manager.py [OPTION] 
模块管理。
-d 项目目录, --destination 项目目录		指定模块安放目录
-p 平台, --platform 平台               指定平台，android, ios
-t 模板, --template 模板             	使用模板，默认为simple,可选为cocos
                                      simple需要-p指定平台,此时项目目录即为对应的工程目录
                                      cocos项目目录为新建的工程目录，会去项目目录下的											    framework/runtime-src/下寻找工程，
                                        -p可限定指定平台工程，否则ios和android都会处理
                                      
-l, --list                           列出项目目录已安装的模块
-a, --all                            列出所有可安装的模块
-i 模块名, --install 模块名            安装指定模块
-u 模块名， --uninstall 模块名          移除指定模块
```





## 模块引入标准

1. 安卓模块以依赖库形式引入项目，ios以子工程形式引入

2. 需要`setup.py`提供安装和卸载模块操作，将会分别调用**`python setup.py install 项目目录`**和**`python setup.py uninstall 项目目录`**
3. 需要`README`告知安装成功后需要进行哪些配置和如何使用