#Include "Totvs.ch"

#Define INVALIDO .F.
#Define VALIDO   .T.

// ############################################################################
// Projeto: Valida Campos de emails pelo sistema, inserir na Validacao de Usuario
// Modulo : Diversos
// Fonte  : ValEmail
// ---------+-------------------+----------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+----------------------------------------------
// 15/04/15 | Cristiano Machado | Valida os campos de Email
// ---------+-------------------+----------------------------------------------
*******************************************************************************
User Function ValEmail()
*******************************************************************************

	Private lValida 		:= .T. 			//| Variaval que Contém o resultado da Validação |
	Private cConteudo 	:= ""				//| Obtem o Conteudo do Campo que irá ser validado 	|
	Private cMailOK 		:= ""				//| Variavel Auxiliar que Retorna email's Corretos 	|
	Private cMailER		:= ""			  //| Variavel Auxiliar que Retorna email's Incorretos 	|
	Private cMailVal		:= ""				//| Array que vai armazenar os emails |

	Private nPIUMail		:= 0					//| Recebe a posição Inicial do Ultimo Email Encontrado na String	|
	Private nPFUMail		:= 0					//| Recebe a posição Final do Ultimo Email Encontrado na String		|
	Private cCaracter  := ""				//| Armazena o caracter que esta sendo validado...								|
	Private nTamCamp		:= 0					//| Armazena a Quantidade Total de Caracteres contina no campo..  |
	Private cCampo			:= ""				//| nome do campo em que esta posicionado a Validação... 					|
	Private nTOrCamp		:= 0					//| Numero de Caracteres default do Campo... |

	Private cCarAtual	:= ""
	Private nPc				:= 0
	Private bCarAtual	:= {	 || cCarAtual := Substr(cConteudo,nPc,1)	 }

	//| Inicializa Variaveis necessárias...
	cCampo			:= Readvar()
	nTOrCamp		:= Len( &( Readvar() ) )
	cConteudo 	:= Upper(Alltrim( &( Readvar() ) ) )
	cConteudo 	:= StrTran(cConteudo," ", "" )	//| Retirar espeços Vazios no meio da string... |
	nTamCamp		:= Len(cConteudo)

	//| Caso esteja vazio, não há o que Validar. |
	If Empty(cConteudo)
		Return( lValida )
	EndIf

	//| Varre String Atrás de Caracteres que não pode Fazer parte do email...e separa email's para validacao direta |
	For nPc := 1 To nTamCamp

		eval( bCarAtual ) // Separa o Caracter a ser avaliado...

		//|  Valida o Caracter, este eh um carater valido ? ...
		IF ValidaCarcter( cCarAtual ) == INVALIDO

			If PulaEmail(@nPc) // Pula e-mail quando encontrou um caracter inválido...
				exit
			EndIf

		EndIf

		If Separador(cCarAtual)// Após percorrer todos os caracter que compoem o email, ele agora eh deve passar por uma segunda validacao

			If VerEmail(cMailVal) == INVALIDO // Verifica se o email realmente possui um formato de email ?
				lValida := INVALIDO
			EndIf

		EndIF

	Next

	AtueApre() // Atualiza Campo e Apresenta Mensagens ...

Return(.T.)
*******************************************************************************
Static Function ValidaCarcter(cCaracter)
*******************************************************************************
	Local lValCar := .F.
	Local nCodAsc := ASC(cCaracter)
	Local bVNumer := {|| ( nCodAsc >= 48 .And. nCodAsc <= 57 )	} //| Numeros..: '0123456789' |
	Local bVAlfab := {|| ( nCodAsc >= 65 .And. nCodAsc <= 90 )	} //| Alfabeto.: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' |
	Local bVEspec := {|| ( cValToChar(nCodAsc) $ ('95/64/59/46/45') ) 			} //| Especiais: '_ @ ; . - ' |

	If 	eVal( bVNumer ) == VALIDO .And. !lValCar
		lValCar := .T.
	EndIF

	If	 	eVal( bVAlfab ) == VALIDO .And. !lValCar
		lValCar := .T.
	EndIf

	If 	eVal( bVEspec ) == VALIDO .And. !lValCar
		lValCar := .T.
	EndIf

Return(lValCar)
*******************************************************************************
Static Function Separador(cCaracter)
*******************************************************************************

	Local lSeparador := .F.
	Local bAddCar 		:= { || If( nPFUMail == 0 , 1 , 2 ) } // Controla... no caso do segundo email adiante deve adicionar 2 posicoes pelo motivo do separador ";"

	//| Separador de emails... ";" Valida o email como um todo, verificar se ele corresponde ao formato de um email. |
	If cCaracter == ";"

		nPIUMail := nPFUMail + eVal(bAddCar)	//| Atualiza variavel que armazena posicao onde inicia o email. 	|
		nPFUMail := nPc - 1									//| Atualiza variavel que armazena posicao onde Termina o email.	|
		nTamMail := nPFUMail - nPIUMail + 1	//| Obtem o Quantidade de caracteres que formam o email. 					|

		cMailVal := Substr(cConteudo,nPIUMail,nTamMail) //| Obtem o email ... para futura validacao |

		lSeparador := .T.

	ElseIf nTamCamp == nPc			//| Separador de emails... ";" Valida o email como um todo, verificar se ele corresponde ao formato de um email. |

		nPIUMail := nPFUMail + eVal(bAddCar)	//| Atualiza variavel que armazena posicao onde inicia o email. 	|
		nPFUMail := nPc										//| Atualiza variavel que armazena posicao onde Termina o email.	|
		nTamMail := nPFUMail - nPIUMail + 1	//| Obtem o Quantidade de caracteres que formam o email. 					|

		cMailVal := Substr(cConteudo,nPIUMail,nTamMail) //| Obtem o email ... para futura validacao |

		lSeparador := .T.

	EndIf

Return(lSeparador)
*******************************************************************************
Static Function VerEmail(email)
*******************************************************************************
	Local lOk := .T.

	//| Validacao do email em questão ...|
	If IsEMail(cMailVal) == INVALIDO
		lOk := .F.
		If Empty(cMailER)
			cMailER := cMailVal
		Else
			cMailER += ";" + cMailVal
		EndIf
	Else
		If Empty(cMailOK)
			cMailOK := cMailVal
		Else
			cMailOK += ";" + cMailVal
		EndIf
	EndIF

Return(lOk)
*******************************************************************************
Static Function PulaEmail(nPc) //| Atualiza e apresenta inconsistências |
*******************************************************************************
	Local lFim := .F.

		//| Caso encontrado o Caracter INVALIDO Pula para o Próximo email para continuar Validacao caso exista senao sai do FOR...
	nProxMail := At(";",Substr(cConteudo,nPc))

	If nProxMail > 0
		nPc 		:= nProxMail
	Else
		nPc 		:= nTamCamp //| sai do For
		lFim	 	:= .T.
	EndIf

	lValida := INVALIDO

Return(lFim)
*******************************************************************************
Static Function AtueApre() //| Atualiza e apresenta inconsistências |
*******************************************************************************

	//| Mantém no Campo apenas os email Válidos... |
	&cCampo. := PadR(cMailOK,nTOrCamp)

	//|Mensagem Informando os email retirados...  |
	If lValida == INVALIDO
		Iw_MsgBox("Por Favor Verificar o e-mail informado. E-mail: "+cMailER+ " é inválido e foi removido do campo !!!", "Email Inválido","ALERT")
	EndIf

Return()
