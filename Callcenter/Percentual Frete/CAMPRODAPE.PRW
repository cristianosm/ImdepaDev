#include "Protheus.ch"

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    � CAMPRODAPE  � Autor 矯RISTIANO MACHADO   � Data � 31/07/13 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri嘺o � Adiciona Campos no Rodape da Tela da Verdade...            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � CAMPRODAPE                                                 潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
/*/
*****************************************************************************
User Function CAMPRODAPE()
*****************************************************************************

	Local cPonto := PROCNAME(1)

	If cPonto == "U_TMKACTIVE" //| Criacao das Variavaies

		Public _nPosPeF := Len(aValores) + 1  //| Percentual Frete
		Public _nPosObC := Len(aValores) + 2  //| Obs Cliente

		aADD( aValores, 0  ) // Percentual Frete
		aADD( aValores,  "" ) // Obs Cliente

		@ 020,190  SAY "Perc. Frete" OF oFoldRodape:aDialogs[1] PIXEL SIZE 55,90
		@ 019,220  MSGET oPerFrete VAR aValores[_nPosPeF] Picture "@R 999.99 %" OF oFoldRodape:aDialogs[1] PIXEL When .F. SIZE 70,9

		@ 035,190  SAY "Obs Cliente" OF oFoldRodape:aDialogs[1] PIXEL SIZE 55,90
		@ 034,220  MSGET oObsCli VAR aValores[_nPosObC] Picture "@!" OF oFoldRodape:aDialogs[1] PIXEL  When .F. SIZE 250,9


	ElseIf cPonto == "U_TMKVCP" // Atualiza Variavel Percentual Frete

		nMerc := MaFisRet(  , "NF_TOTAL" )    //funcao para pegar o valor da venda (ja calculado os impostos)
		aValores[_nPosPeF] := Round( M->UA_FRETCAL / nMerc * 100 , 2 )

	ElseIf cPonto == "U_ALT_CLIENTE_SUA"

		If !M->UA_PROSPEC

			aValores[_nPosObC] := Posicione("SA1",1,XFILIAL("SA1")+__ClienteAtual,"A1_OBSVEND")

		EndIf

	Else
		Teste := 0

	EndIf

Return(.T.)
