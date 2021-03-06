#include "rwmake.ch"
#include "topconn.ch"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LPITEMCC  �Autor  �Elisabeth Gianuca   � Data �25/11/2003   ���
�������������������������������������������������������������������������͹��
���Desc.     �Lancamento Padrao                                           ���
���          �Item centro de custo                                        ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
*****************************************************************************
User Function LPITEMCC()
*****************************************************************************
Local cQuery
Local aArea    := GetArea()
Local cAlias   := Alias()
Local cprefixo:=SE1->E1_PREFIXO // '' BETH 29/05/07

If Empty(cprefixo)
	If Select("__SE1")<>0
		cprefixo=__SE1->E1_PREFIXO
	Endif
Endif


	// monta a query
	cQuery := " SELECT SUBSTR(SX5.X5_DESCRI,1,2) CODFIL FROM "+retSqlname('SX5')+" SX5 "
	cQuery += " WHERE X5_FILIAL = '  '"
	cQuery += " AND SX5.X5_TABELA = 'ZM' AND SUBSTR(SX5.X5_CHAVE,1,3) = '"+cprefixo+"'"
	cQuery += " AND SX5.D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYX5",.F.,.T.)

	cItemcc := substr(SM0->M0_CODIGO, 2,1)+QRYX5->CODFIL

	QRYX5->(DBCloseArea())

	RestArea(aArea)
	DbselectArea(cAlias)


Return(cItemcc)


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LPITEMDD  �Autor  �Elisabeth Gianuca   � Data �25/11/2003   ���
���Manutencao�LPITEMDD  �Autor  �Elisabeth Gianuca   � Data �25/11/2003   ���
�������������������������������������������������������������������������͹��
���Desc.     �Lancamento Padrao                                           ���
���          �Item centro de custo debito na baixa do CP                  ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function LPITEMDD()
Local aArea    := GetArea()
Local cprefixo := SE5->E5_PREFIXO // '' BETH 29/05/07
Local cQuery


If cprefixo != "COM"

		// monta a query
		cQuery := "SELECT SUBSTR(SX5.X5_DESCRI,1,2) CODFIL FROM "+retSqlname('SX5')+" SX5 "
		cQuery += " WHERE X5_FILIAL = '  '"
		cQuery += " AND SX5.X5_TABELA = 'ZM' AND SUBSTR(SX5.X5_CHAVE,1,3) = '"+cprefixo+"'"
		cQuery += " AND SX5.D_E_L_E_T_ = ' ' "
		//cQuery := ChangeQuery(cQuery)

		// Executa a query
		TCQUERY cQuery NEW ALIAS _TMP

		cItemdd :=  substr(SM0->M0_CODIGO, 2,1)+_TMP->CODFIL
		dbSelectArea('_TMP')
		dbCloseArea()

Else
	// monta a query
	cQuery := "SELECT SA3.A3_ITEMD CODFIL FROM "+retSqlname('SA3')+" SA3 "
	cQuery += " WHERE SA3.A3_FILIAL = '"+xFilial("SA3")+"'"
	cQuery += " AND SA3.A3_FORNECE = '"+SE5->E5_CLIFOR+"' AND SA3.A3_LOJA = '"+SE5->E5_LOJA+"'"
	cQuery += " AND SA3.D_E_L_E_T_ = ' ' "
	//cQuery := ChangeQuery(cQuery)

	// Executa a query
	TCQUERY cQuery NEW ALIAS _TMP

	cItemdd := _TMP->CODFIL

	// Fecha o cursor
	dbSelectArea('_TMP')
	dbCloseArea()
Endif
RestArea(aArea)

Return(cItemdd)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LPITEMDI  �Autor  �Elisabeth Gianuca   � Data �25/11/2003   ���
���Manutencao�LPITEMDI  �Autor  �Elisabeth Gianuca   � Data �25/11/2003   ���
�������������������������������������������������������������������������͹��
���Desc.     �Lancamento Padrao                                           ���
���          �Item centro de custo debito na inclusao do CP               ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function LPITEMDI()
Local aArea    := GetArea()
Local cprefixo := SE2->E2_PREFIXO // '' BETH 29/05/07
Local cQuery

If cprefixo != "COM"

		// monta a query
		cQuery := "SELECT SUBSTR(SX5.X5_DESCRI,1,2) CODFIL FROM "+retSqlname('SX5')+" SX5 "
		cQuery += " WHERE X5_FILIAL = '  '"
		cQuery += " AND SX5.X5_TABELA = 'ZM' AND SUBSTR(SX5.X5_CHAVE,1,3) = '"+cprefixo+"'"
		cQuery += " AND SX5.D_E_L_E_T_ = ' ' "
		//cQuery := ChangeQuery(cQuery)

		// Executa a query
		TCQUERY cQuery NEW ALIAS _TMP

		cItemdd :=  substr(SM0->M0_CODIGO, 2,1)+_TMP->CODFIL
		dbSelectArea('_TMP')
		dbCloseArea()

Else
	// monta a query
	cQuery := "SELECT SA3.A3_ITEMD CODFIL FROM "+retSqlname('SA3')+" SA3 "
	cQuery += " WHERE SA3.A3_FILIAL = '"+xFilial("SA3")+"'"
	cQuery += " AND SA3.A3_FORNECE = '"+SE2->E2_FORNECE+"' AND SA3.A3_LOJA = '"+SE2->E2_LOJA+"'"
	cQuery += " AND SA3.D_E_L_E_T_ = ' ' "
	//cQuery := ChangeQuery(cQuery)

	// Executa a query
	TCQUERY cQuery NEW ALIAS _TMP

	cItemdd := _TMP->CODFIL

	// Fecha o cursor
	dbSelectArea('_TMP')
	dbCloseArea()
Endif

RestArea(aArea)

Return(cItemdd)


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LPITEMLC  �Autor  �Elisabeth Gianuca   � Data �06/06/2007   ���
���Manutencao�LPITEMLC  �Autor  �Elisabeth Gianuca   � Data �06/06/2007   ���
�������������������������������������������������������������������������͹��
���Desc.     �Lancamento Padrao                                           ���
���          �Item centro de custo                                        ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function LPITEMLC()
Local aArea    := GetArea()
Local cprefixo := SUBSTR(STRLCTPAD,1,3)
Local cItemlc  := ""
Local cQuery


If !Empty(cprefixo)

		// monta a query
		cQuery := "SELECT SUBSTR(SX5.X5_DESCRI,1,2) CODFIL FROM "+retSqlname('SX5')+" SX5 "
		cQuery += " WHERE X5_FILIAL = '  '"
		cQuery += " AND SX5.X5_TABELA = 'ZM' AND SUBSTR(SX5.X5_CHAVE,1,3) = '"+cprefixo+"'"
		cQuery += " AND SX5.D_E_L_E_T_ = ' ' "
		//cQuery := ChangeQuery(cQuery)

		// Executa a query
		TCQUERY cQuery NEW ALIAS _TMP

		cItemlc :=  substr(SM0->M0_CODIGO, 2,1) +_TMP->CODFIL

		// Fecha o cursor
		dbSelectArea('_TMP')
		dbCloseArea()


Endif

RestArea(aArea)

Return(cItemlc)
