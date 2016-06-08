#INCLUDE "Rwmake.ch"
#INCLUDE "TOPCONN.CH"

//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa Rolamentos
//|Funcao....: U_UZPREEIC()
//|Autor.....: Armando M. Urzum - armando@urzum.com.br
//|Data......: 29 de Agosto de 2009 - 18:00
//|Uso.......: SIGAEIC
//|Versao....: Protheus - 8.11
//|Descricao.: Alteração dos Titulos PRE e NF  para o numero do processo
//|Observação:
//+------------------------------------------------------------------------------------//
*----------------------------------------------*
User Function UZPREEIC()
*----------------------------------------------*

Local cSql := ""

  LimpaSE2EIC02() //Limpa os Titulos Deletados do EIC do Tipo PRE,INV,NF
                  //Na primeira passada da alteracao dos Titulos PRE e NF
/*
//+------------------------------------------------------------------------------------//
//|ALTERAÇÃO DO PRE
//+------------------------------------------------------------------------------------//
cSql := " SELECT R_E_C_N_O_ FROM "+RetSqlName("SE2")
cSql += " WHERE D_E_L_E_T_ <> '*' AND E2_FILIAL = '"+xFilial("SE2")+"' "
cSql += " AND E2_PREFIXO = 'EIC' AND E2_TIPO = 'PRE' AND E2_NUM = '"+Alltrim(SW6->W6_NUMDUP)+"' "

IIf(Select("XXXZ") # 0,XXXZ->(dbCloseArea()),.T.)

TcQuery cSql New Alias "XXXZ"
XXXZ->(dbSelectArea("XXXZ"))
XXXZ->(dbGoTop())

If XXXZ->(EOF()) .AND. XXXZ->(BOF())
	XXXZ->(dbCloseArea())
Else
	SW6->(RecLock("SW6",.F.))
	SW6->W6_NUMDUP := Iif(!Empty(SW6->W6_TAB_PC),Alltrim(SW6->W6_HAWB),"")
	SW6->(MsUnLock())

	While XXXZ->(!EOF())
		SE2->(dbGoTo(XXXZ->R_E_C_N_O_))
		SE2->(RecLock("SE2",.F.))
		If !Empty(SW6->W6_TAB_PC)
			SE2->E2_NUM := Alltrim(SW6->W6_HAWB)
		Else
			SE2->(dbDelete())
		   LimpaSE2EIC02()
		EndIf
		SE2->(MsUnLock())
		XXXZ->(dbSkip())
	EndDo
	XXXZ->(dbCloseArea())
EndIf
*/
If Alltrim(SW6->W6_TIPODES) <> "14"

	//+------------------------------------------------------------------------------------//
	//|ALTERAÇÃO DO NF DO FRETE
	//+------------------------------------------------------------------------------------//
	cSql := " SELECT R_E_C_N_O_ FROM "+RetSqlName("SE2")
	cSql += " WHERE D_E_L_E_T_ <> '*' AND E2_FILIAL = '"+xFilial("SE2")+"' "
	cSql += " 	AND E2_PREFIXO = 'EIC' AND E2_TIPO = 'NF' AND E2_NUM = '"+Alltrim(SW6->W6_NUMDUPF)+"' "

	IIf(Select("XXXZ") # 0,XXXZ->(dbCloseArea()),.T.)

	TcQuery cSql New Alias "XXXZ"
	XXXZ->(dbSelectArea("XXXZ"))
	XXXZ->(dbGoTop())

	If XXXZ->(EOF()) .AND. XXXZ->(BOF())
		XXXZ->(dbCloseArea())
	Else
		SW6->(RecLock("SW6",.F.))
		SW6->W6_NUMDUPF := Alltrim(SW6->W6_HAWB)
		SW6->(MsUnLock())

		While XXXZ->(!EOF())
			SE2->(dbGoTo(XXXZ->R_E_C_N_O_))
			SE2->(RecLock("SE2",.F.))
			SE2->E2_NUM := Alltrim(SW6->W6_HAWB)
			SE2->(MsUnLock())
			XXXZ->(dbSkip())
		EndDo
		XXXZ->(dbCloseArea())

		SWD->(dbSetOrder(1))
		If SWD->(dbSeek(xFilial("SWD")+SW6->W6_HAWB+"102"))
			If SWD->WD_CTRFIN1 <> SW6->W6_NUMDUPF
				SWD->(RecLock("SWD",.F.))
				SWD->WD_CTRFIN1 := Alltrim(SW6->W6_HAWB)
				SWD->(MsUnLock())
			EndIf
		EndIf

	EndIf

	//+------------------------------------------------------------------------------------//
	//|ALTERAÇÃO DO NF DO SEGURO
	//+------------------------------------------------------------------------------------//
	//LimpaSE2EIC(SW6->W6_NUMDUPS       ,'EIC','NF')
	//LimpaSE2EIC(Alltrim(SW6->W6_HAWB) ,'EIC','NF')

	cSql := " SELECT R_E_C_N_O_ FROM "+RetSqlName("SE2")
	cSql += " WHERE D_E_L_E_T_ <> '*' AND E2_FILIAL = '"+xFilial("SE2")+"' "
	cSql += " AND E2_PREFIXO = 'EIC' AND E2_TIPO = 'NF' AND E2_NUM = '"+Alltrim(SW6->W6_NUMDUPS)+"' "

	IIf(Select("XXXZ") # 0,XXXZ->(dbCloseArea()),.T.)

	TcQuery cSql New Alias "XXXZ"
	XXXZ->(dbSelectArea("XXXZ"))
	XXXZ->(dbGoTop())

	If XXXZ->(EOF()) .AND. XXXZ->(BOF())
		XXXZ->(dbCloseArea())
	Else
		SW6->(RecLock("SW6",.F.))
		SW6->W6_NUMDUPS := Alltrim(SW6->W6_HAWB)
		SW6->(MsUnLock())

   	If !LimpaSeguro(Alltrim(SW6->W6_HAWB))
		While XXXZ->(!EOF())
			SE2->(dbGoTo(XXXZ->R_E_C_N_O_))
			SE2->(RecLock("SE2",.F.))
			SE2->E2_NUM := Alltrim(SW6->W6_HAWB)
			SE2->(MsUnLock())
			XXXZ->(dbSkip())
		EndDo
	Endif

		XXXZ->(dbCloseArea())

		SWD->(dbSetOrder(1))
		If SWD->(dbSeek(xFilial("SWD")+SW6->W6_HAWB+"103"))
			If SWD->WD_CTRFIN1 <> SW6->W6_NUMDUPS
				SWD->(RecLock("SWD",.F.))
				SWD->WD_CTRFIN1 := Alltrim(SW6->W6_HAWB)
				SWD->(MsUnLock())
			EndIf
		EndIf

	EndIf
Else

	SW6->(RecLock("SW6",.F.))
	SW6->W6_NUMDUPF := ""
	SW6->W6_NUMDUPS := ""
	SW6->(MsUnLock())

EndIf

Return

Static Function LimpaSE2EIC02()
Local cSql:=' '

cSql := " DELETE "+RetSqlName('SE2')
cSql += " WHERE E2_FILIAL= '" + xFilial( 'SE2' ) + "'"
cSql += " AND E2_TIPO IN('PRE','INV','NF')
cSql += " AND E2_PREFIXO = 'EIC'"
cSql += " AND D_E_L_E_T_='*'"

TCSQLExec( cSql )
TCSQLExec('COMMIT')

Return

Static Function LimpaSeguro(cDoc)
Local lRet:=.F.
Local cSql:=' '

cSql := " SELECT E2_NUM "
cSql += " FROM "+RetSqlName( 'SE2' ) + " SE2 "
cSql += " WHERE E2_FILIAL= '" + xFilial( 'SE2' ) + "'"
cSql += " AND  E2_NUM= '" + cDoc + "'"
cSql += " AND E2_TIPO ='NF'"
cSql += " AND E2_PREFIXO = 'EIC'"
cSql += " AND   E2_FORNECE ='N02275'" // Fornecedor do Seguro
cSql += " AND   E2_MOEDA='2'"         // Moeda do seguro é sempre 2
cSql += " AND   D_E_L_E_T_ <> '*'"

Iif( Select("QRY_SE2") <> 0, QRY_SE2->( dbCloseArea() ), ) // Verifico se a area não está em uso.

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"QRY_SE2",.F.,.T.)
DbSelectArea("QRY_SE2")

If QRY_SE2->( !EOF() )
 lRet:=.T.
Endif


/*
cSql := " DELETE "+RetSqlName('SE2')
cSql += " WHERE E2_FILIAL= '" + xFilial( 'SE2' ) + "'"
cSql += " AND  E2_NUM= '" + cDoc + "'"
cSql += " AND E2_TIPO ='NF'"
cSql += " AND E2_PREFIXO = 'EIC'"
cSql += " AND   E2_FORNECE ='N02275'" // Fornecedor do Seguro
cSql += " AND   E2_MOEDA='2'"         // Moeda do seguro é sempre 2

TCSQLExec( cSql )
TCSQLExec('COMMIT')
*/

Return(lRet)

