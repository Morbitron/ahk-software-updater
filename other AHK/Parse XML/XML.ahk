﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


; func SSN() = Select Single Node
; func CreateElement() 
; func EA(XPath,attributes:="")
; func Get(XPath,Default) 
; func Get(XPath,Default) 
; func Get(XPath,Default) 
; func Get(XPath,Default) 

; def XPath https://docs.microsoft.com/en-us/dotnet/standard/data/xml/select-nodes-using-xpath-navigation
;			https://www.w3schools.com/xml/xpath_syntax.asp


; FUNCTION TO CreateElement
; FileRead, OutputVar, Filename
; FileAppend [, Text, Filename, Encoding]







xmlcontents=
(
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<options version="410">
	<!--group unity.Options-->
	<!--group unity.General-->
	<entryvalue ident="unity.AutoIncrementProjectVer" value="1">WOOR</entryvalue>
	<entryvalue ident="unity.AutoCompletion" value="1">bob</entryvalue>
	<entryvalue ident="unity.DisplayErrorMode" value="0">margaret</entryvalue>
	<entryvalue ident="unity.OpeninContextActive" value="1">plow</entryvalue>
	<entryvalue ident="unity.DisplayModifiedSections" value="1">me</entryvalue>
</options>
)

NewXML:=New XML("dick_cheese")
;NewXML.XML.LoadXML(xmlcontents)
;UnityPath:=NewXML.SSN("//*[@ident='unity.OpeninContextActive']/@value").text
UnityPath:=NewXML.SSN("//*[@ident='unity.OpeninContextActive']").text
UnityPath:=NewXML.Find("entryvalue")
MsgBox,%UnityPath%
;UnityPath:=NewXML.save
;MsgBox,%UnityPath%


NewXML.Save("poop.xml")







#SingleInstance,Force

Class XML{
	keep:=[]
	__Get(x=""){
		return this.XML.xml
	}
	
	;__New(root_tag_name, file_name, )
	__New(param*){
		;temp.preserveWhiteSpace:=1
		root := param.1
		root := root?root:"root"
		file := param.2
		file := file?file:root ".xml"
		temp := ComObjCreate("MSXML2.DOMDocument")
		this.xml:=temp
		this.file:=file
		XML.keep[root]:=this
		temp.SetProperty("SelectionLanguage","XPath")
		if(FileExist(file)){
			FileRead,info,%file%
			if(info=""){
				this.xml:=this.CreateElement(temp,root)
				FileDelete,%file%
			}else
				temp.LoadXML(info),this.xml:=temp
		}else
			this.xml:=this.CreateElement(temp,root)
	}
	
	
	Add(XPath,attributes:="",text:="",dup:=0){
		p:="/",add:=(next:=this.SSN("//" XPath))?1:0,last:=SubStr(XPath,InStr(XPath,"/",0,0)+1)
		if(!next.xml){
			next:=this.SSN("//*")
			for a,b in StrSplit(XPath,"/")
				p.="/" b,next:=(x:=this.SSN(p))?x:next.AppendChild(this.XML.CreateElement(b))
		}if(dup&&add)
			next:=next.ParentNode.AppendChild(this.XML.CreateElement(last))
		for a,b in attributes
			next.SetAttribute(a,b)
		if(text!="")
			next.text:=text
		return next
	}
	
	
	CreateElement(document,root){
		return document.AppendChild(this.XML.CreateElement(root)).ParentNode
	}
	
	
	EA(XPath,attributes:=""){
		list:=[]
		if(attributes)
			return XPath.NodeName?SSN(XPath,"@" attributes).text:this.SSN(XPath "/@" attributes).text
		nodes:=XPath.NodeName?XPath.SelectNodes("@*"):nodes:=this.SN(XPath "/@*")
		while(nn:=nodes.item[A_Index-1])
			list[nn.NodeName]:=nn.text
		return list
	}
	
	
	Find(info*){
		static last:=[]
		document:=info.1.NodeName?info.1:this.xml
		if(info.1.NodeName)
			node:=info.2,find:=info.3,return:=info.4!=""?"SelectNodes":"SelectSingleNode",search:=info.4
		else
			node:=info.1,find:=info.2,return:=info.3!=""?"SelectNodes":"SelectSingleNode",search:=info.3
		if(InStr(info.2,"descendant"))
			last.1:=info.1,last.2:=info.2,last.3:=info.3,last.4:=info.4
		if(InStr(find,"'"))
			return document[return](node "[.=concat('" RegExReplace(find,"'","'," Chr(34) "'" Chr(34) ",'") "')]/.." (search?"/" search:""))
		else
			return document[return](node "[.='" find "']/.." (search?"/" search:""))
	}
	
	
	Get(XPath,Default){
		text:=this.SSN(XPath).text
		return text?text:Default
	}
	
	
	ReCreate(XPath,new){
		rem:=this.SSN(XPath),rem.ParentNode.RemoveChild(rem),new:=this.Add(new)
		return new
	}
	
	
	Save(x*){
		if(x.1=1)
			this.Transform()
		if(this.XML.SelectSingleNode("*").xml="")
			return m("Errors happened while trying to save " this.file ". Reverting to old version of the XML")
		filename:=this.file?this.file:x.1.1,ff:=FileOpen(filename,0),text:=ff.Read(ff.length),ff.Close()
		if(!this[])
			return m("Error saving the " this.file " XML.  Please get in touch with maestrith if this happens often")
		if(text!=this[])
			file:=FileOpen(filename,"rw"),file.Seek(0),file.Write(this[]),file.Length(file.Position)
	}
	
	
	SSN(XPath){
		return this.XML.SelectSingleNode(XPath)
	}
	
	
	SN(XPath){
		return this.XML.SelectNodes(XPath)
	}
	
	
	Transform(){
		static
		if(!IsObject(xsl))
			xsl:=ComObjCreate("MSXML2.DOMdocumentument"),xsl.loadXML("<xsl:stylesheet version=""1.0"" xmlns:xsl=""http://www.w3.org/1999/XSL/Transform""><xsl:output method=""xml"" indent=""yes"" encoding=""UTF-8""/><xsl:template match=""@*|node()""><xsl:copy>`n<xsl:apply-templates select=""@*|node()""/><xsl:for-each select=""@*""><xsl:text></xsl:text></xsl:for-each></xsl:copy>`n</xsl:template>`n</xsl:stylesheet>"),style:=null
		this.XML.TransformNodeToObject(xsl,this.xml)
	}
	
	
	Under(under,node,attributes:="",text:="",list:=""){
		new:=under.AppendChild(this.XML.CreateElement(node)),new.text:=text
		for a,b in attributes
			new.SetAttribute(a,b)
		for a,b in StrSplit(list,",")
			new.SetAttribute(b,attributes[b])
		return new
	}
}


;Same as SSN
SelectSingleNode(node,XPath){
	return node.SelectSingleNode(XPath)
}


SSN(node,XPath){
	return node.SelectSingleNode(XPath)
}


;SelectNodes
SelectNodes(node,XPath){
	return node.SelectNodes(XPath)
}


SN(node,XPath){
	return node.SelectNodes(XPath)
}







;Message box function to handle errors
m(x*){
	active:=WinActive("A")
	ControlGetFocus,Focus,A
	ControlGet,hwnd,hwnd,,%Focus%,ahk_id%active%
	static list:={btn:{oc:1,ari:2,ync:3,yn:4,rc:5,ctc:6},ico:{"x":16,"?":32,"!":48,"i":64}},msg:=[],msgbox
	list.title:="XML Class",list.def:=0,list.time:=0,value:=0,msgbox:=1,txt:=""
	for a,b in x
		obj:=StrSplit(b,":"),(vv:=List[obj.1,obj.2])?(value+=vv):(list[obj.1]!="")?(List[obj.1]:=obj.2):txt.=b "`n"
	msg:={option:value+262144+(list.def?(list.def-1)*256:0),title:list.title,time:list.time,txt:txt}
	Sleep,120
	MsgBox,% msg.option,% msg.title,% msg.txt,% msg.time
	msgbox:=0
	for a,b in {OK:value?"OK":"",Yes:"YES",No:"NO",Cancel:"CANCEL",Retry:"RETRY"}
		IfMsgBox,%a%
	{
		WinActivate,ahk_id%active%
		ControlFocus,%Focus%,ahk_id%active%
		return b
	}
}


















