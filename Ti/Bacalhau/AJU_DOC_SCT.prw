#Include 'Protheus.ch'
#Include "Tbiconn.ch"

/*
Esta rotina transfere os DOC's que não possuem os 9 caracteres ... para um DOC de 9 caracteres...
Ex: CT_DOC "000014" -> "000000014"


*/
*******************************************************************************
User Function AJU_DOC_SCT()
*******************************************************************************	

Private nRegs 		:= 0
Private lShowSql 	:= .F.

	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "05" FUNNAME 'AJU_DOC_SCT'  TABLES 'SM0'

	conout("Inicio do Processo")

	VerDocER(@nRegs) // Verifica DOC's com menos de 9 Caracteres

	ProcRegs() // Remaneja os DOC's

	RESET ENVIRONMENT

Return Nil

*******************************************************************************
Static function ProcRegs()
*******************************************************************************

Local cDOC := ""
Local cSEQ := ""
Local nRAt := 1 

DbSelectArea("TSCT");DbGotop()
While !Eof()
	
	conout('Registro -> '+ Transform(nRAt, '@R 999,999') +" de "+ Transform(nRegs, '@R 999,999')+" ")
	
	cDOC := TSCT->CT_DOC
	
	// Ver DOC e SEQ a ser utilizado
	VerDOCSeq( TSCT->CT_FILIAL, @cDOC, @cSEQ )

	// Inclui Registro no DOC correpondente
	IncReg( cDOC, cSEQ )
	
	// Exclui Reg Antigo
	DelReg( TSCT->R_E_C_N_O_ )

	nRAt += 1 
	DbSelectArea("TSCT")
	DbSkip()

EndDo

	conout("Fim do Processo")

Return Nil
*******************************************************************************
Static Function DelReg( nR_E_C_N_O_ )
*******************************************************************************

Local cSql := "DELETE SCT010 Where R_E_C_N_O_ = "+cValToChar(nR_E_C_N_O_)+" "
conout(cSql)
U_ExecMySql( cSql , "" , "E", lShowSql, .F. )

Return
*******************************************************************************
Static Function IncReg( cDOC, cSEQ ) // Inclui o Registro Remanejado
*******************************************************************************

	conout("RecLock:  FILIAL: "+TSCT->CT_FILIAL+"  DOC.Old: "+TSCT->CT_DOC+" DOC.New: "+cDoc+"  SEQ.Old: "+TSCT->CT_SEQUEN+ " SEQ.New: "+cSEQ+" !")
	
	RecLock("SCT",.T.)
	SCT->CT_FILIAL  := TSCT->CT_FILIAL
	SCT->CT_DOC     := cDOC
	SCT->CT_SEQUEN  := cSEQ
	SCT->CT_DESCRI  := TSCT->CT_DESCRI
	SCT->CT_REGIAO  := TSCT->CT_REGIAO
	SCT->CT_CCUSTO  := TSCT->CT_CCUSTO
	SCT->CT_ITEMCC  := TSCT->CT_ITEMCC
	SCT->CT_VEND    := TSCT->CT_VEND
	SCT->CT_CIDADE  := TSCT->CT_CIDADE
	SCT->CT_MARCA   := TSCT->CT_MARCA
	SCT->CT_SEGMEN  := TSCT->CT_SEGMEN
	SCT->CT_DATA    := SToD(TSCT->CT_DATA)
	SCT->CT_TIPO    := TSCT->CT_TIPO
	SCT->CT_GRUPO   := TSCT->CT_GRUPO
	SCT->CT_PRODUTO := TSCT->CT_PRODUTO
	SCT->CT_QUANT   := TSCT->CT_QUANT
	SCT->CT_VALOR   := TSCT->CT_VALOR
	SCT->CT_MOEDA   := TSCT->CT_MOEDA
	SCT->CT_CLVL    := TSCT->CT_CLVL
	SCT->CT_MARGEM  := TSCT->CT_MARGEM
	SCT->CT_CLIENTE := TSCT->CT_CLIENTE 
	SCT->CT_LOJACLI := TSCT->CT_LOJACLI
	SCT->CT_GRPSEGT := TSCT->CT_GRPSEGT
	SCT->CT_MARCA3  := TSCT->CT_MARCA3
	SCT->CT_CATEGO  := TSCT->CT_CATEGO
	SCT->CT_ORIGER  := TSCT->CT_ORIGER
	SCT->CT_RELAUTO := TSCT->CT_RELAUTO
	SCT->CT_MARGVLR := TSCT->CT_MARGVLR
	MsUnlock()
	
Return
*******************************************************************************
Static Function VerDOCSeq(cCT_FILIAL, cCT_DOC, cCT_SEQUEN)
*******************************************************************************

Local nCT_DOC 	:= Val(Alltrim(cCT_DOC))
Local cSql 		:= ""

//Alert("nCT_DOC:"+cValToChar(nCT_DOC))

cCT_DOC 		:= StrZero(nCT_DOC,9)// Ajusta DOC de 8 ou menos caracteres para 9 caracteres. Ex: "000014" -> "000000014" 
cCT_SEQUEN 		:= "000"

While cCT_SEQUEN == "000"
	
	cSql := ""
	cSql += "SELECT NVL(MAX(CT_SEQUEN),'000') CT_SEQUEN FROM SCT010 WHERE CT_FILIAL = '"+cCT_FILIAL+"' AND CT_DOC = '"+cCT_DOC+"' " 

	U_ExecMySql( cSql , "VSEQ" , "Q", lShowSql, .F. )

	DbSelectArea("VSEQ");DbGotop()
	If !EOF()
		cCT_SEQUEN := VSEQ->CT_SEQUEN
	EndIf
	DbSelectArea("VSEQ");DbcloseArea()
	
	If cCT_SEQUEN == '000' 
		cCT_SEQUEN := '001'
	
	ElseIf cCT_SEQUEN == 'ZZZ'
		cCT_DOC	:= StrZero(nCT_DOC + 1,9) // Caso não haja sequencia disponivel no DOC Atual pula para o Proximo
		cCT_SEQUEN := '000' 
	Else
		cCT_SEQUEN := Soma1(cCT_SEQUEN)
	EndIf
	
EndDo

Return Nil
*******************************************************************************
Static function VerDocER(nRegs)
*******************************************************************************

Local cSql := ""

cSql += "SELECT CT_FILIAL,CT_DOC,CT_SEQUEN,CT_DESCRI,CT_REGIAO,CT_CCUSTO,CT_ITEMCC,CT_VEND,CT_CIDADE,CT_MARCA,CT_SEGMEN,CT_DATA,CT_TIPO,CT_GRUPO,CT_PRODUTO,CT_QUANT,CT_VALOR,CT_MOEDA,CT_CLVL,CT_MARGEM,CT_CLIENTE,CT_LOJACLI,CT_GRPSEGT,CT_MARCA3,CT_CATEGO,CT_ORIGER,CT_RELAUTO,CT_MARGVLR, R_E_C_N_O_ "
cSql += "FROM SCT010 WHERE R_E_C_N_O_ IN ( SELECT R_E_C_N_O_ RECNO FROM SCT010 WHERE D_E_L_E_T_ = ' ' AND LENGTH( RTRIM(CT_DOC)) < 9 
//cSql += " AND CT_FILIAL = '09' AND CT_DOC = '000014' " 
cSql += ") "

U_ExecMySql( cSql , "TSCT" , "Q", lShowSql, .F. )

cSql := "SELECT COUNT(R_E_C_N_O_) NRECNO FROM SCT010 WHERE D_E_L_E_T_ = ' ' AND LENGTH( RTRIM(CT_DOC)) < 9 "   

U_ExecMySql( cSql , "NREGS" , "Q", lShowSql, .F. )

conout("Contando registros...")
DbSelectArea("TSCT");DbGotop()
DbSelectArea("NREGS");DbGotop()
If !EOF()
	nRegs := NREGS->NRECNO
EndIf
DbSelectArea("NREGS");DbCloseArea()
Return Nil