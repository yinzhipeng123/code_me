import subprocess
import ConfigParser

conf = ConfigParser.ConfigParser()
conf.read("which.conf")
filelist = conf.items("which")
for i in filelist:
    print i

    subprocess.call('xmllint  --format new/'+ i[1] + '.xml > format/'+ i[1] + '.xml',shell=True)