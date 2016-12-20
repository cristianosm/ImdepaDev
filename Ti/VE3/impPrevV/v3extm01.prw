#include "protheus.ch"

Static __lV3ExtM01	:= .f.
Static __aV3ExtM01	:= {}

USER FUNCTION V3ExtM01(cEmpAmb, cFilAmb)
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : Interface de instalaÁ„o do sistema no ambiente do cliente
<Data> : 28/09/2016
<Parametros> : cEmpAmb, cFilAmb
	cEmpAmb	: CÛdigo da empresa
	cFilAmb	: CÛdigo da filial
<Retorno> : Nenhum
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local aSay		:= {}
Local aButton	:= {}
Local aMarcadas	:= {}
Local cTitulo	:= "ATUALIZA«√O DE DICION¡RIOS E TABELAS"
Local cDesc1	:= "Esta rotina tem como funÁ„o fazer  a atualizaÁ„o  dos dicion·rios do Sistema ( SX?/SIX )"
Local cDesc2	:= "Este processo deve ser executado em modo EXCLUSIVO, ou seja n„o podem haver outros"
Local cDesc3	:= "usu·rios  ou  jobs utilizando  o sistema.  … EXTREMAMENTE recomendavÈl  que  se  faÁa um"
Local cDesc4	:= "BACKUP  dos DICION¡RIOS  e da  BASE DE DADOS antes desta atualizaÁ„o, para que caso "
Local cDesc5	:= "ocorram eventuais falhas, esse backup possa ser restaurado."
Local cDesc6	:= ""
Local cDesc7	:= ""
Local lOk		:= .F.
Local lAuto		:= (cEmpAmb <> nil .OR. cFilAmb <> nil)
Private lCriaIni	:= .f.

Private oMainWnd, oProcess

#IFDEF TOP
    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet	:= NIL
__lPYME		:= .F.

SET DELETED ON

// Mensagens de Tela Inicial
Aadd(aSay, cDesc1)
Aadd(aSay, cDesc2)
Aadd(aSay, cDesc3)
Aadd(aSay, cDesc4)
Aadd(aSay, cDesc5)

// Botoes Tela Inicial
Aadd(aButton, {1, .T., {|| lOk := .T., FechaBatch()}})
Aadd(aButton, {2, .T., {|| lOk := .F., FechaBatch()}})
IF File(RetIni()[1] + RetIni()[2])
	MsgAlert("O arquivo '" + RetIni()[2] + "' j· existe. Por seguranÁa, o compatibilizador n„o ser· executado neste ambiente!", "AtenÁ„o")
	RETURN
ENDIF
IF lAuto
	lOk	:= .T.
ELSE
	FormBatch(cTitulo, aSay, aButton)
ENDIF

IF lOk
	IF lAuto
		aMarcadas	:= {{cEmpAmb, cFilAmb, ""}}
	ELSE
		aMarcadas	:= EscEmpresa()
	ENDIF

	IF !Empty(aMarcadas)
		IF !VerAlias(aMarcadas)
			MsgStop("AtualizaÁ„o n„o Realizada.", "Dicion·rio Extrator")
			IF lCriaIni
				FErase(RetIni()[1] + RetIni()[2])
			ENDIF
		ELSEIF lAuto .OR. MsgNoYes( "Confirma a atualizaÁ„o dos dicion·rios ?", cTitulo)
			oProcess	:= MsNewProcess():New( { |lEnd| lOk := FSTProc(@lEnd, aMarcadas)}, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			IF lAuto
				IF lOk
					MsgStop("AtualizaÁ„o Realizada.", "Dicion·rio Extrator" )
				ELSE
					MsgStop("AtualizaÁ„o n„o Realizada.", "Dicion·rio Extrator" )
					IF lCriaIni
						FErase(RetIni()[1] + RetIni()[2])
					ENDIF
				ENDIF
				DbCloseAll()
			ELSE
				IF lOk
					Final("AtualizaÁ„o concluÌda.")
				ELSE
					Final("AtualizaÁ„o n„o realizada.")
					IF lCriaIni
						FErase(RetIni()[1] + RetIni()[2])
					ENDIF
				ENDIF
			ENDIF
		ELSE
			MsgStop("AtualizaÁ„o n„o Realizada.", "Dicion·rio Extrator")
			IF lCriaIni
				FErase(RetIni()[1] + RetIni()[2])
			ENDIF
		ENDIF
	ELSE
		MsgStop("AtualizaÁ„o n„o Realizada.", "Dicion·rio Extrator")
		IF lCriaIni
			FErase(RetIni()[1] + RetIni()[2])
		ENDIF
	ENDIF
ENDIF
IF lCriaIni
	FErase(RetIni()[1] + RetIni()[2])
ENDIF

RETURN

STATIC FUNCTION VerAlias(aMarcadas)
Local lRet		:= .t.
Local cOldEmp	:= ""
Local aVerAli	:= {}
Local nI		:= 0
Local nX		:= 0
Local nC		:= 0
Local cArqSx2	:= ""
Local lTem		:= .f.
Local aParam	:= {}
Local aRetPar	:= {}
Local aBkpRan	:= {}
Local cEmp1		:= ""
Local cFil1		:= ""
Local lEnv		:= .f.
Local aArqSxb	:= {}
Local cArqSxb	:= ""
Local aVerSxb	:= {}
Local cSqCons	:= ""	//StrZero(1, Len(SXB->XB_ALIAS))
Private aRange	:= {}
Private aAlias	:= {}

// Configura a necessidade
Aadd(aVerAli, {"Cadastro de consultas"	, "", "CONS"})
Aadd(aVerAli, {"Cadastro de permissıes"	, "", "PERM"})

Aadd(aVerSxb, {"Consulta GRP"		, "", "SXB1"})
Aadd(aVerSxb, {"Consulta USR"		, "", "SXB2"})
Aadd(aVerSxb, {"Consulta Z09"		, "", "SXB3"})
Aadd(aVerSxb, {"Consulta Z09USR"	, "", "SXB4"})

// Range de aliases disponÌveis para tabelas personalizadas
Aadd(aRange, {"SZ0", "SZZ"})
Aadd(aRange, {"Z00", "ZZZ"})
aBkpRan	:= AClone(aRange)

// Abre o arquivo SX2 e o SXB para cada uma das empresas do array
FOR nI := 1 TO Len(aMarcadas)
	IF Empty(cFil1)
		cEmp1	:= aMarcadas[nI, 1]
		cFil1	:= aMarcadas[nI, 2]
	ENDIF
	IF aMarcadas[nI, 1] # cOldEmp
		cOldEmp	:= aMarcadas[nI, 1]
		cArqSx2	:= "SX2" + cOldEmp + "0"
		IF File(cArqSx2 + GetDbExtension())
			DbUseArea(.t.,, cArqSx2, cArqSx2, .t., .f.)
			Aadd(aAlias, cArqSx2)
		ENDIF
		
		cArqSxb	:= "SXB" + cOldEmp + "0"
		IF File(cArqSxb + GetDbExtension())
			DbUseArea(.t.,, cArqSxb, cArqSxb, .t., .f.)
			Aadd(aArqSxb, cArqSxb)
		ENDIF
	ENDIF
NEXT

IF Len(aArqSxb) > 0
	cSqCons	:= StrZero(1, Len((aArqSxb[1])->XB_ALIAS))
ENDIF

FOR nX := 1 TO Len(aVerAli)
	FOR nI := 1 TO Len(aRange)
		WHILE aRange[nI, 1] <= aRange[nI, 2] .AND. Empty(Alltrim(aVerAli[nX, 2]))
			lTem	:= .f.
			FOR nC := 1 TO Len(aAlias)	// Cada alias de SX2 aberto das empresas selecionadas
				(aAlias[nC])->(DbSetOrder(1))
				IF (aAlias[nC])->(DbSeek(aRange[nI, 1], .f.))	// Se encontrou, n„o d· para usar o alias
					// Incrementa o range e saÌ do laÁo dos aliases
					aRange[nI, 1]	:= Soma1(aRange[nI, 1])
					lTem			:= .t.
					EXIT
				ENDIF
			NEXT
			IF !lTem	// Se a pesquisa n„o encontrou nada, d· para usar o alias
				aVerAli[nX, 2]	:= aRange[nI, 1]
				aRange[nI, 1]	:= Soma1(aRange[nI, 1])	// Incrementa o range usado
			ENDIF
		ENDDO
		
		// Se achou um alias, sai do laÁo do range
		IF !Empty(Alltrim(aVerAli[nX, 2]))
			EXIT
		ENDIF
	NEXT
NEXT

FOR nX := 1 TO Len(aVerSxb)
	WHILE cSqCons <= "999999"
		lTem	:= .f.
		FOR nI := 1 TO Len(aArqSxb)
			(aArqSxb[nI])->(DbSetOrder(1))
			IF (aArqSxb[nI])->(DbSeek(cSqCons, .f.))
				lTem	:= .t.
				EXIT
			ENDIF
		NEXT
		IF !lTem
			aVerSxb[nX, 2]	:= cSqCons
			cSqCons			:= Soma1(cSqCons)
			EXIT
		ELSE
			cSqCons	:= Soma1(cSqCons)
		ENDIF
	ENDDO
NEXT

IF AScan(aVerAli, {|z| Empty(Alltrim(z[2]))}) > 0	// N„o foi possÌvel identificar todos os aliases
	lRet	:= .f.
ELSE
	// Informa ao usu·rio quais ser„o os aliases utilizados, d· a oportunidade de alteraÁ„o e cria o arquivo .ini
	aRange	:= AClone(aBkpRan)
	Aadd(aParam, {9, "Confirme abaixo o nome dos arquivos que dever„o ser utilizados pela rotina:", 200, 020, .t.})
	FOR nI := 1 TO Len(aVerAli)
		Aadd(aParam, {1, aVerAli[nI, 1], aVerAli[nI, 2], "@!", "U_VExtM01V()",,, 30, .t.})
	NEXT
	Aadd(aParam, {9, "Tenha certeza que os arquivos informados n„o existem em todas as empresas do ambiente.", 200, 020, .t.})
	
	RpcSetType(3)
	RpcSetEnv(cEmp1, cFil1)
	IF Select("SX2") > 0
		lEnv	:= .t.
		WHILE .t.
			lRet	:= ParamBox(aParam, "Novos arquivos", @aRetPar,,, .t.,,,,, .f., .f.)
			
			IF lRet
				FOR nI := 1 TO Len(aRetPar)
					IF !Empty(Alltrim(aRetPar[nI]))
						FOR nX := 1 TO Len(aRetPar)
							IF !Empty(Alltrim(aRetPar[nX])) .AND. nI # nX .AND. aRetPar[nX] == aRetPar[nI]
								MsgStop("N„o informe o mesmo nome de arquivo mais de uma vez!", "AtenÁ„o")
								lRet	:= .f.
								EXIT
							ENDIF
						NEXT
						IF !lRet
							EXIT
						ENDIF
					ENDIF
				NEXT
				IF lRet
					EXIT
				ELSE
					lRet	:= .t.
				ENDIF
			ELSE
				EXIT
			ENDIF
		ENDDO
	ENDIF
ENDIF

IF lRet .AND. Len(aRetPar) > 0
	FOR nI := 2 TO Len(aRetPar) - 1
		aVerAli[nI - 1, 2]	:= aRetPar[nI]
	NEXT
	GrvIni(aVerAli, aVerSxb)
ENDIF

FOR nI := 1 TO Len(aAlias)
	(aAlias[nI])->(DbCloseArea())
NEXT
FOR nI := 1 TO Len(aArqSxb)
	(aArqSxb[nI])->(DbCloseArea())
NEXT
IF lEnv
	RpcClearEnv()
ENDIF
Return(lRet)

STATIC FUNCTION RetIni()
Local cRoot	:= ""
Local cBar	:= Iif(IsSrvUnix(), "/", "\")

cRoot	:= Alltrim(GetSrvProfString("ROOTPATH", cBar))
cRoot	+= Iif(Right(cRoot, 1) == cBar, "", cBar)

Return({cRoot, "v3extm01.ini"})

STATIC FUNCTION GrvIni(aVerAli, aVerSxb)
Local cDir	:= RetIni()[1]
Local cArq	:= RetIni()[2]
Local nHdl	:= 0

nHdl	:= FCreate(cDir + cArq)

FWrite(nHdl, "[ALIAS_EXPORT_TOOL]" + CRLF)
AEval(aVerAli, {|z| FWrite(nHdl, ";" + z[1] + CRLF + z[3] + "=" + z[2] + CRLF + CRLF)})
AEval(aVerSxb, {|z| FWrite(nHdl, ";" + z[1] + CRLF + z[3] + "=" + z[2] + CRLF + CRLF)})

FClose(nHdl)
lCriaIni	:= .t.
RETURN

USER FUNCTION VExtM01V()
Local lRet	:= .f.
Local nI	:= 0

FOR nI := 1 TO Len(aRange)
	lRet	:= &(ReadVar()) >= aRange[nI, 1] .AND. &(ReadVar()) <= aRange[nI, 2]
	IF lRet
		EXIT
	ENDIF
NEXT

IF !lRet
	MsgStop("O nome de arquivo informado n„o est· dentro do intervalo de nomes para arquivos de usu·rio!", "Nome inv·lido")
ELSE
	FOR nI := 1 TO Len(aAlias)
		(aAlias[nI])->(DbSetOrder(1))
		IF (aAlias[nI])->(DbSeek(&(ReadVar()), .f.))
			lRet	:= .f.
			MsgStop("O nome de arquivo informado j· existe em ao menos uma das empresas marcadas. Informe outro nome!", "Nome inv·lido")
		ENDIF
	NEXT
ENDIF
Return(lRet)

USER FUNCTION VExtM01R()
Return(RetIni()[1] + RetIni()[2])

USER FUNCTION VExtM01P(aAliases)
__aV3ExtM01	:= AClone(aAliases)
__lV3ExtM01	:= .t.
RETURN

USER FUNCTION VExtM01I(cKey)
Local cRet	:= ""
Local nPos	:= 0

IF !__lV3ExtM01
	Aadd(__aV3ExtM01, {"CONS", GetPvProfString("ALIAS_EXPORT_TOOL", "CONS", "*", RetIni()[1] + RetIni()[2])})
	Aadd(__aV3ExtM01, {"PERM", GetPvProfString("ALIAS_EXPORT_TOOL", "PERM", "*", RetIni()[1] + RetIni()[2])})
	Aadd(__aV3ExtM01, {"SXB1", GetPvProfString("ALIAS_EXPORT_TOOL", "SXB1", "*", RetIni()[1] + RetIni()[2])})
	Aadd(__aV3ExtM01, {"SXB2", GetPvProfString("ALIAS_EXPORT_TOOL", "SXB2", "*", RetIni()[1] + RetIni()[2])})
	Aadd(__aV3ExtM01, {"SXB3", GetPvProfString("ALIAS_EXPORT_TOOL", "SXB3", "*", RetIni()[1] + RetIni()[2])})
	Aadd(__aV3ExtM01, {"SXB4", GetPvProfString("ALIAS_EXPORT_TOOL", "SXB4", "*", RetIni()[1] + RetIni()[2])})
	__lV3ExtM01	:= .t.
ENDIF

nPos	:= AScan(__aV3ExtM01, {|z| z[1] == cKey})
IF nPos > 0
	cRet	:= __aV3ExtM01[nPos, 2]
ENDIF

Return(cRet)

STATIC FUNCTION FSTProc(lEnd, aMarcadas)
Local oDlg, oFont, oMemo
Local aInfo		:= {}
Local aRecnoSM0	:= {}
Local cAux		:= ""
Local cFile		:= ""
Local cFileLog	:= ""
Local cMask		:= "Arquivos Texto (*.TXT)|*.txt|"
Local cTCBuild	:= "TCGetBuild"
Local cTexto	:= ""
Local cTopBuild	:= ""
Local lOpen		:= .F.
Local lRet		:= .T.
Local nI		:= 0
Local nPos		:= 0
Local nRecno	:= 0
Local nX		:= 0

Private aArqUpd	:= {}

IF (lOpen := MyOpenSm0(.T.))
	DbSelectArea("SM0")
	DbGoTop()

	WHILE !SM0->(Eof())
		// SÛ adiciona no aRecnoSM0 se a empresa for diferente
		IF AScan(aRecnoSM0, {|x| x[2] == SM0->M0_CODIGO}) == 0 .AND. AScan(aMarcadas, { |x| x[1] == SM0->M0_CODIGO}) > 0
			Aadd(aRecnoSM0, {Recno(), SM0->M0_CODIGO})
		ENDIF
		SM0->(DbSkip())
	ENDDO

	SM0->(DbCloseArea())

	IF lOpen

		FOR nI := 1 TO Len(aRecnoSM0)
			IF !( lOpen := MyOpenSm0(.F.))
				MsgStop( "AtualizaÁ„o da empresa " + aRecnoSM0[nI][2] + " n„o efetuada." )
				EXIT
			ENDIF

			SM0->(DbGoTo(aRecnoSM0[nI][1]))

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			cTexto += Replicate( "-", 128 ) + CRLF
			cTexto += "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF + CRLF

			oProcess:SetRegua1( 8 )

			//------------------------------------
			// Atualiza o dicion·rio SX2
			//------------------------------------
			oProcess:IncRegua1( "Dicion·rio de arquivos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX2( @cTexto )

			//------------------------------------
			// Atualiza o dicion·rio SX3
			//------------------------------------
			FSAtuSX3( @cTexto )

			//------------------------------------
			// Atualiza o dicion·rio SIX
			//------------------------------------
			oProcess:IncRegua1( "Dicion·rio de Ìndices" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSIX( @cTexto )

			oProcess:IncRegua1( "Dicion·rio de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/Ìndices" )

			// AlteraÁ„o fÌsica dos arquivos
			__SetX31Mode( .F. )

			IF FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			ENDIF

			For nX := 1 To Len( aArqUpd )

				IF cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					IF ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
						!aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
						TcInternal( 25, "CLOB" )
					ENDIF
				ENDIF

				IF Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					DbCloseArea()
				ENDIF

				X31UpdTable( aArqUpd[nX] )

				IF __GetX31Error()
					Alert( __GetX31Trace() )
					MsgStop( "Ocorreu um erro desconhecido durante a atualizaÁ„o da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicion·rio e da tabela.", "ATEN«√O" )
					cTexto += "Ocorreu um erro desconhecido durante a atualizaÁ„o da estrutura da tabela : " + aArqUpd[nX] + CRLF
				ENDIF

				IF cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				ENDIF

			Next nX

			//------------------------------------
			// Atualiza o dicion·rio SXB
			//------------------------------------
			oProcess:IncRegua1( "Dicion·rio de consultas padr„o" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSXB( @cTexto )

			RpcClearEnv()

		Next nI

		IF MyOpenSm0(.T.)

			cAux += Replicate( "-", 128 ) + CRLF
			cAux += Replicate( " ", 128 ) + CRLF
			cAux += "LOG DA ATUALIZA«√O DOS DICION¡RIOS" + CRLF
			cAux += Replicate( " ", 128 ) + CRLF
			cAux += Replicate( "-", 128 ) + CRLF
			cAux += CRLF
			cAux += " Dados Ambiente" + CRLF
			cAux += " --------------------"  + CRLF
			cAux += " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt  + CRLF
			cAux += " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF
			cAux += " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF
			cAux += " DataBase...........: " + DtoC( dDataBase )  + CRLF
			cAux += " Data / Hora Õnicio.: " + DtoC( Date() )  + " / " + Time()  + CRLF
			cAux += " Environment........: " + GetEnvServer()  + CRLF
			cAux += " StartPath..........: " + GetSrvProfString( "StartPath", "" )  + CRLF
			cAux += " RootPath...........: " + GetSrvProfString( "RootPath" , "" )  + CRLF
			cAux += " Vers„o.............: " + GetVersao(.T.)  + CRLF
			cAux += " Usu·rio TOTVS .....: " + __cUserId + " " +  cUserName + CRLF
			cAux += " Computer Name......: " + GetComputerName() + CRLF

			aInfo   := GetUserInfo()
			IF ( nPos    := AScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				cAux += " "  + CRLF
				cAux += " Dados Thread" + CRLF
				cAux += " --------------------"  + CRLF
				cAux += " Usu·rio da Rede....: " + aInfo[nPos][1] + CRLF
				cAux += " EstaÁ„o............: " + aInfo[nPos][2] + CRLF
				cAux += " Programa Inicial...: " + aInfo[nPos][5] + CRLF
				cAux += " Environment........: " + aInfo[nPos][6] + CRLF
				cAux += " Conex„o............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) )  + CRLF
			ENDIF
			cAux += Replicate( "-", 128 ) + CRLF
			cAux += CRLF

			cTexto := cAux + cTexto + CRLF

			cTexto += Replicate( "-", 128 ) + CRLF
			cTexto += " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time()  + CRLF
			cTexto += Replicate( "-", 128 ) + CRLF

			cFileLog := MemoWrite( CriaTrab( , .F. ) + ".log", cTexto )

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "AtualizaÁ„o concluida." From 3, 0 to 340, 417 Pixel

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

			Activate MsDialog oDlg Center

		ENDIF

	ENDIF

Else

	lRet := .F.

ENDIF

Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX2
FunÁ„o de processamento da gravaÁ„o do SX2 - Arquivos

@author TOTVS Protheus
@since  02/02/2014
@obs    Gerado por EXPORDIC - V.4.19.8.1 EFS / Upd. V.4.17.7 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX2( cTexto )
Local aEstrut   := {}
Local aSX2      := {}
Local cAlias    := ""
Local cEmpr     := ""
Local cPath     := ""
Local nI        := 0
Local nJ        := 0
Local cCons		:= U_VExtM01I("CONS")
Local cPerm		:= U_VExtM01I("PERM")

cTexto  += "Õnicio da AtualizaÁ„o" + " SX2" + CRLF + CRLF

// Estrutura do SX2
aEstrut := { "X2_CHAVE", "X2_PATH", "X2_ARQUIVO", "X2_NOME", "X2_NOMESPA", "X2_NOMEENG", ;
             "X2_ROTINA", "X2_MODO", "X2_MODOUN", "X2_MODOEMP", "X2_DELET", "X2_TTS", ;
             "X2_UNICO", "X2_PYME", "X2_MODULO", "X2_DISPLAY", "X2_SYSOBJ", "X2_USROBJ", ;
             "X2_POSLGT"}

dbSelectArea( "SX2" )
SX2->( dbSetOrder( 1 ) )
SX2->( dbGoTop() )
cPath := SX2->X2_PATH
cPath := IIf( Right( AllTrim( cPath ), 1 ) <> "\", PadR( AllTrim( cPath ) + "\", Len( cPath ) ), cPath )
cEmpr := Substr( SX2->X2_ARQUIVO, 4 )

//
// Tabela Consulta
//
Aadd(aSX2, {cCons, cPath, cCons + cEmpr, 'CADASTRO DA CONSULTA          ', 'CADASTRO DA CONSULTA          ', 'CADASTRO DA CONSULTA          ', '                                        ', 'C', 'C', 'C',              0, ' ', '                                                                                                                                                                                                                                                          ', ' ',              0, '                                                                                                                                                                                                                                                              ', '                              ', '                              ', ' '})

//
// Tabela Permissoes
//
Aadd(aSX2, {cPerm, cPath, cPerm + cEmpr, 'CADASTRO DE PERMISSOES        ', 'CADASTRO DE PERMISSOES        ', 'CADASTRO DE PERMISSOES        ', '                                        ', 'C', 'C', 'C',              0, ' ', '                                                                                                                                                                                                                                                          ', ' ',              0, '                                                                                                                                                                                                                                                              ', '                              ', '                              ', ' '})

//
// Atualizando dicion·rio
//
oProcess:SetRegua2( Len( aSX2 ) )

dbSelectArea( "SX2" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX2 )

	oProcess:IncRegua2( "Atualizando Arquivos (SX2)..." )

	IF !SX2->( dbSeek( aSX2[nI][1] ) )

		IF !( aSX2[nI][1] $ cAlias )
			cAlias += aSX2[nI][1] + "/"
			cTexto += "Foi incluÌda a tabela " + aSX2[nI][1] + CRLF
		ENDIF

		RecLock( "SX2", .T. )
		For nJ := 1 To Len( aSX2[nI] )
			IF FieldPos( aEstrut[nJ] ) > 0
				IF AllTrim( aEstrut[nJ] ) == "X2_ARQUIVO"
					FieldPut( FieldPos( aEstrut[nJ] ), SubStr( aSX2[nI][nJ], 1, 3 ) + cEmpAnt +  "0" )
				Else
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				ENDIF
			ENDIF
		Next nJ
		MsUnLock()

	Else

		IF  !( StrTran( Upper( AllTrim( SX2->X2_UNICO ) ), " ", "" ) == StrTran( Upper( AllTrim( aSX2[nI][12]  ) ), " ", "" ) )
			RecLock( "SX2", .F. )
			SX2->X2_UNICO := aSX2[nI][12]
			MsUnlock()

			IF MSFILE( RetSqlName( aSX2[nI][1] ),RetSqlName( aSX2[nI][1] ) + "_UNQ"  )
				TcInternal( 60, RetSqlName( aSX2[nI][1] ) + "|" + RetSqlName( aSX2[nI][1] ) + "_UNQ" )
			ENDIF

			cTexto += "Foi alterada a chave ˙nica da tabela " + aSX2[nI][1] + CRLF
		ENDIF

	ENDIF

Next nI

cTexto += CRLF + "Final da AtualizaÁ„o" + " SX2" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX3
FunÁ„o de processamento da gravaÁ„o do SX3 - Campos

@author TOTVS Protheus
@since  02/02/2014
@obs    Gerado por EXPORDIC - V.4.19.8.1 EFS / Upd. V.4.17.7 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX3( cTexto )
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cMsg      := ""
Local cSeqAtu   := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nPosVld   := 0
Local nSeqAtu   := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )
Local cCons		:= U_VExtM01I("CONS")
Local cPreC		:= Iif(Left(cCons, 1) == "S", Substr(cCons, 2), cCons)
Local cPerm		:= U_VExtM01I("PERM")
Local cPreP		:= Iif(Left(cPerm, 1) == "S", Substr(cPerm, 2), cPerm)
Local cSxb1		:= U_VExtM01I("SXB1")
Local cSxb2		:= U_VExtM01I("SXB2")
Local cSxb3		:= U_VExtM01I("SXB3")
Local cSxb4		:= U_VExtM01I("SXB4")

cTexto  += "InÌcio da AtualizaÁ„o" + " SX3" + CRLF + CRLF

// Estrutura do SX3
aEstrut := { { "X3_ARQUIVO", 0 }, { "X3_ORDEM", 0 }, { "X3_CAMPO", 0 }, { "X3_TIPO", 0 }, { "X3_TAMANHO", 0 }, { "X3_DECIMAL", 0 }, ;
             { "X3_TITULO", 0 }, { "X3_TITSPA", 0 }, { "X3_TITENG", 0 }, { "X3_DESCRIC", 0 }, { "X3_DESCSPA", 0 }, { "X3_DESCENG", 0 }, ;
             { "X3_PICTURE", 0 }, { "X3_VALID", 0 }, { "X3_USADO", 0 }, { "X3_RELACAO", 0 }, { "X3_F3", 0 }, { "X3_NIVEL", 0 }, ;
             { "X3_RESERV", 0 }, { "X3_CHECK", 0 }, { "X3_TRIGGER", 0 }, { "X3_PROPRI", 0 }, { "X3_BROWSE", 0 }, { "X3_VISUAL", 0 }, ;
             { "X3_CONTEXT", 0 }, { "X3_OBRIGAT", 0 }, { "X3_VLDUSER", 0 }, { "X3_CBOX", 0 }, { "X3_CBOXSPA", 0 }, { "X3_CBOXENG", 0 }, ;
             { "X3_PICTVAR", 0 }, { "X3_WHEN", 0 }, { "X3_INIBRW", 0 }, { "X3_GRPSXG", 0 }, { "X3_FOLDER", 0 }, { "X3_PYME", 0 }, ;
             { "X3_CONDSQL", 0 }, { "X3_CHKSQL", 0 }, { "X3_IDXSRV", 0 }, { "X3_ORTOGRA", 0 }, { "X3_IDXFLD", 0 }, { "X3_TELA", 0 }, ;
             { "X3_AGRUP", 0 }, { "X3_POSLGT", 0 }}

aEval( aEstrut, { |x| x[2] := SX3->( FieldPos( x[1] ) ) } )


//
// Campos Tabela Consultas
//
Aadd(aSX3, {cCons, '01', cPreC + '_FILIAL'	, 'C', 008, 0, 'Filial'			, 'Sucursal'		, 'Branch'			, 'Filial do Sistema'			, 'Sucursal'					, 'Branch of the System'		, '@!'							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128), ''													, ''	, 1, Chr(254) + Chr(192), '', '', 'U', 'N', ''	, ''	, ''	, ''									, ''																													, '', '', '', '', '', '033'	, '', '', '', '', '', ''	, ''	, '', '', ''})
Aadd(aSX3, {cCons, '02', cPreC + '_CODIGO'	, 'C', 006, 0, 'Codigo'			, 'Codigo'			, 'Codigo'			, 'Codigo da consulta'			, 'Codigo da consulta'			, 'Codigo da consulta'			, '@!'							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), 'GETSX8NUM("' + cCons  + '","' + cPreC + '_CODIGO")'	, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'S', 'V'	, 'R'	, ''	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', ''	, ''	, '', '', ''})
Aadd(aSX3, {cCons, '03', cPreC + '_DESCRI'	, 'C', 060, 0, 'Descricao'		, 'Descricao'		, 'Descricao'		, 'Descricao da Consulta'		, 'Descricao da Consulta'		, 'Descricao da Consulta'		, '@!'							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'S', 'A'	, 'R'	, 'Ä'	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', ''	, ''	, '', '', ''})
Aadd(aSX3, {cCons, '04', cPreC + '_OBS'		, 'C', 200, 0, 'Observacoes'	, 'Observacoes'		, 'Observacoes'		, 'Observacoes'					, 'Observacoes'					, 'Observacoes'					, ''							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'S', 'A'	, 'R'	, ''	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', ''	, ''	, '', '', ''})
Aadd(aSX3, {cCons, '05', cPreC + '_ACESS'	, 'C', 001, 0, 'Acesso'			, 'Acesso'			, 'Acesso'			, 'Acesso'						, 'Acesso'						, 'Acesso'						, '@!'							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'S', 'A'	, 'R'	, 'Ä'	, 'Pertence("12")'						, '1=Publica;2=Restrito'																								, '', '', '', '', '', ''	, '', '', '', '', '', ''	, ''	, '', '', ''})
Aadd(aSX3, {cCons, '06', cPreC + '_PROPRI'	, 'C', 006, 0, 'Proprietario'	, 'Proprietario'	, 'Proprietario'	, 'Proprietario'				, 'Proprietario'				, 'Proprietario'				, '@!'							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), '__CUSERID'											, cSxb4	, 0, Chr(254) + Chr(192), '', '', 'U', 'S', 'A'	, 'R'	, ''	, 'U_VExtA01V("' + cPreC + '_PROPRI")'	, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', ''	, ''	, '', '', ''})
Aadd(aSX3, {cCons, '07', cPreC + '_NMPROP'	, 'C', 025, 0, 'Nome Prop.'		, 'Nome Prop.'		, 'Nome Prop.'		, 'Nome do Proprietario'		, 'Nome do Proprietario'		, 'Nome do Proprietario'		, '@!'							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), 'USRFULLNAME(__CUSERID)'								, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'S', 'V'	, 'R'	, ''	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', ''	, ''	, '', '', ''})
Aadd(aSX3, {cCons, '08', cPreC + '_DTINCL'	, 'D', 008, 0, 'Dt. Inclusao'	, 'Dt. Inclusao'	, 'Dt. Inclusao'	, 'Data de inclusao'			, 'Data de inclusao'			, 'Data de inclusao'			, ''							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), 'DDATABASE'											, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'S', 'V'	, 'R'	, ''	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', ''	, ''	, '', '', ''})
Aadd(aSX3, {cCons, '09', cPreC + '_HRINCL'	, 'C', 008, 0, 'Hr. Inclusao'	, 'Hr. Inclusao'	, 'Hr. Inclusao'	, 'Hr. Inclusao'				, 'Hr. Inclusao'				, 'Hr. Inclusao'				, ''							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), 'TIME()'												, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'S', 'V'	, 'R'	, ''	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', ''	, ''	, '', '', ''})
Aadd(aSX3, {cCons, '10', cPreC + '_SQL'		, 'M', 010, 0, 'SQL'			, 'SQL'				, 'SQL'				, 'Query SQL'					, 'Query SQL'					, 'Query SQL'					, ''							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'S', 'A'	, 'R'	, 'Ä'	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', ''	, ''	, '', '', ''})
Aadd(aSX3, {cCons, '11', cPreC + '_EXEMED'	, 'C', 050, 0, 'Tempo Medio'	, 'Tempo Medio'		, 'Tempo Medio'		, 'Tempo medio de execucao'		, 'Tempo medio de execucao'		, 'Tempo medio de execucao'		, ''							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'S', 'V'	, 'R'	, ' '	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', 'N'	, 'N'	, '', '', ''})
Aadd(aSX3, {cCons, '12', cPreC + '_TOTEXE'	, 'N', 016, 0, 'Qtd.Execucao'	, 'Qtd.Execucao'	, 'Qtd.Execucao'	, 'Quantidade de execucoes'		, 'Quantidade de execucoes'		, 'Quantidade de execucoes'		, '@E 9,999,999,999,999,999'	, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'N', 'V'	, 'R'	, ' '	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', 'N'	, 'N'	, '', '', ''})
Aadd(aSX3, {cCons, '13', cPreC + '_TOTMIN'	, 'N', 018, 0, 'Tot.Minutos'	, 'Tot.Minutos'		, 'Tot.Minutos'		, 'Minutos totais na execuca'	, 'Minutos totais na execuca'	, 'Minutos totais na execuca'	, '@E 999,999,999,999,999,999'	, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'N', 'V'	, 'R'	, ' '	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', 'N'	, 'N'	, '', '', ''})
Aadd(aSX3, {cCons, '14', cPreC + '_MODOEX'	, 'C', 001, 0, 'Modo Exec.'		, 'Modo Exec.'		, 'Modo Exec.'		, 'Modo de execucao'			, 'Modo de execucao'			, 'Modo de execucao'			, ''							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), '"3"'													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'S', 'A'	, 'R'	, 'Ä'	, ''									, '1=Manual;2=Agendada;3=Ambos'																							, '', '', '', '', '', ''	, '', '', '', '', '', 'N'	, 'N'	, '', '', ''})
Aadd(aSX3, {cCons, '15', cPreC + '_FORMAT'	, 'C', 001, 0, 'Formato'		, 'Formato'			, 'Formato'			, 'Formato da saida'			, 'Formato da saida'			, 'Formato da saida'			, ''							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), '"1"'													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'S', 'A'	, 'R'	, 'Ä'	, ''									, '1=Planilha;2=CSV;3=Tabela SGBD'																						, '', '', '', '', '', ''	, '', '', '', '', '', 'N'	, 'N'	, '', '', ''})
Aadd(aSX3, {cCons, '16', cPreC + '_CAMINH'	, 'C', 150, 0, 'Path Servid.'	, 'Path Servid.'	, 'Path Servid.'	, 'Path no servidor'			, 'Path no servidor'			, 'Path no servidor'			, '@!@S100'						, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'S', 'A'	, 'R'	, ' '	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', 'N'	, 'N'	, '', '', ''})
Aadd(aSX3, {cCons, '17', cPreC + '_PADRAO'	, 'C', 001, 0, 'Padrao'			, 'Padrao'			, 'Padrao'			, 'Padrao do agendamento'		, 'Padrao do agendamento'		, 'Padrao do agendamento'		, ''							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'N', 'V', 'R'	, ' '	, ''									, '1=Diario;2=Semanal;3=Mensal;4=Anual'																					, '', '', '', '', '', ''	, '', '', '', '', '', 'N'	, 'N'	, '', '', ''})
Aadd(aSX3, {cCons, '18', cPreC + '_QTSDIA'	, 'N', 003, 0, 'Qtos Dias'		, 'Qtos Dias'		, 'Qtos Dias'		, 'A cada quantos dias?'		, 'A cada quantos dias?'		, 'A cada quantos dias?'		, '@E 999'						, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'N', 'V', 'R'	, ' '	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', 'N'	, 'N'	, '', '', ''})
Aadd(aSX3, {cCons, '19', cPreC + '_DOMING'	, 'L', 001, 0, 'Domigo'			, 'Domigo'			, 'Domigo'			, 'Executar domingo'			, 'Executar domingo'			, 'Executar domingo'			, ''							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'N', 'V', 'R'	, ' '	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', 'N'	, 'N'	, '', '', ''})
Aadd(aSX3, {cCons, '20', cPreC + '_SEGUND'	, 'L', 001, 0, 'Segunda'		, 'Segunda'			, 'Segunda'			, 'Executar segunda'			, 'Executar segunda'			, 'Executar segunda'			, ''							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'N', 'V', 'R'	, ' '	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', 'N'	, 'N'	, '', '', ''})
Aadd(aSX3, {cCons, '21', cPreC + '_TERCA'	, 'L', 001, 0, 'Terca'			, 'Terca'			, 'Terca'			, 'Executar terca'				, 'Executar terca'				, 'Executar terca'				, ''							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'N', 'V', 'R'	, ' '	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', 'N'	, 'N'	, '', '', ''})
Aadd(aSX3, {cCons, '22', cPreC + '_QUARTA'	, 'L', 001, 0, 'Quarta'			, 'Quarta'			, 'Quarta'			, 'Executar quarta'				, 'Executar quarta'				, 'Executar quarta'				, ''							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'N', 'V', 'R'	, ' '	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', 'N'	, 'N'	, '', '', ''})
Aadd(aSX3, {cCons, '23', cPreC + '_QUINTA'	, 'L', 001, 0, 'Quinta'			, 'Quinta'			, 'Quinta'			, 'Executar quinta'				, 'Executar quinta'				, 'Executar quinta'				, ''							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'N', 'V', 'R'	, ' '	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', 'N'	, 'N'	, '', '', ''})
Aadd(aSX3, {cCons, '24', cPreC + '_SEXTA'	, 'L', 001, 0, 'Sexta'			, 'Sexta'			, 'Sexta'			, 'Executar sexta'				, 'Executar sexta'				, 'Executar sexta'				, ''							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'N', 'V', 'R'	, ' '	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', 'N'	, 'N'	, '', '', ''})
Aadd(aSX3, {cCons, '25', cPreC + '_SABADO'	, 'L', 001, 0, 'Sabado'			, 'Sabado'			, 'Sabado'			, 'Executar sabado'				, 'Executar sabado'				, 'Executar sabado'				, ''							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'N', 'V', 'R'	, ' '	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', 'N'	, 'N'	, '', '', ''})
Aadd(aSX3, {cCons, '26', cPreC + '_DIAMES'	, 'N', 002, 0, 'Dia do Mes'		, 'Dia do Mes'		, 'Dia do Mes'		, 'Dia do mes para executar'	, 'Dia do mes para executar'	, 'Dia do mes para executar'	, '99'							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'N', 'V', 'R'	, ' '	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', 'N'	, 'N'	, '', '', ''})
Aadd(aSX3, {cCons, '27', cPreC + '_MES'		, 'C', 001, 0, 'Mes Execucao'	, 'Mes Execucao'	, 'Mes Execucao'	, 'Mes de execucao'				, 'Mes de execucao'				, 'Mes de execucao'				, ''							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'N', 'V', 'R'	, ' '	, ''									, '1=Janeiro;2=Fevereiro;3=Marco;4=Abril;5=Maio;6=Junho;7=Julho;8=Agosto;9=Setembro;A=Outubro;B=Novembro;C=Dezembro'	, '', '', '', '', '', ''	, '', '', '', '', '', 'N'	, 'N'	, '', '', ''})
Aadd(aSX3, {cCons, '28', cPreC + '_EXEDIA'	, 'N', 003, 0, 'Exec. no dia'	, 'Exec. no dia'	, 'Exec. no dia'	, 'Execucoes no dia'			, 'Execucoes no dia'			, 'Execucoes no dia'			, '@E 999'						, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'N', 'V', 'R'	, ' '	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', 'N'	, 'N'	, '', '', ''})
Aadd(aSX3, {cCons, '29', cPreC + '_INTERV'	, 'C', 005, 0, 'Intervalo'		, 'Intervalo'		, 'Intervalo'		, 'Intervalo entre execucoes'	, 'Intervalo entre execucoes'	, 'Intervalo entre execucoes'	, ''							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'N', 'V', 'R'	, ' '	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', 'N'	, 'N'	, '', '', ''})
Aadd(aSX3, {cCons, '30', cPreC + '_DTTERM'	, 'D', 008, 0, 'Dt. Termino'	, 'Dt. Termino'		, 'Dt. Termino'		, 'Data de termino'				, 'Data de termino'				, 'Data de termino'				, ''							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'N', 'V', 'R'	, ' '	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', 'N'	, 'N'	, '', '', ''})
Aadd(aSX3, {cCons, '31', cPreC + '_DTINI'	, 'D', 008, 0, 'Dr. Inicial'	, 'Hr. Inicial'		, 'Hr. Inicial'		, 'Hora inicial'				, 'Hora inicial'				, 'Hora inicial'				, ''							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'N', 'V', 'R'	, ' '	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', 'N'	, 'N'	, '', '', ''})
Aadd(aSX3, {cCons, '32', cPreC + '_HRINI'	, 'C', 005, 0, 'Hr. Execucao'	, 'Hr. Execucao'	, 'Hr. Execucao'	, 'Hora da primeira execucao'	, 'Hora da primeira execucao'	, 'Hora da primeira execucao'	, '99:99'						, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'N', 'V', 'R'	, ' '	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', 'N'	, 'N'	, '', '', ''})
Aadd(aSX3, {cCons, '33', cPreC + '_NXTDT'	, 'D', 008, 0, 'Proxima Data'	, 'Proxima Data'	, 'Proxima Data'	, 'Proxima data de execucao'	, 'Proxima data de execucao'	, 'Proxima data de execucao'	, ''							, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'N', 'V', 'R'	, ' '	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', 'N'	, 'N'	, '', '', ''})
Aadd(aSX3, {cCons, '34', cPreC + '_NXTHR'	, 'C', 005, 0, 'Proxima Hora'	, 'Proxima Hora'	, 'Proxima Hora'	, 'Proxima hora de execucao'	, 'Proxima hora de execucao'	, 'Proxima hora de execucao'	, '99:99'						, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128), ''													, ''	, 0, Chr(254) + Chr(192), '', '', 'U', 'N', 'V', 'R'	, ' '	, ''									, ''																													, '', '', '', '', '', ''	, '', '', '', '', '', 'N'	, 'N'	, '', '', ''})

//
// Campos Tabela Permissoes
//
Aadd(aSX3, {cPerm, '01', cPreP + '_FILIAL'	, 'C', 008, 0, 'Filial'			, 'Sucursal'		, 'Branch'			, 'Filial do Sistema'	, 'Sucursal'			, 'Branch of the System'	, '@!'			, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128), ''			, ''	, 1, Chr(254) + Chr(192), '', ''	, 'U', 'N', ''	, ''	, ''	, ''														, ''					, '', '', '', ''							, '', '033'	, '', '', '', '', '', '', '', '', '', ''})
Aadd(aSX3, {cPerm, '02', cPreP + '_CODIGO'	, 'C', 006, 0, 'Cod.Consulta'	, 'Cod.Consulta'	, 'Cod.Consulta'	, 'Codigo da Consulta'	, 'Codigo da Consulta'	, 'Codigo da Consulta'		, '@!'			, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), ''			, cSxb3	, 0, Chr(254) + Chr(192), '', 'S'	, 'U', 'S', 'A'	, 'R'	, 'Ä'	, 'U_VExtA02V("' + cPreP + '_CODIGO")'						, ''					, '', '', '', ''							, '', ''	, '', '', '', '', '', '', '', '', '', ''})
Aadd(aSX3, {cPerm, '03', cPreP + '_DESCRI'	, 'C', 060, 0, 'Descricao'		, 'Descricao'		, 'Descricao'		, 'Descricao'			, 'Descricao'			, 'Descricao'				, '@!'			, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), ''			, ''	, 0, Chr(254) + Chr(192), '', ''	, 'U', 'S', 'V'	, 'R'	, 'Ä'	, ''														, ''					, '', '', '', ''							, '', ''	, '', '', '', '', '', '', '', '', '', ''})
Aadd(aSX3, {cPerm, '04', cPreP + '_TIPO'	, 'C', 001, 0, 'Tipo'			, 'Tipo'			, 'Tipo'			, 'Tipo'				, 'Tipo'				, 'Tipo'					, ''			, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), ''			, ''	, 0, Chr(254) + Chr(192), '', ''	, 'U', 'S', 'A'	, 'R'	, 'Ä'	, 'Pertence("12") .and. U_VExtA02V("' + cPreP + '_TIPO")'	, '1=Grupo;2=Usuario'	, '', '', '', ''							, '', ''	, '', '', '', '', '', '', '', '', '', ''})
Aadd(aSX3, {cPerm, '05', cPreP + '_GRUPO'	, 'C', 006, 0, 'Cod.Grupo'		, 'Cod.Grupo'		, 'Cod.Grupo'		, 'Codigo do Grupo'		, 'Codigo do Grupo'		, 'Codigo do Grupo'			, '@!'			, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), ''			, cSxb1	, 0, Chr(254) + Chr(192), '', ''	, 'U', 'S', 'A'	, 'R'	, ''	, 'U_VExtA02V("' + cPreP + '_GRUPO")'						, ''					, '', '', '', 'M->' + cPreP + '_TIPO = "1"'	, '', ''	, '', '', '', '', '', '', '', '', '', ''})
Aadd(aSX3, {cPerm, '06', cPreP + '_NMGRP'	, 'C', 025, 0, 'Nome Grupo'		, 'Nome Grupo'		, 'Nome Grupo'		, 'Nome do Grupo'		, 'Nome do Grupo'		, 'Nome do Grupo'			, '@!'			, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), ''			, ''	, 0, Chr(254) + Chr(192), '', ''	, 'U', 'S', 'V'	, 'R'	, ''	, ''														, ''					, '', '', '', ''							, '', ''	, '', '', '', '', '', '', '', '', '', ''})
Aadd(aSX3, {cPerm, '07', cPreP + '_CODUSR'	, 'C', 006, 0, 'Cod.Usuario'	, 'Cod.Usuario'		, 'Cod.Usuario'		, 'Codigo do Usuario.'	, 'Codigo do Usuario.'	, 'Codigo do Usuario.'		, '@!'			, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), ''			, cSxb2	, 0, Chr(254) + Chr(192), '', ''	, 'U', 'S', 'A'	, 'R'	, ''	, 'U_VExtA02V("' + cPreP + '_CODUSR")'						, ''					, '', '', '', 'M->' + cPreP + '_TIPO = "2"'	, '', ''	, '', '', '', '', '', '', '', '', '', ''})
Aadd(aSX3, {cPerm, '08', cPreP + '_NMUSR'	, 'C', 025, 0, 'Nome Usuario'	, 'Nome Usuario'	, 'Nome Usuario'	, 'Nome Usuario'		, 'Nome Usuario'		, 'Nome Usuario'			, '@!'			, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), ''			, ''	, 0, Chr(254) + Chr(192), '', ''	, 'U', 'S', 'V'	, 'R'	, ''	, ''														, ''					, '', '', '', ''							, '', ''	, '', '', '', '', '', '', '', '', '', ''})
Aadd(aSX3, {cPerm, '09', cPreP + '_DTINCL'	, 'D', 008, 0, 'Dt. Inclusao'	, 'Dt. Inclusao'	, 'Dt. Inclusao'	, 'Data de Inclusao'	, 'Data de Inclusao'	, 'Data de Inclusao'		, ''			, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), 'DDATABASE'	, ''	, 0, Chr(254) + Chr(192), '', ''	, 'U', 'S', 'V'	, 'R'	, ''	, ''														, ''					, '', '', '', ''							, '', ''	, '', '', '', '', '', '', '', '', '', ''})
Aadd(aSX3, {cPerm, '10', cPreP + '_HRINCL'	, 'C', 005, 0, 'Hr. Inclusao'	, 'Hr. Inclusao'	, 'Hr. Inclusao'	, 'Hr. Inclusao'		, 'Hr. Inclusao'		, 'Hr. Inclusao'			, '@R 99:99'	, '', Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), 'TIME()'		, ''	, 0, Chr(254) + Chr(192), '', ''	, 'U', 'S', 'V'	, 'R'	, ''	, ''														, ''					, '', '', '', ''							, '', ''	, '', '', '', '', '', '', '', '', '', ''})

//
// Atualizando dicion·rio
//

nPosArq := AScan(aEstrut, {|x| AllTrim(x[1]) == "X3_ARQUIVO"})
nPosOrd := AScan(aEstrut, {|x| AllTrim(x[1]) == "X3_ORDEM"})
nPosCpo := AScan(aEstrut, {|x| AllTrim(x[1]) == "X3_CAMPO"})
nPosTam := AScan(aEstrut, {|x| AllTrim(x[1]) == "X3_TAMANHO"})
nPosSXG := AScan(aEstrut, {|x| AllTrim(x[1]) == "X3_GRPSXG"})
nPosVld := AScan(aEstrut, {|x| AllTrim(x[1]) == "X3_VALID"})

ASort(aSX3,,, {|x, y| x[nPosArq] + x[nPosOrd] + x[nPosCpo] < y[nPosArq] + y[nPosOrd] + y[nPosCpo]})

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajsuta tamanho
	//
	IF !Empty( aSX3[nI][nPosSXG] )
		SXG->( dbSetOrder( 1 ) )
		IF SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
			IF aSX3[nI][nPosTam] <> SXG->XG_SIZE
				aSX3[nI][nPosTam] := SXG->XG_SIZE
				cTexto += "O tamanho do campo " + aSX3[nI][nPosCpo] + " N√O atualizado e foi mantido em ["
				cTexto += AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF
				cTexto += "   por pertencer ao grupo de campos [" + SX3->X3_GRPSXG + "]" + CRLF + CRLF
			ENDIF
		ENDIF
	ENDIF

	SX3->( dbSetOrder( 2 ) )

	IF !( aSX3[nI][nPosArq] $ cAlias )
		cAlias += aSX3[nI][nPosArq] + "/"
		Aadd( aArqUpd, aSX3[nI][nPosArq] )
	ENDIF

	IF !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo], nTamSeek ) ) )

		//
		// Busca ultima ocorrencia do alias
		//
		IF ( aSX3[nI][nPosArq] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq]

			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + "ZZ", .T. ) )
			DbSkip( -1 )

			IF ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			ENDIF

			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		ENDIF

		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

		RecLock( "SX3", .T. )
		For nJ := 1 To Len( aSX3[nI] )
			IF     nJ == nPosOrd  // Ordem
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), cSeqAtu ) )

			ElseIf aEstrut[nJ][2] > 0
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ] ) )

			ENDIF
		Next nJ

		dbCommit()
		MsUnLock()

		cTexto += "Criado o campo " + aSX3[nI][nPosCpo] + CRLF

	ENDIF

	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3)..." )

Next nI

cTexto += CRLF + "Final da AtualizaÁ„o" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSIX
FunÁ„o de processamento da gravaÁ„o do SIX - Indices

@author TOTVS Protheus
@since  02/02/2014
@obs    Gerado por EXPORDIC - V.4.19.8.1 EFS / Upd. V.4.17.7 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSIX( cTexto )
Local aEstrut   := {}
Local aSIX      := {}
Local lAlt      := .F.
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0
Local cCons		:= U_VExtM01I("CONS")
Local cPreC		:= Iif(Left(cCons, 1) == "S", Substr(cCons, 2), cCons)
Local cPerm		:= U_VExtM01I("PERM")
Local cPreP		:= Iif(Left(cPerm, 1) == "S", Substr(cPerm, 2), cPerm)

cTexto  += "Õnicio da AtualizaÁ„o" + " SIX" + CRLF + CRLF

// Estrutura do SIX
aEstrut := { "INDICE", "ORDEM", "CHAVE", "DESCRICAO", "DESCSPA", "DESCENG", ;
             "PROPRI", "F3", "NICKNAME", "SHOWPESQ"}

//
// Tabela Consultas
//
Aadd(aSIX, {cCons, '1', cPreC + '_FILIAL+' + cPreC + '_CODIGO'						, 'Codigo'					, 'Codigo'					, 'Codigo'					, 'U', '', '', 'S'})
Aadd(aSIX, {cCons, '2', cPreC + '_FILIAL+' + cPreC + '_DESCRI+' + cPreC + '_CODIGO'	, 'Descricao+Codigo'		, 'Descricao+Codigo'		, 'Descricao+Codigo'		, 'U', '', '', 'S'})
Aadd(aSIX, {cCons, '3', cPreC + '_FILIAL+' + cPreC + '_NMPROP+' + cPreC + '_DESCRI'	, 'Nome Prop.+Descricao'	, 'Nome Prop.+Descricao'	, 'Nome Prop.+Descricao'	, 'U', '', '', 'S'})

//
// Tabela Permissıes
//
Aadd(aSIX, {cPerm, '1', cPreP + '_FILIAL+' + cPreP + '_CODIGO+' + cPreP + '_TIPO+' + cPreP + '_GRUPO'	, 'Cod.Consulta+Tipo+Cod.Grupo'		, 'Cod.Consulta+Tipo+Cod.Grupo'		, 'Cod.Consulta+Tipo+Cod.Grupo'		, 'U', '', '', 'S'})
Aadd(aSIX, {cPerm, '2', cPreP + '_FILIAL+' + cPreP + '_CODIGO+' + cPreP + '_TIPO+' + cPreP + '_CODUSR'	, 'Cod.Consulta+Tipo+Cod.Usuario'	, 'Cod.Consulta+Tipo+Cod.Usuario'	, 'Cod.Consulta+Tipo+Cod.Usuario'	, 'U', '', '', 'S'})
Aadd(aSIX, {cPerm, '3', cPreP + '_FILIAL+' + cPreP + '_DESCRI+' + cPreP + '_TIPO+' + cPreP + '_CODUSR'	, 'Descricao+Tipo+Cod.Usuario'		, 'Descricao+Tipo+Cod.Usuario'		, 'Descricao+Tipo+Cod.Usuario'		, 'U', '', '', 'S'})
Aadd(aSIX, {cPerm, '4', cPreP + '_FILIAL+' + cPreP + '_DESCRI+' + cPreP + '_TIPO+' + cPreP + '_GRUPO'	, 'Descricao+Tipo+Cod.Grupo'		, 'Descricao+Tipo+Cod.Grupo'		, 'Descricao+Tipo+Cod.Grupo'		, 'U', '', '', 'S'})

//
// Atualizando dicion·rio
//
oProcess:SetRegua2( Len( aSIX ) )

dbSelectArea( "SIX" )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )

	lAlt    := .F.
	lDelInd := .F.

	IF !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
		cTexto += "Õndice criado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] + CRLF
	Else
		lAlt := .T.
		Aadd( aArqUpd, aSIX[nI][1] )
		IF !StrTran( Upper( AllTrim( CHAVE )       ), " ", "") == ;
		    StrTran( Upper( AllTrim( aSIX[nI][3] ) ), " ", "" )
			cTexto += "Chave do Ìndice alterado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] + CRLF
			lDelInd := .T. // Se for alteraÁ„o precisa apagar o indice do banco
		ENDIF
	ENDIF

	RecLock( "SIX", !lAlt )
	For nJ := 1 To Len( aSIX[nI] )
		IF FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
		ENDIF
	Next nJ
	MsUnLock()

	dbCommit()

	IF lDelInd
		TcInternal( 60, RetSqlName( aSIX[nI][1] ) + "|" + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] )
	ENDIF

	oProcess:IncRegua2( "Atualizando Ìndices..." )

Next nI

cTexto += CRLF + "Final da AtualizaÁ„o" + " SIX" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSXB
FunÁ„o de processamento da gravaÁ„o do SXB - Consultas Padrao

@author TOTVS Protheus
@since  02/02/2014
@obs    Gerado por EXPORDIC - V.4.19.8.1 EFS / Upd. V.4.17.7 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSXB( cTexto )
Local aEstrut   := {}
Local aSXB      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local cCons		:= U_VExtM01I("CONS")
Local cPreC		:= Iif(Left(cCons, 1) == "S", Substr(cCons, 2), cCons)
Local cPerm		:= U_VExtM01I("PERM")
Local cPreP		:= Iif(Left(cPerm, 1) == "S", Substr(cPerm, 2), cPerm)
Local cSxb1		:= U_VExtM01I("SXB1")
Local cSxb2		:= U_VExtM01I("SXB2")
Local cSxb3		:= U_VExtM01I("SXB3")
Local cSxb4		:= U_VExtM01I("SXB4")

cTexto  += "Õnicio da AtualizaÁ„o" + " SXB" + CRLF + CRLF

aEstrut := { "XB_ALIAS", "XB_TIPO", "XB_SEQ", "XB_COLUNA", "XB_DESCRI", "XB_DESCSPA", ;
             "XB_DESCENG", "XB_CONTEM", "XB_WCONTEM"}

//
// Consulta GRP (000001)
//
Aadd(aSXB, {cSxb1, '1', '01', 'GR'	, 'Grupo de Usu·rios'	, 'Grupo de Usuarios'	, 'User Group'	, ''	, ''})
Aadd(aSXB, {cSxb1, '5', '01', ''	, ''					, ''					, ''			, 'ID'	, ''})

//
// Consulta USR (000002)
//
Aadd(aSXB, {cSxb2, '1', '01', 'US'	, 'Usu·rios'	, 'Usuarios'	, 'Users'	, ''	, ''})
Aadd(aSXB, {cSxb2, '5', '01', ''	, ''			, ''			, ''		, 'ID'	, ''})

//
// Consulta Z09 (000003)
//
Aadd(aSXB, {cSxb3, '1', '01', 'DB'	, 'Cadastro Consultas'	, 'Cadastro Consultas'		, 'Cadastro Consultas'	, cCons								, ''})
Aadd(aSXB, {cSxb3, '2', '01', '01'	, 'Codigo'				, 'Codigo'					, 'Codigo'				, ''								, ''})
Aadd(aSXB, {cSxb3, '4', '01', '01'	, 'Codigo'				, 'Codigo'					, 'Codigo'				, cPreC + '_CODIGO'					, ''})
Aadd(aSXB, {cSxb3, '4', '01', '02'	, 'Descricao'			, 'Descricao'				, 'Descricao'			, cPreC + '_DESCRI'					, ''})
Aadd(aSXB, {cSxb3, '5', '01', ''	, ''					, ''						, ''					, cCons + '->' + cPreC + '_CODIGO'	, ''})
Aadd(aSXB, {cSxb3, '5', '02', ''	, ''					, ''						, ''					, cCons + '->' + cPreC + '_DESCRI'	, ''})

//
// Consulta Z09USR (000004)
//
Aadd(aSXB, {cSxb4, '1', '01', 'US'	, 'Proprietario'	, 'Proprietario'	, 'Proprietario'	, ''			, ''})
Aadd(aSXB, {cSxb4, '5', '01', ''	, ''				, ''				, ''				, 'ID'			, ''})
Aadd(aSXB, {cSxb4, '5', '02', ''	, ''				, ''				, ''				, 'FULLNAME'	, ''})

//
// Atualizando dicion·rio
//
oProcess:SetRegua2( Len( aSXB ) )

dbSelectArea( "SXB" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXB )

	IF !Empty( aSXB[nI][1] )

		IF !SXB->( dbSeek( PadR( aSXB[nI][1], Len( SXB->XB_ALIAS ) ) + aSXB[nI][2] + aSXB[nI][3] + aSXB[nI][4] ) )

			IF !( aSXB[nI][1] $ cAlias )
				cAlias += aSXB[nI][1] + "/"
				cTexto += "Foi incluÌda a consulta padr„o " + aSXB[nI][1] + CRLF
			ENDIF

			RecLock( "SXB", .T. )

			For nJ := 1 To Len( aSXB[nI] )
				IF !Empty( FieldName( FieldPos( aEstrut[nJ] ) ) )
					FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
				ENDIF
			Next nJ

			dbCommit()
			MsUnLock()

		Else

			//
			// Verifica todos os campos
			//
			For nJ := 1 To Len( aSXB[nI] )

				//
				// Se o campo estiver diferente da estrutura
				//
				IF aEstrut[nJ] == SXB->( FieldName( nJ ) ) .AND. ;
					!StrTran( AllToChar( SXB->( FieldGet( nJ ) ) ), " ", "" ) == ;
					 StrTran( AllToChar( aSXB[nI][nJ]            ), " ", "" )

					cMsg := "A consulta padr„o " + aSXB[nI][1] + " est· com o " + SXB->( FieldName( nJ ) ) + ;
					" com o conte˙do" + CRLF + ;
					"[" + RTrim( AllToChar( SXB->( FieldGet( nJ ) ) ) ) + "]" + CRLF + ;
					", e este È diferente do conte˙do" + CRLF + ;
					"[" + RTrim( AllToChar( aSXB[nI][nJ] ) ) + "]" + CRLF +;
					"Deseja substituir ? "

					IF      lTodosSim
						nOpcA := 1
					ElseIf  lTodosNao
						nOpcA := 2
					Else
						nOpcA := Aviso( "ATUALIZA«√O DE DICION¡RIOS E TABELAS", cMsg, { "Sim", "N„o", "Sim p/Todos", "N„o p/Todos" }, 3, "DiferenÁa de conte˙do - SXB" )
						lTodosSim := ( nOpcA == 3 )
						lTodosNao := ( nOpcA == 4 )

						IF lTodosSim
							nOpcA := 1
							lTodosSim := MsgNoYes( "Foi selecionada a opÁ„o de REALIZAR TODAS alteraÁıes no SXB e N√O MOSTRAR mais a tela de aviso." + CRLF + "Confirma a aÁ„o [Sim p/Todos] ?" )
						ENDIF

						IF lTodosNao
							nOpcA := 2
							lTodosNao := MsgNoYes( "Foi selecionada a opÁ„o de N√O REALIZAR nenhuma alteraÁ„o no SXB que esteja diferente da base e N√O MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta aÁ„o [N„o p/Todos]?" )
						ENDIF

					ENDIF

					IF nOpcA == 1
						RecLock( "SXB", .F. )
						FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
						dbCommit()
						MsUnLock()

						IF !( aSXB[nI][1] $ cAlias )
							cAlias += aSXB[nI][1] + "/"
							cTexto += "Foi alterada a consulta padr„o " + aSXB[nI][1] + CRLF
						ENDIF

					ENDIF

				ENDIF

			Next

		ENDIF

	ENDIF

	oProcess:IncRegua2( "Atualizando Consultas Padrıes (SXB)..." )

Next nI

cTexto += CRLF + "Final da AtualizaÁ„o" + " SXB" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return NIL




Static Function EscEmpresa()
Local oDlg, oChkMar, oLbxoMascEmp, oMascFil, oButMarc, oButDMar, oButInv, oSay
Local aSalvAmb	:= GetArea()
Local aSalvSM0	:= {}
Local aRet		:= {}
Local aVetor	:= {}
Local oOk		:= LoadBitmap(GetResources(), "LBOK")
Local oNo		:= LoadBitmap(GetResources(), "LBNO")
Local lChk		:= .F.
Local lOk		:= .F.
Local lTeveMarc	:= .F.
Local cVar		:= ""
Local cNomEmp	:= ""
Local cMascEmp	:= "??"
Local cMascFil	:= "??"
Local aMarcadas	:= {}

IF !MyOpenSm0(.F.)
	Return(aRet)
ENDIF

DbSelectArea("SM0")
aSalvSM0	:= SM0->(GetArea())
DbSetOrder( 1 )
DbGoTop()

WHILE !SM0->(Eof())
	IF AScan(aVetor, {|x| x[2] == SM0->M0_CODIGO}) == 0
		Aadd(aVetor, {;
			AScan(aMarcadas, {|x| x[1] == SM0->M0_CODIGO .AND. x[2] == SM0->M0_CODFIL}) > 0, ;
			SM0->M0_CODIGO, ;
			SM0->M0_CODFIL, ;
			SM0->M0_NOME, ;
			SM0->M0_FILIAL ;
			})
	ENDIF

	DbSkip()
ENDDO

RestArea(aSalvSM0)

DEFINE MSDIALOG oDlg TITLE "" FROM 000, 000 TO 270, 396 PIXEL

oDlg:cToolTip	:= "Tela para M˙ltiplas SeleÁıes de Empresas/Filiais"
oDlg:cTitle		:= "Selecione a(s) Empresa(s) para AtualizaÁ„o"

@ 010, 010 LISTBOX oLbx VAR cVar FIELDS HEADER " ", " ", "Empresa" SIZE 178, 095 OF oDlg PIXEL
oLbx:SetArray(aVetor)
oLbx:bLine	:= {|| {;
					Iif(aVetor[oLbx:nAt, 1], oOk, oNo), ;
					aVetor[oLbx:nAt, 2], ;
					aVetor[oLbx:nAt, 4];
				}}
oLbx:BlDblClick	:= { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos(aVetor, @lChk, oChkMar), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip	:=  oDlg:cTitle
oLbx:lHScroll	:= .F. // NoScroll

@ 112, 010 CHECKBOX oChkMar VAR lChk PROMPT "Todos" MESSAGE SIZE 040, 007 PIXEL OF oDlg ;
	ON CLICK (AEval(aVetor, {|z, y| aVetor[y, 1] := lChk}), oLbx:Refresh())

@ 123, 010 BUTTON oButInv PROMPT "&Inverter" SIZE 032, 012 PIXEL ;
	ACTION (AEval(aVetor, {|z, y| aVetor[y, 1] := !aVetor[y, 1]}), oLbx:Refresh(), VerTodos(aVetor, @lChk, oChkMar)) ;
	MESSAGE "Inverter SeleÁ„o" OF oDlg

// Marca/Desmarca por mascara
@ 113, 051 SAY oSay Prompt "Empresa" Size 040, 008 OF oDlg PIXEL
@ 112, 080 MSGET oMascEmp VAR cMascEmp SIZE 005, 005 PIXEL PICTURE "@!" ;
	VALID (cMascEmp := StrTran(cMascEmp, " ", "?" ), cMascFil := StrTran(cMascFil, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
	MESSAGE "M·scara Empresa ( ?? )" OF oDlg
@ 123, 050 BUTTON oButMarc PROMPT "&Marcar" SIZE 032, 012 PIXEL ACTION (MarcaMas(oLbx, aVetor, cMascEmp, .T.), VerTodos(aVetor, @lChk, oChkMar)) ;
	MESSAGE "Marcar usando m·scara ( ?? )" OF oDlg
@ 123, 080 BUTTON oButDMar PROMPT "&Desmarcar" SIZE 032, 012 PIXEL ACTION (MarcaMas(oLbx, aVetor, cMascEmp, .F.), VerTodos(aVetor, @lChk, oChkMar)) ;
	MESSAGE "Desmarcar usando m·scara ( ?? )" OF oDlg

DEFINE SBUTTON FROM 111, 125 TYPE 1 ACTION (RetSelecao(@aRet, aVetor), oDlg:End()) ONSTOP "Confirma a SeleÁ„o" ENABLE OF oDlg
DEFINE SBUTTON FROM 111, 158 TYPE 2 ACTION (Iif(lTeveMarc, aRet :=  aMarcadas, .T.), oDlg:End()) ONSTOP "Abandona a SeleÁ„o" ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTER

RestArea(aSalvAmb)
DbSelectArea("SM0")
DbCloseArea()

Return(aRet)


//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
FunÁ„o auxiliar que monta o retorno com as seleÁıes

@param aRet    Array que ter· o retorno das seleÁıes (È alterado internamente)
@param aVetor  Vetor do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	IF aVetor[nI][1]
		Aadd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	ENDIF
Next nI

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
FunÁ„o para marcar/desmarcar usando m·scaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a m·scara (???)
@param lMarDes  Marca a ser atribuÌda .T./.F.

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	IF cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		IF cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] := lMarDes
		ENDIF
	ENDIF
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


STATIC FUNCTION VerTodos(aVetor, lChk, oChkMar)
Local lTTrue	:= .T.
Local nI		:= 0

FOR nI := 1 TO Len(aVetor)
	lTTrue	:= Iif(!aVetor[nI][1], .F., lTTrue)
NEXT

lChk	:= lTTrue
oChkMar:Refresh()

RETURN


STATIC FUNCTION MyOpenSM0(lShared)
Local lOpen	:= .F.
Local nLoop	:= 0

FOR nLoop := 1 TO 20
	DbUseArea(.T.,, "SIGAMAT.EMP", "SM0", lShared, .F.)

	IF !Empty(Select("SM0"))
		lOpen	:= .T.
		DbSetIndex( "SIGAMAT.IND" )
		EXIT
	ENDIF

	Sleep(500)
NEXT

IF !lOpen
	MsgStop( "N„o foi possÌvel a abertura da tabela " + ;
		Iif(lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATEN«√O" )
ENDIF

Return(lOpen)


/////////////////////////////////////////////////////////////////////////////
