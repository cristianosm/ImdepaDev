#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH" 
#INCLUDE "TBICONN.CH" 
#DEFINE  ENTER CHR(13)+CHR(10)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � FT210BRW   � Autor �Fabiano Pereira      � Data �28/09/2016���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ponto de entrada chamado na tela abertura do Browser.      ���
���          | Nao permitir chamada via FATA210 - Padrao                  ���
���          � Deve-se utilizar rotina customizada FATA210A.prw           ���
���          �	                                                          ���
���          �	                                                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �ESPECIFICO PARA O CLIENTE IMDEPA						      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
*********************************************************************
User Function FT210BRW() 
*********************************************************************

If IsInCallStack('FATA210') //.And. cModulo == 'FAT'
	MsgAlert('Essa rotina (FATA210) dever� ser executada no seguinte caminho:'+ENTER+;
			 'Modulo: Faturamento-> Atualiza��es-> Pedidos-> Libera��o Regra', 'FT210BRW')
EndIf

Return()