*/Program U_MDIOK.PRG/*/
#INCLUDE "PROTHEUS.CH"


/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : MdiOk	       | AUTOR : Cristiano Machado  | DATA : 03/12/2015   **
**---------------------------------------------------------------------------**
** DESCRIÇÃO: Validar o Acesso ao Interface MDI                              **
**---------------------------------------------------------------------------**
** USO      : Especifico para o cliente IMDEPA                               **
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
User Function MdiOk()
*******************************************************************************

	Local lMdiOk := U_GetSx6("IM_PERMDI",Nil,.T.)// Parametro Configura se Permite ou Não a uTilização do MDI.

	Begin Sequence

    //Permite o Acesso ao SIGAMDI apenas para o Administrador do Sistema
		If !lMdiOk .And. ( __cUserId <> "000000" ) //| Administrador
			Iw_MsgBox("O Acesso ao Sistema via MDI não esta Permitida. Contate o Adamistrador do sistema e apresente esta mensagem [IM_PERMDI]","Atenção","ALERT")
			Break
		Else
			lMdiOk := .T.
		EndIF

	End Sequence

Return( lMdiOk )
