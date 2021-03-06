#INCLUDE "PROTHEUS.CH"

/* 
Jean Rehermann - Solutio IT - 25/10/2018 - Ponto de entrada ap�s grava��o do empenho

DESCRI��O: Ponto de Entrada que tem o objetivo de manipular as informa��es que ser�o gravadas 
para cada item de empenho gerado, possibilitando alterar um produto empenhado, 
o local padr�o do produto, ou ainda, selecionar um outro lote/sublote para o produto,
de acordo com a necessidade.

LOCALIZA��O: Function GravaEmp - Fun��o principal respons�vel pelo tratamento na gera��o de empenhos, 
no final da Fun��o, ap�s ter executado todos os processos envolvidos na grava��o dos empenhos. 

UTILIZA��O: Ser� usado para modificar o endere�o dos empenhos no SDC para OP, endere�o deve ser PRD, al�m
de ajustar o saldo empenhado na SBF.
*/

User Function MTGRVEMP()
	
	Local aParam := PARAMIXB
	Local cLocal := ""
	Local cEnder := ""
	Local cOrig  := ""
	Local aItens := ""
	Local cProd  := ""
	Local cOP    := ""
	Local nQuant := 0
	Local aArea  := GetArea()
	Local _lRadioF  := ( SuperGetMV('MV_RADIOF', .F., 'N') == 'S' ) // Jean Rehermann - Solutio IT - 26/12/2018 - N�o executar quando RF OFF
	
	If _lRadioF
	
		If ValType( aParam ) == "A" .And. Len( aParam ) > 0
			cLocal := aParam[ 02 ]
			cEnder := aParam[ 07 ]
			cOrig  := aParam[ 13 ]
			aItens := aParam[ 15 ]
			cProd  := aParam[ 01 ]
			nQuant := aParam[ 03 ]
			cOP    := aParam[ 09 ]
		EndIf
		
		If !Empty( cEnder ) .And. Empty( aItens ) .And. cOrig == "SC2"
			
			dbSelectArea("SBF")
			dbSetOrder(1)
			dbSeek( xFilial("SBF") + cLocal + cEnder + cProd )
			
			If Found()
				RecLock("SBF",.F.)
					SBF->BF_EMPENHO := SBF->BF_EMPENHO - nQuant // O empenho sai do endere�o pois j� foi baixado pela movimenta��o WMS
				MsUnLock()
			EndIf
			
			dbSeek( xFilial("SBF") + cLocal + "PRD            " + cProd )
			
			If Found()
				RecLock("SBF",.F.)
					SBF->BF_EMPENHO := SBF->BF_EMPENHO + nQuant // O empenho vai para o endere�o de produ��o pois o saldo j� foi movimentado pra l�
				MsUnLock()
			EndIf
	
			dbSelectArea("SDC")
			dbSetOrder(2)
			dbSeek( xFilial("SDC") + cProd + cLocal + cOP )
			
			If Found() .And. SDC->DC_LOCALIZ == cEnder
				RecLock("SDC",.F.)
					SDC->DC_LOCALIZ := "PRD" // O endere�o ser� o mesmo onde est� empenhado no SBF para baixar no apontamento da OP
				MsUnLock()
			EndIf
		
		EndIf
    
	EndIf
	
	RestArea( aArea )

Return