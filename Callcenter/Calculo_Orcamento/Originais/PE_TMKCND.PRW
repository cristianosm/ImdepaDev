/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³U_TMKCND    ³ Autor ³Global Informatica   ³ Data ³ 07/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza o codigo da transportadora na tela de atendimento  ³±±
±±³          ³do Call Center. Este ponto de entrada eh chamado sempre     ³±±
±±³          ³ que é aberto a tela da condição de pagamento. Usado para   ³±±
±±³          ³ buscar os dados da Transportadora e da Cond.Pag do SUA,    ³±±
±±³          ³ pois esse problema será corrigido somente no MP9.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±³            ³        ³                                                 ³±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Uso      ³ESPECIFICO PARA O CLIENTE IMDEPA						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

/*/
User Function TMKCND(	cNumTlv,;
						cCliente,;
						cLoja,;
						cCodCont,;
						cCodOper,;
						aParcelas,;
						cCodPagto,;
						oCodPagto,;
						cDescPagto,;
						oDescPagto,;
						lVisual,;
						cCodTransp,cTransp)


IF Empty(M->UA_TRANSP)
	IF Empty(cCodTransp)
		cCodTransp := Posicione("SA1",1,xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA,"A1_TRANSP")
	ENDIF
ELSE
   	cCodTransp := M->UA_TRANSP
ENDIF
cCodPagto 	 := M->UA_CONDPG

oCodPagto:Refresh()
oDescPagto:Refresh()

	_ljaCPaCP := .T.

Return()



/*Static Function Tk270AtuTransp(cCodTransp,cTransp,oTransp)
Local lRet := .F.

cTransp := ""
DbSelectarea("SA4")
DbSetorder(1)
If DbSeek(xFilial("SA4")+cCodTransp)
   cTransp := SA4->A4_NOME
   oTransp:Refresh()
   lRet := .T.
Endif

Return(lRet)
*/
