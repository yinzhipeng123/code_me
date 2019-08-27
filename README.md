# code_me
# 大数据xml内容增删工具
假如你有个大数据相关的项目的配置文件，内容格式如下
```xml
<configuration>  
<property>  
<name>yinzhipeng</name>  
<value>zhangli</value> 
<final>false</final>
</property>  
</configuration>  
```

那么就可以通过该项目，快速的修改你要的配置文件，  

首先在old目录下，创建配置文件  
假如你要写个hiveserver2-site.xml的配置
在old目录下，写个hiveserver2-site.conf配置文件即可  
名字要一样，后缀不一样，是conf结尾  
```bash
[yinzhipeng]  #这个是name的名字
value = yinzhipeng #这个是value的值
superposition = true  #这个value是不是用逗号分隔的，true代表是的，false说明这个value值只有一个值，且是唯一的值  
action = add  #add是增加这个property节点还是移除property这个节点，想要移除，这里填写remove  
final = false # 这个property的final值是true还有false，hadoop的配置文件中，有的property会有final值  
```

然后把要修改的xml放到old目录下
把hiveserver2-site.xml放到old目录下   
会读取这个hiveserver2-site.xml的内容，修改完后，会在format目录下  
生成新的修改好的hiveserver2-site.xml文件


然后在which.xml中，指定下要修改哪个文件  
```bash
7=hiveserver2-site  #需要序号，序号随便写，然后=后加文件名，不要后缀 
```

然后执行python3 xml_py.py  
在format文件夹下就会生成新的修改好的配置了

对了，这个脚本只能在Linux平台下用，需要xmllint命令，主要用这个命令进行美化    
安装命令如下  
centos安装 yum install -y libxml2-utils

ubuntu安装 apt-get install libxml2-utils