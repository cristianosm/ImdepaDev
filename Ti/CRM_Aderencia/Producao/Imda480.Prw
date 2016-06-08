#include "topconn.ch"
#include "rwmake.ch"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ U_IMDA480   ³ Autor ³Expedito Mendonca Jr³ Data ³ 01/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processamento de dados com o objetivo de gerar um historico³±±
±±³          ³ de faturamento mes a mes, por vendedor. O resultado deste  ³±±
±±³          ³ processamento sera armazenado num arquivo padrao .DBF      ³±±
±±³          ³ para ser aberto via Microsoft Excel.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_IMDA480()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico p/ o cliente Imdepa                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
User Function IMDA480()
Private cPerg, aDados := {}

// Atualiza arquivo de parametros SX1
// aDados := { 1.PERGUNT,2.PERSPA,3.PERENG,4.VARIAVL,5.TIPO,6.TAMANHO,7.DECIMAL,8.PRESEL,9.GSC,10.VALID,11.VAR01,12.DEF01,13.DEFSPA1,14.DEFENG1,15.CNT01,16.VAR02,17.DEF02,18.DEFSPA2,19.DEFENG2,20.CNT2,
//             21.VAR03,22.DEF03,23.DEFSPA3,24.DEFENG3,25.CNT3,26.VAR04,27.DEF04,28.DEFSPA4,29.DEFENG4,30.CNT4,31.VAR05,32.DEF05,33.DEFSPA5,34.DEFENG5,35.CNT5,36.F3,37.PYME,38.GRPSXG}
aAdd(aDados,{ "Campanha?           ","Campanha?           ","Campanha?           ","mv_ch1","C", 6,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SUO","","" })
aAdd(aDados,{ "Mes de?             ","Mes de?             ","Mes de?             ","mv_ch2","C", 2,0,0,"G","(mv_par02 >= '01' .and. mv_par02 <= '12')","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
aAdd(aDados,{ "Ano de?             ","Ano de?             ","Ano de?             ","mv_ch3","C", 4,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
aAdd(aDados,{ "Mes ate?            ","Mes ate?            ","Mes ate?            ","mv_ch4","C", 2,0,0,"G","(mv_par04 >= '01' .and. mv_par04 <= '12')","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
aAdd(aDados,{ "Ano ate?            ","Ano ate?            ","Ano ate?            ","mv_ch5","C", 4,0,0,"G","(mv_par05+mv_par04 >= mv_par03+mv_par02)","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
aAdd(aDados,{ "Considera Devolucoes","Considera Devolucoes","Considera Devolucoes","mv_ch6","N", 1,0,0,"C","","mv_par06","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","","","","" })
aAdd(aDados,{ "Quais vendedores?   ","Quais vendedores?   ","Quais vendedores?   ","mv_ch7","C", 6,0,0,"G","U_TPVENDS","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
cPerg      := "IMDA48"

AjustaSx1( cPerg, aDados )
If Pergunte(cPerg,.T.)

	If MsgYesNo( 'Confirma processamento?', 'Export.Excel - Metas de Campanhas de Vendas ' )

		// Realiza o processamentoo para selecao dos registros
		Processa( {||IMDA480PROC()}, "Aguarde...","Processando Export.Excel - Metas de Campanhas" )
		
	Endif	

Endif	
Return NIL


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ IMDA480PROC ³ Autor ³Expedito Mendonca Jr³ Data ³ 01/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Processamento para geracao do arquivo com dados historicos ³±±
±±³          ³ de vendas por vendedor ou vendedor+produto.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ IMDR180PROC()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ U_IMDA480                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function IMDA480PROC()
LOCAL nI, nQtdProc, nQtdDec
LOCAL aStruct, cArq
LOCAL cPathCompleto := Getmv("MV_DIRCV")
LOCAL cExecExcel := Getmv("MV_EXCEL")
LOCAL cPathRoot := "\cv\"
PRIVATE aMeses := {"JAN","FEV","MAR","ABR","MAI","JUN","JUL","AGO","SET","OUT","NOV","DEZ"}, nMes, nAno
PRIVATE aTpVends, aLTpVends, lTpVends


// Define quais tipos de vendedores deverao aparecer no historico de vendas
aLTpVends := {"I"$mv_par07,"E"$mv_par07,"C"$mv_par07,"H"$mv_par07,"G"$mv_par07,"D"$mv_par07}
aTpVends  := {"Int.","Ext.","Coord.","Chefe","Gerente","Diretor"}
lTpVends := aLTpVends[1] .or. aLTpVends[2] .or. aLTpVends[3] .or. aLTpVends[4] .or. aLTpVends[5] .or. aLTpVends[6]

// Calcula a quantidade de processos desta rotina para definir a regua de processamento
nQtdProc := 0
for nI := 1 to Len(aLTpVends)
	If aLTpVends[nI]
		nQtdProc += 2
	Endif
next
ProcRegua(nQtdProc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Localiza a campanha de vendas                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SUO")
dbSetOrder(1)
If !dbSeek(xFilial("SUO")+MV_PAR01,.F.)
	MsgBox("Campanha não encontrada","Atenção","STOP")
	Return NIL
Endif

// Define o nome do arquivo
cArq := "cv"+IIF(SUO->UO_TPMETA == "2" , "q" , "v")+"_orig.xls"

// Define estrutura do arquivo
aStruct := { {"FILIAL"      , "C" , 15 , 0 },;
              {"VENDEDOR"   , "C" , 6  , 0 },;
              {"NOME"       , "C" , 40 , 0 },;
              {"TIPO"       , "C" , 7 , 0 } }

If SUO->UO_TPMETA == "2"	// quantidades
	aAdd(aStruct,{"PRODUTO"  , "C" , 15 , 0 } )
	aAdd(aStruct,{"DESCRICAO", "C" , 40 , 0 } )
Endif

// Define os campos referentes aos periodos
nMes := Val(mv_par02)
nAno := Val(mv_par03)
nQtdDec := IIF(SUO->UO_TPMETA == "2", 0, 2)
for nI := 1 to 12
	aAdd(aStruct,{aMeses[nMes]+strzero(nAno,4) , "N" , 17 , nQtdDec } )
	nMes ++
	If nMes > 12
		nMes := 1
		nAno ++
	Endif
next

// Verifica se o arquivo ja existe e o apaga
If File(cPathRoot+cArq)
	fERASE(cPathRoot+cArq)
	If FERROR() != 0
		MsgBox("Erro ao excluir arquivo temporário anterior. Código do erro: "+Str(FERROR()),"Atenção","STOP")
		Return NIL
	Endif
Endif

// Cria o arquivo
dbCreate(cPathRoot+cArq,aStruct,"DBFCDXADS")   // MP8 nao aceita desta forma

Use (cPathRoot+cArq) EXCLUSIVE NEW via "DBFCDXADS" alias "CAM"   // MP8 nao aceita desta forma

IncProc()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria e executa a Query para selecao dos registros            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !IMDA480QUERY()
	MsgAlert("Problema na criacao da QUERY !")
EndIf	

dbSelectArea("CAM")
dbCloseArea()

// Carrega o Excel
WinExec(cExecExcel+" "+cPathCompleto+cArq)

Return nil



/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ IMDA480QUERY³ Autor ³Expedito Mendonca Jr³ Data ³ 26/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Query para selecao dos registros						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ IMDA480QUERY()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ IMDA480PROC                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function IMDA480QUERY()
LOCAL nI, nJ
LOCAL lOk     := .F.
LOCAL aStru   := {}
LOCAL cQuery, cFiliais, cFilFiltro, aFiliais, nRecSM0
LOCAL dDataIni, dDataFim, nMesTmp, nAnoTmp, bChave
LOCAL cFilTmp, cNomFilTmp
Private cMacro

          
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01 // Qual Campanha?                                   ³
//³ mv_par02 // Mes de?                                          ³
//³ mv_par03 // Ano de?                                          ³
//³ mv_par04 // Mes ate?                                         ³
//³ mv_par05 // Ano ate?                                         ³
//³ mv_par06 // Considera devolucoes?                            ³
//³ mv_par07 // Quais vendedores? Internos, Externos, etc...     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Define periodo
dDataIni := ctod( "01/"+strzero(val(mv_par02),2)+"/"+strzero(val(mv_par03),4) )
nMesTmp := val(mv_par04)+1
nAnoTmp := val(mv_par05)
If nMesTmp > 12
	nMesTmp := 1
	nAnoTmp ++
Endif
dDataFim := ctod( "01/"+strzero(nMesTmp,2)+"/"+strzero(nAnoTmp,4) ) - 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define quais sao todas as filiais                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiliais := ""
aFiliais := {}
dbSelectArea("SM0")
nRecSM0 := Recno()
dbSeek(cEmpAnt,.F.)
Do While SM0->M0_CODIGO == cEmpAnt .and. !Eof()
	cFiliais += "'" + SM0->M0_CODFIL + "',"
	aAdd(aFiliais,{SM0->M0_CODFIL,SM0->M0_FILIAL})
	dbSkip()
Enddo
cFiliais := Left(cFiliais,Len(cFiliais)-1)
dbGoto(nRecSM0) 	
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define filtro de filiais                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SUO->UO_FILIAIS == "2" // Amarracao Campanhas x Filiais
	cFilFiltro := ""
	dbSelectArea("ZZ9")
	dbSetOrder(1)
	dbSeek(xFilial("ZZ9")+SUO->UO_CODCAMP)
	Do While ZZ9->ZZ9_FILIAL+ZZ9->ZZ9_CODCAM == xFilial("ZZ9")+SUO->UO_CODCAMP .and. !Eof()
		cFilFiltro += "'" + ZZ9->ZZ9_CFILIA + "',"
		dbSkip()	
	Enddo
	cFilFiltro := Left(cFilFiltro,Len(cFilFiltro)-1)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona dados de historico de vendas por vendedor          ³
//³ Obs.: Se a pergunta "Qual indicador?" estiver configurada    ³
//³ Valor Faturado, os dados serao agrupados por Filial+Vendedor,³
//³ caso seja por Quantidade, os dados serao agrupados por       ³
//³ Filial + Vendedor + Produto.                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aGrpRep := {GETMV("MV_EISVI"),GETMV("MV_EISVE"),GETMV("MV_EISCOOR"),GETMV("MV_EISCHVE"),GETMV("MV_EISGEVE"),GETMV("MV_EISDIVE")}
bChave := IIF(SUO->UO_TPMETA == "2" , {|| TRB->FILVEND+TRB->VENDEDOR+TRB->PRODUTO} , {|| TRB->FILVEND+TRB->VENDEDOR} )
for nI := 1 to 5
	If aLTpVends[nI]

		cQuery := "SELECT VENDPROD.FILVEND FILVEND, VENDPROD.VEND VENDEDOR, VENDPROD.NOMEVEN NOMEVEN, "
		If SUO->UO_TPMETA == "2"	// Quando for meta por quantidade, abre por produto
			cQuery += "VENDPROD.PRODUTO PRODUTO, VENDPROD.DESCPRO DESCPRO, "
		Endif
		cQuery += "HIST.ANO_MES ANO_MES, "
		cQuery += IIF( SUO->UO_TPMETA == "2" , "SUM(HIST.QUANT) QUANT " , "SUM(HIST.VALOR) VALOR " )
		cQuery += "FROM "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Vendedores ou Vendedores+Produtos                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		cQuery += " (SELECT SUBSTR(SA3.A3_ITEMD,2,2) FILVEND, SA3.A3_COD VEND, SA3.A3_NOME NOMEVEN "
		If SUO->UO_TPMETA != "2"	// Quando for meta por valor, nao abre por produto
			cQuery += "FROM "+RetSqlName("SA3")+" SA3 "
		Else						// Quando for meta por quantidade, abre por produto
			cQuery += ", SB1.B1_COD PRODUTO, SB1.B1_DESC DESCPRO "
			cQuery += "FROM "+RetSqlName("SA3")+" SA3, "+RetSqlName("SB1")+" SB1 "
		Endif	
		If SUO->UO_VEND == "2" // Amarracao Campanhas x Vendedores
			cQuery += ", "+RetSqlName("ZZA")+" ZZA "
		Endif			
		If SUO->UO_TPMETA == "2"	// Quantidade, aglutina por Filial+Vendedor+Produto
			If SUO->UO_MARCA == "2" // Amarracao Campanhas x Marcas
				cQuery += ", "+RetSqlName("ZZ3")+" ZZ3 "
			Endif
			If SUO->UO_GRUPO == "2" // Amarracao Campanhas x Grupo
				cQuery += ", "+RetSqlName("ZZ4")+" ZZ4 "
			Endif
			If SUO->UO_SUBGR1 == "2" // Amarracao Campanhas x SubGrupo1
				cQuery += ", "+RetSqlName("ZZ5")+" ZZ5 "
			Endif
			If SUO->UO_SUBGR2 == "2" // Amarracao Campanhas x SubGrupo2
				cQuery += ", "+RetSqlName("ZZ6")+" ZZ6 "
			Endif		
			If SUO->UO_SUBGR3 == "2" // Amarracao Campanhas x SubGrupo3
				cQuery += ", "+RetSqlName("ZZ7")+" ZZ7 "
			Endif			
			If SUO->UO_PRODUTO == "2" // Amarracao Campanhas x Produtos
				cQuery += ", "+RetSqlName("ZZ8")+" ZZ8 "
			Endif				
		Endif		
		cQuery += " WHERE SA3.A3_FILIAL = '  '"
		If SUO->UO_FILIAIS == "2" // Amarracao Campanhas x Filiais
			cQuery += " AND SUBSTR(SA3.A3_ITEMD,2,2) IN ( " + cFilFiltro + " ) "
		Endif
		cQuery += " AND SA3.A3_GRPREP IN (" + aGrpRep[nI] + ") "		
		If nI == 1
			cQuery += " AND SA3.A3_TIPO = 'I'"
		Elseif nI == 2
			cQuery += " AND SA3.A3_TIPO = 'E'"		
		Endif	
		If SUO->UO_VEND == "2" // Amarracao Campanhas x Vendedores
			cQuery += " AND ZZA.ZZA_FILIAL = '  '"
			cQuery += " AND ZZA.ZZA_CODCAM = '"+SUO->UO_CODCAMP+"'"
			cQuery += " AND ZZA.ZZA_VEND = SA3.A3_COD
			cQuery += " AND ZZA.ZZA_NIVEL = '"+str(nI,1)+"'"
			cQuery += " AND ZZA.D_E_L_E_T_ = ' '"					
		Endif					
		// deletados
		cQuery += " AND SA3.D_E_L_E_T_ = ' '"		
		If SUO->UO_TPMETA == "2"	// Quantidade, aglutina por Filial+Vendedor+Produto		
			cQuery += " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
			If SUO->UO_MARCA == "2" // Amarracao Campanhas x Marcas
				cQuery += " AND ZZ3.ZZ3_FILIAL = '  '"
				cQuery += " AND ZZ3.ZZ3_CODCAM = '"+SUO->UO_CODCAMP+"'"
				cQuery += " AND ZZ3.ZZ3_MARCA = SB1.B1_MARCA"
				cQuery += " AND ZZ3.D_E_L_E_T_ = ' '"						
			Endif
			If SUO->UO_GRUPO == "2" // Amarracao Campanhas x Grupo
				cQuery += " AND ZZ4.ZZ4_FILIAL = '  '"
				cQuery += " AND ZZ4.ZZ4_CODCAM = '"+SUO->UO_CODCAMP+"'"
				cQuery += " AND ZZ4.ZZ4_GRUPO = SB1.B1_GRUPO"
				cQuery += " AND ZZ4.D_E_L_E_T_ = ' '"										
			Endif
			If SUO->UO_SUBGR1 == "2" // Amarracao Campanhas x SubGrupo1
				cQuery += " AND ZZ5.ZZ5_FILIAL = '  '"
				cQuery += " AND ZZ5.ZZ5_CODCAM = '"+SUO->UO_CODCAMP+"'"
				cQuery += " AND ZZ5.ZZ5_SUBGR1 = SB1.B1_SGRB1"
				cQuery += " AND ZZ5.D_E_L_E_T_ = ' '"										
			Endif
			If SUO->UO_SUBGR2 == "2" // Amarracao Campanhas x SubGrupo2
				cQuery += " AND ZZ6.ZZ6_FILIAL = '  '"
				cQuery += " AND ZZ6.ZZ6_CODCAM = '"+SUO->UO_CODCAMP+"'"
				cQuery += " AND ZZ6.ZZ6_SUBGR2 = SB1.B1_SGRB2"
				cQuery += " AND ZZ6.D_E_L_E_T_ = ' '"										
			Endif		
			If SUO->UO_SUBGR3 == "2" // Amarracao Campanhas x SubGrupo3
				cQuery += " AND ZZ7.ZZ7_FILIAL = '  '"
				cQuery += " AND ZZ7.ZZ7_CODCAM = '"+SUO->UO_CODCAMP+"'"
				cQuery += " AND ZZ7.ZZ7_SUBGR3 = SB1.B1_SGRB3"
				cQuery += " AND ZZ7.D_E_L_E_T_ = ' '"										
			Endif			
			If SUO->UO_PRODUTO == "2" // Amarracao Campanhas x Produtos
				cQuery += " AND ZZ8.ZZ8_FILIAL = '  '"
				cQuery += " AND ZZ8.ZZ8_CODCAM = '"+SUO->UO_CODCAMP+"'"
				cQuery += " AND ZZ8.ZZ8_PRODUT = SB1.B1_COD"
				cQuery += " AND ZZ8.D_E_L_E_T_ = ' '"										
			Endif				
			cQuery += " AND SB1.D_E_L_E_T_ = ' '"						
		Endif
		cQuery += ") VENDPROD, "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Historico de Vendas				                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
		cQuery += "( SELECT SF2.F2_FILCLI FILCLI, SF2.F2_VEND"+str(nI,1)+" VENDEDOR, "
		If SUO->UO_TPMETA == "2"	// Quando for quantidade, abre a meta por produtos
			cQuery += " SD2.D2_COD PRODUTO,  "
		Endif
		cQuery += "SUBSTR(SD2.D2_EMISSAO,1,6) ANO_MES, "
		cQuery += IIF( SUO->UO_TPMETA == "2" , "SUM(SD2.D2_QUANT) QUANT " , "SUM(SD2.D2_TOTAL) VALOR ")
		
		cQuery += " FROM "+RetSqlName("SD2")+" SD2, " + RetSqlName("SF2")+" SF2, " + RetSqlName("SF4")+" SF4"
		
		// Verifica se eh necessario utilizar o arquivo SB1
		If SUO->UO_TPMETA == "2" .or. SUO->UO_MARCA == "2" .or. SUO->UO_GRUPO == "2" .or. SUO->UO_SUBGR1 == "2" .or. SUO->UO_SUBGR2 == "2" .or. SUO->UO_SUBGR3 == "2"
			cQuery += ", " + RetSqlName("SB1")+" SB1"
		Endif
		
		// Verifica se eh necessario utilizar o arquivo SA1		
		If Val(SUO->UO_AREAS) > 1 .or. SUO->UO_ATIVIDA == "2" .or. SUO->UO_SATIV1 == "2" .or. SUO->UO_SATIV2 == "2"
			cQuery += ", " + RetSqlName("SA1")+" SA1"		
		Endif

		cQuery += IIF(SUO->UO_MARCA == "2" , ", "+RetSqlName("ZZ3")+" ZZ3" , "")	// Amarracao Campanhas x Marcas
		cQuery += IIF(SUO->UO_GRUPO == "2" , ", "+RetSqlName("ZZ4")+" ZZ4" , "")	// Amarracao Campanhas x Grupos
		cQuery += IIF(SUO->UO_SUBGR1 == "2" , ", "+RetSqlName("ZZ5")+" ZZ5" , "")	// Amarracao Campanhas x SubGrupo1
		cQuery += IIF(SUO->UO_SUBGR2 == "2" , ", "+RetSqlName("ZZ6")+" ZZ6" , "")	// Amarracao Campanhas x SubGrupo2
		cQuery += IIF(SUO->UO_SUBGR3 == "2" , ", "+RetSqlName("ZZ7")+" ZZ7" , "")	// Amarracao Campanhas x SubGrupo3
		cQuery += IIF(SUO->UO_PRODUTO == "2" , ", "+RetSqlName("ZZ8")+" ZZ8" , "")	// Amarracao Campanhas x Produtos
		cQuery += IIF(SUO->UO_VEND == "2" , ", "+RetSqlName("ZZA")+" ZZA" , "")		// Amarracao Campanhas x Vendedores
		cQuery += IIF(VAL(SUO->UO_AREAS) > 1 , ", "+RetSqlName("ZZB")+" ZZB" , "")	// Amarracao Campanhas x Areas Geograficas
		cQuery += IIF(SUO->UO_ATIVIDA == "2" , ", "+RetSqlName("ZZC")+" ZZC" , "")	// Amarracao Campanhas x Codigos de Atividade
		cQuery += IIF(SUO->UO_SATIV1 == "2" , ", "+RetSqlName("ZZD")+" ZZD" , "")	// Amarracao Campanhas x Segmento 1          		
		cQuery += IIF(SUO->UO_SATIV2 == "2" , ", "+RetSqlName("ZZE")+" ZZE" , "")	// Amarracao Campanhas x Segmento 2          						
		cQuery += IIF(SUO->UO_CLIENTE == "2" , ", "+RetSqlName("ZZF")+" ZZF" , "")	// Amarracao Campanhas x Clientes  

		cQuery += " WHERE SD2.D2_FILIAL IN ( " + cFiliais + " ) "

		// Filtro por Periodo
		cQuery += " AND SD2.D2_EMISSAO BETWEEN '" + DTOS(dDataIni) + "' AND '" + DTOS(dDataFim) + "'"
	
		// Relacionamentos
		// SF2
		cQuery += " AND SF2.F2_FILIAL = SD2.D2_FILIAL"
		cQuery += " AND SF2.F2_DOC = SD2.D2_DOC"
		cQuery += " AND SF2.F2_SERIE = SD2.D2_SERIE"
		cQuery += " AND SF2.F2_CLIENTE = SD2.D2_CLIENTE"
		cQuery += " AND SF2.F2_LOJA = SD2.D2_LOJA"
	
		// SF4
		cQuery += " AND SF4.F4_FILIAL = SD2.D2_FILIAL"
		cQuery += " AND SF4.F4_CODIGO = SD2.D2_TES"
		
		// SB1
		If SUO->UO_TPMETA == "2" .or. SUO->UO_MARCA == "2" .or. SUO->UO_GRUPO == "2" .or. SUO->UO_SUBGR1 == "2" .or. SUO->UO_SUBGR2 == "2" .or. SUO->UO_SUBGR3 == "2"
			cQuery += " AND SB1.B1_FILIAL = SD2.D2_FILIAL"
			cQuery += " AND SB1.B1_COD = SD2.D2_COD"	
		Endif	

		// SA1
		If Val(SUO->UO_AREAS) > 1 .or. SUO->UO_ATIVIDA == "2" .or. SUO->UO_SATIV1 == "2" .or. SUO->UO_SATIV2 == "2"
			cQuery += " AND SA1.A1_FILIAL = '  '"
			cQuery += " AND SA1.A1_COD  = SF2.F2_CLIENTE"
			cQuery += " AND SA1.A1_LOJA = SF2.F2_LOJA"
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define filtro por Marca                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SUO->UO_MARCA == "2" // Amarracao Campanhas x Marcas
			cQuery += " AND ZZ3.ZZ3_FILIAL = '  '"
			cQuery += " AND ZZ3.ZZ3_CODCAM = '"+SUO->UO_CODCAMP+"'"
			cQuery += " AND ZZ3.ZZ3_MARCA = SB1.B1_MARCA"
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define filtro por Grupo                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SUO->UO_GRUPO == "2" // Amarracao Campanhas x Grupo
			cQuery += " AND ZZ4.ZZ4_FILIAL = '  '"
			cQuery += " AND ZZ4.ZZ4_CODCAM = '"+SUO->UO_CODCAMP+"'"
			cQuery += " AND ZZ4.ZZ4_GRUPO = SB1.B1_GRUPO"
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define filtro por SubGrupo1                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SUO->UO_SUBGR1 == "2" // Amarracao Campanhas x SubGrupo1
			cQuery += " AND ZZ5.ZZ5_FILIAL = '  '"
			cQuery += " AND ZZ5.ZZ5_CODCAM = '"+SUO->UO_CODCAMP+"'"
			cQuery += " AND ZZ5.ZZ5_SUBGR1 = SB1.B1_SGRB1"
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define filtro por SubGrupo2                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SUO->UO_SUBGR2 == "2" // Amarracao Campanhas x SubGrupo2
			cQuery += " AND ZZ6.ZZ6_FILIAL = '  '"
			cQuery += " AND ZZ6.ZZ6_CODCAM = '"+SUO->UO_CODCAMP+"'"
			cQuery += " AND ZZ6.ZZ6_SUBGR2 = SB1.B1_SGRB2"
		Endif		
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define filtro por SubGrupo3                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SUO->UO_SUBGR3 == "2" // Amarracao Campanhas x SubGrupo3
			cQuery += " AND ZZ7.ZZ7_FILIAL = '  '"
			cQuery += " AND ZZ7.ZZ7_CODCAM = '"+SUO->UO_CODCAMP+"'"
			cQuery += " AND ZZ7.ZZ7_SUBGR3 = SB1.B1_SGRB3"
		Endif			
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define filtro por Produtos                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SUO->UO_PRODUTO == "2" // Amarracao Campanhas x Produtos
			cQuery += " AND ZZ8.ZZ8_FILIAL = '  '"
			cQuery += " AND ZZ8.ZZ8_CODCAM = '"+SUO->UO_CODCAMP+"'"
			cQuery += " AND ZZ8.ZZ8_PRODUT = SD2.D2_COD"
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define filtro por Vendedores                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SUO->UO_VEND == "2" // Amarracao Campanhas x Vendedores
			cQuery += " AND ZZA.ZZA_FILIAL = '  '"
			cQuery += " AND ZZA.ZZA_CODCAM = '"+SUO->UO_CODCAMP+"'"
			cQuery += " AND ZZA.ZZA_VEND = SF2.F2_VEND"+str(nI,1)
			cQuery += " AND ZZA.ZZA_NIVEL = '"+str(nI,1)+"'"
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define filtro por Area Geografica                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If VAL(SUO->UO_AREAS) > 1		// Amarracao Campanhas x Areas Geograficas
			cQuery += " AND ZZB.ZZB_FILIAL = '  '"
			cQuery += " AND ZZB.ZZB_CODCAM = '"+SUO->UO_CODCAMP+"'"
			If SUO->UO_AREAS == "2"			// Cidades    
				cQuery += " AND ZZB.ZZB_AREA = SA1.A1_CODCID"
			Elseif SUO->UO_AREAS == "3"		// Micro-regiao
				cQuery += " AND ZZB.ZZB_AREA = SA1.A1_MICRORE"			
			Elseif SUO->UO_AREAS == "4"		// Meso-regiao          
				cQuery += " AND ZZB.ZZB_AREA = SA1.A1_MESORG"
			Elseif SUO->UO_AREAS == "5"		// Estados
				cQuery += " AND SUBSTR(ZZB.ZZB_AREA,1,2) = SA1.A1_EST"
			Elseif SUO->UO_AREAS == "6"		// Regioes     
				cQuery += " AND ZZB.ZZB_AREA = SA1.A1_REGIAO"			
			Endif			
		Endif		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define filtro por Codigo de Atividade do Cliente             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SUO->UO_ATIVIDA == "2" // Amarracao Campanhas x Codigo de Atividade
			cQuery += " AND ZZC.ZZC_FILIAL = '  '"
			cQuery += " AND ZZC.ZZC_CODCAM = '"+SUO->UO_CODCAMP+"'"
			cQuery += " AND ZZC.ZZC_ATIVID = SA1.A1_ATIVIDA"
		Endif					
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define filtro por Segmento 1 do Cliente 		             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SUO->UO_SATIV1 == "2" // Amarracao Campanhas x Segmento 1
			cQuery += " AND ZZD.ZZD_FILIAL = '  '"
			cQuery += " AND ZZD.ZZD_CODCAM = '"+SUO->UO_CODCAMP+"'"
			cQuery += " AND ZZD.ZZD_SATIV1 = SA1.A1_SATIV1"
		Endif							
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define filtro por Segmento 2 do Cliente 		             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SUO->UO_SATIV2 == "2" // Amarracao Campanhas x Segmento 2
			cQuery += " AND ZZE.ZZE_FILIAL = '  '"
			cQuery += " AND ZZE.ZZE_CODCAM = '"+SUO->UO_CODCAMP+"'"
			cQuery += " AND ZZE.ZZE_SATIV2 = SA1.A1_SATIV2"
		Endif							
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define filtro por Codigo/Loja do Cliente		             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SUO->UO_CLIENTE == "2" // Amarracao Campanhas x Cliente
			cQuery += " AND ZZF.ZZF_FILIAL = '  '"
			cQuery += " AND ZZF.ZZF_CODCAM = '"+SUO->UO_CODCAMP+"'"
			cQuery += " AND ZZF.ZZF_CLIENT = SD2.D2_CLIENTE"
			cQuery += " AND ZZF.ZZF_LOJA   = SD2.D2_LOJA"
		Endif									
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define filtro por Filiais               		             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SUO->UO_FILIAIS == "2" // Amarracao Campanhas x Filiais
			cQuery += " AND SF2.F2_FILCLI IN ( " + cFilFiltro + " ) "		
		Endif		

		// Filtros especificos
		cQuery += " AND SD2.D2_TIPO NOT IN ( 'B', 'D' )"
		cQuery += " AND SD2.D2_ORIGLAN <> 'LF'"
		cQuery += " AND SF4.F4_DUPLIC = 'S'"
		cQuery += " AND SF4.F4_ESTOQUE = 'S'"

		// Filtrando registros deletados
		cQuery += " AND SD2.D_E_L_E_T_ = ' '" 
		cQuery += " AND SF2.D_E_L_E_T_ = ' '"		
		cQuery += " AND SF4.D_E_L_E_T_  = ' '"
		If SUO->UO_TPMETA == "2" .or. SUO->UO_MARCA == "2" .or. SUO->UO_GRUPO == "2" .or. SUO->UO_SUBGR1 == "2" .or. SUO->UO_SUBGR2 == "2" .or. SUO->UO_SUBGR3 == "2"
			cQuery += " AND SB1.D_E_L_E_T_  = ' '"	
		Endif
		If Val(SUO->UO_AREAS) > 1 .or. SUO->UO_ATIVIDA == "2" .or. SUO->UO_SATIV1 == "2" .or. SUO->UO_SATIV2 == "2"
			cQuery += " AND SA1.D_E_L_E_T_  = ' '"			
		Endif
		cQuery += IIF(SUO->UO_MARCA == "2"  , " AND ZZ3.D_E_L_E_T_  = ' '" , "")	// Amarracao Campanhas x Marcas
		cQuery += IIF(SUO->UO_GRUPO == "2"  , " AND ZZ4.D_E_L_E_T_  = ' '" , "")	// Amarracao Campanhas x Grupos
		cQuery += IIF(SUO->UO_SUBGR1 == "2" , " AND ZZ5.D_E_L_E_T_  = ' '" , "")	// Amarracao Campanhas x SubGrupo1
		cQuery += IIF(SUO->UO_SUBGR2 == "2" , " AND ZZ6.D_E_L_E_T_  = ' '" , "")	// Amarracao Campanhas x SubGrupo2
		cQuery += IIF(SUO->UO_SUBGR3 == "2" , " AND ZZ7.D_E_L_E_T_  = ' '" , "")	// Amarracao Campanhas x SubGrupo3
		cQuery += IIF(SUO->UO_PRODUTO == "2" , " AND ZZ8.D_E_L_E_T_  = ' '" , "")	// Amarracao Campanhas x Produtos
		cQuery += IIF(SUO->UO_VEND == "2" , " AND ZZA.D_E_L_E_T_  = ' '" , "")		// Amarracao Campanhas x Vendedores
		cQuery += IIF(VAL(SUO->UO_AREAS) > 1 , " AND ZZB.D_E_L_E_T_  = ' '" , "")	// Amarracao Campanhas x Areas Geograficas
		cQuery += IIF(SUO->UO_ATIVIDA == "2" , " AND ZZC.D_E_L_E_T_  = ' '" , "")	// Amarracao Campanhas x Codigos de Atividade
		cQuery += IIF(SUO->UO_SATIV1 == "2" , " AND ZZD.D_E_L_E_T_  = ' '" , "")	// Amarracao Campanhas x Segmento 1
		cQuery += IIF(SUO->UO_SATIV2 == "2" , " AND ZZE.D_E_L_E_T_  = ' '" , "")	// Amarracao Campanhas x Segmento 2
		cQuery += IIF(SUO->UO_CLIENTE == "2" , " AND ZZF.D_E_L_E_T_  = ' '" , "")	// Amarracao Campanhas x Clientes

		If SUO->UO_TPMETA != "2"	// Valores faturados, aglutina por Filial+Vendedor
			cQuery += " GROUP BY SF2.F2_FILCLI, SF2.F2_VEND"+str(nI,1)+", SUBSTR(SD2.D2_EMISSAO,1,6) "
		Else				// Quantidade, aglutina por Filial+Vendedor+Produto
			cQuery += " GROUP BY SF2.F2_FILCLI, SF2.F2_VEND"+str(nI,1)+", SD2.D2_COD, SUBSTR(SD2.D2_EMISSAO,1,6) "
		Endif

		If mv_par06 == 1	// considera devolucoes
			cQuery += "UNION ALL SELECT SF2.F2_FILCLI FILCLI, SF2.F2_VEND"+str(nI,1)+" VENDEDOR, "
			If SUO->UO_TPMETA == "2"	// Quando for quantidade, abre a meta por produtos
				cQuery += "SD1.D1_COD PRODUTO, "
			Endif
			cQuery += "SUBSTR(SD1.D1_DTDIGIT,1,6) ANO_MES, "
			cQuery += IIF( SUO->UO_TPMETA == "2" , "SUM(SD1.D1_QUANT * -1) QUANT " , "SUM(SD1.D1_TOTAL * -1) VALOR " )
		
			cQuery += " FROM "+RetSqlName("SD1")+" SD1, " + RetSqlName("SF2")+" SF2, " + RetSqlName("SF4")+" SF4 "
		
			// Verifica se eh necessario utilizar o arquivo SB1
			If SUO->UO_TPMETA == "2" .or. SUO->UO_MARCA == "2" .or. SUO->UO_GRUPO == "2" .or. SUO->UO_SUBGR1 == "2" .or. SUO->UO_SUBGR2 == "2" .or. SUO->UO_SUBGR3 == "2"
				cQuery += ", " + RetSqlName("SB1")+" SB1"
			Endif
		
			// Verifica se eh necessario utilizar o arquivo SA1
			If Val(SUO->UO_AREAS) > 1 .or. SUO->UO_ATIVIDA == "2" .or. SUO->UO_SATIV1 == "2" .or. SUO->UO_SATIV2 == "2"
				cQuery += ", " + RetSqlName("SA1")+" SA1"
			Endif

			cQuery += IIF(SUO->UO_MARCA == "2" , ", "+RetSqlName("ZZ3")+" ZZ3" , "")	// Amarracao Campanhas x Marcas
			cQuery += IIF(SUO->UO_GRUPO == "2" , ", "+RetSqlName("ZZ4")+" ZZ4" , "")	// Amarracao Campanhas x Grupos
			cQuery += IIF(SUO->UO_SUBGR1 == "2" , ", "+RetSqlName("ZZ5")+" ZZ5" , "")	// Amarracao Campanhas x SubGrupo1
			cQuery += IIF(SUO->UO_SUBGR2 == "2" , ", "+RetSqlName("ZZ6")+" ZZ6" , "")	// Amarracao Campanhas x SubGrupo2
			cQuery += IIF(SUO->UO_SUBGR3 == "2" , ", "+RetSqlName("ZZ7")+" ZZ7" , "")	// Amarracao Campanhas x SubGrupo3
			cQuery += IIF(SUO->UO_PRODUTO == "2" , ", "+RetSqlName("ZZ8")+" ZZ8" , "")	// Amarracao Campanhas x Produtos
			cQuery += IIF(SUO->UO_VEND == "2" , ", "+RetSqlName("ZZA")+" ZZA" , "")		// Amarracao Campanhas x Vendedores
			cQuery += IIF(VAL(SUO->UO_AREAS) > 1 , ", "+RetSqlName("ZZB")+" ZZB" , "")	// Amarracao Campanhas x Areas Geograficas
			cQuery += IIF(SUO->UO_ATIVIDA == "2" , ", "+RetSqlName("ZZC")+" ZZC" , "")	// Amarracao Campanhas x Codigos de Atividade
			cQuery += IIF(SUO->UO_SATIV1 == "2" , ", "+RetSqlName("ZZD")+" ZZD" , "")	// Amarracao Campanhas x Segmento 1
			cQuery += IIF(SUO->UO_SATIV2 == "2" , ", "+RetSqlName("ZZE")+" ZZE" , "")	// Amarracao Campanhas x Segmento 2
			cQuery += IIF(SUO->UO_CLIENTE == "2" , ", "+RetSqlName("ZZF")+" ZZF" , "")	// Amarracao Campanhas x Clientes

			cQuery += " WHERE SD1.D1_FILIAL IN ( " + cFiliais + " )"

			// Filtro por Periodo 
			cQuery += " AND SD1.D1_DTDIGIT BETWEEN '" + DTOS(dDataIni) + "' AND '" + DTOS(dDataFim) + "'"
	
			// Relacionamentos
			// SF2                         
			cQuery += " AND	SF2.F2_FILIAL  = SD1.D1_FILIAL"
			cQuery += " AND	SF2.F2_DOC     = SD1.D1_NFORI"
			cQuery += " AND	SF2.F2_SERIE   = SD1.D1_SERIORI"
			cQuery += " AND	SF2.F2_CLIENTE = SD1.D1_FORNECE"
			cQuery += " AND	SF2.F2_LOJA    = SD1.D1_LOJA"
			
			// SF4
			cQuery += " AND SF4.F4_FILIAL = SD1.D1_FILIAL"
			cQuery += " AND SF4.F4_CODIGO = SD1.D1_TES"			
	
			// SB1
			If SUO->UO_TPMETA == "2" .or. SUO->UO_MARCA == "2" .or. SUO->UO_GRUPO == "2" .or. SUO->UO_SUBGR1 == "2" .or. SUO->UO_SUBGR2 == "2" .or. SUO->UO_SUBGR3 == "2"
				cQuery += " AND SB1.B1_FILIAL = SD1.D1_FILIAL"
				cQuery += " AND SB1.B1_COD = SD1.D1_COD"	
			Endif	

			// SA1
			If Val(SUO->UO_AREAS) > 1 .or. SUO->UO_ATIVIDA == "2" .or. SUO->UO_SATIV1 == "2" .or. SUO->UO_SATIV2 == "2"
				cQuery += " AND SA1.A1_FILIAL = '  ' "
				cQuery += " AND SA1.A1_COD  = SD1.D1_FORNECE"
				cQuery += " AND SA1.A1_LOJA = SD1.D1_LOJA"
			Endif
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define filtro por Marca                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SUO->UO_MARCA == "2" // Amarracao Campanhas x Marcas
				cQuery += " AND ZZ3.ZZ3_FILIAL = '  '"
				cQuery += " AND ZZ3.ZZ3_CODCAM = '"+SUO->UO_CODCAMP+"'"
				cQuery += " AND ZZ3.ZZ3_MARCA = SB1.B1_MARCA"
			Endif
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define filtro por Grupo                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SUO->UO_GRUPO == "2" // Amarracao Campanhas x Grupo
				cQuery += " AND ZZ4.ZZ4_FILIAL = '  '"
				cQuery += " AND ZZ4.ZZ4_CODCAM = '"+SUO->UO_CODCAMP+"'"
				cQuery += " AND ZZ4.ZZ4_GRUPO = SB1.B1_GRUPO"
			Endif
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define filtro por SubGrupo1                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SUO->UO_SUBGR1 == "2" // Amarracao Campanhas x SubGrupo1
				cQuery += " AND ZZ5.ZZ5_FILIAL = '  '"
				cQuery += " AND ZZ5.ZZ5_CODCAM = '"+SUO->UO_CODCAMP+"'"
				cQuery += " AND ZZ5.ZZ5_SUBGR1 = SB1.B1_SGRB1"
			Endif
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define filtro por SubGrupo2                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SUO->UO_SUBGR2 == "2" // Amarracao Campanhas x SubGrupo2
				cQuery += " AND ZZ6.ZZ6_FILIAL = '  '"
				cQuery += " AND ZZ6.ZZ6_CODCAM = '"+SUO->UO_CODCAMP+"'"
				cQuery += " AND ZZ6.ZZ6_SUBGR2 = SB1.B1_SGRB2"
			Endif		
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define filtro por SubGrupo3                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SUO->UO_SUBGR3 == "2" // Amarracao Campanhas x SubGrupo3
				cQuery += " AND ZZ7.ZZ7_FILIAL = '  '"
				cQuery += " AND ZZ7.ZZ7_CODCAM = '"+SUO->UO_CODCAMP+"'"
				cQuery += " AND ZZ7.ZZ7_SUBGR3 = SB1.B1_SGRB3"
			Endif			
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define filtro por Produtos                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SUO->UO_PRODUTO == "2" // Amarracao Campanhas x Produtos
				cQuery += " AND ZZ8.ZZ8_FILIAL = '  '"
				cQuery += " AND ZZ8.ZZ8_CODCAM = '"+SUO->UO_CODCAMP+"'"
				cQuery += " AND ZZ8.ZZ8_PRODUT = SD1.D1_COD"
			Endif
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define filtro por Vendedores                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SUO->UO_VEND == "2" // Amarracao Campanhas x Vendedores
				cQuery += " AND ZZA.ZZA_FILIAL = '  '"
				cQuery += " AND ZZA.ZZA_CODCAM = '"+SUO->UO_CODCAMP+"'"
				cQuery += " AND ZZA.ZZA_VEND = SF2.F2_VEND"+str(nI,1)
				cQuery += " AND ZZA.ZZA_NIVEL = '"+str(nI,1)+"'"
			Endif
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define filtro por Area Geografica                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If VAL(SUO->UO_AREAS) > 1		// Amarracao Campanhas x Areas Geograficas
				cQuery += " AND ZZB.ZZB_FILIAL = '  '"
				cQuery += " AND ZZB.ZZB_CODCAM = '"+SUO->UO_CODCAMP+"'"
				If SUO->UO_AREAS == "2"			// Cidades    
					cQuery += " AND ZZB.ZZB_AREA = SA1.A1_CODCID"
				Elseif SUO->UO_AREAS == "3"		// Micro-regiao
					cQuery += " AND ZZB.ZZB_AREA = SA1.A1_MICRORE"			
				Elseif SUO->UO_AREAS == "4"		// Meso-regiao          
					cQuery += " AND ZZB.ZZB_AREA = SA1.A1_MESORG"
				Elseif SUO->UO_AREAS == "5"		// Estados
					cQuery += " AND SUBSTR(ZZB.ZZB_AREA,1,2) = SA1.A1_EST"
				Elseif SUO->UO_AREAS == "6"		// Regioes     
					cQuery += " AND ZZB.ZZB_AREA = SA1.A1_REGIAO"			
				Endif			
			Endif		
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define filtro por Codigo de Atividade do Cliente             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SUO->UO_ATIVIDA == "2" // Amarracao Campanhas x Codigo de Atividade
				cQuery += " AND ZZC.ZZC_FILIAL = '  '"
				cQuery += " AND ZZC.ZZC_CODCAM = '"+SUO->UO_CODCAMP+"'"
				cQuery += " AND ZZC.ZZC_ATIVID = SA1.A1_ATIVIDA"
			Endif					
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define filtro por Segmento 1 do Cliente 		             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SUO->UO_SATIV1 == "2" // Amarracao Campanhas x Segmento 1
				cQuery += " AND ZZD.ZZD_FILIAL = '  '"
				cQuery += " AND ZZD.ZZD_CODCAM = '"+SUO->UO_CODCAMP+"'"
				cQuery += " AND ZZD.ZZD_SATIV1 = SA1.A1_SATIV1"
			Endif							
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define filtro por Segmento 2 do Cliente 		             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SUO->UO_SATIV2 == "2" // Amarracao Campanhas x Segmento 2
				cQuery += " AND ZZE.ZZE_FILIAL = '  '"
				cQuery += " AND ZZE.ZZE_CODCAM = '"+SUO->UO_CODCAMP+"'"
				cQuery += " AND ZZE.ZZE_SATIV2 = SA1.A1_SATIV2"
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define filtro por Codigo/Loja do Cliente                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SUO->UO_CLIENTES == "2" // Amarracao Campanhas x Clientes
				cQuery += " AND ZZF.ZZF_FILIAL = '  '"
				cQuery += " AND ZZF.ZZF_CODCAM = '"+SUO->UO_CODCAMP+"'"
				cQuery += " AND ZZF.ZZF_CLIENT = SD1.D1_FORNECE "
				cQuery += " AND ZZF.ZZF_LOJA   = SD1.D1_LOJA "
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define filtro por Filiais               		             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SUO->UO_FILIAIS == "2" // Amarracao Campanhas x Filiais
				cQuery += " AND SF2.F2_FILCLI IN ( " + cFilFiltro + " ) "
			Endif					
		
			// Filtros especificos	
			cQuery += " AND	SD1.D1_TIPO = 'D' "
			cQuery += " AND SD1.D1_ORIGLAN <> 'LF' "
			cQuery += " AND	SF4.F4_DUPLIC  = 'S' "  		
			cQuery += " AND SF4.F4_ESTOQUE = 'S'"			
			
			// Filtrando registros deletados
			cQuery += " AND SD1.D_E_L_E_T_ = ' '" 
			cQuery += " AND SF2.D_E_L_E_T_  = ' '"		
			cQuery += " AND SF4.D_E_L_E_T_  = ' '"
			If SUO->UO_TPMETA == "2" .or. SUO->UO_MARCA == "2" .or. SUO->UO_GRUPO == "2" .or. SUO->UO_SUBGR1 == "2" .or. SUO->UO_SUBGR2 == "2" .or. SUO->UO_SUBGR3 == "2"
				cQuery += " AND SB1.D_E_L_E_T_  = ' '"	
			Endif
			If Val(SUO->UO_AREAS) > 1 .or. SUO->UO_ATIVIDA == "2" .or. SUO->UO_SATIV1 == "2" .or. SUO->UO_SATIV2 == "2"
				cQuery += " AND SA1.D_E_L_E_T_  = ' '"			
			Endif
			cQuery += IIF(SUO->UO_MARCA == "2"  , " AND ZZ3.D_E_L_E_T_  = ' '" , "")	// Amarracao Campanhas x Marcas
			cQuery += IIF(SUO->UO_GRUPO == "2"  , " AND ZZ4.D_E_L_E_T_  = ' '" , "")	// Amarracao Campanhas x Grupos
			cQuery += IIF(SUO->UO_SUBGR1 == "2" , " AND ZZ5.D_E_L_E_T_  = ' '" , "")	// Amarracao Campanhas x SubGrupo1
			cQuery += IIF(SUO->UO_SUBGR2 == "2" , " AND ZZ6.D_E_L_E_T_  = ' '" , "")	// Amarracao Campanhas x SubGrupo2
			cQuery += IIF(SUO->UO_SUBGR3 == "2" , " AND ZZ7.D_E_L_E_T_  = ' '" , "")	// Amarracao Campanhas x SubGrupo3
			cQuery += IIF(SUO->UO_PRODUTO == "2" , " AND ZZ8.D_E_L_E_T_  = ' '" , "")	// Amarracao Campanhas x Produtos
			cQuery += IIF(SUO->UO_VEND == "2" , " AND ZZA.D_E_L_E_T_  = ' '" , "") 		// Amarracao Campanhas x Vendedores
			cQuery += IIF(VAL(SUO->UO_AREAS) > 1 , " AND ZZB.D_E_L_E_T_  = ' '" , "")	// Amarracao Campanhas x Areas Geograficas
			cQuery += IIF(SUO->UO_ATIVIDA == "2" , " AND ZZC.D_E_L_E_T_  = ' '" , "")	// Amarracao Campanhas x Codigos de Atividade
			cQuery += IIF(SUO->UO_SATIV1 == "2" , " AND ZZD.D_E_L_E_T_  = ' '" , "")	// Amarracao Campanhas x Segmento 1
			cQuery += IIF(SUO->UO_SATIV2 == "2" , " AND ZZE.D_E_L_E_T_  = ' '" , "")	// Amarracao Campanhas x Segmento 2
			cQuery += IIF(SUO->UO_SATIV2 == "2" , " AND ZZF.D_E_L_E_T_  = ' '" , "")	// Amarracao Campanhas x Clientes

			If SUO->UO_TPMETA != "2"	// Valores faturados, aglutina por Filial+Vendedor
				cQuery += " GROUP BY SF2.F2_FILCLI, SF2.F2_VEND"+str(nI,1)+", SUBSTR(SD1.D1_DTDIGIT,1,6) "
			Else				// Quantidade, aglutina por Filial+Vendedor+Produto
				cQuery += " GROUP BY SF2.F2_FILCLI, SF2.F2_VEND"+str(nI,1)+", SD1.D1_COD, SUBSTR(SD1.D1_DTDIGIT,1,6) "
			Endif        
		
		Endif 
		
		cQuery += ") HIST "
		
		// relacionamento com HIST
//		cQuery += " WHERE HIST.FILCLI (+) = VENDPROD.FILVEND "
		cQuery += " WHERE HIST.VENDEDOR (+) = VENDPROD.VEND "		
		If SUO->UO_TPMETA != "2"	// Valores faturados, aglutina por Filial+Vendedor
			cQuery += " GROUP BY VENDPROD.FILVEND, VENDPROD.VEND, VENDPROD.NOMEVEN, HIST.ANO_MES "
			cQuery += " ORDER BY VENDPROD.FILVEND, VENDPROD.VEND, HIST.ANO_MES "
		Else						// Quantidade, aglutina por Filial+Vendedor+Produto
			cQuery += " AND HIST.PRODUTO (+) = VENDPROD.PRODUTO "
			
			cQuery += " GROUP BY VENDPROD.FILVEND, VENDPROD.VEND, VENDPROD.NOMEVEN, VENDPROD.PRODUTO, VENDPROD.DESCPRO, HIST.ANO_MES "
			cQuery += " ORDER BY VENDPROD.FILVEND, VENDPROD.VEND, VENDPROD.PRODUTO, HIST.ANO_MES "
		Endif	
		
		// Executa a query
		MEMOWRIT( FunName(1)+".SQL", cQuery ) 
		TCQUERY cQuery NEW ALIAS "TRB"
		Incproc()
		If Alias() == "TRB"
			lOk := .T.
			aStru := DbStruct()
			For nJ := 1 To Len( aStru )
			   If aStru[nJ,2] != "C"
				   TCSetField( "TRB", aStru[nJ,1], aStru[nJ,2], aStru[nJ,3], aStru[nJ,4] )
			   EndIf
			Next  
            
			// Grava os registros
			dbSelectArea("TRB")
			cFilTmp    := TRB->FILVEND
			cNomFilTmp := NomeFil(aFiliais,cFilTmp)
			Do While !Eof()
			             
				dbSelectArea("CAM")
				Reclock("CAM",.T.)
					CAM->FILIAL   := cNomFilTmp
					CAM->VENDEDOR := TRB->VENDEDOR
					CAM->NOME     := TRB->NOMEVEN
					CAM->TIPO     := aTpVends[nI]
					If SUO->UO_TPMETA == "2"
						CAM->PRODUTO   := TRB->PRODUTO
						CAM->DESCRICAO := TRB->DESCPRO
					Endif
				MsUnlock()			
			                          
				// agrupa por filial+vendedor ou filial+vendedor+produto
				dbSelectArea("TRB")				
				cChave := Eval(bChave)
				Do While Eval(bChave) == cChave .and. !Eof()
				
					If !Empty(TRB->ANO_MES)
						// Define nome do campo referente ao mes a ser gravado
						cMacro := aMeses[ Val( Right(TRB->ANO_MES,2) ) ] + Left(TRB->ANO_MES,4)				
								
						dbSelectArea("CAM")
						Reclock("CAM",.F.)
							If SUO->UO_TPMETA == "2"
								CAM->&(cMacro) := TRB->QUANT
							Else
								CAM->&(cMacro) := IIF(SUO->UO_MOEDA==1,TRB->VALOR,xMoeda(TRB->VALOR,1,SUO->UO_MOEDA,dDataBase,2))
							Endif
						MsUnlock()
					Endif	
					
	        	    dbSelectArea("TRB")
    	        	dbSkip()
    	            
    	        Enddo
    	        
    			// Atualiza o nome da filial quando mudar de filial
 	   	        If TRB->FILVEND != cFilTmp
					cFilTmp    := TRB->FILVEND
					cNomFilTmp := NomeFil(aFiliais,cFilTmp)
    	        Endif
                
     		Enddo
     		
     		dbSelectArea("TRB")
			dbCloseArea()
     		
		Else

			lOk := .F.
			Exit	

		EndIf	  
		
   		Incproc()		
        	
	Endif	
	
next

Return lOk


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³U_TPVENDS ³ Autor ³ Expedito Mendonca Jr  ³ Data ³ 09/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Selecionar quais tipos de vendedores serao considerados     ³±±
±±³          ³no processamento das Metas das Campanhas de Vendas.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ U_TPVENDS() 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ IMDA480  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
User Function TpVends()
Local cTitulo, MvPar, MvParDef, oWnd
Private aSit := {}

oWnd  := GetWndDefault()
MvPar := &(Alltrim(ReadVar()))	 // Carrega Nome da Variavel do Get em Questao
mvRet := Alltrim(ReadVar())		 // Iguala Nome da Variavel ao Nome variavel de Retorno

// Define as opcoes a serem selecionadas
aSit:={"Vendedores Internos","Vendedores Externos","Coordenadores","Chefes de Vendas","Gerentes de Vendas","Diretoria de Vendas"}
MvParDef:="IECHGD"
cTitulo :="Vendedores"

f_Opcoes(@MvPar,cTitulo,aSit,MvParDef,12,49,.F.)  // Chama funcao f_Opcoes
&MvRet := mvpar                                   // Devolve Resultado

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ NomeFil     ³ Autor ³Expedito Mendonca Jr³ Data ³ 30/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o nome da filial									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ NomeFil(ExpA1,ExpC1)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array de duas dimensoes contendo o codigo e o nome ³±±
±±³          ³ das filiais da empresa atual.                              ³±±
±±³          ³ ExpC1 = Codigo da filial  								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpC1 = Nome da Filial                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function NomeFil(aFiliais,cCodFil)
Local nPos := aScan(aFiliais, {|x| x[1] == cCodFil} )
Return IIF(nPos > 0, aFiliais[nPos,2], "")
