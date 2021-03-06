#INCLUDE "PROTHEUS.CH"

/*
Jean Rehermann - Solutio IT - 02/01/2018
Permite remover a condi��o de anomalia de um movimento com diverg�ncia de recebimento
Acionado via op��o de a��es relacionadas da rotina de monitor de servi�os pelo ponto de entrada WM331MNU
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
						MsgAlert("Registro n�o est� com anomalia!")
					EndIf
				Else
					MsgAlert("Atividade n�o � de confer�ncia de recebimento!")
				EndIf
			Else
				MsgAlert("Tarefa n�o � de confer�ncia!")
			EndIf
		Else
			MsgAlert("Servi�o n�o � de recebimento!")
		EndIf
    Else
		MsgAlert("Registro atual est� estornado!")
    EndIf
    
Return Nil