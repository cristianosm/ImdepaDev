/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ PRENOTA∫ Autor ≥ Luiz Alberto ∫ Data ≥ 29/10/10            ∫±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±∫          ≥ ModificaÁoes e Ajustes em 03/02/11 por Julio Jacovenko     ∫±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±∫          ≥ Ajustados tamanhos do campo F1_DOC                         ∫±±
±±∫          ≥ Criar a rotina de envio de email                           ∫±±
±±∫          ≥ Ajustado NCM para 9 digitos                                ∫±±
±±∫          ≥ AtenÁ„o: MATA140( SEM TES) MATA103(COM TES)                ∫±±
±±∫          ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Leitura e Importacao Arquivo XML para geraÁ„o de Pre-Nota  ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ IMDEPA ROLAMENTOS                                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

////JULIO JACOVENKO, em 17/08/2016
////criado parametros para envio de email
////IMD_DEXML  - quem envia
////IMD_PARXML - para quem ser enviado
////IMD_CFILCD - parametro por filial, quais faturamentos irao receber
////



///JULIO JACOVENKO, em 29/02/2016
///ajustado para o codigo do produto ter 15 posicoes
///igual ao do B1_COD
///quando monta o T8 e T9
///



///JULIO JACOVENKO, em 12/02/2015
///liberado para validaÁ„o com Everton ref.
///SCHAFFLER e moeda 7.
///


//-- Julio diz:
//-- Sugiro colocar aqui um Ponto de Entrada para incluir bot„o na PrÈ-Nota de Entrada

#INCLUDE "PROTHEUS.CH"
#include "RWMAKE.ch"
#include "Colors.ch"
#include "Font.ch"
//colocado este include na Imdepa
#Include "HBUTTON.CH"
/////////////////////////////////
#include "Topconn.ch"

///ATENCAO QUANDO COLOCAR EM PRODUCAO
///-----------------------------------
///quando entrar em produÁao
///trocar o nome da funcao e do programa
///para PreNFxPed()
///pois teremos de manter a outra rotina
///para importaÁ„o sem validacoes de pedido de compra e
///gerenciamente de email.

//JULIO JACOVENKO, em 18/07/2014
//JULIO JACOVENKO, em 22/07/2014 - adicionado emails.

User Function PreNotaXML
	//Processa( {||LeXML()}, "Aguarde...","Lendo XML e Gerando PreNota...")
	Local   aTipo		:={'N','B','D'}
	Local   cFile 		:= Space(10)
	Private CPERG   	:="NOTAXML"
	Private Caminho 	:= "\servidor\system\nfe"+cfilant+"\entrada\" //dd:\NFEIMP\" //"C:\NFEIMP\XMLNFE\"  //"\System\XmlNfe\" //"E:\Protheus10_Teste\protheus_data\XmlNfe\  Foi alterado para \System\XmlNfe\ para funcionar de qualquer estacao Emerson Holanda 10/11/10
	Private _cMarca     := GetMark()
	Private aFields     := {}
	Private cArq
	Private aFields2    := {}
	Private cArq2
	Private lPcNfe		:= GETMV("MV_PCNFE")  ///SE .T. NFE SERA AMARRADA A PEDIDO DE COMPRA, DEFAULT … .F.
	Private cIniFile    := GetADV97()
	Private cStartPath  :=GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'nfe'+cfilant+'\entrada'   //'C:\IMPXMLNFE'   //GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'nfe'+cfilant+'\entrada'
	Private cErroPath   :=GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'nfe'+cfilant+'\erro'      //'C:\IMPXMLNFE'   //GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'nfe'+cfilant+'\erro'
	Private cImportPath :=GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'nfe'+cfilant+'\importada' //'C:\IMPXMLNFE'   //GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'nfe'+cfilant+'\importada'
	PUBLIC  CPEDIDO
	PUBLIC TINKEM, SHAFFLER

    ///JULIO JACOVENKO, em 17/08/2016
    ///para publicacao de Email
    ///
    PUBLIC CASSUNTO:="V3.05 - VALIDACAO USUARIO - "
    //PUBLIC CASSUNTO:="ATENCAO! TESTE EM HOMOLOGACAO  "
    //PUBLIC CASSUNTO:="ATENCAO! TESTE JULIO  "



	//CRIA DIRETORIOS
	//ALERT('...IMPORTACAO XML ENTRADA VERSAO TESTES PARA QUALQUER FORNECEDOR! VERSAO 1.30...')
	MakeDir(GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'nfe'+cfilant+'\')
	MakeDir(Trim(cStartPath)) //CRIA DIRETOTIO ENTRADA
	MakeDir(Trim(cErroPath)) //CRIA DIRETOTIO ENTRADA
	MakeDir(Trim(cImportPath)) //CRIA DIRETOTIO ENTRADA


	cPART1:=''
	FOR KY:=1 TO LEN(CSTARTPATH)
		IF SUBSTR(CSTARTPATH,KY,1)=='/'
			cPart1:=cpart1+'\'
		ELSE
			cPART1:=CPART1+SUBSTR(CSTARTPATH,KY,1)
		ENDIF
	NEXT

	CSTARTPATH:=CPART1

	PutMV("MV_PCNFE",.f.)


	nTipo := 1


	Do While .T.
		cCodBar := Space(100)

		DEFINE MSDIALOG _oPT00005 FROM  50, 050 TO 400,500 TITLE OemToAnsi('Busca de XML de Notas Fiscais de Entrada Fornecedores (V 2.05.09)') PIXEL	// "MovimentaáÑo Banc†ria"

		@ 003,005 Say OemToAnsi("Cod Barra NFE") Size 040,030
		@ 030,005 Say OemToAnsi("Tipo Nota Entrada:") Size 070,030

		@ 003,060 Get cCodBar  Picture "@!S80" Valid (AchaFile(@cCodBar),If(!Empty(cCodBar),_oPT00005:End(),.t.))  Size 150,030
		@ 020,060 RADIO oTipo VAR nTipo ITEMS "Nota Normal","Nota Beneficiamento","Nota DevoluÁ„o" SIZE 70,10 OF _oPT00005


		@ 135,060 Button OemToAnsi("Arquivo") Size 036,016 Action (GetArq(@cCodBar),_oPT00005:End())
		@ 135,110 Button OemToAnsi("Ok")  Size 036,016 Action (_oPT00005:End())
		@ 135,160 Button OemToAnsi("Sair")   Size 036,016 Action Fecha()

		Activate Dialog _oPT00005 CENTERED


		MV_PAR01 := nTipo   //"1-Nota Normal","2-Nota Beneficiamento","3-Nota DevoluÁ„o"

		cFile := cCodBar

		If !File(cFile) .and. !Empty(cFile)
			MsgAlert("Arquivo N„o Encontrado no Local de Origem Indicado!")
			PutMV("MV_PCNFE",lPcNfe)
			Return
		Endif

		Private nHdl    := fOpen(cFile,0)


		aCamposPE:={}

		If nHdl == -1
			If !Empty(cFile)
				MsgAlert("O arquivo de nome "+cFile+" nao pode ser aberto! Verifique os parametros.","Atencao!")
			Endif
			PutMV("MV_PCNFE",lPcNfe)
			Return
		Endif
		nTamFile := fSeek(nHdl,0,2)
		fSeek(nHdl,0,0)
		cBuffer  := Space(nTamFile)                // Variavel para criacao da linha do registro para leitura
		nBtLidos := fRead(nHdl,@cBuffer,nTamFile)  // Leitura  do arquivo XML
		fClose(nHdl)

		cAviso := ""
		cErro  := ""
		oNfe := XmlParser(cBuffer,"_",@cAviso,@cErro)
		Private oNF



		If Type("oNFe:_NfeProc")<> "U"
			oNF := oNFe:_NFeProc:_NFe
		Else
			oNF := oNFe:_NFe
		Endif

		Private oVersao    := oNF:_InfNfe:_Versao
		Private oEmitente  := oNF:_InfNfe:_Emit
		Private oIdent     := oNF:_InfNfe:_IDE
		Private oDestino   := oNF:_InfNfe:_Dest
		Private oTotal     := oNF:_InfNfe:_Total
		Private oTransp    := oNF:_InfNfe:_Transp
		Private oDet       := oNF:_InfNfe:_Det

		Private nPLiquido  := Val(oNF:_InfNfe:_TRANSP:_VOL:_PESOL:TEXT)
		Private nPBruto    := Val(oNF:_InfNfe:_TRANSP:_VOL:_PESOB:TEXT)

		If Type("oNF:_InfNfe:_ICMS")<> "U"
			Private oICM       := oNF:_InfNfe:_ICMS
		Else
			Private oICM		:= nil
		Endif
		Private oFatura    := IIf(Type("oNF:_InfNfe:_Cobr")=="U",Nil,oNF:_InfNfe:_Cobr)
		Private cEdit1	   := Space(15)
		Private _DESCdigit := space(55)
		Private _NCMdigit  := space(8)
		Private cCNPJ_FIL  := oNF:_INFNFE:_DEST:_CNPJ:TEXT

		Private LABORTA:= .F.
		Private APRDNE := {}

		Private LEmailVlr:=.F.
		Private aEmailVlr:={}
		Private LEmailQtd:=.F.
		Private aEmailQtd:={}

		SM0->(dbGoTop())
		While !SM0->(Eof())
			If cEmpAnt != SM0->M0_CODIGO
				SM0->(dbskip()) // ignora filiais que nao sejam da empresa ativa.
				loop
			Endif

			If cCNPJ_FIL = SM0->M0_CGC
				cFilorig := SM0->M0_CODFIL
				Exit //Forca a saida
			Endif

			SM0->(dbskip())
		EndDo


		////JULIO JACOVENKO em 24/04/2014
		////
		////nos meus testes, pelo que vi, existe um controle
		////de n vezes na consulta
		////depois de n (nao sei) ele bloqueia.
		////
		////
		/*
		///valida no SEFAZ
		//PEGA A IDENT
		lJob:=.T.
		If lJob
		cIdEnt := WSAT01GetIdEnt()
		EndIf

		//VERIFICA O STATUS NA RECEITA FEDERAL E EM CASO DE REJEICAO NAO IMPORTA
		lStatus := ConsCTEChave(Right(AllTrim(oNF:_InfNfe:_Id:Text),44),cIdEnt,lJob)

		If !lStatus
		ALERT('XML recusado.. ')
		RETURN
		EndIf

		ALERT('...TESTANTO...')
		///
		*/



		oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
		// ValidaÁıes -------------------------------
		// -- CNPJ da NOTA = CNPJ do CLIENTE ? oEmitente:_CNPJ

		//"1-Nota Normal","2-Nota Beneficiamento","3-Nota DevoluÁ„o"
		If MV_PAR01 = 1
			cTipo := "N"
		ElseIF MV_PAR01 = 2
			cTipo := "B"
		ElseIF MV_PAR01 = 3
			cTipo := "D"
		Endif


		// CNPJ ou CPF

		cCgc := AllTrim(IIf(Type("oEmitente:_CPF")=="U",oEmitente:_CNPJ:TEXT,oEmitente:_CPF:TEXT))

		If MV_PAR01 = 1 // Nota Normal Fornecedor
			If !SA2->(dbSetOrder(3), dbSeek(xFilial("SA2")+cCgc))
				MsgAlert("CNPJ Origem N„o Localizado - Verifique " + cCgc)
				PutMV("MV_PCNFE",lPcNfe)
				Return
			Endif
		Else
			If !SA1->(dbSetOrder(3), dbSeek(xFilial("SA1")+cCgc))
				MsgAlert("CNPJ Origem N„o Localizado - Verifique " + cCgc)
				PutMV("MV_PCNFE",lPcNfe)
				Return
			Endif
		Endif

		/*
		// -- Nota Fiscal j· existe na base ?      ---estava com 9 zeros, acertado para 6
		If SF1->(DbSeek(XFilial("SF1")+Right("000000"+Alltrim(OIdent:_nNF:TEXT),6)+Padr(OIdent:_serie:TEXT,3)+SA2->A2_COD+SA2->A2_LOJA))
		IF MV_PAR01 = 1
		MsgAlert("Nota No.: "+Right("000000"+Alltrim(OIdent:_nNF:TEXT),6)+"/"+OIdent:_serie:TEXT+" do Fornec. "+SA2->A2_COD+"/"+SA2->A2_LOJA+" Ja Existe. A Importacao sera interrompida")
		Else
		MsgAlert("Nota No.: "+Right("000000"+Alltrim(OIdent:_nNF:TEXT),6)+"/"+OIdent:_serie:TEXT+" do Cliente "+SA1->A1_COD+"/"+SA1->A1_LOJA+" Ja Existe. A Importacao sera interrompida")
		Endif
		PutMV("MV_PCNFE",lPcNfe)
		Return Nil
		EndIf
		*/
		//IncProc('Gravando PreNota '+Right("000000"+Alltrim(OIdent:_nNF:TEXT),6)+"/"+OIdent:_serie:TEXT+' ...')
		//INCPROC()


		aCabec := {}
		aItens := {}
		aNPC   := {}


		AITEALT:= {}

		aadd(aCabec,{"F1_FILIAL" ,CFILORIG,Nil,Nil})
		aadd(aCabec,{"F1_TIPO"   ,If(MV_PAR01==1,"N",If(MV_PAR01==2,'B','D')),Nil,Nil})
		aadd(aCabec,{"F1_FORMUL" ,"N",Nil,Nil})
		//eram para 9 zeros, ajustados para 6
		//JULIO JACOVENKO, 09/07/13
		//retorna para 9 zeros - ajustes no P11
		aadd(aCabec,{"F1_DOC"    ,Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9),Nil,Nil})
		//If OIdent:_serie:TEXT ='0'
		//	aadd(aCabec,{"F1_SERIE"  ,"   ",Nil,Nil})
		//Else

		//aadd(aCabec,{"F1_SERIE"  ,PADR( alltrim(str(val(OIdent:_serie:TEXT))),3,' '),Nil,Nil})
		//aadd(aCabec,{"F1_SERIE"  ,PADR( alltrim(str(val(OIdent:_serie:TEXT))),3,' '),Nil,Nil})
		aadd(aCabec,{"F1_SERIE"  ,PADL( alltrim(str(val(OIdent:_serie:TEXT))),3,'0'),Nil,Nil})

		//Endif


		////JULIO JACOVENKO, em 04/03/2015
		////ajustado para diferenciar layout 3.10 da 2.00
		////porque a maior diferenca he no que toca a data
		////OK - Validado pela Zelena e Lorayne, tambem
		////com todos os outros fornecedores....
		////

		if AllTrim(OVersao:TEXT)='3.10'
			cData:=SUBSTR(Alltrim(OIdent:_dhEmi:TEXT),1,10)
			DData:=CTOD(Right(cData,2)+'/'+Substr(cData,6,2)+'/'+Left(cData,4))
		else
			cData:=Alltrim(OIdent:_dEmi:TEXT)
			DData:=CTOD(Right(cData,2)+'/'+Substr(cData,6,2)+'/'+Left(cData,4))
		endif

		//dData:=CTOD(Right(cData,2)+'/'+Substr(cData,6,2)+'/'+Left(cData,4))
		aadd(aCabec,{"F1_EMISSAO",dData,Nil,Nil})
		aadd(aCabec,{"F1_FORNECE",If(MV_PAR01=1,SA2->A2_COD,SA1->A1_COD),Nil,Nil})
		aadd(aCabec,{"F1_LOJA"   ,If(MV_PAR01=1,SA2->A2_LOJA,SA1->A1_LOJA),Nil,Nil})
		aadd(aCabec,{"F1_ESPECIE","SPED",Nil,Nil})  //ESTAVA NFE, MAS PEDIRAM PARA MUDAR PARA NF, coisas do fiscal

		aadd(aCabec,{"F1_PLIQUI"    ,nPLiquido,Nil,Nil})
		aadd(aCabec,{"F1_PBRUTO"    ,nPBruto,Nil,Nil})


		///aadd(aCabec,{"F1_CHVNFE",Right(AllTrim(oNF:_InfNfe:_Id:Text),44),NIL,NIL})

		//If cTipo == "N"
		//	aadd(aCabec,{"F1_COND" ,If(Empty(SA2->A2_COND),'007',SA2->A2_COND),Nil,Nil})
		//Else
		//	aadd(aCabec,{"F1_COND" ,If(Empty(SA1->A1_COND),'007',SA1->A1_COND),Nil,Nil})
		//Endif


		// Primeiro Processamento
		// Busca de InformaÁıes para Pedidos de Compras

		cProds := ''
		cPeds  := ''
		cProdsne:= ''
		cPedsne:=''
		LPRODSNE:=.F.
		nnen:=0
		nenc:=0


		aPedIte:={}




		//////////////////////////////////////AJUSTADO EM 01/02/2013
		//////////////////////////////////////PARA FORNECEDOR N01307
		////////////////////////////////////////////////////////////
		IF MV_PAR01 = 1
			CLOJAFOR:=SA2->A2_LOJA ///GLOBAL, PARA TODAS AS NOTAS DE ENTRADA DE COMPRA
		ENDIF

		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		// -- Nota Fiscal j· existe na base ?      ---estava com 9 zeros, acertado para 6
		////JULIO JACOVENKO, em 09/07/13 - ajustes P11 - VOLTA PARA 9 ZEROS
		LCOM3:=.F.
		LCOM1:=.F.
		LCOM3:=SF1->(DbSeek(CFILORIG+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+PADL( alltrim(str(val(OIdent:_serie:TEXT))),3,'0')+SA2->A2_COD+SA2->A2_LOJA))
		LCOM1:=SF1->(DbSeek(CFILORIG+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+PADR( alltrim(str(val(OIdent:_serie:TEXT))),3,' ')+SA2->A2_COD+SA2->A2_LOJA))
		CBUSCA:="SF1->(DbSeek(CFILORIG+Right('000000000'+Alltrim(OIdent:_nNF:TEXT),9)+PADL( alltrim(str(val(OIdent:_serie:TEXT))),3,'0')+SA2->A2_COD+SA2->A2_LOJA))"
		IF LCOM3
			CBUSCA:="SF1->(DbSeek(CFILORIG+Right('000000000'+Alltrim(OIdent:_nNF:TEXT),9)+PADL( alltrim(str(val(OIdent:_serie:TEXT))),3,'0')+SA2->A2_COD+SA2->A2_LOJA))"
		ELSEIF LCOM1
			CBUSCA:="SF1->(DbSeek(CFILORIG+Right('000000000'+Alltrim(OIdent:_nNF:TEXT),9)+PADR( alltrim(str(val(OIdent:_serie:TEXT))),3,' ')+SA2->A2_COD+SA2->A2_LOJA))"
		ENDIF



		IF &CBUSCA
			//If SF1->(DbSeek(CFILORIG+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+Padr(OIdent:_serie:TEXT,3)+SA2->A2_COD+SA2->A2_LOJA))
			IF MV_PAR01 = 1
				MsgAlert("Nota No.: "+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+"/"+OIdent:_serie:TEXT+" do Fornec. "+SA2->A2_COD+"/"+CLOJAFOR+" Ja Existe na FILIAL: "+CFILORIG+". A Importacao sera interrompida")
			Else
				MsgAlert("Nota No.: "+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+"/"+OIdent:_serie:TEXT+" do Cliente "+SA1->A1_COD+"/"+SA1->A1_LOJA+" Ja Existe na FILIAL: "+CFILORIG+". A Importacao sera interrompida")
			Endif
			///NOTA JA EXISTE, mando para importada
			xFile := STRTRAN(cFile,"nfe"+cfilant+"\entrada", "nfe"+cfilant+"\importada\")

			//COPY FILE &cFile TO &xFile
			//FErase(cFile)

			//////////////////////


			PutMV("MV_PCNFE",lPcNfe)
			Return Nil
		EndIf




		For nX := 1 To Len(oDet)
			cEdit1 := Space(15)
			_DESCdigit :=space(55)
			_NCMdigit  :=space(8)



			//cProduto:=STRZERO(VAL(PadR(AllTrim(oDet[nX]:_Prod:_cProd:TEXT),20)),8)

			cProduto:=AllTrim(oDet[nX]:_Prod:_cProd:TEXT)
			CPEDIDO:=''
			If Type("oDet[nX]:_Prod:_XPED")<> "U"
				CPEDIDO :=AllTrim(oDet[nX]:_Prod:_XPED:TEXT)
				///A PEDIDO DO SUPRIMENTOS via Everton
				///precisa para Shaffler
				///se tiver VALE no campo pedido
				///pega somente o seis primeiros caracteres
				///
				////JULIO JACOVENKO, em 13/09/2016
				////tratar aqui quando for oferta RELAMPAGO
				////quando for do fornecedor SABO e para filial SC
				////CFILORIG='06'
				LSABO:=.F.
				IF cCGC $ "60860681000602#03481809000251#60860681000190#60860681000432#60860681000432#60860681000432";
				   .AND. CFILORIG='06'
				   //HE SABO
				   LSABO:=.T.
				ENDIF
				////
				CPEDANT:=''
				IF "VALE" $ CPEDIDO
				    CPEDANT:=CPEDIDO
					CPEDIDO:=SUBSTR(CPEDIDO,1,6)
			    ELSEIF ("A" $ CPEDIDO) .AND. (LSABO) //HE SABO E FILIAL SC
			        CPEDANT:=CPEDIDO
			        CPEDIDO:=SUBSTR(CPEDIDO,2,6)     //TIRA O 'A' e pega o pedido imdepa
				ENDIF
			EndIf
			xProduto:=cProduto




			cNCM    :=IIF(Type("oDet[nX]:_Prod:_NCM")=="U",space(12),oDet[nX]:_Prod:_NCM:TEXT)
			Chkproc :=.F.



            //////JULIO JACOVENKO, em 10/08/2016
            //////Tratamento para quando SA5 for
            //////N Prod Imdepa x 1 SAP
            /////////////////////////////////////////////////////////////////////////
            //Alltrim(oICM:_orig:TEXT)
            /*
            CORIG:=Alltrim(oICM:_orig:TEXT)

			IF CORIG='1'
			   CORIG:='2'
			ELSEIF CORIG='6'
			   CORIG:='7'
			ENDIF
			*/

            cORIGEM:='0' //CORIG  //DEPOIS SE PEGAR A ORIGEM, QUANDO ENTRAR FCI
            cFornece:=SA2->A2_COD
            cLojaFor:=SA2->A2_LOJA
            cCodProdb1:=fLeSa5(cPRODUTO,cOrigem,cPedido,cFilOrig,cFornece,cLojaFor,CCGC)
            IF cCodProdb1='xxxxxxxx'
               MsgAlert('Encontrado no pedido: xxxx itens duplicados com mesmo SAP')
               ReTURN .F.
            EndIf


            //////////////////////////////////////////////////////////////////////////


			If MV_PAR01 = 1

				///////////////////////////////////////TRANTAMENTO FORNECEDOR CONFORME PRODUTO
				/////////////////////////////////AQUI ENTRA O TRAMENTO PARA OS PRODUTOS
				///////////////////////////////////////////////////////////////////////
				CCODIGOP:=CCODPRODB1  //SA5->A5_PRODUTO



				If MV_PAR01 = 1  .AND.  cCgc='57000036001407' //Um 'de para' para a SCHAEFFLER BRASIL LTDA
					NITEM11=0
					NFIL04:=0
					NFIL05:=0
					_LBASEQ1:=.F.
					_LBASEQ2:=.F.
					_LBASEQ3:=.F.
					_LBASEQ4:=.F.
					cProduto:=AllTrim(oDet[NX]:_Prod:_cProd:TEXT)

					CPEDIDO:=''

					If Type("oDet[nX]:_Prod:_XPED")<> "U"
						CPEDIDO :=AllTrim(oDet[nX]:_Prod:_XPED:TEXT)
						///A PEDIDO DO SUPRIMENTOS via Everton
						///precisa para Shaffler
						///se tiver VALE no campo pedido
						///pega somente o seis primeiros caracteres
						///
						CPEDANT:=''
						IF "VALE" $ CPEDIDO
							CPEDANT:=CPEDIDO
							CPEDIDO:=SUBSTR(CPEDIDO,1,6)
						ENDIF

					EndIf


					CLOJAFOR:=SA2->A2_LOJA
					////PARA QUANDO FOR FILIAL 11, MARANHAO
					IF CFILORIG='11'
						CQUERY:=''
						CQUERY+="SELECT A5_CODPRF,A5_FORNECE,A5_PRODUTO,B1_FILIAL,B1_COD,B1_GRMAR1 FROM SA5010 SA5, SB1010 SB1 "
						CQUERY+="WHERE A5_CODPRF='"+CPRODUTO+"' "
						CQUERY+="AND A5_FORNECE='"+SA2->A2_COD+"' "
						////tratamento SA5 N X 1
						//////JULIO JACOVENKO, em 10/08/2016
						//////Tratamento para quando SA5 for
						//////N Prod Imdepa x 1 SAP
						IF ALLTRIM(CCODPROdB1)<>'' .AND. ALLTRIM(CCODPROdB1)<>'xxxxxxxx'
						   CQUERY+="AND A5_PRODUTO='"+CCODPROdB1+"' "
						ENDIF
						//////////////////////////////////////
						CQUERY+="AND A5_PRODUTO=B1_COD "
						CQUERY+="AND B1_FILIAL='11' "
						CQUERY+="AND B1_GRMAR1='000004' "
						CQUERY+="AND SA5.D_E_L_E_T_ <>'*' "
						MEMOWRIT("C:\SQLSIGA\_FIL11.TXT", cQUERY)
						cQuery := ChangeQuery(cQuery)
						TCQUERY cQuery NEW ALIAS "_FIL11"
						DBSELECTAREA('_FIL11')
						DBGOTOP()


						///////////////////////////////
						IF (_FIL11->( bof() ) .and. _FIL11->( eof() ))
							dbCloseArea("_FIL11")
							_lBASEQ1 := .F.
						ELSE
							_lBASEQ1 := .T.
							CCODIGOP:=_FIL11->B1_COD
							dbCloseArea("_FIL11")
						ENDIF
						//////////////
					ENDIF



					IF _LBASEQ1 .OR. CFILORIG='11'


						CLOJAFOR:='04'
						//aadd(aCabec,{"F1_LOJA"   ,If(MV_PAR01=1,SA2->A2_LOJA,SA1->A1_LOJA),Nil,Nil})
						aCabec[8][2]:='04'    //ForÁa loja 4

						///////////////VERIFICA SE JA EXISTE NOTA NA BASE
						// -- Nota Fiscal j· existe na base ?      ---estava com 9 zeros, acertado para 6
						// JULIO JACOVENKO, em 09/07/2013 - retorna os 9 zeros - ajustes no P11
						If SF1->(DbSeek(CFILORIG+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+Padr(OIdent:_serie:TEXT,3)+SA2->A2_COD+CLOJAFOR))
							IF MV_PAR01 = 1
								MsgAlert("Nota No.: "+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+"/"+OIdent:_serie:TEXT+" do Fornec. "+SA2->A2_COD+"/"+CLOJAFOR+" Ja Existe na FILIAL: "+CFILORIG+". A Importacao sera interrompida")
							Endif
							PutMV("MV_PCNFE",lPcNfe)
							//NOTA JA EXISTE, mando para erro
							xFile := STRTRAN(cFile,"nfe"+cfilant+"\entrada", "nfe"+cfilant+"\importada\")
							COPY FILE &cFile TO &xFile
							FErase(cFile)
							//////////////////////

							Return Nil
						EndIf
						///////////////////////////////////////////////////
					ENDIF




					////PARA QUANDO NAO FOR FILIAL 11 OU NITEM=0
					IF CFILORIG<>'11'

						CLOJAFOR:=SA2->A2_LOJA
						CQUERY:=''
						CQUERY+="SELECT A5_CODPRF, A5_FORNECE, A5_PRODUTO, B1_FILIAL, B1_GRMAR1, B1_GRMAR2, B1_COD FROM SA5010 SA5, SB1010 SB1 "
						CQUERY+="WHERE A5_CODPRF='"+CPRODUTO+"' "
						CQUERY+="AND A5_FORNECE='"+SA2->A2_COD+"'  "
						////tratamento SA5 N X 1
						//////JULIO JACOVENKO, em 10/08/2016
						//////Tratamento para quando SA5 for
						//////N Prod Imdepa x 1 SAP
						IF ALLTRIM(cCodProdb1)<>'' .AND. ALLTRIM(cCodProdb1)<>'xxxxxxxx'
						   CQUERY+="AND A5_PRODUTO='"+CCODPROdB1+"' "
						ENDIF
						//////////////////////////////////////

						CQUERY+="AND A5_PRODUTO=B1_COD "
						CQUERY+="AND B1_FILIAL='"+CFILORIG+"' "
						CQUERY+="AND B1_GRMAR1<>'000004' "
						CQUERY+="AND (B1_GRMAR2='000001' OR B1_GRMAR2='000002') "
						CQUERY+="AND SA5.D_E_L_E_T_ <>'*' "

						MEMOWRIT("C:\SQLSIGA\_FILNO4.TXT", cQUERY)
						cQuery := ChangeQuery(cQuery)
						TCQUERY cQuery NEW ALIAS "_FILNO4"
						DBSELECTAREA('_FILNO4')
						DBGOTOP()

						///////////////////////////////
						IF (_FILNO4->( bof() ) .and. _FILNO4->( eof() ))
							dbCloseArea("_FILN04")
							_lBASEQ2 := .F.
						ELSE
							_lBASEQ2 := .T.
							CCODIGOP:=_FILNO4->B1_COD
							dbCloseArea("_FILNO4")
						ENDIF



						IF _LBASEQ2
							CLOJAFOR:='04'
							aCabec[8][2]:='04'    //ForÁa loja 4
							///////////////VERIFICA SE JA EXISTE NOTA NA BASE
							// -- Nota Fiscal j· existe na base ?      ---estava com 9 zeros, acertado para 6
							// JULIO JACOVENKO, em 09/07/2013 - retorna os 9 zeros - ajustes no P11
							If SF1->(DbSeek(CFILORIG+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+Padr(OIdent:_serie:TEXT,3)+SA2->A2_COD+CLOJAFOR))
								IF MV_PAR01 = 1
									MsgAlert("Nota No.: "+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+"/"+OIdent:_serie:TEXT+" do Fornec. "+SA2->A2_COD+"/"+CLOJAFOR+" Ja Existe na FILIAL: "+CFILORIG+".A Importacao sera interrompida")
								Endif
								PutMV("MV_PCNFE",lPcNfe)
								//NOTA JA EXISTE, mando para erro
								xFile := STRTRAN(cFile,"nfe"+cfilant+"\entrada", "nfe"+cfilant+"\importada\")
								COPY FILE &cFile TO &xFile
								FErase(cFile)
								//////////////////////

								Return Nil
							EndIf
							///////////////////////////////////////////////////

						ENDIF


						CQUERY:=''
						CQUERY+="SELECT A5_CODPRF, A5_FORNECE, A5_PRODUTO, B1_FILIAL, B1_GRMAR1, B1_GRMAR2, B1_COD FROM SA5010 SA5, SB1010 SB1 "
						CQUERY+="WHERE A5_CODPRF='"+CPRODUTO+"' "
						CQUERY+="AND A5_FORNECE='"+SA2->A2_COD+"'  "
						CQUERY+="AND A5_PRODUTO=B1_COD "
						////tratamento SA5 N X 1
						//////JULIO JACOVENKO, em 10/08/2016
						//////Tratamento para quando SA5 for
						//////N Prod Imdepa x 1 SAP
						IF ALLTRIM(cCodProdb1)<>'' .AND. ALLTRIM(cCodProdb1)<>'xxxxxxxx'
						   CQUERY+="AND A5_PRODUTO='"+CCODPROdB1+"' "
						ENDIF
						//////////////////////////////////////

						CQUERY+="AND B1_FILIAL='"+CFILORIG+"' "
						CQUERY+="AND B1_GRMAR1<>'000004' "
						CQUERY+="AND (B1_GRMAR2='000003') "
						CQUERY+="AND SA5.D_E_L_E_T_ <>'*' "

						MEMOWRIT("C:\SQLSIGA\_FILNO5.TXT", cQUERY)
						cQuery := ChangeQuery(cQuery)
						TCQUERY cQuery NEW ALIAS "_FILNO5"
						DBSELECTAREA('_FILNO5')
						DBGOTOP()
						///////////////////////////////
						IF (_FILNO5->( bof() ) .and. _FILNO5->( eof() ))
							dbCloseArea("_FILNO5")
							_lBASEQ3 := .F.
						ELSE
							_lBASEQ3 := .T.
							CCODIGOP:=_FILNO5->B1_COD
							dbCloseArea("_FILNO5")
						ENDIF



						IF _LBASEQ3
							CLOJAFOR:='05'
							aCabec[8][2]:='05'    //ForÁa loja 5
							///////////////VERIFICA SE JA EXISTE NOTA NA BASE
							// -- Nota Fiscal j· existe na base ?      ---estava com 9 zeros, acertado para 6
							// JULIO JACOVENKO, em 09/07/2013 - retorna os 9 zeros - ajustes no P11
							If SF1->(DbSeek(CFILORIG+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+Padr(OIdent:_serie:TEXT,3)+SA2->A2_COD+CLOJAFOR))
								IF MV_PAR01 = 1
									MsgAlert("Nota No.: "+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+"/"+OIdent:_serie:TEXT+" do Fornec. "+SA2->A2_COD+"/"+CLOJAFOR+" Ja Existe na FILIAL: "+CFILORIG+". A Importacao sera interrompida")
								Endif
								PutMV("MV_PCNFE",lPcNfe)
								///NOTA JA EXISTE, mando para erro
								xFile := STRTRAN(cFile,"nfe"+cfilant+"\entrada", "nfe"+cfilant+"\importada\")
								COPY FILE &cFile TO &xFile
								FErase(cFile)
								//////////////////////

								Return Nil
							EndIf

						ENDIF

					ENDIF

				ENDIF
				////////////////////////////////////////////////////////////////////////////////
				//////////////////////////////////////////////////////////////////////////////////


				DBSELECTAREA('SA5')
				//SA5->(DbOrderNickName("FORPROD"))   // FILIAL + FORNECEDOR + LOJA + CODIGO PRODUTO NO FORNECEDOR
				SA5->(DbSetorder(14))
				//If !SA5->(dbSeek(xFilial("SA5")+SA2->A2_COD+SA2->A2_LOJA+cProduto))




				If !SA5->(dbSeek(xFilial("SA5")+SA2->A2_COD+CLOJAFOR+cProduto))

					//SB1->(DbSetOrder(1))
					//If !SB1->(dbSeek(xFilial("SB1")+cProduto))



					/////////ACUMULA OS CODIGOS NE ENCONTRADO
					/////////E REGISTRA PARA ABORTAR...
					LABORTA:=.T.
					cdescricao:=oDet[nX]:_Prod:_xProd:TEXT
					AADD(APRDNE,{SA2->A2_COD+' - Item: '+STRZERO(NX,3,0)+' -> '+cProduto+' - '+cdescricao})

					/////////////////VAI ACUMULAR OS CODIGOS NAO ENCONTRADOS
					/*

					If !MsgYesNo ("Produto Cod.: "+cProduto+" Nao Encontrado. Digita Codigo de Substituicao?")
					PutMV("MV_PCNFE",lPcNfe)
					Return Nil
					Endif

					DEFINE MSDIALOG _oDlg TITLE "Dig.Cod.Substituicao" FROM C(177),C(192) TO C(509),C(659) PIXEL

					// Cria as Groups do Sistema
					@ C(002),C(003) TO C(071),C(186) LABEL "Dig.Cod.Substituicao " PIXEL OF _oDlg

					// Cria Componentes Padroes do Sistema
					@ C(012),C(027) Say "Produto: "+cProduto+" - NCM: "+cNCM Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
					@ C(020),C(027) Say "Descricao: "+oDet[nX]:_Prod:_xProd:TEXT Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
					@ C(028),C(070) MsGet oEdit1 Var cEdit1 F3 "SB1" Valid(ValProd()) Size C(060),C(009) COLOR CLR_HBLUE PIXEL OF _oDlg
					@ C(040),C(027) Say "Produto digitado: "+cEdit1+" - NCM: "+_NCMdigit Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
					@ C(048),C(027) Say "Descricao: "+_DESCdigit Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
					@ C(004),C(194) Button "Processar" Size C(037),C(012) PIXEL OF _oDlg Action(Troca())
					@ C(025),C(194) Button "Cancelar" Size C(037),C(012) PIXEL OF _oDlg Action(_oDlg:End())
					oEdit1:SetFocus()

					ACTIVATE MSDIALOG _oDlg CENTERED
					If Chkproc!=.T.
					MsgAlert("Produto Cod.: "+cProduto+" Nao Encontrado. A Importacao sera interrompida")
					PutMV("MV_PCNFE",lPcNfe)
					Return Nil
					Else
					If SA5->(dbSetOrder(1), dbSeek(xFilial("SA5")+SA2->A2_COD+CLOJAFOR+cEDIT1))   //SB1->B1_COD))
					RecLock("SA5",.f.)
					Else
					Reclock("SA5",.t.)
					Endif

					SA5->A5_FILIAL := xFilial("SA5")
					SA5->A5_FORNECE := CLOJAFOR//SA2->A2_COD
					SA5->A5_LOJA 	:= SA2->A2_LOJA
					SA5->A5_NOMEFOR := SA2->A2_NOME
					SA5->A5_PRODUTO := cEDIT1 //SB1->B1_COD, codigo informado pelo usuario
					SA5->A5_NOMPROD := oDet[nX]:_Prod:_xProd:TEXT
					//			 		SA5->A5_PRODDES :=
					SA5->A5_CODPRF  := xProduto
					SA5->(MsUnlock())

					EndIf
					*/
					////////////////////////////////////////////////////

				Else
					/////////////////////////////////AQUI ENTRA O TRAMENTO PARA OS PRODUTOS
					///////////////////////////////////////////////////////////////////////
					CLOJAFOR:=SA2->A2_LOJA
					CCODIGOP:=CCODPRODB1 //SA5->A5_PRODUTO


					If MV_PAR01 = 1  .AND.  cCgc='57000036001407' //Um 'de para' para a SCHAEFFLER BRASIL LTDA


						NITEM11=0
						NFIL04:=0
						NFIL05:=0
						LBASEQ1:=.F.
						LBASEQ2:=.F.
						LBASEQ3:=.F.
						LBASEQ4:=.F.
						cProduto:=AllTrim(oDet[NX]:_Prod:_cProd:TEXT)


						CPEDIDO:=''

						If Type("oDet[nX]:_Prod:_XPED")<> "U"
							CPEDIDO :=AllTrim(oDet[nX]:_Prod:_XPED:TEXT)
							///A PEDIDO DO SUPRIMENTOS via Everton
							///precisa para Shaffler
							///se tiver VALE no campo pedido
							///pega somente o seis primeiros caracteres
							///
							CPEDANT:=''
							IF "VALE" $ CPEDIDO
								CPEDANT:=CPEDIDO
								CPEDIDO:=SUBSTR(CPEDIDO,1,6)
							ENDIF

						EndIf



						CLOJAFOR:=SA2->A2_LOJA
						////PARA QUANDO FOR FILIAL 11, MARANHAO
						IF CFILORIG='11'
							CQUERY:=''
							CQUERY+="SELECT A5_CODPRF,A5_FORNECE,A5_PRODUTO,B1_FILIAL,B1_COD,B1_GRMAR1 FROM SA5010 SA5, SB1010 SB1 "
							CQUERY+="WHERE A5_CODPRF='"+CPRODUTO+"' "
							CQUERY+="AND A5_FORNECE='"+SA2->A2_COD+"' "
						////tratamento SA5 N X 1
						//////JULIO JACOVENKO, em 10/08/2016
						//////Tratamento para quando SA5 for
						//////N Prod Imdepa x 1 SAP
						IF ALLTRIM(CCODPROdB1)<>'' .AND. ALLTRIM(CCODPROdB1)<>'xxxxxxxx'
						   CQUERY+="AND A5_PRODUTO='"+CCODPROdB1+"' "
						ENDIF
						//////////////////////////////////////

							CQUERY+="AND A5_PRODUTO=B1_COD "
							CQUERY+="AND B1_FILIAL='11' "
							CQUERY+="AND B1_GRMAR1='000004' "
							CQUERY+="AND SA5.D_E_L_E_T_ <>'*' "
							MEMOWRIT("C:\SQLSIGA\_FIL11.TXT", cQUERY)
							cQuery := ChangeQuery(cQuery)
							TCQUERY cQuery NEW ALIAS "_FIL11"
							DBSELECTAREA('_FIL11')
							DBGOTOP()
							///////////////////////////////
							IF (_FIL11->( bof() ) .and. _FIL11->( eof() ))
								dbCloseArea("_FIL11")
								_lBASEQ1 := .F.
							ELSE
								_lBASEQ1 := .T.
								CCODIGOP:=_FIL11->B1_COD
								dbCloseArea("_FIL11")
							ENDIF
							//////////////
						ENDIF



						IF _LBASEQ1 .OR. CFILORIG='11'
							CLOJAFOR:='04'
							//aadd(aCabec,{"F1_LOJA"   ,If(MV_PAR01=1,SA2->A2_LOJA,SA1->A1_LOJA),Nil,Nil})
							aCabec[8][2]:='04'    //ForÁa loja 4

							///////////////VERIFICA SE JA EXISTE NOTA NA BASE
							// -- Nota Fiscal j· existe na base ?      ---estava com 9 zeros, acertado para 6
							// JULIO JACOVENKO, em 09/07/2013 - retorna os 9 zeros - ajustes no P11
							If SF1->(DbSeek(CFILORIG+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+Padr(OIdent:_serie:TEXT,3)+SA2->A2_COD+CLOJAFOR))
								IF MV_PAR01 = 1
									MsgAlert("Nota No.: "+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+"/"+OIdent:_serie:TEXT+" do Fornec. "+SA2->A2_COD+"/"+CLOJAFOR+" Ja Existe na FILIAL: "+CFILORIG+". A Importacao sera interrompida")
								Endif
								PutMV("MV_PCNFE",lPcNfe)
								///NOTA JA EXISTE, mando para erro
								xFile := STRTRAN(cFile,"nfe"+cfilant+"\entrada", "nfe"+cfilant+"\importada\")
								COPY FILE &cFile TO &xFile
								FErase(cFile)
								//////////////////////

								Return Nil
							EndIf
							///////////////////////////////////////////////////
						ENDIF

						////PARA QUANDO NAO FOR FILIAL 11 OU NITEM=0
						IF CFILORIG<>'11'
							CLOJAFOR:=SA2->A2_LOJA
							CQUERY:=''
							CQUERY+="SELECT A5_CODPRF, A5_FORNECE, A5_PRODUTO, B1_FILIAL, B1_GRMAR1, B1_GRMAR2, B1_COD FROM SA5010 SA5, SB1010 SB1 "
							CQUERY+="WHERE A5_CODPRF='"+CPRODUTO+"' "
							CQUERY+="AND A5_FORNECE='"+SA2->A2_COD+"'  "
						////tratamento SA5 N X 1
						//////JULIO JACOVENKO, em 10/08/2016
						//////Tratamento para quando SA5 for
						//////N Prod Imdepa x 1 SAP
						IF ALLTRIM(CCODPROdB1)<>'' .AND. ALLTRIM(CCODPROdB1)<>'xxxxxxxx'
						   CQUERY+="AND A5_PRODUTO='"+CCODPROdB1+"' "
						ENDIF
						//////////////////////////////////////

							CQUERY+="AND A5_PRODUTO=B1_COD "
							CQUERY+="AND B1_FILIAL='"+CFILORIG+"' "
							CQUERY+="AND B1_GRMAR1<>'000004' "
							CQUERY+="AND (B1_GRMAR2='000001' OR B1_GRMAR2='000002') "
							CQUERY+="AND SA5.D_E_L_E_T_ <>'*' "

							MEMOWRIT("C:\SQLSIGA\_FILNO4.TXT", cQUERY)
							cQuery := ChangeQuery(cQuery)
							TCQUERY cQuery NEW ALIAS "_FILNO4"
							DBSELECTAREA('_FILNO4')
							DBGOTOP()

							///////////////////////////////
							IF (_FILNO4->( bof() ) .and. _FILNO4->( eof() ))
								dbCloseArea("_FILN04")
								_lBASEQ2 := .F.
							ELSE
								_lBASEQ2 := .T.
								CCODIGOP:=_FILNO4->B1_COD
								dbCloseArea("_FILNO4")
							ENDIF



							IF _LBASEQ2
								CLOJAFOR:='04'
								aCabec[8][2]:='04'    //ForÁa loja 4
								///////////////VERIFICA SE JA EXISTE NOTA NA BASE
								// -- Nota Fiscal j· existe na base ?      ---estava com 9 zeros, acertado para 6
								// JULIO JACOVENKO, em 09/07/2013 - retorna os 9 zeros - ajustes no P11
								If SF1->(DbSeek(CFILORIG+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+Padr(OIdent:_serie:TEXT,3)+SA2->A2_COD+CLOJAFOR))
									IF MV_PAR01 = 1
										MsgAlert("Nota No.: "+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+"/"+OIdent:_serie:TEXT+" do Fornec. "+SA2->A2_COD+"/"+CLOJAFOR+" Ja Existe na FILIAL: "+CFILORIG+".A Importacao sera interrompida")
									Endif
									PutMV("MV_PCNFE",lPcNfe)
									///NOTA JA EXISTE, mando para erro
									xFile := STRTRAN(cFile,"nfe"+cfilant+"\entrada", "nfe"+cfilant+"\importada\")
									COPY FILE &cFile TO &xFile
									FErase(cFile)
									//////////////////////

									Return Nil
								EndIf
								///////////////////////////////////////////////////

							ENDIF





							CQUERY:=''
							CQUERY+="SELECT A5_CODPRF, A5_FORNECE, A5_PRODUTO, B1_FILIAL, B1_GRMAR1, B1_GRMAR2, B1_COD FROM SA5010 SA5, SB1010 SB1 "
							CQUERY+="WHERE A5_CODPRF='"+CPRODUTO+"' "
							CQUERY+="AND A5_FORNECE='"+SA2->A2_COD+"'  "
						////tratamento SA5 N X 1
						//////JULIO JACOVENKO, em 10/08/2016
						//////Tratamento para quando SA5 for
						//////N Prod Imdepa x 1 SAP
						IF ALLTRIM(CCODPROdB1)<>'' .AND. ALLTRIM(CCODPROdB1)<>'xxxxxxxx'
						   CQUERY+="AND A5_PRODUTO='"+CCODPROdB1+"' "
						ENDIF
						//////////////////////////////////////

							CQUERY+="AND A5_PRODUTO=B1_COD "
							CQUERY+="AND B1_FILIAL='"+CFILORIG+"' "
							CQUERY+="AND B1_GRMAR1<>'000004' "
							CQUERY+="AND (B1_GRMAR2='000003') "
							CQUERY+="AND SA5.D_E_L_E_T_ <>'*' "

							MEMOWRIT("C:\SQLSIGA\_FILNO5.TXT", cQUERY)
							cQuery := ChangeQuery(cQuery)
							TCQUERY cQuery NEW ALIAS "_FILNO5"
							DBSELECTAREA('_FILNO5')
							DBGOTOP()
							///////////////////////////////
							IF (_FILNO5->( bof() ) .and. _FILNO5->( eof() ))
								dbCloseArea("_FILN05")
								_lBASEQ3 := .F.
							ELSE
								_lBASEQ3 := .T.
								CCODIGOP:=_FILNO5->B1_COD
								dbCloseArea("_FILNO5")
							ENDIF



							IF _LBASEQ3


								CLOJAFOR:='05'
								aCabec[8][2]:='05'    //ForÁa loja 5
								///////////////VERIFICA SE JA EXISTE NOTA NA BASE
								// -- Nota Fiscal j· existe na base ?      ---estava com 9 zeros, acertado para 6
								// JULIO JACOVENKO, em 09/07/2013 - retorna os 9 zeros - ajustes no P11
								If SF1->(DbSeek(CFILORIG+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+Padr(OIdent:_serie:TEXT,3)+SA2->A2_COD+CLOJAFOR))
									IF MV_PAR01 = 1
										MsgAlert("Nota No.: "+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+"/"+OIdent:_serie:TEXT+" do Fornec. "+SA2->A2_COD+"/"+CLOJAFOR+" Ja Existe na FILIAL: "+CFILORIG+". A Importacao sera interrompida")
									Endif
									PutMV("MV_PCNFE",lPcNfe)
									///NOTA JA EXISTE, mando para erro
									xFile := STRTRAN(cFile,"nfe"+cfilant+"\entrada", "nfe"+cfilant+"\importada\")
									COPY FILE &cFile TO &xFile
									FErase(cFile)
									//////////////////////

									Return Nil
								EndIf
								///////////////////////////////////////////////////

							ENDIF
						ENDIF

					ENDIF


					///////////////////////////////////////////////////////////////////////
					///////////////////////////////////////////////////////////////////////
					SB1->(dbSetOrder(1), dbSeek(CFILORIG+CCODIGOP))

					//SB1->(dbSetOrder(1), dbSeek(CFILORIG+SA5->A5_PRODUTO))

					//SB1->(dbSetOrder(1), dbSeek(xFilial("SB1")+CPRODUTO))

					If !Empty(cNCM) .and. cNCM != '00000000' .And. SB1->B1_POSIPI <> cNCM
						RecLock("SB1",.F.)
						Replace B1_POSIPI with cNCM
						MSUnLock()
					Endif
				Endif


			Else

				SA7->(DbOrderNickName("CLIPROD"))   // FILIAL + FORNECEDOR + LOJA + CODIGO PRODUTO NO FORNECEDOR
				//SA7->(DbSetOrder(3))
				If !SA7->(dbSeek(xFilial("SA7")+SA1->A1_COD+SA1->A1_LOJA+cProduto))
					//SB1->(DbSetOrder(1))
					//If !SB1->(dbSeek(xFilial("SB1")+cProduto))

					If !MsgYesNo ("Produto Cod.: "+cProduto+" Nao Encontrado. Digita Codigo de Substituicao?")
						PutMV("MV_PCNFE",lPcNfe)
						Return Nil
					Endif
					DEFINE MSDIALOG _oDlg TITLE "Dig.Cod.Substituicao" FROM C(177),C(192) TO C(509),C(659) PIXEL

					// Cria as Groups do Sistema
					@ C(002),C(003) TO C(071),C(186) LABEL "Dig.Cod.Substituicao " PIXEL OF _oDlg

					// Cria Componentes Padroes do Sistema
					@ C(012),C(027) Say "Produto: "+cProduto+" - NCM: "+cNCM Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
					@ C(020),C(027) Say "Descricao: "+oDet[nX]:_Prod:_xProd:TEXT Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
					@ C(028),C(070) MsGet oEdit1 Var cEdit1 F3 "SB1" Valid(ValProd()) Size C(060),C(009) COLOR CLR_HBLUE PIXEL OF _oDlg
					@ C(040),C(027) Say "Produto digitado: "+cEdit1+" - NCM: "+_NCMdigit Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
					@ C(048),C(027) Say "Descricao: "+_DESCdigit Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
					@ C(004),C(194) Button "Processar" Size C(037),C(012) PIXEL OF _oDlg Action(Troca())
					@ C(025),C(194) Button "Cancelar" Size C(037),C(012) PIXEL OF _oDlg Action(_oDlg:End())
					oEdit1:SetFocus()

					ACTIVATE MSDIALOG _oDlg CENTERED
					If Chkproc!=.T.
						MsgAlert("Produto Cod.: "+cProduto+" Nao Encontrado. A Importacao sera interrompida")
						PutMV("MV_PCNFE",lPcNfe)
						Return Nil
					Else
						If SA7->(dbSetOrder(1), dbSeek(xFilial("SA7")+SA1->A1_COD+SA1->A1_LOJA+cEDIT1)) //SB1->B1_COD))
							RecLock("SA7",.f.)
						Else
							Reclock("SA7",.t.)
						Endif

						SA7->A7_FILIAL := xFilial("SA7")
						SA7->A7_CLIENTE := SA1->A1_COD
						SA7->A7_LOJA 	:= SA1->A1_LOJA
						SA7->A7_DESCCLI := oDet[nX]:_Prod:_xProd:TEXT
						SA7->A7_PRODUTO := cEDIT1 //SB1->B1_COD, produto escolhido pelo usuario
						SA7->A7_CODCLI  := xProduto
						SA7->(MsUnlock())

					EndIf
				Else
					SB1->(dbSetOrder(1), dbSeek(CFILORIG+SA7->A7_PRODUTO))
					//SB1->(dbSetOrder(1), dbSeek(xFilial("SB1")+CPRODUTO))
					If !Empty(cNCM) .and. cNCM != '00000000' .And. SB1->B1_POSIPI <> cNCM
						RecLock("SB1",.F.)
						Replace B1_POSIPI with cNCM
						MSUnLock()
					Endif

					///GRAVA PRODUTOS ENCONTRADOS
					///JULIO JACOVENKO, 14/04/2014
					_areaatu:=GetArea()

					DBSELECTAREA('SC7')
					DBSETORDER(4)
				Endif
			Endif


			SB1->(dbSetOrder(1))

			_areaatu:=GetArea()

			DBSELECTAREA('SC7')
			DBSETORDER(4)
			DBGOTOP()
			///C7_FILIAL+C7_PRODUTO+C7_NUM+C7_ITEM+C7_SEQUEN


			//ALERT('PROCURA: '+SB1->B1_COD+'  '+CPEDIDO)





			//ALERT(SB1->B1_COD+ALLTRIM(CPEDIDO))


			//CFILORIG HE A FILIAL QUE ESTA NA NOTA
			//

			IF DBSEEK(XFILIAL('SC7')+SB1->B1_COD+ALLTRIM(CPEDIDO))
				//cProds += ALLTRIM(SB1->B1_COD)+'/'
				cPeds  += ALLTRIM(CPEDIDO)+ALLTRIM(SB1->B1_COD)+'/'
				//ALERT('ACHOU...SC7')
			ELSE
				//ALERT('...NAO ACHOU PEDIDO DE VENDAS...SC7')
				//ALERT('BUSCA SC7: '+XFILIAL('SC7')+SB1->B1_COD+CPEDIDO )

				///JULIO JACOVENKO, em 10/04/2014
				///guarda produto + pedido nao encontrado
				///para avisar suprimentos
				///
				//ALERT('NAO ACHOU: '+SB1->B1_COD+'  '+CPEDIDO)

				//quantidade = oDet[nX]:_Prod:_qCom:TEXT
				APROD:={}

				IF ALLTRIM(CPRODUTO)<>''
				   //JUNTA OS COD PRODUTO IMDEPA QUE ESTAO NESTE SAP
				   //
				   CQUERY:=""
				   CQUERY+="SELECT A5_FORNECE, A5_LOJA, A5_PRODUTO, A5_CODPRF FROM SA5010 "
                   CQUERY+="WHERE A5_CODPRF='"+CPRODUTO+"' "
                   		////tratamento SA5 N X 1
						//////JULIO JACOVENKO, em 10/08/2016
						//////Tratamento para quando SA5 for
						//////N Prod Imdepa x 1 SAP
						IF ALLTRIM(CCODPROdB1)<>'' .AND. ALLTRIM(CCODPROdB1)<>'xxxxxxxx'
						   CQUERY+="AND A5_PRODUTO='"+CCODPROdB1+"' "
						ENDIF
						//////////////////////////////////////

                   CQUERY+="AND D_E_L_E_T_<>'*' "
                   CQUERY+="AND A5_FORNECE='"+CFORNECE+"' "
                   CQUERY+="AND A5_LOJA='"+CLOJAFOR+"' "
                   cQuery := ChangeQuery(cQuery)
                   TCQUERY cQuery NEW ALIAS "LESA5"
                   DBSELECTAREA('LESA5')
                   DBGOTOP()
                  DO WHILE !EOF()
                      //ALERT('ENCONTROU UM PRODUTO')
                      cCodRet:=LESA5->A5_PRODUTO
                      aadd(aprod,{cCodRet})
                      LESA5->(DBSKIP())
                  ENDDO
                  dbCloseArea("LESA5")
				ENDIF

				IF ALLTRIM(CPEDANT)<>''   //JULIO JACOVENKO - TRATAMENTO PARA VALE
				                          //
				    cProdsne+= 'N.P: '+ALLTRIM(CPEDANT)+CHR(9)+' - '+CHR(9)+'Cod: '+ALLTRIM(CPRODUTO)+' / '
				ELSE
				    cProdsne+= 'N.P: '+ALLTRIM(CPEDIDO)+CHR(9)+' - '+CHR(9)+'Cod: '+ALLTRIM(CPRODUTO)+' / '
				ENDIF
				/////mostra codigos imdepas sem pedido
				/////
				for x:=1 to len(aprod)
				   if x=len(aprod)
				    cProdsne+=ALLTRIM(aprod[x][1])
				   else
				    cProdsne+=ALLTRIM(aprod[x][1])+" - "
				   endif
				next
				cProdsne+='   '+'Qtd: '+oDet[nX]:_Prod:_qCom:TEXT+CHR(13)+CHR(10)
				//cProdsne+= 'N.P: '+ALLTRIM(CPEDIDO)+CHR(9)+' - '+CHR(9)+'Cod: '+ALLTRIM(SB1->B1_COD)+CHR(9)+' - '+CHR(9)+'Qtd: '+oDet[nX]:_Prod:_qCom:TEXT+CHR(13)+CHR(10)     //' / '
				LPRODSNE:=.T.
			ENDIF
			RESTAREA(_areaatu)

			///////////////////JULIO JACOVENKO, 10/04/2014
			///////////////////////////////////////////////
			//jogar os pedidos e produtos num array
			//aqui faremos um seek com pedido + produto para ver se encontramos, se
			//positivo ai juntamos
			//C7_ ORDEM 4 - FILIAL+PRODUTO+NUMERO

			//aadd(aPeds,{CPEDIDO})
			//aadd(aProds,{SB1->B1_COD})

			///////////////////////////////////////////////

			///JULIO JACOVENKO, em 04/05/2014
			///busca no SB1 a moeda para trabalhar
			///
			nMoedaB1:=SB1->B1_MCUSTD


			AAdd(aPedIte,{SB1->B1_COD,Val(oDet[nX]:_Prod:_qTrib:TEXT),Round(Val(oDet[nX]:_Prod:_vProd:TEXT)/Val(oDet[nX]:_Prod:_qCom:TEXT),6),Val(oDet[nX]:_Prod:_vProd:TEXT),nMoedaB1})

		Next nX

		/////NAO ACHOU ALGUM PEDIDO/PRODUTO INDICADO NA NOTA
		/////ABORTA A IMPORTACAO

		//IF LProdsne
		// ALERT(cProdsne)
		//ENDIF

		IF LPRODSNE
			CFORNECE:=If(MV_PAR01=1,SA2->A2_NOME,SA1->A1_NOME)
			cCABECEM:='V3.01 - Relacao de Pedidos/Produtos na nota n„o encontrado!"
			cCorpo01:=''
			//FOR X:=1 TO LEN(aEmailQtd)
			cCorpo01:=CPRODSNE+CHR(13)+CHR(10)
			//NEXT
			CCorpo  :='Fornecedor: '+CFORNECE+CHR(13)+CHR(10)
			CCorpo  +=CHR(13)+CHR(10)+' Segue relacao de pedido/produto nao encontrados : '
			CCorpo  +=CHR(13)+CHR(10)+cCABECEM
			CCorpo  +=CHR(13)+CHR(10)+cCorpo01
			De     :=GETMV("IMD_DEXML")  //'julio.cesar@imdepa.com.br'
			cPara  :=GETMV("IMD_PARXML") //'julio.cesar@imdepa.com.br;marcio.janson@imdepa.com.br;arlete@imdepa.com.br;suprimentosnac@imdepa.com.br'
			//cPara  :='julio.cesar@imdepa.com.br'   //;everton@imdepa.com.br'

			///separar por filial com CFILORIG

			if CFILORIG='05'
				cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.cdp@imdepa.com.br'
			elseif CFILORIG='06'
				cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.itajai@imdepa.com.br'
			elseif CFILORIG='09'
				cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.spa@imdepa.com.br'
			elseif CFILORIG='13'
				cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.ctba@imdepa.com.br'
			elseif CFILORIG='02'
				cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.cba@imdepa.com.br'
			elseif CFILORIG='04'
				cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.goi@imdepa.com.br'
			elseif CFILORIG='14'
				cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.mg@imdepa.com.br'
			elseif CFILORIG='07'
				cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.vit@imdepa.com.br'
			elseif CFILORIG='11'
				cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.ma@imdepa.com.br'
			else
				cfilcdp:=''
			endif

			//cfilcdp:=''
			cPara:=cPara+';'+cfilcdp


			Assunto:=CASSUNTO+'Entrada NF '+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+' Filial: '+cfilorig+' Forn: '+CFORNECE+' - c/Relacao de N.Pedidos nao encontrados.'
			Anexo  :=''
			Copia  :=''

			ALERT(CASSUNTO+CCORPO)

			cRET:=U_EnvMyMail(De, cPara, Copia, Assunto, CCorpo, Anexo )

			If !Empty(cRet)
				Alert("Erro no Envio !!! " + cRet)
			Else
				Alert("Email Enviado com Sucesso !!!")
			Endif
			RETURN NIL
		ENDIF
		////////////////////////////////////////////////////////////



		////AQUI COMECA O TRATAMENTO DE PEDIDO DE COMPRA
		////////////////////////////////////////////////
		// Retira a Ultima "/" da Variavel cProds

		cProds := Left(cProds,Len(cProds)-1)
		cPeds  := Left(cPeds,Len(cPeds)-1)

		aCampos := {}
		aCampos2:= {}

		AADD(aCampos,{'T9_OK'			,'#','@!','2','0'})
		AADD(aCampos,{'T9_PEDIDO'		,'Pedido','@!','6','0'})
		AADD(aCampos,{'T9_ITEM'			,'Item','@!','4','0'})
		AADD(aCampos,{'T9_PRODUTO'		,'PRODUTO','@!','15','0'})
		AADD(aCampos,{'T9_DESC'			,'DescriÁ„o','@!','40','0'})
		AADD(aCampos,{'T9_UM'			,'Un','@!','02','0'})
		AADD(aCampos,{'T9_QTDE'			,'Qtde','@EZ 999,999.9999','10','4'})
		AADD(aCampos,{'T9_UNIT'			,'Unitario','@EZ 9,999,999.99','12','2'})
		AADD(aCampos,{'T9_TOTAL'		,'Total','@EZ 99,999,999.99','14','2'})
		AADD(aCampos,{'T9_EMISSAO'		,'Dt.Prev','','10','0'})
		AADD(aCampos,{'T9_ALMOX'		,'Alm','','2','0'})
		AADD(aCampos,{'T9_OBSERV'		,'ObservaÁ„o','@!','30','0'})
		AADD(aCampos,{'T9_CCUSTO'		,'C.Custo','@!','6','0'})


		////JULIO JACOVENKO, em 04/12/2014
		////
		////aqui, vamos criar dois campos novos:
		////T9_UNMOEDA - valor da mercadoria em moeda
		////             usado no pedido
		////T9_MOEDA   - moeda usada
		/////
		/////
		////T8_UNMOEDA - valor da mercadoria em moeda
		////             usado na nota
		////T8_MOEDA   - moeda usada
		////
		////nPreco := xMoeda( 48,07, SimbToMoeda( 'R$ '), 1, dDataBase )






		//JULIO JACOVENKO, em 19/03/2014
		//adicionar campo de saldo
		AADD(aCampos,{'T9_QTDACL'       ,'Qtd.Acla','@EZ 999,999.9999','10','4'})
		AADD(aCampos,{'T9_QUJE'       ,'Qtd.UJE','@EZ 999,999.9999','10','4'})
		AADD(aCampos,{'T9_ENCER'       ,'PEDENC','@!','01','0'})
		///
		AADD(aCampos,{'T9_UNMOEDA'     ,'VLRMOEDA','@EZ 999,999.9999','10','4'})
		AADD(aCampos,{'T9_MOEDA'       ,'MOEDA','@!','1','0'})



		AADD(aCampos2,{'T8_NOTA'			,'N.Fiscal','@!','6','0'})
		AADD(aCampos2,{'T8_SERIE'		,'Serie','@!','3','0'})
		AADD(aCampos2,{'T8_PRODUTO'		,'PRODUTO','@!','15','0'})
		AADD(aCampos2,{'T8_DESC'			,'DescriÁ„o','@!','40','0'})
		AADD(aCampos2,{'T8_UM'			,'Un','@!','02','0'})
		AADD(aCampos2,{'T8_QTDE'			,'Qtde','@EZ 999,999.9999','10','4'})
		AADD(aCampos2,{'T8_UNIT'			,'Unitario','@EZ 9,999,999.99','12','2'})
		AADD(aCampos2,{'T8_TOTAL'		,'Total','@EZ 99,999,999.99','14','2'})

		AADD(aCampos2,{'T8_UNMOEDA'     ,'VLRMOEDA','@EZ 999,999.9999','10','4'})
		AADD(aCampos2,{'T8_MOEDA'       ,'MOEDA','@!','1','0'})



		Cria_TC9()

		For ni := 1 To Len(aPedIte)
			RecLock("TC8",.t.)
			TC8->T8_NOTA 	:= Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)
			TC8->T8_SERIE 	:= OIdent:_serie:TEXT
			TC8->T8_PRODUTO   := aPedIte[nI,1]
			TC8->T8_DESC	    := Posicione("SB1",1,CFILORIG+aPedIte[nI,1],"B1_DESC")
			TC8->T8_UM		:= SB1->B1_UM
			TC8->T8_QTDE	:= aPedIte[nI,2]
			TC8->T8_UNIT	:= aPedIte[nI,3]
			TC8->T8_TOTAL	:= aPedIte[nI,4]

			///JULIO JACOVENKO, em 04/12/2014
			///AQUI TRATA CONFORME FORNECEDOR
			///
			////se Tinkem pega dia anterior a da emissao
			////se Scheffler pega moeda especifica
			////


			dDataMoeda:=dDATA   ///data emissao da nota


			////JULIO JACOVENKO, em 06/02/2015
			////
			////ajustar variaveis: TINKEM e SCHAFFLER
			////para .T. quando pegar o CGC e ver os
			////dados do fornecedor
			////
			////
			TINKEM:=.F.
			SHAFFLER:=.F.

			//SHEFFLER
			CGCSHF:="56993157000110#57000036001407#5700003600140X#57000036001407#57000036001407#5700003600140X"
			CGCTIN:="56990880000145#56990880000811#56990880000730#56990880001206#56990880001206#"

			IF CCGC $ CGCTIN
				TINKEM   := .T.
			ELSEIF CCGC $ CGCSHF
				SHAFFLER := .T.
			ENDIF

			//pega pela dData -1, que he a data da NF menos 1 dia
			//
			if TINKEM
				cDataMoeda:=dData-1  //pega o dia anterio a emissao
			endif

			///pega pela dData, que he a data da NF do Fornecedor
			///
			IF SHAFFLER
				CQUERY:=''
				CQUERY+="SELECT * FROM SM2010 SM2 "
				CQUERY+="WHERE M2_MOEDA7<>0 "
				CQUERY+="AND M2_DATA<='"+DTOS(dData)+"' "
				CQUERY+="ORDER BY R_E_C_N_O_ DESC"
				MEMOWRIT("C:\SQLSIGA\_FIL11XX.TXT", cQUERY)
				cQuery := ChangeQuery(cQuery)
				TCQUERY cQuery NEW ALIAS "_FIL11XX"
				DBSELECTAREA('_FIL11XX')
				DBGOTOP()
				dDataMoeda:= stod(_FIL11XX->M2_DATA)
				DBCloseArea('_FIL11XX')
			ENDIF



			cMoeda    :=aPedIte[nI,5]   //'2'


			if SHAFFLER .AND. cMoeda='2'
				//pega moeda 7 que seria moeda da schaffler
				cMoeda:='7'
			endif
			///////////////////////////


			nPrCmoeda := xMoeda( aPedIte[nI,3] , SimbToMoeda( 'R$ '), VAL(cMoeda), dDataMoeda )    //moeda 2 he dolar



			TC8->T8_UNMOEDA := nPrCMoeda
			TC8->T8_MOEDA   := cMoeda

			////julio
			//TC8->T8_UNIT    := nPrCmoeda
			//TC8->T8_TOTAL	:= aPedIte[nI,2] * nPrCmoeda



			TC8->(msUnlock())
		Next
		TC8->(dbGoTop())

		Monta_TC9()




		////JULIO JACOVENKO, 01/05/2014
		////fazer um tramento aqui para sÛ usar quand
		////for Veyance ou Sabo
		////SABO    = N00092
		////VEYANCE/GOODYEAR = N01837
		////CFORNECE:=IF(MV_PAR01=1,SA2->A2_COD,SA1->A1_COD)  //If(MV_PAR01=1,SA2->A2_NOME,SA1->A1_NOME)
		////
		LMOSTRA:=.F.


		//////JULIO JACOVENKO, 09/02/2015
		//////inicio as variaveis para saber do fornecedor
		//////que trabalham com moedas diferentes

		TINKEM:=.F.
		SHAFFLER:=.F.

		//SHEFFLER
		CGCSHF:="56993157000110#57000036001407#5700003600140X#57000036001407#57000036001407#5700003600140X"
		CGCTIN:="56990880000145#56990880000811#56990880000730#56990880001206#56990880001206#"



		IF CCGC $ CGCSHF
			TINKEM   := .T.
		ELSEIF CCGC $ CGCTIN
			SHAFFLER := .T.
		ENDIF


		///JULIO JACOVENKO, em 13/03/2015
		///quem trabalha com pedido


        CTIMK:="56990880001206#56990880000730#56990880001206#56990880000811#"
        //56990880000145
		IF cCGC $ "60860681000602#03481809000251#60860681000190#60860681000432#60860681000432#60860681000432" .OR.; //SABO
		cCGC $ "08832031000382#08832031000463#08832031000706#08832031000382#08832031000382";	         //VEYENCE
		.OR. cCGC $ CGCSHF ; //"57000036001407#56990880000145#56990880000811#56990880000730"  //SHEFF  e TINKEN
		.OR. cCGC $ CGCTIN
			LMOSTRA:=.T.
		ENDIF

		IF LMOSTRA

			If !Empty(TC9->(RecCount()))

				lOk := .f.


				////JULIO JACOVENKO, 07/05/2014 - Teste no ambiente COMP-CONTAGEM

				DbSelectArea('TC9')
				@ 100,005 TO 500,750 DIALOG oDlgPedidos TITLE "Pedidos de Compras x Nota Fiscal (Versao 2.01)"


				@ 006,005 TO 100,325 BROWSE "TC9" MARK "T9_OK" FIELDS aCampos Object _oBrwPed

				@ 066,330 BUTTON "Marcar"         SIZE 40,15 ACTION MsAguarde({||MarcarTudo()},'Marcando Registros...')
				@ 086,330 BUTTON "Desmarcar"      SIZE 40,15 ACTION MsAguarde({||DesMarcaTudo()},'Desmarcando Registros...')
				@ 106,330 BUTTON "Processar"	  SIZE 40,15 ACTION MsAguarde({|| lOk := .t. , Close(oDlgPedidos)},'Gerando e Enviando Arquivo...')
				@ 183,330 BUTTON "_Sair"          SIZE 40,15 ACTION Close(oDlgPedidos)

				//			Processa({||  } ,"Selecionando Informacoes de Pedidos de Compras...")

				DbSelectArea('TC8')

				@ 100,005 TO 190,325 BROWSE "TC8" FIELDS aCampos2 Object _oBrwPed2

				DbSelectArea('TC9')

				_oBrwPed:bMark := {|| Marcar()}

				ACTIVATE DIALOG oDlgPedidos CENTERED

			ELSE
				///NAO ACHOU NENHUM PEDIDO NA NOTA...
				///////////////////////////////////////

				/*
				IF LProdsne
				cCABECEM:='Relacao de Pedidos/Produtos na nota n„o encontrado!"
				cCorpo01:=''

				cCorpo01:=CPRODSNE+CHR(13)+CHR(10)

				CFORNECE:=If(MV_PAR01=1,SA2->A2_NOME,SA1->A1_NOME)
				CCorpo  :='Fornecedor: '+CFORNECE+CHR(13)+CHR(10)
				CCorpo  +=CHR(13)+CHR(10)+' Segue relacao de pedido/produto nao encontrados : '
				CCorpo  +=CHR(13)+CHR(10)+cCABECEM
				CCorpo  +=CHR(13)+CHR(10)+cCorpo01
				De     :='julio.cesar@imdepa.com.br'
				cPara  :='julio.cesar@imdepa.com.br;marcio.janson@imdepa.com.br;faturamento.cdp@imdepa.com.br'
				Assunto:='Entrada NF '+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+' Filial: '+cfilorig+' Forn: '+CFORNECE+' - c/Relacao de N.Pedidos nao encontrados.'
				Anexo  :=''
				Copia  :=''

				ALERT(CCORPO)

				cRET:=U_EnvMyMail(De, cPara, Copia, Assunto, CCorpo, Anexo )

				If !Empty(cRet)
				Alert("Erro no Envio !!! " + cRet)
				Else
				Alert("Email Enviado com Sucesso !!!")
				Endif
				ENDIF
				*/



				///////////////////////////////////////
			Endif
		ENDIF

		// Verifica se o usuario selecionou algum pedido de compra

		dbSelectArea("TC9")
		dbGoTop()
		ProcRegua(Reccount())

		lMarcou := .f.

		While !Eof() .And. lOk
			IncProc()
			If TC9->T9_OK  <> _cMarca
				dbSelectArea("TC9")
				TC9->(dbSkip(1));Loop
			Else
				lMarcou := .t.
				Exit
			Endif

			TC9->(dbSkip(1))
		Enddo



		/////JULIO JACOVENKO, em 01/05/2014
		/////ATE AQUI COM PEDIDO DE COMPRAS
		/////
		/////
		///
		//LMARCOU:=.F.    ///COLOCAR ESTA LINHA SE NAO HOUVER CONTROLE DE PEDIDO DE COMPRA

		/*
		///JULIO JACOVENKO, em 21/05/2014
		///SO VAI TRATAR PEDIDO DE COMPRA SE DIFERENTE DE SABO e VEYANCe
		FORNECEDOR SABO:
		60860681000602
		03481809000251
		60860681000190
		60860681000432
		60860681000432
		60860681000432



		FORNECEDOR VEYANCE:
		08832031000382
		08832031000463
		08832031000706
		08832031000382
		08832031000382

		*/

		LMARCOU:=.F.

		//	       //.OR. cCGC $ "57000036001407#56990880000145#56990880000811#56990880000730"  //SHEFF  e TINKEN


		IF cCGC $ "60860681000602#03481809000251#60860681000190#60860681000432#60860681000432#60860681000432" .OR.; //SABO
		cCGC $ "08832031000382#08832031000463#08832031000706#08832031000382#08832031000382" ; //VEYENCE
		.OR. cCGC $ CGCSHF ; //"57000036001407#56990880000145#56990880000811#56990880000730"  //SHEFF  e TINKEN
		.OR. cCGC $ CGCTIN
			LMARCOU:=.T.
		ENDIF



		///////////////////////////DEFINICAO DE QUAL FORNECEDORES IR√O USAR
		///////////////////////////O CONTROLE DE PEDIDO DE COMPRAS
		///////////////////////////



		////JULIO JACOVENKO, em 26/12/2013
		////AQUI NO LABORTA IREMOS TRATAR TAMBEM
		////QUANDO TIVER DIVERGENCIA DE PRODUTO X FORNECEDOR...


		IF  LABORTA  ///NAO ENCONTROU COD.FORNECEDO X PRODUTO IMDEPA, ENTAO ABORTA IMPORTACAO
			CPRODNE:=''
			cCorpo01:=''
			FOR XK:=1 TO LEN(APRDNE)
				CPRODNE:=CPRODNE+APRDNE[XK,1]+CHR(13)+CHR(10)			//,{SA2->A2_COD+' - '+CLOJAFOR+' -> '+cProduto})

				nf     := Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)

			NEXT

			MsgBox("Fornecedor - Item - Cod.Produto: "+CHR(13)+cProdne,"Cod N Encontrados, sera enviado ao Suprimento! Para importar novamente.", "ALERT")
			//MsgAlert("N/Emcontrou:Fornecedor - Item - Cod.Produto: "+CHR(13)+cProdne)
			PutMV("MV_PCNFE",lPcNfe)


			/////JULIO JACOVENKO, 25/04/2014
			////////////////////////////////
			/////Aqui enviar por email os produtos nao cadastrados
			/////para o suprimento.
			/////
			CFORNECE:=If(MV_PAR01=1,SA2->A2_NOME,SA1->A1_NOME)
			CCABECEM :="Relacao de Cod Prod Fornecedor N Encontrados. NF "+NF+" Filial: "+CFILORIG
			CCorpo  :='Fornecedor: '+CFORNECE+CHR(13)+CHR(10)
			CCorpo  +=CHR(13)+CHR(10)+' Segue Cod Prod Fornecedor N Encontrados.Ref N.:'+nf+' da Filial '+CFILORIG
			CCORPO  +=CHR(13)+CHR(10)+cCABECEM
			CCORPO  +=CHR(13)+CHR(10)+CPRODNE
			De     :=GETMV("IMD_DEXML") //'julio.cesar@imdepa.com.br'
			cPara  :=GETMV("IMD_PARXML") //'julio.cesar@imdepa.com.br;marcio.janson@imdepa.com.br;arlete@imdepa.com.br;suprimentosnac@imdepa.com.br'

			//cPara  :='julio.cesar@imdepa.com.br' //;everton@imdepa.com.br'

			///separar por filial com CFILORIG
			if CFILORIG='05'    //ok
				cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.cdp@imdepa.com.br'
			elseif CFILORIG='06'
				cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.itajai@imdepa.com.br'
			elseif CFILORIG='09' //0k
				cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.spa@imdepa.com.br'
			elseif CFILORIG='13'  //ok
				cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.ctba@imdepa.com.br'
			elseif CFILORIG='02'  //ok
				cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.cba@imdepa.com.br'
			elseif CFILORIG='04' //ok
				cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.goi@imdepa.com.br'
			elseif CFILORIG='14'  //ok
				cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.mg@imdepa.com.br'
			elseif CFILORIG='07'  //ok
				cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.vit@imdepa.com.br'
			elseif CFILORIG='11'  //ok
				cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.ma@imdepa.com.br'
			else
				cfilcdp:=''
			endif


			cPara:=cPara+';'+cfilcdp



			Assunto:=CASSUNTO+"Relacao de Cod Prod Fornecedor N Encontrados. NF "+NF+" Filial: "+CFILORIG
			Anexo  :=''
			Copia  :=''
			cRet:=U_EnvMyMail(De, cPara, Copia, Assunto, CCorpo, Anexo )
			If !Empty(cRet)
				Alert("Erro no Envio !!! " + cRet)
			Else
				Alert("Email Enviado com Sucesso !!!")
			Endif
			Return Nil
		ENDIF




		NITEMNF:=0
		For nX := 1 To Len(oDet)

			// Validacao: Produto Existe no SB1 ?
			// Se n„o existir, abrir janela c/ codigo da NF e descricao para digitacao do cod. substituicao.
			// Deixar opÁ„o para cancelar o processamento //  Descricao: oDet[nX]:_Prod:_xProd:TEXT

			ALINALT:={}
			aLinha := {}
			//cProduto:=STRZERO(VAL(Right(AllTrim(oDet[nX]:_Prod:_cProd:TEXT),15)),8)
			cProduto:=AllTrim(oDet[nX]:_Prod:_cProd:TEXT)
			xProduto:=cProduto

			cNCM:=IIF(Type("oDet[nX]:_Prod:_NCM")=="U",space(12),oDet[nX]:_Prod:_NCM:TEXT)
			Chkproc=.F.



            If Type("oDet[nX]:_Prod:_XPED")<> "U"
				CPEDIDO :=AllTrim(oDet[nX]:_Prod:_XPED:TEXT)
				///A PEDIDO DO SUPRIMENTOS via Everton
				///precisa para Shaffler
				///se tiver VALE no campo pedido
				///pega somente o seis primeiros caracteres
				///
				CPEDANT:=''
				IF "VALE" $ CPEDIDO
					CPEDANT:=CPEDIDO
					CPEDIDO:=SUBSTR(CPEDIDO,1,6)
				ENDIF
			EndIf

            cORIGEM:='0' //CORIG  //DEPOIS SE PEGAR A ORIGEM, QUANDO ENTRAR FCI
            cFornece:=SA2->A2_COD
            cLojaFor:=SA2->A2_LOJA
            cCodProdb1:=fLeSa5(cPRODUTO,cOrigem,cPedido,cFilOrig,cFornece,cLojaFor,cCGC)
            IF cCodProdb1='xxxxxxxx'
               MsgAlert('Encontrado no pedido: xxxx itens duplicados com mesmo SAP')
               ReTURN .F.
            EndIf





			If MV_PAR01 == 1
				//////////////////////////////////////////NOVAMENTE AQUI TENHO QUE VALIDAR A FILIAL E PRODUTO
				///////////////////////////////////////TRANTAMENTO FORNECEDOR CONFORME PRODUTO
				/////////////////////////////////AQUI ENTRA O TRAMENTO PARA OS PRODUTOS
				///////////////////////////////////////////////////////////////////////
				CCODIGOP:=CCODPRODB1  //SA5->A5_PRODUTO
				CLOJAFOR:=SA2->A2_LOJA

				If  cCgc='57000036001407' //Um 'de para' para a SCHAEFFLER BRASIL LTDA


					NITEM11=0
					NFIL04:=0
					NFIL05:=0
					LBASEQ1:=.F.
					LBASEQ2:=.F.
					LBASEQ3:=.F.
					LBASEQ4:=.F.
					cProduto:=AllTrim(oDet[nX]:_Prod:_cProd:TEXT)

					CPEDIDO:=''


					If Type("oDet[nX]:_Prod:_XPED")<> "U"
						CPEDIDO :=AllTrim(oDet[nX]:_Prod:_XPED:TEXT)
						///A PEDIDO DO SUPRIMENTOS via Everton
						///precisa para Shaffler
						///se tiver VALE no campo pedido
						///pega somente o seis primeiros caracteres
						///
					CPEDANT:=''
					IF "VALE" $ CPEDIDO
						CPEDANT:=CPEDIDO
						CPEDIDO:=SUBSTR(CPEDIDO,1,6)
					ENDIF
					EndIf



					CLOJAFOR:=SA2->A2_LOJA
					////PARA QUANDO FOR FILIAL 11, MARANHAO
					IF CFILORIG='11'
						CQUERY:=''
						CQUERY+="SELECT A5_CODPRF,A5_FORNECE,A5_PRODUTO,B1_FILIAL,B1_COD,B1_GRMAR1 FROM SA5010 SA5, SB1010 SB1 "
						CQUERY+="WHERE A5_CODPRF='"+CPRODUTO+"' "
						////tratamento SA5 N X 1
						//////JULIO JACOVENKO, em 10/08/2016
						//////Tratamento para quando SA5 for
						//////N Prod Imdepa x 1 SAP
						IF ALLTRIM(CCODPROdB1)<>'' .AND. ALLTRIM(CCODPROdB1)<>'xxxxxxxx'
						   CQUERY+="AND A5_PRODUTO='"+CCODPROdB1+"' "
						ENDIF
						//////////////////////////////////////

						CQUERY+="AND A5_FORNECE='"+SA2->A2_COD+"' "
						CQUERY+="AND A5_PRODUTO=B1_COD "
						CQUERY+="AND B1_FILIAL='11' "
						CQUERY+="AND B1_GRMAR1='000004' "
						MEMOWRIT("C:\SQLSIGA\_FIL11.TXT", cQUERY)
						cQuery := ChangeQuery(cQuery)
						TCQUERY cQuery NEW ALIAS "_FIL11"
						DBSELECTAREA('_FIL11')
						DBGOTOP()

						///////////////////////////////
						IF (_FIL11->( bof() ) .and. _FIL11->( eof() ))
							dbCloseArea("_FIL11")
							_lBASEQ1 := .F.
						ELSE
							_lBASEQ1 := .T.
							CCODIGOP:=_FIL11->B1_COD
							dbCloseArea("_FIL11")
							CLOJAFOR:='04'
							//aadd(aCabec,{"F1_LOJA"   ,If(MV_PAR01=1,SA2->A2_LOJA,SA1->A1_LOJA),Nil,Nil})
							aCabec[8][2]:='04'    //ForÁa loja 4

							///////////////VERIFICA SE JA EXISTE NOTA NA BASE
							// -- Nota Fiscal j· existe na base ?      ---estava com 9 zeros, acertado para 6

							// JULIO JACOVENKO, em 09/07/2013 - retorna os 9 zeros - ajustes no P11
							If SF1->(DbSeek(CFILORIG+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+Padr(OIdent:_serie:TEXT,3)+SA2->A2_COD+CLOJAFOR))
								IF MV_PAR01 = 1
									MsgAlert("Nota XNo.: "+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+"/"+OIdent:_serie:TEXT+" do Fornec. "+SA2->A2_COD+"/"+CLOJAFOR+" Ja Existe na FILIAL: "+CFILORIG+". A Importacao sera interrompida")
								Endif
								PutMV("MV_PCNFE",lPcNfe)
								///NOTA JA EXISTE, mando para erro
								xFile := STRTRAN(cFile,"nfe"+cfilant+"\entrada", "nfe"+cfilant+"\importada\")
								COPY FILE &cFile TO &xFile
								FErase(cFile)
								//////////////////////

								Return Nil
							EndIf
							///////////////////////////////////////////////////
						ENDIF
						//////////////
					ENDIF



					////PARA QUANDO NAO FOR FILIAL 11 OU NITEM=0
					IF CFILORIG<>'11'
						CLOJAFOR:=SA2->A2_LOJA
						CQUERY:=''
						CQUERY+="SELECT A5_CODPRF, A5_FORNECE, A5_PRODUTO, B1_FILIAL, B1_GRMAR1, B1_GRMAR2, B1_COD FROM SA5010 SA5, SB1010 SB1 "
						CQUERY+="WHERE A5_CODPRF='"+CPRODUTO+"' "
						////tratamento SA5 N X 1
						//////JULIO JACOVENKO, em 10/08/2016
						//////Tratamento para quando SA5 for
						//////N Prod Imdepa x 1 SAP
						IF ALLTRIM(CCODPROdB1)<>'' .AND. ALLTRIM(CCODPROdB1)<>'xxxxxxxx'
						   CQUERY+="AND A5_PRODUTO='"+CCODPROdB1+"' "
						ENDIF
						//////////////////////////////////////

						CQUERY+="AND A5_FORNECE='"+SA2->A2_COD+"'  "
						CQUERY+="AND A5_PRODUTO=B1_COD "
						CQUERY+="AND B1_FILIAL='"+CFILORIG+"' "
						CQUERY+="AND B1_GRMAR1<>'000004' "
						CQUERY+="AND (B1_GRMAR2='000001' OR B1_GRMAR2='000002') "
						MEMOWRIT("C:\SQLSIGA\_FILNO4.TXT", cQUERY)
						cQuery := ChangeQuery(cQuery)
						TCQUERY cQuery NEW ALIAS "_FILNO4"
						DBSELECTAREA('_FILNO4')
						DBGOTOP()

						///////////////////////////////
						IF (_FILNO4->( bof() ) .and. _FILNO4->( eof() ))
							dbCloseArea("_FILN04")
							_lBASEQ2 := .F.
						ELSE
							_lBASEQ2 := .T.
							CCODIGOP:=_FILNO4->B1_COD
							dbCloseArea("_FILNO4")
						ENDIF



						IF _LBASEQ2
							CLOJAFOR:='04'
							aCabec[8][2]:='04'    //ForÁa loja 4
							///////////////VERIFICA SE JA EXISTE NOTA NA BASE
							// -- Nota Fiscal j· existe na base ?      ---estava com 9 zeros, acertado para 6

							// JULIO JACOVENKO, em 09/07/2013 - retorna os 9 zeros - ajustes no P11
							If SF1->(DbSeek(CFILORIG+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+Padr(OIdent:_serie:TEXT,3)+SA2->A2_COD+CLOJAFOR))
								IF MV_PAR01 = 1
									MsgAlert("Nota No.: "+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+"/"+OIdent:_serie:TEXT+" do Fornec. "+SA2->A2_COD+"/"+CLOJAFOR+" Ja Existe na FILIAL: "+CFILORIG+".A Importacao sera interrompida")
								Endif
								PutMV("MV_PCNFE",lPcNfe)
								///NOTA JA EXISTE, mando para erro
								xFile := STRTRAN(cFile,"nfe"+cfilant+"\entrada", "nfe"+cfilant+"\importada\")
								COPY FILE &cFile TO &xFile
								FErase(cFile)
								//////////////////////

								Return Nil
							EndIf
							///////////////////////////////////////////////////
						ENDIF


						CQUERY:=''
						CQUERY+="SELECT A5_CODPRF, A5_FORNECE, A5_PRODUTO, B1_FILIAL, B1_GRMAR1, B1_GRMAR2, B1_COD FROM SA5010 SA5, SB1010 SB1 "
						CQUERY+="WHERE A5_CODPRF='"+CPRODUTO+"' "
						////tratamento SA5 N X 1
						//////JULIO JACOVENKO, em 10/08/2016
						//////Tratamento para quando SA5 for
						//////N Prod Imdepa x 1 SAP
						IF ALLTRIM(CCODPROdB1)<>'' .AND. ALLTRIM(CCODPROdB1)<>'xxxxxxxx'
						   CQUERY+="AND A5_PRODUTO='"+CCODPROdB1+"' "
						ENDIF
						//////////////////////////////////////

						CQUERY+="AND A5_FORNECE='"+SA2->A2_COD+"'  "
						CQUERY+="AND A5_PRODUTO=B1_COD "
						CQUERY+="AND B1_FILIAL='"+CFILORIG+"' "
						CQUERY+="AND B1_GRMAR1<>'000004' "
						CQUERY+="AND (B1_GRMAR2='000003') "
						MEMOWRIT("C:\SQLSIGA\_FILNO5.TXT", cQUERY)
						cQuery := ChangeQuery(cQuery)
						TCQUERY cQuery NEW ALIAS "_FILNO5"
						DBSELECTAREA('_FILNO5')
						DBGOTOP()
						///////////////////////////////
						IF (_FILNO5->( bof() ) .and. _FILNO5->( eof() ))
							dbCloseArea("_FILN05")
							_lBASEQ3 := .F.
						ELSE
							_lBASEQ3 := .T.
							CCODIGOP:=_FILNO5->B1_COD
							dbCloseArea("_FILNO5")
						ENDIF



						IF _LBASEQ3
							CLOJAFOR:='05'
							aCabec[8][2]:='05'    //ForÁa loja 5
							///////////////VERIFICA SE JA EXISTE NOTA NA BASE
							// -- Nota Fiscal j· existe na base ?      ---estava com 9 zeros, acertado para 6

							// JULIO JACOVENKO, em 09/07/2013 - retorna os 9 zeros - ajustes no P11
							If SF1->(DbSeek(CFILORIG+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+Padr(OIdent:_serie:TEXT,3)+SA2->A2_COD+CLOJAFOR))
								IF MV_PAR01 = 1
									MsgAlert("Nota No.: "+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+"/"+OIdent:_serie:TEXT+" do Fornec. "+SA2->A2_COD+"/"+CLOJAFOR+" Ja Existe na FILIAL: "+CFILORIG+". A Importacao sera interrompida")
								Endif
								PutMV("MV_PCNFE",lPcNfe)
								///NOTA JA EXISTE, mando para erro
								xFile := STRTRAN(cFile,"nfe"+cfilant+"\entrada", "nfe"+cfilant+"\importada\")
								COPY FILE &cFile TO &xFile
								FErase(cFile)
								//////////////////////

								Return Nil
							EndIf
							///////////////////////////////////////////////////

						ENDIF
					ENDIF

				ENDIF
				////////////////////////////////////////////////////////////////////////////////
				//////////////////////////////////////////////////////////////////////////////////



				//////////////////////////////////////////////////////////////////////////////////////////////

				DBSELECTAREA('SA5')

				//SA5->(DbOrderNickName("FORPROD"))   // FILIAL + FORNECEDOR + LOJA + CODIGO PRODUTO NO FORNECEDOR
				SA5->(DbSetOrder(14))
				SA5->(dbSeek(xFilial("SA5")+SA2->A2_COD+CLOJAFOR+cProduto))
				//CCODIGOP:=SA5->A5_PRODUTO //CCODPRODB1
				SB1->(dbSetOrder(1) , dbSeek(CFILORIG+CCODIGOP))  //SA5->A5_PRODUTO))

				//SB1->(DbSetOrder(1))
				//SB1->(dbSeek(xFilial("SB1")+cProduto))

			Else
				SA7->(DbOrderNickName("CLIPROD"))
				//SA7->(DbSetOrder(3))
				SA7->(dbSeek(xFilial("SA7")+SA1->A1_COD+SA1->A1_LOJA+cProduto))
				SB1->(dbSetOrder(1) , dbSeek(CFILORIG+SA7->A7_PRODUTO))

				//SB1->(DbSetOrder(1))
				//SB1->(dbSeek(xFilial("SB1")+cProduto))

			Endif





			//////SE SALDO NO PEDIDO JA ESTIVER CHEIO NAO CRIA NO D1
			//////


			AADD(ALINALT,{"D1_FILIAL",cFilorig           ,Nil})
			aadd(aLinha,{"D1_FILIAL",cFilorig           ,Nil})




			/*
			////JULIO JACOVENKO, em 06/01/2014 -  ler do ODET
			cProdutoX:=AllTrim(oDet[nX]:_Prod:_cProd:TEXT)
			cProdutoI:=POSICIONE('SA5',14,xFilial("SA5")+SA2->A2_COD+CLOJAFOR+cProduto,"A5_PRODUTO")
			aadd(aLinha,{"D1_COD",CPRODUTOI,Nil,Nil}) //Emerson Holanda
			*/

			//AADD(ALINALT,{"D1_COD",SB1->B1_COD,Nil,Nil})
			//aadd(aLinha,{"D1_COD",SB1->B1_COD,Nil,Nil}) //Emerson Holanda

			AADD(ALINALT,{"D1_COD",ALLTRIM(CCODPROdB1),Nil,Nil})
			aadd(aLinha,{"D1_COD",ALLTRIM(CCODPROdB1),Nil,Nil}) //Emerson Holanda

			VTOT:=0
			If Val(oDet[nX]:_Prod:_qTrib:TEXT) != 0
				AADD(ALINALT,{"D1_QUANT",Val(oDet[nX]:_Prod:_qTrib:TEXT),Nil,Nil})
				AADD(ALINALT,{"D1_VUNIT",Round(Val(oDet[nX]:_Prod:_vProd:TEXT)/Val(oDet[nX]:_Prod:_qTrib:TEXT),6),Nil,Nil})

				aadd(aLinha,{"D1_QUANT",Val(oDet[nX]:_Prod:_qTrib:TEXT),Nil,Nil})
				//aadd(aLinha,{"D1_VUNIT",Round(Val(oDet[nX]:_Prod:_vProd:TEXT)/Val(oDet[nX]:_Prod:_qTrib:TEXT),6),Nil,Nil})
				aadd(aLinha,{"D1_VUNIT",Val(oDet[nX]:_Prod:_vUnTrib:TEXT),Nil,Nil})

				VTOT:=Val(oDet[nX]:_Prod:_qTrib:TEXT) * Val(oDet[nX]:_Prod:_vUnTrib:TEXT)

			Else
				AADD(ALINALT,{"D1_QUANT",Val(oDet[nX]:_Prod:_qCom:TEXT),Nil,Nil})
				AADD(ALINALT,{"D1_VUNIT",Round(Val(oDet[nX]:_Prod:_vProd:TEXT)/Val(oDet[nX]:_Prod:_qCom:TEXT),6),Nil,Nil})

				aadd(aLinha,{"D1_QUANT",Val(oDet[nX]:_Prod:_qCom:TEXT),Nil,Nil})
				//aadd(aLinha,{"D1_VUNIT",Round(Val(oDet[nX]:_Prod:_vProd:TEXT)/Val(oDet[nX]:_Prod:_qCom:TEXT),6),Nil,Nil})
				aadd(aLinha,{"D1_VUNIT",Val(oDet[nX]:_Prod:_vUnTrib:TEXT),Nil,Nil})

				VTOT:=Val(oDet[nX]:_Prod:_qCom:TEXT) * Val(oDet[nX]:_Prod:_vUnTrib:TEXT)
			Endif
			//Val(oDet[nX]:_Prod:_vUnCom:TEXT)

			//AADD(ALINALT,{"D1_TOTAL",Val(oDet[nX]:_Prod:_vUnCom:TEXT),Nil,Nil})

			//Val(oDet[nX]:_Prod:_vProd:TEXT)
			//aadd(aLinha,{"D1_TOTAL",Val(oDet[nX]:_Prod:_vProd:TEXT),Nil,Nil})



			_cfop:=oDet[nX]:_Prod:_CFOP:TEXT

			/*
			////JULIO DIZ:
			////TENHO QUE AJUSTAR CONFORME AS NECESSIDADES DA IMDEPA...
			////
			If Left(Alltrim(_cfop),1)="5"
			_cfop:=Stuff(_cfop,1,1,"1")
			Else
			_cfop:=Stuff(_cfop,1,1,"2")
			Endif
			*/

			///acho que tenho que colocar e n„o o gatilho...
			//aadd(aLinha,{"D1_CF",_cfop,Nil,Nil})


			If Type("oDet[nX]:_Prod:_vDesc")<> "U"
				AADD(ALINALT,{"D1_VALDESC",Val(oDet[nX]:_Prod:_vDesc:TEXT),Nil,Nil})
				aadd(aLinha,{"D1_VALDESC",Val(oDet[nX]:_Prod:_vDesc:TEXT),Nil,Nil})
			else
				AADD(ALINALT,{"D1_VALDESC",0,Nil,Nil})
				aadd(aLinha,{"D1_VALDESC",0,Nil,Nil})
			Endif


			Do Case
				Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS00")<> "U"
				oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS00
				Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS10")<> "U"
				oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS10
				Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS20")<> "U"
				oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS20
				Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS30")<> "U"
				oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS30
				Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS40")<> "U"
				oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS40
				Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS51")<> "U"
				oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS51
				Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS60")<> "U"
				oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS60
				Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS70")<> "U"
				oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS70
				Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS90")<> "U"
				oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS90
			EndCase

			CST_Aux:=Alltrim(oICM:_orig:TEXT)+Alltrim(oICM:_CST:TEXT)


			AADD(ALINALT,{"D1_CLASFIS",CST_Aux,Nil,Nil})
			aadd(aLinha,{"D1_CLASFIS",CST_Aux,Nil,Nil})



			If lMarcou

				If Type("oDet[nX]:_Prod:_XPED")<> "U"
					XCPEDIDO :=AllTrim(oDet[nX]:_Prod:_XPED:TEXT)
					///A PEDIDO DO SUPRIMENTOS via Everton
					///precisa para Shaffler
					///se tiver VALE no campo pedido
					///pega somente o seis primeiros caracteres
					///
					CPEDANT:=''
					IF "VALE" $ XCPEDIDO
						XCPEDIDO:=SUBSTR(XCPEDIDO,1,6)
					ENDIF

				else
					ALERT('N√O SER POSSIVEL EFETUAR A IMPORTA«√O. FALTA O NUMERO DO PEDIDO DE COMPRAS NOS PRODUTOS!!!!')
					RETURN
				EndIf


				//aadd(aLinha,{"D1_PEDIDO",Space(06),Nil,Nil})


				aadd(aLinha,{"D1_PEDIDO",XCPEDIDO,Nil,Nil})
				//aadd(aLinha,{"D1_ITEMPC",Space(04),Nil,Nil})

				NITEMNF:=NITEMNF+1
				CITEM:=STRZERO(NITEMNF,4,0)
				aadd(aLinha,{"D1_ITEM", cITEM,NIL,NIL})

				aadd(aLinha,{"D1_ITEMPC",Space(04),Nil,Nil})


			Endif



			aadd(aItens,aLinha)
			aadd(aNPC, {AllTrim(oDet[nX]:_Prod:_XPED:TEXT)})

			////////////////////CONTROLE DE SALDO
			/////////////////////////////////////
		Next nX


		_ITEMDEL :={}
		_ITEMDELA:={}
		LSALDO:=.T.
		LEMAILSLD:=.F.

		LENCERRA:=.T.
		LEMAILENC:=.F.

		NITEMTOT:=LEN(AITENS)







		////SE JA NAO TEM PEDIDOS ENTRA AQUI
		////



		If lMarcou



			dbSelectArea("TC9")
			dbGoTop()
			//ProcRegua(Reccount())
			ProcRegua(0)

			//_ITEMDEL :={}
			//_ITEMDELA:={}
			//LSALDO:=.T.
			//NITEMTOT:=LEN(AITENS)


			While !Eof() .And. lOk

				IncProc()
				If TC9->T9_OK  <> _cMarca
					dbSelectArea("TC9")
					TC9->(dbSkip(1));Loop
				Endif


				For nItem := 1 To Len(aItens)


					///JULIO JACOVENKO, em 10/02/2015
					IF ALLTRIM(aItens[nItem,2,2])==AllTrim(TC9->T9_PRODUTO) .AND. ALLTRIM(aItens[nItem,7,2])==AllTrim(TC9->T9_PEDIDO)

						//aItens[nItem,07,2]:=AllTrim(TC9->T9_PEDIDO)
						//aItens[nItem,09,2]:=AllTrim(TC9->T9_ITEM)

						//aItens[nItem,04,2]:=TC9->T9_UNIT
						//aItens[nItem,03,2]:=TC9->T9_QTDE
						//aItens[nItem,05,2]:=TC9->T9_TOTAL

					ENDIF

					//Empty(aItens[nItem,9,2]) .AND. ALLTRIM(aItens[nItem,8,2]) == ALLTRIM(TC9->T9_PEDIDO)
					If AllTrim(aItens[nItem,2,2]) == AllTrim(TC9->T9_PRODUTO) .And. Empty(aItens[nItem,9,2]) .AND. ALLTRIM(aItens[nItem,7,2]) == ALLTRIM(TC9->T9_PEDIDO)



						TINKEM:=.F.
						SHAFFLER:=.F.

						//SHEFFLER
						CGCSHF:="56993157000110#57000036001407#5700003600140X#57000036001407#57000036001407#5700003600140X"
						CGCTIN:="56990880000145#56990880000811#56990880000730#56990880001206#56990880001206#"

						IF CCGC $ CGCTIN
							TINKEM   := .T.
						ELSEIF CCGC $ CGCSHF
							SHAFFLER := .T.
						ENDIF


						nTotProd:=(aItens[nItem,3,2]*aItens[nItem,4,2])/aItens[nItem,3,2]
						nTotPed :=(TC9->T9_TOTAL/TC9->T9_QTDE)
						IF SHAFFLER
							////CONVERTE DADOS DA NF
							////para o Dolar da Scheffler
							////PARA PEGAR CABECALHO
							////ACABEC[1,N]
							CQUERY:=''
							CQUERY+="SELECT * FROM SM2010 SM2 "
							CQUERY+="WHERE M2_MOEDA7<>0 "
							CQUERY+="AND M2_DATA<='"+DTOS(DDATA)+"' "
							CQUERY+="ORDER BY R_E_C_N_O_ DESC"
							MEMOWRIT("C:\SQLSIGA\_AFIL11XY.TXT", cQUERY)
							cQuery := ChangeQuery(cQuery)
							TCQUERY cQuery NEW ALIAS "_AFIL11XY"
							DBSELECTAREA('_AFIL11XY')
							DBGOTOP()
							dDataMoeda:= STOD(_AFIL11XY->M2_DATA)
							DBCloseArea('_AFIL11XY')
							cMoeda    :=Posicione("SB1",1,CFILORIG+TC9->T9_PRODUTO,"B1_MCUSTD")
							if SHAFFLER .AND. cMoeda='2'
								cMoeda:='7'  ///moeda da schaffler seria a 7
							endif
							////converte valor nf para dolar shaffler
							nPrCmoeda := xMoeda( aitens[nitem,4,2] , SimbToMoeda( 'R$ '), VAL(cMoeda), dDataMoeda )
							nTotProd  :=nPrCmoeda
							nTotPed   :=TC9->T9_UNMOEDA
						ENDIF




						LSALDO:=.T.

						//IF  TC9->T9_QTDACL >= AITENS[NITEM,3,2]
						IF (   (AITENS[NITEM,3,2] > (TC9->T9_QTDE - TC9->T9_QTDACL)) .AND. (TC9->T9_QTDACL<>0) )
							ALERT('Qtd. >= Saldo Pedido - Prod: '+aItens[nItem,2,2]+' qtdNF: '+str(aItens[nItem,3,2],13,4)+' sldPd: '+str(TC9->T9_QTDACL,13,4))
							LSALDO:=.F.
							_DELITEM:=NITEM
							AADD(_ITEMDEL ,{_DELITEM,ACABEC[1,2]+ACABEC[4,2]+ACABEC[5,2]+ACABEC[7,2]+ACABEC[8,2]+AITENS[NITEM,2,2]})
							//AADD(_ITEMDELA,{AITENS[NITEM,1,2],AITENS[NITEM,2,2],AITENS[NITEM,3,2],AITENS[NITEM,4,2],AITENS[NITEM,5,2],AITENS[NITEM,6,2],AITENS[NITEM,7,2],AITENS[NITEM,8,2],AITENS[NITEM,9,2]})
							AADD(_ITEMDELA,{AITENS[NITEM,1,2],AITENS[NITEM,2,2],AITENS[NITEM,3,2],AITENS[NITEM,4,2],AITENS[NITEM,3,2]*AITENS[NITEM,4,2],AITENS[NITEM,5,2],AITENS[NITEM,6,2],AITENS[NITEM,7,2],AITENS[NITEM,8,2]})
							nf     := Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)
							nPC    := aNPC[nItem,1] //TC9->T9_PEDIDO
							cproduto:= aItens[nItem,2,2]
							valorNF:= aItens[nItem,4,2]
							valorPC:= TC9->T9_UNIT
							qtdaNF := aItens[nItem,3,2]
							qtdPC  := TC9->T9_QTDE

							valorNFD:= nTotProd
							nmoeda  := TC9->T9_MOEDA
							valorPCD:= nTotPed

							aadd(aEmailVlr,{nf, nPC, cproduto, valorNF, valorPC, qtdaNF, qtdPC, VALORNFD, NMOEDA, ValorPCD})  //Adiciona itens com diferenca
							//no array aEmailVlr (dif valores)
							LEmailSld:=.T.	                                                       //confirma envio de email

						ENDIF

						LENCERRA:=.T.

						IF (   TC9->T9_ENCER='E' )
							ALERT('Produto '+aItens[nItem,2,2]+' qtdNF: '+str(aItens[nItem,3,2],13,4)+' ja foi encerrado neste pedido!')
							LENCERRA:=.F.
							_DELITEM:=NITEM
							AADD(_ITEMDEL ,{_DELITEM,ACABEC[1,2]+ACABEC[4,2]+ACABEC[5,2]+ACABEC[7,2]+ACABEC[8,2]+AITENS[NITEM,2,2]})
							//AADD(_ITEMDELA,{AITENS[NITEM,1,2],AITENS[NITEM,2,2],AITENS[NITEM,3,2],AITENS[NITEM,4,2],AITENS[NITEM,5,2],AITENS[NITEM,6,2],AITENS[NITEM,7,2],AITENS[NITEM,8,2],AITENS[NITEM,9,2]})
							AADD(_ITEMDELA,{AITENS[NITEM,1,2],AITENS[NITEM,2,2],AITENS[NITEM,3,2],AITENS[NITEM,4,2],AITENS[NITEM,3,2]*AITENS[NITEM,4,2],AITENS[NITEM,5,2],AITENS[NITEM,6,2],AITENS[NITEM,7,2],AITENS[NITEM,8,2]})
							nf     := Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)
							nPC    := aNPC[nItem,1] //TC9->T9_PEDIDO
							cproduto:= aItens[nItem,2,2]
							valorNF:= aItens[nItem,4,2]
							valorPC:= TC9->T9_UNIT
							qtdaNF := aItens[nItem,3,2]
							qtdPC  := TC9->T9_QTDE

							valorNFD:= nTotProd
							nmoeda  := TC9->T9_MOEDA
							valorPCD:= nTotPed

							aadd(aEmailVlr,{nf, nPC, cproduto, valorNF, valorPC, qtdaNF, qtdPC, VALORNFD, NMOEDA, ValorPCD})  //Adiciona itens com diferenca
							//no array aEmailVlr (dif valores)
							LEMAILENC:=.T.
						ENDIF

						//aqui verifica valores....
						///


						If !Empty(TC9->T9_QTDE) .AND. LSALDO .AND. LENCERRA


							//aItens[nItem,8,2] := TC9->T9_PEDIDO
							//aItens[nItem,9,2] := TC9->T9_ITEM

							aItens[nItem,7,2] := TC9->T9_PEDIDO
							aItens[nItem,9,2] := TC9->T9_ITEM


							//ALERT('... : '+STR(NITEM)+'  '+STR(TC9->T9_ITEM))


							/*
							LOCAL aArray
							aArray := { 1, 2, 3 }            // Resulta: { 1, 2, 3 }
							ADEL(aArray, 2)                // Resulta: { 1, 3, NIL }

							LOCAL aArray := { 1 }       // Resulta: { 1 }
							ASIZE(aArray, 3)               // Resulta: { 1, NIL, NIL }
							ASIZE(aArray, 1)               // Resulta: { 1 }
							*/

							///JULIO JACOVENKO,em 30/09/2014
							///a ocorrencia do C7_TOTAL VINDO ZERADO

							////JULIO JACOVENKO, em 09/01/2013
							////AQUI QUANDO HOUVER DIFERENCA ENTRE O PEDIDO E A NF
							////VAMOS REPORTAR VIA EMAIL
							////

							///PARA DIFEREN«A EM VALORES....
							///Se diferenÁa no preÁo entre o faturado e o pedido for de maior ou igual a 2%
							///e maior que R$ 0,25 para mais ou menos, disparar email para suprimentos com assunto
							///DIVERGENCIA DE PRE«O E NOME DO FORNECEDOR. No corpo do email deve constar:
							///N˙mero de nf, produto, valor e quantidade, caso contr·rio liberar entrada.

							/// TC9->TC9_TOTAL/TC0->TC9_QTDE - quantidade do pedido de compra
							/// Round(Val(oDet[nX]:_Prod:_vProd:TEXT)/Val(oDet[nX]:_Prod:_qCom:TEXT)

							///Primeiro vemos SALDO PRODUTO
							///JULIO JACOVENKO, em 19/03/2014
							///ver tambem no C7_QTDACLA se tem saldo ou <

							///JULIO JACOVENKO, em 11/02/2015
							///tratar com moeda quando produto for moeda 2
							///trato primeiro pedido
							///


							///JULIO JACOVENKO, em 18/03/2015
							///na nf o total do produto difere do calculo
							//


							nTotProd:=(aItens[nItem,3,2]*aItens[nItem,4,2])/aItens[nItem,3,2]
							nTotPed :=(TC9->T9_TOTAL/TC9->T9_QTDE)


							////JULIO JACOVENKO, em 02/02/2015
							////para Schaffler tratamento diferenciado
							////pois usa moeda 7.
							IF SHAFFLER

								////CONVERTE DADOS DA NF
								////para o Dolar da Scheffler
								////PARA PEGAR CABECALHO
								////ACABEC[1,N]
								CQUERY:=''
								CQUERY+="SELECT * FROM SM2010 SM2 "
								CQUERY+="WHERE M2_MOEDA7<>0 "
								CQUERY+="AND M2_DATA<='"+DTOS(DDATA)+"' "
								CQUERY+="ORDER BY R_E_C_N_O_ DESC"
								MEMOWRIT("C:\SQLSIGA\_AFIL11XY.TXT", cQUERY)
								cQuery := ChangeQuery(cQuery)
								TCQUERY cQuery NEW ALIAS "_AFIL11XY"
								DBSELECTAREA('_AFIL11XY')
								DBGOTOP()
								dDataMoeda:= STOD(_AFIL11XY->M2_DATA)
								DBCloseArea('_AFIL11XY')
								cMoeda    :=Posicione("SB1",1,CFILORIG+TC9->T9_PRODUTO,"B1_MCUSTD")
								if SHAFFLER .AND. cMoeda='2'
									cMoeda:='7'  ///moeda da schaffler seria a 7
								endif
								////converte valor nf para dolar shaffler
								nPrCmoeda := xMoeda( aitens[nitem,4,2] , SimbToMoeda( 'R$ '), VAL(cMoeda), dDataMoeda )

								nTotProd  :=nPrCmoeda
								nTotPed   :=TC9->T9_UNMOEDA
							ENDIF




							//Round((aItens[nItem,3,2]*aItens[nItem,4,2])



							IF (nTotProd > nTOTPED)

								//nDoisP:=Round(aItens[nItem,5,2]/aItens[nItem,4,2],6) * (2/100)  //(2/100)
								//nDif2P:=Round(aItens[nItem,5,2]/aItens[nItem,4,2],6) - TC9->T9_TOTAL/TC9->T9_QTDE

								nDoisP:=nTotProd * (2/100)  //(2/100)
								nDif2P:=nTotProd - nTotPed

								///valor da diferencao entre nota e pedido nao pode ser maior que 2% e
								///e a difereca nao pode ser maior do que 0.25 centavos
								///0.25 tanto para dolar quanto para reais.


								IF (NDIF2P >= NDOISP) .AND. (NDIF2P > 0.25)
									///aqui mandaria email
									///usar funcao pronta para tal
									///monta num array os itens com diferenca e da um flag como .T.
									///para enviar email
									///monta num array os itens com diferenca e da um flag como .T.
									///para enviar email
									nf     := Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)

									//nPC    := aItens[nItem,8,2]+' / '+aitens[nItem,9,2]
									//nPC    := aItens[nItem,6,2]+' / '+aitens[nItem,7,2]

									nPC    := aNPC[nItem,1] //aitens[nItem,7,2]

									cproduto:= aItens[nItem,2,2]
									valorNF := aItens[nItem,4,2]
									valorNFD:= nTotProd
									nmoeda  := cMoeda

									valorPC := TC9->T9_UNIT
									valorPCD:= TC9->T9_UNMOEDA

									qtdaNF := aItens[nItem,3,2]
									qtdPC  := TC9->T9_QTDE

									aadd(aEmailVlr,{nf, nPC, cproduto, valorNF, valorPC, qtdaNF, qtdPC, VALORNFD, NMOEDA, VALORPCD})  //Adiciona itens com diferenca
									//no array aEmailVlr (dif valores)
									LEmailVlr:=.T.	  //confirma envio de email
								ENDIF


							ENDIF


							///PARA DIFERENCA EM QUANTIDADE
							///Dispara email para suprimentos  com o assunto: PEDIDO A MENOR E NOME DO FORNECEDOR.
							///No corpo do email deve constar: produto, a quantidade de itens da nf,
							///a quantidade de itens do pedido, diferenÁa a ser incluÌda e n˙mero do pedido
							///em aberto que contenha este item para a filial.


							/// TC9->TC9_QTDE - quantidade do pedido de compra
							/// Val(oDet[nX]:_Prod:_qTrib:TEXT)
							IF aItens[nItem,3,2] > TC9->T9_QTDE
								///aqui mandaria email
								///usar funcao pronta para tal
								///monta num array os itens com diferenca e da um flag como .T.
								///para enviar email


								//ALERT(aItens[nItem,8,2] + ' / ' + aItens[nItem,9,2])

								//ALERT(aItens[nItem,7,2] + ' / ' + aItens[nItem,8,2])
								//ALERT(aItens[nItem,3,2])
								//ALERT(TC9->T9_QTDE)



								nf     := Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)

								//nPC    := aItens[nItem,8,2] + ' / ' + aItens[nItem,9,2]
								nPC    := aNPC[NITEM,1] + ' / ' + aItens[nItem,9,2]  //aItens[nItem,7,2] + ' / ' + aItens[nItem,8,2]

								cproduto:= aItens[nItem,2,2]
								valorNF:= aItens[nItem,4,2]
								valorPC:= TC9->T9_UNIT
								qtdaNF := aItens[nItem,3,2]
								qtdPC  := TC9->T9_QTDE

								//ALERT('Erro qtd: '+cproduto+' qtdNF: '+str(qtdanf)+' qtdPC: '+str(qtdPC) )


								aadd(aEmailQtd,{nf, nPC, cproduto, valorNF, valorPC, qtdaNF, qtdPC})  //Adiciona itens com diferenca


								LEmailQtd:=.T.
								//aadd(aEmailQtd,{nf, nPC, produto, valorNF, valorPC, qtdaNF, qtdPC})
							ENDIF




							//ALERT(TC9->T9_PEDIDO+' '+TC9->T9_PRODUTO+' '+STR(aItens[nItem,3,2])+' '+STR(TC9->T9_QTDE))

							//IF TC9->T9_PRODUTO<>'00073749'
							/* JULIO JACOVENKO, em 04/03/2016
							//ESTA DANDO ERRO QUANDO FAZ MSUNLOCK
							//NAO HE MAIS NECESSARIO ESTE CONTROLE
							/////////////////////////////////
							If RecLock('TC9',.f.)
							If (TC9->T9_QTDE-aItens[nItem,3,2]) < 0
							TC9->T9_QTDE := 0
							Else
							TC9->T9_QTDE := (TC9->T9_QTDE - aItens[nItem,3,2])
							Endif
							TC9->(MsUnlock())
							//MsUnlock()
							Endif
							*/
							//ENDIF


						Endif

					Endif

				Next

				/*
				//DELETA ITEM COM INCONSISTENCIA
				// _DELITEM
				ALERT(LEN(_ITEMDEL))
				IF LEN(_ITEMDEL)>=1
				FOR XXY:=1 TO LEN(_ITEMDEL)
				//nLenItens:=len(aItens) - 1
				//nLenItens:=len(aItens) - LEN(_ITEMDEL)
				ADEL(aItens, _ITEMDEL[XXY,1])                // Resulta: { 1, 3, NIL }
				//ASIZE(aItens,nLenItens)
				NEXT
				//nLenItens:=len(aItens) - LEN(_ITEMDEL)
				//ASIZE(aItens,nLenItens)
				LSALDO:=.T.
				ENDIF
				*/
				TC9->(dbSkip(1))
			Enddo



			IF LEN(_ITEMDEL)>=1
				FOR XXY:=1 TO LEN(_ITEMDEL)
					//nLenItens:=len(aItens) - 1
					//nLenItens:=len(aItens) - LEN(_ITEMDEL)
					ADEL(aItens, _ITEMDEL[XXY,1])                // Resulta: { 1, 3, NIL }
				NEXT
				//nLenItens:=len(aItens) - LEN(_ITEMDEL)
				//ASIZE(aItens,nLenItens)
				LSALDO:=.T.
				LENCERRA:=.T.
			ENDIF

			nLenItens:=len(aItens) - LEN(_ITEMDEL)
			ASIZE(aItens,nLenItens)


			////JULIO JACOVENKO, 27/01/2014
			////
			/////SE HOUVE DIFERENCAS EM VALOR OU QUANTIDADE, ENVIO EMAIL
			/////sera enviado email para diferencas e outro para valor
			/////



			cCorpo01:=''
			cCABECEM:=' '   //' NF.Fornec'+CHR(9)+'N.Ped.'+CHR(9)+'CodProd'+CHR(9)+'VlrNF'+CHR(9)+'VlrPC'+CHR(9)+'QtdNF'+CHR(9)+'QtdPC'
			cRet    :=''


			CFORNECE:=If(MV_PAR01=1,SA2->A2_NOME,SA1->A1_NOME)





			IF LEMAILSLD   //SE HOUVE DIFERENCA COM SLD
				cCorpo01:=''
				///PEGO ITEN(S)
				//aadd(aEmailVlr,{nf, nPC, produto, valorNF, valorPC, qtdaNF, qtdPC})
				FOR X:=1 TO LEN(aEmailVlr)
					//cCorpo01+=aEmailVlr[x,1]+CHR(9)+aEmailVlr[x,2]+CHR(9)+aEmailVlr[x,3]+CHR(9)+STR(aEmailVlr[x,4])+CHR(9)+STR(aEmailVlr[x,5])+CHR(9)+STR(aEmailVlr[x,6])+CHR(9)+STR(aEmailVlr[x,7])+CHR(13)+CHR(10)

					cCorpo01+='NF.Fornec: '+aEmailVlr[x,1]+CHR(13)+CHR(10)+'N.Pedido: '+aEmailVlr[x,2]+CHR(13)+CHR(10)+;
					'Cod.Prod : '+aEmailVlr[x,3]+CHR(13)+CHR(10)+'Vlr.NF  : '+STR(aEmailVlr[x,4])+CHR(13)+CHR(10)+;
					'Vlr.PC   : '+STR(aEmailVlr[x,5])+CHR(13)+CHR(10)+'Qtd.NF :'+STR(aEmailVlr[x,6])+CHR(13)+CHR(10)+;
					'Qtd.PC   : '+STR(aEmailVlr[x,7])+CHR(13)+CHR(10)+CHR(13)+CHR(10)

				NEXT
				CCorpo  :='Fornecedor: '+CFORNECE+CHR(13)+CHR(10)
				CCorpo  +=CHR(13)+CHR(10)+' Segue Produto/Pedido j· classifado encontradas : '
				CCORPO  +=CHR(13)+CHR(10)+cCABECEM
				CCORPO  +=CHR(13)+CHR(10)+cCorpo01
				De     :=GETMV("IMD_DEXML") //'julio.cesar@imdepa.com.br'
				cPara  :=GETMV("IMD_PARXML") //'julio.cesar@imdepa.com.br;marcio.janson@imdepa.com.br;arlete@imdepa.com.br;suprimentosnac@imdepa.com.br'
				//cPara  :='julio.cesar@imdepa.com.br' //;everton@imdepa.com.br'


				///separar por filial com CFILORIG
				if CFILORIG='05'    //ok
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.cdp@imdepa.com.br'
				elseif CFILORIG='06'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.itajai@imdepa.com.br'
				elseif CFILORIG='09' //0k
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.spa@imdepa.com.br'
				elseif CFILORIG='13'  //ok
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.ctba@imdepa.com.br'
				elseif CFILORIG='02'  //ok
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.cba@imdepa.com.br'
				elseif CFILORIG='04' //ok
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.goi@imdepa.com.br'
				elseif CFILORIG='14'  //ok
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.mg@imdepa.com.br'
				elseif CFILORIG='07'  //ok
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.vit@imdepa.com.br'
				elseif CFILORIG='11'  //ok
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.ma@imdepa.com.br'
				else
					cfilcdp:=''
				endif


				cPara:=cPara +';'+cfilcdp



				Assunto:=CASSUNTO+"Entrada NF "+aEmailVlr[1,1]+"Filial: "+cFilorig+" Forn: "+CFORNECE+" - c/Divergencia Produto/Pedido j· classifado encontradas"
				Anexo  :=''
				Copia  :=''

				ALERT(CASSUNTO+CCORPO)

				cRet:=U_EnvMyMail(De, cPara, Copia, Assunto, CCorpo, Anexo )

				If !Empty(cRet)
					Alert("Erro no Envio !!! " + cRet)
				Else
					Alert("Email Enviado com Sucesso !!!")
				Endif

				//LEMAILSLD:=.F.
			ENDIF



			////////////////
			IF LEMAILENC   //SE HOUVE DIFERENCA COM SLD


				cCorpo01:=''
				///PEGO ITEN(S)
				//aadd(aEmailVlr,{nf, nPC, produto, valorNF, valorPC, qtdaNF, qtdPC})
				FOR X:=1 TO LEN(aEmailVlr)
					//cCorpo01+=aEmailVlr[x,1]+CHR(9)+aEmailVlr[x,2]+CHR(9)+aEmailVlr[x,3]+CHR(9)+STR(aEmailVlr[x,4])+CHR(9)+STR(aEmailVlr[x,5])+CHR(9)+STR(aEmailVlr[x,6])+CHR(9)+STR(aEmailVlr[x,7])+CHR(13)+CHR(10)

					cCorpo01+='NF.Fornec: '+aEmailVlr[x,1]+CHR(13)+CHR(10)+'N.Pedido: '+aEmailVlr[x,2]+CHR(13)+CHR(10)+;
					'Cod.Prod : '+aEmailVlr[x,3]+CHR(13)+CHR(10)+'Vlr.NF  : '+STR(aEmailVlr[x,4])+CHR(13)+CHR(10)+;
					'Vlr.PC   : '+STR(aEmailVlr[x,5])+CHR(13)+CHR(10)+'Qtd.NF :'+STR(aEmailVlr[x,6])+CHR(13)+CHR(10)+;
					'Qtd.PC   : '+STR(aEmailVlr[x,7])+CHR(13)+CHR(10)+CHR(13)+CHR(10)

				NEXT
				CCorpo  :='Fornecedor: '+CFORNECE+CHR(13)+CHR(10)
				CCorpo  +=CHR(13)+CHR(10)+' Segue Produto/Pedido j· classifado encontradas : '
				CCORPO  +=CHR(13)+CHR(10)+cCABECEM
				CCORPO  +=CHR(13)+CHR(10)+cCorpo01
				De     :=GETMV("IMD_DEXML") //'julio.cesar@imdepa.com.br'
				cPara  :=GETMV("IMD_PARXML") //'julio.cesar@imdepa.com.br;marcio.janson@imdepa.com.br;arlete@imdepa.com.br;suprimentosnac@imdepa.com.br'
				//cPara  :='julio.cesar@imdepa.com.br'  //;everton@imdepa.com.br'

				///separar por filial com CFILORIG
				if CFILORIG='05'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.cdp@imdepa.com.br'
				elseif CFILORIG='06'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.itajai@imdepa.com.br'
				elseif CFILORIG='09'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.spa@imdepa.com.br'
				elseif CFILORIG='13'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.ctba@imdepa.com.br'
				elseif CFILORIG='02'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.cba@imdepa.com.br'
				elseif CFILORIG='04'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.goi@imdepa.com.br'
				elseif CFILORIG='14'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.mg@imdepa.com.br'
				elseif CFILORIG='07'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.vit@imdepa.com.br'
				elseif CFILORIG='11'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.ma@imdepa.com.br'
				else
					cfilcdp:=''
				endif

				cPara:=cPara+';'+cfilcdp


				Assunto:=CASSUNTO+"Entrada NF "+aEmailVlr[1,1]+"Filial: "+cFilorig+" Forn: "+CFORNECE+" - c/Produto/Pedido j· encerrado"
				Anexo  :=''
				Copia  :=''

				ALERT(CASSUNTO+CCORPO)

				cRet:=U_EnvMyMail(De, cPara, Copia, Assunto, CCorpo, Anexo )

				If !Empty(cRet)
					Alert("Erro no Envio !!! " + cRet)
				Else
					Alert("Email Enviado com Sucesso !!!")
				Endif

				//LEMAILSLD:=.F.
			ENDIF



			///////////////





			IF LEMAILVLR   //SE HOUVE DIFERENCA COM VALOR

				cCorpo01:=''
				///PEGO ITEN(S)
				//aadd(aEmailVlr,{nf, nPC, produto, valorNF, valorPC, qtdaNF, qtdPC})
				FOR X:=1 TO LEN(aEmailVlr)
					//cCorpo01+=aEmailVlr[x,1]+CHR(9)+aEmailVlr[x,2]+CHR(9)+aEmailVlr[x,3]+CHR(9)+STR(aEmailVlr[x,4])+CHR(9)+STR(aEmailVlr[x,5])+CHR(9)+STR(aEmailVlr[x,6])+CHR(9)+STR(aEmailVlr[x,7])+CHR(13)+CHR(10)
					//'NF.Fornec: '+aEmailVlr[x,1]+CHR(13)+CHR(10)+
					cCorpo01+='N.Pedido : '+aEmailVlr[x,2]+CHR(13)+CHR(10)+;
					'Cod.Prod : '+aEmailVlr[x,3]+CHR(13)+CHR(10)+;
					'Vlr.NF   : '+STR(aEmailVlr[x,4])+" / Vlr.NF.U$ :"+STR(aEmailVlr[x,8])+"/"+aEmailVlr[x,9]+CHR(13)+CHR(10)+;
					'Qtd.NF   : '+STR(aEmailVlr[x,6])+CHR(13)+CHR(10)+;
					'Vlr.PC   : '+STR(aEmailVlr[x,5])+" / Vlr.PC.U$ :"+STR(aEmailVlr[x,10])+CHR(13)+CHR(10)+;
					'Qtd.PC   : '+STR(aEmailVlr[x,7])+CHR(13)+CHR(10)+CHR(13)+CHR(10)
				NEXT

				CCorpo  :='Fornecedor: '+CFORNECE+CHR(13)+CHR(10)
				CCorpo  +=CHR(13)+CHR(10)+' Segue diferencas por valor encontradas (se valores unitarios iguais,'
				cCorpo  +=CHR(13)+CHR(10)+' verifique se o Total no Pedido esta zerado ou '
				cCorpo  +=CHR(13)+CHR(10)+' qtd produto vezes vlr unitario nao fecha com total do produto) : '

				CCORPO  +=CHR(13)+CHR(10)+cCABECEM
				CCORPO  +=CHR(13)+CHR(10)+cCorpo01
				De     :=GETMV("IMD_DEXML") //'julio.cesar@imdepa.com.br'
				cPara  :=GETMV("IMD_PARXML") //'julio.cesar@imdepa.com.br;marcio.janson@imdepa.com.br;arlete@imdepa.com.br;suprimentosnac@imdepa.com.br'
				//cPara  :='julio.cesar@imdepa.com.br'   //;everton@imdepa.com.br'



				///separar por filial com CFILORIG
				if CFILORIG='05'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.cdp@imdepa.com.br'
				elseif CFILORIG='06'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.itajai@imdepa.com.br'
				elseif CFILORIG='09'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.spa@imdepa.com.br'
				elseif CFILORIG='13'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.ctba@imdepa.com.br'
				elseif CFILORIG='02'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.cba@imdepa.com.br'
				elseif CFILORIG='04'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.goi@imdepa.com.br'
				elseif CFILORIG='14'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.mg@imdepa.com.br'
				elseif CFILORIG='07'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.vit@imdepa.com.br'
				elseif CFILORIG='11'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.ma@imdepa.com.br'
				else
					cfilcdp:=''
				endif

				cPara:=cPara+';'+cfilcdp



				Assunto:=CASSUNTO+'Entrada NF '+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+' Filial: '+cfilorig+' Forn: '+CFORNECE+' - c/Divergencia em valores'
				Anexo  :=''
				Copia  :=''

				ALERT(CASSUNTO+CCORPO)

				cRet:=U_EnvMyMail(De, cPara, Copia, Assunto, CCorpo, Anexo )

				If !Empty(cRet)
					Alert("Erro no Envio !!! " + cRet)
				Else
					Alert("Email Enviado com Sucesso !!!")
				Endif

				//LEMAILVLR:=.F.
			ENDIF


			////JULIO JACOVENKO, 27/01/2014
			////
			////se houver diferencas nas quantidades NF x PC
			////nao sera criada a prenota
			/////////////////////////////////////////////////
			IF LEMAILQTD  //SE HOUVE DIFERENCA COM QUANTIDADES

				cCorpo01:=''
				FOR X:=1 TO LEN(aEmailQtd)
					//cCorpo01+=aEmailQtd[x,1]+CHR(9)+aEmailQtd[x,2]+CHR(9)+aEmailQtd[x,3]+CHR(9)+STR(aEmailQtd[x,4])+CHR(9)+STR(aEmailQtd[x,5])+CHR(9)+STR(aEmailQtd[x,6])+CHR(9)+STR(aEmailQtd[x,7])+CHR(13)+CHR(10)
					//'NF.Fornec: '+aEmailQTD[x,1]+CHR(13)+CHR(10)+
					cCorpo01+='N.Pedido : '+aEmailQTD[x,2]+CHR(13)+CHR(10)+;
					'Cod.Prod : '+aEmailQTD[x,3]+CHR(13)+CHR(10)+'Vlr.NF  : '+STR(aEmailQTD[x,4])+CHR(13)+CHR(10)+;
					'Vlr.PC   : '+STR(aEmailQTD[x,5])+CHR(13)+CHR(10)+'Qtd.NF  :'+STR(aEmailQTD[x,6])+CHR(13)+CHR(10)+;
					'Qtd.PC   : '+STR(aEmailQTD[x,7])+CHR(13)+CHR(10)+CHR(13)+CHR(10)

				NEXT
				CCorpo  :='Fornecedor: '+CFORNECE+CHR(13)+CHR(10)
				CCorpo  +=CHR(13)+CHR(10)+' Segue diferencas por quantidade encontradas : '
				CCorpo  +=CHR(13)+CHR(10)+cCABECEM
				CCorpo  +=CHR(13)+CHR(10)+cCorpo01
				De     :=GETMV("IMD_DEXML") //'julio.cesar@imdepa.com.br'
				cPara  :=GETMV("IMD_PARXML") //'julio.cesar@imdepa.com.br;marcio.janson@imdepa.com.br;arlete@imdepa.com.br;suprimentosnac@imdepa.com.br'
				//cPara  :='julio.cesar@imdepa.com.br'   //;everton@imdepa.com.br'

				///separar por filial com CFILORIG
				if CFILORIG='05'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.cdp@imdepa.com.br'
				elseif CFILORIG='06'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.itajai@imdepa.com.br'
				elseif CFILORIG='09'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.spa@imdepa.com.br'
				elseif CFILORIG='13'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.ctba@imdepa.com.br'
				elseif CFILORIG='02'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.cba@imdepa.com.br'
				elseif CFILORIG='04'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.goi@imdepa.com.br'
				elseif CFILORIG='14'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.mg@imdepa.com.br'
				elseif CFILORIG='07'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.vit@imdepa.com.br'
				elseif CFILORIG='11'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.ma@imdepa.com.br'
				else
					cfilcdp:=''
				endif

				cPara:=cPara +';'+cfilcdp


				Assunto:=CASSUNTO+'Entrada NF '+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+' Filial: '+cfilorig+' Forn: '+CFORNECE+' - c/Divergencia em quantidade.'
				Anexo  :=''
				Copia  :=''

				ALERT(CASSUNTO+CCORPO)

				cRET:=U_EnvMyMail(De, cPara, Copia, Assunto, CCorpo, Anexo )

				If !Empty(cRet)
					Alert("Erro no Envio !!! " + cRet)
				Else
					Alert("Email Enviado com Sucesso !!!")
				Endif

				//LEMAILQTD:=.F.
			ENDIF



			IF LProdsne

				cCABECEM:='Relacao de Pedidos/Produtos na nota n„o encontrado!"
				cCorpo01:=''
				//FOR X:=1 TO LEN(aEmailQtd)
				cCorpo01:=CPRODSNE+CHR(13)+CHR(10)
				//NEXT
				CCorpo  :='Fornecedor: '+CFORNECE+CHR(13)+CHR(10)
				CCorpo  +=CHR(13)+CHR(10)+' Segue relacao de pedido/produto nao encontrados : '
				CCorpo  +=CHR(13)+CHR(10)+cCABECEM
				CCorpo  +=CHR(13)+CHR(10)+cCorpo01
				De     :=GETMV("IMD_DEXML") //'julio.cesar@imdepa.com.br'
				cPara  :=GETMV("IMD_PARXML") //'julio.cesar@imdepa.com.br;marcio.janson@imdepa.com.br;arlete@imdepa.com.br;suprimentosnac@imdepa.com.br'
				//cPara  :='julio.cesar@imdepa.com.br'   //;everton@imdepa.com.br'

				///separar por filial com CFILORIG

				if CFILORIG='05'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.cdp@imdepa.com.br'
				elseif CFILORIG='06'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.itajai@imdepa.com.br'
				elseif CFILORIG='09'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.spa@imdepa.com.br'
				elseif CFILORIG='13'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.ctba@imdepa.com.br'
				elseif CFILORIG='02'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.cba@imdepa.com.br'
				elseif CFILORIG='04'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.goi@imdepa.com.br'
				elseif CFILORIG='14'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.mg@imdepa.com.br'
				elseif CFILORIG='07'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.vit@imdepa.com.br'
				elseif CFILORIG='11'
					cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.ma@imdepa.com.br'
				else
					cfilcdp:=''
				endif

				cPara:=cPara+';'+cfilcdp


				Assunto:=CASSUNTO+'Entrada NF '+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+' Filial: '+cfilorig+' Forn: '+CFORNECE+' - c/Relacao de N.Pedidos nao encontrados.'
				Anexo  :=''
				Copia  :=''

				ALERT(CASSUNTO+CCORPO)

				cRET:=U_EnvMyMail(De, cPara, Copia, Assunto, CCorpo, Anexo )

				If !Empty(cRet)
					Alert("Erro no Envio !!! " + cRet)
				Else
					Alert("Email Enviado com Sucesso !!!")
				Endif
			ENDIF


			////////////////////////////////////////////////////////////



			TC8->(dbCloseArea())
			TC9->(dbCloseArea())


		Endif   //LMARCOU COMO VERDADEIRO .T.
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//| Teste de Inclusao                                            |
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		cx=1



		If Len(aItens) > 0
			Private lMsErroAuto := .f.
			Private lMsHelpAuto := .T.

			SB1->( dbSetOrder(1) )
			SA2->( dbSetOrder(1) )


			/* Alteracao da filial corrente. */
			cFilAtu := cFilAnt
			cFilAnt := cFilOrig



			nModulo := 4  //ESTOQUE


			////ATENCAO VER ISTO COM O DEP COMPRAS...
			////
			///JULIO JACOVENKO, em 19/03/2014
			///se houver inconsistencia quanto a valor ou quantidade
			///incluir como pre-nota ou nao?
			///se nao tera de importar novamente
			///ver com MARCIO BOROWSKI JANSON
			///QUANDO INCONSISTENCIA NAO INCLUIR PRE NOTA





			////JULIO JACOVENKO, em 27/12/2013
			////primeiro faz a inclus„o para aceitar o numero do pedido nas linhas
			////
			////


			//////FAZ INCLUSAO DA NOTA, SE NAO TIVER ERROS DE QTD, VLR, SLD


			IF LEMAILSLD .OR. LEMAILVLR .OR. LEMAILQTD .OR. LEMAILENC .OR. LPRODSNE
				ALERT('NOTA NAO GERADA...ERROS em Valores, Quantidade ou Saldos!!!')
				///JULIO JACOVENKO, em 06/02/2015
				///
				///aqui se tiver erros abre em modo de ediÁ„o

				IF LEMAILENC .OR. LPRODSNE
					//MSExecAuto({|x,y,z|Mata140(x,y,z,.T.)},aCabec,aItens,3) //INCLUIDO O 4 PARAMETRO COMO .T. PARA APRESENTAR
					//A TELA DE ENTRADA DE NOTAS ONDE PODE SER FEITA
					//ALTERACOES ANTES DE CONFIRMAR.

				ENDIF

			ELSE
				MSExecAuto({|x,y,z|Mata140(x,y,z)},aCabec,aItens,3)
			ENDIF





			/* RETORNO FILIAL CORRENTE */
			cFilAnt := cFilAtu

			//nfe\entrada

			_AAREA:=GETAREA()


			IF !LEMAILSLD .OR. !LEMAILVLR .OR. !LEMAILQTD .OR. LPRODSNE
				IF lMsErroAuto

					//\servidor\system\nfe\erro

					xFile := STRTRAN(cFile,"nfe"+cfilant+"\entrada", "nfe"+cfilant+"\erro\")

					COPY FILE &cFile TO &xFile

					//FErase(cFile)

					MSGALERT("ERRO NA GRAVA«√O DA PRENOTA!!! CONTINUE PARA VER O ERRO!")
					MostraErro()
				Else                               //estava com 9 zeros



					////JULIO JACOVENKO, em 27/12/2013
					////agora faz a alteraÁ„o para aceitar o numero do pedido nas linhas
					////
					_AAREA:=GETAREA()

					DBSELECTAREA("SD1")
					DBSETORDER(1)

					SET DELETED ON



					////JULIO JACOVENKO, em 15/04/2014
					////as linha abaixo sao necessarias pra forÁar
					////quantidade, valor unitario e total com os dados
					////do xml E NAO DO PC
					////

					IF !LMARCOU
						FOR XX:=1 TO LEN(AITENS)
							//IF DbSeek( ACABEC[1,2]+ACABEC[4,2]+ACABEC[5,2]+ACABEC[7,2]+ACABEC[8,2])
                            IF DbSeek( ACABEC[1,2]+ACABEC[4,2]+ACABEC[5,2]+ACABEC[7,2]+ACABEC[8,2]+AITENS[XX,2,2]+AITENS[XX,08,2] )


								if RECLOCK('SD1',.F.)
									SD1->D1_QUANT:=AITENS[XX,3,2]
									SD1->D1_VUNIT:=AITENS[XX,4,2]
									SD1->D1_TOTAL:=AITENS[XX,3,2] * AITENS[XX,4,2]
									MSUNLOCK()
								EndIf
							ELSE
								//
							ENDIF
						NEXT

					ELSE

						FOR XX:=1 TO LEN(AITENS)
							IF DbSeek( ACABEC[1,2]+ACABEC[4,2]+ACABEC[5,2]+ACABEC[7,2]+ACABEC[8,2]+AITENS[XX,2,2]+AITENS[XX,08,2] )


								if RECLOCK('SD1',.F.)
									SD1->D1_QUANT:=AITENS[XX,3,2]
									SD1->D1_VUNIT:=AITENS[XX,4,2]
									SD1->D1_TOTAL:=AITENS[XX,3,2] * AITENS[XX,4,2]
									MSUNLOCK()
								EndIf
							ELSE
								//
							ENDIF
						NEXT


					ENDIF


					DBSELECTAREA('SD1')
					DBGOTOP()


					///
					///JULIO JACOVENKO, em  06;02;2015
					///modificado para atender Shaffler e Tinkem
					///
					///---o texto abaixo poder· ser retirado
					///-----------------------------------------
					///-----------------------------------------
					///validar a questao do erro de pedido
					///abilitar a alteraÁ„o no memento da gravaÁ„o
					///da pre-nota
					///




					///JULIO JACOVENKO, em 15/04/2014
					///nao sera mais necessario, ja que serao
					///corrigidos os pedidos com erro
					///
					///

					/*
					IF LEN(_ITEMDEL)>0
					FOR XX:=1 TO LEN(_ITEMDELA)
					IF SD1->(!DbSeek( ACABEC[1,2]+ACABEC[4,2]+ACABEC[5,2]+ACABEC[7,2]+ACABEC[8,2]+_ITEMDELA[XX,2] ) 	)
					//AQUI DEVEMOS EXCLUIR A PRE
					//ALERT(ACABEC[1,2]+ACABEC[4,2]+ACABEC[5,2]+ACABEC[7,2]+ACABEC[8,2]+_ITEMDELA[XX,2])
					if SD1->(RECLOCK('SD1',.T.))
					//AADD(_ITEMDELA,{AITENS[NITEM,1,2],AITENS[NITEM,2,2],AITENS[NITEM,3,2],AITENS[NITEM,4,2],AITENS[NITEM,5,2],AITENS[NITEM,6,2],AITENS[NITEM,7,2],AITENS[NITEM,8,2],AITENS[NITEM,9,2]})
					//ALERT(_ITEMDELA[XX,2] )
					SD1->D1_FILIAL := ACABEC[1,2]
					SD1->D1_COD    :=_ITEMDELA[XX,2]
					SD1->D1_QUANT  :=_ITEMDELA[XX,3]
					SD1->D1_VUNIT  :=_ITEMDELA[XX,4]
					SD1->D1_TOTAL  :=_ITEMDELA[XX,5]
					SD1->D1_VALDESC:=_ITEMDELA[XX,6]
					SD1->D1_CLASFIS:=_ITEMDELA[XX,7]

					cITEM          := STRZERO( (NITEMTOT-LEN(_ITEMDELA))+XX,4,0)
					SD1->D1_ITEM   := CITEM

					SD1->D1_DOC    :=ACABEC[4,2]
					SD1->D1_SERIE  :=ACABEC[5,2]
					SD1->D1_FORNECE:=ACABEC[7,2]
					SD1->D1_LOJA   :=ACABEC[8,2]
					SD1->D1_UM     :='PC'
					SD1->D1_LOCAL  :='01'
					SD1->D1_TIPO   :=If(MV_PAR01==1,"N",If(MV_PAR01==2,'B','D'))
					SD1->D1_EMISSAO:=dDATA
					SD1->D1_DTDIGIT:=DATE()

					//ALERT( _ITEMDELA[XX,2] )
					SD1->(MSUNLOCK())
					END
					ENDIF
					NEXT
					ENDIF
					*/


				ENDIF  ///SE NAO HOUVER ERROS

				RESTAREA(_AAREA)

				///USER SEEK

				KXFILIAL  = CFILORIG
				XDOC     = Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)
				XSERIE   = PADL( alltrim(str(val(OIdent:_serie:TEXT))),3,'0')
				XFORNECE = If(MV_PAR01=1,SA2->A2_COD,SA1->A1_COD)
				XLOJA    = If(MV_PAR01=1,SA2->A2_LOJA,SA1->A1_LOJA)
				///
				///JULIO JACOVENKO, em 24/06/2015
				///tive de colocar o SEEK, pois no novo binario o MsExecAuto
				///nao estava ficando posicionado no SF1
				DbSelectArea('SF1')
				DbSetOrder(1)

				SF1->(DBSEEK(CFILORIG+XDOC+XSERIE+XFORNECE+XLOJA))

				////ESTOU POSICIONADO NO SF1
				If SF1->F1_DOC == Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)
					ConfirmSX8()
					////GRAVAR A CHAVE NFE
					///VAMOS COLOCAR A CHAVE NFE
					///DEPOIS DE TUDO
					///TEM DE SER AGORA, POIS QUANDO PRE NAO ACEITA
					///aadd(aCabec,{"F1_CHVNFE",Right(AllTrim(oNF:_InfNfe:_Id:Text),44),NIL,NIL})
					if RECLOCK('SF1',.F.)
						SF1->F1_CHVNFE:=Right(AllTrim(oNF:_InfNfe:_Id:Text),44)
						MsUnlock()
					EndIf


					///COMO FOI TUDO OK
					///COPIO PARA IMPORTADA E DELETO DA ENTRADA
					///

					xFile :=STRTRAN(cFile,"nfe"+cfilant+"\entrada\", "nfe"+cfilant+"\importada\")

					COPY FILE &cFile TO &xFile
					__CopyFile(cFile, xFile)

					FErase(cFile)



                    ///JULIO JACOVENKO, em 13/09/2016
                    ///
                    ///ajustar para quando for entrega RELAMPAGO, mostrar
                    ///mensagem...
                    ///

					//MSGALERT(Alltrim(aCabec[3,2])+' / '+Alltrim(aCabec[4,2])+" - PrÈ Nota Gerada Com Sucesso! - FIL: "+CFILORIG)


                    CTEXTO:="OPERA«√O REL¬MPAGO - ATENCAO "+CHAR(13)+CHR(10)
                    CTEXTO+=CTEXTO+"Sr. Faturista, informar ao recebimento que esta NF ser· despachada para Curitiba, n„o endereÁar fisicamente."+CHR(13)+CHR(10)
                    IF LSABO
                       MSGALERT(CTEXTO+Alltrim(aCabec[4,2])+' / '+Alltrim(aCabec[5,2])+" Forn: "+ALLTRIM(ACABEC[7,2])+" / "+ALLTRIM(ACABEC[8,2])+CCOMPLM+" - PrÈ Nota Gerada Com Sucesso! - FIL: "+CFILORIG)
                    ELSE
                        MSGALERT(Alltrim(aCabec[4,2])+' / '+Alltrim(aCabec[5,2])+" Forn: "+ALLTRIM(ACABEC[7,2])+" / "+ALLTRIM(ACABEC[8,2])+" - PrÈ Nota Gerada Com Sucesso! - FIL: "+CFILORIG)
                    ENDIF
					//JULIO, para gravar o usuario que gerou a nota
					//vamos ativar, pois ser· necess·rio....
					///
					/*
					If SF1->F1_PLUSER <> __cUserId
					If Reclock("SF1",.F.)
					SF1->F1_PLUSER := __cUserId
					EndIf
					EndIf
					*/

					/* Desabilitado pois a temos de ver quem na IMDEPA  que podera classificar notas
					//////////////////////////////////////////////////////////////////////////////////////////////////
					IF Msgyesno("Deseja Efetuar a ClassificaÁ„o da Nota " + Alltrim(aCabec[3,2])+' / '+Alltrim(aCabec[4,2]) + " Agora ?")
					_aArea := GetArea()
					//A103NFiscal("SF1",SF1->(Recno()),4,.f.,.f.)
					dbSelectArea("SF1")
					SET FILTER TO AllTrim(F1_DOC) = Alltrim(aCabec[3,2]) .AND. AllTrim(F1_SERIE) == aCabec[4,2]
					MATA103()
					dbSelectArea("SF1")
					SET FILTER TO
					RetArea(_aArea)
					Endif
					/////////////////////////////////////////////////////////////////////////////////////////////////
					*/

                    ////JULIO JACOVENKO	, em 13/09/2016
                    ///aviso ref. carga relampago...


					PswOrder(1)
					PswSeek(__cUserId,.T.)
					aInfo := PswRet(1)
					cAssunto := CASSUNTO+'GeraÁ„o da pre nota '+Alltrim(aCabec[3,2])+' Serie '+Alltrim(aCabec[4,2])
					cTexto   := 'A pre nota '+Alltrim(aCabec[3,2])+' Serie: '+Alltrim(aCabec[4,2]) +' do tipo '+Alltrim(aCabec[1,2]) + ' do fornecedor '+ Alltrim(aCabec[6,2])+' loja ' + Alltrim(aCabec[7,2]) + ' foi gerada com sucesso pelo usuario '+ aInfo[1,4] + ' favor classificar a pre nota em nota'
					cPara    := GETMV("IMD_PARXML") //'julio.cesar@imdepa.com.br;marcio.janson@imdepa.com.br;arlete@imdepa.com.br;suprimentosnac@imdepa.com.br'
					//cPara  :='julio.cesar@imdepa.com.br'  //;everton@imdepa.com.br'

					///separar por filial com CFILORIG
					if CFILORIG='05'
						cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.cdp@imdepa.com.br'
					elseif CFILORIG='06'
						cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.itajai@imdepa.com.br'
					elseif CFILORIG='09'
						cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.spa@imdepa.com.br'
					elseif CFILORIG='13'
						cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.ctba@imdepa.com.br'
					elseif CFILORIG='02'
						cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.cba@imdepa.com.br'
					elseif CFILORIG='04'
						cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.goi@imdepa.com.br'
					elseif CFILORIG='14'
						cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.mg@imdepa.com.br'
					elseif CFILORIG='07'
						cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.vit@imdepa.com.br'
					elseif CFILORIG='11'
						cfilcdp:=GETMV("IMD_CFILCD") //'faturamento.ma@imdepa.com.br'
					else
						cfilcdp:=''
					endif

					cPara:=cPara+';'+cfilcdp

					cCC      := ''
					cArquivo := ''

					//U_EnvMailto(cAssunto,cTexto,cPara,cCC,cArquivo) //para que seja enviado um arquivo em anexo o arquivo deve estar dentro da pasta protheus_data
					///

				Else
					MSGALERT(Alltrim(aCabec[3,2])+' / '+Alltrim(aCabec[4,2])+" - PrÈ Nota N„o Gerada - Nota com divergÍncias !")
				EndIf
			EndIf
		Endif

	Enddo

	PutMV("MV_PCNFE",lPcNfe)
Return NIL




Static Function C(nTam)
	Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.8
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
		nTam *= 1
	Else	// Resolucao 1024x768 e acima
		nTam *= 1.28
	EndIf

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥Tratamento para tema "Flat"≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	If "MP8" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf
Return Int(nTam)

Static Function ValProd()
	_DESCdigit=Alltrim(GetAdvFVal("SB1","B1_DESC",CFILORIG+cEdit1,1,""))
	_NCMdigit=GetAdvFVal("SB1","B1_POSIPI",CFILORIG+cEdit1,1,"")
Return 	ExistCpo("SB1")

Static Function Troca()
	Chkproc=.T.
	cProduto=cEdit1                                                      //JULIO JACOVENKO, em 03/01/2014
	If Empty(SB1->B1_POSIPI) .and. !Empty(cNCM) .and. cNCM != '00000000' //Ariovaldo alterar o ncm se houver discrepancia
		RecLock("SB1",.F.)
		Replace B1_POSIPI with cNCM
		MSUnLock()
	Endif
	_oDlg:End()
Return


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥Chk_File  ∫Autor  ≥ Julio Jacovenko   ∫ Data ≥ 27/12/13     ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Chamado pelo grupo de perguntas EESTR1			              ∫±±
±±∫          ≥Verifica se o arquivo em &cVar_MV (MV_PAR06..NN) existe.   ∫±±
±±∫          ≥Se n„o existir abre janela de busca e atribui valor a      ∫±±
±±∫          ≥variavel Retorna .T.										       ∫±±
±±∫          ≥Se usu·rio cancelar retorna .F.							       ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Parametros≥Texto da Janela		                                       ∫±±
±±∫          ≥Variavel entre aspas.                                       ∫±±
±±∫          ≥Ex.: Chk_File("Arquivo Destino","mv_par06")                 ∫±±
±±∫          ≥VerificaSeExiste? Logico - Verifica se arquivo existe ou    ∫±±
±±∫          ≥nao - Indicado para utilizar quando o arquivo eh novo.      ∫±±
±±∫          ≥Ex. Arqs. Saida.                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ IMDEPA ROLAMENTOS, vers„o propria                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

User Function Chk_F(cTxt, cVar_MV, lChkExiste)
	Local lExiste := File(&cVar_MV)
	Local cTipo := "Arquivos XML   (*.XML)  | *.XML | Todos os Arquivos (*.*)    | *.* "
	Local cArquivo := ""

	//Verifica se arquivo n„o existe
	If lExiste == .F. .or. !lChkExiste
		cArquivo := cGetFile( cTipo,OemToAnsi(cTxt))
		If !Empty(cArquivo)
			lExiste := .T.
			&cVar_Mv := cArquivo
		Endif
	Endif
	Return (lExiste .or. !lChkExiste)

	******************************************
Static Function MarcarTudo()
	DbSelectArea('TC9')
	dbGoTop()
	While !Eof()
		MsProcTxt('Aguarde...')
		RecLock('TC9',.F.)
		TC9->T9_OK := _cMarca
		MsUnlock()
		DbSkip()
	EndDo
	DbGoTop()
	DlgRefresh(oDlgPedidos)
	SysRefresh()
	Return(.T.)

	******************************************
Static Function DesmarcaTudo()
	DbSelectArea('TC9')
	dbGoTop()
	While !Eof()
		MsProcTxt('Aguarde...')
		RecLock('TC9',.F.)
		TC9->T9_OK := ThisMark()
		MsUnlock()
		DbSkip()
	EndDo
	DbGoTop()
	DlgRefresh(oDlgPedidos)
	SysRefresh()
	Return(.T.)



	////JULIO JACOVENKO, em 06/02/2014
	////ajustes por bug
	******************************************
Static Function Marcar()
	DbSelectArea('TC9')
	RecLock('TC9',.F.)
	If Empty(TC9->T9_OK)
		TC9->T9_OK := _cMarca
	Endif
	MsUnlock()
	SysRefresh()
	Return(.T.)

	******************************************************
Static FUNCTION Cria_TC9()

	If Select("TC9") <> 0
		TC9->(dbCloseArea())
	Endif
	If Select("TC8") <> 0
		TC8->(dbCloseArea())
	Endif


	////JULIO JACOVENKO, em 04/11/2014
	////
	////aqui, vamos criar dois campos novos:
	////T9_UNMOEDA - valor da mercadoria em moeda
	////             usado no pedido
	////T9_MOEDA   - moeda usada
	/////
	/////
	////T8_UNMOEDA - valor da mercadoria em moeda
	////             usado na nota
	////T8_MOEDA   - moeda usada
	////
	////nPreco := xMoeda( 48,07, SimbToMoeda( 'R$ '), 1, dDataBase )


	aFields   := {}
	AADD(aFields,{"T9_OK"     ,"C",02,0})
	AADD(aFields,{"T9_PEDIDO" ,"C",06,0})
	AADD(aFields,{"T9_ITEM"   ,"C",04,0})
	AADD(aFields,{"T9_PRODUTO","C",15,0})
	AADD(aFields,{"T9_DESC"   ,"C",40,0})
	AADD(aFields,{"T9_UM"     ,"C",02,0})
	AADD(aFields,{"T9_QTDE"   ,"N",6,0})
	AADD(aFields,{"T9_UNIT"   ,"N",12,2})
	AADD(aFields,{"T9_TOTAL"  ,"N",14,2})
	AADD(aFields,{"T9_EMISSAO","D",08,0})
	AADD(aFields,{"T9_ALMOX"  ,"C",02,0})
	AADD(aFields,{"T9_OBSERV" ,"C",30,0})
	AADD(aFields,{"T9_CCUSTO" ,"C",06,0})
	////JULIO JACOVENKO, em 19/03/2014
	////adicionado controle da saldo/classificados
	AADD(aFields,{"T9_QTDACL" ,"N",14,2})
	AADD(aFields,{"T9_QUJE"   ,"C",14,2})
	AADD(aFields,{"T9_ENCER"  ,"C",01,0})

	AADD(aFields,{"T9_UNMOEDA","N",12,2})
	AADD(aFields,{"T9_MOEDA"  ,"C",01,0})


	/////////////////////////////////////////////
	AADD(aFields,{"T9_REG"    ,"N",10,0})

	//cArq:=Criatrab(aFields,.T.)
	//DBUSEAREA(.t.,,cArq,"TC9")
	//U_MyFile( aStruFile, aStruIndex, cPath, cNameFile, cAliasFile, cDriver, lReplace )

	U_MyFile( aFields, , , , "TC9", , )

	aFields2   := {}
	AADD(aFields2,{"T8_NOTA"    ,"C",09,0})
	AADD(aFields2,{"T8_SERIE"   ,"C",03,0})
	AADD(aFields2,{"T8_PRODUTO" ,"C",15,0})
	AADD(aFields2,{"T8_DESC"    ,"C",40,0})
	AADD(aFields2,{"T8_UM"      ,"C",02,0})
	AADD(aFields2,{"T8_QTDE"    ,"N",6,0})
	AADD(aFields2,{"T8_UNIT"    ,"N",12,2})
	AADD(aFields2,{"T8_TOTAL"   ,"N",14,2})

	AADD(aFields2,{"T8_UNMOEDA","N",12,2})
	AADD(aFields2,{"T8_MOEDA","C",01,0})


	//cArq2:=Criatrab(aFields2,.T.)
	//DBUSEAREA(.t.,,cArq2,"TC8")
	//U_MyFile( aStruFile, aStruIndex, cPath, cNameFile, cAliasFile, cDriver, lReplace )
	U_MyFile( aFields2, , , , "TC8", , )

	Return


	********************************************
Static Function Monta_TC9()
	// Ir· efetuar a checagem de pedidos de compras
	// em aberto para este fornecedor e os itens desta nota fiscal a ser importa
	// ser· demonstrado ao usu·rio se o pedido de compra dever· ser associado
	// a entrada desta nota fiscal


	/////JULIO JACOVENKO, 10/04/2014
	/////TEREMOS DE RODAR ESTA QUERY PEDIDO E PRODUTO
	/////POIS TEMOS PRODUTOS E MUITO PEDIDOS E NAO PODEMOS MISTURAR...




	cQuery := ""
	cQuery += " SELECT  C7_NUM T9_PEDIDO,     "
	cQuery += " 		C7_ITEM T9_ITEM,    "
	cQuery += " 	    C7_PRODUTO T9_PRODUTO, "
	cQuery += " 		B1_DESC T9_DESC,    "
	cQuery += " 		B1_UM T9_UM,		"
	cQuery += " 		C7_QUANT T9_QTDE,   "
	cQuery += " 		C7_PRECO T9_UNIT,   "
	cQuery += " 		C7_TOTAL T9_TOTAL,   "
	cQuery += " 		C7_EMISSAO T9_EMISSAO,  "
	cQuery += " 		C7_LOCAL T9_ALMOX, "
	cQuery += " 		C7_OBS T9_OBSERV, "
	cQuery += " 		C7_CC T9_CCUSTO, "
	/////JULIO JACOVENKO, em 19/03/2014
	/////adicionado controle saldo/classificados
	cQuery +="          C7_QTDACLA T9_QTDACL, "
	cQuery +="          C7_QUJE T9_QUJE, "
	cQuery +="          C7_ENCER T9_ENCER, "

	////JULIO JACOVENKO, em 04/11/2014
	////tratamento para quando fornecedor usar moeda
	cQuery +="          C7_PRECO T9_UNMOEDA, "
	cQuery +="          C7_MOEDA T9_MOEDA, "

	/////////////////////////////////////////////
	cQuery +=" 		SC7.R_E_C_N_O_ T9_REG "

	cQuery += " FROM " + RetSqlName("SC7") + " SC7, " + RetSqlName("SB1") + " SB1 "
	cQuery += " WHERE C7_FILIAL = '" + xFilial("SC7") + "' "
	cQuery += " AND B1_FILIAL = '" + CFILORIG + "' "
	cQuery += " AND SC7.D_E_L_E_T_ = ' ' "
	cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
	///////////cQuery += " AND C7_QUANT > C7_QUJE  "
	//////TEM DE COLOCAR PARA NAO PEGA PRODUTO ENCERRADO
	//////
	///////////cQuery += " AND C7_RESIDUO = ''  "
	//cQuery += " AND C7_RESIDUO = ''  "

	//////////	cQuery += " AND C7_TPOP <> 'P'  "
	//////////  cQuery += " AND C7_CONAPRO <> 'B'  "
	//////////  cQuery += " AND C7_ENCER = '' "
	/////////	cQuery += " AND C7_CONTRA = '' "
	/////////	cQuery += " AND C7_MEDICAO = '' "
	cQuery += " AND C7_PRODUTO = B1_COD "
	cQuery += " AND C7_FORNECE = '" + SA2->A2_COD + "' "
	cQuery += " AND C7_LOJA = '" + CLOJAFOR + "' "



	IF ALLTRIM(CPEDIDO)<>''   ///SE  HAVER PEDIDO
		///CONCATENA C7_NUM,C7_PRODUTO+7 ESPACOS
		cQuery += " AND C7_NUM||C7_PRODUTO||'       ' IN" + FormatIn(cPeds, "/")
	ENDIF

	//cQuery += " AND C7_PRODUTO IN" + FormatIn( cProds, "/")
	If MV_PAR01 <> 1  ///SER FOR DIFERENTE DE 'N' NORMAL, NAO PEGA NADA DO SC7
		cQuery += " AND 1 > 1 "
	Endif

	cQuery += " ORDER BY C7_NUM, C7_ITEM, C7_PRODUTO "
	cQuery := ChangeQuery(cQuery)

	MEMOWRIT( "C:\SQLSIGA\PEGASC7.SQL", cQuery )

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CAD",.T.,.T.)
	TcSetField("CAD","T9_EMISSAO","D",8,0)

	Dbselectarea("CAD")


	///JULIO JACOVENKO, 10/04/2014
	///aqui a cada select vamos alimentar um array?



	While CAD->(!EOF())
		RecLock("TC9",.T.)
		For _nX := 1 To Len(aFields)

			If !(aFields[_nX,1] $ 'T9_OK')
				If aFields[_nX,2] = 'C'
					_cX := 'TC9->'+aFields[_nX,1]+' := Alltrim(CAD->'+aFields[_nX,1]+')'
				Else
					_cX := 'TC9->'+aFields[_nX,1]+' := CAD->'+aFields[_nX,1]
				Endif
				_cX := &_cX
			Endif
		Next

		//////JULIO JACOVENKO, em 04/11/20104
		dDataMoeda:=CAD->T9_EMISSAO   ///data emissao da nota

		TINKEM:=.F.
		SHAFFLER:=.F.
		//SHEFFLER
		//57000036001407
		CGCSHF:="56993157000110#57000036001407#5700003600140X#57000036001407#57000036001407#5700003600140X" //"56993157000110#57000036001407#5700003600140X"
		CGCTIN:="56990880000145#56990880000811#56990880000730#56990880001206#56990880001206#"

		IF CCGC $ CGCTIN
			TINKEM   := .T.
		ELSEIF CCGC $ CGCSHF
			SHAFFLER := .T.
		ENDIF



		//////vamos usar esta regra para pegar a ultima moeda valida
		//---PEGA A PRIMEIRA DATA DISPONIVEL
		//---COMPARA COM A DATA DA EMISSAO DA NOTA
		//---E NA TINKEM DATA DE EMISAO -1
		//SELECT * FROM SM2010
		//WHERE M2_MOEDA7<>0
		//AND M2_DATA<='20150128'
		//ORDER BY R_E_C_N_O_ DESC




		if TINKEM
			///se Tinkem pega o dia anterior
			dDataMoeda=CAD->T9_EMISSAO - 1
			CQUERY:=''
			CQUERY+="SELECT * FROM SM2010 SM2 "
			CQUERY+="WHERE M2_MOEDA2<>0 "
			CQUERY+="AND M2_DATA<='"+DTOS(CAD->T9_EMISSAO-1)+"' "
			CQUERY+="ORDER BY R_E_C_N_O_ DESC"
			MEMOWRIT("C:\SQLSIGA\_FIL11XY.TXT", cQUERY)
			cQuery := ChangeQuery(cQuery)
			TCQUERY cQuery NEW ALIAS "_FIL11XY"
			DBSELECTAREA('_FIL11XY')
			DBGOTOP()
			dDataMoeda:= STOD(_FIL11XY->M2_DATA)
			DBCloseArea('_FIL11XY')
		endif

		IF SHAFFLER
			///AQUI BUSCA A MOEDA NO DIA DO PEDIDO
			///NO CASO A MOEDA DOIS QUE HE DOLAR
			///
			CQUERY:=''
			CQUERY+="SELECT * FROM SM2010 SM2 "
			CQUERY+="WHERE M2_MOEDA2<>0 "
			CQUERY+="AND M2_DATA<='"+DTOS(CAD->T9_EMISSAO)+"' "
			CQUERY+="ORDER BY R_E_C_N_O_ DESC"
			MEMOWRIT("C:\SQLSIGA\_FIL11XY.TXT", cQUERY)
			cQuery := ChangeQuery(cQuery)
			TCQUERY cQuery NEW ALIAS "_FIL11XY"
			DBSELECTAREA('_FIL11XY')
			DBGOTOP()
			dDataMoeda:= STOD(_FIL11XY->M2_DATA)
			DBCloseArea('_FIL11XY')
		ENDIF



		//nMoedaB1:=Posicione("SB1",1,CFILORIG+aPedIte[nI,1],"B1_MCUSTD")
		cMoeda    :=Posicione("SB1",1,CFILORIG+TC9->T9_PRODUTO,"B1_MCUSTD")


		//////JULIO JACOVENKO, em 06/02/2015
		//////
		//////Pedido pega a moeda dolar padrao (2)
		//////

		//if SHAFFLER .AND. cMoeda='2'
		//cMoeda:='7'  ///moeda da schaffler seria a 7
		//endif



		///////////////////////////
		nPrCmoeda := xMoeda( CAD->T9_UNIT , SimbToMoeda( 'R$ '), VAL(cMoeda), dDataMoeda )    //moeda 2 he dolar



		TC9->T9_UNMOEDA := nPrCMoeda
		TC9->T9_MOEDA   := cMoeda

		///JULIO
		//TC9->T9_UNIT    := nPrCmoeda
		//TC9->T9_TOTAL   := TC9->T9_QTDE * nPrCmoeda


		TC9->T9_OK := _cMarca //ThisMark()
		MsUnLock()

		DbSelectArea('CAD')
		CAD->(dBSkip())
	EndDo

	Dbselectarea("CAD")
	DbCloseArea()
	Dbselectarea("TC9")
	DbGoTop()

	_cIndex:=Criatrab(Nil,.F.)
	_cChave:="T9_PEDIDO"
	Indregua("TC9",_cIndex,_cChave,,,"Ordenando registros selecionados...")
	DbSetIndex(_cIndex+ordbagext())
	SysRefresh()
Return


Static Function GetArq(cFile)
	cFile:= cGetFile( "Arquivo NFe (*.xml) | *.xml", "Selecione o Arquivo de Nota Fiscal XML",,cStartPath,.F., )
Return cFile


StatiC Function Fecha()
	Close(_oPT00005)
Return





Static Function AchaFile(cCodBar)
	Local aCompl := {}
	Local cCaminho := cStartPath //Caminho
	Local lOk := .f.
	Local oNf
	Local oNfe

	If Empty(cCodBar)
		Return .t.
	Endif

	/*AAdd(aCompl,'_v1.10-procNFe.xml')
	AAdd(aCompl,'-nfe.xml')
	AAdd(aCompl,'.xml')
	AAdd(aCompl,'-procnfe.xml')

	For nC := 1 To Len(aCompl)
	If File(cCaminho+AllTrim(cCodBar)+aCompl[nC])
	cCodBar := AllTrim(cCaminho+AllTrim(cCodBar)+aCompl[nC])
	lOk := .t.
	Exit
	Endif
	Next
	*/

	aFiles := Directory(cCaminho+"\*.XML", "D")

	For nArq := 1 To Len(aFiles)
		cFile := AllTrim(cCaminho+aFiles[nArq,1])

		nHdl    := fOpen(cFile,0)
		nTamFile := fSeek(nHdl,0,2)
		fSeek(nHdl,0,0)
		cBuffer  := Space(nTamFile)                // Variavel para criacao da linha do registro para leitura
		nBtLidos := fRead(nHdl,@cBuffer,nTamFile)  // Leitura  do arquivo XML
		fClose(nHdl)
		If AT(AllTrim(cCodBar),AllTrim(cBuffer)) > 0
			cCodBar := cFile
			lOk := .t.
			Exit
		Endif
	Next

	If !lOk
		Alert("Nenhum Arquivo Encontrado, Por Favor Selecione a OpÁ„o Arquivo e FaÁa a Busca na Arvore de DiretÛrios!")
	Endif


Return lOk



/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥GetIdEnt  ≥ Autor ≥Eduardo Riera          ≥ Data ≥18.06.2007≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Obtem o codigo da entidade apos enviar o post para o Totvs  ≥±±
±±≥          ≥Service                                                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥ExpC1: Codigo da entidade no Totvs Services                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥Nenhum                                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥   DATA   ≥ Programador   ≥Manutencao efetuada                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥          ≥               ≥                                            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
STATIC Function WSAT01GetIdEnt()

	Local aArea  := GetArea()
	Local cIdEnt := ""
	Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local oWs
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥Obtem o codigo da entidade                                              ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	oWS := WsSPEDAdm():New()
	oWS:cUSERTOKEN := "TOTVS"

	oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
	oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM
	oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
	oWS:oWSEMPRESA:cFANTASIA   := SM0->M0_NOME
	oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
	oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
	oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
	oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
	oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
	oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
	oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
	oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
	oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
	oWS:oWSEMPRESA:cCEP_CP     := Nil
	oWS:oWSEMPRESA:cCP         := Nil
	oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
	oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
	oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
	oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
	oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
	oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
	oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cINDSITESP  := ""
	oWS:oWSEMPRESA:cID_MATRIZ  := ""
	oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
	oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
	If oWs:ADMEMPRESAS()
		cIdEnt  := oWs:cADMEMPRESASRESULT
	Else
		Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3)
	EndIf

	RestArea(aArea)
Return(cIdEnt)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥COMMI010  ∫Autor  ≥Microsiga           ∫ Data ≥  01/30/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function ConsCTEChave(cChaveCTE,cIdEnt,lWeb)

	Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local cMensagem:= ""
	Local oWS
	Local lErro := .F.


	If ValType(lWeb) == 'U'
		lWeb := .F.
	EndIf

	lweb:=.F.


	oWs:= WsNFESBra():New()
	oWs:cUserToken   := "TOTVS"
	oWs:cID_ENT    := cIdEnt
	ows:cCHVNFE		 := cChaveCTE
	oWs:_URL         := AllTrim(cURL)+"/NFESBRA.apw"

	If oWs:ConsultaChaveNFE()
		cMensagem := ""
		If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cVERSAO)
			cMensagem += "Vers„o da Mensagem"+": "+oWs:oWSCONSULTACHAVENFERESULT:cVERSAO+CRLF
		EndIf
		cMensagem += "Ambiente"+": "+IIf(oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1,"ProduÁ„o","HomologaÁ„o")+CRLF //"ProduÁ„o"###"HomologaÁ„o"
		cMensagem += "Cod.Ret.CTE"+": "+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF
		cMensagem += "Msg.Ret.CTE"+": "+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF
		If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
			cMensagem += "Protocolo"+": "+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF
		EndIf

		//QUANDO NAO ESTIVER OK NAO IMPORTA, CODIGO DIFERENTE DE 100

		If oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE $ "100"
			lErro := .T.
		EndIf

		If !lWeb
			Aviso("Imdepa diz Consulta NF",cMensagem,{"Ok"},3)
		Else
			Return({lErro,cMensagem})
		EndIf
	Else
		Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3)
	EndIf
Return(lErro)

///JULIO JACOVENKO, em 21/05/2014
///
///SOBRE A FUNCAO FORMATIN
/*
Pode usar o comando abaixo.

cQuery+= "AND B1_TIPO IN " + FormatIn(MV_PAR07,";") + cEOL

O parametro MV_PAR07 pode estar assim:
1201;1202;1203;1204

E o FormatIn j· transforma em
('1201','1202','1203','1204')

*/


/*
FUNCAO PARA LER SA5 COM N Produto Imdepa x 1 SAP do fornecedor
JULIO JACOVEKO, em 10/08/2016
*/

Static Function fLeSa5(cCodiFor,cOrigem,cPedido,cFil,cFornece,cLoja,CCGC)
Local cQuery:=""
Local cCodRet:=""
//cCgc='57000036001407' -- QUANDO SHAFFLER



cQuery+="SELECT * FROM SA5010 "
cQuery+="WHERE A5_PRODUTO IN ( SELECT C7_PRODUTO FROM SC7010 SC7 WHERE C7_NUM='"+cPedido+"' "
cQuery+="AND C7_FILIAL='"+cFil+"') "
cQuery+="AND D_E_L_E_T_ <> '*' "
cQuery+="AND A5_CODPRF='"+cCodiFor+"' "
cQuery+="AND A5_FORNECE='"+cFornece+"' "
IF CCGC<>'57000036001407'  //TRATAMENTO SHAFFLER, PRODUTO LUK SOMENTE LOJA 05
   cQuery+="AND A5_LOJA='"+cLoja+"' "
ENDIF
//CQUERY+="AND A5_IMDORIG = '"+CORIGEM+"' "


MEMOWRIT("C:\SQLSIGA\FLESA5.TXT", cQUERY)
cQuery := ChangeQuery(cQuery)
TCQUERY cQuery NEW ALIAS "LESA5"
DBSELECTAREA('LESA5')
DBGOTOP()
                  nCnt:=0
                  DO WHILE !EOF()
                      //ALERT('ENCONTROU UM PRODUTO')
                      cCodRet:=LESA5->A5_PRODUTO
                      nCnt+=1
                      LESA5->(DBSKIP())
                  ENDDO
                  dbCloseArea("LESA5")

If nCnt>1    ///temos problemas: temos mais itens no pedido com este SAP
   MsgAlert("temos problemas: temos mais itens com este SAP")
   cCodRet:="xxxxxxxx"
Endif

Return cCodRet

