#Include "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MtValAvc  �Autor  �Cristiano Machado   � Data � 02/01/2013  ���
�������������������������������������������������������������������������͹��
���Desc.     � Este ponto de entrada eh executado antes da rotina de      ���
���          � avaliacao de credito.                                      ���
���          �          - MAAVALCRED() em FATXFUN().                      ���
���          �    Ele permite que o valor a ser passado para essa fun��o  ���
���          �    seja alterado.                                          ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico para o cliente IMDEPA                           ���
�������������������������������������������������������������������������͹��
���Ultimas Alteracoes                                                     ���
�������������������������������������������������������������������������͹��
���Autor     � Data     �  Descricao                                      ���
���          �          �                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

*****************************************************************************
User Function MtValAvc()
*****************************************************************************
Local nValor := PARAMIXB[2] //| Nao altera o Valor....


If AT("NDC",MVPROVIS) <= 0 
	MVPROVIS := MVPROVIS + "/NDC"   //| Tratamento para Desconsiderar NDC Durante avaliacao de Credito.... 20/12/12
EndIf

 
Return( nValor ) 
