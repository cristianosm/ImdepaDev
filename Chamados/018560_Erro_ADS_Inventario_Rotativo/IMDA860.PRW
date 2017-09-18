#Include "Protheus.ch"
#Include "FileIO.ch"
#Include "topconn.ch"
#Include "fileio.ch"
#Include "ap5mail.ch"
#Include "protheus.ch"
#Include "tbiconn.ch"

#Define CRLF ( Chr( 13 ) + Chr( 10 ) )

*******************************************************************************
User Function IMDA860( )// Inventario Rotativo
	*******************************************************************************

	Local aDados    := {}
	Local cperg	 	:= 'MDA860'
	Local aHlp_Par08:= {}
	Private aMovSDB :={}

	aAdd( aHlp_Par08, "Considera produtos inventariados  " )
	aAdd( aHlp_Par08, "com data de contagem a partir de um número determinado número de dias " )

	aAdd(aDados,{ "Do Produto ?   ","Do Produto ?   ","Do Produto    ?","mv_ch1","C", 08,0,0,"G","          ","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","" })
	aAdd(aDados,{ "Até o Produto ?","Até o Produto ?","Até o Produto ?","mv_ch2","C", 08,0,0,"G","          ","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","" })

	aAdd(aDados,{ "Do Local ?  ","Do Local ?  ","Do Local ?  ","mv_ch3","C", 02,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
	aAdd(aDados,{ "Até o Local ? ","Até o Local ? ","Até o Local ? ","mv_ch4","C", 02,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","" })

	aAdd(aDados,{ "Do Grupo ?      ","Do Grupo ?     ","Do Grupo ?     ","mv_ch5","C", 04,0,0,"G","          ","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","" })
	aAdd(aDados,{ "Até o Grupo ?   ","Até o Grupo ?  ","Até o Grupo ?  ","mv_ch6","C", 04,0,0,"G","          ","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","" })

	aAdd(aDados,{ "Consid. Item Inventariado ?" ,"Consid. Item Inventariado ?","Consid. Item Inventariado ?" ,"mv_ch7","N", 1,0,0,"C",""        ,"mv_par07","Nao","Nao","Nao","","","Sim","Sim","Sim","","","","","","","","","","","","","","","","","","","" })
	aAdd(aDados,{ "Invent. a partir de ? (dias)","Invent. a partir de ? (dias) ","Invent. a partir de ? (dias) ","mv_ch8","N", 03,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","" })

	U_ImdASX1( cPerg, aDados )

	If Pergunte(cPerg,.T.)
		MsAguarde({ |lEnd| IMDA860c( )	,OemToAnsi('Consultando movimentos do produto')}, OemToAnsi('Movimentos do Produto'))
		MsAguarde({ |lEnd| IMDA860b( )	,OemToAnsi('Processando o relatório.')}, OemToAnsi('Saldos por Endereço'))
	Endif

	Return

	*******************************************************************************
Static Function IMDA860b( )
	*******************************************************************************

	Local cSql		   := ""
	Local cFolderC	   := "C:\mp11"
	Local cFFServe	   := "\"
	Local cCSVFile     := "inventario_rotativo"
	Local cTabAux        := "" //"\workflow\inventario_rotativo.csv"
	Local nQtdMov      := 0
	Local nPos         := 0

	Local _aStruct     := {{"FILIAL"	, "C", 02, 0 },;
	{"PRODUTO"	         , "C", 08, 0 },;
	{"ARMAZEM"	         , "C", 08, 0 },;
	{"DESCRICAO"	     , "C", 30, 0 },;
	{"ENDERECO"		     , "C", 15, 0 },;
	{"SALDO"			 , "N", 14, 0 },;
	{"QT_SEP"		     , "N", 14, 0 },;
	{"CONTADO"           , "C", 01, 0 } }

	//Apaga o arquivo local do usuário
	If( File( cCSVFile ) )
		fErase( cCSVFile )
	Endif

	cTabAux := U_MyFile( _aStruct, Nil, Nil, Nil, "TAUX", Nil, Nil )

	cSql:=" SELECT                                           "
	cSql+=" B1_FILIAL                   FILIAL             , "
	cSql+=" B1_COD                      PRODUTO            , "
	cSql+=" B1_DESC                     DESCRICAO          , "
	cSql+=" BF_LOCALIZ                  ENDERECO           , "
	cSql+=" BF_LOCAL                    ARMAZEM            , "
	cSql+=" SUM(BF_QUANT)               SALDO                "
	cSql+="  FROM "+RetSqlName("SBF")+" SBF, "
	cSql+=		    RetSQLName("SB2")+" SB2, "
	cSql+=		    RetSQLName("SB1")+" SB1  "
	cSql+= " WHERE BF_FILIAL = '"+xFilial("SBF")+"'"
	cSql+= " AND B1_FILIAL=BF_FILIAL "
	cSql+="  AND B2_FILIAL=BF_FILIAL "

	cSql+="  AND B1_COD   =BF_PRODUTO "
	cSql+="  AND B2_COD   =BF_PRODUTO "
	cSql+="  AND B2_LOCAL=BF_LOCAL "

	cSql +=" AND BF_LOCAL >= '" + MV_PAR03 + "' "
	cSql +=" AND BF_LOCAL <= '" + MV_PAR04 + "' "

	cSql +=" AND BF_PRODUTO >= '" + MV_PAR01 + "'"
	cSql +=" AND BF_PRODUTO <= '" + MV_PAR02 + "'"

	cSql +=" AND B1_GRUPO >= '" + MV_PAR05 + "'"
	cSql +=" AND B1_GRUPO <= '" + MV_PAR06 + "'"

	If MV_PAR07=1 // Tratamento para nao listar Itens ja Inventariados
		cSql+="  AND B2_DINVENT=' ' "
		//Else
		//cSql+=" AND  TO_CHAR( ADD_MONTHS( SYSDATE,0 ), 'yyyymmdd' )- B2_DINVENT  >= " +Str( MV_PAR08) + " "
	Endif

	cSql+="  AND SBF.D_E_L_E_T_  =' ' "
	cSql+="  AND SB2.D_E_L_E_T_  =' ' "
	cSql+="  AND SB1.D_E_L_E_T_  =' ' "

	cSql+=" GROUP BY B1_FILIAL, "
	cSql+="          B1_COD           , "
	cSql+="      	 B1_DESC          , "
	cSql+="      	 BF_LOCALIZ       , "
	cSql+="          BF_LOCAL           "
	cSql+=" ORDER BY PRODUTO,BF_LOCAL,BF_LOCALIZ "

	U_ExecMySql( cSql , "QRY_SBF" , "Q", .F., .F. )

	DbSelectArea("QRY_SBF");DbGotop()
	While !QRY_SBF->( EOF() )

		//Pesquisa se o produto possui movimentação no mês anterior
		nPos    := aScan(aMovSDB,{|x| x[1]+x[2] =QRY_SBF->PRODUTO+QRY_SBF->ARMAZEM})

		If nPos>0
			nQtdMov := aMovSDB[npos][3]
		Else     //Produto não teve movimentações dentro do mês anterior
			nQtdMov :=0
		Endif

		RecLock( "TAUX", .T. )
		TAUX->FILIAL    := QRY_SBF->FILIAL
		TAUX->PRODUTO   := QRY_SBF->PRODUTO
		TAUX->ARMAZEM  	:= QRY_SBF->ARMAZEM
		TAUX->DESCRICAO	:= QRY_SBF->DESCRICAO
		TAUX->ENDERECO  := QRY_SBF->ENDERECO
		TAUX->SALDO  	:= QRY_SBF->SALDO
		TAUX->QT_SEP    := nQtdMov
		TAUX->CONTADO   := 'N'

		MsUnLock()
		QRY_SBF->( dbSkip() )

	EndDo

	QRY_SBF->( dbCloseArea() )

	aTAux := U_TabToArray( "TAUX", .T. )// Joga o conteudo da tabela em array...

	cFFServe += U_ArrayToCsv( aTAux , cCSVFile, ';' )

	TAUX->( dbCloseArea() )

	If !CpyS2T( cFFServe, cFolderC, .F., .F. )
		Alert("Erro na Copia do Arquivo! Origem : "+cFFServe+" Destino: "+cFolderC+"\"+cCSVFile)
	EndIf

	Aviso('Inventario Rotativo ','Gerado arquivo no seguinte diretório'+CHR(10)+CHR(13)+cFolderC+cFFServe ,{'Ok'})

	SW_NORMAL:=1

	MsAguarde({ |lEnd|  ShellExecute ("open",cFolderC+cFFServe,"/play /close","",SW_NORMAL) 	,OemToAnsi('Abrindo arquivo '+cFolderC+cFFServe +' ...'  )}, OemToAnsi(' Inventário Rotativo'   ))

	Return

	*******************************************************************************
Static Function IMDA860C()//Rotina para listar produtos com movimentos do mes anterior
	*******************************************************************************
	Local cSql      :=' '

	cSql+=" SELECT db_produto, db_local, COUNT (db_localiz) AS qtd_mov "
	cSql+=" FROM "+RetSqlName("SDB")+" SDB, "
	cSql+=		   RetSQLName("SB1")+" SB1 "
	cSql+=" WHERE DB_FILIAL = '"+xFilial("SDB")+"'"
	cSql+=" AND   B1_FILIAL = '"+xFilial("SB1")+"'"
	cSql+=" AND   B1_COD    = DB_PRODUTO "
	cSql+=" AND   DB_PRODUTO >= '" + MV_PAR01 + "' "
	cSql+=" AND   DB_PRODUTO <= '" + MV_PAR02 + "' "
	cSql+=" AND   DB_LOCAL >= '" + MV_PAR03 + "' "
	cSql+=" AND   DB_LOCAL <= '" + MV_PAR04 + "' "

	cSql+=" AND B1_GRUPO >=  '" + MV_PAR05 + "' "
	cSql+=" AND B1_GRUPO <=  '" + MV_PAR06 + "' "

	cSql+=" AND DB_DATA  >= TO_CHAR(TRUNC(SYSDATE-30,'MM'),'yyyymmdd')  "              //Primeiro dia do mês anterior
	cSql+=" AND DB_DATA  <= TO_CHAR( last_day(ADD_MONTHS(SYSDATE, -1) ),'yyyymmdd' )"  //Último dia do mês anterior

	cSql+=" AND DB_ESTORNO <> 'S'"
	cSql+=" AND DB_SERVIC ='001' "
	cSql+=" AND DB_TAREFA ='002' "
	cSql+=" AND DB_LOCAL='01' "
	cSql+=" AND DB_LOCALIZ<>'DOCA'"
	cSql+=" AND SDB.D_E_L_E_T_ = ' '"
	cSql+=" AND SB1.D_E_L_E_T_ = ' '"
	cSql+=" GROUP BY DB_PRODUTO,DB_LOCAL"

	U_ExecMySql( cSql , "QRY_SDB" , "Q", .F., .F. )

	ProcRegua(0)

	If QRY_SDB->(Eof())
		aAdd( aMovSDB,{' ',' ',0})
	Endif

	Do While QRY_SDB->(!Eof())

		aAdd( aMovSDB,{QRY_SDB->DB_PRODUTO,QRY_SDB->DB_LOCAL,QRY_SDB->qtd_mov})

		QRY_SDB->(DbSKIP())
	EndDo

	Return

	*******************************************************************************
USER FUNCTION IMDA870()//Rotina para confirmar iventario
	*******************************************************************************

	LOCAL aArea           := GetArea()
	LOCAL Vc_Tipo         := ""
	LOCAL Vc_Tipo         := ""
	LOCAL Vc_Caminho      := ""
	LOCAL Vn_pos          := 1
	LOCAL Vc_Prog         := ""

	PRIVATE lGravou       := .f.
	PRIVATE nRegist       := 0

	Vc_Tipo        := "Arquivos CCS (*.CSV)        |*.CSV | "    //define variaveis para pesquisa de arquivos
	Vc_Tipo        := Vc_Tipo + "Todos os Arquivos  (*.*)   | *.*     "
	Vc_Caminho := " "

	Vc_Caminho := cGetFile(Vc_Tipo,"Arquivo a ser Importado") //executa fução de pesquisa de arquivo

	if Empty(Vc_Caminho)
		return
	end

	nHdl := FT_FUse(Vc_Caminho)   // Abre o arquivo

	If nHdl == NIL .Or. nHdl <= 0
		MsgInfo( "Não foi possível abrir o arquivo " + Chr(13) +;
		"Erro: " + AllTrim( Str( ferror(), 4 ) ) )
	Else

		If MsgYesNo( 'Confirma o processamento do arquivo abaixo ?'+Chr(10)+Chr(13)+Vc_Caminho, 'Inventário Rotativo' )

			Processa( { ||IMPARQ() }, "Importando", "Processando o arquivo, aguarde..." )

			If lGravou
				AVISO("Confirmacao de Inventário","Data Inventario atualizada com Sucesso !"+Chr(10)+Chr(13)+" Foram atualizado " + Alltrim(Str(nRegist)) + " Registros !" ,{"OK"} )
			Endif

		EndIf

	EndIf

	FT_FUSE()   // Fecha o arquivo

	RestArea( aArea )

	Return()

	*******************************************************************************
Static Function IMPARQ()
	*******************************************************************************
	Local cLinha          := ""
	Local cDelimitador    := ""
	Local aRat            := {}
	Local  _CodFil        :=' '
	Local cCodProd        :=' '
	Local cProdJaAtu      :=' '
	Local   cArmazem      :=' '

	DbSelectArea( "SB2" )
	DbSetOrder( 1 ) // B2_FILIAL+B2_COD+B2_LOCAL

	FT_FGoTop()  // Posiciona no inicio do arquivo - cabecario
	cLinha := FT_FReadLn()

	// Procura por algum delimitador
	cDelimitador := ""
	If At( ";", cLinha ) > 0
		cDelimitador := ";"
	ElseIf At( ",", cLinha ) > 0
		cDelimitador := ","
	ElseIf At( ":", cLinha ) > 0
		cDelimitador := ":"
	EndIf

	If Empty( cDelimitador )
		MsgInfo( 'Problemas na estrutura do arquivo: " ' + cArq  + ' "' + Chr( 13 ) +;
		'Não foram encontrados delimitadores de colunas como " ; " ou " , " ou " : " ' + Chr( 13 ) +;
		'Processamento cancelado.' )
		Return

	EndIf

	FT_FSKIP() //Posiciona na primeira linha de dados

	While !FT_FEOF()

		cLinha := FT_FReadLn()
		cLinha := AllTrim( Replace( cLinha, '"', "" ) )
		cLinha := AllTrim( Replace( cLinha, cDelimitador, ";" ) )
		cLinha := AllTrim( Replace( cLinha, ",", "." ) )

		nQtdelim  :=  LEN(ALLTRIM(cLinha)) - LEN(AllTrim( Replace( cLinha, ";", "" ) ))

		IF  nQtdelim < 21
			cLinha := cLinha + REPLICATE("; ",21-nQtdelim)
		ENDIF

		cLinha := AllTrim( Replace( cLinha, ";", "  ; " ) )
		cLinha := "; "+cLinha

		aRat := StrTokArr(cLinha,";")   // Converte a linha num array
		//    1    2       3         4        5     6      7    8
		//FILIAL;PRODUTO;LOCAL;DESCRICAO;ENDERECO;SALDO;QT_SEP;CONTADO

		_CodFil   :=StrZero(Val(ALLTRIM(aRat[1])) ,2)
		cCodProd  :=StrZero(Val(ALLTRIM( aRat[2])),8)
		cArmazem :=StrZero(Val(ALLTRIM( aRat[3])),2)

		Begin Transaction

			IF UPPER(ALLTRIM(ARAT[8]))= 'S'
				DbSelectArea( "SB2" )

				IF DBSEEK( _CodFil + cCodProd +SPACE(7)  + cArmazem )

					IF RECLOCK("SB2",.F.)
						SB2->B2_DINVENT := dDataBase
						SB2->( MsUnlock() )

						//Controle para contar os registros processados sem repetir o codigo do produto
						If cProdJaAtu <> SB2->B2_COD
							nRegist    := nRegist + 1
							cProdJaAtu :=SB2->B2_COD
						Endif

					ENDIF

					If ! lGravou
						lGravou := .t.
					Endif

				Else
					lGravou := .f.
				Endif
			ENDIF

		End Transaction

		FT_FSKIP()

	Enddo

Return()
