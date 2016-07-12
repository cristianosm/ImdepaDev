#INCLUDE "Protheus.ch"
#INCLUDE "Imdepa.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄż±±
±±łFun‡…o    ł U_MT440GR       łAutor  łExpedito M. Jr.  ł Data ł 13/01/04 ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±łDescri‡…o ł Ponto de entrada chamado apos a liberacao do pedido de vendał±±
±±ł          ł Ele desabilita a tecla F5 que estava configurada para  a    ł±±
±±ł          ł chamada da rotina especifica de consulta metas de venda     ł±±
±±ł          ł on-line por vendedor.                                       ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ł Uso      ł CALL CENTER						                           ł±±
±±ŔÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MT440GR()

	Local lReturn	  := .t.
	Local aAreaSC9	  := SC9->( Getarea() )
	// Jorge Oliveira - 28/02/2011 - Indica se a Filial atual, trabalha com as Liberacao Comercial utilizando Carta de Negocio
	Local lCartLib   := IIF( Upper( SuperGetMV( "MV_CARTLIB",, "N" ) ) == "S", .T., .F. )
	Local aAreaSC6   := SC6->( GetArea() )
	Local aAreaSA3   := SA3->( GetArea() )
	Local aAreaSUB   := SUB->( GetArea() )
	Local aAreaSB1   := SB1->( GetArea() )
	Local aCarta     := {}
	Local aProdCarta := {}
	Local cOpcA      := PARAMIXB[1]
	Local cCodVend   := ""
	
	SetKey( 116, Nil )
	
	// inserido por Luciano Corręa, existem pedidos liberados em duplicidade, como năo deve existir liberaçăo
	// parcial será feita uma consistęncia dos dados...
	SC9->( dbSetOrder( 1 ) )
	If SC9->( dbSeek( xFilial( 'SC9' ) + SC5->C5_NUM, .f. ) )
		
		If !IsBlind()
			
			MsgStop( 'Estorne as liberaçőes existentes deste pedido para poder liberá-lo novamente.', cCadastro )
		EndIf
		
		lReturn	:= .f.
	EndIf
	
	// Jorge Oliveira - 28/02/2011 - Indica se a Filial atual, trabalha com as Liberacao Comercial utilizando Carta de Negocio
	If lReturn .And. lCartLib .And. cOpcA == 1
	
		// leitura dos itens do atendimento ( SUB ) para carregar o array e chamo a rotina para validar a carta
		// se a rotina da carta retornar alguma carta, o pedido pode ser liberado, caso contrario, informa uma 
		// mensagem e nao libera o item.

		//DbSelectArea("SC6")
		//DbSetOrder(1) // C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
		//If SC6->( DbSeek( xFilial( "SC6" ) + SC5->C5_NUM, .F. ) )

		AADD( aCarta, xFilial( "SUA" )	) //  1 - POS_FILIAL
		AADD( aCarta, SC5->C5_CLIENTE		) //  2 - POS_CLIENTE
		AADD( aCarta, SC5->C5_LOJAENT		) //  3 - POS_LOJA
		AADD( aCarta, SC5->C5_CONDPAG		) //  4 - POS_CONDPG
		AADD( aCarta, 0						) //  5 - POS_PRECO_CARTA
		AADD( aCarta, 0						) //  6 - POS_PER_DES_FILIAL
		AADD( aCarta, SC5->C5_TPFRETE		) //  7 - POS_FRETE
		AADD( aCarta, 0						) //  8 - POS_COM_CLIENTE
		AADD( aCarta, 0						) //  9 - POS_MARGEM_CARTA
		AADD( aCarta, SA1->A1_EST			) // 10 - POS_UF_CLIENTE
		AADD( aCarta, SA1->A1_COD_MUN		) // 11 - POS_MUN_CLIENTE
		AADD( aCarta, SA1->A1_REGIAO		) // 12 - POS_REGIAO_CLIENTE
		AADD( aCarta, SA1->A1_MESORG		) // 13 - POS_MESOREGIAO_CLIENTE
		AADD( aCarta, SA1->A1_MICRORE		) // 14 - POS_MICROREGIAO_CLIENTE
		AADD( aCarta, SA1->A1_CNAE			) // 15 - POS_CNAE_CLIENTE
		AADD( aCarta, SA1->A1_ATIVIDA    ) // 16 - POS_ATIVIDADE_CLIENTE
		AADD( aCarta, SA1->A1_GRPSEG     ) // 17 - POS_GRPSEGMENTO_CLIENTE
		AADD( aCarta, SA1->A1_SATIV1     ) // 18 - POS_SEGMENTO_CLIENTE
		AADD( aCarta, 0                  ) // 19 - POS_PERC_DESCONTO_CLIENTE
		AADD( aCarta, SA1->A1_VINCULO    ) // 20 - POS_VINCULO_CLIENTE
		AADD( aCarta, ""					   ) // 21 - POS_VEND_B2B
		AADD( aCarta, 0                  ) // 22 - POS_PERC_DENCONTO_B2B
		AADD( aCarta, ""					   ) // 23 - POS_VEND_VI
		AADD( aCarta, 0                  ) // 24 - POS_DESCONTO_VI
		AADD( aCarta, 0                  ) // 25 - POS_COMISSAO_VI
		AADD( aCarta, ""					   ) // 26 - POS_VEND_VE
		AADD( aCarta, 0                  ) // 27 - POS_DESCONTO_VE
		AADD( aCarta, 0                  ) // 28 - POS_COMISSAO_VE
		AADD( aCarta, ""					   ) // 29 - POS_VEND_GC
		AADD( aCarta, 0                  ) // 30 - POS_DESCONTO_GC
		AADD( aCarta, 0                  ) // 31 - POS_COMISSAO_GC
		AADD( aCarta, ""					   ) // 32 - POS_VEND_GE
		AADD( aCarta, 0                  ) // 33 - POS_DESCONTO_GE
		AADD( aCarta, 0                  ) // 34 - POS_COMISSAO_GE
		AADD( aCarta, ""					   ) // 35 - POS_VEND_DIR
		AADD( aCarta, 0                  ) // 36 - POS_DESCONTO_DIR
		AADD( aCarta, 0                  ) // 37 - POS_COMISSAO_DIR
		AADD( aCarta, ""				      ) // 38 - POS_CARGO
	
		// Posiciona no Cadastro do Vendedor, pelo codigo do usuario atual
		DbSelectArea("SA3")
		DbSetOrder(7)
		If DbSeek(xFilial("SA3") + RetCodUsr( Upper( AllTrim( SubStr( cUsuario, 7, 15 ) ) ) ) )
			
			cCodVend := SA3->A3_COD
			
			// Verifica se o Vendedor atual eh um Gestor de Conta
			DbSelectArea("SX5")
			If DbSeek( xFilial('SX5') +'75'+ SA3->A3_GEREN )

				If ( SA3->A3_COD $ SX5->X5_DESCRI + SX5->X5_DESCSPA + SX5->X5_DESCENG )
					cCodVend := SA3->A3_GEREN
				EndIf
			EndIf
			
			// Tudo isso soh para buscar o cargo do Gerente ou do Vendedor
			DbSelectArea('SA3')
			DbSetOrder(1)
			DbSeek( xFilial('SA3') + cCodVend )
			aCarta[ POS_CARGO ] := SA3->A3_CARGO
			
		EndIf
		
		DbSelectArea("SB1")
		DbSetOrder(1) // B1_FILIAL + B1_COD

		DbSelectArea("SUB")
		DbSetOrder(1) // UB_FILIAL + UB_NUM
		
		SUB->( DbSeek( xFilial( "SUB" ) + SC5->C5_NUMSUA ) )
		While SUB->( !Eof() ) .And. SUB->UB_FILIAL + SUB->UB_NUM == xFilial("SUB") + SC5->C5_NUMSUA

			aCarta[ POS_PRECO_CARTA		] += SUB->UB_VLRITEM
			aCarta[ POS_PER_DES_FILIAL	] += SUB->UB_DESC2
			aCarta[ POS_MARGEM_CARTA	] += SUB->UB_IMC
			
			SB1->( DbSeek( xFilial( "SB1" ) + SUB->UB_PRODUTO ) )
	
			// Carrega os produtos, para depois comparar com os Produtos da Carta de Negocio
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

			SUB->( DbSkip() )
		EndDo

		If Len( aProdCarta ) > 0

			// Chama a rotina que irah informar se tem alguma Carta de Negocio que poderah liberar o Pedido
			Processa( {|| lReturn := SC5->( U_A710Carta( aCarta, aProdCarta, {}, .F. ) ) }, "Carta de Negócios", "Consultando Cartas de Negócios..." )
						 
			If !lReturn
				MsgStop( "Esse pedido năo pode ser liberado, pois năo tem uma Carta de Negócios "+;
							"com características que possam liberar esse pedido.", "Carta de Negócios" )
			EndIf
			
		EndIf

	EndIf
	
	Restarea( aAreaSB1 )
	Restarea( aAreaSUB )
	Restarea( aAreaSA3 )
	Restarea( aAreaSC6 )
	Restarea( aAreaSC9 )

Return( lReturn )
