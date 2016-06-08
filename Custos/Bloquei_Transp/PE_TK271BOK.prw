#Include "Rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PE_TK271BOK�Autor  �Edivaldo           � Data �  30/08/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada executado na confirma��o do Or�amento      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � valida��o do Atendimento(TMKA271)                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
*****************************************************************************
User Function TK271BOK()
*****************************************************************************

     Local lReturn := .T.

         //Valida a tranportadora e o tipo de Frete - (Carro fixo nao pode ser usado no Frete Fob)
     If !U_IMDA890(M->UA_TRANSP)
        lReturn:=.F.
     Endif


     // Valida Selecao de Rota no caso de Faturamento e Frete CIF - Cristiano Machado - 31/01/2014 - Bloqueio de Alteracao de Transportadora
     If !__lTranspPossuiRota .And. M->UA_OPER == '1' .And. M->UA_TPFRETE == 'C' //1-FATURAMENTO

      lReturn := __lTranspPossuiRota
      Iw_Msgbox("Para CONFIRMAR o FATURAMENTO com Frete CIF, � necess�rio SELECIONAR uma ROTA!", "Aten��o", "ALERT")

     EndIf

Return(lReturn)
