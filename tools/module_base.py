#-*-coding:utf-8-*-
import os

class ModuleBase:

    def __init__(self, target_folder, platform, template):
        self.target_folder = target_folder
        self.platform = platform
        self.template = template

    def isinstalled(self):
        return True

    def install(self):
        pass

    def uninstall(self):
        pass