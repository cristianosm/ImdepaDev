#DEFINE xFreteNormal 	 8
#DEFINE xFretNorReemb    9
#DEFINE xFreteExpress   10
#DEFINE xFretExpReemp   11


//ajustado 04/09/2014
//testes com mauricio



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �U_ValRota  � Autor �Expedito Mendonca Jr � Data � 19/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida Rotina de Rotas  para a confirma��o do atendimento   ���
���          �do Call Center. Usada na Rotina PE_TMKGRPED                 ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �ESPECIFICO PARA O CLIENTE IMDEPA						      ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function ValRota()
    
Local nPos 			:= 0
Local lCondPagOK 	:= .T.
Local lRet 		 	:= .T.
Local nTolerancia 	:= 0.1  // um centavo , tolerancia devido ao aredondamento
Local cOperacao     :=Iif(M->UA_OPER=='1',"Faturamento","Or�amento")
  
Private __aRotasDisponiveis	:= {}
Private cMens:=' '
__lValTranspXRota  := .T.

// S� executa as valida��es de Rota se for no Pedido, no Or�amemto n�o precisa validar
If M->UA_OPER <> '1'
  Return(lRet)
Endif

// Caso for rotina autom�tica, ou n�o for Faturamento,  nao valida as Rotas 

//IF M->UA_OPER != "1" .OR. !(Type("lTk271Auto") == "U" .OR. !lTk271Auto)
//	Return lRet
//ENDIF




    //EDI IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (SA1->A1_VINCIMD<>'PP' .AND. SA1->A1_VINCIMD<>'CM')

	
	  //	JULIO:=.T.
	//	IF JULIO
	  //	   RETURN .T.                                                                                                            
	//	ENDIF                                                                  
	//EDI ENDIF  
	
	

//�������������������������������������������������������������������������������������������������Ŀ
//�Verifica se j� foi Rodada a  rotina de Rotas Anteriormente, se n�o ,roda sem interface com usu�rio�
//�para verificar se a rota atual ainda faz parte do range selecionado
//���������������������������������������������������������������������������������������������������

u_RodaRota()

//----------------------------------------
//Verifica se a Transportadora Possui Rota
__lTranspPossuiRota := aScan(__aRotasDisponiveis, {|x| x[1] == M->UA_TRANSP}) > 0


// Verifica se a Rota atual pertence � Transportadora atual
IF !EMPTY(M->UA_CODROTA) //.AND. __lTranspPossuiRota
	nPos := aScan(__aRotasDisponiveis, {|x| x[3] == M->UA_CODROTA})
	IF nPos > 0
		IF M->UA_TRANSP <> __aRotasDisponiveis[nPos][1]
			__lValTranspXRota := .F. //DBSEEK(xFilial("SZO")+M->UA_TRANSP+M->UA_CODROTA,.F.)
		ENDIF
	ELSE // A Tranportadora n�o possui rota
		__lValTranspXRota := .F.
	ENDIF
	
ENDIF
//-----------------------------------------


IF  !__lValTranspXRota
	
	//	If Type("lTk271Auto") == "U" .Or. !lTk271Auto
	lRet := .F.
	IW_MSGBOX(Oemtoansi(" Rota selecionada n�o corresponde a esta tranportadora. Limpando Rota Selecionada... !"),Oemtoansi('Aten��o'),'ALERT')
	//	Else
	//		lRet := .T.  //Libera para quando vir do PALM (Proj Rotas)
	//		ConOut(" Rota selecionada n�o corresponde a esta tranportadora. Limpando Rota Selecionada... !")
	//	EndIf
	M->UA_CODROTA 		:= SPACE(tamSX3("UA_CODROTA")[1])
	M->UA_FRETCAL 		:= 0
	aValores[4] 		:= M->UA_FRETCAL
	Tk273RodImposto("NF_FRETE",aValores[4])
	__RodouRotas		:= .F.
	
ELSEIF 	M->UA_TPFRETE == "C"
	
	//�������������������������������������������������������������H�
	//�VERIFICO SE A ROTA ATUAL CORRESPONDE A TRANSPORTADORA  ATUAL�
	//�������������������������������������������������������������H�
	
	IF Posicione("SA4",1,xFilial("SA4")+M->UA_TRANSP,"A4_CIF") != "1"
		//		If Type("lTk271Auto") == "U" .Or. !lTk271Auto
		lRet := .F.
		IW_MSGBOX(Oemtoansi("Transportadora n�o habilitada � trabalhar com frete CIF " ),Oemtoansi('Aten��o'),'ALERT')
		Return lRet
		//		Else
		//			lRet := .T.  //Libera para quando vir do PALM (Proj Rotas)
		//			ConOut("Transportadora n�o habilitada � trabalhar com frete CIF ")
		//		EndIf
	ELSEIF  __lTranspPossuiRota
		
		//EDIIF  EMPTY(M->UA_CODROTA)			
			
			//lRet := .F.
			//aResp:={'SIM','N�O'}
			//nResp:= Aviso(Oemtoansi('Rotas'),Oemtoansi(" � necess�rio selecionar uma Rota para esta Transportadora ! Deseja selecionar agora?"),aResp)
			//IF nResp == 1
			 //	U_Mstrot2()
			//ENDIF
			
		//EDIENDIF
		
	ENDIF
	
	
	
	//�����������������������������������������������Z�
	//�Sempre que for CIF o falor do FRETE CALCULADO�
	//� N�O pode estar zerado                       �
	//�����������������������������������������������Z�
	
    ///JULIO JACOVENKO, em 27/08/2014
    ///
    
  
    
	// Valida aqui o frete calculado zerado somente se tiver sido escolhida a rota, pois ser� validado novamente na confirma��o do pedido


//IF (XFILIAL('SUA')<>'07' .OR. XFILIAL('SUA')<>'11') .OR. (A1_VINCIMD<>'PP' .OR. A1_VINCIMD<>'CM') .OR. (A1_CLFAMIN<>'S') 


    
    //ORIGINAL JULIO IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (SA1->A1_VINCIMD<>'PP' .AND. SA1->A1_VINCIMD<>'CM') .AND. SA1->A1_CLIFRTE<>'1'
    IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (SA1->A1_VINCIMD<>'PP' .OR. SA1->A1_VINCIMD=='CM') .OR. SA1->A1_CLIFRTE<>'1' //.AND. SA1->A1_TPFRET <> 'F'
   //Return(.T.)//EDI

//IF (XFILIAL('SUA')=='05') .AND. (SA1->A1_VINCIMD<>'PP' .OR. SA1->A1_VINCIMD<>'CM') 
    lRet := .T.
    ELSE
	IF lRet .AND. M->UA_FRETCAL == 0
		IF EMPTY(M->UA_CODROTA)
			cMens:= " Consulte a Log�stica para obter o valor e preencher o Frete Calculado !"
		ELSE
			cMens:= " Consulte a Log�stica. Rota selecionada est� retornando Frete Calculado Zerado !"
		ENDIF
		//		If Type("lTk271Auto") == "U" .Or. !lTk271Auto
		lRet := .F.
		IW_MSGBOX(Oemtoansi("N�o foi poss�vel obter o c�lculo do Frete." + cMens),Oemtoansi('Aten��o'),'ALERT')
		//		Else
		//			lRet := .T.  //Libera para quando vir do PALM (Proj Rotas)
		//			ConOut("N�o foi poss�vel obter o c�lculo do Frete." + cMens)
		//		EndIf
		
	ENDIF
ENDIF   
    


ENDIF


//�������������������������������������������������������������������������������������Ŀ
//�Consist�ncia para verificar se foi adicionado ou retirado itens do atendimento       �
//�                                                                                     �
//�Caso tenha sido, isso afetar� o Frete Calculado e portanto o valor estar� divergindo.�
//�Esta rotina verifica se o Frete Calculado est� correto                               �
//���������������������������������������������������������������������������������������


//	M->UA_FRETEXP := IIF(nNorExp==2,"1","2")  // 1=Sim, 2=Nao
//  M->UA_REEMB   := IIF(nReemb==1,"S","N")	  // 1=Sim, 2=Nao
IF lRet
	// Jorge Oliveira - 08/12/10
	// Para frete FOB, sempre serah zero o campo de Frete Calculado, por isso nao precisa validar isso.
	If M->UA_FRETCAL > 0
		IF M->UA_FRETEXP == "2"	//Nao  (Normal)
			If M->UA_REEMB == "N"  // Normal sem reembolso
				IF nPos > 0
					If   !(M->UA_FRETCAL-nTolerancia <= __aRotasDisponiveis[nPos,xFreteNormal] .and. __aRotasDisponiveis[nPos,xFreteNormal] <= M->UA_FRETCAL+nTolerancia )//!Entre(M->UA_FRETCAL-nTolerancia,M->UA_FRETCAL+nTolerancia, __aRotasDisponiveis[nPos,8]) //M->UA_FRETCAL <> __aRotasDisponiveis[nPos,8]
						cMens :=  AllTrim(STR(__aRotasDisponiveis[nPos,xFreteNormal]))

								//IF (XFILIAL('SUA')<>'07' .OR. XFILIAL('SUA')<>'11') .OR. (A1_VINCIMD<>'PP' .OR. A1_VINCIMD<>'CM') .OR. (A1_CLFAMIN<>'S') 
								
								
								
								//MV_FILFRT='05/11'
    //IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (SA1->A1_VINCIMD<>'PP' .AND. SA1->A1_VINCIMD<>'CM')
			IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (SA1->A1_VINCIMD<>'PP' .AND. SA1->A1_VINCIMD<>'CM') .AND. SA1->A1_CLIFRTE<>'1' //.AND. SA1->A1_TPFRET <> 'F'														
										//IF (XFILIAL('SUA')=='05') .AND. (SA1->A1_VINCIMD<>'PP' .OR. SA1->A1_VINCIMD<>'CM') 
										  lRet := .T. 
			ELSE
										  lRet := .F.
			ENDIF
		



                   ENDIF
               ENDIF
			Else
				IF nPos > 0				// Normal com reembolso
					IF  !(M->UA_FRETCAL-nTolerancia <= __aRotasDisponiveis[nPos,xFretNorReemb] .and. __aRotasDisponiveis[nPos,xFretNorReemb] <= M->UA_FRETCAL+nTolerancia )//!Entre(M->UA_FRETCAL-nTolerancia,M->UA_FRETCAL+nTolerancia, __aRotasDisponiveis[nPos,9]) //M->UA_FRETCAL <> __aRotasDisponiveis[nPos,9]
						cMens :=  AllTrim(STR(__aRotasDisponiveis[nPos,xFretNorReemb]))
						lRet := .F.
					ENDIF
				ENDIF
				
			Endif
		ELSE			//Expresso
			If M->UA_REEMB == "N"	//Expresso sem reembolso
				IF nPos > 0
					IF  !(M->UA_FRETCAL-nTolerancia <= __aRotasDisponiveis[nPos,xFreteExpress] .and. __aRotasDisponiveis[nPos,xFreteExpress] <= M->UA_FRETCAL+nTolerancia )//!Entre(M->UA_FRETCAL-nTolerancia,M->UA_FRETCAL+nTolerancia, __aRotasDisponiveis[nPos,10]) //M->UA_FRETCAL <> __aRotasDisponiveis[nPos,10]
						cMens :=  AllTrim(STR(__aRotasDisponiveis[nPos,xFreteExpress]))				
						lRet := .F.
					ENDIF
				ENDIF
			Else
				IF nPos > 0		// Expresso com reembolso
					IF  !(M->UA_FRETCAL-nTolerancia <= __aRotasDisponiveis[nPos,xFretExpReemp] .and. __aRotasDisponiveis[nPos,xFretExpReemp] <= M->UA_FRETCAL+nTolerancia )//!Entre(M->UA_FRETCAL-nTolerancia,M->UA_FRETCAL+nTolerancia, __aRotasDisponiveis[nPos,11]) //M->UA_FRETCAL <> __aRotasDisponiveis[nPos,11]
						cMens :=  AllTrim(STR(__aRotasDisponiveis[nPos,xFretExpReemp]))								
						lRet := .F.
					ENDIF
				ENDIF
			Endif
		ENDIF
	ENDIF

	///JULIO JACOVENKO, em 01/08/2014
	///projeto novo frete
	//LRET:=.T.
	
	If ((XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (Alltrim(SA1->A1_VINCIMD)=='PP' .OR. Alltrim(SA1->A1_VINCIMD)=='CM' .OR. Alltrim(SA1->A1_CLIFRTE)=='1'))
		Return(.T.)
	Endif   
	
	IF !lRet 

	 	//		If Type("lTk271Auto") == "U" .Or. !lTk271Auto
		IW_MSGBOX(Oemtoansi("O Frete Calculado sofreu altera��o. Provavelmente foi inclu�do ou apagado itens do atendimento. Favor selecionar a Rota novamente para recalcular. Frete Calculado deveria estar em torno de " +cMens ),Oemtoansi('Aten��o'),'ALERT')
		//		Else
		//			lRet := .T.  //Libera para quando vir do PALM (Proj Rotas)
		//			ConOut("O Frete Calculado sofreu altera��o. Provavelmente foi inclu�do ou apagado itens do atendimento. Favor selecionar a Rota novamente para recalcular")
		//		EndIf
	ENDIF
	
ENDIF                      


    /*
	IF (XFILIAL('SUA')=='05') .AND. (SA1->A1_VINCIMD<>'PP' .OR. SA1->A1_VINCIMD<>'CM') 
		///JULIO JACOVENKO, em 01/08/2014
		///projeto novo frete
		///VERIFICAR COM EDIVALDO como contornar estas
		///validacoes.
		////
		LRET:=.T.
	ENDIF
	*/                  
	
	If  (Empty(M->UA_CODROTA) .AND. M->UA_TPFRETE == "C")			
			lRet := .F.
			//aResp:={'SIM','N�O'}
			//nResp:= Aviso(Oemtoansi('Rotas'),Oemtoansi(" � necess�rio selecionar uma Rota para esta Transportadora ! Deseja selecionar agora?"),aResp)
			//If nResp == 1
			 //	U_Mstrot2()
			//Endif
			//IW_MsgBox("O Sistema n�o localizou o or�amento "+cNumOrc,"Orcamento n�o encontrado","INFO")
		
		//IW_MsgBox("Selecione uma rota para este "+ cOperacao+"Sem Rota Definida","ALERT")  
		IW_MSGBOX("Selecione uma rota para este "+cOperacao,cOperacao+" sem Rota Definida","INFO")
	Endif		
	
Return lRet
