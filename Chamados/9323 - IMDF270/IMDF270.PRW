
#include "topconn.ch"
#include "rwmake.ch"
#include 'tbiconn.ch'
#Include 'Totvs.ch'

/*
Programa IMDF270
Objetivo : Gerar estorno de comissoes quando os titulos a receber estiverem vencidos a n dias atraves
do Schedule.
Data
Elaborado Por: Jaime de Souza

Melhoria: fazer a rotina rodar como um job
Programador: Expedito Mendonca Junior
--------
06/06/06 Marcio, Correcao pois nao estava retirando a comissao para titulo parcialmente baixado devido ao filtro
E1_BAIXA == CTOD(" / / "), modificado para : E1_SALDO > 0
--------
*/
*******************************************************************************
User Function IMDF270()
	*******************************************************************************

	Local nQtdProc
	Local	cEmp
	Private	nI
	Private	aFiliais := {}
	Private lViaWorkFlow

	IF Type("dDatabase") == "U" // Se rodado via workflow a vari vel dDatabase estara disponivel somente apos o Prepare Environment
		lViaWorkFlow := .T.
	ELSE
		lViaWorkFlow := .F.
	ENDIF

	cEmp := "01" // Codigo da Empresa

	ConOut("IMDF270 - Inicio dos Processamentos" )

	Prepare Environment Empresa cEmp Filial cEmp

	aFiliais := FWAllFilial() // Retorna as filiais para o grupo de empresas, empresa e unidade de neg?cio informada.

	For nI := 1 to Len(aFiliais)

		cFilAnt := aFiliais[nI]

		RpcSetType( 3 )

		lRpcSet := RpcSetEnv("01",cFilAnt,Nil,Nil,"FIN","IMDF270", {"SX6","SE1","SE3","SD2"} )

		ConOut("IMDF270 - Processando empresa/filial "+cEmp+"/"+aFiliais[nI] )

		nQtdProc := AtuaCom()

		ConOut('IMDF270 - ' + alltrim(str(nQtdProc))+" registros processados na empresa/filial "+cEmp+"/"+aFiliais[nI]+" - Data: "+dtoc(date())+" Hora: "+time())

	Next

	Reset Environment

	ConOut("IMDF270 - Fim dos Processamentos" )

	Return NIL
	*******************************************************************************
Static Function atuacom()
	*******************************************************************************

	// Quantidade de dias de atraso do titulo a receber do cliente para que o vendedor seja descontado de sua comissao.
	Local cumdias := GETMV("IM_DIASINA")
	// Qtd de dias de atraso do titulo a receber para que o vendedor seja descontado de sua comissao, quando a condicao de pagto. utilizada for Vendor.
	Local cdiasvend := GETMV("IM_DINAVEN")
	Local aAreaSE1 := SE1->(Getarea())
	Local nProxRec, nQtdProc := 0
	Local aVendedor := {}
	Local cVendedor
	Local nVlrComis

	AADD(aVendedor,{"SE1->E1_VEND1","SE1->E1_VALCOM1","D2_COMIS1"})
	AADD(aVendedor,{"SE1->E1_VEND2","SE1->E1_VALCOM2","D2_COMIS2"})
	AADD(aVendedor,{"SE1->E1_VEND3","SE1->E1_VALCOM3","D2_COMIS3"})
	AADD(aVendedor,{"SE1->E1_VEND4","SE1->E1_VALCOM4","D2_COMIS4"})
	AADD(aVendedor,{"SE1->E1_VEND5","SE1->E1_VALCOM5","D2_COMIS5"})

	//cQuery := "SELECT R_E_C_N_O_ FROM SE1010 WHERE TO_DATE('20101130','YYYYMMDD') - TO_DATE( E1_VENCREA,'YYYYMMDD') >= 30 AND E1_SALDO > 0 AND E1_FLAGCOM = ' ' AND D_E_L_E_T_ <> '*' AND E1_NUM = '014216' AND E1_FILIAL = ' ' "
	cQuery := "SELECT R_E_C_N_O_ FROM " + RetSqlName("SE1") + " WHERE E1_FILIAL = '"+ xFilial("SE1") + "' AND E1_FILORIG = '" + cFilAnt +"' AND TO_DATE('" + DTOS(DDATABASE) + "','YYYYMMDD') - TO_DATE( E1_VENCREA,'YYYYMMDD') >= " + ALLTRIM(STR(MAX(Val(cdiasvend),Val(cumdias)))) + " AND E1_SALDO > 0 AND E1_FLAGCOM = ' ' AND E1_TIPO = 'NF' AND D_E_L_E_T_ = ' '"
	//MEMOWRIT("\WORKFLOW\IMDF270-COMIS_SE1.TXT" , cQuery)
	CONOUT("IMDF270: " + cQuery)

	TCQUERY cQuery NEW ALIAS "COMIS_SE1"

	DBSELECTAREA("SE1") //;dbOrderNickName('E1_FLAGCOM')	//Flag de COMISSAO ordem J

	DO WHILE COMIS_SE1->(!EOF())
		SE1->(DBGOTO(COMIS_SE1->R_E_C_N_O_))
		//CONOUT('IMDF270 - verificando registro '+ STRZERO(recno()) + " "+ IIF( (E1_VENDORR <> "S" .AND. (DDATABASE - E1_VENCREA) >= Val(cumdias) .AND. E1_SALDO > 0),'.T.', '.F.') )

		IF E1_VENDORR <> "S"
			IF (DDATABASE - E1_VENCREA) >= Val(cumdias)// .AND. E1_SALDO > 0
				//Atualiza o arquivo SE3 E SE1
				FOR x:=1 TO LEN(aVendedor)
					cVendedor := &(aVendedor[x][1])//SE1->E1_VEND1
					nVlrComis := &(aVendedor[x][2])//SE1->E1_VALCOMx onde x = 1 / 2 / 3 / 4 / 5
					cCpoD2_comis := aVendedor[x][3]
					F_ATUCOMIS(cVendedor,nVlrComis,cCpoD2_comis)
				NEXT x
				RecLock("SE1",.F.)
				E1_FLAGCOM := "S"
				MSUNLOCK()
			ENDIF
		ELSEIF E1_VENDORR == "S"
			IF (DDATABASE - E1_VENCREA) >= Val(cdiasvend) //.AND. E1_SALDO > 0
				//Atualiza o arquivo SE3 E SE1
				FOR x:=1 TO LEN(aVendedor)
					cVendedor := &(aVendedor[x][1])//SE1->E1_VEND1
					nVlrComis := &(aVendedor[x][2])//SE1->E1_VALCOMx onde x = 1 / 2 / 3 / 4 / 5
					cCpoD2_comis := aVendedor[x][3]
					F_ATUCOMIS(cVendedor,nVlrComis,cCpoD2_comis)
				NEXT x
				RecLock("SE1",.F.)
				E1_FLAGCOM := "S"
				MSUNLOCK()
			ENDIF
		ENDIF
		COMIS_SE1->(DBSKIP())
	ENDDO

	COMIS_SE1->(DBCloseArea())

	Restarea(aAreaSE1)

	Return nQtdProc
	*******************************************************************************
Static Function F_ATUCOMIS(cVendedor,nVlrComis,cCpoD2_comis)
	*******************************************************************************

	Local ncomis,cnum, nvalorbruto

	IF !EMPTY(cVendedor)//(SE1->E1_VEND1) //&aVendedor[x][1].

		nTxBrutParaLiq := TxBrutParaLiq(SE1->E1_FILORIG,SE1->E1_NUM,SE1->E1_SERIE,SE1->E1_CLIENTE,SE1->E1_LOJA)

		nBase	:= SE1->E1_SALDO

		nBase	:= nBase * nTxBrutParaLiq
		nPorc := PercSE3(SE1->E1_FILORIG,SE1->E1_NUM,SE1->E1_SERIE,SE1->E1_CLIENTE,SE1->E1_LOJA,cCpoD2_comis) //nPorc := nVlrComis / (SE1->E1_VALOR * nTxBrutParaLiq) * 100 //	nPorc := (nVlrComis / SE1->E1_VALOR)*100

		ncomis := (nBase * nPorc) /100

		DBSELECTAREA("SE3")
		RecLock("SE3",.T.)
		SE3->E3_FILIAL := Xfilial("SE3")

		SE3->E3_BASE := nBase
		SE3->E3_PORC := nPorc
		SE3->E3_COMIS := ncomis *(-1)

		SE3->E3_VEND := cVendedor
		SE3->E3_NUM := SE1->E1_NUM
		SE3->E3_EMISSAO := DDATABASE
		SE3->E3_SERIE := SE1->E1_SERIE
		SE3->E3_CODCLI := SE1->E1_CLIENTE
		SE3->E3_LOJA := SE1->E1_LOJA
		// SE3->E3_DATA
		SE3->E3_PREFIXO := SE1->E1_PREFIXO
		SE3->E3_PARCELA := SE1->E1_PARCELA
		SE3->E3_TIPO := SE1->E1_TIPO
		SE3->E3_BAIEMI := "E"
		SE3->E3_PEDIDO := SE1->E1_PEDIDO
		SE3->E3_VENCTO := DDATABASE//SE1->E1_VENCTO
		SE3->E3_SEQ := "02"
		SE3->E3_ORIGPRG	:= "IMDF270" + "(" + IIF(lViaWorkFlow,'SCHEDULE', Funname()) + ")"
		MSUNLOCK()
	EndIF

	Return Nil
	*******************************************************************************
Static Function TxBrutParaLiq(f2filial,cnum,cserie,ccliente,cloja)
	*******************************************************************************

	Local nTxBrutParaLiq := 0

	cQuery := "select nvl(f2_valmerc /f2_valbrut,0) TxbrutParaliq from "+ RetSqlName("SF2") +" where f2_filial = '" + f2filial + "' and f2_doc = '" + cnum + "' and f2_serie = '" + cserie + "' and f2_cliente = '" + ccliente + "' and f2_loja = '" + cloja + "' and d_e_l_e_t_ = ' '"
	TCQUERY cQuery NEW ALIAS "TX"

	TCSetField( "TX", "TxbrutParaliq", 'N',10 , 6 )

	nTxBrutParaLiq := TX->TxbrutParaliq

	TX->(DbCloseArea())

	Return nTxBrutParaLiq
	*******************************************************************************
Static Function PercSE3(f2filial,cnum,cserie,ccliente,cloja,ccampod2)
	*******************************************************************************

	Local nPercSE3 := 0
	// ccampod2 --> campo do percentual de comiss o do sd2 ex: d2_comis1, d2_comis2 etc
	cQuery := "select sum(d2_total* " + ccampod2 + " /100)/ sum(d2_total) *100 PercSE3 from "+ RetSqlName("SD2") +" where d2_filial = '" + f2filial + "' and d2_doc = '" + cnum + "' and d2_serie = '" + cserie + "' and d2_cliente = '" + ccliente + "' and d2_loja = '" + cloja + "' and d_e_l_e_t_ = ' '"

	TCQUERY cQuery NEW ALIAS "PERC"

	TCSetField( "PERC", "PercSE3", 'N',10 , 6 )

	nPercSE3	:= PERC->PercSE3

	PERC->(DbCloseArea())

Return nPercSE3