# 
#  Name:   Green, Carson
#  Project:  # 3
#  Due: 4/15/2022
#  Course:  cs-2640-03-sp22 
# 
#  Description: 
#     reads up to ten lines from user, then prints them out.
# 
 
MAXLINES = 10
LINELEN = 82        
          .data
lines:    .word     0:10
inbuf:    .space    LINELEN
heapbuf:   .word     0
title:    .asciiz   "Lines by C. Green\n\n"
prompt:   .ascii    "Enter text? "

          .text

main:
          la        $a0, title
          li        $v0, 4
          syscall

          addi      $sp, $sp, -12
         
          sw        $s0, 0($sp)         #stores address of lines on stack
          sw        $s1, 4($sp)
          sw        $ra, 8($sp)

          la        $s0, lines
          
          li        $s1, 0

          
         
while0:
          la        $a0, prompt         #prints prompt
          li        $v0, 4
          syscall
          
          la        $a0, inbuf          #loads the inbuf for a parameter
          li        $a1, LINELEN
          jal       gets
          lb        $t0, inbuf
          beq       $t0, '\n', endw0    #breaks if character is \n
          la        $a0, inbuf 
          jal       strdup
          sw        $v0, ($s0)          #stores the heap address into lines
          addi      $s0, $s0, 4
          addi      $s1, $s1, 1

          
          ble       $s1, 9, while0     # branches 10 times
endw0:
          li        $t0, 0              #line counter
          la        $s0, lines          #loads address of lines

          li        $a0, '\n'
          li        $v0, 11
          syscall

whileprt: bge       $t0, $s1, endwp     #prints the lines array
          lw        $a0, ($s0)
          jal       puts
          addi      $s0, $s0, 4         #traverses lines array
          addi      $t0, $t0, 1
          b         whileprt
endwp:
          lw        $s0, 0($sp)         #restores s registers
          lw        $s1, 4($sp)
          lw        $ra, 8($sp)         #restores the ra
          addi      $sp, $sp, 12

          jr        $ra
         

# gets(cstring inbuf, int LINELEN)\
#     gets user input and stores in inbuf
#   parameters:
#         $a0: inbuf
#         $a1: LINELEN
#   return type
#         returns user input into inbuf
#      
gets:
          li        $v0, 8              #reads cstring
          syscall
         
          jr        $ra

# puts(cstring)
#         prints cstring
# parameters:
#         none
#return values:
#         none
puts:
          li        $v0, 4
          syscall
# strlen (cstring inbuf)
#         gets the length
# parameters:
#         $a0: inbuf
# return values:
#         $v0: heap address of duplicated string
strlen:
          
          li        $v0, 0
while1:   lb        $t1, ($a0)
          beq       $t1, 0, endw1              #if it is 0 end the counter
          addi      $a0, $a0, 1
          addi      $v0, $v0, 1
          b         while1

endw1:    jr        $ra

# malloc(int strlen)
#         allocates space on the heap
# parameters
#         $a0: int string length
# return values:
#         $v0: heap address

malloc:
          
          addi      $a0, $a0, 3
          andi      $a0, $a0, 0xfffc              #makes string length multiple of 4

          li        $v0, 9                        #allocates space on the heap
          syscall
          jr        $ra
# strdup(cstring)
#         duplicates string onto the heap, and returns the heap address
# parameters:
#         $a0: inbuf
#return values:
#         word address of string on heap
strdup:
          
          addi      $sp, $sp, -8        #allocate space on stack
          sw        $ra, 0($sp)         #save return address because non leaf
          sw        $a0, 4($sp)         #stores a0 because it gets overwritten

          jal       strlen
          addi      $a0, $v0, 1         #string length + 1 for 0 byte
          jal       malloc
          
          lw        $a0, 4($sp)         #restore a0

          move      $t0, $a0            #has address of inbuf
          move      $t1, $v0            
while2:	lb	$t2, ($t0)	# get char from inbuf
	sb	$t2, ($t1)	# put char on heap, ensure copy also \0
	beqz	$t2, endw2	# if char is \0, done
	addi	$t0, $t0, 1	# next inbuf char
	addi	$t1, $t1, 1	# next heap char
	b 	while2
endw2:
          lw        $ra, 0($sp)
          addi      $sp, $sp, 8
          
          jr        $ra

          
