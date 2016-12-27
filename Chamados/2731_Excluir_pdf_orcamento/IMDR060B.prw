#Include "FWPrintSetup.ch"
#Include "FileIo.ch"
#Include "Protheus.ch"
#Include "Colors.ch"
#Include 'Totvs.ch'

#Define LIMPLIPAG	.F. // Se imprime ou nao box Limite de Pagina...

#Define _ENTER CHR(13) + CHR(10)
//| Posicoes Array aValores Padrao Tela da Verdade
#Define _DESCONTO 2
#Define _FRETE 4
#Define _DESPESA 5

//| Config Impressao ///////////
#Define IMP_PDF 6 //| Impressao em PDF
#Define PAPER_A4 9 //| Tamanho do Papel A4
#Define FNIPPAG	22	//| Numero de Itens que podem ser impressos na Primeira Pagina...
#Define FNISPAG	37	//| Numero de Itens que podem ser impressos apartir da Segunda Pagina
#Define POS_M_MARK 12	//| Linha entre os itens que sera imprema a mensagem de Marketing

//| Cores
#define CLR_CONTIN RGB( 255, 185, 0 )
#define CLR_ORANGE RGB( 255, 229, 204 )
#define CLR_GRAYH RGB( 235, 235, 235 )
#define CLR_GRAY RGB( 224, 224, 224 )
#define CLR_HBLUE RGB( 0, 0, 255 )
#define CLR_HGREEN RGB( 0, 255, 0 )
#define CLR_HCYAN RGB( 0, 255, 255 )
#define CLR_HRED RGB( 255, 0, 0 )
#define CLR_HMAGENTA RGB( 255, 0, 255 )
#define CLR_YELLOW RGB( 255, 255, 0 )
#define CLR_WHITE RGB( 255, 255, 255 )

//| Posicoes Array Itens, Usado no Relatorio
#Define I_CODIGO	1	//| Codigo
#Define I_DESCRI	2	//| Descricao Referencia e Marca que compoem a Descricao do Produto
#Define I_CODNCM	3	//| Codigo NCM do produto
#Define I_UNIDME	4	//| Unidade de Medida
#Define I_QUANTI	5	//| Quantidade
#Define I_VALUNI	6	//| Valor Unitario do Produto
#Define I_ALIPIU	7	//| Aliquota IPI Unitario
#Define I_VAIPIU	8	//| Valor IPI Unitario
#Define I_VALSTU	9	//| Valor Substituicao Tributario Unitario
#Define I_VIPSTU	10	//| Valor + IPI + ST Unitario
#Define I_VIPSTT	11	//| Valor + IPI + ST Total
#Define I_PREVEN	12	//| Previsao de Entrega
#Define I_ALICMS	13	//| Aliquota ICMS
#Define I_REFGATES	14	//| Correia com Referencia Gates


//| Posicoes Array aCliente
#Define C_CONTATO 1	//| Contato
#Define C_MAILCON	2	//| Email Comercial
#Define C_CARGOCO	3	//| Cargo Comprador
#Define C_CODNOME	4	//|
#Define C_CNPJCLI	5
#Define C_ENDERE1	6
#Define C_ENDERE2	7
#Define C_FONECLI	8
#Define C_MAILCLI	9 //| Email Cliente Impresso no Orcamento
#Define C_MAILCEM	10 //| Email Cliente inserido no e-mail

//| Posicoes Array aVendedor
#Define V_NOMEVE 1
#Define V_MAILVE 2
#Define V_NOMERE 3
#Define V_MAILRE 4
#Define V_MAILCH 5
#Define V_MAILCO 6
#Define V_MAILFI	7
#Define V_VEFONE 8
#Define V_FILIAL 9
#Define V_CNPJFI 10
#Define V_ENDER1 11
#Define V_ENDER2 12

//| Posicoes Variavel aCols Tela da Verdade (TMK273)
#Define A_CODIGO RetPosArr(aHeader, "UB_PRODUTO" , 1) // RetPosArr("UB_PRODUTO"	) // Codigo do Produto...
#Define A_DESCRI RetPosArr(aHeader, "UB_DESCRI"	, 1) // Referencia e Marca do Produto...
#Define A_UNIDME RetPosArr(aHeader, "UB_UM"	, 1) // Unidade Medida...
#Define A_QUANTI RetPosArr(aHeader, "UB_QUANT"	, 1) // Quantidade...
#Define A_VALUNI RetPosArr(aHeader, "UB_VRCACRE"	, 1) // Valor com Acrescimo ...
#Define A_ALIPIU RetPosArr(aHeader, "UB_ALIQIPI"	, 1) // Valor Unitario...
#Define A_VALSTU	RetPosArr(aHeader, "UB_ST"	, 1) // Valor Unitario ST
#Define A_VAIPIU	RetPosArr(aHeader, "UB_VALIPI"	, 1) // Valor Unitario IPI
#Define A_PREVEN RetPosArr(aHeader, "UB_DTENTRE"	, 1) // Data de Entrega...
#Define A_TES RetPosArr(aHeader, "UB_TES"	, 1) // TES do Produto...
#Define A_IT_AUTO RetPosArr(aHeader, "UB_CONFITA"	, 1) // Confirma Item Automatico...

#Define A_DELETE	Len(aHeader) + 1

//| Posicoes Array Totais, Usado no Relatorio
#Define T_TOTDES	1	//| Total Despesa
#Define T_TOTFRE 2 //| Total Frete
#Define T_TOTMER	3	//| Total de Mercadoria
#Define T_TOTQTD	4	//| Total Pecas
#Define T_TOTIPI	5	//| Total Geral IPI
#Define T_TOTGST	6	//| Total Geral Substituicao Tributaria
#Define T_TGERAL	7	//| Total Geral
#Define T_PESOLI	8	//| Total Peso Liquido | nPesol := nPesol + (SB1->B1_PESO * __aCCols[nI][A_QUANT])
#Define T_PESOBU	9	//| Total Peso Bruto | nPesob := nPesob + (SB1->B1_PESBRU * __aCCols[nI][A_QUANT])
///#Define T_ACRECP 10 //| Valor Acrescimo/Juros Condicao de Pagamento...

//| Posicoes Array Mensagens
#Define	M_LINHA1	1
#Define	M_LINHA2 2
#Define	M_LINHA3 3
#Define	M_LINHA4 4
#Define	M_LINHA5 5
#Define	M_RODAPE 6

//| Validacoes
#Define NAOFATURANDO .F.
#Define _SAIR_	.F.

// Mascara a Serem Utilizadas
#Define _MASC_VL_U_ "@E 999,999.9999" //| Mascara Valor Unitario
#Define _MASC_VL_T_	"@E 99,999,999.99"	//| Mascara Valor Total
#Define _MASC_AL_U_	"@E 99"	//| Mascara Aliquota Unitario
#Define _MASC_VI_U_	"@E 99,999.99"	//| Mascara Valor Unitario Impostos
#Define _MASC_PE_T_ "@E 999,999,999.99"	//| Mascara Total Peso...

//| Posicao MafisRet em casos especificos....
#Define MF_BSICMIT 1 //| Base do ICMS Item
#Define MF_VLICMIT 2 //| Valor ICMS Item

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUN O : IMDR060B | AUTOR : Cristiano Machado | DATA : 18/02/2016 **
**---------------------------------------------------------------------------**
** DESCRI O: Or amento de Vendas, Utilizado na Tela da Verdade **
**---------------------------------------------------------------------------**
** USO : Especifico para o cliente Imdepa Rolamentos **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
** ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. **
**---------------------------------------------------------------------------**
** PROGRAMADOR | DATA | MOTIVO DA ALTERACAO **
**---------------------------------------------------------------------------**
** | | **
** | | **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User Function IMDR060B(_lPerg)
	*******************************************************************************

	Private oProcess := Nil
	Default _lPerg	:= .T.

	ConfigVar(_lPerg) //| Configura e Inicializa as Variaveis Envolvidas

	bValida := {|| lContinua, lContinua := Valida() } //| Bloco com Valida oes Necess rias...

	If eVal(bValida)

		//| Monta/Obtem todos os dados envolvidos no orcamento em cada Arrays....
		oProcess := MsNewProcess():New( {|lEnd| MontaDados()(@oProcess, @lEnd)} , "Obtendo Valores... ", "", .T. )
		oProcess:Activate()

		//| Imprime o Or amento...apartir dos dados obtidos anteriormente
		oProcess := MsNewProcess():New( {|lEnd| PrintOrc(@oProcess, @lEnd)} , "Gerando o PDF... ", "", .T. )
		oProcess:Activate()

		//| Apresenta Tela com Email
		TelaEmail()

	EndIf

	Return()
	*******************************************************************************
Static Function ConfigVar(_lPerg) //| Configura as Variaves necessarias
	*******************************************************************************
	_SetOwnerPrvt( 'oPrn'	, Nil	)
	_SetOwnerPrvt( 'aCliente'	, {} ) //| Dados Cliente
	_SetOwnerPrvt( 'aVendedor'	, {} ) //| Dados Vendedor
	_SetOwnerPrvt( 'aItens'	, {} ) //| Itens
	_SetOwnerPrvt( 'aTotais'	, {} ) //| Totais
	_SetOwnerPrvt( 'aTransp'	, {} ) //| Tranportado
	_SetOwnerPrvt( 'aMens'	, {} ) //| Mensagens
	_SetOwnerPrvt( 'lContinua'	, .F. ) //| Verifica se Continua
	_SetOwnerPrvt( 'lPerg'	, _lPerg ) //| Define se deve perguntar...
	_SetOwnerPrvt( 'nPagina'	, 0	) //| Numero da Pagina
	_SetOwnerPrvt( 'lMsgMark'	, .F.	) //| Controle se existe mensagens de Marketing para apresentar...
	_SetOwnerPrvt( 'cMsgMark'	, ''	) //| Mensagem de Marketing
	_SetOwnerPrvt( 'nTotMer'	, 0 ) //| Total de Mercadoria
	_SetOwnerPrvt( 'nVIL'	, 350 ) //| nVIL -> Valor Inicial Posicao Linhas Apos Titulo
	_SetOwnerPrvt( 'nVIC'	, 85 ) //| nVIL -> Valor Inicial Coluna Tudo Referente aos Itens
	_SetOwnerPrvt( 'nFPG' , 0 ) //| nFPG -> Fator utilizado para posicionar Linhas apartir da pagina 2
	_SetOwnerPrvt( 'dEmisOrc' , 0 ) //| dEmisOrc -> Data de Emissao do Orcamento conforme Gravado em SUA->UA_EMISSAO
	_SetOwnerPrvt( 'aTES'	, {} ) //| Salva as TES's Utilizadas no Orcamento para posterior tratamento em Mensagens
	_SetOwnerPrvt( 'cLocalPath'	, "C:\MP11\" ) //| Local no cliente onde os arquivos PDF irão ser Salvos....
	_SetOwnerPrvt( 'cPathInServer', "\pdf\" ) //| Local no Servidor Protheus onde os arquivos PDF irão ser Salvos....
    _SetOwnerPrvt( 'cArqName', "" ) //| Nome que o arquivo pdf recebeu no momento em que foi criado ....

	//| Verifica se ja foi faturado o Pedido
	_SetOwnerPrvt( 'lFaturado' , .F.	)
	If ( Alltrim( SUA->UA_STATUS ) == "NF." )
		lFaturado := .T.
	Else
		lFaturado := .F.
	EndIf

	//| Verifica se eh Orcamento ou pedido
	_SetOwnerPrvt( 'lEhOrc'	, .F.	)
	If ( M->UA_OPER == "1" )
		lEhOrc := .F.
		dEmisOrc := M->UA_EMISSAO
	Else
		lEhOrc := .T.
		dEmisOrc := dDataBase
	EndIf

	//| Somente Substitui o __ACOLS caso seja Or amento j Faturado... |
	If lFaturado
		__aCCols := aCols
	EndIf

	_SetOwnerPrvt( 'nTotPag'	, 0 ) //| Total de Paginas...

	//| Apura o Numero Total de Paginas...
	//nAux := Mod( LenSD(__aCCols) , FNIPPAG )
	//If nAux == 0
	If ( LenSD(__aCCols) < FNIPPAG ) //| Caso o Numero de Itens caiba na Primeira Pagina...
		nTotPag := 1
	Else
		nTotPag := 1
		nQtdISPP := LenSD(__aCCols) - FNIPPAG // Remove do Calculo os Itens da Primeira Pagina
		nAux := Mod( nQtdISPP , FNISPAG ) //| Verifica quantas Paginas Necessarias para os Demais itens
		If nAux == 0
			nTotPag += NoRound( ( nQtdISPP / FNISPAG ) , 0 )
		Else
			nTotPag += NoRound( ( nQtdISPP / FNISPAG ) + 1, 0 )
		EndIf
	EndIf

	Return()
	*******************************************************************************
Static Function Valida()//| Valida es Necessarias
	*******************************************************************************
	Local lValidacao := .T.

	//| Solicita o Click na Condi o de Pagamento antes de emitir o Or amento...

	If !ExistDir(cLocalPath)
		If MakeDir (cLocalPath ) <> 0
			IW_MsgBox("Nao foi possivel criar o Diretorio "+cLocalPath+"' este necessario, para salvar o arquivo PDF. Entrar em contato com a TI.","Impressao de Orcamento/Pedido", "ALERT")
			lValidacao := _SAIR_
		EndIf
	EndIf

	//| Solicita Gravacao de Or amento Novo ou Alterado
	If lValidacao .And. _lAltOrc .And. !lPerg //.And. Alltrim(Procname(1)) <> "U_TMKVFIM"//.And. Empty(M->UA_DOC) .AND. PROCNAME(2) == "ACTIVATE" //PROCNAME(1)<> "U_TMKR03" //PROCNAME(1) <> "U_TMKR3A"
		IW_MsgBox("Como este Or amento/Pedido foi alterado, realize a gravacao antes da Impressao","Impressao de Or amento/Pedido", "ALERT")
		lValidacao := _SAIR_
	Endif

	IF !_ljaCPaCP .And. lValidacao
		IW_MsgBox("Por favor, clique na Condi o de pagamento antes de imprimir o Or amento","Impressao de Or amento/Pedido", "ALERT")
		lValidacao := _SAIR_
	EndIf

	// Solicita Gravacao de Or amento Vencido...
	If lFaturado == NAOFATURANDO //| Somente Efetua esta validacao em Or amento n o Faturados... |
		If lValidacao .And. (dDataBase > M->UA_DTLIM .AND. M->UA_DOC<>' ') .And. !lPerg
			IW_MsgBox("Como este Or amento esta Vencido, realize a gravacao antes da Impressao","Impressao de Or amento/Pedido", "ALERT")
			lValidacao := _SAIR_
		EndIf
	EndIf

	//| Pergunta se o Vendedor deseja abrir o Or amento...
	If lPerg .And. lValidacao
		//	If !( IW_MsgBox( "Deseja olhar o Or amento ? " , "Escolha uma Opcao ..." , "YESNO" ) )
		//	lValidacao := _SAIR_
		//	EndIf
	EndIf

	Return ( lValidacao )
	*******************************************************************************
Static Function MontaDados()//| Obtem e Monta todos os Dados envolvidos no Orcamento
	*******************************************************************************
	oProcess:SetRegua1(5)
	oProcess:SetRegua2(0)
	//| Obtem Dados do Cliente
	oProcess:IncRegua1("Verificando Cliente...")
	DCliente(@aCliente)

	//| Obtem Dados Referente ao Vendedor, N Orc. e Filial
	oProcess:IncRegua1("Verificando Vendedor...")
	DVendedor(@aVendedor)

	//| Obtem dados dos Itens
	oProcess:IncRegua1("Verificando Itens...")
	DItens(@aItens)

	//| Calcula Totais e outros dados finais...
	oProcess:IncRegua1("Verificando Totais...")
	DTotOut(@aTotais)

	//| Monta as Mensagens de Observacoes e Rodape
	oProcess:IncRegua1("Verificando Mensagens...")
	DMsgens(@aMens)

	Return()
	*******************************************************************************
Static Function DVendedor(aVendedor)//| Obtem Dados Referente ao Vendedor, N Orc. e Filial
	*******************************************************************************

	cAliasSA1 := SA1->( GetArea() )
	aVendedor := {"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"", "", "", "" }

	cImdepa := GetMV('MV_IMDEPA')
	//DbSelectArea("SA1")

	If lehOrc
		aVendedor[V_NOMEVE] := SA1->(Posicione("SA3",1,xFilial("SA3")+SA1->A1_VENDEXT,"A3_NOME"))
	Else
		aVendedor[V_NOMEVE] := SA1->(Posicione("SU7",1,xFilial("SU7")+M->UA_OPERADO,"U7_NOME"))
	EndIf

	//aVendedor[V_NOMEVE] := SA1->(Posicione("SU7",1,xFilial("SU7")+M->UA_OPERADO	,"U7_NOME"))
	aVendedor[V_MAILVE] := Lower(SA1->(Posicione("SA3",1,xFilial("SA3")+SA1->A1_VENDEXT	,"A3_EMAIL")))
	aVendedor[V_NOMERE] := SA1->(Posicione("SA3",1,xFilial("SA3")+SA1->A1_VEND	,"A3_NOME"))
	aVendedor[V_MAILRE] := Lower(SA1->(Posicione("SA3",1,xFilial("SA3")+SA1->A1_VEND	,"A3_EMAIL")))
	aVendedor[V_MAILCH] := Lower(SA1->(Posicione("SA3",1,xFilial("SA3")+SA1->A1_CHEFVEN	,"A3_EMAIL")))
	aVendedor[V_MAILCO] := Lower(SA1->(Posicione("SA3",1,xFilial("SA3")+SA1->A1_VENDCOO	,"A3_EMAIL")))

	SA1->( DbSeek(xfilial('SA1') + cImdepa + cFilAnt , .F. ))
	If At(';',SA1->A1_EMAIL) > 0
		aVendedor[V_MAILFI] := Lower(Substr(SA1->A1_EMAIL,1,At(';',SA1->A1_EMAIL)-1))
	Else
		aVendedor[V_MAILFI] := Lower(Alltrim(SA1->A1_EMAIL))
	EndIf

	aVendedor[V_FILIAL] := "IMDEPA: " + SM0->M0_CODFIL + " - FILIAL "+ PadR( Alltrim( SA1->A1_MUN ), 18, " " )
	aVendedor[V_CNPJFI] := " - " + Transform(SA1->A1_CGC, "@R 99.999.999/9999-99")
	aVendedor[V_ENDER1] := AllTrim(SA1->A1_TLOGEND) + " " + AllTrim( U_ALTEND(SA1->A1_END) ) + ", " + AllTrim(Str(SA1->A1_NUMEND,6)) + " - " + AllTrim(SA1->A1_COMPEND)
	aVendedor[V_ENDER2] := AllTrim(SA1->A1_MUN) + ' - ' + SA1->A1_EST + ' - ' + Transform(SA1->A1_CEP, "@R CEP 99.999-999")

	If Len(Alltrim(SA1->A1_DDD)) <= 2
		aVendedor[V_VEFONE] := Transform(SA1->A1_DDD,'@R (99)')
	Else
		aVendedor[V_VEFONE] := Transform(SA1->A1_DDD,'@R (999)')
	EndIf
	If Len(Alltrim(SA1->A1_DDD)) <= 8
		aVendedor[V_VEFONE] += Transform(SA1->A1_TEL, "@R 9999-9999")
	Else
		aVendedor[V_VEFONE] += Transform(SA1->A1_TEL, "@R 99999-9999")
	EndIf

	RestArea(cAliasSA1)

	Return()
	*******************************************************************************
Static Function DCliente(aCliente)//| Obtem Dados do Cliente
	*******************************************************************************

	aCliente := {"" , "", "", "", "", "", "", "", "", "" }

	SA1->( DbSeek(xfilial('SA1') + M->UA_CLIENTE + M->UA_LOJA, .F. ) )
	SU5->( dbseek(xFilial('SU5')+M->UA_CODCONT) )

	aCliente[C_CONTATO]	:= Substr(SU5->U5_CONTAT,1,25)

	If At(';',SU5->U5_EMAIL) > 0
		aCliente[C_MAILCON] := Lower(Substr(SU5->U5_EMAIL,1,At(';',SU5->U5_EMAIL)-1))
	Else
		aCliente[C_MAILCON] := Lower(Alltrim(SU5->U5_EMAIL))
	EndIf

	aCliente[C_CARGOCO] := SubStr(SUM->UM_DESC,1,35)

	aCliente[C_CODNOME] := SA1->A1_COD + ' - ' + PadR( Alltrim( SA1->A1_NREDUZ ), 22, " " )
	aCliente[C_CNPJCLI] := ' - ' + If( SA1->A1_PESSOA == 'J',Transform(SA1->A1_CGC, "@R 99.999.999/9999-99"), Transform(SA1->A1_CGC, "@R 999.999.999-99") )
	aCliente[C_ENDERE1] := AllTrim(SA1->A1_TLOGEND) + " " + AllTrim( U_ALTEND(SA1->A1_END) ) + ", " + AllTrim(Str(SA1->A1_NUMEND,6)) + " - " + AllTrim(SA1->A1_COMPEND)
	aCliente[C_ENDERE2] := AllTrim(SA1->A1_MUN) + ' - ' + SA1->A1_EST + ' - ' + Transform(SA1->A1_CEP, "@R CEP: 99.999-999")

	If Len(Alltrim(SA1->A1_DDD)) <= 2
		aCliente[C_FONECLI] := Transform(SA1->A1_DDD,'@R (99)')
	Else
		aCliente[C_FONECLI] := Transform(SA1->A1_DDD,'@R (999)')
	EndIf
	If Len(Alltrim(SA1->A1_DDD)) <= 8
		aCliente[C_FONECLI] += Transform(SA1->A1_TEL, "@R 9999-9999")
	Else
		aCliente[C_FONECLI] += Transform(SA1->A1_TEL, "@R 99999-9999")
	EndIf

	If At(';',SA1->A1_EMAIL) > 0
		aCliente[C_MAILCLI] := Lower(Substr(SA1->A1_EMAIL,1,At(';',SA1->A1_EMAIL)-1))
	Else
		aCliente[C_MAILCLI] := Lower(Substr(SA1->A1_EMAIL,1))
	EndIf

	aCliente[C_MAILCEM]	:= Lower(Substr(SA1->A1_EMAIL,1))
	Return()
	*******************************************************************************
Static Function DItens(aItens)//| Obtem dados dos Itens
	*******************************************************************************
	Local nIok	:= 0
	Local nItem	:= 0
	Local bVIPSTU	:= {|| __aCCols[nItem][A_VALUNI] + __aCCols[nItem][A_VAIPIU] + __aCCols[nItem][A_VALSTU] }
	Local bVIPSTT	:= {|| eVal(bVIPSTU) * __aCCols[nItem][A_QUANTI] }
	Local bCAICMS	:= {|| Round( MafisRet(nItem, "IT_ICMS" )[MF_VLICMIT] / MafisRet(nItem, "IT_ICMS" )[MF_BSICMIT] * 100, 0 ) }

	For nItem := 1 To Len(__aCCols)

		If !__aCCols[nItem][A_DELETE] // Desconsidera os Itens Deletados...
			nIok += 1
			Aadd( aItens, { "", "", "", "", "", "", "", "", "", "", "", "", "","" } )

			aItens[nIok][I_CODIGO] := PadC( Alltrim( Alltrim(__aCCols[nItem][A_CODIGO]) ), 13, " " )

			If __aCCols[nItem][A_IT_AUTO]=='1' //Tratamento para Descri o Especifica do Produto
				aItens[nIok][I_DESCRI]:= SB1->(FNewDescri(__aCCols[nItem][A_CODIGO], PadR( Substr(__aCCols[nItem][A_DESCRI],1,30),50, " " )))
			Else
				aItens[nIok][I_DESCRI] := PadR( Substr(__aCCols[nItem][A_DESCRI],1,30),50, " " )
			EndIf


			aItens[nIok][I_REFGATES]   :=  FRefGates(PadR( Alltrim( Alltrim(__aCCols[nItem][A_CODIGO]) ), 15, " " ))


			aItens[nIok][I_CODNCM] := Posicione("SB1",1,xFilial("SB1")+ __aCCols[nItem][A_CODIGO], "B1_POSIPI" ) //PadR( Alltrim( SB1->B1_POSIPI	), 08, " " )
			aItens[nIok][I_UNIDME] := PadR( Alltrim( __aCCols[nItem][A_UNIDME] ), 02, " " )

			aItens[nIok][I_QUANTI] := Transform( __aCCols[nItem][A_QUANTI]	, _MASC_VL_T_ )
			aItens[nIok][I_VALUNI] := Transform( __aCCols[nItem][A_VALUNI]	, _MASC_VL_U_ )
			aItens[nIok][I_ALIPIU] := Transform( MaFisRet( nItem , "IT_ALIQIPI" ), _MASC_AL_U_ ) //Transform( __aCCols[nItem][A_ALIPIU]	, _MASC_AL_U_ )
			aItens[nIok][I_VAIPIU] := Transform( __aCCols[nItem][A_VAIPIU]	, _MASC_VI_U_ )
			aItens[nIok][I_VALSTU] := Transform( __aCCols[nItem][A_VALSTU]	, _MASC_VI_U_ )
			aItens[nIok][I_VIPSTU] := Transform( eVal(bVIPSTU)	, _MASC_VL_U_ )
			aItens[nIok][I_VIPSTT] := Transform( eVal(bVIPSTT)	, _MASC_VL_T_ )

			aItens[nIok][I_PREVEN] := Dtoc( __aCCols[nItem][A_PREVEN] )

			// aItens[nIok][I_ALICMS] := Transform( eVal( bCAICMS ), _MASC_AL_U_ ) //Transform( MaFisRet( nItem , "IT_ALIQICM" ), _MASC_AL_U_ )
			aItens[nIok][I_ALICMS] := Transform( MaFisRet( nItem , "IT_ALIQICM" ), _MASC_AL_U_ )

			//| Soma Total de Mercadoria aqui para Usar em Calculos de Fatores....
			nTotMer += ( __aCCols[nItem][A_VALUNI] * __aCCols[nItem][A_QUANTI] )

			FAddTES(__aCCols[nItem][A_TES])// Adiciona as TES ao Array de Controle de TES para Mensagens Posteriores...

		EndIf

	Next

	//|Ordena Por Codigo de Produto... Como nao possui numero de item, eh uma maneira de se localizar facilmente um item
	//aSort(aItens, , , { | x,y | x[I_CODIGO] < y[I_CODIGO] } )

	Return()
	*******************************************************************************
Static Function DTotOut(aTotais) //| Calcula Totais e outros dados finais...
	*******************************************************************************
	Local nTotDes := nTotQtd := nTotIpi := 0
	Local nTotGST	:= nTGeral := nPesoLi	:= 0
	Local nPesoBu := nTotFre := nTotGer	:= 0
	Local nFatIte	:= nVRDespT := nVRDespI := 0
	Local nVRFretT := nVRFretI := 0 //nAcreCP := 0
	DbSelectArea("SB1")

	For nT := 1 To Len(aItens)

		DbSeek(xFilial("SB1")+Alltrim(aItens[nT][I_CODIGO]), .F. )

		nTotDes	:= aValores[_DESPESA]
		nTotFre	:= aValores[_FRETE]

		nTotQtd += CNV( aItens[nT][I_QUANTI] )
		nTotGST	+= MaFisRet(nT,"IT_VALSOL")

		nPesoLi	+= ( SB1->B1_PESO * CNV(aItens[nT][I_QUANTI]) )
		nPesoBu	+= ( SB1->B1_PESBRU * CNV(aItens[nT][I_QUANTI]) )

		//| Usado Para Avaliacao de Mensagens Marketing
		DMarketing()

	Next

	nTotIpi := MaFisRet(,"NF_VALIPI")
	nTotGer	:= MaFisRet(,"NF_TOTAL")
	//	nAcreCP := Posicione("SE4",1,xFilial("SE4")+M->UA_CONDPG,"E4_ACRREAL")

	aTotais := { "", "", "", "", "", "", "", "", "", "" }

	aTotais[T_TOTDES] := Transform( nTotDes, _MASC_VL_T_ )
	aTotais[T_TOTFRE] := Transform( nTotFre, _MASC_VL_T_ )
	aTotais[T_TOTMER] := Transform( nTotMer, _MASC_VL_T_ )
	aTotais[T_TOTQTD] := Transform( nTotQtd, _MASC_VL_T_ )
	aTotais[T_TOTIPI] := Transform( nTotIpi, _MASC_VL_T_ )
	aTotais[T_TOTGST] := Transform( nTotGST, _MASC_VL_T_ )
	aTotais[T_TGERAL] := If(nTotGer < nTotMer, Transform( nTotMer, _MASC_VL_T_ ),Transform( nTotGer, _MASC_VL_T_ ) ) //| Em alguns Casos, o Valor da Mercadoria fica 1 centavo maior que o total geral...Exemplo: Orcamento: 963403 Filial: 13 Cliente : 015426-03 Data: 07/03/16
	aTotais[T_PESOLI] := Transform( nPesoLi, _MASC_PE_T_ )
	aTotais[T_PESOBU] := Transform( nPesoBu, _MASC_PE_T_ )
	//aTotais[T_ACRECP] := Transform( nAcreCP, _MASC_PE_T_ )

	Return()
	*******************************************************************************
Static Function DMsgens(aMens)//| Monta as Mensagens de Observacoes e Rodape
	*******************************************************************************

	Local MsgRodape  := SuperGetMV("IM_MSROORC", .F., '[Emitido em '+ Dtoc(dEmisOrc) +' - Proposta Vï¿½lida por 2 Dias - Sera Acrescida Despesa Bancï¿½ria por Duplicata ] - Visite nosso site WWW.IMDEPA.COM.BR', Nil )
	Private cEmisOrc := Dtoc(dEmisOrc)
	//| TRATAMENTO para utilizar Parametro SX6 e Variavel... Chamado:9256
	MsgRodape := "'" + StrTran(MsgRodape, 'cEmisOrc', "'+cEmisOrc+'" ) + "'"
	MsgRodape := &MsgRodape.
	MsgRodape := SUBSTR(MsgRodape,1,122)

	aMens := { "* ", "* ", "* ", "* ", "* ", " " }

	//| Mensagem Linha 01
	aMens[M_LINHA1] := '* Faturamento Mï¿½nimo de R$ ' + Alltrim(Transform( GetMv("IM_PEDMINF"),'@E 999,999.99')) +' Reais'

	//| Mensagem Linha 02
	aMens[M_LINHA2] := '* Para compras fora do estado ï¿½ fundamental levar em consideraï¿½ï¿½o as mesmas bases de ICMS e ST.'

	//| Mensagem Linha 03
	If SA1->A1_EST == 'GO' .And. SA1->A1_GRPSEG $ "AG3/AU3/IN3" .And. cFilant == '04'
		aMens[M_LINHA3] := '* Ao comparar nossos preï¿½os com outros fornecedores locais, favor verificar se a Subs. Trib. estï¿½ destacada (TARE).'
	EndIf

	//| Mensagem Linha 04
	If Substr(SA1->A1_GRPSEG,3,1) == "3"
		If U_FVerNcm()// Verifica se Produto eh ST
			If !U_FCnaeAuto()// Verifica Cnae Do Cliente
				If SB1->B1_INDUSTR == "S"
					If (! cFilAnt $ Alltrim( GetMv("MV_MENFIL"))) .And. (! cFilAnt + SA1->A1_EST $ Alltrim( GetMv("MV_MENFIL1"))) .And. SA1->A1_CONAGRI <> "1" //Agostinho - 24/03/2009 - Chamado AAZOSN retirada da mensagem para as filias 02-CUI, 04-GOI e 05-CDP quando venda para o RS
						aMens[M_LINHA4] := '* Mercadorias P/ Uso e Aplicacao Exclusivamente Industrial Nï¿½o Sujeita a ST Cfe Protocolo 49/08 '
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	//| Mensagem Linha 05
	aMens[M_LINHA5] := '* '
	If xFilial("SUB") == "13" //Curitiba aMens[M_LINHA5] := '* '
		If FAddTES("514",.T.)
			aMens[M_LINHA5] := '* ICMS Diferido em 33,33%, cfe Art. 108 - RICMS/PR.'
		EndIf
	EndIf
	// Mensagem Observacao Orcamento...Colocamos na Linha 3 ou 4, conforme estiver em branco..
	If !Empty(M->UA_OBSORC)
		If ( aMens[M_LINHA3] == "* " )
			aMens[M_LINHA3] += Substr(M->UA_OBSORC,1,100)
			aMens[M_LINHA3] := StrTran(aMens[M_LINHA3], _ENTER, " ")
		ElseIf	( aMens[M_LINHA4] == "* " )
			aMens[M_LINHA4] += Substr(M->UA_OBSORC,1,100)
			aMens[M_LINHA4] := StrTran(aMens[M_LINHA4], _ENTER, " ")
		EndIf
	EndIf

	//| Mensagem RODAPE
	aMens[M_RODAPE] := Padc(MsgRodape,122)

	Return()
	*******************************************************************************
Static Function DMarketing() //| Verifica e Monta as Mensagens de Marketing
	*******************************************************************************

	//DbSelectArea("SB1")
	//DbSeek(xFilial("SB1")+aItem[I_CODIGO] ,.F.)

	//| Regra : Correias Continental ...
	If !lMsgMark
		If ( ( SB1->B1_SGRB1 == "220000" .And. SB1->B1_GRMAR3 == "000510" .And. SB1->B1_MERCADO == "N" ) .Or. ( !SUA->UA_PROSPEC .And. SA1->A1_GRPSEG == "AG3" ) )
			lMsgMark := .T.
			cMsgMark := 'Correias Agricolas CONTINENTAL: ï¿½nicas com 100% de garantia do fabricante !!!'
			//	'01234567890123456789012345678901234567890123456789012345678901234567890123456
			//	'0 1 2 3 4 5 6 7

		EndIf
	EndIf

	cMsgMark := PADC(cMsgMark,76,' ') // Msg no Maximo pode Conter 76 Caracteres...

	Return()
	*******************************************************************************
Static Function PrintOrc()
	*******************************************************************************
	Private oBruCC := TBrush():New2(,CLR_GRAYH	)// Cinza Claro
	Private oBruCI := TBrush():New2(,CLR_GRAY	)// Cinza
	Private oBruAM := TBrush():New2(,CLR_YELLOW	)// Amarelo
	Private oBruLJ := TBrush():New2(,CLR_ORANGE	)// Laranja Claro
	Private oBruCO := TBrush():New2(,CLR_CONTIN	)// Laranja Logo Continental
	Private oTFont

	Private cFilePrintert	:= CriaTrab( ,.F.) + ".pdf"
	Private nDevice	:= IMP_PDF
	Private lAdjustToLegacy	:= .T.
	//Private cPathInServer	:= "\pdf\"
	//Private cLocalPath	:= "C:\MP11\"
	Private lDisabeSetup	:= .T.
	Private lTReport	:= .F.
	Private cPrinter	:= ""
	Private lServer	:= .F.
	Private lPDFAsPNG	:= .F.
	Private lRaw	:= .F.
	Private lViewPDF	:= .T.
	Private nQtdCopy	:= NIL
	Private lSetView	:= .F.

	Private nI	:= 0 // Auxiliar para Posicionamento dos Itens na Impressao
	Private nIp	:= 1 // Auxiliar para Controle de Itens j'a Impressos
	Private nPagina	:= 0 // Auxiliar para Controle da Pagina atual ...
	Private bPriPag	:= {|| If(nPagina == 1,.T.,.F.)} // Verifica se esamos na Primeira Pagina

	//| Configura a Impressao ...
	oPrn := FWMSPrinter():New(cFilePrintert, nDevice, lAdjustToLegacy ,cPathInServer, lDisabeSetup, lTReport, @oPrn, cPrinter, lServer, lPDFAsPNG, lRaw, lViewPDF )
	oPrn:SetPortrait() // Retrato
	oPrn:SetPaperSize(PAPER_A4)
	oPrn:SetMargin(20,50,15,0) //oPrn:SetMargin(50,05,10,15)
	oPrn:cPathPDF	:= cLocalPath
	oPrn:SetViewPDF(lSetView)

	oProcess:SetRegua1(0)
	oProcess:SetRegua2(0)

	oProcess:IncRegua1("Gerando o PDF...")
	//| Impressao...das Paginas...
	For nPagina := 1 To nTotPag
		oProcess:IncRegua2("Pï¿½gina..." + cValToChar(nPagina))

		//Variavel usada como Fator de Posicionamento na Impressao dos Itens
		nI	:= 0

		If !EvAL(bPriPag) //| Veeifica se eh a primeiro pagina ou nao...
			nFPG := -770
		EndIf

		//| Inicia uma Pagina
		oPrn:StartPage()

		//|Imprime Layout Base Completo do Or amento
		PLayout(@oPrn)

		IF EvAL(bPriPag)

			//| Imprime Dados como: N Orc., Dados Filial e Vendedor
			PVendedor(@oPrn)

			//| Imprime Dados do Cliente
			PCliente(@oPrn)

		EndIf

		//| Imprime os Itens do Orcamento
		aEval( aItens, {|aItem| nI+=1, PItens(@oPrn, aItem )} , nIp )

		//| Impressao dos Totais e Outras informacoes finais...
		PTotais(@oPrn)

		//IF EvAL(bPriPag)
		//| Mensagens de Observacoes e Rodape
		PMsgens(oPrn)
		//EndIf

		//| Encerra a Pagina
		oPrn:EndPage()

	Next

	//| Abre a Impressao
	oPrn:Preview()

	Return()
	*******************************************************************************
Static Function PVendedor(oPrn)//| Imprime Dados como: N Orc., Dados Filial e Vendedor
	*******************************************************************************

	//| Filial
	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nVIL+350 , 50 , aVendedor[V_FILIAL] , oFont , , 0 , )

	//| CNPJ
	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nVIL+350 , 775	, aVendedor[V_CNPJFI] , oFont , , 0 , )

	//| Dados Vendedor
	oFont := TFont():New( 'Courier new' , , -10)
	oPrn:Say( nVIL+450 , 100 , aVendedor[V_NOMEVE] , oFont , , 0 , )

	//| Telefone
	oPrn:Say( nVIL+525 , 100 , aVendedor[V_VEFONE] , oFont , , 0 , )

	//| Email Vendedor
	oPrn:Say( nVIL+450 , 650 , aVendedor[V_MAILVE] , oFont , , 0 , )

	//| Email Comercial
	oPrn:Say( nVIL+525 , 650 , aVendedor[V_MAILFI] , oFont , , 0 , )

	//| Endereco
	oPrn:Say( nVIL+600 , 100 , aVendedor[V_ENDER1] , oFont , , 0 , )
	oPrn:Say( nVIL+630 , 100 , aVendedor[V_ENDER2] , oFont , , 0 , )

	Return()
	*******************************************************************************
Static Function PCliente(oPrn)	//| Imprime Dados do Cliente
	*******************************************************************************

	//| Dados Cliente...
	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nVIL+350 , 1180+(nVIC/2) , 'CLIENTE:' + aCliente[C_CODNOME] , oFont , , 0 , )

	//| CNPJ...
	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nVIL+350 , 1880+(nVIC/2) , aCliente[C_CNPJCLI] , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -10)
	oPrn:Say( nVIL+450 , 1230+(nVIC/2) , aCliente[C_CONTATO] , oFont , , 0 , )

	oPrn:Say( nVIL+525 , 1230+(nVIC/2) , aCliente[C_FONECLI] , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -10)
	oPrn:Say( nVIL+450 , 1780+(nVIC/2) , aCliente[C_MAILCON] , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -10)
	oPrn:Say( nVIL+470 , 1780+(nVIC/2) , aCliente[C_MAILCLI] , oFont , , 0 , )

	oPrn:Say( nVIL+525 , 1780+(nVIC/2) , aCliente[C_CARGOCO] , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -10)
	oPrn:Say( nVIL+600 , 1230+(nVIC/2) , aCliente[C_ENDERE1] , oFont , , 0 , )
	oPrn:Say( nVIL+630 , 1230+(nVIC/2) , aCliente[C_ENDERE2] , oFont , , 0 , )

	Return()
	*******************************************************************************
Static Function PItens(oPrn, aItem)
	*******************************************************************************
	Local nPIMM := -1 //| Variavel de Controle para Pulo quando ocorre Mensagem de Marketing
	Local bPos := {|| nFPG+nVIL+850 + ((nI+nPIMM) * 50 )} //| Monta a Posicao da Linha
	Local bPon := {|| nFPG+nVIL+870 + ((nI+nPIMM) * 50 )}	//| Monta a Posicao da Linha para NCM
	Local bPox := {|| nFPG+nVIL+887 + ((nI+nPIMM) * 50 )}	//| Monta a Posicao da Linha Gates


	Local bItem := {|| StrZero((nIp+nI)-1,3) } //| Monta o Numero do Item

	//|Controla a Impressao dos Itens..
	If EvAL(bPriPag)
		If nI > FNIPPAG
			nIp := ( FNIPPAG ) + 1
			Return()
		EndIf
	Else
		If nI > FNISPAG
			nIp := ( FNIPPAG + ((nPagina-1) * FNISPAG) ) + 1
			Return()
		EndIf
	EndIf

	//| Tratamento de Impressao Quando Existe Mensagens de Marketing...
	If lMsgMark .And. nI >= POS_M_MARK
		nPIMM := 1
	EndIf

	//| Codigo Produto
	oFont := TFont():New( 'Courier new' , , -10);	oFont:Bold := .F.
	oPrn:Say( eVal(bPos) , 30 , aItem[I_CODIGO] , oFont , , 0 , )

	//| Item
	oFont := TFont():New( 'Courier new' , , -9);	oFont:Italic := .T.
	oPrn:Say( eVal(bPon) , 25+nVIC , eVal(bItem) , oFont , , 0 , )

	//| Descricao
	oFont := TFont():New( 'Courier new' , , -10); oFont:Bold := .T.
	oPrn:Say( eVal(bPos) , 162+nVIC , aItem[I_DESCRI] , oFont , , 0 , )


	//| NCM
	oFont := TFont():New( 'Courier new' , , -9);	oFont:Italic := .T.
	oPrn:Say( eVal(bPon) , 350-193+nVIC ,Alltrim(aItem[I_CODNCM]), oFont , , 0 , )
	//oPrn:Say( eVal(bPon) , 350-193+nVIC ,Alltrim(aItem[I_CODNCM]) +" "+aItem[I_REFGATES], oFont , , 0 , )

	//| NCM
	oFont := TFont():New( 'Courier new' , , -10);	oFont:Bold := .T.
	oPrn:Say( eVal(bPon) , 350-193+99+nVIC ," "+aItem[I_REFGATES], oFont , , 0 , )



	//If aItem[I_REFGATES]
	 //Msginfo('Tem Correias')
	//Endif


	//| Unidade Medida
	oFont := TFont():New( 'Courier new' , , -10)
	oPrn:Say( eVal(bPos) , 668+nVIC , aItem[I_UNIDME] , oFont , , 0 , )

	//| Quantidade
	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( eVal(bPos) , 690+nVIC , aItem[I_QUANTI] , oFont , , 0 , )

	//| Valor Unitario
	oFont := TFont():New( 'Courier new' , , -10)
	oPrn:Say( eVal(bPos) , 947+nVIC , aItem[I_VALUNI] , oFont , , 0 , )

	//| Aliquota ICMS
	oFont := TFont():New( 'Courier new' , , -10)
	oPrn:Say( eVal(bPos) , 1172+nVIC , aItem[I_ALICMS] , oFont , , 0 , )

	//| Aliquota IPI
	oFont := TFont():New( 'Courier new' , , -10)
	oPrn:Say( eVal(bPos) , 1247+nVIC , aItem[I_ALIPIU] , oFont , , 0 , )

	// Valor IPI
	oFont := TFont():New( 'Courier new' , , -10)
	oPrn:Say( eVal(bPos) , 1307+nVIC , aItem[I_VAIPIU] , oFont , , 0 , )

	//| Valor ST Unitario
	oFont := TFont():New( 'Courier new' , , -10)
	oPrn:Say( eVal(bPos) , 1467+nVIC , aItem[I_VALSTU] , oFont , , 0 , )

	//| Valor + IPI + ST Unitario
	oFont := TFont():New( 'Courier new' , , -10); oFont:Bold := .T.
	oPrn:Say( eVal(bPos) , 1648+nVIC , aItem[I_VIPSTU] , oFont , , 0 , )

	//| Valor + IPI + St Total
	oFont := TFont():New( 'Courier new' , , -10); oFont:Bold := .T.
	oPrn:Say( eVal(bPos) , 1875+nVIC , aItem[I_VIPSTT] , oFont , , 0 , )

	//| Previsao de Entrega
	oFont := TFont():New( 'Courier new' , , -10)
	oPrn:Say( eVal(bPos) , 2110+nVIC , aItem[I_PREVEN] , oFont , , 0 , )


	Return()
	*******************************************************************************
Static Function PTotais(oPrn)//| Imprime os Totais e Outras Informacoes Finais
	*******************************************************************************

	//| Linha 1
	//| Total Mercadoria
	oFont := TFont():New( 'Courier new' , , -18)
	oPrn:Say( nVIL+2199 , 220 , aTotais[T_TOTMER], oFont , , 0 , ) //| Despesa

	//| Total IPI
	oFont := TFont():New( 'Courier new' , , -18)
	oPrn:Say( nVIL+2199 , 780 , aTotais[T_TOTIPI] , oFont , , 0 , ) //| IPI

	//| Total ST
	oFont := TFont():New( 'Courier new' , , -18)
	oPrn:Say( nVIL+2199 , 1330 , aTotais[T_TOTGST] , oFont , , 0 , )

	//| Total Geral
	oFont := TFont():New( 'Courier new' , , -18)
	oPrn:Say( nVIL+2199 , 1945 , aTotais[T_TGERAL] , oFont , , 0 , )

	//| Linha 2
	//| Transportadora
	oFont := TFont():New( 'Courier new' , , -12)
	oPrn:Say( nVIL+2299 , 300 , M->UA_TRANSP + " - " + AllTrim(Posicione("SA4",1,xFilial("SA4")+M->UA_TRANSP,"A4_NOME")) , oFont , , 0 , )

	//| Tipo de Frete
	oFont := TFont():New( 'Courier new' , , -12)
	oPrn:Say( nVIL+2299 , 1310 , Iif(M->UA_TPFRETE=='C','CIF','FOB'), oFont , , 0 , )

	//| Total Frete
	oFont := TFont():New( 'Courier new' , , -12)
	oPrn:Say( nVIL+2500+(-201) , 1480 , aTotais[T_TOTFRE] , oFont , , 0 , )

	//| Total Despesa
	oFont := TFont():New( 'Courier new' , , -12)
	oPrn:Say( nVIL+2299 , 2095 , aTotais[T_TOTDES] , oFont , , 0 , )

	//| Linha 3
	//| Condicao de Pagamento
	oFont := TFont():New( 'Courier new' , , -10);	oFont:Bold := .F.
	oPrn:Say( nVIL+2369 , 175 , PadL(M->UA_CONDPG+"-"+ Alltrim(Posicione("SE4",1,xFilial("SE4")+M->UA_CONDPG,"E4_DESCRI")),28," ") , oFont , , 0 , )

	//| Acrescimo Condicao de Pagamento
	//	oFont := TFont():New( 'Courier new' , , -10);	oFont:Bold := .F.
	//	oPrn:Say( nVIL+2369 , 817 , aTotais[T_ACRECP] , oFont , , 0 , )

	//| Numero Total de Pecas
	oFont := TFont():New( 'Courier new' , , -10);	oFont:Bold := .F.
	oPrn:Say( nVIL+2369 , 950, aTotais[T_TOTQTD] , oFont , , 0 , )

	//|Total Peso Liquido
	oFont := TFont():New( 'Courier new' , , -10);	oFont:Bold := .F.
	oPrn:Say( nVIL+2369 , 1490 , aTotais[T_PESOLI] , oFont , , 0 , )

	//|Total Peso Bruto
	oFont := TFont():New( 'Courier new' , , -10);	oFont:Bold := .F.
	oPrn:Say( nVIL+2369 , 2100 , aTotais[T_PESOBU] , oFont , , 0 , )

	Return()
	*******************************************************************************
Static Function PMsgens(oPrn)//| Imprime Mensagens
	*******************************************************************************

	//| Mensagem Marketing
	PMarketing(@oPrn)

	//| Impressao da Numeracao da Pagina
	oFont := TFont():New( 'Courier new' , , -14);	oFont:Bold := .T.
	oPrn:Say( nVIL+2029 , 2000 , "Pï¿½gina: " + cValToChar(nPagina) + "-" + cValToChar(nTotPag) , oFont , , 0 , )

	//| Mensagem Linha 01
	oFont := TFont():New( 'Courier new' , , -14);	oFont:Bold := .T.
	oPrn:Say( nVIL+2476 , 50 , aMens[M_LINHA1] , oFont , , 0 , )

	//| Mensagem Linha 02
	oFont := TFont():New( 'Courier new' , , -14);	oFont:Bold := .T.
	oPrn:Say( nVIL+2509 , 50 , aMens[M_LINHA2] , oFont , , 0 , )

	//| Mensagem Linha 03
	oFont := TFont():New( 'Courier new' , , -14);	oFont:Bold := .T.
	oPrn:Say( nVIL+2542 , 50 , aMens[M_LINHA3] , oFont , , 0 , )

	//| Mensagem Linha 04
	oFont := TFont():New( 'Courier new' , , -14);	oFont:Bold := .T.
	oPrn:Say( nVIL+2575 , 50 , aMens[M_LINHA4] , oFont , , 0 , )

	//| Mensagem Linha 05
	oFont := TFont():New( 'Courier new' , , -14);	oFont:Bold := .T.
	oPrn:Say( nVIL+2608 , 50 , aMens[M_LINHA5] , oFont , , 0 , )

	//| Mensagem Rodape
	oFont := TFont():New( 'Courier new' , , -13);	oFont:Bold := .T.;	oFont:Italic := .T.
	oPrn:Say( nVIL+2644 , 30 , aMens[M_RODAPE] , oFont , , 255 , )

	Return()
	*******************************************************************************
Static Function PMarketing(oPrn)//| Imprime a Mensagem de Marketing ...
	*******************************************************************************

	If lMsgMark //| Verifica se deve imprimir a Mensagem de Marketing

		oBrush := oBruCO
		oPrn:FillRect({ nFPG+nVIL+1379 , 100+45 , nFPG+nVIL+1459 , 2150+40 } , oBrush , '01' )

		oFont := TFont():New( 'Courier new' , , -17);	oFont:Bold := .T.
		oPrn:Say( nFPG+nVIL+1434 , 110+45 , cMsgMark , oFont , , 0 , )

	EndIf

	Return()
	*******************************************************************************
Static Function PLayout(oPrn) //|Imprime Layout Completo do Or amento
	*******************************************************************************
	Local nVIL := 350 //| nVIL Valor Inicial Posicao Linhas Apos Titulo

	//| *** Imagens e Box e Linhas Titulo do Orcamento***************

	If eVal(bPriPag)
		oPrn:SayBitmap( 265 , 30 , '\bmp\logos_orcamento_v7.jpg' , 2305 , 375 )	//oPrn:SayBitmap( 2635 , 30 , '\bmp\logos_orcamento_v7.jpg' , 2240 , 370 )
	EndIf
	//| Limites Pagina...

	oPrn:Box( 50 , 30 , 250 , 400 , '01' )
	oPrn:Line( 150 , 75 , 150 , 350 , 0 , '01' )
	oPrn:Box( 50 , 400 , 250 , 2250+nVIC , '01' )
	oPrn:SayBitmap( 80 , 920 , '\bmp\logo_titulo_orc_v2.jpg ' , 650 , 150 )//oPrn:SayBitmap( 80 , 620 , '\bmp\logo_titulo_orc_v2.jpg ' , 1377 , 152 )

	//| Numero Or amento
	oFont := TFont():New( 'Courier new' , , -20);	oFont:Bold := .T.
	oPrn:Say( 215 , 65 , 'N.:'+ IiF(lEhOrc, M->UA_NUM, SUA->UA_NUMSC5 ) , oFont , , 0 , )

	If LIMPLIPAG
		oPrn:Box( 50 , 30 , 3000 , 2340 , '00' )
	EndIf

	//| *** Box e Linhas Dados Vendedor e Cliente *******************
	If eVal(bPriPag)
		oBrush := oBruCI
		oPrn:FillRect({ nVIL+300 , 30	, nVIL+380 , 2250+nVIC } , oBrush , '01' )
		oPrn:Line( nVIL+300 , 30 , nVIL+300 , 2252+nVIC , 0 , '01' )
		oPrn:Line( nVIL+300 , 1192 , nVIL+650 , 1107+nVIC , 0 , '01' )
		oPrn:Line( nVIL+380 , 30 , nVIL+380 , 2252+nVIC , 0 , '01' )
		oPrn:Line( nVIL+650 , 30 , nVIL+650 , 2252+nVIC , 0 , '01' )
	EndIf

	//| **** Retangulo e Linhas Colunas Detalhes************************
	oBrush := oBruCI
	oPrn:FillRect({ nFPG+nVIL+700 , 30 , nFPG+nVIL+780 , 2250+nVIC } , oBrush , '01' )
	oPrn:Line( nFPG+nVIL+780 , 30 , nFPG+nVIL+780 , 2252+nVIC , 0 , '01' )
	oPrn:Line( nFPG+nVIL+788 , 30 , nFPG+nVIL+788 , 2252+nVIC , 0 , '01' )

	//| ******************** Linhas Zebrado dos itens ****************
	oBrush := oBruCC

	nEspacoEL := 0 //| Variavel auxiliar para soma dos espacos entre linhas zebradas ..
	nZebras := ( If(eVal(bPriPag), FNIPPAG, FNISPAG ) / 2 ) + 1 //| Apartir da primeira pagina e alterado a quantidade de itens que cabem na pagina
	For nZebItens := 1 To nZebras

		nEspacoEL := 100 * nZebItens
		oPrn:FillRect({ nFPG+nVIL+730+nEspacoEL, 30 , nFPG+nVIL+770+nEspacoEL , 2245+nVIC } , oBrush , '01' )
	Next

	/*
	oPrn:FillRect({ nVIL+ 930, 30 , nVIL+ 970, 2245+nVIC } , oBrush , '01' )
	oPrn:FillRect({ nVIL+1030, 30 , nVIL+1070, 2245+nVIC } , oBrush , '01' )
	oPrn:FillRect({ nVIL+1130, 30 , nVIL+1170, 2245+nVIC } , oBrush , '01' )
	oPrn:FillRect({ nVIL+1230, 30 , nVIL+1270, 2245+nVIC } , oBrush , '01' )
	oPrn:FillRect({ nVIL+1330, 30 , nVIL+1370, 2245+nVIC } , oBrush , '01' )
	oPrn:FillRect({ nVIL+1430, 30 , nVIL+1470, 2245+nVIC } , oBrush , '01' )
	oPrn:FillRect({ nVIL+1530, 30 , nVIL+1570, 2245+nVIC } , oBrush , '01' )
	oPrn:FillRect({ nVIL+1630, 30 , nVIL+1670, 2245+nVIC } , oBrush , '01' )
	oPrn:FillRect({ nVIL+1730, 30 , nVIL+1770, 2245+nVIC } , oBrush , '01' )
	oPrn:FillRect({ nVIL+1830, 30 , nVIL+1870, 2245+nVIC } , oBrush , '01' )
	oPrn:FillRect({ nVIL+1930, 30 , nVIL+1970, 2245+nVIC } , oBrush , '01' )
	*/

	//| ************** Linhas Verticais que Dividem os Detalhes dos Itens *************************
	oPrn:Line( nFPG+nVIL+740 , 150+nVIC , nVIL+1999 , 150+nVIC , 0 , '-2' )
	oPrn:Line( nFPG+nVIL+740 , 660+nVIC , nVIL+1999 , 660+nVIC , 0 , '-2' )
	oPrn:Line( nFPG+nVIL+740 , 710+nVIC , nVIL+1999 , 710+nVIC , 0 , '-2' )
	oPrn:Line( nFPG+nVIL+740 , 920+nVIC , nVIL+1999 , 920+nVIC , 0 , '-2' )
	oPrn:Line( nFPG+nVIL+740 , 1140+nVIC , nVIL+1999 , 1140+nVIC , 0 , '-2' )
	oPrn:Line( nFPG+nVIL+740 , 1233+nVIC , nVIL+1999 , 1233+nVIC , 0 , '-2' )
	oPrn:Line( nFPG+nVIL+740 , 1455+nVIC , nVIL+1999 , 1455+nVIC , 0 , '-2' )
	oPrn:Line( nFPG+nVIL+740 , 1615+nVIC , nVIL+1999 , 1615+nVIC , 0 , '-2' )
	oPrn:Line( nFPG+nVIL+740 , 1840+nVIC , nVIL+1999 , 1840+nVIC , 0 , '-2' )
	oPrn:Line( nFPG+nVIL+740 , 2090+nVIC , nVIL+1999 , 2090+nVIC , 0 , '-2' )

	//| **************** Retangulo Totais ******************************
	oBrush := oBruCI
	oPrn:FillRect({ nVIL+2049 , 30 , nVIL+2399 , 2252+nVIC } , oBrush , '01' )
	oPrn:Line( nVIL+2049 , 30 , nVIL+2049 , 2252+nVIC , 0 , '01' )

	//| *************** Linhas Verticais Divisorias dos Totais Linha 1 e 2 ***********
	oPrn:Line( nVIL+2049 , 612 , nVIL+2249 , 612 , 0 , '01' )
	oPrn:Line( nVIL+2049 , 1168 , nVIL+2324 , 1168 , 0 , '01' )
	oPrn:Line( nVIL+2049 , 1725 , nVIL+2324 , 1725 , 0 , '01' )

	// Terceira Linha
	oPrn:Line( nVIL+2324 , 612 , nVIL+2399 , 612 , 0 , '01' )
	oPrn:Line( nVIL+2324 , 1168 , nVIL+2399 , 1168 , 0 , '01' )
	oPrn:Line( nVIL+2324 , 1725	, nVIL+2399 , 1725 , 0 , '01' )
	//oPrn:Line( nVIL+2324 , 1905 , nVIL+2399 , 1905 , 0 , '01' )

	//| **************** Linhas Horizontais Totais *************
	oPrn:Line( nVIL+2249 , 30 , nVIL+2249 , 2252+nVIC , 0 , '01' )
	oPrn:Line( nVIL+2324 , 30 , nVIL+2324 , 2252+nVIC , 0 , '01' )
	oPrn:Line( nVIL+2399 , 30 , nVIL+2399 , 2252+nVIC , 0 , '01' )

	//| ****************** Retangulo e Linhas Caixa Observacoes ***********
	//If eVal(bPriPag)
	oBrush := oBruLJ

	oPrn:FillRect({ nVIL+2419 , 30 , nVIL+2655 , 2252+nVIC }, oBrush , '01' ) //| Linha - 40
	oPrn:Line( nVIL+2414 , 30 , nVIL+2414 , 2252+nVIC , 0 , '01' )//| Linha - 40
	oPrn:Line(	nVIL+2620 , 30 , nVIL+2620 , 2252+nVIC , 0 , '01' )//| Linha - 40
	oPrn:Line(	nVIL+2650 , 30 , nVIL+2650 , 2252+nVIC , 0 , '01' )//| Linha - 40
	//EndIf

	//| *************************** Textos Titulo *********************************
	oFont := TFont():New( 'Courier new' , , -20);	oFont:Bold := .T.
	oPrn:Say( 115 , 70 , Iif( lEhOrc , 'ORÇAMENTO', ' PEDIDO ' ) , oFont , , 255 , )

	//| *************************** Textos Vendedor *********************************
	If eVal(bPriPag)
		oFont := TFont():New( 'Courier new' , , -10);	oFont:Bold := .T.
		oPrn:Say( nVIL+420 , 50 , 'VENDEDOR: ' , oFont , , 0 , )

		oFont := TFont():New( 'Courier new' , , -10);	oFont:Bold := .T.
		oPrn:Say( nVIL+495 , 50 , 'TELEFONE: ' , oFont , , 0 , )

		oFont := TFont():New( 'Courier new' , , -10);	oFont:Bold := .T.
		oPrn:Say( nVIL+570 , 50 , 'ENDEREï¿½O: ' , oFont , , 0 , )

		oFont := TFont():New( 'Courier new' , , -10);	oFont:Bold := .T.
		oPrn:Say( nVIL+420 , 600 , 'E-MAIL: ' , oFont , , 0 , )

		oFont := TFont():New( 'Courier new' , , -10);	oFont:Bold := .T.
		oPrn:Say( nVIL+495 , 600 , 'E-MAIL: ' , oFont , , 0 , )

		//| *************************** Textos Cliente *********************************

		oFont := TFont():New( 'Courier new' , , -10);	oFont:Bold := .T.
		oPrn:Say( nVIL+420 , 1180+(nVIC/2) , 'CONTATO: ' , oFont , , 0 , )

		oFont := TFont():New( 'Courier new' , , -10);	oFont:Bold := .T.
		oPrn:Say( nVIL+495 , 1180+(nVIC/2) , 'TELEFONE: ' , oFont , , 0 , )

		oFont := TFont():New( 'Courier new' , , -10);	oFont:Bold := .T.
		oPrn:Say( nVIL+420 , 1730+(nVIC/2) , 'E-MAIL: ' , oFont , , 0 , )

		oFont := TFont():New( 'Courier new' , , -10);	oFont:Bold := .T.
		oPrn:Say( nVIL+495 , 1730+(nVIC/2) , 'CARGO: ' , oFont , , 0 , )

		oFont := TFont():New( 'Courier new' , , -10);	oFont:Bold := .T.
		oPrn:Say( nVIL+570 , 1180+(nVIC/2) , 'ENDEREï¿½O: ' , oFont , , 0 , )

	EndIf

	//| *************************** Textos Titulo Itens *********************************
	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nFPG+nVIL+750 , -5+nVIC , 'Cï¿½digo' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -10);	oFont:Italic := .T.
	oPrn:Say( nFPG+nVIL+770 , 10+nVIC , 'Item' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nFPG+nVIL+750 , 325+nVIC , 'Descriï¿½ï¿½o' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -10);	oFont:Italic := .T.
	oPrn:Say( nFPG+nVIL+770 , 370+nVIC , 'NCM' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nFPG+nVIL+750 , 668+nVIC , 'UM' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nFPG+nVIL+750 , 730+nVIC , 'Quantidade' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nFPG+nVIL+730 , 985+nVIC , 'Valor' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nFPG+nVIL+770 , 970+nVIC , 'Unitï¿½rio' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nFPG+nVIL+730 , 1155+nVIC , 'ICMS' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nFPG+nVIL+770 , 1155+nVIC , 'Aliq' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nFPG+nVIL+730 , 1325+nVIC , 'IPI' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nFPG+nVIL+770 , 1255+nVIC , 'Aliq Unit' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nFPG+nVIL+730 , 1515+nVIC , 'ST' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nFPG+nVIL+770 , 1470+nVIC , 'Unitï¿½rio' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nFPG+nVIL+730 , 1642+nVIC , 'Vlr+IPI+ST' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nFPG+nVIL+770 , 1662+nVIC , 'Unitï¿½rio' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nFPG+nVIL+730 , 1880+nVIC , 'Vlr+IPI+ST' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nFPG+nVIL+770 , 1935+nVIC , 'Total' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nFPG+nVIL+730 , 2105+nVIC , 'Previsï¿½o' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nFPG+nVIL+770 , 2110+nVIC , 'Entrega' , oFont , , 0 , )




	//| *************************** Textos Titulo Totais *********************************
	oFont := TFont():New( 'Courier new' , , -18);	oFont:Bold := .T.
	oPrn:Say( nVIL+2099 , 080 , 'Valor Mercadoria' , oFont , , 0 , );

	oFont := TFont():New( 'Courier new' , , -18); oFont:Bold := .T.
	oPrn:Say( nVIL+2099, 760 , 'Total IPI' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -18); oFont:Bold := .T.
	oPrn:Say( nVIL+2099 , 1330 , 'Total ST' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -18);	oFont:Bold := .T.
	oPrn:Say( nVIL+2099 , 1850 , 'Valor Total' , oFont , , 0 , )

	//| *************************** Textos Titulos Transporte, Frete e peso ********************
	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nVIL+2299 , 50 , 'Transportador:' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nVIL+2299 , 1190 , 'Frete:' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nVIL+2299 , 1740 , 'Despesa:' , oFont , , 0 , )

	//| *************************** Textos Titulos Outros *********************************
	oFont := TFont():New( 'Courier new' , , -12); oFont:Bold := .T.
	oPrn:Say( nVIL+2369 , 50 , 'C.Pgto:' , oFont , , 0 , )

	//oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	//oPrn:Say( nVIL+2369 , 630 , 'Acresc. C.Pag: ' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nVIL+2369 , 630 , 'N de Peï¿½as:' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nVIL+2369 , 1190 , 'Peso Lï¿½quido:' , oFont , , 0 , )

	oFont := TFont():New( 'Courier new' , , -12);	oFont:Bold := .T.
	oPrn:Say( nVIL+2369 , 1740 , 'Peso Bruto:' , oFont , , 0 , )

	//| *************************** Textos Titulo Observacoes *********************************
	//If eVal(bPriPag)
	oFont := TFont():New( 'Courier new' , , -14);	oFont:Italic := .T.
	oPrn:Say( nVIL+2442 , 50 , 'OBSERVAï¿½ï¿½ES:' , oFont , , 0 , )
	//EndIf

	Return()
	*******************************************************************************
Static Function TelaEmail()//| Apresenta Tela com Email
	*******************************************************************************
	Local cDe := ""
	Local cPara := ""
	Local cCopia := ""

	//| Posiciona no Usuario
	PswOrder(2);PswSeek(CUSERNAME,.T.)

	cDe	:= Alltrim( SA3->(PswRet()[1][14]) ) + Space(100)
	cPara	:= Alltrim(aCliente[C_MAILCEM]) + Space(50)
	cCopia := vCopia(cCopia)
	cAssunto	:= Iif(lEhOrc , 'Orçamento de Venda Imdepa' , 'Pedido de Venda Imdepa' )
	cAnexo := Alltrim( oPrn:cPathpdf ) + Substr(Alltrim(oPrn:cFileName),1,Len(Alltrim(oPrn:cFileName))-3)+"pdf"

	cArqName := Substr(Alltrim(oPrn:cFileName),1,Len(Alltrim(oPrn:cFileName))-4)

	//| _cFrom,_cTo ,_cBcc ,_cSubject,_cBody,_cAttach,lTela
	U_EnvMyMail( cDe , Lower(cPara) , lower(cCopia) , cAssunto , 'Segue anexo '+ cAssunto , cAnexo , .T.)


	DeletaFile() // Apaga os arquivos anexos... para não ficar ocupando espaco desnecessario no cliente e server


	Return(cAnexo)
	*******************************************************************************
Static Function vCopia(cCopia) //| Verifica Quem recebe Copia do email contendo Orcamento....
	*******************************************************************************
	Local lCopMailVendInt := IIf(SU7->U7_RCOPORC == '1' ,.T. ,.F. )

	//Envia C pia do e-mail para o Vendedor Interno
	If lCopMailVendInt
		If !Empty(cCopia)
			cCopia += ";"
		EndIf
		cCopia	+= Alltrim( aVendedor[V_MAILVE] ) //+ Space(50)
	Endif

	//| Envia C pia do e-mail para o Chefe de Vendas
	If !Empty(aVendedor[V_MAILCH])
		If !Empty(cCopia)
			cCopia += ";"
		EndIf
		cCopia	+= Alltrim( aVendedor[V_MAILCH] ) //+ Space(50)
	Endif

	//| Envia C pia do e-mail para o Coordenador de Vendas
	If !Empty(aVendedor[V_MAILCO])
		If !Empty(cCopia)
			cCopia += ";"
		EndIf
		cCopia	+= Alltrim( aVendedor[V_MAILCO]) //+ Space(50)
	Endif

	//| Envia C pia do e-mail para o Coordenador de Vendas
	If !Empty(aVendedor[V_MAILRE])
		If !Empty(cCopia)
			cCopia += ";"
		EndIf
		cCopia	+= Alltrim( aVendedor[V_MAILRE]) //+ Space(50)
	Endif

	Return(cCopia)
	*******************************************************************************
Static Function RetPosArr(aHeader, cCampo)// Obtem a posicao dos Campos atrav s do aheader
	*******************************************************************************
	Local nPos := 0

	For nP := 1 To Len(aHeader)
		If Alltrim(aHeader[nP][2]) == Alltrim(cCampo)

			nPos := nP
			exit

		EndIf
	Next

	Return nPos
	*******************************************************************************
Static Function CNV(cVar)// Converte um String Formatado Ex.: 9.999.999,99 em Numerico
	*******************************************************************************
	Local cAux := cVar

	cAux := StrTran( cAux, ".", "")
	cAux := StrTran( cAux, ",", ".")

	Return( Val(cAux) )
	*******************************************************************************
Static Function LenSD(aArray)// Verifica o Tamanho do Acols sem os Deletados...
	*******************************************************************************
	Local nCount := 0

	For nP := 1 To Len(aArray)

		If !aArray[nP][A_DELETE]
			nCount += 1
		EndIf
	Next

	Return(nCount)
	*******************************************************************************
Static Function FAddTES(cTes, lRet)//| Adiciona as TES ao Array de Controle de TES para Mensagens Posteriores...e Retorna se a TES ja estava cadastrada no
	*******************************************************************************
	Local lAchou := .T.

	Default lRet := .F.

	If Ascan(aTES, cTes ) == 0
		lAchou := .F.
		If !lRet
			Aadd(aTES, cTes)
		EndIf
	EndIf

	If lRet
		Return(lAchou)
	EndIf

	Return()

	*******************************************************************************
Static Function FNewDescri(cCodPro, cDescriAtu) //| Retorna a Descri o Especifica de um Produto
	*******************************************************************************
	Local cNewDescri := cDescriAtu

	DbSelectArea( "ZAB" )
	DbSetOrder( 2 ) // FILIAL + PROD. SIMILAR

	If ZAB->( DbSeek( xFilial( "ZAB" ) + cCodPro ) )
		If !Empty(ZAB->ZAB_DESIMI)
			cNewDescri := PadR( Substr(ZAB->ZAB_DESIMI,1,30),50, " " )

		Else
			cNewDescri := cDescriAtu

		EndIf
	Endif

Return cNewDescri

*************************************************************************************
Static Function FRefGates(cCodPro ) //| Verifica se a correia possui Referencia Gates
*************************************************************************************
	Local cRefGates:=' '
	Local cRefAux  :=' '
	Local cRefAux2 :='GATES:'
	Local lTemRefGates:=.F.



	DbSelectArea( "SZH" )
	DbSetOrder( 1 ) // FILIAL + PROD. SIMILAR


	DbSelectArea( "SB1" )
	DbSetOrder( 1 ) // FILIAL + PROD
	//Verifica se o produto ï¿½ do grupo de Correias ou se Possui regra para quebra da Marca
    If DbSeek(xFilial('SB1')+cCodPro, .F.)

        //Regra para Quebra da Marca
         If SB1->B1_SGRB1 $ '220300/220400'
           Return(SB1->B1_MARCA)
         Endif



        If SB1->B1_GRUPO<>'0022'
          Return(' ')
        EndIf


		 DbSelectArea( "SZH" )
		If DbSeek(xFilial('SZH')+cCodPro, .F.)
		    //cRefAux  :='GATES:'
			Do While !Eof() .And. SZH->ZH_PROD == cCodPro

			  DbSelectArea( "SB1" )

			  If DbSeek(xFilial('SB1')+SZH->ZH_EQUI, .F.)
			     If Alltrim(SB1->B1_MARCA)=='GATES'

			        If !lTemRefGates
			        cRefGates:='GATES:'+Alltrim(SB1->B1_REFER)+'-'
			        lTemRefGates:=.T.
			        Else
			         //Verifica se jï¿½ nï¿½o foi incluso esta Referencia,pois ela pode se repetir
			         If !Alltrim(SB1->B1_REFER)$ cRefGates
			          cRefGates+=Alltrim(SB1->B1_REFER)+'-'
			         Endif
			        Endif
			     Endif
			  EndIf


           	 	SZH->(DbSkip())

           	 EndDo
		EndIf
    Endif

  If !Empty(cRefGates)
    cRefGates:=Left(cRefGates,Len(cRefGates)-1)
  Endif
Return(cRefGates)

*************************************************************************************
Static Function DeletaFile()//| Apaga os arquivos pdf e rel criados, no cliente e servidor ...
*************************************************************************************
	Local aFilesDir := {} // O array receberá os nomes dos arquivos e do diretório
	Local aSizesDir := {} // O array receberá os tamanhos dos arquivos e do diretorio

	//| Carrega todos os arquivos que deve ser exluidos no cliente...
	ADir(cLocalPath+cArqName+".*" , aFilesDir, aSizesDir )

	For nF := 1 To Len(aFilesDir)
		//MsgStop("Local:" + cLocalPath+aFilesDir[nF]  )
		// Exclui local...
		If FErase(cLocalPath+aFilesDir[nF]) == -1
			//MsgStop('Falha na delecao do Arquivo')
		Else
			//MsgStop('Arquivo deletado com sucesso.')
		Endif
	Next

	//| Carrega todos os arquivos que deve ser exluidos no servidor...
	ADir(cPathInServer+cArqName+".*" , aFilesDir, aSizesDir)

	For nF := 1 To Len(aFilesDir)
		MsgStop("Server:"+cPathInServer+aFilesDir[nF]  )
		// Exclui local...
		If FErase(cPathInServer+aFilesDir[nF]) == -1
			//MsgStop('Falha na delecao do Arquivo')
		Else
			//MsgStop('Arquivo deletado com sucesso.')
		Endif
	Next


Return()