import shutil
import configparser
import subprocess

conf = configparser.ConfigParser()
conf.read("copy_xml_conf.conf")

target =conf.get("target", "target") #目的目录


filelist = conf.items("which")
for i in filelist:
    # shutil.copy(i[1],target)
    print('sshpass -p '+ password + ' scp '+i[1].split(',')[0]+' '+target)
    subprocess.call('sshpass -p '+ password + ' scp '+i[1].split(',')[0]+' '+target, shell=True)
