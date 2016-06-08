#include "totvs.ch"


//| Classe Verifica Saldo em Pedido de Determinado Cliente e Corrige se Necessario...
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CLPVSLFI  ºAutor  ³Cristiano Machado   º Data ³  05/17/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica Saldo em Pedido de Determinado Cliente e Corrige   º±±
±±º          ³se Necessario...                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Class PvSldFin

	//| Atributos...
	Data cCliente		/// Codigo do Cliente...
	Data cLoja  		/// Codigo da Loja...
	Data cDataInicio	/// Data de inicio para filtro na query...
	Data nSldPvB		/// Salva o Saldo de Pedidos Bloqueados...
	Data nSldPvL		/// Salva o Saldo de Pedidos Liberados no Comercial...
	Data nSldPvF		/// Salva o Saldo de Pedidos Liberados no Financeiro...
	Data lQuery			///| Mostra Query na Tela ?


	//| Metodos...
	Method Novo( cCliente , cLoja ) Constructor  /// Cria Classe... tem que passar Cod Cliente e Loja
   Method Cliente( cCliente , cLoja ) //| Troca Cliente...
   Method PedidoB() 	/// Verifica Pedidos Bloqueados....
	Method PedidoL() 	/// Verifica Pedidos Liberados Comercial...
	Method PedidoF() 	/// Verifica Pedidos Liberados Financeiro
	Method AtuCliente()	/// Atualiza Cadastro do Cliente com Valores Obtidos conforme os pedidos...
	Method RefazCLI()	/// Executa Refaz Saldos Historicos Cliente...

EndClass


*******************************************************************
 /// Construtor de Classe... tem que passar Cod Cliente e Loja
*******************************************************************

	Method Novo(_cCliente,_cLoja) Class PvSldFin

		::cCliente 	:= _cCliente
		::cLoja 		:= _cLoja
		::cDataInicio	:= DtOs(dDataBase - 540) // 540 = 1 ano e 6 meses
		::nSldPvB		:= 0
		::nSldPvL		:= 0
		::nSldPvF		:= 0
		::lQuery		:= .F.

	Return
*******************************************************************
 /// Construtor de Classe... tem que passar Cod Cliente e Loja
*******************************************************************

	Method Cliente(_cCliente,_cLoja) Class PvSldFin

		::Novo(_cCliente,_cLoja)

	Return

*******************************************************************
 	/// Verifica Pedidos Nao Liberados....
*******************************************************************

	Method PedidoB() Class PvSldFin

	cSql := ""
	cSql += "select  sum( ( sc6.c6_qtdven - sc6.c6_qtdent ) * sc6.c6_prcacre ) c6_total "

	cSql += "from sc5010 sc5, sc6010 sc6 "

	cSql += "where sc5.c5_filial  = sc6.c6_filial "
	cSql += "and   sc5.c5_num     = sc6.c6_num "
	cSql += "and   sc5.c5_cliente = sc6.c6_cli "
	cSql += "and   sc5.c5_lojacli = sc6.c6_loja "
	cSql += "and   sc5.d_e_l_e_t_ = sc6.d_e_l_e_t_ "

	cSql += "and   sc5.c5_liberok = ' ' "
	cSql += "and   sc5.c5_client  = '"+::cCliente+"' "
	cSql += "and   sc5.c5_lojacli = '"+::cLoja+"' "
	cSql += "and   sc5.c5_emissao > '"+::cDataInicio+"' "

	cSql += "and   sc6.c6_nota    = '      ' "
	cSql += "and   sc6.d_e_l_e_t_ = ' ' "

	U_ExecMySql(cSql,"SQL","Q", ::lQuery)

	If ( SQL->C6_TOTAL  > 0 )
		::nSldPvB := SQL->C6_TOTAL
	Else
		::nSldPvB := 0
	EndIf

	Return

*******************************************************************
 	/// Verifica Pedidos Liberados Comercial...e Bloqueados no Credito
*******************************************************************

	Method PedidoL() Class PvSldFin

	cSql := ""
	cSql += "select sum(sc9.c9_qtdlib * sc9.c9_prcven) as c9_total "

	cSql += "from sc9010 sc9 "

	cSql += "where sc9.d_e_l_e_t_ = ' ' "
	cSql += "and   sc9.c9_nfiscal = '      ' "
	cSql += "and   sc9.c9_datalib > '"+::cDataInicio+"' "
	cSql += "and   sc9.c9_cliente = '"+::cCliente+"' "
	cSql += "and   sc9.c9_loja    = '"+::cLoja+"' "
	cSql += "and   sc9.c9_blcred  > '  ' "
	cSql += "and   sc9.c9_blcred  < '10' "

	U_ExecMySql(cSql,"SQL","Q",::lQuery)

	If ( SQL->C9_TOTAL  > 0 )
		::nSldPvL := SQL->C9_TOTAL
	Else
		::nSldPvL := 0
	EndIf

	Return

*******************************************************************
	/// Verifica Pedidos Liberados no Credito
*******************************************************************

	Method PedidoF() Class PvSldFin

 	cSql := ""
	cSql += "select sum(sc9.c9_qtdlib * sc9.c9_prcven) as c9_total "

	cSql += "from sc9010 sc9 "

	cSql += "where sc9.d_e_l_e_t_ = ' ' "
	cSql += "and   sc9.c9_nfiscal = '      ' "
	cSql += "and   sc9.c9_datalib > '"+::cDataInicio+"' "
	cSql += "and   sc9.c9_cliente = '"+::cCliente+"' "
	cSql += "and   sc9.c9_loja    = '"+::cLoja+"' "
	cSql += "and   sc9.c9_blcred  = '  ' "

	U_ExecMySql(cSql,"SQL","Q",::lQuery)

	If ( SQL->C9_TOTAL  > 0 )
		::nSldPvF := SQL->C9_TOTAL
	Else
		::nSldPvF := 0
	EndIf

	Return

*******************************************************************
	/// Atualiza Cadastro do Cliente com Valores Obtidos...
*******************************************************************

	Method AtuCliente() Class PvSldFin

	::PedidoB()
	::PedidoL()
	::PedidoF()

 	cSql := ""
	cSql += "update sa1010 "
	cSql += "set a1_salped   = "+cValtoChar( ::nSldPvB )+" " // Saldo em Pedidos nao Liberados
	cSql += "   ,a1_salpedb  = "+cValtoChar( ::nSldPvL )+" " // Saldo em Pedidos Liberados Comercial
	cSql += "   ,a1_salpedl  = "+cValtoChar( ::nSldPvF )+" " // Saldo em Pedidos Liberados Credito
	cSql += "where a1_filial 	= '  ' "
	cSql += "and a1_cod 		= '"+::cCliente+"' "
	cSql += "and a1_loja 		= '"+::cLoja+"' "
	cSql += "and d_e_l_e_t_ 	= ' ' "

	U_ExecMySql(cSql,"","E",::lQuery)

	Return

*******************************************************************
	/// Executa Refaz Saldos Historicos Cliente...
*******************************************************************

	Method RefazCLI() Class PvSldFin

	Private lDireto := .T.
	
	DbSelectArea("SA1")
	DbSeek(xFilial("SA1")+::cCliente,.F. ) 

	// Ajusta os Parametros...
	Pergunte("AFI410",.F.)

	Mv_Par01 := 2 			//|Refaz Dados de ? [ 1-Ambos, 2-Clientes, 3-Fornecedor ]
	Mv_Par02 := 1 			//|Recalcular Dados Historicos ? [ 1-Sim, 2-Nao ]
	Mv_Par03 := ::cCliente 	//|Do Cliente ?
	Mv_Par04 := ::cCliente 	//|Ate Cliente ?
	Mv_Par05 := Replicate(' ',6) 	//|Do Fornecedor ?
	Mv_Par06 := Replicate('Z',6) 	//|Ate Fornecedor ?

	Fa410Processa(lDireto)
	//Fina410(lDireto) //|

	Return()
