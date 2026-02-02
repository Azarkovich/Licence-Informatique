type reg =
  | ZERO
  | V0 | V1
  | A0 | A1 | A2 | A3
  | T0 | T1 | T2 | T3 | T4 | T5 | T6 | T7 | T8 | T9
  | S0 | S1 | S2 | S3 | S4 | S5 | S6 | S7
  | SP | FP | RA

type label = string

type instr =
  | Label  of label
  | Li     of reg * int
  | La     of reg * label
  | Move   of reg * reg
  | Add    of reg * reg * reg
  | Addi   of reg * reg * int
  | Sub    of reg * reg * reg
  | Mul    of reg * reg * reg
  | Div    of reg * reg
  | Mflo   of reg
  | Mfhi   of reg
  | Slt    of reg * reg * reg
  | Lw     of reg * int * reg
  | Sw     of reg * int * reg
  | Beqz   of reg * label
  | Bnez   of reg * label
  | B      of label
  | J      of label
  | Jal    of label
  | Jr     of reg
  | Syscall

type directive =
  | Asciiz of string
  | Space  of int

type decl = label * directive
type asm = { text: instr list ; data: decl list }

let ps = Printf.sprintf

let fmt_reg = function
  | ZERO -> "$zero"
  | V0 -> "$v0" | V1 -> "$v1"
  | A0 -> "$a0" | A1 -> "$a1" | A2 -> "$a2" | A3 -> "$a3"
  | T0 -> "$t0" | T1 -> "$t1" | T2 -> "$t2" | T3 -> "$t3" | T4 -> "$t4"
  | T5 -> "$t5" | T6 -> "$t6" | T7 -> "$t7" | T8 -> "$t8" | T9 -> "$t9"
  | S0 -> "$s0" | S1 -> "$s1" | S2 -> "$s2" | S3 -> "$s3"
  | S4 -> "$s4" | S5 -> "$s5" | S6 -> "$s6" | S7 -> "$s7"
  | SP -> "$sp" | FP -> "$fp" | RA -> "$ra"

let fmt_instr = function
  | Label l -> ps "%s:" l
  | Li (r, i) -> ps "  li %s, %d" (fmt_reg r) i
  | La (r, l) -> ps "  la %s, %s" (fmt_reg r) l
  | Move (d,s) -> ps "  move %s, %s" (fmt_reg d) (fmt_reg s)
  | Add (d,a,b) -> ps "  add %s, %s, %s" (fmt_reg d) (fmt_reg a) (fmt_reg b)
  | Addi (d,a,i) -> ps "  addi %s, %s, %d" (fmt_reg d) (fmt_reg a) i
  | Sub (d,a,b) -> ps "  sub %s, %s, %s" (fmt_reg d) (fmt_reg a) (fmt_reg b)
  | Mul (d,a,b) -> ps "  mul %s, %s, %s" (fmt_reg d) (fmt_reg a) (fmt_reg b)
  | Div (a,b) -> ps "  div %s, %s" (fmt_reg a) (fmt_reg b)
  | Mflo r -> ps "  mflo %s" (fmt_reg r)
  | Mfhi r -> ps "  mfhi %s" (fmt_reg r)
  | Slt (d,a,b) -> ps "  slt %s, %s, %s" (fmt_reg d) (fmt_reg a) (fmt_reg b)
  | Lw (r, off, base) -> ps "  lw %s, %d(%s)" (fmt_reg r) off (fmt_reg base)
  | Sw (r, off, base) -> ps "  sw %s, %d(%s)" (fmt_reg r) off (fmt_reg base)
  | Beqz (r,l) -> ps "  beqz %s, %s" (fmt_reg r) l
  | Bnez (r,l) -> ps "  bnez %s, %s" (fmt_reg r) l
  | B l -> ps "  b %s" l
  | J l -> ps "  j %s" l
  | Jal l -> ps "  jal %s" l
  | Jr r -> ps "  jr %s" (fmt_reg r)
  | Syscall -> "  syscall"

let fmt_dir = function
  | Asciiz s -> ps ".asciiz \"%s\"" s
  | Space n  -> ps ".space %d" n

let emit oc asm =
  Printf.fprintf oc ".text\n.globl main\n";
  List.iter (fun i -> Printf.fprintf oc "%s\n" (fmt_instr i)) asm.text;
  Printf.fprintf oc "\n.data\n";
  List.iter (fun (l, d) -> Printf.fprintf oc "%s: %s\n" l (fmt_dir d)) asm.data
