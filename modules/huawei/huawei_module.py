#-*-coding:utf-8-*-
import os
import shutil
import platform
from module_base import ModuleBase

class HuweiModule(ModuleBase):
    HMSAGENT_FOLDER = "HMSAgent_2.6.3.301/"

    def __init__(self, target_folder, platform, template):
        super.__init__(self, target_folder, platform, template)
    
    def _generate_agent(self):
        target_folder = HMSAGENT_FOLDER + "copysrc"
        if os.path.exists(target_folder):
            choice = input("agent target folder exists, re-generate?(y/n)")
            if choice != "y" and choice != "Y":
                return
        shutil.rmtree(target_folder)
        if platform.system() == "Windows":
            script_file = os.path.abspath(HMSAGENT_FOLDER + "GetHMSAgent_cn.bat")
            os.system(script_file)
        else:
            script_file = os.path.abspath(HMSAGENT_FOLDER + "GetHMSAgent_cn.sh")
            os.system(script_file)
        
    def isinstalled(self):
        return True

    def install(self):
        pass

    def uninstall(self):
        pass