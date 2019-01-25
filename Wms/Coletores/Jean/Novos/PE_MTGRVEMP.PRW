#INCLUDE "PROTHEUS.CH"

/* 
Jean Rehermann - Solutio IT - 25/10/2018 - Ponto de entrada após gravação do empenho

DESCRIÇÃO: Ponto de Entrada que tem o objetivo de manipular as informações que serão gravadas 
para cada item de empenho gerado, possibilitando alterar um produto empenhado, 
o local padrão do produto, ou ainda, selecionar um outro lote/sublote para o produto,
de acordo com a necessidade.

LOCALIZAÇÃO: Function GravaEmp - Função principal responsável pelo tratamento na geração de empenhos, 
no final da Função, após ter executado todos os processos envolvidos na gravação dos empenhos. 

UTILIZAÇÃO: Será usado para modificar o endereço dos empenhos no SDC para OP, endereço deve ser PRD, além
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
	Local _lRadioF  := ( SuperGetMV('MV_RADIOF', .F., 'N') == 'S' ) // Jean Rehermann - Solutio IT - 26/12/2018 - Não executar quando RF OFF
	
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
					SBF->BF_EMPENHO := SBF->BF_EMPENHO - nQuant // O empenho sai do endereço pois já foi baixado pela movimentação WMS
				MsUnLock()
			EndIf
			
			dbSeek( xFilial("SBF") + cLocal + "PRD            " + cProd )
			
			If Found()
				RecLock("SBF",.F.)
					SBF->BF_EMPENHO := SBF->BF_EMPENHO + nQuant // O empenho vai para o endereço de produção pois o saldo já foi movimentado pra lá
				MsUnLock()
			EndIf
	
			dbSelectArea("SDC")
			dbSetOrder(2)
			dbSeek( xFilial("SDC") + cProd + cLocal + cOP )
			
			If Found() .And. SDC->DC_LOCALIZ == cEnder
				RecLock("SDC",.F.)
					SDC->DC_LOCALIZ := "PRD" // O endereço será o mesmo onde está empenhado no SBF para baixar no apontamento da OP
				MsUnLock()
			EndIf
		
		EndIf
    
	EndIf
	
	RestArea( aArea )

Return