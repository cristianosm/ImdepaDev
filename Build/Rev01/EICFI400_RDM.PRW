#INCLUDE "AVERAGE.CH"
#INCLUDE "TOPCONN.CH"

//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa Rolamentos
//|Funcao....: EICFI400_RDM()
//|Autor.....: Armando M. Urzum - armando@urzum.com.br
//|Data......: 29 de Agosto de 2009, 06:00
//|Uso.......: SIGAEIC
//|Versao....: Protheus - 8.11
//|Descricao.: Possibilidade de alterar o valor padrão para o campo "No Título" da tela de
//| geração de títulos no Contas a Pagar (Financeiro), ao gerar uma PA a partir da rotina
//| geração  de  PA. Caminho:  Atualizações->Financeiro->Geração de PA->Gera PA (depois de
//| selecionar  um  despachante)-> Gera  PA  (depois de selecionar o processo). Obs: Para
//| alterar o valor do campo use a variável private “cIniDocto”, ela contém o valor (por
//| padrão) do campo WD_DOCTO. Foi  disponibilizado no  programa EICFI400.PRW o ponto de
//| entrada  EICFI400 com o  parâmetro  FI400INIVALPA  que  possibilitarão  o  acesso  as
//| informações referente ao  Número de Pagamento Antecipado, Parcela, Tipo, Fornecedor
//| e Loja quando o mesmo é integrado ao Financeiro.
//|
//------------------------------------------------------------------------------------//
*----------------------------------------------*
User Function EICFI400()
*----------------------------------------------*

	Local lPassou   := .F.
	Local cxTipotit := ""
	Local cSql      := ""



	// Cristiano MAchado... Correcao de ERRO de BUILD... ParamIxb vem diferente de C as vezes... CHAMADO TOTVS:TSMJE0
	If ValType(ParamIxb) <> 'C'
		Return()
	EndIf


	Do Case

	//+-----------------------------------------------------------------------------------//
	//|Parametro..: "FI400INCTIT"
	//|Descricao..: Para gravaÁ„o do NF das despesas do processo
	//+-----------------------------------------------------------------------------------//
	Case ParamIxb == "FI400INCTIT"
		M->E2_NUM := Iif(cOrigem == "SWB_AP100",M->E2_NUM,Alltrim(SW6->W6_HAWB))

	//+-----------------------------------------------------------------------------------//
	//|Parametro..: "ANTES_GRAVACAO_TIT"
	//|Descricao..: Antes da GravaÁ„o do Numero Titulo no Financeiro "INV", "NF, "PA" Inter
	//+-----------------------------------------------------------------------------------//
	Case ParamIxb == "ANTES_GRAVACAO_TIT"
		If cOperacao == "2"
			If cOrigem == "SWB_AP100"
				cIniDocto := Alltrim(SWA->WA_HAWB)
			ElseIf "SWD" $ cOrigem
				cIniDocto := Alltrim(SW6->W6_HAWB)
			ElseIf cOrigem = "SWB"
				cIniDocto := Alltrim(SW6->W6_HAWB)
				cSql := " SELECT MAX(E2_PARCELA) AS QTD FROM "
				cSql += RETSQLNAME("SE2")
				cSql += " WHERE E2_FILIAL = '"+xFilial("SE2")+"' AND D_E_L_E_T_ <> '*' "
				cSql += " AND E2_PREFIXO = 'EIC' AND E2_TIPO = '"+cTipo_Tit+"' AND E2_NUM = '"+cIniDocto+"' "
				cSql += " AND E2_FORNECE = '"+cCodFor+"' AND E2_LOJA = '"+cLojaFor+"' "
				Iif(Select("XXX") # 0,XXX->(dbCloseArea()),.T.)
				TcQuery cSql New Alias "XXX"
				XXX->(dbSelectArea("XXX"))
				XXX->(dbGoTop())

				cParcela := Iif(ValType(XXX->QTD) <> "C", Str(XXX->QTD), XXX->QTD)
				cParcela := Iif(Empty(cParcela),"0",Soma1(cParcela))
			EndIf

		EndIf

	//+-----------------------------------------------------------------------------------//
	//|Parametro..: "FI400INIVALPA"
	//|Descricao..: Inicial variavel de titulo PA ao Despachante no financeiro
	//+-----------------------------------------------------------------------------------//
	Case ParamIxb == "FI400INIVALPA"
		M->E2_NUM := Alltrim(SWD->WD_HAWB)

	//+-----------------------------------------------------------------------------------//
	//|Parametro..: "FI400ARRAY_BAIXA"
	//|Descricao..: Coloca o numero de cheque para baixa
	//+-----------------------------------------------------------------------------------//

	Case ParamIxb == "FI400ARRAY_BAIXA"

		nOpsi0 := aScan(aBaixa,{ |x|x[1] == "E2_TIPO"  })
		nOpsi1 := aScan(aBaixa,{ |x|x[1] == "AUTCHEQUE"  })
		If Alltrim(aBaixa[nOpsi0,2]) == "PA" .OR. Alltrim(aBaixa[nOpsi0,2]) == "INV"
			aBaixa[nOpsi1,2] := Alltrim(SWB->WB_HAWB)+Alltrim(SWB->WB_LINHA)
		EndIf

	/*
		nOpsi0 := aScan(aBaixa,{ |x|x[1] == "E2_TIPO"  })
		nOpsi1 := aScan(aBaixa,{ |x|x[1] == "AUTCHEQUE"  })
		nOpsi2 := aScan(aBaixa,{ |x|x[1] == "AUTBANCO"   })
		nOpsi3 := aScan(aBaixa,{ |x|x[1] == "AUTAGENCIA" })
		nOpsi4 := aScan(aBaixa,{ |x|x[1] == "AUTCONTA"   })
		If Alltrim(aBaixa[nOpsi0,2]) == "INV"
			aBaixa[nOpsi1,2] := Alltrim(SWB->WB_HAWB)+Alltrim(SWB->WB_LINHA)
			aBaixa[nOpsi2,2] := SWB->WB_BANCO
			aBaixa[nOpsi3,2] := SWB->WB_AGENCIA
			aBaixa[nOpsi4,2] := SWB->WB_CONTA
		EndIf
    */
	//+-----------------------------------------------------------------------------------//
	//|Parametro..: "FI400POS_PO_2"
	//|Descricao..: verifica se o titulo PA foi deletado
	//+-----------------------------------------------------------------------------------//
	//Case ParamIxb == "FI400POS_PO_2"

	EndCase

Return