# -*- coding: utf-8 -*-
import os
import urllib2
import json
import csv
import ConfigParser
import time
#获取配置文件中参数
work_dir = os.path.dirname(os.path.abspath(__file__))
es_conf = os.path.join(work_dir,'es.conf')
conf = ConfigParser.ConfigParser()
conf.read(es_conf)

#获取要从哪台主机获取数据
eshost=conf.get("base","eshost")

result=conf.get("base","result")

#Python文件是否要加入到计划任务中
escron=conf.get("base","cron")
if escron=="yes":
    date = time.strftime('%Y-%m-%d', time.localtime(time.time()))
    csvtime = mytime= time.strftime('%Y-%m-%d-%H-%M-%S',time.localtime(time.time()))
else:
    date=conf.get("base","date")
    csvtime = mytime = time.strftime('%Y-%m-%d-%H-%M-%S', time.localtime(time.time()))
print date
print csvtime

es_name=conf.get("base","es_name")
#获取json的方法
def jsonPost(eshost,date,es_name,role,hostname):
    requrl = "http://" + eshost + ":9200/ordiraryjournal" + date + "--" + es_name + "/" + role + "/_count?pretty"
    json_data ='{"query":{"match":{"hostname":"'+hostname+'"}}}'
    req=urllib2.Request(url=requrl,data =json_data)
    res=urllib2.urlopen(req)
    page_json=res.read()
    res.close()
    print "----------------"
    return page_json

#把hosts文件读取出来
work_dir = os.path.dirname(os.path.abspath(__file__))
hosts_conf = os.path.join(work_dir,'hosts')
hostsfile = hosts_conf
def read_hosts(file):
    with open(file, 'r') as fs:
        data = fs.readlines()
    return data

#统计hosts多少行
datas2 = read_hosts(hostsfile)
biaochang=0
for i in datas2:
    biaochang=biaochang+1




#获取角色列表
rolelist = conf.items("role")
#长是角色个数
chang= len(rolelist)
rolejishu=0

#生成宽是角色个数+1，长是主机列表个数的二维数组
a2 = []
for i in range(biaochang+2):
    a2.append([])
    for j in range(chang+1):
        a2[i].append(0)

datas = read_hosts(hostsfile)
#按列进行填值
for i in rolelist:
    #获取角色名字
    role=i[1]
    print role
    datejishu1 = 0
    #宽是主机列表
    kuan=len(datas)

    for i in  datas:
        hostname=i.split()[1]
        print hostname
        jsonstring=jsonPost(eshost,date,es_name,role,hostname)
        jsonzhi=json.loads(jsonstring)
        print jsonzhi['count']
        countzhi=jsonzhi['count']
        #首先往列表里，第一行，第二列添加值，然后往第二行，第二列添加值
        a2[datejishu1][rolejishu+1] = countzhi
        datejishu1 = datejishu1 + 1

    rolejishu = rolejishu +1



datajishu2=0
for a in datas:
    hostname2 = a.split()[1]
    print hostname2
    #然后往列表里，第一列里添加主机名
    a2[datajishu2][0] = hostname2
    datajishu2=datajishu2+1


print a2


#添加表头，[主机名，namenode日志条数,datanode日志条数,...]
biaotou=["主机名"]
for o in rolelist:
    biaotou.append(o[1]+"日志条数")

#列表最前面插入表头
a2.insert(0,biaotou)


#把list转成CSV方法
def createListCSV(fileName, dataList):
    with open(fileName, "wb") as csvFile:
        csvWriter = csv.writer(csvFile)
        for data in dataList:
            csvWriter.writerow(data)
        csvFile.close


csvfile = result+"es"+csvtime+".csv"
createListCSV(csvfile,a2)






#curl -XGET '172.16.31.154:9200/ordiraryjournal2019-03-30--es_147/datanode/_count?pretty' -d '{"query":{"match":{"hostname":"hadoop104"}}}'
