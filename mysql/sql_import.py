#!/usr/bin/python
# coding=UTF-8
import ConfigParser
import MySQLdb

cf = ConfigParser.ConfigParser(allow_no_value=True)
cf.read('sql.conf')
#设置数据库连接
host = cf.get('mysql', 'host')
database = cf.get('mysql', 'database')
user = cf.get('mysql', 'user')
password = cf.get('mysql', 'password')
db = MySQLdb.connect(host, user, password, database, charset='utf8')
cursor = db.cursor()

#取消数据库主键关联
cursor.execute('SET foreign_key_checks=0;')
#截断表
cursor.execute("truncate table t_host_role;")
cursor.execute('truncate table t_host_component;')
cursor.execute('truncate table t_host;')
#恢复数据集主键关联
cursor.execute('SET foreign_key_checks=1;')
db.commit()
#修改t_host和t_host_role数据表的值
cg = ConfigParser.ConfigParser(allow_no_value=True)
cg.read('t_host_and_t_host_role.conf')
sections = cg.sections()
for a in sections:
    if a == "hosts":
        hostslist = cg.items("hosts")
        for i in hostslist:
            hostname = i[0]
            ipaddr = i[1]
            int1 = 0
            cursor.execute(
                "insert into t_host (name,ip,status) values ('%s','%s','%d')" % (hostname, ipaddr, int1))
            db.commit()
        continue
    cursor.execute('select role_id from t_function_role where name="%s"' % a)
    role_id = cursor.fetchone()
    hostlist = cg.items(a)
    for b in hostlist:
        ipaddr = b[1]
        cursor.execute('select host_id from t_host where ip="%s"' % ipaddr)
        host_id = cursor.fetchone()
        cursor.execute('insert into t_host_role (host_id,role_id) values ("%d","%d")' % (host_id[0], role_id[0]))
        db.commit()

#修改t_host_commpont_的值
ci = ConfigParser.ConfigParser(allow_no_value=True)
ci.read('t_host_component.conf')
sections = ci.sections()
for i in sections:
    cursor.execute('select id from t_component where name="%s"' % i)
    component_id = cursor.fetchone()
    hostlist = ci.items(i)
    for c in hostlist:
        ipaddr = c[1]
        cursor.execute('select host_id from t_host where ip="%s"' % ipaddr)
        host_id = cursor.fetchone()
        int2 = 0
        cursor.execute('insert into t_host_component (host_id,component_id,status) values ("%d","%d","%d")' % (host_id[0] , component_id[0],int2))
        db.commit()

ck = ConfigParser.ConfigParser(allow_no_value=True)
ck.read('t_component.conf')
sections = ck.sections()
for n in sections:

    pathvalue = ck.get(n, "path")
    cursor.execute('update t_component set install_path=%s where name =%s ',(pathvalue,n))
    db.commit()


cl = ConfigParser.ConfigParser(allow_no_value=True)

cl.read('t_host_and_t_host_role.conf')
resturllsit = cl.items("rest")
resturl = resturllsit[0][1]



cursor.execute('select metric_name from t_alarm_rule_default where role !="xcloud"')
data = cursor.fetchall()
for j in data:
    yuanstr =j[0].encode('utf-8')

    xinstr = j[0].encode('utf-8').replace('999.999.999.999', resturl)

    cursor.execute('update t_alarm_rule_default set metric_name=%s where metric_name=%s',(xinstr,yuanstr))
    db.commit()


print 'succeeded'
db.close()
