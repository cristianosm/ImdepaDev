#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#DEFINE CRLF ( CHR(13)+CHR(10) )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄż±±
±±łPrograma  ł SF1100I     ł Autor ł Marllon Figueiredo ł Data ł 16/04/03 ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±łDescri??o ł Ponto de entrada na inclusao da nota de entrada para infor-ł±±
±±ł          ł mar na planilha de transferencia que o item foi recebido   ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±łSintaxe   ł U_SF1100I()                                                ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±łParametrosł NIL                                                        ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±łRetorno   ł NIL                                                        ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±łUso       ł Compras                                                    ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ł ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ł PROGRAMADOR  ł DATA   ł DESCRICAO                                     ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ł Marllon      ł20/08/03ł Os pedidos de transferencia entre as IMDEPAS  ł±±
±±ł              ł        ł nao serao liberado automaticamente na entrada ł±±
±±ł              ł        ł da nota. deve ser avaliado pelo gerente da    ł±±
±±ł              ł        ł casa que tomara a decisao de liberar ou nao.  ł±±
±±ł              ł        ł                                               ł±±
±±ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function SF1100i()
	Local aArea    := GetArea()
	Local aAreaSC5 := SC5->( GetArea() )
	Local aAreaSC6 := SC6->( GetArea() )
	Local aAreaSC7 := SC7->( GetArea() )
	Local aAreaSC9 := SC9->( GetArea() )
	Local aAreaSZE := SZE->( GetArea() )
	Local aAreaSB1 := SB1->( GetArea() )
	Local aAreaSB2 := SB2->( GetArea() )
	Local aAreaSF1 := SF1->( GetArea() )
	Local aAreaSD1 := SD1->( GetArea() )
	Local aAreaSUA := SUA->( GetArea() )
	Local aAreaSUB := SUB->( GetArea() )
	Local aAreaSU7 := SU7->( GetArea() )
	Local aAreaSA1 := SA1->( GetArea() )
	Local aAreaSF4 := SF4->( GetArea() )
//	Local aPVs     := Array(0)
	
	Local aItensTransf  :={}
	Local _E3_ORIGEM    :=' '
	
	Local aEmail   := Array(0)
	Local cChave
	Local nQtdEnt  := 0
	Local nDias    := 0
	Local cImdepa  := GetMV('MV_IMDEPA')
	Local cOperaWms:= GetMv("MV_WMSTPAP",,"F")
	
	Local cF1hora  := Left(Time(),5)
	
	// incluido por Luciano Correa em 05/05/04 para marcar nfs que 
	// nao atualizam estoque como liberadadas pela keppers...
	Local lLibKeep := .f.
	// incluido por Luciano Correa em 19/03/04 para gravar natureza em nccs...
	
	// Jorge Oliveira - 28/02/2011 - Indica se a Filial atual, trabalha com as Liberacao Comercial utilizando Carta de Negocios
	Local lCartLib   := IIF( Upper( SuperGetMV( "MV_CARTLIB",, "N" ) ) == "S", .T., .F. )
	//Local lOk        := .T.
	Local aAreaBkp   := {}
	Local aCarta     := {}
	Local aProdCarta := {}
	Local cVendB2B   := ""
	Local cUsu       := ""
	Local _lCorreia  := .F. // Jean Rehermann - SOLUTIO IT - 22/01/2016 - Flag se produto é correia
	
	Private Ind_SE1, Rec_SE1, cNaturez
	
	// somente se for devolucao, gerou nota de credito ao cliente e estah posicionado nela
	// Obs.: devera jah estar posicionado no sf1, sd1 e se1
	
	//Incluido por Luciano Barra (IMDEPA)
	//Grava Nota Fiscal de Origem de Devoluçăo de Vendas no Histórico da NCC
	Private cDevol    := ""
	Private aDevol    := {}
	Private nPosNFO   := 0
	Private nPosSNFO  := 0
	Private cChavePes := "" 
 
	// Jorge Oliveira - 28/02/2011 - Projeto Carta de Negocios - INICIO
	aAreaBkp := GetArea()
	
	DbSelectArea( "SUB" )
	DbSetOrder( 3 ) // UB_FILIAL + UB_NUMPV + UB_ITEMPV
	
	RestArea( aAreaBkp )
	// Jorge Oliveira - 28/02/2011 - Projeto Carta de Negocios - FINAL
	
	RecLock("SF1",.F.)
	SF1->F1_HORA := cF1hora
	MsUnLock()
	
	If !EMPTY(SF1->F1_HAWB) .AND. SF1->F1_EST <> "EX"
		U_GERTXICM() // Gera a taxa de icm da nota de transferencia do EIC
	Endif

	If ALLTRIM(POSICIONE("SA2",1,XFILIAL("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_NATUREZ")) $ GETMV("MV_NATREV")//Grava data e hora de entrada da mercadoria
		U__DHEntra()
	EndIf
	
	If SF1->F1_TIPO == 'D'
       
		U_DEVANAL()
    
	Endif
	
	If SF1->F1_TIPO == 'D' .and. SE1->E1_TIPO == 'NCC'
		nPosNFO   := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_NFORI" })
		nPosSNFO  := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_SERIORI" })
		For I := 1 To Len(aCols)
			cChavePes :=aCols[I,nPosNFO]+"/"+aCols[I,nPosSNFO]
			If aScan(aDevol,cChavePes) = 0
				Aadd(aDevol,cChavePes)
			EndIf
		Next I
		For D := 1 To Len(aDevol)
			cDevol += aDevol[D] + " "
		Next D
		RecLock("SE1",.F.)
		SE1->E1_HIST := "DEV REF NF "+cDevol
		MsUnLock()
	EndIf
	
	
	If SF1->F1_TIPO == 'D' .and. SE1->E1_TIPO == 'NCC' .and. ;
			( SF1->F1_DOC + SF1->F1_FORNECE + SF1->F1_LOJA ) == ;
			( SE1->E1_NUM + SE1->E1_CLIENTE + SE1->E1_LOJA )
		// na Imdepa estah configurado para o titulo nao ser gerado com o prefixo igual a serie ( considero errado )...
		//( SF1->F1_SERIE + SF1->F1_DOC + SF1->F1_FORNECE + SF1->F1_LOJA ) == ;
		//( SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_CLIENTE + SE1->E1_LOJA )
		
		// busca natureza do titulo de origem
		Ind_SE1 := SE1->( IndexOrd() )
		Rec_SE1 := SE1->( Recno() )
		
		SE1->( dbSetOrder( 1 ) )
		SE1->( dbSeek( xFilial( 'SE1' ) + SD1->D1_SERIORI + SD1->D1_NFORI, .f. ) )
		
		cNaturez := SE1->E1_NATUREZ
		
		If Empty( cNaturez )
			
			@ 000,000 to 086,224 Dialog oDlg1 Title 'NCC - Nota de Credito ao Cliente'
			
			@ 002,004 to 023,108
			@ 010,009 Say OemToAnsi( 'Natureza do Titulo' ) Size 060,10
			
			@ 009,058 Get cNaturez F3 'SED' Valid NaoVazio() .and. ExistCpo( 'SED' ) Picture PesqPict( 'SE1', 'E1_NATUREZ' ) Size 042,00
			
			@ 028,082 bmpButton Type 01 Action Close( oDlg1 )
			
			Activate Dialog oDlg1 Centered
		EndIf
		
		SE1->( dbSetOrder( Ind_SE1 ) )
		SE1->( dbGoTo( Rec_SE1 ) )
		
		// grava natureza
		SE1->( RecLock( 'SE1', .f. ) )
		SE1->E1_NATUREZ := cNaturez
		SE1->( MsUnlock() )
	EndIf
	
	SF4->( dbSetOrder( 1 ) )
	
	dbSelectArea('SD1')
	dbSetOrder( 1 )	// selecao do indice incluida por Luciano Correa em 16/06/04...
	cChvSD1 := SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
	dbSeek(xFilial('SD1')+cChvSD1)
	While ! Eof() .and. xFilial('SD1')+cChvSD1 == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
		
		// Jean Rehermann - SOLUTIO IT - 22/01/2016 - Verifica se produto é correia
		IIF(Select('SBP')==0, (ChkFile('SBP'),DbSelectArea("SBP")),)
		_lCorreia := !Empty( AllTrim( A093VldBase( SD1->D1_COD ) ) )
		dbSelectArea("SD1")
		
		// verifica se deve bloquear na liberacao keepers...
		SF4->( dbSeek( xFilial( 'SF4' ) + SD1->D1_TES, .f. ) )
	
		//Inserido por Edivaldo Gonçalves Cordeiro	
		// se possuir pelo menos um item que atualize estoque, grava o preço base de ICMS para impressăo do custo na Nota
		If SF4->F4_ESTOQUE == 'S'
		
			If  (nBaseRed:=SD1->D1_BRICMS/SD1->D1_QUANT) <> 0 .AND. (nIcmsRet:=SD1->D1_ICMSRET/SD1->D1_QUANT) <> 0
				MsAguarde({||ZA7->(U_AtuBaseRed(SD1->D1_FILIAL, SD1->D1_COD,nBaseRed,nIcmsRet))},"Base Reduzida de ICMS","Atualizando ...")
			Endif
		EndIf
	
		If SF1->F1_TIPO $ 'ND' .AND. SF4->F4_ESTOQUE == 'S'
			aAdd(aItensTransf,{SD1->D1_COD,SD1->D1_QUANT})  //Nota de Entrada, avisa vendedores da entrada dos produtos na filial
		Endif
		
	  ///////////////////////////////////////////////////////////////////////////////////////////////////
	  ///Verifica se tem correia para realizar o endereçamento Automático  
      ///////////////////////////////////////////////////////////////////////////////////////////////////

		ExecBlock('ChkPosBase',.F.,.F., {'ChkCorreias', SD1->D1_COD})
        cBase  		:= 	A093VldBase(SD1->D1_COD)
     	
		// quantidade entrada pela nota fiscal
		nQtdEnt := SD1->D1_QUANT
	
		dbSelectArea('SC7')
		dbSetOrder(1)
		If dbSeek(xFilial('SC7')+SD1->D1_PEDIDO+SD1->D1_ITEMPC)
	
			// testo se esta lincado a planilha
			If ! Empty(SC7->C7_PLANILH)
				// localiza o item da planilha
				dbSelectArea('SZE')
				dbSetOrder(3)
				If dbSeek(xFilial('SZE')+SC7->C7_PLANILH+SC7->C7_PLITEM)
					If SZE->ZE_DESTINO == cFilAnt
						RecLock('SZE',.F.)
						SZE->ZE_FLAGNF := 'S'
						msUnLock()
					EndIf
				EndIf
				
				// se o produto nao tem controle de localizacao, entao vou liberar os pedidos de venda
				// deste item
				SB1->( dbSeek(xFilial('SB1')+SC7->C7_PRODUTO) )
	        			
				//Inserido por Edivaldo Gonçalves Cordeiro em 08/08/2007
				//Garante a configuracao do controle de localizacao para filiais com WMS			
				If cOperaWms <> 'F' .AND. SB1->B1_LOCALIZ <> 'S'
	
					If( SB1->B1_TIPO='PA' .OR. SB1->B1_TIPO='PP' .OR. SB1->B1_TIPO='MP' )
	
						If RecLock("SB1",.F.)
							SB1->B1_LOCALIZ :='S'
							MsUnlock()
						Endif
					Endif
				Endif
	                       
				//Comentado por Edivaldo Endereçamento Automático If SB1->B1_LOCALIZ <> 'S'
				// localiza o item do pedido de vendas que esta lincado ao item da planilha
				dbSelectArea('SC6')
				dbOrderNickName('C6_PLAN')
				cChave := SC7->C7_PLANILH   // +SC7->C7_PLITEM+SC7->C7_PRODUTO
					
				If dbSeek(xFilial('SC6')+cChave)
					dbSelectArea('SC6')
					While !Eof() .and. SC6->C6_PLANILH == SC7->C7_PLANILH .And. xFilial('SC6') == SC6->C6_FILIAL
					
						// so libero se for o mesmo produto da entrada da nota
						If SC6->C6_PRODUTO <> SC7->C7_PRODUTO
							dbSkip()
							Loop
						EndIf
							
						If SC6->C6_CLI <> cImdepa .And. SC7->C7_PLITEM = SC6->C6_PLITEM
							
							// pedidos sendo processados
							//If ! (Ascan(aPVs, SC6->C6_NUM) > 0)
							//	Aadd(aPVs, SC6->C6_NUM)
							//EndIf
								
							// posiciona no cabecalho
							// localizo o registro do SUA para encontrar o opedador
							SUA->( DbSetOrder(8) )
							SUA->( DbSeek(xFilial('SUA')+SC6->C6_NUM) )
							SC5->( DbSeek(xFilial('SC5')+SC6->C6_NUM) )
							SA1->( DbSeek(xFilial('SA1')+SC6->C6_CLI+SC6->C6_LOJA) )
							
							dbSelectArea('SC9')
							dbSetOrder(1)
							If dbSeek(xFilial('SC9')+SC6->C6_NUM+SC6->C6_ITEM)
								// se tiver saldo a ser liberado
								// dbSelectArea('SC6')
								// esta linha nao necessita, pois como estou posicionado no SC9 a qtd
								// que tenho que liberar eh a mesma que ja existe no proprio SC9
								nQtdLib := SC9->C9_QTDLIB
										
								// libera saldo para o estoque
								If nQtdEnt >= nQtdLib .and. nQtdLib > 0 .and. Empty(SC9->C9_NFISCAL)
									// funcao Microsiga para estornar uma liberacao
									// estorna o registro posicionado do SC9
									A460Estorna(.T.)
											
									// Jean Rehermann - SOLUTIO IT - 22/01/2016 - Adaptaçăo ao projeto correias
									// Conforme conversa entre Marcos Franciosi (SOLUTIO) e Leonardo (IMDEPA)
									// năo existe a necessidade de reavaliaçăo de crédito neste momento.
									// Para atender a liberaçăo do estoque do pedido é feito o desbloqueio do mesmo.
									
									// No momento da liberacao do estoque quando for dado entrada na NF 
									// o Credito deverah ser avaliado novamente (Otoni)
									// inserido controle de transacao por Luciano Correa em 21/06/05...

									//lOk := .T.
									// Jorge Oliveira - 28/02/2011 - Projeto Carta de Negocios - INICIO
									// Se a Filial utiliza Carta de Negocios para liberar os pedidos
									
									// Carta de negócios năo é mais utilizado - 22/01/2016
									/*
									If lCartLib
										
										// Posiciona no item do atendimento do Call-Center
										SUB->( DbSeek( xFilial( "SC6" ) + SC6->C6_NUM + SC6->C6_ITEM ) )
										
										// Para cada item, limpa as variaveis para carregar novamente
										aCarta     := {}
										aProdCarta := {}

										AADD( aCarta, xFilial( "SUA" )	) //  1 - POS_FILIAL
										AADD( aCarta, SUA->UA_CLIENTE		) //  2 - POS_CLIENTE
										AADD( aCarta, SUA->UA_LOJA			) //  3 - POS_LOJA
										AADD( aCarta, SUA->UA_CONDPG		) //  4 - POS_CONDPG
										AADD( aCarta, SUB->UB_VLRITEM   ) //  5 - POS_PRECO_CARTA
										AADD( aCarta, SUB->UB_DESC2		) //  6 - POS_PER_DES_FILIAL
										AADD( aCarta, SUA->UA_TPFRETE		) //  7 - POS_FRETE
										AADD( aCarta, SC6->C6_COMIS1		) //  8 - POS_COM_CLIENTE
										AADD( aCarta, SC6->C6_IMC			) //  9 - POS_MARGEM_CARTA
										AADD( aCarta, SA1->A1_EST			) // 10 - POS_UF_CLIENTE
										AADD( aCarta, SA1->A1_COD_MUN		) // 11 - POS_MUN_CLIENTE
										AADD( aCarta, SA1->A1_REGIAO		) // 12 - POS_REGIAO_CLIENTE
										AADD( aCarta, SA1->A1_MESORG		) // 13 - POS_MESOREGIAO_CLIENTE
										AADD( aCarta, SA1->A1_MICRORE		) // 14 - POS_MICROREGIAO_CLIENTE
										AADD( aCarta, SA1->A1_CNAE			) // 15 - POS_CNAE_CLIENTE
										AADD( aCarta, SA1->A1_ATIVIDA    ) // 16 - POS_ATIVIDADE_CLIENTE
										AADD( aCarta, SA1->A1_GRPSEG     ) // 17 - POS_GRPSEGMENTO_CLIENTE
										AADD( aCarta, SA1->A1_SATIV1     ) // 18 - POS_SEGMENTO_CLIENTE
										AADD( aCarta, SUB->UB_DESC2      ) // 19 - POS_PERC_DESCONTO_CLIENTE

										cVendB2B := SUA->UA_OPERADO
										If SUA->UA_OPERADO == "055615"
											cVendB2B := SC6->( Posicione( "SU7", 1, xFilial( "SU7" ) + SUA->UA_OPERADO, "U7_CODVEN" ) )
										EndIf

										AADD( aCarta, SA1->A1_VINCIMD    ) // 20 - POS_VINCULO_CLIENTE
										AADD( aCarta, cVendB2B           ) // 21 - POS_VEND_B2B
										AADD( aCarta, 0                  ) // 22 - POS_PERC_DENCONTO_B2B
										AADD( aCarta, SA1->A1_VENDEXT    ) // 23 - POS_VEND_VI
										AADD( aCarta, SUB->UB_DESC2      ) // 24 - POS_DESCONTO_VI
										AADD( aCarta, SC6->C6_COMIS1     ) // 25 - POS_COMISSAO_VI
										AADD( aCarta, SA1->A1_VEND       ) // 26 - POS_VEND_VE
										AADD( aCarta, SUB->UB_DESC2      ) // 27 - POS_DESCONTO_VE
										AADD( aCarta, SC6->C6_COMIS2     ) // 28 - POS_COMISSAO_VE
										AADD( aCarta, SA1->A1_VENDCOO    ) // 29 - POS_VEND_GC
										AADD( aCarta, SUB->UB_DESC2      ) // 30 - POS_DESCONTO_GC
										AADD( aCarta, SC6->C6_COMIS3     ) // 31 - POS_COMISSAO_GC
										AADD( aCarta, SA1->A1_CHEFVEN    ) // 32 - POS_VEND_GE
										AADD( aCarta, SUB->UB_DESC2      ) // 33 - POS_DESCONTO_GE
										AADD( aCarta, SC6->C6_COMIS4     ) // 34 - POS_COMISSAO_GE
										AADD( aCarta, SA1->A1_GERVEN     ) // 35 - POS_VEND_DIR
										AADD( aCarta, SUB->UB_DESC2      ) // 36 - POS_DESCONTO_DIR
										AADD( aCarta, SC6->C6_COMIS5     ) // 37 - POS_COMISSAO_DIR
										cUsu := SC6->( Posicione( "SU7", 1, xFilial( "SU7" ) + SUA->UA_OPERADO, "U7_CODUSU" ) )
										AADD( aCarta, SC6->( Posicione( "SA3", 7, xFilial( "SA3" ) + cUsu, "A3_CARGO" ) ) ) // 38 - POS_CARGO

										AADD( aProdCarta, {	SUB->UB_PRODUTO,;		// 01 - POS_PRODUTO
										SB1->B1_DESC,;			// 02 - POS_DESC
										SB1->B1_CODITE,;		// 03 - POS_CODITE
										SUB->UB_QUANT,;		// 04 - POS_QUANT
										SB1->B1_MARCA,;		// 05 - POS_MARCA
										SB1->B1_GRUPO,;		// 06 - POS_GRUPO
										SB1->B1_GRMAR1,;		// 07 - POS_GRPMA1
										SB1->B1_GRMAR2,;		// 08 - POS_GRPMA2
										SB1->B1_GRMAR3,;		// 09 - POS_GRPMA3
										SB1->B1_SGRB1,;		// 10 - POS_SRGB1
										SB1->B1_SGRB2,;		// 11 - POS_SRGB2
										SB1->B1_SGRB3,;		// 12 - POS_SRGB3
										SUB->UB_DESC2,;		// 13 - POS_PERCENT_DESC
										SUB->UB_VRCACRE,;		// 14 - POS_PRECO
										SUB->UB_IMC,;			// 15 - POS_MARGEM
										SB1->B1_OBSTPES,;		// 16 - POS_OBS_TIPO_ESTOQUE
										.F.  } )					// 17 - POS_ITEM_OK

										//Chama a rotina para utilizar a Carta de Negocios para verificar se irah ou nao liberar o pedido !
										Processa( {|| lOk := U_A710Carta( aCarta, aProdCarta, NIL, .F. ) }, "Carta de Negócios", "Consultando Cartas de Negócios..." )

									EndIf
									*/
									// Jorge Oliveira - 28/02/2011 - Projeto Carta de Negocios - FINAL
									
									//If lOk
									/*
									MaLibDoFat(...) funcao Microsiga para liberacao do item posicionado do pedido SC6
									Parametros ExpN1: Registro do SC6
									           ExpN2: Quantidade a Liberar
									           ExpL3: Bloqueio de Credito
									           ExpL4: Bloqueio de Estoque
									           ExpL5: Avaliacao de Credito
									           ExpL6: Avaliacao de Estoque
									           ExpL7: Permite Liberacao Parcial
									           ExpL8: Tranfere Locais automaticamente
									           ExpA9: Empenhos ( Caso seja informado nao efetua a gravacao
									                  apenas avalia ).
									           ExpbA: CodBlock a ser avaliado na gravacao do SC9
									           ExpAB: Array com Empenhos previamente escolhidos
									                  (impede selecao dos empenhos pelas rotinas)
									           ExpLC: Indica se apenas esta trocando lotes do SC9
									           ExpND: Valor a ser adicionado ao limite de credito
									           ExpNE: Quantidade a Liberar - segunda UM
									*/
									dbSelectArea('SC6')
									
									Begin Transaction
									  //Endereça o Produto para Depois realizar a Liberaçăo de Estoque Automaticamente									
									    If !Empty(cBase)									    
		                                   MsAguarde( {|| U_IMDMT265(SD1->D1_FILIAL,SD1->D1_COD,SD1->D1_LOCAL,SD1->D1_NUMSEQ,SD1->D1_DOC,SD1->D1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA) },"Item de Correias","Endereçando Automaticamente...")
		                                Endif
									
										If _lCorreia
											MaLibDoFat(SC6->(RecNo()),nQtdLib,.T.,.F.,.F.,.T.,.F.,.F.)
										Else
											MaLibDoFat(SC6->(RecNo()),nQtdLib,.T.,.T.,.T.,.T.,.F.,.F.,,)
										EndIf
									End Transaction
									//EndIf
									
									nQtdEnt := nQtdEnt - nQtdLib
																												
								EndIf
							EndIf
									
							// gera array para envio de e-mail
							Aadd(aEmail, {SC6->C6_NUM,;
								SC6->C6_ITEM,;
								SC6->C6_PRODUTO,;
								SC6->C6_QTDVEN,;
								SUA->UA_OPERADO,;
								SC6->C6_PLANILH,;
								SC6->C6_PLITEM,;
								cChvSD1,;
								SB1->B1_DESC,;
								SC6->C6_CLI+'/'+SC6->C6_LOJA})
							 
						EndIf
						
						dbSelectArea('SC6')
						dbSkip()
					EndDo
					
				EndIf
				dbSetOrder(1)
			EndIf
		EndIf
		
		dbSelectArea('SD1')
		dbSkip()
	EndDo
	
	/* 
	// Jorge Oliveira - 04/02/2011 - Comentado porque năo tem finalidade !
	// Testa se todos os itens do pedido foram liberados em sua totalidade
	If Len(aPVs) > 0
	
		For nStart := 1 To Len(aPVs)
			lLiberOk := .T.
			SC5->( dbSeek(xFilial('SC5')+aPVs[nStart]) )
	
			dbSelectArea('SC6')
			dbSetOrder(1)
			SC6->( dbSeek(xFilial('SC6')+aPVs[nStart]) )
			While !Eof() .and. xFilial('SC6') = SC6->C6_FILIAL .and. aPVs[nStart] = SC6->C6_NUM
				If SC6->C6_QTDENT+SC6->C6_QTDEMP < SC6->C6_QTDVEN
					lLiberOk := .F.
					Exit
				EndIf
				dbSkip()
			EndDo
		Next
	EndIf				
	*/ 
	
	// envia e-mail para os operadores
	If Upper(GetMv('MV_ENVMAIL')) = 'SIM'
		EnvMailPlan( aEmail )
	EndIf
	
	If Len( aItensTransf ) > 0
		SF1->(U_SendNfTrf(SF1->F1_FILIAL,SF1->F1_FORNECE,SF1->F1_LOJA,aItensTransf,'SF1',F1_EST))
	EndIf
	
	//Se a venda for do gerente 000685 , verifica se e necessario criar os titulos na Devolucao
	If SF1->F1_TIPO='D' .AND. SA1->A1_GERVEN = '000685'
		U_IMDA660()
	Endif   
	/*
	 If Len(aEndereca)>0	
	       For i=1 to Len(aEndereca)
		     MsAguarde( {|| U_TMATA265(aEndereca[i,1],aEndereca[i,2],aEndereca[i,3]) },"Item de Correias","Endereçando Automaticamente...")
		   Next i
	 Endif
	*/
	 
	// restaura as areas
	RestArea(aAreaSA1)
	RestArea(aAreaSUA)
	RestArea(aAreaSUB)
	RestArea(aAreaSU7)
	RestArea(aAreaSB2)
	RestArea(aAreaSF1)
	RestArea(aAreaSD1)
	RestArea(aAreaSB1)
	RestArea(aAreaSZE)
	RestArea(aAreaSC7)
	RestArea(aAreaSC5)
	RestArea(aAreaSC6)
	RestArea(aAreaSF4)
	RestArea(aArea)

Return



	/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄż±±
	±±łPrograma  ł EnvMailPlan ł Autor ł Microsiga          ł Data ł 11/04/03 ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±łDescri??o ł Envia e-mail para o departamento de credito avisando que   ł±±
	±±ł          ł foi inserido um novo cliente.                              ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±łSintaxe   ł U_EnvMailPlan( aEmail )                                    ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±łParametrosł 1 = Numero do Pedido                       NIDPEDIDO       ł±±
	±±ł          ł 2 = Item do Pedido                         NIDITEM         ł±±
	±±ł          ł 3 = Produto                                NIDPRODUTO      ł±±
	±±ł          ł 4 = Quantidade Liberada                    NIDQUANT        ł±±
	±±ł          ł 5 = Operador                               NIDOPERADO      ł±±
	±±ł          ł 6 = Numero da Planilha                     NIDPLANILHA     ł±±
	±±ł          ł 7 = Item da Planilha                       NIDPLITEM       ł±±
	±±ł          ł 8 = Numero da Nota/Serie/Fornecedor/Loja   NIDNOTA         ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±łRetorno   ł NIL                                                        ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±łUso       ł Compras                                                    ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±ł ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±ł PROGRAMADOR  ł DATA   ł DESCRICAO                                     ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±ł              ł        ł                                               ł±±
	±±ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	/*/
Static Function EnvMailPlan( aEmail )

	Local cServer := GetMV("MV_RELSERV" ),;
		cAccount := Alltrim(GETMV("MV_RELACNT")),;
		cPassword := Alltrim(GETMV("MV_RELPSW")),;
		lAuth := Getmv("MV_RELAUTH"),;
		cAssunto := "Entrada de Nota de Transferencia",;
		cEmailTo := "",cEmailBcc:="",;
		lResult  := .F.,;
		cError := ""
	Local cArq
	Local ix
	Local cTexto, cTxtFile := Space(0)
	Local cMailCred     := AllTrim(GetMV('MV_MAILCRE'))
	Local aArea         := GetArea()
	Local aAreaSU7      := SU7->( GetArea() )
	Local aAreaSA3      := SA3->( GetArea() )

	Private NIDPEDIDO   := 1
	Private NIDITEM     := 2
	Private NIDPRODUTO  := 3
	Private NIDQUANT    := 4
	Private NIDOPERADO  := 5
	Private NIDPLANILHA := 6
	Private NIDPLITEM   := 7
	Private NIDNOTA     := 8
	Private NIDDESCRI   := 9
	Private NIDCLIENTE  := 10
	
	// testa se tem itens
	If Len(aEmail) > 0
		// indexa o array
		aEmail := aSort(aEmail,,, {|x,y| x[NIDOPERADO] < y[NIDOPERADO]})
		
		// gera o nome do arquivo para ir como anexo
		cArq := "\" + AllTrim( SubStr( aEmail[1,NIDNOTA], 1 ,6 ) )
		ix := 1
		While File(cArq)
			cArq := "\" + AllTrim( SubStr(aEmail[1,NIDNOTA],1,6) ) + "_" + Soma1(Str(ix,1))
			ix++
		EndDo
		cArq+=".txt"
		
		// corpo do e-mail
		cTexto := "Entrada de Nota referente a Transferencia entre filiais." + CRLF
		cTexto += "Favor observar o Anexo." + CRLF
		//cTexto += "Encaminhar este e-mail imediatamente para o departamento de credito: Gisele e Nelson." + CRLF
		cTexto += CRLF
		
		// email destino
		SU7->( dbSetOrder(1) )
		SA3->( dbSetOrder(1) )
		cMail := Space(0)
		cTxtFile += 'Nota fiscal Numero: ' + SubStr(aEmail[1,NIDNOTA],1,6)+' / '+SubStr(aEmail[1,NIDNOTA],7,3) + CRLF + CRLF
		cTxtFile += 'Pedido  Item  Produto   Descricao                                      Qtd Pedido  Planilha Item  Operador          Cliente' + CRLF + CRLF
		
		For nStart := 1 To Len(aEmail)
			SU7->( dbSeek(xFilial('SU7')+aEmail[nStart,NIDOPERADO]) )
			SA3->( dbSeek(xFilial('SA3')+SU7->U7_CODVEN) )
			//If cMail <> aEmail[nStart,NIDOPERADO]
			If ! (aEmail[nStart,NIDOPERADO] $ cMail)
				cEmailTo += AllTrim(SA3->A3_EMAIL)+';'
				//cMail := aEmail[nStart,NIDOPERADO]
				cMail += aEmail[nStart,NIDOPERADO]+'/'
			EndIf
			
			// monta o arquivo texto com as informacoes da entrada
			// Pedido  Item  Produto   Descricao                                      Quantidade  Planilha Item  Operador          Cliente
			// 999999   99   99999999  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA    999999     999999   99   AAAAAAAAAAAAAAA
			cTxtFile += aEmail[nStart,NIDPEDIDO]+Space(3)+;
				aEmail[nStart,NIDITEM]+Space(3)+;
				SubStr(aEmail[nStart,NIDPRODUTO],1,8)+Space(2)+;
				aEmail[nStart,NIDDESCRI]+Space(4)+;
				Str(aEmail[nStart,NIDQUANT],6)+Space(5)+;
				aEmail[nStart,NIDPLANILHA]+Space(3)+;
				aEmail[nStart,NIDPLITEM]+Space(3)+;
				SA3->A3_NREDUZ+Space(3)+;
				aEmail[nStart,NIDCLIENTE] + CRLF
		Next
		// remove o ponto e virgula do final da lista
		If Right( AllTrim( cEmailTo ), 1 ) == ";" .And. Len( cEmailTo ) > 1
			cEmailTo := SubStr(cEmailTo,1,Len(cEmailTo)-1)
		EndIf
		
		// grava  o arquivo para anexa-lo e envia o e-mail
		If MEMOWRIT(cArq, cTxtFile)
			// conectando-se com o servidor de e-mail
			CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult
			
			// fazendo autenticacao 
			If lResult .And. lAuth
				lResult := MailAuth(cAccount,cPassword)
				If !lResult
					lResult := QADGetMail() // Funcao que abre uma janela perguntando o usuario e senha para fazer autenticacao
				EndIf
				If !lResult
					//Erro na conexao com o SMTP Server
					GET MAIL ERROR cError
					MsgInfo(cError,OemToAnsi("Erro de Autenticacao"))
					RestArea( aAreaSA3 )
					RestArea( aAreaSU7 )
					RestArea( aArea    )
				Return Nil
				Endif
			Else
				If !lResult
					//Erro na conexao com o SMTP Server
					GET MAIL ERROR cError
					MsgInfo(cError,OemToAnsi("Erro de Conexao"))
					RestArea( aAreaSA3 )
					RestArea( aAreaSU7 )
					RestArea( aArea    )
				Return Nil
				Endif
			EndIf
			
			// enviando e-mail  
			If lResult
				If ! Empty(cMailCred) .And. Len( cMailCred ) > 5
					//cEmailTo := cEmailTo + ';' + cMailCred
					cEmailBcc  := cMailCred
				EndIf
	
				SEND MAIL FROM cAccount ;
					TO			cEmailTo ;
					BCC     	cEmailBcc ;
					SUBJECT 	cAssunto ;
					BODY    	cTexto ;
					ATTACHMENT  cArq ;
					RESULT lResult
	
				If !lResult
			  		//Erro no envio do email
					GET MAIL ERROR cError
			    	
					Help(" ",1,"ATENCAO",,cError,4,5)
				EndIf
				DISCONNECT SMTP SERVER
			EndIf
			
			// exclui o arquivo gerado
			fErase(cArq)
		EndIf
	EndIf

	RestArea( aAreaSA3 )
	RestArea( aAreaSU7 )
	RestArea( aArea    )

Return




	/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄż±±
	±±łPrograma  ł _DHEntra    ł Autor ł Microsiga          ł Data ł 11/04/03 ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±łDescri??o ł Solicita o preenchimento da data e hora do recebimento     ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±łSintaxe   ł U__DHEntra()                                               ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±łParametrosł NIL                                                        ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±łRetorno   ł NIL                                                        ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±łUso       ł Compras                                                    ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±ł ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±ł PROGRAMADOR  ł DATA   ł DESCRICAO                                     ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±ł              ł        ł                                               ł±±
	±±ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	/*/
User Function _DHEntra()

	Private _cDATAREC := SF1->F1_DTRECBM
	Private _cHORAREC := SF1->F1_HORAREC
	
	While Empty( _cDATAREC ) .Or. Empty( _cHORAREC )
	
		@ 080,000 to 240,420 Dialog oDlg Title "Data e Hora de Recebimento da Mercadoria"
	
		@ 15,010 SAY "Data"
		@ 15,050 GET _cDATAREC SIZE 60,10
		@ 30,010 SAY "Hora"
		@ 30,050 GET _cHORAREC SIZE 40,10 PICTURE "99:99" VALID _VALHORA()
		@ 65,130 BMPBUTTON TYPE 01 ACTION _GRAVADH()
		ACTIVATE DIALOG oDlg CENTER
	
		If Empty( SF1->F1_DTRECBM ) .Or. Empty( SF1->F1_HORAREC )
			AVISO("Data e Hora Obrigatórios!!!",Oemtoansi("O preecnhimento dos campos Data e Hora săo obrigatórios!!!"),{"OK"} )
		EndIf
	
	EndDo

Return

	/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄż±±
	±±łPrograma  ł GERTXICM    ł Autor ł Agostinho Lima     ł Data ł 12/09/13 ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±łDescri??o ł Gera a taxa de ICM da NF de Importacao do EIC                ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±łSintaxe   ł U_GERTXICM()                                               ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±łParametrosł NIL                                                        ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±łRetorno   ł NIL                                                        ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±łUso       ł Compras                                                    ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±ł ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±ł PROGRAMADOR  ł DATA   ł DESCRICAO                                     ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±ł              ł        ł                                               ł±±
	±±ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	/*/
User Function GERTXICM()

Local aArea  := GetArea()
Local aTitulo   := {}
Private lMsErroAuto := .F.

  
	IF !EMPTY(SF1->F1_VALICM)

		cSql := " SELECT MAX(E2_PARCELA) AS QTD FROM "
		cSql += RETSQLNAME("SE2")
		cSql += " WHERE E2_FILIAL = '"+xFilial("SE2")+"' AND D_E_L_E_T_ <> '*' "
		cSql += " AND E2_PREFIXO = 'EIC' AND E2_TIPO = 'TX' AND E2_NUM = '"+SF1->F1_DOC+"' "
		cSql += " AND E2_FORNECE = '"+SF1->F1_FORNECE+"' AND E2_LOJA = '"+SF1->F1_LOJA+"' "
		Iif(Select("XXX") # 0,XXX->(dbCloseArea()),.T.)
		TcQuery cSql New Alias "XXX"
		XXX->(dbSelectArea("XXX"))
		XXX->(dbGoTop())
		cxParc := Iif(ValType(XXX->QTD) <> "C", Str(XXX->QTD), XXX->QTD)
		cxParc := Iif(Empty(cxParc),"0",Soma1(cxParc))
		XXX->(dbCloseArea())
		   
		sDat := DtoS(SF1->F1_EMISSAO)
		cMes := Soma1(SubStr(sDat,5,2))
		If Val(cMes) > 12
           If SF1->F1_FILIAL = '06'
			   dNotaData := StoD(Soma1(SubStr(sDat,1,4))+"0110")
			 Else
			   dNotaData := StoD(Soma1(SubStr(sDat,1,4))+"0120")
			 Endif   
		Else
		   If SF1->F1_FILIAL = '06'
			   dNotaData := StoD(SubStr(sDat,1,4)+cMes+"10") 
			Else 
			   dNotaData := StoD(SubStr(sDat,1,4)+cMes+"20")
			Endif   
		EndIf
		   
		xDtVali := DataValida(dNotaData)

/*
		SE2->(RecLock("SE2",.T.))

		SE2->E2_NUM      := SF1->F1_DOC
		SE2->E2_PREFIXO := "EIC"
		SE2->E2_PARCELA := cxParc
		SE2->E2_TIPO    := "TX"
		SE2->E2_NATUREZ := "2080101"
		SE2->E2_FORNECE := SF1->F1_FORNECE
		SE2->E2_LOJA     := SF1->F1_LOJA
		SE2->E2_EMISSAO  := SF1->F1_EMISSAO
		SE2->E2_EMIS1    := SF1->F1_DTDIGIT
		SE2->E2_VENCTO   := xDtVali
		SE2->E2_VENCREA  := xDtVali
		SE2->E2_VENCORI  := xDtVali
		SE2->E2_VALOR    := SF1->F1_VALICM
		SE2->E2_SALDO    := SF1->F1_VALICM
		SE2->E2_MOEDA    := 1
		SE2->E2_VLCRUZ   := SF1->F1_VALICM
		SE2->E2_TXMOEDA  := 1
		SE2->E2_HIST     := "P: "+Alltrim(SF1->F1_HAWB)+" - I.C.M."
		SE2->E2_ORIGEM   := "MATA100"
		SE2->E2_LA       := " "
		SE2->E2_FILORIG := "07"
           
		SE2->(MsUnLock())

*/		
		aAdd(aTitulo,{"E2_NUM", SF1->F1_DOC ,NIL})
		aAdd(aTitulo,{"E2_PREFIXO", "EIC" ,NIL})
		aAdd(aTitulo,{"E2_PARCELA", cxParc ,NIL})
		aAdd(aTitulo,{"E2_TIPO", "TX" ,NIL})
		aAdd(aTitulo,{"E2_NATUREZ", "2080101" ,NIL})
		aAdd(aTitulo,{"E2_FORNECE", SF1->F1_FORNECE , NIL})
		aAdd(aTitulo,{"E2_LOJA", SF1->F1_LOJA , NIL})
		aAdd(aTitulo,{"E2_EMISSAO", SF1->F1_EMISSAO , NIL})
		aAdd(aTitulo,{"E2_EMIS1" , SF1->F1_DTDIGIT , NIL})
		aAdd(aTitulo,{"E2_VENCTO", xDtVali , NIL})
		aAdd(aTitulo,{"E2_VENCREA" , xDtVali , NIL})
		aAdd(aTitulo,{"E2_VENCORI" , xDtVali , NIL})
		aAdd(aTitulo,{"E2_VALOR" , SF1->F1_VALICM , NIL})
		aAdd(aTitulo,{"E2_SALDO" , SF1->F1_VALICM , NIL})
		aAdd(aTitulo,{"E2_MOEDA" , 1 , , NIL})
		aAdd(aTitulo,{"E2_VLCRUZ", SF1->F1_VALICM , NIL})
		aAdd(aTitulo,{"E2_TXMOEDA", 1 , NIL})
		aAdd(aTitulo,{"E2_HIST" , "P: "+Alltrim(SF1->F1_HAWB)+" - I.C.M." , NIL})
		aAdd(aTitulo,{"E2_ORIGEM", "MATA100" , NIL})
		aAdd(aTitulo,{"E2_LA", " " , NIL})
		aAdd(aTitulo,{"E2_FILORIG", "07", NIL})
		
		lMsErroAuto := .F.
			
		dbSelectArea("SE2")

		MSExecAuto({|a,b,c,d,e,f,g| FINA050(a,b,c,d,e,f,g)},aTitulo,3,,,,.T.,.T.)
//		MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aTitulo,, 3)  // 3 - Inclusao, 4 - Alteraçăo, 5 - Exclusăo
		
		If lMsErroAuto
			MsgInfo("Titulo referente a "+Alltrim(SF1->F1_HAWB)+" - I.C.M.S năo pode ser gerado. Verifique informaçőes","Năo gerado")
			MostraErro()
       Else 
          MsgInfo("Titulo referente a "+Alltrim(SF1->F1_HAWB)+" - I.C.M.S foi incluido com sucesso!","Gerado") 
       Endif		


	ENDIF

RestArea(aArea)        

Return()


	/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄż±±
	±±łPrograma  ł _GRAVADH    ł Autor ł Microsiga          ł Data ł 11/04/03 ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±łDescri??o ł Grava a data e hora do recebimento                         ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±łSintaxe   ł U__GRAVADH()                                               ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±łParametrosł NIL                                                        ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±łRetorno   ł NIL                                                        ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±łUso       ł Compras                                                    ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±ł ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±ł PROGRAMADOR  ł DATA   ł DESCRICAO                                     ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±ł              ł        ł                                               ł±±
	±±ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	/*/
Static Function _GRAVADH()

	Reclock("SF1",.F.)
	SF1->F1_DTRECBM := _cDATAREC
	SF1->F1_HORAREC := _cHORAREC
	MsUnLock()

	CLOSE( oDlg )
	
Return



	/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄż±±
	±±łPrograma  ł _VALHORA    ł Autor ł Microsiga          ł Data ł 11/04/03 ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±łDescri??o ł Validar e hora do recebimento                              ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±łSintaxe   ł U__VALHORA()                                               ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±łParametrosł NIL                                                        ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±łRetorno   ł NIL                                                        ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±łUso       ł Compras                                                    ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±ł ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±ł PROGRAMADOR  ł DATA   ł DESCRICAO                                     ł±±
	±±ĂÄÄÄÄÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±ł              ł        ł                                               ł±±
	±±ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	/*/
Static Function _VALHORA()

Local cHora := ""

Local cCorHor := STRZERO(VAL(LEFT(_cHORAREC,2)),2)
Local cCorMin := STRZERO(VAL(RIGHT(_cHORAREC,2)),2)

_cHORAREC := cCorHor + ":" + cCorMin  

cHora := VAL(StrTran(_cHORAREC,":","."))
	
	If cHora < 0.01 .OR. cHora > 24
	
		ALERT("Informe uma hora valida de 0,01 a 24!!!")
	Return(.F.)
	   
	Endif
     
Return(.T.)

