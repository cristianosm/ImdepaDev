#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ANALIZASX ºAutor  ³Cristiano Machado   º Data ³  05/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Analisa campos que existem no sx3 e nao existem no Banco deº±±
±±º          ³ Dados Criandos conforme parametros utilizado               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Imdepa Roalmentos                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*********************************************************************
User Function DbtoSx3()
*********************************************************************
Local oGrpA       	:= Nil 
Local oGrpB      	:= Nil 
Local bOk        	:= {||nOpcao:=1, oDlgTf:End() }
Local bCancel    	:= {||nOpcao:=0, oDlgTf:End() }
Local nOpcao     	:= 0

Private cDe     	:= Space(3)
Private cAte    	:= Space(3)
Private cModo	 	:= ""
Private cVeri	 	:= "Ambos"
Private aModo 		:=  {"Simulação","Execução"}
Private aVeri		:= {"Tabelas","Campos","Ambos"}
Private oDlgTf   	:= Nil
Private oProcess	:= Nil
Private oModo	 	:= Nil
Private oVeri	 	:= Nil
Private nTabelas	:= 0
//Private nCampos		:= 0

DEFINE MSDIALOG oDlgTf TITLE "Tabelas" From 1,1 to 250,190 of oMainWnd PIXEL

oGrpA  := TGroup():New( 15,05,50,090,"Atenção",oDlgTf,CLR_BLACK,CLR_WHITE,.T.,.F. )

@ 22,10 SAY "Esta Rotina irá sincronizar os " SIZE 100,7 PIXEL OF oDlgTf
@ 32,10 SAY "Campos e Indices entre Banco e " SIZE 100,7 PIXEL OF oDlgTf
@ 42,10 SAY "Sx3/Six - Dicinario do Sistema " SIZE 100,7 PIXEL OF oDlgTf

oGrpB  := TGroup():New( 55,05,130,090,"Filtro",oDlgTf,CLR_BLACK,CLR_WHITE,.T.,.F. )

@ 65,10 SAY "De" SIZE 30,7 PIXEL OF oDlgTf
@ 65,35 MSGET cDe PICTURE "@!" SIZE 30,7 F3 "SX2" PIXEL OF oDlgTf

@ 80,10 SAY "Até" SIZE 30,7 PIXEL OF oDlgTf
@ 80,35 MSGET cAte PICTURE "@!" SIZE 30,7 F3 "SX2" PIXEL OF oDlgTf

@ 95,10 SAY "Verifica:" SIZE 30,7 PIXEL OF oDlgTf
@ 95,35 MSCOMBOBOX oVeri VAR cVeri ITEMS aVeri SIZE 45,08 OF oDlgTf PIXEL Valid (!Empty(cVeri))

@ 110,10 SAY "Modo:" SIZE 30,7 PIXEL OF oDlgTf
@ 110,35 MSCOMBOBOX oModo VAR cModo ITEMS aModo SIZE 45,08 OF oDlgTf PIXEL Valid (!Empty(cModo))

ACTIVATE MSDIALOG oDlgTf ON INIT EnchoiceBar(oDlgTf,bOk,bCancel) Centered

If nOpcao == 1
	oProcess := MsNewProcess():New({|lEnd| RunProc(lEnd)},"Processando em Modo: "+cModo+"...","Lendo...",.T.)
	oProcess:Activate()
EndIf

Return()
*********************************************************************
Static Function RunProc(lEnd)
*********************************************************************
Local cFile   	:= ""
Local cMask   	:= "Arquivos Texto (*.TXT) |*.txt|"
Local cChave  	:= ""
Local lTable  	:= .F.
Local cExecSql	:= ""
Local lSemErro	:= .T.

Private cxEnter 	:= CHR(13)+CHR(10)
Private cTraco  	:= Replicate("-",130)+cxEnter
Private cLogTxt 	:= ""
Private cLogInsert 	:= ""
Private  lExec 		:= .F.


//| Ajusta Parametro De e Ate
cDe  := Iif(Empty(cDe)	,"AAA"	,cDe)
cAte := Iif(Empty(cAte)	,"ZZZ"	,cAte)
 

//| Confirmacao de Execucao
If cModo == "Execução"
	If !(Msgbox("Tem certeza que deseja Executar a operação em Modo: Execução !!!","Atenção","YESNO"))
		
		GeraLog( ".: Execução Abortada pelo OPERADOR !!!" )
		
		Return()
	Endif
	
	lExec := .T.
	
Endif

ObtemDados() //| Querys.... Arquivo de Trabalho TAUX

ProcArqTrab() //| Processa Arquivode Trabalho


Return()
*********************************************************************
Static Function ProcArqTrab()//| Processa Arquivode Trabalho
*********************************************************************
Local nContab 	:= 1
Local cTable  	:= ""

oProcess:SetRegua1(nTabelas)
oProcess:SetRegua2(0)

DbSelectArea("SX3");DbSetOrder(2)
DbSelectArea("TAUX");DbGotop()

cLogTxt := ".:: Sincroniza Banco com SX3Padrao  ::. Start = "+DtoS(Ddatabase)+" "+Time()+cxEnter+cxEnter+cxEnter
cLogTxt += " Tabela " + TAUX->TABELA + cxEnter + cxEnter
cTable  := TAUX->TABELA
oProcess:IncRegua1("Lendo Tabela: "+AllTrim(Str(nContab))+" / "+AllTrim(Str(nTabelas))+" - "+Alltrim(TAUX->TABELA))
	
DbSelectArea("TAUX")
While !EOF()
   
	oProcess:IncRegua2("Verificando Campo : "+TAUX->CAMPO)
	
	DbSelectArea("SX3")
	If DbSeek(TAUX->CAMPO,.F.) //| Campo Existe ??
     	
     	If TAUX->TIPO = 'C' .AND. 
		

	Else 
		
		//| Comando 
		cSql := " Alter Table "+TAUX->TABELA+" Drop Column "+TAUX->CAMPO    
	
    EndIf


	If !Empty(cSql) //| Grava LOG
		cLogTxt += cSql + cxEnter
	EndIf

    
	// Em Modo Execucao ira enviar o commando para o Banco 
	If lExec
		cErro := U_ExecMySql( cSql , "" , "E" )			
			
		If !Empty(cErro) //| Controle de Erros...
			cLogTxt += cxEnter + cxEnter + cErro + cxEnter + cxEnter
			cErro := ""
		EndIf
		
	EndIf

    
	DbSelectArea("TAUX");DbSkip()
	cSql := ""

	If cTable <> TAUX->TABELA .And. !EOF()
		nContab += 1
		oProcess:IncRegua1("Lendo Tabela: "+AllTrim(Str(nContab))+" / "+AllTrim(Str(nTabelas))+" - "+Alltrim(TAUX->TABELA))
		cLogTxt += cxEnter + cxEnter + " Tabela " + TAUX->TABELA + cxEnter + cxEnter
		cTable	:= TAUX->TABELA 
	EndIf

EndDo


cLogTxt += cxEnter + cxEnter + "End = " + DtoS(Ddatabase) + " " + Time()

GeraLog( cLogTxt )

Return()
*********************************************************************
Static Function ObtemDados()//| Querys.... Arquivo de Trabalho TAUX
*********************************************************************
Local cModo := "Q" //| Q - Query || E - Execucao
Local cEmp	:= SM0->M0_CODIGO
Local cAlias:= 'TAUX'
Local cSql 	:= ""

If Select('AUX') <> 0
	DbCloseArea('AUX')
EndIF

//| Numero de Tabelas
cSql += "Select Count(1) NumTab "
cSql += "From User_All_Tables "
cSql += "Where Length(Table_Name) = 6 "
cSql += "And   Substr(Table_Name,4,2) = '"+cEmp+"'  "
cSql += "And   Table_Name Between '"+cDe+cEmp+'0'+"' And '"+cAte+cEmp+'0'+"' "
                                                          
U_ExecMySql( cSql , cAlias , cModo )

nTabelas := TAUX->NUMTAB

DbSelectArea("TAUX");DbCloseArea();cSql := ""

/*
//| Numero de Campos
cSql += "Select Count(1) NumCol "
cSql += "From User_Tab_Columns "
cSql += "Where Length(Table_Name) = 6 "
cSql += "And   Substr(Table_Name,4,2) = '"+cEmp+"'  "
cSql += "And   Column_Name Not In('R_E_C_D_E_L_','R_E_C_N_O_','D_E_L_E_T_')
cSql += "And   Table_Name Between '"+cDe+cEmp+'0'+"' And '"+cAte+cEmp+'0'+"' "
                                                          
U_ExecMySql( cSql , cAlias , cModo )

nCampos := TAUX->NUMCOL

DbSelectArea("TAUX");DbCloseArea();cSql := ""
*/

//| Arquivo de Trabalho Virtual com Campos 
cSql += "Select TABLE_NAME TABELA, COLUMN_NAME CAMPO, SUBSTR(DATA_TYPE,1,1) TIPO, DATA_LENGTH TAM "
cSql += "From User_Tab_Columns "
cSql += "Where Length(Table_Name) = 6 "
cSql += "And   Substr(Table_Name,4,2) = '"+cEmp+"'  "
cSql += "And   Column_Name Not In('R_E_C_D_E_L_','R_E_C_N_O_','D_E_L_E_T_')
cSql += "And   Table_Name Between '"+cDe+cEmp+'0'+"' And '"+cAte+cEmp+'0'+"' "

U_ExecMySql( cSql , cAlias , cModo )

DbSelectArea("TAUX")


Return()




cLogTxt := ".:: Sincroniza Banco com SX3Padrao  ::. Start = "+DtoS(Ddatabase)+" "+Time()+cxEnter+cxEnter








DbSelectArea("SX3");dbSetOrder(1);DbGotop()
//DbSelectArea("SX2");dbSetOrder(1)

//If !DbSeek(cDe,.F.)
//	DbSelectArea("SX2");DbGotop()
//Endif

//nPosSx2 := Recno()
	


oObj:SetRegua1(nRegSx2)
oObj:SetRegua2(0)

nCont  := 0

DbSelectArea("SX2");DbGoto(nPosSx2)
While !EOF() .AND. SX2->X2_CHAVE >= cDe .AND. SX2->X2_CHAVE <= cAte .And. lSemErro
	
	IF lEnd	
		Return()
	Endif
	
	nCont++
	
	lTable := .F.
	
	cExecSql := ""
	cLogInsert := ""
	
	oObj:IncRegua1("Lendo Registro do SX2 : "+AllTrim(Str(nCont))+" / "+AllTrim(Str(nRegSx2))+" - Tabela "+Alltrim(SX2->X2_CHAVE))
	
	cTable := SX2->X2_CHAVE + SM0->M0_CODIGO + "0"
	
	SX3->(dbSeek(SX2->X2_CHAVE))
	
	oObj:SetRegua2(30)
	lFirst	:= .T.
	While SX3->(!EOF())	 .AND. SX3->X3_ARQUIVO == SX2->X2_CHAVE
		
		
		oObj:IncRegua2("Verificando Campo : "+SX3->X3_CAMPO+" - "+ SX3->X3_TITULO)
		
		If SX3->X3_ARQUIVO < cDe .OR. SX3->X3_ARQUIVO > cAte
			SX3->(dbSkip())
			Loop
		Endif

		If !lTable //| Ver se existe ah Tabela no Banco:
			
			cQuery := "Select * from " + cTable
			
			If ExecMySql( cQuery ) == 0 //| Existe ah Tabela
				lTable := .T.
			Else //| Tabela Nao Existe Conforme Verificacao:{"Tabelas","Campos","Ambos"}
				
				If cVeri == "Tabelas" .or. cVeri == "Ambos"
					cLogTxt += cxEnter
					cLogTxt += ".:Tabela : " + cTable + " - " +Alltrim(SX2->X2_NOME)+". Nao existe no Banco !!!" + cxEnter
				Endif
				
				exit
				
			Endif
		Endif
		
		If SX3->X3_CONTEXT <> "V"	//| Verifica se eh campo REAL ou VIRTUAL
			
			cQuery := "Select "+ Alltrim(SX3->X3_CAMPO) +" From " + cTable	//| Verifica se Existe o Campo no Banco
			If  ExecMySql( cQuery ) <> 0
				
				If cVeri == "Campos" .or. cVeri == "Ambos" //| Tabela Não Existe //| Conforme Verificacao:{"Tabelas","Campos","Ambos"}
					
					If lFirst //| Primeiro Campo Nao Emcontrado escreve nome tabela
						
						cLogTxt += cxEnter
						cLogTxt += "**********************************************************************************" + cxEnter
						cLogTxt += ".:Tabela : " + cTable + " - " +SX2->X2_NOME + cxEnter
						lFirst := .F.
						
						cExecSql := " ALTER TABLE  "+ cTable + cxEnter + " ADD ( " //| Inicia ALTER TABLE
						
					Endif
					
					cExecSql +=	Alltrim(SX3->X3_CAMPO)	//| Configura Campos no ALTER TABLE Campo
					
					If SX3->X3_TIPO == "N" 	//| Tipo do Campo
						cTpCamp := " NUMBER DEFAULT 0.0"
					Else
						nTam := SX3->X3_TAMANHO
						cTpCamp := " CHAR("+Alltrim(str(nTam))+") DEFAULT '" +Space(nTam)+ "'"
					Endif
					cExecSql +=	cTpCamp
					
					cExecSql +=	" NOT NULL," //| Nao pode Ser NULO
					
					cLogTxt += " Campo: "+Alltrim(SX3->X3_CAMPO)+" Tipo: "+(SX3->X3_TIPO)+" Tam: "+Alltrim(Str(SX3->X3_TAMANHO))+" Dec: "+Alltrim(Str(SX3->X3_DECIMAL))+". Nao Existe !" + cxEnter
					
					cRetFunc := FValTopField()//| Top Field
					
					If !Empty(cRetFunc)
						cLogInsert += cRetFunc + cxEnter 
						
						If cModo == "Execução"			
						
							If ExecMySql( cRetFunc ) <> 0
								cLogTxt += cxEnter + TCSQLERROR() + cxEnter
					   			lSemErro := .F.
					   			Exit
					    	Endif
						
						Endif
					Endif

				Endif
				
			EndIf
			
		Endif
		
		SX3->(dbSkip())
		
	EndDo
	
	If !lSemErro //| Foi Encontradoo Erro
		DbSelectArea("SX2")
		Loop
	EndIf
				
	If cExecSql <> ""
		
		cExecSql := Substr(cExecSql, 1, (Len(cExecSql)-1) )
		
		cExecSql += " )" + cxEnter
		
		If cModo == "Execução"
			If ExecMySql( cExecSql ) <> 0
				cLogTxt += cxEnter + TCSQLERROR() + cxEnter
				Exit
			Endif
		Else
			cLogTxt +=  cxEnter + cExecSql 
		Endif
		
		If !Empty(cLogInsert)
			cLogTxt += cxEnter + cLogInsert
		Endif
		
	Endif
   
	if lTable .And. cModo == "Execução" //| Cria Os Indices ....
		
		oObj:IncRegua2("Criando Indice da Tabela: "+cTable)
		
		FDropIndex()
		
		DbSelectArea(SX2->X2_CHAVE)  
		DbCloseArea()
		
	Endif
	
	oObj:SetRegua2(0)	
	DbSelectArea("SX2")
	dbSkip()
	
EndDo

cLogTxt += +cxEnter+cxEnter+"End = "+DtoS(Ddatabase)+" "+Time()

GeraLog( cLogTxt )

Return()
*********************************************************************
Static Function MyQuery( cQuery , cursor )
*********************************************************************

IF SELECT( cursor ) <> 0
	dbSelectArea(cursor)
	DbCloseArea(cursor)
Endif

TCQUERY cQuery NEW ALIAS (cursor)

Return()
*********************************************************************
Static Function FValTopField()
*********************************************************************
Local cTipo 	:= "C"
Local cTable  	:= "SIGA."+ SX2->X2_CHAVE + SM0->M0_CODIGO + "0"
Local aValues  	:= {}
Local cRetorno 	:= ""

If SX3->X3_TIPO <> "C" //| Somnente Campos Nao Caracteres Fazem Parte devem ser inseridos na Top_Field
	Do Case
		Case SX3->X3_TIPO == "N" //| Numerico
			cTipo := "P"
		Case SX3->X3_TIPO == "D" //| Data
			cTipo := "D"
		Case SX3->X3_TIPO == "M" //| Memo
			cTipo := "M"
		Case SX3->X3_TIPO == "L" //| Logico
			cTipo := "L"
	EndCase
	
	AADD(aValues,{ cTable , SX3->X3_CAMPO , cTipo , SX3->X3_TAMANHO , SX3->X3_DECIMAL })
	
	cRetorno := 	ExecInsert(aValues)
	
EndIf

Return(cRetorno)
*********************************************************************
Static Function ExecMySql( cSql )//| Executa comandos SQL no servidor. ( Query , Tabela , Se Dropa Tabela Antes .T. Or .F. )
*********************************************************************
Local nRet := 0 //| 0 == OK / 1 == Erro

nRet := TCSQLEXEC(cSql)

Return(nRet)
*********************************************************************
Static Function ExecInsert( aValues )//| Executa comandos SQL no servidor. ( Query , Tabela , Se Dropa Tabela Antes .T. Or .F. )
*********************************************************************
Local nRet := 0 //| 0 == OK / 1 == Erro

//|aValues {"SIGA.DCD010","DCD_DTULAL","D","8","0"}

cSql := "Insert into TOP_FIELD (FIELD_TABLE,FIELD_NAME,FIELD_TYPE,FIELD_PREC,FIELD_DEC) "
cSql += "Values ('"+ aValues[1][1] + "','"+ Alltrim(aValues[1][2]) +"','"+ aValues[1][3] +"','"+ Alltrim(Str(aValues[1][4])) +"','"+ Alltrim(Str(aValues[1][5])) +"')"

Return(cSql)
*********************************************************************
Static Function GeraLog( cLogTxt )
*********************************************************************
__cFileLog := MemoWrite(Criatrab(,.F.)+".LOG",cLogTxt)

Define FONT oFont NAME "Tahoma" Size 6,12
Define MsDialog oDlgMemo Title "Leitura Concluida." From 3,0 to 340,550 Pixel

@ 5,5 Get oMemo  Var cLogTxt MEMO Size 265,145 Of oDlgMemo Pixel
oMemo:bRClicked := {||AllwaysTrue()}
oMemo:oFont:=oFont

Define SButton  From 153,205 Type 13 Action ({oDlgMemo:End(),Mysend(cLogTxt)}) Enable Of oDlgMemo Pixel
Define SButton  From 153,235 Type 1 Action oDlgMemo:End() Enable Of oDlgMemo Pixel

Activate MsDialog oDlgMemo Center

Return()
*********************************************************************
Static Function Mysend(cTxt)
*********************************************************************
Static oDlg
Static oButton1
Static oButton2
Static oGet1
Static cGet1 := Space(200)
Static oSay

DEFINE MSDIALOG oDlg TITLE "Form" FROM 000, 000  TO 150, 300 COLORS 0, 12632256 PIXEL

@ 031, 015 MSGET oGet1 VAR cGet1 SIZE 114, 010 OF oDlg PICTURE "@!" VALID !Empty(Alltrim(cGet1)) COLORS 0, 16777215 PIXEL
@ 016, 015 SAY oSay PROMPT "Por favor, entre com seu email ABAIXO:" SIZE 100, 007 OF oDlg PICTURE "@!" COLORS 0, 12632256 PIXEL

@ 050, 025 BUTTON oButton1 PROMPT "Enviar" SIZE 040, 012 OF oDlg ACTION {||oDlg:End(),DISMAILX(cGet1,cTxt)} PIXEL
@ 050, 075 BUTTON oButton2 PROMPT "Sair" SIZE 040, 012 OF oDlg ACTION oDlg:End()  PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

Return
*********************************************************************
Static Function DISMAILX(cMail,cTxt)
*********************************************************************

CONNECT SMTP SERVER GETMV("MV_RELSERV") ACCOUNT GETMV("MV_RELACNT") PASSWORD GETMV("MV_RELPSW") RESULT lResult

If !lResult
	MsgBox('Erro no Envio')
	Return()
EndIf

cAccount := GETMV("MV_RELACNT")

SEND MAIL FROM cAccount 	;
TO      cMail	        	;
SUBJECT "Log Sx3 vs Banco" 	;
BODY cTxt

DISCONNECT SMTP SERVER

MsgBox("Email Enviado com Sucesso!")

Return()
*********************************************************************
Static Function FDropIndex()
*********************************************************************




Return()