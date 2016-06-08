#INCLUDE "PROTHEUS.CH"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ IMDG008     ³ Autor ³ Jorge Oliveira     ³ Data ³ 30/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcular o desconto de ICMS para os Estados do PR e GO     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_IMDG008()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Valor de desconto do ICMS                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Call Center                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function IMDG008()

	Local aAreaSZW := SZW->( GetArea() )
	Local lCons    := .F.
	Local cTES     := gdFieldGet( "UB_TES", n )
	Local nValDesc := gdFieldGet( "UB_DESCICM", n ) // Pega o valor default do campo
    

	// Tabela de Desconto de ICMS
	DbSelectArea( "SZW" )
	DbSetOrder( 1 )
	
	// linha esta deletada
	If aCols[ n, Len( aHeader )+1 ]
		Return( nValDesc )
	EndIf

	If lProspect

		// Prospect eh do PR e a TES eh 514 e Prospect nao eh Consumidor Final
		If ( SUS->US_EST == "PR" .And. cFilAnt == "13" .And. cTES == "514" .And. SUS->US_TIPO <> "F" .And. SB1->B1_GRTRIB <> '001'  )
		
			If SZW->( DbSeek( xFilial( "SZW" ) + "PR" + "PR" ) )
				lCons    := .T.
			EndIf
			
	
		// Prospect eh do GO e a TES eh 540 e Prospect nao eh Consumidor Final    
		ElseIf ( SUS->US_EST == "GO" .And. cFilAnt == "04" .And. cTES  $ '540/721' .And. SUS->US_TIPO <> "F" .And. SB1->B1_GRTRIB <> '001' )
		
	 		If SZW->( DbSeek( xFilial( "SZW" ) + "GO" + "GO" ) )
	  			lCons    := .T. 
			EndIf
			
		EndIf
		
	
	// Cliente					
	Else
	
	
		// Cliente eh do PR e a TES eh 514 e Cliente nao eh Consumidor Final
		If ( SA1->A1_EST == "PR" .And. cFilAnt == "13" .And. cTES == "514" .And. SA1->A1_TIPO <> "F" .And. SB1->B1_GRTRIB <> '001' )
		
			If SZW->( DbSeek( xFilial( "SZW" ) + "PR" + "PR" ) )
				lCons    := .T.
			EndIf
	
		// Cliente eh do GO e a TES eh 540 e Cliente nao eh Consumidor Final
		ElseIf ( SA1->A1_EST == "GO" .And. cFilAnt == "04" .And. cTES $ '540/721' .And. SA1->A1_TIPO <> "F" .And. SB1->B1_GRTRIB <> '001' )
		
		 	If SZW->( DbSeek( xFilial( "SZW" ) + "GO" + "GO" ) )
		 		lCons    := .T. 
		 	EndIf
			
		EndIf
		
	EndIf
	

	If lCons					
///JULIO JACOVENKO....
///21/12/2012 - PARA AJUSTAR DESCONTO ICM
      LIMP:=.F.
      CPRODUTO:=SB1->B1_COD
      cIMPNAC:=SA1->(POSICIONE('SB1',1,XFILIAL('SB1')+CPRODUTO,'B1_ORIGEM'))           
	  LIMP:=(CIMPNAC='1' .OR. CIMPNAC='2')

   if !LIMP //e nacional
	nValDesc	:= SZW->ZW_DESCONT
   else     //e importado
	nValDesc	:= SZW->ZW_DESCIMP
   endif                          

		//nValDesc := SZW->ZW_DESCONT
		
		GDFieldPut( "UB_DESCICM", nValDesc, N )
		GDFieldPut( "UB_VDESICM", U_IMDG240(), N )// declarada em IMDF240.PRW

	EndIf

   RestArea( aAreaSZW )

Return( nValDesc )
