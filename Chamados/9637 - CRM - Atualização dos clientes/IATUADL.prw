#Include 'protheus.ch'

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNCAO : IATUADL         | AUTOR : Cristiano Machado | DATA : 22/09/2016  **
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
User function IATUADL( cQuem, cCli, cLoj, cTp )
*******************************************************************************

	Local TAlias 	:= ""
	Local cCodCli 	:= ""
	Local cLojaCl	:= ""
	Local TipoOpe	:= ""

	Default  cQuem 	:= ""  //| Qual Tabela esta Solicitando a Sincronizacao
	Default  cCli	:= ""  //| Codigo da Entidade no caso do Cliente
	Default  cLoj	:= ""  //| Loja da Entidade no Caso do Cliente
	Default  cTp	:= "X" //| Tipo de Operacao ( I-Inclusao, A-Alteracao ou E-Exclusao) so obrigatorio informar a Exclusao

	TAlias 	:= Alltrim(cQuem)
	cCodCli	:= Alltrim(cCli)
	cLojaCl	:= Alltrim(cLoj)
	TipoOpe	:= Alltrim(cTp)

	If !Empty(TAlias) .And. !Empty(cCli) .And. !Empty(cLoj)

		SincADL( TAlias, cCodCli, cLojaCl, TipoOpe )

	EndIf

	Return()
*******************************************************************************
Static Function SincADL( TAlias, cCodCli, cLojaCl, TipoOpe )
*******************************************************************************
	Local cPref := TAlias+"->"+Substr(TAlias,2,2)+"_" // Monta o Prefixo ex.: "SA1->A1_"
	Local cVend :=  cPref+"VENDEXT"
	Local cNome :=  cPref+"NOME"
	Local cCgc  :=  cPref+"CGC"

	//| Apaga todos os registros da entidade....
	Deleta( TAlias, cCodCli, cLojaCl  )

	If !Empty(&cVend.) .And. TipoOpe <> "E"

		DbSelectArea("ADL");DbSetOrder(1) //| ADL_FILIAL + ADL_ENTIDA + ADL_FILENT + ADL_CODENT + ADL_LOJENT + ADL_VEND
		If ADL->( DbSeek( xFilial("ADL") + TAlias + Space(2) + cCodCli + cLojaCl, .F.) )
			Reclock("ADL", .F.)
		Else
			Reclock("ADL", .T.)
		EndIf

		ADL->ADL_FILIAL := xFilial("ADL")
		ADL->ADL_VEND	:= &cVend.
		ADL->ADL_ENTIDA := TAlias
		ADL->ADL_CODENT := cCodCli
		ADL->ADL_LOJENT := cLojaCl
		ADL->ADL_NOME 	:= Substr(&cNome.,1,40)
		ADL->ADL_CGC 	:= &cCgc.

		MsUnlock()

	EndIf

	Return()
*******************************************************************************
Static Function Deleta( TAlias, cCodCli, cLojaCl  )
*******************************************************************************

	Local cSql 		:= ""

	cSql := " Delete " + TAlias + "010 "
	cSql += " Where ADL_CODENT = '" + cCodCli + "' "
	cSql += " And   ADL_LOJENT = '" + cLojaCl + "' "
	//cSql += " And   ADL_ENTIDA = '" + TAlias  + "' "

	U_ExecMySQl( cSql , "", "E", .F.)

Return()