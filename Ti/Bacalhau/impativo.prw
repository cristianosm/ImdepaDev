#include "RWMAKE.CH"
#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "AP5MAIL.CH"

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : NomeProg    | AUTOR : Cristiano Machado  | DATA : 07/05/2003   **
**---------------------------------------------------------------------------**
** DESCRIÇÃO:                                                                **
**---------------------------------------------------------------------------**
** USO      : Especifico para o cliente XXXXXX                               **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
**            ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.              **
**---------------------------------------------------------------------------**
**   PROGRAMADOR   |   DATA   |            MOTIVO DA ALTERACAO               **
**---------------------------------------------------------------------------**
**                 |          |                                              **
**                 |          |                                              **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User Function ImpAtivo()
*******************************************************************************
Private oLeTxt
Private oButton1
Private oButton2
Private oSay
Private oArqTxt
Private cArqTxt := "C:\Importa\ativo.txt" + space(50)

DEFINE MSDIALOG oLeTxt TITLE "Importacao Arquivo - Ativo Fixo" FROM 000, 000  TO 200, 400 COLORS 0, 16777215 PIXEL
@ 10,018 Say oSay PROMPT " Este programa ira ler o conteudo do arquivo texto informado" SIZE 300, 007 OF oLeTxt COLORS 0, 12632256 PIXEL
@ 18,018 Say oSay PROMPT " abaixo e importara os registros para o Ativo Fixo."			SIZE 300, 007 OF oLeTxt COLORS 0, 12632256 PIXEL

@ 40,018 Say oSay PROMPT "Arquivo: " SIZE 100, 007 OF oLeTxt COLORS 0, 12632256 PIXEL
@ 38,040 MSGET oArqTxt VAR cArqTxt SIZE 130, 010 OF oLeTxt PICTURE "@!" VALID !Empty(Alltrim(cArqTxt)) COLORS 0, 16777215 PIXEL

@ 70, 040 BUTTON oButton1 PROMPT "Importar" SIZE 040, 012 OF oLeTxt ACTION {||oLeTxt:End(),OkLeTxt()} PIXEL
@ 70, 110 BUTTON oButton2 PROMPT "Sair" SIZE 040, 012 OF oDlg ACTION oLeTxt:End()  PIXEL

ACTIVATE MSDIALOG oLeTxt CENTERED

Return()
*******************************************************************************
Static Function ApagaLoja(cLoja)//Funcao utilizada para limpar os dados de uma determinada loja, para que seja feita a reimportacao.
*******************************************************************************
If Aviso('APAGA ATIVOS','Essa operacao ir· excluir todos os Ativos da filial '+cLoja+'. '+chr(13)+chr(10)+'Deseja continuar?',{'Sim','Nao'})==2
	Return .t.
EndIf

ProcRegua(0) // Numero de registros a processar

AbreExcl("SN1")
DELETE FOR N1_FILIAL = cLoja
PACK
IncProc()

AbreExcl("SN2")
DELETE FOR N2_FILIAL = cLoja
PACK
IncProc()

AbreExcl("SN3")
DELETE FOR N3_FILIAL = cLoja
PACK
IncProc()

AbreExcl("SN4")
DELETE FOR N4_FILIAL = cLoja
PACK
IncProc()

Aviso('Apaga Ativos da Filial','Todos os ativos da Filial '+cLoja+' foram apagados.',{'Ok'})

Return(.T.)
*******************************************************************************
Static Function ApagaSN2(cLoja)
*******************************************************************************

If Aviso('APAGA ATIVOS','Essa operacao ir· excluir as descricoes estendias da filial '+cLoja+'. '+chr(13)+chr(10)+'Deseja continuar?',{'Sim','Nao'})==2
	Return .t.
EndIf

AbreExcl("SN2")
DELETE FOR N2_FILIAL = cLoja
PACK

Aviso('Apaga Ativos da Filial','Todas as descricoes estendidas da Filial '+cLoja+' foram apagadas.',{'Ok'})

Return .t.
*******************************************************************************
Static Function OkLeTxt()//Funcao chamada pelo botao OK na tela inicial de processamen to. Executa a leitura do arquivo texto.
*******************************************************************************
//> Abertura do arquivo texto                                           >
Private cTitulo := "Importando Bens"
Private cMsg 	:= "Processando Bem:"

cArqTxt 		:= alltrim(cArqTxt)
Private nHdl    := FT_FUSE(cArqTxt) //| fOpen(cArqTxt,68)

Private cEOL    := "CHR(13)+CHR(10)"

If Empty(cEOL)
	cEOL := CHR(13)+CHR(10)
Else
	cEOL := Trim(cEOL)
	cEOL := &cEOL
Endif

If nHdl == -1
	MsgAlert("O arquivo de nome "+ cArqTxt +" nao pode ser aberto! Verifique os parametros.","Atencao!")
	Return()
Endif

//> Inicializa a regua de processamento                                 >
Processa({|| RunCont() },cTitulo,cMsg)

Return()
*******************************************************************************
Static Function RunCont()
*******************************************************************************

//| Campos Arquivo de Entrada
Local _Codigo_Bem 			:= 1
Local _Tipo_Valor 			:= 2
Local _Filial 				:= 3
Local _Codigo_Especie 		:= 4
Local _Data_Aquisicao 		:= 5
Local _Numero_Adicao 		:= 6
Local _Descricao 			:= 7
Local _Data_Uso 			:= 8
Local _Tipo_Bem 			:= 9
Local _Codigo_Contabil 		:= 10
Local _Codigo_Gerencial 	:= 11
Local _Plaqueta 			:= 12
Local _Tx_Especial1 		:= 13
Local _Tx_Especial2 		:= 14
Local _Valor1_Original 		:= 15
Local _Numeros_Original 	:= 16
Local _Correcao_Acumulada 	:= 17
Local _Deprec_Acumulada1 	:= 18
Local _Deprec_Acu_Num1 		:= 19
Local _Valor2_Original 		:= 20
Local _Deprec_Acumulada2 	:= 21
Local _Data_Garantia 		:= 22
Local _Data_Manutencao 		:= 23
Local _Vinculo_Bem 			:= 24
Local _Quantidade			:= 25
Local _Natureza_bem 		:= 26
Local _Class_Historico 		:= 27
Local _Historico 			:= 28
Local _Cgc_Fornecedor 		:= 29
Local _Modelo_Documento 	:= 30
Local _Nota_Fiscal 			:= 31
Local _Numero_Serie 		:= 32
Local _Marca 				:= 33
Local __Modelo 				:= 34
Local _Ano 					:= 35
Local _Numero_LRE 			:= 36
Local _Folha_LRE 			:= 37
Local _Valor_Icms 			:= 38
Local _Planta 				:= 39
Local _Local_ 				:= 40
Local _Pis_Cofind 			:= 41

Local cBuffer				:= ""
Local aItem					:= {}
Local nCont					:= 0
Local nSeqSn2				:= 0
Local cDescSn2				:= ""

Private cxEnter	 := CHR(13)+CHR(10)
Private dDtProc	 := Ctod("31/05/2010")
Private cLogTxt	 := ""
Private cDescIni := ""

ProcRegua(0) // Numero de registros a processar

cLogTxt := ".:: Importacao de Ativos Fixos ::. Start = "+DtoS(Ddatabase)+" "+Time()+cxEnter+cxEnter

FT_FGOTOP()
While !FT_FEOF()

	cDescIni := ""
	//|Tratamento para StrTokArr
	cBuffer := StrTran(FT_FREADLN(),'"',"") //| Retira as aspas duplas da String
	While AT(";;",cBuffer) > 0
		cBuffer := StrTran(cBuffer,';;',"; ;")
	EndDo

	aItem 	:= StrTokArr(cBuffer,";") 	//| Converte a Linha para Array

	Private cFilial  := "01"
	Private cCBase   := "HU00"+aItem[_Codigo_Bem]

	IncProc(cMsg+" "+cCBase)

	Private cItem    := IncItem(cCBase)
	Private cChapa   := aItem[_Plaqueta]
	Private cTipo	 := FGetTipo(aItem[_Tipo_Valor])
	If Empty(cTipo)
		cLogTxt += " - Item " + cCBase + " Tipo Vazio ! Nao Importado !!! " + cxEnter
		FT_FSKIP()
		Loop
	Endif

	Private cCodGru  := GetCodGrupo(aItem[_Codigo_Especie]) //| Codigo do grupo
	If Empty(cCodGru)
		cLogTxt += " - Item: " + cCBase + " Grupo "+aItem[_Codigo_Especie]+" Nao Encontrado. Nao ser· Importado !!! " + cxEnter
		FT_FSKIP()
		Loop
	Endif


	//| Tratamento Especial de Grupos
	cGrupEsp := ""
	cGrupEsp := GetEspecie()//| Obtem o Codigo do Grupo Atraves do Codigo Base
	If !Empty(cGrupEsp)
		cCodGru := cGrupEsp
	Endif

	Private cDescric := cDescIni + " " + aItem[_Descricao]

	Private cCCusto  := FGetcCus(aItem[_Codigo_Gerencial])
	If Empty(cCCusto)
		cLogTxt += " - Item: " + cCBase + " Centro de Custo "+aItem[_Codigo_Especie]+" Nao Encontrado. Nao ser· Importado !!! " + cxEnter
		FT_FSKIP()
		Loop
	Endif

	Private cCContab := POSICIONE("SNG",1, XFILIAL("SNG") + cCodGru,"NG_CCONTAB")
	If Empty(cCContab)
		cLogTxt += " - Item: " + cCBase + " Grupo "+cCodGru+" Conta Contabil nao preenchida. Nao ser· Importado !!! " + cxEnter
		FT_FSKIP()
		Loop
	Endif

	Private cCCDepAc := POSICIONE("SNG",1, XFILIAL("SNG") + cCodGru,"NG_CCDEPR")
	If Empty(cCCDepAc) .And. cCodGru <> "0016" //| Nao deprecia
		cLogTxt += " - Item: " + cCBase + " Grupo "+cCodGru+" Conta Depreciacao Acumulada nao preenchida/Vazia. Nao ser· Importado !!! " + cxEnter
		FT_FSKIP()
		Loop
	Endif

	cCDespDe := "7111191001307001" //Conforme Tipo . Reavaliado = 02

	If cTipo == "02"

		cCDespDe := "7111191001307002"

		cAux 		:= cCContab
		cCContab 	:= FGetConRL(Alltrim(cCContab))
		If Empty(cCContab)
			cLogTxt += " - Item: " + cCBase + " Conta Contabil Reavaliado nao encontrada no De: "+cAux+" Para:. Nao ser· Importado !!! " + cxEnter
			FT_FSKIP()
			Loop
		Endif

		cAux 		:= cCCDepAc
		cCCDepAc 	:= FGetConRL(Alltrim(cCCDepAc))
		If Empty(cCCDepAc)
			cLogTxt += " - Item: " + cCBase + " Conta Contabil Reavaliado nao encontrada no De: "+cAux+" Para:. Nao ser· Importado !!! " + cxEnter
			FT_FSKIP()
			Loop
		Endif
	Endif




	Private cFornec  := "SH0010"
	Private cCocloja := "01"

	Private cLocaliz := FGetLoc(cCCusto)  		//| Endereco = EndereÁo do bem dentro da empresa
	If Empty(cLocaliz)
		cLogTxt += " - Item: " + cCBase + " No C.Custo "+cCCusto+" Nao Encontrado Local. Nao ser· Importado !!! " + cxEnter
		FT_FSKIP()
		Loop
	Endif

	Private cNFiscal := aItem[_Nota_Fiscal]
	Private dAquisic := CTOD(aItem[_Data_Aquisicao])
	Private nValor   := Val(aItem[_Valor1_Original])
	Private dUsoIni  := CTOD(aItem[_Data_Uso])
	//| Depreciacoes
	Private nTxDepr  := FGetTxdep(cCodGru)	//| Tx An Depr 1	= Neste campo deve ser indicada qual a taxa de depreciaÁ·o anual do bem na Moeda 1

	//| Valor da Taxa de Depreciacao Utilizada no SN4
//|	Private nFatorDp   :=  ( ( nTxDepr / 100) / 360 ) * ( NumMes(dAquisic) * 30 ) //| Formula = ( Taxa / 100 ) / 360 ) * (Numero de Meses (Aquisicao - Hoje) * 30 )
//	Private nFatorDp   := ( ( (nTxDepr / 100) / 12 ) * NumMes(dUsoIni) ) //| Formula = ( Taxa / 100 ) / 360 ) * (Numero de Meses (Aquisicao - Hoje) * 30 )
	Private nFatorDp   := ( Round( ( (nValor * (nTxDepr / 100)) / 12 ),2) * NumMes(dUsoIni) ) //| Formula = ( Taxa / 100 ) / 360 ) * (Numero de Meses (Aquisicao - Hoje) * 30 )

	Private nDepMes  := Iif( nFatorDp > nValor, nValor, nFatorDp ) 	//| Depr Mes M1		= Valor da ultima depreciacao na Moeda 1.
	Private nVDepr   := Iif( nFatorDp > nValor, nValor, nFatorDp )	//| Depr Acum M1 	= Valor da Depreciacao Acumulada na Moeda 1.

	//|	Private nSResid  := aItem()	//|
	//|	Private nMesDepr := aItem()	//|
	//|	Private cDesGru  := GetDesGru(cCodGru)       //| Descricao do Grupo
	//|	Private cLocLoja := aItem()	//|

	//"Tot.: "+alltrim(str(int(nTotalLin)))+" - Atual: "+alltrim(str(nCont))+" - CÛd.: "+alltrim(cCBase))

	//> Grava os campos do Cadastro de Ativos Imobilizados a partir das         >
	//> Tabela: SN1                                                                                                                     >

	DbSelectarea("SN1");DbSetOrder(1)
	If DbSeek(xFilial("SN1")+cCbase+cItem,.F.)
		cLogTxt += " - Item: " + cCBase + " Ja existe na Base Atual do Ativo. Nao ser· Importado !!! " + cxEnter
		FT_FSKIP()
		Loop
	Endif

	DbSelectArea("SN1")
	SN1->(DBAPPEND())
	SN1->(RLOCK())

	SN1->N1_FILIAL  := XFilial("SN1")
	SN1->N1_GRUPO   := cCodGru
	//	SN1->N1_GRUDES  := cDesGru
	SN1->N1_ITEM    := cItem
	SN1->N1_CBASE   := cCbase
	SN1->N1_DESCRIC := Substr(cDescric,1,25)
	SN1->N1_QUANTD  := 1
	SN1->N1_CHAPA   := cChapa
	//	SN1->N1_ESTADO  := cEstCons
	SN1->N1_LOCAL   := cLocaliz
	SN1->N1_LOJA 	:= cCocloja
	SN1->N1_FORNEC  := cFornec
	SN1->N1_NFISCAL := cNFiscal
	SN1->N1_AQUISIC := dAquisic
	SN1->N1_PATRIM  := "N"
	SN1->N1_ITEMFOR := "133SH0010"

	SN1->(MSUNLOCK())

	//> Grava os campos na Tabela de Descricoes Estendidas a partir
	cDescSn2	:= cDescric
	DbSelectArea("SN2")
	while !Empty(Trim(cDescSn2))

		nSeqSn2 += 1

		SN2->(DBAPPEND())
		SN2->(RLOCK())

		SN2->N2_FILIAL  := xFilial("SN2")
		SN2->N2_CBASE   := cCbase
		SN2->N2_ITEM    := cItem
		SN2->N2_SEQ     := "001"
		SN2->N2_SEQUENC := StrZero(nSeqSn2, 2)
		SN2->N2_HISTOR  := SubStr(cDescSn2, 1, 40)
		SN2->N2_TIPO    := cTipo

		SN2->(MSUNLOCK())

		cDescSn2		:= SubStr(cDescSn2, 41, Len(cDescSn2))

	EndDo
	nSeqSn2 	:= 0
	cDescSn2	:= ""

	//> Grava os campos na Tabela de CADASTRO DE SALDOS E VALORES a partir das>
	//> Tabela: SN3                                                                                                                     >

	DbSelectArea("SN3")

	SN3->(DBAPPEND())
	SN3->(RLOCK())

	SN3->N3_FILIAL  := XFilial("SN3")
	SN3->N3_CBASE   := cCbase
	SN3->N3_ITEM    := cItem
	SN3->N3_SEQ     := "001"
	SN3->N3_HISTOR  := SubStr(cDescric, 1, 40)
	SN3->N3_XCHIST  := SubStr(cDescric, 1, 200)
	SN3->N3_TIPO    := cTipo

	SN3->N3_CCONTAB := cCContab
	SN3->N3_CUSTBEM := cCCusto
	SN3->N3_CCUSTO  := cCCusto
	SN3->N3_CCDEPR  := cCCDepAc
	SN3->N3_CDEPREC := cCDespDe
	SN3->N3_CDESP   := cCDespDe
	SN3->N3_DINDEPR := dDtProc

	SN3->N3_VORIG1  := nValor
	SN3->N3_VORIG4  := ConvMoeda(nValor, '4')

	SN3->N3_TXDEPR1 := nTxDepr
	SN3->N3_TXDEPR2 := nTxDepr
	SN3->N3_TXDEPR3 := nTxDepr
	SN3->N3_TXDEPR4 := nTxDepr
	SN3->N3_TXDEPR5 := nTxDepr

	SN3->N3_VRDACM1 := nVDepr
	SN3->N3_VRDACM4 := ConvMoeda(nVDepr, '4')

	SN3->N3_VRDMES1 := nDepMes
	SN3->N3_VRDMES4 := ConvMoeda(nDepMes, '4')

	SN3->N3_AQUISIC	:= dAquisic
	SN3->N3_SEQ     := "001"

	SN3->(MSUNLOCK())

	//> Tabela: SN4 - Grava os campos na Tabela de MOVIMENTACOES DO ATIVO FIXO
	DbSelectArea("SN4")

	//> Inserindo Registro
	//| N4_TIPOCNT 	:= '1' - Conta do Bem
	//| N4_OCORR	:= '05' - Implantacao
	SN4->(DBAPPEND())
	SN4->(RLOCK())

	SN4->N4_FILIAL  := xFilial("SN4")
	SN4->N4_CBASE   := cCbase
	SN4->N4_ITEM    := cItem
	SN4->N4_TIPO    := cTipo
	SN4->N4_OCORR   := "05"
	SN4->N4_TIPOCNT := "1"
	SN4->N4_CONTA   := cCCDepAc
	SN4->N4_DATA    := dAquisic
	SN4->N4_QUANTD  := 1
	SN4->N4_VLROC1  := nValor
	SN4->N4_VLROC4  := ConvMoeda(nValor, '4')
	SN4->N4_TXMEDIA := 0
	SN4->N4_TXDEPR  := 0
	SN4->N4_CCUSTO  := cCCusto
	SN4->N4_SEQ     := "001"

	SN4->(MSUNLOCK())

	If nTxDepr <> 0 .And. nFatorDp <> 0 //| Tem que possuir as Taxas

		//> Inserindo Registro
		//| N4_TIPOCNT 	:= '3' - Despesa Depreciacao
		//| N4_OCORR	:= '06' - Depreciacao
		SN4->(DBAPPEND())
		SN4->(RLOCK())

		SN4->N4_FILIAL  := xFilial("Sn4")
		SN4->N4_CBASE   := cCbase
		SN4->N4_ITEM    := cItem
		SN4->N4_TIPO    := cTipo
		SN4->N4_TIPOCNT := "3"
		SN4->N4_OCORR   := "06"
		SN4->N4_CONTA   := cCDespDe
		SN4->N4_DATA    := dDtProc
		SN4->N4_QUANTD  := 0
		SN4->N4_TXMEDIA := nFatorDp
		SN4->N4_TXDEPR  := nTxDepr
		SN4->N4_VLROC1  := Iif( nFatorDp > nValor, nValor, nFatorDp )
		SN4->N4_VLROC4  := ConvMoeda(Iif( nFatorDp > nValor, nValor, nFatorDp ) , '4')
		SN4->N4_CCUSTO  := cCCusto
		SN4->N4_SEQ     := "001"

		SN4->(MSUNLOCK())

		//> Inserindo Registro
		//| N4_TIPOCNT 	:= '4' - Depreciacao Acumulada
		//| N4_OCORR	:= '06' - Depreciacao
		SN4->(DBAPPEND())
		SN4->(RLOCK())

		SN4->N4_FILIAL  := xFilial("SN4")
		SN4->N4_CBASE   := cCbase
		SN4->N4_ITEM    := cItem
		SN4->N4_TIPO    := cTipo
		SN4->N4_TIPOCNT := "4"
		SN4->N4_OCORR   := "06"
		SN4->N4_CONTA   := cCCDepAc
		SN4->N4_DATA    := dDtProc
		SN4->N4_QUANTD  := 0
		SN4->N4_TXMEDIA := nFatorDp
		SN4->N4_TXDEPR  := nTxDepr
		SN4->N4_VLROC1  := Iif( nFatorDp > nValor, nValor, nFatorDp )
		SN4->N4_VLROC4  := ConvMoeda(Iif( nFatorDp > nValor, nValor, nFatorDp ) , '4')
		SN4->N4_CCUSTO  := ""
		SN4->N4_SEQ     := "001"

		SN4->(MSUNLOCK())

	EndIf

	//> Grava os campos na Tabela de ARQUIVOS DE SALDOS a partir das            >
	//> Tabela: SN5

	/*
	SN5->(DBAPPEND())
	SN5->(RLOCK())

	SN5->N5_FILIAL  := cFilial
	SN5->N5_CONTA   := cCCDepAc
	SN5->N5_DATA    := CTOD("26/02/2003")
	SN5->N5_TIPO    := cTipo
	SN5->N5_VALOR1  := nVDepr
	SN5->N5_VALOR3  := Val(Str(nVDepr/1.6462))
	SN5->N5_USERLGI := "rnA aid dsmLoti"

	SN5->(MSUNLOCK())

	//> Inserindo segundo registro
	//> Tabela: SN5

	SN5->(DBAPPEND())
	SN5->(RLOCK())

	SN5->N5_FILIAL  := cFilial
	SN5->N5_CONTA   := cCCDepAc
	SN5->N5_DATA    := CTOD("26/02/2003")
	SN5->N5_TIPO    := cTipo
	SN5->N5_VALOR1  := nValor
	SN5->N5_VALOR3  := Val(Str(nValor/1.6462))
	SN5->N5_USERLGI := "rnA aid dsmLoti"

	SN5->(MSUNLOCK())
	*/


	cLogTxt += " - Item: " + cCBase + " Importacao com Sucesso !!! " + cxEnter

	//> Leitura da proxima linha do arquivo texto.                          >

	FT_FSKIP()//	nBtLidos := fRead(nHdl,@cBuffer,nTamLin) // Leitura da proxima linha do arquivo texto

EndDo

FT_FUSE()//> O arquivo texto deve ser fechado, bem como o dialogo criado na funcao anterior.

GeraLog( cLogTxt )

Return()
*******************************************************************************
Static Function GetCodGrupo(cDe)//| Obtem o Codigo do Grupo Atraves da Especie
*******************************************************************************

Do Case
	Case cDe == "10.001"
		cPara := "0006"
	Case cDe == "10.002"
		cPara := "0006"
	Case cDe == "10.003"
		cPara := "0006"
	Case cDe == "10.004"
		cPara := "0006"
	Case cDe == "10.005"
		cPara := "0006"
	Case cDe == "10.006"
		cPara := "0006"
	Case cDe == "10.007"
		cPara := "0006"
	Case cDe == "10.008"
		cPara := "0004"
	Case cDe == "10.009"
		cPara := "0006"
	Case cDe == "10.099"
		cPara := "0006"
	Case cDe == "20.001"
		cPara := "0002"
	Case cDe == "20.002"
		cPara := "0002"
	Case cDe == "20.004"
		cPara := "0002"
	Case cDe == "20.099"
		cPara := "0002"
	Case cDe == "30.001"
		cPara := "0022"
	Case cDe == "30.002"
		cPara := "0022"
	Case cDe == "30.003"
		cPara := "0022"
	Case cDe == "30.004"
		cPara := "0022"
	Case cDe == "30.005"
		cPara := "0022"
	Case cDe == "30.006"
		cPara := "0022"
	Case cDe == "30.099"
		cPara := "0022"
	Case cDe == "40.001"
		cPara := "0006"
	Case cDe == "40.002"
		cPara := "0006"
	Case cDe == "40.003"
		cPara := "0006"
	Case cDe == "40.004"
		cPara := "0006"
	Case cDe == "50.001"
		cPara := "0016"
	Case cDe == "60.001"
		cPara := "0018"
	Case cDe == "70.001"
		cPara := "0009"
	Case cDe == "70.002"
		cPara := "0024"
	Case cDe == "70.003"
		cPara := "0023" //alterado
	OtherWise
		cPara := GetEspecie()
EndCase


Do Case
	Case cDe == "10.001"
		cDescIni := "CADEIRA"
	Case cDe == "10.002"
		cDescIni := "MESA"
	Case cDe == "10.003"
   		cDescIni := "POLTRONA"
	Case cDe == "10.004"
   		cDescIni := "ARM¡RIO"
	Case cDe == "10.005"
   		cDescIni := "COFRE"
	Case cDe == "10.006"
  		cDescIni := "CONDICIONADOR DE AR"
	Case cDe == "10.007"
  		cDescIni := "CAMA"
	Case cDe == "10.008"
  		cDescIni := "TELEVISOR"
	Case cDe == "10.009"
  		cDescIni := "FRIGOBAR"
	Case cDe == "20.001"
		cDescIni := "MICROCOMPUTADOR"
	Case cDe == "20.002"
		cDescIni := "IMPRESSORA"
	Case cDe == "20.004"
   		cDescIni := "MONITOR"
	Case cDe == "20.005"
   		cDescIni := "COFRE"
	Case cDe == "20.006"
  		cDescIni := "CONDICIONADOR DE AR"
	Case cDe == "30.001"
		cDescIni := "MONITOR MEDICO"
	Case cDe == "30.002"
		cDescIni := "OXIMETRO"
	Case cDe == "30.003"
   		cDescIni := "RESPIRADOR"
	Case cDe == "30.004"
   		cDescIni := "CARRO ANESTESIA"
	Case cDe == "40.002"
		cDescIni := "BALAN«A"
	Case cDe == "40.003"
   		cDescIni := "BOMBA"
	Case cDe == "40.004"
   		cDescIni := "COMPRESSOR"
	Case cDe == "60.001"
		cDescIni := "PREDIO"
	Case cDe == "70.001"
		cDescIni := "LICEN«A SOFTWARE"
	Case cDe == "70.002"
		cDescIni := "INSTALACOES"
	Case cDe == "70.003"
   		cDescIni := "CENTRAL TELEFONICA"
   OtherWise
		cDescIni := ""
EndCase

Return(cPara)
*******************************************************************************
Static Function GetEspecie()//| Obtem o Codigo do Grupo Atraves do Codigo Base
*******************************************************************************
Local cEspecie := ""

Do Case

	Case cCBase == 	'HU00100058'
		cEspecie := "0006"
	Case cCBase == 	'HU00100059'
		cEspecie := "0006"
	Case cCBase == 	'HU00100060'
		cEspecie := "0006"
	Case cCBase == "HU00002015"
		cEspecie := "0006"
	Case cCBase == "HU00000518"
		cEspecie := "0006"
	Case cCBase == "HU00001949"
		cEspecie := "0006"
	Case cCBase == "HU00001966"
		cEspecie := "0022"
	Case cCBase == "HU00001967"
		cEspecie := "0022"
	Case cCBase == "HU00001968"
		cEspecie := "0022"
	Case cCBase == "HU00001969"
		cEspecie := "0022"
	Case cCBase == "HU00001970"
		cEspecie := "0006"
	Case cCBase == "HU00001971"
		cEspecie := "0006"
	Case cCBase == "HU00001972"
		cEspecie := "0006"
	Case cCBase == "HU00001973"
		cEspecie := "0006"
	Case cCBase == "HU00001974"
		cEspecie := "0006"
	Case cCBase == "HU00001975"
		cEspecie := "0006"
	Case cCBase == "HU00001976"
		cEspecie := "0006"
	Case cCBase == "HU00001977"
		cEspecie := "0006"
	Case cCBase == "HU00001978"
		cEspecie := "0006"
	Case cCBase == "HU00001979"
		cEspecie := "0022"
	Case cCBase == "HU00001980"
		cEspecie := "0022"
	Case cCBase == "HU00001981"
		cEspecie := "0004"
	Case cCBase == "HU00001982"
		cEspecie := "0006"
	Case cCBase == "HU00001983"
		cEspecie := "0006"
	Case cCBase == "HU00001984"
		cEspecie := "0006"
	Case cCBase == "HU00001985"
		cEspecie := "0006"
	Case cCBase == "HU00001986"
		cEspecie := "0006"
	Case cCBase == "HU00001987"
		cEspecie := "0006"
	Case cCBase == "HU00001988"
		cEspecie := "0006"
	Case cCBase == "HU00001989"
		cEspecie := "0022"
	Case cCBase == "HU00001990"
		cEspecie := "0022"
	Case cCBase == "HU00001991"
		cEspecie := "0022"
	Case cCBase == "HU00001992"
		cEspecie := "0006"
	Case cCBase == "HU00001993"
		cEspecie := "0006"
	Case cCBase == "HU00001994"
		cEspecie := "0006"
	Case cCBase == "HU00001995"
		cEspecie := "0006"
	Case cCBase == "HU00001996"
		cEspecie := "0006"
	Case cCBase == "HU00001997"
		cEspecie := "0006"
	Case cCBase == "HU00001998"
		cEspecie := "0006"
	Case cCBase == "HU00001999"
		cEspecie := "0006"
	Case cCBase == "HU00002000"
		cEspecie := "0006"
	Case cCBase == "HU00002001"
		cEspecie := "0006"
	Case cCBase == "HU00002002"
		cEspecie := "0006"
	Case cCBase == "HU00002003"
		cEspecie := "0006"
	Case cCBase == "HU00002004"
		cEspecie := "0006"
	Case cCBase == "HU00002005"
		cEspecie := "0004"
	Case cCBase == "HU00100193"
		cEspecie := "0022"
	Case cCBase == "HU00100194"
		cEspecie := "0022"
	OtherWise
		cEspecie := ""
EndCase

Return(cEspecie)
*******************************************************************************
Static Function FGetcCus(cDe)//| DE: Conta Gerencial PARA: Centro de Custo
*******************************************************************************
Local cPara := ""

Do Case
	Case cDe == "30"
		cPara := "11801" //| Bloco Cirurgico
	Case cDe == "247"
		cPara := "11802" //| CTI Adulto
	Case cDe == "1979"
		cPara := "11803" //| CTI Neo
	Case cDe == "218"
		cPara := "11804" //| Unidade A
	Case cDe == "224"
		cPara := "11805" //| Unidade B
	Case cDe == "483"
		cPara := "11806" //| Centro de DiagnÛstico
	Case cDe == "1985"
		cPara := "11807" //| Endoscopia
	Case cDe == "454"
		cPara := "11806" //| Centro de DiagnÛstico
	Case cDe == "721"
		cPara := "11806" //| Centro de DiagnÛstico
	Case cDe == "282"
		cPara := "11808" //| Oncologia
	Case cDe == "253"
		cPara := "11809" //| Recepcao
	Case cDe == "260"
		cPara := "11810" //| Nutricao
	Case cDe == "5782"
		cPara := "11811" //| Higienizacao
	Case cDe == "738"
		cPara := "11812" //| Manutencao
	Case cDe == "313"
		cPara := "11813" //| Farm·cia
	Case cDe == "52"
		cPara := "11801" //| Bloco Cirurgico
	Case cDe == "394"
		cPara := "11890" //| Administracao Hospital
	Case cDe == "307"
		cPara := "11890" //| Administracao Hospital
	Case cDe == "371"
		cPara := "11890" //| Administracao Hospital
	Case cDe == "626"
		cPara := "11890" //| Administracao Hospital
	Case cDe == "431"
		cPara := "11890" //| Administracao Hospital
	Case cDe == "796"
		cPara := "11890" //| Administracao Hospital
	Case cDe == "336"
		cPara := "11890" //| Administracao Hospital
	Case cDe == "320"
		cPara := "11899" //| Gerais Hospital Unimed
	OtherWise
		cPara := ""
EndCase

Return(cPara)
*******************************************************************************
Static Function FGetConRL(cDe)//| DE: Conta Contabil Valor Original  PARA: Conta Contabil Reavaliado
*******************************************************************************
Local cPara := ""

Do Case

//	Case cDe == "1333291000001"
//		cPara := ""
	Case cDe == "1334191100001"
		cPara := "1334191100002"
	Case cDe == "1331191100001"
		cPara := "1331192100001"
	Case cDe == "1331191100001"
		cPara := "1331192100001"
	Case cDe == "1331191200001"
		cPara := "1331192200001"
	Case cDe == "1331199100001"
		cPara := "1331199200001"
	Case cDe == "1335191000001"
		cPara := "1335192000001"
	Case cDe == "1333191000001"
		cPara := "1333192000001"
	Case cDe == "1333191000002"
		cPara := "1333192000002"
	Case cDe == "1335191000001"
		cPara := "1335192000001"
	Case cDe == "1332191000001"
		cPara := "1332292000001"
	Case cDe == "1333191000001"
		cPara := "1333192000001"
	Case cDe == "1335191000001"
		cPara := "1335192000001"
	Case cDe == "1341291200001"
		cPara := "1341291200002"
	Case cDe == "1335199100001"
		cPara := "1335199200001"
	Case cDe == "1333199100001"
		cPara := "1333199200001"
	Case cDe == "1335199100001"
		cPara := "1335199200001"
	Case cDe == "1332199100001"
		cPara := "1332199200001"
	Case cDe == "1334199100001"
		cPara := "1334199100002"
	Case cDe == "1333199100002"
		cPara := "1333299200001"
	Case cDe == "1341299200001"
		cPara := "1341299200002"
	EndCase

Return(cPara)
*******************************************************************************
Static Function FGetConta(cDe)//| DE: Codigo da Conta PARA: Conta Contabil
*******************************************************************************
Local cPara := ""

Do Case
	Case cDe == "13020101"
		cPara := "1322291110001"	//| Terreno do Hospital
	Case cDe == "13020102"
		cPara := "1322291120004"	//| Predio do Hospital de Novo Hamburgo - HUVS
	Case cDe == "13020103"
		cPara := "1322291210001"	//| Terrenos Reavaliados
	Case cDe == "13020104"
		cPara := "1322291220002"	//| Reavaliacao Predio HUVS
	Case cDe == "13030102"
		cPara := "1322291910004"	//| (-) Deprec.Acum.do Predio HUVS	711119000130700.1
	Case cDe == "13030103"
		cPara := "1322291920001"	//| (-) Deprec.Acum.do Predio Reavaliado-HUVS	711119000
	Case cDe == "13020201"
		cPara := "1322691100001"	//| Moveis e Utensilios (Calc. E Ar Condic.)
	Case cDe == "13020202"
		cPara := "1322491100001"	//| Equipamentos e Utensilios Medicos
	Case cDe == "13020203"
		cPara := "1322691100001"	//| Moveis e Utensilios (Calc. E Ar Condic.)
	Case cDe == "13020204"
		cPara := "1322391100001"	//| Instalacoes (Cortinas e Divisorias)
	Case cDe == "13020205"
		cPara := "1322691100001"	//| Moveis e Utensilios (Calc. E Ar Condic.)
	Case cDe == "13020206"
		cPara := "1322591110001"	//| Equipamentos de Informatica
	Case cDe == "13020213"
		cPara := "1322591110002"	//| Reavaliacao de Equip. de Informatica
	Case cDe == "13020207"
		cPara := "1322491100002"	//| Equip. de Comunicacao (Central Telefonica)
	Case cDe == "13020208"
		cPara := "1322491100001"	//| Equipamentos e Utensilios Medicos
	Case cDe == "13020209"
		cPara := "1322691200001"	//| Reavaliacao Mov. E Utens. (Calc e Ar Cond)
	Case cDe == "13020210"
		cPara := "1322491200001"	//| Reavaliacao - Equip. e Utensilios Medicos
	Case cDe == "13020214"
		cPara := "1322491200002"	//| Reavaliacao Equipamentos de comunicacao
	Case cDe == "13020211"
		cPara := "1322691200001"	//| Reavaliacao Mov. E Utens. (Calc e Ar Cond)
	Case cDe == "13020212"
		cPara := "1322392200001"	//| Reavaliacao de Instalacoes
	Case cDe == "13020215"
		cPara := "1322491200001"	//| Reavaliacao - Equip. e Utensilios Medicos
	Case cDe == "13020216"
		cPara := "1322691200001"	//| Reavaliacao Mov. E Utens. (Calc e Ar Cond)
	Case cDe == "13040101"
		cPara := "1323192120001"	//| Direito de Uso de Software
	Case cDe == "13040103"
		cPara := "1323192120002"	//| Reavaliacao Direito de uso de Software
	Case cDe == "13030201"
		cPara := "1322691910001"	//|(-) Moveis e Utensilios	711119000130700.1
	Case cDe == "13030202"
		cPara := "1322491910001"	//|(-) Equipamentos e Utensilios Medicos	7111190001307
	Case cDe == "13030203"
		cPara := "1322691910001"	//|(-) Moveis e Utensilios	711119000130700.1
	Case cDe == "13030204"
		cPara := "1322391910001"	//|(-) Instalacoes	711119000130700.1
	Case cDe == "13030205"
		cPara := "1322691910001"	//|(-) Moveis e Utensilios	711119000130700.1
	Case cDe == "13030206"
		cPara := "1322591910001"	//|(-) Equipamentos de Informatica	711119000130700.1
	Case cDe == "13030207"
		cPara := "1322491910002"	//|(-) Equipamentos de Comunicacao	711119000130700.1
	Case cDe == "13030208"
		cPara := "1322491910001"	//|(-) Equipamentos e Utensilios Medicos	7111190001307
	Case cDe == "13030209"
		cPara := "1322691920001"	//|(-) Moveis e Utensilios Reavaliacao	711119000130700.2
	Case cDe == "13030210"
		cPara := "1322491920001"	//|(-) Equipamentos e Utensilios Medicos	7111190001307
	Case cDe == "13030211"
		cPara := "1322691920001"	//|(-) Moveis e Utensilios Reavaliacao	711119000130700.2
	Case cDe == "13030212"
		cPara := "1322391920001"	//|(-) Instalacoes Reavaliacao	711119000130700.2
	Case cDe == "13030213"
		cPara := "1322591910002"	//|(-) Equipamentos de Infor. reavaliacao	7111190001307
	Case cDe == "13030214"
		cPara := "1322492920001"	//|(-) Equip. de comunicacao reavaliacao	7111190001307
	Case cDe == "13040201"
		cPara := "1323192920001"	//|(-) Direito de Uso de Software	711119000130700.1
	Case cDe == "13040202"
		cPara := "1323192920002"	//|(-) Reavaliacao Direito de Software	711119000130700.2
	OtherWise
		cPara := cDe

EndCase

// Ajuste Norma IN36
cSql := "SELECT CTA_PARA FROM DEPARACT1IN36 WHERE CTA_DE = "+cPara

U_MyQuery( cSql , "DEPARA" )

cPara := DEPARA->CTA_PARA

DbCloseArea("DEPARA")

Return(cPara)
*******************************************************************************
Static Function FGetTxdep(cGrupo)//Recebe o codigo do grupo e retorna a descricao
*******************************************************************************
Local nTx := 0

cGrupo := upper(cGrupo)

DbSelectArea("SNG")
DbSeek(xFilial("SNG")+cGrupo,.F.)

nTx := SNG->NG_TXDEPR1

Return (nTx)
*******************************************************************************
Static Function FGetTipo(cDe)
*******************************************************************************
//| Tipos v·lidos:
//| 01 - Aquisicao
//| 02 - Reavaliacao
//| 03 - Adiantamento
//| 04 - Lei 8.200

cPara := ""

Do Case
	Case cDe == "VO"
		cPara := "01"
	Case cDe == "AD"
		cPara := "03"
	Case cDe == "DE"
		cPara := "04"
	OtherWise
		cPara := "02"
EndCase

Return(cPara)
*******************************************************************************
Static Function IncItem(cCodBase)//| Incrementa o Item
*******************************************************************************
sItem := '0001'

nRecno := SN1->(Recno())
SN1->(dbSetOrder(1))
SN1->(dbGoTop())

IF SN1->(dbSeek( xFilial("SN1") + cCodBase ))
	lExiste := .T.
ELSE
	lExiste := .F.
ENDIF

if !lExiste
	SN1->(dbGoto(nRecno))
	Return(sItem)
EndIf

While SN1->(!EOF()) .and. Alltrim(SN1->N1_CBASE) == Alltrim(cCodBase) .and. SN1->N1_FILIAL == xFilial("SN1")

	If Alltrim(SN1->N1_CBASE) == Alltrim(cCodBase) .and. SN1->N1_FILIAL == xFilial("SN1")
		sItem := SN1->N1_ITEM
		SN1->(dbSkip())
		Loop
	Endif

EndDo

sItem := ALLTRIM( STRZERO(VAL(sItem) + 1, 4))
SN1->(dbGoto(nRecno))
Return( sItem )

Return()
*******************************************************************************
Static Function FGetLoc(XcCusto)
*******************************************************************************

// Ajuste Norma IN36
cSql := "SELECT Z3_COD FROM SZ3010 WHERE Z3_CCUSTO = '"+ XcCusto +"' AND D_E_L_E_T_ = ' ' "

U_MyQuery( cSql , "XLO" )


Return(XLO->Z3_COD)
*******************************************************************************
Static Function NumMes(dDataI)
*******************************************************************************
Local DDataF := dDtProc

Local nMonthI := Month(DDataI)
Local nMonthF := Month(DDataF)
Local nMonthT := nMonthF - nMonthI

Local nYearI := Year(dDataI)
Local nYearF := Year(DDataF)
Local nYearT := nYearF - nYearI

nResult := (nYearT * 12) + nMonthT

Return(nResult + 1)        // Numero de Meses
*******************************************************************************
Static Function ConvMoeda(nVal, nCMoeda)
*******************************************************************************
//|xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,1,dData)
cData 	:= Dtos(dDtProc)
cCampo 	:= "SM2->M2_MOEDA" + nCMoeda

DbSelectArea("SM2")
If DbSeek(cData,.F.)
	nVal := nVal / &cCampo.
Endif

Return(nVal)
*******************************************************************************
Static Function CalcDepr()
*******************************************************************************
Return()
*******************************************************************************
Static Function GeraLog( cLogTxt )
*******************************************************************************
__cFileLog := MemoWrite(Criatrab(,.F.)+".LOG",cLogTxt)

Define FONT oFont NAME "Tahoma" Size 6,12
Define MsDialog oDlgMemo Title "Importacao Concluida." From 3,0 to 340,550 Pixel

@ 5,5 Get oMemo  Var cLogTxt MEMO Size 265,145 Of oDlgMemo Pixel
oMemo:bRClicked := {||AllwaysTrue()}
oMemo:oFont:=oFont
Define SButton  From 153,205 Type 13 Action ({oDlgMemo:End(),Mysend(cLogTxt)}) Enable Of oDlgMemo Pixel
Define SButton  From 153,235 Type 1 Action oDlgMemo:End() Enable Of oDlgMemo Pixel

Activate MsDialog oDlgMemo Center

Return()
*******************************************************************************
Static Function Mysend(cTxt)
*******************************************************************************
Static oDlg
Static oButton1
Static oButton2
Static oGet1
Static cGet1 := Space(200)
Static oSay

DEFINE MSDIALOG oDlg TITLE "Form" FROM 000, 000  TO 150, 300 COLORS 0, 12632256 PIXEL

@ 031, 015 MSGET oGet1 VAR cGet1 SIZE 114, 010 OF oDlg PICTURE "@!" VALID !Empty(Alltrim(cGet1)) COLORS 0, 16777215 PIXEL
@ 016, 015 SAY oSay PROMPT "Por favor, entre com seu email ABAIXO:" SIZE 100, 007 OF oDlg PICTURE "@!" COLORS 0, 12632256 PIXEL

@ 050, 025 BUTTON oButton1 PROMPT "Enviar" SIZE 040, 012 OF oDlg ACTION {||oDlg:End(),DISMAILX(cGet1,cTxt)} PIXEL
@ 050, 075 BUTTON oButton2 PROMPT "Sair" SIZE 040, 012 OF oDlg ACTION oDlg:End()  PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

Return
*******************************************************************************
Static Function DISMAILX(cMail,cTxt)
*******************************************************************************

CONNECT SMTP SERVER GETMV("MV_RELSERV") ACCOUNT GETMV("MV_RELACNT") PASSWORD GETMV("MV_RELPSW") RESULT lResult

If !lResult
	MsgBox('Erro no Envio')
	Return()
EndIf

cAccount := GETMV("MV_RELACNT")

SEND MAIL FROM cAccount 	;
TO      cMail	        	;
SUBJECT "Log Importacao Ativo" 	;
BODY cTxt

DISCONNECT SMTP SERVER

MsgBox("Email Enviado com Sucesso!")

Return()