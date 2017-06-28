#INCLUDE 'FATA210.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'FONT.CH'
#DEFINE  ENTER CHR(13)+CHR(10)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FT210OPC    ³ Autor ³RAFAEL L. SCHEIBLER  ³ Data ³  /  /    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este ponto de entrada é executado apos a confirmação da     ³±±
±±³          ³liberação do pedido de venda por regra e antes do inicio da ³±±
±±³          ³transação.												  ³±±
±±³          ³Seu objetivo é permitir a interrupção do&nbsp;processo, 	  ³±±
±±³          ³mesmo com a confirmação do usuário. 						  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ESPECIFICO PARA O CLIENTE IMDEPA						      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
*********************************************************************
User Function FT210OPC()
	*********************************************************************
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ESTE PONTO DE ENTRADA é EXECUTADO APOS A CONFIRMAçãO DA LIBERAçãO DO PEDIDO DE VENDA POR REGRA E ANTES DO INICIO DA TRANSAçãO. 	|
	//|	SEU OBJETIVO é PERMITIR A INTERRUPçãO DO PROCESSO, MESMO COM A CONFIRMAçãO DO USUáRIO.                                         	|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cMsg 			:= 	''
	Local nRetOpcao		:= 	0
	Local lGerente 	 	:=	IIF(Type('ParamIxb')== 'A', IIF(Len(ParamIxb)>=1, ParamIxb[01], .F.), .F.)
	Local lFinanceiro	:=	IIF(Type('ParamIxb')== 'A', IIF(Len(ParamIxb)>=2, ParamIxb[02], .F.), .F.)
	Local lDiretor	 	:=	IIF(Type('ParamIxb')== 'A', IIF(Len(ParamIxb)>=3, ParamIxb[03], .F.), .F.)
	Local lLiberGer	 	:=	IIF(Type('ParamIxb')== 'A', IIF(Len(ParamIxb)>=4, ParamIxb[04], .F.), .F.)
	Local lLiberFin	 	:=	IIF(Type('ParamIxb')== 'A', IIF(Len(ParamIxb)>=5, ParamIxb[05], .F.), .F.)
	Local lRegAtiva	 	:=	IIF(Type('ParamIxb')== 'A', IIF(Len(ParamIxb)>=6, ParamIxb[06], .F.), .F.)
	Local cTpBloq	 	:=	IIF(Type('ParamIxb')== 'A', IIF(Len(ParamIxb)>=7, ParamIxb[07], 'AMBOS'), 'AMBOS')
	Local lCancel		:=	.F.

	Private lFilGer		:=	lLiberGer
	Private lFilFin	 	:=	lLiberFin

	Private cLibNiv1	:=	''
	Private cLibNiv2	:=	''
	Private cLibNiv3	:=	''


	Private nVlrIMCMin	:= 	0
	Private nVlrIMCRMin := 	0
	Private nVlrMinPV	:= 	0
	Private lLiberaPV	:=	.F.
	Private aChkLiber	:=	{}
	Private aBloqRegra	:=	{}
	Private aDiretor	:=	{}
	Private aGerente	:=	{}
	Private aDesconto	:=	{}


	// 1=IMC; 2=IMCR; 3=AMBOS
	Private lChkIMC  	:= 	IIF(cTpBloq == '1',	.T., .F.)		//	1=IMC
	Private lChkIMCR 	:= 	IIF(cTpBloq == '2',	.T., .F.)		//	2=IMCR
	Private lChkAmbos	:=	IIF(cTpBloq == 'AMBOS',	.T., .F.)	//	3=AMBOS
	Private cBlqIMC		:=	IIF(cTpBloq == 'AMBOS', 'IMC e IMCR', IIF(cTpBloq=='1', 'IMC', 'IMCR'))



	If FunName() == 'DLGA150'
		Return()
	EndIf


	SetKey(K_ALT_F1,  {|| U_HelpLibPV() })


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  ChkLevelUp()                          ³
	//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
	//|  VERIFICA SE LIBERACAO DO PV IRA PARA  |
	//|  FINANCEIRO \ DIRETOR				   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRegAtiva .And. lGerente

		aChkLiber	:=	ChkLevelUp()
		lLiberGer 	:= 	aChkLiber[01]
		lLiberDir	:= 	aChkLiber[02]
		lLiberAll	:=	lLiberGer .And. lLiberDir
		lLiberAll	:=	IIF(!lRegAtiva, .T., lLiberAll)

	Else
		aChkLiber	:=	ChkLevelUp()
		lLiberAll	:=	.T.
	EndIf





	Do Case

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  GERENTE OU LIBERANDO COMO GERENTE     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case lGerente .Or. lFilGer

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³      APENAS GERENTE OU LIBERANDO COMO GERENTE                                                       ³
		//³                                                                                                     ³
		//³  O GERENTE DE VENDAS FARá UMA ANáLISE DO PEDIDO COMO UM TODO, ENGLOBANDO                       		³
		//³  TODOS OS ITENS DO PEDIDO DE VENDA E COMPARANDO COM UMA TABELA CONTENDO A                      		³
		//³  MARGEM MíNIMA POR FILIAL + CANAL.   >> TABELA ZGV                                             		³
		//³  ELE PODERá LIBERAR O PEDIDO SE O MESMO ATENDER AO REQUISITO DE ESTAR ACIMA                    		³
		//³  OU IGUAL A ESTA MARGEM MíNIMA. (PRIMEIRO IF)                                                  		³
		//³  PEDIDOS EM QUE O VALOR TOTAL AINDA NãO CHEGA à MARGEM MíNIMA DETERMINADA NA                   		³
		//³  TABELA DE MARGENS POR FILIAL+CANAL SERãO "ESCALADOS" PARA A DIRETORIA E FINANCEIRO,           		³
		//³  DESDE QUE O VALOR TOTAL DO PEDIDO DE VENDA SEJA SUPERIOR à R$ 2.000,00 (VALOR PARAMETRIZADO). 		³
		//³  (SEGUNDO IF)                                                                                  		³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lLiberAll
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  NAO TEM BLOQUEIO - IMC/IMCR/AMBOS ESTAO OK - LIBERAR PEDIDO	  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If TelaBloq('GERENTE')
				cLibNiv1 :=	'L'
				cLibNiv2 :=	'L'
				cLibNiv3 :=	'L'
				GravaC5Lib(cLibNiv1, cLibNiv2, cLibNiv3)
			Else
				lCancel := .T.
			EndIf

		Else

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  IMC\IMCR\AMBOS MENOR QUE O PERMITIDO E VALOR PV MENOR QUE O VLR.MINIMO (ZGV_VLRMIN)	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !TelaBloq('GERENTE')

				cLibNiv1 :=	'B'
				cLibNiv2 :=	'B'
				cLibNiv3 :=	'B'
				lCancel  := .T.

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³  GERENTE NAO LIBERA PV - BLOQUEIA TODOS OS NIVEIS	³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				GravaC5Lib(cLibNiv1, cLibNiv2, cLibNiv3)

			Else

				cLibNiv1 :=	'L'
				cLibNiv2 := 'B'
				cLibNiv3 := 'B'

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³  GERENTE LIBERA PV - LIBERA NIVEL GERENTE E AGUARDA DIRETOR\FINANCEIRO LIBERAR	³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				GravaC5Lib(cLibNiv1, cLibNiv2, cLibNiv3)
				EnvEmail(SC5->C5_FILIAL, SC5->C5_NUM, SC5->C5_CLIENTE, SC5->C5_LOJACLI)

			EndIf

		EndIf


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  FINANCEIRO OU LIBERANDO COMO DIRETOR	 	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case lFinanceiro .Or. lFilFin

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ OS PEDIDOS Já ANALISADOS PELO GERENTE (E APROVADOS POR ELE, PORéM, SEM ATENDER à REGRA DE MARGEM MíNIMA)            	³
		//³	CHEGARãO à DIRETORIA E FINANCEIRO, E ONDE AMBOS DEVERãO ANALISAR O PEDIDO DE VENDA, PARA O MESMO SER LIBERADO OU NãO. 	³
		//³	NESTE NíVEL, NãO HAVERá LIMITES PARA A APROVAçãO. APROVAçãO COMPARTILHADA ENTRE DIRETORIA E GERENTE.                  	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lLiberAll
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  NAO TEM BLOQUEIO - IMC/IMCR/AMBOS ESTAO OK - LIBERAR PEDIDO	  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If TelaBloq('FINANCEIRO')
				cLibNiv1 :=	'L'
				cLibNiv2 := 'L'
				cLibNiv3 := 'L'
				GravaC5Lib(cLibNiv1, cLibNiv2, cLibNiv3)
			Else
				lCancel := .T.
			EndIf

		Else


			If TelaBloq('FINANCEIRO')
				cLibNiv1 :=	'L'
				cLibNiv2 :=	'L'
				cLibNiv3 :=	'L'
				GravaC5Lib(cLibNiv1, cLibNiv2, cLibNiv3)
			Else
				lCancel := .T.
			EndIf

		EndIf


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  	   DIRETOR	 	 	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case lDiretor

		If lLiberAll
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  NAO TEM BLOQUEIO - IMC/IMCR/AMBOS ESTAO OK - LIBERAR PEDIDO	  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If TelaBloq('DIRETOR')
				cLibNiv1 :=	'L'
				cLibNiv2 := 'L'
				cLibNiv3 := 'L'
				GravaC5Lib(cLibNiv1, cLibNiv2, cLibNiv3)
			Else
				lCancel := .T.
			EndIf

		Else

			If TelaBloq('DIRETOR')
				cLibNiv1 :=	'L'
				cLibNiv2 := 'L'
				cLibNiv3 := 'L'
				GravaC5Lib(cLibNiv1, cLibNiv2, cLibNiv3)
			Else
				lCancel := .T.
			Endif

		EndIf

	EndCase



	If !lCancel

		If SC5->C5_LIBRNV1 == 'L' .And. SC5->C5_LIBRNV2 == 'B' .And. (SC5->C5_LIBRNV3 == 'B' .Or. SC5->C5_LIBRNV3 == 'L')
			lLiberaPV	:=	.F.
			cMsg 		:= 	"PEDIDO "+SC5->C5_NUM+" ENCAMINHADO PARA A LIBERAÇÃO DO SETOR FINANCEIRO / DIRETORIA"

		ElseIf SC5->C5_LIBRNV1 == 'L' .And. SC5->C5_LIBRNV2 == 'L' .And. SC5->C5_LIBRNV3 == 'L'
			lLiberaPV	:=	.T.
			cMsg 		:= 	"PEDIDO "+SC5->C5_NUM+" SERÁ LIBERADO "
		EndIf


		If !Empty(cMsg)
			MsgAlert(cMsg, 'Liberação Pedido')
		EndIf

	EndIf


	SetKey(K_ALT_F1,  {||  })
	Return(lLiberaPV)
	*********************************************************************
Static Function GravaC5Lib(cLibNiv1, cLibNiv2, cLibNiv3)
	*********************************************************************
	DbSelectArea('SC5')
	RecLock('SC5', .F.)
	SC5->C5_LIBRNV1	:= cLibNiv1 	//	Liberado como Gerente
	SC5->C5_LIBRNV2	:= cLibNiv2 	//	Liberado como Financeiro (nao escalou)
	SC5->C5_LIBRNV3	:= cLibNiv3 	//	Liberado como Diretor (nao escalou)
	MsUnLock()

	Return()
	*************************************************************************
Static Function ChkLevelUp()
	*************************************************************************
	Local aStru			:=	{}
	Local aTravaM		:=	{}
	Local lLiberGer		:=	.F.
	Local lLiberDir		:=	.F.
	Local lNextLevel	:=	.F.

	aDiretor	:=	{}
	aGerente	:=	{}
	aDesconto	:=	{}

	IIF(!ExisteSX6('IMD_TMIMC'),	CriarSX6('IMD_TMIMC', 'L','Bloq.Trava Master por IMC - FT210OPC.PRW', 	'.T.' ),)
	lMvIMC_TM := GetMv('IMD_TMIMC')
	IIF(!ExisteSX6('IMD_TMIMCR'),	CriarSX6('IMD_TMIMCR', 'L','Bloq.Trava Master por IMCR - FT210OPC.PRW', '.F.' ),)
	lMvIMCR_TM := GetMv('IMD_TMIMCR')
	IIF(!ExisteSX6('IMD_IMCOUR'),	CriarSX6('IMD_IMCOUR', 'L','Bloq.Trava Master por IMC OU IMCR - FT210OPC.PRW', '.F.' ),)
	lIMCouIMCR := GetMv('IMD_IMCOUR')


	IIF(!ExisteSX6('IMD_MINIMC'),	CriarSX6('IMD_MINIMC', 'N','Valor minimo IMC - PE_TMKVFIM.PRW', '-10' ),)
	nMvImcMin:=	GetMv('IMD_MINIMC')				// 0
	IIF(!ExisteSX6('IMD_MIIMCR'),	CriarSX6('IMD_MIIMCR', 'N','Valor minimo IMCR - PE_TMKVFIM.PRW', '-10' ),)
	nMvImcRMin	:=	GetMv('IMD_MIIMCR')			// 0


	If Select('TMPDET') > 0
		DbSelectArea('TMPDET')
		RecLock('TMPDET', .F.)
		Zap
		MsUnLock()
	Else



		Aadd(aStru,{"ITEM" 	 	, "C"	, TamSx3('UB_ITEM')[01], 	TamSx3('UB_ITEM')[02] 	})
		Aadd(aStru,{"CODIGO" 	, "C"	, TamSx3('B1_COD')[01],		TamSx3('B1_COD')[02]	})
		Aadd(aStru,{"DESCRI" 	, "C"	, TamSx3('B1_DESC')[01], 	TamSx3('B1_DESC')[02]	})
		Aadd(aStru,{"PROMO"  	, "C"	, TamSx3('B1_OBSTPES')[01], TamSx3('B1_OBSTPES')[02]})
		Aadd(aStru,{"IDADE" 	, "N"	, TamSx3('UB_IDADE')[01], 	TamSx3('UB_IDADE')[02]	})
		Aadd(aStru,{"IMCPROD"	, "N"	, TamSx3('UB_IMC')[01], 	TamSx3('UB_IMC')[02]	})
		Aadd(aStru,{"MRK_MIN" 	, "N"	, TamSx3('UB_IMC')[01], 	TamSx3('UB_IMC')[02]	}) //TamSx3('IM1_IMCMIN')[01], TamSx3('IM1_IMCMIN')[02]})
		Aadd(aStru,{"IMCPED" 	, "N"	, TamSx3('UA_IMC')[01], 	TamSx3('UA_IMC')[02]	})
		Aadd(aStru,{"IMCRPROD"	, "N"	, TamSx3('UB_IMCR')[01], 	TamSx3('UB_IMCR')[02]	})
		Aadd(aStru,{"IMCRPERM" 	, "N"	, TamSx3('ZGV_IMCRMI')[01], TamSx3('ZGV_IMCRMI')[02]})
		Aadd(aStru,{"IMCRPED" 	, "N"	, TamSx3('UA_IMCR')[01], 	TamSx3('UA_IMCR')[02]	})
		Aadd(aStru,{"TRAVAM" 	, "N"	, TamSx3('UA_IMCR')[01], 	TamSx3('UA_IMCR')[02]	})
		Aadd(aStru,{"VLRPERM" 	, "N"	, TamSx3('ZGV_VLRMIN')[01],	TamSx3('ZGV_VLRMIN')[02]})
		Aadd(aStru,{"LIBER"  	, "C"	, 007, 00 })


		Aadd(aStru,{"VLRPED" 	, "N"	, TamSx3('UA_VLRLIQ')[01], 	TamSx3('UA_VLRLIQ')[02]	})
		Aadd(aStru,{"IMCPERM" 	, "N"	, TamSx3('ZGV_IMCMIN')[01], TamSx3('ZGV_IMCMIN')[02]})
		Aadd(aStru,{"DESCVEN"	, "N"	, TamSx3('UB_DESCVEN')[01], TamSx3('UB_DESCVEN')[02]})
		Aadd(aStru,{"DESCREG"	, "N"	, TamSx3('UB_DESCRD')[01], 	TamSx3('UB_DESCRD')[02]	})
		Aadd(aStru,{"DESCMAX"	, "N"	, TamSx3('UB_DESCRD')[01], 	TamSx3('UB_DESCRD')[02]	})
		Aadd(aStru,{"TABPRC" 	, "C"	, TamSx3('UB_TABPRC')[01], 	TamSx3('UB_TABPRC')[02] })

		Aadd(aStru,{"REGRA" 	, "C"	,07	,00	})
		Aadd(aStru,{"DESC_UP" 	, "C"	,15	,00	})
		Aadd(aStru,{"IMCR_MIN" 	, "C"	,15	,00	})
		Aadd(aStru,{"IMC_TM" 	, "C"	,15	,00	})
		Aadd(aStru,{"IMCR_PV" 	, "C"	,15	,00	})

		cArqTrab := CriaTrab(aStru,.T.)
		DbUseArea(.T.,,cArqTrab, 'TMPDET', .F., .F.)
	EndIf



	DbSelectArea('SUA');DbSetOrder(1)		// UA_FILIAL+UA_NUM
	If DbSeek(xFilial('SUA') + SC5->C5_NUMSUA, .F.)

		aTabelas 	:= 	&(GetMv('MV_SEGXTAB'))		//	{{"1","OEM"},{"2","MNT"},{"3","REV"}}
		nPosTab 	:= 	Ascan(aTabelas, {|X| X[2] == SUA->UA_TABELA })
		If nPosTab > 0
			cTabPrc := 	SUA->UA_TABELA
		Else

			DbselectArea("SA1");DbSetOrder(1);DbGoTop()
			If DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI, .F.)
				cSegmento  	:= 	SubStr(SA1->A1_GRPSEG,3,1)
				nPosTab 	:= 	Ascan(aTabelas, {|X| X[1] == cSegmento })
				cTabPrc 	:= 	IIF(nPosTab > 0, aTabelas[nPosTab][02], '')
			EndIf

		EndIf



		IIF(Select('TMPL')!=0, TMPL->(DbCloseArea()), )
		cQuery := "	SELECT 	SUB.UB_PRODUTO, SB1.B1_DESC,	SB1.B1_OBSTPES, 						"+ENTER		//	UB_IDADE,
		cQuery += "			SC6.C6_IDADE2 	IDADE_IMDEPA,											"+ENTER
		cQuery += "			SUB.UB_NUM, 	SUB.UB_ITEM, 	SUB.UB_ITEMPV,  SUB.UB_PRODUTO,			"+ENTER
		cQuery += "			SUB.UB_DESCVEN, SUB.UB_DESCRD,											"+ENTER
		cQuery += "			SUB.UB_IMC, 					SUB.UB_IMCR,	SUB.UB_IMCG,			"+ENTER
		cQuery += "			ZGV.ZGV_IMCMIN RGV_IMCMIN, 		ZGV.ZGV_IMCRMI  RGV_IMCRMIN, 			"+ENTER
		cQuery += "			ZGV.ZGV_VLRMIN RGV_VLRMIN, 												"+ENTER
		cQuery += "			(IM1.IM1_IMCMIN * 100) MKP_IMCMIN,										"+ENTER
		cQuery += "			(IM1.IM1_TRAVAM * 100) TRAVAM,											"+ENTER
		cQuery += "			SUB.UB_TABPRC, SUB.UB_PRCTAB, 											"+ENTER
		cQuery += "			SUB.UB_VRCACRE, SUB.UB_VRUNIT, SUB.UB_PRCBASE							"+ENTER+ENTER

		cQuery += "	FROM "+RetSqlName("SUB")+"  SUB  												"+ENTER+ENTER

		cQuery += "									INNER JOIN "+RetSqlName("ZGV")+" ZGV 			"+ENTER
		cQuery += "									ON 	ZGV.ZGV_FILIAL 	 = '"+xFilial("ZGV")+" '	"+ENTER
		cQuery += "									AND ZGV.ZGV_GV 		 =  SUB.UB_FILIAL	 		"+ENTER
		cQuery += "									AND ZGV.ZGV_TABELA 	 = 	'"+cTabPrc+"' 			"+ENTER
		cQuery += "									AND ZGV.D_E_L_E_T_ 	!= 	'*' 					"+ENTER+ENTER

		cQuery += " 								INNER JOIN "+RetSqlName("SC6")+" SC6 			"+ENTER
		cQuery += " 								ON  SC6.C6_FILIAL 	=  SUB.UB_FILIAL		 	"+ENTER
		cQuery += " 								AND SC6.C6_NUM 		=  SUB.UB_NUMPV 			"+ENTER
		cQuery += " 								AND SC6.C6_ITEM 	=  SUB.UB_ITEMPV 			"+ENTER
		cQuery += " 								AND SC6.D_E_L_E_T_ !=  '*' 						"+ENTER+ENTER

		cQuery += " 								INNER JOIN "+RetSqlName("SB1")+" SB1 			"+ENTER
		cQuery += " 								ON  SB1.B1_FILIAL 	=  SUB.UB_FILIAL		 	"+ENTER
		cQuery += " 								AND SB1.B1_COD 		=  SUB.UB_PRODUTO 			"+ENTER
		cQuery += " 								AND SB1.D_E_L_E_T_ !=  '*' 						"+ENTER+ENTER

		cQuery += " 								INNER JOIN "+RetSqlName("IM1")+" IM1 			"+ENTER
		cQuery += " 								ON  IM1.IM1_FILIAL 	=  SUB.UB_FILIAL		 	"+ENTER
		cQuery += " 								AND IM1.IM1_COD 	=  SB1.B1_CURVA 			"+ENTER
		cQuery += " 								AND IM1.IM1_SEGMEN 	=  '"+cTabPrc+"' 			"+ENTER
		cQuery += " 								AND IM1.D_E_L_E_T_ !=  '*' 						"+ENTER+ENTER

		cQuery += "	WHERE SUB.UB_FILIAL  = '"+SUA->UA_FILIAL+"' 	"+ENTER
		cQuery += "	AND SUB.UB_NUM 		 = '"+SUA->UA_NUM+"' 		"+ENTER
		cQuery += "	AND SUB.D_E_L_E_T_ 	!= '*'  					"+ENTER

		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TMPL', .F., .T.)


		DbSelectArea("TMPL");DbGoTop()
		Do While !Eof()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|    PEDIDOS BLOQUEADOS POR REGRA CAIRAM PARA FINANCEIRO\DIRETOR QUANDO :		|
			//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
			//| 1. ITEM COM IMC ABAIXO DA TRAVA MASTER 										|
			//|																				|
			//| 2. ITEM COM IMCR ABAIXO DO MINIMO DO PRODUTO (IM1)							|
			//|    e IMCR DO PEDIDO ABAIXO MINIMO PERMITIDO  (ZGV)							|
			//|	   e VALOR DO PV >= R$ 2.000,00              (ZGV)							|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lTravaM		:=	.F.
			cTpBlqTM	:=	''
			cLiber		:=	''

			nImCPedido	:=	SUA->UA_IMC
			nImcRPedido	:=	SUA->UA_IMCR
			nTotalPV	:=	SUA->UA_VLRLIQ

			cItemAT		:=	TMPL->UB_ITEM
			cProdAT		:=	AllTrim(TMPL->UB_PRODUTO)
			cDescProd 	:= 	AllTrim(TMPL->B1_DESC)
			nIdade		:=	TMPL->IDADE_IMDEPA
			cItTabPrc	:=	TMPL->UB_TABPRC

			nImCProd  	:=	TMPL->UB_IMC
			nImcRProd 	:= 	TMPL->UB_IMCR

			nMrkImCMin	:=	TMPL->MKP_IMCMIN

			nImCMinRGV	:=	TMPL->RGV_IMCMIN
			nImcRMinRGV	:=	TMPL->RGV_IMCRMIN
			nVlrMinRGV	:=	TMPL->RGV_VLRMIN

			cPromo		:=	TMPL->B1_OBSTPES
			lPromo		:=	Left(TMPL->B1_OBSTPES,1) == 'P'



			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³***  BUSCA VALOR DA TRAVA MASTER NA TABELA IM1	*** ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nMvImcMin := TMPL->TRAVAM

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  VERIFICA SE EXISTE DESCONTO ACIMA DO PERMITIDO                     |
			//|	(SE ZRN_TPBLQ = DESCONTO EH PQ DESCONTO ESTA ACIMA DO PERMITIDO)	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IIF(Select('TMPD')!=0, TMPD->(DbCloseArea()), )
			cQuery := "	SELECT 	ZRN.ZRN_FILIAL, ZRN.ZRN_NUMAT, ZRN.ZRN_ITEMAT, ZRN.ZRN_PEDIDO, ZRN.ZRN_ITEMPV, ZRN.ZRN_PRODUT, 	"+ENTER
			cQuery += "			ZRN.ZRN_TPBLQ, ZRN.ZRN_VENDA,  ZRN.ZRN_REGRA,  ZRN.ZRN_CODRN, ZRN.ZRN_TPBLQ, ZRN.ZRN_CPOBLQ		"+ENTER+ENTER

			cQuery += " FROM 	"+RetSqlName("ZRN")+" ZRN   			   	"+ENTER
			cQuery += " WHERE 	ZRN.ZRN_FILIAL 	=  '"+SUA->UA_FILIAL+"' 	"+ENTER
			cQuery += " AND 	ZRN.ZRN_NUMAT 	=  '"+TMPL->UB_NUM+"'		"+ENTER
			cQuery += " AND 	ZRN.ZRN_ITEMAT 	=  '"+TMPL->UB_ITEM+"'		"+ENTER
			cQuery += " AND 	ZRN.ZRN_PRODUT 	=  '"+TMPL->UB_PRODUTO+"' 	"+ENTER
			cQuery += " AND 	UPPER(RTRIM(ZRN.ZRN_TPBLQ)) =  'DESCONTOS'	"+ENTER
			cQuery += " AND 	ZRN.ZRN_VENDA 	>  ZRN.ZRN_REGRA 			"+ENTER
			cQuery += " AND 	ZRN.D_E_L_E_T_ !=  '*' 						"+ENTER+ENTER

			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TMPD', .F., .T.)
			TMPD->(DbGoTop())

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|  VERIFICA SE DESCONTO DENTRO DA ALCADA	  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lDescAcima 	:= 	IIF(Empty(TMPD->ZRN_PEDIDO), .F., .T.)

			nDescVenda	:=	TMPL->UB_DESCVEN	//	DESCONTO CONCEDIDO PELO VENDEDOR NO ATENDIMENTO
			nDescRegra	:=	TMPL->UB_DESCRD		//	DESCONTO DE REGRA
			nDescMax	:=	IIF(Empty(TMPD->ZRN_PEDIDO), 0, TMPD->ZRN_REGRA )



			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| 		-->   R E G R A   B L O Q U E I O   <--  				|
			//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
			//| GetMv('IMD_TMIMC') 	- VERIFICA TRAVA MASTER POR IMC            	|
			//| GetMv('IMD_TMIMCR')	- VERIFICA TRAVA MASTER POR IMCR			|
			//|	GetMv('IMD_IMCOUR')	- VERIFICA IMC OU IMCR						|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³    X5_TABELA = 'GV'    					³
			//³	BLMRG1 - IMC Negativo 					³
			//³	BLMRG2 - IMC Item     					³
			//³	BLMRG3 - IMC Pedido   					³
			//³	BLMRG4 - IMCR Negativo					³
			//³	BLMRG5 - IMCR Item    					³
			//³	BLMRG6 - IMCR Pedido  					³
			//³	BLMRG7 - IMC e  IMCR Negativo  			³
			//³	BLMRG8 - IMC ou IMCR Negativo  			³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If lIMCouIMCR
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| TRAVA MASTER VERIFICA IMC -> OU <- IMCR		|
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lTravaM	:=	nImCProd  < nMvImcMin .Or. nImcRProd < nMvImcRMin
				cTpBlqTM:=	IIF(lTravaM, 'BLOQ. TRAVA MASTER. IMC PROD.: '+cValToChar(nImCProd)+'  <  '+cValToChar(nMvImcMin)+'  OU  IMCR PROD.: '+cValToChar(nImcRProd)+'  <  '+cValToChar(nMvImcRMin), '')

			Else

				If lMvIMC_TM .And. lMvIMCR_TM
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//| TRAVA MASTER VERIFICA IMC -> E <- IMCR		|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lTravaM	:=	nImCProd  < nMvImcMin .And. nImcRProd < nMvImcRMin
					cTpBlqTM:=	IIF(lTravaM, 'BLOQ. TRAVA MASTER. IMC PROD.: '+cValToChar(nImCProd)+'  <  '+cValToChar(nMvImcMin)+'  E  IMCR PROD.: '+cValToChar(nImcRProd)+'  <  '+cValToChar(nMvImcRMin), '')

				ElseIf lMvIMC_TM
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//| TRAVA MASTER VERIFICA IMC	|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lTravaM	:=	nImCProd  < nMvImcMin
					cTpBlqTM:=	IIF(lTravaM, 'BLOQ. TRAVA MASTER. IMC PROD.: '+cValToChar(nImCProd)+'  <  '+cValToChar(nMvImcMin), '')

				ElseIf lMvIMCR_TM
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//| TRAVA MASTER VERIFICA IMCR	|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lTravaM	:=	nImCRProd  < nMvImcRMin
					cTpBlqTM:=	IIF(lTravaM, 'BLOQ. TRAVA MASTER. IMCR PROD.: '+cValToChar(nImcRProd)+'  <  '+cValToChar(nMvImcRMin), '')

				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//| TODOS OS PARAMETROS COMO FALSO - NAO VERIFICA TRAVA MASTER	|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				EndIf

			EndIf


			If lTravaM

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//|  EXCETO ITENS EM PROMO DENTRO DA ALCADA		|
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lPromo //.And. !lDescAcima
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//| -->  R E G R A   B L O Q U E I O   	<--  |
					//| 	   	    TRAVA MASTER				 |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Aadd(aDiretor, {cItemAT, cProdAT, cDescProd, cTpBlqTM, 'LIB.DIR', nImCProd, nImcRProd, cItTabPrc, nMrkImCMin, nIdade, .F.})
					cLiber	:=	'LIB.DIR' //'BLQ.DIR'
				Else
					cLiber	:=	'LIB.GER'
				EndIf

			Else
				cLiber	:=	'LIB.GER'
			EndIf



			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|  VERIFICA SE GERENTE PODE LIBERAR	|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lDescAcima

				If nImcRProd >= nMrkImCMin .And. !lTravaM
					Aadd(aGerente, {cItemAT, cProdAT, cDescProd, 'DESCONTO('+cValToChar(nDescVenda)+' %) > ALÇADA('+cValToChar(nDescMax)+' %) e IMCR PRODUTO >= IMC.MIN e SEM BLOQ.TRAVA MASTER', 'LIB.GER', nImCProd, nImcRProd, cItTabPrc, nMrkImCMin, nIdade, .F.}) // MRK.MIN
					cLiber	:=	'LIB.GER'
				ElseIf nImcRProd <  nMrkImCMin .And. nImcRPedido >= nImcRMinRGV
					Aadd(aGerente, {cItemAT, cProdAT, cDescProd, 'DESCONTO('+cValToChar(nDescVenda)+' %) > ALÇADA('+cValToChar(nDescMax)+' %) e IMCR PRODUTO < IMC.MIN e IMCR PEDIDO > MIN.PERMITIDO', 'LIB.GER', nImCProd, nImcRProd, cItTabPrc, nMrkImCMin, nIdade, .F.})	//MRK.MIN
					cLiber	:=	'LIB.GER'
				Else
					Aadd(aGerente, {cItemAT, cProdAT, cDescProd, 'DESCONTO: '+cValToChar(nDescVenda)+'%   ACIMA DO  PERMITIDO: '+cValToChar(nDescMax)+'% ', 'LIB.DIR'/*'BLQ.GER'*/, nImCProd, nImcRProd, cItTabPrc, nMrkImCMin, nIdade, .F.})
					cLiber	:=	'LIB.DIR'
				EndIf



				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//|  ARRAY COM DESCONTO ACIMA DO PERMITIDO	|
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Ascan(aGerente, {|X| X[01] == cItemAT} ) == 0
					Aadd(aDesconto, {cItemAT, cProdAT, cDescProd, 'DESCONTO: '+cValToChar(nDescVenda)+'%   ACIMA DO  PERMITIDO: '+cValToChar(nDescMax)+'% ', 'LIB.GER', .F.})
					cLiber	:=	'LIB.GER'
				EndIf

			EndIf


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| --> R E G R A   B L O Q U E I O  II	<--  |
			//|  PEDIDO MAIOR QUE R$ 2.000,00  (ZGV)	 |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nTotalPV >= nVlrMinRGV

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//|  IMCR PV MENOR IMCR MINIMO (ZGV)	|
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nImcRPedido < nImcRMinRGV


					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//|  VERIFICA SE IMC/IMCR/AMBOS MENOR QUE MARKUP MINIMO (IM1)	|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lNextLevel	:=	.F.
					cTpBlqTM	:=	''

					If lChkIMC
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//|  VERIFICA SE IMC MENOR QUE MARKUP MINIMO (IM1)	|
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nImCProd  < nMrkImCMin
							lNextLevel	:= .T.
							cTpBlqTM	+=	'IMC PROD.: '+cValToChar(nImCProd)+'  <  IMC.MIN: '+ cValToChar(nMrkImCMin)		// MRK.MIN
						EndIf

					ElseIf lChkIMCR
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//|  VERIFICA SE IMCR MENOR QUE MARKUP MINIMO (IM1)	|
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nImcRProd < nMrkImCMin
							lNextLevel	:= .T.
							cTpBlqTM	+=	'IMCR PROD.: '+cValToChar(nImcRProd)+'  <  IMC.MIN: '+ cValToChar(nMrkImCMin)	//MRK.MIN
						EndIf

					ElseIf lChkAmbos
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//|  VERIFICA SE IMC e IMCR MENOR QUE MARKUP MINIMO (IM1)	|
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nImCProd  < nMrkImCMin .And. nImcRProd < nMrkImCMin
							lNextLevel	:= .T.
							cTpBlqTM	+=	'IMC PROD.: '+cValToChar(nImCProd)+'  <  IMC.MIN: '+ cValToChar(nMrkImCMin)		// MRK.MIN
							cTpBlqTM	+=	'  e  '
							cTpBlqTM	+=	'IMCR PROD.: '+cValToChar(nImcRProd)+'  <  IMC.MIN: '+ cValToChar(nMrkImCMin)	// MRK.MIN
						EndIf

					EndIf


					If lNextLevel
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//| *** IMC|IMCR|AMBOS MENOR IMC MINIMO DO MARKUP		|
						//|  e  IMC DO PEDIDO ABAIXO DO MINIMO PERMITIDO (ZGV)	|
						//|  e  VALOR DO PEDIDO MAIOR QUE R$ 2.000,00    (ZGV)	|
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cTotalPV 	:=	AllTrim(Transform( nTotalPV, PesqPict('SUA','UA_VLRLIQ')))
						cVlrMinRGV	:=	AllTrim(Transform( nVlrMinRGV, PesqPict('SUA','UA_VLRLIQ')))
						cLiber		:=	'LIB.DIR'//'BLQ.DIR'

						Aadd(aDiretor, {cItemAT, cProdAT, cDescProd,;
						cTpBlqTM+Space(02)+;
						'e IMCR DO PV '+cValToChar(nImcRPedido)+' ABAIXO DO IMCR PERMITIDO '+cValToChar(nImcRMinRGV)+Space(02)+;
						'e VALOR DO PV R$ '+cTotalPV+' MAIOR QUE O PERMITIDO '+cVlrMinRGV,;
						'LIB.DIR', nImCProd, nImcRProd, cItTabPrc, nMrkImCMin, nIdade, .F.})

					EndIf

				EndIf


			EndIf



			DbSelectArea('TMPDET')
			RecLock('TMPDET', .T.)
			TMPDET->ITEM		:=	cItemAT
			TMPDET->CODIGO		:=	cProdAT
			TMPDET->DESCRI		:=	cDescProd
			TMPDET->IDADE		:=	nIdade
			TMPDET->PROMO		:=	cPromo
			TMPDET->DESCVEN		:=	nDescVenda
			TMPDET->DESCREG		:=	nDescRegra
			TMPDET->DESCMAX		:=	nDescMax
			TMPDET->IMCPROD		:=	nImCProd
			TMPDET->TRAVAM		:=	nMvImcMin		//	AJUSTAR PARA CASOS IMC e IMCR
			TMPDET->IMCRPROD	:=	nImcRProd
			TMPDET->MRK_MIN		:=	nMrkImCMin
			TMPDET->IMCPED		:=	nImCPedido
			TMPDET->IMCRPED		:=	nImcRPedido
			TMPDET->IMCPERM		:=	nImCMinRGV
			TMPDET->IMCRPERM	:=	nImcRMinRGV
			TMPDET->VLRPERM		:=	nVlrMinRGV
			TMPDET->VLRPED		:=	nTotalPV
			TMPDET->LIBER		:=	cLiber
			TMPDET->TABPRC		:=	cItTabPrc

			//			If lDiretor .Or. lFinanceiro .Or. lFilGer
			//				IMC PROD.: 3.08  <  MRK.MIN: 16  E  IMCR PROD.: 8.56  <  MRK.MIN: 16  E IMCR DO PV 11.52 ABAIXO DO IMCR PERMITIDO 50  E VALOR DO PV R$ 19.793,88 MAIOR QUE O PERMITIDO 2.000,00

			TMPDET->DESC_UP		:=	IIF(nDescVenda >  nDescRegra, 'R1 SIM | R2 SIM', 'R1 NAO | R1 NAO')
			TMPDET->IMCR_MIN	:=	IIF(nImcRProd  >= nMrkImCMin, 'R1 SIM | R2 NAO', 'R1 NAO | R2 SIM')
			TMPDET->IMC_TM		:=	IIF(nImcProd   >= nMvImcMin,  'R1 SIM','R1 NAO')
			TMPDET->IMCR_PV		:=	IIF(nImcRPedido>= nImcRMinRGV,'R2 SIM','R2 NAO')


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ * DESCONTO ACIMA DA ALCADA                    		³
			//³ IMCR MINIMO DO PRODUTO [ DENTRO ] DO PERMITIDO (IM1)³
			//³	IMC DO PRODUTO MAIOR QUE TRAVA MASTE        		³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lRegra1	:=	.T.
			lRegra1	:=	IIF(lRegra1, IIF(AT("R1 SIM", TMPDET->DESC_UP ) > 0, .T., .F.), lRegra1)
			lRegra1	:=	IIF(lRegra1, IIF(AT("R1 SIM", TMPDET->IMCR_MIN) > 0, .T., .F.), lRegra1)
			lRegra1	:=	IIF(lRegra1, IIF(AT("R1 SIM", TMPDET->IMC_TM  ) > 0, .T., .F.), lRegra1)


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ * DESCONTO ACIMA DA ALCADA                    		³
			//³	IMCR MINIMO DO PRODUTO [ ABAIXO ] DO PERMITIDO (IM1)³
			//³	IMCR DO PEDIDO DENTRO DO PERMITIDO (ZGV)	        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lRegra2	:=	.T.
			lRegra2	:=	IIF(lRegra2, IIF(AT("R2 SIM", TMPDET->DESC_UP ) > 0, .T., .F.), lRegra2)
			lRegra2	:=	IIF(lRegra2, IIF(AT("R2 SIM", TMPDET->IMCR_MIN) > 0, .T., .F.), lRegra2)
			lRegra2	:=	IIF(lRegra2, IIF(AT("R2 SIM", TMPDET->IMC_TM  ) > 0, .T., .F.), lRegra2)

			If lRegra1 .And. lRegra2
				TMPDET->REGRA := 'R1 e R2'
			ElseIf lRegra1
				TMPDET->REGRA := 'R1'
			ElseIf lRegra2
				TMPDET->REGRA := 'R2'
			EndIf

			MsUnLock()

			DbSelectArea("TMPL")
			DbSkip()
		EndDo


		// 					 [01]     [02]      [03]        [04]            [05]
		// Aadd(aGerente, {cItemAT, cProdAT, cDescProd, 'NAO_LIBERAR',  'LIB.GER', nImCProd, nImcRProd, cItTabPrc, .F.}) // LIB.DIR
		// Aadd(aDiretor, {cItemAT, cProdAT, cDescProd, cTpBlqTM,		'LIB.DIR', nImCProd, nImcRProd, cItTabPrc, .F.})

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|  PEDIDO NECESSITA DE AVALIACAO DO DIRETOR				|
		//|	 GERENTE LIBERA E PV Eh ENVIADO PARA DIRETOR LIBERAR	|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aDiretor) > 0
			lLiberDir 	:=	.T.
			lLiberGer	:= 	.F.
			aBloqRegra	:=	aDiretor

		Else

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|  AVALIACAO SE GERENTE PODE LIBERAR DIRETO		|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aGerente) > 0
				If Ascan(aGerente, {|X| AllTrim(X[05]) == AllTrim('LIB.DIR') }) > 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//| GERENTE NAO PODE LIBERAR 						|
					//| DIRETOR DEVE ENTRAR COMO GERENTE PARA LIBERAR 	|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lLiberDir 	:= 	.F.
					lLiberGer 	:= 	.F.
					aBloqRegra	:=	aGerente

				Else
					If Ascan(aGerente, {|X| AllTrim(X[05]) == AllTrim('LIB.GER') })  > 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//|  GERENTE PODE LIBERAR DIRETO		|
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lLiberDir 	:= 	.T.
						lLiberGer 	:= 	.T.
						aBloqRegra	:=	aGerente
					EndIf
				EndIf
			EndIf

		EndIf


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|  ADICIONA NO ARRAY OS ITENS COM DESCONTO ACIMA DA ALCADA	|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aEval(aDesconto, {|nX| Aadd(aBloqRegra, nX)})
		aSort(aBloqRegra,,,{|X,Y| X[1] < Y[1]  })


	EndIf


	Return({lLiberGer, lLiberDir})
	*************************************************************************
Static Function TelaBloq(cNivelLib)
	*************************************************************************
	Local lRetBloq 	:= 	.F.
	Local nOpc 		:= 	0 //GD_INSERT+GD_DELETE+GD_UPDATE
	Local nTamProd	:=	0
	Local aHeaderB 	:= 	{}
	Local oFont1   	:=	TFont():New( "Arial",0,-16,,.T.,0,,700,.F.,.F.,,,,,, )
	Local cBckFil	:=	cFilAnt
	Local cNomeFil	:=	AllTrim(Upper(Posicione('SM0', 1, cEmpAnt + SC5->C5_FILIAL, 'M0_FILIAL' )))
	Local cEstFil	:=	AllTrim(Upper(Posicione('SM0', 1, cEmpAnt + SC5->C5_FILIAL, 'M0_ESTENT' )))


	aEval(aBloqRegra, 	{|X| nTamProd := IIF(Len(AllTrim(X[03])) > nTamProd, Len(AllTrim(X[03])), nTamProd) })

	Aadd(aHeaderB, {"Item"		, "ITEM"	, "@!" , TamSx3('UB_ITEM')[01], 0 , "" , "" , "C" , ""})
	Aadd(aHeaderB, {"Código"	, "CODIGO"	, "@!" , TamSx3('B1_COD')[01] , 0 , "" , "" , "C" , ""})
	Aadd(aHeaderB, {"Descrição"	, "DESCRI"	, "@!" , nTamProd, 0 , "" , "" , "C" , ""})
	Aadd(aHeaderB, {"Bloqueio"	, "BLOQ"	, "@!!", 200, 0 , "" , "" , "C" , ""})
	Aadd(aHeaderB, {"Liber"		, "TPBLOQ"	, "@!!", 010, 0 , "" , "" , "C" , ""})


	oDlgTela 	:= 	MsDialog():New( 091,232,394,1040,"Liberação Pedido Bloqueio de Regra",,,.F.,,,,,,.T.,,,.T. )

	oSayFil    	:= 	TSay():New( 003,007,{|| "FILIAL:  "+SC5->C5_FILIAL+" | "+cEstFil+" - "+cNomeFil},oDlgTela,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,256,012)
	oSayPV     	:= 	TSay():New( 013,007,{|| "PEDIDO:  "+SC5->C5_NUM+"  |  DT.EMISSÃO: "+DtoC(SC5->C5_EMISSAO)+"  -  COM RESTRIÇÃO PARA LIBERAÇÃO "},oDlgTela,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,356,012)
	oGrp       	:= 	TGroup():New( 024,004,128,396,"",oDlgTela,CLR_BLACK,CLR_WHITE,.T.,.F.)

	oBrwBlq    	:= 	MsNewGetDados():New(032,008,124,392,nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,999,'AllwaysTrue()','','AllwaysTrue()',oGrp, aHeaderB, aBloqRegra )


	oBtnDet    	:= 	TButton():New( 132,250,"Detalhes",		oDlgTela,{|| DetalBlq()   	},047,012,,,,.T.,,"",,,,.F. )
	oBtnOk     	:= 	TButton():New( 132,315,"Liberar",    	oDlgTela,{|| IIF(lRetBloq:= LiberPV(cNivelLib), oDlgTela:End(),) },037,012,,,,.T.,,"",,,,.F. )
	oBtnNo     	:=	TButton():New( 132,360,"Retornar",		oDlgTela,{|| oDlgTela:End()	},037,012,,,,.T.,,"",,,,.F. )
	oBtnVis    	:= 	TButton():New( 132,010,"Bloqueios",		oDlgTela,{|| MsgRun("Aguarde...Carregando dados...","Processando",{|| U_IMDPEDBLQ() }) },037,012,,,,.T.,,"",,,,.F. )

	oDlgTela:Activate(,,,.T.)


	Posicione('SM0', 1, cEmpAnt + cBckFil, 'M0_ESTENT' )
	Return(lRetBloq)
	*************************************************************************
Static Function LiberPV(cNivelLib)
	*************************************************************************
	Local lRetTela := .F.

	If cNivelLib == 'GERENTE' .And. !lFilGer
		/*
		If cNivelLib == 'GERENTE' .And. Ascan(aBloqRegra, {|X| AllTrim(X[05]) == AllTrim('LIB.DIR') }) > 0 // BLQ.GER
		MsgAlert('ESSE PEDIDO DEVERÁ SER ANALISADO PELO FINANCEIRO\DIRETOR ANTES DE SER LIBERADO.')
		lRetTela := .F.
		Else
		lRetTela := MsgYesNo("PEDIDO  "+SC5->C5_NUM+"  COM RESTRIÇÃO DE LIBERAÇÃO."+ENTER+IIF(!lRegAtiva, "DESEJA LIBERAR MESMO ASSIM ?", "DESEJA ENVIAR PARA O FINANCEIRO \ DIRETOR ?"), cNivelLib)
		EndIf
		*/
		If cNivelLib == 'GERENTE' .And. Ascan(aBloqRegra, {|X| AllTrim(X[05]) == AllTrim('LIB.DIR') }) > 0
			lRetTela := MsgYesNo("PEDIDO  "+SC5->C5_NUM+"  COM RESTRIÇÃO DE LIBERAÇÃO."+ENTER+IIF(!lRegAtiva, "DESEJA LIBERAR MESMO ASSIM ?", +ENTER+"ESSE PEDIDO DEVERÁ SER ANALISADO PELO FINANCEIRO\DIRETOR ANTES DE SER LIBERADO."+ENTER+"DESEJA ENVIAR PARA O FINANCEIRO\DIRETOR ?"), cNivelLib)
		Else
			lRetTela := MsgYesNo("PEDIDO  "+SC5->C5_NUM+"  COM RESTRIÇÃO DE LIBERAÇÃO."+ENTER+"DESEJA LIBERAR MESMO ASSIM ?", cNivelLib)
		EndIf

	ElseIf cNivelLib == 'FINANCEIRO' .Or. cNivelLib == 'DIRETOR' .Or. lFilGer
		lRetTela := MsgYesNo("PEDIDO  "+SC5->C5_NUM+"  COM RESTRIÇÃO DE LIBERAÇÃO."+ENTER+"DESEJA LIBERAR MESMO ASSIM ?", IIF(lFilGer,'Liberando como ','')+cNivelLib)
	EndIf

	Return(lRetTela)
	*************************************************************************
Static Function DetalBlq()
	*************************************************************************
	Local aDetalhe := 	{}

	DbSelectArea('TMPDET'); DbGoTop()
	Do While !Eof()

		cNivEst 	:= 	Posicione('ZA7', 1, SC5->C5_FILIAL+TMPDET->CODIGO, 'ZA7_ESTOBJ')
		cVlrPV		:=	AllTrim(Transform(TMPDET->VLRPED,  PesqPict('SUA','UA_VLRLIQ')))
		cVlrPerm 	:=	AllTrim(Transform(TMPDET->VLRPERM, PesqPict('SUA','UA_VLRLIQ')))

		//	[08-11]
		cIMCPed 	:=	AllTrim(Transform(TMPDET->IMCPED, PesqPict('SUA','UA_VLRLIQ')))
		cIMCPerm 	:=	AllTrim(Transform(TMPDET->IMCPERM,PesqPict('SUA','UA_VLRLIQ')))

		cIMCRPed 	:=	AllTrim(Transform(TMPDET->IMCRPED, PesqPict('IM1','IM1_TRAVAM')))
		cIMCRPerm 	:=	AllTrim(Transform(TMPDET->IMCRPERM,PesqPict('IM1','IM1_TRAVAM')))

		//						1		2		3									4												5			6		7			8		9
		//	Aadd(aGerente, {cItemAT, cProdAT, cDescProd, 'DESCONTO > ALÇADA e IMCR PRODUTO >= IMC.MIN e SEM BLOQ.TRAVA MASTER', 'LIB.GER', nImCProd, nImcRProd, cItTabPrc, .F.}) // MRK.MIN
		//	Aadd(aDiretor, {cItemAT, cProdAT, cDescProd, cTpBlqTM, 'LIB.DIR', nImCProd, nImcRProd, cItTabPrc, .F.})
		nPProb	:=	Ascan(aBloqRegra, {|X| AllTrim(X[01]) == AllTrim(TMPDET->ITEM) })
		cFlag	:= 	IIF(nPProb > 0, '*', '')

		Aadd(aDetalhe,{	cFlag,;
		TMPDET->ITEM,   	AllTrim(TMPDET->CODIGO)+' - '+ AllTrim(TMPDET->DESCRI),	 AllTrim(TMPDET->PROMO),;	//	[02-04]
		TMPDET->IMCPROD, 	TMPDET->MRK_MIN,;	//	[05-06]
		TMPDET->IMCRPROD,	TMPDET->MRK_MIN,;	//	[07-08]
		TMPDET->DESCVEN,;		//	[09]
		TMPDET->DESCREG,;		//	[10]
		TMPDET->TRAVAM,;		//	[11]
		TMPDET->IDADE,;			//	[12]
		TMPDET->TABPRC,;		//	[13]
		TMPDET->LIBER,;			//	[14]
		' - ',;					//	[15]
		TMPDET->REGRA,;			//	[16]
		TMPDET->DESC_UP,;		//	[17]
		TMPDET->IMCR_MIN,;		//	[18]
		TMPDET->IMC_TM,;		//	[19]
		TMPDET->IMCR_PV })		//	[20]

		DbSkip()
	EndDo

	//					cNivEst,;				//	[21]
	//					TMPDET->VLRPED,;		//	[14]
	//					TMPDET->VLRPERM, ;		//	[15]

	aSort(aDetalhe,,,{|X,Y| X[1] > Y[1]  })

	Define Dialog oDlgBlq Title "Detlhes Bloqueio - Pedido: "+SC5->C5_NUM+"  |  Dt.Emissão: "+DtoC(SC5->C5_EMISSAO) From 120,120 To 415,1400 Pixel

	DbselectArea("SA1");DbSetOrder(1);DbGoTop()
	If DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI, .F.)
		cCliente	:= SA1->A1_COD
		cLoja		:= SA1->A1_LOJA
	EndIf
	cGrpSeg		:= 	SA1->A1_GRPSEG
	cVinculo	:=	AllTrim(SA1->A1_VINCIMD)+' - '+AllTrim(Posicione('CC1', 1, xFilial('CC1')+SA1->A1_VINCIMD, 'CC1_DESCRI'))
	cDtUltComp	:=	DtoC(SA1->A1_ULTCOM)
	cGerente	:=	AllTrim(SA1->A1_GERVEN)+' - '+AllTrim(Posicione('SA3', 1, xFilial('SA3')+SA1->A1_GERVEN, 'A3_NOME'))
	cObsCli		:=	SA1->A1_OBSVEND
	cCliente	:=	AllTrim(SA1->A1_COD)+'\'+AllTrim(SA1->A1_LOJA)+' - '+AllTrim(SA1->A1_NOME)

	cTpFrete	:=	IIF(SC5->C5_TPFRETE == 'F', 'FOB', (IIF(SC5->C5_TPFRETE == 'C', 'CIF', '')) )
	nVlrFrete	:=	Posicione('SUA', 1, xFilial('SUA')+SC5->C5_NUMSUA, 'UA_FRETRAN')
	cTpCIF		:=	Posicione('SUA', 1, xFilial('SUA')+SC5->C5_NUMSUA, 'UA_TPCIF')
	cTpFrete	:=	IIF(!Empty(cTpCIF), cTpCIF, cTpFrete)

	oFont1	:= TFont():New( "Arial",0,18,,.T.,0,,700,.F.,.F.,,,,,, )
	oBrowse := TcBrowse():New(040, 002, 638, 090,,{'Item','Produto','Descri?o','Quant.','Saldo'},{/*50,50,50*/},oDlgBlq,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	oBrowse:SetArray(aDetalhe)

	oSay2  := TSay():New( 004,010,{|| 'Cliente: '+AllTrim(cCliente) },,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,300,020 )
	oSay3  := TSay():New( 014,010,{|| 'Ult.Compra: '+cDtUltComp  },,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,300,020 )

	nColVinc 	:= 100
	cVlrFreTran := ''
	If nVlrFrete > 0
		cVlrFreTran := '   Vlr.Frete:  R$ '+AllTrim(Transform(nVlrFrete,  PesqPict('SUA','UA_VLRLIQ')))
	EndIf

	oSay4  := TSay():New( 024,010,{|| 'Frete: '+cTpFrete+ cVlrFreTran 	},,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,300,020 )
	oSay5  := TSay():New( 024,040+nColVinc,{|| 'Vinculo: '+cVinculo	},,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,300,020 )

	oSay6  := TSay():New( 004,250,{|| 'Vlr.Pedido:  R$ '+cVlrPV	},,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,300,020 )
	oSay7  := TSay():New( 014,250,{|| 'Vlr.Mínimo:  R$ '+cVlrPerm 	},,,oFont1,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,300,020 )

	oSay8  := TSay():New( 004,340,{|| 'IMC.Pedido:  '+cIMCPed		},,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,300,020 )
	oSay9  := TSay():New( 014,340,{|| 'IMC.Mínimo:  '+cIMCPerm 	},,,oFont1,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,300,020 )

	oSay10 := TSay():New( 004,430,{|| 'IMCR.Pedido: '+cIMCRPed		},,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,300,020 )
	oSay11 := TSay():New( 014,430,{|| 'IMCR.Mínimo: '+cIMCRPerm	},,,oFont1,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,300,020 )



	oBrowse:AddColumn( TcColumn():New(''				,{|| aDetalhe[oBrowse:nAt][01] },,,,"CENTER",,.F.,.T.,,,,.F.,) )
	oBrowse:AddColumn( TcColumn():New('Item'			,{|| aDetalhe[oBrowse:nAt][02] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	oBrowse:AddColumn( TcColumn():New('Produto'			,{|| aDetalhe[oBrowse:nAt][03] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	oBrowse:AddColumn( TcColumn():New('Promo'			,{|| aDetalhe[oBrowse:nAt][04] },,,,"LEFT",,.F.,.T.,,,,.F.,) )

	oBrowse:AddColumn( TcColumn():New('IMC Prod.'		,{|| aDetalhe[oBrowse:nAt][05] },PesqPict('SUA','UA_VLRLIQ'),,,"LEFT",,.F.,.T.,,,,.F.,) )	//	UB_IMC
	oBrowse:AddColumn( TcColumn():New('IMC Min.Prod'	,{|| aDetalhe[oBrowse:nAt][06] },PesqPict('SUA','UA_VLRLIQ'),,,"LEFT",,.F.,.T.,,,,.F.,) )	//	IM1_IMCMIN
	//    oBrowse:AddColumn( TcColumn():New('IMC Pedido'		,{|| aDetalhe[oBrowse:nAt][06] },PesqPict('SUA','UA_VLRLIQ'),,,"LEFT",,.F.,.T.,,,,.F.,) )	//	UA_IMC
	//    oBrowse:AddColumn( TcColumn():New('IMC Min.Pedido'	,{|| aDetalhe[oBrowse:nAt][07] },PesqPict('SUA','UA_VLRLIQ'),,,"LEFT",,.F.,.T.,,,,.F.,) )	//	ZGV_IMCMIN
	oBrowse:AddColumn( TcColumn():New('IMCR Prod.'		,{|| aDetalhe[oBrowse:nAt][07] },PesqPict('SUA','UA_VLRLIQ'),,,"LEFT",,.F.,.T.,,,,.F.,) )	//	UB_IMCR
	oBrowse:AddColumn( TcColumn():New('*IMCR Min.Prod'	,{|| aDetalhe[oBrowse:nAt][08] },PesqPict('SUA','UA_VLRLIQ'),,,"LEFT",,.F.,.T.,,,,.F.,) )	//	MESMO IM1_IMCMIN
	//    oBrowse:AddColumn( TcColumn():New('IMCR Pedido'		,{|| aDetalhe[oBrowse:nAt][10] },PesqPict('SUA','UA_VLRLIQ'),,,"LEFT",,.F.,.T.,,,,.F.,) )	//	UA_IMCR
	//    oBrowse:AddColumn( TcColumn():New('IMCR Min.Pedido'	,{|| aDetalhe[oBrowse:nAt][11] },PesqPict('SUA','UA_VLRLIQ'),,,"LEFT",,.F.,.T.,,,,.F.,) )	//	ZGV_IMCRMI
	oBrowse:AddColumn( TcColumn():New('Desc.Vend'		,{|| aDetalhe[oBrowse:nAt][09] },PesqPict('SUA','UA_VLRLIQ'),,,"LEFT",,.F.,.T.,,,,.F.,) )	//	ZRN_VENDA
	oBrowse:AddColumn( TcColumn():New('Desc.Regra'		,{|| aDetalhe[oBrowse:nAt][10] },PesqPict('SUA','UA_VLRLIQ'),,,"LEFT",,.F.,.T.,,,,.F.,) ) 	//	UB_DESCRD
	oBrowse:AddColumn( TcColumn():New('Trava M.'		,{|| aDetalhe[oBrowse:nAt][11] },PesqPict('SUA','UA_VLRLIQ'),,,"LEFT",,.F.,.T.,,,,.F.,) )	//	PARAMETRO IMD_MINIMC/IMD_MIIMCR
	oBrowse:AddColumn( TcColumn():New('Idade'			,{|| aDetalhe[oBrowse:nAt][12] },PesqPict('SUA','UA_VLRLIQ'),,,"LEFT",,.F.,.T.,,,,.F.,) )
	oBrowse:AddColumn( TcColumn():New('Tab.Preco'		,{|| aDetalhe[oBrowse:nAt][13] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	oBrowse:AddColumn( TcColumn():New('Liber.'			,{|| aDetalhe[oBrowse:nAt][14] },,,,"LEFT",,.F.,.T.,,,,.F.,) )

	//  oBrowse:AddColumn( TcColumn():New('Vlr.Ped.'		,{|| aDetalhe[oBrowse:nAt][nColuna] },PesqPict('SUA','UA_VLRLIQ'),,,"LEFT",,.F.,.T.,,,,.F.,) ); nColuna++		//	UA_VLRLIQ
	//  oBrowse:AddColumn( TcColumn():New('Vlr.Min.'		,{|| aDetalhe[oBrowse:nAt][nColuna] },PesqPict('SUA','UA_VLRLIQ'),,,"LEFT",,.F.,.T.,,,,.F.,) ); nColuna++		//	ZGV_VLRMIN
	//  oBrowse:AddColumn( TcColumn():New('Niv.Estoque'		,{|| aDetalhe[oBrowse:nAt][nColuna] },,,,"LEFT",,.F.,.T.,,,,.F.,) ); nColuna++

	oBrowse:AddColumn( TcColumn():New(''				,{|| aDetalhe[oBrowse:nAt][15] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	oBrowse:AddColumn( TcColumn():New('Regra'			,{|| aDetalhe[oBrowse:nAt][16] },,,,"CENTER",,.F.,.T.,,,,.F.,) )
	oBrowse:AddColumn( TcColumn():New('Desc > Alçada'	,{|| aDetalhe[oBrowse:nAt][17] },,,,"CENTER",,.F.,.T.,,,,.F.,) )
	oBrowse:AddColumn( TcColumn():New('IMC Prod > Trava Master'	,{|| aDetalhe[oBrowse:nAt][18] },,,,"CENTER",,.F.,.T.,,,,.F.,) )
	oBrowse:AddColumn( TcColumn():New('IMCR PV > Permitido'		,{|| aDetalhe[oBrowse:nAt][19] },,,,"CENTER",,.F.,.T.,,,,.F.,) )
	oBrowse:AddColumn( TcColumn():New('IMCR Prod. > Permitido'	,{|| aDetalhe[oBrowse:nAt][20] },,,,"CENTER",,.F.,.T.,,,,.F.,) )

	//oBrowse:bLDblClick	:=	{|| }

	TButton():New( 134, 600, '&Retornar',  oDlgBlq,{|| oDlgBlq:End() },30,010,,,.F.,.T.,.F.,,.F.,,,.F. )


	Activate Dialog oDlgBlq Centered

	Return()
	*************************************************************************
Static Function EnvEmail(cFilPV, cNumPV, cCodCli, cLojaCli)
	*************************************************************************
	cUserLib	:=	UsrRetName(__cUserId)
	cNomeCli	:=	AllTrim(Posicione('SA1', 1, xFilial(cFilPV) + cCodCli + cLojaCli, 'A1_NOME'))
	cTotalPV 	:= 	'0' //AllTrim(Transform(Posicione('SUA', 8, cFilPV+cNumPV, 'UA_VLRLIQ'), PesqPict('SUA','UA_VLRLIQ')))
	cGerente	:=	''
	cNomeFil	:= 	AllTrim( Posicione('SM0', 1, cEmpAnt + cFilPV,  'M0_FILIAL' ))
	cFilAtu 	:= 	AllTrim( Posicione('SM0', 1, cEmpAnt + cFilAnt, 'M0_ESTENT' )) // RETORNA PARA FILIAL ATUAL

	cCondPag	:=	AllTrim(SC5->C5_CONDPAG)+' - '+ Alltrim(Posicione('SE4', 1, xFilial('SE4')+SC5->C5_CONDPAG, 'E4_DESCRI'))
	cIMCPv		:=	cValToChar(SC5->C5_IMC)
	cIMCRPv		:=	cValToChar(SC5->C5_IMCR)

	cPvImcMin	:=	''
	cPvImcRMin	:=	''
	cTpCIF 		:= 	''


	DbSelectArea('SUA');DbSetOrder(1)		// UA_FILIAL+UA_NUM
	If DbSeek(xFilial('SUA') + SC5->C5_NUMSUA, .F.)
		cTotalPV 	:= 	AllTrim(Transform(SUA->UA_VLRLIQ, PesqPict('SUA','UA_VLRLIQ')))
		cTabPrc 	:= 	SUA->UA_TABELA
		cObs		:=	MSMM(SUA->UA_CODOBS,TamSx3("UA_OBS")[1])
		cTpCIF 		:= 	SUA->UA_TPCIF
		//cObsOrc		:=	SUA->UA_OBSORC
		//cObsExp		:=	SUA->UA_OBSEXP
		//cObsNF		:=	SUA->UA_MENNOTA
		//cObsCod		:=	SUA->UA_CODOBS
		//cObsFrete	:=	SUA->UA_OBSFRT
	EndIf

	DbSelectArea('ZGV');DbSetOrder(1);DbGoTop()
	If DbSeek(xFilial('ZGV')+cFilPV+cTabPrc, .F.)
		cPvImcMin	:=	cValToChar(ZGV->ZGV_IMCMIN)
		cPvImcRMin	:=	cValToChar(ZGV->ZGV_IMCRMI)
	EndIf



	aTabelas 	:= 	&(GetMv('MV_SEGXTAB'))		//  {{"1","OEM", "INDUSTRIA"},{"2","MNT","MANUTENCAO"},{"3","REV","REVENDA"}
	cSegmento 	:= 	''

	DbselectArea("SA1");DbSetOrder(1);DbGoTop()
	If DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI, .F.)
		cCliente	:= SA1->A1_COD
		cLoja		:= SA1->A1_LOJA
	EndIf
	cGrpSeg		:= 	SA1->A1_GRPSEG
	cVinculo	:=	AllTrim(SA1->A1_VINCIMD)+' - '+AllTrim(Posicione('CC1', 1, xFilial('CC1')+SA1->A1_VINCIMD, 'CC1_DESCRI'))
	cDtUltComp	:=	DtoC(SA1->A1_ULTCOM)
	cGerente	:=	AllTrim(SA1->A1_GERVEN)+' - '+AllTrim(Posicione('SA3', 1, xFilial('SA3')+SA1->A1_GERVEN, 'A3_NOME'))
	cObsCli		:=	SA1->A1_OBSVEND
	cEmailGer	:=	UsrRetMail(cGerente)

	nPSeg 		:= 	Ascan(aTabelas, {|X| AllTrim(X[2]) == AllTrim(cGrpSeg) })
	If nPSeg == 0

		nPSeg := Ascan(aTabelas, {|X| X[1] == Right(cGrpSeg,1) })
		If nPSeg > 0
			cGrpSeg   := aTabelas[nPSeg][02]
			cSegmento := AllTrim(aTabelas[nPSeg][03])
			//cSegmento := IIF(cGrpSeg=='REV', 'REVENDA', 		cSegmento)
			//cSegmento := IIF(cGrpSeg=='MNT', 'MANUTENÇÃO', 	cSegmento)
			//cSegmento := IIF(cGrpSeg=='OEM', 'INDUSTRIA', 	cSegmento)
		EndIf

		cDescSeg	:= 	AllTrim(Posicione('ZZV', 1, xFilial('ZZV')+cGrpSeg, 'ZZV_DESC'))
		cSegmento	:=	IIF(Empty(cDescSeg), cSegmento, cGrpSeg+' - '+cDescSeg)

	EndIf



	cHtml := '<html>'
	cHtml += '<head>'
	//cHtml += '<h3 align = Left><font size="3" face="Verdana" color="#483D8B">PEDIDO DE VENDA BLOQUEADO POR REGRA</h3></font>'
	cHtml += '<h3 align = Left><font size="2" face="Verdana" color="#483D8B">Pedido de Venda liberado pelo Gerente para analise do Setor Financeiro \ Diretor</h3></font>'
	cHtml += '<br></br>'
	cHtml += '<h3 align = Left><font size="2" face="Verdana">Filial '+cFilPV+' - '+cNomeFil+'</h3></font>'
	cHtml += '<h3 align = Left><font size="2" face="Verdana">Gerente: '+cGerente+'</h3></font>'
	cHtml += '<h3 align = Left><font size="2" face="Verdana">Pedido: '+cNumPV+'</h3></font>'
	cHtml += '<h3 align = Left><font size="2" face="Verdana">Cliente: '+cCodCli+'\'+cLojaCli+' - '+cNomeCli+'</h3></font>'
	cHtml += '<h3 align = Left><font size="2" face="Verdana">Segmento: '+cSegmento+'   Vinculo: '+cVinculo+'</h3></font>'
	cHtml += '<h3 align = Left><font size="2" face="Verdana">Dt.Ult.Compra: '+cDtUltComp+'</h3></font>'
	cHtml += '<h3 align = Left><font size="2" face="Verdana">Valor Pedido R$ : '+cTotalPV+'</h3></font>'
	cHtml += '<h3 align = Left><font size="2" face="Verdana">Cond.Pagto: '+cCondPag+'</h3></font>'
	cHtml += '<h3 align = Left><font size="2" face="Verdana">IMC PV:   '+cIMCPv+' | IMC MIN.:  '+cPvImcMin+'</h3></font>'
	cHtml += '<h3 align = Left><font size="2" face="Verdana">IMCR PV: '+cIMCRPv+' | IMCR MIN.: '+cPvImcRMin+'</h3></font>'
	cHtml += '<h3 align = Left><font size="2" face="Verdana">Observação : '+cObs+'</h3></font>'


	cHtml += '<br></br>'
	cHtml += '<b><font size="2" face="Verdana">Liberado por: '+cUserLib+'</font></b>'
	cHtml += '<br></br>'
	cHtml += '<b><font size="2" face="Verdana">Processado em: </font></b>'
	cHtml += '<b><font size="2" face="Verdana">'+Dtoc(Date())+' às '+Time()+'</font></b>'	//	color="#0000FF"
	cHtml += '<br></br>'

	cHtml += '<br></br>'
	cHtml += '<TABLE WIDTH=100% BORDER=1 BORDERCOLOR="#cccccc" CELLPADDING=4 CELLSPACING=0 STYLE="page-break-before: always">'
	cHtml += '	<TR VALIGN=TOP>'

	cHtml += '		<TD WIDTH=03%>'
	cHtml += '	   		<P><font size="1" face="Verdana"><b>Item<B></P></font> '
	cHtml += '		</TD>'

	cHtml += '		<TD WIDTH=03%>'
	cHtml += '			<P><font size="1" face="Verdana"><b>Produto</P></font> '
	cHtml += '		</TD>'

	cHtml += '		<TD WIDTH=03%>'
	cHtml += '			<P><font size="1" face="Verdana"><b>Descrição</P></font> '
	cHtml += '		</TD>'

	cHtml += '		<TD WIDTH=03%>'
	cHtml += '			<P><font size="1" face="Verdana"><b>IMC</P></font> '
	cHtml += '		</TD>'

	cHtml += '		<TD WIDTH=03%>'
	cHtml += '			<P><font size="1" face="Verdana"><b>IMC Min.</P></font> '
	cHtml += '		</TD>'

	cHtml += '		<TD WIDTH=03%>'
	cHtml += '			<P><font size="1" face="Verdana"><b>IMCR</P></font> '
	cHtml += '		</TD>'

	cHtml += '		<TD WIDTH=03%>'
	cHtml += '			<P><font size="1" face="Verdana"><b>IMCR Min.</P></font> '
	cHtml += '		</TD>'

	cHtml += '		<TD WIDTH=03%>'
	cHtml += '			<P><font size="1" face="Verdana"><b>Idade</P></font> '
	cHtml += '		</TD>'

	cHtml += '		<TD WIDTH=03%>'
	cHtml += '			<P><font size="1" face="Verdana"><b>Tab.Preco</P></font> '
	cHtml += '		</TD>'

	cHtml += '		<TD WIDTH=20%>'
	cHtml += '			<P><font size="1" face="Verdana"><b>Regra Bloqueio</P></font> '
	cHtml += '		</TD>'

	cHtml += '	</TR>'

	For nX:=1 To Len(aBloqRegra)
		//						1		2		3									4												5			6		7			8		    9        10     11
		//	Aadd(aGerente, {cItemAT, cProdAT, cDescProd, 'DESCONTO > ALÇADA e IMCR PRODUTO >= IMC.MIN e SEM BLOQ.TRAVA MASTER', 'LIB.GER', nImCProd, nImcRProd, cItTabPrc, nMrkImCMin, nIdade, .F.}) // MRK.MIN
		//	Aadd(aDiretor, {cItemAT, cProdAT, cDescProd, cTpBlqTM, 'LIB.DIR', nImCProd, nImcRProd, cItTabPrc, nImCMinRGV, nImcRMinRGV, nIdade, .F.})
		cItem 	 	:= 	aBloqRegra[nX][01]
		cCodPro  	:= 	aBloqRegra[nX][02]
		cDescPro 	:= 	aBloqRegra[nX][03]
		cBloq 	 	:= 	aBloqRegra[nX][04]
		cImCProd 	:=	cValToChar(aBloqRegra[nX][06])
		cImcRProd	:=	cValToChar(aBloqRegra[nX][07])
		cItTabPrc	:=	aBloqRegra[nX][08]
		cMrkImCMin 	:=	cValToChar(aBloqRegra[nX][09])
		cIdade	 	:=  cValToChar(aBloqRegra[nX][10])


		cHtml += '	<TR VALIGN=TOP>'

		cHtml += '		<TD VALIGN=alin_vertical WIDTH=01%>'
		cHtml += '			<P><font size="2" color="#696969" face="Verdana"><b> '+cItem+'</P></font>  '
		cHtml += '		</TD>'

		cHtml += '		<TD VALIGN=alin_vertical WIDTH=01%>'
		cHtml += '			<P><font size="2" color="#696969" face="Verdana"><b> '+cCodPro+'</P></font>  '
		cHtml += '		</TD>'

		cHtml += '		<TD VALIGN=alin_vertical WIDTH=05%>'
		cHtml += '			<P><font size="2" color="#696969" face="Verdana"><b> '+cDescPro+'</P></font>  '
		cHtml += '		</TD>'

		cHtml += '		<TD VALIGN=alin_vertical WIDTH=05%>'
		cHtml += '			<P><font size="2" color="#696969" face="Verdana"><b> '+cImCProd+'</P></font>  '
		cHtml += '		</TD>'

		cHtml += '		<TD VALIGN=alin_vertical WIDTH=05%>'
		cHtml += '			<P><font size="2" color="#696969" face="Verdana"><b> '+cMrkImCMin+'</P></font>  '
		cHtml += '		</TD>'

		cHtml += '		<TD VALIGN=alin_vertical WIDTH=05%>'
		cHtml += '			<P><font size="2" color="#696969" face="Verdana"><b> '+cImcRProd+'</P></font>  '
		cHtml += '		</TD>'

		cHtml += '		<TD VALIGN=alin_vertical WIDTH=05%>'
		cHtml += '			<P><font size="2" color="#696969" face="Verdana"><b> '+cMrkImCMin+'</P></font>  '
		cHtml += '		</TD>'

		cHtml += '		<TD VALIGN=alin_vertical WIDTH=05%>'
		cHtml += '			<P><font size="2" color="#696969" face="Verdana"><b> '+cIdade+'</P></font>  '
		cHtml += '		</TD>'

		cHtml += '		<TD VALIGN=alin_vertical WIDTH=05%>'
		cHtml += '			<P><font size="2" color="#696969" face="Verdana"><b> '+cItTabPrc+'</P></font>  '
		cHtml += '		</TD>'

		cHtml += '		<TD VALIGN=alin_vertical WIDTH=05%>'
		cHtml += '			<P><font size="2" color="#696969" face="Verdana"><b> '+cBloq+'</P></font>  '
		cHtml += '		</TD>'

		cHtml += '	</TR>'

	Next
	cHtml += '</TABLE>                          '
	cHtml += '<P STYLE="margin-bottom: 0cm"><BR>'
	cHtml += '</P>'


	cHtml += '<br></br>'
	cHtml += '</head>'
	cHtml += '<body bgcolor = white text=black>'
	cHtml += '<hr width=100% noshade>'
	cHtml += '<br></br>'


	IIF(!ExisteSX6('IMD_EMLIBE'),	CriarSX6('IMD_EMLIBE', 'C','Envia e-mail para X Niveis - FT210OPC.PRW', '3' ),)	//1-GERENTE; 2-FINANCEIRO; 3-DIRETOR
	cParEnvia := AllTrim(GetMv('IMD_EMLIBE'))

	cEnvEmail := ''
	DbSelectArea("ZRL");DbGoTop()
	Do While !Eof()
		lRegAtiva	:=	IIF(ZRL->ZRL_STATUS!='2', .T., lRegAtiva)	//1=ATIVO; 2=INATIVO
		lEnvia		:=	IIF(ZRL->ZRL_NIVEL $ cParEnvia, .T., .F.)
		cEnvEmail	+=	IIF(lRegAtiva.And.lEnvia, AllTrim(UsrRetMail(ZRL->ZRL_CODUSR))+';','')
		DbSkip()
	EndDo

	cEnvEmail	:=	IIF(Right(cEnvEmail,1)==';',SubStr(cEnvEmail,1,Len(cEnvEmail)-1),cEnvEmail)

	cRotina		:=	'FT210OPC'
	cAssunto	:=	'Filial: '+cFilPV+' Pedido: '+cNumPV+' Bloq.Regra'
	cPara		:=  cEnvEmail
	cCopia		:=	''//
	cCopOcult	:=	''
	cCorpoEmail	:=	cHtml
	cAtachado	:=	''

	U_ENVIA_EMAIL(cRotina, cAssunto, cPara, cCopia, cCopOcult, cCorpoEmail, cAtachado)

Return()