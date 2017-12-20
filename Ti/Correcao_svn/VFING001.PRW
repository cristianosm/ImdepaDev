#Include "Totvs.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VFING001  ºAutor  ³Jeferson            º Data ³  09/12/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para atualizar os campos nos cadastros, conforme o  º±±
±±º          ³ CEP selecionado.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Descricao                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Expedito    ³14/08/03³ Adaptacao do programa para atualizacao dos      ³±±
±±³            ³        ³ campos de CEP de entrega, cobranca e recebimento³±±
±±³            ³        ³ do cadastro de prospect (SUS)                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function VFING001( _cAlias )

Local aAreaAtu	:= GetArea()

Default _cAlias :=  Alias()

Private cAliasCampo:= _cAlias

SetPrvt("LOKCEP,NCEP,ATELA,M->A1_END,LREFRESH,M->A1_CEP")
SetPrvt("M->A1_MUN,M->A1_BAIRRO,M->A1_EST,M->A1_LOGRADO,_CCEPRET")
SetPrvt("_cEndereco,_cCEP,_cNomeRot,_cMun,_cBairro,_cEst,lOkCliente,lOkProspect")

lOkCep      := .F.
lOkCliente  := .F.
lOkProspect := .F.

// "Cadastro de Clientes"
If cAliasCampo == 'SA1'

	lOkCliente := .T.
	
	If ReadVar() == "M->A1_CEP"
		_cCepRet   :=  M->A1_CEP
		_cCEP      := "M->A1_CEP"
	Elseif ReadVar() == "M->A1_CEPC"
		_cCepRet   :=  M->A1_CEPC
		_cCEP      := "M->A1_CEPC"
	Elseif ReadVar() == "M->A1_CEPE"
		_cCepRet   :=  M->A1_CEPE
		_cCEP      := "M->A1_CEPE"
	Elseif ReadVar() == "M->A1_CEPREC"
		_cCepRet   :=  M->A1_CEPREC
		_cCEP      := "M->A1_CEPREC"
	Endif
	_cEndereco := "M->A1_END"
	_cMun      := "M->A1_MUN"
	_cBairro   := "M->A1_BAIRRO"
	_cEst      := "M->A1_EST"
	_cTlogend  := "M->A1_TLOGEND"
Endif

// "Cadastro de Prospect"
If cAliasCampo == 'SUS'

	lOkProspect := .T.
	
	If ReadVar() == "M->US_CEP"
		_cCepRet   :=  M->US_CEP
		_cCEP      := "M->US_CEP"
	Elseif ReadVar() == "M->US_CEPC"
		_cCepRet   :=  M->US_CEPC
		_cCEP      := "M->US_CEPC"
	Elseif ReadVar() == "M->US_CEPE"
		_cCepRet   :=  M->US_CEPE
		_cCEP      := "M->US_CEPE"
	Elseif ReadVar() == "M->US_CEPREC"
		_cCepRet   :=  M->US_CEPREC
		_cCEP      := "M->US_CEPREC"
	Endif
	_cEndereco := "M->US_END"
	_cMun      := "M->US_MUN"
	_cBairro   := "M->US_BAIRRO"
	_cEst      := "M->US_EST"
	_cTlogend  := "M->US_TLOGEND"
Endif

// "Cadastro de Fornecedores"
If cAliasCampo == 'SA2' .And. ReadVar() == "M->A2_CEP"
	

	
	_cCepRet   :=  M->A2_CEP
	_cEndereco := "M->A2_END"
	_cCEP      := "M->A2_CEP"
	_cMun      := "M->A2_MUN"
	_cBairro   := "M->A2_BAIRRO"
	_cEst      := "M->A2_EST"
	_cTlogend  := "M->A2_TLOGEND"
Endif

// "Cadastro de Fornecedores"
If cAliasCampo == 'SA2' .And. ReadVar() == "M->A2_REPRCEP"
	_cCepRet   :=  M->A2_REPRCEP
	_cEndereco := "M->A2_REPR_EN"
	_cCEP      := "M->A2_REPRCEP"
	_cMun      := "M->A2_REPMUN"
	_cBairro   := "M->A2_REPBAIR"
	_cEst      := "M->A2_REPEST"
	_cTlogend  := "M->A2_REPTLOG"
Endif


// "Cadastro de Vendedores"
If cAliasCampo == 'SA3'
	_cCepRet   :=  M->A3_CEP
	_cEndereco := "M->A3_END"
	_cCEP      := "M->A3_CEP"
	_cMun      := "M->A3_MUN"
	_cBairro   := "M->A3_BAIRRO"
	_cEst      := "M->A3_EST"
	_cTlogend  := "M->A3_TLOGEND"
Endif

// "Cadastro de Transportadora"
If cAliasCampo == 'SA4'
	_cCepRet   :=  M->A4_CEP
	_cEndereco := "M->A4_END"
	_cCEP      := "M->A4_CEP"
	_cMun      := "M->A4_MUN"
	_cBairro   := "M->A4_BAIRRO"
	_cEst      := "M->A4_EST"
	_cTlogend  := "M->A4_TLOGEND"
Endif

// "Cadastro de Bancos"
If cAliasCampo == 'SA6'
	_cCepRet   :=  M->A6_CEP
	_cEndereco := "M->A6_END"
	_cCEP      := "M->A6_CEP"
	_cMun      := "M->A6_MUN"
	_cBairro   := "M->A6_BAIRRO"
	_cEst      := "M->A6_EST"
	_cTlogend  := "M->A6_TLOGEND"
Endif

// "Cadastro de Suspecte"
If cAliasCampo == 'ACH'
	_cCepRet   :=  M->ACH_CEP
	_cEndereco := "M->ACH_END"
	_cCEP      := "M->ACH_CEP"
	_cMun      := "M->ACH_CIDADE"
	_cBairro   := "M->ACH_BAIRRO"
	_cEst      := "M->ACH_EST"
	_cTlogend  := "M->ACH_TLOGEN"
Endif

// "Cadastro de Concorrentes"
If cAliasCampo == 'AC3'
	_cCepRet   :=  M->AC3_CEP
	_cEndereco := "M->AC3_END"
	_cCEP      := "M->AC3_CEP"
	_cMun      := "M->AC3_MUN"
	_cBairro   := "M->AC3_BAIRRO"
	_cEst      := "M->AC3_EST"
	_cTlogend  := "M->AC3_TLOGEN"
Endif

// "Cadastro de Parceiros"
If cAliasCampo == 'AC4'
	_cCepRet   :=  M->AC4_CEP
	_cEndereco := "M->AC4_END"
	_cCEP      := "M->AC4_CEP"
	_cMun      := "M->AC4_MUN"
	_cBairro   := "M->AC4_BAIRRO"
	_cEst      := "M->AC4_EST"
	_cTlogend  := "M->AC4_TLOGEN"
Endif

// "Cadastro de Contatos"
If cAliasCampo == 'SU5'
	_cCepRet   :=  M->U5_CEP
	_cEndereco := "M->U5_END"
	_cCEP      := "M->U5_CEP"
	_cMun      := "M->U5_MUN"
	_cBairro   := "M->U5_BAIRRO"
	_cEst      := "M->U5_EST"
	_cTlogend  := "M->U5_TLOGEND"
Endif


// "Cadastro de Operadores"
If cAliasCampo == 'SU7'
	_cCepRet   :=  M->U7_CEP
	_cEndereco := "M->U7_END"
	_cCEP      := "M->U7_CEP"
	_cMun      := "M->U7_MUN"
	_cBairro   := "M->U7_BAIRRO"
	_cEst      := "M->U7_EST"
	_cTlogend  := "M->U7_TLOGEND"
Endif

// "Cadastro de Prospects"
/*If cAliasCampo == 'SUS'
	_cCepRet   :=  M->US_CEP
	_cEndereco := "M->US_END"
	_cCEP      := "M->US_CEP"
	_cMun      := "M->US_MUN"
	_cBairro   := "M->US_BAIRRO"
	_cEst      := "M->US_EST"
	_cTlogend  := "M->US_TLOGEND"
Endif*/

ZZ1->( dbSetOrder(1) )

If ZZ1->( dbSeek( xFilial("ZZ1") + _cCepRet ) )
	lOkCep:=.T.
Else
	U_VFING006(cAliasCampo)
//  	Return(_cCepRet)
	Return .T.
Endif

If lOkCep						// CEP Encontrado.
	
	If lOkCliente            	// Cadastro de Clientes
		
		If ReadVar() == "M->A1_CEP"
			// Atualiza os campos de faturamento e cobranca
		    /*
			M->A1_ENDCOB := ZZ1->ZZ1_END
			M->A1_CEPC   := ZZ1->ZZ1_CEP
			M->A1_MUNC   := ZZ1->ZZ1_MUNIC
			M->A1_ESTC   := ZZ1->ZZ1_EST
			M->A1_BAIRROC:= ZZ1->ZZ1_BAIRRO
			M->A1_TLOGCOB:= ZZ1->ZZ1_TLOG
			*/
			&_cEndereco  := ZZ1->ZZ1_END
			&_cCEP       := ZZ1->ZZ1_CEP
			&_cMun       := ZZ1->ZZ1_MUNIC
			&_cBairro    := ZZ1->ZZ1_BAIRRO
			&_cEst       := ZZ1->ZZ1_EST
			&_cTlogend   := ZZ1->ZZ1_TLOG
		Elseif ReadVar() == "M->A1_CEPC"
			// Atualiza So os campos de cobranca
			M->A1_ENDCOB := ZZ1->ZZ1_END
			M->A1_CEPC   := ZZ1->ZZ1_CEP
			M->A1_MUNC   := ZZ1->ZZ1_MUNIC
			M->A1_ESTC   := ZZ1->ZZ1_EST
			M->A1_BAIRROC:= ZZ1->ZZ1_BAIRRO
			M->A1_TLOGCOB:= ZZ1->ZZ1_TLOG
		Elseif ReadVar() == "M->A1_CEPE"
			// Atualiza So os campos de entrega
			M->A1_ENDENT := ZZ1->ZZ1_END
			M->A1_CEPE   := ZZ1->ZZ1_CEP
			M->A1_MUNE   := ZZ1->ZZ1_MUNIC
			M->A1_ESTE   := ZZ1->ZZ1_EST
			M->A1_BAIRROE:= ZZ1->ZZ1_BAIRRO
			M->A1_TLOGENT:= ZZ1->ZZ1_TLOG
		Elseif ReadVar() == "M->A1_CEPREC"
			// Atualiza So os campos de Recebimento
			M->A1_ENDREC := ZZ1->ZZ1_END
			M->A1_CEPREC := ZZ1->ZZ1_CEP
			M->A1_CIDREC := ZZ1->ZZ1_MUNIC
			M->A1_UFREC  := ZZ1->ZZ1_EST
			M->A1_BAIRREC:= ZZ1->ZZ1_BAIRRO
			M->A1_TLOGREC:= ZZ1->ZZ1_TLOG
		Endif
	
	Elseif lOkProspect
	
		If ReadVar() == "M->US_CEP"
			// Atualiza os campos de faturamento e cobranca
			M->US_ENDCOB := ZZ1->ZZ1_END
			M->US_CEPC   := ZZ1->ZZ1_CEP
			M->US_MUNC   := ZZ1->ZZ1_MUNIC
			M->US_ESTC   := ZZ1->ZZ1_EST
			M->US_BAIRROC:= ZZ1->ZZ1_BAIRRO
			M->US_TLOGCOB:= ZZ1->ZZ1_TLOG
			
			&_cEndereco  := ZZ1->ZZ1_END
			&_cCEP       := ZZ1->ZZ1_CEP
			&_cMun       := ZZ1->ZZ1_MUNIC
			&_cBairro    := ZZ1->ZZ1_BAIRRO
			&_cEst       := ZZ1->ZZ1_EST
			&_cTlogend   := ZZ1->ZZ1_TLOG
		Elseif ReadVar() == "M->US_CEPC"
			// Atualiza So os campos de cobranca
			M->US_ENDCOB := ZZ1->ZZ1_END
			M->US_CEPC   := ZZ1->ZZ1_CEP
			M->US_MUNC   := ZZ1->ZZ1_MUNIC
			M->US_ESTC   := ZZ1->ZZ1_EST
			M->US_BAIRROC:= ZZ1->ZZ1_BAIRRO
			M->US_TLOGCOB:= ZZ1->ZZ1_TLOG
		Elseif ReadVar() == "M->US_CEPE"
			// Atualiza So os campos de entrega
			M->US_ENDENT := ZZ1->ZZ1_END
			M->US_CEPE   := ZZ1->ZZ1_CEP
			M->US_MUNE   := ZZ1->ZZ1_MUNIC
			M->US_ESTE   := ZZ1->ZZ1_EST
			M->US_BAIRROE:= ZZ1->ZZ1_BAIRRO
			M->US_TLOGEND:= ZZ1->ZZ1_TLOG
		Elseif ReadVar() == "M->US_CEPREC"
			// Atualiza So os campos de Recebimento
			M->US_ENDREC := ZZ1->ZZ1_END
			M->US_CEPREC := ZZ1->ZZ1_CEP
			M->US_CIDREC := ZZ1->ZZ1_MUNIC
			M->US_UFREC  := ZZ1->ZZ1_EST
			M->US_BAIRREC:= ZZ1->ZZ1_BAIRRO
			M->US_TLOGREC:= ZZ1->ZZ1_TLOG
		Endif
			
	Else
	
		&_cEndereco  := ZZ1->ZZ1_END
		&_cCEP       := ZZ1->ZZ1_CEP
		&_cMun       := Substr(ZZ1->ZZ1_MUNIC,1,Len(&_cMun))
		&_cBairro    := Substr(ZZ1->ZZ1_BAIRRO,1,Len(&_cBairro))
		&_cEst       := ZZ1->ZZ1_EST
		&_cTlogend   := Substr(ZZ1->ZZ1_TLOG,1,Len(&_cTlogend))
		
		If ReadVar() == 'M->A2_CEP'
			M->A2_ESTADO := Tabela( '12', M->A2_EST, .F. )
		EndIf
			
	EndIf
Endif

RestArea(aAreaAtu)
//Return(_cCepRet)
Return .T.



