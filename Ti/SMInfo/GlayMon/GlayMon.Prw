#Include 'Totvs.ch'
#Include "FWPrintSetup.ch"
#Include "FileIo.ch"
#Include "Protheus.ch"
#Include "Colors.ch"

#Define LTESTE	   .F.

#Define PAPER_A4 	9 	//| Tamanho do Papel A4

#Define _SAVE	   .F. 	//| Parametro usado no cGetFile
#Define _OPEN	   .T. 	//| Parametro usado no cGetFile

#Define _ENTER     CHR(13) + CHR(10)

#Define TIPO		1 	//| TIPO DE OBJETO
#Define LIN1		2 	//| POSICAO 1 LINHA
#Define COL1		3 	//| POSICAO 1 COLUNA
#Define LIN2		4 	//| POSICAO 2 LINHA
#Define COL2		5 	//| POSICAO 2 COLUNA
#Define COR			6 	//| COR EM RGB
#Define TAM			7 	//| TAMANHO LINHA OU TEXTO
#Define TEXTO		8 	//| TEXTO...
#Define FORM 		9 	//| FORMATO DO TEXTO ... N->NORMAL, B->NEGRITO, I->ITALICO, A->NEGRITO E ITALICO

//                        Low Intensity colors
#define CLR_BLACK             0               // RGB(   0,   0,   0 )
#define CLR_BLUE        8388608               // RGB(   0,   0, 128 )
#define CLR_GREEN         32768               // RGB(   0, 128,   0 )
#define CLR_CYAN        8421376               // RGB(   0, 128, 128 )
#define CLR_RED             128               // RGB( 128,   0,   0 )
#define CLR_MAGENTA     8388736               // RGB( 128,   0, 128 )
#define CLR_BROWN         32896               // RGB( 128, 128,   0 )
#define CLR_HGRAY      12632256               // RGB( 192, 192, 192 )
#define CLR_LIGHTGRAY  CLR_HGRAY

//|                       High Intensity Colors
#define CLR_ORANGE      RGB( 255, 229, 204 )
#define CLR_GRAYH       RGB( 224, 224, 224 )
#define CLR_GRAY        RGB( 128, 128, 128 )
#define CLR_HBLUE       RGB(   0,   0, 255 )
#define CLR_HGREEN      RGB(   0, 255,   0 )
#define CLR_HCYAN       RGB(   0, 255, 255 )
#define CLR_HRED        RGB( 255,   0,   0 )
#define CLR_HMAGENTA    RGB( 255,   0, 255 )
#define CLR_YELLOW      RGB( 255, 255,   0 )
#define CLR_WHITE       RGB( 255, 255, 255 )

*******************************************************************************
User Function GlayMon()// Ferramenta para Desenvolver Relatorio Grafico
*******************************************************************************

	Private cTexto 		:= ""
	Private cNameArq 	:= "Novo"
	Private cExporta	:= ""
	Private aValDef 	:= { "L", "0000", "0000", "0000", "0000", "PT", "00", SPACE(250), "N" }
	Private oPrn		:= Nil

	If DATE() > cTod("29/03/2016")
		Iw_MsgBox("Desculpe. Versão Expirada !!! Entre em contato com cristianosm@gmail.com","Atenção","ALERT")
		Return()
	EndIf
	
//| Menu Tela Principal....
	TelaPrincipal()

Return()
*******************************************************************************
Static Function TelaPrincipal()//| Tela Principal
*******************************************************************************
	Local lCentered 	:= .T. //| lógico Indica se a janela será (.T.) ou não (.F.) centralizada. O padrão é falso (.F.).

	Local oDlg 			:= Nil

	Local oBtNovo		:= Nil
	Local oBtImportar	:= Nil
	Local oBtSalvar		:= Nil
	Local oBtExportar	:= Nil

	Local oBtParametros	:= Nil
	Local oBtEdtar		:= Nil
	Local oBtVisualizar	:= Nil

	Local oGroupA		:= Nil
	Local oGroupB		:= Nil
	Local oGroupC		:= Nil

	local oSay			:= Nil

	Local cDescricao	:= ""
	
	Private  lBtNovo		:= Nil
	Private  lBtImportar	:= Nil
	Private  lBtSalvar		:= Nil
	Private  lBtExportar	:= NIl
	Private  lBtParametros	:= Nil
	Private  lBtEdtar		:= Nil
	Private  lBtVisualizar	:= Nil
	
	cDesc1 	:= "Ferramenta criada com o intuito de auxiliar no desenvolvimento de relatórios "
	cDesc2 	:= "Graficos. Permitindo de forma prática, criar seu Layout Gráfico para posteriormente "
	cDesc3 	:= "ser exportado no formato ADVPL e ser inserido no seu fonte efetivamente. "
	
	FAtuSBtm("I") //Atualiza o Status dos Botoes
	
	FWindows(@oDlg, "GlayMon" , 240, 470) //| Monta o Objeto Odlg

	FSay(@oSay, 015, 030, cDesc1, oDlg )
	FSay(@oSay, 025, 015, cDesc2, oDlg )
	FSay(@oSay, 035, 015, cDesc3, oDlg )

	FGroup(@oGroupA,010,010,050,225,oDlg )
	FGroup(@oGroupB,055,010,080,225,oDlg )
	FGroup(@oGroupC,085,010,110,225,oDlg )

	cToolTip := "NOVO: Usado para criar do inicio um novo layout."
	FButton(@oBtNovo		, 060, 015, "Novo"		, oDlg, {||FNovo()      }	, 050,,{||lBtNovo		}, cToolTip ) //| Cria Botao no Odlg

	cToolTip := "IMPORTAR: Abre um arquivo layout salvo anteriormente, dando a opção de continuidade do desenvolvimento."
	FButton(@oBtImportar	, 060, 066, "Importar"	, oDlg, {||FImport()	}	, 050,,{||lBtImportar	}, cToolTip ) //| Cria Botao no Odlg

	cToolTip := "SALVAR: Salva o layout em arquivo texto que pode ser posteriormente utilizado."
	FButton(@oBtSalvar		, 060, 118, "Salvar"	, oDlg, {||FSalvar()   	}	, 050,,{||lBtSalvar		}, cToolTip ) //| Cria Botao no Odlg

	cToolTip := "EXPORTAR: Exportar o layout criado para o fomato ADVPL. O botão só é ativado após o Visualizar."
	FButton(@oBtExportar	, 060, 170, "Exportar"	, oDlg, {||FExporta() 	}	, 050,,{||lBtExportar	}, cToolTip ) //| Cria Botao no Odlg

	cToolTip := "PARAMETROS: Devemos aqui definir os parametros de impressão que serão utilizadas no relatório."
	FButton(@oBtParametros	, 090, 015, "Parametros", oDlg, {||FParametros()}	, 066,,{||lBtParametros	}, cToolTip ) //| Cria Botao no Odlg

	cToolTip := "EDITAR: Usado para manipular o Layout. Alterações, Inclusãoes e exclusões  de objetos no relatório."
	FButton(@oBtEdtar		, 090, 084, "Editar"	, oDlg, {||FEditar()	} 	, 067,,{||lBtEdtar		}, cToolTip ) //| Cria Botao no Odlg

	cToolTip := "VISUALIZAR: Aqui podemos gerar o Relatório e verificar o andamento do desenvolvimento."
	FButton(@oBtVisualizar	, 090, 154, "Visualizar", oDlg, {||FVisualizar()}	, 066,,{||lBtVisualizar	}, cToolTip ) //| Cria Botao no Odlg
	
 	oFCred := TFont():New("Arial", ,12,,.F.,,,,,.F.)	//| Conteudo dos Campos
	FSay(@oSay, 115, 140, "by CSM - cristianosm@gmail.com  - v1.0", oDlg, Nil, oFCred )
	
	oDlg:Activate( Nil, Nil, Nil, lCentered )

Return()
*******************************************************************************
Static Function Fnovo() //| Cria um Novo Arquivo Layout
*******************************************************************************

	FAtuSBtm("N") //Atualiza o Status dos Botoes

	cNameArq 	:= "Novo"
	cTexto 		:= ""

	TelaMultG(@cTexto) //| Editor de Texto

Return()
*******************************************************************************
Static Function FImport()//| Importa um novo Arquivo Layout
*******************************************************************************

	FAtuSBtm("M") //Atualiza o Status dos Botoes

	cFile := ASFile(_OPEN)

Return()
*******************************************************************************
Static Function FSalvar()//| Salva um Arquivo Layout
*******************************************************************************

	FAtuSBtm("S") //Atualiza o Status dos Botoes

	cFile := ASFile(_SAVE) //| Salva Arquivo

Return()
*******************************************************************************
Static Function FExporta()//| Exporta o Arquivo Layout para Codigo Fonte Advpl
*******************************************************************************

	TelaMultG(@cExporta) //| Exporta o Texto Formato Layout para Codigo Advpl

Return()
*******************************************************************************
Static Function FParametros//| Configura os Parametros de Ferramenta...
*******************************************************************************
	
	FAtuSBtm("P") //Atualiza o Status dos Botoes

	VerSx1(.T.)
	
	//FConfig(.T.) //FWMsPrinter():Setup()
	
Return()
*******************************************************************************
Static Function FEditar()//| Funcao do Botao EDITAR
*******************************************************************************

	FAtuSBtm("D") //Atualiza o Status dos Botoes

	TelaMultG(@cTexto)

Return()
*******************************************************************************
Static Function FVisualizar()// Prepara Arquivo Layout para Impressao
*******************************************************************************

	Private oFConteudo		:= Nil
	Private aLines			:= {}
	
	FAtuSBtm("V") //Atualiza o Status dos Botoes
	
	oFConteudo	:=	TFont():New("Arial",09,10,,.T.,,,,,.F.)	//| Conteudo dos Campos
	
	FConfig()

	FPrint(@oPrn)
	
Return()
*******************************************************************************
Static Function FAtuSBtm(cQual) //Atualiza Estatus dos Botoes conforme Operacao...
*******************************************************************************	

	Do Case
	Case cQual == "I" //| Inicio
		lBtNovo := lBtImportar := .T.
		lBtSalvar := lBtExportar := lBtParametros := lBtVisualizar := lBtEdtar := .F.
	Case cQual == "N"  //| Novo
		lBtEdtar := lBtSalvar := lBtParametros := .T.
		lBtImportar := lBtNovo := lBtExportar := lBtVisualizar := .F.
	Case cQual == "M"  // Importar
		lBtEdtar := lBtParametros := lBtVisualizar := .T.
		lBtImportar := lBtNovo := lBtExportar := lBtSalvar := .F.
	Case cQual == "S" //| Salvar
		lBtNovo	:= lBtImportar	:= lBtEdtar	:= lBtParametros := lBtVisualizar:= .T.
		lBtSalvar  := lBtExportar := .F.
	Case cQual == "E" //| Exportar
		lBtNovo	:= lBtImportar := lBtEdtar	:= .T.
		lBtSalvar := lBtExportar := lBtParametros := lBtVisualizar := .F.
	Case cQual == "D" //| Editar
		oBtEdtar := lBtSalvar := lBtParametros := .T.
		lBtImportar	:= lBtNovo := lBtExportar := lBtVisualizar := .F.
	Case cQual == "V" //| Editar
		lBtExportar := .T.
	OtherWise  //| Parametros //| Visualizar //Case cQual == "P" .Or. cQual == "V"
	
	EndCase
	
Return()
*******************************************************************************
Static Function FConfig(lConfig)//| Configura Pagina e Parametros de Impressao
*******************************************************************************
	//| Parametros FWMSPrinter()
	Private cFilePrint		:= CriaTrab( ,.F. ) + ".pdf"//| Nome do arquivo de relatório a ser criado.
	Private lAdjustToLegacy	:= .T.						//| Se .T. recalcula as coordenadas para manter o legado de proporções com a classe TMSPrinter. Default é .T.IMPORTANTE: Este cálculos não funcionam corretamente quando houver retângulos do tipo BOX e FILLRECT no relatório, podendo haver distorções de algumas pixels o que acarretará no encavalamento dos retângulos no momento da impressão.
	Private cPathInServer	:= "\system\pdf\"			//| Diretório onde o arquivo de relatório será salvo no Servidor
	Private lDisableSetup	:= .T.						//| Se .T. não exibe a tela de Setup, ficando à cargo do programador definir quando e se será feita sua chamada. Default é .F.
	Private lTReport		:= .F.						//|
	Private cPrinter		:=  ""
	Private lServer			:= .F.
	Private lPDFAsPNG		:= .F.
	Private lRaw			:= .F.
	Private lViewPDF		:= .T.
	Private nQtdCopy		:= NIL
	Private lSetView		:= .T.
	
	Private nDevice			:= Nil					//| Tipos de Saída aceitos: IMP_SPOOL Envia para impressora. IMP_PDF Gera arquivo PDF à partir do relatório.Default é IMP_SPOOL
	Private cLocalPath		:= "C:\MP11\"				//| Diretório onde o arquivo de relatório será salvo no Cliente
	Private nPaperSize		:= Nil
	Private bSetPaperS  	:= {|| oPrn:SetPaperSize(nPaperSize) }
	Private bOrientaPag 	:= {||  }
	Private bSetMargin  	:= {||  }

	Default lConfig 			:= .F.
	
	VerSx1(.F.)
 
	oPrn := FWMSPrinter():New(cFilePrint, nDevice, lAdjustToLegacy ,cPathInServer, lDisableSetup, lTReport, @oPrn, cPrinter, lServer, lPDFAsPNG, lRaw, lViewPDF )
	
	cExporta := MCabExporta() //| Monta o Cabecalho do Exporta...

	eVal(bOrientaPag)
	eVal(bSetPaperS)
	eVal(bSetMargin)
	
	oPrn:SetViewPDF(lSetView)

Return()
*******************************************************************************
Static Function FPrint(oPrn)//| Imprime a Pagina
*******************************************************************************

	oPrn:StartPage() //| Inicia a Pagina

	cExporta += "oPrn:StartPage()" + _ENTER + _ENTER
	
	If LTESTE // lTeste
		PrintTst( @oPrn )
	Else
		GetTxt(@aLines) //Carrega o texto...
		
		TxtToGrafi( @oPrn )
	EndIF
	
	oPrn:EndPage() //| Finaliza a Pagina
	oPrn:Preview() //| Abre a Impressao
	
	cExporta += _ENTER + "oPrn:EndPage()" + _ENTER
	cExporta += _ENTER + "oPrn:Preview()" + _ENTER + _ENTER

	cExporta += "Return()" + _ENTER
	
Return()
*******************************************************************************
Static Function GetTxt(aLines)//| Converte o Texto em Array para Montar Desenho
*******************************************************************************

	Local aLine		:= {}
	Local lContinua := .T.
	Local nPosI		:= 1
	Local cPosF		:= -1
	Local nPosAux	:= 1
	
	While nPosAux > 0
	
		nPosAux := At(_ENTER, cTexto, nPosI )

		cLine  := Substr(cTexto,nPosI,(nPosAux-nPosI))
		aLine	:= StrToKarr(cLine,';')

		Aadd( aLines, aLine )
		
		nPosI := nPosAux + Len(_ENTER)
		
	EndDo

Return()
*******************************************************************************
Static Function TxtToGrafi( oPrn ) //|Inicia o Desenho Grafico da Pagina
*******************************************************************************
	Local lBold 	:= .T.
	Local lItalic 	:= .T.

	Local cDLinPix	:= "0" // Densidade Linha em Pixel Default (-2)
	
	Private oBruVE 	:= TBrush():New2( , CLR_HRED 		) //| Vermelho	|
	Private oBruCI 	:= TBrush():New2( , CLR_GRAYH		) //| Cinza		|
	Private oBruAM 	:= TBrush():New2( , CLR_YELLOW 		) //| Amarelo	|
	Private oBruAZ 	:= TBrush():New2( , CLR_BLUE 		) //| Azul 		|
	Private oBruVD 	:= TBrush():New2( , CLR_ORANGE		) //| Laranja 		|
	Private oBruBR 	:= TBrush():New2( , CLR_WHITE		) //| Branco		|
	Private oTFont
	
	Private nColor	:= 0
	Private aCoords := {}
	
	
	// Inicia o Desenho do Relatorio... Conforme estrutura pre definida...
	For nL := 1 To Len(aLines)

		If Len(aLines[nL]) > 0

			If aLines[nL][TIPO] == "L" // Linha
				FDLinha(@oPrn)
		
			ElseIf aLines[nL][TIPO] == "B" // Box
				FDBox(@oPrn)

			ElseIf  aLines[nL][TIPO] == "R" // Retangulo Colorido
				FDRetangulo(@oPrn)
				
			ElseIf aLines[nL][TIPO] == "T" // Texto
				FDTexto(@oPrn)
				
			ElseIf aLines[nL][TIPO] == "I" // Imagem
				FDImagem(@oPrn)
				
			ElseIf aLines[nL][TIPO] == "C"  // Comentario
				cExporta += "//| " + aLines[nL][TEXTO] + _ENTER
			
			EndIf
		EndIf
	Next
	
Return()
*******************************************************************************
Static Function FDLinha(oPrn) // Desenha Linha
*******************************************************************************
//| Parâmetros oPrn:Line()
 
	nTop	:= Val(aLines[nL][LIN1])//| Numérico	Indica a coordenada vertical em pixels.	X
	nLeft	:= Val(aLines[nL][COL1])//| Numérico	Indica a coordenada horizontal em pixels.	X
	nBottom	:= Val(aLines[nL][LIN2])//| Numérico	Indica a posição do objeto ao rodapé.	X
	nRight	:= Val(aLines[nL][COL2])//| Numérico	Indica a posição do objeto à direita.	X
	nColor	:= FNToC(aLines[nL][COR],"H") //nColor 				//| Numérico	Cor da linha. Default é 0
	cPixel	:= aLines[nL][TAM]		//| Caracter	Expessura da linha em pixels. Default é "-2"

	oPrn:Line( nTop, nLeft, nBottom, nRight, nColor, cPixel )
	cExporta += "oPrn:Line( "+XC( nTop )+" , "+XC( nLeft )+" , "+XC( nBottom )+" , "+XC( nRight )+" , "+XC( nColor )+" , '" + XC( cPixel )+"'  )"  + _ENTER

Return()
*******************************************************************************
Static Function FDBox(oPrn) // Desenha Caixa
*******************************************************************************
//| Parâmetros oPrn:Box()
 
	Local nRow		:= Val(aLines[nL][LIN1])	//|	Numérico	Indica a coordenada vertical em pixels.	X
	Local nCol		:= Val(aLines[nL][COL1])	//|	Numérico	Indica a coordenada horizontal em pixels.	X
	Local nBottom	:= Val(aLines[nL][LIN2])	//|	Numérico	Indica a posição do objeto em relação ao rodapé.	X
	Local nRight	:= Val(aLines[nL][COL2]) 	//|	Numérico	Indica a posição do objeto à direita.	X
	Local cPixel	:= aLines[nL][TAM]       	//|	Caracter	Expessura da linha em pixels. Default é "-2"
 
	oPrn:Box( nRow, nCol, nBottom, nRight, cPixel )
	cExporta += "oPrn:Box( "+XC( nRow )+" , "+XC( nCol )+" , "+XC( nBottom )+" , "+XC( nRight )+" , '"+XC( cPixel )+"' )"  +_ENTER

Return()
*******************************************************************************
Static Function FDRetangulo(oPrn) // Desenha Retangulo
*******************************************************************************

	Local aCoords	:= {} 	//| Vetor	Vetor de coordenadas {nTop,nLeft,nBottom,nRight}	X
	Local oBrush	:= FNToC(aLines[nL][COR],"O") 	//| Objeto	Indica o objeto do tipo TBrush utilizado para definir a cor de preenchimento do shape e responsável pelo preenchimento do retângulo.
	Local cPixel	:= aLines[nL][TAM] //| Caracter	Expessura da linha em pixels. Default é "-2"

	aCoords := { Val(aLines[nL][LIN1]) , Val(aLines[nL][COL1]) , Val(aLines[nL][LIN2]) , Val(aLines[nL][COL2]) }
	cCoords := "{ " +XC( Val(aLines[nL][LIN1]) )+","+XC( Val(aLines[nL][COL1]) )+","+XC( Val(aLines[nL][LIN2]) )+","+XC( Val(aLines[nL][COL2]) )+ " }"
				
	oPrn:FillRect( aCoords 	, oBrush	, cPixel)
	cExporta += "oPrn:FillRect( "+XC( cCoords )+" , oBrush , '"+XC( cPixel ) +"' ) " + _ENTER

Return()
*******************************************************************************
Static Function FDTexto(oPrn) // Desenha Texto
*******************************************************************************
//| Parâmetros oPrn:Say()
	Local nRow		:= Val(aLines[nL][LIN1])	//| Numérico	Indica a coordenada vertical em pixels ou caracteres.	X
	Local nCol		:= Val(aLines[nL][COL1])	//| Numérico	Indica a coordenada horizontal em pixels ou caracteres.	X
	Local cText		:= aLines[nL][TEXTO]		//| Caracter	Texto a ser impresso.	X
	Local oFont		:= Nil						//| Objeto		Indica o objeto do tipo TFont utilizado para definir as características da fonte aplicada na exibição do conteúdo do controle visual.
	Local nWidth	:= Nil						//| Nulo		Indica a largura em pixels do objeto.
	Local nCorTxt	:= FNToC(aLines[nL][COR],"H")	//| Numérico	Indica a cor do texto do objeto.
	Local nAngle	:= 0							//| Numérico	Ângulo de rotação do texto.
	Local nTamT		:= Val(aLines[nL][TAM]) * -1  	//| Numerico 	Tamanho do Texto...

	//| Monta a Fonte...		
	oFont :=  TFont():New( 'Courier new' , , nTamT )
	cExporta += "oFont :=  TFont():New( 'Courier new' , , "+ XC( nTamT ) +") " + _ENTER

	//| Formatacao do Texto
	Do Case
	Case aLines[nL][FORM] == "A" // Tudo
		oFont:Bold 		:= .T.
		oFont:Italic  	:= .T.
		cExporta += "oFont:Bold 	:= .T. " + _ENTER
		cExporta += "oFont:Italic  	:= .T. " + _ENTER
					
	Case aLines[nL][FORM] == "I" // Italico
		oFont:Italic  	:= .T.
		cExporta += "oFont:Italic 	:= .T. " + _ENTER
				
	Case aLines[nL][FORM] == "B" // Negrito
		oFont:Bold 		:= .T.
		cExporta += "oFont:Bold 	:= .T. " + _ENTER
	EndCase

	//| Desenha o Texto
	oPrn:Say( nRow , nCol , cText, oFont ,   ,  nCorTxt ,  )
	cExporta += "oPrn:Say( "+XC( nRow  )+" , "+XC(  nCol  )+" , '"+XC( cText )+"' , oFont ,   , " + cValTocHar(nCorTxt)+ " , ) " + _ENTER

Return()
*******************************************************************************
Static Function FDImagem(oPrn) //| Desenha a Imagem...
*******************************************************************************
 
//| Parâmetros oPrn:SayBitmap()
	Local nRow		:= Val(aLines[nL][LIN1]) 	//| Numérico	Indica a coordenada vertical em pixels ou caracteres.	X
	Local nCol		:= Val(aLines[nL][COL1]) 	//| Numérico	Indica a coordenada horizontal em pixels ou caracteres.	X
	Local cBitmap	:= aLines[nL][TEXTO] 		//| Caracter	Indica o diretório e o nome, com extensão BMP (Bitmap), da imagem.	X
	Local nWidth	:= if(Val(aLines[nL][LIN2])>0,Val(aLines[nL][LIN2]),Nil)  	//| Numérico	Indica a largura em pixels do objeto. Default é 100.
	Local nHeight	:= If(Val(aLines[nL][COL2])>0,Val(aLines[nL][COL2]),Nil)	//| Numérico	Indica a altura em pixels do objeto. Default é 100.
	//Alert(cBitmap)
	
	oPrn:SayBitmap( nRow , nCol , cBitmap , nWidth , nHeight )
	cExporta += "oPrn:SayBitmap( "+XC( nRow  )+" , "+XC(  nCol  )+" , '"+XC(  cBitmap  )+"' , "+XC(  nWidth  )+" , "+XC(  nHeight )+" ) " + _ENTER

Return()
*******************************************************************************
Static Function FWindows(oDlg, cCaption, nBottom, nRight, lTransparent) //| Monta o Objeto Window
*******************************************************************************

	nTop	 	:= 000		 //| Numérico	Indica a coordenada vertical superior em pixels ou caracteres.
	nLeft	 	:= 000		 //| Numérico	Indica a coordenada horizontal esquerda em pixels ou caracteres.
	nBottom	 	:= nBottom	 //| Numérico	Indica a coordenada vertical inferior em pixels ou caracteres.
	nRight	 	:= nRight	 //| Numérico	Indica a coordenada horizontal direita em pixels ou caracteres.
	cCaption 	:= cCaption  //| Caracter	Indica o título da janela.
	uParam6	 	:= Nil		 //| Qualquer	Compatibilidade.
	uParam7	 	:= Nil		 //| Qualquer	Compatibilidade.
	uParam8	 	:= Nil		 //| Qualquer	Compatibilidade.
	uParam9	 	:= Nil		 //| Qualquer	Compatibilidade.
	nClrText 	:= CLR_BLACK //| Objeto		Indica a cor do texto.
	nClrBack 	:= CLR_WHITE //| Qualquer	Indica a cor de fundo.
	uParam12 	:= Nil 		 //| Qualquer	Compatibilidade.
	oWnd 	 	:= Nil 		 //| Objeto	Indica a janela mãe (principal) da janela que será criada. O padrão é a janela principal do programa.
	lPixel 	 	:= Nil 		 //| lógico	Indica se considera as coordenadas passadas em pixels (.T.) ou caracteres (.F.).
	uParam15 	:= Nil		 //| Qualquer	Compatibilidade.
	uParam16 	:= Nil		 //| Qualquer	Compatibilidade.
	uParam17 	:= Nil		 //| Qualquer	Compatibilidade.
	nWidth 	 	:= Nil		 //| numérico	Indica a largura da janela em pixels..
	nHeight  	:= Nil		 //| numérico	Indica a altura da janela em pixels..
	lTransparent:= lTransparent		 //| lógico	Se .T. permitira que a Dialog receba um fundo transparente..

	Default nBottom  := 400
	Default nRight 	 := 400
	Default cCaption := "Dialogo"
	Default lTransparent := .F.
	
	WS_POPUP 	:= 2147483648 //| [ 1 0 0 0 ]
	WS_A 		:= 1073741824 //| [ 0 1 0 0 ]
	WS_B 		:= 536870912  //| [ 0 0 1 0 ]
	WS_VISIBLE 	:= 268435456  //| [ 0 0 0 1 ]
	
	nOpcW := Nil
	
	oDlg := TDialog():New( nTop, nLeft, nBottom, nRight, cCaption,,,,nOpcW,CLR_BLACK,CLR_WHITE,,,.T.,,,,,,lTransparent)
	
Return()
*******************************************************************************
Static Function FButton(oButton, nRow, nCol, cCaption, oDlg, bAction, nWidth, nHeight, bWhen, cToolTip) //| Monta Botao em Dialogo
*******************************************************************************
	Local nRow 		:= nRow 	//|numérico Indica a coordenada vertical em pixels ou caracteres.
	Local nCol 		:= nCol 	//|numérico Indica a coordenada horizontal em pixels ou caracteres.
	Local cCaption 	:= cCaption //|caractere Indica o título do botão.
	Local oDlg 		:= oDlg		//|objeto Indica a janela ou controle visual onde o botão será criado.
	Local bAction 	:= bAction 	//|bloco de código Indica o bloco de código que será executado quando clicar, com o botão esquerdo do mouse, sobre o botão.
	Local nWidth 	:= nWidth 	//|numérico Indica a largura em pixels do botão.
	Local nHeight 	:= nHeight 	//|numérico Indica a altura em pixels do botão.
	Local uP8 		:= Nil 		//|numérico Compatibilidade.
	Local oFont 	:= Nil 		//|objeto Indica o objeto do tipo TFont utilizado para definir as características da fonte aplicada na exibição do conteúdo do controle visual.
	Local uP10 		:= .F. 		//|lógico Compatibilidade.
	Local lPixel 	:= .T. 		//| lógico Indica se considera as coordenadas passadas em pixels (.T.) ou caracteres (.F.).
	Local uP12 		:= Nil 		//| lógico Compatibilidade.
	Local uP13 		:= Nil 		//| lógico Compatibilidade.
	Local uP14 		:= Nil 		//| lógico Compatibilidade.
	Local bWhen 	:= bWhen	//| bloco de código Indica o bloco de código que será executado quando a mudança de foco da entrada de dados, na janela em que o controle foi criado, estiver sendo efetuada. Observação: O bloco de código retornará verdadeiro (.T.), se o controle permanecer habilitado; caso contrário, retornará falso (.F.).
	Local uP16 		:= Nil 		//| bloco de código Compatibilidade.
	Local uP17 		:= .F. 		//| lógico Compatibilidade.
	Local cToolTip  := cToolTip

	Default nWidth 	:= 040
	Default nHeight	:= 015
	Default cToolTip := ""
	
	oTButton := TButton():New(nRow,nCol,cCaption,oDlg,bAction,nWidth,nHeight,uP8,oFont,uP10,lPixel,uP12,uP13,uP14,bWhen,uP16,uP17 )
	
	oTButton:cToolTip := cToolTip
	
Return()
*******************************************************************************
Static Function FGroup(oGroup,nTop,nLeft,nBottom,nRight,oDlg,cCaption )//| Monta Group em Dialogo
*******************************************************************************
	nTop 	 := nTop 		//| numérico Indica a coordenada vertical superior em pixels ou caracteres.
	nLeft	 := nLeft		//| numérico Indica a coordenada horizontal à esquerda em pixels ou caracteres.
	nBottom  := nBottom 	//| numérico Indica a coordenada vertical inferior em pixels ou caracteres.
	nRight   := nRight 		//| numérico Indica a coordenada horizontal à direita em pixels ou caracteres.
	cCaption := cCaption  	//| caractere Indica o título do grupo.
	oDlg	 := oDlg		//| objeto Indica a janela ou controle visual onde o objeto será criado.
	nClrText := CLR_BLACK	//| numérico Indica a cor do texto.
	nClrPane := CLR_WHITE	//| numérico Indica a cor de fundo.
	lPixel	 := .T.  		//| lógico Indica se considera as coordenadas passadas em pixels (.T.) ou caracteres (.F.).
	uP10 	 := .T. 		//| lógico Compatibilidade.

	Default cCaption := ""

	oGroup := TGroup():New(nTop,nLeft,nBottom,nRight,cCaption,oDlg,nClrText,nClrPane,lPixel,uP10)

Return()
*******************************************************************************
Static Function FSay(oSay, nRow, nCol, cText, oDlg, cPicture, oFont, nClrText )//| Monta Texto em Dialogo
*******************************************************************************

	nRow 	:= nRow 		//| numérico Indica a coordenada vertical em pixels ou caracteres.
	nCol 	:= nCol 		//| numérico Indica a coordenada horizontal em pixels ou caracteres.
	bText 	:= {||cText} 	//| bloco de código Indica o bloco de código que será executado para retornar e apresentar uma string.
	oDlg 	:= oDlg			//| objeto Indica a janela ou controle visual onde o objeto será criado.
	cPicture:= cPicture 	//| caractere Indica a máscara de formatação, do conteúdo, que será apresentada. Verificar Tabela de Pictures de Formatação.
	oFont 	:= oFont 		//| objeto Indica o objeto do tipo TFont utilizado para definir as características da fonte aplicada na exibição do conteúdo do controle visual.
	uP7 	:= Nil 			//| lógico Compatibilidade.
	uP8 	:= Nil 			//| lógico  Compatibilidade.
	uP9 	:= Nil 			//| lógico Compatibilidade.
	lPixels := .T.			//| lógico Indica se considera as coordenadas passadas em pixels (.T.) ou caracteres (.F.).
	nClrText:= nClrText		//| numérico Indica a cor do texto do objeto.
	nClrBack:= CLR_WHITE	//| numérico Indica a cor de fundo do objeto.
	nWidth 	:= 400			//| numérico Indica a largura em pixels do objeto.
	nHeight := 020			//| numérico Indica a altura em pixels do objeto.
	uP15 	:= Nil			//| lógico Compatibilidade.
	uP16 	:= Nil			//| lógico Compatibilidade.
	uP17 	:= Nil			//| lógico Compatibilidade.
	uP18 	:= Nil			//| lógico Compatibilidade.
	uP19 	:= Nil			//| lógico Compatibilidade.
	lHtml 	:= Nil			//| lógico Indica se, verdadeiro (.T.), habilita a visualização do texto no formato HTML; caso contrário, falso (.F.).

	Default cPicture := ""
	Default oFont 	 := Nil
	Default nClrText := CLR_BLACK

	oSay := TSay():New(nRow,nCol,bText,oDlg,cPicture,oFont,uP7,uP8,uP9,lPixels,nClrText,nClrBack,nWidth,nHeight,)

Return()
*******************************************************************************
Static Function FMultG(oTMultGet,cTxtMG,oDlgT,nWidth,nHeight, bWhen)
*******************************************************************************
	nRow		:= 001 		//| Numérico	Indica a coordenada vertical em pixels ou caracteres.
	nCol		:= 001 		//| Numérico	Indica a coordenada horizontal em pixels ou caracteres.
	bSetGet		:= {|u|if(Pcount()>0,cTxtMG:=u,cTxtMG)} //| Bloco de código	Indica o bloco de código, no formato {|u| if( Pcount( )>0, := u, ) }, que será executado para atualizar a variável (essa variável deve ser do tipo caracter). Desta forma, se a lista for sequencial, o controle atualizará com o conteúdo do item selecionado, se for indexada, será atualizada com o valor do índice do item selecionado.
	oWnd		:= oDlgT 	//| Objeto	Indica a janela ou controle visual onde o objeto será criado.
	nWidth		:= nWidth 	//| Numérico	Indica a largura em pixels do objeto.
	nHeight		:= nHeight 	//| Numérico	Indica a altura em pixels do objeto.
	oFont		:= 	TFont():New( 'Courier new' , , 20, , .T.) //| Objeto	Indica o objeto do tipo TFont utilizado para definir as características da fonte aplicada na exibição do conteúdo do controle visual.
	lHScroll	:= .F. //| Lógico	Indica se habilita(.T.)/desabilita (.F.) a barra de rolagem horizontal.
	uP09		:= Nil //| Numérico	Compatibilidade
	uP10		:= Nil //| Numérico	Compatibilidade
	uP11		:= Nil //| Objeto	Compatibilidade.
	lPixel		:= .T. //| Lógico	Indica se considera as coordenadas passadas em pixels (.T.) ou caracteres (.F.).
	uP13		:= Nil //| Caracter	Compatibilidade.
	uP14		:= Nil //| Lógico	Compatibilidade.
	bWhen		:= bWhen  //| Bloco de código	Indica o bloco de código que será executado quando a mudança de foco da entrada de dados, na janela em que o controle foi criado, estiver sendo efetuada. Observação: O bloco de código retornará verdadeiro (.T.) se o controle permanecer habilitado; caso contrário, retornará falso (.F.).
	uP16		:= Nil //| Lógico	Compatibilidade.
	uP17		:= Nil //| Lógico	Compatibilidade.
	lReadOnly	:= .F. //| Lógico	Indica se o conteúdo da variável associada ao objeto permanecerá apenas para leitura.
	bValid		:= {||} //| Bloco de código	Indica o bloco de código de validação que será executado quando o conteúdo do objeto for modificado. Retorna verdadeiro (.T.), se o conteúdo é válido; caso contrário, falso (.F.).
	uP20		:= {||}  //| Bloco de código	Compatibilidade.
	uP21		:= Nil //| Lógico	Compatibilidade.
	lNoBorder	:= .T. //| Lógico	Indica se habilita(.T.)/desabilita(.F.) a apresentação da borda no objeto.
	lVScroll	:= .T. //| Lógico	Indica se habilita(.T.)/desabilita(.F.) a barra de rolagem vertical. Obs.: O valor default é Desabilitado.
	cLabelText	:= "" //| Caractere	indica o texto que será apresentado na Label.
	nLabelPos	:= 1 //| Numérico	Indica a posição da label, sendo 1=Topo e 2=Esquerda
	oLabelFont	:= Nil //| Objeto	Indica o objeto, do tipo TFont, que será utilizado para definir as características da fonte aplicada na exibição da label.
	nLabelColor	:= Nil //| Numérico	Indica a cor do texto da Label.

	oTMultGet := TMultiget():New(nRow,nCol,bSetGet,oWnd,nWidth,nHeight,oFont,lHScroll,uP09,uP10,uP11,lPixel,uP13,uP14,bWhen,uP16,uP17,lReadOnly,bValid,uP20,uP21,lNoBorder,lVScroll,cLabelText,nLabelPos,oLabelFont,nLabelColor)
//TSimpleEditor(): GoTo ( < nLine> ) -->
Return()
*******************************************************************************
Static Function FComboBox(oCombo, nRow, nCol, aItems, cCombo, nWidth, nHeight, oWnd, bWhen, bChange)
*******************************************************************************

	nRow		:= nRow 	//| numérico Indica a coordenada vertical em pixels ou caracteres.
	nCol		:= nCol 	//| numérico Indica a coordenada horizontal em pixels ou caracteres.
	bSetGet		:= {|u|if(PCount()>0,cCombo:=u,cCombo)} //| bloco de código Indica o bloco de código, no formato {|u| if( Pcount( )>0, := u, ) }, que será executado para atualizar a variável (essa variável deve ser do tipo caracter). Desta forma, se a lista for seqüencial, o controle atualizará com o conteúdo do item selecionado, se for indexada, será atualizada com o valor do índice do item selecionado.
	aItems		:= aItems 	//| vetor Indica uma lista de itens e caracteres que serão apresentados. Essa lista pode ter os seguintes formatos: Seqüencial (Exemplo: {"item1","item2",...,"itemN"}) ou Indexada (Exemplo: {"a=item1","b=item2",...,"n=itemN"}).
	nWidth		:= nWidth 	//| numérico Indica a largura em pixels do objeto.
	nHeight		:= nHeight 	//| numérico Indica a altura em pixels do objeto.
	oDlg		:= oWnd 	//| objeto Indica a janela ou controle visual onde o objeto será criado.
	uP08		:= Nil 		//| numérico Compatibilidade.
	bChange		:= bChange 	//| bloco de código Indica o bloco de código que será executado quando o item selecionado é alterado.
	bValid		:= {||}  	//| bloco de código Indica o bloco de código de validação que será executado quando o conteúdo do objeto for modificado. Retorna verdadeiro (.T.), se o conteúdo é válido; caso contrário, falso (.F.).
	nClrBack	:= Nil 		//| numérico Indica a cor de fundo do objeto.
	nClrText	:= Nil 		//| numérico Indica a cor de texto do objeto.
	lPixel		:= .T. 		//| lógico Indica se considera as coordenadas passadas em pixels (.T.) ou caracteres (.F.).
	oFont		:= Nil 		//| objeto Indica o objeto do tipo TFont utilizado para definir as características da fonte aplicada na exibição do conteúdo do controle visual.
	uP15		:= Nil 		//| caractere Compatibilidade.
	uP16		:= Nil 		//| lógico Compatibilidade.
	bWhen		:= bWhen  	//| bloco de código Indica o bloco de código que será executado quando a mudança de foco da entrada de dados, na janela em que o controle foi criado, estiver sendo efetuada. Observação: O bloco de código retornará verdadeiro (.T.), se o controle permanecer habilitado; caso contrário, retornará falso (.F.).
	uP18		:= Nil 		//| lógico Compatibilidade.
	uP19		:= Nil 		//| vetor Compatibilidade.
	uP20		:= Nil 		//| bloco de código Compatibilidade.
	uP21		:= Nil 		//| caractere Compatibilidade.
	cReadVar	:= 'cCombo' //| caractere Indica o nome da variável, configurada no parâmetro bSetGet, que será manipulada pelo objeto. Além disso, esse parâmetro será o retorno da função ReadVar().
	cLabelText	:= Nil 		//| caractere indica o texto que será apresentado na Label.
	nLabelPos	:= Nil 		//| numérico Indica a posição da label, sendo 1=Topo e 2=Esquerda
	oLabelFont	:= Nil 		//| objeto Indica o objeto, do tipo TFont, que será utilizado para definir as características da fonte aplicada na exibição da label.
	nLabelColor	:= Nil 		//| numérico Indica a cor do texto da Label

	oCombo := TComboBox():New(nRow,nCol,bSetGet,aItems,nWidth,nHeight,oDlg,uP08,bChange,bValid,nClrBack,nClrText,lPixel,oFont,uP15,uP16,bWhen,uP18,uP19,uP20,uP21,cReadVar,cLabelText,nLabelPos,oLabelFont,nLabelColor)

Return()
*********************************************************************
Static Function FGet(oTGet, nRow, nCol, cGet, nWidth, nHeight, cPict, oWnd, bWhen)
*********************************************************************

	nRow		:= nRow 	//| Numérico		Indica a coordenada vertical em pixels ou caracteres.
	nCol		:= nCol 	//| Numérico		Indica a coordenada horizontal em pixels ou caracteres.
	bSetGet		:= {|u| if( Pcount( )>0, cGet:= u, cGet) } //| Bloco de código	Indica o bloco de código, no formato {|u| if( Pcount( )>0, := u, ) }, que será executado para atualizar a variável (essa variável deve ser do tipo caracter). Desta forma, se a lista for sequencial, o controle atualizará com o conteúdo do item selecionado, se for indexada, será atualizada com o valor do índice do item selecionado.
	oDlg		:= oWnd 	//| Objeto			Indica a janela ou controle visual onde o objeto será criado.
	nWidth		:= nWidth 	//| Numérico		Indica a largura em pixels do objeto.
	nHeight		:= nHeight 	//| Numérico		Indica a altura em pixels do objeto.
	cPict		:= cPict 	//| Caracter		Indica a máscara de formatação, do conteúdo, que será apresentada. Verificar Tabela de Pictures de Formatação
	bValid		:= {||If(Empty(cGet),.F.,.T.)} 	//| Bloco de código	Indica o bloco de código de validação que será executado quando o conteúdo do objeto for modificado. Retorna verdadeiro (.T.), se o conteúdo é válido; caso contrário, falso (.F.).
	nClrFore	:= Nil 		//| Numérico		Indica a cor do texto do objeto.
	nClrBack	:= Nil 		//| Numérico		Indica a cor de fundo do objeto.
	oFont		:= Nil 		//| Objeto			Indica o objeto, do tipo TFont, que será utilizado para definir as características da fonte aplicada na exibição do conteúdo do controle visual.
	uP12		:= .T. 		//| Lógico			Compatibilidade.
	uP13		:= Nil 		//| Objeto			Compatibilidade.
	lPixel		:= .T. 		//| Lógico			Indica se considera as coordenadas passadas em pixels (.T.) ou caracteres (.F.).
	uP15		:= Nil 		//| Caracter		Compatibilidade.
	uP16		:= Nil 		//| Lógico			Compatibilidade.
	bWhen		:= bWhen 	//| Bloco de código	Indica o bloco de código que será executado quando a mudança de foco da entrada de dados, no objeto criado, estiver sendo realizada. Se o retorno for verdadeiro (.T.), o objeto continua habilitado; caso contrário, falso (.F.).
	uP18		:= Nil 		//| Lógico			Compatibilidade.
	uP19		:= Nil 		//| Lógico			Compatibilidade.
	bChange		:= {||} 	//| Bloco de código	Indica o bloco de código que será executado quando o estado ou conteúdo do objeto é modificado pela ação sobre o controle visual.
	lReadOnly	:= Nil 		//| Lógico			Indica se o objeto pode ser editado.
	lPassword	:= Nil 		//| Lógico			Indica se, verdadeiro (.T.), o objeto apresentará asterisco (*) para entrada de dados de senha; caso contrário, falso (.F.).
	uP23		:= Nil 		//| Caracter		Compatibilidade.
	cReadVar	:= cGet 	//| Caracter		Indica o nome da variável, configurada no parâmetro bSetGet, que será manipulada pelo objeto. Além disso, esse parâmetro será o retorno da função ReadVar().
	uP25		:= Nil 		//| Caracter		Compatibilidade.
	uP26		:= Nil 		//| Caracter		Compatibilidade.
	uP27		:= Nil 		//| Lógico			Compatibilidade.
	lHasButton	:= Nil 		//| Lógico			Indica se, verdadeiro (.T.), o uso dos botões padrão, como calendário e calculadora.
	lNoButton	:= Nil 		//| Lógico			Oculta o botão F3 (HasButton).
	cLabelText	:= Nil 		//| Caractere		indica o texto que será apresentado na Label.
	nLabelPos	:= Nil  	//| Caractere		Indica a posição da label, sendo 1=Topo e 2=Esquerda
	oLabelFont	:= Nil 		//| Objeto			Indica o objeto, do tipo TFont, que será utilizado para definir as características da fonte aplicada na exibição da label.
	nLabelColor	:= Nil 		//| Numérico		Indica a cor do texto da Label.
	cPlaceHold	:= Nil 		//| Caractere		Define o texto a ser utilizado como place holder, ou seja, o texto que ficará escrito em cor mais opaca quando nenhuma informação tiver sido digitada no campo. (disponível em builds superiores a 7.00.121227P)

	oTGet := TGet():New(nRow,nCol,bSetGet,oDlg,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP12,uP13,lPixel,uP15,uP16,bWhen,uP18,uP19,bChange,lReadOnly,lPassword,uP23,cReadVar,uP25,uP26,uP27,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)

Return()
*********************************************************************
Static Function TelaMultG( cTexto )//| Exibe Texto em Memo para Edicao....
*********************************************************************
	Local oDlgT			:= Nil
	Local lCentered 	:= .T.
	Local oTMultGet 	:= Nil
	Local oGroup		:= Nil
	
	Local cAuxTxt		:= cTexto
	local oBtAdic		:= Nil
	local oBtEdit		:= Nil
	local oBtExcl		:= Nil
	local oBtFech		:= Nil
		
	FWindows(@oDlgT, cNameArq, 700, 600, .T.) //| Monta o Objeto Odlg

	FMultG(@oTMultGet,@cAuxTxt,@oDlgT,299,315)
	
	FGroup(@oGroup,325,025,350,275,oDlgT,"" )//| oGroup,nTop,nLeft,nBottom,nRight,oDlg,cCaption )
	
	FButton(@oBtAdic,330,035,"Incluir"	,oDlgT,{|| AdicLine(oTMultGet:nPos,@cAuxTxt )},050) //| Cria Botao no Odlg
	FButton(@oBtEdit,330,095,"Alterar"	,oDlgT,{|| EditLine(oTMultGet:nPos,@cAuxTxt )},050) //| Cria Botao no Odlg
	FButton(@oBtExcl,330,155,"Excluir"	,oDlgT,{|| ExcLine (oTMultGet:nPos,@cAuxTxt )},050) //| Cria Botao no Odlg
	FButton(@oBtFech,330,215,"Fechar"	,oDlgT,{|| cTexto := cAuxTxt, oDlgT:End()	},050) //| Cria Botao no Odlg
	
	oDlgT:Activate( Nil, Nil, Nil, lCentered )

Return()
*********************************************************************
Static Function AdicLine(nPos,cTxt)// Adiciona Linha Posicionado
*********************************************************************
	Local cLine := ""
	Local nPI   := 0
	Local nPF  	:= 0
	Local lContinua := .T.
	Local aValCG 	:= {}
	
	aLine := RecTxt(nPos,@cTxt,@cLine,@nPI,@nPF, "I")

	While lContinua
	
		lContinua := TelaModLay(aLine, "I", nPI, @cTxt, @aValCG, nPF)
	
	EndDo
	
Return()
*********************************************************************
Static Function EditLine(nPos,cTxt)// Edita Linha Posicionado
*********************************************************************
	Local cLine := ""
	Local nPI   := 0
	Local nPF  	:= 0
	Local aLine := {}
	
	aLine := RecTxt(nPos,@cTxt,@cLine,@nPI,@nPF, "A")

	TelaModLay(aLine, "A", nPI, @cTxt)

Return()
*********************************************************************
Static Function ExcLine(nPos,cTxt)// Exclui Linha Posicionado
*********************************************************************
	Local cLine := ""
	Local nPI   := 0
	Local nPF  	:= 0

	If IW_MsgBox("Confirma a Exclusao da Linha ? ","Atenção !!!", "YESNO")
		aLine := RecTxt(nPos,@cTxt,@cLine,@nPI,@nPF, "A")
	EndIf

Return()
*********************************************************************
Static Function RecTxt(nPos,cTxt,cLine,nPI,nPF, nOperac)// Recorta o texto corretamente para Edicao/Exclusao ou Inclusao
*********************************************************************
	Local cTxtAnt 	:= Substr(cTxt,1,nPos)
	Local cTxtDep 	:= Nil
	Local nPI	  	:= 0
	Local nPF	  	:= 0
	Local aLine		:= {}

	//| Identifica o inicio da Linha posicionado..
	For n := nPos To 1 Step -1
		If Substr(cTxtAnt,n,2) == _ENTER
			nPI := n + 2
			Exit
		EndIf
	Next
	
	If nOperac == "A" //| Alterar ...
		//Recorta para pesquisa o texto apartir do incio da linha
		cTxtDep := Substr(cTxt,nPI)
	
		//| Identifica a posicao final da linha
		nPF 	:= ( At(_ENTER,cTxtDep ) - 1 )

		//| Seleciona o texto da  linha que se esta posicionado
		cLine 	:= Substr(cTxt,nPI,nPF)

		// Converte a Linha Texto em Array
		aLine 	:= StrTokArr(cLine,';')
	
		// Remove a Linha do Texto que vai ser editado....
		If ( nPI > 0 )
			cTxt 	:= Substr(cTxt,1,nPI-1) + Substr(cTxt,nPI+nPF+2) //| 3 = ENTER + 1
		Else
			cTxt 	:= Substr(cTxt,nPF+3)
		EndIf
		
		//Alert(" cLine: " + cLine)
	EndIf
	
Return(aLine)
*********************************************************************
Static Function TelaModLay(aLine, nOperac, nPI, cTxt, aValCG, nPF)//| Tela para Modificar Linha no MultGet
*********************************************************************
	Local oWML 		:= Nil
	Local oGroup	:= Nil
	Local oSay		:= Nil

	local oComTp	:= Nil
	local oGetL1	:= Nil
	local oGetC1	:= Nil
	local oGetL1	:= Nil
	local oGetC1	:= Nil
	local oComCr	:= Nil
	local oComTa	:= Nil
	local oGetTx	:= Nil
	local oComFo	:= Nil
	Local lContinua := .F.

	Local lCentered := .T.
	Local cCaption 	:= "Incluir/Alterar/Excluir Linha"
	Local bValid    := {|| SaveLin(aValCG, aBW, nPI , @cTxt, oWML, nOperac), .T. } //| bloco de código  Indica se o conteúdo do diálogo é válido. Se o retorno for falso (.F.), o diálogo não será fechado quando a finalização for solicitada.
	
	Local aCombO 	:= {"L=Linha","R=Retangulo","B=Box","T=Texto","I=Imagem","C=Comentario"}
	Local aCombC 	:= {"PT=Preto","BR=Branco","VE=Vermnelho","CI=Cinza","AM=Amarelo","AZ=Azul","LA=Laranja" }
	
	Local aCombF 	:= {"N=Normal","B=Negrito","I=Italico","A=Neg.e Ita." }
	
	Local bChange 	:= {|| lContinua:=.T. , oWML:End() } //, Recurso(aLine, "E", nPI, @cTxt, aValCG, oWAu)  }
	
	Local aLabTO	:= {} //{"Qual Objeto ?", "Posicao Linha 1","Posicao Coluna 1","Posicao Linha 2","Posicao Coluna 2","Selecione uma Cor","Defina o Tamanho","Texto ou Descricao"} //|Array de Label conforme tipo de Objeto Selecionado...
	//Local aValCG	:= {} //{aCombT[2],"9999","9999","9999","9999",aCombC[3],"9999",Space(250)}
	Local aBW		:= {}
	
	Local cCombT 	:= "" //aCombT[2]
	Local cCombC 	:= "" //aCombC[3]
	Local cCombF	:= ""
	
	Default aValCG 	:= {}
	
	Private aCombT 	:= {}
	Private lValRec := eVal( {|| Len(aValCG) < 9} ) // Usado em Teste de Recursividade

//	If ValType(oWML) <> "U" //| Tratamento de Recursividade.... 
//		oWML:End()
//		oWML := Nil
//	EndIf 
	
	//|Valida Montar Linha Invalida ou incompleta.....  
	If Len(aLine) < 9 .And. nOperac == "A" .And. lValRec
		Iw_MsgBox("Linha Inválida !!! Não Possui as 9 Posições !!! Verifique.... ","Validação","ALERT")
		Return()
	Endif
	
	
	//| Monta a Janela 
	FWindows(@oWML, cCaption, 060, 905)//| oWML, cCaption, nBottom, nRight

	//| Inicializa as variaveis conforme a operacao...
	InitVar(@aValCG, nOperac, aLine )
	
	//| Atualiza os Labels de acordo com o Tipo do Objeto...
	AtuLabel(@aLabTO,@aBW, aValCG[TIPO], nOperac )
	
	
	//| Monta o Objeto Group
	FGroup(@oGroup,002,002,030,452,oWML,"") //| oGroup,nTop,nLeft,nBottom,nRight,oWML,cCaption

	FSay(@oSay, 005, 005, aLabTO[TIPO]	, oWML, "", Nil, Nil) //| oSay, nRow, nCol, cText, oWML, cPicture, oFont, nClrText
	FSay(@oSay, 005, 055, aLabTO[LIN1]	, oWML, "", Nil, Nil) //| oSay, nRow, nCol, cText, oWML, cPicture, oFont, nClrText
	FSay(@oSay, 005, 105, aLabTO[COL1]	, oWML, "", Nil, Nil) //| oSay, nRow, nCol, cText, oWML, cPicture, oFont, nClrText
	FSay(@oSay, 005, 155, aLabTO[LIN2]	, oWML, "", Nil, Nil) //| oSay, nRow, nCol, cText, oWML, cPicture, oFont, nClrText
	FSay(@oSay, 005, 205, aLabTO[COL2]	, oWML, "", Nil, Nil) //| oSay, nRow, nCol, cText, oWML, cPicture, oFont, nClrText
	FSay(@oSay, 005, 255, aLabTO[COR]	, oWML, "", Nil, Nil) //| oSay, nRow, nCol, cText, oWML, cPicture, oFont, nClrText
	FSay(@oSay, 005, 305, aLabTO[TAM]	, oWML, "", Nil, Nil) //| oSay, nRow, nCol, cText, oWML, cPicture, oFont, nClrText
	FSay(@oSay, 005, 355, aLabTO[TEXTO]	, oWML, "", Nil, Nil) //| oSay, nRow, nCol, cText, oWML, cPicture, oFont, nClrText
	FSay(@oSay, 005, 405, aLabTO[FORM]	, oWML, "", Nil, Nil) //| oSay, nRow, nCol, cText, oWML, cPicture, oFont, nClrText
	
	FComboBox(	@oComTp	, 013, 005, aCombO			, @aValCG[TIPO]	, 045, 035, oWML, aBW[TIPO] , bChange)//| oCombo, nRow, nCol, aItems, cCombo, nWidth, nHeight, oWnd
	FGet(		@oGetL1	, 013, 055, @aValCG[LIN1]	, 045			, Nil, Nil, oWML, aBW[LIN1] )//| oTGet, nRow, nCol, cGet, nWidth, nHeight, cPict, oWnd)
	FGet(		@oGetC1	, 013, 105, @aValCG[COL1]	, 045			, Nil, Nil, oWML, aBW[COL1] )
	FGet(		@oGetL1	, 013, 155, @aValCG[LIN2]	, 045			, Nil, Nil, oWML, aBW[LIN2] )
	FGet(		@oGetC1	, 013, 205, @aValCG[COL2]	, 045			, Nil, Nil, oWML, aBW[COL2] )
	FComboBox(	@oComCr	, 013, 255, aCombC			, @aValCG[COR]	, 045, 035, oWML, aBW[COR]  )
	FComboBox(	@oComTa	, 013, 305, aCombT			, @aValCG[TAM]	, 045, 035, oWML, aBW[TAM]  )
	FGet(		@oGetTx	, 013, 355, @aValCG[TEXTO]	, 045			, Nil, Nil, oWML, aBW[TEXTO])
	FComboBox(	@oComFo	, 013, 405, aCombF			, @aValCG[FORM]	, 045, 035, oWML, aBW[FORM] )
	
	oWML:Activate( Nil, Nil, Nil, lCentered, bValid )

Return(lContinua)
*********************************************************************
Static Function SaveLin(aValCG, aBW, nPI , cTxt, oWML, nOperac)//| SAlva a Linha Editada ou Incluida...
*********************************************************************
	Local cLine := ""
	
	If  Alltrim(ProcName(2)) == "ACTIVATE" //| Apenas Controle Recursividade TelaModLay
	 
		cLine += aValCG[TIPO] + ";"
		cLine += Iif(Eval(aBW[LIN1])	,aValCG[LIN1]	,"    " 	) + ";"
		cLine += Iif(Eval(aBW[COL1])	,aValCG[COL1]	,"    " 	) + ";"
		cLine += Iif(Eval(aBW[LIN2])	,aValCG[LIN2]	,"    " 	) + ";"
		cLine += Iif(Eval(aBW[COL2])	,aValCG[COL2]	,"    " 	) + ";"
		cLine += Iif(Eval(aBW[COR])		,aValCG[COR] 	,"  " 		) + ";"
		cLine += Iif(Eval(aBW[TAM])		,StrZero(Val(aValCG[TAM]),2) ,"  " )+ ";"
		cLine += Iif(Eval(aBW[TEXTO])	,Alltrim(aValCG[TEXTO])+" ",Space(250) )+ ";"
		cLine += Iif(Eval(aBW[FORM])	,aValCG[FORM] 	," " 		)+ ";"
   
		cLine += _ENTER

		If (nPI == 0) .And. nOperac == "A"
			//nPI 	:= 1   
			cTxt 	:= cLine + cTxt
		Else
			If nOperac == "I"
		    
				If (nPI == 0)
					cTxtDep := cTxt
					nPI := 1
				Else
					cTxtDep := Substr(cTxt,nPI)
				EndIF
				
				//| Identifica a posicao final da linha
				nPF 	:= ( At(_ENTER,cTxtDep ) )
		
				cTxt := Substr(cTxt,1,nPI+nPF) + cLine + Substr(cTxt,nPI+nPF+1)
			
			ElseIf nOperac == "A"
			
				cTxt := Substr(cTxt,1,nPI-1) + cLine + Substr(cTxt,nPI)
			
			EndIf
			
		EndIf
	
	EndIf
	
Return(.T.)
*********************************************************************
Static Function InitVar( aValCG, nOperac, aLine) //| Inicializa as variaveis envolvidas TelaModLay
*********************************************************************


	If nOperac == "A" .And. lValRec// Edicao

		Aadd( aValCG, aLine[TIPO] )
		Aadd( aValCG, aLine[LIN1] )
		Aadd( aValCG, aLine[COL1] )
		Aadd( aValCG, aLine[LIN2] )
		Aadd( aValCG, aLine[COL2] )
		Aadd( aValCG, aLine[COR] )
		Aadd( aValCG, StrZero(Val(aLine[TAM]) /** -1*/ , 2 ) )
		Aadd( aValCG, aLine[TEXTO] + Space(250-Len(aLine[TEXTO])) )
		Aadd( aValCG, aLine[FORM] )
 	
	ElseIf nOperac == "I"  // Adicao de Linha

		Aadd( aValCG, aValDef[TIPO] )
		Aadd( aValCG, aValDef[LIN1] )
		Aadd( aValCG, aValDef[COL1] )
		Aadd( aValCG, aValDef[LIN2] )
		Aadd( aValCG, aValDef[COL2] )
		Aadd( aValCG, aValDef[COR]  )
		Aadd( aValCG, aValDef[TAM]	 )
		Aadd( aValCG, aValDef[TEXTO])
		Aadd( aValCG, aValDef[FORM] )
	EndIf

Return()
*********************************************************************
Static Function AtuLabel(aLabTO, aBW , cQuem, nOperac )
*********************************************************************
	Local aBwInc := { {||.T.}, {||.T.},{||.T.},{||.T.},{||.T.},{||.T.},{||.T.},{||.T.},{||.F.}} //|Array de Label conforme tipo de Objeto Selecionado...
 	
	aCombT  :=  {"00","01","02","03","04","05","06","08","10","12","14","16","22" }
 	
	Do Case
	Case cQuem == "L" // Linha
		aLabTO 	:=  { "Qual Objeto ?", "Ponto Superior","Ponto Esquerdo","Ponto Inferior","Ponto Direito","Escolha a Cor","Espessura","Comnetario",""} //|Array de Label conforme tipo de Objeto Selecionado...
		aBW 	:=  { {||!lValRec}, {||.T.},{||.T.},{||.T.},{||.T.},{||.T.},{||.T.},{||.T.},{||.F.}} //|Array de Label conforme tipo de Objeto Selecionado...
		aCombT  :=  {"00","-1","-2","-4","-6","-8","01","02","03","04","05","06","08","10","12","14","16","22" }
	Case cQuem == "R" // Retangulo
		aLabTO :=  {"Qual Objeto ?", "Ponto Superior","Ponto Esquerdo","Ponto Inferior","Ponto Direito","Escolha a Cor","Espessura","Comnetario",""}//|Array de Label conforme tipo de Objeto Selecionado...
		aBW 	:=  { {||!lValRec}, {||.T.},{||.T.},{||.T.},{||.T.},{||.T.},{||.F.},{||.T.},{||.F.}}//|Array de Label conforme tipo de Objeto Selecionado...
	Case cQuem == "B" // Box
		aLabTO :=  {"Qual Objeto ?", "Ponto Superior","Ponto Esquerdo","Ponto Inferior","Ponto Direito","","Espessura","Comnetario",""}//|Array de Label conforme tipo de Objeto Selecionado...
		aBW 	:=  { {||!lValRec}, {||.T.},{||.T.},{||.T.},{||.T.},{||.F.},{||.T.},{||.T.},{||.F.}}//|Array de Label conforme tipo de Objeto Selecionado...
	Case cQuem == "T"// Texto
		aLabTO 	:=  {"Qual Objeto ?", "Ponto Superior","Ponto Esquerdo","","","Escolha a Cor","Espessura","Texto","Formatacao"}//|Array de Label conforme tipo de Objeto Selecionado...
		aBW 	:=  { {||!lValRec}, {||.T.},{||.T.},{||.F.},{||.F.},{||.T.},{||.T.},{||.T.},{||.T.}}//|Array de Label conforme tipo de Objeto Selecionado...
		aCombT  :=  {"06" ,"08","10","12","14","16","18","20","22","24","36","48","60","72" }
	Case cQuem == "I" // Imagem
		aLabTO :=  {"Qual Objeto ?", "Ponto Superior","Ponto Esquerdo","Qual Largura","Qual Altura","","","Caminho da Imagem",""}//|Array de Label conforme tipo de Objeto Selecionado...
		aBW 	:=  { {||!lValRec}, {||.T.},{||.T.},{||.T.},{||.T.},{||.F.},{||.F.},{||.T.},{||.F.}}//|Array de Label conforme tipo de Objeto Selecionado...
	Case cQuem == "C" // Comentario
		aLabTO :=  {"Qual Objeto ?", "","","","","","","Comentario",""}//|Array de Label conforme tipo de Objeto Selecionado...
		aBW 	:=  { {||!lValRec}, {||.F.},{||.F.},{||.F.},{||.F.},{||.F.},{||.F.},{||.T.},{||.F.}}//|Array de Label conforme tipo de Objeto Selecionado...
	EndCase
	
	If nOperac == "I" .And. lValRec// Adicao
		aBW := aBwInc
	EndIf
		
Return()
*********************************************************************
Static Function ASFile(lOper, cTitulo )//| Abre/Salva Arquivo
*********************************************************************

	Local cMascara		:= "Arquivo Layout (.lay)|*.lay" //| Caracter	Indica o nome do arquivo ou máscara.
	Local cTitulo		:= cTitulo 			//| Caracter	Indica o título da janela. Caso o parâmetro não seja especificado, o título padrão será apresentado.
	Local nMascPad		:= 0 				//| Numérico	Indica o número da máscara.
	Local cDirIni		:= "\" 				//| Caracter	Indica o diretório inicial.
	Local lSalvar		:= lOper 			//| Lógico	Indica se é um "save dialog - (.F.)" ou um "open dialog - .T. ".
	Local nOpcoes		:= GETF_LOCALHARD	//| Numérico	Indica a opção de funcionamento. Para mais informações das funcionalidades disponíveis, consulte a área Observações.
	Local lArvore		:= .F.				//| Lógico	Indica se, verdadeiro (.T.), apresenta o árvore do servidor; caso contrário, falso (.F.).
	Local lKeepCase	:= .T. 				//| Lógico	Indica se, verdadeiro (.T.), mantém o case original; caso contrário, falso (.F.).

	Default cTitulo := If(lOper==_SAVE,"Salvar arquivo...","Abrir arquivo...")

	cPathFile := cGetFile( cMascara, cTitulo, nMascpad, cDirIni, lSalvar, nOpcoes, lArvore, lKeepCase)

	cNameArq := cPathFile
	
	If !Empty(cPathFile)
		WRFile( cPathFile, lOper )
	EndIf
	
Return(cPathFile)
*******************************************************************************
Static Function WRFile( cArq, lOper )//| Escreve/Le Arquivo
*******************************************************************************

	Local cArq			:= cArq
	Local nModo			:= If(lOper==_SAVE, 1, 0 ) //| 0-> READ | 1-> WRITE | 2-> READ_WRITE |
	Local cBuffer		:= ""
	Local lChangeCase	:= .T. //| Case sensitive .T. , .F. |
	Local nHandle		:= 0 //FCREATE(cArq, nModo)
	Local aLine			:= {}
	
//| Tipo;Lin1;Col1;Lin2;Col2 |
//| L   ;10  ;10  ;10  ;10   |
//| B   ;10  ;10  ;11  ;12   |

	If ( lOper == _SAVE )
	
		nHandle	:= FCreate(cArq, nModo)
		FWrite(nHandle, cTexto, Len(cTexto))
		FClose(nHandle)
	Else
		cTexto := ""
		
		FT_FUse(cArq)
		FT_FGoTop()
		While !FT_FEOF()

			cLine  := FT_FReadLn()

			cTexto += cLine + _ENTER

			FT_FSkip()
		EndDo

		FT_FUse()
	
	EndIf
	
Return()
*******************************************************************************
Static Function FNTOC(cCor, cTipo)//| Converte a Nomenclatura da Cor (VE) na Cor em Hexa ou Objeto.... Conforme Parametro
*******************************************************************************
	Local xColor := Nil

	If cTipo == "H" //| Retorna a Cor em Hexadecimal
		Do Case
		Case cCor == "VE"
			xColor := CLR_HRED
		Case cCor == "CI"
			xColor := CLR_GRAYH
		Case cCor == "AM"
			xColor := CLR_YELLOW
		Case cCor == "AZ"
			xColor := CLR_BLUE
		Case cCor == "LA"
			xColor := CLR_ORANGE
		OtherWise
			xColor := CLR_BLACK
		EndCase

	ElseIf cTipo == "O" //| Retorna a Cor em Hexadecimal
		Do Case
		Case aLines[nL][COR] == "VE"
			oBrush 	:= oBruVE
			cExporta += " oBrush := oBruVE " +  _ENTER
		Case aLines[nL][COR] == "CI"
			oBrush 	:= oBruCI
			cExporta += " oBrush := oBruCI " +  _ENTER
		Case aLines[nL][COR] == "AM"
			oBrush 	:= oBruAM
			cExporta += " oBrush := oBruAM " +  _ENTER
		Case aLines[nL][COR] == "AZ"
			oBrush := oBruAZ
			cExporta += " oBrush := oBruAZ " +  _ENTER
		Case aLines[nL][COR] == "LA"
			oBrush := oBruVD
			cExporta += " oBrush := oBruVD " +  _ENTER
		OtherWise
			oBrush := Nil
			cExporta += " oBrush := Nil " +  _ENTER
		EndCase
		
		xColor := oBrush
	EndIf

	
Return(xColor)
*******************************************************************************
Static Function XC(xVar)//| Converte Qualquer Variavel para Texto
*******************************************************************************

Return( cValToChar(xVar) )
*******************************************************************************
Static Function FRefresh(Objeto)
*******************************************************************************

	Objeto:Refresh()

Return()
*******************************************************************************
Static Function MCabExporta() //| Monta o Cabecalho do Exporta...
*******************************************************************************
	cExporta := "#Include 'Totvs.ch'" + _ENTER + _ENTER
	cExporta += "#Define CLR_ORANGE      RGB( 255, 229, 204 )" + _ENTER
	cExporta += "#Define CLR_GRAYH       RGB( 224, 224, 224 )" + _ENTER
	cExporta += "#Define CLR_GRAY        RGB( 128, 128, 128 )" + _ENTER
	cExporta += "#Define CLR_HBLUE       RGB(   0,   0, 255 )" + _ENTER
	cExporta += "#Define CLR_HGREEN      RGB(   0, 255,   0 )" + _ENTER
	cExporta += "#Define CLR_HCYAN       RGB(   0, 255, 255 )" + _ENTER
	cExporta += "#Define CLR_HRED        RGB( 255,   0,   0 )" + _ENTER
	cExporta += "#Define CLR_HMAGENTA    RGB( 255,   0, 255 )" + _ENTER
	cExporta += "#Define CLR_YELLOW      RGB( 255, 255,   0 )" + _ENTER
	cExporta += "#Define CLR_WHITE       RGB( 255, 255, 255 )" + _ENTER  + _ENTER
	

	cExporta += "****************************************************" + _ENTER
	cExporta += "User Function Test_Imp_Grafico()" + _ENTER
	cExporta += "****************************************************" + _ENTER + _ENTER
	cExporta += "Local cFilePrint := CriaTrab( ,.F. ) + '.pdf' " + _ENTER
	cExporta += "Local lAdjustToLegacy := .T." + _ENTER
	cExporta += "Local cPathInServer := '\system\pdf\'" + _ENTER
	cExporta += "Local lDisableSetup := .T." + _ENTER
	cExporta += "Local lTReport := .F." + _ENTER
	cExporta += "Local cPrinter :=  ''" + _ENTER
	cExporta += "Local lServer := .F." + _ENTER
	cExporta += "Local lPDFAsPNG := .F." + _ENTER
	cExporta += "Local lRaw := .F." + _ENTER
	cExporta += "Local lViewPDF := .T." + _ENTER
	cExporta += "Local nQtdCopy := NIL" + _ENTER
	cExporta += "Local lSetView := .T." + _ENTER + _ENTER
	cExporta += "Local oBruVE := TBrush():New2(,CLR_HRED	)" + _ENTER
	cExporta += "Local oBruCI := TBrush():New2(,CLR_GRAYH	)" + _ENTER
	cExporta += "Local oBruAM := TBrush():New2(,CLR_YELLOW	)" + _ENTER
	cExporta += "Local oBruAZ := TBrush():New2(,CLR_BLUE 	)" + _ENTER
	cExporta += "Local oBruVD := TBrush():New2(,CLR_ORANGE	)" + _ENTER
	cExporta += "Local oBruBR := TBrush():New2(,CLR_WHITE	)" + _ENTER + _ENTER
	cExporta += "Local oTFont " + _ENTER
	cExporta += "Local oPrn " + _ENTER + _ENTER
	
	cExporta += "Local nDevice := "+XC(nDevice)+" " + _ENTER
	cExporta += "Local cLocalPath := '" + cLocalPath + "' " + _ENTER
	cExporta += "Local nPaperSize := "+XC(nPaperSize)+" " + _ENTER	+ _ENTER
	
	cExporta += "oPrn := FWMSPrinter():New(cFilePrint, nDevice, lAdjustToLegacy ,cPathInServer, lDisableSetup, lTReport, @oPrn, cPrinter, lServer, lPDFAsPNG, lRaw, lViewPDF )" + _ENTER

	If MV_PAR04 == 1
		cExporta += "oPrn:SetPortrait() " + _ENTER
	Else
		cExporta += "oPrn:SetLandscape() " + _ENTER
	EndIf
	cExporta += "oPrn:SetPaperSize(nPaperSize)" + _ENTER
	cExporta += "oPrn:SetMargin("+XC(MV_PAR05)+","+XC(MV_PAR06)+","+XC(MV_PAR07)+","+XC(MV_PAR08)+")" + _ENTER
	cExporta += "oPrn:SetViewPDF(lSetView) " + _ENTER + _ENTER
 

Return(cExporta)
*******************************************************************************
Static Function VerSx1(lPerg) //| Verifica Se Existe as Perguntas e Faz os devidos ajustes....
*******************************************************************************

//PutS(cPerg    ,"01"    ,cStringP                       ,cStringE,cStringI  ,"mv_ch1"  ,"D"    ,8         ,0         ,0        ,"G"   ,"","","","","mv_par01",""       ,""       ,""       ,""     ,""        ,""        ,""        ,""         ,""         ,""         ,""        ,""        ,""        ,""      ,""        ,""        ,aHelpPor,aHelpIng,aHelpEsp) 
	PutSx1("GLAYMON","01"    ,"Escolha o Tipo de Impressao:" ,""      ,""        ,"MV_CH0"  ,"N"    ,1	       ,0         ,1        ,"C"   ,"","","","","MV_PAR01","PDF"    ,"PDF"    ,"PDF"    ,""     ,"SPOOL"   ,"SPOOL"   ,"SPOOL"   ,""         ,""         ,""         ,""        ,""        ,""        ,""      ,""        ,""        ,{""}    ,{""}    ,{""}    )
	PutSx1("GLAYMON","02"    ,"Salvar Arquivo PDF em ?"      ,""      ,""        ,"MV_CH1"  ,"C"    ,60        ,0         ,0        ,"F"   ,"","","","","MV_PAR02","56"     ,""       ,""       ,""     ,""        ,""        ,""        ,""         ,""         ,""         ,""        ,""        ,""        ,""      ,""        ,""        ,{""}    ,{""}    ,{""}    )
	PutSx1("GLAYMON","03"    ,"Tamanho da Pagina ?"          ,""      ,""        ,"MV_CH2"  ,"N"    ,1         ,0         ,1        ,"C"   ,"","","","","MV_PAR03","A4"     ,"A4"     ,"A4"     ,""     ,"A3"      ,"A3"      ,"A3"      ,"Executivo","Executivo","Executivo","Tabloide","Tabloide","Tabloide","Carta" ,"Carta"   ,"Carta"   ,{""}    ,{""}    ,{""}    )
	PutSx1("GLAYMON","04"    ,"Orientacao da  Impressao ?"   ,""      ,""        ,"MV_CH3"  ,"N"    ,1         ,0         ,1        ,"C"   ,"","","","","MV_PAR04","Retrato","Retrato","Retrato",""     ,"Paisagem","Paisagem","Paisagem",""         ,""         ,""         ,""        ,""        ,""        ,""      ,""        ,""        ,{""}    ,{""}    ,{""}    )
	PutSx1("GLAYMON","05"    ,"Margem Esquerda (Milimetro):" ,""      ,""        ,"MV_CH4"  ,"N"    ,5         ,0         ,0        ,"G"   ,"","","","","MV_PAR05",""       ,""       ,""       ,""     ,""        ,""        ,""        ,""         ,""         ,""         ,""        ,""        ,""        ,""      ,""        ,""        ,{""}    ,{""}    ,{""}    )
	PutSx1("GLAYMON","06"    ,"Margem Superior (Milimetro):" ,""      ,""        ,"MV_CH5"  ,"N"    ,5         ,0         ,0        ,"G"   ,"","","","","MV_PAR06",""       ,""       ,""       ,""     ,""        ,""        ,""        ,""         ,""         ,""         ,""        ,""        ,""        ,""      ,""        ,""        ,{""}    ,{""}    ,{""}    )
	PutSx1("GLAYMON","07"    ,"Margem Direita  (Milimetro):" ,""      ,""        ,"MV_CH6"  ,"N"    ,5         ,0         ,0        ,"G"   ,"","","","","MV_PAR07",""       ,""       ,""       ,""     ,""        ,""        ,""        ,""         ,""         ,""         ,""        ,""        ,""        ,""      ,""        ,""        ,{""}    ,{""}    ,{""}    )
	PutSx1("GLAYMON","08"    ,"Margem Inferior (Milimetro):" ,""      ,""        ,"MV_CH7"  ,"N"    ,5         ,0         ,0        ,"G"   ,"","","","","MV_PAR08",""       ,""       ,""       ,""     ,""        ,""        ,""        ,""         ,""         ,""         ,""        ,""        ,""        ,""      ,""        ,""        ,{""}    ,{""}    ,{""}    )

	Pergunte("RLAYMON",lPerg)

//| Ajusta as Variaveis Conforme as Perguntas....
	If !lperg
	 
	 //| Tipo de Impressao 
		Do Case
		Case MV_PAR01 == 1
			nDevice := 6 //| PDF
		Case MV_PAR01 == 2
			nDevice := 2 //| SPOOL
		End Case

		cLocalPath := Alltrim(MV_PAR02)

	//| Tamanho da Pagina
		Do Case
		Case MV_PAR03 == 1
			nPaperSize := 9 //| A4
		Case MV_PAR03 == 2
			nPaperSize := 8 //| A3
		Case MV_PAR03 == 3
			nPaperSize := 7 //| Executive
		Case MV_PAR03 == 4
			nPaperSize := 3 //| Tabloid
		Case MV_PAR03 == 5
			nPaperSize := 1 //| Letter
		End Case


	//| Orientacao Pagina
		If MV_PAR04 == 1
			bOrientaPag := {|| oPrn:SetPortrait()  }
		Else
			bOrientaPag := {|| oPrn:SetLandscape() }
		EndIf
	
	//| Margens 
		bSetMargin := {|| oPrn:SetMargin(MV_PAR05, MV_PAR06, MV_PAR07, MV_PAR08 ) }

	EndIf


Return()
