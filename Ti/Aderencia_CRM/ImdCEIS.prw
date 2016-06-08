//#INCLUDE "rwmake.ch"
//#INCLUDE "topconn.ch"
//
//STATIC __nnLock := -1
//STATIC __ccArq := ''
//
///*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³IMDCEIS   º Autor ³ Raul Pietsch       º Data ³  13/04/03   º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao ³ Geracao das Tabelas  para o EIS                            º±±
//±±º          ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºUso       ³ SigaEIS                                                    º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
///*/
//
User Function IMDCEIS()
Return
//Private data1 := FirstDay( ddatabase  )
//Private data2 := LastDay( ddatabase  )
//Private path  := GETMV( 'MV_EIS' )
//Private aDados  := { { "Consid. Devolucoes?","Consid. Devolucoes","Consid. Devolucoes?","mv_ch1","N", 1,0,0,"C","","mv_par01","Sim","Sim","Sim",""    ,"","Nao","Nao","Nao","","","","","","","","","","","","","","","","",""   ,"" } }
//Private cPerg := "IMDEIS"
//Private cQuery
//
//// Atualiza arquivo de parametros SX1
//AjustaSx1( cPerg, aDados )
//Pergunte(cPerg,.F.)
//
//// Monta a tela para o processamento
//@ 148,66 To 364,568 Dialog dlg1 Title OemToAnsi("Tabelas EIS")
//@ 12,17 To 76,236 Title OemToAnsi("Objetivo")
////@ 15,17 Say OemToAnsi("Data:") Size 20,8
////@ 15,44 GET data1              Size 40,8 when .f.
////@ 15,88 Say OemToAnsi("ate")
////@ 15,98 GET data2              Size 40,8 when .f.
//@ 21,22 Say OemToAnsi("Esta rotina tem a funcao de gerar os dados necessarios para o processamento do SigaEis") Size 208,48
//@ 082,17  BmpButton Type 5 Action   Pergunte(cPerg,.T.)
//@ 082,50  BmpButton Type 1 Action   Processa({||Executar( dlg1 )},"Atencao!","Gerando tabelas para consulta EIS...")
//@ 082,083 BmpButton Type 2 Action  Close( dlg1 )
//Activate Dialog dlg1 CENTER
//Return
//
//Static Function Executar()
//Local aDiasRest := {}
//Local aDiasPass := {}
//Local nPos, cFilTmp
//Local aStruct
//Private cData1 := DTOS( data1 )
//Private cData2 := DTOS( data2 )
//Private datafim := Dtos( ddatabase )
//Private cFilImd, nRec_SM0, aSetField
//
//// Trava, pois esta rotina deve ser rodada de maneira exclusiva
//If !u_ImdMyLock("IMDCEIS",1)
//	MSGBOX("Existe outro usuário utilizando esta rotina neste momento.",'Atenção','ALERT')
//	Return NIL
//Endif
//
//ProcRegua( 55 )  // Executa 55 processos
//
//// filtro de filiais
//cFilImd := ""
//nRec_SM0 := SM0->( RecNo() )
//SM0->( dbSeek( cEmpAnt, .f. ) )
//While SM0->( !EOF() ) .and. SM0->M0_CODIGO == cEmpAnt
//	cFilImd += "'" + SM0->M0_CODFIL + "',"
//
//	// atualiza aarray com dias restantes e dias passados
//	// verifica se hoje eh dia util
//	If DataValida(dDatabase) == dDatabase
//		aAdd(aDiasPass,{SM0->M0_CODFIL,u_diasUteis( ddatabase,SM0->M0_CODFIL )-1 } )
//	Else
//		aAdd(aDiasPass,{SM0->M0_CODFIL,u_diasUteis( ddatabase,SM0->M0_CODFIL ) } )
//	Endif
//	aAdd(aDiasRest,{SM0->M0_CODFIL,u_diasUteis(LastDay( ddatabase),SM0->M0_CODFIL) - aDiasPass[Len(aDiasPass),2] } )
//
//	SM0->( dbSkip() )
//End
//cFilImd := Left(cFilImd,Len(cFilImd)-1)
//SM0->( dbGoTo( nRec_SM0 ) )
//IncProc()
//
//
////CONSULTA EIS00 - Movimentacao de Vendas
////=======================================
//aStruct := {  {"E00_FILIAL" ,"C" , 2  ,0},;
//              {"E00_COD"    ,"C" , 15 ,0},;
//              {"E00_DESC"   ,"C" , 45 ,0},;
//              {"E00_DATA"   ,"C" , 8  ,0},;
//              {"E00_MARCA"  ,"C" , 20 ,0},;
//              {"E00_SATIV1" ,"C" , 6  ,0} } //,;
///*
//              {"E00_VEND"   ,"C" , 6  ,0},;
//              {"E00_VENEXT" ,"C" , 6  ,0},;
//              {"E00_VENDC"  ,"C" , 6  ,0},;
//              {"E00_CHVEND" ,"C" , 6  ,0},;
//              {"E00_GEVEN"  ,"C" , 6  ,0},;
//              {"E00_DIVEN"  ,"C" , 6  ,0},;
//              {"E00_CMCREG" ,"C" , 6  ,0},;
//              {"E00_CMSREG" ,"C" , 6  ,0},;
//              {"E00_UF"     ,"C" , 2  ,0},;
//              {"E00_CREG"   ,"C" , 6  ,0},;
//              {"E00_CODCID" ,"C" , 6  ,0},;
//              {"E00_FAT"    ,"N" , 17 ,2},;
//              {"E00_CUSIMD" ,"N" , 23 ,8},;
//              {"E00_LUCRO"  ,"N" , 23 ,8},;
//              {"E00_FATHOJ" ,"N" , 17 ,2},;
//              {"E00_CUSHOJ" ,"N" , 23 ,8},;
//              {"E00_LUCHOJ" ,"N" , 23 ,8},;
//              {"E00_DIASRE" ,"N" , 3  ,0},;
//              {"E00_DIASPA" ,"N" , 3  ,0} }
//*/
//cQuery := "select D2_FILIAL E00_FILIAL, D2_COD E00_COD, B1_DESC E00_DESC, D2_EMISSAO E00_DATA, B1_MARCA E00_MARCA,"
//cQuery += " A1_SATIV1 E00_SATIV1, C5_VEND1 E00_VEND, C5_VEND2 E00_VENEXT, C5_VEND3 E00_VENDC, C5_VEND4 E00_CHVEND,"
//cQuery += " C5_VEND5 E00_GEVEN, A3_DIRETOR E00_DIVEN,  A1_MICRORE E00_CMCREG, A1_MESORG E00_CMSREG,"
//cQuery += " A1_EST E00_UF, A1_REGIAO E00_CREG, A1_CODCID E00_CODCID, D2_TOTAL E00_FAT, D2_CUSIMD1 E00_CUSIMD,"
//cQuery += " D2_LUCRO1 E00_LUCRO, 0 E00_FATHOJ, 0 E00_CUSHOJ, 0 E00_LUCHOJ, 0 E00_DIASRE, 0 E00_DIASPA "
//
//// tabelas
//cQuery += " from "+RetSqlName('sd2')+" sd2, "
//cQuery += RetSqlName('sc6')+" sc6, "
//cQuery += RetSqlName('sc5')+" sc5, "
//cQuery += RetSqlName('sb1')+" sb1, "
//cQuery += RetSqlName('sf4')+" sf4, "
//cQuery += RetSqlName("sa1")+" sa1, "
//cQuery += RetSqlName('sa3')+" sa3"
//
//// filiais
//cQuery += " where 	D2_FILIAL IN ( " + cFilImd + " )"
//cQuery += " and 	(C6_FILIAL IS NULL OR C6_FILIAL IN ( " + cFilImd + " ) )"
//cQuery += " and 	(C5_FILIAL IS NULL OR C5_FILIAL IN ( " + cFilImd + " ) )"
//cQuery += " and 	(B1_FILIAL IS NULL OR B1_FILIAL IN ( " + cFilImd + " ) )"
//cQuery += " and 	F4_FILIAL IN ( " + cFilImd + " ) "
//cQuery += " and 	A1_FILIAL (+) = '  '"
//cQuery += " and 	A3_FILIAL (+) = '  '"
//
//// deleted
//cQuery += " and   	sd2.D_E_L_E_T_ = ' '"
//cQuery += " and 	sc6.D_E_L_E_T_ (+) = ' '"
//cQuery += " and 	sc5.D_E_L_E_T_ (+) = ' '"
//cQuery += " and 	sb1.D_E_L_E_T_ (+) = ' '"
//cQuery += " and 	sf4.D_E_L_E_T_  = ' '"
//cQuery += " and 	sa1.D_E_L_E_T_ (+) = ' '"
//cQuery += " and 	sa3.D_E_L_E_T_ (+) = ' '"
//
//// filtros
//cQuery += " and   D2_EMISSAO between '"+cData1+ "' AND  '"+dataFim+"' "
//cQuery += " and 	D2_TIPO NOT IN ( 'B', 'D' ) "
//cQuery += " and   D2_ORIGLAN <> 'LF' "
//cQuery += " and 	F4_DUPLIC  = 'S' "
//
//// relacionamentos
////SC6
//cQuery += " and	D2_FILIAL = C6_FILIAL (+)"
//cQuery += " and	D2_PEDIDO = C6_NUM (+)"
//cQuery += " and 	D2_ITEMPV = C6_ITEM (+)"
//
////SC5
//cQuery += " and 	C6_FILIAL = C5_FILIAL (+)"
//cQuery += " and 	C6_NUM = C5_NUM (+)"
//
////SB1
//cQuery += " and 	D2_FILIAL = B1_FILIAL (+)"
//cQuery += " and 	D2_COD = B1_COD (+)"
//
////SF4
//cQuery += " and 	D2_FILIAL = F4_FILIAL "
//cQuery += " and 	D2_TES = F4_CODIGO "
//
////SA1
//cQuery += " and 	D2_CLIENTE = A1_COD (+)"
//cQuery += " and 	D2_LOJA = A1_LOJA (+)"
//
////SA3
//cQuery += " and 	C5_VEND1 = A3_COD (+)"
//
//
////ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
////³ Uniao com as devolucoes, com valores negativos  		     ³
////ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If mv_par01 == 1
//
//	cQuery += " UNION ALL select D1_FILIAL E00_FILIAL, D1_COD E00_COD, B1_DESC E00_DESC, D1_DTDIGIT E00_DATA, B1_MARCA E00_MARCA,"
//	cQuery += " A1_SATIV1 E00_SATIV1, F2_VEND1 E00_VEND, F2_VEND2 E00_VENEXT, F2_VEND3 E00_VENDC, F2_VEND4 E00_CHVEND,"
//	cQuery += " F2_VEND5 E00_GEVEN, A3_DIRETOR E00_DIVEN,  A1_MICRORE E00_CMCREG, A1_MESORG E00_CMSREG,"
//	cQuery += " A1_EST E00_UF, A1_REGIAO E00_CREG, A1_CODCID E00_CODCID, D1_TOTAL*-1 E00_FAT, (D2_CUSIMD1/D2_QUANT)*D1_QUANT*-1 E00_CUSIMD,"
//	cQuery += " (D2_LUCRO1/D2_QUANT)*D1_QUANT*-1 E00_LUCRO, 0 E00_CUSHOJ, 0 E00_FATHOJ, 0 E00_LUCHOJ, 0 E00_DIASRE, 0 E00_DIASPA "
//
//	// tabelas
//	cQuery += " from "+RetSqlName('sd1')+" sd1, "
//	cQuery += RetSqlName('sd2')+" sd2, "
//	cQuery += RetSqlName('sf2')+" sf2, "
//	cQuery += RetSqlName('sb1')+" sb1, "
//	cQuery += RetSqlName('sf4')+" sf4, "
//	cQuery += RetSqlName("sa1")+" sa1, "
//	cQuery += RetSqlName('sa3')+" sa3"
//
//	// filiais
//	cQuery += " where 	D1_FILIAL IN ( " + cFilImd + " )"
//	cQuery += " and 	(D2_FILIAL IS NULL OR D2_FILIAL IN ( " + cFilImd + " ) )"
//	cQuery += " and 	(F2_FILIAL IS NULL OR F2_FILIAL IN ( " + cFilImd + " ) )"
//	cQuery += " and 	(B1_FILIAL IS NULL OR B1_FILIAL IN ( " + cFilImd + " ) )"
//	cQuery += " and 	F4_FILIAL IN ( " + cFilImd + " ) "
//	cQuery += " and 	A1_FILIAL (+) = '  '"
//	cQuery += " and 	A3_FILIAL (+) = '  '"
//
//	// deleted
//	cQuery += " and   	sd1.D_E_L_E_T_ = ' '"
//	cQuery += " and 	sd2.D_E_L_E_T_ (+) = ' '"
//	cQuery += " and 	sf2.D_E_L_E_T_ (+) = ' '"
//	cQuery += " and 	sb1.D_E_L_E_T_ (+) = ' '"
//	cQuery += " and 	sf4.D_E_L_E_T_  = ' '"
//	cQuery += " and 	sa1.D_E_L_E_T_ (+) = ' '"
//	cQuery += " and 	sa3.D_E_L_E_T_ (+) = ' '"
//
//	// filtros
//	cQuery += " and   D1_DTDIGIT between '"+cData1+ "' AND  '"+dataFim+"' "
//	cQuery += " and 	D1_TIPO = 'D' "
//	cQuery += " and   D1_ORIGLAN <> 'LF' "
//	cQuery += " and 	F4_DUPLIC  = 'S' "
//
//	// relacionamentos
//	//SD2
//	cQuery += " and	D1_FILIAL  = D2_FILIAL (+)"
//	cQuery += " and	D1_NFORI   = D2_DOC (+)"
//	cQuery += " and 	D1_SERIORI = D2_SERIE (+)"
//	cQuery += " and 	D1_FORNECE = D2_CLIENTE (+)"
//	cQuery += " and 	D1_LOJA    = D2_LOJA (+)"
//	cQuery += " and 	D1_COD     = D2_COD (+)"
//	// alterado por Luciano Correa em 29/08/05...
//	//cQuery += " and 	D1_ITEM    = D2_ITEM (+)"
//	cQuery += " and 	D1_ITEMORI = D2_ITEM (+)"
//
//	//SF2
//	cQuery += " and	D1_FILIAL  = F2_FILIAL (+)"
//	cQuery += " and	D1_NFORI   = F2_DOC (+)"
//	cQuery += " and 	D1_SERIORI = F2_SERIE (+)"
//	cQuery += " and 	D1_FORNECE = F2_CLIENTE (+)"
//	cQuery += " and 	D1_LOJA    = F2_LOJA (+)"
//
//	//SB1
//	cQuery += " and 	D1_FILIAL = B1_FILIAL (+)"
//	cQuery += " and 	D1_COD = B1_COD (+)"
//
//	//SF4
//	cQuery += " and 	D1_FILIAL = F4_FILIAL "
//	cQuery += " and 	D1_TES = F4_CODIGO "
//
//	//SA1
//	cQuery += " and 	D1_FORNECE = A1_COD (+)"
//	cQuery += " and 	D1_LOJA = A1_LOJA (+)"
//
//	//SA3
//	cQuery += " and 	F2_VEND1 = A3_COD (+)"
//Endif
//
//aSetField := { {'EIS00', 'E00_FAT'    , 'N',17 , 2},;
//          	  { 'EIS00', 'E00_CUSIMD' , 'N',17 , 2 },;
//	          { 'EIS00', 'E00_LUCRO ' , 'N',17 , 2 },;
//    	      { 'EIS00', 'E00_FATHOJ' , 'N',17 , 2 },;
//        	  { 'EIS00', 'E00_CUSHOJ' , 'N',17 , 2 },;
//	          { 'EIS00', 'E00_LUCHOJ' , 'N',17 , 2 },;
//    	      { 'EIS00', 'E00_DIASRE' , 'N',2 , 0 },;
//        	  { 'EIS00', 'E00_DIASPA' , 'N',2 , 0 } }
//MyQuery( cQuery , 'EIS00', aStruct  )
//
//// cria tabela no banco temporaria com dados do Sigamat.emp
//If u_ExistTable("FILIAISTMP")
//	TCSQLEXEC("DROP TABLE FILIAISTMP")
//Endif
//dbSelectArea("SM0")
//COPY TO ( "FILIAISTMP" ) via "TOPCONN"
//
//
////CONSULTA EIS01 - Metas por Filial
////=================================
//aStruct := { {"E01_FILIAL" ,"C",2 ,0},;
//              {"E01_NOME"   ,"C",18,0},;
//              {"E01_MFAT"   ,"N",17,2},;
//              {"E01_MMARGE" ,"N",7 ,2},;
//              {"E01_MCUSTO" ,"N",23,8} }
//cQuery := "select CT_FILIAL E01_FILIAL, M0_FILIAL E01_NOME, CT_VALOR E01_MFAT , CT_MARGEM E01_MMARGE, CT_VALOR/(1+(CT_MARGEM/100)) E01_MCUSTO"
//cQuery += " from "+retSqlname('sct')+" sct, FILIAISTMP FIL "
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND M0_CODIGO  = '"+cEmpAnt+"'"
//cQuery += " AND CT_FILIAL  = M0_CODFIL "
//cQuery += " AND CT_MARCA   = '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_VEND    = '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//aSetField := {{ 'EIS01', 'E01_MFAT'   , 'N',17 , 2 },;
//          	   { 'EIS01', 'E01_MMARGE' , 'N',7 , 2  },;
//		        { 'EIS01', 'E01_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS01', aStruct  )
//// exclui tabela temporaria
//TCSQLEXEC("DROP TABLE FILIAISTMP")
//
//
////CONSULTA EIS02 - Metas por Filial x Marca
////=========================================
//aStruct := { {"E02_FILIAL" ,"C",2 ,0},;
//              {"E02_MARCA"  ,"C",20,0},;
//              {"E02_MFAT"   ,"N",17,2},;
//              {"E02_MLUCRO" ,"N",23,8},;
//              {"E02_MCUSTO" ,"N",23,8} }
//cQuery := "select CT_FILIAL E02_FILIAL,  CT_MARCA E02_MARCA, sum(CT_VALOR) E02_MFAT, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) E02_MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) E02_MCUSTO "
//cQuery += " from "+retSqlname('sct')+" sct"
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_VEND    = '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_MARCA "
//aSetField := {{ 'EIS02', 'E02_MFAT'   , 'N',17 , 2 },;
//               { 'EIS02', 'E02_MLUCRO' , 'N',17 , 2 },;
//               { 'EIS02', 'E02_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS02', aStruct  )
//
////CONSULTA EIS03 - Metas por Filial x Segmento
////==============================================
//aStruct := { {"E03_FILIAL" ,"C",2 ,0},;
//              {"E03_SATIV1" ,"C",6 ,0},;
//              {"E03_DATIVI" ,"C",30,0},;
//              {"E03_MFAT"  ,"N",17 ,2},;
//              {"E03_MLUCRO" ,"N",23,8},;
//              {"E03_MCUSTO" ,"N",23,8} }
//cQuery :=	   "select CT_FILIAL E03_FILIAL,  CT_SEGMEN E03_SATIV1, SUBSTRING(X5_DESCRI,1,30) E03_DATIVI ,sum(CT_VALOR) E03_MFAT, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) E03_MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) E03_MCUSTO"
//cQuery += " from "+RetSqlName('sct')+" sct , "
//cQuery += RetSqlName('sx5')+" sx5 "
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND X5_FILIAL (+) = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sx5.D_E_L_E_T_ (+) = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " and sx5.x5_tabela (+) = 'T3' AND sx5.X5_CHAVE (+) = sct.CT_SEGMEN "
//cQuery += " AND CT_SEGMEN <> '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_MARCA   = '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_VEND    = '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_SEGMEN, SUBSTRING(X5_DESCRI,1,30)"
//aSetField := { {'EIS03', 'E03_MFAT'   , 'N',17 , 2 },;
//          { 'EIS03', 'E03_MLUCRO' , 'N',17 , 2 },;
//          { 'EIS03', 'E03_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS03', aStruct  )
//
////CONSULTA EIS04 - Metas por Filial x Vendedor INTERNO
////====================================================
//aStruct := { {"E04_FILIAL" ,"C",2 ,0},;
//              {"E04_VEND"   ,"C",6 ,0},;
//              {"E04_NVEND"  ,"C",40,0},;
//              {"E04_MFAT"  ,"N",17 ,2},;
//              {"E04_MLUCRO","N",23 ,8},;
//              {"E04_MCUSTO" ,"N",23,8} }
//cQuery := "select CT_FILIAL E04_FILIAL,  CT_VEND E04_VEND, A3_NOME E04_NVEND, SUM(CT_VALOR) E04_MFAT, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) E04_MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) E04_MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct ,"+ RetSqlName('sa3')+" sa3"
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL  = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_   = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " and A3_TIPO = 'I'"
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISVI") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_VEND, A3_NOME "
//aSetField := { { 'EIS04', 'E04_MFAT'   , 'N',17 , 2 },;
//                { 'EIS04', 'E04_MLUCRO' , 'N',17 , 2 },;
//                { 'EIS04', 'E04_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS04', aStruct  )
//
//
////CONSULTA EIS05 - Metas por Filial x Vendedor EXTERNO
////====================================================
//aStruct := { {"E05_FILIAL" ,"C",2 ,0},;
//              {"E05_VEND"   ,"C",6 ,0},;
//              {"E05_NVEND"  ,"C",40,0},;
//              {"E05_MFAT"  ,"N",17 ,2},;
//              {"E05_MLUCRO","N",23 ,8},;
//              {"E05_MCUSTO" ,"N",23,8} }
//cQuery := "select CT_FILIAL E05_FILIAL,  CT_VEND E05_VEND, A3_NOME E05_NVEND, SUM(CT_VALOR) E05_MFAT, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) E05_MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) E05_MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct,"+ RetSqlName('sa3')+" sa3"
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_  = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " and A3_TIPO = 'E'"
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISVE") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_VEND, A3_NOME "
//aSetField := { { 'EIS05', 'E05_MFAT'   , 'N',17 , 2 },;
//                { 'EIS05', 'E05_MLUCRO' , 'N',17 , 2 },;
//                { 'EIS05', 'E05_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS05', aStruct  )
//
//
////* CONSULTA EIS06 - Metas por Filial x Vendedor COORDENADOR
////==========================================================
//aStruct := { {"E06_FILIAL" ,"C",2 ,0},;
//              {"E06_VEND"   ,"C",6 ,0},;
//              {"E06_NVEND"  ,"C",40,0},;
//              {"E06_MFAT"  ,"N",17 ,2},;
//              {"E06_MLUCRO","N",23 ,8},;
//              {"E06_MCUSTO" ,"N",23,8} }
//// Definicao: meta dos coordenador + meta dos seus vendedores externos subordinados
//cQuery := "select SUPER.FILIAL E06_FILIAL, SUPER.SUPERIOR E06_VEND, sa3.A3_NOME E06_NVEND, SUM(SUPER.VALOR) E06_MFAT, SUM(SUPER.MLUCRO) E06_MLUCRO, SUM(SUPER.MCUSTO) E06_MCUSTO from "
//// vendedores coordenadores
//cQuery += "( select CT_FILIAL FILIAL, CT_VEND SUPERIOR, SUM(CT_VALOR) VALOR, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct,"+ RetSqlName('sa3')+" sa3 "
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_  = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISCOOR") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_VEND "
//// uniao com vendedores externos
//cQuery += " UNION ALL select CT_FILIAL FILIAL, SA3.A3_SUPER SUPERIOR, SUM(CT_VALOR) VALOR, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct,"+ RetSqlName('sa3')+" sa3 "
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL  = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_   = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " AND SA3.A3_TIPO = 'E'"
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISVE") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, A3_SUPER ) SUPER , "+RetSqlName('sa3')+" sa3 "
//cQuery += " WHERE sa3.A3_FILIAL (+) = '  '"
//cQuery += " AND sa3.D_E_L_E_T_ (+)  = ' ' "
//cQuery += " AND SUPER.SUPERIOR = sa3.A3_COD (+) "
//cQuery += " group by SUPER.FILIAL, SUPER.SUPERIOR, sa3.A3_NOME "
//aSetField := { { 'EIS06', 'E06_MFAT'   , 'N',17 , 2 },;
//                { 'EIS06', 'E06_MLUCRO' , 'N',17 , 2 },;
//                { 'EIS06', 'E06_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS06', aStruct  )
//
//
////* CONSULTA EIS07 - Metas por Filial x CHEFE DE VENDAS
////========================================================
//aStruct := { {"E07_FILIAL" ,"C",2 ,0},;
//              {"E07_VEND"   ,"C",6 ,0},;
//              {"E07_NVEND"  ,"C",40,0},;
//              {"E07_MFAT"   ,"N",17,2},;
//              {"E07_MLUCRO" ,"N",23,8},;
//              {"E07_MCUSTO" ,"N",23,8} }
//// Definicao: meta do chefe + meta dos seus vendedores internos subordinados
//cQuery := "select SUPER.FILIAL E07_FILIAL, SUPER.SUPERIOR E07_VEND, sa3.A3_NOME E07_NVEND, SUM(SUPER.VALOR) E07_MFAT, SUM(SUPER.MLUCRO) E07_MLUCRO, SUM(SUPER.MCUSTO) E07_MCUSTO from "
//// chefe de vendas
//cQuery += "( select CT_FILIAL FILIAL, CT_VEND SUPERIOR, SUM(CT_VALOR) VALOR, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct,"+ RetSqlName('sa3')+" sa3 "
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_  = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISCHVE") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_VEND "
//// uniao com vendedores internos
//cQuery += " UNION ALL select CT_FILIAL FILIAL, SA3.A3_SUPER SUPERIOR, SUM(CT_VALOR) VALOR, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct,"+ RetSqlName('sa3')+" sa3 "
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL  = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_  =	 ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " AND SA3.A3_TIPO = 'I'"
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISVI") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, A3_SUPER ) SUPER , "+RetSqlName('sa3')+" sa3 "
//cQuery += " WHERE sa3.A3_FILIAL (+) = '  '"
//cQuery += " AND sa3.D_E_L_E_T_ (+)  = ' ' "
//cQuery += " AND SUPER.SUPERIOR = sa3.A3_COD (+) "
//cQuery += " group by SUPER.FILIAL, SUPER.SUPERIOR, sa3.A3_NOME "
//aSetField := { { 'EIS07', 'E07_MFAT'   , 'N',17 , 2 },;
//                { 'EIS07', 'E07_MLUCRO' , 'N',17 , 2 },;
//                { 'EIS07', 'E07_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS07', aStruct  )
//
//
////CONSULTA EIS08 - Metas por Filial x GERENTE DE VENDAS
////======================================================
//aStruct := { {"E08_FILIAL" ,"C",2 ,0},;
//              {"E08_VEND"   ,"C",6 ,0},;
//              {"E08_NVEND"  ,"C",40,0},;
//              {"E08_MFAT"  ,"N",17 ,2},;
//              {"E08_MLUCRO","N",23 ,8},;
//              {"E08_MCUSTO" ,"N",23,8} }
//// Definicao: vendedores internos subordinados + chefe de vendas subordinados agrupados por gerente
//cQuery := "select GERENTE.FILIAL E08_FILIAL, sa3.A3_GEREN E08_VEND, na3.A3_NOME E08_NVEND, SUM(GERENTE.MFAT) E08_MFAT, SUM(GERENTE.MLUCRO) E08_MLUCRO, SUM(GERENTE.MCUSTO) E08_MCUSTO from "
//// meta de venda dos vendedores internos
//cQuery += "(select CT_FILIAL FILIAL,  CT_VEND VEND, A3_NOME NVEND, SUM(CT_VALOR) MFAT, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct ,"+ RetSqlName('sa3')+" sa3"
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL  = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_   = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " and A3_TIPO = 'I'"
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISVI") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_VEND, A3_NOME "
//// uniao com meta de venda efetiva do chefe de vendas
//cQuery += "UNION ALL select CT_FILIAL FILIAL, CT_VEND VEND, A3_NOME NVEND, SUM(CT_VALOR) VALOR, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct,"+ RetSqlName('sa3')+" sa3 "
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_  = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISCHVE") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_VEND, A3_NOME ) GERENTE , "+RetSqlName('sa3')+" sa3,"+RetSqlName('sa3')+" na3 "
//cQuery += "WHERE sa3.A3_FILIAL = '  ' "
//cQuery += "and na3.A3_FILIAL  = '  ' "
//cQuery += "and sa3.D_E_L_E_T_  = ' ' "
//cQuery += "and na3.D_E_L_E_T_  = ' ' "
//cQuery += "and GERENTE.VEND = sa3.A3_COD "
//cQuery += "and SA3.A3_GEREN = na3.A3_COD "
//cQuery += "and na3.A3_GRPREP IN (" + GETMV("MV_EISGEVE") + ") "
//cQuery += "group by GERENTE.FILIAL, sa3.A3_GEREN, na3.A3_NOME"
//aSetField := { { 'EIS08', 'E08_MFAT'   , 'N',17 , 2 },;
//                { 'EIS08', 'E08_MLUCRO' , 'N',17 , 2 },;
//                { 'EIS08', 'E08_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS08', aStruct  )
//
////CONSULTA EIS09 - Metas por Filial x DIRETOR DE VENDAS
////========================================================
//aStruct := { {"E09_FILIAL" ,"C",2 ,0},;
//              {"E09_VEND"   ,"C",6 ,0},;
//              {"E09_NVEND"  ,"C",40,0},;
//              {"E09_MFAT"  ,"N",17 ,2},;
//              {"E09_MLUCRO","N",23 ,8},;
//              {"E09_MCUSTO" ,"N",23,8} }
//// Definicao: vendedores internos subordinados + chefe de vendas subordinados agrupados por diretores
//cQuery := "select DIRETOR.FILIAL E09_FILIAL, sa3.A3_DIRETOR E09_VEND, na3.A3_NOME E09_NVEND, SUM(DIRETOR.MFAT) E09_MFAT, SUM(DIRETOR.MLUCRO) E09_MLUCRO, SUM(DIRETOR.MCUSTO) E09_MCUSTO from "
//// meta de venda dos vendedores internos
//cQuery += "(select CT_FILIAL FILIAL,  CT_VEND VEND, A3_NOME NVEND, SUM(CT_VALOR) MFAT, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct ,"+ RetSqlName('sa3')+" sa3"
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL  = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_   = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " and A3_TIPO = 'I'"
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISVI") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_VEND, A3_NOME "
//// uniao com meta de venda efetiva do chefe de vendas
//cQuery += "UNION ALL select CT_FILIAL FILIAL, CT_VEND VEND, A3_NOME NVEND, SUM(CT_VALOR) VALOR, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct,"+ RetSqlName('sa3')+" sa3 "
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_  = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISCHVE") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_VEND, A3_NOME )  DIRETOR , "+RetSqlName('sa3')+" sa3,"+RetSqlName('sa3')+" na3 "
//cQuery += "WHERE sa3.A3_FILIAL  = '  ' "
//cQuery += "and na3.A3_FILIAL  = '  ' "
//cQuery += "and sa3.D_E_L_E_T_  = ' ' "
//cQuery += "and na3.D_E_L_E_T_  = ' ' "
//cQuery += "and DIRETOR.VEND = sa3.A3_COD  "
//cQuery += "and SA3.A3_DIRETOR = na3.A3_COD  "
//cQuery += "and na3.A3_GRPREP IN (" + GETMV("MV_EISDIVE") + ") "
//cQuery += "group by DIRETOR.FILIAL, sa3.A3_DIRETOR, na3.A3_NOME"
//aSetField := { { 'EIS09', 'E09_MFAT'   , 'N',17 , 2 },;
//                { 'EIS09', 'E09_MLUCRO' , 'N',17 , 2 },;
//                { 'EIS09', 'E09_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS09', aStruct  )
//
////CONSULTA EIS10 - Metas por Filial x Vendedor EXTERNO x Marca
////============================================================
//aStruct := { {"E10_FILIAL" ,"C",2 ,0},;
//              {"E10_VEND"   ,"C",6 ,0},;
//              {"E10_NVEND"  ,"C",40,0},;
//              {"E10_MARCA"  ,"C",20,0},;
//              {"E10_MFAT"  ,"N",17 ,2},;
//              {"E10_MLUCRO","N",23 ,8},;
//              {"E10_MCUSTO" ,"N",23,8} }
//cQuery :=  "select CT_FILIAL E10_FILIAL,  CT_VEND E10_VEND, A3_NOME E10_NVEND, CT_MARCA E10_MARCA, SUM(CT_VALOR) E10_MFAT, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100))))  E10_MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) E10_MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct,"+RetSqlName('sa3')+" sa3"
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_  = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " and A3_TIPO = 'E'"
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISVE") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_VEND, A3_NOME, CT_MARCA "
//aSetField := { { 'EIS10', 'E10_MFAT'   , 'N',17 , 2 },;
//                { 'EIS10', 'E10_MLUCRO' , 'N',17 , 2 },;
//                { 'EIS10', 'E10_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS10', aStruct  )
//
//
////CONSULTA EIS11 - Metas por Filial x Vendedor EXTERNO x Segmento
////=================================================================
//aStruct := { {"E11_FILIAL" ,"C",2 ,0},;
//              {"E11_VEND"   ,"C",6 ,0},;
//              {"E11_NVEND"  ,"C",40,0},;
//              {"E11_SATIV1" ,"C",6 ,0},;
//              {"E11_DATIVI" ,"C",30,0},;
//              {"E11_MFAT"   ,"N",17 ,2},;
//              {"E11_MLUCRO" ,"N",23 ,8},;
//              {"E11_MCUSTO" ,"N",23,8} }
//cQuery :=  "select CT_FILIAL E11_FILIAL,  CT_VEND E11_VEND, A3_NOME E11_NVEND, CT_SEGMEN E11_SATIV1, SUBSTR(X5_DESCRI,1,30) E11_DATIVI , SUM(CT_VALOR) E11_MFAT , SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) E11_MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) E11_MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct,"+RetSqlName('sa3')+" sa3, "+RetSqlName('sx5')+" sx5  "
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL = '  '"
//cQuery += " AND X5_FILIAL (+) = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_  = ' ' "
//cQuery += " AND sx5.D_E_L_E_T_ (+) = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " and A3_TIPO = 'E'"
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISVE") + ") "
//cQuery += " and sx5.x5_tabela (+) = 'T3' AND sx5.X5_CHAVE (+) = sct.CT_SEGMEN "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_SEGMEN <> '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_MARCA   = '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_VEND, A3_NOME, CT_SEGMEN, SUBSTR(X5_DESCRI,1,30) "
//aSetField := { { 'EIS11', 'E11_MFAT'   , 'N',17 , 2 },;
//                { 'EIS11', 'E11_MLUCRO' , 'N',17 , 2 },;
//                { 'EIS11', 'E11_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS11', aStruct  )
//
//
////CONSULTA EIS12 - Metas por Cidades
////======================================
//aStruct := { {"E12_FILIAL" ,"C",2 ,0},;
//              {"E12_CCID"   ,"C",6 ,0},;
//              {"E12_NCID"   ,"C",40,0},;
//              {"E12_MFAT"   ,"N",17 ,2},;
//              {"E12_MLUCRO" ,"N",23 ,8},;
//              {"E12_MCUSTO" ,"N",23,8} }
//cQuery := "select CT_FILIAL E12_FILIAL,  CT_CIDADE E12_CCID, Z4_CIDADE E12_NCID, sum(CT_VALOR) E12_MFAT, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) E12_MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) E12_MCUSTO "
//cQuery += " from "+retSqlname('sct')+" sct,"+retSqlname('sz4')+" sz4"
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND Z4_FILIAL (+) = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sz4.D_E_L_E_T_ (+)  = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_CIDADE = Z4_COD (+)"
//cQuery += " AND CT_CIDADE <> '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_MARCA   = '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_VEND    = '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_CIDADE, Z4_CIDADE "
//aSetField := { { 'EIS12', 'E12_MFAT'   , 'N',17 , 2 },;
//                { 'EIS12', 'E12_MLUCRO' , 'N',17 , 2 },;
//                { 'EIS12', 'E12_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS12', aStruct  )
//
//
////CONSULTA EIS13 - Metas por Microregião
////======================================
//aStruct := { {"E13_FILIAL" ,"C",2 ,0},;
//              {"E13_CMCREG" ,"C",6 ,0},;
//              {"E13_NMCREG" ,"C",30,0},;
//              {"E13_MFAT"  ,"N",17 ,2},;
//              {"E13_MLUCRO","N",23 ,8},;
//              {"E13_MCUSTO" ,"N",23,8} }
//cQuery :=  "select CT_FILIAL E13_FILIAL, Z8_CODMICR E13_CMCREG, Z8_NOMEMIC E13_NMCREG, SUM(CT_VALOR) E13_MFAT, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) E13_MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) E13_MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct, "+RetSqlName('sz8')+" sz8"
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND Z8_FILIAL (+) = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sz8.D_E_L_E_T_ (+)  = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_CIDADE = Z8_CODCIDA (+)"
//cQuery += " AND CT_CIDADE <> '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_MARCA   = '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_VEND    = '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, Z8_CODMICR, Z8_NOMEMIC "
//aSetField := { { 'EIS13', 'E13_MFAT'   , 'N',17 , 2 },;
//                { 'EIS13', 'E13_MLUCRO' , 'N',17 , 2 },;
//                { 'EIS13', 'E13_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS13', aStruct  )
//
//
////CONSULTA EIS14 - Metas por Mesoregiao
////=====================================
//aStruct := { {"E14_FILIAL" ,"C",2 ,0},;
//              {"E14_CMSREG" ,"C",6 ,0},;
//              {"E14_NMSREG" ,"C",40,0},;
//              {"E14_MFAT"  ,"N",17 ,2},;
//              {"E14_MLUCRO","N",23 ,8},;
//              {"E14_MCUSTO" ,"N",23,8} }
//cQuery := "select  CT_FILIAL E14_FILIAL, Z9_CODMESO E14_CMSREG, Z9_NOMEMES E14_NMSREG, SUM(CT_VALOR) E14_MFAT, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) E14_MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) E14_MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct,  "+RetSqlName('sz8')+" sz8, "+RetSqlName('sz9')+" sz9 "
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND Z8_FILIAL (+) = '  '"
//cQuery += " AND Z9_FILIAL (+) = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sz8.D_E_L_E_T_ (+)  = ' ' "
//cQuery += " AND sz9.D_E_L_E_T_ (+)  = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_CIDADE = Z8_CODCIDA (+)"
//cQuery += " AND Z8_CODMICR = Z9_CODMICR (+)"
//cQuery += " AND CT_CIDADE <> '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_MARCA   = '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_VEND    = '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, Z9_CODMESO, Z9_NOMEMES "
//aSetField := { { 'EIS14', 'E14_MFAT'   , 'N',17 , 2 },;
//                { 'EIS14', 'E14_MLUCRO' , 'N',17 , 2 },;
//                { 'EIS14', 'E14_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS14', aStruct  )
//
//
////CONSULTA EIS15 - Metas por Estado
////=================================
//aStruct := { {"E15_FILIAL" ,"C",2 ,0},;
//              {"E15_UF"     ,"C",2 ,0},;
//              {"E15_MFAT"  ,"N",17 ,2},;
//              {"E15_MLUCRO","N",23 ,8},;
//              {"E15_MCUSTO" ,"N",23,8} }
//cQuery := "select CT_FILIAL E15_FILIAL,  Z4_UF E15_UF, sum(CT_VALOR) E15_MFAT, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) E15_MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) E15_MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct,  "+RetSqlName('sz4')+" sz4"
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND Z4_FILIAL (+) = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sz4.D_E_L_E_T_ (+)  = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_CIDADE = Z4_COD (+)"
//cQuery += " AND CT_CIDADE <> '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_MARCA   = '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_VEND    = '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, Z4_UF "
//aSetField := { { 'EIS15', 'E15_MFAT'   , 'N',17 , 2 },;
//                { 'EIS15', 'E15_MLUCRO' , 'N',17 , 2 },;
//                { 'EIS15', 'E15_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS15', aStruct  )
//
//
////CONSULTA EIS16 - Metas por Regiao
////=================================
//aStruct := { {"E16_FILIAL" ,"C",2 ,0},;
//              {"E16_CREG"   ,"C",6 ,0},;
//              {"E16_NREG"   ,"C",30,0},;
//              {"E16_MFAT"  ,"N",17 ,2},;
//              {"E16_MLUCRO","N",23 ,8},;
//              {"E16_MCUSTO" ,"N",23,8} }
//cQuery := "select  CT_FILIAL E16_FILIAL, Z7_CODREG E16_CREG, Z7_NOMEREG E16_NREG, SUM(CT_VALOR) E16_MFAT, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) E16_MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) E16_MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct, "+RetSqlName('sz4')+" sz4, "+RetSqlName('sz7')+" sz7 "
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND Z4_FILIAL (+) = '  '"
//cQuery += " AND Z7_FILIAL (+) = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sz4.D_E_L_E_T_ (+)  = ' ' "
//cQuery += " AND sz7.D_E_L_E_T_ (+)  = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_CIDADE = Z4_COD (+)"
//cQuery += " AND Z4_UF = Z7_CODEST (+)"
//cQuery += " AND CT_CIDADE <> '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_MARCA   = '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_VEND    = '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, Z7_CODREG, Z7_NOMEREG "
//aSetField := { { 'EIS16', 'E16_MFAT'   , 'N',17 , 2 },;
//                { 'EIS16', 'E16_MLUCRO' , 'N',17 , 2 },;
//                { 'EIS16', 'E16_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS16', aStruct  )
//
//
////CONSULTA EIS17 - Metas por Filial x Vendedor INTERNO x Marca
////==============================================================
//aStruct := { {"E17_FILIAL" ,"C",2 ,0},;
//              {"E17_VEND"   ,"C",6 ,0},;
//              {"E17_NVEND"  ,"C",40,0},;
//              {"E17_MARCA"  ,"C",20,0},;
//              {"E17_MFAT"   ,"N",17,2},;
//              {"E17_MLUCRO" ,"N",23,8},;
//              {"E17_MCUSTO" ,"N",23,8} }
//cQuery :=  "select CT_FILIAL E17_FILIAL,  CT_VEND E17_VEND, A3_NOME E17_NVEND, CT_MARCA E17_MARCA, SUM(CT_VALOR) E17_MFAT, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100))))  E17_MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) E17_MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct,"+RetSqlName('sa3')+" sa3"
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_  = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " and A3_TIPO = 'I'"
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISVI") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_VEND, A3_NOME, CT_MARCA "
//aSetField := { { 'EIS17', 'E17_MFAT'   , 'N',17 , 2 },;
//                { 'EIS17', 'E17_MLUCRO' , 'N',17 , 2 },;
//                { 'EIS17', 'E17_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS17', aStruct  )
//
//
////CONSULTA EIS18 - Metas por Filial x Vendedor Coordenador x Marca
////================================================================
//aStruct := { {"E18_FILIAL" ,"C",2 ,0},;
//              {"E18_VEND"   ,"C",6 ,0},;
//              {"E18_NVEND"  ,"C",40,0},;
//              {"E18_MARCA"  ,"C",20,0},;
//              {"E18_MFAT"  ,"N",17 ,2},;
//              {"E18_MLUCRO","N",23 ,8},;
//              {"E18_MCUSTO" ,"N",23,8} }
//// Definicao: meta dos coordenador + meta dos seus vendedores externos subordinados
//cQuery := "select SUPER.FILIAL E18_FILIAL, SUPER.SUPERIOR E18_VEND, sa3.A3_NOME E18_NVEND, SUPER.MARCA E18_MARCA, SUM(SUPER.VALOR) E18_MFAT, SUM(SUPER.MLUCRO) E18_MLUCRO, SUM(SUPER.MCUSTO) E18_MCUSTO from "
//// vendedores coordenadores
//cQuery += "( select CT_FILIAL FILIAL, CT_VEND SUPERIOR, CT_MARCA MARCA, SUM(CT_VALOR) VALOR, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct,"+ RetSqlName('sa3')+" sa3 "
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_  = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISCOOR") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_VEND, CT_MARCA "
//// uniao com vendedores externos
//cQuery += " UNION ALL select CT_FILIAL FILIAL, SA3.A3_SUPER SUPERIOR, CT_MARCA E17_MARCA, SUM(CT_VALOR) VALOR, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct,"+ RetSqlName('sa3')+" sa3 "
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL  = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_   = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " AND SA3.A3_TIPO = 'E'"
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISVE") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, A3_SUPER, CT_MARCA ) SUPER , "+RetSqlName('sa3')+" sa3 "
//cQuery += " WHERE sa3.A3_FILIAL (+) = '  '"
//cQuery += " AND sa3.D_E_L_E_T_ (+)  = ' ' "
//cQuery += " AND SUPER.SUPERIOR = sa3.A3_COD (+) "
//cQuery += " group by SUPER.FILIAL, SUPER.SUPERIOR, sa3.A3_NOME, SUPER.MARCA"
//aSetField := { { 'EIS18', 'E18_MFAT'   , 'N',17 , 2 },;
//                { 'EIS18', 'E18_MLUCRO' , 'N',17 , 2 },;
//                { 'EIS18', 'E18_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS18', aStruct  )
//
//
////* CONSULTA EIS19 - Metas por Filial x CHEFE DE VENDAS + MARCA
////=============================================================
//aStruct := { {"E19_FILIAL" ,"C",2 ,0},;
//              {"E19_VEND"   ,"C",6 ,0},;
//              {"E19_NVEND"  ,"C",40,0},;
//              {"E19_MARCA"  ,"C",20,0},;
//              {"E19_MFAT"   ,"N",17,2},;
//              {"E19_MLUCRO" ,"N",23,8},;
//              {"E19_MCUSTO" ,"N",23,8} }
//// Definicao: meta do chefe + meta dos seus vendedores internos subordinados
//cQuery := "select SUPER.FILIAL E19_FILIAL, SUPER.SUPERIOR E19_VEND, sa3.A3_NOME E19_NVEND, SUPER.MARCA E19_MARCA, SUM(SUPER.VALOR) E19_MFAT, SUM(SUPER.MLUCRO) E19_MLUCRO, SUM(SUPER.MCUSTO) E19_MCUSTO from "
//// chefe de vendas
//cQuery += "( select CT_FILIAL FILIAL, CT_VEND SUPERIOR, CT_MARCA MARCA, SUM(CT_VALOR) VALOR, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct,"+ RetSqlName('sa3')+" sa3 "
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_  = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISCHVE") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_VEND, CT_MARCA "
//// uniao com vendedores internos
//cQuery += " UNION ALL select CT_FILIAL FILIAL, SA3.A3_SUPER SUPERIOR, CT_MARCA MARCA, SUM(CT_VALOR) VALOR, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct,"+ RetSqlName('sa3')+" sa3 "
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL  = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_  =	 ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " AND SA3.A3_TIPO = 'I'"
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISVI") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, A3_SUPER, CT_MARCA ) SUPER , "+RetSqlName('sa3')+" sa3 "
//cQuery += " WHERE sa3.A3_FILIAL (+) = '  '"
//cQuery += " AND sa3.D_E_L_E_T_ (+)  = ' ' "
//cQuery += " AND SUPER.SUPERIOR = sa3.A3_COD (+) "
//cQuery += " group by SUPER.FILIAL, SUPER.SUPERIOR, sa3.A3_NOME, SUPER.MARCA "
//aSetField := { { 'EIS19', 'E19_MFAT'   , 'N',17 , 2 },;
//                { 'EIS19', 'E19_MLUCRO' , 'N',17 , 2 },;
//                { 'EIS19', 'E19_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS19', aStruct  )
//
//
////* CONSULTA EIS20 - Metas por Filial x GERENTE DE VENDAS + MARCA
////===============================================================
//aStruct := { {"E20_FILIAL" ,"C",2 ,0},;
//              {"E20_VEND"   ,"C",6 ,0},;
//              {"E20_NVEND"  ,"C",40,0},;
//              {"E20_MARCA"  ,"C",20,0},;
//              {"E20_MFAT"  ,"N",17 ,2},;
//              {"E20_MLUCRO","N",23 ,8},;
//              {"E20_MCUSTO" ,"N",23,8} }
//// Definicao: vendedores internos subordinados + chefe de vendas subordinados agrupados por gerente
//cQuery := "select GERENTE.FILIAL E20_FILIAL, sa3.A3_GEREN E20_VEND, na3.A3_NOME E20_NVEND, GERENTE.MARCA E20_MARCA, SUM(GERENTE.MFAT) E20_MFAT, SUM(GERENTE.MLUCRO) E20_MLUCRO, SUM(GERENTE.MCUSTO) E20_MCUSTO from "
//// meta de venda dos vendedores internos
//cQuery += "(select CT_FILIAL FILIAL,  CT_VEND VEND, A3_NOME NVEND, CT_MARCA MARCA, SUM(CT_VALOR) MFAT, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct ,"+ RetSqlName('sa3')+" sa3"
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL  = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_   = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " and A3_TIPO = 'I'"
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISVI") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_VEND, A3_NOME, CT_MARCA "
//// uniao com meta de venda efetiva do chefe de vendas
//cQuery += "UNION ALL select CT_FILIAL FILIAL, CT_VEND VEND, A3_NOME NVEND, CT_MARCA MARCA, SUM(CT_VALOR) VALOR, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct,"+ RetSqlName('sa3')+" sa3 "
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_  = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISCHVE") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_VEND, A3_NOME, CT_MARCA ) GERENTE , "+RetSqlName('sa3')+" sa3,"+RetSqlName('sa3')+" na3 "
//cQuery += "WHERE sa3.A3_FILIAL = '  ' "
//cQuery += "and na3.A3_FILIAL  = '  ' "
//cQuery += "and sa3.D_E_L_E_T_  = ' ' "
//cQuery += "and na3.D_E_L_E_T_  = ' ' "
//cQuery += "and GERENTE.VEND = sa3.A3_COD "
//cQuery += "and SA3.A3_GEREN = na3.A3_COD "
//cQuery += "and na3.A3_GRPREP IN (" + GETMV("MV_EISGEVE") + ") "
//cQuery += "group by GERENTE.FILIAL, sa3.A3_GEREN, na3.A3_NOME, GERENTE.MARCA "
//aSetField := { { 'EIS20', 'E20_MFAT'   , 'N',17 , 2 },;
//                { 'EIS20', 'E20_MLUCRO' , 'N',17 , 2 },;
//                { 'EIS20', 'E20_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS20', aStruct  )
//
//
////CONSULTA EIS21 - Metas por Filial x DIRETOR DE VENDAS + Marca
////=============================================================
//aStruct := { {"E21_FILIAL" ,"C",2 ,0},;
//              {"E21_VEND"   ,"C",6 ,0},;
//              {"E21_NVEND"  ,"C",40,0},;
//              {"E21_MARCA"  ,"C",20,0},;
//              {"E21_MFAT"   ,"N",17 ,2},;
//              {"E21_MLUCRO" ,"N",23 ,8},;
//              {"E21_MCUSTO" ,"N",23,8} }
//// Definicao: vendedores internos subordinados + chefe de vendas subordinados agrupados por diretores
//cQuery := "select DIRETOR.FILIAL E21_FILIAL, sa3.A3_DIRETOR E21_VEND, na3.A3_NOME E21_NVEND, DIRETOR.MARCA E21_MARCA, SUM(DIRETOR.MFAT) E21_MFAT, SUM(DIRETOR.MLUCRO) E21_MLUCRO, SUM(DIRETOR.MCUSTO) E21_MCUSTO from "
//// meta de venda dos vendedores internos
//cQuery += "(select CT_FILIAL FILIAL,  CT_VEND VEND, A3_NOME NVEND, CT_MARCA MARCA, SUM(CT_VALOR) MFAT, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct ,"+ RetSqlName('sa3')+" sa3"
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL  = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_   = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " and A3_TIPO = 'I'"
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISVI") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_VEND, A3_NOME, CT_MARCA "
//// uniao com meta de venda efetiva do chefe de vendas
//cQuery += "UNION ALL select CT_FILIAL FILIAL, CT_VEND VEND, A3_NOME NVEND, CT_MARCA MARCA, SUM(CT_VALOR) VALOR, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct,"+ RetSqlName('sa3')+" sa3 "
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_  = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISCHVE") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_VEND, A3_NOME, CT_MARCA )  DIRETOR , "+RetSqlName('sa3')+" sa3,"+RetSqlName('sa3')+" na3 "
//cQuery += "WHERE sa3.A3_FILIAL  = '  ' "
//cQuery += "and na3.A3_FILIAL  = '  ' "
//cQuery += "and sa3.D_E_L_E_T_  = ' ' "
//cQuery += "and na3.D_E_L_E_T_  = ' ' "
//cQuery += "and DIRETOR.VEND = sa3.A3_COD  "
//cQuery += "and SA3.A3_DIRETOR = na3.A3_COD  "
//cQuery += "and na3.A3_GRPREP IN (" + GETMV("MV_EISDIVE") + ") "
//cQuery += "group by DIRETOR.FILIAL, sa3.A3_DIRETOR, na3.A3_NOME, DIRETOR.MARCA "
//aSetField := { { 'EIS21', 'E21_MFAT'   , 'N',17 , 2 },;
//                { 'EIS21', 'E21_MLUCRO' , 'N',17 , 2 },;
//                { 'EIS21', 'E21_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS21', aStruct  )
//
//
////CONSULTA EIS22 - Metas por Filial x Vendedor INTERNO x Segmento
////===============================================================
//aStruct := { {"E22_FILIAL" ,"C",2 ,0},;
//              {"E22_VEND"   ,"C",6 ,0},;
//              {"E22_NVEND"  ,"C",40,0},;
//              {"E22_SATIV1" ,"C",6 ,0},;
//              {"E22_DATIVI" ,"C",30,0},;
//              {"E22_MFAT"   ,"N",17 ,2},;
//              {"E22_MLUCRO" ,"N",23 ,8},;
//              {"E22_MCUSTO" ,"N",23,8} }
//cQuery := "select CT_FILIAL E22_FILIAL,  CT_VEND E22_VEND, A3_NOME E22_NVEND, CT_SEGMEN E22_SATIV1, SUBSTR(X5_DESCRI,1,30) E22_DATIVI, SUM(CT_VALOR) E22_MFAT, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) E22_MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) E22_MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct ,"+ RetSqlName('sa3')+" sa3, " + RetSqlName('sx5')+" sx5 "
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL  = '  '"
//cQuery += " AND X5_FILIAL (+) = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_   = ' ' "
//cQuery += " AND sx5.D_E_L_E_T_ (+) = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " and A3_TIPO = 'I'"
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISVI") + ") "
//cQuery += " and sx5.x5_tabela (+) = 'T3' AND sx5.X5_CHAVE (+) = sct.CT_SEGMEN "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_SEGMEN <> '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_MARCA   = '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_VEND, A3_NOME, CT_SEGMEN, SUBSTR(X5_DESCRI,1,30) "
//aSetField := { { 'EIS22', 'E22_MFAT'   , 'N',17 , 2 },;
//                { 'EIS22', 'E22_MLUCRO' , 'N',17 , 2 },;
//                { 'EIS22', 'E22_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS22', aStruct  )
//
//
////* CONSULTA EIS23 - Metas por Filial x Vendedor COORDENADOR x Segmento
////=====================================================================
//aStruct := { {"E23_FILIAL" ,"C",2 ,0},;
//              {"E23_VEND"   ,"C",6 ,0},;
//              {"E23_NVEND"  ,"C",40,0},;
//              {"E23_SATIV1" ,"C",6 ,0},;
//              {"E23_DATIVI" ,"C",30,0},;
//              {"E23_MFAT"   ,"N",17,2},;
//              {"E23_MLUCRO" ,"N",23,8},;
//              {"E23_MCUSTO" ,"N",23,8} }
//// Definicao: meta dos coordenador + meta dos seus vendedores externos subordinados
//cQuery := "select SUPER.FILIAL E23_FILIAL, SUPER.SUPERIOR E23_VEND, sa3.A3_NOME E23_NVEND, SUPER.SATIV1 E23_SATIV1, SUBSTR(X5_DESCRI,1,30) E23_DATIVI, SUM(SUPER.VALOR) E23_MFAT, SUM(SUPER.MLUCRO) E23_MLUCRO, SUM(SUPER.MCUSTO) E23_MCUSTO from "
//// vendedores coordenadores
//cQuery += "( select CT_FILIAL FILIAL, CT_VEND SUPERIOR, CT_SEGMEN SATIV1, SUM(CT_VALOR) VALOR, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct,"+ RetSqlName('sa3')+" sa3 "
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_  = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISCOOR") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_SEGMEN <> '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_MARCA   = '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_VEND, CT_SEGMEN "
//// uniao com vendedores externos
//cQuery += " UNION ALL select CT_FILIAL FILIAL, SA3.A3_SUPER SUPERIOR, CT_SEGMEN SATIV1, SUM(CT_VALOR) VALOR, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct,"+ RetSqlName('sa3')+" sa3 "
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL  = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_   = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " AND SA3.A3_TIPO = 'E'"
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISVE") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_SEGMEN <> '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_MARCA   = '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, A3_SUPER, CT_SEGMEN ) SUPER , "+RetSqlName('sa3')+" sa3, " + RetSqlName('sx5')+" sx5 "
//cQuery += " WHERE sa3.A3_FILIAL (+) = '  '"
//cQuery += " AND X5_FILIAL (+) = '  '"
//cQuery += " AND sa3.D_E_L_E_T_ (+)  = ' ' "
//cQuery += " AND sx5.D_E_L_E_T_ (+) = ' ' "
//cQuery += " AND SUPER.SUPERIOR = sa3.A3_COD (+) "
//cQuery += " and sx5.x5_tabela (+) = 'T3' AND sx5.X5_CHAVE (+) = SUPER.SATIV1 "
//cQuery += " group by SUPER.FILIAL, SUPER.SUPERIOR, sa3.A3_NOME, SUPER.SATIV1, SUBSTR(X5_DESCRI,1,30) "
//aSetField := { { 'EIS23', 'E23_MFAT'   , 'N',17 , 2 },;
//                { 'EIS23', 'E23_MLUCRO' , 'N',17 , 2 },;
//                { 'EIS23', 'E23_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS23', aStruct  )
//
//
////* CONSULTA EIS24 - Metas por Filial x CHEFE DE VENDAS x Segmento
////================================================================
//aStruct := { {"E24_FILIAL" ,"C",2 ,0},;
//              {"E24_VEND"   ,"C",6 ,0},;
//              {"E24_NVEND"  ,"C",40,0},;
//              {"E24_SATIV1" ,"C",6 ,0},;
//              {"E24_DATIVI" ,"C",30,0},;
//              {"E24_MFAT"   ,"N",17,2},;
//              {"E24_MLUCRO" ,"N",23,8},;
//              {"E24_MCUSTO" ,"N",23,8} }
//// Definicao: meta do chefe + meta dos seus vendedores internos subordinados
//cQuery := "select SUPER.FILIAL E24_FILIAL, SUPER.SUPERIOR E24_VEND, sa3.A3_NOME E24_NVEND, SUPER.SATIV1 E24_SATIV1, SUBSTR(X5_DESCRI,1,30) E24_DATIVI, SUM(SUPER.VALOR) E24_MFAT, SUM(SUPER.MLUCRO) E24_MLUCRO, SUM(SUPER.MCUSTO) E24_MCUSTO from "
//// chefe de vendas
//cQuery += "( select CT_FILIAL FILIAL, CT_VEND SUPERIOR, CT_SEGMEN SATIV1, SUM(CT_VALOR) VALOR, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct,"+ RetSqlName('sa3')+" sa3 "
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_  = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISCHVE") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_SEGMEN <> '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_MARCA   = '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_VEND, CT_SEGMEN "
//// uniao com vendedores internos
//cQuery += " UNION ALL select CT_FILIAL FILIAL, SA3.A3_SUPER SUPERIOR, CT_SEGMEN SATIV1, SUM(CT_VALOR) VALOR, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct,"+ RetSqlName('sa3')+" sa3 "
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL  = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_  =	 ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " AND SA3.A3_TIPO = 'I'"
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISVI") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_SEGMEN <> '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_MARCA   = '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, A3_SUPER, CT_SEGMEN ) SUPER , "+RetSqlName('sa3')+" sa3, " + RetSqlName('sx5')+" sx5 "
//cQuery += " WHERE sa3.A3_FILIAL (+) = '  '"
//cQuery += " AND X5_FILIAL (+) = '  '"
//cQuery += " AND sa3.D_E_L_E_T_ (+)  = ' ' "
//cQuery += " AND sx5.D_E_L_E_T_ (+) = ' ' "
//cQuery += " AND SUPER.SUPERIOR = sa3.A3_COD (+) "
//cQuery += " and sx5.x5_tabela (+) = 'T3' AND sx5.X5_CHAVE (+) = SUPER.SATIV1 "
//cQuery += " group by SUPER.FILIAL, SUPER.SUPERIOR, sa3.A3_NOME, SUPER.SATIV1, SUBSTR(X5_DESCRI,1,30) "
//aSetField := { { 'EIS24', 'E24_MFAT'   , 'N',17 , 2 },;
//                { 'EIS24', 'E24_MLUCRO' , 'N',17 , 2 },;
//                { 'EIS24', 'E24_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS24', aStruct  )
//
//
////CONSULTA EIS25 - Metas por Filial x GERENTE DE VENDAS
////======================================================
//aStruct := { {"E25_FILIAL" ,"C",2 ,0},;
//              {"E25_VEND"   ,"C",6 ,0},;
//              {"E25_NVEND"  ,"C",40,0},;
//              {"E25_SATIV1" ,"C",6 ,0},;
//              {"E25_DATIVI" ,"C",30,0},;
//              {"E25_MFAT"   ,"N",17,2},;
//              {"E25_MLUCRO" ,"N",23,8},;
//              {"E25_MCUSTO" ,"N",23,8} }
//// Definicao: vendedores internos subordinados + chefe de vendas subordinados agrupados por gerente
//cQuery := "select GERENTE.FILIAL E25_FILIAL, sa3.A3_GEREN E25_VEND, na3.A3_NOME E25_NVEND, GERENTE.SATIV1 E25_SATIV1, SUBSTR(X5_DESCRI,1,30) E25_DATIVI, SUM(GERENTE.MFAT) E25_MFAT, SUM(GERENTE.MLUCRO) E25_MLUCRO, SUM(GERENTE.MCUSTO) E25_MCUSTO from "
//// meta de venda dos vendedores internos
//cQuery += "(select CT_FILIAL FILIAL,  CT_VEND VEND, A3_NOME NVEND, CT_SEGMEN SATIV1, SUM(CT_VALOR) MFAT, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct ,"+ RetSqlName('sa3')+" sa3"
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL  = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_   = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " and A3_TIPO = 'I'"
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISVI") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_SEGMEN <> '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_MARCA   = '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_VEND, A3_NOME, CT_SEGMEN "
//// uniao com meta de venda efetiva do chefe de vendas
//cQuery += "UNION ALL select CT_FILIAL FILIAL, CT_VEND VEND, A3_NOME NVEND, CT_SEGMEN SATIV1, SUM(CT_VALOR) VALOR, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct,"+ RetSqlName('sa3')+" sa3 "
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_  = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISCHVE") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_SEGMEN <> '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_MARCA   = '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_VEND, A3_NOME, CT_SEGMEN ) GERENTE , "+RetSqlName('sa3')+" sa3,"+RetSqlName('sa3')+" na3, " + RetSqlName('sx5')+" sx5 "
//cQuery += "WHERE sa3.A3_FILIAL = '  ' "
//cQuery += "and na3.A3_FILIAL  = '  ' "
//cQuery += "AND X5_FILIAL (+) = '  ' "
//cQuery += "and sa3.D_E_L_E_T_  = ' ' "
//cQuery += "and na3.D_E_L_E_T_  = ' ' "
//cQuery += "AND sx5.D_E_L_E_T_ (+) = ' ' "
//cQuery += "and GERENTE.VEND = sa3.A3_COD "
//cQuery += "and SA3.A3_GEREN = na3.A3_COD "
//cQuery += "and na3.A3_GRPREP IN (" + GETMV("MV_EISGEVE") + ") "
//cQuery += "and sx5.x5_tabela (+) = 'T3' AND sx5.X5_CHAVE (+) = GERENTE.SATIV1 "
//cQuery += "group by GERENTE.FILIAL, sa3.A3_GEREN, na3.A3_NOME, GERENTE.SATIV1, SUBSTR(X5_DESCRI,1,30)"
//aSetField := { { 'EIS25', 'E25_MFAT'   , 'N',17 , 2 },;
//                { 'EIS25', 'E25_MLUCRO' , 'N',17 , 2 },;
//                { 'EIS25', 'E25_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS25', aStruct  )
//
//
////CONSULTA EIS26 - Metas por Filial x DIRETOR DE VENDAS
////========================================================
//aStruct := { {"E26_FILIAL" ,"C",2 ,0},;
//              {"E26_VEND"   ,"C",6 ,0},;
//              {"E26_NVEND"  ,"C",40,0},;
//              {"E26_SATIV1" ,"C",6 ,0},;
//              {"E26_DATIVI" ,"C",30,0},;
//              {"E26_MFAT"   ,"N",17,2},;
//              {"E26_MLUCRO" ,"N",23,8},;
//              {"E26_MCUSTO" ,"N",23,8} }
//// Definicao: vendedores internos subordinados + chefe de vendas subordinados agrupados por diretores
//cQuery := "select DIRETOR.FILIAL E26_FILIAL, sa3.A3_DIRETOR E26_VEND, na3.A3_NOME E26_NVEND, DIRETOR.SATIV1 E26_SATIV1, SUBSTR(X5_DESCRI,1,30) E26_DATIVI, SUM(DIRETOR.MFAT) E26_MFAT, SUM(DIRETOR.MLUCRO) E26_MLUCRO, SUM(DIRETOR.MCUSTO) E26_MCUSTO from "
//// meta de venda dos vendedores internos
//cQuery += "(select CT_FILIAL FILIAL,  CT_VEND VEND, A3_NOME NVEND, CT_SEGMEN SATIV1, SUM(CT_VALOR) MFAT, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct ,"+ RetSqlName('sa3')+" sa3"
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL  = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_   = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " and A3_TIPO = 'I'"
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISVI") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_SEGMEN <> '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_MARCA   = '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_VEND, A3_NOME, CT_SEGMEN "
//// uniao com meta de venda efetiva do chefe de vendas
//cQuery += "UNION ALL select CT_FILIAL FILIAL, CT_VEND VEND, A3_NOME NVEND, CT_SEGMEN SATIV1, SUM(CT_VALOR) VALOR, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MLUCRO, SUM(CT_VALOR/(1+(CT_MARGEM/100))) MCUSTO "
//cQuery += " from "+RetSqlName('sct')+" sct,"+ RetSqlName('sa3')+" sa3 "
//cQuery += " where CT_FILIAL IN (" + cFilImd + ")"
//cQuery += " AND A3_FILIAL = '  '"
//cQuery += " AND sct.D_E_L_E_T_  = ' ' "
//cQuery += " AND sa3.D_E_L_E_T_  = ' ' "
//cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
//cQuery += " AND CT_VEND = A3_COD "
//cQuery += " and A3_GRPREP IN (" + GETMV("MV_EISCHVE") + ") "
//cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
//cQuery += " AND CT_SEGMEN <> '"+space(len(SCT->CT_SEGMEN))+"'"
//cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
//cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
//cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
//cQuery += " AND CT_MARCA   = '"+space(len(SCT->CT_MARCA))+"'"
//cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
//cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
//cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
//cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
//cQuery += " group by CT_FILIAL, CT_VEND, A3_NOME, CT_SEGMEN )  DIRETOR , "+RetSqlName('sa3')+" sa3,"+RetSqlName('sa3')+" na3, " + RetSqlName('sx5')+" sx5 "
//cQuery += "WHERE sa3.A3_FILIAL  = '  ' "
//cQuery += "and na3.A3_FILIAL  = '  ' "
//cQuery += "AND X5_FILIAL (+) = '  ' "
//cQuery += "and sa3.D_E_L_E_T_  = ' ' "
//cQuery += "and na3.D_E_L_E_T_  = ' ' "
//cQuery += "AND sx5.D_E_L_E_T_ (+) = ' ' "
//cQuery += "and DIRETOR.VEND = sa3.A3_COD  "
//cQuery += "and SA3.A3_DIRETOR = na3.A3_COD  "
//cQuery += "and na3.A3_GRPREP IN (" + GETMV("MV_EISDIVE") + ") "
//cQuery += "and sx5.x5_tabela (+) = 'T3' AND sx5.X5_CHAVE (+) = DIRETOR.SATIV1 "
//cQuery += "group by DIRETOR.FILIAL, sa3.A3_DIRETOR, na3.A3_NOME, DIRETOR.SATIV1, SUBSTR(X5_DESCRI,1,30) "
//aSetField := { { 'EIS26', 'E26_MFAT'   , 'N',17 , 2 },;
//               { 'EIS26', 'E26_MLUCRO' , 'N',17 , 2 },;
//               { 'EIS26', 'E26_MCUSTO' , 'N',17 , 2 } }
//MyQuery( cQuery , 'EIS26', aStruct  )
//
//// Atualizacao do numero de dias restantes e dos dias passados
//If Select('EIS00') <> 0
//   EIS00->( dbCloseArea())
//Endif
////Use (path+'eis00') EXCLUSIVE NEW ALIAS EIS00 via "DBFCDXADS"
//Use (path+'eis00') EXCLUSIVE NEW ALIAS EIS00
//dbGotop()
//cFilTmp := "zz"
//Do While !Eof()
//	RecLock('EIS00',.F.)
//		// grava faturamento de hoje
//		If DTOS( ddatabase ) == EIS00->E00_DATA
//    	   EIS00->E00_FATHOJ := EIS00->E00_FAT
//    	   EIS00->E00_LUCHOJ := EIS00->E00_LUCRO
//    	   EIS00->E00_CUSHOJ := EIS00->E00_CUSIMD
//    	   EIS00->E00_FAT    := 0
//    	   EIS00->E00_LUCRO  := 0
//    	   EIS00->E00_CUSIMD := 0
//		Endif
//
//		// grava dias restantes e passados
//	   	If cFilTmp != EIS00->E00_FILIAL
//			nPos := aScan(aDiasRest, {|x| x[1]==EIS00->E00_FILIAL})
//			cFilTmp := EIS00->E00_FILIAL
//		Endif
//		EIS00->E00_DIASRE :=  aDiasRest[nPos,2]
//		EIS00->E00_DIASPA :=  aDiasPass[nPos,2]
//   MsUnLock()
//   dbSkip()
//Enddo
//IncProc()
//EIS00->( dbCloseArea())
//
//// Destrava para poder rodar esta rotina novamente
//u_ImdMyUnlock()
//
//Return .T.
//
//
//
///**
//* Transforma cQuery em arquivo com os
//* dados - comunica com o Top
//*/
//
////MyQuery( cQuery , 'EIS06', aStruct  )
//
//Static Function MyQuery( cQuery , dest, aStruct )
//Local nI
//cQuery := ChangeQuery(cQuery)
//
///** Mostrar a consulta  **/
///*@ 116,090 To 416,707 Dialog oDlgMemo Title dest
//@ 055,005 Get cQuery   Size 250,080  MEMO Object oMemo
//Activate Dialog oDlgMemo*/
//IF SELECT( '_TMP' ) <> 0
//   dbSelectArea('_TMP')
//   Use
//Endif
////TCSQLEXEC("DROP TABLE "+dest)
////TCQUERY cQuery NEW ALIAS _TMP
////COPY TO ( path+dest ) via "TOPCONN"
///*if dest = "EIS00"
//	alert("antes da primeira query")
//endif*/
//TCQUERY cQuery NEW ALIAS _TMP
//IncProc()
///*if dest = "EIS00"
//	alert("apos a primeira query")
//endif*/
//for nI := 1 to Len(aSetField)
//	TCSetField( "_TMP",aSetField[nI,2]  , aSetField[nI,3],aSetField[nI,4], aSetField[nI,5] )
//next
//
////*************************************************************************************
//If file(path+dest+".dbf")
//	If Ferase(path+dest+".dbf") == -1
//		alert("Erro ao excluir arquivo temporario "+path+dest+".dbf")
//		Return
//	Endif
//Endif
//
//
//dbCreate(path+dest+".dbf",aStruct,"DBFCDXADS")
//Use (path+dest+".dbf") EXCLUSIVE NEW via "DBFCDXADS"
//***************************************************************************************
////dbCreate(path+dest,aStruct,'DBFCDX')
////Use (path+dest) EXCLUSIVE NEW via "DBFCDX"
////MSGINFO('CRIEI')
//
//append from _TMP
//Use
//IncProc()
//Return
//
///*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³EXISTTABLEºAutor  ³Carlos Galimberti   º Data ³  12/26/02   º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³ Checa no dicionario do ORACLE se existe a tabela passado   º±±
//±±º          ³ no parametro.                                              º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºUso       ³ AP6                                                        º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
///*/
//User Function ExistTable(cTableName)
//Local aAreaAnt := GetArea()
//Local nRet, aArea := Alias()
//Local cQry
//
//// Query
//cQry  :=  "SELECT COUNT(*) QTDOCOR FROM all_tables where table_name = '" + cTableName + "' "
//
//TCQuery cQry NEW ALIAS "TRB"
//TCSetField("TRB","QTDOCOR","N",1,0)
//
////aResult := TCSPExec("SP_ExistTable",cTableName)
//nRet := TRB->QTDOCOR
//IF SELECT( 'TRB' ) <> 0
//   dbSelectArea('TRB')
//   Use
//Endif
//
//MsgInfo('IMPRIMINDO VALOR DA AREA ATUAL '+aArea)
//
//If aArea <> nil .and. !Empty(aArea) //aArea <> nil .or. Empty(aArea) //marcio
//	dbSelectArea(aArea)
//EndIf
//
//Return nRet > 0
//
///*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºFuncao    ³ ImdMyLock        º Autor ³Julio Witwer     º Data ³           º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao ³ Trava para operacao critica                                º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºSintaxe   ³ ImdMyLock(cKey)                                               º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºParametros³ ExpC1 - Chave que sera utilizada para criar arquivo de     º±±
//±±º          ³ controle das travas.                                       º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
///*/
//User Function ImdMyLock(cKey,nTentativas)
//__ccArq := cKey+".LCK"
//nCont := 1
//While (__nnLock := fcreate(__ccArq)) == -1
//    If KillApp()
//        conout("ImdMyLock abort on "+procname(1))
//        __nnLock := -1
//    Endif
//    nCont++
//    If nCont > nTentativas
//    	Exit
//    Endif
//    sleep(1000)
//Enddo
//Return ( __nnLock <> -1 )
//
///*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºFuncao    ³ ImdMyUnlock      º Autor ³Julio Witwer     º Data ³           º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao ³ Libera chamada de operacao critica (inverso da ImdMyLock)     º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºSintaxe   ³ ImdMyUnlock()                                                 º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºParametros³ Nenhum                                                     º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
///*/
//User Function ImdMyUnlock()
//If __nnLock != -1
//    fclose(__nnLock)
//    ferase(__ccArq)
//Endif
//Return .T.