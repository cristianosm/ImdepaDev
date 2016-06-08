#Include "Rwmake.ch"

#DEFINE  ENTER CHR(13)+CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PE_TK271BOKºAutor  ³Edivaldo            º Data ³  30/08/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada executado na confirmação do Orçamento      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Validacao do Atendimento(TMKA271)                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*****************************************************************************
User Function TK271BOK()
*****************************************************************************

	Local lReturn       :=.T.
	Private cLibPedMin  := Posicione( "SA1" , 1 , xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA , "A1_CLFAMIN" )


     //Valida a tranportadora e o tipo de Frete - (Carro fixo nao pode ser usado no Frete Fob)
	If !U_IMDA890(M->UA_TRANSP)
		Return(.F.)
	Endif

	If cLibPedMin=="N" .AND. M->UA_TPFRETE=="C"
		IW_MSGBOX("Este cliente não tem permissão para operar com frete CIF" ,'Fretes !',"ALERT")
		Return(.F.)
	Endif

    //Valida a Tabexa de Faixas p/ frete CIF Destacado
	If M->UA_TPFRETE=="C" .AND. aValores[4]>0
		Vld_TabCarrFix()
	Endif

Return(lReturn)
*****************************************************************************
Static Function Vld_TabCarrFix()
*****************************************************************************

	Local nValPedMi   := GetMV("IM_PEDMINF")// Pedido Minimo Faturamento...
	Local lReturn     :=.T.
	Local nValorTotal := aValores[8]

      /*
        Valor total do Frete Destacado =  aValores[4]
      */

	dbSelectArea('ZAX')
	dbSetOrder(1)
	Do While !ZAX->(Eof())

		/*
		  Validacao da Faixa abaixo dos 500,00 (Faturamento Minimo)
		  Cliente nao autorizado faturamento minimo -> Acrescento a Taxa da Faixa no valor do Frete
	 	*/

		If nValPedMi==ZAX->ZAX_FAIXA2 .AND. cLibPedMin == "N"
			//aValores[4]+=ZAX->ZAX_TAXA
			//Aviso('Fretes ','Foi acrescentado ao valor do frete uma taxa de :  '+Str(ZAX->ZAX_TAXA)+ENTER +'Referente a faixa : '+ZAX->ZAX_DESC,{'OK'})

			aValores[4] := ZAX->ZAX_TAXA
			Aviso('Fretes ','Foi Substituido o valor do frete pela taxa de :  '+cValToChar(ZAX->ZAX_TAXA)+ENTER +'Referente a faixa : '+ZAX->ZAX_DESC,{'OK'})
			Exit
			Return(.T.)
		Endif


		Do Case
		Case nValorTotal >=ZAX->ZAX_FAIXA1 .AND. nValorTotal <=ZAX->ZAX_FAIXA2
			//aValores[4]+=ZAX->ZAX_TAXA
			//Aviso('Fretes ','Foi acrescentado ao valor do frete uma taxa de :  '+Str(ZAX->ZAX_TAXA)+ ENTER + 'Referente a faixa : '+ZAX->ZAX_DESC ,{'OK'})

			aValores[4] := ZAX->ZAX_TAXA
			Aviso('Fretes ','Foi Substituido o valor do frete pela taxa de :  '+cValToChar(ZAX->ZAX_TAXA)+ ENTER + 'Referente a faixa : '+ZAX->ZAX_DESC ,{'OK'})

			Exit
		Return(.T.)
		End Case

		ZAX->(dbSkip())
	EndDo


Return(lReturn)