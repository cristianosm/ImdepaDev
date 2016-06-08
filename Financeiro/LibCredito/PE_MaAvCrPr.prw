#Include "Protheus.ch"

#Define BLQ99 "99" //| Bloqueio Vendor
#Define BLQ98 "98" //| Bloqueio Parametro
#Define BLQ97 "97" //| Bloqueio Valor MINIMO
#Define BLQ96 "96" //| Bloqueia Risco Z Cliente Recuperacao

/*________________________________________________________________________________________
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||--------------------------------------------------------------------------------------||
|| Função: MaAvCrPr     || Autor: Edivaldo Gonçalves    || Data: 16/07/07               ||
||--------------------------------------------------------------------------------------||
|| Descrição: PE na avaliacao de credito do cliente, valida a liberacao                 ||
||--------------------------------------------------------------------------------------||
|| ParamIxb[1]=Código do cliente                                                        ||
|| ParamIxb[2]=Código da filial                                                         ||
|| ParamIxb[3]=Valor da venda                                                           ||
|| ParamIxb[4]=Moeda da venda                                                           ||
|| ParamIxb[5]=Considera acumulados de Pedido de Venda do SA1                           ||
|| ParamIxb[6]=Tipo de crédito (“L” - Código cliente + Filial; “C” - código do cliente) ||
|| ParamIxb[7]=Indica se o credito será liberado ( Lógico )                             ||
|| ParamIxb[8]=Indica o código de bloqueio do credito ( Caracter )                      ||
||                                                                                      ||
|| Retorno                                                                              ||
||                                                                                      ||
||  lRet(logico)                                                                        ||
||  .T. - crédito aprovado                                                              ||
||  .F. - crédito não aprovado.                                                         ||
||                                                                                      ||
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

********************************************************************
User Function MaAvCrPr( cCodCli , cLoja , nValor , nMoeda , lPedido , cTipoLim , lRetorno , cCodigo )
********************************************************************

If Type("aBLK_IMD") = "U" //| Variavel Global Utilizada Para Codigo de Bloqueio de Credito Cuztomizado no SC9
	Public aBLK_IMD := {} //| Sempre Salvar { Filial + Pedido + Item + CodBloqueio}
EndIF

Default cCodCli		:= paramixb[1]	//| Codigo Cliente
Default cLoja		:= paramixb[2] 	//| Loja Cliente
Default nValor		:= paramixb[3] 	//| Valor do Item
Default nMoeda		:= paramixb[4] 	//| Moeda
Default lPedido		:= paramixb[5] 	//| Considera acumulados de Pedido de Venda do SA1
Default cTipoLim	:= paramixb[6] 	//| Tipo de Liberacao.. por Codigo Cliente + Loja ou Codigo Cliente
Default lRetorno	:= paramixb[7] 	//| Status do Bloqueio da Rotina Padrao
Default cCodigo		:= paramixb[8] 	//| Codigo de Bloqueio

IF SC5->C5_LIBREPR = "S"  // Libera quando o pedido estiver macado para reprocesso  - Marca Pedido
    lRetorno 	:= .T.
    RETURN(lRetorno)
ENDIF

If lRetorno // Se ja estiver bloqueado por Motivos Padroes do Sistema nao ha necessidade de Bloqueio....

	aArea	:= GetArea()

	Ver_Vendor	(@lRetorno 	, @cCodigo) 	//| Verifica Vendor e Parametro de Cond. Pagamento

	Ver_Valor	(@lRetorno	, @cCodigo)  	//| Verifica Valor Minimo


	IF SC5->C5_FILIAL  = "11" .AND. LEFT(POSICIONE("SA1",1,XFILIAL("SA1")+cCodCli+cLoja,"SA1->A1_CGC"),8) <> ALLTRIM(GETMV("MV_CLIVALE"))  // Bloqueia os pedidos da filial 11 de clientes diferentes da VALE
		lRetorno 	:= .F.                                                                                                                                                                                                   // Chamado  AAZVJ9 da Daniele - Agostinho 21/02/2013
	ENDIF

	RestArea( aArea )

Else // Cliente Risco Z ja vem Bloqueado mas deve ser alterado o Codigo de Bloqueio para identificacao...

	Ver_Recuperacao(@lRetorno	, @cCodigo, cCodCli ,cLoja)

EndIf


// Limpa a Variavel Global .... Que eh Alimentada em MtValAvc.Prw Antes da Avaliaçao do Crédito... Ela é usada para Filtrar as NDC's..
If AT("NDC",MVPROVIS) > 0 // Encontrou
	MVPROVIS := Substr(MVPROVIS,1,3) // + "/NDC"   //| Tratamento para Desconsiderar NDC Durante avaliacao de Credito.... 20/12/12
EndIf

Return(lRetorno)
********************************************************************
Static Function Ver_Vendor(lRetorno,cCodigo) //| Verifica Vendor e Parametro de Cond. Pagamento
********************************************************************
Local aCondBloqCred := GETMV("MV_BLCREDI")
Local aParc         := {}
Local aAreaSE4		:= SE4->(GetArea())

If !lRetorno
	Return()
EndIf

If SE4->( DbSeek( xFilial( 'SE4' ) + SC5->C5_CONDPAG, .F. ) )

	If SE4->E4_VENDORR == '1' //| Pedido com Cond. de Pagto Vendor deve Bloquear no credito ....
		lRetorno 	:= .F.

		aAdd( aBLK_IMD , SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM+BLQ99 )

	ElseIf SC5->C5_CONDPAG $  aCondBloqCred //| Condicoes que devem ser Bloqueadas...
		lRetorno 	:= .F.

		aAdd( aBLK_IMD , SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM+BLQ98 )
	Endif

EndIf

RestArea(aAreaSE4)

Return (lRetorno)
********************************************************************
Static Function Ver_Valor(lRetorno,cCodigo) //| Verifica Valor Minimo
********************************************************************

If !lRetorno
	Return()
EndIf

aParc := Condicao( SUA->UA_FINANC , SC5->C5_CONDPAG , , dDataBase ) //| UA_FINANC -> TEM IMPOSTOS E ACRESCIMO CONDICAO

For n := 1 To Len(aParc)

	If (aParc[n][2] < GETMV("MV_VRPEDMI") ) //| Boqueia o Pv se a Parcela estiver abaixo do valor do parametro.
		lRetorno := .F.
	EndIf

Next

If !lRetorno
	aAdd( aBLK_IMD , SC6->C6_FILIAL + SC6->C6_NUM + SC6->C6_ITEM+BLQ97 )
EndIf

Return ( )
********************************************************************
Static Function Ver_Recuperacao(lRetorno , cCodigo , cCodCli ,cLoja)
********************************************************************

	If Posicione("SA1",1,XFILIAL("SA1")+cCodCli+cLoja,"SA1->A1_RISCO") == 'Z'

		lRetorno 	:= .F.

		aAdd( aBLK_IMD , SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM+BLQ96 )

	EndIf

Return()
