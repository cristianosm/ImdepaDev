#INCLUDE "Ap5Mail.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMTA410T   บAutor  ณMarllon Figueiredo  บ Data ณ 27/02/2003  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada na inclusao do pedido de vendas           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico para o cliente IMDEPA                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUltimas Alteracoes                                                     บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAutor     ณ Data     ุ  Descricao                                      บฑฑ
ฑฑบEdivaldo  ณ06/12/06  ุ  Tratamento para produtos Gerenciado  pelo WMS  บฑฑ
ฑฑศออออออออออฯออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function MTA410T()


Local aArea      := GetArea()
Local aAreaSC5   := SC5->( GetArea() )
Local aAreaSC6   := SC6->( GetArea() )
Local aAreaSC9   := SC9->( GetArea() )
Local aAreaSB2   := SB2->( GetArea() )
Local aAreaSB1   := SB1->( GetArea() )
Local aAreaSZE   := SZE->( GetArea() )
Local aItems     := Array(0)
Local aBlq       := Array(0)
Local nSldDisp
Local cCodTrf    := GetMV('MV_IMDEPA')
Local cFilTran   := Space(0)
Local cProd      := Space(0)
Local cLocal     := Space(0)
Local nQtdVen    := 0
Local lRetWMS
Local cTpEstFis  :=' '
Local cServic    :=' '
Local cTpEstFis  :=' '
Local cEndPad    :=' '

Alert("Entrou MTA410T ")

dbSelectArea("DC8");dbOrderNickName('EST_LOCPAD')



If INCLUI .OR.  ALTERA

	For nStart := 1 To Len(aCols)


		cPed     := SC6->C6_NUM
		cProd    := GDFieldGet('C6_PRODUTO', nStart)
		cItem    := GDFieldGet('C6_ITEM', nStart)
		cCodTes  := GDFieldGet('C6_TES', nStart)
		cLocal   := GDFieldGet('C6_LOCAL', nStart)
	   	cLocal   := IIf(cLocal=='98','02',cLocal) //O armazem 98 equivale ao 02 nos cadastros do WMS (Sequencia de Abastecimento e Norma)

		SF4->( dbSeek(xFilial('SF4')+cCodTes))//Posiciona na Tes para ver se movimenta Estoque

		If !SC5->C5_TIPO $"C/I/P" .AND. SF4->F4_ESTOQUE='S' //Se movimentar Estoque verifico se trata Controle de Localiza็ใo

			MsAguarde({||lRetWMS:=SF4->(U_checkWMS(cProd)) },"WMS","Checando se o produto possui controle de localiza็ใo ...")
			If lRetWMS
				   If DC8->(dbSeek(xFilial('DC8')+'5'+cLocal,.F.))
				    cTpEstFis :=DC8->DC8_CODEST
					cEndPad   :=SBE->(Posicione("SBE",1,xFilial("SBE") +cLocal+'DOCA',"BE_LOCALIZ"))
					cServic   :=DC5->(Posicione("DC5",2,xFilial("DC5") +'002',"DC5_SERVIC"))
				   Endif

				If SC6->(dbSeek(xFilial("SC6")+cPed+cItem+cProd,.F.))

					lLock :=  RecLock("SC6",.F.)

				    //Inserido por Edivaldo Goncalves em 27/07/09
	                //Estorna a Impressใo do pedido em caso de altera็ao. chamado :AAZPRP
	                If ALTERA
	  	              SC6->C6_IMPEMB :=' '
	                Endif

					SC6->C6_SERVIC :=	cServic
					SC6->C6_TPESTR :=	cTpEstFis
					SC6->C6_ENDPAD :=	cEndPad

				   	If lLock
						MsUnlock()
					Endif

				Endif

			Endif
		Else //Caso o produto nใo possua Controle de Localiza็ใo,nใo poderแ autorizar a Gera็ใo do Servi็o de WMS
			If SC6->(dbSeek(xFilial("SC6")+cPed+cItem+cProd,.F.))
				If !Empty(SC6->C6_SERVIC)
					SC6->C6_SERVIC :=' '
					SC6->C6_TPESTR :=' '
					SC6->C6_ENDPAD :=' '
					SC6->C6_REGWMS :=' '
				Endif
			Endif

		Endif
	Next
EndIf


*---------------------------------------------------
//Fim da Inser;แo por Edivaldo Goncalves Cordeiro //
*---------------------------------------------------

If !INCLUI

	// incluํdo por Luciano Corr๊a em 03/03/06, em alguns casos nใo excluia o pedido liberado...
	U_DelPVL( SC5->C5_FILIAL, SC5->C5_NUM )
EndIf

// processa as reservas em planilha de transferencia
If  cCodTrf <> SC5->C5_CLIENTE .and. INCLUI
	ResPlan()
EndIf

// tratamento para os pedidos de transferencia entre filiais
If cCodTrf == SC5->C5_CLIENTE
	If INCLUI
		For nStart := 1 To Len(aCols)
			cFilTran := GDFieldGet('C6_FILTRAN', nStart)
			cProd    := GDFieldGet('C6_PRODUTO', nStart)
			cLocal   := GDFieldGet('C6_LOCAL', nStart)
			nQtdVen  := GDFieldGet('C6_QTDVEN', nStart)
			If ! Empty(cFilTran)
				// Vou verificar o saldo de transferencia
				dbSelectArea('SB2')
				If dbSeek(cFilTran+cProd+cLocal)
					RecLock('SB2', .F.)
					SB2->B2_QTRANS -= nQtdVen
					msUnLock()
				EndIf
			EndIf
		Next
	EndIf
EndIf

RestArea(aAreaSZE)
RestArea(aAreaSB1)
RestArea(aAreaSB2)
RestArea(aAreaSC9)
RestArea(aAreaSC5)
RestArea(aAreaSC6)
RestArea(aArea)

Return



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao para tratamento das reservas em planilha para os produtos inclu-บฑฑ
ฑฑบidos em pedidos de venda para clientes e onde o usuario seleciona uma  บฑฑ
ฑฑบplanilha de transferencia com saldo disponivel para uso pela filial    บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAutor     ณ Data     ุ  Descricao                                      บฑฑ
ฑฑศออออออออออฯออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ResPlan()
Local cCodTrf    := GetMV('MV_IMDEPA')
Local nStart, nPLin
Local cNumPlan
Local cPlItem
Local cProd
Local nQtdVen
Local lExced
Local nQtdExced


// processa para todos os pedidos de venda para clientes
// pedidos que nao sao para transferencia entre filiais
If cCodTrf <> SC5->C5_CLIENTE
	// inclusao de pedido de vendas
	If INCLUI
		// tratamento para pedido com reserva em planilha de transferencia
		For nStart := 1 To Len(aCols)
			cNumPlan := GDFieldGet('C6_PLANILH', nStart)
			cPlItem  := GDFieldGet('C6_PLITEM', nStart)
			cProd    := GDFieldGet('C6_PRODUTO', nStart)
			nQtdVen  := GDFieldGet('C6_QTDVEN', nStart)

			If ! Empty(cNumPlan)
				dbSelectArea('SZE')
				dbSetOrder(3)
				lExced := .F.
				If dbSeek(xFilial('SZE')+cNumPlan+cPlItem)    // cProd+xFilial('SC6'))
					RecLock('SZE',.F.)
					SZE->ZE_QTDRES += nQtdVen
					// indica se usou saldo excedente
					If SZE->ZE_QTDRES > SZE->ZE_QTDTRAN
						// quantidade a ser abatida do excedente
						nQtdExced := SZE->ZE_QTDRES - SZE->ZE_QTDTRAN
						// ajusta a quantidade a ser transfereida
						SZE->ZE_QTDTRAN := SZE->ZE_QTDRES

						cChvExced := SZE->ZE_NUMPLAN+SZE->ZE_PRODUTO+Dtos(SZE->ZE_DTENTRE)
						lExced    := .T.
					EndIf
					msUnLock()
				EndIf

				// ajusta o saldo do excedente
				If lExced
					If dbSeek(xFilial('SZE')+cNumPlan)
						Do While !Eof() .and. cNumPlan == SZE->ZE_NUMPLAN
							If cChvExced == SZE->ZE_NUMPLAN+SZE->ZE_PRODUTO+Dtos(SZE->ZE_DTENTRE)
								RecLock('SZE',.F.)
								SZE->ZE_EXCED -= nQtdExced
								msUnLock()
							EndIf
							dbSkip()
						EndDo
					EndIf
				EndIf
				dbSelectArea('SZE')
				dbSetOrder(1)
			EndIf
		Next
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ DelPVL   บ Autor ณ Luciano Corr๊a     บ Data ณ 03/03/2006  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica e deleta se necessแrio os itens liberados que nใo บฑฑ
ฑฑบ          ณ constam no pedido de venda.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico para o cliente IMDEPA                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DelPVL( cFilPed, cNumPed )

Local aArea		:= GetArea()
Local aAreaSC6	:= SC6->( Getarea() )
Local aAreaSC9	:= SC9->( Getarea() )
Local aAreaSB2	:= SB2->( Getarea() )

SC6->( dbSetOrder( 1 ) )
SB2->( dbSetOrder( 1 ) )

SC9->( dbSetOrder( 1 ) )
SC9->( dbSeek( cFilPed + cNumPed, .f. ) )

Alert("Entrou DelPVL ")

While SC9->( !Eof() ) .and. SC9->C9_FILIAL	== cFilPed .and. SC9->C9_PEDIDO	== cNumPed

	Alert("Entrou WHILE SC9 ")
	// se nใo possui nota fiscal e nใo encontrou o item correspondente no pedido de venda...
	If Empty( SC9->C9_NFISCAL ) .and. ;
		SC6->( !dbSeek( SC9->C9_FILIAL + SC9->C9_PEDIDO + SC9->C9_ITEM + SC9->C9_PRODUTO, .f. ) )

		SC9->( RecLock( 'SC9', .f. ) )
		SC9->( dbDelete() )
		SC9->( MsUnlock() )

		If SB2->( dbSeek( xFilial( 'SB2' ) + SC9->C9_PRODUTO + SC9->C9_LOCAL, .f. ) )

			SB2->( RecLock( 'SB2', .F. ) )

			If Empty( SC9->C9_BLEST ) .and. Empty( SC9->C9_BLCRED )
				Alert("Entrou +QPEDVEN E -RESERVA ")
				SB2->B2_QPEDVEN	+= SC9->C9_QTDLIB
				SB2->B2_RESERVA	-= SC9->C9_QTDLIB
			Else
			  Alert("Entrou -QPEDVEN ")
				SB2->B2_QPEDVEN	-= SC9->C9_QTDLIB
			EndIf

			SB2->( MsUnlock() )
		EndIf
	EndIf

	SC9->( dbSkip() )
End

Restarea( aAreaSB2 )
Restarea( aAreaSC9 )
Restarea( aAreaSC6 )
RestArea( aArea )

Return
