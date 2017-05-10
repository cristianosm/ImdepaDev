#Include 'protheus.ch'
#Include 'parmtype.ch'

#Define _SAVE .F. //| Parametro usado no cGetFile
#Define _OPEN .T. //| Parametro usado no cGetFile

#Define _READ_       0 //
#Define _WRITE_      1
#Define _READ_WRITE_ 2

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

	Local cPathFile := ""

	CriaVariaveis() // Cria todas as Variavaies necessárias

	If Pergunta(@cPathFile) // Obter o Local do Arquivo....

		If ValArquivo(cPathFile) // Valida se o arquivo esta correto...

			AjusArquivo() // Ajusta o Arquivo e converte em array...

		EndIf

	EndIf


	Return Nil
*******************************************************************************
Static Function AjusArquivo() // Ajusta o Arquivo e converte em array...
*******************************************************************************

		Local nTamCpo 	 := 0

		//| Define os campos  Envolvidos e e suas posicoes 
		nPA1_COD   		:= Ascan(aCab,{|x| AllTrim(x) == "A1_COD"		})
		nPA1_LOJA  		:= Ascan(aCab,{|x| AllTrim(x) == "A1_LOJA"		})
		nPA1_GERVEN		:= Ascan(aCab,{|x| AllTrim(x) == "A1_GERVEN"	})
		nPA1_VENDCOO	:= Ascan(aCab,{|x| AllTrim(x) == "A1_VENDCOO"	})
		nPA1_VENDEXT	:= Ascan(aCab,{|x| AllTrim(x) == "A1_VENDEXT"	})
		nPA1_VEND		:= Ascan(aCab,{|x| AllTrim(x) == "A1_VEND"		})

		For nI := 1 To Len(aDet)
		
			For nC := 1 To Len(aDet[nI])
			
				nTamCpo := ( TamSX3(aCab[nC]) )[1]
				
				aDet[nI][nC] := PadL( aDet[nI][nC] , nTamCpo, '0' )

			Next
			
			VerItem(aDet[nI]) // Lança Item...
		
		Next


	Return Nil
*******************************************************************************
Static Function VerItem(aItem) // Monta as Chaves
*******************************************************************************
	
	Local nCampos 	 := Len( aItem ) // Numero de Campos

	Local cChCli     := "" // Monta a Chave do Cliente que vai ser atualizado
	Local cChVen     := "" // Monta a Chave do Cliente que vai ser atualizado
	
	//Posiciona no Cliente
	DbSelectArea("SA1")
	DbSeek(xFilial("SA1")+aItem[nPA1_COD]+aItem[nPA1_LOJA],.F.)

	//MntChCli() // Monta a Chave do Cliente que vai ser atualizado
	
	//MntChArq() // Monta a Chave do Arquivo



Return Nil
*******************************************************************************
Static Function MntChArq() // Monta a Chave do Cliente que vai ser atualizado
*******************************************************************************

	If( nPA1_VEND    > 0 , AA1_VEND 	:= aItem[nPA1_VEND] 	, "" )
	If( nPA1_VENDEXT > 0 , AA1_VENDEXT 	:= aItem[nPA1_VENDEXT] 	, "" )
	If( nPA1_VENDCOO > 0 , AA1_VENDCOO 	:= aItem[nPA1_VENDCOO] 	, "" )
	If( nPA1_GERVEN  > 0 , AA1_GERVEN 	:= aItem[nPA1_GERVEN] 	, "" )

Return Nil 
*******************************************************************************
Static Function MntChCli() // Monta a Chave do Cliente que vai ser atualizado
*******************************************************************************

	CA1_GERVEN	:= Alltrim(SA1->A1_GERVEN)
	CA1_VENDCOO	:= Alltrim(SA1->A1_VENDCOO)
	CA1_VENDEXT	:= Alltrim(SA1->A1_VENDEXT)
	CA1_VEND	:= Alltrim(SA1->A1_VEND)

Return Nil 
*******************************************************************************
Static Function ValArquivo()  // Valida se o arquivo esta correto...
*******************************************************************************

	Local cCAMPOS  := "A1_COD/A1_LOJA/A1_GERVEN/A1_VENDCOO/A1_VENDEXT/A1_VEND"
	Local cCpoCli  := "A1_COD/A1_LOJA"
	Local lValCpo  := .T.
	Local lValCli  := .T.
	Local lReturn  := .T.
	Local nCpoCli  :=  0
	
	// Todos os Campos devem estar dentre os campos...
	For nI := 1 To Len(aCab)
		
		If !(aCab[nI] $ cCAMPOS)
			lValCpo := .F.
		EndIf
		
		If  aCab[nI] $ cCpoCli
			nCpoCli += 1
		EndIf
		
	Next
	
	// Valida se os dois campos do clientes se encontram no arquivo...
	If !(nCpoCli == 2)
		lValCli := .F.
	EndIf
	
	If !lValCpo
		Conout("lValCpo: "+cValToChar(lValCpo))
	
	ElseIf !lValCli
		Conout("lValCli: "+cValToChar(lValCli))
	EndIf
	
	If !lValCli .Or. !lValCpo
		lReturn := .F.
	EndIF
	
	Return lReturn 
*******************************************************************************
Static Function CriaVariaveis() // Cria todas as Variavaies necessárias
*******************************************************************************

	_SetOwnerPrvt( 'aCab'	, {} ) //| Contem o cabecalho do arquivo CSV
	_SetOwnerPrvt( 'aDet'	, {} ) //| Contem os itens do arquivo CSV
	
	_SetOwnerPrvt( 'nPA1_COD	'	, 0 ) //| Posicao do campo no array aCab
	_SetOwnerPrvt( 'nPA1_LOJA	'	, 0 ) //| Posicao do campo no array aCab
	_SetOwnerPrvt( 'nPA1_GERVEN	'	, 0 ) //| Posicao do campo no array aCab
	_SetOwnerPrvt( 'nPA1_VENDCOO'	, 0 ) //| Posicao do campo no array aCab
	_SetOwnerPrvt( 'nPA1_VENDEXT'	, 0 ) //| Posicao do campo no array aCab
	_SetOwnerPrvt( 'nPA1_VEND	'	, 0 ) //| Posicao do campo no array aCab			

	_SetOwnerPrvt( 'CA1_GERVEN	'	, "" ) //| Conteudo do campo no Cliente
	_SetOwnerPrvt( 'CA1_VENDCOO	'	, "" ) //| Conteudo do campo no Cliente
	_SetOwnerPrvt( 'CA1_VENDEXT	'	, "" ) //| Conteudo do campo no Cliente
	_SetOwnerPrvt( 'CA1_VEND'		, "" ) //| Conteudo do campo no Cliente

	_SetOwnerPrvt( 'AA1_GERVEN	'	, "" ) //| Conteudo do campo no Vendedor ou Arquivo
	_SetOwnerPrvt( 'AA1_VENDCOO	'	, "" ) //| Conteudo do campo no Vendedor ou Arquivo
	_SetOwnerPrvt( 'AA1_VENDEXT	'	, "" ) //| Conteudo do campo no Vendedor ou Arquivo
	_SetOwnerPrvt( 'AA1_VEND'		, "" ) //| Conteudo do campo no Vendedor ou Arquivo

	Return Nil
*******************************************************************************
Static Function Pergunta(cPathFile)
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
		OpenFile(cPathFile) // Abre o arquivo ...
	EndIf

	Return lReturn
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

	FT_FUse(cArq)
	FT_FGoTop()

	While !FT_FEOF()

		cLine := StrTran(FT_FREADLN(),'"','') //| Retira as aspas duplas da String
		While AT(";;",cLine) > 0
			cLine := StrTran(cLine,';;',"; ;")
		EndDo

		If lPril
			aCab :=  StrTokArr(cLine,";") 
		Else
			AAdd( aDet, StrTokArr(cLine,";") ) //| Converte a Linha para Array
		EndIf

		FT_FSkip()
		
		lPril	:= .F.
		
	EndDo

	FT_FUse()
	FClose(nHandle)

Return Nil