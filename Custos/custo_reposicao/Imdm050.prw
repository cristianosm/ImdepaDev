#INCLUDE "rwmake.ch"
#Define  CRLF    (chr(13)+chr(10))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMDM050   º Autor ³ Expedito Mendonca Jr º Data ³ 15/10/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Geracao de arquivo para ser utilizado no Excel para          º±±
±±º          ³ formacao de precos.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico para o cliente Imdepa.                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function IMDM050()
Local aDados  := {}
Local oDlg
Private cPerg := "IMM050"

// No caso da Imdepa, este rotina deve ser executada em Porto Alegre devido ao Custo de Reposicao (B1_CUSTD) que sera considerado
If cEmpAnt == "01" .and. cFilAnt != "12"
	MsgBox('Esta rotina deve ser executada na filial de Porto Alegre.','Atenção','ALERT')
	Return NIL
Endif

// Atualiza arquivo de parametros SX1
aAdd(aDados,{ "Tabela de Precos?" ,"Tabela de Precos?"   ,"Tabela de Precos?"  ,"mv_ch1","C",3 ,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","DA0","" })
aAdd(aDados,{ "Do Produto?"       ,"Do Produto?"         ,"Do Produto?"        ,"mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1","" })
aAdd(aDados,{ "Ate o Produto?"    ,"Ate o Produto?"      ,"Ate o Produto"      ,"mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1","" })
aAdd(aDados,{ "Da Marca?"         ,"Da Marca?"           ,"Da Marca?"          ,"mv_ch4","C",20,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"" })
aAdd(aDados,{ "Ate a Marca?"      ,"Ate a Marca?"        ,"Ate a Marca?"       ,"mv_ch5","C",20,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"" })
aAdd(aDados,{ "Da Referencia?"    ,"Da Referencia?"      ,"Da Referencia?"     ,"mv_ch6","C",20,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"" })
aAdd(aDados,{ "Ate a Referencia?" ,"Ate a Referencia?"   ,"Ate a Referencia?"  ,"mv_ch7","C",20,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"" })
aAdd(aDados,{ "Da Origem?"        ,"Da Origem?"          ,"Da Origem?"         ,"mv_ch8","C",1 ,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","S0 ","" })
aAdd(aDados,{ "Ate a Origem?"     ,"Ate a Origem?"       ,"Ate a Origem?"      ,"mv_ch9","C",1 ,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","S0 ","" })
aAdd(aDados,{ "Do Grupo?"         ,"Do Grupo?"           ,"Do Grupo?"          ,"mv_chA","C",4 ,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","SBM","" })
aAdd(aDados,{ "Ate o Grupo?"      ,"Ate o Grupo?"        ,"Ate o Grupo?"       ,"mv_chB","C",4 ,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","SBM","" })
aAdd(aDados,{ "Do SubGrupo 1?"    ,"Do SubGrupo 1?"      ,"Do SubGrupo 1?"     ,"mv_chC","C",6 ,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","SZA","" })
aAdd(aDados,{ "Ate o SubGrupo 1?" ,"Ate o SubGrupo 1?"   ,"Ate o SubGrupo 1?"  ,"mv_chD","C",6 ,0,0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","SZA","" })
aAdd(aDados,{ "Do SubGrupo 2?"    ,"Do SubGrupo 2?"      ,"Do SubGrupo 2?"     ,"mv_chE","C",6 ,0,0,"G","","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","","SZB","" })
aAdd(aDados,{ "Ate o SubGrupo 2?" ,"Ate o SubGrupo 2?"   ,"Ate o SubGrupo 2?"  ,"mv_chF","C",6 ,0,0,"G","","mv_par15","","","","","","","","","","","","","","","","","","","","","","","","","SZB","" })
aAdd(aDados,{ "Do SubGrupo 3?"    ,"Do SubGrupo 3?"      ,"Do SubGrupo 3?"     ,"mv_chG","C",6 ,0,0,"G","","mv_par16","","","","","","","","","","","","","","","","","","","","","","","","","SZC","" })
aAdd(aDados,{ "Ate o SubGrupo 3?" ,"Ate o SubGrupo 3?"   ,"Ate o SubGrupo 3?"  ,"mv_chH","C",6 ,0,0,"G","","mv_par17","","","","","","","","","","","","","","","","","","","","","","","","","SZC","" })
aAdd(aDados,{ "Do Fornecedor?"    ,"Do Fornecedor?"      ,"Do Fornecedor?"     ,"mv_chI","C",6 ,0,0,"G","","mv_par18","","","","","","","","","","","","","","","","","","","","","","","","","FOR","" })
aAdd(aDados,{ "Da Loja?"          ,"Da Loja?"            ,"Da Loja?"           ,"mv_chJ","C",2 ,0,0,"G","","mv_par19","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"" })
aAdd(aDados,{ "Ate o Fornecedor?" ,"Ate o Fornecedor?"   ,"Ate o Fornecedor?"  ,"mv_chK","C",6 ,0,0,"G","","mv_par20","","","","","","","","","","","","","","","","","","","","","","","","","FOR","" })
aAdd(aDados,{ "Ate a Loja?"       ,"Ate a Loja?"         ,"Ate a Loja?"        ,"mv_chL","C",2 ,0,0,"G","","mv_par21","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"" })
AjustaSx1( cPerg, aDados )
Pergunte(cPerg,.F.)

// Monta a tela para o processamento
@ 148,66 To 364,568 Dialog oDlg Title OemToAnsi("Formação de Preços - Excel")
@ 12,17 To 76,236 Title OemToAnsi("Objetivo")
@ 21,22 Say OemToAnsi("Esta rotina tem a funcao de gerar um arquivo com dados para formação de preços de venda a serem manuseados através do Microsoft Excel.") Size 208,48
@ 082,017 BmpButton Type 5 Action   Pergunte(cPerg,.T.)
@ 082,050 BmpButton Type 1 Action   MsAguarde({|| Executar()},OemToAnsi("Aguarde..."),OemToAnsi("Gerando planilha de formação de preços..."))
@ 082,083 BmpButton Type 2 Action  Close( oDlg )
Activate Dialog oDlg CENTER
Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Executar  º Autor ³ Expedito Mendonca Jr º Data ³ 15/10/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Executa o processamento de geracao de arquivo para           º±±
±±º          ³ formacao de precos.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico para o cliente Imdepa.                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Executar()
//Local nNumSeq, aPasta
Local aStruct, cArq, nI
Local cPathCompleto := Getmv("MV_DIRPFP")
Local cExecExcel := Getmv("MV_EXCEL")
Local cPathRoot := "\pfp\"
Local nPercDesp := Getmv("MV_DESPPFP")
Local nDecB1CUSTD := TamSx3("B1_CUSTD")[2]
Local nRec_SM0
Local cDescOrigem,cDescGrupo,cDesSubGr1,cDesSubGr2,cDesSubGr3,cDescForn, nDolar
Local aFiliais

// Define nome do arquivo
//nNumSeq := 1
//aPasta := Directory(cPathRoot+"*.xls")
//aSort(aPasta,,,{|x,y| x[1] > y[1] })
//for nI := 1 to Len(aPasta)
//	If Upper(Left(aPasta[nI,1],3)) == "PFP"
//		nNumSeq := Val(SubStr(aPasta[nI,1],4)) + 1
//		Exit
//	Endif
//next
//cArq := "pfp"+strzero(nNumSeq,5)+".xls"
cArq := "pfp_orig.xls"

// Define estrutura do arquivo
aStruct := { {"PRODUTO"    , "C" , 15 , 0 },;
{"REFERENCIA" , "C" , 20 , 0 },;
{"MARCA"      , "C" , 20 , 0 },;
{"DESCRICAO"  , "C" , 40 , 0 },;  //B1_DESC
{"CURVA"  , "C" , 4 , 0 },;       //B1_CURVA
{"TAB_FORNEC"  , "C" , 4 , 0 },; // Z6_FILIAL+Z6_CODPRO+Z6_CODTAB+Z6_ITEM
{"ORIGEM"     , "C" , 30 , 0 },;
{"GRUPO"      , "C" , 30 , 0 },;
{"SUBGR1"     , "C" , 20 , 0 },;
{"SUBGR2"     , "C" , 20 , 0 },;
{"SUBGR3"     , "C" , 20 , 0 },;
{"FORNECEDOR" , "C" , 30 , 0 },;
{"CUSTOMEDIO" , "N" , 14 , 4 },;
{"DESPESAS"   , "N" , 14 , 4 },;
{"PRECOBASE"  , "N" , 14 , 4 },;
{"CUSTOREPOS" , "N" , 14 , 4 },;
{"DESPESA_CR" , "N" , 14 , 4 },;
{"PRECBAS_CR" , "N" , 14 , 4 },;
{"ULTIMOCUST" , "N" , 14 , 4 },;
{"DESPESA_UC" , "N" , 14 , 4 },;
{"PRECBAS_UC" , "N" , 14 , 4 },;
{"QUALCUSTO"  , "C" , 1 ,  0 },;
{"MARKUP"     , "N" , 6 ,  4 },;
{"PRECOVENDA" , "N" , 14 , 4 },;
{"MOEDA"      , "N" , 2  , 0 },;
{"COT_DOLAR"  , "N" , 11 , 4 },;
{"MARKUPSIGA" , "N" , 6  , 4 } }

// Verifica se o arquivo ja existe e o apaga
If File(cPathRoot+cArq)
	fERASE(cPathRoot+cArq)
	If FERROR() != 0
		MsgBox("Erro ao excluir arquivo temporário anterior. Código do erro: "+Str(FERROR()),"Atenção","STOP")
		Return NIL
	Endif
Endif

// Cria o arquivo
dbCreate(cPathRoot+cArq,aStruct,"DBFCDXADS")
Use (cPathRoot+cArq) EXCLUSIVE NEW via "DBFCDXADS" alias "PFP"

// define as filiais da empresa
aFiliais := {}
dbSelectArea("SM0")
nRec_SM0 := RecNo()
dbSeek(cEmpAnt)
Do While SM0->M0_CODIGO == cEmpAnt .and. !Eof()
	aAdd(aFiliais,SM0->M0_CODFIL)
	dbSkip()
Enddo
SM0->(dbGoTo(nRec_SM0))

// Verifica o valor do dolar do dia
nDolar := RecMoeda(dDataBase,2)

// Inicia o processo de gravacao do arquivo
dbSelectArea("SB1")
dbSetOrder(1)
dbSelectArea("DA1")
dbSetOrder(1)
dbSeek(xFilial("DA1")+mv_par01+mv_par02,.T.)
Do While DA1->DA1_FILIAL+DA1->DA1_CODTAB+DA1->DA1_CODPRO <= xFilial("DA1")+mv_par01+mv_par03 .and. !Eof()
	dbSelectArea("SB1")
	dbSeek(xFilial("SB1")+DA1->DA1_CODPRO)
	If B1_MARCA >= MV_PAR04 .AND. B1_MARCA <= MV_PAR05 .AND. B1_REFER >= MV_PAR06 .AND. B1_REFER <= MV_PAR07 .AND. ;
		B1_ORIGEM >= MV_PAR08 .AND. B1_ORIGEM <= MV_PAR09 .AND. B1_GRUPO >= MV_PAR10 .AND. B1_GRUPO <= MV_PAR11 .AND. ;
		B1_SGRB1 >= MV_PAR12 .AND. B1_SGRB1 <= MV_PAR13 .AND. B1_SGRB2 >= MV_PAR14 .AND. B1_SGRB2 <= MV_PAR15 .AND. ;
		B1_SGRB3 >= MV_PAR16 .AND. B1_SGRB3 <= MV_PAR17 .AND. B1_PROC+B1_LOJPROC >= MV_PAR18+MV_PAR19 .AND. B1_PROC+B1_LOJPROC <= MV_PAR20+MV_PAR21
		
		// Define algumas variaveis para validacao e gravacao
		cDescOrigem := Tabela("S0",SB1->B1_ORIGEM,.F.)
		cDescGrupo  := Posicione("SBM",1,xFilial("SBM")+SB1->B1_GRUPO,"BM_DESC")
		cDesSubGr1  := Posicione("SZA",1,xFilial("SZA")+SB1->B1_SGRB1,"ZA_DESC")
		cDesSubGr2  := Posicione("SZB",1,xFilial("SZB")+SB1->B1_SGRB2,"ZB_DESC")
		cDesSubGr3  := Posicione("SZC",1,xFilial("SZC")+SB1->B1_SGRB3,"ZC_DESC")
		cDescForn   := Posicione("SA2",1,xFilial("SA2")+SB1->B1_PROC+SB1->B1_LOJPROC,"A2_NREDUZ")
		cCodTab     := Posicione("SZ6",2,xFilial("SZ6")+SB1->B1_COD,"Z6_CODTAB")
		
		If ";" $ DA1->DA1_CODPRO+SB1->B1_REFER+SB1->B1_MARCA+cDescOrigem+cDescGrupo+cDesSubGr1+cDesSubGr2+cDesSubGr3+cDescForn
			MsgBox("O produto "+DA1->DA1_CODPRO+" não será considerado porque possui um caracter inválido ( ; ) num dos seguintes campos: "+;
			"Código, Referência, Marca, Descrição da Origem, Descrição do Grupo, Descrição dos Subgrupos 1,2 e 3 ou Nome Reduzido do Fornecedor.","Atenção","ALERT")
		Else
			
			// Moeda do Custo de Reposicao
			nMCustD := Val(SB1->B1_MCUSTD)
			
			// Faz a gravacao do arquivo da planilha de formacao de precos
			dbSelectArea("PFP")
			While !Reclock("PFP",.T.)
			End
			PFP->PRODUTO	:= DA1->DA1_CODPRO
			PFP->REFERENCIA	:= SB1->B1_REFER
			PFP->MARCA		:= SB1->B1_MARCA
			PFP->DESCRICAO := Alltrim(SB1->B1_DESC)
			PFP->CURVA     :=SB1->B1_CURVA
			PFP->TAB_FORNEC:=cCodTab
			PFP->ORIGEM		:= cDescOrigem
			PFP->GRUPO		:= cDescGrupo
			PFP->SUBGR1		:= cDesSubGr1
			PFP->SUBGR2		:= cDesSubGr2
			PFP->SUBGR3		:= cDesSubGr3
			PFP->FORNECEDOR	:= cDescForn
			PFP->CUSTOMEDIO	:= u_CMPond(DA1->DA1_CODPRO,SB1->B1_ORIGEM,.F.,.F.)
			PFP->DESPESAS	:= (nPercDesp/100) * PFP->CUSTOMEDIO
			PFP->PRECOBASE	:= PFP->CUSTOMEDIO + PFP->DESPESAS
			PFP->CUSTOREPOS	:= IIF(nMCustD == 1 , SB1->B1_CUSTD , xMoeda(SB1->B1_CUSTD,nMCustD,1,dDataBase,nDecB1CUSTD))
			PFP->DESPESA_CR	:= (nPercDesp/100) * PFP->CUSTOREPOS
			PFP->PRECBAS_CR	:= PFP->CUSTOREPOS + PFP->DESPESA_CR
			PFP->ULTIMOCUST	:= u_UCMedio(DA1->DA1_CODPRO,SB1->B1_ORIGEM,aFiliais)
			PFP->DESPESA_UC	:= (nPercDesp/100) * PFP->ULTIMOCUST
			PFP->PRECBAS_UC	:= PFP->ULTIMOCUST + PFP->DESPESA_UC
			PFP->QUALCUSTO	:= DA1->DA1_TPCUST
			PFP->MARKUP		:= DA1->DA1_MKPIMD
			PFP->MOEDA		:= DA1->DA1_MOEDA
			PFP->COT_DOLAR	:= nDolar
			MsUnlock()
			
			// Faz a gravacao do arquivo da planilha de formacao de precos
			dbSelectArea("SB1")
			for nI := 1 to Len(aFiliais)
				If dbSeek(aFiliais[nI]+DA1->DA1_CODPRO)
					Reclock("SB1",.F.)
					SB1->B1_PRV1 := PFP->PRECOBASE
					SB1->B1_PBCR := PFP->PRECBAS_CR
					SB1->B1_PBUC := PFP->PRECBAS_UC
					MsUnlock()
				Endif
			next
			
		Endif
		
	Endif
	
	dbSelectArea("DA1")
	dbSkip()
Enddo

dbSelectArea("PFP")
dbCloseArea()
Winexec(cExecExcel+" "+cPathCompleto+cArq)
Return NIL


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ CMPond   º Autor ³ Expedito Mendonca Jr º Data ³ 16/10/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna o custo medio ponderado entre as filiais             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico para o cliente Imdepa.                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function CMPond(cProduto,cOrigem,lLocal,lM460Fim)
Local nQtdTot := 0, nValTot := 0, nCMPond := 0
Local nDecB2VAtu := TamSx3("B2_VATU1")[2]
Local bCusto    := IIF(cOrigem $ "12",{||SB2->B2_VATU2},{||SB2->B2_VATU1})
Local bCustoSD2 := IIF(cOrigem $ "12",{||SD2->D2_CUSTO2},{||SD2->D2_CUSTO1})
Local aAreaSD2, aAreaSF4, cComplChave

dbSelectArea("SB2")
If lLocal	// apenas da filial local no momento
	dbSetOrder(1)	// filial + produto + local
	dbSeek(cFilAnt+cProduto)
	Do While SB2->B2_FILIAL+SB2->B2_COD == cFilAnt+cProduto .and. !Eof()
		nQtdTot += SB2->B2_QATU
		nValTot += Eval(bCusto)
		dbSkip()
	Enddo
	
	// se for no momento da geracao da NF, ja houve a saida do estoque, mas tenho que considerar o custo antes tambem
	If lM460Fim
		
		// sf4
		dbSelectArea("SF4")
		aAreaSF4 := getarea()
		dbSetOrder(1)
		
		// sd2
		dbSelectArea("SD2")
		aAreaSD2 := getarea()
		dbSetOrder(3) 	// filial + doc + serie + cliente + loja + produto + item
		
		cComplChave := SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
		MsSeek(cFilAnt+cComplChave+cProduto)
		Do While SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_COD == cFilAnt+cComplChave+cProduto .and. !Eof()
			dbSelectArea("SF4")
			MsSeek(xFilial("SF4")+SD2->D2_TES)
			If SF4->F4_ESTOQUE == "S"
				nQtdTot += SD2->D2_QUANT
				nValTot += Eval(bCustoSD2)
			Endif
			dbSelectArea("SD2")
			dbSkip()
		Enddo
		
		// restaura o ambiente
		Restarea(aAreaSF4)
		Restarea(aAreaSD2)
		
	Endif
	
Else		// todas as filiais
	
	dbSetOrder(2)	// produto + local + filial
	dbSeek(cProduto)
	Do While SB2->B2_COD == cProduto .and. !Eof()
		nQtdTot += SB2->B2_QATU
		nValTot += Eval(bCusto)
		dbSkip()
	Enddo
	
Endif

If nQtdTot != 0
	nCMPond := nValTot / nQtdTot
	// Custo Medio em Dolar ou Reais de acordo com a origem do produto
	If cOrigem $ "12"
		nCMPond := xMoeda(nCMPond,2,1,dDataBase,nDecB2VAtu)
	Endif
Endif
Return nCMPond


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ UCMedio  º Autor ³ Expedito Mendonca Jr º Data ³ 16/10/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna o ultimo custo de entrada medio entre as filiais     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico para o cliente Imdepa.                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function UCMedio(cProduto,cOrigem,aFiliais)
Local nCustUnitEnt := 0
Local cDocFret,cSerieFret,cTransp,cLojTran
Local nCustMerc,nCustFret,nPercFret
Local nTotCustFil,nFilConsid,nUCMedio:=0
Local bCusto := IIF(cOrigem $ "12",{||SD1->D1_CUSTO2},{||SD1->D1_CUSTO})
Local nDiasUC := GetMV("MV_DIASUC")
Local nDecD1Custo := TamSx3("D1_CUSTO")[2]
Local nI

// posiciona indice do SF4 (TES)
dbSelectArea("SF4")
dbSetOrder(1)	// F4_FILIAL+F4_TES

// Custo total considerado e quantidade de filiais consideradas
nTotCustFil := 0
nFilConsid	:= 0

// faz o calculo entre as filiais
For nI := 1 to Len(aFiliais)
	
	// Ultimo custo de entrada desta filial
	nCustUnitEnt := 0
	
	dbSelectArea("SD1")
	dbOrderNickName("PRODDTHR")	//  especifico chave D1_FILIAL+D1_TIPO+D1_COD+DTOS(D1_DTDIGIT)+D1_HRDIGIT
	dbSeek(aFiliais[nI]+"N"+cProduto+"z",.T.)
	dbSkip(-1)
	Do While SD1->D1_FILIAL+SD1->D1_TIPO+SD1->D1_COD == aFiliais[nI]+"N"+cProduto .and. !Bof()
		
		dbSelectArea("SF4")
		If dbSeek(aFiliais[nI]+SD1->D1_TES,.F.)
			If SF4->F4_UPRC == "S"	.AND. SD1->D1_ORIGLAN <> 'LF' // atualiza preco de compra
				
				// Verifica se a ultima nota de entrada desta filial sera considerada ou nao
				If SD1->D1_DTDIGIT < (dDataBase-nDiasUC+1)
					Exit
				Endif
				
				// define o custo unitario de entrada do produto
				nCustUnitEnt := Eval(bCusto) / SD1->D1_QUANT
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula o custo do frete                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				// localizo a nota de conhecimento de frete correspondente a nota fiscal de entrada
				dbSelectArea("SF8")
				dbSetOrder(2)	// F8_FILIAL+F8_NFORIG+F8_SERORIG+F8_FORNECE+F8_LOJA
				If dbSeek(aFiliais[nI]+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA,.F.)
					
					// guardar dados da nota de conhecimento de frete
					cDocFret   := F8_NFDIFRE
					cSerieFret := F8_SEDIFRE
					cTransp    := F8_TRANSP
					cLojTran   := F8_LOJTRAN
					
					// custo total das mercadorias referentes a esta nota de conhecimento de frete
					nCustMerc := 0
					
					// verifico todas as notas fiscais de entrada correspondentes a nota de conhecimento de frete
					dbSelectArea("SF8")
					//dbOrderNickName("NFFRETE")	// F8_FILIAL+F8_NFDIFRE+F8_SEDIFRE+F8_TRANSP+F8_LOJTRAN
					DbSetOrder(3)	// F8_FILIAL+F8_NFDIFRE+F8_SEDIFRE+F8_TRANSP+F8_LOJTRAN
					dbSeek(aFiliais[nI]+cDocFret+cSerieFret+cTransp+cLojTran)
					Do While SF8->F8_FILIAL+SF8->F8_NFDIFRE+SF8->F8_SEDIFRE+SF8->F8_TRANSP+SF8->F8_LOJTRAN == aFiliais[nI]+cDocFret+cSerieFret+cTransp+cLojTran .and. !Eof()
						
						dbSelectArea("SD1")
						dbSetOrder(1)	//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
						dbSeek(aFiliais[nI]+SF8->F8_NFORIG+SF8->F8_SERORIG+SF8->F8_FORNECE+SF8->F8_LOJA)
						Do While SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == aFiliais[nI]+SF8->F8_NFORIG+SF8->F8_SERORIG+SF8->F8_FORNECE+SF8->F8_LOJA .and. !Eof()
							nCustMerc += Eval(bCusto)
							dbSkip()
						Enddo
						
						dbSelectArea("SF8")
						dbSkip()
					Enddo
					
					// custo total do frete referente a todas as notas fiscais de entrada relacionadas a ele
					nCustFret := 0
					
					dbSelectArea("SD1")
					dbSetOrder(1)	//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
					dbSeek(aFiliais[nI]+cDocFret+cSerieFret+cTransp+cLojTran)
					Do While SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == aFiliais[nI]+cDocFret+cSerieFret+cTransp+cLojTran .and. !Eof()
						nCustFret += Eval(bCusto)
						dbSkip()
					Enddo
					
					// calculo o percentual do custo total do frete sobre o custo total das mercadorias das notas fiscais de entrada
					nPercFret := (nCustFret / nCustMerc) + 1
					
					// aproprio o custo do frete no custo unitario do produto
					nCustUnitEnt := nPercFret * nCustUnitEnt
					
				Endif
				
				exit
			Endif
		Endif
		
		dbSelectArea("SD1")
		dbSkip(-1)
		
	Enddo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifico se considero este custo para fazer a media entre as filiais ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nCustUnitEnt != 0	// havia uma ultima nf de entrada e ela estava dentro do periodo considerado
		nTotCustFil += nCustUnitEnt
		nFilConsid ++
	Endif
	
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o ultimo custo de entrada medio entre as filiais              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nFilConsid != 0
	nUCMedio := nTotCustFil / nFilConsid
Else
	nUCMedio := 0
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for produto importado ou nacionalizado, converto o dolar para R$  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cOrigem $ "12"
	nUCMedio := xMoeda(nUCMedio,2,1,dDataBase,nDecD1Custo)
Endif

Return nUCMedio


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³U_PRCBASE º Autor ³ Expedito Mendonca Jr º Data ³ 20/10/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna o preco base de determinado produto                  º±±
±±º          ³ CUSTO + DESPESAS , baseado apenas na filial local            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico para o cliente Imdepa.                            º±±

±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlterações³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Márcio QB³ Modicicado para trab com o custo passado como parametro ou c/º±±
±±º          ³ o custo da tabela de preço DA1.                              º±±
±±º          ³ Custo de reposicaão considerado de B1_CUSTD para B1_CUSTRP   º±±
±±º          ³ e moeda de B1_MCUSTD para  B1_MCUSTRP    6/032006            º±±
±±º          ³                                                              º±±
±±º Márcio QB³ Retirado  mensagem de custo negativo quando a função for     º±±
±±º          ³ chamada especificando o custo como no caso da tela da verdadeº±±
±±º          ³ e no faturamento                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function PRCBASE(cProduto,cTabela,cTpCust,lM460Fim,cCustoEspec)
// cCustoEspec ---> Usado quando se quer calcular o preço base, baseado em um tipo de custo específico
//                       indiferente do que consta na Tabela de Preço
Local aArea    := Getarea()
Local aAreaDA1 := DA1->(Getarea())
Local aAreaSF4 := SF4->(Getarea())
Local aAreaSD1 := SD1->(Getarea())
Local aAreaSF8 := SF8->(Getarea())
Local aAreaSB1 := SB1->(Getarea())
Local aAreaSB2 := SB2->(Getarea())
Local nCusto, nDespesas, nPrcBase := 0, nMCustRP
Local nPercDesp := Getmv("MV_DESPPFP")
Local nDecB1CUSTD  := TamSx3("B1_CUSTD")[2] //Velho
Local nDecB1CUSTRP := TamSx3("B1_CUSTRP")[2] // (novo)
Local nDecCusto	:= 0
Local cCampoCusto := ""
Local cMoedaCusto := ""
Local nDecD2Custo := TamSx3("D2_CUSTO1")[2]
Local aFiliais := {cFilAnt}
Local lCustoEspec := cCustoEspec <> Nil .OR. !Empty(cCustoEspec) // .T. se por passado o campo de custo específico




// posiciona o cadastro de produtos
dbSelectArea("SB1")
dbSetOrder(1)
MsSeek(xFilial("SB1")+cProduto,.F.)

// posiciona a tabela de precos para saber o tipo de custo considerado
dbSelectArea("DA1")
dbSetOrder(1)
If !MsSeek(xFilial("DA1")+cTabela+cProduto,.F.)
//	u_Mensagem("O produto "+cProduto+" não está cadastrado na tabela de preços "+cTabela+". Para o calculo da rentabilidade, sera utilizado o custo de reposicao. Favor comunicar ao setor de custos da Imdepa.")
	cTpCust := "R"
Else
	// Determina o preco base do produto
	cTpCust := DA1->DA1_TPCUST
Endif

//  Caso se queira consultar um tipo específico de custo o mesmo terá de ser passado como parâmetro
// Tratamento da variável de custo, se CUSTO STANDARD OU REPOSICAO

If lCustoEspec   // Se for reposicao
	cCampoCusto := "SB1->B1_CUSTRP"
	cMoedaCusto := "SB1->B1_MCUSTRP"
	nDecCusto	:= nDecB1CUSTRP
	cTpCust 	:= cCustoEspec
Else			// Se NÃO for reposicao
	cCampoCusto := "SB1->B1_CUSTD"
	cMoedaCusto := "SB1->B1_MCUSTD"
	nDecCusto	:= nDecB1CUSTD
Endif

If cTpCust == "M"			// Custo Medio somente desta filial
	// Verifica se eh na geracao na NF
	nCusto := u_CMPond(cProduto,SB1->B1_ORIGEM,.T.,lM460Fim)
	
	// Valida o valor
	If nCusto <= 0
		If (Type("lTk271Auto") == "U" .Or. !lTk271Auto) .and. !lCustoEspec
		   	u_Mensagem('O custo medio do produto '+cProduto+' esta zerado ou negativo'+CRLF+'('+Transform(nPrcBase,'@E 9,999,999.9999')+'). Para o calculo da rentabilidade, sera utilizado o custo de reposicao. Favor comunicar ao setor de custos da Imdepa.')
		EndIf
		cTpCust := "R"
		// Moeda do Custo de Reposicao
		nMCustRP := Val(&cMoedaCusto.)
		nCusto := IIF(nMCustRP == 1 , &cCampoCusto. , xMoeda(&cCampoCusto.,nMCustRP,1,dDataBase,nDecCusto))
	Endif
Elseif cTpCust == "U"	// Ultimo custo de entrada somente desta filial
	nCusto := u_UCMedio(cProduto,SB1->B1_ORIGEM,aFiliais)
	If nCusto <= 0
		If (Type("lTk271Auto") == "U" .Or. !lTk271Auto) .and. !lCustoEspec
		   	u_Mensagem('O ultimo custo de entrada do produto '+cProduto+' esta zerado ou negativo'+CRLF+'('+Transform(nPrcBase,'@E 9,999,999.9999')+'). Para o calculo da rentabilidade, sera utilizado o custo de reposicao. Favor comunicar ao setor de custos da Imdepa.')
		EndIf
		cTpCust := "R"
		// Moeda do Custo de Reposicao
		nMCustRP := Val(&cMoedaCusto.)
		nCusto := IIF(nMCustRP == 1 , &cCampoCusto. , xMoeda(&cCampoCusto.,nMCustRP,1,dDataBase,nDecCusto))
	Endif
Else
	// Moeda do Custo de Reposicao
	cTpCust := "R"
	nMCustRP := Val((&cMoedaCusto.))
	nCusto := IIF(nMCustRP == 1 , &cCampoCusto. , xMoeda(&cCampoCusto.,nMCustRP,1,dDataBase,nDecCusto))  //		nCusto := IIF(nMCustD == 1 , SB1->B1_CUSTD , xMoeda(SB1->B1_CUSTD,nMCustD,1,dDataBase,nDecB1CUSTD))
Endif

// Da um alerta caso o custo de reposicao esteja zerado
If cTpCust == "R" .and. nCusto <= 0
	If (Type("lTk271Auto") == "U" .Or. !lTk271Auto) .and. !lCustoEspec
	  	u_Mensagem('O custo de reposicao do produto '+cProduto+' esta zerado ou negativo'+CRLF+'('+Transform(nPrcBase,'@E 9,999,999.9999')+'). Favor comunicar ao setor de custos da Imdepa.')
	EndIf
Endif

// Calcula as despesas
nDespesas := (nPercDesp/100)*nCusto

// Define o preco base
nPrcBase := nCusto + nDespesas

// Restaura o ambiente
Restarea(aAreaDA1)
Restarea(aAreaSF4)
Restarea(aAreaSD1)
Restarea(aAreaSF8)
Restarea(aAreaSB1)
Restarea(aAreaSB2)
Restarea(aArea)

Return nPrcBase
