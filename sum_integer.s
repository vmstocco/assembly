			.data
			.align 0
num:    	.float 938.505
num1:   	.float -750.725
str:		.ascii "Trabalho de Organização de Computadores Digitais I"
str1:		.ascii "Vinicius Marques Stocco"
str2:    	.asciiz "Resposta "
str3:   	.asciiz "esta no registrador s1."
str4:    	.asciiz "é 0."
stro:   	.asciiz "overflow=>expoente contendo 0xFF e bit de sinal 1."
stru: 	 	.asciiz "underflow=>expoente contendo 0xFF e bit de sinal 0."

	 .text
	 .align 2
	 .globl main

main:	
     la $a0 , str				#coloca str no registrador a0
	 li $v0 , 4				#imprime a0(string)
	 la $a1 , str1				#coloca str1 no registrador a1
	 li $v0 , 4				#imprime a0(string)
	 syscall	

	 lw $a0 , num				#coloca num no registrador a0
	 lw $a1 , num1				#coloca num1 no registrador a1
	 j add_ieee754

add_ieee754:			#função que armazena os sinais, expoentes e mantissas dos numeros desejados, alem de testar se esses valores não são todos 0
	la $t0 , 0($a0)				#copia o conteudo do registrador a0 no registrador temporario t0
	jal    desmonta			
	move $t4 , $t1				#copia o sinal do "num" no registrador temporario t4
	move $t5 , $t2				#copia o expoente do "num" no registrador temporario t5
	move $t6 , $t3				#copia a mantissa do "num" no registrador temporario t6
	la $t0 , 0($a1)				#copia o conteudo do registrador a1 no registrador temporario t0
	jal    desmonta

	#Faz or entre as mantissas e 100000000000000000000000

	li $t9 , 8388608
	or $t3 , $t3 , $t9
	or $t6 , $t6 , $t9

	#Verifica se todos elementos são zero

	bne $t1 , $t4 , testes			#se os sinais forem diferentes vai para testes
	bne $t2 , $zero , arrumamant 		#se o expoente,t2, igual a 0, vai "arrumamant"
	bne $t5 , $zero , arrumamant 		#se o expoente,t5, igual a 0, vai "arrumamant"
	bne $t3 , $zero , arrumamant 		#se a mantissa,t3, igual a 0, vai "arrumamant"
	bne $t6 , $zero , arrumamant 		#se a mantissa,t6, igual a 0, vai "arrumamant"
	j respzero

desmonta:                      	 #função que desmonta o número em 3 partes
	srl  $t1 , $t0 , 31			#shift de 31 casas para a direita do valor de t0 e salva em t1 (sinal)
	li   $t9 , 2139095040			#salva a mascara (1111111100000000000000000000000) em t9  para obter o expoente
	and  $t2 , $t9 , $t0			#utiliza a mascara que esta em t9 em t0 (AND) e obtem o expoente que é salvo em t2
	srl  $t2 , $t2 , 23			#desloca o valor de t2 23 bits para a direita e salva em t2 (expoente)
	li   $t9 , 8388607			#salva a mascara (11111111111111111111111) em t9 para a mantissa
	and  $t3 , $t9 , $t0			#utiliza a mascara em t0 (AND) e obtem a mantissa que é salva em t3
	jr   $ra				#retorno
	
testes:				#função que testa se os expoentes e mantissas são iguais, se forem iguais a resposta será 0
	bne $t2 , $t5 , arrumamant  		#se os expoentes forem diferentes 
	bne $t3 , $t6 , arrumamant  		#se as mantissas forem diferentes
	j respzero
	
respzero:			#função que imprime na tela e coloca no registrador $a0 a resposta 0
    la $a0 , str2				#coloca "str2" no registrador a0
	li $v0 , 4				#imprime a0(string)
    la $a0 , str4				#coloca "str4" no registrador a0
	li $v0 , 4				#imprime a0(string)
	syscall	
	
ajusta:				#função que acerta os expoentes
	addi $t2 , $t2 , 1 			#soma 1 ao expoente em t2
	srl $t3 , $t3, 1			#shift de uma casa para a direita da mantissa do "num1"
	j arrumamant
	
arrumamant:			#função que acerta a mantissa em relação ao expoente
	beq $t2 , $t5 , testmantissa		#se os expoentes forem iguais vai para testmantissa
  	slt $t9 , $t2 , $t5			#se o expoente t2 for menor que o expoente t5 , t9 = 1, senao t9 = 0
	bne $t9 , $zero , ajusta 		#se t9 = 1 , vai para ajusta
	addi $t5 , $t5 , 1 			#soma 1 ao expoente em t5
	srl  $t6 , $t6, 1			#shift de uma casa para a direita da mantissa do "num"
	j arrumamant

testmantissa:			#função que testa qual é o maior valor absoluto entre as mantissas
	slt $t9 , $t3 , $t6  			#se a mantissa t3 for menor que a mantissa t6, t9 = 1, senao t9 = 0 
	bne $t9 , $zero , sinaldomaior		#se t9 = 1 , vai para sinaldomaior
	move $s0 , $t1				#copia o sinal de "num" t1 no registrador s0	
	j operacao
	
sinaldomaior:			#função que copia em s0 o valor do sinal de "num1"
	move $s0 , $t4				#copia o sinal de "num1" t4 no registrador s0
	j operacao
	
operacao:			#função que controla a operação que será realizada
	beq $t1 , $t4 , soma			#se os sinais forem iguais vai para soma
	slt $t9 , $t6 , $t3			#se a mantissa t6 for menor que a mantissa t3, t9 = 1, senao t9 = 0 
	bne $t9 , $zero , subtroc  		#se t9 = 1, vai para subtroc
	subu $t7 , $t6 , $t3			#faz a subtração de t3 de t6, sem considerar o sinal
	j testmantmaior

soma:				#função que realiza a soma, sem considerar o sinal 
	addu $t7 , $t3 , $t6     		# soma as mantissas e coloca em t7
	j testmantmaior
	
subtroc:			#função que realiza a subtração de t6 de t3
	subu $t7 , $t3 , $t6			#faz a subtração de t6 de t3, sem considerar o sinal
	j testmantmaior
	
testmantmaior:			#função que testa se o resultado da operacao é maior que 100000000000000000000000 
	li   $t0 , 8388608			#salva a mascara (100000000000000000000000) em t0
	slt  $t9 , $t7 , $t0			#se o resultado da operacao, t7, for menor que a mascara, t0, t9 = 1, senao t9 = 0
	bne  $t9 , $zero , testmantmenor  	#se t9 = 1, vai para testmantmenor	
	srl  $t7 , $t7 , 1			#shift de uma casa para a direita do resultado da operacao, e o coloca resultado em t7
	addi $t2 , $t2 , 1 	                #soma 1 ao expoente em t2
	j testmantmaior

testmantmenor:			#função que testa se o resultado da operacao é menor que 10000000000000000000000
	li   $t0 , 4194304			#salva a mascara (10000000000000000000000) em t0
	slt  $t9 , $t7 , $t0    		#se o resultado da operação, t7, for menor que a mascara, t0, t9 = 1, senao t9 = 0
	beq  $t9 , $zero , testunderover	#se t9 = 0, vai para testunderover
	sll  $t7 , $t7 , 1			#shift de uma casa para a esquerda do resultado da operacao, t7
	addi $t2 , $t2 , -1 	                #subtrai 1 do expoente em t2
	j testmantmenor
	
testunderover:			#função que testa se acontecera underflow ou overflow, em caso negativo de ambas já libera o resultado
	addi $t2 , $t2 , -1 			#subtrai 1 do expoente em t2

	#Testa over e/ou underflow

	li   $t0 , 255				#salva a mascara (11111111) em t0
	beq  $t2 , $t0 , underover		#se o resultado do expoente, t2, for igual a mascara,t0, vai para underover
	sll  $t7 , $t7 , 1			#shift de uma casa para a esquerda do resultado da operacao, e o coloca resultado em t7
	li   $t0 , 8388607			#salva a mascara (11111111111111111111111) em t0
	and  $t7 , $t7 , $t0			#utiliza a mascara em t7 (AND) e o coloca resultado em t7
	sll  $t8 , $t2 , 23			#shift de 23 casas para a esquerda do expoente,t2, e o coloca resultado em t8
	sll  $t0 , $s0 , 31			#shift de 31 casas para a esquerda do sinal,s0, e o coloca resultado em t0
	or   $s1 , $t7 , $t8			#faz a operação de juntar a mantissa e o expoente, e o coloca resultado em s1
	or   $s1 , $s1 , $t0			#faz a operação de juntar s1 com o sinal,t0, e o coloca resultado em s1

	la   $a0 , str3				#coloca "str3" no registrador a0
	li   $v0 , 4				#imprime a0(string)
	syscall

	li $v0 , 10				#encerra o programa
	syscall
	
underover:			#função que trata o resultado caso esse seja overflow ou underflow
	beq  $s0 , $zero , overflow    		#se o sinal,s0, for 0, vai para "overflow"
	la $a0 , stru				#coloca "strur" no registrador a0
	li $v0 , 4				#imprime a0(string)
	syscall
	
	li $v0 , 10				#encerra o programa
	syscall

overflow:			#função que trata o resultado caso esse seja overflow
	la $a0 , stro				#carrega "stro" em a0
	li $v0 , 4				#imprime a0(string)
	syscall
	
	li $v0 , 10				#encerra o programa
	syscall

