#include "rwmake.ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³U_CTARETIRºAutor  ³Expedito Mendonca Jrº Data ³29/07/2004   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a conta contabil de retencao de imposto de renda    º±±
±±º          ³de apropriacao e de baixa                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ESPECIFICO PARA O CLIENTE IMDEPA                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function CtaRetIr(_cAlias)
Local cConta, cCodRet, cArea, aAreaSED, aAreaSE2
If _cAlias == "SE2"		// Inclusao manual de titulo a pagar

	// Salva ambiente
	cArea := alias()
	aAreaSED := SED->(Getarea())	
	
	// Busca o codigo da retencao no cadastro de natureza
	cCodRet := Posicione("SED",1,xFilial("SED")+SE2->E2_NATUREZ,"ED_CODREIR")
	// Define conta contabil da retencao
	cConta := PadR(Tabela("I9",cCodRet,.F.),20)
	
	// Restaura ambiente
	Restarea(aAreaSED)
	dbSelectarea(cArea)
	
Elseif _cAlias == "SD1"	// Inclusao de nota fiscal de entrada

	// Salva ambiente
	cArea := alias()
	aAreaSE2 := SE2->(Getarea())	
	aAreaSED := SED->(Getarea())	
	
	// Posiciona no titulo a pagar principal 
	dbSelectArea("SE2")
	dbSetOrder(6)
//	MsSeek(xFilial("SE2")+SD1->D1_FORNECE+SD1->D1_LOJA+&(GetMv("MV_2DUPREF"))+SD1->D1_DOC,.F.)
	MsSeek(xFilial("SE2")+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_SERIE+SD1->D1_DOC,.F.)
//	Do While SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM == xFilial("SE2")+SD1->D1_FORNECE+SD1->D1_LOJA+&(GetMv("MV_2DUPREF"))+SD1->D1_DOC .and. !Eof()
	Do While SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM == xFilial("SE2")+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_SERIE+SD1->D1_DOC .and. !Eof()
		If SE2->E2_TIPO == "NF "
			Exit
		Endif
		dbSkip()
	Enddo
	
	// Busca o codigo da retencao no cadastro de natureza
	cCodRet := Posicione("SED",1,xFilial("SED")+SE2->E2_NATUREZ,"ED_CODREIR")
	// Define conta contabil da retencao
	cConta := PadR(Tabela("I9",cCodRet,.F.),20)
	
	// Restaura ambiente
	Restarea(aAreaSED)
	Restarea(aAreaSE2)	
	dbSelectarea(cArea)	
	
Elseif _cAlias == "SE5"	// Baixa de titulo a pagar

	// Define conta contabil da retencao
	cConta := PadR(Tabela("I9",SE2->E2_CODRET,.F.),20)
	
Endif  

Return cConta
