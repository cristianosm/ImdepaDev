#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

 //////////
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa  º IMDR150w º Autor º Edivaldo Gonçalves  º Data º  02/10/06 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao  º Impressao do Pedido de Venda Separação WMS,auxilio na     º±±
±±º           º separacao dos materiais(Com impressao de Endereco e Lote) º±±
±±º           º Está preparado para imprimir produtos que não estão       º±±
±±º           º habilitado a Rastreabilidade no WMS                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PEDIDO DE SEPARAÇÃO IMDEPA    						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  29/11/2006  Edivaldo Gonçalves  Cordeiro                             ³±±
±±³  Ajustado programa para fazer leitura de produtos que possuem         ³±±
±±ºRastreabilidade(Considerando o serviço ='001' e Tarefa='002' do WMS    ³±±
±±º-----------------------------------------------------------------------³±±
±±º 15/12/2006   Edivaldo Gonçalves Cordeiro                              ³±±
±±º              Corrigido problema na impressão de duplicidade de        ³±±
±±º              Produto X Endereço                                       ³±±
±±³                                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function IMDR050w()

Private cPerg := 'IMDR05'
Private aPedidos    := Array(0)

IF CVERSAO <> "MP8.11"
	cPerg := PADR(cPerg,10)
ENDIF


SX1->( dbSetOrder( 1 ) )

If !SX1->( dbSeek( cPerg ) )

	SX1->( RecLock( 'SX1', .T. ) )
	SX1->X1_GRUPO   := cPerg
	SX1->X1_ORDEM   := '01'
	SX1->X1_PERGUNT := 'Imprime marcados?'
	SX1->X1_VARIAVL := 'mv_ch01'
	SX1->X1_TIPO    := 'N'
	SX1->X1_TAMANHO := 1
	SX1->X1_GSC     := 'C'
	SX1->X1_VAR01   := 'mv_par01'
	SX1->X1_DEF01   := 'Sim'
	SX1->X1_DEF02   := 'Nao'
	SX1->( MsUnlock() )

	SX1->( RecLock( 'SX1', .T. ) )
	SX1->X1_GRUPO   := cPerg
	SX1->X1_ORDEM   := '02'
	SX1->X1_PERGUNT := 'Pedido:'
	SX1->X1_VARIAVL := 'mv_ch02'
	SX1->X1_TIPO    := 'C'
	SX1->X1_TAMANHO := 6
	SX1->X1_GSC     := 'G'
	SX1->X1_VALID   := 'Vazio() .or. ExistCpo("SC5")'
	SX1->X1_VAR01   := 'mv_par02'
	SX1->( MsUnlock() )
EndIf

If !SX1->( dbSeek( cPerg + '03' ) )

	SX1->( RecLock( 'SX1', .T. ) )
	SX1->X1_GRUPO   := cPerg
	SX1->X1_ORDEM   := '03'
	SX1->X1_PERGUNT := 'Emissao a partir de:'
	SX1->X1_VARIAVL := 'mv_ch03'
	SX1->X1_TIPO    := 'D'
	SX1->X1_TAMANHO := 8
	SX1->X1_GSC     := 'G'
	SX1->X1_VALID   := 'mv_par03>CtoD("01/11/03").and.mv_par03<=dDataBase'
	SX1->X1_VAR01   := 'mv_par03'
	SX1->( MsUnlock() )
EndIf

DO WHILE Pergunte( cPerg, .T. )

	Private cString   := 'SC5'
	Private cTitulo   := 'Pedidos de Venda - Separacao WMS'
	Private cDesc1    := OemToAnsi( 'Este programa vai emitir o relatório de Pedidos de Venda' )
	Private cDesc2    := OemToAnsi( 'separados pelo WMS, conforme os parâmetros informados pelo' )
	Private cDesc3    := OemToAnsi( 'usuário.Também está compátivel para imprimir produtos que não estã habilitados a Rastreabilidade' )
	Private cCabec1   := ''
	Private cCabec2   := ''
	Private aReturn   := { 'Zebrado', 1,'Administracao', 2, 2, 1, '',1 }
	Private cNomeProg := 'IMDR050b'
	Private cTamanho  := 'P'
	Private nLastKey  := 0
	Private m_pag     := 1
	Private cNomeRel  := Time()
	cNomeRel  := ( DtoS( Date() ) + SubStr( cNomeRel, 1, 2 ) + SubStr( cNomeRel, 4, 2 ) + SubStr( cNomeRel, 7, 2 ) )
	Private wnrel     //:= SetPrint( cString, cNomeRel, cPerg, cTitulo, cDesc1, cDesc2, cDesc3, .F., '', .T., cTamanho,, .F. )

	MsAguarde({||SF4->(RunProc()) },"Pedido Separação...","Estruturando lista de Pedidos ...")

END DO
Return


********************************************************************************
Static Function RunProc()

Local oDlg, oBut1, oBut2, oList
Local aItensFull  := Array(0)
Local aItensTemp :={}
Local lRetSemBloqWms

Local oEnable  := Loadbitmap( GetResources(), 'ENABLE' )
Local oCinza := Loadbitmap( GetResources(), 'BR_CINZA' )
Local oAzul  := Loadbitmap( GetResources(),'FWOCN_RDO_HVR.PNG')


Private cQuery    := ""
Private cPedidos  := ""
Private lImpresso := .F.
Public dDataCom   := CToD("  /  /  ")
Public cHRLCom    := ""
Public cUSRCom    := ""
Public dDataCre   := CToD("  /  /  ")
Public cUSRCre    := ""
Public cHRLCre    := ""

SUA->(DbSetOrder(8))

*--------------------------------------------------------*
//Seleciona os pedidos aptos a impressão para Separação  //
*--------------------------------------------------------*
// query para analisar os pedidos que podem ser impressos...
cQuery := "select C5_FILIAL, C5_NUM, C5_TIPFAT, C5_NUMSUA, sum( C6_QTDVEN ) C6_QTDVEN, sum( C9_QTDLIB ) C9_QTDLIB"
cQuery += " from ("
// seleciono a quantidade total dos pedidos de venda que possuem algum item apto a ser faturado...
cQuery += " select C5_FILIAL, C5_NUM, C5_TIPFAT, C5_NUMSUA, sum( C6_QTDVEN ) C6_QTDVEN, 0 C9_QTDLIB"
cQuery += "  from " + RetSqlName( 'SC5' ) + " SC5, " + RetSqlName( 'SC6' ) + " SC6"
cQuery += "  where C5_FILIAL = '" + xFilial( 'SC5' ) + "'"
cQuery += "  and C5_EMISSAO >= '" + DtoS( mv_par03 ) + "'"
cQuery += "  and SC5.D_E_L_E_T_ = ' '"
cQuery += If( !Empty( mv_par02 ), " and C5_NUM = '" + mv_par02 + "'", "" )

cQuery+=" AND C6_IMPEMB = " + If( mv_par01 = 1, "'S'", "' '" )

// verifica se o pedido possui algum item apto a ser faturado...
cQuery += "  and exists ("
cQuery += "  select C9_PEDIDO"
cQuery += "  from " + RetSqlName( 'SC9' ) + " SC9B"
cQuery += "  where SC9B.C9_FILIAL = SC5.C5_FILIAL"
cQuery += "  and SC9B.C9_PEDIDO = SC5.C5_NUM"


cQuery += "  and SC9B.C9_SERIENF = ' '"
cQuery += "  and SC9B.C9_NFISCAL = ' '"
cQuery += "  and SC9B.C9_BLCRED = ' '"
cQuery += "  and SC9B.C9_BLEST = ' '"

cQuery += "  and SC9B.C9_STSERV ='3'"
cQuery += "  and SC9B.D_E_L_E_T_ = ' ' )"
cQuery += "  and C6_FILIAL = C5_FILIAL"
cQuery += "  and C6_NUM = C5_NUM"
cQuery += "  and SC6.D_E_L_E_T_ = ' '"
cQuery += "  group by C5_FILIAL, C5_NUM, C5_TIPFAT, C5_NUMSUA"
cQuery += " union all"
// seleciono a quantidade total dos itens aptos a serem faturados...
cQuery += " select C5_FILIAL,C5_NUM, C5_TIPFAT, C5_NUMSUA, 0 C6_QTDVEN, sum( C9_QTDLIB ) C9_QTDLIB"
cQuery += "  from " + RetSqlName( 'SC5' ) + " SC5, " + RetSqlName( 'SC9' ) + " SC9"
cQuery += "  where C5_FILIAL = '" + xFilial( 'SC5' ) + "'"
cQuery += "  and C5_EMISSAO >= '" + DtoS( mv_par03 ) + "'"
cQuery += "  and SC5.D_E_L_E_T_ = ' '"
cQuery += If( !Empty( mv_par02 ), " and C5_NUM = '" + mv_par02 + "'", "" )

cQuery += "  and C9_FILIAL = C5_FILIAL"
cQuery += "  and C9_PEDIDO = C5_NUM"

cQuery += "  and C9_SERIENF = ' '"
cQuery += "  and C9_NFISCAL = ' '"
cQuery += "  and C9_BLCRED = ' '"
cQuery += "  and C9_BLEST = ' '"

cQuery += "  and C9_STSERV ='3'"
cQuery += "  and SC9.D_E_L_E_T_ = ' '"
cQuery += "  group by C5_FILIAL, C5_NUM, C5_TIPFAT, C5_NUMSUA )"
cQuery += "  group by C5_FILIAL, C5_NUM, C5_TIPFAT, C5_NUMSUA "

IF SELECT( "SC5TMP1" ) <> 0
	dbSelectArea("SC5TMP1")
	SC5TMP1->(DbCLoseArea())
Endif


//MEMOWRIT("C:\SQLSIGA\IMDR050B_SC5TMP.TXT", cQuery)
dbUseArea( .T., 'TOPCONN', TCGenQry( ,, cQuery ), 'SC5TMP1', .T., .T. )

TCSetField( 'SC5TMP1', 'C6_QTDVEN' , 'N', 14, 4 )
TCSetField( 'SC5TMP1', 'C9_QTDLIB' , 'N', 14, 4 )

// analisa os pedidos que podem ser impressos...
//dbGotop()

While SC5TMP1->( !Eof() )


	//IncProc( 'Analisando Pedido ' + SC5TMP1->C5_NUM )


  If  SC5TMP1->C6_QTDVEN == SC5TMP1->C9_QTDLIB
	 	cPedidos += "'" + SC5TMP1->C5_NUM + "',"
  Else

  EndIf

	dbSkip()
Enddo

dbSelectArea('SC5TMP1')
dbCloseArea()

//dbSelectArea('SC5')

If Empty( cPedidos )

	MsgStop( 'Nao existem pedidos de separacao a serem impressos', cTitulo )
	Return
Else

	cQuery:=" SELECT C5_FILIAL,C5_NUM,C5_CLIENTE,C5_LOJACLI,C5_EMISSAO,C6_IMPEMB,C5_PEDGUIA"
	cQuery+=" FROM "
	cQuery+=RetSqlName( 'SC6' ) + " SC6, "+RetSqlName( 'SC5' ) + " SC5 "
	cQuery+=" WHERE "
	cQuery+=" C5_FILIAL='"+ xFilial( 'SC5' )+ "'"
	cQuery+=" AND C6_FILIAL=C5_FILIAL"
	cQuery+=" AND C5_NUM in (" + Left( cPedidos, Len( cPedidos ) - 1 ) + ")"
	cQuery+=" AND C6_NUM=C5_NUM"
	cQuery+=" AND  SC5.D_E_L_E_T_ = ' '"
	cQuery+=" AND  SC6.D_E_L_E_T_ = ' '"
	cQuery+=" GROUP BY C5_FILIAL,C5_NUM,C5_CLIENTE,C5_LOJACLI,C5_EMISSAO,C6_IMPEMB,C5_PEDGUIA "
	cQuery+=" ORDER BY C5_PEDGUIA DESC ,C5_NUM  "


	IF Select('SC5TMP') <> 0
	    SC5TMP->( DbCLoseArea() )
	Endif

	dbUseArea( .T., 'TOPCONN', TCGenQry( ,, cQuery ), 'SC5TMP', .T., .T. )
	TCSetField( 'SC5TMP', 'C5_EMISSAO', 'D', 08, 0 )


	dbselectarea('SC5TMP')
	//SC5TMP->( DBGOTOP())
	aPedidos:=Array(0)

	While SC5TMP->( !Eof() )

		//MsAguarde({||lRetSemBloqWms:=SF4->(checkServico(SC5TMP->C5_FILIAL,SC5TMP->C5_NUM)) },"Status de Serviço WMS",'Checando Pedido '+SC5TMP->C5_NUM+'...')
		lRetSemBloqWms:=SF4->(checkServico(SC5TMP->C5_FILIAL,SC5TMP->C5_NUM))

		If lRetSemBloqWms
	   	SA1->( dbSeek(xFilial('SA1')+SC5TMP->C5_CLIENTE+SC5TMP->C5_LOJACLI) )

				Aadd(aPedidos,{ Iif(SC5TMP->C6_IMPEMB=='S',.T.,.F.) ,;
										SC5TMP->C5_FILIAL,;
										SC5TMP->C5_NUM,;
										SC5TMP->C5_EMISSAO,;
										SC5TMP->C5_CLIENTE,;
										SC5TMP->C5_LOJACLI,;
										SA1->A1_NOME,;
										SC5TMP->C5_PEDGUIA})

		Endif

		dbSkip()
	EndDo

Endif

//RodaRel(aPedidos)
// dialogo com o usuario
If !Empty(aPedidos)

	DEFINE MSDIALOG oDlg TITLE 'Impressão de Pedidos de Separação WMS' FROM 0,0 TO 18,100 OF oMainWnd
//	DEFINE SBUTTON oBut1 FROM 115,250 TYPE 01 ENABLE OF oDlg PIXEL ACTION(RodaRel(aPedidos))
//	DEFINE SBUTTON oBut2 FROM 115,285 TYPE 02 ENABLE OF oDlg PIXEL ACTION( Iif(MarcaPV(aPedidos), (aPedidos:=Array(0), oDlg:End()),.F.) )

	@ 109,003 bitmap size 8,8 file 'FWOCN_RDO_HVR.PNG' of oDlg  NOBORDER WHEN .F. PIXEL
	@ 109,012  Say "Pedido c/ Guia Aguardando Impressão "  of oDlg PIXEL

	@ 109,115 bitmap size 8,8 file 'ENABLE' of oDlg  NOBORDER WHEN .F. PIXEL
	@ 109,124  Say "Pedido Aguardando Impressão "  of oDlg PIXEL

	@ 109,206 bitmap size 8,8 file 'BR_CINZA' of oDlg NOBORDER WHEN .F. PIXEL
	@ 109,217  Say "Pedido Impresso "  of oDlg PIXEL

	//oBtn_localiza := TButton():New(115,250,"",oDlg,{|| fLocaliza1(),oListPRO:cToolTip:='' },39,18,,,.F.,.T.,.F.,'Imprimir',.F.,,,.F. )
   //	oBtn_localiza:SetCss("QPushButton{ background-image: url(rpo:localiza_mdi.png);"+" background-repeat: none; margin: 2px }")
	TBtnBmp2():New(216,745,035,018,'IMPRESSAO_OCEAN.PNG',,,,{|| RodaRel(aPedidos) },oDlg,"Imprimir",{||},,.T. )
	TBtnBmp2():New(240,745,035,018,'IC_20_CANCELAR.GIF',,,,{|| Iif(MarcaPV(aPedidos), (aPedidos:=Array(0), oDlg:End()),.F.)  },oDlg,"Sair",{||},,.T. )




	/*
	@ 116,003 bitmap size 8,8 file 'ENABLE' of oDlg  NOBORDER WHEN .F. PIXEL
	@ 116,013  Say "Pedido Aguardando Impressão "  of oDlg PIXEL
	*/

	/*
	@ 125,003 bitmap size 8,8 file 'BR_AMARELO' of oDlg PIXEL
	@ 125,13  Say "Pedido Impresso "  of oDlg PIXEL
    /*

	/*
	@ 121,003 bitmap size 7,7 file 'BR_AMARELO' of oDlg PIXEL
	@ 121,13  Say "Pedido Impresso "  of oDlg PIXEL
	*/


	  @ 05,02  LISTBOX oList FIELDS HEADER  ' ','Filial','Pedido','Emissao','Cliente','Loja','Nome','Guia GNE ' SIZE 100,100 PIXEL OF oDlg




	oList:Align := 3
	oList:SetArray(aPedidos)
    oList:bLine:={|| {IIf(aPedidos[ oList:nAt,8] == '1' , IIf(aPedidos[ oList:nAt,1] == .F. , oAzul ,oCinza) , IIf(aPedidos[ oList:nAt,1] == .F. , oEnable ,oCinza)),;
							aPedidos[oList:nAt,02],;
							aPedidos[oList:nAt,03],;
							aPedidos[oList:nAt,04],;
							aPedidos[oList:nAt,05],;
							aPedidos[oList:nAt,06],;
							aPedidos[oList:nAt,07],;
							aPedidos[oList:nAt,08]}}
	oList:Refresh()




	ACTIVATE MSDIALOG oDlg CENTER

Endif

dbSelectArea('SC5TMP')
dbCloseArea()

dbSelectArea('SC5')


Return


*---------------------------------------------------------*
//Pesquisa status do serviço WMS EXECUTADO/NAO EXECUTADO //
*---------------------------------------------------------*
Static Function checkServico(cCodFil,cPedido)
Local lRet
Local cQuery

cQuery :="SELECT DCF_STSERV "
cQuery +=" FROM "
cQuery +=RetSqlName("DCF")+" DCF "
cQuery +=" WHERE   DCF_FILIAL='"+cCodFil+"'"
cQuery +=" AND DCF_DOCTO    ='"+cPedido+"'"
cQuery +=" AND DCF_SERVIC='001'"
cQuery +=" AND DCF.D_E_L_E_T_ = ' ' "

IF Select('TRB') <> 0
    TRB->( DbCLoseArea() )
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.T.,.T.)

DbselectARea("TRB")
DbGoTop()

If TRB->( Eof() )
	//Pedido não possui itens Gerenciado pelo WMS,Libera impressão do pedido de separação
	lRet:=.T.
Else
	If TRB->DCF_STSERV='1' .OR. TRB->DCF_STSERV='2' //Serviço está pendente a Execução,bloqueia a impressão
		lRet:=.F.
	Else
		lRet:=.T.
	Endif
Endif

Return lRet



Static Function BuscaItensDBC9(cCodFil,cPedido)
Local aItensPed:={}
Local cController:=.F.
Local lController

*************************************************************************************
//Busca Itens de Produto com seus respectivos Endereços e Lotes separados pelo WMS //
*************************************************************************************

cQuery :="SELECT DB_FILIAL,DB_DOC,DB_PRODUTO,DB_LOCALIZ,DB_QUANT,DB_LOTECTL,B1_MARCA,B1_DESC,B1_PESO,B1_ORIGEM,B1_UM "
cQuery +=" FROM "
cQuery += RetSqlName("SDB")+" SDB, "+RetSqlName("SC9")+" SC9, "+RetSqlName( "SB1" )+ " SB1 "
cQuery +=" WHERE DB_DOC  = '"+cPedido+"' "
cQuery +=" AND DB_FILIAL = '"+cCodFil +"' "
cQuery +=" AND C9_FILIAL = DB_FILIAL "
cQuery +=" AND B1_FILIAL = DB_FILIAL "

cQuery +=" AND C9_PEDIDO  = DB_DOC "
cQuery +=" AND C9_ITEM    = DB_SERIE "
cQuery +=" AND C9_PRODUTO = DB_PRODUTO "
cQuery +=" AND C9_IDDCF   = DB_IDDCF "
cQuery +=" AND B1_COD     = DB_PRODUTO "
cQuery +=" AND B1_LOCALIZ = 'S' "

cQuery +=" AND DB_ESTORNO <> 'S' "
cQuery +=" AND DB_TM > '500' "
cQuery +=" AND DB_ATUEST = 'N' "
cQuery +=" AND DB_SERVIC = '001' "
cQuery +=" AND DB_TAREFA = '002' "

// Jorge Oliveira - 28/07/2010 - Inclusao da Atividade 015 - Separar Produtos
If cVersao <> "MP8.11"
	cQuery +=" AND DB_ATIVID = '015' "
EndIf

cQuery +=" AND SDB.D_E_L_E_T_ = ' ' "
cQuery +=" AND SC9.D_E_L_E_T_ = ' ' "
cQuery +=" AND SB1.D_E_L_E_T_ = ' ' "
cQuery +=" ORDER BY DB_LOCALIZ ASC "


IF Select('TRB') <> 0
    TRB->( DbCLoseArea() )
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.T.,.T.)


DbselectARea("TRB")

ProcRegua(TRB->(Reccount()))

While TRB->(!Eof())
	//MsAguarde({||lController:=SF4->(chekReabastAuto(TRB->DB_DOC,TRB->DB_PRODUTO)) },"Reabastecimento Automático",'Checando  Reabastecimento para o item '+TRB->DB_PRODUTO+'...')
	lController:=SF4->(chekReabastAuto(TRB->DB_DOC,TRB->DB_PRODUTO))

	aAdd(aItensPed,{ TRB->DB_FILIAL,;
							TRB->DB_DOC,;
							TRB->DB_PRODUTO,;
							TRB->DB_QUANT,;
							ALLTRIM(TRB->DB_LOCALIZ),;
							TRB->B1_MARCA,;
							TRB->B1_DESC,;
							TRB->B1_PESO,;
							TRB->B1_UM,;
							TRB->B1_ORIGEM,;
							TRB->DB_LOTECTL,;
							Iif(lController,'Não Possui','S')})

	//Incproc('Estruturando lista de produtos com Endereço e Lote')
	DbSkip()

Enddo

DbselectARea("TRB")
DbCloseArea()

/*

*----------------------------------------------------------------------------------------------*
//Carrega os Pedidos que podem ser impressos e que não estão habilitado a Rastreabilidade WMS //
*----------------------------------------------------------------------------------------------*

cQuery := "select C6_FILIAL, C6_NUM, C6_ITEM, C9_SEQUEN, C6_PRODUTO, C9_QTDLIB, C9_PRCVEN,"
cQuery += "B1_UM, B1_REFER, B1_PESO, B1_MARCA, B1_ORIGEM, C6_CLI, C6_LOJA "

cQuery += " from " + RetSQLName( 'SC6' ) + " SC6, " + RetSQLName( 'SC9' ) + " SC9, " + RetSQLName( 'SB1' ) + " SB1 "

cQuery += " where C6_FILIAL = '" + xFilial( 'SC6' ) + "'"
cQuery += " and C6_NUM ='" +cPedido+"'"
cQuery += " and C6_IMPEMB = " + If( mv_par01 = 1, "'S'", "' '" )
cQuery += " and SC6.D_E_L_E_T_ = ' '"

cQuery += " and C9_FILIAL = '" + xFilial( 'SC9' ) + "'"
cQuery += " and C9_PEDIDO = C6_NUM"
cQuery += " and C9_ITEM = C6_ITEM"
cQuery += " and C9_PRODUTO = C6_PRODUTO"

cQuery += " and C9_SERIENF = ' '"
cQuery += " and C9_NFISCAL = ' '"
cQuery += " and C9_BLEST   = ' '"
cQuery += " and C9_BLCRED  = ' '"
cQuery += " and SC9.D_E_L_E_T_ = ' '"

cQuery += " and B1_FILIAL = '" + xFilial( 'SB1' ) + "'"
cQuery += " and B1_COD = C9_PRODUTO"
cQuery += " AND B1_LOCALIZ <> 'S' "
cQuery += " and SB1.D_E_L_E_T_ = ' '"
cQuery += " order by C6_FILIAL, C6_NUM, B1_REFER, C6_PRODUTO"


IF Select('SC6TMP') <> 0
	SC6TMP->( DbCLoseArea() )
Endif


dbUseArea( .T., 'TOPCONN', TCGenQry( ,, cQuery ), 'SC6TMP', .T., .T. )

TCSetField( 'SC6TMP', 'C9_QTDLIB' , 'N', 14, 4 )
TCSetField( 'SC6TMP', 'C9_PRCVEN' , 'N', 14, 4 )
TCSetField( 'SC6TMP', 'B1_PESO'   , 'N', 11, 4 )
TCSetField( 'SC6TMP', 'C5_EMISSAO', 'D', 08, 0 )

dbselectarea('SC6TMP')
SC6TMP->( DBGOTOP())
ProcRegua(SC6TMP->(Reccount()))

While SC6TMP->( !Eof() )
	MsAguarde({||lController:=SF4->(chekReabastAuto(SC6TMP->C6_NUM,SC6TMP->C6_PRODUTO)) },"Reabastecimento Automático",'Checando  Reabastecimento para o item '+SC6TMP->C6_PRODUTO+'...')
	aAdd(aItensPed,{ SC6TMP->C6_FILIAL,;
							SC6TMP->C6_NUM,;
							SC6TMP->C6_PRODUTO,;
                		SC6TMP->C9_QTDLIB,;
                		'Não Possui',;
                		Alltrim(SC6TMP->B1_MARCA),;
                 		Alltrim(SC6TMP->B1_REFER),;
                		SC6TMP->B1_PESO,;
                 		SC6TMP->B1_UM,;
                		SC6TMP->B1_ORIGEM,;
                		'Não Possui',;
                		Iif(lController,'Não Possui','S')})

	IncProc('Estruturando lista de produtos sem Endereço')
	dbSkip()
EndDo
*/
Return(aItensPed)


**********************************************************************************
Static Function RodaRel(aPedidos)
nLastKey := 0

wnrel := SetPrint( cString, cNomeRel, cPerg, cTitulo, cDesc1, cDesc2, cDesc3, .F., '', .T., cTamanho,, .F. )


If nLastKey == 27
	Set Filter to
	Return
EndIf

SetDefault( aReturn, cString )

If nLastKey == 27
	Set Filter to
	Return
EndIf

Processa( { || RptDetail(aPedidos) } )

Return



********************************************************************************
Static Function RptDetail(aPedidos)

Local nValTot, nPesTot, cKey
Local nStart, nItem
Local cQuery
Local aItensPV:={}
Local lRetabastAuto
Local nLin := 0
Local cPictPeso := PesqPict( "SB1", "B1_PESO" )

Private cNomeVend1, cNomeVend2
Private nTipo := If( aReturn[4] == 1, 15, 18 )



//ProcRegua( Len(aPedidos) )

SA1->( dbSetOrder( 1 ) )
SA2->( dbSetOrder( 1 ) )
SA3->( dbSetOrder( 1 ) )
SA4->( dbSetOrder( 1 ) )
SC5->( dbSetOrder( 1 ) )
SC6->( dbSetOrder( 1 ) )
SE4->( dbSetOrder( 1 ) )
SU7->( dbSetOrder( 1 ) )
SUA->(DbSetOrder(8))
ZZV->( dbSetOrder( 1 ) )

SC9->(DBSETORDER(1))


For nStart := 1 To Len(aPedidos)

	// ajusta variaveis de controle
	cFilPed   := aPedidos[nStart,2]
	cNumPed   := aPedidos[nStart,3]

  //	IncProc( 'Imprimindo pedido ' + cNumPed )

	SC5->( dbSeek( cFilPed + cNumPed, .F. ) )
	SA3->( dbSeek( xFilial( 'SA3' ) + SC5->C5_VEND1, .F. ) )
	SA3->( dbSeek( xFilial( 'SA3' ) + SC5->C5_VEND2, .F. ) )	; cNomeVend2 := AllTrim( SA3->A3_NOME )
	SA4->( dbSeek( xFilial( 'SA4' ) + SC5->C5_TRANSP, .F. ) )
	SE4->( dbSeek( xFilial( 'SE4' ) + SC5->C5_CONDPAG, .F. ) )
	SU7->( dbSeek( xFilial( 'SU7' ) + SC5->C5_OPERADO, .F. ) )  ; cNomeVend1 := AllTrim( SU7->U7_NOME )
	SUA->( dbSeek( xFilial( 'SUA' ) + SC5->C5_NUM, .F. ) )

	nValTot := 0
	nPesTot := 0
	cKey    := cFilPed + cNumPed

 //	Processa( { || SF4->( aItensPV := BuscaItensDBC9(cFilPed,cNumPed)) }, cTitulo, 'Estruturando Itens do Pedido '+cNumPed+'...' )
    aItensPV := BuscaItensDBC9(cFilPed,cNumPed)

	nPos := Ascan(aItensPV, {|x| x[1]+x[2] = cKey})

	If nPos > 0

		For nItem := nPos To Len(aItensPV)

			cFilPed     := aItensPV[nItem,1]   // SC6TMP->C6_FILIAL
			cUM			:= aItensPV[nItem,9]  // SC6TMP->B1_UM
			cNumPed     := aItensPV[nItem,2]   // SC6TMP->C6_NUM
			cProduto    := aItensPV[nItem,3]   // SC6TMP->C6_NUM
			nC9_QTDLIB  := aItensPV[nItem,4]   // SC6TMP->C9_QTDLIB
			cB1_REFER   := aItensPV[nItem,7]   // SC6TMP->B1_REFER
			cB1_MARCA   := aItensPV[nItem,6]   // SC6TMP->B1_MARCA
			cB1_ORIGEM  := aItensPV[nItem,10]  // SC6TMP->B1_ORIGEM
			nB1_PESO    := aItensPV[nItem,8]   // SC6TMP->B1_PESO
			cEnd        := aItensPV[nItem,5]   // Endereço do Produto
			cLote       := aItensPV[nItem,11]
			cReabast    := aItensPV[nItem,12]

			nC6_PRCVEN  := 0

			If cFilPed + cNumPed <> cKey
				Exit
			EndIf

			SC6->( dbSeek( cFilPed + cNumPed, .F. ) )

			If pRow() > 50 .or. m_pag == 1	// salto de pagina, neste caso o formulario tem 55 linhas...
				ImpCabec()
		    	lImpresso := .T.
			EndIf

		   //MsAguarde({||lRetabastAuto:=SF4->(chekReabastAuto(SC5->C5_NUM,cProduto)) },"Reabastecimento Automático",'Checando  se gerou para o Item '+cProduto+'...')
		  lRetabastAuto:=SF4->(chekReabastAuto(SC5->C5_NUM,cProduto))

			//                                1         2         3         4         5         6         7         8
			//                      0123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
			// @ pRow()+1,000 pSay 'Endereço      Qtd   Codigo     Descrição                Marca   Ori  UM  Peso_Un '

	       @ pRow()+1, 000 pSay LEFT(cEnd,8)

		   If lRetabastAuto
		  	   @ pRow()  , 008 pSay 'R'
	  	   Else
	  	      @ pRow()  , 009 pSay ' '
	  	   Endif

			// Jorge Oliveira - 20/08/2010 - Nao estava imprimindo as 3 primeiras colunas, somente mostrava na tela.
	      //@ pRow()  , 010 pSay Alltrim(PADL(transform(nC9_QTDLIB , "@E 99999999.99"  ),11," "))
/*
	      @ pRow()  , 008 pSay Transform( nC9_QTDLIB, "@E 999999.99"  ) + "|"
	      @ pRow()  , 022 pSay Left( Alltrim(cProduto), 10 ) + "|"
	      @ pRow()  , 032 pSay SubStr(cB1_REFER,1,25) + "|"
	      @ pRow()  , 057 pSay SubStr( cB1_MARCA, 1, 15 ) + "|"
	      @ pRow()  , 065 pSay cB1_ORIGEM  + "|"
	      @ pRow()  , 069 pSay cUM + "|"
	      @ pRow()  , 072 pSay nB1_PESO Picture cPictPeso //"@E 999.9999"
*/
	      @ pRow()  , 010 pSay Transform( nC9_QTDLIB, "@E 999999.99"  )

	      /////JULIO JACOVENKO, em 18/08/2016
	      /////ajustado conf. solicitacao ref. chamdo N. 8881 do Jonas

	      //@ pRow()  , 020 pSay Left( Alltrim(cProduto), 10 )
	      @ pRow()  , 020 pSay Left( Alltrim(cProduto), 13 )

	      //@ pRow()  , 030 pSay SubStr(cB1_REFER,1,25)
	      @ pRow()  , 035 pSay SubStr(cB1_REFER,1,22)

	      //@ pRow()  , 056 pSay SubStr( cB1_MARCA, 1, 05 )
	      @ pRow()  , 059 pSay SubStr( cB1_MARCA, 1, 05 )

	      //@ pRow()  , 062 pSay cB1_ORIGEM
	      @ pRow()  , 065 pSay cB1_ORIGEM

	      //@ pRow()  , 065 pSay cUM
	      @ pRow()  , 067 pSay cUM

	      //@ pRow()  , 068 pSay nB1_PESO Picture cPictPeso //"@E 999.9999"
	      @ pRow()  , 070 pSay nB1_PESO Picture cPictPeso //"@E 999.9999"
                       //71+8 79

		   nPesTot += nB1_PESO * nC9_QTDLIB

          @ pRow()+1, 000 pSay __PrtThinLine()


		Next

	Else

		If pRow() > 50 .or. m_pag == 1	// salto de pagina, neste caso o formulario tem 55 linhas...
			ImpCabec()
		EndIf

	Endif

	dbSelectArea("SC9")
	dbSetOrder(1)

	//JULIO JACOVENKO, em 12/08/2013 - nao estava encontrando
	//dbSeek( SC6->C6_FILIAL + SC6->C6_NUM ,.F. )
	//ALERT(SC6->C6_FILIAL + SC6->C6_NUM)


	IF SC9->(dbSeek( cFilPed + ALLTRIM(cNumPed), .F. ) )
	    //ALERT('...ACHOU...')
	    //DtoC(SC9->C9_DTLCOM)+" - "+SC9->C9_HRLCOM+" - "+SC9->C9_USRLCOM
	    cDTLCOM :=DtoC(SC9->C9_DTLCOM)
	    cHRLCOM :=SC9->C9_HRLCOM
	    cUSRLCOM:=SC9->C9_USRLCOM

	    //DtoC(SC9->C9_DTLCRE)+" - "+SC9->C9_HRLCRE+" - "+SC9->C9_USRLCRE
	    cDTLCRE:=DtoC(SC9->C9_DTLCRE)
	    cHRLCRE:=SC9->C9_HRLCRE
	    cUSRLCRE:=SC9->C9_USRLCRE
	ELSE
	    //ALERT(cFilPed + cNumPed)
	    //ALERT('...NAO ACHOU...')
	ENDIF



	If pRow() > 50
		ImpCabec()
	EndIf

	@ pRow()  +2,056 psay 'Peso Total:'
	@ pRow()  , 068 pSay nPesTot Picture  '@E 99,999.99999' //'@E 999,999.99999'
	@ pRow()+1, 000 pSay __PrtThinLine()
	@ pRow()+1, 000 pSay 'Visto Expedicao em ___/___/___     Visto:_________________    NF:_______________'
	@ pRow()+1, 000 pSay __PrtThinLine()

	@ pRow()+2, 000 pSay "Lib. Pedidos : Comercial "+cDTLCOM+" - "+cHRLCOM+" - "+cHRLCOM
	@ pRow()+1, 000 pSay "Lib. Pedidos : Credito   "+cDTLCRE+" - "+cHRLCRE+" - "+cUSRLCRE

	If pRow() > 50
		ImpCabec()
	EndIf

	// Jorge Oliveira - 10/12/10 - Chamado AAZRS1 - Incluida uma "Ficha de Separacao", para preenchimento manual do pessoal do CD
	@ pRow()+2, 000 pSay __PrtThinLine()
	@ pRow()+1, 000 pSay Space( 28 ) + "FICHA DE SEPARACAO"
	@ pRow()+1, 000 pSay __PrtThinLine()
	@ pRow()+1, 000 pSay "SEPARADOR:___________________________"
	@ pRow()  , 040 pSay "INICIO:_____:_____ "

	@ pRow()+2, 000 pSay "EMBALADOR:___________________________"
	@ pRow()  , 040 pSay "TERMINO:_____:_____"

	@ pRow()+2, 000 pSay "CONFERENTE:__________________________"
	@ pRow()  , 040 pSay "FATURAMENTO:_____:_____"

	//@ pRow()+2, 000 pSay "FINAL DO PROCESSO:_____:_____"

	@ pRow()+2, 000 pSay "QUANTIDADE DE ERROS:_________________"
	@ pRow()  , 040 pSay "TIPOS DE ERROS:______________________"

    @ pRow()+2, 000 pSay "PESO BRUTO:_________________"
	@ pRow()  , 040 pSay "QTD VOLUMES:______________________"



	m_pag := 1

Next

If aReturn[5] == 1
	Set Printer to
	Commit
	OurSpool( wnrel )
EndIf
Ms_Flush()

Return


*------------------------------------------------------------*
//  Impressão do Cabeçalho do Relatório Pedido de Separação //
*------------------------------------------------------------*
Static Function ImpCabec()

Local cCliImdepa  := GetMV('MV_IMDEPA')
Local cDescSeg    := ' '
Local cSegmento	  := SPACE(TamSX3('A1_GRPSEG')[1])
Local lTemGuia    :=.F.  //Define se o pedido possui Guia GNE

Cabec( cTitulo, cCabec1, cCabec2, cNomeProg, cTamanho, nTipo )

// MsAguarde({||lRetabastAuto:=SF4->(chekReabastAuto(SC5->C5_NUM)) },"Reabastecimento Automático",'Checando  Reabastecimento para o pedido '+SC5->C5_NUM+'...')
If !SC5->C5_TIPO $ 'DB'

	SA1->( dbSeek( xFilial( 'SA1' ) + SC5->C5_CLIENTE + SC5->C5_LOJACLI, .F. ) )

	cCliente := SA1->A1_COD + '/' + SA1->A1_LOJA + ' ' + SA1->A1_NOME
	cEndFatu := AllTrim( U_ALTEND(SA1->A1_END) ) + ', ' + AllTrim( Str( SA1->A1_NUMEND, 6 ) )
	cCidFatu := AllTrim( SA1->A1_MUN ) + ' - ' + SA1->A1_EST
	cEndEntr := AllTrim( SA1->A1_ENDENT) + ', ' + AllTrim( Str( SA1->A1_NUMENTR, 6 ) )
	cCidEntr := AllTrim( SA1->A1_MUN ) + ' - ' + SA1->A1_EST
	cSegmento:= SA1->A1_GRPSEG
Else

	SA2->( dbSeek( xFilial( 'SA2' ) + SC5->C5_CLIENTE + SC5->C5_LOJACLI, .F. ) )

	If SA2->A2_ESTRATG = 'S'

		SZZ->( dbSetOrder( 1 ) )
		SZZ->( dbSeek( xFilial( 'SZZ' ) + SC5->C5_CLIENTE + SC5->C5_LOJACLI, .F. ) )
	EndIf

	cCliente := SA2->A2_COD + '/' + SA2->A2_LOJA + ' ' + If( SA2->A2_ESTRATG = 'S', SZZ->ZZ_NOME, SA2->A2_NOME )
	cEndFatu := AllTrim( If( SA2->A2_ESTRATG = 'S', SZZ->ZZ_END, SA2->A2_END ) )
	cCidFatu := AllTrim( If( SA2->A2_ESTRATG = 'S', SZZ->ZZ_MUN, SA2->A2_MUN ) ) + ' - ' + SA2->A2_EST
	cEndEntr := AllTrim( If( SA2->A2_ESTRATG = 'S', SZZ->ZZ_END, SA2->A2_END ) )
	cCidEntr := AllTrim( If( SA2->A2_ESTRATG = 'S', SZZ->ZZ_MUN, SA2->A2_MUN ) ) + ' - ' + SA2->A2_EST

EndIf

cDescSeg=SF4->(cRetset(cSegmento))
SE4->( dbSeek( xFilial( 'SE4' ) + SC5->C5_CONDPAG, .F. ) ) ; cDescCondpg := Alltrim( SE4->E4_DESCRI)

If SC5->C5_PEDGUIA=='1'
  lTemGuia:=.T.
Endif

//Inserido por Edivaldo Gonçalves Cordeiro

If !Empty(SC5->C5_NUMSUA) .AND. cCliImdepa = SC5->C5_CLIENTE
	@ pRow()+1,000 pSay '**PEDIDO ALOCADO**'
	@ pRow()+2,000 pSay 'Pedido No.........: ' + SC5->C5_NUM
Else
	@ pRow()+1,000 pSay 'Pedido No.........: ' + SC5->C5_NUM
Endif

@ pRow()  ,050 pSay 'Emissao: ' + DtoC( SC5->C5_EMISSAO )
@ pRow()  ,078 pSay AllTrim(SC5->C5_TIPFAT)

If MV_PAR01 = 1
	@ pRow(),079 pSay 'R'
EndIf

If !Empty(SC5->C5_OCCLI)
 @ pRow()+1,000 pSay 'Ordem de Compra...: '
Endif

@ pRow()+1,000 pSay 'Cliente...........: ' + cCliente
@ pRow()+1,000 pSay 'Endereco Fatura...: ' + cEndFatu
@ pRow()+1,000 pSay 'Cidade   Fatura...: ' + cCidFatu
@ pRow()+1,000 pSay 'Endereco Entrega..: ' + cEndEntr
@ pRow()+1,000 pSay 'Cidade   Entrega..: ' + cCidEntr
@ pRow()  ,053 pSay 'Origem.: 0 - Nacional'
@ pRow()+1,062 pSay '1 - Importado'
@ pRow()+1,000 pSay 'Representante.....: ' + cNomeVend2
@ pRow()  ,062 pSay '2 - Nacionalizado'
@ pRow()+1,000 pSay 'Vendedor Interno..: ' + cNomeVend1
@ pRow()  ,053 pSay 'Tipo Frete .: '+IIF(SC5->C5_TPFRETE='2','1','2')
@ pRow()+1,000 pSay 'Transportadora....: ' +Substr(Alltrim( SA4->A4_NOME ),1,26)
@ pRow()  ,053 pSay 'R$ Frete .: '+Transform(SUA->UA_FRETE,"@E 999,999.99")

//@ 13,000 PSay 'Condicoes Pgto....: '+cConPgto
@ pRow()+2,000 PSay 'Condicoes Pgto....: '+cDescCondpg

If lTemGuia
 @ pRow()+2,053 pSay '**Pedido com GUIA**'
Endif


@ pRow()+1,000 pSay 'Segmento..........: **'+cSegmento+'/'+cDescSeg+'**'

If !Empty(SUA->UA_OBSEXP)
  @ pRow()+2,000 pSay 'Observacao........: ' + Substr( SUA->UA_OBSEXP, 01, 45 )
  @ pRow()+1,000 pSay '                    ' + Substr( SUA->UA_OBSEXP, 46, 45 )
Endif


@ pRow()+1, 000 pSay __PrtFatLine()


//@ pRow()+1,000 pSay 'Endereço |  Qtd    | Codigo | Descrição                |Marca|Or|UM| Peso_Un '
//@ pRow()+1,000 pSay 'Endereço    Qtd      Codigo   Descrição                 Marca Or UM  Peso_Un '
@ pRow()+1,000 pSay 'Endereço    Qtd      Codigo           Descrição            Marca Or UM  Peso_Un '

@ pRow()+1, 000 pSay __PrtThinLine()

Return

Static Function MarcaPV(aPedidos)
Local lSair      := .T.
Local nStart

/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄxäZ¿
//³Atualiza informações de impressão do pedido de separação³
//³Edivaldo Gonçalves Cordeiro em 29/10/06                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄxäZÙ
ENDDOC*/

If lImpresso
	If MsgYesNo('Marca os Pedidos como ja Impressos?')
	  Begin Transaction
		For nStart := 1 To Len(aPedidos)

			cSql := " UPDATE "+RetSqlName('SC6') //grava status de ja impresso
			cSql += " SET C6_IMPEMB = 'S' WHERE C6_FILIAL= '" + xFilial( 'SC6' ) + "'"
			cSql += " AND C6_NUM = '"+aPedidos[nStart,3]+"'"
			cSql += " AND D_E_L_E_T_<>'*'"
			TCSQLExec( cSql )
			TCSQLExec('COMMIT')


			cSql := " UPDATE "+RetSqlName('SC9') //grava status de ja impresso
			cSql += " SET C9_DTPSEP ='"+Dtos(Date())+"'"
			cSql += ",C9_HRPSEP='"+Strtran(Left(Time(),5),":","")+"'"
			cSql += ",C9_USRPSEP='"+SubStr( cUsuario, 7, 15 )+"'"
			cSql += " WHERE C9_FILIAL= '" + xFilial( 'SC9' ) + "'"
			cSql += " AND C9_PEDIDO = '"+aPedidos[nStart,3]+"'"
			cSql += " AND D_E_L_E_T_<>'*'"
			TCSQLExec( cSql )
			TCSQLExec('COMMIT')

		Next i
	End Transaction
 Endif

Else
	If MsgYesNo('Os Pedidos nao foram Impressos! Sair assim mesmo?')
		lSair := .T.
	Else
		lSair := .F.
	Endif

Endif

Return(lSair)



Static Function chekReabastAuto(cNumPed,cItemProd)

Local lRet:=.F.

cQuery := " SELECT DCF_DOCORI "
cQuery += " FROM "+ RetSqlName( 'DCF' ) + " DCF "
cQuery += " WHERE DCF_FILIAL = '" + xFilial( 'DCF' ) + "'"
cQuery += " AND DCF_DOCORI='"+cNumPed+ "'"
cQuery += " AND DCF_CODPRO='"+cItemProd+"'"
cQuery += " AND DCF_SERVIC='005'
cQuery += " AND D_E_L_E_T_ = ' '"

If Select('DCFTMP') <> 0
    DCFTMP->( DbCLoseArea() )
Endif

dbUseArea( .T., 'TOPCONN', TCGenQry(,,cQuery), 'DCFTMP', .F., .T. )

DCFTMP->( DBGOTOP())

If DCFTMP->( !Eof() )
	//Item de Pedido gerou reabastecimento
	lRet:=.T.
Endif

Return lRet



Static Function cRetset(cSeg)

Local cRetseg:=' '

cQuery := " SELECT ZZV_DESC "
cQuery += " FROM "+ RetSqlName( 'ZZV' ) + " ZZV "
cQuery += " WHERE ZZV_FILIAL = '" + xFilial( 'ZZV' ) + "'"
cQuery += " AND ZZV_COD='"+cSeg+ "'"
cQuery += " AND D_E_L_E_T_ = ' '"

If Select('ZZVTMP') <> 0
    ZZVTMP->( DbCLoseArea() )
Endif

dbUseArea( .T., 'TOPCONN', TCGenQry(,,cQuery), 'ZZVTMP', .F., .T. )

ZZVTMP->( DBGOTOP())

If DCFTMP->( !Eof() )

	cRetseg=Alltrim(ZZVTMP->ZZV_DESC)
Endif

Return(cRetseg)