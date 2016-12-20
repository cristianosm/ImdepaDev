#include "protheus.ch"

USER FUNCTION V3ExtA02()
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : Interface de cadastro das permissıes das consultas
<Data> : 28/09/2016
<Parametros> : Nenhum
<Retorno> : LÛgico
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local cVldAlt	:= ".T."
Local cVldExc	:= ".T." 
Private cString	:= U_VExtM01I("PERM")

DbSelectArea(cString)
DbSetOrder(1)

AxCadastro(cString, "Cadastro de Permissıes", cVldExc, cVldAlt)

RETURN
         
USER FUNCTION VExtA02V(cCpo)
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : ValidaÁ„o genÈrica de campos das consultas
<Data> : 28/09/2016
<Parametros> : cCpo - Nome do campo para execuÁ„o da validaÁ„o
<Retorno> : LÛgico
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : V
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local lRet		:= .T.
Local cUserPerm	:= ""
Local aAreaOld	:= GetArea()
Local cCons		:= U_VExtM01I("CONS")
Local cPerm		:= U_VExtM01I("PERM")
Local cPreP		:= Iif(Left(cPerm, 1) == "S", Substr(cPerm, 2), cPerm)
Local aAreaCon	:= {}
Default cCPO	:= ""

IF cCPO = cPreP + "_GRUPO"
	IF &("M->" + cPreP + "_TIPO") == "1"
		IF !Empty(&("M->" + cPreP + "_GRUPO"))
			cUserPerm	:= Alltrim(GrpRetName(&("M->" + cPreP + "_GRUPO")))
			IF Empty(cUserPerm)
				lRet	:= .F.
				Help( ,, 'Help',, "Informe um grupo existente!", 1, 0) 		
			ELSE
				&("M->" + cPreP + "_NMGRP")	:= cUserPerm	
			ENDIF
		ENDIF
	ENDIF
	IF lRet
		lRet	:= xValChave()
	ENDIF
ELSEIF cCPO = cPreP + "_CODUSR"		
	IF &("M->" + cPreP + "_TIPO") == "2"	
		IF !Empty(&("M->" + cPreP + "_CODUSR"))
			PswOrder(1)
			IF !PswSeek(&("M->" + cPreP + "_CODUSR"), .T.)
				Help( ,, 'Help',, "CÛdigo de usu·rio n„o localizado!", 1, 0) 	
				lRet	:= .F.
			ELSE
				&("M->" + cPreP + "_NMUSR")	:= PswRet(1)[1][4]	
			ENDIF
		ELSE
			Help( ,, 'Help',, "Informe o usu·rio!", 1, 0) 	
			lRet	:= .F.
		ENDIF
	ENDIF
	IF lRet
		lRet	:= xValChave()
	ENDIF
ELSEIF cCPO = cPreP + "_TIPO"			
	IF &("M->" + cPreP + "_TIPO") == "1"
		&("M->" + cPreP + "_CODUSR")	:= Space(6)
		&("M->" + cPreP + "_NMUSR")		:= Space(25)
	ELSE
		&("M->" + cPreP + "_GRUPO")	:= Space(6)
		&("M->" + cPreP + "_NMGRP")	:= Space(25)
	ENDIF
ELSEIF cCPO = cPreP + "_CODIGO"
	aAreaCon := (cCons)->(GetArea())
	IF !Empty(&("M->" + cPreP + "_CODIGO"))
		(cCons)->(DbSetOrder(1))
		IF !(cCons)->(DbSeek(xFilial(cCons) + &("M->" + cPreP + "_CODIGO")))
			Help( ,, 'Help',, "CÛdigo de Consulta n„o localizada!", 1, 0) 
			lRet	:= .F.
		ENDIF
	ENDIF
	RestArea(aAreaCon)
	IF lRet
		lRet	:= xValChave()
	ENDIF
ENDIF
           
RestArea(aAreaOld)
Return lRet           

STATIC FUNCTION xValChave()
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : Verifica se usu·rio ou grupo j· tem permissıes para a consulta
<Data> : 28/09/2016
<Parametros> : Nenhum
<Retorno> : LÛgico
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : V
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local lRet		:= .t.
Local cPerm		:= U_VExtM01I("PERM")
Local cPreP		:= Iif(Left(cPerm, 1) == "S", Substr(cPerm, 2), cPerm)
Local aAreaPer	:= (cPerm)->(GetArea())
Local cChvPerm1	:= &("M->(" + cPreP + "_CODIGO + " + cPreP + "_TIPO + " + cPreP + "_GRUPO)")
Local cChvPerm2	:= &("M->(" + cPreP + "_CODIGO + " + cPreP + "_TIPO + " + cPreP + "_CODUSR)")
Local nRec		:= Iif(Inclui, 0, (cPerm)->(RecNo()))

IF !Empty(&("M->" + cPreP + "_GRUPO"))
	(cPerm)->(DbSetOrder(1))
	IF (cPerm)->(DbSeek(xFilial(cPerm) + cChvPerm1))
		IF nRec = 0 .OR. (Altera .AND. nRec <> (cPerm)->(RecNo()))
			Help( ,, 'Help',, "J· possui permiss„o cadastrada para Consulta e Grupo informados!", 1, 0) 
			lRet	:= .F.
		ENDIF
	ENDIF
ELSEIF !Empty(&("M->" + cPreP + "_CODUSR"))
	(cPerm)->(DbSetOrder(2))
	IF (cPerm)->(DbSeek(xFilial(cPerm)+cChvPerm2))
		IF nRec = 0 .or. (Altera .AND. nRec <> (cPerm)->(RecNo()))
			Help( ,, 'Help',, "J· possui permiss„o cadastrada para Consulta e Usu·rio informados!", 1, 0) 
			lRet	:= .F.
		ENDIF
	ENDIF
ENDIF

RestArea(aAreaPer)
Return lRet