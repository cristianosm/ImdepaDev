#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#Define  CR      chr(13)
#Define  CRLF    (chr(13)+chr(10))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ IMDA520  º Autor ³Expedito Mendonca Jrº Data ³  17/03/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Importacao de arquivo para preenchimento de metas de       º±±
±±º          ³ campanhas de vendas por vendedor.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico para o cliente Imdepa                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function IMDA520()
Local aDados  := {}
Local oDlg
Private cPerg := "IMDA52"


// Atualiza arquivo de parametros SX1
// aDados := { 1.PERGUNT,2.PERSPA,3.PERENG,4.VARIAVL,5.TIPO,6.TAMANHO,7.DECIMAL,8.PRESEL,9.GSC,10.VALID,11.VAR01,12.DEF01,13.DEFSPA1,14.DEFENG1,15.CNT01,16.VAR02,17.DEF02,18.DEFSPA2,19.DEFENG2,20.CNT2,
//             21.VAR03,22.DEF03,23.DEFSPA3,24.DEFENG3,25.CNT3,26.VAR04,27.DEF04,28.DEFSPA4,29.DEFENG4,30.CNT4,31.VAR05,32.DEF05,33.DEFSPA5,34.DEFENG5,35.CNT5,36.F3,37.PYME,38.GRPSXG}
aAdd(aDados,{ "Campanha?           ","Campanha?           ","Campanha?           ","mv_ch1","C", 6,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SUO","","" })
AjustaSx1( cPerg, aDados )

// Monta a tela para o processamento
DEFINE MSDIALOG oDlg TITLE OemToAnsi( "Atualização de Metas de Campanhas - Excel" ) FROM 148,66 TO 364,568 PIXEL
	@ 12,17 TO 76,236 LABEL OemtoAnsi("Objetivo") OF oDlg PIXEL
	@ 21,22 SAY OemToAnsi("Este programa tem por objetivo atualizar a meta de Campanhas de Vendas por vendedor, importando dados de um arquivo padrão .CSV gerado a partir do Microsoft Excel.") OF oDlg PIXEL Size 208,48

	DEFINE SBUTTON FROM 082,017 TYPE 1  ENABLE OF oDlg ACTION LeParametros()
	DEFINE SBUTTON FROM 082,050 TYPE 2  ENABLE OF oDlg ACTION ( oDlg:End() )
ACTIVATE DIALOG oDlg CENTER
Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³LeParametrº Autor ³Expedito Mendonca Jrº Data ³  17/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao chamada pelo botao OK na tela inicial de processamenº±±
±±º          ³ to. Le os parametros para o processamento.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico para o cliente Imdepa                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LeParametros()
Local cTipo := "Arquivos (*.csv) |*.csv|"
Local cPathArq, cDescCamp

// Abre a tela com as perguntas do processamento
If !Pergunte(cPerg,.T.)
	Return NIL
Endif

// Define descricao da campanha de vendas e posiciona a tabela de campanhas
cDescCamp := Posicione("SUO",1,xFilial("SUO")+mv_par01,"UO_DESC")
If SUO->(Eof())
	IW_MsgBox("Campanha "+mv_par01+" não cadastrada.","Atenção","ALERT")
	Return NIL
Endif

// Usuario seleciona o arquivo a ser processado
cPathArq := cGetFile( cTipo , "Selecione o arquivo *.CSV",,"SERVIDOR\cv\" )
If Empty(cPathArq)
	Return NIL
Endif

// Inicia o processamento
If MsgYesNo("Confirma atualização das metas da campanha "+alltrim(cDescCamp)+" a partir do arquivo "+cPathArq+"?","Metas de Campanhas - Excel")
	Processa( {||Executar(cPathArq)}, "Aguarde...","Atualizando metas de campanhas...")
Endif

Return NIL


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ Executar º Autor ³Expedito Mendonca Jrº Data ³  18/03/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Executa o processamento de atualizacao das metas de        º±±
±±º          ³ campanhas de vendas por vendedor                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico para o cliente Imdepa                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Executar(cPathArq)
Local nHdl, nTamFile, cBuffer, nBtLidos, cLinha, aLinha, nI, nLinCab
Local nNumSeq, aPasta, cArqLog, cLog, cErr, nHdlLog, bLinLog, cMsg
Local cPathRoot := "\cv\"
Local nProc, nNProc
Local nPosVend, nPosProd, nPosMeta
Local cVend, cProd, nMeta, lGrava, cNivelVend
//Local cVI, cVE, cCoor, cCHVE, cGEVE, cDIVE
Local cFiliais, nRecSM0
Private nBytesProc
Private TAM_BLOCO


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a posicao dos campos no arquivo texto                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SUO->UO_TPMETA == "2"	// quantidade
	nPosVend := 1
	nPosProd := 2
	nPosMeta := 3
	TAM_BLOCO := 35
Else						// valores
	nPosVend := 1
	nPosMeta := 2
	TAM_BLOCO := 20
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura do arquivo texto                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHdl := fOpen(cPathArq,0)
If FERROR() != 0
	IW_MsgBox("Erro ao abrir o arquivo. Código do erro: "+Str(FERROR()),"Atenção","STOP")
	Return NIL
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os parametros de nivel de vendedor                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//cVI		:= GETMV("MV_EISVI")
//cVE		:= GETMV("MV_EISVE")
//cCoor	:= GETMV("MV_EISCOOR")
//cCHVE	:= GETMV("MV_EISCHVE")
//cGEVE 	:= GETMV("MV_EISGEVE")
//cDIVE 	:= GETMV("MV_EISDIVE")

// define tamanho do arquivo
nTamFile := fSeek(nHdl,0,2)

// posiciona no inicio do arquivo texto
fSeek(nHdl,0,0)

// Variavel para leitura do bloco do arquivo texto
cBuffer  := Space(TAM_BLOCO)

// regua para processamento
ProcRegua(Int(nTamFile/TAM_BLOCO))
nBytesProc := 0

// Le a primeira linha do arquivo
LeLinha(nHdl,@cLinha,@cBuffer)
// Carrega a primeira linha do arquivo em um array
aLinha := U_ListAsArray(cLinha,";")
// Valida o arquivo (Q = Quantidades, V = Valores)
If !( (SUO->UO_TPMETA == "2" .and. aLinha[1] == "Q") .or. (SUO->UO_TPMETA != "2" .and. aLinha[1] == "V") )
	IW_MsgBox("Arquivo texto não corresponde ao tipo de meta definido na campanha de venda.","Atenção","ALERT")
	// Fecho o arquivo texto.
	fClose(nHdl)
	Return NIL
Endif

// Arquivo de log
nNumSeq := 1
aPasta := Directory(cPathRoot+"*.log")
aSort(aPasta,,,{|x,y| x[1] > y[1] })
for nI := 1 to Len(aPasta)
	If Upper(Left(aPasta[nI,1],2)) == "CV"
		nNumSeq := Val(SubStr(aPasta[nI,1],3)) + 1
		Exit
	Endif
next
cArqLog := "cv"+strzero(nNumSeq,6)+".log"
nHdlLog:=fCreate(cPathRoot+cArqLog,0)
If SUO->UO_TPMETA == "2"
	fWrite(nHdlLog,"VENDEDOR NOME                                     PRODUTO         DESCRICAO                                META STATUS                           "+CRLF)
	fWrite(nHdlLog,"----------------------------------------------------------------------------------------------------------------------------------------------------"+CRLF)
	bLinLog := {|| cVend+"   "+PadR(SA3->A3_NOME,40)+" "+cProd+" "+PadR(SB1->B1_DESC,30)+" "+Transform(nMeta,"@E 999,999,999.99")+" "+cErr}
Else
	fWrite(nHdlLog,"VENDEDOR NOME                                                  META STATUS                              "+CRLF)
	fWrite(nHdlLog,"--------------------------------------------------------------------------------------------------------"+CRLF)
	bLinLog := {|| cVend+"   "+PadR(SA3->A3_NOME,40)+" "+Transform(nMeta,"@E 99,999,999,999.99")+" "+cErr}
Endif

dbSelectArea("SA3")
dbSetOrder(1)	// FILIAL + VENDEDOR

dbSelectArea("SB1")
dbSetOrder(1)	// FILIAL + PRODUTO

// Exclui as metas existentes para a campanha, caso existam
dbSelectArea("ZZG")
dbSetOrder(1)	// FILIAL + CAMPANHA + VENDEDOR + PRODUTO

cFiliais := ""
dbSelectArea("SM0")
nRecSM0 := Recno()
dbSeek(cEmpAnt,.F.)
Do While SM0->M0_CODIGO == cEmpAnt .and. !Eof()
	dbSelectArea("ZZG")
	dbSeek(SM0->M0_CODFIL+SUO->UO_CODCAMP)
	Do While ZZG->ZZG_FILIAL+ZZG->ZZG_CODCAM == SM0->M0_CODFIL+SUO->UO_CODCAMP .and. !Eof()
		Reclock("ZZG",.F.)
			ZZG->(dbDelete())
		MsUnlock()
		dbSkip()
	Enddo
	dbSelectArea("SM0")
	cFiliais += "'" + SM0->M0_CODFIL + "',"
	dbSkip()
Enddo
cFiliais := Left(cFiliais,Len(cFiliais)-1)
dbGoto(nRecSM0)
IncProc()

// Variaveis de controle de registros processados
nProc  := 0
nNProc := 0

// Leitura das linhas detalhes do arquivo texto
While LeLinha(nHdl,@cLinha,@cBuffer)

    lGrava := .T.
    cErr := ""

    // Carrega a linha do arquivo em um array
    aLinha := U_ListAsArray(cLinha,";")

    cVend := PadR(aLinha[nPosVend],6)
	nMeta := U_ConvNum(aLinha[nPosMeta])

    // Posiciona tabela de vendedores e produtos
	If SUO->UO_TPMETA = "2"		// quantidades
	    cProd := PadR(aLinha[nPosProd],15)
		If !( SA3->(dbSeek(xFilial("SA3")+cVend,.F.))  )
			cErr := "Erro - Vendedor nao cadastrado"
			SB1->(dbGoBottom());SB1->(dbSkip())
			lGrava := .F.
		Else
			If !( SB1->(dbSeek(xFilial("SB1")+cProd,.F.)) )
				cErr := "Erro - Produto nao cadastrado"
				lGrava := .F.
			Endif
		Endif
	Else						// produtos
		If !( SA3->(dbSeek(xFilial("SA3")+cVend,.F.)) )
			cErr := "Erro - Vendedor nao cadastrado"
			lGrava := .F.
		Endif
	Endif

 	// Faz a gravacao das metas da campanha
	If lGrava

		//| GLPI : [2418]  || Titulo: [Adaptar CRM] || Analista: [cristianosm] || Data: [07/01/2016]
		// Verifica o nivel do vendedor
		/*
		cNivelVend := ""
		If SA3->A3_GRPREP $ cVI+cVE
			If SA3->A3_TIPO = "I"
				cNivelVend := "1"
			Elseif SA3->A3_TIPO = "E"
				cNivelVend := "2"
			Endif
		Elseif SA3->A3_GRPREP $ cCoor
			cNivelVend := "3"
		Elseif SA3->A3_GRPREP $ cCHVE
			cNivelVend := "4"
		Elseif SA3->A3_GRPREP $ cGEVE
			cNivelVend := "5"
		Elseif SA3->A3_GRPREP $ cDIVE
			cNivelVend := "6"
		Endif
  	    */
  	  cNivelVend := SA3->A3_NVLVEN

   		// grava o registro
		If SUO->UO_TPMETA == "2"	// quantidades
			lInclui := !dbSeek(SubStr(SA3->A3_ITEMD,2,2)+SUO->UO_CODCAMP+cVend+cProd,.F.)
		Else
			lInclui := !dbSeek(SubStr(SA3->A3_ITEMD,2,2)+SUO->UO_CODCAMP+cVend,.F.)
		Endif
   		RecLock("ZZG",lInclui)
			Replace ZZG_FILIAL with SubStr(SA3->A3_ITEMD,2,2),;
					ZZG_CODCAM with SUO->UO_CODCAMP,;
					ZZG_VEND  with cVend,;
					ZZG_NIVEL with cNivelVend,;
					ZZG_META with ZZG_META + nMeta
			If SUO->UO_TPMETA == "2"	// quantidades
				Replace ZZG_PRODUT with cProd
			Endif
		MSUnLock()
		// Se a meta estiver zerada ou negativa, da um alerta
   		If nMeta > 0
			cErr := "Ok"
		Elseif nMeta < 0
			cErr := "Ok, mas atencao, meta negativa"
		Else
			cErr := "Ok, mas atencao, meta zerada"
		Endif
		nProc++

	Else
		nNProc++
	Endif

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Grava os campos obtendo os valores da linha lida do arquivo texto.  ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cLog := Eval(bLinLog)
	fWrite(nHdlLog,cLog+CRLF)

EndDo

// Fecho o arquivo texto.
fClose(nHdl)
// Fecho o arquivo de log.
fClose(nHdlLog)
// Exibo mensagem no fim do processamento
If nNProc == 0
	cMsg := "Todos os registros foram atualizados com sucesso!"+CRLF+CRLF
	cMsg += alltrim(str(nProc))+" registros foram processados."
Else
	cMsg := "Ocorrência de registros não atualizados!"+CRLF+CRLF
	cMsg += "Foram atualizados "+alltrim(str(nProc))+" registros."+CRLF
	cMsg += "Não foram atualizados "+alltrim(str(nNProc))+" registros."+CRLF
	cMsg += "Para maiores detalhes, verifique o arquivo "+cPathRoot+cArqLog
Endif
IW_MsgBox(OemToAnsi(cMsg),OemToAnsi("Resumo"),IIF(nNProc==0,"INFO","ALERT"))

// Define meta geral da campanha
DefMetaCamp(cFiliais)

Return NIL


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ LeLinha  º Autor ³Expedito Mendonca Jrº Data ³  18/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Le uma linha do arquivo texto.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico para o cliente Imdepa                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LeLinha(nHdl,cLinha,cBuffer)
Local nPosCR := 0, nBtLidos := 1, nMove, nQtdInc, nJ
cLinha := ""
// Le os blocos ate encontrar o fim de linha (CR)
While nPosCR == 0 .and. nBtLidos > 0
	nBtLidos := fRead(nHdl,@cBuffer,TAM_BLOCO)
	nPosCR   := AT(CR,cBuffer)
	If nPosCR > 0
		cLinha += Substr(cBuffer,1,nPosCR-1)
	Else
		cLinha += cBuffer
	Endif
End
// Posiciono no inicio da proxima linha
If nPosCR > 0
	nMove := (Len(cBuffer)-nPosCR-1) * -1
	fSeek(nHdl,nMove,1)
Endif

// Incremento a regua conforme quantidade de bytes lidos
nBytesProc += Len(cLinha)+2
nQtdInc := Int(nBytesProc/TAM_BLOCO)
If nQtdInc > 0
	for nJ := 1 to nQtdInc
		IncProc()
	next
	nBytesProc := nBytesProc % TAM_BLOCO
Endif
Return nBtLidos > 0


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³DefMetaCamº Autor ³Expedito Mendonca Jrº Data ³  23/03/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Define a meta geral da campanha                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico para o cliente Imdepa                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DefMetaCamp(cFiliais)
Local aListBox, nOpca := 0
Local oDlg, oListbox, oMeta, nMeta := 0, cNivMeta := ""
Local oOk := LoadBitmap( GetResources(), "LBOK" )
Local oNo := LoadBitmap( GetResources(), "LBNO" )
Local cQuery, aStru, nI

// Calcula os totais por nivel de vendedor
cQuery := "SELECT ZZG.ZZG_NIVEL NIVEL, SUM(ZZG.ZZG_META) META "
cQuery += " FROM "+RetSqlName("ZZG")+" ZZG "
cQuery += " WHERE ZZG.ZZG_FILIAL IN ( " + cFiliais + " )"
cQuery += " AND ZZG.ZZG_CODCAM = '" + SUO->UO_CODCAMP + "'"
cQuery += " AND ZZG.D_E_L_E_T_ = ' '"
cQuery += " GROUP BY ZZG.ZZG_NIVEL "
TCQUERY cQuery NEW ALIAS "TRB"

// Verifica se a query foi executada com sucesso
If Alias() != "TRB"
	IW_MsgBox("Erro ao definir meta geral da campanha de vendas.","Atenção","ALERT")
	Return NIL
Endif

If Eof()
	dbCloseArea()
	IW_MsgBox("Não havia nenhuma meta de vendedor cadastrada para esta campanha.","Atenção","ALERT")
	Return NIL
Endif

aStru := DbStruct()
For nI := 1 To Len( aStru )
   If aStru[nI,2] != "C"
	   TCSetField( "TRB", aStru[nI,1], aStru[nI,2], aStru[nI,3], aStru[nI,4] )
   EndIf
Next

// Define os totais por nivel de vendedor
aListBox := {}
Do While !Eof()
	aAdd(aListBox,{.F.,TRB->NIVEL,DescNivVend(Val(TRB->NIVEL)),TRB->META})
	dbSkip()
Enddo
dbCloseArea()

// Monta a tela para o usuario elaborar a meta total da campanha
DEFINE MSDIALOG oDlg TITLE OemToAnsi( "Definicao de Metas da Campanha de Vendas" ) FROM 026,043 TO 273,482 PIXEL

	DEFINE FONT oFont NAME "Courier New" SIZE 0,-11
	@ 15,02 LISTBOX oListBox FIELDS HEADER "" , "", OemToAnsi("Vendedores") , OemToAnsi("Total")  SIZE 217,078;
		ON DBLCLICK (Marca(oListBox:nAt,@aListBox,@oMeta,@nMeta,@cNivMeta),oListBox:nColPos := 1,oListBox:Refresh()) NOSCROLL PIXEL FONT oFONT

	oListBox:SetArray(aListBox)
	oListBox:bLine := { || { IF(aListBox[oListBox:nAt,1],oOk,oNo),aListBox[oListBox:nAt,2],aListBox[oListBox:nAt,3],Transform(aListBox[oListBox:nAt,4],"@E 99,999,999.99") } }

	@ 100,010 SAY OemToAnsi("Campanha:") OF oDlg PIXEL
	@ 100,040 SAY SUO->UO_CODCAMP+" - "+SUO->UO_DESC OF oDlg PIXEL
	@ 110,010 SAY OemToAnsi("Meta Geral:") OF oDlg PIXEL
	@ 110,035 SAY oMeta VAR nMeta PICTURE "@E 999,999,999.99" of oDlg SIZE 50,10 PIXEL
//	@ 110,150 SAY oNivMeta VAR CNivMeta of oDlg SIZE 50,10 PIXEL

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , {|| nOpca := 1,oDlg:End()} , {|| oDlg:End()} )

// Grava a meta geral da campanha
IF nOpca == 1
	RecLock("SUO",.F.)
		SUO->UO_METAIMD := nMeta
		SUO->UO_NIVMETA := cNivMeta
	MsUnlock()
	IW_MsgBox("Meta geral atualizada com sucesso!","Atenção","INFO")
Else
	IW_MsgBox("Meta geral não foi atualizada!","Atenção","ALERT")
Endif

DeleteObject(oOk)
DeleteObject(oNo)

Return( NIL )



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ Marca    º Autor ³Expedito Mendonca Jrº Data ³  23/03/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Marca / Desmarca itens para definicao da meta geral da     º±±
±±º          ³ Campanha de Vendas                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico para o cliente Imdepa                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Marca(nAt,aArray,oMeta,nMeta,cNivMeta)
Local nPos, cNivel := IIF(Empty(aArray[nAt,2]),"X",aArray[nAt,2])
aArray[nAt,1] := !aArray[nAt,1]
If aArray[nAt,1]	// usuario marcou
	nMeta += aArray[nAt,4]
	cNivMeta += cNivel
Else				// usuario desmarcou
	nMeta -= aArray[nAt,4]
	nPos := At(cNivel,cNivMeta)
	cNivMeta := Substr(cNivMeta,1,nPos-1) + Substr(cNivMeta,nPos+1)
Endif
oMeta:Refresh()
//oNivMeta:Refresh()
Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³DescNivVenº Autor ³Expedito Mendonca Jrº Data ³  23/03/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Retorna a descricao do nivel do vendedor                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico para o cliente Imdepa                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DescNivVend(nNivel)
Local aDesc := {"Vendedores Internos","Vendedores Externos","Vendedores Coordenadores","Chefes de Vendas","Gerentes de Vendas","Diretores de Vendas"}
Local cRet := ""
If nNivel >= 1 .and. nNivel <= 6
	cRet := aDesc[nNivel]
Endif
Return PadR(cRet,30)