#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMBRWVIEW()

@sample CRMBRWVIEW
@param cRotina , Caracter, Contém o nome da Rotina que chama a view
@param cAliasView , Caracter, Contém o nome da Tabela utilizada na view
@return oTableAtt, Objeto, Contém os dados da nova View

@author
@since 09/08/2016
@version 12.1.7
/*/
//------------------------------------------------------------------------------
*******************************************************************************
User Function CRMBRWVIEW()
*******************************************************************************
	Local oTableAtt := Nil
	Local oDSViewA := Nil
	Local oDSViewB := Nil
	Local aParam := {}

	If !Empty ( PARAMIXB )
		aParam := PARAMIXB
	EndIf

	If !Empty ( aParam[1] ) .And. !Empty( aParam[2] )

		oTableAtt := FWTableAtt():New()
		oTableAtt:SetAlias(aParam[2])

		Do Case
			Case aParam[1] == "FATA300" .And. aParam[2] == "AD1" //Oportunidades

			//VIEW TESTE "A"
			oDSViewA := FWDSView():New()
			oDSViewA:SetName("Visão CRM AAA") // "Visão CRM AAA"
			oDSViewA:SetID("NewViewA")
			oDSViewA:SetOrder(1) // AD1_FILIAL+AD1_NROPOR
			oDSViewA:SetCollumns({ "AD1_NROPOR","AD1_REVISA","AD1_DESCRI","AD1_VEND","AD1_NOMVEN","AD1_VERBA","AD1_PROSPE",;
			"AD1_PROSPE","AD1_LOJPRO","AD1_CODCLI","AD1_LOJCLI","AD1_NOMCLI","AD1_RCINIC",;
			"AD1_RCFECH","AD1_DTINI","AD1_DTPFIM","AD1_FEELIN", "AD1_STATUS" })
			oDSViewA:SetPublic(.T.)
			oDSViewA:AddFilter("Oportunidades Abertas", "AD1_STATUS == '1'")
			oTableAtt:AddView(oDSViewA)

			//VIEW TESTE "B"
			oDSViewB := FWDSView():New()
			oDSViewB:SetName("Visão CRM BBB") // "View ESPECIAL CRM BBB"
			oDSViewB:SetID("NewViewB")
			oDSViewB:SetOrder(1) // AD1_FILIAL+AD1_NROPOR
			oDSViewB:SetCollumns({ "AD1_NROPOR","AD1_REVISA","AD1_DESCRI","AD1_DTINI","AD1_DTPFIM","AD1_STATUS",;
			"AD1_PROSPE","AD1_LOJPRO","AD1_CODCLI", "AD1_STAGE"})
			oDSViewB:SetPublic(.T.)
			oDSViewB:AddFilter("Oportunidades Ganhas", "AD1_STATUS == '9'")
			oTableAtt:AddView(oDSViewB)

			Case aParam[1] == "TMKA341" .And. aParam[2] == "ACH" //Suspects
			// VIEW TESTE "A"
			oDSViewA := FWDSView():New()
			oDSViewA:SetName("Todas Contas AAA") // "Todas Contas AAA"
			oDSViewA:SetID("AllACC")
			oDSViewA:SetOrder(1) // ACH_FILIAL+ACH_CODIGO+ACH_LOJA
			oDSViewA:SetCollumns({"ACH_CODIGO","ACH_LOJA","ACH_RAZAO","ACH_NFANT","ACH_DDD",;
			"ACH_END","ACH_MIDIA","ACH_TPCAMP","ACH_STATUS"})
			oDSViewA:SetPublic( .T. )
			oDSViewA:AddFilter("Todas Contas AAA", "!ACH_STATUS $ '5,6'") //"Todas Contas AAA"
			oTableAtt:AddView(oDSViewA)

		EndCase

		If Empty(oTableAtt:aViews) // Retorna Nil caso queria aceitar as visões padrão para os browses não tratados no CASE
			oTableAtt := Nil
		EndIf

	EndIf

Return ( oTableAtt )