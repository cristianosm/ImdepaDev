#include 'protheus.ch'
#include 'parmtype.ch'

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNCAO : TK273PT2    | AUTOR : Cristiano Machado     | DATA : 22/09/2016  **
**---------------------------------------------------------------------------**
** DESCRICAO: PE na Conversao de prospec em cliente                          **
**                                                                           **
**                                                                           **
**---------------------------------------------------------------------------**
** USO : Especifico para o cliente                                           **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
** ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                         **
**---------------------------------------------------------------------------**
** PROGRAMADOR        |   DATA   | MOTIVO DA ALTERACAO                       **
**---------------------------------------------------------------------------**
**                    |          |                                           **
**                    |          |                                           **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User function TK273PT2()
*******************************************************************************

//|  CHAMADO: 9637 -> CRM - Atualizacao dos clientes por Vendedores
U_IATUADL( "SA1", SA1->A1_COD, SA1->A1_LOJA )

Return()