#Include "TopConn.ch"
#Include 'Protheus.ch'
#Include "Tbiconn.ch"

#Define ORA_ER942 "ORA-00942"
//#Define ORA_ER001 "ORA-00942" //ERRO: unique constraint violated
//#Define NUMTABSX2 5635

#Define _SIM_	1
#Define _NAO_	2

#Define _TODAS_	 1
#Define _EXIST_	 2
#Define _NEHUMA_ 3

*******************************************************************************
User Function Check_TopField()
	*******************************************************************************

	Local oProcess := Nil
	Local lEnd	:= Nil
	Local cScript	:= Nil

	Private oError 			:= ErrorBlock( {|e| conout( "Mensagem de Erro: "+ chr(10) + e:Description ) /*, "cristiano.machado@imdepa.com.br")**/ } )
	Private lShowSql 		:= .F.
	Private lContinua 		:= .T.
	Private lViaWorkFlow 	:= Type("dDatabase") == "U"// Se rodar via workflow, dDatabase só estara disponivel apos o Prepare Environment

	If lViaWorkFlow
		PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" FUNNAME 'Check_TopField'  TABLES 'SM0'
	EndIf
	
	SysErrorBlock( {|e| conout("Mensagem de Erro: "+ chr(10) + e:Description)/*, "cristiano.machado@imdepa.com.br")*/ } )

	While lContinua //If Iw_MsgBox( "Deseja Recriar a Tabela TOP_FIELD ?? ", "TOP_FIELD", "YESNO" )

		oProcess := lEnd := cScript := Nil

		If Perguntas()

			oProcess := MsNewProcess():New( {|lEnd| Verifica(@oProcess, @lEnd)} , "Recriando Top_Field...", "", .T. )
			oProcess:Activate()

		EndIf

	EndDo
	
	If lViaWorkFlow
		RESET ENVIRONMENT
	EndIf
		
	Return()
	*******************************************************************************
Static Function Verifica(oProcess, lEnd)
	*******************************************************************************
	Local cRet := ""
	Local cSql := ""
	Local btabOk	:= {|| If(AT(ORA_ER942,cRet)>0,.F.,.T.) }
	Local x2Alias	:= ""
	Local x2Table	:= ""
	Local cLine	:= Nil

	Local cFTable	:= ""
	Local cFName	:= ""
	Local cFType	:= ""
	Local cFPrec	:= ""
	Local cFDec := ""

	Local bInsert := {|| cInsert := "Insert into TOP_FIELD (FIELD_TABLE,FIELD_NAME,FIELD_TYPE,FIELD_PREC,FIELD_DEC) values ( '"+cFTable+"', '"+cFName+"', '"+cFType+"', '"+cFPrec+"', '"+cFDec+"')" }
	Local bInsHas := {|| cInsHas := "Insert into TOP_FIELD (FIELD_TABLE,FIELD_NAME,FIELD_TYPE,FIELD_PREC,FIELD_DEC) values ( 'SIGA."+x2Table+"','@@HAS_DFT_VAL@@','X','0','0') " }
	Local bDelCpo := {|| cDelCpo := "Delete Top_Field Where FIELD_TABLE = '"+cFTable+"' And FIELD_NAME = '"+cFName+"' " }

	oProcess:SetRegua1( VerTamSx2() )
	oProcess:SetRegua2( 0 )

	If MV_PAR05 == _SIM_
		lContinua := .F.
		Return()
	EndIf

	If MV_PAR01 == _SIM_ // So trunca caso a Pergunta seja SIM....
		cRet := ExecMySql("Truncate Table TOP_FIELD","","E",lShowSql)
	EndIf

	DbSelectArea("SX3");DbSetOrder(1);dbGotop()
	DbSelectArea("SX2");DbGotop()
	DbSeek(MV_PAR02,.F.)
	While !EOF() .And. SX2->X2_ARQUIVO <= MV_PAR03

		x2Table	:= Alltrim(SX2->X2_ARQUIVO)
		x2Alias	:= Alltrim(SX2->X2_CHAVE)

		oProcess:IncRegua1("Analisando Tabela: " + x2Table )

		cSql := " Select * From " + x2Table + " Where RowNum = 1 "
		cRet := ExecMySql(cSql,"","E",lShowSql)

		lExist_Table := Eval(btabOk) // Confirma que a Tabela Existe no Banco...

		//| Deleta a chave padrao da tabela caso exista ....
		cFTable := "SIGA."+x2Table
		cFName := "@@HAS_DFT_VAL@@"
		cRet := ExecMySql( Eval(bDelCpo),"","E",lShowSql)

		// Cria a Chave na Top_Field Padrao da Tabela
		cRet := ExecMySql( Eval(binsHas),"","E",lShowSql)

		DbSelectArea("SX3")
		DbSeek(x2Alias,.F.)

		While Alltrim(SX3->X3_ARQUIVO) == Alltrim(x2Alias)

			Procmem(oProcess,	PadR("Analisando Campo...:",20) + SX3->X3_CAMPO )

			If Sx3ToTop(@cFTable, @cFName, @cFType, @cFPrec, @cFDec ) // Alimneta as Variaveis envolvidas e se deve ser criado...

				//| Deleta o Campos Caso Exista....
				Procmem(oProcess, PadR("Deletando Campo....:",20) + SX3->X3_CAMPO )
				cRet := ExecMySql( Eval(bDelCpo),"","E",lShowSql)

				//| Insere a Nova Config do Campo ...
				Procmem(oProcess, PadR("Inserindo Campo....:",20) + SX3->X3_CAMPO )
				cRet := ExecMySql( Eval(bInsert),"","E",lShowSql)

			EndIf

			DbSelectArea("SX3")
			DbSkip()

		EndDo

		If Mv_Par04 <> _NEHUMA_

			If MV_PAR04 == _TODAS_ .Or. (MV_PAR04 == _EXIST_ .And. lExist_Table )

				Begin Sequence

					Procmem(oProcess,"DbSelectArea.......:"+x2Alias )
					DbSelectArea(x2Alias)

					Procmem(oProcess,"TcRefresh..........:"+x2Alias )
					TcRefresh( x2Table )

					Procmem(oProcess,"ChkFile............:"+x2Alias )
					ChkFile( x2Alias, .F. ) //, .F. , x2Alias)

					Procmem(oProcess,"TcRefresh..........:"+x2Alias )
					TcRefresh( x2Table )

				End Sequence

				ErrorBlock(oError)

			EndIf

			If Select(x2Alias) > 0
				DbCloseArea(x2Alias)
			EndIf

		EndIf

		cRet := ""

		DbSelectArea("SX2")
		DbSkip()

	EndDo

	lContinua := .F.

	Return()
	*******************************************************************************
Static Function VerTamSx2()
	*******************************************************************************
	Local cCond := "X2_ARQUIVO >= '"+MV_PAR02+"' .And. X2_ARQUIVO <= '"+MV_PAR03+"' "
	Local cCAll	:= "X2_ARQUIVO >= ' '"
	lOCAL nReg	:= 0
	DbSelectArea("SX2")
	dbSetFilter( &( '{|| ' + cCond + ' }' ), cCond )
	DbGotop()
	While !Eof()
		nReg += 1`
		DbSkip()
	EndDo

	dbSetFilter( &( '{|| ' + cCAll + ' }' ), cCAll )

	Return(nReg)
	*******************************************************************************
Static Function Sx3ToTop(cFTable, cFName, cFType, cFPrec, cFDec )
	*******************************************************************************
	Local lRet	:= .T.

	// Tabela
	cFTable	:= Alltrim("SIGA."+ SX2->X2_ARQUIVO)

	//| Campo
	cFName	:= Alltrim(SX3->X3_CAMPO)

	// Tipo do Campo
	If SX3->X3_TIPO <> "C" .And. !(SX3->X3_CONTEXT == 'V') //| Somente os Campos Nao Caracteres Fazem Parte devem ser inseridos na Top_Field
		Do Case
			Case SX3->X3_TIPO == "N" //| Numerico
			cFType := "P"

			Case SX3->X3_TIPO == "D" //| Data
			cFType := "D"

			Case SX3->X3_TIPO == "M" //| Memo
			cFType := "M"

			Case SX3->X3_TIPO == "L" //| Logico
			cFType := "L"

		EndCase

		//| Tamanho do Campo
		cFPrec	:= Alltrim(cValToChar(SX3->X3_TAMANHO))

		//| Decimal do Campo
		cFDec	:= Alltrim(cValToChar(SX3->X3_DECIMAL))

	Else
		cFTable	:= cFName := cFType := cFPrec := cFDec := ""
		lRet := .F.
	EndIf

	Return(lRet)
	*******************************************************************************
Static Function Perguntas()
	*******************************************************************************
/*
   //					   X1_PERGUNT			,X1_PERSPA	,X1_PERENG	,X1_VARIAVL	,X1_TIPO,X1_TAMANHO	,X1_DECIMAL	,X1_PRESEL	,X1_GSC	,X1_VALID	,X1_VAR01	,X1_DEF01	,X1_DEFSPA1	,X1_DEFENG1	,X1_CNT01	,X1_VAR02	,X1_DEF02		,X1_DEFSPA2		,X1_DEFENG2		,X1_CNT02	,X1_VAR03	,X1_DEF03	,X1_DEFSPA3	,X1_DEFENG3	,X1_CNT03	,X1_VAR04	,X1_DEF04	,X1_DEFSPA4	,X1_DEFENG4 ,X1_CNT04	,X1_VAR05	,X1_DEF05	,X1_DEFSPA5	,X1_DEFENG5	,X1_CNT05	,X1_F3	,X1_GRPSXG	,X1_PYME	,X1_HELP	,X1_PICTURE	,aHelpPor,aHelpEng,aHelpSpa
	FMX_AJSX1("CHETOPF" ,{"Truncar TOP_FIELD ?" 		,"" ,"" 		,"MV_CH0" 	,"C" 	,1 			,0 			,2 			,"C" 	,""			,"MV_PAR01"	,"Sim"		,"Sim"		,"Sim"		,"" 		,""			,"Nao"		 	,"Nao" 			,"Nao" 			,""			,"" 		,"" 		,"" 		,"" 		,"" 		,"" 		,"" 		,"" 		,"" 		,""			,""			,""			,""			,""			,""			,""		,""			,""			,""			,""			,{""} ,{""} ,{""} })
	FMX_AJSX1("CHETOPF" ,{"Tabela Inicial: " 			,"" ,"" 		,"MV_CH1" 	,"C" 	,3 			,0 			,0 			,"G" 	,""			,"MV_PAR02"	,"" 		,"" 		,"" 		,"" 		,""			,"" 		 	,"" 			,"" 			,""			,"" 		,"" 		,"" 		,"" 		,"" 		,"" 		,"" 		,"" 		,"" 		,""			,""			,""			,""			,""			,""			,""		,""			,""			,""			,""			,{""} ,{""} ,{""} })
	FMX_AJSX1("CHETOPF" ,{"Tabela Final: " 				,"" ,"" 		,"MV_CH2" 	,"C" 	,3 			,0 			,0 			,"G" 	,""			,"MV_PAR03"	,"" 		,"" 		,"" 		,"" 		,""			,"" 		 	,"" 			,"" 			,""			,"" 		,"" 		,"" 		,"" 		,"" 		,""			,"" 		,"" 		,"" 		,""			,""			,""			,""			,""			,""			,""		,""			,""			,""			,""			,{""} ,{""} ,{""} })
	FMX_AJSX1("CHETOPF" ,{"Abrir Tabela (CheckFile) ?" 	,"" ,"" 		,"MV_CH3" 	,"C" 	,1 			,0 			,2 			,"C" 	,""			,"MV_PAR04"	,"Todas"	,"Todas"	,"Todas"	,"" 		,""			,"Existentes"	,"Existentes" 	,"Existentes"	,""			,"Nenhuma" 	,"Nenhuma" ,"Nenhuma" 	,"" 		,"" 		,"" 		,"" 		,"" 		,"" 		,""			,""			,""			,""			,""			,""			,""		,""			,""			,""			,""			,{""} ,{""} ,{""} })
	FMX_AJSX1("CHETOPF" ,{"Deseja Sair ? " 				,"" ,"" 		,"MV_CH4" 	,"C" 	,1 			,0 			,2 			,"C" 	,""			,"MV_PAR05"	,"Sim"		,"Sim"		,"Sim"		,"" 		,""			,"Nao"		 	,"Nao" 			,"Nao" 			,""			,"" 		,"" 		,"" 		,"" 		,"" 		,"" 		,"" 		,"" 		,"" 		,""			,""			,""			,""			,""			,""			,""		,""			,""			,""			,""			,{""} ,{""} ,{""} })

	backup: SX1_CHETOPF.DTC

*/
	If lViaWorkFlow
	
		Pergunte("CHETOPF",.F.)
	
		MV_PAR01 := _SIM_ //_SIM_ 
		MV_PAR02 := "AA1"
		MV_PAR03 := "ZZZ"
		MV_PAR04 := _NEHUMA_
		MV_PAR05 := _NAO_
	
	Else
	
		Pergunte("CHETOPF",.T.)
		
	EndIf

	Return .T.
	*********************************************************************
Static Function CaixaTexto( cTexto , cMail)
	*********************************************************************

	Default cMail := ""

	__cFileLog := MemoWrite(Criatrab(,.F.)+".log",cTexto)

	Define FONT oFont NAME "Tahoma" Size 6,12
	Define MsDialog oDlgMemo Title "Leitura Concluida." From 3,0 to 340,550 Pixel

	@ 5,5 Get oMemo Var cTexto MEMO Size 265,145 Of oDlgMemo Pixel
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:=oFont

	//Define SButton From 153,205 Type 6 Action Send(cTexto) Enable Of oDlgMemo Pixel
	Define SButton From 153,245 Type 1 Action oDlgMemo:End() Enable Of oDlgMemo Pixel

	Activate MsDialog oDlgMemo Center

	Return(cTexto)
	*********************************************************************
Static Function ExecMySql( cSql , cCursor , lModo, lMostra, lChange )
	*********************************************************************
	Local nRet := 0
	Local cRet := "Executado Com Sucesso"

	Default lModo := "Q"
	Default lMostra := .F.
	Default lChange := .T.

	If lMostra
		cSql := CaixaTexto(cSql)
	EndIf

	If lModo == "Q" //| Query

		If lChange
			cSql := ChangeQuery(cSql)
		Else
			cSql := Upper(cSql)
		EndIf

		If( Select(cCursor) <> 0 )
			DbSelectArea(cCursor)
			DbCloseArea()
		EndIf

		TCQUERY cSql NEW ALIAS &cCursor.

	ElseIf lModo == "E" //| Comandos

		cSql := Upper(cSql)

		nRet := TCSQLExec(cSql)

		If nRet <> 0
			cRet := TCSQLError()
			If lmostra
				Iw_MsgBox(cRet)
			Endif
		Endif
		Return(cRet)

	ElseIf lModo == "P" //Procedure

		cSql := Upper(cSql)

		TCSQLExec("BEGIN")

		nRet := TCSPExec(cSql)

		If Empty(nRet)
			cRet := TCSQLError()

			If lmostra
				Iw_MsgBox(cRet)
			Endif
		Endif

		TCSQLExec("END")

		Return(cRet)

	Endif

Return()
*******************************************************************************
Static Function Procmem(oProcess, cTexto )
*******************************************************************************

	oProcess:IncRegua2( cTexto )

	conout(cTexto)

Return()