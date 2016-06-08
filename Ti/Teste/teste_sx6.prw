#Include 'Protheus.ch'
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ CFGX017  ≥ Autor ≥ Eveli Morasco         ≥ Data ≥ 01/09/92 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Programa de manutencao dos parametros do sistema           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGACFG                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function TESTE_SX6()

LOCAL cAlias := "SX6"
 
PRIVATE cCadastro := "Cadastro de Fornecedores"
PRIVATE aRotina     := { }
 
AADD(aRotina, { "Pesquisar"		, "AxPesqui"	, 0, 1 })
AADD(aRotina, { "Visualizar"	, "AxVisual"  	, 0, 2 })
AADD(aRotina, { "Incluir"      	, "AxInclui"   	, 0, 3 })
AADD(aRotina, { "Alterar"     	, "AxAltera"  	, 0, 4 })
AADD(aRotina, { "Excluir"     	, "AxDeleta" 	, 0, 5 })
 
dbSelectArea(cAlias)
dbSetOrder(1)
 
mBrowse(6, 1, 22, 75, cAlias)
 

Return()

/*
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Seleciona somente os parametros utilizados pelos modulos escolhidos≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
User Function Sel017()
Local cCond := "",cGenericos := "",lGenericos := .F.
Local cIndSx6 := "SX6" + cEmpAnt + "0"+ IIF(RetIndExt() == ".CDX","","1")
Local oOk := LoadBitmap( GetResources(), "LBOK" )
Local oNo := LoadBitmap( GetResources(), "LBNO" )
Local aModulos := {},lRet := .F.,lTodos := .T.,oDlg,oLbx,oChk,oGen
Local i

If !Empty(cIndTrab)
	dbClearInd()
	Ferase(cIndTrab)
	dbSetIndex(cIndSx6)	
Endif
cIndTrab :=  CriaTrab(,.F.)

//AADD(aModulos,{.T.,"SIGAATF",OemToAnsi(STR0007)})  // "Ativo Fixo            "
//AADD(aModulos,{.T.,"SIGACOM",OemToAnsi(STR0008)})  // "Compras               "
//AADD(aModulos,{.T.,"SIGACON",OemToAnsi(STR0009)})  // "Contabilidade         "
//AADD(aModulos,{.T.,"SIGAEST",OemToAnsi(STR0010)})  // "Estoque/Custos        "
AADD(aModulos,{.T.,"SIGAFAT",OemToAnsi("Faturamento")})  // "Faturamento           "
AADD(aModulos,{.T.,"SIGAFIN",OemToAnsi("Financeiro")})  // "Financeiro            "
//AADD(aModulos,{.T.,"SIGAGPE",OemToAnsi(STR0013)})  // "Gestao de Pessoal     "
//AADD(aModulos,{.T.,"SIGAFAS",OemToAnsi(STR0014)})  // "Faturamento Serviáo   "
//AADD(aModulos,{.T.,"SIGAFIS",OemToAnsi(STR0015)})  // "Livros Fiscais        "
//AADD(aModulos,{.T.,"SIGAPCP",OemToAnsi(STR0016)})  // "Plan.Controle ProduáÑo"
//AADD(aModulos,{.T.,"SIGAVEI",OemToAnsi(STR0017)})  // "Ve°culos              "
//AADD(aModulos,{.T.,"SIGALOJ",OemToAnsi(STR0018)})  // "Controle de Lojas     "
//AADD(aModulos,{.T.,"SIGAMAN",OemToAnsi(STR0019)}) // "ManutenáÑo de Arquivos"
//AADD(aModulos,{.T.,"SIGAOFI",OemToAnsi(STR0020)})  // "Administ. de Oficinas "
//AADD(aModulos,{.T.,"SIGARPM",OemToAnsi(STR0021)})  // "Gerador de Relat¢rios "
//AADD(aModulos,{.T.,"SIGAPON",OemToAnsi(STR0022)})  // "Ponto Eletrìnico      "
//AADD(aModulos,{.T.,"SIGAEIC",OemToAnsi(STR0023)})  // "Controle de ImportaáÑo"
//AADD(aModulos,{.T.,"SIGAESP",OemToAnsi(STR0024)})  // "Especiais             "

DEFINE MSDIALOG oDlg FROM  31,58 TO 300,538 TITLE OemToAnsi(" Selecao de Parametros" ) PIXEL  // "SeleáÑo de ParÉmetros"


	@ 10, 8 TO 116, 232 LABEL "" OF oDlg  PIXEL
	@ 27, 160 TO 47, 226 LABEL "" OF oDlg  PIXEL
	@ 49, 160 TO 69, 226 LABEL "" OF oDlg  PIXEL
	@ 26,21 LISTBOX oLbx FIELDS HEADER "",OemToAnsi("Modulos"),OemToAnsi("Descricao") SIZE 133, 81 OF oDlg PIXEL;  // "M¢dulos" ### "DescriáÑo"
			 ON DBLCLICK (aModulos[oLbx:nAt,1] := !aModulos[oLbx:nAt,1],lTodos := .F.,lGenericos:=.F.,oLbx:Refresh(.F.),oChk:Refresh(.F.),oGen:Refresh(.F.))
	oLbx:SetArray(aModulos)
   oLbx:bLine := { || {if(aModulos[oLbx:nAt,1],oOk,oNo),aModulos[oLbx:nAt,2],aModulos[oLbx:nAt,3] } }

	@ 34,165 CHECKBOX oChk VAR lTodos PROMPT "Seleciona Todos" SIZE 60, 10 OF oDlg PIXEL ON CLICK(IIF(lTodos,(oLbx:Disable(),lGenericos:=.F.,oGen:Disable()),(oLbx:Enable(),oGen:Enable())),MarkAll(aModulos,lTodos),oLbx:Refresh(.f.),oGen:Refresh(.F.));oChk:oFont := oDlg:oFont // "Seleciona Todos"
	@ 56,165 CHECKBOX oGen VAR lGenericos PROMPT OemToAnsi("Generico") SIZE 60, 10 OF oDlg PIXEL ON CLICK(IIF(lGenericos,(oLbx:Disable(),lTodos:=.F.,oChk:Disable()),(oLbx:Enable(),oChk:Enable())),oLbx:Refresh(.f.),oChk:Refresh(.F.));oGen:oFont := oDlg:oFont  // "Genericos"

	DEFINE SBUTTON FROM 89, 172 TYPE 1 ENABLE OF oDlg ACTION (lRet := .T.,oDlg:End())
	DEFINE SBUTTON FROM 89, 200 TYPE 2 ENABLE OF oDlg ACTION (lRet := .F.,oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

If !lRet 
	Return Nil
Endif

cCond :=""
If lTodos 
	dbClearInd()
	cIndTrab := ""
	dbSetIndex(cIndSx6)
Else
	For i := 1 to Len(aModulos)
		 IF aModulos[i,1]
			 IF !Empty(cCond)
				 cCond += " .or. "
			 Endif
			 cCond += '!Empty(X6_'+aModulos[i,2]+')'
		 Endif	
		 If !Empty(cGenericos)
			 cGenericos += "+"
		 Endif
		 cGenericos += "X6_"+aModulos[i,2] 
	Next i
	If !Empty(cCond)
	    cCond := '(' + cCond + ') .and. !(' + cGenericos + '=='+'"XXXXXXXXXXXXXXXXXX"'+')'
	Else
	    cCond := '.T.'
	Endif    
	If lGenericos
		cCond := '(' + cGenericos	+ '==' + '"XXXXXXXXXXXXXXXXXX"'+')'
	Endif
	IndRegua("SX6",cIndTrab,IndexKey(),,cCond,"Seleciona Registros")  // "Selecionando Registros..."
	dbClearInd()
	dbSetIndex(cIndSx6)
	dbSetIndex(cIndTrab+OrdBagExt())
	dbSetOrder(2)
Endif


DeleteObject(oOk)
DeleteObject(oNo)

Return Nil


User Function  Incl017(cAlias,nReg,nOpc)
Local cIndSx6 := "SX6" + cEmpAnt +"0"+IIF(RetIndExt()==".CDX","","1")
Local nOldOrd :=  IndexOrd()

DbSetOrder(1)	

AxInclui(cAlias,nReg,nOpc )

DbSetorder(nOldOrd)

Return Nil

Static Functio MarkAll(aModulos,lTodos)
Local x := 0
For x:= 1 to len(aModulos)
    aModulos[x][1] := lTodos
Next    
Return Nil
*/

