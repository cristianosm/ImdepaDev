#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include "Fileio.ch"

#Define UMSEGUNDO 1000

/*----------------------------------------------------------------------------+
|Fonte: Relatorio Percentual de Ocupação por Endereço                         |
+-----------------------------------------------------------------------------+
|Analista: Cristiano Machado                                                  |
|                                                                             |
|Data    : 12/12/2018                                                         |
+-----------------------------------------------------------------------------+
+----------------------------------------------------------------------------*/
*******************************************************************************
User Function RPercOcup()
*******************************************************************************

	Private oProcess 	:= Nil // Objeto que armazena Barra de execução
	Private lEnd 		:= Nil // Variavel para Cancelar execucao

	oProcess := MsNewProcess():New( {|lEnd| ExecRel()(@oProcess, @lEnd)} , "Gerando Relatório  - Percentual de Ocupação... ", "", .T. )
	oProcess:Activate()

	
Return Nil
*******************************************************************************
Static Function ExecRel()
*******************************************************************************

	oProcess:SetRegua1(5)
	oProcess:SetRegua2(0)
	
	//|Prepara Variaveis
	oProcess:IncRegua1("Preparando Variaveis...")
	PrepVar()

	//| Preprara Parametros de Usuário
	oProcess:IncRegua1("Preparando Parâmetros...")
	OpenPar()

	//| Executa Query
	oProcess:IncRegua1("Verificando Endereços...")
	ExecQuery()

	//| Exporta para CSV
	oProcess:IncRegua1("Exportando Resultado...")
	ExpCsv()

	// Envio por e-mail 
	EnviaEmail()

Return()
*******************************************************************************
Static Function PrepVar() //|Prepara Variaveis
*******************************************************************************
	
	oProcess:IncRegua2() ; Sleep( UMSEGUNDO )
	
	_SetOwnerPrvt( 'cTab'		, "POE"	) //| Nome da Tabela auxiliar utilizada na Query |
	_SetOwnerPrvt( 'cSql'		, ""	) //| Variavel usada na consulta |
	_SetOwnerPrvt( 'cNomeFile' 	, ""	)
	_SetOwnerPrvt( 'nHandle'	, ""	)
	_SetOwnerPrvt( 'cLinha'		, ""	)
	_SetOwnerPrvt( 'cEnter'		, CHR(13) + CHR(10) )
	_SetOwnerPrvt( 'cExt'		, ".csv" )
	_SetOwnerPrvt( 'nTotalReg'	, 0     )

Return Nil
*******************************************************************************
Static Function OpenPar() //| Preprara Parametros de Usuário
*******************************************************************************

Local aHelpPor01	:= {'Informar o Codifo da filial que deve ser' , 'avaliada.                               ' , ' ' 			}
Local aHelpPor02	:= {'Informar Codigo do Estoque que deve ser ' , 'avaliado. Para todos preencher com "ZZ".' , ' ' 			}
Local aHelpPor03	:= {'Informar o Codigo do Enreço que deve ser ', 'avaliado. Para todos preencher com      ' , '"ZZZZZZZZZZZZZZZ".'	}
Local aHelpPor04	:= {'Informar Email que ira receber relatório' , 'Exemplo: "fulano@dominio.com.br".       ' , ' '				}

oProcess:IncRegua2() ; Sleep( UMSEGUNDO )

PutSx1('HTOCUP', '01', 'Filial             ', ' ', ' ', 'mv_cha', 'C', 02, 0, 0, 'G','','','','', 'mv_par01','','','','','','','','','','','','','','','','', aHelpPor01, '' , '' )
PutSx1('HTOCUP', '02', 'Local              ', ' ', ' ', 'mv_chb', 'C', 02, 0, 0, 'G','','','','', 'mv_par02','','','','','','','','','','','','','','','','', aHelpPor02, '' , '' )
PutSx1('HTOCUP', '03', 'Endereco           ', ' ', ' ', 'mv_chc', 'C', 15, 0, 1, 'G','','','','', 'mv_par03','','','','','','','','','','','','','','','','', aHelpPor03, '' , '' )
PutSx1('HTOCUP', '04', 'Email              ', ' ', ' ', 'mv_chd', 'C', 50, 0, 2, 'G','','','','', 'mv_par04','','','','','','','','','','','','','','','','', aHelpPor04, '' , '' )


Pergunte("HTOCUP",.T.)

Return Nil
*******************************************************************************
Static Function ExecQuery() //| Executa Query
*******************************************************************************

oProcess:IncRegua2() ; Sleep( UMSEGUNDO )

cSql := ""
cSql += "SELECT ROWNUM REGISTRO, TABELA.* FROM (

cSql += "SELECT		BFF_FILIAL,	BFF_PRODUTO, BFF_LOCALIZ,	BF_LOCAL, BF_QUANT,	BF_ESTFIS,	DC3_CODNOR, B1_DESC , "
cSql += "			(	DECODE( DC2_LASTRO, 0, 1, DC2_LASTRO )* DECODE( DC2_CAMADA, 0, 1, DC2_CAMADA ) ) DC2_QTDLIM, "
cSql += "				ROUND(	(BF_QUANT) / (	DECODE( DC2_LASTRO, 0, 1, DC2_LASTRO ) * DECODE( DC2_CAMADA, 0, 1, DC2_CAMADA )) * 100	, 2 ) DC2_PEROCU "
cSql += ""
cSql += "FROM "
cSql += "			(	SELECT	BF_FILIAL,	BF_LOCALIZ,	BF_PRODUTO,	BF_LOCAL, BF_ESTFIS,	SUM( BF_QUANT ) BF_QUANT "
cSql += "				FROM		SBF010	 "
cSql += "				WHERE	BF_LOCAL IN(	'01','02') "
cSql += "					AND BF_LOCALIZ > '               ' "
cSql += "					AND BF_LOCALIZ <> 'DOCA' "
cSql += "					AND D_E_L_E_T_ = ' ' "
cSql += "				GROUP BY 	BF_FILIAL,	BF_LOCALIZ,	BF_PRODUTO,	BF_LOCAL, BF_ESTFIS	) BF "
cSql += ""
cSql += "	INNER JOIN DC3010 C3 ON "
cSql += "			BF_FILIAL = DC3_FILIAL "
cSql += "			AND BF_PRODUTO = DC3_CODPRO "
cSql += "			AND BF_ESTFIS = DC3_TPESTR "
cSql += "			AND BF_LOCAL = DC3_LOCAL "
cSql += ""
cSql += "	INNER JOIN DC2010 C2 ON "
cSql += "			BF_FILIAL  = DC2_FILIAL "
cSql += "			AND DC3_CODNOR = DC2_CODNOR "
cSql += ""
cSql += "	INNER JOIN DC8010 C8 ON "
cSql += "			DC8_FILIAL =  '"+xFilial("DC8")+"' "
cSql += "			AND DC8_CODEST = BF_ESTFIS "

cSql += "	INNER JOIN (SELECT B1_FILIAL, B1_COD, B1_DESC FROM SB1010 WHERE D_E_L_E_T_ = ' ' ) B1 ON "
cSql += "			BF_FILIAL = B1_FILIAL  "
cSql += "			AND BF_PRODUTO = B1_COD  "

cSql += "" // Filtro da Query
cSql += "	INNER JOIN(	SELECT	BF_FILIAL BFF_FILIAL,	BF_LOCAL BFF_LOCAL,BF_LOCALIZ BFF_LOCALIZ,	BF_PRODUTO BFF_PRODUTO "
cSql += "				FROM 	SBF010 "

cSql += "				WHERE  
	If ( MV_PAR01 == "ZZ" ) // Filial
		cSql += "			BF_FILIAL < '"+MV_PAR01+"' "
	Else
		cSql += "			BF_FILIAL = '"+MV_PAR01+"' "					
	EndIf
	If ( MV_PAR02 == "ZZ" ) // Local 
		cSql += "       AND BF_LOCAL < '"+MV_PAR02+"' "
	Else
		cSql += "       AND BF_LOCAL = '"+MV_PAR02+"' "
	EndIf
	If ( Alltrim(MV_PAR03) == "ZZZZZZZZZZZZZZZ" ) // Endereço
		cSql += "		AND	BF_LOCALIZ < '"+MV_PAR03+"' "
	Else	
		cSql += "		AND	BF_LOCALIZ = '"+MV_PAR03+"' "
	EndIf
cSql += "					AND BF_LOCALIZ <> 'DOCA' "
cSql += "					AND D_E_L_E_T_ = ' ' "
cSql += "				GROUP BY 	BF_FILIAL, BF_LOCAL,	BF_LOCALIZ, BF_PRODUTO ) DB ON "			
cSql += "			BFF_FILIAL  = BF_FILIAL "
cSql += "			AND BFF_LOCALIZ = BF_LOCALIZ "
cSql += "			AND BFF_PRODUTO = BF_PRODUTO "
cSql += "			AND BFF_LOCAL   = BF_LOCAL "		
cSql += "" // Fim do Filtro
cSql += "		WHERE	C3.D_E_L_E_T_ = ' ' "
cSql += "			AND C2.D_E_L_E_T_ = ' ' "
cSql += "			AND C8.D_E_L_E_T_ = ' ' "
cSql += "		ORDER BY BFF_FILIAL, BFF_LOCALIZ, BFF_PRODUTO	 "

cSql += " 	 ) TABELA ORDER BY 1 "

U_ExecMySql( cSql , cCursor := cTab, cModo := "Q", lMostra := .F., lChange := .F.)

TCSetField( cCursor, "REGISTRO"		, "N", 9	, 0 ) 
TCSetField( cCursor, "BF_QUANT"		, "N", 12	, 2 ) 
TCSetField( cCursor, "DC2_QTDLIM"	, "N", 12	, 2 ) 
TCSetField( cCursor, "DC2_PEROCU"	, "N", 9	, 0 ) 


DbSelectArea(cTab);DbGoTop()
While !EOF()
	nTotalReg += 1
	DbSkip()
EndDo


Return Nil
*******************************************************************************
Static Function ExpCsv() //| Exporta para CSV
*******************************************************************************
Local nCount := 0

oProcess:IncRegua2() ; Sleep( UMSEGUNDO )

cNomeFile 	:= CriaTrab( Nil,.F.)
nHandle		:= FCreate ( cNomeFile + cExt, FC_NORMAL , Nil , .T. )

cCab := "FILIAL;LOCAL;ENDEREÇO;ESTRUTURA;NORMA;PRODUTO;DESCRIÇÃO;QUANTIDADE;LIMITE ENDEREÇO; % OCUPAÇÃO;" + cEnter
FWrite ( nHandle, cCab, Len(cCab) )

oProcess:SetRegua2(nTotalReg)

DbSelectArea(cTab);DbGoTop()
While !Eof()
	
	nCount += 1

	cLinha := ""
	cLinha += "'" + BFF_FILIAL		+ ";"
	cLinha += "'" + BF_LOCAL		+ ";"
	cLinha += "'" + BFF_LOCALIZ		+ ";"
	cLinha += "'" + BF_ESTFIS		+ ";"
	cLinha += "'" + DC3_CODNOR		+ ";"
	cLinha += "'" + BFF_PRODUTO		+ ";"
	cLinha += "'" + Alltrim(B1_DESC)+ ";"
	cLinha += XV(   BF_QUANT    )	+ ";"
	cLinha += XV(   DC2_QTDLIM  )	+ ";"
	cLinha += XV(   DC2_PEROCU  )	+ " % ;"

	cLinha += cEnter

	FWrite ( nHandle, cLinha, Len(cLinha) )
	
	oProcess:IncRegua2("Registro " + XV(nCount) +" de " + XV(nTotalReg) )
	
	DbSelectArea(cTab)
	DbSkip()

EndDo

FClose( nHandle )

DbSelectArea(cTab)
DbCloSeArea()


Return Nil
*******************************************************************************
Static Function EnviaEmail() // Envio por anexo o CSV
*******************************************************************************
Local cFrom 	:= "protheus@imdepa.com.br"
Local cTo		:= Alltrim(MV_PAR04)
Local cBcc		:= ""
Local cSubject	:= "Relatório % de Ocupacao"
Local cAttach	:= "\SYSTEM\" + cNomeFile+".csv"
Local cbody		:= cEnter + cEnter +  " Segue anexo arquivo contendo o Relatório em formato CSV..." + cEnter + cEnter + "     Nome: " +cNomeFile + ".csv"
Local cRet		:= ""

cRet := U_EnvMyMail( cFrom, cTo, cBcc, cSubject, cBody, cAttach ) //| U_EnvMyMail(De, Para, Copia, Assunto, Corpo, Anexo )

If !Empty(cRet)
	IW_MsgBox("Erro no Envio !!! " + cRet, "Atenção", "ALERT" )
EndIf

Return()
*******************************************************************************
Static Function XV(X)
*******************************************************************************
X := cValToChar(X)
X := StrTran(X, '.', ',' , Nil, Nil)

Return(X)