#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"
#include "vkey.ch"

#DEFINE MERCADORIA		1	 // Valor total do mercadoria
#DEFINE DESCONTO			2	 // Valor total do desconto
#DEFINE ACRESCIMO		3	 // Valor do acrescimo financeiro da condicao de pagamento
#DEFINE FRETE   			4	 // Valor total do Frete
#DEFINE DESPESA 			5	 // Valor total da despesa
#DEFINE TOTAL 			6	 // Total do Pedido
#DEFINE X_DESCNEG		30  // Dias para vencimento dos acrescimos/descontos negociados

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271HTlv ³ Autor ³ Fabio Rogerio Pereira ³ Data ³ 03/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Hist¢rico das ligacoes atendidas pelo Televendas           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso   	 ³ SIGATMK      			 						 	      			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³03/12/01³609   ³- O historico nao esta carregando a descri- ³±±
±±³          ³        ³      ³  cao do produto corretamente.              ³±±
±±³Jorge Oliv³28/01/11³      ³- Diversos ajustes p/ compatibilizar c/ P10 ³±±
±±³          ³        ³      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function COPIATT()

	Local cCodPed	:= ""
	Local oMonoAs	:= TFont():New( "Mono AS", 6, 15 )
	Local aFirst[1][Len(aHeader)+1]
	Local oDlgHist
	Local nHist		:= 0
	Local bSavKey
	Local nAnt := n
	Local cperg:= 'TMKH02'
	Local lBkpCopia := __COPIATT

	// Bitmaps das legendas do historico
	Local oBmp1													//Atendimento
	Local oBmp2 												//Orcamento
	Local oBmp3 												//Aberto
	Local oBmp4 												//Liberado
	Local oBmp5 												//Faturado
	Local oBmp6 												//Cancelado
	Local oBmp7 												//Em Carga (integracao com OMS)

	Private oGetHist, oObsMemo, cObsMemo, oCancMemo, cCancMemo
	Private oLbx, aLigacoes := {}
	Private 	oAberto     := LoadBitmap( GetResources(),"BR_VERDE"),;
				oEncerrado  := LoadBitmap( GetResources(),"BR_VERMELHO"),;
				oLiberado   := LoadBitmap( GetResources(),"BR_AMARELO"),;
				oOrcamento  := LoadBitmap( GetResources(),"BR_AZUL")
	Private lPodeSair := .F.
	Private lMaior    := .T.
	Private aColAnt   := AClone(aCols)


	Public cTipoAte := "2"

	// Se o usuario ja digitou a quantidade e consultou o estoque, ele deve gravar o atendimento que esta posicionado
	If __Podesair != "S"
		IW_MSGBOX(Oemtoansi("Opção não disponível. Realize a gravação do atendimento !"),Oemtoansi('Atenção'),'STOP')
		Return
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Flag que indica que o atendimento atual da tela é uma cópia³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	__COPIATT := .T.

	// Numero do atendimento
	cNUM_ANT := ""

	// Validacao da tela da verdade
	If nFolder == 1 // TeleMarketing ou Televendas
		If cTipoAte == "1" .OR. cTipoAte == "4" //Telemarketing ou Ambos
			MSGBOX("Opcao valida somente para tela de TeleVendas",'Atenção','ALERT')
			// Volta o conteudo original da variavel
			__COPIATT := lBkpCopia

			Return
		ElseIf (cTipoAte == "2") // Televendas
			If Inclui
				// Guarda numero do atendimento
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
					// Volta o conteudo original da variavel
					__COPIATT := lBkpCopia

					Return(.F.)
				Endif
			Else
				Alert("Opção não disponível, clique em 'Limpa o Atendimento' para iniciar um novo atendimento")
				// Volta o conteudo original da variavel
				__COPIATT := lBkpCopia

				Return
			Endif
		ElseIf (cTipoAte == "3") // TeleCobranca
			MSGBOX("Opcao valida somente para tela de TeleVendas",'Atenção','ALERT')
			// Volta o conteudo original da variavel
			__COPIATT := lBkpCopia

			Return
		Endif
	ElseIf nFolder == 2 // Televendas
		If Inclui
			// Guarda numero do atendimento
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
				// Volta o conteudo original da variavel
				__COPIATT := lBkpCopia

				Return(.F.)
			Endif
		Else
			Alert("Opção não disponível, clique em 'Limpa o Atendimento' para iniciar um novo atendimento")
			// Volta o conteudo original da variavel
			__COPIATT := lBkpCopia

			Return
		Endif
	ElseIf nFolder == 3 // Telecobranca
		MSGBOX("Opcao valida somente para tela de TeleVendas",'Atenção','ALERT')
		// Volta o conteudo original da variavel
		__COPIATT := lBkpCopia

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
		cQuery := "SELECT /*+rule*/ SUA.*, SA3.A3_NOME "
		cQuery += "FROM " + RetSqlName("SUA") + " SUA, " + RetSqlName("SA3") + " SA3, "
		cQuery += "WHERE "
		cQuery += "SUA.UA_FILIAL='"  + xFilial("SUA") + "' AND "
		cQuery += "SUA.UA_CLIENTE='" + M->UA_CLIENTE  + "' AND "
		cQuery += "SUA.UA_LOJA='"    + M->UA_LOJA     + "' AND "
		cQuery += "SUA.UA_PROSPEC='" + IIF(lProspect,'T','F') + "' AND "
		cQuery += "SUA.UA_EMISSAO >='"+ Dtos(MV_PAR01) + "' AND "
		cQuery += "SUA.UA_EMISSAO <='"+ Dtos(MV_PAR02) + "' AND "
		cQuery += "SUA.UA_OPERADO >='"+ MV_PAR03 + "' AND "
		cQuery += "SUA.UA_OPERADO <='"+ MV_PAR04 + "' "

		****************************************************************
		//Inserido por Edivaldo Goncalves Cordeiro em 29/05/2006
		//Filtra o Tipo de Operacao (Faturamento,Orcamento,Atendimento)
		//No Evento Click do Botao  Copia de Atendimento
		****************************************************************
		Do Case
			Case MV_PAR05=2
				cQuery += " AND SUA.UA_OPER='1' "
			Case MV_PAR05=3
				cQuery += " AND SUA.UA_OPER='2' "
			Case MV_PAR05=4
				cQuery += " AND SUA.UA_OPER='3' "
		EndCase


		//Filtra Marketing (1=ATIVO  2=RECEPTIVO  3=FAX  4=REPRESENTANTE)
		Do Case
			Case MV_PAR06=2
				cQuery += " AND SUA.UA_TMK='2' "
			Case MV_PAR06=3
				cQuery += " AND SUA.UA_TMK='1' "
			Case MV_PAR06=4
				cQuery += " AND SUA.UA_TMK='3' "
			Case MV_PAR06=5
				cQuery += " AND SUA.UA_TMK='4' "
		EndCase

		cQuery += "AND SA3.A3_FILIAL (+) = '"+ xFilial("SA3")+"' AND "
		cQuery += "SA3.A3_COD (+) = SUA.UA_VEND AND "

		cQuery += "SUA.D_E_L_E_T_<>'*' AND "
		cQuery += "SA3.D_E_L_E_T_ (+) <>'*' "
		cQuery += "ORDER BY SUA.UA_EMISSAO DESC "

		cQuery := ChangeQuery(cQuery)

		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'TMK',.T.,.T.)
		TCSetField( 'TMK', 'UA_EMISSAO'  , 'D',8 , 0 )
		TCSetField( 'TMK', 'UA_VLRLIQ'   , 'N',12, 2 )
		TCSetField( 'TMK', 'UA_EMISNF'   , 'D',8 , 0 )

		DbSelectArea("TMK")
		dbgotop()
		While (!Eof())

			AAdd(aLigacoes, {	TMK->( bTK271OrcPed(	TMK->UA_DOC,TMK->UA_OPER,TMK->UA_CANC,TMK->UA_NUM) ),;// 01 - Status
																TMK->UA_NUM,;													// 02 - Atendimento
																DTOC(TMK->UA_EMISSAO),;										// 03 - Data
																TMK->A3_NOME,;													// 04 - Vendedor
																OemToAnsi(IIF(TMK->UA_OPER=="1","Faturamento","Or‡amento  ")),;	// 05 - Operacao
																IIF(!Empty(TMK->UA_CODCONT),Posicione("SU5",1,xFilial("SU5")+TMK->UA_CODCONT,"U5_CONTAT"),TMK->UA_DESCNT),;// 06 - Contato
																TMK->UA_NUMSC5,;												// 07 - Pedido
																bTkStatus(TMK->UA_STATUS,TMK->UA_OPER),;				// 08 - Status
																Transform(TMK->UA_VLRLIQ,"@E 999,999,999.99"),;	// 09 - Valor
																Posicione("SUO",1,xFilial("SUO")+TMK->UA_CODCAMP,"UO_DESC"),;// 10 - Campanha
																TMK->UA_DOC+"/"+TMK->UA_SERIE,;							// 11 - NF/SERIE
																DTOC(TMK->UA_EMISNF),;										// 12 - Emissao
																Posicione("SE4",1,xFilial("SE4")+TMK->UA_CONDPG,"E4_DESCRI"),;// 13 - Condicao de Pagto
																Posicione("SA4",1,xFilial("SA4")+TMK->UA_TRANSP,"A4_NOME"),;	// 14 - Transportadora
																TMK->UA_ENDENT,;												// 15 - Endereco Entrega
																TMK->UA_MUNE,;													// 16 - Cidade Entrega
																TMK->UA_CEPE,;				 									// 17 - Cep Entrega
																TMK->UA_CODOBS,;                                	// 18 - Codigo Observacao
																TMK->UA_CODCANC} )                              	// 19 - Codigo do Cancelamento
			DbSkip()
		Enddo
		DbCloseArea()

		// Se nao houver atendimentos para este cliente, retorna a tela
		If Len(aLigacoes) <= 0
			Help(" ",1,"SEMDADOS" )
			aCols	:= aClone(aColAnt)
			n		:= nAnt
			CursorArrow() // Define o ponteiro do mouse como seta.

			// Volta o conteudo original da variavel
			__COPIATT := lBkpCopia

			Return(.F.)
		Endif

		// Abre a janela com os atendimentos do cliente
		DEFINE MSDIALOG oDlgfHist FROM 1,003 TO 38,103 Title OemToAnsi("Historico")

		@ 01,002 To 228,395 Title OemtoAnsi("Ultimas Ligacoes")  oBject oDlgYHist

		@ 08,05 LISTBOX oLbx FIELDS ;
									HEADER ;
									OemToAnsi(""),;
									OemToAnsi("Or‡amento"),;
									OemToAnsi("Data"),;
									OemToAnsi("Vendedor"),;
									OemToAnsi("Opera‡„o"),;
									OemToAnsi("Contato"),;
									OemToAnsi("Pedido"),;
									OemToAnsi("Status"),;
									OemToAnsi("Valor"),;
									OemToAnsi("Campanha"),;
									OemToAnsi("Nota Fiscal"),;
									OemToAnsi("Emiss„o NF"),;
									OemToAnsi("Condi‡„o de Pagto"),;
									OemToAnsi("Transportadora"),;
									OemToAnsi("Endere‡o Entrega"),;
									OemToAnsi("Cidade"),;
									OemToAnsi("CEP");
									SIZE 385,120 OF oDlgHist PIXEL;

		oLbx:SetArray(aLigacoes)
		oLbx:bLine:={||{	aLigacoes[oLbx:nAt,1],;
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
		//³Monta o acols com os itens da ligacao selecionada.			       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TkMontaItens( "SUB", cCodPed, "V" )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Modificado o valor da variavel N para 1 para que nao seja tomado³
		//³como parametro a posicao do acols da tela de atendimento        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		N := 1
		oGetHist:= MSGetDados():New(135,5,225,390,2,"AlwaysTrue","AlwaysTrue","",.T.,,,.F.,)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Observacao da ligacao										             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 232,002 TO 270,115 Title OemToAnsi("Observa‡„o da liga‡„o") OBJECT oDlgSHist
		@ 240,05 GET cObsMemo oBJECT oObsMemo MEMO SIZE 105,25
		oObsMemo:oFont := oMonoAs
		oObsMemo:bRClicked := {|| AllwaysTrue() }

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Motivo do Cancelamento se for um orcamento cancelado  		    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 232,140 TO 270,245 Title OemToAnsi("Motivo do Cancelamento") OBJECT oCancMemo
		@ 240,145 GET cCancMemo oBJECT oCancMemo MEMO SIZE 090,25
		oCancMemo:oFont := oMonoAs
		oCancMemo:bRClicked := {|| AllwaysTrue() }

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Evento de DuploClick                            		    		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oLbx:bLDblClick := {|| aCols:=aClone(aColAnt), lPodeSair := .T., oDlgfHist:End(), Processa( {|| BTk271NumTlv(cCodPed) }, "Aguarde", "Carregando itens do Atendimento: " + cCodPed ) }

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Click no Header dos atendimentos                        		    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oLbx:bHeaderClick := { |o,x| OrdCols( x ) }

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Bitmaps das legendas do historico     ³
		//³                                      ³
		//³Marrom - Atendimento 			        ³
		//³Azul -  Orcamento                     ³
		//³Verde - Aberto                        ³
		//³Amarelo - Liberado                    ³
		//³Vermelho - NF.Emitida                 ³
		//³Preto - Cancelado                     ³
		//³Branco - Em Carga (integracao com OMS)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    // Legendas da Tela

		@ 272,05 BITMAP oBmp1 ResName "BR_MARRON" OF oDlgSHist Size 10,10 NoBorder When .F. Pixel
		@ 272,15 SAY OemToAnsi( "Atendimento" ) OF oDlgSHist Color CLR_BROWN,CLR_WHITE PIXEL

		@ 272,55 BITMAP oBmp2 ResName "BR_AZUL" OF oDlgSHist Size 10,10 NoBorder When .F. Pixel
		@ 272,65 SAY OemToAnsi( "Orcamento" ) OF oDlgSHist Color CLR_BLUE,CLR_WHITE PIXEL

		@ 272,105 BITMAP oBmp3 ResName "BR_VERDE" OF oDlgSHist Size 10,10 NoBorder When .F. Pixel
		@ 272,115 SAY OemToAnsi( "Aberto" ) OF oDlgSHist Color CLR_GREEN,CLR_WHITE PIXEL

		@ 272,155 BITMAP oBmp4 ResName "BR_AMARELO" OF oDlgSHist Size 10,10 NoBorder When .F. Pixel
		@ 272,165 SAY OemToAnsi( "Liberado" ) OF oDlgSHist Color CLR_BLACK PIXEL

		@ 272,205 BITMAP oBmp5 ResName "BR_VERMELHO" OF oDlgSHist Size 10,10 NoBorder When .F. Pixel
		@ 272,215 SAY OemToAnsi( "NF.Emitida" ) OF oDlgSHist Color CLR_RED,CLR_WHITE PIXEL

		@ 272,255 BITMAP oBmp6 ResName "BR_PRETO" OF oDlgSHist Size 10,10 NoBorder When .F. Pixel
		@ 272,265 SAY OemToAnsi( "Cancelado" ) OF oDlgSHist Color CLR_BLACK,CLR_WHITE PIXEL

		@ 272,305 BITMAP oBmp7 ResName "BR_BRANCO" OF oDlgSHist Size 10,10 NoBorder When .F. Pixel
		@ 272,315 SAY OemToAnsi( "Em Carga" ) OF oDlgSHist Color CLR_BLACK,CLR_WHITE PIXEL


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Botao "Ok"                                             		    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE SBUTTON FROM 245,285 TYPE 1 ID 301 ;
				ACTION {|| aCols:=aClone(aColAnt), lPodeSair := .T., oDlgfHist:End(), Processa( {|| BTk271NumTlv(cCodPed) }, "Aguarde", "Carregando itens do Atendimento: " + cCodPed ) };
				ENABLE OF oDlgfHist

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Botao "Cancela"                                         		    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE SBUTTON FROM 245,330 TYPE 2 ID 302 ACTION (aCols:=aClone(aColAnt),lPodeSair := .T.,oDlgfHist:End()) ENABLE OF oDlgFHist

		ACTIVATE MSDIALOG oDlgfHist CENTER ON INIT CursorArrow() VALID lPodeSair

		// Altera dados do cabecalho do atendimento
		M->UA_NUM := cNUM_ANT

		//area dos itens do orcamento
		DbSelectArea('SUB')
		DbSetOrder(1)

		// ALTERADO PROJETO F11, exige a redigitacao de todas as quantidades
		__nLibDel   := 0
		__aItDigQtd := {}

		// Volta o conteudo original da variavel
		__COPIATT := lBkpCopia

		// Volta a habilitar a tecla F5
		SetKey( VK_F5, bSavKey )


	Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡„o    ³Tk271OrcPed³ Autor ³Luis Marcelo Kotaki    ³ Data ³03/12/01  ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡„o ³Verifica quais os pedidos estao liberados e com NF gerada    ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso	    ³ SIGATMK                                     	 	      	   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function BTk271OrcPed(cNF,cOper,cCanc,cNum)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Bitmaps das legendas do historico     ³
//³                                      ³
//³Marrom - Atendimento 			        ³
//³Azul -  Orcamento                     ³
//³Verde - Aberto                        ³
//³Amarelo - Liberado                    ³
//³Vermelho - NF.Emitida                 ³
//³Preto - Cancelado                     ³
//³Branco - Em Carga (integracao com OMS)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oAtendimento:= LoadBitmap( GetResources(),"BR_MARRON")        // Bitmap
Local oOrcamento  := LoadBitmap( GetResources(),"BR_AZUL")			// Bitmap
Local oAberto	  := LoadBitmap( GetResources(),"BR_VERDE")			// Bitmap
Local oLiberado   := LoadBitmap( GetResources(),"BR_AMARELO") 		// Bitmap
Local oFaturado   := LoadBitmap( GetResources(),"BR_VERMELHO")		// Bitmap
Local oCancelado  := LoadBitmap( GetResources(),"BR_PRETO")			// Bitmap
Local oCarga      := LoadBitmap( GetResources(),"BR_BRANCO")		// Bitmap
Local oRet															// Objeto de Retorno
Local aArea		  := GetArea()										// Salva a area atual

Dbselectarea("SUA")
DbsetOrder(1)
MsSeek(xFilial("SUA")+cNum)

If !Empty(TRIM(cCanc))
	oRet := oCancelado
Else
	If cOper == "1" //Faturamento
		Do case
			Case Empty(cNF) //Aberto
				oRet := oAberto

				If !Empty(SUA->UA_NUMSC5)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifico se esse pedido foi liberado pelo SIGAFAT³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectarea("SC9")
					DbSetorder(1)
					If DbSeek(xFilial("SC9")+SUA->UA_NUMSC5)
						If Empty(C9_NFISCAL)	//Se estiver vazio indica que foi liberado mas ainda nao foi gerado NF
							oRet := oLiberado
						Endif
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifico se esse pedido foi faturado pelo SIGAFAT³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectarea("SC5")
					DbSetOrder(1)
					If DbSeek(xFilial("SC5")+SUA->UA_NUMSC5)
						If !Empty(C5_NOTA)
							oRet := oFaturado
						Endif
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifico se esse pedido esta em Carga (OMS)      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectarea("DAI")
					DbSetOrder(4)
					If DbSeek(xFilial("DAI")+SUA->UA_NUMSC5)
						oRet := oCarga
					Endif

				Endif

			Case !Empty(cNF) // NF. Emitida
				oRet := oFaturado
		Endcase

	ElseIf cOper == "2"  //Or‡amento
		oRet := oOrcamento

	ElseIf cOper == "3"  //Atendimento
	    oRet := oAtendimento
	Endif
Endif

RestArea(aArea)

Return(oRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkCargaItem ³ Autor ³ Luis Marcelo Kotaki  ³ Data ³ 15/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega os items gravados em cada atendimento selecionado    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso   	 ³ SIGATMK      			 						  						   ³±±
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
±±³ Uso  	 ³SIGATMK - Televendas                                        ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function BTk271NumTlv(cNumTlv)

	Local cNumAux := "", cTipo   := "", cCliente:= "", cLoja   := "", cQuery := "", nLinha := ""
	Local nPrcTabAtu
	Private lInclui, lDesNegVencido,lOrcVencido := .F.

	CursorWait()

	DBSELECTAREA("SB1")
	DBSETORDER(1)

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

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza a enchoice de TeleVendas.   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SX3")
		DbSetOrder(1)
		DbSeek("SUA")
		While (!SX3->( Eof()) .AND. SX3->X3_ARQUIVO == "SUA")

			If X3USO(SX3->X3_USADO)

				cCampo := ALLTRIM(SX3->X3_CAMPO)
				If cCampo != "UA_OPERADO" .and. cCampo != "UA_DESCOPE"
					If SX3->X3_CONTEXT # "V"
						M->&(cCampo) := SUA->&(cCampo)
					ElseIf SX3->X3_CONTEXT == "V"
						M->&(cCampo) :=  CriaVar(cCampo)
					EndIf
				Endif

			EndIf
			DbSkip()
		EndDo


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza a GetDados de TeleVendas.   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SX3")
		DbSetOrder(1)
		DbSeek("SUB")
		While (!SX3->( Eof()) .AND. SX3->X3_ARQUIVO == "SUB")

			If X3USO(SX3->X3_USADO)

				cCampo := ALLTRIM(SX3->X3_CAMPO)

				If SX3->X3_CONTEXT # "V"
					M->&(cCampo) := SUB->&(cCampo)
				ElseIf SX3->X3_CONTEXT == "V"
					M->&(cCampo) :=  CriaVar(cCampo)
				EndIf

			EndIf

			DbSkip()
		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza campos especificos          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		M->UA_DESCCLI := IIF(lProspect,SUS->US_NOME,SA1->A1_NOME)
		M->UA_DESCVEN := aLigacoes[oLbx:nAt,4]
		M->UA_DESCMID := Posicione("SUH",1,xFilial("SUH") + M->UA_MIDIA, "UH_DESC")
		M->UA_DESCCAM := aLigacoes[oLbx:nAt,10]
		M->UA_DESCLIG := Posicione("SU9",2,xFilial("SU9") + M->UA_CODLIG,"U9_DESC")
		M->UA_OBSCLI  := IIF(SUA->UA_PROSPEC,"",POSICIONE("SA1",1,XFILIAL("SA1")+SUA->UA_CLIENTE+SUA->UA_LOJA,"A1_OBSVEND"))
		M->UA_VENDINT := SF4->(U_PesqVend(M->UA_CLIENTE,M->UA_LOJA)) //Inserido por Edivaldo G. Cordeiro em 20/07/06
		M->UA_TABELA  := SUA->UA_TABELA
		M->UA_EMISSAO := dDATABASE

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atendimento original                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SUA->UA_STATUS == "NF."
			M->UA_NUMORIG := Space(Len(SUA->UA_NUM))
		Else
			M->UA_NUMORIG := SUA->UA_NUM
		Endif

		cQuery := ""
		cQuery := "SELECT COUNT( UB_ITEM ) AS QUANT "
		cQuery += "  FROM " + RetSqlName("SUB") + " "
		cQuery += " WHERE D_E_L_E_T_ = ' ' "
		cQuery += "   AND UB_FILIAL = '" + xFilial( "SUB" ) + "' "
		cQuery += "   AND UB_NUM = '" + cNumTlv + "' "

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY_QTPR",.F.,.T.)
		DbselectArea("QRY_QTPR")

		If QRY_QTPR->( !EOF() )
			ProcRegua( QRY_QTPR->QUANT + 1 )
		Else
			ProcRegua( 1 )
		EndIf
		DbCloseArea()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Configura‡ao da GetDados - Folder 01			     		³
		//³ *** Televendas                          			 		³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SUA->( bTK271Config( "SUB", "UB_NUM", NIL, cNumTlv, NIL, ) )

		// Tratamento especifico a algumas variaveis do cabecalho do atendimento
		M->UA_DTLIM   := CRIAVAR("UA_DTLIM",.T.)	// vencimento do orcamento
		M->UA_DESCOND := SE4->E4_DESCRI			// descricao da condicao de pagamento
		M->UA_TRANSP  := SUA->UA_TRANSP			// codigo da tranportadora

		// Indica que neste atendimento, ao se passar pelo campo UA_TABELA, a validacao nao atualizar os precos dos itens do atendimento
		__cTabAtu := M->UA_TABELA

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Refresh no RODAPE	     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aValores[MERCADORIA]		:= SUA->UA_VALMERC
		aValores[ACRESCIMO]		:= SUA->UA_ACRESCI
		aValores[DESPESA]	 		:= SUA->UA_DESPESA
		aValores[DESCONTO]		:= SUA->UA_DESCONT
		aValores[MERCADORIA]		:= SUA->UA_VALBRUT
		aValores[FRETE]			:= SUA->UA_FRETE

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Deleta os bonus 	    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SUA->( bTk271Bonus() )

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
			cOperacao := bTkStatus( SUA->UA_STATUS )

			oLigacao :Refresh()
			oOperador:Refresh()
			oOperacao:Refresh()
			oProximo :Refresh()
		Endif

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Nao localizou atendimento            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cNumAux   := GetSxeNum("SUA","UA_NUM")
		M->UA_NUM := cNumAux
		RollBackSxe()
		If cNumTlv > cNumAux
			Help( " ",1,"FORA_SEQ")
		EndIf
	Endif

	oGetTlv:oBrowse:Refresh()
	Eval(bRefresh)

	CursorArrow() // Define o ponteiro do mouse como seta.

Return(.T.)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Tk271Bonus³ Autor ³Fabio Rogerio Pereira  ³ Data ³20.06.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de tratamento da regra de bonificacao para interface ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo avaliar a regra de bonificacao³±±
±±³          ³e adicionar na respectiva interface                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Call Center						                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function bTk271Bonus()

	Local aArea     := GetArea()
	Local nLinha    := 0
	Local nUsado    := Len(aHeader)
	Local nPProd    := aPosicoes[1][2]
	Local nPQuant   := aPosicoes[4][2]
	Local nPTES		:= aPosicoes[11][2]

	// Essa funcao deixa a linha do aCols como deletada
	// FtDelBonus(aCols,{nPProd,nPQuant,nPTES,nUsado+1})

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

	RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk271CalcValores ³ Autor ³ Marcelo Kotaki       ³ Data ³ 28/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula o valor dos campos de desconto e acrescimo           	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tk271CalcDesc(ExpN1,ExpC1)									  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 = Tipo(1=% 2=Valor), ExpN1 = Valor/Percentual  	    		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³TMKA271													    					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³28/12/01³609   ³-Revisao total do fonte                       	  ³±±
±±³          ³        ³      ³                                              	  ³±±
±±³          ³        ³      ³                                              	  ³±±
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
±±³Uso		 ³TMKA271											          			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function bTK271Posto(cCodOper,cCampo)

	Local xRet
	Local aArea:= GetArea()
	Local cPosto:= CRIAVAR("U7_POSTO",.F.)

	cPosto:= Posicione("SU7",1,xFilial("SU7") + cCodOper,"U7_POSTO")
	cPosto:= IIf(Empty(cPosto),GetMV("MV_POSTO"),cPosto)

	xRet  := Posicione("SU0",1,xFilial("SU0") + cPosto,cCampo)

	RestArea( aArea )

Return(xRet)


/*
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
*/
Static Function bTk271Trigger(cCampo,nTrigger)

	Local lRet		:= .T.
	Local aArea 	:= GetArea()
	Local nPosCpo	:= Ascan(aHeader,{|x| x[2]=cCampo})
	Local nSavN		:= n
	Local aSavCols  := AClone(aCols)

	If nTrigger != nil
		n := nTrigger
	EndIf

	If nPosCpo > 0
		For nx	:= 1 to Len(aHeader)
			M->&(AllTrim(aHeader[nx][2])) := aCols[n][nx]
		Next
		If &(aHeader[nPosCpo][6])
			If MaFisFound("NF")

				Eval(bRefresh)
				oFoldRodape:Refresh()

			EndIf
		Else
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf

	If nTrigger != nil
		n := nSavN
	EndIf

	aCols:= AClone(aSavCols)
	RestArea(aArea)

Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OrdCols   ³ Autor ³ Jorge Oliveira        ³ Data ³28/01/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ordena o aCols, conforme a coluna onde deu o Click          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso	    ³ SIGATMK						          			          		   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OrdCols( nColAten )

	Local aFirst[1][ Len( aHeader ) + 1 ]

	aCols := aClone( aFirst )

	// Colunas: "Bolinha", "Or‡amento", "Data", "Vendedor", "Opera‡„o", "Contato", "Pedido"
   If nColAten >= 2 .And. nColAten <= 7

		// Ordena o array das ligacoes conforme a coluna selecionada
		If nColAten == 3

			// O primeiro click sempre serah ordenado do maior ao menor
			If lMaior
				aSort( aLigacoes,,, { |x,y| CtoD( x[ nColAten ] ) > CtoD( y[ nColAten ] ) } )
			Else
				aSort( aLigacoes,,, { |x,y| CtoD( x[ nColAten ] ) < CtoD( y[ nColAten ] ) } )
			EndIf

		Else

			// O primeiro click sempre serah ordenado do maior ao menor
			If lMaior
				aSort( aLigacoes,,, { |x,y| x[ nColAten ] > y[ nColAten ] } )
			Else
				aSort( aLigacoes,,, { |x,y| x[ nColAten ] < y[ nColAten ] } )
			EndIf

		EndIf

		// Inverte a ordenacao para o proximo click
		lMaior := !lMaior

		oLbx:SetArray(aLigacoes)
		oLbx:bLine:={||{	aLigacoes[oLbx:nAt,1],;
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
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pega o primeiro Nr do Atendimento e monta o acols com os itens da ligacao selecionada.			   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		N := 1
		oLbx:nAt := N

		bTkCargaItem(@cObsMemo,@cCancMemo,oObsMemo,oCancMemo,oGetHist,aLigacoes[oLbx:nAt,2],aLigacoes[oLbx:nAt,18],aLigacoes[oLbx:nAt,19] )

		oLbx:Refresh()
		oLbx:SetFocus(.T.)

   EndIf

Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TkStatus  ³ Autor ³Luis Marcelo Kotaki    ³ Data ³21/07/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Busca o status do pedido selecionado                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso	    ³ SIGATMK						          			          		   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function BTkStatus(cCampo,cOper)

	Local cDesc := " "
	Do case
		case AllTrim(cCampo) == "NF." .AND. AllTrim(cOper) == "1"
			cDesc := OemToAnsi("NF.Emitida")
		case AllTrim(cCampo) == "SUP" .AND. AllTrim(cOper) == "1"
			cDesc := OemToAnsi("Ped. Bloq.")
		case AllTrim(cCampo) == "CAN"
			cDesc := OemToAnsi("Cancelado ")
		case AllTrim(cCampo) == "LIB"
			cDesc := OemToAnsi("Liberado  ")
			other
			cDesc := OemToAnsi("Or‡amento")
	Endcase

Return(cDesc)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk271Config³ Autor ³ Fabio Rogerio Pereira³ Data ³ 29.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta ACOLS e AHEADER conforme o alias passado			     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk271Config(ExpC1,ExpN1,ExpC2,ExpF1)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Alias selecionado								  			  ³±±
±±³          ³ ExpN1 := Numero do Folder								  			  ³±±
±±³          ³ ExpC2 := Campos que nao devem aparecer na Getdados		     ³±±
±±³          ³ ExpF1 := Flag que indica qual array sera selecionado		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TMKA271													  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function bTk271Config(cAlias,cString,cNumTmk,cNumTlv,cNumTlc)

	Local nUsado		:= Len( aHeader )
	Local nCnt			:= 0 	//Qtde. registros
	Local nPProd		:= 0
	Local nPDescPro	:= 0
	Local I				:= 0
	Local nP_Alias		:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_ALI_WT"} )
	Local nP_Recno		:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_REC_WT"} )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aHeader a partir dos campos do SX3         	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCampos:= {}
	DbSelectArea("SX3")
	DbSetorder(1)
	DbSeek(cAlias)
	While !EOF() .AND. (X3_ARQUIVO == cAlias)
		If X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL .AND. (! TRIM(SX3->X3_CAMPO) $ cString )
			Aadd(aCampos,ALLTRIM(X3_CAMPO))
		Endif
		SX3->(DbSkip())
	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica posicao relativa dos campos do SUB/SUD na GetDados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aPosicoesV,{"UB_PRODUTO"   ,Ascan(aCampos,"UB_PRODUTO")})	//01
	AADD(aPosicoesV,{"UB_DESCRI"    ,Ascan(aCampos,"UB_DESCRI")})		//02
	AADD(aPosicoesV,{"UB_SITPROD"   ,Ascan(aCampos,"UB_SITPROD")})	//03
	AADD(aPosicoesV,{"UB_QUANT"     ,Ascan(aCampos,"UB_QUANT")})		//04
	AADD(aPosicoesV,{"UB_VRUNIT"    ,Ascan(aCampos,"UB_VRUNIT")})		//05
	AADD(aPosicoesV,{"UB_VLRITEM"   ,Ascan(aCampos,"UB_VLRITEM")})	//06
	AADD(aPosicoesV,{"UB_LOCAL"     ,Ascan(aCampos,"UB_LOCAL")})		//07
	AADD(aPosicoesV,{"UB_UM"        ,Ascan(aCampos,"UB_UM")})	  		//08
	AADD(aPosicoesV,{"UB_DESC"    	,Ascan(aCampos,"UB_DESC")})  		//09
	AADD(aPosicoesV,{"UB_VALDESC"   ,Ascan(aCampos,"UB_VALDESC")})	//10
	AADD(aPosicoesV,{"UB_TES"  	  	,Ascan(aCampos,"UB_TES")})			//11
	AADD(aPosicoesV,{"UB_CF"  	 		,Ascan(aCampos,"UB_CF")})	  		//12
	AADD(aPosicoesV,{"UB_ACRE"  		,Ascan(aCampos,"UB_ACRE")})		//13
	AADD(aPosicoesV,{"UB_VALACRE"   ,Ascan(aCampos,"UB_VALACRE")})	//14
	AADD(aPosicoesV,{"UB_PRCTAB"  	,Ascan(aCampos,"UB_PRCTAB")})		//15
	AADD(aPosicoesV,{"UB_DTENTRE" 	,Ascan(aCampos,"UB_DTENTRE")})	//16
	AADD(aPosicoesV,{"UB_LOTE"      ,Ascan(aCampos,"UB_LOTE")})   	//17
	AADD(aPosicoesV,{"UB_SUBLOTE"   ,Ascan(aCampos,"UB_SUBLOTE")})	//18
	AADD(aPosicoesV,{"UB_DTVALID"   ,Ascan(aCampos,"UB_DTVALID")})	//19
	// Jorge Oliveira - 26/01/2011 - Incluido mais um campo
	AADD(aPosicoesV,{"UB_ITEM"      ,Ascan(aCampos,"UB_ITEM")})		//20

	aPosicoes := Aclone(aPosicoesV)
	nPProd    := aPosicoes[1][2]
	nPDescPro := aPosicoes[2][2]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso nao seja inclusao carrega os registros das base para a getdados            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nCnt := 0

	__aItDigPrd := {}

	DbSelectArea("SUB")
	DbSetorder(1)
	DbGoTop()
	DbSeek( xFilial("SUB") + cNumTlv )
	While !EOF() .AND. (SUB->UB_FILIAL+SUB->UB_NUM == xFilial("SUB")+cNumTlv)

		nCnt++
		For nX := 1 to Len(aHeader)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ignora esses campos visuais          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( aHeader[nP_Alias][2] == "UB_ALI_WT" .Or. aHeader[nP_Recno][2] == "UB_REC_WT" )
				Loop
			EndIf

			If (aHeader[nX][10] <> "V" .AND. aHeader[nX][08] <> "M")
				aCols[Len(aCols)][nX] := FieldGet(FieldPos(aHeader[nX][2]))
			Else
				If (aHeader[nX][08] <> "M")
					aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2],.T.)
				Else
					aCols[Len(aCols)][nX] := FieldGet(FieldPos(aHeader[nX][2]))
				Endif
			Endif

		Next nX


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza dados especificos do aCols  			     	 	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nAcreCond  := 1+(Posicione("SE4",1,xFilial("SE4")+M->UA_CONDPG,"E4_ACRSFIN")/100)
		nP_Email   := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_EMAIL"} )
		nP_Prod    := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_PRODUTO"} )
		nP_QTDA    := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_QUANT"} )
		nP_TES     := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_TES"} )
		nP_SeqId   := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_SEQID"} )
		nP_VRUNIT  := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VRUNIT"} )
		nP_VLIT    := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VLRITEM"} ) // VALOR TOTAL
		nP_PRTB    := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_PRCTAB"} )
		nP_PRTB2   := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_PRCTAB2"} )
		nP_BICM    := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_BASEICM"} )
		nP_QOFER   := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_QOFERT"} )
		nP_VLOFER  := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VOFERT"} )
		nP_FLAG    := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_FLAGOFE"} )
		nP_FLAGCON := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_FLAGCON"} )
		nP_DTOFER  := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_DTOFERT"} )
		nP_HROFER  := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_HROFERT"} )
		nP_DESC    := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_DESC"} )
		nP_DESC2   := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_DESC2"} )
		nP_VALDESC := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VALDESC"} )
		nP_ACRE    := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_ACRE"} )
		nP_ACRE2   := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_ACRE2"} )
		nP_VALACRE := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VALACRE"} )
		nP_DESCICM := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_DESCICM"} )
		nP_VDESICM := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VDESICM"} )
		nP_VRCCAMP := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VRCCAMP"} )
		nP_FILTRAN := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_FILTRAN"} )
		nP_PLANILH := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_PLANILH"} )
		nP_PLITEM  := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_PLITEM"} )
		nP_VRCACRE := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VRCACRE"} )  //Prc.c/ Acres
		nP_ACREIPI := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_ACREIPI"} )  //Preco c/ IPI
		nP_VALIPI  := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VALIPI"} )   // VALOR DO IPI
		nP_DATA    := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_DTNECLI"} )
		nP_HORA    := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_HRNECLI"} )
		nP_TPCUST  := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_TPCUST"} )

		//VERIFICA SE O ORCAMENTO COPIADO ESTA VENCIDO (vencimento dos preços acertados).
		lOrcVencido 	:= .T.//(DDATABASE >  M->UA_DTLIM )
		lDesNegVencido	:= .T. //DDATABASE > (SUA->UA_EMISSAO + X_DESCNEG)  //ENTRE(SUA->UA_EMISSAO,(SUA->UA_EMISSAO + X_DESCNEG), DDATABASE)  // Descontos Negociados vencem em 30 dias

		// Array com a amarracao produtoxcampanha para posterior gravacao da tabela ZZI
		__aProdCamp := {}

		I := Len( aCols )
		n := I
		oGetTlv:oBrowse:nAt := N

		//**************************
		//Projeto F11 - Usado para armazenar o estado anterior dos produtos para quando os mesmos forem alterados
		// possa ser detectado
		AADD(__aItDigPrd,{I , SUB->UB_PRODUTO , M->UB_LOCAL })

		ACOLS[I,nP_Email]   := "N"
		M->UB_EMAIL := ACOLS[I,nP_Email]
		GDFieldPut( 'UB_EMAIL', ACOLS[I,nP_Email], I )

		ACOLS[I,nP_DATA]    := DDATABASE
		M->UB_DTNECLI := ACOLS[I,nP_Email]
		GDFieldPut( 'UB_DTNECLI', ACOLS[I,nP_DATA], I )

		ACOLS[I,nP_HORA]    := STRZERO(VAL(SUBSTR(TIME(),1,2))+1,2)+SUBSTR(TIME(),4,2)//SPACE(LEN(SUB->UB_HRNECLI))
		M->UB_HRNECLI := ACOLS[I,nP_HORA]
		GDFieldPut( 'UB_HRNECLI', ACOLS[I,nP_HORA], I )

		SB1->(dbSeek(xFilial('SB1')+SUB->UB_PRODUTO))

		ACOLS[I,nP_Prod]    := SUB->UB_PRODUTO
		M->UB_PRODUTO := ACOLS[I,nP_Prod]
		GDFieldPut( 'UB_PRODUTO', ACOLS[I,nP_Prod], I )

		ACOLS[I,nP_ACREIPI] := SUB->UB_VRCACRE //Preco c/ IPI
		M->UB_VRCACRE := ACOLS[I,nP_ACREIPI]
		GDFieldPut( 'UB_VRCACRE', ACOLS[I,nP_ACREIPI], I )

		ACOLS[I,nP_QTDA]    := SUB->UB_QUANT
		M->UB_QUANT := ACOLS[I,nP_QTDA]
		GDFieldPut( 'UB_QUANT', ACOLS[I,nP_QTDA], I )

		ACOLS[I,nP_TES]     := SUB->UB_TES
		M->UB_TES := ACOLS[I,nP_TES]
		GDFieldPut( 'UB_TES', ACOLS[I,nP_TES], I )

		ACOLS[I,nP_VALIPI]  := 	SB1->B1_IPI  // VALOR DO IPI
		M->UB_ALIQIPI := ACOLS[I,nP_VALIPI]
		GDFieldPut( 'UB_VALIPI', ACOLS[I,nP_VALIPI], I )

		ACOLS[I,nP_QOFER]   := 0
		M->UB_QOFERT := ACOLS[I,nP_QOFER]
		GDFieldPut( 'UB_QOFERT', ACOLS[I,nP_QOFER], I )

		ACOLS[I,nP_VLOFER]  := 0
		M->UB_VOFERT := ACOLS[I,nP_VLOFER]
		GDFieldPut( 'UB_VOFERT', ACOLS[I,nP_VLOFER], I )

		ACOLS[I,nP_FLAG]    := " "
		M->UB_FLAGOFE := ACOLS[I,nP_FLAG]
		GDFieldPut( 'UB_FLAGOFE', ACOLS[I,nP_FLAG], I )

		ACOLS[I,nP_FLAGCON] := " "
		M->UB_FLAGCON := ACOLS[I,nP_FLAGCON]
		GDFieldPut( 'UB_FLAGCON', ACOLS[I,nP_FLAGCON], I )

		ACOLS[I,nP_DTOFER]  := CTOD("")
		M->UB_DTOFERT := ACOLS[I,nP_DTOFER]
		GDFieldPut( 'UB_DTOFERT', ACOLS[I,nP_DTOFER], I )

		ACOLS[I,nP_HROFER]  := SPACE(LEN(SUB->UB_HROFERT))
		M->UB_HROFERT := ACOLS[I,nP_HROFER]
		GDFieldPut( 'UB_HROFERT', ACOLS[I,nP_HROFER], I )

		ACOLS[I,nP_FILTRAN] := SUB->UB_FILTRAN
		M->UB_FILTRAN := ACOLS[I,nP_FILTRAN]
		GDFieldPut( 'UB_FILTRAN', ACOLS[I,nP_FILTRAN], I )

		ACOLS[I,nP_PLANILH] := SUB->UB_PLANILH
		M->UB_PLANILH := ACOLS[I,nP_PLANILH]
		GDFieldPut( 'UB_PLANILH', ACOLS[I,nP_PLANILH], I )

		ACOLS[I,nP_PLITEM]  := SUB->UB_PLITEM
		M->UB_PLITEM := ACOLS[I,nP_PLITEM]
		GDFieldPut( 'UB_PLITEM', ACOLS[I,nP_PLITEM], I )

		ACOLS[I,nP_SeqId ]  := 0
		M->UB_SEQID := ACOLS[I,nP_SeqId ]
		GDFieldPut( 'UB_SEQID', ACOLS[I,nP_SeqId], I )

		ACOLS[I,nP_TPCUST]  := IIF( Empty( SUB->UB_TPCUST ), "R", SUB->UB_TPCUST )
		M->UB_TPCUST := ACOLS[I,nP_TPCUST]
		GDFieldPut( 'UB_TPCUST', ACOLS[I,nP_TPCUST], I )

		nPrcTabAtu := SUA->( MaTabPrVen(M->UA_TABELA,ACOLS[I,nP_Prod],ACOLS[I,nP_QTDA],M->UA_CLIENTE,M->UA_LOJA,M->UA_MOEDA) )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza preco do item se foi modificado o preco da Tabela de Preco³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPrcTabAtu != ACOLS[I,nP_PRTB2]
			ACOLS[I,nP_PRTB2] := nPrcTabAtu
			M->UB_PRCTAB2 := ACOLS[I,nP_PRTB2]
			GDFieldPut( 'UB_PRCTAB2', ACOLS[I,nP_PRTB2], I )
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Orcamento vencido           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF lOrcVencido
			ACOLS[I,nP_VRUNIT]  := nPrcTabAtu
			M->UB_VRUNIT := ACOLS[I,nP_VRUNIT]
			GDFieldPut( 'UB_VRUNIT', ACOLS[I,nP_VRUNIT], I )

			ACOLS[I,nP_PRTB]    := nPrcTabAtu
			M->UB_PRCTAB := ACOLS[I,nP_PRTB]
			GDFieldPut( 'UB_PRCTAB', ACOLS[I,nP_PRTB], I )

			ACOLS[I,nP_VLIT]    := (nPrcTabAtu * ACOLS[I,nP_QTDA])  // TOTAL  (QTD X VALOR)
			M->UB_VLRITEM := ACOLS[I,nP_VLIT]
			GDFieldPut( 'UB_VLRITEM', ACOLS[I,nP_VLIT], I )

			ACOLS[I,nP_BICM]    := ACOLS[I,nP_VLIT]
			M->UB_BASEICM := ACOLS[I,nP_BICM]
			GDFieldPut( 'UB_BASEICM', ACOLS[I,nP_BICM], I )

			IF lDesNegVencido
				ACOLS[I,nP_DESC]    	:= 0
				M->UB_DESC := ACOLS[I,nP_DESC]
				GDFieldPut( 'UB_DESC', ACOLS[I,nP_DESC], I )

				ACOLS[I,nP_DESC2]   	:= 0
				M->UB_DESC2 := ACOLS[I,nP_DESC2]
				GDFieldPut( 'UB_DESC2', ACOLS[I,nP_DESC2], I )

				ACOLS[I,nP_VALDESC] 	:= 0
				M->UB_VALDESC := ACOLS[I,nP_VALDESC]
				GDFieldPut( 'UB_VALDESC', ACOLS[I,nP_VALDESC], I )

				ACOLS[I,nP_ACRE]    	:= 0
				M->UB_ACRE := ACOLS[I,nP_ACRE]
				GDFieldPut( 'UB_ACRE', ACOLS[I,nP_ACRE], I )

				ACOLS[I,nP_ACRE2]   	:= 0
				M->UB_ACRE2 := ACOLS[I,nP_ACRE2]
				GDFieldPut( 'UB_ACRE2', ACOLS[I,nP_ACRE2], I )

				ACOLS[I,nP_VALACRE]	:= 0
				M->UB_VALACRE := ACOLS[I,nP_VALACRE]
				GDFieldPut( 'UB_VALACRE', ACOLS[I,nP_VALACRE], I )

				ACOLS[I,nP_DESCICM]	:= 0
				M->UB_DESCICM := ACOLS[I,nP_DESCICM]
				GDFieldPut( 'UB_DESCICM', ACOLS[I,nP_DESCICM], I )

				ACOLS[I,nP_VDESICM]	:= 0
				M->UB_VDESICM := ACOLS[I,nP_VDESICM]
				GDFieldPut( 'UB_VDESICM', ACOLS[I,nP_VDESICM], I )

				M->UA_DESCICM		 	:= 0	// zera o desconto de icm se o orcamento estiver vencido
			ENDIF
		ENDIF

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega as informacoes do PRODUTO para rodar a trigger          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		__ReadVar     := "M->UB_PRODUTO"
		M->UB_PRODUTO := ACOLS[I,nP_Prod]

		SX3->( Posicione( "SX3", 2, 'UB_PRODUTO', 'X3_CAMPO' ) )

		// Executa a trigger para preencher os outros campos da tela
		CheckSX3( "UB_PRODUTO", M->UB_PRODUTO )
	   RunTrigger(2,N,"",,'UB_PRODUTO')

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza descontos e acrescimos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		M->UB_VRUNIT := AtuVrUnit()
		u_AtuDesAcr()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza campo UB_VRCCAMP (Preco minimo de campanha de vendas)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		u_MsgCamp(ACOLS[I,nP_Prod],.T.,.F.,.F.,.T.,nAcreCond)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega a descricao do Produto      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aCols[nCnt][nPProd])
			DbSelectarea("SB1")
			DbSetorder(1)
			If !(DbSeek( xFilial("SB1")+aCols[nCnt][nPProd] ))
				Help(" ",1,"B1PROD" )
			Endif
			aCols[nCnt][nPDescPro] := SB1->B1_DESC
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza as informacoes na tela     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oGetTlv:oBrowse:Refresh()
		Eval(bRefresh)

		IncProc( "Carregando itens do Atendimento: " + cNumTlv )

		DbSelectArea("SUB")
		DbSkip()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o proximo registro da base for do mesmo Atendimento        ³
		//³entao cria mais uma linha no GetDados para ser alimentada.    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SUB->UB_FILIAL + SUB->UB_NUM == xFilial("SUB") + cNumTlv
			eVal( oGetTlv:obrowse:badd ) // Adiciona uma linha
			aCols[Len(aCols)][nUsado+1] := .F.
			N := Len( aCols )
			I := N
			oGetTlv:oBrowse:nAt := N // Aponte a linha que deve ficar posicionado
		EndIf
	Enddo

	// Jorge Oliveira - 18/02/2011 - Chamado: AAZTLV - Depois de carregar o aCols, deverah atualizar na tela as informacoes
	oGetTlv:SetArray( aCols )
	N := 1
	oGetTlv:oBrowse:nAt := N
	oGetTlv:oBrowse:Refresh()
	oGetTlv:Refresh()
	Eval(bRefresh)

	IncProc( "Carregando itens do Atendimento: " + cNumTlv )

	If MaFisFound()
		MaFisClear()
		MaColsToFis(aHeader,aCols,,"TK271",.T.)
	Endif

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AtuVrUnit  ³ Autor ³   Fabio Rogerio     ³ Data ³ 30/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o valor unitario do produto                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGATMK                                         			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AtuVrUnit()

	Local nVrUnit   := GdFieldGet("UB_VRUNIT" ,n)
	Local nPrcTab2  := GdFieldGet("UB_PRCTAB2",n)
	Local nPrcAcre  := GdFieldGet("UB_VRCACRE",n)
	Local nPDesc    := GdFieldGet("UB_DESC2"  ,n)
	Local nPAcre    := GdFieldGet("UB_ACRE2"  ,n)
	Local nPDesICM  := GdFieldGet("UB_DESCICM",n)
	Local nAcreCond := 1 + ( Posicione("SE4",1,xFilial("SE4")+M->UA_CONDPG,"E4_ACRSFIN") / 100 )  // Acrescimo Financeiro

	If  nPAcre > 0
		// Preco unitario (sem acrescimo financeiro) com acrescimo comercial
		nPrccAcrDescCom := A410Arred(nPrcTab2 * (1 + (nPAcre/ 100)),"UB_VRUNIT")

		// Preco unitario (sem acrescimo financeiro) com acrescimo comercial e com desconto de ICMS
		nPrccDesIcm := A410Arred(nPrccAcrDescCom * (1 - (nPDesICM / 100)),"UB_VRUNIT")

	ElseIf nPDesc > 0
		// Preco unitario (sem acrescimo financeiro) com desconto comercial
		nPrccAcrDescCom := A410Arred(nPrcTab2 * (1 - (nPDesc / 100)),"UB_VRUNIT")

		// Preco unitario (sem acrescimo financeiro) com desconto comercial e com desconto de ICMS
		nPrccDesIcm := A410Arred(nPrccAcrDescCom * (1 - (nPDesICM / 100)),"UB_VRUNIT")
	Else
		// Se nao existe acresimo nem desonto comercial, será igual ao preco de tabela
		// Preco unitario (sem acrescimo financeiro) com desconto comercial

		nPrccAcrDescCom := nPrcTab2

		// Preco unitario (sem acrescimo financeiro) com desconto comercial e com desconto de ICMS
		nPrccDesIcm := A410Arred(nPrccAcrDescCom * (1 - (nPDesICM / 100)),"UB_VRUNIT")
	EndIf

	// Preco unitario com desconto comercial, desconto de ICMS e acrescimo financeiro
	nPrcAcres := A410Arred(nPrccDesIcm * nAcreCond , "UB_VRUNIT" )

	// Atribui o valor do desconto ou acrescimo a variavel de memoria
	M->UB_VRUNIT := A410Arred(nPrcAcres / nAcreCond,"UB_VRUNIT")

	// Ajusta arredondamento
	nSimPrcAcres := A410Arred( M->UB_VRUNIT * nAcreCond ,"UB_VRUNIT" )
	nIncremento := IIF(nSimPrcAcres < nPrcAcres , 0.0001, -0.0001)
	lSitInic := (nSimPrcAcres < nPrcAcres)
	While ( nSimPrcAcres := A410Arred( M->UB_VRUNIT * nAcreCond ,"UB_VRUNIT") ) != nPrcAcres
		If lSitInic != (nSimPrcAcres < nPrcAcres)
			Exit
		Endif
		M->UB_VRUNIT += nIncremento
	EndDo

	nVrUnit := M->UB_VRUNIT

Return( nVrUnit )
