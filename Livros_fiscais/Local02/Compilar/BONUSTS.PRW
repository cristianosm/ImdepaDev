#INCLUDE "Totvs.ch"

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
User Function Bonusts()
**********************************************************************
	Local aArea    		:= Getarea()
	Local cTesPadrao  	:= GetMv("MV_TESPADR",,"501")
	Local cTes			:= ""
	Local cLocalPadrao	:= SB1->B1_LOCPAD

	IF FUNNAME()=="TMKA271"
		IF PROCNAME(6)=='TK271HISTORICO' .OR. (PROCNAME(6) == "ACTIVATE" .AND. PROCNAME(7) != "U_F190QTD1") //PROCNAME(6) == "ACTIVATE"
			RestArea(aArea)
		Return()
		ENDIF
	ENDIF

	//| UB_TES
	cTes := aCols[ n, GDFieldPos( "UB_TES" ) ] //gdFieldGet("UB_TES",n)
	If Empty(cTes)
		cTes := cTesPadrao
	EndIf

	GdFieldPut("UB_TES",cTes, n)
//	aCols[ n, GDFieldPos( "UB_TES" ) ] := cTes
//	M->UB_TES := cTes

	//| UB_LOCAL
	If Len( __aItDigPrd) >= n
		cLocal := __aItDigPrd[n,3]
	Else
		cLocal :=  aCols[ n, GDFieldPos( "UB_LOCAL" ) ]
	EndIf

	If Empty(cLocal)
		cLocal := cLocalPadrao
	EndIf

	GdFieldPut("UB_LOCAL",cLocal, n)
	aCols[ n, GDFieldPos( "UB_LOCAL" ) ] := cLocal
	M->UB_LOCAL := cLocal


	Restarea(aArea)

Return( cTes )
