alias Esolix.Langs.Brainfuck

# Brainfuck.eval_alt("""
#         Calculate the value 256 and test if it's zero
#         If the interpreter errors on overflow this is where it'll happen
#         ++++++++[>++++++++<-]>[<++++>-]
#         +<[>-<
#             Not zero so multiply by 256 again to get 65536
#             [>++++<-]>[<++++++++>-]<[>++++++++<-]
#             +>[>
#                 # Print "32"
#                 ++++++++++[>+++++<-]>+.-.[-]<
#             <[-]<->] <[>>
#                 # Print "16"
#                 +++++++[>+++++++<-]>.+++++.[-]<
#         <<-]] >[>
#             # Print "8"
#             ++++++++[>+++++++<-]>.[-]<
#         <-]<
#         # Print " bit cells\n"
#         +++++++++++[>+++>+++++++++>+++++++++>+<<<<-]>-.>-.+++++++.+++++++++++.<.
#         >>.++.+++++++..<-.>>-
#         Clean up used cells.
#         [[-]<]
#         """, tape_params: [cell_byte_size: 2])


  alias Esolix.Langs.Brainfuck
  alias Esolix.DataStructures.Tape

  # Notes on performance

  # Accessing element in a long grapheme_list, string, or charlist
  # From Fastest to Slowest: Enum.at(charlist, n) -> Enum.at(grapheme_list, n), String.at(string, n)

  # Comparision of elements ("case elem do ...")
  # Comparision to codepoints/numbers faster than comparison to graphemes


  string_10000 = List.duplicate("1234567890", 1000) |> Enum.join()
  string_100000 = List.duplicate("1234567890", 10000) |> Enum.join()
  string_1000000 = List.duplicate("1234567890", 100000) |> Enum.join()
  list_10000 = String.graphemes(string_10000)
  list_100000 = String.graphemes(string_100000)
  list_1000000 = String.graphemes(string_1000000)
  charlist_10000 = String.to_charlist(string_10000)
  charlist_100000 = String.to_charlist(string_100000)
  charlist_1000000 = String.to_charlist(string_1000000)

  codepoint_case = fn (elem, x) ->
    case elem do
      48 -> x + 0
      49 -> x + 1
      50 -> x + 2
      51 -> x + 3
      52 -> x + 4
      53 -> x + 5
      54 -> x + 6
      55 -> x + 7
      56 -> x + 8
      57 -> x + 9
      _ -> x
    end
  end

  grapheme_case = fn (elem, x) ->
    case elem do
      "0" -> x + 0
      "1" -> x + 1
      "2" -> x + 2
      "3" -> x + 3
      "4" -> x + 4
      "5" -> x + 5
      "6" -> x + 6
      "7" -> x + 7
      "8" -> x + 8
      "9" -> x + 9
      _ -> x
    end
  end


  # Access performance

  # Benchee.run(%{
  #   "string_at_10000" => fn -> String.at(string_10000, 5000) end,
  #   "string_at_100000" => fn -> String.at(string_100000, 50000) end,
  #   "string_at_1000000" => fn -> String.at(string_1000000, 500000) end,
  #   "list_at_10000" => fn -> Enum.at(list_10000, 5000) end,
  #   "list_at_100000" => fn -> Enum.at(list_100000, 50000) end,
  #   "list_at_1000000" => fn -> Enum.at(list_1000000, 500000) end,
  #   "charlist_at_10000" => fn -> Enum.at(charlist_10000, 5000) end,
  #   "charlist_at_100000" => fn -> Enum.at(charlist_100000, 50000) end,
  #   "charlist_at_1000000" => fn -> Enum.at(charlist_1000000, 500000) end,
  # })

  # comparision (case elem do) performance

  # Benchee.run(%{
  #   "grapheme_case_10000" => fn -> Enum.map(list_10000, fn elem -> apply(grapheme_case, [elem, 5]) end) end,
  #   "grapheme_case_100000" => fn -> Enum.map(list_100000, fn elem -> apply(grapheme_case, [elem, 5]) end) end,
  #   "grapheme_case_1000000" => fn -> Enum.map(list_1000000, fn elem -> apply(grapheme_case, [elem, 5]) end) end,
  #   "codepoint_case_10000" => fn -> Enum.map(charlist_10000, fn elem -> apply(codepoint_case, [elem, 5]) end) end,
  #   "codepoint_case_100000" => fn -> Enum.map(charlist_100000, fn elem -> apply(codepoint_case, [elem, 5]) end) end,
  #   "codepoint_case_1000000" => fn -> Enum.map(charlist_1000000, fn elem -> apply(codepoint_case, [elem, 5]) end) end
  # })

  # Tape Benchmarks

  # tape = Tape.init(cell_byte_size: 1)
  # tape_loop = Tape.init(cell_byte_size: 1, loop: true)
  # tape_no_limit = Tape.init()
  # tape_input = Tape.init(cell_byte_size: 1, input: "This is a reaaaaaally long input, blah blah blah and a lot of this repeats This is a reaaaaaally long input, blah blah blah and a lot of this repeats This is a reaaaaaally long input, blah blah blah and a lot of this repeats This is a reaaaaaally long input, blah blah blah and a lot of this repeats This is a reaaaaaally long input, blah blah blah and a lot of this repeats This is a reaaaaaally long input, blah blah blah and a lot of this repeats This is a reaaaaaally long input, blah blah blah and a lot of this repeats")

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

  byte_size_bf = """
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
  """

  hello_world_bf = "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."
  hello_world_100_bf = List.duplicate(hello_world_bf, 100) |> Enum.join("")

  # calculator = """
  # >>>>>>>>>>+@<<<<<<<<<++++[->>>>>>>>>>>>++++++++<<<<<<<<<<<<]>>>>>>>>>>>>>++++++++++@<<<<<<<<<<<<<+++
  # ++++++++[>>>>>>>>>>>>>>++++++<<<<<<<<<<<<<<-]>>>>>>>>>>>>>>.<<<<<<<<<<<<<<++++++++[>>>>>>>>>>>>>>+++
  # +++<<<<<<<<<<<<<<-]>>>>>>>>>>>>>>.<<<<<<<<<<<<<<++++[>>>>>>>>>>>>>>----<<<<<<<<<<<<<<-]>>>>>>>>>>>>>
  # >-.++++++++.+++++.--------.<<<<<<<<<<<<<<+++++[>>>>>>>>>>>>>>+++<<<<<<<<<<<<<<-]>>>>>>>>>>>>>>.<<<<<
  # <<<<<<<<<++++++[>>>>>>>>>>>>>>---<<<<<<<<<<<<<<-]>>>>>>>>>>>>>>.++++++++.<<<<<<<<<<<<<<+++++++[>>>>>
  # >>>>>>>>>-----------<<<<<<<<<<<<<<-]>>>>>>>>>>>>>>++.<<<<<<<<<<<<<<+++++++[>>>>>>>>>>>>>>+++++<<<<<<
  # <<<<<<<<-]>>>>>>>>>>>>>>.<<<<<<<<<<<<<<++++++[>>>>>>>>>>>>>>+++++<<<<<<<<<<<<<<-]>>>>>>>>>>>>>>.++++
  # +++++++.---------.<<<<<<<<<<<<<<++++++[>>>>>>>>>>>>>>+++<<<<<<<<<<<<<<-]>>>>>>>>>>>>>>.---------.---
  # --------.<<<<<<<<<<<<<<++++[>>>>>>>>>>>>>>+++++<<<<<<<<<<<<<<-]>>>>>>>>>>>>>>-.-----.+++.<<<<<<<<<<<
  # <<<+++++++++[>>>>>>>>>>>>>>---------<<<<<<<<<<<<<<-]>>>>>>>>>>>>>>-.<<<<<<<<<<<<<<+++++++[>>>>>>>>>>
  # >>>>---<<<<<<<<<<<<<<-]>>>>>>>>>>>>>>-.[-]@<<<<<<+[>>>>>>>,[<<<<<<<<<<<<<<<+<+>>>>>>>>>>>>>>>>-]<<<<
  # <<<<<<<<<<<[>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<-]++++++++[<---->-]<[>+<-]+>[<->[-]]<[[-]>-<]>+[->>>>>>>>
  # >>>>>>>[<<<<<<<<<<<<<<<+<+>>>>>>>>>>>>>>>>-]<<<<<<<<<<<<<<<[>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<-]+++++++
  # ++++[<--------->-]<[>+<-]+>[<->[-]]<[[-]>>>>>>>>>>>>>>>++++++++++.[-]++++++++++.[-]<..<<<<<->-<<<<<<
  # <<<-<]>+[->>>>>>>>>>>>>>>[<<<<<<<<<<<<<<<+<+>>>>>>>>>>>>>>>>-]<<<<<<<<<<<<<<<[>>>>>>>>>>>>>>>+<<<<<<
  # <<<<<<<<<-]++++++++++[<------>-]-<[>+<-]+>[<->[-]]<[[-]>>>>>>>>>-<<<<<<<<-<]>+[->>>>>>>>>>>>>>>[<<<<
  # <<<<<<<<<<<+<+>>>>>>>>>>>>>>>>-]<<<<<<<<<<<<<<<[>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<-]+++++++[<------>-]-
  # <[>+<-]+>[<->[-]]<[[-]>>>>>>>>>>>>>>>>[<<<<<<<<<<<<+>>>>>>>>>>>>-]<<<<+<<<<<<<<<<<-<]>+[->>>>>>>>>>>
  # >>>>[<<<<<<<<<<<<<<<+<+>>>>>>>>>>>>>>>>-]<<<<<<<<<<<<<<<[>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<-]+++++++++[
  # <----->-]<[>+<-]+>[<->[-]]<[[-]>>>>>>>>>>>>>>>>[<<<<<<<<<<<<+>>>>>>>>>>>>-]<<<<+<<<<<<<<<<<-<]>+[->>
  # >>>>>>>>>>>>>[<<<<<<<<<<<<<<<+<+>>>>>>>>>>>>>>>>-]<<<<<<<<<<<<<<<[>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<-]+
  # ++++++[<------>-]<[>+<-]+>[<->[-]]<[[-]>>>>>>>>>>>>>>>>[<<<<<<<<<<<<+>>>>>>>>>>>>-]<<<<+<<<<<<<<<<<-
  # <]>+[->>>>>>>>>>>>>>>[<<<<<<<<<<<<<<<+<+>>>>>>>>>>>>>>>>-]<<<<<<<<<<<<<<<[>>>>>>>>>>>>>>>+<<<<<<<<<<
  # <<<<<-]++++++[<-------->-]+<[>+<-]+>[<->[-]]<[[-]>>>>>>>>>>>>>>>>[<<<<<<<<<<<<+>>>>>>>>>>>>-]<<<<+<<
  # <<<<<<<<<-<]>+[->>>>>>>>>>>>>>>[<<<<<<<<<<<<<<<+<+>>>>>>>>>>>>>>>>-]<<<<<<<<<<<<<<<[>>>>>>>>>>>>>>>+
  # <<<<<<<<<<<<<<<-]++++++[<------>-]-<[>+<-]+>[<->[-]]<[[-]>>>>>>>>>>>>>>>>[<<<<<<<<<<<<+>>>>>>>>>>>>-
  # ]<<<<+<<<<<<<<<<<-<]>+[->>>>>>>>>>>>>>>[<<<<<<<<<<<<<<<+<+>>>>>>>>>>>>>>>>-]<<<<<<<<<<<<<<<[>>>>>>>>
  # >>>>>>>+<<<<<<<<<<<<<<<-]++++++++[<------------>-]++<[>+<-]+>[<->[-]]<[[-]>>>>>>>>>>>>>>>>[<<<<<<<<<
  # <<<+>>>>>>>>>>>>-]<<<<+<<<<<<<<<<<-<]>+[-++++++++[->>>>>>>>>>>>>>>------<<<<<<<<<<<<<<<]>>>>>>>>>>>[
  # <<<<<<<<<<<+<+>>>>>>>>>>>>-]<<<<<<<<<<<[>>>>>>>>>>>+<<<<<<<<<<<-]+[<->-]+<[>+<-]+>[<->[-]]<[[-]>>[<+
  # >-]<[>++++++++++<-]>>>>>>>>>>>>>>>[<<<<<<<<<<<<<<+>>>>>>>>>>>>>>-]<<<<<<<<<<<<<<<-<]>+[->>>>>>>>>>>[
  # <<<<<<<<<<<+<+>>>>>>>>>>>>-]<<<<<<<<<<<[>>>>>>>>>>>+<<<<<<<<<<<-]+[<->-]<[>+<-]+>[<->[-]]<[[-]>>>[<<
  # +>>-]<<[>>++++++++++<<-]>>>>>>>>>>>>>>>[<<<<<<<<<<<<<+>>>>>>>>>>>>>-]<<<<<<<<<<<<<<<-<]>+[->>>>>>>>>
  # >>>>>++++++++++.[-]<<<<<+<<<<<<<<<]]]]]]]]]]]>>>>>>>>]@<<<<<[<<<+<+>>>>-]<<<[>>>+<<<-]+++++++[<-----
  # ->-]-<[>+<-]+>[<->[-]]<[[-]>>[>>>>>>>>>+<<<<<<<<<-]>[>>>>>>>>+<<<<<<<<-]<<<]>>>>[<<<+<+>>>>-]<<<[>>>
  # +<<<-]+++++++[<------>-]<[>+<-]+>[<->[-]]<[[-]>>[->[<<+>>>>>>>>>>+<<<<<<<<-]<<[>>+<<-]>]<<]>>>>[<<<+
  # <+>>>>-]<<<[>>>+<<<-]+++++++++[<----->-]<[>+<-]+>[<->[-]]<[[-]>>[>>>>>>>>>+<<<<<<<<<-]>[->>>>>>>>-<<
  # <<<<<<]<<<]>>>>[<<<+<+>>>>-]<<<[>>>+<<<-]++++++[<-------->-]+<[>+<-]+>[<->[-]]<[[-]>>>[<<+>>>>>>>>+<
  # <<<<<-]<<[>>+<<-]>[->>>>>>>-[<<<<<<<<+<+>>>>>>>>>-]<<<<<<<<[>>>>>>>>+<<<<<<<<-]<[[-]>-<]>+[-<+>]<[[-
  # ]>>>[<<+>>>>>>>>+<<<<<<-]<<[>>+<<-]>>>>>>>>>>+<<<<<<<<<<<]>>]<<]>>>>[<<<+<+>>>>-]<<<[>>>+<<<-]++++++
  # [<------>-]-<[>+<-]+>[<->[-]]<[[-]>>>[<<+>>>>>>>>+<<<<<<-]<<[>>+<<-]>[->>>>>>>-[<<<<<<<<+<+>>>>>>>>>
  # -]<<<<<<<<[>>>>>>>>+<<<<<<<<-]<[[-]>-<]>+[-<+>]<[[-]>>>[<<+>>>>>>>>+<<<<<<-]<<[>>+<<-]<]>>]>[>>>>>>>
  # >+<<<<<<<<-]>>>>>>[>>-<<-]<<<<<<<<<]>>>>[<<<+<+>>>>-]<<<[>>>+<<<-]++++++++[<------------>-]++<[>+<-]
  # +>[<->[-]]<[[-]>>>>>>>>>>>+<<<<<<<<[>>>>>>>>[<<<<<<<<<[<+<+>>-]<[>+<-]>>>>>>>>>>-]<<<<<<<<<<<[>>>>>>
  # >>>>>+<<<<<<<<<<<-]>>>-]<<<]>>>>>>>>>>[<<<<<<<<<+<+>>>>>>>>>>-]<<<<<<<<<[>>>>>>>>>+<<<<<<<<<-]<[[-]>
  # >>>>>>>>>>>>.<<<<<<<++++++++++>>>>>[<<<<<<<<<<+>>>>>>>>>>>>>>>>+<<<<<<-]<<<<<<<<<<[>>>>>>>>>>+<<<<<<
  # <<<<-]>>>>>>>>>>>>>>>>[-<<<<<<<<<<<-[<<<<<+<+>>>>>>-]<<<<<[>>>>>+<<<<<-]<[[-]>-<]>+[->>>>>>+<+++++++
  # +++<<<<<]>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<++++++++++>>>>>[-<<<<<->>>>>]<<<<<[->>>>>+<<<<<]>>>>>>[->>
  # >>>>>>>>+<<<<<<<<<<]++++++++++>>>>>>>>>>[-<<<<<<<<<<-[<<<<<<+<+>>>>>>>-]<<<<<<[>>>>>>+<<<<<<-]<[[-]>
  # -<]>+[->>>>>>>+<++++++++++<<<<<<]>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<++++++++++>>>>>>[-<<<<<<->>>>>>]<<
  # <<<<[->>>>>>+<<<<<<]>>>>>>[<<<<<<+>>>>+>>-]<<<<<<[>>>>>>+<<<<<<-]>>>>>>>[<<<<<<<+>>>>+>>>-]<<<<<<<[>
  # >>>>>>+<<<<<<<-]>>>>>>>[<<<<<<<+<+>>>>>>>>-]<<<<<<<[>>>>>>>+<<<<<<<-]<[[-]>++++++++[->>>>>>>++++++<<
  # <<<<<]>>>>>>>.<<<<<<<<]>>>>>[<<<<+<+>>>>>-]<<<<[>>>>+<<<<-]<[[-]>++++++++[->>>>>>++++++<<<<<<]>>>>>>
  # .<<<<<<<]>++++++++[->>>>>++++++<<<<<]>>>>>.[-]>[-]>[-]<<<<<<<<]
  # """


  Benchee.run(%{
    "hello_world" => fn -> Brainfuck.eval(hello_world_bf, [tape_params: [cell_byte_size: 1]]) end,
    "hello_world_alt" => fn -> Brainfuck.eval_alt(hello_world_bf, [tape_params: [cell_byte_size: 1]]) end,
    # "calculator_add" => fn -> Brainfuck.eval(calculator, "134+55=", [tape_params: [cell_byte_size: 2]]) end,
    # "calculator_sub" => fn -> Brainfuck.eval(calculator, "55-100=", [tape_params: [cell_byte_size: 2]]) end,
    # "calculator_mult" => fn -> Brainfuck.eval(calculator, "134*55=", [tape_params: [cell_byte_size: 2]]) end,
    # "calculator_div" => fn -> Brainfuck.eval(calculator, "134/55=", [tape_params: [cell_byte_size: 2]]) end,
    # "calculator_exp" => fn -> Brainfuck.eval(calculator, "4^6=", [tape_params: [cell_byte_size: 2]]) end,
    # "hello_world_bracket" => fn -> Brainfuck.group_by_brackets(hello_world_bf) end,
    # "hello_worldx100_bracket" => fn -> Brainfuck.group_by_brackets(hello_world_100_bf) end,
    "byte_size_1" => fn -> Brainfuck.eval(byte_size_bf) end,
    "byte_size_1_alt" => fn -> Brainfuck.eval_alt(byte_size_bf) end,
    "byte_size_2" => fn -> Brainfuck.eval(byte_size_bf, [tape_params: [cell_byte_size: 2]]) end,
    "byte_size_2_alt" => fn -> Brainfuck.eval_alt(byte_size_bf, [tape_params: [cell_byte_size: 2]]) end,
    "byte_size_4" => fn -> Brainfuck.eval(byte_size_bf, [tape_params: [cell_byte_size: 4]]) end,
    "byte_size_4_alt" => fn -> Brainfuck.eval_alt(byte_size_bf, [tape_params: [cell_byte_size: 4]]) end,
  })

# Original                  ips        average  deviation         median         99th %
# hello_world            345.46        2.89 ms    ±13.21%        2.80 ms        4.15 ms
# hello_world_alt        290.19        3.45 ms    ±13.02%        3.34 ms        4.91 ms
# byte_size_1            148.98        6.71 ms    ±33.62%        6.50 ms       12.80 ms
# byte_size_1_alt         52.60       19.01 ms    ±15.76%       19.11 ms       25.54 ms
# byte_size_2             19.10       52.35 ms    ±10.27%       50.03 ms       66.95 ms
# byte_size_4              4.60      217.59 ms     ±2.20%      217.43 ms      228.39 ms
# byte_size_2_alt          3.84      260.73 ms     ±2.41%      261.21 ms      269.59 ms
# byte_size_4_alt          1.14      879.46 ms     ±0.58%      879.38 ms      886.01 ms

# Comparison:
# hello_world            345.46
# hello_world_alt        290.19 - 1.19x slower +0.55 ms
# byte_size_1            148.98 - 2.32x slower +3.82 ms
# byte_size_1_alt         52.60 - 6.57x slower +16.12 ms
# byte_size_2             19.10 - 18.08x slower +49.46 ms
# byte_size_4              4.60 - 75.17x slower +214.70 ms
# byte_size_2_alt          3.84 - 90.07x slower +257.84 ms
# byte_size_4_alt          1.14 - 303.82x slower +876.56 ms



# width10 orig              ips        average  deviation         median         99th %
# byte_size_1            528.93        1.89 ms    ±35.60%        1.64 ms        4.21 ms
# hello_world            342.23        2.92 ms    ±13.45%        2.83 ms        3.96 ms
# hello_world_alt        282.21        3.54 ms    ±20.29%        3.45 ms        4.57 ms
# byte_size_1_alt        101.07        9.89 ms    ±15.75%        9.44 ms       17.30 ms
# byte_size_2             17.30       57.80 ms    ±18.84%       54.04 ms      106.25 ms
# byte_size_4              4.57      218.84 ms     ±3.11%      217.71 ms      232.28 ms
# byte_size_2_alt          3.75      266.44 ms     ±5.95%      260.67 ms      313.73 ms
# byte_size_4_alt          1.10      910.99 ms     ±3.63%      900.41 ms      974.94 ms

# Comparison:
# byte_size_1            528.93
# hello_world            342.23 - 1.55x slower +1.03 ms
# hello_world_alt        282.21 - 1.87x slower +1.65 ms
# byte_size_1_alt        101.07 - 5.23x slower +8.00 ms
# byte_size_2             17.30 - 30.57x slower +55.91 ms
# byte_size_4              4.57 - 115.75x slower +216.95 ms
# byte_size_2_alt          3.75 - 140.93x slower +264.55 ms
# byte_size_4_alt          1.10 - 481.85x slower +909.10 ms


# width10 alt               ips        average  deviation         median         99th %
# hello_world_alt       1879.15        0.53 ms    ±14.26%        0.50 ms        0.83 ms
# hello_world           1818.78        0.55 ms    ±17.39%        0.51 ms        0.94 ms
# byte_size_1            517.15        1.93 ms    ±28.72%        1.72 ms        3.94 ms
# byte_size_1_alt        109.25        9.15 ms     ±7.23%        9.02 ms       11.42 ms
# byte_size_2             20.89       47.86 ms     ±3.50%       47.49 ms       56.49 ms
# byte_size_4              4.57      218.96 ms     ±2.21%      217.96 ms      236.52 ms
# byte_size_2_alt          4.03      248.10 ms     ±1.64%      248.09 ms      255.87 ms
# byte_size_4_alt          1.12      894.86 ms     ±7.90%      851.99 ms      992.58 ms

# Comparison:
# hello_world_alt       1879.15
# hello_world           1818.78 - 1.03x slower +0.0177 ms
# byte_size_1            517.15 - 3.63x slower +1.40 ms
# byte_size_1_alt        109.25 - 17.20x slower +8.62 ms
# byte_size_2             20.89 - 89.93x slower +47.33 ms
# byte_size_4              4.57 - 411.45x slower +218.42 ms
# byte_size_2_alt          4.03 - 466.23x slower +247.57 ms
# byte_size_4_alt          1.12 - 1681.58x slower +894.33 ms
