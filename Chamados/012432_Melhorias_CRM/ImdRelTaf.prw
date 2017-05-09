#Include 'Totvs.ch'
#Include "Protheus.ch"

#Define _NORMAL 1 //1->Normal Opções de exibição da janela da aplicação executada:
/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : ImdRelTaf   | AUTOR : Cristiano Machado  | DATA : 04/11/2016   **
**---------------------------------------------------------------------------**
** DESCRIÇÃO: Relatorio Tarefas de Vendedor (AD8)                            **
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
User function ImdRelTaf()
*******************************************************************************
	Private oProcess 	:= Nil
	Private cCodUser	:= RetCodUsr()

	PreparaVar() //| Prepara/Inicializa Todas as Variaveis Utilizadas

	If !Valida()//| Valida se a Execucao e possivel
		Return()
	EndIF

	oProcess := MsNewProcess():New( {|lEnd| ObtDados(@oProcess, @lEnd)} , "Obtendo Dados... ", "", .T. )
	oProcess:Activate()
	//| Obtem Dados do Relatorio em Tabela Auxiliar

	oProcess := MsNewProcess():New( {|lEnd| ExpDados(@oProcess, @lEnd)} , "Exportando Resultado... ", "", .T. )
	oProcess:Activate()
	//| Exporta os Dados para CSV

Return()
*******************************************************************************
Static Function Valida()//| Valida se a Execucao e possivel
*******************************************************************************
	Local lVal 		:= .T.
	Local nNvlVen	:=  0
	Local aAreaSA3	:= SA3->(GetArea())
	
	Pergunte( "IRELTF"   , .T. ) // Parametros do Relatorio

	If Type("MV_PAR03") == "A"
		lVal := .F.
	EndIf

	If Empty(SA3->A3_CODUSR)
		lVal := .F.
		Iw_MsgBox("Vendedor sem Codigo de Usuario relacionado ao seu Cadastro !!!","Cadastro de Vendedores","ALERT")
	EndIf

	//| Verifica se o Usuario pode ver todos os vendedores da filial
	nNvlVen := Val(Posicione("SA3",7,xFilial("SA3")+cCodUser,"A3_NVLVEN"))
	If nNvlVen >= 3 //| [1-INTERNO, 2-EXTERNO, 3-COORDENADOR, 4-CHEFE, 5-GERENTE, 6-DIRETOR]
		lVerTodos := .T.
		cFilTodos := xFilial("AD8")	
	EndIf

	RestArea(aAreaSA3)
	
Return(lVal)
*******************************************************************************
Static Function PreparaVar()//| Prepara/Inicializa Todas as Variaveis Utilizadas
*******************************************************************************

	_SetOwnerPrvt( 'cTab'		, "TREP"	) //| Nome da Tabela auxiliar resultado da Query |
	_SetOwnerPrvt( 'lShowSql' 	, .F.		) //| Se mostra o SQL antes de envio ao Banco |
	_SetOwnerPrvt( 'lVerTodos'	, .F.       ) //| Indica se o usuario tem acesso para ver todos os vendedores
	_SetOwnerPrvt( 'cFilTodos'	, "00"      ) //| indica a filial a ser filtrada no caso de relatorio com todos os vendedores

Return()
*******************************************************************************
Static Function ObtDados()//| Obtem Dados do Relatorio em Tabela Auxiliar
*******************************************************************************
	Local cSql := ""

	cSql += "SELECT AD8_TAREFA TAREFA,AD8_TOPICO ASSUNTO,AD8_NROPOR OPORTUNIDADE,AD8_DTINI INICIO,AD8_DTFIM TERMINO,AD8_DTREMI LEMBRETE, "
	cSql += "      CASE  "
	cSql += "        WHEN AD8_STATUS = '1' THEN 'NAO INICIADA' "
	cSql += "        WHEN AD8_STATUS = '2' THEN 'EM ANDAMENTO' "
	cSql += "        WHEN AD8_STATUS = '3' THEN 'COMPLETADA' "
	cSql += "        WHEN AD8_STATUS = '4' THEN 'SUSPENCA' "
	cSql += "        WHEN AD8_STATUS = '5' THEN 'ENCERRADA' "
	cSql += "        ELSE 'INDEFINIDA' "
	cSql += "      END SITUACAO, "
	cSql += "      CASE  "
	cSql += "        WHEN AD8_PRIOR = '1' THEN 'BAIXA' "
	cSql += "        WHEN AD8_PRIOR = '2' THEN 'NORMAL' "
	cSql += "        WHEN AD8_PRIOR = '3' THEN 'ALTA' "
	cSql += "      END PRIORIDADE, "
	cSql += "      AD8_PERC COMPLETO, "
	cSql += "      CASE  "
	cSql += "        WHEN AD8_CODCLI > ' ' THEN 'C:' || AD8_CODCLI || '.' || AD8_LOJCLI || '-' || SA1.A1_NOME "
	cSql += "        WHEN AD8_PROSPE > ' ' THEN 'P:' || AD8_PROSPE || '.' || AD8_LOJPRO || '-' || SUS.US_NOME "
	cSql += "        ELSE 'NAO INFORMADO' "
	cSql += "      END ENTIDADE, "
	cSql += "      NVL(AD8_COMENTARIO, ' ') COMENTARIO "

	cSql += "FROM AD8010 AD8 LEFT JOIN "
	cSql += "    ( SELECT YP_CHAVE, LISTAGG(REPLACE(TRIM(YP_TEXTO),'\13\10',' '), ' ') "
	cSql += "      WITHIN GROUP (ORDER BY YP_SEQ) AD8_COMENTARIO "
	cSql += "      FROM SYP010  "
	cSql += "      WHERE D_E_L_E_T_ = ' ' "
	cSql += "      GROUP BY YP_CHAVE) COM "
	cSql += "ON  AD8.AD8_CODMEM = COM.YP_CHAVE "

	cSql += "	LEFT JOIN SA1010 SA1 "
	cSql += "ON  AD8_CODCLI = SA1.A1_COD "
	cSql += "AND AD8_LOJCLI = SA1.A1_LOJA "

	cSql += "   LEFT JOIN SUS010 SUS  "
	cSql += "ON  AD8.AD8_PROSPE = SUS.US_COD "
	cSql += "AND AD8.AD8_LOJPRO = SUS.US_LOJA "
	//cSql += "      SA3010 SA3 "

	cSql += "LEFT JOIN SA3010 SA3 "
	cSql += "ON  SA3.A3_CODUSR = AD8.AD8_CODUSR "

	cSql += "WHERE AD8.D_E_L_E_T_ = ' ' "
	If !Empty(cValToChar(DtoS(MV_PAR01)))
		cSql += "AND AD8.AD8_DTINI >= '"+DtoS(MV_PAR01)+"' "
	EndIF
	If !Empty(cValToChar(DtoS(MV_PAR02)))
		cSql += "AND AD8.AD8_DTFIM <= '"+DtoS(MV_PAR02)+"' "
	EndIf
	If !Empty(MV_PAR03)
		cSql += "AND AD8.AD8_STATUS IN ("+PVV(MV_PAR03)+") "
	EndIf
	If !Empty(MV_PAR04)
		cSql += "AND AD8.AD8_PRIOR  IN ("+PVV(MV_PAR04)+") "
	EndIf
	If !Empty(cValToChar(DtoS(MV_PAR05))) .And. !Empty(cValToChar(DtoS(MV_PAR06)))
		cSql += "AND AD8.AD8_DTREMI BETWEEN '"+DtoS(MV_PAR05)+"' AND '"+DtoS(MV_PAR06)+"' "
	EndIF

	cSql += "AND AD8.AD8_CODCLI BETWEEN '"+(MV_PAR07)+"' AND '"+(MV_PAR08)+"' "
	cSql += "AND AD8.AD8_PROSPE BETWEEN '"+(MV_PAR09)+"' AND '"+(MV_PAR10)+"' "

	If lVerTodos  // Pode ver todos....
		cSql += "AND AD8.AD8_FILIAL = '"+cFilTodos+"' "
		cSql += "AND SA3.A3_COD 	BETWEEN '"+(MV_PAR11)+"' AND '"+(MV_PAR12)+"' "
	Else
		cSql += "AND AD8.AD8_CODUSR = '"+SA3->A3_CODUSR+"' "
	EndIf

	cSql += "AND SA3.D_E_L_E_T_ = ' ' "

	cSql += "ORDER BY AD8.AD8_TAREFA "

	U_ExecMySql(cSql, cTab    , "Q"  , lShowSql, .F. )

	TCSetField ( cTab, "INICIO"  , "D", 8, 0 )
	TCSetField ( cTab, "TERMINO" , "D", 8, 0 )
	TCSetField ( cTab, "LEMBRETE", "D", 8, 0 )

Return()
*******************************************************************************
Static Function ExpDados()//| Exporta os Dados para CSV
*******************************************************************************

	Local lHeader			:= .T.
	Local aArrayTab			:= {}

	Local cDelimitador		:= ';'
	Local cPath				:= GetTempPath()

	Local cFileOK			:= ''
	Local cDrive			:= Nil
	Local cDir				:= Nil
	Local cNome				:= Nil
	Local cExt				:= Nil

	aArrayTab 	:= U_TabToArray( cTab, lHeader )
	cFileOK		:= U_ArrayToFCsv( aArrayTab , cPath, cNome, cDelimitador )

	SplitPath( cFileOK, @cDrive, @cDir, @cNome, @cExt )

	ShellExecute("Open", cFileOK, "", cDrive+cDir , _NORMAL )

Return()
*******************************************************************************
Static Function PVV(cConteudo)//| Converte Separador ; para ,
*******************************************************************************

	cConteudo := StrTran(cConteudo,';',',')+'0'

Return(cConteudo)