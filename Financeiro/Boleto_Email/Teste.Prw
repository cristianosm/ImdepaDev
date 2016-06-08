#INCLUDE "Protheus.ch"
#include "Rwmake.ch"
#include "TbiConn.ch"

*******************************************************************************
User Function MyMata261()
*******************************************************************************

	Local cProd		:= "PA001"
	Local cUM			:= ""
	Local cLocal		:= ""
	Local cDoc			:= ""
	Local cLote		:= "8888888888"
	Local dDatVal	:= ""
	Local nQuant		:= 0
	Local lOk			:= .T.
	Local aItem		:= {}
	Local nOpcAuto	:= 3 // Indica qual tipo de a‹o ser‡ tomada (Inclus‹o/Exclus‹o)

	PRIVATE lMsHelpAuto := .T.
	PRIVATE lMsErroAuto := .F.

	//ò€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€À
	//| Abertura do ambiente                                         |
	//Ë€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€ô

	PREPARE ENVIRONMENT EMPRESA "YY" FILIAL "01" MODULO "EST"

	DbSelectArea("SB1")
	DbSetOrder(1)

	If !SB1->(MsSeek(xFilial("SB1")+cProd))

		lOk := .F.

		ConOut(OemToAnsi("Cadastrar produto: " + cProd))

	Else

		cProd 		:= B1_COD
		cDescri	:= B1_DESC
		cUM 			:= B1_UM
		cLocal		:= B1_LOCPAD

	EndIf

	DbSelectArea("SD5")
	DbSetOrder(1)

	If !SD5->(MsSeek(xFilial("SD5")+ "      " + cProd ))

		lOk := .F.
		ConOut(OemToAnsi("Cadastrar lote: " + cLote ))

	Else
		cLote 	:= D5_LOTECTL
		dDataVl	:= D5_DTVALID
		nQuant	:= D5_QUANT

	EndIf

	If lOk

		cDoc		:= GetSxENum("SD3","D3_DOC",1)
		ConOut(Repl("-",80))
		ConOut(PadC("Teste de Transf. Mod2",80))
		ConOut("Inicio: "+Time())

	//ò€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€À	
	//| Teste de Inclusao                                            |	
	//Ë€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€ô   		

		Begin Transaction   		//Cabecalho a Incluir

			aAuto := {}
			aadd(aAuto,{cDoc,dDataBase})  //Cabecalho		//Itens a Incluir
			aadd(aItem,cProd)  						//D3_COD
			aadd(aItem,cDescri)    				//D3_DESCRI
			aadd(aItem,cUM)  						//D3_UM
			aadd(aItem,cLocal)      			//D3_LOCAL
			aadd(aItem,"")								//D3_LOCALIZ
			aadd(aItem,cProd)  						//D3_COD
			aadd(aItem,cDescri)  				  //D3_DESCRI
			aadd(aItem,cUM)  						//D3_UM
			aadd(aItem,"02")      				//D3_LOCAL
			aadd(aItem,"")								//D3_LOCALIZ
			aadd(aItem,"")        			  //D3_NUMSERI
			aadd(aItem,cLote)						//D3_LOTECTL
			aadd(aItem,"")        		 		//D3_NUMLOTE
			aadd(aItem,dDataVl)						//D3_DTVALID
			aadd(aItem,0)								//D3_POTENCI
			aadd(aItem,nQuant) 						//D3_QUANT
			aadd(aItem,0)								//D3_QTSEGUM
			aadd(aItem,"")   						//D3_ESTORNO
			aadd(aItem,"")         				//D3_NUMSEQ
			aadd(aItem,cLote)						//D3_LOTECTL
			aadd(aItem,dDataVl)						//D3_DTVALID
			aadd(aItem,"")								//D3_ITEMGRD
			aadd(aAuto,aItem)

			MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)

			If !lMsErroAuto

				ConOut("Incluido com sucesso! " + cDoc)

			Else

				ConOut("Erro na inclusao!")

				MostraErro()

			EndIf

			ConOut("Fim  : "+Time())

		End Transaction

	EndIf

	RESET ENVIRONMENT

Return Nil


//Exemplo Estorno: 
*******************************************************************************
User Function Tmata261()
*******************************************************************************
	Local aAUTO := {}
	Local cDoc	:= "000113001"
	Local cProd	:= "TESTE          "

	Private lMsErroAuto := .F.

	RpcSetEnv("99","01",,,,,,,,,)

	DbSelectArea("SD3")
	DbSetOrder(2)
	DbSeek(xFilial("SD3")+cDoc+cProd)

	aAuto := {}

	MSExecAuto({|x,y| mata261(x,y)},aAuto,6)

	If !lMsErroAuto	
	
		Alert("Incluido com sucesso! ")

		Alert(CVALTOCHAR(LMSERROAUTO))

	Else

		Alert("Erro na inclusao!")
	
		MostraErro()
	
	
	EndIf


Return
