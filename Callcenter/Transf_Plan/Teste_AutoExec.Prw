//Produto :00000007
//Tirar o PV em Betim 151 pças , 150 estoque local e 1 pç comprando em Cuiaba (02)

*****************************************************************
User Function Sol_Palhativa(lPar)
*****************************************************************

	Local aCabec := {}
	Local aItens := {}
	Local aLinha := {}
	Local nX 		:= 0
	Local nY 		:= 0
	Local cDoc 	:= ""
	Local lOk 	:= .T.

	Private lMsErroAuto := .F.

	If lOk .and. lPar

		aadd(aCabec,{"C7_EMISSAO" 	,dDataBase})
		aadd(aCabec,{"C7_FORNECE" 	,"N00000"})
		aadd(aCabec,{"C7_LOJA" 		,"05"})
		aadd(aCabec,{"C7_COND" 		,"001"})
		aadd(aCabec,{"C7_CONTATO" 	," "})
		aadd(aCabec,{"C7_FILENT" 	,cFilAnt})

		For nX := 1 To 1

			aLinha := {}
			aadd(aLinha,{"C7_PRODUTO" 	,"00000007"	,Nil})
			aadd(aLinha,{"C7_QUANT" 		,1 				,Nil})
			aadd(aLinha,{"C7_PRECO" 		,0.8868 		,Nil})
			aadd(aLinha,{"C7_DATPRF" 	,dDataBase		,Nil})
			aadd(aLinha,{"C7_LOCAL" 		,'01' 			,Nil})
			aadd(aLinha,{"C7_TES" 		,'062' 		,Nil})
			aadd(aLinha,{"C7_PLANILH" 	,'128684' 		,Nil})
			aadd(aLinha,{"C7_PLITEM" 	,'01' 			,Nil})
			aadd(aLinha,{"C7_PICM" 		,12 			,Nil})

			aadd(aItens,aLinha)

		Next nX

		MATA120(1,aCabec,aItens,3)

		If !lMsErroAuto
			Msginfo("Pedido de compras Incluido com sucesso! - Rotina Teste ")
		Else
			Alert("Erro na inclusao do Pedido de Compras ! - Rotina Teste ")
			MostraErro()
		EndIf

		Msginfo("Fim : "+Time())

	Elseif lOk .and. !lPar

		aadd(aCabec,{"C7_EMISSAO" 	,})
		aadd(aCabec,{"C7_FORNECE" 	,})
		aadd(aCabec,{"C7_LOJA" 		,})
		aadd(aCabec,{"C7_COND" 		,})
		aadd(aCabec,{"C7_CONTATO" 	,})
		aadd(aCabec,{"C7_FILENT" 	,})

		aLinha := {}
		aadd(aLinha,{"C7_PRODUTO" 	,,Nil})
		aadd(aLinha,{"C7_QUANT" 		,,Nil})
		aadd(aLinha,{"C7_PRECO" 		,,Nil})
		aadd(aLinha,{"C7_DATPRF" 	,,Nil})
		aadd(aLinha,{"C7_LOCAL" 		,,Nil})
		aadd(aLinha,{"C7_TES" 		,,Nil})
		aadd(aLinha,{"C7_PLANILH" 	,,Nil})
		aadd(aLinha,{"C7_PLITEM" 	,,Nil})
		aadd(aLinha,{"C7_PICM" 		,,Nil})

		aadd(aItens,aLinha)

		MATA120(1,aCabec,aItens,3)

	EndIf


Return()
