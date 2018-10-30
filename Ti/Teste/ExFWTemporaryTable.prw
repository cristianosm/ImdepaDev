#include 'protheus.ch'

User Function ExFWTemporaryTable()
Local aFields := {}
Local oTempTable
Local nI
Local cAlias := "MEUALIAS"
Local cQuery

//-------------------
//Criação do objeto
//-------------------
oTempTable := FWTemporaryTable():New( cAlias )

//--------------------------
//Monta os campos da tabela
//--------------------------
aadd(aFields,{"DESCR","C",30,0})
aadd(aFields,{"CONTR","N",3,1})
aadd(aFields,{"ALIAS","C",3,0})

oTemptable:SetFields( aFields )
oTempTable:AddIndex("indice1", {"DESCR"} )
oTempTable:AddIndex("indice2", {"CONTR", "ALIAS"} )
//------------------
//Criação da tabela
//------------------
oTempTable:Create()

//------------------------------------
//Executa query para leitura da tabela
//------------------------------------
cQuery := "select * from "+ oTempTable:GetRealName()
MPSysOpenQuery( cQuery, 'QRYTMP' )

DbSelectArea('QRYTMP')

while !eof()
	for nI := 1 to fcount()
		varinfo(fieldname(nI),fieldget(ni))
	next
	dbskip()
Enddo

	
//---------------------------------
//Exclui a tabela 
//---------------------------------
oTempTable:Delete() 


return

