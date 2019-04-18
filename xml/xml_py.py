# -- coding: utf-8 --
import xml.etree.ElementTree as ET
import ConfigParser
import os
import shutil
shutil.rmtree('new')
os.mkdir("new")
conf = ConfigParser.ConfigParser()
conf.read("which.conf")
filelist = conf.items("which")
# filelist存放了哪些文件需要被修改
# filelist是个集合，需要遍历，i[1]是文件名

for i in filelist:
    xml_conf = ConfigParser.ConfigParser()

    xml_conf.read("old/" + i[1] + ".conf")
    xml_conflist = xml_conf.sections()
    # 获取配置文件章节
    tree = ET.parse("old/"+i[1] + ".xml")
    root = tree.getroot()
    # 解析i[1].xml文件，以hdfs-site.xml文件为例
    for a in xml_conflist:
        # 遍历每个章节写的内容
        xml_name = a
        # 章节名字就是要找的name节点
        xml_value = xml_conf.get(a, "value")
        # value是value节点
        xml_superposition = xml_conf.get(a, "superposition")
        # superposition的意思是value是不是可以追加，true表示可以追加，false表示只能覆盖
        xml_final_flag = xml_conf.has_option(a,"final")

        if xml_final_flag:
            xml_final=xml_conf.get(a,"final")



        if xml_superposition!="true" and xml_superposition!="false":
            print"错误！！！！superposition参数只能是true，false"
            exit()


        xml_action = xml_conf.get(a, "action")
        # action的意思是这个章节的值是要添加还是移除
        if xml_action!="add" and xml_action!="remove":
            print"错误！！！！xml_action参数只能是add，remove"
            exit()

        list = []
        for property in root.iter("property"):
            name = property.find("name").text

            list.append(name)
        #把hdfd.xml中的name都拿出来放到list中


        if xml_name in list:
            #判断该节点是否包含数值

            if xml_action == "add":
                #判断是否增加改节点
                if xml_superposition == "true":
                    # 判断该节点是否包含该数值

                    for property in root.findall('property'):
                        name = property.find('name').text
                        value = property.find('value').text

                        if name == xml_name:
                            value_list = value.split(',')
                            if xml_value not in value_list:
                                value_list.append(xml_value)
                                xml_value_str=",".join(value_list)
                                property.find('value').text=xml_value_str

                            if xml_final_flag:
                                try:
                                    property.find('final').text = xml_final
                                except AttributeError:
                                    final = ET.SubElement(property, 'final')
                                    final.text = xml_final


                else:

                    for property in root.findall('property'):
                        name = property.find('name').text
                        value = property.find('value').text
                        if name == xml_name:
                            if value!=xml_value:
                                property.find('value').text = xml_value
                            if xml_final_flag:
                                try:
                                    property.find('final').text = xml_final
                                except AttributeError:
                                    final = ET.SubElement(property, 'final')
                                    final.text = xml_final







            else:
                print "删除该节点"
                for property in root.findall('property'):
                    name = property.find('name').text
                    if name == xml_name:
                        root.remove(property)






        else:
            if xml_action=="add":

                property = ET.Element('property')
                name = ET.SubElement(property, 'name')
                name.text = xml_name
                value = ET.SubElement(property, 'value')
                value.text = xml_value
                if xml_final_flag:
                    final = ET.SubElement(property, 'final')
                    final.text = xml_final
                root.append(property)
            else:
                print "什么都不做"+xml_name
    print "-----处理完"+i[1] + ".xml"+"----"
    tree.write('new/'+i[1] +'.xml',encoding='utf-8',xml_declaration=True)





