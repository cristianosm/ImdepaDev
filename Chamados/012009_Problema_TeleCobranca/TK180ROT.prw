#include 'protheus.ch'
#include 'parmtype.ch'


//|****************************************************************************
//| Projeto:
//| Modulo :
//| Fonte : TK180ROT
//| 
//|************|******************|*********************************************
//|    Data    |     Autor        |                   Descricao
//|************|******************|*********************************************
//| 15/01/2017 | Cristiano Machado| Funcao responsavel por sincronizar Telefone do Cliente com Tabela de Contatos.
//|            |                  | Utilizado na criacao das listas do Telecobranca.   
//|            |                  |  
//|            |                  |  
//|            |                  |  
//|************|***************|***********************************************
user function TK180ROT()
	
Local aRotCust	:= {}

	aRotCust := {{ 'Atualiza Telefones',	"U_SinCliCon", 0, 5 , , .T.}} 

return(aRotCust)