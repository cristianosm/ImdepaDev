#Include 'Totvs.ch'

#Define _CODINV_ '000000' 

*******************************************************************************
User Function GetCodFor()
*******************************************************************************
	
	Local aArea		:= GetArea()
	Local aTrigger  := {}
	Local cVarDisp  := ReadVar()
	
	Public oNewCodFo := Nil 
	
	If cVarDisp == "M->A2_CGC"
	
		oNewCodFo := oGetCodFor():New( Alltrim( M->A2_CGC ) )
	
	ElseIf cVarDisp == "M->A2_CLASFOR"
	
		oNewCodFo := oGetCodFor():New( Alltrim( M->A2_CLASFOR ) )
		
	EndIf
	
//	Alert( "oNewCodFo:cCodNew: " 	+ oNewCodFo:cCodNew	 )                                      
//	Alert( "oNewCodFo:cLojNew: " 	+ oNewCodFo:cLojNew  )                                      
//	Alert( "oNewCodFo:cNome: " 		+ oNewCodFo:cNome    )                                      
//	Alert( "oNewCodFo:cNReduz: " 	+ oNewCodFo:cNReduz  )                                      
//	Alert( "oNewCodFo:cClassF: " 	+ oNewCodFo:cClassF  )                                        
//	Alert( "oNewCodFo:cTipo: " 		+ oNewCodFo:cTipo  	 )                                        
//	Alert( "oNewCodFo:cConta: " 	+ oNewCodFo:cConta   )                                      
//	Alert( "oNewCodFo:cNaturez: " 	+ oNewCodFo:cNaturez )       

//	If( ValType(oNewCodFo:cCodNew 	) == "C" , M->A2_COD 	:= oNewCodFo:cCodNew	, "" )                                      
//	If( ValType(oNewCodFo:cLojNew 	) == "C" , M->A2_LOJA	:= oNewCodFo:cLojNew  	, "" )    

	If( ValType(oNewCodFo:cNome   	) == "C" , M->A2_NOME 	:= oNewCodFo:cNome    	, "" )                                      
	If( ValType(oNewCodFo:cNReduz 	) == "C" , M->A2_NREDUZ	:= oNewCodFo:cNReduz  	, "" )                                      
	If( ValType(oNewCodFo:cClassF	) == "C" , M->A2_CLASFOR:= oNewCodFo:cClassF 	, "" )                                        
	If( ValType(oNewCodFo:cTipo  	) == "C" , M->A2_TIPO 	:= oNewCodFo:cTipo  	, "" )                                        
	If( ValType(oNewCodFo:cConta  	) == "C" , M->A2_CONTA 	:= oNewCodFo:cConta   	, "" )                                      
	If( ValType(oNewCodFo:cNaturez	) == "C" , M->A2_NATUREZ:= oNewCodFo:cNaturez 	, "" )                                      
	
	RestArea( aArea ) 

Return( oNewCodFo:lValido )
*******************************************************************************
Class oGetCodFor 
*******************************************************************************
	Export:
	Data cCodNew 	as String
	Data cLojNew 	as String
	Data cCNPJ 		as String
	Data cCPF 		as String
	Data cClassF 	as String
	Data cPjPf  	as String
	Data cTipo		as String
	
	Data cNReduz	as String
	Data cNome		as String
	Data cNaturez	as String
	Data cConta		as String
	
	Data lValido	as Logical 
	
	//| Metodos PUBLICOS
	Method New( cPjPf ) Constructor  //| inicializa as variaveis e define se eh pj ou pf
	
	//| Metodos PRIVADOS
	Hidden:
	Method _GetC() 		//| Obtem o codigo a ser utilizado
	Method _qryc() 		//| executa uma query para ver a disponibilizado do codigo
	Method _ValCod() 	//| valida se o codigo encontrado e valido.
	Method _GetD()      //| Obtem os DADos do cadastro ja existente
	Method _GetL()      //| Obtem a loja Adequada 
	Method _GetN() 		//| Obtem novo codigo, pois nao possui cadastro com mesmo cnpj
	
EndClass
*******************************************************************************
Method New( cPjPf ) Class oGetCodFor //| Inicializa as Variaveis e Define se eh PJ ou PF
*******************************************************************************
	
	Self:lValido := .T.
	
	If len(alltrim(cPjPf)) == 14
		Self:cCNPJ		:= cPjPf
		Self:cCPF		:= Space(11)
		Self:cTipo     	:= "J"
	ElseIf len(alltrim(cPjPf)) == 11
		Self:cCNPJ		:= Space(14)
		Self:cCPF		:= cPjPf
		Self:cTipo      := "F"
	ElseIf len(alltrim(cPjPf)) == "E"
		Self:cCNPJ		:= Space(14)
		Self:cCPF		:= Space(14)
		Self:cClassF    := "E"
		Self:cTipo      := "X"
	Else
		Self:cCNPJ		:= Space(14)
		Self:cCPF		:= Space(11)
		Self:cTipo      := " "
		Self:lValido 	:= .F.
	EndIf
	
	If Self:lValido .And. Inclui // só executa na inclusao e caso seja informado um cnpj ou cpf valido
	
		Self:cCodNew	:= Space(TamSx3("A2_COD")[2])
		Self:cLojNew	:= Space(TamSx3("A2_LOJA")[2])
		Self:cClassF	:= Space(TamSx3("A2_CLASFOR")[2])
		Self:cNReduz	:= Space(TamSx3("A2_NREDUZ")[2])
		Self:cNome		:= Space(TamSx3("A2_NOME")[2])
		Self:cNaturez	:= Space(TamSx3("A2_NATUREZ")[2])
		Self:cConta		:= Space(TamSx3("A2_CONTA")[2])
		
		Self:_GetC() // Obtem codigo
		
		If Self:_ValCod()// codigo valido ?
			
			Self:_GetD() // Obtem os Dados do Outro Cadastro
			
			Self:_GetL() // Obtem a loja Adequada
	
		Else
			
			Self:_GetN() // Obtem novo codigo, pois nao possui cadastro com mesmo cnpj/cpf
			
			Self:_GetL() // Obtem a loja Adequada
			
		EndIf
	
	EndIf
	
Return Self
*******************************************************************************
Method _GetC() Class oGetCodFor //| verIfica o codigo a ser utilizado..
*******************************************************************************

	Local cSql 	:= ""
	
	cSql += "SELECT Nvl(Max(a2_cod),'"+_CODINV_+"') CODIGO FROM SA2010 " 
	cSql += "WHERE a2_filial  	= '"+xfilial("sa2")+"' "
	If !Empty(Self:cCNPJ)
		cSql += "And   SubStr(a2_cgc,1,8) 	= '"+ SubStr(Self:cCNPJ,1,8) +"' "
	ElseIf !Empty(Self:cCPF)
		cSql += "And   a2_cgc 	= '"+ AllTrim(Self:cCPF) +"' "
	EndIf
	cSql += "And   d_e_l_e_t_ 	= ' ' "
	
	U_ExecMySQL( cSql , cCursor := "TAB" , cmodo := "Q" , lmostra := .F. , lchange := .F. )
	
	Self:cCodNew := TAB->CODIGO
	
	DbSelectArea("TAB");DbCloseArea()
	
Return Self
*******************************************************************************
Method _ValCod() Class oGetCodFor //| VerIfica o codigo a ser utilizado..
*******************************************************************************

	Local lValido := .F.
	
	If Self:cCodNew == _CODINV_
		lValido := .F.
    Else
     	lValido := .T.
	EndIf
	
Return lValido
*******************************************************************************
Method _GetD() Class oGetCodFor //| Obtem os DADos do cadastro ja existente
*******************************************************************************

	Local cSql 	:= ""

	cSql += "SELECT A2_COD, A2_LOJA, A2_CLASFOR, A2_NREDUZ, A2_NOME, A2_NATUREZ, A2_CONTA "
	cSql += "FROM SA2010 "
	cSql += "WHERE A2_COD = '"+Self:cCodNew+"' "
	cSql += "AND   A2_LOJA = (SELECT MAX(A2_LOJA) FROM SA2010 WHERE A2_FILIAL = '"+xFilial("SA2")+"' AND A2_COD = '"+Self:cCodNew+"') "
	cSql += "AND   D_E_L_E_T_ = ' ' "

	U_ExecMySQL( cSql , cCursor := "DAD" , cmodo := "Q" , lmostra := .F. , lchange := .F. )

	If !Empty(M->A2_CLASFOR)
		Self:cClassF	:= M->A2_CLASFOR
	Else
		Self:cClassF	:= DAD->A2_CLASFOR
	EndIf
	
	Self:cNReduz	:= DAD->A2_NREDUZ
	Self:cNome		:= DAD->A2_NOME
	Self:cNaturez	:= DAD->A2_NATUREZ
	Self:cConta		:= DAD->A2_CONTA
	Self:cLojNew   	:= DAD->A2_LOJA  // Pega a Loja usada para obter os Dados, eh temporario depois a Loja vai ser Atualizada... 
	 
	DbSelectArea("DAD");DbCloseArea()
	
Return Self
*******************************************************************************
Method _GetL() Class oGetCodFor //| Monta a Loja Adequada, para ser usada... 
*******************************************************************************
	Local cSql   := ""
	Local lAchou := .F.
	Local cAchou := " "
	
	If Self:cTipo == "J" //| Juridico
		cAchou := SA2->( Posicione( "SA2", 3, xFilial("SA2")+Self:cCNPJ, "A2_CGC" ) )
		Alert("cAchou PJ : " + cAchou )
		If cAchou == Self:cCNPJ
			lAchou := .T.
		EndIf
		
	ElseIf Self:cTipo == "F" //| Juridico //| Fisico
		cAchou := SA2->( Posicione( "SA2", 3, xFilial("SA2")+Self:cCPF , "A2_CGC" ) )
		If cAchou == Self:cCPF
			lAchou := .T.
		EndIf
	EndIf
	
	
	If lAchou //| Se ja existe o CNPJ ou CPF Cadastrado deve montar sequencial 
		
		cSql := "SELECT NVL( TO_CHAR( MIN( A2_LOJA ) - 1 , '99'),'" + Replicate( '9', Len(Self:cLojNew) ) + "') LOJA FROM SA2010 WHERE A2_FILIAL = ' ' AND A2_COD = '" + Self:cCodNew + "' AND A2_LOJA > '80' AND D_E_L_E_T_ = ' ' "
		
		U_ExecMySQL( cSql , cCursor := "LOJ" , cmodo := "Q" , lmostra := .T. , lchange := .F. )
		
		Alert("LOJ->LOJA : " + LOJ->LOJA )
		
		Self:cLojNew := LOJ->LOJA // StrZero( Val( Self:cLojNew ) + 1 , 2 )     //| Loja Sequencial
		
		DbSelectArea("LOJ");DbCloseArea()

		
	ElseIf Self:cTipo == "J"
		Self:cLojNew := SubStr( Self:cCNPJ , 11, 2 ) //Loja 

	ElseIf Self:cTipo == "F"
		Self:cLojNew := "00" //Loja 
	
	ElseIf Self:cTipo == "X"
			Self:cLojNew := "01" //Loja 
		
	EndIf

Return Self
*******************************************************************************
Method _GetN() Class oGetCodFor // Obtem novo codigo, pois nao possui cadastro com mesmo cnpj/cpf
*******************************************************************************

	Local cSql 		:= ""

	If !Empty(M->A2_CLASFOR)
		Self:cClassF	:= M->A2_CLASFOR
	Else
		Self:cClassF	:= "N"
	EndIf
	
	cSql += "SELECT MAX( A2_CLASFOR ) || TRIM(TO_CHAR(MAX(SUBSTR( A2_COD ,2 ,5 ) ) + 1 , '99999') ) AS A2_COD "
    cSql += "FROM SA2010 "
	cSql += "WHERE A2_FILIAL = '  ' "
	cSql += "AND   A2_CLASFOR = '"+Self:cClassF+"' "
	cSql += "AND   D_E_L_E_T_ = ' ' "

	U_ExecMySQL( cSql , cCursor := "COD" , cmodo := "Q" , lmostra := .F. , lchange := .F. )

	Self:cCodNew := COD->A2_COD
	Self:cLojNew := Replicate("0" , Len(Self:cLojNew) )
	
	DbSelectArea("COD");DbCloseArea()

Return Self
