#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "Colors.ch"
#Include "DBTREE.CH"
#include "Totvs.ch"

#Define SEG_EM_HORA 3600


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFTesEspe  บAutor  ณCristiano MAchado   บ Data ณ  07/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChamado: AAZSHW  Data: 08/07/2010  Solicit.: Adriana Fiscal บฑฑ                                                                                       *
ฑฑบ          ณDesc: Regras Especificas para TES                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8 Imdepa Rolamentos                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

**********************************************************************
User Function FTesEspe(lRetSubT,cFilImd,cTpCliente,cDestino,cClassif,cSegmento,cProduto)
**********************************************************************
	Local cTes := ""

//| Parametros de Entrada:
//| ----------------------
//| lRetSubT 	= Para identificar se eh ou nao Substituicao Tributaria
//| cFilImd 	= Filial que sta sendo utilizada
//| cTpCliente 	= Tipo do Cliente
//| cDestino 	= Estado destino da Venda
//| cClassif  	= Classificacao do Produto
//| cSegmento 	= Segmento do Cliente
//| cProduto 	= Codigo do Produto

	If FunName() = "TMKA271" //| Somente eh Utilizado no CallCenter.

	//| Regras Empresa ---------------------------------------------------------------
		If U_FEhSufra() == "ZFM" //| Regra 001
			cTes := FBuscaTes("00R001") //| TES - 504

		ElseIf U_FEhSufra() == "AMO" //| Regra 002
			cTes := FBuscaTes("00R002") //| TES - 505

		Else //| Regras Filiais ----------------------------------------------------------

		//| Filial Cuiaba ------------------------------------------------------------
			If cFilImd == "02"

				If U_FEhSufra() == "ALC" //| Regra 001
					cTes := FBuscaTes(cFilImd+"R001") //| TES - 518

				EndIf
			EndIf

		//| Filial Goias -------------------------------------------------------------
			If cFilImd == "04"

				If U_FEhSufra() == "ALC" //| Regra 003
					cTes := FBuscaTes(cFilImd+"R003") //| TES - 518

				Elseif SA1->A1_CLITARE == 'S'          // Chamado: AAZUIM
					cTes := FBuscaTes(cFilImd+"R004") //| TES - 540

				Elseif SA1->A1_SIMPNAC == '1'          // Chamado: AAZVMT
					cTes := FBuscaTes(cFilImd+"R005") //| TES - 723

				/*
				ElseIf cTpCliente == "F" .And. cSegmento == "2"	  //| Regra 001
				cTes := FBuscaTes(cFilImd+"R001") //| TES - 502

				ElseIf 	cDestino == "GO" //.AND. SA1->A1_GRPSEG $ "AU1/AG1/IN1" //| Regra 002
				cTes := FBuscaTes(cFilImd+"R002") //| TES - 540
				*/

				Endif
			EndIf

		//| Filial Cd Porto Alegre ---------------------------------------------------
			If cFilImd == "05"

				If U_FEhSufra() == "ALC" //| Regra 001
					cTes := FBuscaTes(cFilImd+"R001") //| TES - 514
				EndIf

			//Tratamento para o Decreto RS - Desconto de 7.7 no Pre็o de Tabela atrelado a TES 721
				If cSegmento == "3" .AND. SA1->A1_EST='RS' .AND. lRetSubT .AND. Alltrim(SB1->B1_ORIGER) =="F/NCZADO" .OR. cSegmento == "3" .AND. SA1->A1_EST='RS' .AND. lRetSubT .AND.  Alltrim(SB1->B1_ORIGER) =="IMPORTADO"
					cTes := FBuscaTes(cFilImd+"R002")  //| TES - 721 (Decreto RS)
				Endif

			EndIf


		//| Filial Sao Paulo ---------------------------------------------------------
			If cFilImd == "09"

				If !Empty(U_FEhSufra()) .And. lRetSubT //| Regra 001
					cTes := FBuscaTes(cFilImd+"R001") //| TES - 753

				ElseIf U_FEhSufra() == "ALC" //| Regra 002
					cTes := FBuscaTes(cFilImd+"R002") //| TES - 753

				Endif
			EndIf


		//| Filial Curitiba ----------------------------------------------------------
			If cFilImd == "13" //| Curitiba

				If U_FEhSufra() == "ALC" //| Regra 003
					cTes := FBuscaTes(cFilImd+"R003") //| TES 515

				ElseIf !lRetSubT //| Se nao for ST.

					If cTpCliente == "F" .And. cSegmento == "2" //| Regra 001
						cTes := FBuscaTes(cFilImd+"R001") //| TES 502

					ElseIf 	cDestino == "PR" //| Regra 002
						cTes := FBuscaTes(cFilImd+"R002") //| TES - 514

					Endif

				Endif
			Endif
		Endif
	EndIf

Return(cTes)
**********************************************************************
Static Function FBuscaTes(cRegra) //| Tabela de TES Especificas confomre filial e Regra
**********************************************************************

	cTes := SX5->(Posicione("SX5",1,xFilial("SX5")+"ZN"+cRegra,"X5_DESCRI"))

Return(AllTrim(cTes))
**********************************************************************
User Function FEhSufra() //| Verifica se enquadra na regra suframa e qual delas
**********************************************************************
//| Definicoes:
//| -----------
//| AMO - Amazonia Ocidental
//| ZFM - Zona Franca de Manaus
//| ALC - Area de Livre Comerci'o

	Local cRet := ""
//| Tratamento Zona Franca de Manaus - Tratamento Empresa
	If SB1->B1_ORIGEM == "0" .OR. SB1->B1_ORIGEM == "2" //| Nacional / Mercado Interno

		If !Empty(SA1->A1_SUFRAMA)

			If SA1->A1_ESTE == "AP" //| UF = AMAPA

				Do Case
				Case SA1->A1_CODMUN == "00605" //| Macapa
					cRet := "ALC"

				Case SA1->A1_CODMUN == "00615" //| Santana
					cRet := "ALC"

				OtherWise
					cRet := ""
				EndCase

			ElseIf SA1->A1_ESTE == "AC" //| UF = ACRE

				Do Case
				Case SA1->A1_CODMUN == "00107" //| Cruzeiro do Sul
					cRet := "ALC"

				Case SA1->A1_CODMUN == "00105" //| Brasileira
					cRet := "ALC"

				Case SA1->A1_CODMUN == "99998" //| Epitacolandia
					cRet := "ALC"

				Otherwise
					cRet := "AMO"
				EndCase

			ElseIf SA1->A1_ESTE == "RR" //| UF = RORAIMA

				Do Case
				Case SA1->A1_CODMUN == "00307" //| Bonfim
					cRet := "ALC"

				Case SA1->A1_CODMUN == "99999" //| Pacaraima
					cRet := "ALC"

				OtherWise
					cRet := "AMO"
				EndCase

			ElseIf SA1->A1_ESTE == "RO" //| UF = RONDONIA

				Do Case
				Case SA1->A1_CODMUN == "00001" //| Guajara Mirin
					cRet := "ALC"

				OtherWise
					cRet := "AMO"
				EndCase

			ElseIf SA1->A1_ESTE == "AM" //| UF = AMAZONAS

				Do Case
				Case SA1->A1_CODMUN == "09847" //| Tabatinga
					cRet := "ALC"

				Case SA1->A1_CODMUN == "00255" //| Manaus
					cRet := "ZFM"

				Case SA1->A1_CODMUN == "09843" //| Rio Preto da Eva
					cRet := "ZFM"

				Case SA1->A1_CODMUN == "09841" //| Presidente Figueiredo
					cRet := "ZFM"

				OtherWise
					cRet := "AMO"

				EndCase
			EndIf
		EndIf
	Endif




Return(cRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLIBRARY   บAutor  ณMicrosiga           บ Data ณ  07/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
**********************************************************************
User Function FSubTrib(cpar1,cpar2,cpar3,cpar4,cpar5,cpar6,cpar7,npar8,cpar9)//Retorna a Tes conforme parametros - (cfilImd,cNota,cTipo,cTpCliFor,cDestin,Classif,cSegmento,tpRet,CProd)
**********************************************************************
	Local 	cRetorno

	Private ltesok 		:= .F.
	Private CtesRt 		:= space(03)
	Private CtesTf 		:= space(03)
	Private cfilImd 	:= cpar1
	Private cNota		:= cpar2
	Private cTipo		:= cpar3
	Private cTpCliFor 	:= cpar4
	Private cDestin 	:= cpar5
	Private Classif 	:= cpar6
	Private cSegmento 	:= cpar7
	Private tpRet 		:= npar8
	Private cVeST		:= Iif(cpar9==Nil,'',cpar9)// Regra Custo ?
	Private cProd	 	:= SB1->B1_INDUSTR

	If cfilImd == nil .or. cNota == nil .or. cTipo == nil .or. cTpCliFor == nil .or. cDestin == nil .or. Classif == nil .or.  cSegmento == nil .or. tpRet == nil

		alert("Chamada invalida da Fun็ใo!!! - FSubTrib( Falta Parametro )")
		Conout("Chamada invalida da Fun็ใo!!! - FSubTrib( Falta Parametro )")
	Return("")

	Endif

	cQuery := " "
	cQuery += " SELECT ZA4_CLASSI CLASSI, ZA4_TES TES, ZA4_TESTRF TESTRF, ZA4_REGST REGST "
	cQuery += " FROM " + RetSqlName("ZA4")
	cQuery += " WHERE ZA4_FILIAL  = '" + xFilial("ZA4")	+ "' "
	cQuery += "   AND ZA4_FORIGE  = '" + cfilImd 		+ "' "
	cQuery += "   AND ZA4_NOTA    = '" + cNota 			+ "' "
	cQuery += "   AND(ZA4_TIPO    = '" + cTipo 			+ "' OR ZA4_TIPO   = '*') "
	cQuery += "   AND(ZA4_CLIFOR  = '" + cTpCliFor 		+ "' OR ZA4_CLIFOR = '*') "
	cQuery += "   AND(ZA4_DESTIN  = '" + cDestin 		+ "' OR ZA4_DESTIN = '**') "
	cQuery += "   AND(ZA4_GRPSEG  = '" + cSegmento 		+ "' OR ZA4_GRPSEG = '*') "

	If ( cVeST == 'S' )
		cQuery += "   AND ZA4_REGST  = '" + cVeST 		+ "' "
	EndIf

	cQuery += "  AND D_E_L_E_T_  = ' '
	cQuery += " ORDER BY ZA4_TIPO,ZA4_CLIFOR,ZA4_DESTIN, ZA4_GRPSEG,ZA4_CLASSI DESC "

//MEMOWRIT("C:\SQLSIGA\Funcao_FSubTrib.TXT ", cQuery)

	IF Select( '_ST' ) <> 0
		dbSelectArea('_ST')
		DbCloseArea('_ST')
	Endif

	TCQUERY cQuery NEW ALIAS ('_ST')

	Do While _ST->(!EOF())
		cCaracter := ""

		For I:=1 to len(alltrim(_ST->CLASSI))

			If substr(Classif,i,1) == substr(_ST->CLASSI,i,1) .Or. Substr(_ST->CLASSI,i,1) == '*'
				cCaracter += substr(_ST->CLASSI,i,1)
				ltesok := .T.
				CtesRt := _ST->TES
				CtesTf := _ST->TESTRF
			ElseIf substr(_ST->CLASSI,i,1) == "%" .and. ltesok
				CtesRt := _ST->TES
				CtesTf := _ST->TESTRF
				ltesok := .T.
				exit
			Else
				ltesok := .F.
				exit
			Endif

		Next i

		If ltesok
			CtesRt := _ST->TES
			CtesTf := _ST->TESTRF
			Exit
		else
			_ST->(DbSkip())
		Endif

	EndDo

	_ST->(DBCloseArea())

	If cSegmento == "3" .and. ltesok .and. tpRet != 2 //Regra especifica P/ Cliente Segmento 3
	// Regra de Excessao solicitada pelos clientes. Para se enquadrar na ST. 20/01/08 | Ariorbeto - Fiscal
	//If SA1->A1_ATIVIDA == '47890' .And.  cfilImd $('13/05')
	//	lTesOk	:= .T.
		If SA1->A1_CLITARE == 'S' //| Cliente Tare ? S=Sim | N= Nao
			lTesOk	:= .F.
		ElseIf SA1->A1_EXCECST == '1' //| Cliente Entra na ST ?
			lTesOk	:= .T.
		ElseIf cfilImd == '05' .and. cDestin == 'RS' //| Chamado: AAZVNW -  Data: 28/03/2013 - Cristiano Machado //.and. (substr(Classif,1,5) = '40103' .or. substr(Classif,1,8) = '59100000' .or. substr(Classif,1,4) = '8482')
			lTesOk	:= .T.
		ElseIf ConAgri() .and. cProd == "S" //Regra para Concessionarias Agricolas conforme proj. logico do chamado AAZQV1 - Agostinho 23/09/2009
			lTesOk	:= .T.
		Else
			lAuto	:= U_FCnaeAuto()//Nova Regra Substituicao Tributaria Para Segmento 3 Definido em 01/08/08
			If !lAuto .and. cProd == "S" .AND. !SA1->A1_GRPSEG  $ "A/G"
				lTesOk	:= .F.
			Endif
		Endif
	Endif


	IF PROCNAME(1) == "U_FPARTES" .OR. PROCNAME(1) == "U_TMKVFIM" // == //PROCNAME() <> "U_IMDV240AC"  .AND. PROCNAME() <> "U_IMDV240" //DESC ICMS

	//|Chamado: AAZSHW  Data: 08/07/2010  Solicitante: Adriana Fiscal  Desc: Regras Especificas para TES
		cRetFunc := U_FTesEspe(lTesOk,cfilImd,cTpCliFor,cDestin,Classif,cSegmento,cProd)

		If !Empty(cRetFunc)
			lTesOK := .T.
			CtesRt := cRetFunc
		EndIf
	//| Fim AAZSHW

	ENDIF

	If tpRet == 3 .and. !lTesok
	Return(.F.)
	Elseif !ltesok
	Return(Space(03))
	Endif

	Do Case
	Case tpRet == 1 //Tes Venda / Compra
		If ltesok
			cRetorno := CtesRt
		else
			cRetorno := '   '
		endif
	Case tpRet == 2 //Tes Transferencia
		If ltesok
			cRetorno := CtesTf
		else
			cRetorno := '   '
		endif
	Case tpRet == 3 //True / False
		cRetorno := ltesok
	EndCase


Return(cRetorno)
*********************************************************************
Static Function ConAgri()//Retorna se ้ Concessionแrias Agrํcolas
*********************************************************************

	If FunName() = "TMKA271"
		If lProspect
			If SUS->US_CONAGRI = "1"
			Return(.T.)
			Endif
		Else
			If SA1->A1_CONAGRI = "1"
			Return(.T.)
			Endif
		Endif
	Else
		If SA1->A1_CONAGRI = "1"
		Return(.T.)
		Endif
	Endif

Return(.F.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLIBRARY   บAutor  ณMicrosiga           บ Data ณ  07/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

*****************************************************************************************************
User Function VerGer(ARQ)//Ver se o usuario ้ gerente - valida็ใo para os campos US_CONAGRI e A1_CONAGRI
*****************************************************************************************************
	LOCAL ARQ
	LOCAL nHdlLog
	LOCAL cQuery
	LOCAL aArea := GetArea()
	LOCAL _CAMPO:= ARQ+"_CONAGRI"
	LOCAL _DE   := IF(&("S"+ARQ+"->"+ARQ+"_CONAGRI")= "1","SIM","NAO")
	LOCAL _PARA := IF(&("M->"+ARQ+"_CONAGRI")= "1","SIM","NAO")

	cQuery := " "
	cQuery += " SELECT A3_CODUSR "
	cQuery += " FROM " + RetSqlName("SA3")
	cQuery += " WHERE  D_E_L_E_T_  = ' ' "
	cQuery += " AND A3_CODUSR = '" + __CUSERID	+ "' "
	cQuery += " AND A3_GERENTE = 'S'

	TCQUERY cQuery NEW ALIAS ('VERGER')

	VERGER->(dbSelectArea("VERGER"))

	IF VERGER->(EOF()) .AND. VERGER->(BOF())
		AVISO("Permissใo Negada!","Somente gerentes podem alterar este campo!",{"OK"} )
		VERGER->(dbCloseArea())
	RETURN(.F.)
	ENDIF

//GRAVA LOG
	If File("\conagri.log")
		nHdlLog := fOpen("\conagri.log",2)
		fSeek(nHdlLog,0,2)
	Else
		nHdlLog:=fCreate("\conagri.log",0)
		fWrite(nHdlLog,"DATA     HORA     CAMPO      USUARIO CLIENTE LOJA DE  PARA"+CRLF)
		fWrite(nHdlLog,"----------------------------------------------------------"+CRLF)
	Endif
	fWrite(nHdlLog,dtoc(date())+" "+time()+" "+_CAMPO+" "+__CUSERID+"  "+&("S"+ARQ+"->"+ARQ+"_COD")+"  "+&("S"+ARQ+"->"+ARQ+"_LOJA")+"   "+_DE+" "+_PARA+CRLF)
	fclose(nHdlLog)

	DBCloseArea("VERGER")
	RestArea(aArea)

RETURN(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLIBRARY   บAutor  ณMicrosiga           บ Data ณ  07/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

*********************************************************************
User Function FCnaeAuto()//Retorna Conforme Regra se E Substituicao Tributaria ou Nao
*********************************************************************

	Dbselectarea("SX5")
	Dbseek(xFilial("SX5")+"Z9"+"NIND1",.F.)
	While(SX5->X5_TABELA == "Z9") //Tabela com Cnaes Automotivos (De - Ate) Eles Nao devem ter ST
	/*
	CnaeIni := SUBSTR(SX5->X5_DESCRI,1,5)
	CnaeFim := SUBSTR(SX5->X5_DESCRI,7,5)

	If SA1->A1_ATIVIDA >= CnaeIni .and. SA1->A1_ATIVIDA <= CnaeFim
	Return(.T.)
	Endif
	*/
	CnaeIni := SUBSTR(SX5->X5_DESCRI,1,9)
	CnaeFim := SUBSTR(SX5->X5_DESCRI,11,9)

	//If SA1->A1_ATIVIDA >= CnaeIni .and. SA1->A1_ATIVIDA <= CnaeFim
	If SA1->A1_CNAE >= CnaeIni .and. SA1->A1_CNAE <= CnaeFim
	Return(.T.)
	Endif

	Dbselectarea("SX5")
	Dbskip()
EndDo

Return(.F.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLIBRARY   บAutor  ณMicrosiga           บ Data ณ  07/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

**********************************************************************
User Function FCusTrib(lOk) //ณ Calcula Custo de Substituicao Tributaria
**********************************************************************
	Local nCusto 		:= 0
	Local nCusB2 		:= 0
	Local nAliqICM 		:= 0
	Local nIcmSbDest 	:= 0 // ICMS de Destino (Substtiuicao)
	Local nAcrMargem	:= 0
	Local nAcrIPI		:= 0
	Local nAliqPIS 		:= 0
	Local nAliqCOF 		:= 0

	Local cImdepa  		:= GetMV('MV_IMDEPA') // Cliente Tranfer๊ncia
	Local nAliqICMSInt  := GETMV('MV_ICMSTRF',,0)/100    //ICMS TRF - ICMS USADO NA DESONERACAO DE CUSTO TRANSFERENCIA
	Local nIcmsDesVen   := GETMV('MV_ICMVEND',,0)        //ICMS de Desonera็ใo da Venda
	Local nAliqMVATRF   := 1 + (GETMV("MV_MVATRF",,0) /100) //% MVA padrใo para transferencia entre filiais

	Private nDesonera	:= .F. // Se deve ou nao Desonerar o Calculo do Custo Kardex
	Private cUFOri		:= Posicione("SM0",1,"01"+cfilant,"M0_ESTENT")   //SM0->M0_ESTENT
	Private lEstOner  	:= dDatabase >= GetMV("MV_ESTONER",,dDatabase+1)
	Private lZA4Ok 		:= lOk
	Private cEstATU		:= GETMV("MV_ESTADO") // Estado Atual (Edivaldo,inserido como variavel private para ser usado na funcao FcondOnera()

	nDesonera := FcondOnera() //Condicoes para Calculo de Desoneracao

	If !nDesonera
	Return(SB2->B2_CM1)
	Endif

	nCusB2 		:= 	SB2->B2_CM1
	nAliqICM 	:= 	GETMV("MV_ALIQOST",,0) /100//| ICM de Origem - Aliquota de Origem (Fornecedor) para Substituicao Tributaria - Desoneracao // nAliqICM := GETMV("MV_ICMPAD") /100

	If SA1->A1_EST $ GetMV('MV_NORTE') .AND. !(cEstATU$GetMV('MV_NORTE')) 	// ICM de Destino //cEstDest $ GetMV('MV_NORTE')
		nIcmSbDest := 7/100
	Else
		nIcmSbDest := 12/100
	EndIf

	nAcrMargem 	:= 1 + (GETMV("MV_MVAOST",,0) /100)// Deixo de buscar a Margem das excecoes fiscais e passo a buscar do parโmetro MV_MVAOST
	nAcrIPI 	:= 1 + (SB1->B1_IPI / 100 )// Acrescimo de IPI
// PIS e COFINS
	nAliqPIS	:= iif(SB1->B1_PPIS > 0, SB1->B1_PPIS, GetMV("MV_TXPIS"))
	nAliqPIS	:= nAliqPIS /100 // 84821010 / 100 = 848210,1

	nAliqCOF 	:= iif(SB1->B1_PCOFINS	>0, SB1->B1_PCOFINS	, GetMV("MV_TXCOFIN"))
	nAliqCOF	:= nAliqCOF/100

// Aplica Reducao no  PIS e COFINS
	nAliqPIS 	:= nAliqPIS - (nAliqPIS * (SB1->B1_REDPIS / 100))
	nAliqCOF 	:= nAliqCOF - (nAliqCOF * (SB1->B1_REDCOF / 100))
	nPISCOF		:= nAliqPIS + nAliqCOF

	If cEstATU == "SP"// Desoneracao venda SP tem regra especifica ... Alicota Interna ICMS
		nCusto1 	:= nCusB2 /( 1 + ( 1 / ( 1 - nPISCOF - nAliqICMSInt )) * nAcrIPI * nAcrMargem * nAliqICM)

	ElseIf cEstATU == "MT" //| Chamado: AAZUG0

		If FunName() == 'TMKA271' //| CallCenter
			nTotItem	:= SUB->UB_VRCACRE + (( SUB->UB_VRCACRE / (SUA->UA_VALMERC + SUA->UA_DESPESA + SUA->UA_ACRESCI) ) * SUA->UA_DESPESA )

		ElseIf  FunName() == 'MATA460A' //| Faturamento
			nTotItem	:= SD2->D2_BASEICM / SD2->D2_QUANT

		Else //| Outros
			nTotItem	:= 0

		EndIF

		nCusto1 	:= nCusB2 - ( nTotItem * nIcmSbDest)
	//| Fim Chamado: AAZUG0
	Else
	//nCusto1 	:= nCusB2 /( 1 + ( 1 / ( 1 - nPISCOF - nIcmSbDest )) * nAcrIPI * nAcrMargem * nAliqICM)

	// Edivaldo Gon็alves Cordeiro | Alterado a variแvel nIcmSbDest pela nova variแvel de Desonera็ใo na Venda (nIcmsDesVen)
		nCusto1 	:= nCusB2 /( 1 + ( 1 / ( 1 - nPISCOF - nIcmsDesVen )) * nAcrIPI * nAcrMargem * nAliqICM)


	Endif//		 	=  C66    /( 1 + ( 1 / ( 1 -    N66   -      G66    )) *   K66   *     I66           *E66      )


	If cEstATU == "MT"	//| Chamado: AAZUG0
		nVlrProd 	:= 100 //| Valor Produto
		nVlrIpi 	:= nVlrProd * (SB1->B1_IPI / 100 ) //| nVlrIpi 	= nVlrProd * Aliq IPI
		nVlrRetST 	:= ( nVlrIpi + nVlrProd ) * 0.13 	//| nVlrRetST 	= ( nVlrIpi + nVlrProd ) * Imcs Carga Media
		nBaseSt		:= ( nVlrRetST + 7 ) / 0.17 		//| nBaseSt		= ( nVlrRetST + VlrIcms ) / Icms Interno
		nMVACalc	:= nBaseSt / ( nVlrIpi + nVlrProd )//| nMVACalc		= nBaseSt / nVlrIpi + nVlrProd

		nCustTRF 	:= nCusB2 /( 1 + ( 1 / ( 1 - nPISCOF - nAliqICMSInt )) * nAcrIPI * nMVACalc * nAliqICMSInt)
	//| Fim Chamado: AAZUG0

	Else
	//Inserido por Edivaldo Gon็alves Cordeiro em 25/11/2008
	//Custo para Transferencia entre filiais
		nCustTRF 	:= nCusB2 /( 1 + ( 1 / ( 1 - nPISCOF - nAliqICMSInt )) * nAcrIPI * nAliqMVATRF  * nAliqICMSInt)
	//		 	=  C66    /( 1 + ( 1 / ( 1 -    N66   -      G66    )) *   K66   *     I66           *E66      )
	EndIf

//Inserido por Cristiano Machado Data: 13/01/2009
	If FunName() == 'TMKA271'//Call Center
		If !Empty(SUB->UB_FILTRAN) // Item de Transferencia
			nCusto 	:=  nCustTRF
		Else
			nCusto 	:=  nCusto1
		Endif
	// Jorge Oliveira 16/08/2010 - Incluida a funcao IMDA090 e IMDA640
	//Transferencia entre filiais, Manutencao da Planilha, Transferencia de vendas das Planilhas
	ElseIf FunName() $('IMDA070/IMDA090/IMDA640')
		nCusto 	:=  nCustTRF
	ElseIf FunName() == 'MATA410' .AND. SA1->A1_COD == 'N00000' //Alteracao no Pedido Transferencia SC6
		nCusto 	:=  nCustTRF
	ElseIf FunName() == 'MATA410' .AND. SA1->A1_COD != 'N00000' //Alteracao Pedido de Venda SC6
		nCusto 	:=  nCusto1
	ElseIf FunName() == 'MATA460A'//Geracao da NF
		If SD2->D2_CLIENTE =='N00000' //Cliente Transferencia
			nCusto 	:=  nCustTRF
		Else
			nCusto 	:=  nCusto1
		Endif
	Endif

Return nCusto
**********************************************************************
Static Function FcondOnera()//Condic๕es Para Onerar Custos (.T.)
**********************************************************************
	Local  Desonera 	:= .T.
	Local  NaoDesonera 	:= .F.
	Local lEhST         := .F.
	Local cImdepa       := GetMV('MV_IMDEPA')

	Private lEstOner    := dDatabase >= GetMV("MV_ESTONER",,dDatabase+1)


	If !Empty(U_FEhSufra())//| Chamado: AAZUQO - Cliente Suframa Desonera   data: 28/03/2012
	Return(Desonera)
	EndIF

	IF lEstOner // Verifica se filial tem estoque onerado

		If  cUFOri == "MT" //Regras para MT
			If FunName() $('IMDA070/IMDA090/IMDA640')
			Return(Desonera)
			ElseIf cUFOri <> SA1->A1_EST
			Return(Desonera)
			Else
			Return(NaoDesonera)
			Endif
		Endif

		lEhST := U_FVerNcm()

	//Inserido por Edivaldo Goncalves Cordeiro
		If lEhST .AND. SA1->A1_COD == cImdepa  // eh uma transferencia entre filiais e o produto eh ST
		Return(Desonera)
		Endif


		If lEhST//Verifica Se Ncm do Produto eh ST
	   //Tratamento para RS
			If cUFOri == "RS" .AND. (Alltrim(SB1->B1_ORIGER) == "F/NCZADO" .OR.Alltrim(SB1->B1_ORIGER) == "IMPORTADO") .AND. (Substr(SA1->A1_GRPSEG,3,1) == "1" .OR. Substr(SA1->A1_GRPSEG,3,1) == "2")
			Return(NaoDesonera)
			Endif

			If cUFOri <> SA1->A1_EST //Verifica se eh Venda Para Fora do Estado
			Return(Desonera)
			ElseIf cUFOri == SA1->A1_EST .AND. (Substr(SA1->A1_GRPSEG,3,1) == "1" .OR. Substr(SA1->A1_GRPSEG,3,1) == "2")
			Return(Desonera)
			ElseIf cUFOri == SA1->A1_EST .AND. Substr(SA1->A1_GRPSEG,3,1) == "3"
			// Regra de Excessao solicitada pelos clientes. Para se enquadrar na ST. 20/01/08 | Ariorbeto - Fiscal
			//	If SA1->A1_ATIVIDA == '47890' .And.  cUFOri $("RS/PR")
			//	lTesOk	:= .T.
				If SA1->A1_CLITARE == 'S' //| Cliente tare ? S=Sim | N=Nao
				Return(Desonera)
				ElseIf SA1->A1_EXCECST == '1'  //| Cliente Entra na ST ? 1 = SIM | 2 = NAO
				Return(Desonera)
				ElseIf cUFOri == "RS" .and. cUFOri == SA1->A1_EST .AND. Alltrim(SB1->B1_ORIGER) == "F/NCZADO" .OR. cUFOri == "RS" .and. cUFOri == SA1->A1_EST .AND.  Alltrim(SB1->B1_ORIGER) == "IMPORTADO"  //| Chamado: AAZVNW -  Data: 28/03/2013 - Cristiano Machado // .and. (substr(SB1->B1_POSIPI,1,5) = '40103' .or. substr(SB1->B1_POSIPI,1,8) = '59100000' .or. substr(SB1->B1_POSIPI,1,4) = '8482')
				Return(NaoDesonera) ////| Chamado: AAZVNW -  Data: 28/03/2013 - Cristiano Machado
				ElseIf cUFOri == "RS" .and. cUFOri == SA1->A1_EST .AND. Alltrim(SB1->B1_ORIGER) <> "F/NCZADO" .OR. cUFOri == "RS" .and. cUFOri == SA1->A1_EST .AND. Alltrim(SB1->B1_ORIGER) <> "IMPORTADO"  //| Chamado: AAZVNW -  Data: 28/03/2013 - Cristiano Machado // .and. (substr(SB1->B1_POSIPI,1,5) = '40103' .or. substr(SB1->B1_POSIPI,1,8) = '59100000' .or. substr(SB1->B1_POSIPI,1,4) = '8482')
				Return(NaoDesonera)
				ElseIf ConAgri() .and. SB1->B1_INDUSTR == "S" //Regra para Concessionarias Agricolas conforme proj. logico do chamado AAZQV1 - Agostinho 23/09/2009
				Return(NaoDesonera)
				ElseIf !U_FCnaeAuto() //Cnae Industria
					If SB1->B1_INDUSTR == "S"
					Return(Desonera)
					Endif
				Endif
			Endif
		Endif
	Endif

Return(NaoDesonera)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLIBRARY   บAutor  ณMicrosiga           บ Data ณ  07/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

**********************************************************************
User Function FVerNcm()
**********************************************************************
	Local lTesOk := .F.
	Private Classif := SB1->B1_POSIPI

	cQuery := " "
	cQuery += " SELECT ZA4_CLASSI "
	cQuery += " FROM " + RetSqlName("ZA4")
	cQuery += " WHERE ZA4_FILIAL  = '" + xFilial("ZA4")	+ "' "
	cQuery += " AND ZA4_FORIGE    = '" + cfilant 		+ "' "
	cQuery += " AND ZA4_NOTA      = 'S' "
	cQuery += " AND(ZA4_TIPO      = 'N' OR ZA4_TIPO   = '*') "
	cQuery += " AND ZA4_REGST     = 'S' "
	cQuery += " AND ZA4_CLASSI   != '*%' "
	cQuery += " AND D_E_L_E_T_    = ' ' "
	cQuery += " GROUP BY ZA4_CLASSI  "

	MEMOWRIT("C:\SQLSIGA\FVerNcm.TXT ", cQuery)

	IF Select( '_ST' ) <> 0
		dbSelectArea('_ST')
		DbCloseArea('_ST')
	Endif

	TCQUERY cQuery NEW ALIAS ('_ST')

	Do While _ST->(!EOF())
		cCaracter := ""
		For i:=1 to len(alltrim(_ST->ZA4_CLASSI))

			If substr(Classif,i,1) == substr(_ST->ZA4_CLASSI,i,1)
				cCaracter += substr(_ST->ZA4_CLASSI,i,1)
				ltesok := .T.
			ElseIf substr(_ST->ZA4_CLASSI,i,1) == "%" .and. ltesok
				ltesok := .T.
				exit
			Else
				ltesok := .F.
				exit
			Endif

		Next i

		If ltesok
			Exit
		else
			_ST->(DbSkip())
		Endif

	EndDo

	_ST->(DBCloseArea())

Return(lTesOk)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLIBRARY   บAutor  ณMicrosiga           บ Data ณ  07/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

**********************************************************************
User Function F_Sim_SUBTRIB(cpar1,cpar2,cpar3)//|Valida as Regras do Cliente Ref. Subst. Trib -> SX5 TAB IE
**********************************************************************
	Local lReturn := .F.
	Local cRegra  := cpar1 + "," + cpar2 + "," + cpar3
	Local cQuery := " "

	cQuery += "SELECT '1' ST "
	cQuery += "  FROM " + RetSqlName("SX5")
	cQuery += " WHERE x5_filial = '  '"
	cQuery += "   AND x5_tabela = 'IE'"
	cQuery += "   AND x5_descri LIKE '" + cpar1 + "," + cpar2 + "%'" //'IMP,RS%'"
	cQuery += "   AND (SUBSTR (x5_descri, 8, 1) = '" + cpar3 + "' OR SUBSTR (x5_descri, 8, 1) = '*')"
	cQuery += "   AND d_e_l_e_t_ = ' ' AND rownum = 1"

//MEMOWRIT("C:\SQLSIGA\Funcao_F_Sim_SUBTRIB.TXT ", cQuery)

	IF SELECT( '_ST' ) <> 0
		dbSelectArea('_ST')
		DbCloseArea('_ST')
	Endif

	TCQUERY cQuery NEW ALIAS ('_ST')

	IF !EMPTY(_ST->ST)
		lReturn   := .T.
	ENDIF

	_ST->(DBCloseArea())

Return lReturn
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณClearAcentosบAutor  ณCristiano Machadoบ Data ณ  07/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetira acentos das strings enviadas a funcap               บฑฑ
ฑฑบ          ณ                                                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
**********************************************************************
User Function ClearAcentos(xTxt)
**********************************************************************
	Local cAcentos 	:= "็ว"+chr(8364)+chr(8225)+"แ้ํ๓๚มษอำฺโ๊๎๔๛ยสฮิÛเ้ํ๓๚มษอำฺไ๋๏๖üฤหฯึÜใ๕รี"+chr(381)+"?ภล"+chr(8230)+chr(8224)+" "+chr(8222)+"ฆๅ?ศ"+chr(710)+chr(8218)+"่ฬก?าึ"+chr(8220)+chr(8221)+chr(8226)+"ขง๐ูฃ?๙ั๑%$þ๗Ýฐบชฌ"+chr(402)+"&"
	Local cAcSubst 	:= "cCCcaeiouAEIOUaeiouAEIOUaeiouAEIOUaeiouAEIOUaoAOAAAAaaaaaaEEeeeIiiOOooooooUuuuNnPScoiooaqaE"
	Local nI       	:= 0
	Local nPos     	:= 0

	cCpoLmp			:=	cTxt

//ณTroca Acentos
	For nI := 1 To Len( cCpoLmp )
		If ( nPos := At( SubStr( cCpoLmp, nI, 1 ), cAcentos ) ) > 0
			cCpoLmp := SubStr( cCpoLmp, 1, nI - 1 ) + SubStr( cAcSubst, nPos, 1 ) +  SubStr( cCpoLmp, nI + 1 )
		EndIf
	Next nI

	cTxt  := cCpoLmp

Return(cTxt)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLIBRARY   บAutor  ณMicrosiga           บ Data ณ  07/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
**********************************************************************
User Function FValIcmsRet()
**********************************************************************

	nMVA        := 0

	nValIcmSt 	:= 0

	nIcmRetido	:= 0

	nValDesp 	:= NoRound(SUB->UB_VLRITEM / SUA->UA_VALMERC * SUA->UA_DESPESA,2) // Despesa DOC

	nAcreCon 	:= NoRound(((SUB->UB_VLRITEM + (SUB->UB_VLRITEM / SUA->UA_VALMERC) * SUA->UA_DESPESA) * SE4->E4_ACRSFIN)/100,2) //Acrescimo Condicao

	nValFret 	:= NoRound(SUB->UB_VLRITEM / SUA->UA_VALMERC * SUA->UA_FRETE,2) //Valor Frete

	nCalcIcm 	:= NoRound((SUB->UB_VLRITEM  + nValDesp + nAcreCon + nValFret),2)

	nAlicIpi 	:= SB1->B1_IPI

	cTpCliFor  	:= SA1->A1_TIPO

	cSegmento  	:= substr(SA1->A1_GRPSEG,3,1)

// Jorge Oliveira - 22/12/10 - Alteracao da regra de calculo de IMCS ST
// Regra antiga: SF4->F4_CREDST == '3'
// Regra nova..: ( SF4->F4_CREDST == '3' .Or. ( SF4->F4_CODIGO $ '720_750' .And. SF4->F4_CREDST $ '2_4' ) )
	If U_Fsubtrib(xFilial("SUA"),"S","N",cTpCliFor,SA1->A1_EST,SB1->B1_POSIPI,cSegmento,3) .AND.;
			( SF4->F4_CREDST $ '2/4') //'3' .Or. ( SF4->F4_CODIGO $ '720/721/750/723' .And. SF4->F4_CREDST $ '2/4' ) )

		DbSelectarea("SF7")
		If DbSeek(xFilial("SF7")+SB1->B1_GRTRIB,.F.)
			While !eof() .AND. SB1->B1_GRTRIB == SF7->F7_GRTRIB .AND. SF7->F7_GRPCLI == SPACE(03)
				If SA1->A1_EST == SF7->F7_EST
					nMVA := SF7->F7_MARGEM
					Exit
				Endif
				DbSkip()

			EndDo

			nBaseRet 	:= ( nCalcIcm * (1 + nAlicIpi / 100)) * ( 1 +  (nMVA/100) )
			cEstxIcm 	:= GetMv("MV_ESTICM")
			nPosUf		:= At(SA1->A1_EST,cEstxIcm) + 2
			nValIcmSt 	:= (nBaseRet * ((Val(Substr(cEstxIcm,nPosUf,2))/100)))


		Endif

	Endif

	lInterna := (SM0->M0_ESTENT == SA1->A1_EST)

	If SF4->F4_MKPCMP = '2'  //SF4->F4_ICM = 'S'     //

		If lInterna
			nAlicIcm := GetMv('MV_ICMPAD')
		ElseIf SA1->A1_EST $ GetMv('MV_NORTE') .AND. !(SM0->M0_ESTENT $ GetMv('MV_NORTE'))
			nAlicIcm := 7
		Else
			nAlicIcm := 12
		EndIf

		If nValIcmSt != 0
			nIcmRetido := NoRound(( nValIcmSt - ( nCalcIcm * ( nAlicIcm / 100) )),3)
		Endif

	///JULIO COMENTOU
	///em 30/04/2012
		If SF4->F4_BASEICM<>0 .AND. SF4->f4_bsicmst==0 .AND. lInterna .AND. NVALICMST!=0
			nAliqRed:= nAlicIcm * (SF4->F4_BASEICM/100)
			nAliqNova:= nAliqRED
			nIcmRetido := NoRound(( nValIcmSt - ( nCalcIcm * ( nAliqNova / 100) )),3)
		ELSEIF 	SF4->F4_BASEICM<>0 .AND. SF4->f4_bsicmst<>0 .AND. lInterna .AND. NVALICMST!=0
		//pega aliquota de reducao
			nAliqRed   := nAlicIcm * (SF4->F4_BSICMST/100)
			nAliqNova  := nAliqRED
		//aplico no valor base
			nValor     := (nBaseRet * (nAliqNova/100))
		//neste valor temos de reduzir novamente
			nIcmRetido:= NoRound(( nValor - ( nCalcIcm * ( nAliqNova / 100) )),3)
		Endif


	EndIf


Return(nIcmRetido)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExecMySql บAutor  ณCristiano Machado   บ Data ณ  07/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPar: 	cSql    = Texto Sql,                                  บฑฑ
ฑฑบ			 ณ	  	cAlias  = Alias a ser usado no caso de Query          บฑฑ
ฑฑบ          ณ      lModo   = "E"-Execucao ou "Q"-Query)                  บฑฑ
ฑฑบ          ณ      lMostra = Se deve Apresentar a Query para captura     บฑฑ
ฑฑบ          ณ      lChange = Se deve executar o ChangeQuery              บฑฑ
ฑฑบ          ณObs.: Execucao(Drop, Update, Delete e etc..                 บฑฑ
ฑฑบ          ณRetorno: No modo Execucao retorna o Status caracter, em     บฑฑ
ฑฑบ          ณmodo Query nใo tem retorno.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
User Function ExecMySql( cSql , cCursor , lModo, lMostra, lChange )
*********************************************************************
	Local nRet := 0
	Local cRet := "Executado Com Sucesso"

	Default lModo   := "Q"
	Default lMostra := .F.
	Default lChange := .T.

	If lMostra
		U_MostraTxt(cSql)
	EndIf

	If lModo == "Q" //| Query

		If lChange
			cSql := ChangeQuery(cSql)
		Else
			cSql := Upper(cSql)
		EndIf

		If( Select(cCursor) <> 0 )
			DbSelectArea(cCursor)
			DbCloseArea()
		EndIf

		TCQUERY cSql NEW ALIAS &cCursor.

	ElseIf lModo == "E" //| Comandos

		cSql := Upper(cSql)

		nRet := TCSQLExec(cSql)

		If nRet <> 0
			cRet := TCSQLError()
			If lmostra
				Iw_MsgBox(cRet)
			Endif
		Endif
	Return(cRet)

	ElseIf lModo == "P" //Procedure

		cSql := Upper(cSql)

		TCSQLExec("BEGIN")

		nRet := TCSPExec(cSql)

		If Empty(nRet)
			cRet := TCSQLError()

			If lmostra
				Iw_MsgBox(cRet)
			Endif
		Endif

		TCSQLExec("END")

	Return(cRet)

	Endif


Return()
*********************************************************************
User Function MostraTxt( cTxt )
*********************************************************************
	__cFileLog := MemoWrite(Criatrab(,.F.)+".log",cTxt)

	Define FONT oFont NAME "Tahoma" Size 6,12
	Define MsDialog oDlgMemo Title "Leitura Concluida." From 3,0 to 340,550 Pixel

	@ 5,5 Get oMemo  Var cTxt MEMO Size 265,145 Of oDlgMemo Pixel
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:=oFont

	Define SButton  From 153,235 Type 1 Action oDlgMemo:End() Enable Of oDlgMemo Pixel

	Activate MsDialog oDlgMemo Center

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEnvMyMail บAutor  ณCristiano MAchado   บ Data ณ  07/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Envia Email conform parametros                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
User Function EnvMyMail(cFrom,cTo,cBcc,cSubject,cBody,cAttach)//| U_EnvMyMail(De, Para, Copia, Assunto, Corpo, Anexo )
*********************************************************************
	Local cServer 	:= GetMV("MV_RELSERV" )
	Local cAccount 	:= Alltrim(GETMV("MV_RELACNT"))
	Local cPassword := Alltrim(GETMV("MV_RELPSW"))
	Local lAuth 	:= Getmv("MV_RELAUTH")
	Local lResult  	:= .F.
	Local cError	:= ''

	cFrom		:= Iif(empty(Alltrim(cFrom)), cAccount, Alltrim(cFrom))
	cTo			:= Alltrim(cTo)
	cBcc		:= Alltrim(cBcc)
	cSubject	:= Alltrim(cSubject)
	cBody		:= Alltrim(cBody)
	cAttach		:= Alltrim(cAttach)

	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

//| lResult := MailAuth(cAccount,cPassword)

	If lResult
		SEND MAIL FROM cFrom TO cTo CC cBcc SUBJECT cSubject BODY cBody ATTACHMENT cAttach RESULT lResult
		If !lResult
		//| Erro no envio do email
			GET MAIL ERROR cError
		EndIf
	Endif

	DISCONNECT SMTP SERVER

Return(cError)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVERSEDEV  บAutor  ณAgostinho Lima      บ Data ณ  21/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o cliente estแ com titulos em atraso. Conforme บฑฑ
ฑฑบ          ณ os dias de atraso informado no parametro MV_DIAATR         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
**********************************************************************
User Function VERSEDEV(CLIE)
**********************************************************************

	LOCAL cQuery := ""
	LOCAL cTexto := "       TITULO         TIPO   VENCIMENTO    DIAS ATRASO     VALOR"+CHR(13)+CHR(10)
	LOCAL aArea  := GetArea()
	LOCAL nTotcli:= 0

	Conout('........ '+FUNNAME())

	If FUNNAME() == "IMDB2BPV" .OR. FUNNAME()=="RPC"
	Return(CLIE)
	EndIf

	cQuery := "SELECT E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_VENCREA,E1_SALDO,TRUNC(SYSDATE) - TO_DATE(E1_VENCREA,'YYYYMMDD') ATRASO "
	cQuery += " FROM " + RetSqlName("SE1")
	cQuery += " WHERE  D_E_L_E_T_  = ' ' AND E1_FILIAL = ' ' "
	cQuery += " AND E1_CLIENTE  = '"+CLIE+"' "
	cQuery += " AND E1_SALDO > 0 "
	cQuery += " AND E1_TIPO IN  "+GETMV("MV_TIPOATR")
	cQuery += " AND TO_DATE(E1_VENCREA,'YYYYMMDD')  > SYSDATE - "+GETMV("MV_DIAPVAL")
	cQuery += " AND ( '"+DTOS(DDATABASE)+"' - E1_VENCREA ) > '"+GETMV("MV_DIATATR")+"' "
	cQuery += " ORDER BY E1_VENCREA,E1_PREFIXO,E1_NUM,E1_PARCELA "


	TCQUERY cQuery NEW ALIAS ("TDEV")

	IF ! (TDEV->( bof() ) .AND. TDEV->( eof() ))


		WHILE !EOF()

			cTexto += TDEV->E1_PREFIXO + " - " + TDEV->E1_NUM + " - " +TDEV->E1_PARCELA +"    "+TDEV->E1_TIPO+SPACE(4)+;
				RIGHT(TDEV->E1_VENCREA,2)+"/"+SUBSTR(TDEV->E1_VENCREA,5,2)+"/"+LEFT(TDEV->E1_VENCREA,4)+SPACE(12)+;
				STRZERO(TDEV->ATRASO,5)+SPACE(07)+;
				PADL(ALLTRIM(Transform(TDEV->E1_SALDO,'@E 999,999.99')),10,".")+CHR(13)+CHR(10)

		//      PADL(ALLTRIM(STR(TDEV->E1_SALDO,10,2)),10,".")+CHR(13)+CHR(10)

			nTotcli += TDEV->E1_SALDO

			DBSKIP()

		ENDDO

		cTexto += REPLICATE(".",104)+CHR(13)+CHR(10)
		cTexto += "Total"+SPACE(90-LEN(STR(nTotcli,10,2)))+Transform(nTotcli,'@E 999,999.99')+CHR(13)+CHR(10)
	//   cTexto += "Total"+SPACE(90-LEN(STR(nTotcli,10,2)))+STR(nTotcli,10,2)+CHR(13)+CHR(10)

		AVISO("CLIENTE DEVEDOR!!!",Oemtoansi(cTexto),{"OK"} )

	//   U_IGeraFile( cTexto, "CLIENTE DEVEDOR!!!" )

	ENDIF
	dbCloseArea("TDEV")
	RestArea(aArea)

RETURN(CLIE)
*********************************************************************
USer Function IGeraFile( cFileTxt, cTitulo )
*********************************************************************
//Local cTrab   := Criatrab(,.F.)
//Local cArq   := "\system\arqtrab.txt"
//Local __cFileTxt  := MemoWrit(cArq,cFileTxt)
//Local nOrder   := 2 // Pesquisa pelo nome do usuario
	Static oFontNor  := TFont():New("Courier New",,16,.T.)  //| Campos

	Static oEnvMail,oSairArq,oCampMail,oEnvMail,oSayMail

//PswOrder(nOrder)
//PswSeek(Substr(cusuario,7,15), .T.)
//cEamilCC := PswRet()[1][14]  //| Retorna Codigo do Usuario

	Define FONT oFont NAME "Tahoma" Size 6,12
	Define MsDialog oDlgMemo Title cTitulo From 3,0 to 340,550 Pixel

	@ 005,005 Get oMemo  Var cFileTxt MEMO Size 265,145 Of oDlgMemo Pixel

	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont  := oFont

//@ 155, 006 SAY oSayMail PROMPT "Enviar Para:" FONT oFontNor SIZE 060, 007 OF oDlgMemo COLORS 0, 16777215 PIXEL
//@ 153, 050 MSGET oCampMail VAR cEmailTo SIZE 140, 010 OF oDlgMemo COLORS 0, 16777215 PIXEL

//@ 153,200 Button oEnvMail PROMPT "Enviar"  Action ({ oDlgMemo:End(), EnvMail(cArq)})  Size 30,12 Of oDlgMemo Pixel
	@ 153,235 Button oSairArq PROMPT "Sair"   Action   oDlgMemo:End()       Size 30,12 Of oDlgMemo Pixel

	Activate MsDialog oDlgMemo Center

Return()
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExecFunc  บAutor  ณCristiano Machado   บ Data ณ  10/05/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Executa Qualquer Funcao e mantem as ultimas 10 executados บฑฑ
ฑฑบ          ณordenadas.                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
User Function ExecMyFunc()//| Executa Qualquer Fun็ใo   Autor: Cristiano Machado   Data: 10/05/2011
*********************************************************************
	Private lContinua 	:= .T.
	Private cLastRun 	:= GetProfString( Lower("ExecMy_"+ GetComputerName()), "LastRun"		, "undefined", .T.)

	If cLastRun == "undefined"
		cLastRun := ""
	EndIf

	While lContinua
		MontaTela()

		WriteProfString( Lower("ExecMy_"+ GetComputerName()), "LastRun"		,cLastRun	,.T.)

	EndDo

Return()
*********************************************************************
Static Function MontaTela()
*********************************************************************
	Static oJanela
	Static oButton
	Static oGet
	Static oGroup
	Static oRadOpc
	Static oSay

	Private cAuxRun 	:= cLastRun
	Private lTrue 		:= .T.

	Private  nRadOpc := 1
	Private  cFunc 	 := Space(20)


	DEFINE MSDIALOG oJanela TITLE "New Dialog" FROM 000, 000  TO 150, 500 COLORS 0, 16777215 PIXEL

	@ 004, 003 GROUP oGroup TO 050, 147 PROMPT "Executa Fun็๕es " 		   									OF oJanela COLOR  0, 16777215 	PIXEL
	@ 023, 047 MSGET oGet VAR cFunc SIZE 094, 016 	PICTURE "@E"							   				OF oJanela COLORS 0, 16777215 	PIXEL
	@ 023, 007 RADIO oRadOpc VAR nRadOpc ITEMS "Usuario","Sistema" SIZE 031, 019 							OF oJanela COLOR  0, 16777215 	PIXEL
	@ 013, 003 SAY oSay PROMPT "Tipo Fun็ใo" 	SIZE 034, 007 												OF oJanela COLORS 0, 16777215 	PIXEL
	@ 013, 046 SAY oSay PROMPT "Fun็ใo" 		SIZE 021, 007 												OF oJanela COLORS 0, 16777215 	PIXEL

	fDBTree()

	@ 055, 004 BUTTON oButton PROMPT "Executa" 	ACTION (oJanela:End() , Executa()       ) SIZE 046,012	OF oJanela 				   		PIXEL
	@ 055, 099 BUTTON oButton PROMPT "Sair" 	ACTION (oJanela:End() , lContinua := .F.) SIZE 046,012	OF oJanela 				   		PIXEL

	ACTIVATE MSDIALOG oJanela CENTERED


Return()
*********************************************************************
Static Function fDBTree()
*********************************************************************
	Static oRunTree
	True 	:= .T.
	nCount 	:= 1

	oRunTree := DbTree():New(004,155,068,245,oJanela,,,.T.)//fDBTree()
	oRunTree:AddItem(PadR("Ultimas Exec",15," "),"001", "FOLDER5" ,,,,1)

	While lTrue

		nPos := At(',',cAuxRun)
		nCount	+= 1
		If nPos <= 0
			lTrue := .F.
			Loop
		Endif

		cAuxFunc	:= 	PadR(Substr(cAuxRun,1,nPos - 1),15," ")
		cAuxCont	:= 	StrZero(nCount,3)

		oRunTree:AddItem(cAuxFunc ,cAuxCont, "FOLDER6",,,,2)

		cAuxRun	:= Substr(cAuxRun,nPos + 1)

	EndDo

	oRunTree:EndTree()

Return()
*********************************************************************
Static Function Executa()
*********************************************************************
	cFunc :=  Alltrim(cFunc)

	If Empty(cFunc)
		cFunc := Alltrim(oRunTree:GetPrompt(.T.))
	EndIf

	If nRadOpc == 1
		cFunc :=  "U_" + cFunc
	EndIf

	If At("(",cFunc) <= 0
		cFunc := cFunc + "()"
	EndIF

	&cFunc.

	Alert( " Fim da Execu็ใo da Rotina "+ cFunc )

	AtuUltFun() //| Atualiza Ultimas Funcoes Executadas

Return()
*********************************************************************
Static Function AtuUltFun()
*********************************************************************
	nVir := 0
	nPos := At("U_", cFunc )
	If nPos > 0
		cFunc :=  Substr(cFunc,3)
	EndIf

	nPos := At("(",	cFunc )
	If nPos > 0
		cFunc := Substr(cFunc,1,nPos-1)
	EndIF

	nPos := At(cFunc, cLastRun )


	If nPos <= 0
		cLastRun := cFunc + "," + cLastRun
	Else
		cLastRun := cFunc+ "," + Substr(cLastRun,1,nPos - 1) + Substr(cLastRun,nPos + Len(cFunc) + 1)
	EndIf

	nPos := 0
	For N := 1 To Len(cLastRun)

		If Substr(cLastRun,N,1) == ","
			nVir += 1
		Endif

		If nVir == 11
			nPos := N
			Exit
		EndIf

	Next

	If nPos <> 0
		cLastRun := Substr(cLastRun,1,nPos - 1)
	EndIf

	cFunc := ""

Return()
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValTelCad บAutor  ณCristiano Machado   บ Data ณ  10/05/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Valida o Telefone do Cliente/Prospect                     บฑฑ
ฑฑบ          ณ  Nao pode conter apostrofo por causa da Nf-e.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
User Function ValTelCad()
*********************************************************************
	lVal := .F.

	If Alltrim(__ReadVar) $ ("M->A1_TEL/M->US_TEL")
		If AT("-",&__ReadVar.) > 0
			Iw_MsgBox("Por Favor, Nใo Utilizar Hifen (-) no Telefone .")
		Else
			lVal := .T.
		EndIf
	Else
		lVal := .T.
	EndIf

Return(lVal)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Mensagem บAutor  ณCristiano Machado   บ Data ณ  28/05/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta Janala com botoes e/ou get.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cCaption   	:Titulo da Janela                             บฑฑ
ฑฑบ          ณ cSubTit  	:Sub Titulo da Janela                         บฑฑ
ฑฑบ          ณ cMensagem  	:Texto da Janela (400 caracteres)             บฑฑ
ฑฑบ          ณ aBotoes    	:Array com titulo dos botoes  ( Max.5 )       บฑฑ
ฑฑบ          ณ xGet			:Valor Padaro do Get                          บฑฑ
ฑฑบ          ณ cValida		:Validacao para o Get                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
User Function Men(cCaption, cSubTit, cMensagem, aBotoes, xGet, lAut)
*********************************************************************
	Local ny        := 0//                   W - COMPRIMENTO | H - ALTURA
	Local nx        := 0// Lf  Cf            W  H    LB    g
	Local aSize  := {  	{144,304, 35,155, 35,113, 61  , 37},;  	// Tamanho 1
	{144,450, 35,155, 35,185, 61  , 47},; 		// Tamanho 2
	{237,450, 35,210, 65,185, 100 , 67} } 		// Tamanho 3

	Local nLinha    := 0
	Local cMsgButton:= ""
	Local oGet

	Private oGet
	Private mGet
	Private bGet
	Private lGet := .F.

	Private oTButton1
	Private oTButton2
	Private oTButton3
	Private oTButton4
	Private oTButton5

	Private cBotao := ""
	Private oDlgAviso
	Private nOpc := 0

	If lAut == Nil
		lAut := .F.
	EndIf

	If xGet <> Nil
		Do Case
		Case ValType(xGet) == "C"
			mGet := "@!"
		Case ValType(xGet) == "N"
			mGet := "@E 999,999,999.99"
		Case ValType(xGet) == "D"
			mGet := "@"
		EndCase

		lGet := .T.
	EndIf


//ณ Verifica o numero de botoes Max. 5 e o tamanho da Msg.       ณ
	If aBotoes <> Nil
		If  Len(aBotoes) > 3
			If Len(cMensagem) > 286
				nSize := 3
			Else
				nSize := 2
			EndIf
		Else
			Do Case
			Case Len(cMensagem) > 170 .And. Len(cMensagem) < 250
				nSize := 2
			Case Len(cMensagem) >= 250
				nSize := 3
			OtherWise
				nSize := 1
			EndCase
		EndIf
	Else
		nSize := 1
	EndIf


	If nSize <= 3
		nLinha := nSize
	Else
		nLinha := 3
	EndIf

//| Monta Janela

	DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

	DEFINE MSDIALOG oDlgAviso FROM 0,0 TO aSize[nLinha][1],aSize[nLinha][2] TITLE cCaption STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) Of oMainWnd PIXEL

	@ 0, 0 BITMAP RESNAME "LOGIN" oF oDlgAviso SIZE aSize[nSize][3],aSize[nSize][4] NOBORDER WHEN .F. PIXEL ADJUST .T.
	@ 3  ,37  SAY cSubTit Of oDlgAviso PIXEL SIZE 130 ,9 FONT oBold
	@ 11 ,35  TO 13 ,400 LABEL '' OF oDlgAviso PIXEL

	If nSize <= 3
		@ 16 ,38  SAY cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5]
	Else
		@ 16 ,38  SAY cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5]
	//	@ 16 ,38  GET oGet VAR cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5] READONLY MEMO
	EndIf


	If lGet
		If nSize <= 2
			nCol := 65
		else
			nCol := 95
		Endif

		@ aSize[nLinha][8], nCol MSGET xGet PICTURE mGet SIZE 040, 	010 OF oDlgAviso COLORS 0, 16777215 PIXEL Valid( .T. )

	EndIf


//If aBotoes <> Nil

//	If Len(aBotoes) > 1
//		TButton():New(1000,1000," ",oDlgAviso,{||Nil},32,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
//	EndIf

//EndIf

	ny := (aSize[nLinha][2]/2)-36

	If aBotoes <> Nil

		For nx := Len(aBotoes) To 1 Step -1

			cMsgButton	:= OemToAnsi(AllTrim(aBotoes[Len(aBotoes)-nx+1]))
			cMsgButton	:= IF( ( "&" $ SubStr( cMsgButton , 1 , 1 ) ) , cMsgButton , ( "&"+cMsgButton ) )

			Do Case
			Case nx == 1
				@ aSize[nLinha][7], ny BUTTON oTButton1 PROMPT cMsgButton SIZE 32, 10 OF oDlgAviso Action {|| nOpc:=1 , oDlgAviso:end()} PIXEL

			Case nx == 2
				@ aSize[nLinha][7], ny BUTTON oTButton2 PROMPT cMsgButton SIZE 32, 10 OF oDlgAviso Action {|| nOpc:=2 , oDlgAviso:end()} PIXEL

			Case nx == 3
				@ aSize[nLinha][7], ny BUTTON oTButton3 PROMPT cMsgButton SIZE 32, 10 OF oDlgAviso Action {|| nOpc:=3 , oDlgAviso:end()} PIXEL

			Case nx == 4
				@ aSize[nLinha][7], ny BUTTON oTButton4 PROMPT cMsgButton SIZE 32, 10 OF oDlgAviso Action {|| nOpc:=4 , oDlgAviso:end()} PIXEL

			Case nx == 5
				@ aSize[nLinha][7], ny BUTTON oTButton5 PROMPT cMsgButton SIZE 32, 10 OF oDlgAviso Action {|| nOpc:=5 , oDlgAviso:end()} PIXEL
			EndCase
			ny -= 35
		Next

	EndIf

	Activate MsDialog oDlgAviso Centered

Return ( { nOpc , If(lGet,xGet,Nil) } )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLIBRARY   บAutor  ณEdivaldo Gonsalves  บ Data ณ  06/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna as filiais que operam com estoque.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณ|Q|- Se quiser Utilizar na Clausula IN da Query             บฑฑ
ฑฑบParametro ณ|A|- Se quiser receber Array                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*********************************************************************
User Function cRetFils(cPar) //|Parametro:( |Q|-Se quiser Utilizar na Clausula IN da Query, |A|- se quiser receber Arrey )
*********************************************************************
	Local cFilNoEst	:= GetMV('MV_FILSEST')
	Local cFiliais  := ""
	Local aFiliais 	:= {}
	Local nRecSM0

	DeFault cPar := "Q"

	DbSelectArea("SM0")
	nRecSM0 := Recno()

	DbSeek(cEmpAnt,.F.)
	Do While SM0->M0_CODIGO == cEmpAnt

		If SM0->M0_CODFIL $ cFilNoEst
			dbSkip()
			Loop
		Endif

		If cPar == "Q"
			cFiliais += "'" + SM0->M0_CODFIL + "',"
		ElseIf cPar == "A"
			Aadd(aFiliais,{M0_CODFIL,Tabela("Z3",M0_CODFIL,.F.)})
		EndIf

		DbSkip()
	EndDo

	If  cPar == "Q"
		xRetorno := Left(cFiliais,Len(cFiliais)-1)
	ElseIf cPar == "A"
		xRetorno := aFiliais
	Else
		xRetorno := ""
	EndIf

	DbGoto(nRecSM0)

Return (xRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFileCopy  บAutor  ณCristiano Machado   บ Data ณ  06/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Efetua a Copia de arquivos do Server para a pasta Temp do  บฑฑ
ฑฑบ          ณ Windows.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณ|cArquivo|- Informar o nome do Arquivo.                [Obr]บฑฑ
ฑฑบ          ณ|cDirServ|- Especificar o diretorio no Server.              บฑฑ
ฑฑบ          ณ            Padrao: \arquivos\                         [Opc]บฑฑ
ฑฑบ          ณ|lOpen|	- [.T.,.F.] Se deve abrir arquivo apos copia.[Opc]บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ|Caracter|- Caminho completo do arquivo ap๓s c๓pia ou "Erro"บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*********************************************************************
User Function FileCopy(cArquivo,cDirServ,lOpen)
*********************************************************************
	Local 	cDirTem		:= GetTempPath()
	Local 	lCopied		:= .F.
	Local 	cDrive 		:= "" //| Resultado: "c:"
	Local 	cDir   		:= "" //| Resultado: "\path\"
	Local 	cNome  		:= "" //| Resultado: "arquivo"
	Local 	cExt		:= ""
	Local 	cLArqServer	:= ""
	Local 	cLArqClient	:= ""
	Local  _ENTER 		:= CHR(13)+CHR(10)
	Default cDirServ 	:= "\arquivos\"
	Default	lOpen		:= .F.

	cLArqServer	:= cDirServ + cArquivo //| Local + nome arquivo no Servidor
	cLArqClient	:= cDirTem  + cArquivo //| Local + Nome Arquivo na Maquina Cliente pasta Temp do Windows

	If Empty(cArquivo)
		IW_MsgBox("Aten็ใo","Parametro obrigat๓rio nใo Informado [cArquivo] Fun็ใo: U_FileCopy(cArquivo) !","ALERT")
	Return("Erro")
	EndIf

	lCopied := CpyS2T( cLArqServer, cDirTem, .T. )

	If !lCopied
		IW_MsgBox(" O Arquivo nใo foi copiado ! "+_ENTER+"Origem: "+cLArqServer+_ENTER+" Destino : "+cDirTem+_ENTER,"Aten็ใo","ALERT")
	Return("Erro")
	EndIF

	If lOpen

		SplitPath(cLArqClient, @cDrive, @cDir, @cNome ,@cExt)

		cDir := StrTran(cDir,"/","\")

		nRet := ShellExecute("Open",cArquivo,"",cDrive+cDir, 1 )

	Endif


Return(cLArqClient)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFTIMETO   บAutor  ณCRISTIANO MACHADO   บ Data ณ  04/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna Diferen็a entre 2 Tempos em formato Hora ou        บฑฑ
ฑฑบ          ณ Segundos e Converte Hora para Segundo ou Segundo para Hora บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso.   1- ณ Se vc quiser Retorno em SN - Segundos Numero passar o TimeIบฑฑ
ฑฑบ          ณ e TimeF em formato Time() - Caracter                       บฑฑ
ฑฑบ       2- ณ Se vc quiser Retorno em HC - Horas Caracter passar o TimeI บฑฑ
ฑฑบ          ณ e TimeF em formato segundos numericos                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*********************************************************************
User Function FTimeTo(TimeI,TimeF,cTipo)// Retorno = SN - Segundos formato Numerico ou HC - Hora Formato Caracter
*********************************************************************
	Local Hora
	Local Min
	Local Seg
	Local TimeAux
	Local Retorno

	Default cTipo := "SN"

	If cTipo == "SN"
		Default TimeI := '00:00:00'
		Default TimeF := '00:00:00'
	Else
		Default TimeI := 0
		Default TimeF := 0
	EndIf

	If cTipo == "SN"  // Segundos Formato Numero

		If !Empty(TimeI) .And. !Empty(TimeF)
			TimeAux := ElapTime(TimeI,TimeF)
		ElseIf !Empty(TimeI)
			TimeAux := TimeI
		Else
			TimeAux := "00:00:00"
		EndIf

		Hora := Val(Substr(TimeAux,1,2)) * 3600
		Min  := Val(Substr(TimeAux,4,2)) * 60
		Seg  := Val(Substr(TimeAux,7,2))

		Retorno := Hora + Min + Seg

	ElseIf cTipo == "HC" // Hora Formato Caracter

		If TimeI <> 0 .And. TimeF <> 0
			TimeAux := TimeF - TimeI
		ElseIf TimeI <> 0
			TimeAux := TimeI
		ElseIf TimeF <> 0
			TimeAux := TimeF
		Else
			TimeAux := 0
		EndIf

		Hora := Int(   TimeAux / 3600)
		Min  := Int((  TimeAux - Hora * 3600 ) / 60 )
		Seg  := Int((  TimeAux - Hora * 3600 - Min * 60) )

		Retorno := StrZero(Hora,2) + ":" + StrZero(Min,2) + ":" + StrZero(Seg,2)

	EndIf

Return(Retorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLoadBmp   บAutor  ณCristiano Machado   บ Data ณ  08/22/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para visualizar as imagens do RPO                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

********************************************************************
User Function LoadBMP()
********************************************************************

	Local oGet
	Local 	oGroup

	Private cGet 		:= "Imagem"
	Private lExiste 	:= .F.
	Private aFontes 	:= {}
	Private nListBox 	:= 0
	Private aItens 		:= {}

	Static 	oImagem
	Static 	oDlg

	Carrega_itens()

	DEFINE MSDIALOG oDlg TITLE "New Dialog" FROM 000, 000  TO 350, 400 COLORS 0, 16777215 PIXEL

	oListBox := TListBox():New(017,010,{|u| if(Pcount()>0,nListBox := u, nListBox )},aItens,100,150,{||Ver()},oDlg,,,,.T.)

	oImagem := TBitmap():New(34,122,50,50,,/*aItens[nListBox]*/,.T.,oDlg,,,.F.,.F.,,,.F.,,.T.,,.F.)

	@ 017, 110 GROUP oGroup TO 200, 100 PROMPT "Imagem RPO" OF oDlg COLOR 0, 16777215 PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return ""
********************************************************************
Static Function Carrega_itens()
********************************************************************
	Local nFile := 0
	Local cLine := ""

	nFile := FT_FUse("\system\imagens.txt")

	If nFile == -1
	Return
	Endif

	FT_FGoTop()
	While !FT_FEOF()

		cLine  := FT_FReadLn()

		aAdd(aItens,cLine)

		FT_FSkip()

	EndDo


Return
********************************************************************
Static Function Ver()
********************************************************************
	oImagem:SetFocus()
	oImagem:SetEmpty()
	oImagem:Load ( aItens[nListBox], aItens[nListBox] )

Return(.T.)
*********************************************************************
User Function PrintArray( cDesc , _Array , lMostra)
*********************************************************************

	Private _ENTER 	:= CHR(13) + CHR(10)
	Private cTexto 	:= ""
	Private aface1 	:= {}	, aface2 	:= {}	, aface3	:= {}	, aFace4 	:= {} 	, aFace5	:= {}
	Private nT1		:= 999	, nT2		:= 999	, nT3		:= 999	, nT4 		:= 999	, nT5		:= 999
	Private nP1		:= 0 	, nP2		:= 0	, nP3		:= 0	, nP4 		:= 0	, nP5		:= 0
	Private aArray	:= _Array
	Private nFaces	:= 0


	Default cDesc 	:= ""
	Default aArray 	:= {}
	Default lMostra 	:= .T.

	cTexto	:= cDesc + _ENTER + _ENTER

	nFaces := IdentnFaces()

	VarreArray(nFaces)

	If lMostra
		U_MostraTxt( cTexto )
	EndIf

Return()
*********************************************************************
Static Function IdentnFaces()
*********************************************************************
	Local lNEntrou := .F.

	// Identifica o Numero de Faces do Array
	If ( ValType(aArray) == "A" )
		nFaces 	:= 1
		nT1			:= Len( aArray )

		If ( ValType(aArray[1]) == "A" )
			nFaces := 2
			nT2		:= Len( aArray[1] )

			If ( ValType(aArray[1][1]) == "A" )
				nFaces := 3
				nT3		:= Len(aArray[1][1])

				If ( ValType(aArray[1][1][1]) == "A" )
					nFaces := 4
					nT4		:= Len(aArray[1][1][1])

					If ( ValType(aArray[1][1][1][1]) == "A" )
						nFaces := 5
						nT5	:= Len(aArray[1][1][1][1])
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf


Return(nFaces)
*********************************************************************
Static Function VarreArray(nFaces)
*********************************************************************


	For nP1 := 1 To nT1
		If nFaces == 1
			cTexto += PegaTxt(nFaces)
		Else
			For nP2 := 1 To nT2
				If nFaces == 2
					cTexto += PegaTxt(nFaces)
				Else
					For nP3 := 1 To nT3
						If nFaces == 3
							cTexto += PegaTxt(nFaces)
						Else
							For nP4 := 1 To nT4
								If nFaces == 4
									cTexto += PegaTxt(nFaces)
								Else
									For nP5 := 1 To nT5
										If nFaces == 5
											cTexto += PegaTxt(nFaces)
										EndIF
									Next
								EndIf
							Next
						EndIf
					Next
				EndIf
			Next
		EndIf
	Next


Return()
*********************************************************************
Static Function PegaTxt(nFaces)
*********************************************************************
	Local cTxt := ""
	Local cP1 := cValToChar(nP1)
	Local cP2 := cValToChar(nP2)
	Local cP3 := cValToChar(nP3)
	Local cP4 := cValToChar(nP4)
	Local cP5 := cValToChar(nP5)

	IF ( nFaces ) == 1
		cTxt := "Array["+cP1+"] = " + cValToChar( aArray[nP1] )
	EndIf

	IF ( nFaces ) == 2
		cTxt := "Array["+cP1+"]["+cP2+"] = " + cValToChar( aArray[nP1][nP2] )
	EndIF

	IF ( nFaces ) == 3
		cTxt := "Array["+cP1+"]["+cP2+"]["+cP3+"] = " + cValToChar( aArray[nP1][nP2][nP3] )
	EndIF

	IF ( nFaces ) == 4
		cTxt := "Array["+cP1+"]["+cP2+"]["+cP3+"]["+cP4+"] = " + cValToChar( aArray[nP1][nP2][nP3][nP4] )
	EndIF

	IF ( nFaces ) == 5
		cTxt := "Array["+cP1+"]["+cP2+"]["+cP3+"]["+cP4+"]["+cP5+"] = " + cValToChar( aArray[nP1][nP2][nP3][nP4][nP5] )
	EndIF

	cTxt += _ENTER

Return ( cTxt )
*********************************************************************
User Function Date_Time_UTC(_UF) // Retorna Data e Hora no Formato UTC ( AAAA-MM-DDTHH-MM-SSTZD NFE 3.0)
*********************************************************************
	Local cZonaHServer 	:= ""
	Local cZonaHFilial 	:= ""
	Local cTimeHLocal	:= ""
	Local dData			:= dDatabase

	//| Hora Zona do Servidor Oracle
	cZonaHServer := Server_Obtem_Zona()

	//| Hora Zona da Filial Aplicacao Protheus
	cZonaHFilial := Filial_Obtem_Zona(_UF)

	// Retorna a Data e Hora no Local na UF ... Corrigindo a Diferenca entre Servidores e de acordo com Horario na UF...
	cTimeHLocal := GMT_Obtem_Hora(cZonaHServer, cZonaHFilial, @dData)

//	Alert(   dToS(dData) +"T"+ cTimeHLocal + cZonaHFilial   )

Return( dToS(dData) +"T"+ cTimeHLocal + cZonaHFilial )
*********************************************************************
Static Function GMT_Obtem_Hora(cZonaHServer, cZonaHFilial, dData)// Retorna a Data e Hora no Local na UF ... Corrigindo a Diferenca entre Servidores e de acordo com Horario na UF...
*********************************************************************

Local nSegundos 		:= 0
Local nZServXSeg 	:= cHtoN(cZonaHServer) 	* SEG_EM_HORA
Local nZFiliXSeg		:= cHtoN(cZonaHFilial) 	* SEG_EM_HORA
Local nZLocXSeg		:= nZServXSeg - nZFiliXSeg

nSegundos := U_FTimeTO(Nil,TIME(),'SN')

If (nZLocXSeg == 0 )

	nSegundos	:= U_FTimeTO(Nil,TIME(),'SN')

elseIf (nSegundos - nZLocXSeg) < 0
	dData := dData - 1
	nSegundos := ( 23 * SEG_EM_HORA ) - (nSegundos - nZLocXSeg)

Else
	nSegundos := ( nSegundos - nZLocXSeg )

EndIf


Return( U_FTimeTo(Nil,nSegundos,"HC") )
*********************************************************************
Static Function Filial_Obtem_Zona(_UF)//| Hora Zona da Filial Aplicacao Protheus
*********************************************************************

	Local cUF := _UF
	Local cZona := ""

	Default cUf := SM0->M0_ESTENT

	If cUf $ ('DF/ES/GO/MG/PR/RJ/RS/SC/SP/TO') // BRASILIA COM VERAO = -3:00 OU -2:00 TZ_OFFSET('America/Sao_Paulo')
		cZona := "'America/Sao_Paulo'"

	ElseIf cUf $ ('AL/AP/BA/CE/MA/PA/PB/PE/PI/RN/RO/SE') // BRASILIA SEM VERAO = -3:00 TZ_OFFSET('America/Recife')
		cZona := "'America/Recife'"

	ElseIf cUf $ ('MT/MS') // AMAZONIA COM VERAO = -3:00 TZ_OFFSET('America/Araguaina'))
		cZona := "'America/Araguaina'"

	ElseIf cUf $ ('AC/AM/RR') // AMAZONIA SEM VERAO = -4:00 TZ_OFFSET('Brazil/West')
		cZona := "'Brazil/West'"

	EndIf

Return( Server_Obtem_Zona(cZona) )
*********************************************************************
Static Function Server_Obtem_Zona(_TMZ)//| Hora Zona do Servidor Oracle
*********************************************************************
	Local cTimeZona := _TMZ

	Default cTimeZona := "SESSIONTIMEZONE"

	If Select("_TZS") <> 0
		DbCloseArea("_TZS")
	EndIf

	U_ExecMySql("SELECT TZ_OFFSET("+cTimeZona+") TIME FROM DUAL","_TZS","Q",.F.)

Return(_TZS->TIME)
*********************************************************************
Static Function cHtoN(cHZona) /// Converte Hora em Numero exemplo:  '-02:00' em -2
*********************************************************************
Local cSinal := Substr(cHZona,1,1)
Local nHora	:= Val(Substr(cHZona,2,2))

If cSinal == '-'
	nHora := nHora * -1
EndIf

Return(nHora)