#include "tbiconn.ch"

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    �Make_preco� Autor � Edivaldo/ M�rcio      � Data � 18/10/2006 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Registro dos preco do item no atendimento                    ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �ESPECIFICO PARA O CLIENTE IMDEPA						        ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
User Function Make_preco(cCodFil,cNumOrc,nSeqId,nVrcAcre)
/*
Local aTamSX3:= TamSX3("ZA0_SEQID")

DbSelectArea("ZA0")
dbsetorder(1)
//alert( cCodFil+cNumOrc+Str(nSeqId,aTamSX3[1],aTamSX3[2]))
If Dbseek(cCodFil+cNumOrc+Str(nSeqId,aTamSX3[1],aTamSX3[2]))
		RecLock("ZA0",.F.)
		ZA0->ZA0_PRECO  := nVrcAcre
		// Limpeza dos dados para Reprossessamento do workflow
		ZA0->ZA0_VOFERT	:=  0
		ZA0->ZA0_QOFERT	:=  0
		ZA0->ZA0_FLAGOF	:= " "
		ZA0->ZA0_DTOFER	:= CTOD(" ")
		ZA0->ZA0_HROFER	:= SPACE(LEN(ZA0->ZA0_HROFER))
		ZA0->(MsUnlock())
ENDIF
*/
Return(.T.)

