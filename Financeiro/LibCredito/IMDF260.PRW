//#include 'fivewin.ch'
#include "Totvs.ch"
#include 'rwmake.ch'
#include 'FONT.CH'
#include 'COLORS.CH'
#include "AP5MAIL.CH"
#DEFINE CRLF (CHR(13)+CHR(10))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMDF260   ºAutor  ³Luciano Corrêa      º Data ³  08/18/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Liberacao de Credito                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*********************************************************************
User Function ImdF260()
*********************************************************************
Private cArq					// arquivo de trabalho
Private bFiltraBrw := {|| Nil}	// variavel utilizada na liberacao de credito manual
Private aFields   :=  {{ 'OK'		,, ''                , ''                  },;
{ 'CSTATUS'	,, 'Status'          , ''                  }, ;
{ 'MOTIVO'	,, 'Motivo'          , ''                  }, ;
{ 'DESCFIL' ,, 'Filial'          , ''                  }, ;
{ 'NUM'     ,, 'Pedido'          , ''                  }, ;
{ 'CLIENTE' ,, 'Cliente'         , ''                  }, ;
{ 'LOJACLI' ,, 'Loja'            , ''                  }, ;
{ 'NOMECLI' ,, 'Nome Cliente'    , ''                  }, ;
{ 'EMISSAO' ,, 'Emissao'         , ''                  }, ;
{ 'VALTOT'  ,, 'Valor Total'     , '@E 9,999,999.99'   }, ;
{ 'DESCOND' ,, 'Cond Pagto'      , ''                  }, ;
{ 'VENC'    ,, 'Titulos Vencidos', '@E 9,999,999.99'   }, ;
{ 'AVENC'   ,, 'Titulos a Vencer', '@E 9,999,999.99'   }, ;
{ 'NOMEOPER',, 'Operador'        , ''                  }, ;
{ 'BANCO'   ,, 'Banco'           , ''                  }, ;
{ 'MENNOTA' ,, 'Obs. p/NF'       , ''                  } }

Private lMarca    := .f.
Private cMarca    := GetMark()
Private cCadastro := 'Liberação de Crédito'
Private aRotina   :=  {	{ 'Atualizar  ', 'U_ImdF261' 	, 0, 0 },;
{ 'Automatica ', 'U_ImdF263' 	, 0, 0 },;
{ 'Manual     ', 'U_ImdF262' 	, 0, 0 },;
{ 'Rastrear   ', 'u_RastreiaPv' , 0, 0 },;
{ 'Analisar   ', 'U_ImdF264(1)' , 0, 0 },;
{ 'Rejeitar   ', 'U_ImdF264(9)' , 0, 0 }}

If Select( 'TRB' ) # 0		// se jah existe alguma area trb aberta, fecha
	TRB->( dbCloseArea() )
EndIf

If !U_ImdF261()			// chama funcao para selecionar pedidos
	Return()			// retorna .f. se cancelou a selecao
EndIf

DbSelectArea( 'TRB' )

MarkBrow( 'TRB', 'OK',, aFields, lMarca, cMarca )

TRB->( dbCloseArea() )
fErase( cArq + '.DBF' )
fErase( cArq + '.CDX' )

Return()
*********************************************************************
User Function ImdF261() //| Liberacao de Credito - Atualizar
*********************************************************************
Private lSucesso := .f.

Processa( {|| RunProc() }, cCadastro, 'Selecionando pedidos...' )

Return lSucesso
*********************************************************************
Static Function RunProc()//| Liberacao de Credito - Atualizar
*********************************************************************
Local nRec_SM0
Local cFilImd := ""
Local cUltCli := "ZZZZZZ"
Local nVenc   := 0
Local nAVenc  := 0
Private cQuery

// verifica as filiais cadastradas
nRec_SM0 := SM0->( RecNo() )

SM0->( dbSeek( cEmpAnt, .f. ) )

While SM0->( !EOF() ) .and. SM0->M0_CODIGO == cEmpAnt

	cFilImd += "'" + SM0->M0_CODFIL + "',"

	SM0->( dbSkip() )
End

cFilImd := SubStr( cFilImd, 1, Len( cFilImd ) - 1 )

SM0->( dbGoTo( nRec_SM0 ) )

If Select( 'TRB' ) == 0		// se jah nao criou o arquivo trb, cria

	MsAguarde( {|| RunProc1() }, cCadastro, 'Gerando arquivo de trabalho...' )

EndIf

If TRB->( LastRec() ) > 0	// limpa arquivo de trabalho

	DbSelectArea( 'TRB' )
	Zap

EndIf

//|chamado:AAZV30
cQuery := ""
cQuery += "SELECT "
cQuery += "		SC5.C5_FILIAL	,  "
cQuery += "		AC9.C9_MOTIVO MOTIVO,  "
cQuery += "		SC5.C5_NUM		,  "
cQuery += "		SC5.C5_CLIENTE,  "
cQuery += "		SC5.C5_LOJACLI,  "
cQuery += "		SC5.C5_STATUS	, "
cQuery += "		SUM( SC6.C6_VALOR ) VALTOT "

cQuery += "FROM SC6010 SC6, "
cQuery += "		(	SELECT C9_FILIAL, C9_PEDIDO, MIN(C9_BLCRED) C9_MOTIVO "
cQuery += "			FROM SC9010 "
cQuery += "			WHERE C9_SERIENF = ' ' "
cQuery += "			AND   C9_NFISCAL = ' ' "
cQuery += " 		AND   C9_BLCRED NOT IN ( '10', '  ' )"
cQuery += "			AND   D_E_L_E_T_  = ' '  "
cQuery += "			GROUP BY   C9_FILIAL,C9_PEDIDO "
cQuery += "		 ) AC9, "
cQuery += "		 SC5010 SC5 "

cQuery += "WHERE SC6.C6_FILIAL = C9_FILIAL "
cQuery += "AND   SC6.C6_NUM    = C9_PEDIDO "
cQuery += "AND   SC6.D_E_L_E_T_ = ' ' "
cQuery += "AND   SC5.C5_FILIAL = C9_FILIAL "
cQuery += "AND   SC5.C5_NUM    = C9_PEDIDO "
cQuery += "AND 	 SC5.C5_EMISSAO >=  '"+DTOS(ddatabase - 360)+"'" "
cQuery += "AND 	 SC5.D_E_L_E_T_ = ' ' "

cQuery += "GROUP BY SC5.C5_FILIAL,AC9.C9_MOTIVO,SC5.C5_NUM,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC5.C5_STATUS "
cQuery += "ORDER BY C5_FILIAL,C5_CLIENTE, C5_LOJACLI DESC "
;
/*
cQuery := " SELECT C5_FILIAL, MIN(C9_BLCRED) MOTIVO, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_STATUS,C9_SEQUEN,   SUM( C6_QTDVEN* C6_PRCACRE  ) VALTOT"
cQuery += " FROM " + RETSQLNAME( 'SC5' ) + " SC5, " + RETSQLNAME( 'SC6' ) + " SC6,"  + RETSQLNAME( 'SC9' ) + " SC9"
cQuery += " WHERE C5_FILIAL IN (" + CFILIMD + ")"
cQuery += " and C5_EMISSAO >= '" + DTOS(ddatabase - 360) + "'"
cQuery += " AND C5_NUM = C6_NUM "
cQuery += " AND SC5.D_E_L_E_T_ <> '*'"
cQuery += " AND C9_FILIAL = SC6.C6_FILIAL"
cQuery += " AND C9_PEDIDO = SC6.C6_NUM"
cQuery += " AND C9_ITEM = SC6.C6_ITEM"
cQuery += " AND C9_SERIENF = ' '"
cQuery += " AND C9_NFISCAL = ' '"
cQuery += " AND C9_BLCRED IN ( '01', '04', '09')"
cQuery += " AND SC9.D_E_L_E_T_ <> '*' "
cQuery += " AND C6_FILIAL = C5_FILIAL"
cQuery += " AND SC6.D_E_L_E_T_ <> '*'"
cQuery += " GROUP BY C5_FILIAL, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_STATUS, C9_SEQUEN"
cQuery += " ORDER BY C5_FILIAL,C5_CLIENTE, C5_LOJACLI DESC"
*/

//| Fim Chamado AAZV30


MEMOWRIT( "c:\sqlsiga\imdf260(lib_credito_imdt)_sc5tmp.txt", cQuery)

dbUseArea( .t., 'TOPCONN', TCGenQry( ,, cQuery ), 'SC5TMP', .t., .t. )

TCSetField( 'SC5TMP', 'VALTOT'    , 'N', 14, 2 )

SA1->( dbSetOrder( 1 ) )
SC6->( dbSetOrder( 1 ) )
SC5->( dbSetOrder( 1 ) )
SE4->( dbSetOrder( 1 ) )
SU7->( dbSetOrder( 1 ) )

SC5TMP->( dbGoTop() )

While SC5TMP->( !Eof() )

	// Executo esta verificacao para incluir na tabela somente um registro do
	// pedido a ser somado. By Jeferson 19/10/2004.

 //	If SC5TMP->C9_SEQUEN <> '01'
//		SC5TMP->( DbSkip() );Loop
//	Endif

	SC5->( dbSeek( SC5TMP->C5_FILIAL + SC5TMP->C5_NUM, .f. ) )
	SA1->( dbSeek( '  ' + SC5->C5_CLIENTE + SC5->C5_LOJACLI, .f. ) )
	SE4->( dbSeek( '  ' + SC5->C5_CONDPAG, .f. ) )
	SU7->( dbSeek( '  ' + SC5->C5_OPERADO, .f. ) )

	If cUltCli <> ( SC5->C5_CLIENTE + SC5->C5_LOJACLI )

		cQuery := "select sum( VENC ) VENC, sum( AVENC ) AVENC"
		cQuery += " from ("
		cQuery += " select sum( E1_SALDO ) VENC, 0 AVENC"
		cQuery += "  from " + RetSqlName( 'SE1' ) + " SE1"
		cQuery += "  where E1_FILIAL = '  '"
		cQuery += "  and E1_CLIENTE = '" + SC5->C5_CLIENTE + "'"
		cQuery += "  and E1_LOJA = '" + SC5->C5_LOJACLI + "'"
		cQuery += "  and E1_VENCREA >= '" + DTOS(ddatabase - 360) + "'"
		cQuery += "  and E1_VENCREA <  '" + DtoS( dDataBase ) + "'"
		cQuery += "  and E1_SALDO > 0"
		cQuery += "  and E1_TIPO not in ( '" + MVRECANT + "', '" + MVPROVIS + "', '" + MV_CRNEG + "' )"
		cQuery += "  and E1_TIPO not like '__-'"
		cQuery += "  and E1_FATURA in ( ' ', 'NOTFAT' )"
		cQuery += "  and SE1.D_E_L_E_T_ <> '*'"
		cQuery += " union all"
		cQuery += " select 0 VENC, sum( E1_SALDO ) AVENC"
		cQuery += "  from " + RetSqlName( 'SE1' ) + " SE1"
		cQuery += "  where E1_FILIAL = '  '"
		cQuery += "  and E1_CLIENTE = '" + SC5->C5_CLIENTE + "'"
		cQuery += "  and E1_LOJA = '" + SC5->C5_LOJACLI + "'"
		cQuery += "  and E1_VENCREA >= '" + DtoS( dDataBase ) + "'"
		cQuery += "  and E1_SALDO > 0"
		cQuery += "  and E1_TIPO not in ( '" + MVRECANT + "', '" + MVPROVIS + "', '" + MV_CRNEG + "' )"
		cQuery += "  and E1_TIPO not like '__-'"
		cQuery += "  and E1_FATURA in ( ' ', 'NOTFAT' )"
		cQuery += "  and SE1.D_E_L_E_T_ <> '*'"
		cQuery += " )"

		MEMOWRIT("c:\SQLSIGA\imdf260(lib_credito_imdt)_se1tmp.txt", cQuery)
		dbUseArea( .t., 'TOPCONN', TCGenQry( ,, cQuery ), 'SE1TMP', .t., .t. )

		TCSetField( 'SE1TMP', 'VENC'      , 'N', 14, 2 )
		TCSetField( 'SE1TMP', 'AVENC'     , 'N', 14, 2 )

		nVenc  := SE1TMP->VENC
		nAVenc := SE1TMP->AVENC

		SE1TMP->( dbCloseArea() )

		cUltCli := SC5->C5_CLIENTE + SC5->C5_LOJACLI

	EndIf

	TRB->( dbAppend() )
	TRB->CSTATUS  := Iif(SC5TMP->C5_STATUS==" "," Pendente",(Iif(SC5TMP->C5_STATUS=="P"," Pendente","Analisando")))
	TRB->MOTIVO	  := RetMotivo(SC5TMP->MOTIVO) //Iif(SC5TMP->MOTIVO=="01","Vl.Lim.Inferior",IiF(SC5TMP->MOTIVO=="04","Dt.Lim.Vencido",IiF(SC5TMP->MOTIVO=="09","Rej.Man.Cred","")))
	TRB->FILIAL   := SC5TMP->C5_FILIAL
	TRB->DESCFIL  := Posicione( 'SX5', 1, xFilial( 'SX5' ) + 'Z3' + SC5TMP->C5_FILIAL, 'X5_DESCRI' )
	TRB->NUM      := SC5TMP->C5_NUM
	TRB->CLIENTE  := SC5->C5_CLIENTE
	TRB->LOJACLI  := SC5->C5_LOJACLI
	TRB->NOMECLI  := SA1->A1_NOME
	TRB->EMISSAO  := SC5->C5_EMISSAO
	TRB->VALTOT   := SC5TMP->VALTOT + SC5->C5_FRETE + SC5->C5_SEGURO + SC5->C5_DESPESA + SC5->C5_FRETAUT
	TRB->DESCOND  := SE4->E4_DESCRI
	TRB->NOMEOPER := SU7->U7_NOME
	TRB->BANCO    := SA1->A1_BCO1
	TRB->MENNOTA  := SC5->C5_MENNOTA
	TRB->VENC     := nVenc
	TRB->AVENC    := nAVenc

	SC5TMP->( dbSkip() )

EndDo

SC5TMP->( dbCloseArea() )

TRB->( dbGoTop() )

lSucesso := .t.

Return
*********************************************************************
Static Function RunProc1()//| Liberacao de Credito - Atualizar
*********************************************************************
cArq := CriaTrab( { { 'CSTATUS'  , 'C',  15, 0 },;
{ 'MOTIVO'  , 'C',  15, 0 }, ;
{ 'FILIAL'  , 'C',  2, 0 }, ;
{ 'DESCFIL' , 'C',  3, 0 }, ;
{ 'NUM'     , 'C',  6, 0 }, ;
{ 'CLIENTE' , 'C',  6, 0 }, ;
{ 'LOJACLI' , 'C',  2, 0 }, ;
{ 'NOMECLI' , 'C', 40, 0 }, ;
{ 'EMISSAO' , 'D',  8, 0 }, ;
{ 'VALTOT'  , 'N', 14, 2 }, ;
{ 'DESCOND' , 'C', 30, 0 }, ;
{ 'NOMEOPER', 'C', 30, 0 }, ;
{ 'BANCO'   , 'C',  3, 0 }, ;
{ 'MENNOTA' , 'C', 60, 0 }, ;
{ 'VENC'    , 'N', 14, 2 }, ;
{ 'AVENC'   , 'N', 14, 2 }, ;
{ 'OK'      , 'C',  2, 0 } }, .t. )

dbUseArea( .t., , cArq, 'TRB', .f. )

//cindice1 := 'DESCEND(CSTATUS)+DESCFIL+NUM'
cindice1 := 'CSTATUS+DESCFIL+NUM'
//INDEX ON Placa + DTOS(Dt_Abast) + H_Abast TAG XDecre DESCEND TO &WChave

//Index On &cindice1. TAG 1 DESCEND TO &cArq.  //mostra erro que a funcao descend nao he suportado em CTREE

Index On &cindice1. TAG 1 TO &cArq.  //ajustado na linha 249 para colocar espaço em branco antes de PROCESSA

//dbCreateIndex( cArq, 'DESCEND(CSTATUS)+DESCFIL+NUM', { || DESCEND(CSTATUS)+DESCFIL+NUM } )

Return
*********************************************************************
User Function ImdF263()//|Liberacao de Credito - Liberacao Automatica
*********************************************************************
Local cFilLiber		:= cFilAnt
Local aArea     	:= GetArea()
Local lContinua 	:= .T.
Local lAvCred 		:= .T. //| Avalia Credito
Local lAvEst		:= .T. //| Avalia Estoque
Local lEnd			:= .F. //|
Local lEmpresa		:= .T. //| .T. Avalia Empresa, .F. Avalia Filial
Local lAvWMS		:= .T. //| Avalia WMS
Local cPerg     	:= "LIBAT2"
Local cAlias		:= "SC9"
Private lIf260Can


dbSelectArea( 'TRB' )
dbGoTop()

While !eof()

	If !Marked( 'OK' )
		dbSkip()
		Loop
	EndIf

	// altera filial...
	If cFilAnt # TRB->FILIAL .And. !Empty( TRB->FILIAL )
		cFilAnt := TRB->FILIAL
	EndIf

	Pergunte(cPerg,.F.)
	MV_PAR01 := TRB->NUM
	MV_PAR02 := TRB->NUM //| Pedido ate ?
	MV_PAR03 := "      " //(06)TRB->CLIENTE //| Cliente de ?
	MV_PAR04 := "ZZZZZZ" //TRB->CLIENTE //| Cliente ate ?
	MV_PAR05 := (dDataBase - 365) //| Data de Entrega de ?
	MV_PAR06 := (dDataBase + 365) //| Data de Entrega ate ?
	MV_PAR07 := 2 //| Quanto ao Estoque ?

	Processa({|lEnd| Ma450Processa(cAlias,lAvCred,lAvEst,@lEnd,lEmpresa,lAvWMS)},,,.T.)

	dbSelectArea( 'TRB' )
	dbSkip()

EndDo

cFilAnt := cFilLiber

RestArea( aArea )

U_ImdF261()

Return()

//|RestArea(aArea)

Return()
*********************************************************************
User Function ImdF262() //|Liberacao de Credito - Liberacao Manual
*********************************************************************
Local cFilLiber		:= cFilAnt
Local aArea     	:= GetArea()
Local lContinua 	:= .T.
Local aAreaSC9

Private lIf260Can

mv_par01 := 1

SC9->( dbSetOrder( 1 ) )

dbSelectArea( 'TRB' )
//ProcRegua( LastRec() )
dbGoTop()

While !eof()

	If !Marked( 'OK' )
		dbSkip()
		Loop
	EndIf

	// altera filial...
	If cFilAnt # TRB->FILIAL .and. !Empty( TRB->FILIAL )
		cFilAnt := TRB->FILIAL
	EndIf

	SC9->( dbSeek( TRB->FILIAL + TRB->NUM, .f. ) )
	While SC9->( !Eof() ) .and. SC9->C9_FILIAL == TRB->FILIAL ;
		.and. SC9->C9_PEDIDO == TRB->NUM

		If SC9->C9_BLCRED <> '10' .And. SC9->C9_BLCRED <> '  '

			aAreaSC9  := SC9->( GetArea() )

			lIf260Can := .T.

			lContinua := A450LibMan()

			SC9->( RestArea( aAreaSC9 ) )

			If !lContinua .or. lIf260Can
				Exit
			EndIf
		EndIf

		SC9->( dbSkip() )
	End

	If !lContinua
		Exit
	EndIf

	dbSelectArea( 'TRB' )
	dbSkip()

Enddo

// retorna filial atual do sistema...
cFilAnt := cFilLiber

RestArea( aArea )

U_ImdF261()

Return()
*********************************************************************
User Function Imdf264(nOpc)//|Liberacao de Credito - Analizar/Rejeitar
*********************************************************************
Local cFilLiber		:= cFilAnt
Local aArea     	:= GetArea()
Local lContinua 	:= .T.

MV_PAR01 := 1


SC5->( dbSetOrder( 1 ) )

DbSelectArea( 'TRB' );DbGoTop()
While !Eof()

	If !Marked( 'OK' )
		DbSkip()
		Loop
	EndIf

	If cFilAnt # TRB->FILIAL .And. !Empty( TRB->FILIAL )
		cFilAnt := TRB->FILIAL
	EndIf

	SC5->( DbSeek( TRB->FILIAL + TRB->NUM, .F.) )

	While 	SC5->( !Eof() ) .And. SC5->C5_FILIAL == TRB->FILIAL .And. SC5->C5_NUM == TRB->NUM

		U_Imdf269(nOpc)

		SC5->( dbSkip() )

	EndDo

	If !lContinua
		Exit
	EndIf

	DbSelectArea( 'TRB' )
	DbSkip()

EndDo

cFilAnt := cFilLiber

RestArea( aArea )

U_ImdF261()

Return()
*********************************************************************
User Function Imdf269(nOpc)//|Liberacao de Credito - Monta Tela
*********************************************************************
Private oDialog
Private oTextA
Private oTextB
Private oCombo
Private oMemo
Private oButomA
Private oButomB
Private cTitulo	:= "Pedido: "+TRB->NUM+" Cliente: "+TRB->CLIENTE +" - "+TRB->NOMECLI
Private lFecha 	:= .F.
Private cCombo	:= IiF(!Empty(SC5->C5_MOTFIN),SC5->C5_MOTFIN,Space(3))
Private cMemo 	:= IiF(!Empty(SC5->C5_OBSFIN),SC5->C5_OBSFIN,Space(500))
Private aItens 	:= FCarSx5()

DbSelectArea("SUA");DbSetOrder( 1 )
DbSelectArea("SU7");DbSetOrder( 1 )
DbSelectArea("SA3");DbSetOrder( 1 )
DbSelectArea("SA1");DbSetOrder( 1 )
DbSelectArea("SC9");DbSetOrder( 1 )
DbSelectArea("SC6");DbSetOrder( 1 )
DbSelectArea("SC5");DbSetOrder( 1 )
DbSelectArea("SUA");DbSetOrder( 1 )
DbSelectArea("SUA");DbSetOrder( 1 )

oDialog	:= MSDialog		():New( 090 ,230 ,450 ,630 , cTitulo ,,,.F. ,,,,,,.T. ,,,.T. )
oTextA  := TSay			():New( 016 ,012 ,{||"Escolha o Motivo:"} ,oDialog ,,,.F. ,.F. ,.F. ,.T. ,CLR_BLACK ,CLR_WHITE ,048 ,008 )
oTextB  := TSay			():New( 032 ,012 ,{||"Observação:"},oDialog ,,,.F. ,.F. ,.F. ,.T. ,CLR_BLACK ,CLR_WHITE ,032 ,008 )
oCombo  := TComboBox	():New( 014 ,064 ,{|U|if(PCount() > 0 ,cCombo := U ,cCombo)} ,aItens  ,124 ,010 ,oDialog ,,,,CLR_BLACK ,CLR_WHITE ,.T. ,,"" ,,,,,,, )
oMemo   := TMultiGet	():New( 044 ,012 ,{|U|if(PCount() > 0 ,cMemo  := U ,cMemo )} ,oDialog ,180 ,096 ,,,CLR_BLACK ,CLR_WHITE ,,.T. ,"" ,,,.F. ,.F. ,.F. ,,,.F. ,, )
oButomA	:= TButton		():New( 150 ,050 ,"OK" ,oDialog ,{||Valida() , Iif( lFecha , { MsgBox("Gravado com Sucesso!!"), oDialog:End() , FAtuPed(nOpc) } , MsgBox("Preencher os Dados!!!")  )  },037 ,012 ,,,,.T. ,,"" ,,,,.F. )
oButomB	:= TButton		():New( 150 ,120 ,"Cancela" ,oDialog ,{||oDialog:End()} ,037 ,012 ,,,,.T. ,,"" ,,,,.F. )

oDialog:Activate(,,,.T.)

Return()
*********************************************************************
Static Function FAtuPed(nOpc)//|Liberacao de Credito - Monta Tela
*********************************************************************

If nOpc == 1 //Analizar

	DbSelectArea("SC5")
	Reclock("SC5",.F.)
	SC5->C5_OBSFIN := cMemo + CRLF +Substr(cUsuario,1,15) + " " + Dtoc(Ddatabase) + " " +Time()
	SC5->C5_STATUS := "A"
	SC5->C5_MOTFIN := cCombo
	MsUnlock()

	DbSelectArea("TRB")
	Reclock("TRB",.F.)
	TRB->CSTATUS := "A"
	MsUnlock()

ElseIf nOpc == 9//Rejeitar

	DbSelectArea("SC5")
	Reclock("SC5",.F.)
	SC5->C5_OBSFIN 	:= cMemo + CRLF +Substr(cUsuario,1,15) + " " + Dtoc(Ddatabase) + " " +Time()
	SC5->C5_STATUS 	:= "P"
	SC5->C5_MOTFIN 	:= cCombo
	SC5->C5_LIBEROK := ""
	SC5->C5_LIBERAD := ""
	MsUnlock()

	DbSelectArea("SC6");DbSeek( TRB->FILIAL + TRB->NUM ,.F.)

	While !Eof()  .and. SC6->C6_FILIAL == TRB->FILIAL 	.And. SC6->C6_NUM == TRB->NUM
		Reclock("SC6",.F.)
		SC6->C6_QTDEMP	:=	0
		MsUnlock()
		DbSelectArea("SC6")
		DbSkip()
	EndDo

	DbSelectArea("SC9");DbSeek( TRB->FILIAL + TRB->NUM ,.F.)
	While SC9->( !Eof() ) .and. SC9->C9_FILIAL == TRB->FILIAL 	.And. SC9->C9_PEDIDO == TRB->NUM
		Reclock("SC9",.F.)
		Delete
		MsUnlock()
		DbSelectArea("SC9")
		DbSkip()
	EndDo


	DbSelectarea("TRB")
	RecLock("TRB",.F.)
	Delete
	MsUnlock()

	/*
	Programa	|A460Estorna
	Parametros	³ExpL1: Indica se o programa chamador eh o MATA410
	³ExpL2: Indica se Atualizará Empenhos
	³ExpN3: Valor a ser adicionado ao limite de credito
	*/

	//|SUA->( A460Estorna(.T.,.T.,.T.) )

Endif

DispEmail(nOpc)

Return()
*********************************************************************
Static Function FCarSx5()//|Carrega Arrey com a Tabela SX5 - Z1
*********************************************************************
Local ArreySx5 := {}

DbSelectarea("Sx5")
DbSeek(xFilial("SX5")+"Z1"+"001",.F.)
While !Eof() .And. SX5->X5_TABELA == "Z1"

	Aadd(ArreySx5, Alltrim(SX5->X5_CHAVE) + "=" + Alltrim(SX5->X5_DESCRI) )
	DbSkip()
EndDo

Return(ArreySx5)
*********************************************************************
Static Function Valida()//|Liberacao de Credito - Monta Tela
*********************************************************************

IF !Empty(Alltrim(cCombo)) .And. !Empty(Alltrim(cMemo))
	lFecha := .T.
Endif

Return()
*********************************************************************
Static Function DispEmail(nOpc)
*********************************************************************
Local cEmailVen 	:= ""
Local cEmailGer 	:= ""
Local cSubject 		:= "Lib de Crédito - Pedido: " + SC5->C5_NUM + " - Cliente: " + Alltrim(TRB->NOMECLI) + " - " + Iif(nOpc==1,"Em Analise","Rejeitado")
Local cConteudo		:= ""
Local cTo 			:= ""
Local cDescMotivo 	:= ""
Local cServer  		:= GetMV('MV_RELSERV')
Local cConta   		:= GetMV('MV_RELACNT')
Local cPass    		:= GetMV('MV_RELPSW')
Local lAuth    		:= Getmv("MV_RELAUTH")

DbSelectArea("SC6")//|C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
DbSeek(SC5->C5_FILIAL + SC5->C5_NUM ,.F.)

DbSelectArea("SUA")//|UA_FILIAL+UA_NUM
DbSeek(xFilial("SUA") + Substr(SC6->C6_PEDCLI,4,6),.F.)

DbSelectArea("SU7")//|U7_FILIAL+U7_COD
DbSeek(xFilial("SU7")+SUA->UA_OPERADO,.F.)

DbSelectArea("SA3")//|A3_FILIAL+A3_COD
DbSeek(xFilial("SA3")+SU7->U7_CODVEN,.F.)

cEmailVen := Alltrim(SA3->A3_EMAIL)

DbSelectArea("SA1")//|A1_FILIAL + A1_COD + A1_LOJA
DbSeek(xFilial("SA1")+SC5->C5_CLIENTE + SC5->C5_LOJAENT,.F.)

DbSelectArea("SA3")//|A3_FILIAL+A3_COD
DbSeek(xFilial("SA3") + SA1->A1_GERVEN ,.F.)

cEmailGer := Alltrim(SA3->A3_EMAIL)

DbSelectArea("SA3")//|A3_FILIAL+A3_COD
If DbSeek(xFilial("SA3") + SA1->A1_VENDEXT ,.F.)

	cEmailVen := Iif(cEmailVen == Alltrim(SA3->A3_EMAIL), cEmailVen, cEmailVen + "," + Alltrim(SA3->A3_EMAIL) )

Endif

DbSelectArea("SX5")
DbSeek(xFilial("SX5")+"Z1"+SC5->C5_MOTFIN,.F.)//| X5_FILIAL+X5_TABELA+X5_CHAVE

cDescMotivo := Alltrim(SX5->X5_DESCRI)

CONNECT SMTP SERVER cServer ACCOUNT cConta PASSWORD cPass RESULT lResult

If lResult .And. lAuth
	lResult := MailAuth(cConta,cPass)
	If !lResult
		lResult := MailAuth(cConta,cPass)
	EndIf
	If !lResult
		GET MAIL ERROR cError
		Conout("Erro de autenticacao de e-mail no job de Açao de vendas "+cError)
		Return Nil
	Endif
Else
	If !lResult
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		Conout("Erro de Conexao no envio de e-mail: "+cError)
		Return Nil
	Endif
EndIf

cConteudo	:=  CRLF + "MOTIVO: " + cDescMotivo + 	CRLF + CRLF + CRLF
cConteudo 	+= 	SC5->C5_OBSFIN
cConteudo	+=  CRLF
cTo 		:=  cEmailGer + "," + cEmailVen

SEND MAIL FROM cConta TO cTO BCC '' SUBJECT cSubject BODY cConteudo ATTACHMENT ''//cAttach

DISCONNECT SMTP SERVER

Conout("Enviando e-mail Para: "+cTo)

Return()


/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Funcao: RastreiaPv   || Autor: Edivaldo Goncalves    || Data: 20/01/09  ||
||-------------------------------------------------------------------------||
|| Descricao: System Tracker do Pedido no Financeiro                       ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function RastreiaPv()

Local aArea        := GetArea()
Local aTpLCre      := u_RetX3Box("C9_TPLCRE")
Local aTpLEst      := u_RetX3Box("C9_TPLEST")

Local  oBut1
Local  cPed 	   := Space( 6 )
Local  nOpc 	   := 0
Local  dData       :=CToD("  /  /  ")
Local  oCbxItem
Local  oComboItem  := Array(0)
Local  oDlgPesq

Private oDlg01
Private cTitle     := OemToAnsi("System Tracking do Atendimento do Cliente")
Private cAlias     := GetArea()
Private aListPed   := {}
Private oListPed
Private aListItem  := {{Space(02),Space(20),Space(20),0,'',CTod(''),ctod(''),space(8),space(15),ctod(''),space(8),space(15),'',ctod(''),space(8),space(15),'',ctod(''),space(8),space(15),ctod(''),space(8),space(15),Space(06)}}
Private oListItem

aFiliais:=aRetFIL()//Retorna as Filiais do sistema para a pesquisa dos Pedidos

For i=1 to Len(aFiliais)
	AADD(oComboItem,aFiliais[i,1]+' - '+aFiliais[i,2])
next i

Define msDialog oDlgPesq Title 'Rastrear Pedido' From 00,00 To 080,200  COLORS 0, 16777215 PIXEL

@ 010,005 Say oSay Prompt 'FILIAL' Size 025,007 OF oDlg COLORS 0,16777215 PIXEL

@ 010,036 COMBOBOX oCbxItem  ITEMS oComboItem  SIZE 58,10 object SelModulo

@ 025,005 Say oSay Prompt 'Nº PEDIDO ' Size 025,007 OF oDlg COLORS 0,16777215 PIXEL

@ 22,036 msGet cPed  Of oDlgPesq Pixel Size 30,10

Define sButton oBut1 From 22,67 Type 01 Enable Of oDlgPesq Pixel Action ( nOpc := 1, oDlgPesq:End())

Activate msDialog oDlgPesq Center

If  !Empty( cPed )

	cFilSel:=ALLTRIM(SUBSTR(oCbxItem,1,2))//Filial selecionada pelo perador

	DbSelectArea("SC5")
	DbSetOrder(1)
	If !DbSeek(cFilSel+Alltrim(cPed))
		IW_MsgBox(Oemtoansi("O sistema não localizou este pedido no sistema."+CHR(10)+CHR(13)+"Verifique se digitou corretamente o numero do pedido e tente novamente"),'Atenção','ALERT')
		Return
	Endif

	DbSelectArea("SUA")
	DbSetorder(1)
	If !DbSeek(cFilSel+ SC5->C5_NUMSUA)
		IW_MsgBox(Oemtoansi("Este pedido não foi gerado a partir do Call Center ou houve um erro na gravação."),'Atenção','ALERT')
		Return(.T.)
	Endif

	If Empty(UA_NUMSC5)  // O Atendimento nao transformou-se em pedido de venda.
		MsgInfo("Atendimento nao esta em Pedido de Venda")
		Return(.T.)
	Endif

	DEFINE MSDIALOG oDlg01 TITLE cTitle FROM 001,001 TO 470,1012 PIXEL OF oMainWnd

	oFolder := TFolder():New(1,1,{"Pedido","Itens"},{},oDlg01,,,,.T.,.F.,503,236)

	//***************************************************************************************************************\\
	//***************************************************************************************************************\\
	//Procedimento para o folder de Pedido
	//***************************************************************************************************************\\
	//***************************************************************************************************************\\
	@ 200,430 Button OemToAnsi("Ok") Size 036,018 of oFolder:aDialogs[1] PIXEL Action(oDlg01:End())

	@ 005,004  LISTBOX oListPed 		 ;
	FIELDS HEADER ;
	"Pedido" 						,;
	"Cliente"         				,;
	"Data Chamado"				    ,;
	"Data Pedido"   				,;
	"Data Entrega"       		    ,;
	"Nota Fiscal"                   ,;
	"Data Fatura"                   ,;
	"Hora Fatura"                    ;
	SIZE 495,192 of oFolder:aDialogs[1] PIXEL

	DbSelectArea("SC5")
	DbSetOrder(1)
	DbSeek(cFilSel+SUA->UA_NUMSC5)

	If !Empty(SC5->C5_NOTA)
		DbSelectArea("SF2")
		DbSetOrder(1)
		DbSeek(cFilSel+SC5->C5_NOTA+SC5->C5_SERIE)
		cHora:=F2_HORA
		dData:=F2_EMISSAO
	Else
		cHora:=' '
		dData:=Ctod('//')
	Endif

	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+SUA->UA_CLIENTE+SUA->UA_LOJA)

	dAuxFat:=Ctod('//')
	dAuxEnt:=Ctod('//')
	DbSelectArea("SC6")
	DbSetOrder(1)
	DbSeek(cFilSel+SUA->UA_NUMSC5)
	While !Eof() .And. cFilSel+SUA->UA_NUMSC5 = C6_FILIAL+C6_NUM
		dAuxFat:=If(C6_DATFAT>dAuxEnt,C6_DATFAT,dAuxEnt)
		dAuxEnt:=If(C6_ENTREG>dAuxEnt,C6_ENTREG,dAuxEnt)
		DbSkip()
	End

	AADD(aListPed,{SUA->UA_NUMSC5,SA1->A1_NOME,SUA->UA_EMISSAO,SC5->C5_EMISSAO,dAuxEnt,SC5->C5_NOTA,dData,cHora})

	oListPed:SetArray(aListPed)
	oListPed:bLine:={||{aListPed[oListPed:nAt,1],;
	aListPed[oListPed:nAt,2],;
	aListPed[oListPed:nAt,3],;
	aListPed[oListPed:nAt,4],;
	aListPed[oListPed:nAt,5],;
	aListPed[oListPed:nAt,6],;
	aListPed[oListPed:nAt,7],;
	aListPed[oListPed:nAt,8]}}
	oListPed:Refresh()

	//***************************************************************************************************************\\
	//***************************************************************************************************************\\
	//Procedimento para o folder de Itens
	//***************************************************************************************************************\\
	//***************************************************************************************************************\\

	@ 200,430 Button OemToAnsi("Ok") Size 036,018 of oFolder:aDialogs[2] PIXEL Action(oDlg01:End())

	@ 005,004  LISTBOX oListItem 		 ;
	FIELDS HEADER ;
	"Item"   						,;
	"Referencia"      				,;
	"Marca"       				    ,;
	"Qtd"           				,;
	"Status"                        ,;
	"Data Entrega"       		    ,;
	"Dt.Lib.Com."        		    ,;
	"Hr.Lib.Com."        		    ,;
	"Usr.Lib.Com."        		    ,;
	"Dt.Lib.Cred."        		    ,;
	"Hr.Lib.Cred."        		    ,;
	"Usr.Lib.Cred."        		    ,;
	"Tp.Lib.Cred."        		    ,;
	"Dt.Lib.Est."        		    ,;
	"Hr.Lib.Est."        		    ,;
	"Usr.Lib.Est."        		    ,;
	"Tp.Lib.Est."        		    ,;
	"Dt.Ped.Sep."        		    ,;
	"Hr.Ped.Sep."        		    ,;
	"Usr.Ped.Sep."        		    ,;
	"Dt.Ger.NF"         		    ,;
	"Hr.Ger.NF"  	     		    ,;
	"Usr.Ger.NF."        		    ,;
	"Nota Fiscal"                   ;
	SIZE 495,192 of oFolder:aDialogs[2] PIXEL

	DbSelectArea("SC5")
	DbSetOrder(1)
	DbSeek(cFilSel+SUA->UA_NUMSC5)

	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+SUA->UA_CLIENTE+SUA->UA_LOJA)

	dAuxFat:=Ctod('//')
	dAuxEnt:=Ctod('//')

	DbSelectArea('SZE')
	DbSetOrder(3)
	DbSelectArea("SC9")
	DbSetOrder(1)

	DbSelectArea("SC6")
	DbSetOrder(1)
	DbSeek(cFilSel+SUA->UA_NUMSC5)
	While !Eof() .And. cFilSel+SUA->UA_NUMSC5 = C6_FILIAL+C6_NUM

		// Verifica se o pedido de venda esta vinculado ha uma planilha
		If !Empty(C6_PLANILH)

			DbSelectArea('SZE')
			DbSeek(xFilial('SZE')+SC6->C6_PLANILH+SC6->C6_PLITEM)

			// Nf de Entrada ja processada e Pedido de Transferencia ja emitido.
			If SZE->ZE_FLAGPT = 'S' .And. SZE->ZE_FLAGNF = 'S'

				If !Empty(SC6->C6_NOTA)
					cStatus := 'Pedido de Venda ja Faturado'
				Else
					// alterado por Luciano Correa em 27/01/2004...
					DbSelectArea("SC9")
					If dbSeek(cFilSel+SC6->C6_NUM+SC6->C6_ITEM)
						If !Empty(SC9->C9_NFISCAL)
							cStatus := 'Pedido de Venda ja Faturado'
						ElseIf Empty(SC9->C9_BLEST) .And. Empty(SC9->C9_BLCRED) .And. Empty(SC9->C9_BLWMS)
							cStatus := 'Pedido de Venda Liberado Aguardando Faturamento'
						ElseIf !Empty(SC9->C9_BLCRED) .And. Empty(SC9->C9_NFISCAL)
							cStatus := 'Pedido de Venda Bloqueado por Credito'
						ElseIf !Empty(SC9->C9_BLEST) .And. Empty(SC9->C9_NFISCAL)
							cStatus := 'Pedido de Venda Bloqueado por Estoque'
						ElseIf !Empty(SC9->C9_BLWMS) .And. Empty(SC9->C9_NFISCAL)
							cStatus := 'Em Processo de Separação pelo WMS'
						Endif
					Else
						cStatus:='Pedido Aguardando Liberacao Comercial'
					Endif
				Endif
				cStatus := 'PROCESSO TRANSFERENCIA -> '+cStatus
			Else
				If !Empty(SZE->ZE_HAWB)  // Pedido de Importacao ---> Verificar Status

					DbSelectArea('SW6')
					DbSetOrder(1)
					DbSeek(xFilial('SW6')+SZE->ZE_HAWB)

					DbSelectArea('SW7')
					DbSetOrder(1)
					DbSeek(xFilial('SW7')+SZE->ZE_HAWB)

					DbSelectArea('SW2')
					DbSetOrder(1)
					DbSeek(xFilial('SW2')+SW7->W7_PO_NUM)

					cStatus := ''

					If !Empty( SW6->W6_DT_EMB )

						If Empty( SW2->W2_HAWB_DA )

							If Empty( SW6->W6_CHEG )

								cStatus := 'Produto em Transito Desde ' + DtoC( SW6->W6_DT_EMB )
							Else
								cStatus := 'Produto Atracado em ' + DtoC( SW6->W6_CHEG )
							EndIf
						Else
							cStatus := 'Produto Ag. Nacionalizacao Desde ' + DtoC( SW6->W6_DT_HAWB )
						EndIf
					EndIf

					If !Empty( SW6->W6_CHEG )

						If Empty( SW6->W6_DT ) .and. !Empty( SW6->W6_DT_AVE )

							If !( AllTrim( SW6->W6_TIPODES ) $ '2/3/4/02/03/04' )	// diferente de DA

								cStatus := 'Produto Ag. Pgto.Impostos Desde ' + DtoC( SW6->W6_DT_AVE )
							Else
								cStatus := 'Produto Ag. Declaracao de Admissao'
							EndIf
						EndIf
					EndIf

					If !Empty( SW6->W6_DT )

						If Empty( SW6->W6_DT_DESE )

							// DI
							If !( AllTrim( SW6->W6_TIPODES ) $ '2/3/4/02/03/04' ) .and. Empty( SW2->W2_HAWB_DA )

								cStatus := 'Produto Ag. Desembaraco Desde ' + DtoC( SW6->W6_DT )

								// DI NAC.
							ElseIf !( AllTrim( SW6->W6_TIPODES ) $ '2/3/4/02/03/04' ) .and. !Empty( SW2->W2_HAWB_DA )

								If !Empty( SW6->W6_DT_DESE )

									cStatus := 'Produto Ag. NAcionalizacao Desde ' + DtoC( SW6->W6_DT_DESE )
								Else
									cStatus := 'Produto Ag. NAcionalizacao Desde ' + DtoC( SW6->W6_DT )
								EndIf

								cStatus := 'Produto Ag. NAcionalizacao Desde ' + DtoC( SW6->W6_DT_HAWB )
								// DA
							Else
								cStatus := 'Produto Ag. Entrepostamento'
							EndIf
						Else
							If !( AllTrim( SW6->W6_TIPODES ) $ '2/3/4/02/03/04' )	// diferente DA

								cStatus := 'Produto Ag. Entrega'
							Else
								cStatus := 'Produto Ag. Entrepostamento'
							EndIf
						EndIf
					EndIf

					If Empty( SW6->W6_DT )

						If !Empty( SW6->W6_DTRECDO ) .and. !Empty( SW6->W6_CHEG )

							SY9->( dbSetOrder( 1 ) )
							If SY9->( dbSeek( xFilial( 'SY9' ) + SW6->W6_LOCAL, .f. ) ) .and. SY9->Y9_DAP == 'S'

								cStatus := 'Produto Mat. Ag. no DAP'
							EndIf
						EndIf
					EndIf

					If SW7->W7_FLUXO == '4'

						If !Empty( SW6->W6_DA_DT )

							cStatus := 'Produto Ag. Entrepostamento'

							If SW7->W7_QTDE <= 0
								dbSkip()
								Loop
							EndIf
						EndIf
					EndIf

					// diferente de DA
					If !( AllTrim( SW6->W6_TIPODES ) $ '2/3/4/02/03/04' ) .and. !Empty( SW6->W6_DT_ENTR ) .and. Empty( SW2->W2_HAWB_DA )
						cStatus := 'Produto Entregue Em ' + DtoC( SW6->W6_DT_ENTR )
						// DA
					ElseIf AllTrim( SW6->W6_TIPODES ) $ '2/3/4/02/03/04' .and. !Empty( SW6->W6_DT_ENTR ) .and. !Empty( SW2->W2_HAWB_DA )

						If Empty( SW6->W6_DI_NUM )
							cStatus := 'Produto Ag. Entrepostamento'
						Else
							If !Empty( SW2->W2_HAWB_DA )

								cStatus := 'Produto Entrepostado Em ' + DtoC( SW6->W6_DT_DTA )
							EndIf
						EndIf
					EndIf

					If Empty( SW6->W6_DT_EMB ) .and. Empty( cStatus ) .and. Empty( SW2->W2_HAWB_DA )
						cStatus := 'Produto Ag. Confirmacao de Embarque'
					EndIf

					cStatus := 'PROCESSO IMPORTACAO -> '+cStatus

				Else // Planilha sobre Pedido de Compra
					DbSelectArea("SC7")
					DbSetOrder(16)
					DbSeek(cFilSel+SC6->C6_PLANILH+SC6->C6_PLITEM)
					cStatus := 'Pedido de Compra Alocada no Fornecedor'
					cStatus := 'PROCESSO DE COMPRA -> '+cStatus
				Endif
			Endif
		Else

			If !Empty(SC6->C6_NOTA)
				cStatus := 'Pedido de Venda ja Faturado'
			Else

				DbSelectArea("SC9")
				DbSeek(cFilSel+SC6->C6_NUM+SC6->C6_ITEM)
				If Found()
					If !Empty(SC9->C9_NFISCAL)
						cStatus := 'Pedido de Venda ja Faturado'
					Endif
					If Empty(SC9->C9_BLEST) .And. Empty(SC9->C9_BLCRED) .And. Empty(SC9->C9_BLWMS)
						If !Empty(SC9->C9_NFISCAL)
							cStatus := 'Pedido de Venda ja Faturado'
						Else
							cStatus := 'Pedido de Venda Liberado Aguardando Faturamento'
						Endif
					ElseIf !Empty(SC9->C9_BLCRED) .And. Empty(SC9->C9_NFISCAL)
						cStatus := 'Pedido de Venda Bloqueado por Credito'
					ElseIf !Empty(SC9->C9_BLEST) .And. Empty(SC9->C9_NFISCAL)
						cStatus := 'Pedido de Venda Bloqueado por Estoque'
					ElseIf !Empty(SC9->C9_BLWMS) .And. Empty(SC9->C9_NFISCAL)
						cStatus := 'Em Processo de Separação pelo WMS'
					Endif
				Else
					cStatus:='Pedido Aguardando Liberacao Comercial'
				Endif
			Endif
			cStatus := 'PROCESSO DE VENDA NORMAL -> '+cStatus
		Endif

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(cFilSel+SC6->C6_PRODUTO)

		If Empty(aListItem[1,1])
			aListItem:={}
		Endif


		DbSelectArea("SC9")
		MsSeek(cFilSel+SC6->C6_NUM+SC6->C6_ITEM)
		aAdd(aListItem,{SC6->C6_ITEM,SB1->B1_REFER,SB1->B1_MARCA,SC6->C6_QTDVEN,cStatus,SC6->C6_ENTREG,;
		SC9->C9_DTLCOM,SC9->C9_HRLCOM,SC9->C9_USRLCOM,SC9->C9_DTLCRE,SC9->C9_HRLCRE,SC9->C9_USRLCRE,Iif(!Empty(C9_USRLCRE),Iif(SC9->C9_TPLCRE="M","Manual",'Automática') ,' '),;
		SC9->C9_DTLEST,SC9->C9_HRLEST,SC9->C9_USRLEST,u_X3CBOXDES(SC9->C9_TPLEST,aTpLEst),SC9->C9_DTPSEP,SC9->C9_HRPSEP,SC9->C9_USRPSEP,;
		SC9->C9_DTDOCS,SC9->C9_HRDOCS,SC9->C9_USRDOCS,SC6->C6_NOTA})

		DbSelectArea("SC6")
		DbSkip()

	End

	oListItem:SetArray(aListItem)
	oListItem:bLine:={||{aListItem[oListItem:nAt,1],;
	aListItem[oListItem:nAt,2],;
	aListItem[oListItem:nAt,3],;
	aListItem[oListItem:nAt,4],;
	aListItem[oListItem:nAt,5],;
	aListItem[oListItem:nAt,6],;
	aListItem[oListItem:nAt,7],;
	aListItem[oListItem:nAt,8],;
	aListItem[oListItem:nAt,9],;
	aListItem[oListItem:nAt,10],;
	aListItem[oListItem:nAt,11],;
	aListItem[oListItem:nAt,12],;
	aListItem[oListItem:nAt,13],;
	aListItem[oListItem:nAt,14],;
	aListItem[oListItem:nAt,15],;
	aListItem[oListItem:nAt,16],;
	aListItem[oListItem:nAt,17],;
	aListItem[oListItem:nAt,18],;
	aListItem[oListItem:nAt,19],;
	aListItem[oListItem:nAt,20],;
	aListItem[oListItem:nAt,21],;
	aListItem[oListItem:nAt,22],;
	aListItem[oListItem:nAt,23],;
	aListItem[oListItem:nAt,24]}}
	oListItem:Refresh()

	ACTIVATE MSDIALOG oDlg01 CENTERED

Endif

RestArea(aArea)

Return(.T.)


/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Funcao: aRetFIL    || Autor: Edivaldo Goncalves      || Data: 20/01/09  ||
||-------------------------------------------------------------------------||
|| Descricao: Retorna um Array com as filiais do sistema                   ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
*****************************************************************************
Static Function aRetFIL
*****************************************************************************
cFiliais := ""
aFiliais := {}
dbSelectArea("SM0")
nRecSM0 := Recno()
dbSeek(cEmpAnt,.F.)

Do While SM0->M0_CODIGO == cEmpAnt
	aAdd(aFiliais,{SM0->M0_CODFIL,SM0->M0_FILIAL})
	dbSkip()
Enddo

cFiliais := Left(cFiliais,Len(cFiliais)-1)

dbGoto(nRecSM0)

Return (aFiliais)

Return
*****************************************************************************
Static Function RetMotivo(CMOTIVO)
*****************************************************************************
Local cRetorno := ""

Do Case
	Case CMOTIVO == "01"
		cRetorno := "Vl.Lim.Inferior"
	Case CMOTIVO == "04"
		cRetorno := "Dt.Lim.Vencido"
	Case CMOTIVO == "09"
		cRetorno := "Rej.Man.Cred"


	Case CMOTIVO == "99"
		cRetorno := "Cliente Vendor"
	Case CMOTIVO == "98"
		cRetorno := "Cond. Pgto"
	Case CMOTIVO == "97"
		cRetorno := "Parc. Vlr Min"
	Case CMOTIVO == "96"
		cRetorno := "Cli. Recuper."
	OtherWise
		cRetorno := CMOTIVO +" Cadastrar TI "
End Do

//Iif(SC5TMP->MOTIVO=="01","Vl.Lim.Inferior",IiF(SC5TMP->MOTIVO=="04","Dt.Lim.Vencido",IiF(SC5TMP->MOTIVO=="09","Rej.Man.Cred","")))

Return(cRetorno)