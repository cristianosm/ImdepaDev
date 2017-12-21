#Include "RWMAKE.CH"

#Define __P12 "12"
#Define __P11 "11"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PE_OM010TOK�Autor  �Edivaldo Gon�alves � Data �  28/07/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada na confirma��o da tabela de pre�os         ���
���          �Atualiza flag de controle do Gerenciamento Pre�o de Venda   ���
�������������������������������������������������������������������������͹��
���Uso       � Grava��o da tabela de Pre�os                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
*****************************************************************************
User Function OM010TOK()
*****************************************************************************

	Local cCodpro  :=MV_PAR02
	Local nPrecAtu :=0
	Local nPrecMan :=0
	Local cObs     :=''
	Local cVersao := GetVersao(.F.)
	
	If cVersao == __P12
	
		Public aHeader := PARAMIXB[1]:AALLSUBMODELS[2]:AHEADER
		Public aCols   := PARAMIXB[1]:AALLSUBMODELS[2]:ACOLS
		
		//PutGlbValue( aHeader , PARAMIXB[1]:AALLSUBMODELS[2]:AHEADER )
		//PutGlbValue( aCols   , PARAMIXB[1]:AALLSUBMODELS[2]:ACOLS )
	
	ElseIf cVersao == __P11

		If dbSeek( xFilial("DA1") + cCodpro, .F. ) //Produto j� existente na Tabela de Pre�o de Venda
			nPrecAtu:=DA1->DA1_PRCVEN
			nPrecMan:=DA1->DA1_PRCMAN
		Else
			nPrecAtu := 0
			nPrecMan := 0
		Endif

		For i=1 to Len(aCols)

			If GdFieldGet('DA1_PRCMAN',i)=0 .AND. GdFieldGet('DA1_PRCVEN',i)<>0

				Aviso('Pre�o Base Manual','Pre�o Base Manual Inv�lido , favor informar o Pre�o para continuar ! ',{'OK'})

				Return .F.
			Else

				//Verifica se houve mudan�a de Pre�o - DA1_PRCVEN
				If  nPrecAtu<>0 .AND. nPrecAtu <> GdFieldGet('DA1_PRCVEN',i)   //Houve altera��o de Pre�o,deve atualizar a flag de controle do Job
					//GERENCIAMENTO PRE�O DE VENDA

					GDFieldPut('DA1_PRCMAN'    ,GdFieldGet('DA1_PRCVEN',i),i)      //Novo Pre�o
					GDFieldPut('DA1_ATUMAN'    ,1 ,i)                              //Flag de Controle do GERENCIAMENTO PRE�O DE VENDA
					GDFieldPut('DA_CONFIR '    ,'',i)                             //Garante a Trava Manual
					cObs:='Altera��o manual,DA1_PRCVEN'
					U_MakeLogJob(cCodpro,' ',' ',GdFieldGet('DA1_PRCVEN',i),nPrecAtu,0,0,0,cObs,RetCodUsr())
				Endif

				// Verifica se houve mudan�a de pre�o base ( DA1_PRCMAN )
				If  nPrecMan<>0 .AND. nPrecMan <> GdFieldGet('DA1_PRCMAN',i)          //Houve altera��o de Pre�o,deve atualizar a flag de controle do Job
					GDFieldPut('DA1_ATUMAN'    ,1 ,i)                              //Flag de Controle do GERENCIAMENTO PRE�O DE VENDA
					GDFieldPut('DA_CONFIR '    ,'',i)                              //Garante a Trava Manual
					cObs:='Altera��o manual,DA1_PRCMAN'
					U_MakeLogJob(cCodpro,' ',' ',GdFieldGet('DA1_PRCMAN',i),nPrecAtu,0,0,0,cObs,RetCodUsr())
				Endif

				If nPrecAtu=0 // Produto Novo

					GDFieldPut('DA1_ATUMAN'    ,1 ,i)                              //Flag de Controle do GERENCIAMENTO PRE�O DE VENDA
					GDFieldPut('DA_CONFIR '    ,'',i)                              //Garante a Trava Manual
					cObs:='Altera��o manual,DA1_PRCMAN,Prod Novo'
					U_MakeLogJob(cCodpro,' ',' ',GdFieldGet('DA1_PRCMAN',i),nPrecAtu,0,0,0,cObs,RetCodUsr())
				Endif

			Endif

		Next i

	EndIf

Return.T.
