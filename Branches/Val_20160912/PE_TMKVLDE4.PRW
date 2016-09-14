#DEFINE  ENTER CHR(13)+CHR(10)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³U_TMKVLDE4  ³ Autor ³Expedito Mendonca Jr ³ Data ³ 18/12/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Ponto de entrada chamado na tela de atendimento do Call     ³±±
±±³          ³Center, no botao "Condicao de Pagamento", com o objetivo de ³±±
±±³          ³calcular e preencher o campo de Despesas do atendimento,    ³±±
±±³          ³com o conteudo das despesas de cobranca.                    ³±±
*****************************************************************************
* Edivaldo Gonçalves Cordeiro                                               *
* Criada em : 13/12/2005                                                    *
*****************************************************************************
* De Acordo com a Condição de Pagamento, a Rotina passa a Setar a Flag      *
* Credita ICMS='S', baseado no Conteúdo da Flag E4_CREDICM                  *
*                                                                           *
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ESPECIFICO PARA O CLIENTE IMDEPA						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
********************************************************************
User Function TMKVLDE4(nOpc,cCodPagto,oCodPagto)
********************************************************************
Local aArea			:= 	Getarea()
Local aAreaSA1		:= 	SA1->(Getarea())
Local aAreaSE4		:= 	SE4->(Getarea())
Local _MERCADORIA	:=	1	// Valor total do mercadoria
Local _DESCONTO		:=	2	// Valor total do desconto
Local _ACRESCIMO	:=	3	// Valor do acrescimo financeiro da condicao de pagamento
Local _FRETE		:=	4	// Valor total do frete
Local _DESPESA		:=	5	// Valor total da despesa
Local _TOTAL		:=	6	// Total do pedido
Local _SUFRAMA		:=	7	// Valor total da suframa
Local _BASEDUP		:=	8	// Base da duplicata (Valor l?uido da condi?o de pagamento)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| VERIFICA\ATUALIZA SE COD.PAGTO FOI ALTERADA	 (cCodPagto != M->UA_CONDPG)	|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If Ascan(aProdxImp, {|X| X[13] != cCodPagto })  > 0 
	ExecBlock('IncDesp',.F.,.F., {cCodPagto})				// 	ATUALIZA CAMPO DESPESAS MESMO R$ DESPESA = 

	If MaFisRet(, "NF_FRETE") != aValores[_FRETE]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| FABIANO PEREIRA - 14/09/2016 - CHAMADO: 9309								|
		//|	IDENTIFICA OCORRENCIA DE ERRO NA SOMA DAS PARCELAS							|
		//| VALOR DA PARCELA ESTA DIFERENTE DO VALOR TOTAL								|
		//| Tk273AtuNFs() ATUALIZA NF_DESCONTO, NF_FRETE, NF_DESPESA COM aValores[x] 	|
		//| e RODA MaFisToCols 															|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Tk273AtuNFs()	//	ATUALIZA NF_DESCONTO, NF_FRETE, NF_DESPESA COM aValores[x] e RODA MaFisToCols 
	EndIf


	Tk273FRefresh()											//	ATUALIZA OBJETOS DO RODAPE
	Tk273Refresh(.T.)										//	ATUALIZA aValores
	oGetTLV:oBrowse:Refresh()
//EndIf	                                         

/////JULIO JACOVENKO, em 17/05/2016
/////marca que ja abriu a tela de condicao pagamento
///isto é necessario em virtude de ter controle
///para quando teclar F4 para mostrar o calculo do IMC
__lJaBotPag2 := .T.                    

/////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////


Restarea(aAreaSE4)
Restarea(aAreaSA1)
Restarea(aArea)
Return(.T.)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³U_ATUDESP   ³ Autor ³Expedito Mendonca Jr ³ Data ³ 18/12/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao dos campos especificos UA_DESPES2, UA_ENDOSSO e  ³±±
±±³          ³ UA_REEMBOLSO utilizado para preencher automaticamente o    ³±±
±±³          ³ campo "Despesas" do rodape da Tela da Verdade.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ESPECIFICO PARA O CLIENTE IMDEPA						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function AtuDesp()

__lJaBotCPag  := .F.
__lJaBotPag2 := .F.
//u_TMKVLDE4(,M->UA_CONDPG)
Tk273RodImposto("NF_DESPESA",aValores[5]+aValores[3])

Return .T.