#INCLUDE "PROTHEUS.CH"
#Include "Rwmake.ch"

///AJUSTADO PARA NÃO ABRIR A TELA DE OBS
///QUANDO JÁ ESTIVER GRAVADO
///VALIDADE PELA ADRIANE em 26 e 27/10/2014
///ela deu ok via email.


//ajustado 04/09/2014
//testes com mauricio



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PE_TK271BOKºAutor  ³Edivaldo           º Data ³  30/08/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada executado na confirmação do Orçamento      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ validação do Atendimento(TMKA271)                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TK271BOK()
	Local lReturn       :=.T.
	Local lAbaTeleVendas:=IIf( nFolder == 2,.T.,.F.)  // Define se a Aba em uso é a do TeleVendas

 //Inserido por Edivaldo Gonçalves Cordeiro em 03/05/2015
 //Somente executa este PE para o TeleVendas
	If lAbaTeleVendas

		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³  ROTINA CARREGAMENTO DA FUNCAO FISCAL COM BASE NO ACOLS E AHEADER   ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   //  MaColsToFis(aHeader,aCols,Nil,"TK271",.T.,Nil,Nil,Nil)
   //    ExpA1: Variavel com a estrutura do aHeader
   //    ExpA2: Variavel com a estrutura do aCols
   //    -> ExpN3: Item a ser carregado [ Nil = Todos ]          (opc)
   //    ExpC4: Nome do programa                                 (opc)
   //    ExpL5: Indica se o recalculo dos impostos deve ser feito(opc)
   //    ExpL6: Indica se o recalculo dos impostos deve ser feito(opc)
   //    ExpL7: Indica se o recalculo vai considerar as linhs apagadas
   // -------------------------------------------------------------------


		//MaColsToFis(aHeader,aCols,Nil,"TK271",.T.,Nil,.T.,Nil)




   //Frete FOB não pode ter Frete Destacado
		If M->UA_TPFRETE=='F'
			aValores[4]:=0
		Endif

         //Valida a tranportadora e o tipo de Frete - (Carro fixo nao pode ser usado no Frete Fob)
		If !U_IMDA890(M->UA_TRANSP)
			lReturn:=.F.
		Endif


     // Inserido por Edivaldo Goncalves Cordeiro em 03/05/2015
     // Houve alteração no pedido , obriga o operador a clicar na Condição de pagamento para o calculo correto do Frete
		If (M->UA_OPER=='1' .AND. M->UA_TPFRETE=='C' .AND. !__RodouRotas )
			IW_MsgBox("Para continuar , Selecione uma ROTA ! ","Gestão de Fretes", "ALERT")
			aValores[4]  	:= 0
			M->UA_FRETRAN 	:= 0
			M->UA_CODROTA 	:= SPACE(tamSX3("UA_CODROTA")[1])
			lReturn				:= .F.
			Return(lReturn)
		EndIf


   //Nao permite gravar o Pedido se a Rota estiver em branco sem antes selecionar uma Rota
			If (M->UA_TPFRETE=='C' .AND. M->UA_OPER=='1')
				If ( Empty(M->UA_CODROTA)) ;
						.OR. ((M->UA_TPFRETE=='C' .AND.  M->UA_FRETRAN==0 ) .AND. ;
						((XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (SA1->A1_VINCULO<>'PP' .AND. SA1->A1_VINCULO<>'CM') .AND. SA1->A1_CLIFRTE<>'1') )

					SUA->(U_Mstrot2()) //Seleciona uma Rota

				Endif
			Endif



/*
//Não permite a alteração do valor do Frete
If  aValores[4] < nVlFretAuto .AND. SA1->A1_CLFAMIN=="N"
 Aviso("Valor do Frete","Não é permitido a alteração do valor do frete !",{"OK"} )
 aValores[4]:=nVlFretAuto
Endif
*/


//////JULIO JACOVENKO, em 02/07/2014
//////projeto nova regra de frete
//////validar se usuario alterou valor do frete


////////////////////////////////////////////////////////////////
//////JULIO JACOVENKO, em 29/07/2014 - NOVA VERSAO DO PROJETO
//////So ira cair aqui se nao estiver nas EXCEÇÕES
//////
///////////////////////////////////////////////////////////////
/*

****Clientes contratos e programas (campo A1_vinculo = PP e CM) .

****Vendas feitas pela filial ES estarão liberadas para vendas com frete CIF.

****Clientes estratégicos identificados e justificados pela diretoria comercial.
Esta justificativa deverá ser encaminhada para análise
e liberação do setor financeiro.
Analisar a criação de um campo no cadastro de clientes
que identifique o cliente estratégico para fretes.

****Filial MA igual filial ES

*/
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////


////JULIO JACOVENKO, em 31/07/2014
////tratar excecoes
/////tratar aqui

////PARA USAR FILIAL 05
////QUANDO TODOS TROCAR
////IF (XFILIAL('SUA')<>'07' .OR. XFILIAL('SUA')<>'11') .AND. (SA1->A1_VINCULO<>'PP' .OR. SA1->A1_VINCULO<>'CM') .AND. (SA1->A1_CLFAMIN<>'S')


//MV_FILFRT='05/11'
  //IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (SA1->A1_VINCULO<>'PP' .AND. SA1->A1_VINCULO<>'CM')
			IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (SA1->A1_VINCULO<>'PP' .AND. SA1->A1_VINCULO<>'CM') .AND. SA1->A1_CLIFRTE<>'1'
//
//IF (XFILIAL('SUA')=='05') .AND. (SA1->A1_VINCULO<>'PP' .OR. SA1->A1_VINCULO<>'CM')


				IF LRETURN
					LRETURN:=fVldFrt(aVALORES[4])
				ENDIF

			ENDIF

////////////////////////////////////////////////

		EndIf
		Return(lReturn)



	Static Function fVldFrt(nVlrFrt)
		Local cPonto := PROCNAME(1)
		Local _nPosPeF := 4 //Len(aValores) + 1  //| Percentual Frete
		Local LRET:=.T.


//TK271BOK
		If cPonto =="U_TK271BOK"


	   //ALERT('FILIAL OPERANDO: '+XFILIAL('SUA'))

	   //ALERT('aVALORES: '+str(aValores[4])+' - FretCal: '+STR(M->UA_FRETCAL))


				////JULIO JACOVENKO, em 04/07/2014 -- novo projeto fretes
				////
				////criado em campo virtual que he calculo CIF-D ou CIF-I
				///M->UA_TIPOCIF:='CIF-D' ou 'CIF-I'
				///para tratamento das validacoes.
          //IF ALLTRIM(M->UA_OBSFRT)=''
            //M->UA_OBSFRT:=SPACE(50)
          //ENDIF


          ///JULIO JACOVENKO, em 30/07/2014
          ///como estou usando o campo aValores[4] e este alimenta (quando destacado) o
          ///campo UA_FRETE (internamente), agora somos obrigado a zerar quando
          ///for frete NAO DESTACADO, ja que estamos usando o aValores para alteraçoes.


			If !GETMV('IM_FRETE20')  //Se filial não utiliza novo frete utilizar regra antiga
				if ALLTRIM(M->UA_OBSFRT)='' .AND. (aValores[4] < M->UA_FRETCAL) .AND. M->UA_TPCIF='CIFD'   ///CIF Destacado
					IF MSGYESNO( 'CIFD - Voce esta cobrando Frete a Menor...Justifique!!!', 'Atenção - Frete menor que o calculado' )
						M->UA_OBSFRT:=fMotivo()
						LRET:=.T.
					else
						LRET:=.F.
						M->UA_OBSFRT:=SPACE(50)
						AVALORES[4]:=M->UA_FRETCAL
					endif
				ELSEIF ALLTRIM(M->UA_OBSFRT)<>'' .AND. (aValores[4] >= M->UA_FRETCAL) .AND. M->UA_TPCIF='CIFI'
					M->UA_OBSFRT:=SPACE(50)
					LRET:=.T.
				EndIf



				if ALLTRIM(M->UA_OBSFRT)='' .AND. (aValores[4] < M->UA_FRETCAL) .AND. M->UA_TPCIF='CIFI'  ///CIF imcorporado
					IF MSGYESNO( 'CIFI - Voce esta cobrando Frete a Menor...Justifique!!!', 'Atenção - Frete menor que o calculado' )
						M->UA_OBSFRT:=fMotivo()
						LRET:=.T.
					else
						M->UA_OBSFRT:=SPACE(50)
						LRET:=.F.
						AVALORES[4]:=M->UA_FRETCAL
					endif
				ELSEIF ALLTRIM(M->UA_OBSFRT)<>'' .AND. (aValores[4] >= M->UA_FRETCAL) .AND. M->UA_TPCIF='CIFI'
					M->UA_OBSFRT:=SPACE(50)
					LRET:=.T.
				EndIf

			Else //Se frete nova versao 2.0

           //JULIO JACOVENKO, em 03/11/2014
           //versao 3.0
				_aarea:=getarea()
				DbSelectarea("SUA")
				DbSetorder(1)


		    /*
		    IF !_LPEGATRAN
		     ALERT('LPEGRAM HE FALSE')
		    ELSE
		     ALERT('LPEGRAM HE TRUE')
		    ENDIF
		    */


				IF DBSEEK(XFILIAL('SUA')+M->UA_NUM) .AND. !_LPEGATRAN  ///_LPEGTRAN , ve se já passou pelo transporte
					_NVALSUG:=SUA->UA_FRETCAL
					M->UA_FRETRAN:=SUA->UA_FRETRAN
					M->UA_FRETE:=SUA->UA_FRETE
		              //_LPEGATRAN:=.F.
				ENDIF

				dBSELECTAREA(_AAREA)





				if (aValores[4] < _NVALSUG) .AND. M->UA_TPCIF='CIFD'   ///CIF Destacado
					IF _NACOL>1
						ALERT( "Você selecionou uma transportadora cujo frete não é o menor entre as transportadoras."+CHR(13)+CHR(13)+"Não é possível diminuir o valor do frete neste caso.")
					ELSE
						ALERT( "Valor do frete digitado menor que o valor calculado pelo Percentual de Frete sobre Vendas."+CHR(13)+CHR(13)+"Favor informar um frete maior." )
					ENDIF

					LRET:=.F.

					IF  !_LPEGATRAN
						AVALORES[4]:= M->UA_FRETE
					ELSE
						AVALORES[4]:= M->UA_FRETRAN
					ENDIF

				ELSEIF (aValores[4] >= _NVALSUG) .AND. M->UA_TPCIF='CIFD'
					M->UA_FRETCAL:=_NVALSUG
					LRET:=.T.
				EndIf



				if (aValores[4] < _NVALSUG) .AND. M->UA_TPCIF='CIFI'   ///CIF Destacado
					IF _NACOL>1
						ALERT( "Você selecionou uma transportadora cujo frete não é o menor entre as transportadoras."+CHR(13)+CHR(13)+"Não é possível diminuir o valor do frete neste caso.")
					ELSE
						ALERT( "Valor do frete digitado menor que o valor calculado pelo Percentual de Frete sobre Vendas."+CHR(13)+CHR(13)+"Favor informar um frete maior." )
					ENDIF
					LRET:=.F.
					IF  !_LPEGATRAN
						AVALORES[4]:= M->UA_FRETE
					ELSE
						AVALORES[4]:= M->UA_FRETRAN
					ENDIF


				ELSEIF (aValores[4] >= _NVALSUG) .AND. M->UA_TPCIF='CIFI'
					M->UA_FRETCAL:=_NVALSUG
					LRET:=.T.
				EndIf




				IF !_LPEGATRAN
					_LPEGATRAN:=.F.
				ENDIF

			EndIf

		ENDIF


  ////JULIO JACOVENKO, em 30/07/2104
  ////quando CIFII somo obrigados a zerar antes de gravar
  ////pois este campo alimenta via sistema o UA_FRETE, que
  ////he usado para Frete Destacado
  ////
  /*
  IF M->UA_TPCIF="CIFI"
     //ALERT('...HE FRETE CIFI...')
     //JULIO JACOVENKO, em 30/07/2014
     //testada e funcional
     //
     AVALORES[4]:=0
  ENDIF
  */


		Return LRET



///JULIO JACOVENKO, em 07/07/2014
///grava o motivo da reducao ou aumento do frete
///
	STATIC FUNCTION fMotivo()
		Private oDlg,oSayMotivo
		Private cMotivo,oMotivo,oConfirma
		Private Lsair:=.F.

		cMotivo:=SPACE(100)
		DEFINE MSDIALOG oDlg TITLE "Justificativa (minimo 30 caractere)" FROM 400,400 TO 510,980 PIXEL

		@ 001   , 017 SAY		oSayMotivo	PROMPT OemToAnsi( "Motivo" ) SIZE 045, 012 OF oDlg PIXEL
		@ 003   , 037 MSGET	    oMotivo	VAR cMotivo SIZE 059+100, 010 OF oDlg PICTURE "@!" VALID(LEN(ALLTRIM(cMotivo))>=30) PIXEL

		@ 030   , 017 BUTTON	oConfirma PROMPT "Confirma" SIZE 067, 010 OF oDlg ACTION(LSAIR:=.T., ODLG:END()) PIXEL



               //@ 105, 020 GET oMultiGe1 VAR cMensagem OF oWinMail MULTILINE SIZE 215, 080 COLORS 0, 16777215 HSCROLL PIXEL

	           //@ 500,600 BUTTON "OK"		SIZE 40,13 ACTION {|| oDlg:End() }			PIXEL Of oDlg


		ACTIVATE MSDIALOG oDlg CENTERED VALID LSAIR

		RETURN cMotivo