#INCLUDE 'Protheus.ch'

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ AtuStatusCli| Autor ³ Cristiano Machado  ³ Data ³ 29/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina executada via WorkFlow mensalmente para manter auta-³±±
±±³          ³ lizado os Status de Venda do Cliente. Conforme suas compras³±±
±±³          |                                                            ³±±
±±³          ³ ATIVO: Cliente que efetuou compra dentro dos ultimos 90dias³±±
±±³          | NOVO : Cliente que efetuou primeira compra no ultimo mes   ³±±
±±³          | INATIVO: Ultima compra Superior a 90 Dias                  ³±±
±±³          | REATIVADO: Cliente que efetuou compra no Ultimosmes e nao  ³±±
±±³          |            efetuou compra nos 90 dias anteriores.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/


*****************************************************************************
User Function AtuStatusCli()
*****************************************************************************

SetPrv("dAnt1Mes, dAnt2Mes, dAnt3Mes, dAnt4Mes, dAnt4Ano")

PREPARE ENVIRONMENT EMPRESA '01' FILIAL '05' USER 'Administrador' PASSWORD '' TABLES 'SX6'


//| Prepara Parametros de Datas...
PreparaDatas()

//| Cria Tabela Auxiliar....
CriatabelaAux()

//| Define Status de Clientes.....
QuerySetCli()

//| Inativa Clientes Que nao estao na Query
QueryInativos()

//Insere Novos Registros e Atualiza Cadastro de Clientes
InsertRegSZY()

//Limpa Tabelas Auxiliares...
LimpaTudo()


RESET ENVIRONMENT

Return()

*****************************************************************************
Static Function PreparaDatas()//| Prepara Parametros de Datas...
*****************************************************************************


cAnt1Mes 	:= SubStr(dToS(dDataBase - 20),1,6)          	//| Utilizo 20 dias,por que o Workflow sempre executa no dia 1 do mes corrente...e deve ser analisado apartir do mes anterior
cAnt2Mes	:= SubStr(dToS(sToD(cAnt1Mes+'01')-20),1,6)   	//| Utilizo mesma regra do acima so que partindo da variavel cAnt1Mes...
cAnt3Mes	:= SubStr(dToS(sToD(cAnt2Mes+'01')-20),1,6)   	//| Utilizo mesma regra do acima so que partindo da variavel cAnt2Mes...
cAnt4Mes	:= SubStr(dToS(sToD(cAnt3Mes+'01')-20),1,6)   	//| Utilizo mesma regra do acima so que partindo da variavel cAnt3Mes...
cAnt4Ano	:= SubStr(dToS(sToD(cAnt1Mes+'01')-365*4),1,6)	//| Utilizo mesma regra do acima so com o periodo de 4 anos e partindo da variavel cAnt1Mes...para pegar 4 anos em relacao ao ao mes anterior que deve ser analisado.



Return()
*****************************************************************************
Static Function CriatabelaAux()//| Cria Tabela Auxiliar....
*****************************************************************************

Local cSql := ""


//| Deleta Tabela Caso Exista...
U_ExecMySql("DELETE VENDAS_CLIENTES","","E",.F.)



//| Cria Tabela Auxiliar...
cSql += "CREATE TABLE VENDAS_CLIENTES AS "

cSql += " SELECT DISTINCT  SD2.D2_CLIENTE              CLIENTE , "
cSql += "                  SD2.D2_LOJA                 LOJA, "
cSql += "                  SUBSTR(SD2.D2_EMISSAO,1,6)  COMPRA "

cSql += "FROM SD2010 SD2, "
cSql += "  SF4010 SF4 , "
cSql += "  SC5010 SC5 "
cSql += "WHERE SUBSTR(SD2.D2_EMISSAO,1,6) BETWEEN '"+cAnt4Ano+"' AND '"+cAnt1Mes+"' "
cSql += "AND   SF4.F4_FILIAL    = D2_FILIAL "
cSql += "AND   SF4.F4_CODIGO    = D2_TES "
cSql += "AND   SD2.D2_FILIAL    = C5_FILIAL "
cSql += "AND   SD2.D2_PEDIDO    = SC5.C5_NUM "
cSql += "AND   SD2.D2_TIPO      NOT IN ( 'B', 'D' ) "
cSql += "AND   SD2.D2_ORIGLAN   <> 'LF' "
cSql += "AND   SF4.F4_DUPLIC    = 'S' "
cSql += "AND   SF4.F4_ESTOQUE   = 'S' "
cSql += "AND   SD2.D_E_L_E_T_   = ' ' "
cSql += "AND   SF4.D_E_L_E_T_   = ' ' "
cSql += "AND   SC5.D_E_L_E_T_   = ' ' "


U_ExecMySql(cSql,"","E",.F.)


Return ()

*****************************************************************************
Static Function QuerySetCli() //| Define Status de Clientes.....
*****************************************************************************

Local cSql := ""

cSql := "SELECT CLIENTE, LOJA, STATUS FROM ( "

cSql := "((SELECT DISTINCT CLIENTE, LOJA , 'R' STATUS "
cSql := "  FROM VENDAS_CLIENTES "
cSql := "  WHERE COMPRA = '201312' "
cSql := "  MINUS "
cSql := "  SELECT DISTINCT CLIENTE, LOJA , 'R' STATUS "
cSql := "  FROM VENDAS_CLIENTES "
cSql := "  WHERE COMPRA BETWEEN '201309' AND '201311' "
cSql := ") INTERSECT "
cSql := "  SELECT DISTINCT CLIENTE, LOJA , 'R' STATUS "
cSql := "  FROM VENDAS_CLIENTES "
cSql := "  WHERE COMPRA BETWEEN '201012' AND '201308' "
cSql := "  )

cSql := "  UNION ALL "
// 2 PARTE - ATIVOS

cSql := " (SELECT DISTINCT CLIENTE, LOJA , 'A' STATUS "
cSql := "  FROM VENDAS_CLIENTES "
cSql := "  WHERE COMPRA = '201312' "
cSql := "     INTERSECT
cSql := "  SELECT DISTINCT CLIENTE, LOJA , 'A' STATUS
cSql := "  FROM VENDAS_CLIENTES
cSql := "  WHERE COMPRA = '201311'
cSql := "     INTERSECT
cSql := "  SELECT DISTINCT CLIENTE, LOJA , 'A' STATUS
cSql := "  FROM VENDAS_CLIENTES
cSql := "  WHERE COMPRA = '201310')


cSql := "  UNION ALL "

//| 3 PARTE - NOVOS

cSql := " (SELECT DISTINCT CLIENTE, LOJA , 'N' STATUS
cSql := "  FROM VENDAS_CLIENTES INNER JOIN SA1010 SA1
cSql := "  ON    CLIENTE = A1_COD
cSql := "  AND   LOJA    = A1_LOJA
cSql := "  WHERE COMPRA = '201312'
cSql := "  AND   SUBSTR(SA1.A1_PRICOM,1,6) = '201312')

cSql := "  UNION ALL "

 -- 4ª PARTE - INATIVOS

cSql := " ( SELECT DISTINCT CLIENTE, LOJA , 'I' STATUS
cSql := "  FROM VENDAS_CLIENTES
cSql := "  WHERE COMPRA < '201310'
cSql := "  MINUS
cSql := "  SELECT DISTINCT CLIENTE, LOJA  , 'I' STATUS
cSql := "  FROM VENDAS_CLIENTES
cSql := "  WHERE COMPRA >= '201310'
cSql := "  )


cSql := "  ) TAB "

cSql := "  ORDER BY 1,2,3 "


U_ExecMySql(cSql,"SCLI","Q",.F.)

Return()


*****************************************************************************
Static Function QueryInativos() //| Inativa Clientes Que nao estao na Query de Status...
*****************************************************************************

Local cSql := ""

cSql := "SELECT A1_COD CLIENTE, A1_LOJA LOJA FROM SA1010 WHERE A1_COD > ' ' AND d_e_l_e_t_ = ' ' "
cSql := "MINUS "
cSql := "SELECT CLIENTE, LOJA FROM vendas_clientes "

U_ExecMySql(cSql,"DCLI","Q",.F.)

Return()

*****************************************************************************
Static Function InsertRegSZY() //| Insere Novos Registros e Atualiza Cadastro de Clientes
*****************************************************************************



Return()