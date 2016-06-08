#INCLUDE "PROTHEUS.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FPARTES   º Autor ³ CRISTIANO MACHADO  º Data ³  25/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ DEVE SER IMPLEMENTADO NO PARAMETRO MV_BONUSTS.             º±±
±±º          ³ PARA NO CALL CENTER TRAZER A TES CONFORME TABELA ZA4       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8 IMDEPA - FISCAL                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

**********************************************************************
User Function FParTes(cPAR1,cPAR2)
**********************************************************************

	Local aArea    := Getarea()
	Local cTesPadrao  := GetMv("MV_TESPADR",,"501")

	IF FUNNAME()=="TMKA271"
		IF PROCNAME(6)=='TK271HISTORICO' .OR. (PROCNAME(6) == "ACTIVATE" .AND. PROCNAME(7) != "U_F190QTD1") //PROCNAME(6) == "ACTIVATE"
			RestArea(aArea)
		Return()
		ENDIF
	ENDIF


	Private cNota	 	:= cPar1
	Private cTipo		:= cPar2
	Private cTpCliFor	:= ""
	Private cfilImd		:= xFilial("SB1")
	Private cDestin		:= ""
	Private Classif		:= SB1->B1_POSIPI
	Private cTesOk		:= ""
	Private ltesok		:= .F.
	Private cTes			:= Space(03)

	If	Cnota=="S" .AND. lProspect
		cTpCliFor 	:= SUS->US_PESSOA
		cDestin		:= SUS->US_EST
		cSegmento 	:= substr(SUS->US_GRPSEG,3,1)
		ltesok		:= .T.
	ElseIf 	Cnota=="S"
		cTpCliFor 	:= SA1->A1_TIPO
		cDestin		:= SA1->A1_EST
		cSegmento 	:= substr(SA1->A1_GRPSEG,3,1)
		ltesok		:= .T.
	ElseIf 	Cnota=="E"
		cTpCliFor 	:= SA2->A2_TIPO
		cDestin		:= SA2->A2_EST
		cSegmento 	:= " "
		ltesok		:= .T.
	EndIf

	If ltesok
		cTes := SF4->(U_FSubTrib(cfilImd, cNota, cTipo, cTpCliFor, cDestin, Classif, cSegmento,1)) //fTestaClas()
	Endif

	If FUNNAME()=="TMKA271"      //Tratamento para preenchimento de TES Manual via Tela da Verdade , Exec Auto nao Executa
		If !Empty(M->UA_TESMANU) //Usuario definiu TES Manual, nao executa a TES Automatica
			cTes := M->UA_TESMANU
		ElseIf empty(cTes)
			cTes := cTesPadrao
		Endif
		gdfieldput("UB_TES",cTes)
	Endif

	Restarea(aArea)


Return(cTes)
