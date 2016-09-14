#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#DEFINE  ENTER CHR(13)+CHR(10)

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    | FT100RNI   | Autor | Rafael                | Data |09.03.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Avaliação dos itens da regra de negócios                       ³±±
±±³          ³Ponto de Entrada que possibilita a continuação da avaliação    ³±±
±±³          ³dos itens da regra de negócios.                                ³±±
±±³          ³                                                               ³±±
±±³          ³                                                               ³±±
±±³          ³ Primeiro avalia Regra padrao                                  ³±±
±±³          ³ Chamado no PE TK271BOK (Apos Confirmar AT)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³IMDEPA                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
************************************************************************
User Function FT100RNI()
************************************************************************
Local aCodRegra    	:=	IIF(Type('aImdCodR') == 'A', aImdCodR, {ParamIxb[01]})		//	Código da regra  (BTN CONFIRMAR aImdCodR CONTEM REGRAS DO PRW TK271RN)
Local cTabPreco    	:= 	ParamIxb[02]		//	Código da tabela de preço
Local cCondPg      	:= 	ParamIxb[03]		//	Código da condição de pagamento
Local cFormPg      	:= 	ParamIxb[04]		//	Código da forma de pagamento
Local aProdutos    	:= 	ParamIxb[05]       	//	Array com o código de produto
Local aProdDesc    	:= 	ParamIxb[06]		//	Array com detalhe de descontos.Detalhamento em observações.
Local lContinua    	:= 	ParamIxb[07]		//	Indica se continua pesquisa
Local lRetorno     	:= 	ParamIxb[08]		//	Indica se regra ou exceção
Local lContVerba   	:= 	ParamIxb[09]		//	Indica se continua verba
Local lExecao      	:= 	ParamIxb[10]		//	Indica validação de operações de exceção 

Local aRetPE       	:= 	{}
Local aRegras      	:= 	{}
Local aBloqueios 	:= 	{}
Local aDescRN		:=	{}

Local lProdACX     	:= 	.F.
Local lAchouACX 	:= 	.F.
Local lOperFat 		:= 	.F.			
Local lExecute		:=	.F.
 
Local cCliente 		:= 	''
Local cLoja 		:= 	''
Local cMarca 		:= 	''
Local cGrupo 		:= 	''
Local cGrMar3 		:= 	''
Local cCurva 		:= 	''
Local cItemDesc	 	:=	''
Local cItemRgBlq 	:= 	''

Local nAbaRgBlq		:=	0
Local nLnaCols		:=	0

Local lSomaVer  	:= (SuperGetMv("MV_SOMAVER",.F.,"S") == "S")	// Indica se caso o vendedor realize uma venda com preco maior que o de tabela, a diferenca sera adicionada a verba correspondente.

Local lBloqPV 		:= 	.F.
Local lPreview 		:= 	.F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³      Estrutura do array aProdDesc                                           ³
//³      [1] - Codigo do Produto                                                ³
//³      [2] - Item do Pedido de Venda                                          ³
//³      [3] - Preco de Venda                                                   ³
//³      [4] - Preco de Lista                                                   ³
//³      [5] - % do Desconto Concedido no item do pedido                        ³
//³      [6] - % do Desconto Permitido pela regra (FtRegraNeg)                  ³
//³      [7] - Indica se sera necessario verificar o saldo de verba             ³
//³                            01 - Bloqueio de regra de negocio                ³
//³                            02 - Bloqueio para verificacao de verba          ³
//³      [8] - Valor a ser abatido da verba caso seja aprovada (FtVerbaVen)     ³
//³      [9] - Flag que indica se o item sera analisado nas regras              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



If FunName() == 'TMKA271'

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ MOSTRAR TELA BLOQ.REGRAS X ITENS ATENDIMENTO QDO CLICAR NO BOTAO CONFIRMAR   	³ 
	//|	OBS.: --> NO BOTAO DE COND.PAGTO (F6) E OUTRAS CHAMADAS NAO MOSTRAR <--		 	|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| *** PONTO DE ENTRADA CHAMADA EM *CADA PARCELA* DA CONDICAO DE PAGAMENTO		 	|
	//|     TK273MONTAPARCELA() -> TMKA273C.PRW										 	|
	//|		FTREGRANEG()->FTREGNEGIT()->FT100RNI()									 	|
	//|																					|
	//|	*** PARA NAO MOSTRAR TELA DE BLOQUEIO FOI UTILIZADO UM FLAG NO ARRAY aProdDesc	|
	//|		Eh ADICIONADO +1 ELEMENTO NO ARRAY... ENTAO QUANDO aProdDesc[nX] > 09		|
	//|		SIGNIFICA QUE O A TELA FOI MOSTRADA PARA O USUARIO.                         |
	//|																					|
	//|	*** O SISTEMA APRESENTA VALORES DE DESCONTO INDEVIDO							|
	//|		O PROTHEUS CALCULA\CONSIDERA O DESCONTO DA SEGUINTE MANEIRA:				|
	//|		IF UB_DESC == 0 AND PRECO UNITARIO < PRECO TABELA							|
	//|		   nDescon := (100 - (PRECO UNITARIO / PRECO TABELA) * 100 )				|
	//|     ELSE                                                                        |
	//|        nDescon := UB_DESC														|
	//|     ENDIF																		|
	//| 	UB_DESC Eh ZERADO APOS O NOVO CALCULO DE PRECO DE VENDA. 					|
	//|		NAO UTILIZAMOS ESSE CAMPO QUE Eh PADRAO AO FATURAR O PEDIDO O PROTHEUS 		|
	//|     CONCEDE NOVAMENTE ESSE DESCONTO.											|
	//|																					|
	//|	***	TINHAMOS CASO ONDE O SISTEMA APRESENTAVA MSG DE BLOQUEIO ONDE O VALOR DE 	|
	//|     DESCONTO CONCEDIDO PELO VENDEDOR NAO ERA O VALOR INDORMADO PELO VENDEDOR	|
		
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|	 EXEMPLO PV COM BLOQUEIO DE REGRA INDEVIDO.										|
	//|																					|
	//| (aProdDesc[nP][06] > 0 .And. aProdDesc[nP][06] < nDescRN)  						|
	//³  EXEMPLO DO PEDIDO DE CURITIBA                         							³
	//³  nDescCC = 4%                                          							³
	//³  nDescRN = 4%                                          							³
	//³  aProdDesc[nP][06] = 2%                                							³
	//³  OCORREU QUE PEDIDO FICOU BLOQUEADO POREM INDEVIDAMENTE							³
	//|																					|
	//|  OUTRO CASO DE CURITIBA															|
	//|  VENDEDOR CONCEDEU 2% DE DESCONTO E DESC.REGRA TB ERA 2%						|
	//|  NO ARRAY aProdDesc[nP][05] ESTAVA COM 7.31....									|
	//|  DEIXANDO O PV BLOQUEADO INDEVIDAMENTE											|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cCliente :=	AllTrim(M->UA_CLIENTE)
	cLoja	 :=	AllTrim(M->UA_LOJA)
	lOperFat :=	(M->UA_OPER == '1')		// 	1=FATURAMENTO; 2=ORCAMENTO; 3=ATENDIMENTO


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| MSG SOMENTE Eh APRESENTADA QUANDO USUARIO CONFIRMA O ATENDIMENTO			|
	//| ROTINA TB Eh CHAMADA NO BOTAO DE CONDICAO DE PAGAMENTO - (F6)				|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lExecute := IIF(IsInCallStack('TK271GRAVA'), .T., .F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| SE aProdDesc[nX] > 10 NAO EXECUTA ROTINA E NAO MOSTRA MSG DE BLOQUEIO	|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aEval(aProdDesc, {|nX|  lExecute := IIF(Len(nX)>=10, .T., lExecute) })

EndIf




If !lExecute

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| aProdDesc[07] := '' RETIRA FLAG PARA MOSTRAR MENSAGEM PADRAO DE BLOQUEIO	|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aEval(aProdDesc, {|aProdDesc|aProdDesc[07] := ''})
	lRetorno	:= .T.
	lContVerba 	:= .T.
	lContinua 	:= .F.
	Return({aProdDesc,lContinua,lRetorno,lContVerba,lExecao})

EndIf 






For i:= 1 To Len(aCodRegra)


	ACT->(DbSetOrder(1))	//	ITENS DA REGRA DE NEGOCIACAO
	If ACT->(DbSeek( xFilial("ACT") + aCodRegra[i] ))
		Do While (	ACT->ACT_FILIAL	 == xFilial("ACT") .And. ACT->ACT_CODREG == aCodRegra[i] )
			Aadd( aRegras, {ACT->ACT_FILIAL,ACT->ACT_CODREG,ACT->ACT_TPRGNG,ACT->ACT_CODTAB,ACT->ACT_CONDPG,ACT->ACT_FORMPG,ACT->ACT_ITEM} )
			ACT->(DbSkip())
		EndDo
	EndIf



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  ANÁLISE DAS REGRAS DENTRO DO ARRAY DE REGRAS	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aRegras) > 0
		
		//SE SO HOUVER EXCECAO, PARTE DO PRINCIPIO QUE ESTAO APROVADO ATE QUE ALGUMA EXCECAO BLOQUEIE.
		If aScan( aRegras, { |x| x[3] == "2" } ) > 0 .AND. aScan( aRegras, { |x| x[3] == "1" } ) == 0
			lRetorno := .T.
			lExecao   := .F.
		
			For nX := 1 To Len( aRegras )
				If(	IF(Empty(aRegras[nX,4]), .T., AllTrim(aRegras[nX,4]) == Alltrim(cTabPreco) ).AND.;
					IF(Empty(aRegras[nX,5]), .T., AllTrim(aRegras[nX,5]) == Alltrim(cCondPg)   ).AND.;
					IF(Empty(aRegras[nX,6]), .T., AllTrim(aRegras[nX,6]) == Alltrim(cFormPg)   ))
					lRetorno 	:= 	.F.
					lContinua 	:=	.F.
                                
                    cCpoBlq	:=	''                                            
					cCpoBlq	+=	IIF(AllTrim(aRegras[nX,4]) != Alltrim(cTabPreco),	AllTrim(RetTitle('ACT_CODTAB'))+' ','')
					cCpoBlq	+=	IIF(AllTrim(aRegras[nX,5]) != Alltrim(cCondPg),	AllTrim(RetTitle('ACT_CONDPG'))+' ','')
					cCpoBlq	+=	IIF(AllTrim(aRegras[nX,6]) != Alltrim(cFormPg),	AllTrim(RetTitle('ACT_FORMPG'))+' ','')


					// GUARDA MOTIVO DO BLOQUEIO, PARA MOSTRAR MSG AO USUARIO
					cItemRgBlq := AllTrim(aRegras[nX,7]) 						   		//	ITEM DA REGRA QUE GEROU BLOQUEIO
					nAbaRgBlq  := 1 											   		//	BLOQUEIO POR REGRA DE NEGOCIACAO (ABA NEGOCIACAO)
					Aadd (aBloqueios,{aRegras[nX,2], cItemRgBlq, nAbaRgBlq, cCpoBlq}) 	//	GUARDA ARRAY COM BLOQUEIOS
				EndIf
			Next
		
		Else
		
			 // SE NAO, VERIFICA A LIBERACAO ITEM A ITEM DAS REGRAS E EXCECOES.
			For nX := 1 To Len( aRegras )
				
				If(	IF(Empty(aRegras[nX,4]), .T., AllTrim(aRegras[nX,4]) == Alltrim(cTabPreco) ).AND.;
					IF(Empty(aRegras[nX,5]), .T., AllTrim(aRegras[nX,5]) == Alltrim(cCondPg)   ).AND.;
					IF(Empty(aRegras[nX,6]), .T., AllTrim(aRegras[nX,6]) == Alltrim(cFormPg)   ))
					lRetorno  := ( aRegras[nX,3] == "1" )
					lContinua := .F.
					lExecao   := ( aRegras[nX,3] == "1" )

                    cCpoBlq	:=	''                                            
					cCpoBlq	+=	IIF(AllTrim(aRegras[nX,4]) != Alltrim(cTabPreco),	AllTrim(RetTitle('ACT_CODTAB'))+' ','')
					cCpoBlq	+=	IIF(AllTrim(aRegras[nX,5]) != Alltrim(cCondPg),	AllTrim(RetTitle('ACT_CONDPG'))+' ','')
					cCpoBlq	+=	IIF(AllTrim(aRegras[nX,6]) != Alltrim(cFormPg),	AllTrim(RetTitle('ACT_FORMPG'))+' ','')
					
					
					//	GUARDA MOTIVO DO BLOQUEIO, PARA MOSTRAR MSG AO USUARIO
					If !lRetorno
						cItemRgBlq += AllTrim(aRegras[nX,7]) 					   		//	ITEM DA REGRA QUE GEROU BLOQUEIO
						nAbaRgBlq := 1 											   		//	BLOQUEIO POR REGRA DE NEGOCIACAO (ABA NEGOCIACAO)
						Aadd (aBloqueios,{aRegras[nX,2],cItemRgBlq,nAbaRgBlq,cCpoBlq}) //	GUARDA ARRAY COM BLOQUEIOS
					EndIF
					//Exit
				
				Else
				
					lRetorno  := .F.
					lContinua := .F.
					
					//	GUARDA MOTIVO DO BLOQUEIO, PARA MOSTRAR MSG AO USUARIO.
					//	BLOQUEADO POR NAO ACHAR NENHUM ITEM QUE ATENDA A REGRA
					If !lRetorno
						nAbaRgBlq := 1 												//	BLOQUEIO POR REGRA DE NEGOCIACAO (ABA NEGOCIACAO)
						Aadd(aBloqueios,{aRegras[nX,2],cItemRgBlq,nAbaRgBlq,''}) 	//	GUARDA ARRAY COM BLOQUEIOS
					EndIf
				
				EndIf
			
			Next
		
		EndIf
	
	EndIf
	
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  			REGRA DE COMERCIALIZACAO	  		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//  PROCESSA OS ITENS DE COMERCIALIZACAO, MESMO QUE TENHA ENCONTRADO
	//  UM ITEM NEGOCIACAO VALIDO, PARA LOCALIZAR UMA POSSIVEL EXCESSAO
	If lRetorno .Or. lContinua
	
		//For i:=1 to len(aCodRegra)
			// Percorre todos os produtos
			For nLoop2 := 1 To Len(aProdutos)
	
				cCodPro := aProdutos[ nLoop2 ]
				SB1->( DbSetOrder( 1 ) )
			    If SB1->( DbSeek( xFilial( "SB1" ) + cCodPro ) )
	
					cGrupo 	:= SB1->B1_GRUPO
					cGrMar3 := SB1->B1_GRMAR3
					cCurva 	:= SB1->B1_CURVA
	
					lContItem := .T.
	
					ACX->( DbSetOrder( 2 ) )
					If !ACX->( dbSeek( xFilial( "ACX" ) + aCodRegra[i] ) )  //Verifica se h?a regra
						lAchouACX := .F.
					Else
		 			
		 				If 	Empty(ACX->ACX_CODPRO) .And. ;
		 					Empty(ACX->ACX_GRUPO)  .AND. ;
		 					Empty(ACX->ACX_GRMAR3) .AND. ;
		 					Empty(ACX->ACX_CURVA)  .AND. ;
		 					!ACX->(EOF())
							
							lRetorno  := ACX->ACX_TPRGNG == "1"	// TIPO DE REGRA  1=REGRA;2=EXCECAO
							lContinua := .F.
							//Guarda motivo do bloqueio, para mostrar msg ao usuario
							If !lRetorno
								cItemRgBlq:= AllTrim(ACX->ACX_ITEM) //item da regra que gerou bloqueio
								nAbaRgBlq := 2 //bloqueio por regra de comercializacao (aba Comercializacao)
								Aadd (aBloqueios,{aCodRegra[i],cItemRgBlq,nAbaRgBlq,'Todos Campos'}) //guarda array com bloqueios
							EndIf
							//Exit
						Endif
					EndIf
	
		            //VERIFICA SE BATE OS DADOS COM A REGRA
	
					cQuery := " SELECT ACX_FILIAL,ACX_CODREG,ACX_ITEM,ACX_CODPRO,ACX_GRUPO,ACX_TPRGNG,ACX_MARCA,ACX_GRMAR3,ACX_CURVA"
					cQuery +=" FROM "
					cQuery += RetSqlName("ACX")
					cQuery +=" WHERE "
					cQuery += "ACX_FILIAL = '"+xFilial("ACX")+ "' AND "
					cQuery += "ACX_CODREG = '"+aCodRegra[i]+"' AND "
					cQuery += "(ACX_CODPRO = '"+Space(Len(SB1->B1_COD) )+"' OR ACX_CODPRO = '"+cCodPro+"') AND "
					cQuery += "(ACX_GRUPO =  '"+Space(Len(SB1->B1_GRUPO) )+"' OR ACX_GRUPO LIKE '"+cGrupo+"') AND "
					cQuery += "(ACX_GRMAR3 = '"+Space(Len(SB1->B1_GRMAR3) )+"' OR ACX_GRMAR3 = '"+cGrMar3+"') AND "
					cQuery += "(ACX_CURVA = '"+Space(Len(SB1->B1_CURVA) )+"' OR ACX_CURVA LIKE '"+cCurva+"') AND "
					cQuery += " D_E_L_E_T_ <> '*' "
					cQuery += " ORDER BY ACX_FILIAL,ACX_CODREG,ACX_CODPRO,ACX_GRUPO,ACX_GRMAR3,ACX_CURVA "
	
					//cQuery := ChangeQuery( cQuery )
					
					dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), "QRYACX", .F., .T. )
	
					//inicio da verificação dos níveis ???
	
					DbSelectArea("QRYACX")
					DBGotop()
					nRegQRY := Contar("QRYACX","!Eof()")
					DBGotop()
	
					if nRegQRY > 0
						//maior que zero faz coisas
						if nRegQRY == 1
							lRetorno  := QRYACX->ACX_TPRGNG == "1"
							lContinua := .F.
							lContItem := .F.
							// Guarda motivo do bloqueio, para mostrar msg ao usuario
							If !lRetorno                                       
								
			                    cCpoBlq	:=	''                                            
								cCpoBlq	+=	IIF(!Empty(QRYACX->ACX_CODPRO),	AllTrim(RetTitle('ACX_CODPRO'))+' ','')
								cCpoBlq	+=	IIF(!Empty(QRYACX->ACX_GRUPO),	AllTrim(RetTitle('ACX_GRUPO')) +' ','')
								cCpoBlq	+=	IIF(!Empty(QRYACX->ACX_GRMAR3),	AllTrim(RetTitle('ACX_GRMAR3'))+' ','')
								cCpoBlq	+=	IIF(!Empty(QRYACX->ACX_CURVA),	AllTrim(RetTitle('ACX_CURVA')) +' ','')
							
								cItemRgBlq += AllTrim(QRYACX->ACX_ITEM) //item da regra que gerou bloqueio
								nAbaRgBlq  := 2 //bloqueio por regra de comercializacao (aba Comercializacao)
								Aadd (aBloqueios,{aCodRegra[i],cItemRgBlq,nAbaRgBlq,cCpoBlq}) //guarda array com bloqueios
							Endif
						
						else
						
							//maior que 1 percorre tudo e
							Do While QRYACX->(!eof())
								If !Empty(QRYACX->ACX_CODPRO)
									lRetorno  := QRYACX->ACX_TPRGNG == "1"
									lContinua := .F.
									lContItem := .F.
									// Guarda motivo do bloqueio, para mostrar msg ao usuario
									If !lRetorno       
										cItemRgBlq 	:=	Alltrim(QRYACX->ACX_ITEM) //item da regra que gerou bloqueio
										nAbaRgBlq  	:= 	2 //bloqueio por regra de comercializacao (aba Comercializacao)
										cCpoBlq		:=	AllTrim(RetTitle('ACX_CODPRO'))
										Aadd (aBloqueios,{aCodRegra[i],cItemRgBlq,nAbaRgBlq, cCpoBlq}) //guarda array com bloqueios
									Endif
								Else
									If !Empty(QRYACX->ACX_GRUPO)
										lRetorno  := QRYACX->ACX_TPRGNG == "1"
										lContinua := .F.
										lContItem := .F.
										// Guarda motivo do bloqueio, para mostrar msg ao usuario
										If !lRetorno
											cItemRgBlq += AllTrim(QRYACX->ACX_ITEM)  //item da regra que gerou bloqueio
											nAbaRgBlq  := 2 //bloqueio por regra de comercializacao (aba Comercializacao)
											cCpoBlq		:=	AllTrim(RetTitle('ACX_GRUPO'))
											Aadd (aBloqueios,{aCodRegra[i],cItemRgBlq,nAbaRgBlq, cCpoBlq}) //guarda array com bloqueios
										Endif
									Else
										If !Empty(QRYACX->ACX_GRMAR3)
											lRetorno  := QRYACX->ACX_TPRGNG == "1"
											lContinua := .F.
											lContItem := .F.
											// Guarda motivo do bloqueio, para mostrar msg ao usuario
											If !lRetorno
												cItemRgBlq 	:= AllTrim(QRYACX->ACX_ITEM) //item da regra que gerou bloqueio
												nAbaRgBlq  	:= 2 //bloqueio por regra de comercializacao (aba Comercializacao)
												cCpoBlq		:=	AllTrim(RetTitle('ACX_GRMAR3'))
												Aadd (aBloqueios,{aCodRegra[i],cItemRgBlq,nAbaRgBlq,cCpoBlq}) //guarda array com bloqueios
											Endif
										
										Else
											
											If !Empty(QRYACX->ACX_CURVA)
												lRetorno  := QRYACX->ACX_TPRGNG == "1"
												lContinua := .F.
												lContItem := .F.
												// Guarda motivo do bloqueio, para mostrar msg ao usuario
												If !lRetorno
													cItemRgBlq 	:=	AllTrim(QRYACX->ACX_ITEM) //item da regra que gerou bloqueio
													nAbaRgBlq  	:= 	2 //bloqueio por regra de comercializacao (aba Comercializacao)
													cCpoBlq		:=	AllTrim(RetTitle('ACX_CURVA'))
													Aadd (aBloqueios,{aCodRegra[i],cItemRgBlq,nAbaRgBlq,cCpoBlq}) //guarda array com bloqueios
												Endif
											Endif
											
										Endif
										
									Endif
									
								Endif
								
						    	QRYACX->(DBSkip())
							Enddo
						endif
					endif
	
					QRYACX->(DBCloseAREA())
	
					If  lContItem .And. ACX->( dbSeek( xFilial( "ACX" ) + aCodRegra[i] ) ) .And. ;
						(!Empty(ACX->ACX_CODPRO) .Or. !Empty(ACX->ACX_GRUPO) .Or. !Empty(ACX->ACX_GRMAR3) .Or. !Empty(ACX->ACX_CURVA)) .And. ;
						ACX->ACX_TPRGNG == "1"
				   		lProdACX := .F.
					EndIf      // PROCURA POR CURVA E GRUPO DE MARCA ???
	
					If Upper(FunName())=="TMKA271"
		  				If lContItem .And. !lProdACX
							aProdDesc[nLoop2,7] := "01"
						ElseIf !lContItem .And. lProdACX
							aProdDesc[nLoop2,7] := ""
						EndIf
					EndIf
				Endif
	
			Next nLoop2
		//Next i
	EndIf
	
	
	// ACX contém pelo menos um registro cadastrado e algum produto do pedido nao foi encontrado -> REPROVAR.
	// Se ACX vazia, APROVAR.
	If lAchouACX .And. !lProdACX
		lRetorno := .F.
		// Guarda motivo do bloqueio, para mostrar msg ao usuario
		If (!lRetorno)
			nAbaRgBlq := 2 //bloqueio por regra de comercializacao (aba Comercializacao)
			Aadd (aBloqueios,{aCodRegra[i],cItemRgBlq,nAbaRgBlq,'6'}) //guarda array com bloqueios
		EndIf
	EndIf
	
	
	


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³   			  REGRAS DE DESCONTOS 				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno //.And. lContVerba  // DEBUG - PERSONALIZAÇÃO PARA VERIFICAÇÃO DOS DESCONTOS
	
		//For i:=1 To Len(aCodRegra)
			aStruACN:= ACN->(DbStruct())
	
			For nLoop := 1 To Len(aProdDesc)

				cCodProd := aProdDesc[nLoop][01]
				cItemAT  := aProdDesc[nLoop][02]
				nLnaCols := 0
				

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ aProdDesc CONTEM ITENS DELETADOS DO ATENDIMENTO		³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nLnaCols := Ascan(aCols, {|X| X[1] == cItemAT })
				If nLnaCols == 0
					Loop
				Else
					If aCols[nLnaCols][Len(aHeader)+1]
	            		Loop   
					EndIf
				EndIf

								
				//Verifica se o item deve ser analisado
				If aProdDesc[nLoop][09]
					
					// ALIMENTA VALORES SB1 para query posterior
					SB1->(DbSetOrder(1))
				    If SB1->(DbSeek(xFilial("SB1") + cCodProd ))
				    	cDescGr    	:= SB1->B1_GRUPO
						cDescGrM 	:= SB1->B1_GRMAR3
						cDescCur 	:= SB1->B1_CURVA
					EndIf
	
					//faz query para ver em que regra o produto se encaixa
					cQuery := " SELECT ACN_FILIAL,ACN_CODREG,ACN_ITEM,ACN_CODPRO,ACN_GRPPRO,ACN_GRMAR3,ACN_CURVA,ACN_DESCON	"+ENTER
					cQuery += " FROM "+RetSqlName("ACN")+ENTER
	
					cQuery += " WHERE 									"+ENTER
					cQuery += " ACN_FILIAL = '"+xFilial("ACN")+ "' AND	"+ENTER
					cQuery += "(ACN_CODREG = '"+Space(Len(ACN->ACN_CODREG))+"' OR ACN_CODREG = '"+aCodRegra[i]+"')	AND "+ENTER
					cQuery += "(ACN_CODPRO = '"+Space(Len(SB1->B1_COD))	+"' OR ACN_CODPRO = '"+cCodProd+"') 	AND "+ENTER
					cQuery += "(ACN_GRPPRO = '"+Space(Len(SB1->B1_GRUPO) )	+"' OR ACN_GRPPRO = '"+cDescGr+"') 		AND "+ENTER
					cQuery += "(ACN_GRMAR3 = '"+Space(Len(SB1->B1_GRMAR3))	+"' OR ACN_GRMAR3 = '"+cDescGrM+"') 	AND "+ENTER
					cQuery += "(ACN_CURVA  = '"+Space(Len(SB1->B1_CURVA))	+"' OR ACN_CURVA LIKE '"+cDescCur+"') 	AND "+ENTER
					cQuery += " D_E_L_E_T_ <> '*' "+ENTER
					cQuery += " ORDER BY ACN_FILIAL,ACN_CODREG,ACN_CODPRO,ACN_GRPPRO,ACN_GRMAR3,ACN_CURVA "+ENTER

					//MemoWrit(GetTempPath()+'_REGRA_NEGOCIO.TXT', cQuery)	
					//cQuery := ChangeQuery( cQuery )
					
					dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), "QRYACN", .F., .T. )
	
					DbSelectArea("QRYACN");	DbGoTop()
					nRegQRY := Contar("QRYACN","!Eof()")
					QRYACN->(DbGoTop())
	
					nDescRD	:=	0
					nDescRN	:=	0
					cCpoBlq	:=	''
					
					
					If nRegQRY > 0
					
						If nRegQRY == 1

							nDescRN 	:= 	QRYACN->ACN_DESCON
							cItemDesc 	:= 	QRYACN->ACN_ITEM
						
							cCpoBlq	:=	''                                            
							cCpoBlq	+=	IIF(!Empty(QRYACN->ACN_CODPRO),	AllTrim(RetTitle('ACN_CODPRO')) +' ','')
							cCpoBlq	+=	IIF(!Empty(QRYACN->ACN_GRPPRO),	AllTrim(RetTitle('ACN_GRPPRO'))+' ','')
							// cCpoBlq	+=	IIF(!Empty(QRYACN->ACN_DESCON),	AllTrim(RetTitle('ACN_DESCON')) +' ','')
							cCpoBlq	+=	IIF(!Empty(QRYACN->ACN_GRMAR3),	AllTrim(RetTitle('ACN_GRMAR3'))+' ','')
							cCpoBlq	+=	IIF(!Empty(QRYACN->ACN_CURVA),	AllTrim(RetTitle('ACN_CURVA')) +' ','')

							Aadd(aDescRN, {QRYACN->ACN_CODREG, QRYACN->ACN_DESCON, cItemDesc, cCpoBlq, cCodProd, cItemAT, nLnaCols})
							
						Else
						
							
							//nContDesc :=  100
							Do While QRYACN->(!Eof())
							    
							    
							    If !Empty(QRYACN->ACN_CODPRO)
							    	nDescRN 	:=	QRYACN->ACN_DESCON
							    	cItemDesc 	:= 	QRYACN->ACN_ITEM
							    	cCpoBlq		:=	AllTrim(RetTitle('ACN_CODPRO'))
							    	Aadd(aDescRN, {QRYACN->ACN_CODREG, nDescRN, cItemDesc, cCpoBlq, cCodProd, cItemAT, nLnaCols} )
							    Else
							    	
							    	If !Empty(QRYACN->ACN_GRPPRO)
							    		nDescRN 	:=	QRYACN->ACN_DESCON
							    		cItemDesc 	:= 	QRYACN->ACN_ITEM
							    		cCpoBlq		:=	AllTrim(RetTitle('ACN_GRPPRO'))
							    		Aadd(aDescRN, {QRYACN->ACN_CODREG, nDescRN, cItemDesc, cCpoBlq, cCodProd, cItemAT, nLnaCols} )
							    	Else
							    		
							    		If !Empty(QRYACN->ACN_GRMAR3)
							    			nDescRN 	:= 	QRYACN->ACN_DESCON
							    			cItemDesc 	:= 	QRYACN->ACN_ITEM
								    		cCpoBlq		:=	AllTrim(RetTitle('ACN_GRMAR3'))
								    		Aadd(aDescRN, {QRYACN->ACN_CODREG, nDescRN, cItemDesc, cCpoBlq, cCodProd, cItemAT, nLnaCols} )
							    		Else
							    			
							    			If !Empty(QRYACN->ACN_CURVA)
							    				nDescRN 	:=	QRYACN->ACN_DESCON
							    				cItemDesc 	:= 	QRYACN->ACN_ITEM
									    		cCpoBlq		:=	AllTrim(RetTitle('ACN_CURVA'))
									    		Aadd(aDescRN, {QRYACN->ACN_CODREG, nDescRN, cItemDesc, cCpoBlq, cCodProd, cItemAT, nLnaCols} )
							    			EndIf 	//	CURVA
							    			
							    		EndIf 		//	GRUPO MARCA
							    		
							    	EndIf 			//	GRUPO PRODUTO
							    	
							    EndIf 				//	PRODUTO

						    
							
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³     DESCONTO EM CASCATA			³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								//nDescTab 	:=	QRYACN->ACN_DESCON / 100
								//nContDesc 	:= 	nContDesc - (nContDesc * nDescTab)

								QRYACN->(DbSkip())
							EndDo
								
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ RESULTADO DESCONTO EM CASCATA	³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							//nDescRN := 100 - nContDesc

						EndIf
						
					EndIf
	
					QRYACN->(DbCloseArea())
	
	                
				EndIf
			Next	
			
	EndIf

Next



// Aadd(aDescRN, {QRYACN->ACN_CODREG, QRYACN->ACN_DESCON, cItemDesc, cCpoBlq, cCodProd, cItemAT, nLnaCols})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  VERIFICA REGRA DE DESCONTO 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aDescRN) > 0 
	
	aSort(aDescRN,,,{|X,Y| X[6] < Y[6]  })

	For nP:=1 To Len(aProdDesc)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ OBS.: SE ITEM DELETADO NO ACOLS   1,2,4				³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
		lBloqDesc 	:= .F.
		aBlqDesc	:=	{}
		nContDesc 	:=  100
		cItemAProd 	:=	aProdDesc[nP][02] 
		nLnaCols	:=	0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ aProdDesc CONTEM ITENS DELETADOS DO ATENDIMENTO		³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nLnaCols := Ascan(aCols, {|X| X[1] == cItemAProd })
		If nLnaCols == 0
			Loop
		Else
			If aCols[nLnaCols][Len(aHeader)+1]
            		Loop   
			EndIf
		EndIf

				
						
		If Ascan(aDescRN, {|X| AllTrim(X[06]) == cItemAProd}) > 0

			For nD:=1 To Len(aDescRN)
				//						  1					  2				  3			4		 5 		   6        7 = LINHA DO ACOLS
				// Aadd(aDescRN, {QRYACN->ACN_CODREG, QRYACN->ACN_DESCON, cItemDesc, cCpoBlq, cCodProd, cItemAT, nLnaCols})
				
				//nLnaCols := aDescRN[nD][07]

				If AllTrim(aDescRN[nD][06]) == AllTrim(cItemAProd)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³     DESCONTO EM CASCATA			³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nDescTab 	:=	aDescRN[nD][02] / 100
					nContDesc 	:= 	nContDesc - (nContDesc * nDescTab)	


					//						1				2		   3		4				5					6				7				8
					Aadd(aBlqDesc,  {aDescRN[nD][01],aDescRN[nD][03],3,aDescRN[nD][04],aDescRN[nD][05],aDescRN[nD][06], aDescRN[nD][02], aDescRN[nD][07]})

				EndIf
		    
		    Next
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ RESULTADO DESCONTO EM CASCATA	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nDescRN 	:= 	100 - nContDesc            
			nDescCC		:=	GdFieldGet('UB_DESCVEN', nLnaCols) 
		
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³      Estrutura do array aProdDesc                                           ³
			//³      [1] - Codigo do Produto                                                ³
			//³      [2] - Item do Pedido de Venda                                          ³
			//³      [3] - Preco de Venda                                                   ³
			//³      [4] - Preco de Lista                                                   ³
			//³      [5] - % do Desconto Concedido no item do pedido                        ³
			//³      [6] - % do Desconto Permitido pela regra (FtRegraNeg)                  ³
			//³      [7] - Indica se sera necessario verificar o saldo de verba             ³
			//³                            01 - Bloqueio de regra de negocio                ³
			//³                            02 - Bloqueio para verificacao de verba          ³
			//³      [8] - Valor a ser abatido da verba caso seja aprovada (FtVerbaVen)     ³
			//³      [9] - Flag que indica se o item sera analisado nas regras              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| AJUSTE VALORES.... PRC.UNIT < PRC.TAB, ETC... 				|
			//|																|
			//| ATUALIZA DESCONTO CONCEDIDO PELO VENDEDOR aProdDesc[05]  	|
			//| ATUALIZA DESCONTO DE REGRA aProdDesc[06]  					|
			//| OCORRENCIA DE CASOS QUE ESTA TRAZENDO VALORES ERRADOS		|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aProdDesc[nP][05] 	:=	nDescCC		//	% DE DESCONTO DO PEDIDO
			aProdDesc[nP][06]	:=	nDescRN		// 	% DE DESCONTO PERMITIDO PELA REGRA | GRAVA DESCONTO PERMITIDO NA VERBA E STATUS PARA VERIFICACAO DE SALDO

			If nDescCC > nDescRN

				lContVerba			:= 	.T.
				aProdDesc[nP][07] 	:= 	'01'
		  		aEval(aBlqDesc, {|nX| Aadd(aBloqueios, nX)})
            
            Else
				lContVerba			:= 	.T.
            	aProdDesc[nP][07] 	:= 	''
			EndIf

		EndIf

	Next
	
		
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| FLAG UTILIZADO PARA MOSTRAR APENAS 1 VEZ A TELA COM OS ITENS COM BLOQUEIOS   |
//| PONTO DE ENTRADA CHAMADA EM CADA PARCELA DA CONDICAO DE PAGAMENTO			 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEval(aProdDesc, {|aProdDesc| lPreview := IIF(Len(aProdDesc)>=10, .F., .T.) })
If lPreview

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| ADICIONA MAIS UM ELEMENTO NO ARRAY PARA UTILIZAR DE FLAG...                  |
	//| PARA MOSTRAR APENAS 1 VEZ A TELA COM OS BLOQUEIOS   						 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	aEval(aProdDesc, {|aProdDesc| Aadd(aProdDesc, .T.) })


	aATxRN := {}

	If Upper(Left(GetEnvServer(),07)) == 'SOLUTIO' .Or. Upper(AllTrim(cUserName)) == 'SOLUTIO' //UsrRetName(RetCodUsr()) == 'SOLUTIO'
		If Len(aBloqueios) > 0
			BrwRBlq(aBloqueios)
		EndIf
	Else	
		If Len(aBloqueios) > 0 .And. lOperFat
			BrwRBlq(aBloqueios)
		EndIf
    EndIf

EndIf

Return({aProdDesc,lContinua,lRetorno,lContVerba,lExecao})
************************************************************************
Static Function BrwRBlq(aBloqueios)	// TELA QUE EXIBE OS BLOQUEIOS POR REGRA NO ATENDIMENTO
************************************************************************
Local aBrowse := {}
Local aAreaAnt := GetArea()

Static oDlg
Static oSay1



For nX:= 1 To Len(aBloqueios)

	cDescAba := ''
	    	
	DbSelectArea("ACS");DBSetOrder(1)
	If DbSeek(xFilial("ACS")+aBloqueios[nX][1], .F.)
		If aBloqueios[nX][3] == 1
			cDescAba := 'Negociacao'                          
		ElseIf aBloqueios[nX][3] == 2
			cDescAba := 'Comercializacao'
		ElseIf aBloqueios[nX][3] == 3
			cDescAba := 'Descontos'
		EndIf
	EndIf

	// OBS.: ITEM DO ATENDIMENTO PODE SER <> DA LINHA DO ACOLS
	// EX.: AT COM 5 ITENS, POREM 4o ITEM FOI DELETADO. AO BUSCAR AT VIA HISTORICO O 5o ITEM PASSA A SER A 4o LINHA DO ACOLS.
	


    //					[01] COD.REGRA		[02] DESC.REGRA   [03] ITEM RD    [04]     [05]      [06]     [07]  
	// Aadd(aDescRN, {QRYACN->ACN_CODREG, QRYACN->ACN_DESCON, cItemDesc,    cCpoBlq, cCodProd, cItemAT, nLnaCols})

	//				    [01]COD.REGRA	[02]ITEM RD     [03] ABA-DESC   [04]cCpoBlq 	 [05]COD.PROD  	  [06]ITEM AT 	   [07]DESC.REGRA   [08] nLnaCols
	// Aadd(aBlqDesc,  {aDescRN[nD][01],aDescRN[nD][03],       3 	 ,  aDescRN[nD][04], aDescRN[nD][05], aDescRN[nD][06], aDescRN[nD][02], aDescRN[nD][07]})
						
	// aBloqueios == aBlqDesc	


	nLnaCols := aBloqueios[nX][08]

	Aadd(aBrowse, { AllTrim(ACS->ACS_DESCRI)+Space(05),;		//	[01] DESCRICAO COD.REGRA
					aBloqueios[nX][06],;				   		//	[02] ITEM ATIMENTO
					GdFieldGet('UB_DESCRI',  nLnaCols),;  		//	[03] DESCRICAO PRODUTO
					GdFieldGet('UB_DESCVEN', nLnaCols),;  		//	[04] DESCONTO VENDEDOR
					aBloqueios[nX][07],;						//	[05] DESCONTO REGRA
					cDescAba,;							   		//	[06] ABA BLOQUEIO	[COMERCIALIZACAO\NEGOCIACAO\DESCONTO]
					aBloqueios[nX][04]})						//	[07] CAMPO BLOQUEIO	[GRUPO DE MARCAS\GRUPO\VINCULO\ETC..]


 	Aadd(aATxRN, {	M->UA_NUM,;									//	[01] NUM.ATEND
 					aBloqueios[nX][01],;						//	[02] COD.REGRA
 					cDescAba,;									//	[03] ABA BLOQUEIO	[COMERCIALIZACAO\NEGOCIACAO\DESCONTO]
 					aBloqueios[nX][04],;						//	[04] CAMPO BLOQUEIO	[GRUPO DE MARCAS\GRUPO\VINCULO\ETC..]
 					aBloqueios[nX][06],;						//	[05] ITEM ATEND
 					GdFieldGet('UB_DESCVEN', nLnaCols),;   		//	[06] DESCONTO VENDEDOR
 					aBloqueios[nX][05],;						//	[07] PRODUTO
 					aBloqueios[nX][07],; 						//	[08] DESC.RNEG
 					'',;										//	[09] PV
 					'',;										//	[10] ITEMPV
 					'' })										//	[11] FLAG

Next



															// C1  L1     C2  L2
Define Dialog oDlg Title "Bloqueios - Regras Negociação" From 120,120 To 350,950 Pixel 

    oBrowse := TcBrowse():New(001, 001, 415, 095,,{'Nro. Regra','Nome Regra Negociacao','Aba de Bloqueio','Campo Bloqueio'},{50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
    oBrowse:SetArray(aBrowse)

    oBrowse:AddColumn( TcColumn():New('Item At.'			,{|| aBrowse[oBrowse:nAt][02] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
    oBrowse:AddColumn( TcColumn():New('Produto'				,{|| aBrowse[oBrowse:nAt][03] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
    oBrowse:AddColumn( TcColumn():New('Desc.Vend'			,{|| aBrowse[oBrowse:nAt][04] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
    oBrowse:AddColumn( TcColumn():New('Max.Desc.'			,{|| aBrowse[oBrowse:nAt][05] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
    oBrowse:AddColumn( TcColumn():New('Regra de Negocio   '	,{|| aBrowse[oBrowse:nAt][01] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
    oBrowse:AddColumn( TcColumn():New('Tipo Bloqueio'		,{|| aBrowse[oBrowse:nAt][06] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
    oBrowse:AddColumn( TcColumn():New('Campo Bloqueio'		,{|| aBrowse[oBrowse:nAt][07] },,,,"LEFT",,.F.,.T.,,,,.F.,) )

    TButton():New( 100, 365, '&Sair', oDlg,{|| oDlg:End() },30,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	@ 100, 003  Say oSay1 PROMPT "Nesta tela são exibidas todas as regras que bloqueiam o Pedido de Venda." Size 225, 020 Of oDlg COLORS CLR_HRED,CLR_WHITE/*0, 16777215*/ Pixel

Activate Dialog oDlg Centered



RestArea(aAreaAnt)
Return()
************************************************************************
Static Function ChkProdDXZRD(aProdDesc)
************************************************************************
Local _aArea := GetArea()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VERIFICA\ATUALIZA aProdDesc (AARAY ITEM AT x DESC.RN)						³
//| CASO ITEM DO aProdDesc[X][07] <> 01/02 VERIFICA NA NO LOG NEGOCIO\DESCONTO	|	 
//|																				|
//| CASOS ONDE aProdDesc DEVERIA TER CONTEUDO PARA BLOQUEAR AT ([05],[06],[07]) |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³      Estrutura do array aProdDesc                                           ³
//³      [1] - Codigo do Produto                                                ³
//³      [2] - Item do Pedido de Venda                                          ³
//³      [3] - Preco de Venda                                                   ³
//³      [4] - Preco de Lista                                                   ³
//³      [5] - % do Desconto Concedido no item do pedido                        ³
//³      [6] - % do Desconto Permitido pela regra (FtRegraNeg)                  ³
//³      [7] - Indica se sera necessario verificar o saldo de verba             ³
//³                            01 - Bloqueio de regra de negocio                ³
//³                            02 - Bloqueio para verificacao de verba          ³
//³      [8] - Valor a ser abatido da verba caso seja aprovada (FtVerbaVen)     ³
//³      [9] - Flag que indica se o item sera analisado nas regras              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbselectArea('ZRN');DbSetOrder(1)	//	ZRN_FILIAL + ZRN_NUMAT + ZRD_ITEMAT + ZRN_CODRN
For nX:=1 To Len(aProdDesc)

	cProduto := aProdDesc[nX][01]
	cItemAT	 := aProdDesc[nX][02]
	If DbSeek(xFilial('ZRN') + M->UA_NUM + cItemAT, .F.)
		Do While !Eof() .And. Alltrim(ZRN->ZRN_PRODUT) == Alltrim(cProduto)
			aProdDesc[nX][05]	:=	ZRN->ZRN_VENDA
			aProdDesc[nX][06]	:=	ZRN->ZRN_REGRA
			aProdDesc[nX][07]	:=	'01'
			DbSkip()
		EndDo
    EndIf

Next


RestArea(_aArea)
Return()