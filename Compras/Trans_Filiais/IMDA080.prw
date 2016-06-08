#INCLUDE "Ap5Mail.ch"
#INCLUDE "FiveWin.ch"

#DEFINE X_lMKBR_SC7		01
#DEFINE X_ZE_PRODUTO 	04
#DEFINE X_ZE_QTDPC		05
#DEFINE X_ZE_DESTINO	06
#DEFINE X_ZE_QTDORIG	07
#DEFINE X_ZE_HAWB		08
#DEFINE X_ZE_DTENTRE	09
#DEFINE X_ZE_EXCED		10
#DEFINE X_ZE_LOCAL		11
#DEFINE X_ZE_NUMPLAN	12
#DEFINE X_ZE_ITEM		13
#DEFINE X_ZE_PVITEM		14

           
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ IMDA080  ºAutor  ³Marllon Figueiredo  º Data ³ 14/03/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotima para geracao da planilha de transferencia de estoqueº±±
±±º          ³ entre filiais atraves dos Pedidos de Compra nacionais e ou º±±
±±º          ³ compras importadas.                                        º±±
±±º          ³ Permite exclusao de planilha gerada e que nao foi processa-º±±
±±º          ³ da.                                                        º±±
±±º          ³ Envia e-mail para as filiais informando da geracao da Pla- º±±
±±º          ³ nilha.                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUltimas Alteracoes                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAutor     ³ Data     Ø  Descricao                                      º±±
±±º          ³          Ø                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function IMDA080()
Local cFiltro   := Space(0)
Local aFixe     := {{ OemToAnsi("Planilha    "), "ZE_NUMPLAN" },;  //"Planilha    "
					{ OemToAnsi("Item        "), "ZE_ITEM   " },;  //"Item        "
					{ OemToAnsi("Num. PC/PO  "), "ZE_HAWB   " }}   //"Processo    "

Local aCores    := {{ 'ZE_FLAGPT <> "S" .and. ZE_VENCD < dDataBase', 'BR_AZUL' },;
					{ 'ZE_FLAGPT <> "S"', 'ENABLE'  },;
					{ 'ZE_FLAGPT == "S"', 'DISABLE' }}

Private bFiltraBrw := {|| nil}
Private nFuncao    := 1
Private nTipoPed   := 1
Private cCadastro  := "Planilha de Transferência"

// Variaveis utilizadas na funcao A120Pedido()
Private l120Auto   := .F.
Private aAutoCab   := {}
Private aAutoItens := {}
Private lPedido    := .T.


//+--------------------------------------------------------------+
//¦ Define Array contendo as Rotinas a executar do programa      ¦
//¦ ----------- Elementos contidos por dimensao ------------     ¦
//¦ 1. Nome a aparecer no cabecalho                              ¦
//¦ 2. Nome da Rotina associada                                  ¦
//¦ 3. Usado pela rotina                                         ¦
//¦ 4. Tipo de Transaçäo a ser efetuada                          ¦
//¦    1 - Pesquisa e Posiciona em um Banco de Dados             ¦
//¦    2 - Simplesmente Mostra os Campos                         ¦
//¦    3 - Inclui registros no Bancos de Dados                   ¦
//¦    4 - Altera o registro corrente                            ¦
//¦    5 - Remove o registro corrente do Banco de Dados          ¦
//+--------------------------------------------------------------+
Private aRotina := { 	{OemtoAnsi('Pesquisar'),  'AxPesqui',     0 , 1}  ,;  // "Pesquisar"
						{OemtoAnsi('Visualizar'), 'u_IMD090Man',  0 , 2}  ,;  // 'Visualizar'
						{OemtoAnsi('Planilha'),   'u_IMD080Gera', 0 , 3}  ,;  // "Planilha"
						{OemtoAnsi('Excluir'),    'u_IMD080Exc',  0 , 2}  ,;  // "Excluir"
						{OemtoAnsi("Legenda"),    'u_IMD080Leg',  0 , 2}}     // "Legenda"

Private cPerg   := 'IMD080'


ValidPerg(cPerg)
dbSelectArea('SZE')
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a funcao FilBrowse                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiltro := "ZE_FILIAL == '"+xFilial('SZE')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1, 22, 75, 'SZE', aFixe,,,,, aCores )

dbSelectArea('SZE')
dbSetOrder(1)

Return(.T.)



/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³IMD080GERA³ Autor ³ Marllon Figueiredo    ³ Data ³14/03/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Dispara a rotina de geracao de planilhas                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function IMD080Gera()
u_IMD080Plan()
Return nil



/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³IMD080PLAN³ Autor ³ Marllon Figueiredo    ³ Data ³14/03/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta planilhas de transferencia entre filiais             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ lFlag = Se .F. nao mostra o dialogo de selecao dos itens   ³±±
±±³          ³         do pedido de compras, porque foi chamada de uma    ³±±
±±³          ³         inclusao automatica de planilha na tela da verdade ³±±
±±³          ³         quando faz reserva de saldo de transferencia entre ³±±
±±³          ³         filiais.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function IMD080Plan( lFlag, cNumPC, aSelPc )

Local cAlias 	:= Alias()
Local nRecno	:= &(cAlias)->(Recno())
Local nSB1Recno := SB1->(Recno()) 


Local cNumPlan   := GetSxeNum('SZE', 'ZE_NUMPLAN')
Local cNumItem   := '00'
Local lPlan      := .F.
Local lNovoItem  := .T.
Local lOk        := .T.
Local cAuto      := lFlag
Local cLocPad   // Estoque padrao do produto
// variaveis utilizadas na funcao IA080PO()...
Private cNewSC	:= ''
Private cNewSI	:= ''
Private nNewIt	:= 0


// Se nao passar este parametro entao sempre mostra o dialogo de selecao
DEFAULT lFlag := .T.
                             
DbSelectArea("SB1");DbSetOrder(1)

If lFlag
	// start das perguntas para selecao dos registros
	lOk := Pergunte('IMD080', lFlag)
Else
	lOk := .T.
EndIf

If lOk
	If !lFlag
		MV_PAR01 := 1    // Nacional
		MV_PAR02 := ''   // Numero da DI
		MV_PAR03 := cNumPC    // Numero do pedido de compras
	EndIf

	// seleciona os pedidos de compra somente se nao passou os dados para 
	// geracao da planilha
	If aSelPc = nil
		aSelPc := SelPC( lFlag )
	EndIf      
	
	nStart := 1
	For nStart := 1 To Len(aSelPc)
	
		// se foi selecionado
		If aSelPc[nStart,1]
			// incluo o item na planilha
			dbSelectArea('SZE');dbSetOrder(2)          // NUMPLAN + DESTINO + PRODUTO + DATA DE ENTREGA

			If ! dbSeek(xFilial('SZE')+cNumPlan+aSelPc[nStart, X_ZE_DESTINO]+aSelPc[nStart, X_ZE_PRODUTO]+Dtos(aSelPc[nStart, X_ZE_DTENTRE]))
				IF SB1->(DBSEEK(xFilial("SB1")+ aSelPc[nStart, X_ZE_PRODUTO]))
					cLocPad := SB1->B1_LOCPAD   
				ELSE
					cLocPad := "  "
				ENDIF
				RecLock('SZE', .T.)
				// proximo numero de item
				cNumItem  := Soma1(cNumItem)
				lNovoItem := .T.
			Else
				RecLock('SZE', .F.)
				lNovoItem := .F.
			EndIf
			
			SZE->ZE_FILIAL     := xFilial('SZE')
			SZE->ZE_NUMPLAN    := cNumPlan
			SZE->ZE_ITEM       := Iif(lNovoItem, cNumItem, SZE->ZE_ITEM)
			SZE->ZE_DATA       := dDataBase
			SZE->ZE_VENCD      := dDataBase + 5
			SZE->ZE_VENCH      := Time()
			SZE->ZE_PRODUTO    := aSelPc[nStart, X_ZE_PRODUTO]
			// somente gravo para compras importadas
			If MV_PAR01 == 2
				SZE->ZE_HAWB   := aSelPc[nStart, X_ZE_HAWB]  // por solicitacao do cliente devo gravar o numero do PC/PO
			EndIf
			SZE->ZE_DESTINO    := aSelPc[nStart, X_ZE_DESTINO]
			SZE->ZE_QTDORIG    := SZE->ZE_QTDORIG + aSelPc[nStart, X_ZE_QTDORIG]
			SZE->ZE_QTDPC      := SZE->ZE_QTDPC + aSelPc[nStart, X_ZE_QTDPC]
			SZE->ZE_QTDRES     := 0
			If aSelPc[nStart, X_ZE_QTDORIG] <= 0    // Pedido s/ solicitacao de compras
				SZE->ZE_QTDTRAN    := SZE->ZE_QTDTRAN + 0
			Else
				SZE->ZE_QTDTRAN    := SZE->ZE_QTDTRAN + Min(aSelPc[nStart, X_ZE_QTDPC],aSelPc[nStart, X_ZE_QTDORIG])   // QTDPC ou QTDORIG
			EndIf
			SZE->ZE_CODCLI     := Space(0)
			SZE->ZE_LOJA       := Space(0)
			SZE->ZE_DTENTRE    := aSelPc[nStart, X_ZE_DTENTRE]
			SZE->ZE_EXCED      := aSelPc[nStart, X_ZE_EXCED]        
            
            //Cristiano 22-09-08 Solicitato Por Edivaldo
            SZE->ZE_ORIGEM 	   := Iif(FUNNAME()=='IMDA070','',SUA->UA_NUM)
            
             
             //Inserido por Edivaldo Gonçalves Cordeiro 
              If Empty(aSelPc[nStart,X_ZE_LOCAL]) //Planilha gerada a partir de uma rotina Automática,seto o armazem Padrão
	              	SZE->ZE_LOCAL:=cLocPad
                Else
             	SZE->ZE_LOCAL      :=aSelPc[nStart,X_ZE_LOCAL] //Planilha gerada a partir de um processo manual,capturo o armazém informado do produto
             Endif
						
			MsUnLock()

			// Se o item 12 e 13 existirem eu devo gravar o numero e item da
			// planilha nestas posicoes
			If Len(aSelPc[nStart]) > X_ZE_LOCAL
				aSelPc[nStart,12] := SZE->ZE_NUMPLAN
				aSelPc[nStart,13] := SZE->ZE_ITEM
			EndIf
			
			// marco o pedido de compras
			dbSelectArea('SC7')
			dbSetOrder(1)
//			If dbSeek(SZE->ZE_DESTINO+aSelPc[nStart,2]+aSelPc[nStart,3])
			
			If dbSeek(SZE->ZE_DESTINO+aSelPc[nStart,2]+aSelPc[nStart,3])				
				RecLock('SC7', .F.)
				SC7->C7_FLAGPT  := 'S'
				SC7->C7_PLANILH := SZE->ZE_NUMPLAN
				SC7->C7_PLITEM  := SZE->ZE_ITEM
				MsUnLock()
				
				// alterado por Luciano Corrêa em 20/06/05...
				// se importacao e possui saldo no pedido, deve ser gerado um novo item...
				If mv_par01 == 2
					
					u_IA080PO()
				EndIf
			EndIf
			
			// flag de gravacao, indica que salvou a planilha
			lPlan := .T.
		EndIf
	Next
	
	// retorna area original
	dbSelectArea('SZE')
	dbSetOrder(3) // ZE_FILIAL + ZE_NUMPLAN + ZE_ITEM
	dbSeek( xFilial('SZE') + cNumPlan + '01' )
EndIf

If lPlan
	ConfirmSX8()
Else
	RollBackSX8()
EndIf

// envia e-mail para os Gerentes informando da geracao da planilha
If lPlan .and. lFlag
	u_I080SndMail(cNumPlan, aSelPC)
EndIf

SB1->(Dbgoto(nSB1Recno))
&(cAlias)->(Dbgoto(nRecno))

Return



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºProgram   ³SelPC     ºAuthor ³Marllon Figueiredo  º Date ³ 17/03/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta um vetor com os pedidos de compra para serem selecio- º±±
±±º          ³nados.                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametro ³ lFlag = Se .F. nao mostra o dialogo de selecao dos itens   ³±±
±±³          ³         do pedido de compras, porque foi chamada de uma    ³±±
±±³          ³         inclusao automatica de planilha na tela da verdade ³±±
±±³          ³         quando faz reserva de saldo de transferencia entre ³±±
±±³          ³         filiais.                                           ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUse       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SelPC( lFlag )

Local nQtdPos    := 0
Local nPos       := 0
Local nPosIni    := 0
Local nList      := 0
Local oDlg
Local aTotal     := Array(0)
Local cSCFil     := Space(2)
Local cSCQuant   := 0
Local cSCNum     := Space(6)
Local aArea      := GetArea()
Local aAreaSB1   := SB1->( GetArea() )
Local cTipoSZE   := GetMV('MV_TIPOSZE')
Private oList
Private aList    := Array(0)
Private oOk      := Loadbitmap(GetResources(), 'LBOK')
Private oNo      := Loadbitmap(GetResources(), 'LBNO')
Private aListAux := {}


DEFAULT lFlag := .T.

// monta uma Dialog com um Browse do SC7 para selecao
If lFlag
	DEFINE MSDIALOG oDlg TITLE 'Pedidos de Compra' FROM 0,0 TO 18,90 OF oMainWnd
	
	DEFINE SBUTTON oBut FROM 115,130 TYPE 01 ENABLE OF oDlg PIXEL ACTION oDlg:End()
	DEFINE SBUTTON oBut FROM 115,200 TYPE 02 ENABLE OF oDlg PIXEL ACTION(aList:=Array(0), oDlg:End())
EndIf

// Compras nacionais
	If lFlag
		aList    := {{.F.,'Pedido','Item','Produto','Descricao','Qtde P.C.','Filial','Qtde Sol','Num Sol','Prev. Entrega','Excedente'}}
		@ 02,02  LISTBOX oList ;
		         FIELDS HEADER  '  ','Pedido','Item','Produto','Descricao','Qtde P.C.','Filial','Qtde Sol','Num Sol','Prev. Entrega','Excedente' ;
		         SIZE 300,105 ;
		         PIXEL OF oDlg ;
		         ON dblClick(aList:=SDTroca(oList:nAt,aList),oList:Refresh())
	    oList:Align := 3
	EndIf
	
	// localiza o pedido de compra selecionado no parametro
	dbSelectArea('SC7')
	dbSetOrder(1)
	dbSeek(xFilial('SC7')+MV_PAR03)

	// carrega as posicoes para o vetor listbox
	aList := Array(0)
	Do While !Eof() .and. SC7->C7_NUM == MV_PAR03 .and. xFilial('SC7') == SC7->C7_FILIAL
		// testa se o item do pedido ja foi processado
		If SC7->C7_FLAGPT == 'S'
			dbSelectArea('SC7')
			dbSkip()
			Loop
		EndIf

		// Se for para planilha de importados, testo se o pedido foi gerado pela rotina de importacao
		If MV_PAR01 = 2 .and. Empty(SC7->C7_NUMIMP)   // ORIGEM == 'EICPO400'
			dbSelectArea('SC7')
			dbSkip()
			Loop
		EndIf

		// Se for para planilha de nacionais, testo se o pedido foi gerado pela rotina de inc. de pedidos normal
		If MV_PAR01 = 1 .and. !Empty(SC7->C7_NUMIMP)
			dbSelectArea('SC7')
			dbSkip()
			Loop
		EndIf

		SB1->( dbSeek(xFilial('SB1')+SC7->C7_PRODUTO) )
		If ! (AllTrim(SB1->B1_TIPO) $ cTipoSZE)
			dbSelectArea('SC7')
			dbSkip()
			Loop
		EndIf
		
		// testa se o item do pedido ja teve entrada de nota
		// isto eh necessario porque nao posso ter mais de uma planilha por item
		// de pedido.
		If SC7->C7_QUJE > 0
			dbSelectArea('SC7')
			dbSkip()
			Loop
		EndIf

		// posiciona na solicitacao
		dbSelectArea('SC1')
		dbSetOrder(1)

		// isto eh feito porque os pedidos de compra gerados pelo modulo de 
		// importacao sempre gravam como 01 o item da solicitacao do compras, mesmo que exista
		// mais de um item na SC.
		cSCFil     := SC7->C7_FILIAL
		cSCQuant   := 0
		cSCNum     := Space(6)
		If dbSeek(xFilial('SC1')+SC7->C7_NUMSC)
			Do While !Eof() .and. SC7->C7_NUMSC = SC1->C1_NUM
				If SC7->C7_PRODUTO = SC1->C1_PRODUTO
					cSCFil     := SC1->C1_MSFIL
					cSCQuant   := SC1->C1_QUANT
					cSCNum     := SC1->C1_NUM
					Exit
				EndIf
				dbSkip()
			EndDo
		EndIf
		
		// atualiza o vetor de selecao
		dbSelectArea('SC7')
		Aadd(aList,{.T.,;
		            SC7->C7_NUM,;
		            SC7->C7_ITEM,;
		            SC7->C7_PRODUTO,;
		            SC7->C7_QUANT,;
		            cSCFil,;
		            cSCQuant,;
		            Iif(MV_PAR01=2,SC7->C7_NUM,cSCNum),;
		            SC7->C7_DATPRF,;
					0,;										//10 //X_ZE_EXCED
					' ',; 									//11 //X_ZE_LOCAL	//cItem
					' ',;									//12 //X_ZE_NUMPLAN
					' ',;									//13 //X_ZE_ITEM
					' ',;									//14 //X_ZE_PVITEM
					})
		            
		// inserido por Luciano Correa em 18/07/05...
		aAdd( aListAux, SC7->C7_DESCRI )

		dbSkip()
	EndDo

	// testa se encontrou algum registro, pois o array nao pode 
	// ser passado vazio para a listbox
	If Empty(aList)
		aList := {{.F.,'','','',0,'',0,'',Ctod(''),0}}
		aListAux :=  { '' }
	EndIf
	
	If lFlag
		oList:SetArray(aList)
		oList:bLine:={|| {If(aList[oList:nAt,01],oOk,oNo),;
							 aList[oList:nAt,02],;
							 aList[oList:nAt,03],;
							 aList[oList:nAt,04],;
							 aListAux[oList:nAt],;
							 aList[oList:nAt,05],;
							 aList[oList:nAt,06],;
							 aList[oList:nAt,07],;
							 aList[oList:nAt,08],;
							 aList[oList:nAt,09],;
							 aList[oList:nAt,10]}}
		oList:Refresh()
	EndIf
	
If lFlag
	ACTIVATE MSDIALOG oDlg CENTERED
EndIf

// calcula o excedente
aList := u_CalcExced(aList)

RestArea(aAreaSB1)
RestArea(aArea)

Return(aList)



/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CalcExced ³ Autor ³ Marllon Figueiredo    ³ Data ³14/03/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula o saldo excedente da planilha sendo gerada         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function CalcExced(aList)
Local aTotal := Array(0)
Local nPos, nStart

// calculo do saldo excedente
nStart := 1
For nStart := 1 To Len(aList)
	// se foi selecionado
	If aList[nStart,1]
		// somente tenho excedente se o pedido de compras for maior que a solicitacao
		If aList[nStart,5] > aList[nStart,7]
			nPos := Ascan(aTotal, {|x| x[1]+Dtos(x[2]) == aList[nStart,4]+Dtos(aList[nStart,9])})
			If nPos > 0
				aTotal[nPos,3] := aTotal[nPos,3] + (aList[nStart,5] - aList[nStart,7])
			Else
				Aadd(aTotal, {aList[nStart,4], aList[nStart,9], (aList[nStart,5] - aList[nStart,7])})
			EndIf
		EndIf
	EndIf
Next

// atualizo o array da planilha com o saldo excedente
nStart := 1
For nStart := 1 To Len(aList)
	// se foi selecionado
	If aList[nStart,1]
		nPos := Ascan(aTotal, {|x| x[1]+Dtos(x[2]) == aList[nStart,4]+Dtos(aList[nStart,9])})
		If nPos > 0
			aList[nStart,10] := aTotal[nPos,3]
		EndIf
	EndIf
Next

Return(aList)



/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³IMD090Leg ³ Autor ³ Marllon Figueiredo    ³ Data ³14/03/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclui a planilha de transferencia                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function IMD080Exc()
Local lDel         := .T.
Local aArea        := GetArea()
Local aAreaSB2     := SB2->( GetArea() )
Local aAreaSC6     := SC6->( GetArea() )
Local aAreaSC7     := SC7->( GetArea() )
Local cNumPlan     := SZE->ZE_NUMPLAN
Local __cFilAnt__  := cFilAnt
Local lExcPC       := .F.



// Testa se a planilha eh da filial ativa
If SZE->ZE_MSFIL <> cFilAnt
	Help(' ', 1, 'Atenção',,'Esta Planilha somente poderá ser excluida na Filial que a gerou! - (Filial - '+SZE->ZE_MSFIL+')',1,1)
	lDel := .F.
EndIf

// Testa se a planilha nao sofreu manutencao
If lDel
	dbSelectArea('SZE')
	dbSeek(xFilial('SZE')+cNumPlan)
	Do While ! Eof() .and. SZE->ZE_NUMPLAN == cNumPlan
		// verifica se tem reserva
		If SZE->ZE_QTDRES > 0
			MsgInfo('Atenção! Esta Planilha já tem reservas, por isto não poderá ser Excluida!')
			lDel := .F.
			Exit
		EndIf
		// planilha processada deve ser feito validacoes para verificar se pode ser excluida
		If SZE->ZE_FLAGPT == 'S'
			// avaliar o pedido de venda (transferencia)
			dbSelectArea('SC6')
			dbOrderNickName('C6_PLAN')
			dbSeek(xFilial('SC6')+SZE->ZE_NUMPLAN+SZE->ZE_ITEM)
			SC5->( dbSeek(xFilial('SC5')+SC6->C6_NUM) )
			If SC6->C6_QTDENT > 0
				lDel := .F.
				MsgInfo('Atenção! O P.V. de transferencia num: '+SC5->C5_NUM+' ja foi enviado (Nota Emitida) por isto não poderá ser Excluida!')
				Exit
			EndIf

			// avaliar o pedido de compra (transferencia)
			dbSelectArea('SC7')
			dbOrderNickName('C7_PLAN')
			dbSeek(SZE->ZE_DESTINO+SZE->ZE_NUMPLAN+SZE->ZE_ITEM)  		
			If SC7->C7_QUJE > 0
				lDel := .F.
				MsgInfo('Atenção! O P.C. de transferencia num: '+SC7->C7_NUM+' ja tem entrada de Nota no sistema por isto esta Planilha não poderá ser Excluida!')
				Exit
			EndIf
		EndIf
		dbSelectArea('SZE')
		dbSkip()
	EndDo		
EndIf

If lDel .and. ! MsgYesNo('Exclui esta Planilha?')
	lDel := .F.
EndIf

// testa se pode excluir a planilha
If lDel .and. MsgYesNo('Exclui o Pedido de Compra que gerou esta Planilha?')
	lExcPC := .T.
EndIf

If lDel
	// posiciona no primeiro item da planilha
	dbSelectArea('SZE')
	dbSeek(xFilial('SZE')+cNumPlan)
	Do While ! Eof() .and. SZE->ZE_NUMPLAN == cNumPlan
		// posiciona no PV de transferencia
		dbSelectArea('SC6')
		dbOrderNickName('C6_PLAN')
		dbSeek(xFilial('SC6')+SZE->ZE_NUMPLAN+SZE->ZE_ITEM)
		SC5->( dbSeek(xFilial('SC5')+SC6->C6_NUM) )
		
		// dispara a funcao de exclusao do pedido de transferencia (parte SC5/SC6)
		// na casa distribuidora
		// DelPVenda() declarada em TMKVEX.PRW
		If u_DelPVenda(SC5->C5_NUM)
			// avaliacao do pedido de compra
			// somente excluo o p.c. se o pv for excluido
			// posiciona na filial correta
			cFilAnt := SZE->ZE_DESTINO
			// posiciona no PC de transferencia
			dbSelectArea('SC7')
			dbOrderNickName('C7_PLAN')
			dbSeek(xFilial('SC7')+SZE->ZE_NUMPLAN+SZE->ZE_ITEM)
			u_DelPCompra(SC7->C7_NUM)
		EndIf
		// retorno para a filial correta
		cFilAnt := __cFilAnt__
	
		// posiciona no pedido de compras
		dbSelectArea('SC7')
		dbOrderNickName('C7_PLAN')
		If dbSeek(SZE->ZE_MSFIL+SZE->ZE_NUMPLAN+SZE->ZE_ITEM)
			If lExcPC
				// exclui o pedido de compra do fornecedor
				u_DelPCompra(SC7->C7_NUM)
    		Else
				// desmarca os itens do pedido de compras
				RecLock('SC7',.F.)
				SC7->C7_FLAGPT  := ''
				SC7->C7_PLANILH := ''
				SC7->C7_PLITEM  := ''
				MsUnLock()
			EndIf
        EndIf
        
		// excluo a planilha
		dbSelectArea('SZE')
		RecLock('SZE',.F.)
		Delete
		MsUnLock()

		// proximo registro da planilha
		dbSkip()
	EndDo
	
	// alterado por Luciano Correa em 21/07/04 - atualizar b2_salpedi...
	SB2->( dbSetOrder( 1 ) )
	
	// desmarco as solicitacoes de compra
	dbSelectArea('SC1')
	dbOrderNickName('C1_PLAN')
	// Posiciono no registro
	dbSeek(xFilial('SC1')+cNumPlan)
	Do While !Eof() .and. cNumPlan == SC1->C1_NUMPLAN
		
		// alterado por Luciano Correa em 21/07/04 - atualizar b2_salpedi...
		If SB2->( dbSeek( SC1->C1_MSFIL + SC1->C1_PRODUTO + SC1->C1_LOCAL, .f. ) )
			
			// soma na quantidade prevista a quantidade ja entregue que sera zerada...
			SB2->( RecLock( 'SB2', .f. ) )
			SB2->B2_SALPEDI += SC1->C1_QUJE
			SB2->( MsUnlock() )
		EndIf
		
		RecLock('SC1',.F.)
		SC1->C1_QUJE     := 0
		SC1->C1_COTACAO  := ""
		SC1->C1_NUMPLAN  := ""
		msUnLock()

		// faco isto porque o campo C1_NUMPLAN faz parte da chave de indice
		dbSeek(xFilial('SC1')+cNumPlan)
	EndDo
EndIf

// retorna areas originais
RestArea(aAreaSB2)
RestArea(aAreaSC6)
RestArea(aAreaSC7)
RestArea(aArea)

Return



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³VALPLAEXC º Autor ³ Marllon            º Data ³05/04/2004   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Valida a exclusao da planilha de transferencia             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ValPlaExc(cPlanilha)
Local cRet     := 'SIM'


// Codigos de retorno
// SIM   = planilha pode ser excluida
// 001   = planilha com reserva de pedidos de venda, nao pode ser excluida
// 002   = planilha processada c/ PV de transferencia ja faturado

dbSelectArea('SZE')
dbSeek(xFilial('SZE')+cPlanilha)
Do While !Eof() .and. SZE->ZE_NUMPLAN = cPlanilha
	// existe P.V. alocado nesta planilha
	If SZE->ZE_QTDRES > 0
		cRet := '001'
		Exit
	EndIf
	// a planilha ja foi processada
	If SZE->ZE_FLAGPT = 'S'
		// AVALIAR O PEDIDO DE VENDA (TRANSFERENCIA)
		//     A) PEDIDO ABERTO/LIBERADO  -  ESTORNA A LIBERACAO E EXCLUI
		//     B) PEDIDO SEPARADO - ESTORNA A LIBERACAO / EXCLUI E ENVIA E-MAIL
		//     C) PEDIDO FATURADO - ENVIA E-MAIL
		dbSelectArea('SC6')
		dbOrderNickName('C6_PLAN')
		dbSeek(xFilial('SC6')+SZE->ZE_NUMPLAN+SZE->ZE_ITEM)
		SC5->( dbSeek(xFilial('SC5')+SC6->C6_NUM) )
			// Se esta faturado somente envia mail
			If SC6->C6_QTDENT > 0
				cRet := '002'
				Exit
			EndIf
	EndIf
	
	dbSelectArea('SZE')
	dbSkip()
EndDo

Return(cRet)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºProgram   ³SDTroca   ºAuthor ³Marllon Figueiredo  º Date ³  10/04/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Troca o flag de marcacao do browse                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUse       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SDTroca(nIt, aVetor)
Local oDlg1, oBut1
Local nQuant  := aVetor[nIt,5]
Local lOk     := .F.

// troca o flag de marcacao
aVetor[nIt,1] := ! aVetor[nIt,1]


// somente altero para compras importadas
If MV_PAR01 = 2
	If aVetor[nIt,1]
		Define msDialog oDlg1 Title OemToAnsi( 'Quantidade' ) From 00,00 To 100,400 Pixel
		
		@ 012,008 Say OemToAnsi( 'Quantidade:' ) Of oDlg1 Pixel
		@ 012,055 msGet nQuant Picture '@E 9,999,999.99' Of oDlg1 Pixel Size 100,10 VALID nQuant >= 0   
		
		Define sButton oBut1 From 030,165 Type 01 Enable Of oDlg1 Pixel Action ( lOk:=.T., oDlg1:End() )
		
		Activate msDialog oDlg1 Center
	EndIf
EndIf

If lOk
	aVetor[nIt,5] := nQuant
EndIf

Return(aVetor)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³I080SndMail ºAutor  ³Marllon Figueiredo  ºData  ³18/03/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDesc.     ³Envia e-mail para os gerentes das filiais informando que a  º±±
±±º          ³planilha de transferencia foi gerada e estah pronta para    º±±
±±º          ³manutencao.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³IMDEPA                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function I080SndMail(cNumPlan, aItens)
Local cServer  := GetMV('MV_RELSERV')
Local cUser    := GetMV('MV_RELACNT')
Local cPass    := GetMV('MV_RELPSW')
Local lAuth    := Getmv("MV_RELAUTH")
Local lResult  := .F.
Local cError
Local nStart   := 0
Local aFil     := Array(0)
Local cBody
Local cHtml    := Space(0)
Local lOk
Local oProcess
Local cTo      := Space(0)



// posiciona na planilha
dbSelectArea('SZE')
dbSeek(xFilial('SZE')+cNumPlan)

// recupera as filiais
nStart := 1
For nStart := 1 To Len(aItens)
	// se foi selecionado
	If aItens[nStart,1]
		If Ascan(aFil, {|x| x[1] == aItens[nStart,6]}) <= 0
			aAdd(aFil, {aItens[nStart,6], Tabela('I2',aItens[nStart,6],.F.)})
		EndIf
	EndIf
Next

nStart := 1
For nStart := 1 To Len(aFil)
	cTo += aFil[nStart, 2]+'; '
Next

cHtml += 'Gerenciamento automatico de Estoques' + CRLF
cHtml += CRLF
cHtml += CRLF
		
cHtml += 'Informa que a Planilha de transferencia número: '+cNumPLan+' ' + CRLF
cHtml += CRLF
cHtml += 'foi gerada, e que deve ser efetuado a manutencao da mesma até '+Dtoc(SZE->ZE_VENCD)+' as '+SubStr(SZE->ZE_VENCH,1,5)+'.' + CRLF
cHtml += CRLF
cHtml += CRLF

cHtml += 'Não é necessário responder este e-mail.'+Chr(13)+Chr(10)
cHtml += CRLF

// conectando-se com o servidor de e-mail
CONNECT SMTP SERVER cServer ACCOUNT cUser PASSWORD cPass RESULT lResult

// fazendo autenticacao 
If lResult .And. lAuth
	lResult := MailAuth(cUser,cPass)
	If !lResult
		lResult := QADGetMail() // Funcao que abre uma janela perguntando o usuario e senha para fazer autenticacao
	EndIf
	If !lResult
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		u_Mensagem("Erro de Autenticacao no Envio de e-mail: "+cError)
		Return Nil
	Endif
Else
	If !lResult
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		u_Mensagem("Erro de Conexao no envio de e-mail: "+cError)
		Return Nil
	Endif
EndIf

SEND MAIL FROM cUser ;
     TO cTo;
     SUBJECT 'Planilha de Transferencia';
     BODY cHtml;
     RESULT lResult

If ! lResult
	//Erro no envio do email
	GET MAIL ERROR cError
	u_Mensagem("Erro no envio de e-mail: "+cError)
EndIf

DISCONNECT SMTP SERVER

Return nil



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg ºAutor  ³Marllon Figueiredo  ºData  ³14/12/2000   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o grupo de perguntas                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ValidPerg(cPerg)
Local aRegs := {}
Local i,j


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros usados na rotina                      ³
//³ mv_par01  Compras Nacionais ou Importadas        ³
//³ mv_par02  Numero do Processo                     ³
//³ mv_par03  do P.O.                                ³
//³ mv_par04  ate o P.O.                             ³
//³ mv_par05  do Pedido de Compras                   ³
//³ mv_par06  ate o Pedido de Compras                ³
//³ mv_par07  do Produto                             ³
//³ mv_par08  ate o Produto                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

//          Grupo/Ordem/Pergunta/                           Variavel/Tipo/Tam/Dec/Pres/GSC/ Valid/       Var01/      Def01________/ Cnt01/Var02/Def02_________/ Cnt02/ Var03/Def03___________/Cnt03/ Var04/Def04_______/Cnt04/ Var05/Def05_______/Cnt05/F3
aAdd(aRegs,{cPerg,"01","das Compras?            ","","",     "mv_ch1","N", 1,  0, 0,  "C", "",          "MV_PAR01", "Nacionais","","",  "",   "",   "Importadas","","",  "",    "",   "","","",        "",    "",   "","","",    "",    "",   "","","",    "",   ""})
aAdd(aRegs,{cPerg,"02","Numero do Processo?     ","","",     "mv_ch2","C",17,  0, 0,  "G", "",          "MV_PAR02", "",     "","", "",   "",   "",      "","", "",    "",   "",        "","","",    "",   "",    "","","",    "",   "",    "","","",  ""})
aAdd(aRegs,{cPerg,"03","Pedido de Compra?       ","","",     "mv_ch3","C",06,  0, 0,  "G", "",          "MV_PAR03", "",     "","", "",   "",   "",      "","", "",    "",   "",        "","","",    "",   "",    "","","",    "",   "",    "","","",  ""})

i:=1            
j:=1
For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

Return




/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³IMD080Leg ³ Autor ³ Marllon Figueiredo    ³ Data ³14/03/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function IMD080Leg()

BrwLegenda(cCadastro,"Legenda",{{"BR_AZUL", "Prazo de Validade esgotado"},;
								{"ENABLE",  "Aguardando Manutenção da Planilha"},;
								{"DISABLE", "Planilha Processada"}} )

Return(.T.)


/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ IA080PO  ³ Autor ³ Luciano Corrêa        ³ Data ³ 21/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Desmembra saldo de itens de POs em novos itens para poderem³±±
±±³          ³ ser alocados em outras planilhas de transferencia.         ³±±
±±³          ³ Deve estar posicionado no item do PC (SC7)                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function IA080PO()

Local aArea		:= GetArea()
// ja está posicionado no item da tabela de SC7...
Local aAreaSC7	:= SC7->( GetArea() )
Private nRecSC7	:= SC7->( RecNo() )

SW3->( dbsetOrder( 8 ) )	// W3_FILIAL+W3_PO_NUM+W3_POSICAO
SW3->( dbSeek( xFilial( 'SW3' ) + PadR( SC7->C7_NUMIMP, 15 ) + SC7->C7_SEQUEN, .f. ) )

While SW3->( !Eof() ) .and. SW3->W3_FILIAL  == xFilial( 'SW3' ) ;
					  .and. SW3->W3_PO_NUM  == PadR( SC7->C7_NUMIMP, 15 ) ;
					  .and. SW3->W3_POSICAO == SC7->C7_SEQUEN
	
	If SW3->W3_SEQ == 0 .and. ;
		SW3->W3_SALDO_Q > 0 .and. ;
		SW3->W3_SALDO_Q <> SW3->W3_QTDE
		
		// produtos sem li...
		// fucao para criar novo item...
		IA080ItPO( 'PO' )
		
	ElseIf SW3->W3_SEQ > 0
		
		// produtos com li..
		SW5->( dbSetOrder( 8 ) )	// W5_FILIAL+W5_PGI_NUM+W5_PO_NUM+W5_POSICAO
		SW5->( dbSeek( xFilial( 'SW5' ) + SW3->W3_PGI_NUM + SW3->W3_PO_NUM + SW3->W3_POSICAO, .f. ) )
		
		While SW5->( !Eof() ) .and. SW5->W5_FILIAL  == xFilial( 'SW5' ) ;
							  .and. SW5->W5_PGI_NUM == SW3->W3_PGI_NUM ;
							  .and. SW5->W5_PO_NUM  == SW3->W3_PO_NUM ;
							  .and. SW5->W5_POSICAO == SW3->W3_POSICAO
			
			If SW5->W5_SEQ == 0 .and. ;
				SW5->W5_SALDO_Q > 0 .and. ;
				SW5->W5_SALDO_Q <> SW5->W5_QTDE
				
				// fucao para criar novo item...
				IA080ItPO( 'LI' )
				
				Exit
			EndIf
			
			SW5->( dbSkip() )
		End
	EndIf
	
	SW3->( dbSkip() )
End

RestArea( aAreaSC7 )
RestArea( aArea )

Return

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ IA080ItPO³ Autor ³ Luciano Corrêa        ³ Data ³ 21/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Desmembra saldo de itens de POs em novos itens para poderem³±±
±±³          ³ ser alocados em outras planilhas de transferencia          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Fonte    ³ PO_Grava( EIC.prw )                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function IA080ItPO( cFase )

Local nSaldo
Local cKeySW3	:= SW3->W3_FILIAL + SW3->W3_PO_NUM + SW3->W3_POSICAO
Local nSeqSW3	:= SW3->W3_SEQ
Local cPosSW3	:= SW3->W3_POSICAO
Local nRecSW3	:= SW3->( RecNo() )
Local nRecSW3_0	:= SW3->( RecNo() )
Local cKeySW1
Local nSeqSW1
Local nPosicao	:= 0
Local nNr_Cont	:= 0
Local cSeq_LI	:= ''
Local nPos
Local nCpoSW1	:= SW1->( fCount() )
Local nCpoSW3	:= SW3->( fCount() )
Local nCpoSW5	:= SW5->( fCount() )
Local nCpoSC1	:= SC1->( fCount() )
Local nCpoSC7	:= SC7->( fCount() )
Local aEspReg	:= {}
Local lPosSW1	:= .f.
Local lPosSW5	:= .f.
Local cItem

	// 1o. retira saldo do item atual...
	
	If cFase == 'LI'
		
		nSaldo := SW5->W5_SALDO_Q
		
		// as sequencias maiores que zero não possuem saldo e a quantidade não é a original e sim
		// a quantidade utilizada na próxima fase, portanto não necessita alteração...
		
		SW5->( RecLock( 'SW5', .f. ) )
		SW5->W5_QTDE	-= nSaldo
		SW5->W5_SALDO_Q	:= 0
		SW5->( MsUnlock() )
		
		// já está posicionado no SW3...
	Else
		nSaldo := SW3->W3_SALDO_Q
	EndIf
	
	SW3->( dbSetOrder( 8 ) )	// W3_FILIAL+W3_PO_NUM+W3_POSICAO
	SW3->( dbSeek( cKeySW3, .f. ) )
	
	While SW3->( !Eof() ) .and. cKeySW3 == SW3->W3_FILIAL + SW3->W3_PO_NUM + SW3->W3_POSICAO
		
		If SW3->W3_SEQ == 0 .or. SW3->W3_SEQ == nSeqSW3
			
			// item do po...
			SW3->( RecLock( 'SW3', .f. ) )
			SW3->W3_QTDE	-= nSaldo
			SW3->W3_SALDO_Q	:= Max( SW3->W3_SALDO_Q - nSaldo, 0 )
			SW3->( MsUnlock() )
			
			If SW3->W3_SEQ == 0
				
				nRecSW3_0 := SW3->( RecNo() )
				
				SW1->( dbSetOrder( 2 ) )	// W1_FILIAL+W1_PO_NUM+W1_POSICAO+W1_CC+W1_SI_NUM
				
				// ao gerar uma nova sequencia do item da si, ela assume a posicao do po...
				SW1->( dbSeek( xFilial( 'SW1' ) + SW3->W3_PO_NUM + SW3->W3_POSICAO, .f. ) )
				
				cKeySW1 := SW1->W1_FILIAL + SW1->W1_CC + SW1->W1_SI_NUM + SW1->W1_COD_I
				
				SW1->( dbSetOrder( 1 ) )	// W1_FILIAL+W1_CC+W1_SI_NUM+W1_COD_I
				SW1->( dbSeek( cKeySW1, .f. ) )
				While SW1->( !Eof() ) .and. cKeySW1 == SW1->W1_FILIAL + SW1->W1_CC + SW1->W1_SI_NUM + SW1->W1_COD_I
					
					// item da si...
					If SW1->W1_SEQ == 0 .or. SW1->W1_SEQ == nSeqSW3
						
						SW1->( RecLock( 'SW1', .f. ) )
						SW1->W1_QTDE -= nSaldo
						SW1->( MsUnlock() )
					EndIf
					
					SW1->( dbSkip() )
				End
				
				SC1->( dbSetOrder( 1 ) )	// C1_FILIAL+C1_NUM+C1_ITEM
				SC1->( dbSeek( '  ' + SC7->C7_NUMSC, .f. ) )		// o c7_itemsc não é gravado corretamente pelo EIC... + SC7->C7_ITEMSC, .f. ) )
				While SC1->( !Eof() ) .and. SC1->C1_FILIAL = '  ' ;
									  .and. SC1->C1_NUM == SC7->C7_NUMSC
					
					If SC1->C1_PRODUTO == SC7->C7_PRODUTO	// existe funcao que nao permite repetir o produto em uma sc...
						
						SC1->( RecLock( 'SC1', .f. ) )
						SC1->C1_QUANT	-= nSaldo
						SC1->C1_QTSEGUM	-= ConvUM( SC1->C1_PRODUTO, SC1->C1_QUANT, 0, 2 )
						SC1->C1_QUJE	-= nSaldo
						SC1->( MsUnlock() )
						Exit
					EndIf
					
					SC1->( dbSkip() )
				End
			Else
				// utiliza a mesma PLI...
				cSeq_LI := SW3->W3_PGI_NUM
			EndIf
		EndIf
		
		SW3->( dbSkip() )
	End

	// 2o. acrescenta nova sc e nova si...
	SC1->( dbSetOrder( 1 ) )	// C1_FILIAL+C1_NUM+C1_ITEM
	SC1->( dbSeek( '  ' + SC7->C7_NUMSC, .f. ) )		// o c7_itemsc não é gravado corretamente pelo EIC... + SC7->C7_ITEMSC, .f. ) )
	While SC1->( !Eof() ) .and. SC1->C1_FILIAL = '  ' ;
						  .and. SC1->C1_NUM == SC7->C7_NUMSC
		
		If SC1->C1_PRODUTO == SC7->C7_PRODUTO	// existe funcao que nao permite repetir o produto em uma sc...
			
			Exit
		EndIf
		
		SC1->( dbSkip() )
	End
	
	aEspReg	:= {}
	nPos := 1
	For nPos := 1 to nCpoSC1
		
		// prepara matriz de campos que serao espelhados
		aAdd( aEspReg, { SC1->( FieldName( nPos ) ), SC1->( FieldGet( nPos ) ) } )
		
	Next nPos
	
	// insere nova sc...
	dbSelectArea( 'SC1' )
	SC1->( RecLock( 'SC1', .t. ) )
	nPos := 1
	For nPos := 1 to nCpoSC1
		
		If aEspReg[ nPos, 1 ] == 'C1_NUM'
			
			If Empty( cNewSC )
				
				cNewSC := GetSXENum( 'SC1' )
				ConfirmSX8()
			EndIf
			
			aEspReg[ nPos, 2 ] := cNewSC
			
		ElseIf aEspReg[ nPos, 1 ] == 'C1_ITEM'
			
			aEspReg[ nPos, 2 ] := StrZero( ++nNewIt, Len( SC1->C1_ITEM ) )
			
		ElseIf aEspReg[ nPos, 1 ] == 'C1_QUANT' .or. aEspReg[ nPos, 1 ] == 'C1_QUJE'
			
			aEspReg[ nPos, 2 ] := nSaldo
			
		ElseIf aEspReg[ nPos, 1 ] == 'C1_QTSEGUM' .or. aEspReg[ nPos, 1 ] == 'C1_QUJE2'
			
			aEspReg[ nPos, 2 ] := ConvUM( SC1->C1_PRODUTO, SC1->C1_QUANT, 0, 2 )
			
		 
		EndIf
		
		Eval( FieldBlock( aEspReg[ nPos, 1 ] ), aEspReg[ nPos, 2 ] )
	Next
	SC1->( MsUnlock() )
	
	SW0->( dbSetOrder( 1 ) )
	
	If Empty( cNewSI ) .or. SW0->( !dbSeek( xFilial( 'SW0' ) + SC1->C1_UNIDREQ + cNewSI, .f. ) )
		
		SY3->( dbSetOrder( 1 ) )
		SY3->( dbSeek( xFilial( 'SY3' ) + SC1->C1_UNIDREQ, .f. ) )
		
		cNewSI := GetSXENum( 'SW0' )
		ConfirmSX8()
		
		SW0->( RecLock( 'SW0', .t. ) )
		SW0->W0_FILIAL	:= xFilial( 'SW0' )
		SW0->W0__CC		:= SC1->C1_UNIDREQ
		SW0->W0_SOLIC	:= SC1->C1_SOLICIT
		SW0->W0__NUM	:= cNewSI
		SW0->W0__DT		:= SC1->C1_EMISSAO
		SW0->W0__POLE	:= SY3->Y3_LE
		SW0->W0_COMPRA	:= SC1->C1_CODCOMP
		SW0->W0_C1_NUM	:= SC1->C1_NUM
		SW0->( MsUnlock() )
	Else
		
	EndIf
	
	SW1->( RecLock( 'SW1', .t. ) )
	SW1->W1_FILIAL	:= xFilial( 'SW1' )
	SW1->W1_COD_I	:= SC1->C1_PRODUTO
	SW1->W1_FABR	:= SC1->C1_FABR
	SW1->W1_FORN	:= SC1->C1_FORNECE
	SW1->W1_CLASS	:= SC1->C1_CLASS
	SW1->W1_QTDE	:= SC1->C1_QUANT
	SW1->W1_SALDO_Q	:= SC1->C1_QUANT
	SW1->W1_DTENTR_	:= SC1->C1_DATPRF
	SW1->W1_CC		:= SW0->W0__CC
	SW1->W1_SI_NUM	:= SW0->W0__NUM
	SW1->W1_POSICAO	:= SC1->C1_ITEM
	SW1->W1_REG		:= 1
	SW1->W1_QTSEGUM	:= SC1->C1_QTSEGUM
	SW1->W1_SEGUM	:= SC1->C1_SEGUM
	SW1->( MsUnlock() )
	
	SC1->( RecLock( 'SC1', .f. ) )
	SC1->C1_NUM_SI	:= SW1->W1_SI_NUM
	SC1->C1_COTACAO	:= 'IMPORX'
	SC1->( MsUnlock() )
	
	// 3o. acrescenta novo item... utilizada funcao PO_Grava() como referencia...
	
	cKeySW3 := Left( cKeySW3, Len( SW3->W3_FILIAL ) + Len( SW3->W3_PO_NUM ) )
	
	SW3->( dbSetOrder( 8 ) )	// W3_FILIAL+W3_PO_NUM+W3_POSICAO
	SW3->( dbSeek( cKeySW3, .f. ) )
	
	While SW3->( !Eof() ) .and. cKeySW3 == SW3->W3_FILIAL + SW3->W3_PO_NUM
		
		// definir nova posicao e sequencia do novo item...
		If SW3->W3_POSICAO > StrZero( nPosicao, Len( SW3->W3_POSICAO ) )
			
			nPosicao := Val( SW3->W3_POSICAO )
		EndIf
		
		If SW3->W3_NR_CONT > nNr_Cont
			
			nNr_Cont := SW3->W3_NR_CONT
		EndIf
		
		SW3->( dbSkip() )
	End
	
	
	SW3->( dbGoTo( nRecSW3_0 ) )
	
	aEspReg	:= {}
	nPos := 1 
	For nPos := 1 to nCpoSW3
		
		// prepara matriz de campos que serao espelhados
		aAdd( aEspReg, { SW3->( FieldName( nPos ) ), SW3->( FieldGet( nPos ) ) } )
		
	Next nPos
	
	// insere novo item no po...
	dbSelectArea( 'SW3' )
	SW3->( RecLock( 'SW3', .t. ) )
	nPos := 1 
	For nPos := 1 to nCpoSW3
		
		If aEspReg[ nPos, 1 ] == 'W3_SI_NUM'
			
			aEspReg[ nPos, 2 ] := SW1->W1_SI_NUM
			
		ElseIf aEspReg[ nPos, 1 ] == 'W3_QTDE' .or. aEspReg[ nPos, 1 ] == 'W3_SALDO_Q'
			
			aEspReg[ nPos, 2 ] := nSaldo
			
		ElseIf aEspReg[ nPos, 1 ] == 'W3_POSICAO'
			
			aEspReg[ nPos, 2 ] := StrZero( nPosicao + 1, Len( SW3->W3_POSICAO ) )
			
		ElseIf aEspReg[ nPos, 1 ] == 'W3_SEQ'
			
			aEspReg[ nPos, 2 ] := 0
			
		ElseIf aEspReg[ nPos, 1 ] == 'W3_NR_CONT'
			
			aEspReg[ nPos, 2 ] := nNr_Cont + 1
		EndIf
		
		Eval( FieldBlock( aEspReg[ nPos, 1 ] ), aEspReg[ nPos, 2 ] )
	Next
	SW3->( MsUnlock() )

	nSeqSW1 := 0
	
	SW1->( dbSetOrder( 1 ) )
	
	SW1->( dbSeek( xFilial( 'SW1' ) + SW3->W3_CC + SW3->W3_SI_NUM + SW3->W3_COD_I, .f. ) )
	
	While SW1->( !Eof() ) .and. SW1->W1_FILIAL  == xFilial( 'SW1' ) ;
						  .and. SW1->W1_CC      == SW3->W3_CC ;
						  .and. SW1->W1_SI_NUM  == SW3->W3_SI_NUM ;
						  .and. SW1->W1_COD_I   == SW3->W3_COD_I
		
		If SW1->W1_REG == SW3->W3_REG .and. SW1->W1_SEQ > nSeqSW1
			
			nSeqSW1	:= SW1->W1_SEQ
		EndIf
		
		SW1->( dbSkip() )
	End
	
	
	lPosSW1	:= .f.
	
	SW1->( dbSeek( xFilial( 'SW1' ) + SW3->W3_CC + SW3->W3_SI_NUM + SW3->W3_COD_I, .f. ) )
	
	While SW1->( !Eof() ) .and. SW1->W1_FILIAL  == xFilial( 'SW1' ) ;
						  .and. SW1->W1_CC      == SW3->W3_CC ;
						  .and. SW1->W1_SI_NUM  == SW3->W3_SI_NUM ;
						  .and. SW1->W1_COD_I   == SW3->W3_COD_I
		
		If SW1->W1_REG == SW3->W3_REG .and. SW1->W1_SEQ == 0
			
			lPosSW1	:= .t.
			Exit
		EndIf
		
		SW1->( dbSkip() )
	End
	
	If lPosSW1
		
		SW1->( RecLock( 'SW1', .f. ) )
		SW1->W1_SALDO_Q -= SW3->W3_QTDE
		SW1->( MsUnlock() )
	EndIf

	aEspReg	:= {}
	nPos := 1 
	For nPos := 1 to nCpoSW1
		
		// prepara matriz de campos que serao espelhados
		aAdd( aEspReg, { SW1->( FieldName( nPos ) ), SW1->( FieldGet( nPos ) ) } )
		
	Next nPos
	
	// insere nova sequencia no item da si...
	dbSelectArea( 'SW1' )
	SW1->( RecLock( 'SW1', .t. ) )
	nPos := 1 
	For nPos := 1 to nCpoSW1
		
		If aEspReg[ nPos, 1 ] == 'W1_QTDE'
			
			aEspReg[ nPos, 2 ] := SW3->W3_QTDE
			
		ElseIf aEspReg[ nPos, 1 ] == 'W1_SALDO_Q'
			
			aEspReg[ nPos, 2 ] := 0
			
		ElseIf aEspReg[ nPos, 1 ] == 'W1_PO_NUM'
			
			aEspReg[ nPos, 2 ] := SW3->W3_PO_NUM
			
		ElseIf aEspReg[ nPos, 1 ] == 'W1_POSICAO'
			
			aEspReg[ nPos, 2 ] := SW3->W3_POSICAO
			
		ElseIf aEspReg[ nPos, 1 ] == 'W1_SEQ'
			
			aEspReg[ nPos, 2 ] := nSeqSW1 + 1
			
		ElseIf aEspReg[ nPos, 1 ] == 'W1_FLUXO'
			
			aEspReg[ nPos, 2 ] := SW3->W3_FLUXO
			
		ElseIf aEspReg[ nPos, 1 ] == 'W1_FABR'
			
			aEspReg[ nPos, 2 ] := SW3->W3_FABR
			
		ElseIf aEspReg[ nPos, 1 ] == 'W1_FORN'
			
			aEspReg[ nPos, 2 ] := SW3->W3_FORN
		EndIf
		
		Eval( FieldBlock( aEspReg[ nPos, 1 ] ), aEspReg[ nPos, 2 ] )
	Next	
	SW1->( MsUnlock() )
	
	If SW3->W3_FLUXO == '7'
				
		lPosSW5	:= .f.
		
		SW5->( dbSetOrder( 8 ) )
		SW5->( dbSeek( xFilial( 'SW5' ) + cSeq_LI + SW3->W3_PO_NUM + cPosSW3, .f. ) )
		
		While SW5->( !Eof() ) .and. SW5->W5_FILIAL  == xFilial( 'SW5' ) ;
							  .and. SW5->W5_PGI_NUM == cSeq_LI ;
							  .and. SW5->W5_PO_NUM  == SW3->W3_PO_NUM ;
							  .and. SW5->W5_POSICAO == cPosSW3
			
			If Empty( SW5->W5_HAWB )
				
				lPosSW5	:= .t.
				Exit
			EndIf
			
			SW5->( dbSkip() )
		End
		
		If lPosSW5
			
			aEspReg	:= {}
			nPos := 1 
			For nPos := 1 to nCpoSW5
				
				// prepara matriz de campos que serao espelhados
				aAdd( aEspReg, { SW5->( FieldName( nPos ) ), SW5->( FieldGet( nPos ) ) } )
				
			Next nPos
			
			// insere novo item no po...
			dbSelectArea( 'SW5' )
			SW5->( RecLock( 'SW5', .t. ) )
			nPos := 1 
			For nPos := 1 to nCpoSW5
				
				If aEspReg[ nPos, 1 ] == 'W5_SI_NUM'
					
					aEspReg[ nPos, 2 ] := SW3->W3_SI_NUM
					
				ElseIf aEspReg[ nPos, 1 ] == 'W5_QTDE' .or. aEspReg[ nPos, 1 ] == 'W5_SALDO_Q'
					
					aEspReg[ nPos, 2 ] := SW3->W3_QTDE
					
				ElseIf aEspReg[ nPos, 1 ] == 'W5_POSICAO'
					
					aEspReg[ nPos, 2 ] := SW3->W3_POSICAO
					
				ElseIf aEspReg[ nPos, 1 ] == 'W5_SEQ'
					
					aEspReg[ nPos, 2 ] := 0
				EndIf
				
				Eval( FieldBlock( aEspReg[ nPos, 1 ] ), aEspReg[ nPos, 2 ] )
			Next
			SW5->( MsUnlock() )
			
			SW3->( RecLock( 'SW3', .f. ) )
			SW3->W3_SALDO_Q	:= 0
			SW3->( MsUnlock() )
		
			// utilizada funcao Po420GrvIP(.t.) como referencia...
			aEspReg	:= {}
			nPos := 1 
			For nPos := 1 to nCpoSW3
				
				// prepara matriz de campos que serao espelhados
				aAdd( aEspReg, { SW3->( FieldName( nPos ) ), SW3->( FieldGet( nPos ) ) } )
				
			Next nPos
			
			// insere novo item no po...
			dbSelectArea( 'SW3' )
			SW3->( RecLock( 'SW3', .t. ) )
			nPos := 1 
			For nPos := 1 to nCpoSW3
				
				If aEspReg[ nPos, 1 ] == 'W3_PGI_NUM'
					
					aEspReg[ nPos, 2 ] := SW5->W5_PGI_NUM
					
				ElseIf aEspReg[ nPos, 1 ] == 'W3_SEQ'
					
					aEspReg[ nPos, 2 ] := 1
					
				ElseIf aEspReg[ nPos, 1 ] == 'W3_NR_CONT'
					
					aEspReg[ nPos, 2 ] := 0
					
				ElseIf aEspReg[ nPos, 1 ] == 'W3_TEC' .or. aEspReg[ nPos, 1 ] == 'W3_EX_NCM' .or. aEspReg[ nPos, 1 ] == 'W3_EX_NBM'
					
					aEspReg[ nPos, 2 ] := ''
				EndIf
				
				Eval( FieldBlock( aEspReg[ nPos, 1 ] ), aEspReg[ nPos, 2 ] )
			Next
			SW3->( MsUnlock() )
		EndIf
	EndIf
	
	// prepara dados para criar novo item no pc...
	
	SC7->( dbSetOrder( 1 ) )	// C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
	
	SC7->( dbGoTo( nRecSC7 ) )
	
	SC7->( dbSeek( xFilial( 'SC7' ) + Soma1( SC7->C7_NUM, Len( SC7->C7_NUM ) ), .t. ) )
	
	SC7->( dbSkip( -1 ) )
	
	cItem := Soma1( SC7->C7_ITEM, Len( SC7->C7_ITEM ) )
	
	
	SC7->( dbGoTo( nRecSC7 ) )
	
	aEspReg	:= {}
	nPos := 1 
	For nPos := 1 to nCpoSC7
		
		// prepara matriz de campos que serao espelhados
		aAdd( aEspReg, { SC7->( FieldName( nPos ) ), SC7->( FieldGet( nPos ) ) } )
		
	Next nPos
	
	// abate saldo do item atual...
	SC7->( RecLock( 'SC7', .f. ) )
	SC7->C7_QUANT	-= SW3->W3_QTDE
	SC7->C7_QTSEGUM	:= ConvUM( SC7->C7_PRODUTO, SC7->C7_QUANT, 0, 2 )
	SC7->C7_TOTAL	:= NoRound( SC7->C7_PRECO * SC7->C7_QUANT, TamSX3( 'C7_TOTAL' )[ 2 ] )
	SC7->( MsUnlock() )
	
	// insere novo item no pc...
	dbSelectArea( 'SC7' )
	SC7->( RecLock( 'SC7', .t. ) )
	nPos := 1 
	For nPos := 1 to nCpoSC7
		
		If aEspReg[ nPos, 1 ] == 'C7_ITEM'
			
			aEspReg[ nPos, 2 ] := cItem
			
		ElseIf aEspReg[ nPos, 1 ] == 'C7_NUMSC'
			
			aEspReg[ nPos, 2 ] := SC1->C1_NUM
			
		ElseIf aEspReg[ nPos, 1 ] == 'C7_ITEMSC'
			
			aEspReg[ nPos, 2 ] := SC1->C1_ITEM
			
		ElseIf aEspReg[ nPos, 1 ] == 'C7_SEQUEN'
			
			aEspReg[ nPos, 2 ] := SW3->W3_POSICAO
			
		ElseIf aEspReg[ nPos, 1 ] == 'C7_PLANILH' .or. aEspReg[ nPos, 1 ] == 'C7_PLITEM' .or. aEspReg[ nPos, 1 ] == 'C7_FLAGPT'
			
			aEspReg[ nPos, 2 ] := ''
		EndIf
		
		Eval( FieldBlock( aEspReg[ nPos, 1 ] ), aEspReg[ nPos, 2 ] )
	Next
	SC7->C7_QUANT	:= SW3->W3_QTDE
	SC7->C7_QTSEGUM	:= ConvUM( SC7->C7_PRODUTO, SC7->C7_QUANT, 0, 2 )
	SC7->C7_TOTAL	:= NoRound( SC7->C7_PRECO * SC7->C7_QUANT, TamSX3( 'C7_TOTAL' )[ 2 ] )
	SC7->C7_QUJE	:= 0
	SC7->( MsUnlock() )


Return
