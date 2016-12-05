#include "protheus.ch"

USER FUNCTION V3ExtA04(cQuery, lGeraCSV, xP3, cCodCons)
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : Valida a sintaxe e executa a consulta cadastrada
<Data> : 28/09/2016
<Parametros> : cQuery, lGeraCSV, xP3, cCodCons
	cQuery		: Sintaze query para validaÁ„o
	lGeraCSV	: Se .t., gera arquivo em disco
	xP3			: sem funcionalidade - mantido para compatiblizar com chamada por mBrowse
	cCodCons	: cÛdigo do cadastro da consulta em execuÁ„o
<Retorno> : LÛgico
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local aAreaOld	:= GetArea()
Local cQry		:= GetNextAlias()
Local aSize		:= {}
Local cTagMI	:= "%|"
Local cTagMF	:= "|%"
Local lErroSQL	:= .F.
Local lSQL		:= .T.
Local bBlock	:= {|| }
Local aParms	:= {}
Local aCpos		:= {}
Local aStrutCPO	:= {} 
Local n1		:= 0
Local n2		:= 0
Local n3		:= 0
Local n4		:= 0
Local n5		:= 0
Local cPatchCsv	:= ""
Local nSecIni	:= 0
Local nSecTot	:= 0
Local cCons		:= U_VExtM01I("CONS")
Local cPreC		:= Iif(Left(cCons, 1) == "S", Substr(cCons, 2), cCons)
Local nTamExe	:= TamSx3(cPreC + "_TOTEXE")[1]
Local nTamMin	:= TamSx3(cPreC + "_TOTMIN")[1]
Local nLenCmp	:= Len(SX3->X3_CAMPO)
Local cLoad		:= ""
Local cParRet	:= ""
Local aTitPar	:= {}
Local nPosPar	:= 0
Local nFormat	:= 0
Local cTable	:= ""
Local cModoEx	:= ""
Local cBkpUsr	:= ""
Private bErrorBlockSave	:= { |e| LocalChecErro(e) }
Private cMsgErro		:= ""
Private nSecFim			:= -1
Private lErSQL			:= .F.

//Default cQuery 		:= &("M->" + cPreC + "_SQL")
Default lGeraCSV	:= .F.

IF ValType(cQuery) == "U"	// Se n„o foi enviado o par‚metro, È a validaÁ„o do TudoOk() do cadastro
	cQuery 		:= &("M->" + cPreC + "_SQL")
	cModoEx		:= &("M->" + cPreC + "_MODOEX")	// Modo de execuÁ„o: 1=Manual; 2=Agendada; 3=Ambos
	cCodCons	:= &("M->" + cPreC + "_CODIGO")
ENDIF

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Montagem do script sql   ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
IF !Empty(cQuery) 
	IF At("DELETE", Upper(cQuery)) > 0 .OR.;
	       At("INSERT", Upper(cQuery)) > 0 .OR.;
		   At("TRUNCATE ", Upper(cQuery)) > 0 .OR.; 
		   At("UPDATE", Upper(cQuery)) > 0 .OR.;
		   At(" INTO ", Upper(cQuery)) > 0 
	   Aviso("AtenÁ„o", "As palavras DELETE, INSERT, INTO, TRUNCATE, UPDATE, n„o podem serem utilizadas para n„o comprometer a seguranÁa do BD!", {"OK"})
	   Return .F.
	ENDIF
	IF "ORDER BY" $ Upper(cQuery)
		Aviso("Cl·usula ORDER BY", "Evite utilizar a cl·usula 'ORDER BY' nas consultas. Se utilizada no agendamento ir· provocar erro fatal. " + CRLF + ;
			"Prefira ordenar os registro no arquivo / tabela de resultado.", {"Fechar"})
	ENDIF
	
	//MacroSubstituicao da query
	n1		:= 0
	n2		:= 0
	cLinha	:= ""
	lErSQL	:= .F.
	lSQL	:= .T.
	DO WHILE .T.
		//Tags de macrosubstituicao		
		n1	:= At("%|", SubStr(cQuery, 1	, Len(cQuery)))
		n4	:= At("%|", SubStr(cQuery, n1+2	, Len(cQuery)))			
		n2	:= At("|%", SubStr(cQuery, n1	, Len(cQuery)))
		IF n2 == 0 
			IF n1 > 0 
				Alert("Estrutura sem a tag de finalizaÁ„o -> |% !")
				lSQL	:= .F.
			ENDIF
		ELSEIF n2 > 0 .and. n1 == 0 	
			Alert("Estrutura sem a tag de inicializaÁ„o -> %| !")
			lSQL	:= .F.
		ELSEIF n4 < n2 .and. n4 > 0 
			Alert("Estrutura sem a tag de finalizaÁ„o -> |% !")
			lSQL	:= .F.
		ENDIF
		IF !lSql .OR. (n1 == 0 .AND. n4 == 0 .AND. n2 == 0)
			EXIT
		ENDIF
		cLinha := SubString(cQuery,n1+2,n2-3)
		
		_xSQL(@cLinha)
		
		IF !lErSQL
			IF ValType(cLinha) == "C"
				cQuery	:= SubString(cQuery, 1, n1 - 1) + cLinha + SubStr(cQuery, n2 + 1 + n1, Len(cQuery))
			ENDIF
		ELSE
			EXIT
		ENDIF
	ENDDO
	lErroSQL	:= lErSQL
	
	
	//Tratamento dos parametros
	IF !lErroSQL .AND. lSQL
		n1			:= 0
		n2			:= 0
		n3			:= 0
		n4			:= 0
		n5			:= 0 
		cLinha		:= ""
		cTitPar		:= ""
		cTipoPar	:= ""
		nTamPar		:= 0
		cTamPar		:= ""
		lErSQL		:= .F.
		lSQL		:= .T.
		DO WHILE .T.
			n1	:= At("&|", SubStr(cQuery, 1		, Len(cQuery)))
			n4	:= At("&|", SubStr(cQuery, n1 + 2	, Len(cQuery)))
			n2	:= At("|&", SubStr(cQuery, n1		, Len(cQuery)))
			IF n2 == 0 
				IF n1 > 0
					Alert("Estrutura sem a tag de finalizaÁ„o -> |& !")
					lSQL	:= .F.
				ENDIF
			ELSEIF n2 > 0 .and. n1 == 0 	
				Alert("Estrutura sem a tag de inicializaÁ„o -> &| !")
				lSQL	:= .F.
			ELSEIF n4 < n2 .and. n4 > 0 
				Alert("Estrutura sem a tag de finalizaÁ„o -> |& !")				 			
				lSQL	:= .F.
			ENDIF
			IF !lSql .OR. (n1 == 0 .AND. n4 == 0 .AND. n2 == 0)
				EXIT
			ENDIF
			
			cLinha		:= SubStr(cQuery, n1 + 2, n2 - 3)
			n3			:= At("|T", SubStr(cLinha, 1, Len(cLinha)))						
			cTitPar		:= SubStr(cLinha, 1, n3 - 1)
			cTipoPAR	:= SubStr(cLinha, n3 + 2, 1)
			cTamPAR		:= SubStr(cLinha, n3 + 3, Len(cLinha))
			nInt		:= 0 
			nDec		:= 0   
			n5			:= 0            
			lDec		:= .T.
			IF !Empty(cTamPAR)     
				cTamPar	:= StrTran(cTamPar, ".", ",")
				n5		:= At(",", cTamPar)                      
				IF n5 == 0 
					lDec	:= .F.
				ENDIF
				
				bBlock	:= ErrorBlock( { || nInt := 0 } )	
				BEGIN SEQUENCE
					nInt	:= Val(Substr(cTamPar, 1, Iif(lDec, n5, Len(cTamPar))))
				END	SEQUENCE
				
				IF nInt > 0 .and. lDec
					bBlock	:= ErrorBlock( { || nDec := 0 } )	
					BEGIN SEQUENCE
						nDec	:= Val(Substr(cTamPar, n5+1, Len(cTamPar)))					
					END	SEQUENCE
				ENDIF
			ENDIF
			IF cTipoPar == "D"
				nInt	:= 12
			ENDIF
			IF (nInt == 0 .OR. !(cTipoPar$("CDN"))) .AND. !Empty(cTitPar) .OR. n3 == 0 
				Aviso("AtenÁ„o", "ConfiguraÁ„o de parametros incorreta!", {"OK"})
				lSQL	:= .F.
				EXIT
			ENDIF
						    
			cTitPar	:= StrTran(cTitPar, "?", "")		
			nPosPar	:= AScan(aTitPar, {|z| z[1] == cTitPar})
			
			IF nPosPar == 0
				IF cTipoPar == "C"
					Aadd(aParms, {1, cTitPar, Space(nInt), "", "", "", "", nInt * 4, .F.})
				ELSEIF cTipoPar == "D"	
					Aadd(aParms,{1,cTitPar,CTOD("  /  /  "),"@D","","","",nInt*4,.F.})			
				ELSEIF cTipoPar == "N"	                               
					IF nDec > 0 
						Aadd(aParms,{1,cTitPar,0,"@E "+REPLICATE("9",nInt-1)+"."+REPLICATE("9",nDec),"","","",(nInt + nDec) *4,.F.})			
					ELSE
						Aadd(aParms,{1,cTitPar,0,"@E "+REPLICATE("9",nInt-1),"","","",nInt*4,.F.})			
					ENDIF
				ENDIF
				Aadd(aTitPar, {cTitPar, StrZero(Len(aParms), 6)})
				nPosPar	:= Len(aTitPar)
			ENDIF
			cQuery := SubString(cQuery, 1, n1 - 1) + "<#" + aTitPar[nPosPar, 2] + "#>" + SubString(cQuery, n2 + 1 + n1, Len(cQuery))
		
		EndDo
		lErroSQL := lErSQL		
		
	ENDIF
	
	//Tratamento de campos
	IF !lErroSQL .AND. lSQL
		    
		//Exibicao da tela de parametros
		IF lSql .and. (lGeraCSV .OR. cModoEx $ "2|3")
			IF !Empty(cModoEx) .OR. IsBlind()
				cLoad	:= "JOB000_" + ProcName(0)
				IF Len(aParms) > 0
					Aviso("ExecuÁ„o autom·tica", "A seguir ser· aberta a tela de par‚metros para que vocÍ possa configurar os valores que ser„o " + ;
						"considerados pela consulta agendada!", {"Continuar"})
				ENDIF
				cBkpUsr		:= __cUserID
				__cUserID	:= "JOB000"
			ELSE
				cLoad	:= __cUserID + "_" + ProcName(0)
			ENDIF

			aRet := {}
			FOR n1 := 1 TO Len(aParms)
				cParRet	:= ParamLoad(cLoad, aParms, n1, "<*>")
				IF IsBlind()
					Aadd(aRet, cParRet)
				ENDIF
				IF (ValType(cParRet) == "C" .AND. cParRet == "<*>") .OR. ValType(cParRet) # ValType(aParms[n1, 3])
					IF IsSrvUnix()
						FErase("/PROFILE/" + Alltrim(cLoad) + ".PRB")
					ELSE
						FErase("\PROFILE\" + Alltrim(cLoad) + ".PRB")
					ENDIF
					EXIT
				ENDIF
			NEXT
			
			IF Len(aParms) == 0 .OR. IsBlind() .OR. (lRet := ParamBox(aParms, "Par‚metros", @aRet,,,,,,,, .t., .t.))
				IF lGeraCSV
					nSecIni	:= Int(Seconds())
					
					(cCons)->(DbSetOrder(1))
					IF (cCons)->(DbSeek(xFilial(cCons) + cCodCons, .f.))
						nFormat	:= Val((cCons)->(FieldGet(FieldPos(cPreC + "_FORMAT"))))
					ENDIF
					
					cPatchCsv	:= Alltrim((cCons)->(FieldGet(FieldPos(cPreC + "_CAMINH"))))
					IF nFormat < 3 .AND. !IsBlind()
						cPatchCsv := cGetFile("","Local",0,"",.T.,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE)
						IF Empty(Alltrim(cPatchCsv))
							Aviso("Destino do arquivo", "Destino do arquivo inv·lido. Ser· gravado no diretÛrio tempor·rio da m·quina local.", {"Ok"})
							cPatchCsv	:= GetTempPath()
						ENDIF
					ENDIF
					
					ProcRegua(0)
					IncProc("Executando a consulta...")
					ProcessMessages()
					
					FOR n1 := 1 TO Len(aRet)
						IF ValType(aRet[n1]) == "D"
							cQuery	:= StrTran(cQuery, "<#" + StrZero(n1, 6) + "#>", Dtos(aRet[n1]))
						ELSEIF ValType(aRet[n1]) == "C"
							cQuery	:= StrTran(cQuery, "<#" + StrZero(n1, 6) + "#>", aRet[n1])						
						ELSEIF ValType(aRet[n1]) == "N"
							cQuery	:= StrTran(cQuery, "<#" + StrZero(n1, 6) + "#>", Alltrim(Str(aRet[n1])))						
						ENDIF
					NEXT
					
					cMsgErro	:= ""
					IF nFormat < 3
						ErrorBlock(bErrorBlockSave)
						BEGIN SEQUENCE
							DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cQry, .T., .F.)
						RECOVER
							lErroSql	:= .f.
						END SEQUENCE
					ELSE
						cTable	:= "V3EXTA01_" + (cCons)->(FieldGet(FieldPos(cPreC + "_CODIGO"))) + "_" + __cUserID + "_" + Dtos(Date()) + ;
									StrTran(Time(), ":", "")
						IF TcSqlExec("SELECT * INTO " + cTable + " FROM (" + cQuery + ") " + Iif(Alltrim(Upper(TcGetDb())) == "ORACLE", "", "AS T")) < 0
							cMsgErro	:= "Erro na criaÁ„o do arquivo no banco de dados."
						ELSE
							Aviso("Consulta " + (cCons)->(FieldGet(FieldPos(cPreC + "_CODIGO"))), "Resultado da consulta gerado no BD na tabela:" + CRLF + ;
								cTable, {"Ok"}, 3)
						ENDIF
					ENDIF
					IF !Empty(cMsgErro)
						Aviso("Erro SQL", "Erro na execuÁ„o da consulta:" + CRLF + Alltrim(TcSqlError()), {"Ok"}, 3)
					ENDIF
					ErrorBlock(bErrorBlockSave)
					IF Empty(cMsgErro)
						IF nFormat < 3
							aCpos := (cQry)->(DbStruct())
						ENDIF
						IF Len(aCpos) > 0 .OR. nFormat == 3
							SX3->(DbSetOrder(2))//CAMPO
							FOR n1 := 1 TO Len(aCpos)
								IF SX3->(DbSeek(Padr(aCPOS[n1, 1], nLenCmp)))			
									Aadd(aStrutCPO, {SX3->X3_TITULO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_CAMPO, SX3->X3_PICTURE})
								ELSE
									Aadd(aStrutCPO, {aCpos[n1, 1], aCpos[n1, 2], aCpos[n1, 3], aCpos[n1, 4], aCpos[n1,1], Iif(aCpos[n1, 2]== "D", "@D", "")})
								ENDIF
							NEXT
							
							IF nFormat == 2
								_xExcelCSV(aStrutCPO, cQry, cPatchCsv)
							ELSEIF nFormat == 1
								GeraXls(aStrutCPO, cQry, cPatchCsv, cCodCons)
							ENDIF
							IF nSecFim >= 0
								IF nSecIni > nSecFim
									nSecTot	:= (86400 - nSecIni) + nSecFim
								ELSE
									nSecTot	:= nSecFim - nSecIni
								ENDIF
								(cCons)->(DbSetOrder(1))
								IF (cCons)->(DbSeek(xFilial(cCons) + cCodCons, .f.))
									RecLock(cCons, .f.)
										IF Val(Replicate("9", nTamExe)) <= (cCons)->(FieldGet(FieldPos(cPreC + "_TOTEXE"))) + 1 .OR. ;
												Val(Replicate("9", nTamMin)) <= (cCons)->(FieldGet(FieldPos(cPreC + "_TOTMIN"))) + Round(nSecTot / 60, 0)
											(cCons)->(FieldPut(FieldPos(cPreC + "_TOTEXE"), 1))
											(cCons)->(FieldPut(FieldPos(cPreC + "_TOTMIN"), Round(nSecTot / 60, 0)))
										ELSE
											(cCons)->(FieldPut(FieldPos(cPreC + "_TOTEXE"), FieldGet(FieldPos(cPreC + "_TOTEXE")) + 1))
											(cCons)->(FieldPut(FieldPos(cPreC + "_TOTMIN"), FieldGet(FieldPos(cPreC + "_TOTMIN")) + Round(nSecTot / 60, 0)))
										ENDIF
										IF (cCons)->(FieldGet(FieldPos(cPreC + "_TOTEXE"))) > 0
											IF (cCons)->(FieldGet(FieldPos(cPreC + "_TOTMIN")) / FieldGet(FieldPos(cPreC + "_TOTEXE"))) < 1
												(cCons)->(FieldPut(FieldPos(cPreC + "_EXEMED"), "< 1 MINUTO"))
											ELSE
												(cCons)->(FieldPut(FieldPos(cPreC + "_EXEMED"), ;
													Alltrim(Transform(Int(FieldGet(FieldPos(cPreC + "_TOTMIN")) / FieldGet(FieldPos(cPreC + "_TOTEXE"))), ;
													"@E 99,999,999,999,999")) + " MINUTO(S)"))
											ENDIF
										ENDIF
									MsUnlock()
								ENDIF
							ENDIF
						ENDIF
					ENDIF
				ENDIF
			ENDIF
			__cUserID	:= cBkpUsr
		ENDIF
	ENDIF
ENDIF

RestArea(aAreaOld)
Return(!lErroSQL .and. lSQL)

STATIC FUNCTION LocalChecErro(e)
// obs: o objeto "e" traz v·rias informaÁıes sobre o erro e podem ser feitos v·rios tratamentos
// forÁa o retorno para a linha do RECOVER
cMsgErro	:= e:Description
RETURN

STATIC FUNCTION _xSQL(cLinha)
Local bBlock	:= ErrorBlock( { || Aviso("AtenÁ„o", "Erro na execuÁ„o do trecho: " + cLinha, {"OK"}), lErSQL := .t.})

BEGIN SEQUENCE
  cLinha := &(cLinha)
END SEQUENCE	
RETURN

STATIC FUNCTION GeraXls(aStrutCPO, cQry, cPatchCsv, cNumCons)
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : Gera o arquivo no formato XML
<Data> : 28/09/2016
<Parametros> : aStrutCPO, cQry, cPatchCsv, cNumCons
	aStrutCPO	: Estrutura de campos de origem
	cQry		: Alias com o resultado da consulta
	cPatchCsv	: Caminho de destino do arquivo
	cNumCons	: Id da consulta em execuÁ„o
<Retorno> : Nenhum
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local oExcel	:= FwMsExcel():New()
Local cWrkSht	:= "Consulta " + cNumCons
Local cTitTbl	:= "Resultado da Consulta " + cNumCons + " - " + Dtoc(Date()) + "-" + Time()
Local nFormat	:= 0
Local aLinha	:= {}
Local nTotReg	:= 0
Local n1		:= 0
Local cConsFile	:= "V3EXTA01_" + cNumCons + "_" + __cUserID + "_" + StrTran(Time(), ":", "") + ".xml"
Local cPath		:= Alltrim(GetSrvProfString("STARTPATH", ""))
Local lCopy		:= .f.
Local cArqCsv	:= ""

IF IsSrvUnix()
	cPath	+= Iif(Right(cPath, 1) # "/", "/", "")
ELSE
	cPath	+= Iif(Right(cPath, 1) # "\", "\", "")
ENDIF
IF IsBlind()
	cConsFile	:= cPatchCsv + cConsFile
ENDIF
IF File(cConsFile)
	FErase(cConsFile)
ENDIF

oExcel:AddWorkSheet(cWrkSht)
oExcel:AddTable(cWrkSht, cTitTbl)

// Aadd(aStrutCPO, {SX3->X3_TITULO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_CAMPO, SX3->X3_PICTURE})
// Adiciona as colunas da tabela
FOR n1 := 1 TO Len(aStrutCPO)
	IF aStrutCPO[n1, 2] == "N"
		nFormat	:= 2
	ELSEIF aStrutCPO[n1, 2] == "D"
		nFormat	:= 4
	ELSE
		nFormat	:= 1
	ENDIF
	
	oExcel:AddColumn(cWrkSht, cTitTbl, aStrutCPO[n1, 1], 1, nFormat, .f.)
NEXT

(cQry)->(DbGoTop())
(cQry)->(DbEval({|| nTotReg++}))
(cQry)->(DbGoTop())
ProcRegua(nTotReg)

//Acrescentando os itens
WHILE !(cQry)->(Eof())
	IncProc("Gerando planilha...")
	
	aLinha	:= {}
	FOR n1 := 1 TO Len(aStrutCPO)
		Aadd(aLinha, (cQry)->(FieldGet(n1)))
	NEXT
	oExcel:AddRow(cWrkSht, cTitTbl, AClone(aLinha))
	
	(cQry)->(DbSkip())	
ENDDO
oExcel:Activate()
oExcel:GetXmlFile(cConsFile)

IF !IsBlind()
	MsgRun("Transferindo para a m·quina local...",, {|| lCopy := CpyS2T(cPath + cConsFile, Alltrim(cPatchCsv))})
	
	IF lCopy
		cArqCsv	:= cPatchCsv + cConsFile
		IF " " $ Alltrim(cArqCsv)
			cArqCsv	:= '"' + cArqCsv + '"'
		ENDIF
		
		MsgRun("Abrindo planilha...",, {|| ShellExecute("open", "Excel", cArqCsv, "", 1)})
		nSecFim	:= Int(Seconds())
	ENDIF
	
	IF File(cConsFile)
		FErase(cConsFile)
	ENDIF
ENDIF
RETURN

STATIC FUNCTION _xExcelCSV(aStrutCPO, cQry, cPatchCsv)
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : Gera o arquivo no formato CSV
<Data> : 28/09/2016
<Parametros> : aStrutCPO, cQry, cPatchCsv
	aStrutCPO	: Estrutura de campos de origem
	cQry		: Alias com o resultado da consulta
	cPatchCsv	: Caminho de destino do arquivo
<Retorno> : Nenhum
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local cLn		:= ""
Local cLinha	:= ""
Local nHdlCsv	:= 0
Local cConsFile	:= ""
Local cArqCsv	:= ""
Local n1		:= 0
Local nTmLn		:= 0 
Local nCountLn	:= 0 
Local nLns		:= 0
Local nTotReg	:= 0
Local cPath		:= Alltrim(GetSrvProfString("STARTPATH", ""))
Local cCons		:= U_VExtM01I("CONS")
Local cPreC		:= Iif(Left(cCons, 1) == "S", Substr(cCons, 2), cCons)


IF (cQry)->(Eof())
	Aviso("AtenÁ„o", "Consulta n„o retornou dados!", {"OK"})
	RETURN
ENDIF

cConsFile	:= "V3EXTA01_" + (cCons)->(FieldGet(FieldPos(cPreC + "_CODIGO"))) + "_" + __cUserID + "_" + StrTran(Time(), ":", "") + ".csv"
IF IsBlind()
	cConsFile	:= cPatchCsv + cConsFile
ENDIF

IF File(cConsFile)
	FErase(cConsFile)
ENDIF

nHdlCsv	:= FCreate(cConsFile)

//Cabecalho do CSV
cLinha := ""   
FOR n1 := 1 TO Len(aStrutCPO)
	_xAddCpo(@cLinha, Alltrim(StrTran(aStrutCPO[n1,1], ";", " ")))
	nTmLn	+= aStrutCPO[n1, 3]	
NEXT
FWrite(nHdlCsv, cLinha + CRLF)
cLinha	:= ""

//Tratamento do limite de linha para gravaÁ„o no arquivo csv
IF Int(6120 / nTmLn) > 0
	nLns	:= Int(6120 / nTmLn)
ENDIF

(cQry)->(DbGoTop())
(cQry)->(DbEval({|| nTotReg++}))
(cQry)->(DbGoTop())
ProcRegua(nTotReg)
//Acrescentando os itens
WHILE !(cQry)->(Eof())
	IncProc("Gerando planilha...")
	cLn	:= ""
	FOR n1 := 1 TO Len(aStrutCPO)
		IF aStrutCPO[n1,2] == "C"
			//cCPO := (cQry)->&(aStrutCPO[n1,5])
			cCPO	:= (cQry)->(FieldGet(n1))
			IF !Empty(aStrutCPO[n1, 6])
				_xAddCpo(@cLn, Transform(cCPO, aStrutCPO[n1, 6]))
			ELSE
				_xAddCpo(@cLn, cCPO)
			ENDIF
		ELSEIF aStrutCPO[n1, 2] == "D"	
			//dCPO := STOD((cQry)->&(aStrutCPO[n1,5]))			
			dCPO	:= Stod((cQry)->(FieldGet(n1)))
			_xAddCpo(@cLn, Dtoc(dCPO))
		ELSEIF aStrutCPO[n1, 2] == "N"		
			//nCPO := (cQry)->&(aStrutCPO[n1,5])
			nCPO	:= (cQry)->(FieldGet(n1))
			IF !Empty(aStrutCPO[n1, 6])
				_xAddCpo(@cLn, Alltrim(Transform(nCPO, aStrutCPO[n1, 6])))
			ELSE
				_xAddCpo(@cLn, StrTran(Alltrim(Str(nCPO)), ".", ","))
			ENDIF
		ENDIF
	NEXT
	cLinha	+= cLn + CRLF
	
	//Controle para gravar no limite medio de 6120 caracteres
	nCountLn++
	IF nCountLn >= nLns
		FWrite(nHdlCsv, cLinha)
		nCountLn	:= 0
		cLinha		:= ""		
	ENDIF
	
	(cQry)->(DbSkip())	
ENDDO

IF !Empty(cLinha)
	FWrite(nHdlCsv, cLinha)
ENDIF
	
FClose(nHdlCsv)

IF !IsBlind()
	cPatchCsv	+= Iif(Right(AllTrim(cPatchCsv), 1) <> '\' , '\', '')
	cARQCSV		:= Alltrim(cPatchCsv) + cConsFile
	
	IF Empty(cPatchCsv)
		RETURN
	ENDIF
	IF IsSrvUnix()
		cPath	+= Iif(Right(cPath, 1) # "/", "/", "")
	ELSE
		cPath	+= Iif(Right(cPath, 1) # "\", "\", "")
	ENDIF
	
	//COPY FILE &cConsFile TO &cARQCSV
	MsgRun("Transferindo para a m·quina local...",, {|| CpyS2T(cPath + cConsFile, Alltrim(cPatchCsv))})
	IF !File(cARQCSV)
		Aviso("AtenÁ„o", "N„o foi possivel gerar a planilha (" + cARQCSV + "), verifique com o administrador de rede/computador, se vocÍ possui permissıes " + ;
			"para salvar no caminho informado!",{"OK"})
		RETURN
	ELSE
		IF " " $ Alltrim(cARQCSV)
			cARQCSV	:= '"' + cARQCSV + '"'
		ENDIF
		
		MsgRun("Abrindo planilha...",, {|| ShellExecute("open", "Excel", cARQCSV, "", 1)})
		nSecFim	:= Int(Seconds())
	ENDIF
	
	FErase(cConsFile)
ENDIF
RETURN


STATIC FUNCTION _xAddCpo(cLn, xValor)
IF Empty(StrTran(cLn, " ", "@"))
	cLn := xValor
ELSE
	cLn += ";"+xValor	
ENDIF
RETURN
