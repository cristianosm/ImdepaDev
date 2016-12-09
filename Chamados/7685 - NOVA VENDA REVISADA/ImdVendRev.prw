#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include 'Tbiconn.ch'


//|****************************************************************************
//| Projeto: CHAMADO 7685 - NOVA VENDA REVISADA
//| Modulo : COMPRAS
//| Fonte : IMDVENDREV
//| 
//|************|*****************|*********************************************
//|    Data    |     Autor       |                   Descricao
//|************|*****************|*********************************************
//| 28/11/2016 |Cristiano Machado| Solucao desevolvida para calculo da Venda Revisada e Ofertado Atendido
//|            |                 | 
//|            |                 | Deve estar agendado para executar toda a noite a 01:00 da manhã. 
//|            |                 |  
//|            |                 |  
//|************|*****************|*********************************************
*******************************************************************************
User Function ImdVendRev()
*******************************************************************************

	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" FUNNAME 'ImdVendRev'  TABLES 'SM0','SX6'

		Conout('IMDVENDREV - INICIO - ' + DToC(dDataBase) + ' ' + Time() )

		Executa()

		Conout('IMDVENDREV - FIM - ' + DToC(dDataBase) + ' ' + Time() )

	RESET ENVIRONMENT

Return
*******************************************************************************
Static Function Executa()
*******************************************************************************

	Local dDataAtu := dDataBase
	Local lSemErro := .T.
	Local dDtUltE  := GetMv('IMD_VENDRE')
	Local aResult  := {}

	While lSemErro .And. dDataAtu > dDtUltE

		aResult := TCSPEXEC("IMD_VENDAREV", DToS(dDtUltE) )

		IF empty(aResult)
			ErroExec( TcSqlError() )
			lSemErro := .F.

		ElseIf aResult[1] == 0
			ErroExec( TcSqlError() )
			lSemErro := .F.

		EndIF

		If lSemErro

			PutMv('IMD_VENDRE', dDtUltE )

			Conout('IMDVENDREV - Executado com Sucesso dia [ ' + DToC(dDtUltE)  + ' ] ' + DToC(DDataBAse) + ' ' + Time() )

			dDtUltE := dDtUltE + 1
			aResult := {}

		EndIf
	EndDo

Return
*******************************************************************************
Static Function ErroExec(cConteudo)
*******************************************************************************

	Local cEmail :=  "cristiano.machado@imdepa.com.br"

	Conout('IMDVENDREV - ERRO de Execucao, Por favor Verificar !!!' + DToC(DDataBAse) + ' ' + Time() )

	U_EnvMyMail('protheus@imdepa.com.br',cEmail,'','ERRO IMDVENDREV', _ENTER + _ENTER + "Ocorreu erro na Excucao da VENDA REVISADA "  + _ENTER  + _ENTER  + cConteudo ,'',.F.)

Return