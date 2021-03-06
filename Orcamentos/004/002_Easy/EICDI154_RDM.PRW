#Include "Rwmake.ch"
#Include "Average.ch"

#DEFINE  NFE_UNICA     3
#DEFINE  CUSTO_REAL    4
#DEFINE  NF_TRANS      6

//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa
//|Funcao....: EICDI154_RDM
//|Autor.....: Armando M. Urzum - armando@urzum.com.br
//|Data......: 30 de Junho de 2009 - 08:00
//|Uso.......: SIGAEIC
//|Versao....: Protheus - 8.11
//|Descricao.: Pontos de Entrada na gera��o da NF de Importa��o
//|Observa��o:
//+-----------------------------------------------------------------------------------//
*----------------------------------------------*
User Function EICDI154()
*----------------------------------------------*
	Local aArea    := GetArea()
	Local aAreaSD1 := SD1->(GetArea())

	Private lFlagCont 	:= .F.
	Private cLancPad  	:= " "
	Private cNovoFor  	:= ""
	Private cNovoLoj  	:= ""
	Private cAnteFor  	:= ""
	Private cAnteLoj  	:= ""
	Private cNF       	:= ""
	Private cSerie    	:= ""
	Public _nTotFob   	:= 0
	Public xdDt1      	:= SW6->W6_DT_EMB
	Public xdDt2      	:= SW6->W6_DT_EMB
	Public xUsaIPICus

	_nTotFob := SW6->W6_FOB_TOT

	If Type("ParamIXB") # "C"
		Return .F.
	EndIf

	//Alert("ParamIxb: " + ParamIxb)
//+------------------------------------------------------------------------------------//
//|VerIfica pelo parametro padrao do DESEMBARA�O F12 se fara a contabiliza��o
//|Precionando F12 na tela do Desembara�o poderam selecionar os parametros
//+------------------------------------------------------------------------------------//
	MV_PAR03 := Posicione("SX1",1,"EICFI4"+"02","X1_PRESEL")  // Mostra   Lan�amento Contabil?
	MV_PAR04 := Posicione("SX1",1,"EICFI4"+"03","X1_PRESEL")  // Aglutina Lan�amento Contabil?

	Do Case


	//+-----------------------------------------------------------------------------------//
	//|Parametro..: "ANTES_ESTORNO_NOTA"
	//|Descricao..: Verifica as contabiliza��es no estorno e se h� NF Transferencia
	//+-----------------------------------------------------------------------------------//
	Case ParamIxb == "ESTORNO"
		
		
		If nTipoNF <> CUSTO_REAL
			If !Empty(SW6->W6_NFTRAN)
				Aviso("Aten�ao","Processo Possui NF de Transferencia, Estorne-a primeiro",{"OK"} )
				Return .F.
			Endif
		EndIf
	
	Case ParamIxb == "ANTES_ESTORNO_NOTA"
		
		//| Estorno Lan�amento CE Mercante 
		U_IEasyLanc(SW6->W6_HAWB, "E")
		
		
		

	//+-----------------------------------------------------------------------------------//
	//|Parametro..: "GRAVA_SWN_EI2"
	//|Descricao..: Corrige os Valores Calculados na SWN pelo Sistema.... Cristiano Machado
	//+-----------------------------------------------------------------------------------//

	Case ParamIxb == "FINAL_GRAVA_NF" //"GRAVA_SWN_EI2"
	
		//| Lan�amento CE Mercante 
		U_IEasyLanc(SW6->W6_HAWB, "I")

		If ExistBlock( "CalcNFImp" ) .And. SW6->W6_TIPOEMB $ "1"
			U_CalcNFImp(SW6->W6_HAWB , "SWN")
		EndIf

	//+-----------------------------------------------------------------------------------//
	//|Parametro..: "MBROWSE"
	//|Descricao..: Inclui bot�o para nota de transferencia
	//+-----------------------------------------------------------------------------------//
	Case ParamIxb == "MBROWSE"

		aAdd(aRotina,{"NF.Transferencia","DI154NFE",0,2})


	//+-----------------------------------------------------------------------------------//
	//|Parametro..: "INICIA_VARIAVEIS"
	//|Descricao..: Verifica se tipo de nota � de transfencia
	//+-----------------------------------------------------------------------------------//
	Case ParamIxb == "INICIA_VARIAVEIS"

		If nTipoNF == NF_TRANS
			lLoop := .T.
		//	U_UZGerNFT()
		Else
			SWN->(dbSetOrder(3))
			If SWN->(dbSeek(xFilial("SWN")+SW6->W6_HAWB+"3"))
				If !Empty(SWN->WN_NFTRAN)
					lLoop := .T.
					MsgStop("Processo possue nota de Transferencia. Favor utilizar a op��o de Nf Transferencia para a Visualiza��o.","NF Transferencia")
				EndIf
			EndIf
			SWN->(dbSetOrder(1))
		Endif

	//+-----------------------------------------------------------------------------------//
	//|Parametro..: "TELA_TOTAIS"
	//|Descricao..: Monta tela com Totais para Nota de transferencia.
	//+-----------------------------------------------------------------------------------//
	Case ParamIxb == "TELA_TOTAIS"
		lRet := .F.
		If SW6->W6_TIPOEMB $ "1"
			
			If ExistBlock( "CalcNFImp" )
				
				Processa({ || lRet := U_CalcNFImp("")  })
				//Alert("Processou -> lRet:" + cValToChar(lRet))
				If !lRet
					Processa({ || U_UzTelTot()  })
				EndIf
			Else
				Processa({ || U_UzTelTot()  })
			EndIf
			
			lSair := .T.
		ElseIf SW6->W6_TIPOEMB $ "23"
		
			Processa({ || U_UzTelTot()  })
		
		EndIf

	//+-----------------------------------------------------------------------------------//
	//|Parametro..: "GRAVACAO_SD1"
	//|Descricao..: Adiciona campos na gera��o da NF
	//+-----------------------------------------------------------------------------------//
	Case ParamIxb == "GRAVACAO_SD1"

/*
		aAdd(aItem,{"D1_II"    ,Work1->WKIIVAL   ,".T."})
		aAdd(aItem,{"D1_CIF"   ,Work1->WKCIF     ,".T."})
		aAdd(aItem,{"D1_CIF"   ,Work1->(WKCIF-WKFRETE-WKSEGURO) ,".T."})
//		aAdd(aItem,{"D1_NUMDI" ,SW6->W6_DI_NUM   ,".T."})
*/

		aAdd(aItem,{"D1_NUMDI" ,IF(!EMPTY(SD1->D1_CONHEC),SW6->W6_DI_NUM,"")  ,".T."})
		
	//+-----------------------------------------------------------------------------------//
	//|Parametro..: "GRAVACAO_SF1"
	//|Descricao..: Adiciona campos na gera��o da NF
	//+-----------------------------------------------------------------------------------//		

	Case ParamIxb == "GRAVACAO_SF1"
   
		aAdd(aCab, {"F1_ESPECI1",SW6->W6_ESPECIE, nil})
		aAdd(aCab, {"F1_VOLUME1",SW6->W6_QTDVOL , nil})
		aAdd(aCab, {"F1_PLIQUI" ,SW6->W6_PESOLIQ, nil})
		aAdd(aCab, {"F1_PBRUTO" ,SW6->W6_PESO_BR, nil})

	EndCase

	RestArea(aAreaSD1)
	RestArea(aArea)

Return()

//+------------------------------------------------------------------------------------//
//|Fim do programa EICDI154_RDM.PRW
//+------------------------------------------------------------------------------------//
