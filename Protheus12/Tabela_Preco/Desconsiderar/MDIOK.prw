#include 'protheus.ch'
#include 'parmtype.ch'
#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

/*
****************************************************************************
****************************************************************************
* Programa  * MDIOK  * Autor  *  AGOSTINHO LIMA   * Data * 07/08/2017 *
****************************************************************************
* Desc.     * A execucao do ponto de entrada e realizada apos as tela de   *
*           * login, data base, ambiente e papel de trabalho.              *
****************************************************************************
* Uso       * IMDEPA ROLAMENTOS                                            *
****************************************************************************
****************************************************************************
*/

****************************************************************************
User Function MDIOK()
****************************************************************************


Local lMdiOk := U_GetSx6("IM_PERMDI",Nil,.T.)// Parametro Configura se Permite ou Não a uTilização do MDI.


	Begin Sequence

    //Permite o Acesso ao SIGAMDI apenas para o Administrador do Sistema
		If !lMdiOk .And. ( __cUserId <> "000000" ) //| Administrador
			Iw_MsgBox("O Acesso ao Sistema via MDI não esta Permitida. Contate o Adamistrador do sistema e apresente esta mensagem [IM_PERMDI]","Atenção","ALERT")
			Break
		Else

			lMdiOk := .T.

            U_TelFunBrow() // Rotina para criar a tela de fundo do browse do protheus com as informacoes da conexao

		EndIF

	End Sequence

Return( lMdiOk )


