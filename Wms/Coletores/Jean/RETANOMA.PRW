#INCLUDE "PROTHEUS.CH"

/*
Jean Rehermann - Solutio IT - 02/01/2018
Permite remover a condição de anomalia de um movimento com divergência de recebimento
Acionado via opção de ações relacionadas da rotina de monitor de serviços pelo ponto de entrada WM331MNU
*/

User Function RetAnoma

	If SDB->DB_ESTORNO != "S"
	
		If SDB->DB_SERVIC == "003"
	
			If SDB->DB_TAREFA == "003"
				
				If SDB->DB_ATIVID == "022"
				
					If AllTrim( SDB->DB_ANOMAL ) == "S"
						
						If MsgYesNo("Deseja remover a anomalia do item "+ AllTrim( SDB->DB_PRODUTO ) +"  documento "+ AllTrim( SDB->DB_DOC ) +"/"+ SDB->DB_SERIE +"?")
						
							RecLock("SDB",.F.)
								SDB->DB_ANOMAL := Space( Len( SDB->DB_ANOMAL ) )
								SDB->DB_STATUS := "1"
							MsUnLock()
							
						EndIf
					Else
						MsgAlert("Registro não está com anomalia!")
					EndIf
				Else
					MsgAlert("Atividade não é de conferência de recebimento!")
				EndIf
			Else
				MsgAlert("Tarefa não é de conferência!")
			EndIf
		Else
			MsgAlert("Serviço não é de recebimento!")
		EndIf
    Else
		MsgAlert("Registro atual está estornado!")
    EndIf
    
Return Nil