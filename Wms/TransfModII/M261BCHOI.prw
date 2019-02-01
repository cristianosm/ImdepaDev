#include 'protheus.ch'
#include 'parmtype.ch'

*******************************************************************************
User Function M261BCHOI()
*******************************************************************************
	
	Local aButtons := {} // "BITMAP" , { || Alert("Texto Botao") } , "Texto do Botão" }
	Set Key VK_F7 TO
	Set Key VK_F7 TO U_M261IMPARQ()
	
	
Return( aButtons )

User Function M261IMPARQ()

	Alert("Entrou")
	

Return Nil