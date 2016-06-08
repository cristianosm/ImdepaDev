#include "TOTVS.CH"


**********************************************************************************
// Classe que Obtem Dados Referente ao Cliente
**********************************************************************************
Class oCliente

	Data _cCodigo
	Data _cLoja
	Data _cUF

	Method New( cCodigo , cLoja ) Constructor

EndClass
**********************************************************************************
Method New( cCodigo , cLoja ) Class oCliente

	::_cCodigo 	:= cCodigo
	::_cLoja		:= cLoja
	::_cUf			:= POSICIONE("SA1",1,xFilial("SA1")+cCodigo+cLoja,"A1_EST")

Return





**********************************************************************************
// Classe que Obtem Dados Referente ao ICMS
**********************************************************************************
Class oIcms

	Data _nValor
	Data _nAliq
	Data _nBase

	Data _oCliente
	Data _oProduto

	Method  New(cCliente , cLoja , cProduto)

EndClass
**********************************************************************************
Method New ( cCliente , cLoja , cProduto ) Class oIcms


	::_oCliente 	:= oCliente():New(cCliente, cLoja)
	::_oProduto	:= oProduto():New(cProduto, 1 )

	::_nValor		:= 1
	::_nAliq		:= 1
	::_nBase		:= 1


	//::_nValor 	:= MafisRet()

Return


