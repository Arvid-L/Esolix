alias Esolix.Langs.Brainfuck
alias Esolix.Memory.Tape

tape = Tape.init(cell_byte_size: 1)
tape_loop = Tape.init(cell_byte_size: 1, loop: true)
tape_no_limit = Tape.init()
tape_input = Tape.init(cell_byte_size: 1, input: "This is a reaaaaaally long input, blah blah blah and a lot of this repeats This is a reaaaaaally long input, blah blah blah and a lot of this repeats This is a reaaaaaally long input, blah blah blah and a lot of this repeats This is a reaaaaaally long input, blah blah blah and a lot of this repeats This is a reaaaaaally long input, blah blah blah and a lot of this repeats This is a reaaaaaally long input, blah blah blah and a lot of this repeats This is a reaaaaaally long input, blah blah blah and a lot of this repeats")

# Tape Benchmarks
# Benchee.run(%{
#   "inc" => fn -> tape = Tape.inc(tape) end,
#   "inc_no_limit" => fn -> tape_no_limit = Tape.inc(tape_no_limit) end,
#   "dec" => fn -> tape = Tape.dec(tape) end,
#   "dec_no_limit" => fn -> tape_no_limit = Tape.dec(tape_no_limit) end,
#   "right" => fn -> tape_loop = Tape.right(tape_loop) end,
#   "left" => fn -> tape_loop = Tape.left(tape_loop) end,
#   "cell" => fn -> Tape.cell(tape) end,
#   "print" => fn -> Tape.print(tape, mode: :ascii) end,
#   "handle_input" => fn -> tape_input = Tape.handle_input(tape_input) end,
# })

# Brainfuck Benchmarks
Benchee.run(%{
  "hello_world" => fn -> Brainfuck.eval("") end,
  "byte_size_1" => fn -> Brainfuck.eval("""
    Calculate the value 256 and test if it's zero
    If the interpreter errors on overflow this is where it'll happen
    ++++++++[>++++++++<-]>[<++++>-]
    +<[>-<
        Not zero so multiply by 256 again to get 65536
        [>++++<-]>[<++++++++>-]<[>++++++++<-]
        +>[>
            # Print "32"
            ++++++++++[>+++++<-]>+.-.[-]<
        <[-]<->] <[>>
            # Print "16"
            +++++++[>+++++++<-]>.+++++.[-]<
    <<-]] >[>
        # Print "8"
        ++++++++[>+++++++<-]>.[-]<
    <-]<
    # Print " bit cells\n"
    +++++++++++[>+++>+++++++++>+++++++++>+<<<<-]>-.>-.+++++++.+++++++++++.<.
    >>.++.+++++++..<-.>>-
    Clean up used cells.
    [[-]<]
    """) end,
  "byte_size_2" => fn -> Brainfuck.eval("""
    Calculate the value 256 and test if it's zero
    If the interpreter errors on overflow this is where it'll happen
    ++++++++[>++++++++<-]>[<++++>-]
    +<[>-<
        Not zero so multiply by 256 again to get 65536
        [>++++<-]>[<++++++++>-]<[>++++++++<-]
        +>[>
            # Print "32"
            ++++++++++[>+++++<-]>+.-.[-]<
        <[-]<->] <[>>
            # Print "16"
            +++++++[>+++++++<-]>.+++++.[-]<
    <<-]] >[>
        # Print "8"
        ++++++++[>+++++++<-]>.[-]<
    <-]<
    # Print " bit cells\n"
    +++++++++++[>+++>+++++++++>+++++++++>+<<<<-]>-.>-.+++++++.+++++++++++.<.
    >>.++.+++++++..<-.>>-
    Clean up used cells.
    [[-]<]
    """, "", [tape_params: [cell_byte_size: 2]]) end,
  "byte_size_4" => fn -> Brainfuck.eval("""
    Calculate the value 256 and test if it's zero
    If the interpreter errors on overflow this is where it'll happen
    ++++++++[>++++++++<-]>[<++++>-]
    +<[>-<
        Not zero so multiply by 256 again to get 65536
        [>++++<-]>[<++++++++>-]<[>++++++++<-]
        +>[>
            # Print "32"
            ++++++++++[>+++++<-]>+.-.[-]<
        <[-]<->] <[>>
            # Print "16"
            +++++++[>+++++++<-]>.+++++.[-]<
    <<-]] >[>
        # Print "8"
        ++++++++[>+++++++<-]>.[-]<
    <-]<
    # Print " bit cells\n"
    +++++++++++[>+++>+++++++++>+++++++++>+<<<<-]>-.>-.+++++++.+++++++++++.<.
    >>.++.+++++++..<-.>>-
    Clean up used cells.
    [[-]<]
    """, "", [tape_params: [cell_byte_size: 4]]) end,
})
