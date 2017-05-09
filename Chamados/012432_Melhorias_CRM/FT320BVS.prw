#Include 'Totvs.ch'

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUN��O   : FT320BVS    | AUTOR : Cristiano Machado  | DATA : 15/12/2016   **
**---------------------------------------------------------------------------**
** DESCRI��O: Filtra bot�es que devem ser apresentados na workarea todos os  **
**          : bot�es passam por este filtro para validar sua apresentacao.   **
**---------------------------------------------------------------------------**
** USO      : Especifico para o cliente Imdepa Rolamentos                    **
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
User function FT320BVS() 
*******************************************************************************	
Local lReturn := .T.
Local cIcoBtn := PARAMIXB[1] //| Icone do Botao 
Local cNomBtn := PARAMIXB[2] //| Nome do Botao 

	If cIcoBtn == "BTCALEND" .And. cNomBtn == "Agenda"
		lReturn := .F.
	EndIf
	
Return(lReturn)        