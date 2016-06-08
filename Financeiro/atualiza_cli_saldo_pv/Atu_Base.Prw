#Include 'TbiConn.ch'
#Include 'protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Atu_Base_CliºAutor  ³Cristiano Machado º Data ³  05/17/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica Saldo em Pedidos de Determinado Cliente e Corrige  º±±
±±º          ³se Necessario no cadastro de clientes... Varre toda a base  º±±
±±º          ³de clientes com ultima compra dentro dos ultimos 3 anos.    º±±
±±º          ³Deve ser executado semanalmente no Workflow...              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*********************************************************************
User Function Atu_Base_Cli(cCod, cLoja)
*********************************************************************

Private cSQl 	:= ""
Private oAtuCli	:= Nil
Private nTotal 	:= 0 // 12252
Private nProc	:= 0

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "05" MODULO "FIN" USER "WORK" PASSWORD "WORK" FUNNAME 'ATUCLI'  TABLES 'SA1'

Default cCod 	:= Space(06)
Default cLoja 	:= Space(02)

DbSelectArea("SA1");DbSetOrder(1) 

cSQl 		:= ""
oAtuCli	:= Nil
nTotal 	:= 0 // 12252
nProc		:= 0

oAtuCli	:= PvSldFin():Novo( '000001' , '01' )
oAtuCli:AtuCliente()

Dispara()

Reset Environment


Return()
*********************************************************************
Static Function Dispara()
*********************************************************************

cData36m := dToS( dDatabase - ( 365 * 3) )

cSql := ""
cSql := "Select Count(1) TOTCLI  From Sa1010 Where A1_UltCom >= '"+cData36m+"' And d_e_l_e_t_ = ' ' "

U_ExecMySql(cSql, "TEMP","Q", .F.)/// Seleciona os Clientes...

DbSelectArea("TEMP");DbGotop()
 
nTotal := Val(cValToChar(TEMP->TOTCLI))

cSql := ""
cSql := "Select ROWNUM NUM, AUX.A1_COD, AUX.A1_LOJA  From ( select A1_COD, A1_LOJA FROM Sa1010 Where A1_UltCom >= '"+cData36m+"' And d_e_l_e_t_ = ' '  ORDER BY A1_COD, A1_LOJA ) AUX"

Conout("ATUCLI - Query: "+cSql) 

U_ExecMySql(cSql, "TEMP","Q", .F.)/// Seleciona os Clientes...


DbSelectArea("TEMP");DbGotop()
While !Eof()

	oAtuCli:Cliente( TEMP->A1_COD , TEMP->A1_LOJA ) //| Troca Cliente...

	oAtuCli:AtuCliente()
	
	oAtuCli:RefazCLI()

	conout("ATUCLI - Registro "+cValToChar(TEMP->NUM) +" de "+cValToChar(nTotal)+" : "+TEMP->A1_COD +"."+ TEMP->A1_LOJA + Space(10) + cValToChar(dDataBase) + "  " + Time() )
	
	DbSelectArea("TEMP");DbSkip()

End While

Return()