#include "topconn.ch"
#include "ap5mail.ch"
#include "rwmake.ch"

#DEFINE X_DESCNEG		30  // Dias para vencimento dos acrescimos/descontos negociados
#DEFINE ACRESCIMO		3	// Valor do acrescimo financeiro da condicao de pagamento

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TLVENT    �Autor  �Edivaldo Gon�alves  � Data �  09/13/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de Entrada ap�s sele��o do Hist�rico das ligacoes     ���
���          �atendidas pelo Televendas                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Call Center                                                ���
�������������������������������������������������������������������������͹��
���Alteracao � M�rcio Q. Borges �Rodar Valid de campo VRUNIT somente      ���
��� 27/10/07 �                  �quando alterar o preco de tabela e PV    ���
���          �                  �estiver aberto.                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

**********************************************************************
User Function TLVENT()
**********************************************************************
Local cDisplay:=''

If M->UA_OPER='1'
	cDisplay='Pedido'
Else
	If M->UA_OPER='2'
		cDisplay='Or�amento'
	Endif
Endif

//Inserido por Edivaldo Gon�alves Cordeiro em 01/09/2009 - Atualiza vari�veis de Mem�ria no cabe�alho no Or�amento
M->UA_VENDINT 	:= SUA->(U_PesqVend(M->UA_CLIENTE,M->UA_LOJA))
M->UA_DESATIV	:= SUA->(U_PesqAtiv(M->UA_CLIENTE,M->UA_LOJA))
//M->UA_OPERADO   := SUA->(TKOPERADOR())
M->UA_DESCOPE   := SUA->(Posicione("SU7",1,xFilial("SU7") + M->UA_OPERADO, "U7_NOME"))

//Caso Emitiu NF, nao roda atualizacoes do Historico
If  !EMPTY(SUA->UA_EMISNF)
	Return .T.
EndIf

MsAguarde({||SF4->(LoadOrc()) },'Hist�rico','Estruturando '+cDisplay+' ...')

Return(.T.)
**********************************************************************
Static Function LoadOrc
**********************************************************************
Local nAnt, nPrcTabAtu
Local lDesNegVencido,lOrcVencido := .F.
Local cOperAtivo:=""
Local aArea := Getarea()
Local lAtuPrcTab2 := .F.
Local nDesAcreFil :=0

// Campos virtuais Customizados pela IMDEPA
M->UA_OBSCLI  := IIF(SUA->UA_PROSPEC,"",SA1->(POSICIONE("SA1",1,XFILIAL("SA1")+SUA->UA_CLIENTE+SUA->UA_LOJA,"A1_OBSVEND")))
//M->UA_VENDINT := U_PesqVend(M->UA_CLIENTE,M->UA_LOJA) //Inserido por Edivaldo G. Cordeiro em 20/07/06

aHeader  := {}
aCols    := {}
aHeader  := aClone(aSvFolder[2][1])
aCols    := aClone(aSvFolder[2][2])
n		 := aSvFolder[2][3]

//������������������������������������������������������Ŀ
//� Atualiza dados especificos do aCols  			     �
//��������������������������������������������������������
nAcreCond 	:= 1+(Posicione("SE4",1,xFilial("SE4")+M->UA_CONDPG,"E4_ACRSFIN")/100)
nP_VRUNIT   := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VRUNIT"} )
nP_PRTB   	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_PRCTAB"} )
nP_PRTB2  	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_PRCTAB2"} )
nP_VLIT   	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VLRITEM"} ) // VALOR TOTAL
nP_BICM   	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_BASEICM"} )
nP_DESCICM	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_DESCICM"} )
nP_DESC2  	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_DESC2"} )
nP_VALDESC	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VALDESC"} )
nP_DESC   	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_DESC"} )
nP_ACRE   	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_ACRE"} )
nP_ACRE2  	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_ACRE2"} )
nP_VALACRE	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VALACRE"} )
nP_DESCICM	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_DESCICM"} )
nP_VDESICM	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VDESICM"} )

nP_VRCACRE 	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VRCACRE"} )  //Prc.c/ Acres
nP_ACREIPI 	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_ACREIPI"} )  //Preco c/ IPI
nP_ALIQIPI 	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_ALIQIPI"} )	// % IPI
nP_VALIPI  	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VALIPI"} )   // VALOR DO IPI

nP_DATA   	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_DTNECLI"} )
nP_HORA   	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_HRNECLI"} )
nP_Prod   	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_PRODUTO"} )
nP_QTDA   	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_QUANT"} )

//VERIFICA SE O ORCAMENTO COPIADO ESTA VENCIDO (vencimento dos pre�os acertados).
lOrcVencido 	:= (DDATABASE >  M->UA_DTLIM )   // 3 dias ap�s a database
lDesNegVencido	:= DDATABASE > (SUA->UA_EMISSAO + X_DESCNEG)  //ENTRE(SUA->UA_EMISSAO,(SUA->UA_EMISSAO + X_DESCNEG), DDATABASE)  // Descontos Negociados vencem em 30 dias

// Array com a amarracao produtoxcampanha para posterior gravacao da tabela ZZI
__aProdCamp := {}
__aItDigPrd := {}

nAnt := n

//|Analista: Cristiano Machado   Data: 18/09/2010   Obs: Correcao Mensagem "SEMDADOS"
If MaFisFound()
	MaFisClear()
Endif

//|Fim Cristiano
FOR I:= 1 TO LEN(ACOLS)
	n := I

//|Analista: Cristiano Machado   Data: 18/09/2010   Obs: Correcao Mensagem "SEMDADOS"
	If MaFisFound()

			MaFisAlt("IT_QUANT"		,aCols[n][nP_QTDA]		,n)
			MaFisAlt("IT_PRCUNI"	,aCols[n][nP_VRUNIT]	,n)
			MaFisAlt("IT_VALMERC"	,aCols[n][nP_VLIT] 		,n)

			MaColsToFis(aHeader,aCols,n,"TK271",.T.,NIL,NIL,NIL)

			//#DEFINE SUFRAMA			7	// Valor total da Suframa
			If aValores[7] > 0
				Tk273Recalc(n)
			Endif

	Endif
//|Fim Cristiano

	***********************************************************************************************************
	//Projeto F11 - Usado para armazenar o estado anterior dos produtos para saber quando houver uma altera��o//
	***********************************************************************************************************


	AADD(__aItDigPrd,{I,gdFieldGet("UB_PRODUTO",I),gdFieldGet("UB_LOCAL",I)}) //Carrega o Vetor __aItDigPrd{} com os produtos do Acols
	AADD(__aItDigQtd,I)


	SB1->(dbSeek(xFilial('SB1')+gdFieldGet("UB_PRODUTO",I)))
	ACOLS[I,nP_ACREIPI]:= gdFieldGet("UB_VRCACRE",I)*(1+(MaFisRet(I,"IT_ALIQIPI")/100)) //Preco c/ IPI
	ACOLS[I,nP_ALIQIPI]:= MaFisRet(I,"IT_ALIQIPI")  //  % IPI
	ACOLS[I,nP_VALIPI] := SB1->B1_IPI   // VALOR DO IPI

	ACOLS[I,nP_DATA]   := DDATABASE  //Data da Necessidade do Cliente
	ACOLS[I,nP_HORA]   := STRZERO(VAL(SUBSTR(TIME(),1,2))+1,2)+SUBSTR(TIME(),4,2)//Hora da Necessidade do Cliente

	    // Verifica se o produto possui Desconto/Acr�scimo especial
    nDesAcreFil :=SB1->(U_IMDG240E(.F.,gdFieldGet("UB_PRODUTO",I)))


	nPrcTabAtu := DA1->(MaTabPrVen(M->UA_TABELA,ACOLS[I,nP_Prod],ACOLS[I,nP_QTDA],M->UA_CLIENTE,M->UA_LOJA,M->UA_MOEDA))
	//�������������������������������������������������������������������Ŀ
	//�Atualiza preco do item se foi modificado o preco da Tabela de Preco�
	//���������������������������������������������������������������������

	//Aplica o Desconto/Acr�scimo Especial
	If nDesAcreFil <>0
	 nPrcTabAtu :=A410Arred(nPrcTabAtu +((nPrcTabAtu*nDesAcreFil)/100))
	Endif



	IF nPrcTabAtu != ACOLS[I,nP_PRTB2]
		lAtuPrcTab2 := .T.
	ELSE
		lAtuPrcTab2 := .F.
	ENDIF

	IF lAtuPrcTab2
		ACOLS[I,nP_PRTB2] := nPrcTabAtu
	Endif

	IF lOrcVencido		// Tratamento para orcamento vencido
		//Aviso('Or�amento Vencido','O Sistema Ajustou vari�veis para Or�amento Vencido  !:'+CHR(10)+CHR(13)+CHR(10)+CHR(13)+'Vencido em : '+Dtoc(M->UA_DTLIM),{'Ok'})

		IF lDesNegVencido

			ACOLS[I,nP_DESC]    := 0
			ACOLS[I,nP_DESC2]   := 0
			ACOLS[I,nP_VALDESC] := 0
			ACOLS[I,nP_ACRE]    := 0
			ACOLS[I,nP_ACRE2]   := 0
			ACOLS[I,nP_VALACRE] := 0
			ACOLS[I,nP_DESCICM] := 0
			ACOLS[I,nP_VDESICM] := 0
			M->UA_DESCICM 		 := 0	// zera o desconto de icm se o orcamento estiver vencido

		ENDIF

		IF lAtuPrcTab2
			ACOLS[I,nP_PRTB]    := nPrcTabAtu
			ACOLS[I,nP_VLIT]    := (nPrcTabAtu * ACOLS[I,nP_QTDA])  // TOTAL  (QTD X VALOR)
			ACOLS[I,nP_BICM]    := ACOLS[I,nP_VLIT]

			//�������������������������������Ŀ
			//�Atualiza descontos e acrescimos�
			//���������������������������������

			// Preenche Valor do Pre�o Unit�rio
			__ReadVar := 'M->UB_VRUNIT'
			M->UB_VRUNIT := SF4->(AtuVrUnit())
			GDFieldPut('UB_VRUNIT',M->UB_VRUNIT, N)

			// Validacao do Preco unitario sem a apresentacao da tela para digitacao do valor.
			SF4->(U_AtuDesAcr())


			// MARCIO -> MUDANCA VALIDACAO BUILD 27/10/07
			// Roda Gatilhos do Campo
			SX3->(Posicione("SX3",2,'UB_VRUNIT','X3_CAMPO'))
			CheckSX3('UB_VRUNIT',M->UB_VRUNIT)
			RunTrigger(2,n,PADR('UB_VRUNIT',10))

			//��������������������������������������������������������������Ŀ
			//�Atualiza campo UB_VRCCAMP (Preco minimo de campanha de vendas)�
			//����������������������������������������������������������������

			SF4->(U_MsgCamp(ACOLS[I,nP_Prod],.T.,.F.,.F.,.T.,nAcreCond))

		ENDIF

	ENDIF

NEXT

n := nAnt

// Indica que neste atendimento, ao se passar pelo campo UA_TABELA, a validacao nao atualizar os precos dos itens do atendimento
__cTabAtu	:= M->UA_TABELA

Restarea(aArea)
Return
**********************************************************************
Static Function AtuVrUnit()
**********************************************************************
Local nVrUnit   := GdFieldGet("UB_VRUNIT" ,n)
Local nPrcTab2  := GdFieldGet("UB_PRCTAB2",n)
Local nPrcAcre  := GdFieldGet("UB_VRCACRE",n)
Local nPDesc    := GdFieldGet("UB_DESC2"  ,n)
Local nPAcre    := GdFieldGet("UB_ACRE2"  ,n)
Local nPDesICM  := GdFieldGet("UB_DESCICM",n)
Local nAcreCond := 1 + (SE4->( Posicione("SE4",1,xFilial("SE4")+M->UA_CONDPG,"E4_ACRSFIN")) / 100 )  // Acrescimo Financeiro


IF  nPAcre > 0
	// Preco unitario (sem acrescimo financeiro) com acrescimo comercial
	nPrccAcrDescCom := A410Arred(nPrcTab2 * (1 + (nPAcre/ 100)),"UB_VRUNIT")

	// Preco unitario (sem acrescimo financeiro) com acrescimo comercial e com desconto de ICMS
	nPrccDesIcm := A410Arred(nPrccAcrDescCom * (1 - (nPDesICM / 100)),"UB_VRUNIT")

ELSEIF nPDesc > 0
	// Preco unitario (sem acrescimo financeiro) com desconto comercial
	nPrccAcrDescCom := A410Arred(nPrcTab2 * (1 - (nPDesc / 100)),"UB_VRUNIT")

	// Preco unitario (sem acrescimo financeiro) com desconto comercial e com desconto de ICMS
	nPrccDesIcm := A410Arred(nPrccAcrDescCom * (1 - (nPDesICM / 100)),"UB_VRUNIT")
ELSE
	// Se nao existe acresimo nem desonto comercial, ser� igual ao preco de tabela
	// Preco unitario (sem acrescimo financeiro) com desconto comercial

	nPrccAcrDescCom := nPrcTab2

	// Preco unitario (sem acrescimo financeiro) com desconto comercial e com desconto de ICMS
	nPrccDesIcm := A410Arred(nPrccAcrDescCom * (1 - (nPDesICM / 100)),"UB_VRUNIT")
ENDIF

// Preco unitario com desconto comercial, desconto de ICMS e acrescimo financeiro
nPrcAcres := A410Arred(nPrccDesIcm * nAcreCond , "UB_VRUNIT" )

// Atribui o valor do desconto ou acrescimo a variavel de memoria
M->UB_VRUNIT := A410Arred(nPrcAcres / nAcreCond,"UB_VRUNIT")

// Ajusta arredondamento
nSimPrcAcres := A410Arred( M->UB_VRUNIT * nAcreCond ,"UB_VRUNIT" )
nIncremento := IIF(nSimPrcAcres < nPrcAcres , 0.0001, -0.0001)
lSitInic := (nSimPrcAcres < nPrcAcres)
While ( nSimPrcAcres := A410Arred( M->UB_VRUNIT * nAcreCond ,"UB_VRUNIT") ) != nPrcAcres
	If lSitInic != (nSimPrcAcres < nPrcAcres)
		Exit
	Endif
	M->UB_VRUNIT += nIncremento
End

nVrUnit := M->UB_VRUNIT

Return nVrUnit