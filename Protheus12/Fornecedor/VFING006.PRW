#include 'Totvs.ch'
#Include 'Protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VFING006  ºAutor  ³Jeferson            º Data ³  13/12/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de Pesquisa de Codigo Enderecamento Postal - CEP      º±±
±±º          ³ Usado em conjunto com a rotina VFING001().                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


// Utilizado atraves de Gatilho nos arquivos :
// 												"Cadastro de Clientes"
// 												"Cadastro de Fornecedores"
// 												"Cadastro de Vendedores"
// 												"Cadastro de Transportadora"
// 												"Cadastro de Bancos"


User Function VFING006(cAliasCpo)

Local cCepRetorno
Local nCount:=0,lAchou:=.f.
Private oDlg01,cTitle:=OemToAnsi("Codigo de Enderecamento Postal"),cAlias:=GetArea()
Private cAliasCampo:= cAliasCpo
Private oListCEP,aListCEP:={{Space(08),Space(06),Space(40),,Space(30),Space(20),Space(02),Space(20)}}
Private cEnd:=Space(40),cMun:=Space(20),cEst:=Space(02)
Private __cVar := ReadVar()    // Marllon - 29/08/2005 (motivo: MP8)

If Type("aGets") == "U"
	Private aGets := {}
EndIf

DEFINE MSDIALOG oDlg01 TITLE cTitle FROM 082,061 TO 445,748 PIXEL OF oMainWnd
@ 011,013 Say OemToAnsi("Endereco") 		Size 033,008 of oDlg01 PIXEL
@ 025,013 Say OemToAnsi("Municipio")		Size 038,008 of oDlg01 PIXEL
@ 038,013 Say OemToAnsi("Estado") 			Size 025,008 of oDlg01 PIXEL
@ 011,063 MsGet cEnd Picture '@!'			Size 116,010 of oDlg01 PIXEL
@ 024,063 MsGet cMun Picture '@!'			Size 076,010 of oDlg01 PIXEL
@ 039,063 MsGet cEst Picture '@!' F3 '12'	Size 011,010 of oDlg01 PIXEL
@ 031,294 Button OemToAnsi("Localizar") 	Size 036,016 of oDlg01 PIXEL Action LocalizaCEP()
@ 161,013 Button "Inclui/Altera/Exclui"	Size 060,011 of oDlg01 PIXEL Action (cCepRetorno:=MancadCep(),oDlg01:End())			//oDlg01:End()
@ 161,246 Button "Seleciona"           	Size 034,011 of oDlg01 PIXEL Action (cCepRetorno:=SelecionaCEP(),oDlg01:End())			//oDlg01:End()
@ 160,293 Button "Cancela"             	Size 034,011 of oDlg01 PIXEL Action (cCepRetorno:=Space(08),oDlg01:End())

@ 055,004  LISTBOX oListCEP ;
FIELDS HEADER 	"CEP"      	        ,;
"Logradouro"        ,;
"Endereco"	        ,;
"Faixa Numerica"	,;
"Cidade"	        ,;
"Estado"	        ,;
"Bairro"             ;
SIZE 330,100 PIXEL				//         ON DBLCLICK oPanSM:Hide()


oListCEP:SetArray(aListCEP)
oListCEP:bLine:={|| {aListCEP	[oListCEP:nAt,1],;
aListCEP[oListCEP:nAt,2],;
aListCEP[oListCEP:nAt,3],;
aListCEP[oListCEP:nAt,4],;
aListCEP[oListCEP:nAt,5],;
aListCEP[oListCEP:nAt,6],;
aListCEP[oListCEP:nAt,7]}}

ACTIVATE MSDIALOG oDlg01 CENTERED

For nCount:=1 to Len(aGets)
	If 'A1_CGC    ' $ aGets[nCount]
		cRet:=M->A1_TIPO
		cConteudo := IIf(cRet == "X","F","T")
		aGets[nCount] := Stuff(aGets[nCount],22,1,cConteudo)
		Exit
	Endif
Next nCount

RestArea(cAlias)

Return


Static Function LocalizaCEP()
Local cQuery:=""

cEnd:=Alltrim(cEnd)
cMun:=Alltrim(cMun)
cEst:=Alltrim(cEst)

If empty(cEnd+cMun+cEst)
	MsgInfo("Favor digite um dos campos para pesquisa.")
	cEnd:=Space(40)
	cMun:=Space(20)
	cEst:=Space(02)
	Return
Endif

cQuery += "SELECT * FROM"
cQuery += RetSQLName("ZZ1")
cQuery += " WHERE "
cQuery += "ZZ1_FILIAL = '"   +xFilial("ZZ1")+ "' AND "
If .not. empty(cEnd)
	cQuery += "ZZ1_END LIKE '" +cEnd+ "%' AND "
Endif
If .not. empty(cMun)
	cQuery += "ZZ1_MUNIC LIKE '" +cMun+ "%' AND "
Endif
If .not. empty(cEst)
	cQuery += "ZZ1_EST =   '" +cEst+ "' AND "
Endif

cQuery += " D_E_L_E_T_ = '' "
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TZZ1",.F.,.T.)
DbGoTop()

aListCEP:={}
cEnd:=Space(40)
cMun:=Space(20)
cEst:=Space(02)
While .not. eof()
	AADD(aListCEP,{TZZ1->ZZ1_CEP,TZZ1->ZZ1_TLOG,TZZ1->ZZ1_END,TZZ1->ZZ1_FAINUM,TZZ1->ZZ1_MUNIC,TZZ1->ZZ1_EST,TZZ1->ZZ1_BAIRRO})
	TZZ1->(dBsKIP())
Enddo
oListCEP:SetArray(aListCEP)
oListCEP:bLine:={|| {aListCEP[oListCEP:nAt,1],;
aListCEP[oListCEP:nAt,2],;
aListCEP[oListCEP:nAt,3],;
aListCEP[oListCEP:nAt,4],;
aListCEP[oListCEP:nAt,5],;
aListCEP[oListCEP:nAt,6],;
aListCEP[oListCEP:nAt,7]}}
oListCEP:Refresh() // Final da AADD

DbSelectArea("TZZ1")
DbCloseArea()
Return

Static Function SelecionaCEP()
Local nPos         := oListCEP:nAt
Local cCepRetormo  := aListCEP[nPos,1]
Local lOkCep       := .F.
Local lOkCliente   := .F.
Local lOkProspect  := .F.

//oDlg01:End()

// "Cadastro de Clientes"
If cAliasCampo == 'SA1'
	lOkCliente := .T.
	cCepRet   :=  M->A1_CEP
	cEndereco := "M->A1_END"
	cCEP      := "M->A1_CEP"
	cMun      := "M->A1_MUN"
	cBairro   := "M->A1_BAIRRO"
	cEst      := "M->A1_EST"
	cTlogend  := "M->A1_TLOGEND"
Endif

// "Cadastro de Prospect"
If cAliasCampo == 'SUS'
	lOkProspect := .T.
	cCepRet   :=  M->US_CEP
	cEndereco := "M->US_END"
	cCEP      := "M->US_CEP"
	cMun      := "M->US_MUN"
	cBairro   := "M->US_BAIRRO"
	cEst      := "M->US_EST"
	cTlogend  := "M->US_TLOGEND"
Endif

// "Cadastro de Fornecedores"
//If cAliasCampo == 'SA2' .And. ReadVar() == "M->A2_CEP"
If cAliasCampo == 'SA2' .And. __cVar == "M->A2_CEP"
	cCepRet   :=  M->A2_CEP
	cEndereco := "M->A2_END"
	cCEP      := "M->A2_CEP"
	cMun      := "M->A2_MUN"
	cBairro   := "M->A2_BAIRRO"
	cEst      := "M->A2_EST"
	cTlogend  := "M->A2_TLOGEND"
Endif

// "Cadastro de Fornecedores"
//If cAliasCampo == 'SA2' .And. ReadVar() == "M->A2_REPRCEP"
If cAliasCampo == 'SA2' .And. __cVar == "M->A2_REPRCEP"
	cCepRet   :=  M->A2_REPRCEP
	cEndereco := "M->A2_REPR_EN"
	cCEP      := "M->A2_REPRCEP"
	cMun      := "M->A2_REPMUN"
	cBairro   := "M->A2_REPBAIR"
	cEst      := "M->A2_REPEST"
	cTlogend  := "M->A2_REPTLOG"
Endif


// "Cadastro de Vendedores"
If cAliasCampo == 'SA3'
	cCepRet   :=  M->A3_CEP
	cEndereco := "M->A3_END"
	cCEP      := "M->A3_CEP"
	cMun      := "M->A3_MUN"
	cBairro   := "M->A3_BAIRRO"
	cEst      := "M->A3_EST"
	cTlogend  := "M->A3_TLOGEND"
Endif

// "Cadastro de Transportadora"
If cAliasCampo == 'SA4'
	cCepRet   :=  M->A4_CEP
	cEndereco := "M->A4_END"
	cCEP      := "M->A4_CEP"
	cMun      := "M->A4_MUN"
	cBairro   := "M->A4_BAIRRO"
	cEst      := "M->A4_EST"
	cTlogend  := "M->A4_TLOGEND"
Endif

// "Cadastro de Bancos"
If cAliasCampo == 'SA6'
	cCepRet   :=  M->A6_CEP
	cEndereco := "M->A6_END"
	cCEP      := "M->A6_CEP"
	cMun      := "M->A6_MUN"
	cBairro   := "M->A6_BAIRRO"
	cEst      := "M->A6_EST"
	cTlogend  := "M->A6_TLOGEND"
Endif

// "Cadastro de Suspecte"
If cAliasCampo == 'ACH'
	cCepRet   :=  M->ACH_CEP
	cEndereco := "M->ACH_END"
	cCEP      := "M->ACH_CEP"
	cMun      := "M->ACH_CIDADE"
	cBairro   := "M->ACH_BAIRRO"
	cEst      := "M->ACH_EST"
	cTlogend  := "M->ACH_TLOGEN"
Endif

// "Cadastro de Concorrentes"
If cAliasCampo == 'AC3'
	cCepRet   :=  M->AC3_CEP
	cEndereco := "M->AC3_END"
	cCEP      := "M->AC3_CEP"
	cMun      := "M->AC3_MUN"
	cBairro   := "M->AC3_BAIRRO"
	cEst      := "M->AC3_EST"
	cTlogend  := "M->AC3_TLOGEN"
Endif

// "Cadastro de Parceiros"
If cAliasCampo == 'AC4'
	cCepRet   :=  M->AC4_CEP
	cEndereco := "M->AC4_END"
	cCEP      := "M->AC4_CEP"
	cMun      := "M->AC4_MUN"
	cBairro   := "M->AC4_BAIRRO"
	cEst      := "M->AC4_EST"
	cTlogend  := "M->AC4_TLOGEN"
Endif

// "Cadastro de Contatos"
If cAliasCampo == 'SU5'
	cCepRet   :=  M->U5_CEP
	cEndereco := "M->U5_END"
	cCEP      := "M->U5_CEP"
	cMun      := "M->U5_MUN"
	cBairro   := "M->U5_BAIRRO"
	cEst      := "M->U5_EST"
	cTlogend  := "M->U5_TLOGEND"
Endif


// "Cadastro de Operadores"
If cAliasCampo == 'SU7'
	cCepRet   :=  M->U7_CEP
	cEndereco := "M->U7_END"
	cCEP      := "M->U7_CEP"
	cMun      := "M->U7_MUN"
	cBairro   := "M->U7_BAIRRO"
	cEst      := "M->U7_EST"
	cTlogend  := "M->U7_TLOGEND"
Endif

// "Cadastro de Prospects"
/*If cAliasCampo == 'SUS'
	cCepRet   :=  M->US_CEP
	cEndereco := "M->US_END"
	cCEP      := "M->US_CEP"
	cMun      := "M->US_MUN"
	cBairro   := "M->US_BAIRRO"
	cEst      := "M->US_EST"
	cTlogend  := "M->US_TLOGEND"
Endif*/

If len(aListCEP) > 0
	lOkCep:=.T.
Else
	&cEndereco  := SPACE( 30)
	&cCEP       := SPACE(8)
	&cMun       := SPACE(15)
	&cBairro    := SPACE(20)
	&cEst       := SPACE(2)
	&cTlogEnd   := SPACE(20)
Endif

If lOkCep						// CEP Encontrado.
	
	If lOkCliente            	// Cadastro de Clientes
		
		//If ReadVar() == "M->A1_CEP"
		If __cVar == "M->A1_CEP"
			// Atualiza os campos de faturamento e cobranca
			M->A1_ENDCOB := aListCEP[nPos,3]
			M->A1_CEPC   := aListCEP[nPos,1]
			M->A1_MUNC   := aListCEP[nPos,5]
			M->A1_ESTC   := aListCEP[nPos,6]
			M->A1_BAIRROC:= aListCEP[nPos,7]
			M->A1_TLOGCOB:= aListCEP[nPos,2]
			
			&cEndereco  := aListCEP[nPos,3]
			&cCEP       := aListCEP[nPos,1]
			&cMun       := aListCEP[nPos,5]
			&cEst       := aListCEP[nPos,6]
			&cBairro    := aListCEP[nPos,7]
			&cTlogend   := aListCEP[nPos,2]
		//Elseif ReadVar() == "M->A1_CEPC"
		Elseif __cVar == "M->A1_CEPC"
			// Atualiza os campos de cobranca
			M->A1_ENDCOB := aListCEP[nPos,3]
			M->A1_CEPC   := aListCEP[nPos,1]
			M->A1_MUNC   := aListCEP[nPos,5]
			M->A1_ESTC   := aListCEP[nPos,6]
			M->A1_BAIRROC:= aListCEP[nPos,7]
			M->A1_TLOGCOB:= aListCEP[nPos,2]
		//Elseif ReadVar() == "M->A1_CEPE"
		Elseif __cVar == "M->A1_CEPE"
			// Atualiza So os campos de entrega
			M->A1_ENDENT := aListCEP[nPos,3]
			M->A1_CEPE   := aListCEP[nPos,1]
			M->A1_MUNE   := aListCEP[nPos,5]
			M->A1_ESTE   := aListCEP[nPos,6]
			M->A1_BAIRROE:= aListCEP[nPos,7]
			M->A1_TLOGENT:= aListCEP[nPos,2]
		//Elseif ReadVar() == "M->A1_CEPREC"
		Elseif __cVar == "M->A1_CEPREC"
			// Atualiza So os campos de Recebimento
			M->A1_ENDREC := aListCEP[nPos,3]
			M->A1_CEPREC := aListCEP[nPos,1]
			M->A1_CIDREC := aListCEP[nPos,5]
			M->A1_UFREC  := aListCEP[nPos,6]
			M->A1_BAIRREC:= aListCEP[nPos,7]
			M->A1_TLOGREC:= aListCEP[nPos,2]
		Endif
	
	Elseif lOkProspect

		//If ReadVar() == "M->US_CEP"
		If __cVar == "M->US_CEP"
			// Atualiza os campos de faturamento e cobranca
			M->US_ENDCOB := aListCEP[nPos,3]
			M->US_CEPC   := aListCEP[nPos,1]
			M->US_MUNC   := aListCEP[nPos,5]
			M->US_ESTC   := aListCEP[nPos,6]
			M->US_BAIRROC:= aListCEP[nPos,7]
			M->US_TLOGCOB:= aListCEP[nPos,2]
			
			&cEndereco  := aListCEP[nPos,3]
			&cCEP       := aListCEP[nPos,1]
			&cMun       := aListCEP[nPos,5]
			&cEst       := aListCEP[nPos,6]
			&cBairro    := aListCEP[nPos,7]
			&cTlogend   := aListCEP[nPos,2]
		//Elseif ReadVar() == "M->US_CEPC"
		Elseif __cVar == "M->US_CEPC"
			// Atualiza os campos de cobranca
			M->US_ENDCOB := aListCEP[nPos,3]
			M->US_CEPC   := aListCEP[nPos,1]
			M->US_MUNC   := aListCEP[nPos,5]
			M->US_ESTC   := aListCEP[nPos,6]
			M->US_BAIRROC:= aListCEP[nPos,7]
			M->US_TLOGCOB:= aListCEP[nPos,2]
		//Elseif ReadVar() == "M->US_CEPE"
		Elseif __cVar == "M->US_CEPE"
			// Atualiza So os campos de entrega
			M->US_ENDENT := aListCEP[nPos,3]
			M->US_CEPE   := aListCEP[nPos,1]
			M->US_MUNE   := aListCEP[nPos,5]
			M->US_ESTE   := aListCEP[nPos,6]
			M->US_BAIRROE:= aListCEP[nPos,7]
			M->US_TLOGENT:= aListCEP[nPos,2]
		//Elseif ReadVar() == "M->US_CEPREC"
		Elseif __cVar == "M->US_CEPREC"
			// Atualiza So os campos de Recebimento
			M->US_ENDREC := aListCEP[nPos,3]
			M->US_CEPREC := aListCEP[nPos,1]
			M->US_CIDREC := aListCEP[nPos,5]
			M->US_UFREC  := aListCEP[nPos,6]
			M->US_BAIRREC:= aListCEP[nPos,7]
			M->US_TLOGREC:= aListCEP[nPos,2]
		Endif
			
	Else
		&(cEndereco)  := aListCEP[nPos,3]
		&(cCEP)       := aListCEP[nPos,1]
		&(cMun)       := aListCEP[nPos,5]
		&(cEst)       := aListCEP[nPos,6]
		&(cBairro)    := aListCEP[nPos,7]
		&(cTlogEnd)   := aListCEP[nPos,2]
//		If ReadVar() == 'M->A2_CEP'
//			M->A2_ESTADO := Tabela( '12', M->A2_EST, .f. )
//		EndIf
	EndIf
Endif

Return

*******************************
Static Function MancadCep()
*********************************

Local cCep := ""

AxCadastro("ZZ1","Cadastro de CEP")
  
Return()

