#INCLUDE 'RWMAKE.CH'


#Define _REAL 1

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : NomeProg    | AUTOR : Cristiano Machado  | DATA : 22/12/2015   **
**---------------------------------------------------------------------------**
** DESCRIÇÃO: Ponto de entrada Usado para Corrigir o Custo em Notas de       **
**          : Importacao. Devido a não estar Creditando o PIS/COFINS..       **
**---------------------------------------------------------------------------**
** USO      : Especifico para o cliente IMDEPA                               **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
**            ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.              **
**---------------------------------------------------------------------------**
**   PROGRAMADOR   |   DATA   |            MOTIVO DA ALTERACAO               **
**---------------------------------------------------------------------------**
**                 |          |                                              **
**                 |          |                                              **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User Function A103CUST()
*******************************************************************************

	//| Chamado Totvs :  TTRCI9 |
	//| Chamado GLPI  :  802    |

	Local aRet := PARAMIXB[1] //| Recebe o Custo do Produto Calculado nas Moedas Utilizadas pela Sistema.

	If xFilial("SD1") == "06" //| Tratamento Itájai...|

		If ( SF1->F1_EST == "EX" .or. CUFORIG == "EX" )

			If !Empty(SD1->D1_NUMDI)

				//| Recalcula o Custo Creditando o PIS/COFINS|
				aRet[1][_REAL] := aRet[1][_REAL] - (SD1->D1_VALIMP5 + SD1->D1_VALIMP6 )

			EndIf
		EndIf
	EndIf


Return aRet