#include "Totvs.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CalcNFImp ºAutor  ³CRISTIANO MACHADO   º Data ³  31/07/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula as Notas de Importacao Direta. Solucao palhativa   º±±
±±º          ³devido ao erro no padrao.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8 IMDEPA ROLAMENTOS                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

*******************************************************************************
User Function CalcNFImp(xHawb)// Calcula NF Importacao
*******************************************************************************
	Local   lSoTela	:= If(empty(xHawb),.T.,.F.)
	Private 	cHawb 		:= If(empty(xHawb),SW6->W6_HAWB,xHawb)
	Private	lMostra 	:= .F.
	Private lCalCust	:= SuperGetMv("IM_CALCIMP", .T., .T., "  ")
	Private lRegSICM	:= VerRegimeICMS() // Regime Especial de ICMS apenas para iTajai...

	Default  cHawb := SW6->W6_HAWB

//	Alert("Entrou CalcNFImp....lCalCust: " + cValToChar(lCalCust))

	If !lCalCust
		lSoTela := !lCalCust
		//Return(.F.)
	EndIf

	If Empty(cHawb)
		Return(.F.)
	EndIf

//| Testa ah Recursividade..
	If Type('lRecurEASY') != 'U'
		Return()
	Else
		If Type('lRecurEASY') == 'U'
			Private lRecurEASY := .T.
		Endif
	Endif
	//| Fim Recursividade...

	If !lSoTela
		//| Calcula SWN - Itens que compoem a Nota Fiscal de Importacao...
		Monta_SWN()
		//Alert("MontaSWN Entrou")

		//| Calcula SD1 - Itens da Nota Fiscal de Entrada...
		Monta_SD1()

		//| CalculaSF1 - Cabecalho da Nota Fiscal de Entrada...
		Ajusta_SF1()

		//| Calcula SW6 - Capa da Declaracao de Importacao...
		Ajusta_SW6()

	EndIf
	//| Monta Tela Com Comparacao de Impostos...
	AbreTela(cHawb)


Return(.T.)
*******************************************************************************
Static Function Monta_SWN()//| Calcula SWN - Itens que compoem a Nota Fiscal de Importacao...
*******************************************************************************

	Calc_SWN()

	DbSelectArea("SWN_AUX");DbGotop()
	While !EOF()

		Update_SWN()

		SWN_AUX->( DbSkip() )

	EndDo

Return()
*******************************************************************************
Static Function Calc_SWN()// Calcula os Valores Corretos dos Itens para Gerar NF-Importacao
*******************************************************************************
	Local cSql         := ""
	Local cYB_ICMS_UF  := "YB_ICMS_" + Alltrim(SM0->M0_ESTENT)
	Local nAliqICM 		:= ObtAliqICM(Alltrim(SM0->M0_ESTENT))



	cSql += "SELECT  SUBSTR(WN_HAWB	,1,17) 		AS WN_HAWB, "

	cSql += "			SUBSTR(WN_PO_NUM ,1,6)   	AS WN_PO_NUM, "

	cSql += "        SUBSTR(WN_TEC	,1,10) 		AS WN_TEC, "
	cSql += "        SUBSTR(WN_EX_NCM,1,3)			AS WN_EX_NCM, "
	cSql += "        SUBSTR(WN_ITEM	,1,4)			AS WN_ITEM, "
	cSql += "        SUBSTR(WN_PRODUTO,1,15)		AS WN_PRODUTO, "
	cSql += "        ROUND(WN_QUANT,3)				AS WN_QUANT, "
	cSql += "        ROUND(WN_PRECO,2)				AS WN_PRECO, "
	cSql += "        ROUND(WN_PRUNI,8)				AS WN_PRUNI, "
	cSql += "        ROUND(WN_VALOR,2)				AS WN_VALOR, "
	cSql += "        ROUND(WN_PESOL,6)				AS WN_PESOL, "
	cSql += "        ROUND(WN_RATEIO,8) 				AS WN_RATEIO, "
	cSql += "        ROUND(WN_DESPADU,2) 			AS WN_DESPADU, "
	cSql += "        ROUND(WN_SEGURO,2)			AS WN_SEGURO, "
	cSql += "        ROUND(WN_FRETE,2)				AS WN_FRETE, "
	cSql += "        ROUND(WN_CIF,2)				AS WN_CIF, "
	cSql += "        ROUND(WN_IITX,2)				AS WN_IITX, "
	cSql += "        ROUND(WN_IIVAL,2) 			AS WN_IIVAL, "
	cSql += "        ROUND(WN_VLDEVII,2)			AS WN_VLDEVII, "
	cSql += "        ROUND(WN_IPIBASE,2)			AS WN_IPIBASE, "
	cSql += "        ROUND(WN_IPITX,2)				AS WN_IPITX, "
	cSql += "        ROUND(WN_IPIVAL,2)			AS WN_IPIVAL, "
	cSql += "        ROUND(WN_VALIPI,2)			AS WN_VALIPI, "
	cSql += "        ROUND(WN_BASPIS,2)			AS WN_BASPIS, "
	cSql += "        ROUND(WN_PERPIS,2)			AS WN_PERPIS, "
	cSql += "        ROUND(WN_VLRPIS,2)			AS WN_VLRPIS, "
	cSql += "        ROUND(WN_BASCOF,2)			AS WN_BASCOF, "
	cSql += "        ROUND(WN_PERCOF,2)			AS WN_PERCOF, "
	cSql += "        ROUND(WN_VLRCOF,2)			AS WN_VLRCOF, "
	cSql += "        ROUND(WN_DESPICM,2)			AS WN_DESPICM, "
	cSql += "      	ROUND((WN_CIF + WN_IIVAL + WN_IPIVAL + WN_VLRPIS + WN_VLRCOF + WN_DESPICM)/(1-("+cc(nAliqICM)+"/100)),2)  				AS WN_BASEICM, "
	cSql += "        ROUND(WN_ICMS_A,2)																									AS WN_ICMS_A, "

	If lRegSICM // Regime Especial Itajai n‹o possui ICMS
		cSql += "      	0 	AS WN_VALICM, "
		cSql += "      	0	AS WN_VL_ICM "
	Else
		cSql += "      	ROUND(( WN_CIF + WN_IIVAL + WN_IPIVAL + WN_VLRPIS + WN_VLRCOF + WN_DESPICM)/(1-("+cc(nAliqICM)+"/100)) *("+cc(nAliqICM)+"/100),2) 	AS WN_VALICM, "
		cSql += "      	ROUND(( WN_CIF + WN_IIVAL + WN_IPIVAL + WN_VLRPIS + WN_VLRCOF + WN_DESPICM)/(1-("+cc(nAliqICM)+"/100)) *("+cc(nAliqICM)+"/100),2)		AS WN_VL_ICM "
	EndIf
	cSql += "FROM   "
	cSql += "    ( "
	cSql += "        SELECT    WN_HAWB, WN_PO_NUM, WN_TEC, WN_EX_NCM, WN_ITEM, WN_PRODUTO, WN_QUANT, WN_PRECO, "
	cSql += "                  (WN_CIF + ( WN_CIF * (WN_IITX / 100 ))) /  WN_QUANT                   AS  WN_PRUNI, "
	cSql += "                  WN_CIF + ( WN_CIF * (WN_IITX / 100 ))                                 AS  WN_VALOR, "
	cSql += "                  WN_PESOL, WN_RATEIO, WN_DESPADU, WN_SEGURO, WN_FRETE, WN_CIF, WN_IITX, "
	cSql += "                  WN_CIF * (WN_IITX / 100 )                                             AS  WN_IIVAL, "
	cSql += "                  WN_CIF * (WN_IITX / 100 )                                             AS  WN_VLDEVII, "
	cSql += "                  WN_CIF + ( WN_CIF * (WN_IITX / 100 ))                                 AS  WN_IPIBASE,  "
	cSql += "                                                                                            WN_IPITX , "
	cSql += "                ( WN_CIF + ( WN_CIF * (WN_IITX / 100 )) ) * (WN_IPITX / 100 )           AS  WN_IPIVAL, "
	cSql += "                ( WN_CIF + ( WN_CIF * (WN_IITX / 100 )) ) * (WN_IPITX / 100 )           AS  WN_VALIPI, "
	cSql += "                  WN_CIF                                                                AS  WN_BASPIS,  "
	cSql += "                  WN_PERPIS , "
	cSql += "                ( WN_CIF * (WN_PERPIS / 100 ))                                          AS  WN_VLRPIS, "
	cSql += "                  WN_CIF                                                                AS  WN_BASCOF,  "
	cSql += "                  WN_PERCOF, "
	cSql += "                ( WN_CIF * (WN_PERCOF / 100 ))                                          AS WN_VLRCOF, "
	cSql += "                  WN_DESPICM, "
	cSql += "                  WN_BASEICM,  "
	cSql += "                  WN_ICMS_A, "
	cSql += "                  WN_VALICM, "
	cSql += "                  WN_VL_ICM "

	cSql += "        FROM "
	cSql += "            (  "
	cSql += "                SELECT   SW7.WN_HAWB                                       AS WN_HAWB, "
	cSql += "                         SW7.WN_PO_NUM                                     AS WN_PO_NUM, "
	cSql += "                         SW7.WN_TEC                                        AS WN_TEC, "
	cSql += "                         SW7.WN_EX_NCM                                     AS WN_EX_NCM, "
	cSql += "                         SW7.WN_ITEM                                       AS WN_ITEM, "
	cSql += "                         SW7.WN_PRODUTO                                    AS WN_PRODUTO, "
	cSql += "                         SW7.WN_QUANT                                      AS WN_QUANT, "
	cSql += "                         SW7.WN_PRECO                                      AS WN_PRECO, "
	cSql += "                         0                                                 AS WN_PRUNI, "
	cSql += "                         0                                                 AS WN_VALOR, "
	cSql += "                         SW7.WN_PESOL                                      AS WN_PESOL, "
	cSql += "                         SW8.WN_RATEIO                                     AS WN_RATEIO, "
	cSql += "                         SW7.WN_RATEIO_PESO * SWD.T_WN_DESPADU             AS WN_DESPADU, "
	cSql += "                         SW7.T_WN_SEGURO * SW8.WN_RATEIO                   AS WN_SEGURO, "
	cSql += "                         T_WN_FRETE * WN_RATEIO_PESO * WN_TX_FOB           AS WN_FRETE, "
	cSql += "                         WN_TOTAL_ITEM + (T_WN_FRETE * WN_RATEIO_PESO * WN_TX_FOB) + (SW7.WN_RATEIO_PESO * SWD.T_WN_DESPADU) + (SW7.T_WN_SEGURO * SW8.WN_RATEIO) AS WN_CIF, "
	cSql += "                         SW7.WN_IITX                                       AS WN_IITX, "
	cSql += "                         0                                                 AS WN_IIVAL, "
	cSql += "                         0                                                 AS WN_VLDEVII, "
	cSql += "                         0                                                 AS WN_IPIBASE, "
	cSql += "                         SW7.WN_IPITX                                      AS WN_IPITX, "
	cSql += "                         0                                                 AS WN_IPIVAL, "
	cSql += "                         0                                                 AS WN_VALIPI, "
	cSql += "                         0                                                 AS WN_BASPIS,  "
	cSql += "                         SW7.WN_PERPIS                                     AS WN_PERPIS, "
	cSql += "                         0                                                 AS WN_VLRPIS, "
	cSql += "                         0                                                 AS WN_BASCOF,  "
	cSql += "                         SW7.WN_PERCOF                                     AS WN_PERCOF, "
	cSql += "                         0                                                 AS WN_VLRCOF, "
	cSql += "                         T_WN_DESPICM * SW8.WN_RATEIO                      AS WN_DESPICM, "
	cSql += "                         0                                                 AS WN_BASEICM,  "
	cSql += "                         SW7.WN_ICMS_A                                     AS WN_ICMS_A, "
	cSql += "                         0                                                 AS WN_VALICM, "
	cSql += "                         0                                                 AS WN_VL_ICM   "

	cSql += "                FROM  "
	cSql += "                    (    "
	cSql += "                        SELECT   W7_HAWB                      AS  WN_HAWB, "
	cSql += "                                 W7_PO_NUM                    AS  WN_PO_NUM, "
	cSql += "                                 W7_NCM                       AS  WN_TEC, "
	cSql += "                                 W7_EX_NCM                    AS  WN_EX_NCM, "
	cSql += "                                 W7_POSICAO                   AS  WN_ITEM, "
	cSql += "                                 W7_COD_I                     AS  WN_PRODUTO, "
	cSql += "                                 W7_QTDE                      AS  WN_QUANT, "
	cSql += "                                 W7_PRECO                     AS  WN_PRECO, "
	cSql += "                                 W7_PESO * W7_QTDE            AS  WN_PESOL,  "
	cSql += "                                 YD_PER_II                    AS  WN_IITX, "
	cSql += "                                 YD_PER_IPI                   AS  WN_IPITX, "
	cSql += "                                 YD_PER_PIS                   AS  WN_PERPIS, "
	cSql += "                                 YD_PER_COF                   AS  WN_PERCOF, "
	cSql += "                                 YD_ICMS_RE                   AS  WN_ICMS_A, "
	cSql += "                                 W6_PESOL                     AS  T_WN_PESOL, "
	cSql += "                                 W6_VLSEGMN                   AS  T_WN_SEGURO, "
	cSql += "                                 W6_VLFRECC                   AS  T_WN_FRETE, "
	cSql += "                                 W7_PESO * W7_QTDE / W6_PESOL AS WN_RATEIO_PESO  "

	cSql += "                        FROM SW7010 INNER JOIN SYD010 "
	cSql += "                          ON W7_NCM     = YD_TEC "
	cSql += "                         AND W7_EX_NCM = YD_EX_NCM "
	cSql += "                                    INNER JOIN SW6010 "
	cSql += "                          ON W7_FILIAL = W6_FILIAL "
	cSql += "                        AND W7_HAWB = W6_HAWB "

	cSql += "                       WHERE W7_CC = '"+cFilAnt+"' "
	cSql += "                         AND W7_HAWB = '"+cHawb+"' "

	cSql += "                         AND SW7010.D_E_L_E_T_ = ' ' "
	cSql += "                         AND SYD010.D_E_L_E_T_ = ' ' "
	cSql += "                         AND SW6010.D_E_L_E_T_ = ' ' "
	cSql += "                    ) SW7, "
	cSql += "                    (  "
	cSql += "                        SELECT   W8_HAWB                               AS  WN_HAWB, "
	cSql += "                                 W8_PO_NUM                             AS WN_PO_NUM, "
	cSql += "                                 W8_POSICAO                            AS  WN_ITEM, "
	cSql += "                                 W8_COD_I                              AS  WN_PRODUTO, "
	cSql += "                                 W8_QTDE                               AS  WN_QUANT, "
	cSql += "                                 W8_PRECO                              AS  WN_PRECO, "
	cSql += "                                 W8_PRECO_R                            AS  WN_TOTAL_ITEM, "
	cSql += "                                 W9_FOB_TOT * W9_TX_FOB                AS  WN_TOTAL_FOB, "
	cSql += "                                 W8_FRETEIN * W9_TX_FOB                AS  WN_FRETE, "
	cSql += "                                 W9_TX_FOB                             AS  WN_TX_FOB, "
	cSql += "                                 W8_PRECO_R / (W9_FOB_TOT * W9_TX_FOB) AS  WN_RATEIO "


	cSql += "                        FROM SW8010 INNER JOIN SW9010 "
	cSql += "                        ON     W9_FILIAL = W8_FILIAL "
	cSql += "                        AND   W9_HAWB   = W8_HAWB "
	cSql += "                        WHERE W8_FILIAL = '  ' "
	cSql += "                        AND W8_HAWB = '"+cHawb+"' "
	cSql += "                        AND SW8010.D_E_L_E_T_ = ' ' "
	cSql += "                        AND SW9010.D_E_L_E_T_ = ' ' "
	cSql += "                    ) SW8, "
	cSql += "                    ( "
	cSql += "                        SELECT WN_HAWB, SUM(WN_DESPICM) T_WN_DESPICM, SUM(WN_DESPADU) T_WN_DESPADU "
	cSql += "                        FROM    "
	cSql += "                               ( "
	cSql += "                                   SELECT   WD_HAWB   AS  WN_HAWB, "
	cSql += "                                            CASE  "
	cSql += "                                              WHEN YB_BASEICM = '1' AND  "+cYB_ICMS_UF+" = '1' THEN WD_VALOR_R "
	cSql += "                                              ELSE 0 "
	cSql += "                                            END WN_DESPICM, "
	cSql += "                                            CASE  "
	cSql += "                                              WHEN YB_BASEICM = '1' AND  "+cYB_ICMS_UF+" != '1' THEN WD_VALOR_R  "
	cSql += "                                              WHEN YB_BASEICM != '1'THEN WD_VALOR_R   "
	cSql += "                                              ELSE 0 "
	cSql += "                                            END WN_DESPADU "

	cSql += "                                   FROM SWD010 INNER JOIN SYB010 "
	cSql += "                                   ON  WD_DESPESA = YB_DESP "
	cSql += "                                   WHERE WD_HAWB = '"+cHawb+"' "
	cSql += "                                   AND SUBSTR(YB_DESP,1,1) = '4'  "
	cSql += "                                   AND YB_BASECUS  != '2' "
	cSql += "                                   AND SWD010.D_E_L_E_T_ = ' ' "
	cSql += "                                   AND SYB010.D_E_L_E_T_ = ' ' "
	cSql += "                                ) "

	cSql += "                        GROUP BY WN_HAWB "
	cSql += "                        ) SWD "

	cSql += "                WHERE SW7.WN_HAWB = SW8.WN_HAWB "
	cSql += "                AND   SW7.WN_PRODUTO = SW8.WN_PRODUTO "
	cSql += "                AND SW7.WN_PO_NUM  = SW8.WN_PO_NUM "
	cSql += "                AND   SW7.WN_ITEM = SW8.WN_ITEM "
	cSql += "                AND   SW7.WN_HAWB = SWD.WN_HAWB "
	cSql += "            ) "
	cSql += "    ) "

	U_ExecMySql(cSql,"SWN_AUX","Q",.F.)

Return()
*******************************************************************************
Static Function Update_SWN()//| Atualiza o SWN pelos valores Obtidos...
*******************************************************************************

	Local cSQl := ""


	cSQl += "UPDATE SWN010 "
	cSQl += "SET "
	cSQl += "WN_TEC			= '"+cc(SWN_AUX->WN_TEC		)+"', "
	cSQl += "WN_EX_NCM		= '"+cc(SWN_AUX->WN_EX_NCM	)+"', "
	cSQl += "WN_QUANT   	=  "+cc(SWN_AUX->WN_QUANT	)+",  "
	cSQl += "WN_PRECO   	=  "+cc(SWN_AUX->WN_PRECO	)+",  "
	cSQl += "WN_PRUNI   	=  "+cc(SWN_AUX->WN_PRUNI	)+",  "
	cSQl += "WN_VALOR   	=  "+cc(SWN_AUX->WN_VALOR	)+",  "
	cSQl += "WN_PESOL  		=  "+cc(SWN_AUX->WN_PESOL	)+",  "
	cSQl += "WN_RATEIO 		=  "+cc(SWN_AUX->WN_RATEIO	)+",  "
	cSQl += "WN_DESPADU  	=  "+cc(SWN_AUX->WN_DESPADU	)+",  "
	cSQl += "WN_SEGURO   	=  "+cc(SWN_AUX->WN_SEGURO	)+",  "
	cSQl += "WN_FRETE     	=  "+cc(SWN_AUX->WN_FRETE	)+",  "
	cSQl += "WN_CIF    		=  "+cc(SWN_AUX->WN_CIF		)+",  "
	cSQl += "WN_IITX   		=  "+cc(SWN_AUX->WN_IITX		)+",  "
	cSQl += "WN_IIVAL 		=  "+cc(SWN_AUX->WN_IIVAL	)+",  "
	cSQl += "WN_VLDEVII 		=  "+cc(SWN_AUX->WN_VLDEVII	)+",  "
	cSQl += "WN_IPIBASE   	=  "+cc(SWN_AUX->WN_IPIBASE )+",  "
	cSQl += "WN_IPITX  		=  "+cc(SWN_AUX->WN_IPITX  	)+",  "
	cSQl += "WN_IPIVAL  		=  "+cc(SWN_AUX->WN_IPIVAL  )+",  "
	cSQl += "WN_VALIPI  		=  "+cc(SWN_AUX->WN_VALIPI  )+",  "
	cSQl += "WN_BASPIS  		=  "+cc(SWN_AUX->WN_BASPIS  )+",  "
	cSQl += "WN_PERPIS  		=  "+cc(SWN_AUX->WN_PERPIS  )+",  "
	cSQl += "WN_VLRPIS  		=  "+cc(SWN_AUX->WN_VLRPIS  )+",  "
	cSQl += "WN_BASCOF  		=  "+cc(SWN_AUX->WN_BASCOF  )+",  "
	cSQl += "WN_PERCOF  		=  "+cc(SWN_AUX->WN_PERCOF  )+",  "
	cSQl += "WN_VLRCOF 		=  "+cc(SWN_AUX->WN_VLRCOF  )+",  "
	cSQl += "WN_DESPICM 		=  "+cc(SWN_AUX->WN_DESPICM )+",  "
	cSQl += "WN_BASEICM  	=  "+cc(SWN_AUX->WN_BASEICM )+",  "
	cSQl += "WN_ICMS_A  		=  "+cc(SWN_AUX->WN_ICMS_A  )+",  "
	cSQl += "WN_VALICM  		=  "+cc(SWN_AUX->WN_VALICM  )+",  "
	cSQl += "WN_VL_ICM		=  "+cc(SWN_AUX->WN_VL_ICM  )+"  "

	cSQl += "WHERE WN_HAWB 		= '"+AllTrim(SWN_AUX->WN_HAWB)+"'  "
	cSQl += "AND   WN_PRODUTO 	= '"+AllTrim(SWN_AUX->WN_PRODUTO)+"'  "
	cSQl += "AND   WN_ITEM 		= '"+AllTrim(SWN_AUX->WN_ITEM)+"'  "
	cSql += "AND   WN_PO_NUM 	= '"+AllTrim(SWN_AUX->WN_PO_NUM)+"'  "
	cSQl += "AND   D_E_L_E_T_  	= '  ' "

	U_ExecMySql(cSql,"","E",.F.)

Return()
*******************************************************************************
Static Function Monta_SD1()// Monta Itens de Nf-Entrada...
*******************************************************************************

	Calc_SD1()

	DbSelectArea("SD1_AUX");DbGotop()
	While !EOF()

		Update_SD1()

		SD1_AUX->( DbSkip() )

	EndDo

Return()
*******************************************************************************
Static Function Calc_SD1()//| Obtem Valores para Gravacao nos itens da NF-Entrada
*******************************************************************************

	cSQl := ""

	cSQl += "SELECT W6_DI_NUM WN_DI_NUM, WN_PO_NUM, WN_CC,WN_HAWB,WN_ITEM,WN_PRODUTO,WN_PRUNI,WN_VALOR,WN_PESOL,WN_IIVAL,WN_IPIBASE, WN_IPITX ,WN_IPIVAL,WN_BASPIS, WN_PERPIS ,WN_VLRPIS,WN_BASCOF, WN_PERCOF ,WN_DESPICM,WN_BASEICM, WN_ICMS_A ,WN_VALICM "
	cSQl += "FROM SWN010 INNER JOIN SW6010 "
	cSQl += "ON WN_FILIAL = W6_FILIAL "
	cSQl += "AND WN_HAWB = W6_HAWB "
	cSQl += "WHERE WN_HAWB = '"+Alltrim(cHawb)+"' "
	cSQl += "AND SWN010.D_E_L_E_T_ = ' ' "
	cSQl += "AND sw6010.D_E_L_E_T_ = ' ' "

	U_ExecMySql(cSql,"SD1_AUX","Q",.F.)

Return()
*******************************************************************************
Static Function Update_SD1()//| Atualiza o Cabecalho da NF-entrada conforme os itens
*******************************************************************************

	cSQl := ""

	cSQl += "UPDATE SD1010 "
	cSQl += "SET "

	cSQl += "D1_VUNIT			= "+cc(SD1_AUX->WN_PRUNI)+", "
	cSQl += "D1_TOTAL			= "+cc(SD1_AUX->WN_VALOR)+", "
	cSQl += "D1_PESO			= "+cc(SD1_AUX->WN_PESOL)+", "
	cSQl += "D1_II			= "+cc(SD1_AUX->WN_IIVAL)+", "
	cSQl += "D1_BASEIPI		= "+cc(SD1_AUX->WN_IPIBASE)+", "
	cSQl += "D1_IPI			= "+cc(SD1_AUX->WN_IPITX)+", "
	cSQl += "D1_VALIPI		= "+cc(SD1_AUX->WN_IPIVAL)+", "
	cSQl += "D1_BASIMP6		= "+cc(SD1_AUX->WN_BASPIS)+", "
	cSQl += "D1_ALQIMP6		= "+cc(SD1_AUX->WN_PERPIS)+", "
	cSQl += "D1_VALIMP6		= "+cc(SD1_AUX->WN_VLRPIS)+", "
	cSQl += "D1_BASIMP5		= "+cc(SD1_AUX->WN_BASCOF)+", "
	cSQl += "D1_ALQIMP5		= "+cc(SD1_AUX->WN_PERCOF)+", "
	cSQl += "D1_DESPESA		= "+cc(SD1_AUX->WN_DESPICM)+", "
	cSQl += "D1_BASEICM		= "+cc(SD1_AUX->WN_BASEICM)+", "
	cSQl += "D1_PICM			= "+cc(SD1_AUX->WN_ICMS_A)+", "
	cSQl += "D1_VALICM		= "+cc(SD1_AUX->WN_VALICM)+", "
	cSQl += "D1_NUMDI			= '"+cc(SD1_AUX->WN_DI_NUM)+"' "

	cSQl += "WHERE D1_CONHEC		= '"+AllTrim(SD1_AUX->WN_HAWB)		+"'  "
	cSQl += "AND   D1_COD	 	= '"+AllTrim(SD1_AUX->WN_PRODUTO)	+"'  "
	cSQl += "AND   D1_ITEMPC 	= '"+AllTrim(SD1_AUX->WN_ITEM)		+"'  "

	cSQl += "AND   D1_PEDIDO		= '"+AllTrim(SD1_AUX->WN_PO_NUM)	+"'  "

	cSQl += "AND   D_E_L_E_T_   = '  ' "


	U_ExecMySql(cSql,"","E",.F.)

Return()
*******************************************************************************
Static Function Ajusta_SF1()//| Calcula SF1 - Cabecalho da Nota Fiscal de Entrada...
*******************************************************************************


	cSql := ""
	cSql += "UPDATE  "
	cSql += "  SF1010 "
	cSql += "SET  "
	cSql += "  F1_II      = ( SELECT SUM(D1_II)               FROM SD1010 WHERE D1_FILIAL = F1_FILIAL AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND SD1010.D_E_L_E_T_ = ' ' AND SF1010.D_E_L_E_T_ = ' ' ), "
	cSql += "  F1_ICMS    = ( SELECT SUM(D1_VALICM)           FROM SD1010 WHERE D1_FILIAL = F1_FILIAL AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND SD1010.D_E_L_E_T_ = ' ' AND SF1010.D_E_L_E_T_ = ' ' ), "
	cSql += "  F1_FOB_R   = ( SELECT SUM(WN_FOB_R)            FROM SWN010 WHERE WN_HAWB = F1_HAWB   AND SWN010.D_E_L_E_T_ = ' ' AND SF1010.D_E_L_E_T_ = ' ' ), "
	cSql += "  F1_CIF     = ( SELECT SUM(D1_TOTAL)-SUM(D1_II) FROM SD1010 WHERE D1_FILIAL = F1_FILIAL AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND SD1010.D_E_L_E_T_ = ' ' AND SF1010.D_E_L_E_T_ = ' ' ), "
	cSql += "  F1_IPI     = ( SELECT SUM(D1_VALIPI)           FROM SD1010 WHERE D1_FILIAL = F1_FILIAL AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND SD1010.D_E_L_E_T_ = ' ' AND SF1010.D_E_L_E_T_ = ' ' ), "
	cSql += "  F1_DESPESA = ( SELECT SUM(D1_DESPESA)          FROM SD1010 WHERE D1_FILIAL = F1_FILIAL AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND SD1010.D_E_L_E_T_ = ' ' AND SF1010.D_E_L_E_T_ = ' ' ) "

	cSql += "WHERE F1_HAWB  = '"+Alltrim(cHawb)+"' "
	cSql += "AND D_E_L_E_T_  = ' ' "

	U_ExecMySql(cSql,"","E",lMostra)

Return()
*******************************************************************************
Static Function Ajusta_SW6()//| Atualiza Valor Total da NF na Capa do Processo
*******************************************************************************

	cSql := ""

	cSql += "UPDATE "
	cSql += "  SW6010 "
	cSql += "SET  "
	cSql += "  W6_VL_NF = ( SELECT SUM(D1_BASEICM) FROM SD1010 WHERE D1_CONHEC = W6_HAWB AND D_E_L_E_T_ = ' ' ) "
	cSql += "WHERE W6_HAWB = '"+Alltrim(cHawb)+"' "
	cSql += "AND D_E_L_E_T_ = ' ' "

	U_ExecMySql(cSql,"","E",lMostra)

Return()
*******************************************************************************
Static Function AbreTela()// Apresenta a Tela...
*******************************************************************************

	Static oGet
	Static oSay
	Static oGroup
	Static oDlg

	Local nGet 		:= 0
	Local PICT15_2 	:= "@E 999,999,999,999.99"
	Local PICT15_4 	:= "@E 99,999.9999"

	Local aValI 			:= {}
	Local aValC 			:= {}

	SetPrvt("nValNegI,nFreteI,nSeguroI,nTXDII,nDespBsI,nCIFI,nIII,nIPII,nPISI,nCOFINSI,nDespICI,nICMSI,nImpTotI,nTotGerI")
	SetPrvt("nValNegC,nFreteC,nSeguroC,nTXDIC,nDespBsC,nCIFC,nIIC,nIPIC,nPISC,nCOFINSC,nDespICC,nICMSC,nImpTotC,nTotGerC")

	nValNegI := nFreteI := nSeguroI := nTXDII := nDespBsI := nCIFI := nIII := nIPII := nPISI := nCOFINSI := nDespICI := nICMSI := nImpTotI := nTotGerI := 0
	nValNegC := nFreteC := nSeguroC := nTXDIC := nDespBsC := nCIFC := nIIC := nIPIC := nPISC := nCOFINSC := nDespICC := nICMSC := nImpTotC := nTotGerC := 0

	SomaTotI()/// Alimentas as Variaiveis de Totais Informadas...( SW8 e SW9 )
	SomaTotC()/// Alimentas as Variaiveis de Totais Calculados...( SWN )

	aValI := {nTXDII , nValNegI , nFreteI , nSeguroI , nDespBsI , nCIFI , nIII , nIPII , nPISI , nCOFINSI , nDespICI , nICMSI , nImpTotI , nTotGerI }
	aValC := {nTXDIC , nValNegC , nFreteC , nSeguroC , nDespBsC , nCIFC , nIIC , nIPIC , nPISC , nCOFINSC , nDespICC , nICMSC , nImpTotC , nTotGerC }

	U_JanEasy(aValI, aValC) // Abre a Janela

/*
	DEFINE MSDIALOG oDlg TITLE "Processo: "+cHawb+" - Verificar Valores/Taxas" FROM 000, 000  TO 465, 590 COLORS 0, 16777215 PIXEL

	@ 010, 150 GROUP oGroup TO 220, 290 PROMPT " Valores Calculados (SWN)" OF oDlg COLOR 0, 16777215 PIXEL

	@ 010, 005 GROUP oGroup TO 220, 145 PROMPT " Valores Informados (SW8,SW9,SWD)" OF oDlg COLOR 0, 16777215 PIXEL

	@ 025, 012 SAY oSay		PROMPT "Valor FOB (R$)" 		 	SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 040, 012 SAY oSay 	PROMPT "Frete (R$)" 			 	SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 055, 012 SAY oSay 	PROMPT "Seguro (R$)" 		 	SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 070, 012 SAY oSay 	PROMPT "Taxa Invoice"		 	SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 085, 012 SAY oSay 	PROMPT "Desp. Aduaneira (R$)"	SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 100, 012 SAY oSay 	PROMPT "C.I.F. (R$)" 		 	SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 115, 012 SAY oSay 	PROMPT "I.I. (R$)" 			 	SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 130, 012 SAY oSay 	PROMPT "I.P.I. (R$)" 		 	SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 145, 012 SAY oSay 	PROMPT "PIS (R$)" 		 	 	SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 160, 012 SAY oSay 	PROMPT "COFINS (R$)" 		 	SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 175, 012 SAY oSay 	PROMPT "Despesa ICMS (R$)"		SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 190, 012 SAY oSay 	PROMPT "I.C.M.S. (R$)" 		 	SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 205, 012 SAY oSay 	PROMPT "Total Geral (R$)" 	 	SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL

	@ 1000, 1000 MSGET oGet Var nGet 		SIZE 000, 000 OF oDlg PICTURE "" COLORS 0, 0 READONLY PIXEL

	@ 025, 073 MSGET oGet Var nValNegI 	SIZE 067, 010 OF oDlg PICTURE PICT15_2 COLORS 0, RC(nValNegI	,nValNegC	) READONLY PIXEL
	@ 040, 073 MSGET oGet Var nFreteI 		SIZE 067, 010 OF oDlg PICTURE PICT15_2 COLORS 0, RC(nFreteI	,nFreteC	) READONLY PIXEL
	@ 055, 073 MSGET oGet Var nSeguroI 	SIZE 067, 010 OF oDlg PICTURE PICT15_2 COLORS 0, RC(nSeguroI	,nSeguroC	) READONLY PIXEL
	@ 070, 073 MSGET oGet Var nTXDII 		SIZE 067, 010 OF oDlg PICTURE PICT15_4 COLORS 0, RC(nTXDII		,nTXDIC	) READONLY PIXEL
	@ 085, 073 MSGET oGet Var nDespBsI 	SIZE 067, 010 OF oDlg PICTURE PICT15_2 COLORS 0, RC(nDespBsI	,nDespBsC	) READONLY PIXEL
	@ 100, 073 MSGET oGet Var nCIFI 		SIZE 067, 010 OF oDlg PICTURE PICT15_2 COLORS 0, RC(nCIFI		,nCIFC		) READONLY PIXEL
	@ 115, 073 MSGET oGet Var nIII 		  SIZE 067, 010 OF oDlg PICTURE PICT15_2 COLORS 0, RC(nIII		,nIIC		) READONLY PIXEL
	@ 130, 073 MSGET oGet Var nIPII 		SIZE 067, 010 OF oDlg PICTURE PICT15_2 COLORS 0, RC(nIPII		,nIPIC		) READONLY PIXEL
	@ 145, 073 MSGET oGet Var nPISI 		SIZE 067, 010 OF oDlg PICTURE PICT15_2 COLORS 0, RC(nPISI		,nPISC		) READONLY PIXEL
	@ 160, 073 MSGET oGet Var nCOFINSI 	SIZE 067, 010 OF oDlg PICTURE PICT15_2 COLORS 0, RC(nCOFINSI	,nCOFINSC	) READONLY PIXEL
	@ 175, 073 MSGET oGet Var nDespICI 	SIZE 067, 010 OF oDlg PICTURE PICT15_2 COLORS 0, RC(nDespICI	,nDespICC	) READONLY PIXEL
	@ 190, 073 MSGET oGet Var nICMSI 		SIZE 067, 010 OF oDlg PICTURE PICT15_2 COLORS 0, RC(nICMSI		,nICMSC	) READONLY PIXEL
	@ 205, 073 MSGET oGet Var nTotGerI 	SIZE 067, 010 OF oDlg PICTURE PICT15_2 COLORS 0, RC(nTotGerI	,nTotGerC	) READONLY PIXEL

	@ 025, 155 SAY oSay 	PROMPT "Valor FOB (R$)" 		 	SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 040, 155 SAY oSay 	PROMPT "Frete (R$)" 			 	SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 055, 155 SAY oSay 	PROMPT "Seguro (R$)" 		 	SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 070, 155 SAY oSay 	PROMPT "Taxa Invoice"		 	SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 085, 155 SAY oSay 	PROMPT "Desp. Aduaneira (R$)"	SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 100, 155 SAY oSay 	PROMPT "C.I.F. (R$)" 		 	SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 115, 155 SAY oSay 	PROMPT "I.I. (R$)" 			 	SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 130, 155 SAY oSay 	PROMPT "I.P.I. (R$)" 		 	SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 145, 155 SAY oSay 	PROMPT "PIS (R$)" 		 	 	SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 160, 155 SAY oSay 	PROMPT "COFINS (R$)" 			SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 175, 155 SAY oSay 	PROMPT "Despesa ICMS (R$)"   	SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 190, 155 SAY oSay 	PROMPT "I.C.M.S. (R$)"		 	SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 205, 155 SAY oSay 	PROMPT "Total Geral (R$)" 	 	SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL

	@ 025, 215 MSGET oGet Var nValNegC 	SIZE 067, 010 OF oDlg PICTURE PICT15_2 COLORS 0, RC(nValNegI	,nValNegC	)  READONLY PIXEL
	@ 040, 215 MSGET oGet Var nFreteC 	SIZE 067, 010 OF oDlg PICTURE PICT15_2 COLORS 0, RC(nFreteI	,nFreteC	)  READONLY PIXEL
	@ 055, 215 MSGET oGet Var nSeguroC 	SIZE 067, 010 OF oDlg PICTURE PICT15_2 COLORS 0, RC(nSeguroI	,nSeguroC	)  READONLY PIXEL
	@ 070, 215 MSGET oGet Var nTXDIC 		SIZE 067, 010 OF oDlg PICTURE PICT15_4 COLORS 0, RC(nTXDII		,nTXDIC	)  READONLY PIXEL
	@ 085, 215 MSGET oGet Var nDespBsC 	SIZE 067, 010 OF oDlg PICTURE PICT15_2 COLORS 0, RC(nDespBsI	,nDespBsC	)  READONLY PIXEL
	@ 100, 215 MSGET oGet Var nCIFC 		SIZE 067, 010 OF oDlg PICTURE PICT15_2 COLORS 0, RC(nCIFI		,nCIFC		)  READONLY PIXEL
	@ 115, 215 MSGET oGet Var nIIC 		SIZE 067, 010 OF oDlg PICTURE PICT15_2 COLORS 0, RC(nIII		,nIIC		)  READONLY PIXEL
	@ 130, 215 MSGET oGet Var nIPIC 		SIZE 067, 010 OF oDlg PICTURE PICT15_2 COLORS 0, RC(nIPII		,nIPIC		)  READONLY PIXEL
	@ 145, 215 MSGET oGet Var nPISC 		SIZE 067, 010 OF oDlg PICTURE PICT15_2 COLORS 0, RC(nPISI		,nPISC		)  READONLY PIXEL
	@ 160, 215 MSGET oGet Var nCOFINSC 	SIZE 067, 010 OF oDlg PICTURE PICT15_2 COLORS 0, RC(nCOFINSI	,nCOFINSC	)  READONLY PIXEL
	@ 175, 215 MSGET oGet Var nDespICC 	SIZE 067, 010 OF oDlg PICTURE PICT15_2 COLORS 0, RC(nDespICI	,nDespICC	)  READONLY PIXEL
	@ 190, 215 MSGET oGet Var nICMSC 		SIZE 067, 010 OF oDlg PICTURE PICT15_2 COLORS 0, RC(nICMSI		,nICMSC	)  READONLY PIXEL
	@ 205, 215 MSGET oGet Var nTotGerC 	SIZE 067, 010 OF oDlg PICTURE PICT15_2 COLORS 0, RC(nTotGerI	,nTotGerC	)  READONLY PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED
*/


Return ()
*******************************************************************************
Static Function SomaTotI() // Soma valores Informados....
*******************************************************************************

	ObtemIDados()//| Obtem Dados Informados ...

	GravaIDados()//| Grava Dados Informados nas Variaveis...

Return()
*******************************************************************************
Static Function SomaTotC() // Soma valores Calculados....
*******************************************************************************

	ObtemCDados()//| Obtem Dados Calculados ...

	GravaCDados()//| Grava Dados Calculados nas Variaveis...

Return()
*******************************************************************************
Static Function ObtemIDados()//| Obtem Dados Informados ...
*******************************************************************************
	Local cYB_ICMS_UF := "YB_ICMS_" + Alltrim(SM0->M0_ESTENT)

// Capa da Invoice...
	cSql := ""
	cSQl += "SELECT W9_HAWB, W9_TX_FOB, W9_FOB_TOT "
	cSQl += "FROM SW9010 "
	cSQl += "WHERE W9_HAWB = '"+cHawb+"' "
	cSQl += "AND D_E_L_E_T_ = ' ' "

	U_ExecMySql(cSql , "W9AUX", "Q" , lMostra)


// Itens da Invoice...
	cSql := ""
	cSQl += "SELECT W8_HAWB, SUM(W8_FRETEIN)  W8_FRETEIN , SUM(W8_EX_NCM) / COUNT(1) W8_AL_ICM "
	cSQl += "FROM SW8010 "
	cSQl += "WHERE W8_HAWB = '"+cHawb+"' "
	cSQl += "AND D_E_L_E_T_ = ' ' "
	cSQl += "GROUP BY W8_HAWB "

	U_ExecMySql(cSql , "W8AUX", "Q" , lMostra)

// Despesas ...
	cSql := ""
	cSQl += "SELECT  WD_HAWB,WD_DESPESA,TRIM(YB_DESCR) YB_DESCR,YB_PERCAPL,WD_VALOR_R,YB_MOEDA,YB_BASEICM,"+cYB_ICMS_UF+" YB_ICMS_UF,YB_BASECUS "
	cSQl += "FROM  SWD010 INNER JOIN SYB010 "
	cSQl += "ON  WD_DESPESA = YB_DESP "
	cSQl += "WHERE  WD_HAWB = '"+cHawb+"' "
	cSQl += "AND SWD010.D_E_L_E_T_ = ' ' "
	cSQl += "AND SYB010.D_E_L_E_T_ = ' ' "
	cSQl += "AND WD_DESPESA < '900' "
	cSQl += "ORDER BY SWD010.WD_DESPESA "

	U_ExecMySql(cSql , "WDAUX", "Q" , lMostra)

Return()
*******************************************************************************
Static Function GravaIDados()//| Grava Dados Informados nas Variaveis...
*******************************************************************************
// Alimenta as Variaveis...
	DbSelectArea("WDAUX");DbGoTop()
	While !Eof()

		If Alltrim(WDAUX->YB_DESCR) == "SEGURO" // Seguro
			nSeguroI 	+= WDAUX->WD_VALOR_R
		EndIf
		If WDAUX->YB_BASEICM == "2" .AND. WDAUX->YB_BASECUS == "1" .And. Substr(WDAUX->WD_DESPESA,1,1) == "4" // Despesa que nao formam Base do ICMS
			nDespBsI 	+= WDAUX->WD_VALOR_R
		EndIf
		If Alltrim(WDAUX->YB_DESCR) == "I.I." // Imposto II
			nIII 		+= WDAUX->WD_VALOR_R
		EndIf
		If Alltrim(WDAUX->YB_DESCR) == "I.P.I" // Imposto IPI
			nIPII 		+= WDAUX->WD_VALOR_R
		EndIf
		If Alltrim(WDAUX->YB_DESCR) == "PIS" // Imposto PIS
			nPISI 		+= WDAUX->WD_VALOR_R
		EndIf
		If Alltrim(WDAUX->YB_DESCR) == "I.C.M.S." // Imposto ICMS
			nICMSI 	+= WDAUX->WD_VALOR_R
		EndIf
		If Alltrim(WDAUX->YB_DESCR) == "COFINS" // Imposto COFINS
			nCOFINSI 	+= WDAUX->WD_VALOR_R
		EndIf
		If WDAUX->YB_BASEICM == "1" .AND. WDAUX->YB_ICMS_UF == "1" .And. Substr(WDAUX->WD_DESPESA,1,1) == "4" // Despesa que formam Bases ICMS
			nDespICI 	+= WDAUX->WD_VALOR_R
		EndIf

		DbSelectArea("WDAUX")
		DbSkip()

	EndDo

	nValNegI 	:= ( W9AUX->W9_FOB_TOT * W9AUX->W9_TX_FOB )
	nTXDII 		:= ( W9AUX->W9_TX_FOB )
	nFreteI 		:= ( W8AUX->W8_FRETEIN * W9AUX->W9_TX_FOB )
	nCIFI 			:= ( nDespBsI + nSeguroI + nFreteI + ( W9AUX->W9_FOB_TOT * nTXDII ) )



	If lRegSICM // Regime Especial Itajai n‹o possui ICMS
		nImpTotI		:= ( nIII + nIPII + nPISI + nCOFINSI + nDespICI )
		nTotGerI 	:= ( nCIFI + nIII + nIPII + nPISI + nCOFINSI + nDespICI )
	Else
		nImpTotI		:=  ( nIII + nIPII + nPISI + nCOFINSI + nDespICI ) / (1-(W8AUX->W8_AL_ICM/100))
		nTotGerI 	:= ( nCIFI + nIII + nIPII + nPISI + nCOFINSI + nDespICI ) / (1-(W8AUX->W8_AL_ICM/100))
	EndIf

Return()
*******************************************************************************
Static Function ObtemCDados()//| Obtem Dados Informados ...
*******************************************************************************


	cSQl := ""
	cSQl += "SELECT SUM(WN_CIF)-(SUM(WN_FRETE)+SUM(WN_SEGURO)+SUM(WN_DESPADU)) AS WN_FOB, "
	cSQl += "       SUM(WN_FRETE)                                              AS WN_FRETE, "
	cSQl += "       SUM(WN_SEGURO)                                             AS WN_SEGURO, "
	cSQl += "       SUM(W9_TX_FOB)/COUNT(1)                                    AS WN_TX_FOB, "
	cSQl += "       SUM(WN_DESPADU)                                            AS WN_DESPADU, "
	cSQl += "       SUM(WN_CIF)                                                AS WN_CIF, "
	cSQl += "       SUM(WN_IIVAL)                                              AS WN_IIVAL, "
	cSQl += "       SUM(WN_IPIVAL)                                             AS WN_IPIVAL, "
	cSQl += "       SUM(WN_VLRPIS)                                             AS WN_VLRPIS, "
	cSQl += "       SUM(WN_VLRCOF)                                             AS WN_VLRCOF, "
	cSQl += "       SUM(WN_DESPICM)                                            AS WN_DESPICM, "
	cSQl += "       SUM(WN_VALICM)                                             AS WN_VALICM "

	cSQl += "FROM SWN010 INNER JOIN SW9010 "
	cSQl += "ON W9_FILIAL = WN_FILIAL "
	cSQl += "AND W9_HAWB = WN_HAWB "
	cSQl += "WHERE WN_HAWB = '"+cHawb+"' "
	cSQl += "AND SWN010.D_E_L_E_T_ = ' ' "
	cSQl += "AND SW9010.D_E_L_E_T_ = ' ' "


	U_ExecMySql(cSql , "WNAUX", "Q" , lMostra)

Return()
*******************************************************************************
Static Function GravaCDados()//| Grava Dados Calculados nas Variaveis...
*******************************************************************************

// Alimenta as Variaveis...

	nValNegC 	:= WNAUX->WN_FOB
	nSeguroC 	+= WNAUX->WN_SEGURO
	nDespBsC 	+= WNAUX->WN_DESPADU
	nIIC 			+= WNAUX->WN_IIVAL
	nIPIC 			+= WNAUX->WN_IPIVAL
	nPISC 			+= WNAUX->WN_VLRPIS
	nICMSC 		+= WNAUX->WN_VALICM
	nCOFINSC 	+= WNAUX->WN_VLRCOF
	nDespICC 	+= WNAUX->WN_DESPICM
	nTXDIC 		:= WNAUX->WN_TX_FOB
	nFreteC 		:= WNAUX->WN_FRETE
	nCIFC 			:= WNAUX->WN_CIF

	If lRegSICM // Regime Especial Itajai n‹o possui ICMS
		nImpTotC		:= ( nIIC + nIPIC + nPISC + nCOFINSC + nDespICC )
		nTotGerC 	:= ( nCIFC + nIIC + nIPIC + nPISC + nCOFINSC + nDespICC )
	Else
		nImpTotC		:= ( nIIC + nIPIC + nPISC + nCOFINSC + nDespICC ) / (1-(W8AUX->W8_AL_ICM/100))
		nTotGerC 	:= ( nCIFC + nIIC + nIPIC + nPISC + nCOFINSC + nDespICC ) / (1-(W8AUX->W8_AL_ICM/100))
	EndIF

Return()
*******************************************************************************
Static Function rc(nVal1, nVal2)// Retorna Codigo RGB de Cor
*******************************************************************************
	Local nRGB_White		:=	 16777215
	Local nRGB_Red			:= 1118719
	Local nRGB_Laranja 	:=	 4886271
	Local nRGB_Amarelo	:= 4784127

	If Round(nVal1,2) <> Round(nVal2,2)

		If Abs(nVal1 - nVal2) <= 0.10
			//Alert('Amarelo')
			Return (nRGB_Amarelo)

		ElseIf Abs(nVal1 - nVal2) <= 1
			//Alert('Laranja')
			Return (nRGB_Laranja)
		Else
			Return (nRGB_Red)
		EndIf

	EndIf

Return(nRGB_White)
*******************************************************************************
Static Function cc(xVar)// Converte Qualquer Tipo para Caracter..
*******************************************************************************

Return(cValToChar(xVar))
*******************************************************************************
Static Function ObtAliqICM(cUf)// Obtem Aliquota do ICMS que deve ser utilizado...
*******************************************************************************
Local cConteudo 	:= U_GetSX6("MV_ESTICM")
Local nPosAliq	 	:= At(cUf,cConteudo)
Local nAliqICM		:= U_GetSX6("IM_ICMIMPD") // Aliquota Default por Filial...
Local nRetorno		:= 0

Default nAliqICM := 0

//Alert("nPosAliq: " + cValtochar(nPosAliq))

//Alert("cConteudo: " + cValtochar(cConteudo))

//Alert("nAliqICM: " + cValtochar(nAliqICM))

If ( nPosAliq > 0 ) .And. nAliqICM == 0

	nPosAliq += 2 // Saltar a Sigla do estado....
	nRetorno := Val( Substr( cConteudo, nPosAliq, 2) )

	//Alert("Substr( cConteudo, nPosAliq, 2): " + cValtochar(Substr( cConteudo, nPosAliq, 2)))

Else

	nRetorno := nAliqICM

EndIf

	//Alert("nRetorno: " + cValtochar(nRetorno))

Return (	 nRetorno )
*******************************************************************************
Static Function VerRegimeICMS() // Regime Especial de ICMS apenas para iTajai...
*******************************************************************************
Local cCodDesp := "499" //| C—digo da Despesa que representa o Regime Especial sem ICMS usado em ITAJAI...
Local cSql 		:= "Select Case When Count(1) > 0 Then 1 else 0 End lRegSICMS From SWD010 Where WD_HAWB = '"+cHawb+"' And D_E_L_E_T_ = ' ' And WD_DESPESA = '"+cCodDesp+"'"
Local lResult 	:= .F.

U_ExecMySql(cSql,"RSI","Q",.F.)

DbSelectArea("RSI");DbGotop()
If !EOF()
		lResult := if(  RSI->lRegSICMS > 0 , .T., .T.  )
EndIf

DbSelectArea("RSI");DbCloseArea()


Return(lResult)