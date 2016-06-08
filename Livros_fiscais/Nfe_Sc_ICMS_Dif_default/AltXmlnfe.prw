#Include 'Protheus.ch'
#Include 'XmlxFun.ch'

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : NomeProg    | AUTOR : Cristiano Machado  | DATA : 19/10/2015   **
**---------------------------------------------------------------------------**
** DESCRIÇÃO: Efetua Ajustes no XML gerado apartir do Fonte Padrao Totvs     **
**          : NfeSefaz... Qualquer Tratamento no Xml imdepa deve ser aplicado**
**          : aqui... 	                                                      **
**---------------------------------------------------------------------------**
** USO      : Especifico para o cliente  XXXXXX                              **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
**            ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.              **
**---------------------------------------------------------------------------**
**   PROGRAMADOR   |   DATA   |            MOTIVO DA ALTERACAO               **
**---------------------------------------------------------------------------**
**                 |          |                                              **
**                 |          |                                              **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User Function AltXmlnfe(cXml_Imd, Tp_Nf , Ser_Nf, Num_Nf, ClFr_Nf, Lj_Nf )
*******************************************************************************

	Local lShowXML		:= .T.				//| Define se o Conteudo do Xml vai ser apresentado na Tela ? |

	Private cTipo		:= Tp_Nf			//| Tipo da NF 0-Entrada, 1-Saida |
	Private cSerie		:=	 Ser_Nf		//| Serie da NF |
	Private cNota		:= Num_Nf		//| Numero da Nf |
	Private cClieFor	:= ClFr_Nf		//| Cliente ou Fornecedor da Nf |
	Private cLoja 		:= Lj_Nf			//| Loja do Cliente ou Fornecedor |

	Private oXml_imd := Nil				//| Recebe o Xml em formato de Objeto |

	//| Variaveis Customizadas Imdepa |
	Private lNfImport 	:= .F.				//| Define se eh Nf Importacao ou Nao |
	Private nTotalPIS	:= 0					//| Obtem o Valor Total do PIS para Incluir no Complemento da NF |
	Private nTotalCOF	:= 0					//| Obtem o Valor Total do COFINS para Incluir no Complemento da NF |

	If lShowXML
		U_CaixaTexto(cXml_Imd)
	EndIf


	//| Converte o o Xml-String para Xml-Objeto |
	oXml_imd := ConvXmlStrToObj( cXml_Imd )


	//| Pre-Definições Gerais... Variaveis... Funcoes... Posicionamentos...|
	DefFuncVar()

	//| Tratamento de Conteudo das Tags Especifico Imdepa |
	TratagEsp(@oXml_imd)


	//| Convert o Xml-Objeto para Xml-String e Trata padrao UTF-8
	SAVE oXml_imd XMLSTRING cXml_Imd
	cXml_Imd := EncodeUTF8(cXml_Imd)



	//| Define se apresenta o Caixa de Texto contendo o XML |
	If lShowXML
		U_CaixaTexto(cXml_Imd)
	EndIf

Return ( cXml_Imd )
*******************************************************************************
Static Function DefFuncVar()//| Pre-Definições Gerais... Variaveis... Funcoes... Posicionamentos...|
*******************************************************************************

//| Verifica se eh Importacao....|
If ( cTipo == '0' .And. !Empty(SF1->F1_HAWB) )
	lNfImport := .T.
EndIf



Return()
*******************************************************************************
Static Function ConvXmlStrToObj(cString) //| Converte o o Xml-String para Xml-Objeto |
*******************************************************************************

	Local 	cString	:= cString		//| Indica uma string que contém o código XML. |
	Local cReplace	:= "_"				//| Indica o valor que será atribuído como prefixo para a nomenclatura das propriedades do objeto XML em Advpl a partir dos nomes dos nodes do documento XML. Será usando também na substituição de qualquer caractere usado no nome do node XML que não faça parte da nomenclatura de uma variável Adppl, como espaços em branco por exemplo.|
	Local cError		:= ""				//| Caso ocorra algum erro durante execução da função, a variável será preenchida com a descrição do erro ocorrido.
	Local cWarning	:= ""				//| Caso ocorra alguma advertência durante execução da função, a variável será preenchida com a descrição da advertência ocorrida. |

	Local oXml_Aux	:= Nil				//| Retorna um objeto com a estrutura de acordo com o XML. |

	Local xInfCpl	:= ''				//| a Ser Alterada |


	//| Cria o Xml ...como Objeto para poder alterar...|
	oXml_Aux	:= XmlParser( cString, cReplace, @cError, @cWarning )

	//| Verifica se houve Erros ou Alertas na Conversao do Xml-String para Xml-Objeto...|
	If !Empty(cError) .Or. !Empty(cWarning)
		Iw_MsgBox(cError + " " + cWarning)
	EndIf


Return( oXml_Aux )
*******************************************************************************
Static Function TratagEsp(oXml_imd)
*******************************************************************************

	local cVarAux := ""


	//| <IDE> 				-> Identificação da Nf-Eletronica |
	FA_IDE( 		@oXml_imd:_infNFe:_Ide )

	//| <EMIT> 			-> Identificação do Emitente da Nf-Eletronica |
	FA_EMIT( 	@oXml_imd:_infNFe:_Emit )

	//| <DEST> 			-> Identificação do Destinatário da Nf-Eletronica |
	FA_DEST( 	@oXml_imd:_infNFe:_Dest )

	//| <DET>				-> Detalhamento de Produtos e Servicos da NF-e |
	FA_DET( 		@oXml_imd:_infNFe:_Det )

	//| <TOTAL> 			-> Valores Totais da Nf-Eletronica |
	FA_TOTAL( 	@oXml_imd:_infNFe:_Total )

	//| TRANSP 			-> Dados da Transportadora |
	FA_TRANSP(	@oXml_imd:_infNFe:_Transp )

	//| <INFADIC >  	-> Informacoes Adicionais NF-Eletronica |
	FA_INFADIC( @oXml_imd:_infNFe:_infAdic )


Return()
*******************************************************************************
Static Function FA_IDE(oIde)//| <IDE> 				-> Identificação da Nf-Eletronica |
*******************************************************************************


Return
*******************************************************************************
Static Function FA_EMIT(oEmit)//| <EMIT> 			-> Identificação do Emitente da Nf-Eletronica |
*******************************************************************************


Return
*******************************************************************************
Static Function FA_DEST(oDest)//| <DEST> 			-> Identificação do Destinatário da Nf-Eletronica |
*******************************************************************************


Return
*******************************************************************************
Static Function FA_DET(aDetItem)//| <DET>	-> Detalhe dos Itens Contidos na NF-Eletronica |
*******************************************************************************

	For nIte := 1 To Len(aDetItem)

		//| <Prod> - Grupo do detalhamento de produtos e servicos da Nf-e |
		FA_DET_PROD(aDetItem[nIte]:_Prod)


		//| <IMPOSTO> - Tributos incidentes no Produto ou Servicos da Nf-e |
		FA_DET_IMPOSTO(aDetItem[nIte]:_Imposto)


		//| <infAdProd> - informacoes Adicionais do produto ou Servico da Nf-e |
		FA_DET_INFADPROD(aDetItem[nIte]:_InfaDProd)

	Next


Return
*******************************************************************************
Static Function FA_DET_PROD(oProd) //| <Prod> - Grupo do detalhamento de produtos e servicos da Nf-e |
*******************************************************************************


Return
*******************************************************************************
Static Function FA_DET_IMPOSTO(oImposto)	//| <IMPOSTO> - Tributos incidentes no Produto ou Servicos da Nf-e |
*******************************************************************************


For nImp := 1 To Len( oImposto ) // Percorre Estrutura de Impostos do ITEM para Obter o Total dos Impostos...

		If  ( oImposto[nImp]:_Codigo:Text == 'IPI' )
				nTotalPIS += Val( oImposto[nImp]:_Tributo:_Valor:Text )
		EndIf

		If  ( oImposto[nImp]:_Codigo:Text == 'COFINS' )
				nTotalCOF += Val( oImposto[nImp]:_Tributo:_Valor:Text )
		EndIf

Next


Return
*******************************************************************************
Static Function FA_DET_INFADPROD(oInfaDProd)	//| <infAdProd> - informacoes Adicionais do produto ou Servico da Nf-e |
*******************************************************************************


Return
*******************************************************************************
Static Function FA_TOTAL(oTotal)	//| <TOTAL> 			-> Valores Totais da Nf-Eletronica |
*******************************************************************************


Return
*******************************************************************************
Static Function FA_TRANSP(oTransp)//| TRANSP 			-> Dados da Transportadora |
*******************************************************************************


Return
*******************************************************************************
Static Function FA_INFADIC(oInfAdic)//| <INFADIC >  	-> Informacoes Adicionais NF-Eletronica |
*******************************************************************************

Local cComplemento := oInfAdic:_CPL:Text			//| Tag <Cpl> 	: Complemento Nf-e |
Local cFisco				:= oInfAdic:_FISCO:Text		//| Tag <Fisco>: Dados Complementares Fisco Nf-e |



//| Tratamento para Mensagens Nf Importação...|
//If lNfImport
	cComplemento += " PIS: R$" 		+ cValToChar(Transform(nTotalPIS, "@R 9.999.999,99") )
	cComplemento += " COFINS: R$"	+ cValToChar(Transform(nTotalCOF, "@R 9.999.999,99") )
//EndIf


oInfAdic:_CPL:Text		:= cComplemento
oInfAdic:_FISCO:Text	:= cFisco


Return()


