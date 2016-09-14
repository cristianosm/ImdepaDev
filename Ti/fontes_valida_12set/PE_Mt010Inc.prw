#INCLUDE 'RWMAKE.CH'
#DEFINE CRLF (CHR(13)+CHR(10))
/////
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT010INC  ºAutor  ³Luciano / Marllon   º Data ³  07/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³PE na inclusão de produtos para inclusao de saldo e espelha-º±±
±±º          ³mento do cadastro nas outras filiais                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8 SUPRIMENTOS IMDEPA                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
**********************************************************************
User Function Mt010Inc()
**********************************************************************

Local cMsg, n
Local aDadTOP  		:=	{}

Private	lCorreia 	:=	.F.
Private cB1_COD		:=	IIF(Type('M->B1_COD')=='U', SB1->B1_COD, M->B1_COD)
Private cFam 		:= 	SubStr(cB1_COD,4,2) 		// SubStr(M->B1_COD,4,2)     [ COPIA DE PRODUTO ERRO NA VARIAVEL M->B1_COD NAO EXISTE ]
Private aFiliais
Private cFilEsp
Private _lReplicaSB1 := IsInCallStack("U_REPLICASB1")	// Jean Rehermann - Solutio IT - 18/08/2015 - Verifica se está em execução pelo programa REPLICASB1()
Private lPlanoCorte	 :=	IsInCallStack('U_IMDA641')
Private lCopia		 :=	IsInCallStack('A010COPIA')	
ExecBlock('ChkPosBase',.F.,.F., {'QDADOPAI', Left(cB1_COD,02) })
cBase 	 	:= A093VldBase(cB1_COD)
ExecBlock('ChkPosBase',.F.,.F., {'QDADOPAI',cBase})
lCorrOpen	:=	IIF(AllTrim(cBase)=='02', .T., .F.)
lCorreia 	:= !Empty(cBase)



// cria registro nas tabelas de saldos iniciais e saldos fisico e financeiro...
CriaSaldo( SB1->B1_FILIAL, SB1->B1_COD, SB1->B1_LOCPAD )

// Jean Rehermann - SOLUTIO IT - 20/01/2016 - Sempre cria o saldo no armazém 01
If !_lReplicaSB1
	If SB1->B1_LOCPAD <> "01"
		CriaSaldo( SB1->B1_FILIAL, SB1->B1_COD, "01" )
	EndIf
EndIf
cFilEsp	:= GETMV('MV_FILESP')

//Faz o cadastro na Extensão do Produto ZA7
CriaZA7(cFilAnt, SB1->B1_COD, SB1->B1_CODITE)

If lCorreia
	Reclock("SB1", .F.)
		If Type("nCrps") == Nil .OR. Type("nCrps") == "U" 
		 	SB1->B1_CUSTRP := U_QCSTRPAI( cFam , cB1_COD, "B1_CUSTRP")
		Else
		 	SB1->B1_CUSTRP := nCrps
		EndIf
	MsUnlock()
EndIf	

//|verifica se a filial atual deve ser espelhada...
If ( cFilAnt $ AllTrim( cFilEsp ) )

	// chama funcao que retorna um array contendo as filiais a serem espelhadas...
 	aFiliais := U_RetConteud( AllTrim(cFilEsp) )
	
	Processa( {|| RunProc() }, 'Cadastro de Produtos', 'Incluindo cadastro nas outras filiais...' )

EndIf




//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ FABIANO PEREIRA - 23/02/2016                                 	³
//³ IMPORTACAO .CSV CORREIAS ABERTAS                             	³
//³                                                              	³
//³ EX.: FILIAL 05 IMPORTA .CSV VARIAVEIS cCstd e nCrps NAO ESTAO	³ 	
//³ CONSIDERANDO CUSTO X COMPRIMENTO (DO ARQ. .CSV)              	³
//³ ENTAO APOS REPLICAR PARA OUTRAS FILIAIS VARIAVEIS ESTAO      	³
//³ COM VALORES CORRETOS (SO NAO ESTAVA GRAVANDO CORRETO NA      	³
//³ FILIAL 05 NAS DEMAIS ESTAVA OK)                              	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCorrOpen .And.  IsInCallStack("U_IMDA100")
	Reclock("SB1", .F.)
		SB1->B1_CUSTD  := nCstd	
	 	SB1->B1_CUSTRP := nCrps	
	MsUnlock()
EndIf	



 //Envia um e-mail informativo de novo cadastro de produto
If SB1->B1_TIPO $('PA/PP/IMP') 
	U_IMDA850( SB1->B1_COD, SB1->B1_DESC, SB1->B1_TIPO )
Endif  

//Begin Edivaldo
//Possibilita a Inclusão do Produto Cadastrado na Tabela de Fornecedores

// Jean Rehermann - Solutio IT - 12/08/2015 - Quando origem da inclusão for via programa REPLICASB1() não precisa perguntar  
// Cristiano Oliveira - Solutio IT - 16/09/2015 - Quando a Origem for IMDA100, não perguntar, chamar ImdA10Grv( nOpcao, nTipo, cProduto ) direto
If !_lReplicaSB1
	If FunName() == "IMDA100"
		If Type(cCodPrd) != "N"
	    	U_IMDA100() // U_ImdA10Grv( 1, 1, cCodPrd ) // INCLUSAO, TABELA, PRODUTO
	    EndIf
	Else
		If FunName() <> 'TMKA271'
			If SB1->B1_TIPO <> "PP"	
				op:=MsgBox ("Cadastrar Produto na Tabela de Fornecedores Agora ?","Pergunta...","YESNO")  //Após Incluir produto, executo a chamada da tabela de fornecedores
				if op =.T.
					U_IMDA100()
				Endif
			EndIf				
		EndIf		
	EndIf		
EndIf
//End Begin Edivaldo


//Inclusão tabelas de preço
SB1->(DbGoTo( SB1->( RecNo()) ))

If AllTrim(SB1->B1_TIPO) $ "PA/PP/MP"

	U_IncTabPr()                                                                                              
	
	aDadTOP  := {{ "B1_CUSTRP", "B1_MCUSTRP", "B1_CURVA", "B1_GRMAR3", "B1_GRTRIB", "B1_CLASSVE", "B1_ATIVO", "B1_MSBLQL", "B1_OBSTPES", "B1_PE" }, {} }
         
                    
    aAdd(aDadTOP[2], SB1->B1_CUSTRP )
	aAdd(aDadTOP[2], SB1->B1_MCUSTRP )  
	aAdd(aDadTOP[2],  SB1->B1_CURVA )
	aAdd(aDadTOP[2],  SB1->B1_GRMAR3 )
	aAdd(aDadTOP[2], SB1->B1_GRTRIB )
	aAdd(aDadTOP[2], SB1->B1_CLASSVE )
	aAdd(aDadTOP[2],  SB1->B1_ATIVO )
	aAdd(aDadTOP[2], SB1->B1_MSBLQL )
	aAdd(aDadTOP[2], SB1->B1_OBSTPES )
    aAdd(aDadTOP[2], SB1->B1_PE )   

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



****************************
	ChkDatRef(SB1->B1_COD)
****************************


Return()
**********************************************************************
Static Function RunProc()
**********************************************************************
Local n
Local aCampos  := {}
Local aValores := {}  
Local cCabec   :=' '                                                           
Local cRefer   := ""
Local cCodZon  := "000001"
//|Relacao de campos que nao devem ser espelhados...
Local aCpoNEsp := {	'B1_DATREF','B1_UPRC', 'B1_UCOM', 'B1_PICM', 'B1_CONINI', ;
					'B1_EMIN', 'B1_ESTSEG', 'B1_ESTFOR', 'B1_PE', 'B1_FORPRZ', 'B1_TIPE', 'B1_LE', 'B1_LM',;
					'B1_TOLER','B1_TSPLAN','B1_PICMRET','B1_PICMENT','B1_CURVAPR', IIF(!_lReplicaSB1, 'B1_CUSTRP',''), 'B1_LOCPAD'}

Local nOrd_SB1, nRec_SB1, cProduto
Local _nFilial, __cFilAnt := cFilAnt

Local cOperaWms    := ""   
Local nCriticidade := 1
Local cTitulo      := ' '

Local lTMKA271	   := IsInCallStack('TMKA271')	// CallCenter - TeleVendas

cBase 	 := A093VldBase(cB1_COD)
lCorrOpen:=	IIF(AllTrim(cBase)=='02', .T., .F.)
nTamBase := Len(AllTrim(cBase))
aIdSBQ	 := A093ORetSBQ(cBase)
nPosMat	 := Ascan(aIdSBQ, {|X| AllTrim(X[01]) == 'MAT'})
nPosFam	 := Ascan(aIdSBQ, {|X| AllTrim(X[01]) == 'FAM'})
nPosRef	 := Ascan(aIdSBQ, {|X| AllTrim(X[01]) == 'REF'})
nPosLgr	 := Ascan(aIdSBQ, {|X| AllTrim(X[01]) == 'LRG'})
nPosCom	 := Ascan(aIdSBQ, {|X| AllTrim(X[01]) == 'COM'})
lCheck	 := nPosMat > 0 .And. nPosFam > 0.And. nPosRef > 0 .And. nPosLgr > 0

If lCorrOpen
	Aadd(aCpoNEsp, 'B1_CUSTD')
EndIf

If lCheck
	
	nIniMat := 	nTamBase + 1
	nFimMat	:= 	aIdSBQ[nPosMat][02]

	nIniFam := 	nIniMat+nFimMat
	nFimFam := 	aIdSBQ[nPosFam][02]

	nIniRef := 	nIniFam+nFimFam
	nFimRef := 	aIdSBQ[nPosRef][02]

	nIniLgr := 	nIniRef+nFimRef
	nFimLgr := 	aIdSBQ[nPosLgr][02]
    
	nIniCom := 	nIniLgr+nFimLgr
	nFimCom := 	IIF(nPosCom > 0, aIdSBQ[nPosLgr][02], 0)
		
Else

	// [ BUSCA VALORES DIRETO DA TABELA SBQ  ]
	nIniMat := 	nTamBase+ 1
	nFimMat	:= 	Posicione('SBQ', 2, xFilial('SBQ') + cBase + PadR('MAT',TamSx3('BQ_ID')[1],''), 'BQ_TAMANHO')	//	[01 == 1 | 02 == 1]

	nIniFam := 	nIniMat + nFimMat
	nFimFam := 	Posicione('SBQ', 2, xFilial('SBQ') + cBase + PadR('FAM',TamSx3('BQ_ID')[1],''), 'BQ_TAMANHO')	//	[01 == 2 | 02 == 1]

	nIniRef := 	nIniFam + nFimFam
	nFimRef := 	Posicione('SBQ', 2, xFilial('SBQ') + cBase + PadR('REF',TamSx3('BQ_ID')[1],''), 'BQ_TAMANHO')	//	[01 == 4 | 02 == 3]

	nIniLgr := 	nIniRef + nFimRef 
	nFimLgr := 	Posicione('SBQ', 2, xFilial('SBQ') + cBase + PadR('LRG',TamSx3('BQ_ID')[1],''), 'BQ_TAMANHO')	//	[01 == 4 | 02 == 3]

	nIniCom := 	nIniLgr + nFimLgr
	nFimCom	:=	Posicione('SBQ', 2, xFilial('SBQ') + cBase + PadR('COM',TamSx3('BQ_ID')[1],''), 'BQ_TAMANHO')	//	[        | 02 == 3]

EndIf


cMaterial :=	SubStr(cB1_COD, nIniMat, nFimMat)
cFamilia  :=	SubStr(cB1_COD, nIniFam, nFimFam)
cReferen  :=	SubStr(cB1_COD, nIniRef, nFimRef)
cLarg	  :=	SubStr(cB1_COD, nIniLgr, nFimLgr)
cComp	  :=	SubStr(cB1_COD, nIniCom, nFimCom)
								
// BS_FILIAL+BS_BASE+BS_ID+BS_CODIGO
cRefer 	 += AllTrim(Posicione('SBS', 1, xFilial('SBS') + cBase + PadR('FAM',TamSx3('BS_ID')[1],'') + PadR(cFamilia, TamSx3('BS_CODIGO')[1]), 'BS_DESCR'))+Space(01)
cRefer 	 += AllTrim(Posicione('SBS', 1, xFilial('SBS') + cBase + PadR('REF',TamSx3('BS_ID')[1],'') + PadR(cReferen, TamSx3('BS_CODIGO')[1]), 'BS_DESCR'))+Space(01)
cRefer 	 += AllTrim(Posicione('SBS', 1, xFilial('SBS') + cBase + PadR('LRG',TamSx3('BS_ID')[1],'') + PadR(cLarg,    TamSx3('BS_CODIGO')[1]), 'BS_DESCR'))
If lCorrOpen
	cRefer 	 += +Space(01)+AllTrim(Posicione('SBS', 1, xFilial('SBS') + cBase + PadR('COM',TamSx3('BS_ID')[1],'') + PadR(cComp,TamSx3('BS_CODIGO')[1]), 'BS_DESCR'))
EndIf

DbSelectArea("SB1")
For n := 1 to fCount()
	
	// prepara matriz de campos que serao espelhados
	aAdd( aCampos, FieldName( n ) )
	
	// guarda o registro atual
	aAdd( aValores, FieldGet( n ) )
Next

nOrd_SB1 := SB1->( IndexOrd() )
nRec_SB1 := SB1->( RecNo() )
cProduto := SB1->B1_COD         


cB1CURVA 	:=	SB1->B1_CURVA
cB1CustD	:= 	SB1->B1_CUSTD
cB1CustRp	:= 	SB1->B1_CUSTRP


SB1->( dbSetOrder( 1 ) )

For _nFilial := 1 to Len( aFiliais )
	


	If aFiliais[ _nFilial ] == cFilAnt 
		Loop
	EndIf

	If SB1->( dbSeek( aFiliais[ _nFilial ] + cProduto, .F. ) )			
		MsgBox( 'O produto  ' + AllTrim( cProduto ) + '  nao sera incluido na filial  ' + ;
		aFiliais[ _nFilial ] + ', pois ja se encontra cadastrado na mesma.', 'Atualizacao de Produtos', 'INFO' )
	
		Loop
	EndIf

	If lCorreia
		If Type("nCstd") == Nil .Or. Type("nCstd") == 'U'   
			nCstd := U_QCSTRPAI( cFam , cB1_COD, "B1_CUSTD") 	//	0
		Else
			nCstd := U_QCSTRPAI( cFam , cB1_COD, "B1_CUSTD") 
		EndIf
		
		If Type("nCrps") == Nil .Or. Type("nCrps") == 'U'
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  NAO ESTAVA GRAVANDO B1_CUSTRP QUANDO PRODUTO\SOBRA CRIADO VIA PLANO DE CORTE PARA FILIAL 02 - FABIANO PEREIRA	  ³
			//|  INCLUIDO CHAMADAS VIA TELA DA VERDADE e SIMULACAO DE CONFIG.PRODUTO											  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nCrps := U_QCSTRPAI( cFam , cB1_COD, "B1_CUSTRP") // 0
		Else
			nCrps := U_QCSTRPAI( cFam , cB1_COD, "B1_CUSTRP") 
		EndIf 
    EndIf


	// espelha os campos, menos a filial
	RecLock( 'SB1', .T. )
		// Jean Rehermann - 25/11/2008 - Verifica parametro se filial opera com WMS
		cOperaWms := SuperGetMv( "MV_WMSTPAP", .F., "F", aFiliais[ _nFilial ] )
		For n := 1 to fCount()
			
			If aCampos[ n ] == 'B1_FILIAL'   
				aValores[ n ] := aFiliais[ _nFilial ]
			ElseIf aCampos[ n ] == "B1_CURVAIT"
				    SB1->B1_CURVAIT :="NC"
	  	    ElseIf aCampos[ n ] == "B1_ESTFOR"
	  	    	If SB1->B1_TIPO == "PA"
				    SB1->B1_ESTFOR  :="C04"
				Else
					SB1->B1_ESTFOR  :="C00"
				EndIf
	        ElseIf aCampos[ n ] == "B1_CURVAPR"
	                SB1->B1_CURVAPR :="NC"						    	
	        ElseIf aCampos[ n ] == "B1_CURVA"
	                SB1->B1_CURVA :=CB1CURVA					    	
			ElseIf aCampos[ n ] == "B1_CUSTRP"
	                SB1->B1_CUSTRP := IIF(lCorreia, nCrps, cB1CustRp)
			ElseIf lCorrOpen .And.aCampos[n] == "B1_CUSTD"
	                SB1->B1_CUSTD := IIF(lCorreia, nCstd, cB1CustD)
			// Jean Rehermann - Solutio IT - 05/01/2016 - Trata o campo B1_LOCPAD
			ElseIf aCampos[ n ] == "B1_LOCPAD"
					_cFilLoc 		:= 	cFilAnt
					cFilAnt 		:= 	aFiliais[ _nFilial ]
					SB1->B1_LOCPAD 	:= 	U_IMDA093( "B1_LOCPAD" )
					cFilAnt 		:= 	_cFilLoc
			EndIf
			
			If !lCorreia
				// VERIFICA O PRAZO DE ENTREGA POR FILIAL                                                                
				If     aCampos[ n ] == "B1_ESTFOR" .AND. aFiliais[ _nFilial ] == "02" .AND. SB1->B1_TIPO == "PA"
					SB1->B1_PE := 14 //18
				ElseIf aCampos[ n ] == "B1_ESTFOR" .AND. aFiliais[ _nFilial ] == "04" .AND. SB1->B1_TIPO == "PA"
					SB1->B1_PE := 10 //14
				ElseIf aCampos[ n ] == "B1_ESTFOR" .AND. aFiliais[ _nFilial ] == "05" .AND. SB1->B1_TIPO == "PA"
					SB1->B1_PE := 10 //14
				ElseIf aCampos[ n ] == "B1_ESTFOR" .AND. aFiliais[ _nFilial ] == "06" .AND. SB1->B1_TIPO == "PA"
					SB1->B1_PE := 07 //10
				ElseIf aCampos[ n ] == "B1_ESTFOR" .AND. aFiliais[ _nFilial ] == "09" .AND. SB1->B1_TIPO == "PA"
					SB1->B1_PE := 07 //10
				ElseIf aCampos[ n ] == "B1_ESTFOR" .AND. aFiliais[ _nFilial ] == "13" .AND. SB1->B1_TIPO == "PA"
					SB1->B1_PE := 07 //10
				ElseIf aCampos[ n ] == "B1_ESTFOR" .AND. aFiliais[ _nFilial ] == "14" .AND. SB1->B1_TIPO == "PA"
					SB1->B1_PE := 10 //14
				ElseIf aCampos[ n ] == "B1_ESTFOR"
					SB1->B1_PE := 0
				EndIf
			Else

				//	{{'02',30},{'04',25},{'05',21},{'06',21},{'09',21},{'13',21},{'14',25}}
				aFilPE	:=	&(GetMv('IM_I093PE'))
				nPos 	:= 	Ascan(aFilPE, {|X| X[01] == aFiliais[ _nFilial ]  })

				If nPos > 0 //cTipo == 'PA' .And. nPos > 0
					SB1->B1_PE := aFilPE[nPos][02]
			    Endif
				
			EndIf
			
			//verifica se nao eh algum campo que nao deve ser espelhado...
			If aScan( aCpoNEsp, aCampos[ n ] ) == 0
				// Jean Rehermann - 25/11/2008 - Se filial não opera WMS e o campo for B1_LOCALIZA, grava como "N"
				If( cOperaWms == "F" .And. aCampos[ n ] == "B1_LOCALIZ")
					SB1->B1_LOCALIZ :="N" 
				Else
					Eval( FieldBlock( aCampos[ n ] ), aValores[ n ] )
	    		EndIf
			EndIf
			
		Next
	MsUnLock()

	//|cria registro nas tabelas de saldos iniciais e saldos fisico e financeiro...
	CriaSaldo( SB1->B1_FILIAL, SB1->B1_COD, SB1->B1_LOCPAD )
	
	// Jean Rehermann - SOLUTIO IT - 20/01/2016 - Sempre cria o saldo no armazém 01
	If !_lReplicaSB1
		If SB1->B1_LOCPAD <> "01"
			CriaSaldo( SB1->B1_FILIAL, SB1->B1_COD, "01" )
		EndIf
	EndIf

	//Cria complemento do produto SB5
	U_GravaCmp(SB1->B1_COD, cRefer, cCodZon)

	//Cria a Extensão do Cadastro de Produto para o novo Produto
	CriaZA7( SB1->B1_FILIAL, SB1->B1_COD,SB1->B1_CODITE )

Next _nFilial

SB1->( dbSetOrder( nOrd_SB1 ) )
SB1->( dbGoTo( nRec_SB1 ) )

Return
**********************************************************************
Static Function CriaSaldo( _cFilial, _cProduto, _cLocal )
**********************************************************************

	Local nOrd_SB9, nRec_SB9, nOrd_SB2, nRec_SB2, nFor
	Local cCodBas  := ""  // Código da base do produto correia
	Local _nPosIni := 2   // Tamanho do código conforme estrutura
	Local _aIdSBQ  := {}  // Array com os nomes das características
	Local _aVarSBS := {}  // Array com as especificações das características
	Local _aLrgFil := {}  // Array com Largura do produto filho
	Local _aLrgPai := {}  // Array com Largura do produto pai
	Local nCusPai  := 0   // Custo do produto pai (B2_CM1) na filial 09 e local 02
	Local nCusFil  := 0   // Custo proporcionalizado do produto filho (PP)
	Local _aComPai := {}  // Array com Comprimento do produto pai
	Local _aComFil := {}  // Array com Comprimento do Produto filho
	Local nPropor  := 0   // % de proporção entre a largura do PP para a largura do PA quando for Base = 01 e M2 quando for Base = 02
	
	nOrd_SB9 := SB9->( IndexOrd() )
	nRec_SB9 := SB9->( RecNo() )
	
	nOrd_SB2 := SB2->( IndexOrd() )
	nRec_SB2 := SB2->( RecNo() )
	
	// Jean Rehermann - SOLUTIO IT - 03/02/2016
	// Gravar na tabela SB2, nos produtos tipo PP, o campo B2_CM1, trazido do produto-pai (tipo=PA)
	_aAreaAtu := GetArea()
	
	Iif( Select('SBP') == 0, ( ChkFile('SBP'), DbSelectArea("SBP") ), )
	SBP->( dbGoTop() )
	
	cCodBas := U_A093Base( _cProduto )
	
	dbSelectArea("SBP")
	dbSetOrder(1)
	dbSeek( xFilial("SBP") + cCodBas )
	
	If !Empty( cCodBas ) .And. SB1->B1_TIPO = "PP" // Significa que é correia e produto filho
	
		// Busco a posição
		Iif( Select('SBQ') == 0, ( ChkFile('SBQ'), DbSelectArea("SBQ") ), )
		SBQ->( dbGoTop() )
		_aIdSBQ := A093ORetSBQ( cCodBas )
		
		For nFor := 1 to Len( _aIdSBQ )
			If AllTrim( _aIdSBQ[ nFor, 1 ] ) == "LRG"
				If AllTrim( cCodBas ) == "02"
//					_nPosIni += _aIdSBQ[ nFor, 2 ]
				EndIf
				Exit
			EndIf
			_nPosIni += _aIdSBQ[ nFor, 2 ]
		Next
		
		// Monto a query que vai me bucar o B2_CM1 e B2_COD da filial 09 do produto do tipo PA com as mesmas caracteristicas do PP
		_cSql := " SELECT B2_CM1, B2_COD "
		_cSql += " FROM "+ RetSqlName("SB2")
		_cSql += " WHERE B2_COD = ("
		_cSql += " 		SELECT B1_COD "
		_cSql += " 		FROM "+ RetSqlName("SB1")
		_cSql += " 		WHERE D_E_L_E_T_ = ' ' "
		_cSql += " 			AND B1_FILIAL = '09' " // Fixo na filial de entrada das mantas (PA)
		_cSql += " 			AND SUBSTR(B1_COD,1,"+ Str( _nPosIni, 2, 0 ) +") = '"+ Left( _cProduto, _nPosIni )+"' "
		_cSql += " 			AND B1_TIPO = 'PA' "
		_cSql += " 			AND B1_CUSTD > 0 "
		_cSql += " 			AND B1_PROATIV = 'S' "
		_cSql += " 			AND B1_MSBLQL <> '1' "
		_cSql += " 			AND ROWNUM = 1 ) "
		_cSql += " 	AND B2_FILIAL = '09' " // Fixo na filial de entrada das mantas (PA)
		_cSql += " 	AND B2_LOCAL = '02' " // Fixo no local padrão da filial 09
		_cSql += " 	AND D_E_L_E_T_ = ' ' "

		Iif( Select('TMPCUS') != 0, TMPCUS->( DbCloseArea() ), )
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cSql),"TMPCUS",.T.,.T.)
		TMPCUS->( DBgoTop() )
		
		If !TMPCUS->( Eof() )

			//If TMPCUS->B2_CM1 > 0

				nCusPai := IIF(TMPCUS->B2_CM1 > 0, TMPCUS->B2_CM1, 1)

				_aLrgFil := u_GetUmSBS( _cProduto, "LRG", AllTrim( cCodBas ) == "02" ) // Busca a largura do produto filho
				_aLrgPai := u_GetUmSBS( TMPCUS->B2_COD, "LRG", AllTrim( cCodBas ) == "02" ) // Busca a largura do produto pai

				If AllTrim( cCodBas ) == "02"
					_aComFil := u_GetUmSBS( _cProduto, "COM", .F. ) // Busca o comprimento do produto filho
					_aComPai := u_GetUmSBS( TMPCUS->B2_COD, "COM", .F. ) // Busca o comprimento do produto pai
				EndIf

			//EndIf

		EndIf

		TMPCUS->( dbCloseArea() )

		If AllTrim( cCodBas ) == "01"
			// % da largura do PA
			nPropor := ( _aLrgFil[3] / _aLrgPai[3] )
			nCusFil := Round( nCusPai * nPropor, 2 ) // Custo do filho

		ElseIf AllTrim( cCodBas ) == "02"
			// % do M2 do PA
			nPropor := ( ( _aLrgFil[3] * _aComFil[3] ) / ( _aLrgPai[3] * _aComPai[3] ) )
			nCusFil := Round( nCusPai * nPropor, TamSx3('B2_CM1')[02] ) // Custo do filho
		EndIf

	EndIf
	
	RestArea( _aAreaAtu )

	SB9->( dbSetOrder( 1 ) )
	If SB9->( !dbSeek( _cFilial + _cProduto + _cLocal, .f. ) )
		
		SB9->( RecLock( 'SB9', .t. ) )
		SB9->B9_FILIAL  := _cFilial
		SB9->B9_COD     := _cProduto
		SB9->B9_LOCAL   := _cLocal
		SB9->( MsUnlock() )
	EndIf
	
	// cria registro na tabela de saldos fisico e financeiro...
	SB2->( dbSetOrder( 1 ) )
	If SB2->( !dbSeek( _cFilial + _cProduto + _cLocal, .f. ) )
		
		SB2->( RecLock( 'SB2', .t. ) )
		SB2->B2_FILIAL  := _cFilial
		SB2->B2_COD     := _cProduto
		SB2->B2_LOCAL   := _cLocal
		SB2->B2_CM1     := nCusFil  // Jean Rehermann - SOLUTIO IT - 03/02/2016 - Quando for produto PP de correia
		SB2->( MsUnlock() )
	EndIf
	
	SB9->( dbSetOrder( nOrd_SB9 ) )
	SB9->( dbGoTo( nRec_SB9 ) )
	
	SB2->( dbSetOrder( nOrd_SB2 ) )
	SB2->( dbGoTo( nRec_SB2 ) )
	
	//Atualiza o Codigo do Item na tabela de estoques SB2
	SB1->( U_aTuSB2( _cFilial, _cProduto ) )
	 
Return



/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Inserido por Edivaldo Gonçalves Cordeiro                                                 ³
//³Cria a Extensão do Cadastro de Produto de forma automática na Inclusão de um Novo Produto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC*/

**********************************************
Static Function CriaZA7( _cFilial, _cProduto,cCodite )
**********************************************
Local aSaveArea	:= GetArea()

ZA7->( dbSetOrder( 1 ) ) //ZA7_FILIAL+ZA7_CODPRO

If ZA7->( !dbSeek( _cFilial + _cProduto, .f. ) )
	
	ZA7->( RecLock( 'ZA7', .t. ) )
		ZA7->ZA7_FILIAL := _cFilial
		ZA7->ZA7_CODPRO :=_cProduto
		ZA7->ZA7_CODITE :=cCodite
	 
		
	////JULIO JACOVENKO, em 20/11/2013
	///aqui replicatos os outros campos....
	///com o inicializador padrao     
	    ZA7->ZA7_PQR   ='NC'
	    ZA7->ZA7_PGRAMA='N'
	    ZA7->ZA7_ITEMSE='0' //NC
	    ZA7->ZA7_ITEMCA='0' //NC
	    ZA7->ZA7_ABCMC ='NC'
	    ZA7->ZA7_PQRCLI='NC'
	    ZA7->ZA7_PRCOMA='S'
	    ZA7->ZA7_ABCVRI='NC'
	    ZA7->ZA7_CURVAA='NC'
	    ZA7->ZA7_NIVELS=0
	    ZA7->ZA7_PPCOMP='N'
	    ZA7->ZA7_TPPROM='0'
	    ZA7->ZA7_CVVRIT=0.3
	    ZA7->ZA7_ESTOCP=0
	    ZA7->ZA7_TNDPF =1
	
	    ZA7->ZA7_SAZJAN=1
	    ZA7->ZA7_SAZFEV=1
	    ZA7->ZA7_SAZMAR=1
	    ZA7->ZA7_SAZABR=1 
	    ZA7->ZA7_SAZMAI=1 
	    ZA7->ZA7_SAZJUN=1
	    ZA7->ZA7_SAZJUL=1
	    ZA7->ZA7_SAZAGO=1
	    ZA7->ZA7_SAZSET=1
	    ZA7->ZA7_SAZOUT=1
	    ZA7->ZA7_SAZNOV=1
	    ZA7->ZA7_SAZDEZ=1                
	    
	    ZA7->ZA7_XYZ   ='N'
	    ZA7->ZA7_SUGEST='2'      
	    
	    ZA7->ZA7_FPREVD=IIF(SB1->B1_TIPO=="PP", "D", "T") // PP == D // PA == T
		ZA7->ZA7_CODIT2=cCodite
	
	MsUnlock()
EndIf

RestArea(aSaveArea)

Return Nil
  
**********************************************************************************                                 
// INCLUSAO DA TABELA DE PRECO DE VENDA - DA1 

User Function IncTabPr() 

Local nQuant		:=	1
Local nPosTab		:=	0  
Local aTabs			:= {"OEM", "MNT", "REV"}
Private cArqMemo     :=	''        // Qual planilha vamos usar para calcular    
Private lDirecao     :=	.T.  
Private nQualCusto   := 1
Private cProg        := "C010"
  
aTabelas := &(GetMv('MV_SEGXTAB'))		//	{{"1","OEM"},{"2","MNT"},{"3","REV"}}

For nK := 1 To Len(aTabelas)
	nPosTab := Ascan(aTabelas, {|X| X[2] == aTabs[nK] })
	If nPosTab > 0 
		cArqMemo := aTabelas[nPosTab][02]                                             
	EndIf
		
	If !Empty(cArqMemo)
		If !Empty(SB1->B1_COD)
			Pergunte("MTC010",.F.)
		    //aHeader   := aMyHeader
		    //Pergunte("MTA410",.F.)
            
			************************************************************************* 
			aFormaPrc	:= MC010Forma("SB1",SB1->(Recno()),98,nQuant,1,.F.)
		    
			nPos := Ascan(aFormaPrc, {|X| '#PRECO DE VENDA SUGE'  $  AllTrim(X[3]) }) 
			If nPos > 0
				nPrcBase := aFormaPrc[nPos][6]
			EndIf
			************************************************************************* 
							    
		    DbSelectArea( "SM0" )
			SM0->( DbGoTop() )
			While SM0->( !Eof() )
			    DA1->( dbSetOrder( 1 ) ) //DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM  
			    DA0->( dbSetOrder( 1 ) ) //DA0_FILIAL+DA0_CODTAB
			    dbSelectArea("DA0")
			    If DA0->(MsSeek(SM0->M0_CODFIL+aTabs[nK]))			                         
			    
					*************************************************************************                                                                                     
					DbSelectArea("IM1")
					DbSetOrder(2)
					If DbSeek(SM0->M0_CODFIL + aTabs[nK] + SB1->B1_CURVA) // IM1_FILIAL + IM1_SEGMEN + IM1_COD     
						nPrcBase := SB1->B1_CUSTRP * IM1->IM1_MARKUP
					EndIf
					*************************************************************************
				
				    dbSelectArea("DA1")
					If !DA1->(MsSeek(SM0->M0_CODFIL+aTabs[nK]+SB1->B1_COD))
						RecLock("DA1", .T.)		
							DA1->DA1_FILIAL	:= SM0->M0_CODFIL  
							DA1->DA1_ITEM	:= GETSXENUM("DA1","DA1_ITEM")
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
				SM0->( DbSkip() )
			EndDo
		Else
		     Help(" ",1,"SEMPERM")
		EndIf	           
	EndIf
Next nK	
      

Return()
*********************************************************************
Static Function ChkDatRef(cCodProd)
*********************************************************************
Local xArea   := GetArea()
Local cFilBck := cFilAnt

cFilAnt := '05'
DbSelectArea('SB1');DbSetOrder(1)
If DbSeek(xFilial('SB1') + cCodProd, .F.)
	If Empty(SB1->B1_DATREF)

		// SE UPDATE NAO DER CERTO FAZ COM WHILE...
		
		cSql := "UPDATE "+ RetSqlName("SB1") + " SET B1_DATREF = '"+Space(TamSx3('B1_DATREF')[01])+"' WHERE B1_COD = '"+cCodProd+"' AND D_E_L_E_T_ != '*' " 
		TcSqlExec(cSql)
		If Empty(TcSqlError())
			TcSqlExec('COMMIT')
		Else
			TcSqlExec('ROLLBACK')
			MsgAlert('Erro update B1_DATREF.'+ENTER+'Produto: '+ cCodProd+ENTER+'Erro: '+ TcSqlError())
		EndIf

		RecLock('SB1', .F.)
			SB1->B1_DATREF := dDataBase
		MsUnLock()
				
	EndIf
EndIf

cFilAnt := cFilBck
RestArea(xArea)
Return()