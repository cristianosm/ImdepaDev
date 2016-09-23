#Include 'protheus.ch'



*******************************************************************************
User Function M030Exc()//| AP�S CONFIRMAR A EXCLUS�O Este P.E. ser� executado ap�s o usu�rio confirmar a exclus�o; Depois da execu��o do mesmo, ser� feita a exclus�o efetiva dos dados do Cliente no arquivo.
*******************************************************************************


Reclock("SA1",.F.)
A1_IMDREP := "9"
MsUnlock()

//|  CHAMADO: 9637 -> CRM - Atualiza��o dos clientes por Vendedores
U_IATUADL( "SA1", SA1->A1_COD, SA1->A1_LOJA , "D" )


Return(.T.)
*******************************************************************************
User Function M030Inc() //| AP�S INCLUS�O DO CLIENTE Este Ponto de Entrada � chamado ap�s a inclus�o dos dados do cliente no Arquivo.
*******************************************************************************
/*
Reclock("SA1",.f.)
A1_IMDREP := "1"
MsUnlock()
*/

//|  CHAMADO: 9637 -> CRM - Atualiza��o dos clientes por Vendedores
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
User Function M030PALT() //| Este ponto de entrada realiza valida��o de usu�rio, ap�s a confirma��o da altera��o do cliente.
*******************************************************************************

//|  CHAMADO: 9637 -> CRM - Atualiza��o dos clientes por Vendedores
U_IATUADL( "SA1", SA1->A1_COD, SA1->A1_LOJA )

Return(.T.)

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
*******************************************************************************
User Function ma030rot()
*******************************************************************************
n := 1
Return(.t.)

*/