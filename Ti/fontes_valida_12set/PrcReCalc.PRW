#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#DEFINE  ENTER CHR(13)+CHR(10)


/*
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбддддддддддд©╠╠
╠╠ЁFun┤ao    ЁPrcReCalc ЁAutor  ЁFabiano Pereira        ЁData  Ё03/09/2014 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддаддддддддддд╢╠╠
╠╠ЁParametrosЁ                                                             Ё╠╠
╠╠Ё          ЁParam1: Numero da Linha                                      Ё╠╠
╠╠Ё          ЁParam2: Forca a Execucao da Rotina para Recalcular Valores   Ё╠╠
╠╠Ё          ЁParam3: Verifica Item deletado.(Utilizado na troca UA_TABELA)Ё╠╠
╠╠Ё          ЁParam4: Atualiza apenas o aProdXImp, nao aCols               Ё╠╠
╠╠Ё          Ё                                                             Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁDescri┤ao ЁEsta funcao efetua os calculos de impostos (ICMS,PIS,COF,etc)Ё╠╠
╠╠Ё          Ёcom base nas funcoes fiscais, a fim de possibilitar ao usua- Ё╠╠
╠╠Ё          Ёrio o valor de desembolso financeiro.                        Ё╠╠
╠╠Ё          Ё                                                             Ё╠╠
╠╠Ё          ЁRetorno: Valor do campo que disparou o gatilho               Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁObs.:     ЁEh necessario ReCalcular os valores ao clicar nos campos     Ё╠╠
╠╠Ё          ЁUB_PRODUTO, UB_QUANT pq X3_VALID tem a funcao Tk273Calcula   Ё╠╠
╠╠Ё          Ёque atualiza o UB_VRUNIT com a valor padrao do sistema e     Ё╠╠
╠╠Ё          Ёdesconsidera Novo Preco (PrecoNet+Impostos)                  Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       ЁGenerico                                                     Ё╠╠
╠╠юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
**********************************************************************
User Function PrcReCalc()
**********************************************************************
Local aArea			:= 	GetArea()
Local nLine			:=	IIF(Type('ParamIxb')== 'A', ParamIxb[01], n)
Local cBckReadVar	:=	ReadVar()
Local cReadVar		:=	SubStr(ReadVar(),04)
Local cContCpo		:=	IIF(Type(ReadVar()) == 'U', GdFieldGet(cReadVar,nLine), &(ReadVar()))
Local lTelaF11		:=	Upper(SubStr(ProcName(09),03)) == 'IMDF190'
Local lExecute		:=	IIF(Upper(SubStr(ProcName(3),03)) $ 'RUNLTRIGUER\FCRIALINHA\TK273DELTLV\F190EQUI\F190VALQTD\'.Or.Upper(ProcName(02))=='FVERREST', .F., .T.)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//| VERIFICA SE FORCA O RECALCULO DOS VALORES		   		|
//| EX.: X3_VLDUSER UB_QUANT                          		|
//|		  NOS CASOS ONDE Eh CRIADO MAIS UMA LINHA NO aCols	|
//|		  IMDF051.PRW										|
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
If !lExecute .And. Type('ParamIxb')=='A'
	If Len(ParamIxb)>=2 
		lExecute := ParamIxb[02]
	EndIf
EndIf


//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//| FUNCAO IMDF051 NOS CASOS ONDE Eh CRIADA NOVA LINHA NO	|
//| ACOLS Eh EXECUTADO A ULTIMA LINHA MAIS UMA VEZ.   		|
//|	COM ISSO ESTA CALCULANDO OS IMPOSTOS NOVAMENTE.         |
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
If Type('ParamIxb')=='A' .And. lExecute
// 	Local lIMDF051		:=	Upper(SubStr(ProcName(04),03)) == 'IMDF051'
//	Local lTelaF11		:=	Upper(SubStr(ProcName(10),03)) == 'IMDF190' 
//	eVal( oGetTlv:obrowse:bAdd ) //| ADICIONA UMA LINHA NA GETDADOS AUTOMATICAMENTE
	If Upper(SubStr(ProcName(09),03)) == 'IMDF190'
		If ParamIxb[01] != n
			// VERIFICA TANTO O NUM DA LINHA DO ParamIxb QTO DO "n" SE EXISTE NO aProdXImp
			If Ascan(aProdXImp, {|X| X[01] == StrZero(n, TamSx3('UB_ITEM')[01]) }) > 0 .And.;
			   Ascan(aProdXImp, {|X| X[01] == StrZero(ParamIxb[01], TamSx3('UB_ITEM')[01]) }) > 0
				lExecute := .F.
			EndIf
		EndIf
	EndIf
EndIf


//здддддддддддддддддддддддддддддддддддддддддддддддддддд©
//| UTILIZADO QUANDO VARIAVEL DE MEMORIA NAO EXISTE.   |
//| EX.: M->UB_PRODUTO NA TELA QUE CHECA O ESTOQUE     |
//|		  IMDF051.PRW -> FAbreTela()   				   |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддды
If Type(ReadVar()) == 'U'
	&(ReadVar()) := cContCpo
EndIf 

Private nPosProd	:=	0
Private cCampo		:=	SubStr(ReadVar(),04)
Private nLinha		:=	IIF(Type('ParamIxb')== 'A', ParamIxb[01], n)
Private lDeletado	:=	IIF(Type('aCols')   == 'A', aCols[nLinha][Len(aHeader)+1], .T.)
Private lCheckDel	:=	IIF(Type('ParamIxb')== 'A', IIF(Len(ParamIxb)>=3, ParamIxb[03], .F.), .F.)
Private lOnlyArray	:=	IIF(Type('ParamIxb')== 'A', IIF(Len(ParamIxb)>=4, ParamIxb[04], .F.), .F.)
Private lWillDel	:=	IIF(Type('ParamIxb')== 'A', IIF(Len(ParamIxb)>=5, ParamIxb[05], .F.), .F.)
Private lTelaDesc	:= 	Upper(SubStr(ProcName(3),03)) == 'CALCPRUN' .Or. Upper(SubStr(ProcName(2),03)) == 'CALCPRUN'
Private lDescGeral 	:= 	Upper(SubStr(ProcName(6),03)) == 'REPLACRDESG'
Private lHistorico 	:= 	Upper(SubStr(ProcName(7),03)) == 'TLVENT' .Or. Upper(SubStr(ProcName(6),03)) == 'TLVENT'
Private lCondPgto 	:= 	cCampo == 'UA_CONDPG' .Or. (Upper(SubStr(ProcName(8),03))$'TMKVLDE4\TMKVCP'.And. Upper(SubStr(ProcName(6),03))=='ACOLSRECALC') // USUARIO ALTEROU COND.PGTO NO BTN.COND.PGATO
Private lTelaF6		:=	(Upper(SubStr(ProcName(8),03))=='TMKVLDE4'.And. Upper(SubStr(ProcName(6),03))=='ACOLSRECALC') // USUARIO ALTEROU (VIA F6) COND.PGTO NO BTN.COND.PGATO
Private lCorreia	:=	.F.



/*
If !Empty(cCodProd)
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//|POSICIONA TABELAS NA XX_BASE CORRETA E VERIFICA SE ALIAS() ESTA VAZIA	|
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	ExecBlock('ChkPosBase',.F.,.F., {'ChkCorreias', ''})
	cBase  		:= 	A093VldBase(cCodProd)
	lCorrOpen	:=	IIF(AllTrim(cBase) == '02', .T., .F.)		// 01-FECHADAS, 02-ABERTAS
	ExecBlock('ChkPosBase',.F.,.F., {'ChkCorreias', cBase})
EndIf
*/
IIF(Select('SBP')==0.Or.Empty(Alias()), (ChkFile('SBP'),DbSelectArea("SBP")),); SBP->(DbGoTop())
lCorreia := !Empty(A093VldBase(GdFieldGet("UB_PRODUTO",nLinha)))

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//| 'TMKVLDE4'																						 |
//| VERIFICA SE CHAMADO Eh DO TMKVLDE4 (BTN. COND.PAGTO) VALIDACAO SE USUARIO TROCOU A COND.PAGTO    |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

Private lNF_SUFRAMA	:=	MaFisRet(,"NF_DESCZF") > 0		//	MaFisRet(,"NF_SUFRAMA")
Private cIT_Campo 	:= ''
Private cNotCalcImp := 'IPI\ICR'
Private nE4Acresc 	:= 	Posicione('SE4',1,xFilial('SE4')+M->UA_CONDPG,'E4_ACRSFIN')
Private lRegraDesc 	:= 	M->UA_DESC1 + M->UA_DESC2 +M->UA_DESC4  + IIF(nLinha > 0, (GdFieldGet('UB_DESCVEN',nLinha) + GdFieldGet('UB_DESC',nLinha) + GdFieldGet('UB_DESCRD',nLinha)), 0) > 0
Private lImposto	:= .F.		//	VARIAVEL VERIFICA SE O ITEM TEM IMPOSTO
Private lCheckQtd  	:= .T.
Private lAltCabec 	:= .F.
Private lFirstRun	:= .T.	

//здддддддддддддддддддддд©
//| 	TELEVENDAS 		 |
//юдддддддддддддддддддддды
Private nPTotal   := Ascan(aHeader,{|x| AllTrim(x[2]) == "UB_VLRITEM"	})
Private nPPrUnit  := Ascan(aHeader,{|x| AllTrim(x[2]) == "UB_VRUNIT"	})
Private nPProduto := Ascan(aHeader,{|x| AllTrim(x[2]) == "UB_PRODUTO"	})
Private nPDescri  := Ascan(aHeader,{|x| AllTrim(x[2]) == "UB_DESCRI"	})
Private nPItem	  := Ascan(aHeader,{|x| AllTrim(x[2]) == "UB_ITEM"		})
Private nPQuant   := Ascan(aHeader,{|x| AllTrim(x[2]) == "UB_QUANT"	})
Private nPBaseI   := Ascan(aHeader,{|x| AllTrim(x[2]) == "UB_BASEICM"	})

Private nPPAcre   := Ascan(aHeader,{|x| AllTrim(x[2]) == "UB_ACRE"		})
Private nPVAcre   := Ascan(aHeader,{|x| AllTrim(x[2]) == "UB_VALACRE"	})
Private nPPDesc   := Ascan(aHeader,{|x| AllTrim(x[2]) == "UB_DESC"		})
Private nPVDesc   := Ascan(aHeader,{|x| AllTrim(x[2]) == "UB_VALDESC"	})
Private nPVlrST   := Ascan(aHeader,{|x| AllTrim(x[2]) == "UB_ST"		})
Private nPTES	  := Ascan(aHeader,{|x| AllTrim(x[2]) == "UB_TES"		})
Private nPPrcTab  := Ascan(aHeader,{|x| AllTrim(x[2]) == "UB_PRCTAB"	})
Private nPDesVen  := Ascan(aHeader,{|x| AllTrim(x[2]) == "UB_DESCVEN"	})

Private nPPrcAcr  := Ascan(aHeader,{|x| AllTrim(x[2]) == "UB_VRCACRE"	})
Private nPTotAcr  := Ascan(aHeader,{|x| AllTrim(x[2]) == "UB_TOTACRE"	})

Private _MERCADORIA	:=	1	// [1] VALOR TOTAL DO MERCADORIA
Private _DESCONTO	:=	2	// [2] VALOR TOTAL DO DESCONTO
Private _ACRESCIMO	:=	3	// [3] VALOR DO ACRESCIMO FINANCEIRO DA CONDICAO DE PAGAMENTO
Private _FRETE		:=	4	// [4] VALOR TOTAL DO FRETE
Private _DESPESA	:=	5	// [5] VALOR TOTAL DA DESPESA
Private _TOTAL		:=	6	// [6] TOTAL DO PEDIDO
Private _SUFRAMA	:=	7	// [7] VALOR TOTAL DA SUFRAMA
Private _BASEDUP	:=	8	// [8] BASE DA DUPLICATA (VALOR LМQUIDO DA CONDIГЦO DE PAGAMENTO)


//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//|	ParamIxb																	|
//|	ParamIxb[1]	= Numero da Linha												|
//| ParamIxb[2] = Forca a Execucao da Rotina para Recalcular Valores			|
//|	ParamIxb[3] = Verifica Item deletado.(Utilizado na troca UA_TABELA)			|
//|	ParamIxb[4] = Atualiza apenas o aProdXImp, nao aCols						|
//|	ParamIxb[5] = Item sera deletado (Casos Qtd > Est Cria nova linha IMDF051)	|
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?


//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//|	 NAO RODAR RECALCULO PARA AS SEGUINTES CHAMADAS						|
//|																		|
//|  IMDF051.PRW - 	X3_VLDUSER - Validacao do Campo UB_QUANT. 			|
//|					Abre Tela com Estoque de outras filiais...			|
//|																		|
//| IMDF051.PRW->FCarQtd()->RUNLTRIGUER() [Joga o nQtdDig para SUB]		|
//| IMDF051.PRW->FCRIALINHA() [Cria Linha e Joga Produto no SUB]     	|
//|	 IMDF051.PRW->FVERREST() [Lanca a Qtd restante para o SUB] 			|
//|																		|
//|	 IMDF190.PRW->F190VALQTD()  [Joga valores da Tela F11 para aCols]	|
//|  IMDF190.PRW->F190EQUI()	[Joga valores da Tela F11 para aCols]	|
//|																		|
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?


//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//|	Public aProdxImp  := {}	[ TmkActive.prw ]											|
//|																						|
//| lDeletado	==	VERIFICA SE LINHA ESTA DELETADA										|
//|																						|
//| lCheckDel	==	VARIAVEL UTILIZADA PARA CONTROLAR SE DEVE ANALISAR LINHA DO ACOLS   |
//|                 QUE ESTA DELETADA. Ex.: TROCA DE TABELA\CLIENTE 					|
//|																						|
//| lAtuBase	==	VARIAVEL CONTROLA SE DEVE OU NAO RODAR A FUNCAO QUE ZERA\RESTAURA 	|
//|					DESPESAS\ACRESCIMO (FUNCAO FAZ COM QUE DESPESAS RATEADA NA BASEICMS |
//|					E ADICIONADOS ACRESC.FIN)											|
//|																						|
//| lOnlyArray	==	.F. SIGNIFICA QUE DVE APENAS ALIMENTAR O ARRAY aProdXImp E NAO      |
//|					ATUALIZAR O ACOLS. EX.: HISTORICO DE ATENDIMENTO.					|
//|																						|
//| cNotCalcImp	==	NAO CONSIDERAR NO CALCULO DO NOVO PRECO ESSES IMPOSTOS - IPI\ICR	|
//|					- IPI ESTA EMBUTIDO NAS PARCELAS DOS TITULOS						|
//|					- ICMS RETIRDO ESTA INCLUSO NO TOTAL DA NOTA						|
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?


//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//| COMPORTAMENTO DESPESA \ ACRESCIMO FINANCEIRO                                        |
//цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//|                                                                                    	|
//|. GATILHO CONTATO PREENCHE DEPESA  [ IncDesp() ] 				                    |
//|                                                                                    	|
//| AO INFORMAR PRODUTO, NOVOS ITENS, NAO CONSIDERA DESPESA\ACRES. [ PrcReCalc() ]		|
//| 2.1. UB_VRCACRE = (PRC.TAB-REGRA DESC)+IMPOSTOS+ACRES.FIN                          	|
//|																						|
//|. BOTAO COND.PAGAMENTO 				                                                |
//|    3.1. NA CHAMADA DA TELA DE COND.PAG Eh RATEADO DESP\ACRES (NA BASE DO ICMS) 		|
//|			 AO(s) ITEM(s) PARA COMPOR O VALOR DE CADA PARCELA [ TMKVLDE4 ]				|
//|                                                                                    	|
//|    3.2. AO FECHAR TELA DE COND.PAG Eh ZERADO AS DESPESAS E DESFEITO O RATEADO DO(s)	|
//|         ITEM(s) (BASE DO ICMS Eh RESTAURADA AO VALOR ORIGINAL) [ TMKVCP ] 			|
//|                                                                                    	|
//|. AO CONFIRMAR O ATENDIMENTO Eh REALIZADO O RATEIO IDEM 3.1  [ TKGRPED ] 			|
//|    4.1 CASO NAO FOI CONFIRMADA O ATENDIMENTO NцO Eh POSSIVEL DESFAZER O RATEIO		|
//| 		(NAO HA P.E NESSE MOMENTO \ BASE ICMS FICARA COM DESPESAS\ACRES.FINANCEIRO)	| 
//|			 AO INFORMAR NOVO PRODUTO VOLTARA O VALOR DA BASE SEM ACRES.\DESPESA		|
//|			                                                                        	|
//|			                                                                        	|
//|* NAO CONSIDERAR IPI e ICMS RETIDO PARA COMPOR O VALOR UNITаRIO DO PRODUTO			|
//|* IPI ESTA COMPONDO O VALOR DA PARCELA DO(S) TITULO(s)				                |
//|* ICMS RETIDO COMPOEM TOTAL DA NOTA			                                        |
//|			                                                                        	|
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//| ARRAY aValores							                                                        |
//цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//|#DEFINE MERCADORIA		1	// Valor total do mercadoria										|
//|#DEFINE DESCONTO			2	// Valor total do desconto											|
//|#DEFINE ACRESCIMO		3	// Valor do acrescimo financeiro da condicao de pagamento			|
//|#DEFINE FRETE			4	// Valor total do frete												|
//|#DEFINE DESPESA			5	// Valor total da despesa											|
//|#DEFINE TOTAL			6	// Total do pedido													|
//|#DEFINE SUFRAMA			7	// Valor total da suframa											|
//|#DEFINE BASEDUP			8	// Base da duplicata (Valor lМquido da condiГЦo de pagamento)		|
//|                                                 									            |
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//| CABEC DO ARRAY - DADOS GERAIS                                                                   |
//цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//|Aadd(aProdxImp, {	aCols[n][nPItem],;			//	[01] ITEM          							|
//|						aCols[n][nPProduto],;		//	[02] COD.PRODUTO              				|
//|						cDescProd,;					//	[03] DESCRICAO DO PRODUTO            		|
//| 					0 ,;						//	[04] PRECO DE TABELA                      	|
//| 					0 ,;						//	[05] VLR.PRODUTO + IMPOSTOS               	|
//| 					0 ,;						//	[06] VLR. TOTAL IMPOSTOS 2 DECIMAIS      	|
//| 					aCols[n][nPQuant],;			//	[07] QUANTIDADE               				|
//| 					'',;						//  [08] MAIOR QTD\R$\TES (CONSULTADO X OFERT)  |
//| 					'',; 						//	[09] PROJETO CORREIAS                      	|
//|                    	nVlrSuframa ,;				//	[10] DESCONTO SUFRAMA(ICMS/PIS/COFINS)		|
//|                    	aCols[n][nPTES],;	        //  [11] TES							        |
//|                    	Cliente\Loja,;              //  [12] Cliente\Loja							|
//|                    	Condicao Pagamento,;        //  [13] Cond.Pagamento							|
//|                    	Tabela de Preco,; 	 	    //  [14] Tabela de Preco						|
//|						aCols[nLinha][nPPrUnit],;	//	[15] R$ Preco Unit. 						|
//|						M->UA_DESC4,;				//	[16] % Desconto Cabec						|
//|						0,;  						//	[17] VLR. TOTAL IMPOSTOS 4 DECIMAIS			|
//|						0,;							//	[18] PRECO A SER PRATICADO                 	|
//|						0,;							//	[19] ALIQ.ICMS-SUF                       	|
//|						UA_DESCG,;					//	[20] % DESCONTO GERAL						|
//|						0,; 						//	[21] SOMA ALIQUOTAS IMPOSTOS				|
//|						0,; 						//	[22] PRECO DA FORMACAO DE PRECO				|
//|						UA_ACREG,;					//	[23] % ACRESCIMO CONCEDIDO VENDEDOR			|
//|						0,;							//	[24] % DESCONTO  CONCEDIDO VENDEDOR			|
//|						.F.			})				//	[25] FLAG EXISTE TES <> NO AT          		|
//цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//| ITENS DO ARRAY - DADOS DOS IMPOSTOS   ( ARRAY DENTRO DO aProdXImp )                             |
//цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//|	Aadd(aProdxImp[nPosProd], {	cImposto,;			//	[01] COD.IMPOSTO							|
//|								cDescImp,;			//	[02] DESCRICAO IMPOSTO               		|
//|								nBaseImp,;			//	[03] BASE                            		|
//|								nAliqImp,;			//	[04] ALIQUOTA                        		|
//|								nValorImp,;			//	[05] VALOR                          		|
//|								nVlImp4Dec})		//	[06] VALOR                         		 	|
//|								nTruImp4Dec})		//	[07] VALOR IMPOSTO 4DEC \ QTD -> TRUNCADO   |
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?

/*
cMsg := 'cCampo:        '+cCampo 		+ENTER
cMsg += 'ProcName(03):  '+ProcName(03)	+ENTER
cMsg += 'ProcName(10):  '+ProcName(10)	+ENTER
cMsg += 'lExecute:      '+IIF(lExecute, '.T.','.F.')+ENTER
Aviso('Tela F11!!!', cMsg ,{'Ok'},3)
//lExecute	:=	IIF(cCampo == 'UB_PRODUTO' .And. lTelaF11 .And. lExecute, .F., lExecute)		//	QUANDO TELA F11 E CAMPO PRODUTO NAO EXECUTAR PRCRECALC (JA SERA EXECUTADO NO UB_QUANT)
*/
 


nPosProd 	:=	Ascan(aProdxImp, {|X| AllTrim(X[1]) ==  AllTrim(aCols[nLinha][nPItem]) })
lPrcBase 	:= 	IIF(nPosProd > 0, .F., .T.)
lCheck	 	:=	.T.


If lExecute .And. (!lDeletado .Or. lCheckDel) // lCheckDel - Ex.: TROCA DE TABELA\CLIENTE Disp.Gatilho 

	//IIF(!lHistorico, ALERT('INICIO'), )
	//cHoraInicial:= Time()

	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	//| VERIFICA SE HOUVE ALTERACAO DE CLIENTE\COND.PAG\TABELA	|
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	If Len(aProdxImp) >= nLinha .And. nPosProd > 0

		If 	aProdxImp[nPosProd][12] != AllTrim(M->UA_CLIENTE+M->UA_LOJA) .Or.; // aProdxImp[nLinha][13] != AllTrim(M->UA_CONDPG) .Or.;
			aProdxImp[nPosProd][14] != AllTrim(M->UA_TABELA) .Or. aProdxImp[nPosProd][16] != M->UA_DESC4
			
			lAltCabec := .T.

		ElseIf cCampo == 'UB_TES' 
			lCheck	  := IIF( aProdxImp[nPosProd][11] == aCols[nLinha][nPTES], .F., lCheck   )
			lAltCabec := IIF( aProdxImp[nPosProd][11] != aCols[nLinha][nPTES], .T., lAltCabec)		
			//	SE HOUVER ALTERACAO DA TES APAGA OS ITENS DE IMPOSTOS NO ARRAY aProdXImp
		EndIf


		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		//| QDO TELA F11 E LINHA DELETADA NAO PRECIS CHECAR	 LINHA JA FOI VERIFICADA ANTERIORMENTE	|
		//| (ANTES DE SER DELETADA, POIS DEPOIS DE DELETADA NAO TINHA MAIS OS IMPOSTOS				|
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		If lTelaF11 .And. lDeletado
			lCheck := .F.
		EndIf

		//здддддддддддддддддддддддддддддддддддддддддд©
		//| VERIFICA SE DEVE ATUALIZA O PRECO BASE	 |
		//юдддддддддддддддддддддддддддддддддддддддддды
		If  GdFieldGet('UB_PRCBASE',nLinha) ==	0 .Or.;
			GdFieldGet('UB_PRODUTO',nLinha)	!= 	AllTrim(aProdxImp[nPosProd][02]).Or.;
			GdFieldGet('UB_TES',    nLinha)	!=	AllTrim(aProdxImp[nPosProd][11])

			lPrcBase := .T.

		EndIf

	EndIf
	
	






	If lCheck


		Tk273Refresh(.T.)

	
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		//| OCORRENCIA DE CASOS ONDE aNF_IMPOSTO\aValores = VAZIO  (F10)			|
		//|																			|
		//| aValores[_SUFRAMA] > 0 RODA Tk273Calcula->Tk273ReCalc QUE ZERA aValores	|
		//|	MaFisRet(1, "IT_PRCUNI") <> GdFieldGet('UB_VRUNIT', 1)					|
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		If aValores[_MERCADORIA] == 0 .Or.	aValores[_TOTAL] == 0 .Or. 	aValores[_BASEDUP] == 0

			lReCalImp := .T.
			lReCalDel := IIF(lDeletado, .F., .T.)
			lVisual   := Nil
			lSoItem   := .T.
			MaColsToFis(aHeader,aCols,nLinha,"TK271",lReCalImp,lVisual,lReCalDel,lSoItem)
			Tk273Refresh(.T.)
		EndIf

		
		//зддддддддддддддддддддддддддддддд?
		//| VERIFICA\ATUALIZA DESCONTOS   |            
		//юддддддддддддддддддддддддддддддд?
 		If !lCondPgto

			If !lHistorico

				****************************
	               lCheck := ChkDesconto()
			    ****************************
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
				//| lCheck == .F. NAO PRECISA CALCULAR NOVAMENTE			|
				//|	EX.: USUARIO INFORMOU O MESMO VALOR NO CAMPO UB_DESCRD	|
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
			
			Else

				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
				//| SE Eh UM ITEM DO HISTORICO CRIA O ITEM NO ARRAY aProdXImp 	|
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
				*****************************
					CheckImpXProd({}, .F.)
    			*****************************

				If ExecBlock('ChkRecalAT',.F.,.F.)
					//зддддддддддддддддддддддддддддддддддддддддд?
					//|  RECALCULA ATENDIMENTO > 2 DIAS UTEIS	|
					//юддддддддддддддддддддддддддддддддддддддддд?
					If lOnlyArray
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
						//| ATUALIZA CAMPO PRECO BASE DOS ATENDIMENTO > 2 DIAS									|
						//| ITEM DO HISTORICO E NAO PRECISA REFAZER OS CALCULOS (APENAS CARREGA PARA aProdXImp) |
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
							ChkPrcBase()
							lPrcBase := .F.

						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
						//| CARREGA aRegDesc (Descontos\Acrescimos Concedidos\Regra		|
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
							ChkRegDesc()

					Else
						ChkDesconto()
					EndIf
				
				
				Else
				
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
					//| ATENDIMENTO < 2 DIAS NAO PRECISA RECALCULAR VALORES			|
					//| CARREGA aRegDesc (Descontos\Acrescimos Concedidos\Regra		|
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
						ChkRegDesc()

				EndIf

			EndIf

		Else

			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
			//| OBS.: MV_PVRECAL = .T. (HABILITA RECALCULO DA TABELA DE PRECO.                          |
			//|							EX.: TROCA COND.PAGTO PRCUNIT EH RECALCULADO NO PADRAO			|
			//цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
			//| NAO RECALCULA PRC.UNIT NO PADRAO E PRECISA ATUALIZAR NOVO PRECO (OS VALORES SE MANTEM)	|
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
			//| ALTERACAO DA COND.PAGTO (F6\TMKVLDE4\ACOLSRECALC)		|
			//| ATUALIZA CAMPOS DE R$ IPI, R$ ST, R$ PRECO FINAL		|
			//| BUSCA VALORES BASEADO NO PRECO COM ACRESCIMO E QTD 1	|
			//|															|
			//|	lCheck := .F. - NAO PRECISA RECALCULAR\VERIFICAR 		|
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
			*************************************************
				CalcPrcXImp(.F.)
				ImpSobPrcAcre()
				lCheck := .F.				
	        *************************************************

   		EndIf

	EndIf
	
	




	If lCheck


		//зддддддддддддддддддддддддддддддддддддддд?
		//| CARREGA TODOS OS IMPOSTOS			  |
		//юддддддддддддддддддддддддддддддддддддддд?
		aNF_IMPOSTOS := MaFisRet(, "NF_IMPOSTOS")

		If lAltCabec
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
			//|VERIFICA SE HOUVE ALTERACAO DE CABEC. DO ATENDIMENTO			|
			//|	SE HOUVE ALTERACAO ZERA ARRAY aProdXImp 					|
			//|	OBS.: Eh NECESSARIO CARREGAR ANTES aNF_IMPOSTOS  			|
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
            *******************************
				CheckImpXProd({}, .T.)
            *******************************
		EndIf



		//зддддддддддддддддддддддддддддддддддддддддддддддддд?
		//| VERIFICA SE IMPOSTO EXISTE EM aNF_IMPOSTOS		|
		//|	 CheckImpXProd() ALIMENTA\ATUALIZA aProdXImp	|
		//юддддддддддддддддддддддддддддддддддддддддддддддддд?
		If Ascan(aNF_IMPOSTOS, {|X| 'ICM' $ X[2]} ) > 0

	        // Imposto sobre operaГУes relativas a circulaГЦo de mercadorias e sobre prestaГУes de serviГos
			// aIT_ICMS	:= MaFisRet(nLinha, "IT_ICMS") 			//	Array contendo os valores de ICMS
			nIT_BASEICM	:= MaFisRet(nLinha, "IT_BASEICM") 		//	Valor da Base de ICMS
			nIT_ALIQICM	:= MaFisRet(nLinha, "IT_ALIQICM") 		//	Aliquota de ICMS
			nIT_VALICM	:= MaFisRet(nLinha, "IT_VALICM") 		//	Valor do ICMS Normal		
			lImposto	:= IIF(lImposto, .T., nIT_VALICM > 0)
			aParametro	:= {'ICM', nIT_BASEICM, nIT_ALIQICM, nIT_VALICM, "IT_VALICM" }	//	[03]
			CheckImpXProd(aParametro)

			nIT_BASESOL	:= MaFisRet(nLinha, "IT_BASESOL") 		//	Base do ICMS Solidario
			nIT_ALIQSOL	:= MaFisRet(nLinha, "IT_ALIQSOL") 		//	Aliquota do ICMS Solidario
			nIT_VALSOL	:= MaFisRet(nLinha, "IT_VALSOL") 		//	Valor do ICMS Solidario
			lImposto	:= IIF(lImposto, .T., nIT_VALSOL > 0)
			aParametro	:= {'ICR', nIT_BASESOL, nIT_ALIQSOL, nIT_VALSOL, "IT_VALSOL" }	//	[ 19/05 ]
			CheckImpXProd(aParametro)

			nIT_BASEICM	:= MaFisRet(nLinha, "IT_BASEICM") 		//	Valor da Base de ICMS							
			nIT_ALIQCMP	:= MaFisRet(nLinha, "IT_ALIQCMP")	 	//	Aliquota para calculo do ICMS Complementar
			nIT_VALCMP	:= MaFisRet(nLinha, "IT_VALCMP") 		//	Valor do ICMS Complementar do item
			lImposto	:= IIF(lImposto, .T., nIT_VALCMP > 0)
			aParametro	:= {'ICC', 0, nIT_ALIQCMP,  nIT_VALCMP, "IT_VALCMP" }	//	[12/22]
			CheckImpXProd(aParametro)

			nIT_BASEICA	:= MaFisRet(nLinha, "IT_BASEICA") 		//	Base do ICMS sobre o frete autonomo
			nIT_VALICA	:= MaFisRet(nLinha, "IT_VALICA") 		//	Valor do ICMS sobre o frete autonomo
			nIT_VALICA	:= MaFisRet(nLinha, "IT_VALICA") 		//	Valor do Frete Autonomo
			lImposto	:= IIF(lImposto, .T., nIT_VALICA > 0)
			aParametro	:= {'ICA', nIT_BASEICA, nIT_VALICA, nIT_VALICA, "IT_VALICA" }		// [ 20 ]
			CheckImpXProd(aParametro)
						                                   
			nIT_BASETST	:= MaFisRet(nLinha, "IT_BASETST")  		//	Base do ICMS sobre o frete autonomo
			nIT_ALIQTST	:= MaFisRet(nLinha, "IT_ALIQTST")  		//	Valor do ICMS sobre o frete autonomo
			nIT_VALTST	:= MaFisRet(nLinha, "IT_VALTST")  		//	Valor do Frete Autonomo
			lImposto	:= IIF(lImposto, .T., nIT_VALTST > 0)
			aParametro	:= {'TST', nIT_BASETST, nIT_ALIQTST, nIT_VALTST, "IT_VALTST" }		// [ 21 ]
			CheckImpXProd(aParametro)

		EndIf

   		
   		If Ascan(aNF_IMPOSTOS, {|X| 'IPI' $ X[2]} )  > 0
	        // O Imposto sobre Produtos Industrializados
			// aIT_IPI 	:= MaFisRet(nLinha, "IT_IPI")			//	Array contendo os valores de IPI

			nIT_BASEIPI	:= MaFisRet(nLinha, "IT_BASEIPI") 		//	Valor da Base do IPI
			nIT_ALIQIPI	:= MaFisRet(nLinha, "IT_ALIQIPI") 		//	Aliquota de IPI
			nIT_VALIPI 	:= MaFisRet(nLinha, "IT_VALIPI") 		//	Valor do IPI
			lImposto	:= IIF(lImposto, .T., nIT_VALIPI > 0)
			aParametro	:= {'IPI', nIT_BASEIPI, nIT_ALIQIPI, nIT_VALIPI, "IT_VALIPI" }	//	[04]
			CheckImpXProd(aParametro)

	    EndIf
	    

   		If Ascan(aNF_IMPOSTOS, {|X| 'ISS' $ X[2]} ) > 0
			//	Instituto Nacional do Seguro Social
			// aIT_ISS 	:= MaFisRet(nLinha, "IT_ISS") 			//	Array contendo os valores de ISS
			nIT_BASEISS := MaFisRet(nLinha, "IT_BASEISS")		//	Base de Calculo do ISS
			nIT_ALIQISS	:= MaFisRet(nLinha, "IT_ALIQISS")  		//	Aliquota de ISS do item
			nIT_VALISS 	:= MaFisRet(nLinha, "IT_VALISS")			//	Valor do ISS do item
			lImposto	:= IIF(lImposto, .T., nIT_VALISS > 0)
			aParametro	:= {'ISS', nIT_BASEISS, nIT_ALIQISS, nIT_VALISS, "IT_VALISS" }	//	[02]
			CheckImpXProd(aParametro)
		EndIf

   		If Ascan(aNF_IMPOSTOS, {|X| 'IRR' $ X[2]} ) > 0
			// aIT_IR 		:= MaFisRet(nLinha, "IT_IR")			//	Array contendo os valores do Imposto de renda
			nIT_BASEIRR := MaFisRet(nLinha, "IT_BASEIRR")		//	Base do Imposto de Renda do item
			nIT_ALIQIRR	:= MaFisRet(nLinha, "IT_ALIQIRR") 		//	Aliquota de Calculo do IR do Item
			nIT_VALIRR 	:= MaFisRet(nLinha, "IT_VALIRR")			//	Valor do IR do Item
			lImposto	:= IIF(lImposto, .T., nIT_VALIRR > 0)
			aParametro	:= {'IRR', nIT_BASEIRR, nIT_ALIQIRR, nIT_VALIRR, "IT_VALIRR" }	//	[01]
			CheckImpXProd(aParametro)
		EndIf

   		If Ascan(aNF_IMPOSTOS, {|X| 'INSS' $ X[2]} ) > 0
			//	(Instituto Nacional do Seguro Social
			// aIT_INSS 	:= MaFisRet(nLinha, "IT_INSS")		//	Array contendo os valores de INSS
			nIT_BASEINS	:= MaFisRet(nLinha, "IT_BASEINS") 		//	Base de calculo do INSS
			nIT_ALIQINS	:= MaFisRet(nLinha, "IT_ALIQINS") 		//	Aliquota de Calculo do INSS
			nIT_VALINS 	:= MaFisRet(nLinha, "IT_VALINS")			//	Valor do INSS
			lImposto	:= IIF(lImposto, .T., nIT_VALINS > 0)
			aParametro	:= {'INS', nIT_BASEINS, nIT_ALIQINS, nIT_VALINS, "IT_VALINS" }	//	[06]
			CheckImpXProd(aParametro)
		
			nIT_BASEINA	:= MaFisRet(nLinha, "IT_BASEINA") 		//	Base de calculo do INSS CondiГУes Especiais
			IT_ALIQINA  := MaFisRet(nLinha, "IT_ALIQINA")		//	Aliquota de calculo do INSS CondiГУes Especiais
			nIT_VALINA	:= MaFisRet(nLinha, "IT_VALINA") 		//	Valor do INSS CondiГУes Especiais
			lImposto	:= IIF(lImposto, .T., nIT_VALINA > 0)
			aParametro	:= {'INA', nIT_BASEINA, nIT_ALIQINA, nIT_VALINA, "IT_VALINA" }	//	[23]
			CheckImpXProd(aParametro)		
		EndIf				



   		If Ascan(aNF_IMPOSTOS, {|X| 'PIS' $ X[2]} ) > 0
			// Programa de IntegraГЦo Social

			nIT_BASEPIS	:= MaFisRet(nLinha, "IT_BASEPIS") 		//	Base de calculo do PIS
			nIT_ALIQPIS := MaFisRet(nLinha, "IT_ALIQPIS")		//	Aliquota de calculo do PIS
			nIT_VALPIS 	:= MaFisRet(nLinha, "IT_VALPIS")			//	Valor do PIS
			lImposto	:= IIF(lImposto, .T., nIT_VALPIS > 0)
			aParametro	:= {'PIS', nIT_BASEPIS, nIT_ALIQPIS, nIT_VALPIS, "IT_VALPIS" }	//	[09] - 'PIS - Via RetenГao'
			CheckImpXProd(aParametro)

			
			nIT_BASEPIS	:= MaFisRet(nLinha, "IT_BASEPS2") 		//	Base de calculo do PIS
			nIT_ALIQPIS := MaFisRet(nLinha, "IT_ALIQPS2")		//	Aliquota de calculo do PIS
			nIT_VALPIS 	:= MaFisRet(nLinha, "IT_VALPS2")		//	Valor do PIS
			lImposto	:= IIF(lImposto, .T., nIT_VALPIS > 0)
			aParametro	:= {'PS2', nIT_BASEPIS, nIT_ALIQPIS, nIT_VALPIS, "IT_VALPS2" }	//	[07] - 'PIS - Via ApuraГЦo'
			CheckImpXProd(aParametro)

			
			nIT_BASEPIS	:= MaFisRet(nLinha, "IT_BASEPS3") 		//	Base de calculo do PIS
			nIT_ALIQPIS := MaFisRet(nLinha, "IT_ALIQPS3")		//	Aliquota de calculo do PIS
			nIT_VALPIS 	:= MaFisRet(nLinha, "IT_VALPS3")			//	Valor do PIS
			lImposto	:= IIF(lImposto, .T., nIT_VALPIS > 0)
			aParametro	:= {'PS3', nIT_BASEPIS, nIT_ALIQPIS, nIT_VALPIS, "IT_VALPS3" }	//	[13] - 'PIS - Subst. Tributaria'
			CheckImpXProd(aParametro)


		EndIf



   		If Ascan(aNF_IMPOSTOS, {|X| 'COF' $ X[2]} )  > 0
			// ContribuiГЦo para o Financiamento da Seguridade Social
			nIT_BASECOF := MaFisRet(nLinha, "IT_BASECOF")		//	Base de calculo do COFINS
			nIT_ALIQCOF := MaFisRet(nLinha, "IT_ALIQCOF")		//	Aliquota de calculo do COFINS		
			nIT_VALCOF	:= MaFisRet(nLinha, "IT_VALCOF") 		//	Valor do COFINS
			lImposto	:= IIF(lImposto, .T., nIT_VALCOF > 0)
			aParametro	:= {'COF', nIT_BASECOF, nIT_ALIQCOF, nIT_VALCOF, "IT_VALCOF" }	//	[08] - 'COFINS - Via ApuraГЦo'
			CheckImpXProd(aParametro)
			
					
			nIT_BASECOF := MaFisRet(nLinha, "IT_BASECF2") 		//	Base de calculo do COFINS
			nIT_ALIQCOF := MaFisRet(nLinha, "IT_ALIQCF2") 		//	Aliquota de calculo do COFINS		
			nIT_VALCOF	:= MaFisRet(nLinha, "IT_VALCF2")  		//	Valor do COFINS
			lImposto	:= IIF(lImposto, .T., nIT_VALCOF > 0)
			aParametro	:= {'CF2', nIT_BASECOF, nIT_ALIQCOF, nIT_VALCOF, "IT_VALCF2" }	//	[10] - 'COFINS - Via RetenГao'
			CheckImpXProd(aParametro)

			
			nIT_BASECOF := MaFisRet(nLinha, "IT_BASECF3") 		//	Base de calculo do COFINS
			nIT_ALIQCOF := MaFisRet(nLinha, "IT_ALIQCF3") 		//	Aliquota de calculo do COFINS		
			nIT_VALCOF	:= MaFisRet(nLinha, "IT_VALCF3")  		//	Valor do COFINS
			lImposto	:= IIF(lImposto, .T., nIT_VALCOF > 0)
			aParametro	:= {'CF3', nIT_BASECOF, nIT_ALIQCOF, nIT_VALCOF, "IT_VALCF3" }	//	[14] - 'COFINS - Subst. Tributaria'
			CheckImpXProd(aParametro)

			
	    EndIf
            


   		If Ascan(aNF_IMPOSTOS, {|X| 'CSL' $ X[2]} ) > 0
			// ContribuiГЦo Social sobre o Lucro LМquido
			nIT_BASECSL	:= MaFisRet(nLinha, "IT_BASECSL") 		//	Base de calculo do CSLL
			nIT_ALIQCSL := MaFisRet(nLinha, "IT_ALIQCSL")		//	Aliquota de calculo do CSLL
			nIT_VALCSL	:= MaFisRet(nLinha, "IT_VALCSL") 		//	Valor do CSLL
			lImposto	:= IIF(lImposto, .T., nIT_VALCSL > 0)
			aParametro	:= {'CSL', nIT_BASECSL, nIT_ALIQCSL, nIT_VALCSL, "IT_VALCSL" }	//	[11]
			CheckImpXProd(aParametro)
        EndIf
        
   		If Ascan(aNF_IMPOSTOS, {|X| 'FUN' $ X[2]} ) > 0
			//	Fundo de AssistЙncia ao Trabalhador Rural		
			nIT_BASEFUN	:= MaFisRet(nLinha, "IT_BASEFUN") 		//	Base de calculo do FunRural
			nIT_PERFUN  := MaFisRet(nLinha, "IT_PERFUN")			//	Aliquota de calculo do FunRural
			nIT_FUNRURAL:= MaFisRet(nLinha, "IT_FUNRURAL") 		//	Valor do FunRural
			lImposto	:= IIF(lImposto, .T., nIT_FUNRURAL > 0)
			aParametro	:= {'FRU', nIT_BASEFUN, nIT_PERFUN, nIT_FUNRURAL, "IT_FUNRURAL" }		//	[24]
			CheckImpXProd(aParametro)
		EndIf	

   		If Ascan(aNF_IMPOSTOS, {|X| 'SES' $ X[2]} ) > 0
			nIT_BASESES	:= MaFisRet(nLinha, "IT_BASESES") 		//	Base de calculo do SEST/SENAT
			nIT_ALIQSES := MaFisRet(nLinha, "IT_ALIQSES")			//	Aliquota de calculo do SEST/SENAT
			nIT_VALSES	:= MaFisRet(nLinha, "IT_VALSES") 		//	Valor do SEST/SENAT
			lImposto	:= IIF(lImposto, .T., nIT_VALSES > 0)
			aParametro	:= {'SES', nIT_BASESES, nIT_ALIQSES, nIT_VALSES, "IT_VALSES" }		//	[15]
			CheckImpXProd(aParametro)
		EndIf	

   		If Ascan(aNF_IMPOSTOS, {|X| 'FET' $ X[2]} ) > 0
			// Fundo Estadual de Transporte e HabitaГЦo (FETHAB) - MT
			nIT_BASEFET	:= MaFisRet(nLinha, "IT_BASEFET")  		//	Base de calculo do FETHAB
			nIT_ALIQFET := MaFisRet(nLinha, "IT_ALIQFET") 		//	Aliquota de calculo do FETHAB
			nIT_VALFET	:= MaFisRet(nLinha, "IT_VALFET")  		//	Valor do FETHAB
			lImposto	:= IIF(lImposto, .T., nIT_VALFET > 0)
			aParametro	:= {'FET', nIT_BASEFET, nIT_ALIQFET, nIT_VALFET, "IT_VALFET" }		//	[16]
			CheckImpXProd(aParametro)
	    EndIf
	
  		If Ascan(aNF_IMPOSTOS, {|X| 'FAV' $ X[2]} ) > 0
			// Fundo de Apoio a Bovinocultura de Corte
			nIT_BASEFAB	:= MaFisRet(nLinha, "IT_BASEFAB") 		//	Base de calculo do FABOV
			nIT_ALIQFAB := MaFisRet(nLinha, "IT_ALIQFAB") 		//	Aliquota de calculo do FABOV
			nIT_VALFAB	:= MaFisRet(nLinha, "IT_VALFAB")  		//	Valor do FABOV
			lImposto	:= IIF(lImposto, .T., nIT_VALFAB > 0)
			aParametro	:= {'FAB', nIT_BASEFAB, nIT_ALIQFAB, nIT_VALFAB, "IT_VALFAB" }		//	[17]
			CheckImpXProd(aParametro)
	    EndIf
	         
   		If Ascan(aNF_IMPOSTOS, {|X| 'FAC' $ X[2]} ) > 0
			// Fundo de Apoio a Cultura da Soja (FACS) - MT
			nIT_BASEFAC	:= MaFisRet(nLinha, "IT_BASEFAC") 		//	Base de calculo do FACS
			nIT_ALIQFAC := MaFisRet(nLinha, "IT_ALIQFAC") 		//	Aliquota de calculo do FACS
			nIT_VALFAC	:= MaFisRet(nLinha, "IT_VALFAC")  		//	Valor do FACS
			lImposto	:= IIF(lImposto, .T., nIT_VALFAC > 0)
			aParametro	:= {'FAC', nIT_BASEFAC, nIT_ALIQFAC, nIT_VALFAC, "IT_VALFAC" }		//	[18]
			CheckImpXProd(aParametro)
		EndIf			
	
   		If Ascan(aNF_IMPOSTOS, {|X| 'FUM' $ X[2]} ) > 0
			// 	Fundo Maranhense de Combate a Pobreza - FUMACOP
			nIT_BASEFUM	:= MaFisRet(nLinha, "IT_BASEFUM") 		//	Base de calculo do FUMACOP
			nIT_ALIQFUM := MaFisRet(nLinha, "IT_ALIQFUM") 		//	Aliquota de calculo do FUMACOP
			nIT_VALFUM	:= MaFisRet(nLinha, "IT_VALFUM")  		//	Valor do FUMACOP
			lImposto	:= IIF(lImposto, .T., nIT_VALFUM > 0)
			aParametro	:= {'FUM', nIT_BASEFUM, nIT_ALIQFUM, nIT_VALFUM, "IT_VALFUM" }		//	[XX]
			CheckImpXProd(aParametro)
		EndIf			

   		If Ascan(aNF_IMPOSTOS, {|X| 'SEN' $ X[2]} ) > 0
			// 	ServiГo Nacional de Aprendizagem Rural
			nIT_BSSENAR	:= MaFisRet(nLinha, "IT_BSSENAR") 		//	Base de calculo do SENAR
			nIT_ALSENAR := MaFisRet(nLinha, "IT_ALSENAR") 		//	Aliquota de calculo do SENAR
			nIT_VLSENAR	:= MaFisRet(nLinha, "IT_VLSENAR")  		//	Valor do SENAR
			lImposto	:= IIF(lImposto, .T., nIT_VLSENAR > 0)
			aParametro	:= {'SENAR', nIT_BSSENAR, nIT_ALSENAR, nIT_VLSENAR, "IT_VLSENAR" }		//	[XX]
			CheckImpXProd(aParametro)
		EndIf								

		// MaFisResumo(0,0,aNfItem[nX][IT_VALFDS],'FDS','FUNDERSUL','FDS',.T.,.T.,lSoma) 
		// Fundo de Desenvolvimento do Sistema RodoviАrio de Mato Grosso do Sul
		// MaFisResumo(aNfCab[NF_BASTPDP],aNfItem[nX][IT_ALITPDP],aNfCab[NF_VALTPDP],'TPD','TPDP-PB','TPDP',.T.,.T.,lSoma)




		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		//| SE NAO TEM IMPOSTO NO ITEM 											|
		//| VERIFICA SE NO aProdxImp, DO ITEM, EXISTE ALGUM ARRAY DESSE IMPOSTO	|
		//| SE TIVER DELETA OS IMPOSTOS DO ARRAY 								|
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		If !lImposto

			If Len(aProdXImp) >= nLinha			
				*****************************
					DelAllImp(nLinha, .F.)
				***************************** 
            Else 
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддд?
				//| CRIA NOVO ITEM NO ARRAY aProdXImp (CABEC+IMPOSTOS) 	|
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддд?
        	    *******************************
					CheckImpXProd({}, .F.)
	            *******************************
            EndIf

		EndIf
            

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		//|							NOVO PRECO									|
		//цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		//| >>> CALCULO PARA EMBUTIR O VALOR DOS IMPOSTOS  ( POR DENTRO ) <<<	|
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	   	 ****************************************************
		 	 IIF(!lOnlyArray, CalcPrcXImp(.T.), )
		 *****************************************************



		If lCheck .And. !lOnlyArray

			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
			//| ROTINA CARREGAMENTO DA FUNCAO FISCAL COM BASE NO ACOLS E AHEADER						|
			//цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
			//| OBS.: NAO RECALCULA... ATUALIZA SIM... PARA SER ATULIZADO NA FUNCAO ImpSobPrcAcre       |
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
			lRecalImp	:=	.F.
		    lVisual 	:= 	.F.
			lRecalDel 	:=	IIF(lDeletado, .F., .T.)
			lSoItem 	:=	.T.
			MaColsToFis(aHeader,aCols,nLinha,"TK271",lRecalImp,lVisual,lRecalDel,lSoItem)	//	ExpA1: Variavel com a estrutura do aHeader
																          					//	ExpA2: Variavel com a estrutura do aCols                     
																          	   				//	-> ExpN3: Item a ser carregado [ Nil = Todos ]          (opc)
																           					//	ExpC4: Nome do programa                                 (opc)
																          					//	ExpL5: Indica se o recalculo dos impostos deve ser feito(opc)
																          					//	ExpL6: Indica se o recalculo dos impostos deve ser feito(opc)
																          	 				//	ExpL7: Indica se o recalculo vai considerar as linhs apagadas
    
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
			//|  ATUALIZA CAMPOS DE R$ IPI, R$ ST, R$ PRECO FINAL				|
			//|  BUSCA VALORES BASEADO NO PRECO COM ACRESCIMO E QTD 1			|
			//|  PRECO FINAL = (PRC.C\ACRE + VLR.IPI + VLR.ST ) - VLR.SUFRAMA	|
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
        	*************************
				ImpSobPrcAcre()
        	*************************
	        
		EndIf

	EndIf



	//зддддддддддддддддддддддддддддд?
	//| ATUALIZA CAMPO PRECO BASE	|
	//юддддддддддддддддддддддддддддд?
	lPrcBase := IIF(GdFieldGet('UB_PRCBASE',nLinha) ==	0, .T., lPrcBase)
	lPrcBase := IIF(GdFieldGet('UB_PRCBASE',nLinha) >	0 .And. (cCampo$'UA_DESCG\UA_ACREG').Or.lOnlyArray, .F., lPrcBase)
	lPrcBase := IIF(NoRound(GdFieldGet('UB_PRCBASE',nLinha),2) ==	NoRound(GdFieldGet('UB_PRCTAB',nLinha),2), .T., lPrcBase)
	 *********************************
		IIF(lPrcBase, ChkPrcBase(), )
	 *********************************



	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	//|	OBSERVACAO TELA F11 x ITEM SEM SALDO x LINHA DELETADA																	|
	//|	QDO TELA F11 E ITEM NAO TEM SALDO, LINHA FICA DELETADA, ESTAVA LEVANDO PARA O F6 A LINHA DELETADA (ABA IMPOSTOS)        |
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	If !(lNF_SUFRAMA .And. lHistorico)
		lReCalImp := .T.
		lReCalDel := IIF(lDeletado.And.!lTelaF11, .F., .T.)
		lVisual   := Nil
		lSoItem   := .T.
		MaColsToFis(aHeader,aCols,nLinha,"TK271",lReCalImp,lVisual,lReCalDel,lSoItem)


		//зддддддддддддддддддддддддддддддддддддддддд?
		//|	MANOBRA PARA ACERTA VALORES SUFRAMA		|
		//юддддддддддддддддддддддддддддддддддддддддд?
		If lNF_SUFRAMA 
		    MaFisAlt("IT_PRCUNI",GdFieldGet("UB_VRUNIT", n),nLinha)
			MaFisAlt("IT_VALMERC",A410Arred( GdFieldGet("UB_QUANT", n) * GdFieldGet("UB_VRUNIT", n), "UB_VLRITEM"),nLinha)
    	EndIf

    EndIf


	If nPosProd > 0

		Tk273Refresh(.T.)

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//|	VERIFICA SE EXISTES TES <> NO MESMO ATENDIMENTO	      	|
		//| E GRAVA CONSULTADOS X OFERTADOS							|
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If cCampo $ 'UB_QUANT\UB_TES' .Or. lTelaDesc .Or. lDescGeral
			
			//здддддддддддддддддддддддддддддддддддддд©
			//| FLAG INFO QUE EXISTE TES <> NO AT	 |
			//юдддддддддддддддддддддддддддддддддддддды
			If cCampo $ 'UB_QUANT\UB_TES'.And.!Empty(GdFieldGet('UB_TES',nLinha)) .And. Ascan(aProdxImp, {|X| AllTrim(X[11]) != AllTrim(GdFieldGet('UB_TES',nLinha)) }) > 0
				aProdxImp[nPosProd][25] := .T.
			EndIf

			//зддддддддддддддддддддддддддддддддддддд©
			//|        PROJETO CORREIAS            	|
			//| ESTOQUE DISPONIVEL >= QTD INFORMADA	|
			//|	GRAVA RESERVAS -> aProdXImp[X][09]	|
			//юддддддддддддддддддддддддддддддддддддды
			lGravaRes := .T.   
			If IsIncallStack("VALIDBTNOK")
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//| MAIS DE 1 ITEM MARCADO NO BROWSER  										|
				//|	RESERVA SERA GRAVADA NO FINAL DA ROTINA ValidBtnOk() CHKCORREIAS.prw	|
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nPMarca	 := 1	// nPMarca := Ascan(aHeaderC,{|X| AllTrim(x[2]) == "MARCA"  })
				nTotMarc := 0
				aEval(oBrwC:aCols, {|X| nTotMarc += IIF(!Empty(X[nPMarca]),1,0) })
	            lGravaRes := IIF(nTotMarc > 1, .F., .T.)
			EndIf

			If !lTelaDesc .And. !lDescGeral

				If !lDeletado .And. !lWillDel .And. lGravaRes //lWillDel <- ITEM SERA DELETADO 
					If lCorreia
						cRotina  := 'PRCRECALC'
						aOpcao	 :=	{'GRAVA_RESERVA'}
						cCodProd := GdFieldGet("UB_PRODUTO",nLinha)   
						aParam	 := {}
						xRetorno :=	''
						aRetorno := ExecBlock('ChkCorreias', .F., .F., {cRotina, aOpcao, cCodProd, aParam, nLinha, xRetorno})
					EndIf
		        Else
		        	aProdxImp[nPosProd][09] := ''
		        EndIf
            
            EndIf
            
			//здддддддддддддддддддддддддддддддддддддд©
			//| 	GRAVA CONSULTADO X OFERTADO		 |
			//юдддддддддддддддддддддддддддддддддддддды
			***********************************
				U_Write_OrcOfert('Q', nLinha)
			***********************************

		EndIf

	EndIf

	 //cHoraFinal := Time()
	 //IIF(!lHistorico, ALERT('FIM... TEMPO  '+ElapTime( cHoraInicial , cHoraFinal )) , )

Else
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	//|OBS.:                                                   		|
	//| NAO DELETAR O ITEM DO aProdxImp NESSE TRECHO...          	|
	//| NA TELA PROD X IMPOSTOS APRESENTO A LINHA COMO DELETADA		|
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
EndIf



__ReadVar := cBckReadVar
aSort(aProdxImp,,,{|X,Y| X[1] < Y[1] })
IIF(oGetTLV:oBrowse:ColPos==nPProduto, oGetTLV:oBrowse:ColPos:=(nPQuant-1),)
//oGetTLV:oBrowse:Refresh()



RestArea(aArea)
Return(cContCpo)
**********************************************************************
Static Function CheckImpXProd(aImpostos, lAltCabec)
**********************************************************************
Local aDescImp 	   := {	'IRRF Imposto de Renda',;		//	[01]	-	OK
						'ISS Imp. ServiГo',;			//	[02]	-	OK
						'ICMS',;						//	[03]	-	OK
						'IPI',;							//	[04]	-	OK
						'ICMS Retido',;					//	[05]	-	OK 	- IDEM [19]
						'INSS',;						//	[06]	-	OK
						'PIS/PASEP - Via ApuraГЦo',;	//	[07]	-	OK
	  					'COFINS - Via ApuraГЦo',;		//	[08]	-	OK
	  					'PIS/PASEP - Via RetenГao',;	//	[09]	-	OK
	  					'COFINS - Via RetenГao',;		//	[10]	-	OK
	  					'CSLL - Via RetenГao',;			//	[11]	-	OK
						'ICMS Complementar',; 			// 	[12]	-	OK
	  					'PIS/PASEP - Subst. Tributaria',;//	[13]	-	OK
	  					'COFINS - Subst. Tributaria',;	//	[14]	-	OK
	  					'SEST/SENAT',;					//	[15]	-	OK
	  					'FETHAB',;						//	[16]	-	OK
	  					'FABOV',;						//	[17]	-	xx
	  					'FACS',;						//	[18]	-	xx
	  					'ICMS Retido ',;				//	[19]	-	OK 	- IDEM [05]
	  					'ICMS ref. Frete Autonomo',;	//	[20]	-	OK
	  					'ICMS ref. Frete Autonomo - ST',;//	[21]	-	OK
	  					'ICMS Complementar ',;			//	[22]	-	OK	- IDEM [12]
	  					'INSS CondiГУes Especiais',;	//	[23]	-	OK
	  					'FUNRURAL ',;					//	[24]	-	OK
						'SUFRAMA';						//	[25]	-	OK
	  				}

					//  1     2      3      4     5       6      7     8     9     10    11    12    13    14    15     16    17    18  
Local   aCodImp	:= { 'IRR','ISS', 'ICM', 'IPI', 'SOL', 'INS', 'PS2','CF2','PIS','COF','CSL','CMP','PS3','CF3','SES','FET','FAB','FAC',;
					 'ICR', 'ICA', 'TST', 'ICC','INA', 'FRU', 'SUF' }
                     // 19   20     21      22    23     24     25


Local 	nPrcHist  	:= 0
Local   lCalcImp  	:= ''

Private cImposto  := IIF(Len(aImpostos)>=2, aImpostos[01], '')
Private nBaseImp  := IIF(Len(aImpostos)>=2, aImpostos[02], 0 )
Private nAliqImp  := IIF(Len(aImpostos)>=3, aImpostos[03], 0 )
Private nValorImp := IIF(Len(aImpostos)>=4, aImpostos[04], 0 )
		lCalcImp  := IIF(Upper(AllTrim(cImposto)) $ cNotCalcImp, .F., .T.)		//	IPI \ ICMS RETIDO
		cIT_Campo := IIF(Len(aImpostos)>=5, aImpostos[05], '' )

Default lAltCabec := .F.


//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//| CABEC DO ARRAY - DADOS GERAIS                                                                   |
//цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//|Aadd(aProdxImp, {	aCols[n][nPItem],;			//	[01] ITEM          							|
//|						aCols[n][nPProduto],;		//	[02] COD.PRODUTO              				|
//|						cDescProd,;					//	[03] DESCRICAO DO PRODUTO            		|
//| 					0 ,;						//	[04] PRECO DE TABELA                      	|
//| 					0 ,;						//	[05] VLR.PRODUTO + IMPOSTOS               	|
//| 					0 ,;						//	[06] VLR. TOTAL IMPOSTOS 2 DECIMAIS      	|
//| 					aCols[n][nPQuant],;			//	[07] QUANTIDADE               				|
//| 					'',;						//  [08] MAIOR QTD\R$\TES (CONSULTADO X OFERT)  |
//| 					'',; 						//	[09] PROJETO CORREIAS					 	|
//|                    	nVlrSuframa ,;				//	[10] DESCONTO SUFRAMA(ICMS/PIS/COFINS)		|
//|                    	aCols[n][nPTES],;	        //  [11] TES							        |
//|                    	Cliente\Loja,;              //  [12] Cliente\Loja							|
//|                    	Condicao Pagamento,;        //  [13] Cond.Pagamento							|
//|                    	Tabela de Preco,; 	 	    //  [14] Tabela de Preco						|
//|						aCols[nLinha][nPPrUnit],;	//	[15] R$ Preco Unit. 						|
//|						M->UA_DESC4,;				//	[16] % Desconto Cabec						|
//|						0,;  						//	[17] VLR. TOTAL IMPOSTOS 4 DECIMAIS			|
//|						0,;							//	[18] PRECO A SER PRATICADO                 	|
//|						0,;							//	[19] ALIQ.ICMS-SUF                       	|
//|						UA_DESCG,;					//	[20] % DESCONTO GERAL						|
//|						0,; 						//	[21] SOMA ALIQUOTAS IMPOSTOS				|
//|						0,; 						//	[22] PRECO DA FORMACAO DE PRECO				|
//|						UA_ACREG,;					//	[23] % ACRESCIMO CONCEDIDO VENDEDOR			|
//|						0,;							//	[24] % DESCONTO CONCEDIDO VENDEDOR			|
//|						.F.			})				//	[25]                              			|
//цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//| ITENS DO ARRAY - DADOS DOS IMPOSTOS   ( ARRAY DENTRO DO aProdXImp )                             |
//цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//|	Aadd(aProdxImp[nPosProd], {	cImposto,;			//	[01] COD.IMPOSTO							|
//|								cDescImp,;			//	[02] DESCRICAO IMPOSTO               		|
//|								nBaseImp,;			//	[03] BASE                            		|
//|								nAliqImp,;			//	[04] ALIQUOTA                        		|
//|								nValorImp,;			//	[05] VALOR                          		|
//|								nVlImp4Dec})		//	[06] VALOR                         		 	|
//|								nTruImp4Dec})		//	[07] VALOR IMPOSTO 4DEC \ QTD -> TRUUNCADO  |
//|                                                									        	    |
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?



//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//| VERIFICA SE ITEM + PRODUTO EXISTE NO ARRAY	aProdxImp 	|
//|  SE NAO EXISTE CRIA NOVO ITEM\PRODUTO NO aProdxImp	  	|
//|														  	|
//| lAltCabec == .T. HOUVE ALTERACAO DE CABEC - ZERA ARRAY	|
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
If Ascan(aProdxImp, {|X| AllTrim(X[1]) == AllTrim(aCols[nLinha][nPItem]) .And. AllTrim(X[2]) == AllTrim(aCols[nLinha][nPProduto]) }) == 0 .Or. lAltCabec

	//	VERIFICA SE EH MESMO ITEM E PRODUTO <> ENTAO DELETA ITEM DO ARRAY E RECREIA NOVAMENTE
	lAltCabec 	:=	IIF(Ascan(aProdxImp, {|X| AllTrim(X[1]) == AllTrim(aCols[nLinha][nPItem]) .And. AllTrim(X[2]) != AllTrim(aCols[nLinha][nPProduto]) }) > 0, .T., lAltCabec)
	cProd08		:=	IIF(lAltCabec, aProdxImp[nLinha][08], '')

	********************************************
		IIF(lAltCabec, DelAllImp(nLinha, .T.), )	// NAO RODAR DELALLIMP NOS CASOS DA TELA F11 GERAR 2 LINHAS IGUAIS. DELAALIMP IRA DEIXAR APENAS 1 ITEM NO ARRAY E OCORRERA ERRO
	********************************************

  
	//зддддддддддддддддддддддддддддддддддддддддддддддддд?
	//| INCLUI DADOS DO PRODUTO NO ARRAY  [ CABEC ]		|
	//юддддддддддддддддддддддддддддддддддддддддддддддддд?

	//зддддддддддддддддддддддддддддддддддддддддддддд?
	//| DESCONTO SUFRAMA   							|
	//цддддддддддддддддддддддддддддддддддддддддддддд?
	//|  NF_DESCZF, NF_SUFRAMA						|
    //|  MaFisRet(, "NF_SUFRAMA") == .T.			|
	//юддддддддддддддддддддддддддддддддддддддддддддд?
	/*
	nICMSuframa	:= MaFisRet(nLinha, "IT_DESCZF") 				//	Valor do desconto da Zona Franca do ITEM
	nPISSuframa	:= MaFisRet(nLinha, "IT_DESCZFPIS")  
	nCOFSuframa	:= MaFisRet(nLinha, "IT_DESCZFCOF") 
	nVlrSuframa	:= nICMSuframa + nPISSuframa + nCOFSuframa
	*/
	
	nSomaAliq	:= 0
	nVlrSuframa	:= MaFisRet(nLinha, "IT_DESCZF") 				//	Valor do desconto da Zona Franca do ITEM

	If nVlrSuframa > 0 .And. lHistorico
		nAliqIMC := MaFisRet(nLinha, "IT_ALIQICM")
		nAliqPIS := MaFisRet(nLinha, "IT_ALIQPIS")	//	MaFisRet(nLinha, "IT_ALIQPS2")
		nAliqCOF := MaFisRet(nLinha, "IT_ALIQCOF")	//	MaFisRet(nLinha, "IT_ALIQCO2")
		nSomaAliq:= (nAliqIMC+nAliqPIS+nAliqCOF)
	EndIf

						
	aCols[nLinha][nPQuant] := IIF(aCols[nLinha][nPQuant] == 0, 1, aCols[nLinha][nPQuant] )
	    
	Aadd(aProdxImp, {	aCols[nLinha][nPItem],;					//	[01] ITEM
						aCols[nLinha][nPProduto],;				//	[02] COD.PRODUTO
						aCols[nLinha][nPDescri],;				//	[03] DESCRICAO DO PRODUTO
	 					aCols[nLinha][nPPrcTab],;		  		//	[04] PRECO DE TABELA
	 					0 ,;									//	[05] VLR.PRODUTO + IMPOSTOS
	 					0 ,;				   					//	[06] VLR. TOTAL IMPOSTOS 2 DECIMAIS
	 					aCols[nLinha][nPQuant],;				//	[07] QUANTIDADE
	 					cProd08,;								//  [08] MAIOR QTD\R$\TES DIG. (CONSULTADO X OFERT)
	 					'' ,;									//	[09] PROJETO CORREIAS
	 					nVlrSuframa,;							//	[10] DESCONTO SUFRAMA(ICMS\PIS\COFINS)
						aCols[nLinha][nPTES],; 			 		//	[11] TES
						AllTrim(M->UA_CLIENTE+M->UA_LOJA),;    //  [12] Cliente\Loja
						AllTrim(M->UA_CONDPG),;                	// 	[13] Condicao Pagamento
						AllTrim(M->UA_TABELA),;               	// 	[14] Tabela de Preco
						aCols[nLinha][nPPrUnit],;				//	[15] R$ Preco Unit. 
						M->UA_DESC4,;							//	[16] Desconto Cabec
						0,;										//	[17] VLR. TOTAL IMPOSTOS 4 DECIMAIS
						IIF(lHistorico,GdFieldGet('UB_VRCACRE',nLinha),0),;	//	[18] PRECO A SER PRATICADO
						0,;										//	[19] NAO UTILIZADO
						M->UA_DESCG,; 							//	[20] % DESCONTO GERAL
						nSomaAliq,  ;							//	[21] SOMA ALIQUOTAS IMPOSTOS
                        0,;										//	[22] PRECO DA FORMACAO DE PRECO 
                        IIF(lHistorico,GdFieldGet('UB_ACRE2',nLinha),0),;  //	[23] % ACRESCIMO CONCEDIDO VENDEDOR
						IIF(lHistorico,GdFieldGet('UB_DESCVEN',nLinha),0),;//	[24] % DESCONTO CONCEDIDO VENDEDOR
						.F.			})							//	[25]                               
							
ElseIf 	Ascan(aProdxImp, {|X| AllTrim(X[1]) == AllTrim(aCols[nLinha][nPItem]) .And. AllTrim(X[2]) != AllTrim(aCols[nLinha][nPProduto]) }) != 0 .Or.;
		Ascan(aProdxImp, {|X| AllTrim(X[1]) == AllTrim(aCols[nLinha][nPItem]) .And. AllTrim(X[2]) == AllTrim(aCols[nLinha][nPProduto]) .And.  AllTrim(X[11]) != AllTrim(aCols[nLinha][nPTES]) }) != 0

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	//|  MESMO ITEM E PRODUTO <>												|
	//|  VERIFICA SE ITEM EXISTE E PRODUTO Eh O MESMO DO ARRAY					|
	//|  SE PRODUTO <> ENTAO ATUALIZA ITEM DO ARRAY                          	|
	//|																			|
	//|  UTILIZADO PARA OS CASOS ONDE Eh INFORMADO UM PRODUTO NO ITEM E         |
	//|  DEPOIS ALTERA-SE PARA OUTRO PRODUTO [ NO MESMO ITEM ] 					| 
	//|																			|
	//|	 VERIFICA SE TES <>														|
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?

	lProdDif  := Ascan(aProdxImp, {|X| AllTrim(X[1]) == AllTrim(aCols[nLinha][nPItem]) .And. AllTrim(X[2]) != AllTrim(aCols[nLinha][nPProduto]) }) != 0
	nPosProd  := Ascan(aProdxImp, {|X| AllTrim(X[1]) == AllTrim(aCols[nLinha][nPItem]) })
	lDelCabec := Ascan(aProdxImp, {|X| AllTrim(X[1]) == AllTrim(aCols[nLinha][nPItem]) .And. AllTrim(X[2]) != AllTrim(aCols[nLinha][nPProduto]) }) != 0
	cReserva  := IIF(Ascan(aProdxImp, {|X| AllTrim(X[1]) == AllTrim(aCols[nLinha][nPItem]) .And. AllTrim(X[2]) == AllTrim(aCols[nLinha][nPProduto]) .And.  AllTrim(X[11]) != AllTrim(aCols[nLinha][nPTES]) }) != 0, aProdxImp[nLinha][09],'')
		
	aCols[nLinha][nPQuant] 	:= 	IIF(aCols[nLinha][nPQuant] == 0, 1, aCols[nLinha][nPQuant] )
	aProdxImp[nPosProd][02]	:=	aCols[nLinha][nPProduto]
	aProdxImp[nPosProd][03]	:=	AllTrim(GdFieldGet('UB_DESCRI', nLinha))//Posicione('SB1',1,xFilial('SB1')+ aCols[nLinha][nPProduto],'B1_DESC'))
	aProdxImp[nPosProd][04]	:=	aCols[nLinha][nPPrcTab]			   		//	[04] PRECO DE TABELA
	aProdxImp[nPosProd][05]	:=	0								   		//	[05] VLR.PRODUTO + IMPOSTOS
	aProdxImp[nPosProd][06]	:=	0										//	[06] VLR. TOTAL IMPOSTOS 2 DECIMAIS
	aProdxImp[nPosProd][07]	:=	aCols[nLinha][nPQuant]			   		//	[07] QUANTIDADE
	aProdxImp[nPosProd][10]	:=	0 							 	   		//	[10] VALOR DO DESCONTO DA ZONA FRANCA DO ITEM
	aProdxImp[nPosProd][09]	:=	cReserva								//	[09] PROJETO CORREIAS
	aProdxImp[nPosProd][11]	:=	aCols[nLinha][nPTES]
	If oGetTLV:oBrowse:ColPos != nPTES
		aProdxImp[nPosProd][15]	:=	aCols[nLinha][nPPrUnit]           	//	[15] R$ Preco Unit. 
	EndIf	
	aProdxImp[nPosProd][16]	:=	M->UA_DESC4
	aProdxImp[nPosProd][17]	:=	0										// 	[17] VLR. TOTAL IMPOSTOS 4 DECIMAIS
	aProdxImp[nPosProd][18]	:=	0										// 	[18] PRECO A SER PRATICADO
	aProdxImp[nPosProd][19]	:=	0										// 	[19] ALIQ.ICMS-SUF
	aProdxImp[nPosProd][20]	:=	M->UA_DESCG								//	[20] % DESCONTO GERAL
	aProdxImp[nPosProd][21]	:=	0										//	[21] SOMA ALIQUOTAS IMPOSTOS
	aProdxImp[nPosProd][22]	:=	0										//	[22] PRECO DA FORMACAO DE PRECO
	If lProdDif
		aProdxImp[nPosProd][23]	:=	0									//	[23] % ACRESCIMO CONCEDIDO VENDEDOR
		aProdxImp[nPosProd][24]	:=	0									//	[24] % DESCONTO CONCEDIDO VENDEDOR
		aProdxImp[nPosProd][25]	:=	.F.									//	[24] 
    EndIf

   
ElseIf (lTelaDesc .Or. lDescGeral) 
    If nPosProd > 0
		aProdxImp[nPosProd][15]	:=	aCols[nLinha][nPPrUnit]       	    	//	[15] R$ Preco Unit. 
	EndIf
EndIf




nPosProd :=	Ascan(aProdxImp, {|X| AllTrim(X[1]) == AllTrim(aCols[nLinha][nPItem]) .And. AllTrim(X[2]) == AllTrim(aCols[nLinha][nPProduto]) })


If lFirstRun

	If nValorImp > 0
	
		/*
		lIcmsDif := .F.
	
		//зддддддддддддддддддддддддддддддддд?
		//|	TRATAMENTO PARA ICMS DIFERIDO	|
		//юддддддддддддддддддддддддддддддддд?
		If nPosProd > 0
		
			If Posicione('SF4',1,xFilial('SF4') + aProdxImp[nPosProd][11] , 'F4_ICMSDIF') == '3' // 1=Diferido;2=Nao Diferido;3=Diferimento de Reducao;4=Diferimento Incentivo
	                                              
				// UTILIZADO QUANDO CALCULO(F4_ICM) E NAO CREDITA(F4_CREDICM) ICMS
				// IMPOSTO TEM BASE, ALIQUOTA POREM NAO TEM VALOR
				
				// VERIFICA ICM DIF (TEM BASE, ALIQ POREM VALOR == 0) 
				// NAO APAGAR ARRAY DE IMPOSTOS... POIS ARRAY JA TEM IMPOSTO DO ICM
				// NAO COLOCAR lFirstRun == .T. NO TRATAMENTO PARA ICMS DIFERIDO (TRECHO ABAIXO)
				// POIS OCORRE DUPLICACAO DOS IMPOSTOS NO ARRAY
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//|VERIFICA SE IMPOSTO (cImposto) EXISTE NO ARRAY	[ ITEM ] |
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nPosImp := 0                                                    //  aProdxImp[nPosProd][nX]
				For nX  := 1 To Len(aProdxImp[nPosProd])                      	//	[01] - ICM
					If ValType(aProdxImp[nPosProd][nX]) == 'A'					//	[02] - ICMS
						If AllTrim(aProdxImp[nPosProd][nX][01]) == 'ICM'      	//	[03] - BASE
								If aProdxImp[nPosProd][nX][05] == 0           	//	[04] - ALIQ
									lIcmsDif := .T.                            	//	[05] - VALOR IMP. 2DEC
								EndIf                                          	//	[06] - VALOR IMP. 4DEC 
							Exit
						EndIf
					EndIf	
				Next
            
            EndIf
            
        EndIf
        */
		
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		//| lFirstRun FLAG PARA IDENTIFICAR SE Eh A PRIMEIRA VEZ QUE PASSA NESSA FUNCAO		|
		//| UTILIZADO PARA ATUALIZAR ARRAY COM O VALOR DO PRODUTO [ CABEC ]					|
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		aProdxImp[nPosProd][04]	:=	aCols[nLinha][nPPrcTab] 			//	[04] PRECO DE TABELA
		aProdxImp[nPosProd][07]	:=	aCols[nLinha][nPQuant]				//	[07] QUANTIDADE
	
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//|ZERA VLR.PRODUTO + IMPOSTOS	[ CABEC ] 					 |
		//| EM CASO DE ALTERACAO DO VLR.UNITARIO RECALCULA O VALOR	 |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aProdxImp[nPosProd][05]	:=	0                					//	[05] VLR.PRODUTO + IMPOSTOS
		aProdxImp[nPosProd][06]	:=	0                     	 			//	[06] VLR. IMPOSTOS 2 DECIMAIS
		aProdxImp[nPosProd][17]	:=	0                     	 			//	[17] VLR. IMPOSTOS 4 DECIMAIS
		aProdxImp[nPosProd][10]	:=	0 //MaFisRet(nLinha, "IT_DESCZF") 		//	[10] VALOR DO DESCONTO DA ZONA FRANCA DO ITEM

		//If !lIcmsDif
			lDelCabec := Ascan(aProdxImp, {|X| AllTrim(X[1]) == AllTrim(aCols[nLinha][nPItem]) .And. AllTrim(X[2]) != AllTrim(aCols[nLinha][nPProduto]) }) != 0
			********************************           
				DelAllImp(nPosProd, lDelCabec)
			********************************
		//EndIf
		
		lFirstRun := .F.
	EndIf

EndIf

	

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//|VERIFICA SE IMPOSTO (cImposto) EXISTE NO ARRAY	[ ITEM ] |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nPosImp := 0
For nX  := 1 To Len(aProdxImp[nPosProd])
	If ValType(aProdxImp[nPosProd][nX]) == 'A'
		If AllTrim(aProdxImp[nPosProd][nX][01]) == AllTrim(cImposto)
			nPosImp := nX
			Exit
		EndIf
	EndIf	
Next



//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//|* VERIFICA SE VALOR DO IMPOSTO MUDOU								|
//цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//| EX.: AO INFORMAR O MESMO PRODUTO		                        |
//| O CONTEUDO DO UB_VRUNIT EH ALTERADO PARA O VALOR DE TABELA		|
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
lCheckImp := .T.
If nPosImp > 0
	If 	nBaseImp  ==  aProdxImp[nPosProd][nPosImp][03] .And.;		//	BASE IMPOSTO
		nAliqImp  ==  aProdxImp[nPosProd][nPosImp][04] .And.;		//	ALIQUOTA
		nValorImp ==  aProdxImp[nPosProd][nPosImp][05]				//	VALOR
		lCheckImp := .F.
	EndIf
EndIf



If lCheckImp 
	
	//зддддддддддддддддддддддддддддддддд?
	//|	TRATAMENTO PARA ICMS DIFERIDO	|
	//юддддддддддддддддддддддддддддддддд?
/*
	lIcmsDif := .F.
	If nValorImp == 0 .And. cImposto == 'ICM' 
		If nPosProd > 0
			If Posicione('SF4',1,xFilial('SF4') + aProdxImp[nPosProd][11] , 'F4_ICMSDIF') == '3' // 1=Diferido;2=Nao Diferido;3=Diferimento de Reducao;4=Diferimento Incentivo
				lIcmsDif  := .T.
				// lFirstRun := .F.
			EndIf
		EndIf
	EndIf
*/

	//зддддддддддддддддддддддддддддддддддддддддддддддддд?
	//| ACERTO VALOR IMPOSTO.                       	|
	//| CASO ONDE BASE x ALIQUOTA = R$ 0.0073			|
	//| (SISTEMA CONSIDERA APENAS DOIS DECIMAIS)		|
	//юддддддддддддддддддддддддддддддддддддддддддддддддд?
	/*lAjVlrImp := .F.
	If nValorImp == 0 .And. nBaseImp > 0 .And. nAliqImp > 0 .And. !(cImposto $ 'ICR')
		aValorImp 	:= 	ChkVlrImpostos(nBaseImp, nAliqImp, nValorImp, nLinha, .F., cImposto)
		nValorImp	:=	aValorImp[01]
		nVlrImp4Dec	:=	aValorImp[02]		
	    lAjVlrImp   := 	IIF(nVlrImp4Dec > 0, .T., .F.)
    EndIf
    */
	
	If nValorImp > 0

		//зддддддддддддддддддддддддддддддддддддддддддддддддд?
		//| INCLUI DADOS DO IMPOSTO NO ARRAY [ ITEM ] 		|
		//юддддддддддддддддддддддддддддддддддддддддддддддддд?
		nPosCodI 	:=	Ascan(aCodImp, AllTrim(cImposto))
		cDescImp 	:=	IIF(nPosCodI > 0, aDescImp[nPosCodI], '')
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		//| CALCULO PARA VERIRIFCAR SE VALOR DO IMPOSTO ESTA CORRETO		|
		//| OCORRE DIVERGENCIA DE VALORES, CENTAVOS, QDO O MESMO PRODUTO	|
		//| INFORMADO MAIS DE UMA VEZ.										|
		//|																	|
		//|	-> NAO CHECAR PARA ICMS RETIDO. (BASE*ALIQ) NAO Eh == VALOR IMP	|
		//|	BASE  ICMS RETIDO  = VLR.PROD + FRETE + IPI + ACRESC.FIN		|
		//| VALOR ICMS RETIDO = (BASE * ALIQ) - VALOR ICMS					|
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		If !(cImposto $ 'ICR') //.And. !lIcmsDif
			***********************************************************************
				//If !lAjVlrImp
					aValorImp 	:= 	ChkVlrImpostos(nBaseImp, nAliqImp, nValorImp, nLinha)
					nValorImp	:=	aValorImp[01]
					nVlrImp4Dec	:=	aValorImp[02]
				//EndIf
			***********************************************************************
		Else
			nVlrImp4Dec	:=	0
		EndIf		
		                                            //  [ ITEM IMPOSTO ]
		Aadd(aProdxImp[nPosProd], {	cImposto,;		//	[01] COD.IMPOSTO
									cDescImp,;		//	[02] DESCRICAO IMPOSTO
									nBaseImp,;		//	[03] BASE
									nAliqImp,;		//	[04] ALIQUOTA
									nValorImp,;		//	[05] VALOR IMP 2 DECIMAIS
									nVlrImp4Dec})	//	[06] VALOR IMP 4 DECIMAIS
		
		nPosImp := Len(aProdxImp[nPosProd])     

		//	NAO CONSIDERAR IPI E ICMS RETIRO NO CALCULO
		aProdxImp[nPosProd][06]	+=	IIF(lCalcImp, nValorImp,   0)		//	[06] VLR. IMPOSTOS 2 DEC [ CABEC ]
		aProdxImp[nPosProd][17]	+=	IIF(lCalcImp, nVlrImp4Dec, 0)		//	[17] VLR. IMPOSTOS 4 DEC [ CABEC ]
		aProdxImp[nPosProd][21]	+=	IIF(lCalcImp, nAliqImp,    0)		//	[21] SOMA ALIQUOTA IMPOSTOS

	Else
		*************************************
			IIF(!lHistorico, DelImposto(), )	//	QDO ITEM EH DE HIST E NAO TEM ITEM NO ARRAY aProdXImp
		*************************************
	EndIf

EndIf

Return()
**********************************************************************
Static Function DelImposto(nPosImp, lDelImp)
**********************************************************************
Local lDelImp := IIF(ValType(lDelImp)=='U', .F., lDelImp)
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//Ё[ IF ]    VALOR DO IMPOSTO Eh ZERO            						|
//|         VERIFICA\RETIRA O IMPOSTO DO ARRAY - 1 ITEM DO ARRAY		|
//цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//Ё[ ELSE ]  VERIFICA SE EH MESMO ITEM POREM PRODUTOS <>				|
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?



If Ascan(aNF_IMPOSTOS, {|X| X[1] == cImposto}) == 0 .Or. lDelImp
	
	If !lDelImp
		nPosProd := Ascan(aProdxImp, {|X| AllTrim(X[1]) == AllTrim(aCols[nLinha][nPItem]) .And. AllTrim(X[2]) == allTrim(aCols[nLinha][nPProduto]) })
	
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//|VERIFICA SE IMPOSTO (cImposto) EXISTE NO ARRAY	[ ITEM ] |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		nPosImp := 0
		For nX  := 1 To Len(aProdxImp[nPosProd])
			If ValType(aProdxImp[nPosProd][nX]) == 'A'
				If AllTrim(aProdxImp[nPosProd][nX][01]) == AllTrim(cImposto)
					nPosImp := nX
					Exit
				EndIf
			EndIf	
		Next
	EndIf
	

	If nPosImp > 0

		//	DELETA ITEM DO ARRAY
		aDel(aProdxImp[nPosProd], nPosImp)
		
		// REFAZ O ARRAY SEM O ITEM DELETADO - aDel RETIRA O ARRAY MAS COLOCA COMO NIL
		nTamArray :=  0		//	TAMANHO DO ARRAY
		lArray	  := .F.	//	VERIFICA SE EXISTE ALGUM ARRAY [ ITEM ] DENTO DE aProdxImp
                                                                   
		For nX:=1 To Len(aProdxImp[nPosProd])
			If ValType(aProdxImp[nPosProd][nX]) != 'U'
				nTamArray++
				lArray	:=	IIF(lArray, .T., ValType(aProdxImp[nPosProd][nX]) == 'A' )
			EndIf
		Next
		
		If nTamArray > 0
			// REDIMENSIONA O ARRAY
			aSize(aProdxImp[nPosProd], nTamArray)

			//	SENAO EXISTIR [ ITEM ] NO ARRAY ZERA VLR. [ CABEC ] 
			If !lArray
				//	ZERA VALORES
				aProdxImp[nPosProd][05]	:=	0            				//	[05] VLR.PRODUTO + IMPOSTOS
				aProdxImp[nPosProd][06]	:=	0                     	 	//	[06] VLR. IMPOSTOS 2 DECIMAIS
				aProdxImp[nPosProd][17]	:=	0                     	 	//	[06] VLR. IMPOSTOS 4 DECIMAIS
				nSomaAliq := 0
			
				If MaFisRet(nLinha, "IT_DESCZF") > 0 .And. lHistorico
					nAliqIMC := MaFisRet(nLinha, "IT_ALIQICM")
					nAliqPIS := MaFisRet(nLinha, "IT_ALIQPIS")
					nAliqCOF := MaFisRet(nLinha, "IT_ALIQCOF")
					nSomaAliq:= (nAliqIMC+nAliqPIS+nAliqCOF)
				EndIf

				aProdxImp[nPosProd][21]	:=	nSomaAliq					//	[21] SOMA ALIQUOTA IMPOSTOS

			EndIf

		EndIf

	EndIf

Else

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	//|   	VERIFICA SE EH MESMO ITEM POREM PRODUTOS <>		|
	//| 	DELETA ITEM QUE EH DIFERENTE					|
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	nPosProd := Ascan(aProdxImp, {|X| AllTrim(X[1]) == AllTrim(aCols[nLinha][nPItem]) .And. AllTrim(X[2]) != AllTrim(aCols[nLinha][nPProduto]) })
    If nPosProd > 0
    	DelAllImp(nPosProd, .T.)
	Else
		// CASO nPosProd == ZERO nPosProd RETORNA O CONTEUDO CORRETO
		nPosProd := Ascan(aProdxImp, {|X| AllTrim(X[1]) == AllTrim(aCols[nLinha][nPItem]) .And. AllTrim(X[2]) == AllTrim(aCols[nLinha][nPProduto]) })	
	EndIf

EndIf		

Return()
**********************************************************************
Static Function DelAllImp(nPosProd, lDelCabec)
**********************************************************************
//зддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//|   NAO GEROU NENHUM IMPOSTO            				|
//|   DELETA TODOS OS ITENS DO ARRAY DE IMPOSTOS 		|
//|    DEIXA APENAS O CABEC DO ARRAY					|
//юддддддддддддддддддддддддддддддддддддддддддддддддддддд?
lDelCabec	:=	IIF(ValType(lDelCabec)=='U', .F., lDelCabec)
nPosProd  	:= 	IIF(ValType(nPosProd) =='U',   0, nPosProd )
nPosProd  	:= 	IIF(nPosProd>0,nPosProd, Ascan(aProdxImp, {|X| AllTrim(X[1]) == AllTrim(aCols[nLinha][nPItem]) .And. AllTrim(X[2]) == AllTrim(aCols[nLinha][nPProduto]) }) )

If nPosProd > 0

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	//|SE lDelCabec == .T. DELETA TODO O ITEM DO ARRAY		|
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	If lDelCabec 
	
		aCopia := {}	
		For nX := 1 To Len(aProdxImp)
			If nX != nPosProd
				Aadd(aCopia, aProdxImp[nX])
			EndIf
		Next  
		
		aProdxImp := aCopia
		aSort(aProdxImp,,,{|X,Y| X[1] < Y[1] })

	Else
	
		nTamArray :=  0		//	TAMANHO DO ARRAY
		lArray	  := .F.	//	VERIFICA SE EXISTE ALGUM ARRAY [ ITEM ] DENTO DE aProdxImp
		
	
		If Len(aProdxImp) >= nPosProd
		
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//|VERIFICA SE IMPOSTO (cImposto) EXISTE NO ARRAY	[ ITEM ] |
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			For nX   := 1 To Len(aProdxImp[nPosProd])
		
		
				If ValType(aProdxImp[nPosProd][nX]) == 'A'
					
					Do While ValType(aProdxImp[nPosProd][nX]) == 'A'
						aDel(aProdxImp[nPosProd],nX)
						lArray := .F.
					EndDo
							
					Exit
				Else
					nTamArray++
				EndIf
			
			Next
		
		    
			// REFAZ O ARRAY SEM O ITEM DELETADO - aDel RETIRA O ARRAY MAS COLOCA COMO NIL
			If nTamArray > 0
				// REDIMENSIONA O ARRAY
				aSize(aProdxImp[nPosProd], nTamArray)
		
				//	SENAO EXISTIR [ ITEM ] NO ARRAY ZERA VLR. [ CABEC ] 
				If !lArray		
					//	ZERA VALORES
					//aProdxImp[nPosProd][04]	:=	aCols[nLinha][nPPrcTab]		//	[04] PRECO DE TABELA
					aProdxImp[nPosProd][05]	:=	0            					//	[05] VLR.PRODUTO + IMPOSTOS
					aProdxImp[nPosProd][06]	:=	0               	      	 	//	[06] VLR. IMPOSTOS 2 DECIMAIS
					aProdxImp[nPosProd][17]	:=	0               	      	 	//	[06] VLR. IMPOSTOS 4 DECIMAIS					
					aProdxImp[nPosProd][11]	:=  aCols[nLinha][nPTES]			//	[11] TES

					nSomaAliq := 0				
					If MaFisRet(nLinha, "IT_DESCZF") > 0 .And. lHistorico
						nAliqIMC := MaFisRet(nLinha, "IT_ALIQICM")
						nAliqPIS := MaFisRet(nLinha, "IT_ALIQPIS")
						nAliqCOF := MaFisRet(nLinha, "IT_ALIQCOF")
						nSomaAliq:= (nAliqIMC+nAliqPIS+nAliqCOF)
					EndIf
	
					aProdxImp[nPosProd][21]	:=	nSomaAliq					//	[21] SOMA ALIQUOTA IMPOSTOS
	

				EndIf
		
			EndIf

        EndIf
        
    EndIf


EndIf

Return()
**********************************************************************
Static Function CalcPrcXImp(lPrcxImp)
**********************************************************************
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//| CABEC DO ARRAY - DADOS GERAIS                                                                   |
//цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//|Aadd(aProdxImp, {	aCols[n][nPItem],;			//	[01] ITEM          							|
//|						aCols[n][nPProduto],;		//	[02] COD.PRODUTO              				|
//|						cDescProd,;					//	[03] DESCRICAO DO PRODUTO            		|
//| 					0 ,;						//	[04] PRECO DE TABELA                      	|
//| 					0 ,;						//	[05] VLR.PRODUTO + IMPOSTOS               	|
//| 					0 ,;						//	[06] VLR. TOTAL IMPOSTOS 2 DECIMAIS      	|
//| 					aCols[n][nPQuant],;			//	[07] QUANTIDADE               				|
//| 					'',;						//  [08] MAIOR QTD\R$\TES (CONSULTADO X OFERT)  |
//| 					'',; 						//	[09] PROJETO CORREIAS                      	|
//|                    	nVlrSuframa ,;				//	[10] DESCONTO SUFRAMA(ICMS/PIS/COFINS)		|
//|                    	aCols[n][nPTES],;	        //  [11] TES							        |
//|                    	Cliente\Loja,;              //  [12] Cliente\Loja							|
//|                    	Condicao Pagamento,;        //  [13] Cond.Pagamento							|
//|                    	Tabela de Preco,; 	 	    //  [14] Tabela de Preco						|
//|						aCols[nLinha][nPPrUnit],;	//	[15] R$ Preco Unit. 						|
//|						M->UA_DESC4,;				//	[16] % Desconto Cabec						|
//|						0,;  						//	[17] VLR. TOTAL IMPOSTOS 4 DECIMAIS			|
//|						0,;							//	[18] PRECO A SER PRATICADO                 	|
//|						0,;							//	[19] ALIQ.ICMS-SUF                       	|
//|						UA_DESCG,;					//	[20] % DESCONTO GERAL						|
//|						0,; 						//	[21] SOMA ALIQUOTAS IMPOSTOS				|
//|						0,; 						//	[22] PRECO DA FORMACAO DE PRECO				|
//|						UA_ACREG,;					//	[23] % ACRESCIMO CONCEDIDO VENDEDOR			|
//|						0,;							//	[24] % DESCONTO CONCEDIDO VENDEDOR			|
//|						.F.			})				//	[25]                               		|
//цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//| ITENS DO ARRAY - DADOS DOS IMPOSTOS   ( ARRAY DENTRO DO aProdXImp )                             |
//цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//|	Aadd(aProdxImp[nPosProd], {	cImposto,;			//	[01] COD.IMPOSTO							|
//|								cDescImp,;			//	[02] DESCRICAO IMPOSTO               		|
//|								nBaseImp,;			//	[03] BASE                            		|
//|								nAliqImp,;			//	[04] ALIQUOTA                        		|
//|								nValorImp,;			//	[05] VALOR                          		|
//|								nVlImp4Dec})		//	[06] VALOR                         		 	|
//|								nTruImp4Dec})		//	[07] VALOR IMPOSTO 4DEC \ QTD -> TRUUNCADO  |
//|                                                									        	    |
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//Default lPrcxImp := .T.

If lPrcxImp

	// ROTINA SUFRAMA
	nSuframa := MaFisRet(nLinha, "IT_DESCZF")
	aProdxImp[nPosProd][10] := nSuframa
	If nSuframa > 0
		nAliqIMC := MaFisRet(nLinha, "IT_ALIQICM")
		nAliqPIS := MaFisRet(nLinha, "IT_ALIQPIS")	//	MaFisRet(nLinha, "IT_ALIQPS2")
		nAliqCOF := MaFisRet(nLinha, "IT_ALIQCOF")	//	MaFisRet(nLinha, "IT_ALIQCO2")
		aProdxImp[nPosProd][21] := (nAliqIMC+nAliqPIS+nAliqCOF)
		aProdxImp[nPosProd][19] := nAliqIMC
	EndIf
	
	nVlrTotal	:=	aCols[nLinha][nPPrUnit] * aCols[nLinha][nPQuant]	// 	[F] NoRound( aCols[nLinha][nPPrUnit] * aCols[nLinha][nPQuant], TamSx3('UB_VRUNIT')[02])
	nVlrUnit	:=	nVlrTotal / aCols[nLinha][nPQuant]					//	[F] NoRound( nVlrTotal / aCols[nLinha][nPQuant], TamSx3('UB_VRUNIT')[02])
	nVlrImp 	:=	aProdxImp[nPosProd][21]															//	[21] SOMA ALIQUOTAS IMPOSTOS
	nNewPreco	:=	(nVlrTotal / ((100 - nVlrImp) / 100)) 			// 	[F] NoRound((nVlrTotal / ((100 - nVlrImp) / 100)), TamSx3('UB_VRUNIT')[02]) 
	//зддддддддддддддддддддд?
	//| ATUALIZA aProdXImp	|
	//юддддддддддддддддддддд?
	aProdxImp[nPosProd][05] :=	nNewPreco // Round(nNewPreco, TamSx3('UB_VLRITEM')[02])	// [F]	[05] VLR.PRODUTO + IMPOSTOS

EndIf


//зддддддддддддддддддддддддддддддддд?
//| ATUALIZA VALORES DO ACOLS 		|
//юддддддддддддддддддддддддддддддддд?
//	lOnlyArray = ATUALIZA APENAS ARRAY COM OS IMPOSTOS... 
//				 UTILIZADO NOS CASOS DO ATENDIMENTO JA ESTA FATURADO VIA HISTORICO

If !lOnlyArray

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	//| 	ATUALIZA PRECO UNITARIO\TOTAL e PRECO COM ACRESCIMO FINANCEIRO 			|
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	// lPrcTD = USUARIO INFORMOU PRECO A SER PRATICADO\DESC\ACRESC (TELA DESCONTO - LINHA) OU PRECO DE HISTORICO
	//			aProdXImp[nPosProd][18] := IIF(lHistorico,GdFieldGet('UB_VRCACRE',nLinha),0)
	
	lPrcTD 	 := IIF(aProdXImp[nPosProd][18] > 0, .T., .F.)
	If lPrcxImp
	
		nPrcUnit := NoRound( (nNewPreco / aCols[nLinha][nPQuant]), TamSx3('UB_VRUNIT')[02]) 	// TRUNCA 4

		// AJUSTE\ACERTO DIVERGENCIA DECIMAIS. 
		// EX.: PRECO A SER PRATIC R$ 93.15, PRCUNIT R$ 93.1499 [SE ACRESC.FIN == ZERO ENTAO PRC.UNIT E PRR.C\ACRE FICAM IGUAIS]
		If nE4Acresc == 0 .And. lPrcTD
			nPrcUnit := aProdXImp[nPosProd][18]
		EndIf

	Else	
		nPrcUnit := aCols[nLinha][nPPrUnit]			//	!lPrcxImp UTILIZADO QDO USER TROCA COND.PAGTO
	EndIf

	nPrcAcre 	:= 	NoRound( (nPrcUnit  * (1+(nE4Acresc/100))),    TamSx3('UB_VRUNIT')[02]) 	// TRUNCA 4
	lAjPrcAcre	:=	.F.

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	//| MANOBRA HISTORICO - ITENS QUE DEVEM SER RECALCULADOS POREM NAO PRECISA AJUSTAR O PRC.C\ACRE		|
	//| UTILIZADO NOS CASOS ONDE O AT > 2 DIAS E PROGRAMA RECALCULA PRCUNIT "E" PRC.C\ACRE				|
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	lPrcxImp	:=	IIF(lHistorico.Or.cCampo$'UA_DESCG', .F., lPrcxImp)
	
	
	If lPrcTD .And. lPrcxImp 

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		//| MANOBRA PARA ACERTAR PRECO A SER PRATICADO (TELA DESCONTO - LINHA)	|
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		If nPrcAcre != aProdXImp[nPosProd][18]

			//зддддддддддддддддддддддддддддддддддддд?
			//| PRECO C\ACRESC  VERIFICA\AJUSTA		|
			//юддддддддддддддддддддддддддддддддддддд?
			nDifer	 := aProdXImp[nPosProd][18] - nPrcAcre
			nPrcAcre := (nPrcUnit  * (1+(nE4Acresc/100)))		//	PRC\ACRE COM TODOS DECIMAIS
			If nDifer != 0
				nPrcAcre 	:= 	NoRound( (nPrcUnit  * (1+(nE4Acresc/100)))+ nDifer, TamSx3('UB_VRUNIT')[02]) 	// TRUNCA 4
				lAjPrcAcre	:=	.T.
			EndIf

			//зддддддддддддддддддддддддддддддддддддд?
			//| PRECO UNITARIO VERIFICA\AJUSTA		|
			//юддддддддддддддддддддддддддддддддддддд?
			If aProdXImp[nPosProd][18] > nPrcAcre
		       	nDifer 	 := aProdXImp[nPosProd][18] - nPrcAcre
				nPrcUnit += NoRound(nDifer, TamSx3('UB_VRUNIT')[02]) 		// TRUNCA 4
			
			ElseIf aProdXImp[nPosProd][18] < nPrcAcre 
		       	nDifer 	 := nPrcAcre - aProdXImp[nPosProd][18]
				nPrcUnit -= NoRound(nDifer, TamSx3('UB_VRUNIT')[02]) 		// TRUNCA 4			    
			
			Else
				
				If nPrcAcre >= NoRound((nPrcUnit * (1+(nE4Acresc/100))), TamSx3('UB_VRUNIT')[02])
					nPrcUnit += NoRound(nDifer, TamSx3('UB_VRUNIT')[02])
				ElseIf nPrcAcre <= NoRound((nPrcUnit * (1+(nE4Acresc/100))), TamSx3('UB_VRUNIT')[02])
					nPrcUnit -= NoRound(nDifer, TamSx3('UB_VRUNIT')[02])
				EndIf

			EndIf
		
		EndIf

	EndIf



	aCols[nLinha][nPPrUnit]	:= NoRound(nPrcUnit, TamSx3('UB_VRUNIT')[02] )												//	TRUNCA 4
	aCols[nLinha][nPTotal] 	:= A410Arred( (aCols[nLinha][nPPrUnit]*aCols[nLinha][nPQuant]), 'UB_VLRITEM' )
		
	If !lAjPrcAcre
		aCols[nLinha][nPPrcAcr]	:= NoRound((nPrcUnit * (1+(nE4Acresc/100))), TamSx3('UB_VRUNIT')[02] )				//	TRUNCA 4
    Else
    	aCols[nLinha][nPPrcAcr]	:= nPrcAcre
    EndIf	
	
	aCols[nLinha][nPTotAcr]	:= NoRound((aCols[nLinha][nPPrcAcr] * aCols[nLinha][nPQuant]) , TamSx3('UB_VRUNIT')[02])	//	TRUNCA 4	// DEIXEI COM 4DEC - DEPOIS O SISTEMA MESMO FAZ UM ROUND 2

    
	If lPrcTD .And. !lPrcxImp
		aProdXImp[nPosProd][18] := aCols[nLinha][nPPrcAcr]
	EndIf


EndIf

Return()
**********************************************************************
Static Function ImpSobPrcAcre()
**********************************************************************
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//| ATUALIZA PRECO UNITARIO COM O PRECO COM ACRESCIMO 					|
//| PARA BUSCAR R$ IPI, R$ ST, R$ FINAL. BASEADO NO PRECO COM ACRESCIMO	| 
//| OBS.: QUANTIDADE == 1  <---------------------	*****				|
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
Local lIMDF051		:=	Upper(SubStr(ProcName(04),03)) == 'IMDF051'
Local lTelaF11		:=	Upper(SubStr(ProcName(10),03)) == 'IMDF190'
Local nOrigPrcUnit	:=	GdFieldGet('UB_VRUNIT',	 nLinha)
Local nOrigQuant	:=	GdFieldGet('UB_QUANT', 	 nLinha)
Local nOrigTotal	:=	GdFieldGet('UB_VLRITEM', nLinha)
Local lQuant1		:=	GdFieldGet('UB_QUANT', 	 nLinha) == 1
Local nVlrImpST		:=	0
Local nVlrImpIPI	:=	0
Local nVlrImpZF		:=	0
Local naValDesp		:=	MaFisRet(nLinha, "IT_DESPESA")		// aValores[_DESPESA]
Local naValAcre		:=	MaFisRet(nLinha, "IT_ACRESCI")	// GdFieldGet('UB_VRCACRE',nLinha) - GdFieldGet('UB_VRUNIT',	nLinha)  //aValores[_ACRESCIMO]
Local naValFrete	:=	MaFisRet(nLinha, "IT_FRETE")
Local nSuframa		:=	MaFisRet(nLinha, "IT_DESCZF")


Local lRecalImp		:=	.T.
Local lVisual 		:= 	Nil
Local lRecalDel 	:= 	IIF(lDeletado, .F., .T.)
Local lSoItem 		:= 	.T.

Local lZeraDesp		:=	IIF(aValores[_DESPESA] + aValores[_ACRESCIMO] > 0, .T., .F.)
Local lZeraFrete	:=	IIF(aValores[_FRETE] > 0, .T., .F.)

Local lChkIPIST		:=	.T.
Local lExecuta		:=	.T.


	
/*
Local lExecuta		:=	IIF(GdFieldGet('UB_VRUNIT',	nLinha) == GdFieldGet('UB_VRCACRE',nLinha) .And. lQuant1, .F., .T.)
      lExecuta		:=	IIF(!lImposto, .F., lExecuta  )  
      lExecuta		:=	IIF(lCondPgto, .T., lExecuta  )  
	  lExecuta 		:=	IIF(MaFisRet(nLinha, "IT_VALIPI") + MaFisRet(nLinha, "IT_VALSOL") == 0, .F., lExecuta)
	  lExecuta 		:= 	IIF(GdFieldGet('UB_PRCFIN', nLinha) == 0 .Or.  GdFieldGet('UB_ST', nLinha) == 0, .T., lExecuta)
      lExecuta		:=	IIF(nSuframa > 0, .T., lExecuta)
  	  lExecuta		:=	IIF(lTelaDesc .Or. lDescGeral, .T., lExecuta)
    
	  lChkIPIST		:=	IIF(MaFisRet(nLinha, "IT_VALIPI") + MaFisRet(nLinha, "IT_VALSOL") == 0, .F., lChkIPIST )
	  lChkIPIST		:=	IIF(GdFieldGet('UB_PRCFIN', nLinha) == 0 .Or. GdFieldGet('UB_ST', nLinha) == 0, .T., lChkIPIST ) // RODAR MESMO Q VALIPI\ST = 0 PARA ATUALIZAR CAMPO PRECO C\IPI E PRECO FINAL
	  lChkIPIST		:=	IIF(cCampo $ 'UB_QUANT\UB_TES' .And. !lTelaF11 .And. !lQuant1 .And.;
	  						GdFieldGet('UB_PRCFIN', nLinha) > 0 .And. GdFieldGet('UB_ST', nLinha) > 0, .F., lChkIPIST)
      lChkIPIST		:=	IIF(lTelaDesc .Or. lDescGeral, .T., lChkIPIST)	

	  lExecuta		:=	IIF(lExecuta .And. !lChkIPIST, .F., lExecuta)

      lZeraDesp		:=	IIF(MaFisRet(nLinha, "IT_DESPESA") > 0, .T., lZeraDesp)
*/


//lRecalImp := IIF(lCondPgto, .F., lRecalImp)
//aNF_IMPOSTOS := MaFisRet(, "NF_IMPOSTOS")	<- NAO USAR VAI TER CASO Q A TES NAO CALCULA IMPOSTOS (Ex.: TES 508)
//lExecuta	 :=	IIF(Len(aNF_IMPOSTOS)> 0, .T., lExecuta)




//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//| QUANTIDADE == 1 PRECISA SIM CALCULAR POIS PRECO COM IPI, COM ST			|
//| Eh BASEADO EM CIMA DO CAMPO PRECO COM ACRESCIMO.						|
//| SENAO ENTRAR AQUI O VALOR DO PRECO COM IPI\ST SE BASEARA NO PRC.UNIT	|
//цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//| SE PRECO C\ACRE == PRECO UNITARIO NAO PRECISA CALCULAR					|
//| SE SUFRAMA PRECISA CALCULAR												|
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
If lExecuta

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	//| OBS.: NAO ATUALIZAR MaColsToFis QDO F4_PICMDIF > 0 (BASEICMS\VALICMS\VALST FICA ERRADA)		|
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	If GdFieldGet('UB_TES',nLinha) == SF4->F4_CODIGO
		lRecalImp := IIF(SF4->F4_PICMDIF > 0, .F., .T.)
	Else
		DbSelectArea('SF4');DbSetOrder(1)
		If DbSeek(xFilial('SF4') + GdFieldGet('UB_TES',nLinha), .F.)
			lRecalImp := IIF(SF4->F4_PICMDIF > 0, .F., .T.)
		EndIf
	EndIf
	                     

	//зддддддддддддддддддддддддддддддддддддддддддддд?
	//|  SE SUFRAMA > 0 NAO RECALCULA MaColaToFis	|
	//юддддддддддддддддддддддддддддддддддддддддддддд?
	lRecalImp := IIF(nSuframa > 0, .F., lRecalImp)
	

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	//|  NAO CONSIDERAR DESPESAS\ACRESCIMO NO CALCULO DOS VALORES DE IPI\ ST DOS CAMPO PRC.IPI\FINAL	|
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	//Function MaFisAlt(cCampo,nValor,nItem,lNoCabec,nItemNao,lDupl,cRotina,lRecal)
	IIF(lZeraDesp,  MaFisAlt("IT_DESPESA", 0, nLinha, .T.,,,,.F.), )
	IIF(lZeraFrete, MaFisAlt("IT_FRETE",   0, nLinha, .T.,,,,.F.), )

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	//|ALTERA PRECO UNITARIO COM O VALOR PRECO COM ACRESCIMO			|
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	nPrcAcre	:=	GdFieldGet('UB_VRCACRE',nLinha)

	GdFieldPut('UB_VRUNIT', nPrcAcre, nLinha)
	GdFieldPut('UB_VLRITEM',nPrcAcre, nLinha)
	GdFieldPut('UB_QUANT',	1, nLinha)
	MaFisAlt("IT_PRCUNI", 	nPrcAcre, nLinha)
	MaFisAlt("IT_QUANT", 	1, nLinha)
	MaFisAlt("IT_VALMERC",	nPrcAcre * GdFieldGet('UB_QUANT', nLinha), nLinha)
	MaFisAlt("IT_TOTAL",	nPrcAcre * GdFieldGet('UB_QUANT', nLinha), nLinha)
	
	

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	//| ROTINA CARREGAMENTO DA FUNCAO FISCAL COM BASE NO ACOLS E AHEADER	|
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	MaColsToFis(aHeader,aCols,nLinha,"TK271",lRecalImp,lVisual,lRecalDel,lSoItem)	//	ExpA1: Variavel com a estrutura do aHeader
															          				//	ExpA2: Variavel com a estrutura do aCols                     
															          	   			//	-> ExpN3: Item a ser carregado [ Nil = Todos ]          (opc)
															           				//	ExpC4: Nome do programa                                 (opc)
															          				//	ExpL5: Indica se o recalculo dos impostos deve ser feito(opc)
															          				//	ExpL6: Indica se o recalculo dos impostos deve ser feito(opc)
															          	 			//	ExpL7: Indica se o recalculo vai considerar as linhs apagadas

EndIf	




//зддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//|														|
//|	VERIFICA\ATUALIZA CAMPOS COM VALORES DOS IMPOSTOS	|
//|														|
//юддддддддддддддддддддддддддддддддддддддддддддддддддддд?
If lChkIPIST

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	//|CARREGAR NOVAMENTE aNF_IMPOSTOS := MaFisRet(, "NF_IMPOSTOS")		|
	//| MaColsToFis APAGA aNF_IMPOSTOS									|
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	aNF_IMPOSTOS := MaFisRet(, "NF_IMPOSTOS")

	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?ддддддддддддддд©
	//|	BUSCA VALOR DO ICMS - HOUVE CASOS QUE VLR.ICMS ESTAVA COM DIVERGENCIA					|
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?ддддддддддддды
	If Ascan(aNF_IMPOSTOS, {|X| 'ICM' == X[1]} ) > 0 .And. Ascan(aNF_IMPOSTOS, {|X| 'ICR' $ X[1]} ) > 0
		cIT_Campo 	:= "IT_VALICM"
		aValorImp 	:= 	ChkVlrImpostos( MaFisRet(nLinha, "IT_BASEICM"), MaFisRet(nLinha,"IT_ALIQICM"), MaFisRet(nLinha, "IT_VALICM"), nLinha, lRecalImp, 'IMPST')
	EndIf
	
	
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?ддддддддддддддд©
	//|	BUSCA VALOR DO IPI ( REFERNTE AO PRECO COM ACRESCIMO NAO CONSIDERANDO DESPESAS)			|
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?ддддддддддддды
	If Ascan(aNF_IMPOSTOS, {|X| 'IPI' == X[1]} ) > 0
		If MaFisRet(nLinha, "IT_VALIPI") > 0
			aValorImp 	:= 	ChkVlrImpostos( MaFisRet(nLinha, "IT_BASEIPI"), MaFisRet(nLinha,"IT_ALIQIPI"), MaFisRet(nLinha, "IT_VALIPI"), nLinha, .F.)
			nVlrImpIPI	:=	aValorImp[01]
		EndIf
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	//| BUSCA VALOR DO ICMS RETIDO - ST ( REFERNTE AO PRECO COM ACRESCIMO NAO CONSIDERANDO DESPESAS )			|
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	nPosST :=	Ascan(aNF_IMPOSTOS, {|X| 'ICR' $ X[1]})
	If nPosST > 0
		nVlrImpST	:=	MaFisRet(nLinha, "IT_VALSOL")
	EndIf
	
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	//| ATUALIZA CAMPOS DE R$ IMPOSTOS ( VALORES REFERENTE A PRECO COM ACRESCIMO NAO CONSIDERANDO DESPESAS )  	| 
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	//зддддддддддддддддддддддддд?
	//|   ICMS RETIDO - ST		| 
	//юддддддддддддддддддддддддд?
	GdFieldPut('UB_ST', nVlrImpST, nLinha)
	
	//зддддддддддддддддддддддддд?
	//|   IPI					| 
	//юддддддддддддддддддддддддд?
	nPrcComIpi := Round(GdFieldGet('UB_VRCACRE', nLinha) + nVlrImpIPI, TamSx3('UB_VLRITEM')[02])	//	TamSx3('UB_VRUNIT')[02]) = DEC 4
	GdFieldPut('UB_ACREIPI', nPrcComIpi  , nLinha)								//	PRECO + IPI
	GdFieldPut('UB_ALIQIPI', MaFisRet(nLinha, "IT_ALIQIPI"), 	nLinha)			//	% IPI
	GdFieldPut('UB_VALIPI',  nVlrImpIPI, nLinha)								//	VALOR IPI - MaFisRet(nLinha, "IT_VALIPI")
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	//|  PRECO FINAL = (PRECO C\ ACRESC + R$ IPI + R$ ST) - SUFRAMA		| 
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?                              
	//	SE USUARIO DIGITOU MESMA QUANTIDADE NO CAMPO UB_QUANT
	If cCampo=='UB_QUANT' .And. !lTelaF11 .And. GdFieldGet('UB_QUANT', nLinha) == aProdXImp[nPosProd][07] .And. MaFisRet(nLinha, "IT_DESCZF") > 0
		nPrcFinal	:=	GdFieldGet('UB_PRCFIN', nLinha)
    Else
		nPrcFinal	:=	Round( (GdFieldGet('UB_VRCACRE',nLinha) + nVlrImpIPI + nVlrImpST) - MaFisRet(nLinha, "IT_DESCZF") , TamSx3('UB_VRUNIT')[02])

		If nPrcComIpi > NoRound(nPrcFinal, TamSx3('UB_VLRITEM')[02])
			nPrcFinal	:=	Round(nPrcFinal, TamSx3('UB_VLRITEM')[02]) // ROUND 2
		EndIf
	EndIf
	      
	GdFieldPut('UB_PRCFIN', nPrcFinal, nLinha)
	
EndIf	
	

	
//зддддддддддддддддддддддддддддддддддддд?
//|	RESTAURA VALORES ORIGINAIS  		|
//юддддддддддддддддддддддддддддддддддддд?
If lExecuta

	//зддддддддддддддддддддддддддддддддд?
	//|  RESTAURA DESPESAS\ACRESCIMO 	|
	//юддддддддддддддддддддддддддддддддд?
	//Function MaFisAlt(cCampo,nValor,nItem,lNoCabec,nItemNao,lDupl,cRotina,lRecal)
	IIF(lZeraDesp, MaFisAlt("IT_DESPESA", naValDesp+naValAcre, nLinha, .T.,,,,.F.), )
	IIF(lZeraDesp, MaFisAlt("IT_FRETE",   naValFrete,          nLinha, .T.,,,,.F.), )
	
	GdFieldPut('UB_VRUNIT', nOrigPrcUnit, 	nLinha)
	GdFieldPut('UB_VLRITEM',nOrigTotal, 	nLinha)	
	GdFieldPut('UB_QUANT',	nOrigQuant, 	nLinha)	
	MaFisAlt("IT_PRCUNI", 	nOrigPrcUnit,	nLinha)
	MaFisAlt("IT_QUANT", 	nOrigQuant, 	nLinha)		
	MaFisAlt("IT_VALMERC",	nOrigTotal, 	nLinha)
	
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	//| ROTINA CARREGAMENTO DA FUNCAO FISCAL COM BASE NO ACOLS E AHEADER	|
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	lRecalImp	:=	IIF(nSuframa == 0, .F., .T.)
	lVisual 	:= 	Nil
	lRecalDel 	:= 	IIF(lDeletado, .F., .T.)
	lSoItem 	:= 	.T. 
	MaColsToFis(aHeader,aCols,nLinha,"TK271",lRecalImp,lVisual,lRecalDel,lSoItem)	//	ExpA1: Variavel com a estrutura do aHeader                   
															          				//	ExpA2: Variavel com a estrutura do aCols                     
															          				//	-> ExpN3: Item a ser carregado [ Nil = Todos ]          (opc)
															          				//	ExpC4: Nome do programa                                 (opc)
															          				//	ExpL5: Indica se o recalculo dos impostos deve ser feito(opc)
															          				//	ExpL6: Indica se o recalculo dos impostos deve ser feito(opc)
															          				//	ExpL7: Indica se o recalculo vai considerar as linhs apagadas
		
EndIf



Return()
**********************************************************************
Static Function ChkPrcBase()
**********************************************************************
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//|	BUSCA PRECO BASE ATRAVES DA FORMACAO DE PRECO.      				|
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
Local aArea			:=	GetArea()
Local aMyHeader		:=	aHeader
Local aMyCols		:=	aCols
Local nPrcBase		:=	0
Local nQuant		:=	1
Local nNewPrcUnit 	:= 	0
Local aFormaPrc		:= 	{}
Local cCodProd		:=	GdFieldGet('UB_PRODUTO', nLinha)
Local cTabela		:=	IIF(!Empty(GdFieldGet('UB_TABPRC',nLinha)), GdFieldGet('UB_TABPRC',nLinha), M->UA_TABELA)
Local cGrpSeg		:= 	''

						 							//	  [01] [02]   [02] [02]   [03] [02]
Local aTabelas 		:= &(GetMv('MV_SEGXTAB'))		//	{{"1","OEM"},{"2","MNT"},{"3","REV"}}



If lProspect
	If AllTrim(SUS->US_COD+SUS->US_LOJA) == AllTrim(M->UA_CLIENTE+M->UA_LOJA)
		cGrpSeg		:= 	SUS->US_GRPSEG	//M->UA_DESCSEG
	Else
		DbselectArea("SUS");DbSetOrder(1);DbGoTop()
		If DbSeek(xFilial("SUS")+M->UA_CLIENTE+M->UA_LOJA, .F.)
			cGrpSeg		:= 	SUS->US_GRPSEG
		EndIf
	EndIf
Else

	If AllTrim(SA1->A1_COD+SA1->A1_LOJA) == AllTrim(M->UA_CLIENTE+M->UA_LOJA)
		cCliente	:= M->UA_CLIENTE
		cLoja		:= M->UA_LOJA
	Else
		DbselectArea("SA1");DbSetOrder(1);DbGoTop()
		If DbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA, .F.)
			cCliente	:= SA1->A1_COD
			cLoja		:= SA1->A1_LOJA
		EndIf
	EndIf
	
	cGrpSeg	:= 	SA1->A1_GRPSEG
EndIf
	

nPSeg := Ascan(aTabelas, {|X| AllTrim(X[2]) == AllTrim(cGrpSeg) })
If nPSeg == 0
	
	nPSeg := Ascan(aTabelas, {|X| X[1] == Right(cGrpSeg,1) })
	If nPSeg > 0 
		cGrpSeg := aTabelas[nPSeg][02] 
	EndIf

EndIf
	


IIF(Select('TPB')!=0, TPB->(DbCloseArea()), )

cSql :=" SELECT NVL(NVL(SB1.B1_CUSTRP,0) *  		"+ENTER
cSql +=" 	CASE SB1.B1_MCUSTRP						"+ENTER
cSql += 	SqlChkMoeda()
cSql +=" 	END * NVL(IM1.IM1_MARKUP,0),0) PRCBASE	"+ENTER+ENTER

cSql +=" FROM 	"+ RetSqlName('DA1')+"	DA1	"+ENTER
cSql +=" 								INNER JOIN "+ RetSqlName('SB1')+" SB1 	"+ENTER
cSql +=" 								ON 	SB1.B1_FILIAL  = DA1.DA1_FILIAL 	"+ENTER
cSql +=" 								AND	SB1.B1_COD 	   = DA1.DA1_CODPRO 	"+ENTER
cSql +=" 								AND SB1.D_E_L_E_T_ = ' '				"+ENTER+ENTER

cSql +=" 								INNER JOIN "+ RetSqlName('SM2')+" SM2 		"+ENTER
cSql +=" 								ON 	SM2.M2_DATA 	= '"+DToS(dDataBase)+"'	"+ENTER
cSql +=" 								AND SM2.D_E_L_E_T_ 	= ' '					"+ENTER+ENTER

cSql +=" 								INNER JOIN "+ RetSqlName('IM1')+" IM1 	"+ENTER
cSql +=" 								ON 	IM1.IM1_FILIAL 	= DA1.DA1_FILIAL 	"+ENTER
cSql +=" 								AND IM1.IM1_COD 	= SB1.B1_CURVA 		"+ENTER
cSql +=" 								AND IM1.IM1_SEGMEN 	= '"+cGrpSeg+"' 	"+ENTER
cSql +=" 								AND IM1.D_E_L_E_T_ 	= ' ' 				"+ENTER+ENTER

cSql +=" WHERE DA1.DA1_FILIAL 	= '"+cFilAnt+"' 	"+ENTER
cSql +=" AND DA1.DA1_CODTAB 	= '"+cTabela+"' 	"+ENTER
cSql +=" AND DA1.DA1_CODPRO   	= '"+cCodProd+"' 	"+ENTER
cSql +=" AND DA1.D_E_L_E_T_ 	= ' ' 				"+ENTER

DbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), 'TPB', .F., .T.)
DbSelectArea('TPB')
nPrcBase := TPB->PRCBASE

//зддддддддддддддддддддддддддддддддддддд?
//|  ATUALIZA PRECO BASE X IMPOSTOS     | 
//юддддддддддддддддддддддддддддддддддддд?
nVlrImp 	:=	aProdxImp[nPosProd][21]		//	[21] SOMA ALIQUOTAS IMPOSTOS
nPrcBase	:=	NoRound(nPrcBase / ((100 - nVlrImp) / 100), TamSx3('UB_VRUNIT')[02])

aProdxImp[nPosProd][22] := nPrcBase

//зддддддддддддддддддддддддддд?
//|	 ATUALIZA PRECO BASE      | 
//юддддддддддддддддддддддддддд?
GdFieldPut('UB_PRCBASE', nPrcBase, nLinha)


IIF(Select('TPB')!=0, TPB->(DbCloseArea()), )
RestArea(aArea)
Return()
**********************************************************************
Static Function ChkDesconto()
**********************************************************************
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//|	FUNCAO ATUALIZA COM VALORES PADRAO E VERIFICA\ATUALIZA DESCONTO		|
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
Local lDescRD	:=	cCampo == 'UB_DESCRD'
Local lCpoCabec	:=  Left(cCampo,2) == 'UA'
Local lCpoGrid	:=  Left(cCampo,2) == 'UB'
Local lAtuTDesc	:=	.F.
Local nPriori	:=	0
Local nVlrDesRD	:=	0
Local nReplDesc	:=	0
Local lVerifica := .T.
Local aAcrescimo:=	{}
Local aDesconto	:=	{}
Local nAcreUser :=  GdFieldGet('UB_ACRE2',nLinha)
Local nOriVrUnit:=	GdFieldGet('UB_VRUNIT',nLinha)
Local nPrcUnit  := 	GdFieldGet('UB_VRUNIT',nLinha)
Local nTotal	:=	GdFieldGet('UB_VLRITEM',nLinha)
Local lTk273Calc:=	.F.



If GdFieldPos(cCampo) > 0 .And. cCampo != 'UB_TES'
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	//|QUANDO EXECUTADO O TK273CALCULA RODA VERIFICACAO PADRAO.				|
	//|UB_VRUNIT JA ESTA COM DESCONTOS PADROES (UA_DESC1,2,3e4 UB_DESC) 	|
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	lTk273Calc := "TK273CALCULA" $ Upper(aHeader[GdFieldPos(cCampo)][6])
EndIf


	

If lTelaDesc .Or. lCpoCabec .Or. GdFieldPos(cCampo) > 0 .Or. lTelaF6 .Or. lHistorico


	//зддддддддддддддддддддддддддддддддддддддддддддд?
	//| VERIFICA SE DEVE CHECAR ROTINA		 		|
	//юддддддддддддддддддддддддддддддддддддддддддддд?
    If lTelaDesc
		
		If nPosProd > 0
		
			//зддддддддддддддддддддддддддддддддддддддддддддд?
			//| VERIFICA SE PRECO FINAL == PRECO C\ACRESC	|
			//юддддддддддддддддддддддддддддддддддддддддддддд?
			If GdFieldGet('UB_DESCVEN',nLinha) > 0
				nPercCalc :=	1-(GdFieldGet('UB_DESCVEN',nLinha)/100)
			ElseIf GdFieldGet('UB_ACRE2',nLinha) > 0
				nPercCalc :=	1+(GdFieldGet('UB_ACRE2',nLinha)/100)
			Else
				nPercCalc := 1
			EndIf

			nPrcFinal		:=	Round( GdFieldGet('UB_VRCACRE', nLinha) * nPercCalc, TamSx3('UB_VRUNIT')[02])
			nVlrImp 		:=	aProdxImp[nPosProd][21]							
			nPrcFinal		:=	Round( (nPrcFinal / ((100 - nVlrImp) / 100)), TamSx3('UB_VRUNIT')[02])
			nPrcFinal		:=	Round(nPrcFinal * (1+(nE4Acresc/100)), TamSx3('UB_VRUNIT')[02] )
        
        	If nPrcFinal == GdFieldGet('UB_VRCACRE', nLinha)
				lVerifica := .F.
			EndIf

   		Else
   			lVerifica := .F.
  		EndIf


	ElseIf nPosProd > 0
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		//|** NAO VERIFICAR SE NAO HOUVE ALTERACAO    						|
		//| CAMPOS COMO UB_PRODUTO, UB_QUANT e UB_TES DEVEM SER 			|
		//| RECALCULADOS POIS UTILIZAM NO X3_VALID A FUNCAO TK273CALCULA 	|
		//| QUE ATUALIZA O PRECO UNITARIO									|
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?  
		If cCampo == 'UB_DESCRD' 
			nVlrDesRD := &(cCampo)
			If GdFieldGet('UB_DESCRD',nLinha) == GdFieldGet('UB_ORIGRD',nLinha) .And. nVlrDesRD == GdFieldGet('UB_DESCRD',nLinha)
				lVerifica := .F.
			EndIf
	    EndIf
		
    EndIf
    
    
	
	If lVerifica


		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		//| PREENCHE CAMPO DESCONTO(CUSTOMIZADO) COM O DESCONTO DA REGRA DE DESCONTO E ZERA 	|
		//|	O DESCONTO PADRAO PARA NAO IMPACTAR NAS REGRAS DE NEGOCIO						    |
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		If GdFieldGet('UB_DESC',nLinha) > 0

			nDescRD  := GdFieldGet('UB_DESC', 	nLinha)
			GdFieldPut('UB_DESCRD',  nDescRD, 	nLinha)		//	DESCONTO DE REGRA

			If GdFieldGet('UB_ORIGRD', nLinha) == 0
				GdFieldPut('UB_ORIGRD', nDescRD, nLinha)	//	GRAVA CAMPO COM DESCONTO PADRAO
			EndIf

			GdFieldPut('UB_DESC',  0,	nLinha)				//	DESCONTO PADRAO	-> ZERA PARA NAO CONSIDERAR NA REGRA DE NEGOCIIO
															//	REGRA DE DESCONTO CUSTOMIZADA CONSIDERA APENAS OS DESCONTOS CONCEDIDOS PELO VENDEDORES (NAO A Q VEM DA RD)
		ElseIf cCampo == 'UB_PRODUTO' .And. GdFieldGet('UB_DESC',nLinha) == 0 .And. GdFieldGet('UB_DESCRD',nLinha) > 0
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
			//|  LIMPA CAMPO DESCONTO REGRA DE DESCONTO										|
			//| EX.: PROD.TEM DESC.RD E USER ALTERA P/ NOVO PROD. Q TEM NAO TEM DESC.RD		|
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
			GdFieldPut('UB_DESCRD',  0,	nLinha)
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		//|  NECESSARIO ZERAR VALOR DO DESCONTO PARA NAO INFLUENCIAR NA NOTA FISCAL		|
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		If GdFieldGet('UB_VALDESC', nLinha) > 0
			GdFieldPut('UB_VALDESC', 0, nLinha)
		EndIf
		
	
		// AJUSTE PQ QDO INFO QUANTIDADE RODA TK273CALCULA E ZERA ACRESCIMO
		If GdFieldGet('UB_ACRE',nLinha) > 0 
			GdFieldPut('UB_ACRE2', GdFieldGet('UB_ACRE',nLinha), nLinha)	
			nAcreUser := GdFieldGet('UB_ACRE2',nLinha)
			GdFieldPut('UB_ACRE', 0, nLinha)
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		//|  NECESSARIO ZERAR VALOR DO DESCONTO PARA NAO INFLUENCIAR NA NOTA FISCAL		|
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		If GdFieldGet('UB_VALACRE', nLinha) > 0
			GdFieldPut('UB_VALACRE', 0, nLinha)
		EndIf		


				


		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		//| VERIFICA ALTERACAO DO CAMPO UB_DESCRD -> REGRA DESCONTO		|
		//| Tk273Calcula ATUALIZA UB_VRUNIT COM DESCONTO PADRAO		 	|
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		nVlrDesRD := IIF(cCampo $ 'UB_DESCRD', &(cCampo), GdFieldGet('UB_DESCRD',nLinha))
		If nVlrDesRD > 0

			Aadd(aDesconto, {nPriori++, 'UB_DESCRD', nVlrDesRD})
		
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддд?
			//|	*** CAMPO UB_DESCRR NAO Eh ALTERADO					|
			//| SEU CONTEUDO Eh PREENCHIDO ATRAVES PE FT080RDES.PRW	|
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддд?
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
			//|	OBS.: POREM AO BUSCAR AT DO HISTORICO NAO EH EXECUTADO O PE FT080RDES.PRW	|
			//|		  QDO HISTORICO Eh CARREGADO VIA FUNCAO ChkRegDesc()				 	|
			//|		  IMPORTANTE CARREGAR O CONTEUDO DO UB_DESCRD NO ARRAY aRegDesc			|
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			/*
			//зддддддддддддддддддддддддддддд?
			//|aRegDesc DESCONTO VENDEDOR	|
			//юддддддддддддддддддддддддддддд?
			//nPos := Ascan(aRegDesc,{|X| Upper(X[1]) == Upper('Item RD') .And. X[2] == StrZero(nLinha, TamSx3('UB_ITEM')[1]) .And. X[3] == cCodRegra })
	    	//If nPos == 0
			//	Aadd(aRegDesc, {'Item RD', StrZero(nLinha, TamSx3('UB_ITEM')[1]), ''cCodRegra, nVlrDesRD, '000000'cItemACP })
			//Else
			//	aRegDesc[nPos][4] := nVlrDesRD		
			//EndIf
			*/
		Else
			 ExcluiRD('Item RD')
		EndIf
  

		
		//здддддддддддддддддддддддддддддддддддддддд©
		//| VERIFICA DESCONTO GERAL - M->UA_DESCG  |
		//юдддддддддддддддддддддддддддддддддддддддды
		If M->UA_DESCG > 0

			If cCampo == 'UA_DESCG'
				If GdFieldGet('UB_DESCVEN',nLinha) > aProdXImp[nPosProd][20]
					aProdXImp[nPosProd][24] := (GdFieldGet('UB_DESCVEN',nLinha) - aProdXImp[nPosProd][20])						
				Else 
					aProdXImp[nPosProd][24] :=  0 // GdFieldGet('UB_DESCVEN',nLinha)
				EndIf
			EndIf

			IIF(nPosProd 	> 0, aProdXImp[nPosProd][20] := M->UA_DESCG, )
			IIF(M->UA_DESCG	> 0, Aadd(aDesconto, {nPriori++, 'UA_DESCG', M->UA_DESCG}), )

			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
			//| SE TELA DESCONTO (DESC.G == 5%) E USUARIO DEU ZERO DE DESCONTO		|
			//|	ENTAO ZERA O DESC.VEND E O DESC.G       							|
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
       		If lTelaDesc
	       		If GdFieldGet('UB_DESCVEN',nLinha) == 0
	    
	       			IIF(nPosProd > 0, aProdXImp[nPosProd][20] := 0, )

					nPos := Ascan(aDesconto, {|X| X[2] == 'UA_DESCG' })
					If nPos > 0
						aDesconto[nPos][03] := 0
					EndIf
		
				EndIf
     		EndIf

		Else
			If nPosProd > 0 .And. cCampo == 'UA_DESCG' 
				// nos casos onde vem 2%descg via historico e user coloca 0%
				aProdXImp[nPosProd][24] := (GdFieldGet('UB_DESCVEN',nLinha) - aProdXImp[nPosProd][20])
			EndIf
							
			IIF(nPosProd > 0, aProdXImp[nPosProd][20] := 0, )
		EndIf




		//зддддддддддддддддддддддддддддддддддддддддддддд?
		//| VERIFICA DESCONTO VENDEDOR  - UB_DESCVEN	|
		//юддддддддддддддддддддддддддддддддддддддддддддд?
		If GdFieldGet('UB_DESCVEN',nLinha) > 0 

			//      <                      >                 ==
			// DESCG 	= 3%		DESCG 	 = 3%		DESCG    = 3%
			// DESCVEN  = 5%		DESCVEN  = 2%		DESCVEN  = 3%
			// -------------	    -------------	    -------------
			// ALCADA 	= 2%		ALCADA   = 2%		ALCADA 	 = 0%
			// DESCG	= 3%		DESCG	 = 0%		DESCG	 = 3%

            If nPosProd > 0
            
				If M->UA_DESCG < GdFieldGet('UB_DESCVEN',nLinha) 
					// DESCG 	= 3%	|	DESCG 	 = 5% -> 0%  4%->2%
					// DESCVEN  = 5% 	|	DESCVEN  = 0% -> 5%  4%->4%
					// -------------	|	-------------
					// ALCADA 	= 2%	|	DESCVEN	 = 5% -> 0%  4%->2%
	
	                If lTelaDesc .Or. cCampo == 'UB_TES' .Or. lTk273Calc 	// lTk273Calc = QUANDO USER CLICA NA QUANTIDADE...
						aProdxImp[nPosProd][24] := GdFieldGet('UB_DESCVEN',nLinha) - aProdxImp[nPosProd][20]
					EndIf
					
					nPos := Ascan(aDesconto, {|X| X[2] == 'UA_DESCG' })
					If nPos > 0
						aDesconto[nPos][02] := 'DESC.VEND'
						nDescG 		:= 	aProdxImp[nPosProd][20] 
						nDescV		:=	aProdxImp[nPosProd][24]
						nDesconto	:=	IIF(lTelaDesc, nDescG+nDescV, IIF(nDescV >= nDescG, nDescV, nDescG+nDescV))
						aDesconto[nPos][03] := nDesconto
					Else
						Aadd(aDesconto, {nPriori++, 'TELADESC', aProdxImp[nPosProd][24] })
					EndIf
	
					// Aadd(aDesconto, {nPriori++, 'TELADESC', GdFieldGet('UB_DESCVEN',nLinha) })	
				
				ElseIf M->UA_DESCG > GdFieldGet('UB_DESCVEN',nLinha) 
					// DESCG 	= 3%	|	DESCG 	 = 3% -> 5%		|	DESCG 	 = 5% -> 5% -> 5%	|	DESCG 	 = 3% -> 4%
					// DESCVEN  = 2%	|	DESCVEN  = 0% -> 0%		|	DESCVEN  = 5% -> 3% -> 3%	|	DESCVEN  = 0% -> 0%
					// -------------	|	-------------			|	-------------				|	-------------
					// ALCADA 	= 2%	|	ALCADA 	 = 0% -> 0% 	|	ALCADA 	 = 0% -> 3% -> 3%	|	ALCADA 	 = 0% -> 0%
					// DESCG	= 0%	|	DESCG	 = 3% -> 5%		|	DESCG	 = 5% -> 0% -> 5% 	|	DESCG	 = 3% -> 4%
	
					If cCampo == 'UA_DESCG'
	
						nPos := Ascan(aDesconto, {|X| X[2] == 'UA_DESCG' })
						If nPos > 0
							aDesconto[nPos][02] 	:= 	'DESC.VEND'
							aDesconto[nPos][03] 	:= 	aProdxImp[nPosProd][20] + aProdxImp[nPosProd][24]
						Else
	    	           		Aadd(aDesconto, {nPriori++, 'TELADESC', GdFieldGet('UB_DESCVEN',nLinha) })
	   	 				EndIf
	
					Else
					
						aProdxImp[nPosProd][20] := 0
						aProdxImp[nPosProd][24] := GdFieldGet('UB_DESCVEN',nLinha)
						Aadd(aDesconto, {nPriori++, 'TELADESC', GdFieldGet('UB_DESCVEN',nLinha) })
	
						If lTelaDesc
							nPos := Ascan(aDesconto, {|X| X[2] == 'UA_DESCG' })
							If nPos > 0
								aDesconto[nPos][03] := 0
							EndIf
						EndIf
						
					EndIf
					
				Else
	
						// TELA DESCONTO        CAMPO DESCG
					// DESCG 	= 3%		DESCG 	 = 3%
					// DESCVEN  = 3%		DESCVEN  = 3%
					// -------------  		-------------
					// ALCADA 	= 0%       	ALCADA 	 = 3%
					// DESCG	= 3%    	DESCG	 = 3%
					
	                If lTelaDesc
	                	If M->UA_DESCG > 0   
	                		//	aDesconto CONTEM UA_DESCG
	                		aProdxImp[nPosProd][24] := 0 
	                		//Aadd(aDesconto, {nPriori++, 'UA_DESCG', M->UA_DESCG })
	                	Else
	                		//	aDesconto CONTEM UA_DESCG ZERADO
	                		aProdxImp[nPosProd][24] := GdFieldGet('UB_DESCVEN',nLinha)
	                		Aadd(aDesconto, {nPriori++, 'TELADESC', GdFieldGet('UB_DESCVEN',nLinha) })
	                	EndIf
	                	
					Else
	
						If M->UA_DESCG > 0
							
							lDescG := (M->UA_DESCG == GdFieldGet('UB_DESCVEN',nLinha)) .Or. (cCampo=='UA_DESCG')
	
							nPos := Ascan(aDesconto, {|X| X[2] == 'UA_DESCG' })
							If nPos > 0                
								If (M->UA_DESCG == GdFieldGet('UB_DESCVEN',nLinha)) .And. (cCampo!='UA_DESCG')
									aProdxImp[nPosProd][24] := 0
								EndIf
								aDesconto[nPos][02] := 'DESC.VEND'
								aDesconto[nPos][03] := IIF(lDescG,aProdxImp[nPosProd][20],0) + aProdxImp[nPosProd][24]
														//	IIF(cCampo=='UA_DESCG',0,aProdxImp[nPosProd][20]) + aProdxImp[nPosProd][24]
							Else
		                		aProdxImp[nPosProd][24] := IIF(lDescG, aProdxImp[nPosProd][24] , GdFieldGet('UB_DESCVEN',nLinha))
		                								 //	IIF(cCampo=='UA_DESCG', aProdxImp[nPosProd][24] , GdFieldGet('UB_DESCVEN',nLinha))
	    	            		Aadd(aDesconto, {nPriori++, 'TELADESC', GdFieldGet('UB_DESCVEN',nLinha) })
	    	 				EndIf
	    	 				
	                	EndIf
	
					EndIf
					
				EndIf
            Else
            	//зддддддддддддддддддддддддддддддддддддддддддддддддддддд?
				//| CONCIDERA DESCONTO DO ITEM DO ALMOX_01 -> ALMOX_02	|
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддд?
				Aadd(aDesconto, {nPriori++, 'DESC.VEND', GdFieldGet('UB_DESCVEN',nLinha) })
	            Aadd(aRegDesc,  {'Desc.Vend', GdFieldGet('UB_ITEM',nLinha), '', GdFieldGet('UB_DESCVEN',nLinha), '' })
	            nReplDesc	:=	GdFieldGet('UB_DESCVEN', nLinha)
            EndIf

        ElseIf GdFieldGet('UB_DESCVEN',nLinha) == 0
        	IIF(nPosProd > 0, aProdxImp[nPosProd][24] := 0, )
        EndIf
        

        
                 
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		//|  AJUSTA ARRAY aDescomto DESCONTOS e aRegDesc REGRA DE DESCONTO			|
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		If nPosProd > 0

		    If Left(cCampo,2) == 'UB'
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
				//| CONSIDERAR DESCONTO QUE CONSTA NA LINHA DO ATENDIMENTO 		|
				//| DESC.LINHA ESTARA, OU NAO, CONTEMPLANDO O DESC.GERAL		|
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?/ Aadd(aDesconto, {nPriori++, 'UA_DESCG', M->UA_DESCG})
				nPos := Ascan(aDesconto, {|X| X[2] == 'UA_DESCG'})
				If nPos > 0
					aDesconto[nPos][3] 		:= 0
					aProdxImp[nPosProd][20]	:= 0
				EndIf
			EndIf	


				//	 [20] DESC.GERAL			[24] DESC.VEND				
			If ( aProdxImp[nPosProd][20] + aProdxImp[nPosProd][24] ) > 0

				//зддддддддддддддддддддддддддддд?
				//|aRegDesc DESCONTO VENDEDOR	|
				//юддддддддддддддддддддддддддддд?
				nDescVend := aProdxImp[nPosProd][20] + aProdxImp[nPosProd][24]
				nPos := Ascan(aRegDesc,{|X| X[1] == 'Desc.Vend' .And. X[2] == GdFieldGet('UB_ITEM',nLinha)  })
		    	If nPos == 0
					Aadd(aRegDesc, {'Desc.Vend', GdFieldGet('UB_ITEM',nLinha), '', nDescVend, '' })
				Else
					aRegDesc[nPos][04] := nDescVend
				EndIf
            
            Else
				ExcluiRD('Desc.Vend')
			EndIf

		EndIf



		//зддддддддддддддддддддддддддддддддд?
		//|   DESCONTO COMP.ST \ ICMS		|
		//юддддддддддддддддддддддддддддддддд?
		nDescCompST := 	ExecBlock('ChkDCompST', .F., .F., {nLinha} )
		nDescICM	:=	ExecBlock('ChkDescICM', .F., .F., {nLinha} )
		
		If nDescCompST > 0
			Aadd(aDesconto, {nPriori++, 'COMP.ST', nDescCompST})
		Else
			ExcluiRD('COMP.ST', 03)
		EndIf
		
		If nDescICM > 0
			Aadd(aDesconto, {nPriori++, 'ICM', nDescICM})
		Else
			ExcluiRD('ICM', 03)
		EndIf


		



		//зддддддддддддддддддддддддддддддддд?
		//|   ARRAY DE ACRESCIMO 			|
		//юддддддддддддддддддддддддддддддддд?
		If M->UA_ACREG > 0 .And. !lTelaDesc
			Aadd(aAcrescimo, {'UA_ACREG', M->UA_ACREG}) 
			GdFieldPut('UB_ACRE2',  M->UA_ACREG, 	nLinha)	
			
		ElseIf cCampo == 'UA_ACREG' .And. M->UA_ACREG == 0 
			GdFieldPut('UB_ACRE2',  M->UA_ACREG, 	nLinha)	

		Else
			If nAcreUser > 0
				Aadd(aAcrescimo, {'UB_ACRE2', nAcreUser} )
			EndIf
		EndIf
		
		If nPosProd > 0
			aProdxImp[nPosProd][23] := GdFieldGet('UB_ACRE2',nLinha)
		EndIf
		
		//зддддддддддддддддддддддддддддд?
		//|aRegDesc ACRESCIMO GERAL		|
		//юддддддддддддддддддддддддддддд?
		If GdFieldGet('UB_ACRE2',nLinha) > 0
			nPos := Ascan(aRegDesc,{|X| X[1] == 'Acrec.Vend' .And. X[2] == GdFieldGet('UB_ITEM',nLinha)  })
		   	If nPos == 0
				Aadd(aRegDesc, {'Acrec.Vend', GdFieldGet('UB_ITEM',nLinha), '', GdFieldGet('UB_ACRE2',nLinha), '' })
			Else
				aRegDesc[nPos][04] := GdFieldGet('UB_ACRE2',nLinha)
			EndIf
			
		Else
			ExcluiRD('Acrec.Vend')
	    EndIf
		
		


		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		//| FORCA PRC.UNIT = PRC.TAB PARA CALCULAR DESCONTOS\ACRESCIMOS		|
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		GdFieldPut('UB_VRUNIT', GdFieldGet('UB_PRCTAB',nLinha), nLinha)	

	



		
		//зддддддддддддддддддддддддддддддддддддддддддддддддд?
		//|      D E S C O N T O   	C A S C A T E A D O		|
		//юддддддддддддддддддддддддддддддддддддддддддддддддд?
		aSort(aDesconto,,,{|X,Y| X[1] < Y[1]})
		nContDesc :=  100
		For nD := 1 To Len(aDesconto)
			nPercDesc 	:=	aDesconto[nD][03] / 100
			nContDesc 	:= 	nContDesc - (nContDesc * nPercDesc)
		Next
		nPercDesc := 100 - nContDesc

		If nPercDesc > 0
			//зддддддддддддддддддддддддддддддддддддддддддддд?
			//|   ATUALIZA PRECO UNITARIO COM DESCONTO		|
			//юддддддддддддддддддддддддддддддддддддддддддддд?
			nPercCalc := 1-(nPercDesc/100)
			nPrcUnit  := (GdFieldGet('UB_VRUNIT',nLinha) * nPercCalc )  // [F] Round(GdFieldGet('UB_VRUNIT',nLinha) * nPercCalc , TamSx3('UB_VRUNIT')[02])
			
			GdFieldPut('UB_VRUNIT', nPrcUnit, nLinha)

			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
			//|  ATUALIZA TOTAL PRECO UNIT. SEM ACRESCIMO FINANCEIRO	|
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
			nTotal	:=	A410Arred(GdFieldGet('UB_VRUNIT',nLinha) * GdFieldGet('UB_QUANT',nLinha), 'UB_VLRITEM') // [F] A410Arred( (GdFieldGet('UB_VRUNIT',nLinha) * GdFieldGet('UB_QUANT',nLinha) ),'UB_VLRITEM')	
			GdFieldPut('UB_VLRITEM', nTotal, nLinha)
			
		EndIf
		


		
		//зддддддддддддддддддддддддддддд?
		//|   	 A C R E S C I M O 	   	|
		//юддддддддддддддддддддддддддддд?
		For nA := 1 To Len(aAcrescimo)
		
			nAcreUser := aAcrescimo[nA][02]
		
			//зддддддддддддддддддддддддддддддддддддддддддддд?
			//|  ATUALIZA PRECO UNITARIO COM ACRESCIMO		|
			//юддддддддддддддддддддддддддддддддддддддддддддд?
			nPercCalc :=	1+(nAcreUser/100)
			nPrcUnit := GdFieldGet('UB_VRUNIT',nLinha) * nPercCalc
			// If !lTelaDesc nPrcUnit := Round(GdFieldGet('UB_VRUNIT',nLinha) * nPercCalc, TamSx3('UB_VRUNIT')[02])

			
			GdFieldPut('UB_VRUNIT', nPrcUnit, nLinha)
		
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
			//|  ATUALIZA TOTAL PRECO UNIT. SEM ACRESCIMO FINANCEIRO	|
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
			nTotal	:=	A410Arred( GdFieldGet('UB_VRUNIT',nLinha) * GdFieldGet('UB_QUANT',nLinha), 'UB_VLRITEM')	//	[F] A410Arred( (GdFieldGet('UB_VRUNIT',nLinha) * GdFieldGet('UB_QUANT',nLinha) ),'UB_VLRITEM')	
			GdFieldPut('UB_VLRITEM', nTotal, nLinha)	
		
				
		Next
		
		


		//зддддддддддддддддддддддддддддддддддддддддддддд?
		//| ALTERA PRECO UNITARIO COM O NOVOS VALORES 	|
		//юддддддддддддддддддддддддддддддддддддддддддддд?
		If GdFieldGet('UB_VRUNIT', nLinha)	!= nOriVrUnit
			
			MaFisAlt("IT_PRCUNI", 	nPrcUnit, nLinha)
			MaFisAlt("IT_QUANT", 	GdFieldGet('UB_QUANT',nLinha), nLinha)
			MaFisAlt("IT_VALMERC",	(GdFieldGet("UB_VRUNIT",nLinha)*GdFieldGet('UB_QUANT',nLinha)), nLinha)
			MaFisAlt("IT_TOTAL",	(GdFieldGet("UB_VRUNIT",nLinha)*GdFieldGet('UB_QUANT',nLinha)), nLinha)
		EndIf    

	
		//зддддддддддддддддддддддддддддддддд?
		//| 	  VERIFICA DESCONTOS        |
		//юддддддддддддддддддддддддддддддддд?
		nDescGeral	:=	IIF(nPosProd > 0, aProdxImp[nPosProd][20], M->UA_DESCG)
		nDescVend 	:= 	IIF(nPosProd > 0, aProdxImp[nPosProd][24], IIF(nReplDesc > 0, nReplDesc, 0))



		//зддддддддддддддддддддддддддддддддд?
		//| PREENCHE CAMPO TOTAL DESCONTO  	|
		//юддддддддддддддддддддддддддддддддд?
		nTotDesc	:=	M->UA_DESC1 + M->UA_DESC2 + M->UA_DESC4 + nDescGeral + nDescVend + nVlrDesRD 
		GdFieldPut('UB_TOTDESC', nTotDesc,	 nLinha)
	
	
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		//| PREENCHE CAMPO DESCONTO CONCEDIDO + DESCONTO GERAL	|
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		GdFieldPut('UB_DESCVEN', nDescGeral + nDescVend, nLinha)
	
		
		// verifica se existe desconto do vendedor
		// caso nao tenha zera [18] para nao considerar lPratic (preco a ser praticado) na funcao CalcPrcxImp
		If nPosProd > 0
			
			If lHistorico 
				aProdXImp[nPosProd][18] := GdFieldGet('UB_VRCACRE', nLinha)
			EndIf
			
			If aProdxImp[nPosProd][23] + aProdxImp[nPosProd][24] == 0
				aProdXImp[nPosProd][18]	:=	0
	        EndIf	        
	   EndIf
	    
    EndIf
    
EndIf

Return(lVerifica)
**********************************************************************
User Function ChkDCompST()
**********************************************************************
Local nLinAT	 := ParamIxb[01]
Local nDesconto  := 0
Local cEstMV     :=  GetMv('MV_ESTADO')
Local cCodProd	 :=	 GdFieldGet('UB_PRODUTO',nLinAT)
Local cCFOP		 :=	 AllTrim(GdFieldGet('UB_CF', nLinAT))
Local cTES		 :=	 AllTrim(GdFieldGet('UB_TES',nLinAT))
Local cEstCli	 :=	 ''
Local cOriGer 	 :=	 ''

If lProspect
	
	If AllTrim(SUS->US_COD+SUS->US_LOJA) == AllTrim(M->UA_CLIENTE+M->UA_LOJA)
		cCliente	:= 	M->UA_CLIENTE
		cLoja		:= 	M->UA_LOJA
	Else
		DbselectArea("SUS");DbSetOrder(1);DbGoTop()
		If DbSeek(xFilial("SUS")+M->UA_CLIENTE+M->UA_LOJA, .F.)
			cCliente	:= 	SUS->US_COD
			cLoja		:= 	SUS->US_LOJA
		EndIf
	EndIf
    
	cEstCli		:= 	SUS->US_EST

Else
		
	If AllTrim(SA1->A1_COD+SA1->A1_LOJA) == AllTrim(M->UA_CLIENTE+M->UA_LOJA)
		cEstCli	:= 	SA1->A1_EST
	Else
		DbselectArea("SA1");DbSetOrder(1);DbGoTop()
		If DbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA, .F.)
			cEstCli	:= 	SA1->A1_EST
		EndIf
	EndIf

EndIf	



If AllTrim(cCodProd) == AllTrim(SB1->B1_COD)
	cOriGer := AllTrim(SB1->B1_ORIGER)
Else
	DbselectArea("SB1");DbSetOrder(1);DbGoTop()
	If DbSeek(xFilial("SB1")+cCodProd)
		cOriGer := AllTrim(SB1->B1_ORIGER)
	EndIf
EndIf
	
	
If ( (cEstCli == cEstMV .And. cEstMV == 'PR' .And. cTES  == '724' ) .Or.;
	 (cEstCli == cEstMV .And. cEstMV == 'SC' .And. cTES  == '721' ) .Or.;
	 (cEstCli == cEstMV .And. cEstMV == 'RS' .And. cTES  == '721' ) )
	
	If SX5->(DbSeek(xFilial("SX5") + "77" +cFilAnt,.F.))
		nDesconto := Val(StrTran(SX5->X5_DESCRI,",",".")) 
		nDesconto := (100-(100*nDesconto))		
	EndIf

EndIf


//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//| GRAVA EM aRegDesc % DESCONTO PARA MOSTRA NA TELA PRODUTO X IMPOSTOS 	|
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
If nDesconto > 0
	// nPos := Ascan(aRegDesc,{|X| X[1] == 'Fiscal' .And. X[2] == StrZero(nLinAT, TamSx3('UB_ITEM')[1]) .And. AllTrim(X[3]) == 'Comp.ST' })
	nPos := Ascan(aRegDesc,{|X| X[1] == 'Fiscal' .And. X[2] == GdFieldGet('UB_ITEM', nLinAT) .And. AllTrim(X[3]) == 'Comp.ST' })
	If nPos == 0
		// Aadd(aRegDesc, {'Fiscal', StrZero(nLinAT, TamSx3('UB_ITEM')[1]), 'Comp.ST', nDesconto, '' })
		Aadd(aRegDesc, {'Fiscal', GdFieldGet('UB_ITEM', nLinAT), 'Comp.ST', nDesconto, '' })
	EndIf
Else
	// nPos := Ascan(aRegDesc,{|X| X[1] == 'Fiscal' .And. X[2] == StrZero(nLinAT, TamSx3('UB_ITEM')[1]) .And. X[3] == 'Comp.ST' })
	nPos := Ascan(aRegDesc,{|X| X[1] == 'Fiscal' .And. X[2] == GdFieldGet('UB_ITEM', nLinAT) .And. X[3] == 'Comp.ST' })
	If nPos > 0
		aRegDesc[nPos][04] := 	0
	EndIf
EndIf
	   
Return(nDesconto)
**********************************************************************
User Function ChkDescICM()
**********************************************************************
Local aAreaSZW 	:=	GetArea()
Local nLinAT	:= 	ParamIxb[01]
Local cTES     	:= 	GdFieldGet('UB_TES', nLinAT)
Local cCodProd	:=	GdFieldGet('UB_PRODUTO',nLinAT)
Local lChkDesc 	:= 	.F.
Local nPerDesc	:=	0


If lProspect
	
	If AllTrim(SUS->US_COD+SUS->US_LOJA) == AllTrim(M->UA_CLIENTE+M->UA_LOJA)
		cCliente	:= 	M->UA_CLIENTE
		cLoja		:= 	M->UA_LOJA
	Else
		DbselectArea("SUS");DbSetOrder(1);DbGoTop()
		If DbSeek(xFilial("SUS")+M->UA_CLIENTE+M->UA_LOJA, .F.)
			cCliente	:= 	SUS->US_COD
			cLoja		:= 	SUS->US_LOJA
		EndIf
	EndIf
    
	cEstCli	 :=	SUS->US_EST
	cTipoCli :=	SUS->US_TIPO
		
Else

	If AllTrim(SA1->A1_COD+SA1->A1_LOJA) == AllTrim(M->UA_CLIENTE+M->UA_LOJA)
		cEstCli	 := SA1->A1_EST
		cTipoCli :=	SA1->A1_TIPO
	Else
		DbselectArea("SA1");DbSetOrder(1);DbGoTop()
		If DbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA, .F.)
			cEstCli	 :=	SA1->A1_EST
			cTipoCli :=	SA1->A1_TIPO
		EndIf
	EndIf
	
EndIf

If AllTrim(cCodProd) == AllTrim(SB1->B1_COD)
	cOrigem  := AllTrim(SB1->B1_ORIGEM)
	cGrpTrib :=	AllTrim(SB1->B1_GRTRIB)
Else
	DbselectArea("SB1");DbSetOrder(1);DbGoTop()
	If DbSeek(xFilial("SB1")+cCodProd)
		cOrigem  := AllTrim(SB1->B1_ORIGEM)
		cGrpTrib :=	AllTrim(SB1->B1_GRTRIB)
	EndIf
EndIf
	


//здддддддддддддддддддддддддддддд©
//| TABELA DE DESCONTO DE ICMS   |
//юдддддддддддддддддддддддддддддды
DbSelectArea("SZW");DbSetOrder(1)
If (cEstCli == 'PR' .And. cFilAnt == '13' .And. cTES $ '514/724/720' .And. cTipoCli != 'F' .And.  cGrpTrib != '001' )
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	//| CLIENTE Eh DO PR E A TES Eh 514 E CLIENTE NAO EH CONSUMIDOR FINAL 		|
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	If SZW->(DbSeek(xFilial('SZW')+'PR'+'PR'))
		lChkDesc := .T.
	EndIf
	
ElseIf (cEstCli == 'GO' .And. cFilAnt == '04' .And. cTES $ '540/721/723' .And. cTipoCli != 'F' .And. cGrpTrib != '001' )
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	//| CLIENTE Eh DO GO E A TES Eh 540 E CLIENTE NAO EH CONSUMIDOR FINAL 		|
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	If SZW->(DbSeek(xFilial('SZW')+'GO'+'GO'))
		lChkDesc := .T.
	EndIf
	
EndIf


If lChkDesc
	If cOrigem $ '1/2'
		nPerDesc	:= SZW->ZW_DESCIMP		//	IMPORTADO
	Else
		nPerDesc	:= SZW->ZW_DESCONT		//	NACIONAL
	EndIf
EndIf


//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//| GRAVA EM aRegDesc % DESCONTO PARA MOSTRA NA TELA PRODUTO X IMPOSTOS 	|
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
/*
If nPerDesc > 0
	nPos := Ascan(aRegDesc,{|X| X[1] == 'Fiscal' .And. X[2] == StrZero(nLinAT, TamSx3('UB_ITEM')[1]) .And. AllTrim(X[3]) == 'ICMS' })
	If nPos == 0
		Aadd(aRegDesc, {'Fiscal', StrZero(nLinAT, TamSx3('UB_ITEM')[1]), 'ICMS', nPerDesc, '' })
	EndIf
Else
	nPos := Ascan(aRegDesc,{|X| X[1] == 'Fiscal' .And. X[2] == StrZero(nLinAT, TamSx3('UB_ITEM')[1]) .And. X[3] == 'ICMS' })
	If nPos > 0
		aRegDesc[nPos][04] := 	0
	EndIf
EndIf
*/

If nPerDesc > 0
	nPos := Ascan(aRegDesc,{|X| X[1] == 'Fiscal' .And. X[2] == GdFieldGet('UB_ITEM', nLinAT) .And. AllTrim(X[3]) == 'ICMS' })
	If nPos == 0
		Aadd(aRegDesc, {'Fiscal', GdFieldGet('UB_ITEM', nLinAT), 'ICMS', nPerDesc, '' })
	EndIf
Else
	nPos := Ascan(aRegDesc,{|X| X[1] == 'Fiscal' .And. X[2] == GdFieldGet('UB_ITEM', nLinAT) .And. X[3] == 'ICMS' })
	If nPos > 0
		aRegDesc[nPos][04] := 	0
	EndIf
EndIf


RestArea(aAreaSZW)
Return(nPerDesc)
**********************************************************************
Static Function ChkRegDesc()
**********************************************************************
Local lRetorno := .F.
DbSelectArea('ZRD');DbSetOrder(1)	//	ZRD_FILIAL + ZRD_NUMAT + ZRD_ITEMAT  + ZRD_CODRD + ZRD_ITEMRD
									//	ZRD_FILIAL + ZRD_NUMAT + ZRD_ITEMAT  + ZRD_TPBLQ

If DbSeek(xFilial('ZRD') + M->UA_NUM + GdFieldGet('UB_ITEM', nLinha), .F.)
	Do While !Eof() .And. ZRD->ZRD_NUMAT == M->UA_NUM  .And. ZRD->ZRD_ITEMAT == GdFieldGet('UB_ITEM', nLinha)

		cCodRD 		:= 	IIF(ZRD->ZRD_CODRD=='CompST', 'Comp.ST', ZRD->ZRD_CODRD)
		cItemRD		:=	ZRD->ZRD_ITEMRD
		nDesconto	:=	ZRD->ZRD_DESCRD
		nDesconto	:=	IIF(Upper(AllTrim(ZRD->ZRD_TPBLQ))=='DESC.VEND',ZRD->ZRD_DESCVE, nDesconto) 

		Aadd(aRegDesc, {AllTrim(ZRD->ZRD_TPBLQ), GdFieldGet('UB_ITEM', nLinha), cCodRD, nDesconto, cItemRD })

		lRetorno := .T.
		DbSkip()
	EndDo
EndIf

Return(lRetorno)
**********************************************************************
Static Function ExcluiRD(cPesq, nIndice)
**********************************************************************
// Aadd(aRegDesc, {'Desc.RD - Cabec', '', cCodRegra, M->UA_DESC4 })
// Aadd(aRegDesc, {'Item RD', GdFieldGet('UB_ITEM', nLinha), cCodRegra, nDesconto })
// Aadd(aRegDesc, {'Fiscal',  GdFieldGet('UB_ITEM', nLinha), 'ICMS', nPerDesc, '' })
// Aadd(aRegDesc, {'Fiscal',  GdFieldGet('UB_ITEM', nLinha), 'Comp.ST', nDesconto, '' })
Default nIndice := 01
nPos := Ascan(aRegDesc,{|X| Upper(X[nIndice]) == Upper(cPesq)  })
If nPos > 0

	aCopiaRD := {}	
	For nX := 1 To Len(aRegDesc)
		If Upper(AllTrim(aRegDesc[nX][nIndice])) != Upper(AllTrim(cPesq))
			Aadd(aCopiaRD, aRegDesc[nX])
        Else

        	If GdFieldGet('UB_ITEM', nLinha) != aRegDesc[nX][02]
				Aadd(aCopiaRD, aRegDesc[nX])        	
        	EndIf
		EndIf
		
	Next  
	
	aRegDesc := aCopiaRD

EndIf
			
Return()
*********************************************************************************************
Static Function ChkVlrImpostos(nBaseImp, nAliqImp, nValorImp, nLinha, lUpdate, cImposto)
*********************************************************************************************
Local aValorImp := 	{}
Default lUpdate	:=	.T.
Default cImposto:=	''

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//| CALCULO PARA VERIRIFCAR SE VALOR DO IMPOSTO ESTA CORRETO										|
//| OCORRE DIVERGENCIA DE VALORES, CENTAVOS, QDO O MESMO PRODUTO									|
//| INFORMADO MAIS DE UMA VEZ OU MESMO PRODUTO COM QUANTIDADES <>.									| 
//|																									|
//цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//|EX.: QUANTIDADE == 1 UN.																			|
//|																									|
//|	ITEM | PRODUTO	 |	BASEIMP    | ALIQ  |  VLR.IMP  |											|
//|	 01	 | 00000007	 |	R$ 14.58   |  12%  |  R$ 1.75  |											|
//|	 02	 | 00000007	 |	R$ 14.58   |  12%  |  R$ 1.76  |											|
//|																									|
//|	* FUNCAO VERIFICA SE (BASE * ALIQ) = VLR.IMP													|
//|																									|
//цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//|																									|
//|EX.: QUANTIDADE > 1 UN.																			|
//|																									|
//|	ITEM | PRODUTO	 |	QUANT | PRECO 	   | BASEIMP  | ALIQ  |  VLR.IMP  	|                       |
//|	 01	 | 00000007	 |	  1	  | R$ 17.3588 | R$ 14.58 |  12%  |  R$ 1.7496	|                       |
//|	 02	 | 00000007	 |	  4	  | R$ 17.3544 | R$ 58.32 |  12%  |  R$ 6.9984	|						|
//|																									|
//|	[ VALOR IMPOSTOS ITEM 01 - QUANT. 1 ]                                                           |
//| IMP   |   BASE	 | ALIQ  | VLR.PROTHEUS | VLR.4DECIMAIS                                         |
//|	ICM	  |	R$ 14.58 | 12%	 |  R$ 1.75   	| R$ 1.7496                                             |
//|	IPI	  |	R$ 13.50 | 8%	 |  R$ 1.08  	| R$ 1.0800                                             |
//|	COF	  |	R$ 13.50 | 1.65% |  R$ 0.22  	| R$ 0.2228 								            |
//|	PIS	  |	R$ 13.50 | 7.6	 |  R$ 1.03  	| R$ 1.0260 								           	|
//|	TOTAL: 	          		    R$ 3.00  	| R$ 2.9984 											|		
//|																									|
//|																									|
//|	[ VALOR IMPOSTOS ITEM 01 - QUANT. 4 ]                                                           |
//| IMP   |   BASE	 | ALIQ  | VLR.PROTHEUS | VLR.4DECIMAIS                                         |
//|	ICM	  |	R$ 58.32 | 12%	 |  R$ 7.00   	| R$ 6.9984 											|
//|	IPI	  |	R$ 54.00 | 8%	 |  R$ 4.32  	| R$ 4.3200                                             |
//цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//| COF***|	R$ 54.00 | 1.65% |  R$ 0.89  	| R$ 0.8910             								|
//цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//|	PIS	  |	R$ 54.00 | 7.6	 |  R$ 4.10  	| R$ 4.1040                                             |
//|	TOTAL: 	          		    R$ 11.99 	| R$ 11.9934 											|
//|																									|
//|																									|
//|	* FUNCAO VERIFICA SE VLR.IMP ESTA CONFORME INDEPENDENTE DA QUANT.                               |
//|	  EX.: COFINS                                                                                   |
//|                                                                                                 |
//|	  ROUND((54.00/100)*1.65,04) = R$ 0.8910 [ (BASE/100)*ALIQ ]									|
//|	  ROUND( 0.8910/ 4, 02)		 = R$ 0.22   [ 0.8910 / QUANT  ]									|
//|	  ROUND( 0.22  / 4, 02)		 = R$ 0.88	 [ 0.22   / QUANT  ]									|
//|	  VLRIMP := 0.88																				|
//|																									|
//цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//|	-> NAO CHECAR PARA ICMS RETIDO. (BASE*ALIQ) NAO Eh == VALOR IMP									|
//|	BASE  ICMS RETIDO  = VLR.PROD + FRETE + IPI + ACRESC.FIN										|
//| VALOR ICMS RETIDO = (BASE * ALIQ) - VALOR ICMS													|
//|																									|
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
/*
	nVlrImp4Dec	:=	Round((nBaseImp/100)*nAliqImp, TamSx3('UB_VRUNIT')[02])		//	DECIMAL = 04
	nVlrImp2Dec	:=	Round(nVlrImp4Dec, TamSx3('UB_VLRITEM')[02] )				//	DECIMAL = 02
	
	nVlrImpXQtd	:=	Round(nVlrImp4Dec / aCols[nLinha][nPQuant], TamSx3('UB_VLRITEM')[02])
	nReCalcImp	:= 	Round(nVlrImpXQtd * aCols[nLinha][nPQuant], TamSx3('UB_VLRITEM')[02])

	If nVlrImp2Dec != nReCalcImp .Or. nValorImp != nReCalcImp
		nValorImp := nReCalcImp
		MaFisAlt(cIT_Campo, nReCalcImp, nLinha)
	EndIf
*/

nVlrImp4Dec := Round((nBaseImp/100)*nAliqImp, TamSx3('UB_VRUNIT')[02] )	//	DECIMAL = 04
nReCalcImp 	:= Round((nBaseImp/100)*nAliqImp, TamSx3('UB_VLRITEM')[02])	//	DECIMAL = 02
If 	nValorImp != nReCalcImp .And. !(cImposto $ 'SUF\ICR')
	nValorImp := nReCalcImp
	If lUpdate
		MaFisAlt(cIT_Campo, nReCalcImp, nLinha)
		If cImposto == 'IMPST'
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
			//| IDENTIFICADO NECESSIDADE DE AJUSTE QUANDO NO CALCULO DO ICMS ST SISTEMA CALCULANDO COM DIVERGENCIA.		|
			//|  EX.: VALICM <> BASEICM * ALIQICM 																		|
			//|	 BASEICM= 8.9, ALIQICM=17, VALICM=1.52 (CORRETO=1.513) MaFisAlt CORRIGE DE 1.52 PARA 1.51				|
			//|	 DEPOIS Eh NECESSARIO RODAR MaFisReCal IT_BASESOL PARA QUE VALSOL TAMBEM ALTERE							|
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
			MaFisRecal( "IT_BASESOL",  nLinha)
		EndIf
	EndIf
EndIf

Aadd(aValorImp, nValorImp) 
Aadd(aValorImp, nVlrImp4Dec)

Return(aValorImp)
**********************************************************************
Static Function ConsXOfert()
**********************************************************************
Local nPProd 	 :=	01
Local nPQtd  	 :=	02
Local nPVlr  	 :=	03
Local nPTes  	 :=	04
Local aConsXOfer :=	{}


If Empty(aProdxImp[nPosProd][08])
	//										[01]						 [02]									[03]						[04]					[05]								[06]
	Aadd(aConsXOfer, {AllTrim(GdFieldGet('UB_PRODUTO',nLinha)), GdFieldGet('UB_QUANT',nLinha), GdFieldGet('UB_VRCACRE',nLinha), GdFieldGet('UB_TES',nLinha), GravaData(GdFieldGet('UB_DTNECLI',nLinha),.F.,8), GdFieldGet('UB_HRNECLI',nLinha) })
Else

	//		PROD|QTD| R$ |TES
	//	Ex.: XXX| 10|5.25|721
	
	// VERIFICA SE EXITE APENAS 1 ITEM NO ARRAY[08]
	If AT('\',aProdxImp[nPosProd][08]) == 0
	
		aProd08	:= 	StrTokArr(aProdxImp[nPosProd][08],"|") 
		cOpcao	:=	IIF(AllTrim(GdFieldGet('UB_PRODUTO',nLinha)) != AllTrim(aProd08[nPProd]), 'PROD_DIFERENTE','')
		cOpcao	:=	IIF(Empty(cOpcao).And.GdFieldGet('UB_TES',nLinha) != aProd08[nPTes], 'TES_DIFERENTE',cOpcao)
		cOpcao	:= 	IIF(Empty(cOpcao).And.GdFieldGet('UB_QUANT',nLinha) > Val(aProd08[nPQtd]),'QTD_MAIOR',cOpcao)

		
		If cOpcao == 'PROD_DIFERENTE' .Or. (cCampo=='UB_TES' .And. cOpcao == 'TES_DIFERENTE')
			// CONTEUDO ATUAL DO aProdxImp[nPosProd][08]
			Aadd(aConsXOfer, aProd08 )
			//	NOVO PRODUTO\TES
			Aadd(aConsXOfer, {AllTrim(GdFieldGet('UB_PRODUTO',nLinha)), GdFieldGet('UB_QUANT',nLinha), GdFieldGet('UB_VRCACRE',nLinha), GdFieldGet('UB_TES',nLinha), GravaData(GdFieldGet('UB_DTNECLI',nLinha),.F.,8), GdFieldGet('UB_HRNECLI',nLinha) })
		ElseIf cOpcao == 'QTD_MAIOR'
        	// ATUALIZA QUANTIDADE    
			aProd08[nPQtd] := GdFieldGet('UB_QUANT',nLinha)
			aProd08[nPVlr] := GdFieldGet('UB_VRCACRE',nLinha)

			Aadd(aConsXOfer, aProd08 )
		ElseIf Empty(cOpcao) 
			If GdFieldGet('UB_VRCACRE',nLinha) != Val(aProd08[nPVlr])
				aProd08[nPVlr] := GdFieldGet('UB_VRCACRE',nLinha)
				Aadd(aConsXOfer, aProd08 )
			EndIf
		EndIf
        


	Else

		// EXISTE + 1 ITEM NO ARRAY[08] (MESMO ITEM POREM TES <> OU PRODUTO <>

		//		PROD|QTD| R$ |TES| \ PROD|QTD| R$ |TES| \ PROD|QTD| R$ |TES
		//	Ex.:XXXX|10 |5.25|721| \ XXXX|05 |4.10|501| \ YYYY| 15|1,23|721


		aProd08	:= 	StrTokArr(aProdxImp[nPosProd][08],"\")
		aAux	:= 	{}
		For nX:=1 To Len(aProd08)
			Aadd(aAux, StrTokArr(aProd08[nX], '|') )
		Next
		aProd08	  := aAux
			

		nPesqProd := Ascan(aProd08,{|X| AllTrim(X[nPProd]) == AllTrim(GdFieldGet('UB_PRODUTO',nLinha)) })

		If nPesqProd > 0 

			nPProdTes	:=	Ascan(aProd08,{|X| 	AllTrim(X[nPProd]) == AllTrim(GdFieldGet('UB_PRODUTO',nLinha)) .And.;
											 	AllTrim(X[nPTes])  == AllTrim(GdFieldGet('UB_TES',nLinha))  })

			If nPProdTes > 0
				//	MESMO PRODUTO E MESMA TES
				If GdFieldGet('UB_QUANT',nLinha) > Val(aProd08[nPProdTes][nPQtd])
		        	// ATUALIZA QUANTIDADE    
		        	aProd08[nPProdTes][nPQtd] := GdFieldGet('UB_QUANT',  nLinha)
		        	aProd08[nPProdTes][nPVlr] := GdFieldGet('UB_VRCACRE',nLinha)
					aConsXOfer := aProd08
				EndIf

			ElseIf nPesqProd > 0 .And. nPProdTes == 0 
				//	MESMO PRODUTO E TES <>
				
				//	CONTEUDO ATUAL DO aProdxImp[nPosProd][08]
				aConsXOfer := aProd08
				//	NOVO PRODUTO\TES                                                
				nMaxQtd := Max(GdFieldGet('UB_QUANT',nLinha), Val(aProd08[nPesqProd][nPQtd]) )	// VERIFICA QTD MAIOR
				Aadd(aConsXOfer, {AllTrim(GdFieldGet('UB_PRODUTO',nLinha)), nMaxQtd, GdFieldGet('UB_VRCACRE',nLinha), GdFieldGet('UB_TES',nLinha), GravaData(GdFieldGet('UB_DTNECLI',nLinha),.F.,8), GdFieldGet('UB_HRNECLI',nLinha) })
            Else
				If GdFieldGet('UB_VRCACRE',nLinha) != Val(aProd08[nPProdTes][nPVlr])                
		        	aProd08[nPProdTes][nPVlr] := GdFieldGet('UB_VRCACRE',nLinha)
					aConsXOfer := aProd08            		
            	EndIf
            EndIf

		Else
			// NOVO PRODUTO
			
			// CONTEUDO ATUAL DO aProdxImp[nPosProd][08]
			aConsXOfer := aProd08
			//	NOVO PRODUTO\TES
			Aadd(aConsXOfer, {AllTrim(GdFieldGet('UB_PRODUTO',nLinha)), GdFieldGet('UB_QUANT',nLinha), GdFieldGet('UB_VRCACRE',nLinha), GdFieldGet('UB_TES',nLinha), GravaData(GdFieldGet('UB_DTNECLI',nLinha),.F.,8), GdFieldGet('UB_HRNECLI',nLinha) })
		EndIf	

	EndIf
                
EndIf



If Len(aConsXOfer) > 0

	cConteudo := ''	
	aProdxImp[nPosProd][08] :=	''
	
	For nX:=1 To Len(aConsXOfer)

        cConteudo := cConteudo+IIF(nX > 1, '\','')

        For nI := 1 To Len(aConsXOfer[nX])
			cString   := IIF(ValType(aConsXOfer[nX][nI])$'N\D', cValtoChar(aConsXOfer[nX][nI]), aConsXOfer[nX][nI])
			cConteudo += cString+'|'
		Next
	Next	

	aProdxImp[nPosProd][08] := cConteudo

EndIf		

Return()
**********************************************************************
User Function ChkMaColsToFis()
**********************************************************************
Local _nMERCADORIA	:=	1	// Valor total do mercadoria
Local _nDESCONTO	:=	2	// Valor total do desconto
Local _nACRESCIMO	:=	3	// Valor do acrescimo financeiro da condicao de pagamento
Local _nFRETE		:=	4	// Valor total do frete
Local _nDESPESA		:=	5	// Valor total da despesa
Local _nTOTAL		:=	6	// Total do pedido
Local _nSUFRAMA		:=	7	// Valor total da suframa
Local _nBASEDUP		:=	8	// Base da duplicata (Valor lМquido da condiГЦo de pagamento)
Local lTelaF6  		:=	Upper(SubStr(ProcName(2),03)) $ 'TMKCND\TMKVLDE4\TMKVCP\TMKCPG'
Local lExecuta		:=	.T.
Local lNF_SUFRAMA	:=	MaFisRet(,"NF_DESCZF") > 0

Local nCountLn	:=	IIF(Type('ParamIxb')== 'A', ParamIxb[01], Len(aProdXImp))
Local lForca	:=	IIF(Type('ParamIxb')== 'A', IIF(Len(ParamIxb)>=2, ParamIxb[02], .F.), .F.)


For nX:=1 To nCountLn

	If lTelaF6
		nLinha := Nil 
	//	lExecuta := IIF(aValores[01] == MaFisRet(, "NF_VALMERC"), .F., .T.) 	//	M->UA_VALMERC
	Else
	
	 	// SE NENHUM ITEM FOI ATUALIZADO VIA MaColsToFis ENTAO RODA PARA TODOS UMA UNICA VEZ
	 	nLinha := IIF(lForca, Nil, IIF(Ascan(aProdXImp, {|X| X[25] == .T.}) == 0, Nil, nX))
	
	
		If nLinha == Nil 
			aEval(aProdxImp, {|aProdxImp|aProdxImp[25] := .T.})
		Else
	
			// SE ITEM JA RODOU O MaColsToFis NAO PRECISA PROCESSAR NOVAMENTE        
			If aProdXImp[nLinha][25] == .T.
		    	Loop
			Else
		    	//	GRAVA FLAG INFO QUE RODOU MaColsToFis
		    	aProdXImp[nLinha][25] := .T.
			EndIf
		
		EndIf
  
    EndIf
	
	
	// If lTelaF6 .And. nLinha == Nil
	//	lExecuta := IIF(aValores[01] == MaFisRet(, "NF_VALMERC"), .F., .T.) 	//	M->UA_VALMERC
	// EndIf

	
	If lExecuta
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		//| ROTINA CARREGAMENTO DA FUNCAO FISCAL COM BASE NO ACOLS E AHEADER	|
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		lReCalImp	:= 	.T. //IIF(MaFisRet(, "NF_DESCZF")>0, .F., .T.)
		lReCalDel 	:= 	IIF(nLinha==Nil, .T., IIF(aCols[nLinha][Len(aHeader)+1], .F., .T.))
	    lVisual 	:= 	Nil
		lSoItem		:=	IIF(nLinha==Nil, Nil, .T.)	 // Nil
		MaColsToFis(aHeader,aCols,nLinha,"TK271",lRecalImp,lVisual,lRecalDel,lSoItem)	

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		//?MaColsToFis(aHeader,aCols,nItem,cProg,lRecalc,lVisual,lDel,lSoItem)           ?
		//|	DEFAULT lRecalc := .F.                                                        |
		//|	DEFAULT lVisual	:= .F.                                                        |
		//|	DEFAULT lDel    := .F.	//Indica que a linha deletada sera considerada		  |
		//|	DEFAULT lSoItem	:= .F.														  |
		//цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		//? ExpA1: Variavel com a estrutura do aHeader                                   ?
		//? ExpA2: Variavel com a estrutura do aCols                                     ?
		//? ExpN3: Item a ser carregado [ Nil = Todos ]             (opc)                ?
		//? ExpC4: Nome do programa                                 (opc)                ?
		//? ExpL5: Indica se o recalculo dos impostos deve ser feito(opc) - DEFAUL .F.   ?
		//? ExpL6: Indica se o recalculo dos impostos deve ser feito(opc) - DEFAUL .F.   ?
		//? ExpL7: Indica se o recalculo vai considerar as linhs apagadas - DEFAUL .F.   ?
		//? ExpL7 == .T. Executa MaFisDel()                                              ?
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		//? MaFisEndLoad(nY,Iif(lVisual,3,If(lSoItem,2,Nil)))                                        ?
		//цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
		//? 1-(Default) Executa o recalculo de todos os itens para efetuar a atualizacao do cabecalho?
		//? 2-Executa a soma do item para atualizacao do cabecalho.                                  ?
		//? 3-Nao executa a atualizacao do cabecalho.                                                ?
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
	
    EndIf


	If nLinha == Nil
		Exit
	EndIf

Next

IIF(!lNF_SUFRAMA, Tk273Refresh(.T.),)

Return()
/*
Function MaColsToFis(aHeader,aCols,nItem,cProg,lRecalc,lVisual,lDel,lSoItem)
DEFAULT lRecalc := .F.
DEFAULT lVisual	:= .F.
DEFAULT lDel    := .F.	//Indica que a linha deletada do acols nao sera considerada
DEFAULT lSoItem	:= .F.

MaFisEndLoad(nY,Iif(lVisual,3,If(lSoItem,2,Nil)))
	
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ?
╠╠ЁFuncao    ЁMaFisEndLoad?Autor ?Edson Maricate      ?Data ?9.12.1999Ё╠?
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠?
╠╠ЁDescri┤┘o ЁFinaliza a carga dos itens Fiscais                          Ё╠?
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠?
╠╠ЁParametrosЁExpN1 : Item                                                Ё╠?
╠╠?         ЁExpN2 : Tipo de atualizacao do Item :                       Ё╠?
╠╠?         ?       1-(default) Executa o recalculo de todos os itens   Ё╠?
╠╠?         ?                   para efetuar a atualizacao do cabecalho Ё╠?
╠╠?         ?       2-Executa a soma do item para atualizacao do cabeca Ё╠?
╠╠?         ?                   lho.                                    Ё╠?
╠╠?         ?       3-Nao executa a atualizacao do cabecalho.           Ё╠?
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ?
Function MaFisEndLoad(nItem,nTipo)
DEFAULT nTipo := 1
*/
/*
*************************************************************************
Function Tk273Refresh(lForca)
*************************************************************************
Local aArea		:= GetArea()	   				// Salva a area atual
Local lMV_TMKFIS:= IIf(lTk271Auto, .T., GetNewPar("MV_TMKFIS",.T.))	// (N? divulgar) Parametro que indica que a atualiza?o da MATXFIS ?feita de maneira on-line, no off-line a MATXFIS s??atualizada quando se entra na condi?o de pagamento.
Local nX 		:=0     
Local nPQtd 	:= aPosicoes[4][2]		   		// Posicao da Quantidade
Local nPVrUnit  := aPosicoes[5][2]
Local nPVlrItem := aPosicoes[6][2]				// Posicao do Valor do item 

Default lForca	:= .F.

If !Empty(M->UA_CLIENTE) .And. (lMV_TMKFIS .Or. lForca)
	aValores[MERCADORIA]	:= MaFisRet(, "NF_VALMERC")
	aValores[SUFRAMA]		:= MaFisRet(, "NF_DESCZF")
	aValores[TOTAL]			:= MaFisRet(, "NF_TOTAL") 
	aValores[BASEDUP]		:= MaFisRet(, "NF_BASEDUP")
	//Para nao aplicar o suframa ao item, que sera aplicado apenas no total.
	If MaFisRet(, "NF_DESCZF") >0 
		For nX:=1 To len(aCols)
			aCols[nX][nPVlrItem] := A410Arred(aCols[nX][nPQtd]*aCols[nX][nPVrUnit],"UB_VLRITEM")
		Next
	EndIf
EndIf

RestArea(aArea)
Return(.T.)
*/
*************************************************************************
Static Function SqlChkMoeda()
*************************************************************************
Local aArea		:= 	GetArea()
Local cCpoSM2 	:= 	''
Local cRetSql 	:=	''
/*
cSql +="   		WHEN '1'  THEN 1					"+ENTER
cSql +="   		WHEN '2'  THEN NVL(SM2.M2_MOEDA2,0)	"+ENTER
cSql +="   		WHEN '3'  THEN NVL(SM2.M2_MOEDA3,0)	"+ENTER
cSql +="   		WHEN '4'  THEN NVL(SM2.M2_MOEDA4,0)	"+ENTER
cSql +="   		WHEN '5'  THEN NVL(SM2.M2_MOEDA5,0)	"+ENTER
cSql +="   		WHEN '6'  THEN NVL(SM2.M2_MOEDA6,0)	"+ENTER
cSql +="   		WHEN '7'  THEN NVL(SM2.M2_MOEDA7,0)	"+ENTER
cSql +="   		WHEN '8'  THEN NVL(SM2.M2_MOEDA8,0)	"+ENTER
cSql +="   		WHEN '9'  THEN NVL(SM2.M2_MOEDA9,0)	"+ENTER
cSql +="   		WHEN '10' THEN NVL(SM2.M2_MOEDA10,0)"+ENTER
cSql +="   		WHEN '11' THEN NVL(SM2.M2_MOEDA11,0)"+ENTER
cSql +="   		WHEN '12' THEN NVL(SM2.M2_MOEDA12,0)"+ENTER
*/

DbSelectArea('SM2')
For nM := 1 To FCount()
	cCpoSM2 := AllTrim(FieldName(nM))
	If Left(cCpoSM2, 08) == 'M2_MOEDA'
		cMoeda := SubStr(cCpoSM2, 09)
		If cMoeda == '1'
			cRetSql += "   		WHEN '1'  THEN 1					"+ENTER
		Else
			cRetSql += "   		WHEN '"+cMoeda+"'  THEN NVL(SM2.M2_MOEDA"+cMoeda+",0)	"+ENTER
		EndIf
	EndIf
Next

RestArea(aArea)
Return(cRetSql)