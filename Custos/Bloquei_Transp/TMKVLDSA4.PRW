#Include "Totvs.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TMKVLDSA4 �Autor  �Cristiano Machado   � Data �  31/01/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada executado na Validacao da Transportadora   ���
���          �no Botao Condicao de Pagamento e no Campo Transportadora    ���
���          �existente no cabecalho do atendimento.                      ���
���          �                                                            ���
���          �Foi criado com o intuito de Bloquear a alteracao da Transp. ���
���          �Manualmente pelo Vendedor quando eh FATURAMENTO e Frete CIF ���
���          �Nestes casos ele deve SEMPRE selecionar uma Tranportadora   ���
���          �utilizando a Rotina ROTAS no Atendimento.                   ���
�������������������������������������������������������������������������͹��
���Uso       � Validacao do Atendimento(TMKA271)                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
*****************************************************************************
User Function TMKVLDSA4()// Ponto Padrao Totvs
*****************************************************************************

__lTranspPossuiRota := .F.

Return(.T.)

