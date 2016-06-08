#include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ChgSrvDir       ³Autor  ³Agostinho Lima  ³ Data ³ 09/07/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ponto de entrada que  possibilita a alteração do diretório  ³±±
±±³          ³ utilizado pelo sistema para a geração dos relatórios        ³±±
±±³          ³ (SetPrint ou Personalizáveis) no servidor durante a sua     ³±±
±±³          ³ execução.                                                   ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GERAL     						                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function ChgSrvDir()

Local _NomeUser := CUSERNAME
Local _cPasta   := "\RELATO\"
Local _aRetUser := {}

// Defino a ordem
PswOrder(2) // Ordem de nome

// Efetuo a pesquisa, definindo se pesquiso usuário ou grupo
If PswSeek(_NomeUser,.T.)

   // Obtenho o resultado conforme vetor
   _aRetUser := PswRet(2)

   _cPasta  := upper(alltrim(_aRetUser[1,3]))

EndIf

Return (_cPasta)


//#include "TOTVS.CH"User Function TAvPrinter()  DEFINE DIALOG oDlg TITLE "Exemplo TAvPrinter" FROM 180,180 TO 550,700 PIXEL	    oPrinter := TAvPrinter():New("Exemplo TAvPrinter")    oPrinter:SetFile( '\SPOOL\matr010.prt', .F.)    oTPageView := TPageView():New( 0,0,510,354,oPrinter,oDlg,550,550 )    oTPageView:Show()    oTPageView:nZoom := 150                  ACTIVATE DIALOG oDlg CENTERED Return
