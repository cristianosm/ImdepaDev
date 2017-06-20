#include 'protheus.ch'
#include 'parmtype.ch'

// Documentacao Totvs
// http://tdn.totvs.com/pages/releaseview.action;jsessionid=0C5768277A1177EF28B0B6F16CCA50EB?pageId=6787821

// E1_SITUACA == "0"	// Carteira
// E1_SITUACA == "1"	// Simples
// E1_SITUACA == "2"	// Descontada
// E1_SITUACA == "4"	// Vinculada
// E1_SITUACA == "5"	// c/Advogado
// E1_SITUACA == "6"	// Judicial
// E1_SITUACA == "7"	// Caucionada Descontada
// E1_SITUACA == "H"    // Serasa (Customizado)

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : TK180GRV.prw | AUTOR : Cristiano Machado | DATA : 16/06/2017   **
**---------------------------------------------------------------------------**
** DESCRIÇÃO: Ponto de Entrada executado após a gravação do título na tabela **
**            de referência do Contas a Receber (SK1), considerando como     **
**            parâmetro o código do cliente e a loja em que foi gravado.     **
**            Esse Ponto possibilita customizações no momento da gravação de **
**            cada título.                                                   **
**---------------------------------------------------------------------------**
** USO : Especifico para Imdepa Tele-Cobranca                                **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
** ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                         **
**---------------------------------------------------------------------------**
** PROGRAMADOR | DATA | MOTIVO DA ALTERACAO                                  **
**---------------------------------------------------------------------------**
**             |      |                                                      **
**             |      |                                                      **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User function TK180GRV()
*******************************************************************************

Local _cCliente := ParamIxb[1]
Local _cLoja    := ParamIxb[2]

	// Tratamento Situacao H...
	If K1_SITUACAO == 'H'
		K1_SITUACA := '7'
		
	EndIf
	
Return