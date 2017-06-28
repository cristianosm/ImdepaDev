#Include "Totvs.ch"
#Include "Tbiconn.ch"

#Define SIM "S"
#Define NAO "N"

#Define TODAS "T"
#Define ATUAL "A"
/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : SM_ASeqAut.prw | AUTOR : Cristiano Machado | DATA : 27/04/2017**
**---------------------------------------------------------------------------**
** DESCRIÇÃO: Ajusta Numeração License para as Tabelas Conforme Parametros   **
**---------------------------------------------------------------------------**
** USO : Especifico para Imdepa  **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
** ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. **
**---------------------------------------------------------------------------**
** PROGRAMADOR | DATA | MOTIVO DA ALTERACAO **
**---------------------------------------------------------------------------**
**   |  | **
**   |  | **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User Function SM_ASeqAut()
*******************************************************************************
	Local lChangEnv   := .F.
	// Parametros
	Private cTAlias   := ""//MV_PAR01 := Alias da Tabela
	Private cCpoSeq   := ""//MV_PAR02 := Campo Sequencialsen
	Private cAllFil   := "" //MV_PAR03 := Filial Corrente ou Todas
	Private cFilSql   := ""//MV_PAR04 := Fltro Adicional Formato SQL
	Private AreaAtu   := GetArea()
	Private AreaSx3   := SX3->(GetArea())
	Private AreaSx2   := SX2->(GetArea())
	//
	Private cNewSeq	    := ""
	Private aFiliais    := {}
	Private cBkpFil     := cFilAnt

	Pergunte("ASEQAU",.T.)
	lPerg  := .T. 
	

		cTAlias   := Alltrim(MV_PAR01) //MV_PAR01 := Alias da Tabela
		cCpoSeq   := Alltrim(MV_PAR02) //MV_PAR02 := Campo Sequencialsen
		cAllFil   := If(MV_PAR03==1,TODAS,ATUAL) //MV_PAR03 := Filial Corrente ou Todas
		cFilSql   := Alltrim(MV_PAR04) //MV_PAR04 := Fltro Adicional Formato SQL

		VerFiliais(@aFiliais)

		For nF:= 1 To Len(aFiliais)
		
			If cAllFil == TODAS //MV_PAR03 := Filial Corrente ou Todas
				lSet := .T. //RpcSetEnv("01",aFiliais[nF],cEnvUser := Nil,cEnvPass := Nil,cEnvMod := Nil,cFunName := Nil,aTables := Nil,lShowFinal := .F.,lAbend := Nil,lOpenSX := .F.,lConnect := .F. )
				lChangEnv := .T.
			Else
				lSet := .T.
			EndIf
			
			If lSet
				cFilAnt := aFiliais[nF]

				If VerNewDOC(@cNewSeq)

					SetNewDoc(@cNewSeq)
				Else
					IW_MsgBox("Nao Ajustado, não foi identificado Registros para esta Filial:"+cFilAnt+" e Tabela: "+cTAlias,"Sem Registros !","INFO" )
				EndIf

			Else

				ConOut("Nao Ajustado, não foi possivel Setar a Filial [ "+aFiliais[nF]+" ]' no RpcSetEnv()' ")

			EndIf

		Next
		If lChangEnv
			//RpcSetEnv("01",cBkpFil,cEnvUser := Nil,cEnvPass := Nil,cEnvMod := Nil,cFunName := Nil,aTables := Nil,lShowFinal := .F.,lAbend := Nil,lOpenSX := .F.,lConnect := .F. )
			cFilAnt := cBkpFil
		EndIf
	

	RestArea(AreaSx2)
	RestArea(AreaSx3)
	RestArea(AreaAtu)

	Iw_MsgBox("Fim do Processo")

	Return()
*******************************************************************************
Static Function SetNewDoc(cNewSeq)
*******************************************************************************
	Local cSpecialKey := Upper( GetSrvProfString("SpecialKey", ""))
	Local cAliasSx8   := PadR( xFilial(cTAlias) + Upper( x2path(cTAlias)), 50 )

	Local cChaveSx 	  := cSpecialKey+cAliasSX8+cTAlias
	Local cNum		  := ""
	Local nRet		  := 0

	ConOut(" Maior DOC encontrado na Filial [" + xFilial(cTAlias) +"] => "+ cNewSeq )

	cNum := LS_GetNum(cChaveSx) 				; ConOut( " DOC Atual : "+cValToChar( cNum ) )
	//nRet := LS_ConfirmNum(cChaveSx, cNum ) 	; ConOut( " Confirmando DOC : " + If(cValToChar(nRet)=="0","Ok","Erro"))
	If cNum < cNewSeq

		If IW_MsgBox("Sequencia : [ "+cNum+" ] -->> [ "+cNewSeq+" ] . Tabela -> "+cTAlias+" Filial -> "+cFilAnt+" ","Confirma a Alteracao ?","YESNO" )

			LS_ChangeFreeNum(cChaveSx, cNewSeq )	;ConOut( " Alterando DOC para " + cNewSeq )

			cNum := LS_GetNum(cChaveSx)				; ConOut(" Proximo DOC : "+ cValToChar( cNum ) )
			nRet := LS_ConfirmNum(cChaveSx, cNum ) 	; ConOut(" Confirmando DOC : " + If(cValToChar(nRet)=="0","Ok","Erro"))
		EndIf
	Else
	
		IW_MsgBox("Sequencia Correta: [ "+cNum+" ]. Tabela -> "+cTAlias+" Filial -> "+cFilAnt+" ","Não Precisa Alterar !","INFO" )

	EndIf

	Return Nil
*******************************************************************************
Static Function VerNewDOC(cNewSeq) // Obtem novo Sequencia
*******************************************************************************

	Local cSql 		:= ""
	Local cTabela 	:= RetSqlName(cTalias)
	Local lRet    	:= .T.

	
	cSql := "SELECT NVL(MAX("+cCpoSeq+"),'0') NUM FROM "+cTabela+" WHERE "+Substr(cCpoSeq,1,AT("_",cCpoSeq))+"FILIAL = '"+xFilial(cTalias)+"' AND D_E_L_E_T_ = ' ' "
	If !Empty(cFilSql)
		cSql += "AND " + Alltrim(cFilSql)
	EndIf

	VarInfo('cSql',cSql)

	U_ExecMySql( cSql , "TSEQ" , "Q", .F., .F. )

	DbSelectArea("TSEQ");DbGotop()
	If !EOF()
		cNewSeq := Alltrim(TSEQ->NUM)
		If cNewSeq == "0"
			lRet := .F.
		EndIf
	Else
		cNewSeq := "0"
		lRet := .F.
	EndIf
	DbSelectArea("TSEQ");DbCloseArea()

	Return(lRet)
*******************************************************************************
Static Function VerFiliais(aFiliais)// Verifica Filiais...
*******************************************************************************
	local cCouE := "C"

	cCouE	 	:= Posicione("SX2", 1, cTAlias, "X2_MODO" )

	If cAllFil == TODAS

		If cCouE == "C" // Compartilhado

			aFiliais := {"01"}
		Else // Exclusivo
			aFiliais := FWAllFilial( Nil, Nil, "01",.T.)

		EndIf

	Else
		aFiliais := { cFilAnt }
	EndIf

	VarInfo('aFiliais',aFiliais)

Return()