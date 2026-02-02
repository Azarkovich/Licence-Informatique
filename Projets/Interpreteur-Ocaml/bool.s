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
  addi $sp, $sp, 0
  li $v0, 1
  addi $sp, $sp, -4
  sw $v0, 0($sp)
  li $v0, 0
  beqz $v0, not_true_0001
  li $v0, 0
  b not_end_0002
not_true_0001:
  li $v0, 1
not_end_0002:
  lw $t0, 0($sp)
  addi $sp, $sp, 4
  beqz $t0, and_false_0003
  beqz $v0, and_false_0003
  li $v0, 1
  b and_end_0004
and_false_0003:
  li $v0, 0
and_end_0004:
  move $a0, $v0
  jal print_bool
  li $v0, 0
  j main_epilogue
main_epilogue:
  addi $sp, $sp, 0
  lw $fp, 0($sp)
  lw $ra, 4($sp)
  addi $sp, $sp, 8
  li $v0, 10
  syscall

.data
__true: .asciiz "true"
__false: .asciiz "false"
__buf: .space 256
