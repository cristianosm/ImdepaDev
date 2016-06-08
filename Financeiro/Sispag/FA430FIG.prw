#Include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA430FIG  ºAutor  ³Cristiano Machado   º Data ³  05/15/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Permite modificar o CNPJ obtido da leitura do arquivo de   º±±
±±º          ³retorno DDA, de modo que a tabela SA2 seja posicionada      º±±
±±º          ³através do CNPJ modificado neste ponto de entrada.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*********************************************************************
User Function FA430FIG()
*********************************************************************
	Local cCnpj := ParamIxb[1]

	If Type("lDDa") == "U"
		Public lDDa := .T.
	Else
		lDDa := .T.
	EndIf

	cCnpj := U_VerDPDDA(cCnpj)  // Consulta

Return ( cCNPJ )
*********************************************************************
User Function FA430REN()
*********************************************************************

	If Type("lDDa") == "U"
		lDDa := .F.
	EndIf

	Default lDDa := ( .F. )

	If lDDa

	//| Verifica se existem CNPJS incorretos na tabela FIG - Conciliacao DDA....
		VerCnpj()

	//| Corrige os CNPJ incorretos encontrados...
		AtuCnpj()

		lDDa := ( .F. )

	EndIf

Return( )
*********************************************************************
Static Function VerCnpj()
*********************************************************************
	cSql := ""

	cSql += "select "
	cSql += "	fig_cnpj, fig_valor, fig_vencto, fig.r_e_c_n_o_ , "
	cSql += "	sa2.a2_cgc, sa2.a2_cod, sa2.a2_nreduz, sa2.a2_loja, "
	cSql += "	se2.e2_fornece, se2.e2_loja, e2_valor, e2_vencto, e2_vencrea "

	cSql += "from "
	cSql += "	sa2010 sa2, "
	cSql += " (	select fig_cnpj, fig_vencto, fig_valor,r_e_c_n_o_ from fiG010 "
	cSql += "     where fig_filial = '  ' and fig_concil = '2' "
	cSql += "     and   fig_vencto >= '"+DToS(dDataBase-365)+"' "
	cSql += "     and d_e_l_e_t_ = ' ' ) fig,  "
	cSql += "	se2010 se2 "

	cSql += "where substr(sa2.a2_cgc,1,8)  =   substr(fig.fig_cnpj,1,8) "
	cSql += "and   sa2.a2_cgc              <>  fig.fig_cnpj  "
	cSql += "and   sa2.a2_cod              =   se2.e2_fornece "
	cSql += "and   sa2.a2_loja             =   se2.e2_loja "

	cSql += "and   trunc(se2.e2_valor,0)   =   trunc(fig.fig_valor,0) "
	cSql += "and   fig.fig_vencto          =   se2.e2_vencto "
	cSql += "and   sa2.a2_msblql           in(' ','2') "
	cSql += "and   sa2.d_e_l_e_t_          =   ' ' "
	cSql += "and   se2.d_e_l_e_t_          =   ' ' "

	cSql += "order by fig.fig_cnpj, sa2.a2_cgc "

	U_ExecMySql(cSql,"AJU","Q",.F.)

Return( )
*********************************************************************
Static Function AtuCnpj()
*********************************************************************

	DbSelectArea("AJU");DbGotop()
	While !EOF()

		cSql := "Update fig010 set "
		cSql += " fig_cnpj 			= '"+AJU->A2_CGC+"' ,"
		cSql += " fig_fornec 		= '"+AJU->A2_COD+"' ,"
		cSql += " fig_loja 			= '"+AJU->A2_LOJA+"' ,"
		cSql += " fig_nomfor 		= '"+Substr(AJU->A2_NREDUZ,1,20)+"' "
		cSql += " where r_e_c_n_o_ 	= "+cValToChar(AJU->R_E_C_N_O_)+" "

		U_ExecMySql(cSql,"","E",.F.)

		DbSelectARea("AJU")
		DbSkip()

	EndDo

Return( )