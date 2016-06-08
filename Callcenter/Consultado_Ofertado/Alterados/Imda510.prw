#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ IMDA510          ³ Autor ³Edivaldo       ³ Data ³ 23/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclui uma Ordem de Carga.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_IMDA510()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cLote => Lote para inclusao.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   Jaime      ³21/11/06³ Alterado para permitir edicao                 ³±±
±±³Jorge Oliveira³27/07/10³ Ajustes diversos e padronizacao nomenclatura. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function IMDA510(cLote)

local aAreaAnt := GetArea()
local cAlias := Alias()
local nrecno:= Recno()

Local lOk
Private cPerg :="OCARGA"
Private aListBox
Private GetNF := {}

If !Pergunte( cperg, .T. )
	RestArea( aAreaAnt )
	DbSelectArea( cAlias )
	DbGoTo( nRecNo )
	Return()
EndIf


If MsgYesNo( 'Confirma processamento?', 'ORDEM DE CARGA...' )

	// Realiza o processamentoo para selecao dos registros
	MsAguarde( {||lOk := A510SELNF()}, "Aguarde...","Selecionando notas fiscais...")

	// Chama rotina de conferencia
	If lOk
		If Empty(aListBox)
			IW_MsgBox("Nenhum nota fiscal selecionada para a Ordem de Carga!","Atenção","INFO")
		Else
			A510MARKNF(cLote)
		Endif
	Endif

Endif


RestArea( aAreaAnt )
dbselectarea(cAlias)
DBGOTO(nRecNo)

Return NIL

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ A510ALT          ³ Autor ³Edivaldo       ³ Data ³ 23/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Altera uma Ordem de Carga.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_A510ALT()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cLote => Lote para inclusao.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jorge Oliveira³27/07/10³ Ajustes diversos e padronizacao nomenclatura. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function A510ALT()
Local aAreaAnt := GetArea()
local cAlias := Alias()
local nrecno:= Recno()

Local lOk
Private cPerg :="OCARGA"
Private aListBox
Public lAltera := .T.

If MsgYesNo( 'Confirma processamento de Alteração?', 'ORDEM DE CARGA...' )

	// Realiza o processamentoo para selecao dos registros
	MsAguarde( {||lOk := A510SETFLA(SZU->ZU_LOTE)}, "Aguarde...","Selecionando Notas Fiscais da Ordem Selecionada...")
/* JAIME
	// Chama rotina de conferencia
	If lOk
		If Empty(aListBox)
			IW_MsgBox("Nenhum nota fiscal selecionada para a Ordem de Carga!","Atenção","INFO")
		Else
			A510MARKNF()
		Endif
	Endif
	    */
Endif

RestArea( aAreaAnt )
dbselectarea(cAlias)
DBGOTO(nRecNo)

lAltera := .F.

Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A510SELNF ³Autor³Edivaldo Gonçalves Cordeiro³Data³23/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Processamento para selecionar as notas fiscais de venda    ³±±
±±³          ³ para gerar a Ordem de Carga                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A510SELNF()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jorge Oliveira³27/07/10³ Ajustes diversos e padronizacao nomenclatura. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function A510SELNF()

	LOCAL nRecSM0, cQuery, cFiliais, nI
	LOCAL aStru := {}

	cQuery := ""
	cQuery += "SELECT   SF2.F2_FRTCONF FRETCONF, SF2.F2_SERIE SERIE, SF2.F2_DOC DOC,
	cQuery += "         SF2.F2_EMISSAO EMISSAO, SF2.F2_CLIENTE CLIENTE, SF2.F2_LOJA LOJA,
	cQuery += "         SA1.A1_NOME NOMECLI, SF2.F2_TRANSP TRANSP, SA4.A4_NOME NOMETRAN,
	cQuery += "         SF2.F2_FILIAL, SF2.F2_DOC, SF2.F2_VALBRUT TOTALNF,
	cQuery += "         SF2.F2_PBRUTO PBRUTO, SF2.F2_VOLUME1 VOLUME, SF2.R_E_C_N_O_ R_E_C_N_O_
	cQuery += "    FROM " + RetSqlName("SF2")+" SF2, "
	cQuery += "     " + RetSqlName("SA1")+" SA1, "
	cQuery += "     " + RetSqlName("SA4")+" SA4, "
	cQuery += "         (SELECT F2.F2_FILIAL FILIAL, F2.F2_DOC NOTA, F2.F2_SERIE SERIE
	cQuery += "            FROM  " + RetSqlName("SF2")+" F2
	cQuery += "           WHERE F2.F2_FILIAL = '" + xFilial("SF2") +"' "
	cQuery += "             AND F2.F2_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "
	cQuery += "             AND F2.F2_TRANSP BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	//cQuery += "             AND F2.F2_TIPO NOT IN ('B', 'D')
	cQuery += "             AND F2.D_E_L_E_T_ <> '*'
	cQuery += "          MINUS
	cQuery += "          SELECT ZU_FILIAL FILIAL, ZU_NF NOTA, ZU_SERIE SERIE
	cQuery += "            FROM SZU010
	cQuery += "           WHERE D_E_L_E_T_ <> '*') NF
	cQuery += "   WHERE SF2.F2_FILIAL = NF.FILIAL
	cQuery += "     AND SF2.F2_DOC = NF.NOTA
	cQuery += "     AND SF2.F2_SERIE = NF.SERIE
	cQuery += "     AND SF2.F2_CLIENTE = SA1.A1_COD
	cQuery += "     AND SF2.F2_LOJA = SA1.A1_LOJA
	cQuery += "     AND SA4.A4_COD = SF2.F2_TRANSP
	cQuery += "     AND SF2.D_E_L_E_T_ <> '*'
	cQuery += "     AND SA1.D_E_L_E_T_ <> '*'
	cQuery += "     AND SA4.D_E_L_E_T_ <> '*'
	cQuery += "ORDER BY F2_DOC, F2_SERIE

	//cQuery+="FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SF2")+" SF2, "+RetSqlName("SA1")+" SA1, "+RetSqlName("SA4")+" SA4, "+RetSqlName("SUA")+" SUA "
	MEMOWRIT( "C:\SQLSIGA\" +FunName(1)+".SQL", cQuery )

	// conteudo da funcao abaixo foi colocada nessa rotina
	//ExecutaQuery(cQuery)
	TCQUERY cQuery NEW ALIAS "TRB_NF"
	aStru := DbStruct()
	For nI := 1 To Len( aStru )
	   If aStru[nI,2] != "C"
		   TCSetField( "TRB_NF", aStru[nI,1], aStru[nI,2], aStru[nI,3], aStru[nI,4] )
	   EndIf
	Next


	// Preenche array com as notas fiscais
	aListBox := {}
	Do While !Eof()
		aAdd(aListBox,{.F.,IIF(TRB_NF->FRETCONF=='S','Sim','Não'),TRB_NF->SERIE,TRB_NF->DOC,TRB_NF->EMISSAO,TRB_NF->TOTALNF,'PENDENTE',TRB_NF->PBRUTO,TRB_NF->VOLUME,TRB_NF->CLIENTE,TRB_NF->LOJA,TRB_NF->NOMECLI,TRB_NF->TRANSP,TRB_NF->NOMETRAN,TRB_NF->R_E_C_N_O_})
		dbSkip()
	Enddo
	dbCloseArea()

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A510MARKNF  ³ Autor ³Edivaldo Gonçalves  ³ Data ³ 23/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Exibe as notas fiscais selecionadas para inicio da geração ³±±
±±³          ³ da Ordem de Carga                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A510MARKNF()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clote => Numero lote quando inclusao da alteracao da Ordem ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jorge Oliveira³27/07/10³ Ajustes diversos e padronizacao nomenclatura. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function A510MARKNF(cLote)

	Local oDlg, oListbox, oTotalFrete, nTotalFrete := 0
	Local oOk := LoadBitmap( GetResources(), "LBOK" )
	Local oNo := LoadBitmap( GetResources(), "LBNO" )
	Local cPictValNF := PesqPict( 'SF2', 'F2_VALBRUT' )
	Local cPictFrete := PesqPict( 'SUA', 'UA_FRETCAL' )
	Local aButtons := {}

	aAdd(aButtons,{"PENDENTE",&("{|| A510MARCA(.T.)}"),"Marca Todos"})
	aAdd(aButtons,{"PENDENTE",&("{|| A510MARCA(.F.)}"),"Desmarca Todos"})

	// Monta a tela para o usuario marcar as notas a serem Geradas a Ordem de Carga
	DEFINE MSDIALOG oDlg TITLE OemToAnsi( "Seleção de Notas Fiscais para a Ordem de Carga" ) FROM 125,005 TO 515,795 PIXEL

		DEFINE FONT oFont NAME "Courier New" SIZE 0,-11
		@ 15,02 LISTBOX oListBox FIELDS HEADER "" ,OemToAnsi("Número") , OemToAnsi("Emissão"), OemToAnsi("Valor NF") , OemToAnsi("Status")  , OemToAnsi("Peso Bruto"), ;
			OemToAnsi("Cliente") , OemToAnsi("Loja") , OemToAnsi("Nome") , OemToAnsi("Transp.") , OemToAnsi("Nome") , "" ;
			SIZE 392,158 ON DBLCLICK (aListBox[ oListBox:nAt, 1 ] := !aListBox[ oListBox:nAt, 1 ],oListBox:nColPos := 1,oListBox:Refresh()) NOSCROLL PIXEL FONT oFONT

		oListBox:SetArray(aListBox)
		oListBox:bLine := { || { IF(aListBox[oListBox:nAt,1],oOk,oNo),aListBox[oListBox:nAt,4],stod(aListBox[oListBox:nAt,5]),;
	    Transform(aListBox[oListBox:nAt,6],"@E 99,999,999.99"),aListBox[oListBox:nAt,7],Transform(aListBox[oListBox:nAt,8],"@E 999999.99"),aListBox[oListBox:nAt,9],;
	   	aListBox[oListBox:nAt,10],aListBox[oListBox:nAt,11],aListBox[oListBox:nAt,12],aListBox[oListBox:nAt,13],"" } }

		@ 180,010 SAY OemToAnsi("Frete Total:") OF oDlg PIXEL


	IF cLote == Nil
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , {|| A510SETFLA(),oDlg:End()} , {||IW_MsgBox("Não Foi Selecionada nenhuma Nota Fiscal para a Ordem de Carga!","Atenção","ALERT"),oDlg:End() },,aButtons )
	ELSE
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , {|| A510ADDNF(),oDlg:End()} , {||IW_MsgBox("Não Foi Selecionada nenhuma Nota Fiscal para a Ordem de Carga!","Atenção","ALERT"),oDlg:End() },,aButtons )
	ENDIF

	DeleteObject(oOk)
	DeleteObject(oNo)

Return( NIL )


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A510SETFLA  ³ Autor ³Edivaldo Gonçalves  ³ Data ³ 23/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Alimenta Matriz com as Notas Fiscais pertencentes a Ordem  ³±±
±±³          ³ da Ordem de Carga                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A510SETFLA()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clote => Numero lote da Ordem                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jorge Oliveira³27/07/10³ Ajustes diversos e padronizacao nomenclatura. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function A510SETFLA(cLote)

	Local carea := getarea()
	local nrecno:= recno()
	Local crecnoZZU := SZU->(Recno())
	Local nOrdemZZU := SZU->(IndexOrd())

	Local nI
	Private GetNF := {}


	IF cLote == Nil .OR. EMPTY(cLote)
		dbSelectArea("SF2")
		For nI := 1 to Len(aListBox)
			If aListBox[nI,1]
				dbGoto(aListBox[nI,15])  //14
				aAdd(GetNF,{SF2->F2_DOC,SF2->F2_CLIENTE})

			Endif
		Next
	ENDIF
	Begin Transaction
	Processa( {|| A510BROWOC(cLote) },"Working...","MONTANDO ORDEM DE CARGA...  ")
	End Transaction


	dbselectarea('SZU')
	DbSelectArea(nOrdemZZU)
	DBGOTO(crecnoZZU)

	dbselectarea(carea)
	DBGOTO(nRecNo)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A510MARCA   ³ Autor ³Edivaldo Gonçalves  ³ Data ³ 23/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Alimenta Matriz com as Notas Fiscais pertencentes a Ordem  ³±±
±±³          ³ da Ordem de Carga                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A510MARCA()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lMarca => Informa se deve marcar ou desmarcar o registro   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jorge Oliveira³27/07/10³ Ajustes diversos e padronizacao nomenclatura. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function A510MARCA(lMarca)

	Local nI
	for nI := 1 to Len(aListBox)
		aListBox[nI,1] := lMarca
	next

Return NIL



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A510BROWOC  ³ Autor ³Edivaldo Gonçalves  ³ Data ³ 23/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta uma tela para selecao das Ordens de Carga.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A510BROWOC()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cLote => Lote para processamento ou todos.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jorge Oliveira³27/07/10³ Ajustes diversos e padronizacao nomenclatura. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function A510BROWOC(cLote)

	Local   aPerg	 := {}
	Local	aRet	 := {}
	Private NOPCX
	Private NUSADO
	Private AHEADER := {}
	Private ACOLS   := {}
	Private cTrans1
	Private cPlaca
	Private cMotorista
	Private CLOJA
	Private DDATA
	Private NLINGETD
	Private CTITULO
	Private AC
	Private AR
	Private ACGD
	Private CLINHAOK
	Private CTUDOOK
	Private LRETMOD2
	Private X_NF 	:= 1
	Private X_SERIE := 2
	Private X_DELETE
	Private INCLUI := .F.
	Private ALTERA := .F.
	Private bF4 := { || U_IMDA510( cLote ) }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Opcao de acesso para o Modelo 2                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// 3,4 Permitem alterar getdados e incluir linhas
	// 6 So permite alterar getdados e nao incluir linhas
	// Qualquer outro numero so visualiza
	nOpcx:=3
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montando aHeader                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SF2")
	DbSetOrder( 1 )

	dbSelectArea("Sx3")
	dbSetOrder(1)
	dbSeek("SZU")
	nUsado:=0
	aHeader:={}
	While !Eof() .And. (x3_arquivo == "SZU")
		//Filtro os Campos que desejo aparecer no aHeader

		If ( Alltrim(X3_CAMPO)=="ZU_LOTE"   .OR. Alltrim(X3_CAMPO)=="ZU_DATA"    .OR.;
		     Alltrim(X3_CAMPO)=="ZU_OBS"    .OR. Alltrim(X3_CAMPO)=="ZU_HRENTME" .OR.;
		     Alltrim(X3_CAMPO)=="ZU_PLACVEI".OR. Alltrim(X3_CAMPO)=="ZU_MTA"     .OR.;
		     Alltrim(X3_CAMPO)=="ZU_ESTORNO".OR. Alltrim(X3_CAMPO)=="ZU_DTENTME" .OR.;
		     Alltrim(X3_CAMPO)=="ZU_CODTRAN" )
			dbSkip()
			Loop
		Endif

		If X3USO(x3_usado) .AND. cNivel >= x3_nivel
			nUsado++
			AADD(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
							x3_tamanho, x3_decimal,"",;
							x3_usado, x3_tipo, x3_arquivo, x3_context } )

		Endif
		dbSkip()
	End

	Private X_DELETE := Len(aHeader)+1

	n := 0

	IF cLote == Nil .OR. Empty(cLote)  // SE FOR INCLUSAO

		INCLUI := .T.

		//Carrega dados para o aCols

		For i:= 1 to Len(GetNF)   //Colocar o Next do FOR no final do arquivo

		//Capturo ITENS DA NOTA FISCAL
		  cQuery :="SELECT  SA1.A1_COD,SA1.A1_NOME,SF2.F2_FILIAL,SF2.F2_SERIE,SF2.F2_DOC,SF2.F2_VALBRUT "
		  cQuery +="     , SF2.F2_PLIQUI,SF2.F2_VOLUME1,SA4.A4_COD,SA4.A4_NOME,SC5.C5_FILIAL,SC5.C5_NOTA,SC5.C5_TPFRETE "
		  cQuery +="     , SF2.F2_DTRECNF,SF2.F2_HRRECNF "
		  cQuery +="  FROM "
		  cQuery += RetSqlName( "SA1" )+ " SA1, " + RetSqlName( "SF2" ) + " SF2, "+ RetSqlName( "SA4" ) + " SA4, "+RetSqlName( "SC5" ) +" SC5 "
		  cQuery +="WHERE "
		  cQuery +="SF2.F2_CLIENTE  = '" +GetNF[i,2]+ "' AND "
		  cQuery +="SF2.F2_DOC      = '" +GetNF[i,1] + "' AND  "
		  cQuery +="SF2.F2_FILIAL   = '"+ xFilial("SF2") + "' AND "
		  cQuery +="SF2.F2_FILIAL   = SC5.C5_FILIAL   AND "
		  cQuery +="SF2.F2_SERIE    = SC5.C5_SERIE    AND "
		  cQuery +="SF2.F2_DOC      = SC5.C5_NOTA     AND "
		  cQuery +="SF2.F2_TRANSP   =  SA4.A4_COD     AND "
		  cQuery +="SF2.F2_CLIENTE  = SA1.A1_COD      AND "
		  cQuery +="SF2.F2_LOJA     = SA1.A1_LOJA     AND "
		  cQuery +="SF2.D_E_L_E_T_ <> '*' AND SA1.D_E_L_E_T_ <> '*' AND SA4.D_E_L_E_T_ <> '*' AND SC5.D_E_L_E_T_ <> '*'  "

		  MEMOWRIT( "C:\SQLSIGA\" +FunName(1)+"-INCLUIORDEMCARGA.SQL", cQuery )

		  	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"CONSTA1",.F.,.T.)

			aStru := DbStruct()
			For nI := 1 To Len( aStru )
				If aStru[nI,2] != "C"
					TCSetField( "CONSTA1", aStru[nI,1], aStru[nI,2], aStru[nI,3], aStru[nI,4] )
				EndIf
			Next


		 	DBSELECTAREA("CONSTA1")
			DBGOTOP()


			n++
			aAdd(aCols,Array(LEN(AHEADER)+1))   //aAdd(aCols,Array(nUsado+1))

		    aCols[n,1] := CONSTA1->F2_DOC  //NF
		    aCols[n,2] := CONSTA1->F2_SERIE                   //SERIE
		    aCols[n,3] := CONSTA1->F2_VOLUME1 //0 //Inicia o valor padrão com Zero  //VOLUME
		    aCols[n,4] := CONSTA1->A1_COD                     //CLIENTE
		    aCols[n,5] := CONSTA1->A1_NOME                    //DESC CLIENTE
		    aCols[n,6] := CONSTA1->F2_VALBRUT                 //VALORNF
		    aCols[n,7] := CONSTA1->F2_PLIQUI                  //PESO
		    aCols[n,8] := CONSTA1->A4_NOME                    //NOME TRANSP
		    aCols[n,10]:= SPACE(2)                            //EMBALADOR
		    aCols[n,11]:= SPACE(2)                            //CONFERENTE
			// Jorge Oliveira - 19/07/2010 - Carrega os campos na tela
		    aCols[n,12]:= IIF( Type( "CONSTA1->F2_DTRECNF" ) == "C", StoD( CONSTA1->F2_DTRECNF ), CONSTA1->F2_DTRECNF ) //DATA RECEBIMENTO DA NFS
		    aCols[n,13]:= CONSTA1->F2_HRRECNF		 			//HORA RECEBIMENTO DA NFS


		    If CONSTA1->C5_TPFRETE='F'
		       aCols[n,9] := 'FOB'
		    Else
		      aCols[n,9]  := 'CIF'
			Endif
			aCols[n][X_DELETE] := .F. //	aCols[Len(aCols)][Len(aHeader)+1] := .F.

			DBSELECTAREA("CONSTA1")
			DbCloseArea()

		Next i

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Variaveis do Cabecalho do Modelo 2                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTrans1 	:= Space(6)
		iLoja		:= Space(2)
		cTrans  	:= Space(7)
		cObs    	:= Space(20)
		cPlaca  	:= Space(9)
		cMotorista	:= Space(15)// MsDate()
		cTrans		:= A510NEXTOC() //GETSXENum("SZU","ZU_LOTE")

	ELSE  // Caso seja alteração

		ALTERA := .T.

		cQuery := "SELECT UNIQUE ZU.ZU_CODTRAN,ZU.ZU_OBS,ZU.ZU_LOTE, ZU.ZU_DATA, ZU.ZU_MTA, ZU.ZU_PLACVEI, ZU.ZU_FILIAL,ZU.ZU_SERIE "
		cQuery += "     , ZU.ZU_NF,ZU.ZU_VOLUME,ZU.ZU_CLIENTE,SA1.A1_NOME,SF2.F2_VALBRUT,SF2.F2_PLIQUI,SA4.A4_NOME,SC5.C5_TPFRETE "
		cQuery += "     , ZU.ZU_EMBALAD,ZU.ZU_CONFERE,SF2.F2_DTRECNF,SF2.F2_HRRECNF,SF2.F2_DTENTME "
		cQuery += "  FROM "
		cQuery += RetSqlName( "SZU" )+ " ZU,  "
		cQuery += RetSqlName( "SA1" )+ " SA1, "
		cQuery += RetSqlName( "SF2" )+ " SF2, "
		cQuery += RetSqlName( "SA4" )+ " SA4, "
		cQuery += RetSqlName( "SC5" )+ " SC5  "
		cQuery += " WHERE SF2.F2_FILIAL = SC5.C5_FILIAL "
		cQuery += "   AND SF2.F2_DOC = SC5.C5_NOTA "
		cQuery += "   AND SF2.F2_SERIE= SC5.C5_SERIE "
		cQuery += "   AND ZU.ZU_FILIAL = '" + xFilial("SZU") + "' "
		cQuery += "   AND ZU.ZU_LOTE = '" + cLote + "' "
		cQuery += "   AND ZU.ZU_FILIAL = SF2.F2_FILIAL "
		cQuery += "   AND ZU.ZU_SERIE = SF2.F2_SERIE "
		cQuery += "   AND ZU.ZU_NF    = SF2.F2_DOC 	"
		cQuery += "   AND ZU.ZU_CODTRAN = SA4.A4_COD "
		cQuery += "   AND SF2.F2_CLIENTE = SA1.A1_COD  "
		cQuery += "   AND SF2.F2_LOJA    = SA1.A1_LOJA "
		cQuery += "   AND ZU.D_E_L_E_T_ <> '*' "
		cQuery += "   AND SF2.D_E_L_E_T_ <> '*' "
		cQuery += "   AND SA4.D_E_L_E_T_ <> '*' "
		cQuery += "   AND SC5.D_E_L_E_T_ <> '*' "
		cQuery += "   AND SA1.D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY  ZU.ZU_FILIAL,ZU.ZU_LOTE,ZU.ZU_SERIE,ZU.ZU_NF"

		//  MEMOWRIT( "C:\SQLSIGA\" +FunName(1)+"-ALTERAORDEMCARGA.SQL", cQuery )

		If Select( "CONSTA1" ) <> 0
		   dbSelectArea("CONSTA1")
		   CONSTA1->(DbCLoseArea())
		Endif

	 	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"CONSTA1",.F.,.T.)

		aStru := DbStruct()
		For nI := 1 To Len( aStru )
			If aStru[nI,2] != "C"
				TCSetField( "CONSTA1", aStru[nI,1], aStru[nI,2], aStru[nI,3], aStru[nI,4] )
			EndIf
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Variaveis do Cabecalho do Modelo 2                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTrans1 	:= CONSTA1->ZU_CODTRAN	//TRANSPORTADORA
		iLoja		:= Space(2)				// LOJA TRANSPORTADORA
		cTrans		:= CONSTA1->ZU_LOTE
		cObs    	:= CONSTA1->ZU_OBS
		cPlaca  	:= CONSTA1->ZU_PLACVEI
		cMotorista	:= CONSTA1->ZU_MTA

		While CONSTA1->(!EOF())

			aAdd( aCols, Array( LEN( AHEADER ) + 1  ) )
			n := Len( aCols )
			aFill( aCols[ n ], " " )

		    aCols[n,1] := CONSTA1->ZU_NF  //NF //	    aCols[n,GdFieldPos(n,"ZU_NF")] 		:= CONSTA1->ZU_NF  //NF
		    aCols[n,2] := CONSTA1->ZU_SERIE                   //SERIE
		    aCols[n,3] := CONSTA1->ZU_VOLUME //Inicia o valor padrão com Zero  //VOLUME
		    aCols[n,4] := CONSTA1->ZU_CLIENTE                 //CLIENTE
		    aCols[n,5] := CONSTA1->A1_NOME                    //DESC CLIENTE
		    aCols[n,6] := CONSTA1->F2_VALBRUT                 //VALORNF
		    aCols[n,7] := CONSTA1->F2_PLIQUI                  //PESO
		    aCols[n,8] := CONSTA1->A4_NOME                    //NOME TRANSP
		    aCols[n,10]:= CONSTA1->ZU_EMBALAD                 //EMBALADOR
		    aCols[n,11]:= CONSTA1->ZU_CONFERE                 //CONFERENTE
			// Jorge Oliveira - 19/07/2010 - Carrega os campos na tela
		    aCols[n,12]:= IIF( Type( "CONSTA1->F2_DTRECNF" ) == "C", StoD( CONSTA1->F2_DTRECNF ), CONSTA1->F2_DTRECNF ) //DATA RECEBIMENTO DA NFS
		    aCols[n,13]:= CONSTA1->F2_HRRECNF		 			//HORA RECEBIMENTO DA NFS

		    If CONSTA1->C5_TPFRETE='F'
				aCols[n,9] := 'FOB'
		    Else
				aCols[n,9]  := 'CIF'
			Endif
			aCols[n][X_DELETE] := .F. //	aCols[Len(aCols)][Len(aHeader)+1] := .F.


			CONSTA1->(DBSKIP() )
	    EndDo

	    //Se não retornou dados cria o acols zerado
		If Empty(aCols)
			aAdd(aCols,Array(LEN(AHEADER)+1))
			IW_MsgBox("Não Gerou dados devido inconsitência no registro posicionado!","Atenção","ALERT")
	        DbCloseArea("CONSTA1")

			Return
		EndIf

	    DbCloseArea("CONSTA1")

	EndIf

	n:=1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis do Rodape do Modelo 2                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLinGetD:=0
	nMsg:=Nil
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Titulo da Janela                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo := "Filial - [" + ALLTRIM( SM0->M0_FILIAL )+ "]" + IIF( Empty( cLote ), "Inclusão", "Alteração" )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array com descricao dos campos do Cabecalho do Modelo 2      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aC:={}
	// aC[n,1] = Nome da Variavel Ex.:"cCliente"
	// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
	// aC[n,3] = Titulo do Campo
	// aC[n,4] = Picture
	// aC[n,5] = Validacao
	// aC[n,6] = F3
	// aC[n,7] = Se campo e' editavel .t. se nao .f.

	// 					 Linha, Coluna
	AADD(aC,{"cTrans"    ,{17,006}	,OemToAnsi("IdTrans            "),"@!",,,.F.})
	AADD(aC,{"cTrans1"   ,{17,150}	,OemToAnsi("Transportadora "),"@!","U_A510VLTR()","SA4", })
	AADD(aC,{"cMotorista",{17,300}	,OemToAnsi("Motorista      "),"@!",,,})
	AADD(aC,{"cPlaca"	 ,{32,006}	,OemToAnsi("Placa/Veículo  "),"@!",,,})
	AADD(aC,{"cObs"	     ,{32,150}	,OemToAnsi("Observações    "),"@!",,,})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array com descricao dos campos do Rodape do Modelo 2         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aR:={}
	// aR[n,1] = Nome da Variavel Ex.:"cCliente"
	// aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
	// aR[n,3] = Titulo do Campo
	// aR[n,4] = Picture
	// aR[n,5] = Validacao
	// aR[n,6] = F3
	// aR[n,7] = Se campo e' editavel .t. se nao .f.

	AADD(aR,{"nMsg"	,{15,10},"IMDEPA ROLAMENTOS","@! ",,,.F.})


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array com coordenadas da GetDados no modelo2                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCGD:={60,10,118,315}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validacoes na GetDados da Modelo 2                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cLinhaOk:="ExecBlock('A510LINOK',.f.,.f.)"
	cTudoOk:="ExecBlock('Md2TudOk',.f.,.f.)"

	dbselectarea('SZU');DbSetOrder(3)
	IF cLote <> Nil .AND. !EMPTY(cLote)
		IF MsSeek(xFilial('SZU')+cLote)
			nSZU	:= 1
		ELSE
			nSZU	:= 0
		ENDIF
	ENDIF

	nLENaColsINI := LEN(aCols)

	/*
	Modelo2( cTitulo, [ aC ], [ aR ], [ aGd ], [ nOp ], [ cLinhaOk ], [ cTudoOk ], aGetsD,  [ bF4 ],;
		      [ cIniCpos ], [ nMax ], [ aCordW ], [ lDelGetD ], [ lMaximazed ], [ aButtons ] )
	##########################################################################################################
	Nome		Tipo			Descricao															Default
	----------------------------------------------------------------------------------------------------------
	cTitulo		Caracter		Titulo da janela													X
	aC			Vetor			Array com os campos do cabecalho
	aR			Vetor			Array com os campos do rodape
	aGd			Vetor			Array com as posicoes para edicao dos itens (GETDADOS)
	nOp			Numerico		Modo de operacao (3 ou 4 altera e inclui itens, 6 altera mas nao
								inclui itens, qualquer outro numero so visualiza os itens)			3
	cLinhaOk	Caracter		Funcao para validacao da linha
	cTudoOk		Caracter		Funcao para validacao na confirmacao
	aGetsD		Vetor			Array com gets editaveis											X
	bF4			Bloco codigo	bloco de codigo para tecla F4
	cIniCpos	Caracter		String com nome dos campos que devem ser inicializados ao
								teclar seta para baixo.
	nMax		Numerico		Quantidade Máxima de ítens da GetDados
	aCordW		Vetor			Coordenadas para montagem da dialog
	lDelGetD	Logico			Determina se as linas da GetDados podem ser deletadas ou nao		.T.
	lMaximazed	Logico			Se a tela virah Maximizada
	aButtons	Vetor			Array com botoes do usuario
	##########################################################################################################

	*/

	// Jorge Oliveira - 17/09/2010 - Declarada e incluida a variavel bF4
	lRetMod2 := Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,,bF4,,,,.T.,.T.,)

	// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
	// objeto Getdados Corrente
	If lRetMod2
		dbselectarea('SZU');DbSetOrder(3)
		For nI := 1 to Len(aCols)
			IF aCols[nI,3] <> NIL
				IF !aCols[nI,X_DELETE]
					//MsGbox("Registro Deletado na linha "+str(nI)) Gravar os registros do aCols
					IF ((nI > nLENaColsINI) .Or.  (Type("lAltera") == "U" .Or. !lAltera))
						recLock("SZU",.T.)
						SZU->ZU_DATA   := date()
					ELSE
						IF SZU->(DbSeek(xFilial('SZU')+cLote+aCols[nI,X_SERIE]+aCols[nI,X_NF])) // FILIAL+LOTE+SERIE+NF
							recLock("SZU",.F.)
						ELSE
							Alert("Não encontrou NF para ser alterada, indo para o proximo registro")
							loop
						ENDIF

					ENDIF
					SZU->ZU_Filial := xFilial("SZU")
					SZU->ZU_NF     := aCols[nI,1]
					SZU->ZU_SERIE  := aCols[nI,2]
					SZU->ZU_VOLUME := aCols[nI,3]
					SZU->ZU_CLIENTE:= aCols[nI,4]
					SZU->ZU_CODTRAN:= cTrans1
					SZU->ZU_LOTE   := cTrans
					SZU->ZU_OBS    := cObs
					SZU->ZU_PLACVEI:= cPlaca
					SZU->ZU_MTA    := cMotorista
					SZU->ZU_EMBALAD:= aCols[nI,10]
					SZU->ZU_CONFERE:= aCols[nI,11]

					// Jorge Oliveira - 19/07/2010 - Grava a data de Entrega na Ordem de Carga e na Nota
		    		SZU->ZU_DTRECNF := aCols[nI,12]
		    		SZU->ZU_HRRECNF := aCols[nI,13]
					MsUnLock()

					If SF2->( DbSeek( xFilial( "SF2" ) + aCols[nI,1] + aCols[nI,2] ) )
						RecLock( "SF2", .F. )
				    		SF2->F2_DTRECNF := aCols[nI,12]
				    		SF2->F2_HRRECNF := aCols[nI,13]
						MsUnLock()
					EndIf

				Else
					IF !((nI > nLENaColsINI) .Or.  (Type("lAltera") == "U" .Or. !lAltera))
						IF SZU->(DbSeek(xFilial('SZU')+cLote+aCols[nI,X_SERIE]+aCols[nI,X_NF])) // FILIAL+LOTE+SERIE+NF
							RecLock('SZU',.F.,.T.)                      // Öndice.
		        			SZU->(dbDelete())
		    		    	MsUnLock()
						ELSE
							Alert("Não encontrou refistro de NF para deleção, desconsiderando o registro")
							loop
						ENDIF

					ENDIF
				ENDIF
			ENDIF

		Next
		ConfirmSX8()
		MsgInfo("Operação Realizada com Sucesso !")
	Else
		RollBackSX8()
	Endif

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A510VLTR    ³ Autor ³Agostinho Lima      ³ Data ³ 23/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao do codigo da transportadora no SA4.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_A510VLTR()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jorge Oliveira³27/07/10³ Ajustes diversos e padronizacao nomenclatura. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function A510VLTR()

	Local aArea := GetArea()
	Local _lOk  := .T.

	DbSelectArea("SA4")
	DbSetOrder( 1 )
	If ! DbSeek(xFilial("SA4")+cTrans1)

	   _lOk  := .F.
	   Aviso( Oemtoansi("Atenção !"), Oemtoansi("Codigo não encontrado no cadastro de transportadora!"), { Oemtoansi("Ok") }, 2 )

	EndIf

	RestArea(aArea)

Return(_lOk)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A510ADDNF   ³ Autor ³Edivaldo Gonçalves  ³ Data ³ 23/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Alimenta Matriz com as Notas Fiscais pertencentes a O.C.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A510ADDNF()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jorge Oliveira³27/07/10³ Ajustes diversos e padronizacao nomenclatura. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function A510ADDNF()

	Local carea := getarea()
	local nrecno:= recno()
	Local crecnoZZU := SZU->(Recno())
	Local nOrdemZZU := SZU->(IndexOrd())

	Local nI
	Private GetNF := {}
	
	

	dbSelectArea("SF2")
	For nI := 1 to Len(aListBox)
		If aListBox[nI,1]
			dbGoto(aListBox[nI,14])
			aAdd(GetNF,{SF2->F2_DOC,SF2->F2_CLIENTE,SF2->F2_SERIE})

		Endif
	Next


	Processa( {|| A510ADDIT() },"Working...","Adicionando Registros à Ordem de Carga Atual..  ")


	dbselectarea('SZU')
	DbSelectArea(nOrdemZZU)
	DBGOTO(crecnoZZU)

	dbselectarea(carea)
	DBGOTO(nRecNo)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A510ADDIT   ³ Autor ³Edivaldo Gonçalves  ³ Data ³ 23/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Adiciona itens pertencentes a Ordem de Carga               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A510ADDIT()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jorge Oliveira³27/07/10³ Ajustes diversos e padronizacao nomenclatura. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function A510ADDIT()

	For i:= 1 to Len(GetNF)   //Colocar o Next do FOR no final do arquivo

		//Itens da Nota Fiscal de Venda
		cQuery :="SELECT UNIQUE SA1.A1_COD,SA1.A1_NOME,SF2.F2_FILIAL,SF2.F2_SERIE,SF2.F2_DOC,SF2.F2_VALBRUT,SF2.F2_PLIQUI,SA4.A4_COD,SA4.A4_NOME,SC5.C5_FILIAL,SC5.C5_NOTA,SC5.C5_TPFRETE,SF2.F2_DTRECNF,SF2.F2_VOLUME1,SF2.F2_HRRECNF"
		cQuery +="  FROM "
		cQuery += RetSqlName( "SA1" )+ " SA1, " + RetSqlName( "SF2" ) + " SF2, "+ RetSqlName( "SA4" ) + " SA4, "+RetSqlName( "SC5" ) +" SC5 "
		cQuery +=" WHERE "
		cQuery +=" SF2.F2_CLIENTE  = '" +GetNF[i,2]+ "'"
		cQuery +=" AND SF2.F2_DOC      = '" +GetNF[i,1] + "'"
		cQuery +=" AND SF2.F2_SERIE    = '" +GetNF[i,3] + "'"
		cQuery +=" AND SF2.F2_FILIAL   = '"+ xFilial("SF2") + "' "
		cQuery +=" AND SF2.F2_FILIAL   = SC5.C5_FILIAL  "
		cQuery +=" AND SF2.F2_SERIE    = SC5.C5_SERIE   "
		cQuery +=" AND SF2.F2_DOC      = SC5.C5_NOTA    "
		cQuery +=" AND SF2.F2_TRANSP   =  SA4.A4_COD    "
		cQuery +=" AND SF2.F2_CLIENTE  = SA1.A1_COD     "
		cQuery +=" AND SF2.F2_LOJA     = SA1.A1_LOJA    "
		cQuery +=" AND SF2.D_E_L_E_T_ <> '*' AND SA1.D_E_L_E_T_ <> '*' AND SA4.D_E_L_E_T_ <> '*' AND SC5.D_E_L_E_T_ <> '*'  "

	 //	MEMOWRIT( "C:\SQLSIGA\" +FunName(1)+"-Adiciona_Acols.SQL", cQuery )

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"INCACOLS",.F.,.T.)

		aTamSX3 := TamSX3("F2_VALBRUT")
		TCSetField( "INCACOLS","F2_VALBRUT",aTamSX3[3],aTamSX3[1],aTamSX3[2])

		aTamSX3 := TamSX3("F2_PLIQUI")
		TCSetField( "INCACOLS","F2_PLIQUI",aTamSX3[3],aTamSX3[1],aTamSX3[2])

		aTamSX3 := TamSX3("F2_DTRECNF")
		TCSetField( "INCACOLS","F2_DTRECNF",aTamSX3[3],aTamSX3[1],aTamSX3[2])

		aTamSX3 := TamSX3("F2_HRRECNF")
		TCSetField( "INCACOLS","F2_HRRECNF",aTamSX3[3],aTamSX3[1],aTamSX3[2])


		DBSELECTAREA("INCACOLS")
		DBGOTOP()


		// Nao pode ter a mesma Nota e Serie
		If aScan( aCols, { |x| x[1]+x[2] == INCACOLS->F2_DOC + INCACOLS->F2_SERIE } ) <= 0

			aAdd(aCols,Array(LEN(AHEADER)+1))
			n:= Len(aCols)
			AFILL(aCols[n],' ')

			aCols[n,1] := INCACOLS->F2_DOC  //NF
			aCols[n,2] := INCACOLS->F2_SERIE                   //SERIE
			aCols[n,3] := INCACOLS->F2_VOLUME1 //0 //Inicia o valor padrão com Zero  //VOLUME
			aCols[n,4] := INCACOLS->A1_COD                     //CLIENTE
			aCols[n,5] := INCACOLS->A1_NOME                    //DESC CLIENTE
			aCols[n,6] := INCACOLS->F2_VALBRUT                 //VALORNF
			aCols[n,7] := INCACOLS->F2_PLIQUI                  //PESO
			aCols[n,8] := INCACOLS->A4_NOME                    //NOME TRANSP
			aCols[n,10]:= SPACE(2)                            //EMBALADOR
			aCols[n,11]:= SPACE(2)                            //CONFERENTE
			// Jorge Oliveira - 19/07/2010 - Inclui os campos na tela
		    aCols[n,12]:= IIF( Type( "CONSTA1->F2_DTRECNF" ) == "C", StoD( INCACOLS->F2_DTRECNF ), INCACOLS->F2_DTRECNF ) //DATA RECEBIMENTO DA NFS
		    aCols[n,13]:= INCACOLS->F2_HRRECNF	 				//MERCADORIA JA ENTREGUE PARA O CLIENTE
		    aCols[n,14]:= "N"									//HORA RECEBIMENTO DA NFS

			If INCACOLS->C5_TPFRETE='F'
				aCols[n,9] := 'FOB'
			Else
				aCols[n,9]  := 'CIF'
			Endif
			aCols[n][X_DELETE] := .F. //	aCols[Len(aCols)][Len(aHeader)+1] := .F.
	    Else
	    	Alert( "A Nota " + INCACOLS->F2_SERIE + " / " + INCACOLS->F2_DOC + " já foi adicionada." )
	    EndIf

		DBSELECTAREA("INCACOLS")
		DbCloseArea()

	Next i

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A510NEXTOC  ³ Autor ³Edivaldo Gonçalves  ³ Data ³ 23/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o proximo Numero da Ordem de Carga disponivel      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A510NEXTOC()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cPrxNumOc => Proximo numero disponivel                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jorge Oliveira³27/07/10³ Ajustes diversos e padronizacao nomenclatura. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function A510NEXTOC()

	Local cPrxNumOc
	// Tamanho do campo
	Local nTam := TamSx3("ZU_LOTE")[1]

	cQuery :="SELECT MAX(ZU_LOTE)MaxLote FROM "
	cQuery += RetSqlName( "SZU" )
	cQuery +=" WHERE ZU_FILIAL = '" + xFilial("SZU") + "' AND "
	cQuery +=" D_E_L_E_T_ <> '*'"

	TCQUERY cQuery NEW ALIAS 'MAX_ZU'

	DBSELECTAREA("MAX_ZU")

	// Calcula o proximo numero
	cPrxNumOc	:= strzero( val(MAX_ZU->MaxLote) + 1 , nTam )//SOMA1(ALLTRIM(MAX_ZU->MaxLote))
	DBCLOSEAREA("MAX_W6")

	While  !MayIUseCode("SZU"+xFilial("SZU")+ cPrxNumOc )
		cPrxNumOc	:= strzero( val(cPrxNumOc) + 1 , nTam ) //SOMA1(cPrxNumOc)
	EndDo

Return cPrxNumOc


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A510LINOK   ³ Autor ³Edivaldo Gonçalves  ³ Data ³ 23/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacoes da linha contendo a NF e outras validacoes.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A510LINOK()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. se tudo ok, ou .F. caso tenha alguma inconsistencia    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jorge Oliveira³27/07/10³ Ajustes diversos e padronizacao nomenclatura. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function A510LINOK()

	If !aCols[ n, X_DELETE ]

		// Valida se a Data e Hora do RECEBIMENTO DA NFS digitada sao validas
		/*
		If ( ( Val( DtoC( aCols[ n, 12 ] ) ) > 0 .And. !U_ValidHor( aCols[ n, 13 ] ) ) .Or.;
		     ( !Empty( Replace( aCols[ n, 13 ], ":" ) ) .And. Val( DtoC( aCols[ n, 12 ] ) ) <= 0 ) )
		*/
		If !Empty( Replace( aCols[ n, 13 ], ":" ) ) .And. !U_ValidHor( aCols[ n, 13 ] )

			MsgInfo( "Favor informar corretamente a Hora do Recebimento da NF ou deixe o campo em branco." )
			Return( .F. )

		EndIf

		//JULIO JACOVENKO, dia 16/01/2012
		//ref. chamado AAZUNW
		// Valida para não permitir num Nota e Serie ja digitada no acols
		cValida:=aCols[n,1]+aCols[n,2]
		IF LEN(ACOLS)>1
		For K:=1 to len(aCols)
		    If aCols[k,1]+aCols[k,2] == cValidA .AND. K<>N
		    	MsgInfo( "Este Num e Serie de NF estão duplicados! "+aCols[k,1]+"/"+aCols[k,2] )
			    Return( .F. )
		    EndIf
		Next
		ENDIF

	EndIf

Return( .T. )
