#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#DEFINE  ENTER CHR(13)+CHR(10)

/*
??????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
???Programa  ?PE_TK271BOK?Autor ?Edivaldo            ?Data ? 30/08/13   ???
?????????????????????????????????????????????????????????????????????????????
???Desc.     ?Ponto de entrada executado na confirma??o do ATENDIMENTO.    ???
???         ?                                                            ???
???         ?Esse ponto de entrada ?chamado no bot?o "OK" da barra de    ???
???         ?ferramentas da tela de atendimento do Call Center, antes da  ???
???         ?fun??o de grava??o.                                          ???
?????????????????????????????????????????????????????????????????????????????
???Uso       ?Valida??o do Atendimento(TMKA271)                           ???
?????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????????
*/
User Function TK271BOK()
	Local lReturn       :=.T.
	Local lAbaTeleVendas:=IIf( nFolder == 2,.T.,.F.)  // Define se a Aba em uso ?a do TeleVendas
  

//???????????????????????????????????????????
//? RAFAEL - SOLUTIO                    	?
//? BUSCA REGRA DE NEGOCIO PERSONALIZADA	?
//???????????????????????????????????????????	
	*************************
	U_TK271RN() 	//	<- TK271RNEG.PRW
	*************************

/*
aValores[5] := 5.25
Tk273RecCpg()
MaFisAlt("NF_DESPESA",aValores[5]+aValores[3])
Tk273Refresh(.T.)
*/

 //Inserido por Edivaldo Gon?alves Cordeiro em 03/05/2015
 //Somente executa este PE para o TeleVendas
	If lAbaTeleVendas

   //???????????????????????????????????????????????????????????????????????
   //? ROTINA CARREGAMENTO DA FUNCAO FISCAL COM BASE NO ACOLS E AHEADER   ?
   //???????????????????????????????????????????????????????????????????????
   //  MaColsToFis(aHeader,aCols,Nil,"TK271",.T.,Nil,Nil,Nil)  
   //    ExpA1: Variavel com a estrutura do aHeader                  
   //    ExpA2: Variavel com a estrutura do aCols                    
   //    -> ExpN3: Item a ser carregado [ Nil = Todos ]          (opc)
   //    ExpC4: Nome do programa                                 (opc)
   //    ExpL5: Indica se o recalculo dos impostos deve ser feito(opc)
   //    ExpL6: Indica se o recalculo dos impostos deve ser feito(opc)
   //    ExpL7: Indica se o recalculo vai considerar as linhs apagadas
   // -------------------------------------------------------------------


  // MaColsToFis(aHeader,aCols,Nil,"TK271",.T.,Nil,.T.,Nil)      
   
	//???????????????????????????????????????????????????
	//| VERIFICA SE ALGUM ITEM NAO RODOU MaColsToFis	|
	//???????????????????????????????????????????????????
	//If Ascan(aProdXImp, {|X| X[25] == .F.}) > 0		//	[25] FLAG SE EXECUTOU MaColsToFis
	//	ExecBlock('ChkMaColsToFis', .F., .F.)
	//EndIf
		Tk273Refresh(.T.)
   
   //Frete FOB n?o pode ter Frete Destacado  
		If M->UA_TPFRETE=='F'
			aValores[4]:=0
		Endif
    
         //Valida a tranportadora e o tipo de Frete - (Carro fixo nao pode ser usado no Frete Fob)
		If !U_IMDA890(M->UA_TRANSP)
			lReturn:=.F.
		Endif
    
          
     // Inserido por Edivaldo Goncalves Cordeiro em 03/05/2015
     // Houve altera??o no pedido , obriga o operador a clicar na Condi??o de pagamento para o calculo correto do Frete       
		If (M->UA_OPER=='1' .AND. M->UA_TPFRETE=='C' .AND. !_ljaCPaCP )
			IW_MsgBox("Para continuar , clique na Condi??o de pagamento ! ","Gest?o de Fretes", "ALERT")
			aValores[4]  := 0
			M->UA_FRETRAN :=0
			M->UA_CODROTA := SPACE(tamSX3("UA_CODROTA")[1])
			lReturn:=.F.
			Return(lReturn)
		EndIf
    
     
   //Nao permite gravar o Pedido se a Rota estiver em branco sem antes selecionar uma Rota  
		LVINCULO:=ALLTRIM(SA1->A1_VINCULO)$  ("#CM*CM*#PP*PP")
		If (M->UA_TPFRETE=='C' .AND. M->UA_OPER=='1')
			If ( Empty(M->UA_CODROTA)) ;
					.OR. ((M->UA_TPFRETE=='C' .AND.  M->UA_FRETRAN==0 ) .AND. ;
					((XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (!LVINCULO) .AND. SA1->A1_CLIFRTE<>'1') )
                     
				SUA->(U_Mstrot2()) //Seleciona uma Rota
        
			Endif
		Endif
    
     
     
/*
//N?o permite a altera??o do valor do Frete
If  aValores[4] < nVlFretAuto .AND. SA1->A1_CLFAMIN=="N"   
 Aviso("Valor do Frete","N?o ?permitido a altera??o do valor do frete !",{"OK"} )
 aValores[4]:=nVlFretAuto   
Endif
*/


//////JULIO JACOVENKO, em 02/07/2014
//////projeto nova regra de frete
//////validar se usuario alterou valor do frete

                                                               
////////////////////////////////////////////////////////////////
//////JULIO JACOVENKO, em 29/07/2014 - NOVA VERSAO DO PROJETO
//////So ira cair aqui se nao estiver nas EXCE??ES 
//////
///////////////////////////////////////////////////////////////
/*

****Clientes contratos e programas (campo A1_vinculo = PP e CM) .

****Vendas feitas pela filial ES estar?o liberadas para vendas com frete CIF.

****Clientes estrat?gicos identificados e justificados pela diretoria comercial.
Esta justificativa dever?ser encaminhada para an?lise
e libera??o do setor financeiro.
Analisar a cria??o de um campo no cadastro de clientes
que identifique o cliente estrat?gico para fretes.

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
		LVINCULO:=ALLTRIM(SA1->A1_VINCULO)$  ("#CM*CM*#PP*PP")
		IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (!LVINCULO) .AND. SA1->A1_CLIFRTE<>'1' .AND. SA1->A1_TPFRET <> 'F'
//
//IF (XFILIAL('SUA')=='05') .AND. (SA1->A1_VINCULO<>'PP' .OR. SA1->A1_VINCULO<>'CM')  


			IF LRETURN
				LRETURN:=fVldFrt(aVALORES[4])
			ENDIF

		ENDIF

////////////JULIO JACOVENKO, em 19/10/2105
////////////para nova regra do frete Grupo1 e Grupo3
/////////////////////////////////////////////////////////
		LVINCULO:=ALLTRIM(SA1->A1_VINCULO)$  ("#CM*CM*#PP*PP")

//CARRO FIXO SP
//CMEPP OU ESPECIAL LIBERA CARRO FIXO         LCLISPFRT :=.F. LIBERA
//NAO CMM NEM ESPECIAL MAIOR 3000 LIBERA      LCLISPFRT :=.F. LIBERA
//NAO CMM NEM ESPECIAL MENOR 3000 NAO LIBERA   LCLISPFRT:=.T. NAO LIBERA
//SEM CARRO FIXO SP							  	 LCLISPFRT :=.F. LIBERA

//COM OU SEM CARRO FIXO NAO SP
//CMPP OU ESPECIAL LIBERA CARRO FIXO           LCLISPFRT:=.F. (default)
//NAO CMPP E NAO ESPECIAL NAO LIBERA           LCLISPFRT:=.F. (default)

///CLIENTE SPFIXO E NA REGRA  : LCLIENTESP SE .T. E DA REGRA SPFIXO


///REGRA GERAL                                                          
///PARA NAO LIBERAR
///NAO CMPP OU NAO ESPECIAL E NAO FOB
///



		IF !LVINCULO  .AND. SA1->A1_CLIFRTE<>'1'

    
			IF (SA1->A1_TPFRET <> 'F') .AND. !LCLIENTESP .AND. !LCLISPFRT
	        ///NAO LIBERA
				IF ((AVALORES[4]< M->UA_FRETCAL) .AND. NDESTACA=1)
					LRETURN:=.F.
					AVALORES[4]:=M->UA_FRETCAL
					CTEXTO:=" * "
			      
					IF NDESTACA=1
						CTEXTO:='Destacado'
					ELSE
						CTEXTO:='N/Destacado'
					ENDIF
			           
					IW_MsgBox("Frete "+CTEXTO+" nao pode ser menor que Calculado ! ","Gest?o de Fretes:Nao sao CM/PP ou Especial", "ALERT")
				ENDIF
			ENDIF
	
	
	////PARA REGRA FRETE SPFIXO
	////SE NAO CMPP OU NAO ESPECIAL NAO FOB E CLIENTESP(REGRA FIXO) E NAO PASSOU REGRA 3000
	////ENTRA NA REGRA DO 1%
	
	
			IF (SA1->A1_TPFRET <> 'F') .AND. LCLIENTESP .AND. LCLISPFRT
	        ///NAO LIBERA
				IF ((AVALORES[4]< M->UA_FRETCAL) .AND. NDESTACA=1)
					LRETURN:=.F.
					AVALORES[4]:=M->UA_FRETCAL
					CTEXTO:=" * "
			      
					IF NDESTACA=1
						CTEXTO:='Destacado'
					ELSE
						CTEXTO:='N/Destacado'
					ENDIF
			           
					IW_MsgBox("Frete "+CTEXTO+" nao pode ser menor que Calculado ! ","Gest?o de Fretes:Nao sao CM/PP ou Especial CFSP", "ALERT")
				ENDIF
			ENDIF
		ENDIF








/*
IF ( (!LVINCULO) .AND. SA1->A1_CLIFRTE='1') .OR. (LVINCULO) .AND. SA1->A1_TPFRET <> 'F'
//IF ( !(ALLTRIM(SA1->A1_VINCULO)$'CM#PP#') .AND. SA1->A1_CLIFRTE='1') .OR. (LVINCULO) .AND. SA1->A1_TPFRET <> 'F'
   IF ((AVALORES[4]< M->UA_FRETCAL) .AND. NDESTACA=1)
      LRETURN:=.F.
      AVALORES[4]:=M->UA_FRETCAL                             
      CTEXTO:=" * "
      
      IF NDESTACA=1
         CTEXTO:='Destacado'
      ELSE
         CTEXTO:='N/Destacado'
      ENDIF 
           
      IW_MsgBox("Frete "+CTEXTO+" nao pode ser menor que Calculado ! ","Gest?o de Fretes: CM/PP ou Especial", "ALERT")  
   ENDIF   
ENDIF                                                      
*/

		IF SA1->A1_TPFRET = 'F'
			IF ((AVALORES[4]< M->UA_FRETCAL) .AND. NDESTACA=1)
				LRETURN:=.F.
				AVALORES[4]:=M->UA_FRETCAL
				CTEXTO:=" * "
      
				IF NDESTACA=1
					CTEXTO:='Destacado'
				ELSE
					CTEXTO:='N/Destacado'
				ENDIF
           
				IW_MsgBox("Frete "+CTEXTO+" nao pode ser menor que Calculado ! ","Gest?o de Fretes: Regra Cliente FOB", "ALERT")
			ENDIF

		ENDIF

//////////////////////////////////////////////////////

       If lReturn 
          LRETURN:= DPARCULT(M->UA_CONDPG) //BLOQUEIA CLIENTES COM RISCO D COM CONDICAO DE PAGAMENTO COM DATA DA ULTIMA PARCELA MAIOR QUE O VALOR DO PARAMETRO MV_DIASULP (45 DIAS) - AGOSTINHO LIMA - 14/03/2016 - CHAMADO 2454
       Endif


	
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
          ///for frete NAO DESTACADO, ja que estamos usando o aValores para altera?oes.
          

		If !GETMV('IM_FRETE20')  //Se filial n?o utiliza novo frete utilizar regra antiga
			if ALLTRIM(M->UA_OBSFRT)='' .AND. (aValores[4] < M->UA_FRETCAL) .AND. M->UA_TPCIF='CIFD'   ///CIF Destacado
				IF MSGYESNO( 'CIFD - Voce esta cobrando Frete a Menor...Justifique!!!', 'Aten??o - Frete menor que o calculado' )
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
				IF MSGYESNO( 'CIFI - Voce esta cobrando Frete a Menor...Justifique!!!', 'Aten??o - Frete menor que o calculado' )
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
		    
		          
			IF DBSEEK(XFILIAL('SUA')+M->UA_NUM) .AND. !_LPEGATRAN  ///_LPEGTRAN , ve se j?passou pelo transporte
				_NVALSUG:=SUA->UA_FRETCAL
				M->UA_FRETRAN:=SUA->UA_FRETRAN
				M->UA_FRETE:=SUA->UA_FRETE
		              //_LPEGATRAN:=.F.
			ENDIF
		     
			dBSELECTAREA(_AAREA)
		
		          
		
		
		
			if (aValores[4] < _NVALSUG) .AND. M->UA_TPCIF='CIFD'   ///CIF Destacado
				IF _NACOL>1
					ALERT( "Voc?selecionou uma transportadora cujo frete n?o ?o menor entre as transportadoras."+CHR(13)+CHR(13)+"N?o ?poss?vel diminuir o valor do frete neste caso.")
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
					ALERT( "Voc?selecionou uma transportadora cujo frete n?o ?o menor entre as transportadoras."+CHR(13)+CHR(13)+"N?o ?poss?vel diminuir o valor do frete neste caso.")
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


STATIC FUNCTION DPARCULT(cCond) 

//BLOQUEIA CLIENTES COM RISCO IGUAL AO RISCO CONTIDO NO PARAMETRO MV_RISCOBL COM CONDICAO DE PAGAMENTO COM DATA DA ULTIMA PARCELA MAIOR QUE O VALOR DO PARAMETRO MV_DIASULP (45 DIAS)
//AGOSTINHO LIMA - 14/03/2016 - CHAMADO 2454 E 5243.

Local nDias 
Local aParc := {}
Local cCond
Local lOk := .T.

If SA1->A1_RISCO $ GETMV("MV_RISCOBL")


aParc := Condicao(100,cCond,,dDataBase)

nDias := aParc[Len(aParc),1] - dDataBase

   If nDias > GetMv("MV_DIASULP")
   
      MsgAlert("Cliente risco " + SA1->A1_RISCO + " com condi??o de pagamento com data da ?ltima parcela maior que " + ALLTRIM(STR(GetMv("MV_DIASULP"))) +" dias! Bloqueio Financeiro!","Alerta")
      
      lOk := .F.
      
   Endif    


Endif

Return (lOk)



