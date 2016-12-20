#include "protheus.ch"

USER FUNCTION V3ExtA05()
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : Interface para chamada da arquivo de previs„o de vendas
<Data> : 28/09/2016
<Parametros> : Nenhum
<Retorno> : Nenhum
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : M
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local aParam	:= {}
Local nOpcGet	:= GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE
Local aRetPar	:= {}

Aadd(aParam, {6, "Arquivo de origem", Space(250),, "U_VExtA05V(1)",, 90, .T., "Todos .* |*.*", GetTempPath(), nOpcGet, .f.})

IF ParamBox(aParam, "Arquivo de origem", @aRetPar,,, .t.,,,,, .t., .t.)
	Processa({|| RunProc() })
ENDIF
RETURN

USER FUNCTION VExtA05J(aParam)
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : ServiÁo de execuÁ„o da carga de previs„o de vendas
<Data> : 28/09/2016
<Parametros> : aParam {<cEmpresa>, <cFilial>}
<Retorno> : Nenhum
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local cEmp	:= ""
Local cFil	:= ""
Local cPath	:= ""
Local aArqs	:= {}
Local nI	:= 0
Default aParam	:= {}

IF Len(aParam) < 2
	ConOut("V3EXTA05: Configuracao incorreta de parametros")
	RETURN
ELSE
	cEmp	:= aParam[1]
	cFil	:= aParam[2]
ENDIF

RpcSetType(3)
RpcSetEnv(cEmp, cFil)
IF Select("SX2") > 0
	ConOut("V3EXTA05: Ambiente montado corretamente (Empresa: " + cEmp + " Filial: " + cFil + ")")
	
	cPath	:= GetMv("V3_PATH051")
	aArqs	:= ASort(Directory(cPath),,, {|x, y| x[1] < y[1]})
	IF !File(Left(cPath, Rat(CmPt("\"), cPath)) + "lidos")
		MakeDir(Left(cPath, Rat(CmPt("\"), cPath)) + "lidos")
	ENDIF
	
	FOR nI := 1 TO Len(aArqs)
		RunProc(Left(cPath, Rat(CmPt("\"), cPath)) + aArqs[nI, 1])
		IF __CopyFile(Left(cPath, Rat(CmPt("\"), cPath)) + aArqs[nI, 1], Left(cPath, Rat(CmPt("\"), cPath)) + "lidos" + CmPt("\") + aArqs[nI, 1])
			FErase(Left(cPath, Rat(CmPt("\"), cPath)) + aArqs[nI, 1])
		ENDIF
	NEXT
	RpcClearEnv()
ELSE
	ConOut("V3EXTA05: Falha na montagem do ambiente (Empresa: " + cEmp + " Filial: " + cFil + ")")
ENDIF

RETURN

STATIC FUNCTION OkToGo(nHdlSem)
Local cFile		:= U_VExtJ01N()[1] + "v3exta05.sem"
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
	Aviso("Uso Exclusivo", "A rotina de ImportaÁ„o de Previs„o de Vendas est· sendo utilizada pelo usu·rio " + Alltrim(cUsuUsa) + " neste momento." + ;
		CRLF + CRLF + "Aguarde alguns minutos e tente novamente!", {"Fechar"}, 3)
ENDIF

Return(lRet)

STATIC FUNCTION RunProc(cArqOri)
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : ExecuÁ„o da carga do arquivo de previs„o de vendas
<Data> : 28/09/2016
<Parametros> : cArqOri - nome do arquivo de origem
<Retorno> : Nenhum
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local cDirRot	:= "\v3exta05"
Local cNmArq	:= ""
Local cSeqLog	:= "001"
Local nTotReg	:= 0
Local cLinha	:= ""
Local nHdlLog	:= 0
Local aCampos	:= {}
Local lRet		:= .t.
Local nHdlSem	:= -1
Local nPosPrd	:= 0
Local nPosData	:= 0
Local aDados	:= {}
Local nI		:= 0
Local dDtIni	:= Ctod("")
Local dDtFim	:= Ctod("")
Local nRegAtu	:= 1
Local nQtdTre	:= GetMv("V3_QTDTRA5",, 10)
Local aRegTre	:= {}
Local nRegPTrd	:= 0
Default cArqOri		:= "*"

IF cArqOri # "*"
	MV_PAR01	:= cArqOri
	ConOut("V3EXTA05: Carga arquivo '" + Alltrim(MV_PAR01) + "' (Empresa: " + cEmpAnt + " Filial: " + cFilAnt + ")")
ENDIF

// Arquivo de origem na m·quina local
cNmArq	:= Upper(Alltrim(Substr(MV_PAR01, Rat("\", MV_PAR01) + 1)))

IF !File(CmPt(cDirRot))	// Verifica se existe diretÛrio no servidor
	IF MakeDir(CmPt(cDirRot)) # 0
		lRet	:= .f.
		Aviso("DiretÛrio de trabalho", "N„o foi possÌvel criar o diretÛrio de trabalho '" + CmPt(cDirRot) + "' no servidor (" + Alltrim(Str(FError())) + ;
			").", {"Ok"})
	ENDIF
ENDIF

// Verifica diretÛrio LOG no servidor
IF lRet .AND. !File(CmPt(cDirRot + "\log"))
	IF MakeDir(CmPt(cDirRot + "\log")) # 0
		lRet	:= .f.
		Aviso("DiretÛrio de LOG", "N„o foi possÌvel criar o diretÛrio de trabalho '" + CmPt(cDirRot) + "' no servidor (" + Alltrim(Str(FError())) + ;
			").", {"Ok"})
	ENDIF
ENDIF

// Verifica diretÛrio de tabalho no servidor
IF lRet .AND. !File(CmPt(cDirRot + "\trb"))
	IF MakeDir(CmPt(cDirRot + "\trb")) # 0
		lRet	:= .f.
		Aviso("DiretÛrio de Trabalho", "N„o foi possÌvel criar o diretÛrio de trabalho '" + CmPt(cDirRot + "\trb") + "' no servidor (" + ;
			Alltrim(Str(FError())) + ").", {"Ok"})
	ENDIF
ENDIF

// Copia o arquivo para o diretÛrio do servidor
IF lRet .AND. File(CmPt(cDirRot + "\trb\" + cNmArq))
	IF FErase(CmPt(cDirRot + "\trb\" + cNmArq)) < 0
		Aviso("DiretÛrio de trabalho", "Existe arquivo com o mesmo nome no diretÛrio de trabalho no servidor e n„o foi possÌvel apag·-lo.", {"Fechar"})
		lRet	:= .f.
	ENDIF
ENDIF
IF lRet
	MsgRun("Copiando arquivo de origem para o servidor...",, {|| CpyT2S(Alltrim(MV_PAR01), CmPt(cDirRot + "\trb"))})
ENDIF

IF lRet .AND. (lRet := OkToGo(@nHdlSem))
	aCampos	:= GetCampos()
	lRet	:= Len(aCampos) > 0
	
	WHILE File(CmPt(cDirRot + "\log\" + cNmArq + cSeqLog + ".log")) .OR. !MayIUseCode(cNmArq + cSeqLog)
		cSeqLog	:= Soma1(cSeqLog)
	ENDDO
	
	// Abre o arquivo de origem
	Ft_FUse(MV_PAR01)
	
	nTotReg	:= Ft_FLastRec()
	
	// Se a quantidade de registros for menor que 2, n„o È possÌvel processar, pois n„o tem a quantidade mÌnima de registros
	IF nTotReg < 2
		Aviso("Sem registros", "O arquivo de origem n„o tem quantidade de registros suficientes para ser um arquivo v·lido de previs„o de vendas.", {"Ok"})
		lRet	:= .f.
	ELSE
		cLinha	:= StrTran(Ft_FReadLn(), CRLF)
		Ft_FSkip()
		nRegAtu++
	ENDIF
	FClose(nHdlSem)
ENDIF

IF lRet
	nHdlLog	:= FCreate(CmPt(cDirRot + "\log\" + cNmArq + cSeqLog + ".log"))
	IF nHdlLog < 0
		Aviso("Erro no arquivo de log", "Ocorreu erro na criaÁ„o do arquivo '" + cNmArq + cSeqLog + ".log'. (" + Alltrim(Str(FError())) + ")", {"Ok"})
		lRet	:= .f.
	ENDIF	
ENDIF

// Como j· foi criado o arquivo, posso liberar o nome reservado
FreeUsedCode()

IF lRet
	ProcRegua(nTotReg)
	
	// Verifica as definiÁıes de campos
	nPosPrd		:= AScan(aCampos, {|z| Alltrim(z[1]) == "C4_PRODUTO"})
	nPosData	:= AScan(aCampos, {|z| Alltrim(z[1]) == "C4_DATA"})
	IF nPosPrd == 0
		FWrite(nHdlLog, "ERRO: Campo C4_PRODUTO obrigatorio nao existe na estrutura" + CRLF)
		aDados	:= {}
		lRet	:= .f.
	ELSEIF nPosData == 0
		FWrite(nHdlLog, "ERRO: Campo C4_DATA obrigatorio nao existe na estrutura" + CRLF)
		aDados	:= {}
		lRet	:= .f.
	ENDIF
	
	cLinha	:= StrTran(Ft_FReadLn(), CRLF)
	aLinha	:= Separa(cLinha, ";")
	aDados	:= {}
	FOR nI := 1 TO Len(aCampos)
		IF Len(aLinha) < aCampos[nI, 2]
			FWrite(nHdlLog, "ERRO: n˙mero de coluna inv·lido para o campo " + aCampos[nI, 1] + CRLF)
			lRet	:= .f.
		ELSEIF (nI == nPosPrd .OR. nI == nPosData) .AND. Empty(TrataDd(aLinha[aCampos[nI, 2]], aCampos[nI, 1]))
			FWrite(nHdlLog, "ERRO: o campo " + aCampos[nI, 1] + " n„o pode estar vazio!" + CRLF)
			lRet	:= .f.
		ELSE
			IF nI == nPosData
				dDtIni	:= FirstDay(TrataDd(aLinha[aCampos[nI, 2]], aCampos[nI, 1]))
			ENDIF
			Aadd(aDados, {aCampos[nI, 1], TrataDd(aLinha[aCampos[nI, 2]], aCampos[nI, 1])})
		ENDIF
	NEXT
	IF lRet
		//Ft_FGoTo(nTotReg)
		WHILE nRegAtu < nTotReg
			Ft_FSkip()
			nRegAtu++
		ENDDO
		cLinha		:= StrTran(Ft_FReadLn(), CRLF)
		aLinha		:= Separa(cLinha, ";")
		dDtFim		:= LastDay(TrataDd(aLinha[aCampos[nPosData, 2]], aCampos[nPosData, 1]))
		nRegPTrd	:= NoRound((nTotReg - 1) / nQtdTre, 0)
		nRegAtu		:= 2
		
		IncProc("Apagando registros anteriores...")
		ProcessMessages()
		TcSqlExec("DELETE FROM " + RetSqlName("SC4") + " WHERE C4_FILIAL >= ' ' AND C4_PRODUTO >= ' ' AND C4_DATA BETWEEN '" + ;
			Dtos(dDtIni) + "' AND '" + Dtos(dDtFim) + "'")
			
		FOR nI := 1 TO nQtdTre
			Aadd(aRegTre, {nRegAtu, nRegAtu + nRegPTrd})
			nRegAtu	+= nRegPTrd + 1
		NEXT
		aRegTre[nQtdTre, 2]	:= nTotReg
		nRegBas				:= RegBas()
		IncProc("Iniciando as threads de carga do dados...")
		
		FOR nI := 1 TO nQtdTre
			StartJob("U_VExtA05T", GetEnvServer(), .F., {cEmpAnt, cFilAnt, nI, cNmArq, aRegTre[nI, 1], aRegTre[nI, 2], AClone(aCampos), nRegBas})
			//U_VExtA05T({cEmpAnt, cFilAnt, nI, cNmArq, aRegTre[nI, 1], aRegTre[nI, 2], AClone(aCampos), nRegBas})
		NEXT
	ENDIF
ENDIF
Ft_FUse()

IF nHdlLog > 0
	FClose(nHdlLog)
ENDIF
RETURN

STATIC FUNCTION RegBas()
Local nRet		:= 0
Local cQuery	:= ""
Local cAlias	:= Alias()

cQuery += "SELECT MAX(R_E_C_N_O_) AS REG FROM " + RetSqlName("SC4")

DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "TBC4", .T., .F.)

nRet	:= TBC4->REG

TBC4->(DbCloseArea())

IF !Empty(Alltrim(cAlias)) .AND. Select(cAlias) > 0
	DbSelectArea(cAlias)
ENDIF
Return(nRet)

USER FUNCTION VExtA05T(aParam)
Local nRegPCall	:= 500
Local cEmpPar	:= aParam[1]
Local cFilPar	:= aParam[2]
Local nTreAtu	:= aParam[3]
Local cArqOri	:= aParam[4]
Local nRegIni	:= aParam[5]
Local nRegFim	:= aParam[6]
Local aCampos	:= AClone(aParam[7])
Local nRegBas	:= aParam[8]
Local aCmpPad	:= {}
Local cDirRot	:= "\v3exta05\trb\"
Local nRegAtu	:= 1
Local nCntCall	:= 0
Local cQuery	:= ""
Local nI		:= 0
Local cLinha	:= ""
Local aLinha	:= {}
Local cCampos	:= ""
Local nPosPrd	:= 0

RpcSetType(3)
RpcSetEnv(cEmpPar, cFilPar)
IF Select("SX2") > 0
	nRegPCall	:= GetMv("V3_RGCLL05",, 500)
	
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("SC4", .f.)
	WHILE !Eof() .AND. SX3->X3_ARQUIVO == "SC4"
		IF AScan(aCampos, {|z| Alltrim(z[1]) == Alltrim(SX3->X3_CAMPO)}) == 0 .AND. SC4->(FieldPos(SX3->X3_CAMPO)) > 0
			IF Alltrim(SX3->X3_CAMPO) == "C4_FILIAL"
				Aadd(aCmpPad, {SX3->X3_CAMPO, "'" + xFilial("SC4") + "'"})
			ELSEIF SX3->X3_TIPO == "N"
				Aadd(aCmpPad, {SX3->X3_CAMPO, "0"})
			ELSEIF SX3->X3_TIPO == "L"
				Aadd(aCmpPad, {SX3->X3_CAMPO, "'F'"})
			ELSE
				Aadd(aCmpPad, {SX3->X3_CAMPO, "'" + Space(SX3->X3_TAMANHO) + "'"})
			ENDIF
		ENDIF
		
		DbSkip()
	ENDDO
	
	cCampos	:= ""
	FOR nI := 1 TO Len(aCampos)
		cCampos	+= Alltrim(aCampos[nI, 1]) + ","
	NEXT
	FOR nI := 1 TO Len(aCmpPad)
		cCampos	+= Alltrim(aCmpPad[nI, 1]) + ","
	NEXT
	cCampos	+= "D_E_L_E_T_, R_E_C_N_O_"
	
	Ft_FUse(CmPt(cDirRot + cArqOri))
	WHILE !Ft_FEof()
		IF nRegAtu > nRegFim
			EXIT
		ELSEIF nRegAtu >= nRegIni
			cLinha		:= StrTran(Ft_FReadLn(), CRLF)
			aLinha		:= Separa(cLinha, ";")
			nCntCall++
			IF !Upper(Alltrim(TcGetDb())) == "ORACLE"
				IF !Empty(cQuery)
					cQuery += ","
				ENDIF
				
				cQuery += "("
				FOR nI := 1 TO Len(aCampos)
					cQuery += TrataDd(aLinha[aCampos[nI, 2]], aCampos[nI, 1], .T.) + ","
					IF Alltrim(aCampos[nI, 1]) == "C4_PRODUTO"
						nPosPrd	:= nI
					ENDIF
				NEXT
				FOR nI := 1 TO Len(aCmpPad)
					IF Alltrim(aCmpPad[nI, 1]) == "C4_LOCAL"
						SB1->(DbSetOrder(1))
						SB1->(DbSeek(xFilial("SB1") + aLinha[aCampos[nPosPrd, 2]], .f.))
						IF Empty(Alltrim(SB1->B1_LOCPAD))
							cQuery += "'01'," 
						ELSE
							cQuery += "'" + SB1->B1_LOCPAD + "'," 
						ENDIF
					ELSE
						cQuery += aCmpPad[nI, 2] + ","
					ENDIF
				NEXT
				cQuery += "' ', " + Alltrim(Str(nRegAtu + nRegBas)) + ")"
			ELSE
				cQuery += "INTO " + RetSqlName("SC4") + " (" + cCampos + ") VALUES ("
				FOR nI := 1 TO Len(aCampos)
					cQuery += TrataDd(aLinha[aCampos[nI, 2]], aCampos[nI, 1], .T.) + ","
					IF Alltrim(aCampos[nI, 1]) == "C4_PRODUTO"
						nPosPrd	:= nI
					ENDIF
				NEXT
				FOR nI := 1 TO Len(aCmpPad)
					IF Alltrim(aCmpPad[nI, 1]) == "C4_LOCAL"
						SB1->(DbSetOrder(1))
						SB1->(DbSeek(xFilial("SB1") + aLinha[aCampos[nPosPrd, 2]], .f.))
						IF Empty(Alltrim(SB1->B1_LOCPAD))
							cQuery += "'01'," 
						ELSE
							cQuery += "'" + SB1->B1_LOCPAD + "'," 
						ENDIF
					ELSE
						cQuery += aCmpPad[nI, 2] + ","
					ENDIF
				NEXT
				cQuery += "' ', " + Alltrim(Str(nRegAtu + nRegBas)) + ") "
			ENDIF
		ENDIF
		
		Ft_FSkip()
		nRegAtu++
		IF (nCntCall >= nRegPCall .OR. Ft_FEof() .OR. nRegAtu > nRegFim) .AND. !Empty(cQuery)
			IF Upper(Alltrim(TcGetDb())) == "ORACLE"
				cQuery	:= "INSERT ALL " + cQuery + " SELECT * FROM DUAL"
			ELSE
				cQuery	:= "INSERT INTO " + RetSqlName("SC4") + " (" + cCampos + ") VALUES " + cQuery
			ENDIF
			
			TcSqlExec(cQuery)
			
			nCntCall	:= 0
			cQuery		:= ""
		ENDIF
	ENDDO
	Ft_FUse()
	
	//RpcClearEnv()
ENDIF

RETURN

STATIC FUNCTION TrataDd(cCont, cCampo, lDelim)
Local xCont		:= nil
Local aPosSx3	:= SX3->({IndexOrd(), RecNo()})
Default lDelim	:= .f.

cCont	:= Alltrim(cCont)

IF (Left(cCont, 1) == "'" .AND. Right(cCont, 1) == "'") .OR. (Left(cCont, 1) == '"' .AND. Right(cCont, 1) == '"')
	cCont	:= Substr(cCont, 2, Len(cCont) - 2)
ENDIF

SX3->(DbSetOrder(2))
IF SX3->(DbSeek(Padr(cCampo, Len(SX3->X3_CAMPO)), .f.))
	IF SX3->X3_TIPO == "D"
		IF Substr(cCont, 3, 1) == "/" .AND. Substr(cCont, 6, 1) == "/"
			xCont	:= Stod(Substr(cCont, 7, 4) + Substr(cCont, 4, 2) + Substr(cCont, 1, 2))
		ELSE
			xCont	:= Stod(StrTran(cCont, "-"))
		ENDIF
		IF lDelim
			xCont	:= "'" + Dtos(xCont) + "'"
		ENDIF
	ELSEIF SX3->X3_TIPO == "N"
		xCont	:= Val(StrTran(cCont, ",", "."))
		IF lDelim
			xCont	:= Alltrim(Str(xCont))
		ENDIF
	ELSEIF SX3->X3_TIPO == "C"
		xCont	:= Padr(cCont, SX3->X3_TAMANHO)
		IF lDelim
			xCont	:= "'" + xCont + "'"
		ENDIF
	ELSE
		xCont	:= cCont
	ENDIF
ENDIF

SX3->(DbSetOrder(aPosSx3[1]))
SX3->(DbGoTo(aPosSx3[2]))
Return(xCont)


STATIC FUNCTION GetCampos()
Local aCampos	:= {}
Local cCmpPd	:= "C4_DATA-01|C4_PRODUTO-09|C4_QUANT-17"
Local cCampos	:= Alltrim(GetMv("V3_EXTA051",, "*"))
Local cCampos2	:= Alltrim(GetMv("V3_EXTA052",, " "))
Local aPivo		:= {}
Local nI		:= 0
Local aStrSc4	:= SC4->(DbStruct())

IF cCampos == "*"
	Aviso("Par‚metros", "O par‚metro 'V3_EXTA051' n„o existe e deve ser criado. Seu tipo dever· ser 'Caractere' e seu conte˙do dever· armazenar a " + ;
		"associaÁ„o entre o nome do campo da tabela SC4 e a posiÁ„o de seu conte˙do no arquivo CSV de origem." + CRLF + "Exemplo de conte˙do: " + CRLF + ;
		cCmpPd + CRLF + CRLF + "Caso um ˙nico par‚metro n„o seja suficiente, crie tambÈm o par‚metro 'V3_EXTA052' como continuaÁ„o do primeiro.", {"Ok"})
ELSE
	IF Right(cCampos, 1) # "|" .AND. !Empty(Alltrim(cCampos2)) .AND. Left(cCampos2, 1) # "|"
		cCampos	+= "|"
	ENDIF
	cCampos	+= cCampos2
	
	aPivo	:= Separa(cCampos, "|")
	
	FOR nI := 1 TO Len(aPivo)
		IF AScan(aStrSc4, {|z| Alltrim(z[1]) == Alltrim(Separa(aPivo[nI], "-")[1])}) > 0 .AND. Val(Separa(aPivo[nI], "-")[2]) > 0
			Aadd(aCampos, {Alltrim(Separa(aPivo[nI], "-")[1]), Val(Separa(aPivo[nI], "-")[2])})
		ENDIF
	NEXT
	
	IF Len(aCampos) == 0
		Aviso("Par‚metros", "Os conte˙dos do par‚metro obrigatÛrio 'V3_EXTA051' e par‚metro opcional 'V3_EXTA052' n„o est„o definidos corretamente.", {"Ok"})
	ENDIF
ENDIF
Return(aCampos)

STATIC FUNCTION CmPt(cPath)
Return(Iif(IsSrvUnix(), StrTran(cPath, "\", "/"), cPath))

USER FUNCTION VExtA05V(nTipo)
Local lRet	:= .t.

IF nTipo == 1
	IF !Empty(Alltrim(MV_PAR01)) .AND. !File(MV_PAR01)
		Aviso("Arquivo inv·lido", "O arquivo de origem È inv·lido. Verifique o caminho e o nome do arquivo informado!", {"Ok"})
		lRet	:= .f.
	ENDIF
ENDIF
Return(lRet)