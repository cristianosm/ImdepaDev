#Include "Totvs.ch"

#Define INCLUI 		3
#Define ESTORNA 		6

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : NomeProg    | AUTOR : Cristiano Machado  | DATA : 22/06/2015   **
**---------------------------------------------------------------------------**
** DESCRIÇÃO:                                                                **
**---------------------------------------------------------------------------**
** USO      : Especifico para o cliente  XXXXXX                              **
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
User Function MA261IN( )
*******************************************************************************
	Private nTamFile := 5

	aCols := {}

	GetFile() //| Carrega Arquivo csv com Itens |

	GetAcols() //| Alimenta Acols com Arquivo... |

	Teste 				:=  0
//	lContinua 		:= .T.
//	lAutoma261 	:= .T.

Return()
*******************************************************************************
Static Function GetFile() //| Carrega Arquivo csv com Itens |
*******************************************************************************

Return()
*******************************************************************************
Static Function GetAcols() //| Alimenta Acols com Arquivo... |
*******************************************************************************

	Local cCodOri 	:= "00017587" 			//| Produto Origem 		|
	Local cCodDes 	:= "00017587" 			//| Produto Destino 	|

	Local cLocalO	:= "01" 						//| Estoque Origem 		|
	Local cLocalD	:= "02" 						//| Estoque Destino 	|

	Local cEnderO	:= "PA00310" 			//| Endereco Origem 	|
	Local cEnderD	:= "PA00310" 			//| Endereco Destino 	|

	Local nQtd			:= 1								//| Quantidade a ser Transferida |

	Local cDb			:= cToD("  /  /  ")	//| Data Vazia...		|
	Local nVz			:= 0								//| Valor Zerado... 	|
	Local cVb			:= " " 						//| Caracter Vazio.. 	|


	For n := 1 To nTamFile

		Aadd( aCols , Array( Len( aHeader ) + 1 ) )

		aCols[n][01] := cCodOri
		aCols[n][02] := Posicione("SB1", 1, xFilial("SB1") + cCodOri, "B1_DESC")
		aCols[n][03] := Posicione("SB1", 1, xFilial("SB1") + cCodOri, "B1_UM")
		aCols[n][04] := cLocalO
		aCols[n][05] := cEnderO

		aCols[n][06] := cCodDes
		aCols[n][07] := Posicione("SB1", 1, xFilial("SB1") + cCodDes, "B1_DESC")
		aCols[n][08] := Posicione("SB1", 1, xFilial("SB1") + cCodDes, "B1_UM")
		aCols[n][09] := cLocalD
		aCols[n][10] := cEnderD

		aCols[n][11] := cVb
		aCols[n][12] := cVb
		aCols[n][13] := cVb
		aCols[n][14] := cDb
		aCols[n][15] := nVz
		aCols[n][16] := nQtd
		aCols[n][17] := nVz
		aCols[n][18] := cVb
		aCols[n][19] := cVb
		aCols[n][20] := cVb
		aCols[n][21] := cDb
		aCols[n][22] := cVb
		aCols[n][23] := cVb

		aCols[n][24] := "SD3"
		aCols[n][25] := nVz
		aCols[n][26] := .F.

	Next

Return()