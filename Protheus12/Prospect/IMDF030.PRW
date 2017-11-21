#Include "Totvs.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบOriginal  ณVFING002  บAutor  ณMicrosiga           บ Data ณ  09/12/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบFuncao    ณGERCODPROSบAutor  ณExpedito Mendonca Jrบ Data ณ  10/03/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Geracao automatica de codigos de prospect, analisando se jaบฑฑ
ฑฑบ          ณ existe o CNPJ dando sequencia do codigo.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Exclusivo para o cliente IMDEPA                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function GerCodPros()


Local cCodCgc   := Substr(M->US_CGC,1,8)
Local cNumCgc   := M->US_CGC
Local cTipo 	:= M->US_TIPO
Local cAlias    := GetArea()


Local cNreduz  := M->US_NREDUZ
Local cNome    := M->US_NOME
Local nCont

Public P_CodPros := M->US_COD
Public P_LojPros := M->US_LOJA
// alterado por Expedito Mendonca Junior em 30/01/04...
// prospect ja cadastrado nao pode ter a loja alterada...
//If !Inclui .or. funname() == "TMKA271"
	
//If U_UltFuncoes("AXINCLUI","AXALTERA",30) != 1
If !Inclui .or. funname() == "TMKA271"
	//Return(cNumCgc)
	Return .T.
EndIf

// Verifica ha existencia do Codigo por CNPJ
IF cTipo <> "X"
	
	If len(Alltrim(cNumCgc)) == 14
		
		DbSelectArea("SUS")
		DbSetOrder(4)
		IF DbSeek(xFilial("SUS")+cCodCgc)
			P_CodPros := SUS->US_COD
			P_LojPros:= "99"
			cNreduz := SUS->US_NREDUZ
			cNome   := SUS->US_NOME
			IF Val(Substr(cNumCgc,9,4)) > 99
				For nCont:= 99 to Val(Substr(cNumCgc,9,4))
					P_LojPros := Soma1(P_LojPros)
				Next nCont
			Else
				P_LojPros := Substr(cNumCgc,11,2)
			Endif
			
			// Verifica se realmente nao existe o codigo
			DbSetOrder(1)
			DbGoTop()
			Do While .not. eof()
				DBSEEK(xFilial("SUS")+P_CodPros+P_LojPros,.t.)
				IF Found()
					P_LojPros := Soma1(P_LojPros)
				Else
					Exit
				Endif
			Enddo
		Else
			
			DbSetOrder(1)
//			P_CodPros  := GetSxEnum("SUS")
			P_CodPros  := M->US_COD
			P_LojPros := "00"
			
			For nCont:= 1 to Val(Substr(cNumCgc,9,4))
				P_LojPros := Soma1(P_LojPros)
			Next nCont
			
		Endif
	ELSE


		// Verifica ha existencia do Codigo por CPF
		// Nao analisa a existencia do mesmo codigo por validacao no campo.
		DbSetOrder(1)
//		P_CodPros    := GetSxEnum("SUS")
		P_CodPros    := M->US_COD
		P_LojPros   := "01"
		
	ENDIF
	
ENDIF

M->US_LOJA    := P_LojPros
M->US_COD     := P_CodPros
M->US_NREDUZ  := cNreduz
M->US_NOME    := cNome	

//lRefresh       := .t.
RestArea(cAlias)

//Return(cNumCgc)
Return .T.

           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณU_ULTFUNCOบAutor  ณExpedito Mendonca Jrบ Data ณ  20/02/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica utomatica de codigos de prospect, analisando se jaบฑฑ
ฑฑบ          ณ existe o CNPJ dando sequencia do codigo.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Exclusivo para o cliente IMDEPA                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function UltFuncoes(cFuncao1,cFuncao2,nQtd)


Local nI,nRet := 0
for nI := 1 to nQtd

	If procname(nI) == cFuncao1
		nRet := 1
		Exit
	Elseif procname(nI) == cFuncao2
		nRet := 2
		Exit
	Endif
next     


Return nRet