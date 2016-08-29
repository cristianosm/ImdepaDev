#INCLUDE "Protheus.ch"
#INCLUDE "Tbiconn.ch"
#Include "Totvs.ch"
#Include "DbInfo.ch"

#Define 	_ENTER 		CHR(13) + CHR(10)
#define _ENTERHTM	'<br>'
//#Define 	DBRI_DELETED       1

/*
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
HH?Fun?ao    ? IMDF110  ? Autor ? Expedito Mendonca Jr. ? Data ? 30/04/2003 HH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH?JHH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
HH? 06/09/06 ?ReestruturaHHo da Rotina IMDF110 com a Nova Vers?o do         HH
HH?          ?   Or?ado X Ofertado - Por Edivaldo Gon?alves Cordeiro        HH
HH? 12/12/06 ?Implementada a alimentacao do ZA0_PRECO on-line no atendimentoHH
HH?          ?   portanto, foi retirado a pesquisa ao SUB no schedule       HH
HH? 24/01/07 ?Quantidade ofertada deve ser o minimo entre a consulta e o    HH
HH?		      ?   saldo e n?o entre o SUB e o Saldo.                        HH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH?JHH
HH?DescriHHo ? Registro de quantidade ofertada e venda perdida              HH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH?JHH
HH? Uso      ?ESPECIFICO PARA IMDEPA	        					        HH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
*/

*******************************************************************************
User Function ImdF110()
*******************************************************************************

	Private nQtd 			:= 0 	//| Quantidade de Itens Marcados
	Private cLogE			:= ""	//| Grava o Log de Incosistencia encontradas...
	Private cLogTab		:= ""	//| Grava o Log de Incosistencia encontradas...

	Private lAchouERRO	:= .F.	//| Flag informando que foi encontrado inconsistencia em algum registro...
	Private aErros			:= {}	//|
	Private nQtdCor		:= 0  	//| Quantidade de itens Corrigidos
	Private nQtdErr		:= 0  	//| Quantidade de Erros Encontrados

	Private nQECoCNE		:= 0	//| Quantidade de Erros Corrigidos Capa Orcamento
	Private nQECoDTE		:= 0	//| Quantidade de Erros Corrigidos Divergencia Datas
	Private nQECoINE		:= 0	//| Quantidade de Erros Corrigidos Item nao Encontrado
	Private nQECoQTD		:= 0	//| Quantidade de Erros Corrigidos Quantidade Menor
	Private nQECoCLI		:= 0	//| Quantidade de Erros Corrigidos Cliente Divergente

	Private cSqlDTE 		:= ""
	Private cSqlCLI 		:= ""
	Private cSqlQTD 		:= ""
	Private cSqlCNE		:= ""

	Private lTeste			:= .F.

	//IF !lTeste
	//Prepare Environment Empresa ("01") Filial ("05") MODULO ("FAT") FunName ("IMDF110") Tables 'SUB','SUA','SB2','ZA0'
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '05' FUNNAME "IMDF110" TABLES 'SB2','SX6','SM0'
	//EndIf

	RegExec(1) //| Registra Execucao
	Executa()  //| Executa Processo Geral

	RegExec(4) //| Registra Execucao
	GravaLog() //| Grava Log com ultima execucao...

	RegExec(5) //| Registra Execucao
	SlvStat()  //| Salva Statisticas....

	RegExec(15)
	SendErros()//| Envia Erroa caso sejam encontrados..

	RegExec(7) //| Registra Execucao


	//IF !lTeste
	Reset Environment
	//EndIf

Return()
*******************************************************************************
Static Function Executa()// Inicia a Execucao do Programa...
*******************************************************************************

	DbSelectArea("SUA");DbSetOrder(1)//| UA_FILIAL+UA_NUM
	DbSelectArea("SUB");DbSetOrder(5)//| UB_FILIAL+UB_NUM+UB_PRODUTO+UB_SEQID

	cLogE := _ENTERHTM + _ENTERHTM + _ENTERHTM
	cLogE += SPACE(10)+ " || --- DIVERGENCIAS ENCONTRADAS NA ZA0 - CONSULTA/OFERTADO/VENDIDO  --- ||" + _ENTERHTM + _ENTERHTM

	CarregaSQL()	//| Carrega SQL Base para Correcoes Futuras

	RegExec(2)		//| Registra Execucao
	SelRegistros()//| Seleciona os Registros a Serem atualizados...ZA0_FLAGOF = " ".

	RegExec(3)		//| Registra Execucao
	While ( !Eof() )

	//| Grava o Ofertado...
		GravaOfertado( Min( REG->ZA0_QUANTD , REG->B2_SALDO ), REG->ZA0_PRECO, REG->R_E_C_N_O_)

		nQtd++

		DbSelectArea("REG")
		DbSkip()

	End While

	RegExec(9)		//| Quantidade de Registros Corrigidos...

	If nQECoCNE > 0 //|  Registros CNE Corrigidos
		RegExec(10)
	EndIF

	If nQECoDTE > 0 //|  Registros DTE Corrigidos
		RegExec(11)
	EndIF

	If nQECoINE > 0 //|  Registros INE Corrigidos
		RegExec(12)
	EndIF

	If nQECoQTD > 0 //|  Registros QTD Corrigidos
		RegExec(13)
	EndIF

	If nQECoCLI > 0 //|  Registros CLI Corrigidos
		RegExec(14)
	EndIF

	cLogE += _ENTERHTM + _ENTERHTM + _ENTERHTM


Return()
*******************************************************************************
Static Function SelRegistros()// Seleciona os Registros que devem ser atualizados...
*******************************************************************************
	Local cData		:= DToS(Date())
	Local n1Hora 		:= 10800 //| 10800 seg = 3 Horas.... Motivo... Tempo de Orcamento... Para validar Capas...
	Local cTime		:= StrTran(Left(U_FTimeTo(Seconds()-n1Hora,,"HC"),5),":","")
	//Local nLastRec	:= ZA0->( LASTREC()) - 1000

	cSql 	:= ""
	cSql 	+= "SELECT 		"
	cSql 	+=  	"  ZA0_FILIAL ,	"
	cSql 	+=  	"ZA0_CLIENT ,		"
	cSql 	+=  	"ZA0_LOJACL ,		"
	cSql 	+=  	"ZA0_NUMORC ,		"
	cSql 	+=  	"ZA0_PRODUT ,		"
	cSql 	+=  	"ZA0_QUANTD ,		"
	cSql 	+=  	"ZA0_PRECO  ,		"
	cSql 	+=  	"NVL(SUM(B2.B2_QATU - B2.B2_RESERVA - B2.B2_QPEDVEN),0) B2_SALDO,		"
	cSql 	+=  	"ZA.R_E_C_N_O_ 		"
	cSql 	+=  	"FROM ZA0010 ZA FULL JOIN SB2010 B2		"
	cSql 	+=  	"ON ZA.ZA0_FILIAL = B2.B2_FILIAL		"
	cSql 	+=  	"AND ZA.ZA0_PRODUT = B2.B2_COD		"

	If lTeste /// Modo Teste....
		cSql 	+=  	"WHERE ZA.R_E_C_N_O_ = "+cValToChar( 11647033 )+"		"
		cSql 	+=  	"AND   ZA.D_E_L_E_T_ = ' '		"
		cSql 	+=  	"AND   B2.B2_LOCAL IN ('01','02')		"
		cSql 	+=  	"AND   B2.D_E_L_E_T_ = ' '		"

	Else /// Modo Normal
		cSql 	+=  	"WHERE ZA0_FLAGOF    = ' '		"
		cSql 	+=  	"AND   ZA.D_E_L_E_T_ = ' '		"
		cSql 	+= 		"AND(  ZA.ZA0_DTNECL < '"+cData+"' OR ( ZA.ZA0_DTNECL = '"+cData+"' AND ZA.ZA0_HRNECL <= '"+cTime+"' ) )		"
		cSql 	+=  	"AND( B2.D_E_L_E_T_ = ' ' OR B2.D_E_L_E_T_ IS NULL )"

	EndIf

	cSql 	+=  	"GROUP BY		"
	cSql 	+=  	"  ZA0_FILIAL ,		"
	cSql 	+=  	"  ZA0_CLIENT ,		"
	cSql 	+=  	"  ZA0_LOJACL ,		"
	cSql 	+=  	"  ZA0_NUMORC ,		"
	cSql 	+=  	"  ZA0_PRODUT ,		"
	cSql 	+=  	"  ZA0_QUANTD ,		"
	cSql 	+=  	"  ZA0_PRECO  ,		"
	cSql 	+=  	"  ZA.R_E_C_N_O_  	"

	Conout( " IMDF110 - SQL: " + cSql )


//| Obs.: Data do Cliente tem que ser Menor que data de execucao da Rotina....
	U_ExecMySql(cSql , "REG", "Q", lTeste )

	DbSelectArea("REG"); DbGotop()

// VOLTAR --- RECNO E FLAGOFER CRISTIANO.

Return()
*******************************************************************************
Static Function GravaOfertado(nQtdOfer, nPreco, nRecZA0 )
*******************************************************************************

	nQtdOfer := Iif(nQtdOfer < 0, 0, nQtdOfer )

	// Atualiza o Registro...
	cSql 	:= 	"Update ZA0010 ";
		+	"Set ZA0_QOFERT  	=  "+ cValToChar(nQtdOfer) 				+" , ";
		+	"ZA0_VOFERT 		=  "+ cValToChar(nQtdOfer * nPreco) 	+" , ";
		+	"ZA0_DTOFER 		= '"+ DToS(Date())						+"', ";
		+	"ZA0_HROFER  		= '"+ Strtran(Left(Time(),5),":","") 	+"', ";
		+	"ZA0_FLAGOF  		= 'S' ";
		+	"Where R_E_C_N_O_ = "+ cValToChar(nRecZA0)

	U_ExecMySql(cSql,"","E",lTeste)

	// Valida se o Registro ZA0 foi Gravado Corretamente....
	ValidaZA0(nRecZA0)

Return()
*******************************************************************************
Static Function ValidaZA0(nRecZA0, cQual)// Valida Registro ZA0 a Procura de Inconsistencias
*******************************************************************************
	Private cChaveZA 	:= "ZA0->ZA0_FILIAL + ZA0->ZA0_NUMORC + ZA0->ZA0_PRODUT"
	Private cChaveUB		:= "SUB->UB_FILIAL  + SUB->UB_NUM     + SUB->UB_PRODUTO"
	Private nQuant			:= 0
	Private cErro			:= ""
	Private lPosicSUA	:= .F.

	Default cQual := Space(03)

	DbSelectArea("ZA0");DbGotop()
	Dbgoto(nRecZA0)

	//| Valida Capa do Orcamento, Codigo de Cliente e Loja
	DbSelectArea("SUA")
	If ( ZA0->ZA0_FILIAL + ZA0->ZA0_NUMORC == SUA->UA_FILIAL+SUA->UA_NUM )
		lPosicSUA := .T.
		//Alert("Compara Achou")
	Else
		lPosicSUA := SUA->( DbSeek( ZA0->ZA0_FILIAL + ZA0->ZA0_NUMORC, .F. ))
		//Alert("Pesquisa Retorna : "+cValToChar(lPosicSUA))
	EndIf

	If lPosicSUA
		If ( SUA->UA_CLIENTE+SUA->UA_LOJA <> ZA0->ZA0_CLIENT + ZA0->ZA0_LOJACL )
			cErro += "CLI " //| CLI -> Cliente Divergente
		EndIF
	Else
		cErro += "CNE " //| CNE -> Capa do Orcamento Nao encontrado
	EndIf

	//| Valiza Existencia do Orcamento e Produto
	DbSelectArea("SUB")
	If ( SUB->( DbSeek(ZA0->ZA0_FILIAL + ZA0->ZA0_NUMORC + ZA0->ZA0_PRODUT, .F. )) )

			//| Valida Data Necessidade Cliente
		If ( SUB->UB_DTNECLI <> ZA0->ZA0_DTNECL)
			cErro += "DTE " //| DTE --> Data Necessidade de Cliente Nao Bate...
		EndIf

		While ( &cChaveZA. == &cChaveUB. .And. !EOF() )
			nQuant := nQuant + SUB->UB_QUANT
			DbSkip()
		EndDo

	ElseIF ZA0->ZA0_QOFERT > 0
		//cErro += "INE " //| INE ->  Item do Orcamento nao Encontrado.
	EndIf

	//| Valida Quantidade Digitada e Consultada
	If ( nQuant > ZA0->ZA0_QUANTD )
		cErro += "QTD "		//| QTD -> Quantidade Digitada Menor que o Consultado...
	EndIf

	If !Empty(cErro)
		lAchouERRO	:= .T.
		InformaERRO(cErro,nRecZA0)

	EndIF

Return()
*******************************************************************************
Static Function InformaERRO(cErro,nRecZA0)//| Grava o ERRO no LOG e Solicita Correcao...
*******************************************************************************
	Local lCorrigido 	:= .F.
	Local cLogTemp			:= ""
	Local cOk					:= " -> Corrigido "


	If ( AT("CNE ",cErro) > 0 )  	 //| ONE -> Orcamento Nao encontrado

		lCorrigido := CorrigErros(nRecZA0, "CNE")
		If lCorrigido
			cLogTemp += "#CNE "  + cOk //+ " -> Capa do Orcamento/Faturamento nao Encontrado."
		Else
			cLogTemp += "#CNE "//+ " -> Capa do Orcamento/Faturamento nao Encontrado."
		EndIf

	EndIF

	If ( AT("DTE ",cErro) > 0 ) //| DTE --> Data Necessidade de Cliente Nao Bate...

		lCorrigido := CorrigErros(nRecZA0, "DTE")
		If lCorrigido
			cLogTemp += "#DTE "  + cOk//+ " -> Divergencia na Data de Necessidade do Cliente. "
		Else
			cLogTemp += "#DTE " //+ " -> Divergencia na Data de Necessidade do Cliente. "
		EndIf

	EndIf

	If ( AT("INE ",cErro) > 0 )  	 //| ONE -> Orcamento Nao encontrado

		lCorrigido := CorrigErros(nRecZA0, "INE")
		If lCorrigido
			cLogTemp += "#INE " + cOk //+ " -> Item do Orcamento nao Encontrado."
		Else
			cLogTemp += "#INE " //+ " -> Item do Orcamento nao Encontrado."
		EndIf

	EndIF

	If ( AT("QTD ",cErro) > 0 ) 		//| QTD -> Quantidade Digitada Menor que o Consultado...

		lCorrigido := CorrigErros(nRecZA0, "QTD")
		If lCorrigido
			cLogTemp += "#QTD " + cOk //+ " -> Quantidade Consultada (ZA0) Menor que Digitada (SUB). "
		Else
			cLogTemp += "#QTD " //+ " -> Quantidade Consultada (ZA0) Menor que Digitada (SUB). "
		EndIF

	EndIf

	If ( AT("CLI ",cErro) > 0 )  //| CLI -> Cliente Divergente

		lCorrigido := CorrigErros(nRecZA0, "CLI")
		If lCorrigido
			cLogTemp += "#CLI " + cOk//+ " -> Codigo de Cliente ou Loja Divergentes. "
		Else
			cLogTemp += "#CLI "  //+ " -> Codigo de Cliente ou Loja Divergentes. "
		EndIf

	EndIf

	cLogE += Space(10)+" * ZA0->R_E_C_N_O = "+cValToChar(nRecZA0) + " " + cLogTemp + " " + _ENTERHTM

	If lCorrigido
		nQtdCor += 1
		nQtdErr += 1
	Else
		nQtdErr += 1
	EndIf

Return()
*******************************************************************************
Static Function SendErros()// Envia por email o log de erro..
*******************************************************************************
	Local cFrom 	:= "protheus@imdepa.com.br"
	Local cTo		:= Alltrim( SuperGetsMv("IM_LOGF100", .F., "cristiano.machado@imdepa.com.br", Nil) )
	Local cBcc		:= ""
	Local cSubject	:= ""
	Local cHtmCab	:= ""
	Local cAttach	:= ""
	Local cBody		:= ""
	Local cLeg 		:= ""

	cHtmCab += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">'
	cHtmCab += '<html>'
	cHtmCab += '<body>'
	cHtmCab += '<style>'

	cHtmCab += '	table.legenda{
	cHtmCab += 'border: 0px solid black;
		cHtmCab += '   width :100%;
		cHtmCab += '   text-align: left;
		cHtmCab += '}

	cHtmCab += 'table.tabela{
	cHtmCab += '   border: 2px solid black;
		cHtmCab += '   width :100%;
		cHtmCab += '   text-align: center;
		cHtmCab += '}
	cHtmCab += '</style>'

	cLeg 		+= " LEGENDA: " + _ENTERHTM + _ENTERHTM
	cLeg			+= '<table class="legenda">'
	cLeg			+= '<tr>'
	cLeg			+= '<td>CNE</td>'
	cLeg			+= '<td>-></td>'
	cLeg			+= '<td>Capa do Orcamento n?o encontrado.</td>'
	cLeg			+= '</tr>'

	cLeg			+= '<tr>'
	cLeg			+= '<td>DTE</td>'
	cLeg			+= '<td>-></td>'
	cLeg			+= '<td>Divergencia na data de necessidade do Cliente.</td>'
	cLeg			+= '</tr>'

	cLeg			+= '<tr>'
	cLeg			+= '<td>QTD</td>'
	cLeg			+= '<td>-></td>'
	cLeg			+= '<td>Quantidade Consultada (ZA0) menor que digitada (SUB).</td>'
	cLeg			+= '</tr>'

	cLeg			+= '<tr>'
	cLeg			+= '<td>CLI</td>'
	cLeg			+= '<td>-></td>'
	cLeg			+= '<td>Codigo de Cliente ou Loja Divergentes.</td>'
	cLeg			+= '</tr>'
	cLeg			+= '</table>'
	cLeg 		+= _ENTERHTM + _ENTERHTM + _ENTERHTM

	//cLogE += SPACE(10)+ " || --- ANALIZAR E CORRIDIR TODAS AS DIVERGENCIAS ENCONTRADAS ACIMA !!!  --- ||" + _ENTERHTM + _ENTERHTM

	cBody := cHtmCab + cLogE + cLeg + cLogTab + '</body></html>'

	If !lAchouERRO
		RegExec(8)
		cSubject	:= "IMDF110 - Nenhuma Inconsistencia nos Dados da Tabela ZA0"
		//Return()
	Else
		cSubject	:= "IMDF110 - Inconsistencia nos Dados da Tabela ZA0"
	EndIf

	If ( nQtdErr > nQtdCor ) //| Compara Erros Enconrados com Corrigidos ....
		cSubject += " - Exitem ERROS nao Corrigidos !!!
	EndIf

	U_EnvMyMail(cFrom,cTo,cBcc,cSubject,cBody,cAttach)	//|

	//ConOut("cbody:"+cBody)

	RegExec(6)

Return()

*******************************************************************************
Static Function CorrigErros(nRecZA0, cErro)//| Corrige Erros que foram encontrados..
*******************************************************************************

	Local cRecZA0 		:= cValToChar(nRecZA0)
	Local lRetorno		:= .F.
	Local cSqlAux		:= ""
	Local lCorrigido := .T.

	If !lAchouERRO
		Return(lRetorno)
	EndIf

	//| Capa do Orcamento n?o encontrado.
	If cErro == "CNE"

		cSqlAux := cSqlCNE + cRecZA0 + " "

		U_ExecMySQl(cSqlAux,"","E",lTeste)

		If ValCorrecao("CNE",nRecZA0) == lCorrigido // Valida Corre?ao
			nQECoCNE		+=  1
			lRetorno		:= .T.
		Else
			lRetorno		:= .F.
		EndIf

	EndIF

	//| Divergencia na data de necessidade do Cliente. " + _ENTER
	If cErro == "DTE"

		cSqlAux := cSqlDTE + cRecZA0 + " "

		U_ExecMySQl(cSqlAux,"","E",lTeste)

		If ValCorrecao("DTE",nRecZA0) == lCorrigido
			nQECoDTE	+= 1
			lRetorno	:= .T.
		Else
			lRetorno	:= .F.
		EndIf

	EndIf

	//| Item do Orcamento n?o encontrado.
	If cErro == "INE"
		//nQECoINE	+= 1
	EndIF

	//| Quantidade Consultada (ZA0) menor que digitada (SUB).
	If cErro == "QTD"

		cSqlAux := cSqlQTD + cRecZA0 + " "

		U_ExecMySQl(cSqlAux,"","E",lTeste)

		If ValCorrecao("QTD",nRecZA0) == lCorrigido
			nQECoQTD	+= 1
			lRetorno	:= .T.
		Else
			lRetorno	:= .F.
		EndIf
	EndIF

	//| Corrige: Codigo de Cliente ou Loja Divergentes.
	If cErro == "CLI"

		cSqlAux := cSqlCLI + cRecZA0 + " "

		U_ExecMySQl(cSqlAux,"","E",lTeste)

		If ValCorrecao("CLI",nRecZA0) == lCorrigido
			nQECoCLI	+= 1
			lRetorno	:= .T.
		Else
			lRetorno	:= .F.
		EndIf
	EndIf

Return(lRetorno)
*******************************************************************************
Static Function ValCorrecao(cTipo,nRecZA0)// Verifica se a Correcao Funcionou...
*******************************************************************************
	Local lNCor  	:= .F.
	Local lSCor		:= .T.
	local cChaveZA := "ZA0->ZA0_FILIAL + ZA0->ZA0_NUMORC + ZA0->ZA0_PRODUT"
	local cChaveUB	:= "SUB->UB_FILIAL  + SUB->UB_NUM     + SUB->UB_PRODUTO"
	local nQuant		:= 0

// Posiciona ZA0
	DbSelectArea("ZA0")
	DbGotop()
	DbGoto(nRecZA0)


	If cTipo == "CNE"

		If !( DBRecordInfo(DBRI_DELETED) )
			Return(lNCor)
		EndIF

	Else

//| Posiciona... SUA
		DbSelectArea("SUA")
		If ( ZA0->ZA0_FILIAL + ZA0->ZA0_NUMORC == SUA->UA_FILIAL+SUA->UA_NUM )
			lPosicSUA := .T.
		Else
			lPosicSUA := SUA->( DbSeek( ZA0->ZA0_FILIAL + ZA0->ZA0_NUMORC, .F. ))
		EndIf


		If cErro == "DTE"

			DbSelectArea("SUB")
			If ( SUB->( DbSeek(ZA0->ZA0_FILIAL + ZA0->ZA0_NUMORC + ZA0->ZA0_PRODUT, .F. )) )
				If ( SUB->UB_DTNECLI <> ZA0->ZA0_DTNECL)
					Return(lNCor)
				EndIf
			EndIf

		ElseIf cErro == "INE"

	//*****

		ElseIf cErro == "QTD"

			DbSelectArea("SUB")
			If ( SUB->( DbSeek(ZA0->ZA0_FILIAL + ZA0->ZA0_NUMORC + ZA0->ZA0_PRODUT, .F. )) )

				While ( &cChaveZA. == &cChaveUB. .And. !EOF() )
					nQuant := nQuant + SUB->UB_QUANT
					DbSkip()
				EndDo

				If ( nQuant > ZA0->ZA0_QUANTD )
					Return(lNCor)
				EndIf
			EndIF

		ElseIf cErro == "CLI"

			If ( SUA->UA_CLIENTE+SUA->UA_LOJA <> ZA0->ZA0_CLIENT + ZA0->ZA0_LOJACL )
				Return(lNCor)
			EndIF

		EndIf

	EndIf

Return(lSCor)
*******************************************************************************
Static Function CarregaSQL()// Carrega SQL...
*******************************************************************************

	Local cSQl := ""


//| Query CNE - > Capa do Orcamento Nao Encontrado.
	cSQl := ""
	cSQl += " UPDATE ZA0010 Set D_E_L_E_T_ = '*' "
	cSQl += " WHERE R_e_c_n_o_  = " //11577499

	cSqlCNE := cSQl


//| Query CLI - > Codigo de Cliente ou Loja Divergentes.
	cSQl := ""
	cSQl += " UPDATE ZA0010 SET "
	cSQl += " ZA0_CLIENT = (SELECT UA_CLIENTE FROM SUA010 WHERE UA_FILIAL = ZA0_FILIAL AND UA_NUM = ZA0_NUMORC ), "
	cSQl += " ZA0_LOJACL = (SELECT UA_LOJA    FROM SUA010 WHERE UA_FILIAL = ZA0_FILIAL AND UA_NUM = ZA0_NUMORC ) "
	cSQl += " WHERE R_e_c_n_o_  = " //11577499

	cSqlCLI := cSQl


//| Query DTE - > Divergencia na data de necessidade do Cliente. " + _ENTER
	cSQl := ""
	cSQl += " UPDATE ZA0010 SET "
	cSQl += "   ZA0_DTNECL = (SELECT MAX(UB_DTNECLI) UB_DTNECLI FROM SUB010 WHERE UB_FILIAL = ZA0_FILIAL AND UB_NUM = ZA0_NUMORC AND UB_PRODUTO = ZA0_PRODUT ), "
	cSQl += "   ZA0_HRNECL = (SELECT MAX(UB_HRNECLI) UB_HRNECLI FROM SUB010 WHERE UB_FILIAL = ZA0_FILIAL AND UB_NUM = ZA0_NUMORC AND UB_PRODUTO = ZA0_PRODUT ) "
	cSQl += " WHERE R_e_c_n_o_  = " //11584985

	cSqlDTE := cSQl


//| Query QTD - > Quantidade Consultada (ZA0) menor que digitada (SUB).
	cSQl := ""
	cSQl += " UPDATE ZA0010 SET "
	cSQl += "   ZA0_QUANTD = (SELECT SUM(UB_QUANT) UB_QUANT FROM SUB010 WHERE UB_FILIAL = ZA0_FILIAL AND UB_NUM = ZA0_NUMORC AND UB_PRODUTO = ZA0_PRODUT ) "
	cSQl += " WHERE R_e_c_n_o_  = "//1  "//1578142  "

	cSqlQTD := cSQl

Return()
*******************************************************************************
Static Function RegExec(nP)// Registra Operacao no console.log
*******************************************************************************

	If nP == 1
		Conout(" IMDF110 - Iniciando Execucao............................. " + cValToChar(dDataBase) + "  " + Time() )
	ElseIf nP == 2
		Conout(" IMDF110 - Verificando Registros.......................... " + cValToChar(dDataBase) + "  " + Time() )
	ElseIf nP == 3
		Conout(" IMDF110 - Gravando Ofertados............................. " + cValToChar(dDataBase) + "  " + Time() )
	ElseIf nP == 4
		Conout(" IMDF110 - "+StrZero(nQtd,4)+" Registros Consultados Atualizados......... " + cValToChar(dDataBase) + "  " + Time() )
	ElseIf nP == 5
		Conout(" IMDF110 - Salvando Log de Execucao....................... " + cValToChar(dDataBase) + "  " + Time() )
	ElseIf nP == 6
		Conout(" IMDF110 - Erros Encontrados, verificar email............. " + cValToChar(dDataBase) + "  " + Time() )
	ElseIf nP == 7
		Conout(" IMDF110 - Execucao Finalizada  .......................... " + cValToChar(dDataBase) + "  " + Time() )
	ElseIf nP == 8
		Conout(" IMDF110 - Nenhuma Inconsistencia Encontrada ............. " + cValToChar(dDataBase) + "  " + Time() )
	ElseIf nP == 9
		Conout(" IMDF110 - "+StrZero(nQtdCor,4)+" Registros Corrigidos no Total............. " + cValToChar(dDataBase) + "  " + Time() )
	//| Correcoes ...
	ElseIf nP == 10
		Conout("         - "+StrZero(nQECoCNE,4)+" Registros CNE Corrigidos.................. " + cValToChar(dDataBase) + "  " + Time() )
	ElseIf nP == 11
		Conout("         - "+StrZero(nQECoDTE,4)+" Registros DTE Corrigidos.................. " + cValToChar(dDataBase) + "  " + Time() )
	ElseIf nP == 12
		Conout("         - "+StrZero(nQECoINE,4)+" Registros INE Corrigidos.................. " + cValToChar(dDataBase) + "  " + Time() )
	ElseIf nP == 13
		Conout("         - "+StrZero(nQECoQTD,4)+" Registros QTD Corrigidos.................. " + cValToChar(dDataBase) + "  " + Time() )
	ElseIf nP == 14
		Conout("         - "+StrZero(nQECoCLI,4)+" Registros CLI Corrigidos.................. " + cValToChar(dDataBase) + "  " + Time() )
	ElseIf nP == 15
		Conout(" IMDF110 - Salva Log para Estatisticas ................... " + cValToChar(dDataBase) + "  " + Time() )
	EndIf

Return
*******************************************************************************
Static Function GravaLog()/// Grava Log de Execucao....
*******************************************************************************
	Local cConteudo := "Data/Hora: "+ DToC(Date()) +" "+ Time() +" -> Registros processados: "+ cValToChar(nQtd)

//| grava um pequeno log da rotina
	DbSelectArea("SX6");DbSetOrder(1)

	If dbSeek(xFilial("SX6")+"MV_LOGJOB1")
		Reclock("SX6",.F.)
		Replace X6_CONTEUD with cConteudo
		MsUnlock()
	Else
		Reclock("SX6",.T.)
		Replace X6_FIL with xFilial("SX6"),;
			X6_VAR with "MV_LOGJOB1",;
			X6_TIPO with "C",;
			X6_DESCRIC with "Informacoes sobre o ultimo processamento da rotina",;
			X6_DESC1 with "IMDF110 de gravacao do Ofertado e Vendas Perdidas",;
			X6_CONTEUD with cConteudo,;
			X6_PROPRI with "U"
		MsUnlock()
	Endif

Return()
*******************************************************************************
Static Function SlvStat() //Tabela Que armazena Estatisticas....
*******************************************************************************

	CriaouAbretab()

	SalvaLog()

	ApagaMes13()

	cLogTab := MontaLog()

	Retorn()
*******************************************************************************
Static Function MontaLog()
*******************************************************************************
	cHtmbody := ""
//cTitulo 	:= " | Periodo | Tot Consultados      | Tot Erros            | Tot Erros CNE        | Tot Erros DTE        | Tot Erros INE        | Tot Erros QTD        | Tot Erros CLI        | % Consultado/Erros   | % Erros/Corrigidos   |"
//clinha		:= " --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

	cHtmbody := '<table class="tabela">' //style="border: 1px solid black; width:100%" align="center">' + _ENTER
	cHtmbody += "<tr>"
	cHtmbody += "<th>Periodo</th>"
	cHtmbody += "<th>Total</th>"
	cHtmbody += "<th>Total</th>"
	cHtmbody += "<th>Total</th>"
	cHtmbody += "<th>Total</th>"
	cHtmbody += "<th>Total</th>"
//cHtmbody += "<th>Total</th>" + _ENTER
	cHtmbody += "<th>Total</th>"
	cHtmbody += "<th>Relacao</th>"
	cHtmbody += "<th>Relacao</th>"
	cHtmbody += "</tr>"

	cHtmbody += "<tr>"
	cHtmbody += "<th>Analisado</th>"
	cHtmbody += "<th>Consultados</th>"
	cHtmbody += "<th>Erros</th>"
	cHtmbody += "<th>Erros CNE</th>"
	cHtmbody += "<th>Erros DTE</th>"
//cHtmbody += "<th>Erros INE</th>" + _ENTER
	cHtmbody += "<th>Erros QTD</th>"
	cHtmbody += "<th>Erros CLI</th>"
	cHtmbody += "<th>Erros/Consultados</th>"
	cHtmbody += "<th>Erros/Corrigidos</th>"
	cHtmbody += "</tr>"

//cLog := cTitulo +	_ENTER + clinha + _ENTER

	DbSelectArea("IMDF");DbGotop()
	While !EOF()

		cHtmbody += "<tr>"
	//cLog += " | "
		cHtmbody += "<td>" + Transform(IMDF->PERIODO,"@R 9999.99")  +  "</td>" 	// Periodo AAAAMM
	//cLog += 	PadC(cValToChar(IMDF->REGCONS),20,' ')   +  " | "	// Registros Marcados como Consultados...
		cHtmbody +=	"<td>" + Transform(IMDF->REGCONS,"@E 99,999,999,999") + "</td>" 	// Registros Marcados como Consultados...
		cHtmbody +=	"<td>" + Transform(IMDF->ERROTOT,"@E 99,999,999,999") + "</td>" // Total de Erros Encontrados...
		cHtmbody +=	"<td>" + Transform(IMDF->ERROCNE,"@E 99,999,999,999") + "</td>"// Erros CNE encontrados...
		cHtmbody +=	"<td>" + Transform(IMDF->ERRODTE,"@E 99,999,999,999") + "</td>" // Erros DTE encontrados...
	//cHtmbody +=	"<td>" + Transform(IMDF->ERROINE,"@E 99,999,999,999") + "</td>" + _ENTER	// Erros INE encontrados...
		cHtmbody +=	"<td>" + Transform(IMDF->ERROQTD,"@E 99,999,999,999") + "</td>" 	// Erros QTD encontrados...
		cHtmbody +=	"<td>" + Transform(IMDF->ERROCLI,"@E 99,999,999,999") + "</td>" 	// Erros CLI encontrados..
		cHtmbody +=	"<td>" + Transform(IMDF->RELTOTE,"@R 9,999.99 %") + "</td>" 	// Relacao Total Consultado / Erros encontrados... (%)
		cHtmbody +=	"<td>" + Transform(IMDF->RELECOR,"@R 9,999.99 %") + "</td>"
		cHtmbody +=	"</tr>"

		DbSelectArea("IMDF")
		DbSkip()

	EndDo

	cHtmbody += "</table>" + _ENTER
//cLog += clinha + _ENTER

Return(cHtmbody)
*******************************************************************************
Static Function ApagaMes13()
*******************************************************************************
	Local cPeriodo := Substr(Dtos(ctod("01/"+StrZero(Month(dDataBase),2)+"/"+cValToChar(year(dDataBase)))-366),1,6)

	If ( DbSeek( cPeriodo , .F. ) )

		RecLock("IMDF", .F.)
		DbDelete()
		Msunlock()

	EndIf

Return()
*******************************************************************************
Static Function SalvaLog()
*******************************************************************************

	Local cPeriodo := Substr(Dtos(dDataBase),1,6)
	DbSelectArea("IMDF");DbGotop();DbSetOrder(1)

	If ( DbSeek( cPeriodo , .F. ) )
		RecLock("IMDF", .F.)
	Else
		RecLock("IMDF", .T.)
	EndIf

	IMDF->PERIODO := cPeriodo		// Periodo AAAAMM
	IMDF->REGCONS += nQtd				// Registros Marcados como Consultados...
	IMDF->ERROTOT += nQtdErr			// Total de Erros Encontrados...
	IMDF->ERROCNE += nQECoCNE // Erros CNE encontrados...
	IMDF->ERRODTE += nQECoDTE // Erros DTE encontrados...
	IMDF->ERROINE += nQECoINE // Erros INE encontrados...
	IMDF->ERROQTD += nQECoQTD // Erros QTD encontrados...
	IMDF->ERROCLI += nQECoCLI // Erros CLI encontrados..
	IMDF->RELTOTE := Round( IMDF->ERROTOT / IMDF->REGCONS * 100 ,2) // Relacao Total Consultado / Erros encontrados... (%)
	IMDF->RELECOR := Round( ( IMDF->ERROCNE + IMDF->ERRODTE + IMDF->ERROINE + IMDF->ERROQTD + IMDF->ERROCLI ) / IMDF->ERROTOT * 100 ,2 )//

	Msunlock()

Return()
*******************************************************************************
Static Function CriaouAbretab()
*******************************************************************************

	Local cNameFile	:= "IMDF110"
	local cAliasFile	:= "IMDF"
	Local cPath			:= Nil
	Local cDriver		:= Nil
	local lReplace		:= .F.
	Local aStruFile	:= {	{ "PERIODO" , "C",  6, 0	} ,; // Periodo AAAAMM
	{	"REGCONS" , "N", 14, 0	} ,; // Registros Marcados como Consultados...
	{	"ERROTOT" , "N", 14, 0	} ,; // Total de Erros Encontrados...
	{	"ERROCNE" , "N", 14, 0 	} ,; // Erros CNE encontrados...
	{	"ERRODTE" , "N", 14, 0 	} ,; // Erros DTE encontrados...
	{	"ERROINE" , "N", 14, 0 	} ,; // Erros INE encontrados...
	{	"ERROQTD" , "N", 14, 0 	} ,; // Erros QTD encontrados...
	{	"ERROCLI" , "N", 14, 0 	} ,; // Erros CLI encontrados..
	{	"RELTOTE" , "N",  7, 2 	} ,; // Relacao Total Consultado / Erros encontrados... (%)
	{	"RELECOR" , "N",  7, 2 	} }	 // Relacao Total Corrigidos / Erros Encontrados... (%)


	Local aStruIndex	:= { "PERIODO" }

	U_MyFile( aStruFile, aStruIndex, cPath, cNameFile, cAliasFile, cDriver, lReplace )

	DbSelectArea("IMDF")
	DbGoTop()

Return()
