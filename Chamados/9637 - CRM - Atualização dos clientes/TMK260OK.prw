#Include 'protheus.ch'

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNCAO : TMK260OK    | AUTOR : Cristiano Machado     | DATA : 22/09/2016  **
**---------------------------------------------------------------------------**
** DESCRICAO:                                                                **
**                                                                           **
**                                                                           **
**---------------------------------------------------------------------------**
** USO : Especifico para o cliente                                           **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
** ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                         **
**---------------------------------------------------------------------------**
** PROGRAMADOR        |   DATA   | MOTIVO DA ALTERACAO                       **
**---------------------------------------------------------------------------**
**                    |          |                                           **
**                    |          |                                           **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User Function TMK260OK()
*******************************************************************************

	Local aArea := Getarea()
	Local lRet := .T.

	IF  M->US_TIPO = 'R' // REVENDEDOR
		IF ! M->US_GRPSEG $ GETMV("MV_GSEGREV")
			MsgInfo('Grupo de Segmento invalido para Revendedor! Os grupos corretos devem ser: ' + GETMV("MV_GSEGREV") )
			lRet := .F.
		ENDIF
	ENDIF

	IF  M->US_TIPO = 'F' // CONSUMIDOR FINAL
		IF ! M->US_GRPSEG $ GETMV("MV_GSEGFIN")
			MsgInfo('Grupo de Segmento invalido para Consumidor Final! Os grupos corretos devem ser: ' + GETMV("MV_GSEGFIN") )
			lRet := .F.
		ENDIF
	ENDIF

	Restarea(aArea)

	If lRet
		//|  CHAMADO: 9637 -> CRM - Atualização dos clientes por Vendedores
		U_IATUADL( "SUS", M->US_COD, M->US_LOJA )
	EndIf

Return(lRet)