#-*-coding:utf-8-*-
import os
from module_base import ModuleBase

class BaseModule(ModuleBase):
    
    def __init__(self, target_folder, platform, template):
        super.__init__(self, target_folder, platform, template)
    
    def isinstalled(self):
        return True

    def install(self):
        pass

    def uninstall(self):
        pass