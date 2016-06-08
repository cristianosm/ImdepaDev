#Include 'Protheus.ch'

#Define 	ORA_ER942  	"ORA-00942"
//#Define 	ORA_ER001  	"ORA-00942" //ERRO: unique constraint  violated
//#Define 	NUMTABSX2   5635

#Define     _SIM_		1
#Define     _NAO_		2

#Define 	_TODAS_		1
#Define 	_EXIST_		2
#Define 	_NEHUMA_	3

*******************************************************************************
User Function Check_TopField()
*******************************************************************************

	Local oProcess 	:= Nil
	Local lEnd		:= Nil
	Local cScript	:= Nil
	
	Private oError 		:= ErrorBlock( {|e| u_CaixaTexto("Mensagem de Erro: "+ chr(10) + e:Description, "cristiano.machado@imdepa.com.br") } )   
	Private lShowSql 	:= .F.
	Private lContinua 	:= .T.
	
	SysErrorBlock( {|e| u_CaixaTexto("Mensagem de Erro: "+ chr(10) + e:Description, "cristiano.machado@imdepa.com.br") }  )
	
	While lContinua //If Iw_MsgBox( "Deseja Recriar a Tabela TOP_FIELD ?? ", "TOP_FIELD", "YESNO" )
		
		oProcess := lEnd := cScript := Nil
		
		If Perguntas()
		
			oProcess := MsNewProcess():New( {|lEnd| Verifica(@oProcess, @lEnd)} , "Recriando Top_Field...", "", .T. )
			oProcess:Activate()
		
		EndIf
		
	EndDo
		
Return()
*******************************************************************************
Static Function Verifica(oProcess, lEnd)
*******************************************************************************
	Local cRet 		:= ""
	Local cSql 		:= ""
	Local btabOk	:= {|| If(AT(ORA_ER942,cRet)>0,.F.,.T.) }
	Local x2Alias	:= ""
	Local x2Table	:= ""
	Local cLine		:= Nil

	Local cFTable	:= ""
	Local cFName	:= ""
	Local cFType	:= ""
	Local cFPrec	:= ""
	Local cFDec 	:= ""

	Local bInsert 	:= {|| cInsert := "Insert into TOP_FIELD (FIELD_TABLE,FIELD_NAME,FIELD_TYPE,FIELD_PREC,FIELD_DEC) values ( '"+cFTable+"', '"+cFName+"', '"+cFType+"', '"+cFPrec+"', '"+cFDec+"')" }
	Local bInsHas   := {|| cInsHas := "Insert into TOP_FIELD (FIELD_TABLE,FIELD_NAME,FIELD_TYPE,FIELD_PREC,FIELD_DEC) values ( 'SIGA."+x2Table+"','@@HAS_DFT_VAL@@','X','0','0') " }
	Local bDelCpo   := {|| cDelCpo := "Delete Top_Field Where FIELD_TABLE = '"+cFTable+"' And FIELD_NAME = '"+cFName+"'  " }
	
	
	oProcess:SetRegua1( VerTamSx2() )
	oProcess:SetRegua2( 0 )

	If MV_PAR05 == _SIM_
		lContinua := .F.
		Return()
	EndIf

	If MV_PAR01 == _SIM_ // Só trunca caso a Pergunta seja SIM....
		cRet := U_ExecMySql("Truncate Table TOP_FIELD","","E",lShowSql)
	EndIf
		
	DbSelectArea("SX3");DbSetOrder(1);dbGotop()
	DbSelectArea("SX2");DbGotop()
	DbSeek(MV_PAR02,.F.)
	While !EOF() .And.  SX2->X2_ARQUIVO <= MV_PAR03

		x2Table	:= Alltrim(SX2->X2_ARQUIVO)
		x2Alias	:= Alltrim(SX2->X2_CHAVE)
	
		oProcess:IncRegua1("Analisando Tabela: " + x2Table )
	
		cSql := " Select * From " + x2Table + " Where RowNum = 1 "
		cRet := U_ExecMySql(cSql,"","E",lShowSql)
	
		lExist_Table := Eval(btabOk) // Confirma que a Tabela Existe no Banco...
	 
	 //| Deleta a chave padrao da tabela caso exista ....
		cFTable := "SIGA."+x2Table
		cFName  := "@@HAS_DFT_VAL@@" 
		cRet := U_ExecMySql( Eval(bDelCpo),"","E",lShowSql)
		 
		// Cria a Chave na Top_Field Padrao da Tabela
		cRet := U_ExecMySql( Eval(binsHas),"","E",lShowSql)
		
		DbSelectArea("SX3")
		DbSeek(x2Alias,.F.)
		
		While Alltrim(SX3->X3_ARQUIVO) == Alltrim(x2Alias)
			
			oProcess:IncRegua2(	PadR("Analisando Campo...:",20) + SX3->X3_CAMPO )
			
			If Sx3ToTop(@cFTable, @cFName, @cFType, @cFPrec, @cFDec ) // Alimneta as Variaveis envolvidas e se deve ser criado...
				
				//| Deleta o Campos Caso Exista....
				oProcess:IncRegua2( PadR("Deletando Campo....:",20) + SX3->X3_CAMPO  )
				cRet := U_ExecMySql( Eval(bDelCpo),"","E",lShowSql)
				
				//| Insere a Nova Config do Campo ...
				oProcess:IncRegua2( PadR("Inserindo Campo....:",20) + SX3->X3_CAMPO  )
				cRet := U_ExecMySql( Eval(bInsert),"","E",lShowSql)
			
			EndIf
		
			DbSelectArea("SX3")
			DbSkip()
			
		EndDo
		
		If Mv_Par04 <> _NEHUMA_
			
			If MV_PAR04 == _TODAS_ .Or. (MV_PAR04 == _EXIST_ .And. lExist_Table )
			
			Begin Sequence  
				
				oProcess:IncRegua2("DbSelectArea.......:"+x2Alias   )
				DbSelectArea(x2Alias)
				
				oProcess:IncRegua2("TcRefresh..........:"+x2Alias  )
				TcRefresh( x2Table )
				
				oProcess:IncRegua2("ChkFile............:"+x2Alias  )
				ChkFile( x2Alias, .F.  ) //, .F. , x2Alias)
		
				oProcess:IncRegua2("TcRefresh..........:"+x2Alias  )
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


Return()
*******************************************************************************
Static Function VerTamSx2()
*******************************************************************************
	Local cCond :=  "X2_ARQUIVO >= '"+MV_PAR02+"' .And. X2_ARQUIVO <= '"+MV_PAR03+"' "
	Local cCAll	:=  "X2_ARQUIVO >= '   '"
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
	Local lRet		:= .T.
	
	// Tabela 
	cFTable			:= Alltrim("SIGA."+ SX2->X2_ARQUIVO)
	
	//| Campo
	cFName			:= Alltrim(SX3->X3_CAMPO)
	
	// Tipo do Campo
	If SX3->X3_TIPO <> "C" //| Somente os Campos Nao Caracteres Fazem Parte devem ser inseridos na Top_Field
		Do Case
		Case SX3->X3_TIPO == "N" //| Numerico
			cFType 	:= "P"
		
		Case SX3->X3_TIPO == "D" //| Data
			cFType 	:= "D"
		
		Case SX3->X3_TIPO == "M" //| Memo
			cFType 	:= "M"
		
		Case SX3->X3_TIPO == "L" //| Logico
			cFType 	:= "L"
		
		EndCase

		//| Tamanho do Campo
		cFPrec	   	:= Alltrim(cValToChar(SX3->X3_TAMANHO))
		
		//| Decimal do Campo
		cFDec	   	:= Alltrim(cValToChar(SX3->X3_DECIMAL))

	Else
		cFTable	:= cFName := cFType := cFPrec := cFDec := ""
		lRet := .F.
	EndIf

Return(lRet)
*******************************************************************************
Static Function Perguntas()
*******************************************************************************

	PutSx1("CHETOPF","01"    ,"Truncar TOP_FIELD ?"  			,""      ,""        ,"MV_CH0"  ,"C"    ,1         ,0         ,0        ,"C"   ,"","","","","MV_PAR01","Sim"		,"Sim"	  	,"Sim"		,"" 	,"Nao"	   		,"Nao"     		,"Nao"     		,""         ,""         ,""         ,""        ,""        ,""        ,""      ,""        ,""        ,{""}    ,{""}    ,{""}    )
	PutSx1("CHETOPF","02"    ,"Tabela Inicial: 	  "  			,""      ,""        ,"MV_CH1"  ,"C"    ,3         ,0         ,0        ,"G"   ,"","","","","MV_PAR02",""       ,""       	,""       	,""     ,""        		,""        		,""        		,""         ,""         ,""         ,""        ,""        ,""        ,""      ,""        ,""        ,{""}    ,{""}    ,{""}    )
	PutSx1("CHETOPF","03"    ,"Tabela Final:      "  			,""      ,""        ,"MV_CH2"  ,"C"    ,3         ,0         ,0        ,"G"   ,"","","","","MV_PAR03",""       	,""       	,""       	,""     ,""        		,""        		,""        		,""         ,""         ,""         ,""        ,""        ,""        ,""      ,""        ,""        ,{""}    ,{""}    ,{""}    )
	PutSx1("CHETOPF","04"    ,"Abrir Tabela (CheckFile) ?"   	,""      ,""        ,"MV_CH3"  ,"C"    ,1         ,0         ,0        ,"C"   ,"","","","","MV_PAR04","Todas"	,"Todas"	,"Todas"	,"" 	,"Existentes"	,"Existentes"	,"Existentes"	,"Nenhuma"  ,"Nenhuma"  ,"Nenhuma"  ,"" 	   ,""        ,""        ,""      ,""        ,""        ,{""}    ,{""}    ,{""}    )
	PutSx1("CHETOPF","05"    ,"Deseja Sair ?      "  			,""      ,""        ,"MV_CH4"  ,"C"    ,1         ,0         ,0        ,"C"   ,"","","","","MV_PAR05","Sim"		,"Sim"	  	,"Sim"		,"" 	,"Nao"	   		,"Nao"     		,"Nao"     		,""         ,""         ,""         ,""        ,""        ,""        ,""      ,""        ,""        ,{""}    ,{""}    ,{""}    )

Return(Pergunte("CHETOPF",.T.))