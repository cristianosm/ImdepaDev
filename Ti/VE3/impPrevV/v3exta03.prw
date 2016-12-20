#include "protheus.ch"

USER FUNCTION V3ExtA03()
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : Interface de execuÁ„o manual das consultas
<Data> : 28/09/2016
<Parametros> : Nenhum
<Retorno> : Nenhum
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : M
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local cFiltro	:= ""
Local aQuery	:= {}
Local cGrupos	:= ""
Local nI		:= 0
Local cUsrID	:= RetCodUsr() 
Local aGrupo	:= UsrRetGrp(cUsrID)
Local cCons		:= U_VExtM01I("CONS")
Local cPreC		:= Iif(Left(cCons, 1) == "S", Substr(cCons, 2), cCons)
Local cPerm		:= U_VExtM01I("PERM")
Local cPreP		:= Iif(Left(cPerm, 1) == "S", Substr(cPerm, 2), cPerm)
Private aRotina		:= MenuDef()
Private cCadastro	:= "ExecuÁ„o de Consultas"
Private aRotina		:= MenuDef()

// Filtra somente os registros onde existe seguranÁa determinada para o usu·rio
//Montagem do filtro das consultas, por usu·rio e grupo ou propriet·rio
FOR nI := 1 TO Len(aGrupo)
	IF Empty(cGrupos)
		cGrupos := "'" + aGrupo[nI] + "'"
	ELSE
		cGrupos += ",'" + aGrupo[nI] + "'"
	ENDIF
NEXT

cFiltro := "@" + cPreC + "_FILIAL = '" + xFilial(cCons) + "' "
cFiltro += "AND " + cPreC + "_MODOEX <> '2' "
cFiltro += "AND (" + cPreC + "_ACESS = '1' "
cFiltro += "OR " + cPreC + "_PROPRI = '" + cUsrID + "' "
cFiltro += "OR EXISTS ( "
cFiltro += "SELECT 0 FROM " + RetSqlName(cPerm) + " " + cPerm + " "
cFiltro += "WHERE " + cPerm + ".D_E_L_E_T_ = ' ' "
cFiltro += "AND " + cPreP + "_FILIAL = " + cPreC + "_FILIAL "
cFiltro += "AND " + cPreP + "_CODIGO = " + cPreC + "_CODIGO "
IF Empty(Alltrim(cGrupos))
	cFiltro += "AND " + cPreP + "_CODUSR = '" + cUsrID + "')) "
ELSE
	cFiltro += "AND (" + cPreP + "_GRUPO IN (" + cGrupos + ") "
	cFiltro += "OR " + cPreP + "_CODUSR = '" + cUsrID + "'))) "
ENDIF

FilBrowse(cCons, @aQuery, cFiltro, .t.)

DbSelectArea(cCons)
DbSetOrder(1)
DbSeek(xFilial(cCons), .t.)

MBrowse(006, 001, 022, 075, cCons)

EndFilBrw(cCons, aQuery)

RETURN

STATIC FUNCTION MenuDef()
Local aRotina	:= {}

Aadd(aRotina, {"Pesquisar"	, "AxPesqui"	, 0, 1})
Aadd(aRotina, {"Visualizar"	, "AxVisual"	, 0, 2})
Aadd(aRotina, {"Executar"	, "U_VExtA03X"	, 0, 6})
Return(aRotina)

USER FUNCTION VExtA03X()
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : Faz a chamada da execuÁ„o manual da consulta e indica o final de processamento
<Data> : 28/09/2016
<Parametros> : Nenhum
<Retorno> : Nenhum
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local cCons	:= U_VExtM01I("CONS")
Local cPreC	:= Iif(Left(cCons, 1) == "S", Substr(cCons, 2), cCons)
Local lRet	:= .t.

IF Aviso("ExecuÁ„o de consulta", "Confirma a execuÁ„o da consulta '" + (cCons)->(FieldGet(FieldPos(cPreC + "_CODIGO"))) + "'?", {"Sim", "N„o"}) == 1
	Processa({|| lRet := U_V3ExtA04((cCons)->(FieldGet(FieldPos(cPreC + "_SQL"))), .T.,, (cCons)->(FieldGet(FieldPos(cPreC + "_CODIGO"))))})
	IF lRet
		Aviso("ExecuÁ„o de consulta", "A consulta '" + (cCons)->(FieldGet(FieldPos(cPreC + "_CODIGO"))) + "' foi executada com sucesso.", {"Fechar"})
	ENDIF
ENDIF
RETURN
