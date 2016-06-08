#Include "Totvs.Ch"
#Include "protheus.Ch"

// -----------------------------------------------------------------------------------------
// Projeto:
// Modulo :
// Fonte  : WfOcupacaoWMS
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 14/02/14 | Cristiano Machado | Rotina que Define a Ocupação do Endereço.
// ---------+-------------------+-----------------------------------------------------------
*******************************************************************************
User Function WfOcupacao(lModo)
*******************************************************************************
	Private cDataAtu
	Private cHoraAtu
	Private cSvDtHrE
	Private cTpExecucao
	Private cDtUExecP
	Private cHrUExecP
	Private cDtUExecC
	Private cHrUExecC
	Private lTeste
	Private nSeq
	Private cMsg
	Private lMostra

	Default lModo := .F.

//Prepare Environment Empresa '01' Filial '05' User 'WORKFLOW' PassWord 'WORK' Tables 'SX6' Modulo "WMS"

//| Ajustes Pre-execucao
	PreAjustes(lModo)

//| Processo Geral
	If cTpExecucao == "M"
		Processa( {|| Processar()} , "Calculando Ocupacao..." , cMsg , .F. )
	Else
		Processar()
	EndIf

//Reset Environment

Return()
*******************************************************************************
Static Function PreAjustes(lModo)
*******************************************************************************
	nSeq				:= 0

	lTeste			:= lModo
	lMostra			:= .F.

	cDataAtu			:= Dtos(dDataBase) 		//| Data Atual do sistema
	cHoraAtu			:= Substr(Time(),1,5)	//| Hora Atual do sistema

	cSvDtHrE 			:= cDataAtu + " " + cHoraAtu //| Salva Data e Hora da Execucao no Formato "YYYYMMDD HH:MM"
	cTpExecucao		:= Iif(lTeste,"M","")  //| Tipo de Execucao...: P -> Parcial ... C -> Completa ... N -> Nao Executa ...

	cDtUExecP 		:= SuperGetMv("IM_DTUEP",.F.,DTOS(dDataBase))  // Obtem Data da ultima execucao Parcial no Formato "YYYYMMDD"
	cHrUExecP 		:= SuperGetMv("IM_HRUEP",.F.,Substr(Time(),1,5))  // Obtem Hora da ultima execucao Parcial no Formato "HH:MM"

	cDtUExecC 		:= SuperGetMv("IM_DTUEC",.F.,DTOS(dDataBase-1))  // Obtem Data da ultima execucao Completa no Formato "YYYYMMDD"
	cHrUExecC 		:= SuperGetMv("IM_HRUEC",.F.,Substr(Time(),1,5))  // Obtem Hora da ultima execucao Completa no Formato "HH:MM"

	MsgServer( "Pre-Ajustes" )

	If Empty(cTpExecucao)

	//| Valida Qual Tipo de execucao deve ser definida...
		If ( cHoraAtu > '03:00' .And. cHoraAtu < '04:00' ) //| Neste Periodo deve ser feita uma execucao completa.... Madrugada...
			If ( cDataAtu <> cDtUExecC )
				cTpExecucao := "C" //|Execucao Completa
			Else
				cTpExecucao := "N" //|Nao Executa
			EndIf
		ElseIf  ( cHoraAtu >= '07:00' .And.  cHoraAtu <= '23:00' ) //| Neste Periodo deve ser feita uma execucao completa.... Madrugada...
			cTpExecucao := "P" //| Executacao Parcial
		Else
			cTpExecucao := "N" //|Nao Executa
		EndIf

	EndIf

	MsgServer( "Definicao Tipo Execucao ["+cTpExecucao+"]" )

Return()
*******************************************************************************
Static Function Processar()
*******************************************************************************
	Private cSvDtHrE := DTOS(dDataBase) + " " + Substr(Time(),1,5) //Salva Data e Hora da Execucao no Formato "YYYYMMDD HH:MM"


//| Selecionar Enderecos que devem ser Avaliados....e tras novo valor acumulado...
	SelEnderecos()


//| Atualizar Enderecos
	AtuEnderecos()


//| Salva Parametros...


//PUTMV( <nome do parâmetro>, <conteúdo> )
//PUTMV( <nome do parâmetro>, <conteúdo> )

Return()
*******************************************************************************
Static Function SelEnderecos()//| Selecionar Enderecos que devem ser Avaliados....
*******************************************************************************
	Local cSql := ""
	Local cForCal1 := "DECODE( DC2_QTDEL,0,1,DC2_QTDEL ) * DECODE( DC2_QTDEC,0,1,DC2_QTDEC ) * DECODE( DC2_QTDEA,0,1,DC2_QTDEA )"
	local cForCal2	:= "DECODE( DC2_LASTRO, 0, 1, DC2_LASTRO ) * DECODE( DC2_CAMADA, 0, 1, DC2_CAMADA )"

	MsgServer( "Antes de Execucao da Query" )

//--/ Verificar Todos os Enderecos Alterados nos Ultimos 4 Minutos...e monta nova ocupacao...

	cSql += "SELECT "
	cSql += "	DB_FILIAL FILIAL, DB_LOCALIZ ENDERECO, COUNT( DB_PRODUTO ) PARTICOES, ROUND( SUM( DC2_PEROCU ) ) OCUPACAO "
	cSql += "FROM ( "

	cSql += "	SELECT  "
	cSql += "		DB_FILIAL, DB_PRODUTO, DB_LOCALIZ, BF_QUANT, BF_ESTFIS ,DC3_CODNOR, "
	cSql += "  	("+cForCal2+") DC2_QTDLIM, "
	cSql += "    ((BF_QUANT) / ("+cForCal2+") * 100) DC2_PEROCU "

	cSql += "  FROM "

//| Tabela Saldos por Endereco. Obtem os Saldos.... SBF010
	cSql += "  	( "
	cSql += "    	SELECT "
	cSql += "      	BF_FILIAL, BF_LOCALIZ, BF_PRODUTO, BF_LOCAL, BF_ESTFIS, SUM( BF_QUANT ) BF_QUANT "
	cSql += "     	FROM "
	cSql += "      	SBF010 "
	cSql += "      WHERE "
//cSql += "      			BF_FILIAL = '05' AND "
	cSql += "        		BF_LOCAL IN( '01', '02' ) "
	cSql += "        AND 	BF_LOCALIZ > '               ' "
	cSql += "        AND 	BF_LOCALIZ <> 'DOCA' "
	cSql += "        AND 	D_E_L_E_T_ = ' ' "
//cSql += "        AND BF_LOCALIZ = 'CA00210' "
	cSql += "      GROUP BY "
	cSql += "        BF_FILIAL, BF_LOCALIZ, BF_PRODUTO, BF_LOCAL, BF_ESTFIS "
	cSql += "    ) BF "

	cSql += "  INNER JOIN "

//| Tabela Sequencia de Abastecimento... DC3010
	cSql += "  DC3010 C3 "
	cSql += "  	ON 	BF_FILIAL 	= DC3_FILIAL "
	cSql += "  	AND 	BF_PRODUTO	= DC3_CODPRO "
	cSql += "  	AND 	BF_ESTFIS 	= DC3_TPESTR "
	cSql += "  	AND 	BF_LOCAL 	= DC3_LOCAL "

	cSql += "  INNER JOIN "

//| Tabela Cadastro de Normas... DC2010
	cSql += "  DC2010 C2 "
	cSql += "  	ON 	DC2_FILIAL = '"+xFilial("DC2")+"' "
	cSql += "  	AND 	DC3_CODNOR = DC2_CODNOR "

	cSql += "  INNER JOIN "

//| Tabela Cadastros de Estruturas... DC8010
	cSql += "  DC8010 C8 "
	cSql += "  	ON 	DC8_FILIAL = '"+xFilial("DC8")+"' "
	cSql += "  	AND 	DC8_CODEST = BF_ESTFIS "

	cSql += "  INNER JOIN "

	cSql += "  ( "
	cSql += FiltraEnds() //| Seleciona os Enderecos que devem ser atualizados....
	cSql += "  ) DB "
	cSql += "    ON   DB_FILIAL  	= BF_FILIAL "
	cSql += "    AND  DB_LOCALIZ 	= BF_LOCALIZ "
	cSql += "    AND  DB_PRODUTO 	= BF_PRODUTO "
	cSql += "    AND BD_LOCAL 		= BF_LOCAL "

	cSql += "	WHERE 	"
	cSql += " 			C3.D_E_L_E_T_ = ' ' "
	cSql += "  AND C2.D_E_L_E_T_ = ' ' "
	cSql += "  AND C8.D_E_L_E_T_ = ' ' "
	cSql += "      ) "

	cSql += "GROUP BY DB_FILIAL, DB_LOCALIZ "
	cSql += "ORDER BY DB_FILIAL, DB_LOCALIZ "

	
	U_ExecMySql(cSql, "ENDATU", "Q", lMostra) //| Enderecos a Atualizar....


	If cTpExecucao == "M" .And. lTeste // Em Modo Teste e Manual deve Limpar a Tabela antes da gravacao...
		U_ExecMySql("Delete ZZ0010", "", "E", lMostra) //| Enderecos a Atualizar....
	EndIf

	MsgServer( "Apos Execucao da Query" )

Return()
*******************************************************************************
Static Function FiltraEnds() //| Seleciona os Enderecos que devem ser atualizados....
*******************************************************************************
	Local cSql := ""

	If cTpExecucao == 'M' // Modo Manual ( Homologacao )

		cSql += "                               SELECT BF_FILIAL DB_FILIAL, BF_LOCAL BD_LOCAL, BF_LOCALIZ DB_LOCALIZ, BF_PRODUTO DB_PRODUTO "
		cSql += "                               FROM  SBF010 "
		cSql += "                               WHERE BF_FILIAL = '"+MV_PAR01+"' "
		If ( MV_PAR02 == "ZZ" )
			cSql += "                               AND BF_LOCAL In('01','02') "
		Else
			cSql += "                               AND BF_LOCAL = '"+MV_PAR02+"' "
		EndIf
		cSql += "                               AND BF_LOCALIZ > '"+IIf(Alltrim(MV_PAR03)=="ZZZZZZZZZZZZZZZ",Space(15),MV_PAR03)+"' "
		cSql += "                               AND BF_LOCALIZ <> 'DOCA' "
		cSql += "                               AND D_E_L_E_T_ = ' ' "
		cSql += "                               GROUP BY BF_FILIAL, BF_LOCAL, BF_LOCALIZ, BF_PRODUTO "

	Else

		cSql += "                                SELECT DB_FILIAL, DB_LOCALIZ, DB_PRODUTO "
		cSql += "                                FROM SDB010 "
		cSql += "                                WHERE DB_FILIAL >       '  ' "

		If cTpExecucao == "P" // Parcial
			cSql += "                             AND DB_DATA     =       '"+cDtUExecP+"' "
			cSql += "                             AND DB_HRINI    BETWEEN '"+cHrUExecP+"' AND '"+cHoraAtu+"' "
		ElseIf cTpExecucao == "C" // Completa
			cSql += "                             AND DB_DATA     =       '"+cDtUExecC+"' "
		EndIf

		cSql += "                                AND DB_LOCALIZ  <>      'DOCA' "
		cSql += "                                AND D_E_L_E_T_  =       ' ' "
		cSql += "                                GROUP BY DB_FILIAL, DB_LOCALIZ, DB_PRODUTO "

	EndIf

Return (cSQl)
*******************************************************************************
Static Function AtuEnderecos()//| Atualizar Endereços
*******************************************************************************

	MsgServer( "Antes de Execucao de atualizacao dos enderecos" )

	DbSelectArea("ENDATU");DbGotop()

	While !Eof()

		If ( ZZ0->(DbSeek( ENDATU->FILIAL + SPACE(02) + ENDATU->ENDERECO, .F.)) )

			If ( ( ENDATU->OCUPACAO <> ZZ0->ZZ0_PEROCU ) .Or. (ZZ0->ZZ0_ESTRUT	<> ENDATU->ESTRUTURA) .Or. (ZZ0->ZZ0_PARTIC <> ENDATU->PARTICOES) )

				RecLock("ZZ0",.F.)
//				ZZ0->ZZ0_ESTRUT	:= ENDATU->ESTRUTURA
				ZZ0->ZZ0_PARTIC	:= ENDATU->PARTICOES
				ZZ0->ZZ0_PEROCU	:= iif (ENDATU->OCUPACAO > 999.99 , 999.99, ENDATU->OCUPACAO)
				MsUnlock()

				MsgServer( "Atulizado Endereco "+Alltrim(ENDATU->ENDERECO)+" UPDATE" )

			EndIF

		Else

			RecLock("ZZ0",.T.)
			ZZ0->ZZ0_FILIAL	:= ENDATU->FILIAL
//			ZZ0->ZZ0_LOCAL  	:= Space(02) //ENDATU->ELOCAL
			ZZ0->ZZ0_LOCALI	:= ENDATU->ENDERECO
			//ZZ0->ZZ0_ESTRUT	:= ENDATU->ESTRUTURA
			ZZ0->ZZ0_PARTIC	:= ENDATU->PARTICOES
			ZZ0->ZZ0_PEROCU	:=  iif (ENDATU->OCUPACAO > 999.99 , 999.99, ENDATU->OCUPACAO)
			MsUnlock()

			MsgServer( "Atulizado Endereco "+Alltrim(ENDATU->ENDERECO)+" NOVO" )

		EndIf

		DbSelectArea("ENDATU")
		DbSkip()

	EndDo

	MsgServer( "Fim da Execucao de atualizacao dos enderecos" )

Return()
*******************************************************************************
Static Function MsgServer(cMemCorp)
*******************************************************************************
	Local cMemCab := "WFOcupacao " + cValToChar(dDatabase) + " " + Substr(Time(),1,5)

	cMsg	:= cMemCab + " - Passo: " + cValToChar(nSeq) + " -> " + cMemCorp + "..."

	Conout( cMsg )

	nSeq += 1

	If cTpExecucao == "M"
		IncProc(cMsg)
	EndIf

Return(cMsg)

// -----------------------------------------------------------------------------------------
// Projeto:
// Modulo :
// Fonte  : WfOcupacaoWMS
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 14/02/14 | Cristiano Machado | Rotina que Define a Ocupação do Endereço.
// ---------+-------------------+-----------------------------------------------------------

*******************************************************************************
User Function ZZ0TABAUX()// mBROWSE Utilizado apenas para criar a Tabela...
*******************************************************************************
	Local cFiltro   		:= ""

	Private cAlias   	:= "ZZ0"
	Private _cCpo 		:= "ZZ0_FILIAL"

	Private cCadastro 	:= "Tabela Auxiliar WMS"
	Private aRotina    	:= {	{"Pesquisar" 	,	"AxPesqui" 	, 0, 1 },;
		{"Visualizar"	,	"AxVisual"   	, 0, 2 },;
		{"Incluir" 	,	"AxInclui"   	, 0, 3 },;
		{"Excluir"  	,	"AxExclui"   	, 0, 5 }}

	dbSelectArea("ZZ0");dbSetOrder(1)

	mBrowse( ,,,,"ZZ0",,,,,,,,,,,,,,)

RETURN NIL

Return()
