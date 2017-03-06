#INCLUDE "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
#INCLUDE 'tbiconn.ch'
#Include "rwmake.ch"
#Include "TXL.Ch"

#DEFINE X_NOME_GER   1
#DEFINE X_COD_GER    2
#DEFINE X_TIPO       3
#DEFINE X_GRUPO      4
#DEFINE X_DESCRI     5
#DEFINE X_VALOR      6
#DEFINE X_PERCENT    7

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫FUNCAO    ≥IMDC021   ∫Autor  ≥Marcio Q.Borges     ∫ Data ≥             ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Monta um arquivo com as Metas On-Line e envia por e-mail.   ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥SIGATMK  - Metas On-Line Modelo II (Por Gerente)            ∫±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ PROGRAMADOR  ≥ DATA   ≥ BOPS ≥MOTIVO DA ALTERACAO                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Marcio Borges ≥25/08/05≥      ≥ - Carga de Gerente Ò definido e Total, ≥±±
±±≥				 ≥		  ≥      ≥   	mostrar no inicio do arquivo	  ≥±±
±±≥				 ≥		  ≥	     ≥ - Adicionar opÁ„o "Considera o Dia"    ≥±±
±±≥              ≥        ≥      ≥ - Verificar as percentagens dos totais ≥±±
±±≥				 ≥30/11/05≥      ≥ - Compatibilizado query de devoluÁıes  ≥±±
±±≥              ≥        ≥      ≥ com o relatorio Fat. Vendedor (matr580)≥±±
±±≥              ≥01/12/05≥      ≥ - Alterado Filtro de Gerentes para Ò   ≥±±
±±≥              ≥        ≥      ≥  buscar do SA1 e sim do SC5            ≥±±
±±≥Marcio Borges ≥31/01/07≥      ≥ - Controla usu·rios que podem rodar    ≥±±
±±≥              ≥        ≥      ≥ conforme par.: USRIMDC021 e MV_IMDC021 ≥±±
±±≥Marcio Borges ≥24/04/08≥AAZNZ8≥ - Metas on-line via workflow           ≥±±
±±≥Jorge Oliveira≥21/12/10≥AAZTCP≥ - Nao podem aparecer movimentacoes de  ≥±±
±±≥              ≥        ≥      ≥   Clientes com Gerente igual ao parame-≥±±
±±≥              ≥        ≥      ≥   tro MV_FILGMOL                       ≥±±
±±≥Agostinho Lima≥22/08/14≥      ≥ - Alterada logica para enviar o email  ≥±±
±±≥              ≥        ≥      ≥   para os gerentes separados.          ≥±±
±±≥              ≥        ≥      ≥                                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
*********************************************************************
User Function IMDC021()
	*********************************************************************
	Local nNumSeq, aPasta
	Local aStruct, cArq, nI
	Local cPathCompleto
	Local cExecExcel
	Local cPathRoot := "\mol\"
	Local nXcont := 1
	Local nYcont := 1
	Local nZcont := 1
	Local aColsTot :=  {}
	Local aCodGere :=  {}
	Local aColsGer :=  {}
	Local aHrMORet :=  {}

	Private aheader
	Private aCols
	Private aNome_Ger   // Esta filial representa o total geral
	Private aCodGer
	Private aMAILGer
	Private recSM0
	Private aDiasPass
	Private aDiasRest
	Private aMetaFil
	Private aMetaGer
	Private aMetaTri
	Private _cglobger
	Private dDataConsiderada
	Private dataIni
	Private datafim
	Private cData1
	Private cData2
	Private cNomProg := " Metas On - Line II "
	Private lTeste	  := .F.
	Private lViaWorkFlow
	Private aHtmlObsEmail 	:= {}
	Private cHtml 				:= " "
	Private cFilGerente := "" // Filtrar os Gerentes que estao nessa variavel, para nao apresentar no relatorio
	Private lCaptura := .F.

	Private cDtTriIni
	Private cDtTriFim

	Conout( cNomProg + " -  TESTE - Preparando Environment")

	IF Type("dDatabase") == "U" // Se rodado via workflow a vari·vel dDatabase estara disponivel somente apos o Prepare Environment
		lViaWorkFlow := .T.
	ELSE
		lViaWorkFlow := .F.
	EndIf

	IF lViaWorkFlow
		cEmp := '01'
		cFil := '09'

		Conout( cNomProg + " -  VIA WORKFLOW - Preparando Environment")
		PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil FUNNAME 'FCLIENTE'  TABLES 'SM0','SF4','SD2', 'SB2'

		IF DATAVALIDA(dDatabase,.T.) <> dDatabase  // 29/12/2015 - Agostinho - Feriados e final de semana nao deve executar
			RETURN()
		ENDIF

	ELSE
		Conout( cNomProg + " -  VIA MENU    - Preparando Environment ")
	EndIf

	IF lViaWorkFlow
		Private	MV_PAR01
		Private	MV_PAR02
		Private	MV_PAR03
		Private	MV_PAR04
		Private	MV_PAR05
	EndIf

	cPathCompleto  		:= Getmv("MV_DIRMOL")
	cExecExcel 	   		:= Getmv("MV_EXCEL")
	cFilGerente    		:= Getmv("MV_FILGMOL")
	aHrMORet        := &(Getmv("MV_HRMORET"))

	aheader 			:= {}
	aCols   	 		:= {}
	aNome_Ger    		:= {}    // Esta filial representa o total geral
	aCodGer     		:= {}
	aMAILGer			:= {}

	aCodMAIGer    		:= {}

	recSM0         		:= SM0->( Recno() )
	aDiasPass 	   		:= {}
	aDiasRest 	   		:= {}
	aMetaFil 	   		:= {}
	aMetaGer 	   		:= {}
	aMetaTri			:= {}
	_cglobger 	   		:= ""

	//| Parametro Para Rodar Retroativo
	If !Empty(Alltrim(GetMv("MV_DTWORKF")))
		dDatabase := Stod(GetMv("MV_DTWORKF"))
	Endif

	If (Time() >= aHrMORet[1] .AND. Time() <= aHrMORet[2]) // Executa no horario especificado no parametro com data retroativa - Agostinho 26/11/2016

		If DOW(DATE()) = 2
			dDatabase := dDatabase - 3
		Else
			dDatabase := dDatabase - 1
		Endif

	Endif

	dDataConsiderada 	:= ddatabase

	//| Monta as Datas do RelatÛrio
	dataIni 				:= DTOS(FirstDay(dDataConsiderada))
	datafim 				:= Dtos( dDataConsiderada -1 )
	cData1  				:= DTOS(FirstDay(dDataConsiderada))
	cData2  				:= DTOS( LastDay(dDataConsiderada))

	//| Analista: Cristiano Machado - Chamado: 14677 - Data 03/03/2017
	MontaDtTri(dDataConsiderada,@cDtTriIni,@cDtTriFim ) //| Monta as Datas para serem usadas nas Selecoes de Trimestres Trimestres

	ExisteSXB_A3M()//| Verifica a existÍncia da consulta padr„o A3M E PARAMETRO, se n„o existir, cria

	CAMPOS()//| Campos que Definem a Filial e o Gerente, para estruturaÁ„o do RelatÛrio...

	// SELECIONA OS GERENTES PARA AS PERGUNTAS
	IF lViaWorkFlow
		GERENTES() //| Seleciona os vendedores considerados Gerentes atravÈs do cadastro de clientes, campo A1_GERVEN
	ELSE
		MsAguarde( {|| GERENTES() },cNomProg,"Selecionando Gerentes para as Perguntas...") //| Seleciona os vendedores considerados Gerentes atravÈs do cadastro de clientes, campo A1_GERVEN
	EndIf

	//| Concatena os Codigos de Gerentes apartir do arquivo de trabalho.... EX: 000276/000327/000458/000506/000852/000910/010016/010121
	_cglobger := ""

	DO WHILE !EOF()
		_cglobger += _G0->COD_GER + "/"

		dbSkip()
	Enddo

	_cglobger := Left(_cglobger,Len(_cglobger)-1)

	DbselectArea("SX6")
	IF DBSEEK(xFilial("SX6")+"MV_GERENTE") //| Salva informaÁ„o....
		Reclock("SX6",.F.)
		SX6->X6_CONTEUD := _cglobger
		MsUnLock()
	EndIf

	Perg()//| Chama as Perguntas...

	If !Pergunte( 'IMDCXXXXXX', .T. ) .AND. !lViaWorkFlow
		Return NIL
	EndIf

	IF lViaWorkFlow
		Conout( cNomProg + " -  Processando Metas On-Line")
		Executar()//| FunÁ„o Principal do RelatÛrio...
	ELSE

		If MsgYesNo( 'Confirma processamento?', 'Metas on-line' )

			// realiza o processamentoo para selecao dos registros
			Processa( {||Executar()}, "Aguarde...","Processando Metas On-Line" )//| FunÁ„o Principal do RelatÛrio...

			If MV_PAR04 == 1	// exibe em tela

				// define a tela
				@ 74,9 To 512,936 Dialog mkwdlg Title OemToAnsi("Visualiza Metas On-line")//512,780
				@ 4,4 Button OemToAnsi("_Sair")       Size 36,16 Action  Close(mkwdlg )
				@ 07,57 To 210,454 MultiLine  VALID .T. OBJECT objMetas //210,378
				Activate Dialog mkwdlg CENTER
			Else 				// grava em arquivo para o Excel

				// Define nome do arquivo
				nNumSeq := 1
				aPasta := Directory(cPathRoot+"*.xls")
				aSort(aPasta,,,{|x,y| x[1] > y[1] }) //coloca em ordem  vetor aPasta asort(vetor,inicio, quanidade,ordem)
				for nI := 1 to Len(aPasta)
					If Upper(Left(aPasta[nI,1],5)) == "MOL"+cEmpAnt
						nNumSeq := Val(SubStr(aPasta[nI,1],6)) + 1
						Exit
					EndIf
				next

				IF Select('MOL') <> 0
					MOL->( DbCLoseArea() )
				END

				cArq := "mol"+cEmpAnt+strzero(nNumSeq,3)+".xls"

				//| Monta Estrutura do Arquivo Principal de Trabalho
				aStruct := {{"FILIAL"    , "C" , 20 , 0 },;
				{"COD_GER"   , "C" , TamSx3("A3_COD" )[1] , 0 },;
				{"NOME_GER"  , "C" , TamSx3("A3_NOME")[1] , 0 },;
				{"TIPO"      , "C" , 5  , 0 },;
				{"GRUPO"     , "C" , 20 , 0 },;
				{"DESCRICAO" , "C" , 30 , 0 },;
				{"VALOR"     , "N" , 14 , 2 },;
				{"Perc"      , "N" , 6  , 2 } }

				carqtrab := CRIATRAB(aStruct,.T.)

				USE &cArqtrab ALIAS 'MOL' NEW

				// Grava os campos
				For nI := 1 To Len( aCols )
					Reclock("MOL",.T.)

					MOL->COD_GER	:= aCols[ nI, X_COD_GER  ]
					MOL->NOME_GER	:= aCols[ nI, X_NOME_GER ]
					MOL->TIPO		:= aCols[ nI, X_TIPO     ]
					MOL->GRUPO		:= aCols[ nI, X_GRUPO    ]
					MOL->DESCRICAO	:= aCols[ nI, X_DESCRI   ]
					MOL->VALOR		:= aCols[ nI, X_VALOR    ]
					MOL->Perc		:= aCols[ nI, X_PERCENT  ]

					MsUnlock()
				Next

				CARQEXCEL = cPathCompleto+cArq
				Send2Excel()
				dbCloseArea()
			EndIf

		EndIf
	EndIf

	IF lViaWorkFlow    // Agostinho - 22/008/2014 Alterada logica para enviar o email para os gerentes separados

		aColsTot :=  aCols

		FOR nZcont:= 1 TO LEN(aCodGer)
			IF !EMPTY(aCodGer[nZcont]) .AND. aCodGer[nZcont] <> "XXXXXX"
				aAdd(aCodGere,aCodGer[nZcont])
			EndIf
		NEXT

		FOR nXcont:= 1 TO LEN(aCodGere)

			aColsGer:= {}

			FOR nYcont:= 1 TO LEN(aColsTot)

				IF aColsTot[nYcont][2] = aCodGere[nXcont] .OR. aColsTot[nYcont][2] = "XXXXXX"
					AADD(aColsGer,aColsTot[nYcont])
				EndIf

			NEXT

			IF nXcont = 1
				GeraEmail(aColsTot)
				EnviaEmail("T","")
			EndIf

			GeraEmail(aColsTot)//Monta HTML para envio

			EnviaEmail("G",aCodGere[nXcont])// Envia o Email

		NEXT

		//	CONOUT( 'WFUDPMPC ' + APARAM[ 1, NPARAM ] + '/' + APARAM[ 2, NPARAM ] + ' - JOB EXECUTADO COM SUCESSO...' )
		CONOUT( cNomProg + '-  JOB EXECUTADO COM SUCESSO...' )
		RESET ENVIRONMENT
	EndIf

	Return NIL
	*******************************************************************************
Static Function GERENTES()//| Seleciona os vendedores considerados Gerentes atravÈs do cadastro de clientes, campo A1_GERVEN
	*******************************************************************************

	// BUSCA GERENTES ATRAVES DOS ATENDIMENTOS
	//CHAMADO: AAZO9M

	cQuery := "SELECT  UA_GERVEN COD_GER "
	cQuery += "    FROM  " + RetSqlName("SUA")
	cQuery += "   WHERE UA_GERVEN <> '      ' "

	// Jorge Oliveira - 21/12/2010 - Nao mostra movimentacoes de Clientes para esse Gerente
	// Exemplo da variavel cFilGerente := '000207', '000467'
	// Exemplo da variavel cFilGerente := ''
	cQuery += "     AND UA_GERVEN NOT IN (" + cFilGerente + ") "

	cQuery += "     AND UA_EMISSAO >= '"+cData1+"'"
	cQuery += "     AND UA_EMISSAO <= '"+cData2+"'"
	cQuery += "     AND D_E_L_E_T_ = ' ' "
	cQuery += "GROUP BY UA_GERVEN "
	cQuery += "ORDER BY UA_GERVEN "

	U_ExecMySql(cQuery, '_G0', "Q", lCaptura)

	dbSelectArea('_G0')
	DBGOTOP()

	Return()
	*******************************************************************************
Static Function Send2Excel()
	*******************************************************************************

	LOCAL oExcel, oSheet, oSelection, oWin, oDlg, oMeter, oClp, oWorkBook
	LOCAL cRange     := ""
	LOCAL nSheets    := 0
	LOCAL n          := 0
	LOCAL nPos       := 0
	LOCAL nRow       := 0
	LOCAL nTotal     := mol->( lastrec() )
	LOCAL nHeaderRow := 4               // line number of table header descriptions
	LOCAL nDataStart := nHeaderRow + 1  // line number where table data begin

	DEFINE DIALOG oDlg NAME "TO_EXCEL"

	ACTIVATE DIALOG oDlg CENTERED NOWAIT

	// start Excel with empty workbook
	oExcel    := TOleAuto():New( "Excel.Application" )
	oWorkBook := oExcel:WorkBooks:Add()

	// If your Excel is configured to start with more than one empty sheet,
	// delete all sheets, except the first one with the following
	nSheets := oExcel:Sheets:Count()

	// set Excel to operate quiet
	// otherwise you'll be asked when deleting sheets
	oExcel:Set( "DisplayAlerts", .f. )

	for n := 1 to nSheets - 1
		oExcel:Worksheets( n ):Delete()
	next

	mol->( DbGoTop() )

	// select actual Excel sheet
	oSheet := oExcel:Get( "ActiveSheet" )

	// set name of Excel sheet into the bottom tab
	oSheet:Name := "Metas On Line "

	// select actual Excel window
	oWin := oExcel:Get( "ActiveWindow" )

	// mark cell "A" in start row as selected
	oSheet:Cells( nDataStart, 1 ):Select()

	// now set Excel window 'freezed' at cell "A5"
	oWin:Set( "FreezePanes", .t. )

	// Set Font parameters for all cells of actual work sheet
	oSheet:Cells:Font:Size := 10
	oSheet:Cells:Font:Name := "Arial"

	// set Font parameters and text for certain cells which have to appear different
	oSheet:Cells( 1, 1 ):Font:Size := 12
	oSheet:Cells( 1, 1 ):Font:Bold := .t.
	oSheet:Cells( 1, 1 ):Value     := "Customer Listing"

	oSheet:Cells( 2, 1 ):Font:Size := 10
	oSheet:Cells( 2, 1 ):Font:Bold := .F.
	oSheet:Cells( 2, 1 ):Value     := "List of sold items"

	nRow := nHeaderRow

	do while !mol->( eof() )

		// for each record of wrk
		++nRow

		// put data into clipboard works faster than writing
		// directly into cells like 'oSheet:Cells( x, y ):Value := xyz
		// seperate values with 'TAB' ->  chr( 9 )
		oClp:SetText( str( nRow - nHeaderRow, 4, 0 ) + "."      + chr( 9 ) + ;
		MOL->NOME_GER                             + chr( 9 )  )

		oSheet:Cells( nRow, 1 ):Select()
		oSheet:Paste()
		oClp:Clear()

		SysRefresh()

		mol->( DbSkip() )
		SysRefresh()
	enddo

	oSheet:Cells( nDataStart, 1 ):Select()

	oWorkBook:SaveAs( "c:\IMDC021.xls" )

	// don't forget to clear the clipboard
	oClp:Clear()
	oClp:End()

	oExcel:Quit()

	oSelection:End()
	oSheet:End()

	oExcel:End()
	oDlg:End()

	RETURN( NIL )
	*******************************************************************************
Static Function Executar()//| FunÁ„o Principal do RelatÛrio...
	*******************************************************************************
	Private diferenca
	Private yfilial
	Private aDevDia := {}
	Private aDevMes := {}
	Private aDevTri := {}
	Private nPos    := 0
	Private nPosDev := 0
	Private LENnome := 16 //| Tamanho do Nome do Gerente
	Private nDecSD2 := TamSx3("D2_TOTAL")[2]
	Private cFilImd

	ProcRegua( 20 )

	*******************************************************************************
	IncProc("Processando Metas On-Line "+" - Carga de Gerentes")
	*******************************************************************************
	Conout( cNomProg + " - Carga de Gerentes")

	cQuery := "SELECT SA3.A3_COD COD_GER, SA3.A3_DESCMOL NOME_GER, SA3.A3_CODFIL FILIAL_GER, SA3.A3_EMAIL EMAIL"
	cQuery += "    FROM "+RetSqlName("SA3")+" SA3 " //+"," +RetSqlName("SUA")+" SUA"
	cQuery += "   WHERE "
	cQuery += " '" + GETMV('MV_GERENTE') + "' LIKE  '%'||SA3.A3_COD||'%' "
	cQuery += "     AND SA3.A3_COD >= '" + MV_PAR01 + "'"
	cQuery += "     AND SA3.A3_COD <= '" + MV_PAR02 + "'"
	cQuery += "     AND SA3.D_E_L_E_T_ <> '*'"
	cQuery += "GROUP BY SA3.A3_COD, SA3.A3_DESCMOL, SA3.A3_CODFIL,SA3.A3_EMAIL "
	cQuery += "ORDER BY SA3.A3_DESCMOL "

	//cQuery += "ORDER BY SA3.A3_COD "

	U_ExecMySql(cQuery, "_G1", "Q", lCaptura)

	// Tamanho do aheader din‚mico, define as colunas que aparecerao na consulta
	aAdd(aHeader,{ "Nome Gerente  " , "A1_NOME" 	,                 ""	,LENnome+1 				,  0,  ".F.", " ",  "C",  "SA1"    } )
	aAdd(aHeader,{ "CÛdigo Gerente" , "A1_COD"   	,                 ""	,(TamSx3("A3_COD" )[1]) ,  0,  ".F.", " ",  "C",  "SA1"    } )
	aAdd(aHeader,{ "Tipo     "   	, "A1_FILIAL"  	,                 ""	,    02					,  0,  ".F.", " ",  "C",  "SA1"    } )
	aAdd(aHeader,{ "Grupo    "  	, "A1_NOME"    	,                 ""	,    17					,  0,  ".F.", " ",  "C",  "SA1"    } )
	aAdd(aHeader,{ "Descricao"  	, "A1_NOME"    	,                 ""	,    22					,  0,  ".F.", " ",  "C",  "SA1"    } )
	aAdd(aHeader,{ "Valor"      	, "C6_TOTAL"   	,"@E 99,999,999,999.99"	,    12					,  2,  ".F.", " ",  "C",  "SC6"    } )
	aAdd(aHeader,{ "(%)"        	, "A3_COMIS"  	,       "@EZ 999.99"	,     5					,  2,  ".F.", " ",  "N",  "SA3"    } )
	aAdd(aHeader,{ " "          	, "A1_FILIAL"  	,                 ""	,    02					,  0,  ".F.", " ",  "C",  "SA1"    } )

	// Adiciona ‡ carga de gerentes, o "Total" para o inicio do acols
	aAdd( aNome_Ger	,"Total")
	aAdd( aCodGer	,REPLICATE("X",TamSx3("A3_COD" )[1]) )

	// Adiciona ‡ carga de gerentes, o "Gerente n„o Definido"  para o inicio do acols
	//edi	aAdd( aNome_Ger	,"Gerente n„o Definido")
	//edi	aAdd( aCodGer	,REPLICATE(" ",TamSx3("A3_COD" )[1]) )

	// AtualizaÁıes de dias ˙teis por gerente  e codigo+gerente
	dbSelectArea('_G1');DbGoTop()
	DO WHILE !EOF()

		// ARRRAY GERENCIA
		aAdd( aNome_Ger		,_G1->NOME_GER	)
		aAdd( aCodGer		,_G1->COD_GER	)
		aAdd( aMAILGer		,_G1->EMAIL		)

		aAdd( aCodMAIGer	,{_G1->COD_GER,_G1->EMAIL})

		//ARRAY DIAS
		// atualiza array com dias restantes e dias passados
		cFilialGerenteAtual := _G1->FILIAL_GER
		IF EMPTY(cFilialGerenteAtual)
			cMsgOBS := "Verifique no cadastro de Vendedores (SA3), campo Filial do Vendedor (A3_CODFIL) para o gerente ' ";
			+ _G1->COD_GER + "  " +  ALLTRIM(_G1->NOME_GER)  + " ' pois n„o existe dado cadastrado para o mesmo. Isto ";
			+ "influenciar· no c·lculo dos dias ˙teis ! "

			IF lViaWorkFlow
				Conout( cNomProg + " - " + cMsgOBS )
				AADD(aHtmlObsEmail,  " - " + cMsgOBS)

			ELSE
				ALERT(cMsgOBS)
			EndIf

		EndIf

		// atualiza array com dias restantes e dias passados para a OS GERENTES
		aAdd(aDiasPass,{_G1->COD_GER,u_diasUteis( dDataConsiderada,cFilialGerenteAtual ) } )
		aAdd(aDiasRest,{_G1->COD_GER,u_diasUteis(LastDay( dDataConsiderada),cFilialGerenteAtual) - aDiasPass[Len(aDiasPass),2] } )

		// atualiza array com dias restantes e dias passados para a o TOTALIZADOR XXXXX, utilizado para calc. da percentg tipo '12'
		// CONSIDERADO A FILIAL 05 PARA O 'XXXX'
		aAdd(aDiasPass,{REPLICATE("X",TamSx3("A3_COD" )[1]),u_diasUteis( dDataConsiderada,'05' ) } )
		aAdd(aDiasRest,{REPLICATE("X",TamSx3("A3_COD" )[1]),u_diasUteis(LastDay( dDataConsiderada),'05') - aDiasPass[Len(aDiasPass),2] } )

		// CONSIDERADO A FILIAL 05 PARA O '    '
		aAdd(aDiasPass,{REPLICATE(" ",TamSx3("A3_COD" )[1]),u_diasUteis( dDataConsiderada,'05' ) } )
		aAdd(aDiasRest,{REPLICATE(" ",TamSx3("A3_COD" )[1]),u_diasUteis(LastDay( dDataConsiderada),'05') - aDiasPass[Len(aDiasPass),2] } )

		//C·lculo do aheader Din‚mico
		IF LENnome < LEN(ALLTRIM(_G1->NOME_GER))
			LENnome := LEN(ALLTRIM(_G1->NOME_GER))
		EndIf
		dbSkip()
	ENDDO

	*******************************************************************************
	IncProc("Processando Metas On-Line "+" - Carga de Filiais") // Carga das filiais
	*******************************************************************************
	Conout( cNomProg + " - Carga de Filiais")

	// Carga das filiais
	dbSelectArea('SM0');dbSetOrder(1)
	dbSeek(cEmpAnt,.T.)
	cFilImd := ""
	While SM0->M0_CODIGO == cEmpAnt .and. !EOF()
		cFilImd += "'" + SM0->M0_CODFIL + "',"

		dbSkip()
	Enddo
	cFilImd := Left(cFilImd,Len(cFilImd)-1)  //retira o ultimo caracter da string, no caso a "," do final

	dbGoto( recSM0 )

	*******************************************************************************
	IncProc("Processando Metas On-Line "+" - Consultado e Ofertado")// Consultado e Ofertado...
	*******************************************************************************
	Conout( cNomProg + " - Consultado e Ofertado")

	// Define o Tipo do Consultado e Oferta... Antes Tipo 1 -> 09/2006 , Tipo 2 -> 09/2006 e Tipo 3 -> Aparir 10/2006
	IF substr(DTOS(dDataConsiderada),1,6) <  '200609'
		cTpCeO := '1'
	ELSEIF substr(DTOS(dDataConsiderada),1,6) ==  '200609' // MES DA VIRADA DO CONSULTADO E OFERTADO
		cTpCeO := '2'
	ELSE
		cTpCeO := '3'
	EndIf

	cQuery := ""

	IF cTpCeO == '2'
		cQuery += "SELECT GERENTE, SUM(VLRITEM) VLRITEM ,SUM(VOFERT) VOFERT "
		cQuery += "FROM ( ( "
	EndIf

	IF cTpCeO == '1' .OR. cTpCeO =='2'
		cQuery += "SELECT   UA_GERVEN GERENTE, SUM (ROUND (UB_VRCACRE * UB_QCONSUL, 2)) VLRITEM, "
		cQuery += "         SUM (UB_VOFERT) VOFERT "
		cQuery += "    FROM SUB010 SUB, SUA010 SUA "
		cQuery += "   WHERE SUA.UA_FILIAL IN ( " + cFilImd + " ) "

		// Jorge Oliveira - 21/12/2010 - Nao mostra movimentacoes de Clientes para esse Gerente
		// Exemplo da variavel cFilGerente := '000207', '000467'
		// Exemplo da variavel cFilGerente := ''
		cQuery += "     AND UA_GERVEN NOT IN (" + cFilGerente + ") "

		cQuery += "     AND SUA.D_E_L_E_T_ = ' ' "
		cQuery += "     AND SUB.D_E_L_E_T_ = ' ' "
		cQuery += "     AND SUA.UA_FILIAL = SUB.UB_FILIAL "
		cQuery += "     AND SUA.UA_NUM = SUB.UB_NUM "
		//CHAMADO: AAZO9M
		cQuery += "     AND SUA.UA_CANC <> 'S' AND SUB.UB_FLAGCON = 'S' "
		cQuery += "     AND SUA.UA_STATUS <> 'CAN' "
		//	cQuery += "     AND SUA.UA_EMISSAO = '" + DTOS(dDataConsiderada) + "' "
		//CHAMADO: AAZO9M
		cQuery += "     AND SUB.UB_DTNECLI = '" + DTOS(dDataConsiderada) + "' "

		cQuery += "GROUP BY UA_GERVEN"
	EndIf
	IF cTpCeO == '2'
		cQuery += ")"
		cQuery += "UNION ALL"
		cQuery += "( "

	EndIf
	IF cTpCeO == '3' .OR. cTpCeO =='2'

		cQuery += "SELECT   UA_GERVEN GERENTE, SUM (ROUND (ZA0_PRECO * ZA0_QUANTD, 2)) VLRITEM, "
		cQuery += "         SUM (ZA0_VOFERT) VOFERT "
		cQuery += "    FROM  SUA010 SUA, ZA0010 ZA0 "
		cQuery += "   WHERE SUA.UA_FILIAL IN ( " + cFilImd + " )

		// Jorge Oliveira - 21/12/2010 - Nao mostra movimentacoes de Clientes para esse Gerente
		// Exemplo da variavel cFilGerente := '000207', '000467'
		// Exemplo da variavel cFilGerente := ''
		cQuery += "     AND UA_GERVEN NOT IN (" + cFilGerente + ") "

		cQuery += "     AND SUA.D_E_L_E_T_ = ' ' "
		cQuery += "     AND ZA0.D_E_L_E_T_ = ' ' "
		cQuery += "     AND SUA.UA_FILIAL = ZA0.ZA0_FILIAL "
		cQuery += "     AND SUA.UA_NUM = ZA0.ZA0_NUMORC "
		//CHAMADO: AAZO9M
		cQuery += "     AND SUA.UA_CANC != 'S' "
		cQuery += "     AND SUA.UA_STATUS <> 'CAN' "
		cQuery += "     AND ZA0.ZA0_FLAGOF = 'S' "
		//	cQuery += "     AND SUA.UA_EMISSAO = '" + DTOS(dDataConsiderada) + "' "
		//CHAMADO: AAZO9M
		cQuery += "     AND ZA0.ZA0_DTNECL = '" + DTOS(dDataConsiderada) + "' "
		cQuery += "GROUP BY UA_GERVEN  "
	EndIf

	IF cTpCeO == '2'
		cQuery += ")) GROUP BY GERENTE "
	EndIf

	U_ExecMySql(cQuery, '_CN1', "Q", lCaptura)

	TCSetField( '_CN1', 'VLRITEM'  , 'N',17 , 2 )
	TCSetField( '_CN1', 'VOFERT'   , 'N',17 , 2 )

	*******************************************************************************
	IncProc("Processando Metas On-Line "+" - Valor Vendido/Pedido Dia") //| Valor Vendido dia (Pedidos)
	*******************************************************************************
	Conout( cNomProg + " - Valor Vendido/Pedido Dia")

	cQuery := " "
	cQuery += "SELECT  UA_GERVEN GERENTE, SUM( ROUND( C6_PRCACRE*C6_QTDVEN,"+alltrim(str(nDecSD2))+" ) ) VALOR "
	cQuery += "		FROM "+RetSqlName("SUA")+" SUA, "+RetSqlName("SC5")+" SC5," + RetSqlName("SC6")+" SC6, "+RetSqlName("SF4")+" SF4 	"
	cQuery += "		WHERE SUA.UA_FILIAL IN ( " + cFilImd + " ) "
	//CHAMADO: AAZO9M
	//cQuery += "			AND 	UA_EMISSAO  = '" + DTOS(dDataConsiderada) + "' "
	cQuery += "			AND 	C5_EMISSAO  = '" + DTOS(dDataConsiderada) + "' "

	cQuery += "       AND   C5_VEND5    NOT IN (" + cFilGerente + ") "// Jorge Oliveira - 21/12/2010 - Nao mostra movimentacoes de Clientes para esse Gerente

	cQuery += "			AND 	SUA.UA_CANC <> 'S' "
	cQuery += "			AND 	C5_FILIAL   = C6_FILIAL "
	cQuery += "			AND 	C6_FILIAL   = UA_FILIAL "
	cQuery += "			AND 	C6_NUM      = UA_NUMSC5 "
	cQuery += "			AND 	C5_NUM      = C6_NUM 	"
	cQuery += "			AND 	F4_FILIAL   = C6_FILIAL "
	cQuery += "			AND 	F4_CODIGO   = C6_TES 	"
	cQuery += "       AND   SC5.C5_TIPO NOT IN ( 'B', 'D','P','I') "
	cQuery += "       AND   SF4.F4_ESTOQUE = 'S'    "
	cQuery += "			AND 	SF4.F4_DUPLIC  = 'S' 	"
	cQuery += "			AND   SUA.D_E_L_E_T_ = ' ' 	"
	cQuery += "			AND	SC6.D_E_L_E_T_ = ' ' 	"
	cQuery += "			AND	SC5.D_E_L_E_T_ = ' '    "
	cQuery += "			AND	SF4.D_E_L_E_T_ = ' '	"
	cQuery += "		GROUP BY UA_GERVEN  "
	cQuery += " 	ORDER BY UA_GERVEN  "

	U_ExecMySql(cQuery, '_CN2', "Q", lCaptura)

	TCSetField( '_CN2', 'VALOR'  , 'N',17 , 2 )

	*******************************************************************************
	IncProc("Processando Metas On-Line "+" - Valor Vendido/Pedidos") //CONSULTA 03 - valor vendido (nao somente do dia) que nao gerou nf
	*******************************************************************************
	Conout( cNomProg + " - Valor Vendido/Pedidos")

	cQuery := ""

	cQuery += "SELECT  SC5.C5_VEND5 GERENTE, SUM( ROUND( C6_PRCACRE*( C6_QTDVEN - C6_QTDENT ),"+alltrim(str(nDecSD2))+" ) ) VALOR "
	cQuery += "		FROM "+RetSqlName("SC6")+" SC6 ,"+RetSqlName("SC5")+" SC5, "+RetSqlName("SF4")+" SF4 "
	cQuery += "		WHERE SC6.C6_FILIAL IN ( " + cFilImd + " ) 			"
	cQuery += "			AND	SC5.C5_EMISSAO <= '" + DTOS(dDataConsiderada) + "' "
	cQuery += "			AND SC5.C5_FILIAL 	= SC6.C6_FILIAL  	"
	cQuery += "			AND SC5.C5_NUM		= SC6.C6_NUM     	"
	cQuery += "			AND F4_FILIAL       = C6_FILIAL 		"
	cQuery += "			AND F4_CODIGO 		= C6_TES 			"

	// Jorge Oliveira - 21/12/2010 - Nao mostra movimentacoes de Clientes para esse Gerente
	// Exemplo da variavel cFilGerente := '000207', '000467'
	// Exemplo da variavel cFilGerente := ''
	cQuery += "       AND SC5.C5_VEND5 NOT IN (" + cFilGerente + ") "

	//cQuery += " 		AND	SC5.C5_TIPO <> 'B' "
	//cQuery += " 		AND	SC5.C5_TIPO <> 'D' "

	cQuery += "       AND SC5.C5_TIPO NOT IN ( 'B', 'D','P','I') "
	cQuery += "       AND SF4.F4_ESTOQUE = 'S'    "

	cQuery += "			AND SC6.C6_NOTA     = '      ' 			"
	cQuery += "			AND SC6.C6_SERIE    = '   ' 			"
	cQuery += "			AND SC6.C6_BLOQUEI  = '  ' 				"
	cQuery += "			AND SC6.C6_QTDVEN - SC6.C6_QTDENT > 0	"
	cQuery += "			AND 	SF4.F4_DUPLIC   = 'S' "
	cQuery += " 		AND  	SC6.D_E_L_E_T_  = ' ' "
	cQuery += "			AND  	SC5.D_E_L_E_T_  = ' ' "
	cQuery += "			AND  	SF4.D_E_L_E_T_  = ' ' "
	cQuery += "		GROUP BY SC5.C5_VEND5  "
	cQuery += "		ORDER BY SC5.C5_VEND5  "

	U_ExecMySql(cQuery, '_CN3', "Q", lCaptura)

	TCSetField( '_CN3', 'VALOR'  , 'N',17 , 2 )

	*******************************************************************************
	IncProc("Processando Metas On-Line "+" - Valores Bloqueados")//CONSULTA 04 - valores bloqueados por avaliacao comercial
	*******************************************************************************
	Conout( cNomProg + " - Valores Bloqueados")

	cQuery := "SELECT  SC5.C5_VEND5 GERENTE, SUM( ROUND( C6_PRCACRE*( C6_QTDVEN - C6_QTDEMP ),"+alltrim(str(nDecSD2))+" ) )  VALOR "
	cQuery += "		FROM "+RetSqlName("SC6")+" SC6, " + RetSqlName("SC5")+" SC5, "+RetSqlName("SF4")+" SF4 "
	cQuery += "		WHERE SC6.C6_FILIAL IN ( " + cFilImd + " ) "
	cQuery += "			AND C5_EMISSAO <= '" + DTOS(dDataConsiderada) + "' "
	cQuery += "			AND SC5.C5_FILIAL = C6_FILIAL 		"
	cQuery += "			AND SC5.C5_NUM = C6_NUM 			"
	cQuery += "			AND F4_FILIAL = C6_FILIAL 			"
	cQuery += "			AND F4_CODIGO = C6_TES 				"

	// Jorge Oliveira - 21/12/2010 - Nao mostra movimentacoes de Clientes para esse Gerente
	// Exemplo da variavel cFilGerente := '000207', '000467'
	// Exemplo da variavel cFilGerente := ''
	cQuery += "       AND SC5.C5_VEND5 NOT IN (" + cFilGerente + ") "

	//cQuery += " 		AND	SC5.C5_TIPO <> 'B' "
	//cQuery += " 		AND	SC5.C5_TIPO <> 'D' "

	cQuery += "         AND SC5.C5_TIPO NOT IN ( 'B', 'D','P','I') "
	cQuery += "         AND SF4.F4_ESTOQUE = 'S'    "

	cQuery += "			AND SC6.C6_NOTA = '      ' 			"
	cQuery += "			AND SC6.C6_SERIE = '   ' 			"
	cQuery += "			AND C6_BLOQUEI  = '  ' 				"
	cQuery += "			AND C6_QTDVEN - (C6_QTDEMP+C6_QTDENT) > 0 "
	cQuery += "			AND SF4.F4_DUPLIC  = 'S' "
	cQuery += "			AND SC6.D_E_L_E_T_ = ' ' "
	cQuery += "			AND SC5.D_E_L_E_T_ = ' ' "
	cQuery += "			AND	SF4.D_E_L_E_T_ = ' ' "
	cQuery += "		GROUP BY SC5.C5_VEND5  "
	cQuery += "		ORDER BY SC5.C5_VEND5  "

	U_ExecMySql(cQuery, '_CN4', "Q", lCaptura)

	TCSetField( '_CN4', 'VALOR'  , 'N',17 , 2 )

	*******************************************************************************
	IncProc("Processando Metas On-Line "+" - Lib. Pendente Estoque") // CONSULTA 05 - LIBERACAO PENDENTE DE ESTOQUE
	*******************************************************************************
	Conout( cNomProg + " - Lib. Pendente Estoque")

	cQuery :=  ""
	cQuery +=  "SELECT  SC5.C5_VEND5 GERENTE, "
	cQuery +=  "        SUM( ROUND( SC6.C6_PRCACRE * SC9.C9_QTDLIB,"+alltrim(str(nDecSD2))+" ) ) VALOR "

	cQuery +=  "FROM ( SELECT C9_FILIAL,C9_PEDIDO,C9_ITEM,C9_QTDLIB FROM SC9010 SC9 "
	cQuery +=  "       WHERE SC9.C9_FILIAL IN ( " + cFilImd + " ) 	 "
	cQuery +=  "       AND   SC9.C9_BLCRED   = ' ' "
	cQuery +=  "       AND   SC9.C9_BLEST    > ' '  "
	cQuery +=  "       AND   SC9.C9_NFISCAL  = ' ' "
	cQuery +=  "       AND   SC9.D_E_L_E_T_  = ' ' AND SC9.C9_SEQUEN = '01' ) SC9, "
	cQuery +=  "       SC6010 SC6, SC5010 SC5, SF4010 SF4 "

	cQuery +=  "WHERE SC6.C6_FILIAL   = SC9.C9_FILIAL "
	cQuery +=  "AND   SC6.C6_NUM      = SC9.C9_PEDIDO "
	cQuery +=  "AND   SC6.C6_ITEM     = SC9.C9_ITEM "
	cQuery +=  "AND   SC6.D_E_L_E_T_  = ' ' "
	cQuery +=  "AND   SC6.C6_FILIAL   = SC5.C5_FILIAL "
	cQuery +=  "AND   SC6.C6_NUM      = SC5.C5_NUM "
	cQuery +=  "AND   SC6.C6_CLI      = SC5.C5_CLIENTE "
	cQuery +=  "AND   SC6.C6_LOJA     = SC5.C5_LOJACLI "
	cQuery +=  "AND   SC5.C5_VEND5    NOT IN (" + cFilGerente + ") "
	cQuery +=  "AND   SC5.C5_TIPO     NOT IN ( 'B', 'D','P','I') "
	cQuery +=  "AND   SC5.C5_EMISSAO  <= '" + DTOS(dDataConsiderada) + "' "
	cQuery +=  "AND   SC5.D_E_L_E_T_  = ' '  "
	cQuery +=  "AND   SC6.C6_FILIAL   = SF4.F4_FILIAL "
	cQuery +=  "AND   SC6.C6_TES      = SF4.F4_CODIGO "
	cQuery +=  "AND   SF4.D_E_L_E_T_  = ' ' "
	cQuery +=  "AND   SF4.F4_ESTOQUE  = 'S' "
	cQuery +=  "AND   SF4.F4_DUPLIC   = 'S' "
	cQuery +=  "GROUP BY SC5.C5_VEND5 "
	cQuery +=  "ORDER BY SC5.C5_VEND5 "

	U_ExecMySql(cQuery, '_CN5', "Q", lCaptura)

	TCSetField( '_CN5', 'VALOR'  , 'N',17 , 2 )

	*******************************************************************************
	IncProc("Processando Metas On-Line "+" - Lib. Pendente CrÈdito")//CONSULTA 06 - LIBERACAO PENDENTE DE CREDITO
	*******************************************************************************
	Conout( cNomProg + " - Lib. Pendente CrÈdito")

	cQuery :=  "SELECT SC5.C5_VEND5 GERENTE , SUM( ROUND( C6_PRCACRE*C9_QTDLIB,"+alltrim(str(nDecSD2))+" ) )  VALOR "
	cQuery +=  "  FROM "+RetSqlName("SC6")+" sc6, "+RetSqlName("SC9")+" SC9, " + RetSqlName("SC5")+" SC5, "+RetSqlName("SF4")+" SF4 "
	cQuery +=  " WHERE SC9.C9_FILIAL IN ( " + cFilImd + " ) "
	cQuery +=  " 	AND C5_EMISSAO  <= '" + DTOS(dDataConsiderada) + "' "
	cQuery +=  "	AND C9_FILIAL = SC6.C6_FILIAL "
	cQuery +=  "	AND C9_PEDIDO = SC6.C6_NUM    "
	cQuery +=  "	AND C9_ITEM = SC6.C6_ITEM     "
	cQuery +=  "	AND C9_SEQUEN = '01'    "

	cQuery +=  "	AND C5_FILIAL = SC6.C6_FILIAL "
	cQuery +=  "	AND C5_NUM = SC6.C6_NUM "
	cQuery +=  "	AND F4_FILIAL = C6_FILIAL "
	cQuery +=  "	AND F4_CODIGO = C6_TES "

	// Jorge Oliveira - 21/12/2010 - Nao mostra movimentacoes de Clientes para esse Gerente
	// Exemplo da variavel cFilGerente := '000207', '000467'
	// Exemplo da variavel cFilGerente := ''
	cQuery +=  "  AND SC5.C5_VEND5 NOT IN (" + cFilGerente + ") "

	//cQuery += " 		AND	SC5.C5_TIPO <> 'B' "
	//cQuery += " 		AND	SC5.C5_TIPO <> 'D' "

	cQuery +=  "  AND SC5.C5_TIPO NOT IN ( 'B', 'D','P','I') "
	cQuery +=  "  AND SF4.F4_ESTOQUE = 'S' "

	cQuery +=  "  AND SF4.F4_DUPLIC = 'S' "
	cQuery +=  "  AND	C9_BLCRED  > '  ' "    // Deve ter bloqueio == 02
	cQuery +=  "  AND	C9_BLCRED  < '10' "    // Nao pode estar faturado
	cQuery +=  "  AND SC6.D_E_L_E_T_ = ' ' "
	cQuery +=  "  AND SC9.D_E_L_E_T_ = ' ' "
	cQuery +=  "  AND SC5.D_E_L_E_T_ = ' ' "
	cQuery +=  "  AND	SF4.D_E_L_E_T_  = ' ' "
	cQuery +=  "GROUP BY SC5.C5_VEND5 "
	cQuery +=  "ORDER BY SC5.C5_VEND5 "

	U_ExecMySql(cQuery, '_CN6', "Q", lCaptura)

	TCSetField( '_CN6', 'VALOR'  , 'N',17 , 2 )

	*******************************************************************************
	IncProc("Processando Metas On-Line "+" - Fat. Dia") //CONSULTA 07 - valores NFs emitidas no dia
	*******************************************************************************
	Conout( cNomProg + " - Fat. Dia")

	QueryNfs("D", '_CN7') //| Executa a Query Nf's Emitidas,  com Parametro D-Dia, M-Mes ou T-Trimestre

	*******************************************************************************
	IncProc("Processando Metas On-Line "+" - Fat. MÍs")//CONSULTA 08 - valores NFs emitidas no mes ate a database
	*******************************************************************************
	Conout( cNomProg + " - Fat. MÍs")

	QueryNfs("M", '_CN8') //| Executa a Query Nf's Emitidas,  com Parametro D-Dia, M-Mes ou T-Trimestre

	*******************************************************************************
	IncProc("Processando Metas On-Line "+" - Fat. Tri")//CONSULTA  - valores NFs emitidas no Trimestre corrente ate a database
	*******************************************************************************
	Conout( cNomProg + " - Fat. Tri")

	QueryNfs("T", '_CT1') //| Executa a Query Nf's Emitidas,  com Parametro D-Dia, M-Mes ou T-Trimestre

	*******************************************************************************
	IncProc("Processando Metas On-Line "+" - Lib. Pendente WMS")//CONSULTA 05,5 - LIBERACAO PENDENTE DE WMS
	*******************************************************************************
	Conout( cNomProg + " - Lib. Pendente WMS")

	cQuery :=  ""
	cQuery +=  "SELECT  SC5.C5_VEND5 GERENTE, "
	cQuery +=  "        SUM( ROUND( SC6.C6_PRCACRE * SC9.C9_QTDLIB,"+ alltrim(str(nDecSD2)) +" ) ) VALOR "

	cQuery +=  "FROM ( SELECT C9_FILIAL,C9_PEDIDO,C9_ITEM,C9_QTDLIB FROM SC9010 SC9 "
	cQuery +=  "       WHERE SC9.C9_FILIAL IN ( " + cFilImd + " )	 "
	cQuery +=  "       AND   SC9.C9_BLCRED   = ' ' "
	cQuery +=  "       AND   SC9.C9_BLEST    = ' '  "
	cQuery +=  "       AND   SC9.C9_NFISCAL  = ' ' "
	cQuery +=  "       AND   SC9.D_E_L_E_T_  = ' ' AND SC9.C9_SEQUEN = '01') SC9, "
	cQuery +=  "       SC6010 SC6, SC5010 SC5, SF4010 SF4 "

	cQuery +=  "WHERE SC6.C6_FILIAL   = SC9.C9_FILIAL "
	cQuery +=  "AND   SC6.C6_NUM      = SC9.C9_PEDIDO "
	cQuery +=  "AND   SC6.C6_ITEM     = SC9.C9_ITEM "
	cQuery +=  "AND   SC6.D_E_L_E_T_  = ' ' "
	cQuery +=  "AND   SC6.C6_FILIAL   = SC5.C5_FILIAL "
	cQuery +=  "AND   SC6.C6_NUM      = SC5.C5_NUM "
	cQuery +=  "AND   SC6.C6_CLI      = SC5.C5_CLIENTE "
	cQuery +=  "AND   SC6.C6_LOJA     = SC5.C5_LOJACLI "
	cQuery +=  "AND   SC5.C5_VEND5    NOT IN (" + cFilGerente + ") "
	cQuery +=  "AND   SC5.C5_TIPO     NOT IN ( 'B', 'D','P','I') "
	cQuery +=  "AND   SC5.C5_EMISSAO  <= '" + DTOS(dDataConsiderada) + "' "
	cQuery +=  "AND   SC5.D_E_L_E_T_  = ' '  "
	cQuery +=  "AND   SC6.C6_FILIAL   = SF4.F4_FILIAL "
	cQuery +=  "AND   SC6.C6_TES      = SF4.F4_CODIGO "
	cQuery +=  "AND   SF4.D_E_L_E_T_  = ' ' "
	cQuery +=  "AND   SF4.F4_ESTOQUE  = 'S' "
	cQuery +=  "AND   SF4.F4_DUPLIC   = 'S' "
	cQuery +=  "GROUP BY SC5.C5_VEND5 "
	cQuery +=  "ORDER BY SC5.C5_VEND5 "

	U_ExecMySql(cQuery, '_CN9', "Q", lCaptura)

	TCSetField( '_CN9', 'VALOR'  , 'N',17 , 2 )

	If MV_PAR03 == 1	// CONSULTA se considera devolucoes

		*******************************************************************************
		IncProc("Processando Metas On-Line "+" - DevoluÁıes") // DEVOLUCOES DIA
		*******************************************************************************
		Conout( cNomProg + " - DevoluÁıes Dia")

		QueryDev("D", '_CNA', @aDevDia)//| Exe

		*******************************************************************************
		IncProc("Processando Metas On-Line "+" - DevoluÁıes MÍs")  // DEVOLUCOES MES
		*******************************************************************************
		Conout( cNomProg + " - DevoluÁıes MÍs")

		QueryDev("M", '_CNB', @aDevMes)//| Exe

		*******************************************************************************
		IncProc("Processando Metas On-Line "+" - DevoluÁıes MÍs")  // DEVOLUCOES MES
		*******************************************************************************
		Conout( cNomProg + " - DevoluÁıes Trimestre")

		QueryDev("T", '_CT2', @aDevTri)//| Exe

	EndIf

	*******************************************************************************
	IncProc("Processando Metas On-Line "+" - Metas")// METAS DAS GERENCIAS...
	*******************************************************************************
	Conout( cNomProg + " - Metas")

	QueryMet("M", '_META', @aMetaGER)//| Executa a Query Metas,  com Parametro M-Mes ou T-Trimestre

	*******************************************************************************
	IncProc("Processando Metas On-Line "+" - Metas Trimestre")// METAS DAS GERENCIAS...
	*******************************************************************************
	Conout( cNomProg + " - Metas Trimestre")

	QueryMet("T", '_CT3', @aMetaTri)//| Executa a Query Metas,  com Parametro M-Mes ou T-Trimestre

	*******************************************************************************
	IncProc("Processando Metas On-Line "+" - Montagem dos Dados")
	*******************************************************************************

	Conout( cNomProg +" - Montagem dos Dados") // INICIO DO PROCESSO DE PREENCHIMENTO DOS VALORES

	/* Preenche o aCols com informacoes iniciais - Inicializacao */
	aCols := {}
	//qtdGerentes := 2// INICIA COM 2 referente ao Total Geral e Gerente n„o definido
	qtdGerentes := 1// INICIA COM 1 referente ao Total Geral
	DBSELECTAREA("_G1")
	DBGOTOP()
	DO WHILE !EOF()
		qtdGerentes++
		DBSKIP()
	ENDDO

	qtd2 := _G1->(RECCOUNT())  //FCOUNT()   //SM0->(Reccount()) > 1

	For ind := 1 To qtdGerentes

		AADD(  aCols,{ nomeGerente( aCodGer[ ind ] ) , ;
		aCodGer[ind]        , ;
		'01'       , ;   // Grupo para ordenacao
		'Venda dias s/IPI', ;   // Grupo
		'Valor Consultado', ;   // Descricao
		0                 , ;   // Valor  consultado
		100               , ;   // Percentual         // Representa 100%
		Space(2)          , ;   // Borda
		.F.                } )             // Delete

		AADD( aCols, { nomeGerente( aCodGer[ ind ] ) , ;
		aCodGer[ind]        , ;
		'02'    , ;   // Grupo para ordenacao
		'Venda dias s/IPI', ;   // Grupo
		'Valor Ofertado  ', ;   // Descricao
		0                 , ;   // Valor ofertado
		0                 , ;   // Percentual
		Space(2)          , ;   // Borda
		.F.                } )   // Delete

		AADD( aCols, { nomeGerente( aCodGer[ ind ] ) , ;
		aCodGer[ind]        , ;
		'03'       , ;   // Grupo para ordenacao
		'Venda dias s/IPI', ;   // Grupo
		'Valor Vendido   ', ;   // Descricao
		0                 , ;   // Valor vendido
		0                 , ;   // Percentual
		Space(2)          , ;   // Borda
		.F.               } )   // Delete

		//------------------------------------------------------------------------------------------------------

		AADD( aCols, { nomeGerente( aCodGer[ ind ] ) , ;
		aCodGer[ind]        , ;
		'04'            , ;   // Grupo para ordenacao
		'Total do dia s/IPI   ', ;   // Grupo
		'Valor Vendido        ', ;   // Descricao
		0                      , ;   // Total do dia s/IPI
		0                      , ;   // Percentual
		Space(2)               , ;   // Borda
		.F.                     } )   // Delete

		AADD( aCols, { nomeGerente( aCodGer[ ind ] ) , ;
		aCodGer[ind]        , ;
		'05'              , ;   // Grupo para ordenacao
		'Total do dia s/IPI'     , ;   // Grupo
		'Valor Pend. Lib. Venda' , ;   // Descricao
		0                        , ;   // Total do dia s/IPI
		0                        , ;   // Percentual
		Space(2)                 , ;   // Borda
		.F.                      } )   // Delete

		AADD( aCols, { nomeGerente( aCodGer[ ind ] ) , ;
		aCodGer[ind]        , ;
		'06'              , ;   // Grupo para ordenacao
		'Total do dia s/IPI'     , ;   // Grupo
		'Valor Pend. Lib. Cred.' , ;   // Descricao
		0                        , ;   // Total
		0                        , ;   // Percentual
		Space(2)                 , ;   // Borda
		.F.                      } )   // Delete

		AADD( aCols, { nomeGerente( aCodGer[ ind ] ) , ;
		aCodGer[ind]        , ;
		'07'              , ;   // Grupo para ordenacao
		'Total do dia s/IPI'     , ;   // Grupo
		'Valor Pend. Lib. Est. ' , ;   // Descricao
		0                        , ;   // Total
		0                        , ;   // Percentual
		Space(2)                 , ;   // Borda
		.F.                      } )   // Delete

		AADD( aCols, { nomeGerente( aCodGer[ ind ] ) , ;
		aCodGer[ind]        , ;
		'08'              , ;   // Grupo para ordenacao
		'Total do dia s/IPI'     , ;   // Grupo
		'Valor Pend. Lib. WMS  ' , ;   // Descricao
		0                        , ;   // Total
		0                        , ;   // Percentual
		Space(2)                 , ;   // Borda
		.F.                      } )   // Delete

		AADD( aCols, { nomeGerente( aCodGer[ ind ] ) , ;
		aCodGer[ind]        , ;
		'09'                       , ;   // Grupo para ordenacao
		'Total do dia s/IPI'       , ;   // Grupo
		'Valor NF emitida      '   , ;   // Descricao
		0                          , ;   // Total
		0                          , ;   // Percentual
		Space(2)                   , ;   // Borda
		.F.                        } )   // Delete

		//------------------------------------------------------------------------------------------------------

		AADD( aCols, { nomeGerente( aCodGer[ ind ] ) ,;
		aCodGer[ind]        , ;
		'10'              , ;   // Grupo para ordenacao
		'Faturamento  s/IPI'     , ;   // Grupo
		'Total Dia             ' , ;   // Descricao
		0                        , ;   // Total
		0                        , ;   // Percentual
		Space(2)                 , ;   // Borda
		.F.                      } )   // Delete

		AADD( aCols, { nomeGerente( aCodGer[ ind ] ) ,;
		aCodGer[ind]        , ;
		'11'              , ;   // Grupo para ordenacao
		'Faturamento  s/IPI'     , ;   // Grupo
		'Media Dia             ' , ;   // Descricao
		0                        , ;   // Total
		0                        , ;   // Percentual
		Space(2)          , ;   // Borda
		.F.                      } )   // Delete

		AADD( aCols, { nomeGerente( aCodGer[ ind ] ) ,;
		aCodGer[ind]        	, ;
		'12'              		, ;   // Grupo para ordenacao
		'Faturamento  s/IPI'    , ;   // Grupo
		'Total Mes             ', ;   // Descricao
		0                       , ;   // Total
		0                       , ;   // Percentual
		Space(2)                , ;   // Borda
		.F.                     } )   // Delete

		AADD( aCols, { nomeGerente( aCodGer[ ind ] ) ,;
		aCodGer[ind]        	, ;
		'13'                 	, ;   // Grupo para ordenacao
		'Faturamento  s/IPI'    , ;   // Grupo
		'Meta Mes              ', ;   // Descricao
		MetaMes( aCodGer[ind ] ), ;   // Total
		0                       , ;   // Percentual
		Space(2)                , ;   // Borda
		.F.                     } )   // Delete

		AADD( aCols, { nomeGerente( aCodGer[ ind ] ) , ;
		aCodGer[ind]        	, ;
		'14'              		, ;   // Grupo para ordenacao
		'Faturamento  s/IPI'    , ;   // Grupo
		'Diferenca             ', ;   // Descricao
		0                       , ;   // Total
		0                       , ;   // Percentual
		Space(2)                , ;   // Borda
		.F.                     } )   // Delete

		AADD( aCols, { nomeGerente( aCodGer[ ind ] ) ,;
		aCodGer[ind]        , ;
		'15'              , ;   // Grupo para ordenacao
		'Faturamento  s/IPI'     , ;   // Grupo
		'Media dia p/Meta      ' , ;   // Descricao
		0                        , ;   // Total
		0                        , ;   // Percentual
		Space(2)                 , ;   // Borda
		.F.                      } )   // Delete

		//| Analista: Cristiano Machado - Chamado: 14677 - Data 03/03/2017
		AADD( aCols, { nomeGerente( aCodGer[ ind ] ) ,;
		aCodGer[ind]        , ;
		'16'              , ;   // Grupo para ordenacao
		'Faturamento  s/IPI'     , ;   // Grupo
		'Diferenca Meta Trimestre' , ;   // Descricao
		0                        , ;   // Total
		0                        , ;   // Percentual
		Space(2)                 , ;   // Borda
		.F.                      } )   // Delete

	Next ind

	IncProc()

	If Empty( aCols )
		AAdd( aCols, { Space(20),Space(2),Space(17),Space(30),0,0,.f. } )
	EndIf

	// Atualizacao dos valores a partir das consultas
	// Valor consultado
	dbSelectArea('_CN1')
	dbGotop()
	Do While !Eof()
		lancaValor( _CN1->GERENTE ,, '01' , _CN1->VLRITEM,"GERENTE" )  //( _CN1->FILIAL , '01', _CN1->VLRITEM )
		dbSkip()
	Enddo

	// Valor ofertado
	dbSelectArea('_CN1')
	dbGotop()
	Do While !Eof()
		lancaValor( _CN1->GERENTE,, '02',  _CN1->VOFERT ,"GERENTE" )//( _CN1->FILIAL, '02',  _CN1->VOFERT  )
		dbSkip()
	Enddo

	// Valor vendido
	dbSelectArea('_CN2')
	dbGotop()
	Do While !Eof()
		lancaValor( _CN2->GERENTE ,, '03' , _CN2->VALOR ,"GERENTE"  )//( _CN2->FILIAL , '03', _CN2->VALOR  )
		dbSkip()
	Enddo

	// Valor vendido total
	dbSelectArea('_CN3')
	dbGotop()
	Do While !Eof()
		lancaValor( _CN3->GERENTE ,, '04' , _CN3->VALOR ,"GERENTE" )//( _CN3->FILIAL , '04', _CN3->VALOR  )
		dbSkip()
	Enddo

	// Valor pend. de analise
	dbSelectArea('_CN4')
	dbGotop()
	Do While !Eof()
		lancaValor( _CN4->GERENTE ,, '05' , _CN4->VALOR ,"GERENTE"  ) //( _CN4->FILIAL , '05', _CN4->VALOR  )
		dbSkip()
	Enddo

	// Valor a liberar credito
	dbSelectArea('_CN6')
	dbGotop()
	Do While !Eof()
		lancaValor( _CN6->GERENTE ,, '06' , _CN6->VALOR ,"GERENTE" )//( _CN6->FILIAL , '06', _CN6->VALOR  )
		dbSkip()
	Enddo

	// Valor a liberar estoque
	dbSelectArea('_CN5')
	dbGotop()
	Do While !Eof()
		lancaValor( _CN5->GERENTE ,, '07' , _CN5->VALOR ,"GERENTE" )//( _CN5->FILIAL , '07', _CN5->VALOR  )
		dbSkip()
	Enddo

	// Valor a liberar WMS
	dbSelectArea('_CN9')
	dbGotop()
	Do While !Eof()
		lancaValor( _CN9->GERENTE ,, '08' , _CN9->VALOR ,"GERENTE" ) //( _CN9->FILIAL , '08', _CN9->VALOR  )
		dbSkip()
	Enddo

	// Valor faturado   dia
	dbSelectArea('_CN7')
	dbGotop()
	Do While !Eof()
		lancaValor( _CN7->GERENTE ,, '09' , _CN7->VALOR ,"GERENTE"  )//
		dbSkip()
	Enddo

	// Valor faturado   dia
	dbSelectArea('_CN7')
	dbGotop()
	Do While !Eof()
		lancaValor(  _CN7->GERENTE ,, '10' , _CN7->VALOR ,"GERENTE"  ) 	//( _CN7->FILIAL , '10', _CN7->VALOR  )
		If MV_PAR05 == 1		// Considera o dia
			lancaValor(  _CN7->GERENTE ,, '11' , _CN7->VALOR ,"GERENTE"  )  	//( _CN7->FILIAL , '11', _CN7->VALOR  )
			lancaValor(  _CN7->GERENTE ,, '12' , _CN7->VALOR ,"GERENTE"  )	//( _CN7->FILIAL , '12', _CN7->VALOR  )
			lancaValor(  _CN7->GERENTE ,, '14' , _CN7->VALOR ,"GERENTE"  )	//( _CN7->FILIAL , '14', _CN7->VALOR  ) TAVA 13
		EndIf
		dbSkip()
	Enddo

	// Valor faturado mes e diferenca
	dbSelectArea('_CN8')
	dbGotop()
	Do While !Eof()
		lancaValor( _CN8->GERENTE ,, '11' , _CN8->VALOR, "GERENTE"  )  	//( _CN8->FILIAL , '11', _CN8->VALOR  )
		lancaValor( _CN8->GERENTE ,, '12' , _CN8->VALOR, "GERENTE"  )	//( _CN8->FILIAL , '12', _CN8->VALOR  )
		lancaValor( _CN8->GERENTE ,, '14' , _CN8->VALOR, "GERENTE"  )	//( _CN8->FILIAL , '14', _CN8->VALOR  )
		dbSkip()
	Enddo

	//| Analista: Cristiano Machado - Chamado: 14677 - Data 03/03/2017
	// _CT1 -> Faturamento Trimestre (Baseado em _CN8)
	dbSelectArea('_CT1')
	dbGotop()
	Do While !Eof()
		lancaValor( _CT1->GERENTE ,, '16' , (_CT1->VALOR * -1), "GERENTE"  )  	//( _CN8->FILIAL , '11', _CN8->VALOR  )
		dbSkip()
	Enddo

	*******************************************************************************
	// OUTROS C¡LCULOS
	*******************************************************************************
	IncProc()

	cdevdia := "adevdia" + CHR(13)+CHR(10)
	for ind := 1 to len(aDevDia)
		cdevdia += aDevDia[ind,1] + " " + STR(aDevDia[ind,2]) + CHR(13)+CHR(10)
	next ind
	MEMOWRIT("C:\SQLSIGA\IMDC021_ADEVDIA.TXT", cdevdia)

	cdevmes := "adevmes" + CHR(13)+CHR(10)
	for ind := 1 to len(aDevmes)
		cdevmes += aDevmes[ind,1] + " " + STR(aDevmes[ind,2]) + CHR(13)+CHR(10)
	next ind
	MEMOWRIT("C:\SQLSIGA\IMDC021_ADEVMES.TXT", cdevmes)

	cdevtri := "adevtri" + CHR(13)+CHR(10)
	for ind := 1 to len(aDevTri)
		cdevtri += aDevTri[ind,1] + " " + STR(aDevTri[ind,2]) + CHR(13)+CHR(10)
	next ind
	MEMOWRIT("C:\SQLSIGA\IMDC021_ADEVTRI.TXT", cdevtri)

	For ind := 1 To Len( aCols )

		// Identifica o C”DIGO DO GERENTE
		cgerenteAtual 	:= aCols[ ind, X_COD_GER ] //Right( Rtrim(aCols[ ind, X_NOME_COD_GER ]),TamSx3("A3_COD" )[1])	//yfilial   := Right(Rtrim(aCols[ind, X_NOME_COD_GER ]),TamSx3("A3_COD" )[1])
		nPosDevDia 		:= aScan(aDevDia, {|x| x[1]==cgerenteAtual})  //retorna em qual linha do array de devoluÁ„o dia
		nPosDevMes 		:= aScan(aDevMes, {|x| x[1]==cgerenteAtual})
		nPosDevTri 		:= aScan(aDevTri, {|x| x[1]==cgerenteAtual})
		//***************************************************************************
		// Subtrai as devolucoes do Total Dia, do Total Mes , da Diferenca, e do Calculo da Media Dia
		//***************************************************************************
		If MV_PAR03 == 1
			If aCols[ ind, X_TIPO  ] == '10'
				If nPosDevDia > 0
					// Total dia
					aCols[ ind, X_VALOR ] := aCols[ ind, X_VALOR ] - aDevDia[nPosDevDia,2]
				EndIf
			Elseif aCols[ ind, X_TIPO  ] == '11' .or. aCols[ ind, X_TIPO  ] == '12' .or. aCols[ ind, X_TIPO  ] == '14'	// Media Dia(11), Total mes(12) e diferenca(14)
				If MV_PAR05 == 1	// Considera o dia
					If nPosDevDia > 0
						// subtrai as devolucoes do dia
						aCols[ ind, X_VALOR ] := aCols[ ind, X_VALOR ] - aDevDia[nPosDevDia,2]
					EndIf
				EndIf
				If 	nPosDevMes > 0
					//subtrai as devoluÁıes mÍs
					aCols[ ind, X_VALOR ] := aCols[ ind, X_VALOR ] - aDevMes[nPosDevMes,2]
				EndIf
			Elseif aCols[ ind, X_TIPO  ] == '16'
				If 	nPosDevTri > 0
					//subtrai as devoluÁıes trimestre
					aCols[ ind, X_VALOR ] := aCols[ ind, X_VALOR ] + aDevTri[nPosDevTri,2]
				EndIf

			EndIf
		EndIf

		//**********************************************************
		// Calcula a Media Dia
		//**********************************************************
		If aCols[ ind, X_TIPO  ] == '11'	// Media Dia
			nPos := aScan(aDiasPass, {|x| x[1]==cgerenteAtual})
			If nPos > 0
				aCols[ ind, X_VALOR ] := aCols[ ind, X_VALOR ] / aDiasPass[nPos,2]
			EndIf
		EndIf

		// Identifica a quantidade de dias uteis que restam no mes por Gerente
		nPos 	 := aScan(aDiasRest, {|x| x[1]==cgerenteAtual})
		IF nPos > 0

			// O valor lancado anteriormente foi o faturado do mes
			// diminuir meta do mes
			If 		aCols[ ind, X_TIPO  ] == '14'   //diferenca
				diferenca:=	aCols[ ind, X_VALOR ] :=  MetaMes( aCols[ind, X_COD_GER ] ) - aCols[ ind, X_VALOR ]
			ElseIf 	aCols[ ind, X_TIPO  ] == '15'   // media dia pela meta
				If aDiasRest[nPos,2] <> 0 .AND. diferenca <> 0
					aCols[ ind, X_VALOR ] := diferenca / aDiasRest[nPos,2]
				EndIf
			EndIf
		EndIf

		If	aCols[ ind, X_TIPO  ] == '16'   //Meta Trimestre
			aCols[ ind, X_VALOR ] :=  aCols[ ind, X_VALOR ] + MetaMes( aCols[ind, X_COD_GER ], aMetaTri )
		EndIF

	Next ind

	*******************************************************************************
	// SomatÛrio para totais
	*******************************************************************************

	IncProc()

	// Calcular o valor total
	tot_01  := 0
	tot_02  := 0
	tot_03  := 0
	tot_04  := 0
	tot_05  := 0
	tot_06  := 0
	tot_07  := 0
	tot_08  := 0
	tot_09  := 0
	tot_10  := 0
	tot_11  := 0
	tot_12  := 0
	tot_13  := 0
	tot_14  := 0
	tot_15  := 0
	tot_16  := 0

	For ind := 1 To Len( aCols )

		If 	aCols[ ind, X_TIPO ] == '01'
			tot_01 += aCols[ ind, X_VALOR ]
		Elseif aCols[ ind, X_TIPO ] == '02'
			tot_02 += aCols[ ind, X_VALOR ]
		Elseif aCols[ ind, X_TIPO ] == '03'
			tot_03 += aCols[ ind, X_VALOR ]
		Elseif aCols[ ind, X_TIPO ] == '04'
			tot_04 += aCols[ ind, X_VALOR ]
		Elseif aCols[ ind, X_TIPO ] == '05'
			tot_05 += aCols[ ind, X_VALOR ]
		Elseif aCols[ ind, X_TIPO ] == '06'
			tot_06 += aCols[ ind, X_VALOR ]
		Elseif aCols[ ind, X_TIPO ] == '07'
			tot_07 += aCols[ ind, X_VALOR ]
		Elseif aCols[ ind, X_TIPO ] == '08'
			tot_08 += aCols[ ind, X_VALOR ]
		Elseif aCols[ ind, X_TIPO ] == '09'
			tot_09 += aCols[ ind, X_VALOR ]
		Elseif aCols[ ind, X_TIPO ] == '10'
			tot_10 += aCols[ ind, X_VALOR ]
		Elseif aCols[ ind, X_TIPO ] == '11'
			tot_11 += aCols[ ind, X_VALOR ]
		Elseif aCols[ ind, X_TIPO ] == '12'
			tot_12 += aCols[ ind, X_VALOR ]
		Elseif aCols[ ind, X_TIPO ] == '13'
			tot_13 += aCols[ ind, X_VALOR ]
		Elseif aCols[ ind, X_TIPO ] == '14'
			tot_14 += aCols[ ind, X_VALOR ]
		Elseif aCols[ ind, X_TIPO ] == '15'
			tot_15 += aCols[ ind, X_VALOR ]
		Elseif aCols[ ind, X_TIPO ] == '16'
			tot_16 += aCols[ ind, X_VALOR ]
		EndIf

	Next ind

	For ind := 1 To Len( aCols )

		//**********************************
		// Atribui os totais j· somados
		//**********************************

		IF aCols[ ind, X_COD_GER ] == REPLICATE("X",TamSx3("A3_COD" )[1])
			For itipo := 1 To 16
				If aCols[ ind, X_TIPO ] == padl(alltrim(STR(itipo)),2,"0") // transforma um numero como 3 para 03
					cvalor := "tot_"+padl(alltrim(STR(itipo)),2,"0")
					aCols[ ind, X_VALOR ] := &cvalor
				EndIf
			Next itipo
		EndIf

	Next ind

	*******************************************************************************
	// -----------Calculo de percentuais
	*******************************************************************************
	// PERCENT valor ofertado (tipo02)  =  valor ofertado (tipo02) / valor consultado(tipo01) * 100
	// PERCENT valor vendido  (tipo03)  =  valor vendido  (tipo03) / valor consultado(tipo01) * 100

	For ind := 0 To ( Len( aCodGer )-1 )

		//If aCols[ ind, X_TIPO ] <> '16'
		mult := ind * 16  // Cada filial ( ou o total geral ) possui 15 linhas
		aCols[ mult+02, X_PERCENT] :=  aCols[mult+02, X_VALOR ] / aCols[ mult+01, X_VALOR] * 100
		aCols[ mult+03, X_PERCENT] :=  aCols[mult+03, X_VALOR ] / aCols[ mult+01, X_VALOR] * 100
		//*****************************************************
		// Define o percentual da meta parcial atingida por dia
		//*****************************************************
		// Verifica a posicao do array da quantidade de dias uteis da filial para calculo da percentagem
		cgerenteAtual   := aCols[mult+12, X_COD_GER ]
		nPos := aScan(aDiasPass, {|x| x[1]==cgerenteAtual})

		// --------Calcula percentagem da meta parcial
		// PERCENT 	meta parcial = VALOR meta parcial /
		IF nPos > 0

			nMetaParcial := ( aCols[mult+13 , X_VALOR] / (aDiasPass[nPos,2]+aDiasRest[nPos,2]) ) * aDiasPass[nPos,2]
			// Define o percentual da meta parcial atingida
			aCols[mult+12, X_PERCENT] := aCols[mult+12, X_VALOR] / nMetaParcial * 100

		Else
			aCols[mult+12, X_PERCENT] := 0
		EndIf
		//EndIf

	Next ind
	Incproc()

	Return

	//Realiza nova ordenacao dos dados conforme solicitado
	for nPos := 0 to (Len(aNome_Ger)-1)
		For ind := 12 to 14
			aCols[ind+nPos*15,X_TIPO] := strzero(Val( aCols[ind+nPos*15,X_TIPO])+1 , 2 )
		Next
		aCols[15+nPos*15,X_TIPO] := "12"
	next
	aSort(aCols,,,{|x,y| x[X_COD_GER]+x[X_TIPO] < y[X_COD_GER]+y[X_TIPO] })

	Return()
	*******************************************************************************
Static Function ExisteSXB_A3M()//| Verifica a existÍncia da consulta padr„o A3M E PARAMETRO, se n„o existir, cria
	*******************************************************************************

	DBSelectArea("SXB")
	DBSetOrder(1)
	DBGoTop()
	aCampos := {}

	IF !DBSeek("A3M")

		RecLock('SXB',.T.)
		SXB->XB_ALIAS   :=	"A3M"
		SXB->XB_TIPO	:=	"1"
		SXB->XB_SEQ		:=	"01"
		SXB->XB_COLUNA	:=	"DB"
		SXB->XB_DESCRI	:=	"Vendedor"
		SXB->XB_DESCSPA	:=	"Vendedor"
		SXB->XB_DESCENG	:=	"Sales Representative"
		SXB->XB_CONTEM	:=	"SA3"
		MsUnlock()

		RecLock('SXB',.T.)
		SXB->XB_ALIAS   :=	"A3M"
		SXB->XB_TIPO	:=	"2"
		SXB->XB_SEQ		:=	"01"
		SXB->XB_COLUNA	:=	"01"
		SXB->XB_DESCRI	:=	"CÛdigo"
		SXB->XB_DESCSPA	:=	"CÛdigo"
		SXB->XB_DESCENG	:=	"Code"

		MsUnlock()

		RecLock('SXB',.T.)
		SXB->XB_ALIAS   :=	"A3M"
		SXB->XB_TIPO	:=	"2"
		SXB->XB_SEQ		:=	"02"
		SXB->XB_COLUNA	:=	"02"
		SXB->XB_DESCRI	:=  "Nome"
		SXB->XB_DESCSPA	:=	"Nombre"
		SXB->XB_DESCENG	:=	"Name"
		MsUnlock()
		RecLock('SXB',.T.)
		SXB->XB_ALIAS   :=	"A3M"
		SXB->XB_TIPO	:=	"2"
		SXB->XB_SEQ		:=  "03"
		SXB->XB_COLUNA	:=	"03"
		SXB->XB_DESCRI	:=	"CGC"
		SXB->XB_DESCSPA	:=	"CGC"
		SXB->XB_DESCENG	:=	"CGC Number"
		MsUnlock()
		RecLock('SXB',.T.)
		SXB->XB_ALIAS   :=	"A3M"
		SXB->XB_TIPO	:=	"3"
		SXB->XB_SEQ		:=	"01"
		SXB->XB_COLUNA	:=	"01"
		SXB->XB_DESCRI	:=	"Cadastra Novo"
		SXB->XB_DESCSPA	:=	"Incluye Nuevo"
		SXB->XB_DESCENG	:=	"Add New"
		SXB->XB_CONTEM	:=	"01"
		MsUnlock()
		RecLock('SXB',.T.)
		SXB->XB_ALIAS   :=	"A3M"
		SXB->XB_TIPO	:=	"4"
		SXB->XB_SEQ		:=	"01"
		SXB->XB_COLUNA	:=	"01"
		SXB->XB_DESCRI	:=	"CÛdigo"
		SXB->XB_DESCSPA	:=	"Codigo"
		SXB->XB_DESCENG	:=	"Code"
		SXB->XB_CONTEM	:=	"A3_COD"
		MsUnlock()
		RecLock('SXB',.T.)
		SXB->XB_ALIAS   :=	"A3M"
		SXB->XB_TIPO	:=	"4"
		SXB->XB_SEQ		:=	"01"
		SXB->XB_COLUNA	:=	"02"
		SXB->XB_DESCRI	:=	"Nome"
		SXB->XB_DESCSPA	:=	"Nombre"
		SXB->XB_DESCENG	:=	"Name"
		SXB->XB_CONTEM	:=	"A3_NOME"
		MsUnlock()
		RecLock('SXB',.T.)
		SXB->XB_ALIAS   :=	"A3M"
		SXB->XB_TIPO	:=  "4"
		SXB->XB_SEQ		:=	"02"
		SXB->XB_COLUNA	:=	"01"
		SXB->XB_DESCRI	:=	"CÛdigo"
		SXB->XB_DESCSPA	:=	"Codigo"
		SXB->XB_DESCENG	:=	"Code"
		SXB->XB_CONTEM	:=	"A3_COD"
		MsUnlock()
		RecLock('SXB',.T.)
		SXB->XB_ALIAS   :=	"A3M"
		SXB->XB_TIPO	:=	"4"
		SXB->XB_SEQ		:=	"02"
		SXB->XB_COLUNA	:=	"02"
		SXB->XB_DESCRI	:=	"Nome"
		SXB->XB_DESCSPA	:= 	"Nombre"
		SXB->XB_DESCENG	:=	"Name"
		SXB->XB_CONTEM	:=	"A3_NOME"
		MsUnlock()
		RecLock('SXB',.T.)
		SXB->XB_ALIAS   :=	"A3M"
		SXB->XB_TIPO	:=	"4"
		SXB->XB_SEQ		:=	"03"
		SXB->XB_COLUNA	:=	"01"
		SXB->XB_DESCRI	:=	"CGC"
		SXB->XB_DESCSPA	:=	"CGC"
		SXB->XB_DESCENG	:=	"CGC Number"
		SXB->XB_CONTEM	:=	"A3_CGC"
		MsUnlock()
		RecLock('SXB',.T.)
		SXB->XB_ALIAS   :=	"A3M"
		SXB->XB_TIPO	:=	"4"
		SXB->XB_SEQ		:=	"03"
		SXB->XB_COLUNA	:=	"02"
		SXB->XB_DESCRI	:=	"Nome"
		SXB->XB_DESCSPA	:=	"Nombre"
		SXB->XB_DESCENG	:=	"Name"
		SXB->XB_CONTEM	:=	"A3_NOME"
		MsUnlock()
		RecLock('SXB',.T.)
		SXB->XB_ALIAS   :=	"A3M"
		SXB->XB_TIPO	:=	"5"
		SXB->XB_SEQ		:=	"01"
		SXB->XB_CONTEM	:=	"SA3->A3_COD"
		MsUnlock()
		RecLock('SXB',.T.)
		SXB->XB_ALIAS   :=	"A3M"
		SXB->XB_TIPO	:=  "6"
		SXB->XB_SEQ		:=	"01"
		SXB->XB_CONTEM	:= "AllTrim(A3_COD)$ GETMV('MV_GERENTE')"
		MsUnlock()
	EndIf

	//Verifica se exsite MV parametro

	DbselectArea("SX6")
	IF !DBSEEK(xFilial("SX6")+"MV_GERENTE")
		Reclock("SX6",.T.)
		SX6->X6_FIL		:= xFilial("SX6")
		SX6->X6_VAR		:= "MV_GERENTE"
		SX6->X6_TIPO 	:= "C"
		SX6->X6_DESCRIC := "CODIGOS DOS VENDEDORES CONSIDERADOS COMO GERENTES"
		SX6->X6_DSCSPA	:= "CODIGOS DOS VENDEDORES CONSIDERADOS COMO GERENTES"
		SX6->X6_DSCENG	:= "CODIGOS DOS VENDEDORES CONSIDERADOS COMO GERENTES"
		SX6->X6_PROPRI	:= "U"
		MsUnLock()
	EndIf

	Return
	*******************************************************************************
User Function FiltroA3M(codigo)
	*******************************************************************************
	cArea := GetArea()
	nrecno:= Recno()

	cQuery := "SELECT  A1_GERVEN FROM SA1010 WHERE D_E_L_E_T_ = ' ' AND A1_GERVEN = '" + codigo + "' GROUP BY A1_GERVEN"
	cQuery := ChangeQuery(cQuery)

	IF SELECT("A3M" ) <> 0
		dbSelectArea("A3M")
		Use
	EndIf

	TCQUERY cQuery NEW ALIAS ("A3M")
	IF SELECT("A3M" ) <> 0
		codigo := A3M->A1_GERVEN
	Else
		codigo := ""
	EndIf
	dbselectarea(carea)
	DBGOTO(nRecNo)

	Return(codigo)
	*******************************************************************************
Static Function Perg()//Testa/Cria se existem as perguntas do grupo IMDCXX()
	*******************************************************************************

	Local	aTamSX3 := {}

	DbSelectarea('SX1')
	DbSetOrder(1)
	If !DbSeek('IMDCXXXXXX')
		aTamSX3 := TamSx3("A3_COD")
		RecLock('SX1',.T.)
		SX1->X1_GRUPO   := 'IMDCXXXXXX'
		SX1->X1_ORDEM   := '01'
		SX1->X1_PERGUNT := 'Gerente Inicial ?'
		SX1->X1_VARIAVL := 'mv_ch1'
		SX1->X1_TIPO    := "C"//aTamSX3[3]
		SX1->X1_TAMANHO := 6 //aTamSX3[1]
		SX1->X1_DECIMAL := 0 //aTamSX3[2]
		SX1->X1_PRESEL  := 1
		SX1->X1_GSC     := 'G'
		SX1->X1_VALID   := ''
		SX1->X1_VAR01   := 'MV_PAR01'
		SX1->X1_F3      := 'A3M'
		MsUnlock()
	EndIf

	IF lViaWorkFlow
		//	aTamSX3 	:= 6
		MV_PAR01	:= "      "
	EndIf

	If !DbSeek('IMDCXXXXXX')
		RecLock('SX1',.T.)
		//	aTamSX3 	:= TamSx3("A3_COD")
		SX1->X1_GRUPO   := 'IMDCXXXXXX'
		SX1->X1_ORDEM   := '02'
		SX1->X1_PERGUNT := 'Gerente Final   ?'
		SX1->X1_VARIAVL := 'mv_ch2'
		SX1->X1_TIPO    := "C"
		SX1->X1_TAMANHO := 6
		SX1->X1_DECIMAL := 0
		SX1->X1_PRESEL  := 1
		SX1->X1_GSC     := 'G'
		SX1->X1_VALID   := ''
		SX1->X1_VAR01   := 'MV_PAR02'
		SX1->X1_F3      := 'A3M'
		MsUnlock()
	EndIf

	IF lViaWorkFlow
		//	aTamSX3 	:= //TamSx3("A3_COD")
		MV_PAR02	:= "ZZZZZZ" //REPLICATE("Z",aTamSX3[1]+ aTamSX3[2])
	EndIf

	If !DbSeek('IMDCXXXXXX')
		RecLock('SX1',.T.)
		SX1->X1_GRUPO   := 'IMDCXXXXXX'
		SX1->X1_ORDEM   := '03'
		SX1->X1_PERGUNT := 'Consid.Devolucoes ?'
		SX1->X1_VARIAVL := 'mv_ch3'
		SX1->X1_TIPO    := 'N'
		SX1->X1_TAMANHO := 1
		SX1->X1_DECIMAL := 0
		SX1->X1_PRESEL  := 1
		SX1->X1_GSC     := 'C'
		SX1->X1_VALID   := ''
		SX1->X1_VAR01   := 'MV_PAR03'
		SX1->X1_DEF01   := "Sim"
		SX1->X1_DEF02   := "Nao"
		MsUnlock()
	EndIf

	IF lViaWorkFlow
		MV_PAR03	:= 1 //sim
	EndIf

	If !DbSeek('IMDCXXXXXX')
		RecLock('SX1',.T.)
		SX1->X1_GRUPO   := 'IMDCXXXXXX'
		SX1->X1_ORDEM   := '04'
		SX1->X1_PERGUNT := 'Tipo de Saida'
		SX1->X1_VARIAVL := 'mv_ch4'
		SX1->X1_TIPO    := 'N'
		SX1->X1_TAMANHO := 1
		SX1->X1_DECIMAL := 0
		SX1->X1_PRESEL  := 1
		SX1->X1_GSC     := 'C'
		SX1->X1_VALID   := ''
		SX1->X1_VAR01   := 'MV_PAR04'
		SX1->X1_DEF01   := "Tela"
		SX1->X1_DEF02   := "Excel"
		MsUnlock()
	EndIf

	IF lViaWorkFlow
		MV_PAR04	:= 1
	EndIf

	If !DbSeek('IMDCXXXXXX')
		RecLock('SX1',.T.)
		SX1->X1_GRUPO   := 'IMDCXXXXXX'
		SX1->X1_ORDEM   := '05'
		SX1->X1_PERGUNT := 'Considera o dia?'
		SX1->X1_VARIAVL := 'mv_ch5'
		SX1->X1_TIPO    := 'N'
		SX1->X1_TAMANHO := 1
		SX1->X1_DECIMAL := 0
		SX1->X1_PRESEL  := 2
		SX1->X1_GSC     := 'C'
		SX1->X1_VALID   := ''
		SX1->X1_VAR01   := 'MV_PAR05'
		SX1->X1_DEF01   := "Sim"
		SX1->X1_DEF02   := "N„o"
		MsUnlock()
	EndIf

	IF lViaWorkFlow
		MV_PAR05	:= 1 // Considera o dia? SIM
	EndIf

	Return()
	*******************************************************************************
Static Function nomeGerente(ccodigo)//Traz o nome da filial
	*******************************************************************************

	Local pos := Ascan( aCodGer, ccodigo )
	If pos <> 0
		Return aNome_Ger[ pos ]
	Else
		Return 'Indefinida'
	EndIf

	Return()
	*******************************************************************************
Static Function lancaValor( cclienteOUger, cloja, tipo, valor,par1)//Atualiza os valores de aCols
	*******************************************************************************

	Local ind, filialCol  // Filial extraida da coluna nome+filial

	IF par1 = "GERENTE"
		cgerentedocliente := cclienteOUger
	ELSE
		cgerentedocliente := u_BUSCAGERENTE(cclienteOUger,cloja)
	EndIf

	For ind := 1 To Len( aCols )
		cgerenteAtual := aCols[ ind, X_COD_GER ]

		If cgerenteAtual == cgerentedocliente  .AND.  aCols[ ind , X_TIPO ] == tipo
			aCols[ ind, X_VALOR  ] += valor
			exit
		EndIf
	Next ind

	Return

	*******************************************************************************
User Function diasUteis( dataLimite , yfilial, dDataInicial ) //| Retorna o no. de dias uteis do ano/mes ate a data limite
	*******************************************************************************

	Local area   := GetArea()
	Private ndUtil := 0   // total de dias uteis
	//Private nMes   := Month( dataLimite )
	//Private nAno   := Year( dataLimite  )
	Private dDtIni
	Private regional // Feriado regional

	If dDataInicial == NIL
		dDtIni := FirstDay(dataLimite)
	Else
		dDtIni := dDataInicial
	EndIf

	While   dDtIni <= datalimite
		If DataValida(dDtIni) == dDtIni
			// Consulta tabela de feriados regionais
			dbSelectArea('SX5')
			dbSetOrder(1)
			dbSeek(XFilial('SX5')+'I8'+ yfilial )
			regional := .F.
			Do While !Eof() .AND. SX5->X5_TABELA == 'I8' .AND.  Left( SX5->X5_CHAVE,2 )== yfilial
				If Left(SX5->X5_DESCRI,5) == Left( DTOC( dDtIni ),5 )  // verificar dia e mes
					regional := .T.
					Exit
				EndIf
				dbSkip()
			Enddo
			If !regional
				ndUtil++  //somatorio de dias ˙teis considerando os feriados regionais
			EndIf
		EndIf
		dDtIni++
	EndDo
	RestArea( area )

	Return nDUtil
	*******************************************************************************
Static Function MetaMes( ccodgerente, aDados )
	*******************************************************************************

	Local nMeta := 0, nPosMet := 0

	Default aDados := aMetaGer

	nPosMet := aScan(aDados, {|x| x[1]==ccodgerente})

	If nPosMet > 0
		nMeta := aDados[nPosMet,2]
	EndIf

	Return nMeta
	*******************************************************************************
User Function BUSCAGERENTE(par_cliente,par_loja)
	*******************************************************************************

	Local	cgerente
	Local   carea 	:= GetArea()

	dbSelectArea("SA1")
	dbsetorder(1)

	IF dbseek(xFilial("SA1")+par_cliente+par_loja)
		cgerente := SA1->A1_GERVEN
	ELSE
		cgerente := REPLICATE(" ",TamSx3("A3_COD" )[1])
	EndIf

	RestArea( carea )

	Return(cgerente)
	*******************************************************************************
User Function CARGAGERENTES(codigo)
	*******************************************************************************

	//*************************************************************************
	//	CARGA DOS GERENTES  PARA AS PERGUNTAS
	//*************************************************************************
	// Seleciona os vendedores considerados Gerentes atravÈs do cadastro de clientes, campo A1_GERVEN
	Local   carea 	:= GetArea()
	Local	lretorno

	cQuery := ""
	cQuery += "SELECT  SA3.A3_COD COD_GER"
	cQuery += "	FROM "+RetSqlName("SA3")+" SA3, "+RetSqlName("SA1")+" SA1"
	cQuery += " WHERE 	SA1.A1_GERVEN <> ' '"
	cQuery += " 	AND SA3.A3_COD = SA1.A1_GERVEN"
	cQuery += " 	AND SA3.A3_COD = '" + codigo + "'"
	cQuery += "		AND SA3.A3_FILIAL = SA1.A1_FILIAL"
	cQuery += "		AND SA1.D_E_L_E_T_ = ' '"
	cQuery += "		AND SA3.D_E_L_E_T_ = ' '"
	cQuery += "		GROUP BY SA3.A3_COD"
	cQuery += "		ORDER BY SA3.A3_COD"

	IF SELECT( 'FGG' ) <> 0
		dbSelectArea('FGG')
		Use
	EndIf

	TCQUERY cQuery NEW ALIAS ('FGG')

	DbselectArea("FGG")
	DBGOTOP()

	IF !EMPTY(FGG->COD_GER)
		lretorno := .T.

	ELSE
		lretorno := .F.
	EndIf

	DBSELECTAREA( carea )

	RETURN(lretorno)
	*******************************************************************************
Static Function CAMPOS()//| Campos que Definem a Filial e o Gerente, para estruturaÁ„o do RelatÛrio...
	*******************************************************************************

	Local lachou := .F., lachouSA3 := .F.,lachouSUA := .F., cordem :=""

	dbSelectArea("SX3");dbsetorder(1);dbgotop()
	IF DBSEEK("SA3")
		Do while SX3->X3_ARQUIVO == "SA3" .AND. !EOF()
			IF ALLTRIM(SX3->X3_CAMPO) == "A3_CODFIL"
				lachouSA3 := .T.
			EndIf
			dbskip()
		ENDDO
		IF !lachouSA3
			cordem := ProxOrdem("SA3")
			RECLOCK("SX3", .T.)
			SX3->X3_ARQUIVO	:= "SA3"
			SX3->X3_ORDEM	:= cordem
			SX3->X3_CAMPO	:= "A3_CODFIL"
			SX3->X3_TIPO	:= "C"
			SX3->X3_TAMANHO	:= 2
			SX3->X3_DECIMAL	:= 0
			SX3->X3_TITULO	:= "COD FILIAL"
			SX3->X3_TITSPA	:= "COD FILIAL"
			SX3->X3_TITENG	:= "COD FILIAL"
			SX3->X3_DESCRIC	:= "Filial do Vendedor       "
			SX3->X3_DESCSPA	:= "Filial do Vendedor       "
			SX3->X3_DESCENG	:= "Filial do Vendedor       "
			SX3->X3_USADO	:= "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ†"
			SX3->X3_F3		:= "SM0"
			SX3->X3_NIVEL	:= 0
			SX3->X3_RESERV	:= "˛A"
			SX3->X3_PROPRI	:= "U"
			SX3->X3_BROWSE	:= "S"
			SX3->X3_VISUAL	:= "A"
			SX3->X3_CONTEXT	:= "R"
			SX3->X3_OBRIGAT	:= "Ä"
			MSUNLOCK()
		EndIf
	EndIf

	dbgotop()
	IF DBSEEK("SUA")
		Do while SX3->X3_ARQUIVO == "SUA" .AND. !EOF()
			IF ALLTRIM(SX3->X3_CAMPO) == "UA_GERVEN"
				lachouSUA := .T.
			EndIf
			dbskip()
		ENDDO
		IF !lachouSUA
			cordem := ProxOrdem("SUA")
			RECLOCK("SX3", .T.)
			SX3->X3_ARQUIVO	:= "SUA"
			SX3->X3_ORDEM	:= cordem
			SX3->X3_CAMPO	:= "UA_GERVEN"
			SX3->X3_TIPO	:= "C"
			SX3->X3_TAMANHO	:= 6
			SX3->X3_DECIMAL	:= 0
			SX3->X3_TITULO	:= "Gerente"
			SX3->X3_TITSPA	:= "Gerente"
			SX3->X3_TITENG	:= "Manager"
			SX3->X3_DESCRIC	:= "CÛdigo do Gerente       "
			SX3->X3_DESCSPA	:= "Codigo del Gerente      "
			SX3->X3_DESCENG	:= "Manager¥s Code          "
			SX3->X3_USADO	:= "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ†"
			SX3->X3_RELACAO := ""     //"u_BUSCAGERENTE(M->UA_CLIENTE, M->UA_LOJA)†"
			SX3->X3_F3		:= "A3M"
			SX3->X3_NIVEL	:= 5
			SX3->X3_RESERV	:= "˛A"
			SX3->X3_PROPRI	:= "U"
			SX3->X3_BROWSE	:= "N"
			SX3->X3_VISUAL	:= "V"
			SX3->X3_CONTEXT	:= "R"
			SX3->X3_OBRIGAT	:= ""
			MSUNLOCK()
		EndIf
	EndIf
	IF lachouSA3 .OR. lachouSUA
		lachou := .T.
	EndIf

	Return(lachou)
	*******************************************************************************
Static Function ProxOrdem(alias)// Verifica a OrdenaÁ„o do Campo...
	*******************************************************************************

	Local cpxordem := ""
	Local carea := getarea()
	local nrecno:= recno()

	DBSelectArea("SX3");dbsetorder(1);dbgotop()
	IF DBSEEK(alias)
		Do While SX3->X3_ARQUIVO == alias .AND. !EOF()
			cpxordem := SX3->X3_ORDEM
			DBSKIP()
		EndDO

		cpxordem := u_item(cpxordem)

	ELSE
		cpxordem := "01"
	EndIf

	dbselectarea(carea)
	DbGotop(nRecNo)

	return(cpxordem)
	*******************************************************************************
User Function Item(cpar1)
	*******************************************************************************

	IF EMPTY(cpar1)
		cpar1 := "00"
	END
	citem 	:= ""
	cN0_A	:= SUBSTR(cpar1,2,1)
	cN1_A	:= SUBSTR(cpar1,1,1)
	nN0_D	:= ASC(cN0_A)
	nN1_D   := ASC(cN1_A)

	IF nN1_D >= 48 .AND. nN1_D < 57

		IF nN0_D >= 48 .AND. nN0_D < 57
			nN0_D++
		ELSEIF nN0_D = 57
			nN0_D := 48
			nN1_D++
		EndIf

	ELSEIF nN1_D = 57
		IF nN0_D >= 48 .AND. nN0_D < 57
			nN0_D++
		ELSEIF nN0_D = 57
			nN0_D := 65
			nN1_D := 65
		EndIf
	ELSEIF nN1_D >= 65 .AND. nN1_D < 90  //DE A ‡ Z
		IF (nN0_D >= 65 .AND. nN0_D < 90) .OR. (nN0_D >= 48 .AND. nN0_D < 57)
			nN0_D++
		ELSEIF nN0_D = 90
			nN0_D := 48
			nN1_D++
		ELSEIF nN0_D = 57
			nN0_D := 65
			nN1_D++
		EndIf
	EndIf
	cN0_A	:= CHR(nN0_D)
	cN1_A	:= CHR(nN1_D)

	citem := cN1_A + cN0_A

	RETURN(citem)

	*******************************************************************************
Static Function GeraEmail(_aCols)//Monta HTML para envio
	*******************************************************************************
	Local _aCols

	aCols := _aCols

	//Ajusta Array para trabalhar com HTML
	For x:= 1 To Len( aCols )
		For Y := 1 To Len( aCols[X] )
			IF	ValType( aCols[X][Y] ) == 'C'
				IF Empty( aCols[X][Y] )
					aCols[X][Y] := '<BR>
				EndIf
			EndIf

		Next Y
	Next x

	cHtml := ""

	cHtml += ' <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">'

	cHtml += '<HTML>'
	cHtml += '<HEAD>'

	cHtml += '	<META HTTP-EQUIV="CONTENT-TYPE" CONTENT="text/html; charset=windows-1252">'
	cHtml += '	<TITLE></TITLE>'
	cHtml += '	<META NAME="GENERATOR" CONTENT="BrOffice.org 2.3  (Win32)">'
	cHtml += '	<META NAME="AUTHOR" CONTENT="MARCIO">'
	cHtml += '	<META NAME="CREATED" CONTENT="20080424;16044000">'
	cHtml += '	<META NAME="CHANGEDBY" CONTENT="MARCIO">'
	cHtml += '	<META NAME="CHANGED" CONTENT="20080424;17155800">'

	cHtml += '	<STYLE>'
	cHtml += '		<!-- '
	cHtml += '		BODY,DIV,TABLE,THEAD,TBODY,TFOOT,TR,TH,TD,P { font-family:"Arial"; font-size:x-small }'
	cHtml += '		 -->'
	cHtml += '	</STYLE>'

	cHtml += '</HEAD>'

	cHtml += '<BODY TEXT="#000000">'
	cHtml += '<TABLE FRAME=VOID CELLSPACING=0 COLS=7 RULES=NONE BORDER=0>'
	cHtml += '	<COLGROUP><COL WIDTH=197><COL WIDTH=115><COL WIDTH=36><COL WIDTH=128><COL WIDTH=151><COL WIDTH=94><COL WIDTH=86></COLGROUP>'
	cHtml += '	<TBODY>'
	cHtml += '		<TR>'
	cHtml += '			<TD STYLE="border-top: 3px solid #000000; border-bottom: 3px solid #000000; border-left: 3px solid #000000; border-right: 3px solid #000000" COLSPAN=7 WIDTH=806 HEIGHT=17 ALIGN=CENTER BGCOLOR="#00FFFF"><B>Metas On-Line II &ndash; Scheduled</B></TD>' //cHtml += '			<TD STYLE="border-top: 3px solid #000000; border-bottom: 3px solid #000000; border-left: 3px solid #000000; border-right: 3px solid #000000" COLSPAN=7 WIDTH=806 HEIGHT=17 ALIGN=CENTER BGCOLOR="#00FFFF"><B>Metas On-Line II &ndash; Scheduled</B></TD>'
	cHtml += '			</TR>'
	cHtml += '		<TR>'
	cHtml += '			<TD HEIGHT=17 ALIGN=LEFT><BR></TD>'
	cHtml += '			<TD ALIGN=LEFT><BR></TD>'
	cHtml += '			<TD ALIGN=LEFT><BR></TD>'
	cHtml += '			<TD ALIGN=LEFT><BR></TD>'
	cHtml += '			<TD ALIGN=LEFT><BR></TD>'
	cHtml += '			<TD ALIGN=LEFT><BR></TD>'
	cHtml += '			<TD ALIGN=LEFT><BR></TD>'
	cHtml += '		</TR>'
	cHtml += '		<TR>'
	cHtml += '			<TD STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" HEIGHT=17 ALIGN=LEFT BGCOLOR="#99CCFF"><B>Nome Gerente</B></TD>'
	cHtml += '			<TD STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" ALIGN=LEFT BGCOLOR="#99CCFF"><B>C&oacute;digo Gerente</B></TD>'
	cHtml += '			<TD STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" ALIGN=LEFT BGCOLOR="#99CCFF"><B>Tipo</B></TD>'
	cHtml += '			<TD STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" ALIGN=LEFT BGCOLOR="#99CCFF"><B>Grupo</B></TD>'
	cHtml += '			<TD STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" ALIGN=LEFT BGCOLOR="#99CCFF"><B>Descri&ccedil;&atilde;o</B></TD>'
	cHtml += '			<TD STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" ALIGN=LEFT BGCOLOR="#99CCFF"><B>Valor</B></TD>'
	cHtml += '			<TD STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" ALIGN=LEFT BGCOLOR="#99CCFF"><B>(%)</B></TD>'
	cHtml += '		</TR>'

	FOR X:=1 TO LEN(aCols)

		cHtml += '		<TR>'
		cHtml += '			<TD STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" HEIGHT=17 ALIGN=LEFT SDNUM="1046;0;@">' + aCols[x][X_NOME_GER] + '</TD>'
		cHtml += '			<TD STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" ALIGN=LEFT SDNUM="1046;0;@">' + aCols[x][X_COD_GER] + '</TD>'
		cHtml += '			<TD STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" ALIGN=LEFT SDNUM="1046;0;@">' + aCols[x][X_TIPO] + '</TD>'
		cHtml += '			<TD STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" ALIGN=LEFT SDNUM="1046;0;@">' + aCols[x][X_GRUPO] + '</TD>'
		cHtml += '			<TD STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" ALIGN=LEFT SDNUM="1046;0;@">' + aCols[x][X_DESCRI] + '</TD>'
		cHtml += '			<TD STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" ALIGN=RIGHT SDVAL="11041034,06" SDNUM="1046;0;#.##0,00">' + TRANSFORM(aCols[x][X_VALOR],'@E 99,999,999.99') + '</TD>'
		cHtml += '			<TD STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" ALIGN=RIGHT SDVAL="110,63" SDNUM="1046;">' + TRANSFORM(aCols[x][X_PERCENT],'@E 99,999,999.99') + '</TD>'
		cHtml += '		</TR>'

	NEXT X

	cHtml += '		<TR>'
	cHtml += '			<TD HEIGHT=17 ALIGN=LEFT><BR></TD>'
	cHtml += '			<TD ALIGN=LEFT><BR></TD>'
	cHtml += '			<TD ALIGN=LEFT><BR></TD>'
	cHtml += '			<TD ALIGN=LEFT><BR></TD>'
	cHtml += '			<TD ALIGN=LEFT><BR></TD>'
	cHtml += '			<TD ALIGN=LEFT><BR></TD>'
	cHtml += '			<TD ALIGN=LEFT><BR></TD>'
	cHtml += '		</TR>'
	//linha de observaÁıes

	For x:= 1 TO LEN(aHtmlObsEmail)

		IF x == 1
			cHtml += '		<TR>'
			cHtml += '			<TD HEIGHT=17 ALIGN=LEFT><B>Observa&ccedil;&otilde;es:</B></TD>'
			cHtml += '			<TD ALIGN=LEFT><BR></TD>'
			cHtml += '			<TD ALIGN=LEFT><BR></TD>'
			cHtml += '			<TD ALIGN=LEFT><BR></TD>'
			cHtml += '			<TD ALIGN=LEFT><BR></TD>'
			cHtml += '			<TD ALIGN=LEFT><BR></TD>'
			cHtml += '			<TD ALIGN=LEFT><BR></TD>'
			cHtml += '		</TR>'
		EndIf

		cHtml += '		<TR>'
		cHtml += '			<TD COLSPAN=7 HEIGHT=17 ALIGN=LEFT>'+ aHtmlObsEmail[x] +'</TD>'
		cHtml += '			</TR>'

	NEXT x

	cHtml += '		<TR>'
	cHtml += '			<TD HEIGHT=17 ALIGN=LEFT><BR></TD>'
	cHtml += '			<TD ALIGN=LEFT><BR></TD>'
	cHtml += '			<TD ALIGN=LEFT><BR></TD>'
	cHtml += '			<TD ALIGN=LEFT><BR></TD>'
	cHtml += '			<TD ALIGN=LEFT><BR></TD>'
	cHtml += '			<TD ALIGN=LEFT><BR></TD>'
	cHtml += '			<TD ALIGN=LEFT><BR></TD>'
	cHtml += '		</TR>'

	cHtml += '		<TR>'
	cHtml += '			<TD COLSPAN=7 HEIGHT=17 ALIGN=LEFT><B>Gerado via Workflow </B></TD>'
	cHtml += '			</TR>'

	cHtml += '	</TBODY>'
	cHtml += '</TABLE>'
	cHtml += '<!-- ************************************************************************** -->'
	cHtml += '</BODY>'

	cHtml += '</HTML>'

	Return()
	*******************************************************************************
Static Function EnviaEmail(cTipo,cCodG)//Envia o Html Gerado
	*******************************************************************************

	Local cTipo
	Local cCodG
	Local cServer 	:= GetMV("MV_RELSERV" )
	Local cAccount 	:= Alltrim(GETMV("MV_RELACNT"))
	Local cPassword 	:= Alltrim(GETMV("MV_RELPSW"))
	Local lAuth 		:= Getmv("MV_RELAUTH")
	Local cAssunto  	:= cNomProg + ' - Data da GeraÁ„o: '+ DTOC(dDatabase)
	Local cEmailTo  	:= " "
	Local cEmailBcc	:= ""
	Local cAnexo   	:= " "
	Local lResult  	:= .F.
	Local cError   	:= ""
	Local nMV         := 1

	IF cTipo = "G"

		cEmailGer := ALLTRIM(POSICIONE("SA3",1,XFILIAL("SA3")+cCodG,"A3_EMAIL"))
		cFilGer   := ALLTRIM(POSICIONE("SA3",1,XFILIAL("SA3")+cCodG,"A3_CODFIL"))
		cEmailAss := ALLTRIM(SUPERGETMV("MV_EASSV",.F.,, cFilGer))

		cEmailTo := cEmailGer +","+cEmailAss

		IF ! EMPTY(GETMV("MV_RECMOG"))  // E-MAILs QUE RECEBERAO O RELATORIO DOS GERENTES
			cEmailTo += ALLTRIM(GETMV("MV_RECMOG"))
		EndIf

	EndIf

	IF cTipo = "T"

		DBSELECTAREA("SX6")
		DBSETORDER(1)

		nMV:= 1

		WHILE DBSEEK(xFilial("SX6")+"MV_EMMOL"+STRZERO(nMV,2)) // E-MAILs QUE RECEBERAO O RELATORIO GERAL

			cEmailTo += ALLTRIM(X6_CONTEUD)
			nMV += 1

		END

	EndIf

	// conectando-se com o servidor de e-mail
	Conout(cNomProg + " - Conectando com o Servidor de Email")
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

	If lResult .And. lAuth
		lResult := MailAuth(cAccount,cPassword)
		If !lResult
			lResult := QADGetMail() // Funcao que abre uma janela perguntando o usuario e senha para fazer autenticacao
		EndIf
		If !lResult
			//Erro na conexao com o SMTP Server
			GET MAIL ERROR cError
			Conout(cNomProg + " -  Erro de Autenticacao")
			//			MsgInfo(cError,OemToAnsi("Erro de Autenticacao"))
			Return Nil
		EndIf
	Else
		If !lResult
			//Erro na conexao com o SMTP Server
			GET MAIL ERROR cError
			Conout(cNomProg + " - Erro de Conexao")
			//			MsgInfo(cError,OemToAnsi("Erro de Conexao"))
			Return Nil
		EndIf
	EndIf

	// enviando e-mail
	If lResult
		Conout(cNomProg + " - Enviando Email para " + cEmailTo + cEmailBcc )

		/* TESTE
		SEND MAIL FROM cAccount ;
		TO "cristiano.machado@imdepa.com.br" ;
		CC "" ;
		*/


		SEND MAIL FROM cAccount ;
		TO IIF(lTeste,ALLTRIM(GETMV("MV_ECONTTI")),cEmailTo ) ;  //		TO			cEmailTo ; //		BCC     	cEmailBcc ;
		CC IIF(lTeste,ALLTRIM(GETMV("MV_ANALITI")),ALLTRIM(GETMV("MV_ECONTTI"))+cEmailBcc) ;
		SUBJECT 	cAssunto ;
		BODY    	cHtml ;
		ATTACHMENT  cAnexo ;
		RESULT lResult

		If !lResult
			//Erro no envio do email
			GET MAIL ERROR cError
			Conout(cNomProg + " - Nao Enviou Email - " + cError)
		EndIf
		//		DISCONNECT SMTP SERVER
	EndIf

	DISCONNECT SMTP SERVER

	Return()

	//| Analista: Cristiano Machado - Chamado: 14677 - Data 03/03/2017
	*******************************************************************************
Static Function MontaDtTri(dDataConsiderada, cDtTriIni, cDtTriFim ) //| Monta as Datas para serem usadas nas Selecoes de Trimestres Trimestres
	*******************************************************************************

	Static Tri1I   := "01" 	//| Mes inicial do Trimestre 1
	Static Tri1F   := "03" 	//| Mes final do Trimestre 1
	Static Tri2I   := "04" 	//| Mes inicial do Trimestre 1
	Static Tri2F   := "06"	//| Mes final do Trimestre 1
	Static Tri3I   := "07" 	//| Mes inicial do Trimestre 1
	Static Tri3F   := "09" 	//| Mes finaldo Trimestre 1
	Static Tri4I   := "10" 	//| Mes inicial do Trimestre 1
	Static Tri4F   := "12" 	//| Mes finaldo Trimestre 1

	If 		StrZero(Month(dDataConsiderada),2) >= Tri1I .And. StrZero(Month(dDataConsiderada),2) <= Tri1F // Trimestre 1 (Jan-Fev-Mar)
		cDtTriIni	:= cValToChar( Year( dDataConsiderada ) ) + Tri1I + "01"
		cDtTriFim	:= cValToChar( Year( dDataConsiderada ) ) + Tri1F + "31"

	ElseIf StrZero(Month(dDataConsiderada),2) >= Tri2I .And. StrZero(Month(dDataConsiderada),2) <= Tri2F // Trimestre 2 (Abr-Mai-Jun)
		cDtTriIni	:= cValToChar( Year( dDataConsiderada ) ) + Tri2I + "01"
		cDtTriFim	:= cValToChar( Year( dDataConsiderada ) ) + Tri2F + "30"

	ElseIf StrZero(Month(dDataConsiderada),2) >= Tri3I .And. StrZero(Month(dDataConsiderada),2) <= Tri3F // Trimestre 3 (Jul-Ago-Set)
		cDtTriIni	:= cValToChar( Year( dDataConsiderada ) ) + Tri3I + "01"
		cDtTriFim	:= cValToChar( Year( dDataConsiderada ) ) + Tri3F + "30"

	ElseIf StrZero(Month(dDataConsiderada),2) >= Tri4I .And. StrZero(Month(dDataConsiderada),2) <= Tri4F // Trimestre 4 (Out-Nov-Dez)
		cDtTriIni	:= cValToChar( Year( dDataConsiderada ) ) + Tri4I + "01"
		cDtTriFim	:= cValToChar( Year( dDataConsiderada ) ) + Tri4F + "31"

	EndIf

	conout("Data Trimestre : " +cDtTriIni+ " - " +cDtTriFim)

	Return

	//| Analista: Cristiano Machado - Chamado: 14677 - Data 03/03/2017
	*******************************************************************************
Static Function QueryNfs(cPeriodo, cTAlias)//| Executa a Query Nf's Emitidas,  com Parametro D-Dia, M-Mes ou T-Trimestre
	*******************************************************************************
	Local cQuery := ""

	cQuery := "SELECT  SC5.C5_VEND5 GERENTE, SUM(D2_TOTAL) VALOR"
	cQuery += "  FROM "+RetSqlName("SD2")+" SD2, "+RetSqlName("SF4")+" SF4 ," +RetSqlName("SC5")+" SC5 "
	cQuery += " WHERE SD2.D2_FILIAL IN ( " + cFilImd + " ) "

	If  cPeriodo == "D" // Dia
		cQuery += "   AND SD2.D2_EMISSAO = '" + DTOS(dDataConsiderada) + "'"

	ElseIf 	cPeriodo == "M" // Mes
		cQuery += "   AND SD2.D2_EMISSAO >= '"+dataIni+"'"
		cQuery += "   AND SD2.D2_EMISSAO <= '"+dataFim+"'"

	ElseIf 	cPeriodo == "T" // Trimestre
		cQuery += "   AND SD2.D2_EMISSAO >= '"+cDtTriIni+"'"
		cQuery += "   AND SD2.D2_EMISSAO <= '"+cDtTriFim+"'"

	EndIf

	cQuery += "   AND F4_FILIAL = D2_FILIAL 	"
	cQuery += "   AND F4_CODIGO = D2_TES 		"
	cQuery += "   AND D2_FILIAL = C5_FILIAL		"
	cQuery += "   AND SD2.D2_PEDIDO = SC5.C5_NUM	"

	// Jorge Oliveira - 21/12/2010 - Nao mostra movimentacoes de Clientes para esse Gerente
	// Exemplo da variavel cFilGerente := '000207', '000467'
	// Exemplo da variavel cFilGerente := ''
	cQuery += "   AND SC5.C5_VEND5 NOT IN (" + cFilGerente + ") "

	//cQuery += " 		AND SD2.D2_TIPO <> 'B'"
	//cQuery += " 		AND SD2.D2_TIPO <> 'D'"

	cQuery += "   AND SD2.D2_TIPO NOT IN ( 'B', 'D','P','I') "

	cQuery += "   AND SD2.D2_ORIGLAN <> 'LF'	"
	cQuery += "   AND SF4.F4_DUPLIC = 'S'		"
	cQuery += "   AND SF4.F4_ESTOQUE = 'S' 	"  // Adici. verif. TES Gera Estoque, compatibilizando com Rel.Fat.por Vendedor
	cQuery += "   AND SD2.D_E_L_E_T_ = ' '	"
	cQuery += "   AND SF4.D_E_L_E_T_  = ' '	"
	cQuery += "   AND SC5.D_E_L_E_T_  = ' '	" //adicionado 28/11/05 marcio
	cQuery += " GROUP BY SC5.C5_VEND5  "
	cQuery += " ORDER BY SC5.C5_VEND5  "

	MEMOWRIT("C:\SQLSIGA\QueryNfs_"+cTAlias+".TXT", cQuery)

	U_ExecMySql(cQuery, cTAlias, "Q", lCaptura)//| Dia -> _CN7,  Mes -> _CN8,  Tri -> _CT1

	TCSetField( cTAlias, 'VALOR'  , 'N',17 , 2 )

	Return

	//| Analista: Cristiano Machado - Chamado: 14677 - Data 03/03/2017
	*******************************************************************************
Static Function QueryDev(cPeriodo, cTAlias, aDados)//| Executa a Query Nf's Emitidas,  com Parametro D-Dia, M-Mes ou T-Trimestre
	*******************************************************************************

	// pego query de devoluÁ„o do relatorio matr580
	cQuery := "SELECT F2_CLIENTE CLIENTE,F2_LOJA LOJA, SUM(D1_TOTAL) VALOR
	cQuery += " FROM "+RetSqlName("SD1")+" SD1, "+RetSqlName("SF1")+" SF1 ," +RetSqlName("SF2")+" SF2, "+RetSqlName("SF4")+ " SF4 "
	cQuery += " WHERE D1_FILIAL = F1_FILIAL "
	cQuery += "	  AND D1_FILIAL = F2_FILIAL "
	cQuery += "	  AND D1_FILIAL = F4_FILIAL "

	If  cPeriodo == "D" // Dia
		cQuery += "   AND D1_DTDIGIT = '" + DTOS(dDataConsiderada) + "' "

	ElseIf 	cPeriodo == "M" // Mes
		cQuery += "   AND D1_DTDIGIT >= '"+dataIni+"' "
		cQuery += "   AND D1_DTDIGIT <= '"+dataFim+"' "

	ElseIf 	cPeriodo == "T" // Trimestre

		cQuery += "   AND D1_DTDIGIT >= '"+cDtTriIni+"' "
		cQuery += "   AND D1_DTDIGIT <= '"+cDtTriFim+"' "

	EndIf

	cQuery += "   AND D1_TIPO = 'D'"
	cQuery += "   AND F4_CODIGO  = D1_TES"

	// Jorge Oliveira - 21/12/2010 - Nao mostra movimentacoes de Clientes para esse Gerente
	// Exemplo da variavel cFilGerente := '000207', '000467'
	// Exemplo da variavel cFilGerente := ''
	cQuery += "   AND F2_VEND5 NOT IN (" + cFilGerente + ") "

	cQuery += "   AND F4_ESTOQUE = 'S'   "
	cQuery += "   AND F4_DUPLIC = 'S'   "

	cQuery += "   AND F2_DOC     = D1_NFORI   "
	cQuery += "   AND F2_SERIE   = D1_SERIORI "
	cQuery += "   AND F2_CLIENTE = D1_FORNECE "
	cQuery += "   AND F2_LOJA    = D1_LOJA "
	cQuery += "   AND F1_DOC     = D1_DOC     "
	cQuery += "   AND F1_SERIE   = D1_SERIE"
	cQuery += "   AND F1_FORNECE = D1_FORNECE"
	cQuery += "   AND F1_LOJA    = D1_LOJA"
	cQuery += "   AND SD1.D_E_L_E_T_ = ' '"
	cQuery += "   AND SF4.D_E_L_E_T_ = ' '"
	cQuery += "   AND SF2.D_E_L_E_T_ = ' '"
	cQuery += "   AND SF1.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY F2_CLIENTE,F2_LOJA "

	MEMOWRIT("C:\SQLSIGA\QueryDev_"+cTAlias+".TXT", cQuery)
	U_ExecMySql(cQuery, cTAlias, "Q", lCaptura)

	TCSetField( cTAlias, 'VALOR'  , 'N',17 , 2 )
	dbSelectArea(cTAlias)

	dbGotop()
	aDados := {}
	do while !Eof()
		//nPosDevDia 		:= aScan(aDados, {|x| x[1]==u_BUSCAGERENTE((&cTAlias)->CLIENTE,(&cTAlias)->LOJA)})
		nPosDevDia 		:= aScan(aDados, {|x| x[1]==u_BUSCAGERENTE(CLIENTE,LOJA)})
		If nPosDevDia > 0
			//aDados[nPosDevDia,2] := aDados[nPosDevDia,2] + (&cTAlias)->VALOR
			aDados[nPosDevDia,2] := aDados[nPosDevDia,2] + VALOR
		Else
			//aAdd(aDados,{ U_BUSCAGERENTE((&cTAlias)->CLIENTE,(&cTAlias)->LOJA) , (&cTAlias)->VALOR } ) //	aAdd(aDados,{_CNA->CLIENTE,_CNA->LOJA, _CNA->VALOR})
			aAdd(aDados,{ U_BUSCAGERENTE(CLIENTE,LOJA) , VALOR } ) //	aAdd(aDados,{_CNA->CLIENTE,_CNA->LOJA, _CNA->VALOR})
		EndIf
		dbSkip()

	EndDo

	Return

	//| Analista: Cristiano Machado - Chamado: 14677 - Data 03/03/2017
	*******************************************************************************
Static Function QueryMet(cPeriodo, cTAlias, aDados)//| Executa a Query Metas,  com Parametro M-Mes ou T-Trimestre
	*******************************************************************************

	cQuery := "SELECT CT_VEND META_GERENTE, SUM(CT_VALOR) META_MFAT "
	cQuery += "  FROM "+retSqlname('SCT')
	cQuery += " WHERE D_E_L_E_T_  = ' ' "

	If 	cPeriodo == "M" // Mes
		cQuery += "   AND CT_DATA >= '"+ cData1 + "' "
		cQuery += "   AND CT_DATA <= '"+ cData1 + "' "

	ElseIf 	cPeriodo == "T" // Trimestre

		cQuery += "   AND CT_DATA >= '"+ cDtTriIni + "' "
		cQuery += "   AND CT_DATA <= '"+ cDtTriFim + "' "

	EndIf

	cQuery += "   AND CT_MARCA   = '"+space(len(SCT->CT_MARCA))+"'"
	cQuery += "   AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
	cQuery += "   AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
	cQuery += "   AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
	cQuery += "   AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
	cQuery += "   AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
	cQuery += "   AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
	cQuery += "   AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
	cQuery += "   AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
	cQuery += "   AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
	cQuery += "   AND CT_GRPSEGT = '"+space(len(SCT->CT_GRPSEGT))+"'"
	cQuery += "   AND CT_CLIENTE = '"+space(len(SCT->CT_CLIENTE))+"'"
	cQuery += "   AND CT_MARCA3  = '"+space(len(SCT->CT_MARCA3))+"'"
	cQuery += "   GROUP BY CT_VEND "

	MEMOWRIT("C:\SQLSIGA\QueryMet_"+cTAlias+".TXT", cQuery)

	U_ExecMySql(cQuery, cTAlias, "Q", lCaptura)

	TCSetField( cTAlias, 'META_MFAT'  , 'N',17 , 2 )
	dbSelectArea(cTAlias);dbGoTop()

	While !Eof()
		aAdd(aDados,{META_GERENTE,META_MFAT})
		dbSkip()
	Enddo

Return
