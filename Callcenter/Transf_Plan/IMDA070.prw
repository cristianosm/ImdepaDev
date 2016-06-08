#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
//Array
#DEFINE DEF_FLAG       	1
#DEFINE DEF_FILIAL     	2
#DEFINE DEF_SALDO      	3
#DEFINE DEF_QATU       	4
#DEFINE DEF_DISP       	5
#DEFINE DEF_CONMED     	6
#DEFINE DEF_CUSTOM     	7
#DEFINE DEF_QTDSOL     	8
#DEFINE DEF_QTDRES     	9
#DEFINE DEF_LOCALEST  	10
#DEFINE X_ZE_QTDORIG	07
#DEFINE X_ZE_LOCAL		11
#DEFINE DEF_FILDEST		15

#DEFINE CLR_BLUE      	8388608

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ IMDA070  ºAutor  ³Marllon Figueiredo  º Data ³ 07/03/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotima para processar solicitacoes de compra e verificar seº±±
±±º          ³ existe estoque disponivel em alguma filial e solicitar     º±±
±±º          ³ a transferencia dos itens mediante geracao de PVs na filialº±±
±±º          ³ que tem o estoque disponivel e pedido de compras automati- º±±
±±º          ³ co na filial de destino                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUltimas Alteracoes                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAutor     ³ Data     Ø  Descricao                                      º±±
±±ºEdivaldo  ³18/02/07  Ø Implementacao da Geracao pedidos no Estoque98   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
**********************************************************************
User Function IMDA070()
**********************************************************************

	Local aArea			:= GetArea()
	Local nCntFor		:= 0
	Local aGrupo		:= {}
	Local cGrupComp 	:= ""
	Local cFiltroSC1	:= ""
	Local cQuerySC1		:= ""
	Local cQueryGrp		:= ""
	Local cAuxFil   	:= ""
	Local lFiltra		:= .F.
	Local aIndexSC1	    := {}
	Private cPerg         := 'IMD070'

	Private cMarca      := GetMark()
	PRIVATE bFiltraBrw  := {|| {"","",""}}
	PRIVATE cCadastro   := OemToAnsi("Solicita‡oes")

	PRIVATE aRotina := {	{ "Pesquisar",  "PesqBrw"      ,0 ,1 },;
		{ "Visualiza",  "A110Visual"   ,0 ,2 },;
		{ "Processar",  "U_IMD070Gera" ,0 ,4 } }

	ValidPerg(cPerg)

	If Pergunte(cPerg,.T.)

		lFiltra := ( MV_PAR01==1 .Or. !Empty(cFiltroSC1) .Or. !Empty(cGrupComp) )

		DbSelectArea("SC1");DbSetOrder(1)

		If ( lFiltra )
			cFiltroSC1+= ".And. C1_FILIAL == '"+xFilial("SC1")+"'"
			cFiltroSC1+= ".And. Dtos(C1_EMISSAO) >= '"+Dtos(MV_PAR02)+"'"
			cFiltroSC1+= ".And. Dtos(C1_EMISSAO) <= '"+Dtos(MV_PAR03)+"'"
			cFiltroSC1+= ".And. C1_FORNECE >= '"+MV_PAR04+"'"
			cFiltroSC1+= ".And. C1_FORNECE <= '"+MV_PAR05+"'"
			cFiltroSC1+= ".And. C1_NUM >= '"+MV_PAR06+"'"
			cFiltroSC1+= ".And. C1_NUM <= '"+MV_PAR07+"'"
			cQuerySC1 += " AND C1_FILIAL = '"+xFilial("SC1")+"'"
			cQuerySC1 += " AND C1_EMISSAO >= '"+Dtos(MV_PAR02)+"'"
			cQuerySC1 += " AND C1_EMISSAO <= '"+Dtos(MV_PAR03)+"'"
			cQuerySC1 += " AND C1_FORNECE >= '"+MV_PAR04+"'"
			cQuerySC1 += " AND C1_FORNECE <= '"+MV_PAR05+"'"
			cQuerySC1 += " AND C1_NUM >= '"+MV_PAR06+"'"
			cQuerySC1 += " AND C1_NUM <= '"+MV_PAR07+"'"

		EndIf

	//|Filtra somente as solicitacoes pendentes
		cFiltroSC1+= ".And. (C1_COTACAO=='"+Space(Len(SC1->C1_COTACAO))+"' .OR. C1_COTACAO=='IMPORT') .And. C1_QUJE<C1_QUANT.And.C1_TPOP<>'P'"
		cQuerySC1 += " AND  (C1_COTACAO= '"+Space(Len(SC1->C1_COTACAO))+"'  OR  C1_COTACAO= 'IMPORT')  AND  C1_QUJE<C1_QUANT AND C1_TPOP<>'P'"

		cFiltroSC1 += cGrupComp
		cQuerySC1  += cQueryGrp

		cFiltroSc1 := SubStr(cFiltroSC1,6)
		cQuerySC1  := SubStr(cQuerySC1,6)

		bFiltraBrw := {|x| Iif(x==Nil,FilBrowse("SC1",@aIndexSC1,@cFiltroSC1),{cFiltroSC1,cQuerySC1,cAuxFil}) }

		Eval(bFiltraBrw)

		dbSelectArea("SC1");dbGotop()
		DbSeek(xFilial())

		If !SC1->(Eof())
		//³ Endereca a funcao de MarkBrowse                              ³
			MarkBrow("SC1", "C1_OK", "(C1_NUMPLAN+C1_PEDIDO+Iif(C1_TPOP=='P','X',' '))",,, cMarca)
		Else
			HELP(" ",1,"RECNO")
			lContinua := .F.
		EndIf


	//³Restaura as condicoes de Entrada                                        ³
	EndFilBrw("SC1",aIndexSC1)

	dbSelectArea("SC8")
	dbClearFilter()
	RetIndex("SC8")

Endif

RestArea(aArea)

Return
**********************************************************************
User Function Imd070Gera()
**********************************************************************

	Local aArea      := GetArea()
	Local aAreaSB2   := SB2->( GetArea() )
	Local nSldDisp   := 0
	Local aItems     := Array(0)
	Local lSel       := .F.
	Local cCodTrf    := GetMV('MV_IMDEPA')
	Local aItemPC    := Array(0)
	Local aItemPV    := Array(0)
	Local __aQtdFil  := Array(0)
	Local nTrf       := 0
	Local aSZE       := Array(0)
	Local nSZE
	Local nSldPos
	Local aSaldos    := Array(0)

	Public cFilOri 	 := ""
	Public cFilDest	 := ""
	Public __cFil

//Edivaldo Gonçalves Cordeiro - Carrega as perguntas para corrigir errorLog no retorno da função DTOS() abaixo
	Pergunte(cPerg,.F.)


///JULIO JACOVENKO em 06/04/2013, ajustando para não ler todo o SC1
///////////////////////////////////////////////////////////////////

	cQuery = " SELECT * FROM SC1010 WHERE C1_FILIAL = '"+xFilial("SC1")+"'"
	cQuery += " AND C1_EMISSAO >= '"+Dtos(MV_PAR02)+"'"
	cQuery += " AND C1_EMISSAO <= '"+Dtos(MV_PAR03)+"'"
	cQuery += " AND C1_FORNECE >= '"+MV_PAR04+"'"
	cQuery += " AND C1_FORNECE <= '"+MV_PAR05+"'"
	cQuery += " AND C1_NUM >= '"+MV_PAR06+"'"
	cQuery += " AND C1_NUM <= '"+MV_PAR07+"'"


	TCQUERY cQuery NEW ALIAS "QSC1"

	TCSetField( 'QSC1', 'C1_DATPRF', 'D', 8, 0 )


	DBSELECTAREA('QSC1')
	dbGoTop()
//dbSeek(xFilial('SC1'))
	While !Eof()
	// testa se foi marcado
	//CMARCA:=QSC1->C1_OK
		If Marked('C1_OK')
		// tem pelo menos um marcado
			lSel := .T.

		// Recupera o saldo das filiais e retorna qual filial efetuara a transferencia
			__aQtdFil := RetFilTrf(QSC1->C1_PRODUTO, aSaldos,QSC1->C1_NUM,QSC1->C1_QUANT,QSC1->C1_ITEM,QSC1->C1_MSFIL,QSC1->C1_DESCRI)


		// Conteudo do __aQtdFil
		// 2 - Filial
		// 3 - Quantidade
		// 4 - Saldo Atual
		// 5 - Saldo Disponivel
		// 6 - Media de Consumo
		// 7 - Custo
		// 8 - Solicitado
		// 9 - Reservado para transferir
		//10 - Armazem do Produto
			If Len(__aQtdFil) > 0
			// procuro saldo nas filiais
				For nTrf := 1 To Len(__aQtdFil)
					If __aQtdFil[nTrf, DEF_FLAG ]
						lGeraSZE := .T.
					// atualizacao do array de geracao de planilhas
						nPos := aScan(aSZE, {|x| x[1] = __aQtdFil[nTrf, DEF_FILIAL ]})
						If nPos <= 0

							Aadd(aSZE, {__aQtdFil[nTrf, DEF_FILIAL ], {{.T.,;       						//01
							QSC1->C1_NUM,;						//02
							QSC1->C1_ITEM,;                     	//03
							QSC1->C1_PRODUTO,;                  	//04
							__aQtdFil[nTrf, DEF_QTDRES ],;		//05
							QSC1->C1_MSFIL,;						//06
							__aQtdFil[nTrf, DEF_QTDSOL ],;		//07
							' ',;								//08
							QSC1->C1_DATPRF,;                   	//09
							0,;                                	//10
							__aQtdFil[nTrf,DEF_LOCALEST ],;		//11
							' ',;  								//12
							' ',;								//13
							' ',;								//14
							alltrim(QSC1->C1_UNIDREQ);			//15
							}}})
						Else
							Aadd(aSZE[nPos,2], {.T.,;			//01
							QSC1->C1_NUM,;						//02
							QSC1->C1_ITEM,;                   	//03
							QSC1->C1_PRODUTO,;                  	//04
							__aQtdFil[nTrf, DEF_QTDRES ],;		//05
							QSC1->C1_MSFIL,;                  	//06
							__aQtdFil[nTrf, DEF_QTDSOL ],;     	//07
							' ',;                            	//08
							QSC1->C1_DATPRF,;                 	//09
							0,;                             	//10
							__aQtdFil[nTrf,DEF_LOCALEST ],;		//11
							' ',;  								//12
							' ',;								//13
							' ',;								//14
							alltrim(QSC1->C1_UNIDREQ);			//15
							})

						EndIf

					// incluo o saldo ja reservado neste processo
						nSldPos := aScan(aSaldos, {|x| x[1] == __aQtdFil[nTrf, DEF_FILIAL ]+QSC1->C1_PRODUTO})
						If nSldPos <= 0
							Aadd(aSaldos, {__aQtdFil[nTrf, DEF_FILIAL ]+QSC1->C1_PRODUTO, __aQtdFil[nTrf, DEF_QTDRES ]})
						Else
							aSaldos[nSldPos,2] += __aQtdFil[nTrf, DEF_QTDRES ]
						EndIf
					EndIf
				Next
			EndIf

		// desmarco o indicador do SC1

		///JULIO JACOVENKO, em 06/04/2013
		///ajustado para a versao P11
		///
			DBSELECTAREA('SC1')
			DBSETORDER(1)
			IF DBSEEK(XFILIAL('SC1')+QSC1->C1_NUM+QSC1->C1_ITEM)
				RecLock('SC1',.F.)
				SC1->C1_OK := ''
				msUnLock()
			ENDIF

			DBSELECTAREA('QSC1')
		EndIf

		dbSelectArea('QSC1')
		dbSkip()
	EndDo
	DBCLOSEAREA('QSC1')

	__cFil  := cFilAnt

	If Len(aSZE) > 0

	// quantidade de planilhas a serem geradas depende das filiais de transferencia utilizadas
	// para gerar a transferencia. Serah gerada uma planilha para cada filial utilizada
		For nSZE := 1 To Len(aSZE)
			dbSelectArea('SC1')
		// filial que tem o saldo disponivel
			cFilAnt 	:= aSZE[nSZE,01]
			cFilDest 	:= aSZE[1,2,nSZE,15]


		// calcula o excedente
			aSZE[nSZE,2] := U_CalcExced( aSZE[nSZE,2] )

		// gera planilhas de transferencia na filial que tem o saldo
			U_IMD080Plan( .F., ' ', aSZE[nSZE,2] )



		// alterado por Luciano Correa em 21/07/04 - atualizar b2_salpedi...
			SB2->( dbSetOrder( 1 ) )

		// marco as solicitacoes de compra
			DbSelectArea('SC1')
			For nItSze := 1 To Len(aSZE[nSZE,2])
				If DbSeek(xFILIAL("SC1")+aSZE[nSZE,2,nItSze,2]+aSZE[nSZE,2,nItSze,3])

					DbSelectarea("SB2")
					If DbSeek( SC1->C1_MSFIL + SC1->C1_PRODUTO + aSZE[nSZE,2,nItSze,X_ZE_LOCAL], .f. )
					// Abate da quantidade prevista a diferenca da quantidade ja entregue...
						RecLock( 'SB2', .f. )
						SB2->B2_SALPEDI -= ( Min( SC1->C1_QUANT, SC1->C1_QUJE + aSZE[nSZE,2,nItSze,X_ZE_QTDORIG] ) - SC1->C1_QUJE )
						MsUnlock()
					EndIf

					DbSelectArea("SC1")
					RecLock('SC1',.F.)// nao pode ser maior que a quantidade solicitada
					If SC1->C1_QUJE + aSZE[nSZE,2,nItSze,X_ZE_QTDORIG] > SC1->C1_QUANT
						SC1->C1_QUJE := SC1->C1_QUANT
					Else
						SC1->C1_QUJE := SC1->C1_QUJE + aSZE[nSZE,2,nItSze,X_ZE_QTDORIG]
					EndIf
					SC1->C1_COTACAO  := "XXXXXX"
					SC1->C1_NUMPLAN  := SZE->ZE_NUMPLAN
					MsUnLock()

				EndIf
			Next
/*
		If !Empty(SC1->C1_FORNECE)
			cFilDest := SZE->ZE_DESTINO
		Endif
*/
			cFilOri	 := aSZE[nSZE,1]
			cFilDest := aSZE[1,2,nSZE,15]
		//Processa a planilha gerada
			U_IMD090Proc( .F. )
		Next

	EndIf

	cFilAnt := __cFil
	RestArea(aAreaSB2)
	RestArea(aArea)

Return()
 //Edivaldo Gonçalves Cordeiro - Informaçoes do SC1 passado via parâmetro
//RetFilTrf(QSC1->C1_PRODUTO, aSaldos,QSC1->C1_NUM,QSC1->C1_QUANT,QSC1->C1_ITEM,QSC1->C1_MSFIL,QSC1->C1_DESCRI)
*****************************************************************************************
Static Function RetFilTrf(cProduto, aSaldos,_NumSC1,_QtdSC1,_cItemSC1,_c1Msfil,_c1Descri)
*****************************************************************************************

	Local oDlg
	Local aRet       := Array(0)
	Local cDesc      :=  _c1Descri //SC1->C1_DESCRI
	Local cDestFil   := _c1Msfil //SC1->C1_MSFIL
	Local cNomFil    := u_RetNameFil(cEmpAnt, _c1Msfil)
	Local nQtd       :=  _QtdSC1 //SC1->C1_QUANT
//Local cNumSol    := _NumSC1+'-'+_cItemSC1 // _cItem  //_cItemSC1->C1_NUM+'-'+SC1->C1_ITEM
	Local lOk        := .F.
	Local nSldPos    := 0
	Local nAbate     := 0
	Private cLocEst  :=' '
	Private cNumSol  := _NumSC1+'/'+_cItemSC1 // _cItem  //_cItemSC1->C1_NUM+'-'+SC1->C1_ITEM
	Private nQtdNaSC := _QtdSC1  //Variável para validar se o operador está tentando transferir um saldo superior ao definido na SC

	Private aList    := Array(0)
	Private aList98  := Array(0)

	Private oOk      := Loadbitmap(GetResources(), 'LBOK')
	Private oNo      := Loadbitmap(GetResources(), 'LBNO')

	Private oList
	Private oList98
	Private lConTrf := .F.
// alterado por Luciano Corrêa em 18/10/04...
	Private nMes, nAno
	Private nPos
	Private aMeses   := {}
	Private aListAux := {}
	Private aLinAux  := {}
	Private nSldDisp


	nMes := Month( dDataBase )
	nAno := Year ( dDataBase ) - 1

	For nPos := 1 to 12

		nMes ++
		If nMes > 12
			nMes := 1
			nAno ++
		EndIf

		aAdd( aMeses, { nMes, nAno } )

	Next nPos
// fim alteracao Luciano...

// monta uma Dialog com um Browse do SC7 para selecao
	DEFINE MSDIALOG oDlg TITLE 'Transferência por Solicitação' FROM 0,0 TO 20,95 OF oMainWnd

//Inserido por Edivaldo Goncalves Cordeiro em 18/02/07 (Criacao de Folders na Geracao do pedido de Compras por TRF)
	oFolder := TFolder():New(1,1,{"Armazem 01","Armazem 98 (Exclusivo Importação)" },{"oFl1","oFl2",},oDlg,,,,.T.,.F.,373,150)

	@ 01+3,05  SAY 'Produto'      PIXEL SIZE 35,08  of oFolder:aDialogs[1] PIXEL
	@ 01+3,40  MSGET cProduto     PIXEL SIZE 35,07  of oFolder:aDialogs[1] PIXEL WHEN .F.
	@ 01+3,80  MSGET cDesc        PIXEL SIZE 150,07 of oFolder:aDialogs[1] PIXEL WHEN .F.
	@ 01+3,245 SAY 'Solicitação'  PIXEL SIZE 40,08  of oFolder:aDialogs[1] PIXEL
	@ 12+4,05  SAY 'Destino'      PIXEL SIZE 32,08  of oFolder:aDialogs[1] PIXEL
	@ 12+4,40  MSGET cDestFil     PIXEL SIZE 20,07  of oFolder:aDialogs[1] PIXEL WHEN .F.
	@ 12+4,60  MSGET cNomFil      PIXEL SIZE 60,07  of oFolder:aDialogs[1] PIXEL WHEN .F.
	@ 12+4,130 SAY 'Necessidade'  PIXEL SIZE 45,08  of oFolder:aDialogs[1] PIXEL
	@ 12+4,170 MSGET nQtd         PIXEL SIZE 35,07  of oFolder:aDialogs[1] PIXEL WHEN .F. PICTURE '@E 9999999.99'
	@ 12+4,245 MSGET cNumSol      PIXEL SIZE 50,07  of oFolder:aDialogs[1] PIXEL WHEN .F.

	DEFINE SBUTTON oBut FROM 115+18,240+55 TYPE 01 ENABLE OF oDlg PIXEL ACTION(lOk:=.T., oDlg:End())
	DEFINE SBUTTON oBut FROM 115+18,280+55 TYPE 02 ENABLE OF oDlg PIXEL ACTION(lOk:=.T., aList:=Array(0), oDlg:End())

	@ 32,02  LISTBOX oList ;
		FIELDS HEADERS ' ','Fil Forn','Disponivel Transf', 'Saldo Atual', 'Saldo Disponivel', 'Consumo Medio', 'Dias Consumo';
		SIZE 360,085 ;
		PIXEL of oFolder:aDialogs[1] PIXEL ;
		ON dblClick(lConTrf := FValida(cDestFil,cNomFil,.F.,oList:nAt), aList:=SDTroca(oList:nAt,aList,nQtd),oList:Refresh())

	For nPos := 1 to 12

	// preenche cabecalho com ultimos 12 meses...
		aAdd( oList:aHeaders, Left( MesExtenso( aMeses[ nPos, 1 ] ), 3 ) + '/' + StrZero( aMeses[ nPos, 2 ], 4 ) )

	Next nPos


	SB3->( dbSetOrder( 1 ) )

// alterado por Luciano Corrêa em 27/08/04 para considerar somente armazem 01 (solicitado por Fernando Mancuzo)...
// avalia o SB2
	dbSelectArea('SB2')
	dbOrderNickName('B2_COD')
	dbSeek(cProduto + '01')

// carrega as posicoes para o vetor listbox
	aList := Array(0)
	Do While !Eof() .and. cProduto == SB2->B2_COD .and. SB2->B2_LOCAL == '01'
	// atualiza o vetor de selecao
	// nao existe transferencia da filial para ela propria
		If cDestFil == SB2->B2_FILIAL
			dbSkip()
			Loop
		EndIf

	// nao mostro armazem dos pedidos da Importacao (98)
		If SB2->B2_LOCAL = '98'
			dbSkip()
			Loop
		EndIf

	// recupero a quantidade ja reservada neste processo para calcular o novo saldo disponivel p/ transferencia
		nSldPos := aScan(aSaldos, {|x| x[1] == SB2->B2_FILIAL+cProduto})
		If nSldPos > 0
			nAbate := aSaldos[nSldPos,2]
		Else
			nAbate := 0
		EndIf

	// alterado por Luciano Corrêa em 27/08/04 para constar saldos atual e disponivel e consumo medio...
		nSldDisp := SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QACLASS - SB2->B2_QPEDVEN + u_QtdPedTra( SB2->B2_COD, SB2->B2_FILIAL )

		SB3->( dbSeek( SB2->B2_FILIAL + SB2->B2_COD, .f. ) )

		Aadd(aList,{.F.,;
			SB2->B2_FILIAL,;
			Max(Min((SB2->B2_QTRANS - nAbate),(SB2->B2_QATU-SB2->B2_RESERVA- SB2->B2_QACLASS - SB2->B2_QPEDVEN - nAbate)),0) ,;
			SB2->B2_QATU,;
			nSldDisp,;
			SB3->B3_MEDIA,;
			SB2->B2_CM1,;
			nQtd,;
			0,;
			'01'})

	// alterado por Luciano Corrêa em 18/10/04 para apresentar o nro de dias de consumo do saldo disponivel e o
	// consumo dos ultimos 12 meses...
		aLinAux := { Int( nSldDisp / ( SB3->B3_MEDIA / 30 ) ) }

		For nPos := 1 to 12

		// verifica se o consumo está atualizado até a database...
			If !Empty( SB3->B3_MES ) .and. ;
					Left( DtoS( SB3->B3_MES ), 6 ) < ( StrZero( aMeses[ nPos, 2 ], 4 ) + StrZero( aMeses[ nPos, 1 ], 2 ) )

				aAdd( aLinAux, 0 )
			Else
				aAdd( aLinAux, &( 'SB3->B3_Q' + StrZero( aMeses[ nPos, 1 ], 2 ) ) )
			EndIf

		Next nPos

		aAdd( aListAux, aLinAux )

		dbSkip()
	EndDo

// testa se encontrou algum registro, pois o array nao pode
// ser passado vazio para a listbox
	If Empty( aList )
		aList := { { .F., '', 0, 0, 0, 0, 0, 0, 0 } }
	EndIf
	If Empty( aListAux )
		aListAux := { { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } }
	EndIf

	oList:SetArray(aList)
	oList:bLine:={|| {If(aList[oList:nAt, DEF_FLAG ],oOk,oNo),;
		aList[oList:nAt, DEF_FILIAL ],;
		aList[oList:nAt, DEF_SALDO ],;
		aList[oList:nAt, DEF_QATU ],;
		aList[oList:nAt, DEF_DISP ],;
		aList[oList:nAt, DEF_CONMED ],;
		aListAux[ oList:nAt, 01 ], ;
		aListAux[ oList:nAt, 02 ], ;
		aListAux[ oList:nAt, 03 ], ;
		aListAux[ oList:nAt, 04 ], ;
		aListAux[ oList:nAt, 05 ], ;
		aListAux[ oList:nAt, 06 ], ;
		aListAux[ oList:nAt, 07 ], ;
		aListAux[ oList:nAt, 08 ], ;
		aListAux[ oList:nAt, 09 ], ;
		aListAux[ oList:nAt, 10 ], ;
		aListAux[ oList:nAt, 11 ], ;
		aListAux[ oList:nAt, 12 ], ;
		aListAux[ oList:nAt, 13 ] } }
	oList:Refresh()

//Inserido por Edivaldo Goncalves Cordeiro em 18/02/07 (Implementacao da Geracao dos Pedidos no Estoque98,Exclusivo Importação)

	@ 04,05  SAY 'Produto'     COLOR CLR_BLUE     PIXEL SIZE 35,08  of oFolder:aDialogs[2] PIXEL
	@ 04,40  MSGET cProduto    COLOR CLR_BLUE     PIXEL SIZE 35,07  of oFolder:aDialogs[2] PIXEL WHEN .F.
	@ 04,80  MSGET cDesc       COLOR CLR_BLUE     PIXEL SIZE 150,07 of oFolder:aDialogs[2] PIXEL WHEN .F.
	@ 04,245 SAY 'Solicitação' COLOR CLR_BLUE     PIXEL SIZE 40,08  of oFolder:aDialogs[2] PIXEL
	@ 16,05  SAY 'Destino'     COLOR CLR_BLUE     PIXEL SIZE 32,08  of oFolder:aDialogs[2] PIXEL
	@ 16,40  MSGET cDestFil    COLOR CLR_BLUE     PIXEL SIZE 20,07  of oFolder:aDialogs[2] PIXEL WHEN .F.
	@ 16,60  MSGET cNomFil     COLOR CLR_BLUE     PIXEL SIZE 60,07  of oFolder:aDialogs[2] PIXEL WHEN .F.
	@ 16,130 SAY 'Necessidade' COLOR CLR_BLUE     PIXEL SIZE 45,08  of oFolder:aDialogs[2] PIXEL
	@ 16,170 MSGET nQtd        COLOR CLR_BLUE     PIXEL SIZE 35,07  of oFolder:aDialogs[2] PIXEL WHEN .F. PICTURE '@E 9999999.99'
	@ 16,245 MSGET cNumSol     COLOR CLR_BLUE     PIXEL SIZE 50,07  of oFolder:aDialogs[2] PIXEL WHEN .F.

	@ 32,02  LISTBOX oList98 ;
		FIELDS HEADERS   ' ','Fil Forn','Disponivel Transf', 'Saldo Atual', 'Saldo Disponivel', 'Consumo Medio', 'Dias Consumo' ;
		SIZE 360,085 ;
		PIXEL of oFolder:aDialogs[2] PIXEL  ;
		ON dblClick(lConTrf := FValida(cDestFil,cNomFil,.T.,oList98:nAt),aList98:=SDTroca(oList98:nAt,aList98,nQtd),oList98:Refresh())

//ON dblClick(aList98:=SDTroca(oList98:nAt,aList98,nQtd),oList98:Refresh())

	For nPos := 1 to 12

	// preenche cabecalho com ultimos 12 meses...
		aAdd( oList98:aHeaders, Left( MesExtenso( aMeses[ nPos, 1 ] ), 3 ) + '/' + StrZero( aMeses[ nPos, 2 ], 4 ) )

	Next nPos


	SB3->( dbSetOrder( 1 ) )

// avalia o SB2
	dbSelectArea('SB2')
	dbOrderNickName('B2_COD')
	dbSeek(cProduto + '98')

// carrega as posicoes para o vetor listbox
	aList98 := Array(0)
	Do While !Eof() .and. cProduto == SB2->B2_COD .and. SB2->B2_LOCAL == '98'
	// atualiza o vetor de selecao
	// nao existe transferencia da filial para ela propria
		If cDestFil == SB2->B2_FILIAL
			dbSkip()
			Loop
		EndIf

	// nao mostro local de Vendas(apenas 98-Exclusivo da importacao)
		If SB2->B2_LOCAL = '01'
			dbSkip()
			Loop
		EndIf

	// recupero a quantidade ja reservada neste processo para calcular o novo saldo disponivel p/ transferencia
		nSldPos := aScan(aSaldos, {|x| x[1] == SB2->B2_FILIAL+cProduto})
		If nSldPos > 0
			nAbate := aSaldos[nSldPos,2]
		Else
			nAbate := 0
		EndIf

	// alterado por Luciano Corrêa em 27/08/04 para constar saldos atual e disponivel e consumo medio...
		nSldDisp := SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QACLASS - SB2->B2_QPEDVEN + u_QtdPedTra( SB2->B2_COD, SB2->B2_FILIAL )

		SB3->( dbSeek( SB2->B2_FILIAL + SB2->B2_COD, .f. ) )
		Aadd(aList98,{ .F.,;
			SB2->B2_FILIAL,;
			SB2->B2_QATU-SB2->B2_RESERVA- SB2->B2_QACLASS - SB2->B2_QPEDVEN,;
			SB2->B2_QATU,;
			nSldDisp,;
			SB3->B3_MEDIA,;
			SB2->B2_CM1,;
			nQtd,;
			0,;
			'98'})

	// alterado por Luciano Corrêa em 18/10/04 para apresentar o nro de dias de consumo do saldo disponivel e o
	// consumo dos ultimos 12 meses...
		aLinAux := { Int( nSldDisp / ( SB3->B3_MEDIA / 30 ) ) }

		For nPos := 1 to 12

		// verifica se o consumo está atualizado até a database...
			If !Empty( SB3->B3_MES ) .and. ;
					Left( DtoS( SB3->B3_MES ), 6 ) < ( StrZero( aMeses[ nPos, 2 ], 4 ) + StrZero( aMeses[ nPos, 1 ], 2 ) )

				aAdd( aLinAux, 0 )
			Else
				aAdd( aLinAux, &( 'SB3->B3_Q' + StrZero( aMeses[ nPos, 1 ], 2 ) ) )
			EndIf

		Next nPos

		aAdd( aListAux, aLinAux )

		dbSkip()
	EndDo

// testa se encontrou algum registro, pois o array nao pode
// ser passado vazio para a listbox
	If Empty( aList98 )
		aList98 := { { .F., '', 0, 0, 0, 0, 0, 0, 0 } }
	EndIf
	If Empty( aListAux )
		aListAux := { { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } }
	EndIf

	oList98:SetArray(aList98)
	oList98:bLine:={|| {If(aList98[oList98:nAt, DEF_FLAG ],oOk,oNo),;
		aList98[oList98:nAt, DEF_FILIAL ],;
		aList98[oList98:nAt, DEF_SALDO ],;
		aList98[oList98:nAt, DEF_QATU ],;
		aList98[oList98:nAt, DEF_DISP ],;
		aList98[oList98:nAt, DEF_CONMED ],;
		aListAux[ oList98:nAt, 01 ], ;
		aListAux[ oList98:nAt, 02 ], ;
		aListAux[ oList98:nAt, 03 ], ;
		aListAux[ oList98:nAt, 04 ], ;
		aListAux[ oList98:nAt, 05 ], ;
		aListAux[ oList98:nAt, 06 ], ;
		aListAux[ oList98:nAt, 07 ], ;
		aListAux[ oList98:nAt, 08 ], ;
		aListAux[ oList98:nAt, 09 ], ;
		aListAux[ oList98:nAt, 10 ], ;
		aListAux[ oList98:nAt, 11 ], ;
		aListAux[ oList98:nAt, 12 ], ;
		aListAux[ oList98:nAt, 13 ] } }
	oList98:Refresh()



	ACTIVATE MSDIALOG oDlg CENTERED VALID lOk

Return(Iif(cLocEst='01',( aList ),(aList98 )))
**********************************************************************
Static Function SDTroca(nIt, aVetor, nQtd)
**********************************************************************

	Local oDlg1, oBut1
	Local nStart   := 0
	Local nQuant   := nQtd //0
	Local lOk      := .F.

	DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
	DEFINE FONT oBold2 NAME "Arial" SIZE 0, -11 BOLD
	DEFINE FONT oBold3 NAME "Arial" SIZE 0, -11


	If !lConTrf
		aVetor[nIt, DEF_FLAG ]   := .F.
		aVetor[nIt, DEF_QTDRES ] := 0
	Return(aVetor)
	Endif

	If aVetor[nIt, DEF_FLAG ]
		aVetor[nIt, DEF_FLAG ]   := .F.
		aVetor[nIt, DEF_QTDRES ] := 0
	Else
	//Define msDialog oDlg1 Title OemToAnsi( 'Quantidade' ) From 00,00 To 100,400 Pixel
		Define msDialog oDlg1 Title OemToAnsi( 'SC - ' +cNumSol) From 00,00 To 100,400 Pixel


		@ 012,008 Say OemToAnsi( 'Saldo a Transferir ?' ) Color CLR_BLUE  Of oDlg1 Pixel
   //	@ 012,055+45 msGet nQuant FONT oBold  Picture '@E 9,999,999.99' Of oDlg1 Pixel Size 60,10 VALID nQuant <= aVetor[nIt, DEF_SALDO ]
		@ 012,055+45 msGet nQuant FONT oBold  Picture '@E 9,999,999.99' Of oDlg1 Pixel Size 60,10 VALID  nQuant <= aVetor[nIt, DEF_SALDO ] .AND. fValidQtdSC(nQuant)


		Define sButton oBut1 From 12,165 Type 01 Enable Of oDlg1 Pixel Action ( lOk:=.T., oDlg1:End() )

	//Define sButton oBut1 From 030,165 Type 01 Enable Of oDlg1 Pixel Action ( lOk:=.T., oDlg1:End() )

		Activate msDialog oDlg1 Center
	EndIf

	If lOk .and. nQuant > 0
		aVetor[nIt, DEF_FLAG ]   := .T.
		aVetor[nIt, DEF_QTDRES ] := nQuant
	EndIf

	If 	oFolder:nOption=1 //O pedido esta sendo inserido no Estoque01
		cLocEst='01'
	Else
		cLocEst='98'//Armazem Exclusivo para processamento de Pedidos da Importacao junto ao WMS
	Endif

Return(aVetor)
**********************************************************************
User Function IDMailPv(aItens)
**********************************************************************

	Local aAreaSA1 := SA1->( GetArea() )
	Local nItem    := 0
	Local cCodTrf  := GetMV('MV_IMDEPA')
	Local cServer  := GetMV('MV_RELSERV')
	Local cUser    := GetMV('MV_RELACNT')
	Local cPass    := GetMV('MV_RELPSW')
	Local cBody    := Space(0)
	Local oProcess
	Local cTo      := Space(0)


// carrego os itens bloqueados para o corpo do e-mail
	cLoja := 'xx'
	For nItem := 1 To Len(aItens)

		If cLoja <> aItens[nItem,1]
			cLoja  := aItens[nItem,1]
			cBody  := 'Email enviado da Filial: '+xFilial()+' solicitando transferencia de material.'+Chr(13)+Chr(10)
			cBody  += Chr(13)+Chr(10)
			cBody  += Chr(13)+Chr(10)
			cBody  += 'Lista de necessidade:'+Chr(13)+Chr(10)
			cBody  += Chr(13)+Chr(10)
		EndIf

		SB1->( dbSeek(xFilial('SB1')+aItens[nItem,2]) )
		cBody  += aItens[nItem,2]+'  -  '+SB1->B1_DESC+'  -  '+Str(aItens[nItem,3],12,2)+Chr(13)+Chr(10)

	// testa se tem outro item e se ele eh da mesma filial
		If nItem+1 > Len(aItens) .or. aItens[nItem,1] <> aItens[nItem+1,1]
		// pega e-mail da filial
			SA1->( dbSeek(xFilial('SA1')+cCodTrf+aItens[nItem,1]) )

		// criacao do objeto oProcess
			oProcess := TWFProcess():New("Transferencia entre Filiais","Transferencia entre Filiais")

		// corpo do e-mail
			oProcess:cBody := cBody

		// assunto do e-mail
			oProcess:cSubject := "Transferencia entre Filiais"

		// destinatario
			cTo := ''
			oProcess:cTo := cTo

		// Envia o e-mail
			oProcess:Start()
		EndIf
	Next

	RestArea(aAreaSA1)

Return()
**********************************************************************
Static Function FValida(cDestino, cNomeDest, lImp, nPosListBox )
**********************************************************************
	Local lRet := .T.

// Jorge Oliveira - 12/08/2010 - Implementada a validacao do Custo Medio zerado
	If lImp

		If aList98[ nPosListBox, DEF_CUSTOM ] <= 0
			Msgbox( "Não está definido um custo do produto na filial selecionada."+Chr(13)+;
				"Não será possível selecionar essa filial.", "Atenção", "ALERT" )
			lRet := .F.
		EndIf

	Else

		If aList[ nPosListBox, DEF_CUSTOM ] <= 0
			Msgbox( "Não está definido um custo do produto na filial selecionada."+Chr(13)+;
				"Não será possível selecionar essa filial.", "Atenção", "ALERT" )
			lRet := .F.
		EndIf

	EndIf

	If lRet .And. cDestino != xFilial("SB1")
		Msgbox("Favor Executar Transferência Estando na Filial Há Qual se Destina a Mercadoria      "+Alltrim(cNomeDest)+" !","Atenção","ALERT")
		lRet := .F.
	Endif

Return( lRet )

**********************************************************************
User Function RetNameFil(__cEmp,__cFil)
**********************************************************************

	Local cName     := SM0->M0_FILIAL
	Local aArea     := GetArea()
	Local aAreaSM0  := SM0->( GetArea() )

	dbSelectArea('SM0')
	dbGoTop()
	Do While !Eof()
		If __cFil == SM0->M0_CODFIL .and. __cEmp == SM0->M0_CODIGO
			cName := SM0->M0_FILIAL
			Exit
		EndIf
		dbSkip()
	EndDo

	RestArea(aAreaSM0)
	RestArea(aArea)

Return(cName)
**********************************************************************
Static Function ValidPerg(cPerg)
**********************************************************************

	Local aRegs := {}
	Local i,j
	dbSelectArea("SX1")
	dbSetOrder(1)
//cPerg := PADR(cPerg,6) VER 811
	cPerg := PADR(cPerg,10)

//          Grupo/Ordem/Pergunta/                     Variavel/Tipo/Tam/Dec/Pres/GSC/ Valid/       Var01/      Def01________/ Cnt01/Var02/Def02_________/ Cnt02/ Var03/Def03___________/Cnt03/ Var04/Def04_______/Cnt04/ Var05/Def05_______/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Considera parametros","","","mv_ch1","N", 01,  0, 0,  "C", "",          "MV_PAR01",   "Sim",  "","",  "",   "",   "Nao",  "","",  "",    "",   "","","",        "",    "",   "","","",    "",    "",   "","","",    "",   ""})
	aAdd(aRegs,{cPerg,"02","Data inicial?   ","","",    "mv_ch2","D", 08,  0, 0,  "G", "",          "MV_PAR02",   "",     "","",  "",   "",   "",     "","",  "",    "",   "","","",        "",    "",   "","","",    "",    "",   "","","",    "",   ""})
	aAdd(aRegs,{cPerg,"03","Data Final?     ","","",    "mv_ch3","D", 08,  0, 0,  "G", "",          "MV_PAR03",   "",     "","",  "",   "",   "",     "","",  "",    "",   "","","",        "",    "",   "","","",    "",    "",   "","","",    "",   ""})
	aAdd(aRegs,{cPerg,"04","Fornecedor de?  ","","",    "mv_ch4","C", 06,  0, 0,  "G", "",          "MV_PAR04",   "",     "","",  "",   "",   "",     "","",  "",    "",   "","","",        "",    "",   "","","",    "",    "",   "","","",    "",   "SA2"})
	aAdd(aRegs,{cPerg,"05","Fornecedor ate? ","","",    "mv_ch5","C", 06,  0, 0,  "G", "",          "MV_PAR05",   "",     "","",  "",   "",   "",     "","",  "",    "",   "","","",        "",    "",   "","","",    "",    "",   "","","",    "",   "SA2"})
	aAdd(aRegs,{cPerg,"06","Solicitacao de? ","","",    "mv_ch6","C", 06,  0, 0,  "G", "",          "MV_PAR06",   "",     "","",  "",   "",   "",     "","",  "",    "",   "","","",        "",    "",   "","","",    "",    "",   "","","",    "",   ""})
	aAdd(aRegs,{cPerg,"07","Solicitacao ate?","","",    "mv_ch7","C", 06,  0, 0,  "G", "",          "MV_PAR07",   "",     "","",  "",   "",   "",     "","",  "",    "",   "","","",        "",    "",   "","","",    "",    "",   "","","",    "",   ""})

	For i := 1 to Len(aRegs)
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

//Edivaldo Goncalves Cordeiro - Nao permite Transferir uma quantidade diferente do definido na SC
**************************************
Static Function fValidQtdSC(nQtdDigi)
**************************************
	Local lReturn :=.T.

	If nQtdDigi > nQtdNaSC
		Msgbox( "O Saldo que você está tentando transferir , é superior ao definido"+Chr(13)+;
			"na solicitação de compras , o saldo máximo permitido é de " +Alltrim(Str(nQtdNaSC))+" Pçs.", "Quantidade difere da Solicitação", "ALERT" )
		lReturn:=.F.
	Endif

Return(lReturn)
