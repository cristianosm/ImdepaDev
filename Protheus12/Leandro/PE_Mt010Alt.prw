#include 'rwmake.ch'
/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: Mt010Alt     || Autor: Luciano Corrêa        || Data: 07/05/03  ||
||-------------------------------------------------------------------------||
|| Descrição: PE na alteração de produtos para espelhamento do cadastro    ||
||            nas outras filiais                                           ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function Mt010Alt()


	Local cMsg, n
	Local aDadTOP  := {}
	
	// Na Versão P12 só deve executar quando chamado apartir do A010TOK, por que o Mt010Alt foi descontinuado o MVC.
	If Alltrim(ProcName(1)) <> "U_A010TOK"
		Return()
	EndIf
		
	//Alert("Entrou Mt010Alt")
	
	Private aFiliais
	Private cMvFilEsp := GetNewPar( 'MV_FILESP', '' , Space(02) ) 

	If ( cFilAnt $ cMvFilEsp )
		// chama funcao que retorna um array contendo as filiais a serem espelhadas...
		aFiliais := U_RetConteud( AllTrim( cMvFilEsp ) )

		Processa( {|| RunProc() }, 'Cadastro de Produtos', 'Alterando cadastro nas outras filiais...' )
		///JULIO JACOVENKO - 31/10/2012
		///REPLICA ZA7

	EndIf

//Inclusão tabelas de preço
SB1->(DbGoTo( SB1->( RecNo()) ))

If AllTrim(SB1->B1_TIPO) $ "PA/PP/MP"

	IncTabPr()

//| CHAMADO: 13311 - Replica CURVA IMDEPA
//aDadTOP  := {{ "B1_CUSTRP", "B1_MCUSTRP", "B1_CURVA", "B1_GRMAR3", "B1_GRTRIB", "B1_CLASSVE", "B1_ATIVO", "B1_MSBLQL", "B1_OBSTPES" }, {} }
aDadTOP  := {{ "B1_CUSTRP", "B1_MCUSTRP", "B1_GRMAR3", "B1_GRTRIB", "B1_CLASSVE", "B1_ATIVO", "B1_MSBLQL", "B1_OBSTPES" }, {} }         
                    
    aAdd(aDadTOP[2], SB1->B1_CUSTRP )
	aAdd(aDadTOP[2], SB1->B1_MCUSTRP )  
	//aAdd(aDadTOP[2],  SB1->B1_CURVA ) //| CHAMADO: 13311 - Replica CURVA IMDEPA
	aAdd(aDadTOP[2],  SB1->B1_GRMAR3 )
	aAdd(aDadTOP[2], SB1->B1_GRTRIB )
	aAdd(aDadTOP[2], SB1->B1_CLASSVE )
	aAdd(aDadTOP[2],  SB1->B1_ATIVO )
	aAdd(aDadTOP[2], SB1->B1_MSBLQL )
	aAdd(aDadTOP[2], SB1->B1_OBSTPES )
      

DbSelectArea("ZLP")
      
For nI := 1 To Len(aDadTOP[2])   
	If ValType(aDadTOP[2, nI]) <> "L"                      
		RECLOCK("ZLP", .T.)
		           
		ZLP->ZLP_FILIAL		:= xFilial("SB1")
		ZLP->ZLP_TABELA		:= "SB1"  
		ZLP->ZLP_REGIST     := SB1->(Recno())
		ZLP->ZLP_PROD       := Alltrim( SB1->B1_COD )
		ZLP->ZLP_CAMPO		:= Alltrim( aDadTOP[1, nI] )
		ZLP->ZLP_CONTEU 	:= Iif( ValType( aDadTOP[2, nI] ) == "N",  Alltrim( Str(aDadTOP[2, nI]) ), Alltrim(aDadTOP[2, nI]) )
		ZLP->ZLP_CONTAT		:= Iif( ValType( &("SB1->"+aDadTOP[1, nI]) ) == "N",  Alltrim( Str(&("SB1->"+aDadTOP[1, nI])) ), Alltrim(&("SB1->"+aDadTOP[1, nI])) )
		ZLP->ZLP_DATA  		:= dDatabase             
		ZLP->ZLP_HORA 		:= SUBSTR(TIME(), 1, 5) 
		ZLP->ZLP_USER 		:= Alltrim( UsrRetName(RetCodUsr()) )
		ZLP->ZLP_STYLE		:= "A"
		
		ZLP->(MSUNLOCK()) 
	EndIf
Next nI  





EndIf


Return


*******************************************************************************
Static Function RunProc()


Local n
Local aCampos  := {}
Local aValores := {} 
Local cOperaWms := ""
// relacao de campos que nao devem ser espelhados...
/*
Local aCpoNEsp := { 'B1_FILIAL','B1_COD','B1_DATREF','B1_UPRC','B1_UCOM','B1_PICM','B1_CONINI',;
					'B1_EMIN', 'B1_ESTSEG', 'B1_PE', 'B1_FORPRZ','B1_TIPE','B1_LE','B1_LM',;
					'B1_TOLER','B1_TSPLAN','B1_PICMRET','B1_PICMENT','B1_ESTFOR','B1_CURVAPR'}
*/


Local aCpoNEsp := {'B1_FILIAL','B1_COD','B1_DATREF','B1_UPRC','B1_UCOM','B1_PICM','B1_CONINI',;
					'B1_EMIN', 'B1_ESTSEG', 'B1_ESTFOR', 'B1_PE', 'B1_FORPRZ','B1_TIPE','B1_LE','B1_LM',;
					'B1_TOLER','B1_TSPLAN','B1_PICMRET','B1_PICMENT','B1_CURVAPR','B1_CURVA','B1_LOCPAD'} //| CHAMADO: 13311 - Replica CURVA IMDEPA


Local nOrd_SB1, nRec_SB1, cProduto
Local _nFilial 
     

DbSelectArea("SB1")
For n := 1 to SB1->( fCount() )
	
	// prepara matriz de campos que serao espelhados
	aAdd( aCampos, FieldName( n ) )
	
	// guarda o registro atual	
	aAdd( aValores, FieldGet( n ) )
Next

nOrd_SB1 := SB1->( IndexOrd() )
nRec_SB1 := SB1->( RecNo() )
cProduto := SB1->B1_COD                 
//CB1CURVA := SB1->B1_CURVA


SB1->( dbSetOrder( 1 ) )

For _nFilial := 1 to Len( aFiliais )

//Atualiza o CodItem na tabela de estoques SB2
 SB1->(U_aTuSB2(aFiliais[ _nFilial ],cProduto))


 	If aFiliais[ _nFilial ] == cFilAnt
		Loop
	EndIf
	
	If SB1->( !dbSeek( aFiliais[ _nFilial ] + cProduto, .f. ) )
		Loop
	EndIf
	
	// espelha os campos, menos a filial
	SB1->( RecLock( 'SB1', .F. ) )
	// Jean Rehermann - 25/11/2008 - Verifica parametro se filial opera com WMS
	cOperaWms := SuperGetMv( "MV_WMSTPAP", .F., "F", aFiliais[ _nFilial ] )
	For n := 1 to fCount()
	

		  // IF ACAMPOS[N]=="B1_CURVA"
		  //    SB1->B1_CURVA:=CB1CURVA
          // ENDIF
		// verifica se nao eh algum campo que nao deve ser espelhado...
		If aScan( aCpoNEsp, aCampos[ n ] ) == 0 
		   
		   
			// Jean Rehermann - 25/11/2008 - Se filial não opera WMS e o campo for B1_LOCALIZA, grava como "N".
			// Jean Rehermann - 26/11/2008 - Se alteração for de filial com B1_LOCALIZ = "N", faz o teste.
			If( cOperaWms == "F" .And. aCampos[ n ] == "B1_LOCALIZ")
				SB1->B1_LOCALIZ := "N"
			Else
				If( aCampos[ n ] == "B1_LOCALIZ" )
					SB1->B1_LOCALIZ := "S"
				Else
					//U_CaixaTexto(VarInfo("aCampos", aCampos, Nil, .T., .F. ))
					Eval( FieldBlock( aCampos[ n ] ), aValores[ n ] )
				EndIf
    		EndIf

		EndIf
		
	Next
	SB1->( MsUnLock() )
	
Next _nFilial    

aTuZA8(cFilAnt,cProduto)

// 12/07/2010 - Incluído por Jean Rehermann
aTuZA7(cFilAnt,cProduto)

SB1->( dbSetOrder( nOrd_SB1 ) )
SB1->( dbGoTo( nRec_SB1 ) )


//JULIO JACOVENKO - 31/12/2012
///////////PARA REPLICAR EXTENSAO DE PRODUTOS

///////



Return


**********************************************
Static Function aTuZA8(_cFilial,_cProduto )
**********************************************
Local aSaveArea	:= GetArea()

ZA8->( dbSetOrder( 1 ) ) 
 
If ZA8->( dbSeek( _cProduto, .f. ) )
	ZA8->( RecLock( 'ZA8', .F. ) )
	ZA8->ZA8_CODITE  := SB1->B1_CODITE
	ZA8->( MsUnlock() )
EndIf

RestArea(aSaveArea)

Return

// 12/07/2010 - Incluído por Jean Rehermann
// Ao alterar o produto, altera na ZA7 (bloqueio automático)
**********************************************
Static Function aTuZA7(_cFilial,_cProduto )
**********************************************
	Local _aSaveArea	:= GetArea()
	
	ZA7->( dbSetOrder( 1 ) ) 
	 
	If ZA7->( dbSeek( _cProduto, .f. ) )
		ZA7->( RecLock( 'ZA7', .F. ) )
		ZA7->ZA7_MSBLQL  := SB1->B1_MSBLQL
		ZA7->( MsUnlock() )
	EndIf
	
	RestArea( _aSaveArea )

Return

**********************************************
User Function aTuSB2(_cFilial,_cProduto )
**********************************************

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³aTuSB2 ºAutor  ³Edivaldo Gonçalves    º Data ³  16/11/09    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza Codigo do Item na SB2                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gerenciamento Preço de Venda                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Local aSaveArea	:= GetArea()


DbSelectArea("SB2")

SB2->( dbSetOrder( 1 ) ) // produto + local + filial


If SB2->( DbSeek(_cFilial+_cProduto,.F.))
  
     While !Eof() .And. _cFilial+_cProduto = B2_FILIAL+B2_COD

      SB2->( RecLock( 'SB2', .F. ) )
      SB2->B2_CODITE:=SB1->B1_CODITE
      SB2->( MsUnlock() )

	     DbSkip()
     End
  	
Endif
	
RestArea(aSaveArea)

Return
****************************************************************
Static Function IncTabPr() 
****************************************************************
Local nQuant		:=	1
Local nPosTab		:=	0
Local aTabs			:= {"OEM", "MNT", "REV"}
Local cFilBck		:=	cFilAnt
Local cCodProd		:= 	SB1->B1_COD
Private cArqMemo    :=	''        // Qual planilha vamos usar para calcular
Private lDirecao    :=	.T.
Private nQualCusto  := 1
Private cProg       := "C010"


If MsgYesNo("Deseja atualizar tabelas de preço?")
	
	aTabelas := &(GetMv('MV_SEGXTAB'))		//	{{"1","OEM"},{"2","MNT"},{"3","REV"}}
	
	If SB1->B1_MSBLQL == "1" //sim
		For nK := 1 To Len(aTabelas)
			DbSelectArea( "SM0" )
			SM0->( DbGoTop() )
			While SM0->( !Eof() )
				DA1->( dbSetOrder( 1 ) ) //DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
				DA0->( dbSetOrder( 1 ) ) //DA0_FILIAL+DA0_CODTAB
				dbSelectArea("DA0")
				If DA0->(MsSeek(SM0->M0_CODFIL+aTabs[nK]))
					dbSelectArea("DA1")
					If DA1->(MsSeek(SM0->M0_CODFIL+aTabs[nK]+SB1->B1_COD))
						RecLock("DA1", .F.)
						
						DA1->DA1_ATIVO	:= "2"
						
						DA1->( MsUnlock() )
					EndIf
				EndIf
				SM0->( DbSkip() )
			EndDo
		Next nK
	Else
		
		For nK := 1 To Len(aTabelas)
			
			nPosTab := Ascan(aTabelas, {|X| X[2] == aTabs[nK] })
			If nPosTab > 0
				cArqMemo := aTabelas[nPosTab][02]
			EndIf
			
			If !Empty(cArqMemo)
				
				//If !Empty(SB1->B1_COD)

				// chama funcao que retorna um array contendo as filiais a serem espelhadas...
				//aFiliais := u_RetConteud( AllTrim( SX6->X6_CONTEUD ) )
					
					For nX := 1 To Len(aFiliais)
						
						cFilAnt	:= aFiliais[nX] 
						
						DbSelectArea("SM0");DbSetOrder(1);DbGoTop()
						If DbSeek(cEmpAnt + cFilAnt, .F.) //Do While SM0->(!Eof())
							
							
							DbSelectArea('SB1');DbSetOrder(1)
							If DbSeek(cFilAnt + cCodProd, .F.)
							
								Pergunte("MTC010",.F.)
								aFormaPrc	:= MC010Forma("SB1",SB1->(Recno()),98,nQuant,1,.F.)
								//aHeader   := aMyHeader
								//Pergunte("MTA410",.F.)
								
								nPos := Ascan(aFormaPrc, {|X| '#PRECO DE VENDA SUGE'  $  AllTrim(X[3]) })
								If nPos > 0
								
									nPrcBase := aFormaPrc[nPos][6]
										
									
									DA1->(DbSetOrder(1)) //DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
									DA0->(DbSetOrder(1)) //DA0_FILIAL+DA0_CODTAB
									DbSelectArea("DA0")
									If DA0->(MsSeek(SM0->M0_CODFIL+aTabs[nK]))
										DbSelectArea("DA1")
										If DA1->(MsSeek(SM0->M0_CODFIL+aTabs[nK]+SB1->B1_COD))
											RecLock("DA1", .F.)
												DA1->DA1_PRCVEN	:= nPrcBase * IIF(DA1->DA1_PERDES > 0, DA1->DA1_PERDES, 1 )
												DA1->DA1_MOEDA 	:= 1        //CESARMMVal(SB1->B1_MCUSTRP)
												//DA1->DA1_MOEDA 	:= Val(SB1->B1_MCUSTRP)      // Rodrigo, para ficar igual a formula da formação de preços 09/07/2015
												DA1->DA1_ATIVO	:= "1"
											DA1->( MsUnlock() )
										Else
											
											RecLock("DA1", .T.)
												DA1->DA1_FILIAL	:= SM0->M0_CODFIL
												DA1->DA1_ITEM	:= GetSxeNum("DA1","DA1_ITEM")
												DA1->DA1_CODTAB	:= aTabs[nK]
												DA1->DA1_CODPRO	:= SB1->B1_COD
												DA1->DA1_PRCVEN	:= nPrcBase
												DA1->DA1_MOEDA 	:= 1			//CESARMM Val(SB1->B1_MCUSTRP)
												DA1->DA1_ATUMAN	:= 1
												DA1->DA1_ATIVO	:= "1"
												DA1->DA1_TPOPER	:= "4"
												DA1->DA1_QTDLOT	:= 999999.99
												DA1->DA1_DATVIG	:= dDatabase
											DA1->( MsUnlock() )
										EndIf
									EndIf
								
								EndIf
		
							EndIf
	
							//SM0->(DbSkip())						
						//EndDo
						EndIf
					Next
					
					
				//Else
				//	Help(" ",1,"SEMPERM")
				//EndIf
				
			EndIf
		Next nK
		
	EndIf

EndIf

cFilAnt := cFilBck
Return()