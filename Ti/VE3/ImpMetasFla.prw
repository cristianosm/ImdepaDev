#include 'protheus.ch'
#include 'parmtype.ch'
#Include "Tbiconn.ch"

#Define  ORD_NAME  1
#Define  ENTER   CHR(13)+CHR(10)

/// estrutura csv
/*
01 - "c4_data" 			= "01/11/2017" 	;
02 - "Gerente" 			= "000276"		;
03 - "c4_filial" 		= "06"			;
04 - "canal2" 			= "AG1"			;
05 - "canal3" 			= "000403"		;
06 - "c4_cliente" 		= "016449"		;
07 - "c4_lojacli" 		= "01"			;
08 - "Campo8" 			= "I"			;
09 - "Campo9" 			= "001811"		;
10 - "Campo10" 			= "ECO_1209K"	;
11 - "c4_produto" 		= "00052692"	;
12 - "c4prvdfin" 		= 0,07			;
13 - "c4prvdfin_preco" 	= 0,82			;
14 - "c4prvdfin_custo" 	= 0,44			;
15 - "suggestion_2" 	= 0,07			;
16 - "suggestion_3" 	= 0,07			;
17 - "consensus" 		= 0,07			;
*/

//| CAMPOS ARQUIVO CSV
#Define F_DATA		 1
#Define F_VEND	 	 2
#Define F_FILIAL   	 3
#Define F_CLIENTE	 6
#Define F_LOJACLI	 7
#Define F_PRODUTO	 11
#Define F_QUANT	 	 12
#Define F_VALOR	 	 13



#Define CANO       '2017'

//| CAMPOS TABELA SCT010 INSERT
#Define TCT_FILIAL   1
#Define TCT_DOC		 2
#Define TCT_SEQUEN	 3
#Define TCT_DESCRI	 4
#Define TCT_VEND	 5
#Define TCT_DATA	 6
#Define TCT_PRODUTO	 7
#Define TCT_QUANT	 8
#Define TCT_VALOR	 9
#Define TCT_MOEDA	 10
#Define TCT_CLIENTE	 11
#Define TCT_LOJACLI	 12
#Define TCT_RELAUTO	 13

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

	cDircsv 			:= "C:\protheus\metas2017\"+Space(100)

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

	// Inicializa a regua de processamento
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

	Private cDoc		:= 'CP0000000' // Numero do DOC
	Private cSequen	 	:= '000'
	Private cDescri		:= ''
	Private nMOEDA	 	:=  1
	Private cRELAUTO	:= '9'
	Private cFilAtu		:= ''
	Private nNewRec		:= 0

	FT_FGOTOP();FT_FSKIP() // Pula Cabecalho

	cBuffer := StrTran(FT_FREADLN(),'"',"") //| Retira as aspas duplas da String
	nTaLin 	:= Len(cBuffer) + 2 			//| Tamanho da Linha em Bytes
	nFator  := nTamFile/nFator				//| Fator de Correcao para calculo do numero de linhas
	nLin 	:= Round((nTamFile/nTaLin),0) - ( Round(nTaLin * nFator ,0) + 2 ) //| Calculo Numero de linhas do arquivo
	nNext   := nShow := Round(nTaLin * nFator ,0) //| Monta quando connout deve imprimir as linhas, para nao atrasar o processo.



	conout(" METAS - Iniciando File: " + cFile )
    conout(" METAS - Limpando Periodo: " + CANO )
	CleanPeriodo()

	nNewRec := HowRecno() // Recno a ser utilizado...

	While !FT_FEOF()


		//|Tratamento para StrTokArr
		cBuffer := StrTran(FT_FREADLN(),'"',"") //| Retira as aspas duplas da String

		aLin 	:= StrTokArr(cBuffer,";") 	//| Converte a Linha para Array

		ContDocSeq(aLin) //| Controla a Numeracao do DOC e SEQUEN

		InsereReg(@aLin)

		nL += 1

		If( nNext == nL )
			conout(" METAS - Linha: "+cValToChar(nL)+" de "+cValToCHar(nLin)+" File: "+cFile )
			nNext += nShow

		elseIf( nLin == nL )
			conout(" METAS - Linha: "+cValToChar(nL)+" de "+cValToCHar(nLin)+" File: "+cFile )
		Endif

		FT_FSKIP()//nBtLidos := fRead(nHdl,@cBuffer,nTamLin) // Leitura da proxima linha do arquivo texto

	EndDo

	FT_FUSE()// O arquivo texto deve ser fechado, bem como o dialogo criado na funcao anterior.

	Return()
*********************************************************************
Static Function InsereReg(aLin) // Insere o Registro na SCT
*********************************************************************



	// Tratamento do Campo Quantidade, troca do decimal , por . para que o insert funcione
	Local cQuant 	:= StrTran(aLin[F_QUANT],',','.') //
	Local cValor 	:= StrTran(aLin[F_VALOR],',','.') //

	Local InsertSql := "Insert into SCT010 (CT_FILIAL,CT_DOC,CT_SEQUEN,CT_DESCRI,CT_REGIAO,CT_CCUSTO,CT_ITEMCC,CT_VEND,CT_CIDADE,CT_MARCA,CT_SEGMEN,CT_DATA,CT_TIPO,CT_GRUPO,CT_PRODUTO,CT_QUANT,CT_VALOR,CT_MOEDA,CT_CLVL,CT_MARGEM,D_E_L_E_T_,R_E_C_N_O_,CT_CLIENTE,CT_LOJACLI,CT_GRPSEGT,CT_MARCA3,CT_CATEGO,R_E_C_D_E_L_,CT_ORIGER,CT_RELAUTO,CT_MARGVLR) "
	Local cValues   := "values ('"+aLin[F_FILIAL]+"','"+cDoc+"','"+cSequen+"','"+Mdescri(aLin[F_FILIAL])+"','   ','         ','         ','"+aLin[F_VEND]+"','      ','                    ','      ','"+dtos(ctod(aLin[F_DATA]))+"','  ','    ','"+aLin[F_PRODUTO]+"',"+cQuant+","+cValor+",'1','         ','0',' ',"+toc(nNewRec)+",'"+aLin[F_CLIENTE]+"','"+aLin[F_LOJACLI]+"','   ','          ','      ','0','          ','9',0)"


	Local cExecCmd := InsertSql + cValues

	cError  := U_ExecMySql(cExecCmd, "", "E", .F., .F.)

	If Alltrim(cError) <> 'Executado Com Sucesso'
		conout(" METAS - cError: "+ cError + " " )

	Else
		nNewRec += 1
	EndIf

Return()
*********************************************************************
Static Function CleanPeriodo() // Obtem o atual RECNO na Tabela SCT - METAS
*********************************************************************

	Local cSql 		:= " DELETE SCT010 WHERE CT_FILIAL > ' ' AND CT_RELAUTO = '9' AND CT_DATA BETWEEN '"+CANO+"0101' AND '"+CANO+"1231'  "

	U_ExecMySql(cSql, "", "E", .F., .F.)


Return()
*********************************************************************
Static Function HowRecno() // Obtem o atual RECNO na Tabela SCT - METAS
*********************************************************************

	Local cSql 		:= "SELECT ( MAX(R_E_C_N_O_) + 1 ) AS RECNO FROM SCT010  "
	Local nRecno	:= 0

	U_ExecMySql(cSql, "REC", "Q", .F., .F.)

	DbSelectArea("REC");DbGotop()
	nRecno := REC->RECNO
	DbSelectArea("REC");DbCloseArea()

Return(nRecno)
*********************************************************************
Static Function HowDoc(cFil) //| Obtem o atual DOC na Tabela SCT - METAS
*********************************************************************
	Local cSql 	:= "SELECT MAX(CT_DOC) DOC FROM SCT010 WHERE SUBSTR(CT_DOC,1,2) = 'CP' AND CT_FILIAL =  '"+cFil+"' AND  D_E_L_E_T_ = ' ' "
	Local cDoc	:= ""

	U_ExecMySql(cSql, "DOC", "Q", .F., .F.)

	DbSelectArea("DOC");DbGotop()
	cDoc := DOC->DOC
	DbSelectArea("DOC");DbCloseArea()

Return(cDoc)
*********************************************************************
Static Function HowSequenc(cDoc) //| Obtem o atual SEQUEN na Tabela SCT - METAS
*********************************************************************
	Local cSql 	:= "SELECT TRIM(MAX(CT_SEQUEN)) SEQ FROM SCT010 WHERE CT_FILIAL = '"+cFilAtu+"' AND CT_DOC = '"+cDoc+"' AND   D_E_L_E_T_ = ' '"


	U_ExecMySql(cSql, "SEQ", "Q", .F., .F.)

	DbSelectArea("SEQ");DbGotop()
	cSequen := SEQ->SEQ
	DbSelectArea("SEQ");DbCloseArea()


Return(cSequen)
*********************************************************************
Static Function ContDocSeq(aLin)
*********************************************************************

//	cDOC		:= '' // Numero do DOC
//	cSEQUEN

	//| Incrementa a Sequencia por padrao...
	cSequen := soma1(cSequen)

	//| Troca de Filial...
	If aLin[F_FILIAL] <> cFilAtu

		cFilAtu := aLin[F_FILIAL]
		cDoc	:= HowDoc(cFilAtu)

		If Empty(cDoc)
			cDoc 	:= 'CP0000000'
			cSequen	:= '000'
		Else
			cSequen	:= HowSequenc(cDoc)
		EndIf

		cSequen := soma1(cSequen)

		If cSequen == '001'
			cDoc := soma1(cDoc)
		EndIf

	ElseIf cSequen == '001'  //| Estouro de Sequencia... Incrementa o DOC
		cDoc := soma1(cDoc)
	EndIf


Return()
*********************************************************************
Static Function Mdescri(cFilAtu) // Converte para caracter qualquer tipo de variavel
*********************************************************************


	Local cSql 	:= "SELECT A1_UFREC CUF FROM SA1010 WHERE A1_COD = 'N00000' AND A1_LOJA = '"+cFilAtu+"' "
	Local cUF	:= ""



	U_ExecMySql(cSql, "CUF", "Q", .F., .F.)

	DbSelectArea("CUF");DbGotop()
	cUF := CUF->CUF
	DbSelectArea("CUF");DbCloseArea()


	cDescri :=  'META ' + CANO + ' ' + cUF + ' PROD CLIENTE'


Return(cDescri)
*********************************************************************
Static Function toc(cval) // Converte para caracter qualquer tipo de variavel
*********************************************************************
Return( cValToChar(cval) )


