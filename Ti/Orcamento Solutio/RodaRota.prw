#include "protheus.ch"
#include "topconn.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �U_RodaRota  � Autor �Expedito Mendonca Jr � Data � 19/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Atualiza o codigo da transportadora na tela de atendimento  ���
���          �do Call Center. Este ponto de entrada eh chamado apenas     ���
���          �quando o atendimento refere-se a cliente e nao a prospect.  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �ESPECIFICO PARA O CLIENTE IMDEPA						      ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

*****************************************************************************
User Function RodaRota()
*****************************************************************************
Local nPesoTotal,dDisp
Local lOk
Local aColsTmp := aClone(aCols), aHeaderTmp := aClone(aHeader)

//
/*BEGINDOC
//�����������������������������������Ŀ
//�carrega array das Rotas dispon�veis�
//�������������������������������������
ENDDOC*/

	Processa( {|| lOk:= U_MSTROT2QUERY(@nPesoTotal,@dDisp,@aHeaderTmp,@aColsTmp)}, OemToAnsi("Aguarde..."),OemToAnsi("Validando as Rotas..."))


Return lOk
