/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �U_TMKCND    � Autor �Global Informatica   � Data � 07/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Atualiza o codigo da transportadora na tela de atendimento  ���
���          �do Call Center. Este ponto de entrada eh chamado sempre     ���
���          � que � aberto a tela da condi��o de pagamento. Usado para   ���
���          � buscar os dados da Transportadora e da Cond.Pag do SUA,    ���
���          � pois esse problema ser� corrigido somente no MP9.          ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
���            �        �                                                 ���
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
��� Uso      �ESPECIFICO PARA O CLIENTE IMDEPA						      ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������

/*/
User Function TMKCND(	cNumTlv,;
						cCliente,;
						cLoja,;
						cCodCont,;
						cCodOper,;
						aParcelas,;
						cCodPagto,;
						oCodPagto,;
						cDescPagto,;
						oDescPagto,;
						lVisual,;
						cCodTransp,cTransp)


IF Empty(M->UA_TRANSP)
	IF Empty(cCodTransp)
		cCodTransp := Posicione("SA1",1,xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA,"A1_TRANSP")
	ENDIF
ELSE
   	cCodTransp := M->UA_TRANSP
ENDIF
cCodPagto 	 := M->UA_CONDPG

oCodPagto:Refresh()
oDescPagto:Refresh()

	_ljaCPaCP := .T.

Return()



/*Static Function Tk270AtuTransp(cCodTransp,cTransp,oTransp)
Local lRet := .F.

cTransp := ""
DbSelectarea("SA4")
DbSetorder(1)
If DbSeek(xFilial("SA4")+cCodTransp)
   cTransp := SA4->A4_NOME
   oTransp:Refresh()
   lRet := .T.
Endif

Return(lRet)
*/
