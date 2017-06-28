#Include 'protheus.ch'
#Include 'parmtype.ch'

#Define _SAVE .F. //| Parametro usado no cGetFile
#Define _OPEN .T. //| Parametro usado no cGetFile

#Define _ENTER CHR(13)+CHR(10)

#Define _READ_       0 //
#Define _WRITE_      1
#Define _READ_WRITE_ 2

// Posicoes dos campos
#Define PC_COD       1
#Define PC_LOJA      2
#Define PC_GERVEN    3
#Define PC_VENDCOO   4
#Define PC_VENDEXT   5
#Define PC_VEND      6

// Cargo Cadastro  Vendedores
#Define G_VEND	 	'2' // Vendedor
#Define G_VENDEXT  	'1' // Externo
#Define G_VENDCOO  	'3' // Coordenador
#Define G_GERVEN   	'5' // Gerente

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : SM_ADA    | AUTOR : Cristiano Machado | DATA : 05/05/2017      **
**---------------------------------------------------------------------------**
** DESCRIÇÃO: Imporata Arquivo para Alterar Vendedor e/ou Gerente ( SA1 )    **
**            no Cadastro de Clientes...                                     **
**---------------------------------------------------------------------------**
** USO : Especifico para Imdepa Rolamentos                                   **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
** ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                         **
**---------------------------------------------------------------------------**
** PROGRAMADOR | DATA | MOTIVO DA ALTERACAO                                  **
**---------------------------------------------------------------------------**
**             |      |                                                      **
**             |      |                                                      **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User Function ImptGerVenC()
*******************************************************************************

	CriaVariaveis() // Cria todas as Variavaies necessárias
	
	If VerAcesso()// Verifica se o Nivel do Usuario eh Suficiente 
	
		oProcess := MsNewProcess():New({|lEnd| Executa(lEnd)},"Alteração...","Lendo...",.T.)
		oProcess:Activate()
	
	EndIf

	RestArea(aAreaSA1)
	RestArea(aAreaATU)
	
Return Nil
*******************************************************************************
Static Function VerAcesso() // Verifica se o Nivel do Usuario eh Suficiente 
*******************************************************************************
	Local cCodUser	:= RetCodUsr()
	Local cCodVen   := Posicione("SA3",7,xFilial("SA3")+cCodUser,"A3_COD")
	
	If Empty(cCodVen)
		Iw_MsgBox("Seu usuário deve possuir cadatro de Vendedor Relacionado!!!","Cadastro não localizado...","ALERT")
		Return .F.
	EndIf

	//| Verifica se o Usuario pode ver todos os vendedores da filial
	nNvlVen := Val(Posicione("SA3",1,xFilial("SA3")+cCodVen,"A3_NVLVEN"))
	If nNvlVen < 3 //| [1-INTERNO, 2-EXTERNO, 3-COORDENADOR, 4-CHEFE, 5-GERENTE, 6-DIRETOR]
		Iw_MsgBox("Seu Cadastro de Vendedor Relacionado deve possuir Nivel Superior a Vendedor...","Privilégio Insuficinte !!!","ALERT")
		Return .F.
	EndIf

Return .T. 
*******************************************************************************
Static Function Executa(lEnd)	
*******************************************************************************
	
	Local cPathFile 	:= ""
	
	oProcess:SetRegua1(0)
	oProcess:SetRegua2(0)

	oProcess:IncRegua1("Carregando Arquivo para a Memória...")	
	If Pergunta(@cPathFile) // Obter o Local do Arquivo....

		oProcess:IncRegua1("Validando o Arquivo...")
		If ValCabArq(cPathFile)  // Valida Estrutura de Cabecalho do Arquivo...

			If Iw_MsgBox("Importar arquivo "+cPathFile+" com "+cValToChar(Len(aDet))+" Registros","Confirma ? ", "YESNO" )
			
				oProcess:SetRegua1(1)
				oProcess:SetRegua2(Len(aDet))
				
				oProcess:IncRegua1("Importanto Arquivo: "+cPathFile+"...")
				For nI := 1 To Len(aDet) // Percorre Linhas
					cLinha := cValToCHar( nI + 1)
					VerItem(aDet[nI]) //| Valida, Prepara e Lança e efetua a alteração
				Next
				Iw_MsgBox(cValToChar(nRegAtu)+" Registros foram alterados com Sucesso !!!", "Fim do Processamento...","INFO")
			EndIf
			
		Else
			Iw_MsgBox("Cabeçalho deve Possuir Codigo do Cliente(A1_COD), Loja(A1_LOJA) e os vendedores que serão alterados... Avaliar arquivo e tentar novamente. ", "Cabeçalho do arquivo Inválido !!!","ALERT")
		EndIf
			//| Finalisa o LOG 
			cTexto := _ENTER + _ENTER + "FIM IMPORTACAO --> " + cValToChar(dDataBase) + " " + Time() + _ENTER ; SlvLog( cTexto )
			Iw_MsgBox("Log Salvo em "+cFilLog,"Veja o LOG para maires informações","INFO")
			FClose(nHFile)
	EndIf

	Return Nil
*******************************************************************************
Static Function CriaVariaveis() // Cria todas as Variavaies necessárias
*******************************************************************************

	_SetOwnerPrvt( 'oProcess'	, Nil ) //| Objeto para uso na Regua de processamento
	_SetOwnerPrvt( 'nHFile'		,  0  ) // Handle para arquivo LOG 
	_SetOwnerPrvt( 'cLinha' 	, ''  ) //| Numero da linha atual em formado texto 
	_SetOwnerPrvt( 'nRegAtu'  	, 0   )  //| Numero de registros alterados
	
	// Tratamento de Areas 
	_SetOwnerPrvt( 'aAreaATU'	, {} ) //| Area Atual
	aAreaATU := GetArea()
	
	_SetOwnerPrvt( 'aAreaSA1'	, {} ) //| Area Cliente 
	aAreaSA1 := SA1->(GetArea())
	DbSelectArea("SA1");DbSetOrder(1);DbGotop()

	// Arrays Auxiliares  
	_SetOwnerPrvt( 'aCab'		, {} ) //| Contem o cabecalho do arquivo CSV
	_SetOwnerPrvt( 'aDet'		, {} ) //| Contem os itens do arquivo CSV
	_SetOwnerPrvt( 'cFilLog'	, "" ) //| Contem os itens do arquivo CSV

	//| Campos [C]->Cadastro Cliente
	_SetOwnerPrvt( 'C_GERVEN'	, "" ) //| Conteudo do campo no Cliente
	_SetOwnerPrvt( 'C_VENDCOO'	, "" ) //| Conteudo do campo no Cliente
	_SetOwnerPrvt( 'C_VENDEXT'	, "" ) //| Conteudo do campo no Cliente
	_SetOwnerPrvt( 'C_VEND'		, "" ) //| Conteudo do campo no Cliente
	_SetOwnerPrvt( 'C_COD'		, "" ) //| Conteudo do campo no Cliente
	_SetOwnerPrvt( 'C_LOJA'		, "" ) //| Conteudo do campo no Cliente

	//| Campos [A]->Arquivo csv
	_SetOwnerPrvt( 'A_GERVEN'	, "" ) //| Conteudo do campo no Vendedor ou Arquivo
	_SetOwnerPrvt( 'A_VENDCOO'	, "" ) //| Conteudo do campo no Vendedor ou Arquivo
	_SetOwnerPrvt( 'A_VENDEXT'	, "" ) //| Conteudo do campo no Vendedor ou Arquivo
	_SetOwnerPrvt( 'A_VEND'		, "" ) //| Conteudo do campo no Vendedor ou Arquivo

	//| Campos [L]->Valida se vai ser alterado 
	_SetOwnerPrvt( 'L_GERVEN'	, .F. ) //| Valida se o campo Gerente vai ser alterado
	_SetOwnerPrvt( 'L_VENDCOO'	, .F. ) //| Valida se o campo Coordenador vai ser alterado
	_SetOwnerPrvt( 'L_VENDEXT'	, .F. ) //| Valida se o campo Vend Externo vai ser alterado
	_SetOwnerPrvt( 'L_VEND'		, .F. ) //| Valida se o campo Vendedor Interno vai ser alterado

	//| Campos [P]->Posicao do campo no Arquivo
	_SetOwnerPrvt( 'P_COD'  	,  0  ) //| Posicao do Campo no arquivo Texto
	_SetOwnerPrvt( 'P_LOJA'  	,  0  ) //| Posicao do Campo no arquivo Texto
	_SetOwnerPrvt( 'P_GERVEN'	,  0  ) //| Posicao do Campo no arquivo Texto
	_SetOwnerPrvt( 'P_VENDCOO'	,  0  ) //| Posicao do Campo no arquivo Texto
	_SetOwnerPrvt( 'P_VENDEXT'	,  0  ) //| Posicao do Campo no arquivo Texto
	_SetOwnerPrvt( 'P_VEND'		,  0  ) //| Posicao do Campo no arquivo Texto

	Return Nil
*******************************************************************************
Static Function Pergunta(cPathFile) // Pergunta Local do arquivo...
*******************************************************************************

	Local cMascara 	:= "Arquivo Layout (.csv)|*.csv" 	//| Caracter Indica o nome do arquivo ou mascara.
	Local cTitulo 	:= "Selecione o arquivo..."			//| Caracter Indica o título da janela. Caso o parametro não seja especificado, o título padrão será apresentado.
	Local nMascPad 	:= 0 								//| Numérico Indica o número da mascara.
	Local cDirIni 	:= "\" 								//| Caracter Indica o diretório inicial.
	Local lSalvar 	:= _SAVE 							//| lógico Indica se é um "save dialog - (.F.)" ou um "open dialog - .T. ".
	Local nOpcoes 	:= GETF_LOCALHARD 					//| Numérico Indica a opção de funcionamento. Para mais informaçães das funcionalidades disponíveis, consulte a Área Observaçães.
	Local lArvore 	:= .F. 								//| lógico Indica se, verdadeiro (.T.), apresenta o arvore do servidor; caso contrário, falso (.F.).
	Local lKeepCase := .T. 								//| lógico Indica se, verdadeiro (.T.), mantém o case original; caso contrário, falso (.F.).

	Local lReturn   := .T.

	cPathFile := cGetFile( cMascara, cTitulo, nMascpad, cDirIni, lSalvar, nOpcoes, lArvore, lKeepCase)

	If Empty(cPathFile)
		lReturn   := .F.
	Else 
		cFilLog	 := Substr(cPathFile,1,Len(cPathFile)-4) + "_H"+StrTran(Time(),':','.')+".log"
		CriaFLog()//| Cria Arquivo de Log
		OpenFile(cPathFile) // Abre o arquivo ...
	EndIf

	Return lReturn
*******************************************************************************
Static Function CriaFLog( )//| Cria Arquivo de LOG
*******************************************************************************

	Local nModo			:= 2 //| 0-> READ | 1-> WRITE | 2-> READ_WRITE |
	Local cBuffer		:= ""
	Local lChangeCase	:= .T. //| Case sensitive .T. , .F. |

	nHFile	:= FCreate(cFilLog, nModo)

	cTexto := "INICIO IMPORTACAO --> " + cValToChar(dDataBase) + " " + Time() + _ENTER + _ENTER + _ENTER; SlvLog( cTexto )

	Return Nil
*******************************************************************************
Static Function SlvLog( cTexto )	//Salva Log Arquivo
*******************************************************************************

	FWrite(nHFile, cTexto, Len(cTexto))

	Return Nil
*******************************************************************************
Static Function OpenFile(cPathFile) // Abre o arquivo ...
*******************************************************************************

	Local cArq 			:= cPathFile
	Local nModo 		:= _READ_
	Local lChangeCase 	:= .T.	//| Case sensitive .T. , .F. |
	Local nHandle 		:=  0
	Local cLine 		:= ""
	Local cTexto 		:= ""
	Local lPril			:= .T.  // Primeira Linha
	Local nTamC			:= 0

	FT_FUse(cArq)
	FT_FGoTop()

	While !FT_FEOF()

		cLine := StrTran(FT_FREADLN(),'"','') //| Retira as aspas duplas da String

		FT_FSkip()

		If Alltrim(cLine) == Replicate( ";" , nTamC ) // Remove linhas Vazias
			Loop
		EndIf

		While AT(";;",cLine) > 0
			cLine := StrTran(cLine,';;',"; ;")
		EndDo

		If lPril
			aCab :=  StrTokArr(cLine,";")
			nTamC := Len(aCab) - 1
		Else
			AAdd( aDet, StrTokArr(cLine,";") ) //| Converte a Linha para Array
		EndIf

		lPril	:= .F.

	EndDo

	FT_FUse()
	FClose(nHandle)

	Return Nil
*******************************************************************************
Static Function ValCabArq()  // Valida Estrutura de Cabecalho do Arquivo...
*******************************************************************************

	Local cCAMPOS  := "A1_COD/A1_LOJA/A1_GERVEN/A1_VENDCOO/A1_VENDEXT/A1_VEND"
	Local cCpoCli  := "A1_COD/A1_LOJA"
	Local lValCab  := .T. //
	Local nCpoCli  :=  0  // Campos do Cliente
	Local nCpoVen  :=  0  // Campos do Vendedor

	For nI := 1 To Len(aCab)
		
		If  ( aCab[nI] $ cCpoCli )
			nCpoCli += 1
		Elseif ( aCab[nI] $ cCAMPOS )
			nCpoVen += 1
		EndIf

	Next

	// Valida se os dois campos do clientes se encontram no arquivo...
	If !(nCpoCli == 2) .Or. (nCpoVen <= 0)
		lValCab := .F.
	EndIf

	If lValCab
		AjusArquivo()
	Else
		cTexto := "ERRO --> " + " Cabeçalho do arquivo Inválido. " + _ENTER ; SlvLog(cTexto)
		cTexto := "ERRO --> " + " Cabeçalho deve contar A1_COD e A1_LOJA além dos campos de vendedores a serem alterados... " + _ENTER ; SlvLog(cTexto)
	EndIf


	Return lValCab
*******************************************************************************
Static Function AjusArquivo() // Ajusta os Dados com os tamanhos Corretos...
*******************************************************************************

	Local nTamCpo 	:= 0

	//| Define os campos  Envolvidos e e suas posicoes
	P_COD   	:= Ascan(aCab,{|x| AllTrim(x) == "A1_COD"		})
	P_LOJA  	:= Ascan(aCab,{|x| AllTrim(x) == "A1_LOJA"		})
	P_GERVEN	:= Ascan(aCab,{|x| AllTrim(x) == "A1_GERVEN"	})
	P_VENDCOO	:= Ascan(aCab,{|x| AllTrim(x) == "A1_VENDCOO"	})
	P_VENDEXT	:= Ascan(aCab,{|x| AllTrim(x) == "A1_VENDEXT"	})
	P_VEND		:= Ascan(aCab,{|x| AllTrim(x) == "A1_VEND"		})

	L_GERVEN 	:= If( P_GERVEN  > 0 , .T. , .F.  )
	L_VENDCOO 	:= If( P_VENDCOO > 0 , .T. , .F.  )
	L_VENDEXT 	:= If( P_VENDEXT > 0 , .T. , .F.  )
	L_VEND 		:= If( P_VEND    > 0 , .T. , .F.  )

	For nI := 1 To Len(aDet) // Percorre Itens

		For nC := 1 To Len(aDet[nI]) // Percorre Cabecalho

			nTamCpo := (TamSX3(aCab[nC]))[1]

			aDet[nI][nC] := PadL( aDet[nI][nC] , nTamCpo, '0' )

		Next

	Next

	Return Nil
*******************************************************************************
Static Function VerItem(aItem) //| Valida, Prepara e Lança e efetua a alteração
*******************************************************************************

	//Posiciona no Cliente
	DbSelectArea("SA1")
	If DbSeek(xFilial("SA1")+aItem[P_COD]+aItem[P_LOJA],.F.)

	MntChArq(aItem) // Monta a Chave do Arquivo

	MntChCli() // Monta a Chave do Cliente que vai ser atualizado
	
	oProcess:IncRegua2("Alterando Cliente: "+C_COD+"-"+C_LOJA+" ...")
	
	If ValAlt() // Valida se a alteração eh possivel ...

		AltItem()

	EndIf
	Else
		MntLogL(aItem[P_COD],aItem[P_LOJA])
	EndIf

	Return Nil
*******************************************************************************
Static Function MntChArq(aItem) // Monta a Chave do Cliente apartir do Arquivo
*******************************************************************************

	If( L_VEND    , A_VEND 		:= aItem[P_VEND] 	, "" )
	If( L_VENDEXT , A_VENDEXT 	:= aItem[P_VENDEXT] , "" )
	If( L_VENDCOO , A_VENDCOO 	:= aItem[P_VENDCOO] , "" )
	If( L_GERVEN  , A_GERVEN 	:= aItem[P_GERVEN] 	, "" )

	Return Nil
*******************************************************************************
Static Function MntChCli() // Monta a Chave do Cliente que vai ser atualizado
*******************************************************************************

	C_COD		:= Alltrim(SA1->A1_COD)
	C_LOJA		:= Alltrim(SA1->A1_LOJA)

	C_VEND		:= Alltrim(SA1->A1_VEND)
	C_VENDCOO	:= Alltrim(SA1->A1_VENDCOO)
	C_VENDEXT	:= Alltrim(SA1->A1_VENDEXT)
	C_GERVEN	:= Alltrim(SA1->A1_GERVEN)

	Return Nil
*******************************************************************************
Static Function ValAlt() // Valida se alteração eh possivel ...
*******************************************************************************

	Local lValGer := .T.	//| Valida Alteração Gerente
	Local lValVen := .T.	//| Valida Alteração Vendedor
	Local lValCar := .T.	//| Valida Cargo do Vendedor
	Local lReturn := .T.	//| Retorno Final das Validações

	If L_GERVEN 	// Alteração de Gerente...
		lValCar := ValCargo( A_GERVEN 	, G_GERVEN)
		lValGer := VAltGer()
	EndIF

	If lValGer .And. lValCar // Alteração Gerente Valida....

		If L_VEND .And. lValVen	.And. lValCar .And. A_VEND <> "VAZIO"	// Alteração de Vendedor...
			lValCar := ValCargo( A_VEND	, G_VEND)
			lValVen	:= VAltVen( A_VEND )
		EndIF
		If L_VENDEXT .And. lValVen	.And. lValCar .And. A_VENDEXT <> "VAZIO"	  	// Alteração de Vendedor Externo...
			lValCar := ValCargo( A_VENDEXT, G_VENDEXT)
			lValVen	:= VAltVen( A_VENDEXT )
		EndIF
		If L_VENDCOO .And. lValVen	.And. lValCar  .And. A_VENDCOO <> "VAZIO"		 	// Alteração de Coordenador...
			lValCar := ValCargo( A_VENDCOO, G_VENDCOO)
			lValVen	:= VAltVen( A_VENDCOO )
		EndIf

	EndIf

	If !lValGer .Or. !lValVen .Or. !lValCar
		lReturn := .F.
	EndIf
	
	//| Alert(" lValGer = "+ cValToChar(lValGer) + " lValVen = "+ cValToChar(lValVen) + " lValCar = "+ cValToChar(lValCar))

	Return lReturn
*******************************************************************************
Static Function ValCargo(cCodVen , cCargoD ) // Valida se o Cargo do Vendedor esta Correto no Cadastro de Vendedores
*******************************************************************************
	Local cCargoV := ""
	Local lVal 	  := .F.
	
	cCargoV := Posicione( "SA3", 1, xFilial("SA3")+cCodVen, "A3_NVLVEN" )

	If cCargoV == cCargoD
		lVal := .T.
	ElseiF !Empty(cCodVen)
		MntLogC(cCodVen, cCargoD,cCargoV)
	EndIf

	Return lVal
*******************************************************************************
Static Function VerC(cCargo)// Converte Codigo do Cargo em Descricao 
*******************************************************************************
Local cDesCargo := "" 
	
	If 		cCargo == G_VEND
		cDesCargo := "VENDEDOR"
	
	ElseIf 	cCargo == G_VENDEXT
		cDesCargo := "V.EXTERNO"
	
	ElseIf 	cCargo == G_VENDCOO
		cDesCargo := "COORDENADOR"
	
	ElseIf 	cCargo == G_GERVEN
		cDesCargo := "GERENTE"
	
	EndIf
	
Return cDesCargo
*******************************************************************************
Static Function VAltGer()// Valida em caso de Alteração de Gerente se o mesmo pode ser alterado...
*******************************************************************************
	Local lVal 		:= .T.
	Local cGerSup 	:= "" // Gerente Superior Conforme Cadastro do Vendedor....
	Local bValGer   := {|| lVal := If(cGerSup == A_GERVEN, .T. , .F. )} 
	Local cCVeAux   := ""

	If lVal //| Vendedor
		If( L_VEND , cCVeAux := A_VEND , cCVeAux := C_VEND ) // Alteração de Coordenador...
		cGerSup := Posicione( "SA3", 1, xFilial("SA3")+cCVeAux, "A3_GEREN" )
		If(!Empty(cCVeAux),Eval(bValGer),'')
		If(!lVal , MntLogG("VENDEDOR", cCVeAux, A_GERVEN),'')
	EndIf

	If lVal //| Externo
		If( L_VENDEXT , cCVeAux := A_VENDEXT , cCVeAux := C_VENDEXT ) // Alteração de Coordenador...
		cGerSup := Posicione( "SA3", 1, xFilial("SA3")+cCVeAux, "A3_GEREN" )
		If(!Empty(cCVeAux), Eval(bValGer), '')
		If(!lVal , MntLogG("EXTERNO", cCVeAux, A_GERVEN),'')
	EndIf

	If lVal //| Coordenador
		If( L_VENDCOO , cCVeAux := A_VENDCOO , cCVeAux := C_VENDCOO ) // Alteração de Coordenador...
		cGerSup := Posicione( "SA3", 1, xFilial("SA3")+cCVeAux, "A3_GEREN" )
		If(!Empty(cCVeAux),Eval(bValGer),'')
		If(!lVal , MntLogG("COORDENADOR", cCVeAux, A_GERVEN),'')
	EndIf

	Return lVal
*******************************************************************************
Static Function VAltVen(cCodVen) //| Valida se eh possivel alterar o Vendedor
*******************************************************************************
	Local cCodGer := If(L_GERVEN,A_GERVEN,C_GERVEN)
	Local cCodGA3 := Posicione( "SA3", 1, xFilial("SA3")+cCodVen,"A3_GEREN")
	Local lVal 	  := .T.

	If cCodGer <> cCodGA3
		lVal := .F.
		MntLogV(cCodVen, cCodGer,cCodGA3)
	EndIf

	Return lVal
*******************************************************************************
Static Function AltItem() //| Efetua a alteração do Item...
*******************************************************************************

	Local cUpd 	 := "Update SA1010 Set "
	Local cWhere := " Where A1_COD = '"+C_COD+"' And A1_Loja = '"+C_LOJA+"' "

	If L_VEND 
		cUpd += " A1_VEND = '" + IIF(A_VEND=='VAZIO',' ',A_VEND) + "' ,"
	EndIF
	If L_VENDEXT
		cUpd += " A1_VENDEXT = '" + IIF(A_VENDEXT=='VAZIO',' ',A_VENDEXT) + "' ,"
	EndIf
	If L_VENDCOO
		cUpd += " A1_VENDCOO = '" + IIF(A_VENDCOO=='VAZIO',' ',A_VENDCOO) + "' ,"
	EndIf
	If L_GERVEN
		cUpd += " A1_GERVEN = '" + A_GERVEN + "' ,"
	EndIf
	
	cUpd := Substr(cUpd,1,Len(cUpd)-1)
	cUpd += cWhere
	
	U_ExecMySql( cUpd , cCursor := "" , cModo := "E" , lMostra := .F. , lChange := .F. )

	//Sincroniza Entidades (Prospect e Clientes) 
	U_IATUADL( "SA1", C_COD, C_LOJA, "X" )

	nRegAtu += 1
	
Return Nil
*******************************************************************************	
Static Function MntLogC(cCodVen, cCargoD,cCargoV)// Monta Log Cargo
*******************************************************************************

	cTexto := "NÃO ALTERADO --> CLIENTE:"+ C_COD +" LOJA:"+ C_LOJA+" REGISTRO:"+cLinha+"    MOTIVO..." + _ENTER ; SlvLog(cTexto)
	cTexto := "                 Alteração do "+VerC(cCargoD)+" ["+cCodVen+"]. Em seu cadastro de Vendedores ele esta defindo " + _ENTER ; SlvLog(cTexto)
	cTexto := "                 como Cargo:"+VerC(cCargoV)+" . Por Favor, Corrigir o Cadastro. " + _ENTER  + _ENTER + _ENTER  ; SlvLog(cTexto)
	
Return Nil
*******************************************************************************	
Static Function MntLogV(cCodVen, cCodGer,cCodGA3)// Monta Log Alteracao do Cliente
*******************************************************************************

	cTexto := "NÃO ALTERADO --> CLIENTE:"+ C_COD +" LOJA:"+ C_LOJA+" REGISTRO:"+cLinha+"    MOTIVO..." + _ENTER ; SlvLog(cTexto)
	cTexto := "                 Vendedor ["+cCodVen+"] possui outro Gerente em seu cadastro. " + _ENTER ; SlvLog(cTexto)
	cTexto := "                 Gerente Cadastro do Vendedor: ["+cCodGA3+"].    Gerente Cliente/Arquivo : ["+cCodGer+"] " + _ENTER  + _ENTER + _ENTER  ; SlvLog(cTexto)
	
Return Nil
*******************************************************************************	
Static Function MntLogG(cQuem ,cCVeAux, A_GERVEN)// Monta Log Alteracao do Gerente
*******************************************************************************

	cTexto := "NÃO ALTERADO --> CLIENTE:"+ C_COD +" LOJA:"+ C_LOJA+" REGISTRO:"+cLinha+"    MOTIVO..." + _ENTER ; SlvLog(cTexto)
	cTexto := "                 Gerente ["+A_GERVEN+"] não é Gerente do "+cQuem+" ["+cCVeAux+"] no Cadastro de Vendedor. " + _ENTER + _ENTER + _ENTER ; SlvLog(cTexto)
		
Return Nil
*******************************************************************************	
Static Function MntLogL(cCod, CLoja)
*******************************************************************************

	cTexto := "NÃO ALTERADO --> CLIENTE:"+ cCod +" LOJA:"+ CLoja+" REGISTRO:"+cLinha+"    MOTIVO..." + _ENTER ; SlvLog(cTexto)
	cTexto := "                 Cadastro do cliente não encontrado... " + _ENTER + _ENTER + _ENTER ; SlvLog(cTexto)

Return