#include "rwmake.ch"
#include "vkey.ch"


#DEFINE  APOS {  15,  1, 70, 315 }
#DEFINE MERCADORIA		1	// Valor total do mercadoria
#DEFINE DESCONTO			2	// Valor total do desconto
#DEFINE ACRESCIMO		3	// Valor do acrescimo financeiro da condicao de pagamento
#DEFINE FRETE   			4	// Valor total do Frete
#DEFINE DESPESA 			5	// Valor total da despesa
#DEFINE TOTAL 			6	// Total do Pedido
#DEFINE X_DESCNEG		30  // Dias para vencimento dos acrescimos/descontos negociados

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271HTlv ³ Autor ³ Fabio Rogerio Pereira ³ Data ³ 03/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Hist¢rico das ligacoes atendidas pelo Televendas           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso   	 ³ SIGATMK      			 						 	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³03/12/01³609   ³- O historico nao esta carregando a descri- ³±±
±±³          ³        ³      ³cao do produto corretamente.                ³±±
±±³          ³        ³      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TMKVBI()

Local oMonoAs	:= TFont():New( "Mono AS", 6, 15 )
Local aFirst[1][Len(aHeader)+1]
Local cCodPed	:= ""
Local oDlgHist
Local nHist		:= 0
Local oGetHist, oObsMemo, cObsMemo, oCancMemo, cCancMemo
Local aColAnt  := AClone(aCols)
Local bSavKey
Local nAnt := n
Local cperg:= 'TMKH02'
Private oLbx, aLigacoes := {}
Private oAberto     := LoadBitmap( GetResources(),"BR_VERDE"),;
        oEncerrado  := LoadBitmap( GetResources(),"BR_VERMELHO"),;
        oLiberado   := LoadBitmap( GetResources(),"BR_AMARELO"),;
        oOrcamento  := LoadBitmap( GetResources(),"BR_AZUL")
Private lPodeSair := .F.
Public cTipoAte := "2"






// Se o usuario ja digitou a quantidade e consultou o estoque, ele deve gravar o atendimento que esta posicionado
If __Podesair != "S"
	IW_MSGBOX(Oemtoansi("Opção não disponível. Realize a gravação do atendimento !"),Oemtoansi('Atenção'),'STOP')
	Return
Endif



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Flag que indica que o atendimento atual da tela é uma cópia³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//__COPIATT := .T.

// Numero do atendimento
cNUM_ANT       := ""

// Validacao da tela da verdade
If nFolder == 1 // TeleMarketing ou Televendas
  	If cTipoAte == "1" .OR. cTipoAte == "4" //Telemarketing ou Ambos
		MSGBOX("Opcao valida somente para tela de TeleVendas",'Atenção','ALERT')
 	   	Return
  	ElseIf (cTipoAte == "2") //Televendas
		If Inclui
			//guarda numero do atendimento
			cNum_Ant := M->UA_NUM

            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  		    //³Realiza as validacoes necessarias antes de executar o historico³
  		    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            cCli_Vld := M->UA_CLIENTE
            cLj_Vld  := M->UA_LOJA
            DbSelectarea( "SUA" )
            DbSetorder(7)
            If !DbSeek(xFilial("SUA") + cCli_Vld + cLj_Vld)
 			     Help(" ",1,"SEMDADOS" )
  			     Return(.F.)
  		    Endif
        Else
            Alert("Opção não disponível, clique em 'Limpa o Atendimento' para iniciar um novo atendimento")
 	   		Return
        Endif
  	ElseIf (cTipoAte == "3") //TeleCobranca
	 	MSGBOX("Opcao valida somente para tela de TeleVendas",'Atenção','ALERT')
 	   	Return
   	Endif
ElseIf nFolder == 2 // Televendas
	If Inclui
    	//guarda numero do atendimento
    	cNum_Ant := M->UA_NUM

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  		//³Realiza as validacoes necessarias antes de executar o historico³
  		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        cCli_Vld := M->UA_CLIENTE
        cLj_Vld  := M->UA_LOJA
        DbSelectarea( "SUA" )
        DbSetorder(7)
        If !DbSeek(xFilial("SUA") + cCli_Vld + cLj_Vld)
  			Help(" ",1,"SEMDADOS" )
  			Return(.F.)
  		Endif
    Else
    	Alert("Opção não disponível, clique em 'Limpa o Atendimento' para iniciar um novo atendimento")
        Return
    Endif
ElseIf nFolder == 3 // Telecobranca
	MSGBOX("Opcao valida somente para tela de TeleVendas",'Atenção','ALERT')
	Return
Endif

If PERGUNTE(cperg,.T.)
// Desabilita a tecla F5
bSavKey    := SetKey( VK_F5, Nil )

CursorWait()
aCols := aClone(aFirst)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona todas a liga‡oes desse cliente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT /*+rule*/ SUA.*, SA3.A3_NOME, SU5.U5_CONTAT, UO_DESC, E4_DESCRI, A4_NOME "
cQuery += "FROM " + RetSqlName("SUA") + " SUA, " + RetSqlName("SA3") + " SA3, " + RetSqlName("SU5") + " SU5, " + RetSqlName("SUO") + " SUO, " + RetSqlName("SE4") + " SE4, " + RetSqlName("SA4") + " SA4 "
cQuery += "WHERE "
cQuery += "SUA.UA_FILIAL='"  + xFilial("SUA") + "' AND "
cQuery += "SUA.UA_CLIENTE='" + M->UA_CLIENTE  + "' AND "
cQuery += "SUA.UA_LOJA='"    + M->UA_LOJA     + "' AND "
cQuery += "SUA.UA_PROSPEC='" + IIF(lProspect,'T','F') + "' AND "
cQuery += "SUA.UA_EMISSAO >='"+ Dtos(MV_PAR01) + "' AND "
cQuery += "SUA.UA_EMISSAO <='"+ Dtos(MV_PAR02) + "' AND "
cQuery += "SUA.UA_OPERADO >='"+ MV_PAR03 + "' AND "
cQuery += "SUA.UA_OPERADO <='"+ MV_PAR04 + "'"

****************************************************************
//Inserido por Edivaldo Gonçalves Cordeiro em 29/05/2006       //
//Filtra o Tipo de Operação (Faturamento,Orçamento,Atendimento //
//No Evento Click do Botão  Cópia de Atendimento               //
****************************************************************
Do Case
	Case MV_PAR05=2
		cQuery += " AND SUA.UA_OPER='1'  "
	Case MV_PAR05=3
		cQuery += " AND SUA.UA_OPER='2'  "
	Case MV_PAR05=4
		cQuery += " AND SUA.UA_OPER='3'  "
EndCase


//Filtra Marketing (1=ATIVO  2=RECEPTIVO  3=FAX  4=REPRESENTANTE)
Do Case
	Case MV_PAR06=2
		cQuery += " AND SUA.UA_TMK='2'  "
	Case MV_PAR06=3
		cQuery += " AND SUA.UA_TMK='1'  "
	Case MV_PAR06=4
		cQuery += " AND SUA.UA_TMK='3'  "
	Case MV_PAR06=5
		cQuery += " AND SUA.UA_TMK='4'  "
EndCase

cQuery += " AND SA3.A3_FILIAL (+) = '"+ xFilial("SA3")+"' AND "
cQuery += "SA3.A3_COD (+) = SUA.UA_VEND AND "

cQuery += "SU5.U5_FILIAL (+)  = '"+ xFilial("SU5")+"' AND "
cQuery += "SU5.U5_CODCONT (+) = SUA.UA_CODCONT AND "

cQuery += "SUO.UO_FILIAL (+)  = '"+ xFilial("SUO")+"' AND "
cQuery += "SUO.UO_CODCAMP (+) = SUA.UA_CODCAMP AND "

cQuery += "SE4.E4_FILIAL (+)  = '"+ xFilial("SE4")+"' AND "
cQuery += "SE4.E4_CODIGO (+) = SUA.UA_CONDPG AND "

cQuery += "SA4.A4_FILIAL (+)  = '"+ xFilial("SA4")+"' AND "
cQuery += "SA4.A4_COD (+) = SUA.UA_TRANSP AND "

cQuery += "SUA.D_E_L_E_T_<>'*' AND "
cQuery += "SA3.D_E_L_E_T_ (+) <>'*' AND "
cQuery += "SU5.D_E_L_E_T_ (+) <>'*' AND "
cQuery += "SUO.D_E_L_E_T_ (+) <>'*' AND "
cQuery += "SE4.D_E_L_E_T_ (+) <>'*' AND "
cQuery += "SA4.D_E_L_E_T_ (+) <>'*' "
cQuery += " ORDER BY " + SqlOrder(IndexKey())

//@ 116,090 To 416,707 Dialog oDlgMemo Title 'SQL - COPIA ATENDIMENTO)'
//@ 055,005 Get cQuery   Size 250,080  MEMO Object oMemo
//Activate Dialog oDlgMemo


cQuery := ChangeQuery(cQuery)

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'TMK',.T.,.T.)
TCSetField( 'TMK', 'UA_EMISSAO'  , 'D',8 , 0 )
TCSetField( 'TMK', 'UA_VLRLIQ'   , 'N',12, 2 )
TCSetField( 'TMK', 'UA_EMISNF'   , 'D',8 , 0 )



DbSelectArea("TMK")
dbgotop()
While (!Eof())

	AAdd(aLigacoes, {	bTK271OrcPed(TMK->UA_DOC,TMK->UA_OPER,TMK->UA_NUMSC5),;	// 01 - Status
			TMK->UA_NUM,;													// 02 - Atendimento
			DTOC(TMK->UA_EMISSAO),;											// 03 - Data
			TMK->A3_NOME,;													// 04 - Vendedor
			OemToAnsi(IIF(TMK->UA_OPER=="1","Faturamento","Or‡amento  ")),;	// 05 - Operacao
			TMK->U5_CONTAT,;												// 06 - Contato
			TMK->UA_NUMSC5,;												// 07 - Pedido
			bTkStatus(TMK->UA_STATUS,TMK->UA_OPER),;						// 08 - Status
			Transform(TMK->UA_VLRLIQ,"@E 999,999,999.99"),;					// 09 - Valor
			TMK->UO_DESC,;													// 10 - Campanha
			TMK->UA_DOC+"/"+TMK->UA_SERIE,;									// 11 - NF/SERIE
			DTOC(TMK->UA_EMISNF),;											// 12 - Emissao
			TMK->E4_DESCRI,;												// 13 - Condicao de Pagto
			TMK->A4_NOME,;													// 14 - Transportadora
			TMK->UA_ENDENT,;												// 15 - Endereco Entrega
			TMK->UA_MUNE,;													// 16 - Cidade Entrega
			TMK->UA_CEPE,;				 									// 17 - Cep Entrega
			TMK->UA_CODOBS,;                                           		// 18 - Codigo Observacao
			TMK->UA_CODCANC} )                                         		// 19 - Codigo do Cancelamento
	DbSkip()
Enddo
DbCloseArea()

// Se nao houver atendimentos para este cliente, retorna a tela
If Len(aLigacoes) <= 0
	Help(" ",1,"SEMDADOS" )
	aCols	:= aClone(aColAnt)
	n		:= nAnt
	CursorArrow()
	Return(.F.)
 Endif




// Abre a janela com os atendimentos do cliente
DEFINE MSDIALOG oDlgfHist FROM 1,003 TO 38,103 Title OemToAnsi("Historico")

	@ 001,002 To 228,395 Title OemtoAnsi("Ultimas Ligacoes")  oBject oDlgYHist

	@  08,05 LISTBOX oLbx FIELDS ;
		HEADER ;
			OemToAnsi(""),;
			"Or‡amento",; //"Or‡amento"
			"Data",; //"Data"
			"Vendedor",; //"Vendedor"
			"Opera‡„o",; //"Opera‡„o"
			"Contato",; //"Contato"
			"Pedido",; //"Pedido"
			"Status",; //"Status"
			"Valor",; //"Valor"
			"Campanha",; //"Campanha"
			"Nota Fiscal",; //"Nota Fiscal"
			"Emiss„o NF",; //"Emiss„o NF"
			"Condi‡„o de Pagto",; //"Condi‡„o de Pagto"
			"Transportadora",; //"Transportadora"
			"Endere‡o Entrega",; //"Endere‡o Entrega"
			"Cidade",; //"Cidade"
			"CEP" ; //"CEP"
	SIZE 385,120 OF oDlgHist PIXEL;

	oLbx:SetArray(aLigacoes)
	oLbx:bLine:={||{aLigacoes[oLbx:nAt,1],;
	aLigacoes[oLbx:nAt,2],;
	aLigacoes[oLbx:nAt,3],;
	aLigacoes[oLbx:nAt,4],;
	aLigacoes[oLbx:nAt,5],;
	aLigacoes[oLbx:nAt,6],;
	aLigacoes[oLbx:nAt,7],;
	aLigacoes[oLbx:nAt,8],;
	aLigacoes[oLbx:nAt,9],;
	aLigacoes[oLbx:nAt,10],;
	aLigacoes[oLbx:nAt,11],;
	aLigacoes[oLbx:nAt,12],;
	aLigacoes[oLbx:nAt,13],;
	aLigacoes[oLbx:nAt,14],;
	aLigacoes[oLbx:nAt,15],;
	aLigacoes[oLbx:nAt,16],;
	aLigacoes[oLbx:nAt,17],;
	aLigacoes[oLbx:nAt,18],;
	aLigacoes[oLbx:nAt,19] } }

	// carrega os itens a cada troca de linha
	oLbx:bChange := {|| cCodPed:= aLigacoes[oLbx:nAt,2],;
					   bTkCargaItem(@cObsMemo,@cCancMemo,oObsMemo,oCancMemo,oGetHist,aLigacoes[oLbx:nAt,2],aLigacoes[oLbx:nAt,18],aLigacoes[oLbx:nAt,19] )}

	oLbx:Refresh()
	oLbx:SetFocus(.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pego o codigo do atendimento e carrega o acols com os itens deste atendimento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCodPed:= aLigacoes[oLbx:nAt,2]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o acols com os itens da ligacao selecionada.			   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TkMontaItens("SUB",cCodPed,"V")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Modificado o valor da variável N para 1 para que não seja tomado³
	//³como parâmetro a posição do acols da tela de atendimento        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	N := 1
	oGetHist:= MSGetDados():New(135,5,225,390,2,"AlwaysTrue","AlwaysTrue","",.T.,,,.F.,)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Observa‡„o da liga‡„o										   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 232,002 TO 270,115 Title OemToAnsi("Observa‡„o da liga‡„o") OBJECT oDlgSHist   //OF oDlgHist PIXEL  // //"Observa‡„o da liga‡„o"
	@ 240,05 GET cObsMemo oBJECT oObsMemo MEMO SIZE 105,25 							// when .f.// SIZE 105,35 // when .f.
	oObsMemo:oFont := oMonoAs
	oObsMemo:bRClicked := {|| AllwaysTrue() }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Motivo do Cancelamento se for um or‡amento cancelado  		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 232,140 TO 270,245 Title OemToAnsi("Motivo do Cancelamento") OBJECT oCancMemo//OF oCancMemo PIXEL  // //"Motivo do Cancelamento"
	@ 240,145 GET cCancMemo oBJECT oCancMemo MEMO SIZE 090,25          //oCancMemo VAR cCancMemo OF oCancMemo MEMO SIZE 118,35 PIXEL READONLY
	oCancMemo:oFont := oMonoAs
	oCancMemo:bRClicked := {|| AllwaysTrue() }

	// Botao "Ok"
	DEFINE SBUTTON FROM 255,285 TYPE 1 ID 301 ACTION (aCols:=aClone(aColAnt),;
		BTk271NumTlv(cCodPed),lPodeSair := .T.,oDlgfHist:End()) ENABLE OF oDlgfHist

	// Botao "Cancela"
	DEFINE SBUTTON FROM 255,330 TYPE 2 ID 302 ACTION (aCols:=aClone(aColAnt),lPodeSair := .T.,oDlgfHist:End()) ENABLE OF oDlgFHist

ACTIVATE MSDIALOG oDlgfHist CENTER ON INIT CursorArrow() VALID lPodeSair

/* comentado proj f11
// Altera dados do cabecalho do atendimento
M->UA_NUM     := cNUM_ANT
*/

//area dos itens do orcamento
DbSelectArea('SUB')
DbSetOrder(1)

// Libera a delecao para itens do atendimento original mas nao permite a delecao para itens que forem acrescentados
//__nLibDel := Len(aCols)
// ALTERADO PROJETO F11, exige a redigitação de todas as quantidades
__nLibDel := 0

// Volta a habilitar a tecla F5
SetKey( VK_F5, bSavKey )

// Retorna a variavel n ao seu valor original
n := nAnt
Endif
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡„o    ³Tk271OrcPed³ Autor ³Luis Marcelo Kotaki	 ³ Data ³03/12/01  ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡„o ³Verifica quais os pedidos estao liberados e com NF gerada    ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso	     ³SIGATMK                                     	 	      	   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function BTk271OrcPed(cNF,cOper,cNumSC5)
Local oRet
If cOper == "1" //Faturamento
	Do case
		case Empty(cNF) //Aberto
			oRet := oAberto
			If !Empty(cNumSC5)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifico se esse pedido foi liberado pelo SIGAFAT³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SC5->(DbSetOrder(1))
				If SC5->(DbSeek(xFilial("SC5")+cNumSC5))
					If !Empty(SC5->C5_NOTA)
						oRet := oLiberado
					Endif
				Endif
			Endif
		case !Empty(cNF) //Encerrado (NF EMITIDA)
			oRet := oEncerrado
	Endcase
Else //Or‡amento
	oRet := oOrcamento
Endif
Return(oRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TkStatus   ³ Autor ³Luis Marcelo Kotaki	 ³ Data ³21/07/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Busca o status do pedido selecionado                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso	     ³SIGATMK						          			           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function BTkStatus(cCampo,cOper)
Local cDesc := " "
Do case
	case AllTrim(cCampo) == "NF." .AND. AllTrim(cOper) == "1"
		cDesc := OemToAnsi("NF.Emitida") //
	case AllTrim(cCampo) == "SUP" .AND. AllTrim(cOper) == "1"
		cDesc := OemToAnsi("Ped. Bloq.") //
	case AllTrim(cCampo) == "CAN"
		cDesc := OemToAnsi("Cancelado ") //
	case AllTrim(cCampo) == "LIB"
		cDesc := OemToAnsi("Liberado  ") //
	other
		cDesc := OemToAnsi("Or‡amento") //
Endcase
Return(cDesc)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkCargaItem ³ Autor ³ Luis Marcelo Kotaki	 ³ Data ³ 15/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega os items gravados em cada atendimento selecionado    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso   	 ³ SIGATMK      			 								   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function bTkCargaItem(cObsMemo,cCancMemo,oObsMemo,oCancMemo,oGetHist,cCodPed,cCodObs,cCodCan)
Local aFirst[1][Len(aHeader)+1]

aCols := aClone(aFirst)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o acols com os itens da ligacao selecionada.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TkMontaItens("SUB",cCodPed,"V")

oGetHist:oBrowse:Refresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrego a observa‡„o do or‡amento e o motivo do cancelam. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cObsMemo := MSMM(cCodObs,TamSx3("UA_OBS")[1])
oObsMemo:Refresh()
cCancMemo:= MSMM(cCodCan,TamSx3("UA_OBSCANC")[1])
oCancMemo:Refresh()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271NumTlv ³ Autor ³Fabio Rogerio Pereira³ Data ³ 03/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega as informacoes do numero do atendimento digitado    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³SIGATMK - Televendas                                        ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function BTk271NumTlv(cNumTlv)
Local cNumAux := "", cTipo   := "", cCliente:= "", cLoja   := ""
Local nAnt, nPrcTabAtu
Private lInclui, lDesNegVencido,lOrcVencido := .F.

CursorWait()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se encontrar o atendimento informado carrega na tela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectarea("SUA")
DbSetorder(1)
If DbSeek(xFilial("SUA")+cNumTlv)

	// Verifica se o atendimento foi gerado pela migracao
	If SUA->UA_MIG == "S"
		IW_MSGBOX(Oemtoansi("Este atendimento não pode ser copiado pois não foi incluído via Advanced Protheus."),Oemtoansi('Atenção'),'ALERT')
		Return(.F.)
	Endif

	lInclui   := .F.
	lProspect := SUA->UA_PROSPEC
	cCliente  := SUA->UA_CLIENTE
	cLoja     := SUA->UA_LOJA

	// Verifica se o atendimento eh de prospect ou cliente
	If lProspect
		cTipo := Posicione("SUS",1,xFilial("SUS") + cCliente + cLoja,"US_TIPO")
	Else
		cTipo := Posicione("SA1",1,xFilial("SA1") + cCliente + cLoja,"A1_TIPO")
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa os dados do cliente na FUNCAO FISCAL  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisIni(cCliente,cLoja,"C","N",cTipo)

	Do Case
		Case UA_STATUS == "NF."
			IW_MSGBOX(Oemtoansi("Atenção, a nota fiscal já foi emitida para o atendimento selecionado. Este atendimento não será considerado como alteração, mas sim como um atendimento novo!"),Oemtoansi('Atenção'),'INFO')
		Case UA_STATUS == "LIB"
//			Help(" ",1,"PED.LIB")
		Case UA_STATUS == "SUP"
	EndCase

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza a enchoice de Telemarketing.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("SUA")
	While (!SX3->( Eof()) .AND. SX3->X3_ARQUIVO == "SUA")
		If X3USO(SX3->X3_USADO)
			cCampo := ALLTRIM(SX3->X3_CAMPO)
			If cCampo != "UA_OPERADO" .and. cCampo != "UA_DESCOPE"
				If (X3_CONTEXT # "V")
					M->&(cCampo) := SUA->&(cCampo)
				ElseIf (X3_CONTEXT == "V")
					M->&(cCampo) :=  CriaVar(cCampo)
				EndIf
			Endif
		EndIf
		DbSkip()
	End

	// Campos virtuais
	M->UA_DESCCLI := IIF(lProspect,SUS->US_NOME,SA1->A1_NOME)
	M->UA_DESCVEN := aLigacoes[oLbx:nAt,4]
	M->UA_DESCMID := Posicione("SUH",1,xFilial("SUH") + M->UA_MIDIA, "UH_DESC")
	M->UA_DESCCAM := aLigacoes[oLbx:nAt,10]
	M->UA_DESCLIG := Posicione("SU9",2,xFilial("SU9") + M->UA_CODLIG,"U9_DESC")
	M->UA_OBSCLI  := IIF(SUA->UA_PROSPEC,"",POSICIONE("SA1",1,XFILIAL("SA1")+SUA->UA_CLIENTE+SUA->UA_LOJA,"A1_OBSVEND"))
	M->UA_VENDINT := SF4->(U_PesqVend(M->UA_CLIENTE,M->UA_LOJA)) //Inserido por Edivaldo G. Cordeiro em 20/07/06


	// Atendimento original
	If SUA->UA_STATUS == "NF."
		M->UA_NUMORIG := Space(Len(SUA->UA_NUM))
	Else
		M->UA_NUMORIG := SUA->UA_NUM
	Endif

/* comentado proj f11
	// Nova data de emissao
	M->UA_EMISSAO := dDATABASE
*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configura‡ao da GetDados - Folder 01			     ³
	//³ *** Televendas                          			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	bTK271Config("SUB","UB_NUM",NIL,cNumTlv,NIL,)

	aHeader  := {}
	aCols    := {}
	aHeader  := aClone(aSvFolder[2][1])
	aCols    := aClone(aSvFolder[2][2])
	n		 := aSvFolder[2][3]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza dados especificos do aCols  			     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nAcreCond := 1+(Posicione("SE4",1,xFilial("SE4")+M->UA_CONDPG,"E4_ACRSFIN")/100)
	nP_Prod   := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_PRODUTO"} )
	nP_Email  := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_EMAIL"} )
	nP_DATA   := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_DTNECLI"} )
	nP_HORA   := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_HRNECLI"} )
	nP_PRCV   := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VRUNIT"} )
	nP_VLIT   := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VLRITEM"} ) // VALOR TOTAL
	nP_PRAC   := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VRCACRE"} )
	nP_PRTB   := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_PRCTAB"} )
	nP_PRTB2  := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_PRCTAB2"} )
	nP_QTDA   := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_QUANT"} )
	nP_BICM   := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_BASEICM"} )
	nP_QOFER  := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_QOFERT"} )
	nP_VLOFER := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VOFERT"} )
	nP_FLAG   := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_FLAGOFE"} )
	nP_FLAGCON:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_FLAGCON"})
	nP_DTOFER := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_DTOFERT"} )
	nP_HROFER := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_HROFERT"} )
	nP_DESC   := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_DESC"} )
	nP_DESC2  := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_DESC2"} )
	nP_VALDESC:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VALDESC"} )
	nP_ACRE   := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_ACRE"} )
	nP_ACRE2  := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_ACRE2"} )
	nP_VALACRE:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VALACRE"} )
	nP_DESCICM:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_DESCICM"} )
	nP_VDESICM:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VDESICM"} )
	nP_VRCCAMP:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VRCCAMP"} )

	nP_FILTRAN:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_FILTRAN"} )
	nP_PLANILH:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_PLANILH"} )
	nP_PLITEM := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_PLITEM"} )

	nP_PERCEIP:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VALIPI"} )
	nP_VLR_IPI:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_ACREIPI"} )
	nP_TES    := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_TES"} )

	nP_SeqId    := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_SEQID"} )






    //VERIFICA SE O ORCAMENTO COPIADO ESTA VENCIDO (vencimento dos preços acertados).
    lOrcVencido 	:= (DDATABASE >  M->UA_DTLIM )
    lDesNegVencido	:= DDATABASE > (SUA->UA_EMISSAO + X_DESCNEG)  //ENTRE(SUA->UA_EMISSAO,(SUA->UA_EMISSAO + X_DESCNEG), DDATABASE)  // Descontos Negociados vencem em 30 dias

  	// Array com a amarracao produtoxcampanha para posterior gravacao da tabela ZZI
	__aProdCamp := {}

    nAnt := n

    __aItDigPrd := {}

	FOR I:= 1 TO LEN(ACOLS)

		//**************************
		//Projeto F11 - Usado para armazenar o estado anterior dos produtos para quando os mesmos forem alterados
		// possa ser detectado
		AADD(__aItDigPrd,{I,gdFieldGet("UB_PRODUTO",I),gdFieldGet("UB_LOCAL",I)})
		aAdd(__aItDigQtd,I)
		//**************************

    	 ACOLS[I,nP_Email]  := "N"
    	 //Inserido por Edivaldo Gonçalves Cordeiro em 20/07/06
		 ACOLS[I,nP_DATA]   := DDATABASE
	 	 ACOLS[I,nP_HORA]   := STRZERO(VAL(SUBSTR(TIME(),1,2))+1,2)+SUBSTR(TIME(),4,2)//SPACE(LEN(SUB->UB_HRNECLI))
	 	 SB1->(dbSeek(xFilial('SB1')+gdFieldGet("UB_PRODUTO",I)))
	 	 ACOLS[I,nP_PERCEIP]:= B1_IPI
	 	 ACOLS[I,nP_VLR_IPI]:=gdFieldGet("UB_VRCACRE",I)*(1+(MaFisRet(I,"IT_ALIQIPI")/100))
	 	´//Fim da Alteração por Edivaldo

	 	 ACOLS[I,nP_QOFER]  := 0
	 	 ACOLS[I,nP_VLOFER] := 0
	 	 ACOLS[I,nP_FLAG]   := " "
	 	 ACOLS[I,nP_FLAGCON]:= " "
	 	 ACOLS[I,nP_DTOFER] := CTOD("")
	 	 ACOLS[I,nP_HROFER] := SPACE(LEN(SUB->UB_HROFERT))
	 	 ACOLS[I,nP_DATA]   := DDATABASE  //Data da Necessidade do Cliente
	 	 ACOLS[I,nP_HORA]   := STRZERO(VAL(SUBSTR(TIME(),1,2))+1,2)+SUBSTR(TIME(),4,2)//Hora da Necessidade do Cliente


	 	 ACOLS[I,nP_FILTRAN] := SPACE(LEN(SUB->UB_FILTRAN))
	 	 ACOLS[I,nP_PLANILH] := SPACE(LEN(SUB->UB_PLANILH))
	 	 ACOLS[I,nP_PLITEM]  := SPACE(LEN(SUB->UB_PLITEM))
	 	 ACOLS[I,nP_SeqId ]  := 0




		 IF lOrcVencido		// orcamento vencido
			 ACOLS[I,nP_PRCV]    := MaTabPrVen(M->UA_TABELA,ACOLS[I,nP_Prod],ACOLS[I,nP_QTDA],M->UA_CLIENTE,M->UA_LOJA,M->UA_MOEDA)
			 ACOLS[I,nP_PRTB]    := ACOLS[I,nP_PRCV]
			 ACOLS[I,nP_PRTB2]   := ACOLS[I,nP_PRCV]
 			 ACOLS[I,nP_PRAC]    := A410Arred(ACOLS[I,nP_PRCV]*nAcreCond,"UB_VRUNIT")
 		 	 ACOLS[I,nP_VLIT]    := (ACOLS[I,nP_PRCV] * ACOLS[I,nP_QTDA])  // TOTAL  (QTD X VALOR)
	 		 ACOLS[I,nP_BICM]    := ACOLS[I,nP_VLIT]
	 		 IF lDesNegVencido
	 			 ACOLS[I,nP_DESC]    := 0
	 			 ACOLS[I,nP_DESC2]   := 0
	 			 ACOLS[I,nP_VALDESC] := 0
		 		 ACOLS[I,nP_ACRE]    := 0
		 		 ACOLS[I,nP_ACRE2]   := 0
	 			 ACOLS[I,nP_VALACRE] := 0
	 			 ACOLS[I,nP_DESCICM] := 0
	 			 ACOLS[I,nP_VDESICM] := 0
 			 ENDIF

 		    SB1->(dbSeek(xFilial('SB1')+gdFieldGet("UB_PRODUTO",I)))

	        ACOLS[I,nP_PERCEIP]:= B1_IPI
 			ACOLS[I,nP_VLR_IPI]:=gdFieldGet("UB_VRCACRE",I)*(1+(MaFisRet(I,"IT_ALIQIPI")/100))
    	    ACOLS[I,nP_DATA]   := DDATABASE
	 	    ACOLS[I,nP_HORA]   := STRZERO(VAL(SUBSTR(TIME(),1,2))+1,2)+SUBSTR(TIME(),4,2)


 		Else
 			nPrcTabAtu := MaTabPrVen(M->UA_TABELA,ACOLS[I,nP_Prod],ACOLS[I,nP_QTDA],M->UA_CLIENTE,M->UA_LOJA,M->UA_MOEDA)
 			If nPrcTabAtu != ACOLS[I,nP_PRTB2]	// houve atualizacao da tabela de precos
				// Atualiza preco de tabela
	   	        ACOLS[I,nP_PRTB2] := nPrcTabAtu
				// Atualiza descontos e acrescimos
				n := I
   				M->UB_VRUNIT := ACOLS[I,nP_PRCV]
 				u_AtuDesAcr()
 			Endif
	 	ENDIF

	 	 // Atualiza campo UB_VRCCAMP (Preco minimo de campanha de vendas)
	 	 u_MsgCamp(ACOLS[I,nP_Prod],.T.,.F.,.F.,.T.,nAcreCond)

	NEXT
	n := nAnt

	// Tratamento especifico a algumas variaveis do cabecalho do atendimento
    M->UA_DTLIM := CRIAVAR("UA_DTLIM",.T.)	// vencimento do orcamento
    M->UA_DESCOND := SE4->E4_DESCRI			// descricao da condicao de pagamento
	M->UA_TRANSP  := SUA->UA_TRANSP			// codigo da tranportadora
	If lOrcVencido
 		IF lDesNegVencido
			M->UA_DESCICM := 0	// zera o desconto de icm se o orcamento estiver vencido
		ENDIF
	Endif

	// Indica que neste atendimento, ao se passar pelo campo UA_TABELA, a validacao nao atualizar os precos dos itens do atendimento
	__cTabAtu	:= M->UA_TABELA

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Refresh no RODAPE	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aValores[MERCADORIA]	:= SUA->UA_VALMERC
	aValores[ACRESCIMO]		:= SUA->UA_ACRESCI
	aValores[DESPESA]	 	:= SUA->UA_DESPESA
	aValores[DESCONTO]		:= SUA->UA_DESCONT
	aValores[MERCADORIA]	:= SUA->UA_VALBRUT
	aValores[FRETE]			:= SUA->UA_FRETE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Deleta os bonus 	     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	bTk271Bonus(2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recalcula os valores  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	bTk271Recalc()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualizo dados da ultima ligacao                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectarea("SUA")
	DbSetorder(7)   //Data da ultima liga‡ao
	If DbSeek(xFilial("SUA") + cCliente + cLoja)
		cLigacao	:= DTOC(SUA->UA_EMISSAO)+" - "+Substr(SUA->UA_INICIO,1,5)
		cOperador   := Posicione("SU7",1,xFilial("SU7") + SUA->UA_OPERADO,"U7_NOME")
		If !Empty(SUA->UA_PROXLIG)
			cProximo:= DTOC(SUA->UA_PROXLIG) + " - " + SUA->UA_HRPEND + " - " + cOperador
		Endif
		cOperacao := BTkStatus(SUA->UA_STATUS)

		oLigacao :Refresh()
		oOperador:Refresh()
		oOperacao:Refresh()
		oProximo :Refresh()
	Endif
Else
	cNumAux   := GetSxeNum("SUA","UA_NUM")
	M->UA_NUM := cNumAux
	RollBackSxe()
	If cNumTlv > cNumAux
		Help( " ",1,"FORA_SEQ")
	EndIf
Endif

oGetTlv:oBrowse:Refresh()
Eval(bRefresh)

CursorArrow()
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk271Recalc     ³Autor ³ Fabio Rogerio Pereira   ³ Data ³ 20/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Recalcula os valores do pedido 					              	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMK                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function bTK271Recalc()
Local nLinha	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zera os valores de desconto, acrescimo, mercadoria e total.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aValores[DESCONTO]  := 0
aValores[MERCADORIA]:= 0
aValores[TOTAL]     := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Recalcula os valores somente para os itens que nao foram deletados.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nLinha:=1 To Len(aCols)
	If (!aCols[nLinha][Len(aHeader)+1]) .AND. (!Empty(aCols[nLinha][1]))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa a rotina que irá calcular os valores de Valor Unitario, Valor Item, Desconto e Acrescimo.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bTk271CalcValores("UB_PRODUTO",nLinha)
	Endif
Next nLinha

Tk273RodImposto("NF_DESPESA",aValores[DESPESA]+aValores[ACRESCIMO])
Tk273RodImposto("NF_FRETE",aValores[FRETE])

oGetTlv:oBrowse:Refresh()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Tk271Bonus³ Autor ³Fabio Rogerio Pereira  ³ Data ³20.06.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de tratamento da regra de bonificacao para interface ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Tipo de operacao                                     ³±±
±±³          ³       [1] Inclusao do bonus                                ³±±
±±³          ³       [2] Exclusao do bonus                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo avaliar a regra de bonificacao³±±
±±³          ³e adicionar na respectiva interface                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Call Center						                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function bTk271Bonus(nTipo)
Local aArea     := GetArea()
Local aBonus    := {}
Local nX        := 0
Local nY        := 0
Local nLinha    := 0
Local nZ        := Len(aCols)
Local nUsado    := Len(aHeader)
Local nPProd    := aPosicoes[1][2]
Local nPDesc    := aPosicoes[2][2]
Local nPQuant   := aPosicoes[4][2]
Local nPVrUnit  := aPosicoes[5][2]
Local nPVlrItem := aPosicoes[6][2]
Local nPTES		:= aPosicoes[11][2]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica os bonus                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipo == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica os bonus por item de venda                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aBonus   := FtRgrBonus(aCols,{nPProd,nPQuant,nPTES},M->UA_CLIENTE,M->UA_LOJA,M->UA_TABELA,Nil)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recupera os bonus ja existentes                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aBonus   := FtRecBonus(aCols,{nPProd,nPQuant,nPTES,nUsado+1},aBonus)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava os novos bonus                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nY := Len(aBonus)
	If nY > 0
		For nX := 1 To nY
			aadd(aCols,Array(nUsado+1))
			nZ++
			N := nZ

			For nW := 1 To nUsado
				aCols[nZ,nW] := CriaVar(aHeader[nW,2],.T.)
			Next nW

			aCols[nZ,nUsado+1] := .F.
			aCols[nZ,nPProd  ] := aBonus[nX][1]
			aCols[nZ,nPDesc  ] := Posicione("SB1",1,xFilial("SB1") + aBonus[nX][1],"B1_DESC")
			aCols[nZ,nPQuant ] := aBonus[nX][2]
			aCols[nZ,nPTES   ] := aBonus[nX][3]
		Next nX

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Recalcula os valores.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Tk271Recalc()
	Endif
Else
	FtDelBonus(aCols,{nPProd,nPQuant,nPTES,nUsado+1})

	For nLinha:= 1 To Len(aCols)
		If (aCols[nLinha][Len(aHeader)+1])

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Deleta o item da rotina fiscal.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !MaFisFound("IT",nLinha)
				MaFisAdd("","",0,0,0,"","",,0,0,0,0,0)
			Endif
			MaFisDel(nLinha,aCols[nLinha][Len(aCols[nLinha])])
		Endif
	Next
Endif

RestArea(aArea)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk271CalcValores ³ Autor ³ Marcelo Kotaki       ³ Data ³ 28/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula o valor dos campos de desconto e acrescimo           		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tk271CalcDesc(ExpN1,ExpC1)										³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 = Tipo(1=% 2=Valor), ExpN1 = Valor/Percentual  	    		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³TMKA271													    	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                           	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³28/12/01³609   ³-Revisao total do fonte                       	³±±
±±³          ³        ³      ³                                              	³±±
±±³          ³        ³      ³                                              	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function bTk271CalcValores(cCampo,nLinha)
Local cArea     := GetArea()
Local nPProd    := aPosicoes[1][2]
Local nPQuant   := aPosicoes[4][2]
Local nPVrUnit  := aPosicoes[5][2]
Local nPVlrItem := aPosicoes[6][2]
Local nPDesc    := aPosicoes[9][2]
Local nPValDesc := aPosicoes[10][2]
Local nPTes	    := aPosicoes[11][2]
Local nPAcre    := aPosicoes[13][2]
Local nPValAcre := aPosicoes[14][2]
Local nPPrcTab  := aPosicoes[15][2]

Local nDesconto := 0
Local nQuant    := 0
Local nDescPer  := 0
Local nValDesc  := 0
Local nAcrePer  := 0
Local nValAcre  := 0
Local nVrUnit   := 0
Local nAuxVrUnit:= 0

Local cPrcFiscal:= bTk271Posto(M->UA_OPERADO,"U0_PRECOF") 	//Preco fiscal bruto 1=SIM / 2=NAO
Local cDesconto := bTk271Posto(M->UA_OPERADO,"U0_DESCONT")	//Desconto  1=ITEM / 2=TOTAL / 3=AMBOS / 4=NAO
Local cAcrescimo:= bTk271Posto(M->UA_OPERADO,"U0_ACRESCI") 	//Acrescimo 1=ITEM / 2=NAO
Local cTesBonus := GetMv("MV_BONUSTS") 						//Codigo da TES usado para as regras de bonificacao
Local cTes      := ""
Local lRet      := .F.

nLinha:= IIf(ValType(nLinha) == "U", n, nLinha )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe os produtos.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aCols[nLinha][nPProd])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica qual o campo que executou a chamada da funcao ³
	//³e armazena os valores.                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cCampo == "UB_QUANT")
		nQuant  := M->UB_QUANT
		nVrUnit := aCols[nLinha][nPVrUnit]
		cTes    := aCols[nLinha][nPTes]

	ElseIf (cCampo == "UB_DESC")
		nDescPer:= M->UB_DESC
		nQuant  := aCols[nLinha][nPQuant]
		nVrUnit := aCols[nLinha][nPVrUnit]
		cTes    := aCols[nLinha][nPTes]
		nValDesc:= 0

		//Zera o desconto anterior da Getdados
		aCols[nLinha][nPDesc]   := 0
		aCols[nLinha][nPValDesc]:= 0

		// Pega o conteudo do acrescimo da getdados
		nAcrePer := aCols[nLinha][nPAcre]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³So pode dar desconto se o Posto de venda estiver 	³
		//³configurado para Item ou Ambos						³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nDescPer > 0
			If Alltrim(cDesconto) == "2" .OR. Alltrim(cDesconto) == "4"   // Total ou Nao
				Help( " ", 1, "NAO_DESCON")
				Return(lRet)
				nDescPer:= 0
				nValDesc:= 0
			Endif
		Endif

	ElseIf (cCampo == "UB_VALDESC")
		nValDesc:= M->UB_VALDESC
		nQuant  := aCols[nLinha][nPQuant]
		nVrUnit := aCols[nLinha][nPVrUnit]
		cTes    := aCols[nLinha][nPTes]
		nDescPer:= 0

		//Zera o valor do desconto anterior
		aCols[nLinha][nPDesc]   := 0
		aCols[nLinha][nPValDesc]:= 0

		// Pega o conteudo do acrescimo da getdados
		nAcrePer := aCols[nLinha][nPAcre]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³So pode dar desconto se o Posto de venda estiver 	³
		//³configurado para Item ou Ambos						³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nValDesc <> 0
			If Alltrim(cDesconto) == "2" .OR. Alltrim(cDesconto) == "4"   // Total ou Nao
				Help( " ", 1, "NAO_DESCON")
				Return(lRet)
				nDescPer := 0
				nValDesc := 0
			Endif
		Endif

	ElseIf (cCampo == "UB_ACRE")
		nAcrePer:= M->UB_ACRE
		nQuant  := aCols[nLinha][nPQuant]
		nVrUnit := aCols[nLinha][nPVrUnit]
		cTes    := aCols[nLinha][nPTes]
		nValAcre:= 0

		//Zera o acrescimo anterior
		aCols[nLinha][nPAcre]   := 0
		aCols[nLinha][nPValAcre]:= 0

		// Pega o conteudo atual do desconto da getdados
		nDescPer := aCols[nLinha][nPDesc]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o posto nao recalcula o unitario nao pode dar acrescimo³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nAcrePer > 0
			If Alltrim(cAcrescimo) == "2"  // 1 - Item e 2 - Nao
				Help( " ", 1, "NAO_ACRESC")
				Return(.F.)
				nAcrePer := 0
				nValAcre := 0
			Endif
		Endif

	ElseIf (cCampo == "UB_VALACRE")
		nValAcre:= M->UB_VALACRE
		nQuant  := aCols[nLinha][nPQuant]
		nVrUnit := aCols[nLinha][nPVrUnit]
		cTes    := aCols[nLinha][nPTes]
		nAcrePer:= 0

		aCols[nLinha][nPAcre]   := 0
		aCols[nLinha][nPValAcre]:= 0

		// Pega o conteudo atual da getdados
		nDescPer := aCols[nLinha][nPDesc]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o posto nao recalcula o unitario nao pode dar acrescimo³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nValAcre > 0
			If Alltrim(cAcrescimo) == "2"  // 1 - Item ou 2 - Nao
				Help( " ", 1, "NAO_ACRESC")
				Return(.F.)
				nAcrePer := 0
				nValAcre := 0
			Endif
		Endif

	ElseIf (cCampo == "UB_VRUNIT")
		nVrUnit := M->UB_VRUNIT
		nQuant  := aCols[nLinha][nPQuant]
		cTes    := aCols[nLinha][nPTes]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Mudou o valor unitario zera os descontos e os acrescimos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nDescPer:= 0
		nAcrePer:= 0
		nValDesc:= 0
		nValAcre:= 0

	ElseIf (cCampo == "UB_TES")
		cTes    := M->UB_TES
		nVrUnit := aCols[nLinha][nPVrUnit]
		nQuant  := aCols[nLinha][nPQuant]
		nDescPer:= 0
		nAcrePer:= 0
		nValDesc:= 0
		nValAcre:= 0

	ElseIf (cCampo == "UB_PRODUTO")
		nQuant  := aCols[nLinha][nPQuant]
		nVrUnit := aCols[nLinha][nPVrUnit]
		cTes    := aCols[nLinha][nPTes]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Mudou o produto ou alterou o produto zera os descontos e acrescimos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nDescPer:= 0
		nAcrePer:= 0
		nValDesc:= 0
		nValAcre:= 0

	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se for algum campo diferente zera todos os descontos e acrescimos ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nQuant  := aCols[nLinha][nPQuant]
		nVrUnit := aCols[nLinha][nPVrUnit]
		cTes    := aCols[nLinha][nPTes]
		nDescPer:= 0
		nAcrePer:= 0
		nValDesc:= 0
		nValAcre:= 0

	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a tabela nao for vazia pega o preco de tabela,              ³
	//³caso contrario pega o valor informado nao campo Valor Unitario.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lOrcVencido
		If !Empty(M->UA_TABELA)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se for uma tabela de preço valida calcula o valor unitario do item³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If MaVldTabPrc(M->UA_TABELA,"","")
				nVrUnit 			   := MaTabPrVen(M->UA_TABELA,aCols[nLinha][nPProd],nQuant,M->UA_CLIENTE,M->UA_LOJA,M->UA_MOEDA)
				aCols[nLinha][nPPrcTab]:= nVrUnit
			Endif
		Endif
	Endif


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a TES utilizada e diferente da TES de bonificacao calcula os acrescimos e descontos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cTes <> cTesBonus)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcula os acrescimos considerando o Posto de Venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (cAcrescimo == "1") //Pode dar acrescimo
			If (nAcrePer > 0)
				aCols[nLinha][nPAcre]   := nAcrePer
				aCols[nLinha][nPVrUnit] := A410Arred(nVrUnit * (100 + nAcrePer) / 100,"UB_VRUNIT")
				aCols[nLinha][nPValAcre]:= A410Arred(((nVrUnit * nAcrePer) / 100) * nQuant,"UB_VALACRE")

			ElseIf (nValAcre > 0)
				nAcrePer                := A410Arred(nValAcre / nQuant ,"UB_VALACRE")
				nAcrePer                := A410Arred((nAcrePer / nVrUnit) * 100,"UB_ACRE")
				aCols[nLinha][nPAcre]   := nAcrePer
				aCols[nLinha][nPVrUnit] := A410Arred(nVrUnit * (100 + nAcrePer) / 100,"UB_VRUNIT")
				aCols[nLinha][nPValAcre]:= nValAcre
			Endif
			aCols[nLinha][nPVlrItem]	:= A410Arred(nQuant * aCols[nLinha][nPVrUnit],"UB_VLRITEM")
			nAuxVrUnit					:= aCols[nLinha][nPVrUnit]
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcula os descontos considerando o Posto de Venda  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (cDesconto == "1") .OR. (cDesconto == "3")   // Item - Ambos
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcula a regra de bonificacao em %³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//nDesconto := MaRgrDesc(aCols[nLinha][nPProd],M->UA_CLIENTE,M->UA_LOJA,M->UA_TABELA,nQuant,Nil,Nil,1)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcula o percentual de desconto em cascata caso haja um desconto alem da bonificacao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (nDescPer > 0)
				nDesconto := nDescPer

			ElseIf (nValDesc > 0)
				nDescPer  := A410Arred((nValDesc / (nQuant * nVrUnit))*100,"UB_DESC")
				nDesconto := nDescPer
			Endif
		Endif

	Endif

	If !Empty(nAuxVrUnit)
		nVrUnit := nAuxVrUnit
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula os valores totais e descontos.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (ALLTRIM(cPrcFiscal) == "1") //Se o preco fiscal bruto = SIM , nao recalcula o valor unitario
		aCols[nLinha][nPQuant]  := nQuant
		aCols[nLinha][nPVrUnit] := nVrUnit
		aCols[nLinha][nPVlrItem]:= A410Arred(nQuant * nVrUnit, "UB_VLRITEM") - aCols[nLinha][nPValDesc]
		If lInclui
			aCols[nLinha][nPValDesc]:= A410Arred((nQuant * nVrUnit) * (nDesconto/100),"UB_VALDESC")
			aCols[nLinha][nPDesc]   := nDesconto
		Endif
	Else
		aCols[nLinha][nPQuant]  := nQuant
		aCols[nLinha][nPVrUnit] := A410Arred(nVrUnit * (1-(nDesconto/100)),"UB_VRUNIT")
		aCols[nLinha][nPVlrItem]:= A410Arred(nQuant  * aCols[nLinha][nPVrUnit] ,"UB_VLRITEM")
		If lInclui
			aCols[nLinha][nPValDesc]:= A410Arred(nQuant  * nVrUnit,"UB_VALDESC") - aCols[nLinha][nPVlrItem]
			aCols[nLinha][nPDesc]   := nDesconto
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula os impostos.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	bTk271Trigger("UB_VLRITEM",nLinha)

	lRet:= .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula o desconto no total.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cDesconto == "2") .OR. (cDesconto == "3")   // Total ou Ambos
	nDesconto:= MaRgrDesc(aCols[nLinha][nPProd],M->UA_CLIENTE,M->UA_LOJA,M->UA_TABELA,nQuant,Nil,Nil,2)
	aValores[DESCONTO]:= (aValores[MERCADORIA] * nDesconto / 100) + Posicione("SUA",1,xFilial("SUA")+M->UA_NUM,"UA_DESCONT") //Soma UA_DESCONT para descontos informados e gravados na base.
	Eval(bRefresh)
Endif

RestArea( cArea )

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271Posto ³ Autor ³Fabio Rogerio Pereira ³ Data ³05/04/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna o conteudo do campo solicitado                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³TMKA271											          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function bTK271Posto(cCodOper,cCampo)
Local xRet
Local cAlias:= Alias()
Local nIndex:= IndexOrd()
Local nRec  := Recno()
Local cPosto:= CRIAVAR("U7_POSTO",.F.)

cPosto:= Posicione("SU7",1,xFilial("SU7") + cCodOper,"U7_POSTO")
cPosto:= IIf(Empty(cPosto),GetMV("MV_POSTO"),cPosto)

xRet  := Posicione("SU0",1,xFilial("SU0") + cPosto,cCampo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura o ambiente.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(cAlias)
DbSetorder(nIndex)
DbGoTo(nRec)

Return(xRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271Trigger³ Autor ³Fabio Rogerio Pereira³ Data ³ 30/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza o folder do rodape com REFRESH                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1:Campo que sera atualizado                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGATMK                                         			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function bTk271Trigger(cCampo,nTrigger)
Local lRet		:= .T.
Local aArea 	:= GetArea()
Local nPosCpo	:= Ascan(aHeader,{|x| x[2]=cCampo})
Local nSavN		:= n
Local aSavCols  := AClone(aCols)

If nTrigger != nil
	n:= nTrigger
EndIf

If nPosCpo > 0
	For nx	:= 1 to Len(aHeader)
		M->&(AllTrim(aHeader[nx][2])) := aCols[n][nx]
	Next
	If &(aHeader[nPosCpo][6])
		If MaFisFound("NF")
			bTk271TlvImp()
		EndIf
	Else
		lRet := .F.
	EndIf
Else
	lRet := .F.
EndIf

If nTrigger != nil
	n:= nSavN
EndIf

aCols:= AClone(aSavCols)
RestArea(aArea)

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271TlvImp ³ Autor ³   Fabio Rogerio     ³ Data ³ 30/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza o folder do rodape com REFRESH                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGATMK                                         			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function bTk271TlvImp()
Eval(bRefresh)
oFoldRodape:Refresh()
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk271Config³ Autor ³ Fabio Rogerio Pereira³ Data ³ 29.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta ACOLS e AHEADER conforme o alias passado			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk271Config(ExpC1,ExpN1,ExpC2,ExpF1)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Alias selecionado								  ³±±
±±³          ³ ExpN1 := Numero do Folder								  ³±±
±±³          ³ ExpC2 := Campos que nao devem aparecer na Getdados		  ³±±
±±³          ³ ExpF1 := Flag que indica qual array sera selecionado		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TMKA271													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function bTk271Config(cAlias,cString,cNumTmk,cNumTlv,cNumTlc)
Local nUsado	:= 0
Local aTmpHeader:= {}	//aHeader Temporario
Local aTmpCols	:= {}  	//acols Temporario
Local nCnt		:= 0 	//Qtde. registros
Local nPProd 	:= 0
Local nPDescPro := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aHeader a partir dos campos do SX3         	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado := 0
aCampos:= {}
DbSelectArea("SX3")
DbSetorder(1)
MsSeek(cAlias)
While !EOF() .AND. (X3_ARQUIVO == cAlias)
	If X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL .AND. (! TRIM(SX3->X3_CAMPO) $ cString )
		nUsado++
		Aadd(aCampos,ALLTRIM(X3_CAMPO))
		AADD(aTmpHeader,{TRIM(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	Endif
	SX3->(DbSkip())
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica posicao relativa dos campos do SUB/SUD na GetDados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aPosicoesV,{"UB_PRODUTO"   ,Ascan(aCampos,"UB_PRODUTO")})	//1
AADD(aPosicoesV,{"UB_DESCRI"    ,Ascan(aCampos,"UB_DESCRI")})	//2
AADD(aPosicoesV,{"UB_SITPROD"   ,Ascan(aCampos,"UB_SITPROD")})	//3
AADD(aPosicoesV,{"UB_QUANT"     ,Ascan(aCampos,"UB_QUANT")})	//4
AADD(aPosicoesV,{"UB_VRUNIT"    ,Ascan(aCampos,"UB_VRUNIT")})	//5
AADD(aPosicoesV,{"UB_VLRITEM"   ,Ascan(aCampos,"UB_VLRITEM")})	//6
AADD(aPosicoesV,{"UB_LOCAL"     ,Ascan(aCampos,"UB_LOCAL")})	//7
AADD(aPosicoesV,{"UB_UM"        ,Ascan(aCampos,"UB_UM")})		//8
AADD(aPosicoesV,{"UB_DESC"    	,Ascan(aCampos,"UB_DESC")})  	//9
AADD(aPosicoesV,{"UB_VALDESC"   ,Ascan(aCampos,"UB_VALDESC")})	//10
AADD(aPosicoesV,{"UB_TES"  	   	,Ascan(aCampos,"UB_TES")})		//11
AADD(aPosicoesV,{"UB_CF"  		,Ascan(aCampos,"UB_CF")})		//12
AADD(aPosicoesV,{"UB_ACRE"  	,Ascan(aCampos,"UB_ACRE")})		//13
AADD(aPosicoesV,{"UB_VALACRE"   ,Ascan(aCampos,"UB_VALACRE")})	//14
AADD(aPosicoesV,{"UB_PRCTAB"  	,Ascan(aCampos,"UB_PRCTAB")})	//15
AADD(aPosicoesV,{"UB_DTENTRE" 	,Ascan(aCampos,"UB_DTENTRE")})	//16
AADD(aPosicoesV,{"UB_LOTE"      ,Ascan(aCampos,"UB_LOTE")})   	//17
AADD(aPosicoesV,{"UB_SUBLOTE"   ,Ascan(aCampos,"UB_SUBLOTE")})	//18
AADD(aPosicoesV,{"UB_DTVALID"   ,Ascan(aCampos,"UB_DTVALID")})	//19

aPosicoes := Aclone(aPosicoesV)
nPProd 	  := aPosicoes[1][2]
nPDescPro := aPosicoes[2][2]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso nao seja inclusao carrega os registros das base para a getdados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nCnt := 0

DbSelectArea("SUB")
DbSetorder(1)
DbSeek(xFilial("SUB")+cNumTlv)
While !EOF() .AND. (SUB->UB_FILIAL+SUB->UB_NUM == xFilial("SUB")+cNumTlv)
	nCnt++
	aadd(aTmpCols,Array(nUsado+1))
	For nX := 1 to Len(aTmpHeader)
		If (aTmpHeader[nX][10] <> "V" .AND. aTmpHeader[nX][08] <> "M")
			aTmpCols[Len(aTmpCols)][nX] := FieldGet(FieldPos(aTmpHeader[nX][2]))
		Else
			If (aTmpHeader[nX][08] <> "M")
				aTmpCols[Len(aTmpCols)][nX] := CriaVar(aTmpHeader[nX][2],.T.)
			Else
				aTmpCols[Len(aTmpCols)][nX] := FieldGet(FieldPos(aTmpHeader[nX][2]))
			Endif
		Endif
		aTmpCols[Len(aTmpCols)][nUsado+1] := .F.
	Next nX

	If !Empty(aTmpCols[nCnt][nPProd])
		DbSelectarea("SB1")
		DbSetorder(1)
		If !(DbSeek( xFilial("SB1")+aTmpCols[nCnt][nPProd] ))
			Help(" ",1,"B1PROD" )
		Endif
		aTmpCols[nCnt][nPDescPro] :=SB1->B1_DESC
	Endif

	DbSelectArea("SUB")
	DbSkip()
Enddo

aSvFolder[2][1] := aClone(aTmpHeader)
aSvFolder[2][2] := aClone(aTmpCols)
aSvFolder[2][3] := Len(aTmpCols)

//Seta o aCols e aHeader para o Folder 2 - TeleVendas
aHeader:= aClone(aSvFolder[2][1])
aCols  := aClone(aSvFolder[2][2])
n	   := aSvFolder[2][3]
If MaFisFound()
	MaFisClear()
	MaColsToFis(aHeader,aCols,,"TK271",.T.)
Endif

Return(.T.)