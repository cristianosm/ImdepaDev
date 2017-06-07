#Include 'protheus.ch'

*******************************************************************************
User Function M030Exc()//| APoS CONFIRMAR A EXCLUSAO Este P.E. sera executado apos o usuario confirmar a exclusao; Depois da execucao do mesmo, sera feita a exclusao efetiva dos dados do Cliente no arquivo.
*******************************************************************************

	Reclock("SA1",.F.)
	A1_IMDREP := "9"
	MsUnlock()

	//|  CHAMADO: 9637 -> CRM - Atualizacao dos clientes por Vendedores
	U_IATUADL( "SA1", SA1->A1_COD, SA1->A1_LOJA , "D" )

	Return(.T.)
*******************************************************************************
User Function M030Inc() //| APoS INCLUSao DO CLIENTE Este Ponto de Entrada e chamado apos a inclusao dos dados do cliente no Arquivo.
*******************************************************************************
	/*
	Reclock("SA1",.f.)
	A1_IMDREP := "1"
	MsUnlock()
	*/

	//|  CHAMADO: 9637 -> CRM - Atualizacao dos clientes por Vendedores
	U_IATUADL( "SA1", SA1->A1_COD, SA1->A1_LOJA )

	Return(.T.)
*******************************************************************************
User Function M030Alt() //| VALIDA ALTERACAO DOS DADOS DE CLIENTES
*******************************************************************************

	Reclock("SA1",.f.)
	A1_IMDREP := "2"
	MsUnlock()

	Return(.T.)
*******************************************************************************
User Function M030PALT() //| Este ponto de entrada realiza validacao de usuario, apos a confirmacao da alteracao do cliente.
*******************************************************************************
	Local lret := .T.

	//|  CHAMADO: 9637 -> CRM - Atualizacao dos clientes por Vendedores
	U_IATUADL( "SA1", SA1->A1_COD, SA1->A1_LOJA )

	Return lret

*******************************************************************************
User Function ma030rot() //Após a criação do aRotina, para adicionar novas rotinas ao cadastro de cliente
*******************************************************************************

	Local aRetorno := {}

	AAdd( aRetorno, { "Imp Arq Vendedores", "U_ImptGerVenC", 2, 0 })

Return( aRetorno )

/*******************************************************************************
User Function M030del(uRet)
*******************************************************************************
//n := 1

U_IATUADL( "SA1", SA1->A1_COD, SA1->A1_LOJA , "D" )

Return(uRet := .T.)

*/
/*
*******************************************************************************
User Function maltcli()
*******************************************************************************
n := 1
Return(.t.)
*******************************************************************************
User Function ma030tok()
*******************************************************************************
n := 1
Return(.t.)
*******************************************************************************
User Function ma030mem()
*******************************************************************************
n := 1
Return(.t.)

*/