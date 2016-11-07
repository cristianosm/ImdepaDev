#Include "Totvs.ch"
#Include "Tbiconn.ch"

#Define _ENTER CHR(10) + CHR(13)

//|****************************************************************************
//| Projeto: CHAMADO 8907
//| Modulo : ESTOQUE
//| Fonte : WFUQPEDRES
//|
//|************|*****************|*********************************************
//|    Data    |     Autor       |                   Descricao
//|************|*****************|*********************************************
//| 18/08/2016 |Cristiano Machado| Solucao Palhativa para Corrigir o Saldo em QPEDVEN e RESERVA
//|            |                 |
//|            |                 | Deve estar agendado para executar toda a noite.
//|            |                 |
//|            |                 |
//|************|***************|***********************************************
*******************************************************************************
User Function WFUQPEDRES()
*******************************************************************************

Local cEmp := '01'
Local cFil := '05'

PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil FUNNAME 'WFUQPEDRES'  TABLES 'SM0','SB2'

Private lTest := .F.
Private lShow := .F.
Private nReg  :=  0

conout( 'WFUQPEDRES - INICIANDO                                     ' + dToc(dDataBase) + ' ' + time() )


conout( 'WFUQPEDRES - Executando Query... Pode demorar ...          ' + dToc(dDataBase) + ' ' + time() )
ExecQuery()

conout( 'WFUQPEDRES - Iniciando Update                              ' + dToc(dDataBase) + ' ' + time() )
ExecUpdate()

conout( 'WFUQPEDRES - FINALIZADO                                    ' + dToc(dDataBase) + ' ' + time() )

U_EnvMyMail('protheus@imdepa.com.br','cristiano.machado@imdepa.com.br','','AJUSTE B2_QPEDVEN e B2_RESERVA', _ENTER + _ENTER + "Foram Atualizados " + cValToChar(nReg) + ' Registros... ','',.F.)//| U_EnvMyMail(De, Para, Copia, Assunto, Corpo, Anexo )
U_EnvMyMail('protheus@imdepa.com.br','edivaldo@imdepa.com.br','','AJUSTE B2_QPEDVEN e B2_RESERVA', _ENTER + _ENTER + "Foram Atualizados " + cValToChar(nReg) + ' Registros... ','',.F.)//| U_EnvMyMail(De, Para, Copia, Assunto, Corpo, Anexo )

RESET ENVIRONMENT
//atual

Return()
*******************************************************************************
Static Function ExecQuery()
*******************************************************************************

Local cSql := ""
Local cCursor := "QPR"
Local cProduto := '00016252'
Local cDataIni := DTOS(dDataBase - (365))

cSql += "SELECT "
cSql += "   VALIDACAO, FILIAL, PRODUTO, ESTOQUE, SALDO_B2, PEDIDO_C6, QPEDVEN_B2, QPEDVEN_OK, RESERVA_B2, RESERVA_OK  "
cSql += "  , 'UPDATE SB2010 SET B2_RESERVA = '|| RESERVA_OK || ', B2_QPEDVEN = ' || QPEDVEN_OK || ' WHERE B2_FILIAL = ''' || FILIAL || ''' AND B2_COD = ''' || PRODUTO || ''' AND B2_LOCAL = ''' || ESTOQUE || ''' AND D_E_L_E_T_ = '' '' ' AJUSTE "
cSql += "FROM "
cSql += "   ( "
cSql += "      SELECT "
cSql += "         CASE "
cSql += "            WHEN NVL( PED.QPEDVEN_OK, 0 ) <> SB2.B2_QPEDVEN "
cSql += "               AND NVL( PED.RESERVA_OK, 0 ) <> SB2.B2_RESERVA "
cSql += "            THEN 'ERRO: QPEDVEN e RESERVA ' "
cSql += "            WHEN NVL( PED.QPEDVEN_OK, 0 ) <> SB2.B2_QPEDVEN "
cSql += "            THEN 'ERRO: QPEDVEN ' "
cSql += "            WHEN NVL( PED.RESERVA_OK, 0 ) <> SB2.B2_RESERVA "
cSql += "            THEN 'ERRO: RESERVA ' "
cSql += "            ELSE 'CORRETO' "
cSql += "         END AS VALIDACAO, SB2.B2_FILIAL FILIAL, SB2.B2_COD PRODUTO, SB2.B2_LOCAL ESTOQUE, NVL( PED.QTD_SC6, 0 ) PEDIDO_C6, NVL( PED.QPEDVEN_OK, 0 ) QPEDVEN_OK, NVL( PED.RESERVA_OK, 0 ) RESERVA_OK, SB2.B2_QATU SALDO_B2, SB2.B2_QPEDVEN QPEDVEN_B2, SB2.B2_RESERVA RESERVA_B2 "
cSql += "      FROM "
cSql += "         ( "
cSql += "            SELECT "
cSql += "               PED.FILIAL, PED.PROD, PED.EST, SUM( QPEDVEN_C6 ) QTD_SC6, SUM( QPEDVEN_C6 - RESERVA_C9) QPEDVEN_OK, SUM( RESERVA_C9 ) RESERVA_OK "
cSql += "            FROM "
cSql += "               (  " // VERICA PEDIDOS EM ABERTO
cSql += "                  SELECT "
cSql += "                     C6_FILIAL FILIAL, C6_PRODUTO PROD, C6_LOCAL EST, C6_QTDVEN QPEDVEN_C6, 0 RESERVA_C9 "
cSql += "                  FROM "
cSql += "                     SC6010, SC5010 "
cSql += "                  WHERE "
cSql += "                     SC6010.D_E_L_E_T_ = ' ' "
cSql += "                     AND C6_QTDVEN > C6_QTDENT "
cSql += "                     AND C6_FILIAL > '  ' "
cSql += "                     AND C6_FILIAL = C5_FILIAL "
cSql += "                     AND C6_NUM    = C5_NUM "
cSql += "                     AND SC5010.D_E_L_E_T_ = ' ' "
cSql += "                     AND C5_EMISSAO >= '20150101' "

If !Empty(cProduto)  .And.  lTest
	cSql += "                   AND SC6010.C6_PRODUTO = '"+cProduto+"' "
EndIf

cSql += "                  UNION ALL "
                  //|  VERIFICA LIBERACOES JA EFETUADAS... CREDITO E ESTOQUE.. LIBERADOS
cSql += "                  SELECT DISTINCT C9_FILIAL FILIAL, C9_PRODUTO PROD, C9_LOCAL EST, 0 QPEDVEN_C6, C9_QTDLIB RESERVA_C9 "
cSql += "                  FROM "
cSql += "                     SC9010, SC6010, SC5010, SD2010 "
cSql += "                  WHERE "
cSql += "                     SC9010.D_E_L_E_T_ = ' ' "
cSql += "                     AND C9_BLCRED = ' '  "
cSql += "                     AND C9_BLEST = ' ' "
//                     --AND C9_NFISCAL > ' ' -- Desconsidera NF Emitida
cSql += "                     AND C9_FILIAL > '  ' "
cSql += "                     AND C6_FILIAL = C9_FILIAL "
cSql += "                     AND C6_NUM    = C9_PEDIDO "
cSql += "                     AND C6_PRODUTO= C9_PRODUTO "
cSql += "                     AND C6_LOCAL  = C9_LOCAL "
cSql += "                     AND SC6010.D_E_L_E_T_ = ' ' "
cSql += "                     AND C6_FILIAL = C5_FILIAL "
cSql += "                     AND C6_NUM    = C5_NUM "
cSql += "                     AND SC5010.D_E_L_E_T_ = ' ' "
cSql += "                     AND C5_EMISSAO >= '20150101' "

cSql += "                     AND NOT EXISTS ( SELECT D2_FILIAL, D2_COD, D2_PEDIDO, D2_CLIENTE, D2_LOJA, D2_LOCAL "
cSql += "                                      FROM SD2010, SF4010 "
cSql += "                                      WHERE D2_FILIAL = C9_FILIAL "
cSql += "                                      AND   D2_COD = C9_PRODUTO "
cSql += "                                      AND   D2_PEDIDO = C9_PEDIDO "
cSql += "                                      AND   D2_LOJA = C9_LOJA "
cSql += "                                      AND   D2_CLIENTE = C9_CLIENTE "
cSql += "                                      AND   D2_LOCAL = C9_LOCAL "

If !Empty(cProduto)  .And.  lTest
	cSql += "                   AND   D2_COD   = '"+cProduto+"' "
EndIf

cSql += "                                      AND   SD2010.D_E_L_E_T_ = ' ' "

cSql += "                                      AND   D2_TES = F4_CODIGO "
cSql += "                                      AND   D2_FILIAL = F4_FILIAL "
cSql += "                                      AND   F4_ESTOQUE = 'S' "
cSql += "                                      AND   D2_EMISSAO >= '20150101' "

cSql += "                                      ) "

If !Empty(cProduto)  .And.  lTest
	cSql += "                  AND SC9010.C9_PRODUTO = '"+cProduto+"' "
EndIf

cSql += "               ) "
cSql += "               PED  "
cSql += "            GROUP BY "
cSql += "               PED.FILIAL, PED.PROD, PED.EST "
cSql += "         ) "
cSql += "         PED "
cSql += "      FULL JOIN SB2010 SB2 ON PED.FILIAL = SB2.B2_FILIAL AND PED.PROD = SB2.B2_COD AND PED.EST = SB2.B2_LOCAL "
cSql += "      WHERE "
cSql += "         ( "
cSql += "            SB2.D_E_L_E_T_ = ' ' "
cSql += "            AND B2_FILIAL > '  ' "

If !Empty(cProduto)  .And.  lTest
	cSql += "                  AND SB2.B2_COD = '"+cProduto+"' "
EndIf

cSql += "         ) "
cSql += "         OR SB2.D_E_L_E_T_ IS NULL "
cSql += "   ) "
cSql += "   TABELA "

cSql += "WHERE "
cSql += "   TABELA.VALIDACAO <> 'CORRETO' "

cSql += "ORDER BY "
cSql += "   FILIAL, PRODUTO, ESTOQUE "

//| Limpa espacos em branco
While AT("  ", cSql) > 0
	cSql := StrTran(cSql, "  ", " ")
EndDo

U_ExecMySql( cSql , cCursor , "Q", lShow, .F. )

Return()
*******************************************************************************
Static Function ExecUpdate()
*******************************************************************************

DbSelectArea("QPR");DbGotop()

While !EOF()


	conout( 'WFUQPEDRES - Update abaixo:                                ' + dToc(dDataBase) + ' ' + time() )
	conout( Alltrim(QPR->AJUSTE) + ";")

	U_ExecMySql( Alltrim(QPR->AJUSTE) , '' , "E", lShow, .F. )

	nReg += 1

	DbSelectArea("QPR")
	DbSkip()

EndDo

DbSelectArea("QPR")
DbCloseArea()


Return()