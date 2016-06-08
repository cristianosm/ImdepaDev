#include 'rwmake.ch'

// ALTERAR ROTINA DE CALCULO DA QUANTIDADE RESERVADA PARA CONSIDERAR TABELA SC0...

/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: TmpM080      || Autor: Luciano Corrêa        || Data: 01/04/04  ||
||-------------------------------------------------------------------------||
|| Descrição: Consistencias de Saldo Fisico de Produtos e Pedidos de Venda ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function TmpM080()


Private cPerg     := 'TMPM08'
Private cCadastro := OemToAnsi( 'Consistencias na Base de Dados' )
Private aSays     := {}
Private aButtons  := {}
Private nOpca     := 0

Private aDados    := { 	{ "Operacao:"						,"","","mv_ch1","N",1,0,0,"C","","mv_par01","Relatorio"	,"","","","","Ajuste"	,"","","","",""          ,"","","","","","","","","","","","","","","" }, ;
						{ "Saldo Atual x Calc? "			,"","","mv_ch2","N",1,0,0,"C","","mv_par02","Sim"		,"","","","","Nao"		,"","","","",""          ,"","","","","","","","","","","","","","","" }, ;
						{ "Saldo Atual Negativo?"			,"","","mv_ch3","N",1,0,0,"C","","mv_par03","Sim"		,"","","","","Nao"		,"","","","",""          ,"","","","","","","","","","","","","","","" }, ;
						{ "Ped Qtd.Entr.Zerada Incorreta?"	,"","","mv_ch4","N",1,0,0,"C","","mv_par04","Sim"		,"","","","","Nao"		,"","","","",""          ,"","","","","","","","","","","","","","","" }, ;
						{ "Quant Reservada Incorreta?"		,"","","mv_ch5","N",1,0,0,"C","","mv_par05","Sim"		,"","","","","Nao"		,"","","","",""          ,"","","","","","","","","","","","","","","" }, ;
						{ "Quant Ped Venda Incorreta?"		,"","","mv_ch6","N",1,0,0,"C","","mv_par06","Sim"		,"","","","","Nao"		,"","","","",""          ,"","","","","","","","","","","","","","","" }, ;
						{ "Quant Prev Entrar Incorreta?"	,"","","mv_ch7","N",1,0,0,"C","","mv_par07","Sim"		,"","","","","Nao"		,"","","","",""          ,"","","","","","","","","","","","","","","" }, ;
						{ "Ped Liberado sem Ped Venda?"		,"","","mv_ch8","N",1,0,0,"C","","mv_par08","Sim"		,"","","","","Nao"		,"","","","",""          ,"","","","","","","","","","","","","","","" }, ;
						{ "Ped Liberado maior Ped Venda?"	,"","","mv_ch9","N",1,0,0,"C","","mv_par09","Sim"		,"","","","","Nao"		,"","","","",""          ,"","","","","","","","","","","","","","","" }, ;
						{ "Ped Venda x Plan Transfer?"		,"","","mv_cha","N",1,0,0,"C","","mv_par10","Sim"		,"","","","","Nao"		,"","","","",""          ,"","","","","","","","","","","","","","","" }, ;
						{ "Doc Saida sem Ped Liberado?"		,"","","mv_chb","N",1,0,0,"C","","mv_par11","Sim"		,"","","","","Nao"		,"","","","",""          ,"","","","","","","","","","","","","","","" }, ;
						{ "Ped Qtd.Entrega > Qtd.Vendida?"	,"","","mv_chc","N",1,0,0,"C","","mv_par12","Sim"		,"","","","","Nao"		,"","","","",""          ,"","","","","","","","","","","","","","","" } }

AjustaSx1( cPerg, aDados )

Pergunte( cPerg, .f. )

aAdd( aSays, OemToAnsi( ' Este programa tem como objetivo consistir o saldo fisico de ' ) )
aAdd( aSays, OemToAnsi( ' produtos e o saldo dos pedidos de venda.' ) )

aAdd( aButtons, { 5, .t., {|| Pergunte( cPerg, .t. ) } } )
aAdd( aButtons, { 1, .t., {|o| nOpca := 1, If( gpconfOK(), FechaBatch(), nOpca:=0 ) } } )
aAdd( aButtons, { 2, .t., {|o| FechaBatch() } } )

FormBatch( cCadastro, aSays, aButtons )

If nOpca == 1
	RunProc()
EndIf

Return


********************************************************************************
Static Function RunProc()


Local nRec_SM0  := SM0->( RecNo() )

Private aLog      := {}
Private cImdepa   := GetMV('MV_IMDEPA')
Private aFiliais  := {}
Private cFilImd   := ""


SM0->( dbSeek( cEmpAnt, .f. ) )

While SM0->( !EOF() ) .and. SM0->M0_CODIGO == cEmpAnt
	
	aAdd( aFiliais, SM0->M0_CODFIL )
	
	cFilImd += "'" + SM0->M0_CODFIL + "',"
	
	SM0->( dbSkip() )
End

cFilImd := SubStr( cFilImd, 1, Len( cFilImd ) - 1 )

SM0->( dbGoTo( nRec_SM0 ) )

If mv_par01 == 1
	
	If mv_par02 == 1
		Processa( {|| RunProc1() }, cCadastro := 'Consistencia 1/14 - Diferencas entre Saldo Atual e Saldo Calculado' )
	EndIf
	If mv_par03 == 1
		Processa( {|| RunProc2() }, cCadastro := 'Consistencia 2/14 - Saldo Atual Negativo' )
	EndIf
	If mv_par04 == 1
		Processa( {|| RunProc3() }, cCadastro := 'Consistencia 3/14 - Pedido com Quant Entregue Zerada Incorreta' )
	EndIf
	If mv_par05 == 1
		Processa( {|| RunProc4() }, cCadastro := 'Consistencia 4/14 - Quantidade Reservada Incorreta' )
	EndIf
	If mv_par06 == 1
		Processa( {|| RunProc5() }, cCadastro := 'Consistencia 5/14 - Quantidade Ped de Venda Incorreta' )
	EndIf
	If mv_par07 == 1
		Processa( {|| RunProc6() }, cCadastro := 'Consistencia 6/14 - Quantidade Prevista para Entrar Incorreta' )
	EndIf
	If mv_par08 == 1
		Processa( {|| RunProc7() }, cCadastro := 'Consistencia 7/14 - Ped Liberado sem Ped de Venda' )
	EndIf
	If mv_par09 == 1
		Processa( {|| RunProc8() }, cCadastro := 'Consistencia 8/14 - Ped Liberado maior que Ped de Venda' )
	EndIf
	If mv_par10 == 1
		Processa( {|| RunProc9() }, cCadastro := 'Consistencia 9/14 - Ped alocado Plan Transf e liberado estoque' )
		Processa( {|| RunProc10() }, cCadastro := 'Consistencia 10/14 - Ped alocado Plan Transf recebida e bloqueado' )
		Processa( {|| RunProc11() }, cCadastro := 'Consistencia 11/14 - Ped sem Plan Transf e bloqueado estoque' )
		Processa( {|| RunProc12() }, cCadastro := 'Consistencia 12/14 - Ped de Transf com Plan Transf e bloqueado estoque' )
	EndIf
	If mv_par11 == 1
		Processa( {|| RunProc13() }, cCadastro := 'Consistencia 13/14 - Documento de Saida sem Pedido Liberado' )
	EndIf
	If mv_par12 == 1
		Processa( {|| RunProc14() }, cCadastro := 'Consistencia 14/14 - Pedido com Quant Entregue > Quant. Vendida' )
	EndIf	
	
	Print()
Else
	If mv_par04 == 1
		Processa( {|| Ajuste3() }, cCadastro := 'Ajuste 3/14 - Pedido com Quant Entregue Zerada Incorreta' )
	EndIf
	If mv_par05 == 1
		Processa( {|| Ajuste4() }, cCadastro := 'Ajuste 4/14 - Quantidade Reservada Incorreta' )
	EndIf
	If mv_par06 == 1
		Processa( {|| Ajuste5() }, cCadastro := 'Ajuste 5/14 - Quantidade Ped de Venda Incorreta' )
	EndIf
	If mv_par07 == 1
		Processa( {|| Ajuste6() }, cCadastro := 'Ajuste 6/14 - Quantidade Prevista para Entrar Incorreta' )
	EndIf
	If mv_par08 == 1
		Processa( {|| Ajuste7() }, cCadastro := 'Ajuste 7/14 - Ped Liberado sem Ped de Venda' )
	EndIf
	If mv_par09 == 1
		Processa( {|| Ajuste8() }, cCadastro := 'Ajuste 8/14 - Ped Liberado maior que Ped de Venda' )
	EndIf
	If mv_par11 == 1
		Processa( {|| Ajuste13() }, cCadastro := 'Ajuste 13/14 - Documento de Saida sem Pedido Liberado' )
	EndIf
	If mv_par12 == 1
		Processa( {|| Ajuste14() }, cCadastro := 'Ajuste 14/14 - Pedido com Quant Entregue > Quant Vendida' )
	EndIf	
EndIf

Return


********************************************************************************
Static Function RunProc1()


Local _nFilial
Local __cFilAnt := cFilAnt
Local aEstCalc
Local nCont := 0

aAdd( aLog, Replicate( '*', 132 ) )
aAdd( aLog, PadC( cCadastro, 132 ) )
aAdd( aLog, Replicate( '*', 132 ) )
//           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
//           0         1         2         3         4         5         6         7         8         9         0         1         2         3
//                99     999999999999999  XXXXXXXXXXxxxxxxxxxxXXXXXXXXXX     99     999,999,999.9999     999,999,999.9999
aAdd( aLog, '   Filial   Produto          Descricao                         Local        Saldo Atual      Saldo Calculado' )
aAdd( aLog, Replicate( '*', 132 ) )


ProcRegua( SB2->( LastRec() ) )

SB1->( dbSetOrder( 1 ) )
SB2->( dbSetOrder( 1 ) )

For _nFilial := 1 to Len( aFiliais )
	
	// altera a filial atual para funcionamento correto da funcao CalcEst()...
	cFilAnt := aFiliais[ _nFilial ]
	
	SB2->( dbSeek( xFilial( 'SB2' ), .t. ) )
	
	While SB2->( !Eof() ) .and. SB2->B2_FILIAL == xFilial( 'SB2' )
		
		IncProc( 'Processando Filial: ' + SB2->B2_FILIAL + '  Produto: ' + AllTrim( SB2->B2_COD ) + '  Local: ' + SB2->B2_LOCAL )
		
		aEstCalc := CalcEst( SB2->B2_COD, SB2->B2_LOCAL, dDataBase + 1 )
		
		If aEstCalc[ 1 ] <> SB2->B2_QATU
			
			SB1->( dbSeek( xFilial( 'SB1' ) + SB2->B2_COD, .f. ) )
			
			aAdd( aLog, Space( 5 ) + SB2->B2_FILIAL + ;
						Space( 5 ) + SB2->B2_COD + ;
					    Space( 2 ) + SB1->B1_DESC + ;
						Space( 5 ) + SB2->B2_LOCAL + ;
						Space( 5 ) + Transform( SB2->B2_QATU, '@E 999,999,999.9999' ) + ;
						Space( 5 ) + Transform( aEstCalc[ 1 ], '@E 999,999,999.9999' ) )
			nCont ++
		EndIf
		
		SB2->( dbSkip() )
	End
	
Next _nFilial

aAdd( aLog, ' ' )
aAdd( aLog, 'Numero de Inconsistencias   >>' + Transform( nCont, '@E 999,999' ) )

// retorna filial original...
cFilAnt := __cFilAnt

Return


********************************************************************************
Static Function RunProc2()


Local nCont := 0
Private cQuery

aAdd( aLog, Replicate( '*', 132 ) )
aAdd( aLog, PadC( cCadastro, 132 ) )
aAdd( aLog, Replicate( '*', 132 ) )
//           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
//           0         1         2         3         4         5         6         7         8         9         0         1         2         3
//                99     999999999999999  XXXXXXXXXXxxxxxxxxxxXXXXXXXXXX     99     999,999,999.9999
aAdd( aLog, '   Filial   Produto          Descricao                         Local        Saldo Atual' )
aAdd( aLog, Replicate( '*', 132 ) )

ProcRegua( 2 )

IncProc( 'Analisando dados...' )

cQuery := "select b2_filial, b2_cod, b1_desc, b2_local, b2_qatu"
cQuery += " from "  + RetSqlName( 'SB2' ) + " sb2, "  + RetSqlName( 'SB1' ) + " sb1"
cQuery += " where b2_filial in ( " + cFilImd + " )"
cQuery += " and b2_qatu < 0"
cQuery += " and sb2.D_E_L_E_T_ = ' '"
cQuery += " and b1_filial = b2_filial"
cQuery += " and b1_cod = b2_cod"
cQuery += " and sb1.D_E_L_E_T_ = ' '"
cQuery += " order by b2_filial, b2_cod, b2_local"

MEMOWRIT("C:\SQLSIGA\TMPM080_RUNPROC2_SB2TMP.TXT", cQuery)

dbUseArea( .t., 'TOPCONN', TCGenQry( ,, cQuery ), 'SB2TMP', .t., .t. )

TCSetField( 'SB2TMP', 'B2_QATU'   , 'N', 14, 4 )

dbSelectArea( 'SB2TMP' )
dbGoTop()

While !Eof()
	
	IncProc( 'Processando Filial: ' + SB2TMP->B2_FILIAL + '  Produto: ' + AllTrim( SB2TMP->B2_COD ) + '  Local: ' + SB2TMP->B2_LOCAL )
	
	aAdd( aLog, Space( 5 ) + SB2TMP->B2_FILIAL + ;
				Space( 5 ) + SB2TMP->B2_COD + ;
			    Space( 2 ) + SB2TMP->B1_DESC + ;
				Space( 5 ) + SB2TMP->B2_LOCAL + ;
				Space( 5 ) + Transform( SB2TMP->B2_QATU, '@E 999,999,999.9999' ) )
	nCont ++
	
	dbSkip()
End

aAdd( aLog, ' ' )
aAdd( aLog, 'Numero de Inconsistencias   >>' + Transform( nCont, '@E 999,999' ) )

SB2TMP->( dbCloseArea() )

Return


********************************************************************************
Static Function RunProc3()


Local nCont := 0
Private cQuery

aAdd( aLog, Replicate( '*', 132 ) )
aAdd( aLog, PadC( cCadastro, 132 ) )
aAdd( aLog, Replicate( '*', 132 ) )
//           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
//           0         1         2         3         4         5         6         7         8         9         0         1         2         3
//                99     999999     99/99/99     99     999999999999999  XXXXXXXXXXxxxxxxxxxxXXXXXXXXXX     99     999,999,999.9999
aAdd( aLog, '   Filial   Pedido     Data Fat    Item    Produto          Descricao                         Local       Qtd Vendida' )
aAdd( aLog, Replicate( '*', 132 ) )

ProcRegua( 2 )

IncProc( 'Analisando dados...' )

// parte do principio que nao existe faturamento parcial...

cQuery := "select c6_filial, c6_num, d2_emissao, c6_item, c6_produto, b1_desc, c6_local, c6_qtdven"
cQuery += " from " + RetSqlName( 'SC6' ) + " sc6, " + RetSqlName( 'SD2' ) + " sd2, " + RetSqlName( 'SB1' ) + " sb1"
cQuery += " where c6_filial in ( " + cFilImd + " )"
cQuery += " and c6_qtdent = 0"
cQuery += " and c6_qtdven > 0"
cQuery += " and sc6.D_E_L_E_T_ = ' '"
cQuery += " and d2_filial = c6_filial"
cQuery += " and d2_pedido = c6_num"
cQuery += " and d2_itempv = c6_item"
cQuery += " and d2_cod = c6_produto"
cQuery += " and d2_quant = c6_qtdven"
cQuery += " and sd2.D_E_L_E_T_ = ' '"
cQuery += " and b1_filial = c6_filial"
cQuery += " and b1_cod = c6_produto "
cQuery += " and sb1.D_E_L_E_T_ = ' '"
cQuery += " order by c6_filial, c6_num, c6_item"

MEMOWRIT("C:\SQLSIGA\TMPM080_RUNPROC3_SC6TMP.TXT", cQuery)

dbUseArea( .t., 'TOPCONN', TCGenQry( ,, cQuery ), 'SC6TMP', .t., .t. )

TCSetField( 'SC6TMP', 'D2_EMISSAO', 'D',  8, 0 )
TCSetField( 'SC6TMP', 'C6_QTDVEN' , 'N', 14, 4 )

dbSelectArea( 'SC6TMP' )
dbGoTop()

While !Eof()
	
	IncProc( 'Processando Filial: ' + SC6TMP->C6_FILIAL + '  Pedido: ' + AllTrim( SC6TMP->C6_NUM ) )
	
	aAdd( aLog, Space( 5 ) + SC6TMP->C6_FILIAL + ;
				Space( 5 ) + SC6TMP->C6_NUM + ;
				Space( 5 ) + DtoC( SC6TMP->D2_EMISSAO ) + ;
			    Space( 5 ) + SC6TMP->C6_ITEM + ;
			    Space( 5 ) + SC6TMP->C6_PRODUTO + ;
			    Space( 2 ) + SC6TMP->B1_DESC + ;
				Space( 5 ) + SC6TMP->C6_LOCAL + ;
				Space( 5 ) + Transform( SC6TMP->C6_QTDVEN, '@E 999,999,999.9999' ) )
	nCont ++
	
	dbSkip()
End

aAdd( aLog, ' ' )
aAdd( aLog, 'Numero de Inconsistencias   >>' + Transform( nCont, '@E 999,999' ) )

SC6TMP->( dbCloseArea() )

Return


********************************************************************************
Static Function RunProc4()


Local nCont := 0
Private cQuery

aAdd( aLog, Replicate( '*', 132 ) )
aAdd( aLog, PadC( cCadastro, 132 ) )
aAdd( aLog, Replicate( '*', 132 ) )
//           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
//           0         1         2         3         4         5         6         7         8         9         0         1         2         3
//                99     999999999999999  XXXXXXXXXXxxxxxxxxxxXXXXXXXXXX     99     999,999,999.9999     999,999,999.9999
aAdd( aLog, '   Filial   Produto          Descricao                         Local        Qtd Reserva          Qtd Correta' )
aAdd( aLog, Replicate( '*', 132 ) )

ProcRegua( 2 )

IncProc( 'Analisando dados...' )

cQuery := "select b2_filial, b2_cod, b1_desc, b2_local, b2_reserva, c9_qtdlib"
cQuery += " from "  + RetSqlName( 'SB2' ) + " sb2, "  + RetSqlName( 'SB1' ) + " sb1, ("
cQuery += "  select c9_filial, c9_produto, c9_local, sum( c9_qtdlib ) c9_qtdlib"
cQuery += "  from "  + RetSqlName( 'SC9' ) + " sc9, "  + RetSqlName( 'SC6' ) + " sc6, "  + RetSqlName( 'SF4' ) + " sf4"
cQuery += "  where c9_filial in ( " + cFilImd + " )"
cQuery += "  and c9_serienf = ' '"
cQuery += "  and c9_nfiscal = ' '"
cQuery += "  and c9_blest = ' '"
cQuery += "  and c9_blcred = ' '"
cQuery += "  and sc9.D_E_L_E_T_ = ' '"
cQuery += "  and c6_filial = c9_filial"
cQuery += "  and c6_num = c9_pedido"
cQuery += "  and c6_item = c9_item"
cQuery += "  and sc6.D_E_L_E_T_ = ' '"
cQuery += "  and f4_filial = c6_filial"
cQuery += "  and f4_codigo = c6_tes"
cQuery += "  and f4_estoque = 'S'"
cQuery += "  and sf4.D_E_L_E_T_ = ' '"
cQuery += "  group by c9_filial, c9_produto, c9_local )"
cQuery += " where b2_filial in ( " + cFilImd + " )"
cQuery += " and sb2.D_E_L_E_T_ = ' '"
cQuery += " and c9_filial = b2_filial"
cQuery += " and c9_produto = b2_cod"
cQuery += " and c9_local = b2_local"
cQuery += " and c9_qtdlib <> b2_reserva"
cQuery += " and b1_filial = b2_filial"
cQuery += " and b1_cod = b2_cod "
cQuery += " and sb1.D_E_L_E_T_ = ' '"
cQuery += "union all "
cQuery += "select b2_filial, b2_cod, b1_desc, b2_local, b2_reserva, 0 c9_qtdlib"
cQuery += " from "  + RetSqlName( 'SB2' ) + " sb2, "  + RetSqlName( 'SB1' ) + " sb1"
cQuery += " where b2_filial in ( " + cFilImd + " )"
cQuery += " and b2_reserva <> 0"
cQuery += " and sb2.D_E_L_E_T_ = ' '"
cQuery += " and not exists ( "
cQuery += "  select c9_filial"
cQuery += "  from "  + RetSqlName( 'SC9' ) + " sc9, "  + RetSqlName( 'SC6' ) + " sc6, "  + RetSqlName( 'SF4' ) + " sf4"
cQuery += "  where c9_filial in ( " + cFilImd + " )"
cQuery += "  and c9_serienf = ' '"
cQuery += "  and c9_nfiscal = ' '"
cQuery += "  and c9_blest = ' '"
cQuery += "  and c9_blcred = ' '"
cQuery += "  and sc9.D_E_L_E_T_ = ' '"
cQuery += "  and c9_filial = b2_filial"
cQuery += "  and c9_produto = b2_cod"
cQuery += "  and c9_local = b2_local"
cQuery += "  and c6_filial = c9_filial"
cQuery += "  and c6_num = c9_pedido"
cQuery += "  and c6_item = c9_item"
cQuery += "  and sc6.D_E_L_E_T_ = ' '"
cQuery += "  and f4_filial = c6_filial"
cQuery += "  and f4_codigo = c6_tes"
cQuery += "  and f4_estoque = 'S'"
cQuery += "  and sf4.D_E_L_E_T_ = ' ' )"
cQuery += " and b1_filial = b2_filial"
cQuery += " and b1_cod = b2_cod "
cQuery += " and sb1.D_E_L_E_T_ = ' '"
cQuery += "order by b2_filial, b2_cod, b2_local"

MEMOWRIT("C:\SQLSIGA\TMPM080_RUNPROC4_SB2TMP.TXT", cQuery)

dbUseArea( .t., 'TOPCONN', TCGenQry( ,, cQuery ), 'SB2TMP', .t., .t. )

TCSetField( 'SB2TMP', 'B2_RESERVA', 'N', 14, 4 )
TCSetField( 'SB2TMP', 'C9_QTDLIB' , 'N', 14, 4 )

dbSelectArea( 'SB2TMP' )
dbGoTop()

While !Eof()
	
	IncProc( 'Processando Filial: ' + SB2TMP->B2_FILIAL + '  Produto: ' + AllTrim( SB2TMP->B2_COD ) + '  Local: ' + SB2TMP->B2_LOCAL )
	
	aAdd( aLog, Space( 5 ) + SB2TMP->B2_FILIAL + ;
				Space( 5 ) + SB2TMP->B2_COD + ;
			    Space( 2 ) + SB2TMP->B1_DESC + ;
				Space( 5 ) + SB2TMP->B2_LOCAL + ;
				Space( 5 ) + Transform( SB2TMP->B2_RESERVA, '@E 999,999,999.9999' ) + ;
				Space( 5 ) + Transform( SB2TMP->C9_QTDLIB, '@E 999,999,999.9999' ) )
	nCont ++
	
	dbSkip()
End

aAdd( aLog, ' ' )
aAdd( aLog, 'Numero de Inconsistencias   >>' + Transform( nCont, '@E 999,999' ) )

SB2TMP->( dbCloseArea() )

Return


********************************************************************************
Static Function RunProc5()


Local nCont := 0
Private cQuery

aAdd( aLog, Replicate( '*', 132 ) )
aAdd( aLog, PadC( cCadastro, 132 ) )
aAdd( aLog, Replicate( '*', 132 ) )
//           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
//           0         1         2         3         4         5         6         7         8         9         0         1         2         3
//                99     999999999999999  XXXXXXXXXXxxxxxxxxxxXXXXXXXXXX     99     999,999,999.9999     999,999,999.9999
aAdd( aLog, '   Filial   Produto          Descricao                         Local       Qtd Ped Vend          Qtd Correta' )
aAdd( aLog, Replicate( '*', 132 ) )

ProcRegua( 2 )

IncProc( 'Analisando dados...' )

cQuery := "select b2_filial, b2_cod, b1_desc, b2_local, b2_qpedven, qtdpend"
cQuery += " from " + RetSqlName( 'SB2' ) + " sb2, " + RetSqlName( 'SB1' ) + " sb1, ( " 
cQuery += "  select c6_filial, c6_produto, c6_local, sum( qtdpend ) qtdpend"
cQuery += "   from ("
cQuery += "   select c6_filial, c6_produto, c6_local, sum( c6_qtdven - c6_qtdent ) qtdpend"
cQuery += "    from " + RetSqlName( 'SC6' ) + " sc6, " + RetSqlName( 'SF4' ) + " sf4"
cQuery += "    where c6_filial in ( " + cFilImd + " )"
cQuery += "    and c6_blq in ( ' ', 'N' )"
cQuery += "    and ( c6_qtdven - c6_qtdent ) > 0"
cQuery += "    and sc6.D_E_L_E_T_ = ' '"
cQuery += "    and f4_filial = c6_filial"
cQuery += "    and f4_codigo = c6_tes"
cQuery += "    and f4_estoque = 'S'"
cQuery += "    and sf4.D_E_L_E_T_ = ' '"
cQuery += "    group by c6_filial, c6_produto, c6_local"
cQuery += "   union all"
cQuery += "   select c9_filial c6_filial, c9_produto c6_produto, "
cQuery += "    c9_local c6_local, sum( c9_qtdlib * -1 ) qtdpend"
cQuery += "    from " + RetSqlName( 'SC9' ) + " sc9, "  + RetSqlName( 'SC6' ) + " sc6, "  + RetSqlName( 'SF4' ) + " sf4"
cQuery += "    where c9_filial in ( " + cFilImd + " )"
cQuery += "    and c9_serienf = ' '"
cQuery += "    and c9_nfiscal = ' '"
cQuery += "    and c9_blest = ' '"
cQuery += "    and c9_blcred = ' '"
cQuery += "    and sc9.D_E_L_E_T_ = ' '"
cQuery += "    and c6_filial = c9_filial"
cQuery += "    and c6_num = c9_pedido"
cQuery += "    and c6_item = c9_item"
cQuery += "    and sc6.D_E_L_E_T_ = ' '"
cQuery += "    and f4_filial = c6_filial"
cQuery += "    and f4_codigo = c6_tes"
cQuery += "    and f4_estoque = 'S'"
cQuery += "    and sf4.D_E_L_E_T_ = ' '"
cQuery += "    group by c9_filial, c9_produto, c9_local )"
cQuery += "  group by c6_filial, c6_produto, c6_local )"
cQuery += " where b2_filial in ( " + cFilImd + " )"
cQuery += " and sb2.D_E_L_E_T_ = ' '"
cQuery += " and c6_filial = b2_filial"
cQuery += " and c6_produto = b2_cod"
cQuery += " and c6_local = b2_local"
cQuery += " and qtdpend <> b2_qpedven"
cQuery += " and b1_filial = b2_filial"
cQuery += " and b1_cod = b2_cod"
cQuery += " and sb1.D_E_L_E_T_ = ' '"
cQuery += " union all "
cQuery += " select b2_filial, b2_cod, b1_desc, b2_local, b2_qpedven, 0 qtdpend"
cQuery += " from " + RetSqlName( 'SB2' ) + " sb2, " + RetSqlName( 'SB1' ) + " sb1"
cQuery += " where b2_filial in ( " + cFilImd + " )"
cQuery += " and b2_qpedven <> 0"
cQuery += " and sb2.D_E_L_E_T_ = ' '"
cQuery += " and not exists ( "
cQuery += "  select c6_filial"
cQuery += "    from " + RetSqlName( 'SC6' ) + " sc6, " + RetSqlName( 'SF4' ) + " sf4"
cQuery += "    where c6_filial in ( " + cFilImd + " )"
cQuery += "    and c6_blq in ( ' ', 'N' )"
cQuery += "    and ( c6_qtdven - c6_qtdent ) > 0"
cQuery += "    and sc6.D_E_L_E_T_ = ' '"
cQuery += "    and f4_filial = c6_filial"
cQuery += "    and f4_codigo = c6_tes"
cQuery += "    and f4_estoque = 'S'"
cQuery += "    and sf4.D_E_L_E_T_ = ' '"
cQuery += "    and c6_filial = b2_filial"
cQuery += "    and c6_produto = b2_cod"
cQuery += "    and c6_local = b2_local )"
cQuery += " and b1_filial = b2_filial"
cQuery += " and b1_cod = b2_cod"
cQuery += " and sb1.D_E_L_E_T_ = ' '"
cQuery += "order by b2_filial, b2_cod, b2_local"

MEMOWRIT("C:\SQLSIGA\TMPM080_RUNPROC5_SB2TMP.TXT", cQuery)

dbUseArea( .t., 'TOPCONN', TCGenQry( ,, cQuery ), 'SB2TMP', .t., .t. )

TCSetField( 'SB2TMP', 'B2_QPEDVEN', 'N', 14, 4 )
TCSetField( 'SB2TMP', 'QTDPEND'   , 'N', 14, 4 )

dbSelectArea( 'SB2TMP' )
dbGoTop()

While !Eof()
	
	IncProc( 'Processando Filial: ' + SB2TMP->B2_FILIAL + '  Produto: ' + AllTrim( SB2TMP->B2_COD ) + '  Local: ' + SB2TMP->B2_LOCAL )
	
	aAdd( aLog, Space( 5 ) + SB2TMP->B2_FILIAL + ;
				Space( 5 ) + SB2TMP->B2_COD + ;
			    Space( 2 ) + SB2TMP->B1_DESC + ;
				Space( 5 ) + SB2TMP->B2_LOCAL + ;
				Space( 5 ) + Transform( SB2TMP->B2_QPEDVEN, '@E 999,999,999.9999' ) + ;
				Space( 5 ) + Transform( SB2TMP->QTDPEND, '@E 999,999,999.9999' ) )
	nCont ++
	
	dbSkip()
End

aAdd( aLog, ' ' )
aAdd( aLog, 'Numero de Inconsistencias   >>' + Transform( nCont, '@E 999,999' ) )

SB2TMP->( dbCloseArea() )

Return


********************************************************************************
Static Function RunProc6()


Local nCont := 0
Private cQuery

aAdd( aLog, Replicate( '*', 132 ) )
aAdd( aLog, PadC( cCadastro, 132 ) )
aAdd( aLog, Replicate( '*', 132 ) )
//           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
//           0         1         2         3         4         5         6         7         8         9         0         1         2         3
//                99     999999999999999  XXXXXXXXXXxxxxxxxxxxXXXXXXXXXX     99     999,999,999.9999     999,999,999.9999
aAdd( aLog, '   Filial   Produto          Descricao                         Local       Qtd Prevista          Qtd Correta' )
aAdd( aLog, Replicate( '*', 132 ) )

ProcRegua( 2 )

IncProc( 'Analisando dados...' )

cQuery := "select b2_filial, b2_cod, b1_desc, b2_local, b2_salpedi, qtdprent"
cQuery += " from " + RetSqlName( 'SB2' ) + " sb2, " + RetSqlName( 'SB1' ) + " sb1, (  "
cQuery += "  select c7_filent, c7_produto, c7_local, sum( qtdprent ) qtdprent"
cQuery += "   from ("
cQuery += "   select c1_msfil c7_filent, c1_produto c7_produto, c1_local c7_local, sum( c1_quant - c1_quje ) qtdprent"
cQuery += "    from " + RetSqlName( 'SC1' ) + " sc1"
cQuery += "    where c1_filial = ' '"
cQuery += "    and c1_msfil in ( " + cFilImd + " )"
cQuery += "    and ( c1_quant - c1_quje ) > 0"
cQuery += "    and sc1.D_E_L_E_T_ = ' '"
cQuery += "    group by c1_msfil, c1_produto, c1_local"
cQuery += "   union all"
cQuery += "   select c7_filent, c7_produto, c7_local, sum( c7_quant - c7_quje ) qtdprent"
cQuery += "    from " + RetSqlName( 'SC7' ) + " sc7"
cQuery += "    where c7_filent in ( " + cFilImd + " )"
cQuery += "    and ( c7_quant - c7_quje ) > 0"
//Inserido por Edivaldo Gonçalves Codeiro/Mancuzo
//Desconsidera Itens eliminados por Residuo
cQuery += "    and C7_RESIDUO <>'S'"
cQuery += "    and c7_tes = ' '"
cQuery += "    and sc7.D_E_L_E_T_ = ' '"
cQuery += "    group by c7_filent, c7_produto, c7_local"
cQuery += "   union all"
cQuery += "   select c7_filent, c7_produto, c7_local, sum( c7_quant - c7_quje ) qtdprent"
cQuery += "    from " + RetSqlName( 'SC7' ) + " sc7, " + RetSqlName( 'SF4' ) + " sf4"
cQuery += "    where c7_filent in ( " + cFilImd + " )"
cQuery += "    and ( c7_quant - c7_quje ) > 0"

cQuery += "    and C7_RESIDUO <>'S'"

cQuery += "    and sc7.D_E_L_E_T_ = ' '"
cQuery += "    and f4_filial = c7_filent"
cQuery += "    and f4_codigo = c7_tes"
cQuery += "    and f4_estoque = 'S'"
cQuery += "    and sf4.D_E_L_E_T_ = ' '"
cQuery += "    group by c7_filent, c7_produto, c7_local"
cQuery += "   union all"
cQuery += "   select c2_filial c7_filent, c2_produto c7_produto, c2_local c7_local, sum( c2_quant - c2_quje ) qtdprent"
cQuery += "    from " + RetSqlName( 'SC2' ) + " sc2"
cQuery += "    where c2_filial in ( " + cFilImd + " )"
cQuery += "    and ( c2_quant - c2_quje ) > 0"

cQuery += "    and sc2.D_E_L_E_T_ = ' '"
cQuery += "    group by c2_filial, c2_produto, c2_local )"
cQuery += "  group by c7_filent, c7_produto, c7_local )"
cQuery += " where b2_filial in ( " + cFilImd + " )"
cQuery += " and sb2.D_E_L_E_T_ = ' '"
cQuery += " and c7_filent = b2_filial"
cQuery += " and c7_produto = b2_cod"
cQuery += " and c7_local = b2_local"
cQuery += " and qtdprent <> b2_salpedi"
cQuery += " and b1_filial = b2_filial"
cQuery += " and b1_cod = b2_cod"
cQuery += " and sb1.D_E_L_E_T_ = ' ' "
cQuery += "union all "
cQuery += "select b2_filial, b2_cod, b1_desc, b2_local, b2_salpedi, 0 qtdprent"
cQuery += " from " + RetSqlName( 'SB2' ) + " sb2, " + RetSqlName( 'SB1' ) + " sb1"
cQuery += " where b2_filial in ( " + cFilImd + " )"
cQuery += " and b2_salpedi <> 0"
cQuery += " and sb2.D_E_L_E_T_ = ' '"
cQuery += " and not exists ( "
cQuery += "  select c7_filent, c7_produto, c7_local, sum( qtdprent ) qtdprent"
cQuery += "   from ("
cQuery += "   select c1_msfil c7_filent, c1_produto c7_produto, c1_local c7_local, sum( c1_quant - c1_quje ) qtdprent"
cQuery += "    from " + RetSqlName( 'SC1' ) + " sc1"
cQuery += "    where c1_filial = ' '"
cQuery += "    and c1_msfil in ( " + cFilImd + " )"
cQuery += "    and ( c1_quant - c1_quje ) > 0"  
cQuery += "    and sc1.D_E_L_E_T_ = ' '"
cQuery += "    group by c1_msfil, c1_produto, c1_local"
cQuery += "   union all"
cQuery += "   select c7_filent, c7_produto, c7_local, sum( c7_quant - c7_quje ) qtdprent"
cQuery += "    from " + RetSqlName( 'SC7' ) + " sc7"
cQuery += "    where c7_filent in ( " + cFilImd + " )"
cQuery += "    and ( c7_quant - c7_quje ) > 0"
//Inserido por Edivaldo/Mancuzo
cQuery += "    and C7_RESIDUO <>'S'"

cQuery += "    and c7_tes = ' '"
cQuery += "    and sc7.D_E_L_E_T_ = ' '"
cQuery += "    group by c7_filent, c7_produto, c7_local"
cQuery += "   union all"
cQuery += "   select c7_filent, c7_produto, c7_local, sum( c7_quant - c7_quje ) qtdprent"
cQuery += "    from " + RetSqlName( 'SC7' ) + " sc7, " + RetSqlName( 'SF4' ) + " sf4"
cQuery += "    where c7_filent in ( " + cFilImd + " )"
cQuery += "    and ( c7_quant - c7_quje ) > 0"
//Inserido por Edivaldo Gonçalves Cordeiro em  18/10/06
//Considera Itens eliminados por Residuo
cQuery += "    and C7_RESIDUO <>'S'"  

cQuery += "    and sc7.D_E_L_E_T_ = ' '"
cQuery += "    and f4_filial = c7_filent"
cQuery += "    and f4_codigo = c7_tes"
cQuery += "    and f4_estoque = 'S'"
cQuery += "    and sf4.D_E_L_E_T_ = ' '"
cQuery += "    group by c7_filent, c7_produto, c7_local"
cQuery += "   union all"
cQuery += "   select c2_filial c7_filent, c2_produto c7_produto, c2_local c7_local, sum( c2_quant - c2_quje ) qtdprent"
cQuery += "    from " + RetSqlName( 'SC2' ) + " sc2"
cQuery += "    where c2_filial in ( " + cFilImd + " )"
cQuery += "    and ( c2_quant - c2_quje ) > 0"
cQuery += "    and sc2.D_E_L_E_T_ = ' '"
cQuery += "    group by c2_filial, c2_produto, c2_local )"
cQuery += "  where c7_filent = b2_filial"
cQuery += "  and c7_produto = b2_cod"
cQuery += "  and c7_local = b2_local )"
cQuery += " and b1_filial = b2_filial"
cQuery += " and b1_cod = b2_cod"
cQuery += " and sb1.D_E_L_E_T_ = ' '"
cQuery += "order by b2_filial, b2_cod, b2_local"

MEMOWRIT("C:\SQLSIGA\TMPM080_RUNPROC6_SB2TMP.TXT", cQuery)

dbUseArea( .t., 'TOPCONN', TCGenQry( ,, cQuery ), 'SB2TMP', .t., .t. )

TCSetField( 'SB2TMP', 'B2_SALPEDI', 'N', 14, 4 )
TCSetField( 'SB2TMP', 'QTDPRENT'  , 'N', 14, 4 )

dbSelectArea( 'SB2TMP' )
dbGoTop()

While !Eof()
	
	IncProc( 'Processando Filial: ' + SB2TMP->B2_FILIAL + '  Produto: ' + AllTrim( SB2TMP->B2_COD ) + '  Local: ' + SB2TMP->B2_LOCAL )
	
	aAdd( aLog, Space( 5 ) + SB2TMP->B2_FILIAL + ;
				Space( 5 ) + SB2TMP->B2_COD + ;
			    Space( 2 ) + SB2TMP->B1_DESC + ;
				Space( 5 ) + SB2TMP->B2_LOCAL + ;
				Space( 5 ) + Transform( SB2TMP->B2_SALPEDI, '@E 999,999,999.9999' ) + ;
				Space( 5 ) + Transform( SB2TMP->QTDPRENT, '@E 999,999,999.9999' ) )
	nCont ++
	
	dbSkip()
End

aAdd( aLog, ' ' )
aAdd( aLog, 'Numero de Inconsistencias   >>' + Transform( nCont, '@E 999,999' ) )

SB2TMP->( dbCloseArea() )

Return


********************************************************************************
Static Function RunProc7()


Local nCont := 0
Private cQuery

aAdd( aLog, Replicate( '*', 132 ) )
aAdd( aLog, PadC( cCadastro, 132 ) )
aAdd( aLog, Replicate( '*', 132 ) )
//           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
//           0         1         2         3         4         5         6         7         8         9         0         1         2         3
//                99     999999     99/99/99     99     999999999999999  XXXXXXXXXXxxxxxxxxxxXXXXXXXXXX     99     999,999,999.9999
aAdd( aLog, '   Filial   Pedido     Data Lib    Item    Produto          Descricao                         Local       Qtd Liberada' )
aAdd( aLog, Replicate( '*', 132 ) )

ProcRegua( 2 )

IncProc( 'Analisando dados...' )

cQuery := "select c9_filial, c9_pedido, c9_datalib, c9_item, c9_produto, b1_desc, c9_local, c9_qtdlib"
cQuery += " from " + RetSqlName( 'SC9' ) + " sc9, " + RetSqlName( 'SB1' ) + " sb1"
cQuery += " where c9_filial in ( " + cFilImd + " )"
cQuery += " and sc9.D_E_L_E_T_ = ' '"
cQuery += " and not exists ("
cQuery += "  select c6_num"
cQuery += "  from " + RetSqlName( 'SC6' ) + " sc6"
cQuery += "  where c6_filial = sc9.c9_filial"
cQuery += "  and c6_num = sc9.c9_pedido"
cQuery += "  and c6_item = sc9.c9_item"
cQuery += "  and sc6.D_E_L_E_T_ = ' ' )"
cQuery += " and b1_filial = c9_filial"
cQuery += " and b1_cod = c9_produto"
cQuery += " and sb1.D_E_L_E_T_ = ' '"
cQuery += " order by c9_filial, c9_pedido, c9_item"

MEMOWRIT("C:\SQLSIGA\TMPM080_RUNPROC7_SC9TMP.TXT", cQuery)

dbUseArea( .t., 'TOPCONN', TCGenQry( ,, cQuery ), 'SC9TMP', .t., .t. )

TCSetField( 'SC9TMP', 'C9_DATALIB', 'D',  8, 0 )
TCSetField( 'SC9TMP', 'C9_QTDLIB' , 'N', 14, 4 )

dbSelectArea( 'SC9TMP' )
dbGoTop()

While !Eof()
	
	IncProc( 'Processando Filial: ' + SC9TMP->C9_FILIAL + '  Pedido: ' + AllTrim( SC9TMP->C9_PEDIDO ) )
	
	aAdd( aLog, Space( 5 ) + SC9TMP->C9_FILIAL + ;
				Space( 5 ) + SC9TMP->C9_PEDIDO + ;
				Space( 5 ) + DtoC( SC9TMP->C9_DATALIB ) + ;
			    Space( 5 ) + SC9TMP->C9_ITEM + ;
			    Space( 5 ) + SC9TMP->C9_PRODUTO + ;
			    Space( 2 ) + SC9TMP->B1_DESC + ;
				Space( 5 ) + SC9TMP->C9_LOCAL + ;
				Space( 5 ) + Transform( SC9TMP->C9_QTDLIB, '@E 999,999,999.9999' ) )
	nCont ++
	
	dbSkip()
End

aAdd( aLog, ' ' )
aAdd( aLog, 'Numero de Inconsistencias   >>' + Transform( nCont, '@E 999,999' ) )

SC9TMP->( dbCloseArea() )

Return


********************************************************************************
Static Function RunProc8()


Local nCont := 0
Private cQuery

aAdd( aLog, Replicate( '*', 132 ) )
aAdd( aLog, PadC( cCadastro, 132 ) )
aAdd( aLog, Replicate( '*', 132 ) )
//           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
//           0         1         2         3         4         5         6         7         8         9         0         1         2         3
//                99     999999     99     999999999999999  XXXXXXXXXXxxxxxxxxxxXXXXXXXXXX     99     999,999,999.9999     999,999,999.9999
aAdd( aLog, '   Filial   Pedido    Item    Produto          Descricao                         Local        Qtd Vendida         Qtd Liberada' )
aAdd( aLog, Replicate( '*', 132 ) )

ProcRegua( 2 )

IncProc( 'Analisando dados...' )

cQuery := "select c6_filial, c6_num, c6_item, c6_produto, b1_desc, c6_local, c6_qtdven, c9_qtdlib"
cQuery += " from " + RetSqlName( 'SC6' ) + " sc6, sb1010 sb1, ("
cQuery += "  select c9_filial, c9_pedido, c9_item, sum( c9_qtdlib ) c9_qtdlib"
cQuery += "  from " + RetSqlName( 'SC9' ) + " sc9"
cQuery += "  where c9_filial in ( " + cFilImd + " )"
cQuery += "  and sc9.D_E_L_E_T_ = ' '"
cQuery += "  group by c9_filial, c9_pedido, c9_item )"
cQuery += " where c6_filial = c9_filial"
cQuery += " and c6_num = c9_pedido"
cQuery += " and c6_item = c9_item"
cQuery += " and sc6.D_E_L_E_T_ = ' '"
cQuery += " and c9_qtdlib > c6_qtdven"
cQuery += " and b1_filial = c6_filial"
cQuery += " and b1_cod = c6_produto"
cQuery += " and sb1.D_E_L_E_T_ = ' '"
cQuery += " order by c6_filial, c6_num, c6_item"

MEMOWRIT("C:\SQLSIGA\TMPM080_RUNPROC8_SC6TMP.TXT", cQuery)

dbUseArea( .t., 'TOPCONN', TCGenQry( ,, cQuery ), 'SC6TMP', .t., .t. )

TCSetField( 'SC6TMP', 'C6_QTDVEN' , 'N', 14, 4 )
TCSetField( 'SC6TMP', 'C9_QTDLIB' , 'N', 14, 4 )

dbSelectArea( 'SC6TMP' )
dbGoTop()

While !Eof()
	
	IncProc( 'Processando Filial: ' + SC6TMP->C6_FILIAL + '  Pedido: ' + AllTrim( SC6TMP->C6_NUM ) )
	
	aAdd( aLog, Space( 5 ) + SC6TMP->C6_FILIAL + ;
				Space( 5 ) + SC6TMP->C6_NUM + ;
			    Space( 5 ) + SC6TMP->C6_ITEM + ;
			    Space( 5 ) + SC6TMP->C6_PRODUTO + ;
			    Space( 2 ) + SC6TMP->B1_DESC + ;
				Space( 5 ) + SC6TMP->C6_LOCAL + ;
				Space( 5 ) + Transform( SC6TMP->C6_QTDVEN, '@E 999,999,999.9999' ) + ;
				Space( 5 ) + Transform( SC6TMP->C9_QTDLIB, '@E 999,999,999.9999' ) )
	nCont ++
	
	dbSkip()
End

aAdd( aLog, ' ' )
aAdd( aLog, 'Numero de Inconsistencias   >>' + Transform( nCont, '@E 999,999' ) )

SC6TMP->( dbCloseArea() )

Return


********************************************************************************
Static Function RunProc9()


Local nCont := 0
Private cQuery

aAdd( aLog, Replicate( '*', 132 ) )
aAdd( aLog, PadC( cCadastro, 132 ) )
aAdd( aLog, Replicate( '*', 132 ) )
//           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
//           0         1         2         3         4         5         6         7         8         9         0         1         2         3
//                99     999999     99/99/99     99     999999999999999  XXXXXXXXXXxxxxxxxxxxXXXXXXXXXX     99     999,999,999.9999
aAdd( aLog, '   Filial   Pedido     Dt Liber    Item    Produto          Descricao                         Local       Qtd Liberada' )
aAdd( aLog, Replicate( '*', 132 ) )

ProcRegua( 2 )

IncProc( 'Analisando dados...' )

cQuery := "select c9_filial, c9_pedido, c9_datalib, c9_item, c9_produto, b1_desc, c9_local, c9_qtdlib"
cQuery += " from " + RetSqlName( 'SC9' ) + " sc9, " + RetSqlName( 'SC6' ) + " sc6, " 
cQuery += RetSqlName( 'SC7' ) + " sc7, " + RetSqlName( 'SB1' ) + " sb1"
cQuery += " where c9_filial in ( " + cFilImd + " )"
cQuery += " and c9_serienf = ' '"
cQuery += " and c9_nfiscal = ' '"
cQuery += " and c9_blest = ' '"
cQuery += " and sc9.D_E_L_E_T_ = ' '"
cQuery += " and c6_filial = c9_filial"
cQuery += " and c6_num  = c9_pedido"
cQuery += " and c6_item = c9_item"
cQuery += " and sc6.D_E_L_E_T_ = ' '"
cQuery += " and c6_cli <> '" + cImdepa + "'"
cQuery += " and c6_planilh || c6_filtran > ' ' "
cQuery += " and c7_filial = c6_filial "
cQuery += " and c7_planilh = c6_planilh "
cQuery += " and c7_plitem = c6_plitem "
cQuery += " and c7_quje = 0 "
cQuery += " and C7_RESIDUO <>'S'"
cQuery += " and sc7.D_E_L_E_T_ = ' '"
cQuery += " and b1_filial = c6_filial"
cQuery += " and b1_cod = c6_produto"
cQuery += " and sb1.D_E_L_E_T_ = ' '"
cQuery += " order by c9_filial, c9_pedido, c9_item"     

MEMOWRIT("C:\SQLSIGA\TMPM080_RUNPROC9_SC9TMP.TXT", cQuery)

dbUseArea( .t., 'TOPCONN', TCGenQry( ,, cQuery ), 'SC9TMP', .t., .t. )

TCSetField( 'SC9TMP', 'C9_DATALIB', 'D',  8, 0 )
TCSetField( 'SC9TMP', 'C9_QTDLIB' , 'N', 14, 4 )

dbSelectArea( 'SC9TMP' )
dbGoTop()

While !Eof()
	
	IncProc( 'Processando Filial: ' + SC9TMP->C9_FILIAL + '  Pedido: ' + AllTrim( SC9TMP->C9_PEDIDO ) )
	
	aAdd( aLog, Space( 5 ) + SC9TMP->C9_FILIAL + ;
				Space( 5 ) + SC9TMP->C9_PEDIDO + ;
			    Space( 5 ) + DtoC( SC9TMP->C9_DATALIB ) + ;
			    Space( 5 ) + SC9TMP->C9_ITEM + ;
			    Space( 5 ) + SC9TMP->C9_PRODUTO + ;
			    Space( 2 ) + SC9TMP->B1_DESC + ;
				Space( 5 ) + SC9TMP->C9_LOCAL + ;
				Space( 5 ) + Transform( SC9TMP->C9_QTDLIB, '@E 999,999,999.9999' ) )
	nCont ++
	
	dbSkip()
End

aAdd( aLog, ' ' )
aAdd( aLog, 'Numero de Inconsistencias   >>' + Transform( nCont, '@E 999,999' ) )

SC9TMP->( dbCloseArea() )

Return


********************************************************************************
Static Function RunProc10()


Local nCont := 0
Private cQuery

aAdd( aLog, Replicate( '*', 132 ) )
aAdd( aLog, PadC( cCadastro, 132 ) )
aAdd( aLog, Replicate( '*', 132 ) )
//           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
//           0         1         2         3         4         5         6         7         8         9         0         1         2         3
//                99     999999     99     999999999999999  XXXXXXXXXXxxxxxxxxxxXXXXXXXXXX     99     999,999,999.9999     999,999,999.9999
aAdd( aLog, '   Filial   Pedido    Item    Produto          Descricao                         Local      Qtd Bloqueada      Transf Entregue' )
aAdd( aLog, Replicate( '*', 132 ) )

ProcRegua( 2 )

IncProc( 'Analisando dados...' )

cQuery := "select c9_filial, c9_pedido, c9_item, c9_produto, b1_desc, c9_local, c9_qtdlib, c7_quje, c9_blcred"
cQuery += " from " + RetSqlName( 'SC9' ) + " sc9, " + RetSqlName( 'SC6' ) + " sc6, "
cQuery += RetSqlName( 'SC7' ) + " sc7, " + RetSqlName( 'SB1' ) + " sb1 "
cQuery += " where c9_filial in ( " + cFilImd + " )"
cQuery += " and c9_serienf = ' '"
cQuery += " and c9_nfiscal = ' '"
cQuery += " and c9_blest = '02'"
cQuery += " and sc9.D_E_L_E_T_ = ' '"
cQuery += " and c6_filial = c9_filial"
cQuery += " and c6_num  = c9_pedido"
cQuery += " and c6_item = c9_item"
cQuery += " and sc6.D_E_L_E_T_ = ' '"
cQuery += " and c6_cli <> '" + cImdepa + "'"
cQuery += " and c6_planilh || c6_filtran > ' '"
cQuery += " and c7_filial = c6_filial"
cQuery += " and c7_planilh = c6_planilh"
cQuery += " and c7_plitem = c6_plitem"
cQuery += " and c7_quje > 0"         
cQuery += " and C7_RESIDUO <>'S'" //marcio
cQuery += " and sc7.D_E_L_E_T_ = ' '"
cQuery += " and b1_filial = c6_filial"
cQuery += " and b1_cod = c6_produto"
cQuery += " and sb1.D_E_L_E_T_ = ' '"
cQuery += " order by c9_filial, c9_pedido, c9_item"
                                   
MEMOWRIT("C:\SQLSIGA\TMPM080_RUNPROC10_SC9TMP.TXT", cQuery)

dbUseArea( .t., 'TOPCONN', TCGenQry( ,, cQuery ), 'SC9TMP', .t., .t. )

TCSetField( 'SC9TMP', 'C9_QTDLIB' , 'N', 14, 4 )
TCSetField( 'SC9TMP', 'C7_QUJE'   , 'N', 14, 4 )

dbSelectArea( 'SC9TMP' )
dbGoTop()

While !Eof()
	
	IncProc( 'Processando Filial: ' + SC9TMP->C9_FILIAL + '  Pedido: ' + AllTrim( SC9TMP->C9_PEDIDO ) )
	
	aAdd( aLog, Space( 5 ) + SC9TMP->C9_FILIAL + ;
				Space( 5 ) + SC9TMP->C9_PEDIDO + ;
			    Space( 5 ) + SC9TMP->C9_ITEM + ;
			    Space( 5 ) + SC9TMP->C9_PRODUTO + ;
			    Space( 2 ) + SC9TMP->B1_DESC + ;
				Space( 5 ) + SC9TMP->C9_LOCAL + ;
				Space( 5 ) + Transform( SC9TMP->C9_QTDLIB, '@E 999,999,999.9999' ) + ;
				Space( 5 ) + Transform( SC9TMP->C7_QUJE, '@E 999,999,999.9999' ) )
	nCont ++
	
	dbSkip()
End

aAdd( aLog, ' ' )
aAdd( aLog, 'Numero de Inconsistencias   >>' + Transform( nCont, '@E 999,999' ) )

SC9TMP->( dbCloseArea() )

Return


********************************************************************************
Static Function RunProc11()


Local nCont := 0
Private cQuery

aAdd( aLog, Replicate( '*', 132 ) )
aAdd( aLog, PadC( cCadastro, 132 ) )
aAdd( aLog, Replicate( '*', 132 ) )
//           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
//           0         1         2         3         4         5         6         7         8         9         0         1         2         3
//                99     999999     99     999999999999999  XXXXXXXXXXxxxxxxxxxxXXXXXXXXXX     99     999,999,999.9999     99     99
aAdd( aLog, '   Filial   Pedido    Item    Produto          Descricao                         Local      Qtd Bloqueada    Cred   Estq' )
aAdd( aLog, Replicate( '*', 132 ) )

ProcRegua( 2 )

IncProc( 'Analisando dados...' )

cQuery := "select c9_filial, c9_pedido, c9_datalib, c9_item, c9_produto, b1_desc, c9_local, c9_qtdlib, c9_blcred, c9_blest"
cQuery += " from " + RetSqlName( 'SC9' ) + " sc9, " + RetSqlName( 'SC6' ) + " sc6, "
cQuery += RetSqlName( 'SC5' ) + " sc5, " + RetSqlName( 'SB1' ) + " sb1"
cQuery += " where c9_filial in ( " + cFilImd + " )"
cQuery += " and c9_serienf = ' '"
cQuery += " and c9_nfiscal = ' '"
cQuery += " and c9_blest > ' '"
cQuery += " and sc9.D_E_L_E_T_ = ' '"
cQuery += " and c6_filial = c9_filial"
cQuery += " and c6_num = c9_pedido"
cQuery += " and c6_item = c9_item"
cQuery += " and sc6.D_E_L_E_T_ = ' '"
cQuery += " and c6_cli <> '" + cImdepa + "'"
cQuery += " and c6_planilh || c6_filtran = ' '"
cQuery += " and c5_filial = c6_filial"
cQuery += " and c5_num = c6_num"
cQuery += " and c5_tipo <> 'D'"
cQuery += " and sc5.D_E_L_E_T_ = ' '"
cQuery += " and b1_filial = c6_filial"
cQuery += " and b1_cod = c6_produto"
cQuery += " and sb1.D_E_L_E_T_ = ' '"
cQuery += " order by c9_filial, c9_pedido, c9_item"

MEMOWRIT("C:\SQLSIGA\TMPM080_RUNPROC11_SC9TMP.TXT", cQuery)

dbUseArea( .t., 'TOPCONN', TCGenQry( ,, cQuery ), 'SC9TMP', .t., .t. )

TCSetField( 'SC9TMP', 'C9_DATALIB', 'D',  8, 0 )
TCSetField( 'SC9TMP', 'C9_QTDLIB' , 'N', 14, 4 )

dbSelectArea( 'SC9TMP' )
dbGoTop()

While !Eof()
	
	IncProc( 'Processando Filial: ' + SC9TMP->C9_FILIAL + '  Pedido: ' + AllTrim( SC9TMP->C9_PEDIDO ) )
	
	aAdd( aLog, Space( 5 ) + SC9TMP->C9_FILIAL + ;
				Space( 5 ) + SC9TMP->C9_PEDIDO + ;
			    Space( 5 ) + SC9TMP->C9_ITEM + ;
			    Space( 5 ) + SC9TMP->C9_PRODUTO + ;
			    Space( 2 ) + SC9TMP->B1_DESC + ;
				Space( 5 ) + SC9TMP->C9_LOCAL + ;
				Space( 5 ) + Transform( SC9TMP->C9_QTDLIB, '@E 999,999,999.9999' ) + ;
				Space( 5 ) + SC9TMP->C9_BLCRED + ;
				Space( 5 ) + SC9TMP->C9_BLEST )
	nCont ++
	
	dbSkip()
End

aAdd( aLog, ' ' )
aAdd( aLog, 'Numero de Inconsistencias   >>' + Transform( nCont, '@E 999,999' ) )

SC9TMP->( dbCloseArea() )

Return


********************************************************************************
Static Function RunProc12()


Local nCont := 0
Private cQuery

aAdd( aLog, Replicate( '*', 132 ) )
aAdd( aLog, PadC( cCadastro, 132 ) )
aAdd( aLog, Replicate( '*', 132 ) )
//           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
//           0         1         2         3         4         5         6         7         8         9         0         1         2         3
//                99     999999     99     999999999999999  XXXXXXXXXXxxxxxxxxxxXXXXXXXXXX     99     999,999,999.9999     99     99
aAdd( aLog, '   Filial   Pedido    Item    Produto          Descricao                         Local      Qtd Bloqueada    Cred   Estq' )
aAdd( aLog, Replicate( '*', 132 ) )

ProcRegua( 2 )

IncProc( 'Analisando dados...' )

cQuery := "select c9_filial, c9_pedido, c9_datalib, c9_item, c9_produto, b1_desc, c9_local, c9_qtdlib, c9_blcred, c9_blest"
cQuery += " from " + RetSqlName( 'SC9' ) + " sc9, " + RetSqlName( 'SC6' ) + " sc6, " + RetSqlName( 'SB1' ) + " sb1"
cQuery += " where c9_filial in ( " + cFilImd + " )"
cQuery += " and c9_serienf = ' '"
cQuery += " and c9_nfiscal = ' '"
cQuery += " and c9_blest > ' '"
cQuery += " and sc9.D_E_L_E_T_ = ' '"
cQuery += " and c6_filial = c9_filial"
cQuery += " and c6_num  = c9_pedido"
cQuery += " and c6_item = c9_item"
cQuery += " and sc6.D_E_L_E_T_ = ' '"
cQuery += " and c6_cli = '" + cImdepa + "'"
cQuery += " and c6_planilh || c6_filtran > ' '"
cQuery += " and b1_filial = c6_filial"
cQuery += " and b1_cod = c6_produto"
cQuery += " and sb1.D_E_L_E_T_ = ' '"
cQuery += " order by c9_filial, c9_pedido, c9_item"

MEMOWRIT("C:\SQLSIGA\TMPM080_RUNPROC12_SC9TMP.TXT", cQuery)

dbUseArea( .t., 'TOPCONN', TCGenQry( ,, cQuery ), 'SC9TMP', .t., .t. )

TCSetField( 'SC9TMP', 'C9_DATALIB', 'D',  8, 0 )
TCSetField( 'SC9TMP', 'C9_QTDLIB' , 'N', 14, 4 )

dbSelectArea( 'SC9TMP' )
dbGoTop()

While !Eof()
	
	IncProc( 'Processando Filial: ' + SC9TMP->C9_FILIAL + '  Pedido: ' + AllTrim( SC9TMP->C9_PEDIDO ) )
	
	aAdd( aLog, Space( 5 ) + SC9TMP->C9_FILIAL + ;
				Space( 5 ) + SC9TMP->C9_PEDIDO + ;
			    Space( 5 ) + SC9TMP->C9_ITEM + ;
			    Space( 5 ) + SC9TMP->C9_PRODUTO + ;
			    Space( 2 ) + SC9TMP->B1_DESC + ;
				Space( 5 ) + SC9TMP->C9_LOCAL + ;
				Space( 5 ) + Transform( SC9TMP->C9_QTDLIB, '@E 999,999,999.9999' ) + ;
				Space( 5 ) + SC9TMP->C9_BLCRED + ;
				Space( 5 ) + SC9TMP->C9_BLEST )
	nCont ++
	
	dbSkip()
End

aAdd( aLog, ' ' )
aAdd( aLog, 'Numero de Inconsistencias   >>' + Transform( nCont, '@E 999,999' ) )

SC9TMP->( dbCloseArea() )

Return


********************************************************************************
Static Function RunProc13()


Local nCont := 0
Private cQuery

aAdd( aLog, Replicate( '*', 132 ) )
aAdd( aLog, PadC( cCadastro, 132 ) )
aAdd( aLog, Replicate( '*', 132 ) )
//           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
//           0         1         2         3         4         5         6         7         8         9         0         1         2         3
//                99     999999     XXX     99     999999     99     999999999999999  XXXXXXXXXXxxxxxxxxxxXXXXXXXXXX     99     999,999,999.9999
aAdd( aLog, '   Filial  Documento  Serie   Item    Pedido    Item    Produto          Descricao                         Local       Qtd Faturada' )
aAdd( aLog, Replicate( '*', 132 ) )

ProcRegua( 2 )

IncProc( 'Analisando dados...' )

cQuery := "select d2_filial, d2_doc, d2_serie, d2_item, d2_pedido, d2_itempv, d2_cod, b1_desc, d2_local, d2_quant"
cQuery += " from " + RetSqlName( 'SD2' ) + " sd2, " + RetSqlName( 'SB1' ) + " sb1"
cQuery += " where d2_filial in ( " + cFilImd + " )"
cQuery += " and d2_emissao > '20031101'"
cQuery += " and sd2.D_E_L_E_T_ = ' '"
cQuery += " and not exists ("
cQuery += "  select c9_pedido"
cQuery += "  from " + RetSqlName( 'SC9' ) + " sc9"
cQuery += "  where c9_filial = sd2.d2_filial"
cQuery += "  and c9_pedido = sd2.d2_pedido"
cQuery += "  and c9_item = sd2.d2_itempv"
cQuery += "  and c9_nfiscal = sd2.d2_doc"
cQuery += "  and c9_serienf = sd2.d2_serie"
cQuery += "  and c9_blest = '10'"
cQuery += "  and c9_blcred = '10'"
cQuery += "  and sc9.D_E_L_E_T_ = ' ' )"
cQuery += " and b1_filial = d2_filial"
cQuery += " and b1_cod = d2_cod"
cQuery += " and sb1.D_E_L_E_T_ = ' '"
cQuery += " order by d2_filial, d2_doc, d2_serie, d2_item"

MEMOWRIT("C:\SQLSIGA\TMPM080_RUNPROC13_SD2TMP.TXT", cQuery)

dbUseArea( .t., 'TOPCONN', TCGenQry( ,, cQuery ), 'SD2TMP', .t., .t. )

TCSetField( 'SD2TMP', 'D2_QUANT' , 'N', 14, 4 )

dbSelectArea( 'SD2TMP' )
dbGoTop()

While !Eof()
	
	IncProc( 'Processando Filial: ' + SD2TMP->D2_FILIAL + '  Documento: ' + AllTrim( SD2TMP->D2_DOC ) )
	
	aAdd( aLog, Space( 5 ) + SD2TMP->D2_FILIAL + ;
				Space( 5 ) + SD2TMP->D2_DOC + ;
				Space( 5 ) + SD2TMP->D2_SERIE + ;
				Space( 5 ) + SD2TMP->D2_ITEM + ;
				Space( 5 ) + SD2TMP->D2_PEDIDO + ;
			    Space( 5 ) + SD2TMP->D2_ITEMPV + ;
			    Space( 5 ) + SD2TMP->D2_COD + ;
			    Space( 2 ) + SD2TMP->B1_DESC + ;
				Space( 5 ) + SD2TMP->D2_LOCAL + ;
				Space( 5 ) + Transform( SD2TMP->D2_QUANT, '@E 999,999,999.9999' ) )
	nCont ++
	
	dbSkip()
End

aAdd( aLog, ' ' )
aAdd( aLog, 'Numero de Inconsistencias   >>' + Transform( nCont, '@E 999,999' ) )

SD2TMP->( dbCloseArea() )

Return


********************************************************************************
Static Function Print()


Private cString   := 'SB1'
Private cTitulo   := 'Consistencias na Base de Dados'
Private cDesc1    := OemToAnsi( 'Este programa vai imprimir um log de inconsistencias encontradas.' )
Private cDesc2    := OemToAnsi( 'na base de dados.' )
Private cDesc3    := OemToAnsi( '' )
Private cCabec1   := ''
Private cCabec2   := ''
Private aReturn   := { 'Zebrado', 1,'Administracao', 1, 2, 1, '',1 }
Private cNomeProg := 'TMPM080'
Private cTamanho  := 'G'
Private nLastKey  := 0
Private m_pag     := 1
Private wnrel     := SetPrint( cString, cNomeProg,, cTitulo, cDesc1, cDesc2, cDesc3, .f., '', .t., cTamanho,, .f. )

If nLastKey == 27
	Set Filter to
	Return
EndIf

SetDefault( aReturn, cString )

If nLastKey == 27
	Set Filter to
	Return
EndIf

RptStatus({|| RunPrint() } )

Return


********************************************************************************
Static Function RunPrint()


Local nTamLog := Len( aLog )
Local nPos

SetRegua( nTamLog )

For nPos := 1 to Len( aLog )
	
	IncRegua()
	
	If pRow() > 58 .or. m_pag == 1
		
		Cabec( cTitulo, cCabec1, cCabec2, cNomeProg, cTamanho )
	EndIf
	
	@ pRow()+1,000 pSay aLog[ nPos ]
	
Next nPos

Roda( 0, '', 'M' )

If aReturn[5] == 1
	Set Printer to
	Commit
	OurSpool( wnrel )
EndIf
Ms_Flush()

Return


********************************************************************************
Static Function Ajuste3()


Local nCont := 0
Private cQuery

ProcRegua( 2 )

IncProc( 'Analisando dados...' )

cQuery := "select c6_filial, c6_num, d2_emissao, c6_item, c6_produto, b1_desc, c6_local, c6_qtdven"
cQuery += " from " + RetSqlName( 'SC6' ) + " sc6, " + RetSqlName( 'SD2' ) + " sd2, " + RetSqlName( 'SB1' ) + " sb1"
cQuery += " where c6_filial in ( " + cFilImd + " )"
cQuery += " and c6_qtdent = 0"
cQuery += " and c6_qtdven > 0"
cQuery += " and sc6.D_E_L_E_T_ = ' '"
cQuery += " and d2_filial = c6_filial"
cQuery += " and d2_pedido = c6_num"
cQuery += " and d2_itempv = c6_item"
cQuery += " and d2_cod = c6_produto"
cQuery += " and d2_quant = c6_qtdven"
cQuery += " and sd2.D_E_L_E_T_ = ' '"
cQuery += " and b1_filial = c6_filial"
cQuery += " and b1_cod = c6_produto "
cQuery += " and sb1.D_E_L_E_T_ = ' '"
cQuery += " order by c6_filial, c6_num, c6_item"

MEMOWRIT("C:\SQLSIGA\TMPM080_AJUSTE3_SC6TMP.TXT", cQuery)

dbUseArea( .t., 'TOPCONN', TCGenQry( ,, cQuery ), 'SC6TMP', .t., .t. )

TCSetField( 'SC6TMP', 'D2_EMISSAO', 'D',  8, 0 )
TCSetField( 'SC6TMP', 'C6_QTDVEN' , 'N', 14, 4 )

SC6->( dbSetOrder( 1 ) )

SC6TMP->( dbGoTop() )

While SC6TMP->( !Eof() )
	
	IncProc( 'Processando Filial: ' + SC6TMP->C6_FILIAL + '  Pedido: ' + AllTrim( SC6TMP->C6_NUM ) )
	
	If SC6->( dbSeek( SC6TMP->C6_FILIAL + SC6TMP->C6_NUM + SC6TMP->C6_ITEM + SC6TMP->C6_PRODUTO, .f. ) )
		
		SC6->( RecLock( 'SC6', .f. ) )
		SC6->C6_QTDENT	:= SC6TMP->C6_QTDVEN
		SC6->( MsUnlock() )
		
		nCont ++
	EndIf
	
	SC6TMP->( dbSkip() )
End

MsgInfo( 'Numero de Ajustes >> ' + Transform( nCont, '@E 999,999' ), cCadastro )

SC6TMP->( dbCloseArea() )

Return


********************************************************************************
Static Function Ajuste4()


Local nCont := 0
Private cQuery

ProcRegua( 2 )

IncProc( 'Analisando dados...' )

cQuery := "select b2_filial, b2_cod, b1_desc, b2_local, b2_reserva, c9_qtdlib"
cQuery += " from "  + RetSqlName( 'SB2' ) + " sb2, "  + RetSqlName( 'SB1' ) + " sb1, ("
cQuery += "  select c9_filial, c9_produto, c9_local, sum( c9_qtdlib ) c9_qtdlib"
cQuery += "  from "  + RetSqlName( 'SC9' ) + " sc9, "  + RetSqlName( 'SC6' ) + " sc6, "  + RetSqlName( 'SF4' ) + " sf4"
cQuery += "  where c9_filial in ( " + cFilImd + " )"
cQuery += "  and c9_serienf = ' '"
cQuery += "  and c9_nfiscal = ' '"
cQuery += "  and c9_blest = ' '"
cQuery += "  and c9_blcred = ' '"
cQuery += "  and sc9.D_E_L_E_T_ = ' '"
cQuery += "  and c6_filial = c9_filial"
cQuery += "  and c6_num = c9_pedido"
cQuery += "  and c6_item = c9_item"
cQuery += "  and sc6.D_E_L_E_T_ = ' '"
cQuery += "  and f4_filial = c6_filial"
cQuery += "  and f4_codigo = c6_tes"
cQuery += "  and f4_estoque = 'S'"
cQuery += "  and sf4.D_E_L_E_T_ = ' '"
cQuery += "  group by c9_filial, c9_produto, c9_local )"
cQuery += " where b2_filial in ( " + cFilImd + " )"
cQuery += " and sb2.D_E_L_E_T_ = ' '"
cQuery += " and c9_filial = b2_filial"
cQuery += " and c9_produto = b2_cod"
cQuery += " and c9_local = b2_local"
cQuery += " and c9_qtdlib <> b2_reserva"
cQuery += " and b1_filial = b2_filial"
cQuery += " and b1_cod = b2_cod "
cQuery += " and sb1.D_E_L_E_T_ = ' '"
cQuery += "union all "
cQuery += "select b2_filial, b2_cod, b1_desc, b2_local, b2_reserva, 0 c9_qtdlib"
cQuery += " from "  + RetSqlName( 'SB2' ) + " sb2, "  + RetSqlName( 'SB1' ) + " sb1"
cQuery += " where b2_filial in ( " + cFilImd + " )"
cQuery += " and b2_reserva <> 0"
cQuery += " and sb2.D_E_L_E_T_ = ' '"
cQuery += " and not exists ( "
cQuery += "  select c9_filial"
cQuery += "  from "  + RetSqlName( 'SC9' ) + " sc9, "  + RetSqlName( 'SC6' ) + " sc6, "  + RetSqlName( 'SF4' ) + " sf4"
cQuery += "  where c9_filial in ( " + cFilImd + " )"
cQuery += "  and c9_serienf = ' '"
cQuery += "  and c9_nfiscal = ' '"
cQuery += "  and c9_blest = ' '"
cQuery += "  and c9_blcred = ' '"
cQuery += "  and sc9.D_E_L_E_T_ = ' '"
cQuery += "  and c9_filial = b2_filial"
cQuery += "  and c9_produto = b2_cod"
cQuery += "  and c9_local = b2_local"
cQuery += "  and c6_filial = c9_filial"
cQuery += "  and c6_num = c9_pedido"
cQuery += "  and c6_item = c9_item"
cQuery += "  and sc6.D_E_L_E_T_ = ' '"
cQuery += "  and f4_filial = c6_filial"
cQuery += "  and f4_codigo = c6_tes"
cQuery += "  and f4_estoque = 'S'"
cQuery += "  and sf4.D_E_L_E_T_ = ' ' )"
cQuery += " and b1_filial = b2_filial"
cQuery += " and b1_cod = b2_cod "
cQuery += " and sb1.D_E_L_E_T_ = ' '"
cQuery += "order by b2_filial, b2_cod, b2_local"

MEMOWRIT("C:\SQLSIGA\TMPM080_AJUSTE4_SB2TMP.TXT", cQuery)

dbUseArea( .t., 'TOPCONN', TCGenQry( ,, cQuery ), 'SB2TMP', .t., .t. )

TCSetField( 'SB2TMP', 'B2_RESERVA', 'N', 14, 4 )
TCSetField( 'SB2TMP', 'C9_QTDLIB' , 'N', 14, 4 )

SB2->( dbSetOrder( 1 ) )

SB2TMP->( dbGoTop() )

While SB2TMP->( !Eof() )
	
	IncProc( 'Processando Filial: ' + SB2TMP->B2_FILIAL + '  Produto: ' + AllTrim( SB2TMP->B2_COD ) + '  Local: ' + SB2TMP->B2_LOCAL )
	
	If SB2->( dbSeek( SB2TMP->B2_FILIAL + SB2TMP->B2_COD + SB2TMP->B2_LOCAL, .f. ) )
		
		SB2->( RecLock( 'SB2', .f. ) )
		SB2->B2_RESERVA := SB2TMP->C9_QTDLIB
		SB2->( MsUnlock() )
		
		nCont ++
	EndIf
	
	SB2TMP->( dbSkip() )
End

MsgInfo( 'Numero de Ajustes >> ' + Transform( nCont, '@E 999,999' ), cCadastro )

SB2TMP->( dbCloseArea() )

Return


********************************************************************************
Static Function Ajuste5()


Local nCont := 0
Private cQuery

ProcRegua( 2 )

IncProc( 'Analisando dados...' )

cQuery := "select b2_filial, b2_cod, b1_desc, b2_local, b2_qpedven, qtdpend"
cQuery += " from " + RetSqlName( 'SB2' ) + " sb2, " + RetSqlName( 'SB1' ) + " sb1, ( " 
cQuery += "  select c6_filial, c6_produto, c6_local, sum( qtdpend ) qtdpend"
cQuery += "   from ("
cQuery += "   select c6_filial, c6_produto, c6_local, sum( c6_qtdven - c6_qtdent ) qtdpend"
cQuery += "    from " + RetSqlName( 'SC6' ) + " sc6, " + RetSqlName( 'SF4' ) + " sf4"
cQuery += "    where c6_filial in ( " + cFilImd + " )"
cQuery += "    and c6_blq in ( ' ', 'N' )"
cQuery += "    and ( c6_qtdven - c6_qtdent ) > 0"
cQuery += "    and sc6.D_E_L_E_T_ = ' '"
cQuery += "    and f4_filial = c6_filial"
cQuery += "    and f4_codigo = c6_tes"
cQuery += "    and f4_estoque = 'S'"
cQuery += "    and sf4.D_E_L_E_T_ = ' '"
cQuery += "    group by c6_filial, c6_produto, c6_local"
cQuery += "   union all"
cQuery += "   select c9_filial c6_filial, c9_produto c6_produto, "
cQuery += "    c9_local c6_local, sum( c9_qtdlib * -1 ) qtdpend"
cQuery += "    from " + RetSqlName( 'SC9' ) + " sc9, "  + RetSqlName( 'SC6' ) + " sc6, "  + RetSqlName( 'SF4' ) + " sf4"
cQuery += "    where c9_filial in ( " + cFilImd + " )"
cQuery += "    and c9_serienf = ' '"
cQuery += "    and c9_nfiscal = ' '"
cQuery += "    and c9_blest = ' '"
cQuery += "    and c9_blcred = ' '"
cQuery += "    and sc9.D_E_L_E_T_ = ' '"
cQuery += "    and c6_filial = c9_filial"
cQuery += "    and c6_num = c9_pedido"
cQuery += "    and c6_item = c9_item"
cQuery += "    and sc6.D_E_L_E_T_ = ' '"
cQuery += "    and f4_filial = c6_filial"
cQuery += "    and f4_codigo = c6_tes"
cQuery += "    and f4_estoque = 'S'"
cQuery += "    and sf4.D_E_L_E_T_ = ' '"
cQuery += "    group by c9_filial, c9_produto, c9_local )"
cQuery += "  group by c6_filial, c6_produto, c6_local )"
cQuery += " where b2_filial in ( " + cFilImd + " )"
cQuery += " and sb2.D_E_L_E_T_ = ' '"
cQuery += " and c6_filial = b2_filial"
cQuery += " and c6_produto = b2_cod"
cQuery += " and c6_local = b2_local"
cQuery += " and qtdpend <> b2_qpedven"
cQuery += " and b1_filial = b2_filial"
cQuery += " and b1_cod = b2_cod"
cQuery += " and sb1.D_E_L_E_T_ = ' '"
cQuery += " union all "
cQuery += " select b2_filial, b2_cod, b1_desc, b2_local, b2_qpedven, 0 qtdpend"
cQuery += " from " + RetSqlName( 'SB2' ) + " sb2, " + RetSqlName( 'SB1' ) + " sb1"
cQuery += " where b2_filial in ( " + cFilImd + " )"
cQuery += " and b2_qpedven <> 0"
cQuery += " and sb2.D_E_L_E_T_ = ' '"
cQuery += " and not exists ( "
cQuery += "  select c6_filial"
cQuery += "    from " + RetSqlName( 'SC6' ) + " sc6, " + RetSqlName( 'SF4' ) + " sf4"
cQuery += "    where c6_filial in ( " + cFilImd + " )"
cQuery += "    and c6_blq in ( ' ', 'N' )"
cQuery += "    and ( c6_qtdven - c6_qtdent ) > 0"
cQuery += "    and sc6.D_E_L_E_T_ = ' '"
cQuery += "    and f4_filial = c6_filial"
cQuery += "    and f4_codigo = c6_tes"
cQuery += "    and f4_estoque = 'S'"
cQuery += "    and sf4.D_E_L_E_T_ = ' '"
cQuery += "    and c6_filial = b2_filial"
cQuery += "    and c6_produto = b2_cod"
cQuery += "    and c6_local = b2_local )"
cQuery += " and b1_filial = b2_filial"
cQuery += " and b1_cod = b2_cod"
cQuery += " and sb1.D_E_L_E_T_ = ' '"
cQuery += "order by b2_filial, b2_cod, b2_local"

MEMOWRIT("C:\SQLSIGA\TMPM080_AJUSTE5_SB2TMP.TXT", cQuery)

dbUseArea( .t., 'TOPCONN', TCGenQry( ,, cQuery ), 'SB2TMP', .t., .t. )

TCSetField( 'SB2TMP', 'B2_QPEDVEN', 'N', 14, 4 )
TCSetField( 'SB2TMP', 'QTDPEND'   , 'N', 14, 4 )

SB2->( dbSetOrder( 1 ) )

SB2TMP->( dbGoTop() )

While SB2TMP->( !Eof() )
	
	IncProc( 'Processando Filial: ' + SB2TMP->B2_FILIAL + '  Produto: ' + AllTrim( SB2TMP->B2_COD ) + '  Local: ' + SB2TMP->B2_LOCAL )
	
	If SB2->( dbSeek( SB2TMP->B2_FILIAL + SB2TMP->B2_COD + SB2TMP->B2_LOCAL, .f. ) )
		
		SB2->( RecLock( 'SB2', .f. ) )
		If SB2TMP->QTDPEND < 0
			SB2->B2_QPEDVEN := 0
		Else		
			SB2->B2_QPEDVEN := SB2TMP->QTDPEND
		Endif	
		SB2->( MsUnlock() )
		
		nCont ++
	EndIf
	
	SB2TMP->( dbSkip() )
End

MsgInfo( 'Numero de Ajustes >> ' + Transform( nCont, '@E 999,999' ), cCadastro )

SB2TMP->( dbCloseArea() )

Return


********************************************************************************
Static Function Ajuste6()


Local nCont := 0
Private cQuery

ProcRegua( 2 )

IncProc( 'Analisando dados...' )

cQuery := "select b2_filial, b2_cod, b1_desc, b2_local, b2_salpedi, qtdprent"
cQuery += " from " + RetSqlName( 'SB2' ) + " sb2, " + RetSqlName( 'SB1' ) + " sb1, (  "
cQuery += "  select c7_filent, c7_produto, c7_local, sum( qtdprent ) qtdprent"
cQuery += "   from ("
cQuery += "   select c1_msfil c7_filent, c1_produto c7_produto, c1_local c7_local, sum( c1_quant - c1_quje ) qtdprent"
cQuery += "    from " + RetSqlName( 'SC1' ) + " sc1"
cQuery += "    where c1_filial = ' '"
cQuery += "    and c1_msfil in ( " + cFilImd + " )"
cQuery += "    and ( c1_quant - c1_quje ) > 0"
cQuery += "    and sc1.D_E_L_E_T_ = ' '"
cQuery += "    group by c1_msfil, c1_produto, c1_local"
cQuery += "   union all"
cQuery += "   select c7_filent, c7_produto, c7_local, sum( c7_quant - c7_quje ) qtdprent"
cQuery += "    from " + RetSqlName( 'SC7' ) + " sc7"
cQuery += "    where c7_filent in ( " + cFilImd + " )"
cQuery += "    and ( c7_quant - c7_quje ) > 0"
cQuery += "    and c7_tes = ' '"
cQuery += "    and sc7.D_E_L_E_T_ = ' '"
cQuery += "    and C7_RESIDUO <>'S'"  // marcio
cQuery += "    group by c7_filent, c7_produto, c7_local"
cQuery += "   union all"
cQuery += "   select c7_filent, c7_produto, c7_local, sum( c7_quant - c7_quje ) qtdprent"
cQuery += "    from " + RetSqlName( 'SC7' ) + " sc7, " + RetSqlName( 'SF4' ) + " sf4"
cQuery += "    where c7_filent in ( " + cFilImd + " )"
cQuery += "    and ( c7_quant - c7_quje ) > 0"
cQuery += "    and C7_RESIDUO <>'S'"  //marcio
cQuery += "    and sc7.D_E_L_E_T_ = ' '"
cQuery += "    and f4_filial = c7_filent"
cQuery += "    and f4_codigo = c7_tes"
cQuery += "    and f4_estoque = 'S'"
cQuery += "    and sf4.D_E_L_E_T_ = ' '"
cQuery += "    group by c7_filent, c7_produto, c7_local"
cQuery += "   union all"
cQuery += "   select c2_filial c7_filent, c2_produto c7_produto, c2_local c7_local, sum( c2_quant - c2_quje ) qtdprent"
cQuery += "    from " + RetSqlName( 'SC2' ) + " sc2"
cQuery += "    where c2_filial in ( " + cFilImd + " )"
cQuery += "    and ( c2_quant - c2_quje ) > 0"
cQuery += "    and sc2.D_E_L_E_T_ = ' '"
cQuery += "    group by c2_filial, c2_produto, c2_local )"
cQuery += "  group by c7_filent, c7_produto, c7_local )"
cQuery += " where b2_filial in ( " + cFilImd + " )"
cQuery += " and sb2.D_E_L_E_T_ = ' '"
cQuery += " and c7_filent = b2_filial"
cQuery += " and c7_produto = b2_cod"
cQuery += " and c7_local = b2_local"
cQuery += " and qtdprent <> b2_salpedi"
cQuery += " and b1_filial = b2_filial"
cQuery += " and b1_cod = b2_cod"
cQuery += " and sb1.D_E_L_E_T_ = ' ' "
cQuery += "union all "
cQuery += "select b2_filial, b2_cod, b1_desc, b2_local, b2_salpedi, 0 qtdprent"
cQuery += " from " + RetSqlName( 'SB2' ) + " sb2, " + RetSqlName( 'SB1' ) + " sb1"
cQuery += " where b2_filial in ( " + cFilImd + " )"
cQuery += " and b2_salpedi <> 0"
cQuery += " and sb2.D_E_L_E_T_ = ' '"
cQuery += " and not exists ( "
cQuery += "  select c7_filent, c7_produto, c7_local, sum( qtdprent ) qtdprent"
cQuery += "   from ("
cQuery += "   select c1_msfil c7_filent, c1_produto c7_produto, c1_local c7_local, sum( c1_quant - c1_quje ) qtdprent"
cQuery += "    from " + RetSqlName( 'SC1' ) + " sc1"
cQuery += "    where c1_filial = ' '"
cQuery += "    and c1_msfil in ( " + cFilImd + " )"
cQuery += "    and ( c1_quant - c1_quje ) > 0"
cQuery += "    and sc1.D_E_L_E_T_ = ' '"
cQuery += "    group by c1_msfil, c1_produto, c1_local"
cQuery += "   union all"
cQuery += "   select c7_filent, c7_produto, c7_local, sum( c7_quant - c7_quje ) qtdprent"
cQuery += "    from " + RetSqlName( 'SC7' ) + " sc7"
cQuery += "    where c7_filent in ( " + cFilImd + " )"
cQuery += "    and ( c7_quant - c7_quje ) > 0"
cQuery += "    and C7_RESIDUO <>'S'" //marcio
cQuery += "    and c7_tes = ' '"
cQuery += "    and sc7.D_E_L_E_T_ = ' '"
cQuery += "    group by c7_filent, c7_produto, c7_local"
cQuery += "   union all"
cQuery += "   select c7_filent, c7_produto, c7_local, sum( c7_quant - c7_quje ) qtdprent"
cQuery += "    from " + RetSqlName( 'SC7' ) + " sc7, " + RetSqlName( 'SF4' ) + " sf4"
cQuery += "    where c7_filent in ( " + cFilImd + " )"
cQuery += "    and ( c7_quant - c7_quje ) > 0"
cQuery += "    and C7_RESIDUO <>'S'" //marcio
cQuery += "    and sc7.D_E_L_E_T_ = ' '"
cQuery += "    and f4_filial = c7_filent"
cQuery += "    and f4_codigo = c7_tes"
cQuery += "    and f4_estoque = 'S'"
cQuery += "    and sf4.D_E_L_E_T_ = ' '"
cQuery += "    group by c7_filent, c7_produto, c7_local"
cQuery += "   union all"
cQuery += "   select c2_filial c7_filent, c2_produto c7_produto, c2_local c7_local, sum( c2_quant - c2_quje ) qtdprent"
cQuery += "    from " + RetSqlName( 'SC2' ) + " sc2"
cQuery += "    where c2_filial in ( " + cFilImd + " )"
cQuery += "    and ( c2_quant - c2_quje ) > 0"
cQuery += "    and sc2.D_E_L_E_T_ = ' '"
cQuery += "    group by c2_filial, c2_produto, c2_local )"
cQuery += "  where c7_filent = b2_filial"
cQuery += "  and c7_produto = b2_cod"
cQuery += "  and c7_local = b2_local )"
cQuery += " and b1_filial = b2_filial"
cQuery += " and b1_cod = b2_cod"
cQuery += " and sb1.D_E_L_E_T_ = ' '"
cQuery += "order by b2_filial, b2_cod, b2_local"         

MEMOWRIT("C:\SQLSIGA\TMPM080_AJUSTE6_SB2TMP.TXT", cQuery)

dbUseArea( .t., 'TOPCONN', TCGenQry( ,, cQuery ), 'SB2TMP', .t., .t. )

TCSetField( 'SB2TMP', 'B2_SALPEDI', 'N', 14, 4 )
TCSetField( 'SB2TMP', 'QTDPRENT'  , 'N', 14, 4 )

SB2->( dbSetOrder( 1 ) )

SB2TMP->( dbGoTop() )

While SB2TMP->( !Eof() )
	
	IncProc( 'Processando Filial: ' + SB2TMP->B2_FILIAL + '  Produto: ' + AllTrim( SB2TMP->B2_COD ) + '  Local: ' + SB2TMP->B2_LOCAL )
	
	If SB2->( dbSeek( SB2TMP->B2_FILIAL + SB2TMP->B2_COD + SB2TMP->B2_LOCAL, .f. ) )
		
		SB2->( RecLock( 'SB2', .f. ) )
		SB2->B2_SALPEDI := SB2TMP->QTDPRENT
		SB2->( MsUnlock() )
		
		nCont ++
	EndIf
	
	SB2TMP->( dbSkip() )
End

MsgInfo( 'Numero de Ajustes >> ' + Transform( nCont, '@E 999,999' ), cCadastro )

SB2TMP->( dbCloseArea() )

Return


********************************************************************************
Static Function Ajuste7()


Local nCont := 0
Private cQuery

ProcRegua( 2 )

IncProc( 'Analisando dados...' )

cQuery := "select c9_filial, c9_pedido, c9_datalib, c9_item, c9_produto, b1_desc, c9_local, c9_qtdlib"
cQuery += " from " + RetSqlName( 'SC9' ) + " sc9, " + RetSqlName( 'SB1' ) + " sb1"
cQuery += " where c9_filial in ( " + cFilImd + " )"
cQuery += " and sc9.D_E_L_E_T_ = ' '"
cQuery += " and not exists ("
cQuery += "  select c6_num"
cQuery += "  from " + RetSqlName( 'SC6' ) + " sc6"
cQuery += "  where c6_filial = sc9.c9_filial"
cQuery += "  and c6_num = sc9.c9_pedido"
cQuery += "  and c6_item = sc9.c9_item"
cQuery += "  and sc6.D_E_L_E_T_ = ' ' )"
cQuery += " and b1_filial = c9_filial"
cQuery += " and b1_cod = c9_produto"
cQuery += " and sb1.D_E_L_E_T_ = ' '"
cQuery += " order by c9_filial, c9_pedido, c9_item"

MEMOWRIT("C:\SQLSIGA\TMPM080_AJUSTE7_SC9TMP.TXT", cQuery)

dbUseArea( .t., 'TOPCONN', TCGenQry( ,, cQuery ), 'SC9TMP', .t., .t. )

TCSetField( 'SC9TMP', 'C9_DATALIB', 'D',  8, 0 )
TCSetField( 'SC9TMP', 'C9_QTDLIB' , 'N', 14, 4 )

SC9->( dbSetOrder( 1 ) )
SD2->( dbSetOrder( 8 ) )

SC9TMP->( dbGoTop() )

While SC9TMP->( !Eof() )
	
	IncProc( 'Processando Filial: ' + SC9TMP->C9_FILIAL + '  Pedido: ' + AllTrim( SC9TMP->C9_PEDIDO ) )
	
	If SD2->( !dbSeek( SC9TMP->C9_FILIAL + SC9TMP->C9_PEDIDO + SC9TMP->C9_ITEM, .f. ) )
		
		SC9->( dbSeek( SC9TMP->C9_FILIAL + SC9TMP->C9_PEDIDO + SC9TMP->C9_ITEM, .f. ) )
		
		SC9->( RecLock( 'SC9', .f. ) )
		SC9->( dbDelete() )
		SC9->( MsUnlock() )
		
		nCont ++
	EndIf
	
	SC9TMP->( dbSkip() )
End

MsgInfo( 'Numero de Ajustes >> ' + Transform( nCont, '@E 999,999' ), cCadastro )

SC9TMP->( dbCloseArea() )

Return


********************************************************************************
Static Function Ajuste8()


Local nCont := 0
Private cQuery

ProcRegua( 2 )

IncProc( 'Analisando dados...' )

cQuery := "select c6_filial, c6_num, c6_item, c6_produto, b1_desc, c6_local, c6_qtdven, c9_qtdlib"
cQuery += " from " + RetSqlName( 'SC6' ) + " sc6, sb1010 sb1, ("
cQuery += "  select c9_filial, c9_pedido, c9_item, sum( c9_qtdlib ) c9_qtdlib"
cQuery += "  from " + RetSqlName( 'SC9' ) + " sc9"
cQuery += "  where c9_filial in ( " + cFilImd + " )"
cQuery += "  and sc9.D_E_L_E_T_ = ' '"
cQuery += "  group by c9_filial, c9_pedido, c9_item )"
cQuery += " where c6_filial = c9_filial"
cQuery += " and c6_num = c9_pedido"
cQuery += " and c6_item = c9_item"
cQuery += " and sc6.D_E_L_E_T_ = ' '"
cQuery += " and c9_qtdlib > c6_qtdven"
cQuery += " and b1_filial = c6_filial"
cQuery += " and b1_cod = c6_produto"
cQuery += " and sb1.D_E_L_E_T_ = ' '"
cQuery += " order by c6_filial, c6_num, c6_item"

MEMOWRIT("C:\SQLSIGA\TMPM080_AJUSTE8_SC6TMP.TXT", cQuery)

dbUseArea( .t., 'TOPCONN', TCGenQry( ,, cQuery ), 'SC6TMP', .t., .t. )

TCSetField( 'SC6TMP', 'D2_EMISSAO', 'D',  8, 0 )
TCSetField( 'SC6TMP', 'C6_QTDVEN' , 'N', 14, 4 )

SC9->( dbSetOrder( 1 ) )
SD2->( dbSetOrder( 8 ) )

SC6TMP->( dbGoTop() )

While SC6TMP->( !Eof() )
	
	IncProc( 'Processando Filial: ' + SC6TMP->C6_FILIAL + '  Pedido: ' + AllTrim( SC6TMP->C6_NUM ) )
	
	If SD2->( dbSeek( SC6TMP->C6_FILIAL + SC6TMP->C6_NUM + SC6TMP->C6_ITEM, .f. ) ) .and. ;
		SD2->D2_COD == SC6TMP->C6_PRODUTO .and. SD2->D2_QUANT == SC6TMP->C6_QTDVEN
		
		SC9->( dbSeek( SC6TMP->C6_FILIAL + SC6TMP->C6_NUM + SC6TMP->C6_ITEM, .f. ) )
		
		While SC9->( !Eof() ) .and. SC9->C9_FILIAL	== SC6TMP->C6_FILIAL .and. ;
									SC9->C9_PEDIDO	== SC6TMP->C6_NUM .and. ;
									SC9->C9_ITEM	== SC6TMP->C6_ITEM
			
			If Empty( SC9->C9_NFISCAL ) .and. SC9->C9_BLEST <> '10'
				
				SC9->( RecLock( 'SC9', .f. ) )
				SC9->( dbDelete() )
				SC9->( MsUnlock() )
				
				nCont ++
			EndIf
			
			SC9->( dbSkip() )
		End
	EndIf
	
	SC6TMP->( dbSkip() )
End

MsgInfo( 'Numero de Ajustes >> ' + Transform( nCont, '@E 999,999' ), cCadastro )

SC6TMP->( dbCloseArea() )

Return


********************************************************************************
Static Function Ajuste13()


Local nCont := 0
Private cQuery

ProcRegua( 2 )

IncProc( 'Analisando dados...' )

cQuery := "select d2_filial, d2_doc, d2_serie, d2_emissao, d2_item, d2_pedido, d2_itempv,"
cQuery += " d2_cod, b1_desc, d2_local, d2_quant, d2_cliente, d2_loja, d2_grupo"
cQuery += " from " + RetSqlName( 'SD2' ) + " sd2, " + RetSqlName( 'SB1' ) + " sb1"
cQuery += " where d2_filial in ( " + cFilImd + " )"
cQuery += " and d2_emissao > '20031101'"
cQuery += " and sd2.D_E_L_E_T_ = ' '"
cQuery += " and not exists ("
cQuery += "  select c9_pedido"
cQuery += "  from " + RetSqlName( 'SC9' ) + " sc9"
cQuery += "  where c9_filial = sd2.d2_filial"
cQuery += "  and c9_pedido = sd2.d2_pedido"
cQuery += "  and c9_item = sd2.d2_itempv"
cQuery += "  and c9_nfiscal = sd2.d2_doc"
cQuery += "  and c9_serienf = sd2.d2_serie"
cQuery += "  and c9_blest = '10'"
cQuery += "  and c9_blcred = '10'"
cQuery += "  and sc9.D_E_L_E_T_ = ' ' )"
cQuery += " and b1_filial = d2_filial"
cQuery += " and b1_cod = d2_cod"
cQuery += " and sb1.D_E_L_E_T_ = ' '"
cQuery += " order by d2_filial, d2_doc, d2_serie, d2_item"

MEMOWRIT("C:\SQLSIGA\TMPM080_AJUSTE13_SD2TMP.TXT", cQuery)                                        

dbUseArea( .t., 'TOPCONN', TCGenQry( ,, cQuery ), 'SD2TMP', .t., .t. )

TCSetField( 'SD2TMP', 'D2_EMISSAO', 'D',  8, 0 )
TCSetField( 'SD2TMP', 'D2_QUANT'  , 'N', 14, 4 )

SC6->( dbSetOrder( 1 ) )
SC9->( dbSetOrder( 1 ) )

SD2TMP->( dbGoTop() )

While SD2TMP->( !Eof() )
	
	IncProc( 'Processando Filial: ' + SD2TMP->D2_FILIAL + '  Documento: ' + AllTrim( SD2TMP->D2_DOC ) )
	
	If SC9->( !dbSeek( SD2TMP->D2_FILIAL + SD2TMP->D2_PEDIDO + SD2TMP->D2_ITEMPV, .f. ) )
		
		SC6->( dbSeek( SD2TMP->D2_FILIAL + SD2TMP->D2_PEDIDO + SD2TMP->D2_ITEMPV + SD2TMP->D2_COD, .f. ) )
		
		SC9->( RecLock( 'SC9', .t. ) )
		SC9->C9_FILIAL   := SD2TMP->D2_FILIAL
		SC9->C9_PEDIDO   := SD2TMP->D2_PEDIDO
		SC9->C9_ITEM     := SD2TMP->D2_ITEMPV
		SC9->C9_CLIENTE  := SD2TMP->D2_CLIENTE
		SC9->C9_LOJA     := SD2TMP->D2_LOJA
		SC9->C9_PRODUTO  := SD2TMP->D2_COD
		SC9->C9_QTDLIB   := SD2TMP->D2_QUANT
		SC9->C9_NFISCAL  := SD2TMP->D2_DOC
		SC9->C9_SERIENF  := SD2TMP->D2_SERIE
		SC9->C9_DATALIB  := SD2TMP->D2_EMISSAO
		SC9->C9_SEQUEN   := '01'
		SC9->C9_GRUPO    := SD2TMP->D2_GRUPO
		SC9->C9_PRCVEN   := SC6->C6_PRCVEN
		SC9->C9_BLEST    := '10'
		SC9->C9_BLCRED   := '10'
		SC9->C9_LOCAL    := SD2TMP->D2_LOCAL
		SC9->C9_TPCARGA  := '2'
		SC9->( MsUnlock() )
		
		nCont ++
	EndIf
	
	SD2TMP->( dbSkip() )
End

MsgInfo( 'Numero de Ajustes >> ' + Transform( nCont, '@E 999,999' ), cCadastro )

SD2TMP->( dbCloseArea() )

Return


********************************************************************************
Static Function RunProc14()

Local nCont := 0
Private cQuery

aAdd( aLog, Replicate( '*', 157 ) )
aAdd( aLog, PadC( cCadastro, 157 ) )
aAdd( aLog, Replicate( '*', 157 ) )
//           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
//           0         1         2         3         4         5         6         7         8         9         0         1         2         3
//                99     999999     99/99/99     99     999999999999999  XXXXXXXXXXxxxxxxxxxxXXXXXXXXXX     99     999,999,999.9999
aAdd( aLog, '   Filial   Pedido     Emissao     Item    Produto          Descricao                         Local  Qtd Vendida(SC6)  Qtd Entregue(SC6)' )
aAdd( aLog, Replicate( '*', 157 ) )

ProcRegua( 2 )

IncProc( 'Analisando dados...' )

// Seleciona os registros do SC6 com quantidade entregue > quantidade vendida
cQuery := " select sc6.c6_filial, sc6.c6_num, sc6.c6_item, sc6.c6_produto, sb1.b1_desc, sc6.c6_local, sc6.c6_qtdven, sc6.c6_qtdent, sc5.c5_emissao"
cQuery += " from " + RetSqlName( 'SC6' ) + " sc6, " + RetSqlName( 'SC5' ) + " sc5, " + RetSqlName( 'SB1' ) + " sb1 "
cQuery += " where sc6.c6_filial in ( " + cFilImd + " )"
cQuery += " and sc6.c6_qtdven > 0"
cQuery += " and sc6.c6_qtdent > sc6.c6_qtdven"
cQuery += " and sc6.d_e_l_e_t_ = ' '
// Relacionamento com o SC5
cQuery += " and sc5.c5_filial = sc6.c6_filial"
cQuery += " and sc5.c5_num = sc6.c6_num"
cQuery += " and sc5.d_e_l_e_t_ = ' '"
// Relacionamento com o SB1
cQuery += " and sb1.b1_filial = sc6.c6_filial"
cQuery += " and sb1.b1_cod = sc6.c6_produto"
cQuery += " and sb1.d_e_l_e_t_ = ' '"
cQuery += " order by c6_filial,c5_emissao,c6_num,c6_item" 
//MEMOWRIT("C:\SQLSIGA\TMPM080_RUNPROC14_SC6TMP.TXT", cQuery)

/*dbUseArea( .t., 'TOPCONN', TCGenQry( ,, cQuery ), 'SC6TMP', .t., .t. )
TCSetField( 'SC6TMP', 'C6_QTDVEN' , 'N', 14, 4 )
TCSetField( 'SC6TMP', 'C6_QTDENT' , 'N', 14, 4 )
TCSetField( 'SC6TMP', 'C5_EMISSAO' , 'D', 8, 0 )
    
dbSelectArea( 'SC6TMP' )
dbGoTop()

While !Eof()
	
	IncProc( 'Processando Filial: ' + SC6TMP->C6_FILIAL + '  Pedido: ' + AllTrim( SC6TMP->C6_NUM ) )
	     
	// Atualiza array para posterior emissao de relatorio
	aAdd( aLog, Space( 5 ) + SC6TMP->C6_FILIAL + ;
				Space( 5 ) + SC6TMP->C6_NUM + ;
				Space( 5 ) + DtoC( SC6TMP->C5_EMISSAO ) + ;
			    Space( 5 ) + SC6TMP->C6_ITEM + ;
			    Space( 5 ) + SC6TMP->C6_PRODUTO + ;
			    Space( 2 ) + SC6TMP->B1_DESC + ;
				Space( 5 ) + SC6TMP->C6_LOCAL + ;
				Space( 5 ) + Transform( SC6TMP->C6_QTDVEN, '@E 999,999,999.9999' ) + ;
				Space( 2 ) + Transform( SC6TMP->C6_QTDENT, '@E 999,999,999.9999' ) )
	nCont ++
	
	dbSelectArea( 'SC6TMP' )
	dbSkip()
End*/

	aAdd( aLog, Space( 5 ) + "14" + ;
				Space( 5 ) + "999999" + ;
				Space( 5 ) + "01/01/2001" + ;
			    Space( 5 ) + "01" + ;
			    Space( 5 ) + "555555555555551" + ;
			    Space( 2 ) + "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" + ;
				Space( 5 ) + "05" + ;
				Space( 5 ) + Transform( 888, '@E 999,999,999.9999' ) + ;
				Space( 2 ) + Transform( 999, '@E 999,999,999.9999' ) )
	nCont ++

aAdd( aLog, ' ' )
aAdd( aLog, 'Numero de Inconsistencias   >>' + Transform( nCont, '@E 999,999' ) )

//SC6TMP->( dbCloseArea() )

Return


********************************************************************************
Static Function Ajuste14()

Local nCont := 0
Private cQuery

ProcRegua( 2 )

IncProc( 'Analisando dados...' )

// Seleciona os registros do SC6 com quantidade entregue > quantidade vendida
cQuery := " select sc6.c6_filial, sc6.c6_num, sc6.c6_item, sc6.c6_produto, sb1.b1_desc, sc6.c6_local, sc6.c6_qtdven, sc6.c6_qtdent, sc5.c5_emissao"
cQuery += " from " + RetSqlName( 'SC6' ) + " sc6, " + RetSqlName( 'SC5' ) + " sc5, " + RetSqlName( 'SB1' ) + " sb1 "
cQuery += " where sc6.c6_filial in ( " + cFilImd + " )"
cQuery += " and sc6.c6_qtdven > 0"
cQuery += " and sc6.c6_qtdent > sc6.c6_qtdven"
cQuery += " and sc6.d_e_l_e_t_ = ' '
// Relacionamento com o SC5
cQuery += " and sc5.c5_filial = sc6.c6_filial"
cQuery += " and sc5.c5_num = sc6.c6_num"
cQuery += " and sc5.d_e_l_e_t_ = ' '"
// Relacionamento com o SB1
cQuery += " and sb1.b1_filial = sc6.c6_filial"
cQuery += " and sb1.b1_cod = sc6.c6_produto"
cQuery += " and sb1.d_e_l_e_t_ = ' '"
cQuery += " order by c6_filial,c5_emissao,c6_num,c6_item" 
//MEMOWRIT( "C:\"+FunName(1)+".SQL", cQuery ) 

dbUseArea( .t., 'TOPCONN', TCGenQry( ,, cQuery ), 'SC6TMP', .t., .t. )
TCSetField( 'SC6TMP', 'C6_QTDVEN' , 'N', 14, 4 )
TCSetField( 'SC6TMP', 'C6_QTDENT' , 'N', 14, 4 )
TCSetField( 'SC6TMP', 'C5_EMISSAO' , 'D', 8, 0 )
   
SC6->( dbSetOrder( 1 ) )

SC6TMP->( dbGoTop() )

While SC6TMP->( !Eof() )
	
	IncProc( 'Processando Filial: ' + SC6TMP->C6_FILIAL + '  Pedido: ' + AllTrim( SC6TMP->C6_NUM ) )
	
	If SC6->( dbSeek( SC6TMP->C6_FILIAL + SC6TMP->C6_NUM + SC6TMP->C6_ITEM + SC6TMP->C6_PRODUTO, .f. ) )
		
		SC6->( RecLock( 'SC6', .f. ) )
		SC6->C6_QTDENT	:= SC6TMP->C6_QTDVEN
		SC6->( MsUnlock() )
		
		nCont ++
	EndIf
	
	SC6TMP->( dbSkip() )
End

MsgInfo( 'Numero de Ajustes >> ' + Transform( nCont, '@E 999,999' ), cCadastro )

SC6TMP->( dbCloseArea() )

Return