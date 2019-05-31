#-*-coding:utf-8-*-
import os

class ModuleBase:

    def __init__(self, target_folder, platform, template):
        self.target_folder = target_folder
        self.platform = platform
        self.template = template
    
    def _add_maven_repository(self, gradle_file):
        with open(gradle_file, "r") as file_obj:
            all_text = file_obj.read()
            file_obj.close()
            
    def isinstalled(self):
        return True

    def install(self):
        pass

    def uninstall(self):
        pass