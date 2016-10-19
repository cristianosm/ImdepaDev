#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TOTVS.CH"

// Propriedades de alinhamento do TWindowDock
#Define AllAlign  1
#Define LeftAlign 2
#Define RightAlign 3
#Define TopAlign 4
#Define BottomAlign 5
// --------------------------------------------
// Exemplo de janelas do tipo destacavel (Dock)
// --------------------------------------------
user function Tst_TMainDock()

	Private oMainDock
	Private DockDlg1
	Private DockDlg2
	Private DockDlg3
	Private cTGet1 := "Teste TGet 01"
	Private cTGet2 := "Teste TGet 02"
	Private nJanela := 0
	DEFINE DIALOG oDlgMain FROM 10,10 TO 800,800 TITLE "Exemplo TMainDock/TWindowDock" PIXEL COLOR CLR_BLACK,RGB(212,208,200)
	oPanelLeft := tPanel():New(0,0,"",oDlgMain,,,,,RGB(132,172,196),06,06)
	oPanelLeft:align := CONTROL_ALIGN_LEFT

	oDlg := tPanel():New(0,0,"",oDlgMain,,,,,RGB(132,172,196),100,100)
	oDlg:align := CONTROL_ALIGN_ALLCLIENT
	// Splitter para montagem da tela
	oSplitter := tSplitter():New( 0,0,oDlg,260,184 )
	oSplitter:align := CONTROL_ALIGN_ALLCLIENT

	// o TMainDock X uma Classe do tipo Painel que pode receber
	// janelas destacaveis da Classe TWindowDock
	oMainDock := TMainDock():New(0,0,300,100,oSplitter)
	oMainDock:align := CONTROL_ALIGN_LEFT
	style := " QMainWindow{margin-right: 5px}"
	style += " QMainWindow::separator {background: rgb(132,172,196); width: 10px; height: 10px; } "
	oMainDock:SetCss(style)

	// Define o objeto central da TMainDock, que pode ser qualquer
	// objeto visual, no exemplo foi usado um TMultiget
	cTMultiget1 := "TMultiget inserido pelo mXtodo setCentralWidget()"
	oTMultiget1 := TMultiget():New(00,00,{|u|if(Pcount()>0,cTMultiget1:=u,cTMultiget1)},;
	oMainDock,400,400,,,,,,.T.)
	oMainDock:setCentralWidget( oTMultiget1 )
	// Painel lateral para os botXes auxiliares
	oPaneAux := TPanel():New(0,0,"",oSplitter,,.F.,.F.,,,200,200,.T.,.F.)
	oPaneAux:align := CONTROL_ALIGN_ALLCLIENT

	// BotXes para auxiliar na criaXXo dos Docks
	TButton():New(02,02," Cria TWindowDock X Esquerda ",oPaneAux,{|| NewDock(LeftAlign, .F.) },96,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(12,02," Cria TWindowDock a Direita ",oPaneAux,{|| NewDock(RightAlign, .F.) },96,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(22,02," Cria TWindowDock ao Topo ",oPaneAux,{|| NewDock(TopAlign, .F.) },96,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(32,02," Cria TWindowDock ao RodapX ",oPaneAux,{|| NewDock(BottomAlign, .F.) },96,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(52,02," Cria TWindowDock Destacado ",oPaneAux,{|| NewDock(AllAlign, .T.) },96,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(62,02," A Direita sem restriXXo",oPaneAux,{|| ;
	dockAux:=NewDock(AllAlign,.F.),oMainDock:addDockWidget(dockAux,RightAlign) };
	,96,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(72,02," Conout ",oPaneAux,{|| conout("") },96,010,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE DIALOG oDlgMain CENTERED ON INIT ( NewDock(LeftAlign,.F.) )
Return
// --------------------------------------------
// FunXXo para criar janelas do tipo Dock
// --------------------------------------------
Static Function NewDock(nType, isFloat)
	nJanela++
	cTexto := "Caption Janela: " + strZero(nJanela,2)
	// Cria janela do tipo Dock
	DockDlg  := TWindowDock():New( 0,0,200,300,cTexto,oMainDock,isFloat,nType )
	style += " QDockWidget{ margin: 50px; color: #0052AF; titlebar-close-icon: url(rpo:fwocn_lyr_close.png); titlebar-normal-icon: url(rpo:fwocn_lyr_restore.png); }"
	style += " QDockWidget::title{ background-color: rgb(132,172,196); border-style: solid; "+;
	"    border-image: url(rpo:fwstd_lyr_title.png) 10 10 10 10 stretch; "+;
	"    border-top-width: 06px; "+;
	"    border-left-width: 10px; "+;
	"    border-right-width: 10px; "+;
	"    border-bottom-width: 0px; }"
	DockDlg:SetCss(style)

	// CodeBlocks de troca de "Dock" da janela e fechamento da janela
	DockDlg:bChange := {|x| conout('TWindowDock - bChange: ' + iif(x,"Destacada(True)","Ancorada(False)")) }
	DockDlg:bValid  := {| | conout('TWindowDock - bValid') }

	// Insere painel na  TWindowDock
	// OBS: Painel deve ser adicionado a janela atravez do mXtodo addWidget()
	//      e os objetos visuais da janela devem ser inseridos neste painel
	oPanelTop := tPanel():New(0,0,"",DockDlg,,,,,RGB(132,172,196),100,100)
	oPanelTop:SetCss("QLabel{border: 1px solid #7B92A0;}")
	DockDlg:addWidget(oPanelTop)

	//*******************************************************
	// IMPORTANTE: O mXtodo addDockWidget() deve ser chamado
	// apXs a criaXXo do Painel, para que haja ajuste do
	// tamanho da janela TWindowDock
	//*******************************************************
	//*******************************************************
	// Se a janela TWindowDock for criada Ancorada
	// ela deve obrigatoriamente ser inserida na TMainDock
	// atraves do metodo addDockWidget()
	//*******************************************************
	if !isFloat
		oMainDock:addDockWidget( DockDlg, nType )
	endif
	//-------------------------------------------------------
	// Cria objetos no Painel que foi inserido no TWindowDock
	oTGet1 := TGet():New( 02,02,{||cTGet1},oPanelTop,096,009,;
	"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet1,,,, )
	oTGet1:bValid := {|| conout("Valid do oTGet1") }
	oTGet2 := TGet():New( 14,02,{||cTGet2},oPanelTop,096,009,;
	"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet2,,,, )
	oTGet2:bValid := {|| conout("Valid do oTGet2") }

	oBtnDock := TButton():New(28,02,"BotXo: "+strZero(nJanela,2),oPanelTop,;
	{|| conout("BotXo Precionado") },;
	50,14,,,.F.,.T.,.F.,,.F.,,,.F. )
	//-------------------------------------------------------

	Return( DockDlg )
