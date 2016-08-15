#include 'protheus.ch'
#include 'parmtype.ch'

User Function Tst_Fin003()
	
	
	oAtuCli	:= PvSldFin():Novo( '029868' , '01' )
	
	oAtuCli:Cliente(  '029868' , '01' ) //| Troca Cliente...

	oAtuCli:AtuCliente()
	
	oAtuCli:RefazCLI()
	

Return()