#Include "Totvs.ch"
#Include "Protheus.ch" 
#Include "ApWebSrv.ch"
#Include "Tbiconn.ch"
#Include "Topconn.ch"
#Include "Rwmake.ch"
#include "ap5mail.ch" 
/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: FT080GRV     || Autor: Bernardo Andréia        || Data: 30/04/15  ||
||-------------------------------------------------------------------------||
|| Descrição: PE após gravação das regras de desconto, grava LOGS          ||
||              	                                  				      ||
||-------------------------------------------- -----------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function FT080GRV()
 
Local aAreaZLP := GetArea()  
Local aDadACO 	:= {{"ACO_DESCRI", "ACO_CODCLI", "ACO_LOJA", "ACO_CODTAB", "ACO_CONDPG", "ACO_FORMPG", "ACO_FAIXA", ;
						"ACO_MOEDA", "ACO_PERDES", "ACO_VINCUL", "ACO_GRPVEN", "ACO_CLASVE", "ACO_TPHORA", "ACO_HORADE", "ACO_HORATE", "ACO_DATDE", "ACO_DATATE"},{}}
Local aDadACP 	:= {}					

Local nPACP_ITEM 	:= GDFieldPos("ACP_ITEM "  , aHeader  ) // [01]
Local nPACP_CODPRO 	:= GDFieldPos("ACP_CODPRO" , aHeader  ) // [02]
Local nPACP_ALI 	:= GDFieldPos("ACP_ALI_WT" , aHeader  ) // [15]
Local nPACP_REC 	:= GDFieldPos("ACP_REC_WT" , aHeader  ) // [16]


//Válida alterações cabeçalho   
If ALTERA .OR. INCLUI
	For nI := 1 To Len(aACO)
		aAdd(aDadACO[2], Iif(&(M->aDadACO[1][nI]) <>	aACO[nI], aACO[nI], .F.	) )         
	Next nI 
Else
	For nI := 1 To Len(aACO)
 		aAdd(aDadACO[2], aACO[nI] )  
 	Next nI 
EndIf
     

DbSelectArea("ZLP")
//Salva LOG cabeçalho      
For nI := 1 To Len(aDadACO[2])   
	If ValType(aDadACO[2, nI]) <> "L"                      
		RECLOCK("ZLP", .T.)
		           
		ZLP->ZLP_FILIAL		:= xFilial("ACO")
		ZLP->ZLP_TABELA		:= "ACO"  
		ZLP->ZLP_REGIST     := ACO->(Recno())
		ZLP->ZLP_PROD       := ""
		ZLP->ZLP_CAMPO		:= Alltrim( aDadACO[1, nI] )
		ZLP->ZLP_CONTEU 	:= Iif( ValType( aDadACO[2, nI] ) == "N",  Alltrim( Str(aDadACO[2, nI]) ), Iif(ValType( aDadACO[2, nI] ) == "D", DToS(aDadACO[2, nI]),Alltrim(aDadACO[2, nI])) )
		ZLP->ZLP_CONTAT		:= Iif( ValType( &(M->aDadACO[1][nI]) ) == "N",  Alltrim( Str(&(M->aDadACO[1][nI])) ), Iif(ValType( &(M->aDadACO[1][nI]) ) == "D", DToS( &(M->aDadACO[1][nI]) ),Alltrim(&(M->aDadACO[1][nI]))) )
		ZLP->ZLP_DATA  		:= dDatabase
		ZLP->ZLP_HORA 		:= SUBSTR(TIME(), 1, 5) 
		ZLP->ZLP_USER 		:= Alltrim( UsrRetName(RetCodUsr()) )  
		ZLP->ZLP_STYLE		:= Iif(INCLUI , "I" , Iif(ALTERA, "A", "E") )
		 
		ZLP->(MSUNLOCK()) 
	EndIf
Next nI    
 
aSIZE(aACP, Len(aCols)) 

BeginSql Alias 'TMPACP'
	SELECT MAX(ACP.R_E_C_N_O_) RECLAST
	from %Table:ACP% ACP
	where 
	ACP_FILIAL = %xFilial:ACP%
	and ACP.%notdel%
EndSql	  

//Válida alterações itens
For nX := 1 To Len(aCols) 
	If ValType(aACP[nX]) == "U" 
		aACP[nX] := {}
		aSIZE(aACP[nX], 9) 
	EndIf
	
	aDadACP 	:= {{"ACP_CODPRO", "ACP_GRUPO", "ACP_PERDES", "ACP_FAIXA", "ACP_FAIXDE", "ACP_FAIXAT", "ACP_GRMAR3", "ACP_CURVA" },{}}	 
	ACP->( dbSetOrder(1) )
	ACP->( msSeek(xFilial("ACP")+M->ACO_CODREG+aCols[nX][nPACP_ITEM] ) )				
	If aCols[nX][nPACP_REC] .OR. aCols[nX][nPACP_ALI] > TMPACP->RECLAST .OR. aCols[nX][nPACP_ALI] == 0    
		For nZ := 1 To Len(aACP[nX])-1
			aAdd(aDadACP[2], aACP[nX, nZ])	 	  
		Next nZ
	Else
   		For nZ := 1 To Len(aACP[nX])-1
	  		aAdd(aDadACP[2], Iif(aCols[nX][ Ascan(aHeader,{|x| Alltrim(x[2])==aDadACP[1][nZ]}) ] <>	aACP[nX][nZ], aACP[nX][nZ], .F.	) )
   		Next nZ
	EndIf
	
	//Salva LOG Itens
	For nY := 1 To Len(aDadACP[2])
		If ValType(aDadACP[2, nY]) <> "L"
			RECLOCK("ZLP", .T.)
			
			ZLP->ZLP_FILIAL		:= xFilial("ACP")
			ZLP->ZLP_TABELA		:= "ACP"
			ZLP->ZLP_REGIST     := aACP[nX][9]
			ZLP->ZLP_PROD       := aCols[nX][nPACP_CODPRO]
			ZLP->ZLP_CAMPO		:= Alltrim( aDadACP[1, nY] )
			ZLP->ZLP_CONTEU 	:= Iif( ValType( aDadACP[2, nY] ) == "N",  Alltrim( Str(aDadACP[2, nY]) ), Iif(ValType( aDadACP[2, nY] ) == "D", DToS(aDadACP[2, nY]),Alltrim(aDadACP[2, nY])) )
			ZLP->ZLP_CONTAT		:= Iif( ValType( aCols[ nX, Ascan(aHeader,{|x| Alltrim(x[2])==aDadACP[1, nY]}) ] ) == "N",  Alltrim( Str(aCols[ nX, Ascan(aHeader,{|x| Alltrim(x[2])==aDadACP[1, nY]}) ]) ), Iif(ValType( aCols[ nX, Ascan(aHeader,{|x| Alltrim(x[2])==aDadACP[1, nY]}) ] ) == "D", DToS(aCols[ nX, Ascan(aHeader,{|x| Alltrim(x[2])==aDadACP[1, nY]}) ]),Alltrim(aCols[ nX, Ascan(aHeader,{|x| Alltrim(x[2])==aDadACP[1, nY]}) ])) )
			ZLP->ZLP_DATA  		:= dDatabase         
			ZLP->ZLP_HORA 		:= SUBSTR(TIME(), 1, 5)
			ZLP->ZLP_USER 		:= Alltrim( UsrRetName(RetCodUsr()) )  
			ZLP->ZLP_STYLE		:= Iif(aCols[nX][Len(aCols[nX])] , "E" , Iif(aCols[nX][nPACP_ALI] > TMPACP->RECLAST .OR. aCols[nX][nPACP_ALI] == 0 ,"I", "A") )
																			
			ZLP->(MSUNLOCK())
		EndIf
	Next nY
		
Next nX 

TMPACP->(dbCloseArea())

RestArea(aAreaZLP)

Return



  



