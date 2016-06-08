#Include 'Protheus.ch'

User Function Teste_WebView()


	DEFINE DIALOG oDlg TITLE "Exemplo TIBrowser" FROM 180,180 TO 550,700 PIXEL

	oTIBrowser := TIBrowser():New(0,0,260,170, "http://www.totvs.com.br",oDlg )

	TButton():New( 172, 002, "Navigate", oDlg,;
		{|| oTIBrowser:Navigate( "http://www.rm.com.br" ) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )

	TButton():New( 172, 052, "GoHome", oDlg,;
		{|| oTIBrowser:GoHome() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )

	TButton():New( 172, 102, "Print", oDlg,;
		{|| oTIBrowser:Print() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE DIALOG oDlg CENTERED


Return()

