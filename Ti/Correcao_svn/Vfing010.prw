#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VFING010  ºAutor  ³Jeferson            º Data ³  09/12/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Geracao automatica de codigos de fornecedor ,analisando se º±±
±±º          ³ existe o CNPJ dando sequencia do codigo.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlteracoes³ 03/02/03 - Inclusao dos campos (Nome, Razaao Social, Natureº±±
±±º          ³ za e Conta Contabil) para quando esta cadastrando um forne º±±
±±º          ³ cedor com lojas iguais.                                    º±±  
±±º          ³ 28/05/07 - Alterado numeração do SA2 para não itulizar o   º±±  
±±º          ³  License. Customizada a geração da numeracao.              º±±  
±±º          ³                                                            º±±  
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function VFING010()

Local cCodCgc   := Substr(M->A2_CGC,1,8)
Local cNumCgc   := M->A2_CGC
Local cAlias    := GetArea()
Local cCodFor
Local cCodLoja
Local nCont     := Space(20)

Private cClasFor  := M->A2_CLASFOR


// alterado por Luciano Correa em 29/01/04...
// fornecedor ja cadastrado nao pode ter a loja alterada...
If !Inclui
	
	Return ( .T. )
	//Return(cNumCgc)
EndIf

// Verifica ha existencia do Codigo por CNPJ

IF cClasFor <> 'E'
	
	If Empty( cNumCgc )
		Return ( .F. )
		//Return( cNumCgc )
	EndIf
	
	If Len(Alltrim(cNumCgc)) == 14
		
		DbSelectArea("SA2")
		DbSetOrder(3)
		DbSeek(xFilial("SA2")+cCodCgc)
		IF FOUND()
			cCodFor := SA2->A2_COD
			cCodloja:= "99"
			
			M->A2_NREDUZ  := SA2->A2_NREDUZ
			M->A2_NOME    := SA2->A2_NOME
			M->A2_NATUREZ := SA2->A2_NATUREZ
			M->A2_CONTA   := SA2->A2_CONTA
			
			IF Val(Substr(cNumCgc,9,4)) > 99
				For nCont:= 99 to Val(Substr(cNumCgc,9,4))
					cCodLoja := Soma1(cCodloja)
				Next nCont
			Else
				cCodLoja := Substr(cNumCgc,11,2)
			Endif
			
			// Verifica se realmente nao existe o codigo
			DbSetOrder(1)
			DbGoTop()
			Do While .not. eof()
				DBSEEK(xFilial("SA2")+cCodFor+cCodLoja,.t.)
				IF Found()
					cCodLoja := Soma1(cCodLoja)
				Else
					Exit
				Endif
			Enddo
		Else
			
			DbSetOrder(1)
			//cCodFor  := GetSxEnum("SA2")
			cCodFor    	:= CodSA2()			  
			cCodLoja 	:= "00"
			
			For nCont:= 1 to Val(Substr(cNumCgc,9,4))
				cCodLoja := Soma1(cCodloja)
			Next nCont
			
		Endif
	ELSE
		// Verifica ha existencia do Codigo por CPF
		// Nao analisa a existencia do mesmo codigo por validacao no campo.
		
		DbSetOrder(1)
		//cCodFor    := GetSxEnum("SA2")  
		cCodFor    	:= CodSA2()	
		cCodLoja   := "00"
		
	ENDIF
	
Else
//	cCodFor    := GetSxEnum("SA2")  
	cCodFor    	:= CodSA2()	
	cCodLoja   := "00"
Endif

If !Empty( cNumCgc ) .or. cClasFor == 'E'
	M->A2_LOJA    := cCodLoja
	M->A2_COD     := M->A2_CLASFOR+Substr(cCodFor,2,5)
	lRefresh      := .t.
	RestArea(cAlias)
EndIf


Return ( .T. )
//Return( cNumCGC )        

Static Function CodSA2()
Local cbuscacod 
Local secSTR

cQuery := "SELECT MAX(A2_COD) CODIGO FROM " + RetSqlName("SA2") 
cQuery += " WHERE  A2_FILIAL = '" + xFilial('SA2') + "' AND  D_E_L_E_T_ <> '*' "
cQuery += " 		AND A2_CLASFOR = '" + cClasFor +"' AND A2_COD LIKE('" + cClasFor + "%')"

//MEMOWRIT("C:\SQLSIGA\VFING010.TXT", cQuery)
  
TCQUERY cQuery NEW ALIAS '_COD'


secSTR	:= STRZERO(VAL(SUBSTR(_COD->CODIGO,2)) + 1,(TamSX3("A2_COD")[1])-1)

cbuscacod := cClasFor + secSTR

_COD->(DbCloseArea())

Return cbuscacod 