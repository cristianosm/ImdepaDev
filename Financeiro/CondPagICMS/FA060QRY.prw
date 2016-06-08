
/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : FA060QRY    | AUTOR : Cristiano Machado  | DATA : 11/29/2010   **
**---------------------------------------------------------------------------**
** DESCRIÇÃO: Ponto de Entrada para Adicionar alguma Condicao no Filtro      **
**          : de montagem do bordero de pagamentos.                          **
**---------------------------------------------------------------------------**
** USO      : Especifico para o cliente IMDEPA                               **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
**            ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.              **
**---------------------------------------------------------------------------**
**   PROGRAMADOR   |   DATA   |            MOTIVO DA ALTERACAO               **
**---------------------------------------------------------------------------**
**                 |          |                                              **
**                 |          |                                              **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User Function FA060QRY()
*******************************************************************************

cCondicao	:=	 " E1_FILIAL = '  ' "

If Type('_nTxBanc') == 'U'
	Public _nTxBanc		:= 0
	Public _nContLan 	:= 0
Else
	_nTxBanc	:= 0
	_nContLan 	:= 0
EndIF


If cPort060 == "001" .And. SA6->A6_AGENCIA == "34150" .And. SA6->A6_NUMCON == "10387X    " //| Banco do Braisl

  	If IW_MSGBOX("Deseja Obter Apenas os Titulos que j· Possuem Boletos Emitidos ?","Atencao","YESNO")

		cCondicao += " AND E1_HIST Like('BOLFAT%') "

	Else
		cCondicao += " AND E1_HIST Not Like('BOLFAT%') "

	EndIf

	lRegra := .T.

EndIf

//| DATA: 22/12/2011   ANALISTA: Cristiano Machado   CHAMADO: AAZU4Q - SERASA PEFIN   SOLICITANTE: Juliano SF
If _cSituacao == "H"

	cCondicao += " AND ( E1_TIPO = 'NF ' AND E1_CLIENTE||E1_LOJA IN (SELECT A1_COD||A1_LOJA FROM SA1010 WHERE A1_TPROTES = 'S' AND D_E_L_E_T_ = ' ' ) ) " //| Serasa

Else

	cCondicao += " AND ( E1_CLIENTE||E1_LOJA IN (SELECT A1_COD||A1_LOJA FROM SA1010 WHERE A1_TPROTES = 'C'  AND D_E_L_E_T_ = ' ' )) AND E1_CREDICM <> 'S' " //| Cartorio

EndIf

//| DATA: 06/08/2015   ANALISTA: Cristiano Machado   CHAMADO: XXXXX - PALHATIVO: CONDICAO QUE UTILIZA E4_CREDICM NA PARCELA 1 NAO ESTA LEVANDO CORRETAMENTE A INFORMACAO PARA O TITULO...POR ISSO ELE ACABA INDO PARA O BANCO INCORRETAMENTE...E1_CREDICM = SIM.      SOLICITANTE: DANIELE FINANCEIRO

cCondicao += " AND  NOT EXISTS( SELECT F2.F2_FILIAL, F2.F2_SERIE, F2.F2_EMISSAO "
cCondicao += "                      FROM SF2010 F2, SE4010 E4  "
cCondicao += "                      WHERE F2.F2_FILIAL = E1_FILORIG AND F2.F2_SERIE = E1_PREFIXO AND F2.F2_DOC = E1_NUM AND E1_PARCELA = '1' AND F2.F2_COND = E4.E4_CODIGO "
cCondicao += "                      AND E4.E4_CREDICM = 'S' AND F2.D_E_L_E_T_ = ' ' AND E4.D_E_L_E_T_ = ' ' ) "

Return(cCondicao)
