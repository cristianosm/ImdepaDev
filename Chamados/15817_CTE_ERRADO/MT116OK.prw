#include 'protheus.ch'
#include 'parmtype.ch'

#Define PCHAVENFE 13 // posicao no array dados danfe

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : MT103INC.prw | AUTOR : Cristiano Machado | DATA : 10/04/2017**
**---------------------------------------------------------------------------**
** DESCRIÇÃO:  **
**---------------------------------------------------------------------------**
** USO : Especifico para   **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
** ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. **
**---------------------------------------------------------------------------**
** PROGRAMADOR | DATA | MOTIVO DA ALTERACAO **
**---------------------------------------------------------------------------**
**   |  | **
**   |  | **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User function MT116OK()
*******************************************************************************
Local lValida 		:= .T. 
Local l116Inclui 	:= !(PARAMIXB[1]) //| PARAMIXB => l116Exclui

If l116Inclui
	IF !ValChavNfe()
		lValida := .F. 
	EndIf
EndIf

Return(lValida)

//| Chamado: 15817 - CTE SC    Analista: Cristiano Machado Data: 10/04/17 
//| Valida Caso tenha Sido Digitado uma Chave para a NF-e com o Numero Utilizado.
*******************************************************************************
Static Function ValChavNfe()
*******************************************************************************
Local lValida := .T. 
Local cChvNfe := aNfeDanfe[PCHAVENFE] // Array com Dados na Danfe Guia/Informações. posicao 13 eh a chave da nfe

	If !Empty(cChvNfe)
		
		If At(cNFiscal,cChvNfe) == 0
			Iw_MsgBox("O Número do Conhecimento:[ "+cNFiscal+" ] não corresponde ao contido na CHAVE NFE informada na Guia/Informações DANFE. O Conhecimento não sera Lançado !!!","Por Favor Corrigir...","STOP")
			lValida := .F.
		EndIf
	
		If Substr(cChvNfe,21,2) == "57" //| 57 => Conhecimento, neste caso deve usar CTE
			If cEspecie <> "CTE"
			 	Iw_MsgBox("A CHAVE da NFE informada na Guia/Informações DANFE, indica que se trata de um Conhecimento de Frete. Neste caso utilize a ESPÉCIE [ CTE ]. O Conhecimento não sera Lançado !!! ","Por Favor Corrigir...","STOP")
				lValida := .F.
			EndIf
		EndIf
		
	EndIf
	
Return(lValida)