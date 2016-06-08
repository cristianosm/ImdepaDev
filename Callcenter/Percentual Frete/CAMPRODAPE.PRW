#include "Protheus.ch"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CAMPRODAPE  ³ Autor ³CRISTIANO MACHADO   ³ Data ³ 31/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Adiciona Campos no Rodape da Tela da Verdade...            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CAMPRODAPE                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
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
