#-*-coding:utf-8-*-
import os
import json
import sys

script_path,_ = os.path.split(sys.argv[0])
module_root = os.path.join(script_path, "../modules")
sys.path.append(os.path.abspath(module_root))

class ModuleManager:

    MODULE_LIST_FILE_NAME = "module_list.json"

    def __init__(self):
        self.module_list = {}
        if os.path.exists(ModuleManager.MODULE_LIST_FILE_NAME):
            self._init_module_list()
    
    def _init_module_list(self):
        self.module_list = {}
        with open(ModuleManager.MODULE_LIST_FILE_NAME, "rb") as file_obj:
            self.module_list = json.load(file_obj, encoding="utf-8")

    def _get_module_instance(self, module_name, target_folder, platform="all", template="simple"):
        if not os.path.exists(target_folder):
            print("target folder not exists: " + target_folder)
            raise ValueError
        if not self.module_list.has_key(module_name):
            print("module not exists: " + module_name)
            raise KeyError
        module_config = self.module_list[module_name]
        
        module_path = module_config.module_path
        path_list = module_path.split(".")
        class_name = module_config.class_name

        folder_module = __import__(module_path)
        module = getattr(folder_module, path_list[len(path_list) - 1])
        module_class = getattr(module, class_name)
        
        module_instance = module_class(target_folder, platform, template)
        return module_instance

    def install(self, module_name, target_folder, platform="all", template="simple"):
        module_instance = self._get_module_instance(module_name, target_folder, platform, template)
        if not module_instance:
            raise ValueError

        module_config = self.module_list[module_name]
        depend_list = module_config.depend_list
        for depend_module in depend_list:
            self.install(depend_module, target_folder, platform, template)
        
        if module_instance.isinstalled():
            return
        module_instance.install()

    def uninstall(self, module_name, target_folder, platform="all"):
        module_instance = self._get_module_instance(module_name, target_folder, platform, template)
        if not module_instance:
            raise ValueError
        if not module_instance.isinstalled():
            return
        module_instance.uninstall()

    def list_all(self):
        print("all modules: ")
        for module_name, module_config in self.module_list.items():
            print("%s" %(module_name))

    def list_installed(self, target_folder, platform="all", template="simple"):
        print("installed modules in %s %s %s: " %(target_folder, platform, template))
        for module_name, module_config in self.module_list.items():
            module_instance = self._get_module_instance(module_name, target_folder, platform, template)
            if module_instance and module_instance.isinstalled():
                print("%s" %(module_name))
            