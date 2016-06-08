#Include "Totvs.ch"

//|#########################################################################################
//|Projeto: Cnab Reposicionamento SE2....
//|Modulo : Financeiro
//|Fonte  : FA430SE2
//|---------+-------------------+-----------------------------------------------------------
//|Data     | Autor             | Descricao
//|---------+-------------------+-----------------------------------------------------------
//|16/06/14 | Cristiano Machado | Ponto de Entrada Utilizado para reposicionar no SE2 antes
//|         |                   | da Baixa. Hoje exite um problema quando ha 2 titulos com
//|         |                   | mesma numeracao e fornecedores divergente. Isso ocorre
//|         |                   | no Retorno de Contas a Pagar. (Sispag.2re).
//|---------+-------------------+-----------------------------------------------------------

*******************************************************************************
User Function FA430SE2()
*******************************************************************************
	Local aValores 	:= PARAMIXB[1]
	Local MvPArqCf 	:= "SISPAG.2PR"
	Local Parametro	:= "MV_PAR04"
	Local nLenArray	:= Len(aValores)

	If U_IMD430SE2(aValores, MvPArqCf, Parametro, nLenArray)
		Return(.T.)
	EndIf
	
Return(.F.)
*******************************************************************************
User Function IMD430SE2(aValores,MvPArqCf,Parametro,nLenArray )
*******************************************************************************
	Local aAreaSE2 	:= SE2->(GetArea())
	Local lRet				:= .F.

	If ( MvPArqCf == Alltrim(&Parametro.) )// Hoje Atende Apenas o SISPAG.2PR - > Retorno de Pagamentos... (Contas a Pagar)
		lRet := .T.
		nRecno := ObtemRecno(aValores[nLenArray])

		DbSelectArea("SE2")

		If ( nRecno > 0 )
 	
			DbSelectArea('SE2')
			nRecAtu := RECNO()
 		
			If ( nRecno <> nRecAtu  )
 		
				DbSelectArea('SE2')
				DbGoto(nRecno)
 		
 				//Posicionou(@aValores)
			EndIf
 				
		Else
			RestArea(aAreaSE2)
		EndIF

	EndIf

Return(lRet)
*******************************************************************************
Static Function ObtemRecno(cLinha)
*******************************************************************************
	Local cPrefixo 	:= Substr(cLinha,183,3)
	Local cNum				:= Substr(cLinha,186,09)
	Local cParcela		:= Substr(cLinha,195,1)
	Local cTipo			:= Substr(cLinha,196,3)
	Local nValor			:= Val(Substr(cLinha,101,12)+"."+Substr(cLinha,113,2))
	Local nRecno			:= 0
	local lMostra		:= .F.


	cSQl := ""
	cSQl += "Select R_E_C_N_O_ RECNO From se2010 "
	cSQl += "Where e2_filial 	= ' ' "
	cSQl += "And e2_prefixo 		= '"+cPrefixo+"' "
	cSQl += "And e2_num 			= '"+cNum+"' "
	cSQl += "And e2_parcela 		= '"+cParcela+"' "
	cSQl += "And e2_tipo 		= '"+cTipo+"' "
	cSQl += "And e2_valor 		=  "+cValToChar(nValor)+"  "
	cSQl += "And D_e_l_e_t_ 		=  ' '"

	U_ExecMySql(cSQl, "TEMP", "Q", lMostra)

	nRecno := TEMP->RECNO

Return(nRecno)

/*
"aValores"	{ size=16 }
	AVALORES[1]	"POA0000625271"
	AVALORES[2]	10/06/14
	AVALORES[3]	"FT"
	AVALORES[4]	""
	AVALORES[5]	0
	AVALORES[6]	0
	AVALORES[7]	0
	AVALORES[8]	110.48
	AVALORES[9]	0
	AVALORES[10]	0
	AVALORES[11]	""
	AVALORES[12]	"00 "
	AVALORES[13]	""
	AVALORES[14]	0
	AVALORES[15]	NIL
	AVALORES[16]	"3410001300001J00039991609000000110482563340505301320448000001NASCISUL TRANSPORTES          1006201400000000001104800000000000000000000000000000010062014000000000011048000000000000000POA0000625271FT               00082272906300001200        "

	SE2010
	Indice 1 	-	E2_FILIAL + E2_PREFIX + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA+
	Indice 5 	-	E2_FILIAL + E2_EMISSAO + E2_NOMFOR + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO

*/
