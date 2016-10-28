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
	Local lCont		:= .t.
	Local cLinha	:= ""
	Local nHdlLog	:= 0
	Local aLinha	:= {}
	Local aCampos	:= {}
	Local nI		:= 0
	Local aDados	:= {}
	Local nPosPrd	:= 0
	Local nPosData	:= Ctod("")
	Local cErro		:= ""
	Local lRet		:= .t.
	Local nLinha	:= 2
	Local lTemReg	:= .f.
	Local nHdlSem	:= -1
	Local nRegDel	:= 0
	Private lMsErroAuto	:= .f.
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

	IF lRet .AND. (lRet := OkToGo(@nHdlSem))
		aCampos	:= GetCampos()
		lRet	:= Len(aCampos) > 0

		// Nome do arquivo de LOG
		/*
		WHILE File(CmPt(cDirRot + "\log\" + cNmArq + cSeqLog + ".log")) .AND. !MayIUseCode(cNmArq + cSeqLog)
		cSeqLog	:= Soma1(cSeqLog)
		ENDDO
		*/
		WHILE File(CmPt(cDirRot + "\log\" + cNmArq + cSeqLog + ".log")) .OR. !MayIUseCode(cNmArq + cSeqLog)
			cSeqLog	:= Soma1(cSeqLog)
		ENDDO

		// Abre o arquivo de origem
		Ft_FUse(MV_PAR01)

		nTotReg	:= Ft_FLastRec()

		// Se a quantidade de registros for menor que 2, n„o È possÌvel processar, pois n„o tem a quantidade mÌnima de registros
		IF nTotReg < 2
			Aviso("Sem registros", "O arquivo de origem n„o tem quantidade de registros suficientes para ser um arquivo v·lido de previs„o de vendas.", {"Ok"})
			lCont	:= .f.
		ELSE
			// Verifica se a primeira linha È a linha de cabeÁalho esperada
			cLinha	:= StrTran(Ft_FReadLn(), CRLF)
			Ft_FSkip()
			/*
			IF cLinha # "date;channel_level_1;channel_level_2;channel_level_3;channel_level_4;product_level_1;product_level_2;product_level_3;" + ;
			"product_level_4;quantity_budget;quantity_marketing;quantity_forecast;quantity_event;suggestion_1;suggestion_2;suggestion_3;consensus"
			Aviso("CabeÁalho inv·lido", "O cabeÁalho do arquivo n„o corresponde ‡ estrutura esperada para os dados de previs„o de vendas.", {"Ok"})
			lRet	:= .f.
			ENDIF
			*/
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
		FWrite(nHdlLog, cLinha + CRLF)

		ProcRegua(nTotReg)
		WHILE !Ft_FEof()
			IncProc("Importando registros...")
			cLinha	:= StrTran(Ft_FReadLn(), CRLF)
			FWrite(nHdlLog, "L" + StrZero(nLinha, Len(Alltrim(Str(nTotReg)))) + "-" + cLinha + CRLF)
			nLinha++
			aLinha	:= Separa(cLinha, ";")

			aDados	:= {}
			FOR nI := 1 TO Len(aCampos)
				Aadd(aDados, {aCampos[nI, 1], TrataDd(aLinha[aCampos[nI, 2]], aCampos[nI, 1]), nil})
			NEXT

			nPosPrd		:= AScan(aCampos, {|z| Alltrim(z[1]) == "C4_PRODUTO"})
			nPosData	:= AScan(aCampos, {|z| Alltrim(z[1]) == "C4_DATA"})
			IF nPosPrd == 0
				FWrite(nHdlLog, "ERRO: Campo C4_PRODUTO obrigatorio nao existe na estrutura" + CRLF)
				aDados	:= {}
			ELSEIF nPosData == 0
				FWrite(nHdlLog, "ERRO: Campo C4_DATA obrigatorio nao existe na estrutura" + CRLF)
				aDados	:= {}
			ELSEIF AScan(aCampos, {|z| Alltrim(z[1]) == "C4_QUANT"}) == 0
				FWrite(nHdlLog, "ERRO: Campo C4_QUANT obrigatorio nao existe na estrutura" + CRLF)
				aDados	:= {}
			ELSEIF AScan(aCampos, {|z| Alltrim(z[1]) == "C4_LOCAL"}) == 0
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1") + TrataDd(aLinha[aCampos[nPosPrd, 2]], aCampos[nPosPrd, 1]), .f.))
				Aadd(aDados, {"C4_LOCAL", SB1->B1_LOCPAD, nil})
			ENDIF

			IF Len(aDados) > 0
				SC4->(DbSetOrder(1))
				lTemReg	:= SC4->(DbSeek(xFilial("SC4") + TrataDd(aLinha[aCampos[nPosPrd, 2]], aCampos[nPosPrd, 1]) + ;
				Dtos(TrataDd(aLinha[aCampos[nPosData, 2]], aCampos[nPosData, 1])), .f.))

				BEGIN TRANSACTION
					IF lTemReg
						nRegDel	:= SC4->(RecNo())
						RecLock("SC4", .f.)
						SC4->(DbDelete())
						SC4->(MsUnlock())
					ENDIF

					MsExecAuto({|x,y| Mata700(x, y)}, aDados, 3)
				END TRANSACTION
				IF lTemReg
					TcSqlExec("DELETE FROM " + RetSqlName("SC4") + " WHERE R_E_C_N_O_ = " + Str(nRegDel))
				ENDIF

				SC4->(DbCommit())
				DbCommitAll()

				IF lMsErroAuto
					cErro	:= MostraErro(GetSrvProfString("StartPath",""))
					FWrite(nHdlLog, cErro)
					lMsErroAuto	:= .f.
				ENDIF
			ENDIF

			Ft_FSkip()
		ENDDO
	ENDIF
	Ft_FUse()

	IF nHdlLog > 0
		FClose(nHdlLog)
	ENDIF
RETURN

STATIC FUNCTION TrataDd(cCont, cCampo)
	Local xCont		:= nil
	Local aPosSx3	:= SX3->({IndexOrd(), RecNo()})

	cCont	:= Alltrim(cCont)

	IF (Left(cCont, 1) == "'" .AND. Right(cCont, 1) == "'") .OR. (Left(cCont, 1) == '"' .AND. Right(cCont, 1) == '"')
		cCont	:= Substr(cCont, 2, Len(cCont) - 2)
	ENDIF

	SX3->(DbSetOrder(2))
	IF SX3->(DbSeek(Padr(cCampo, Len(SX3->X3_CAMPO)), .f.))
		IF SX3->X3_TIPO == "D"
			xCont	:= Stod(Substr(cCont, 7, 4) + Substr(cCont, 4, 2) + Substr(cCont, 1, 2))
		ELSEIF SX3->X3_TIPO == "N"
			xCont	:= Val(StrTran(cCont, ",", "."))
		ELSEIF SX3->X3_TIPO == "C"
			xCont	:= Padr(cCont, SX3->X3_TAMANHO)
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