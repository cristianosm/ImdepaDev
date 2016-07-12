#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#DEFINE  ENTER CHR(13)+CHR(10)
#DEFINE  MAXSAVERESULT 4096

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄż±±
±±łFun‡ao    łFT080RDES |Autor  |Rafael                 |Data  | 03.09.2014ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±łDescri‡ao |Esse PE Substituçăo da rotina de regra de desconto padrăo    ł±±
±±|          |                                                             ł±±
±±|          |                                                             ł±±
±±|          |                                                             ł±±
±±|          |Retorno: % Desconto                                          ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±łUso       |IMDEPA - P11                                                 ł±±
±±ŔÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
**********************************************************************
User Function FT080RDES()
**********************************************************************
Local aAreaFT		:= 	GetArea()
Local cQuery    	:= 	''
Local cAliasQry 	:= 	''
Local cCodRegra		:=	''
Local nDesconto 	:= 	0
Local lExistCpo 	:= 	ACO->(FieldPos("ACO_GRPVEN")) > 0
Local lExistEsca	:=	(ACO->(FieldPos('ACO_ESCALA'))*ACO->(FieldPos('ACO_LOTE')) > 0).AND.	GetNewPar("MV_DESCLOT",.F.)
Local cHoje 		:= 	DtoS(Date())
Local cHora 		:=	SubStr(Time(),1,5)
Local cCampo 		:=	SubStr(ReadVar(),04)
Local lPedido		:=	AllTrim(FunName())== 'MATA410' .Or. AllTrim(FunName())== 'MATA440' //  MATA440 - LIBERACAO PV
Local lTMKA271		:=	IsInCallStack("TMKA271") // AllTrim(Upper(FunName()))== 'TMKA271'
Local nPProd 		:= 	Ascan(aHeader,{|x| AllTrim(x[2]) == "UB_PRODUTO" })
Local nPQuant 		:= 	Ascan(aHeader,{|x| AllTrim(x[2]) == "UB_QUANT" })
Local nDescRD		:=	0
Local cItemACP		:=	''
Local lCheckRD		:=	.T.
Local lTemDescFaixa :=  .F.


//If FunName() <> "TMKA271" //Executa somente para pedidos a partir do TeleVendas
//  Return(nDesconto)
//Endif 

If PROCNAME(13)=='U_TMKVEX'  //Cancelamento de Pedidos nao precisa processar Regras de Desconto
	Return(nDesconto)
Endif
 

IIF(!ExisteSX6('IM_TAMPROD'), CriarSX6('IM_TAMPROD', 'N','Tamanho codigo produto.', '8' ),)


If ACO->(RecCount()) > 0 .And. lTMKA271

	If Type('aContDesc') != 'A'
		Public aContDesc := {}
	EndIf
		
	Private cProduto	:= PadL(ParamIxb[1], TamSx3('B1_COD')[1], '')	//	NECESSARIO PREENCHER ESPACO COM O TAMANHO DO CAMPO QDO ChangeQuery NAO ESTA HABILITADO
	Private cCliente	:= PadL(ParamIxb[2], TamSx3('A1_COD')[1], '')
	Private cLoja		:= PadL(ParamIxb[3], TamSx3('A1_LOJA')[1], '')
	Private cTabPreco 	:= PadL(ParamIxb[4], TamSx3('DA0_CODTAB')[1], '')
	Private cCondPg   	:= PadL(IIF(Empty(ParamIxb[6]), IIF(lPedido, M->C5_CONDPAG,	M->UA_CONDPG), ParamIxb[6]), TamSx3('DA0_CONDPG')[1], '')
	Private cFormPg   	:= PadL(IIF(Empty(ParamIxb[7]), IIF(lPedido, ''           ,	M->UA_FORMPG), ParamIxb[7]), TamSx3('ACO_FORMPG')[1], '')
	Private nFaixa    	:= ParamIxb[5]
	Private nTipo     	:= ParamIxb[8]			//	1 = DESCONTO POR ITEM  2 = DESCONTO POR TOTAL (CLIENTE)
	Private nRegPrior 	:= GetMV("MV_REGDPRI")	// 	1 = DESCONTO POR ITEM  2 = DESCONTO POR TOTAL (CLIENTE)
	Private aProds		:= ParamIxb[9]
	Private aEXC 		:= ParamIxb[10]
	
	Private cGrMar3 	:= Space(Len(SB1->B1_GRMAR3))
	Private cCurva 		:= Space(Len(SB1->B1_CURVA))
	
	Private cGrpVen 	:= Space(Len(SA1->A1_GRPVEN))
	Private cVinculo 	:= Space(Len(SA1->A1_VINCULO))
	Private cClasVen	:= Space(Len(SA1->A1_CLASVEN))
	Private lPromo		:= .F.
			

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
	//| cTabPreco := ParamIxb[4] JA PASSOU PELO PE Alt_Cliente_SUA E 		 |
	//| ALIMENTO M->UA_TABELA == A1_TABELA OU PELO SEGMENTO					 |	
	//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
	//| FUNCAO PARA VERIFICAR SE USUARIO PODE DELETAR LINHA.                	|
	//| QUANDO ITEM GEROU PV TRANSFERENCIA A LINHA NAO PODERA SER DELETADA		|
	//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
	If nFolder == 2                       
		oGetTlv:cDelOK	:=	'U_ChkDelTransf()'
	EndIf
	
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
	//| FUNCAO PARA PREENCHER COM ZEROS A ESQUERDA QUANDO INFORMADO PRODUTO 	|
	//|** MANOBRA PARA RETIRAR FUNCAO Tmk273Calcula DE EXECUCAO (aHeader)		|
	//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
	If nPProd > 0 .And. nFolder == 2
		If !('ComplZero()' $ aHeader[nPProd][06])
			 aHeader[nPProd][06] := 'U_ComplZero() .And. '+aHeader[nPProd][06]
		EndIf
	EndIf
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
	//| VALIDACAO PARA QUE ITEM DE TRANSFERENCIA NAO ALTERE QUANTIDADE.     	|
	//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
	If nPQuant > 0 .And. nFolder == 2
		If !('ChkTransf()' $ aHeader[nPQuant][06])
			 aHeader[nPQuant][06] := 'U_ChkTransf() .And. '+aHeader[nPQuant][06]
		EndIf
	EndIf

	
	If Len(aContDesc) == 0
		Aadd(aContDesc, M->UA_NUM)  	//	1
		Aadd(aContDesc, cCliente)       //	2
		Aadd(aContDesc, cTabPreco)		//	3
		Aadd(aContDesc, cCondPg)		//	4
		Aadd(aContDesc, cFormPg)       	//	5
		Aadd(aContDesc, M->UA_DESCORI)	//	6
		Aadd(aContDesc, .F.)			//	7 -- CONTROLA SE JA DEU DESCONTO
		Aadd(aContDesc, M->UA_DESC4) 	//	8
		Aadd(aContDesc, M->UA_DESC4) 	//	9

	Else
		
		If aContDesc[1] <> M->UA_NUM .Or. aContDesc[2] <> cCliente .Or. aContDesc[3] != cTabPreco
			
			M->UA_DESCORI 	:= -1  			//	RESETA O DESCONTO ORIGINAL
			M->UA_DESC4 	:= 0       		//	RESETA O VALOR DO CAMPO DESC4
			
			aContDesc := {} 				//	Limpa o array pois poutro atend ou outro cliente
			Aadd(aContDesc, M->UA_NUM)  	//	[01]	NUMERO DO ATENDIMENTO
			Aadd(aContDesc,cCliente)       	//	[02]	CLIENTE
			Aadd(aContDesc,cTabPreco)		//	[03]	TABELA DE PRACO
			Aadd(aContDesc,cCondPg)			//	[04]	CONDICAO DE PAGAMENTO
			Aadd(aContDesc,cFormPg)         //	[05]	FORMA DE PAGAMENTO
			Aadd(aContDesc,-1)				//	[06]	DESC. REGRA DE DESCONTO
			Aadd(aContDesc,.F.)				//	[07]	CONTROLA SE JA DEU DESCONTO
			Aadd(aContDesc,0)				//	[08]	ULTIMO VALOR INFO NO CAMPO UA_DESC4
			Aadd(aContDesc,0) 				//	[09]	UA_DESC4 ATUAL
			
		ElseIf 	aContDesc[1] == M->UA_NUM   .And. aContDesc[2] == cCliente .And. SubStr(ReadVar(),04) == 'UA_CLIENTE' .And.;
				aContDesc[6] <> M->UA_DESC4 .And. Upper(AllTrim(ProcName(4))) == 'TK273RECALC' .And. aContDesc[6] >= 0
				// X3_VALID == Tk273DesCab() .And. Tk273Recalc(,,.T.) OS DOIS CHAMAM ESSE PE
			    

			
			If MsgYesNo('DESEJA RESTAURAR O VALOR DO CAMPO  [ '+Upper(AllTrim(RetTitle('UA_DESC4')))+' ]  PARA SEU VALOR ORIGINAL [ '+AllTrim(Str(aContDesc[6]))+' ] ?','FT080RDES')
				aContDesc 	:= 	{}
				M->UA_DESC4 :=  M->UA_DESCORI
				
				Aadd(aContDesc, M->UA_NUM)  	//	1
				Aadd(aContDesc, cCliente)       //	2
				Aadd(aContDesc, cTabPreco)		//	3
				Aadd(aContDesc, cCondPg)		//	4
				Aadd(aContDesc, cFormPg)       	//	5
				Aadd(aContDesc, M->UA_DESCORI)	//	6
				Aadd(aContDesc, .F.)			//	7 -- CONTROLA SE JA DEU DESCONTO
				Aadd(aContDesc, M->UA_DESC4) 	//	8
				Aadd(aContDesc, M->UA_DESC4) 	//	9
				
			EndIf
			
		Else
			If cCampo == 'UA_DESC4' .And. nTipo == 2
				aContDesc[9] :=	aContDesc[8]
				aContDesc[8] := M->UA_DESC4
			EndIf
		EndIf
		
	EndIf
	

	
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
	//| BUSCA O GRUPO VENDAS, VINCULO E CLASS VENDAS DO CLIENTE   |
	//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
	If AllTrim(SA1->A1_COD+SA1->A1_LOJA) == AllTrim(cCliente+cLoja)
		cGrpVen 	:= 	SA1->A1_GRPVEN				//	NAO COLOCAR AllTrim QUANDO NAO TEM ChangeQuery
		cVinculo	:= 	SA1->A1_VINCULO
		cClasVen	:= 	SA1->A1_CLASVEN
	Else
		DbselectArea("SA1");DbSetOrder(1);DbGoTop()
		If DbSeek(xFilial("SA1")+cCliente+cLoja)
			cGrpVen 	:= 	SA1->A1_GRPVEN
			cVinculo	:= 	SA1->A1_VINCULO
			cClasVen	:= 	SA1->A1_CLASVEN
		EndIf
	EndIf

	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
	//| BUSCA O GRUPO DE MARCAS e CURVA DO PRODUTO  			  |
	//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
	If AllTrim(cProduto) == AllTrim(SB1->B1_COD)
		cGrMar3 := SB1->B1_GRMAR3
		cCurva	:= SB1->B1_CURVA
		lPromo	:= Left(SB1->B1_OBSTPES,1)=='P'//!Empty(SB1->B1_OBSTPES)
	Else
		DbselectArea("SB1");DbSetOrder(1);DbGoTop()
		If DbSeek(xFilial("SB1")+cProduto)
			cGrMar3	:= SB1->B1_GRMAR3
			cCurva	:= SB1->B1_CURVA
			lPromo	:= Left(SB1->B1_OBSTPES,1)=='P'
		EndIf
	EndIf



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
	//|CLIENTE COM TABELA ESPECIFICA NAO CONCIDERAR DESCONTO DE REGRA	|
	//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
												//	  [01] [02]   [02] [02]   [03] [02]
	aTabelas 	:= 	&(GetMv('MV_SEGXTAB'))		//	{{"1","OEM"},{"2","MNT"},{"3","REV"}}

	If Ascan(aTabelas, {|X| X[2] == M->UA_TABELA }) == 0
		
		If nTipo == 2		
			//	2 == DESCONTO POR TOTAL
			lCheckRD := IIF(M->UA_TABELA == cTabPreco, .F., .T.)

		ElseIf nTipo == 1	
			//	1 == DESCONTO POR ITEM
			lCheckRD := IIF(M->UA_TABELA == GdFieldGet('UB_TABPRC',n), .F., .T.)
	    EndIf
	
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
	//| PRODUTO EM PROMOCAO NAO CONCIDERAR DESCONTO DE REGRA	  |
	//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ

	/*
		If lCheckRD
			lCheckRD := IIF(lPromo, .F., lCheckRD)
		EndIf

	   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
	   	//|CONSIDERAR REGRA DE DESCONTO PARA PRODUTOS EM PROMOCAO     |
	   	//| SOLICITACAO LUANA 09/12/2015							  |
	  	//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
    */
    



	If lCheckRD

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
		//| 				DESCONTO DO CLIENTE						  |
		//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
		If nTipo == 2 

		
			cAliasQry := "MARGRDESC"
			cQuery := "SELECT ACO.ACO_PERDES DESCONTO, ACO_CODREG "
			If ACO->(FieldPos("ACO_VLRDES")) > 0
				cQuery += ",ACO.ACO_VLRDES VLRDESC "
			EndIf
			If lExistEsca
				cQuery += ", ACO_ESCALA"
			EndIf
			If lExistCpo
				cQuery += ", ACO_GRPVEN"
			EndIf
			If ACO->(FieldPos("ACO_DATDE")) * ACO->(FieldPos("ACO_DATATE")) * ACO->(FieldPos("ACO_HORADE")) * ;
				ACO->(FieldPos("ACO_HORATE")) * ACO->(FieldPos("ACO_TPHORA"))  > 0
				cQuery	+=	",ACO_DATDE,ACO_DATATE,ACO_HORADE,ACO_HORATE,ACO_TPHORA "
				aCpos	:=	{ {'ACO_DATDE',"D",8,0},{'ACO_DATATE',"D",8,0}}
			EndIf
			cQuery += " FROM "+RetSqlName("ACO")+" ACO "
			cQuery += "WHERE ACO.ACO_FILIAL='"+xFilial("ACO")+"' AND "
			cQuery += "(ACO.ACO_CODCLI='"+Space(Len(SA1->A1_COD))+"' OR ACO.ACO_CODCLI='"+cCliente+"') AND "
			cQuery += "(ACO.ACO_LOJA='"+Space(Len(SA1->A1_LOJA))+"' OR ACO.ACO_LOJA='"+cLoja+"') AND "
			cQuery += "(ACO.ACO_CODTAB='"+Space(Len(DA0->DA0_CODTAB))+"' OR ACO.ACO_CODTAB = '"+cTabPreco+"') AND "
			cQuery += "(ACO.ACO_CONDPG='"+Space(Len(DA0->DA0_CONDPG))+"' OR ACO.ACO_CONDPG='"+cCondPg+"') AND "
			cQuery += "(ACO.ACO_FORMPG='"+Space(Len(ACO->ACO_FORMPG))+"' OR ACO.ACO_FORMPG='"+cFormPg+"') AND "
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
			//| CONSIDERA CAMPOS CUSTOMIZADOS	|
			//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
			cQuery += "(ACO.ACO_GRPVEN='"+Space(Len(ACO->ACO_GRPVEN))+"'  OR ACO.ACO_GRPVEN='"+cGrpven+"')  AND "
			cQuery += "(ACO.ACO_VINCUL='"+Space(Len(ACO->ACO_VINCUL))+"'  OR ACO.ACO_VINCUL='"+cVinculo+"') AND "
			cQuery += "(ACO.ACO_CLASVE='"+Space(Len(ACO->ACO_CLASVEN))+"' OR ACO.ACO_CLASVE='"+cClasven+"') AND "
			If 	ACO->(FieldPos("ACO_DATDE")) * ACO->(FieldPos("ACO_DATATE")) * ACO->(FieldPos("ACO_HORADE")) * ;
				ACO->(FieldPos("ACO_HORATE")) * ACO->(FieldPos("ACO_TPHORA"))  > 0
				cQuery	+= "ACO_DATDE <= '"+cHoje+"' AND ACO_HORADE <= '"+cHora+"' AND "
				cQuery += "(ACO_DATATE >= '"+cHoje+"' OR ACO_DATATE = '"+Space(Len(cHoje))+"' ) AND "  // ''
				cQuery += "(ACO_HORATE >= '"+cHora+"' OR ACO_HORATE = '"+Space(Len(cHora))+"') AND "   // ''
			EndIf
		
			cQuery += "ACO.D_E_L_E_T_=' ' AND "
	
			If !lExistEsca
				cQuery += " (ACO.ACO_PERDES > 0 "
				If ACO->(FieldPos("ACO_VLRDES")) > 0
					cQuery += " OR ACO.ACO_VLRDES > 0"
				EndIf
				cQuery += " ) AND "
			EndIf
			cQuery += "ACO.ACO_FAIXA<="+Alltrim(StrZero(nFaixa,18,2))+" "
			cQuery += "ORDER BY ACO_FILIAL DESC,ACO_CODTAB DESC,ACO_CONDPG DESC,ACO_FORMPG DESC,ACO_CODCLI DESC,ACO_LOJA DESC,ACO_GRPVEN DESC,ACO_VINCUL DESC,ACO_CLASVE,ACO_CFAIXA"

			//cQuery := ChangeQuery(cQuery)
			// SOLUTIO - Cesar - Query năo precisa de CHANGE QUERY
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
		    
		
		ElseIf nTipo == 1
	    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
			//| 				DESCONTO DO PRODUTO						  |
			//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
			cAliasQry := "MARGRDESC"
			cQuery := "SELECT ACP.ACP_FAIXDE FAIXA_DE,ACP.ACP_FAIXAT FAIXA_AT,ACP.ACP_CODPRO PRODUTO, ACP.ACP_FAIXA FAIXA, ACP.ACP_PERDES DESCONTO, ACO_CODREG, ACP_ITEM "
			If ACO->(FieldPos("ACO_VLRDES")) > 0
				cQuery += ",ACO.ACO_VLRDES VLRDESC "
			EndIf
			If lExistEsca
				cQuery += ", ACO_ESCALA"
			EndIf
			If lExistCpo
				cQuery += ", ACO_GRPVEN"
			EndIf
			If ACO->(FieldPos("ACO_DATDE")) * ACO->(FieldPos("ACO_DATATE")) * ACO->(FieldPos("ACO_HORADE")) * ;
				ACO->(FieldPos("ACO_HORATE")) * ACO->(FieldPos("ACO_TPHORA"))  > 0
				cQuery	+=	",ACO_DATDE,ACO_DATATE,ACO_HORADE,ACO_HORATE,ACO_TPHORA "
				aCpos	:=	{ {'ACO_DATDE',"D",8,0},{'ACO_DATATE',"D",8,0}}
			EndIf
			cQuery += " FROM "+RetSqlName("ACO")+" ACO "
			
			cQuery += ", " + RetSqlName("ACP")+" ACP "
			cQuery += "WHERE ACO.ACO_FILIAL='"+xFilial("ACO")+"' AND "
			cQuery += "(ACO.ACO_CODCLI='"+Space(Len(SA1->A1_COD))+"' OR ACO.ACO_CODCLI='"+cCliente+"') AND "
			cQuery += "(ACO.ACO_LOJA='"+Space(Len(SA1->A1_LOJA))+"' OR ACO.ACO_LOJA='"+cLoja+"') AND "
			cQuery += "(ACO.ACO_CODTAB='"+Space(Len(DA0->DA0_CODTAB))+"' OR ACO.ACO_CODTAB = '"+cTabPreco+"') AND "
			cQuery += "(ACO.ACO_CONDPG='"+Space(Len(DA0->DA0_CONDPG))+"' OR ACO.ACO_CONDPG='"+cCondPg+"') AND "
			cQuery += "(ACO.ACO_FORMPG='"+Space(Len(ACO->ACO_FORMPG))+"' OR ACO.ACO_FORMPG='"+cFormPg+"') AND "
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
			//| CONSIDERA CAMPOS CUSTOMIZADOS	|
			//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
			cQuery += "(ACO.ACO_GRPVEN='"+Space(Len(ACO->ACO_GRPVEN))+"' OR ACO.ACO_GRPVEN='"+cGrpven+"') AND "
			cQuery += "(ACO.ACO_VINCUL='"+Space(Len(ACO->ACO_VINCUL))+"' OR ACO.ACO_VINCUL='"+cVinculo+"') AND "
			cQuery += "(ACO.ACO_CLASVE='"+Space(Len(ACO->ACO_CLASVEN))+"' OR ACO.ACO_CLASVE='"+cClasven+"') AND "
			If 	ACO->(FieldPos("ACO_DATDE")) * ACO->(FieldPos("ACO_DATATE")) * ACO->(FieldPos("ACO_HORADE")) * ;
				ACO->(FieldPos("ACO_HORATE")) * ACO->(FieldPos("ACO_TPHORA"))  > 0
				cQuery	+= "ACO_DATDE <= '"+cHoje+"' AND ACO_HORADE <= '"+cHora+"' AND "
				cQuery += "(ACO_DATATE >= '"+cHoje+"' OR ACO_DATATE = '"+Space(Len(cHoje))+"' ) AND "
				cQuery += "(ACO_HORATE >= '"+cHora+"' OR ACO_HORATE = '"+Space(Len(cHora))+"') AND "
			EndIf
	
			cQuery += "ACO.D_E_L_E_T_=' ' AND "
			cQuery += "ACP.ACP_FILIAL='"+xFilial("ACP")+"' AND "
			cQuery += "ACP.ACP_CODREG=ACO.ACO_CODREG AND "
			cQuery += "(ACP.ACP_CODPRO='"+Space(Len(SB1->B1_COD))+"' OR ACP.ACP_CODPRO='"+cProduto+"') AND "
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
			//| CONSIDERA CAMPOS CUSTOMIZADOS	|
			//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
			cQuery += "(ACP.ACP_GRMAR3='"+Space(Len(SB1->B1_GRMAR3))+"' OR ACP.ACP_GRMAR3='"+cGrMar3+"') AND "
			cQuery += "(ACP.ACP_CURVA='"+Space(Len(SB1->B1_CURVA))+"' OR ACP.ACP_CURVA='"+cCurva+"') AND "
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
			//| Descarta Itens especificos		|
			//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
			//	cQuery += "(ACP.ACP_CODPRO='"+Space(Len(SB1->B1_COD))+"' OR ACP.ACP_CODPRO='"+cProduto+"') AND "
			//	cQuery += "(ACP.ACP_CURVA='"+Space(Len(SB1->B1_CURVA))+"' OR ACP.ACP_CURVA='"+cCurva+"') AND "
			//	Msginfo('Marca '+SB1->B1_MARCA)
	   		//	Msginfo('Lendo Faixa ---> XXXXX '+Str(nFaixa))
	         	
			cQuery += "ACP.ACP_FAIXA>="+Alltrim(StrZero(nFaixa,18,2))+" AND "
			cQuery += "ACP.ACP_PERDES > 0 AND "
			cQuery += "ACP.D_E_L_E_T_=' ' "
			cQuery += "ORDER BY ACO_FILIAL DESC,ACO_CODTAB DESC,ACO_CONDPG DESC,ACO_FORMPG DESC,ACO_CODCLI DESC,ACO_LOJA DESC,ACO_GRPVEN DESC,ACO_VINCUL DESC,ACO_CLASVE,ACO_CFAIXA"
			
			//cQuery := ChangeQuery(cQuery)
			//SOLUTIO - Cesar - Năoprecisa de ChangeQuery
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
		EndIf
				
		
		
		DbSelectArea(cAliasQry);DbGotop()
		
	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
		//| 	 REGRA CASCATEAMENTO		|
		//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
				
		cCodRegra 	:= 	(cAliasQry)->ACO_CODREG
		cItemACP 	:= 	IIF(nTipo == 1, (cAliasQry)->ACP_ITEM, Space(TamSx3('ACP_ITEM')[01]))
		nDescRD		:=	(cAliasQry)->DESCONTO
		
		If nTipo == 2				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
			//| DESCONTO POR CLIENTE 	|
			//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
			//|(NAO DEU DESCONTO OU DESC4 Eh O MESMO DESCORI)		|
			//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
			If (!aContDesc[7] .Or. (M->UA_DESC4 == aContDesc[6])) 
	
				nContDesc := 100
				Do While (cAliasQry)->(!Eof())
					nDescTab 	:= 	(cAliasQry)->DESCONTO  / 100
					nContDesc 	:= 	nContDesc - (nContDesc * nDescTab)
					(cAliasQry)->(DbSkip())
				Enddo
				nDesconto 		:= 	100 - nContDesc
				aContDesc[7]	:= 	.T.
				
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
				//|ATUALIZA O DESCONTO ORIGINAL SE ESTIVER COM VALOR PADRAO (-1)		|
				//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
				If M->UA_DESCORI < 0 
						M->UA_DESCORI := nDesconto
						aContDesc[6]  := nDesconto
						aContDesc[8]  := nDesconto 		// 	ATUALIZO O CAMPO QUE TEM ORIGEM NO UA_DESC4
				EndIf
			
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
			//|JA APLICOU UMA VEZ AS REGRAS E O DESC4 <> DO DESCORI -- FOI ALTERADO MANUAL                  |
			//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
			If (aContDesc[8] <> aContDesc[6]) .AND. aContDesc[7]
				nDesconto 	:=  M->UA_DESC4  			// 	USO O QUE FOI ALTERADO MANUAL NA TELA DA VERDADE
				nDescRD		:=	nDesconto
			EndIf
		
		

		ElseIf nTipo == 1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
			//| DESCONTO POR PRODUTO	|
			//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ

	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
			//|SE FOR DESCONTO POR PRODUTO E O CAMPO UA->DESC4 NAO ESTIVER VAZIO	|
			//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
			nContDesc	:= 	100
			Do While (cAliasQry)->(!Eof())
			  
				//Verifica se o item possui desconto por  faixa de Qtds.
				//Caso exista despreza os descontos de regra considerando apenas o desconto por Faixa
				lTemDescFaixa:=Iif((cAliasQry)->FAIXA_DE >0,.T.,.F.)
				
				//nDescTab 	:=	(cAliasQry)->DESCONTO / 100
				//nContDesc 	:= 	nContDesc - (nContDesc * nDescTab)
				
				//Tratamento para realizar desconto por faixa de Qtds.
				If ((cAliasQry)->FAIXA_DE>0 .AND. "3" $ SA1->A1_GRPSEG)
				nDescTab 	:=	0
				nContDesc 	:= 	0
				Endif
				
				//ediIf (cAliasQry)->FAIXA>0 .AND. (cAliasQry)->FAIXA<999999.99
				//Msginfo('FAIXA_DE '+Str((cAliasQry)->FAIXA_DE))
				If (!Empty((cAliasQry)->PRODUTO) .AND. (cAliasQry)->FAIXA_DE >0 .AND. "3" $ SA1->A1_GRPSEG )
			    	  //Msginfo('Caiu na Faixa Desconto de : '+Str((cAliasQry)->DESCONTO) )
			    	     
			    	    /*
			    	    Tratamento para faixa de Quantidades
			    	    Quando houver desconto por faixa despreza todos os outros descontos , considerando apenas o desconto por faxa
			    	    */
			    	    
			    	    If (gdFieldGet("UB_QUANT",n) >=(cAliasQry)->FAIXA_DE .AND. gdFieldGet("UB_QUANT",n) <=(cAliasQry)->FAIXA_AT)
			    	 
			    	 	nContDesc	:= 	100
			    	 	nDescTab 	:=	(cAliasQry)->DESCONTO / 100
				        nContDesc 	:= 	nContDesc - (nContDesc * nDescTab)
				        nContDesc   :=0
			    	     Exit 
			    	    Endif
			    Endif	 
				  
				      
	      If lTemDescFaixa             
         	(cAliasQry)->(DbSkip())
              Loop
          Endif
        
                nDescTab 	:=	(cAliasQry)->DESCONTO / 100
				nContDesc 	:= 	nContDesc - (nContDesc * nDescTab)
				
				  
				
				
				(cAliasQry)->(DbSkip())
			EndDo     
			
			If nContDesc>0
			nDesconto := 100 - nContDesc
			Else
			nDesconto :=0
			Endif

		EndIf
				 				 	

		
	
		DbSelectArea("MARGRDESC")
		MARGRDESC->(DbCloseArea())
	
	EndIf


EndIf




//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
//|lTMKA271 == TELA DA VERDADE		|
//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
If lTMKA271

	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
	//|** VERIFICA	AT VIA HISTORICO		|
	//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
	If Len(aHistTV) > 0	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
		//|	 FABIANO PEREIRA - SOLUTIO									|
		//| BUSCA VIA HISTORICO - SE ATENDIMENTO NAO PASSOU DE 2 DIAS 	|
		//| PERMANECEM O MESMO VALOR DE % DESCONTO DO CABEC E      		|
		//| PARA OS ITENS BUSCA O % DESCONTO DA REGRA DE DESCONTO  		|
		//|																|
		//|  OBS.:														|
		//|	 A CADA VALIDACAO DE LINHA Eh CHAMADO ESSE PE E RETORNA		|
		//|  % DE DESCONTO												|
		//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
		/*
			Aadd(aHistTV, {	GdFieldGet('UB_ITEM', nI), 		GdFieldGet('UB_PRODUTO', nI),;									//	[01], [02],     
							M->UA_DESC1, M->UA_DESC4, M->UA_DESCG,;															//	[03], [04], [05]
							GdFieldGet('UB_TOTDESC', nI), 	GdFieldGet('UB_DESCVEN', nI), 	GdFieldGet('UB_DESCRD', nI),;	//	[06], [07], [08]
							GdFieldGet('UB_ACRE',    nI),	GdFieldGet('UB_VRUNIT',  nI), 	GdFieldGet('UB_PRCTAB', nI) })	//	[09], [10], [11]
		*/

		
		If nTipo == 2		//	1 = DESCONTO POR ITEM; 2 = DESCONTO POR TOTAL
			nDesconto := aHistTV[01][04]			//	DESCONTO DA REGRA DE DESCONTO - CABEC
		Else
			// CASO PRODUTO == HISTORICO PERMANECE O MESMO % DESCONTO DO HIST. E P\ ITENS NOVOS BUSCA O % DESC. DA REGRA
			nPos := Ascan(aHistTV, {|X| AllTrim(X[01]) == AllTrim(GdFieldGet('UB_ITEM', n)) .And. AllTrim(X[02]) == AllTrim(GdFieldGet('UB_PRODUTO', n)) })
			If nPos != 0
				nDesconto := aHistTV[nPos][08]		//	DESCONTO DA REGRA DE DESCONTO - ITEM
			EndIf

		EndIf
		
	EndIf
	

    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
	//|** LOG PARA MOSTRAR REGRA DE DESCONTO 	|
	//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
	If nTipo == 2		//	1 = DESCONTO POR ITEM; 2 = DESCONTO POR TOTAL

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
		//| GRAVA NO ARRAY aRegDesc A(s) REGRAS DE DESCONTO	 		|
		//? PARA CADA ITEM\CABEC DO ATENDIMENTO.					|
		//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
		If M->UA_DESC1 > 0
			nPos := Ascan(aRegDesc,{|X| X[1] == 'Desc.Cliente'   })
			If nPos == 0
				Aadd(aRegDesc, {'Desc.Cliente', '', '', M->UA_DESC1, '' })
			Else
				aRegDesc[nPos][4] := M->UA_DESC1
			EndIf
        Else
        	AjustaRD('Desc.Cliente')
        EndIf
        
        If M->UA_DESC4 > 0
			nPos := Ascan(aRegDesc,{|X| X[1] == 'Desc.RD - Cabec' })
			If nPos == 0
				Aadd(aRegDesc, {'Desc.RD - Cabec', '', cCodRegra, M->UA_DESC4, '' })
			Else
				aRegDesc[nPos][3] := cCodRegra
				aRegDesc[nPos][4] := M->UA_DESC4
			EndIf
        Else
        	AjustaRD('Desc.RD - Cabec') 
        EndIf
        
        If M->UA_DESCG > 0
			nPos := Ascan(aRegDesc,{|X| X[1] == 'Desc.Geral'  })
			If nPos == 0
				Aadd(aRegDesc, {'Desc.Geral', '', '', M->UA_DESCG, '' })
			Else
				aRegDesc[nPos][4] := M->UA_DESCG
			EndIf
	    Else
	    	AjustaRD('Desc.Geral')
	    EndIf
	    

	Else

		If Left(cCampo,02) == 'UB'
		
			If nDesconto > 0
				// nPos := Ascan(aRegDesc,{|X| Upper(X[1]) == Upper('Item RD') .And. X[2] == StrZero(n, TamSx3('UB_ITEM')[1]) .And. X[3] == cCodRegra })
				nPos := Ascan(aRegDesc,{|X| Upper(X[1]) == Upper('Item RD') .And. X[2] == GdFieldGet('UB_ITEM', n) .And. X[3] == cCodRegra })
		    	If nPos == 0
					Aadd(aRegDesc, {'Item RD', GdFieldGet('UB_ITEM', n), cCodRegra, nDesconto, cItemACP })
				Else
					aRegDesc[nPos][03] := cCodRegra
					aRegDesc[nPos][04] := nDesconto
					aRegDesc[nPos][05] := cItemACP
				EndIf
			Else
				AjustaRD('Item RD')
			EndIf

        EndIf
        
	EndIf


EndIf
                     

RestArea(aAreaFT)
Return(nDesconto)
***********************************************************************
Static Function AjustaRD(cPesq)
***********************************************************************
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
//| VERIFICA SE TINHA DESCONTO E AGORA NAO TEM MAIS.	|
//| RETIRA DO ARRAY aRegDesc.                       	|
//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Aadd(aRegDesc, {'Desc.RD - Cabec', '', cCodRegra, M->UA_DESC4 })
// Aadd(aRegDesc, {'Item RD', GdFieldGet('UB_ITEM', n), cCodRegra, nDesconto })

nPos := Ascan(aRegDesc,{|X| X[1] == cPesq  })
If nPos > 0

	aCopiaRD := {}	
	For nX := 1 To Len(aRegDesc)
		If Upper(AllTrim(aRegDesc[nX][01])) != Upper(AllTrim(cPesq))
			Aadd(aCopiaRD, aRegDesc[nX])
		Else
			//	Upper(aRegDesc[nX][01]) == 'ITEM RD' .And. GdFieldGet('UB_ITEM', n) != aRegDesc[nX][02] )
			If GdFieldGet('UB_ITEM', n) != aRegDesc[nX][02]
				Aadd(aCopiaRD, aRegDesc[nX])			
			EndIf
		EndIf
	Next  
	
	aRegDesc := aCopiaRD

EndIf
			
Return()
**********************************************************************
User Function ComplZero()
**********************************************************************
lReadVar  := .F.
nTamProd  := GetMv('IM_TAMPROD')
cConteudo := &(ReadVar())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
//| 1. VERIFICA SE CODIGO INFORMADO EH REFERENTE AO PROJETO CORREIAS (SBP)	|
//| 2. PREENCHE COM ZEROS A ESQUERDA			 			              	|
//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ

If !Empty(cConteudo)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
	//| POSICIONA TABELAS NA XX_BASE CORRETA E VERIFICA SE ALIAS() ESTA VAZIA	|
	//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
	ExecBlock('ChkPosBase',.F.,.F., {'ChkCorreias', ''})
	cBase  		:= 	A093VldBase(cConteudo)
	lCorrOpen	:=	IIF(AllTrim(cBase) == '02', .T., .F.)		// 01-FECHADAS, 02-ABERTAS
	ExecBlock('ChkPosBase',.F.,.F., {'ChkCorreias', cBase})

	cBase := A093VldBase(cConteudo)
	
	If !Empty(cBase)
		
		nTamBase := Len(AllTrim(cBase))
		aIdSBQ	 := A093ORetSBQ(cBase)
		nPosMat	 := Ascan(aIdSBQ, {|X| AllTrim(X[01]) == 'MAT'})
		nPosFam	 := Ascan(aIdSBQ, {|X| AllTrim(X[01]) == 'FAM'})
		nPosRef	 := Ascan(aIdSBQ, {|X| AllTrim(X[01]) == 'REF'})
		nPosLgr	 := Ascan(aIdSBQ, {|X| AllTrim(X[01]) == 'LRG'})
		nPosCom	 := Ascan(aIdSBQ, {|X| AllTrim(X[01]) == 'COM'})
				
		nIniMat := 	nTamBase + aIdSBQ[nPosMat][02]
		nFimMat	:= 	aIdSBQ[nPosMat][02]
		nTamMat := 	aIdSBQ[nPosMat][02]
	
		nIniFam := 	nIniMat+nTamMat
		nFimFam := 	aIdSBQ[nPosFam][02]
		nTamFam	:=	aIdSBQ[nPosFam][02]
	
		nIniRef := 	nIniFam+nTamFam
		nFimRef := 	aIdSBQ[nPosRef][02]
		nTamRef	:=	aIdSBQ[nPosRef][02]
	
		nIniLgr := 	nIniRef+nTamRef
		nFimLgr := 	aIdSBQ[nPosLgr][02]
		nTamLgr	:=	aIdSBQ[nPosLgr][02]

		nIniCom := 	nIniLgr+nTamLgr
		nFimCom := 	aIdSBQ[nPosLgr][02]
		nTamCom	:=	aIdSBQ[nPosLgr][02]	


		// Jean Rehermann - SOLUTIO IT - 20/01/2016 - Inseri a linha abaixo.
		nTamCodC := nTamBase + nTamMat + nTamFam + nTamRef + nTamLgr + nTamCom

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
		//| VERIFICA SE TAMANHO DO CODIGO DIGITADO							|
		//| SE PRODUTO CORREIA E CODIGO INFO < QUE COD.CORREIA	            |
		//| ABRE BROWSER PARA MONTAR\PESQUISAR PRODUTO CORREIA				|
		//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
		If Len(AllTrim(cConteudo)) < nTamCodC
			A093Prod()
		Else
			nTamProd := nTamCodC
			lReadVar := .T.
		EndIf
	
	Else
		lReadVar := .T.
	EndIf	
	

	If lReadVar
		&(ReadVar())  	:=	PadR(PadL(AllTrim(cConteudo), nTamProd, '0'), TamSx3('UB_PRODUTO')[01] )
	EndIf	


	GdFieldPut('UB_PRODUTO', M->UB_PRODUTO, n )

EndIf

If Len(aHeader) != Len(aClone(aSvFolder[2][1]))
	aHeader  := aClone(aSvFolder[2][1])
EndIf

oGetTLV:oBrowse:Refresh()
Return(.T.)             
**********************************************************************
User Function ChkDelTransf()
**********************************************************************
Local lRetorno  := 	.T.
Local lDelLine 	:=	.T.
Local lOperFat 	:= (M->UA_OPER == '1')	// 1=Faturamento;2=Orcamento;3=Atendimento

If lOperFat
	If GdDeleted(n)
		If !Empty(GdFieldGet('UB_PRODUTO',n))
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
			//| VERIFICA SE USUARIO PODE OU NAO DELETAR A LINHA DO ATENDIMENTO	|
			//| SE NAO TEM PLANILHA DE TRANSF. PODE DELETAR LINHA.	            |
			//| SE TEM PLANILHA E DOC.ENTRADA EXISTE PODE DELETAR LINHA.		|
			//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
			lPTrans 	:=	IIF(!Empty(GdFieldGet('UB_PLANILH', n)), .T., .F.)
			lDelLine	:=	IIF(!lPTrans, .T., !Empty(Posicione('SZE', 1, xFilial('SZE')+GdFieldGet('UB_PLANILH', n)+GdFieldGet('UB_PRODUTO', n)+cFilAnt, 'ZE_FLAGNF')) ) //ZE_FILIAL+ZE_NUMPLAN+ZE_PRODUTO+ZE_DESTINO
	
			If !lDelLine
				aCols[n][Len(aHeader)+1] := .F.
				oGetTLV:oBrowse:Refresh()
				MsgAlert('ESSE ITEM GEROU PEDIDO DE TRANSFERĘNCIA. NĂO É POSSÍVEL DELETA-LO !!!', 'FT080RDES\ChkDelTransf')
				lRetorno := .F.
			EndIf
	
		EndIf
	EndIf
EndIf

Return(lRetorno)
**********************************************************************
User Function ChkTransf()
**********************************************************************
Local lRetorno  := .T.
Local lOperFat 	:= (M->UA_OPER == '1')	// 1=Faturamento;2=Orcamento;3=Atendimento

If lOperFat
	If !Empty(GdFieldGet('UB_PRODUTO',n))
		If !Empty(GdFieldGet('UB_PLANILH',n))
			MsgAlert('ESSE ITEM GEROU PEDIDO DE TRANSFERĘNCIA. NĂO É POSSÍVEL ALTERAR A QUANTIDADE !!!', 'FT080RDES\ChkTransf')
			lRetorno := .F.
		EndIf
	EndIf
EndIf

Return(lRetorno)