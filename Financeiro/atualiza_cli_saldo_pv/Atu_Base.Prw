#Include 'TbiConn.ch'
#Include 'protheus.ch'

/*
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
HHHPrograma  HAtu_Base_CliHAutor  HCristiano Machado H Data H  05/17/13   HHH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH͹HH
HHHDesc.     HVerifica Saldo em Pedidos de Determinado Cliente e Corrige  HHH
HHH          Hse Necessario no cadastro de clientes... Varre toda a base  HHH
HHH          Hde clientes com ultima compra dentro dos ultimos 3 anos.    HHH
HHH          HDeve ser executado semanalmente no Workflow...              HHH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH͹HH
HHHUso       H                                                            HHH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
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

RESET ENVIROMENT


Return()
*********************************************************************
Static Function Dispara()
*********************************************************************

cData36m := dToS( dDatabase - ( 365 * 3) )

cSql := ""
cSql := "Select Count(1) TOTCLI  From Sa1010 Where A1_UltCom >= '"+cData36m+"' And d_e_l_e_t_ = ' ' "

//cSql := "Select Count(1) TOTCLI  From Sa1010 Where A1_UltCom = ' ' And d_e_l_e_t_ = ' ' "


U_ExecMySql(cSql, "NREG","Q", .F.)/// Seleciona os Clientes...

DbSelectArea("NREG");DbGotop()
 
nTotal := Val(cValToChar(NREG->TOTCLI))

cSql := ""
cSql := "Select ROWNUM NUM, AUX.A1_COD, AUX.A1_LOJA  From ( select A1_COD, A1_LOJA FROM Sa1010 Where A1_UltCom >= '"+cData36m+"' And d_e_l_e_t_ = ' '  ORDER BY A1_COD, A1_LOJA ) AUX"

Conout("ATUCLI - Query: "+cSql) 

U_ExecMySql(cSql, "TEMP","Q", .F.)/// Seleciona os Clientes...

Conout("ATUCLI - Executando Atualizacao para Clientes com Ult.Com dentro dos ultimos 36 meses... ") 
DbSelectArea("TEMP");DbGotop()
While !Eof()

	conout("ATUCLI - Registro "+cValToChar(TEMP->NUM) +" de "+cValToChar(nTotal)+" : "+TEMP->A1_COD +"."+ TEMP->A1_LOJA + Space(10) + cValToChar(dDataBase) + "  " + Time() )
	
	oAtuCli:Cliente( TEMP->A1_COD , TEMP->A1_LOJA ) //| Troca Cliente...

	oAtuCli:AtuCliente()
	
	oAtuCli:RefazCLI()
	
	DbSelectArea("TEMP")
	DbSkip()

End While

Return()