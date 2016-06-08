*/Program U_MDIOK.PRG/*/
#INCLUDE "PROTHEUS.CH"


/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUN��O   : MdiOk	       | AUTOR : Cristiano Machado  | DATA : 03/12/2015   **
**---------------------------------------------------------------------------**
** DESCRI��O: Validar o Acesso ao Interface MDI                              **
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

	Local lMdiOk := U_GetSx6("IM_PERMDI",Nil,.T.)// Parametro Configura se Permite ou N�o a uTiliza��o do MDI.

	Begin Sequence

    //Permite o Acesso ao SIGAMDI apenas para o Administrador do Sistema
		If !lMdiOk .And. ( __cUserId <> "000000" ) //| Administrador
			Iw_MsgBox("O Acesso ao Sistema via MDI n�o esta Permitida. Contate o Adamistrador do sistema e apresente esta mensagem [IM_PERMDI]","Aten��o","ALERT")
			Break
		Else
			lMdiOk := .T.
		EndIF

	End Sequence

Return( lMdiOk )
