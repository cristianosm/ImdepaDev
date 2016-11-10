#include 'protheus.ch'
#include 'parmtype.ch'

#include 'protheus.ch'
#include 'parmtype.ch'

// Propriedades de alinhamento do TWindowDock
#Define ALLALIGN  	1
#Define LeftAlign 2
#Define RightAlign 3
#Define TopAlign 4
#Define BottomAlign 5
// Posicao dos campos no aHeader Solicitacao de compras Padrao
//#Define P_ITEM 		aScan(aHeader, {|x| AllTrim(x[2])=='C1_ITEM'})


/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNCAO   : Sc_Qtd_Data| AUTOR : Cristiano Machado  | DATA : 14/12/2015    **
**---------------------------------------------------------------------------**
** DESCRICAO: Este Programa tem o Objetivo de abrir uma Tela Atraves da Tecla**
**          : de atalho F4. Quando Posicionado em modo Edicao no Campo       **
**          : C1_QUANT na Solicitacao de Compras. Para Facilicar a           **
**          : distribuicao de um determidado produto                         **
**---------------------------------------------------------------------------**
** USO      : Especifico para o cliente Unimed-VS                            **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
**            ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.              **
**---------------------------------------------------------------------------**
**   PROGRAMADOR   |   DATA   |            MOTIVO DA ALTERACAO               **
**---------------------------------------------------------------------------**
**                 |          |                                              **
**                 |          |                                              **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User function IListProd()
*******************************************************************************

Local nRow		:= 0
Local nCol		:= 0
Local nWidth	:= 300
Local nHeight	:= 100
Local cText		:= "Lista de Produtos" 
Local lFloat    := .T.
Local nPosition	:= ALLALIGN
Local lClosable := .F.
Local lMovable  := .T.
Local lFoatable := .T.
Local cIniCpos  := "+ITEM" 
// Objetos
Local oDlgIli
Local oMainDock
Local oWindowDock

Local aAltCpo 	:= {"PRODUTO","QUANT" } 	//Variavel contendo o campo editavel no Grid
Local aBotoes	:= {}         					//Variavel onde sera incluido o botao para a legenda

Local  aHeaderL := {}        				 	//Variavel que montara o aHeader do Grid
Local  aColsL 	:= {}        					//Variavel que recebera os dados do Acols

Local bChanged := NIL //{||oBrowseN:aCols[oBrowseN:nAt][1] := StrZero(oBrowseN:nAt,2)}

Private  oBrowseL := Nil     					//Declarando o objeto do browser Lista


DEFINE MSDIALOG oDlgIli TITLE "Inserir Produtos em Lista" FROM 000, 000  TO 250, 250  PIXEL
	
	
	//| Funcao que cria a estrutura do aHeader e Acols
	IniCabec(@aHeaderL)
	IniaColsL(@aColsL, aHeaderL)
	
	// 
	oWindowDock := TWindowDock():New(nRow,nCol,nWidth,nHeight+20, cText, oDlgIli, lFloat, nPosition, lClosable, lMovable, lFoatable ) 

	//Monta o browser com inclusao, remocao e atualizacao
	oBrowseN := MsNewGetDados():New(nRow,nCol,nHeight,nWidth,(GD_INSERT+GD_DELETE+GD_UPDATE),'AllwaysTrue()','AllwaysTrue()',cIniCpos, aAltCpo ,000,999,'AllwaysTrue()','','AllwaysTrue()',oWindowDock,aHeaderL,aColsL,bChanged )

	//Alinho o grid para ocupar todo o meu formulario
	oBrowseN:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	// Ao abrir a janela o cursor esta posicionado no meu objeto
	oBrowseN:oBrowse:SetFocus()

	//EnchoiceBar(oWindowDock,{||MontaLins(),oWindowDock:End()},{||oWindowDock:End()},Nil,aBotoes,Nil,Nil,.F.,.F.,.F.,.T.,.F.,Nil)

ACTIVATE MSDIALOG oDlgIli CENTERED
	
Return()
*******************************************************************************
Static Function IniCabec(aHeaderL) //| Funcao que cria a estrutura do aHeader
*******************************************************************************

	Aadd( aHeaderL, X3CpoHeader("UB_ITEM"))
	Aadd( aHeaderL, X3CpoHeader("UB_PRODUTO"))
	Aadd( aHeaderL, X3CpoHeader("UB_QUANT"))

Return()
*******************************************************************************
Static Function IniaColsL(aColsL, aHeaderL) //| Funcao que cria a estrutura Acols e o Inicializa
*******************************************************************************
	Local nCpo 	 := 1
	Local nTHead := Len(aHeaderL)

	aColsL := { Array(nTHead + 1) }
    
	aColsL[1][nCpo] 			:=  "01"   		; nCpo += 1	//CriaVar(aHeaderL[nCpo,2]) ; nCpo += 1
	aColsL[1][nCpo] 			:=  Space(15)	; nCpo += 1 //CriaVar(aHeaderL[nCpo,2]) ; nCpo += 1
	aColsL[1][nCpo] 			:=  0			; nCpo += 1 //CriaVar(aHeaderL[nCpo,2]) ; nCpo += 1
	aColsL[1][nTHead + 1] 	:= .F.

Return()
*******************************************************************************
Static Function X3CpoHeader(cCampo)// Obtem estrutura do Header baseado no campo informado.
*******************************************************************************
	Local aAreaAnt := GetArea()
	Local aAreaSx3 := SX3->( GetArea() )
	Local aAuxiliar := {}
	Local cValidacao := ""
	DbSelectArea("SX3");DbSetOrder(2)

	If DbSeek(cCampo,.F.)
		If Alltrim(cCampo) == "UB_PRODUTO"
			cValidacao :=  "ExistCpo('SB1', M->PRODUTO, 1)"
		Else
			cValidacao := "AllwaysTrue()"
		EndIf
		aAuxiliar := { Trim(x3_titulo), SUBSTR(x3_campo,4) , x3_picture, x3_tamanho, x3_decimal, cValidacao, " " /*x3_usado*/, x3_tipo, x3_f3, " " /*x3_context*/ }
	EndIf

	RestArea(aAreaSx3)
	RestArea(aAreaAnt)

Return(aAuxiliar)

*******************************************************************************
Static Function MontaLins()//| Monta Linhas para serem incluidas na Solicitacao
*******************************************************************************


	
Return()