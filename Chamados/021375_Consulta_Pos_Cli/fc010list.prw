#include 'protheus.ch'
#include 'parmtype.ch'

///| Chamado: 21375  Data: 22/05/18 Analista: Cristiano Machado
///| Atualiza todas as informaçòes estatisticos dos clientes (Maior Compra, Titulos em Aberto, Saldo em Pedidos e etc... )

*******************************************************************************
User function FC010LIST()
*******************************************************************************
	Local bRotina := {||  U_PvSldFin(SA1->A1_COD, SA1->A1_LOJA) } 
	Local aCols := paramixb

	//If Iw_MsgBox("Deseja atualizar os Acumulos do Clientes ? ",SA1->A1_NOME, "YESNO")
	
		Processa( bRotina , "Atualizando Dados do Cliente.. ", "Aguarde..." )

	//EndIf

Return aCols