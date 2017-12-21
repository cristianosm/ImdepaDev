#Include "RWMAKE.CH"

#Define __P12 "12"
#Define __P11 "11"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PE_OM010TOKºAutor  ³Edivaldo Gonçalves º Data ³  28/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada na confirmação da tabela de preços         º±±
±±º          ³Atualiza flag de controle do Gerenciamento Preço de Venda   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gravação da tabela de Preços                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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

		If dbSeek( xFilial("DA1") + cCodpro, .F. ) //Produto já existente na Tabela de Preço de Venda
			nPrecAtu:=DA1->DA1_PRCVEN
			nPrecMan:=DA1->DA1_PRCMAN
		Else
			nPrecAtu := 0
			nPrecMan := 0
		Endif

		For i=1 to Len(aCols)

			If GdFieldGet('DA1_PRCMAN',i)=0 .AND. GdFieldGet('DA1_PRCVEN',i)<>0

				Aviso('Preço Base Manual','Preço Base Manual Inválido , favor informar o Preço para continuar ! ',{'OK'})

				Return .F.
			Else

				//Verifica se houve mudança de Preço - DA1_PRCVEN
				If  nPrecAtu<>0 .AND. nPrecAtu <> GdFieldGet('DA1_PRCVEN',i)   //Houve alteração de Preço,deve atualizar a flag de controle do Job
					//GERENCIAMENTO PREÇO DE VENDA

					GDFieldPut('DA1_PRCMAN'    ,GdFieldGet('DA1_PRCVEN',i),i)      //Novo Preço
					GDFieldPut('DA1_ATUMAN'    ,1 ,i)                              //Flag de Controle do GERENCIAMENTO PREÇO DE VENDA
					GDFieldPut('DA_CONFIR '    ,'',i)                             //Garante a Trava Manual
					cObs:='Alteração manual,DA1_PRCVEN'
					U_MakeLogJob(cCodpro,' ',' ',GdFieldGet('DA1_PRCVEN',i),nPrecAtu,0,0,0,cObs,RetCodUsr())
				Endif

				// Verifica se houve mudança de preço base ( DA1_PRCMAN )
				If  nPrecMan<>0 .AND. nPrecMan <> GdFieldGet('DA1_PRCMAN',i)          //Houve alteração de Preço,deve atualizar a flag de controle do Job
					GDFieldPut('DA1_ATUMAN'    ,1 ,i)                              //Flag de Controle do GERENCIAMENTO PREÇO DE VENDA
					GDFieldPut('DA_CONFIR '    ,'',i)                              //Garante a Trava Manual
					cObs:='Alteração manual,DA1_PRCMAN'
					U_MakeLogJob(cCodpro,' ',' ',GdFieldGet('DA1_PRCMAN',i),nPrecAtu,0,0,0,cObs,RetCodUsr())
				Endif

				If nPrecAtu=0 // Produto Novo

					GDFieldPut('DA1_ATUMAN'    ,1 ,i)                              //Flag de Controle do GERENCIAMENTO PREÇO DE VENDA
					GDFieldPut('DA_CONFIR '    ,'',i)                              //Garante a Trava Manual
					cObs:='Alteração manual,DA1_PRCMAN,Prod Novo'
					U_MakeLogJob(cCodpro,' ',' ',GdFieldGet('DA1_PRCMAN',i),nPrecAtu,0,0,0,cObs,RetCodUsr())
				Endif

			Endif

		Next i

	EndIf

Return.T.
