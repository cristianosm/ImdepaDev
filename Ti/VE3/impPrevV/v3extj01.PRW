#include "protheus.ch"

USER FUNCTION V3ExtJ01(aParam)
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : ServiÁo de execuÁ„o das consultas autom·ticas
<Data> : 28/09/2016
<Parametros> : aParam {<cEmpresa>, <cFilial>, <aApelidos_arquivos>}
<Retorno> : Nenhum
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local cEmpPar	:= ""
Local cFilPar	:= ""
Local aAliases	:= {}

IF ValType(aParam) # "A"
	aParam	:= {"01", "01"}
ENDIF
IF Len(aParam) >= 1 .AND. ValType(aParam[1]) == "C"
	cEmpPar	:= aParam[1]
ENDIF
IF Len(aParam) >= 2 .AND. ValType(aParam[2]) == "C"
	cFilPar	:= aParam[2]
ENDIF
IF Len(aParam) >= 3 .AND. ValType(aParam[3]) == "A"
	aAliases	:= AClone(aParam[3])
ENDIF

VldEmp(@cEmpPar, @cFilPar)

RpcSetType(3)
RpcSetEnv(cEmpPar, cFilPar)
IF Select("SX2") > 0
	IF Len(aAliases) > 0
		U_VExtM01P(aAliases)
	ENDIF
	
	ExecAgen(aAliases)
	
	RpcClearEnv()
ENDIF

RETURN

USER FUNCTION VExtJ01N()
Return({Iif(IsSrvUnix(), "/ve3sem/", "\ve3sem\"), "v3extj01_" + cEmpAnt + ".lck"})

STATIC FUNCTION OkToGo(nHdlSem)
Local cFile		:= U_VExtJ01N()[1] + U_VExtJ01N()[2]
Local cUsuUsa	:= ""
Local lRet		:= .f.

MakeDir(U_VExtJ01N()[1])

IF !File(cFile)
	IF (nHdlSem := FCreate(cFile)) > 0
		FClose(nHdlSem)
	ENDIF
ENDIF
IF (nHdlSem := FOpen(cFile, 2 + 32)) > 0
	IF FWrite(nHdlSem, cUserName) # Len(cUserName)
		FRead(nHdlSem, @cUsuUsa, Len(cUserName))
		FClose(nHdlSem)
	ELSE
		MS_Flush()
		lRet	:= .t.
	ENDIF
ELSEIF (nHdlSem := FOpen(cFile, 0)) > 0
	FRead(nHdlSem, @cUsuUsa, Len(cUserName))
	FClose(nHdlSem)
ENDIF
IF !lRet
	IF Empty(Alltrim(cUsuUsa))
		cUsuUsa	:= "JOB"
	ENDIF
	Aviso("Uso Exclusivo", "A rotina de ExtraÁ„o de Dados est· sendo utilizada pelo usu·rio " + Alltrim(cUsuUsa) + " neste momento." + CRLF + CRLF + ;
		"Aguarde alguns minutos e tente novamente!", {"Fechar"}, 3)
ENDIF

Return(lRet)

STATIC FUNCTION ExecAgen(apAlia)
Local cQuery	:= ""
Local dData		:= Date()
Local cHora		:= Left(Time(), 5)
Local dNxtDay	:= Ctod("")
Local aHoras	:= {}
Local cNxtHr	:= ""
Local nExecs	:= 0
Local nI		:= 0
Local cHoraI	:= ""
Local nMin		:= 0
Local nHora		:= 0
Local nInterv	:= 0
Local nPosHr	:= 0
Local dDtIni	:= Ctod("")
Local nHdlSem	:= -1
Local aAliases	:= {}
Local cCons		:= U_VExtM01I("CONS")
Local cPreC		:= Iif(Left(cCons, 1) == "S", Substr(cCons, 2), cCons)
Local aSemana	:= {cPreC + "_DOMING", cPreC + "_SEGUND", cPreC + "_TERCA", cPreC + "_QUARTA", cPreC + "_QUINTA", cPreC + "_SEXTA", cPreC + "_SABADO"}
Local aMes		:= {"1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C"}

IF ValType(apAlia) == "A" .AND. Len(apAlia) > 0
	aAliases	:= AClone(apAlia)
ENDIF
IF OkToGo(@nHdlSem)
	WHILE !File(U_VExtJ01N()[1] + StrTran(U_VExtJ01N()[2], ".lck", ".sto"))
		Sleep(1000)
		dData		:= Date()
		cHora		:= Left(Time(), 5)
		
		cQuery := "SELECT " + cCons + ".R_E_C_N_O_ AS REG FROM " + RetSqlName(cCons) + " " + cCons + " "
		cQuery += "WHERE " + cCons + ".D_E_L_E_T_ = ' ' "
		cQuery += "AND " + cPreC + "_FILIAL = '" + xFilial(cCons) + "' "
		cQuery += "AND " + cPreC + "_MODOEX <> '1' "
		cQuery += "AND " + cPreC + "_DTINI <= '" + Dtos(dData) + "' "
		cQuery += "AND (" + cPreC + "_DTTERM = ' ' "
		cQuery += "OR " + cPreC + "_DTTERM >= '" + Dtos(dData) + "') "
		
		DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "TBZ0", .T., .F.)
		
		WHILE !TBZ0->(Eof())
			(cCons)->(DbGoTo(TBZ0->REG))
			
			lExec	:= .f.
			
			// Pega os hor·rios de execuÁ„o
			nExecs	:= Iif((cCons)->(FieldGet(FieldPos(cPreC + "_EXEDIA"))) == 0, 1, (cCons)->(FieldGet(FieldPos(cPreC + "_EXEDIA"))))
			cHoraI	:= (cCons)->(FieldGet(FieldPos(cPreC + "_HRINI")))
			nInterv	:= (Val(Left((cCons)->(FieldGet(FieldPos(cPreC + "_INTERV"))), 2)) * 60) + ;
						Val(Substr((cCons)->(FieldGet(FieldPos(cPreC + "_INTERV"))), 4))	// Intervalo em minutos
			FOR nI := 1 TO nExecs
				Aadd(aHoras, cHoraI)
				nMin	:= Val(Substr(cHoraI, 4)) + nInterv
				nHora	:= Int(nMin / 60) + Val(Left(cHoraI, 2))
				nMin	:= nMin % 60
				IF nHora > 24
					EXIT
				ENDIF
				cHoraI	:= StrZero(nHora, 2) + ":" + StrZero(nMin, 2)
			NEXT
			
			// Se nunca executei, executa se o dia for maior ou igual a data de inÌcio e a hora for maior que a hora de inÌcio
			// Sen„o executa se a data for maior ou igual a prÛxima e a hora for maior ou igual a prÛxima
			IF (Empty((cCons)->(FieldGet(FieldPos(cPreC + "_NXTDT")))) .AND. AScan(aHoras, {|z| z <= cHora}) > 0) .OR. ;
					((cCons)->(FieldGet(FieldPos(cPreC + "_NXTDT"))) <= dData .AND. (cCons)->(FieldGet(FieldPos(cPreC + "_NXTHR"))) <= cHora)
				dDtIni	:= Iif(Empty((cCons)->(FieldGet(FieldPos(cPreC + "_NXTDT")))), (cCons)->(FieldGet(FieldPos(cPreC + "_DTINI"))), ;
							(cCons)->(FieldGet(FieldPos(cPreC + "_NXTDT"))))
				IF Len(aAliases) == 0
					Aadd(aAliases, {"CONS", GetPvProfString("ALIAS_EXPORT_TOOL", "CONS", "*", U_VExtM01R())})
					Aadd(aAliases, {"PERM", GetPvProfString("ALIAS_EXPORT_TOOL", "PERM", "*", U_VExtM01R())})
					Aadd(aAliases, {"SXB1", GetPvProfString("ALIAS_EXPORT_TOOL", "SXB1", "*", U_VExtM01R())})
					Aadd(aAliases, {"SXB2", GetPvProfString("ALIAS_EXPORT_TOOL", "SXB2", "*", U_VExtM01R())})
					Aadd(aAliases, {"SXB3", GetPvProfString("ALIAS_EXPORT_TOOL", "SXB3", "*", U_VExtM01R())})
					Aadd(aAliases, {"SXB4", GetPvProfString("ALIAS_EXPORT_TOOL", "SXB4", "*", U_VExtM01R())})
				ENDIF
				
				// Executa consulta via JOB em nova inst‚ncia
				StartJob("U_VExtJ01J", GetEnvServer(), .F., {cEmpAnt, cFilAnt, (cCons)->(FieldGet(FieldPos(cPreC + "_CODIGO"))), AClone(aAliases)})
				
				// Calculo a prÛxima data e hor·rio
				// PrÛxima hora maior que a hora atual
				nPosHr	:= AScan(aHoras, {|z| z > cHora})
				
				IF nPosHr == 0	// N„o tem mais execuÁıes no dia
					IF (cCons)->(FieldGet(FieldPos(cPreC + "_PADRAO"))) == "1"	// Di·rio
						dNxtDay	:= dData + Iif((cCons)->(FieldGet(FieldPos(cPreC + "_QTSDIA"))) == -1, 1, (cCons)->(FieldGet(FieldPos(cPreC + "_QTSDIA"))))
					ELSEIF (cCons)->(FieldGet(FieldPos(cPreC + "_PADRAO"))) == "2"	// Semanal
						FOR nI := 1 TO 7
							IF &(cCons + "->" + aSemana[Dow(dData + nI)])
								dNxtDay	:= dData + nI
							ENDIF
						NEXT
					ELSEIF (cCons)->(FieldGet(FieldPos(cPreC + "_PADRAO"))) == "3"	// Mensal
						dNxtDay	:= LastDay(dData) + (cCons)->(FieldGet(FieldPos(cPreC + "_DIAMES")))
					ELSEIF (cCons)->(FieldGet(FieldPos(cPreC + "_PADRAO"))) == "4"	// Anual
						nI := 1
						WHILE Empty(dNxtDay)
							dNxtDay	:= Str(Val(Left(Dtos(dDtIni), 4)) + nI, 4) + ;
										StrZero(AScan(aMes, {|z| z == (cCons)->(FieldGet(FieldPos(cPreC + "_MES")))}), 2) + ;
										StrZero((cCons)->(FieldGet(FieldPos(cPreC + "_DIAMES"))), 2)
							nI++
						ENDDO
					ENDIF
					cNxtHr	:= aHoras[1]
				ELSE
					dNxtDay	:= dData
					cNxtHr	:= aHoras[nPosHr]
				ENDIF
				RecLock(cCons, .f.)
					(cCons)->(FieldPut(FieldPos(cPreC + "_NXTDT"), dNxtDay))
					(cCons)->(FieldPut(FieldPos(cPreC + "_NXTHR"), cNxtHr))
				MsUnlock()
			ENDIF
			
			TBZ0->(DbSkip())
		ENDDO
		TBZ0->(DbCloseArea())
	ENDDO
	FErase(U_VExtJ01N()[1] + StrTran(U_VExtJ01N()[2], ".lck", ".sto"))
	FClose(nHdlSem)
ENDIF
RETURN

USER FUNCTION VExtJ01J(aParam)
Local cEmpPar	:= aParam[1]
Local cFilPar	:= aParam[2]
Local cCodCon	:= aParam[3]
Local aAliases	:= AClone(aParam[4])
Local cCons		:= ""
Local cPreC		:= ""

RpcSetType(3)
RpcSetEnv(cEmpPar, cFilPar)
__cUserID	:= "000000"
IF Select("SX2") > 0
	U_VExtM01P(aAliases)
	
	cCons	:= U_VExtM01I("CONS")
	cPreC	:= Iif(Left(cCons, 1) == "S", Substr(cCons, 2), cCons)
	
	DbSelectArea(cCons)
	DbSetOrder(1)
	IF DbSeek(xFilial(cCons) + cCodCon, .f.)
		U_V3ExtA04((cCons)->(FieldGet(FieldPos(cPreC + "_SQL"))), .T.,, cCodCon)
	ENDIF
	
	RpcClearEnv()
ENDIF
RETURN

STATIC FUNCTION VldEmp(cEmpPar, cFilPar)
USE SIGAMAT.EMP INDEX SIGAMAT.IND ALIAS "SM0" SHARED NEW
SM0->(DbSetOrder(1))
IF !SM0->(DbSeek(cEmpPar + cFilPar, .F.))
	SM0->(DbGoTop())
	
	cEmpPar	:= SM0->M0_CODIGO
	cFilPar	:= SM0->M0_CODFIL
ENDIF
SM0->(DbCloseArea())
RETURN