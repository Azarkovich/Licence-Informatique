.text
.globl main
print_int:
  li $v0, 1
  syscall
  li $v0, 0
  jr $ra
print_string:
  li $v0, 4
  syscall
  li $v0, 0
  jr $ra
print_bool:
  bnez $a0, __pb_true
  la $a0, __false
  li $v0, 4
  syscall
  li $v0, 0
  jr $ra
__pb_true:
  la $a0, __true
  li $v0, 4
  syscall
  li $v0, 0
  jr $ra
read_int:
  li $v0, 5
  syscall
  jr $ra
read_bool:
  li $v0, 5
  syscall
  beqz $v0, __rb_zero
  li $v0, 1
  jr $ra
__rb_zero:
  li $v0, 0
  jr $ra
read_string:
  la $a0, __buf
  li $a1, 256
  li $v0, 8
  syscall
  la $v0, __buf
  jr $ra
main:
  addi $sp, $sp, -8
  sw $ra, 4($sp)
  sw $fp, 0($sp)
  move $fp, $sp
  addi $sp, $sp, -8
  li $v0, 5
  sw $v0, -4($fp)
  li $v0, 1
  sw $v0, -8($fp)
loop_0001:
  lw $v0, -4($fp)
  addi $sp, $sp, -4
  sw $v0, 0($sp)
  li $v0, 0
  lw $t0, 0($sp)
  addi $sp, $sp, 4
  slt $v0, $v0, $t0
  beqz $v0, endloop_0002
  lw $v0, -8($fp)
  addi $sp, $sp, -4
  sw $v0, 0($sp)
  lw $v0, -4($fp)
  lw $t0, 0($sp)
  addi $sp, $sp, 4
  mul $v0, $t0, $v0
  sw $v0, -8($fp)
  lw $v0, -4($fp)
  addi $sp, $sp, -4
  sw $v0, 0($sp)
  li $v0, 1
  lw $t0, 0($sp)
  addi $sp, $sp, 4
  sub $v0, $t0, $v0
  sw $v0, -4($fp)
  b loop_0001
endloop_0002:
  lw $v0, -8($fp)
  addi $sp, $sp, -4
  sw $v0, 0($sp)
  li $v0, 120
  lw $t0, 0($sp)
  addi $sp, $sp, 4
  sub $t1, $t0, $v0
  beqz $t1, eq_true_0005
  li $v0, 0
  b bool_end_0006
eq_true_0005:
  li $v0, 1
bool_end_0006:
  beqz $v0, else_0003
  li $v0, 1
  move $a0, $v0
  jal print_bool
  b ifend_0004
else_0003:
  li $v0, 0
  move $a0, $v0
  jal print_bool
ifend_0004:
  li $v0, 0
  j main_epilogue
main_epilogue:
  addi $sp, $sp, 8
  lw $fp, 0($sp)
  lw $ra, 4($sp)
  addi $sp, $sp, 8
  li $v0, 10
  syscall

.data
__true: .asciiz "true"
__false: .asciiz "false"
__buf: .space 256
