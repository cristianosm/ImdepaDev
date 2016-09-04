#include 'protheus.ch'
#include 'parmtype.ch'
#Include "Tbiconn.ch"

#Define  ORD_NAME  1
#Define  ENTER   CHR(13)+CHR(10)

// estrutura csv
#Define CT_FILIAL	1
#Define CT_DATA		2
#Define CT_PRODUTO	3
#Define CT_CLIENTE	4
#Define CT_LOJACLI	5
#Define CT_QUANT	6


*********************************************************************
User Function ImpMetasFla()
*********************************************************************

Local   aFiles 	:= {} // Ira creceber os arquivos contidos no diretorio
Private cDircsv := ""

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "05" FUNNAME 'ImpMetasFla'  TABLES 'SM0'

TelaPar(@aFiles) // Tela com Diretorio dos arquivos para carga dos files

If Len(aFiles) > 0 // Caso tenha encontrado algum arquivo a ser importado

	Executa(aFiles)

EndIF

RESET ENVIRONMENT

Return()
*********************************************************************
Static Function TelaPar(aFiles) // Tela com Diretorio dos arquivos para carga dos files
*********************************************************************
Private oLeDir		:= Nil
Private oButton1	:= Nil
Private oButton2	:= Nil
Private oSay		:= Nil
Private oDircsv		:= Nil

cDircsv 			:= "C:\protheus\metas2016\"+Space(100)
/*
DEFINE MSDIALOG oLeDir TITLE "Importação das Metas Flavio  " FROM 000, 000  TO 200, 400 COLORS 0, 16777215 PIXEL

@ 10,018 Say oSay PROMPT " Este programa ira ler os arquivos *.csv do diretorio " SIZE 300, 007 OF oLeDir COLORS 0, 12632256 PIXEL
@ 18,018 Say oSay PROMPT " abaixo e importara para a Tabela METAS2016 no Formato: "			SIZE 300, 007 OF oLeDir COLORS 0, 12632256 PIXEL
@ 26,018 Say oSay PROMPT "CT_FILIAL,CT_DATA,CT_PRODUTO,CT_CLIENTE,CT_LOJACLI,CT_QUANT"			SIZE 300, 007 OF oLeDir COLORS 0, 12632256 PIXEL

@ 40,018 Say oSay PROMPT "Diretorio: " SIZE 100, 007 OF oLeDir COLORS 0, 12632256 PIXEL
@ 38,040 MSGET oDircsv VAR cDircsv SIZE 130, 010 OF oLeDir PICTURE "@!" VALID !Empty(Alltrim(cDircsv)) COLORS 0, 16777215 PIXEL

@ 70, 040 BUTTON oButton1 PROMPT "Importar" SIZE 040, 012 OF oLeDir ACTION oLeDir:End()  PIXEL
@ 70, 110 BUTTON oButton2 PROMPT "Sair" 	SIZE 040, 012 OF oLeDir ACTION oLeDir:End()  PIXEL

ACTIVATE MSDIALOG oLeDir CENTERED
*/
cDircsv := Alltrim(cDircsv)

aFiles := Directory( cDircsv+"*.csv", Nil, Nil, Nil, ORD_NAME)

Return()
*********************************************************************
Static Function Executa(aFiles) // Executa a importacao dos arquivos
*********************************************************************

	For nF := 1 To Len(aFiles)

		LeCsv(cDircsv+aFiles[nF][1], aFiles[nF][2])

	Next

Return()
*********************************************************************
Static Function LeCsv(cFile, nTamFile)
*********************************************************************

Private nHdl    := FT_FUSE(cFile) //| fOpen(cDircsv,68)

If nHdl == -1
	MsgAlert("O arquivo de nome "+ cDircsv +" nao pode ser aberto! Verifique os parametros.","Atencao!")
	Return()
Endif

//³ Inicializa a regua de processamento                                 ³
Processa({|| ImpFile(@nHdl, cFile,  nTamFile ) },"Importando arquivo"+cFile,"Aguarde...")

Return()
*********************************************************************
Static Function ImpFile(nHdl, cFile, nTamFile)
*********************************************************************

Local   cBuffer	 := ""
Local 	aLin 	 := {}
Local   nL 		 := 0
Local   nShow	 := 0
Local   nNext	 := 0
Local   nFator   := 723488 /// Fator obtido atraves de calculos matematicos...

FT_FGOTOP();FT_FSKIP() // Pula Cabecalho

cBuffer := StrTran(FT_FREADLN(),'"',"") //| Retira as aspas duplas da String
nTaLin 	:= Len(cBuffer) + 2 			//| Tamanho da Linha em Bytes
nFator  := nTamFile/nFator				//| Fator de Correcao para calculo do numero de linhas
nLin 	:= Round((nTamFile/nTaLin),0) - ( Round(nTaLin * nFator ,0) + 2 ) //| Calculo Numero de linhas do arquivo
nNext   := nShow := Round(nTaLin * nFator ,0) //| Monta quando connout deve imprimir as linhas, para nao atrasar o processo.

conout(" METAS - Iniciando File: "+cFile )

While !FT_FEOF()


	//|Tratamento para StrTokArr
	cBuffer := StrTran(FT_FREADLN(),'"',"") //| Retira as aspas duplas da String

	aLin 	:= StrTokArr(cBuffer,";") 	//| Converte a Linha para Array

	InsereReg(@aLin)

	nL += 1

	If( nNext == nL )
		conout(" METAS - Linha: "+cValToChar(nL)+" de "+cValToCHar(nLin)+" File: "+cFile )
		nNext += nShow

	elseIf( nLin == nL )
	   conout(" METAS - Linha: "+cValToChar(nL)+" de "+cValToCHar(nLin)+" File: "+cFile )
	Endif


	FT_FSKIP()//	nBtLidos := fRead(nHdl,@cBuffer,nTamLin) // Leitura da proxima linha do arquivo texto

EndDo

FT_FUSE()//³ O arquivo texto deve ser fechado, bem como o dialogo criado na funcao anterior.

Return()
*********************************************************************
Static Function InsereReg(aLin)
*********************************************************************

Local cTable := "METAS2016"

// Tratamento do Campo Quantidade, troca do decimal , por . para que o insert funcione
Local cQUNAT 	:= StrTran(aLin[CT_QUANT],',','.') //

Local InsertSql := "Insert into "+cTable+" (CT_FILIAL,CT_DATA,CT_PRODUTO,CT_CLIENTE,CT_LOJACLI,CT_QUANT) "
Local cValues   := " values ('"+aLin[CT_FILIAL]+"','"+aLin[CT_DATA]+"','"+aLin[CT_PRODUTO]+"','"+aLin[CT_CLIENTE]+"','"+aLin[CT_LOJACLI]+"',"+cQUNAT+") "

Local cExecCmd := InsertSql + cValues

cError  := U_ExecMySql(cExecCmd, "", "E", .F., .F.)


Return()